INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $004", ROMX[$4000], BANK[$4]

BankNumber_04::
	db $04

FarTable_04::
	dw DrawFieldMarker
	dw DrawFieldMarkerOnScreen
	dw DrawActorSprite
	dw DrawActorSpriteOnScreen
	dw $4167
	dw StartScript
	dw $56fa

DrawFieldMarker::
	ld de, $401d
	call DrawMetasprite
	ret


DrawFieldMarkerOnScreen::
	ld de, $401d
	call DrawScreenMetasprite
	ret


FieldMarkerSprites::
	db $23, $40, $2a, $40, $3d, $40, $25, $40, $00, $00, $00, $00, $80, $2c, $40, $00
	db $00, $00, $10, $00, $08, $01, $10, $08, $00, $02, $10, $08, $08, $03, $10, $80
	db $45, $40, $4e, $40, $63, $40, $70, $40, $00, $00, $90, $00, $08, $00, $91, $00
	db $80, $00, $00, $a6, $00, $00, $08, $a7, $00, $00, $10, $a8, $00, $00, $30, $a4
	db $00, $08, $30, $a5, $00, $80, $f8, $08, $00, $00, $00, $00, $01, $00, $00, $08
	db $02, $00, $80, $00, $00, $00, $00, $00, $08, $01, $00, $08, $00, $10, $00, $08
	db $08, $11, $00, $80

DrawActorSprite::
	ldh a, [hSpriteSet]
	cp $90
	jr nc, jr_004_409e

	cp $10
	jr nc, jr_004_4095

	call SetActorSpritePalette
	ld de, $4137
	call DrawMetasprite
	ret


jr_004_4095:
	sub $10
	ldh [hSpriteSet], a
	ld hl, far_DrawFieldSprite_10
	rst $10
	ret


jr_004_409e:
	sub $90
	ldh [hSpriteSet], a
	ld hl, far_DrawFieldSprite_11
	rst $10
	ret


DrawActorSpriteOnScreen::
	ldh a, [hSpriteSet]
	cp $90
	jr nc, jr_004_40c4

	cp $10
	jr nc, jr_004_40bb

	call SetActorSpritePalette
	ld de, $4137
	call DrawScreenMetasprite
	ret


jr_004_40bb:
	sub $10
	ldh [hSpriteSet], a
	ld hl, far_DrawFieldSpriteOnScreen_10
	rst $10
	ret


jr_004_40c4:
	sub $90
	ldh [hSpriteSet], a
	ld hl, far_DrawFieldSpriteOnScreen_11
	rst $10
	ret


DrawScreenMetasprite::
	push af
	push bc
	push de
	push hl
	ldh a, [hOAMCount]
	cp $28
	jr nc, jr_004_4121

	ldh a, [hSpriteSet]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ldh a, [hSpriteFrame]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ldh a, [hOAMCount]
	sla a
	sla a
	ld l, a
	ld h, $c0

jr_004_40f4:
	ld a, [de]
	inc de
	cp $80
	jr z, jr_004_4121

	ld b, a
	ldh a, [hSpriteY]
	add b
	add $10
	ld [hli], a
	ld a, [de]
	inc de
	ld b, a
	ldh a, [hSpriteX]
	add b
	add $08
	ld [hli], a
	ldh a, [hSpriteTileBase]
	ld b, a
	ld a, [de]
	inc de
	add b
	ld [hli], a
	ld a, [de]
	inc de
	ld b, a
	ldh a, [hSpriteAttr]
	xor b
	ld [hli], a
	ldh a, [hOAMCount]
	inc a
	ldh [hOAMCount], a
	cp $28
	jr c, jr_004_40f4

jr_004_4121:
	pop hl
	pop de
	pop bc
	pop af
	ret


SetActorSpritePalette::
	ldh a, [hSpriteSet]
	ld hl, $4157
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ldh a, [hSpriteAttr]
	or [hl]
	ldh [hSpriteAttr], a
	ret


ActorSpriteSets::
	db $37, $72, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77
	db $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77
ActorSpritePalettes::
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02

	ld a, [wFieldFlags]
	res 0, a
	res 2, a
	or a
	ret nz

	ld a, [wFieldFlags]
	bit 0, a
	jr z, jr_004_417f

	ld a, [wEventStep]
	cp $0b
	ret nz

	jr jr_004_4189

jr_004_417f:
	bit 2, a
	jr z, jr_004_4189

	ld a, [wScrollStep]
	cp $02
	ret nz

jr_004_4189:
	ld a, [wFadeState]
	or a
	ret nz

	ld a, [wTextState]
	or a
	ret nz

	ld a, [wScriptRunning]
	bit 0, a
	jp z, Jump_004_41c7

	bit 1, a
	jp nz, Jump_004_41c7

	ld a, [wScriptRunning]
	bit 4, a
	call nz, UpdateMovers
	ld a, [wScriptRunning]
	bit 6, a
	call nz, UpdateMovers
	ld a, [wScriptRunning]
	bit 2, a
	jr nz, jr_004_41c8

	bit 3, a
	jp nz, Jump_004_41e0

	ld a, [wScriptFlags]
	bit 2, a
	jp nz, Jump_004_43db

	call NextScriptCommand

Jump_004_41c7:
	ret


jr_004_41c8:
	ld a, [wFrameCounter]
	and $07
	jr nz, jr_004_41dd

	ld a, [wScriptWait]
	dec a
	ld [wScriptWait], a
	jr nz, jr_004_41dd

	ld hl, wScriptRunning
	res 2, [hl]

jr_004_41dd:
	jp Jump_004_41c7


Jump_004_41e0:
	ld a, [wScriptWalker]
	or a
	jp nz, Jump_004_42cd

	ld hl, hPlayerFlags
	set 0, [hl]
	ld a, [wFrameCounter]
	and $03
	cp $01
	jp z, Jump_004_43d8

	ld a, [wScriptWalkX]
	ld l, a
	ld a, [$d8de]
	ld h, a
	ld a, h
	or l
	jr z, jr_004_425a

	bit 7, h
	jr nz, jr_004_4231

	ld a, [wScriptWalkX]
	sub $01
	ld [wScriptWalkX], a
	ld a, [$d8de]
	sbc $00
	ld [$d8de], a
	ldh a, [hPlayerX]
	add $01
	ldh [hPlayerX], a
	ldh a, [$ff93]
	adc $00
	ldh [$ff93], a
	ld a, [wScriptRunning]
	bit 5, a
	jp nz, Jump_004_42ba

	ld a, $03
	ldh [hPlayerDir], a
	jp Jump_004_42ba


jr_004_4231:
	ld a, [wScriptWalkX]
	add $01
	ld [wScriptWalkX], a
	ld a, [$d8de]
	adc $00
	ld [$d8de], a
	ldh a, [hPlayerX]
	sub $01
	ldh [hPlayerX], a
	ldh a, [$ff93]
	sbc $00
	ldh [$ff93], a
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, jr_004_42ba

	ld a, $01
	ldh [hPlayerDir], a
	jr jr_004_42ba

jr_004_425a:
	ld a, [wScriptWalkY]
	ld l, a
	ld a, [$d8e0]
	ld h, a
	ld a, h
	or l
	jr z, jr_004_42c0

	bit 7, h
	jr nz, jr_004_4293

	ld a, [wScriptWalkY]
	sub $01
	ld [wScriptWalkY], a
	ld a, [$d8e0]
	sbc $00
	ld [$d8e0], a
	ldh a, [hPlayerY]
	add $01
	ldh [hPlayerY], a
	ldh a, [$ff96]
	adc $00
	ldh [$ff96], a
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, jr_004_42ba

	ld a, $00
	ldh [hPlayerDir], a
	jr jr_004_42ba

jr_004_4293:
	ld a, [wScriptWalkY]
	add $01
	ld [wScriptWalkY], a
	ld a, [$d8e0]
	adc $00
	ld [$d8e0], a
	ldh a, [hPlayerY]
	sub $01
	ldh [hPlayerY], a
	ldh a, [$ff96]
	sbc $00
	ldh [$ff96], a
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, jr_004_42ba

	ld a, $02
	ldh [hPlayerDir], a

Jump_004_42ba:
jr_004_42ba:
	call SetPlayerPoseFromDir
	jp Jump_004_43d8


jr_004_42c0:
	ld hl, hPlayerFlags
	res 0, [hl]
	ld hl, wScriptRunning
	res 3, [hl]
	jp Jump_004_43d8


Jump_004_42cd:
	dec a
	swap a
	add a
	ld hl, wActors
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
	set 0, [hl]
	res 6, [hl]
	ld a, [wFrameCounter]
	and $03
	cp $01
	jp z, Jump_004_43d8

	ld a, [wScriptWalkX]
	ld e, a
	ld a, [$d8de]
	ld d, a
	ld a, d
	or e
	jr z, jr_004_435f

	bit 7, d
	jr nz, jr_004_4333

	ld a, [wScriptWalkX]
	sub $01
	ld [wScriptWalkX], a
	ld a, [$d8de]
	sbc $00
	ld [$d8de], a
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, jr_004_4320

	ld [hl], $03

jr_004_4320:
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	jp Jump_004_43d8


jr_004_4333:
	ld a, [wScriptWalkX]
	add $01
	ld [wScriptWalkX], a
	ld a, [$d8de]
	adc $00
	ld [$d8de], a
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, jr_004_434d

	ld [hl], $01

jr_004_434d:
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	jr jr_004_43d8

jr_004_435f:
	ld a, [wScriptWalkY]
	ld e, a
	ld a, [$d8e0]
	ld d, a
	ld a, d
	or e
	jr z, jr_004_43c7

	bit 7, d
	jr nz, jr_004_439b

	ld a, [wScriptWalkY]
	sub $01
	ld [wScriptWalkY], a
	ld a, [$d8e0]
	sbc $00
	ld [$d8e0], a
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, jr_004_4389

	ld [hl], $00

jr_004_4389:
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	jr jr_004_43d8

jr_004_439b:
	ld a, [wScriptWalkY]
	add $01
	ld [wScriptWalkY], a
	ld a, [$d8e0]
	adc $00
	ld [$d8e0], a
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, jr_004_43b5

	ld [hl], $02

jr_004_43b5:
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	jr jr_004_43d8

jr_004_43c7:
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	res 0, [hl]
	ld hl, wScriptRunning
	res 3, [hl]

Jump_004_43d8:
jr_004_43d8:
	jp Jump_004_41c7


Jump_004_43db:
	ld a, [wScriptWait]
	dec a
	ld [wScriptWait], a
	jr nz, jr_004_43e9

	ld hl, wScriptFlags
	res 2, [hl]

jr_004_43e9:
	jp Jump_004_41c7


UpdateMovers::
	ld a, [wMovers]
	push af
	call UpdatePlayerMover
	pop af
	ld hl, $d8f1
	or [hl]
	push af
	call UpdateActorMover
	pop af
	ld hl, $d8f9
	or [hl]
	push af
	call UpdateActorMover
	pop af
	ld hl, $d901
	or [hl]
	push af
	call UpdateActorMover
	pop af
	ld hl, $d909
	or [hl]
	push af
	call UpdateActorMover
	pop af
	ld hl, $d911
	or [hl]
	push af
	call UpdateActorMover
	pop af
	ld hl, $d919
	or [hl]
	push af
	call UpdateActorMover
	pop af
	ld hl, $d921
	or [hl]
	push af
	call UpdateActorMover
	pop af
	or a
	ret nz

	ld hl, wScriptRunning
	res 4, [hl]
	res 6, [hl]
	ret


UpdatePlayerMover::
	ld a, [wMovers]
	or a
	ret z

	ld a, [wScriptRunning]
	set 4, a
	ld [wScriptRunning], a
	ld hl, wMovers
	ld a, l
	ldh [$ffd7], a
	ld a, h
	ldh [$ffd8], a
	ld a, [$d8eb]
	ld hl, hPlayerY
	cp $01
	jp z, MoverHopSmall

	cp $03
	jp z, MoverLeapSpin

	cp $04
	jp z, MoverHop

	cp $06
	jp z, MoverFillTrail

	cp $07
	jp z, MoverHopLeft

	cp $1a
	jp z, MoverSpinHop2

	ld hl, hPlayerFlags
	set 0, [hl]
	ld a, [wFrameCounter]
	and $03
	cp $01
	ret z

	ld a, [$d8ed]
	ld l, a
	ld a, [$d8ee]
	ld h, a
	ld a, h
	or l
	jr z, jr_004_44ea

	bit 7, h
	jr nz, jr_004_44bf

	ld a, [$d8ed]
	sub $01
	ld [$d8ed], a
	ld a, [$d8ee]
	sbc $00
	ld [$d8ee], a
	ldh a, [hPlayerX]
	add $01
	ldh [hPlayerX], a
	ldh a, [$ff93]
	adc $00
	ldh [$ff93], a
	ld a, [wScriptRunning]
	bit 5, a
	jp nz, SetPlayerPoseFromDir

	ld a, $03
	ldh [hPlayerDir], a
	jp SetPlayerPoseFromDir


jr_004_44bf:
	ld a, [$d8ed]
	add $01
	ld [$d8ed], a
	ld a, [$d8ee]
	adc $00
	ld [$d8ee], a
	ldh a, [hPlayerX]
	sub $01
	ldh [hPlayerX], a
	ldh a, [$ff93]
	sbc $00
	ldh [$ff93], a
	ld a, [wScriptRunning]
	bit 5, a
	jp nz, SetPlayerPoseFromDir

	ld a, $01
	ldh [hPlayerDir], a
	jp SetPlayerPoseFromDir


jr_004_44ea:
	ld a, [$d8ef]
	ld l, a
	ld a, [$d8f0]
	ld h, a
	ld a, h
	or l
	jp z, PlayerMoverDone

	bit 7, h
	jr nz, jr_004_4524

	ld a, [$d8ef]
	sub $01
	ld [$d8ef], a
	ld a, [$d8f0]
	sbc $00
	ld [$d8f0], a
	ldh a, [hPlayerY]
	add $01
	ldh [hPlayerY], a
	ldh a, [$ff96]
	adc $00
	ldh [$ff96], a
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, SetPlayerPoseFromDir

	ld a, $00
	ldh [hPlayerDir], a
	jr SetPlayerPoseFromDir

jr_004_4524:
	ld a, [$d8ef]
	add $01
	ld [$d8ef], a
	ld a, [$d8f0]
	adc $00
	ld [$d8f0], a
	ldh a, [hPlayerY]
	sub $01
	ldh [hPlayerY], a
	ldh a, [$ff96]
	sbc $00
	ldh [$ff96], a
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, SetPlayerPoseFromDir

	ld a, $02
	ldh [hPlayerDir], a

SetPlayerPoseFromDir::
	ld a, $00
	ldh [hPlayerAttr], a
	ld a, $00
	ldh [hPlayerPose], a
	ldh a, [hPlayerDir]
	or a
	ret z

	ld a, $20
	ldh [hPlayerAttr], a
	ld a, $01
	ldh [hPlayerPose], a
	ldh a, [hPlayerDir]
	cp $01
	ret z

	ld a, $00
	ldh [hPlayerAttr], a
	ld a, $02
	ldh [hPlayerPose], a
	ldh a, [hPlayerDir]
	cp $02
	ret z

	ld a, $00
	ldh [hPlayerAttr], a
	ld a, $01
	ldh [hPlayerPose], a
	ret


PlayerMoverDone::
	ld hl, hPlayerFlags
	res 0, [hl]
	xor a
	ld [wMovers], a
	ret


UpdateActorMover::
	ld a, [hl]
	or a
	ret z

	ld a, [wScriptRunning]
	set 4, a
	ld [wScriptRunning], a
	ld a, l
	ldh [$ffd7], a
	ld a, h
	ldh [$ffd8], a
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	dec a
	swap a
	add a
	ld hl, wActors
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	ldh a, [$ffd7]
	add $02
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	push af
	ldh a, [hNumber]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	pop af
	cp $01
	jp z, MoverHopSmall

	cp $02
	jp z, MoverHopHigh

	cp $04
	jp z, MoverHop

	cp $05
	jp z, MoverDoubleHopRight

	cp $08
	jp z, MoverBlinkIn

	cp $09
	jp z, MoverSpinHop

	cp $0a
	jp z, MoverRise

	cp $0b
	jp z, MoverDoubleHop

	cp $0c
	jp z, MoverFallLeft

	cp $0d
	jp z, MoverBlinkOut

	cp $0e
	jp z, MoverFloatUp

	cp $0f
	jp z, MoverLaunch

	cp $10
	jp z, MoverDrop

	cp $11
	jp z, MoverFallFast

	cp $12
	jp z, MoverHopDrop

	cp $13
	jp z, MoverLeap

	cp $14
	jp z, MoverBlinkSpin

	cp $15
	jp z, MoverFallArcLeft

	cp $16
	jp z, MoverFallArcRight

	cp $17
	jp z, MoverThrowLeft

	cp $18
	jp z, MoverThrowRight

	cp $19
	jp z, MoverHopLeft2

	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	set 0, [hl]
	res 6, [hl]
	ld a, [wFrameCounter]
	and $03
	cp $01
	ret z

	ldh a, [$ffd7]
	add $04
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
	ld a, d
	or e
	jr z, jr_004_46ba

	bit 7, d
	jr nz, jr_004_468c

	ldh a, [$ffd7]
	add $04
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	sub $01
	ld [bc], a
	inc bc
	ld a, [bc]
	sbc $00
	ld [bc], a
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, jr_004_467b

	ld [hl], $03

jr_004_467b:
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	ret


jr_004_468c:
	ldh a, [$ffd7]
	add $04
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	add $01
	ld [bc], a
	inc bc
	ld a, [bc]
	adc $00
	ld [bc], a
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, jr_004_46a9

	ld [hl], $01

jr_004_46a9:
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	ret


jr_004_46ba:
	ldh a, [$ffd7]
	add $06
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
	ld a, d
	or e
	jr z, jr_004_472d

	bit 7, d
	jr nz, jr_004_46ff

	ldh a, [$ffd7]
	add $06
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	sub $01
	ld [bc], a
	inc bc
	ld a, [bc]
	sbc $00
	ld [bc], a
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, jr_004_46ee

	ld [hl], $00

jr_004_46ee:
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	ret


jr_004_46ff:
	ldh a, [$ffd7]
	add $06
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	add $01
	ld [bc], a
	inc bc
	ld a, [bc]
	adc $00
	ld [bc], a
	inc hl
	ld a, [wScriptRunning]
	bit 5, a
	jr nz, jr_004_471c

	ld [hl], $02

jr_004_471c:
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	ret


jr_004_472d:
	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	res 0, [hl]
	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ret


MoverHopSmall::
	ld bc, $4770

StepMoverArc::
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	push af
	inc a
	ld [de], a
	pop af
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	cp $80
	jr z, jr_004_4767

	add [hl]
	ld [hli], a
	inc bc
	ld a, [bc]
	adc [hl]
	ld [hl], a
	ret


MoverDone:
jr_004_4767:
	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ret


ArcHopSmall::
	db $fd, $ff, $fd, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $01, $00
	db $01, $00, $02, $00, $03, $00, $03, $00, $80, $80

MoverHopHigh::
	ld bc, $4790
	jp StepMoverArc


ArcHopHigh::
	db $fb, $ff, $fb, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff
	db $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $80, $80

MoverLeapSpin::
	ld bc, $47d9
	call StepMoverArc
	ld a, [wFadeState]
	or a
	ret nz

	ld a, [wFieldTimer]
	and $03
	ret z

	ldh a, [hPlayerDir]
	inc a
	and $03
	ldh [hPlayerDir], a
	jp SetPlayerPoseFromDir


ArcLeapSpin::
	db $fe, $ff, $fe, $ff, $fe, $ff, $fd, $ff, $fd, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $80, $80

MoverHop::
	ld bc, $485d
	jp StepMoverArc


ArcHop::
	db $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00
	db $80, $80

MoverDoubleHopRight::
	ld bc, $4892
	call StepMoverArc
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	inc [hl]
	inc [hl]
	ret


ArcDoubleHopRight::
	db $fb, $ff, $fb, $ff, $fb, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff
	db $fe, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00
	db $02, $00, $02, $00, $02, $00, $03, $00, $03, $00, $03, $00, $04, $00, $04, $00
	db $04, $00, $fa, $ff, $fc, $ff, $fd, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $03, $00, $04, $00, $06, $00, $80, $80

MoverFillTrail::
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	inc a
	ld [de], a
	cp $40
	jr nz, jr_004_48fc

	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ret


jr_004_48fc:
	ld a, [wTrailPos]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld a, l
	add $73
	ld l, a
	ld a, h
	adc $c9
	ld h, a
	ldh a, [hPlayerX]
	ld [hli], a
	ldh a, [hPlayerY]
	ld [hli], a
	ldh a, [$ff93]
	swap a
	ld c, a
	ldh a, [$ff96]
	or c
	ld [hli], a
	ldh a, [hPlayerFrame]
	ld c, a
	ldh a, [hPlayerAttr]
	or c
	ld [hli], a
	ld a, [wTrailPos]
	inc a
	ld [wTrailPos], a
	cp $31
	ret c

	xor a
	ld [wTrailPos], a
	ret


MoverHopLeft::
	ld bc, $494c
	call StepMoverArc
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	sub $02
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [hPlayerX], a
	ld a, h
	ldh [$ff93], a
	ret


ArcHopLeft::
	db $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $01, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00, $04, $00, $80, $80

MoverBlinkIn::
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	inc a
	ld [de], a
	cp $ff
	jr nz, jr_004_49ae

	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld [hl], $00
	ret


jr_004_49ae:
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	pop af
	ld b, $0f
	cp $20
	jr c, jr_004_49ca

	ld b, $07
	cp $50
	jr c, jr_004_49ca

	ld b, $03
	cp $90
	jr c, jr_004_49ca

	ld b, $01

jr_004_49ca:
	and b
	or a
	ld [hl], $00
	ret z

	ld [hl], $40
	ret


MoverSpinHop::
	ld bc, $4a0a
	call StepMoverArc
	ld a, [wFadeState]
	or a
	ret nz

	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $00
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	srl a
	srl a
	and $03
	push af
	ldh a, [hNumber]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	pop af
	ld [hl], a
	jp SetPlayerPoseFromDir


ArcSpinHop::
	db $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00
	db $80, $80

MoverRise::
	ld bc, $4a32
	jp StepMoverArc


ArcRise::
	db $fb, $ff, $fb, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff
	db $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $80, $80

MoverDoubleHop::
	ld bc, $4a58
	jp StepMoverArc


ArcDoubleHop::
	db $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $01, $00, $01, $00, $02, $00
	db $02, $00, $02, $00, $00, $00, $00, $00, $00, $00, $fb, $ff, $fb, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $80, $80

MoverFallLeft::
	ld bc, $4ab5
	call StepMoverArc
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	dec [hl]
	dec [hl]
	ret


ArcFallLeft::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $03, $00, $02, $00, $03, $00
	db $80, $80

MoverBlinkOut::
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	inc a
	ld [de], a
	cp $ff
	jr nz, jr_004_4b49

	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld [hl], $40
	ret


jr_004_4b49:
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	pop af
	ld b, $0f
	cp $20
	jr c, jr_004_4b65

	ld b, $07
	cp $50
	jr c, jr_004_4b65

	ld b, $03
	cp $90
	jr c, jr_004_4b65

	ld b, $01

jr_004_4b65:
	and b
	or a
	ld [hl], $40
	ret z

	ld [hl], $00
	ret


MoverFloatUp::
	ld a, [wFieldTimer]
	and $03
	ret nz

	ld bc, $4b79
	jp StepMoverArc


ArcFloatUp::
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $80, $80

MoverLaunch::
	ld bc, $4ba1
	jp StepMoverArc


ArcLaunch::
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00
	db $03, $00, $03, $00, $80, $80

MoverDrop::
	ld bc, $4bed
	jp StepMoverArc


ArcDrop::
	db $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00
	db $03, $00, $03, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $80, $80

MoverFallFast::
	ld bc, $4c39
	jp StepMoverArc


ArcFallFast::
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $04, $00, $80, $80

MoverHopDrop::
	ld bc, $4c6b
	jp StepMoverArc


ArcHopDrop::
	db $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00
	db $03, $00, $03, $00, $04, $00, $04, $00, $04, $00, $05, $00, $05, $00, $05, $00
	db $05, $00, $80, $80

MoverLeap::
	ld bc, $4ca5
	jp StepMoverArc


	db $fe, $ff, $fe, $ff, $fe, $ff, $fd, $ff, $fd, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00
	db $80, $80

MoverBlinkSpin::
	call BlinkActorSlow
	ld a, [wFadeState]
	or a
	ret nz

	ldh a, [hNumber]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $00
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	srl a
	srl a
	and $03
	push af
	ldh a, [hNumber]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	pop af
	ld [hl], a
	jp SetPlayerPoseFromDir


BlinkActorSlow::
	ld a, [wFieldTimer]
	and $01
	ret nz

	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	inc a
	ld [de], a
	cp $ff
	jr nz, jr_004_4d84

	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld [hl], $00
	ret


jr_004_4d84:
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	pop af
	ld b, $0f
	cp $20
	jr c, jr_004_4da0

	ld b, $07
	cp $50
	jr c, jr_004_4da0

	ld b, $03
	cp $90
	jr c, jr_004_4da0

	ld b, $01

jr_004_4da0:
	and b
	or a
	ld [hl], $00
	ret z

	ld [hl], $40
	ret


MoverFallArcLeft::
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_004_4dc2

	ld a, [wJumpHeight]
	ld c, a
	ld a, $0a
	sub c
	add a
	add a
	add a
	inc a
	ld [de], a

jr_004_4dc2:
	ld a, [wJumpFall]
	ld bc, $4df3
	cp $01
	jr z, jr_004_4ddd

	ld bc, $4e95
	cp $02
	jr z, jr_004_4ddd

	ld bc, $4f37
	cp $03
	jr z, jr_004_4ddd

	ld bc, $4fd9

jr_004_4ddd:
	call StepMoverArc
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	dec bc
	dec bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


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
	db $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00, $02, $00
	db $03, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $01, $00, $01, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $03, $00, $02, $00, $03, $00
	db $03, $00, $03, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $03, $00, $02, $00, $02, $00, $03, $00, $02, $00, $03, $00, $04, $00
	db $03, $00, $04, $00, $04, $00, $80, $80

MoverFallArcRight::
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_004_5095

	ld a, [wJumpHeight]
	ld c, a
	ld a, $0a
	sub c
	add a
	add a
	add a
	inc a
	ld [de], a

jr_004_5095:
	ld a, [wJumpFall]
	ld bc, $4df3
	cp $01
	jr z, jr_004_50b0

	ld bc, $4e95
	cp $02
	jr z, jr_004_50b0

	ld bc, $4f37
	cp $03
	jr z, jr_004_50b0

	ld bc, $4fd9

jr_004_50b0:
	call StepMoverArc
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	inc bc
	inc bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


MoverThrowLeft::
	ld a, [wJumpHeight]
	ld bc, $5144
	cp $01
	jr z, jr_004_510b

	ld bc, $5156
	cp $02
	jr z, jr_004_510b

	ld bc, $5178
	cp $03
	jr z, jr_004_510b

	ld bc, $51aa
	cp $04
	jr z, jr_004_510b

	ld bc, $51ec
	cp $05
	jr z, jr_004_510b

	ld bc, $523e
	cp $06
	jr z, jr_004_510b

	ld bc, $52a0
	cp $07
	jr z, jr_004_510b

	ld bc, $5312
	cp $08
	jr z, jr_004_510b

	ld bc, $5394
	cp $09
	jr z, jr_004_510b

	ld bc, $5426

jr_004_510b:
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	push af
	inc a
	ld [de], a
	pop af
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	cp $80
	jp z, MoverDone

	ld d, a
	ld a, [hl]
	sub d
	ld [hli], a
	inc bc
	ld a, [bc]
	ld d, a
	ld a, [hl]
	sbc d
	ld [hl], a
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	dec bc
	dec bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $80, $80, $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $80, $80, $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00
	db $01, $00, $01, $00, $80, $80, $03, $00, $03, $00, $03, $00, $02, $00, $03, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $80, $80, $03, $00, $03, $00, $03, $00, $02, $00
	db $03, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $03, $00, $03, $00, $03, $00
	db $02, $00, $03, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $03, $00, $03, $00
	db $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $03, $00
	db $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $80, $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $80, $80

MoverThrowRight::
	ld a, [wJumpHeight]
	ld bc, $5144
	cp $01
	jr z, jr_004_550d

	ld bc, $5156
	cp $02
	jr z, jr_004_550d

	ld bc, $5178
	cp $03
	jr z, jr_004_550d

	ld bc, $51aa
	cp $04
	jr z, jr_004_550d

	ld bc, $51ec
	cp $05
	jr z, jr_004_550d

	ld bc, $523e
	cp $06
	jr z, jr_004_550d

	ld bc, $52a0
	cp $07
	jr z, jr_004_550d

	ld bc, $5312
	cp $08
	jr z, jr_004_550d

	ld bc, $5394
	cp $09
	jr z, jr_004_550d

	ld bc, $5426

jr_004_550d:
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	push af
	inc a
	ld [de], a
	pop af
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	cp $80
	jp z, MoverDone

	ld d, a
	ld a, [hl]
	sub d
	ld [hli], a
	inc bc
	ld a, [bc]
	ld d, a
	ld a, [hl]
	sbc d
	ld [hl], a
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	inc bc
	inc bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


MoverHopLeft2::
	ld bc, $5559
	call StepMoverArc
	ldh a, [hNumber]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	dec [hl]
	dec [hl]
	ret


	db $fa, $ff, $fc, $ff, $fd, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $01, $00, $01, $00, $02, $00, $03, $00, $04, $00, $06, $00, $fc, $ff, $fc, $ff
	db $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $02, $00, $03, $00
	db $03, $00, $04, $00, $04, $00, $04, $00, $05, $00, $05, $00, $05, $00, $80, $80

MoverSpinHop2::
	ld bc, $55ca
	call StepMoverArc
	ld a, [wFadeState]
	or a
	ret nz

	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	srl a
	srl a
	and $03
	ldh [hPlayerDir], a
	jp SetPlayerPoseFromDir


	db $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00
	db $80, $80

StartScript::
	xor a
	ld [wScriptPos], a
	ld [$d8d6], a
	jr jr_004_5605

NextScriptCommand::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a

RunScriptCommand:
jr_004_5605:
	call ReadScriptWord
	ld a, b
	and c
	cp $ff
	jr nz, jr_004_5613

	xor a
	ld [wScriptRunning], a
	ret


jr_004_5613:
	ld hl, wScriptRunning
	set 0, [hl]
	ld a, b
	cp $ff
	jp nz, ScriptQueueMessage

	ld a, c
	rst $00

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
	dw ScriptCmdMapRoutine1
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
	dw ScriptCmdWaitLink4
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
	dw ScriptCmdBoostTopStat
	dw ScriptCmdSpecialBattle
	dw ScriptCmdStartSpecialBattle
	dw ScriptCmdSetupTournament
	dw ScriptCmdGivePrize
	dw ScriptCmdStartShootingStars
	dw ScriptCmdJumpIfLevelBelowCap
	dw ScriptCmdPayPerLevel
	dw ScriptCmdMapRoutine2
	dw ScriptCmdBlankScreen
	dw ScriptCmdRedrawScreen
	dw ScriptCmdJumpIfPartyFit
	dw ScriptCmdWaitLink2

ScriptQueueMessage::
	ld hl, wScriptRunning
	set 1, [hl]
	ld a, c
	ld [wScriptMessage], a
	ld a, b
	ld [$d8da], a
	ret


	ld a, [wScriptRunning]
	bit 1, a
	ret z

	ld hl, wScriptRunning
	res 1, [hl]
	ld a, [wScriptMessage]
	ld l, a
	ld a, [$d8da]
	ld h, a
	call PrintMessage
	ret


ScriptCmdJumpIfFlagClear::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call TestEventFlag
	jp nz, NextScriptCommand

	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdJumpIfFlagSet::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call TestEventFlag
	jp z, NextScriptCommand

	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdClearFlag::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	call ClearEventFlag
	jp NextScriptCommand


ScriptCmdSetFlag::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	call SetEventFlag
	jp NextScriptCommand


ScriptCmdOpenFieldMenu::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wScriptMenu], a
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wScriptMenuText], a
	ld a, b
	ld [$c8f1], a
	ld hl, wFieldFlags
	set 4, [hl]
	xor a
	ld [wMenuStep], a
	ld a, [wScriptMenu]
	cp $09
	ret z

	cp $0a
	ret z

	ld a, $59
	call QueueSound
	ret


ScriptCmdBattle::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wEncSpecies], a
	ld a, b
	ld [$da04], a
	xor a
	ld [wEncCount], a
	ld hl, wFieldFlags
	set 6, [hl]
	xor a
	ld [wMenuStep], a
	ld a, $01
	ld [wBattleKind], a
	ret


ScriptCmdNextEventStep::
	ld a, [wFieldFlags]
	bit 0, a
	ret z

	ld hl, wEventStep
	inc [hl]
	ret


ScriptCmdStartEvent::
	ld a, [wFieldFlags]
	bit 0, a
	ret nz

	ld hl, $ffff
	ld a, l
	ld [wEventRoutine], a
	ld a, h
	ld [$c918], a
	ld hl, wFieldFlags
	set 0, [hl]
	xor a
	ld [wEventStep], a
	ld [$c916], a
	ret


ScriptCmdNop::
	ret


ScriptCmdWait::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wScriptWait], a
	ld hl, wScriptRunning
	set 2, [hl]
	ret


ScriptCmdWalkX::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wScriptWalker], a
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wScriptWalkX], a
	ld a, b
	ld [$d8de], a
	ld hl, wScriptRunning
	set 3, [hl]
	ret


ScriptCmdWalkY::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wScriptWalker], a
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wScriptWalkY], a
	ld a, b
	ld [$d8e0], a
	ld hl, wScriptRunning
	set 3, [hl]
	ret


ScriptCmdFace::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	or a
	jr nz, jr_004_5942

	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord

SetPlayerFacing:
	ld a, c
	or a
	jr nz, jr_004_590d

	ld a, $00
	ldh [hPlayerAttr], a
	ld a, $00
	ldh [hPlayerPose], a
	ld a, $00
	ldh [hPlayerDir], a
	jp NextScriptCommand


jr_004_590d:
	cp $01
	jr nz, jr_004_5920

	ld a, $20
	ldh [hPlayerAttr], a
	ld a, $01
	ldh [hPlayerPose], a
	ld a, $01
	ldh [hPlayerDir], a
	jp NextScriptCommand


jr_004_5920:
	cp $02
	jr nz, jr_004_5933

	ld a, $00
	ldh [hPlayerAttr], a
	ld a, $02
	ldh [hPlayerPose], a
	ld a, $02
	ldh [hPlayerDir], a
	jp NextScriptCommand


jr_004_5933:
	ld a, $00
	ldh [hPlayerAttr], a
	ld a, $01
	ldh [hPlayerPose], a
	ld a, $03
	ldh [hPlayerDir], a
	jp NextScriptCommand


jr_004_5942:
	dec a
	swap a
	add a
	ld hl, $d7d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	pop hl
	ld [hl], c
	jp NextScriptCommand


ScriptCmdSetActorByte::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	or a
	jr nz, jr_004_5996

	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld l, c
	ld h, b
	jr jr_004_59b9

jr_004_5996:
	dec a
	swap a
	add a
	ld hl, wActors
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	pop hl
	add hl, bc

jr_004_59b9:
	push hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	pop hl
	ld [hl], c
	jp NextScriptCommand


ScriptCmdJumpIfScreen::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, [wMapScreen]
	cp c
	jp nz, NextScriptCommand

	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdWarp::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wWarpMap], a
	ld a, b
	ld [wWarpOnGateFloor], a
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wWarpX], a
	ld a, b
	ld [$c970], a
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wWarpY], a
	ld a, b
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
	xor a
	ld [wScriptRunning], a
	ld hl, wFieldFlags
	res 0, [hl]
	xor a
	ld [wTextState], a
	ret


ScriptCmdWalkToX::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wScriptWalker], a
	ld hl, hPlayerX
	or a
	jr z, jr_004_5a99

	dec a
	swap a
	add a
	ld hl, $d7ea
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a

jr_004_5a99:
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	pop hl
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, c
	ld [wScriptWalkX], a
	ld a, b
	ld [$d8de], a
	ld hl, wScriptRunning
	set 3, [hl]
	ret


ScriptCmdWalkToY::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wScriptWalker], a
	ld hl, hPlayerY
	or a
	jr z, jr_004_5aef

	dec a
	swap a
	add a
	ld hl, $d7ec
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a

jr_004_5aef:
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	pop hl
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, c
	ld [wScriptWalkY], a
	ld a, b
	ld [$d8e0], a
	ld hl, wScriptRunning
	set 3, [hl]
	ret


ScriptCmdWriteByte::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld l, c
	ld h, b
	push hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	pop hl
	ld [hl], c
	jp NextScriptCommand


ScriptCmdWriteWord::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld l, c
	ld h, b
	push hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	pop hl
	ld [hl], c
	inc hl
	ld [hl], b
	jp NextScriptCommand


ScriptCmdJump::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdJumpIfByte::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld l, c
	ld h, b
	push hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	pop hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, [hl]
	cp c
	jp nz, NextScriptCommand

	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdRedrawFollowers::
	call BuildStatusBar
	call DrawStatusBar
	ret


ScriptCmdSwapTiles::
	ld a, [wMapId]
	cp $2f
	jr nz, jr_004_5c04

	ld a, [wMapScreen]
	cp $04
	jr z, jr_004_5bed

	cp $05
	jr nz, jr_004_5c04

jr_004_5bed:
	ld hl, $9380
	ld de, $9360
	ld b, $20
	call SwapTileBytes
	ld hl, $9600
	ld de, $9620
	ld b, $20
	call SwapTileBytes
	ret


jr_004_5c04:
	ret


SwapTileBytes::
	di
	call WaitVRAMAccess
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	ei
	inc de
	dec b
	jr nz, SwapTileBytes

	ret


ScriptCmdGiveMonster::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wNewMonId], a
	ld a, b
	ld [$da13], a
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_004_5c36:
	ld a, [de]
	or a
	jr z, jr_004_5c48

	inc c
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_004_5c36

	ld c, $13

jr_004_5c48:
	ld a, c
	ld [wNewMonSlot], a
	ld hl, far_CreateMonster
	rst $10
	ld a, [wPartyCount]
	cp $03
	jr z, jr_004_5c68

	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wNewMonSlot]
	ld [hl], a
	ld hl, wPartyCount
	inc [hl]

jr_004_5c68:
	ld hl, far_RefreshPartyGfx
	rst $10
	ret


ScriptCmdWaitMovers::
	ld a, [wScriptRunning]
	bit 4, a
	jp z, NextScriptCommand

	ld a, [wScriptPos]
	sub $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	sbc $00
	ld [$d8d6], a
	ret


ScriptCmdMoveX::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld hl, wMovers
	ld a, c
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	inc hl
	inc hl
	ld [hl], $00
	inc hl
	ld [hl], c
	inc hl
	push hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	pop hl
	ld [hl], c
	inc hl
	ld [hl], b
	ld hl, wScriptRunning
	set 4, [hl]
	jp NextScriptCommand


ScriptCmdMoveY::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld hl, wMovers
	ld a, c
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	inc hl
	inc hl
	ld [hl], $00
	inc hl
	ld [hl], c
	inc hl
	inc hl
	inc hl
	push hl
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	pop hl
	ld [hl], c
	inc hl
	ld [hl], b
	ld hl, wScriptRunning
	set 4, [hl]
	jp NextScriptCommand


ScriptCmdStartMover::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld hl, wMovers
	ld a, c
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	inc hl
	ld [hl], $00
	inc hl
	ld [hl], b
	inc hl
	ld [hl], c
	ld hl, wScriptRunning
	set 4, [hl]
	jp NextScriptCommand


ScriptCmdKeepFacing::
	ld hl, wScriptRunning
	set 5, [hl]
	jp NextScriptCommand


ScriptCmdTurnWhileMoving::
	ld hl, wScriptRunning
	res 5, [hl]
	jp NextScriptCommand


ScriptCmdSetupArenaBattle::
	ld a, [wArenaClass]
	ld b, a
	add a
	add b
	ld b, a
	ld a, [wArenaRound]
	add b
	ld b, a
	add a
	add b
	ld hl, $00e0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wEncSpecies], a
	ld a, h
	ld [$da04], a
	inc hl
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	inc hl
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a
	ld a, $02
	ld [wEncCount], a
	ld a, [wArenaClass]
	cp $09
	jr nz, jr_004_5db9

	ld hl, $01e1
	ld a, l
	ld [wEncSpecies], a
	ld a, h
	ld [$da04], a
	ld hl, $01e2
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	ld hl, $01e3
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a

jr_004_5db9:
	ld a, [wArenaClass]
	ld b, a
	add a
	add b
	ld b, a
	ld a, [wArenaRound]
	add b
	add a
	ld hl, $5e22
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wEncGfx], a
	ld a, [hl]
	ld [$d7cb], a
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	call GetSpeciesGfx
	ld [$d7ce], a
	ld a, $01
	ld [$d7cf], a
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	call GetSpeciesGfx
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	call GetSpeciesGfx
	ld [$d7d0], a
	ld a, $01
	ld [$d7d1], a
	ret


GetSpeciesGfx::
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wNewMonNameText]
	add $10
	ret


	db $0b, $00, $0a, $00, $11, $00, $0b, $00, $0a, $00, $da, $01, $0b, $00, $0a, $00
	db $0b, $00, $0b, $00, $0a, $00, $02, $00, $0b, $00, $0a, $00, $0b, $00, $0b, $00
	db $0a, $00, $0f, $00, $0b, $00, $0a, $00, $0c, $00, $0b, $00, $0a, $00, $13, $00
	db $0b, $00, $0a, $00, $14, $00, $08, $00, $08, $00, $08, $00

ScriptCmdStartBattle::
	ld hl, wFieldFlags
	set 6, [hl]
	xor a
	ld [wMenuStep], a
	ld a, $01
	ld [wBattleKind], a
	ret


ScriptCmdPlaySound::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	call QueueSound
	jp NextScriptCommand


ScriptCmdFastMovers::
	ld hl, wScriptRunning
	set 6, [hl]
	jp NextScriptCommand


ScriptCmdJumpIfHasSkillsA::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

	ld a, c
	ld hl, wMonSkills
	push bc
	call PartyMonsterField
	pop bc
	ld b, $08

jr_004_5ec8:
	ld a, [hli]
	cp $00
	jr z, jr_004_5efb

	cp $01
	jr z, jr_004_5efb

	cp $02
	jr z, jr_004_5efb

	cp $03
	jr z, jr_004_5efb

	cp $04
	jr z, jr_004_5efb

	cp $05
	jr z, jr_004_5efb

	cp $44
	jr z, jr_004_5efb

	cp $5c
	jr z, jr_004_5efb

	cp $5d
	jr z, jr_004_5efb

	cp $5e
	jr z, jr_004_5efb

	cp $5f
	jr z, jr_004_5efb

	dec b
	jr nz, jr_004_5ec8

	jp NextScriptCommand


jr_004_5efb:
	ld a, c
	ld [wScriptResult], a
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdMapRoutine1::
	ld a, [wScriptMap]
	cp $06
	jr nc, jr_004_5f1f

	ld hl, far_DrawScriptTiles_0C
	rst $10
	ret


jr_004_5f1f:
	cp $20
	jr nc, jr_004_5f28

	ld hl, far_DrawScriptTiles_0D
	rst $10
	ret


jr_004_5f28:
	cp $40
	jr nc, jr_004_5f31

	ld hl, far_DrawScriptTiles_0E
	rst $10
	ret


jr_004_5f31:
	ld hl, far_DrawScriptTiles_0F
	rst $10
	ret


ScriptCmdReleaseMonster::
	ld a, [wScriptResult]
	ld hl, wMonsters
	call PartyMonsterField
	ld [hl], $00
	ld hl, far_CompactMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	call BuildStatusBar
	call DrawStatusBar
	jp NextScriptCommand


ScriptCmdFadeOut::
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
	ret


ScriptCmdHealParty::
	ld hl, far_HealAllMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	jp NextScriptCommand


ScriptCmdJumpIfMonstersFull::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld hl, wMonsters
	ld b, $14
	ld c, $00

jr_004_5f7e:
	ld a, [hl]
	or a
	jr z, jr_004_5f8e

	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	inc c
	dec b
	jr nz, jr_004_5f7e

jr_004_5f8e:
	ld a, c
	cp $14
	jp c, NextScriptCommand

	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdAddMonster::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wNewMonId], a
	ld a, b
	ld [$da13], a
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_004_5fbc:
	ld a, [de]
	or a
	jr z, jr_004_5fce

	inc c
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_004_5fbc

	jr jr_004_5fda

jr_004_5fce:
	ld a, c
	ld [wNewMonSlot], a
	ld hl, far_CreateMonster
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10

jr_004_5fda:
	ret


ScriptCmdGiveItem::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld hl, wBagItems
	ld b, $14

jr_004_5ff3:
	ld a, [hl]
	or a
	jr z, jr_004_6000

	cp $ff
	jr z, jr_004_6000

	inc hl
	dec b
	jr nz, jr_004_5ff3

	ret


jr_004_6000:
	ld [hl], c
	ret


ScriptCmdJumpIfNamedMonster::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld hl, wMonsters
	ld b, $14
	ld c, $00

jr_004_6019:
	push hl
	ld a, [hl]
	or a
	jr z, jr_004_604c

	cp $01
	jr z, jr_004_604c

	ld a, l
	add $4b
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp $0a
	jr c, jr_004_604c

	ld a, l
	add $b6
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld de, $605c
	ld b, $08

jr_004_603c:
	ld a, [de]
	cp [hl]
	jr nz, jr_004_604c

	inc de
	inc hl
	dec b
	jr nz, jr_004_603c

	pop hl
	call ReadScriptWord
	jp ScriptJumpTo


jr_004_604c:
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	inc c
	dec b
	jr nz, jr_004_6019

	jp NextScriptCommand


	db $67, $85, $42, $8d, $26, $f0, $f0, $f0

ScriptCmdJumpIfBagFull::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld hl, wBagItems
	ld b, $14
	ld c, $00

jr_004_607b:
	ld a, [hli]
	or a
	jr z, jr_004_6087

	cp $ff
	jr z, jr_004_6087

	inc c
	dec b
	jr nz, jr_004_607b

jr_004_6087:
	ld a, c
	cp $14
	jp c, NextScriptCommand

	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdMonsterReaction::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	ret z

	push af
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld a, [wMonStats]
	add a
	ld hl, $60f4
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	push hl
	ld d, a
	ld hl, far_GetMonsterPersonality
	rst $10
	ld a, d
	add a
	pop hl
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, wScriptRunning
	set 1, [hl]
	ld a, c
	ld [wScriptMessage], a
	ld a, b
	ld [$d8da], a
	ret


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

ScriptCmdPickFromTable::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	add a
	add a
	add c
	ld c, a
	ld a, [wScriptChoiceRow]
	dec a
	add c
	ld hl, $620d
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wScriptChoice], a
	jp NextScriptCommand


	db $01, $01, $00, $02, $02, $02, $01, $02, $01, $02, $01, $01, $02, $00, $01, $01
	db $01, $00, $02, $01, $00, $02, $00, $00, $00, $01, $02, $00, $00, $01, $00, $01
	db $01, $01, $01, $02, $01, $02, $01, $00, $01, $01, $00, $01, $00

ScriptCmdIncByte::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld l, c
	ld h, b
	inc [hl]
	jp NextScriptCommand


ScriptCmdJumpIfAttack100::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

	ld a, c
	ld hl, wMonAttack
	push bc
	call PartyMonsterField
	pop bc
	ld a, [hli]
	sub $64
	ld a, [hl]
	sbc $00
	jp c, NextScriptCommand

	ld a, c
	ld [wScriptResult], a
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdJumpIfLibrary100::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld b, $00
	ld c, $00

jr_004_62bf:
	push bc
	ld hl, wLibraryFlags
	ld a, b
	call TestFlag
	pop bc
	jr z, jr_004_62cb

	inc c

jr_004_62cb:
	inc b
	ld a, b
	cp $f0
	jr nz, jr_004_62bf

	ld a, c
	cp $64
	jp c, NextScriptCommand

	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdJumpIfSpeciesAF::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

	ld a, c
	ld hl, wMonRecSpecies
	push bc
	call PartyMonsterField
	pop bc
	ld a, [hl]
	cp $af
	jp nz, NextScriptCommand

	ld a, c
	ld [wScriptResult], a
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdGiveGold::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld l, c
	ld h, b
	ld e, $00
	call AddGold
	jp NextScriptCommand


ScriptCmdJumpIfHasSkillsB::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

	ld a, c
	ld hl, wMonSkills
	push bc
	call PartyMonsterField
	pop bc
	ld b, $08

jr_004_6388:
	ld a, [hli]
	cp $0f
	jr z, jr_004_63a3

	cp $10
	jr z, jr_004_63a3

	cp $45
	jr z, jr_004_63a3

	cp $11
	jr z, jr_004_63a3

	cp $5a
	jr z, jr_004_63a3

	dec b
	jr nz, jr_004_6388

	jp NextScriptCommand


jr_004_63a3:
	ld a, c
	ld [wScriptResult], a
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdHealParty2::
	ld hl, far_HealAllMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	jp NextScriptCommand


ScriptCmdBossBattle::
	ld a, [wScriptBossIndex]
	add a
	ld hl, $63ef
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wEncSpecies], a
	ld a, [hl]
	ld [$da04], a
	ld a, $00
	ld [wEncCount], a
	ld hl, wFieldFlags
	set 6, [hl]
	xor a
	ld [wMenuStep], a
	ld a, $01
	ld [wBattleKind], a
	ret


	db $3d, $01, $3e, $01, $3f, $01, $40, $01, $41, $01, $42, $01, $43, $01, $44, $01
	db $44, $01

ScriptCmdGivePrizeItem::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld hl, wArenaWins
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld hl, wBagItems
	ld b, $14

jr_004_6424:
	ld a, [hl]
	or a
	jr z, jr_004_6432

	cp $ff
	jr z, jr_004_6432

	inc hl
	dec b
	jr nz, jr_004_6424

	jr jr_004_6433

jr_004_6432:
	ld [hl], c

jr_004_6433:
	ld l, c
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
	jp NextScriptCommand


ScriptCmdJumpIfHasSkillsC::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

	ld a, c
	ld hl, wMonSkills
	push bc
	call PartyMonsterField
	pop bc
	ld b, $08

jr_004_6478:
	ld a, [hli]
	cp $84
	jr z, jr_004_648f

	cp $85
	jr z, jr_004_648f

	cp $86
	jr z, jr_004_648f

	cp $87
	jr z, jr_004_648f

	dec b
	jr nz, jr_004_6478

	jp NextScriptCommand


jr_004_648f:
	ld a, c
	ld [wScriptResult], a
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdPrintMessage::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld l, c
	ld h, b
	call PrintMessage
	jp NextScriptCommand


ScriptCmdLeaderLeaves::
	ld a, [wLeaderSlot]
	ld [wCurPartyMember], a
	ld hl, far_Call_16_474A
	rst $10
	ld hl, wFieldFlags
	res 4, [hl]
	res 0, [hl]
	xor a
	ld [wMenuStep], a
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld l, [hl]
	ld h, $05
	ld de, wTextArg1
	call CopySystemText
	ld a, [wCurPartyMember]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	ld de, wTextArg1
	call AppendNumberText
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld de, wTextArg1
	call AppendSexSign
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wChosenMonPic], a
	ld [wEncGfx], a
	ld a, $01
	ld [$d7cb], a
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld a, l
	ld [wChosenMonName], a
	ld a, h
	ld [$c8f3], a
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld [wChosenMonGender], a
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wChosenMonSpecies], a
	ld a, $08
	ld [wWarpMap], a
	ld a, $00
	ld [wWarpOnGateFloor], a
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld a, $02
	ld [wStoryStep], a
	xor a
	ld [wScriptRunning], a
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
	ret


AppendNumberText::
	or a
	ret z

	push af

jr_004_6586:
	ld a, [de]
	inc de
	cp $f0
	jr nz, jr_004_6586

	dec de
	ld a, $a2
	ld [de], a
	inc de
	pop af
	ld l, e
	ld h, d
	call ByteToDecimal
	ret


AppendSexSign::
	push af

jr_004_6599:
	ld a, [de]
	inc de
	cp $f0
	jr nz, jr_004_6599

	dec de
	pop af
	and $01
	add $a7
	ld [de], a
	inc de
	ld a, $f0
	ld [de], a
	ret


ScriptCmdWarpNoFade::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wWarpMap], a
	ld a, b
	ld [wWarpOnGateFloor], a
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wWarpX], a
	ld a, b
	ld [$c970], a
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wWarpY], a
	ld a, b
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld hl, wFieldFlags
	set 5, [hl]
	xor a
	ld [wMenuStep], a
	xor a
	ld [wScriptRunning], a
	ld hl, wFieldFlags
	res 0, [hl]
	xor a
	ld [wTextState], a
	ret


ScriptCmdSetScriptFlag0::
	ld hl, wScriptFlags
	set 0, [hl]
	jp NextScriptCommand


ScriptCmdSetScriptFlag1::
	ld hl, wScriptFlags
	set 1, [hl]
	jp NextScriptCommand


ScriptCmdEndGameMode::
	ld a, $04
	call StartFade
	ld hl, wGameModeChange
	inc [hl]
	ret


ScriptCmdCopyLeaderSpecies::
	ld a, $00
	ld hl, wMonRecSpecies
	call PartyMonsterField
	ld l, [hl]
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
	jp NextScriptCommand


ScriptCmdJumpIfOwnsSpecies::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld d, c
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld hl, wMonsters
	ld b, $14
	ld c, $00

jr_004_6671:
	push hl
	ld a, [hl]
	or a
	jr z, jr_004_668d

	cp $01
	jr z, jr_004_668d

	ld a, l
	add $09
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp d
	jr nz, jr_004_668d

	pop hl
	call ReadScriptWord
	jp ScriptJumpTo


jr_004_668d:
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	inc c
	dec b
	jr nz, jr_004_6671

	jp NextScriptCommand


ScriptCmdPlayMusic::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, [wMusic]
	ld [wSavedMusic], a
	ld a, c
	call QueueMusic
	jp NextScriptCommand


ScriptCmdSaveReturnMenu::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wScriptMenuArg], a
	ld a, b
	ld [$c8f8], a
	ld a, [wMapId]
	ld c, a
	ld a, [wOnGateFloor]
	ld b, a
	ld a, c
	ld [wReturnMap], a
	ld a, b
	ld [$c8fc], a
	ldh a, [hPlayerX]
	ld c, a
	ldh a, [$ff93]
	ld b, a
	ld a, c
	ld [wReturnX], a
	ld a, b
	ld [$c8fe], a
	ldh a, [hPlayerY]
	ld c, a
	ldh a, [$ff96]
	ld b, a
	ld a, c
	ld [wReturnY], a
	ld a, b
	ld [$c900], a
	ldh a, [hPlayerDir]
	ld [wReturnDir], a
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wReturnActor], a
	jp NextScriptCommand


ScriptCmdReturnWarp::
	ld a, [wReturnMap]
	ld c, a
	ld a, [$c8fc]
	ld b, a
	ld a, c
	ld [wWarpMap], a
	ld a, b
	ld [wWarpOnGateFloor], a
	ld a, [wReturnX]
	ld c, a
	ld a, [$c8fe]
	ld b, a
	ld a, c
	ld [wWarpX], a
	ld a, b
	ld [$c970], a
	ld a, [wReturnY]
	ld c, a
	ld a, [$c900]
	ld b, a
	ld a, c
	ld [wWarpY], a
	ld a, b
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
	xor a
	ld [wScriptRunning], a
	ld hl, wFieldFlags
	res 0, [hl]
	xor a
	ld [wTextState], a
	ret


ScriptCmdReturnMenuText::
	ld a, [wReturnDir]
	ldh [hPlayerDir], a
	call SetPlayerPoseFromDir
	ld a, [wReturnActor]
	dec a
	swap a
	add a
	ld hl, $d7d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ldh a, [hPlayerDir]
	add $02
	and $03
	ld [hl], a
	ld a, [wScriptMenuText]
	ld c, a
	ld a, [$c8f1]
	ld b, a
	ld a, c
	add $09
	ld c, a
	ld a, b
	adc $00
	ld b, a
	ld hl, wScriptRunning
	set 1, [hl]
	ld a, c
	ld [wScriptMessage], a
	ld a, b
	ld [$d8da], a
	ld hl, wFieldFlags
	set 0, [hl]
	ret


ScriptCmdRestoreParty::
	ld hl, wSavedParty
	ld a, [hli]
	ld [wPartyCount], a
	ld a, [hli]
	ld [wParty], a
	ld a, [hli]
	ld [$ca8f], a
	ld a, [hli]
	ld [$ca90], a
	ld a, [hli]
	ld [wPartyGfx], a
	ld a, [hli]
	ld [$ca92], a
	ld a, [hli]
	ld [$ca93], a
	ld a, [wParty]
	call PutMonsterInParty
	ld a, [$ca8f]
	call PutMonsterInParty
	ld a, [$ca90]
	call PutMonsterInParty
	ld hl, far_CompactMonsters
	rst $10
	ld hl, far_HealAllMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	jp NextScriptCommand


PutMonsterInParty::
	cp $ff
	ret z

	ld hl, wMonsters
	call MonsterField
	ld [hl], $02
	ret


ScriptCmdWaitLink4::
	ld a, [$ddb4]
	ld hl, $ddce
	and [hl]
	ld hl, $dde8
	and [hl]
	ld hl, $de02
	and [hl]
	cp $ff
	jp z, NextScriptCommand

	ld a, [wScriptPos]
	sub $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	sbc $00
	ld [$d8d6], a
	ret


ScriptCmdActorFaceUp::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld c, $02

SetActorFacing:
	or a
	jp z, SetPlayerFacing

	dec a
	swap a
	add a
	ld hl, $d7d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	jp NextScriptCommand


ScriptCmdActorFaceDown::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld c, $00
	jp SetActorFacing


ScriptCmdActorFaceLeft::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld c, $01
	jp SetActorFacing


ScriptCmdActorFaceRight::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld c, $03
	jp SetActorFacing


ScriptCmdRestoreMusic::
	ld a, [wSavedMusic]
	call QueueMusic
	jp NextScriptCommand


ScriptCmdWaitDPad::
	ld a, [wJoyPressed]
	and $f0
	jp nz, NextScriptCommand

	ld a, [wScriptPos]
	sub $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	sbc $00
	ld [$d8d6], a
	ret


ScriptCmdWaitFrames::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wScriptWait], a
	ld hl, wScriptFlags
	set 2, [hl]
	ret


ScriptCmdSaveReturnPoint::
	ld a, [wMapId]
	ld c, a
	ld a, [wOnGateFloor]
	ld b, a
	ld a, c
	ld [wReturnMap], a
	ld a, b
	ld [$c8fc], a
	ldh a, [hPlayerX]
	ld c, a
	ldh a, [$ff93]
	ld b, a
	ld a, c
	ld [wReturnX], a
	ld a, b
	ld [$c8fe], a
	ldh a, [hPlayerY]
	ld c, a
	ldh a, [$ff96]
	ld b, a
	ld a, c
	ld [wReturnY], a
	ld a, b
	ld [$c900], a
	ldh a, [hPlayerDir]
	ld [wReturnDir], a
	jp NextScriptCommand


ScriptCmdReturnWarp2::
	ld a, [wReturnMap]
	ld c, a
	ld a, [$c8fc]
	ld b, a
	ld a, c
	ld [wWarpMap], a
	ld a, b
	ld [wWarpOnGateFloor], a
	ld a, [wReturnX]
	ld c, a
	ld a, [$c8fe]
	ld b, a
	ld a, c
	ld [wWarpX], a
	ld a, b
	ld [$c970], a
	ld a, [wReturnY]
	ld c, a
	ld a, [$c900]
	ld b, a
	ld a, c
	ld [wWarpY], a
	ld a, b
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
	xor a
	ld [wScriptRunning], a
	ld hl, wFieldFlags
	res 0, [hl]
	xor a
	ld [wTextState], a
	ret


ScriptCmdReturnFace::
	ld a, [wReturnDir]
	ldh [hPlayerDir], a
	call SetPlayerPoseFromDir
	ld hl, $d7f8
	ldh a, [hPlayerDir]
	add $02
	and $03
	ld [hl], a
	jp NextScriptCommand


ScriptCmdLibraryRank::
	ld b, $00
	ld c, $00

jr_004_6970:
	push bc
	ld hl, wLibraryFlags
	ld a, b
	call TestFlag
	pop bc
	jr z, jr_004_697c

	inc c

jr_004_697c:
	inc b
	ld a, b
	cp $f0
	jr nz, jr_004_6970

	push bc
	ld a, c
	ld hl, wTextArg0
	call ByteToDecimal
	pop bc
	ld hl, $699d
	ld a, c
	ld e, $ff

jr_004_6991:
	cp [hl]
	inc hl
	inc e
	jr nc, jr_004_6991

	ld a, e
	ld [wScriptResult], a
	jp NextScriptCommand


	db $07, $10, $1a, $26, $32, $47, $64, $83, $a1, $c8, $d7, $ff

ScriptCmdRandomBattle::
	ld bc, $0000
	ld a, [wParty]
	call AddPartyMonLevel
	ld a, [$ca8f]
	call AddPartyMonLevel
	ld a, [$ca90]
	call AddPartyMonLevel
	ld l, c
	ld h, b
	inc hl
	ld a, $14
	call Divide16
	ld a, l
	cp $07
	jr c, jr_004_69cd

	ld a, $07

jr_004_69cd:
	ld hl, $6a3c
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	call Random
	pop hl
	push hl
	ld a, [wRandomHigh]
	and $0f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wEncSpecies], a
	ld a, h
	ld [$da04], a
	pop hl
	push hl
	call Random
	pop hl
	push hl
	ld a, [wRandomHigh]
	and $0f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	pop hl
	push hl
	call Random
	pop hl
	push hl
	ld a, [wRandomHigh]
	and $0f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a
	pop hl
	ld a, $02
	ld [wEncCount], a
	ld hl, wFieldFlags
	set 6, [hl]
	xor a
	ld [wMenuStep], a
	ld a, $02
	ld [wBattleKind], a
	ret


	db $60, $01, $70, $01, $80, $01, $90, $01, $a0, $01, $b0, $01, $c0, $01, $d0, $01
	db $d0, $01

AddPartyMonLevel::
	cp $ff
	ret z

	push bc
	ld hl, wMonLevel
	call MonsterField
	pop bc
	ld a, [hl]
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ret


ScriptCmdFaceActor1::
	ldh a, [hPlayerY]
	and $f0
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, [$d7ec]
	and $f0
	ld e, a
	ld a, [$d7ed]
	ld d, a
	push hl
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, h
	or l
	pop hl
	jr z, jr_004_6a8d

	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, $00
	jr c, jr_004_6abc

	ld a, $02
	jr jr_004_6abc

jr_004_6a8d:
	ldh a, [hPlayerX]
	and $f0
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, [$d7ea]
	and $f0
	ld e, a
	ld a, [$d7eb]
	ld d, a
	push hl
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, h
	or l
	pop hl
	jr z, jr_004_6ab9

	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, $03
	jr c, jr_004_6abc

	ld a, $01
	jr jr_004_6abc

jr_004_6ab9:
	jp NextScriptCommand


jr_004_6abc:
	ldh [hPlayerDir], a
	call SetPlayerPoseFromDir
	ld hl, $d7d8
	ldh a, [hPlayerDir]
	add $02
	and $03
	ld [hl], a
	jp NextScriptCommand


ScriptCmdGiveRandomItem::
	ld a, [wRandomHigh]
	ld b, a
	ld a, $25
	call Divide8
	inc a
	ld c, a
	ld hl, wBagItems
	ld b, $14

jr_004_6ade:
	ld a, [hl]
	or a
	jr z, jr_004_6aed

	cp $ff
	jr z, jr_004_6aed

	inc hl
	dec b
	jr nz, jr_004_6ade

	jp NextScriptCommand


jr_004_6aed:
	ld [hl], c
	ld l, c
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
	jp NextScriptCommand


ScriptCmdLoseRandomItem::
	ld hl, wBagItems
	ld b, $14
	ld c, $00

jr_004_6b01:
	ld a, [hl]
	or a
	jr z, jr_004_6b0e

	cp $ff
	jr z, jr_004_6b0e

	inc hl
	inc c
	dec b
	jr nz, jr_004_6b01

jr_004_6b0e:
	ld a, c
	ld [wScriptResult], a
	or a
	jp z, NextScriptCommand

	ld a, [wRandomHigh]
	ld b, a
	ld a, c
	call Divide8
	ld hl, wBagItems
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld [hl], $ff
	ld l, c
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
	ld hl, far_CompactBag
	rst $10
	jp NextScriptCommand


ScriptCmdLoseTenthOfGold::
	ld a, [wGold]
	ld l, a
	ld a, [$ca4c]
	ld h, a
	ld a, [$ca4d]
	ld e, a
	ld a, $0a
	call Divide24
	ld a, h
	or l
	or e
	ld [wScriptResult], a
	or a
	jp z, NextScriptCommand

	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	ld a, e
	ldh [$ffd7], a
	ld hl, wTextArg0
	call Number24ToDecimal
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ldh a, [$ffd7]
	ld e, a
	call SpendGold
	jp NextScriptCommand


ScriptCmdGiveRandomSeed::
	ld a, [wRandomHigh]
	ld b, a
	ld a, $05
	call Divide8
	add $13
	ld c, a
	ld hl, wBagItems
	ld b, $14

jr_004_6b84:
	ld a, [hl]
	or a
	jr z, jr_004_6b93

	cp $ff
	jr z, jr_004_6b93

	inc hl
	dec b
	jr nz, jr_004_6b84

	jp NextScriptCommand


jr_004_6b93:
	ld [hl], c
	ld l, c
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
	jp NextScriptCommand


ScriptCmdSkipFloors::
	ld a, [wGateFloors]
	dec a
	dec a
	ld b, a
	ld a, [wGateFloor]
	cp b
	jr z, jr_004_6bb9

	add $13
	ld [wGateFloor], a
	cp b
	jr c, jr_004_6bb9

	ld a, b
	dec a
	ld [wGateFloor], a

jr_004_6bb9:
	ld a, $01
	ld [wWarpPending], a
	ld a, $00
	ld [wWarpMap], a
	ld a, $80
	ld [wWarpOnGateFloor], a
	ld hl, wFieldFlags
	set 5, [hl]
	xor a
	ld [wMenuStep], a
	xor a
	ld [wScriptRunning], a
	ld hl, wFieldFlags
	res 0, [hl]
	xor a
	ld [wTextState], a
	ret


ScriptCmdBoostTopStat::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wScriptResult], a
	cp $ff
	jp z, NextScriptCommand

	ld [wCurPartyMember], a
	ld hl, wMonMaxHP
	call MonsterField
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, wMonMaxMP
	call CompareStat
	jr c, jr_004_6c47

	ld hl, wMonAttack
	call CompareStat
	jr c, jr_004_6c47

	ld hl, wMonDefense
	call CompareStat
	jr c, jr_004_6c47

	ld hl, wMonAgility
	call CompareStat2x
	jr c, jr_004_6c47

	ld hl, wMonIntelligence
	call CompareStat4x
	jr c, jr_004_6c47

	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterMaxHP
	ld a, $00
	jp Jump_004_6d0a


jr_004_6c47:
	ld a, [wCurPartyMember]
	ld hl, wMonMaxMP
	call MonsterField
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, wMonAttack
	call CompareStat
	jr c, jr_004_6c81

	ld hl, wMonDefense
	call CompareStat
	jr c, jr_004_6c81

	ld hl, wMonAgility
	call CompareStat2x
	jr c, jr_004_6c81

	ld hl, wMonIntelligence
	call CompareStat4x
	jr c, jr_004_6c81

	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterMaxMP
	ld a, $01
	jp Jump_004_6d0a


jr_004_6c81:
	ld a, [wCurPartyMember]
	ld hl, wMonAttack
	call MonsterField
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, wMonDefense
	call CompareStat
	jr c, jr_004_6cb2

	ld hl, wMonAgility
	call CompareStat2x
	jr c, jr_004_6cb2

	ld hl, wMonIntelligence
	call CompareStat4x
	jr c, jr_004_6cb2

	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterAttack
	ld a, $02
	jr jr_004_6d0a

jr_004_6cb2:
	ld a, [wCurPartyMember]
	ld hl, wMonDefense
	call MonsterField
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, wMonAgility
	call CompareStat2x
	jr c, jr_004_6cdb

	ld hl, wMonIntelligence
	call CompareStat4x
	jr c, jr_004_6cdb

	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterDefense
	ld a, $03
	jr jr_004_6d0a

jr_004_6cdb:
	ld a, [wCurPartyMember]
	ld hl, wMonAgility
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, hl
	ld e, l
	ld d, h
	ld hl, wMonIntelligence
	call CompareStat4x
	jr c, jr_004_6cff

	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterAgility
	ld a, $04
	jr jr_004_6d0a

jr_004_6cff:
	ld hl, $0014
	ld a, [wCurPartyMember]
	call RaiseMonsterIntelligence
	ld a, $05

Jump_004_6d0a:
jr_004_6d0a:
	add $35
	ld l, a
	ld h, $02
	ld de, wTextArg1
	call CopySystemText
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	jp NextScriptCommand


CompareStat4x::
	call GetCurMonWord
	add hl, hl
	add hl, hl
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ret


CompareStat2x::
	call GetCurMonWord
	add hl, hl
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ret


CompareStat::
	call GetCurMonWord
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ret


GetCurMonWord::
	push de
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop de
	ret


ScriptCmdSpecialBattle::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, c
	ld [wEncSpecies], a
	ld a, b
	ld [$da04], a
	xor a
	ld [wEncCount], a
	ld hl, wFieldFlags
	set 6, [hl]
	xor a
	ld [wMenuStep], a
	ld a, $03
	ld [wBattleKind], a
	ret


ScriptCmdStartSpecialBattle::
	ld hl, wFieldFlags
	set 6, [hl]
	xor a
	ld [wMenuStep], a
	ld a, $03
	ld [wBattleKind], a
	ret


ScriptCmdSetupTournament::
	ld a, [wArenaWins]
	bit 7, a
	jr nz, jr_004_6d9e

	ld hl, wArenaWins
	inc [hl]

jr_004_6d9e:
	call RollTournamentTeam
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	ld a, l
	ld [$d9d1], a
	ld a, h
	ld [$d9d2], a
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	ld a, l
	ld [$d9d3], a
	ld a, h
	ld [$d9d4], a
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	ld a, l
	ld [$d9d5], a
	ld a, h
	ld [$d9d6], a
	call RollTournamentTeam
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	ld a, l
	ld [$d9d9], a
	ld a, h
	ld [$d9da], a
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	ld a, l
	ld [$d9db], a
	ld a, h
	ld [$d9dc], a
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	ld a, l
	ld [$d9dd], a
	ld a, h
	ld [$d9de], a
	call RollTournamentTeam
	ld hl, wEncGfx
	call SetEncounterGfx
	ld hl, $6f44
	ld a, [wArenaWins]
	cp $09
	jr c, jr_004_6e1a

	ld hl, $6f54

jr_004_6e1a:
	push hl
	call Random
	ld a, [wRandomHigh]
	and $0f
	pop hl
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wArenaPrize], a
	xor a
	ld [wArenaRound], a
	ld a, [wArenaPrize]
	ld l, a
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
	jp NextScriptCommand


SetEncounterGfx::
	push hl
	ld a, $ff
	ld [hli], a
	xor a
	ld [hli], a
	ld a, $ff
	ld [hli], a
	xor a
	ld [hli], a
	ld a, $ff
	ld [hli], a
	xor a
	ld [hl], a
	pop hl
	push hl
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	call GetSpeciesGfx2
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, [wEncCount]
	or a
	ret z

	push hl
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	call GetSpeciesGfx2
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, [wEncCount]
	cp $01
	ret z

	push hl
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	call GetSpeciesGfx2
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
	ret


GetSpeciesGfx2::
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wNewMonNameText]
	add $10
	ret


RollTournamentTeam::
	ld b, $00
	ld a, [wParty]
	call MaxLevelInto
	ld a, [$ca8f]
	call MaxLevelInto
	ld a, [$ca90]
	call MaxLevelInto
	ld a, b
	ld hl, $0209
	cp $04
	jr c, jr_004_6f13

	ld hl, $0d12
	cp $0a
	jr c, jr_004_6f13

	ld hl, $2112
	cp $10
	jr c, jr_004_6f13

	ld hl, $3912
	cp $16
	jr c, jr_004_6f13

	ld hl, $5112
	cp $1c
	jr c, jr_004_6f13

	ld hl, $6912
	cp $22
	jr c, jr_004_6f13

	ld hl, $8112
	cp $28
	jr c, jr_004_6f13

	ld hl, $9d12
	cp $2e
	jr c, jr_004_6f13

	ld hl, $b512
	jr jr_004_6f13

MaxLevelInto::
	cp $ff
	ret z

	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp b
	ret c

	ld b, a
	ret


jr_004_6f13:
	ld a, $02
	ld [wEncCount], a
	call RandomSpeciesInRange
	ld [wEncSpecies], a
	call RandomSpeciesInRange
	ld [$da05], a
	call RandomSpeciesInRange
	ld [$da07], a
	xor a
	ld [$da04], a
	ld [$da06], a
	ld [$da08], a
	ret


RandomSpeciesInRange::
	push hl
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, l
	call Divide8
	pop hl
	add h
	ret


	db $03, $04, $06, $0c, $15, $17, $18, $19, $1a, $1b, $1c, $25, $1a, $1b, $1c, $25
	db $0d, $0e, $0f, $10, $11, $12, $1e, $1f, $20, $21, $22, $23, $20, $21, $22, $23

ScriptCmdGivePrize::
	ld a, [wArenaPrize]
	ld l, a
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
	ld hl, wBagItems
	ld b, $14

jr_004_6f75:
	ld a, [hl]
	or a
	jr z, jr_004_6f82

	cp $ff
	jr z, jr_004_6f82

	inc hl
	dec b
	jr nz, jr_004_6f75

	ret


jr_004_6f82:
	ld a, [wArenaPrize]
	ld [hl], a
	jp NextScriptCommand


ScriptCmdStartShootingStars::
	ld a, $07
	ld [wStoryStep], a
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
	jp NextScriptCommand


ScriptCmdJumpIfLevelBelowCap::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call ReadScriptWord
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [wPartyCount]
	cp c
	jp z, NextScriptCommand

	jp c, NextScriptCommand

	ld a, c
	ld hl, wMonMaxLevel
	push bc
	call PartyMonsterField
	ld a, [hl]
	push hl
	ld hl, wTextArg1
	call ByteToDecimal
	pop hl
	pop bc
	push hl
	ld a, c
	ld [wScriptResult], a
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	pop hl
	ld a, [hld]
	dec a
	cp [hl]
	jp nc, NextScriptCommand

	call ReadScriptWord
	jp ScriptJumpTo


ScriptCmdPayPerLevel::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, [wLeaderSlot]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	inc a
	ld c, $0a
	call Multiply
	ld a, [wGold]
	sub l
	ld a, [$ca4c]
	sbc h
	ld a, [$ca4d]
	sbc $00
	jr nc, jr_004_7030

	call ReadScriptWord
	jp ScriptJumpTo


jr_004_7030:
	ld e, $00
	call SpendGold
	jp NextScriptCommand


ScriptCmdMapRoutine2::
	ld a, [wScriptMap]
	cp $06
	jr nc, jr_004_7044

	ld hl, far_DrawScriptAttrs_0C
	rst $10
	ret


jr_004_7044:
	cp $20
	jr nc, jr_004_704d

	ld hl, far_DrawScriptAttrs_0D
	rst $10
	ret


jr_004_704d:
	cp $40
	jr nc, jr_004_7056

	ld hl, far_DrawScriptAttrs_0E
	rst $10
	ret


jr_004_7056:
	ld hl, far_DrawScriptAttrs_0F
	rst $10
	ret


ScriptCmdBlankScreen::
	ld hl, $8da0
	ld b, $10
	ld a, $ff

jr_004_7062:
	call WriteVRAMInc
	dec b
	jr nz, jr_004_7062

	ld hl, $9800
	ld b, $00
	ld a, $da

jr_004_706f:
	call WriteVRAMInc
	call WriteVRAMInc
	call WriteVRAMInc
	call WriteVRAMInc
	dec b
	jr nz, jr_004_706f

	ret


ScriptCmdRedrawScreen::
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
	sla l
	rla
	ld h, $98
	add h
	ld h, a
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	and $1f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld de, wSavedTilemap
	ld c, $10

jr_004_70a1:
	ld b, $14
	push hl

jr_004_70a4:
	ld a, [de]
	call WriteVRAM
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	inc de
	dec b
	jr nz, jr_004_70a4

	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, jr_004_70a1

	ld hl, far_RefreshPartyGfx
	rst $10
	ret


ScriptCmdJumpIfPartyFit::
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, [wPartyCount]
	or a
	jp z, Jump_004_71c9

	ld a, $00
	ld hl, wMonStatus
	call GetPartyMonsterByte
	or a
	jp nz, Jump_004_71cf

	ld a, $00
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
	ld a, $00
	ld hl, wMonHP
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
	or l
	jp nz, Jump_004_71cf

	ld a, $00
	ld hl, wMonMaxMP
	call GetPartyMonsterWord
	push bc
	ld a, $00
	ld hl, wMonMP
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
	or l
	jp nz, Jump_004_71cf

	ld a, [wPartyCount]
	cp $01
	jp z, Jump_004_71c9

	ld a, $01
	ld hl, wMonStatus
	call GetPartyMonsterByte
	or a
	jp nz, Jump_004_71cf

	ld a, $01
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
	ld a, $01
	ld hl, wMonHP
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
	or l
	jr nz, jr_004_71cf

	ld a, $01
	ld hl, wMonMaxMP
	call GetPartyMonsterWord
	push bc
	ld a, $01
	ld hl, wMonMP
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
	or l
	jr nz, jr_004_71cf

	ld a, [wPartyCount]
	cp $02
	jr z, jr_004_71c9

	ld a, $02
	ld hl, wMonStatus
	call GetPartyMonsterByte
	or a
	jp nz, Jump_004_71cf

	ld a, $02
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
	ld a, $02
	ld hl, wMonHP
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
	or l
	jr nz, jr_004_71cf

	ld a, $02
	ld hl, wMonMaxMP
	call GetPartyMonsterWord
	push bc
	ld a, $02
	ld hl, wMonMP
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
	or l
	jr nz, jr_004_71cf

Jump_004_71c9:
jr_004_71c9:
	call ReadScriptWord
	jp ScriptJumpTo


Jump_004_71cf:
jr_004_71cf:
	jp NextScriptCommand


ScriptCmdWaitLink2::
	ld a, [wSoundChannels]
	ld hl, $dd9a
	and [hl]
	cp $ff
	jp z, NextScriptCommand

	ld a, [wScriptPos]
	sub $01
	ld [wScriptPos], a
	ld a, [$d8d6]
	sbc $00
	ld [$d8d6], a
	ret


ReadScriptWord::
	ld a, [wScriptMap]
	cp $06
	jr nc, jr_004_71fb

	ld hl, far_GetScriptWord_0C
	rst $10
	ret


jr_004_71fb:
	cp $20
	jr nc, jr_004_7204

	ld hl, far_GetScriptWord_0D
	rst $10
	ret


jr_004_7204:
	cp $40
	jr nc, jr_004_720d

	ld hl, far_GetScriptWord_0E
	rst $10
	ret


jr_004_720d:
	ld hl, far_GetScriptWord_0F
	rst $10
	ret


ScriptJumpTo::
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, b
	push af
	srl b
	rr c
	pop af
	and $80
	or b
	ld b, a
	ld a, [wScriptPos]
	ld l, a
	ld a, [$d8d6]
	ld h, a
	add hl, bc
	ld a, l
	ld [wScriptPos], a
	ld a, h
	ld [$d8d6], a
	jp RunScriptCommand


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
	db $80, $44, $77, $55, $77, $66, $77, $77, $77, $88, $77, $99, $77, $f0, $f8, $00
	db $00, $f0, $00, $01, $00, $f8, $f8, $02, $00, $f8, $00, $03, $00, $80, $f0, $f8
	db $00, $00, $f0, $00, $01, $00, $f8, $f8, $02, $00, $f8, $00, $03, $00, $80, $f0
	db $f8, $04, $00, $f0, $00, $05, $00, $f8, $f8, $06, $00, $f8, $00, $07, $00, $80
	db $f0, $f8, $04, $00, $f0, $00, $05, $00, $f8, $f8, $06, $00, $f8, $00, $07, $00
	db $80, $f0, $f8, $08, $00, $f0, $00, $09, $00, $f8, $f8, $0a, $00, $f8, $00, $0b
	db $00, $80, $f0, $f8, $08, $00, $f0, $00, $09, $00, $f8, $f8, $0a, $00, $f8, $00
	db $0b, $00, $80, $5b, $7f, $8e, $24, $00, $d0, $c9, $03, $13, $1f, $34, $25, $22
	db $25, $3f, $ff, $5b, $7f, $8e, $54, $20, $d0, $c9, $00, $12, $10, $30, $20, $20
	db $25, $3f, $8f, $23, $07, $06, $04, $00, $d0, $c9, $35, $1b, $41, $1e, $ae, $14
	db $1b, $00, $fc, $a7, $1b, $37, $71, $f1, $b3, $df, $06, $0a, $e6, $f4, $b6, $9f
	db $fd, $4f, $7e, $00, $75, $f5, $eb, $fb, $f5, $f5, $8b, $77, $40, $3f, $2f, $20
	db $2f, $3f, $20, $7f, $00, $ff, $ff, $00, $ff, $ff, $00, $ff, $00, $46, $51, $82
	db $00, $01, $46, $55, $99, $01, $5f, $f6, $de, $56, $7f, $d6, $5f, $f7, $ff, $f5
	db $f7, $fd, $f7, $fd, $ff, $f7, $e3, $b9, $eb, $a9, $fb, $e9, $a1, $eb, $7f, $83
	db $7f, $80, $80, $45, $9f, $83, $ff, $00, $00, $45, $ff, $83, $fe, $01, $01, $45
	db $f9, $45, $9f, $42, $80, $81, $7f, $45, $ff, $02, $81, $ff, $45, $f9, $42, $01
	db $81, $fe, $48, $9f, $48, $ff, $48, $f9, $83, $1f, $3f, $7f, $45, $ff, $83, $f8
	db $fc, $fe, $45, $ff, $48, $40, $48, $0a, $84, $43, $4c, $70, $c0, $04, $44, $0a
	db $84, $0b, $0c, $30, $c0, $04, $88, $03, $0c, $30, $c0, $03, $0c, $30, $c0, $04
	db $81, $3f, $47, $40, $81, $ff, $07, $81, $fc, $47, $02, $98, $00, $08, $08, $0c
	db $04, $06, $02, $03, $06, $0e, $02, $03, $03, $07, $02, $03, $0f, $02, $06, $04
	db $0c, $08, $18, $08, $18, $81, $3f, $47, $40, $81, $ff, $09, $83, $06, $08, $10
	db $43, $20, $84, $00, $08, $e4, $82, $44, $81, $48, $20, $48, $81, $05, $b5, $38
	db $24, $12, $00, $00, $03, $0f, $3c, $48, $90, $91, $00, $7f, $c4, $18, $20, $7c
	db $c4, $89, $00, $c0, $30, $0c, $3e, $c7, $81, $00, $11, $0a, $0c, $14, $24, $24
	db $22, $2f, $fe, $e4, $83, $04, $1c, $29, $e8, $70, $09, $10, $e3, $12, $0c, $c4
	db $a6, $82, $00, $80, $03, $42, $40, $be, $60, $13, $16, $1c, $14, $0f, $02, $3e
	db $57, $19, $2e, $28, $63, $ac, $90, $26, $cc, $83, $81, $81, $01, $3d, $43, $1f
	db $20, $38, $38, $3c, $1f, $1e, $1c, $b8, $f0, $54, $36, $4c, $46, $3a, $27, $1c
	db $00, $12, $22, $41, $81, $80, $00, $01, $02, $20, $18, $20, $20, $98, $90, $8f
	db $44, $40, $00, $03, $47, $7c, $41, $e0, $82, $c0, $e0, $06, $99, $03, $04, $04
	db $08, $09, $09, $05, $72, $8e, $80, $22, $ff, $c1, $c1, $80, $80, $c1, $c1, $30
	db $18, $98, $98, $b0, $a7, $78, $04, $85, $0f, $38, $48, $90, $93, $03, $85, $fe
	db $01, $3e, $e4, $88, $04, $8f, $c0, $30, $08, $06, $08, $10, $e1, $12, $0e, $c4
	db $a6, $82, $33, $4d, $c1, $05, $ba, $13, $16, $1c, $14, $0f, $02, $1e, $2b, $83
	db $83, $87, $0c, $3c, $58, $38, $70, $00, $80, $00, $01, $07, $1f, $0f, $0c, $7e
	db $81, $80, $60, $80, $e1, $43, $3e, $3f, $f0, $80, $00, $00, $80, $e0, $3f, $f8
	db $7c, $0c, $04, $00, $01, $3f, $fe, $18, $18, $30, $60, $e0, $c0, $c0, $e0, $01
	db $02, $43, $04, $8b, $3c, $26, $12, $f0, $1c, $2f, $47, $20, $20, $40, $41, $03
	db $92, $07, $19, $2b, $6a, $aa, $11, $0a, $0c, $34, $e4, $24, $22, $6f, $ad, $b7
	db $bf, $7e, $38, $03, $8e, $f3, $f6, $fc, $14, $0f, $02, $02, $03, $04, $06, $04
	db $02, $02, $01, $06, $b0, $18, $14, $12, $12, $00, $7f, $c4, $18, $38, $48, $88
	db $09, $11, $0a, $0c, $17, $2a, $28, $28, $2f, $fe, $e4, $83, $74, $a8, $89, $88
	db $70, $11, $0a, $0c, $17, $28, $2a, $28, $2f, $fe, $e4, $83, $74, $88, $a9, $88
	db $70, $17, $0a, $08, $18, $43, $28, $b7, $2f, $76, $ac, $8b, $8c, $88, $89, $88
	db $70, $13, $16, $1c, $14, $0f, $00, $79, $ae, $19, $2e, $2a, $4b, $cd, $61, $fa
	db $06, $a4, $64, $94, $8f, $7a, $47, $3c, $00, $05, $7d, $db, $4b, $94, $f4, $89
	db $72, $3f, $40, $5f, $5f, $50, $40, $5f, $3f, $ff, $00, $ff, $ff, $00, $00, $43
	db $ff, $46, $80, $42, $ff, $46, $0b, $99, $ff, $a8, $89, $a1, $a9, $a0, $a9, $a8
	db $88, $02, $0a, $08, $02, $0a, $02, $02, $0a, $5f, $4f, $1f, $5f, $4f, $5f, $5f
	db $1f, $ff, $85, $3f, $7f, $ff, $7f, $7f, $45, $ff, $ab, $fe, $ff, $fa, $fc, $e8
	db $f0, $c2, $e1, $e1, $c0, $80, $c0, $c0, $80, $8a, $84, $16, $8f, $a6, $17, $00
	db $21, $ff, $ff, $cf, $9f, $87, $0f, $0f, $07, $0f, $07, $43, $87, $11, $62, $88
	db $11, $e8, $f0, $fa, $fc, $fe, $43, $ff, $91, $f3, $ff, $fa, $f9, $58, $3c, $86
	db $0c, $c0, $e0, $80, $c0, $00, $80, $80, $00, $03, $07, $be, $40, $20, $00, $40
	db $00, $40, $80, $40, $00, $f8, $08, $06, $02, $01, $01, $00, $04, $88, $40, $84
	db $35, $72, $20, $7c, $00, $62, $00, $42, $54, $82, $60, $9c, $40, $82, $10, $60
	db $04, $18, $02, $04, $11, $62, $42, $81, $00, $c1, $00, $21, $00, $00, $02, $01
	db $08, $07, $05, $19, $23, $01, $03, $03, $07, $03, $41, $03, $be, $07, $42, $3c
	db $28, $f0, $f4, $f8, $e8, $f4, $c2, $e4, $85, $c2, $c8, $e7, $e3, $ff, $90, $60
	db $61, $00, $04, $03, $08, $04, $12, $0c, $c9, $3e, $34, $fb, $f8, $f0, $40, $21
	db $20, $c1, $82, $01, $41, $82, $04, $42, $4a, $84, $94, $08, $48, $30, $07, $07
	db $0f, $07, $07, $0f, $1f, $0f, $18, $0f, $10, $09, $02, $41, $10, $82, $20, $10
	db $48, $ff, $9b, $bf, $cf, $8f, $07, $03, $07, $07, $03, $f1, $e0, $e4, $e3, $ca
	db $e4, $e4, $c8, $88, $d0, $80, $d0, $88, $d0, $c4, $e8, $20, $c0, $80, $0d, $ff
	db $60, $01, $fd, $00, $ee, $30, $03, $07, $0f, $0c, $1b, $16, $ff, $36, $2d, $5d
	db $63, $7f, $c0, $ff, $81, $ff, $ff, $80, $fd, $83, $ef, $9f, $f1, $fb, $fd, $01
	db $08, $00, $00, $01, $1f, $1f, $1f, $11, $ff, $cd, $eb, $ad, $7f, $d3, $3b, $e8
	db $98, $ff, $e8, $18, $e8, $18, $c8, $38, $d0, $b8, $ff, $20, $f1, $c1, $e1, $f9
	db $7f, $e7, $bf, $fd, $a1, $fc, $30, $f9, $27, $fa, $17, $a4, $7e, $ff, $f8, $fc
	db $3f, $6f, $3c, $37, $34, $2f, $ff, $18, $3f, $10, $1f, $10, $1f, $15, $1f, $ff
	db $0d, $0f, $7d, $ff, $a7, $fb, $82, $ff, $fb, $fe, $fe, $ee, $31, $18, $3c, $38
	db $3c, $20, $ff, $f0, $fe, $ff, $36, $ff, $10, $f0, $10, $ff, $f0, $5e, $ff, $75
	db $ff, $61, $ff, $c3, $9f, $bf, $8c, $fe, $70, $f8, $ee, $31, $f0, $33, $1f, $f7
	db $10, $37, $2e, $fa, $3f, $00, $01, $00, $00, $ff, $3e, $3e, $fe, $e2, $ba, $76
	db $da, $3e, $fb, $ee, $1e, $18, $01, $c8, $38, $d1, $b9, $21, $cf, $f3, $c3, $e3
	db $fa, $27, $0f, $39, $06, $75, $ff, $ff, $ad, $ff, $85, $ff, $63, $ff, $1c, $3d
	db $fe, $ee, $31, $30, $30, $30, $70, $60, $60, $4c, $df, $ee, $fc, $fe, $30, $f8
	db $5c, $01, $50, $f0, $ff, $70, $f0, $60, $e0, $fe, $ff, $c5, $bf, $ff, $81, $ff
	db $ff, $ff, $00, $00, $10, $78, $ff, $68, $98, $f8, $0c, $f7, $0f, $f0, $0f, $ff
	db $60, $9f, $62, $9d, $26, $d9, $56, $7b, $ff, $36, $7b, $0a, $1d, $1d, $13, $1b
	db $14, $bf, $0d, $1e, $0b, $0f, $0f, $1f, $3f, $00, $13, $ff, $17, $1a, $1b, $1e
	db $17, $1f, $14, $1c, $b3, $18, $1c, $6c, $03, $1e, $17, $e0, $f0, $5d, $00, $90
	db $3f, $dc, $bc, $a4, $fc, $f8, $fc, $1e, $1d, $ee, $31, $00, $02, $bd, $00, $ee
	db $38, $04, $03, $03, $04, $ee, $33, $80, $f7, $60, $40, $a0, $06, $01, $42, $bc
	db $02, $05, $ef, $03, $04, $04, $03, $ee, $37, $7d, $82, $46, $ff, $b9, $2b, $c4
	db $05, $02, $00, $01, $20, $ff, $18, $11, $28, $56, $29, $5c, $24, $8c, $ff, $74
	db $00, $88, $20, $84, $00, $a2, $40, $ff, $99, $28, $c4, $80, $3c, $30, $52, $30
	db $ff, $12, $28, $07, $04, $38, $ab, $44, $40, $ff, $83, $04, $00, $02, $01, $4e
	db $20, $04, $ff, $40, $04, $40, $8e, $4a, $0e, $ca, $a4, $9f, $40, $44, $3b, $0a
	db $24, $ee, $39, $69, $0f, $00, $ff, $00, $50, $20, $20, $10, $20, $10, $28, $ff
	db $10, $21, $1e, $10, $61, $40, $80, $08, $df, $00, $01, $88, $02, $08, $90, $05
	db $01, $08, $5f, $09, $04, $83, $00, $44, $9f, $00, $28, $a3, $01, $ff, $6c, $28
	db $6c, $39, $00, $88, $04, $48, $fe, $af, $04, $50, $0c, $94, $08, $20, $18, $00
	db $bf, $00, $81, $00, $00, $ff, $80, $ee, $30, $03, $fd, $00, $fd, $31, $88, $64
	db $40, $94, $80, $34, $ff, $10, $64, $48, $24, $84, $08, $58, $04, $ff, $08, $04
	db $86, $70, $00, $70, $04, $22, $ff, $00, $1c, $00, $00, $42, $81, $00, $fe, $ff
	db $00, $ff, $04, $03, $0b, $04, $07, $08, $ff, $17, $08, $0c, $13, $2f, $10, $1f
	db $20, $ff, $1f, $20, $90, $60, $e0, $10, $90, $60, $ff, $e8, $10, $f4, $08, $78
	db $84, $7a, $84, $6f, $7c, $82, $5f, $20, $30, $0b, $bc, $42, $40, $0b, $ff, $5f
	db $20, $3f, $40, $3f, $40, $bf, $40, $fe, $56, $05, $d0, $20, $e0, $10, $e0, $10
	db $e8, $56, $85, $0f, $08, $03, $99, $0c, $ab, $a9, $0c, $d0, $b9, $02, $fe, $0e
	db $1b, $90, $24, $02, $34, $61, $1a, $62, $ff, $19, $18, $25, $41, $24, $a4, $42
	db $24, $ff, $c2, $90, $27, $09, $06, $04, $18, $10, $fb, $f8, $f0, $a3, $10, $74
	db $f8, $f8, $7c, $78, $ff, $3c, $84, $59, $01, $23, $03, $1f, $17, $ff, $c7, $4f
	db $2f, $06, $2f, $26, $16, $20, $ff, $16, $31, $c0, $c2, $81, $88, $86, $80, $ff
	db $38, $20, $40, $10, $60, $68, $90, $74, $ff, $88, $80, $79, $71, $8e, $fe, $01
	db $7c, $ff, $83, $9c, $63, $24, $1b, $10, $0f, $5a, $fd, $a4, $de, $01, $00, $20
	db $08, $10, $10, $18, $3f, $5a, $99, $18, $da, $18, $db, $80, $00, $ff, $3f, $7f
	db $5f, $e0, $bf, $c0, $e6, $99, $7f, $bb, $ff, $ee, $ff, $44, $ee, $00, $fc, $31
	db $ff, $01, $00, $01, $01, $03, $03, $06, $07, $ff, $05, $06, $07, $00, $00, $ff
	db $ff, $ff, $ef, $00, $ff, $00, $66, $f5, $32, $c4, $ff, $9c, $ff, $e3, $9e, $f9
	db $b6, $cd, $9e, $e7, $5e, $ff, $e7, $ee, $f1, $b6, $f9, $1c, $3f, $07, $ff, $0f
	db $38, $7c, $54, $ee, $ba, $c6, $ba, $ff, $c6, $92, $ee, $c6, $fe, $7c, $fe, $38
	db $f9, $7c, $fc, $32, $3e, $08, $42, $3c, $bd, $42, $5b, $ff, $bd, $77, $ad, $6d
	db $b7, $37, $cf, $df, $07, $7e, $7e, $3c, $3e, $0d, $00, $9a, $05, $83, $2c, $2d
	db $2e, $11, $8b, $32, $33, $00, $32, $33, $00, $00, $20, $21, $21, $22, $05, $88
	db $2c, $2d, $2e, $00, $00, $28, $29, $2a, $05, $8e, $2c, $2d, $2e, $30, $31, $00
	db $30, $31, $00, $00, $25, $26, $00, $27, $08, $8a, $20, $21, $25, $26, $27, $00
	db $00, $20, $21, $22, $03, $be, $32, $33, $00, $32, $33, $00, $00, $25, $00, $28
	db $29, $2a, $6d, $6e, $6f, $70, $6d, $6e, $6f, $25, $26, $25, $28, $29, $2a, $6e
	db $25, $26, $27, $6d, $6e, $6f, $30, $31, $6e, $30, $31, $6f, $70, $23, $00, $25
	db $26, $27, $71, $72, $73, $74, $71, $72, $73, $25, $26, $23, $23, $26, $27, $72
	db $23, $26, $27, $71, $41, $72, $8d, $73, $32, $33, $72, $32, $33, $73, $74, $25
	db $00, $25, $00, $27, $07, $8a, $23, $28, $29, $2a, $00, $27, $00, $25, $00, $24
	db $03, $8c, $30, $31, $00, $30, $31, $00, $00, $23, $00, $23, $00, $24, $07, $8a
	db $23, $25, $26, $00, $00, $24, $00, $23, $00, $27, $03, $85, $32, $33, $00, $32
	db $33, $04, $81, $23, $0a, $81, $23, $05, $81, $23, $05, $85, $34, $2f, $00, $34
	db $2f, $02, $ff, $00, $9a, $23, $83, $64, $65, $66, $03, $8a, $64, $65, $66, $00
	db $64, $65, $66, $00, $00, $62, $06, $8a, $64, $65, $66, $00, $5e, $5f, $00, $00
	db $64, $65, $43, $3d, $83, $66, $64, $65, $43, $3d, $81, $65, $43, $3d, $b0, $65
	db $66, $67, $00, $64, $65, $66, $64, $65, $3d, $3d, $68, $00, $60, $61, $00, $58
	db $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58
	db $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $7f
	db $e0, $9b, $60, $3d, $ff, $3e, $c7, $ea, $90, $c9, $cd, $92, $13, $3e, $03, $ea
	db $a6, $c9, $af, $ea, $8b, $c9, $ea, $8c, $c9, $ea, $88, $c9, $ea, $a1, $c9, $ea
	db $c7, $dd, $ea, $c8, $dd, $ea, $9a, $c9, $ea, $a4, $c9, $ea, $a7, $c9, $c3, $e6
	db $15, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $04
