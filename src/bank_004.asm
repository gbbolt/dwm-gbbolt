INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $004", ROMX[$4000], BANK[$4]

;@ path: field/script
;@ Bank number byte that bank $04 starts with (read by the far-call code).
BankNumber_04::
	db $04

;@ path: field/script
;@ Far-call entry points of bank $04 (`ld hl, $04nn` + rst $10 calls entry nn).
FarTable_04::
	dw DrawFieldMarker
	dw DrawFieldMarkerOnScreen
	dw DrawActorSprite
	dw DrawActorSpriteOnScreen
	dw UpdateFieldScript
	dw StartScript
	dw PrintScriptMessage

;@ def DrawFieldMarker()
;@ path: gfx/sprites
;@ Draws one of the small field marker sprites (FieldMarkerSprites, chosen by hSpriteSet and
;@ hSpriteFrame) at the world position hSpriteX/hSpriteY.
;@ test: skip writes OAM entries through pointer tables
DrawFieldMarker::
;> DrawMetasprite(FieldMarkerSprites)
	ld de, FieldMarkerSprites
	call DrawMetasprite
	ret


;@ def DrawFieldMarkerOnScreen()
;@ path: gfx/sprites
;@ The same marker sprites, but at the screen position hSpriteX/hSpriteY (no scrolling).
;@ test: skip writes OAM entries through pointer tables
DrawFieldMarkerOnScreen::
;> DrawScreenMetasprite(FieldMarkerSprites)
	ld de, FieldMarkerSprites
	call DrawScreenMetasprite
	ret


;@ path: gfx/sprites
;@ Metasprite table of the field markers: 3 sprite sets (pointers to frame lists), each frame a
;@ list of 4-byte entries (Y offset, X offset, tile, attributes) ended by $80 (DrawMetasprite format).
FieldMarkerSprites::
	db $23, $40, $2a, $40, $3d, $40, $25, $40, $00, $00, $00, $00, $80, $2c, $40, $00
	db $00, $00, $10, $00, $08, $01, $10, $08, $00, $02, $10, $08, $08, $03, $10, $80
	db $45, $40, $4e, $40, $63, $40, $70, $40, $00, $00, $90, $00, $08, $00, $91, $00
	db $80, $00, $00, $a6, $00, $00, $08, $a7, $00, $00, $10, $a8, $00, $00, $30, $a4
	db $00, $08, $30, $a5, $00, $80, $f8, $08, $00, $00, $00, $00, $01, $00, $00, $08
	db $02, $00, $80, $00, $00, $00, $00, $00, $08, $01, $00, $08, $00, $10, $00, $08
	db $08, $11, $00, $80

;@ def DrawActorSprite()
;@ path: field/actors
;@ Draws a field actor's sprite at its world position. hSpriteSet chooses the sprite: below $10
;@ one of the sets of this bank (ActorSpriteSets, with the palette from ActorSpritePalettes),
;@ $10-$8F a set of bank $10, from $90 on a set of bank $11 (the number is made relative first).
;@ test: skip draws through far calls and pointer tables
DrawActorSprite::
;> if hSpriteSet >= 0x90:
;>@a1     hSpriteSet -= 0x90
;>@a2     DrawFieldSprite_11()
	ldh a, [hSpriteSet]
	cp $90
	jr nc, .bank11

;> elif hSpriteSet >= 0x10:
;>@b1     hSpriteSet -= 0x10
;>@b2     DrawFieldSprite_10()
	cp $10
	jr nc, .bank10

;> else:
;>     SetActorSpritePalette()
	call SetActorSpritePalette
;>     DrawMetasprite(ActorSpriteSets)
	ld de, ActorSpriteSets
	call DrawMetasprite
	ret


.bank10
;=@b1
	sub $10
	ldh [hSpriteSet], a
;=@b2
	ld hl, far_DrawFieldSprite_10
	rst $10
	ret


.bank11
;=@a1
	sub $90
	ldh [hSpriteSet], a
;=@a2
	ld hl, far_DrawFieldSprite_11
	rst $10
	ret


;@ def DrawActorSpriteOnScreen()
;@ path: field/actors
;@ Like DrawActorSprite, but at a screen position (DrawScreenMetasprite and the matching entries of
;@ banks $10 and $11).
;@ test: skip draws through far calls and pointer tables
DrawActorSpriteOnScreen::
;> if hSpriteSet >= 0x90:
;>@a1     hSpriteSet -= 0x90
;>@a2     DrawFieldSpriteOnScreen_11()
	ldh a, [hSpriteSet]
	cp $90
	jr nc, .bank11

;> elif hSpriteSet >= 0x10:
;>@b1     hSpriteSet -= 0x10
;>@b2     DrawFieldSpriteOnScreen_10()
	cp $10
	jr nc, .bank10

;> else:
;>     SetActorSpritePalette()
	call SetActorSpritePalette
;>     DrawScreenMetasprite(ActorSpriteSets)
	ld de, ActorSpriteSets
	call DrawScreenMetasprite
	ret


.bank10
;=@b1
	sub $10
	ldh [hSpriteSet], a
;=@b2
	ld hl, far_DrawFieldSpriteOnScreen_10
	rst $10
	ret


.bank11
;=@a1
	sub $90
	ldh [hSpriteSet], a
;=@a2
	ld hl, far_DrawFieldSpriteOnScreen_11
	rst $10
	ret


;@ def DrawScreenMetasprite(table: de)
;@ path: gfx/sprites
;@ Adds a metasprite at the screen position hSpriteX/hSpriteY (not moved by the scroll) to the
;@ shadow OAM from slot hOAMCount on. `table` has one pointer per sprite set, each set one pointer
;@ per frame (hSpriteSet, hSpriteFrame); a frame is a list of Y offset, X offset, tile (plus
;@ hSpriteTileBase), attributes (XOR hSpriteAttr), ended by $80. Stops at 40 sprites.
;@ test: skip writes OAM entries through pointer tables
DrawScreenMetasprite::
;> # (keeps all registers)
	push af
	push bc
	push de
	push hl
;> if hOAMCount >= 40:
;>     return
	ldh a, [hOAMCount]
	cp $28
	jr nc, .done

;>@f1 frames = mem16[table + 2 * hSpriteSet]
	ldh a, [hSpriteSet]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
;=@f1
	inc hl
	ld d, [hl]
;>@f2 data = mem16[frames + 2 * hSpriteFrame]
	ldh a, [hSpriteFrame]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
;=@f2
	inc hl
	ld d, [hl]
;> oam = wShadowOAM + 4 * hOAMCount
	ldh a, [hOAMCount]
	sla a
	sla a
	ld l, a
	ld h, $c0

.loop
;> while True:
;>     dy = mem[data]; data += 1
	ld a, [de]
	inc de
;>     if dy == 0x80:                     # end of the frame
;>         break
	cp $80
	jr z, .done

;>     mem[oam] = (hSpriteY + dy + 0x10) & 0xFF; oam += 1
	ld b, a
	ldh a, [hSpriteY]
	add b
	add $10
	ld [hli], a
;>@x     mem[oam] = (hSpriteX + mem[data] + 8) & 0xFF; oam += 1; data += 1
	ld a, [de]
	inc de
	ld b, a
	ldh a, [hSpriteX]
	add b
	add $08
;=@x
	ld [hli], a
;>     mem[oam] = (hSpriteTileBase + mem[data]) & 0xFF; oam += 1; data += 1
	ldh a, [hSpriteTileBase]
	ld b, a
	ld a, [de]
	inc de
	add b
	ld [hli], a
;>     mem[oam] = mem[data] ^ hSpriteAttr; oam += 1; data += 1
	ld a, [de]
	inc de
	ld b, a
	ldh a, [hSpriteAttr]
	xor b
	ld [hli], a
;>     hOAMCount += 1
	ldh a, [hOAMCount]
	inc a
	ldh [hOAMCount], a
;>     if hOAMCount >= 40:
;>         break
	cp $28
	jr c, .loop

.done
;> return
	pop hl
	pop de
	pop bc
	pop af
	ret


;@ def SetActorSpritePalette()
;@ path: field/npcs
;@ Adds the palette bits of sprite set hSpriteSet (ActorSpritePalettes) to hSpriteAttr.
;@ test: skip indexes a data table
SetActorSpritePalette::
;>@pal hSpriteAttr |= ActorSpritePalettes[hSpriteSet]
	ldh a, [hSpriteSet]
	ld hl, ActorSpritePalettes
	add l
	ld l, a
	ld a, $00
	adc h
;=@pal
	ld h, a
	ldh a, [hSpriteAttr]
	or [hl]
	ldh [hSpriteAttr], a
	ret


;@ path: field/actors
;@ Sprite sets of the field actors drawn from this bank (16 pointers to frame lists): set 0 is
;@ ActorSpriteFrames0, the others all ActorSpriteFrames1.
ActorSpriteSets::
	db $37, $72, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77
	db $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77
;@ path: field/actors
;@ Attribute bits ORed into each of the 16 sprite sets of ActorSpriteSets (all palette 2).
ActorSpritePalettes::
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02

;@ def UpdateFieldScript()
;@ path: event/script
;@ Runs the map script once a field frame (far entry $0404). It waits while another field mode,
;@ a fade or text is busy (during a pending field event only at event step $0B, during a screen
;@ scroll only at scroll step 2), and while a message of the script is waiting to be printed.
;@ The script's movers (wMovers) move every frame - twice with wScriptRunning bit 6. Then a
;@ running wait (ScriptWait8, ScriptWaitFrames) or walk (ScriptWalk) goes on; otherwise the next
;@ command is executed.
;@ test: skip runs script commands from banks $0C-$0F
UpdateFieldScript::
;> if wFieldFlags & ~0x05:                # other field modes than an event or a scroll
;>     return
	ld a, [wFieldFlags]
	res 0, a
	res 2, a
	or a
	ret nz

;> if wFieldFlags & 0x01:                 # a field event is pending
	ld a, [wFieldFlags]
	bit 0, a
	jr z, .noEvent

;>     if wEventStep != 0x0B:
;>         return
	ld a, [wEventStep]
	cp $0b
	ret nz

	jr .check

.noEvent
;> elif wFieldFlags & 0x04:               # scrolling to the next screen
	bit 2, a
	jr z, .check

;>     if wScrollStep != 2:
;>         return
	ld a, [wScrollStep]
	cp $02
	ret nz

.check
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> if not wScriptRunning & 0x01:
;>     return
	ld a, [wScriptRunning]
	bit 0, a
	jp z, UpdateFieldScriptDone

;> if wScriptRunning & 0x02:              # a message waits to be printed
;>     return
	bit 1, a
	jp nz, UpdateFieldScriptDone

;> if wScriptRunning & 0x10:
;>     UpdateMovers()
	ld a, [wScriptRunning]
	bit 4, a
	call nz, UpdateMovers
;> if wScriptRunning & 0x40:              # fast movers: a second step
;>     UpdateMovers()
	ld a, [wScriptRunning]
	bit 6, a
	call nz, UpdateMovers
;> if wScriptRunning & 0x04:
;>     return ScriptWait8()
	ld a, [wScriptRunning]
	bit 2, a
	jr nz, ScriptWait8

;> if wScriptRunning & 0x08:
;>     return ScriptWalk()
	bit 3, a
	jp nz, ScriptWalk

;> if wScriptFlags & 0x04:
;>     return ScriptWaitFrames()
	ld a, [wScriptFlags]
	bit 2, a
	jp nz, ScriptWaitFrames

;> NextScriptCommand()
	call NextScriptCommand

UpdateFieldScriptDone:
;> return
	ret


;@ def ScriptWait8()
;@ path: event/script
;@ A script wait (wScriptRunning bit 2): wScriptWait counts down once every 8 frames; at 0 the
;@ script goes on.
;@ test: skip part of UpdateFieldScript
ScriptWait8::
;> if wFrameCounter & 7 == 0:
	ld a, [wFrameCounter]
	and $07
	jr nz, .done

;>     wScriptWait -= 1
	ld a, [wScriptWait]
	dec a
	ld [wScriptWait], a
;>     if wScriptWait == 0:
	jr nz, .done

;>         wScriptRunning &= ~0x04
	ld hl, wScriptRunning
	res 2, [hl]

.done
;> return
	jp UpdateFieldScriptDone


;@ def ScriptWalk()
;@ path: event/script
;@ A script walk (wScriptRunning bit 3) of Terry (wScriptWalker 0; actors: ScriptWalkActor): he
;@ moves one pixel towards the target, on 3 of 4 frames - first along X (wScriptWalkX), then
;@ along Y (wScriptWalkY) - and turns to face the way he goes unless wScriptRunning bit 5 is set.
;@ When both counts are 0 the walk ends.
;@ test: skip part of UpdateFieldScript
ScriptWalk::
;> if wScriptWalker != 0:
;>     return ScriptWalkActor()
	ld a, [wScriptWalker]
	or a
	jp nz, ScriptWalkActor

;> hPlayerFlags |= 0x01                   # Terry is moving
	ld hl, hPlayerFlags
	set 0, [hl]
;> if wFrameCounter & 3 == 1:             # rest one frame of four
;>     return
	ld a, [wFrameCounter]
	and $03
	cp $01
	jp z, ScriptWalkDone

;>@x if wScriptWalkX != 0:
	ld a, [wScriptWalkX]
	ld l, a
	ld a, [wScriptWalkX + 1]
	ld h, a
	ld a, h
	or l
;=@x
	jr z, .walkY

;>     if wScriptWalkX < 0x8000:          # to the right
	bit 7, h
	jr nz, .walkLeft

;>         wScriptWalkX -= 1
	ld a, [wScriptWalkX]
	sub $01
	ld [wScriptWalkX], a
	ld a, [wScriptWalkX + 1]
	sbc $00
	ld [wScriptWalkX + 1], a
;>         hPlayerX += 1
	ldh a, [hPlayerX]
	add $01
	ldh [hPlayerX], a
	ldh a, [hPlayerX + 1]
	adc $00
	ldh [hPlayerX + 1], a
;>         if not wScriptRunning & 0x20:
	ld a, [wScriptRunning]
	bit 5, a
	jp nz, .pose

;>             hPlayerDir = 3
	ld a, $03
	ldh [hPlayerDir], a
	jp .pose


.walkLeft
;>     else:
;>         wScriptWalkX += 1
	ld a, [wScriptWalkX]
	add $01
	ld [wScriptWalkX], a
	ld a, [wScriptWalkX + 1]
	adc $00
	ld [wScriptWalkX + 1], a
;>         hPlayerX -= 1
	ldh a, [hPlayerX]
	sub $01
	ldh [hPlayerX], a
	ldh a, [hPlayerX + 1]
	sbc $00
	ldh [hPlayerX + 1], a
;>         if not wScriptRunning & 0x20:
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, .pose

;>             hPlayerDir = 1
	ld a, $01
	ldh [hPlayerDir], a
	jr .pose

.walkY
;>@y elif wScriptWalkY != 0:
	ld a, [wScriptWalkY]
	ld l, a
	ld a, [wScriptWalkY + 1]
	ld h, a
	ld a, h
	or l
;=@y
	jr z, .walkDone

;>     if wScriptWalkY < 0x8000:          # down
	bit 7, h
	jr nz, .walkUp

;>         wScriptWalkY -= 1
	ld a, [wScriptWalkY]
	sub $01
	ld [wScriptWalkY], a
	ld a, [wScriptWalkY + 1]
	sbc $00
	ld [wScriptWalkY + 1], a
;>         hPlayerY += 1
	ldh a, [hPlayerY]
	add $01
	ldh [hPlayerY], a
	ldh a, [hPlayerY + 1]
	adc $00
	ldh [hPlayerY + 1], a
;>         if not wScriptRunning & 0x20:
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, .pose

;>             hPlayerDir = 0
	ld a, $00
	ldh [hPlayerDir], a
	jr .pose

.walkUp
;>     else:
;>         wScriptWalkY += 1
	ld a, [wScriptWalkY]
	add $01
	ld [wScriptWalkY], a
	ld a, [wScriptWalkY + 1]
	adc $00
	ld [wScriptWalkY + 1], a
;>         hPlayerY -= 1
	ldh a, [hPlayerY]
	sub $01
	ldh [hPlayerY], a
	ldh a, [hPlayerY + 1]
	sbc $00
	ldh [hPlayerY + 1], a
;>         if not wScriptRunning & 0x20:
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, .pose

;>             hPlayerDir = 2
	ld a, $02
	ldh [hPlayerDir], a

.pose
;=@pose
	call SetPlayerPoseFromDir
	jp ScriptWalkDone


.walkDone
;> else:                                  # arrived
;>     hPlayerFlags &= ~0x01
	ld hl, hPlayerFlags
	res 0, [hl]
;>     wScriptRunning &= ~0x08
	ld hl, wScriptRunning
	res 3, [hl]
;>     return
	jp ScriptWalkDone

;>@pose SetPlayerPoseFromDir()


;@ def ScriptWalkActor()
;@ path: event/script
;@ The script walk of actor wScriptWalker (1-8; its record is 32 bytes in wActors: +5 flags, +6
;@ direction, +$18 X, +$1A Y): marks it walking (and not talking), then moves it like ScriptWalk
;@ moves Terry. When it arrives its walking flag is cleared and the walk ends.
;@ test: skip part of UpdateFieldScript
ScriptWalkActor::
;>@a actor = wActors + 32 * (wScriptWalker - 1)     # kept in hNumber
	dec a
	swap a
	add a
	ld hl, wActors
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
;=@a
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
;> flags = actor + 5
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
;> mem[flags] = (mem[flags] | 0x01) & ~0x40   # walking, not talking
	set 0, [hl]
	res 6, [hl]
;> if wFrameCounter & 3 == 1:
;>     return
	ld a, [wFrameCounter]
	and $03
	cp $01
	jp z, ScriptWalkDone

;>@x if wScriptWalkX != 0:
	ld a, [wScriptWalkX]
	ld e, a
	ld a, [wScriptWalkX + 1]
	ld d, a
	ld a, d
	or e
;=@x
	jr z, .walkY

;>     if wScriptWalkX < 0x8000:
	bit 7, d
	jr nz, .walkLeft

;>         wScriptWalkX -= 1
	ld a, [wScriptWalkX]
	sub $01
	ld [wScriptWalkX], a
	ld a, [wScriptWalkX + 1]
	sbc $00
	ld [wScriptWalkX + 1], a
;>         if not wScriptRunning & 0x20:
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, .right

;>             mem[actor + 6] = 3
	ld [hl], $03

.right
;>@r         mem16[actor + 0x18] += 1
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
;=@r
	inc hl
	ld [hl], d
	jp ScriptWalkDone


.walkLeft
;>     else:
;>         wScriptWalkX += 1
	ld a, [wScriptWalkX]
	add $01
	ld [wScriptWalkX], a
	ld a, [wScriptWalkX + 1]
	adc $00
	ld [wScriptWalkX + 1], a
;>         if not wScriptRunning & 0x20:
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, .left

;>             mem[actor + 6] = 1
	ld [hl], $01

.left
;>@l         mem16[actor + 0x18] -= 1
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@l
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
;=@l
	inc hl
	ld [hl], d
	jr ScriptWalkDone

.walkY
;>@y elif wScriptWalkY != 0:
	ld a, [wScriptWalkY]
	ld e, a
	ld a, [wScriptWalkY + 1]
	ld d, a
	ld a, d
	or e
;=@y
	jr z, .walkDone

;>     if wScriptWalkY < 0x8000:
	bit 7, d
	jr nz, .walkUp

;>         wScriptWalkY -= 1
	ld a, [wScriptWalkY]
	sub $01
	ld [wScriptWalkY], a
	ld a, [wScriptWalkY + 1]
	sbc $00
	ld [wScriptWalkY + 1], a
;>         if not wScriptRunning & 0x20:
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, .down

;>             mem[actor + 6] = 0
	ld [hl], $00

.down
;>@d         mem16[actor + 0x1A] += 1
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@d
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
;=@d
	inc hl
	ld [hl], d
	jr ScriptWalkDone

.walkUp
;>     else:
;>         wScriptWalkY += 1
	ld a, [wScriptWalkY]
	add $01
	ld [wScriptWalkY], a
	ld a, [wScriptWalkY + 1]
	adc $00
	ld [wScriptWalkY + 1], a
;>         if not wScriptRunning & 0x20:
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, .up

;>             mem[actor + 6] = 2
	ld [hl], $02

.up
;>@u         mem16[actor + 0x1A] -= 1
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@u
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
;=@u
	inc hl
	ld [hl], d
	jr ScriptWalkDone

.walkDone
;> else:                                  # arrived
;>@e     mem[actor + 5] &= ~0x01
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@e
	res 0, [hl]
;>     wScriptRunning &= ~0x08
	ld hl, wScriptRunning
	res 3, [hl]

ScriptWalkDone:
;> return
	jp UpdateFieldScriptDone


;@ def ScriptWaitFrames()
;@ path: event/script
;@ A frame wait (wScriptFlags bit 2, script command $4D): wScriptWait counts down every frame; at
;@ 0 the script goes on.
;@ test: skip part of UpdateFieldScript
ScriptWaitFrames::
;> wScriptWait -= 1
	ld a, [wScriptWait]
	dec a
	ld [wScriptWait], a
;> if wScriptWait == 0:
	jr nz, .done

;>     wScriptFlags &= ~0x04
	ld hl, wScriptFlags
	res 2, [hl]

.done
;> return
	jp UpdateFieldScriptDone


;@ def UpdateMovers()
;@ path: event/movers
;@ Moves the script's movers one step: slot 0 is Terry (UpdatePlayerMover), slots 1-7 the actors
;@ (UpdateActorMover). A mover is 8 bytes in wMovers: +0 active, +1 frame counter, +2 movement
;@ type, +3 actor number, +4 dx (u16), +6 dy (u16). When no slot was active the movers are off
;@ (wScriptRunning bits 4 and 6 cleared).
;@ test: skip moves sprites through the mover routines
UpdateMovers::
;> active = wMovers[0]
	ld a, [wMovers]
	push af
;> UpdatePlayerMover()
	call UpdatePlayerMover
	pop af
;> for slot in range(1, 8):
;>@o     active |= wMovers[8 * slot]
	ld hl, wMovers + $08
	or [hl]
;>@u     UpdateActorMover(wMovers + 8 * slot)
	push af
	call UpdateActorMover
	pop af
;=@o
	ld hl, wMovers + $10
	or [hl]
;=@u
	push af
	call UpdateActorMover
	pop af
;=@o
	ld hl, wMovers + $18
	or [hl]
;=@u
	push af
	call UpdateActorMover
	pop af
;=@o
	ld hl, wMovers + $20
	or [hl]
;=@u
	push af
	call UpdateActorMover
	pop af
;=@o
	ld hl, wMovers + $28
	or [hl]
;=@u
	push af
	call UpdateActorMover
	pop af
;=@o
	ld hl, wMovers + $30
	or [hl]
;=@u
	push af
	call UpdateActorMover
	pop af
;=@o
	ld hl, wMovers + $38
	or [hl]
;=@u
	push af
	call UpdateActorMover
	pop af
;> if active:
;>     return
	or a
	ret nz

;> wScriptRunning &= ~0x50
	ld hl, wScriptRunning
	res 4, [hl]
	res 6, [hl]
	ret


;@ def UpdatePlayerMover()
;@ path: event/movers
;@ Moves Terry's mover (wMovers slot 0) one step. Types 1, 3, 4, 6, 7 and $1A are hops, leaps and
;@ the party-gathering trail (see the Mover* routines); any other type walks him like a script
;@ walk: one pixel on 3 of 4 frames towards dx, then dy, turning unless wScriptRunning bit 5 is
;@ set, and the mover ends when both are 0.
;@ test: skip moves sprites through the mover routines
UpdatePlayerMover::
;> if wMovers[0] == 0:
;>     return
	ld a, [wMovers]
	or a
	ret z

;> wScriptRunning |= 0x10
	ld a, [wScriptRunning]
	set 4, a
	ld [wScriptRunning], a
;> mover = wMovers                        # kept in hNumber + 2
	ld hl, wMovers
	ld a, l
	ldh [hNumber + 2], a
	ld a, h
	ldh [hNumber + 3], a
;> pos = hPlayerY                         # what the arc moves
	ld a, [wMovers + 2]
	ld hl, hPlayerY
;> if wMovers[2] == 0x01:
;>     return MoverHopSmall(pos)
	cp $01
	jp z, MoverHopSmall

;> if wMovers[2] == 0x03:
;>     return MoverLeapSpin(pos)
	cp $03
	jp z, MoverLeapSpin

;> if wMovers[2] == 0x04:
;>     return MoverHop(pos)
	cp $04
	jp z, MoverHop

;> if wMovers[2] == 0x06:
;>     return MoverFillTrail()
	cp $06
	jp z, MoverFillTrail

;> if wMovers[2] == 0x07:
;>     return MoverHopLeft(pos)
	cp $07
	jp z, MoverHopLeft

;> if wMovers[2] == 0x1A:
;>     return MoverSpinHop2(pos)
	cp $1a
	jp z, MoverSpinHop2

;> hPlayerFlags |= 0x01
	ld hl, hPlayerFlags
	set 0, [hl]
;> if wFrameCounter & 3 == 1:
;>     return
	ld a, [wFrameCounter]
	and $03
	cp $01
	ret z

;>@x if mem16[wMovers + 4] != 0:
	ld a, [wMovers + 4]
	ld l, a
	ld a, [wMovers + 5]
	ld h, a
	ld a, h
	or l
;=@x
	jr z, .walkY

;>     if mem16[wMovers + 4] < 0x8000:
	bit 7, h
	jr nz, .left

;>         mem16[wMovers + 4] -= 1
	ld a, [wMovers + 4]
	sub $01
	ld [wMovers + 4], a
	ld a, [wMovers + 5]
	sbc $00
	ld [wMovers + 5], a
;>         hPlayerX += 1
	ldh a, [hPlayerX]
	add $01
	ldh [hPlayerX], a
	ldh a, [hPlayerX + 1]
	adc $00
	ldh [hPlayerX + 1], a
;>         if not wScriptRunning & 0x20:
;>             hPlayerDir = 3
	ld a, [wScriptRunning]
	bit 5, a
	jp nz, SetPlayerPoseFromDir

	ld a, $03
	ldh [hPlayerDir], a
	jp SetPlayerPoseFromDir


.left
;>     else:
;>         mem16[wMovers + 4] += 1
	ld a, [wMovers + 4]
	add $01
	ld [wMovers + 4], a
	ld a, [wMovers + 5]
	adc $00
	ld [wMovers + 5], a
;>         hPlayerX -= 1
	ldh a, [hPlayerX]
	sub $01
	ldh [hPlayerX], a
	ldh a, [hPlayerX + 1]
	sbc $00
	ldh [hPlayerX + 1], a
;>         if not wScriptRunning & 0x20:
;>             hPlayerDir = 1
	ld a, [wScriptRunning]
	bit 5, a
	jp nz, SetPlayerPoseFromDir

	ld a, $01
	ldh [hPlayerDir], a
	jp SetPlayerPoseFromDir


.walkY
;>@y elif mem16[wMovers + 6] != 0:
	ld a, [wMovers + 6]
	ld l, a
	ld a, [wMovers + 7]
	ld h, a
	ld a, h
	or l
;=@y
	jp z, PlayerMoverDone

;>     if mem16[wMovers + 6] < 0x8000:
	bit 7, h
	jr nz, .up

;>         mem16[wMovers + 6] -= 1
	ld a, [wMovers + 6]
	sub $01
	ld [wMovers + 6], a
	ld a, [wMovers + 7]
	sbc $00
	ld [wMovers + 7], a
;>         hPlayerY += 1
	ldh a, [hPlayerY]
	add $01
	ldh [hPlayerY], a
	ldh a, [hPlayerY + 1]
	adc $00
	ldh [hPlayerY + 1], a
;>         if not wScriptRunning & 0x20:
;>             hPlayerDir = 0
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, SetPlayerPoseFromDir

	ld a, $00
	ldh [hPlayerDir], a
	jr SetPlayerPoseFromDir

.up
;>     else:
;>         mem16[wMovers + 6] += 1
	ld a, [wMovers + 6]
	add $01
	ld [wMovers + 6], a
	ld a, [wMovers + 7]
	adc $00
	ld [wMovers + 7], a
;>         hPlayerY -= 1
	ldh a, [hPlayerY]
	sub $01
	ldh [hPlayerY], a
	ldh a, [hPlayerY + 1]
	sbc $00
	ldh [hPlayerY + 1], a
;>         if not wScriptRunning & 0x20:
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, SetPlayerPoseFromDir

;>             hPlayerDir = 2
	ld a, $02
	ldh [hPlayerDir], a
;> else:
;>     return PlayerMoverDone()
;> SetPlayerPoseFromDir()                 # falls through into it

;@ def SetPlayerPoseFromDir()
;@ path: field/player
;@ Sets Terry's sprite pose and mirroring for hPlayerDir: down front, left side mirrored, up back,
;@ right side.
;@ test: hPlayerDir = rand(0, 3)
SetPlayerPoseFromDir::
;> hPlayerAttr = 0x00
	ld a, $00
	ldh [hPlayerAttr], a
;> hPlayerPose = 0
	ld a, $00
	ldh [hPlayerPose], a
;> if hPlayerDir == 0:
;>     return
	ldh a, [hPlayerDir]
	or a
	ret z

;> hPlayerAttr = 0x20
	ld a, $20
	ldh [hPlayerAttr], a
;> hPlayerPose = 1
	ld a, $01
	ldh [hPlayerPose], a
;> if hPlayerDir == 1:
;>     return
	ldh a, [hPlayerDir]
	cp $01
	ret z

;> hPlayerAttr = 0x00
	ld a, $00
	ldh [hPlayerAttr], a
;> hPlayerPose = 2
	ld a, $02
	ldh [hPlayerPose], a
;> if hPlayerDir == 2:
;>     return
	ldh a, [hPlayerDir]
	cp $02
	ret z

;> hPlayerAttr = 0x00
	ld a, $00
	ldh [hPlayerAttr], a
;> hPlayerPose = 1
	ld a, $01
	ldh [hPlayerPose], a
	ret


;@ def PlayerMoverDone()
;@ path: event/movers
;@ Ends Terry's mover: he stops moving and slot 0 is freed.
;@ test: skip part of UpdatePlayerMover
PlayerMoverDone::
;> hPlayerFlags &= ~0x01
	ld hl, hPlayerFlags
	res 0, [hl]
;> wMovers[0] = 0
	xor a
	ld [wMovers], a
	ret


;@ def UpdateActorMover(mover: hl)
;@ path: event/movers
;@ Moves an actor's mover (slots 1-7 of wMovers) one step. The actor record (+3 of the mover:
;@ actor number) is kept in hNumber, the mover in hNumber + 2. Types $01-$19 (except 3, 6, 7)
;@ are the Mover* hops, jumps, blinks, falls and throws, which move the actor's Y (record +$1A);
;@ any other type walks the actor one pixel on 3 of 4 frames towards dx, then dy (record +$18 /
;@ +$1A), turning it (+6) unless wScriptRunning bit 5 is set; at the end its walking flag is
;@ cleared and the mover freed.
;@ test: skip moves sprites through the mover routines
UpdateActorMover::
;> if mem[mover] == 0:
;>     return
	ld a, [hl]
	or a
	ret z

;> wScriptRunning |= 0x10
	ld a, [wScriptRunning]
	set 4, a
	ld [wScriptRunning], a
;> # kept in hNumber + 2
	ld a, l
	ldh [hNumber + 2], a
	ld a, h
	ldh [hNumber + 3], a
;>@a actor = wActors + 32 * (mem[mover + 3] - 1)      # kept in hNumber
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	dec a
	swap a
;=@a
	add a
	ld hl, wActors
	add l
	ld l, a
	ld a, $00
	adc h
;=@a
	ld h, a
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
;>@t kind = mem[mover + 2]
	ldh a, [hNumber + 2]
	add $02
	ld c, a
	ldh a, [hNumber + 3]
	adc $00
	ld b, a
;=@t
	ld a, [bc]
	push af
;>@p pos = actor + 0x1A                   # Y, what the arcs move
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@p
	pop af
;> if kind == 0x01: return MoverHopSmall(pos)
	cp $01
	jp z, MoverHopSmall

;> if kind == 0x02: return MoverHopHigh(pos)
	cp $02
	jp z, MoverHopHigh

;> if kind == 0x04: return MoverHop(pos)
	cp $04
	jp z, MoverHop

;> if kind == 0x05: return MoverDoubleHopRight(pos)
	cp $05
	jp z, MoverDoubleHopRight

;> if kind == 0x08: return MoverBlinkIn()
	cp $08
	jp z, MoverBlinkIn

;> if kind == 0x09: return MoverSpinHop(pos)
	cp $09
	jp z, MoverSpinHop

;> if kind == 0x0A: return MoverRise(pos)
	cp $0a
	jp z, MoverRise

;> if kind == 0x0B: return MoverDoubleHop(pos)
	cp $0b
	jp z, MoverDoubleHop

;> if kind == 0x0C: return MoverFallLeft(pos)
	cp $0c
	jp z, MoverFallLeft

;> if kind == 0x0D: return MoverBlinkOut()
	cp $0d
	jp z, MoverBlinkOut

;> if kind == 0x0E: return MoverFloatUp(pos)
	cp $0e
	jp z, MoverFloatUp

;> if kind == 0x0F: return MoverLaunch(pos)
	cp $0f
	jp z, MoverLaunch

;> if kind == 0x10: return MoverDrop(pos)
	cp $10
	jp z, MoverDrop

;> if kind == 0x11: return MoverFallFast(pos)
	cp $11
	jp z, MoverFallFast

;> if kind == 0x12: return MoverHopDrop(pos)
	cp $12
	jp z, MoverHopDrop

;> if kind == 0x13: return MoverLeap(pos)
	cp $13
	jp z, MoverLeap

;> if kind == 0x14: return MoverBlinkSpin()
	cp $14
	jp z, MoverBlinkSpin

;> if kind == 0x15: return MoverFallArcLeft(pos)
	cp $15
	jp z, MoverFallArcLeft

;> if kind == 0x16: return MoverFallArcRight(pos)
	cp $16
	jp z, MoverFallArcRight

;> if kind == 0x17: return MoverThrowLeft(pos)
	cp $17
	jp z, MoverThrowLeft

;> if kind == 0x18: return MoverThrowRight(pos)
	cp $18
	jp z, MoverThrowRight

;> if kind == 0x19: return MoverHopLeft2(pos)
	cp $19
	jp z, MoverHopLeft2

;> flags = actor + 5
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;> mem[flags] = (mem[flags] | 0x01) & ~0x40      # walking, not talking
	set 0, [hl]
	res 6, [hl]
;> if wFrameCounter & 3 == 1:
;>     return
	ld a, [wFrameCounter]
	and $03
	cp $01
	ret z

;>@x dx = mem16[mover + 4]
	ldh a, [hNumber + 2]
	add $04
	ld c, a
	ldh a, [hNumber + 3]
	adc $00
	ld b, a
;=@x
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
;> if dx != 0:
	ld a, d
	or e
	jr z, .walkY

;>     if dx < 0x8000:
	bit 7, d
	jr nz, .left

;>@m         mem16[mover + 4] -= 1
	ldh a, [hNumber + 2]
	add $04
	ld c, a
	ldh a, [hNumber + 3]
	adc $00
	ld b, a
;=@m
	ld a, [bc]
	sub $01
	ld [bc], a
	inc bc
	ld a, [bc]
	sbc $00
;=@m
	ld [bc], a
;>         if not wScriptRunning & 0x20:
;>             mem[actor + 6] = 3
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, .right

	ld [hl], $03

.right
;>@r         mem16[actor + 0x18] += 1
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
;=@r
	inc hl
	ld [hl], d
	ret


.left
;>     else:
;>@n         mem16[mover + 4] += 1
	ldh a, [hNumber + 2]
	add $04
	ld c, a
	ldh a, [hNumber + 3]
	adc $00
	ld b, a
;=@n
	ld a, [bc]
	add $01
	ld [bc], a
	inc bc
	ld a, [bc]
	adc $00
;=@n
	ld [bc], a
;>         if not wScriptRunning & 0x20:
;>             mem[actor + 6] = 1
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, .leftMove

	ld [hl], $01

.leftMove
;>@l         mem16[actor + 0x18] -= 1
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@l
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
;=@l
	inc hl
	ld [hl], d
	ret


.walkY
;> else:
;>@y     dy = mem16[mover + 6]
	ldh a, [hNumber + 2]
	add $06
	ld c, a
	ldh a, [hNumber + 3]
	adc $00
	ld b, a
;=@y
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
;>     if dy == 0:                        # arrived
;>@e         mem[actor + 5] &= ~0x01
;>@f         mem[mover] = 0
;>@g         return
	ld a, d
	or e
	jr z, .done

;>     if dy < 0x8000:
	bit 7, d
	jr nz, .up

;>@o         mem16[mover + 6] -= 1
	ldh a, [hNumber + 2]
	add $06
	ld c, a
	ldh a, [hNumber + 3]
	adc $00
	ld b, a
;=@o
	ld a, [bc]
	sub $01
	ld [bc], a
	inc bc
	ld a, [bc]
	sbc $00
;=@o
	ld [bc], a
;>         if not wScriptRunning & 0x20:
;>             mem[actor + 6] = 0
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, .down

	ld [hl], $00

.down
;>@d         mem16[actor + 0x1A] += 1
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@d
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
;=@d
	inc hl
	ld [hl], d
	ret


.up
;>     else:
;>@q         mem16[mover + 6] += 1
	ldh a, [hNumber + 2]
	add $06
	ld c, a
	ldh a, [hNumber + 3]
	adc $00
	ld b, a
;=@q
	ld a, [bc]
	add $01
	ld [bc], a
	inc bc
	ld a, [bc]
	adc $00
;=@q
	ld [bc], a
;>         if not wScriptRunning & 0x20:
;>             mem[actor + 6] = 2
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, .upMove

	ld [hl], $02

.upMove
;>@u         mem16[actor + 0x1A] -= 1
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@u
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
;=@u
	inc hl
	ld [hl], d
	ret


.done
;=@e
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@e
	res 0, [hl]
;=@f
	ldh a, [hNumber + 2]
	ld l, a
	ldh a, [hNumber + 3]
	ld h, a
	ld [hl], $00
;=@g
	ret


;@ def MoverHopSmall(pos: hl)
;@ path: event/movers
;@ Mover type $01: a small hop (ArcHopSmall), by Terry or an actor.
;@ test: skip part of the mover code
MoverHopSmall::
;> return StepMoverArc(ArcHopSmall, pos)
	ld bc, ArcHopSmall

;@ def StepMoverArc(table: bc, pos: hl)
;@ path: event/movers
;@ One step of an arc movement: adds entry `frame` (mover +1, counted up) of `table`, a list of
;@ signed u16 offsets ended by $80, to the u16 position at `pos`. At the end of the list the mover
;@ is freed (MoverDone). The mover is the one at hNumber + 2.
;@ test: skip part of the mover code
StepMoverArc::
;> mover = mem16[hNumber + 2]
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;> frame = mem[mover + 1]; mem[mover + 1] += 1
	ld a, [de]
	push af
	inc a
	ld [de], a
	pop af
;> entry = table + 2 * frame
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
;> if mem[entry] == 0x80:                 # end of the arc
;>@e     mem[mover] = 0                     # MoverDone
;>@f     return
	ld a, [bc]
	cp $80
	jr z, MoverDone

;>@p mem16[pos] += mem16[entry]
	add [hl]
	ld [hli], a
	inc bc
	ld a, [bc]
	adc [hl]
	ld [hl], a
;=@p
	ret


MoverDone:
;=@e
	ldh a, [hNumber + 2]
	ld l, a
	ldh a, [hNumber + 3]
	ld h, a
	ld [hl], $00
;=@f
	ret


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $01, a small hop.
ArcHopSmall::
	db $fd, $ff, $fd, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $01, $00
	db $01, $00, $02, $00, $03, $00, $03, $00, $80, $80

;@ def MoverHopHigh(pos: hl)
;@ path: event/movers
;@ Mover type $02 (actors): a higher hop (ArcHopHigh).
;@ test: skip part of the mover code
MoverHopHigh::
;> return StepMoverArc(ArcHopHigh, pos)
	ld bc, ArcHopHigh
	jp StepMoverArc


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $02, a high hop.
ArcHopHigh::
	db $fb, $ff, $fb, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff
	db $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $80, $80

;@ def MoverLeapSpin(pos: hl)
;@ path: event/movers
;@ Mover type $03 (Terry): a long leap up off the screen and back down (ArcLeapSpin) while he
;@ spins round (one turn on 3 of 4 field frames).
;@ test: skip part of the mover code
MoverLeapSpin::
;> StepMoverArc(ArcLeapSpin, pos)
	ld bc, ArcLeapSpin
	call StepMoverArc
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> if wFieldTimer & 3 == 0:
;>     return
	ld a, [wFieldTimer]
	and $03
	ret z

;> hPlayerDir = (hPlayerDir + 1) & 3
	ldh a, [hPlayerDir]
	inc a
	and $03
	ldh [hPlayerDir], a
;> return SetPlayerPoseFromDir()
	jp SetPlayerPoseFromDir


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover types $03 / $13, a leap up and back down.
ArcLeapSpin::
	db $fe, $ff, $fe, $ff, $fe, $ff, $fd, $ff, $fd, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $80, $80

;@ def MoverHop(pos: hl)
;@ path: event/movers
;@ Mover type $04: a hop (ArcHop).
;@ test: skip part of the mover code
MoverHop::
;> return StepMoverArc(ArcHop, pos)
	ld bc, ArcHop
	jp StepMoverArc


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $04, a hop.
ArcHop::
	db $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00
	db $80, $80

;@ def MoverDoubleHopRight(pos: hl)
;@ path: event/movers
;@ Mover type $05 (actors): two hops (ArcDoubleHopRight) while moving 2 pixels a frame to the
;@ right (only the low byte of the actor's X changes).
;@ test: skip part of the mover code
MoverDoubleHopRight::
;> StepMoverArc(ArcDoubleHopRight, pos)
	ld bc, ArcDoubleHopRight
	call StepMoverArc
;>@x actor = mem16[hNumber]; mem[actor + 0x18] += 2                 # actor in hNumber
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@x
	inc [hl]
	inc [hl]
	ret


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $05, two hops.
ArcDoubleHopRight::
	db $fb, $ff, $fb, $ff, $fb, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff
	db $fe, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00
	db $02, $00, $02, $00, $02, $00, $03, $00, $03, $00, $03, $00, $04, $00, $04, $00
	db $04, $00, $fa, $ff, $fc, $ff, $fd, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $03, $00, $04, $00, $06, $00, $80, $80

;@ def MoverFillTrail()
;@ path: event/movers
;@ Mover type $06 (Terry): for 63 frames writes his position into the party trail
;@ (wPlayerTrail) every frame, so the followers gather on him.
;@ test: skip part of the mover code
MoverFillTrail::
;> mover = mem16[hNumber + 2]; p = mover + 1
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;> frame = mem[p] + 1; mem[p] = frame
	ld a, [de]
	inc a
	ld [de], a
;> if frame == 0x40:
;>@d     mem[mover] = 0
;>@r     return
	cp $40
	jr nz, .trail

;=@d
	ldh a, [hNumber + 2]
	ld l, a
	ldh a, [hNumber + 3]
	ld h, a
	ld [hl], $00
;=@r
	ret


.trail
;>@t entry = wPlayerTrail + 4 * wTrailPos
	ld a, [wTrailPos]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld a, l
;=@t
	add LOW(wPlayerTrail)
	ld l, a
	ld a, h
	adc HIGH(wPlayerTrail)
	ld h, a
;>@m mem[entry:entry + 4] = [hPlayerX & 0xFF, hPlayerY & 0xFF, (hPlayerX >> 8) << 4 | hPlayerY >> 8, hPlayerFrame | hPlayerAttr]
	ldh a, [hPlayerX]
	ld [hli], a
	ldh a, [hPlayerY]
	ld [hli], a
	ldh a, [hPlayerX + 1]
	swap a
;=@m
	ld c, a
	ldh a, [hPlayerY + 1]
	or c
	ld [hli], a
	ldh a, [hPlayerFrame]
	ld c, a
;=@m
	ldh a, [hPlayerAttr]
	or c
	ld [hli], a
;>@w wTrailPos = (wTrailPos + 1) % 49
	ld a, [wTrailPos]
	inc a
	ld [wTrailPos], a
	cp $31
	ret c

	xor a
;=@w
	ld [wTrailPos], a
	ret


;@ def MoverHopLeft(pos: hl)
;@ path: event/movers
;@ Mover type $07 (Terry): a hop (ArcHopLeft) while moving 2 pixels a frame to the left.
;@ test: skip part of the mover code
MoverHopLeft::
;> StepMoverArc(ArcHopLeft, pos)
	ld bc, ArcHopLeft
	call StepMoverArc
;>@x hPlayerX -= 2
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [hPlayerX + 1]
	ld h, a
	ld a, l
	sub $02
;=@x
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [hPlayerX], a
;=@x
	ld a, h
	ldh [hPlayerX + 1], a
	ret


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $07, a hop to the left.
ArcHopLeft::
	db $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $01, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00, $04, $00, $80, $80

;@ def MoverBlinkIn()
;@ path: event/movers
;@ Mover type $08 (actors): the actor blinks, faster and faster (every 16, 8, 4, 2 frames), for
;@ 255 frames and is then shown (record +0: $40 hidden, 0 shown).
;@ test: skip part of the mover code
MoverBlinkIn::
;> mover = mem16[hNumber + 2]; p = mover + 1
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;> frame = mem[p] + 1; mem[p] = frame
	ld a, [de]
	inc a
	ld [de], a
;> if frame == 0xFF:
;>@e     mem[mover] = 0
;>@g     actor = mem16[hNumber]; mem[actor] = 0
;>@h     return
	cp $ff
	jr nz, .blink

;=@e
	ldh a, [hNumber + 2]
	ld l, a
	ldh a, [hNumber + 3]
	ld h, a
	ld [hl], $00
;=@g
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld [hl], $00
;=@h
	ret


.blink
;>@k actor = mem16[hNumber]; mask = 0x0F if frame < 0x20 else 0x07 if frame < 0x50 else 0x03 if frame < 0x90 else 0x01
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	pop af
;=@k
	ld b, $0f
	cp $20
	jr c, .set

	ld b, $07
	cp $50
	jr c, .set

;=@k
	ld b, $03
	cp $90
	jr c, .set

	ld b, $01

.set
;> mem[actor] = 0x00 if frame & mask == 0 else 0x40
	and b
	or a
	ld [hl], $00
	ret z

	ld [hl], $40
	ret


;@ def MoverSpinHop(pos: hl)
;@ path: event/movers
;@ Mover type $09 (actors): a hop (ArcSpinHop) while the actor spins round (direction from the
;@ frame counter). Then Terry's pose is refreshed too.
;@ test: skip part of the mover code
MoverSpinHop::
;> StepMoverArc(ArcSpinHop, pos)
	ld bc, ArcSpinHop
	call StepMoverArc
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;>@a actor = mem16[hNumber]; mem[actor + 5] = 0
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@a
	ld [hl], $00
;>@b mover = mem16[hNumber + 2]; dir = (mem[mover + 1] >> 2) & 3
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;=@b
	ld a, [de]
	srl a
	srl a
	and $03
	push af
;>@c mem[actor + 6] = dir
	ldh a, [hNumber]
	add $06
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@c
	pop af
	ld [hl], a
;> return SetPlayerPoseFromDir()
	jp SetPlayerPoseFromDir


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $09, a hop.
ArcSpinHop::
	db $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00
	db $80, $80

;@ def MoverRise(pos: hl)
;@ path: event/movers
;@ Mover type $0A (actors): a quick rise (ArcRise).
;@ test: skip part of the mover code
MoverRise::
;> return StepMoverArc(ArcRise, pos)
	ld bc, ArcRise
	jp StepMoverArc


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $0A, a rise.
ArcRise::
	db $fb, $ff, $fb, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff
	db $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $80, $80

;@ def MoverDoubleHop(pos: hl)
;@ path: event/movers
;@ Mover type $0B (actors): two hops (ArcDoubleHop).
;@ test: skip part of the mover code
MoverDoubleHop::
;> return StepMoverArc(ArcDoubleHop, pos)
	ld bc, ArcDoubleHop
	jp StepMoverArc


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $0B, two hops.
ArcDoubleHop::
	db $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $01, $00, $01, $00, $02, $00
	db $02, $00, $02, $00, $00, $00, $00, $00, $00, $00, $fb, $ff, $fb, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $80, $80

;@ def MoverFallLeft(pos: hl)
;@ path: event/movers
;@ Mover type $0C (actors): falls faster and faster (ArcFallLeft) while moving 2 pixels a frame
;@ to the left (low byte of X only).
;@ test: skip part of the mover code
MoverFallLeft::
;> StepMoverArc(ArcFallLeft, pos)
	ld bc, ArcFallLeft
	call StepMoverArc
;>@x actor = mem16[hNumber]; mem[actor + 0x18] -= 2
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@x
	dec [hl]
	dec [hl]
	ret


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $0C, a fall.
ArcFallLeft::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $03, $00, $02, $00, $03, $00
	db $80, $80

;@ def MoverBlinkOut()
;@ path: event/movers
;@ Mover type $0D (actors): the actor blinks faster and faster for 255 frames and is then hidden
;@ (record +0 = $40) - the reverse of MoverBlinkIn.
;@ test: skip part of the mover code
MoverBlinkOut::
;> mover = mem16[hNumber + 2]; p = mover + 1
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;> frame = mem[p] + 1; mem[p] = frame
	ld a, [de]
	inc a
	ld [de], a
;> if frame == 0xFF:
;>@e     mem[mover] = 0
;>@g     actor = mem16[hNumber]; mem[actor] = 0x40
;>@h     return
	cp $ff
	jr nz, .blink

;=@e
	ldh a, [hNumber + 2]
	ld l, a
	ldh a, [hNumber + 3]
	ld h, a
	ld [hl], $00
;=@g
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld [hl], $40
;=@h
	ret


.blink
;>@k actor = mem16[hNumber]; mask = 0x0F if frame < 0x20 else 0x07 if frame < 0x50 else 0x03 if frame < 0x90 else 0x01
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	pop af
;=@k
	ld b, $0f
	cp $20
	jr c, .set

	ld b, $07
	cp $50
	jr c, .set

;=@k
	ld b, $03
	cp $90
	jr c, .set

	ld b, $01

.set
;> mem[actor] = 0x40 if frame & mask == 0 else 0x00
	and b
	or a
	ld [hl], $40
	ret z

	ld [hl], $00
	ret


;@ def MoverFloatUp(pos: hl)
;@ path: event/movers
;@ Mover type $0E (actors): floats up one pixel every 4th field frame, 16 times (ArcFloatUp).
;@ test: skip part of the mover code
MoverFloatUp::
;> if wFieldTimer & 3:
;>     return
	ld a, [wFieldTimer]
	and $03
	ret nz

;> return StepMoverArc(ArcFloatUp, pos)
	ld bc, ArcFloatUp
	jp StepMoverArc


;@ path: event/movers
;@ Y offsets (signed u16 per step, $80 ends) of mover type $0E: 16 times -1.
ArcFloatUp::
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $80, $80

;@ def MoverLaunch(pos: hl)
;@ path: event/movers
;@ Mover type $0F (actors): shoots up fast, slows and comes back down a little (ArcLaunch).
;@ test: skip part of the mover code
MoverLaunch::
;> return StepMoverArc(ArcLaunch, pos)
	ld bc, ArcLaunch
	jp StepMoverArc


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $0F.
ArcLaunch::
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00
	db $03, $00, $03, $00, $80, $80

;@ def MoverDrop(pos: hl)
;@ path: event/movers
;@ Mover type $10 (actors): a small hop, then a long fall (ArcDrop).
;@ test: skip part of the mover code
MoverDrop::
;> return StepMoverArc(ArcDrop, pos)
	ld bc, ArcDrop
	jp StepMoverArc


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $10.
ArcDrop::
	db $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00
	db $03, $00, $03, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $80, $80

;@ def MoverFallFast(pos: hl)
;@ path: event/movers
;@ Mover type $11 (actors): falls 3 pixels a frame for 22 frames, then 4 (ArcFallFast).
;@ test: skip part of the mover code
MoverFallFast::
;> return StepMoverArc(ArcFallFast, pos)
	ld bc, ArcFallFast
	jp StepMoverArc


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $11.
ArcFallFast::
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $04, $00, $80, $80

;@ def MoverHopDrop(pos: hl)
;@ path: event/movers
;@ Mover type $12 (actors): a hop that ends lower than it started (ArcHopDrop).
;@ test: skip part of the mover code
MoverHopDrop::
;> return StepMoverArc(ArcHopDrop, pos)
	ld bc, ArcHopDrop
	jp StepMoverArc


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $12.
ArcHopDrop::
	db $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00
	db $03, $00, $03, $00, $04, $00, $04, $00, $04, $00, $05, $00, $05, $00, $05, $00
	db $05, $00, $80, $80

;@ def MoverLeap(pos: hl)
;@ path: event/movers
;@ Mover type $13 (actors): the long leap up and back down of type $03, without spinning
;@ (ArcLeap).
;@ test: skip part of the mover code
MoverLeap::
;> return StepMoverArc(ArcLeap, pos)
	ld bc, ArcLeap
	jp StepMoverArc


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $13, the same leap as ArcLeapSpin.
ArcLeap::
	db $fe, $ff, $fe, $ff, $fe, $ff, $fd, $ff, $fd, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00
	db $80, $80

;@ def MoverBlinkSpin()
;@ path: event/movers
;@ Mover type $14 (actors): blinks (BlinkActorSlow, every other field frame) while spinning round;
;@ then Terry's pose is refreshed too.
;@ test: skip part of the mover code
MoverBlinkSpin::
;> BlinkActorSlow()
	call BlinkActorSlow
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;>@a actor = mem16[hNumber]; mem[actor + 5] = 0
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@a
	ld [hl], $00
;>@b mover = mem16[hNumber + 2]; dir = (mem[mover + 1] >> 2) & 3
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;=@b
	ld a, [de]
	srl a
	srl a
	and $03
	push af
;>@c mem[actor + 6] = dir
	ldh a, [hNumber]
	add $06
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@c
	pop af
	ld [hl], a
;> return SetPlayerPoseFromDir()
	jp SetPlayerPoseFromDir


;@ def BlinkActorSlow()
;@ path: event/movers
;@ The blink of MoverBlinkIn at half speed (only on even field frames): faster and faster over
;@ 255 steps, then the actor is shown and the mover freed.
;@ test: skip part of the mover code
BlinkActorSlow::
;> if wFieldTimer & 1:
;>     return
	ld a, [wFieldTimer]
	and $01
	ret nz

;> mover = mem16[hNumber + 2]; p = mover + 1
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;> frame = mem[p] + 1; mem[p] = frame
	ld a, [de]
	inc a
	ld [de], a
;> if frame == 0xFF:
;>@e     mem[mover] = 0
;>@g     actor = mem16[hNumber]; mem[actor] = 0
;>@h     return
	cp $ff
	jr nz, .blink

;=@e
	ldh a, [hNumber + 2]
	ld l, a
	ldh a, [hNumber + 3]
	ld h, a
	ld [hl], $00
;=@g
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld [hl], $00
;=@h
	ret


.blink
;>@k actor = mem16[hNumber]; mask = 0x0F if frame < 0x20 else 0x07 if frame < 0x50 else 0x03 if frame < 0x90 else 0x01
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	pop af
;=@k
	ld b, $0f
	cp $20
	jr c, .set

	ld b, $07
	cp $50
	jr c, .set

;=@k
	ld b, $03
	cp $90
	jr c, .set

	ld b, $01

.set
;> mem[actor] = 0x00 if frame & mask == 0 else 0x40
	and b
	or a
	ld [hl], $00
	ret z

	ld [hl], $40
	ret


;@ def MoverFallArcLeft(pos: hl)
;@ path: event/movers
;@ Mover type $15 (actors): falls along one of four fall curves (ArcFall1-4, chosen by wJumpFall)
;@ while moving 2 pixels a frame to the left. The curve is entered at frame
;@ (10 - wJumpHeight) * 8 + 1, so a lower jump starts further along the fall.
;@ test: skip part of the mover code
MoverFallArcLeft::
;> mover = mem16[hNumber + 2]; p = mover + 1
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;> if mem[p] == 0:
	ld a, [de]
	or a
	jr nz, .table

;>@s     mem[p] = (10 - wJumpHeight) * 8 + 1
	ld a, [wJumpHeight]
	ld c, a
	ld a, $0a
	sub c
	add a
	add a
;=@s
	add a
	inc a
	ld [de], a

.table
;>@t table = (ArcFall1, ArcFall2, ArcFall3, ArcFall4)[wJumpFall - 1]   # anything else: ArcFall4
	ld a, [wJumpFall]
	ld bc, ArcFall1
	cp $01
	jr z, .step

	ld bc, ArcFall2
;=@t
	cp $02
	jr z, .step

	ld bc, ArcFall3
	cp $03
	jr z, .step

;=@t
	ld bc, ArcFall4

.step
;> StepMoverArc(table, pos)
	call StepMoverArc
;>@x actor = mem16[hNumber]; mem16[actor + 0x18] -= 2
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@x
	ld a, [hli]
	ld b, [hl]
	ld c, a
	dec bc
	dec bc
	ld a, b
;=@x
	ld [hld], a
	ld [hl], c
	ret


;@ path: event/movers
;@ Fall curve 1 of mover types $15/$16 (wJumpFall 1): Y offsets (signed u16 per frame, $80 ends);
;@ the long run of zeros is the top of the curve that a high jump starts in.
ArcFall1::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00
	db $80, $80

;@ path: event/movers
;@ Fall curve 2 of mover types $15/$16 (wJumpFall 2), same layout as ArcFall1.
ArcFall2::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $01, $00
	db $01, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00, $02, $00, $03, $00
	db $80, $80

;@ path: event/movers
;@ Fall curve 3 of mover types $15/$16 (wJumpFall 3), same layout as ArcFall1.
ArcFall3::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $03, $00, $02, $00, $03, $00, $03, $00, $03, $00
	db $80, $80

;@ path: event/movers
;@ Fall curve 4 of mover types $15/$16 (wJumpFall 4 or more), same layout as ArcFall1.
ArcFall4::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $03, $00, $02, $00
	db $02, $00, $03, $00, $02, $00, $03, $00, $04, $00, $03, $00, $04, $00, $04, $00
	db $80, $80

;@ def MoverFallArcRight(pos: hl)
;@ path: event/movers
;@ Mover type $16 (actors): the fall of type $15 while moving 2 pixels a frame to the right.
;@ test: skip part of the mover code
MoverFallArcRight::
;> mover = mem16[hNumber + 2]; p = mover + 1
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;> if mem[p] == 0:
	ld a, [de]
	or a
	jr nz, .table

;>@s     mem[p] = (10 - wJumpHeight) * 8 + 1
	ld a, [wJumpHeight]
	ld c, a
	ld a, $0a
	sub c
	add a
	add a
;=@s
	add a
	inc a
	ld [de], a

.table
;>@t table = (ArcFall1, ArcFall2, ArcFall3, ArcFall4)[wJumpFall - 1]
	ld a, [wJumpFall]
	ld bc, ArcFall1
	cp $01
	jr z, .step

	ld bc, ArcFall2
;=@t
	cp $02
	jr z, .step

	ld bc, ArcFall3
	cp $03
	jr z, .step

;=@t
	ld bc, ArcFall4

.step
;> StepMoverArc(table, pos)
	call StepMoverArc
;>@x actor = mem16[hNumber]; mem16[actor + 0x18] += 2
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@x
	ld a, [hli]
	ld b, [hl]
	ld c, a
	inc bc
	inc bc
	ld a, b
;=@x
	ld [hld], a
	ld [hl], c
	ret


;@ def MoverThrowLeft(pos: hl)
;@ path: event/movers
;@ Mover type $17 (actors): thrown up along one of ten rise curves (ArcThrow1-10, chosen by
;@ wJumpHeight; the offsets are subtracted from Y) while moving 2 pixels a frame to the left.
;@ test: skip part of the mover code
MoverThrowLeft::
;>@t table = (ArcThrow1, ..., ArcThrow10)[wJumpHeight - 1]       # anything else: ArcThrow10
	ld a, [wJumpHeight]
	ld bc, ArcThrow1
	cp $01
	jr z, .step

	ld bc, ArcThrow2
;=@t
	cp $02
	jr z, .step

	ld bc, ArcThrow3
	cp $03
	jr z, .step

;=@t
	ld bc, ArcThrow4
	cp $04
	jr z, .step

	ld bc, ArcThrow5
	cp $05
;=@t
	jr z, .step

	ld bc, ArcThrow6
	cp $06
	jr z, .step

	ld bc, ArcThrow7
	cp $07
;=@t
	jr z, .step

	ld bc, ArcThrow8
	cp $08
	jr z, .step

	ld bc, ArcThrow9
	cp $09
;=@t
	jr z, .step

	ld bc, ArcThrow10

.step
;> mover = mem16[hNumber + 2]; p = mover + 1
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;> frame = mem[p]; mem[p] += 1
	ld a, [de]
	push af
	inc a
	ld [de], a
	pop af
;>@e entry = table + 2 * frame
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
;> if mem[entry] == 0x80:
;>     return MoverDone()
	ld a, [bc]
	cp $80
	jp z, MoverDone

;>@y mem16[pos] -= mem16[entry]
	ld d, a
	ld a, [hl]
	sub d
	ld [hli], a
	inc bc
	ld a, [bc]
;=@y
	ld d, a
	ld a, [hl]
	sbc d
	ld [hl], a
;>@x actor = mem16[hNumber]; mem16[actor + 0x18] -= 2
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@x
	ld a, [hli]
	ld b, [hl]
	ld c, a
	dec bc
	dec bc
	ld a, b
;=@x
	ld [hld], a
	ld [hl], c
	ret


;@ path: event/movers
;@ Rise curve 1 of mover types $17/$18 (wJumpHeight 1, the lowest throw): offsets (u16 per frame)
;@ subtracted from Y, $80 ends.
ArcThrow1::
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $80, $80

;@ path: event/movers
;@ Rise curve 2 of mover types $17/$18 (wJumpHeight 2).
ArcThrow2::
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $80, $80

;@ path: event/movers
;@ Rise curve 3 of mover types $17/$18 (wJumpHeight 3).
ArcThrow3::
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $80, $80

;@ path: event/movers
;@ Rise curve 4 of mover types $17/$18 (wJumpHeight 4).
ArcThrow4::
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $80, $80

;@ path: event/movers
;@ Rise curve 5 of mover types $17/$18 (wJumpHeight 5).
ArcThrow5::
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $80

;@ path: event/movers
;@ Rise curve 6 of mover types $17/$18 (wJumpHeight 6).
ArcThrow6::
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $80

;@ path: event/movers
;@ Rise curve 7 of mover types $17/$18 (wJumpHeight 7).
ArcThrow7::
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $80

;@ path: event/movers
;@ Rise curve 8 of mover types $17/$18 (wJumpHeight 8).
ArcThrow8::
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $80

;@ path: event/movers
;@ Rise curve 9 of mover types $17/$18 (wJumpHeight 9).
ArcThrow9::
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $80

;@ path: event/movers
;@ Rise curve 10 of mover types $17/$18 (wJumpHeight 10, the highest throw).
ArcThrow10::
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $80

;@ def MoverThrowRight(pos: hl)
;@ path: event/movers
;@ Mover type $18 (actors): the throw of type $17 while moving 2 pixels a frame to the right.
;@ test: skip part of the mover code
MoverThrowRight::
;>@t table = (ArcThrow1, ..., ArcThrow10)[wJumpHeight - 1]
	ld a, [wJumpHeight]
	ld bc, ArcThrow1
	cp $01
	jr z, .step

	ld bc, ArcThrow2
;=@t
	cp $02
	jr z, .step

	ld bc, ArcThrow3
	cp $03
	jr z, .step

;=@t
	ld bc, ArcThrow4
	cp $04
	jr z, .step

	ld bc, ArcThrow5
	cp $05
;=@t
	jr z, .step

	ld bc, ArcThrow6
	cp $06
	jr z, .step

	ld bc, ArcThrow7
	cp $07
;=@t
	jr z, .step

	ld bc, ArcThrow8
	cp $08
	jr z, .step

	ld bc, ArcThrow9
	cp $09
;=@t
	jr z, .step

	ld bc, ArcThrow10

.step
;> mover = mem16[hNumber + 2]; p = mover + 1
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;> frame = mem[p]; mem[p] += 1
	ld a, [de]
	push af
	inc a
	ld [de], a
	pop af
;>@e entry = table + 2 * frame
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
;> if mem[entry] == 0x80:
;>     return MoverDone()
	ld a, [bc]
	cp $80
	jp z, MoverDone

;>@y mem16[pos] -= mem16[entry]
	ld d, a
	ld a, [hl]
	sub d
	ld [hli], a
	inc bc
	ld a, [bc]
;=@y
	ld d, a
	ld a, [hl]
	sbc d
	ld [hl], a
;>@x actor = mem16[hNumber]; mem16[actor + 0x18] += 2
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@x
	ld a, [hli]
	ld b, [hl]
	ld c, a
	inc bc
	inc bc
	ld a, b
;=@x
	ld [hld], a
	ld [hl], c
	ret


;@ def MoverHopLeft2(pos: hl)
;@ path: event/movers
;@ Mover type $19 (actors): two hops (ArcHopLeft2) while moving 2 pixels a frame to the left
;@ (low byte of X only).
;@ test: skip part of the mover code
MoverHopLeft2::
;> StepMoverArc(ArcHopLeft2, pos)
	ld bc, ArcHopLeft2
	call StepMoverArc
;>@x actor = mem16[hNumber]; mem[actor + 0x18] -= 2
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [hNumber + 1]
	adc $00
	ld h, a
;=@x
	dec [hl]
	dec [hl]
	ret


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $19, two hops.
ArcHopLeft2::
	db $fa, $ff, $fc, $ff, $fd, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $01, $00, $01, $00, $02, $00, $03, $00, $04, $00, $06, $00, $fc, $ff, $fc, $ff
	db $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $02, $00, $03, $00
	db $03, $00, $04, $00, $04, $00, $04, $00, $05, $00, $05, $00, $05, $00, $80, $80

;@ def MoverSpinHop2(pos: hl)
;@ path: event/movers
;@ Mover type $1A (Terry): a hop (ArcSpinHop2) while he spins round (direction from the frame
;@ counter).
;@ test: skip part of the mover code
MoverSpinHop2::
;> StepMoverArc(ArcSpinHop2, pos)
	ld bc, ArcSpinHop2
	call StepMoverArc
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;>@d mover = mem16[hNumber + 2]; hPlayerDir = (mem[mover + 1] >> 2) & 3
	ldh a, [hNumber + 2]
	add $01
	ld e, a
	ldh a, [hNumber + 3]
	adc $00
	ld d, a
;=@d
	ld a, [de]
	srl a
	srl a
	and $03
	ldh [hPlayerDir], a
;> return SetPlayerPoseFromDir()
	jp SetPlayerPoseFromDir


;@ path: event/movers
;@ Y offsets (signed u16 per frame, $80 ends) of mover type $1A, a hop.
ArcSpinHop2::
	db $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00
	db $80, $80

;@ def StartScript()
;@ path: event/script
;@ Starts script wScriptId of map wScriptMap (far entry $0405) at its first word and runs it up
;@ to the first command that waits.
;@ test: skip runs script commands from banks $0C-$0F
StartScript::
;> wScriptPos = 0
	xor a
	ld [wScriptPos], a
	ld [wScriptPos + 1], a
;> return RunScriptCommand()
	jr RunScriptCommand

;@ def NextScriptCommand()
;@ path: event/script
;@ Moves on to the next script word and runs it (RunScriptCommand). A script is a list of 16-bit
;@ words: $FFFF ends it, $FFxx is command xx (ScriptCommandTable; its arguments are the words that
;@ follow), any other word is the number of a message to print, after which the script goes on.
;@ test: skip runs script commands from banks $0C-$0F
NextScriptCommand::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a

RunScriptCommand:
;> word = ReadScriptWord()
	call ReadScriptWord
;> if word == 0xFFFF:                     # end of the script
	ld a, b
	and c
	cp $ff
	jr nz, .notEnd

;>     wScriptRunning = 0
;>     return
	xor a
	ld [wScriptRunning], a
	ret


.notEnd
;> wScriptRunning |= 0x01
	ld hl, wScriptRunning
	set 0, [hl]
;> if word >> 8 != 0xFF:                  # a message
;>     return ScriptQueueMessage(word)
	ld a, b
	cp $ff
	jp nz, ScriptQueueMessage

;> return ScriptCommandTable[word & 0xFF]()
	ld a, c
	rst $00

;@ path: event/script
;@ Handlers of the script commands $FF00-$FF65 (the low byte of the command word is the index).
ScriptCommandTable::
	dw ScriptCmdJumpIfFlagClear
	dw ScriptCmdJumpIfFlagSet
	dw ScriptCmdClearFlag
	dw ScriptCmdSetFlag
	dw ScriptCmdOpenFieldMenu
	dw ScriptCmdBattle
	dw ScriptCmdNextEventStep
	dw ScriptCmdStartEvent
	dw ScriptCmdNop
	dw ScriptCmdWait
	dw ScriptCmdWalkX
	dw ScriptCmdWalkY
	dw ScriptCmdFace
	dw ScriptCmdSetActorByte
	dw ScriptCmdJumpIfScreen
	dw ScriptCmdWarp
	dw ScriptCmdWalkToX
	dw ScriptCmdWalkToY
	dw ScriptCmdWriteByte
	dw ScriptCmdWriteWord
	dw ScriptCmdJump
	dw ScriptCmdJumpIfByte
	dw ScriptCmdRedrawFollowers
	dw ScriptCmdSwapTiles
	dw ScriptCmdGiveMonster
	dw ScriptCmdWaitMovers
	dw ScriptCmdMoveX
	dw ScriptCmdMoveY
	dw ScriptCmdStartMover
	dw ScriptCmdKeepFacing
	dw ScriptCmdTurnWhileMoving
	dw ScriptCmdSetupArenaBattle
	dw ScriptCmdStartBattle
	dw ScriptCmdPlaySound
	dw ScriptCmdFastMovers
	dw ScriptCmdJumpIfHasSkillsA
	dw ScriptCmdDrawScriptTiles
	dw ScriptCmdReleaseMonster
	dw ScriptCmdFadeOut
	dw ScriptCmdHealParty
	dw ScriptCmdJumpIfMonstersFull
	dw ScriptCmdAddMonster
	dw ScriptCmdGiveItem
	dw ScriptCmdJumpIfNamedMonster
	dw ScriptCmdJumpIfBagFull
	dw ScriptCmdMonsterReaction
	dw ScriptCmdPickFromTable
	dw ScriptCmdIncByte
	dw ScriptCmdJumpIfAttack100
	dw ScriptCmdJumpIfLibrary100
	dw ScriptCmdJumpIfSpeciesAF
	dw ScriptCmdGiveGold
	dw ScriptCmdJumpIfHasSkillsB
	dw ScriptCmdHealParty2
	dw ScriptCmdBossBattle
	dw ScriptCmdGivePrizeItem
	dw ScriptCmdJumpIfHasSkillsC
	dw ScriptCmdPrintMessage
	dw ScriptCmdLeaderLeaves
	dw ScriptCmdWarpNoFade
	dw ScriptCmdSetScriptFlag0
	dw ScriptCmdSetScriptFlag1
	dw ScriptCmdEndGameMode
	dw ScriptCmdCopyLeaderSpecies
	dw ScriptCmdJumpIfOwnsSpecies
	dw ScriptCmdPlayMusic
	dw ScriptCmdSaveReturnMenu
	dw ScriptCmdReturnWarp
	dw ScriptCmdReturnMenuText
	dw ScriptCmdRestoreParty
	dw ScriptCmdWaitSoundEnd
	dw ScriptCmdActorFaceUp
	dw ScriptCmdActorFaceDown
	dw ScriptCmdActorFaceLeft
	dw ScriptCmdActorFaceRight
	dw ScriptCmdRestoreMusic
	dw ScriptCmdWaitDPad
	dw ScriptCmdWaitFrames
	dw ScriptCmdSaveReturnPoint
	dw ScriptCmdReturnWarp2
	dw ScriptCmdReturnFace
	dw ScriptCmdLibraryRank
	dw ScriptCmdRandomBattle
	dw ScriptCmdFaceActor1
	dw ScriptCmdGiveRandomItem
	dw ScriptCmdLoseRandomItem
	dw ScriptCmdLoseTenthOfGold
	dw ScriptCmdGiveRandomSeed
	dw ScriptCmdSkipFloors
	dw ScriptCmdBoostWeakestStat
	dw ScriptCmdSpecialBattle
	dw ScriptCmdStartSpecialBattle
	dw ScriptCmdSetupTournament
	dw ScriptCmdGivePrize
	dw ScriptCmdStartShootingStars
	dw ScriptCmdJumpIfLevelBelowCap
	dw ScriptCmdPayPerLevel
	dw ScriptCmdDrawScriptAttrs
	dw ScriptCmdBlankScreen
	dw ScriptCmdRedrawScreen
	dw ScriptCmdJumpIfPartyFit
	dw ScriptCmdWaitChannelsEnd

;@ def ScriptQueueMessage(message: bc)
;@ path: event/script
;@ A script word that is not a command: keeps it as the message to print (wScriptMessage) and
;@ sets wScriptRunning bit 1; the script stops until the field has printed it.
;@ test: skip part of the script engine
ScriptQueueMessage::
;> wScriptRunning |= 0x02
	ld hl, wScriptRunning
	set 1, [hl]
;> wScriptMessage = message
	ld a, c
	ld [wScriptMessage], a
	ld a, b
	ld [wScriptMessage + 1], a
	ret


;@ def PrintScriptMessage()
;@ path: event/script
;@ Prints the message a script asked for (far entry $0406, called by the field event code) and
;@ lets the script go on.
;@ test: skip prints text
PrintScriptMessage::
;> if not wScriptRunning & 0x02:
;>     return
	ld a, [wScriptRunning]
	bit 1, a
	ret z

;> wScriptRunning &= ~0x02
	ld hl, wScriptRunning
	res 1, [hl]
;> PrintMessage(wScriptMessage)
	ld a, [wScriptMessage]
	ld l, a
	ld a, [wScriptMessage + 1]
	ld h, a
	call PrintMessage
	ret


;@ def ScriptCmdJumpIfFlagClear()
;@ path: event/script-commands
;@ Command $00 flag, target: goes on at `target` (a script address) if event flag `flag` is clear.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfFlagClear::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> flag = ReadScriptWord()
	call ReadScriptWord
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> if TestEventFlag(flag):
;>     return NextScriptCommand()
	call TestEventFlag
	jp nz, NextScriptCommand

;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdJumpIfFlagSet()
;@ path: event/script-commands
;@ Command $01 flag, target: goes on at `target` if event flag `flag` is set.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfFlagSet::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> flag = ReadScriptWord()
	call ReadScriptWord
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> if not TestEventFlag(flag):
;>     return NextScriptCommand()
	call TestEventFlag
	jp z, NextScriptCommand

;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdClearFlag()
;@ path: event/script-commands
;@ Command $02 flag: clears event flag `flag`.
;@ test: skip reads script words through far calls
ScriptCmdClearFlag::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> ClearEventFlag(ReadScriptWord())
	call ReadScriptWord
	call ClearEventFlag
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdSetFlag()
;@ path: event/script-commands
;@ Command $03 flag: sets event flag `flag`.
;@ test: skip reads script words through far calls
ScriptCmdSetFlag::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> SetEventFlag(ReadScriptWord())
	call ReadScriptWord
	call SetEventFlag
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdOpenFieldMenu()
;@ path: event/script-commands
;@ Command $04 menu, text: opens field window `menu` (wScriptMenu: shops, inn, farm and the other
;@ services) with base message `text` (wFieldFlags bit 4); the script stops. All but windows 9
;@ and 10 open with sound $59.
;@ test: skip reads script words through far calls
ScriptCmdOpenFieldMenu::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wScriptMenu = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
	ld [wScriptMenu], a
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wScriptMenuText = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wScriptMenuText], a
	ld a, b
	ld [wScriptMenuText + 1], a
;> wFieldFlags |= 0x10
	ld hl, wFieldFlags
	set 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> if wScriptMenu == 9 or wScriptMenu == 10:
;>     return
	ld a, [wScriptMenu]
	cp $09
	ret z

	cp $0a
	ret z

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
	ret


;@ def ScriptCmdBattle()
;@ path: event/script-commands
;@ Command $05 species: starts a battle against one monster `species` (wBattleKind 1); the script
;@ stops.
;@ test: skip reads script words through far calls
ScriptCmdBattle::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mem16[wEncSpecies] = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wEncSpecies], a
	ld a, b
	ld [wEncSpecies + 1], a
;> wEncCount = 0                          # one monster
	xor a
	ld [wEncCount], a
;> wFieldFlags |= 0x40                    # start a battle
	ld hl, wFieldFlags
	set 6, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wBattleKind = 1
	ld a, $01
	ld [wBattleKind], a
	ret


;@ def ScriptCmdNextEventStep()
;@ path: event/script-commands
;@ Command $06: during a field event, moves it on to its next step.
;@ test: skip part of the script engine
ScriptCmdNextEventStep::
;> if wFieldFlags & 0x01:
;>     wEventStep += 1
	ld a, [wFieldFlags]
	bit 0, a
	ret z

	ld hl, wEventStep
	inc [hl]
	ret


;@ def ScriptCmdStartEvent()
;@ path: event/script-commands
;@ Command $07: starts a field event without a routine (wEventRoutine $FFFF), unless one runs.
;@ test: skip part of the script engine
ScriptCmdStartEvent::
;> if wFieldFlags & 0x01:
;>     return
	ld a, [wFieldFlags]
	bit 0, a
	ret nz

;> wEventRoutine = 0xFFFF
	ld hl, $ffff
	ld a, l
	ld [wEventRoutine], a
	ld a, h
	ld [wEventRoutine + 1], a
;> wFieldFlags |= 0x01
	ld hl, wFieldFlags
	set 0, [hl]
;> wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [wEventStep + 1], a
	ret


;@ def ScriptCmdNop()
;@ path: event/script-commands
;@ Command $08: does nothing (and stops the script for this frame).
ScriptCmdNop::
;> return
	ret


;@ def ScriptCmdWait()
;@ path: event/script-commands
;@ Command $09 n: waits n times 8 frames.
;@ test: skip reads script words through far calls
ScriptCmdWait::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wScriptWait = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
	ld [wScriptWait], a
;> wScriptRunning |= 0x04
	ld hl, wScriptRunning
	set 2, [hl]
	ret


;@ def ScriptCmdWalkX()
;@ path: event/script-commands
;@ Command $0A who, dx: walks Terry (who 0) or actor `who` dx pixels to the right (negative: left).
;@ test: skip reads script words through far calls
ScriptCmdWalkX::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wScriptWalker = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
	ld [wScriptWalker], a
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wScriptWalkX = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wScriptWalkX], a
	ld a, b
	ld [wScriptWalkX + 1], a
;> wScriptRunning |= 0x08
	ld hl, wScriptRunning
	set 3, [hl]
	ret


;@ def ScriptCmdWalkY()
;@ path: event/script-commands
;@ Command $0B who, dy: walks Terry (who 0) or actor `who` dy pixels down (negative: up).
;@ test: skip reads script words through far calls
ScriptCmdWalkY::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wScriptWalker = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
	ld [wScriptWalker], a
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wScriptWalkY = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wScriptWalkY], a
	ld a, b
	ld [wScriptWalkY + 1], a
;> wScriptRunning |= 0x08
	ld hl, wScriptRunning
	set 3, [hl]
	ret


;@ def ScriptCmdFace()
;@ path: event/script-commands
;@ Command $0C who, dir: turns Terry (who 0; sets his pose and mirroring too) or actor `who`
;@ (its direction byte, record +6) to direction `dir` (0 down, 1 left, 2 up, 3 right).
;@ test: skip reads script words through far calls
ScriptCmdFace::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> who = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> if who == 0:
	ld a, c
	or a
	jr nz, jr_004_5942

;>     wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;>     dir = ReadScriptWord() & 0xFF
	call ReadScriptWord

SetPlayerFacing:
;>     # SetPlayerFacing: also entered by the actor-facing commands for Terry
;>     if dir == 0:                       # down: front pose
	ld a, c
	or a
	jr nz, jr_004_590d

;>         hPlayerAttr = 0x00
	ld a, $00
	ldh [hPlayerAttr], a
;>         hPlayerPose = 0
	ld a, $00
	ldh [hPlayerPose], a
;>         hPlayerDir = 0
	ld a, $00
	ldh [hPlayerDir], a
	jp NextScriptCommand


jr_004_590d:
;>     elif dir == 1:                     # left: side pose, mirrored
	cp $01
	jr nz, jr_004_5920

;>         hPlayerAttr = 0x20
	ld a, $20
	ldh [hPlayerAttr], a
;>         hPlayerPose = 1
	ld a, $01
	ldh [hPlayerPose], a
;>         hPlayerDir = 1
	ld a, $01
	ldh [hPlayerDir], a
	jp NextScriptCommand


jr_004_5920:
;>     elif dir == 2:                     # up: back pose
	cp $02
	jr nz, jr_004_5933

;>         hPlayerAttr = 0x00
	ld a, $00
	ldh [hPlayerAttr], a
;>         hPlayerPose = 2
	ld a, $02
	ldh [hPlayerPose], a
;>         hPlayerDir = 2
	ld a, $02
	ldh [hPlayerDir], a
	jp NextScriptCommand


jr_004_5933:
;>     else:                              # right: side pose
;>         hPlayerAttr = 0x00
	ld a, $00
	ldh [hPlayerAttr], a
;>         hPlayerPose = 1
	ld a, $01
	ldh [hPlayerPose], a
;>         hPlayerDir = 3
	ld a, $03
	ldh [hPlayerDir], a
	jp NextScriptCommand


jr_004_5942:
;> else:
;>@p     dirp = wActors + 6 + 32 * (who - 1)
	dec a
	swap a
	add a
	ld hl, wActors + 6
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
	push hl
;>     wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;>     mem[dirp] = ReadScriptWord() & 0xFF
	call ReadScriptWord
	pop hl
	ld [hl], c
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdSetActorByte()
;@ path: event/script-commands
;@ Command $0D who, offset, value: writes `value` to byte `offset` of actor `who`'s record, or
;@ for who 0 to the address `offset` itself.
;@ test: skip reads script words through far calls
ScriptCmdSetActorByte::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> who = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> if who == 0:
	ld a, c
	or a
	jr nz, .actor

;>     wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;>     addr = ReadScriptWord()
	call ReadScriptWord
	ld l, c
	ld h, b
	jr .write

.actor
;> else:
;>@p     actor = wActors + 32 * (who - 1)
	dec a
	swap a
	add a
	ld hl, wActors
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
	push hl
;>     wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;>     addr = actor + ReadScriptWord()
	call ReadScriptWord
	pop hl
	add hl, bc

.write
;>@w wScriptPos += 1
	push hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
;=@w
	ld [wScriptPos + 1], a
;> mem[addr] = ReadScriptWord() & 0xFF
	call ReadScriptWord
	pop hl
	ld [hl], c
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdJumpIfScreen()
;@ path: event/script-commands
;@ Command $0E screen, target: goes on at `target` if Terry is on screen `screen` of the map
;@ (wMapScreen).
;@ test: skip reads script words through far calls
ScriptCmdJumpIfScreen::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> screen = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> if wMapScreen != screen:
;>     return NextScriptCommand()
	ld a, [wMapScreen]
	cp c
	jp nz, NextScriptCommand

;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdWarp()
;@ path: event/script-commands
;@ Command $0F map, x, y: fades out and warps to map `map` (high byte: the gate-floor flag) at
;@ position x, y; the script ends.
;@ test: skip reads script words through far calls
ScriptCmdWarp::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mem16[wWarpMap] = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wWarpMap], a
	ld a, b
	ld [wWarpOnGateFloor], a
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wWarpX = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wWarpX], a
	ld a, b
	ld [wWarpX + 1], a
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wWarpY = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wWarpY], a
	ld a, b
	ld [wWarpY + 1], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> StartFade(3)
	ld a, $03
	call StartFade
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> wFieldFlags &= ~0x01
	ld hl, wFieldFlags
	res 0, [hl]
;> wTextState = 0
	xor a
	ld [wTextState], a
	ret


;@ def ScriptCmdWalkToX()
;@ path: event/script-commands
;@ Command $10 who, x: walks Terry (who 0) or actor `who` horizontally to map X position `x`.
;@ test: skip reads script words through far calls
ScriptCmdWalkToX::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wScriptWalker = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
	ld [wScriptWalker], a
;> pos = hPlayerX
	ld hl, hPlayerX
	or a
	jr z, .read

;> if wScriptWalker != 0:
;>@x     pos = wActors + 0x18 + 32 * (wScriptWalker - 1)
	dec a
	swap a
	add a
	ld hl, wActors + $18
	add l
	ld l, a
;=@x
	ld a, $00
	adc h
	ld h, a

.read
;> x = mem16[pos]
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;>@d wScriptWalkX = ReadScriptWord() - x
	call ReadScriptWord
	pop hl
	ld a, c
	sub l
	ld c, a
	ld a, b
;=@d
	sbc h
	ld b, a
	ld a, c
	ld [wScriptWalkX], a
	ld a, b
	ld [wScriptWalkX + 1], a
;> wScriptRunning |= 0x08
	ld hl, wScriptRunning
	set 3, [hl]
	ret


;@ def ScriptCmdWalkToY()
;@ path: event/script-commands
;@ Command $11 who, y: walks Terry (who 0) or actor `who` vertically to map Y position `y`.
;@ test: skip reads script words through far calls
ScriptCmdWalkToY::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wScriptWalker = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
	ld [wScriptWalker], a
;> pos = hPlayerY
	ld hl, hPlayerY
	or a
	jr z, .read

;> if wScriptWalker != 0:
;>@x     pos = wActors + 0x1A + 32 * (wScriptWalker - 1)
	dec a
	swap a
	add a
	ld hl, wActors + $1a
	add l
	ld l, a
;=@x
	ld a, $00
	adc h
	ld h, a

.read
;> y = mem16[pos]
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;>@d wScriptWalkY = ReadScriptWord() - y
	call ReadScriptWord
	pop hl
	ld a, c
	sub l
	ld c, a
	ld a, b
;=@d
	sbc h
	ld b, a
	ld a, c
	ld [wScriptWalkY], a
	ld a, b
	ld [wScriptWalkY + 1], a
;> wScriptRunning |= 0x08
	ld hl, wScriptRunning
	set 3, [hl]
	ret


;@ def ScriptCmdWriteByte()
;@ path: event/script-commands
;@ Command $12 addr, value: writes the byte `value` to RAM address `addr`.
;@ test: skip reads script words through far calls
ScriptCmdWriteByte::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> addr = ReadScriptWord()
	call ReadScriptWord
	ld l, c
	ld h, b
	push hl
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mem[addr] = ReadScriptWord() & 0xFF
	call ReadScriptWord
	pop hl
	ld [hl], c
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdWriteWord()
;@ path: event/script-commands
;@ Command $13 addr, value: writes the word `value` to RAM address `addr`.
;@ test: skip reads script words through far calls
ScriptCmdWriteWord::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> addr = ReadScriptWord()
	call ReadScriptWord
	ld l, c
	ld h, b
	push hl
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mem16[addr] = ReadScriptWord()
	call ReadScriptWord
	pop hl
	ld [hl], c
	inc hl
	ld [hl], b
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdJump()
;@ path: event/script-commands
;@ Command $14 target: goes on at `target`.
;@ test: skip reads script words through far calls
ScriptCmdJump::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdJumpIfByte()
;@ path: event/script-commands
;@ Command $15 addr, value, target: goes on at `target` if the RAM byte at `addr` equals `value`.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfByte::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> addr = ReadScriptWord()
	call ReadScriptWord
	ld l, c
	ld h, b
	push hl
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> value = ReadScriptWord() & 0xFF
	call ReadScriptWord
	pop hl
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> if mem[addr] != value:
;>     return NextScriptCommand()
	ld a, [hl]
	cp c
	jp nz, NextScriptCommand

;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdRedrawFollowers()
;@ path: event/script-commands
;@ Command $16: rebuilds and redraws the party status bar; the script stops for this frame.
;@ test: skip draws to VRAM
ScriptCmdRedrawFollowers::
;> BuildStatusBar()
	call BuildStatusBar
;> DrawStatusBar()
	call DrawStatusBar
	ret


;@ def ScriptCmdSwapTiles()
;@ path: event/script-commands
;@ Command $17: on map $2F, screens 4 and 5, swaps two pairs of 32-byte tiles in VRAM ($9380 with
;@ $9360, $9600 with $9620), an animation step of the scenery.
;@ test: skip writes VRAM
ScriptCmdSwapTiles::
;> if wMapId != 0x2F:
;>     return
	ld a, [wMapId]
	cp $2f
	jr nz, .done

;> if wMapScreen != 4 and wMapScreen != 5:
;>     return
	ld a, [wMapScreen]
	cp $04
	jr z, .swap

	cp $05
	jr nz, .done

.swap
;> SwapTileBytes(0x9380, 0x9360, 0x20)
	ld hl, $9380
	ld de, $9360
	ld b, $20
	call SwapTileBytes
;> SwapTileBytes(0x9600, 0x9620, 0x20)
	ld hl, $9600
	ld de, $9620
	ld b, $20
	call SwapTileBytes
	ret


.done
;> return
	ret


;@ def SwapTileBytes(a: hl, b: de, count: b)
;@ path: gfx/tiles
;@ Swaps `count` bytes of VRAM between `a` and `b`, waiting for VRAM access before each byte.
;@ test: skip waits for the LCD
SwapTileBytes::
;> for i in range(count):
;>@t     t = mem[a + i]; mem[a + i] = mem[b + i]; mem[b + i] = t
	di
	call WaitVRAMAccess
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
;=@t
	ld [de], a
	ei
	inc de
	dec b
	jr nz, SwapTileBytes

	ret


;@ def ScriptCmdGiveMonster()
;@ path: event/script-commands
;@ Command $18 species: gives Terry a new monster of `species` in the first free monster slot
;@ (the last slot, 19, when all are taken) and puts it in the party if there is room.
;@ test: skip reads script words and creates a monster through far calls
ScriptCmdGiveMonster::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wNewMonId = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wNewMonId], a
	ld a, b
	ld [wNewMonId + 1], a
;> slot = 0
;> while True:                            # first free slot of the 20
	ld de, wMonsters
	ld b, $14
	ld c, $00

.find
;>     if mem[wMonsters + 0x95 * slot] == 0:
;>         break
	ld a, [de]
	or a
	jr z, .found

;>     slot += 1
	inc c
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@f
	ld d, a
	dec b
	jr nz, .find

;>@f     if slot == 20:
;>         slot = 19
;>         break
	ld c, $13

.found
;> wNewMonSlot = slot
	ld a, c
	ld [wNewMonSlot], a
;> CreateMonster()
	ld hl, far_CreateMonster
	rst $10
;> if wPartyCount != 3:
	ld a, [wPartyCount]
	cp $03
	jr z, .full

;>     wParty[wPartyCount] = wNewMonSlot
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@p
	ld a, [wNewMonSlot]
	ld [hl], a
;>@p     wPartyCount += 1
	ld hl, wPartyCount
	inc [hl]

.full
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
	ret


;@ def ScriptCmdWaitMovers()
;@ path: event/script-commands
;@ Command $19: waits until all movers have finished (wScriptRunning bit 4 clear), by running this
;@ command again next frame.
;@ test: skip runs script commands from banks $0C-$0F
ScriptCmdWaitMovers::
;> if not wScriptRunning & 0x10:
;>     return NextScriptCommand()
	ld a, [wScriptRunning]
	bit 4, a
	jp z, NextScriptCommand

;> wScriptPos -= 1                        # runs again next frame
	ld a, [wScriptPos]
	sub $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	sbc $00
	ld [wScriptPos + 1], a
;> return
	ret


;@ def ScriptCmdMoveX()
;@ path: event/script-commands
;@ Command $1A who, dx: starts mover `who` (0 Terry, else that actor) of type 0, a straight walk
;@ of dx pixels sideways that runs beside the script (wMovers).
;@ test: skip reads script words through far calls
ScriptCmdMoveX::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> who = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> mover = wMovers + 8 * who
	ld hl, wMovers
	ld a, c
	add a
	add a
	add a
	add l
;=@m
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@m mem[mover] = 1                       # active
	ld [hl], $01
;> mem[mover + 2] = 0                     # type 0: walk
	inc hl
	inc hl
	ld [hl], $00
;> mem[mover + 3] = who
	inc hl
	ld [hl], c
	inc hl
	push hl
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mem16[mover + 4] = ReadScriptWord()
	call ReadScriptWord
	pop hl
	ld [hl], c
	inc hl
	ld [hl], b
;> wScriptRunning |= 0x10
	ld hl, wScriptRunning
	set 4, [hl]
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdMoveY()
;@ path: event/script-commands
;@ Command $1B who, dy: like command $1A, a straight mover walk of dy pixels up or down.
;@ test: skip reads script words through far calls
ScriptCmdMoveY::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> who = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> mover = wMovers + 8 * who
	ld hl, wMovers
	ld a, c
	add a
	add a
	add a
	add l
;=@m
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@m mem[mover] = 1
	ld [hl], $01
;> mem[mover + 2] = 0
	inc hl
	inc hl
	ld [hl], $00
;> mem[mover + 3] = who
	inc hl
	ld [hl], c
	inc hl
	inc hl
	inc hl
	push hl
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mem16[mover + 6] = ReadScriptWord()
	call ReadScriptWord
	pop hl
	ld [hl], c
	inc hl
	ld [hl], b
;> wScriptRunning |= 0x10
	ld hl, wScriptRunning
	set 4, [hl]
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdStartMover()
;@ path: event/script-commands
;@ Command $1C word: starts mover `word & $FF` (0 Terry, else that actor) with movement type
;@ `word >> 8` (the hops, jumps, blinks and throws of UpdatePlayerMover / UpdateActorMover).
;@ test: skip reads script words through far calls
ScriptCmdStartMover::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> word = ReadScriptWord()
	call ReadScriptWord
;> mover = wMovers + 8 * (word & 0xFF)
	ld hl, wMovers
	ld a, c
	add a
	add a
	add a
	add l
;=@m
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@m mem[mover] = 1
	ld [hl], $01
;> mem[mover + 1] = 0                     # frame counter
	inc hl
	ld [hl], $00
;> mem[mover + 2] = word >> 8             # movement type
	inc hl
	ld [hl], b
;> mem[mover + 3] = word & 0xFF
	inc hl
	ld [hl], c
;> wScriptRunning |= 0x10
	ld hl, wScriptRunning
	set 4, [hl]
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdKeepFacing()
;@ path: event/script-commands
;@ Command $1D: from now on walks and movers do not turn who moves (wScriptRunning bit 5).
;@ test: skip runs script commands from banks $0C-$0F
ScriptCmdKeepFacing::
;> wScriptRunning |= 0x20
	ld hl, wScriptRunning
	set 5, [hl]
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdTurnWhileMoving()
;@ path: event/script-commands
;@ Command $1E: walkers turn to the way they go again.
;@ test: skip runs script commands from banks $0C-$0F
ScriptCmdTurnWhileMoving::
;> wScriptRunning &= ~0x20
	ld hl, wScriptRunning
	res 5, [hl]
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdSetupArenaBattle()
;@ path: arena/battles
;@ Command $1F: sets up the next Starry Night tournament fight: the three monsters of class
;@ wArenaClass, round wArenaRound are species $E0 + 3 * (3 * class + round) + 0..2 (class 9: the
;@ final team $1E1-$1E3), the opponent's sprite comes from ArenaOpponentGfx and the monsters'
;@ sprites from their species (GetSpeciesGfx). The script goes on with the next command later.
;@ test: skip looks up monster data through far calls
ScriptCmdSetupArenaBattle::
;>@t team = 3 * (3 * wArenaClass + wArenaRound)
	ld a, [wArenaClass]
	ld b, a
	add a
	add b
	ld b, a
	ld a, [wArenaRound]
;=@t
	add b
	ld b, a
	add a
	add b
;> species = 0xE0 + team
	ld hl, $00e0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> wEncSpecies[0] = species
	ld a, l
	ld [wEncSpecies], a
	ld a, h
	ld [wEncSpecies + 1], a
;> wEncSpecies[1] = species + 1
	inc hl
	ld a, l
	ld [wEncSpecies + 2], a
	ld a, h
	ld [wEncSpecies + 3], a
;> wEncSpecies[2] = species + 2
	inc hl
	ld a, l
	ld [wEncSpecies + 4], a
	ld a, h
	ld [wEncSpecies + 5], a
;> wEncCount = 2                          # three monsters
	ld a, $02
	ld [wEncCount], a
;> if wArenaClass == 9:                   # the final
	ld a, [wArenaClass]
	cp $09
	jr nz, .gfx

;>     wEncSpecies[0] = 0x1E1
	ld hl, $01e1
	ld a, l
	ld [wEncSpecies], a
	ld a, h
	ld [wEncSpecies + 1], a
;>     wEncSpecies[1] = 0x1E2
	ld hl, $01e2
	ld a, l
	ld [wEncSpecies + 2], a
	ld a, h
	ld [wEncSpecies + 3], a
;>     wEncSpecies[2] = 0x1E3
	ld hl, $01e3
	ld a, l
	ld [wEncSpecies + 4], a
	ld a, h
	ld [wEncSpecies + 5], a

.gfx
;>@i i = 3 * wArenaClass + wArenaRound
	ld a, [wArenaClass]
	ld b, a
	add a
	add b
	ld b, a
	ld a, [wArenaRound]
;=@i
	add b
;>@g mem16[wEncGfx] = ArenaOpponentGfx[i]     # opponent sprite
	add a
	ld hl, ArenaOpponentGfx
	add l
	ld l, a
	ld a, $00
	adc h
;=@g
	ld h, a
	ld a, [hli]
	ld [wEncGfx], a
	ld a, [hl]
	ld [wEncGfx + 1], a
;> wEncGfx[4] = GetSpeciesGfx(wEncSpecies[0])
	ld a, [wEncSpecies]
	ld l, a
	ld a, [wEncSpecies + 1]
	ld h, a
	call GetSpeciesGfx
	ld [wEncGfx + 4], a
;> wEncGfx[5] = 1
	ld a, $01
	ld [wEncGfx + 5], a
;> wEncGfx[2] = GetSpeciesGfx(wEncSpecies[1])
	ld a, [wEncSpecies + 2]
	ld l, a
	ld a, [wEncSpecies + 3]
	ld h, a
	call GetSpeciesGfx
	ld [wEncGfx + 2], a
;> wEncGfx[3] = 1
	ld a, $01
	ld [wEncGfx + 3], a
;> wEncGfx[6] = GetSpeciesGfx(wEncSpecies[2])
	ld a, [wEncSpecies + 4]
	ld l, a
	ld a, [wEncSpecies + 5]
	ld h, a
	call GetSpeciesGfx
	ld [wEncGfx + 6], a
;> wEncGfx[7] = 1
	ld a, $01
	ld [wEncGfx + 7], a
	ret


;@ def GetSpeciesGfx(species: hl) -> a
;@ path: monster/species
;@ Returns the sprite number of monster `species` (from its template, LoadMonTemplate2, + $10).
;@ test: skip looks up monster data through far calls
GetSpeciesGfx::
;> wNewMonId = species
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;> LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;> return wNewMonNameText + 0x10
	ld a, [wNewMonNameText]
	add $10
	ret


;@ path: arena/battles
;@ Sprite (u16) of the opponent of each Starry Night tournament fight, indexed by
;@ 3 * class + round (10 classes; the last entries are for the final).
ArenaOpponentGfx::
	db $0b, $00, $0a, $00, $11, $00, $0b, $00, $0a, $00, $da, $01, $0b, $00, $0a, $00
	db $0b, $00, $0b, $00, $0a, $00, $02, $00, $0b, $00, $0a, $00, $0b, $00, $0b, $00
	db $0a, $00, $0f, $00, $0b, $00, $0a, $00, $0c, $00, $0b, $00, $0a, $00, $13, $00
	db $0b, $00, $0a, $00, $14, $00, $08, $00, $08, $00, $08, $00

;@ def ScriptCmdStartBattle()
;@ path: event/script-commands
;@ Command $20: starts a battle against the group already set up in wEncSpecies (wBattleKind 1),
;@ for example by command $1F.
;@ test: skip part of the script engine
ScriptCmdStartBattle::
;> wFieldFlags |= 0x40
	ld hl, wFieldFlags
	set 6, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wBattleKind = 1
	ld a, $01
	ld [wBattleKind], a
	ret


;@ def ScriptCmdPlaySound()
;@ path: event/script-commands
;@ Command $21 sound: plays sound effect `sound`.
;@ test: skip reads script words through far calls
ScriptCmdPlaySound::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> QueueSound(ReadScriptWord() & 0xFF)
	call ReadScriptWord
	ld a, c
	call QueueSound
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdFastMovers()
;@ path: event/script-commands
;@ Command $22: movers move twice a frame from now on (wScriptRunning bit 6).
;@ test: skip runs script commands from banks $0C-$0F
ScriptCmdFastMovers::
;> wScriptRunning |= 0x40
	ld hl, wScriptRunning
	set 6, [hl]
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdJumpIfHasSkillsA()
;@ path: event/script-commands
;@ Command $23 slot, target: if party monster `slot` exists and knows one of the skills $00-$05,
;@ $44, $5C-$5F, puts its name in wTextArg0, its slot in wScriptResult and goes on at `target`.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfHasSkillsA::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> slot = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> if slot >= wPartyCount:
;>     return NextScriptCommand()
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

;> skills = PartyMonsterField(slot, wMonSkills)
	ld a, c
	ld hl, wMonSkills
	push bc
	call PartyMonsterField
	pop bc
;>@s for skill in mem[skills:skills + 8]:
	ld b, $08

jr_004_5ec8:
;>     if skill in (0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x44, 0x5C, 0x5D, 0x5E, 0x5F):
;>@f1         wScriptResult = slot
;>@f2         CopyName(PartyMonsterField(slot, wMonName), wTextArg0)
;>@f3         return ScriptJumpTo(ReadScriptWord())
	ld a, [hli]
	cp $00
	jr z, jr_004_5efb

;=@s
	cp $01
	jr z, jr_004_5efb

	cp $02
	jr z, jr_004_5efb

;=@s
	cp $03
	jr z, jr_004_5efb

	cp $04
	jr z, jr_004_5efb

;=@s
	cp $05
	jr z, jr_004_5efb

	cp $44
	jr z, jr_004_5efb

;=@s
	cp $5c
	jr z, jr_004_5efb

	cp $5d
	jr z, jr_004_5efb

;=@s
	cp $5e
	jr z, jr_004_5efb

	cp $5f
	jr z, jr_004_5efb

;=@s
	dec b
	jr nz, jr_004_5ec8

;> return NextScriptCommand()
	jp NextScriptCommand


jr_004_5efb:
;=@f1
	ld a, c
	ld [wScriptResult], a
;=@f2
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
;=@f3
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdDrawScriptTiles()
;@ path: event/script-commands
;@ Command $24: draws the script's tiles (DrawScriptTiles of the script's bank, $0C-$0F, chosen like
;@ ReadScriptWord does); the script stops for this frame.
;@ test: skip far calls into the script banks
ScriptCmdDrawScriptTiles::
;> if wScriptMap < 0x06:
;>     return DrawScriptTiles_0C()
	ld a, [wScriptMap]
	cp $06
	jr nc, .not0C

	ld hl, far_DrawScriptTiles_0C
	rst $10
	ret


.not0C
;> elif wScriptMap < 0x20:
;>     return DrawScriptTiles_0D()
	cp $20
	jr nc, .not0D

	ld hl, far_DrawScriptTiles_0D
	rst $10
	ret


.not0D
;> elif wScriptMap < 0x40:
;>     return DrawScriptTiles_0E()
	cp $40
	jr nc, .not0E

	ld hl, far_DrawScriptTiles_0E
	rst $10
	ret


.not0E
;> else:
;>     return DrawScriptTiles_0F()
	ld hl, far_DrawScriptTiles_0F
	rst $10
	ret


;@ def ScriptCmdReleaseMonster()
;@ path: event/script-commands
;@ Command $25: lets go of the monster in party position wScriptResult (found by a test before):
;@ frees its slot, closes the gap in the monster list and redraws the party.
;@ test: skip far calls
ScriptCmdReleaseMonster::
;> mem[PartyMonsterField(wScriptResult, wMonsters)] = 0
	ld a, [wScriptResult]
	ld hl, wMonsters
	call PartyMonsterField
	ld [hl], $00
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;> BuildStatusBar()
	call BuildStatusBar
;> DrawStatusBar()
	call DrawStatusBar
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdFadeOut()
;@ path: event/script-commands
;@ Command $26: fades out and reloads the map (wMapLoadState); the script stops.
;@ test: skip starts a fade
ScriptCmdFadeOut::
;> StartFade(3)
	ld a, $03
	call StartFade
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
	ret


;@ def ScriptCmdHealParty()
;@ path: event/script-commands
;@ Command $27: heals all monsters fully and redraws the party sprites.
;@ test: skip far calls
ScriptCmdHealParty::
;> HealAllMonsters()
	ld hl, far_HealAllMonsters
	rst $10
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdJumpIfMonstersFull()
;@ path: event/script-commands
;@ Command $28 target: goes on at `target` if all 20 monster slots are taken.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfMonstersFull::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> count = 0                              # monsters before the first free slot
	ld hl, wMonsters
	ld b, $14
	ld c, $00

.count
;> while count < 20 and wMonsters[0x95 * count] != 0:
	ld a, [hl]
	or a
	jr z, .counted

;>     count += 1
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@c
	inc c
	dec b
	jr nz, .count

.counted
;>@c if count < 20:
;>     return NextScriptCommand()
	ld a, c
	cp $14
	jp c, NextScriptCommand

;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdAddMonster()
;@ path: event/script-commands
;@ Command $29 species: adds a new monster of `species` in the first free monster slot (nothing
;@ happens when all 20 are taken); unlike command $18 it does not join the party. The script
;@ stops for this frame.
;@ test: skip reads script words and creates a monster through far calls
ScriptCmdAddMonster::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wNewMonId = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wNewMonId], a
	ld a, b
	ld [wNewMonId + 1], a
;>@f for slot in range(20):
	ld de, wMonsters
	ld b, $14
	ld c, $00

.find
;>     if wMonsters[0x95 * slot] == 0:
;>@n         wNewMonSlot = slot
;>@m         CreateMonster()
;>@r         RefreshPartyGfx()
;>@x         return
	ld a, [de]
	or a
	jr z, .found

;=@f
	inc c
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@f
	ld d, a
	dec b
	jr nz, .find

	jr .done

.found
;=@n
	ld a, c
	ld [wNewMonSlot], a
;=@m
	ld hl, far_CreateMonster
	rst $10
;=@r
	ld hl, far_RefreshPartyGfx
	rst $10

.done
;=@x
	ret


;@ def ScriptCmdGiveItem()
;@ path: event/script-commands
;@ Command $2A item: puts `item` into the first free bag slot (lost when the bag is full). The
;@ script stops for this frame.
;@ test: skip reads script words through far calls
ScriptCmdGiveItem::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> item = ReadScriptWord() & 0xFF
	call ReadScriptWord
;>@f for i in range(20):
	ld hl, wBagItems
	ld b, $14

.find
;>     if wBagItems[i] == 0 or wBagItems[i] == 0xFF:
;>@i         wBagItems[i] = item
;>@j         return
	ld a, [hl]
	or a
	jr z, .put

	cp $ff
	jr z, .put

;=@f
	inc hl
	dec b
	jr nz, .find

;> return                                 # the bag is full
	ret


.put
;=@i
	ld [hl], c
;=@j
	ret


;@ def ScriptCmdJumpIfNamedMonster()
;@ path: event/script-commands
;@ Command $2B target: goes on at `target` if a party monster of level 10 or more has the name
;@ NamedMonsterName. (The name compare reuses the slot counter, so after a partial match fewer
;@ slots are looked at.)
;@ test: skip reads script words through far calls
ScriptCmdJumpIfNamedMonster::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mon = wMonsters
	ld hl, wMonsters
	ld b, $14
	ld c, $00

.monster
;> for _ in range(20):
;>     if mem[mon] not in (0, 1):         # in the party
	push hl
	ld a, [hl]
	or a
	jr z, .next

	cp $01
	jr z, .next

;>         if mem[mon + 0x4B] >= 10:      # level
	ld a, l
	add $4b
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@l
	ld a, [hl]
	cp $0a
	jr c, .next

;>@l             if mem[mon + 1:mon + 9] == NamedMonsterName:
	ld a, l
	add $b6
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;=@l
	ld de, NamedMonsterName
	ld b, $08

.compare
;=@l
	ld a, [de]
	cp [hl]
	jr nz, .next

	inc de
	inc hl
;=@l
	dec b
	jr nz, .compare

;>                 return ScriptJumpTo(ReadScriptWord())
	pop hl
	call ReadScriptWord
	jp ScriptJumpTo


.next
;>@n     mon += 0x95
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
;=@n
	ld h, a
	inc c
	dec b
	jr nz, .monster

;> return NextScriptCommand()
	jp NextScriptCommand


;@ path: event/script-commands
;@ The 8-byte monster name script command $2B looks for (in the game's character codes, padded
;@ with $F0).
NamedMonsterName::
	db $67, $85, $42, $8d, $26, $f0, $f0, $f0

;@ def ScriptCmdJumpIfBagFull()
;@ path: event/script-commands
;@ Command $2C target: goes on at `target` if all 20 bag slots hold an item.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfBagFull::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> count = 0                              # items before the first free slot
	ld hl, wBagItems
	ld b, $14
	ld c, $00

.count
;> while count < 20 and wBagItems[count] not in (0, 0xFF):
	ld a, [hli]
	or a
	jr z, .counted

	cp $ff
	jr z, .counted

;>     count += 1
	inc c
	dec b
	jr nz, .count

.counted
;> if count < 20:
;>     return NextScriptCommand()
	ld a, c
	cp $14
	jp c, NextScriptCommand

;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdMonsterReaction()
;@ path: event/script-commands
;@ Command $2D slot: prints what party monster `slot` thinks: the message is picked from
;@ MonsterReactionTables by the monster's family (GetMonsterStats) and its personality
;@ (GetMonsterPersonality). Nothing happens for an empty party position.
;@ test: skip looks up monster data through far calls
ScriptCmdMonsterReaction::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mon = wParty[ReadScriptWord() & 0xFF]
	call ReadScriptWord
	ld a, c
	ld hl, wParty
	add l
	ld l, a
;=@m
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>@m if mon == 0xFF:
;>     return
	cp $ff
	ret z

;> wMonSpecies = mem[MonsterField(mon, wMonRecSpecies)]
	push af
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wMonSpecies], a
;> GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;> table = MonsterReactionTables[wMonStats[0]]        # by family
	ld a, [wMonStats]
	add a
	ld hl, MonsterReactionTables
	add l
	ld l, a
	ld a, $00
;=@t
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@t personality = GetMonsterPersonality(mon)
	pop af
	push hl
	ld d, a
	ld hl, far_GetMonsterPersonality
	rst $10
;> message = mem16[table + 2 * personality]
	ld a, d
	add a
	pop hl
	add l
	ld l, a
	ld a, $00
;=@p
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;>@p wScriptRunning |= 0x02               # print it
	ld hl, wScriptRunning
	set 1, [hl]
;> wScriptMessage = message
	ld a, c
	ld [wScriptMessage], a
	ld a, b
	ld [wScriptMessage + 1], a
	ret


;@ path: event/script-commands
;@ Messages of script command $2D: 10 pointers (one per monster family, wMonStats[0]) to 4 lists of 27 message
;@ numbers (u16), one per personality.
MonsterReactionTables::
	db $08, $61, $3e, $61, $74, $61, $3e, $61, $08, $61, $74, $61, $74, $61, $08, $61
	db $3e, $61, $aa, $61, $75, $00, $79, $00, $7d, $00, $81, $00, $85, $00, $89, $00
	db $8d, $00, $91, $00, $95, $00, $99, $00, $9d, $00, $a1, $00, $a5, $00, $a9, $00
	db $ad, $00, $b1, $00, $b5, $00, $b9, $00, $bd, $00, $c1, $00, $c5, $00, $c9, $00
	db $cd, $00, $d1, $00, $d5, $00, $d9, $00, $de, $00, $76, $00, $7a, $00, $7e, $00
	db $82, $00, $86, $00, $8a, $00, $8e, $00, $92, $00, $96, $00, $9a, $00, $9e, $00
	db $a2, $00, $a6, $00, $aa, $00, $ae, $00, $b2, $00, $b6, $00, $ba, $00, $be, $00
	db $c2, $00, $c6, $00, $ca, $00, $ce, $00, $d2, $00, $d6, $00, $da, $00, $df, $00
	db $77, $00, $7b, $00, $7f, $00, $83, $00, $87, $00, $8b, $00, $8f, $00, $93, $00
	db $97, $00, $9b, $00, $9f, $00, $a3, $00, $a7, $00, $ab, $00, $af, $00, $b3, $00
	db $b7, $00, $bb, $00, $bf, $00, $c3, $00, $c7, $00, $cb, $00, $cf, $00, $d3, $00
	db $d7, $00, $db, $00, $e0, $00, $78, $00, $7c, $00, $80, $00, $84, $00, $88, $00
	db $8c, $00, $90, $00, $94, $00, $98, $00, $9c, $00, $a0, $00, $a4, $00, $a8, $00
	db $ac, $00, $b0, $00, $b4, $00, $b8, $00, $bc, $00, $c0, $00, $c4, $00, $c8, $00
	db $cc, $00, $d0, $00, $d4, $00, $d8, $00, $dc, $00, $e1, $00

;@ def ScriptCmdPickFromTable()
;@ path: event/script-commands
;@ Command $2E n: sets wScriptChoice to ScriptChoiceTable[5 * n + wScriptChoiceRow - 1].
;@ test: skip reads script words through far calls
ScriptCmdPickFromTable::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> n = ReadScriptWord() & 0xFF
	call ReadScriptWord
;>@k i = 5 * n + wScriptChoiceRow - 1
	ld a, c
	add a
	add a
	add c
	ld c, a
	ld a, [wScriptChoiceRow]
;=@k
	dec a
	add c
;>@i wScriptChoice = ScriptChoiceTable[i]
	ld hl, ScriptChoiceTable
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@i
	ld a, [hl]
	ld [wScriptChoice], a
;> return NextScriptCommand()
	jp NextScriptCommand


;@ path: event/script-commands
;@ Table of script command $2E: 9 rows of 5 values (0-2).
ScriptChoiceTable::
	db $01, $01, $00, $02, $02, $02, $01, $02, $01, $02, $01, $01, $02, $00, $01, $01
	db $01, $00, $02, $01, $00, $02, $00, $00, $00, $01, $02, $00, $00, $01, $00, $01
	db $01, $01, $01, $02, $01, $02, $01, $00, $01, $01, $00, $01, $00

;@ def ScriptCmdIncByte()
;@ path: event/script-commands
;@ Command $2F addr: adds 1 to the RAM byte at `addr`.
;@ test: skip reads script words through far calls
ScriptCmdIncByte::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mem[ReadScriptWord()] += 1
	call ReadScriptWord
	ld l, c
	ld h, b
	inc [hl]
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdJumpIfAttack100()
;@ path: event/script-commands
;@ Command $30 slot, target: if party monster `slot` exists and has an attack of 100 or more,
;@ puts its name in wTextArg0, its slot in wScriptResult and goes on at `target`.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfAttack100::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> slot = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> if slot >= wPartyCount:
;>     return NextScriptCommand()
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

;> attack = PartyMonsterField(slot, wMonAttack)
	ld a, c
	ld hl, wMonAttack
	push bc
	call PartyMonsterField
	pop bc
;> if mem16[attack] < 100:
;>     return NextScriptCommand()
	ld a, [hli]
	sub $64
	ld a, [hl]
	sbc $00
	jp c, NextScriptCommand

;> wScriptResult = slot
	ld a, c
	ld [wScriptResult], a
;> CopyName(PartyMonsterField(slot, wMonName), wTextArg0)
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdJumpIfLibrary100()
;@ path: event/script-commands
;@ Command $31 target: goes on at `target` if the monster library (wLibraryFlags) holds 100 or
;@ more of the 240 species.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfLibrary100::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> count = 0
	ld b, $00
	ld c, $00

.species
;>@s for species in range(0xF0):
;>     if TestFlag(wLibraryFlags, species):
	push bc
	ld hl, wLibraryFlags
	ld a, b
	call TestFlag
	pop bc
	jr z, .next

;>         count += 1
	inc c

.next
;=@s
	inc b
	ld a, b
	cp $f0
	jr nz, .species

;> if count < 100:
;>     return NextScriptCommand()
	ld a, c
	cp $64
	jp c, NextScriptCommand

;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdJumpIfSpeciesAF()
;@ path: event/script-commands
;@ Command $32 slot, target: if party monster `slot` exists and is of species $AF, puts its name
;@ in wTextArg0, its slot in wScriptResult and goes on at `target`.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfSpeciesAF::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> slot = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> if slot >= wPartyCount:
;>     return NextScriptCommand()
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

;>@s if mem[PartyMonsterField(slot, wMonRecSpecies)] != 0xAF:
	ld a, c
	ld hl, wMonRecSpecies
	push bc
	call PartyMonsterField
	pop bc
	ld a, [hl]
;=@s
	cp $af
;>     return NextScriptCommand()
	jp nz, NextScriptCommand

;> wScriptResult = slot
	ld a, c
	ld [wScriptResult], a
;> CopyName(PartyMonsterField(slot, wMonName), wTextArg0)
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdGiveGold()
;@ path: event/script-commands
;@ Command $33 amount: gives Terry `amount` gold.
;@ test: skip reads script words through far calls
ScriptCmdGiveGold::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> AddGold(ReadScriptWord())             # (high byte 0)
	call ReadScriptWord
	ld l, c
	ld h, b
	ld e, $00
	call AddGold
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdJumpIfHasSkillsB()
;@ path: event/script-commands
;@ Command $34 slot, target: if party monster `slot` exists and knows one of the skills $0F,
;@ $10, $11, $45, $5A, puts its name in wTextArg0, its slot in wScriptResult and goes on at
;@ `target`.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfHasSkillsB::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> slot = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> if slot >= wPartyCount:
;>     return NextScriptCommand()
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

;> skills = PartyMonsterField(slot, wMonSkills)
	ld a, c
	ld hl, wMonSkills
	push bc
	call PartyMonsterField
	pop bc
;>@s for skill in mem[skills:skills + 8]:
	ld b, $08

.skill
;>     if skill in (0x0F, 0x10, 0x45, 0x11, 0x5A):
;>@f1         wScriptResult = slot
;>@f2         CopyName(PartyMonsterField(slot, wMonName), wTextArg0)
;>@f3         return ScriptJumpTo(ReadScriptWord())
	ld a, [hli]
	cp $0f
	jr z, .found

;=@s
	cp $10
	jr z, .found

	cp $45
	jr z, .found

;=@s
	cp $11
	jr z, .found

	cp $5a
	jr z, .found

;=@s
	dec b
	jr nz, .skill

;> return NextScriptCommand()
	jp NextScriptCommand


.found
;=@f1
	ld a, c
	ld [wScriptResult], a
;=@f2
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
;=@f3
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdHealParty2()
;@ path: event/script-commands
;@ Command $35: the same as command $27, heals all monsters and redraws the party sprites.
;@ test: skip far calls
ScriptCmdHealParty2::
;> HealAllMonsters()
	ld hl, far_HealAllMonsters
	rst $10
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdBossBattle()
;@ path: event/script-commands
;@ Command $36: starts a battle against the single monster BossBattleSpecies[wScriptBossIndex]
;@ (wBattleKind 1); the script stops.
;@ test: skip part of the script engine
ScriptCmdBossBattle::
;> mem16[wEncSpecies] = BossBattleSpecies[wScriptBossIndex]
	ld a, [wScriptBossIndex]
	add a
	ld hl, BossBattleSpecies
	add l
	ld l, a
	ld a, $00
;=@b
	adc h
	ld h, a
	ld a, [hli]
	ld [wEncSpecies], a
	ld a, [hl]
	ld [wEncSpecies + 1], a
;>@b wEncCount = 0
	ld a, $00
	ld [wEncCount], a
;> wFieldFlags |= 0x40
	ld hl, wFieldFlags
	set 6, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wBattleKind = 1
	ld a, $01
	ld [wBattleKind], a
	ret


;@ path: event/script-commands
;@ Species (u16) of the fixed battles of script command $36, indexed by wScriptBossIndex
;@ ($13D-$144, the last one twice).
BossBattleSpecies::
	db $3d, $01, $3e, $01, $3f, $01, $40, $01, $41, $01, $42, $01, $43, $01, $44, $01
	db $44, $01

;@ def ScriptCmdGivePrizeItem()
;@ path: event/script-commands
;@ Command $37 n: puts item wArenaWins[n] into the first free bag slot (lost when the bag is
;@ full) and its name into wTextArg0.
;@ test: skip reads script words through far calls
ScriptCmdGivePrizeItem::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;>@k item = mem[wArenaWins + (ReadScriptWord() & 0xFF)]
	call ReadScriptWord
	ld a, c
	ld hl, wArenaWins
	add l
	ld l, a
;=@k
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
;>@i for i in range(20):
	ld hl, wBagItems
	ld b, $14

.find
;>     if wBagItems[i] in (0, 0xFF):
;>@p         wBagItems[i] = item
;>@q         break
	ld a, [hl]
	or a
	jr z, .put

	cp $ff
	jr z, .put

;=@i
	inc hl
	dec b
	jr nz, .find

;=@q
	jr .name

.put
;=@p
	ld [hl], c

.name
;> CopySystemText(0x0800 + item, wTextArg0)      # item name
	ld l, c
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdJumpIfHasSkillsC()
;@ path: event/script-commands
;@ Command $38 slot, target: if party monster `slot` exists and knows one of the skills $84-$87,
;@ puts its name in wTextArg0, its slot in wScriptResult and goes on at `target`.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfHasSkillsC::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> slot = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> if slot >= wPartyCount:
;>     return NextScriptCommand()
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

;> skills = PartyMonsterField(slot, wMonSkills)
	ld a, c
	ld hl, wMonSkills
	push bc
	call PartyMonsterField
	pop bc
;>@s for skill in mem[skills:skills + 8]:
	ld b, $08

.skill
;>     if skill in (0x84, 0x85, 0x86, 0x87):
;>@f1         wScriptResult = slot
;>@f2         CopyName(PartyMonsterField(slot, wMonName), wTextArg0)
;>@f3         return ScriptJumpTo(ReadScriptWord())
	ld a, [hli]
	cp $84
	jr z, .found

;=@s
	cp $85
	jr z, .found

	cp $86
	jr z, .found

;=@s
	cp $87
	jr z, .found

	dec b
	jr nz, .skill

;> return NextScriptCommand()
	jp NextScriptCommand


.found
;=@f1
	ld a, c
	ld [wScriptResult], a
;=@f2
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
;=@f3
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdPrintMessage()
;@ path: event/script-commands
;@ Command $39 message: prints `message` at once (PrintMessage) and goes on.
;@ test: skip prints text
ScriptCmdPrintMessage::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> PrintMessage(ReadScriptWord())
	call ReadScriptWord
	ld l, c
	ld h, b
	call PrintMessage
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdLeaderLeaves()
;@ path: event/script-commands
;@ Command $3A: the party leader (wLeaderSlot) is taken away: InitJoinedMonster handles it, its
;@ species name with level and sex sign goes to wTextArg1, its picture, name, sex and species
;@ are kept in wChosenMon*, and Terry is sent (fade, warp) to map 8 at $48, $48 with story step
;@ 2. The script ends.
;@ test: skip far calls and text
ScriptCmdLeaderLeaves::
;> wCurPartyMember = wLeaderSlot
	ld a, [wLeaderSlot]
	ld [wCurPartyMember], a
;> InitJoinedMonster()
	ld hl, far_InitJoinedMonster
	rst $10
;> wFieldFlags &= ~0x11
	ld hl, wFieldFlags
	res 4, [hl]
	res 0, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;>@s CopySystemText(0x0500 + mem[MonsterField(wCurPartyMember, wMonRecSpecies)], wTextArg1)
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld l, [hl]
	ld h, $05
	ld de, wTextArg1
;=@s
	call CopySystemText
;> AppendNumberText(mem[MonsterField(wCurPartyMember, wMonPlus)], wTextArg1)
	ld a, [wCurPartyMember]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	ld de, wTextArg1
	call AppendNumberText
;> AppendSexSign(mem[MonsterField(wCurPartyMember, wMonGender)], wTextArg1)
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld de, wTextArg1
	call AppendSexSign
;> wChosenMonPic = mem[MonsterField(wCurPartyMember, wMonRecSpecies)] + 0x10
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wChosenMonPic], a
;> wEncGfx[0] = wChosenMonPic
	ld [wEncGfx], a
;> wEncGfx[1] = 1
	ld a, $01
	ld [wEncGfx + 1], a
;>@n wChosenMonName = MonsterField(wCurPartyMember, wMonName)
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld a, l
	ld [wChosenMonName], a
	ld a, h
;=@n
	ld [wChosenMonName + 1], a
;> wChosenMonGender = mem[MonsterField(wCurPartyMember, wMonGender)]
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld [wChosenMonGender], a
;> wChosenMonSpecies = mem[MonsterField(wCurPartyMember, wMonRecSpecies)]
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wChosenMonSpecies], a
;> mem16[wWarpMap] = 0x0008
	ld a, $08
	ld [wWarpMap], a
	ld a, $00
	ld [wWarpOnGateFloor], a
;> wWarpX = 0x48
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [wWarpX + 1], a
;> wWarpY = 0x48
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [wWarpY + 1], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> wStoryStep = 2
	ld a, $02
	ld [wStoryStep], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> StartFade(3)
	ld a, $03
	call StartFade
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
	ret


;@ def AppendNumberText(value: a, text: de)
;@ path: text/numbers
;@ Unless `value` is 0, appends a space ($A2) and `value` in decimal to the $F0-ended string `text`.
;@ test: skip writes a string through ByteToDecimal
AppendNumberText::
;> if value == 0:
;>     return
	or a
	ret z

	push af

.end
;> while mem[text] != 0xF0:
;>     text += 1
	ld a, [de]
	inc de
	cp $f0
	jr nz, .end

;> mem[text] = 0xA2; text += 1
	dec de
	ld a, $a2
	ld [de], a
	inc de
;> ByteToDecimal(value, text)
	pop af
	ld l, e
	ld h, d
	call ByteToDecimal
	ret


;@ def AppendSexSign(sex: a, text: de)
;@ path: text/numbers
;@ Appends the male ($A7) or female ($A8) sign for bit 0 of `sex` to the $F0-ended string `text`.
;@ test: skip writes a string
AppendSexSign::
;> while mem[text] != 0xF0:
;>     text += 1
	push af

.end
	ld a, [de]
	inc de
	cp $f0
	jr nz, .end

;> mem[text] = 0xA7 + (sex & 1)
	dec de
	pop af
	and $01
	add $a7
	ld [de], a
;> mem[text + 1] = 0xF0
	inc de
	ld a, $f0
	ld [de], a
	ret


;@ def ScriptCmdWarpNoFade()
;@ path: event/script-commands
;@ Command $3B map, x, y: like command $0F a warp to map `map` at x, y, but through the field's
;@ own transition (wFieldFlags bit 5) instead of a fade; the script ends.
;@ test: skip reads script words through far calls
ScriptCmdWarpNoFade::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mem16[wWarpMap] = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wWarpMap], a
	ld a, b
	ld [wWarpOnGateFloor], a
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wWarpX = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wWarpX], a
	ld a, b
	ld [wWarpX + 1], a
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wWarpY = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wWarpY], a
	ld a, b
	ld [wWarpY + 1], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> wFieldFlags |= 0x20
	ld hl, wFieldFlags
	set 5, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> wFieldFlags &= ~0x01
	ld hl, wFieldFlags
	res 0, [hl]
;> wTextState = 0
	xor a
	ld [wTextState], a
	ret


;@ def ScriptCmdSetScriptFlag0()
;@ path: event/script-commands
;@ Command $3C: sets wScriptFlags bit 0 (the next message box opens at the bottom of the screen).
;@ test: skip runs script commands from banks $0C-$0F
ScriptCmdSetScriptFlag0::
;> wScriptFlags |= 0x01
	ld hl, wScriptFlags
	set 0, [hl]
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdSetScriptFlag1()
;@ path: event/script-commands
;@ Command $3D: sets wScriptFlags bit 1 (the next message box opens at the top of the screen).
;@ test: skip runs script commands from banks $0C-$0F
ScriptCmdSetScriptFlag1::
;> wScriptFlags |= 0x02
	ld hl, wScriptFlags
	set 1, [hl]
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdEndGameMode()
;@ path: event/script-commands
;@ Command $3E: fades out and leaves the field game mode (wGameModeChange); the script stops.
;@ test: skip starts a fade
ScriptCmdEndGameMode::
;> StartFade(4)
	ld a, $04
	call StartFade
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret


;@ def ScriptCmdCopyLeaderSpecies()
;@ path: event/script-commands
;@ Command $3F: puts the species name of the first party monster into wTextArg0.
;@ test: skip copies text through the text banks
ScriptCmdCopyLeaderSpecies::
;>@c CopySystemText(0x0500 + mem[PartyMonsterField(0, wMonRecSpecies)], wTextArg0)
	ld a, $00
	ld hl, wMonRecSpecies
	call PartyMonsterField
	ld l, [hl]
	ld h, $05
	ld de, wTextArg0
;=@c
	call CopySystemText
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdJumpIfOwnsSpecies()
;@ path: event/script-commands
;@ Command $40 species, target: goes on at `target` if a party monster is of species `species`.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfOwnsSpecies::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> species = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld d, c
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mon = wMonsters
	ld hl, wMonsters
	ld b, $14
	ld c, $00

.monster
;> for _ in range(20):
;>     if mem[mon] not in (0, 1):         # in the party
	push hl
	ld a, [hl]
	or a
	jr z, .next

	cp $01
	jr z, .next

;>@s         if mem[mon + 9] == species:
	ld a, l
	add $09
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@s
	ld a, [hl]
	cp d
	jr nz, .next

;>             return ScriptJumpTo(ReadScriptWord())
	pop hl
	call ReadScriptWord
	jp ScriptJumpTo


.next
;>@n     mon += 0x95
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
;=@n
	ld h, a
	inc c
	dec b
	jr nz, .monster

;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdPlayMusic()
;@ path: event/script-commands
;@ Command $41 song: remembers the song playing (wSavedMusic, for command $4B) and starts `song`.
;@ test: skip reads script words through far calls
ScriptCmdPlayMusic::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> song = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> wSavedMusic = wMusic
	ld a, [wMusic]
	ld [wSavedMusic], a
;> QueueMusic(song)
	ld a, c
	call QueueMusic
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdSaveReturnMenu()
;@ path: event/script-commands
;@ Command $42 arg, actor: keeps `arg` for the field menu (wScriptMenuArg), saves Terry's map,
;@ position and direction as the return point and `actor` as the one to face him on return.
;@ test: skip reads script words through far calls
ScriptCmdSaveReturnMenu::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wScriptMenuArg = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wScriptMenuArg], a
	ld a, b
	ld [wScriptMenuArg + 1], a
;>@m mem16[wReturnMap] = wMapId | wOnGateFloor << 8
	ld a, [wMapId]
	ld c, a
	ld a, [wOnGateFloor]
	ld b, a
	ld a, c
	ld [wReturnMap], a
;=@m
	ld a, b
	ld [wReturnMap + 1], a
;>@x wReturnX = hPlayerX
	ldh a, [hPlayerX]
	ld c, a
	ldh a, [hPlayerX + 1]
	ld b, a
	ld a, c
	ld [wReturnX], a
;=@x
	ld a, b
	ld [wReturnX + 1], a
;>@y wReturnY = hPlayerY
	ldh a, [hPlayerY]
	ld c, a
	ldh a, [hPlayerY + 1]
	ld b, a
	ld a, c
	ld [wReturnY], a
;=@y
	ld a, b
	ld [wReturnY + 1], a
;> wReturnDir = hPlayerDir
	ldh a, [hPlayerDir]
	ld [wReturnDir], a
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wReturnActor = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
	ld [wReturnActor], a
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdReturnWarp()
;@ path: event/script-commands
;@ Command $43: fades out and warps back to the return point saved by command $42 or $4E; the
;@ script ends.
;@ test: skip starts a fade
ScriptCmdReturnWarp::
;>@m mem16[wWarpMap] = mem16[wReturnMap]
	ld a, [wReturnMap]
	ld c, a
	ld a, [wReturnMap + 1]
	ld b, a
	ld a, c
	ld [wWarpMap], a
;=@m
	ld a, b
	ld [wWarpOnGateFloor], a
;>@x wWarpX = wReturnX
	ld a, [wReturnX]
	ld c, a
	ld a, [wReturnX + 1]
	ld b, a
	ld a, c
	ld [wWarpX], a
;=@x
	ld a, b
	ld [wWarpX + 1], a
;>@y wWarpY = wReturnY
	ld a, [wReturnY]
	ld c, a
	ld a, [wReturnY + 1]
	ld b, a
	ld a, c
	ld [wWarpY], a
;=@y
	ld a, b
	ld [wWarpY + 1], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> StartFade(3)
	ld a, $03
	call StartFade
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> wFieldFlags &= ~0x01
	ld hl, wFieldFlags
	res 0, [hl]
;> wTextState = 0
	xor a
	ld [wTextState], a
	ret


;@ def ScriptCmdReturnMenuText()
;@ path: event/script-commands
;@ Command $44: after coming back, Terry faces his saved direction, actor wReturnActor turns to
;@ him, and message wScriptMenuText + 9 is printed as a field event.
;@ test: skip part of the script engine
ScriptCmdReturnMenuText::
;> hPlayerDir = wReturnDir
	ld a, [wReturnDir]
	ldh [hPlayerDir], a
;> SetPlayerPoseFromDir()
	call SetPlayerPoseFromDir
;>@d dirp = wActors + 6 + 32 * (wReturnActor - 1)
	ld a, [wReturnActor]
	dec a
	swap a
	add a
	ld hl, wActors + 6
	add l
;=@d
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[dirp] = (hPlayerDir + 2) & 3      # face Terry
	ldh a, [hPlayerDir]
	add $02
	and $03
	ld [hl], a
;>@t message = wScriptMenuText + 9
	ld a, [wScriptMenuText]
	ld c, a
	ld a, [wScriptMenuText + 1]
	ld b, a
	ld a, c
	add $09
;=@t
	ld c, a
	ld a, b
	adc $00
	ld b, a
;> wScriptRunning |= 0x02
	ld hl, wScriptRunning
	set 1, [hl]
;> wScriptMessage = message
	ld a, c
	ld [wScriptMessage], a
	ld a, b
	ld [wScriptMessage + 1], a
;> wFieldFlags |= 0x01
	ld hl, wFieldFlags
	set 0, [hl]
	ret


;@ def ScriptCmdRestoreParty()
;@ path: event/script-commands
;@ Command $45: brings back the party kept aside in wSavedParty (count, slots, sprites), marks
;@ those monsters as party members again, then closes the gaps in the monster list, heals all
;@ monsters and redraws the party.
;@ test: skip far calls
ScriptCmdRestoreParty::
;>@c copy(wPartyCount, wSavedParty, 7)
	ld hl, wSavedParty
	ld a, [hli]
	ld [wPartyCount], a
	ld a, [hli]
	ld [wParty], a
	ld a, [hli]
;=@c
	ld [wParty + 1], a
	ld a, [hli]
	ld [wParty + 2], a
	ld a, [hli]
	ld [wPartyGfx], a
	ld a, [hli]
;=@c
	ld [wPartyGfx + 1], a
	ld a, [hli]
	ld [wPartyGfx + 2], a
;> PutMonsterInParty(wParty[0])
	ld a, [wParty]
	call PutMonsterInParty
;> PutMonsterInParty(wParty[1])
	ld a, [wParty + 1]
	call PutMonsterInParty
;> PutMonsterInParty(wParty[2])
	ld a, [wParty + 2]
	call PutMonsterInParty
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> HealAllMonsters()
	ld hl, far_HealAllMonsters
	rst $10
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def PutMonsterInParty(slot: a)
;@ path: monster/party
;@ Marks monster `slot` as a party member (record byte 0 = 2); does nothing for $FF.
;@ test: a = rand(0, 19)
PutMonsterInParty::
;> if slot == 0xFF:
;>     return
	cp $ff
	ret z

;> mem[MonsterField(slot, wMonsters)] = 2
	ld hl, wMonsters
	call MonsterField
	ld [hl], $02
	ret


;@ def ScriptCmdWaitSoundEnd()
;@ path: event/script-commands
;@ Command $46: waits until the four sound channels have all stopped (their state bytes $DDB4,
;@ $DDCE, $DDE8, $DE02 are $FF), by running this command again next frame.
;@ test: skip part of the script engine
ScriptCmdWaitSoundEnd::
;>@w if mem[0xDDB4] & mem[0xDDCE] & mem[0xDDE8] & mem[0xDE02] == 0xFF:
;>     return NextScriptCommand()
	ld a, [$ddb4]
	ld hl, $ddce
	and [hl]
	ld hl, $dde8
	and [hl]
	ld hl, $de02
;=@w
	and [hl]
	cp $ff
	jp z, NextScriptCommand

;> wScriptPos -= 1
	ld a, [wScriptPos]
	sub $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	sbc $00
	ld [wScriptPos + 1], a
;> return
	ret


;@ def ScriptCmdActorFaceUp()
;@ path: event/script-commands
;@ Command $47 who: turns Terry (who 0) or actor `who` up. SetActorFacing is shared by the four
;@ facing commands (direction in c).
;@ test: skip reads script words through far calls
ScriptCmdActorFaceUp::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> who = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
;> dir = 2
	ld c, $02

SetActorFacing:
;> if who == 0:
;>     return SetPlayerFacing(dir)
	or a
	jp z, SetPlayerFacing

;>@d mem[wActors + 6 + 32 * (who - 1)] = dir
	dec a
	swap a
	add a
	ld hl, wActors + 6
	add l
	ld l, a
;=@d
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdActorFaceDown()
;@ path: event/script-commands
;@ Command $48 who: turns Terry (who 0) or actor `who` down.
;@ test: skip reads script words through far calls
ScriptCmdActorFaceDown::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> who = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
;> return SetActorFacing(who, 0)
	ld c, $00
	jp SetActorFacing


;@ def ScriptCmdActorFaceLeft()
;@ path: event/script-commands
;@ Command $49 who: turns Terry (who 0) or actor `who` left.
;@ test: skip reads script words through far calls
ScriptCmdActorFaceLeft::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> who = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
;> return SetActorFacing(who, 1)
	ld c, $01
	jp SetActorFacing


;@ def ScriptCmdActorFaceRight()
;@ path: event/script-commands
;@ Command $4A who: turns Terry (who 0) or actor `who` right.
;@ test: skip reads script words through far calls
ScriptCmdActorFaceRight::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> who = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
;> return SetActorFacing(who, 3)
	ld c, $03
	jp SetActorFacing


;@ def ScriptCmdRestoreMusic()
;@ path: event/script-commands
;@ Command $4B: starts the song saved by command $41 again.
;@ test: skip starts music
ScriptCmdRestoreMusic::
;> QueueMusic(wSavedMusic)
	ld a, [wSavedMusic]
	call QueueMusic
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdWaitDPad()
;@ path: event/script-commands
;@ Command $4C: waits until a direction is pressed on the pad.
;@ test: skip part of the script engine
ScriptCmdWaitDPad::
;> if wJoyPressed & 0xF0:
;>     return NextScriptCommand()
	ld a, [wJoyPressed]
	and $f0
	jp nz, NextScriptCommand

;> wScriptPos -= 1                        # runs again next frame
	ld a, [wScriptPos]
	sub $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	sbc $00
	ld [wScriptPos + 1], a
;> return
	ret


;@ def ScriptCmdWaitFrames()
;@ path: event/script-commands
;@ Command $4D n: waits n frames (ScriptWaitFrames).
;@ test: skip reads script words through far calls
ScriptCmdWaitFrames::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> wScriptWait = ReadScriptWord() & 0xFF
	call ReadScriptWord
	ld a, c
	ld [wScriptWait], a
;> wScriptFlags |= 0x04
	ld hl, wScriptFlags
	set 2, [hl]
	ret


;@ def ScriptCmdSaveReturnPoint()
;@ path: event/script-commands
;@ Command $4E: saves Terry's map, position and direction as the return point (for $4F/$50).
;@ test: skip runs script commands from banks $0C-$0F
ScriptCmdSaveReturnPoint::
;>@m mem16[wReturnMap] = wMapId | wOnGateFloor << 8
	ld a, [wMapId]
	ld c, a
	ld a, [wOnGateFloor]
	ld b, a
	ld a, c
	ld [wReturnMap], a
;=@m
	ld a, b
	ld [wReturnMap + 1], a
;>@x wReturnX = hPlayerX
	ldh a, [hPlayerX]
	ld c, a
	ldh a, [hPlayerX + 1]
	ld b, a
	ld a, c
	ld [wReturnX], a
;=@x
	ld a, b
	ld [wReturnX + 1], a
;>@y wReturnY = hPlayerY
	ldh a, [hPlayerY]
	ld c, a
	ldh a, [hPlayerY + 1]
	ld b, a
	ld a, c
	ld [wReturnY], a
;=@y
	ld a, b
	ld [wReturnY + 1], a
;> wReturnDir = hPlayerDir
	ldh a, [hPlayerDir]
	ld [wReturnDir], a
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdReturnWarp2()
;@ path: event/script-commands
;@ Command $4F: fades out and warps back to the saved return point; the script ends (the same
;@ as command $43).
;@ test: skip starts a fade
ScriptCmdReturnWarp2::
;>@m mem16[wWarpMap] = mem16[wReturnMap]
	ld a, [wReturnMap]
	ld c, a
	ld a, [wReturnMap + 1]
	ld b, a
	ld a, c
	ld [wWarpMap], a
;=@m
	ld a, b
	ld [wWarpOnGateFloor], a
;>@x wWarpX = wReturnX
	ld a, [wReturnX]
	ld c, a
	ld a, [wReturnX + 1]
	ld b, a
	ld a, c
	ld [wWarpX], a
;=@x
	ld a, b
	ld [wWarpX + 1], a
;>@y wWarpY = wReturnY
	ld a, [wReturnY]
	ld c, a
	ld a, [wReturnY + 1]
	ld b, a
	ld a, c
	ld [wWarpY], a
;=@y
	ld a, b
	ld [wWarpY + 1], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> StartFade(3)
	ld a, $03
	call StartFade
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> wFieldFlags &= ~0x01
	ld hl, wFieldFlags
	res 0, [hl]
;> wTextState = 0
	xor a
	ld [wTextState], a
	ret


;@ def ScriptCmdReturnFace()
;@ path: event/script-commands
;@ Command $50: Terry faces his saved direction and actor 2 turns to face him.
;@ test: skip part of the script engine
ScriptCmdReturnFace::
;> hPlayerDir = wReturnDir
	ld a, [wReturnDir]
	ldh [hPlayerDir], a
;> SetPlayerPoseFromDir()
	call SetPlayerPoseFromDir
;> mem[wActors + 0x20 + 6] = (hPlayerDir + 2) & 3
	ld hl, wActors + $26
	ldh a, [hPlayerDir]
	add $02
	and $03
	ld [hl], a
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdLibraryRank()
;@ path: event/script-commands
;@ Command $51: counts the species in the monster library, writes the count to wTextArg0 and
;@ the rank it reaches in LibraryRankThresholds (0-11) to wScriptResult.
;@ test: skip writes text through ByteToDecimal
ScriptCmdLibraryRank::
;> count = 0
	ld b, $00
	ld c, $00

.species
;>@s for species in range(0xF0):
;>     if TestFlag(wLibraryFlags, species):
	push bc
	ld hl, wLibraryFlags
	ld a, b
	call TestFlag
	pop bc
	jr z, .next

;>         count += 1
	inc c

.next
;=@s
	inc b
	ld a, b
	cp $f0
	jr nz, .species

;> ByteToDecimal(count, wTextArg0)
	push bc
	ld a, c
	ld hl, wTextArg0
	call ByteToDecimal
	pop bc
;> rank = 0
	ld hl, LibraryRankThresholds
	ld a, c
	ld e, $ff

.rank
;> while count >= LibraryRankThresholds[rank]:
;>     rank += 1
	cp [hl]
	inc hl
	inc e
	jr nc, .rank

;> wScriptResult = rank
	ld a, e
	ld [wScriptResult], a
;> return NextScriptCommand()
	jp NextScriptCommand


;@ path: event/script-commands
;@ Library sizes for the ranks of script command $51 (7, 16, 26, 38, 50, 71, 100, 131, 161, 200,
;@ 215; $FF ends the list).
LibraryRankThresholds::
	db $07, $10, $1a, $26, $32, $47, $64, $83, $a1, $c8, $d7, $ff

;@ def ScriptCmdRandomBattle()
;@ path: event/script-commands
;@ Command $52: starts a battle against three random monsters that suit the party: the level
;@ sum + 1 divided by 20 (at most 7) picks a base species in RandomBattleBases, and each
;@ monster is base + a random 0-15 (wBattleKind 2).
;@ test: skip uses the random generator and far calls
ScriptCmdRandomBattle::
;> levels = 0
	ld bc, $0000
;> levels += AddPartyMonLevel(wParty[0])
	ld a, [wParty]
	call AddPartyMonLevel
;> levels += AddPartyMonLevel(wParty[1])
	ld a, [wParty + 1]
	call AddPartyMonLevel
;> levels += AddPartyMonLevel(wParty[2])
	ld a, [wParty + 2]
	call AddPartyMonLevel
;>@t tier = min(Divide16(levels + 1, 20), 7)
	ld l, c
	ld h, b
	inc hl
	ld a, $14
	call Divide16
	ld a, l
;=@t
	cp $07
	jr c, .tier

	ld a, $07

.tier
;>@b base = RandomBattleBases[tier]
	ld hl, RandomBattleBases
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@b
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
;> for i in range(3):
;>@r     Random()
	call Random
	pop hl
	push hl
;>@e     wEncSpecies[i] = base + (wRandomHigh & 0x0F)
	ld a, [wRandomHigh]
	and $0f
	add l
	ld l, a
	ld a, $00
	adc h
;=@e
	ld h, a
	ld a, l
	ld [wEncSpecies], a
	ld a, h
	ld [wEncSpecies + 1], a
	pop hl
;=@r
	push hl
	call Random
	pop hl
	push hl
;=@e
	ld a, [wRandomHigh]
	and $0f
	add l
	ld l, a
	ld a, $00
	adc h
;=@e
	ld h, a
	ld a, l
	ld [wEncSpecies + 2], a
	ld a, h
	ld [wEncSpecies + 3], a
	pop hl
;=@r
	push hl
	call Random
	pop hl
	push hl
;=@e
	ld a, [wRandomHigh]
	and $0f
	add l
	ld l, a
	ld a, $00
	adc h
;=@e
	ld h, a
	ld a, l
	ld [wEncSpecies + 4], a
	ld a, h
	ld [wEncSpecies + 5], a
	pop hl
;> wEncCount = 2
	ld a, $02
	ld [wEncCount], a
;> wFieldFlags |= 0x40
	ld hl, wFieldFlags
	set 6, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wBattleKind = 2
	ld a, $02
	ld [wBattleKind], a
	ret


;@ path: event/script-commands
;@ Base species (u16) of the random battles of script command $52 for the party level tiers 0-7
;@ ($160, $170, ... $1D0; the last entry twice).
RandomBattleBases::
	db $60, $01, $70, $01, $80, $01, $90, $01, $a0, $01, $b0, $01, $c0, $01, $d0, $01
	db $d0, $01

;@ def AddPartyMonLevel(slot: a, sum: bc) -> bc
;@ path: monster/party
;@ Adds the level of monster `slot` to `sum` (nothing for $FF).
;@ test: skip reads the party monster records
AddPartyMonLevel::
;> if slot == 0xFF:
;>     return sum
	cp $ff
	ret z

;> level = mem[MonsterField(slot, wMonLevel)]
	push bc
	ld hl, wMonLevel
	call MonsterField
	pop bc
;>@r return sum + level
	ld a, [hl]
	add c
	ld c, a
;=@r
	ld a, $00
	adc b
	ld b, a
	ret


;@ def ScriptCmdFaceActor1()
;@ path: event/script-commands
;@ Command $53: turns Terry towards actor 1 (comparing their 16-pixel tiles, first vertically,
;@ then horizontally) and actor 1 towards him; nothing happens when they share a tile.
;@ test: skip part of the script engine
ScriptCmdFaceActor1::
;> ty = hPlayerY & 0xFFF0
	ldh a, [hPlayerY]
	and $f0
	ld l, a
	ldh a, [hPlayerY + 1]
	ld h, a
;> ay = mem16[wActors + 0x1A] & 0xFFF0
	ld a, [wActors + $1a]
	and $f0
	ld e, a
	ld a, [wActors + $1b]
	ld d, a
;>@y if ty != ay:
	push hl
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
;=@y
	ld h, a
	ld a, h
	or l
	pop hl
	jr z, .sameRow

;>@d     dir = 0 if ty < ay else 2        # down or up
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
;=@d
	ld a, $00
	jr c, .face

	ld a, $02
	jr .face

.sameRow
;> else:
;>     tx = hPlayerX & 0xFFF0
	ldh a, [hPlayerX]
	and $f0
	ld l, a
	ldh a, [hPlayerX + 1]
	ld h, a
;>     ax = mem16[wActors + 0x18] & 0xFFF0
	ld a, [wActors + $18]
	and $f0
	ld e, a
	ld a, [wActors + $19]
	ld d, a
;>@z     if tx == ax:
;>         return NextScriptCommand()
	push hl
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
;=@z
	ld h, a
	ld a, h
	or l
	pop hl
	jr z, .same

;>@w     dir = 3 if tx < ax else 1        # right or left
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
;=@w
	ld a, $03
	jr c, .face

	ld a, $01
	jr .face

.same
;=@z
	jp NextScriptCommand


.face
;> hPlayerDir = dir
	ldh [hPlayerDir], a
;> SetPlayerPoseFromDir()
	call SetPlayerPoseFromDir
;> mem[wActors + 6] = (hPlayerDir + 2) & 3       # actor 1 faces Terry
	ld hl, wActors + 6
	ldh a, [hPlayerDir]
	add $02
	and $03
	ld [hl], a
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdGiveRandomItem()
;@ path: event/script-commands
;@ Command $54: puts a random item 1-37 into the first free bag slot and its name into
;@ wTextArg0 (nothing when the bag is full).
;@ test: skip uses the random generator and the text banks
ScriptCmdGiveRandomItem::
;> item = Divide8(wRandomHigh, 0x25) + 1         # remainder: 1-37
	ld a, [wRandomHigh]
	ld b, a
	ld a, $25
	call Divide8
	inc a
	ld c, a
;>@f for i in range(20):
	ld hl, wBagItems
	ld b, $14

.find
;>     if wBagItems[i] in (0, 0xFF):
;>@p         wBagItems[i] = item
;>@n         CopySystemText(0x0800 + item, wTextArg0)
;>@r         return NextScriptCommand()
	ld a, [hl]
	or a
	jr z, .put

	cp $ff
	jr z, .put

;=@f
	inc hl
	dec b
	jr nz, .find

;> return NextScriptCommand()
	jp NextScriptCommand


.put
;=@p
	ld [hl], c
;=@n
	ld l, c
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
;=@r
	jp NextScriptCommand


;@ def ScriptCmdLoseRandomItem()
;@ path: event/script-commands
;@ Command $55: takes a random item out of the bag (its name goes to wTextArg0); wScriptResult is
;@ the number of items there were (0: nothing lost).
;@ test: skip uses the random generator and the text banks
ScriptCmdLoseRandomItem::
;> count = 0
	ld hl, wBagItems
	ld b, $14
	ld c, $00

.count
;> while count < 20 and wBagItems[count] not in (0, 0xFF):
	ld a, [hl]
	or a
	jr z, .counted

	cp $ff
	jr z, .counted

;>     count += 1
	inc hl
	inc c
	dec b
	jr nz, .count

.counted
;> wScriptResult = count
	ld a, c
	ld [wScriptResult], a
;> if count == 0:
;>     return NextScriptCommand()
	or a
	jp z, NextScriptCommand

;> i = Divide8(wRandomHigh, count)       # remainder
	ld a, [wRandomHigh]
	ld b, a
	ld a, c
	call Divide8
;>@i item = wBagItems[i]
	ld hl, wBagItems
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@i
	ld c, [hl]
;> wBagItems[i] = 0xFF
	ld [hl], $ff
;> CopySystemText(0x0800 + item, wTextArg0)
	ld l, c
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
;> CompactBag()
	ld hl, far_CompactBag
	rst $10
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdLoseTenthOfGold()
;@ path: event/script-commands
;@ Command $56: Terry loses a tenth of his gold; the amount goes to wTextArg0 and wScriptResult
;@ is nonzero when there was something to lose.
;@ test: skip writes text and changes gold through helpers
ScriptCmdLoseTenthOfGold::
;>@a amount = Divide24(wGold, 10)
	ld a, [wGold]
	ld l, a
	ld a, [wGold + 1]
	ld h, a
	ld a, [wGold + 2]
	ld e, a
;=@a
	ld a, $0a
	call Divide24
;> wScriptResult = (amount | amount >> 8 | amount >> 16) & 0xFF   # nonzero if any
	ld a, h
	or l
	or e
	ld [wScriptResult], a
;> if amount == 0:
;>     return NextScriptCommand()
	or a
	jp z, NextScriptCommand

;> hNumber = amount                       # 24 bits
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	ld a, e
	ldh [hNumber + 2], a
;> Number24ToDecimal(wTextArg0)
	ld hl, wTextArg0
	call Number24ToDecimal
;>@g SpendGold(hNumber)
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ldh a, [hNumber + 2]
	ld e, a
;=@g
	call SpendGold
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdGiveRandomSeed()
;@ path: event/script-commands
;@ Command $57: puts a random one of the items $13-$17 into the first free bag slot and its name
;@ into wTextArg0 (nothing when the bag is full).
;@ test: skip uses the random generator and the text banks
ScriptCmdGiveRandomSeed::
;> item = Divide8(wRandomHigh, 5) + 0x13
	ld a, [wRandomHigh]
	ld b, a
	ld a, $05
	call Divide8
	add $13
	ld c, a
;>@f for i in range(20):
	ld hl, wBagItems
	ld b, $14

.find
;>     if wBagItems[i] in (0, 0xFF):
;>@p         wBagItems[i] = item
;>@n         CopySystemText(0x0800 + item, wTextArg0)
;>@r         return NextScriptCommand()
	ld a, [hl]
	or a
	jr z, .put

	cp $ff
	jr z, .put

;=@f
	inc hl
	dec b
	jr nz, .find

;> return NextScriptCommand()
	jp NextScriptCommand


.put
;=@p
	ld [hl], c
;=@n
	ld l, c
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
;=@r
	jp NextScriptCommand


;@ def ScriptCmdSkipFloors()
;@ path: event/script-commands
;@ Command $58: in a gate world, jumps $13 floors ahead (at most to the floor before the boss
;@ floor) and loads the new floor (wFieldFlags bit 5); the script ends.
;@ test: skip part of the script engine
ScriptCmdSkipFloors::
;> last = wGateFloors - 2
	ld a, [wGateFloors]
	dec a
	dec a
	ld b, a
;> if wGateFloor != last:
	ld a, [wGateFloor]
	cp b
	jr z, .warp

;>     wGateFloor += 0x13
	add $13
	ld [wGateFloor], a
;>     if wGateFloor >= last:
;>         wGateFloor = last - 1
	cp b
	jr c, .warp

	ld a, b
	dec a
	ld [wGateFloor], a

.warp
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> mem16[wWarpMap] = 0x8000               # the next gate floor
	ld a, $00
	ld [wWarpMap], a
	ld a, $80
	ld [wWarpOnGateFloor], a
;> wFieldFlags |= 0x20
	ld hl, wFieldFlags
	set 5, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> wFieldFlags &= ~0x01
	ld hl, wFieldFlags
	res 0, [hl]
;> wTextState = 0
	xor a
	ld [wTextState], a
	ret


;@ def ScriptCmdBoostWeakestStat()
;@ path: event/script-commands
;@ Command $59 pos: raises the weakest stat of party monster `pos` by 20 (agility counts double,
;@ intelligence four times, when they are compared; on a tie the earlier stat wins: max HP, max
;@ MP, attack, defense, agility, intelligence). The stat's name goes to wTextArg1, the monster's
;@ name to wTextArg0, its slot to wScriptResult ($FF: no monster there).
;@ test: skip changes monster stats through helpers
ScriptCmdBoostWeakestStat::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;>@m mon = wParty[ReadScriptWord() & 0xFF]
	call ReadScriptWord
	ld a, c
	ld hl, wParty
	add l
	ld l, a
;=@m
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;> wScriptResult = mon
	ld [wScriptResult], a
;> if mon == 0xFF:
;>     return NextScriptCommand()
	cp $ff
	jp z, NextScriptCommand

;> wCurPartyMember = mon
	ld [wCurPartyMember], a
;> hp = GetCurMonWord(wMonMaxHP)
	ld hl, wMonMaxHP
	call MonsterField
	ld a, [hli]
	ld d, [hl]
	ld e, a
;>@h if not (CompareStat(wMonMaxMP, hp) or CompareStat(wMonAttack, hp) or CompareStat(wMonDefense, hp) or CompareStat2x(wMonAgility, hp) or CompareStat4x(wMonIntelligence, hp)):   # nothing below hp
	ld hl, wMonMaxMP
	call CompareStat
	jr c, .notHP

	ld hl, wMonAttack
	call CompareStat
;=@h
	jr c, .notHP

	ld hl, wMonDefense
	call CompareStat
	jr c, .notHP

	ld hl, wMonAgility
	call CompareStat2x
;=@h
	jr c, .notHP

	ld hl, wMonIntelligence
	call CompareStat4x
	jr c, .notHP

;>     RaiseMonsterMaxHP(wCurPartyMember, 20)
	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterMaxHP
;>     stat = 0
	ld a, $00
	jp .done


.notHP
;> else:
;>@p     mp = GetCurMonWord(wMonMaxMP)
	ld a, [wCurPartyMember]
	ld hl, wMonMaxMP
	call MonsterField
	ld a, [hli]
	ld d, [hl]
	ld e, a
;>@q     if not (CompareStat(wMonAttack, mp) or CompareStat(wMonDefense, mp) or CompareStat2x(wMonAgility, mp) or CompareStat4x(wMonIntelligence, mp)):
	ld hl, wMonAttack
	call CompareStat
	jr c, .notMP

	ld hl, wMonDefense
	call CompareStat
;=@q
	jr c, .notMP

	ld hl, wMonAgility
	call CompareStat2x
	jr c, .notMP

	ld hl, wMonIntelligence
	call CompareStat4x
;=@q
	jr c, .notMP

;>         RaiseMonsterMaxMP(wCurPartyMember, 20)
	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterMaxMP
;>         stat = 1
	ld a, $01
	jp .done


.notMP
;>     else:
;>@a         atk = GetCurMonWord(wMonAttack)
	ld a, [wCurPartyMember]
	ld hl, wMonAttack
	call MonsterField
	ld a, [hli]
	ld d, [hl]
	ld e, a
;>@b         if not (CompareStat(wMonDefense, atk) or CompareStat2x(wMonAgility, atk) or CompareStat4x(wMonIntelligence, atk)):
	ld hl, wMonDefense
	call CompareStat
	jr c, .notAttack

	ld hl, wMonAgility
	call CompareStat2x
;=@b
	jr c, .notAttack

	ld hl, wMonIntelligence
	call CompareStat4x
	jr c, .notAttack

;>             RaiseMonsterAttack(wCurPartyMember, 20)
	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterAttack
;>             stat = 2
	ld a, $02
	jr .done

.notAttack
;>         else:
;>@d             dfn = GetCurMonWord(wMonDefense)
	ld a, [wCurPartyMember]
	ld hl, wMonDefense
	call MonsterField
	ld a, [hli]
	ld d, [hl]
	ld e, a
;>@e             if not (CompareStat2x(wMonAgility, dfn) or CompareStat4x(wMonIntelligence, dfn)):
	ld hl, wMonAgility
	call CompareStat2x
	jr c, .notDefense

	ld hl, wMonIntelligence
	call CompareStat4x
	jr c, .notDefense

;>                 RaiseMonsterDefense(wCurPartyMember, 20)
	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterDefense
;>                 stat = 3
	ld a, $03
	jr .done

.notDefense
;>             else:
;>@g                 agl2 = 2 * GetCurMonWord(wMonAgility)
	ld a, [wCurPartyMember]
	ld hl, wMonAgility
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@g
	add hl, hl
	ld e, l
	ld d, h
;>                 if not CompareStat4x(wMonIntelligence, agl2):
	ld hl, wMonIntelligence
	call CompareStat4x
	jr c, .intelligence

;>                     RaiseMonsterAgility(wCurPartyMember, 20)
	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterAgility
;>                     stat = 4
	ld a, $04
	jr .done

.intelligence
;>                 else:
;>                     RaiseMonsterIntelligence(wCurPartyMember, 20)
	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterIntelligence
;>                     stat = 5
	ld a, $05

.done
;> CopySystemText(0x0235 + stat, wTextArg1)      # the stat's name
	add $35
	ld l, a
	ld h, $02
	ld de, wTextArg1
	call CopySystemText
;>@c CopyName(MonsterField(wCurPartyMember, wMonName), wTextArg0)
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
;=@c
	call CopyName
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def CompareStat4x(field: hl, value: de) -> (hl, carry)
;@ path: event/script-commands
;@ Four times the u16 stat `field` of monster wCurPartyMember minus `value` (carry: smaller).
;@ test: skip reads a monster record
CompareStat4x::
;> v = 4 * GetCurMonWord(field)
	call GetCurMonWord
	add hl, hl
	add hl, hl
;>@r return v - value
	ld a, l
	sub e
	ld l, a
;=@r
	ld a, h
	sbc d
	ld h, a
	ret


;@ def CompareStat2x(field: hl, value: de) -> (hl, carry)
;@ path: event/script-commands
;@ Twice the u16 stat `field` of monster wCurPartyMember minus `value` (carry: smaller).
;@ test: skip reads a monster record
CompareStat2x::
;> v = 2 * GetCurMonWord(field)
	call GetCurMonWord
	add hl, hl
;>@r return v - value
	ld a, l
	sub e
	ld l, a
;=@r
	ld a, h
	sbc d
	ld h, a
	ret


;@ def CompareStat(field: hl, value: de) -> (hl, carry)
;@ path: event/script-commands
;@ The u16 stat `field` of monster wCurPartyMember minus `value` (carry: smaller).
;@ test: skip reads a monster record
CompareStat::
;> v = GetCurMonWord(field)
	call GetCurMonWord
;>@r return v - value
	ld a, l
	sub e
	ld l, a
;=@r
	ld a, h
	sbc d
	ld h, a
	ret


;@ def GetCurMonWord(field: hl) -> hl
;@ path: event/script-commands
;@ Reads the u16 field `field` of monster wCurPartyMember (keeps de).
;@ test: skip reads a monster record
GetCurMonWord::
;>@w return mem16[MonsterField(wCurPartyMember, field)]
	push de
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@w
	pop de
	ret


;@ def ScriptCmdSpecialBattle()
;@ path: event/script-commands
;@ Command $5A species: starts a battle against one monster `species` of battle kind 3 (the
;@ tournament); the script stops.
;@ test: skip reads script words through far calls
ScriptCmdSpecialBattle::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> mem16[wEncSpecies] = ReadScriptWord()
	call ReadScriptWord
	ld a, c
	ld [wEncSpecies], a
	ld a, b
	ld [wEncSpecies + 1], a
;> wEncCount = 0
	xor a
	ld [wEncCount], a
;> wFieldFlags |= 0x40
	ld hl, wFieldFlags
	set 6, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wBattleKind = 3
	ld a, $03
	ld [wBattleKind], a
	ret


;@ def ScriptCmdStartSpecialBattle()
;@ path: event/script-commands
;@ Command $5B: starts a battle of kind 3 against the group already in wEncSpecies.
;@ test: skip part of the script engine
ScriptCmdStartSpecialBattle::
;> wFieldFlags |= 0x40
	ld hl, wFieldFlags
	set 6, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wBattleKind = 3
	ld a, $03
	ld [wBattleKind], a
	ret


;@ def ScriptCmdSetupTournament()
;@ path: arena/battles
;@ Command $5C: sets up a tournament class: counts it in wArenaWins (until bit 7 is set), rolls
;@ three opponent teams that suit the party's best level (RollTournamentTeam; the first two are
;@ kept in wArenaTeam1 / wArenaTeam2, the third stays in wEncSpecies with its sprites in
;@ wEncGfx), and picks the prize from TournamentPrizes (the late list from the 9th class on),
;@ whose name goes to wTextArg0.
;@ test: skip uses the random generator and far calls
ScriptCmdSetupTournament::
;> if not wArenaWins & 0x80:
;>     wArenaWins += 1
	ld a, [wArenaWins]
	bit 7, a
	jr nz, .roll

	ld hl, wArenaWins
	inc [hl]

.roll
;> RollTournamentTeam()
	call RollTournamentTeam
;>@t copy(wArenaTeam1, wEncSpecies, 6)
	ld a, [wEncSpecies]
	ld l, a
	ld a, [wEncSpecies + 1]
	ld h, a
	ld a, l
	ld [wArenaTeam1], a
;=@t
	ld a, h
	ld [wArenaTeam1 + 1], a
	ld a, [wEncSpecies + 2]
	ld l, a
	ld a, [wEncSpecies + 3]
	ld h, a
;=@t
	ld a, l
	ld [wArenaTeam1 + 2], a
	ld a, h
	ld [wArenaTeam1 + 3], a
	ld a, [wEncSpecies + 4]
	ld l, a
;=@t
	ld a, [wEncSpecies + 5]
	ld h, a
	ld a, l
	ld [wArenaTeam1 + 4], a
	ld a, h
	ld [wArenaTeam1 + 5], a
;> RollTournamentTeam()
	call RollTournamentTeam
;>@u copy(wArenaTeam2, wEncSpecies, 6)
	ld a, [wEncSpecies]
	ld l, a
	ld a, [wEncSpecies + 1]
	ld h, a
	ld a, l
	ld [wArenaTeam2], a
;=@u
	ld a, h
	ld [wArenaTeam2 + 1], a
	ld a, [wEncSpecies + 2]
	ld l, a
	ld a, [wEncSpecies + 3]
	ld h, a
;=@u
	ld a, l
	ld [wArenaTeam2 + 2], a
	ld a, h
	ld [wArenaTeam2 + 3], a
	ld a, [wEncSpecies + 4]
	ld l, a
;=@u
	ld a, [wEncSpecies + 5]
	ld h, a
	ld a, l
	ld [wArenaTeam2 + 4], a
	ld a, h
	ld [wArenaTeam2 + 5], a
;> RollTournamentTeam()
	call RollTournamentTeam
;> SetEncounterGfx(wEncGfx)
	ld hl, wEncGfx
	call SetEncounterGfx
;> prizes = TournamentPrizes if wArenaWins < 9 else TournamentPrizesLate
	ld hl, TournamentPrizes
	ld a, [wArenaWins]
	cp $09
	jr c, .prize

	ld hl, TournamentPrizesLate

.prize
;> Random()
	push hl
	call Random
;>@p wArenaPrize = prizes[wRandomHigh & 0x0F]
	ld a, [wRandomHigh]
	and $0f
	pop hl
	add l
	ld l, a
	ld a, $00
;=@p
	adc h
	ld h, a
	ld a, [hl]
	ld [wArenaPrize], a
;> wArenaRound = 0
	xor a
	ld [wArenaRound], a
;> CopySystemText(0x0800 + wArenaPrize, wTextArg0)
	ld a, [wArenaPrize]
	ld l, a
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def SetEncounterGfx(dest: hl)
;@ path: battle/encounter
;@ Fills the 6-byte sprite list `dest` for the encounter group: (sprite, 1) for each of the
;@ wEncCount + 1 monsters of wEncSpecies, ($FF, 0) for the unused places.
;@ test: skip looks up monster data through far calls
SetEncounterGfx::
;>@f mem[dest:dest + 6] = [0xFF, 0, 0xFF, 0, 0xFF, 0]
	push hl
	ld a, $ff
	ld [hli], a
	xor a
	ld [hli], a
	ld a, $ff
;=@f
	ld [hli], a
	xor a
	ld [hli], a
	ld a, $ff
	ld [hli], a
	xor a
;=@f
	ld [hl], a
	pop hl
;>@g wNewMonId = mem16[wEncSpecies]
	push hl
	ld a, [wEncSpecies]
	ld l, a
	ld a, [wEncSpecies + 1]
	ld h, a
	ld a, l
;=@g
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;> mem[dest] = GetSpeciesGfx2(); mem[dest + 1] = 1
	call GetSpeciesGfx2
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
;> if wEncCount == 0:
;>     return
	ld a, [wEncCount]
	or a
	ret z

;>@h wNewMonId = mem16[wEncSpecies + 2]
	push hl
	ld a, [wEncSpecies + 2]
	ld l, a
	ld a, [wEncSpecies + 3]
	ld h, a
	ld a, l
;=@h
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;> mem[dest + 2] = GetSpeciesGfx2(); mem[dest + 3] = 1
	call GetSpeciesGfx2
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
;> if wEncCount == 1:
;>     return
	ld a, [wEncCount]
	cp $01
	ret z

;>@i wNewMonId = mem16[wEncSpecies + 4]
	push hl
	ld a, [wEncSpecies + 4]
	ld l, a
	ld a, [wEncSpecies + 5]
	ld h, a
	ld a, l
;=@i
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;> mem[dest + 4] = GetSpeciesGfx2(); mem[dest + 5] = 1
	call GetSpeciesGfx2
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
	ret


;@ def GetSpeciesGfx2() -> a
;@ path: monster/species
;@ Returns the sprite number of monster wNewMonId (its template's number + $10).
;@ test: skip looks up monster data through far calls
GetSpeciesGfx2::
;> LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;> return wNewMonNameText + 0x10
	ld a, [wNewMonNameText]
	add $10
	ret


;@ def RollTournamentTeam()
;@ path: arena/battles
;@ Picks a species range by the highest party level (below 4: $02-$0A, below 10: $0D-$1E, below
;@ 16: $21-$32, ... up to $B5-$C6 from level 46 on) and rolls a team of three from it
;@ (PickTournamentTeam).
;@ test: skip uses the random generator
RollTournamentTeam::
;> best = 0
	ld b, $00
;> best = MaxLevelInto(wParty[0], best)
	ld a, [wParty]
	call MaxLevelInto
;> best = MaxLevelInto(wParty[1], best)
	ld a, [wParty + 1]
	call MaxLevelInto
;> best = MaxLevelInto(wParty[2], best)
	ld a, [wParty + 2]
	call MaxLevelInto
;> if best < 4:
;>     return PickTournamentTeam(0x0209)  # base $02, 9 species
	ld a, b
	ld hl, $0209
	cp $04
	jr c, PickTournamentTeam

;> if best < 10:
;>     return PickTournamentTeam(0x0D12)
	ld hl, $0d12
	cp $0a
	jr c, PickTournamentTeam

;> if best < 16:
;>     return PickTournamentTeam(0x2112)
	ld hl, $2112
	cp $10
	jr c, PickTournamentTeam

;> if best < 22:
;>     return PickTournamentTeam(0x3912)
	ld hl, $3912
	cp $16
	jr c, PickTournamentTeam

;> if best < 28:
;>     return PickTournamentTeam(0x5112)
	ld hl, $5112
	cp $1c
	jr c, PickTournamentTeam

;> if best < 34:
;>     return PickTournamentTeam(0x6912)
	ld hl, $6912
	cp $22
	jr c, PickTournamentTeam

;> if best < 40:
;>     return PickTournamentTeam(0x8112)
	ld hl, $8112
	cp $28
	jr c, PickTournamentTeam

;> if best < 46:
;>     return PickTournamentTeam(0x9D12)
	ld hl, $9d12
	cp $2e
	jr c, PickTournamentTeam

;> return PickTournamentTeam(0xB512)
	ld hl, $b512
	jr PickTournamentTeam

;@ def MaxLevelInto(slot: a, best: b) -> b
;@ path: monster/party
;@ Returns the larger of `best` and the level of monster `slot` ($FF: `best`).
;@ test: skip reads the party monster records
MaxLevelInto::
;> if slot == 0xFF:
;>     return best
	cp $ff
	ret z

;> level = mem[MonsterField(slot, wMonLevel)]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
;> if level < best:
;>     return best
	cp b
	ret c

;> return level
	ld b, a
	ret


;@ def PickTournamentTeam(range: hl)
;@ path: arena/battles
;@ Sets up a group of three random species base + 0..count-1 (range: base << 8 | count) in
;@ wEncSpecies.
;@ test: skip uses the random generator
PickTournamentTeam::
;> wEncCount = 2
	ld a, $02
	ld [wEncCount], a
;> wEncSpecies[0] = RandomSpeciesInRange(range)
	call RandomSpeciesInRange
	ld [wEncSpecies], a
;> wEncSpecies[1] = RandomSpeciesInRange(range)
	call RandomSpeciesInRange
	ld [wEncSpecies + 2], a
;> wEncSpecies[2] = RandomSpeciesInRange(range)
	call RandomSpeciesInRange
	ld [wEncSpecies + 4], a
;> # high bytes 0
	xor a
	ld [wEncSpecies + 1], a
	ld [wEncSpecies + 3], a
	ld [wEncSpecies + 5], a
	ret


;@ def RandomSpeciesInRange(range: hl) -> a
;@ path: arena/battles
;@ A random species: base (h) + a random value below count (l).
;@ test: skip uses the random generator
RandomSpeciesInRange::
;> Random()
	push hl
	call Random
;>@q return Divide8(wRandomHigh, range & 0xFF) + (range >> 8)     # remainder + base
	ld a, [wRandomHigh]
	ld b, a
	ld a, l
	call Divide8
;=@q
	pop hl
	add h
	ret


;@ path: arena/battles
;@ Prizes of the Starry Night tournament classes 1-8: 16 item numbers, one picked at random.
TournamentPrizes::
	db $03, $04, $06, $0c, $15, $17, $18, $19, $1a, $1b, $1c, $25, $1a, $1b, $1c, $25

;@ path: arena/battles
;@ Prizes from the 9th tournament class on: 16 item numbers, one picked at random.
TournamentPrizesLate::
	db $0d, $0e, $0f, $10, $11, $12, $1e, $1f, $20, $21, $22, $23, $20, $21, $22, $23

;@ def ScriptCmdGivePrize()
;@ path: event/script-commands
;@ Command $5D: puts the tournament prize wArenaPrize (name in wTextArg0) into the first free bag
;@ slot; with a full bag the script stops here for this frame.
;@ test: skip copies text through the text banks
ScriptCmdGivePrize::
;> CopySystemText(0x0800 + wArenaPrize, wTextArg0)
	ld a, [wArenaPrize]
	ld l, a
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
;>@f for i in range(20):
	ld hl, wBagItems
	ld b, $14

.find
;>     if wBagItems[i] in (0, 0xFF):
;>@p         wBagItems[i] = wArenaPrize
;>@r         return NextScriptCommand()
	ld a, [hl]
	or a
	jr z, .put

	cp $ff
	jr z, .put

;=@f
	inc hl
	dec b
	jr nz, .find

;> return
	ret


.put
;=@p
	ld a, [wArenaPrize]
	ld [hl], a
;=@r
	jp NextScriptCommand


;@ def ScriptCmdStartShootingStars()
;@ path: event/script-commands
;@ Command $5E: starts the shooting-star event (story step 7) with cleared cutscene objects.
;@ test: skip part of the script engine
ScriptCmdStartShootingStars::
;> wStoryStep = 7
	ld a, $07
	ld [wStoryStep], a
;> fill(wSceneObjects, 0, 0x28)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdJumpIfLevelBelowCap()
;@ path: event/script-commands
;@ Command $5F slot, target: for party monster `slot`, puts its level cap into wTextArg1, its name
;@ into wTextArg0 and its slot into wScriptResult, and goes on at `target` if it has reached its
;@ level cap.
;@ test: skip reads script words through far calls
ScriptCmdJumpIfLevelBelowCap::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> slot = ReadScriptWord() & 0xFF
	call ReadScriptWord
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> if slot >= wPartyCount:
;>     return NextScriptCommand()
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

;> cap = PartyMonsterField(slot, wMonMaxLevel)
	ld a, c
	ld hl, wMonMaxLevel
	push bc
	call PartyMonsterField
;> ByteToDecimal(mem[cap], wTextArg1)
	ld a, [hl]
	push hl
	ld hl, wTextArg1
	call ByteToDecimal
	pop hl
	pop bc
;> wScriptResult = slot
	push hl
	ld a, c
	ld [wScriptResult], a
;>@n CopyName(PartyMonsterField(slot, wMonName), wTextArg0)
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
;=@n
	call CopyName
	pop hl
;> if mem[cap] - 1 >= mem[cap - 1]:    # level (the byte before) still below the cap
;>     return NextScriptCommand()
	ld a, [hld]
	dec a
	cp [hl]
	jp nc, NextScriptCommand

;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


;@ def ScriptCmdPayPerLevel()
;@ path: event/script-commands
;@ Command $60 target: charges 10 gold per (+ value + 1) of the party leader; goes on at
;@ `target` when Terry cannot pay.
;@ test: skip changes gold through helpers
ScriptCmdPayPerLevel::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;>@c cost = Multiply(mem[MonsterField(wLeaderSlot, wMonPlus)] + 1, 10)
	ld a, [wLeaderSlot]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	inc a
	ld c, $0a
;=@c
	call Multiply
;>@d if wGold < cost:
;>     return ScriptJumpTo(ReadScriptWord())
	ld a, [wGold]
	sub l
	ld a, [wGold + 1]
	sbc h
	ld a, [wGold + 2]
	sbc $00
;=@d
	jr nc, .pay

	call ReadScriptWord
	jp ScriptJumpTo


.pay
;> SpendGold(cost)
	ld e, $00
	call SpendGold
;> return NextScriptCommand()
	jp NextScriptCommand


;@ def ScriptCmdDrawScriptAttrs()
;@ path: event/script-commands
;@ Command $61: sets the script's tile attributes (DrawScriptAttrs of the script's bank $0C-$0F);
;@ the script stops for this frame.
;@ test: skip far calls into the script banks
ScriptCmdDrawScriptAttrs::
;> if wScriptMap < 0x06:
;>     return DrawScriptAttrs_0C()
	ld a, [wScriptMap]
	cp $06
	jr nc, .not0C

	ld hl, far_DrawScriptAttrs_0C
	rst $10
	ret


.not0C
;> elif wScriptMap < 0x20:
;>     return DrawScriptAttrs_0D()
	cp $20
	jr nc, .not0D

	ld hl, far_DrawScriptAttrs_0D
	rst $10
	ret


.not0D
;> elif wScriptMap < 0x40:
;>     return DrawScriptAttrs_0E()
	cp $40
	jr nc, .not0E

	ld hl, far_DrawScriptAttrs_0E
	rst $10
	ret


.not0E
;> else:
;>     return DrawScriptAttrs_0F()
	ld hl, far_DrawScriptAttrs_0F
	rst $10
	ret


;@ def ScriptCmdBlankScreen()
;@ path: event/script-commands
;@ Command $62: fills tile $DA (16 bytes at $8DA0) with $FF and the whole BG map $9800 with that
;@ tile, a blank screen; the script stops for this frame.
;@ test: skip writes VRAM
ScriptCmdBlankScreen::
;> for i in range(16):
;>     mem[0x8DA0 + i] = 0xFF
	ld hl, $8da0
	ld b, $10
	ld a, $ff

.tile
	call WriteVRAMInc
	dec b
	jr nz, .tile

;>@m for i in range(0x400):
;>     mem[0x9800 + i] = 0xDA
	ld hl, $9800
	ld b, $00
	ld a, $da

.map
;=@m
	call WriteVRAMInc
	call WriteVRAMInc
	call WriteVRAMInc
	call WriteVRAMInc
	dec b
	jr nz, .map

;> return
	ret


;@ def ScriptCmdRedrawScreen()
;@ path: event/script-commands
;@ Command $63: copies the saved screen (wSavedTilemap, 16 rows of 20 tiles in 32-byte rows) back
;@ to the BG map at the scroll position and redraws the party sprites; the script stops for
;@ this frame.
;@ test: skip writes VRAM
ScriptCmdRedrawScreen::
;>@r row = 0x9800 + (hScrollY & 0xF8) * 4
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
;=@r
	sla l
	rla
	ld h, $98
	add h
	ld h, a
;>@d dest = row + ((hScrollX >> 3) & 0x1F)
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	and $1f
	add l
;=@d
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> src = wSavedTilemap
	ld de, wSavedTilemap
;> for _ in range(16):
	ld c, $10

.row
;>@x     for _ in range(20):                # wraps within the 32-tile row
	ld b, $14
	push hl

.tile
;>         WriteVRAM(dest, mem[src]); src += 1
	ld a, [de]
	call WriteVRAM
;>@w         dest = (dest & ~0x1F) | ((dest + 1) & 0x1F)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@w
	ld l, a
	pop af
	or l
	ld l, a
;=@x
	inc de
	dec b
	jr nz, .tile

;>@y     src += 12
	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
;=@y
	ld d, a
;>@z     dest = 0x9800 | ((dest + 0x20) & 0x3FF)
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
;=@z
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, .row

;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
	ret


;@ def ScriptCmdJumpIfPartyFit()
;@ path: event/script-commands
;@ Command $64 target: goes on at `target` if every party monster has no status ailment and
;@ full HP and MP (also with an empty party).
;@ test: skip reads script words through far calls
ScriptCmdJumpIfPartyFit::
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;>@f for i in range(wPartyCount):        # unrolled for the 3 places
	ld a, [wPartyCount]
	or a
	jp z, .fit

;>@s     if GetPartyMonsterByte(i, wMonStatus):
;>         return NextScriptCommand()
	ld a, $00
	ld hl, wMonStatus
	call GetPartyMonsterByte
	or a
	jp nz, .notFit

;>@h     if GetPartyMonsterWord(i, wMonMaxHP) != GetPartyMonsterWord(i, wMonHP):
;>         return NextScriptCommand()
	ld a, $00
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
	ld a, $00
	ld hl, wMonHP
;=@h
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
;=@h
	sbc b
	ld h, a
	ld a, h
	or l
	jp nz, .notFit

;>@m     if GetPartyMonsterWord(i, wMonMaxMP) != GetPartyMonsterWord(i, wMonMP):
;>         return NextScriptCommand()
	ld a, $00
	ld hl, wMonMaxMP
	call GetPartyMonsterWord
	push bc
	ld a, $00
	ld hl, wMonMP
;=@m
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
;=@m
	sbc b
	ld h, a
	ld a, h
	or l
	jp nz, .notFit

;=@f
	ld a, [wPartyCount]
	cp $01
	jp z, .fit

;=@s
	ld a, $01
	ld hl, wMonStatus
	call GetPartyMonsterByte
	or a
	jp nz, .notFit

;=@h
	ld a, $01
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
	ld a, $01
	ld hl, wMonHP
;=@h
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
;=@h
	sbc b
	ld h, a
	ld a, h
	or l
	jr nz, .notFit

;=@m
	ld a, $01
	ld hl, wMonMaxMP
	call GetPartyMonsterWord
	push bc
	ld a, $01
	ld hl, wMonMP
;=@m
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
;=@m
	sbc b
	ld h, a
	ld a, h
	or l
	jr nz, .notFit

;=@f
	ld a, [wPartyCount]
	cp $02
	jr z, .fit

;=@s
	ld a, $02
	ld hl, wMonStatus
	call GetPartyMonsterByte
	or a
	jp nz, .notFit

;=@h
	ld a, $02
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
	ld a, $02
	ld hl, wMonHP
;=@h
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
;=@h
	sbc b
	ld h, a
	ld a, h
	or l
	jr nz, .notFit

;=@m
	ld a, $02
	ld hl, wMonMaxMP
	call GetPartyMonsterWord
	push bc
	ld a, $02
	ld hl, wMonMP
;=@m
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
;=@m
	sbc b
	ld h, a
	ld a, h
	or l
	jr nz, .notFit

.fit
;> return ScriptJumpTo(ReadScriptWord())
	call ReadScriptWord
	jp ScriptJumpTo


.notFit
;=@s
	jp NextScriptCommand


;@ def ScriptCmdWaitChannelsEnd()
;@ path: event/script-commands
;@ Command $65: waits until two sound channels have stopped (state bytes $DD80 and $DD9A are
;@ $FF), by running this command again next frame.
;@ test: skip part of the script engine
ScriptCmdWaitChannelsEnd::
;> if mem[0xDD80] & mem[0xDD9A] == 0xFF:
;>     return NextScriptCommand()
	ld a, [$dd80]
	ld hl, $dd9a
	and [hl]
	cp $ff
	jp z, NextScriptCommand

;> wScriptPos -= 1
	ld a, [wScriptPos]
	sub $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	sbc $00
	ld [wScriptPos + 1], a
;> return
	ret


;@ def ReadScriptWord() -> bc
;@ path: event/script
;@ Reads word wScriptPos of the running script (bc; hl = its address). The scripts live in banks
;@ $0C (maps below 6), $0D (below $20), $0E (below $40) and $0F (the rest, also $70 = the shared
;@ actor scripts); each looks up map wScriptMap, script wScriptId in its own tables.
;@ test: skip reads the script banks through far calls
ReadScriptWord::
;> if wScriptMap < 0x06:
;>     return GetScriptWord_0C()
	ld a, [wScriptMap]
	cp $06
	jr nc, .not0C

	ld hl, far_GetScriptWord_0C
	rst $10
	ret


.not0C
;> elif wScriptMap < 0x20:
;>     return GetScriptWord_0D()
	cp $20
	jr nc, .not0D

	ld hl, far_GetScriptWord_0D
	rst $10
	ret


.not0D
;> elif wScriptMap < 0x40:
;>     return GetScriptWord_0E()
	cp $40
	jr nc, .not0E

	ld hl, far_GetScriptWord_0E
	rst $10
	ret


.not0E
;> else:
;>     return GetScriptWord_0F()
	ld hl, far_GetScriptWord_0F
	rst $10
	ret


;@ def ScriptJumpTo(target: bc, here: hl)
;@ path: event/script
;@ Continues the script at script address `target`: `here` is the address of the word just read
;@ (from ReadScriptWord), so the word index moves by (target - here) / 2 (signed). Runs the
;@ command found there.
;@ test: skip runs script commands from banks $0C-$0F
ScriptJumpTo::
;> offset = target - here
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
;>@half offset = offset >> 1 | (offset & 0x8000)     # arithmetic shift: words
	ld a, b
	push af
	srl b
	rr c
	pop af
	and $80
;=@half
	or b
	ld b, a
;>@pos wScriptPos += offset
	ld a, [wScriptPos]
	ld l, a
	ld a, [wScriptPos + 1]
	ld h, a
	add hl, bc
	ld a, l
;=@pos
	ld [wScriptPos], a
	ld a, h
	ld [wScriptPos + 1], a
;> return RunScriptCommand()
	jp RunScriptCommand

;@ path: field/actors
;@ Actor sprite set 0 (ActorSpriteSets): a list of 21 frame pointers, then the frames in the
;@ DrawMetasprite format (Y offset, X offset, tile, attributes; $80 ends a frame) - small 2x2
;@ pictures and several large pictures of up to 7x8 sprites.
ActorSpriteFrames0::
	db $61, $72, $72, $72, $83, $72, $94, $72, $a5, $72, $b6, $72, $c7, $72, $c7, $72
	db $c7, $72, $c7, $72, $c7, $72, $c7, $72, $c7, $72, $c7, $72, $c7, $72, $c7, $72
	db $c7, $72, $b4, $73, $99, $74, $82, $75, $6b, $76, $f0, $f8, $00, $00, $f0, $00
	db $00, $20, $f8, $f8, $01, $00, $f8, $00, $02, $00, $80, $f0, $f8, $03, $00, $f8
	db $f8, $04, $00, $f8, $00, $05, $00, $f0, $00, $03, $20, $80, $f0, $f8, $06, $00
	db $f0, $00, $07, $00, $f8, $f8, $08, $00, $f8, $00, $09, $00, $80, $f0, $00, $0a
	db $00, $f8, $f8, $0b, $00, $f8, $00, $0c, $00, $f0, $f8, $13, $00, $80, $f0, $f8
	db $0d, $00, $f0, $00, $0d, $20, $f8, $f8, $0e, $00, $f8, $00, $0f, $00, $80, $f0
	db $f8, $10, $00, $f0, $00, $10, $20, $f8, $f8, $11, $00, $f8, $00, $12, $00, $80
	db $c8, $e0, $00, $10, $c8, $e8, $01, $10, $c8, $f0, $02, $10, $c8, $f8, $03, $10
	db $c8, $00, $04, $10, $c8, $08, $05, $10, $c8, $10, $06, $10, $c8, $18, $07, $10
	db $d0, $e0, $10, $10, $d0, $e8, $11, $10, $d0, $f0, $12, $10, $d0, $f8, $13, $10
	db $d0, $00, $14, $10, $d0, $08, $15, $10, $d0, $10, $16, $10, $d0, $18, $17, $10
	db $d8, $e0, $20, $00, $d8, $e8, $21, $00, $d8, $f0, $22, $00, $d8, $f8, $23, $00
	db $d8, $00, $24, $00, $d8, $08, $25, $00, $d8, $10, $26, $00, $e0, $e0, $30, $10
	db $e0, $e8, $31, $10, $e0, $f0, $32, $10, $e0, $f8, $33, $10, $e0, $00, $34, $10
	db $e0, $08, $35, $10, $e0, $10, $36, $10, $e8, $e0, $40, $10, $e8, $e8, $41, $10
	db $e8, $f0, $42, $10, $e8, $f8, $43, $10, $e8, $00, $44, $10, $e8, $08, $45, $10
	db $e8, $10, $46, $10, $f0, $e0, $50, $10, $f0, $e8, $51, $10, $f0, $f0, $52, $10
	db $f0, $f8, $53, $10, $f0, $00, $54, $10, $f0, $08, $55, $10, $f0, $10, $56, $10
	db $f8, $e0, $60, $00, $f8, $e8, $61, $00, $f8, $f0, $62, $00, $f8, $f8, $63, $00
	db $f8, $00, $64, $00, $f8, $08, $65, $00, $f8, $10, $66, $00, $00, $e0, $70, $10
	db $00, $e8, $71, $00, $00, $f0, $72, $00, $00, $f8, $73, $00, $00, $00, $74, $00
	db $00, $08, $75, $00, $00, $10, $76, $00, $00, $18, $77, $00, $80, $c8, $e0, $00
	db $10, $c8, $18, $07, $10, $d0, $e0, $10, $10, $d0, $18, $17, $10, $d8, $e0, $20
	db $00, $e0, $e0, $30, $10, $e8, $e0, $40, $10, $f0, $e0, $50, $10, $f8, $e0, $60
	db $00, $c8, $e8, $07, $10, $c8, $f0, $08, $10, $c8, $f8, $09, $10, $c8, $00, $0a
	db $10, $c8, $08, $0b, $10, $c8, $10, $0c, $10, $d0, $e8, $17, $10, $d0, $f0, $18
	db $10, $d0, $f8, $19, $10, $d0, $00, $1a, $10, $d0, $08, $1b, $10, $d0, $10, $1c
	db $10, $d8, $e8, $27, $00, $d8, $f0, $28, $00, $d8, $f8, $29, $00, $d8, $00, $2a
	db $00, $d8, $08, $2b, $00, $d8, $10, $2c, $00, $e0, $e8, $37, $10, $e0, $f0, $38
	db $10, $e0, $f8, $39, $10, $e0, $00, $3a, $10, $e0, $08, $3b, $10, $e0, $10, $3c
	db $10, $e8, $e8, $47, $10, $e8, $f0, $48, $10, $e8, $f8, $49, $10, $e8, $00, $4a
	db $10, $e8, $08, $4b, $10, $e8, $10, $4c, $10, $f0, $e8, $57, $10, $f0, $f0, $58
	db $10, $f0, $f8, $59, $10, $f0, $00, $5a, $10, $f0, $08, $5b, $10, $f0, $10, $5c
	db $10, $f8, $e8, $67, $00, $f8, $f0, $68, $00, $f8, $f8, $69, $00, $f8, $00, $6a
	db $00, $f8, $08, $6b, $00, $f8, $10, $6c, $00, $00, $e8, $77, $00, $00, $f0, $78
	db $00, $00, $f8, $79, $00, $00, $00, $7a, $00, $00, $08, $7b, $00, $00, $10, $7c
	db $00, $80, $c8, $e0, $00, $10, $c8, $18, $07, $10, $d0, $e0, $10, $10, $d0, $18
	db $17, $10, $d8, $e0, $20, $00, $e0, $e0, $30, $10, $e8, $e0, $40, $10, $f0, $e0
	db $50, $10, $f8, $e0, $60, $00, $d0, $e8, $91, $10, $d0, $f0, $92, $10, $d0, $f8
	db $93, $10, $d0, $00, $94, $10, $d0, $08, $95, $10, $d0, $10, $96, $10, $d8, $e8
	db $a1, $00, $d8, $f0, $a2, $00, $d8, $f8, $a3, $00, $d8, $00, $a4, $00, $d8, $08
	db $a5, $00, $d8, $10, $a6, $00, $e0, $e8, $b1, $10, $e0, $f0, $b2, $10, $e0, $f8
	db $b3, $10, $e0, $00, $b4, $10, $e0, $08, $b5, $10, $e0, $10, $b6, $10, $e8, $e8
	db $c1, $10, $e8, $f0, $c2, $10, $e8, $f8, $c3, $10, $e8, $00, $c4, $10, $e8, $08
	db $c5, $10, $e8, $10, $c6, $10, $f0, $e8, $d1, $10, $f0, $f0, $d2, $10, $f0, $f8
	db $d3, $10, $f0, $00, $d4, $10, $f0, $08, $d5, $10, $f0, $10, $d6, $10, $f8, $e8
	db $e1, $00, $f8, $f0, $e2, $00, $f8, $f8, $e3, $00, $f8, $00, $e4, $00, $f8, $08
	db $e5, $00, $f8, $10, $e6, $00, $c8, $e8, $81, $10, $c8, $f0, $82, $10, $c8, $f8
	db $83, $10, $c8, $00, $84, $10, $c8, $08, $85, $10, $c8, $10, $86, $10, $00, $e0
	db $f0, $10, $00, $e8, $f1, $10, $00, $f0, $f2, $10, $00, $f8, $f3, $10, $00, $00
	db $f4, $10, $00, $08, $f5, $10, $00, $10, $f6, $10, $80, $c8, $e0, $00, $10, $c8
	db $18, $07, $10, $d0, $e0, $10, $10, $d0, $18, $17, $10, $d8, $e0, $20, $00, $e0
	db $e0, $30, $10, $e8, $e0, $40, $10, $f0, $e0, $50, $10, $f8, $e0, $60, $00, $c8
	db $e8, $87, $10, $c8, $f0, $88, $10, $c8, $f8, $89, $10, $c8, $00, $8a, $10, $c8
	db $08, $8b, $10, $c8, $10, $8c, $10, $d0, $e8, $97, $10, $d0, $f0, $98, $10, $d0
	db $f8, $99, $10, $d0, $00, $9a, $10, $d0, $08, $9b, $10, $d0, $10, $9c, $10, $d8
	db $e8, $a7, $00, $d8, $f0, $a8, $00, $d8, $f8, $a9, $00, $d8, $00, $aa, $00, $d8
	db $08, $ab, $00, $d8, $10, $ac, $00, $e0, $e8, $b7, $10, $e0, $f0, $b8, $10, $e0
	db $f8, $b9, $10, $e0, $00, $ba, $10, $e0, $08, $bb, $10, $e0, $10, $bc, $10, $e8
	db $e8, $c7, $10, $e8, $f0, $c8, $10, $e8, $f8, $c9, $10, $e8, $00, $ca, $10, $e8
	db $08, $cb, $10, $e8, $10, $cc, $10, $f0, $e8, $d7, $10, $f0, $f0, $d8, $10, $f0
	db $f8, $d9, $10, $f0, $00, $da, $10, $f0, $08, $db, $10, $f0, $10, $dc, $10, $f8
	db $e8, $e7, $00, $f8, $f0, $e8, $00, $f8, $f8, $e9, $00, $f8, $00, $ea, $00, $f8
	db $08, $eb, $00, $f8, $10, $ec, $00, $00, $e8, $f7, $10, $00, $f0, $f8, $10, $00
	db $f8, $f9, $10, $00, $00, $fa, $10, $00, $08, $fb, $10, $00, $10, $fc, $10, $00
	db $18, $fd, $10, $80, $c8, $e0, $00, $10, $c8, $18, $07, $10, $d0, $e0, $10, $10
	db $d0, $18, $17, $10, $d8, $e0, $20, $10, $e0, $e0, $30, $10, $e8, $e0, $40, $10
	db $f0, $e0, $50, $10, $f8, $e0, $60, $10, $c8, $e8, $87, $10, $c8, $f0, $88, $10
	db $c8, $f8, $89, $10, $c8, $00, $8a, $10, $c8, $08, $8b, $10, $c8, $10, $8c, $10
	db $d0, $e8, $97, $10, $d0, $f0, $98, $10, $d0, $f8, $99, $10, $d0, $00, $9a, $10
	db $d0, $08, $9b, $10, $d0, $10, $9c, $10, $d8, $e8, $a7, $10, $d8, $f0, $a8, $10
	db $d8, $f8, $a9, $10, $d8, $00, $aa, $10, $d8, $08, $ab, $10, $d8, $10, $ac, $10
	db $e0, $e8, $b7, $10, $e0, $f0, $b8, $10, $e0, $f8, $b9, $10, $e0, $00, $ba, $10
	db $e0, $08, $bb, $10, $e0, $10, $bc, $10, $e8, $e8, $c7, $10, $e8, $f0, $c8, $10
	db $e8, $f8, $c9, $10, $e8, $00, $ca, $10, $e8, $08, $cb, $10, $e8, $10, $cc, $10
	db $f0, $e8, $d7, $10, $f0, $f0, $d8, $10, $f0, $f8, $d9, $10, $f0, $00, $da, $10
	db $f0, $08, $db, $10, $f0, $10, $dc, $10, $f8, $e8, $e7, $10, $f8, $f0, $e8, $10
	db $f8, $f8, $e9, $10, $f8, $00, $ea, $10, $f8, $08, $eb, $10, $f8, $10, $ec, $10
	db $80

;@ path: field/actors
;@ Actor sprite sets 1-15 (ActorSpriteSets): 6 frame pointers and their 2x2-sprite frames in the
;@ DrawMetasprite format.
ActorSpriteFrames1::
	db $44, $77, $55, $77, $66, $77, $77, $77, $88, $77, $99, $77, $f0, $f8, $00, $00
	db $f0, $00, $01, $00, $f8, $f8, $02, $00, $f8, $00, $03, $00, $80, $f0, $f8, $00
	db $00, $f0, $00, $01, $00, $f8, $f8, $02, $00, $f8, $00, $03, $00, $80, $f0, $f8
	db $04, $00, $f0, $00, $05, $00, $f8, $f8, $06, $00, $f8, $00, $07, $00, $80, $f0
	db $f8, $04, $00, $f0, $00, $05, $00, $f8, $f8, $06, $00, $f8, $00, $07, $00, $80
	db $f0, $f8, $08, $00, $f0, $00, $09, $00, $f8, $f8, $0a, $00, $f8, $00, $0b, $00
	db $80, $f0, $f8, $08, $00, $f0, $00, $09, $00, $f8, $f8, $0a, $00, $f8, $00, $0b
	db $00, $80

;@ path: unused/leftovers
;@ Bytes nothing reads: data fragments that look like compressed graphics and tilemaps and a
;@ piece of code, then $FF filler up to the end of the bank.
UnusedData_04_77AA::
	db $5b, $7f, $8e, $24, $00, $d0, $c9, $03, $13, $1f, $34, $25, $22, $25, $3f, $ff
	db $5b, $7f, $8e, $54, $20, $d0, $c9, $00, $12, $10, $30, $20, $20, $25, $3f, $8f
	db $23, $07, $06, $04, $00, $d0, $c9, $35, $1b, $41, $1e, $ae, $14, $1b, $00, $fc
	db $a7, $1b, $37, $71, $f1, $b3, $df, $06, $0a, $e6, $f4, $b6, $9f, $fd, $4f, $7e
	db $00, $75, $f5, $eb, $fb, $f5, $f5, $8b, $77, $40, $3f, $2f, $20, $2f, $3f, $20
	db $7f, $00, $ff, $ff, $00, $ff, $ff, $00, $ff, $00, $46, $51, $82, $00, $01, $46
	db $55, $99, $01, $5f, $f6, $de, $56, $7f, $d6, $5f, $f7, $ff, $f5, $f7, $fd, $f7
	db $fd, $ff, $f7, $e3, $b9, $eb, $a9, $fb, $e9, $a1, $eb, $7f, $83, $7f, $80, $80
	db $45, $9f, $83, $ff, $00, $00, $45, $ff, $83, $fe, $01, $01, $45, $f9, $45, $9f
	db $42, $80, $81, $7f, $45, $ff, $02, $81, $ff, $45, $f9, $42, $01, $81, $fe, $48
	db $9f, $48, $ff, $48, $f9, $83, $1f, $3f, $7f, $45, $ff, $83, $f8, $fc, $fe, $45
	db $ff, $48, $40, $48, $0a, $84, $43, $4c, $70, $c0, $04, $44, $0a, $84, $0b, $0c
	db $30, $c0, $04, $88, $03, $0c, $30, $c0, $03, $0c, $30, $c0, $04, $81, $3f, $47
	db $40, $81, $ff, $07, $81, $fc, $47, $02, $98, $00, $08, $08, $0c, $04, $06, $02
	db $03, $06, $0e, $02, $03, $03, $07, $02, $03, $0f, $02, $06, $04, $0c, $08, $18
	db $08, $18, $81, $3f, $47, $40, $81, $ff, $09, $83, $06, $08, $10, $43, $20, $84
	db $00, $08, $e4, $82, $44, $81, $48, $20, $48, $81, $05, $b5, $38, $24, $12, $00
	db $00, $03, $0f, $3c, $48, $90, $91, $00, $7f, $c4, $18, $20, $7c, $c4, $89, $00
	db $c0, $30, $0c, $3e, $c7, $81, $00, $11, $0a, $0c, $14, $24, $24, $22, $2f, $fe
	db $e4, $83, $04, $1c, $29, $e8, $70, $09, $10, $e3, $12, $0c, $c4, $a6, $82, $00
	db $80, $03, $42, $40, $be, $60, $13, $16, $1c, $14, $0f, $02, $3e, $57, $19, $2e
	db $28, $63, $ac, $90, $26, $cc, $83, $81, $81, $01, $3d, $43, $1f, $20, $38, $38
	db $3c, $1f, $1e, $1c, $b8, $f0, $54, $36, $4c, $46, $3a, $27, $1c, $00, $12, $22
	db $41, $81, $80, $00, $01, $02, $20, $18, $20, $20, $98, $90, $8f, $44, $40, $00
	db $03, $47, $7c, $41, $e0, $82, $c0, $e0, $06, $99, $03, $04, $04, $08, $09, $09
	db $05, $72, $8e, $80, $22, $ff, $c1, $c1, $80, $80, $c1, $c1, $30, $18, $98, $98
	db $b0, $a7, $78, $04, $85, $0f, $38, $48, $90, $93, $03, $85, $fe, $01, $3e, $e4
	db $88, $04, $8f, $c0, $30, $08, $06, $08, $10, $e1, $12, $0e, $c4, $a6, $82, $33
	db $4d, $c1, $05, $ba, $13, $16, $1c, $14, $0f, $02, $1e, $2b, $83, $83, $87, $0c
	db $3c, $58, $38, $70, $00, $80, $00, $01, $07, $1f, $0f, $0c, $7e, $81, $80, $60
	db $80, $e1, $43, $3e, $3f, $f0, $80, $00, $00, $80, $e0, $3f, $f8, $7c, $0c, $04
	db $00, $01, $3f, $fe, $18, $18, $30, $60, $e0, $c0, $c0, $e0, $01, $02, $43, $04
	db $8b, $3c, $26, $12, $f0, $1c, $2f, $47, $20, $20, $40, $41, $03, $92, $07, $19
	db $2b, $6a, $aa, $11, $0a, $0c, $34, $e4, $24, $22, $6f, $ad, $b7, $bf, $7e, $38
	db $03, $8e, $f3, $f6, $fc, $14, $0f, $02, $02, $03, $04, $06, $04, $02, $02, $01
	db $06, $b0, $18, $14, $12, $12, $00, $7f, $c4, $18, $38, $48, $88, $09, $11, $0a
	db $0c, $17, $2a, $28, $28, $2f, $fe, $e4, $83, $74, $a8, $89, $88, $70, $11, $0a
	db $0c, $17, $28, $2a, $28, $2f, $fe, $e4, $83, $74, $88, $a9, $88, $70, $17, $0a
	db $08, $18, $43, $28, $b7, $2f, $76, $ac, $8b, $8c, $88, $89, $88, $70, $13, $16
	db $1c, $14, $0f, $00, $79, $ae, $19, $2e, $2a, $4b, $cd, $61, $fa, $06, $a4, $64
	db $94, $8f, $7a, $47, $3c, $00, $05, $7d, $db, $4b, $94, $f4, $89, $72, $3f, $40
	db $5f, $5f, $50, $40, $5f, $3f, $ff, $00, $ff, $ff, $00, $00, $43, $ff, $46, $80
	db $42, $ff, $46, $0b, $99, $ff, $a8, $89, $a1, $a9, $a0, $a9, $a8, $88, $02, $0a
	db $08, $02, $0a, $02, $02, $0a, $5f, $4f, $1f, $5f, $4f, $5f, $5f, $1f, $ff, $85
	db $3f, $7f, $ff, $7f, $7f, $45, $ff, $ab, $fe, $ff, $fa, $fc, $e8, $f0, $c2, $e1
	db $e1, $c0, $80, $c0, $c0, $80, $8a, $84, $16, $8f, $a6, $17, $00, $21, $ff, $ff
	db $cf, $9f, $87, $0f, $0f, $07, $0f, $07, $43, $87, $11, $62, $88, $11, $e8, $f0
	db $fa, $fc, $fe, $43, $ff, $91, $f3, $ff, $fa, $f9, $58, $3c, $86, $0c, $c0, $e0
	db $80, $c0, $00, $80, $80, $00, $03, $07, $be, $40, $20, $00, $40, $00, $40, $80
	db $40, $00, $f8, $08, $06, $02, $01, $01, $00, $04, $88, $40, $84, $35, $72, $20
	db $7c, $00, $62, $00, $42, $54, $82, $60, $9c, $40, $82, $10, $60, $04, $18, $02
	db $04, $11, $62, $42, $81, $00, $c1, $00, $21, $00, $00, $02, $01, $08, $07, $05
	db $19, $23, $01, $03, $03, $07, $03, $41, $03, $be, $07, $42, $3c, $28, $f0, $f4
	db $f8, $e8, $f4, $c2, $e4, $85, $c2, $c8, $e7, $e3, $ff, $90, $60, $61, $00, $04
	db $03, $08, $04, $12, $0c, $c9, $3e, $34, $fb, $f8, $f0, $40, $21, $20, $c1, $82
	db $01, $41, $82, $04, $42, $4a, $84, $94, $08, $48, $30, $07, $07, $0f, $07, $07
	db $0f, $1f, $0f, $18, $0f, $10, $09, $02, $41, $10, $82, $20, $10, $48, $ff, $9b
	db $bf, $cf, $8f, $07, $03, $07, $07, $03, $f1, $e0, $e4, $e3, $ca, $e4, $e4, $c8
	db $88, $d0, $80, $d0, $88, $d0, $c4, $e8, $20, $c0, $80, $0d, $ff, $60, $01, $fd
	db $00, $ee, $30, $03, $07, $0f, $0c, $1b, $16, $ff, $36, $2d, $5d, $63, $7f, $c0
	db $ff, $81, $ff, $ff, $80, $fd, $83, $ef, $9f, $f1, $fb, $fd, $01, $08, $00, $00
	db $01, $1f, $1f, $1f, $11, $ff, $cd, $eb, $ad, $7f, $d3, $3b, $e8, $98, $ff, $e8
	db $18, $e8, $18, $c8, $38, $d0, $b8, $ff, $20, $f1, $c1, $e1, $f9, $7f, $e7, $bf
	db $fd, $a1, $fc, $30, $f9, $27, $fa, $17, $a4, $7e, $ff, $f8, $fc, $3f, $6f, $3c
	db $37, $34, $2f, $ff, $18, $3f, $10, $1f, $10, $1f, $15, $1f, $ff, $0d, $0f, $7d
	db $ff, $a7, $fb, $82, $ff, $fb, $fe, $fe, $ee, $31, $18, $3c, $38, $3c, $20, $ff
	db $f0, $fe, $ff, $36, $ff, $10, $f0, $10, $ff, $f0, $5e, $ff, $75, $ff, $61, $ff
	db $c3, $9f, $bf, $8c, $fe, $70, $f8, $ee, $31, $f0, $33, $1f, $f7, $10, $37, $2e
	db $fa, $3f, $00, $01, $00, $00, $ff, $3e, $3e, $fe, $e2, $ba, $76, $da, $3e, $fb
	db $ee, $1e, $18, $01, $c8, $38, $d1, $b9, $21, $cf, $f3, $c3, $e3, $fa, $27, $0f
	db $39, $06, $75, $ff, $ff, $ad, $ff, $85, $ff, $63, $ff, $1c, $3d, $fe, $ee, $31
	db $30, $30, $30, $70, $60, $60, $4c, $df, $ee, $fc, $fe, $30, $f8, $5c, $01, $50
	db $f0, $ff, $70, $f0, $60, $e0, $fe, $ff, $c5, $bf, $ff, $81, $ff, $ff, $ff, $00
	db $00, $10, $78, $ff, $68, $98, $f8, $0c, $f7, $0f, $f0, $0f, $ff, $60, $9f, $62
	db $9d, $26, $d9, $56, $7b, $ff, $36, $7b, $0a, $1d, $1d, $13, $1b, $14, $bf, $0d
	db $1e, $0b, $0f, $0f, $1f, $3f, $00, $13, $ff, $17, $1a, $1b, $1e, $17, $1f, $14
	db $1c, $b3, $18, $1c, $6c, $03, $1e, $17, $e0, $f0, $5d, $00, $90, $3f, $dc, $bc
	db $a4, $fc, $f8, $fc, $1e, $1d, $ee, $31, $00, $02, $bd, $00, $ee, $38, $04, $03
	db $03, $04, $ee, $33, $80, $f7, $60, $40, $a0, $06, $01, $42, $bc, $02, $05, $ef
	db $03, $04, $04, $03, $ee, $37, $7d, $82, $46, $ff, $b9, $2b, $c4, $05, $02, $00
	db $01, $20, $ff, $18, $11, $28, $56, $29, $5c, $24, $8c, $ff, $74, $00, $88, $20
	db $84, $00, $a2, $40, $ff, $99, $28, $c4, $80, $3c, $30, $52, $30, $ff, $12, $28
	db $07, $04, $38, $ab, $44, $40, $ff, $83, $04, $00, $02, $01, $4e, $20, $04, $ff
	db $40, $04, $40, $8e, $4a, $0e, $ca, $a4, $9f, $40, $44, $3b, $0a, $24, $ee, $39
	db $69, $0f, $00, $ff, $00, $50, $20, $20, $10, $20, $10, $28, $ff, $10, $21, $1e
	db $10, $61, $40, $80, $08, $df, $00, $01, $88, $02, $08, $90, $05, $01, $08, $5f
	db $09, $04, $83, $00, $44, $9f, $00, $28, $a3, $01, $ff, $6c, $28, $6c, $39, $00
	db $88, $04, $48, $fe, $af, $04, $50, $0c, $94, $08, $20, $18, $00, $bf, $00, $81
	db $00, $00, $ff, $80, $ee, $30, $03, $fd, $00, $fd, $31, $88, $64, $40, $94, $80
	db $34, $ff, $10, $64, $48, $24, $84, $08, $58, $04, $ff, $08, $04, $86, $70, $00
	db $70, $04, $22, $ff, $00, $1c, $00, $00, $42, $81, $00, $fe, $ff, $00, $ff, $04
	db $03, $0b, $04, $07, $08, $ff, $17, $08, $0c, $13, $2f, $10, $1f, $20, $ff, $1f
	db $20, $90, $60, $e0, $10, $90, $60, $ff, $e8, $10, $f4, $08, $78, $84, $7a, $84
	db $6f, $7c, $82, $5f, $20, $30, $0b, $bc, $42, $40, $0b, $ff, $5f, $20, $3f, $40
	db $3f, $40, $bf, $40, $fe, $56, $05, $d0, $20, $e0, $10, $e0, $10, $e8, $56, $85
	db $0f, $08, $03, $99, $0c, $ab, $a9, $0c, $d0, $b9, $02, $fe, $0e, $1b, $90, $24
	db $02, $34, $61, $1a, $62, $ff, $19, $18, $25, $41, $24, $a4, $42, $24, $ff, $c2
	db $90, $27, $09, $06, $04, $18, $10, $fb, $f8, $f0, $a3, $10, $74, $f8, $f8, $7c
	db $78, $ff, $3c, $84, $59, $01, $23, $03, $1f, $17, $ff, $c7, $4f, $2f, $06, $2f
	db $26, $16, $20, $ff, $16, $31, $c0, $c2, $81, $88, $86, $80, $ff, $38, $20, $40
	db $10, $60, $68, $90, $74, $ff, $88, $80, $79, $71, $8e, $fe, $01, $7c, $ff, $83
	db $9c, $63, $24, $1b, $10, $0f, $5a, $fd, $a4, $de, $01, $00, $20, $08, $10, $10
	db $18, $3f, $5a, $99, $18, $da, $18, $db, $80, $00, $ff, $3f, $7f, $5f, $e0, $bf
	db $c0, $e6, $99, $7f, $bb, $ff, $ee, $ff, $44, $ee, $00, $fc, $31, $ff, $01, $00
	db $01, $01, $03, $03, $06, $07, $ff, $05, $06, $07, $00, $00, $ff, $ff, $ff, $ef
	db $00, $ff, $00, $66, $f5, $32, $c4, $ff, $9c, $ff, $e3, $9e, $f9, $b6, $cd, $9e
	db $e7, $5e, $ff, $e7, $ee, $f1, $b6, $f9, $1c, $3f, $07, $ff, $0f, $38, $7c, $54
	db $ee, $ba, $c6, $ba, $ff, $c6, $92, $ee, $c6, $fe, $7c, $fe, $38, $f9, $7c, $fc
	db $32, $3e, $08, $42, $3c, $bd, $42, $5b, $ff, $bd, $77, $ad, $6d, $b7, $37, $cf
	db $df, $07, $7e, $7e, $3c, $3e, $0d, $00, $9a, $05, $83, $2c, $2d, $2e, $11, $8b
	db $32, $33, $00, $32, $33, $00, $00, $20, $21, $21, $22, $05, $88, $2c, $2d, $2e
	db $00, $00, $28, $29, $2a, $05, $8e, $2c, $2d, $2e, $30, $31, $00, $30, $31, $00
	db $00, $25, $26, $00, $27, $08, $8a, $20, $21, $25, $26, $27, $00, $00, $20, $21
	db $22, $03, $be, $32, $33, $00, $32, $33, $00, $00, $25, $00, $28, $29, $2a, $6d
	db $6e, $6f, $70, $6d, $6e, $6f, $25, $26, $25, $28, $29, $2a, $6e, $25, $26, $27
	db $6d, $6e, $6f, $30, $31, $6e, $30, $31, $6f, $70, $23, $00, $25, $26, $27, $71
	db $72, $73, $74, $71, $72, $73, $25, $26, $23, $23, $26, $27, $72, $23, $26, $27
	db $71, $41, $72, $8d, $73, $32, $33, $72, $32, $33, $73, $74, $25, $00, $25, $00
	db $27, $07, $8a, $23, $28, $29, $2a, $00, $27, $00, $25, $00, $24, $03, $8c, $30
	db $31, $00, $30, $31, $00, $00, $23, $00, $23, $00, $24, $07, $8a, $23, $25, $26
	db $00, $00, $24, $00, $23, $00, $27, $03, $85, $32, $33, $00, $32, $33, $04, $81
	db $23, $0a, $81, $23, $05, $81, $23, $05, $85, $34, $2f, $00, $34, $2f, $02, $ff
	db $00, $9a, $23, $83, $64, $65, $66, $03, $8a, $64, $65, $66, $00, $64, $65, $66
	db $00, $00, $62, $06, $8a, $64, $65, $66, $00, $5e, $5f, $00, $00, $64, $65, $43
	db $3d, $83, $66, $64, $65, $43, $3d, $81, $65, $43, $3d, $b0, $65, $66, $67, $00
	db $64, $65, $66, $64, $65, $3d, $3d, $68, $00, $60, $61, $00, $58, $59, $58, $59
	db $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59
	db $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $7f, $e0, $9b, $60
	db $3d, $ff, $3e, $c7, $ea, $90, $c9, $cd, $92, $13, $3e, $03, $ea, $a6, $c9, $af
	db $ea, $8b, $c9, $ea, $8c, $c9, $ea, $88, $c9, $ea, $a1, $c9, $ea, $c7, $dd, $ea
	db $c8, $dd, $ea, $9a, $c9, $ea, $a4, $c9, $ea, $a7, $c9, $c3, $e6, $15, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $04
