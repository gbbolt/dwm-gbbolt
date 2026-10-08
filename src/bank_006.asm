INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $006", ROMX[$4000], BANK[$6]

;@ path: system/banks
;@ Bank number byte of bank $06 (actors on the field, skills learned on level-up, field input,
;@ screen scrolling, the field events and transitions).
BankNumber_06::
	db $06

;@ path: system/banks
;@ Far-call table of bank $06 (entry n = word n): 0 CheckActorOverlap, 1 DrawFieldActors,
;@ 2 UpdateFieldActors, 3 UpdateAllActors, 4 LoadFieldActorGfx, 5 FindLearnableSkill,
;@ 6 FieldInput.
FarTable_06::
	dw CheckActorOverlap
	dw DrawFieldActors
	dw UpdateFieldActors
	dw UpdateAllActors
	dw LoadFieldActorGfx
	dw FindLearnableSkill
	dw FieldInput

;@ def UpdateFieldActors()
;@ path: field/npcs
;@ Far entry 2: runs the actors' behaviours once per field frame, unless the field is busy
;@ (wFieldFlags bits 1, 3, 4 or 7), and not on step 1 of a screen-to-screen scroll (bit 2).
;@ test: skip works on the actor record at hNumber
UpdateFieldActors::
;> flags = wFieldFlags
;> if flags & 0x02: return
	ld a, [wFieldFlags]
	bit 1, a
	ret nz

;> if flags & 0x08: return
	bit 3, a
	ret nz

;> if flags & 0x10: return
	bit 4, a
	ret nz

;> if flags & 0x80: return
	bit 7, a
	ret nz

;> if flags & 0x04:                         # scrolling to the next screen
	bit 2, a
	jr z, UpdateAllActors

;>     if wScrollStep == 1: return
	ld a, [wScrollStep]
	cp $01
	ret z

;@ def UpdateAllActors()
;@ path: field/npcs
;@ Far entry 3: runs the behaviour of every actor in wActors (32-byte records, $FF ends the list;
;@ records whose byte +1 is $FF are empty).
;@ test: skip works on the actor record at hNumber
UpdateAllActors::
;> actor = wActors
	ld hl, wActors

;>@w while mem[actor] != 0xFF:
jr_006_402b:
	ld a, [hl]
	cp $ff
	ret z

;>     if mem[actor + 1] != 0xFF:
	inc hl
	ld a, [hl]
	dec hl
	cp $ff
;>         UpdateActor(actor)
	push hl
	call nz, UpdateActor
	pop hl
;>     actor += 0x20
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@w
	jr jr_006_402b

;@ def UpdateActor(actor: hl)
;@ path: field/npcs
;@ Runs one actor: stores its address in hNumber/hNumber+1 (all actor code reads it from there)
;@ and, unless it is hidden (flags bit 6), jumps to the behaviour in the low nibble of its flags.
;@ test: skip works on the actor record at hNumber
UpdateActor::
;> mem16[hNumber] = actor
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
;> if mem[actor] & 0x40: return             # hidden
	ld a, [hl]
	bit 6, a
	ret nz

;> return ActorBehaviours[mem[actor] & 0x0F]()
	and $0f
	rst $00

;@ path: field/npcs
;@ Jump table of the 16 actor behaviours (low nibble of actor byte +0): stand, spin, pace 2 tiles,
;@ walk a square, walk a figure, pace 3 tiles, stand still, face fixed, pace 1 tile, pace 2 tiles
;@ starting left, sway, 3 x stand, wander (gate floor, may touch Terry), wander quietly.
ActorBehaviours::
	dw ActorStand
	dw ActorSpin
	dw ActorPace2
	dw ActorWalkSquare
	dw ActorWalkFigure
	dw ActorPace3
	dw ActorStandStill
	dw ActorStandFixed
	dw ActorPace1
	dw ActorPace2L
	dw ActorSway
	dw ActorStand
	dw ActorStand
	dw ActorStand
	dw ActorWander
	dw ActorWanderQuiet

;@ def ActorStand()
;@ path: field/npcs/behaviours
;@ Behaviour 0 (and 11-13): stands on the spot, marching in place.
;@ test: skip works on the actor record at hNumber
ActorStand::
;> actor = mem16[hNumber]; flags = actor + 5
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if not mem[flags] & 0x40:                # not talking to Terry
	bit 6, [hl]
	jr nz, jr_006_408d

;>     if wScriptRunning: return SetActorMirror()
	ld a, [wScriptRunning]
	or a
	jp nz, SetActorMirror

;>     if wFieldTimer & 7: return AnimateActor()
	ld a, [wFieldTimer]
	and $07
	jp nz, AnimateActor

;> return FinishActorUpdate()
jr_006_408d:
	jp FinishActorUpdate


;@ def ActorSpin()
;@ path: field/npcs/behaviours
;@ Behaviour 1: stands and turns a quarter turn every 16 frames.
;@ test: skip works on the actor record at hNumber
ActorSpin::
;> if wFieldTimer & 7: return AnimateActor()
	ld a, [wFieldTimer]
	and $07
	jp nz, AnimateActor

;> if wFieldTimer & 0x0F == 0:
	ld a, [wFieldTimer]
	and $0f
	jr nz, jr_006_40ae

;>     actor = mem16[hNumber]; dirp = actor + 6
	ldh a, [hNumber]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     mem[dirp] = (mem[dirp] + 1) & 3
	ld a, [hl]
	inc a
	and $03
	ld [hl], a

;> return FinishActorUpdate()
jr_006_40ae:
	jp FinishActorUpdate


;@ def ActorPace2()
;@ path: field/npcs/behaviours
;@ Behaviour 2: paces 2 tiles to the right of its home tile and back, one pixel every other
;@ frame, pausing $10 frames at each tile. Phase (+8) 0 walks right, 1 walks left. It stops while
;@ it talks to Terry or a script runs.
;@ test: skip works on the actor record at hNumber
ActorPace2::
;> if wFieldTimer & 1: return AnimateActor()
	ld a, [wFieldTimer]
	and $01
	jp nz, AnimateActor

;> actor = mem16[hNumber]; timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[timer] == 0:
	ld a, [hli]
	or a
	jp nz, Jump_006_40fd

;>     dir = ((mem[actor + 8] & 1) ^ 1) * 2 + 1   # 3 = right, 1 = left
	ld a, [hld]
	and $01
	xor $01
	add a
	inc a
;>     mem[actor + 6] = dir
	dec hl
	ld [hld], a
;>     if not mem[actor + 5] & 0x40 and not wScriptRunning:
	bit 6, [hl]
	jp nz, Jump_006_40fd

	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_40fd

;>         mem[actor + 5] |= 0x01             # moving
	set 0, [hl]
;>         offset, target = ActorPace2Step()
	call ActorPace2Step
;>         offset -= target
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
;>         if offset == 0:                    # turning point reached
	ld a, c
	or b
	jr nz, jr_006_40fd

;>             phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>             mem[phase] = (mem[phase] + 1) & 1
	ld a, [hl]
	inc a
	and $01
	ld [hli], a
;>             mem[actor + 7] = 0x10          # pause
	ld [hl], $10

;> return FinishActorUpdate()
Jump_006_40fd:
jr_006_40fd:
	jp FinishActorUpdate


;@ def ActorPace2Step() -> (bc, de)
;@ path: field/npcs/behaviours
;@ One pixel of ActorPace2 for its phase; returns the new offset from home and the turning point.
;@ test: skip works on the actor record at hNumber
ActorPace2Step::
;> actor = mem16[hNumber]; phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> return ActorPace2Steps[mem[phase]]()
	ld a, [hl]
	rst $00

;@ path: field/npcs/behaviours
;@ Phase handlers of ActorPace2: right, left.
ActorPace2Steps::
	dw ActorPace2Right
	dw ActorPace2Left

;@ def ActorPace2Right() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 0 of ActorPace2: one pixel right, turning at +$20 (2 tiles).
;@ test: skip works on the actor record at hNumber
ActorPace2Right::
;> return MoveActorX(1), 0x20
	ld bc, $0001
	ld de, $0020
	jp MoveActorX


;@ def ActorPace2Left() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 1 of ActorPace2: one pixel left, turning at -$20.
;@ test: skip works on the actor record at hNumber
ActorPace2Left::
;> return MoveActorX(-1), -0x20
	ld bc, $ffff
	ld de, $ffe0
	jp MoveActorX


;@ def ActorWalkSquare()
;@ path: field/npcs/behaviours
;@ Behaviour 3: walks a 2 x 2 tile square from its home tile: down, right, up, left (phase 0,
;@ 3, 2, 1, which is also the facing), pausing $10 frames at each tile.
;@ test: skip works on the actor record at hNumber
ActorWalkSquare::
;> if wFieldTimer & 1: return AnimateActor()
	ld a, [wFieldTimer]
	and $01
	jp nz, AnimateActor

;> actor = mem16[hNumber]; timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[timer] == 0:
	ld a, [hli]
	or a
	jp nz, Jump_006_416a

;>     mem[actor + 6] = mem[actor + 8] & 3    # facing = phase
	ld a, [hld]
	and $03
	dec hl
	ld [hld], a
;>     if not mem[actor + 5] & 0x40 and not wScriptRunning:
	bit 6, [hl]
	jp nz, Jump_006_416a

	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_416a

;>         mem[actor + 5] |= 0x01             # moving
	set 0, [hl]
;>         offset, target = ActorSquareStep()
	call ActorSquareStep
;>         offset -= target
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
;>         if offset == 0:                    # corner reached
	ld a, c
	or b
	jr nz, jr_006_416a

;>             phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>             mem[phase] = (mem[phase] - 1) & 3
	ld a, [hl]
	dec a
	and $03
	ld [hli], a
;>             mem[actor + 7] = 0x10          # pause
	ld [hl], $10

;> return FinishActorUpdate()
Jump_006_416a:
jr_006_416a:
	jp FinishActorUpdate


;@ def ActorSquareStep() -> (bc, de)
;@ path: field/npcs/behaviours
;@ One pixel of ActorWalkSquare for its phase; returns the new offset from home and the corner.
;@ test: skip works on the actor record at hNumber
ActorSquareStep::
;> actor = mem16[hNumber]; phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> return ActorSquareSteps[mem[phase]]()
	ld a, [hl]
	rst $00

;@ path: field/npcs/behaviours
;@ Phase handlers of ActorWalkSquare: down, left, up, right.
ActorSquareSteps::
	dw ActorSquareDown
	dw ActorSquareLeft
	dw ActorSquareUp
	dw ActorSquareRight

;@ def ActorSquareDown() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 0 of ActorWalkSquare: one pixel down, corner at Y +$20.
;@ test: skip works on the actor record at hNumber
ActorSquareDown::
;> return MoveActorY(1), 0x20
	ld bc, $0001
	ld de, $0020
	jp MoveActorY


;@ def ActorSquareLeft() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 1 of ActorWalkSquare: one pixel left, corner at X +0.
;@ test: skip works on the actor record at hNumber
ActorSquareLeft::
;> return MoveActorX(-1), 0
	ld bc, $ffff
	ld de, $0000
	jp MoveActorX


;@ def ActorSquareUp() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 2 of ActorWalkSquare: one pixel up, corner at Y +0.
;@ test: skip works on the actor record at hNumber
ActorSquareUp::
;> return MoveActorY(-1), 0
	ld bc, $ffff
	ld de, $0000
	jp MoveActorY


;@ def ActorSquareRight() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 3 of ActorWalkSquare: one pixel right, corner at X +$20.
;@ test: skip works on the actor record at hNumber
ActorSquareRight::
;> return MoveActorX(1), 0x20
	ld bc, $0001
	ld de, $0020
	jp MoveActorX


;@ def ActorWalkFigure()
;@ path: field/npcs/behaviours
;@ Behaviour 4: walks a figure of two 3 x 3 tile squares side by side, left of its home tile, in
;@ 8 legs (phase +8 0-7; the facing of each leg comes from ActorFigureFacings), pausing $10
;@ frames at each tile.
;@ test: skip works on the actor record at hNumber
ActorWalkFigure::
;> if wFieldTimer & 1: return AnimateActor()
	ld a, [wFieldTimer]
	and $01
	jp nz, AnimateActor

;> actor = mem16[hNumber]; timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[timer] == 0:
	ld a, [hli]
	or a
	jp nz, Jump_006_41f7

;>     facing = ActorFigureFacings + (mem[actor + 8] & 7)
	ld a, [hld]
	and $07
	ld de, ActorFigureFacings
	add e
	ld e, a
	ld a, $00
;>     mem[actor + 6] = mem[facing]
	adc d
	ld d, a
	ld a, [de]
	dec hl
	ld [hld], a
;>     if not mem[actor + 5] & 0x40 and not wScriptRunning:
	bit 6, [hl]
	jp nz, Jump_006_41f7

	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_41f7

;>         mem[actor + 5] |= 0x01             # moving
	set 0, [hl]
;>         offset, target = ActorFigureStep()
	call ActorFigureStep
;>         offset -= target
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
;>         if offset == 0:                    # end of the leg
	ld a, c
	or b
	jr nz, jr_006_41f7

;>             phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>             mem[phase] = (mem[phase] + 1) & 7
	ld a, [hl]
	inc a
	and $07
	ld [hli], a
;>             mem[actor + 7] = 0x10          # pause
	ld [hl], $10

;> return FinishActorUpdate()
Jump_006_41f7:
jr_006_41f7:
	jp FinishActorUpdate


;@ def ActorFigureStep() -> (bc, de)
;@ path: field/npcs/behaviours
;@ One pixel of ActorWalkFigure for its phase; returns the new offset from home and the leg end.
;@ test: skip works on the actor record at hNumber
ActorFigureStep::
;> actor = mem16[hNumber]; phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> return ActorFigureSteps[mem[phase]]()
	ld a, [hl]
	rst $00

;@ path: field/npcs/behaviours
;@ The 8 legs of ActorWalkFigure.
ActorFigureSteps::
	dw ActorFigureStep0
	dw ActorFigureStep1
	dw ActorFigureStep2
	dw ActorFigureStep3
	dw ActorFigureStep4
	dw ActorFigureStep5
	dw ActorFigureStep6
	dw ActorFigureStep7

;@ def ActorFigureStep0() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Leg 0 of ActorWalkFigure: left to X -$30.
;@ test: skip works on the actor record at hNumber
ActorFigureStep0::
;> return MoveActorX(-1), -0x30
	ld bc, $ffff
	ld de, $ffd0
	jp MoveActorX


;@ def ActorFigureStep1() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Leg 1 of ActorWalkFigure: up to Y -$30.
;@ test: skip works on the actor record at hNumber
ActorFigureStep1::
;> return MoveActorY(-1), -0x30
	ld bc, $ffff
	ld de, $ffd0
	jp MoveActorY


;@ def ActorFigureStep2() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Leg 2 of ActorWalkFigure: left to X -$60.
;@ test: skip works on the actor record at hNumber
ActorFigureStep2::
;> return MoveActorX(-1), -0x60
	ld bc, $ffff
	ld de, $ffa0
	jp MoveActorX


;@ def ActorFigureStep3() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Leg 3 of ActorWalkFigure: down to Y 0.
;@ test: skip works on the actor record at hNumber
ActorFigureStep3::
;> return MoveActorY(1), 0
	ld bc, $0001
	ld de, $0000
	jp MoveActorY


;@ def ActorFigureStep4() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Leg 4 of ActorWalkFigure: right to X -$30.
;@ test: skip works on the actor record at hNumber
ActorFigureStep4::
;> return MoveActorX(1), -0x30
	ld bc, $0001
	ld de, $ffd0
	jp MoveActorX


;@ def ActorFigureStep5() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Leg 5 of ActorWalkFigure: up to Y -$30.
;@ test: skip works on the actor record at hNumber
ActorFigureStep5::
;> return MoveActorY(-1), -0x30
	ld bc, $ffff
	ld de, $ffd0
	jp MoveActorY


;@ def ActorFigureStep6() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Leg 6 of ActorWalkFigure: right to X 0.
;@ test: skip works on the actor record at hNumber
ActorFigureStep6::
;> return MoveActorX(1), 0
	ld bc, $0001
	ld de, $0000
	jp MoveActorX


;@ def ActorFigureStep7() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Leg 7 of ActorWalkFigure: down to Y 0, back home.
;@ test: skip works on the actor record at hNumber
ActorFigureStep7::
;> return MoveActorY(1), 0
	ld bc, $0001
	ld de, $0000
	jp MoveActorY

;@ path: field/npcs/behaviours
;@ Facing (0 down, 1 left, 2 up, 3 right) of each of the 8 legs of ActorWalkFigure.
ActorFigureFacings::
	db $01, $02, $01, $00, $03, $02, $03, $00

;@ def ActorPace3()
;@ path: field/npcs/behaviours
;@ Behaviour 5: paces 3 tiles to the right of its home tile and back (phase 0 right, 1 left),
;@ pausing $10 frames at each tile.
;@ test: skip works on the actor record at hNumber
ActorPace3::
;> if wFieldTimer & 1: return AnimateActor()
	ld a, [wFieldTimer]
	and $01
	jp nz, AnimateActor

;> actor = mem16[hNumber]; timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[timer] == 0:
	ld a, [hli]
	or a
	jp nz, Jump_006_42b2

;>     dir = ((mem[actor + 8] & 1) ^ 1) * 2 + 1   # 3 = right, 1 = left
	ld a, [hld]
	and $01
	xor $01
	add a
	inc a
;>     mem[actor + 6] = dir
	dec hl
	ld [hld], a
;>     if not mem[actor + 5] & 0x40 and not wScriptRunning:
	bit 6, [hl]
	jp nz, Jump_006_42b2

	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_42b2

;>         mem[actor + 5] |= 0x01             # moving
	set 0, [hl]
;>         offset, target = ActorPace3Step()
	call ActorPace3Step
;>         offset -= target
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
;>         if offset == 0:                    # turning point reached
	ld a, c
	or b
	jr nz, jr_006_42b2

;>             phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>             mem[phase] = (mem[phase] + 1) & 1
	ld a, [hl]
	inc a
	and $01
	ld [hli], a
;>             mem[actor + 7] = 0x10          # pause
	ld [hl], $10

;> return FinishActorUpdate()
Jump_006_42b2:
jr_006_42b2:
	jp FinishActorUpdate


;@ def ActorPace3Step() -> (bc, de)
;@ path: field/npcs/behaviours
;@ One pixel of ActorPace3 for its phase; returns the new offset from home and the turning point.
;@ test: skip works on the actor record at hNumber
ActorPace3Step::
;> actor = mem16[hNumber]; phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> return ActorPace3Steps[mem[phase]]()
	ld a, [hl]
	rst $00

;@ path: field/npcs/behaviours
;@ Phase handlers of ActorPace3: out (right), back (left).
ActorPace3Steps::
	dw ActorPace3Out
	dw ActorPace3Back

;@ def ActorPace3Out() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 0 of ActorPace3: one pixel right, turning at +$30.
;@ test: skip works on the actor record at hNumber
ActorPace3Out::
;> return MoveActorX(1), 0x30
	ld bc, $0001
	ld de, $0030
	jp MoveActorX


;@ def ActorPace3Back() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 1 of ActorPace3: one pixel left, back home at 0.
;@ test: skip works on the actor record at hNumber
ActorPace3Back::
;> return MoveActorX(-1), 0
	ld bc, $ffff
	ld de, $0000
	jp MoveActorX


;@ def ActorStandStill()
;@ path: field/npcs/behaviours
;@ Behaviour 6: stands on the spot and, unlike ActorStand, keeps its facing when Terry talks to it.
;@ The talking flag is cleared as soon as no script runs.
;@ test: skip works on the actor record at hNumber
ActorStandStill::
;> actor = mem16[hNumber]; flags = actor + 5
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if not mem[flags] & 0x40:                # not talking to Terry
	bit 6, [hl]
	jr nz, jr_006_42f4

;>     if wScriptRunning: return SetActorMirror()
	ld a, [wScriptRunning]
	or a
	jp nz, SetActorMirror

;>     if wFieldTimer & 7: return AnimateActor()
	ld a, [wFieldTimer]
	and $07
	jp nz, AnimateActor

;> if not wScriptRunning:
jr_006_42f4:
	ld a, [wScriptRunning]
	or a
	jr nz, jr_006_4306

;>     flags = actor + 5
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     mem[flags] &= ~0x40                  # talk over
	res 6, [hl]

;> return SetActorMirror()
jr_006_4306:
	jp SetActorMirror


;@ def ActorStandFixed()
;@ path: field/npcs/behaviours
;@ Behaviour 7: stands facing the direction in bits 4-5 of its byte +0 (turns to Terry while talking).
;@ test: skip works on the actor record at hNumber
ActorStandFixed::
;> actor = mem16[hNumber]; flags = actor + 5
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if not mem[flags] & 0x40:                # not talking to Terry
	bit 6, [hl]
	jr nz, jr_006_433c

;>     if wScriptRunning: return SetActorMirror()
	ld a, [wScriptRunning]
	or a
	jp nz, SetActorMirror

;>     if wFieldTimer & 7: return AnimateActor()
	ld a, [wFieldTimer]
	and $07
	jp nz, AnimateActor

;>     p = actor
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
;>     facing = (mem[p] >> 4) & 3
	ld a, [hl]
	swap a
	and $03
;>@s     mem[actor + 6] = facing
	push af
	ld a, l
	add $06
	ld l, a
	ld a, h
	adc $00
;=@s
	ld h, a
	pop af
	ld [hl], a

;> return FinishActorUpdate()
jr_006_433c:
	jp FinishActorUpdate


;@ def ActorPace1()
;@ path: field/npcs/behaviours
;@ Behaviour 8: paces 1 tile to the right of its home tile and back (phase 0 right, 1 left),
;@ pausing $10 frames at each tile.
;@ test: skip works on the actor record at hNumber
ActorPace1::
;> if wFieldTimer & 1: return AnimateActor()
	ld a, [wFieldTimer]
	and $01
	jp nz, AnimateActor

;> actor = mem16[hNumber]; timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[timer] == 0:
	ld a, [hli]
	or a
	jp nz, Jump_006_438b

;>     dir = ((mem[actor + 8] & 1) ^ 1) * 2 + 1   # 3 = right, 1 = left
	ld a, [hld]
	and $01
	xor $01
	add a
	inc a
;>     mem[actor + 6] = dir
	dec hl
	ld [hld], a
;>     if not mem[actor + 5] & 0x40 and not wScriptRunning:
	bit 6, [hl]
	jp nz, Jump_006_438b

	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_438b

;>         mem[actor + 5] |= 0x01             # moving
	set 0, [hl]
;>         offset, target = ActorPace1Step()
	call ActorPace1Step
;>         offset -= target
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
;>         if offset == 0:                    # turning point reached
	ld a, c
	or b
	jr nz, jr_006_438b

;>             phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>             mem[phase] = (mem[phase] + 1) & 1
	ld a, [hl]
	inc a
	and $01
	ld [hli], a
;>             mem[actor + 7] = 0x10          # pause
	ld [hl], $10

;> return FinishActorUpdate()
Jump_006_438b:
jr_006_438b:
	jp FinishActorUpdate


;@ def ActorPace1Step() -> (bc, de)
;@ path: field/npcs/behaviours
;@ One pixel of ActorPace1 for its phase; returns the new offset from home and the turning point.
;@ test: skip works on the actor record at hNumber
ActorPace1Step::
;> actor = mem16[hNumber]; phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> return ActorPace1Steps[mem[phase]]()
	ld a, [hl]
	rst $00

;@ path: field/npcs/behaviours
;@ Phase handlers of ActorPace1: right, left.
ActorPace1Steps::
	dw ActorPace1Right
	dw ActorPace1Left

;@ def ActorPace1Right() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 0 of ActorPace1: one pixel right, turning at +$10.
;@ test: skip works on the actor record at hNumber
ActorPace1Right::
;> return MoveActorX(1), 0x10
	ld bc, $0001
	ld de, $0010
	jp MoveActorX


;@ def ActorPace1Left() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 1 of ActorPace1: one pixel left, turning at -$10.
;@ test: skip works on the actor record at hNumber
ActorPace1Left::
;> return MoveActorX(-1), -0x10
	ld bc, $ffff
	ld de, $fff0
	jp MoveActorX


;@ def ActorPace2L()
;@ path: field/npcs/behaviours
;@ Behaviour 9: paces 2 tiles each side of its home tile, starting to the left (phase 0 left,
;@ 1 right), pausing $10 frames at each tile.
;@ test: skip works on the actor record at hNumber
ActorPace2L::
;> if wFieldTimer & 1: return AnimateActor()
	ld a, [wFieldTimer]
	and $01
	jp nz, AnimateActor

;> actor = mem16[hNumber]; timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[timer] == 0:
	ld a, [hli]
	or a
	jp nz, Jump_006_43fa

;>     dir = (mem[actor + 8] & 1) * 2 + 1     # 1 = left, 3 = right
	ld a, [hld]
	and $01
	add a
	inc a
;>     mem[actor + 6] = dir
	dec hl
	ld [hld], a
;>     if not mem[actor + 5] & 0x40 and not wScriptRunning:
	bit 6, [hl]
	jp nz, Jump_006_43fa

	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_43fa

;>         mem[actor + 5] |= 0x01             # moving
	set 0, [hl]
;>         offset, target = ActorPace2LStep()
	call ActorPace2LStep
;>         offset -= target
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
;>         if offset == 0:                    # turning point reached
	ld a, c
	or b
	jr nz, jr_006_43fa

;>             phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>             mem[phase] = (mem[phase] + 1) & 1
	ld a, [hl]
	inc a
	and $01
	ld [hli], a
;>             mem[actor + 7] = 0x10          # pause
	ld [hl], $10

;> return FinishActorUpdate()
Jump_006_43fa:
jr_006_43fa:
	jp FinishActorUpdate


;@ def ActorPace2LStep() -> (bc, de)
;@ path: field/npcs/behaviours
;@ One pixel of ActorPace2L for its phase; returns the new offset from home and the turning point.
;@ test: skip works on the actor record at hNumber
ActorPace2LStep::
;> actor = mem16[hNumber]; phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> return ActorPace2LSteps[mem[phase]]()
	ld a, [hl]
	rst $00

;@ path: field/npcs/behaviours
;@ Phase handlers of ActorPace2L: left, right.
ActorPace2LSteps::
	dw ActorPace2LLeft
	dw ActorPace2LRight

;@ def ActorPace2LLeft() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 0 of ActorPace2L: one pixel left, turning at -$20.
;@ test: skip works on the actor record at hNumber
ActorPace2LLeft::
;> return MoveActorX(-1), -0x20
	ld bc, $ffff
	ld de, $ffe0
	jp MoveActorX


;@ def ActorPace2LRight() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 1 of ActorPace2L: one pixel right, turning at +$20.
;@ test: skip works on the actor record at hNumber
ActorPace2LRight::
;> return MoveActorX(1), 0x20
	ld bc, $0001
	ld de, $0020
	jp MoveActorX


;@ def ActorSway()
;@ path: field/npcs/behaviours
;@ Behaviour 10: sways slowly (one pixel every 8 frames) 1 tile right and left of its home tile
;@ without pausing and without turning (phase 0 right, 1 left).
;@ test: skip works on the actor record at hNumber
ActorSway::
;> if wFieldTimer & 7: return AnimateActor()
	ld a, [wFieldTimer]
	and $07
	jp nz, AnimateActor

;> actor = mem16[hNumber]; timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[timer] == 0:
	ld a, [hli]
	or a
	jp nz, Jump_006_446a

;>     flags = actor + 5
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     if not mem[flags] & 0x40 and not wScriptRunning:
	bit 6, [hl]
	jp nz, Jump_006_446a

	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_446a

;>         mem[flags] |= 0x01                 # moving
	set 0, [hl]
;>         offset, target = ActorSwayStep()
	call ActorSwayStep
;>         offset -= target
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
;>         if offset == 0:                    # turning point reached
	ld a, c
	or b
	jr nz, jr_006_446a

;>             phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>             mem[phase] = (mem[phase] + 1) & 1
	ld a, [hl]
	inc a
	and $01
	ld [hld], a

;> return FinishActorUpdate()
Jump_006_446a:
jr_006_446a:
	jp FinishActorUpdate


;@ def ActorSwayStep() -> (bc, de)
;@ path: field/npcs/behaviours
;@ One pixel of ActorSway for its phase; returns the new offset from home (bc) and the turning
;@ point (de).
;@ test: skip works on the actor record at hNumber
ActorSwayStep::
;> actor = mem16[hNumber]; phase = actor + 8
	ldh a, [hNumber]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> return ActorSwaySteps[mem[phase]]()
	ld a, [hl]
	rst $00

;@ path: field/npcs/behaviours
;@ Phase handlers of ActorSway: right, left.
ActorSwaySteps::
	dw ActorSwayRight
	dw ActorSwayLeft

;@ def ActorSwayRight() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 0 of ActorSway: one pixel right, turning at +$10.
;@ test: skip works on the actor record at hNumber
ActorSwayRight::
;> return MoveActorXFree(1), 0x10
	ld bc, $0001
	ld de, $0010
	jp MoveActorXFree


;@ def ActorSwayLeft() -> (bc, de)
;@ path: field/npcs/behaviours
;@ Phase 1 of ActorSway: one pixel left, turning at -$10.
;@ test: skip works on the actor record at hNumber
ActorSwayLeft::
;> return MoveActorXFree(-1), -0x10
	ld bc, $ffff
	ld de, $fff0
	jp MoveActorXFree


;@ def MoveActorXFree(step: bc) -> bc
;@ path: field/npcs/movement
;@ Adds `step` to the actor's X (+$18) and returns its offset from the centre of its home tile
;@ (+2, pixel = tile * 16 + 8). Unlike MoveActorX it never pauses at tiles. Does nothing while a
;@ field event runs (wFieldFlags bit 0).
;@ test: skip works on the actor record at hNumber
MoveActorXFree::
;> if wFieldFlags & 0x01: return
	ld a, [wFieldFlags]
	bit 0, a
	ret nz

;> actor = mem16[hNumber]; xp = actor + 0x18
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>@x x = mem16[xp] + step; mem16[xp] = x
	ld a, [hl]
	add c
	ld c, a
	ld [hli], a
	ld a, [hl]
	adc b
;=@x
	ld [hl], a
	ld b, a
;> home = actor + 2
	ldh a, [hNumber]
	add $02
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>@h homex = mem[home] * 16 + 8
	ld a, [hl]
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
;=@h
	ld a, h
	and $0f
	ld h, a
;>@r return x - homex
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
;=@r
	ret


;@ def ActorWander()
;@ path: field/npcs/behaviours
;@ Behaviour 14: the gate floor's special character (only on its screen, wFloorNpcScreen). It
;@ walks tile by tile in a random direction inside a 7 x 5 tile area right of and below its home
;@ tile; at each new tile it checks whether it ran into Terry (CheckActorTouchesPlayer, which
;@ starts its script), then turns at random 1 time in 4; when blocked it always picks a new way.
;@ test: skip works on the actor record at hNumber
ActorWander::
;> if wMapScreen != wFloorNpcScreen: return
	ld a, [wMapScreen]
	ld b, a
	ld a, [wFloorNpcScreen]
	cp b
	ret nz

;> if wFieldFlags & 0x04: return            # scrolling
	ld a, [wFieldFlags]
	bit 2, a
	ret nz

;> if wFieldTimer & 1: return AnimateActor()
	ld a, [wFieldTimer]
	and $01
	jp nz, AnimateActor

;> actor = mem16[hNumber]; timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[timer] == 0:
	ld a, [hl]
	or a
	jp nz, Jump_006_4540

;>     flags = actor + 5
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     if not mem[flags] & 0x40 and not wScriptRunning:
	bit 6, [hl]
	jp nz, Jump_006_4540

	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_4540

;>         mem[flags] |= 0x01                 # moving
	set 0, [hl]
;>         result = ActorWanderStep()         # 0 = between tiles, 1 = next tile, 2 = blocked
	call ActorWanderStep
;>         if result == 0: return FinishActorUpdate()
	cp $00
	jr z, jr_006_4540

;>         if result == 1:
	cp $02
	jr z, jr_006_4524

;>             CheckActorTouchesPlayer()
	call CheckActorTouchesPlayer
;>             timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>             mem[timer] = 4
	ld [hl], $04
;>             if wRandomHigh & 0xC0: return FinishActorUpdate()   # 3 in 4: go on
	ld a, [wRandomHigh]
	and $c0
	jr nz, jr_006_4540

;>         timer = actor + 7
jr_006_4524:
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>         mem[timer] = 4
	ld [hl], $04
;>         dirp = actor + 6
	ldh a, [hNumber]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>         mem[dirp] = wRandomHigh & 3        # new random direction
	ld a, [wRandomHigh]
	and $03
	ld [hl], a

;> return FinishActorUpdate()
Jump_006_4540:
jr_006_4540:
	jp FinishActorUpdate


;@ def ActorWanderStep() -> a
;@ path: field/npcs/behaviours
;@ One pixel of a wandering actor in its facing; returns 0 between tiles, 1 on reaching the next
;@ tile, 2 when blocked.
;@ test: skip works on the actor record at hNumber
ActorWanderStep::
;> actor = mem16[hNumber]; dirp = actor + 6
	ldh a, [hNumber]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> return ActorWanderSteps[mem[dirp] & 3]()
	ld a, [hl]
	and $03
	rst $00

;@ path: field/npcs/behaviours
;@ Direction handlers of the wandering actors: down, left, up, right.
ActorWanderSteps::
	dw ActorWanderDown
	dw ActorWanderLeft
	dw ActorWanderUp
	dw ActorWanderRight

;@ def ActorWanderDown() -> a
;@ path: field/npcs/behaviours
;@ Wandering one pixel down (looks one tile ahead, +$10).
;@ test: skip works on the actor record at hNumber
ActorWanderDown::
;> return WanderMoveY(1, 0x10)
	ld bc, $0001
	ld de, $0010
	jp WanderMoveY


;@ def ActorWanderLeft() -> a
;@ path: field/npcs/behaviours
;@ Wandering one pixel left (looks one tile ahead, -$10).
;@ test: skip works on the actor record at hNumber
ActorWanderLeft::
;> return WanderMoveX(-1, -0x10)
	ld bc, $ffff
	ld de, $fff0
	jp WanderMoveX


;@ def ActorWanderUp() -> a
;@ path: field/npcs/behaviours
;@ Wandering one pixel up (looks one tile ahead, -$10).
;@ test: skip works on the actor record at hNumber
ActorWanderUp::
;> return WanderMoveY(-1, -0x10)
	ld bc, $ffff
	ld de, $fff0
	jp WanderMoveY


;@ def ActorWanderRight() -> a
;@ path: field/npcs/behaviours
;@ Wandering one pixel right (looks one tile ahead, +$10).
;@ test: skip works on the actor record at hNumber
ActorWanderRight::
;> return WanderMoveX(1, 0x10)
	ld bc, $0001
	ld de, $0010
	jp WanderMoveX


;@ def CheckActorTouchesPlayer()
;@ path: field/npcs/talk
;@ Starts the actor's script (StartActorScript) when Terry stands on one of the 4 tiles next to
;@ it: right, left, below or above.
;@ test: skip works on the actor record at hNumber
CheckActorTouchesPlayer::
;> actor = mem16[hNumber]; xp = actor + 0x18
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> d = 0x10; px = mem16[hPlayerX]
	ld bc, $0010
	ldh a, [hPlayerX]
	ld e, a
	ldh a, [$ff93]
	ld d, a
;> if SameTileAs(xp, d, px):                # Terry one tile right?
	call SameTileAs
	jr nz, jr_006_45ae

;>     yp = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     d = 0; py = mem16[hPlayerY]
	ld bc, $0000
	ldh a, [hPlayerY]
	ld e, a
	ldh a, [$ff96]
	ld d, a
;>     if SameTileAs(yp, d, py): return StartActorScript()
	call SameTileAs
	jp z, StartActorScript

;> xp = actor + 0x18
jr_006_45ae:
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> d = -0x10; px = mem16[hPlayerX]
	ld bc, $fff0
	ldh a, [hPlayerX]
	ld e, a
	ldh a, [$ff93]
	ld d, a
;> if SameTileAs(xp, d, px):                # Terry one tile left?
	call SameTileAs
	jr nz, jr_006_45de

;>     yp = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     d = 0; py = mem16[hPlayerY]
	ld bc, $0000
	ldh a, [hPlayerY]
	ld e, a
	ldh a, [$ff96]
	ld d, a
;>     if SameTileAs(yp, d, py): return StartActorScript()
	call SameTileAs
	jr z, jr_006_463f

;> xp = actor + 0x18
jr_006_45de:
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> d = 0; px = mem16[hPlayerX]
	ld bc, $0000
	ldh a, [hPlayerX]
	ld e, a
	ldh a, [$ff93]
	ld d, a
;> if SameTileAs(xp, d, px):                # Terry in the same column?
	call SameTileAs
	jr nz, jr_006_460e

;>     yp = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     d = 0x10; py = mem16[hPlayerY]
	ld bc, $0010
	ldh a, [hPlayerY]
	ld e, a
	ldh a, [$ff96]
	ld d, a
;>     if SameTileAs(yp, d, py): return StartActorScript()   # one tile below
	call SameTileAs
	jr z, jr_006_463f

;> xp = actor + 0x18
jr_006_460e:
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> d = 0; px = mem16[hPlayerX]
	ld bc, $0000
	ldh a, [hPlayerX]
	ld e, a
	ldh a, [$ff93]
	ld d, a
;> if SameTileAs(xp, d, px):
	call SameTileAs
	jr nz, jr_006_463e

;>     yp = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     d = -0x10; py = mem16[hPlayerY]
	ld bc, $fff0
	ldh a, [hPlayerY]
	ld e, a
	ldh a, [$ff96]
	ld d, a
;>     if SameTileAs(yp, d, py): return StartActorScript()   # one tile above
	call SameTileAs
	jr z, jr_006_463f

;> return
jr_006_463e:
	ret


;@ def StartActorScript()
;@ path: field/npcs/talk
;@ Starts the script of the current actor (its byte +4, script map $70) and marks it as talking
;@ (flags bit 6). If the script asks for a field event (wScriptRunning bit 1), the field event
;@ $FFFF is queued: wEventRoutine = $FFFF, wFieldFlags bit 0, step 0.
;@ test: skip works on the actor record at hNumber
StartActorScript::
jr_006_463f:
;> actor = mem16[hNumber]; p = actor + 4
	ldh a, [hNumber]
	add $04
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> wScriptId = mem[p]; wScriptMap = 0x70
	ld a, [hli]
	ld [wScriptId], a
	ld a, $70
	ld [wScriptMap], a
;> mem[actor + 5] |= 0x40                   # talking
	set 6, [hl]
;> wScriptRunning = 0; StartScript()
	xor a
	ld [wScriptRunning], a
	ld hl, far_StartScript
	rst $10
;> if wScriptRunning == 0: return
	ld a, [wScriptRunning]
	or a
	ret z

;> if not wScriptRunning & 0x02: return
	bit 1, a
	ret z

;> wEventRoutine = 0xFFFF
	ld hl, $ffff
	ld a, l
	ld [wEventRoutine], a
	ld a, h
	ld [$c918], a
;> wFieldFlags |= 0x01                      # field event running
	ld hl, wFieldFlags
	set 0, [hl]
;> wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [$c916], a
;> return
	ret


;@ def SameTileAs(p: hl, d: bc, coord: de) -> zero
;@ path: field/npcs/talk
;@ Zero flag set when the u16 pixel coordinate at `p` plus `d` lies on the same tile as `coord`
;@ (both rounded to the tile centre, low nibble 8).
;@ test: skip works on the actor record at hNumber
SameTileAs::
;> v = mem16[p] + d
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, bc
;> v = (v & 0xFFF0) | 8
	ld a, l
	and $f0
	or $08
	ld l, a
;> if (coord & 0xF0) | 8 != v & 0xFF: return False
	ld a, e
	and $f0
	or $08
	cp l
	ret nz

;> if coord >> 8 != v >> 8: return False
	ld a, d
	cp h
	ret nz

;> return True
	ret


;@ def ActorWanderQuiet()
;@ path: field/npcs/behaviours
;@ Behaviour 15: like ActorWander (gate floor screen only, tile by tile, random turns 1 time in 4,
;@ new way when blocked), but it never starts its script by touching Terry.
;@ test: skip works on the actor record at hNumber
ActorWanderQuiet::
;> if wMapScreen != wFloorNpcScreen: return
	ld a, [wMapScreen]
	ld b, a
	ld a, [wFloorNpcScreen]
	cp b
	ret nz

;> if wFieldFlags & 0x04: return            # scrolling
	ld a, [wFieldFlags]
	bit 2, a
	ret nz

;> if wFieldTimer & 1: return AnimateActor()
	ld a, [wFieldTimer]
	and $01
	jp nz, AnimateActor

;> actor = mem16[hNumber]; timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[timer] == 0:
	ld a, [hl]
	or a
	jp nz, Jump_006_46f1

;>     flags = actor + 5
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     if not mem[flags] & 0x40 and not wScriptRunning:
	bit 6, [hl]
	jp nz, Jump_006_46f1

	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_46f1

;>         mem[flags] |= 0x01                 # moving
	set 0, [hl]
;>         result = ActorWanderQuietStep()    # 0 = between tiles, 1 = next tile, 2 = blocked
	call ActorWanderQuietStep
;>         if result == 0: return FinishActorUpdate()
	cp $00
	jr z, jr_006_46f1

;>         if result == 1 and wRandomHigh & 0xC0: return FinishActorUpdate()
	cp $02
	jr z, jr_006_46e1

	ld a, [wRandomHigh]
	and $c0
	jr nz, jr_006_46f1

;>         dirp = actor + 6
jr_006_46e1:
	ldh a, [hNumber]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>         mem[dirp] = wRandomHigh & 3        # new random direction
	ld a, [wRandomHigh]
	and $03
	ld [hl], a

;> return FinishActorUpdate()
Jump_006_46f1:
jr_006_46f1:
	jp FinishActorUpdate


;@ def ActorWanderQuietStep() -> a
;@ path: field/npcs/behaviours
;@ One pixel of ActorWanderQuiet in its facing; returns 0 between tiles, 1 on reaching the next
;@ tile, 2 when blocked.
;@ test: skip works on the actor record at hNumber
ActorWanderQuietStep::
;> actor = mem16[hNumber]; dirp = actor + 6
	ldh a, [hNumber]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> return ActorWanderQuietSteps[mem[dirp] & 3]()
	ld a, [hl]
	and $03
	rst $00

;@ path: field/npcs/behaviours
;@ Direction handlers of ActorWanderQuiet: down, left, up, right.
ActorWanderQuietSteps::
	dw ActorWanderQuietDown
	dw ActorWanderQuietLeft
	dw ActorWanderQuietUp
	dw ActorWanderQuietRight

;@ def ActorWanderQuietDown() -> a
;@ path: field/npcs/behaviours
;@ One pixel down (looks one tile ahead, +$10).
;@ test: skip works on the actor record at hNumber
ActorWanderQuietDown::
;> return WanderMoveY(1, 0x10)
	ld bc, $0001
	ld de, $0010
	jp WanderMoveY


;@ def ActorWanderQuietLeft() -> a
;@ path: field/npcs/behaviours
;@ One pixel left (looks one tile ahead, -$10).
;@ test: skip works on the actor record at hNumber
ActorWanderQuietLeft::
;> return WanderMoveX(-1, -0x10)
	ld bc, $ffff
	ld de, $fff0
	jp WanderMoveX


;@ def ActorWanderQuietUp() -> a
;@ path: field/npcs/behaviours
;@ One pixel up (looks one tile ahead, -$10).
;@ test: skip works on the actor record at hNumber
ActorWanderQuietUp::
;> return WanderMoveY(-1, -0x10)
	ld bc, $ffff
	ld de, $fff0
	jp WanderMoveY


;@ def ActorWanderQuietRight() -> a
;@ path: field/npcs/behaviours
;@ One pixel right (looks one tile ahead, +$10).
;@ test: skip works on the actor record at hNumber
ActorWanderQuietRight::
;> return WanderMoveX(1, 0x10)
	ld bc, $0001
	ld de, $0010
	jp WanderMoveX


;@ def WanderMoveX(step: bc, ahead: de) -> a
;@ path: field/npcs/movement
;@ Moves a wandering actor one pixel along X. On a tile centre it first looks at the tile `ahead`
;@ pixels away: unless its collision class (hTestTile >> 2) is $0C-$0E (floor) the actor is
;@ snapped to its tile, waits 8 frames and 2 is returned. It is also blocked (2) when the new X
;@ would leave the 7-tile range right of the home tile. Otherwise it moves and returns 1 when it
;@ reaches a tile centre (then waits $10 frames), else 0. Does nothing during a field event.
;@ test: skip works on the actor record at hNumber
WanderMoveX::
;> if wFieldFlags & 0x01: return
	ld a, [wFieldFlags]
	bit 0, a
	ret nz

;> actor = mem16[hNumber]; xp = actor + 0x18
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[xp] & 0x0F == 8:                  # on a tile centre
	ld a, [hl]
	and $0f
	cp $08
	jr nz, jr_006_47bd

;>     t = mem16[xp] + ahead
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
;>     mem16[hTestX] = t
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
;>     yp = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     t = mem16[yp]
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>     mem16[hTestY] = t
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
;>     GetCollisionAt(); kind = hTestTile
	push bc
	call GetCollisionAt
	ldh a, [hTestTile]
	push af
;>     mem16[hTestX] = mem16[hPlayerX]
	ldh a, [hPlayerX]
	ldh [hTestX], a
	ldh a, [$ff93]
	ldh [$ffa6], a
;>     mem16[hTestY] = mem16[hPlayerY]
	ldh a, [hPlayerY]
	ldh [hTestY], a
	ldh a, [$ff96]
	ldh [$ffa8], a
;>     GetCollisionAt()                     # Terry's tile again (leaves hTest* as before)
	call GetCollisionAt
	pop af
	pop bc
;>     kind >>= 2
	srl a
	srl a
;>     if kind not in (0x0C, 0x0D, 0x0E):   # not floor: blocked
	cp $0c
	jr z, jr_006_47bd

	cp $0d
	jr z, jr_006_47bd

	cp $0e
	jr z, jr_006_47bd

;>         p = actor + 0x18
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>         mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;>         p = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>         mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;>         timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>         mem[timer] = 8
	ld [hl], $08
;>         return 2
	ld a, $02
	ret


;> p = actor + 0x18
jr_006_47bd:
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> nx = mem16[p]
	ld a, [hli]
	ld e, a
	ld d, [hl]
;> nx += step
	ld a, e
	add c
	ld e, a
	ld a, d
	adc b
	ld d, a
;> home = actor + 2
	ldh a, [hNumber]
	add $02
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>@h homex = mem[home] * 16 + 8
	ld a, [hl]
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
;=@h
	ld a, h
	and $0f
	ld h, a
;> nx -= homex
	ld a, e
	sub l
	ld e, a
	ld a, d
	sbc h
	ld d, a
;> if nx >= 0x70:                           # out of range (or left of home)
	ld a, d
	or a
	jr nz, jr_006_47f6

	ld a, e
	cp $70
	jr c, jr_006_4825

;>     p = actor + 0x18
jr_006_47f6:
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;>     p = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;>     timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     mem[timer] = 8
	ld [hl], $08
;>     return 2
	ld a, $02
	ret


;>@p xp = actor + 0x18                      # homex kept on the stack
jr_006_4825:
	push hl
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
;=@p
	ld h, a
;>@m x = mem16[xp] + step; mem16[xp] = x
	ld a, [hl]
	add c
	ld c, a
	ld [hli], a
	ld a, [hl]
	adc b
;=@m
	ld [hl], a
	ld b, a
	pop hl
;> off = x - homex
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
;> if off & 0x0F: return 0                 # between tiles
	ld a, c
	and $0f
	ld a, $00
	ret nz

;> p = actor + 0x18
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;> p = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;> timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> mem[timer] = 0x10
	ld [hl], $10
;> return 1
	ld a, $01
	ret


;@ def WanderMoveY(step: bc, ahead: de) -> a
;@ path: field/npcs/movement
;@ Like WanderMoveX, along Y: looks at the tile `ahead` pixels below/above on a tile centre, is
;@ blocked by non-floor tiles and outside 5 tiles below the home tile; returns 0 between tiles,
;@ 1 at the next tile centre, 2 when blocked.
;@ test: skip works on the actor record at hNumber
WanderMoveY::
;> if wFieldFlags & 0x01: return
	ld a, [wFieldFlags]
	bit 0, a
	ret nz

;> actor = mem16[hNumber]; yp = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[yp] & 0x0F == 8:                  # on a tile centre
	ld a, [hl]
	and $0f
	cp $08
	jr nz, jr_006_4903

;>     t = mem16[yp] + ahead
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
;>     mem16[hTestY] = t
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
;>     xp = actor + 0x18
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     t = mem16[xp]
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>     mem16[hTestX] = t
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
;>     GetCollisionAt(); kind = hTestTile
	push bc
	call GetCollisionAt
	ldh a, [hTestTile]
	push af
;>     mem16[hTestX] = mem16[hPlayerX]
	ldh a, [hPlayerX]
	ldh [hTestX], a
	ldh a, [$ff93]
	ldh [$ffa6], a
;>     mem16[hTestY] = mem16[hPlayerY]
	ldh a, [hPlayerY]
	ldh [hTestY], a
	ldh a, [$ff96]
	ldh [$ffa8], a
;>     GetCollisionAt()                     # Terry's tile again
	call GetCollisionAt
	pop af
	pop bc
;>     kind >>= 2
	srl a
	srl a
;>     if kind not in (0x0C, 0x0D, 0x0E):   # not floor: blocked
	cp $0c
	jr z, jr_006_4903

	cp $0d
	jr z, jr_006_4903

	cp $0e
	jr z, jr_006_4903

;>         p = actor + 0x18
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>         mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;>         p = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>         mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;>         timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>         mem[timer] = 8
	ld [hl], $08
;>         return 2
	ld a, $02
	ret


;> p = actor + 0x1A
jr_006_4903:
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> ny = mem16[p]
	ld a, [hli]
	ld e, a
	ld d, [hl]
;> ny += step
	ld a, e
	add c
	ld e, a
	ld a, d
	adc b
	ld d, a
;> home = actor + 3
	ldh a, [hNumber]
	add $03
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>@h homey = mem[home] * 16 + 8
	ld a, [hl]
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
;=@h
	ld a, h
	and $0f
	ld h, a
;> ny -= homey
	ld a, e
	sub l
	ld e, a
	ld a, d
	sbc h
	ld d, a
;> if ny >= 0x50:                           # out of range (or above home)
	ld a, d
	or a
	jr nz, jr_006_493c

	ld a, e
	cp $50
	jr c, jr_006_496b

;>     p = actor + 0x18
jr_006_493c:
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;>     p = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;>     timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     mem[timer] = 8
	ld [hl], $08
;>     return 2
	ld a, $02
	ret


;>@p yp = actor + 0x1A                      # homey kept on the stack
jr_006_496b:
	push hl
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
;=@p
	ld h, a
;>@m y = mem16[yp] + step; mem16[yp] = y
	ld a, [hl]
	add c
	ld c, a
	ld [hli], a
	ld a, [hl]
	adc b
;=@m
	ld [hl], a
	ld b, a
	pop hl
;> off = y - homey
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
;> if off & 0x0F: return 0                 # between tiles
	ld a, c
	and $0f
	ld a, $00
	ret nz

;> p = actor + 0x18
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;> p = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> mem[p] = (mem[p] & 0xF0) | 8
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
;> timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> mem[timer] = 0x10
	ld [hl], $10
;> return 1
	ld a, $01
	ret


;@ def MoveActorX(step: bc) -> bc
;@ path: field/npcs/movement
;@ Adds `step` to the actor's X (+$18) and returns its offset from the centre of its home tile
;@ (+2). On a tile boundary of that offset the actor waits $10 frames (timer +7). Does nothing
;@ during a field event (wFieldFlags bit 0).
;@ test: skip works on the actor record at hNumber
MoveActorX::
;> if wFieldFlags & 0x01: return
	ld a, [wFieldFlags]
	bit 0, a
	ret nz

;> actor = mem16[hNumber]; xp = actor + 0x18
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>@x x = mem16[xp] + step; mem16[xp] = x
	ld a, [hl]
	add c
	ld c, a
	ld [hli], a
	ld a, [hl]
	adc b
;=@x
	ld [hl], a
	ld b, a
;> home = actor + 2
	ldh a, [hNumber]
	add $02
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>@h homex = mem[home] * 16 + 8
	ld a, [hl]
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
;=@h
	ld a, h
	and $0f
	ld h, a
;> off = x - homex
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
;> if off & 0x0F == 0:                      # on a tile
	ld a, c
	and $0f
	jr nz, jr_006_4a00

;>     timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     mem[timer] = 0x10
	ld [hl], $10

;> return off
jr_006_4a00:
	ret


;@ def MoveActorY(step: bc) -> bc
;@ path: field/npcs/movement
;@ Like MoveActorX, along Y (+$1A) relative to the home tile row (+3).
;@ test: skip works on the actor record at hNumber
MoveActorY::
;> if wFieldFlags & 0x01: return
	ld a, [wFieldFlags]
	bit 0, a
	ret nz

;> actor = mem16[hNumber]; yp = actor + 0x1A
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>@y y = mem16[yp] + step; mem16[yp] = y
	ld a, [hl]
	add c
	ld c, a
	ld [hli], a
	ld a, [hl]
	adc b
;=@y
	ld [hl], a
	ld b, a
;> home = actor + 3
	ldh a, [hNumber]
	add $03
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>@h homey = mem[home] * 16 + 8
	ld a, [hl]
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
;=@h
	ld a, h
	and $0f
	ld h, a
;> off = y - homey
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
;> if off & 0x0F == 0:                      # on a tile
	ld a, c
	and $0f
	jr nz, jr_006_4a47

;>     timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     mem[timer] = 0x10
	ld [hl], $10

;> return off
jr_006_4a47:
	ret


;@ def FinishActorUpdate()
;@ path: field/npcs
;@ Common end of the behaviours: counts the wait timer (+7) down (and clears the moving flag
;@ while waiting), clears the talking flag when no script runs, turns a talking actor to face
;@ Terry, then sets its mirror attribute (SetActorMirror) and animates it (AnimateActor).
;@ test: skip works on the actor record at hNumber
FinishActorUpdate::
;> actor = mem16[hNumber]; timer = actor + 7
	ldh a, [hNumber]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[timer] != 0:
	ld a, [hl]
	or a
	jr z, jr_006_4a5b

;>     mem[timer] -= 1; mem[actor + 5] &= ~0x01   # waiting, not moving
	dec [hl]
	dec hl
	dec hl
	res 0, [hl]

;> if not wScriptRunning:
jr_006_4a5b:
	ld a, [wScriptRunning]
	or a
	jr nz, jr_006_4a6d

;>     flags = actor + 5
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>     mem[flags] &= ~0x40                  # talk over
	res 6, [hl]

;> flags = actor + 5
jr_006_4a6d:
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[flags] & 0x40:                    # talking: face Terry
	bit 6, [hl]
	jr z, jr_006_4a83

;>     mem[actor + 6] = (hPlayerDir + 2) & 3
	ldh a, [hPlayerDir]
	add $02
	and $03
	inc hl
	ld [hl], a

;@ def SetActorMirror()
;@ path: field/npcs
;@ Sets the actor's sprite attribute (+$17) for its facing from ActorDirAttrs (X flip when facing
;@ left), then animates it (AnimateActor).
;@ test: skip works on the actor record at hNumber
SetActorMirror::
jr_006_4a83:
;> actor = mem16[hNumber]; dirp = actor + 6
	ldh a, [hNumber]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;>@t attr = ActorDirAttrs + mem[dirp]
	ld a, [hl]
	ld de, ActorDirAttrs
	add e
	ld e, a
	ld a, $00
	adc d
;=@t
	ld d, a
;> p = actor + 0x17
	ld a, l
	add $11
	ld l, a
	ld a, h
	adc $00
	ld h, a
;> mem[p] = mem[attr]
	ld a, [de]
	ld [hl], a

;@ def AnimateActor()
;@ path: field/npcs
;@ Picks the actor's animation (ActorAnimBases by facing, +3 while moving, +6 while talking; none
;@ when flags bit 7 is set), restarts it when it changed (+$12, frame data +$13/+$14, +$10), and
;@ steps it with StepAnimation. While a field event runs an unchanged animation is not stepped.
;@ If byte +$0F is set, +$11 is zeroed during the step.
;@ test: skip works on the actor record at hNumber
AnimateActor::
;> actor = mem16[hNumber]; flags = actor + 5
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
;> if mem[flags] & 0x80: return             # no animation
	bit 7, [hl]
	ret nz

;> extra = 6
	ld b, $06
;> if not mem[flags] & 0x40:                # not talking
	bit 6, [hl]
	jr nz, jr_006_4abc

;>     extra = 3
	ld b, $03
;>     if not mem[flags] & 0x01:            # not moving
	bit 0, [hl]
	jr nz, jr_006_4abc

;>         extra = 0
	ld b, $00

;>@b base = ActorAnimBases + mem[actor + 6]
jr_006_4abc:
	inc hl
	ld a, [hl]
	ld de, ActorAnimBases
	add e
	ld e, a
	ld a, $00
;=@b
	adc d
	ld d, a
;> anim = mem[base] + extra
	ld a, [de]
	add b
	ld b, a
;>@w wPlayerAnimPtr = actor + 0x10         # animation state for StepAnimation
	ld a, l
	add $0a
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@w
	ld a, l
	ld [wPlayerAnimPtr], a
	ld a, h
	ld [$d7b5], a
;> if mem[actor + 0x12] == anim:
	inc hl
	inc hl
	ld a, [hl]
	cp b
	jr nz, jr_006_4ae8

;>     if wFieldFlags & 0x01: return
	ld a, [wFieldFlags]
	bit 0, a
	jr z, jr_006_4af7

	ret


;> else:
jr_006_4ae8:
;>     mem[actor + 0x12] = anim; mem[actor + 0x13] = 0
	ld [hl], b
	xor a
	inc hl
	ld [hli], a
;>     mem[actor + 0x14] = 0
	ld [hli], a
;>     mem[wPlayerAnimPtr] = 0
	ld a, [wPlayerAnimPtr]
	ld l, a
	ld a, [$d7b5]
	ld h, a
	ld [hl], $00

;> p = wPlayerAnimPtr
jr_006_4af7:
	ld a, [wPlayerAnimPtr]
	ld l, a
	ld a, [$d7b5]
	ld h, a
;> if mem[actor + 0x0F] == 0:
	dec hl
	ld a, [hli]
	or a
	jr nz, jr_006_4b09

;>     StepAnimation()
	ld hl, far_StepAnimation
	rst $10
;>     return
	ret


;> keep = mem[actor + 0x11]; mem[actor + 0x11] = 0
jr_006_4b09:
	inc hl
	ld a, [hl]
	push af
	push hl
	ld [hl], $00
;> StepAnimation()
	ld hl, far_StepAnimation
	rst $10
;> mem[actor + 0x11] = keep
	pop hl
	pop af
	ld [hl], a
	ret


;@ path: field/npcs
;@ Animation number per facing (down, left, up, right; left and right share one, mirrored);
;@ AnimateActor adds 3 while moving and 6 while talking.
ActorAnimBases::
	db $00, $01, $02, $01
;@ path: field/npcs
;@ Sprite attribute per facing (down, left, up, right): $20 = X flip for facing left.
ActorDirAttrs::
	db $00, $20, $00, $00

;@ def CheckActorOverlap()
;@ path: field/npcs/talk
;@ Far entry 0: clears the overlap flags (hPlayerFlags bit 5, actor +5 bit 5), then, unless a
;@ script runs, looks for actors on Terry's tile (FindActorsAround). A hit sets both flags again
;@ and stores the actor's number in wTouchedActor.
;@ test: skip works on the actor record at hNumber
CheckActorOverlap::
;> hPlayerFlags &= ~0x20
	ld hl, hPlayerFlags
	res 5, [hl]
;> actor = wActors
	ld hl, wActors

;>@w while mem[actor] != 0xFF:
jr_006_4b27:
	ld a, [hl]
	cp $ff
	jr z, jr_006_4b40

;>     p = actor + 5
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>     mem[p] &= ~0x20
	res 5, [hl]
;>     actor = p + 0x1B                     # next record
	ld a, l
	add $1b
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@w
	jr jr_006_4b27

;> if wScriptRunning: return
jr_006_4b40:
	ld a, [wScriptRunning]
	or a
	ret nz

;> p = hDivisorHigh
	ld hl, hDivisorHigh
;> mem16[p] = mem16[hPlayerX]
	ldh a, [hPlayerX]
	ld [hli], a
	ldh a, [$ff93]
	ld [hli], a
;> mem16[hFindY] = mem16[hPlayerY]
	ldh a, [hPlayerY]
	ld [hli], a
	ldh a, [$ff96]
	ld [hli], a
;> FindActorsAround()
	call FindActorsAround
;> return
	ret


;@ def FindActorsAround()
;@ path: field/npcs/talk
;@ Looks for actors on the tile at pixel (hFindX, hFindY) (hFindX is hDivisorHigh/$FFDC,
;@ hFindY $FFDD/$FFDE). When the point lies between two tiles both are checked (+8 and -8).
;@ test: skip works on the actor record at hNumber
FindActorsAround::
;> if mem[hDivisorHigh] & 0x0F != 8:              # between two columns
;>@a     mem16[hDivisorHigh] += 8
;>@b     FindActorOnTile()
;>@c     mem16[hDivisorHigh] -= 0x10
;>@d     FindActorOnTile()
;>@e     return
	ldh a, [hDivisorHigh]
	and $0f
	cp $08
	jr nz, jr_006_4b6c

;> if mem[hFindY] & 0x0F != 8:              # between two rows
;>@f     mem16[hFindY] += 8
;>@g     FindActorOnTile()
;>@h     mem16[hFindY] -= 0x10
;>@i     FindActorOnTile()
;>@j     return
	ldh a, [hFindY]
	and $0f
	cp $08
	jr nz, jr_006_4b89

;> FindActorOnTile()
	call FindActorOnTile
;> return
	ret


jr_006_4b6c:
;=@a
	ld hl, hDivisorHigh
	ld a, [hl]
	add $08
	ld [hli], a
	ld a, [hl]
	adc $00
;=@a
	ld [hl], a
;=@b
	call FindActorOnTile
;=@c
	ld hl, hDivisorHigh
	ld a, [hl]
	sub $10
	ld [hli], a
	ld a, [hl]
	sbc $00
;=@c
	ld [hl], a
;=@d
	call FindActorOnTile
;=@e
	ret


jr_006_4b89:
;=@f
	ld hl, hFindY
	ld a, [hl]
	add $08
	ld [hli], a
	ld a, [hl]
	adc $00
;=@f
	ld [hl], a
;=@g
	call FindActorOnTile
;=@h
	ld hl, hFindY
	ld a, [hl]
	sub $10
	ld [hli], a
	ld a, [hl]
	sbc $00
;=@h
	ld [hl], a
;=@i
	call FindActorOnTile
;=@j
	ret


;@ def FindActorOnTile()
;@ path: field/npcs/talk
;@ Turns (hFindX, hFindY) into tile coordinates (pixel / 16, kept in hNumber/hNumber+1) and runs
;@ CheckActorOnTile for every visible actor except those with sprite byte +1 = $4D.
;@ test: skip works on the actor record at hNumber
FindActorOnTile::
;> x = mem16[hDivisorHigh]
	ldh a, [hDivisorHigh]
	ld l, a
	ldh a, [$ffdc]
	ld h, a
;>@n hNumber = (x >> 4) & 0xFF
	swap h
	swap l
	ld a, h
	and $f0
	ld h, a
	ld a, l
;=@n
	and $0f
	or h
	ldh [hNumber], a
;> y = mem16[hFindY]
	ldh a, [hFindY]
	ld l, a
	ldh a, [$ffde]
	ld h, a
;>@m mem[hNumber + 1] = (y >> 4) & 0xFF
	swap h
	swap l
	ld a, h
	and $f0
	ld h, a
	ld a, l
;=@m
	and $0f
	or h
	ldh [$ffd6], a
;> index = 0; actor = wActors
	ld d, $00
	ld hl, wActors

;>@w while mem[actor] != 0xFF:
jr_006_4bd3:
	ld a, [hl]
	cp $ff
	ret z

;>     if not mem[actor] & 0x40:            # visible
	bit 6, a
	jr nz, jr_006_4be4

;>         if mem[actor + 1] != 0x4D:
	inc hl
	ld a, [hld]
	cp $4d
	jr z, jr_006_4be4

;>             CheckActorOnTile(actor, index)
	call CheckActorOnTile

;>     actor += 0x20
jr_006_4be4:
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>     index += 1
	inc d
;=@w
	jr jr_006_4bd3

; a stray, unreachable ret byte
	db $c9

;@ def CheckActorOnTile(actor: hl, index: d)
;@ path: field/npcs/talk
;@ When the actor (or, between tiles, either tile it covers) stands on the tile in
;@ hNumber/hNumber+1, sets hPlayerFlags bit 5 and the actor's +5 bit 5 and stores `index` in
;@ wTouchedActor.
;@ test: skip works on the actor record at hNumber
CheckActorOnTile::
;>@p p = actor + 0x18
	push hl
	push bc
	push de
	ld a, l
	add $18
	ld l, a
;=@p
	ld a, h
	adc $00
	ld h, a
;> x = mem16[p]
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
;> y = mem16[p + 2]
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> if x & 0x0F == 8:
	ld a, e
	and $0f
	cp $08
	jr nz, jr_006_4c17

;>     if y & 0x0F == 8:
	ld a, l
	and $0f
	cp $08
	jr nz, jr_006_4c37

;>         if not TileMatchesFind(x, y): return
	call TileMatchesFind
	jr nz, jr_006_4c6e

;>     else:                                # between two rows
;>@b         if not TileMatchesFind(x, y + 8) and not TileMatchesFind(x, y - 8): return
	jr jr_006_4c55

;> else:                                    # between two columns
jr_006_4c17:
;>@a     if not TileMatchesFind(x + 8, y) and not TileMatchesFind(x - 8, y): return
	push hl
	push de
	ld a, e
	add $08
	ld e, a
	ld a, d
;=@a
	adc $00
	ld d, a
	call TileMatchesFind
	pop de
	pop hl
	jr z, jr_006_4c55

;=@a
	ld a, e
	add $f8
	ld e, a
	ld a, d
	adc $ff
	ld d, a
;=@a
	call TileMatchesFind
	jr nz, jr_006_4c6e

	jr jr_006_4c55

jr_006_4c37:
;=@b
	push hl
	push de
	ld a, l
	add $08
	ld l, a
	ld a, h
;=@b
	adc $00
	ld h, a
	call TileMatchesFind
	pop de
	pop hl
	jr z, jr_006_4c55

;=@b
	ld a, l
	add $f8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;=@b
	call TileMatchesFind
	jr nz, jr_006_4c6e

;> hPlayerFlags |= 0x20                      # Terry overlaps an actor
jr_006_4c55:
	ld hl, hPlayerFlags
	set 5, [hl]
;> wTouchedActor = index
	pop de
	ld a, d
	ld [wTouchedActor], a
;>@q p = actor + 5
	pop bc
	pop hl
	push hl
	ld a, l
	add $05
	ld l, a
;=@q
	ld a, h
	adc $00
	ld h, a
;> mem[p] |= 0x20
	set 5, [hl]
	pop hl
	ret


;> return
jr_006_4c6e:
	pop de
	pop bc
	pop hl
	ret


;@ def TileMatchesFind(x: de, y: hl) -> zero
;@ path: field/npcs/talk
;@ Zero flag set when pixel (x, y) lies on the tile (hNumber, hNumber+1).
;@ test: skip works on the actor record at hNumber
TileMatchesFind::
;>@t tx = (x >> 4) & 0xFF
	swap d
	swap e
	ld a, d
	and $f0
	ld d, a
	ld a, e
;=@t
	and $0f
	or d
	ld b, a
;> if tx != mem[hNumber]: return False
	ldh a, [hNumber]
	cp b
	ret nz

;>@u ty = (y >> 4) & 0xFF
	swap h
	swap l
	ld a, h
	and $f0
	ld h, a
	ld a, l
;=@u
	and $0f
	or h
	ld c, a
;> return ty == mem[hNumber + 1]
	ldh a, [$ffd6]
	cp c
	ret


;@ path: unused
;@ Unreachable code (no caller), kept as bytes: takes the entry of Terry's trail ($C973, 49
;@ records of 4 bytes) that lies b steps behind wTrailPos and unpacks its position into
;@ hFindX/hFindY ($FFDB-$FFDE) - probably a leftover for finding where a follower stands.
UnusedCode_06_4C94::
	db $fa, $37, $ca, $90, $30, $02, $c6, $31, $6f, $26, $00, $29, $29, $7d, $c6, $73
	db $6f, $7c, $ce, $c9, $67, $2a, $e0, $db, $2a, $e0, $dd, $7e, $cb, $37, $e6, $0f
	db $e0, $dc, $7e, $e6, $0f, $e0, $de, $c9

;@ def DrawFieldActors()
;@ path: field/npcs/draw
;@ Far entry 1: draws the sprites of all visible actors (DrawActorSpriteEntry), unless a menu
;@ overlay is up, the field is busy (wFieldFlags bits 1, 3, 7), script menu $0F is open, or the
;@ screen scroll is at step 1 (outside gate floors).
;@ test: skip works on the actor record at hNumber
DrawFieldActors::
;> if wMenuOverlay: return
	ld a, [wMenuOverlay]
	or a
	ret nz

;> flags = wFieldFlags
;> if flags & 0x02: return
	ld a, [wFieldFlags]
	bit 1, a
	ret nz

;> if flags & 0x08: return
	bit 3, a
	ret nz

;> if flags & 0x80: return
	bit 7, a
	ret nz

;> if flags & 0x10 and wScriptMenu == 0x0F: return
	bit 4, a
	jr z, jr_006_4cd7

	ld a, [wScriptMenu]
	cp $0f
	ret z

;> if wFieldFlags & 0x04 and not wOnGateFloor:   # scrolling
jr_006_4cd7:
	ld a, [wFieldFlags]
	bit 2, a
	jr z, jr_006_4cea

	ld a, [wOnGateFloor]
	or a
	jr nz, jr_006_4cea

;>     if wScrollStep == 1: return
	ld a, [wScrollStep]
	cp $01
	ret z

;> actor = wActors
jr_006_4cea:
	ld de, wActors

;>@w while mem[actor] != 0xFF:
jr_006_4ced:
	ld a, [de]
	cp $ff
	ret z

;>     if not mem[actor] & 0x40:            # visible
	bit 6, a
	jr nz, jr_006_4cff

;>         if mem[actor + 1] != 0xFF:
	inc de
	ld a, [de]
	dec de
	cp $ff
;>             DrawActorSpriteEntry(actor)
	push de
	call nz, DrawActorSpriteEntry
	pop de

;>     actor += 0x20
jr_006_4cff:
	ld a, e
	add $20
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@w
	jr jr_006_4ced

; a stray, unreachable ret byte
	db $c9

;@ def DrawActorSpriteEntry(actor: de)
;@ path: field/npcs/draw
;@ Fills the 8-byte sprite request at hSpriteX for one actor - X (+$18), Y + 8 (+$1A), then
;@ bytes +$11, +$14 (the frame; $FF = draw nothing), +$16 and the attribute +$17 - and draws it:
;@ with far_DrawCharacterSprite when byte +$0F is 0, else with DrawActorSprite (bank 4).
;@ test: skip works on the actor record at hNumber
DrawActorSpriteEntry::
;>@p p = actor + 0x18
	push bc
	push de
	ld a, e
	add $18
	ld e, a
	ld a, d
;=@p
	adc $00
	ld d, a
;> req = hSpriteX
	ld hl, hSpriteX
;> mem16[req] = mem16[p]; req += 2         # X
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
;>@y mem16[req] = mem16[p + 2] + 8; req += 2   # Y
	inc de
	ld a, [de]
	inc de
	add $08
	ld [hli], a
	ld a, [de]
;=@y
	inc de
	adc $00
	ld [hli], a
;>@q p = actor + 0x11
	pop de
	ld a, e
	add $11
	ld e, a
	ld a, d
	adc $00
;=@q
	ld d, a
;> mem[req] = mem[p]; req += 1
	ld a, [de]
	ld [hli], a
;> frame = mem[actor + 0x14]
	inc de
	inc de
	inc de
	ld a, [de]
;> if frame != 0xFF:
	cp $ff
	jr z, jr_006_4d58

;>     mem[req] = frame; mem[req + 1] = mem[actor + 0x16]
	ld [hli], a
	inc de
	inc de
	ld a, [de]
	ld [hli], a
;>     mem[req + 2] = mem[actor + 0x17]
	inc de
	ld a, [de]
	ld [hli], a
;>     p = actor + 0x0F
	ld a, e
	add $f8
	ld e, a
	ld a, d
	adc $ff
	ld d, a
;>     if mem[p] == 0:
	ld a, [de]
	or a
	jr nz, jr_006_4d54

;>         DrawCharacterSprite()
	ld hl, far_DrawCharacterSprite
	rst $10
;>     else:
	jr jr_006_4d58

;>         DrawActorSprite()
jr_006_4d54:
	ld hl, far_DrawActorSprite
	rst $10

;> return
jr_006_4d58:
	pop bc
	ret


;@ def LoadFieldActorGfx()
;@ path: field/npcs/draw
;@ Far entry 4: decompresses the sprite graphics of the (up to 6) entries of wActorGfxSlots into
;@ VRAM, one $100-byte slot each, from $8000 + $500 (towns), $8200 (map $45) or $8700 (gate
;@ floors). An entry is (graphics number, source): source 0 takes the graphics id from the
;@ bank-0 list at $2ADF, anything else from ActorGfxIds. Numbers $15 and $55 from the bank-0
;@ list take two slots. On map $08 the slot address becomes $0800 + slot * $100 (the map id is
;@ used as the address byte), which looks like a bug.
;@ test: skip works on the actor record at hNumber
LoadFieldActorGfx::
;> slot = wActorGfxSlots; n = 6
	ld hl, wActorGfxSlots
	ld b, $06
;> vslot = 0
	ld c, $00

;>@w while n:                               # counted down at the end of each pass
jr_006_4d61:
;>     if mem[slot] == 0xFF: return
	ld a, [hl]
	cp $ff
	ret z

;>     num = mem[slot]
	push hl
	push bc
	ld b, a
;>     if mem[slot + 1] == 0:
	inc hl
	ld a, [hl]
	or a
	jr nz, jr_006_4d7a

;>@k         ptr = 0x2ADF + 2 * num         # bank-0 list
	ld hl, $2adf
	ld a, b
	add a
	add l
	ld l, a
	ld a, $00
;=@k
	adc h
	ld h, a
;>     else:
	jr jr_006_4d86

;>@m         ptr = ActorGfxIds + 2 * num
jr_006_4d7a:
	ld l, b
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(ActorGfxIds)
	ld l, a
;=@m
	ld a, h
	adc HIGH(ActorGfxIds)
	ld h, a

;>     gfx = mem16[ptr]
jr_006_4d86:
	ld e, [hl]
	inc hl
	ld d, [hl]
;>     dest = 0x80 + vslot
	ld a, c
	add $80
	ld h, a
;>     if wOnGateFloor:
	ld a, [wOnGateFloor]
	or a
	jr z, jr_006_4d99

;>         dest += 7
	ld a, h
	add $07
	ld h, a
;>     elif wMapId == 0x08: dest = wMapId   # (bug?)
	jr jr_006_4dae

jr_006_4d99:
	ld a, [wMapId]
	cp $08
	jr z, jr_006_4dae

;>     elif wMapId == 0x45:
	cp $45
	jr nz, jr_006_4daa

;>         dest += 2
	ld a, h
	add $02
	ld h, a
;>     else:
	jr jr_006_4dae

;>         dest += 5
jr_006_4daa:
	ld a, h
	add $05
	ld h, a

;>     DecompressVRAM(gfx, dest << 8)
jr_006_4dae:
	ld h, a
	ld l, $00
	call DecompressVRAM
;>@d     if num in (0x55, 0x15) and mem[slot + 1] == 0:   # two-slot sprite
	pop bc
	pop hl
	ld a, [hl]
	cp $55
	jr z, jr_006_4dbf

;=@d
	cp $15
	jr nz, jr_006_4dc5

;=@d
jr_006_4dbf:
	inc hl
	ld a, [hld]
	or a
	jr nz, jr_006_4dc5

;>         vslot += 1
	inc c

;>     slot += 2; vslot += 1
jr_006_4dc5:
	inc hl
	inc hl
	inc c
;>     n -= 1
	dec b
;=@w
	jr nz, jr_006_4d61

;> return
	ret

;@ path: field/npcs/draw
;@ Graphics ids (u16, passed to DecompressVRAM) of the actor sprites with a non-zero source in
;@ wActorGfxSlots, indexed by graphics number (231 entries).
ActorGfxIds::
	db $00, $2f, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31
	db $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31
	db $01, $2f, $02, $2f, $03, $2f, $04, $2f, $05, $2f, $06, $2f, $07, $2f, $08, $2f
	db $09, $2f, $0a, $2f, $0b, $2f, $0c, $2f, $0d, $2f, $0e, $2f, $0f, $2f, $10, $2f
	db $00, $38, $01, $38, $02, $38, $03, $38, $04, $38, $05, $38, $06, $38, $07, $38
	db $08, $38, $09, $38, $0a, $38, $0b, $38, $0c, $38, $0d, $38, $0e, $38, $0f, $38
	db $10, $38, $11, $38, $12, $38, $13, $38, $14, $38, $15, $38, $16, $38, $17, $38
	db $18, $38, $19, $38, $1a, $38, $1b, $38, $1c, $38, $1d, $38, $1e, $38, $1f, $38
	db $20, $38, $21, $38, $22, $38, $23, $38, $24, $38, $25, $38, $26, $38, $27, $38
	db $28, $38, $29, $38, $2a, $38, $2b, $38, $2c, $38, $2d, $38, $2e, $38, $2f, $38
	db $30, $38, $31, $38, $32, $38, $33, $38, $34, $38, $35, $38, $36, $38, $37, $38
	db $38, $38, $39, $38, $3a, $38, $3b, $38, $3c, $38, $3d, $38, $3e, $38, $3f, $38
	db $40, $38, $41, $38, $42, $38, $43, $38, $44, $38, $45, $38, $46, $38, $47, $38
	db $00, $39, $01, $39, $02, $39, $03, $39, $04, $39, $05, $39, $06, $39, $07, $39
	db $08, $39, $09, $39, $0a, $39, $0b, $39, $0c, $39, $0d, $39, $0e, $39, $0f, $39
	db $10, $39, $11, $39, $12, $39, $13, $39, $14, $39, $15, $39, $16, $39, $17, $39
	db $18, $39, $19, $39, $1a, $39, $1b, $39, $1c, $39, $1d, $39, $1e, $39, $1f, $39
	db $20, $39, $21, $39, $22, $39, $23, $39, $24, $39, $25, $39, $26, $39, $27, $39
	db $28, $39, $29, $39, $2a, $39, $2b, $39, $2c, $39, $2d, $39, $2e, $39, $2f, $39
	db $30, $39, $31, $39, $32, $39, $33, $39, $34, $39, $35, $39, $36, $39, $37, $39
	db $38, $39, $39, $39, $3a, $39, $3b, $39, $3c, $39, $3d, $39, $3e, $39, $3f, $39
	db $40, $39, $41, $39, $42, $39, $43, $39, $44, $39, $45, $39, $46, $39, $47, $39
	db $00, $3a, $01, $3a, $02, $3a, $03, $3a, $04, $3a, $05, $3a, $06, $3a, $07, $3a
	db $08, $3a, $09, $3a, $0a, $3a, $0b, $3a, $0c, $3a, $0d, $3a, $0e, $3a, $0f, $3a
	db $10, $3a, $11, $3a, $12, $3a, $13, $3a, $14, $3a, $15, $3a, $16, $3a, $17, $3a
	db $18, $3a, $19, $3a, $1a, $3a, $1b, $3a, $1c, $3a, $1d, $3a, $1e, $3a, $1f, $3a
	db $20, $3a, $21, $3a, $22, $3a, $23, $3a, $24, $3a, $25, $3a, $26, $3a, $27, $3a
	db $28, $3a, $29, $3a, $2a, $3a, $2b, $3a, $2c, $3a, $2d, $3a, $2e, $3a, $2f, $3a
	db $30, $3a, $31, $3a, $32, $3a, $33, $3a, $34, $3a, $35, $3a, $36, $3a

;@ def FindLearnableSkill()
;@ path: monster/skills
;@ Far entry 5: finds the next skill the current party monster (wCurPartyMember) learns now.
;@ It walks SkillTable (218 skills) and skips skills already in the wSceneObjects scratch list,
;@ skills whose level (minus 1) or stat requirements the monster does not meet, and then takes
;@ the first skill that is either on its own list wMonSkillList (which is crossed out, $FF) or
;@ whose prerequisite skills it all knows. Result in hNumber+2 ($FFD8) = skill and hNumber+3 =
;@ how: 0 own list, 1 grown from the one skill in hNumber+4, 2 from several skills;
;@ both $FF when there is none.
;@ test: skip reads the party monster records
FindLearnableSkill::
;> lvl = MonsterField(wCurPartyMember, wMonLevel)   # address of its level field
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld e, l
	ld d, h
;> rec = SkillTable
	ld hl, SkillTable
;>@f for skill in range(0xDA):              # rec = SkillTable + 0x12 * skill
	ld c, $00

Jump_006_4faa:
;=@f
	push de
	push hl
	push bc
;>     if SkillAlreadyListed(skill): continue
	push de
	call SkillAlreadyListed
	pop de
	jp z, Jump_006_507c

;>     if mem[lvl] + 1 < mem[rec]: continue           # level
	ld a, [de]
	inc a
	cp [hl]
	jp c, Jump_006_507c

;>     p = lvl + 7                                    # wMonMaxHP
	ld a, e
	add $07
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@b     if mem16[p] < mem16[rec + 1]: continue
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
;=@b
	sbc [hl]
	jp c, Jump_006_507c

;>     p = lvl + 0x0B                                 # wMonMaxMP
	ld a, e
	add $03
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@c     if mem16[p] < mem16[rec + 3]: continue
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
;=@c
	sbc [hl]
	jp c, Jump_006_507c

;>     p = lvl + 0x0D                                 # wMonAttack
	ld a, e
	add $01
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@d     if mem16[p] < mem16[rec + 5]: continue
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
;=@d
	sbc [hl]
	jp c, Jump_006_507c

;>     p = lvl + 0x0F                                 # wMonDefense
	ld a, e
	add $01
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@e     if mem16[p] < mem16[rec + 7]: continue
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
;=@e
	sbc [hl]
	jr c, jr_006_507c

;>     p = lvl + 0x11                                 # wMonAgility
	ld a, e
	add $01
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@g     if mem16[p] < mem16[rec + 9]: continue
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
;=@g
	sbc [hl]
	jr c, jr_006_507c

;>     p = lvl + 0x13                                 # wMonIntelligence
	ld a, e
	add $01
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@h     if mem16[p] < mem16[rec + 0x0B]: continue
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
;=@h
	sbc [hl]
	jr c, jr_006_507c

;>     own = lvl - 0x1A                               # wMonSkillList
	ld a, e
	add $d2
	ld e, a
	ld a, d
	adc $ff
	ld d, a
;>@l     for pos in range(own, own + 25):
	pop bc
	push bc
	push de
	ld b, $19

;>         if mem[pos] == skill:
;>@j             mem[pos] = 0xFF                # crossed off its list
;>@k             mem[hNumber + 2] = skill; mem[hNumber + 3] = 0
;>@r             return
jr_006_5031:
	ld a, [de]
	cp c
	jr z, jr_006_5097

;=@l
	inc de
	dec b
	jr nz, jr_006_5031

;>@m     known = own - 8                      # wMonSkills
	pop de
	ld a, e
	add $f8
	ld e, a
	ld a, d
	adc $ff
;=@m
	ld d, a
;>     pre = rec + 0x0D                     # prerequisite skills
	inc hl
;>     if mem[pre] == 0xFF: continue        # none: not learnable this way
	ld a, [hl]
	cp $ff
	jr z, jr_006_507c

;>     if not SkillPrereqKnown(pre, known): continue    # pre += 1
	call SkillPrereqKnown
	jr nz, jr_006_507c

;>     if mem[pre] == 0xFF:                 # a single prerequisite
;>@n         mem[hNumber + 4] = mem[pre - 1]
;>@o         mem[hNumber + 2] = skill; mem[hNumber + 3] = 1
;>@p         return
	ld a, [hl]
	cp $ff
	jp z, Jump_006_50a6

;>     if not SkillPrereqKnown(pre, known): continue
	call SkillPrereqKnown
	jr nz, jr_006_507c

;>     if mem[pre] == 0xFF: break
	ld a, [hl]
	cp $ff
	jp z, Jump_006_50b5

;>     if not SkillPrereqKnown(pre, known): continue
	call SkillPrereqKnown
	jr nz, jr_006_507c

;>     if mem[pre] == 0xFF: break
	ld a, [hl]
	cp $ff
	jp z, Jump_006_50b5

;>     if not SkillPrereqKnown(pre, known): continue
	call SkillPrereqKnown
	jr nz, jr_006_507c

;>     if mem[pre] == 0xFF: break
	ld a, [hl]
	cp $ff
	jp z, Jump_006_50b5

;>     if not SkillPrereqKnown(pre, known): continue
	call SkillPrereqKnown
	jr nz, jr_006_507c

;>     break
	jp Jump_006_50b5


Jump_006_507c:
jr_006_507c:
;=@f
	pop bc
	pop hl
	pop de
	ld a, l
	add $12
	ld l, a
;=@f
	ld a, h
	adc $00
	ld h, a
	inc c
	ld a, c
	cp $da
;=@f
	jp nz, Jump_006_4faa

;> else:
;>     mem[hNumber + 2] = 0xFF; mem[hNumber + 3] = 0xFF   # nothing to learn
	ld a, $ff
	ldh [$ffd8], a
	ld a, $ff
	ldh [$ffd9], a
;>     return
	ret


jr_006_5097:
;=@j
	ld a, $ff
	ld [de], a
;=@k
	pop de
	pop bc
	pop hl
	pop de
	ld a, c
	ldh [$ffd8], a
;=@k
	ld a, $00
	ldh [$ffd9], a
;=@r
	ret


Jump_006_50a6:
;=@n
	dec hl
	ld a, [hl]
	ldh [$ffda], a
;=@o
	pop bc
	pop hl
	pop de
	ld a, c
	ldh [$ffd8], a
	ld a, $01
;=@o
	ldh [$ffd9], a
;=@p
	ret


;>@z mem[hNumber + 2] = skill; mem[hNumber + 3] = 2   # from several skills
Jump_006_50b5:
	pop bc
	pop hl
	pop de
	ld a, c
	ldh [$ffd8], a
	ld a, $02
;=@z
	ldh [$ffd9], a
;> return
	ret


;@ def SkillPrereqKnown(pre: hl, known: de) -> zero
;@ path: monster/skills
;@ Zero flag set when the monster knows skill mem[pre] (MonKnowsSkill); `pre` moves on by one.
;@ test: skip reads the party monster records
SkillPrereqKnown::
;> r = MonKnowsSkill(pre, known)
	push de
	call MonKnowsSkill
	pop de
;> pre += 1
	inc hl
;> return r
	ret


;@ def MonKnowsSkill(pre: hl, known: de) -> zero
;@ path: monster/skills
;@ Zero flag set when skill mem[pre] is one of the 8 skills at `known`.
;@ test: skip reads the party monster records
MonKnowsSkill::
;>@i for i in range(8):
	ld b, $08

;>     if mem[known + i] == mem[pre]: return True
jr_006_50c9:
	ld a, [de]
	cp [hl]
	ret z

;=@i
	inc de
	dec b
	jr nz, jr_006_50c9

;> return False
	inc b
	ret


;@ def SkillAlreadyListed(skill: c) -> zero
;@ path: monster/skills
;@ Zero flag set when `skill` is among the 40 bytes of the scratch list at wSceneObjects (skills
;@ already handled during this level-up).
;@ test: skip reads the party monster records
SkillAlreadyListed::
;>@i for i in range(0x28):
	ld de, wSceneObjects
	ld b, $28

;>     if wSceneObjects[i] == skill: return True
jr_006_50d7:
	ld a, [de]
	cp c
	ret z

;=@i
	inc de
	dec b
	jr nz, jr_006_50d7

;> return False
	inc b
	ret

;@ path: monster/skills
;@ The 218 skills ($00-$D9), $12 bytes each: level needed (the monster learns it from one level
;@ before), then the minimum max HP, max MP, attack, defense, agility and intelligence (u16
;@ each), then up to 5 prerequisite skills ($FF = none / end). A skill with prerequisites can be
;@ learned by any monster that knows all of them; one without is learned only from the
;@ monster's own list (wMonSkillList). One record per line.
SkillTable::
	db $01, $00, $00, $07, $00, $00, $00, $00, $00, $00, $00, $14, $00, $ff, $ff, $ff, $ff, $ff  ; $00
	db $0d, $00, $00, $2e, $00, $00, $00, $00, $00, $00, $00, $40, $00, $00, $ff, $ff, $ff, $ff  ; $01
	db $1c, $00, $00, $70, $00, $00, $00, $00, $00, $00, $00, $92, $00, $01, $ff, $ff, $ff, $ff  ; $02
	db $03, $00, $00, $0b, $00, $00, $00, $00, $00, $00, $00, $17, $00, $ff, $ff, $ff, $ff, $ff  ; $03
	db $0a, $00, $00, $22, $00, $00, $00, $00, $00, $00, $00, $34, $00, $03, $ff, $ff, $ff, $ff  ; $04
	db $1a, $00, $00, $60, $00, $00, $00, $00, $00, $00, $00, $7a, $00, $04, $ff, $ff, $ff, $ff  ; $05
	db $04, $00, $00, $0d, $00, $00, $00, $00, $00, $00, $00, $1a, $00, $ff, $ff, $ff, $ff, $ff  ; $06
	db $0e, $00, $00, $32, $00, $00, $00, $00, $00, $00, $00, $44, $00, $06, $ff, $ff, $ff, $ff  ; $07
	db $1d, $00, $00, $78, $00, $00, $00, $00, $00, $00, $00, $9e, $00, $07, $ff, $ff, $ff, $ff  ; $08
	db $02, $00, $00, $0a, $00, $00, $00, $00, $00, $00, $00, $15, $00, $ff, $ff, $ff, $ff, $ff  ; $09
	db $0b, $00, $00, $26, $00, $00, $00, $00, $00, $00, $00, $38, $00, $09, $ff, $ff, $ff, $ff  ; $0A
	db $1b, $00, $00, $68, $00, $00, $00, $00, $00, $00, $00, $86, $00, $0a, $ff, $ff, $ff, $ff  ; $0B
	db $05, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $1e, $00, $ff, $ff, $ff, $ff, $ff  ; $0C
	db $0c, $00, $00, $2a, $00, $00, $00, $00, $00, $00, $00, $3c, $00, $0c, $ff, $ff, $ff, $ff  ; $0D
	db $19, $00, $00, $58, $00, $00, $00, $00, $00, $00, $00, $6e, $00, $0d, $ff, $ff, $ff, $ff  ; $0E
	db $06, $00, $00, $14, $00, $00, $00, $00, $00, $00, $00, $23, $00, $ff, $ff, $ff, $ff, $ff  ; $0F
	db $0f, $00, $00, $36, $00, $00, $00, $00, $00, $00, $00, $48, $00, $0f, $ff, $ff, $ff, $ff  ; $10
	db $1e, $00, $00, $80, $00, $00, $00, $00, $00, $00, $00, $aa, $00, $10, $ff, $ff, $ff, $ff  ; $11
	db $10, $00, $00, $3a, $00, $00, $00, $00, $00, $00, $00, $4c, $00, $ff, $ff, $ff, $ff, $ff  ; $12
	db $18, $00, $00, $50, $00, $00, $00, $00, $00, $00, $00, $62, $00, $12, $ff, $ff, $ff, $ff  ; $13
	db $01, $00, $00, $07, $00, $00, $00, $00, $00, $00, $00, $06, $00, $ff, $ff, $ff, $ff, $ff  ; $14
	db $04, $00, $00, $18, $00, $00, $00, $00, $00, $00, $00, $10, $00, $ff, $ff, $ff, $ff, $ff  ; $15
	db $0b, $00, $00, $34, $00, $00, $00, $00, $00, $00, $00, $2e, $00, $15, $ff, $ff, $ff, $ff  ; $16
	db $09, $00, $00, $2c, $00, $00, $00, $00, $00, $00, $00, $26, $00, $ff, $ff, $ff, $ff, $ff  ; $17
	db $0a, $00, $00, $2f, $00, $00, $00, $00, $00, $00, $00, $29, $00, $ff, $ff, $ff, $ff, $ff  ; $18
	db $0c, $00, $00, $38, $00, $00, $00, $00, $00, $00, $00, $31, $00, $ff, $ff, $ff, $ff, $ff  ; $19
	db $07, $00, $00, $20, $00, $00, $00, $00, $00, $00, $00, $1c, $00, $ff, $ff, $ff, $ff, $ff  ; $1A
	db $0d, $00, $00, $3a, $00, $00, $00, $00, $00, $00, $00, $34, $00, $1a, $ff, $ff, $ff, $ff  ; $1B
	db $04, $00, $00, $12, $00, $00, $00, $00, $00, $00, $00, $0f, $00, $ff, $ff, $ff, $ff, $ff  ; $1C
	db $08, $00, $00, $24, $00, $00, $00, $00, $00, $00, $00, $20, $00, $1c, $ff, $ff, $ff, $ff  ; $1D
	db $02, $00, $00, $0e, $00, $00, $00, $00, $00, $00, $00, $0c, $00, $ff, $ff, $ff, $ff, $ff  ; $1E
	db $06, $00, $00, $1b, $00, $00, $00, $00, $00, $00, $00, $18, $00, $1e, $ff, $ff, $ff, $ff  ; $1F
	db $03, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $0e, $00, $ff, $ff, $ff, $ff, $ff  ; $20
	db $07, $00, $00, $20, $00, $00, $00, $00, $00, $00, $00, $1c, $00, $20, $ff, $ff, $ff, $ff  ; $21
	db $01, $00, $00, $0a, $00, $00, $00, $00, $00, $00, $00, $08, $00, $ff, $ff, $ff, $ff, $ff  ; $22
	db $05, $00, $00, $18, $00, $00, $00, $00, $00, $00, $00, $14, $00, $22, $ff, $ff, $ff, $ff  ; $23
	db $12, $00, $00, $4c, $00, $00, $00, $00, $00, $00, $00, $46, $00, $ff, $ff, $ff, $ff, $ff  ; $24
	db $11, $00, $00, $48, $00, $00, $00, $00, $00, $00, $00, $42, $00, $ff, $ff, $ff, $ff, $ff  ; $25
	db $13, $00, $00, $50, $00, $00, $00, $00, $00, $00, $00, $4a, $00, $ff, $ff, $ff, $ff, $ff  ; $26
	db $10, $00, $00, $44, $00, $00, $00, $00, $00, $00, $00, $3e, $00, $ff, $ff, $ff, $ff, $ff  ; $27
	db $14, $00, $00, $54, $00, $00, $00, $00, $00, $00, $00, $4e, $00, $27, $ff, $ff, $ff, $ff  ; $28
	db $15, $00, $00, $5c, $00, $00, $00, $00, $00, $00, $00, $58, $00, $ff, $ff, $ff, $ff, $ff  ; $29
	db $0f, $00, $00, $3e, $00, $00, $00, $00, $00, $00, $00, $3a, $00, $ff, $ff, $ff, $ff, $ff  ; $2A
	db $01, $00, $00, $07, $00, $00, $00, $00, $00, $00, $00, $06, $00, $ff, $ff, $ff, $ff, $ff  ; $2B
	db $0a, $00, $00, $34, $00, $00, $00, $00, $00, $00, $00, $30, $00, $2b, $ff, $ff, $ff, $ff  ; $2C
	db $10, $00, $00, $52, $00, $00, $00, $00, $00, $00, $00, $50, $00, $2c, $ff, $ff, $ff, $ff  ; $2D
	db $14, $00, $00, $8c, $00, $00, $00, $00, $00, $00, $00, $78, $00, $ff, $ff, $ff, $ff, $ff  ; $2E
	db $1c, $00, $00, $c4, $00, $00, $00, $00, $00, $00, $00, $a0, $00, $2e, $ff, $ff, $ff, $ff  ; $2F
	db $0e, $00, $00, $3f, $00, $00, $00, $00, $00, $00, $00, $36, $00, $ff, $ff, $ff, $ff, $ff  ; $30
	db $1b, $00, $00, $ae, $00, $00, $00, $00, $00, $00, $00, $98, $00, $30, $ff, $ff, $ff, $ff  ; $31
	db $20, $00, $00, $bc, $00, $00, $00, $00, $00, $00, $00, $b0, $00, $14, $31, $ff, $ff, $ff  ; $32
	db $05, $00, $00, $15, $00, $00, $00, $00, $00, $00, $00, $14, $00, $ff, $ff, $ff, $ff, $ff  ; $33
	db $08, $00, $00, $1e, $00, $00, $00, $00, $00, $00, $00, $1a, $00, $ff, $ff, $ff, $ff, $ff  ; $34
	db $06, $00, $00, $18, $00, $00, $00, $00, $00, $00, $00, $16, $00, $ff, $ff, $ff, $ff, $ff  ; $35
	db $07, $00, $00, $1b, $00, $00, $00, $00, $00, $00, $00, $18, $00, $ff, $ff, $ff, $ff, $ff  ; $36
	db $0a, $00, $00, $28, $00, $00, $00, $00, $00, $00, $00, $22, $00, $ff, $ff, $ff, $ff, $ff  ; $37
	db $0a, $00, $00, $28, $00, $00, $00, $00, $00, $00, $00, $22, $00, $ff, $ff, $ff, $ff, $ff  ; $38
	db $28, $00, $00, $e0, $00, $00, $00, $00, $00, $00, $00, $ec, $00, $ff, $ff, $ff, $ff, $ff  ; $39
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $3A
	db $08, $50, $00, $00, $00, $50, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $3B
	db $0c, $46, $00, $00, $00, $00, $00, $00, $00, $46, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $3C
	db $0e, $62, $00, $00, $00, $54, $00, $54, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $3D
	db $12, $7e, $00, $00, $00, $6c, $00, $6c, $00, $00, $00, $00, $00, $3c, $41, $ff, $ff, $ff  ; $3E
	db $0c, $54, $00, $00, $00, $48, $00, $00, $00, $48, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $3F
	db $0f, $6a, $00, $00, $00, $5a, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $40
	db $0e, $62, $00, $00, $00, $00, $00, $54, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $41
	db $14, $8c, $00, $00, $00, $78, $00, $00, $00, $78, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $42
	db $11, $77, $00, $00, $00, $00, $00, $66, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $43
	db $0b, $4d, $00, $22, $00, $42, $00, $00, $00, $00, $00, $2a, $00, $41, $01, $ff, $ff, $ff  ; $44
	db $0b, $4d, $00, $22, $00, $42, $00, $00, $00, $00, $00, $2a, $00, $41, $5a, $ff, $ff, $ff  ; $45
	db $0b, $4d, $00, $22, $00, $42, $00, $00, $00, $00, $00, $2a, $00, $41, $58, $ff, $ff, $ff  ; $46
	db $0b, $4d, $00, $22, $00, $42, $00, $00, $00, $00, $00, $2a, $00, $41, $0d, $ff, $ff, $ff  ; $47
	db $0c, $44, $00, $00, $00, $48, $00, $00, $00, $3e, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $48
	db $0c, $44, $00, $00, $00, $48, $00, $00, $00, $3e, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $49
	db $0c, $3e, $00, $00, $00, $44, $00, $00, $00, $48, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $4A
	db $0c, $3e, $00, $00, $00, $44, $00, $00, $00, $48, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $4B
	db $0c, $40, $00, $00, $00, $3a, $00, $00, $00, $3e, $00, $30, $00, $ff, $ff, $ff, $ff, $ff  ; $4C
	db $0c, $40, $00, $00, $00, $3a, $00, $00, $00, $3e, $00, $30, $00, $ff, $ff, $ff, $ff, $ff  ; $4D
	db $0c, $44, $00, $00, $00, $48, $00, $00, $00, $3e, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $4E
	db $1c, $9a, $00, $8c, $00, $a8, $00, $00, $00, $a8, $00, $94, $00, $4d, $59, $ff, $ff, $ff  ; $4F
	db $13, $62, $00, $00, $00, $58, $00, $00, $00, $70, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $50
	db $18, $7c, $00, $00, $00, $70, $00, $00, $00, $88, $00, $00, $00, $50, $ff, $ff, $ff, $ff  ; $51
	db $11, $54, $00, $2a, $00, $00, $00, $00, $00, $44, $00, $36, $00, $ff, $ff, $ff, $ff, $ff  ; $52
	db $17, $80, $00, $40, $00, $00, $00, $00, $00, $52, $00, $4a, $00, $52, $ff, $ff, $ff, $ff  ; $53
	db $12, $7e, $00, $00, $00, $00, $00, $6c, $00, $6c, $00, $6c, $00, $41, $43, $93, $ff, $ff  ; $54
	db $0c, $48, $00, $00, $00, $44, $00, $00, $00, $52, $00, $00, $00, $23, $41, $ff, $ff, $ff  ; $55
	db $0c, $48, $00, $00, $00, $52, $00, $44, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $56
	db $0f, $5c, $00, $00, $00, $5a, $00, $00, $00, $60, $00, $00, $00, $50, $55, $ff, $ff, $ff  ; $57
	db $0d, $4a, $00, $00, $00, $3c, $00, $00, $00, $54, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $58
	db $13, $70, $00, $00, $00, $72, $00, $00, $00, $84, $00, $00, $00, $58, $ff, $ff, $ff, $ff  ; $59
	db $0a, $41, $00, $00, $00, $5a, $00, $00, $00, $34, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $5A
	db $10, $7c, $00, $00, $00, $66, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $5B
	db $03, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $5C
	db $0a, $46, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5c, $ff, $ff, $ff, $ff  ; $5D
	db $14, $8c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5d, $ff, $ff, $ff, $ff  ; $5E
	db $1e, $d2, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5e, $ff, $ff, $ff, $ff  ; $5F
	db $03, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $60
	db $0a, $46, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $60, $ff, $ff, $ff, $ff  ; $61
	db $14, $8c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $61, $ff, $ff, $ff, $ff  ; $62
	db $1e, $d2, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $62, $ff, $ff, $ff, $ff  ; $63
	db $22, $b8, $00, $b8, $00, $00, $00, $00, $00, $00, $00, $c4, $00, $11, $5a, $ff, $ff, $ff  ; $64
	db $24, $c4, $00, $c4, $00, $00, $00, $00, $00, $00, $00, $d0, $00, $08, $5f, $63, $ff, $ff  ; $65
	db $26, $00, $00, $d2, $00, $00, $00, $00, $00, $00, $00, $e0, $00, $02, $05, $08, $0b, $0e  ; $66
	db $05, $23, $00, $00, $00, $1e, $00, $00, $00, $00, $00, $1e, $00, $ff, $ff, $ff, $ff, $ff  ; $67
	db $07, $31, $00, $00, $00, $2a, $00, $00, $00, $00, $00, $2a, $00, $ff, $ff, $ff, $ff, $ff  ; $68
	db $09, $3f, $00, $00, $00, $36, $00, $00, $00, $00, $00, $36, $00, $67, $68, $ff, $ff, $ff  ; $69
	db $0a, $46, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3c, $00, $ff, $ff, $ff, $ff, $ff  ; $6A
	db $10, $70, $00, $00, $00, $00, $00, $00, $00, $00, $00, $60, $00, $6a, $6d, $ff, $ff, $ff  ; $6B
	db $09, $3f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $36, $00, $ff, $ff, $ff, $ff, $ff  ; $6C
	db $0e, $62, $00, $00, $00, $00, $00, $00, $00, $00, $00, $54, $00, $6c, $ff, $ff, $ff, $ff  ; $6D
	db $0d, $4a, $00, $00, $00, $00, $00, $00, $00, $4e, $00, $4e, $00, $ff, $ff, $ff, $ff, $ff  ; $6E
	db $0f, $00, $00, $41, $00, $00, $00, $00, $00, $52, $00, $52, $00, $ff, $ff, $ff, $ff, $ff  ; $6F
	db $0a, $00, $00, $00, $00, $3c, $00, $00, $00, $3c, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $70
	db $14, $8c, $00, $48, $00, $00, $00, $00, $00, $78, $00, $78, $00, $6f, $78, $ff, $ff, $ff  ; $71
	db $0a, $46, $00, $00, $00, $00, $00, $00, $00, $46, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $72
	db $0c, $00, $00, $2a, $00, $00, $00, $00, $00, $48, $00, $48, $00, $ff, $ff, $ff, $ff, $ff  ; $73
	db $0e, $00, $00, $41, $00, $00, $00, $00, $00, $54, $00, $54, $00, $6f, $73, $ff, $ff, $ff  ; $74
	db $0a, $36, $00, $1b, $00, $00, $00, $00, $00, $3f, $00, $31, $00, $ff, $ff, $ff, $ff, $ff  ; $75
	db $0c, $44, $00, $27, $00, $00, $00, $00, $00, $55, $00, $3d, $00, $75, $ff, $ff, $ff, $ff  ; $76
	db $09, $3f, $00, $00, $00, $00, $00, $00, $00, $36, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $77
	db $0e, $54, $00, $00, $00, $00, $00, $00, $00, $62, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $78
	db $07, $37, $00, $00, $00, $00, $00, $00, $00, $43, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $79
	db $0d, $51, $00, $00, $00, $00, $00, $00, $00, $5e, $00, $00, $00, $79, $ff, $ff, $ff, $ff  ; $7A
	db $06, $20, $00, $00, $00, $1f, $00, $00, $00, $30, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $7B
	db $0c, $42, $00, $00, $00, $3f, $00, $00, $00, $4d, $00, $00, $00, $7b, $ff, $ff, $ff, $ff  ; $7C
	db $0e, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $7D
	db $04, $00, $00, $1c, $00, $00, $00, $00, $00, $00, $00, $18, $00, $ff, $ff, $ff, $ff, $ff  ; $7E
	db $15, $93, $00, $93, $00, $7e, $00, $7e, $00, $7e, $00, $7e, $00, $29, $54, $ff, $ff, $ff  ; $7F
	db $14, $00, $00, $64, $00, $00, $00, $00, $00, $00, $00, $8c, $00, $81, $82, $ff, $ff, $ff  ; $80
	db $17, $00, $00, $82, $00, $00, $00, $00, $00, $00, $00, $aa, $00, $33, $34, $35, $36, $ff  ; $81
	db $15, $00, $00, $6e, $00, $00, $00, $00, $00, $00, $00, $96, $00, $18, $1d, $21, $ff, $ff  ; $82
	db $16, $00, $00, $78, $00, $00, $00, $00, $00, $00, $00, $a0, $00, $ff, $ff, $ff, $ff, $ff  ; $83
	db $14, $00, $00, $46, $00, $00, $00, $00, $00, $00, $00, $5a, $00, $ff, $ff, $ff, $ff, $ff  ; $84
	db $19, $00, $00, $64, $00, $00, $00, $00, $00, $00, $00, $78, $00, $84, $ff, $ff, $ff, $ff  ; $85
	db $1e, $00, $00, $82, $00, $00, $00, $00, $00, $00, $00, $96, $00, $85, $ff, $ff, $ff, $ff  ; $86
	db $23, $00, $00, $a0, $00, $00, $00, $00, $00, $00, $00, $b4, $00, $86, $ff, $ff, $ff, $ff  ; $87
	db $05, $23, $00, $00, $00, $00, $00, $1e, $00, $1e, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $88
	db $0c, $54, $00, $00, $00, $00, $00, $48, $00, $48, $00, $00, $00, $88, $ff, $ff, $ff, $ff  ; $89
	db $0b, $4b, $00, $00, $00, $00, $00, $54, $00, $46, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $8A
	db $13, $8c, $00, $00, $00, $00, $00, $7e, $00, $8c, $00, $00, $00, $8a, $ff, $ff, $ff, $ff  ; $8B
	db $12, $7e, $00, $00, $00, $6c, $00, $6c, $00, $6c, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $8C
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $8D
	db $0e, $62, $00, $00, $00, $00, $00, $54, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $8E
	db $0d, $5b, $00, $00, $00, $00, $00, $4e, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $8F
	db $0e, $62, $00, $00, $00, $54, $00, $54, $00, $54, $00, $00, $00, $3b, $8e, $ff, $ff, $ff  ; $90
	db $10, $64, $00, $00, $00, $00, $00, $00, $00, $78, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $91
	db $11, $78, $00, $00, $00, $64, $00, $00, $00, $8c, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $92
	db $1a, $b6, $00, $00, $00, $00, $00, $9c, $00, $00, $00, $9c, $00, $89, $8e, $ff, $ff, $ff  ; $93
	db $12, $72, $00, $00, $00, $00, $00, $00, $00, $82, $00, $60, $00, $2d, $77, $ff, $ff, $ff  ; $94
	db $1b, $c6, $00, $5e, $00, $00, $00, $00, $00, $91, $00, $a2, $00, $31, $7d, $ff, $ff, $ff  ; $95
	db $1e, $d2, $00, $00, $00, $00, $00, $00, $00, $b4, $00, $b4, $00, $14, $94, $ff, $ff, $ff  ; $96
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $97
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $98
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $99
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $9A
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $9B
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $9C
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $9D
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $9E
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $9F
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $A0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $A1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $A2
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $A3
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $A4
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $A5
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $A6
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $A7
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $A8
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $A9
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $AA
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $AB
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $AC
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $AD
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $AE
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $AF
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $B0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $B1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $B2
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $B3
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $B4
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $B5
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $B6
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $B7
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $B8
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $B9
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $BA
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $BB
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $BC
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $BD
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $BE
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $BF
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $C0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $C1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $C2
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $C3
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $C4
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $C5
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $C6
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $C7
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $C8
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $C9
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $CA
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $CB
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $CC
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $CD
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $CE
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $CF
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $D0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $D1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $D2
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $D3
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $D4
	db $1c, $00, $00, $7c, $00, $00, $00, $00, $00, $00, $00, $a0, $00, $ff, $ff, $ff, $ff, $ff  ; $D5
	db $0c, $3e, $00, $00, $00, $44, $00, $00, $00, $48, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $D6
	db $0c, $44, $00, $00, $00, $48, $00, $00, $00, $3e, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $D7
	db $0c, $44, $00, $00, $00, $3e, $00, $00, $00, $48, $00, $00, $00, $ff, $ff, $ff, $ff, $ff  ; $D8
	db $21, $e7, $00, $a4, $00, $c6, $00, $00, $00, $c6, $00, $c6, $00, $44, $45, $46, $47, $ff  ; $D9

;@ def FieldInput()
;@ path: field/input
;@ Far entry 6, once per field frame: hands the frame to whatever runs (transition, pause menu,
;@ script menu, field event, field menu, gate map, battle wipe, screen scroll); otherwise, when
;@ Terry is free, reads the buttons: Start switches the status bar, Select opens the map (gate
;@ floors and some maps), A talks to whoever stands in front (or on a gate floor touches the floor
;@ object there), and A with nothing to talk to opens the field menu.
;@ test: skip dispatches to the field handlers
FieldInput::
;> if wMapLoadState: return
	ld a, [wMapLoadState]
	or a
	ret nz

;> flags = wFieldFlags
;> if flags & 0x20: return RunFieldTransition()
	ld a, [wFieldFlags]
	bit 5, a
	jp nz, RunFieldTransition

;> if flags & 0x80: return RunNameEntry()
	bit 7, a
	jp nz, RunNameEntry

;> if flags & 0x10: return RunScriptMenu()
	bit 4, a
	jp nz, RunScriptMenu

;> if flags & 0x01: return RunFieldEvent()
	bit 0, a
	jp nz, RunFieldEvent

;> if flags & 0x02:
	bit 1, a
	jr z, jr_006_6059

;>     return FieldMenu()
	ld hl, far_FieldMenu
	rst $10
	ret


;> if flags & 0x08:
jr_006_6059:
	bit 3, a
	jr z, jr_006_6062

;>     return RunGateMap()
	ld hl, far_RunGateMap
	rst $10
	ret


;> if flags & 0x40:
jr_006_6062:
	bit 6, a
	jr z, jr_006_606b

;>     return RunBattleWipe()
	ld hl, far_RunBattleWipe
	rst $10
	ret


;> if flags & 0x04: return ScrollToNextScreen()
jr_006_606b:
	bit 2, a
	jp nz, ScrollToNextScreen

;> if mem[0xD9E8]: return
	ld a, [wFieldInputBlock]
	or a
	jp nz, Jump_006_6284

;> if wScriptRunning: return
	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_6284

;> if wPlayerPause: return
	ld a, [wPlayerPause]
	or a
	jp nz, Jump_006_6284

;> if hPlayerFlags & 0x01: return           # Terry is moving
	ldh a, [hPlayerFlags]
	bit 0, a
	jp nz, Jump_006_6284

;> if not wFieldPaused:
	ld a, [wFieldPaused]
	or a
	jp nz, Jump_006_611d

;>     if not wFadeState and wJoyPressed & 0x08:   # Start: switch the status bar
	ld a, [wFadeState]
	or a
	jp nz, Jump_006_60b8

	ld a, [wJoyPressed]
	and $08
	jr z, jr_006_60b8

;>         mode = wPartyCount               # 0 when the party is empty
	ld a, [wPartyCount]
	or a
	jr z, jr_006_60ac

;>         if mode: mode = wStatusBarMode ^ 1
	ld a, [wStatusBarMode]
	xor $01

;>         wStatusBarMode = mode
jr_006_60ac:
	ld [wStatusBarMode], a
;>         BuildStatusBar(); DrawStatusBar()
	call BuildStatusBar
	call DrawStatusBar
;>         return
	jp Jump_006_6284


;>     if not wFadeState and wJoyPressed & 0x04:   # Select
Jump_006_60b8:
jr_006_60b8:
	ld a, [wFadeState]
	or a
	jp nz, Jump_006_611d

	ld a, [wJoyPressed]
	and $04
	jr z, jr_006_611d

;>@g         if wOnGateFloor or wMapId in (0x61, 0x62, 0x63, 0x64) or 0x50 <= wMapId < 0x5D:
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_006_60e7

	ld a, [wMapId]
	cp $61
	jr z, jr_006_60e7

;=@g
	cp $62
	jr z, jr_006_60e7

	cp $63
	jr z, jr_006_60e7

	cp $64
	jr z, jr_006_60e7

;=@g
	cp $50
	jr c, jr_006_611d

	cp $5d
	jr nc, jr_006_611d

;>             wFieldFlags |= 0x08          # open the map
jr_006_60e7:
	ld hl, wFieldFlags
	set 3, [hl]
;>             wMenuStep = 0; wMenuSubStep = 0
	xor a
	ld [wMenuStep], a
	ld [wMenuSubStep], a
;>             wItemsHandedIn = 0; wHatchSlot = 0
	xor a
	ld [wItemsHandedIn], a
	ld [wHatchSlot], a
;>@s             mem16[0xFFBF] = mem16[hScrollX]   # keep the scroll
	ldh a, [hScrollX]
	ld l, a
	ldh a, [$ffb8]
	ld h, a
	ld a, l
	ldh [$ffbf], a
;=@s
	ld a, h
	ldh [$ffc0], a
;>@t             mem16[0xFFC1] = mem16[hScrollY]
	ldh a, [hScrollY]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	ld a, l
	ldh [$ffc1], a
;=@t
	ld a, h
	ldh [$ffc2], a
;>             DrawPartyBarWindow()
	call DrawPartyBarWindow
;>             QueueSound(0x59)
	ld a, $59
	call QueueSound
;>             return
	jp Jump_006_6284


;>@h if not wScriptRunning and not wFadeState and wJoyPressed & 0x01:   # A
Jump_006_611d:
jr_006_611d:
	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_6247

	ld a, [wFadeState]
	or a
	jp nz, Jump_006_6247

;=@h
	ld a, [wJoyPressed]
	and $01
	jp z, Jump_006_6247

;>@x     mem16[hDivisorHigh] = mem16[hPlayerX]      # hDivisorHigh = hDivisorHigh
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	ldh [hDivisorHigh], a
;=@x
	ld a, h
	ldh [$ffdc], a
;>@y     mem16[hFindY] = mem16[hPlayerY]
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	ldh [hFindY], a
;=@y
	ld a, h
	ldh [$ffde], a
;>     FindObjectAtPosition()                        # FindObjectAtPosition -> hNumber, hNumber + 1
	ld hl, $0b04
	rst $10
;>     if hNumber == 0xFF:                  # nobody on Terry's tile: look in front
	ldh a, [hNumber]
	cp $ff
	jr nz, jr_006_618e

;>@o         off = FacingOffsets + 4 * hPlayerDir
	ld hl, FacingOffsets
	ldh a, [hPlayerDir]
	add a
	add a
	add l
	ld l, a
;=@o
	ld a, $00
	adc h
	ld h, a
;>@k         dx = mem16[off]; dy = mem16[off + 2]
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld e, [hl]
	inc hl
;=@k
	ld d, [hl]
;>         t = mem16[hPlayerX] + dx
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	add hl, bc
;>         mem16[hDivisorHigh] = t
	ld a, l
	ldh [hDivisorHigh], a
	ld a, h
	ldh [$ffdc], a
;>         t = mem16[hPlayerY] + dy
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	add hl, de
;>         mem16[hFindY] = t
	ld a, l
	ldh [hFindY], a
	ld a, h
	ldh [$ffde], a
;>         FindObjectAtPosition()
	ld hl, $0b04
	rst $10
;>     if hNumber != 0xFF:                  # somebody to talk to
	ldh a, [hNumber]
	cp $ff
	jp z, Jump_006_61e9

;>         wScriptId = hNumber; wScriptMap = wMapId
jr_006_618e:
	ld [wScriptId], a
	ld a, [wMapId]
	ld [wScriptMap], a
;>         if wOnGateFloor: wScriptMap = 0x70
	ld a, [wOnGateFloor]
	or a
	jr z, jr_006_61a2

	ld a, $70
	ld [wScriptMap], a

;>         if mem[hNumber + 1] != 0xFF:     # an actor
jr_006_61a2:
	ldh a, [$ffd6]
	cp $ff
	jr z, jr_006_61b7

;>@q             p = wActors + 5 + 0x20 * mem[hNumber + 1]
	ld c, $20
	call Multiply
	ld a, l
	add $d7
	ld l, a
	ld a, h
;=@q
	adc $d7
	ld h, a
;>             mem[p] |= 0x40               # talking
	set 6, [hl]

;>         wScriptFlags &= ~0x03
jr_006_61b7:
	ld hl, wScriptFlags
	res 0, [hl]
	res 1, [hl]
;>         wScriptRunning = 0; StartScript()
	xor a
	ld [wScriptRunning], a
	ld hl, far_StartScript
	rst $10
;>         if wScriptRunning & 0x02:        # the script wants a field event
	ld a, [wScriptRunning]
	or a
	jp z, Jump_006_61e9

	bit 1, a
	jp z, Jump_006_61e9

;>             wEventRoutine = 0xFFFF
	ld hl, $ffff
	ld a, l
	ld [wEventRoutine], a
	ld a, h
	ld [$c918], a
;>             wFieldFlags |= 0x01
	ld hl, wFieldFlags
	set 0, [hl]
;>             wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [$c916], a

;>     if wOnGateFloor:                     # touch the floor object in front
Jump_006_61e9:
	ld a, [wOnGateFloor]
	or a
	jp z, Jump_006_6247

;>@p         off = FacingOffsets + 4 * hPlayerDir
	ld hl, FacingOffsets
	ldh a, [hPlayerDir]
	add a
	add a
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
;>@m         dx = mem16[off]; dy = mem16[off + 2]
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld e, [hl]
	inc hl
;=@m
	ld d, [hl]
;>         t = mem16[hPlayerX] + dx
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	add hl, bc
;>         mem16[hDivisorHigh] = t
	ld a, l
	ldh [hDivisorHigh], a
	ld a, h
	ldh [$ffdc], a
;>         t = mem16[hPlayerY] + dy
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	add hl, de
;>         mem16[hFindY] = t
	ld a, l
	ldh [hFindY], a
	ld a, h
	ldh [$ffde], a
;>@u         mem[hDivisorHigh] = (mem16[hDivisorHigh] >> 4) & 0xFF    # pixel -> tile
	ldh a, [hDivisorHigh]
	swap a
	and $0f
	ld b, a
	ldh a, [$ffdc]
	swap a
;=@u
	and $f0
	or b
	ldh [hDivisorHigh], a
;>@v         mem[hFindY] = (mem16[hFindY] >> 4) & 0xFF
	ldh a, [hFindY]
	swap a
	and $0f
	ld b, a
	ldh a, [$ffde]
	swap a
;=@v
	and $f0
	or b
	ldh [hFindY], a
;>         wFloorObjectItem = 1
	ld a, $01
	ld [wFloorObjectItem], a
;>         TouchFloorObject()
	ld hl, far_TouchFloorObject
	rst $10

;>@a if not wScriptRunning and not wFieldFlags and not wFadeState:
Jump_006_6247:
	ld a, [wScriptRunning]
	or a
	jp nz, Jump_006_6284

	ld a, [wFieldFlags]
	or a
	jp nz, Jump_006_6284

;=@a
	ld a, [wFadeState]
	or a
	jp nz, Jump_006_6284

;>     if wJoyPressed & 0x01 and wPartyCount:   # A in the open: field menu
	ld a, [wJoyPressed]
	and $01
	jr z, jr_006_6284

	ld a, [wPartyCount]
	or a
	jr z, jr_006_6284

;>         wFieldFlags |= 0x02
	ld hl, wFieldFlags
	set 1, [hl]
;>         wFieldMenuState = 0; wFieldMenuStep = 0
	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
;>         wMenuCount = 0; mem[0xC910] = 0
	xor a
	ld [wMenuCount], a
	ld [$c910], a
;>         QueueSound(0x59)
	ld a, $59
	call QueueSound
;>         return
	jp Jump_006_6284


;> return
Jump_006_6284:
jr_006_6284:
	ret


;@ path: field/input
;@ Pixel offset (dx, dy as signed u16) of the tile in front of Terry, per facing: down, left, up,
;@ right.
FacingOffsets::
	db $00, $00, $10, $00, $f0, $ff, $00, $00, $00, $00, $f0, $ff, $10, $00, $00, $00

;@ def RunNameEntry()
;@ path: field/input
;@ wFieldFlags bit 7: runs one frame of the name entry screen (bank 9), with the menu state
;@ bytes swapped out around it (SwapMenuState).
;@ test: skip dispatches to the field handlers
RunNameEntry::
;> SwapMenuState()
	call SwapMenuState
;> NameEntryMenu()
	ld hl, far_NameEntryMenu
	rst $10
;> SwapMenuState()
	call SwapMenuState
;> return
	ret


;@ def SwapMenuState()
;@ path: field/input
;@ Swaps the 8 menu state bytes from wMenuStep with the 8 bytes at $C876.
;@ test: skip dispatches to the field handlers
SwapMenuState::
;> p = wMenuStep; q = 0xC876
	ld hl, wMenuStep
	ld de, wBattlerSexBits67
;>@i for i in range(8):
	ld b, $08

;>     mem[p + i], mem[q + i] = mem[q + i], mem[p + i]
jr_006_62a8:
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
;=@i
	dec b
	jr nz, jr_006_62a8

;> return
	ret


;@ def RunScriptMenu()
;@ path: field/input
;@ wFieldFlags bit 4: runs one frame of the script menu in wScriptMenu (bank 9's dispatcher).
;@ test: skip dispatches to the field handlers
RunScriptMenu::
;> far_call(0x09, 0x00)                            # ScriptMenuTable9[wScriptMenu]
	ld hl, $0900
	rst $10
	ret


;@ def DrawPartyBarWindow()
;@ path: field/partybar
;@ Shows the window at line $80 and copies the two rows of the party bar (wPartyBarTiles, 20 of
;@ each 32-tile row) to the window map $9C00.
;@ test: skip writes VRAM
DrawPartyBarWindow::
;> hWY = 0x80
	ld a, $80
	ldh [hWY], a
;> dest = 0x9C00; src = wPartyBarTiles
	ld hl, $9c00
	ld de, wPartyBarTiles
;>@o for row in range(2):
	ld c, $02

;>@r     for col in range(20):
jr_006_62c3:
	ld b, $14
	push hl

;>         WriteVRAM(dest, mem[src])
jr_006_62c6:
	ld a, [de]
	call WriteVRAM
;>@c         dest = (dest & ~0x1F) | ((dest + 1) & 0x1F)   # wraps in the row
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@c
	ld l, a
	pop af
	or l
	ld l, a
;>         src += 1
	inc de
;=@r
	dec b
	jr nz, jr_006_62c6

;>@q     src += 12                            # to the next 32-tile row
	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
;=@q
	ld d, a
;>@s     dest = (dest & 0xFC00) | ((dest + 0x20) & 0x3FF)   # next row, wrapping in the map
	push bc
	ld bc, $0020
	ld a, h
	add hl, bc
	and $fc
	ld b, a
;=@s
	ld a, h
	and $03
	or b
	ld h, a
	pop bc
;=@o
	dec c
	jr nz, jr_006_62c3

;> return
	ret


;@ def ScrollToNextScreen()
;@ path: field/scrolling
;@ wFieldFlags bit 2: one frame of the scroll to the neighbouring map screen in wScrollDir.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollToNextScreen::
;> return ScrollDirections[wScrollDir]()
	ld a, [wScrollDir]
	rst $00

;@ path: field/scrolling
;@ Scroll handlers by wScrollDir: left, right, up, down.
ScrollDirections::
	dw ScrollLeft
	dw ScrollRight
	dw ScrollUp
	dw ScrollDown

;@ def ScrollLeft()
;@ path: field/scrolling
;@ Scroll to the screen on the left, step wScrollStep of ScrollLeftSteps.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollLeft::
;> return ScrollLeftSteps[wScrollStep]()
	ld a, [wScrollStep]
	rst $00

;@ path: field/scrolling
;@ Steps of the scroll to the left: start, load the screen's objects, run its map script,
;@ column by column, finish.
ScrollLeftSteps::
	dw ScrollLeftStart
	dw ScrollLoadScreen
	dw ScrollRunMapScript
	dw ScrollLeftColumn
	dw ScrollFinish

;@ def ScrollLeftStart()
;@ path: field/scrolling
;@ Step 0 of the scroll left: wMapScreen -= 1, shows the party bar in the window, builds the new
;@ screen in the buffers (bank $0B entry 3) and starts at column $13.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollLeftStart::
;> wMapScreen -= 1
	ld a, [wMapScreen]
	dec a
	ld [wMapScreen], a
;> ShowPartyBarWindow()
	call ShowPartyBarWindow
;> RedrawScreenBuffer()                            # RedrawScreenBuffer
	ld hl, $0b03
	rst $10
;> wScrollColumn = 0x13
	ld a, $13
	ld [wScrollColumn], a
;> wScrollStep += 1
	ld hl, wScrollStep
	inc [hl]
	ret


;@ def ScrollLeftColumn()
;@ path: field/scrolling
;@ Step 3 of the scroll left, every frame: queues column wScrollColumn of the new screen
;@ (16 tiles from wTilemapBuffer and their attributes from wScreenMap) for the BG map column just
;@ left of the view, scrolls 8 pixels left and counts the column down; after column 0 the next
;@ step follows.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollLeftColumn::
;>@a row = (hScrollY & 0xF8) * 4
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
;=@a
	sla l
	rla
;> dest = 0x9800 + row
	ld h, $98
	add h
	ld h, a
;>@b dest += ((hScrollX >> 3) - 1) & 0x1F
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	dec a
	and $1f
;=@b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> wMapUpdateDest = dest
	ld a, l
	ld [wMapUpdateDest], a
	ld a, h
	ld [$c741], a
;>@d src = wTilemapBuffer + wScrollColumn
	ld a, [wScrollColumn]
	ld de, wTilemapBuffer
	add e
	ld e, a
	ld a, $00
	adc d
;=@d
	ld d, a
;> wMapUpdateDir = 1                       # a column
	ld a, $01
	ld [wMapUpdateDir], a
;> wMapUpdateLen = 0x10
	ld a, $10
	ld [wMapUpdateLen], a
;> out = wMapUpdateTiles
	ld hl, wMapUpdateTiles
;>@i for i in range(16):
	ld b, $10

;>     mem[out] = mem[src]; out += 1
jr_006_6369:
	ld a, [de]
	ld [hli], a
;>     src += 0x20
	ld a, e
	add $20
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@i
	dec b
	jr nz, jr_006_6369

;> col = wScrollColumn >> 1; odd = wScrollColumn & 1
	ld a, [wScrollColumn]
	srl a
;>@m src = wScreenMap + col
	push af
	ld de, wScreenMap
	add e
	ld e, a
	ld a, $00
	adc d
;=@m
	ld d, a
	pop af
;> out = wMapUpdateTiles + 0x10              # the attributes
	ld b, $10
	ld hl, $c754
;> if not odd:
	jr c, jr_006_63a0

;>@j     for i in range(16):
;>         mem[out] = mem[src] >> 4; out += 1   # left half of the metatile
jr_006_638d:
	ld a, [de]
	swap a
	and $0f
	ld [hli], a
;>         src += 0x10
	ld a, e
	add $10
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@j
	dec b
	jr nz, jr_006_638d

;> else:
	jr jr_006_63af

;>@k     for i in range(16):
;>         mem[out] = mem[src] & 0x0F; out += 1
jr_006_63a0:
	ld a, [de]
	and $0f
	ld [hli], a
;>         src += 0x10
	ld a, e
	add $10
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@k
	dec b
	jr nz, jr_006_63a0

;> wMapUpdateOn = 1
jr_006_63af:
	ld a, $01
	ld [wMapUpdateOn], a
;>@x t = mem16[hScrollX] - 8
	ldh a, [hScrollX]
	ld l, a
	ldh a, [$ffb8]
	ld h, a
	ld a, l
	add $f8
;=@x
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;> mem16[hScrollX] = t
	ld a, l
	ldh [hScrollX], a
	ld a, h
	ldh [$ffb8], a
;> wScrollColumn -= 1
	ld a, [wScrollColumn]
	dec a
	ld [wScrollColumn], a
;> if wScrollColumn != 0xFF: return
	cp $ff
	ret nz

;> wScrollStep += 1
	ld hl, wScrollStep
	inc [hl]
	ret


;@ def ScrollFinish()
;@ path: field/scrolling
;@ Last step of every screen scroll: saves the new background (wTilemapBuffer to wSavedTilemap),
;@ ends the scroll (wFieldFlags bit 2), puts the party bar back on the BG map, fills all 49
;@ entries of Terry's trail ($C973, X, Y, high nibbles, frame | attribute) with his position,
;@ checks the tile under him for conveyors and clears $D9E8.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollFinish::
;> dst = wSavedTilemap; src = wTilemapBuffer
	ld hl, wSavedTilemap
	ld de, wTilemapBuffer
;>@i for i in range(0x200):
	ld bc, $0200

;>     mem[dst + i] = mem[src + i]
jr_006_63e0:
	ld a, [de]
	ld [hli], a
	inc de
;=@i
	dec bc
	ld a, b
	or c
	jr nz, jr_006_63e0

;> wFieldFlags &= ~0x04
	ld hl, wFieldFlags
	res 2, [hl]
;> RestorePartyBarRows()
	call RestorePartyBarRows
;>@n for n in range(0x31):
	ld b, $31

;>@e     e = 0xC973 + 4 * wTrailPos
jr_006_63f2:
	ld a, [wTrailPos]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld a, l
;=@e
	add $73
	ld l, a
	ld a, h
	adc $c9
	ld h, a
;>     mem[e] = hPlayerX & 0xFF; mem[e + 1] = hPlayerY & 0xFF
	ldh a, [hPlayerX]
	ld [hli], a
	ldh a, [hPlayerY]
	ld [hli], a
;>     mem[e + 2] = (mem[hPlayerX + 1] << 4) | mem[hPlayerY + 1]
	ldh a, [$ff93]
	swap a
	ld c, a
	ldh a, [$ff96]
	or c
	ld [hli], a
;>     mem[e + 3] = hPlayerFrame | hPlayerAttr
	ldh a, [hPlayerFrame]
	ld c, a
	ldh a, [hPlayerAttr]
	or c
	ld [hli], a
;>     wTrailPos += 1
	ld a, [wTrailPos]
	inc a
	ld [wTrailPos], a
;>     if wTrailPos >= 0x31: wTrailPos = 0
	cp $31
	jr c, jr_006_6427

	xor a
	ld [wTrailPos], a

;=@n
jr_006_6427:
	dec b
	jr nz, jr_006_63f2

;> mem16[hTestX] = mem16[hPlayerX]
	ldh a, [hPlayerX]
	ldh [hTestX], a
	ldh a, [$ff93]
	ldh [$ffa6], a
;> mem16[hTestY] = mem16[hPlayerY]
	ldh a, [hPlayerY]
	ldh [hTestY], a
	ldh a, [$ff96]
	ldh [$ffa8], a
;> GetCollisionAt(); HandleConveyor()
	call GetCollisionAt
	ld hl, far_HandleConveyor
	rst $10
;> mem[0xD9E8] = 0
	xor a
	ld [wFieldInputBlock], a
	ret


;@ def ScrollRight()
;@ path: field/scrolling
;@ Scroll to the screen on the right, step wScrollStep of ScrollRightSteps.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollRight::
;> return ScrollRightSteps[wScrollStep]()
	ld a, [wScrollStep]
	rst $00

;@ path: field/scrolling
;@ Steps of the scroll to the right: start, load the screen's objects, run its map script,
;@ column by column, finish.
ScrollRightSteps::
	dw ScrollRightStart
	dw ScrollLoadScreen
	dw ScrollRunMapScript
	dw ScrollRightColumn
	dw ScrollFinish

;@ def ScrollRightStart()
;@ path: field/scrolling
;@ Step 0 of the scroll right: wMapScreen += 1, shows the party bar in the window, builds the new
;@ screen in the buffers (bank $0B entry 3) and starts at column 0.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollRightStart::
;> wMapScreen += 1
	ld a, [wMapScreen]
	inc a
	ld [wMapScreen], a
;> ShowPartyBarWindow()
	call ShowPartyBarWindow
;> RedrawScreenBuffer()                            # RedrawScreenBuffer
	ld hl, $0b03
	rst $10
;> wScrollColumn = 0
	xor a
	ld [wScrollColumn], a
;> wScrollStep += 1
	ld hl, wScrollStep
	inc [hl]
	ret


;@ def ScrollRightColumn()
;@ path: field/scrolling
;@ Step 3 of the scroll right, every frame: queues column wScrollColumn of the new screen for the
;@ BG map column just right of the view (20 columns on), scrolls 8 pixels right and counts the
;@ column up; after column $13 the next step follows.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollRightColumn::
;>@a row = (hScrollY & 0xF8) * 4
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
;=@a
	sla l
	rla
;> dest = 0x9800 + row
	ld h, $98
	add h
	ld h, a
;>@b dest += ((hScrollX >> 3) + 0x14) & 0x1F
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	add $14
	and $1f
;=@b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> wMapUpdateDest = dest
	ld a, l
	ld [wMapUpdateDest], a
	ld a, h
	ld [$c741], a
;>@d src = wTilemapBuffer + wScrollColumn
	ld a, [wScrollColumn]
	ld de, wTilemapBuffer
	add e
	ld e, a
	ld a, $00
	adc d
;=@d
	ld d, a
;> wMapUpdateDir = 1                       # a column
	ld a, $01
	ld [wMapUpdateDir], a
;> wMapUpdateLen = 0x10
	ld a, $10
	ld [wMapUpdateLen], a
;> out = wMapUpdateTiles
	ld hl, wMapUpdateTiles
;>@i for i in range(16):
	ld b, $10

;>     mem[out] = mem[src]; out += 1
jr_006_64ad:
	ld a, [de]
	ld [hli], a
;>     src += 0x20
	ld a, e
	add $20
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@i
	dec b
	jr nz, jr_006_64ad

;> col = wScrollColumn >> 1; odd = wScrollColumn & 1
	ld a, [wScrollColumn]
	srl a
;>@m src = wScreenMap + col
	push af
	ld de, wScreenMap
	add e
	ld e, a
	ld a, $00
	adc d
;=@m
	ld d, a
	pop af
;> out = wMapUpdateTiles + 0x10              # the attributes
	ld b, $10
	ld hl, $c754
;> if not odd:
	jr c, jr_006_64e4

;>@j     for i in range(16):
;>         mem[out] = mem[src] >> 4; out += 1   # left half of the metatile
jr_006_64d1:
	ld a, [de]
	swap a
	and $0f
	ld [hli], a
;>         src += 0x10
	ld a, e
	add $10
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@j
	dec b
	jr nz, jr_006_64d1

;> else:
	jr jr_006_64f3

;>@k     for i in range(16):
;>         mem[out] = mem[src] & 0x0F; out += 1
jr_006_64e4:
	ld a, [de]
	and $0f
	ld [hli], a
;>         src += 0x10
	ld a, e
	add $10
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@k
	dec b
	jr nz, jr_006_64e4

;> wMapUpdateOn = 1
jr_006_64f3:
	ld a, $01
	ld [wMapUpdateOn], a
;>@x t = mem16[hScrollX] + 8
	ldh a, [hScrollX]
	ld l, a
	ldh a, [$ffb8]
	ld h, a
	ld a, l
	add $08
;=@x
	ld l, a
	ld a, h
	adc $00
	ld h, a
;> mem16[hScrollX] = t
	ld a, l
	ldh [hScrollX], a
	ld a, h
	ldh [$ffb8], a
;> wScrollColumn += 1
	ld a, [wScrollColumn]
	inc a
	ld [wScrollColumn], a
;> if wScrollColumn != 0x14: return
	cp $14
	ret nz

;> wScrollStep += 1
	ld hl, wScrollStep
	inc [hl]
	ret


;@ def ScrollUp()
;@ path: field/scrolling
;@ Scroll to the screen above, step wScrollStep of ScrollUpSteps.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollUp::
;> return ScrollUpSteps[wScrollStep]()
	ld a, [wScrollStep]
	rst $00

;@ path: field/scrolling
;@ Steps of the scroll up: start, load the screen's objects, run its map script, row by row,
;@ finish.
ScrollUpSteps::
	dw ScrollUpStart
	dw ScrollLoadScreen
	dw ScrollRunMapScript
	dw ScrollUpRow
	dw ScrollFinish

;@ def ScrollUpStart()
;@ path: field/scrolling
;@ Step 0 of the scroll up: wMapScreen -= 4 (maps are 4 screens wide), shows the party bar in
;@ the window, builds the new screen in the buffers and starts at row $0F.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollUpStart::
;> wMapScreen -= 4
	ld a, [wMapScreen]
	sub $04
	ld [wMapScreen], a
;> ShowPartyBarWindow()
	call ShowPartyBarWindow
;> RedrawScreenBuffer()                            # RedrawScreenBuffer
	ld hl, $0b03
	rst $10
;> wScrollColumn = 0x0F
	ld a, $0f
	ld [wScrollColumn], a
;> wScrollStep += 1
	ld hl, wScrollStep
	inc [hl]
	ret


;@ def ScrollUpRow()
;@ path: field/scrolling
;@ Step 3 of the scroll up, every frame: queues row wScrollColumn of the new screen (20 tiles from
;@ wTilemapBuffer, attributes from wScreenMap) for the BG map row just above the view, scrolls
;@ 8 pixels up and counts the row down; after row 0 the next step follows.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollUpRow::
;>@a row = (hScrollY & 0xF8) * 4
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
;=@a
	sla l
	rla
;> dest = 0x9800 + row
	ld h, $98
	add h
	ld h, a
;>@b dest += (hScrollX >> 3) & 0x1F
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	and $1f
	add l
;=@b
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@c dest = (dest + 0x3E0) & ~0x400         # the row above, wrapping in the map
	ld a, l
	add $e0
	ld l, a
	ld a, h
	adc $03
	ld h, a
;=@c
	res 2, h
;> wMapUpdateDest = dest
	ld a, l
	ld [wMapUpdateDest], a
	ld a, h
	ld [$c741], a
;> t = wScrollColumn
	ld a, [wScrollColumn]
	ld l, a
	ld h, $00
;> t *= 0x20
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
;>@s src = wTilemapBuffer + t
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;=@s
	ld e, l
	ld d, h
;> wMapUpdateDir = 0                       # a row
	ld a, $00
	ld [wMapUpdateDir], a
;> wMapUpdateLen = 0x14
	ld a, $14
	ld [wMapUpdateLen], a
;> out = wMapUpdateTiles
	ld hl, wMapUpdateTiles
;>@i for i in range(20):
	ld b, $14

;>     mem[out] = mem[src]; out += 1; src += 1
jr_006_6595:
	ld a, [de]
	ld [hli], a
	inc de
;=@i
	dec b
	jr nz, jr_006_6595

;> t = wScrollColumn
	ld a, [wScrollColumn]
	ld l, a
	ld h, $00
;> t *= 0x10
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
;>@m src = wScreenMap + t
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c2
	ld h, a
;=@m
	ld e, l
	ld d, h
;> out = wMapUpdateTiles + 0x14              # the attributes
	ld hl, $c758
;>@j for i in range(10):                     # 10 metatiles, 2 halves each
	ld b, $0a

;>@n     mem[out] = mem[src] >> 4; mem[out + 1] = mem[src] & 0x0F
jr_006_65b4:
	ld a, [de]
	swap a
	and $0f
	ld [hli], a
	ld a, [de]
	and $0f
;=@n
	ld [hli], a
;>     src += 1
	inc de
;=@j
	dec b
	jr nz, jr_006_65b4

;> wMapUpdateOn = 1
	ld a, $01
	ld [wMapUpdateOn], a
;>@x t = mem16[hScrollY] - 8
	ldh a, [hScrollY]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	ld a, l
	add $f8
;=@x
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;> mem16[hScrollY] = t
	ld a, l
	ldh [hScrollY], a
	ld a, h
	ldh [$ffbc], a
;> wScrollColumn -= 1
	ld a, [wScrollColumn]
	dec a
	ld [wScrollColumn], a
;> if wScrollColumn != 0xFF: return
	cp $ff
	ret nz

;> wScrollStep += 1
	ld hl, wScrollStep
	inc [hl]
	ret


;@ def ScrollDown()
;@ path: field/scrolling
;@ Scroll to the screen below, step wScrollStep of ScrollDownSteps.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollDown::
;> return ScrollDownSteps[wScrollStep]()
	ld a, [wScrollStep]
	rst $00

;@ path: field/scrolling
;@ Steps of the scroll down: start, load the screen's objects, run its map script, row by row,
;@ finish.
ScrollDownSteps::
	dw ScrollDownStart
	dw ScrollLoadScreen
	dw ScrollRunMapScript
	dw ScrollDownRow
	dw ScrollFinish

;@ def ScrollDownStart()
;@ path: field/scrolling
;@ Step 0 of the scroll down: wMapScreen += 4, shows the party bar in the window, builds the new
;@ screen in the buffers and starts at row 0.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollDownStart::
;> wMapScreen += 4
	ld a, [wMapScreen]
	add $04
	ld [wMapScreen], a
;> ShowPartyBarWindow()
	call ShowPartyBarWindow
;> RedrawScreenBuffer()                            # RedrawScreenBuffer
	ld hl, $0b03
	rst $10
;> wScrollColumn = 0
	xor a
	ld [wScrollColumn], a
;> wScrollStep += 1
	ld hl, wScrollStep
	inc [hl]
	ret


;@ def ScrollDownRow()
;@ path: field/scrolling
;@ Step 3 of the scroll down, every frame: queues row wScrollColumn of the new screen for the BG
;@ map row just below the view (16 rows on), scrolls 8 pixels down and counts the row up; after
;@ row $0F the next step follows.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollDownRow::
;>@a row = (hScrollY & 0xF8) * 4
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
;=@a
	sla l
	rla
;> dest = 0x9800 + row
	ld h, $98
	add h
	ld h, a
;>@b dest += (hScrollX >> 3) & 0x1F
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	and $1f
	add l
;=@b
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@c dest = (dest + 0x200) & ~0x400         # 16 rows down, wrapping in the map
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $02
	ld h, a
;=@c
	res 2, h
;> wMapUpdateDest = dest
	ld a, l
	ld [wMapUpdateDest], a
	ld a, h
	ld [$c741], a
;> t = wScrollColumn
	ld a, [wScrollColumn]
	ld l, a
	ld h, $00
;> t *= 0x20
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
;>@s src = wTilemapBuffer + t
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;=@s
	ld e, l
	ld d, h
;> wMapUpdateDir = 0                       # a row
	ld a, $00
	ld [wMapUpdateDir], a
;> wMapUpdateLen = 0x14
	ld a, $14
	ld [wMapUpdateLen], a
;> out = wMapUpdateTiles
	ld hl, wMapUpdateTiles
;>@i for i in range(20):
	ld b, $14

;>     mem[out] = mem[src]; out += 1; src += 1
jr_006_6663:
	ld a, [de]
	ld [hli], a
	inc de
;=@i
	dec b
	jr nz, jr_006_6663

;> t = wScrollColumn
	ld a, [wScrollColumn]
	ld l, a
	ld h, $00
;> t *= 0x10
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
;>@m src = wScreenMap + t
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c2
	ld h, a
;=@m
	ld e, l
	ld d, h
;> out = wMapUpdateTiles + 0x14              # the attributes
	ld hl, $c758
;>@j for i in range(10):                     # 10 metatiles, 2 halves each
	ld b, $0a

;>@n     mem[out] = mem[src] >> 4; mem[out + 1] = mem[src] & 0x0F
jr_006_6682:
	ld a, [de]
	swap a
	and $0f
	ld [hli], a
	ld a, [de]
	and $0f
;=@n
	ld [hli], a
;>     src += 1
	inc de
;=@j
	dec b
	jr nz, jr_006_6682

;> wMapUpdateOn = 1
	ld a, $01
	ld [wMapUpdateOn], a
;>@x t = mem16[hScrollY] + 8
	ldh a, [hScrollY]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	ld a, l
	add $08
;=@x
	ld l, a
	ld a, h
	adc $00
	ld h, a
;> mem16[hScrollY] = t
	ld a, l
	ldh [hScrollY], a
	ld a, h
	ldh [$ffbc], a
;> wScrollColumn += 1
	ld a, [wScrollColumn]
	inc a
	ld [wScrollColumn], a
;> if wScrollColumn != 0x10: return
	cp $10
	ret nz

;> wScrollStep += 1
	ld hl, wScrollStep
	inc [hl]
	ret


;@ def ScrollLoadScreen()
;@ path: field/scrolling
;@ Step 1 of every screen scroll: places the new screen's objects (bank $0B), not on gate floors.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollLoadScreen::
;> if not wOnGateFloor: SpawnMapObjects()
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_006_66c2

	ld hl, far_SpawnMapObjects
	rst $10

;> wScrollStep += 1
jr_006_66c2:
	ld hl, wScrollStep
	inc [hl]
	ret


;@ def ScrollRunMapScript()
;@ path: field/scrolling
;@ Step 2 of every screen scroll: starts script 0 of the map (its screen-entry script), unless on
;@ a gate floor or a script already runs.
;@ test: skip builds the BG map updates for the VBlank handler
ScrollRunMapScript::
;> wScrollStep += 1
	ld hl, wScrollStep
	inc [hl]
;> if wOnGateFloor: return
	ld a, [wOnGateFloor]
	or a
	ret nz

;> if wScriptRunning: return
	ld a, [wScriptRunning]
	or a
	ret nz

;> wScriptId = 0; wScriptMap = wMapId
	ld a, $00
	ld [wScriptId], a
	ld a, [wMapId]
	ld [wScriptMap], a
;> StartScript()
	ld hl, far_StartScript
	rst $10
	ret


;@ def ShowPartyBarWindow()
;@ path: field/partybar
;@ Shows the party bar in the window (line $80, map $9C00) while the screen scrolls.
;@ test: skip writes VRAM
ShowPartyBarWindow::
;> hWY = 0x80
	ld a, $80
	ldh [hWY], a
;> DrawPartyBarAt(0x9C00)
	ld hl, $9c00
	call DrawPartyBarAt
	ret


;@ def RestorePartyBarRows()
;@ path: field/partybar
;@ Hides the window again and draws the party bar into the BG map rows 16 and 17 below the view.
;@ test: skip writes VRAM
RestorePartyBarRows::
;> hWY = 0xFF
	ld a, $ff
	ldh [hWY], a
;>@a row = (hScrollY & 0xF8) * 4
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
;=@a
	sla l
	rla
;> dest = 0x9800 + row
	ld h, $98
	add h
	ld h, a
;>@b dest += (hScrollX >> 3) & 0x1F
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	and $1f
	add l
;=@b
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@c dest = (dest + 0x200) & ~0x400         # 16 rows down
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $02
	ld h, a
;=@c
	res 2, h
;> DrawPartyBarAt(dest)
	call DrawPartyBarAt
	ret


;@ def DrawPartyBarAt(dest: hl)
;@ path: field/partybar
;@ Copies the two party bar rows to the BG map at `dest` (CopyPartyBarTiles) and, on a Game Boy
;@ Color, sets their attributes to palette 7.
;@ test: skip writes VRAM
DrawPartyBarAt::
;> CopyPartyBarTiles(dest)
	push hl
	call CopyPartyBarTiles
	pop hl
;> if not wOnCGB: return
	ld a, [wOnCGB]
	or a
	ret z

;> WaitVRAMAccess(); rVBK = 1              # attribute bank
	di
	call WaitVRAMAccess
	ld a, $01
	ldh [rVBK], a
	ei
;>@o for row in range(2):
	ld c, $02

;>@r     for col in range(20):
jr_006_6734:
	ld b, $14
	push hl

;>         WriteVRAM(dest, 7)
jr_006_6737:
	ld a, $07
	call WriteVRAM
;>@c         dest = (dest & ~0x1F) | ((dest + 1) & 0x1F)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@c
	ld l, a
	pop af
	or l
	ld l, a
	inc de
;=@r
	dec b
	jr nz, jr_006_6737

;>@q     src += 12                            # (unused here)
	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
;=@q
	ld d, a
;>@s     dest = (dest & 0xFC00) | ((dest + 0x20) & 0x3FF)
	push bc
	ld bc, $0020
	ld a, h
	add hl, bc
	and $fc
	ld b, a
;=@s
	ld a, h
	and $03
	or b
	ld h, a
	pop bc
;=@o
	dec c
	jr nz, jr_006_6734

;> WaitVRAMAccess(); rVBK = 0
	di
	call WaitVRAMAccess
	ld a, $00
	ldh [rVBK], a
	ei
	ret


;@ def CopyPartyBarTiles(dest: hl)
;@ path: field/partybar
;@ Copies the two rows of the party bar (20 tiles of each 32-tile row of wPartyBarTiles) to the
;@ BG or window map at `dest`.
;@ test: skip writes VRAM
CopyPartyBarTiles::
;> src = wPartyBarTiles
	ld de, wPartyBarTiles
;>@o for row in range(2):
	ld c, $02

;>@r     for col in range(20):
jr_006_6776:
	ld b, $14
	push hl

;>         WriteVRAM(dest, mem[src])
jr_006_6779:
	ld a, [de]
	call WriteVRAM
;>@c         dest = (dest & ~0x1F) | ((dest + 1) & 0x1F)   # wraps in the row
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@c
	ld l, a
	pop af
	or l
	ld l, a
;>         src += 1
	inc de
;=@r
	dec b
	jr nz, jr_006_6779

;>@q     src += 12                            # to the next 32-tile row
	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
;=@q
	ld d, a
;>@s     dest = (dest & 0xFC00) | ((dest + 0x20) & 0x3FF)   # next row
	push bc
	ld bc, $0020
	ld a, h
	add hl, bc
	and $fc
	ld b, a
;=@s
	ld a, h
	and $03
	or b
	ld h, a
	pop bc
;=@o
	dec c
	jr nz, jr_006_6776

;> return
	ret


;@ def RunFieldEvent()
;@ path: event/textbox
;@ wFieldFlags bit 0: one step (wEventStep) of a field event - a text box drawn into the BG map
;@ (saving and later restoring the tiles under it) around the event routine in wEventRoutine
;@ ($FFFF = the running script's message). The scroll is first rounded to whole tiles.
;@ test: skip writes VRAM
RunFieldEvent::
;> RoundScroll(hScrollX)
	ld hl, hScrollX
	call RoundScroll
;> RoundScroll(hScrollY)
	ld hl, hScrollY
	call RoundScroll
;> return FieldEventSteps[wEventStep]()
	ld a, [wEventStep]
	rst $00

;@ path: event/textbox
;@ The 21 steps of a field event: open the box (+ save the BG), save the BG, draw the middle row,
;@ wait, wait, wait, draw rows 1 and 3, wait, wait, draw the frame, show the text, run the event,
;@ restore rows 0 and 4, wait, wait, restore rows 1 and 3, wait, wait, wait, restore row 2, end.
FieldEventSteps::
	dw EventOpenBox
	dw EventSaveBG
	dw EventDrawBoxMiddle
	dw EventNextStep
	dw EventNextStep
	dw EventNextStep
	dw EventDrawBoxRows
	dw EventNextStep
	dw EventNextStep
	dw EventDrawBoxFrame
	dw EventShowText
	dw EventRun
	dw EventRestoreBG1
	dw EventNextStep
	dw EventNextStep
	dw EventRestoreBG2
	dw EventNextStep
	dw EventNextStep
	dw EventNextStep
	dw EventRestoreBG3
	dw EventEnd

;@ def RoundScroll(p: hl)
;@ path: event/textbox
;@ Rounds the u16 scroll value at `p` to the nearest multiple of 8.
;@ test: skip writes VRAM
RoundScroll::
;> mem16[p] += 4
	ld a, [hl]
	add $04
	ld [hli], a
	ld a, [hl]
	adc $00
	ld [hld], a
;> mem[p] &= 0xF8
	ld a, [hl]
	and $f8
	ld [hl], a
	ret


;@ def NextBoxMapColumn(dest: hl) -> hl
;@ path: event/textbox
;@ Moves a BG map address one column right, wrapping inside its 32-tile row (keeps a).
;@ test: skip writes VRAM
NextBoxMapColumn::
;>@c dest = (dest & ~0x1F) | ((dest + 1) & 0x1F)
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;=@c
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
;> return dest
	pop af
	ret


;@ def EventShowText()
;@ path: event/textbox
;@ Field event step 10: prepares the text window (bank $56), prints system text wEventRoutine
;@ unless it is $FFFF (the script's own message), and sets the box's inner area for the text
;@ (DrawTextBoxTiles at row 1, column 1).
;@ test: skip writes VRAM
EventShowText::
;> mem[0xC83B] = 0xFD; ClearTextBoxTiles()
	ld a, $fd
	ld [$c83b], a
	ld hl, far_ClearTextBoxTiles
	rst $10
;>@p if wEventRoutine != 0xFFFF:
	ld a, [wEventRoutine]
	ld l, a
	ld a, [$c918]
	ld h, a
	ld a, h
	and l
;=@p
	cp $ff
	jr z, jr_006_6819

;>     PrintSystemText(wEventRoutine)
	call PrintSystemText

;> wEventStep += 1
jr_006_6819:
	ld hl, wEventStep
	inc [hl]
;> dest = NextBoxMapColumn(EventBoxMapAddress(0x20))
	ld hl, $0020
	call EventBoxMapAddress
	call NextBoxMapColumn
;> DrawTextBoxTiles(dest)
	call DrawTextBoxTiles
	ret


;@ def EventNextStep()
;@ path: event/textbox
;@ A waiting step of the field event: just goes on to the next step.
;@ test: skip writes VRAM
EventNextStep::
;> wEventStep += 1
	ld hl, wEventStep
	inc [hl]
	ret


;@ def EventBoxMapAddress(offset: hl) -> hl
;@ path: event/textbox
;@ BG map address wEventBoxMap + offset, wrapped inside the 1 KiB map.
;@ test: skip writes VRAM
EventBoxMapAddress::
;>@a a = wEventBoxMap + offset
	ld a, [wEventBoxMap]
	add l
	ld l, a
	ld a, [$c91a]
	adc h
	and $03
;=@a
	ld h, a
;> return (wEventBoxMap & 0xFC00) | (a & 0x3FF)
	ld a, [$c91a]
	and $fc
	or h
	ld h, a
	ret


;@ def EventOpenBox()
;@ path: event/textbox
;@ Field event step 0: picks where the 5-row box goes - at the top of the view (offset 0) or at
;@ row 13 ($1A0) - from the script's wScriptFlags (bit 0 bottom, bit 1 top) or else from Terry's
;@ height on screen (in the upper part the box goes to the bottom); sets hSpriteClip (1 top,
;@ 2 bottom, 0 on map $08 and $5D) and $C83D accordingly, stores the box address in wEventBoxMap
;@ and goes on with EventSaveBG.
;@ test: skip writes VRAM
EventOpenBox::
;> wEventStep += 1
	ld hl, wEventStep
	inc [hl]
;> hSpriteClip = 1; wTextChoice = 0
	ld a, $01
	ldh [hSpriteClip], a
	ld a, $00
	ld [wTextChoice], a
;> mem[0xC83D] = 0x20
	ld a, $20
	ld [$c83d], a
;> offset = 0; side = 0                     # 0 = by Terry's height, 1 = bottom, 2 = top
	ld de, $0000
;> if wScriptRunning:
	ld a, [wScriptRunning]
	or a
	jr z, jr_006_686e

;>     f = wScriptFlags; wScriptFlags &= ~0x03
	ld hl, wScriptFlags
	ld a, [hl]
	res 0, [hl]
	res 1, [hl]
;>     side = 1 if f & 0x01 else 2 if f & 0x02 else 0
	bit 0, a
	jr nz, jr_006_6882
	bit 1, a
	jr nz, jr_006_6893

;> if side == 0:
;>@y     y = mem16[hPlayerY] - mem16[hScrollY]  # Terry's height on screen
jr_006_686e:
	ldh a, [hScrollY]
	ld c, a
	ldh a, [hPlayerY]
	sub c
	ld c, a
	ldh a, [$ffbc]
;=@y
	ld b, a
	ldh a, [$ff96]
	sbc b
;>     side = 1 if y < 0x50 else 2
	jr nz, jr_006_6882

	ld a, c
	cp $50
	jr nc, jr_006_6893

;> if side == 1:
;>     hSpriteClip = 2; wTextChoice = 0
jr_006_6882:
	ld a, $02
	ldh [hSpriteClip], a
	ld a, $00
	ld [wTextChoice], a
;>     mem[0xC83D] = 0x80; offset = 0x1A0
	ld a, $80
	ld [$c83d], a
	ld de, $01a0

;>@g if not wOnGateFloor and wMapId in (0x08, 0x5D):
jr_006_6893:
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_006_68a7

	ld a, [wMapId]
	cp $08
	jr z, jr_006_68a4

;=@g
	cp $5d
	jr nz, jr_006_68a7

;>     hSpriteClip = 0
jr_006_68a4:
	xor a
	ldh [hSpriteClip], a

;> RoundScroll2(hScrollX)
jr_006_68a7:
	ld hl, hScrollX
	call RoundScroll2
;> RoundScroll2(hScrollY)
	ld hl, hScrollY
	call RoundScroll2
;>@t t = hScrollY * 4 + (hScrollX >> 3)       # (scroll in whole tiles)
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@t
	rrca
	rrca
	rrca
	add l
	ld l, a
;> t = 0x9800 + t + offset
	ld a, h
	adc $98
	ld h, a
	add hl, de
;>@w wEventBoxMap = 0x9800 | (t & 0x3FF)
	ld a, h
	and $03
	or $98
	ld h, a
;=@w
	ld a, l
	ld [wEventBoxMap], a
	ld a, h
	ld [$c91a], a

;@ def EventSaveBG()
;@ path: event/textbox
;@ Field event step 1 (also run right after EventOpenBox): saves the 5 BG map rows under the box
;@ (20 tiles each) to $C100, $C114, $C128, $C13C and $C150.
;@ test: skip writes VRAM
EventSaveBG::
;> wEventStep += 1
	ld hl, wEventStep
	inc [hl]
;> dest = wEventBoxMap
	ld a, [wEventBoxMap]
	ld l, a
	ld a, [$c91a]
	ld h, a
;> SaveBGRow(0x00, wLineScroll)
	ld bc, $0000
	ld de, wLineScroll
	call SaveBGRow
;> SaveBGRow(0x20, 0xC114)
	ld bc, $0020
	ld de, $c114
	call SaveBGRow
;> SaveBGRow(0x40, 0xC128)
	ld bc, $0040
	ld de, $c128
	call SaveBGRow
;> SaveBGRow(0x60, 0xC13C)
	ld bc, $0060
	ld de, $c13c
	call SaveBGRow
;> return SaveBGRow(0x80, 0xC150)
	ld bc, $0080
	ld de, $c150

;@ def SaveBGRow(offset: bc, buf: de)
;@ path: event/textbox
;@ Copies the 20 BG map tiles of the box row at wEventBoxMap + offset into `buf`.
;@ test: skip writes VRAM
SaveBGRow::
;>@a src = wEventBoxMap + offset
	ld a, [wEventBoxMap]
	ld l, a
	ld a, [$c91a]
	ld h, a
	add hl, bc
	ld a, h
;=@a
	and $03
	ld h, a
;> src = (wEventBoxMap & 0xFC00) | (src & 0x3FF)
	ld a, [$c91a]
	and $fc
	or h
	ld h, a
;>@i for i in range(20):
	ld b, $14

;>     WaitVRAMAccess(); mem[buf] = mem[src]
jr_006_6920:
	di
	call WaitVRAMAccess
	ld a, [hl]
	ei
	ld [de], a
;>     buf += 1; src = NextBoxMapColumn(src)
	inc de
	call NextBoxMapColumn
;=@i
	dec b
	jr nz, jr_006_6920

;> return
	ret


;@ def EventDrawBoxMiddle()
;@ path: event/textbox
;@ Field event step 2: draws the box's middle row (row 2) - the box opens from the middle.
;@ test: skip writes VRAM
EventDrawBoxMiddle::
;> wEventStep += 1
	ld hl, wEventStep
	inc [hl]
;> return DrawBoxSideRow(EventBoxMapAddress(0x40))
	ld hl, $0040
	call EventBoxMapAddress

;@ def DrawBoxSideRow(dest: hl)
;@ path: event/textbox
;@ Draws one inner row of the box: border tile $FE, 18 blank tiles $E0, border tile $FF.
;@ test: skip writes VRAM
DrawBoxSideRow::
;> WriteVRAM(dest, 0xFE); dest = NextBoxMapColumn(dest)
	ld a, $fe
	call WriteVRAM
	call NextBoxMapColumn
;> dest = FillMapTiles(dest, 0xE0, 18)
	ld b, $12
	ld a, $e0
	call FillMapTiles
;> return WriteVRAM(dest, 0xFF)
	ld a, $ff
	jp WriteVRAM


;@ def FillMapTiles(dest: hl, tile: a, count: b) -> hl
;@ path: event/textbox
;@ Writes `count` copies of `tile` to the BG map from `dest` on, rightwards (wrapping in the row).
;@ test: skip writes VRAM
FillMapTiles::
;>@i for i in range(count):
;>     WriteVRAM(dest, tile); dest = NextBoxMapColumn(dest)
	call WriteVRAM
	call NextBoxMapColumn
;=@i
	dec b
	jr nz, FillMapTiles

;> return dest
	ret


;@ def RoundScroll2(p: hl)
;@ path: event/textbox
;@ Same as RoundScroll: rounds the u16 scroll value at `p` to the nearest multiple of 8.
;@ test: skip writes VRAM
RoundScroll2::
;> mem16[p] += 4
	ld a, [hl]
	add $04
	ld [hli], a
	ld a, [hl]
	adc $00
	ld [hld], a
;> mem[p] &= 0xF8
	ld a, [hl]
	and $f8
	ld [hl], a
	ret


;@ def EventDrawBoxRows()
;@ path: event/textbox
;@ Field event step 6: draws the inner rows 1 and 3 of the box.
;@ test: skip writes VRAM
EventDrawBoxRows::
;> wEventStep += 1
	ld hl, wEventStep
	inc [hl]
;> DrawBoxSideRow(EventBoxMapAddress(0x20))
	ld hl, $0020
	call EventBoxMapAddress
	call DrawBoxSideRow
;> return DrawBoxSideRow(EventBoxMapAddress(0x60))
	ld hl, $0060
	call EventBoxMapAddress
	jr DrawBoxSideRow

;@ def EventDrawBoxFrame()
;@ path: event/textbox
;@ Field event step 9: draws the top row ($FA, 18 x $EF, $FB) and bottom row ($FC, 18 x $EE,
;@ $FD) of the box, then on the Super Game Boy gives the box area (19 x 4 at row 0 or 13)
;@ palette 1.
;@ test: skip writes VRAM
EventDrawBoxFrame::
;> wEventStep += 1
	ld hl, wEventStep
	inc [hl]
;> dest = wEventBoxMap
	ld a, [wEventBoxMap]
	ld l, a
	ld a, [$c91a]
	ld h, a
;> WriteVRAM(dest, 0xFA); dest = NextBoxMapColumn(dest)
	ld a, $fa
	call WriteVRAM
	call NextBoxMapColumn
;> dest = FillMapTiles(dest, 0xEF, 18)
	ld b, $12
	ld a, $ef
	call FillMapTiles
;> WriteVRAM(dest, 0xFB)
	ld a, $fb
	call WriteVRAM
;> dest = EventBoxMapAddress(0x80)
	ld hl, $0080
	call EventBoxMapAddress
;> WriteVRAM(dest, 0xFC); dest = NextBoxMapColumn(dest)
	ld a, $fc
	call WriteVRAM
	call NextBoxMapColumn
;> dest = FillMapTiles(dest, 0xEE, 18)
	ld b, $12
	ld a, $ee
	call FillMapTiles
;> WriteVRAM(dest, 0xFD)
	ld a, $fd
	call WriteVRAM
;> SGBAttrBlkBegin()
	call SGBAttrBlkBegin
;> pos = 0x000D if hSpriteClip == 2 else 0x0000   # (x, y) of the block
	ld hl, $0000
	ldh a, [hSpriteClip]
	cp $02
	jr nz, jr_006_69c2

	ld hl, $000d

;> SGBAttrBlkAdd(0, pos, size=0x1304, palette=1)
jr_006_69c2:
	ld a, $00
	ld bc, $1304
	ld d, $01
	call SGBAttrBlkAdd
;> SGBAttrBlkSend()
	call SGBAttrBlkSend
	ret


;@ def EventRun()
;@ path: event/textbox
;@ Field event step 11, once the text is shown and nothing fades: for the script's own message
;@ ($FFFF) it keeps the script going (bank 4 entry 6, PrintScriptMessage); events $0211 (clears
;@ the floor objects' bit 5) and $0217 (boss battle) are handled here; event $1A is the party's
;@ defeat: Terry is sent home to map 0 at ($E8, $58) with half his gold and only the items whose
;@ item data has bit 2 set; any other event just goes on (and sets the SGB field palettes).
;@ Only the low byte is compared for $1A.
;@ test: skip writes VRAM
EventRun::
;> if wFieldPaused: return
	ld a, [wFieldPaused]
	or a
	ret nz

;> if wFadeState: return
	ld a, [wFadeState]
	or a
	ret nz

;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;>@e if wEventRoutine == 0xFFFF and wScriptRunning & 0x02:
	ld a, [wEventRoutine]
	ld l, a
	ld a, [$c918]
	ld h, a
	ld a, h
	and l
;=@e
	cp $ff
	jr nz, jr_006_6a02

	ld a, [wScriptRunning]
	bit 1, a
	jr z, jr_006_6a02

;>     if wFieldFlags & 0x80: return
	ld a, [wFieldFlags]
	bit 7, a
	ret nz

;>     if wFieldFlags & 0x10: return
	bit 4, a
	ret nz

;>     return PrintScriptMessage()                 # PrintScriptMessage: the script goes on
	ld hl, $0406
	rst $10
	ret


;> if wEventRoutine >> 8 == 0x02:
jr_006_6a02:
	ld a, [$c918]
	cp $02
	jr nz, jr_006_6a25

;>     if wEventRoutine & 0xFF == 0x11:
	ld a, [wEventRoutine]
	cp $11
	jr nz, jr_006_6a1a

;>         ClearFloorObjectFlags()          # (followed by a test of $17 that does nothing)
	call ClearFloorObjectFlags
	ld a, [wEventRoutine]
	cp $17
	jr nz, jr_006_6a1a

;>     if wEventRoutine & 0xFF == 0x17:
jr_006_6a1a:
	ld a, [wEventRoutine]
	cp $17
	jr nz, jr_006_6a25

;>         return StartEventBossBattle()
	call StartEventBossBattle
	ret


;> if wEventRoutine & 0xFF != 0x1A:
;>@n     wEventStep += 1
;>@o     SGBSetFieldPalettes()
;>@q     return
jr_006_6a25:
	ld a, [wEventRoutine]
	cp $1a
	jp nz, Jump_006_6ab9

;> wFieldFlags &= ~0x01                     # event over
	ld hl, wFieldFlags
	res 0, [hl]
;> wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [$c916], a
;> mem[0xD92B] = 8
	ld a, $08
	ld [wHomeWarpCause], a
;> wWarpMap = 0; wWarpOnGateFloor = 0       # back home
	ld hl, $0000
	ld a, l
	ld [wWarpMap], a
	ld a, h
	ld [wWarpOnGateFloor], a
;> wWarpX = 0xE8
	ld hl, $00e8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;> wWarpY = 0x58
	ld hl, $0058
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> wGameStarted &= ~0x80
	ld hl, wGameStarted
	res 7, [hl]
;> gold = wGold                             # 24-bit
	ld a, [wGold]
	ld l, a
	ld a, [$ca4c]
	ld h, a
	ld a, [$ca4d]
	ld e, a
;> gold = Divide24(gold, 2)
	ld a, $02
	call Divide24
;> wGold = gold
	ld a, l
	ld [wGold], a
	ld a, h
	ld [$ca4c], a
	ld a, e
	ld [$ca4d], a
;> item = wBagItems
	ld hl, wBagItems
;>@b for i in range(20):
	ld b, $14

;>     if mem[item] not in (0x00, 0xFF):
jr_006_6a8b:
	ld a, [hl]
	or a
	jr z, jr_006_6aa7

	cp $ff
	jr z, jr_006_6aa7

;>         wItemId = mem[item]; GetItemData()
	ld [wItemId], a
	push hl
	push bc
	ld hl, far_GetItemData
	rst $10
;>         if not mem[0xDA6D] & 0x04:       # not kept
	pop bc
	pop hl
	ld a, [wItemFlags]
	bit 2, a
	jr nz, jr_006_6aa7

;>             mem[item] = 0xFF             # lost
	ld [hl], $ff

;>     item += 1
jr_006_6aa7:
	inc hl
;=@b
	dec b
	jr nz, jr_006_6a8b

;> CompactBag()
	ld hl, far_CompactBag
	rst $10
;> StartFade(4)
	ld a, $04
	call StartFade
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
	ret


Jump_006_6ab9:
;=@n
	ld hl, wEventStep
	inc [hl]
;=@o
	ld hl, far_SGBSetFieldPalettes
	rst $10
;=@q
	ret


;@ def ClearFloorObjectFlags()
;@ path: event/textbox
;@ Clears bit 5 of every gate floor object (4-byte records in wFloorObjects, $FF ends).
;@ test: skip writes VRAM
ClearFloorObjectFlags::
;> obj = wFloorObjects
	ld de, wFloorObjects

;>@w while mem[obj] != 0xFF:
jr_006_6ac5:
	ld a, [de]
	cp $ff
	ret z

;>     mem[obj] &= ~0x20
	ld a, [de]
	res 5, a
	ld [de], a
;>     obj += 4
	ld a, e
	add $04
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@w
	jr jr_006_6ac5

;@ def StartEventBossBattle()
;@ path: event/textbox
;@ Event $0217: ends the field event and starts the battle with boss wScriptBossIndex of
;@ EventBossBattles (wEncSpecies and $DA04), one opponent, via the battle wipe (wFieldFlags bit 6).
;@ test: skip writes VRAM
StartEventBossBattle::
;> wFieldFlags &= ~0x01
	ld hl, wFieldFlags
	res 0, [hl]
;> wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [$c916], a
;>@p p = EventBossBattles + 2 * wScriptBossIndex
	ld a, [wScriptBossIndex]
	add a
	ld hl, EventBossBattles
	add l
	ld l, a
	ld a, $00
;=@p
	adc h
	ld h, a
;> wEncSpecies = mem[p]; mem[0xDA04] = mem[p + 1]
	ld a, [hli]
	ld [wEncSpecies], a
	ld a, [hl]
	ld [$da04], a
;> wEncCount = 0
	ld a, $00
	ld [wEncCount], a
;> wFieldFlags |= 0x40                      # battle wipe
	ld hl, wFieldFlags
	set 6, [hl]
;> wMenuStep = 0; wBattleKind = 0
	xor a
	ld [wMenuStep], a
	ld a, $00
	ld [wBattleKind], a
	ret

;@ path: event/textbox
;@ Boss of each gate for StartEventBossBattle: (species, $DA04 value) per wScriptBossIndex.
EventBossBattles::
	db $3d, $01, $3e, $01, $3f, $01, $40, $01, $41, $01, $42, $01, $43, $01, $44, $01
	db $44, $01

;@ def EventRestoreBG1()
;@ path: event/textbox
;@ Field event step 12: puts the saved BG tiles back into the box's rows 0 and 4.
;@ test: skip writes VRAM
EventRestoreBG1::
;> wEventStep += 1
	ld hl, wEventStep
	inc [hl]
;> dest = wEventBoxMap
	ld a, [wEventBoxMap]
	ld l, a
	ld a, [$c91a]
	ld h, a
;> RestoreBGRow(dest, wLineScroll, 20)
	ld de, wLineScroll
	ld b, $14
	call RestoreBGRow
;> dest = EventBoxMapAddress(0x80)
	ld hl, $0080
	call EventBoxMapAddress
;> return RestoreBGRow(dest, 0xC150, 20)
	ld de, $c150
	ld b, $14

;@ def RestoreBGRow(dest: hl, buf: de, count: b)
;@ path: event/textbox
;@ Writes `count` saved tiles from `buf` to the BG map from `dest` on (wrapping in the row).
;@ test: skip writes VRAM
RestoreBGRow::
;>@i for i in range(count):
;>     WriteVRAM(dest, mem[buf]); buf += 1
	ld a, [de]
	call WriteVRAM
	inc de
;>     dest = NextBoxMapColumn(dest)
	call NextBoxMapColumn
;=@i
	dec b
	jr nz, RestoreBGRow

;> return
	ret


;@ def EventRestoreBG2()
;@ path: event/textbox
;@ Field event step 15: lifts the sprite clipping and restores rows 1 and 3.
;@ test: skip writes VRAM
EventRestoreBG2::
;> hSpriteClip = 0
	ld a, $00
	ldh [hSpriteClip], a
;> wEventStep += 1
	ld hl, wEventStep
	inc [hl]
;> RestoreBGRow(EventBoxMapAddress(0x20), 0xC114, 20)
	ld hl, $0020
	call EventBoxMapAddress
	ld de, $c114
	ld b, $14
	call RestoreBGRow
;> return RestoreBGRow(EventBoxMapAddress(0x60), 0xC13C, 20)
	ld hl, $0060
	call EventBoxMapAddress
	ld de, $c13c
	ld b, $14
	jr RestoreBGRow

;@ def EventRestoreBG3()
;@ path: event/textbox
;@ Field event step 19: restores the middle row 2.
;@ test: skip writes VRAM
EventRestoreBG3::
;> wEventStep += 1
	ld hl, wEventStep
	inc [hl]
;> return RestoreBGRow(EventBoxMapAddress(0x40), 0xC128, 20)
	ld hl, $0040
	call EventBoxMapAddress
	ld de, $c128
	ld b, $14
	jr RestoreBGRow

;@ def EventEnd()
;@ path: event/textbox
;@ Field event step 20: the event is over (wFieldFlags bit 0 off, step 0).
;@ test: skip writes VRAM
EventEnd::
;> wFieldFlags &= ~0x01
	ld hl, wFieldFlags
	res 0, [hl]
;> wEventStep = 0
	xor a
	ld [wEventStep], a
	ret


;@ def RunFieldTransition()
;@ path: field/doors/transition
;@ wFieldFlags bit 5: one frame (step wMenuStep) of the effect that leads from the field into a
;@ new map. Towns and most maps below $50 (and $52, $60) use the wave (steps 0-6); gate floors and
;@ the other maps from $50 the squeeze and wipe (steps $10-$17).
;@ test: skip drives the LCD effects and writes VRAM
RunFieldTransition::
;> if wMenuStep == 0:
	ld a, [wMenuStep]
	or a
	jr nz, jr_006_6ba7

;>@g     if wOnGateFloor or (wMapId >= 0x50 and wMapId not in (0x52, 0x60)):
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_006_6ba2

	ld a, [wMapId]
	cp $50
	jr c, jr_006_6ba7

;=@g
	cp $52
	jr z, jr_006_6ba7

	cp $60
	jr z, jr_006_6ba7

;>         wMenuStep = 0x10
jr_006_6ba2:
	ld a, $10
	ld [wMenuStep], a

;> return FieldTransitionSteps[wMenuStep]()
jr_006_6ba7:
	ld a, [wMenuStep]
	rst $00

;@ path: field/doors/transition
;@ Transition steps: 0-6 start, blink, wave, wave and fade, load, reset LCD, blink in;
;@ 7-15 unused; $10-$17 start, blink, squeeze, wipe, wave and fade, load, reset LCD, blink in.
FieldTransitionSteps::
	dw TransitionStart
	dw TransitionBlink
	dw TransitionWave
	dw TransitionWaveFade
	dw TransitionLoad
	dw TransitionResetLCD
	dw TransitionBlinkEnd
	dw TransitionNop
	dw TransitionNop
	dw TransitionNop
	dw TransitionNop
	dw TransitionNop
	dw TransitionNop
	dw TransitionNop
	dw TransitionNop
	dw TransitionNop
	dw TransitionStart2
	dw TransitionBlink2
	dw TransitionSqueeze
	dw TransitionWipe
	dw TransitionWaveFade
	dw TransitionLoad
	dw TransitionResetLCD
	dw TransitionBlinkEnd

;@ def TransitionNop()
;@ path: field/doors/transition
;@ Unused transition steps 7-15: nothing.
;@ test: skip (never used)
TransitionNop::
;> return
	ret


;@ def TransitionStart()
;@ path: field/doors/transition
;@ Step 0 of the wave: music 2, sound $52, scroll rounded to tiles, the base BG map address of the
;@ view in $C90B, the 12 x 16 tiles right of the view blanked, every line of the line-scroll table
;@ wLineScroll set to hScrollX, and $1E blink frames.
;@ test: skip drives the LCD effects and writes VRAM
TransitionStart::
;> QueueMusic(2); InitSound()
	ld a, $02
	call QueueMusic
	call InitSound
;> QueueSound(0x52)
	ld a, $52
	call QueueSound
;> RoundScroll3(hScrollX)
	ld hl, hScrollX
	call RoundScroll3
;> RoundScroll3(hScrollY)
	ld hl, hScrollY
	call RoundScroll3
;> FillMemory(wMenuChoice, 8, 0)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@t t = 0x9800 + hScrollY * 4 + (hScrollX >> 3)
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@t
	rrca
	rrca
	rrca
	add l
	ld l, a
;=@t
	ld a, h
	adc $98
	ld h, a
;>@m mem16[0xC90B] = 0x9800 | (t & 0x3FF)    # the view's top left in the BG map
	ld a, h
	and $03
	or $98
	ld h, a
;=@m
	ld a, l
	ld [$c90b], a
	ld a, h
	ld [wCursorBlink], a
;> pos = 0x14; rows = 16                  # right of the view
	ld hl, $0014
	ld b, $10

;>@r for row in range(rows):
jr_006_6c25:
	push bc
	push hl
;>@c     for col in range(12):
	ld b, $0c

;>         ClearMapTile(pos + col)
jr_006_6c29:
	push bc
	push hl
	call ClearMapTile
	pop hl
	inc hl
	pop bc
;=@c
	dec b
	jr nz, jr_006_6c29

;>@x     pos += 0x20
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
;=@x
	ld h, a
;=@r
	pop bc
	dec b
	jr nz, jr_006_6c25

;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> line = wLineScroll
	ld hl, wLineScroll
;>@l for i in range(0x80):
	ld b, $80

;>     mem[line] = hScrollX; line += 1
jr_006_6c4a:
	ldh a, [hScrollX]
	ld [hli], a
;=@l
	dec b
	jr nz, jr_006_6c4a

;> wMenuSubStep = 0x1E
	ld a, $1e
	ld [wMenuSubStep], a
	ret


;@ def TransitionBlink()
;@ path: field/doors/transition
;@ Step 1: blinks the menu overlay every frame for wMenuSubStep frames, then starts the wave
;@ (amplitude 1 in wItemsHandedIn, the line-scroll LCD effect 2 from line 2).
;@ test: skip drives the LCD effects and writes VRAM
TransitionBlink::
;> wMenuOverlay = wMenuSubStep & 1
	ld a, [wMenuSubStep]
	and $01
	ld [wMenuOverlay], a
;> wMenuSubStep -= 1
	ld a, [wMenuSubStep]
	dec a
	ld [wMenuSubStep], a
;> if wMenuSubStep: return
	ret nz

;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> wItemsHandedIn = 1                       # wave amplitude
	ld a, $01
	ld [wItemsHandedIn], a
;> rLYC = 2; wLCDEffect = 2                 # line scroll on
	di
	ld a, $02
	ldh [rLYC], a
	ld a, $02
	ld [wLCDEffect], a
	ei
;> return
	ret


;@ def TransitionWave()
;@ path: field/doors/transition
;@ Step 2: every 8 frames the wave amplitude grows by amp / 16 + 1; at $38 the fade begins.
;@ test: skip drives the LCD effects and writes VRAM
TransitionWave::
;> wMenuOverlay = 1
	ld a, $01
	ld [wMenuOverlay], a
;> if wFieldTimer & 7 == 0:
	ld a, [wFieldTimer]
	and $07
	jr nz, UpdateWaveScroll

;>     step = (wItemsHandedIn >> 4) + 1
	ld a, [wItemsHandedIn]
	swap a
	and $0f
	inc a
	ld b, a
;>     wItemsHandedIn += step
	ld a, [wItemsHandedIn]
	add b
	ld [wItemsHandedIn], a
;>     if wItemsHandedIn >= 0x38:
	cp $38
	jr c, UpdateWaveScroll

;>         wMenuStep += 1; wHatchSlot = 0
	ld hl, wMenuStep
	inc [hl]
	xor a
	ld [wHatchSlot], a

;@ def UpdateWaveScroll()
;@ path: field/doors/transition
;@ Updates a quarter of wLineScroll (32 lines, which one by wFieldTimer & 3): every pair of lines
;@ gets hScrollX +/- WaveOffsets[e] * amplitude / 256 (minus in the second half of the wave),
;@ with e stepping along the 16-entry wave from (wFieldTimer >> 2).
;@ test: skip drives the LCD effects and writes VRAM
UpdateWaveScroll::
;> mem[hNumber] = wItemsHandedIn            # amplitude
	ld a, [wItemsHandedIn]
	ldh [hNumber], a
;> e = (wFieldTimer >> 2) & 0x0F
	ld a, [wFieldTimer]
	rra
	rra
	and $0f
	ld e, a
	ld d, $00
;> q = wFieldTimer & 3
	ld a, [wFieldTimer]
	and $03
;> if q == 0:
	cp $00
	jr nz, jr_006_6cc5

;>     line = wLineScroll; mem[hNumber + 1] = 0x20   # (low byte of the end)
	ld bc, wLineScroll
	ld a, $20
	ldh [$ffd6], a
	jp Jump_006_6ce8


;> elif q == 1:
jr_006_6cc5:
	cp $01
	jr nz, jr_006_6cd3

;>     line = 0xC120; mem[hNumber + 1] = 0x40
	ld bc, $c120
	ld a, $40
	ldh [$ffd6], a
	jp Jump_006_6ce8


;> elif q == 2:
jr_006_6cd3:
	cp $02
	jr nz, jr_006_6ce1

;>     line = 0xC140; mem[hNumber + 1] = 0x60
	ld bc, $c140
	ld a, $60
	ldh [$ffd6], a
	jp Jump_006_6ce8


;> else:
;>     line = 0xC160; mem[hNumber + 1] = 0x80
jr_006_6ce1:
	ld bc, $c160
	ld a, $80
	ldh [$ffd6], a

;>@w while True:
;>     e = (e + 1) & 0x0F
Jump_006_6ce8:
jr_006_6ce8:
	inc e
	ld a, e
	and $0f
	ld e, a
;>     h = (WaveOffsets[e] * mem[hNumber]) >> 8
	ld hl, WaveOffsets
	add hl, de
	push bc
	ld c, [hl]
	ldh a, [hNumber]
	call Multiply
;>     if e & 0x08:
	pop bc
	bit 3, e
	jr z, jr_006_6d02

;>         x = hScrollX - h
	ldh a, [hScrollX]
	sub h
;>     else:
	jr jr_006_6d05

;>         x = hScrollX + h
jr_006_6d02:
	ldh a, [hScrollX]
	add h

;>     mem[line] = x; mem[line + 1] = x; line += 2
jr_006_6d05:
	ld [bc], a
	inc c
	ld [bc], a
	inc c
;>     if line & 0xFF == mem[hNumber + 1]: return
	ldh a, [$ffd6]
	cp c
;=@w
	jr nz, jr_006_6ce8

	ret

;@ path: field/doors/transition
;@ The wave of UpdateWaveScroll: 16 offsets (0-255, scaled by the amplitude), half a sine twice.
WaveOffsets::
	db $00, $60, $b6, $ec, $ff, $ec, $b6, $60, $00, $60, $b6, $ec, $ff, $ec, $b6, $60

;@ def TransitionWaveFade()
;@ path: field/doors/transition
;@ Steps 3 and $14: keeps the wave going while the BG palette fades through FadePalettes, one
;@ step every 16 frames; after the 4th the line effect is turned off and the next step follows.
;@ test: skip drives the LCD effects and writes VRAM
TransitionWaveFade::
;> if wFieldTimer & 0x0F == 0:
	ld a, [wFieldTimer]
	and $0f
	jr nz, jr_006_6d3a

;>     wHatchSlot += 1
	ld a, [wHatchSlot]
	inc a
	ld [wHatchSlot], a
;>     if wHatchSlot == 4:
	cp $04
	jr nz, jr_006_6d3a

;>         wMenuStep += 1; wLCDEffect = 0
	ld hl, wMenuStep
	inc [hl]
	ld a, $00
	ld [wLCDEffect], a

;>@p wBGP = FadePalettes[wHatchSlot]
jr_006_6d3a:
	ld a, [wHatchSlot]
	ld hl, FadePalettes
	add l
	ld l, a
	ld a, $00
	adc h
;=@p
	ld h, a
	ld a, [hl]
	ld [wBGP], a
;> UpdateWaveScroll()
	call UpdateWaveScroll
	ret

;@ path: field/doors/transition
;@ BG palettes of TransitionWaveFade, from normal to black-free white.
FadePalettes::
	db $d2, $81, $40, $00, $00

;@ def TransitionLoad()
;@ path: field/doors/transition
;@ Steps 4 and $15: asks for the new map (wMapLoadState), blanks all palettes and hides the
;@ sprites for $28 frames. When the warp goes to map 0 (not a gate floor) and $D92B is not 1-5,
;@ the transition ends right here.
;@ test: skip drives the LCD effects and writes VRAM
TransitionLoad::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
;> wMenuSubStep = 0x28
	ld a, $28
	ld [wMenuSubStep], a
;> wBGP = 0; wOBP0 = 0
	ld a, $00
	ld [wBGP], a
	ld a, $00
	ld [wOBP0], a
;> wOBP1 = 0
	ld a, $00
	ld [wOBP1], a
;> wMenuOverlay = 1
	ld a, $01
	ld [wMenuOverlay], a
;> if wWarpOnGateFloor: return
	ld a, [wWarpOnGateFloor]
	or a
	ret nz

;> if wWarpMap: return
	ld a, [wWarpMap]
	or a
	ret nz

;>@d if mem[0xD92B] in (1, 2, 3, 4, 5): return
	ld a, [wHomeWarpCause]
	cp $01
	ret z

	cp $02
	ret z

;=@d
	cp $03
	ret z

	cp $04
	ret z

	cp $05
	ret z

;> wMenuOverlay = 0
	ld a, $00
	ld [wMenuOverlay], a
;> wFieldFlags &= ~0x20; wMenuStep = 0      # done
	ld hl, wFieldFlags
	res 5, [hl]
	xor a
	ld [wMenuStep], a
;> rLYC = 0x7F; wLCDEffect = 1
	di
	ld a, $7f
	ldh [rLYC], a
	ld a, $01
	ld [wLCDEffect], a
	ei
;> return
	ret

;@ path: unused
;@ Unreachable code (no caller), kept as bytes: two more transition steps - a reverse fade
;@ (FadePalettes backwards, every 16 frames, with UpdateWaveScroll) and a shrinking wave
;@ (amplitude down by amp / 16 + 1 every 8 frames) - left over from an earlier version.
UnusedCode_06_6DAA::
	db $3e, $00, $ea, $9b, $c8, $f3, $3e, $02, $e0, $45, $3e, $02, $ea, $92, $c8, $fb
	db $21, $05, $c9, $34, $c9, $fa, $a6, $c8, $e6, $0f, $20, $0f, $fa, $08, $c9, $3d
	db $ea, $08, $c9, $fe, $00, $20, $04, $21, $05, $c9, $34, $fa, $08, $c9, $21, $4e
	db $6d, $85, $6f, $3e, $00, $8c, $67, $7e, $ea, $9b, $c8, $cd, $a3, $6c, $c9, $fa
	db $a6, $c8, $e6, $07, $20, $1f, $fa, $07, $c9, $cb, $37, $e6, $0f, $3c, $47, $fa
	db $07, $c9, $90, $ea, $07, $c9, $30, $0d, $21, $05, $c9, $34, $af, $ea, $07, $c9
	db $3e, $3c, $ea, $06, $c9, $c3, $a3, $6c

;@ def TransitionResetLCD()
;@ path: field/doors/transition
;@ Steps 5 and $16: back to the normal LCD interrupt (line $7F, effect 1); on gate floors Terry's
;@ flags are cleared.
;@ test: skip drives the LCD effects and writes VRAM
TransitionResetLCD::
;> rLYC = 0x7F; wLCDEffect = 1
	di
	ld a, $7f
	ldh [rLYC], a
	ld a, $01
	ld [wLCDEffect], a
	ei
;> if wOnGateFloor: hPlayerFlags = 0
	ld a, [wOnGateFloor]
	or a
	jr z, jr_006_6e26

	xor a
	ldh [hPlayerFlags], a

;> wMenuStep += 1
jr_006_6e26:
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def TransitionBlinkEnd()
;@ path: field/doors/transition
;@ Steps 6 and $17: once the fade-in is over, blinks the overlay for wMenuSubStep frames and ends
;@ the transition (wFieldFlags bit 5 off).
;@ test: skip drives the LCD effects and writes VRAM
TransitionBlinkEnd::
;> if wFadeState: return
	ld a, [wFadeState]
	or a
	ret nz

;> wMenuOverlay = wMenuSubStep & 1
	ld a, [wMenuSubStep]
	and $01
	ld [wMenuOverlay], a
;> wMenuSubStep -= 1
	ld a, [wMenuSubStep]
	dec a
	ld [wMenuSubStep], a
;> if wMenuSubStep: return
	ret nz

;> wMenuOverlay = 0; wMenuStep = 0
	ld a, $00
	ld [wMenuOverlay], a
	xor a
	ld [wMenuStep], a
;> wFieldFlags &= ~0x20
	ld hl, wFieldFlags
	res 5, [hl]
	ret


;@ def RoundScroll3(p: hl)
;@ path: field/doors/transition
;@ Same as RoundScroll: rounds the u16 scroll value at `p` to the nearest multiple of 8.
;@ test: skip drives the LCD effects and writes VRAM
RoundScroll3::
;> mem16[p] += 4
	ld a, [hl]
	add $04
	ld [hli], a
	ld a, [hl]
	adc $00
	ld [hld], a
;> mem[p] &= 0xF8
	ld a, [hl]
	and $f8
	ld [hl], a
	ret


;@ def NextTransitionMapColumn(dest: hl) -> hl
;@ path: field/doors/transition
;@ Same as NextBoxMapColumn: one BG map column right, wrapping inside the row (keeps a).
;@ test: skip drives the LCD effects and writes VRAM
NextTransitionMapColumn::
;>@c dest = (dest & ~0x1F) | ((dest + 1) & 0x1F)
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;=@c
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
;> return dest
	pop af
	ret


;@ def TransitionMapAddress(offset: hl) -> hl
;@ path: field/doors/transition
;@ BG map address mem16[$C90B] (the view's top left) + offset, wrapped inside the 1 KiB map.
;@ test: skip drives the LCD effects and writes VRAM
TransitionMapAddress::
;>@a a = mem16[0xC90B] + offset
	ld a, [$c90b]
	add l
	ld l, a
	ld a, [wCursorBlink]
	adc h
	and $03
;=@a
	ld h, a
;> return (mem16[0xC90B] & 0xFC00) | (a & 0x3FF)
	ld a, [wCursorBlink]
	and $fc
	or h
	ld h, a
	ret


;@ def ClearMapTile(pos: hl)
;@ path: field/doors/transition
;@ Writes the blank tile $E0 at view position `pos` (row * 32 + column).
;@ test: skip drives the LCD effects and writes VRAM
ClearMapTile::
;> WriteVRAM(TransitionTileAddress(pos), 0xE0)
	call TransitionTileAddress
	ld a, $e0
	call WriteVRAM
	ret


;@ def TransitionTileAddress(pos: hl) -> hl
;@ path: field/doors/transition
;@ BG map address of view position `pos` (row * 32 + column), wrapping both ways.
;@ test: skip drives the LCD effects and writes VRAM
TransitionTileAddress::
;> col = pos & 0x1F
	push bc
	ld b, l
;> dest = TransitionMapAddress(pos & ~0x1F)
	ld a, l
	and $e0
	ld l, a
	call TransitionMapAddress
;> col = col & 0x1F
	ld a, b
	and $1f
;> if col:
	jr z, jr_006_6e9d

;>@i     for i in range(col):
	ld b, a

;>         dest = NextTransitionMapColumn(dest)
jr_006_6e97:
	call NextTransitionMapColumn
;=@i
	dec b
	jr nz, jr_006_6e97

;> return dest
jr_006_6e9d:
	pop bc
	ret


;@ def TransitionStart2()
;@ path: field/doors/transition
;@ Step $10 (gate floors and the like): sound $55, scroll rounded to tiles, the view base in
;@ $C90B, the 20 x 14 tiles below the view (from row 18) blanked, every line of wLineScroll set to
;@ hScrollY, $1E blink frames, and the party bar shown in the window.
;@ test: skip drives the LCD effects and writes VRAM
TransitionStart2::
;> QueueSound(0x55)
	ld a, $55
	call QueueSound
;> RoundScroll3(hScrollX)
	ld hl, hScrollX
	call RoundScroll3
;> RoundScroll3(hScrollY)
	ld hl, hScrollY
	call RoundScroll3
;> FillMemory(wMenuChoice, 8, 0)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@t t = 0x9800 + hScrollY * 4 + (hScrollX >> 3)
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@t
	rrca
	rrca
	rrca
	add l
	ld l, a
;=@t
	ld a, h
	adc $98
	ld h, a
;>@m mem16[0xC90B] = 0x9800 | (t & 0x3FF)
	ld a, h
	and $03
	or $98
	ld h, a
;=@m
	ld a, l
	ld [$c90b], a
	ld a, h
	ld [wCursorBlink], a
;> pos = 0x240; rows = 14                  # from row 18, below the view
	ld hl, $0240
	ld b, $0e

;>@r for row in range(rows):
jr_006_6ee0:
	push bc
	push hl
;>@c     for col in range(20):
	ld b, $14

;>         ClearMapTile(pos + col)
jr_006_6ee4:
	push bc
	push hl
	call ClearMapTile
	pop hl
	inc hl
	pop bc
;=@c
	dec b
	jr nz, jr_006_6ee4

;>@x     pos += 0x20
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
;=@x
	ld h, a
;=@r
	pop bc
	dec b
	jr nz, jr_006_6ee0

;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> line = wLineScroll
	ld hl, wLineScroll
;>@l for i in range(0x80):
	ld b, $80

;>     mem[line] = hScrollY; line += 1
jr_006_6f05:
	ldh a, [hScrollY]
	ld [hli], a
;=@l
	dec b
	jr nz, jr_006_6f05

;> wMenuSubStep = 0x1E
	ld a, $1e
	ld [wMenuSubStep], a
;> ShowPartyBarWindow2()
	call ShowPartyBarWindow2
	ret


;@ def TransitionBlink2()
;@ path: field/doors/transition
;@ Step $11: blinks the menu overlay for wMenuSubStep frames, then starts the squeeze (speed 0 in
;@ wItemsHandedIn/wHatchSlot, the per-line Y scroll effect 3 from line 2).
;@ test: skip drives the LCD effects and writes VRAM
TransitionBlink2::
;> wMenuOverlay = wMenuSubStep & 1
	ld a, [wMenuSubStep]
	and $01
	ld [wMenuOverlay], a
;> wMenuSubStep -= 1
	ld a, [wMenuSubStep]
	dec a
	ld [wMenuSubStep], a
;> if wMenuSubStep: return
	ret nz

;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> speed = 0                                # u16 in wItemsHandedIn, wHatchSlot
	ld hl, $0000
	ld a, l
	ld [wItemsHandedIn], a
	ld a, h
	ld [wHatchSlot], a
;> rLYC = 2; wLCDEffect = 3
	di
	ld a, $02
	ldh [rLYC], a
	ld a, $03
	ld [wLCDEffect], a
	ei
;> return
	ret


;@ def TransitionSqueeze()
;@ path: field/doors/transition
;@ Step $12: fills wLineScroll from the middle line (64) outwards with Y scroll values that pull
;@ the picture apart, each line by the accumulated speed (lines past $7C show blank rows); the
;@ speed grows by speed / 8 + 2 per frame until its high byte reaches $20.
;@ test: skip drives the LCD effects and writes VRAM
TransitionSqueeze::
;> y = hScrollY + 0x20; wTextArg0 = y      # lines 128-131
	ldh a, [hScrollY]
	add $20
	ld [wTextArg0], a
;> mem[0xC181] = y; mem[0xC182] = y
	ld [$c181], a
	ld [$c182], a
;> mem[0xC183] = y
	ld [$c183], a
;> wMenuOverlay = 1
	ld a, $01
	ld [wMenuOverlay], a
;> acc = 0; down = 0xC140; up = 0xC140     # from the middle line
	ld hl, $0000
	ld de, $c140
	ld bc, $c140

;>@w while True:
;>     if (acc >> 8) + (down & 0xFF) >= 0x7C:
jr_006_6f5d:
	ld a, h
	add e
	cp $7c
	jr c, jr_006_6f73

;>         mem[down] = hScrollY + 0x98 - (down & 0xFF); down += 1
	ldh a, [hScrollY]
	add $98
	sub e
	ld [de], a
	inc de
;>         up -= 1; mem[up] = hScrollY - 8 - (up & 0xFF)
	dec bc
	ldh a, [hScrollY]
	sub $08
	sub c
	ld [bc], a
;>     else:
	jr jr_006_6f87

;>         acc += speed
jr_006_6f73:
	ld a, [wItemsHandedIn]
	add l
	ld l, a
	ld a, [wHatchSlot]
	adc h
	ld h, a
;>         mem[down] = hScrollY + (acc >> 8); down += 1
	ldh a, [hScrollY]
	add h
	ld [de], a
	inc de
;>         up -= 1; mem[up] = hScrollY - (acc >> 8)
	dec bc
	ldh a, [hScrollY]
	sub h
	ld [bc], a

;>     if up & 0xFF == 0: break
jr_006_6f87:
	ld a, c
	or a
;=@w
	jr nz, jr_006_6f5d

;> speed = mem16[wItemsHandedIn]
	ld a, [wItemsHandedIn]
	ld l, a
	ld a, [wHatchSlot]
	ld h, a
;> if speed >> 8 < 0x20:
	ld a, h
	cp $20
	jr nc, jr_006_6fbe

;>@s     t = (speed >> 3) + 2
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
;=@s
	ld a, l
	add $02
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>     t += speed
	ld a, [wItemsHandedIn]
	ld c, a
	ld a, [wHatchSlot]
	ld b, a
	add hl, bc
;>     mem16[wItemsHandedIn] = t; return
	ld a, l
	ld [wItemsHandedIn], a
	ld a, h
	ld [wHatchSlot], a
	ret


;> else:
;>     wMenuStep += 1; wHatchSlot = 0
jr_006_6fbe:
	ld hl, wMenuStep
	inc [hl]
	xor a
	ld [wHatchSlot], a
	ret


;@ def TransitionWipe()
;@ path: field/doors/transition
;@ Step $13: blanks two 16-tile columns per frame, closing in from both edges of the view
;@ (columns n and $13 - n); after 10 frames the scroll and LCD interrupt are back to normal.
;@ test: skip drives the LCD effects and writes VRAM
TransitionWipe::
;>@p dest = TransitionTileAddress(wHatchSlot)   # column n
	ld hl, $0000
	ld a, [wHatchSlot]
	add l
	ld l, a
	ld a, $00
	adc h
;=@p
	ld h, a
	call TransitionTileAddress
;>@i for i in range(16):
	ld b, $10

;>     WriteVRAM(dest, 0xE0)
jr_006_6fd8:
	ld a, $e0
	call WriteVRAM
;>     dest += 0x20
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@i
	dec b
	jr nz, jr_006_6fd8

;>@q dest = TransitionTileAddress(0x13 - wHatchSlot)   # column $13 - n
	ld hl, $0013
	ld a, [wHatchSlot]
	ld b, a
	ld a, l
	sub b
	ld l, a
;=@q
	ld a, h
	sbc $00
	ld h, a
	call TransitionTileAddress
;>@j for i in range(16):
	ld b, $10

;>     WriteVRAM(dest, 0xE0)
jr_006_6ffb:
	ld a, $e0
	call WriteVRAM
;>     dest += 0x20
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@j
	dec b
	jr nz, jr_006_6ffb

;> wHatchSlot += 1
	ld hl, wHatchSlot
	inc [hl]
;> if wHatchSlot != 0x0A: return
	ld a, [wHatchSlot]
	cp $0a
	ret nz

;> wMenuStep += 1; wHatchSlot = 0
	ld hl, wMenuStep
	inc [hl]
	xor a
	ld [wHatchSlot], a
;> rSCY = hScrollY; hWY = 0xFF
	ldh a, [hScrollY]
	ldh [rSCY], a
	ld a, $ff
	ldh [hWY], a
;> rLYC = 0x7F; wLCDEffect = 1
	di
	ld a, $7f
	ldh [rLYC], a
	ld a, $01
	ld [wLCDEffect], a
	ei
;> return
	ret


;@ def ShowPartyBarWindow2()
;@ path: field/partybar
;@ Same as ShowPartyBarWindow with DrawPartyBarAt built in: the party bar in the window at line
;@ $80 (map $9C00), palette 7 on the Game Boy Color.
;@ test: skip writes VRAM
ShowPartyBarWindow2::
;> hWY = 0x80
	ld a, $80
	ldh [hWY], a
;> CopyPartyBarTiles2(0x9C00)
	ld hl, $9c00
	push hl
	call CopyPartyBarTiles2
	pop hl
;> if not wOnCGB: return
	ld a, [wOnCGB]
	or a
	ret z

;> WaitVRAMAccess(); rVBK = 1              # attribute bank
	di
	call WaitVRAMAccess
	ld a, $01
	ldh [rVBK], a
	ei
;>@o for row in range(2):
	ld c, $02

;>@r     for col in range(20):
jr_006_704d:
	ld b, $14
	push hl

;>         WriteVRAM(dest, 7)
jr_006_7050:
	ld a, $07
	call WriteVRAM
;>@c         dest = (dest & ~0x1F) | ((dest + 1) & 0x1F)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@c
	ld l, a
	pop af
	or l
	ld l, a
	inc de
;=@r
	dec b
	jr nz, jr_006_7050

;>@q     src += 12                            # (unused here)
	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
;=@q
	ld d, a
;>@s     dest = (dest & 0xFC00) | ((dest + 0x20) & 0x3FF)
	push bc
	ld bc, $0020
	ld a, h
	add hl, bc
	and $fc
	ld b, a
;=@s
	ld a, h
	and $03
	or b
	ld h, a
	pop bc
;=@o
	dec c
	jr nz, jr_006_704d

;> WaitVRAMAccess(); rVBK = 0
	di
	call WaitVRAMAccess
	ld a, $00
	ldh [rVBK], a
	ei
	ret


;@ def CopyPartyBarTiles2(dest: hl)
;@ path: field/partybar
;@ Same as CopyPartyBarTiles: the two party bar rows (20 tiles each) to the map at `dest`.
;@ test: skip writes VRAM
CopyPartyBarTiles2::
;> src = wPartyBarTiles
	ld de, wPartyBarTiles
;>@o for row in range(2):
	ld c, $02

;>@r     for col in range(20):
jr_006_708f:
	ld b, $14
	push hl

;>         WriteVRAM(dest, mem[src])
jr_006_7092:
	ld a, [de]
	call WriteVRAM
;>@c         dest = (dest & ~0x1F) | ((dest + 1) & 0x1F)   # wraps in the row
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@c
	ld l, a
	pop af
	or l
	ld l, a
;>         src += 1
	inc de
;=@r
	dec b
	jr nz, jr_006_7092

;>@q     src += 12                            # to the next 32-tile row
	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
;=@q
	ld d, a
;>@s     dest = (dest & 0xFC00) | ((dest + 0x20) & 0x3FF)   # next row
	push bc
	ld bc, $0020
	ld a, h
	add hl, bc
	and $fc
	ld b, a
;=@s
	ld a, h
	and $03
	or b
	ld h, a
	pop bc
;=@o
	dec c
	jr nz, jr_006_708f

;> return
	ret

;@ path: unused
;@ Unreferenced bytes from $70C3 to the end of the bank: about 2.3 KiB that look like leftover
;@ compressed graphics, then $FF filler and the bank number $06 in the last byte.
UnusedData_06_70C3::
	db $08, $0f, $fe, $56, $02, $1f, $10, $3f, $24, $7f, $48, $7f, $ff, $5a, $7f, $32
	db $7f, $14, $3f, $0d, $1f, $ff, $03, $07, $80, $ff, $00, $ff, $02, $ff, $ff, $13
	db $ff, $1f, $fc, $1f, $f0, $1f, $f1, $ff, $0f, $f9, $0f, $fa, $0f, $f9, $27, $fc
	db $ff, $a7, $fc, $93, $fe, $93, $fe, $1f, $fc, $df, $f7, $fb, $01, $ff, $49, $8f
	db $00, $ff, $ff, $bf, $fa, $af, $fc, $8e, $f8, $08, $9a, $00, $28, $ff, $fc, $ac
	db $fe, $62, $fe, $0a, $fe, $46, $bf, $fc, $a4, $f8, $18, $e6, $e6, $fc, $39, $0e
	db $ff, $0f, $0b, $0c, $05, $0e, $02, $07, $03, $ff, $03, $03, $02, $02, $03, $05
	db $07, $05, $ff, $07, $07, $07, $1c, $34, $3f, $7f, $42, $ff, $7f, $42, $ff, $a3
	db $ff, $9c, $fe, $70, $ff, $f8, $20, $e0, $60, $b0, $f0, $10, $e0, $ff, $f0, $e0
	db $a0, $fc, $fe, $1a, $e6, $02, $ff, $fe, $fe, $fe, $0e, $0a, $fa, $f6, $f4, $9f
	db $8e, $f8, $bc, $c0, $e0, $38, $0f, $02, $17, $18, $ff, $3c, $25, $7f, $4e, $fb
	db $8f, $fe, $bb, $df, $ce, $b1, $db, $60, $f1, $02, $19, $0e, $1a, $ff, $1f, $3f
	db $21, $3f, $21, $7f, $d1, $ff, $ff, $ce, $7f, $b8, $7c, $54, $ae, $da, $27, $ff
	db $af, $dd, $75, $ff, $03, $06, $01, $03, $fb, $00, $01, $02, $11, $07, $05, $fd
	db $fb, $7a, $df, $c7, $7c, $de, $e0, $f0, $02, $11, $38, $7c, $ff, $74, $4c, $f4
	db $cc, $c8, $7c, $90, $f8, $fb, $20, $f0, $f6, $05, $60, $f0, $90, $f8, $88, $ff
	db $fc, $a4, $de, $b2, $cf, $59, $e7, $2c, $9f, $73, $1b, $3c, $06, $0f, $46, $10
	db $45, $06, $30, $ff, $78, $48, $78, $48, $7c, $44, $7c, $24, $ff, $7c, $24, $3e
	db $12, $be, $8a, $de, $4a, $ff, $ef, $a5, $77, $d5, $bf, $6a, $ff, $16, $7f, $3f
	db $0b, $1f, $05, $0f, $02, $07, $02, $1f, $fa, $b1, $10, $80, $c3, $10, $c0, $40
	db $c0, $40, $e0, $fb, $e0, $f0, $6e, $08, $f1, $1f, $f2, $0d, $fa, $fb, $0f, $f8
	db $80, $05, $9f, $fe, $21, $ff, $e2, $fd, $ff, $8e, $06, $0f, $fc, $8e, $f9, $09
	db $b9, $ff, $c9, $d9, $69, $fd, $ad, $ff, $63, $fe, $ff, $0b, $fd, $c7, $fe, $46
	db $f8, $2c, $f0, $fd, $f8, $c3, $00, $07, $07, $0c, $0b, $1d, $7f, $ff, $79, $af
	db $d8, $7f, $88, $f7, $0c, $bc, $ff, $47, $cf, $33, $7e, $9d, $bf, $de, $77, $ff
	db $df, $7a, $57, $6e, $5b, $3d, $6b, $10, $7f, $f0, $20, $f8, $98, $64, $dc, $ae
	db $34, $20, $ff, $22, $dc, $22, $b8, $44, $c6, $fa, $7e, $ff, $b2, $f6, $ca, $ea
	db $36, $dc, $ec, $f0, $ff, $58, $e0, $70, $80, $c0, $22, $7f, $22, $fb, $3f, $1f
	db $53, $00, $17, $3f, $2a, $75, $56, $ff, $69, $3d, $62, $1f, $38, $0f, $1f, $1a
	db $ff, $37, $34, $2e, $3f, $7f, $43, $7c, $40, $ff, $7f, $7f, $7f, $f8, $88, $b8
	db $cc, $f4, $ff, $fe, $8b, $df, $4b, $cd, $cb, $6d, $a9, $ff, $6e, $e9, $2e, $c9
	db $6e, $88, $cf, $0b, $ff, $0c, $0b, $0d, $8b, $cc, $47, $cf, $40, $ff, $c0, $c0
	db $c0, $1a, $3d, $04, $06, $00, $fb, $00, $fe, $ed, $10, $8f, $71, $ef, $95, $ff
	db $e7, $e5, $9e, $df, $c7, $11, $8b, $20, $40, $80, $c0, $f4, $b1, $11, $0e, $21
	db $04, $5b, $00, $78, $7f, $af, $d9, $fc, $1a, $2f, $2c, $23, $00, $fc, $00, $fe
	db $00, $fe, $f8, $36, $21, $3c, $2f, $6e, $24, $cf, $45, $ce, $c5, $66, $ff, $a2
	db $67, $e2, $23, $c1, $63, $81, $c1, $f8, $48, $11, $c6, $12, $8b, $26, $80, $c0
	db $e0, $f0, $98, $ff, $fc, $c4, $7e, $72, $be, $3a, $ce, $76, $7f, $9e, $ec, $b6
	db $b8, $cc, $70, $f8, $b1, $13, $ff, $1f, $3f, $2f, $70, $5f, $60, $7f, $c0, $ff
	db $bf, $c0, $ff, $80, $ff, $80, $df, $b8, $ff, $ff, $a1, $ef, $b0, $ff, $98, $77
	db $c8, $ff, $5f, $60, $2f, $70, $1f, $38, $0b, $1d, $ff, $e0, $e0, $d0, $30, $f8
	db $08, $fc, $24, $bf, $fc, $54, $fc, $44, $fc, $84, $5a, $30, $14, $ff, $fe, $d6
	db $ff, $31, $ff, $05, $ff, $23, $3f, $fe, $52, $fc, $0c, $f3, $f3, $6e, $06, $75
	db $32, $7d, $0f, $7b, $32, $27, $ff, $a7, $ff, $93, $85, $30, $ef, $1e, $ff, $f0
	db $f8, $8e, $06, $ff, $fc, $fe, $be, $e2, $00, $f0, $f0, $f8, $f8, $fc, $a1, $31
	db $f8, $f9, $fc, $56, $13, $5a, $10, $3c, $3c, $3e, $06, $0f, $fd, $79, $6b, $20
	db $02, $07, $02, $03, $1e, $1f, $ff, $1d, $33, $37, $2f, $34, $2c, $34, $6c, $ff
	db $74, $4c, $74, $4c, $64, $dc, $e4, $9c, $cf, $e4, $9c, $88, $fc, $26, $35, $db
	db $3f, $01, $03, $fd, $02, $ef, $30, $82, $c3, $42, $e3, $21, $f3, $fe, $7a, $30
	db $fa, $ef, $fb, $2a, $7e, $4c, $7e, $f7, $48, $f8, $88, $05, $00, $90, $f8, $60
	db $f0, $df, $0e, $1f, $d1, $ff, $20, $71, $00, $8a, $ff, $ff, $bf, $ff, $e9, $ff
	db $bb, $cf, $7f, $8b, $ff, $fe, $07, $b4, $cf, $4b, $ff, $3d, $7b, $f1, $06, $91
	db $20, $be, $16, $c3, $10, $bc, $be, $42, $7f, $ff, $b9, $c7, $c1, $3f, $01, $ff
	db $71, $ff, $fb, $8d, $df, $ac, $15, $0c, $0e, $0e, $0e, $06, $7f, $0f, $3b, $3f
	db $3d, $3f, $07, $0f, $f0, $31, $f4, $be, $3d, $ea, $3d, $ff, $fb, $30, $8f, $fb
	db $7a, $fe, $fb, $0c, $0e, $6a, $17, $89, $fb, $8a, $fb, $4a, $ff, $7b, $ca, $fb
	db $4a, $fb, $29, $fb, $2f, $9e, $fb, $30, $cf, $fb, $3a, $7e, $86, $05, $0e, $0b
	db $b9, $f7, $cf, $79, $8f, $20, $0b, $42, $3c, $8b, $46, $ff, $05, $83, $05, $83
	db $4d, $83, $39, $c7, $0f, $83, $7e, $7e, $3c, $dc, $3d, $18, $88, $03, $07, $1f
	db $3f, $3d, $23, $3f, $3f, $14, $8c, $18, $38, $38, $68, $e8, $d8, $d0, $b8, $e0
	db $f0, $00, $80, $ff, $a6, $01, $00, $60, $80, $82, $7c, $05, $02, $20, $1f, $52
	db $21, $21, $40, $21, $40, $84, $7b, $41, $32, $20, $13, $82, $7c, $d0, $20, $08
	db $f0, $32, $cc, $98, $63, $8d, $02, $40, $3c, $20, $c0, $06, $84, $88, $70, $14
	db $88, $04, $8c, $88, $70, $72, $8c, $7d, $82, $be, $41, $46, $39, $0b, $04, $ff
	db $04, $44, $0f, $44, $f0, $44, $0f, $7f, $44, $f0, $0c, $ff, $d0, $02, $fd, $00
	db $ee, $36, $03, $07, $07, $05, $05, $0f, $ff, $0e, $0b, $0a, $1e, $1c, $16, $14
	db $3c, $ff, $38, $2c, $28, $78, $70, $58, $50, $f0, $fe, $ee, $33, $01, $03, $0f
	db $1e, $7e, $f1, $f7, $7f, $8f, $fe, $ff, $10, $1f, $1f, $1f, $ee, $37, $ff, $00
	db $00, $42, $e3, $21, $f1, $50, $b8, $ff, $f8, $f8, $fe, $06, $f7, $f9, $fd, $fe
	db $ff, $0e, $ff, $03, $ff, $e3, $ff, $11, $3f, $ff, $09, $1f, $04, $0f, $0e, $1f
	db $17, $3d, $ff, $05, $1f, $fd, $72, $77, $b8, $ff, $b8, $ff, $fe, $a9, $bd, $c3
	db $7f, $7f, $8d, $9f, $ff, $c6, $4d, $ff, $7f, $7f, $a0, $e0, $bf, $ff, $b0, $df
	db $ff, $df, $5f, $e0, $7f, $ff, $ff, $3b, $fd, $6d, $f3, $9e, $ff, $88, $fc, $ff
	db $b4, $fc, $c4, $fe, $7a, $fe, $2e, $f3, $ff, $95, $fb, $ff, $ff, $a9, $57, $53
	db $fe, $ff, $56, $fd, $fd, $fb, $fb, $07, $fe, $ff, $df, $6c, $b7, $83, $c2, $02
	db $f9, $32, $0f, $1f, $ff, $1f, $30, $37, $6f, $6f, $df, $d8, $bf, $ff, $b0, $7f
	db $60, $ff, $c7, $ff, $84, $fc, $ff, $1c, $fe, $3a, $ef, $28, $fe, $80, $c0, $ff
	db $80, $80, $00, $80, $00, $00, $fc, $fe, $ff, $fe, $02, $fe, $fe, $e0, $f0, $20
	db $e0, $cf, $40, $e0, $80, $c0, $b2, $01, $ee, $33, $b1, $ff, $cf, $ef, $ff, $00
	db $01, $22, $09, $dc, $0b, $b6, $ff, $cf, $6d, $b6, $db, $ff, $dc, $0f, $ee, $35
	db $fd, $12, $ff, $77, $88, $ff, $e0, $16, $19, $0d, $0b, $ef, $07, $07, $85, $87
	db $5c, $0f, $fc, $ff, $f3, $ff, $fc, $ef, $f0, $dd, $e3, $bb, $c7, $bb, $e7, $c7
	db $7b, $87, $3a, $13, $36, $11, $dd, $e3, $ef, $df, $f0, $f3, $fc, $fc, $ff, $2e
	db $13, $df, $e0, $ff, $bf, $c0, $be, $c1, $7d, $83, $7b, $87, $ff, $77, $8f, $7f
	db $8f, $bf, $cf, $be, $c7, $fb, $df, $e0, $48, $1d, $b0, $cf, $6f, $9f, $7f, $7e
	db $7b, $10, $6f, $9f, $b0, $cf, $bf, $c0, $66, $15, $34, $8d, $1d, $fc, $0c, $80
	db $b6, $00, $fe, $ff, $b0, $10, $8d, $15, $f3, $f4, $f8, $b4, $17, $9a, $13, $80
	db $00, $a0, $c0, $cf, $e8, $f0, $f8, $fc, $b6, $00, $8d, $10, $80, $c0, $bf, $c0
	db $e0, $e0, $f0, $f8, $f0, $d5, $10, $f8, $ef, $f8, $fc, $fe, $fc, $12, $00, $00
	db $05, $03, $ff, $17, $0f, $1f, $3f, $3f, $7e, $7b, $fc, $df, $fb, $f1, $2f, $1f
	db $7f, $8d, $12, $bf, $ff, $6d, $ff, $00, $22, $01, $03, $f8, $30, $0f, $1f, $95
	db $00, $ff, $3f, $1e, $1e, $3c, $7e, $3c, $f7, $e3, $ff, $ef, $c7, $dd, $8e, $9d
	db $19, $1b, $03, $3f, $47, $03, $ec, $46, $c8, $85, $07, $24, $8d, $11, $fe, $00
	db $22, $3c, $79, $79, $7b, $ff, $7b, $73, $ef, $f7, $ff, $f7, $f7, $8d, $12, $93
	db $81, $1d, $e7, $b8, $bb, $76, $2f, $27, $ee, $19, $7a, $fc, $f1, $fd, $f8, $fe
	db $13, $fb, $f7, $df, $8f, $3f, $3f, $fa, $00, $20, $e7, $0e, $2a, $3f, $7d, $3f
	db $f3, $e1, $ff, $c1, $e0, $d0, $8c, $3c, $98, $f9, $30, $ff, $f3, $61, $e9, $c1
	db $dc, $c8, $df, $8f, $d7, $bf, $3f, $7f, $00, $22, $df, $a0, $22, $da, $b8, $01
	db $be, $48, $23, $8d, $14, $80, $01, $ff, $00, $01, $0f, $1f, $75, $fb, $ff, $83
	db $df, $7a, $77, $0c, $1e, $00, $fa, $3f, $00, $df, $ff, $bc, $ed, $de, $bf, $6e
	db $3f, $ea, $ef, $ff, $f0, $1f, $3f, $05, $0f, $05, $07, $3f, $ff, $7f, $7f, $40
	db $7f, $7f, $30, $7f, $1b, $ff, $3f, $0e, $1d, $06, $0d, $03, $03, $7b, $ff, $9c
	db $e7, $3f, $e3, $3f, $a5, $7f, $79, $ff, $ff, $d3, $fe, $6f, $bd, $ee, $bb, $fc
	db $ff, $f7, $f8, $0f, $f0, $ff, $07, $ff, $0e, $ff, $f9, $98, $f7, $f8, $f7, $ff
	db $ff, $fe, $df, $ff, $7d, $83, $83, $7f, $52, $01, $03, $ff, $fe, $58, $07, $83
	db $ff, $c7, $ff, $7e, $ff, $7c, $ff, $fe, $f8, $fc, $05, $07, $03, $07, $06, $fd
	db $05, $70, $0f, $0c, $1f, $35, $7a, $5b, $64, $7f, $7f, $7f, $d0, $70, $e0, $f0
	db $b0, $8f, $0f, $ff, $f0, $b0, $f8, $dc, $7e, $ee, $3e, $fe, $ff, $fe, $ff, $84
	db $dd, $e2, $bf, $78, $05, $07, $fe, $fb, $fe, $1a, $01, $1c, $0f, $6e, $0f, $84
	db $07, $fc, $31, $f8, $8e, $0f, $a4, $07, $fc, $31, $2a, $77, $1d, $37, $14, $e7
	db $1c, $08, $08, $fc, $3f, $1c, $13, $5d, $77, $3e, $ff, $7f, $0f, $1f, $1e, $39
	db $3b, $27, $1f, $ff, $3f, $07, $0e, $0e, $09, $07, $0f, $00, $ed, $01, $41, $11
	db $00, $01, $1c, $18, $80, $80, $80, $ff, $00, $80, $c0, $c0, $a0, $60, $f0, $f0
	db $ff, $fa, $df, $df, $b5, $bd, $77, $f7, $6d, $ff, $bd, $ef, $17, $3f, $02, $07
	db $00, $00, $9c, $30, $78, $58, $7c, $76, $df, $bd, $d3, $d6, $be, $38, $dc, $7c
	db $9c, $f4, $9c, $78, $dc, $b6, $ff, $dd, $f3, $76, $fe, $78, $78, $30, $78, $04
	db $81, $fe, $49, $ff, $b2, $f7, $0f, $ff, $00, $fe, $3f, $fd, $42, $fd, $92, $fd
	db $ba, $7d, $92, $bb, $44, $47, $b8, $bf, $40, $cf, $b0, $5d, $77, $3e, $7f, $35
	db $2b, $1f, $3f, $1a, $15, $0f, $1f, $0d, $0a, $07, $0f, $06, $05, $03, $07, $0c
	db $1f, $35, $7a, $5b, $64, $7f, $7f, $0b, $44, $80, $91, $c0, $40, $c0, $c0, $e0
	db $a0, $60, $e0, $f0, $b0, $f8, $dc, $7e, $ee, $3e, $fe, $fe, $0c, $42, $01, $92
	db $00, $01, $03, $02, $01, $03, $06, $05, $03, $07, $0c, $1f, $35, $7a, $5b, $64
	db $7f, $7f, $04, $9c, $5d, $77, $3e, $7f, $d6, $ae, $7c, $fe, $ac, $5c, $f8, $fc
	db $58, $b8, $f0, $f8, $b0, $70, $e0, $f0, $b0, $f8, $dc, $7e, $ee, $3e, $fe, $fe
	db $04, $a3, $02, $67, $37, $3f, $1f, $3f, $3f, $7f, $73, $ff, $ed, $f2, $3e, $29
	db $3f, $29, $3f, $21, $6f, $5f, $ff, $91, $f5, $9a, $ff, $8e, $bf, $c8, $5f, $65
	db $37, $3b, $30, $78, $7d, $45, $ff, $a2, $83, $ff, $7d, $83, $fe, $01, $f7, $19
	db $f7, $19, $ff, $01, $ff, $01, $ff, $82, $ff, $7c, $7f, $80, $bf, $40, $df, $a0
	db $30, $70, $e0, $f0, $e0, $e0, $ec, $fe, $f8, $fc, $43, $f8, $b3, $f9, $b9, $7f
	db $ff, $3f, $be, $7f, $fe, $7e, $7a, $e7, $ff, $db, $ef, $33, $fe, $23, $db, $27
	db $da, $bd, $ff, $9c, $fd, $5e, $7f, $de, $ff, $de, $7b, $de, $f3, $be, $e3, $be
	db $e3, $be, $7e, $d5, $7d, $63, $3e, $7f, $1b, $3f, $0e, $1d, $06, $0d, $03, $03
	db $ff, $a0, $03, $43, $11, $40, $10, $28, $11, $22, $20, $90, $04, $0b, $40, $b3
	db $6f, $de, $0b, $16, $86, $12, $0a, $05, $00, $02, $00, $08, $00, $12, $44, $84
	db $00, $00, $43, $01, $96, $40, $24, $0a, $04, $01, $dc, $b8, $b4, $f0, $e0, $00
	db $80, $20, $c2, $26, $05, $0a, $55, $ab, $4a, $12, $01, $03, $be, $c0, $20, $10
	db $88, $00, $06, $1c, $20, $04, $f2, $38, $e0, $8c, $20, $90, $08, $22, $00, $02
	db $05, $52, $59, $88, $04, $40, $a9, $44, $43, $04, $24, $3a, $32, $bc, $78, $fc
	db $fc, $c2, $04, $90, $50, $a8, $00, $02, $01, $0a, $04, $0a, $14, $4a, $3d, $ae
	db $17, $25, $d8, $62, $39, $7f, $1f, $bf, $1f, $fe, $ff, $41, $ce, $85, $87, $89
	db $f3, $c0, $e1, $7f, $a0, $08, $38, $c8, $2b, $0c, $10, $20, $41, $c0, $60, $f8
	db $04, $3f, $4c, $90, $21, $04, $08, $78, $8c, $04, $82, $83, $01, $20, $27, $38
	db $21, $22, $40, $80, $00, $43, $42, $95, $21, $18, $24, $22, $3e, $23, $44, $48
	db $08, $17, $08, $10, $9f, $01, $01, $02, $04, $88, $50, $30, $e0, $07, $be, $40
	db $21, $13, $03, $00, $f8, $0c, $06, $1e, $78, $10, $08, $c7, $01, $02, $00, $00
	db $20, $20, $70, $80, $38, $44, $83, $81, $60, $70, $70, $78, $78, $fc, $fc, $fe
	db $3c, $f8, $60, $20, $10, $ef, $01, $00, $01, $03, $04, $08, $3c, $fe, $1f, $8f
	db $c0, $e1, $f9, $7f, $3f, $3f, $1f, $9f, $fe, $fe, $e7, $c3, $c3, $41, $c1, $82
	db $e1, $e0, $ff, $09, $87, $0f, $18, $37, $6f, $5e, $5d, $5b, $09, $87, $ff, $00
	db $ff, $ff, $00, $ff, $00, $50, $5a, $7f, $09, $87, $07, $0f, $18, $30, $61, $63
	db $66, $09, $42, $ff, $02, $42, $ff, $81, $00, $50, $66, $ff, $ff, $00, $0f, $0f
	db $0f, $1f, $1f, $1f, $3f, $db, $00, $ff, $f9, $13, $00, $e0, $01, $00, $c0, $c0
	db $fb, $c0, $00, $08, $01, $01, $07, $3f, $3f, $3f, $fb, $7f, $7f, $f9, $14, $ff
	db $fe, $fc, $f0, $c0, $f3, $80, $80, $08, $02, $08, $03, $03, $03, $07, $07, $3d
	db $1f, $13, $08, $fc, $f8, $f8, $fc, $07, $03, $08, $00, $ed, $03, $2d, $01, $07
	db $00, $f8, $14, $00, $00, $fc, $e6, $3c, $01, $f8, $07, $f1, $13, $f8, $16, $f0
	db $f0, $f0, $a8, $01, $01, $25, $05, $f1, $12, $3f, $13, $07, $f8, $71, $01, $c0
	db $e6, $21, $01, $03, $0f, $83, $00, $13, $06, $ff, $ff, $f8, $58, $93, $00, $21
	db $00, $21, $06, $01, $01, $2c, $00, $03, $f8, $16, $fb, $fe, $fe, $3b, $00, $fc
	db $fc, $00, $00, $1f, $ff, $1e, $1e, $3c, $3d, $3f, $3f, $00, $1f, $7f, $3e, $7c
	db $f8, $f1, $e1, $c3, $00, $31, $00, $ff, $f3, $e1, $e1, $c1, $00, $83, $c3, $c3
	db $ff, $e7, $e7, $e7, $ef, $00, $e1, $e1, $e1, $ef, $e3, $f3, $f3, $77, $00, $00
	db $e1, $c1, $c3, $7b, $c7, $87, $c7, $01, $de, $de, $9e, $9e, $f0, $10, $fe, $f4
	db $10, $3d, $3d, $00, $c1, $c3, $c3, $c7, $f7, $c7, $cf, $ce, $59, $02, $78, $79
	db $79, $00, $fb, $78, $78, $70, $02, $7f, $7b, $7b, $f9, $f1, $7b, $f0, $f0, $e8
	db $01, $e3, $e1, $f1, $f0, $10, $11, $7f, $e7, $ff, $ff, $fc, $00, $ef, $cf, $05
	db $10, $ff, $3c, $3c, $00, $77, $77, $7f, $3f, $3f, $7f, $3e, $3e, $00, $8f, $9f
	db $1f, $3f, $21, $10, $fb, $00, $1e, $c8, $00, $1e, $1e, $1e, $00, $3d, $ff, $79
	db $79, $79, $f1, $f1, $f1, $00, $de, $ef, $dc, $fc, $f8, $f9, $65, $10, $f1, $f3
	db $f3, $15, $f3, $ec, $00, $00, $04, $01, $80, $20, $00, $21, $2e, $7a, $cd, $80
	db $22, $cd, $96, $1e, $11, $20, $00, $cd, $65, $1e, $21, $ab, $7b, $cd, $f3, $1d
	db $11, $00, $94, $21, $00, $d8, $01, $58, $00, $cd, $9c, $7b, $01, $18, $00, $cd
	db $8d, $7b, $01, $18, $00, $cd, $9c, $7b, $01, $08, $01, $af, $cd, $a7, $04, $12
	db $13, $2a, $12, $13, $0b, $78, $b1, $20, $f2, $c9, $2a, $cd, $a7, $04, $12, $13
	db $af, $12, $13, $0b, $78, $b1, $20, $f2, $c9, $a4, $98, $83, $40, $41, $42, $7f
	db $c3, $98, $84, $43, $44, $45, $46, $7f, $e1, $98, $93, $47, $48, $49, $4a, $4b
	db $4c, $4d, $5c, $5d, $5e, $5f, $60, $61, $62, $63, $64, $65, $66, $2f, $7f, $01
	db $99, $92, $4e, $4f, $50, $51, $52, $53, $54, $67, $68, $69, $6a, $6b, $6c, $6d
	db $6e, $6f, $70, $71, $7f, $23, $99, $84, $55, $56, $57, $58, $7f, $42, $99, $83
	db $59, $5a, $5b, $ff, $fa, $81, $c9, $c7, $03, $16, $49, $7c, $fc, $15, $67, $7c
	db $7c, $7c, $8a, $7c, $98, $7c, $a3, $7c, $ae, $7c, $b9, $7c, $fc, $15, $c4, $7c
	db $fc, $15, $d8, $7c, $e9, $7c, $d1, $21, $91, $c9, $fa, $82, $c9, $e6, $03, $c0
	db $34, $7e, $d5, $c9, $cd, $70, $16, $cd, $59, $16, $c3, $84, $21, $3e, $4e, $cd
	db $10, $05, $cd, $26, $7c, $21, $ff, $7c, $c3, $54, $7c, $cd, $18, $7c, $fe, $00
	db $c0, $21, $ff, $7c, $c3, $76, $7c, $3e, $63, $cd, $10, $05, $cd, $26, $7c, $21
	db $06, $7d, $3e, $f0, $ea, $91, $c9, $01, $00, $1a, $cd, $96, $11, $cd, $1e, $09
	db $3e, $c0, $c3, $f4, $15, $cd, $18, $7c, $fe, $40, $c0, $01, $00, $18, $cd, $96
	db $11, $21, $06, $7d, $cd, $1a, $09, $c3, $f7, $15, $21, $18, $7d, $3e, $30, $ea
	db $91, $c9, $cd, $1e, $09, $c3, $f7, $15, $cd, $18, $7c, $fe, $f0, $c0, $21, $18
	db $7d, $cd, $1a, $09, $18, $e7, $cd, $18, $7c, $fe, $b0, $c0, $21, $47, $7d, $18
	db $f0, $cd, $18, $7c, $fe, $c0, $c0, $21, $65, $7d, $18, $e5, $cd, $18, $7c, $fe
	db $f0, $c0, $21, $8e, $7d, $18, $da, $cd, $18, $7c, $fe, $78, $c0, $3e, $40, $c3
	db $f4, $15, $cd, $18, $7c, $fe, $b0, $c0, $21, $c4, $7d, $cd, $1a, $09, $3e, $00
	db $21, $0e, $7d, $c3, $56, $7c, $21, $91, $c9, $fa, $82, $c9, $e6, $03, $c0, $35
	db $7e, $fe, $f0, $c0, $c3, $f7, $15, $fa, $87, $c9, $e6, $90, $c8, $3e, $01, $ea
	db $a7, $c9, $21, $0e, $7d, $cd, $1a, $09, $3e, $04, $c3, $e6, $15, $e8, $9b, $ac
	db $a2, $b5, $a8, $ff, $e7, $9b, $b5, $a8, $a2, $ae, $ae, $ff, $e6, $9b, $a8, $b0
	db $a4, $90, $a4, $b3, $ad, $ff, $02, $9a, $a0, $a5, $a6, $af, $a5, $a2, $aa, $aa
	db $a4, $a5, $fe, $86, $9a, $a8, $ba, $b0, $a2, $af, $a9, $b0, $a2, $a5, $a2, $fe
	db $e6, $9a, $a3, $ba, $b0, $a2, $a3, $a2, $b3, $a6, $fe, $46, $9b, $b2, $ba, $aa
	db $a9, $a7, $a5, $a2, $ff, $02, $9a, $af, $a5, $a2, $a0, $b0, $a9, $ac, $90, $ad
	db $a4, $b5, $a9, $af, $b3, $a4, $a5, $fe, $86, $9a, $b2, $ba, $b2, $a9, $aa, $a7
	db $a5, $a2, $ff, $02, $9a, $b5, $a6, $a7, $b3, $ad, $90, $ac, $a5, $a4, $a2, $a8
	db $a6, $a5, $fe, $86, $9a, $b0, $ba, $ae, $a7, $b3, $a2, $a7, $ac, $b0, $a9, $fe
	db $e6, $9a, $aa, $ba, $b5, $b0, $a9, $b3, $ad, $a6, $a7, $ff, $02, $9a, $b5, $a0
	db $a4, $ac, $a9, $a2, $a1, $90, $a8, $b0, $a2, $b3, $b2, $b5, $fe, $86, $9a, $b0
	db $ba, $ae, $a7, $b3, $a2, $ab, $a9, $b2, $a9, $fe, $e6, $9a, $a8, $a4, $ad, $90
	db $b0, $a9, $b2, $a2, $b7, $a2, $fe, $46, $9b, $a2, $ba, $a8, $a6, $a3, $a2, $aa
	db $a2, $ff, $04, $9a, $a0, $a5, $a4, $b5, $a4, $b3, $a8, $a4, $ad, $90, $ab, $a3
	db $fe, $47, $9a, $b2, $a6, $b3, $a2, $aa, $a9, $ff, $cd, $98, $13, $3e, $01, $ea
	db $c1, $c9, $3e, $00, $ea, $c2, $c9, $cd, $59, $16, $cd, $21, $21, $21, $f6, $49
	db $11, $c0, $99, $cd, $40, $13, $01, $00, $98, $11, $0b, $9a, $26, $08, $cd, $f8
	db $7e, $01, $4a, $98, $11, $16, $9a, $26, $0a, $cd, $f8, $7e, $21, $2e, $49, $11
	db $60, $99, $cd, $40, $13, $01, $08, $98, $11, $73, $99, $cd, $d2, $7e, $01, $48
	db $98, $11, $93, $99, $cd, $d2, $7e, $01, $49, $98, $11, $60, $99, $cd, $d2, $7e
	db $01, $89, $98, $11, $80, $99, $cd, $d2, $7e, $01, $ca, $98, $21, $0e, $7f, $cd
	db $ea, $0a, $0e, $d2, $cd, $ea, $0a, $0e, $cf, $cd, $f8, $0a, $0e, $ec, $cd, $f8
	db $0a, $01, $f1, $98, $cd, $ea, $0a, $01, $50, $04, $cd, $93, $11, $c3, $f7, $15
	db $cd, $98, $13, $3e, $01, $ea, $c1, $c9, $3e, $00, $ea, $c2, $c9, $cd, $59, $16
	db $cd, $80, $13, $21, $2e, $49, $11, $21, $98, $cd, $40, $13, $01, $01, $98, $11
	db $21, $98, $26, $06, $cd, $d8, $7e, $01, $07, $98, $11, $34, $98, $cd, $d2, $7e
	db $01, $47, $98, $11, $54, $98, $cd, $d2, $7e, $01, $28, $98, $11, $07, $19, $cd
	db $0c, $0b, $cd, $3c, $0b, $01, $41, $99, $11, $01, $98, $cd, $d6, $7e, $01, $61
	db $99, $11, $61, $98, $cd, $d6, $7e, $06, $80, $cd, $43, $20, $16, $c0, $3e, $01
	db $e7, $14, $3e, $09, $e7, $21, $e0, $cd, $36, $e7, $2c, $36, $7e, $c3, $f7, $15
	db $26, $01, $18, $02, $26, $07, $2e, $06, $c5, $d5, $e5, $cd, $a7, $04, $1a, $02
	db $1c, $0c, $25, $20, $f6, $7d, $e1, $6f, $d1, $c1, $3e, $20, $cd, $40, $16, $3e
	db $20, $df, $2d, $20, $e3, $c9, $cd, $fe, $7e, $cd, $d8, $7e, $c5, $e5, $3e, $df
	db $cd, $59, $0b, $25, $20, $fa, $e1, $c1, $3e, $20, $df, $c9, $60, $61, $62, $63
	db $6d, $6e, $6b, $6c, $66, $69, $64, $65, $6a, $6b, $51, $6f, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $06
