INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $002", ROMX[$4000], BANK[$2]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_02::
	db $02

;@ path: system/banks
;@ Entry points of bank 2 for far calls (rst $10 with far_ constants).
FarTable_02::
	dw StepAnimation
	dw InitCutscene
	dw RunCutscene
	dw RunShootingStarEvent
	dw SceneSpriteSets + 12              ; the code after the table: UpdateSceneObject via wSceneStep/wSceneTimer
	dw GetAnimationFirstPose

;@ def StepAnimation()
;@ path: gfx/animation
;@ Advances the animation object that wPlayerAnimPtr points to by one frame. The object is 6 bytes:
;@ [0] running (0 = start the script over), [1] animation set, [2] animation in the set, [3] script
;@ step, [4] pose shown now, [5] frames left for it. The scripts are in AnimationSets.
StepAnimation::
;> obj = wPlayerAnimPtr
	ld a, [wPlayerAnimPtr]
	ld l, a
	ld a, [wPlayerAnimPtr + 1]
	ld h, a
;> if mem[obj] != 0:
	ld a, [hl]
	or a
	jr z, .start

;>     AdvanceAnimation()
	call AdvanceAnimation
;>     return
	jr .done

;> mem[obj] = 1                       # running
.start
	inc [hl]
;> mem[obj + 3] = 0                   # back to the first script entry
	inc hl
	inc hl
	inc hl
	ld [hl], $00
;> LoadAnimationFrame()
	call LoadAnimationFrame

.done
	ret


;@ def AdvanceAnimation()
;@ path: gfx/animation
;@ Counts down the frames of the current pose; when none are left it moves on to the next script
;@ entry. A pose given $FF frames is held forever. While counting, it returns with the Z flag set
;@ if the pose is $FF (nothing shown).
AdvanceAnimation::
;> left = wPlayerAnimPtr + 5
	ld a, [wPlayerAnimPtr]
	add $05
	ld l, a
	ld a, [wPlayerAnimPtr + 1]
	adc $00
	ld h, a
;> if mem[left] == 0xFF:
	ld a, [hl]
	cp $ff
;>     return                          # held forever
	ret z

;> if mem[left] != 0:
	or a
	jr z, AnimationNextFrame

;>     mem[left] -= 1
	dec a
	ld [hld], a
;>     return                          # Z flag: pose mem[left - 1] is $FF
	ld a, [hl]
	cp $ff
	ret

;> AnimationNextFrame()                 # falls through


;@ def AnimationNextFrame()
;@ path: gfx/animation
;@ Moves the animation object to its next script entry and loads it.
AnimationNextFrame::
;> step = wPlayerAnimPtr + 3
	ld a, [wPlayerAnimPtr]
	add $03
	ld l, a
	ld a, [wPlayerAnimPtr + 1]
	adc $00
	ld h, a
;> mem[step] += 1
	inc [hl]

;> LoadAnimationFrame()                 # falls through

;@ def LoadAnimationFrame()
;@ path: gfx/animation
;@ Reads the script entry at the object's step and acts on it. Entries are 2 bytes: a pose and its
;@ number of frames. $FF $FF starts the script over on the next frame, $FD n plays sound effect n
;@ and goes on with the next entry, $FE n is command n (0 stop, 1-3 skip, 4 restart).
LoadAnimationFrame::
;> entry = GetAnimationEntry()          # low byte pose, high byte frames
	call GetAnimationEntry
;> if entry == 0xFFFF:
	ld a, b
	and c
	cp $ff
	jr nz, .entry

;>     mem[wPlayerAnimPtr] = 0          # start over next frame
	ld a, [wPlayerAnimPtr]
	ld l, a
	ld a, [wPlayerAnimPtr + 1]
	ld h, a
	ld [hl], $00
;>     return
	ret

;> pass                                 # a leftover test of pose $FF that changes nothing
.entry
	ld a, c
	cp $ff
	jr nz, .notFF

.notFF
;> if entry & 0xFF >= 0xF8:
	ld a, c
	cp $f8
	jr c, AnimationSetFrame

;>     if entry & 0xFF != 0xFE:
	cp $fe
;>         return AnimationCheckSound(entry & 0xFF, entry)
	jr nz, AnimationCheckSound

;>     return AnimationCommandTable[entry >> 8]()
	ld a, b
	rst $00

;> return AnimationSetFrame(entry)

;@ path: gfx/animation
;@ Handlers of the animation script commands $FE $00-$04.
AnimationCommandTable::
	dw AnimationCmdStop
	dw AnimationCmdSkip
	dw AnimationCmdSkip
	dw AnimationCmdSkip
	dw AnimationCmdRestart

;@ def AnimationCheckSound(pose: a, entry: bc)
;@ path: gfx/animation
;@ Part of LoadAnimationFrame for poses $F8-$FD and $FF: $FD n plays sound effect n and goes on
;@ with the next entry; the others are shown like a pose.
AnimationCheckSound::
;> if pose != 0xFD:
	cp $fd
;>     return AnimationSetFrame(entry)
	jr nz, AnimationSetFrame

;> QueueSound(entry >> 8)
	ld a, b
	call QueueSound
;> AnimationNextFrame()
	jr AnimationNextFrame

;@ def AnimationSetFrame(entry: bc)
;@ path: gfx/animation
;@ Shows pose c for b frames: stores them in the animation object.
AnimationSetFrame::
;> p = wPlayerAnimPtr + 4
	ld a, [wPlayerAnimPtr]
	add $04
	ld l, a
	ld a, [wPlayerAnimPtr + 1]
	adc $00
	ld h, a
;> mem[p] = entry & 0xFF               # pose
	ld a, c
	ld [hli], a
;> mem[p + 1] = entry >> 8              # frames
	ld [hl], b

AnimationReturn:
	ret


;@ def AnimationCmdStop()
;@ path: gfx/animation
;@ Script command $FE $00: shows no pose ($FF) and holds that forever.
AnimationCmdStop::
;> AnimationSetFrame(0xFFFF)
	ld bc, $ffff
	jp AnimationSetFrame


;@ def AnimationCmdSkip()
;@ path: gfx/animation
;@ Script commands $FE $01-$03: ignored, the next entry is loaded.
AnimationCmdSkip::
;> AnimationNextFrame()
	jp AnimationNextFrame


;@ def AnimationCmdRestart()
;@ path: gfx/animation
;@ Script command $FE $04: sets the step back to 1 and adds a frame to wait; the entry after
;@ step 1 is the next one loaded.
AnimationCmdRestart::
;> p = wPlayerAnimPtr + 3
	ld a, [wPlayerAnimPtr]
	add $03
	ld l, a
	ld a, [wPlayerAnimPtr + 1]
	adc $00
	ld h, a
;> mem[p] = 1
	ld a, $01
	ld [hli], a
;> mem[p + 2] += 1
	inc hl
	inc [hl]
	jp AnimationReturn


;@ def GetAnimationEntry() -> bc
;@ path: gfx/animation
;@ Looks up the current script entry of the animation object: AnimationSets[set] is a list of
;@ animations, each a list of 2-byte entries; returns entry `step` (c = pose, b = frames).
GetAnimationEntry::
;> obj = wPlayerAnimPtr
	ld a, [wPlayerAnimPtr]
	ld c, a
	ld a, [wPlayerAnimPtr + 1]
	ld b, a
;> p = AnimationSets + (2 * mem[obj + 1] & 0xFF)
	inc bc
	ld a, [bc]
	add a
	ld hl, AnimationSets
	add l
	ld l, a
;> animations = mem16[p]
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> p = animations + (2 * mem[obj + 2] & 0xFF)
	inc bc
	ld a, [bc]
	add a
	add l
	ld l, a
;> script = mem16[p]
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> step = mem[obj + 3]
	inc bc
	ld a, [bc]
;> p = script + (2 * step & 0xFF)
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> return mem16[p]                     # c = pose, b = frames
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret


;@ path: gfx/animation
;@ Animation scripts for StepAnimation (the player's and other field characters' animations).
;@ A table of 97 pointers (one per animation set) to lists of animation pointers; each animation
;@ is a list of 2-byte entries: pose, frames to show it. Special entries: $FF $FF starts over,
;@ $FD n plays sound effect n, $FE n is a command (0 stop and hide, 1-3 skip, 4 restart). The
;@ lists and scripts follow the table, shared where sets are alike; set 96 ($46A1) has 45
;@ animations that play sounds.
AnimationSets::
	db $a5, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41
	db $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41
	db $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41
	db $3d, $42, $a5, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $65, $42
	db $f1, $41, $f1, $41, $a9, $42, $cd, $42, $f1, $42, $15, $43, $33, $43, $57, $43
	db $7b, $43, $a7, $43, $cb, $43, $ed, $43, $11, $44, $35, $44, $59, $44, $7d, $44
	db $a1, $44, $c5, $44, $e9, $44, $0d, $45, $45, $45, $69, $45, $a7, $45, $f1, $41
	db $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41
	db $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41
	db $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $cf, $45, $a5, $41, $a5, $41
	db $ef, $45, $ef, $45, $0f, $46, $ef, $45, $33, $46, $67, $46, $f1, $41, $ef, $45
	db $a5, $41, $a5, $41, $a5, $41, $a5, $41, $a5, $41, $a5, $41, $a5, $41, $ef, $45
	db $a1, $46, $bf, $41, $c5, $41, $cb, $41, $d1, $41, $d7, $41, $dd, $41, $e3, $41
	db $e7, $41, $eb, $41, $ef, $41, $ef, $41, $ef, $41, $ef, $41, $00, $20, $01, $20
	db $ff, $ff, $02, $20, $03, $20, $ff, $ff, $04, $20, $05, $20, $ff, $ff, $01, $0b
	db $00, $0b, $ff, $ff, $03, $0b, $02, $0b, $ff, $ff, $05, $0b, $04, $0b, $ff, $ff
	db $00, $ff, $ff, $ff, $02, $ff, $ff, $ff, $04, $ff, $ff, $ff, $ff, $ff, $0b, $42
	db $11, $42, $17, $42, $1d, $42, $23, $42, $29, $42, $2f, $42, $33, $42, $37, $42
	db $3b, $42, $3b, $42, $3b, $42, $3b, $42, $01, $20, $00, $20, $ff, $ff, $03, $20
	db $02, $20, $ff, $ff, $05, $20, $04, $20, $ff, $ff, $01, $0b, $00, $0b, $ff, $ff
	db $03, $0b, $02, $0b, $ff, $ff, $05, $0b, $04, $0b, $ff, $ff, $00, $ff, $ff, $ff
	db $02, $ff, $ff, $ff, $04, $ff, $ff, $ff, $ff, $ff, $57, $42, $57, $42, $57, $42
	db $57, $42, $57, $42, $57, $42, $5f, $42, $5f, $42, $5f, $42, $63, $42, $63, $42
	db $63, $42, $63, $42, $00, $0a, $01, $0a, $02, $0a, $ff, $ff, $00, $0a, $ff, $ff
	db $ff, $ff, $7f, $42, $7f, $42, $7f, $42, $85, $42, $8f, $42, $99, $42, $a1, $42
	db $a1, $42, $a1, $42, $a7, $42, $a7, $42, $a7, $42, $a7, $42, $00, $0e, $01, $0e
	db $ff, $ff, $00, $0e, $01, $0b, $02, $80, $01, $0a, $ff, $ff, $00, $0e, $01, $0b
	db $03, $80, $01, $0a, $ff, $ff, $01, $04, $00, $0e, $04, $80, $ff, $ff, $00, $0e
	db $01, $0e, $ff, $ff, $ff, $ff, $c3, $42, $c3, $42, $c3, $42, $c3, $42, $c3, $42
	db $c3, $42, $c3, $42, $c3, $42, $c3, $42, $c3, $42, $c3, $42, $c3, $42, $c3, $42
	db $00, $08, $01, $0e, $00, $08, $02, $0e, $ff, $ff, $e7, $42, $e7, $42, $e7, $42
	db $e7, $42, $e7, $42, $e7, $42, $e7, $42, $e7, $42, $e7, $42, $e7, $42, $e7, $42
	db $e7, $42, $e7, $42, $00, $08, $01, $0e, $02, $0d, $01, $0e, $ff, $ff, $0b, $43
	db $0b, $43, $0b, $43, $0b, $43, $0b, $43, $0b, $43, $0b, $43, $0b, $43, $0b, $43
	db $0b, $43, $0b, $43, $0b, $43, $0b, $43, $00, $0e, $01, $0e, $00, $0e, $02, $0e
	db $ff, $ff, $2f, $43, $2f, $43, $2f, $43, $2f, $43, $2f, $43, $2f, $43, $2f, $43
	db $2f, $43, $2f, $43, $2f, $43, $2f, $43, $2f, $43, $2f, $43, $00, $ff, $ff, $ff
	db $4d, $43, $4d, $43, $4d, $43, $4d, $43, $4d, $43, $4d, $43, $4d, $43, $4d, $43
	db $4d, $43, $4d, $43, $4d, $43, $4d, $43, $4d, $43, $00, $09, $01, $03, $02, $62
	db $01, $02, $ff, $ff, $71, $43, $71, $43, $71, $43, $71, $43, $71, $43, $71, $43
	db $71, $43, $71, $43, $71, $43, $71, $43, $71, $43, $71, $43, $71, $43, $00, $0e
	db $01, $0e, $00, $0e, $02, $0e, $ff, $ff, $95, $43, $95, $43, $95, $43, $95, $43
	db $95, $43, $95, $43, $95, $43, $95, $43, $95, $43, $95, $43, $95, $43, $95, $43
	db $95, $43, $00, $0e, $01, $0b, $02, $11, $03, $0b, $04, $0e, $03, $0b, $02, $11
	db $01, $0b, $ff, $ff, $c1, $43, $c1, $43, $c1, $43, $c1, $43, $c1, $43, $c1, $43
	db $c1, $43, $c1, $43, $c1, $43, $c1, $43, $c1, $43, $c1, $43, $c1, $43, $00, $0e
	db $01, $08, $02, $0c, $01, $08, $ff, $ff, $e5, $43, $e5, $43, $e5, $43, $e5, $43
	db $e5, $43, $e5, $43, $e5, $43, $e5, $43, $e5, $43, $e5, $43, $e5, $43, $e5, $43
	db $e5, $43, $00, $0a, $01, $0b, $02, $0c, $ff, $ff, $07, $44, $07, $44, $07, $44
	db $07, $44, $07, $44, $07, $44, $07, $44, $07, $44, $07, $44, $07, $44, $07, $44
	db $07, $44, $07, $44, $00, $06, $01, $06, $02, $06, $03, $06, $ff, $ff, $2b, $44
	db $2b, $44, $2b, $44, $2b, $44, $2b, $44, $2b, $44, $2b, $44, $2b, $44, $2b, $44
	db $2b, $44, $2b, $44, $2b, $44, $2b, $44, $00, $2c, $01, $0b, $02, $0d, $01, $0b
	db $ff, $ff, $4f, $44, $4f, $44, $4f, $44, $4f, $44, $4f, $44, $4f, $44, $4f, $44
	db $4f, $44, $4f, $44, $4f, $44, $4f, $44, $4f, $44, $4f, $44, $00, $0b, $01, $0b
	db $02, $0b, $01, $0b, $ff, $ff, $73, $44, $73, $44, $73, $44, $73, $44, $73, $44
	db $73, $44, $73, $44, $73, $44, $73, $44, $73, $44, $73, $44, $73, $44, $73, $44
	db $00, $0e, $01, $0e, $02, $0e, $01, $0e, $ff, $ff, $97, $44, $97, $44, $97, $44
	db $97, $44, $97, $44, $97, $44, $97, $44, $97, $44, $97, $44, $97, $44, $97, $44
	db $97, $44, $97, $44, $00, $0e, $01, $0e, $02, $0e, $01, $0e, $ff, $ff, $bb, $44
	db $bb, $44, $bb, $44, $bb, $44, $bb, $44, $bb, $44, $bb, $44, $bb, $44, $bb, $44
	db $bb, $44, $bb, $44, $bb, $44, $bb, $44, $00, $0e, $01, $0e, $02, $0e, $01, $0e
	db $ff, $ff, $df, $44, $df, $44, $df, $44, $df, $44, $df, $44, $df, $44, $df, $44
	db $df, $44, $df, $44, $df, $44, $df, $44, $df, $44, $df, $44, $00, $0e, $01, $0e
	db $00, $0e, $02, $0e, $ff, $ff, $03, $45, $03, $45, $03, $45, $03, $45, $03, $45
	db $03, $45, $03, $45, $03, $45, $03, $45, $03, $45, $03, $45, $03, $45, $03, $45
	db $00, $0e, $01, $0e, $00, $0e, $02, $0e, $ff, $ff, $27, $45, $27, $45, $27, $45
	db $27, $45, $27, $45, $27, $45, $27, $45, $27, $45, $27, $45, $27, $45, $27, $45
	db $27, $45, $27, $45, $00, $20, $01, $07, $02, $10, $00, $10, $03, $07, $04, $10
	db $00, $0e, $05, $0e, $00, $0e, $05, $0e, $00, $0e, $06, $0e, $00, $0e, $06, $0e
	db $ff, $ff, $5f, $45, $5f, $45, $5f, $45, $5f, $45, $5f, $45, $5f, $45, $5f, $45
	db $5f, $45, $5f, $45, $5f, $45, $5f, $45, $5f, $45, $5f, $45, $00, $0b, $01, $0b
	db $02, $0b, $01, $0b, $ff, $ff, $83, $45, $83, $45, $83, $45, $83, $45, $83, $45
	db $83, $45, $83, $45, $83, $45, $83, $45, $83, $45, $83, $45, $83, $45, $83, $45
	db $00, $0e, $03, $0a, $04, $0e, $05, $0a, $00, $0e, $03, $0a, $04, $0e, $05, $0a
	db $00, $10, $01, $0e, $02, $0e, $01, $0e, $02, $0e, $00, $20, $06, $0e, $07, $20
	db $06, $0e, $ff, $ff, $c1, $45, $c1, $45, $c1, $45, $c1, $45, $c1, $45, $c1, $45
	db $c1, $45, $c1, $45, $c1, $45, $c1, $45, $c1, $45, $c1, $45, $c1, $45, $00, $0c
	db $01, $0c, $02, $0c, $03, $0c, $04, $0c, $05, $0c, $ff, $ff, $e9, $45, $e9, $45
	db $e9, $45, $e9, $45, $e9, $45, $e9, $45, $e9, $45, $e9, $45, $e9, $45, $e9, $45
	db $e9, $45, $e9, $45, $e9, $45, $00, $1c, $ff, $1c, $ff, $ff, $09, $46, $09, $46
	db $09, $46, $09, $46, $09, $46, $09, $46, $09, $46, $09, $46, $09, $46, $0d, $46
	db $0d, $46, $0d, $46, $0d, $46, $00, $ff, $ff, $ff, $ff, $ff, $29, $46, $29, $46
	db $29, $46, $29, $46, $29, $46, $29, $46, $29, $46, $29, $46, $29, $46, $31, $46
	db $31, $46, $31, $46, $31, $46, $00, $08, $01, $08, $02, $0a, $ff, $ff, $ff, $ff
	db $4d, $46, $4d, $46, $4d, $46, $4d, $46, $4d, $46, $4d, $46, $4d, $46, $4d, $46
	db $4d, $46, $65, $46, $65, $46, $65, $46, $65, $46, $00, $0a, $01, $0a, $02, $0a
	db $03, $0a, $04, $0a, $05, $0a, $06, $0a, $07, $0a, $08, $0a, $09, $0a, $fe, $00
	db $ff, $ff, $ff, $ff, $81, $46, $81, $46, $81, $46, $81, $46, $81, $46, $81, $46
	db $85, $46, $85, $46, $85, $46, $9f, $46, $9f, $46, $9f, $46, $9f, $46, $00, $ff
	db $ff, $ff, $00, $0e, $01, $0e, $02, $0e, $01, $0e, $02, $0e, $01, $0e, $02, $0e
	db $00, $36, $03, $0e, $04, $0e, $05, $0e, $06, $ff, $ff, $ff, $ff, $ff, $fb, $46
	db $11, $47, $47, $47, $7b, $47, $89, $47, $97, $47, $c7, $47, $df, $47, $05, $48
	db $47, $48, $67, $48, $7d, $48, $b9, $48, $e5, $48, $05, $49, $45, $49, $67, $49
	db $97, $49, $d9, $49, $f5, $49, $0b, $4a, $27, $4a, $41, $4a, $59, $4a, $6b, $4a
	db $81, $4a, $9f, $4a, $dd, $4a, $f3, $4a, $35, $4b, $47, $4b, $7f, $4b, $bb, $4b
	db $f7, $4b, $2f, $4c, $41, $4c, $55, $4c, $85, $4c, $b7, $4c, $f7, $4c, $37, $4d
	db $5d, $4d, $9d, $4d, $df, $4d, $ff, $4d, $00, $05, $fd, $74, $01, $05, $02, $05
	db $03, $05, $04, $02, $05, $02, $06, $02, $07, $02, $1f, $02, $ff, $ff, $00, $04
	db $fd, $76, $01, $04, $02, $04, $03, $04, $04, $02, $05, $02, $06, $02, $07, $02
	db $1f, $08, $08, $03, $09, $03, $0a, $03, $0b, $03, $0c, $03, $09, $03, $0a, $03
	db $0b, $03, $0c, $03, $09, $02, $0a, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02
	db $1f, $02, $ff, $ff, $08, $02, $fd, $76, $09, $05, $0a, $05, $0b, $05, $0c, $02
	db $0d, $02, $0e, $02, $0f, $02, $1f, $08, $00, $01, $01, $01, $02, $01, $03, $01
	db $04, $03, $05, $03, $06, $03, $07, $03, $04, $03, $05, $03, $06, $03, $07, $03
	db $02, $02, $00, $02, $1f, $02, $ff, $ff, $00, $03, $fd, $78, $01, $03, $02, $03
	db $fe, $04, $1f, $02, $ff, $ff, $00, $02, $fd, $78, $01, $02, $02, $02, $fe, $04
	db $1f, $02, $ff, $ff, $00, $04, $fd, $7a, $01, $03, $02, $02, $03, $04, $04, $05
	db $05, $03, $06, $04, $07, $03, $08, $04, $04, $04, $05, $03, $06, $04, $07, $03
	db $08, $04, $04, $03, $05, $04, $06, $03, $07, $04, $08, $03, $09, $02, $0a, $03
	db $1f, $02, $ff, $ff, $00, $04, $fd, $7b, $01, $02, $02, $04, $03, $04, $04, $02
	db $00, $02, $01, $02, $02, $02, $01, $02, $1f, $02, $ff, $ff, $00, $02, $01, $02
	db $02, $02, $1f, $10, $03, $04, $fd, $7b, $04, $02, $05, $04, $06, $02, $07, $04
	db $08, $02, $03, $03, $04, $02, $05, $03, $06, $02, $07, $04, $08, $02, $1f, $02
	db $ff, $ff, $00, $02, $fd, $7c, $01, $02, $02, $02, $03, $02, $1f, $10, $04, $05
	db $fd, $7b, $05, $05, $06, $05, $07, $02, $08, $02, $0e, $02, $09, $02, $0f, $02
	db $0a, $02, $10, $02, $0b, $02, $11, $02, $0c, $02, $12, $02, $0d, $02, $13, $02
	db $08, $02, $0e, $02, $09, $02, $0f, $02, $0a, $02, $10, $02, $0b, $02, $06, $02
	db $1f, $02, $ff, $ff, $00, $02, $fd, $7e, $01, $02, $02, $02, $03, $02, $04, $02
	db $05, $02, $06, $02, $07, $02, $08, $02, $09, $02, $0a, $02, $0b, $02, $0c, $02
	db $1f, $02, $ff, $ff, $04, $05, $fd, $7e, $05, $04, $06, $05, $07, $06, $08, $05
	db $09, $04, $0a, $05, $04, $05, $1f, $02, $ff, $ff, $00, $03, $fd, $7f, $01, $03
	db $02, $03, $03, $03, $04, $03, $05, $03, $06, $03, $07, $03, $08, $03, $09, $03
	db $0a, $03, $0b, $03, $0c, $03, $0d, $03, $0e, $03, $0f, $03, $10, $03, $11, $03
	db $12, $03, $13, $03, $14, $03, $15, $03, $16, $03, $17, $03, $18, $03, $19, $03
	db $1a, $03, $1f, $02, $ff, $ff, $00, $03, $fd, $80, $01, $03, $02, $03, $03, $03
	db $04, $03, $05, $03, $06, $03, $07, $03, $08, $03, $09, $03, $0a, $03, $0b, $03
	db $0c, $03, $0d, $03, $0e, $03, $0f, $03, $10, $03, $11, $03, $12, $03, $1f, $02
	db $ff, $ff, $00, $05, $fd, $80, $01, $04, $02, $04, $03, $03, $04, $02, $03, $02
	db $04, $03, $03, $03, $04, $0f, $1f, $03, $04, $03, $1f, $03, $04, $02, $1f, $02
	db $ff, $ff, $06, $03, $fd, $81, $07, $03, $08, $02, $09, $02, $0a, $01, $0b, $01
	db $0c, $01, $1f, $08, $01, $02, $02, $02, $03, $02, $04, $02, $01, $02, $02, $02
	db $03, $02, $04, $02, $01, $02, $02, $02, $03, $02, $04, $02, $01, $02, $02, $02
	db $03, $02, $04, $02, $01, $02, $02, $02, $03, $02, $04, $02, $05, $01, $1f, $02
	db $ff, $ff, $00, $04, $fd, $82, $01, $03, $1f, $08, $02, $05, $03, $04, $04, $03
	db $05, $03, $06, $02, $07, $02, $04, $02, $05, $02, $06, $02, $07, $02, $02, $02
	db $1f, $02, $ff, $ff, $00, $04, $fd, $82, $01, $03, $02, $02, $1f, $08, $03, $05
	db $04, $04, $05, $03, $06, $03, $07, $02, $08, $02, $09, $02, $05, $02, $06, $02
	db $07, $02, $08, $02, $09, $02, $06, $02, $07, $02, $08, $02, $09, $02, $04, $01
	db $1f, $02, $ff, $ff, $00, $03, $fd, $83, $01, $03, $02, $02, $03, $03, $02, $01
	db $0f, $01, $04, $03, $05, $03, $06, $03, $07, $02, $08, $02, $09, $02, $0a, $01
	db $0b, $01, $0c, $01, $0d, $01, $06, $03, $07, $02, $0a, $01, $0b, $01, $0c, $01
	db $0d, $01, $08, $03, $09, $02, $0a, $01, $0b, $01, $0c, $01, $0d, $01, $0e, $01
	db $04, $02, $1f, $02, $ff, $ff, $00, $04, $fd, $72, $01, $04, $02, $04, $03, $04
	db $04, $04, $05, $04, $06, $04, $07, $04, $08, $04, $09, $04, $0a, $04, $1f, $02
	db $ff, $ff, $00, $04, $fd, $71, $01, $03, $02, $04, $03, $03, $04, $02, $05, $01
	db $06, $01, $07, $01, $1f, $01, $ff, $ff, $00, $0a, $fd, $70, $01, $08, $02, $07
	db $03, $06, $04, $05, $05, $05, $06, $05, $07, $05, $08, $04, $09, $04, $0a, $04
	db $1f, $02, $ff, $ff, $00, $08, $fd, $73, $01, $06, $02, $08, $03, $06, $04, $08
	db $05, $08, $06, $08, $07, $08, $08, $04, $09, $04, $1f, $02, $ff, $ff, $00, $06
	db $fd, $73, $01, $06, $02, $06, $03, $06, $04, $08, $05, $08, $06, $04, $07, $04
	db $08, $04, $1f, $02, $ff, $ff, $00, $06, $fd, $84, $01, $06, $02, $06, $03, $06
	db $04, $06, $05, $06, $1f, $02, $ff, $ff, $00, $0a, $fd, $85, $01, $06, $02, $05
	db $03, $04, $04, $04, $05, $03, $06, $03, $07, $03, $1f, $02, $ff, $ff, $00, $04
	db $fd, $86, $1f, $04, $00, $04, $1f, $04, $00, $04, $1f, $04, $00, $04, $1f, $04
	db $00, $04, $1f, $04, $00, $04, $1f, $04, $1f, $02, $ff, $ff, $00, $03, $fd, $88
	db $01, $03, $02, $03, $1f, $08, $03, $02, $04, $02, $05, $02, $06, $02, $07, $02
	db $08, $02, $09, $02, $0a, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02, $0f, $02
	db $10, $02, $11, $02, $0a, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02, $0f, $02
	db $10, $02, $11, $02, $12, $02, $1f, $02, $ff, $ff, $00, $04, $fd, $89, $01, $04
	db $02, $04, $03, $04, $04, $05, $05, $04, $06, $04, $07, $04, $1f, $02, $ff, $ff
	db $00, $02, $fd, $8a, $01, $02, $02, $02, $03, $02, $04, $02, $05, $02, $06, $02
	db $07, $02, $08, $02, $09, $02, $0a, $02, $0b, $03, $0c, $05, $0d, $04, $0e, $03
	db $0f, $03, $0e, $04, $0d, $04, $0e, $03, $0b, $03, $13, $04, $0b, $04, $0c, $05
	db $0d, $04, $0e, $03, $0f, $04, $0e, $03, $10, $04, $11, $04, $12, $04, $1f, $02
	db $ff, $ff, $00, $03, $fd, $8c, $01, $04, $02, $04, $03, $03, $04, $05, $05, $03
	db $1f, $02, $ff, $ff, $00, $03, $fd, $8d, $01, $04, $02, $04, $03, $03, $00, $03
	db $01, $04, $02, $04, $03, $03, $04, $05, $05, $03, $06, $03, $1f, $08, $07, $03
	db $08, $02, $09, $04, $0a, $04, $0b, $04, $0c, $04, $0d, $04, $0e, $03, $0f, $03
	db $10, $03, $11, $03, $12, $03, $13, $03, $1f, $02, $ff, $ff, $00, $03, $fd, $8e
	db $01, $04, $02, $04, $03, $03, $04, $05, $05, $02, $06, $02, $07, $02, $08, $02
	db $09, $02, $0a, $03, $0b, $04, $0c, $03, $0d, $03, $0e, $02, $0f, $02, $10, $02
	db $0c, $02, $0d, $02, $0e, $02, $0f, $02, $10, $02, $0d, $02, $0e, $02, $0f, $02
	db $10, $02, $0a, $01, $1f, $02, $ff, $ff, $00, $03, $fd, $8f, $01, $04, $02, $04
	db $03, $03, $04, $05, $05, $03, $06, $03, $1f, $08, $07, $02, $08, $02, $09, $02
	db $0a, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02, $0f, $02, $10, $02, $11, $02
	db $12, $02, $13, $02, $14, $02, $15, $02, $16, $02, $17, $02, $18, $02, $19, $02
	db $1f, $02, $ff, $ff, $00, $03, $fd, $90, $01, $04, $02, $04, $03, $03, $04, $05
	db $05, $03, $06, $03, $1f, $08, $07, $05, $08, $04, $09, $03, $0a, $03, $0b, $03
	db $0a, $04, $0b, $08, $1f, $03, $0b, $02, $1f, $02, $0b, $01, $1f, $01, $0b, $01
	db $1f, $01, $0b, $01, $1f, $01, $0b, $01, $1f, $02, $ff, $ff, $00, $06, $fd, $92
	db $01, $05, $02, $05, $03, $03, $04, $04, $05, $03, $1f, $02, $ff, $ff, $00, $03
	db $fd, $93, $01, $04, $02, $04, $03, $03, $04, $05, $05, $03, $06, $02, $1f, $02
	db $ff, $ff, $00, $06, $fd, $93, $01, $05, $02, $05, $03, $05, $04, $03, $05, $03
	db $06, $08, $07, $03, $06, $03, $07, $03, $06, $03, $07, $02, $06, $02, $07, $02
	db $06, $02, $07, $01, $06, $01, $07, $01, $06, $01, $07, $01, $06, $01, $1f, $02
	db $ff, $ff, $00, $05, $fd, $8c, $01, $04, $02, $04, $03, $04, $04, $03, $05, $03
	db $06, $03, $05, $02, $07, $02, $08, $02, $07, $02, $1f, $02, $08, $02, $1f, $02
	db $07, $01, $1f, $01, $08, $01, $1f, $01, $07, $01, $1f, $01, $08, $01, $1f, $01
	db $1f, $02, $ff, $ff, $00, $04, $fd, $94, $01, $05, $02, $05, $03, $04, $04, $04
	db $05, $06, $06, $04, $07, $04, $08, $03, $07, $02, $08, $02, $06, $02, $08, $03
	db $09, $03, $08, $02, $09, $02, $08, $02, $09, $02, $0a, $02, $0b, $02, $0a, $01
	db $0b, $01, $0a, $01, $1f, $01, $0b, $01, $1f, $01, $0a, $01, $1f, $01, $0b, $01
	db $1f, $02, $ff, $ff, $00, $01, $fd, $95, $01, $01, $02, $01, $03, $02, $04, $03
	db $05, $03, $06, $03, $07, $03, $08, $03, $09, $03, $0a, $03, $0b, $02, $0c, $02
	db $0d, $02, $0b, $02, $0c, $02, $0d, $02, $0b, $02, $0c, $02, $0d, $02, $0b, $02
	db $0c, $02, $0d, $02, $0b, $02, $0c, $02, $0d, $02, $0b, $02, $0c, $02, $0d, $02
	db $1f, $02, $ff, $ff, $00, $03, $fd, $96, $1f, $01, $01, $03, $1f, $01, $02, $03
	db $1f, $01, $03, $03, $1f, $01, $04, $03, $05, $03, $04, $03, $05, $03, $04, $03
	db $05, $03, $04, $03, $05, $03, $1f, $02, $ff, $ff, $00, $04, $fd, $97, $01, $04
	db $00, $03, $01, $03, $02, $04, $01, $04, $02, $03, $01, $03, $03, $04, $02, $04
	db $03, $03, $02, $03, $04, $04, $03, $04, $04, $03, $03, $03, $05, $04, $04, $03
	db $06, $03, $05, $04, $07, $04, $10, $04, $0b, $04, $11, $04, $0c, $04, $12, $04
	db $0d, $04, $13, $04, $07, $03, $1f, $02, $ff, $ff, $00, $04, $fd, $99, $01, $05
	db $02, $04, $03, $03, $04, $03, $05, $03, $06, $03, $07, $03, $08, $03, $1f, $08
	db $09, $02, $0a, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02, $0f, $02, $10, $02
	db $11, $02, $12, $02, $13, $02, $14, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02
	db $0f, $02, $15, $02, $16, $02, $17, $02, $1f, $02, $ff, $ff, $00, $04, $fd, $9b
	db $01, $04, $02, $04, $03, $02, $04, $02, $05, $02, $06, $02, $07, $02, $08, $02
	db $05, $02, $06, $02, $07, $02, $08, $02, $1f, $02, $ff, $ff, $00, $04, $01, $03
	db $02, $06, $03, $06, $04, $06, $05, $06, $06, $06, $07, $06, $08, $06, $09, $06
	db $1f, $02, $ff, $ff

;@ path: gfx/animation
;@ Animation scripts of the cutscene objects (UpdateSceneObject, hSpriteSet picks the script).
;@ A table of 6 script pointers, then the scripts. Each entry is 2 bytes: pose (frame of the
;@ sprite set), frames to show it. A pose of $FE loops back to the first entry, $FF ends the
;@ script and hides the object. 0: star (2 poses), 1: sparkle fading out, 2-3: still poses,
;@ 4: a slow sequence of poses 2-5, 5: two poses looping.
SceneObjectScripts::
	dw .script0, .script1, .script2, .script3, .script4, .script5
.script0
	db $00, $02, $02, $01, $fe, $00
.script1
	db $00, $04, $06, $01, $00, $04, $06, $01, $01, $04
	db $06, $01, $01, $04, $06, $01, $02, $04, $06, $01, $02, $05, $06, $01, $03, $05
	db $06, $01, $03, $05, $06, $01, $04, $05, $06, $01, $04, $06, $06, $01, $05, $06
	db $06, $01, $05, $06, $06, $01, $ff, $ff
.script2
	db $00, $02, $06, $01, $fe, $00
.script3
	db $01, $02, $06, $01, $fe, $00
.script4
	db $02, $02, $06, $01, $02, $02, $06, $01, $02, $02, $06, $01
	db $03, $02, $06, $01, $03, $02, $06, $01, $03, $02, $06, $01, $04, $02, $06, $01
	db $04, $02, $06, $01, $04, $02, $06, $01, $05, $02, $06, $01, $05, $02, $06, $01
	db $05, $02, $06, $01, $ff, $ff
.script5
	db $01, $02, $02, $01, $fe, $00

;@ def InitCutscene()
;@ path: event/cutscene
;@ Game mode 3 start: sets up one of four cutscenes (wGameModeStep picks it) under a starry night
;@ sky, and starts song 2.
InitCutscene::
;> DisableSTATInterrupts()
	call DisableSTATInterrupts
;> wSGBPalSet = 0
	ld hl, wSGBPalSet
	ld [hl], $00
;> mem[wSGBPalSet + 1] = 0
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> QueueMusic(2)
	ld a, $02
	call QueueMusic
;> return InitCutsceneTable[wGameModeStep]()
	ld a, [wGameModeStep]
	rst $00

;@ path: event/cutscene
;@ Set-up routines of the four cutscenes of game mode 3.
InitCutsceneTable::
	dw InitCutscene0
	dw InitCutscene1
	dw InitCutscene2
	dw InitCutscene3

;@ def InitCutscene0()
;@ path: event/cutscene
;@ Cutscene 0: night sky over a hill, with people standing on it (sprites) and a second map in
;@ BG map 2 for the end. Loads the tiles, draws both maps (and on a Game Boy Color their
;@ attributes), and starts with the view scrolled $70 pixels down.
;@ test: skip loads graphics and turns the screen on
InitCutscene0::
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> Decompress(0x5B17, 0x9000)          # background tiles
	ld de, $5b17
	ld hl, $9000
	call Decompress
;> Decompress(0x5B18, 0x8600)          # sprite tiles
	ld de, $5b18
	ld hl, $8600
	call Decompress
;> Decompress(0x5B19, 0x8640)
	ld de, $5b19
	ld hl, $8640
	call Decompress
;> Decompress(0x5B1A, 0x8670)
	ld de, $5b1a
	ld hl, $8670
	call Decompress
;> Decompress(0x2F00, 0x8800)
	ld de, $2f00
	ld hl, $8800
	call Decompress
;> Decompress(0x310D, 0x8A00)
	ld de, $310d
	ld hl, $8a00
	call Decompress
;> Decompress(0x310E, 0x8B00)
	ld de, $310e
	ld hl, $8b00
	call Decompress
;> Decompress(0x3110, 0x8C00)
	ld de, $3110
	ld hl, $8c00
	call Decompress
;> DrawTilemap(Cutscene0SkyTilemap, 0x9800)
	ld de, Cutscene0SkyTilemap
	ld hl, $9800
	call DrawTilemap
;> DrawTilemap(Cutscene0GroundTilemap, 0x9C00)
	ld de, Cutscene0GroundTilemap
	ld hl, $9c00
	call DrawTilemap
;> fill(wSceneObjects, 0, 0x28)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> wPaletteSet = 2
	ld a, $02
	ld [wPaletteSet], a
;> LoadPaletteSet()                       # load the palette set
	ld hl, far_LoadPaletteSet
	rst $10
;> LoadFieldObjPalettes()
	ld hl, far_LoadFieldObjPalettes
	rst $10
;> rVBK = 1
	ld a, $01
	ldh [rVBK], a
;> if wOnCGB:
;>     Decompress(0x3F04, 0x9800)      # attribute maps
	ld de, $3f04
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
;> if wOnCGB:
;>     Decompress(0x3F04, 0x9C00)
	ld de, $3f04
	ld hl, $9c00
	ld a, [wOnCGB]
	or a
	call nz, Decompress
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0x70            # low byte only
	ld a, $70
	ldh [hScrollY], a
;> hWX = 0
	ld a, $00
	ldh [hWX], a
;> hWY = 0
	ld a, $00
	ldh [hWY], a
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
;> mem[0xC892] = 0
	xor a
	ld [wLCDEffect], a
;> wLCDC = 0x03                        # background and sprites
	ld a, $03
	ld [wLCDC], a
;> ApplyScroll()
	call ApplyScroll
;> ClearShadowOAM()
	call ClearShadowOAM
;> hOAMDMA()
	call hOAMDMA
;> return EnableLCDAndInterrupts(1)
	ld a, $01
	jp EnableLCDAndInterrupts


;@ def InitCutscene1()
;@ path: event/cutscene
;@ Cutscene 1: loads its tiles and Cutscene12Tilemap, makes the last tile of $8FF0 a solid
;@ pattern, blanks two rows of BG map 2, and starts scrolled $70 pixels down.
;@ test: skip loads graphics and turns the screen on
InitCutscene1::
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> Decompress(0x5B1B, 0x9000)
	ld de, $5b1b
	ld hl, $9000
	call Decompress
;> Decompress(0x5B1C, 0x8800)
	ld de, $5b1c
	ld hl, $8800
	call Decompress
;> FillWordPattern(0x8FF0, 8, 0xFF00)   # tile $FF: color 1 everywhere
	ld de, $ff00
	ld hl, $8ff0
	ld bc, $0008
	call FillWordPattern
;> DrawTilemap(Cutscene12Tilemap, 0x9800)
	ld de, Cutscene12Tilemap
	ld hl, $9800
	call DrawTilemap
;> fill(0x9C00, 0xFF, 0x40)
	ld a, $ff
	ld hl, $9c00
	ld bc, $0040
	call FillMemory
;> fill(wSceneObjects, 0, 0x28)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> wPaletteSet = 3
	ld a, $03
	ld [wPaletteSet], a
;> LoadPaletteSet()
	ld hl, far_LoadPaletteSet
	rst $10
;> rVBK = 1
	ld de, $3f06
	ld a, $01
	ldh [rVBK], a
;> if wOnCGB:
;>     Decompress(0x3F06, 0x9800)
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0x70            # low byte only
	ld a, $70
	ldh [hScrollY], a
;> hWX = 0
	ld a, $00
	ldh [hWX], a
;> hWY = 0
	ld a, $00
	ldh [hWY], a
;> wLCDC = 0x03
	ld a, $03
	ld [wLCDC], a
;> ApplyScroll()
	call ApplyScroll
;> ClearShadowOAM()
	call ClearShadowOAM
;> hOAMDMA()
	call hOAMDMA
;> mem[0xC892] = 0
	xor a
	ld [wLCDEffect], a
;> return EnableLCDAndInterrupts(1)
	ld a, $01
	jp EnableLCDAndInterrupts


;@ def InitCutscene2()
;@ path: event/cutscene
;@ Cutscene 2: like cutscene 1, but the window is placed at X 7, Y $80.
;@ test: skip loads graphics and turns the screen on
InitCutscene2::
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> Decompress(0x5B1B, 0x9000)
	ld de, $5b1b
	ld hl, $9000
	call Decompress
;> Decompress(0x5B1C, 0x8800)
	ld de, $5b1c
	ld hl, $8800
	call Decompress
;> FillWordPattern(0x8FF0, 8, 0xFF00)
	ld de, $ff00
	ld hl, $8ff0
	ld bc, $0008
	call FillWordPattern
;> DrawTilemap(Cutscene12Tilemap, 0x9800)
	ld de, Cutscene12Tilemap
	ld hl, $9800
	call DrawTilemap
;> fill(0x9C00, 0xFF, 0x40)
	ld a, $ff
	ld hl, $9c00
	ld bc, $0040
	call FillMemory
;> fill(wSceneObjects, 0, 0x28)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> wPaletteSet = 3
	ld a, $03
	ld [wPaletteSet], a
;> LoadPaletteSet()
	ld hl, far_LoadPaletteSet
	rst $10
;> rVBK = 1
	ld de, $3f06
	ld a, $01
	ldh [rVBK], a
;> if wOnCGB:
;>     Decompress(0x3F06, 0x9800)
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0x70            # low byte only
	ld a, $70
	ldh [hScrollY], a
;> hWX = 7
	ld a, $07
	ldh [hWX], a
;> hWY = 0x80
	ld a, $80
	ldh [hWY], a
;> wLCDC = 0x03
	ld a, $03
	ld [wLCDC], a
;> ApplyScroll()
	call ApplyScroll
;> ClearShadowOAM()
	call ClearShadowOAM
;> hOAMDMA()
	call hOAMDMA
;> mem[0xC892] = 0
	xor a
	ld [wLCDEffect], a
;> return EnableLCDAndInterrupts(1)
	ld a, $01
	jp EnableLCDAndInterrupts


;@ def InitCutscene3()
;@ path: event/cutscene
;@ Cutscene 3: like cutscene 2 with its own tiles, Cutscene3Tilemap and palette set 4.
;@ test: skip loads graphics and turns the screen on
InitCutscene3::
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> Decompress(0x5B1D, 0x9000)
	ld de, $5b1d
	ld hl, $9000
	call Decompress
;> Decompress(0x5B1E, 0x8800)
	ld de, $5b1e
	ld hl, $8800
	call Decompress
;> FillWordPattern(0x8FF0, 8, 0xFF00)
	ld de, $ff00
	ld hl, $8ff0
	ld bc, $0008
	call FillWordPattern
;> DrawTilemap(Cutscene3Tilemap, 0x9800)
	ld de, Cutscene3Tilemap
	ld hl, $9800
	call DrawTilemap
;> fill(0x9C00, 0xFF, 0x40)
	ld a, $ff
	ld hl, $9c00
	ld bc, $0040
	call FillMemory
;> fill(wSceneObjects, 0, 0x28)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> wPaletteSet = 4
	ld a, $04
	ld [wPaletteSet], a
;> LoadPaletteSet()
	ld hl, far_LoadPaletteSet
	rst $10
;> rVBK = 1
	ld de, $3f07
	ld a, $01
	ldh [rVBK], a
;> if wOnCGB:
;>     Decompress(0x3F07, 0x9800)
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0x70            # low byte only
	ld a, $70
	ldh [hScrollY], a
;> hWX = 7
	ld a, $07
	ldh [hWX], a
;> hWY = 0x80
	ld a, $80
	ldh [hWY], a
;> wLCDC = 0x03
	ld a, $03
	ld [wLCDC], a
;> ApplyScroll()
	call ApplyScroll
;> ClearShadowOAM()
	call ClearShadowOAM
;> hOAMDMA()
	call hOAMDMA
;> mem[0xC892] = 0
	xor a
	ld [wLCDEffect], a
;> return EnableLCDAndInterrupts(1)
	ld a, $01
	jp EnableLCDAndInterrupts


;@ def RunCutscene()
;@ path: event/cutscene
;@ Game mode 3, every frame: runs the cutscene that wGameModeStep picks.
RunCutscene::
;> return RunCutsceneTable[wGameModeStep]()
	ld a, [wGameModeStep]
	rst $00

;@ path: event/cutscene
;@ Per-frame routines of the four cutscenes of game mode 3.
RunCutsceneTable::
	dw RunCutscene0
	dw RunCutscene1
	dw RunCutscene2
	dw RunCutscene3

;@ def RunCutscene0()
;@ path: event/cutscene
;@ Cutscene 0, every frame: lets the stars twinkle, draws the people while the view is still
;@ on the ground, then runs the current step from Cutscene0StepTable.
RunCutscene0::
;> TwinkleCutscene0Stars()
	call TwinkleCutscene0Stars
;> DrawCutscene0People()
	call DrawCutscene0People
;> return Cutscene0StepTable[wSceneStep]()
	ld a, [wSceneStep]
	rst $00

;@ path: event/cutscene
;@ The steps of cutscene 0: the view pans up into the sky, eleven shooting stars fall one after
;@ another (each with a sparkle and a sound), some poses, the switch to the second map, a fade.
Cutscene0StepTable::
	dw CutsceneWait180
	dw Cutscene0PanUp
	dw CutsceneWait240
	dw Cutscene0Star1
	dw CutsceneWait180
	dw Cutscene0Star2
	dw CutsceneWait120
	dw Cutscene0Star3
	dw CutsceneWait120
	dw Cutscene0Star4
	dw CutsceneWait60
	dw Cutscene0Star5
	dw Cutscene0Star6
	dw Cutscene0Star7
	dw Cutscene0Star8
	dw Cutscene0TwoStars
	dw Cutscene0Star9
	dw CutsceneWait24
	dw Cutscene0Star10
	dw CutsceneWait40
	dw Cutscene0Star11
	dw CutsceneWait64
	dw Cutscene0Pose1
	dw Cutscene0Pose2
	dw CutsceneWait60
	dw Cutscene0SwitchMap
	dw Cutscene0Pose3
	dw Cutscene0FadeOut
	dw CutsceneWait240
	dw Cutscene0End

;@ def DrawCutscene0People()
;@ path: event/cutscene
;@ Cutscene 0, while the view is still low (steps 0 and 1): draws five figures standing on the
;@ hill (four through DrawCharacterSprite, one through DrawActorSprite), each with its position, sprite
;@ set, frame, tile base and attributes in hSpriteX..hSpriteAttr.
DrawCutscene0People::
;> if wSceneStep != 0 and wSceneStep != 1:
	ld a, [wSceneStep]
	cp $00
	jr z, .draw

	cp $01
;>     return
	ret nz

;> hSpriteX = 0x48
.draw
	ld hl, hSpriteX
	ld a, $48
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0xF0
	ld a, $f0
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = 0x0E
	ld a, $0e
	ld [hli], a
;> hSpriteFrame = 4
	ld a, $04
	ld [hli], a
;> hSpriteTileBase = 0xB0
	ld a, $b0
	ld [hli], a
;> hSpriteAttr = 0
	ld a, $00
	ld [hl], a
;> DrawCharacterSprite()
	ld hl, far_DrawCharacterSprite
	rst $10
;> hSpriteX = 0x58
	ld hl, hSpriteX
	ld a, $58
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0xF0
	ld a, $f0
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = 0x0D
	ld a, $0d
	ld [hli], a
;> hSpriteFrame = 4
	ld a, $04
	ld [hli], a
;> hSpriteTileBase = 0xA0
	ld a, $a0
	ld [hli], a
;> hSpriteAttr = 0
	ld a, $00
	ld [hl], a
;> DrawCharacterSprite()
	ld hl, far_DrawCharacterSprite
	rst $10
;> hSpriteX = 0x68
	ld hl, hSpriteX
	ld a, $68
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0xF0
	ld a, $f0
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = 0
	ld a, $00
	ld [hli], a
;> hSpriteFrame = 4
	ld a, $04
	ld [hli], a
;> hSpriteTileBase = 0x80
	ld a, $80
	ld [hli], a
;> hSpriteAttr = 0
	ld a, $00
	ld [hl], a
;> DrawActorSprite()
	ld hl, far_DrawActorSprite
	rst $10
;> hSpriteX = 0x28
	ld hl, hSpriteX
	ld a, $28
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x100
	ld a, $00
	ld [hli], a
	ld a, $01
	ld [hli], a
;> hSpriteSet = 0x10
	ld a, $10
	ld [hli], a
;> hSpriteFrame = 4
	ld a, $04
	ld [hli], a
;> hSpriteTileBase = 0xC0
	ld a, $c0
	ld [hli], a
;> hSpriteAttr = 0
	ld a, $00
	ld [hl], a
;> DrawCharacterSprite()
	ld hl, far_DrawCharacterSprite
	rst $10
;> hSpriteX = 0x78
	ld hl, hSpriteX
	ld a, $78
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x100
	ld a, $00
	ld [hli], a
	ld a, $01
	ld [hli], a
;> hSpriteSet = 0x10
	ld a, $10
	ld [hli], a
;> hSpriteFrame = 4
	ld a, $04
	ld [hli], a
;> hSpriteTileBase = 0xC0
	ld a, $c0
	ld [hli], a
;> hSpriteAttr = 0
	ld a, $00
	ld [hl], a
;> DrawCharacterSprite()
	ld hl, far_DrawCharacterSprite
	rst $10
	ret


;@ def Cutscene0PanUp()
;@ path: event/cutscene
;@ Cutscene 0: scrolls the view up one pixel every 3 frames until it reaches the top, then sets
;@ up the first shooting star (object 0 at X $80, Y 0) and its sparkle (object 7, hidden, at
;@ X $50, Y $30).
Cutscene0PanUp::
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 3:
	ld a, [wSceneTimer]
	cp $03
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> mem[addr(hScrollY)] -= 1              # low byte only
	ld hl, hScrollY
	dec [hl]
;> if hScrollY != 0:
	ldh a, [hScrollY]
	or a
;>     return
	ret nz

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0x80, 0x00]      # star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $80
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]      # pose, script step, frames left
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x50]      # (unused), sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $50
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x30, 0x00, 0x00]     # Y, pose, script step
	ld a, $30
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:14] = [0x04, 0x00]          # frames left, (unused)
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Star1()
;@ path: event/cutscene
;@ Cutscene 0, a shooting star: object 0 falls diagonally (X - 1, Y + 1 a frame, script 0) and
;@ hides when it wraps to X $E0; when it passes X $40 its sparkle (object 7, script 1) appears
;@ with sound $5D. When both are gone, the next star and sparkle are set up.
Cutscene0Star1::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1                # X
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1                # Y
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0xE0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $e0
	call z, HideSceneObject0
;> hSpriteSet = 1                       # sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x40:
	ld a, [$c0d9]
	cp $40
	jr nz, .checkDone

;>     wSceneObjects[7] = 0             # show the sparkle
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[0] == 0:
.checkDone
	ld a, [wSceneObjects]
	or a
;>     return                           # the star is still falling
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return                           # the sparkle is still showing
	ret z

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0x40, 0x00]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $40
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x20]      # sparkle hidden at X $20
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $20
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x20, 0x00, 0x00]
	ld a, $20
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:14] = [0x04, 0x00]
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Star2()
;@ path: event/cutscene
;@ Cutscene 0, second shooting star (like Cutscene0Star1): its sparkle shows when it passes X $10.
Cutscene0Star2::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1                # X
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1                # Y
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0xE0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $e0
	call z, HideSceneObject0
;> hSpriteSet = 1                       # sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x10:
	ld a, [$c0d9]
	cp $10
	jr nz, .noSparkle

;>     wSceneObjects[7] = 0             # show the sparkle
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[0] == 0:
.noSparkle
	ld a, [wSceneObjects]
	or a
;>     return                           # the star is still falling
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return                           # the sparkle is still showing
	ret z

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0xA0, 0x30]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $a0
	ld [$c0d9], a
	ld a, $30
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x80]      # sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $80
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x50, 0x00, 0x00]
	ld a, $50
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:14] = [0x04, 0x00]
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Star3()
;@ path: event/cutscene
;@ Cutscene 0, third shooting star: hides at X $28, its sparkle shows at X $70.
Cutscene0Star3::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1                # X
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1                # Y
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0x28:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $28
	call z, HideSceneObject0
;> hSpriteSet = 1                       # sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x70:
	ld a, [$c0d9]
	cp $70
	jr nz, .noSparkle

;>     wSceneObjects[7] = 0             # show the sparkle
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[0] == 0:
.noSparkle
	ld a, [wSceneObjects]
	or a
;>     return                           # the star is still falling
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return                           # the sparkle is still showing
	ret z

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0x80, 0x00]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $80
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x70]      # sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $70
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x10, 0x00, 0x00]
	ld a, $10
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:14] = [0x04, 0x00]
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Star4()
;@ path: event/cutscene
;@ Cutscene 0, fourth shooting star: its sparkle shows at X $60.
Cutscene0Star4::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1                # X
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1                # Y
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0xE0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $e0
	call z, HideSceneObject0
;> hSpriteSet = 1                       # sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x60:
	ld a, [$c0d9]
	cp $60
	jr nz, .noSparkle

;>     wSceneObjects[7] = 0             # show the sparkle
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[0] == 0:
.noSparkle
	ld a, [wSceneObjects]
	or a
;>     return                           # the star is still falling
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return                           # the sparkle is still showing
	ret z

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0x40, 0x00]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $40
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x20]      # sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $20
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x20, 0x00, 0x00]
	ld a, $20
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:14] = [0x04, 0x00]
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Star5()
;@ path: event/cutscene
;@ Cutscene 0, fifth shooting star: its sparkle shows at X $10 and the star is hidden at X 0.
Cutscene0Star5::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1                # X
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1                # Y
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0xE0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $e0
	call z, HideSceneObject0
;> hSpriteSet = 1                       # sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x10:
	ld a, [$c0d9]
	cp $10
	jr nz, .noSparkle

;>     wSceneObjects[7] = 0             # show the sparkle
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[1] == 0:
.noSparkle
	ld a, [$c0d9]
	or a
	jr nz, .checkDone

;>     wSceneObjects[0] = 1             # hide the star early
	ld a, $01
	ld [wSceneObjects], a

;> if wSceneObjects[0] == 0:
.checkDone
	ld a, [wSceneObjects]
	or a
;>     return                           # the star is still falling
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return                           # the sparkle is still showing
	ret z

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0xA0, 0x30]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $a0
	ld [$c0d9], a
	ld a, $30
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x80]      # sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $80
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x50, 0x00, 0x00]
	ld a, $50
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:14] = [0x04, 0x00]
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Star6()
;@ path: event/cutscene
;@ Cutscene 0, sixth shooting star: its sparkle shows at X $70 and the star is hidden at X $38.
Cutscene0Star6::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1                # X
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1                # Y
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0x28:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $28
	call z, HideSceneObject0
;> hSpriteSet = 1                       # sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x70:
	ld a, [$c0d9]
	cp $70
	jr nz, .noSparkle

;>     wSceneObjects[7] = 0             # show the sparkle
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[1] == 0x38:
.noSparkle
	ld a, [$c0d9]
	cp $38
	jr nz, .checkDone

;>     wSceneObjects[0] = 1             # hide the star early
	ld a, $01
	ld [wSceneObjects], a

;> if wSceneObjects[0] == 0:
.checkDone
	ld a, [wSceneObjects]
	or a
;>     return                           # the star is still falling
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return                           # the sparkle is still showing
	ret z

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0x40, 0x00]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $40
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x20]      # sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $20
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x20, 0x00, 0x00]
	ld a, $20
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:14] = [0x04, 0x00]
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Star7()
;@ path: event/cutscene
;@ Cutscene 0, seventh shooting star: its sparkle shows at X $10.
Cutscene0Star7::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1                # X
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1                # Y
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0xE0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $e0
	call z, HideSceneObject0
;> hSpriteSet = 1                       # sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x10:
	ld a, [$c0d9]
	cp $10
	jr nz, .noSparkle

;>     wSceneObjects[7] = 0             # show the sparkle
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[0] == 0:
.noSparkle
	ld a, [wSceneObjects]
	or a
;>     return                           # the star is still falling
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return                           # the sparkle is still showing
	ret z

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0x80, 0x00]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $80
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x30]      # sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $30
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x50, 0x00, 0x00]
	ld a, $50
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:14] = [0x04, 0x00]
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Star8()
;@ path: event/cutscene
;@ Cutscene 0, eighth shooting star: its sparkle shows at X $20; then sets up two stars at once
;@ (objects 0 and 14 with sparkles 7 and 21).
Cutscene0Star8::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1                # X
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1                # Y
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0xE0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $e0
	call z, HideSceneObject0
;> hSpriteSet = 1                       # sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x20:
	ld a, [$c0d9]
	cp $20
	jr nz, .noSparkle

;>     wSceneObjects[7] = 0             # show the sparkle
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[0] == 0:
.noSparkle
	ld a, [wSceneObjects]
	or a
;>     return                           # the star is still falling
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return                           # the sparkle is still showing
	ret z

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0xA0, 0x30]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $a0
	ld [$c0d9], a
	ld a, $30
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x80]      # sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $80
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x50, 0x00, 0x00]
	ld a, $50
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:15] = [0x04, 0x00, 0x00]
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0e6], a
;> wSceneObjects[15:18] = [0x40, 0x00, 0x00]
	ld a, $40
	ld [$c0e7], a
	ld a, $00
	ld [$c0e8], a
	ld a, $00
	ld [$c0e9], a
;> wSceneObjects[18:21] = [0x00, 0x02, 0x00]
	ld a, $00
	ld [$c0ea], a
	ld a, $02
	ld [$c0eb], a
	ld a, $00
	ld [wVSTeam], a
;> wSceneObjects[21:24] = [0x01, 0x20, 0x20]
	ld a, $01
	ld [$c0ed], a
	ld a, $20
	ld [$c0ee], a
	ld a, $20
	ld [$c0ef], a
;> wSceneObjects[24:27] = [0x00, 0x00, 0x04]
	ld a, $00
	ld [$c0f0], a
	ld a, $00
	ld [$c0f1], a
	ld a, $04
	ld [$c0f2], a
;> wSceneObjects[27:28] = [0x00]
	ld a, $00
	ld [$c0f3], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0TwoStars()
;@ path: event/cutscene
;@ Cutscene 0, two shooting stars at once: object 14 (with its sparkle, object 21, which shows
;@ without a sound at X $10) and object 0 (hidden at X $28, sparkle object 7 with sound $5D at
;@ X $70). Ends when all three are gone and sets up the next star.
Cutscene0TwoStars::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # second star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> if wSceneObjects[15] == 0xE0:
	ld a, [$c0e7]
	cp $e0
	jr nz, .drawSecond

;>     wSceneObjects[14] = 1            # hide it
	ld a, $01
	ld [$c0e6], a
;>     hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a

;> UpdateSceneObject(wSceneObjects + 14)
.drawSecond
	ld hl, $c0e6
	call UpdateSceneObject
;> wSceneObjects[15] -= 1
	ld hl, $c0e7
	dec [hl]
;> wSceneObjects[16] += 1
	ld hl, $c0e8
	inc [hl]
;> hSpriteSet = 1                       # its sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 21)
	ld hl, $c0ed
	call UpdateSceneObject
;> if wSceneObjects[15] == 0x10:
	ld a, [$c0e7]
	cp $10
	jr nz, .firstStar

;>     wSceneObjects[21] = 0            # show the sparkle
	ld a, $00
	ld [$c0ed], a

;> hSpriteSet = 0                       # first star
.firstStar
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0x28:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $28
	call z, HideSceneObject0
;> hSpriteSet = 1
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x70:
	ld a, [$c0d9]
	cp $70
	jr nz, .checkDone

;>     wSceneObjects[7] = 0
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[0] == 0:
.checkDone
	ld a, [wSceneObjects]
	or a
;>     return
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return
	ret z

;> if wSceneObjects[14] == 0:
	ld a, [$c0e6]
	or a
;>     return
	ret z

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0x80, 0x00]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $80
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x50]      # sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $50
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x30, 0x00, 0x00]
	ld a, $30
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:14] = [0x04, 0x00]
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Star9()
;@ path: event/cutscene
;@ Cutscene 0, ninth shooting star: its sparkle shows at X $40.
Cutscene0Star9::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1                # X
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1                # Y
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0xE0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $e0
	call z, HideSceneObject0
;> hSpriteSet = 1                       # sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x40:
	ld a, [$c0d9]
	cp $40
	jr nz, .noSparkle

;>     wSceneObjects[7] = 0             # show the sparkle
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[0] == 0:
.noSparkle
	ld a, [wSceneObjects]
	or a
;>     return                           # the star is still falling
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return                           # the sparkle is still showing
	ret z

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0x40, 0x00]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $40
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x20]      # sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $20
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x20, 0x00, 0x00]
	ld a, $20
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:14] = [0x04, 0x00]
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Star10()
;@ path: event/cutscene
;@ Cutscene 0, tenth shooting star: its sparkle shows at X $10.
Cutscene0Star10::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1                # X
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1                # Y
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0xE0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $e0
	call z, HideSceneObject0
;> hSpriteSet = 1                       # sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x10:
	ld a, [$c0d9]
	cp $10
	jr nz, .noSparkle

;>     wSceneObjects[7] = 0             # show the sparkle
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[0] == 0:
.noSparkle
	ld a, [wSceneObjects]
	or a
;>     return                           # the star is still falling
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return                           # the sparkle is still showing
	ret z

;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0xA0, 0x30]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $a0
	ld [$c0d9], a
	ld a, $30
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:9] = [0x00, 0x01, 0x80]      # sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $80
	ld [$c0e0], a
;> wSceneObjects[9:12] = [0x50, 0x00, 0x00]
	ld a, $50
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
;> wSceneObjects[12:14] = [0x04, 0x00]
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Star11()
;@ path: event/cutscene
;@ Cutscene 0, last shooting star: hides at X $28, its sparkle shows at X $70. Then song 2 starts
;@ again and object 0 becomes the figure at X $50, Y $90 for the poses that follow.
Cutscene0Star11::
;> mem[addr(hScrollX)] = 0               # low byte only
	ld a, $00
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0               # low byte only
	ld a, $00
	ldh [hScrollY], a
;> hSpriteSet = 0                       # star
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x60
	ld a, $60
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 1                # X
	ld hl, $c0d9
	dec [hl]
;> wSceneObjects[2] += 1                # Y
	ld hl, $c0da
	inc [hl]
;> if wSceneObjects[1] == 0x28:
;>     HideSceneObject0()
	ld a, [$c0d9]
	cp $28
	call z, HideSceneObject0
;> hSpriteSet = 1                       # sparkle
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x64
	ld a, $64
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 7)
	ld hl, $c0df
	call UpdateSceneObject
;> if wSceneObjects[1] == 0x70:
	ld a, [$c0d9]
	cp $70
	jr nz, .noSparkle

;>     wSceneObjects[7] = 0             # show the sparkle
	ld a, $00
	ld [$c0df], a
;>     QueueSound(0x5D)
	ld a, $5d
	call QueueSound

;> if wSceneObjects[0] == 0:
.noSparkle
	ld a, [wSceneObjects]
	or a
;>     return                           # the star is still falling
	ret z

;> if wSceneObjects[7] == 0:
	ld a, [$c0df]
	or a
;>     return                           # the sparkle is still showing
	ret z

;> QueueMusic(2)
	ld a, $02
	call QueueMusic
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wSceneObjects[0:3] = [0x00, 0x50, 0x90]      # next star: shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $50
	ld [$c0d9], a
	ld a, $90
	ld [$c0da], a
;> wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;> wSceneObjects[6:7] = [0x00]      # sparkle: hidden, X
	ld a, $00
	ld [$c0de], a
;> wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret


;@ def Cutscene0Pose1()
;@ path: event/cutscene
;@ Cutscene 0: object 0 shows the figure with script 2 (tiles from $67) for 120 frames, then
;@ is set up again (X $50, Y $90) for the next pose.
Cutscene0Pose1::
;> hSpriteSet = 2
	ld a, $02
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x67
	ld a, $67
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> if wSceneTimer < 0x78:
	ld a, [wSceneTimer]
	cp $78
	jr c, .count

;>@count     wSceneTimer += 1
;> else:
;>     wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;>     wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;>     wSceneObjects[0:3] = [0x00, 0x50, 0x90]  # shown, X, Y
	ld a, $00
	ld [wSceneObjects], a
	ld a, $50
	ld [$c0d9], a
	ld a, $90
	ld [$c0da], a
;>     wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;>     wSceneObjects[6] = 0
	ld a, $00
	ld [$c0de], a
;>     wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret

.count
;=@count
	ld hl, wSceneTimer
	inc [hl]
	ret


;@ def Cutscene0Pose2()
;@ path: event/cutscene
;@ Cutscene 0: the figure's next pose (script 3) for 120 frames, then set up again at X $50, Y $88.
Cutscene0Pose2::
;> hSpriteSet = 3
	ld a, $03
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x67
	ld a, $67
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> if wSceneTimer < 0x78:
	ld a, [wSceneTimer]
	cp $78
	jr c, .count

;>@count     wSceneTimer += 1
;> else:
;>     wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;>     wSceneObjects[0:3] = [0x00, 0x50, 0x88]
	ld a, $00
	ld [wSceneObjects], a
	ld a, $50
	ld [$c0d9], a
	ld a, $88
	ld [$c0da], a
;>     wSceneObjects[3:6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
;>     wSceneObjects[6] = 0
	ld a, $00
	ld [$c0de], a
;>     wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret

.count
;=@count
	ld hl, wSceneTimer
	inc [hl]
	ret


;@ def Cutscene0SwitchMap()
;@ path: event/cutscene
;@ Cutscene 0: switches the background to BG map 2 (Cutscene0GroundTilemap).
Cutscene0SwitchMap::
;> wLCDC = 0x8B                        # LCD on, BG map $9C00, sprites, background
	ld a, $8b
	ld [wLCDC], a
;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def Cutscene0Pose3()
;@ path: event/cutscene
;@ Cutscene 0: the figure's last pose (script 4) for 36 frames.
Cutscene0Pose3::
;> hSpriteSet = 4
	ld a, $04
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x67
	ld a, $67
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 2
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> if wSceneTimer < 0x24:
	ld a, [wSceneTimer]
	cp $24
	jr c, .count

;>@count     wSceneTimer += 1
;> else:
;>     wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;>     wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret

.count
;=@count
	ld hl, wSceneTimer
	inc [hl]
	ret


;@ def Cutscene0FadeOut()
;@ path: event/cutscene
;@ Starts a fade out on the first frame, then waits until the fade is over.
Cutscene0FadeOut::
;> if wSceneTimer == 0:
	ld a, [wSceneTimer]
	or a
	jr z, .start

;>@start     wSceneTimer += 1
;>@start2     StartFade(4)
;> elif wFadeState != 0:
	ld a, [wFadeState]
	or a
;>     return                           # still fading
	ret nz

;> else:
;>     wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;>     wSceneTimer = 0
	ld a, $00
	ld [wSceneTimer], a
	ret

.start
;=@start
	ld hl, wSceneTimer
	inc [hl]
;=@start2
	ld a, $04
	call StartFade
	ret


;@ def Cutscene0End()
;@ path: event/cutscene
;@ End of cutscene 0: switches to game mode 1 (the field) and marks the game as started.
Cutscene0End::
;> wGameMode = 1
	ld a, $01
	ld [wGameMode], a
;> wGameModeStep = 0
	ld a, $00
	ld [wGameModeStep], a
;> mem[0xC88C] = 0
	ld a, $00
	ld [$c88c], a
;> mem[0xC88D] = 0
	ld a, $00
	ld [$c88d], a
;> wGameStarted |= 0x80
	ld hl, wGameStarted
	set 7, [hl]
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
;> wLCDC = 0x83
	ld a, $83
	ld [wLCDC], a
	ret


;@ def CutsceneWait24()
;@ path: event/cutscene
;@ Cutscene step: waits 24 frames.
CutsceneWait24::
;> if wSceneTimer < 0x18:
	ld a, [wSceneTimer]
	cp $18
;>     return CutsceneCountFrame()
	jr c, CutsceneCountFrame

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def CutsceneWait40()
;@ path: event/cutscene
;@ Cutscene step: waits 40 frames.
CutsceneWait40::
;> if wSceneTimer < 0x28:
	ld a, [wSceneTimer]
	cp $28
;>     return CutsceneCountFrame()
	jr c, CutsceneCountFrame

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def CutsceneWait64()
;@ path: event/cutscene
;@ Cutscene step: waits 64 frames.
CutsceneWait64::
;> if wSceneTimer < 0x40:
	ld a, [wSceneTimer]
	cp $40
;>     return CutsceneCountFrame()
	jr c, CutsceneCountFrame

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def CutsceneWait60()
;@ path: event/cutscene
;@ Cutscene step: waits 60 frames (one second).
CutsceneWait60::
;> if wSceneTimer < 0x3C:
	ld a, [wSceneTimer]
	cp $3c
;>     return CutsceneCountFrame()
	jr c, CutsceneCountFrame

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def CutsceneWait120()
;@ path: event/cutscene
;@ Cutscene step: waits 120 frames.
CutsceneWait120::
;> if wSceneTimer < 0x78:
	ld a, [wSceneTimer]
	cp $78
;>     return CutsceneCountFrame()
	jr c, CutsceneCountFrame

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def CutsceneWait180()
;@ path: event/cutscene
;@ Cutscene step: waits 180 frames.
CutsceneWait180::
;> if wSceneTimer < 0xB4:
	ld a, [wSceneTimer]
	cp $b4
;>     return CutsceneCountFrame()
	jr c, CutsceneCountFrame

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def CutsceneWait240()
;@ path: event/cutscene
;@ Cutscene step: waits 240 frames.
CutsceneWait240::
;> if wSceneTimer < 0xF0:
	ld a, [wSceneTimer]
	cp $f0
;>     return CutsceneCountFrame()
	jr c, CutsceneCountFrame

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def CutsceneCountFrame()
;@ path: event/cutscene
;@ One more frame of a cutscene wait.
CutsceneCountFrame::
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
	ret


;@ def DrawTilemap(src: de, dest: hl)
;@ path: gfx/tilemap
;@ Draws a tilemap into a BG map. Format: a 2-byte offset added to dest, then tile numbers;
;@ $D8 goes to the start of the next row (32 tiles on), $D9 ends the map.
DrawTilemap::
;> offset = mem16[src]; src += 2
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
;> dest += offset
	add hl, bc
;> wSceneObjectPtr = dest              # start of the current row
	ld a, l
	ld [wSceneObjectPtr], a
	ld a, h
	ld [wSceneObjectPtr + 1], a

;> while True:
.loop
;>     t = mem[src]; src += 1
	ld a, [de]
	inc de
;>     if t == 0xD8:
	cp $d8
	jr z, .newRow

;>@row1         dest = wSceneObjectPtr
;>@row2         dest += 0x20
;>@row3         wSceneObjectPtr = dest
;>     elif t == 0xD9:
	cp $d9
;>         return
	ret z

;>     else:
;>         mem[dest] = t; dest += 1
	ld [hli], a
	jr .loop

.newRow
;=@row1
	ld a, [wSceneObjectPtr]
	ld l, a
	ld a, [wSceneObjectPtr + 1]
	ld h, a
;=@row2
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@row3
	ld a, l
	ld [wSceneObjectPtr], a
	ld a, h
	ld [wSceneObjectPtr + 1], a
	jr .loop

;@ def TwinkleCutscene0Stars()
;@ path: event/cutscene
;@ Every 24 frames swaps the graphics of one star tile with the tile after it (the five star
;@ tiles of TwinkleTileAddrs in turn), so the stars of the night sky twinkle. Each VRAM access
;@ waits for a moment when VRAM is free (WaitVRAMAccess).
;@ test: skip waits on the LCD status
TwinkleCutscene0Stars::
;> wSceneAux3 += 1
	ld hl, wSceneAux3
	inc [hl]
;> if wSceneAux3 != 0x18:
	ld a, [wSceneAux3]
	cp $18
;>     return
	ret nz

;> wSceneAux3 = 0
	xor a
	ld [wSceneAux3], a
;> wSceneAux += 1                       # next star tile
	ld hl, wSceneAux
	inc [hl]
;> if wSceneAux == 5:
	ld a, [wSceneAux]
	cp $05
	jr nz, .swap

;>     wSceneAux = 0
	xor a
	ld [wSceneAux], a

;> tile = GetTableEntry(TwinkleTileAddrs, wSceneAux)
.swap
	ld hl, TwinkleTileAddrs
	ld a, [wSceneAux]
	call GetTableEntry
;> other = tile
	ld e, l
	ld d, h
;> other += 16                          # the tile after it
	ld a, $10
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;>@loop for i in range(16):
	ld b, $10

.loop
;>     wSceneAux2 = mem[other + i]
	di
	call WaitVRAMAccess
	ld a, [de]
	ei
	ld [wSceneAux2], a
;>     v = mem[tile + i]
	di
	call WaitVRAMAccess
	ld a, [hl]
	ei
	push af
;>     mem[other + i] = v
	di
	call WaitVRAMAccess
	pop af
	ld [de], a
	ei
;>     v = wSceneAux2
	ld a, [wSceneAux2]
	push af
;>     mem[tile + i] = v
	di
	call WaitVRAMAccess
	pop af
	ld [hl], a
	ei
;=@loop
	inc de
	inc hl
	dec b
	jr nz, .loop

;> return
	ret


;@ path: event/cutscene
;@ VRAM addresses of the five star tiles that TwinkleCutscene0Stars swaps with their neighbours.
TwinkleTileAddrs::
	dw $9180, $91a0, $91c0, $91e0, $9200

;@ def RunCutscene1()
;@ path: event/cutscene
;@ Cutscene 1, every frame: animates the background tiles, then runs the current step.
RunCutscene1::
;> AnimateCutsceneTiles()
	call AnimateCutsceneTiles
;> return Cutscene1StepTable[wSceneStep]()
	ld a, [wSceneStep]
	rst $00

;@ path: event/cutscene
;@ The steps of cutscene 1: pan up, wait, fade out, pause, then on into the field.
Cutscene1StepTable::
	dw Cutscene1PanUp
	dw Cutscene1Wait
	dw Cutscene1FadeOut
	dw Cutscene1Pause
	dw Cutscene1End

;@ def Cutscene1PanUp()
;@ path: event/cutscene
;@ Scrolls the view up one pixel every 5 frames until it reaches the top.
Cutscene1PanUp::
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 5:
	ld a, [wSceneTimer]
	cp $05
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> mem[addr(hScrollY)] -= 1              # low byte only
	ld hl, hScrollY
	dec [hl]
;> if hScrollY != 0:
	ldh a, [hScrollY]
	or a
;>     return
	ret nz

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def Cutscene1Wait()
;@ path: event/cutscene
;@ Waits 180 frames.
Cutscene1Wait::
;> if wSceneTimer < 0xB4:
	ld a, [wSceneTimer]
	cp $b4
	jr nc, .done

;>     wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
	ret

;> else:
;>     wSceneTimer = 0
.done
	xor a
	ld [wSceneTimer], a
;>     wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def Cutscene1FadeOut()
;@ path: event/cutscene
;@ Starts a fade out on the first frame, then waits until it is over.
Cutscene1FadeOut::
;> if wSceneTimer == 0:
	ld a, [wSceneTimer]
	or a
	jr z, .start

;>@start     wSceneTimer += 1
;>@start2     StartFade(4)
;> elif wFadeState != 0:
	ld a, [wFadeState]
	or a
;>     return
	ret nz

;> else:
;>     wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;>     wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
	ret

.start
;=@start
	ld hl, wSceneTimer
	inc [hl]
;=@start2
	ld a, $04
	call StartFade
	ret


;@ def Cutscene1Pause()
;@ path: event/cutscene
;@ Waits 120 frames.
Cutscene1Pause::
;> if wSceneTimer < 0x78:
	ld a, [wSceneTimer]
	cp $78
	jr nc, .done

;>     wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
	ret

;> else:
;>     wSceneTimer = 0
.done
	xor a
	ld [wSceneTimer], a
;>     wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def Cutscene1End()
;@ path: event/cutscene
;@ End of cutscene 1: back to the field (game mode 1) with a warp to map 4 at X $F8, Y $38.
;@ The party (count and the six bytes after it) is put aside at $CAB9 and emptied: Terry
;@ goes on without his monsters.
Cutscene1End::
;> wGameMode = 1
	ld a, $01
	ld [wGameMode], a
;> wGameModeStep = 0
	ld a, $00
	ld [wGameModeStep], a
;> mem[0xC88C] = 0
	ld a, $00
	ld [$c88c], a
;> mem[0xC88D] = 0
	ld a, $00
	ld [$c88d], a
;> wWarpMap = 4
	ld hl, $0004
	ld a, l
	ld [wWarpMap], a
;> wWarpOnGateFloor = 0
	ld a, h
	ld [wWarpOnGateFloor], a
;> wWarpX = 0xF8
	ld hl, $00f8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [wWarpX + 1], a
;> wWarpY = 0x38
	ld hl, $0038
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [wWarpY + 1], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> hPlayerFlags = 0
	xor a
	ldh [hPlayerFlags], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> wFieldFlags &= ~0x01
	ld hl, wFieldFlags
	res 0, [hl]
;>@copy copy(0xCAB9, wPartyCount, 7)         # keep the party aside
	ld hl, wSavedParty
	ld a, [wPartyCount]
	ld [hli], a
	ld a, [wParty]
	ld [hli], a
;=@copy
	ld a, [wParty + 1]
	ld [hli], a
	ld a, [wParty + 2]
	ld [hli], a
	ld a, [wPartyGfx]
	ld [hli], a
;=@copy
	ld a, [wPartyGfx + 1]
	ld [hli], a
	ld a, [wPartyGfx + 2]
	ld [hli], a
;> wPartyCount = 0
	xor a
	ld [wPartyCount], a
;> fill(wParty, 0xFF, 3)               # no monsters
	ld a, $ff
	ld [wParty], a
	ld [wParty + 1], a
	ld [wParty + 2], a
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret


;@ def AnimateCutsceneTiles()
;@ path: event/cutscene
;@ Background animation of cutscenes 1 and 2, on a 50-frame cycle: at frame 25 the 2-tile blocks
;@ at $8920 and $8A20 swap graphics with the blocks after them (CutsceneTileSwapB), at frame 50
;@ the tiles $8900 and $8A00 swap with the tiles after them (CutsceneTileSwapA).
;@ test: skip waits on the LCD status
AnimateCutsceneTiles::
;> wSceneAux2 += 1
	ld hl, wSceneAux2
	inc [hl]
;> if wSceneAux2 == 0x19:
	ld a, [wSceneAux2]
	cp $19
	jr z, .swapBlocks

;>@blocks     for wSceneAux in range(0, 4, 2):
;>@b1         tile = GetTableEntry(CutsceneTileSwapB, wSceneAux)
;>@b2         other = tile
;>@b3         other += 32
;>@b4         for i in range(32):
;>@b5             v = mem[other + i]
;>@b6             mem[other + i] = mem[tile + i]
;>@b7             mem[tile + i] = v
;> elif wSceneAux2 == 0x32:
	cp $32
	ret nz

;>     wSceneAux2 = 0
	xor a
	ld [wSceneAux2], a
;>@tiles     for wSceneAux in range(2):
	xor a
	ld [wSceneAux], a

.nextTile
;>         tile = GetTableEntry(CutsceneTileSwapA, wSceneAux)
	ld a, [wSceneAux]
	ld hl, CutsceneTileSwapA
	call GetTableEntry
;>         other = tile
	ld e, l
	ld d, h
;>         other += 16
	ld a, $10
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;>@t4         for i in range(16):
	ld b, $10

.tileLoop
;>             v = mem[other + i]
	di
	call WaitVRAMAccess
	ld a, [de]
	ld [wSceneAux3], a
;>             mem[other + i] = mem[tile + i]
	call WaitVRAMAccess
	ld a, [hl]
	ld [de], a
;>             mem[tile + i] = v
	ld a, [wSceneAux3]
	ld [hl], a
	ei
;=@t4
	inc de
	inc hl
	dec b
	jr nz, .tileLoop

;=@tiles
	ld hl, wSceneAux
	inc [hl]
	ld a, [wSceneAux]
	cp $02
	jr nz, .nextTile

;> return
	ret

.swapBlocks
;=@blocks
	xor a
	ld [wSceneAux], a

.nextBlock
;=@b1
	ld a, [wSceneAux]
	ld hl, CutsceneTileSwapB
	call GetTableEntry
;=@b2
	ld e, l
	ld d, h
;=@b3
	ld a, $20
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;=@b4
	ld b, $20

.blockLoop
;=@b5
	di
	call WaitVRAMAccess
	ld a, [de]
	ld [wSceneAux3], a
	ei
;=@b6
	di
	call WaitVRAMAccess
	ld a, [hl]
	ld [de], a
	ei
;=@b7
	di
	call WaitVRAMAccess
	ld a, [wSceneAux3]
	ld [hl], a
	ei
;=@b4
	inc de
	inc hl
	dec b
	jr nz, .blockLoop

;=@blocks
	ld hl, wSceneAux
	inc [hl]
	ld hl, wSceneAux
	inc [hl]
;=@blocks
	ld a, [wSceneAux]
	cp $04
	jr nz, .nextBlock

	ret


;@ path: event/cutscene
;@ Tiles that AnimateCutsceneTiles swaps with the tile after them.
CutsceneTileSwapA::
	dw $8900, $8a00

;@ path: event/cutscene
;@ 2-tile blocks that AnimateCutsceneTiles swaps with the block after them (entries 0 and 2 are used).
CutsceneTileSwapB::
	dw $8920, $8930, $8a20, $8a30

;@ def RunCutscene2()
;@ path: event/cutscene
;@ Cutscene 2, every frame: animates the background tiles, then runs the current step.
RunCutscene2::
;> AnimateCutsceneTiles()
	call AnimateCutsceneTiles
;> return Cutscene2StepTable[wSceneStep]()
	ld a, [wSceneStep]
	rst $00

;@ path: event/cutscene
;@ The steps of cutscene 2: pan up, a rumble that shakes the screen, a pause, back to the field.
Cutscene2StepTable::
	dw CutsceneScrollDown
	dw CutsceneQuakeStart
	dw CutsceneQuake
	dw CutsceneAfterQuake
	dw Cutscene2End

;@ def CutsceneScrollDown()
;@ path: event/cutscene
;@ Cutscenes 2 and 3: pans the view up one pixel every 4 frames until hScrollY is 8.
CutsceneScrollDown::
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 4:
	ld a, [wSceneTimer]
	cp $04
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> mem[addr(hScrollY)] -= 1              # low byte only
	ld hl, hScrollY
	dec [hl]
;> if hScrollY != 8:
	ldh a, [hScrollY]
	cp $08
;>     return
	ret nz

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def CutsceneQuakeStart()
;@ path: event/cutscene
;@ Cutscenes 2 and 3: waits 120 frames, then plays the rumble sound $68.
CutsceneQuakeStart::
;> if wSceneTimer < 0x78:
	ld a, [wSceneTimer]
	cp $78
	jr nc, .start

;>     wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
	ret

;> else:
;>     wSceneObjects[0] = 0             # shake toggle
.start
	xor a
	ld [wSceneObjects], a
;>     wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;>     wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;>     QueueSound(0x68)
	ld a, $68
	call QueueSound
	ret


;@ def CutsceneQuake()
;@ path: event/cutscene
;@ Cutscenes 2 and 3: for 240 frames the view jumps between hScrollY 8 and 0 every 3 frames.
CutsceneQuake::
;> if wSceneTimer >= 0xF0:
	ld a, [wSceneTimer]
	cp $f0
	jr nc, .done

;>@done     wSceneTimer = 0
;>@done2     wSceneStep += 1
;>@done3     return
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer & 3 != 3:
	ld a, [wSceneTimer]
	and $03
	cp $03
;>     return
	ret nz

;> wSceneObjects[0] += 1
	ld hl, wSceneObjects
	inc [hl]
;> if wSceneObjects[0] == 2:
	ld a, [wSceneObjects]
	cp $02
	jr nz, .scroll

;>     wSceneObjects[0] = 0
	xor a
	ld [wSceneObjects], a

;> p = QuakeScrollValues + wSceneObjects[0]
.scroll
	ld a, [wSceneObjects]
	ld hl, QuakeScrollValues
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[addr(hScrollY)] = mem[p]          # low byte only
	ld h, a
	ld a, [hl]
	ldh [hScrollY], a
	ret

.done
;=@done
	xor a
	ld [wSceneTimer], a
;=@done2
	ld hl, wSceneStep
	inc [hl]
;=@done3
	ret


;@ path: event/cutscene
;@ hScrollY values CutsceneQuake switches between.
QuakeScrollValues::
	db $08, $00

;@ def CutsceneAfterQuake()
;@ path: event/cutscene
;@ Cutscenes 2 and 3: waits 60 frames after the rumble.
CutsceneAfterQuake::
;> if wSceneTimer < 0x3C:
	ld a, [wSceneTimer]
	cp $3c
	jr nc, .done

;>     wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
	ret

;> else:
;>     wSceneObjects[0] = 0
.done
	xor a
	ld [wSceneObjects], a
;>     wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;>     wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def Cutscene2End()
;@ path: event/cutscene
;@ End of cutscenes 2 and 3: fades out, then back to the field (game mode 1).
Cutscene2End::
;> if wSceneTimer == 0:
	ld a, [wSceneTimer]
	or a
;>     return CutsceneStartFadeOut()
	jr z, CutsceneStartFadeOut

;> if wFadeState != 0:
	ld a, [wFadeState]
	or a
;>     return
	ret nz

;> wGameMode = 1
	ld a, $01
	ld [wGameMode], a
;> wGameModeStep = 0
	ld a, $00
	ld [wGameModeStep], a
;> mem[0xC88C] = 0
	ld a, $00
	ld [$c88c], a
;> mem[0xC88D] = 0
	ld a, $00
	ld [$c88d], a
;> wGameStarted |= 0x80
	ld hl, wGameStarted
	set 7, [hl]
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret


;@ def CutsceneStartFadeOut()
;@ path: event/cutscene
;@ First frame of a cutscene's last step: starts the fade out.
CutsceneStartFadeOut::
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> StartFade(4)
	ld a, $04
	call StartFade
	ret


;@ def RunCutscene3()
;@ path: event/cutscene
;@ Cutscene 3, every frame: runs the current step (no tile animation).
RunCutscene3::
;> return Cutscene3StepTable[wSceneStep]()
	ld a, [wSceneStep]
	rst $00

;@ path: event/cutscene
;@ The steps of cutscene 3 (the same as cutscene 2).
Cutscene3StepTable::
	dw CutsceneScrollDown
	dw CutsceneQuakeStart
	dw CutsceneQuake
	dw CutsceneAfterQuake
	dw Cutscene3End

;@ def Cutscene3End()
;@ path: event/cutscene
;@ End of cutscene 3: fades out, then back to the field (game mode 1).
Cutscene3End::
;> if wSceneTimer == 0:
	ld a, [wSceneTimer]
	or a
;>     return CutsceneStartFadeOut()
	jr z, CutsceneStartFadeOut

;> if wFadeState != 0:
	ld a, [wFadeState]
	or a
;>     return
	ret nz

;> wGameMode = 1
	ld a, $01
	ld [wGameMode], a
;> wGameModeStep = 0
	ld a, $00
	ld [wGameModeStep], a
;> mem[0xC88C] = 0
	ld a, $00
	ld [$c88c], a
;> mem[0xC88D] = 0
	ld a, $00
	ld [$c88d], a
;> wGameStarted |= 0x80
	ld hl, wGameStarted
	set 7, [hl]
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret


;@ def InitShootingStars()
;@ path: event/shooting-star
;@ Loads the star and sparkle sprite tiles (while the screen is on), clears the six event objects
;@ and hides them all.
;@ test: skip decompresses graphics into VRAM
InitShootingStars::
;> DecompressVRAM(0x5B18, 0x8700)       # star tiles
	ld de, $5b18
	ld hl, $8700
	call DecompressVRAM
;> DecompressVRAM(0x5B19, 0x8740)       # sparkle tiles
	ld de, $5b19
	ld hl, $8740
	call DecompressVRAM
;> fill(wSceneObjects, 0, 0x28)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> HideSceneObject0()
	call HideSceneObject0
;> HideSceneObject1()
	call HideSceneObject1
;> HideSceneObject2()
	call HideSceneObject2
;> HideSceneObject3()
	call HideSceneObject3
;> HideSceneObject4()
	call HideSceneObject4
;> HideSceneObject5()
	call HideSceneObject5
	ret


;@ def RunShootingStarEvent()
;@ path: event/shooting-star
;@ Field event on map 8 at story step 7, called every frame from the field: shooting stars fall
;@ over the field, a shower, a pause until the field clock is at the right phase, more stars, six
;@ rising stars, three flashes, and the end of the event. Runs the current step.
RunShootingStarEvent::
;> return ShootingStarStepTable[wSceneStep]()
	ld a, [wSceneStep]
	rst $00

;@ path: event/shooting-star
;@ The steps of the shooting-star event.
ShootingStarStepTable::
	dw ShootingStarIntro
	dw ShootingStarSetup
	dw ShootingStarPass1
	dw ShootingStarPass2
	dw ShootingStarPass3
	dw ShootingStarPass4
	dw ShootingStarShower
	dw ShootingStarPause
	dw ShootingStarWaitPhase0
	dw ShootingStarWaitPhase15
	dw ShootingStarCross
	dw ShootingStarRise
	dw ShootingStarWaitPhase16
	dw ShootingStarFlash
	dw ShootingStarEnd

;@ def ShootingStarIntro()
;@ path: event/shooting-star
;@ First step: sets the event up on its first frame, then waits 2 x 240 frames (object 0's hidden
;@ flag counts the rounds: InitShootingStars leaves it at 1, the first round makes it 2).
ShootingStarIntro::
;> if wSceneTimer == 0 and wSceneObjects[0] == 0:
;>     InitShootingStars()
	ld a, [wSceneTimer]
	ld b, a
	ld a, [wSceneObjects]
	or b
	call z, InitShootingStars
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 0xF0:
	ld a, [wSceneTimer]
	cp $f0
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> if wSceneObjects[0] == 1:
	ld a, [wSceneObjects]
	cp $01
	jr nz, .done

;>     wSceneObjects[0] += 1            # one more round
	ld hl, wSceneObjects
	inc [hl]
;>     return
	ret

;> wSceneTimer = 0
.done
	xor a
	ld [wSceneTimer], a
;> wSceneObjects[0] = 0
	xor a
	ld [wSceneObjects], a
;> wShootingStarStage = 0
	xor a
	ld [wShootingStarStage], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def ShootingStarSetup()
;@ path: event/shooting-star
;@ Waits 120 frames, then sets up the first star (object 0 at X $80) and its sparkle (object 6,
;@ hidden at X $70, Y $10).
ShootingStarSetup::
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 0x78:
	ld a, [wSceneTimer]
	cp $78
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> InitStarHighRight(wSceneObjects)
	ld hl, wSceneObjects
	call InitStarHighRight
;> InitSparkleLow(wSceneObjects + 6)
	ld hl, $c0de
	call InitSparkleLow
	ret


;@ def ShootingStarPass1()
;@ path: event/shooting-star
;@ A star (object 0) falls diagonally, 2 pixels a frame (X - 2, Y + 2), and is hidden at X 0; at
;@ X $60 its sparkle (object 6) appears. After 120 frames the next star is set up.
ShootingStarPass1::
;> hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 2
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
;> wSceneObjects[2] += 2
	ld a, [$c0da]
	add $02
	ld [$c0da], a
;> if wSceneObjects[1] == 0x60:
;>     ShowSceneObject1()
	ld a, [$c0d9]
	cp $60
	call z, ShowSceneObject1
;> if wSceneObjects[1] == 0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	or a
	call z, HideSceneObject0
;> hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 6)
	ld hl, $c0de
	call UpdateSceneObject
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 0x78:
	ld a, [wSceneTimer]
	cp $78
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> InitStarLeft(wSceneObjects)
	ld hl, wSceneObjects
	call InitStarLeft
	ret


;@ def ShootingStarPass2()
;@ path: event/shooting-star
;@ The second star: its sparkle appears at X $10; after 120 frames the third is set up.
ShootingStarPass2::
;> hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 2
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
;> wSceneObjects[2] += 2
	ld a, [$c0da]
	add $02
	ld [$c0da], a
;> if wSceneObjects[1] == 0x10:
;>     ShowSceneObject1()
	ld a, [$c0d9]
	cp $10
	call z, ShowSceneObject1
;> if wSceneObjects[1] == 0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	or a
	call z, HideSceneObject0
;> hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 6)
	ld hl, $c0de
	call UpdateSceneObject
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 0x78:
	ld a, [wSceneTimer]
	cp $78
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> InitStarFarRight(wSceneObjects)
	ld hl, wSceneObjects
	call InitStarFarRight
	ret


;@ def ShootingStarPass3()
;@ path: event/shooting-star
;@ The third star: its sparkle appears at X $70; after 60 frames two stars are set up (objects 0
;@ and 12, the second one still hidden).
ShootingStarPass3::
;> hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 2
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
;> wSceneObjects[2] += 2
	ld a, [$c0da]
	add $02
	ld [$c0da], a
;> if wSceneObjects[1] == 0x70:
;>     ShowSceneObject1()
	ld a, [$c0d9]
	cp $70
	call z, ShowSceneObject1
;> if wSceneObjects[1] == 0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	or a
	call z, HideSceneObject0
;> hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 6)
	ld hl, $c0de
	call UpdateSceneObject
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 0x3C:
	ld a, [wSceneTimer]
	cp $3c
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> InitStarLeft(wSceneObjects)
	ld hl, wSceneObjects
	call InitStarLeft
;> InitStarFarRight(wSceneObjects + 12)
	ld hl, $c0e4
	call InitStarFarRight
;> HideSceneObject2()
	call HideSceneObject2
	ret


;@ def ShootingStarPass4()
;@ path: event/shooting-star
;@ Two stars: object 0 as before (sparkle at X $10); from frame 16 on the second star (object
;@ 12, shown at frame 16, sparkle object 18 at X $70) falls too. After 200 frames the shower
;@ is set up and wShootingStarStage becomes 1; the field clock starts again from 0.
ShootingStarPass4::
;> hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;> wSceneObjects[1] -= 2
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
;> wSceneObjects[2] += 2
	ld a, [$c0da]
	add $02
	ld [$c0da], a
;> if wSceneObjects[1] == 0x10:
;>     ShowSceneObject1()
	ld a, [$c0d9]
	cp $10
	call z, ShowSceneObject1
;> if wSceneObjects[1] == 0:
;>     HideSceneObject0()
	ld a, [$c0d9]
	or a
	call z, HideSceneObject0
;> hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;> UpdateSceneObject(wSceneObjects + 6)
	ld hl, $c0de
	call UpdateSceneObject
;> if wSceneTimer >= 0x10:
	ld a, [wSceneTimer]
	cp $10
	jr c, jr_002_61fc

;>     if wSceneTimer == 0x10:
	jr nz, jr_002_61b9

;>         ShowSceneObject2()
	call ShowSceneObject2

jr_002_61b9:
;>     hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 12)
	ld hl, $c0e4
	call UpdateSceneObject
;>     wSceneObjects[13] -= 2
	ld a, [$c0e5]
	sub $02
	ld [$c0e5], a
;>     wSceneObjects[14] += 2
	ld a, [$c0e6]
	add $02
	ld [$c0e6], a
;>     if wSceneObjects[13] == 0x70:
;>         ShowSceneObject3()
	ld a, [$c0e5]
	cp $70
	call z, ShowSceneObject3
;>     if wSceneObjects[13] == 0:
;>         HideSceneObject2()
	ld a, [$c0e5]
	or a
	call z, HideSceneObject2
;>     hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 18)
	ld hl, $c0ea
	call UpdateSceneObject

jr_002_61fc:
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 0xC8:
	ld a, [wSceneTimer]
	cp $c8
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> InitStarLeft(wSceneObjects)
	ld hl, wSceneObjects
	call InitStarLeft
;> InitStarHighRight(wSceneObjects + 12)
	ld hl, $c0e4
	call InitStarHighRight
;> InitSparkleLow(wSceneObjects + 18)
	ld hl, $c0ea
	call InitSparkleLow
;> InitStarFarRight(wSceneObjects + 24)
	ld hl, $c0f0
	call InitStarFarRight
;> HideSceneObject2()
	call HideSceneObject2
;> HideSceneObject4()
	call HideSceneObject4
;> ShowSceneObject0()
	call ShowSceneObject0
;> wShootingStarStage += 1
	ld hl, wShootingStarStage
	inc [hl]
;> wFieldTimer = 0
	xor a
	ld [wFieldTimer], a
	ld [wFieldTimer + 1], a
	ret


;@ def ShootingStarShower()
;@ path: event/shooting-star
;@ The shower: three star pairs (A = objects 0/6, B = 12/18, C = 24/30) are set up at frames
;@ $40, $60 and $70 and each falls diagonally (X - 2, Y + 2); a pair's sparkle appears at a set X and
;@ its star is hidden at another. Which pairs move depends on the frame: A before $40, B from $10
;@ to $5F, C from $20 to $6F, A again from $30 to $7F, B again from $50, C again from $60. Ends
;@ after 180 frames.
ShootingStarShower::
;> if wSceneTimer == 0x40:
;>     InitStarLeft(wSceneObjects)
	ld a, [wSceneTimer]
	cp $40
	ld hl, wSceneObjects
	call z, InitStarLeft
;> if wSceneTimer == 0x60:
;>     InitStarFarRight(wSceneObjects + 12)
	ld a, [wSceneTimer]
	cp $60
	ld hl, $c0e4
	call z, InitStarFarRight
;> if wSceneTimer == 0x70:
;>     InitStarHighRight(wSceneObjects + 24)
	ld a, [wSceneTimer]
	cp $70
	ld hl, $c0f0
	call z, InitStarHighRight
;> if wSceneTimer == 0x70:
;>     InitSparkleLeft(wSceneObjects + 30)
	ld a, [wSceneTimer]
	cp $70
	ld hl, $c0f6
	call z, InitSparkleLeft
;> if wSceneTimer == 0x40:
;>     HideSceneObject0()
	ld a, [wSceneTimer]
	cp $40
	call z, HideSceneObject0
;> if wSceneTimer == 0x60:
;>     HideSceneObject2()
	ld a, [wSceneTimer]
	cp $60
	call z, HideSceneObject2
;> if wSceneTimer == 0x70:
;>     HideSceneObject4()
	ld a, [wSceneTimer]
	cp $70
	call z, HideSceneObject4
;> if wSceneTimer == 0x10:
;>     ShowSceneObject2()
	ld a, [wSceneTimer]
	cp $10
	call z, ShowSceneObject2
;> if wSceneTimer == 0x20:
;>     ShowSceneObject4()
	ld a, [wSceneTimer]
	cp $20
	call z, ShowSceneObject4
;> if wSceneTimer == 0x40:
;>     ShowSceneObject0()
	ld a, [wSceneTimer]
	cp $40
	call z, ShowSceneObject0
;> if wSceneTimer == 0x60:
;>     ShowSceneObject2()
	ld a, [wSceneTimer]
	cp $60
	call z, ShowSceneObject2
;> if wSceneTimer == 0x70:
;>     ShowSceneObject4()
	ld a, [wSceneTimer]
	cp $70
	call z, ShowSceneObject4
;> t = wSceneTimer
	ld a, [wSceneTimer]
;> pass                                 # these tests jump straight to the first star pair
	cp $80
	jp nc, Jump_002_63eb

	cp $70
	jp nc, Jump_002_63a0

;> pass                                 # below that runs for t; from there it falls through
	cp $60
	jp nc, Jump_002_6354

	cp $40
	jp nc, Jump_002_6309

;> if t < 0x40:                         # pair A: star 0, sparkle 6
;>     hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;>     wSceneObjects[1] -= 2
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
;>     wSceneObjects[2] += 2
	ld a, [$c0da]
	add $02
	ld [$c0da], a
;>     if wSceneObjects[1] == 0x10:
;>         ShowSceneObject1()
	ld a, [$c0d9]
	cp $10
	call z, ShowSceneObject1
;>     if wSceneObjects[1] == 0:
;>         HideSceneObject0()
	ld a, [$c0d9]
	or a
	call z, HideSceneObject0
;>     hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 6)
	ld hl, $c0de
	call UpdateSceneObject
;> if 0x10 <= t < 0x60:                 # pair B: star 12, sparkle 18
	ld a, [wSceneTimer]
	cp $10
	jp c, Jump_002_6479

Jump_002_6309:
;>     hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 12)
	ld hl, $c0e4
	call UpdateSceneObject
;>     wSceneObjects[13] -= 2
	ld a, [$c0e5]
	sub $02
	ld [$c0e5], a
;>     wSceneObjects[14] += 2
	ld a, [$c0e6]
	add $02
	ld [$c0e6], a
;>     if wSceneObjects[13] == 0x60:
;>         ShowSceneObject3()
	ld a, [$c0e5]
	cp $60
	call z, ShowSceneObject3
;>     if wSceneObjects[13] == 0:
;>         HideSceneObject2()
	ld a, [$c0e5]
	or a
	call z, HideSceneObject2
;>     hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 18)
	ld hl, $c0ea
	call UpdateSceneObject
;> if 0x20 <= t < 0x70:                 # pair C: star 24, sparkle 30
	ld a, [wSceneTimer]
	cp $20
	jp c, Jump_002_6479

Jump_002_6354:
;>     hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 24)
	ld hl, $c0f0
	call UpdateSceneObject
;>     wSceneObjects[25] -= 2
	ld a, [$c0f1]
	sub $02
	ld [$c0f1], a
;>     wSceneObjects[26] += 2
	ld a, [$c0f2]
	add $02
	ld [$c0f2], a
;>     if wSceneObjects[25] == 0x70:
;>         ShowSceneObject5()
	ld a, [$c0f1]
	cp $70
	call z, ShowSceneObject5
;>     if wSceneObjects[25] == 0x30:
;>         HideSceneObject4()
	ld a, [$c0f1]
	cp $30
	call z, HideSceneObject4
;>     hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 30)
	ld hl, $c0f6
	call UpdateSceneObject
;> if 0x30 <= t < 0x80:                 # pair A again
	ld a, [wSceneTimer]
	cp $30
	jp c, Jump_002_6479

Jump_002_63a0:
;>     hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;>     wSceneObjects[1] -= 2
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
;>     wSceneObjects[2] += 2
	ld a, [$c0da]
	add $02
	ld [$c0da], a
;>     if wSceneObjects[1] == 0x10:
;>         ShowSceneObject1()
	ld a, [$c0d9]
	cp $10
	call z, ShowSceneObject1
;>     if wSceneObjects[1] == 0:
;>         HideSceneObject0()
	ld a, [$c0d9]
	or a
	call z, HideSceneObject0
;>     hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 6)
	ld hl, $c0de
	call UpdateSceneObject
;> if t >= 0x50:                        # pair B again
	ld a, [wSceneTimer]
	cp $50
	jp c, Jump_002_6479

Jump_002_63eb:
;>     hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 12)
	ld hl, $c0e4
	call UpdateSceneObject
;>     wSceneObjects[13] -= 2
	ld a, [$c0e5]
	sub $02
	ld [$c0e5], a
;>     wSceneObjects[14] += 2
	ld a, [$c0e6]
	add $02
	ld [$c0e6], a
;>     if wSceneObjects[13] == 0x70:
;>         ShowSceneObject3()
	ld a, [$c0e5]
	cp $70
	call z, ShowSceneObject3
;>     if wSceneObjects[13] == 0x30:
;>         HideSceneObject2()
	ld a, [$c0e5]
	cp $30
	call z, HideSceneObject2
;>     hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 18)
	ld hl, $c0ea
	call UpdateSceneObject
;> if t >= 0x60:                        # pair C again
	ld a, [wSceneTimer]
	cp $60
	jr c, jr_002_6479

;>     hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 24)
	ld hl, $c0f0
	call UpdateSceneObject
;>     wSceneObjects[25] -= 2
	ld a, [$c0f1]
	sub $02
	ld [$c0f1], a
;>     wSceneObjects[26] += 2
	ld a, [$c0f2]
	add $02
	ld [$c0f2], a
;>     if wSceneObjects[13] == 0x20:
;>         ShowSceneObject5()
	ld a, [$c0e5]
	cp $20
	call z, ShowSceneObject5
;>     if wSceneObjects[25] == 0:
;>         HideSceneObject4()
	ld a, [$c0f1]
	or a
	call z, HideSceneObject4
;>     hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 30)
	ld hl, $c0f6
	call UpdateSceneObject

Jump_002_6479:
jr_002_6479:
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 0xB4:
	ld a, [wSceneTimer]
	cp $b4
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def ShootingStarPause()
;@ path: event/shooting-star
;@ Waits 170 frames.
ShootingStarPause::
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 0xAA:
	ld a, [wSceneTimer]
	cp $aa
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def ShootingStarWaitPhase0()
;@ path: event/shooting-star
;@ Waits until the field clock's phase ((wFieldTimer * 3 / 32) mod 32) is 0.
ShootingStarWaitPhase0::
;> n = wFieldTimer
	ld a, [wFieldTimer]
	ld l, a
	ld a, [wFieldTimer + 1]
	ld h, a
;> n = u16(n * 3)
	ld c, l
	ld b, h
	add hl, hl
	add hl, bc
;> n >>= 3
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
;> n >>= 2
	srl h
	rr l
	srl h
	rr l
;> phase = n & 0x1F                    # the field clock's 32-step phase
	ld a, l
	and $1f
;> if phase != 0:
;>     return
	ret nz

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def ShootingStarWaitPhase15()
;@ path: event/shooting-star
;@ Waits until the field clock's phase is 15, then sets up two stars (objects 0 and 12, the second
;@ hidden).
ShootingStarWaitPhase15::
;> n = wFieldTimer
	ld a, [wFieldTimer]
	ld l, a
	ld a, [wFieldTimer + 1]
	ld h, a
;> n = u16(n * 3)
	ld c, l
	ld b, h
	add hl, hl
	add hl, bc
;> n >>= 3
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
;> n >>= 2
	srl h
	rr l
	srl h
	rr l
;> phase = n & 0x1F                    # the field clock's 32-step phase
	ld a, l
	and $1f
;> if phase != 0x0F:
	cp $0f
;>     return
	ret nz

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> InitStarMiddle(wSceneObjects)
	ld hl, wSceneObjects
	call InitStarMiddle
;> InitStarLeft(wSceneObjects + 12)
	ld hl, $c0e4
	call InitStarLeft
;> HideSceneObject2()
	call HideSceneObject2
;> ShowSceneObject0()
	call ShowSceneObject0
	ret


;@ def ShootingStarCross()
;@ path: event/shooting-star
;@ Two pairs cross the sky: pair A (objects 0/6, drawn mirrored, attribute $22) flies to the right
;@ and down (X + 2, Y + 2), pair B (12/18) to the left. A runs before frame $30 and again from $30,
;@ B from $10 to $3F and again from $40; new stars are set up at frames $30 and $40. After 180
;@ frames six rising stars are set up.
ShootingStarCross::
;> if wSceneTimer == 0x30:
;>     InitStarHighLeft(wSceneObjects)
	ld a, [wSceneTimer]
	cp $30
	ld hl, wSceneObjects
	call z, InitStarHighLeft
;> if wSceneTimer == 0x40:
;>     InitStarHighRight(wSceneObjects + 12)
	ld a, [wSceneTimer]
	cp $40
	ld hl, $c0e4
	call z, InitStarHighRight
;> if wSceneTimer == 0x30:
;>     HideSceneObject0()
	ld a, [wSceneTimer]
	cp $30
	call z, HideSceneObject0
;> if wSceneTimer == 0x40:
;>     HideSceneObject2()
	ld a, [wSceneTimer]
	cp $40
	call z, HideSceneObject2
;> if wSceneTimer == 0x30:
;>     InitSparkleRight(wSceneObjects + 6)
	ld a, [wSceneTimer]
	cp $30
	ld hl, $c0de
	call z, InitSparkleRight
;> if wSceneTimer == 0x40:
;>     InitSparkleLeft(wSceneObjects + 18)
	ld a, [wSceneTimer]
	cp $40
	ld hl, $c0ea
	call z, InitSparkleLeft
;> if wSceneTimer == 0x10:
;>     ShowSceneObject2()
	ld a, [wSceneTimer]
	cp $10
	call z, ShowSceneObject2
;> if wSceneTimer == 0x30:
;>     ShowSceneObject0()
	ld a, [wSceneTimer]
	cp $30
	call z, ShowSceneObject0
;> if wSceneTimer == 0x40:
;>     ShowSceneObject2()
	ld a, [wSceneTimer]
	cp $40
	call z, ShowSceneObject2
;> t = wSceneTimer
	ld a, [wSceneTimer]
;> pass                                 # these tests jump straight to the first star pair that
	cp $40
	jp nc, Jump_002_6604

;> pass                                 # runs for t; from there it falls through
	cp $30
	jr nc, jr_002_65b9

;> if t < 0x30:                         # pair A: star 0 flying right, sparkle 6
;>     hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x22
	ld a, $22
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;>     wSceneObjects[1] += 2
	ld a, [$c0d9]
	add $02
	ld [$c0d9], a
;>     wSceneObjects[2] += 2
	ld a, [$c0da]
	add $02
	ld [$c0da], a
;>     if wSceneObjects[1] == 0x90:
;>         ShowSceneObject1()
	ld a, [$c0d9]
	cp $90
	call z, ShowSceneObject1
;>     if wSceneObjects[1] == 0xB0:
;>         HideSceneObject0()
	ld a, [$c0d9]
	cp $b0
	call z, HideSceneObject0
;>     hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x22
	ld a, $22
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 6)
	ld hl, $c0de
	call UpdateSceneObject
;> if 0x10 <= t < 0x40:                 # pair B: star 12, sparkle 18
	ld a, [wSceneTimer]
	cp $10
	jp c, Jump_002_6692

jr_002_65b9:
;>     hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 12)
	ld hl, $c0e4
	call UpdateSceneObject
;>     wSceneObjects[13] -= 2
	ld a, [$c0e5]
	sub $02
	ld [$c0e5], a
;>     wSceneObjects[14] += 2
	ld a, [$c0e6]
	add $02
	ld [$c0e6], a
;>     if wSceneObjects[13] == 0x10:
;>         ShowSceneObject3()
	ld a, [$c0e5]
	cp $10
	call z, ShowSceneObject3
;>     if wSceneObjects[13] == 0:
;>         HideSceneObject2()
	ld a, [$c0e5]
	or a
	call z, HideSceneObject2
;>     hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 18)
	ld hl, $c0ea
	call UpdateSceneObject
;> if t >= 0x30:                        # pair A again
	ld a, [wSceneTimer]
	cp $30
	jp c, Jump_002_6692

Jump_002_6604:
;>     hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x22
	ld a, $22
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;>     wSceneObjects[1] += 2
	ld a, [$c0d9]
	add $02
	ld [$c0d9], a
;>     wSceneObjects[2] += 2
	ld a, [$c0da]
	add $02
	ld [$c0da], a
;>     if wSceneObjects[1] == 0x80:
;>         ShowSceneObject1()
	ld a, [$c0d9]
	cp $80
	call z, ShowSceneObject1
;>     if wSceneObjects[1] == 0xB0:
;>         HideSceneObject0()
	ld a, [$c0d9]
	cp $b0
	call z, HideSceneObject0
;>     hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x22
	ld a, $22
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 6)
	ld hl, $c0de
	call UpdateSceneObject
;> if t >= 0x40:                        # pair B again
	ld a, [wSceneTimer]
	cp $40
	jr c, jr_002_6692

;>     hSpriteSet = 0x00
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 12)
	ld hl, $c0e4
	call UpdateSceneObject
;>     wSceneObjects[13] -= 2
	ld a, [$c0e5]
	sub $02
	ld [$c0e5], a
;>     wSceneObjects[14] += 2
	ld a, [$c0e6]
	add $02
	ld [$c0e6], a
;>     if wSceneObjects[13] == 0x20:
;>         ShowSceneObject3()
	ld a, [$c0e5]
	cp $20
	call z, ShowSceneObject3
;>     if wSceneObjects[13] == 0:
;>         HideSceneObject2()
	ld a, [$c0e5]
	or a
	call z, HideSceneObject2
;>     hSpriteSet = 0x01
	ld a, $01
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x74
	ld a, $74
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 18)
	ld hl, $c0ea
	call UpdateSceneObject

Jump_002_6692:
jr_002_6692:
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 0xB4:
	ld a, [wSceneTimer]
	cp $b4
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> InitRisingStars(wSceneObjects)
	ld hl, wSceneObjects
	call InitRisingStars
	ret


;@ def ShootingStarRise()
;@ path: event/shooting-star
;@ Six stars (objects 0, 6, 12, 18, 24, 30, script 5) rise from the bottom of the screen, 2 pixels a
;@ frame, each hidden when it leaves the top (Y >= $F0); they are let go one after another at frames
;@ $14, $28, $3C, $50 and $64. Ends after 180 frames.
ShootingStarRise::
;> if wSceneObjects[6] == 0:
	ld a, [$c0de]
	or a
	jr nz, jr_002_66df

;>     hSpriteSet = 0x05
	ld a, $05
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 6)
	ld hl, $c0de
	call UpdateSceneObject
;>     wSceneObjects[8] -= 2
	ld a, [$c0e0]
	sub $02
	ld [$c0e0], a
;>     if wSceneTimer == 0x14:
	ld a, [wSceneTimer]
	cp $14
	jr nz, jr_002_66d5

;>         ShowSceneObject5()
	call ShowSceneObject5

jr_002_66d5:
;>     if wSceneObjects[8] >= 0xF0:
	ld a, [$c0e0]
	cp $f0
	jr c, jr_002_66df

;>         HideSceneObject1()
	call HideSceneObject1

jr_002_66df:
;> if wSceneObjects[30] == 0:
	ld a, [$c0f6]
	or a
	jr nz, jr_002_6713

;>     hSpriteSet = 0x05
	ld a, $05
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 30)
	ld hl, $c0f6
	call UpdateSceneObject
;>     wSceneObjects[32] -= 2
	ld a, [$c0f8]
	sub $02
	ld [$c0f8], a
;>     if wSceneTimer == 0x28:
	ld a, [wSceneTimer]
	cp $28
	jr nz, jr_002_6709

;>         ShowSceneObject3()
	call ShowSceneObject3

jr_002_6709:
;>     if wSceneObjects[32] >= 0xF0:
	ld a, [$c0f8]
	cp $f0
	jr c, jr_002_6713

;>         HideSceneObject5()
	call HideSceneObject5

jr_002_6713:
;> if wSceneObjects[18] == 0:
	ld a, [$c0ea]
	or a
	jr nz, jr_002_6747

;>     hSpriteSet = 0x05
	ld a, $05
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 18)
	ld hl, $c0ea
	call UpdateSceneObject
;>     wSceneObjects[20] -= 2
	ld a, [wVSTeam]
	sub $02
	ld [wVSTeam], a
;>     if wSceneTimer == 0x3C:
	ld a, [wSceneTimer]
	cp $3c
	jr nz, jr_002_673d

;>         ShowSceneObject2()
	call ShowSceneObject2

jr_002_673d:
;>     if wSceneObjects[20] >= 0xF0:
	ld a, [wVSTeam]
	cp $f0
	jr c, jr_002_6747

;>         HideSceneObject3()
	call HideSceneObject3

jr_002_6747:
;> if wSceneObjects[12] == 0:
	ld a, [$c0e4]
	or a
	jr nz, jr_002_677b

;>     hSpriteSet = 0x05
	ld a, $05
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 12)
	ld hl, $c0e4
	call UpdateSceneObject
;>     wSceneObjects[14] -= 2
	ld a, [$c0e6]
	sub $02
	ld [$c0e6], a
;>     if wSceneTimer == 0x50:
	ld a, [wSceneTimer]
	cp $50
	jr nz, jr_002_6771

;>         ShowSceneObject4()
	call ShowSceneObject4

jr_002_6771:
;>     if wSceneObjects[14] >= 0xF0:
	ld a, [$c0e6]
	cp $f0
	jr c, jr_002_677b

;>         HideSceneObject2()
	call HideSceneObject2

jr_002_677b:
;> if wSceneObjects[24] == 0:
	ld a, [$c0f0]
	or a
	jr nz, jr_002_67af

;>     hSpriteSet = 0x05
	ld a, $05
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects + 24)
	ld hl, $c0f0
	call UpdateSceneObject
;>     wSceneObjects[26] -= 2
	ld a, [$c0f2]
	sub $02
	ld [$c0f2], a
;>     if wSceneTimer == 0x64:
	ld a, [wSceneTimer]
	cp $64
	jr nz, jr_002_67a5

;>         ShowSceneObject0()
	call ShowSceneObject0

jr_002_67a5:
;>     if wSceneObjects[26] >= 0xF0:
	ld a, [$c0f2]
	cp $f0
	jr c, jr_002_67af

;>         HideSceneObject4()
	call HideSceneObject4

jr_002_67af:
;> if wSceneObjects == 0:
	ld a, [wSceneObjects]
	or a
	jr nz, jr_002_67d9

;>     hSpriteSet = 0x05
	ld a, $05
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0x70
	ld a, $70
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0x02
	ld a, $02
	ldh [hSpriteAttr], a
;>     UpdateSceneObject(wSceneObjects)
	ld hl, wSceneObjects
	call UpdateSceneObject
;>     wSceneObjects[2] -= 2
	ld a, [$c0da]
	sub $02
	ld [$c0da], a
;>     if wSceneObjects[2] >= 0xF0:
	ld a, [$c0da]
	cp $f0
	jr c, jr_002_67d9

;>         HideSceneObject0()
	call HideSceneObject0

jr_002_67d9:
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> if wSceneTimer < 0xB4:
	ld a, [wSceneTimer]
	cp $b4
;>     return
	ret c

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def ShootingStarWaitPhase16()
;@ path: event/shooting-star
;@ Waits until the field clock's phase is 16, then advances wShootingStarStage.
ShootingStarWaitPhase16::
;> n = wFieldTimer
	ld a, [wFieldTimer]
	ld l, a
	ld a, [wFieldTimer + 1]
	ld h, a
;> n = u16(n * 3)
	ld c, l
	ld b, h
	add hl, hl
	add hl, bc
;> n >>= 3
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
;> n >>= 2
	srl h
	rr l
	srl h
	rr l
;> phase = n & 0x1F                    # the field clock's 32-step phase
	ld a, l
	and $1f
;> if phase != 0x10:
	cp $10
;>     return
	ret nz

;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
;> wShootingStarStage += 1
	ld hl, wShootingStarStage
	inc [hl]
	ret


;@ def ShootingStarFlash()
;@ path: event/shooting-star
;@ Three flashes: the Game Boy palettes switch to all-light ($00 / $FF) and back ($C1 / $D2) every
;@ 6 frames.
ShootingStarFlash::
;> wSceneTimer += 1
	ld hl, wSceneTimer
	inc [hl]
;> wBGP = 0x00
	ld a, $00
	ld [wBGP], a
;> wOBP0 = 0xFF
	ld a, $ff
	ld [wOBP0], a
;> if wSceneTimer < 0x06:
	ld a, [wSceneTimer]
	cp $06
;>     return
	ret c

;> wBGP = 0xC1
	ld a, $c1
	ld [wBGP], a
;> wOBP0 = 0xD2
	ld a, $d2
	ld [wOBP0], a
;> if wSceneTimer < 0x0C:
	ld a, [wSceneTimer]
	cp $0c
;>     return
	ret c

;> wBGP = 0x00
	ld a, $00
	ld [wBGP], a
;> wOBP0 = 0xFF
	ld a, $ff
	ld [wOBP0], a
;> if wSceneTimer < 0x12:
	ld a, [wSceneTimer]
	cp $12
;>     return
	ret c

;> wBGP = 0xC1
	ld a, $c1
	ld [wBGP], a
;> wOBP0 = 0xD2
	ld a, $d2
	ld [wOBP0], a
;> if wSceneTimer < 0x18:
	ld a, [wSceneTimer]
	cp $18
;>     return
	ret c

;> wBGP = 0x00
	ld a, $00
	ld [wBGP], a
;> wOBP0 = 0xFF
	ld a, $ff
	ld [wOBP0], a
;> if wSceneTimer < 0x1E:
	ld a, [wSceneTimer]
	cp $1e
;>     return
	ret c

;> wBGP = 0xC1
	ld a, $c1
	ld [wBGP], a
;> wOBP0 = 0xD2
	ld a, $d2
	ld [wOBP0], a
;> wSceneTimer = 0
	xor a
	ld [wSceneTimer], a
;> wSceneStep += 1
	ld hl, wSceneStep
	inc [hl]
	ret


;@ def ShootingStarEnd()
;@ path: event/shooting-star
;@ End of the event: fades out (speed 3), asks for the map to be loaded again and moves the story on
;@ to step 8.
ShootingStarEnd::
;> wSceneStep = 0
	xor a
	ld [wSceneStep], a
;> wSceneObjects[0] = 0
	xor a
	ld [wSceneObjects], a
;> StartFade(3)
	ld a, $03
	call StartFade
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
;> wShootingStarStage = 0
	xor a
	ld [wShootingStarStage], a
;> wStoryStep = 0x08
	ld a, $08
	ld [wStoryStep], a
	ret


;@ def InitStarHighRight(obj: hl)
;@ path: event/shooting-star
;@ Sets up a star at X $80, Y 0 (shown) and its sparkle after it, hidden at X $50, Y $30.
;@ Objects are 6 bytes: hidden, X, Y, pose, script step, frames left.
InitStarHighRight::
;> mem[obj + 0:obj + 3] = [0x00, 0x80, 0x00]
	ld a, $00
	ld [hli], a
	ld a, $80
	ld [hli], a
	ld a, $00
	ld [hli], a
;> mem[obj + 3:obj + 6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> mem[obj + 6:obj + 9] = [0x01, 0x50, 0x30]
	ld a, $01
	ld [hli], a
	ld a, $50
	ld [hli], a
	ld a, $30
	ld [hli], a
;> mem[obj + 9:obj + 12] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def InitStarHighLeft(obj: hl)
;@ path: event/shooting-star
;@ Sets up a star at X $20, Y 0 (shown) and its sparkle after it, hidden at X $50, Y $30.
;@ Objects are 6 bytes: hidden, X, Y, pose, script step, frames left.
InitStarHighLeft::
;> mem[obj + 0:obj + 3] = [0x00, 0x20, 0x00]
	ld a, $00
	ld [hli], a
	ld a, $20
	ld [hli], a
	ld a, $00
	ld [hli], a
;> mem[obj + 3:obj + 6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> mem[obj + 6:obj + 9] = [0x01, 0x50, 0x30]
	ld a, $01
	ld [hli], a
	ld a, $50
	ld [hli], a
	ld a, $30
	ld [hli], a
;> mem[obj + 9:obj + 12] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def InitSparkleLow(obj: hl)
;@ path: event/shooting-star
;@ Sets up a hidden sparkle at X $70, Y $10.
;@ Objects are 6 bytes: hidden, X, Y, pose, script step, frames left.
InitSparkleLow::
;> mem[obj + 0:obj + 3] = [0x01, 0x70, 0x10]
	ld a, $01
	ld [hli], a
	ld a, $70
	ld [hli], a
	ld a, $10
	ld [hli], a
;> mem[obj + 3:obj + 6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def UnusedInitSparkle(obj: hl)
;@ path: event/shooting-star
;@ Sets up a hidden sparkle at X $30, Y $10. Nothing calls it.
;@ Objects are 6 bytes: hidden, X, Y, pose, script step, frames left.
UnusedInitSparkle::
;> mem[obj + 0:obj + 3] = [0x01, 0x30, 0x10]
	ld a, $01
	ld [hli], a
	ld a, $30
	ld [hli], a
	ld a, $10
	ld [hli], a
;> mem[obj + 3:obj + 6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> return
	ret

;@ def InitSparkleLeft(obj: hl)
;@ path: event/shooting-star
;@ Sets up a hidden sparkle at X $30, Y $50.
;@ Objects are 6 bytes: hidden, X, Y, pose, script step, frames left.
InitSparkleLeft::
;> mem[obj + 0:obj + 3] = [0x01, 0x30, 0x50]
	ld a, $01
	ld [hli], a
	ld a, $30
	ld [hli], a
	ld a, $50
	ld [hli], a
;> mem[obj + 3:obj + 6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def InitSparkleRight(obj: hl)
;@ path: event/shooting-star
;@ Sets up a hidden sparkle at X $70, Y $50.
;@ Objects are 6 bytes: hidden, X, Y, pose, script step, frames left.
InitSparkleRight::
;> mem[obj + 0:obj + 3] = [0x01, 0x70, 0x50]
	ld a, $01
	ld [hli], a
	ld a, $70
	ld [hli], a
	ld a, $50
	ld [hli], a
;> mem[obj + 3:obj + 6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def InitStarLeft(obj: hl)
;@ path: event/shooting-star
;@ Sets up a star at X $40, Y 0 (shown) and its sparkle after it, hidden at X $20, Y $20.
;@ Objects are 6 bytes: hidden, X, Y, pose, script step, frames left.
InitStarLeft::
;> mem[obj + 0:obj + 3] = [0x00, 0x40, 0x00]
	ld a, $00
	ld [hli], a
	ld a, $40
	ld [hli], a
	ld a, $00
	ld [hli], a
;> mem[obj + 3:obj + 6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> mem[obj + 6:obj + 9] = [0x01, 0x20, 0x20]
	ld a, $01
	ld [hli], a
	ld a, $20
	ld [hli], a
	ld a, $20
	ld [hli], a
;> mem[obj + 9:obj + 12] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def InitStarMiddle(obj: hl)
;@ path: event/shooting-star
;@ Sets up a star at X $60, Y 0 (shown) and its sparkle after it, hidden at X $80, Y $20.
;@ Objects are 6 bytes: hidden, X, Y, pose, script step, frames left.
InitStarMiddle::
;> mem[obj + 0:obj + 3] = [0x00, 0x60, 0x00]
	ld a, $00
	ld [hli], a
	ld a, $60
	ld [hli], a
	ld a, $00
	ld [hli], a
;> mem[obj + 3:obj + 6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> mem[obj + 6:obj + 9] = [0x01, 0x80, 0x20]
	ld a, $01
	ld [hli], a
	ld a, $80
	ld [hli], a
	ld a, $20
	ld [hli], a
;> mem[obj + 9:obj + 12] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def InitStarFarRight(obj: hl)
;@ path: event/shooting-star
;@ Sets up a star at X $A0, Y $30 (shown) and its sparkle after it, hidden at X $80, Y $50.
;@ Objects are 6 bytes: hidden, X, Y, pose, script step, frames left.
InitStarFarRight::
;> mem[obj + 0:obj + 3] = [0x00, 0xA0, 0x30]
	ld a, $00
	ld [hli], a
	ld a, $a0
	ld [hli], a
	ld a, $30
	ld [hli], a
;> mem[obj + 3:obj + 6] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> mem[obj + 6:obj + 9] = [0x01, 0x80, 0x50]
	ld a, $01
	ld [hli], a
	ld a, $80
	ld [hli], a
	ld a, $50
	ld [hli], a
;> mem[obj + 9:obj + 12] = [0x00, 0x00, 0x02]
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def InitRisingStars(obj: hl)
;@ path: event/shooting-star
;@ Sets up six stars along the bottom (Y $90) at X 8, $18, $28, $78, $88, $98, pose 1; only the
;@ second is shown at first.
;@ Objects are 6 bytes: hidden, X, Y, pose, script step, frames left.
InitRisingStars::
;> mem[obj + 0:obj + 3] = [0x01, 0x08, 0x90]
	ld a, $01
	ld [hli], a
	ld a, $08
	ld [hli], a
	ld a, $90
	ld [hli], a
;> mem[obj + 3:obj + 6] = [0x01, 0x00, 0x02]
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> mem[obj + 6:obj + 9] = [0x00, 0x18, 0x90]
	ld a, $00
	ld [hli], a
	ld a, $18
	ld [hli], a
	ld a, $90
	ld [hli], a
;> mem[obj + 9:obj + 12] = [0x01, 0x00, 0x02]
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> mem[obj + 12:obj + 15] = [0x01, 0x28, 0x90]
	ld a, $01
	ld [hli], a
	ld a, $28
	ld [hli], a
	ld a, $90
	ld [hli], a
;> mem[obj + 15:obj + 18] = [0x01, 0x00, 0x02]
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> mem[obj + 18:obj + 21] = [0x01, 0x78, 0x90]
	ld a, $01
	ld [hli], a
	ld a, $78
	ld [hli], a
	ld a, $90
	ld [hli], a
;> mem[obj + 21:obj + 24] = [0x01, 0x00, 0x02]
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> mem[obj + 24:obj + 27] = [0x01, 0x88, 0x90]
	ld a, $01
	ld [hli], a
	ld a, $88
	ld [hli], a
	ld a, $90
	ld [hli], a
;> mem[obj + 27:obj + 30] = [0x01, 0x00, 0x02]
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> mem[obj + 30:obj + 33] = [0x01, 0x98, 0x90]
	ld a, $01
	ld [hli], a
	ld a, $98
	ld [hli], a
	ld a, $90
	ld [hli], a
;> mem[obj + 33:obj + 36] = [0x01, 0x00, 0x02]
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def ShowSceneObject0()
;@ path: event/cutscene
;@ Shows scene object 0 (clears its hidden flag).
ShowSceneObject0::
;> wSceneObjects[0] = 0
	ld a, $00
	ld [wSceneObjects], a
	ret


;@ def ShowSceneObject1()
;@ path: event/cutscene
;@ Shows the scene object at offset 6.
ShowSceneObject1::
;> wSceneObjects[6] = 0
	ld a, $00
	ld [$c0de], a
	ret


;@ def ShowSceneObject2()
;@ path: event/cutscene
;@ Shows the scene object at offset 12.
ShowSceneObject2::
;> wSceneObjects[12] = 0
	ld a, $00
	ld [$c0e4], a
	ret


;@ def ShowSceneObject3()
;@ path: event/cutscene
;@ Shows the scene object at offset 18.
ShowSceneObject3::
;> wSceneObjects[18] = 0
	ld a, $00
	ld [$c0ea], a
	ret


;@ def ShowSceneObject4()
;@ path: event/cutscene
;@ Shows the scene object at offset 24.
ShowSceneObject4::
;> wSceneObjects[24] = 0
	ld a, $00
	ld [$c0f0], a
	ret


;@ def ShowSceneObject5()
;@ path: event/cutscene
;@ Shows the scene object at offset 30.
ShowSceneObject5::
;> wSceneObjects[30] = 0
	ld a, $00
	ld [$c0f6], a
	ret


;@ def HideSceneObject0()
;@ path: event/cutscene
;@ Hides scene object 0 (sets its hidden flag).
HideSceneObject0::
;> wSceneObjects[0] = 1
	ld a, $01
	ld [wSceneObjects], a
	ret


;@ def HideSceneObject1()
;@ path: event/cutscene
;@ Hides the scene object at offset 6.
HideSceneObject1::
;> wSceneObjects[6] = 1
	ld a, $01
	ld [$c0de], a
	ret


;@ def HideSceneObject2()
;@ path: event/cutscene
;@ Hides the scene object at offset 12.
HideSceneObject2::
;> wSceneObjects[12] = 1
	ld a, $01
	ld [$c0e4], a
	ret


;@ def HideSceneObject3()
;@ path: event/cutscene
;@ Hides the scene object at offset 18.
HideSceneObject3::
;> wSceneObjects[18] = 1
	ld a, $01
	ld [$c0ea], a
	ret


;@ def HideSceneObject4()
;@ path: event/cutscene
;@ Hides the scene object at offset 24.
HideSceneObject4::
;> wSceneObjects[24] = 1
	ld a, $01
	ld [$c0f0], a
	ret


;@ def HideSceneObject5()
;@ path: event/cutscene
;@ Hides the scene object at offset 30.
HideSceneObject5::
;> wSceneObjects[30] = 1
	ld a, $01
	ld [$c0f6], a
	ret


;@ def FillWordPattern(dest: hl, count: bc, pattern: de)
;@ path: gfx/tiles
;@ Writes the two bytes d, e count times from dest on (fills tile rows with one 2-bit pattern).
FillWordPattern::
;> while True:
;>     mem[dest] = pattern >> 8; mem[dest + 1] = pattern & 0xFF; dest += 2
	ld a, d
	ld [hli], a
	ld a, e
	ld [hli], a
;>     count -= 1
	dec bc
;>     if count == 0:
	ld a, b
	or c
	jr nz, FillWordPattern

;>         return
	ret


;@ def DrawSceneSprite()
;@ path: event/cutscene
;@ Draws a cutscene metasprite: hSpriteSet picks the set in SceneSpriteSets, hSpriteFrame the
;@ frame, at hSpriteX/hSpriteY.
DrawSceneSprite::
;> DrawMetasprite(SceneSpriteSets)
	ld de, SceneSpriteSets
	call DrawMetasprite
	ret


;@ def SceneSpriteSets()
;@ path: event/cutscene
;@ Six pointers to the metasprite frame lists of the cutscene sprite sets (0 star, 1 sparkle,
;@ 2-4 the figure's poses, 5 rising star; see SceneSprites). The code after the table is far
;@ entry 4 of this bank (FarTable_02 points here + 12): it updates and draws the object whose
;@ address is in wSceneStep/wSceneTimer, for callers in other banks.
;@ test: skip the label is the table; only the code after it runs
SceneSpriteSets::
	dw SceneSprites + $13, SceneSprites + $170, SceneSprites + $2a9
	dw SceneSprites + $2a9, SceneSprites + $2a9, SceneSprites + $13

;> obj = wSceneStep | wSceneTimer << 8
	ld a, [wSceneStep]
	ld l, a
	ld a, [wSceneTimer]
	ld h, a

;> UpdateSceneObject(obj)               # falls through

;@ def UpdateSceneObject(obj: hl)
;@ path: event/cutscene
;@ Draws a cutscene object (unless it is hidden) and runs its animation script: when the pose's
;@ frames are used up the next script entry (SceneObjectScripts[hSpriteSet]) is loaded; $FF hides
;@ the object, $FE starts the script over.
UpdateSceneObject::
;> wSceneObjectPtr = obj
	ld a, l
	ld [wSceneObjectPtr], a
	ld a, h
	ld [wSceneObjectPtr + 1], a
;> if mem[obj] != 0:
	ld a, [hli]
	or a
;>     return                           # hidden
	ret nz

;> hSpriteClip = 0                      # (and the high bytes of hSpriteX and hSpriteY)
	xor a
	ldh [hSpriteX + 1], a
	ldh [hSpriteY + 1], a
	ldh [hSpriteClip], a
;> hSpriteX = mem[obj + 1]               # its high byte was cleared above
	ld a, [hli]
	ldh [hSpriteX], a
;> hSpriteY = mem[obj + 2]
	ld a, [hli]
	ldh [hSpriteY], a
;> hSpriteFrame = mem[obj + 3]
	ld a, [hli]
	ldh [hSpriteFrame], a
;> DrawSceneSprite()
	call DrawSceneSprite
;> left = wSceneObjectPtr
	ld a, [wSceneObjectPtr]
	ld l, a
	ld a, [wSceneObjectPtr + 1]
	ld h, a
;> left += 5
	ld a, $05
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[left] -= 1
	ld e, l
	ld d, h
	ld a, [de]
	dec a
	ld [de], a
;> if mem[left] != 0:
	or a
;>     return
	ret nz

;> mem[left - 1] += 1                   # next script step
	dec de
	ld a, [de]
	inc a
	ld [de], a
;> script = GetTableEntry(SceneObjectScripts, hSpriteSet)
	ld hl, SceneObjectScripts
	ldh a, [hSpriteSet]
	call GetTableEntry
;> step = mem[left - 1]
	ld a, [de]
	dec de
;> entry = script + (2 * step & 0xFF)
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> if mem[entry] == 0xFF:
	ld a, [hl]
	cp $ff
	jr z, .hide

;>@hide     mem[wSceneObjectPtr] = 1        # script over: hide
;>@hide2     return
;> elif mem[entry] == 0xFE:
	cp $fe
	jr z, .restart

;>@r1     script = GetTableEntry(SceneObjectScripts, hSpriteSet)
;>@r2     mem[left - 2] = mem[script]       # first pose
;>@r3     mem[left - 1] = 0
;>@r4     mem[left] = mem[script + 1]
;> else:
;>     mem[left - 2] = mem[entry]       # pose
	ld a, [hli]
	ld [de], a
;>     mem[left] = mem[entry + 1]       # its frames
	inc de
	inc de
	ld a, [hl]
	ld [de], a
	ret

.hide
;=@hide
	ld a, [wSceneObjectPtr]
	ld l, a
	ld a, [wSceneObjectPtr + 1]
	ld h, a
	ld a, $01
	ld [hl], a
;=@hide2
	ret

.restart
;=@r1
	ld hl, SceneObjectScripts
	ldh a, [hSpriteSet]
	call GetTableEntry
	xor a
	add a
	add l
;=@r1
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@r2
	ld a, [hli]
	ld [de], a
;=@r3
	inc de
	xor a
	ld [de], a
;=@r4
	inc de
	ld a, [hl]
	ld [de], a
	ret


;@ def GetTableEntry(table: hl, index: a) -> hl
;@ path: data
;@ Returns entry `index` of a table of 16-bit words.
GetTableEntry::
;> p = table + (2 * index & 0xFF)
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> return mem16[p]
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret


;@ def GetAnimationFirstPose()
;@ path: gfx/animation
;@ Sets hSpriteFrame to the pose of an animation entry without stepping anything: wPlayerAnimPtr
;@ points to three bytes (set, animation, step) here.
GetAnimationFirstPose::
;> obj = wPlayerAnimPtr
	ld a, [wPlayerAnimPtr]
	ld c, a
	ld a, [wPlayerAnimPtr + 1]
	ld b, a
;> p = AnimationSets + (2 * mem[obj] & 0xFF)
	ld hl, AnimationSets
	ld a, [bc]
	add a
	add l
	ld l, a
;> animations = mem16[p]
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> p = animations + (2 * mem[obj + 1] & 0xFF)
	inc bc
	ld a, [bc]
	add a
	add l
	ld l, a
;> script = mem16[p]
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> step = mem[obj + 2]
	inc bc
	ld a, [bc]
;> p = script + (2 * step & 0xFF)
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> hSpriteFrame = mem[p]
	ld a, [hl]
	ldh [hSpriteFrame], a
	ret


;@ path: event/cutscene
;@ Metasprite frames of the cutscene sprite sets (SceneSpriteSets points into this block). A frame
;@ is a list of 4-byte sprites: Y offset, X offset, tile (added to hSpriteTileBase), attributes
;@ (XORed with hSpriteAttr), ended by $80. Each set is a table of frame pointers.
SceneSprites::
	db $f8, $f8, $00, $00, $f7, $00, $01, $00, $80, $f0, $f8, $02, $00, $f8, $f8, $03
	db $00, $80, $80, $39, $6b, $42, $6b, $4b, $6b, $e8, $18, $02, $00, $f8, $18, $02
	db $00, $f0, $10, $00, $00, $08, $10, $02, $00, $f4, $18, $02, $00, $f6, $1d, $02
	db $00, $ff, $15, $02, $00, $f0, $08, $02, $00, $10, $00, $02, $00, $00, $08, $01
	db $00, $00, $02, $01, $00, $08, $08, $02, $00, $0c, $04, $02, $00, $18, $08, $01
	db $00, $00, $f8, $02, $00, $10, $f0, $01, $00, $20, $f0, $02, $00, $16, $f3, $02
	db $00, $2b, $f2, $02, $00, $0c, $f4, $00, $00, $07, $f0, $02, $00, $1d, $f8, $01
	db $00, $f8, $00, $01, $00, $80, $f8, $18, $02, $00, $08, $18, $02, $00, $18, $10
	db $02, $00, $04, $18, $02, $00, $06, $1d, $02, $00, $0f, $15, $02, $00, $00, $08
	db $02, $00, $20, $00, $02, $00, $10, $08, $01, $00, $10, $02, $01, $00, $18, $08
	db $02, $00, $1c, $04, $02, $00, $28, $08, $01, $00, $10, $f8, $02, $00, $20, $f0
	db $01, $00, $30, $f0, $02, $00, $26, $f3, $02, $00, $3b, $f2, $02, $00, $17, $f0
	db $02, $00, $2d, $f8, $01, $00, $08, $00, $01, $00, $1c, $f4, $01, $00, $00, $10
	db $01, $00, $80, $08, $18, $02, $00, $28, $10, $02, $00, $14, $18, $02, $00, $16
	db $1d, $02, $00, $10, $08, $02, $00, $30, $00, $02, $00, $20, $08, $01, $00, $20
	db $02, $01, $00, $28, $08, $02, $00, $38, $08, $01, $00, $20, $f8, $02, $00, $30
	db $f0, $01, $00, $40, $f0, $02, $00, $36, $f3, $02, $00, $4b, $f2, $02, $00, $27
	db $f0, $02, $00, $3d, $f8, $01, $00, $2c, $f4, $01, $00, $80, $38, $10, $02, $00
	db $24, $18, $02, $00, $20, $08, $02, $00, $40, $00, $02, $00, $30, $08, $01, $00
	db $48, $08, $01, $00, $30, $f8, $02, $00, $50, $f0, $02, $00, $5b, $f2, $02, $00
	db $37, $f0, $02, $00, $4d, $f8, $01, $00, $80, $50, $00, $02, $00, $58, $08, $01
	db $00, $40, $f8, $02, $00, $60, $f0, $02, $00, $6b, $f2, $02, $00, $47, $f0, $02
	db $00, $5d, $f8, $01, $00, $80, $73, $f2, $02, $00, $65, $f8, $01, $00, $80, $80
	db $52, $6b, $af, $6b, $0c, $6c, $55, $6c, $82, $6c, $9f, $6c, $a8, $6c, $f0, $f0
	db $03, $00, $f0, $f8, $04, $00, $f8, $e8, $05, $00, $f8, $f0, $06, $00, $f8, $f8
	db $07, $00, $f0, $08, $03, $20, $f0, $00, $04, $20, $f8, $10, $05, $20, $f8, $08
	db $06, $20, $f8, $00, $07, $20, $80, $f0, $e8, $08, $00, $f0, $f0, $09, $00, $f0
	db $f8, $0a, $00, $f8, $e0, $0b, $00, $f8, $e8, $0c, $00, $f8, $f0, $07, $00, $f8
	db $f8, $07, $00, $f0, $10, $08, $20, $f0, $08, $09, $20, $f0, $00, $0a, $20, $f8
	db $18, $0b, $20, $f8, $10, $0c, $20, $f8, $08, $07, $20, $f8, $00, $07, $20, $80
	db $e0, $f0, $00, $00, $f0, $10, $00, $00, $f0, $e0, $00, $00, $e4, $d8, $00, $00
	db $ea, $07, $00, $00, $e8, $18, $00, $00, $e0, $f8, $01, $00, $e0, $08, $01, $00
	db $f8, $e8, $01, $00, $f8, $10, $01, $00, $80, $e0, $08, $01, $00, $f8, $10, $01
	db $00, $d8, $cd, $00, $00, $d6, $07, $00, $00, $ce, $f5, $01, $00, $f0, $25, $00
	db $00, $f7, $d5, $01, $00, $de, $f8, $00, $00, $ee, $e7, $02, $00, $e3, $df, $02
	db $00, $d7, $ee, $02, $00, $e4, $15, $02, $00, $e3, $24, $02, $00, $80, $d3, $c4
	db $00, $00, $c4, $ec, $01, $00, $f2, $cc, $01, $00, $d4, $ef, $00, $00, $e9, $de
	db $02, $00, $de, $d6, $02, $00, $cd, $e5, $02, $00, $cd, $0d, $01, $00, $ea, $15
	db $01, $00, $c3, $0c, $00, $00, $e2, $2a, $00, $00, $d6, $1a, $02, $00, $d0, $29
	db $02, $00, $80, $e9, $b6, $00, $00, $da, $de, $01, $00, $08, $be, $01, $00, $ea
	db $e1, $00, $00, $ff, $d0, $02, $00, $f4, $c8, $02, $00, $e3, $d7, $02, $00, $e6
	db $1a, $01, $00, $03, $22, $01, $00, $dc, $19, $00, $00, $fb, $37, $00, $00, $ef
	db $27, $02, $00, $e9, $36, $02, $00, $80, $80, $b7, $6c, $e0, $6c, $19, $6d, $42
	db $6d, $77, $6d, $ac, $6d, $e1, $6d

;@ path: event/cutscene
;@ Night sky over the hill for cutscene 0 (BG map 1). DrawTilemap format: a 2-byte VRAM offset,
;@ then tile numbers, $D8 = next row, $D9 = end. Mostly tile $0E (dark sky) with stars ($18-$20).
Cutscene0SkyTilemap::
	db $00, $00, $0e, $1e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $1e, $0e, $0e, $0e, $0e, $1a, $0e, $d8, $0e, $0e
	db $0e, $0e, $1a, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $18, $0e, $d8, $0e, $0e, $18, $0e, $0e, $18, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e
	db $1e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $1a, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $d8, $0e, $1a, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $d8, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20
	db $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $1c, $0e, $0e
	db $0e, $0e, $0e, $0e, $18, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $18, $0e, $0e, $d8
	db $0e, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $1a, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $20, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $d8, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $20, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $1c, $0e, $d8, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $20, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e
	db $0e, $0e, $1e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $1a, $0e, $d8, $0e, $1a, $0e, $0e, $0e, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $0e
	db $0e, $18, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20, $d8, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $d8, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $d8, $0e, $1e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $20, $0e, $18, $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e
	db $d8, $0e, $0e, $0e, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $18, $0e, $0e
	db $0e, $0c, $0d, $0e, $0e, $0e, $0e, $0c, $0d, $0e, $0e, $1c, $0e, $0e, $1e, $d8
	db $0e, $0e, $0e, $0e, $0e, $04, $10, $11, $06, $07, $0a, $0b, $10, $11, $05, $0e
	db $0e, $0e, $0e, $0e, $d8, $1c, $0e, $0c, $0d, $0c, $03, $14, $15, $08, $09, $14
	db $15, $14, $15, $02, $0d, $0c, $0d, $0e, $0e, $d8, $0e, $04, $10, $11, $10, $13
	db $16, $17, $16, $17, $16, $17, $16, $17, $12, $11, $10, $11, $05, $0e, $d8, $0c
	db $03, $14, $15, $14, $15, $14, $15, $14, $15, $14, $15, $14, $15, $14, $15, $14
	db $15, $02, $01, $d8, $12, $13, $16, $17, $16, $17, $16, $17, $16, $17, $16, $17
	db $16, $17, $16, $17, $16, $17, $12, $11, $d9

;@ path: event/cutscene
;@ Second background of cutscene 0 (BG map 2, shown at the end), DrawTilemap format.
Cutscene0GroundTilemap::
	db $00, $00, $0e, $1e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $1e, $0e, $0e, $0e, $0e, $1a, $0e, $d8
	db $0e, $0e, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $18, $0e, $d8, $0e, $0e, $18, $0e, $0e, $18
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $18
	db $0e, $0e, $1e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $1a
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $d8, $0e, $1a
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $20, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $1c
	db $0e, $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $18, $0e
	db $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $1a, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e
	db $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $1c, $0e, $d8, $0e, $0e, $0e, $0e, $18, $0e, $0e, $22, $23, $24
	db $2b, $2c, $2d, $0e, $0e, $0e, $20, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e
	db $0e, $25, $26, $27, $2a, $2a, $2e, $2f, $30, $0e, $0e, $0e, $0e, $0e, $0e, $d8
	db $0e, $0e, $0e, $0e, $1e, $28, $29, $2a, $2a, $2a, $2a, $2a, $2a, $31, $32, $0e
	db $0e, $0e, $1a, $0e, $d9

;@ path: event/cutscene
;@ Background of cutscenes 1 and 2, DrawTilemap format.
Cutscene12Tilemap::
	db $00, $00, $05, $05, $05, $05, $05, $05, $05, $05, $05
	db $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $d8, $05, $05, $05, $05
	db $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05
	db $d8, $14, $15, $15, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $14
	db $15, $15, $16, $17, $4f, $d8, $10, $11, $12, $13, $14, $15, $16, $17, $10, $11
	db $12, $13, $14, $15, $16, $17, $25, $26, $27, $5f, $d8, $20, $21, $22, $23, $24
	db $25, $26, $27, $20, $21, $22, $23, $24, $25, $26, $27, $73, $74, $75, $76, $d8
	db $02, $03, $08, $09, $0a, $0b, $05, $04, $05, $05, $05, $05, $05, $8d, $8e, $8f
	db $83, $84, $85, $36, $d8, $05, $05, $18, $19, $1a, $1b, $05, $05, $05, $92, $93
	db $05, $05, $9d, $9e, $9f, $2e, $2f, $05, $05, $d8, $05, $37, $05, $29, $2a, $2b
	db $05, $2d, $05, $a2, $a3, $05, $05, $ad, $ae, $af, $3e, $39, $05, $05, $d8, $05
	db $05, $05, $05, $3a, $3b, $05, $3d, $05, $05, $05, $05, $05, $05, $8b, $8c, $3f
	db $05, $05, $05, $d8, $39, $05, $05, $05, $0c, $0d, $05, $90, $05, $05, $05, $05
	db $05, $05, $0b, $9c, $05, $05, $05, $37, $d8, $05, $05, $38, $05, $1c, $1d, $05
	db $a0, $05, $05, $05, $90, $05, $58, $1b, $ac, $05, $05, $05, $05, $d8, $47, $48
	db $49, $48, $42, $43, $05, $05, $05, $05, $05, $a0, $05, $68, $89, $8a, $05, $05
	db $05, $05, $d8, $06, $07, $05, $05, $05, $86, $87, $88, $05, $05, $05, $05, $05
	db $33, $34, $35, $05, $36, $05, $05, $d8, $05, $05, $05, $05, $05, $05, $05, $4f
	db $05, $05, $05, $05, $05, $05, $44, $45, $46, $05, $05, $38, $d8, $11, $12, $13
	db $14, $15, $16, $17, $5f, $05, $05, $90, $05, $05, $05, $54, $05, $56, $05, $05
	db $05, $d8, $21, $22, $23, $24, $25, $26, $27, $05, $05, $05, $a0, $05, $05, $05
	db $64, $2c, $66, $05, $05, $05, $d8, $03, $08, $09, $0a, $0b, $05, $3d, $05, $05
	db $05, $05, $05, $05, $05, $05, $4a, $3e, $39, $05, $05, $d8, $05, $18, $19, $1a
	db $1b, $05, $05, $05, $05, $05, $05, $05, $05, $58, $05, $5a, $5b, $05, $05, $05
	db $d8, $37, $05, $29, $2a, $2b, $52, $05, $05, $05, $90, $05, $05, $05, $68, $05
	db $6a, $6b, $05, $05, $05, $d8, $05, $05, $05, $3a, $3b, $9d, $05, $05, $05, $a0
	db $05, $05, $05, $05, $79, $7a, $7b, $05, $37, $05, $d8, $05, $05, $05, $0c, $0d
	db $ad, $05, $05, $05, $05, $05, $05, $05, $05, $33, $34, $35, $05, $05, $05, $d8
	db $05, $05, $38, $1c, $1d, $05, $05, $05, $05, $05, $05, $05, $05, $90, $05, $44
	db $45, $46, $05, $05, $d8, $05, $05, $05, $30, $31, $05, $05, $05, $05, $05, $05
	db $05, $05, $a0, $05, $54, $05, $56, $05, $05, $d8, $38, $05, $05, $40, $41, $05
	db $90, $05, $05, $05, $05, $05, $05, $05, $05, $64, $65, $66, $05, $39, $d8, $05
	db $05, $05, $50, $51, $52, $a0, $05, $05, $05, $05, $05, $05, $05, $05, $52, $4d
	db $4e, $05, $05, $d8, $05, $39, $05, $60, $61, $62, $05, $05, $05, $05, $05, $05
	db $05, $05, $05, $62, $5d, $5e, $05, $05, $d8, $05, $05, $05, $70, $71, $72, $0f
	db $52, $05, $05, $05, $05, $05, $0f, $05, $72, $6d, $6e, $6f, $05, $d8, $05, $05
	db $00, $80, $81, $82, $1f, $62, $05, $05, $05, $05, $05, $1f, $05, $82, $7d, $7e
	db $7f, $05, $d8, $0e, $1e, $0e, $28, $01, $32, $55, $0e, $0e, $1e, $0e, $1e, $0e
	db $32, $1e, $55, $0e, $55, $0e, $1e, $d8, $01, $01, $96, $97, $98, $99, $a6, $a7
	db $a8, $a9, $aa, $01, $01, $01, $01, $01, $01, $96, $97, $98, $d8, $98, $99, $a6
	db $9a, $9b, $ab, $01, $01, $01, $01, $01, $96, $97, $98, $99, $a6, $a7, $01, $9a
	db $9b, $d8, $9b, $ab, $01, $a8, $a9, $aa, $96, $97, $98, $99, $a6, $a7, $9a, $9b
	db $ab, $01, $01, $a8, $a9, $aa, $d9

;@ path: event/cutscene
;@ Background of cutscene 3, DrawTilemap format.
Cutscene3Tilemap::
	db $00, $00, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $09, $0a, $0b, $07, $08, $02, $02, $07, $08, $d8, $02, $07
	db $08, $02, $09, $0a, $0b, $07, $08, $02, $02, $02, $02, $02, $02, $02, $02, $09
	db $0a, $0b, $d8, $0a, $0b, $07, $08, $02, $02, $09, $0a, $0b, $09, $0a, $0b, $07
	db $08, $07, $08, $09, $0c, $0d, $5a, $d8, $13, $14, $15, $16, $0c, $0d, $10, $11
	db $12, $10, $11, $12, $0c, $0d, $4c, $4d, $7c, $7d, $7e, $7f, $d8, $23, $24, $25
	db $26, $0e, $0f, $20, $21, $22, $20, $21, $22, $43, $44, $45, $46, $8c, $8d, $8e
	db $8f, $d8, $33, $34, $35, $36, $30, $31, $32, $01, $01, $01, $01, $01, $53, $54
	db $55, $56, $82, $83, $84, $d8, $b0, $b0, $17, $18, $40, $41, $42, $01, $01, $05
	db $06, $01, $01, $64, $65, $66, $92, $93, $d8, $b0, $b0, $27, $28, $50, $51, $52
	db $01, $01, $01, $01, $01, $01, $74, $75, $76, $a7, $d8, $b0, $b0, $b0, $b0, $60
	db $61, $62, $01, $01, $01, $01, $01, $01, $5b, $70, $71, $a8, $1a, $1b, $19, $d8
	db $19, $1a, $1b, $1c, $1d, $1e, $1f, $04, $01, $01, $01, $01, $01, $01, $80, $81
	db $a9, $2a, $2b, $29, $d8, $29, $2a, $2b, $2c, $2d, $2e, $2f, $01, $01, $01, $01
	db $04, $01, $9d, $9e, $9f, $d8, $37, $38, $37, $38, $39, $3a, $01, $01, $01, $01
	db $01, $5b, $5c, $5d, $5e, $5f, $19, $1a, $1b, $1c, $d8, $02, $02, $02, $02, $02
	db $3b, $3c, $3d, $01, $01, $6a, $6b, $6c, $6d, $6e, $6f, $29, $2a, $2b, $2c, $d8
	db $0b, $07, $08, $02, $02, $09, $08, $3f, $01, $01, $01, $01, $01, $01, $85, $86
	db $63, $d8, $14, $15, $16, $0c, $0d, $10, $3e, $4f, $01, $01, $04, $01, $01, $04
	db $95, $96, $73, $d8, $24, $25, $26, $0e, $0f, $20, $4e, $01, $01, $01, $01, $01
	db $01, $01, $a5, $a6, $72, $d8, $34, $35, $36, $30, $31, $32, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $90, $91, $d8, $b0, $17, $18, $40, $41, $42, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $a0, $a1, $d8, $b0, $27, $28, $50, $51, $52
	db $01, $01, $01, $04, $01, $01, $01, $01, $9d, $9e, $9f, $d8, $b0, $b0, $b0, $60
	db $61, $62, $01, $01, $01, $01, $01, $01, $5b, $5c, $5d, $5e, $5f, $1a, $1b, $1c
	db $d8, $19, $1b, $1c, $1d, $1e, $1f, $01, $01, $01, $01, $01, $6a, $6b, $6c, $6d
	db $6e, $6f, $2a, $2b, $2c, $d8, $29, $2b, $2c, $2d, $2e, $2f, $01, $01, $01, $01
	db $01, $01, $01, $04, $01, $85, $86, $63, $d8, $b0, $b0, $b0, $48, $49, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $95, $96, $73, $d8, $b0, $b0, $b0, $58
	db $59, $01, $04, $01, $01, $01, $01, $01, $01, $01, $01, $a5, $a6, $72, $d8, $b0
	db $b0, $b0, $68, $69, $47, $01, $01, $01, $01, $01, $01, $01, $5b, $5c, $5d, $5e
	db $5f, $1a, $1b, $d8, $b0, $b0, $b0, $78, $79, $57, $01, $01, $01, $47, $01, $01
	db $47, $01, $01, $6d, $6e, $6f, $2a, $2b, $d8, $b0, $b0, $b0, $88, $89, $67, $47
	db $7b, $47, $57, $01, $01, $57, $01, $01, $7b, $9a, $9b, $d8, $b0, $b0, $87, $98
	db $99, $77, $57, $8b, $57, $67, $47, $01, $67, $47, $01, $8b, $aa, $ab, $ac, $d8
	db $a2, $a3, $a4, $4a, $4b, $5d, $4b, $4a, $4b, $5d, $4a, $9c, $4b, $4a, $9c, $5d
	db $4a, $4b, $94, $a2, $d8, $03, $7a, $ae, $af, $03, $03, $03, $03, $03, $03, $7a
	db $8a, $ae, $7a, $03, $03, $03, $03, $03, $03, $d8, $03, $03, $03, $03, $03, $7a
	db $8a, $ad, $ae, $af, $03, $03, $03, $03, $7a, $8a, $ad, $ae, $af, $03, $d8, $7a
	db $8a, $ad, $ae, $af, $03, $03, $03, $03, $7a, $8a, $ad, $ae, $af, $03, $03, $03
	db $03, $03, $7a, $d9

;@ path: unused
;@ Bytes nothing in the game refers to: tables and code fragments that do not fit this ROM's
;@ routines (left over from another build), then $FF padding up to the end of the bank.
UnusedBank02Data::
	db $02, $c0, $81, $82, $83, $84, $85, $a6, $80, $fe, $52, $c9
	db $8a, $8b, $ac, $fe, $62, $cd, $8e, $8f, $b0, $fe, $82, $c7, $88, $91, $b2, $ff
	db $20, $02, $e0, $ff, $55, $77, $6c, $77, $8b, $77, $a6, $77, $27, $23, $c6, $85
	db $84, $83, $82, $a1, $fe, $25, $cc, $8b, $8a, $89, $88, $a7, $fe, $77, $ed, $fe
	db $72, $e0, $ff, $20, $02, $c0, $81, $82, $83, $84, $85, $92, $b3, $fe, $32, $c6
	db $87, $88, $89, $aa, $fe, $62, $cb, $8c, $8d, $8e, $af, $fe, $92, $f0, $fe, $b2
	db $f1, $ff, $22, $22, $c0, $81, $82, $83, $84, $80, $85, $80, $80, $86, $87, $88
	db $89, $ea, $fe, $52, $cb, $8c, $ad, $fe, $82, $ce, $8f, $b0, $ff, $22, $22, $c0
	db $e1, $ff, $b3, $77, $c2, $77, $e1, $77, $f9, $77, $20, $02, $c0, $81, $82, $83
	db $84, $a5, $fe, $22, $c6, $87, $88, $a9, $ff, $20, $02, $c0, $81, $82, $83, $84
	db $85, $86, $87, $88, $89, $8a, $eb, $fe, $32, $ce, $8f, $90, $b1, $fe, $52, $cc
	db $ad, $fe, $72, $f2, $fe, $92, $f3, $ff, $20, $02, $c0, $a1, $fe, $22, $c4, $85
	db $86, $87, $a8, $fe, $42, $e9, $fe, $62, $e2, $fe, $a2, $ea, $fe, $82, $e3, $ff
	db $20, $02, $c0, $81, $a2, $ff, $0b, $78, $11, $78, $1b, $78, $3c, $78, $55, $78
	db $62, $78, $20, $02, $c0, $a1, $c0, $ff, $20, $02, $e0, $fe, $12, $e1, $fe, $f2
	db $e1, $ff, $20, $02, $80, $80, $86, $86, $80, $81, $81, $86, $80, $81, $81, $86
	db $86, $82, $ff, $02, $86, $81, $80, $82, $83, $80, $86, $86, $81, $80, $86, $80
	db $84, $a5, $ff, $20, $02, $c0, $81, $82, $83, $84, $e5, $fe, $21, $e6, $c6, $a7
	db $e7, $fe, $42, $e8, $fe, $62, $c9, $ea, $fe, $82, $eb, $ff, $20, $02, $c0, $c1
	db $c2, $c1, $c2, $c2, $c1, $c1, $c1, $e1, $ff, $20, $02, $e0, $ff, $2f, $f2, $c0
	db $81, $82, $83, $84, $a5, $ff, $79, $78, $79, $78, $99, $78, $d2, $78, $33, $79
	db $81, $78, $81, $78, $81, $78, $8c, $78, $22, $00, $3c, $03, $02, $13, $08, $00
	db $06, $03, $ff, $22, $00, $0f, $01, $2d, $03, $02, $13, $08, $00, $06, $03, $ff
	db $a1, $78, $b6, $78, $c1, $78, $c1, $78, $16, $00, $08, $03, $01, $23, $01, $63
	db $01, $a3, $01, $e3, $21, $03, $04, $00, $17, $03, $02, $13, $ff, $16, $00, $3b
	db $03, $02, $00, $0b, $03, $02, $13, $ff, $16, $00, $04, $03, $03, $83, $20, $03
	db $01, $40, $1c, $00, $04, $03, $02, $13, $ff, $da, $78, $f1, $78, $06, $79, $06
	db $79, $0a, $00, $03, $03, $05, $00, $0d, $03, $07, $00, $02, $03, $1c, $00, $12
	db $03, $04, $00, $04, $03, $02, $13, $ff, $1f, $03, $07, $00, $02, $03, $1c, $00
	db $12, $03, $04, $00, $04, $03, $02, $13, $5a, $00, $04, $20, $ff, $0a, $00, $03
	db $03, $05, $00, $0d, $03, $07, $00, $02, $03, $17, $00, $05, $03, $01, $02, $07
	db $03, $01, $02, $01, $03, $01, $02, $04, $03, $01, $83, $01, $82, $09, $03, $02
	db $13, $46, $00, $01, $22, $01, $00, $01, $22, $ff, $3f, $79, $3f, $79, $3f, $79
	db $4e, $79, $4e, $79, $4e, $79, $22, $00, $1e, $03, $0d, $00, $11, $03, $02, $13
	db $2e, $00, $01, $03, $ff, $0b, $03, $48, $00, $0b, $03, $02, $13, $10, $03, $ff
	db $26, $c0, $16, $17, $af, $2e, $20, $1e, $50, $22, $1d, $20, $fc, $24, $15, $20
	db $f4, $11, $20, $c0, $21, $c9, $69, $cd, $b6, $04, $2a, $fe, $80, $c8, $cb, $7f
	db $28, $22, $cb, $bf, $cb, $77, $20, $04, $47, $af, $18, $0b, $cb, $b7, $47, $cb
	db $a0, $cb, $a8, $e6, $30, $cb, $c7, $e0, $d8, $f0, $d8, $cd, $a3, $79, $d8, $05
	db $20, $f7, $18, $d6, $cd, $a3, $79, $d8, $18, $d0, $12, $1c, $7b, $fe, $70, $3f
	db $d0, $1e, $20, $14, $7a, $fe, $d4, $3f, $c9, $cd, $43, $00, $bf, $79, $d7, $79
	db $f2, $79, $07, $7a, $ae, $08, $d7, $c0, $3e, $30, $cd, $d6, $05, $d0, $01, $ed
	db $79, $cd, $be, $02, $cd, $83, $06, $ff, $01, $00, $fc, $c3, $64, $05, $cd, $1f
	db $7a, $01, $1a, $00, $cd, $8e, $05, $cd, $a2, $05, $c0, $3e, $60, $cd, $ce, $06
	db $ff, $c3, $c3, $05, $08, $61, $08, $62, $fe, $cd, $1f, $7a, $3e, $00, $cd, $a4
	db $06, $3e, $1b, $cc, $15, $05, $d7, $c0, $36, $60, $ff, $c3, $b4, $05, $cd, $1f
	db $7a, $01, $1a, $00, $cd, $8e, $05, $2e, $0f, $7e, $fe, $90, $d8, $36, $90, $cd
	db $c3, $05, $af, $c3, $d8, $07, $cd, $38, $08, $01, $ed, $79, $ca, $98, $02, $3e
	db $04, $01, $05, $63, $cd, $ee, $07, $c1, $c9, $cd, $43, $00, $3f, $7a, $77, $7a
	db $8e, $7a, $94, $7a, $ae, $08, $fa, $01, $cc, $fe, $02, $38, $03, $fe, $07, $d8
	db $3e, $38, $cd, $d6, $05, $d0, $01, $89, $7a, $cd, $be, $02, $cd, $83, $06, $3e
	db $3d, $cd, $15, $05, $ff, $01, $60, $ff, $cd, $52, $05, $01, $c0, $fc, $cd, $64
	db $05, $cd, $48, $06, $cd, $32, $06, $c8, $01, $00, $08, $c3, $ea, $05, $cd, $9d
	db $7a, $01, $16, $00, $cd, $8e, $05, $cd, $a2, $05, $c0, $3e, $20, $c3, $e6, $79
	db $08, $60, $08, $61, $fe, $cd, $9d, $7a, $c3, $ff, $79, $cd, $9d, $7a, $01, $16
	db $00, $c3, $8e, $05, $01, $89, $7a, $cd, $98, $02, $cd, $38, $08, $c8, $3e, $04
	db $01, $05, $62, $cd, $ee, $07, $c1, $c9, $1e, $00, $1a, $fe, $30, $ca, $bb, $7c
	db $fe, $35, $ca, $a3, $7e, $01, $00, $9a, $cd, $c8, $7b, $01, $07, $9a, $cd, $c8
	db $7b, $16, $cc, $01, $40, $7c, $cd, $be, $02, $2e, $07, $36, $a1, $cd, $84, $07
	db $01, $28, $01, $cd, $52, $05, $01, $48, $d4, $cd, $e2, $05, $14, $cd, $e2, $05
	db $2e, $00, $36, $69, $01, $37, $7c, $cd, $7e, $06, $cd, $84, $07, $15, $cd, $be
	db $7b, $01, $2f, $03, $c3, $96, $11, $1e, $00, $1a, $fe, $69, $ca, $11, $7c, $fe
	db $6a, $ca, $8d, $7c, $fe, $30, $ca, $de, $7c, $fe, $35, $ca, $a7, $7e, $cd, $ab
	db $7b, $cd, $98, $08, $cd, $de, $7b, $1e, $01, $1a, $c7, $2c, $7b, $32, $7b, $51
	db $7b, $90, $7b, $f7, $fe, $50, $d0, $ff, $c9, $cd, $32, $06, $01, $d0, $c8, $20
	db $03, $01, $d8, $d0, $f7, $b8, $d8, $b9, $d0, $cd, $38, $06, $cd, $32, $06, $c8
	db $fa, $86, $ca, $fe, $08, $d8, $ff, $c9, $f7, $fe, $f0, $d8, $ff, $01, $00, $b8
	db $cd, $fe, $05, $0e, $08, $14, $3e, $10, $df, $c5, $14, $cd, $e2, $05, $2e, $00
	db $36, $6a, $cd, $84, $07, $3e, $66, $e7, $3e, $91, $cd, $8f, $06, $7a, $d6, $ce
	db $21, $8a, $7b, $ef, $7e, $cd, $ce, $06, $c1, $7a, $fe, $d3, $38, $d8, $16, $cc
	db $c9, $30, $20, $10, $00, $10, $20, $f7, $fe, $c8, $d8, $fe, $d0, $d0, $cd, $26
	db $04, $af, $77, $ea, $96, $ca, $cd, $e4, $23, $01, $7e, $01, $cd, $96, $11, $c3
	db $30, $07, $fa, $82, $c9, $cb, $5f, $3e, $48, $28, $01, $3c, $1e, $0f, $12, $01
	db $40, $7c, $cd, $98, $02, $62, $3e, $34, $2e, $14, $96, $ea, $c3, $dd, $c9, $21
	db $45, $7c, $16, $0c, $1e, $06, $2a, $cd, $07, $0b, $0c, $1d, $20, $f8, $3e, $1a
	db $df, $15, $20, $f0, $c9, $21, $06, $c0, $cb, $46, $c8, $e5, $2c, $cb, $be, $cd
	db $6f, $03, $e1, $cb, $7e, $c8, $2c, $fa, $0f, $c0, $fe, $5c, $d0, $fa, $01, $c0
	db $fe, $03, $30, $08, $cb, $fe, $3e, $01, $ea, $c5, $ca, $c9, $fa, $07, $cc, $cb
	db $bf, $77, $3e, $01, $ea, $d2, $ca, $c9, $fa, $00, $cc, $a7, $ca, $33, $07, $cd
	db $6f, $03, $cd, $98, $08, $cd, $de, $7b, $26, $cc, $cd, $f7, $05, $cd, $e2, $05
	db $fa, $07, $cc, $cb, $bf, $cd, $8f, $06, $01, $37, $7c, $c3, $98, $02, $04, $62
	db $04, $65, $04, $64, $04, $63, $fe, $08, $60, $08, $61, $fe, $b7, $98, $99, $95
	db $96, $93, $9a, $9b, $9c, $92, $92, $97, $9d, $9e, $92, $92, $92, $94, $a6, $92
	db $92, $92, $b0, $af, $a9, $92, $92, $ae, $ad, $ac, $a5, $a8, $a7, $ab, $aa, $b9
	db $b7, $9f, $a0, $95, $96, $93, $a1, $a2, $a3, $92, $92, $97, $b8, $a4, $92, $92
	db $92, $94, $a6, $92, $92, $92, $b6, $ba, $a9, $92, $92, $b5, $b4, $b3, $a5, $a8
	db $a7, $b2, $b1, $b9, $1e, $01, $1a, $fe, $01, $28, $1d, $7a, $fe, $d1, $fa, $01
	db $d1, $c2, $d8, $07, $f7, $fe, $98, $dc, $e4, $23, $fa, $14, $cc, $fe, $a0, $d0
	db $26, $cc, $cd, $89, $03, $d0, $ff, $c9, $d7, $c0, $2e, $00, $36, $67, $af, $c3
	db $d8, $07, $3e, $6f, $e7, $cd, $86, $06, $cd, $88, $07, $62, $2e, $05, $36, $04
	db $3e, $0b, $ea, $c1, $c9, $cd, $98, $3f, $cd, $a3, $3f, $3e, $04, $ea, $c1, $c9
	db $3e, $20, $c3, $ce, $06, $cd, $12, $09, $cd, $98, $08, $cd, $2e, $7e, $1e, $01
	db $1a, $c7, $0f, $7d, $14, $7d, $32, $7d, $5b, $7d, $14, $7d, $32, $7d, $5b, $7d
	db $14, $7d, $32, $7d, $5b, $7d, $5b, $7d, $71, $13, $71, $13, $71, $13, $8c, $7d
	db $c1, $7d, $ce, $7d, $1c, $7e, $d7, $c0, $c3, $5f, $7e, $cd, $c9, $02, $01, $89
	db $7e, $cd, $b1, $06, $c0, $ff, $01, $2d, $7d, $cd, $be, $02, $3e, $4a, $cd, $15
	db $05, $c3, $b4, $05, $30, $6b, $04, $71, $ff, $cd, $c9, $02, $01, $2d, $7d, $cd
	db $98, $02, $01, $18, $00, $1e, $01, $1a, $fe, $08, $20, $02, $0e, $0e, $cd, $8e
	db $05, $01, $17, $00, $cd, $a9, $07, $c8, $ff, $cd, $c3, $05, $01, $89, $7e, $c3
	db $be, $02, $cd, $c9, $02, $01, $89, $7e, $cd, $b1, $06, $c0, $1e, $01, $1a, $fe
	db $09, $c2, $5f, $7e, $cd, $e8, $07, $3e, $0e, $cd, $d8, $07, $01, $83, $7d, $cd
	db $be, $02, $3e, $e0, $cd, $ce, $06, $c3, $c3, $05, $08, $6c, $04, $6d, $08, $6e
	db $04, $6d, $fe, $cd, $90, $7e, $01, $83, $7d, $cd, $98, $02, $3e, $00, $cd, $a4
	db $06, $3e, $39, $cc, $15, $05, $3e, $02, $cd, $a4, $06, $3e, $39, $cc, $15, $05
	db $62, $2e, $04, $cb, $7e, $2e, $08, $cb, $96, $20, $02, $cb, $d6, $d7, $c0, $36
	db $20, $3e, $6d, $e7, $ff, $c3, $e2, $07, $cd, $c9, $02, $d7, $c0, $cd, $5f, $7e
	db $3e, $01, $c3, $d8, $07, $21, $c0, $ca, $cb, $c6, $cd, $10, $7e, $2e, $08, $7e
	db $fe, $6b, $c8, $01, $14, $e6, $cd, $32, $06, $f7, $20, $06, $fe, $24, $30, $08
	db $18, $04, $fe, $7c, $38, $02, $06, $00, $cd, $12, $06, $16, $c0, $cd, $e2, $05
	db $01, $00, $03, $cd, $73, $05, $cd, $b7, $05, $16, $cc, $3e, $73, $e7, $ff, $21
	db $18, $c0, $36, $00, $c3, $d3, $07, $01, $2d, $7d, $cd, $98, $02, $01, $0e, $00
	db $c3, $8e, $05, $cd, $10, $7e, $01, $17, $00, $cd, $a9, $07, $c8, $3e, $08, $cd
	db $d8, $07, $c3, $52, $7d, $fa, $c0, $ca, $a7, $c8, $1e, $02, $1a, $a7, $ca, $f7
	db $7e, $1e, $0f, $1a, $c6, $14, $16, $c0, $12, $cd, $b7, $05, $cd, $d3, $06, $cd
	db $ff, $2f, $16, $cc, $20, $0a, $fa, $14, $c0, $fe, $0c, $38, $03, $fe, $94, $d8
	db $21, $c0, $ca, $cb, $86, $c9, $ff, $01, $89, $7e, $cd, $7e, $06, $01, $80, $fd
	db $cd, $6c, $05, $01, $40, $ff, $cd, $5a, $05, $01, $30, $70, $1e, $01, $1a, $fe
	db $07, $20, $03, $01, $4c, $54, $f7, $b8, $d0, $b9, $da, $38, $06, $c3, $48, $06
	db $04, $67, $0a, $70, $04, $67, $ff, $cd, $41, $08, $c8, $3e, $19, $d2, $ce, $06
	db $3e, $0b, $01, $50, $72, $cd, $ee, $07, $c1, $c9, $3e, $74, $e7, $c9, $15, $cd
	db $f6, $05, $2e, $07, $7e, $cb, $87, $14, $62, $77, $cd, $e2, $05, $21, $01, $cc
	db $7e, $fe, $08, $c0, $2e, $0f, $7e, $fe, $4c, $d0, $fa, $06, $c0, $cb, $7f, $c0
	db $cb, $47, $c8, $cd, $82, $03, $d0, $21, $09, $cc, $2a, $a7, $c0, $36, $20, $16
	db $cc, $3e, $10, $cd, $d8, $07, $af, $cd, $dd, $07, $cd, $f7, $7e, $1e, $07, $1a
	db $16, $c0, $12, $cd, $3b, $06, $21, $06, $c0, $cb, $fe, $16, $cd, $c9, $01, $18
	db $12, $cd, $12, $06, $26, $c0, $c3, $e3, $05, $01, $cc, $98, $21, $43, $7f, $cd
	db $ea, $0a, $0e, $cf, $cd, $f8, $0a, $0e, $f1, $cd, $ea, $0a, $3e, $54, $0e, $0d
	db $cd, $07, $0b, $3e, $78, $01, $f3, $98, $cd, $07, $0b, $cd, $3d, $09, $c0, $cd
	db $77, $13, $c3, $f7, $15, $01, $ec, $98, $21, $4d, $7f, $cd, $ea, $0a, $01, $ef
	db $98, $cd, $ea, $0a, $3e, $7f, $0e, $12, $18, $de, $70, $71, $72, $73, $74, $75
	db $76, $77, $51, $52, $79, $73, $7a, $7b, $7c, $7d, $7e, $50, $61, $98, $89, $18
	db $19, $23, $13, $00, $18, $16, $16, $23, $37, $8b, $12, $1d, $26, $14, $23, $18
	db $17, $15, $14, $25, $2b, $35, $90, $1c, $20, $12, $15, $12, $1c, $18, $14, $15
	db $25, $2b, $23, $12, $1a, $14, $25, $30, $93, $12, $23, $1d, $00, $15, $14, $11
	db $12, $18, $14, $1d, $00, $19, $23, $1d, $19, $1c, $19, $12, $2d, $91, $12, $15
	db $14, $00, $18, $15, $12, $1d, $14, $1a, $12, $15, $22, $25, $00, $16, $1e, $2f
	db $91, $27, $12, $15, $23, $14, $15, $00, $1b, $15, $16, $25, $2a, $00, $19, $23
	db $1c, $2a, $2f, $86, $2e, $00, $05, $0d, $0d, $05, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $02
