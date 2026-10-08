INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $055", ROMX[$4000], BANK[$55]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_55::
	db $55

;@ path: battle/effects
;@ Entry points of bank $55: skill sounds, the letter tiles of the battle menu windows, and the debug
;@ menu (game mode $07).
FarTable_55::
	dw PlaySkillSound0
	dw PlaySkillSound1
	dw PlaySkillSound2
	dw PlaySkillSound3
	dw PlaySkillSound4
	dw LoadWindowLetters_1_9
	dw LoadWindowLetters_3
	dw LoadWindowLetters_4
	dw LoadWindowLetters_5
	dw LoadWindowLetters_6
	dw LoadWindowLetters_2
	dw LoadWindowLetters_7
	dw LoadWindowLetters_10
	dw DebugMenuInit
	dw DebugMenuUpdate

;@ def PlaySkillSound0()
;@ path: battle/effects
;@ Plays the sound of skill wSkillId from the first pair of SkillSoundTables (when its hit effect starts).
;@ test: skip calls a routine in another bank
PlaySkillSound0::
;> PlaySkillSoundFrom(SkillSoundTables + 0)
	ld hl, SkillSoundTables
	call PlaySkillSoundFrom
	ret


;@ def PlaySkillSound1()
;@ path: battle/effects
;@ Plays the sound of skill wSkillId from the second pair of SkillSoundTables, but only when the
;@ target position is the fourth of its side (wSkillTarget & 3 == 3).
;@ test: skip calls a routine in another bank
PlaySkillSound1::
;> if wSkillTarget & 3 != 3:
;>     return
	ld a, [wSkillTarget]
	and $03
	cp $03
	ret nz

;> PlaySkillSoundFrom(SkillSoundTables + 4)
	ld hl, SkillSoundTables + 4
	call PlaySkillSoundFrom
	ret


;@ def PlaySkillSound2()
;@ path: battle/effects
;@ Plays the sound of skill wSkillId from the third pair of SkillSoundTables.
;@ test: skip calls a routine in another bank
PlaySkillSound2::
;> PlaySkillSoundFrom(SkillSoundTables + 8)
	ld hl, SkillSoundTables + 8
	call PlaySkillSoundFrom
	ret


;@ def PlaySkillSound3()
;@ path: battle/effects
;@ Plays the sound of skill wSkillId from SkillSounds3.
;@ test: skip calls a routine in another bank
PlaySkillSound3::
;> PlaySkillSoundFrom(SkillSoundTables + 12)
	ld hl, SkillSoundTables + 12
	call PlaySkillSoundFrom
	ret


;@ def PlaySkillSound4()
;@ path: battle/effects
;@ Plays the sound of skill wSkillId from SkillSounds4 (when the skill's visual effect starts).
;@ test: skip calls a routine in another bank
PlaySkillSound4::
;> PlaySkillSoundFrom(SkillSoundTables + 16)
	ld hl, SkillSoundTables + 16
	call PlaySkillSoundFrom
	ret


;@ def PlaySkillSoundFrom(pair: hl)
;@ path: battle/effects
;@ `pair` points to two sound tables of SkillSoundTables: the first for a skill used from the own
;@ side, the second from the enemy side (swapped on the Game Boy that is link master, whose screen
;@ shows the other side as its own). Queues the table's sound for wSkillId unless it is $FF.
;@ test: skip calls a routine in another bank
PlaySkillSoundFrom::
;>@s side = (wSkillUser & 4) >> 1 ^ (wLinkFlags & 2)   # 0 or 2: which table of the pair
	ld a, [wLinkFlags]
	and $02
	ld b, a
	ld a, [wSkillUser]
	and $04
	srl a
;=@s
	xor b
;>@t sounds = mem16[pair + side]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
;=@t
	ld h, [hl]
	ld l, a
;> sound = mem[sounds + wSkillId]
	ld a, [wSkillId]
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hl]
;> if sound == 0xFF:                      # silent
;>     return
	cp $ff
	ret z

;> QueueSound(sound)
	call QueueSound
	ret


;@ path: battle/effects
;@ Five pairs of pointers to the skill sound tables (own side, enemy side), one pair per moment of a
;@ skill's animation (PlaySkillSound0-4).
SkillSoundTables::
	dw SkillSounds0Own, SkillSounds0Enemy
	dw SkillSounds1Own, SkillSounds1Enemy
	dw SkillSounds2Own, SkillSounds2Enemy
	dw SkillSounds3, SkillSounds3
	dw SkillSounds4, SkillSounds4

;@ path: battle/effects
;@ Sound effect of each skill number ($00-$DD) for PlaySkillSound0 when an own monster uses it
;@ ($FF = none).
SkillSounds0Own::
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $67, $67, $65, $67, $67, $67, $67, $67, $67
	db $67, $ff, $67, $ff, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67
	db $67, $67, $ff, $ff, $ff, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67
	db $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67
	db $67, $67, $67, $ff, $ff, $67, $67, $67, $67, $67, $67, $67, $67, $ff, $67, $ff
	db $ff, $ff, $ff, $ff, $67, $67, $67, $67, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $67, $67, $ff, $67, $ff, $67, $ff, $ff, $67, $67, $67, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $67, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $65, $67, $67, $67, $67, $ff, $ff, $ff, $67

;@ path: battle/effects
;@ Sound effect of each skill number for PlaySkillSound0 when an enemy uses it ($FF = none).
SkillSounds0Enemy::
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $ff, $65, $65, $65, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $ff, $65, $65, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $6b, $6b, $65, $6b, $6b, $6b, $6b, $6b, $6b
	db $6b, $ff, $6b, $ff, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b
	db $6b, $6b, $ff, $ff, $ff, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b
	db $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b
	db $6b, $6b, $6b, $ff, $ff, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $ff, $6b, $ff
	db $ff, $ff, $ff, $ff, $65, $65, $65, $65, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $6b, $6b, $ff, $6b, $ff, $6b, $ff, $ff, $6b, $6b, $6b, $ff, $ff, $ff, $ff
	db $ff, $6d, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6b, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $65, $6b, $6b, $6b, $6b, $65, $6d, $65, $6b

;@ path: battle/effects
;@ Sound effect of each skill number for PlaySkillSound1, own side ($FF = none).
SkillSounds1Own::
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $73, $73, $72, $84, $73, $72, $ff, $72, $72, $ff, $ff
	db $72, $72, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $73, $73, $73, $73, $73, $73
	db $73, $ff, $84, $ff, $ff, $72, $72, $ff, $73, $73, $73, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $72, $72, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $73, $72, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $82, $7e, $ff, $78, $81, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $76, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

;@ path: battle/effects
;@ Sound effect of each skill number for PlaySkillSound1, enemy side ($FF = none).
SkillSounds1Enemy::
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $71, $71, $ff, $ff, $71, $71
	db $ff, $ff, $71, $71, $ff, $71, $ff, $86, $86, $85, $ff, $70, $70, $70, $70, $70
	db $ff, $ff, $ff, $70, $70, $70, $70, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $71, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $70, $70, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $70, $ff, $ff, $ff, $ff, $ff, $ff, $85, $ff, $ff, $ff, $70, $ff
	db $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $82, $7e, $ff, $78, $81, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $76, $85, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

;@ path: battle/effects
;@ Sound effect of each skill number for PlaySkillSound2, own side ($FF = none).
SkillSounds2Own::
	db $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c
	db $6c, $6c, $9c, $9c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $71, $71
	db $ff, $ff, $71, $71, $ff, $71, $ff, $86, $86, $85, $ff, $70, $70, $70, $70, $70
	db $ff, $ff, $ff, $70, $70, $70, $70, $6c, $6c, $ff, $6c, $6c, $6c, $6c, $6c, $6c
	db $6c, $ff, $6c, $ff, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c
	db $6c, $6c, $6c, $6c, $ff, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c
	db $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $9c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6c, $6c, $6c, $6c, $ff
	db $ff, $70, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $70, $70, $ff, $ff, $ff, $ff, $6c, $6c, $6c, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $70, $9c, $ff, $71, $ff, $72, $ff, $85, $6c, $ff, $ff, $70, $6c
	db $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $70, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6c, $6c, $ff, $6c, $6c, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $6c, $85, $6c, $6c, $6c, $6c, $ff, $ff, $ff, $6c

;@ path: battle/effects
;@ Sound effect of each skill number for PlaySkillSound2, enemy side ($FF = none).
SkillSounds2Enemy::
	db $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c
	db $6c, $6c, $9c, $9c, $ff, $73, $73, $72, $84, $ff, $ff, $ff, $72, $72, $ff, $ff
	db $72, $72, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6c, $6c, $ff, $6c, $6c, $6c, $6c, $6c, $6c
	db $6c, $ff, $6c, $ff, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c
	db $6c, $6c, $6c, $6c, $ff, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c
	db $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $73, $73, $73, $73, $73, $73
	db $73, $9c, $84, $ff, $ff, $72, $ff, $ff, $73, $73, $73, $6c, $6c, $6c, $6c, $ff
	db $ff, $70, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $73, $73, $ff, $ff, $ff, $ff, $ff, $ff, $6c, $6c, $6c, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $9c, $ff, $71, $73, $ff, $ff, $ff, $6c, $ff, $ff, $ff, $6c
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6c, $6c, $ff, $6c, $6c, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $6c, $ff, $6c, $6c, $6c, $6c, $73, $ff, $ff, $6c

;@ path: battle/effects
;@ Sound effect of each skill number for PlaySkillSound3, both sides ($FF = none).
SkillSounds3::
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6f, $6f, $ff, $6f, $6f, $6f, $6f, $6f, $6f
	db $6f, $ff, $6f, $ff, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f
	db $6f, $6f, $6f, $6f, $ff, $6f, $6f, $6f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6f, $6f, $6f, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6f, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6f, $6f, $6f, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6f, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $6f, $6f, $6f, $6f, $ff, $ff, $ff, $6f

;@ path: battle/effects
;@ Sound effect of each skill number for PlaySkillSound4, both sides ($FF = none).
SkillSounds4::
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6c, $6c, $ff, $6c, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $73, $73, $73, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $73, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6c
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

;@ def LoadWindowLetters_1_9()
;@ path: battle/menu
;@ Draws the letters of the battle menu windows: letter set 1 into the tiles at $97C0 (6 letters) and
;@ letter set 9 into those at $8800 (12 letters).
;@ test: skip runs the text printer
LoadWindowLetters_1_9::
;> tiles, size = 0x97C0, 0x0601
	ld hl, $97c0
	ld de, $0601
;> wTextIndex = 1
	ld a, $01
	ld [wTextIndex], a
;> wTextGroup = 3                        # (not used by the letter sets)
	ld a, $03
	ld [wTextGroup], a
;> LoadWindowLetters(tiles, size)
	call LoadWindowLetters
;> tiles, size = 0x8800, 0x0C01
	ld hl, $8800
	ld de, $0c01
;> wTextIndex = 9
	ld a, $09
	ld [wTextIndex], a
;> wTextGroup = 3
	ld a, $03
	ld [wTextGroup], a
;> LoadWindowLetters(tiles, size)
	call LoadWindowLetters
	ret


;@ def LoadWindowLetters_3()
;@ path: battle/menu
;@ Draws letter set 3 of WindowLetterSets into the tiles at $8850 (24 letters).
;@ test: skip runs the text printer
LoadWindowLetters_3::
;> tiles, size = 0x8850, 0x1801             # 24 letters on 1 line
	ld hl, $8850
	ld de, $1801
;> wTextIndex = 3
	ld a, $03
	ld [wTextIndex], a
;> wTextGroup = 3                        # (not used by the letter sets)
	ld a, $03
	ld [wTextGroup], a
;> LoadWindowLetters(tiles, size)
	call LoadWindowLetters
	ret


;@ def LoadWindowLetters_4()
;@ path: battle/menu
;@ Draws letter set 4 of WindowLetterSets into the tiles at $8800 (5 letters).
;@ test: skip runs the text printer
LoadWindowLetters_4::
;> tiles, size = 0x8800, 0x0501             # 5 letters on 1 line
	ld hl, $8800
	ld de, $0501
;> wTextIndex = 4
	ld a, $04
	ld [wTextIndex], a
;> wTextGroup = 3                        # (not used by the letter sets)
	ld a, $03
	ld [wTextGroup], a
;> LoadWindowLetters(tiles, size)
	call LoadWindowLetters
	ret


;@ def LoadWindowLetters_5()
;@ path: battle/menu
;@ Draws letter set 5 of WindowLetterSets into the tiles at $8800 (5 letters).
;@ test: skip runs the text printer
LoadWindowLetters_5::
;> tiles, size = 0x8800, 0x0501             # 5 letters on 1 line
	ld hl, $8800
	ld de, $0501
;> wTextIndex = 5
	ld a, $05
	ld [wTextIndex], a
;> wTextGroup = 3                        # (not used by the letter sets)
	ld a, $03
	ld [wTextGroup], a
;> LoadWindowLetters(tiles, size)
	call LoadWindowLetters
	ret


;@ def LoadWindowLetters_6()
;@ path: battle/menu
;@ Draws letter set 6 of WindowLetterSets into the tiles at $8850 (6 letters).
;@ test: skip runs the text printer
LoadWindowLetters_6::
;> tiles, size = 0x8850, 0x0601             # 6 letters on 1 line
	ld hl, $8850
	ld de, $0601
;> wTextIndex = 6
	ld a, $06
	ld [wTextIndex], a
;> wTextGroup = 3                        # (not used by the letter sets)
	ld a, $03
	ld [wTextGroup], a
;> LoadWindowLetters(tiles, size)
	call LoadWindowLetters
	ret


;@ def LoadWindowLetters_2()
;@ path: battle/menu
;@ Draws letter set 2 of WindowLetterSets into the tiles at $8800 (11 letters).
;@ test: skip runs the text printer
LoadWindowLetters_2::
;> tiles, size = 0x8800, 0x0B01             # 11 letters on 1 line
	ld hl, $8800
	ld de, $0b01
;> wTextIndex = 2
	ld a, $02
	ld [wTextIndex], a
;> wTextGroup = 3                        # (not used by the letter sets)
	ld a, $03
	ld [wTextGroup], a
;> LoadWindowLetters(tiles, size)
	call LoadWindowLetters
	ret


;@ def LoadWindowLetters_7()
;@ path: battle/menu
;@ Draws letter set 7 of WindowLetterSets into the tiles at $8860 (2 letters).
;@ test: skip runs the text printer
LoadWindowLetters_7::
;> tiles, size = 0x8860, 0x0201             # 2 letters on 1 line
	ld hl, $8860
	ld de, $0201
;> wTextIndex = 7
	ld a, $07
	ld [wTextIndex], a
;> wTextGroup = 3                        # (not used by the letter sets)
	ld a, $03
	ld [wTextGroup], a
;> LoadWindowLetters(tiles, size)
	call LoadWindowLetters
	ret


;@ def LoadWindowLetters_10()
;@ path: battle/menu
;@ Draws letter set 10 of WindowLetterSets into the tiles at $8820 (7 letters); runs on into
;@ LoadWindowLetters.
;@ test: skip runs the text printer
LoadWindowLetters_10::
;> tiles, size = 0x8820, 0x0701
	ld hl, $8820
	ld de, $0701
;> wTextIndex = 10
	ld a, $0a
	ld [wTextIndex], a
;> wTextGroup = 3
;> LoadWindowLetters(tiles, size)        # (falls through)
	ld a, $03
	ld [wTextGroup], a

;@ def LoadWindowLetters(tiles: hl, size: de)
;@ path: battle/menu
;@ Draws letter set wTextIndex of WindowLetterSets into the tiles at `tiles` (d letters per line, e
;@ lines), keeping the text box settings of the current window.
;@ test: skip runs the text printer
LoadWindowLetters::
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;> saved_lines, saved_length = wTextBoxLines, wTextBoxLineLength
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = size & 0xFF
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = size >> 8
	ld a, d
	ld [wTextBoxLineLength], a
;> DrawLetterSet()
	call DrawLetterSet
;> wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = saved_lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved_length
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ path: unused
;@ Four VRAM tile addresses ($96C0, $97C0, $8800, $8850) of the window letters; nothing reads them.
BattleMenuTileAddrs::
	dw $96c0, $97c0, $8800, $8850

;@ def DrawLetterSet()
;@ path: battle/menu
;@ Prints letter set wTextIndex of WindowLetterSets at once into the text box tiles.
;@ test: skip runs the text printer
DrawLetterSet::
;> StartLetterSetText(WindowLetterSets)
	ld de, WindowLetterSets
	call StartLetterSetText
;> RunTextToEnd()
	call RunTextToEnd
	ret


;@ def StartLetterSetText(table: de)
;@ path: battle/menu
;@ Starts the text printer on text wTextIndex of the pointer table `table` in this bank, drawing
;@ from the start of the text box tiles (wTextTiles).
;@ test: wTextIndex = rand(0, 10)
StartLetterSetText::
;> tiles = wTextTiles
	push de
	ld a, [wTextTiles]
	ld l, a
	ld a, [wTextTiles + 1]
	ld h, a
;> wTextCursor = tiles
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [wTextCursor + 1], a
;> wTextLineStart = tiles
	ld a, l
	ld [wTextLineStart], a
	ld a, h
	ld [wTextLineStart + 1], a
;> text = GetLetterSetPointer(table)
	pop de
	call GetLetterSetPointer
;> wTextPtr = text
	ld a, e
	ld [wTextPtr], a
	ld a, d
	ld [wTextPtr + 1], a
;> wTextStart = text
	ld a, e
	ld [wTextStart], a
	ld a, d
	ld [wTextStart + 1], a
;> wTextState = 1                         # printing
	ld a, $01
	ld [wTextState], a
;> wTextFlags = 0
	ld a, $00
	ld [wTextFlags], a
;> wTextDelay = 0
	xor a
	ld [wTextDelay], a
	ret


;@ path: battle/menu
;@ Letter sets of the battle menu windows, texts in the game's character set ended by $F0. Each lists
;@ the different letters a window needs once (set 3: F I G H T E M S R U N O A P L X D C . K); they are
;@ drawn into consecutive tiles and the window's tile map spells its words from them. $8D and $63 are
;@ punctuation tiles.
WindowLetterSets::
	dw .t0
	dw .t1
	dw .t2
	dw .t3
	dw .t4
	dw .t5
	dw .t6
	dw .t7
	dw .t8
	dw .t9
	dw .t10
.t0
	db $33, $38, $8d, $2b, $8d, $50, $f0
.t1
	db $33, $35, $38, $31, $f0
.t2
	db $24, $2f, $2e, $27, $36, $f0
.t3
	db $29, $2c, $2a, $2b, $37, $28, $30, $36, $35, $38, $31, $32, $24, $33, $2f, $3b
	db $27, $26, $63, $2e, $f0
.t4
	db $24, $2f, $2e, $27, $36, $f0
.t5
	db $2c, $8d, $3a, $55, $29, $30, $8d, $f0
.t6
	db $3a, $2b, $32, $29, $28, $f0
.t7
	db $3a, $32, $f0
.t8
	db $33, $29, $26, $38, $8d, $2b, $8d, $2e, $2b, $31, $55, $3a, $2c, $8d, $50, $f0
.t9
	db $24, $2f, $2e, $27, $36, $29, $2c, $2a, $2b, $37, $28, $30, $f0
.t10
	db $3a, $2b, $32, $2c, $31, $29, $32, $32, $2e, $f0

;@ def GetLetterSetPointer(table: de) -> de
;@ path: battle/menu
;@ Selects this bank for the text printer and returns entry wTextIndex of the pointer table `table`.
;@ test: wTextIndex = rand(0, 10)
GetLetterSetPointer::
;> wTextBank = mem[BankNumber_55]
	ld a, [BankNumber_55]
	ld [wTextBank], a
;>@ret return mem16[table + 2 * wTextIndex]
	ld a, [wTextIndex]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
;=@ret
	inc hl
	ld d, [hl]
	ret


;@ def DebugMenuInit()
;@ path: system/debug
;@ Start of game mode $07, the developers' debug menu (no normal way leads there). Sets up the text box
;@ tiles from $9000, the palettes, clears the 16 debug values at $C0A0 (wNumberBackup on), sets up
;@ page wGameModeStep (DebugPageInits) and turns the screen on.
;@ test: skip calls routines in other banks
DebugMenuInit::
;> SetUpTextBox(0x9000, lines=7, line_length=16)
	ld hl, $9000
	ld de, $1007
	call SetUpTextBox
;> SetSharedBGColors()
	ld hl, far_SetSharedBGColors
	rst $10
;> ClearAttrMap()
	ld hl, far_ClearAttrMap
	rst $10
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
;> FillMemory(wNumberBackup, 0x10, 0)    # the debug values
	ld hl, wNumberBackup
	ld bc, $0010
	ld a, $00
	call FillMemory
;> wMenuChoice = 0
	xor a
	ld [wMenuChoice], a
;> DebugPageInit()
	call DebugPageInit
;> QueueMusic(0)
	ld a, $00
	call QueueMusic
;> wLCDC = 3
	ld a, $03
	ld [wLCDC], a
;> EnableLCDAndInterrupts(1)              # VBlank only
	ld a, $01
	jp EnableLCDAndInterrupts


;@ def DebugPageInit()
;@ path: system/debug
;@ Sets up debug page wGameModeStep (0 main menu, 1 program jump, 2 monster pictures, 3 map edit,
;@ 4 sound test, 5 battle).
;@ test: skip jump table dispatch
DebugPageInit::
;> DebugPageInits[wGameModeStep]()
	ld a, [wGameModeStep]
	rst $00

;@ path: system/debug
;@ Set-up routine of each debug page.
DebugPageInits::
	dw DebugMainInit
	dw DebugModeJumpInit
	dw DebugMonsterViewInit
	dw DebugWarpInit
	dw DebugSoundTestInit
	dw DebugBattleInit

;@ def DebugMainInit()
;@ path: system/debug
;@ Main debug page: prints the "DEBUG MODE / SELECT" list (system text 3) into the tiles at $8800 and
;@ maps 16 x 2 rows of them at $98A3.
;@ test: skip calls routines in other banks
DebugMainInit::
;> wSGBPalSet[0] = 0
	ld hl, wSGBPalSet
	ld [hl], $00
;> wSGBPalSet[1] = 0
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> wTextIndex = 3
	ld hl, $8800
	ld a, $03
	ld [wTextIndex], a
;> DebugPrintText(0x8800)
	call DebugPrintText
;> return FillTileBlock(0x98A3, width=16, height=2, first=0x80)
	ld hl, $98a3
	ld bc, $1002
	ld a, $80
	jp FillTileBlock


;@ def DebugModeJumpInit()
;@ path: system/debug
;@ "GOTOPRG" page: prints the hex digits (text 5) and the page texts, and loads the four values (game
;@ mode, its step, opening scene, logo) from the mode saved when the menu was opened.
;@ test: skip calls routines in other banks
DebugModeJumpInit::
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> wTextIndex = 5                         # "0123456789ABCDEF": the digit tiles
	ld a, $05
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextIndex = 7                         # "GOTOPRG / PRGNO..."
	ld hl, $9120
	ld de, $1006
	ld a, $07
	ld [wTextIndex], a
;> DebugPrintTextBox(0x9120, lines=6, line_length=16)
	call DebugPrintTextBox
;> wTextIndex = 8                         # the names of the game modes
	ld hl, $8800
	ld a, $08
	ld [wTextIndex], a
;> DebugPrintText(0x8800)
	call DebugPrintText
;>@4 for i in range(4): mem[0xC0A0 + i] = wDebugSavedMode[i]
	ld hl, wNumberBackup
	ld a, [wDebugSavedMode]
	ld [hli], a
	ld a, [wDebugSavedMode + 1]
	ld [hli], a
;=@4
	ld a, [wDebugSavedMode + 2]
	ld [hli], a
	ld a, [wDebugSavedMode + 3]
	ld [hli], a
;> return FillTileBlock(0x9884, width=16, height=6, first=0x12)
	ld hl, $9884
	ld bc, $1006
	ld a, $12
	jp FillTileBlock


;@ def DebugMonsterViewInit()
;@ path: system/debug
;@ Monster picture page: loads the digit tiles and a font (compressed entry $2F:$11) to $8800,
;@ clears the background map, maps a 6 x 6 tile picture frame from tile $80 at $9887 and a 9-tile
;@ name line from $A4, then shows monster 0.
;@ test: skip calls routines in other banks
DebugMonsterViewInit::
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> wTextIndex = 5
	ld a, $05
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> Decompress(0x2F, 0x11, 0x8800)
	ld de, $2f11
	ld hl, $8800
	call Decompress
;> FillMemory(0x9800, 0x400, 0)
	ld hl, $9800
	ld bc, $0400
	ld a, $00
	call FillMemory
;> tile = 0x80
	ld hl, $9887
	ld a, $80
;>@rows for row in range(6): tile = WriteTileRun(0x9887 + row * 0x20, tile, 6)
	ld b, $06
	call WriteTileRun
;=@rows
	ld hl, $98a7
	ld b, $06
	call WriteTileRun
;=@rows
	ld hl, $98c7
	ld b, $06
	call WriteTileRun
;=@rows
	ld hl, $98e7
	ld b, $06
	call WriteTileRun
;=@rows
	ld hl, $9907
	ld b, $06
	call WriteTileRun
;=@rows
	ld hl, $9927
	ld b, $06
	call WriteTileRun
;> WriteTileRun(0x9967, 0xA4, 9)          # the name line
	ld hl, $9967
	ld a, $a4
	ld b, $09
	call WriteTileRun
;> wMenuChoice = 0
	xor a
	ld [wMenuChoice], a
;> ShowDebugMonster()
	call ShowDebugMonster
	ret


;@ def WriteTileRun(pos: hl, tile: a, count: b) -> a
;@ path: system/debug
;@ Writes `count` consecutive tile numbers from `tile` on to the background map at `pos`.
;@ test: skip polls the LCD
WriteTileRun::
;> for _ in range(count):
;>     pos = WriteVRAMInc(tile, pos); tile += 1
	call WriteVRAMInc
	inc a
	dec b
	jr nz, WriteTileRun

;> return tile
	ret


;@ def DebugWarpInit()
;@ path: system/debug
;@ "EDIT" page (warp anywhere): prints the digits and the page text, and loads its 8 values from the
;@ game: floor flag, map, party count, the three party slots, 0, debug set-up flag.
;@ test: skip calls routines in other banks
DebugWarpInit::
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> wTextIndex = 5
	ld a, $05
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextIndex = 4                         # "EDIT / MAPTYPE / FLOOR ..."
	ld hl, $9120
	ld de, $0a0a
	ld a, $04
	ld [wTextIndex], a
;> DebugPrintTextBox(0x9120, lines=10, line_length=10)
	call DebugPrintTextBox
;> mem[0xC0A0] = wOnGateFloor
	ld hl, wNumberBackup
	ld a, [wOnGateFloor]
	ld [hli], a
;> mem[0xC0A1] = wMapId
	ld a, [wMapId]
	ld [hli], a
;> mem[0xC0A2] = wPartyCount
	ld a, [wPartyCount]
	ld [hli], a
;> for i in range(3): mem[0xC0A3 + i] = wParty[i]
	ld a, [wParty]
	ld [hli], a
	ld a, [wParty + 1]
	ld [hli], a
	ld a, [wParty + 2]
	ld [hli], a
;> mem[0xC0A6] = 0
	ld a, $00
	ld [hli], a
;> mem[0xC0A7] = wDebugSetup
	ld a, [wDebugSetup]
	ld [hl], a
;> hScrollX = hScrollX & 0xFF00 | 0x1C    # (only the low byte)
	ld a, $1c
	ldh [hScrollX], a
;> FillTileBlock(0x9885, width=10, height=10, first=0x12)
	ld hl, $9885
	ld bc, $0a0a
	ld a, $12
	call FillTileBlock
;> return DebugWarpRefresh()
	jp DebugWarpRefresh


;@ def DebugSoundTestInit()
;@ path: system/debug
;@ "SOUND" page: prints the digits and the page text (BGM / SE) and starts both numbers at 0.
;@ test: skip calls routines in other banks
DebugSoundTestInit::
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> wTextIndex = 5
	ld a, $05
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextIndex = 6                         # "SOUND / BGM / SE"
	ld hl, $9120
	ld de, $1006
	ld a, $06
	ld [wTextIndex], a
;> DebugPrintTextBox(0x9120, lines=6, line_length=16)
	call DebugPrintTextBox
;> mem[0xC0A0] = mem[0xC0A1] = 0          # song and sound effect numbers
	xor a
	ld [wNumberBackup], a
	ld [wNumberBackup + 1], a
;> return FillTileBlock(0x9884, width=16, height=6, first=0x12)
	ld hl, $9884
	ld bc, $1006
	ld a, $12
	jp FillTileBlock


;@ def DebugBattleInit()
;@ path: system/debug
;@ "BATTLE" page: prints the digits and the page text and loads its values from the current
;@ encounter: group size, then the three monster numbers (u16 each), then 0.
;@ test: skip calls routines in other banks
DebugBattleInit::
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> wTextIndex = 5
	ld a, $05
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextIndex = 9                         # "BATTLE / ENEMY / MONST..."
	ld hl, $9120
	ld de, $0a0a
	ld a, $09
	ld [wTextIndex], a
;> DebugPrintTextBox(0x9120, lines=10, line_length=10)
	call DebugPrintTextBox
;> mem[0xC0A0] = wEncCount
	ld hl, wNumberBackup
	ld a, [wEncCount]
	ld [hli], a
;>@6 for i in range(6): mem[0xC0A1 + i] = wEncSpecies[i]
	ld a, [wEncSpecies]
	ld [hli], a
	ld a, [wEncSpecies + 1]
	ld [hli], a
;=@6
	ld a, [wEncSpecies + 2]
	ld [hli], a
	ld a, [wEncSpecies + 3]
	ld [hli], a
;=@6
	ld a, [wEncSpecies + 4]
	ld [hli], a
	ld a, [wEncSpecies + 5]
	ld [hli], a
;> mem[0xC0A7] = 0
	ld a, $00
	ld [hli], a
;> hScrollX = hScrollX & 0xFF00 | 0x24    # (only the low byte)
	ld a, $24
	ldh [hScrollX], a
;> FillTileBlock(0x9885, width=10, height=10, first=0x12)
	ld hl, $9885
	ld bc, $0a0a
	ld a, $12
	call FillTileBlock
;> return DebugBattleRefresh()
	jp DebugBattleRefresh


;@ def DebugPrintTextBox(tiles: hl, lines: e, line_length: d)
;@ path: system/debug
;@ Sets the text box size, then prints system text wTextIndex of group 0 into the tiles at `tiles`
;@ (DebugPrintText).
;@ test: skip calls a routine in another bank
DebugPrintTextBox::
;> wTextBoxLines = lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = line_length
	ld a, d
	ld [wTextBoxLineLength], a

;@ def DebugPrintText(tiles: hl)
;@ path: system/debug
;@ Prints system text wTextIndex of group 0 (the debug texts) into the text tiles at `tiles`.
;@ test: skip calls a routine in another bank
DebugPrintText::
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
	ret


;@ def FillTileBlock(pos: hl, width: b, height: c, first: a)
;@ path: system/debug
;@ Fills a `width` x `height` block of the background map at `pos` with consecutive tile numbers from
;@ `first` on, row by row (the screen must be off).
;@ test: width = rand(1, 20); height = rand(1, 18); pos = 0x9800 + rand(0, 0x100)
FillTileBlock::
;>@loop for _ in range(height):
	push hl
	ld d, b

.col
;>     for i in range(width): mem[pos + i] = first; first = (first + 1) & 0xFF
	ld [hli], a
	inc a
	dec b
	jr nz, .col

	ld b, d
;>@p     pos += 0x20
	ld e, a
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
;=@p
	adc $00
	ld h, a
	ld a, e
;=@loop
	dec c
	jr nz, FillTileBlock

	ret


;@ def DebugMenuUpdate()
;@ path: system/debug
;@ Per-frame routine of game mode $07, the debug menu. SELECT leaves it for game mode $0B (clearing
;@ $DF00-$DF03 and $DF0B-$DF0C first); otherwise runs the page wGameModeStep. Ends with `reti`
;@ instead of `ret` on that path, which also enables interrupts.
;@ test: skip jump table dispatch
DebugMenuUpdate::
;> if wJoyPressed & 0x04:   # Select
	ld a, [wJoyPressed]
	bit 2, a
	jr z, .page

;>@clr     for a in (0xDF0B, 0xDF0C, 0xDF02, 0xDF03, 0xDF00, 0xDF01): mem[a] = 0
	xor a
	ld [wMsgViewRightDelay], a
	ld [wMsgViewLeftDelay], a
	ld [wMsgViewPageRow], a
	ld [wMsgViewCursor], a
;=@clr
	ld [wMsgViewRow], a
	ld [wMsgViewNumber], a
;>     wGameMode = 0x0B
	ld a, $0b
	ld [wGameMode], a
;>     wGameModeStep = 0
	xor a
	ld [wGameModeStep], a
;>     wGameModeChange += 1
;>     return
	ld hl, wGameModeChange
	inc [hl]
	reti

.page
;> DebugPages[wGameModeStep]()
	ld a, [wGameModeStep]
	rst $00

	dw DebugMainPage
	dw DebugModeJumpPage
	dw DebugMonsterViewPage
	dw DebugWarpPage
	dw DebugSoundTestPage
	dw DebugBattlePage

;@ def DebugMainPage()
;@ path: system/debug
;@ Main debug page: up/down (also left/right) moves the cursor over the 6 lines (debug value 0); the
;@ cursor line is highlighted by remapping row $9922 to that line's tiles. A opens page 1-5 (program
;@ jump, monster pictures, map edit, sound test, battle) or, on the last line, returns to the game
;@ mode that was running when the menu was opened.
;@ test: skip polls the LCD
DebugMainPage::
;> if wJoyRepeat & 0x90:   # Down / Right
	ld a, [wJoyRepeat]
	and $90
	jr z, .notDown

;>     line = (mem[0xC0A0] + 1) % 6
	ld a, [wNumberBackup]
	inc a
	cp $06
	jr nz, .moved

	ld a, $00
	jr .moved

;> elif wJoyRepeat & 0x60:   # Up / Left
.notDown
	ld a, [wJoyRepeat]
	and $60
	jr z, .draw

;>     line = (mem[0xC0A0] - 1) % 6
	ld a, [wNumberBackup]
	dec a
	cp $ff
	jr nz, .moved

	ld a, $05

.moved
;>     mem[0xC0A0] = line
	ld [wNumberBackup], a
;>     QueueSound(0x59)                   # cursor click
	ld a, $59
	call QueueSound

.draw
;> tile = 0xA0 + mem[0xC0A0] * 16
	ld a, [wNumberBackup]
	swap a
	add $a0
;> pos = 0x9922
	ld hl, $9922
	ld b, $10
;> for _ in range(16): pos = WriteVRAMInc(tile, pos); tile += 1
.row
	call WriteVRAMInc
	inc a
	dec b
	jr nz, .row

;> if not wJoyPressed & 0x01:   # A
;>     return
	ld a, [wJoyPressed]
	and $01
	ret z

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> if mem[0xC0A0] != 5:
	ld a, [wNumberBackup]
	cp $05
	jr z, .back

;>     wGameModeStep = mem[0xC0A0] + 1   # open that page
	inc a
	ld [wGameModeStep], a
;>     wGameModeChange += 1
;>     return
	ld hl, wGameModeChange
	inc [hl]
	ret

.back
;>@back for i in range(4): mem[wGameMode + i] = wDebugSavedMode[i]   # mode, step, scene, logo
	ld hl, wGameMode
	ld a, [wDebugSavedMode]
	ld [hli], a
	ld a, [wDebugSavedMode + 1]
	ld [hli], a
;=@back
	ld a, [wDebugSavedMode + 2]
	ld [hli], a
	ld a, [wDebugSavedMode + 3]
	ld [hl], a
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret


;@ def DebugModeJumpPage()
;@ path: system/debug
;@ "GOTOPRG" page: four hex values (game mode, step, opening scene, logo) picked with up/down, changed
;@ with right/left (A zeroes one). START jumps to that game mode, after making up a random encounter
;@ (three random monster numbers, group size random % 3); B returns to the main page. The values are
;@ drawn every frame with the chosen one blinking, and the name of the chosen mode next to them.
;@ test: skip calls Random and polls the LCD
DebugModeJumpPage::
;> if wJoyPressed & 0x08:   # Start
	ld a, [wJoyPressed]
	and $08
	jr z, .edit

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>@rnd     for i in (0, 2, 4):
;>         Random(); wEncSpecies[i] = wRandomHigh + 1
	call Random
	ld a, [wRandomHigh]
	inc a
	ld [wEncSpecies], a
;=@rnd
	call Random
	ld a, [wRandomHigh]
	inc a
	ld [wEncSpecies + 2], a
;=@rnd
	call Random
	ld a, [wRandomHigh]
	inc a
	ld [wEncSpecies + 4], a
;>     Random()
	call Random
;>     wEncCount = wRandomHigh % 3
	ld a, [wRandomHigh]
	ld b, a
	ld a, $03
	call Divide8
	ld [wEncCount], a
;>     StartFade(4)
	ld a, $04
	call StartFade
;>     wGameMode = mem[0xC0A0]
	ld hl, wNumberBackup
	ld a, [hli]
	ld [wGameMode], a
;>     wGameModeStep = mem[0xC0A1]
	ld a, [hli]
	ld [wGameModeStep], a
;>     wOpeningScene = mem[0xC0A2]
	ld a, [hli]
	ld [wOpeningScene], a
;>     wOpeningLogo = mem[0xC0A3]
	ld a, [hli]
	ld [wOpeningLogo], a
;>     wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
;>     wFieldFlags = 0
	xor a
	ld [wFieldFlags], a
;>     wGameStarted = 0
;>     return
	xor a
	ld [wGameStarted], a
	ret

.edit
;> if wJoyRepeat & 0x40:   # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .notUp

;>@up     wMenuChoice = (wMenuChoice - 1) & 3
	ld a, [wMenuChoice]
	dec a
	jr .moved

;> elif wJoyRepeat & 0x80:   # Down
.notUp
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, .change

;>@dn     wMenuChoice = (wMenuChoice + 1) & 3
	ld a, [wMenuChoice]
	inc a

.moved
;=@up
;=@dn
	and $03
	ld [wMenuChoice], a
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound

.change
;> p = 0xC0A0 + wMenuChoice
	ld a, [wMenuChoice]
	ld c, a
	ld b, $00
	ld hl, wNumberBackup
	add hl, bc
;> if wJoyRepeat & 0x10:   # Right
	ld a, [wJoyRepeat]
	and $10
	jr z, .notRight

;>@r     mem[p] = (mem[p] + 1) & 0xFF; QueueSound(0x59)
	inc [hl]
	jr .changed

;> elif wJoyRepeat & 0x20:   # Left
.notRight
	ld a, [wJoyRepeat]
	and $20
	jr z, .notLeft

;>@l     mem[p] = (mem[p] - 1) & 0xFF; QueueSound(0x59)
	dec [hl]
	jr .changed

;> elif wJoyPressed & 0x01:   # A
.notLeft
	ld a, [wJoyPressed]
	and $01
	jr z, .back

;>     mem[p] = 0; QueueSound(0x59)
	xor a
	ld [hl], a

.changed
;=@r
;=@l
	ld a, $59
	call QueueSound

.back
;> if wJoyPressed & 0x02:   # B
	ld a, [wJoyPressed]
	and $02
	jr z, .draw

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wGameModeStep = 0                  # back to the main page
	xor a
	ld [wGameModeStep], a
;>     wGameModeChange += 1
;>     return
	ld hl, wGameModeChange
	inc [hl]
	ret

.draw
;> src, pos = 0xC0A0, 0x98CD
	ld de, wNumberBackup
	ld hl, $98cd
	ld b, $01
	ld c, $04
;> for c in range(4, 0, -1):
.line
	push de
	push hl
	push bc
;>@bl     if wMenuChoice + c == 4 and not wFrameCounter & 8:   # the chosen value blinks
	ld a, [wMenuChoice]
	add c
	cp $04
	jr nz, .show

;=@bl
	ld a, [wFrameCounter]
	bit 3, a
	jr nz, .show

;>         pos = WriteVRAMInc(0, pos); WriteVRAMInc(0, pos)
	xor a
	call WriteVRAMInc
	call WriteVRAMInc
	jr .next

;>     else:
.show
;>         DrawHexByte(mem[src], pos)
	ld a, [de]
	call DrawHexByte

.next
;>@nx     pos += 0x20; src += 1
	pop bc
	pop hl
	pop de
	ld a, l
	add $20
	ld l, a
;=@nx
	ld a, h
	adc $00
	ld h, a
	inc de
	dec c
	jr nz, .line

;> tile = 0x80 + mem[0xC0A0] * 8       # name of the chosen game mode
	ld a, [wNumberBackup]
	add a
	add a
	add a
	add $80
;> pos = 0x98C4
	ld hl, $98c4
	ld b, $08
;> for _ in range(8): pos = WriteVRAMInc(tile, pos); tile += 1
.name
	call WriteVRAMInc
	inc a
	dec b
	jr nz, .name

	ret


;@ def DebugMonsterViewPage()
;@ path: system/debug
;@ Monster picture page: shows the number wMenuChoice in decimal; up/down steps through the monsters
;@ and shows the new one (ShowDebugMonster, which follows); B returns to the main page.
;@ test: skip polls the LCD
DebugMonsterViewPage::
;> DrawNumberDigits(wMenuChoice, 0x9988, digit_base=1, blank=0)
	ld hl, $9988
	ld a, [wMenuChoice]
	ld b, $01
	ld c, $00
	call DrawNumberDigits
;> if wJoyPressed & 0x02:   # B
	ld a, [wJoyPressed]
	and $02
	jr z, .move

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wGameModeStep = 0
	xor a
	ld [wGameModeStep], a
;>     wGameModeChange += 1
;>     return
	ld hl, wGameModeChange
	inc [hl]
	ret

.move
;> if wJoyRepeat & 0x40:   # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .notUp

;>     choice = wMenuChoice - 1
	ld a, [wMenuChoice]
	dec a
	jr .moved

;> elif wJoyRepeat & 0x80:   # Down
.notUp
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_055_4da3

;>     choice = wMenuChoice + 1
	ld a, [wMenuChoice]
	inc a
;> else:
;>     return
.moved
;> wMenuChoice = choice & 0xFF
	ld [wMenuChoice], a
;> QueueSound(0x59)
;> ShowDebugMonster()                     # (runs on into it)
	ld a, $59
	call QueueSound

;@ def ShowDebugMonster()
;@ path: system/debug
;@ Shows monster picture wMenuChoice: decompresses it (pointer table at $2B9F in bank 0) to $8800,
;@ loads its palette and prints its name into the tiles at $8A40.
;@ test: skip calls routines in other banks
ShowDebugMonster::
;>@pic pic = mem16[0x2B9F + 2 * wMenuChoice]   # bank and entry of the compressed picture
	ld a, [wMenuChoice]
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add $9f
;=@pic
	ld l, a
	ld a, h
	adc $2b
	ld h, a
	ld e, [hl]
	inc hl
;=@pic
	ld d, [hl]
;> DecompressVRAM(pic >> 8, pic & 0xFF, 0x8800)
	ld hl, $8800
	call DecompressVRAM
;> wPaletteSet = wMenuChoice
	ld a, [wMenuChoice]
	ld [wPaletteSet], a
;> wMonPicPalette = 4
	ld a, $04
	ld [wMonPicPalette], a
;> wMonPicPos = 0x0087
	ld hl, $0087
	ld a, l
	ld [wMonPicPos], a
	ld a, h
	ld [wMonPicPos + 1], a
;> LoadMonPicPalette()
	ld hl, far_LoadMonPicPalette
	rst $10
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
;> wTextIndex = wMenuChoice
	ld a, [wMenuChoice]
	ld [wTextIndex], a
;> wTextGroup = 5                         # monster names
	ld a, $05
	ld [wTextGroup], a
;> wTextBoxLines = 1
	ld hl, $0901
	ld a, l
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 9
	ld a, h
	ld [wTextBoxLineLength], a
;> wTextTiles = 0x8A40
	ld hl, $8a40
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> ClearTextBoxTiles()
	ld hl, far_ClearTextBoxTiles
	rst $10
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
jr_055_4da3:
	ret



;@ def DebugWarpPage()
;@ path: system/debug
;@ "EDIT" page: eight values picked with up/down and changed with right/left (A zeroes one): 0 floor
;@ flag (0-1), 1 map ($00-$5F), 2 party count (0-3), 3-5 the party slots (0-9), 6 a value for hNumber,
;@ 7 the debug set-up flag. START warps there (game mode 1, the field); B also takes the values over
;@ but returns to the main debug page. The values are drawn as hex every frame, the chosen one blinks.
;@ test: skip polls the LCD
DebugWarpPage::
;> if not wJoyPressed & 0x08:             # no Start
;>     return DebugWarpEdit()
	ld a, [wJoyPressed]
	and $08
	jr z, DebugWarpEdit

;> StartFade(4)
	ld a, $04
	call StartFade
;> wGameMode = 1                          # the field
	ld a, $01
	ld [wGameMode], a
;> wGameModeStep = 0
;> DebugWarpApply()                       # (runs on into it)
	ld a, $00
	ld [wGameModeStep], a

;@ def DebugWarpApply()
;@ path: system/debug
;@ Part of DebugWarpPage: copies the eight edit values into the game (floor flag, map, party, debug
;@ set-up), queues a warp to that map and switches game mode.
;@ test: skip writes many game variables
DebugWarpApply::
;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> wOnGateFloor = mem[0xC0A0]
	ld hl, wNumberBackup
	ld a, [hli]
	ld [wOnGateFloor], a
;> wMapId = mem[0xC0A1]
	ld a, [hli]
	ld [wMapId], a
;> wPartyCount = mem[0xC0A2]
	ld a, [hli]
	ld [wPartyCount], a
;>@p for i in range(3): wParty[i] = mem[0xC0A3 + i]
	ld a, [hli]
	ld [wParty], a
	ld a, [hli]
	ld [wParty + 1], a
;=@p
	ld a, [hli]
	ld [wParty + 2], a
;> hNumber[0] = mem[0xC0A6]
	ld a, [hli]
	ldh [hNumber], a
;> wDebugSetup = mem[0xC0A7]
	ld a, [hl]
	ld [wDebugSetup], a
;> wGameStarted = wOnGateFloor
	ld a, [wOnGateFloor]
	ld [wGameStarted], a
;> wWarpPending = wOnGateFloor
	ld a, [wOnGateFloor]
	ld [wWarpPending], a
;> wWarpMap = wMapId
	ld a, [wMapId]
	ld [wWarpMap], a
;> wWarpOnGateFloor = wOnGateFloor
	ld a, [wOnGateFloor]
	ld [wWarpOnGateFloor], a
;> wGateWorld = 0
	xor a
	ld [wGateWorld], a
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
;> wFieldFlags = 0
	xor a
	ld [wFieldFlags], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
	ret


;@ def DebugWarpEdit()
;@ path: system/debug
;@ Part of DebugWarpPage: moves the cursor, changes the chosen value (DebugWarpRefresh wraps it and
;@ redraws the names), handles B and draws the values.
;@ test: skip polls the LCD
DebugWarpEdit::
;> if wJoyRepeat & 0x40:                  # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .notUp

;>@up     wMenuChoice = (wMenuChoice - 1) & 7
	ld a, [wMenuChoice]
	dec a
	jr .moved

;> elif wJoyRepeat & 0x80:                # Down
.notUp
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, .change

;>@dn     wMenuChoice = (wMenuChoice + 1) & 7
	ld a, [wMenuChoice]
	inc a

.moved
;=@up
;=@dn
	and $07
	ld [wMenuChoice], a
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound

.change
;> p = 0xC0A0 + wMenuChoice
	ld a, [wMenuChoice]
	ld c, a
	ld b, $00
	ld hl, wNumberBackup
	add hl, bc
;> if wJoyRepeat & 0x10:                  # Right
	ld a, [wJoyRepeat]
	and $10
	jr z, .notRight

;>@r     mem[p] = (mem[p] + 1) & 0xFF
	inc [hl]
	jr .changed

;> elif wJoyRepeat & 0x20:                # Left
.notRight
	ld a, [wJoyRepeat]
	and $20
	jr z, .notLeft

;>@l     mem[p] = (mem[p] - 1) & 0xFF
	dec [hl]
	jr .changed

;> elif wJoyPressed & 0x01:               # A
.notLeft
	ld a, [wJoyPressed]
	and $01
	jr z, .back

;>     mem[p] = 0
	xor a
	ld [hl], a
;> if wJoyRepeat & 0x30 or wJoyPressed & 0x01:   # a value was changed
.changed
;=@r
;=@l
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     limit = (2, 0x60, 4, 10, 10, 10)[wMenuChoice] if wMenuChoice < 6 else None
	ld a, [wMenuChoice]
	ld b, $02
	cp $00
;>@w     if limit: DebugWarpRefresh(limit)
	call z, DebugWarpRefresh
;=@w
	ld b, $60
	cp $01
	call z, DebugWarpRefresh
	ld b, $04
	cp $02
	call z, DebugWarpRefresh
;=@w
	ld b, $0a
	cp $03
	call z, DebugWarpRefresh
	ld b, $0a
	cp $04
	call z, DebugWarpRefresh
;=@w
	ld b, $0a
	cp $05
	call z, DebugWarpRefresh

.back
;> if wJoyPressed & 0x02:                 # B
	ld a, [wJoyPressed]
	and $02
	jr z, .draw

;>     wGameModeStep = 0                  # back to the main page, keeping the values
;>     return DebugWarpApply()
	xor a
	ld [wGameModeStep], a
	jp DebugWarpApply

.draw
;> src, pos = 0xC0A0, 0x98CC
	ld de, wNumberBackup
	ld hl, $98cc
	ld b, $01
	ld c, $08
;> for c in range(8, 0, -1):
.line
	push de
	push hl
	push bc
;>@bl     if wMenuChoice + c == 8 and not wFrameCounter & 8:   # the chosen value blinks
	ld a, [wMenuChoice]
	add c
	cp $08
	jr nz, .show

;=@bl
	ld a, [wFrameCounter]
	bit 3, a
	jr nz, .show

;>         for _ in range(3): pos = WriteVRAMInc(0, pos)
	xor a
	call WriteVRAMInc
	call WriteVRAMInc
	call WriteVRAMInc
	jr .next

;>     else:
.show
;>         DrawHexDigits(mem[src], pos, digit_base=1)
	ld a, [de]
	ld b, $01
	ld c, $00
	call DrawHexDigits

.next
;>@nx     pos += 0x20; src += 1
	pop bc
	pop hl
	pop de
	ld a, l
	add $20
	ld l, a
;=@nx
	ld a, h
	adc $00
	ld h, a
	inc de
	dec c
	jr nz, .line

;> return
	ret

;@ def DebugWarpRefresh(limit: b)
;@ path: system/debug
;@ Wraps the chosen edit value into 0..limit-1 (limit becomes 0, $FF becomes limit-1), then prints
;@ the names that go with the values: the map type (system text group 1, entry value 0) at $8800,
;@ the map name (group 1, entry value 1 + 4, or "STAGEID" on a floor) at $8870, and group 4 entries
;@ for the three party values, and maps their tiles. Keeps a.
;@ test: skip calls routines in other banks
DebugWarpRefresh::
;>@p p = 0xC0A0 + wMenuChoice
	push af
	ld a, [wMenuChoice]
	ld hl, wNumberBackup
	add l
	ld l, a
	ld a, $00
;=@p
	adc h
	ld h, a
;> if mem[p] == limit:
;>     mem[p] = 0
	ld a, [hl]
	cp b
	jr nz, .notTop

	ld [hl], $00

.notTop
;> if mem[p] == 0xFF:
;>     mem[p] = limit - 1
	ld a, [hl]
	cp $ff
	jr nz, .names

	dec b
	ld [hl], b

.names
;> wTextIndex = mem[0xC0A0]
	ld a, [wNumberBackup]
	ld [wTextIndex], a
;> wTextGroup = 1                         # the debug labels
	ld a, $01
	ld [wTextGroup], a
;> wTextBoxLines = 1
	ld hl, $0701
	ld a, l
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 7
	ld a, h
	ld [wTextBoxLineLength], a
;> PrintTextAt(0x8800)
	ld hl, $8800
	call PrintTextAt
;>@ti wTextIndex = 3 if mem[0xC0A0] else mem[0xC0A1] + 4
	ld a, [wNumberBackup]
	cp $00
	jr z, .mapName

	ld a, $03
	jr .second

.mapName
;=@ti
	ld a, [wNumberBackup + 1]
	add $04

.second
	ld [wTextIndex], a
;> wTextGroup = 1
	ld a, $01
	ld [wTextGroup], a
;> wTextBoxLines = 1
	ld hl, $0701
	ld a, l
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 7
	ld a, h
	ld [wTextBoxLineLength], a
;> PrintTextAt(0x8870)
	ld hl, $8870
	call PrintTextAt
;> wTextGroup = 4
	ld a, $04
	ld [wTextGroup], a
;> wTextIndex = mem[0xC0A3]
	ld a, [wLineUpOrder]
	ld [wTextIndex], a
;> PrintTextAt(0x88E0)
	ld hl, $88e0
	call PrintTextAt
;> wTextIndex = mem[0xC0A4]
	ld a, [wLineUpOrder + 1]
	ld [wTextIndex], a
;> PrintTextAt(0x8950)
	ld hl, $8950
	call PrintTextAt
;> wTextIndex = mem[0xC0A5]
	ld a, [wLineUpOrder + 2]
	ld [wTextIndex], a
;> PrintTextAt(0x89C0)
	ld hl, $89c0
	call PrintTextAt
;> tile = 0x80
	ld hl, $98d0
	ld a, $80
;>@rows for pos in (0x98D0, 0x98F0, 0x9930, 0x9950, 0x9970): tile = WriteTileRun2(pos, tile, 7)
	ld b, $07
	call WriteTileRun2
;=@rows
	ld hl, $98f0
	ld b, $07
	call WriteTileRun2
;=@rows
	ld hl, $9930
	ld b, $07
	call WriteTileRun2
;=@rows
	ld hl, $9950
	ld b, $07
	call WriteTileRun2
;=@rows
	ld hl, $9970
	ld b, $07
	call WriteTileRun2
	pop af
	ret


;@ def WriteTileRun2(pos: hl, tile: a, count: b) -> a
;@ path: system/debug
;@ Same as WriteTileRun: `count` consecutive tile numbers from `tile` to the background map at `pos`.
;@ test: skip polls the LCD
WriteTileRun2::
;> for _ in range(count):
;>     pos = WriteVRAMInc(tile, pos); tile += 1
	call WriteVRAMInc
	inc a
	dec b
	jr nz, WriteTileRun2

;> return tile
	ret


;@ def PrintTextAt(tiles: hl)
;@ path: system/debug
;@ Prints system text wTextGroup/wTextIndex into the text tiles at `tiles` (after far 56_4485).
;@ test: skip calls routines in other banks
PrintTextAt::
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> ClearTextBoxTiles()
	ld hl, far_ClearTextBoxTiles
	rst $10
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
	ret



;@ def DebugSoundTestPage()
;@ path: system/debug
;@ "SOUND" page: two numbers, the song (BGM) and the sound effect (SE), each an index into
;@ DebugMusicList / DebugSoundList; up/down picks one, right/left changes it (A zeroes it). START
;@ plays the chosen one, B returns to the main page. Each line shows the index and the real number.
;@ test: skip polls the LCD
DebugSoundTestPage::
;> if wJoyPressed & 0x08:                 # Start
	ld a, [wJoyPressed]
	and $08
	jr z, .edit

;>     if wMenuChoice == 0:
	ld a, [wMenuChoice]
	or a
	jr nz, .effect

;>@mus         QueueMusic(DebugMusicList[mem[0xC0A0]]); return
	ld a, [wNumberBackup]
	ld hl, DebugMusicList
	add l
	ld l, a
	ld a, $00
	adc h
;=@mus
	ld h, a
	ld a, [hl]
	call QueueMusic
	ret

;>     InitSound()
.effect
	call InitSound
;>@se     QueueSound(DebugSoundList[mem[0xC0A1]]); return
	ld a, [wNumberBackup + 1]
	ld hl, DebugSoundList
	add l
	ld l, a
	ld a, $00
	adc h
;=@se
	ld h, a
	ld a, [hl]
	call QueueSound
	ret

.edit
;> if wJoyRepeat & 0x40:                  # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .notUp

;>@up     wMenuChoice = (wMenuChoice - 1) & 1
	ld a, [wMenuChoice]
	dec a
	jr .moved

;> elif wJoyRepeat & 0x80:                # Down
.notUp
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, .change

;>@dn     wMenuChoice = (wMenuChoice + 1) & 1
	ld a, [wMenuChoice]
	inc a

.moved
;=@up
;=@dn
	and $01
	ld [wMenuChoice], a
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound

.change
;> p = 0xC0A0 + wMenuChoice
	ld a, [wMenuChoice]
	ld c, a
	ld b, $00
	ld hl, wNumberBackup
	add hl, bc
;> if wJoyRepeat & 0x10:                  # Right
	ld a, [wJoyRepeat]
	and $10
	jr z, .notRight

;>@r     mem[p] = (mem[p] + 1) & 0xFF
	inc [hl]
	jr .changed

;> elif wJoyRepeat & 0x20:                # Left
.notRight
	ld a, [wJoyRepeat]
	and $20
	jr z, .notLeft

;>@l     mem[p] = (mem[p] - 1) & 0xFF
	dec [hl]
	jr .changed

;> elif wJoyPressed & 0x01:               # A
.notLeft
	ld a, [wJoyPressed]
	and $01
	jr z, .back

;>     mem[p] = 0
	xor a
	ld [hl], a
;> if wJoyRepeat & 0x30 or wJoyPressed & 0x01:   # a value was changed
.changed
;=@r
;=@l
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>@wrap     DebugWrapValue(0x20 if wMenuChoice == 0 else 0x40)   # 32 songs, 64 effects
	ld a, [wMenuChoice]
	ld b, $20
	cp $00
	call z, DebugWrapValue
	ld b, $40
	cp $01
;=@wrap
	call z, DebugWrapValue

.back
;> if wJoyPressed & 0x02:                 # B
	ld a, [wJoyPressed]
	and $02
	jr z, .draw

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wGameModeStep = 0
	xor a
	ld [wGameModeStep], a
;>     wGameModeChange += 1
;>     return
	ld hl, wGameModeChange
	inc [hl]
	ret

.draw
;> src, pos = 0xC0A0, 0x98CA
	ld de, wNumberBackup
	ld hl, $98ca
	ld b, $01
	ld c, $02
;> for c in (2, 1):
.line
	push de
	push hl
	push bc
;>@bl     if wMenuChoice + c == 2 and not wFrameCounter & 8:   # the chosen index blinks
	ld a, [wMenuChoice]
	add c
	cp $02
	jr nz, .show

;=@bl
	ld a, [wFrameCounter]
	bit 3, a
	jr nz, .show

;>         pos = WriteVRAMInc(0, pos); WriteVRAMInc(0, pos)
	xor a
	call WriteVRAMInc
	call WriteVRAMInc
	jr .number

;>     else:
.show
;>         DrawHexByte(mem[src], pos)
	ld a, [de]
	call DrawHexByte

.number
;>@tb     table = DebugMusicList if c == 2 else DebugSoundList
	pop bc
	push bc
	ld a, c
	ld bc, DebugSoundList
	cp $02
	jr nz, .list

;=@tb
	ld bc, DebugMusicList

.list
;>@num     DrawHexByte(mem[table + mem[src]], pos + 1)   # the real song / effect number
	ld a, [de]
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
;=@num
	ld a, [bc]
	inc hl
	call DrawHexByte
;>@nx     pos += 0x20; src += 1
	pop bc
	pop hl
	pop de
	ld a, l
	add $20
	ld l, a
;=@nx
	ld a, h
	adc $00
	ld h, a
	inc de
	dec c
	jr nz, .line

;> return
	ret


;@ def DebugWrapValue(limit: b)
;@ path: system/debug
;@ Wraps the chosen debug value (0xC0A0 + wMenuChoice) into 0..limit-1: limit becomes 0, $FF becomes
;@ limit-1. Keeps a.
;@ test: wMenuChoice = rand(0, 7); limit = rand(1, 0xFF)
DebugWrapValue::
;>@p p = 0xC0A0 + wMenuChoice
	push af
	ld a, [wMenuChoice]
	ld hl, wNumberBackup
	add l
	ld l, a
	ld a, $00
;=@p
	adc h
	ld h, a
;> if mem[p] == limit:
;>     mem[p] = 0
	ld a, [hl]
	cp b
	jr nz, .notTop

	ld [hl], $00

.notTop
;> if mem[p] == 0xFF:
;>     mem[p] = limit - 1
	ld a, [hl]
	cp $ff
	jr nz, .done

	dec b
	ld [hl], b

.done
;> return                                 # (a kept)
	pop af
	ret

;@ path: system/debug
;@ Songs the sound test plays, by index (32 entries).
DebugMusicList::
	db $02, $06, $09, $0c, $0f, $12, $15, $18, $1b, $1e, $21, $24, $27, $2b, $2e, $31
	db $34, $37, $3a, $3c, $3f, $41, $44, $47, $49, $4b, $4d, $4f, $9f, $00, $00, $00

;@ path: system/debug
;@ Sound effects the sound test plays, by index (64 entries, then two zero bytes).
DebugSoundList::
	db $00, $51, $52, $53, $54, $55, $56, $57, $59, $5a, $5b, $5c, $5d, $5f, $60, $61
	db $64, $65, $66, $67, $68, $69, $6b, $6c, $6d, $6e, $6f, $70, $71, $72, $73, $74
	db $76, $78, $7a, $7b, $7c, $7e, $7f, $80, $81, $82, $83, $84, $85, $86, $88, $89
	db $8a, $8c, $8d, $8e, $8f, $90, $92, $93, $94, $95, $96, $97, $99, $9b, $9c, $9d
	db $00, $00

;@ def DebugBattlePage()
;@ path: system/debug
;@ "BATTLE" page: eight values, the encounter group size (0-2) and three monster numbers as u16
;@ (low byte, high byte 0-1), changed like on the other pages. START sets up a debug game
;@ (DebugSetUpGame, with at least one monster in the party) and starts the battle (game mode 2); B
;@ takes the values over and returns to the main page.
;@ test: skip calls routines in other banks
DebugBattlePage::
;> if not wJoyPressed & 0x08:             # no Start
;>     return DebugBattleEdit()
	ld a, [wJoyPressed]
	and $08
	jr z, DebugBattleEdit

;> StartFade(4)
	ld a, $04
	call StartFade
;> wGameMode = 2                          # battle
	ld a, $02
	ld [wGameMode], a
;> wGameModeStep = 0
	ld a, $00
	ld [wGameModeStep], a
;> DebugSetUpGame()
	call DebugSetUpGame
;> if wPartyCount == 0:
;>     wPartyCount += 1
	ld a, [wPartyCount]
	or a
	jr nz, DebugBattleApply

	ld hl, wPartyCount
	inc [hl]
;> DebugBattleApply()                     # (runs on into it)

;@ def DebugBattleApply()
;@ path: system/debug
;@ Part of DebugBattlePage: copies the group size and the three monster numbers into the encounter
;@ and switches game mode.
;@ test: skip calls a routine in another bank
DebugBattleApply::
;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> wEncCount = mem[0xC0A0]
	ld hl, wNumberBackup
	ld a, [hli]
	ld [wEncCount], a
;>@sp for i in range(6): wEncSpecies[i] = mem[0xC0A1 + i]
	ld a, [hli]
	ld [wEncSpecies], a
	ld a, [hli]
	ld [wEncSpecies + 1], a
;=@sp
	ld a, [hli]
	ld [wEncSpecies + 2], a
	ld a, [hli]
	ld [wEncSpecies + 3], a
;=@sp
	ld a, [hli]
	ld [wEncSpecies + 4], a
	ld a, [hli]
	ld [wEncSpecies + 5], a
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret


;@ def DebugBattleEdit()
;@ path: system/debug
;@ Part of DebugBattlePage: moves the cursor, changes the chosen value (DebugBattleRefresh wraps it and
;@ shows the monsters' names), handles B and draws the values.
;@ test: skip polls the LCD
DebugBattleEdit::
;> if wJoyRepeat & 0x40:                  # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .notUp

;>@up     wMenuChoice = (wMenuChoice - 1) & 7
	ld a, [wMenuChoice]
	dec a
	jr .moved

;> elif wJoyRepeat & 0x80:                # Down
.notUp
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, .change

;>@dn     wMenuChoice = (wMenuChoice + 1) & 7
	ld a, [wMenuChoice]
	inc a

.moved
;=@up
;=@dn
	and $07
	ld [wMenuChoice], a
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound

.change
;> p = 0xC0A0 + wMenuChoice
	ld a, [wMenuChoice]
	ld c, a
	ld b, $00
	ld hl, wNumberBackup
	add hl, bc
;> if wJoyRepeat & 0x10:                  # Right
	ld a, [wJoyRepeat]
	and $10
	jr z, .notRight

;>@r     mem[p] = (mem[p] + 1) & 0xFF
	inc [hl]
	jr .changed

;> elif wJoyRepeat & 0x20:                # Left
.notRight
	ld a, [wJoyRepeat]
	and $20
	jr z, .notLeft

;>@l     mem[p] = (mem[p] - 1) & 0xFF
	dec [hl]
	jr .changed

;> elif wJoyPressed & 0x01:               # A
.notLeft
	ld a, [wJoyPressed]
	and $01
	jr z, .back

;>     mem[p] = 0
	xor a
	ld [hl], a
;> if wJoyRepeat & 0x30 or wJoyPressed & 0x01:   # a value was changed
.changed
;=@r
;=@l
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     limit = (3, 0, 2, 0, 2, 0, 2)[wMenuChoice] if wMenuChoice < 7 else None   # 0 = 256
	ld a, [wMenuChoice]
	ld b, $03
	cp $00
;>@w     if limit is not None: DebugBattleRefresh(limit)
	call z, DebugBattleRefresh
;=@w
	ld b, $00
	cp $01
	call z, DebugBattleRefresh
	ld b, $02
	cp $02
	call z, DebugBattleRefresh
;=@w
	ld b, $00
	cp $03
	call z, DebugBattleRefresh
	ld b, $02
	cp $04
	call z, DebugBattleRefresh
;=@w
	ld b, $00
	cp $05
	call z, DebugBattleRefresh
	ld b, $02
	cp $06
	call z, DebugBattleRefresh

.back
;> if wJoyPressed & 0x02:                 # B
	ld a, [wJoyPressed]
	and $02
	jr z, .draw

;>     wGameModeStep = 0                  # back to the main page, keeping the values
;>     return DebugBattleApply()
	xor a
	ld [wGameModeStep], a
	jp DebugBattleApply

.draw
;> src, pos = 0xC0A0, 0x98CB
	ld de, wNumberBackup
	ld hl, $98cb
	ld b, $01
	ld c, $08
;> for c in range(8, 0, -1):
.line
	push de
	push hl
	push bc
;>@bl     if wMenuChoice + c == 8 and not wFrameCounter & 8:   # the chosen value blinks
	ld a, [wMenuChoice]
	add c
	cp $08
	jr nz, .show

;=@bl
	ld a, [wFrameCounter]
	bit 3, a
	jr nz, .show

;>         for _ in range(3): pos = WriteVRAMInc(0, pos)
	xor a
	call WriteVRAMInc
	call WriteVRAMInc
	call WriteVRAMInc
	jr .next

;>     else:
.show
;>         DrawHexDigits(mem[src], pos, digit_base=1)
	ld a, [de]
	ld b, $01
	ld c, $00
	call DrawHexDigits

.next
;>@nx     pos += 0x20; src += 1
	pop bc
	pop hl
	pop de
	ld a, l
	add $20
	ld l, a
;=@nx
	ld a, h
	adc $00
	ld h, a
	inc de
	dec c
	jr nz, .line

;> return
	ret

;@ def DebugBattleRefresh(limit: b)
;@ path: system/debug
;@ Wraps the chosen value into 0..limit-1 (a limit of 0 leaves the full byte range), copies the three
;@ monster numbers into wEncSpecies and prints each monster's name (LoadMonTemplate gives its name
;@ text) into the tiles at $8800, $8890 and $8920, then maps three rows of 9 tiles. Keeps a.
;@ test: skip calls routines in other banks
DebugBattleRefresh::
;>@p p = 0xC0A0 + wMenuChoice
	push af
	ld a, [wMenuChoice]
	ld hl, wNumberBackup
	add l
	ld l, a
	ld a, $00
;=@p
	adc h
	ld h, a
;> if mem[p] == limit:
;>     mem[p] = 0
	ld a, [hl]
	cp b
	jr nz, .notTop

	ld [hl], $00

.notTop
;> if mem[p] == 0xFF:
;>     mem[p] = (limit - 1) & 0xFF
	ld a, [hl]
	cp $ff
	jr nz, .copy

	dec b
	ld [hl], b

.copy
;>@sp for i in range(6): wEncSpecies[i] = mem[0xC0A1 + i]
	ld a, [wNumberBackup + 1]
	ld [wEncSpecies], a
	ld a, [wNumberBackup + 2]
	ld [wEncSpecies + 1], a
;=@sp
	ld a, [wLineUpOrder]
	ld [wEncSpecies + 2], a
	ld a, [wLineUpOrder + 1]
	ld [wEncSpecies + 3], a
;=@sp
	ld a, [wLineUpOrder + 2]
	ld [wEncSpecies + 4], a
	ld a, [$c0a6]
	ld [wEncSpecies + 5], a
;>@id wNewMonId = wEncSpecies[0] | wEncSpecies[1] << 8
	ld a, [wEncSpecies]
	ld l, a
	ld a, [wEncSpecies + 1]
	ld h, a
	ld a, l
	ld [wNewMonId], a
;=@id
	ld a, h
	ld [wNewMonId + 1], a
;> LoadMonTemplate()
	ld hl, far_LoadMonTemplate
	rst $10
;> wTextBoxLines = 1
	ld hl, $0901
	ld a, l
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 9
	ld a, h
	ld [wTextBoxLineLength], a
;> wTextGroup = 5                         # monster names
	ld a, $05
	ld [wTextGroup], a
;> wTextIndex = wNewMonNameText
	ld a, [wNewMonNameText]
	ld [wTextIndex], a
;> PrintTextAt2(0x8800)
	ld hl, $8800
	call PrintTextAt2
;>@id2 wNewMonId = wEncSpecies[2] | wEncSpecies[3] << 8
	ld a, [wEncSpecies + 2]
	ld l, a
	ld a, [wEncSpecies + 3]
	ld h, a
	ld a, l
	ld [wNewMonId], a
;=@id2
	ld a, h
	ld [wNewMonId + 1], a
;> LoadMonTemplate()
	ld hl, far_LoadMonTemplate
	rst $10
;> wTextIndex = wNewMonNameText
	ld a, [wNewMonNameText]
	ld [wTextIndex], a
;> PrintTextAt2(0x8890)
	ld hl, $8890
	call PrintTextAt2
;>@id3 wNewMonId = wEncSpecies[4] | wEncSpecies[5] << 8
	ld a, [wEncSpecies + 4]
	ld l, a
	ld a, [wEncSpecies + 5]
	ld h, a
	ld a, l
	ld [wNewMonId], a
;=@id3
	ld a, h
	ld [wNewMonId + 1], a
;> LoadMonTemplate()
	ld hl, far_LoadMonTemplate
	rst $10
;> wTextIndex = wNewMonNameText
	ld a, [wNewMonNameText]
	ld [wTextIndex], a
;> PrintTextAt2(0x8920)
	ld hl, $8920
	call PrintTextAt2
;> tile = 0x80
	ld hl, $98ef
	ld a, $80
;>@rows for pos in (0x98EF, 0x992F, 0x996F): tile = WriteTileRun3(pos, tile, 9)
	ld b, $09
	call WriteTileRun3
;=@rows
	ld hl, $992f
	ld b, $09
	call WriteTileRun3
;=@rows
	ld hl, $996f
	ld b, $09
	call WriteTileRun3
	pop af
	ret


;@ def WriteTileRun3(pos: hl, tile: a, count: b) -> a
;@ path: system/debug
;@ Same as WriteTileRun: `count` consecutive tile numbers from `tile` to the background map at `pos`.
;@ test: skip polls the LCD
WriteTileRun3::
;> for _ in range(count):
;>     pos = WriteVRAMInc(tile, pos); tile += 1
	call WriteVRAMInc
	inc a
	dec b
	jr nz, WriteTileRun3

;> return tile
	ret


;@ def PrintTextAt2(tiles: hl)
;@ path: system/debug
;@ Same as PrintTextAt: prints system text wTextGroup/wTextIndex into the text tiles at `tiles`.
;@ test: skip calls routines in other banks
PrintTextAt2::
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> ClearTextBoxTiles()
	ld hl, far_ClearTextBoxTiles
	rst $10
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
	ret



;@ def DrawHexByte(value: a, pos: hl) -> hl
;@ path: system/debug
;@ Writes `value` as two hex digits to the background map at `pos` (digit tiles 1-16, as loaded from
;@ the debug text "0123456789ABCDEF").
;@ test: skip polls the LCD
DrawHexByte::
;> pos = WriteVRAMInc((value >> 4) + 1, pos)
	ld c, a
	swap a
	and $0f
	inc a
	call WriteVRAMInc
;> return WriteVRAMInc((value & 0x0F) + 1, pos)
	ld a, c
	and $0f
	inc a
	call WriteVRAMInc
	ret


;@ def DrawNumberDigits(value: a, pos: hl, digit_base: b, blank: c)
;@ path: system/debug
;@ Writes `value` as three decimal digits to the background map at `pos` (tile digit_base + digit),
;@ leading zeros as the tile `blank`.
;@ test: skip polls the LCD
DrawNumberDigits::
;> if value < 100:
	cp $64
	jr nc, .hundreds

;>     WriteBlankTile(blank, pos); pos += 1
	call WriteBlankTile
	inc hl
;>     tens = value >= 10
	cp $0a
	jr nc, .tens

;=@b
	call WriteBlankTile
	inc hl
	jr .ones

.hundreds
;> else:
;>     d, value = DivideAByE(value, 100); WriteDigitTile(d, pos); pos += 1; tens = True
	ld e, $64
	call DivideAByE
	call WriteDigitTile
	inc hl

.tens
;> if tens:
;>     d, value = DivideAByE(value, 10); WriteDigitTile(d, pos); pos += 1
	ld e, $0a
	call DivideAByE
	call WriteDigitTile
	inc hl
;> else:
;>@b     WriteBlankTile(blank, pos); pos += 1

.ones
;> WriteDigitTile(value, pos)
	ld d, a
	call WriteDigitTile
	ret


;@ def DivideAByE(n: a, d: e) -> (d, a)
;@ path: system/debug
;@ Division by repeated subtraction: returns n // d in d and n % d in a.
;@ test: e = rand(1, 255)
DivideAByE::
;> q = -1
	ld d, $ff

.loop
;> while True:
;>     q += 1; n -= d
	inc d
	sub e
;>     if n < 0: break
	jr nc, .loop

;> return (q & 0xFF, (n + d) & 0xFF)
	add e
	ret


;@ def WriteDigitTile(digit: d, pos: hl, digit_base: b)
;@ path: system/debug
;@ Writes tile digit_base + digit to the background map at `pos` (keeps a).
;@ test: skip polls the LCD
WriteDigitTile::
;> WriteVRAM(digit + digit_base, pos)
	push af
	ld a, d
	add b
	call WriteVRAM
	pop af
	ret


;@ def WriteBlankTile(blank: c, pos: hl)
;@ path: system/debug
;@ Writes tile `blank` to the background map at `pos` (keeps a).
;@ test: skip polls the LCD
WriteBlankTile::
;> WriteVRAM(blank, pos)
	push af
	ld a, c
	call WriteVRAM
	pop af
	ret


;@ def DrawHexDigits(value: a, pos: hl, digit_base: b) -> hl
;@ path: system/debug
;@ Writes `value` as two hex digits (tiles digit_base + digit) at pos + 1 and pos + 2.
;@ test: skip polls the LCD
DrawHexDigits::
;> WriteDigitTile(value >> 4, pos + 1)
	inc hl
	push af
	swap a
	and $0f
	ld d, a
	call WriteDigitTile
;> WriteDigitTile(value & 0x0F, pos + 2)
	inc hl
	pop af
	and $0f
	ld d, a
	call WriteDigitTile
	ret


;@ def DebugSetUpGame()
;@ path: system/debug
;@ Makes up a game to test with: a three-letter player name, all 20 monster records filled with
;@ random monsters (DebugMakeMonster), the first three in the party, 87040 gold and items 1-8.
;@ test: skip calls routines in other banks
DebugSetUpGame::
;> wPlayerName[0] = 0x6E
	ld a, $6e
	ld [wPlayerName], a
;> wPlayerName[1] = 0x86
	ld a, $86
	ld [wPlayerName + 1], a
;> wPlayerName[2] = 0x9C
	ld a, $9c
	ld [wPlayerName + 2], a
;> wPlayerName[3] = 0xF0                  # end of the name
	ld a, $f0
	ld [wPlayerName + 3], a
;> wPartyCount = 3
	ld a, $03
	ld [wPartyCount], a
;>@pt for i in range(3): wParty[i] = i
	ld a, $00
	ld [wParty], a
	ld a, $01
	ld [wParty + 1], a
;=@pt
	ld a, $02
	ld [wParty + 2], a
;>@mk for slot in range(20):
;>     DebugMakeMonster(slot)
	ld b, $14
	ld c, $00

.monster
	push bc
	ld a, c
	call DebugMakeMonster
;=@mk
	pop bc
	inc c
	dec b
	jr nz, .monster

;> wGold[0] = 0x00                        # 0x015400 = 87040 gold
	ld a, $00
	ld [wGold], a
;> wGold[1] = 0x54
	ld a, $54
	ld [wGold + 1], a
;> wGold[2] = 0x01
	ld a, $01
	ld [wGold + 2], a
;>@it for i in range(8): wBagItems[i] = i + 1
	ld a, $01
	ld [wBagItems], a
	ld a, $02
	ld [wBagItems + 1], a
;=@it
	ld a, $03
	ld [wBagItems + 2], a
	ld a, $04
	ld [wBagItems + 3], a
;=@it
	ld a, $05
	ld [wBagItems + 4], a
	ld a, $06
	ld [wBagItems + 5], a
;=@it
	ld a, $07
	ld [wBagItems + 6], a
	ld a, $08
	ld [wBagItems + 7], a
;>@pa for i in range(3): wMonsters[i * 0x95] = 2   # records 0-2: in the party
	ld a, $02
	ld [wMonsters], a
	ld a, $02
	ld [wMonsters + 149], a
;=@pa
	ld a, $02
	ld [wMonsters + 298], a
	ret


;@ def DebugMakeMonster(slot: a)
;@ path: system/debug
;@ Fills monster record `slot` with a random monster for testing: species 1-64 (CreateMonster), two
;@ random parent species (0-127), and random names for the monster, its parents and their masters.
;@ test: skip calls routines in other banks
DebugMakeMonster::
;> wNewMonSlot = slot
	push af
	ld [wNewMonSlot], a
;> Random()
	call Random
;> wNewMonId = (wRandomHigh & 0x3F) + 1
	ld a, [wRandomHigh]
	and $3f
	inc a
	ld [wNewMonId], a
	xor a
	ld [wNewMonId + 1], a
;> CreateMonster()
	ld hl, far_CreateMonster
	rst $10
;> wMonSpecies = Random() & 0x7F
	pop af
	push af
	call Random
	and $7f
	ld [wMonSpecies], a
;> SetMonsterField(slot, wMonParent1, wMonSpecies)
	ld hl, wMonParent1
	ld c, a
	pop af
	call SetMonsterField
	push af
	pop af
;> wMonSpecies = Random() & 0x7F
	push af
	call Random
	and $7f
	ld [wMonSpecies], a
;> SetMonsterField(slot, wMonParent2, wMonSpecies)
	ld hl, wMonParent2
	ld c, a
	pop af
	call SetMonsterField
	push af
	pop af
;> family = mem[MonsterField(slot, wMonFamily)]
	push af
	ld hl, wMonFamily
	call MonsterField
	ld a, [hl]
	ld c, a
;> SetRandomMonsterName(slot, wMonName, family)
	pop af
	ld hl, wMonName
	call SetRandomMonsterName
;> Random()
	push af
	call Random
;> SetRandomMonsterName(slot, wMonParent1Master, wRandomHigh & 7)
	ld a, [wRandomHigh]
	and $07
	ld c, a
	pop af
	ld hl, wMonParent1Master
	call SetRandomMonsterName
;> Random()
	push af
	call Random
;> SetRandomMonsterName(slot, wMonParent2Master, wRandomHigh & 7)
	ld a, [wRandomHigh]
	and $07
	ld c, a
	pop af
	ld hl, wMonParent2Master
	call SetRandomMonsterName
;> wMonSpecies = mem[MonsterField(slot, wMonParent1)]
	push af
	ld hl, wMonParent1
	call MonsterField
	ld a, [hl]
	ld [wMonSpecies], a
;> GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;> SetRandomMonsterName(slot, wMonParent1Name, wMonStats[0])   # a name of the parent's family
	ld a, [wMonStats]
	ld c, a
	pop af
	ld hl, wMonParent1Name
	call SetRandomMonsterName
;> wMonSpecies = mem[MonsterField(slot, wMonParent2)]
	push af
	ld hl, wMonParent2
	call MonsterField
	ld a, [hl]
	ld [wMonSpecies], a
;> GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;> SetRandomMonsterName(slot, wMonParent2Name, wMonStats[0])
	ld a, [wMonStats]
	ld c, a
	pop af
	ld hl, wMonParent2Name
	call SetRandomMonsterName
	ret


;@ def SetMonsterField(slot: a, field: hl, value: c)
;@ path: system/debug
;@ Stores `value` in `field` of monster record `slot` (keeps a). The `push af` after its `ret` is
;@ the first instruction of SetMonsterWord.
;@ test: slot = rand(0, 19); field = 0xCAC1 + rand(0, 0x94)
SetMonsterField::
;> mem[MonsterField(slot, field)] = value
	push af
	call MonsterField
	ld [hl], c
	pop af
	ret

	push af

;@ def SetMonsterWord(slot: a, field: hl, value: bc)
;@ path: unused
;@ Stores the 16-bit `value` in `field` of monster record `slot`; it begins with the `push af` just
;@ before this label. Nothing calls it.
;@ test: skip the push af that belongs to it lies before the label
SetMonsterWord::
;> p = MonsterField(slot, field)
	call MonsterField
;> mem16[p] = value
	ld [hl], c
	inc hl
	ld [hl], b
	pop af
	ret


;@ def SetRandomMonsterName(slot: a, field: hl, group: c)
;@ path: system/debug
;@ Copies one of 16 names of row `group` of system text group 3 (entry group * 16 + random 0-15)
;@ into `field` of monster record `slot` (keeps a).
;@ test: skip calls routines in other banks
SetRandomMonsterName::
;> dest = MonsterField(slot, field)
	push af
	push bc
	call MonsterField
	ld e, l
	ld d, h
;> Random()
	call Random
;> entry = (group << 4 | wRandomHigh & 0x0F) & 0xFF
	ld a, [wRandomHigh]
	and $0f
	pop bc
	swap c
	or c
;> CopySystemText(0x0300 + entry, dest)
	ld l, a
	ld h, $03
	call CopySystemText
	pop af
	ret

;@ path: unused
;@ Bytes from $54C7 to the end of bank $55 that nothing refers to: they look like leftover compressed
;@ graphics, followed by zero padding.
Bank55Leftover::
	db $df, $06, $f8, $04, $f8, $a1, $5a, $01, $4e, $81, $5e, $96, $08, $b8, $28, $11
	db $24, $46, $db, $01, $37, $8b, $b0, $40, $2d, $cd, $84, $64, $ff, $00, $ff, $00
	db $ff, $00, $05, $ff, $8b, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $05, $ff, $8b, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $05, $ff
	db $8b, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $05, $ff, $84, $00
	db $ff, $00, $ff, $11, $00, $ff, $07, $70, $07, $70, $ff, $ff, $00, $ff, $00, $00
	db $ff, $ff, $00, $ff, $00, $00, $e1, $0e, $e1, $0e, $f0, $f6, $08, $fb, $04, $fc
	db $c5, $f6, $25, $f6, $65, $36, $18, $23, $30, $8e, $70, $08, $e1, $10, $03, $a4
	db $06, $e8, $04, $ba, $06, $69, $56, $a9, $1b, $64, $76, $81, $e0, $0e, $40, $b8
	db $40, $a3, $c3, $28, $c6, $31, $c6, $21, $84, $00, $00, $3c, $0c, $51, $18, $e1
	db $30, $4f, $74, $09, $4d, $30, $00, $b7, $29, $16, $22, $49, $da, $04, $3c, $80
	db $b0, $4f, $20, $c2, $80, $6b, $b9, $44, $89, $54, $d8, $27, $00, $f9, $51, $a8
	db $93, $68, $02, $95, $07, $f8, $b1, $0e, $7d, $02, $60, $9f, $e0, $13, $c0, $22
	db $80, $58, $10, $a6, $e0, $f1, $1c, $80, $5f, $00, $7f, $40, $be, $40, $90, $00
	db $75, $01, $46, $45, $aa, $c6, $39, $03, $b8, $07, $18, $30, $07, $20, $47, $c3
	db $3c, $8c, $73, $41, $3a, $06, $d9, $01, $d9, $83, $72, $20, $d0, $05, $f3, $03
	db $f7, $a4, $55, $00, $41, $80, $51, $ff, $1c, $ff, $24, $ff, $44, $ff, $24, $ff
	db $24, $ff, $24, $ff, $42, $ff, $7e, $ff, $7c, $bb, $82, $ff, $92, $ff, $92, $ff
	db $92, $ff, $92, $bb, $82, $ff, $7c, $ff, $fe, $ff, $82, $ff, $9c, $fb, $82, $ff
	db $72, $ff, $72, $fb, $82, $ff, $fc, $ff, $7c, $bb, $82, $ff, $92, $fb, $e2, $ff
	db $4c, $bf, $de, $ff, $82, $ff, $fe, $30, $00, $00, $81, $00, $0f, $7f, $81, $00
	db $0f, $ff, $10, $cf, $10, $ff, $10, $fc, $10, $3f, $04, $00, $84, $03, $07, $0e
	db $0d, $08, $09, $03, $00, $83, $03, $07, $0d, $04, $0a, $86, $1f, $19, $ff, $ff
	db $00, $ff, $0c, $00, $84, $ff, $ff, $00, $ff, $0a, $09, $82, $04, $03, $04, $00
	db $89, $7f, $7f, $7e, $7d, $7d, $7e, $7e, $7d, $7f, $03, $7e, $b8, $7d, $7e, $7e
	db $7f, $a8, $57, $a8, $57, $57, $e8, $eb, $e8, $77, $ab, $ab, $17, $fa, $47, $87
	db $7b, $47, $fa, $09, $95, $6d, $d5, $49, $56, $ee, $d5, $ad, $5e, $be, $5d, $ad
	db $d6, $5f, $5f, $5e, $55, $4a, $4a, $56, $6d, $d7, $62, $49, $b6, $cd, $3e, $06
	db $fa, $ff, $0f, $f7, $8b, $03, $ab, $c9, $57, $bf, $4f, $f7, $87, $db, $67, $87
	db $fb, $fd, $f2, $c9, $fc, $d2, $d2, $ea, $cd, $fb, $e5, $df, $e2, $ef, $e1, $d0
	db $ef, $ff, $ec, $55, $96, $96, $50, $d5, $eb, $fd, $ea, $57, $5a, $b4, $6c, $ea
	db $75, $fe, $f1, $4f, $b2, $85, $b5, $7a, $fd, $f0, $ef, $72, $af, $b2, $ae, $93
	db $6c, $7b, $b5, $7b, $eb, $fd, $d3, $6a, $ab, $fd, $62, $df, $62, $ee, $ea, $66
	db $dd, $05, $fe, $87, $7e, $be, $7e, $fe, $7e, $be, $7e, $04, $fe, $89, $00, $01
	db $02, $05, $0b, $17, $2f, $5f, $7f, $07, $07, $91, $00, $1f, $2f, $5f, $7c, $7f
	db $7c, $7e, $7e, $7d, $7d, $7e, $7e, $7d, $7f, $7f, $00, $03, $ff, $8d, $86, $f8
	db $8b, $ab, $a8, $6b, $68, $d7, $0f, $f6, $5f, $5e, $00, $03, $ff, $8d, $97, $97
	db $f0, $4f, $44, $f9, $26, $ac, $0f, $f6, $2d, $f5, $00, $03, $ff, $8d, $d7, $6b
	db $97, $cb, $ab, $27, $2f, $df, $ff, $cf, $56, $69, $07, $03, $ff, $8d, $f7, $e8
	db $ee, $d8, $ef, $d8, $ea, $d9, $ff, $0f, $f7, $8b, $e0, $03, $ff, $8d, $77, $aa
	db $95, $55, $59, $a5, $b2, $6d, $fa, $f5, $ea, $d5, $00, $03, $ff, $8d, $fe, $f1
	db $4f, $72, $45, $75, $fa, $fd, $84, $7f, $80, $79, $00, $03, $ff, $8d, $7b, $a5
	db $5f, $e2, $ef, $e1, $50, $af, $75, $a5, $95, $55, $00, $03, $ff, $93, $fe, $f1
	db $4f, $72, $85, $75, $fa, $7d, $fd, $f6, $c9, $7c, $00, $f8, $f4, $fa, $7e, $be
	db $7e, $03, $fe, $a2, $7e, $be, $7e, $be, $7e, $be, $7d, $7f, $7f, $7d, $7f, $7f
	db $7c, $7f, $7d, $7d, $7e, $7c, $5f, $2f, $1f, $00, $f7, $5e, $5d, $f6, $df, $2e
	db $95, $c9, $29, $25, $ad, $de, $03, $ff, $8d, $00, $2d, $ed, $35, $ce, $ff, $cf
	db $54, $6b, $68, $0b, $57, $bf, $03, $ff, $ad, $00, $00, $01, $07, $0f, $1a, $17
	db $1f, $17, $1e, $3f, $7f, $ff, $f4, $6b, $30, $00, $00, $fc, $aa, $f5, $ff, $ff
	db $fd, $de, $ef, $ff, $fd, $fa, $7c, $08, $f0, $00, $6a, $0a, $56, $bd, $e7, $1b
	db $f7, $2e, $5f, $5d, $a6, $da, $03, $ff, $81, $00, $03, $ab, $89, $57, $bf, $5f
	db $bf, $bf, $df, $37, $ab, $b7, $03, $ff, $86, $00, $d5, $ee, $ee, $de, $ef, $04
	db $d7, $83, $d6, $d1, $ee, $03, $ff, $8d, $00, $76, $8d, $b4, $85, $f0, $ef, $f2
	db $ef, $f2, $ee, $53, $ec, $03, $ff, $8d, $00, $d4, $54, $95, $66, $fd, $62, $df
	db $62, $ee, $ea, $66, $dd, $03, $ff, $89, $00, $8a, $92, $62, $cd, $ff, $7f, $bf
	db $7f, $07, $ff, $83, $00, $be, $7e, $0a, $fe, $95, $fa, $f4, $f8, $00, $00, $1f
	db $2f, $5f, $7c, $7f, $7c, $7e, $7e, $7d, $7d, $7e, $7c, $7f, $7c, $7f, $00, $03
	db $ff, $8d, $86, $f8, $8b, $ab, $a8, $6b, $68, $d7, $07, $fb, $44, $6f, $00, $03
	db $ff, $8d, $96, $95, $f1, $4e, $46, $f9, $25, $ae, $df, $2e, $97, $ca, $00, $04
	db $ff, $8c, $77, $4b, $b7, $cf, $3f, $07, $fb, $1f, $ef, $0f, $b7, $00, $04, $ff
	db $ff, $e0, $ef, $e0, $ef, $e9, $ef, $e0, $f1, $ee, $f1, $df, $00, $7b, $6f, $51
	db $38, $7f, $7f, $de, $ff, $ff, $f7, $c0, $68, $23, $7f, $7f, $00, $f7, $1d, $8b
	db $ce, $e5, $bd, $ff, $ff, $eb, $ff, $2a, $ff, $e5, $83, $ff, $00, $7b, $77, $69
	db $78, $7e, $7f, $7f, $5f, $3e, $f7, $e0, $83, $7d, $7f, $7f, $f0, $3d, $0e, $c3
	db $71, $1f, $87, $e1, $3f, $ff, $3f, $de, $fb, $7f, $f3, $dd, $07, $f8, $f6, $f8
	db $fc, $8e, $fe, $c2, $fc, $40, $7f, $7b, $7f, $5e, $2f, $5f, $e0, $1b, $07, $65
	db $f3, $f3, $63, $03, $33, $7b, $ff, $b7, $cb, $7d, $07, $ff, $00, $7b, $74, $69
	db $b2, $c1, $00, $ff, $60, $5d, $7b, $73, $71, $69, $77, $7b, $76, $ff, $7b, $3b
	db $96, $9b, $c7, $ff, $7f, $fe, $ff, $ff, $b7, $c9, $bb, $87, $fc, $00, $3c, $7f
	db $ff, $ff, $bd, $43, $3e, $4f, $7f, $03, $ff, $97, $80, $40, $7f, $00, $bf, $ff
	db $b7, $8f, $85, $72, $9f, $0a, $f2, $fb, $fe, $fd, $7a, $71, $ff, $00, $ff, $fc
	db $90, $03, $7f, $8e, $3f, $5f, $9d, $b8, $b8, $7f, $40, $7f, $7f, $00, $ff, $01
	db $00, $fc, $03, $fe, $b5, $f7, $8b, $1d, $1d, $cb, $06, $fb, $ff, $00, $77, $58
	db $64, $28, $51, $51, $7f, $3f, $3f, $7f, $ff, $af, $57, $21, $7f, $00, $ef, $1b
	db $45, $93, $0a, $01, $c1, $ed, $ed, $f1, $fa, $6d, $92, $e1, $ff, $00, $7f, $7b
	db $6c, $53, $6f, $2f, $43, $bb, $fb, $fd, $7b, $3f, $03, $7f, $8d, $00, $ff, $df
	db $37, $cb, $f7, $f5, $c2, $dd, $df, $bf, $de, $fd, $03, $ff, $81, $00, $03, $ff
	db $8d, $fd, $6a, $55, $57, $57, $56, $51, $ae, $f1, $ee, $f0, $6b, $00, $03, $ff
	db $8d, $7b, $a5, $5e, $e9, $de, $ea, $68, $f7, $f2, $ed, $f2, $69, $00, $04, $ff
	db $8c, $f0, $ef, $d8, $6a, $aa, $aa, $55, $af, $57, $94, $6b, $00, $03, $ff, $98
	db $fb, $e4, $5f, $a8, $9d, $a6, $a8, $6f, $ff, $7f, $bf, $7f, $00, $f8, $f4, $fa
	db $fe, $fe, $7e, $7e, $be, $7e, $7e, $be, $04, $fe, $05, $7f, $97, $7e, $7e, $7d
	db $7e, $7d, $7e, $7d, $5f, $2f, $1f, $00, $55, $4d, $5e, $5c, $74, $8b, $ea, $85
	db $f6, $89, $a8, $97, $03, $ff, $8d, $00, $29, $25, $ae, $df, $47, $fb, $08, $f7
	db $4c, $f5, $56, $f8, $03, $ff, $8d, $00, $4b, $ab, $0b, $77, $d7, $6b, $97, $cb
	db $ab, $27, $2f, $df, $03, $ff, $8d, $00, $e2, $f5, $ea, $d5, $fb, $e5, $de, $e9
	db $de, $ea, $e8, $f7, $03, $ff, $8d, $00, $d4, $da, $60, $b7, $f1, $ee, $f0, $eb
	db $54, $9a, $a0, $77, $03, $ff, $8d, $00, $95, $aa, $a2, $4d, $f1, $ee, $f1, $5f
	db $a2, $b5, $aa, $55, $03, $ff, $8d, $00, $6c, $93, $90, $6f, $f0, $ef, $f2, $6f
	db $f2, $ee, $53, $ac, $03, $ff, $8d, $00, $ff, $ff, $7f, $bf, $fd, $62, $df, $62
	db $ee, $ea, $66, $dd, $03, $ff, $81, $00, $05, $fe, $83, $7e, $be, $7e, $04, $fe
	db $83, $fa, $f4, $f8, $09, $00, $09, $ff, $0f, $80, $81, $ff, $0f, $00, $10, $f8
	db $10, $0f, $20, $ff, $04, $00, $84, $03, $04, $09, $0b, $08, $0f, $03, $00, $83
	db $03, $04, $0b, $04, $0e, $86, $1f, $17, $ff, $00, $ff, $ff, $0c, $00, $84, $ff
	db $00, $ff, $ff, $09, $0f, $83, $0e, $07, $03, $04, $00, $83, $c0, $c0, $c1, $04
	db $c3, $82, $c2, $c0, $03, $c1, $89, $c3, $c1, $c1, $c0, $5f, $ff, $7f, $b8, $b8
	db $03, $1f, $ac, $88, $dc, $dc, $f8, $fd, $f8, $f8, $fc, $f8, $fd, $ff, $7b, $f3
	db $fb, $ff, $eb, $11, $3b, $73, $e1, $c1, $e3, $73, $39, $e0, $e0, $e1, $eb, $ff
	db $ff, $fb, $f3, $3c, $9d, $bf, $f9, $f3, $c1, $f9, $fd, $00, $f0, $f8, $fc, $03
	db $dc, $8b, $b8, $40, $f0, $f8, $f8, $fc, $f8, $f8, $fc, $02, $0f, $04, $3f, $85
	db $37, $3e, $04, $1e, $3f, $03, $1f, $b2, $3f, $1f, $00, $13, $bb, $f9, $f9, $bf
	db $3e, $1c, $02, $17, $bf, $bf, $ff, $bf, $3d, $9b, $01, $0f, $bf, $ff, $fe, $ce
	db $87, $03, $0f, $1f, $8f, $df, $cf, $df, $ff, $9f, $84, $ce, $8c, $1c, $1e, $3e
	db $b7, $f7, $02, $9f, $3f, $9f, $1f, $1f, $9f, $3e, $05, $03, $87, $83, $c3, $83
	db $03, $83, $c3, $83, $04, $03, $8a, $01, $03, $07, $0e, $1c, $38, $70, $e0, $fc
	db $fc, $06, $0c, $84, $1f, $3f, $70, $e0, $03, $c3, $82, $c1, $c1, $03, $c3, $81
	db $c1, $03, $c3, $dc, $ff, $ff, $00, $00, $f9, $ff, $ff, $dc, $df, $9f, $9f, $38
	db $f0, $f9, $b8, $b9, $ff, $ff, $00, $00, $fc, $fc, $ff, $f3, $fb, $ff, $fb, $73
	db $f0, $f9, $f3, $fb, $ff, $ff, $00, $00, $3c, $94, $f8, $fc, $fc, $f8, $f0, $e0
	db $00, $30, $b9, $9f, $fc, $fc, $00, $00, $08, $1f, $1f, $3f, $1f, $3f, $3d, $3f
	db $00, $f0, $f8, $fc, $3f, $3f, $00, $00, $88, $dd, $fb, $bb, $bf, $db, $cf, $9e
	db $05, $0f, $17, $3b, $ff, $ff, $00, $00, $01, $0f, $bf, $bf, $be, $8e, $07, $03
	db $03, $ff, $88, $87, $ff, $ff, $00, $00, $84, $de, $bf, $03, $1f, $9d, $bf, $df
	db $8e, $de, $fe, $be, $ff, $ff, $00, $00, $01, $0f, $bf, $bf, $fe, $8e, $07, $83
	db $03, $09, $3f, $bf, $f8, $fc, $0e, $07, $83, $c3, $83, $03, $03, $85, $83, $c3
	db $c3, $43, $83, $05, $c3, $82, $c0, $c0, $06, $c3, $d4, $e0, $70, $3f, $1f, $f8
	db $b9, $bb, $f9, $20, $f1, $fb, $ff, $ff, $fb, $73, $e1, $00, $00, $ff, $ff, $f3
	db $f3, $fb, $f1, $00, $30, $bb, $9f, $9f, $fc, $e8, $c0, $00, $00, $ff, $ff, $00
	db $01, $06, $08, $17, $1c, $18, $1b, $13, $20, $40, $86, $8f, $5b, $30, $00, $00
	db $fc, $76, $1b, $01, $01, $e7, $e2, $59, $79, $13, $36, $a4, $f8, $f0, $00, $9f
	db $ff, $eb, $c3, $18, $fc, $f8, $f1, $e1, $e3, $7b, $3f, $00, $00, $ff, $ff, $03
	db $dc, $92, $b8, $40, $e0, $c0, $c0, $e0, $e8, $7c, $78, $00, $00, $ff, $ff, $3b
	db $31, $31, $21, $10, $04, $38, $a5, $39, $3f, $1f, $00, $00, $ff, $ff, $8f, $ff
	db $ff, $fe, $0f, $1f, $0f, $1f, $0f, $1f, $bf, $1f, $00, $00, $ff, $ff, $3f, $bf
	db $ff, $bf, $02, $9f, $3f, $9f, $1f, $1f, $9f, $3e, $00, $00, $04, $ff, $86, $bf
	db $3e, $00, $80, $c0, $80, $06, $00, $84, $ff, $ff, $c3, $83, $0a, $03, $88, $07
	db $0e, $fc, $f8, $1f, $3f, $70, $e0, $03, $c3, $82, $c1, $c1, $06, $c3, $a3, $c0
	db $ff, $ff, $00, $00, $f9, $ff, $ff, $dc, $df, $9f, $9f, $38, $f8, $fc, $fb, $f3
	db $ff, $ff, $00, $00, $fd, $ff, $ff, $f1, $f9, $ff, $fb, $71, $20, $f1, $f8, $fd
	db $ff, $ff, $03, $00, $8f, $88, $bc, $f8, $f0, $c0, $f8, $fc, $e0, $f0, $f0, $f8
	db $ff, $ff, $00, $00, $08, $3f, $bc, $0e, $1f, $0e, $3f, $ff, $87, $9c, $be, $e7
	db $df, $ff, $bf, $9e, $c8, $bf, $bf, $df, $ff, $de, $ff, $ff, $f8, $ee, $76, $33
	db $fb, $db, $1f, $1f, $37, $e3, $f7, $fe, $1e, $7e, $fe, $ff, $87, $8c, $9e, $97
	db $91, $9e, $9f, $b7, $e9, $cf, $1f, $ff, $fe, $80, $80, $ff, $ce, $f3, $3d, $8f
	db $e2, $7a, $df, $04, $ff, $8b, $fc, $fe, $8e, $be, $ff, $cf, $ff, $cf, $87, $f3
	db $fb, $04, $ff, $c1, $c4, $c7, $e5, $f8, $bf, $ff, $fc, $fc, $9e, $0e, $0e, $9e
	db $fe, $ff, $ce, $85, $ce, $ff, $fe, $fc, $fc, $ff, $87, $8f, $9f, $ff, $fe, $ff
	db $ff, $bf, $bf, $9e, $9e, $9f, $9f, $8e, $87, $ff, $8a, $d6, $ef, $7e, $3d, $3c
	db $c7, $bb, $4d, $85, $cf, $ff, $7e, $7f, $fc, $ff, $ff, $c3, $91, $81, $c3, $ff
	db $ff, $f0, $ff, $aa, $9a, $05, $ff, $9b, $e0, $50, $fc, $fa, $fe, $8f, $65, $f7
	db $ff, $4d, $ab, $9b, $f7, $8f, $ff, $ff, $c7, $bf, $ff, $f0, $9f, $95, $ff, $ff
	db $eb, $d7, $d7, $03, $ff, $be, $80, $ff, $fe, $ff, $ff, $03, $fd, $4d, $1d, $fe
	db $f7, $e3, $e3, $f7, $ff, $fc, $00, $ff, $8f, $bf, $bb, $f7, $ee, $ee, $c0, $ff
	db $f6, $df, $8f, $df, $ff, $ff, $bf, $ff, $f0, $fc, $be, $6e, $f7, $ff, $3f, $df
	db $ff, $9f, $0f, $9e, $ff, $ff, $3f, $ff, $80, $87, $9f, $bc, $b0, $f0, $fc, $c6
	db $86, $82, $c4, $ff, $03, $80, $8d, $ff, $00, $e0, $f8, $3c, $0c, $0e, $3f, $63
	db $61, $41, $23, $fe, $03, $00, $a2, $ff, $ff, $00, $00, $c2, $d7, $fa, $f8, $f8
	db $f9, $ff, $df, $0e, $1f, $0f, $9f, $ff, $ff, $00, $00, $84, $de, $bf, $1e, $3f
	db $1d, $9f, $0f, $0d, $1f, $0f, $96, $ff, $ff, $03, $00, $a7, $0f, $1f, $3f, $bd
	db $fd, $fd, $bb, $d0, $f8, $fb, $9f, $ff, $ff, $00, $00, $04, $1f, $bf, $df, $ff
	db $df, $df, $9f, $00, $80, $c0, $80, $f8, $fc, $0e, $07, $03, $03, $83, $83, $c3
	db $83, $83, $c3, $04, $03, $05, $c0, $84, $c1, $c1, $c3, $c1, $03, $c3, $92, $e0
	db $70, $3f, $1f, $fb, $f3, $e3, $e3, $8b, $ff, $ff, $fb, $f9, $ff, $df, $fb, $00
	db $00, $03, $ff, $ef, $fb, $71, $e0, $f8, $fc, $ff, $fb, $f3, $fb, $fb, $ff, $00
	db $00, $ff, $ff, $fc, $dc, $fc, $f8, $3c, $94, $f8, $fc, $fc, $f8, $f0, $e0, $00
	db $00, $ff, $ff, $1f, $0e, $1f, $3b, $04, $1e, $3f, $1e, $3f, $1d, $1f, $0f, $00
	db $00, $ff, $ff, $3f, $3d, $9f, $cf, $0e, $1f, $0f, $1f, $bf, $fd, $df, $8f, $00
	db $00, $ff, $ff, $fe, $f7, $ff, $be, $0e, $1f, $0e, $bf, $df, $ce, $df, $bb, $00
	db $00, $ff, $ff, $9f, $fc, $ff, $9f, $0f, $1f, $0f, $9f, $0f, $1f, $bf, $df, $00
	db $00, $ff, $ff, $00, $00, $80, $c0, $02, $9f, $3f, $9f, $1f, $1f, $9f, $3e, $00
	db $00, $ff, $ff, $05, $03, $83, $83, $c3, $83, $04, $03, $84, $07, $0e, $fc, $f8
	db $12, $00, $00, $c0, $00, $55, $2a, $55, $2a, $55, $2a, $55, $2a, $55, $2a, $55
	db $2a, $55, $2a, $55, $00, $55, $aa, $55, $aa, $55, $aa, $55, $aa, $55, $aa, $55
	db $aa, $55, $aa, $55, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd
	db $ca, $cd, $ca, $cd, $af, $5f, $af, $5f, $af, $5f, $af, $5f, $af, $5f, $af, $5f
	db $af, $5f, $af, $5f, $10, $fc, $10, $3f, $81, $00, $0f, $7f, $81, $00, $0f, $ff
	db $10, $cf, $10, $ff, $84, $0f, $1f, $3b, $37, $08, $3f, $84, $37, $3b, $1f, $0f
	db $10, $ff, $04, $00, $88, $01, $0f, $1e, $1b, $1b, $1e, $0f, $01, $08, $00, $08
	db $ff, $04, $00, $90, $3f, $7f, $ef, $df, $fe, $fd, $fb, $f6, $f6, $f7, $f6, $f1
	db $f0, $f7, $f6, $f7, $04, $ff, $8c, $7f, $bf, $df, $6f, $6f, $ef, $6f, $8f, $3f
	db $df, $6f, $df, $15, $ff, $88, $f8, $f7, $f8, $fb, $fa, $f9, $f7, $fb, $03, $f5
	db $04, $ff, $8c, $78, $97, $e8, $99, $b6, $b9, $b2, $7d, $fd, $f2, $ff, $f4, $04
	db $ff, $8c, $3f, $df, $bf, $df, $2f, $af, $af, $df, $ff, $9b, $65, $95, $0d, $ff
	db $87, $3f, $5f, $af, $fc, $fe, $f7, $fb, $0c, $ff, $96, $f6, $f6, $f7, $f0, $ff
	db $f5, $ff, $fb, $fd, $f7, $fb, $f5, $df, $ef, $7f, $3f, $6f, $6f, $df, $3f, $ff
	db $d7, $0f, $ff, $81, $7f, $0a, $ff, $8c, $f5, $f5, $f4, $fb, $ff, $fb, $fc, $f7
	db $fc, $f4, $f4, $fb, $04, $ff, $8c, $f4, $b9, $52, $bd, $7f, $fc, $93, $ec, $93
	db $9f, $0c, $db, $04, $ff, $82, $00, $00, $04, $ff, $8c, $e7, $db, $bd, $66, $66
	db $7e, $66, $18, $ff, $ff, $00, $00, $0e, $ff, $82, $00, $00, $04, $ff, $8c, $f7
	db $ab, $5d, $6a, $d2, $b2, $aa, $d5, $ff, $ff, $00, $00, $04, $ff, $8c, $fb, $f5
	db $eb, $d7, $af, $d7, $eb, $f5, $ff, $ff, $00, $00, $04, $ff, $8c, $83, $7d, $8b
	db $9d, $62, $9a, $2a, $dd, $ff, $ff, $00, $00, $0e, $ff, $87, $3f, $7f, $ef, $df
	db $f8, $f7, $f8, $03, $ff, $86, $f8, $f7, $df, $ef, $7f, $3f, $04, $ff, $88, $1f
	db $ef, $2c, $a3, $ac, $a2, $2e, $ee, $08, $ff, $88, $a1, $5e, $b1, $7f, $bf, $bf
	db $b0, $bf, $09, $ff, $87, $dd, $a2, $af, $a2, $54, $b8, $73, $08, $ff, $88, $5e
	db $a9, $57, $2a, $a4, $94, $b9, $7a, $08, $ff, $88, $fd, $7a, $d5, $15, $e6, $19
	db $1c, $eb, $08, $ff, $88, $fc, $bb, $5c, $5b, $5c, $5b, $b4, $7b, $08, $ff, $88
	db $3f, $db, $bc, $d7, $bc, $b4, $d4, $3b, $08, $ff, $88, $7e, $fd, $9e, $ea, $9f
	db $94, $0a, $da, $04, $ff, $9a, $fc, $fe, $f7, $fb, $ff, $7f, $ff, $ff, $7f, $df
	db $af, $df, $fb, $f7, $fe, $fc, $ff, $ff, $03, $7d, $66, $7d, $66, $66, $7d, $03
	db $04, $ff, $0a, $00, $88, $ff, $eb, $cc, $cf, $c8, $bf, $bf, $b0, $08, $00, $8b
	db $c3, $c3, $00, $c3, $00, $ff, $ff, $00, $b0, $a0, $e0, $04, $20, $85, $10, $08
	db $04, $02, $01, $04, $00, $82, $ff, $db, $04, $bd, $86, $a5, $ff, $ff, $00, $00
	db $ff, $04, $00, $10, $ff, $81, $3f, $0e, $3d, $82, $3f, $38, $0e, $28, $a1, $38
	db $00, $01, $07, $0f, $1a, $17, $1f, $17, $1e, $3f, $7f, $ff, $f4, $6b, $30, $00
	db $00, $fc, $aa, $f5, $ff, $ff, $fd, $de, $ef, $ff, $fd, $fa, $7c, $08, $f0, $00
	db $0e, $ff, $82, $00, $00, $03, $ff, $87, $c3, $bd, $c2, $f5, $bb, $41, $be, $04
	db $ff, $8c, $00, $00, $ff, $ff, $ef, $97, $7d, $a1, $4e, $41, $91, $ae, $04, $ff
	db $85, $00, $00, $1d, $23, $41, $04, $7f, $81, $3e, $04, $7f, $87, $41, $22, $1c
	db $00, $fb, $0c, $0c, $09, $ff, $87, $99, $99, $ff, $00, $be, $61, $60, $09, $ff
	db $89, $24, $24, $ff, $00, $fc, $84, $84, $fc, $fc, $03, $f8, $81, $78, $03, $f8
	db $90, $c8, $c8, $f8, $00, $55, $d4, $65, $9a, $ff, $3a, $d5, $26, $ad, $ab, $5a
	db $bd, $04, $ff, $8c, $af, $2f, $5f, $ff, $7f, $bb, $d5, $a5, $25, $24, $a5, $5a
	db $09, $ff, $8b, $3f, $5f, $af, $af, $2f, $5f, $ff, $fb, $f7, $fe, $fc, $11, $00
	db $a6, $a2, $17, $ff, $fe, $ff, $7f, $bf, $bf, $fd, $ff, $97, $ff, $fd, $df, $7f
	db $81, $03, $03, $a6, $8f, $fc, $7f, $b7, $c0, $85, $29, $83, $0d, $ef, $ff, $f8
	db $fb, $f6, $ef, $bd, $fb, $cf, $7f, $08, $ff, $ae, $fe, $bf, $3e, $3f, $bf, $36
	db $3f, $3f, $37, $77, $ef, $db, $fd, $ba, $63, $f5, $fc, $ff, $ef, $ff, $bb, $ff
	db $bf, $7f, $36, $ff, $ff, $eb, $bf, $df, $7f, $ed, $ff, $7d, $ef, $fb, $fb, $b7
	db $fe, $dd, $bf, $f7, $9f, $bf, $7f, $bf, $03, $ff, $9d, $fe, $eb, $f5, $db, $df
	db $f7, $ff, $fe, $d7, $bf, $7f, $ef, $5f, $ef, $ff, $fd, $fb, $f7, $6f, $9f, $f7
	db $fe, $ff, $ff, $fb, $f7, $df, $b7, $ef, $03, $ff, $b0, $fe, $fd, $bf, $bb, $fc
	db $77, $7f, $ee, $ff, $e3, $8e, $7f, $df, $f7, $6f, $bf, $df, $ef, $77, $bf, $db
	db $fd, $ef, $f7, $ef, $ff, $ff, $79, $f7, $ef, $bb, $2f, $ef, $fb, $ff, $9d, $ff
	db $f6, $f8, $fe, $fd, $ff, $ff, $fe, $ff, $ff, $fe, $ff, $03, $3f, $9e, $bf, $bf
	db $3f, $3d, $37, $fe, $df, $fd, $fb, $a7, $ed, $77, $5d, $79, $ff, $ef, $ff, $2f
	db $6f, $df, $bf, $af, $fe, $ee, $f7, $ff, $fd, $fe, $ff, $7f, $04, $ff, $83, $7f
	db $ff, $be, $06, $ff, $8d, $f7, $5b, $ff, $fd, $ff, $ff, $fe, $fe, $fc, $e7, $ff
	db $f7, $fb, $04, $ff, $91, $37, $ef, $ef, $ff, $f9, $f6, $ff, $fb, $ac, $ff, $7f
	db $fe, $df, $ff, $ff, $df, $b3, $0a, $00, $a2, $80, $c0, $e0, $f0, $f8, $fc, $00
	db $80, $c0, $e0, $f0, $f8, $fc, $fe, $7f, $3f, $1f, $0f, $07, $03, $01, $00, $ff
	db $f8, $e0, $c0, $80, $03, $03, $01, $80, $00, $00, $38, $03, $fc, $85, $e0, $01
	db $00, $00, $1c, $03, $3f, $ac, $07, $ff, $1f, $07, $03, $11, $d0, $e0, $a4, $80
	db $c0, $f0, $fc, $f0, $e0, $e0, $f0, $01, $03, $0e, $00, $00, $0c, $1c, $3c, $80
	db $c0, $70, $00, $00, $30, $38, $3c, $25, $1b, $0f, $3f, $0f, $07, $07, $0f, $ff
	db $c7, $83, $09, $fe, $87, $82, $c4, $f9, $e3, $ff, $c5, $c5, $08, $fd, $88, $ff
	db $c2, $c2, $fe, $c0, $ff, $c7, $83, $04, $fe, $8c, $9c, $fd, $f9, $f3, $ff, $82
	db $82, $fe, $80, $ff, $c7, $83, $03, $fe, $83, $fc, $fd, $ff, $03, $fe, $87, $82
	db $c4, $f9, $e3, $ff, $95, $95, $05, $fd, $81, $ff, $03, $fe, $89, $94, $f5, $fd
	db $f1, $ff, $82, $82, $fe, $f0, $03, $ff, $04, $fe, $87, $82, $c4, $f9, $e3, $ff
	db $c7, $83, $03, $fe, $82, $fc, $ff, $04, $fe, $97, $82, $c4, $f9, $e3, $ff, $82
	db $82, $fe, $9e, $fe, $fc, $fd, $fd, $f9, $fb, $fb, $cb, $cb, $fb, $c3, $ff, $c7
	db $83, $03, $fe, $83, $fc, $fd, $ff, $03, $fe, $87, $82, $c4, $f9, $e3, $ff, $c7
	db $83, $09, $fe, $84, $82, $c4, $f9, $e3, $08, $00, $0a, $ff, $88, $83, $7d, $8b
	db $9d, $62, $9a, $2a, $dd, $04, $ff, $82, $00, $00, $0a, $ff, $90, $fb, $f7, $fe
	db $fc, $00, $00, $ff, $ff, $c7, $bb, $c7, $7d, $8b, $d7, $a9, $56, $04, $ff, $0a
	db $00, $0a, $ff, $16, $00, $07, $ff, $81, $fb, $08, $00, $07, $ff, $86, $fe, $fb
	db $8f, $88, $8c, $8f, $03, $8c, $86, $ff, $80, $9f, $bf, $df, $bf, $04, $ff, $83
	db $03, $03, $ff, $03, $02, $82, $ff, $00, $06, $ff, $84, $88, $8c, $ff, $80, $07
	db $9f, $89, $bf, $df, $bf, $ff, $ff, $02, $02, $ff, $00, $0c, $ff, $bf, $fc, $8c
	db $8f, $8c, $8c, $8f, $8c, $8c, $3f, $28, $fb, $3a, $0a, $fb, $0a, $0a, $fc, $14
	db $df, $5c, $50, $df, $50, $50, $3f, $31, $f1, $31, $31, $f1, $31, $31, $8f, $8c
	db $8c, $8f, $8c, $8c, $8f, $ff, $fb, $04, $03, $ff, $00, $00, $ff, $ff, $df, $20
	db $c0, $ff, $00, $00, $ff, $ff, $f1, $31, $31, $f1, $31, $31, $f1, $03, $ff, $8c
	db $fb, $88, $8f, $8c, $8c, $8f, $8c, $8c, $8f, $8c, $8c, $8f, $05, $ff, $8a, $00
	db $ff, $00, $03, $ff, $03, $02, $fe, $02, $03, $06, $ff, $8a, $00, $ff, $00, $c0
	db $ff, $c0, $40, $7f, $40, $c0, $05, $ff, $8e, $df, $11, $f1, $31, $31, $f1, $31
	db $31, $f1, $31, $31, $f1, $ff, $ff, $08, $00, $04, $ff, $84, $80, $80, $9f, $9f
	db $08, $00, $88, $ff, $ff, $fe, $ff, $00, $00, $ff, $ff, $08, $00, $88, $ff, $ff
	db $7f, $ff, $00, $00, $ff, $ff, $08, $00, $04, $ff, $84, $01, $01, $f9, $f9, $07
	db $9f, $87, $bf, $9f, $df, $9f, $bf, $df, $bf, $22, $ff, $07, $f9, $8a, $fd, $f9
	db $fb, $f9, $fd, $fb, $fd, $ff, $ff, $03, $03, $07, $87, $0d, $7d, $f3, $ff, $f3
	db $7d, $0d, $03, $07, $81, $03, $04, $00, $89, $1c, $1f, $1f, $0e, $0d, $0e, $1f
	db $1f, $1c, $08, $00, $8c, $1c, $3f, $3b, $1f, $0f, $07, $0d, $0f, $07, $02, $00
	db $00, $08, $ff, $09, $00, $07, $7f, $81, $00, $07, $ff, $81, $00, $07, $7f, $81
	db $00, $07, $ff, $81, $00, $07, $7f, $81, $00, $07, $ff, $81, $00, $07, $ff, $81
	db $00, $08, $ff, $81, $80, $03, $bf, $8d, $bc, $bd, $bd, $ff, $01, $ff, $ff, $f7
	db $37, $f7, $f7, $ff, $80, $06, $bf, $84, $ff, $01, $ff, $ff, $04, $f7, $82, $ff
	db $80, $03, $bf, $8d, $b8, $bf, $bf, $ff, $01, $ff, $ff, $f7, $37, $f7, $f7, $ff
	db $80, $03, $bf, $83, $b8, $bf, $bf, $05, $f7, $83, $e7, $ff, $ff, $08, $7f, $08
	db $ff, $08, $7f, $08, $ff, $08, $7f, $18, $ff, $03, $bd, $85, $bf, $bf, $b8, $bf
	db $ff, $05, $f7, $83, $07, $ff, $ff, $07, $bf, $81, $ff, $05, $f7, $95, $e7, $ff
	db $ff, $bf, $bc, $bd, $bf, $bf, $b8, $bf, $ff, $f7, $07, $ff, $ff, $f7, $07, $ff
	db $ff, $bf, $be, $03, $bf, $85, $b8, $bf, $ff, $f7, $37, $03, $f7, $81, $07, $03
	db $ff, $83, $80, $bf, $bf, $03, $bd, $85, $bf, $ff, $01, $ff, $ff, $04, $f7, $82
	db $ff, $80, $03, $bf, $8d, $bc, $bd, $bf, $ff, $01, $ff, $ff, $f7, $07, $ff, $ff
	db $ba, $7d, $04, $ff, $83, $7d, $3a, $ef, $06, $ff, $81, $ef, $0b, $ff, $85, $fc
	db $f0, $e3, $e4, $e5, $03, $ff, $84, $00, $00, $ff, $00, $04, $ff, $84, $0f, $07
	db $c5, $25, $0b, $e5, $86, $e3, $e0, $f0, $ff, $f8, $ff, $03, $e5, $9f, $05, $0b
	db $f7, $0f, $ff, $e5, $a5, $a5, $c9, $d1, $a1, $a1, $e9, $38, $10, $00, $01, $02
	db $12, $2a, $06, $0c, $00, $8c, $08, $00, $43, $0b, $16, $bf, $b8, $05, $bf, $83
	db $ff, $f7, $37, $03, $f7, $85, $e7, $ff, $ff, $bf, $b8, $03, $bf, $85, $b8, $bf
	db $ff, $ff, $80, $03, $bf, $83, $b8, $bf, $bf, $05, $ff, $9d, $f6, $fb, $fd, $ff
	db $ff, $df, $f7, $fb, $1f, $ed, $ff, $ff, $2c, $df, $f7, $eb, $f6, $f9, $fe, $ff
	db $fd, $fe, $fb, $f5, $db, $e7, $3f, $ff, $c7, $04, $a3, $81, $c7, $0c, $ff, $87
	db $fb, $ff, $ff, $fb, $ff, $ff, $bb, $04, $ff, $e6, $bb, $ff, $ff, $99, $e7, $10
	db $88, $07, $00, $ff, $ff, $fd, $c5, $c5, $cd, $fd, $81, $ff, $1e, $3c, $3e, $bb
	db $b7, $2f, $3c, $1b, $4f, $ff, $fb, $fd, $7e, $5f, $fe, $af, $07, $00, $87, $0c
	db $08, $20, $05, $03, $00, $03, $29, $92, $27, $57, $cf, $af, $1c, $00, $eb, $ff
	db $fe, $f7, $ff, $7f, $20, $00, $6b, $b6, $de, $fe, $bf, $ff, $07, $00, $91, $00
	db $43, $cb, $b7, $4e, $10, $00, $62, $d5, $c7, $df, $ee, $ff, $00, $3e, $ff, $ed
	db $bf, $ef, $bf, $7f, $30, $00, $bf, $ff, $7e, $b7, $dd, $ea, $1e, $27, $3f, $3b
	db $04, $3f, $83, $ff, $df, $bf, $03, $ff, $86, $6f, $7f, $cf, $fd, $ff, $fe, $04
	db $ff, $f8, $fd, $5b, $be, $f5, $ff, $ed, $fb, $dd, $b5, $7e, $fb, $fb, $ff, $bf
	db $7d, $ff, $7b, $ff, $dd, $f3, $7e, $9f, $7f, $f7, $bf, $6b, $dd, $bf, $d6, $6f
	db $df, $bb, $bf, $76, $ff, $dd, $ff, $6e, $7f, $f7, $4f, $fd, $f7, $ef, $df, $fb
	db $fe, $77, $ff, $f6, $5f, $ff, $f7, $7d, $ef, $fe, $fa, $ff, $f7, $ff, $ff, $b7
	db $7b, $cf, $ff, $ff, $bf, $f7, $fb, $7f, $ed, $be, $ff, $db, $f7, $ba, $fd, $df
	db $f7, $dd, $79, $ff, $ff, $fd, $a7, $ff, $ad, $f3, $ff, $af, $df, $bf, $f7, $ff
	db $bf, $7f, $ef, $ff, $ff, $f5, $ff, $ff, $bf, $fb, $3d, $3f, $3b, $3e, $be, $bf
	db $3b, $bf, $df, $57, $9f, $3f, $9e, $2f, $5e, $f9, $08, $ff, $e1, $f3, $f6, $db
	db $ed, $f7, $fc, $fd, $bf, $be, $fd, $b7, $6f, $fe, $e7, $db, $dd, $df, $ff, $bb
	db $9e, $ff, $79, $df, $bb, $6f, $f7, $6f, $3e, $ef, $cd, $ff, $f6, $af, $de, $b1
	db $3f, $ff, $db, $bf, $d5, $3f, $f7, $7f, $ef, $bf, $ef, $d8, $5f, $df, $ff, $fc
	db $ff, $dd, $df, $1e, $ff, $bd, $3f, $3e, $37, $1f, $39, $3b, $3f, $ef, $bb, $6f
	db $77, $db, $d7, $7d, $de, $7f, $db, $b7, $ff, $fd, $df, $fc, $30, $fd, $bf, $7f
	db $7f, $bf, $ff, $df, $7f, $7f, $ff, $ff, $fe, $fb, $f7, $ee, $fd, $ef, $04, $ff
	db $8c, $8d, $d1, $80, $fb, $ff, $ff, $bf, $f7, $fd, $3f, $e7, $ef, $03, $ff, $b8
	db $f3, $df, $fd, $cb, $fb, $ef, $dd, $bb, $fe, $fd, $6b, $fd, $fb, $47, $08, $17
	db $b7, $ff, $b1, $7f, $37, $3d, $3f, $36, $25, $4b, $0e, $3f, $7b, $ff, $7f, $cf
	db $9f, $ff, $bf, $df, $ff, $df, $ef, $7f, $ff, $f7, $cf, $ff, $d0, $fc, $bf, $e7
	db $fd, $ff, $fb, $f7, $5f, $df, $ff, $bf, $03, $ff, $8b, $fe, $ff, $ff, $fe, $ff
	db $fd, $fe, $ff, $ef, $3e, $3f, $03, $bf, $03, $3f, $e8, $f7, $ef, $fc, $fe, $fd
	db $7b, $ff, $cf, $7c, $dd, $ec, $f7, $fe, $ff, $fb, $bf, $ff, $37, $9b, $3f, $07
	db $8d, $42, $81, $ff, $fd, $ee, $77, $ff, $fe, $d0, $42, $83, $56, $fc, $f8, $b0
	db $e2, $00, $39, $87, $07, $2b, $ab, $12, $85, $a4, $8c, $d0, $40, $92, $2a, $9a
	db $30, $50, $e2, $ff, $d2, $ee, $ce, $ab, $0d, $b5, $3f, $ff, $fe, $7f, $7f, $78
	db $ff, $fd, $7e, $3b, $37, $3d, $3f, $3e, $3f, $bf, $bf, $f4, $7f, $ef, $bb, $d7
	db $ed, $7b, $ff, $fe, $ff, $7d, $b6, $6f, $fd, $eb, $ff, $fd, $9b, $fe, $ff, $fd
	db $df, $fb, $ee, $61, $ff, $0f, $80, $81, $ff, $0f, $00, $10, $f8, $11, $0f, $83
	db $1f, $3c, $38, $08, $30, $86, $38, $3c, $1f, $0f, $ff, $ff, $0c, $00, $82, $ff
	db $ff, $04, $00, $88, $03, $0f, $1f, $1c, $1c, $1f, $0f, $03, $08, $00, $82, $ff
	db $ff, $04, $00, $82, $ff, $ff, $04, $00, $87, $7f, $ff, $f0, $e0, $c1, $c3, $c7
	db $04, $cf, $81, $ce, $04, $cf, $87, $ff, $ff, $00, $00, $80, $c0, $e0, $04, $f0
	db $87, $70, $c0, $e0, $f0, $e0, $ff, $ff, $06, $00, $81, $05, $07, $00, $82, $ff
	db $ff, $03, $00, $88, $07, $0f, $07, $47, $07, $07, $0f, $04, $03, $0e, $88, $ff
	db $ff, $00, $00, $87, $ef, $f7, $e7, $03, $cf, $82, $83, $02, $03, $0f, $88, $ff
	db $ff, $00, $00, $c0, $e0, $c0, $e0, $03, $f0, $87, $e0, $00, $64, $fe, $6e, $ff
	db $ff, $0b, $00, $87, $c0, $e0, $70, $fe, $ff, $0f, $07, $0c, $03, $04, $cf, $92
	db $c0, $cf, $ca, $cc, $c6, $ca, $ce, $ce, $e0, $f0, $ff, $7f, $f0, $f0, $e0, $c0
	db $00, $fb, $03, $aa, $88, $bb, $aa, $aa, $00, $00, $ff, $ff, $05, $04, $00, $b4
	db $f0, $a0, $a0, $a5, $20, $a0, $a0, $00, $00, $ff, $ff, $4e, $0e, $0f, $07, $00
	db $04, $07, $0f, $4f, $0f, $0f, $07, $00, $00, $ff, $ff, $0f, $4f, $ef, $c3, $80
	db $83, $ef, $ff, $ec, $e0, $f3, $e7, $00, $00, $ff, $ff, $00, $00, $ff, $ff, $00
	db $00, $18, $3c, $7e, $04, $ff, $81, $e7, $04, $00, $82, $ff, $ff, $06, $00, $81
	db $54, $07, $00, $87, $ff, $ff, $00, $00, $08, $5c, $fe, $03, $ff, $82, $f7, $6e
	db $04, $00, $8c, $ff, $ff, $00, $00, $04, $0e, $1c, $38, $70, $38, $1c, $0e, $04
	db $00, $88, $ff, $ff, $00, $00, $7c, $fe, $7c, $7e, $03, $ff, $81, $3e, $04, $00
	db $82, $ff, $ff, $0c, $00, $87, $3f, $7f, $f0, $e0, $c7, $cf, $c7, $03, $c0, $94
	db $c7, $cf, $e0, $f0, $7f, $3f, $ff, $ff, $00, $00, $e0, $f0, $f3, $7f, $7f, $7d
	db $f1, $f1, $00, $00, $04, $ff, $8c, $00, $00, $7e, $ef, $ce, $80, $c0, $c0, $cf
	db $cf, $00, $00, $04, $ff, $03, $00, $81, $22, $03, $7f, $85, $ef, $cf, $8f, $00
	db $00, $04, $ff, $8c, $00, $00, $f1, $57, $ef, $f7, $ff, $ef, $cf, $8d, $00, $00
	db $04, $ff, $8c, $00, $00, $02, $87, $ee, $ee, $ff, $e6, $e3, $f7, $00, $00, $04
	db $ff, $8c, $00, $00, $03, $47, $e3, $e7, $e3, $e7, $cf, $87, $00, $00, $04, $ff
	db $8c, $00, $00, $c0, $e4, $c7, $ef, $cf, $cf, $ef, $c7, $00, $00, $04, $ff, $ac
	db $00, $00, $81, $83, $e3, $f7, $e7, $ef, $fd, $ed, $00, $00, $ff, $ff, $fc, $fe
	db $0f, $07, $03, $83, $03, $03, $83, $a3, $f3, $e3, $07, $0f, $fe, $fc, $00, $00
	db $fc, $fe, $ff, $fe, $ff, $ff, $fe, $fc, $00, $00, $ff, $ff, $0a, $00, $88, $ff
	db $9c, $bf, $bf, $b8, $ff, $e0, $ef, $08, $00, $8b, $c3, $00, $c3, $c3, $00, $ff
	db $00, $ff, $ef, $ff, $ff, $04, $3f, $85, $1f, $0f, $07, $03, $01, $04, $00, $86
	db $ff, $a5, $c3, $db, $db, $c3, $06, $ff, $04, $00, $81, $ff, $0e, $81, $82, $ff
	db $3f, $0e, $27, $81, $3f, $10, $38, $9f, $00, $01, $06, $08, $17, $1c, $18, $1b
	db $13, $20, $40, $86, $8f, $5b, $30, $00, $00, $fc, $76, $1b, $01, $01, $e7, $e2
	db $59, $79, $13, $36, $a4, $f8, $f0, $07, $00, $81, $54, $05, $00, $82, $ff, $ff
	db $05, $00, $8b, $3c, $7e, $3f, $0e, $44, $fe, $7f, $00, $00, $ff, $ff, $04, $00
	db $91, $10, $78, $fe, $7e, $ff, $fe, $fe, $df, $00, $00, $ff, $ff, $00, $00, $1d
	db $3f, $7f, $03, $49, $83, $4f, $23, $79, $03, $49, $88, $7f, $3f, $1f, $0e, $fb
	db $ff, $ff, $09, $03, $99, $82, $98, $98, $03, $99, $03, $ff, $84, $7f, $be, $ff
	db $ff, $04, $24, $82, $20, $21, $03, $24, $04, $ff, $86, $fc, $fe, $fe, $86, $ce
	db $ce, $06, $cc, $04, $fc, $a0, $ee, $ef, $ff, $e7, $00, $c5, $ef, $ff, $7f, $7f
	db $ef, $c6, $00, $00, $ff, $ff, $70, $f0, $a0, $00, $80, $c4, $ee, $fe, $fe, $ff
	db $7f, $e7, $00, $00, $ff, $ff, $05, $03, $8b, $c3, $e3, $73, $73, $f3, $a3, $03
	db $07, $0f, $ff, $fe, $10, $00, $a7, $ff, $5d, $ef, $ff, $ff, $00, $80, $c0, $40
	db $fe, $fe, $ef, $03, $03, $3f, $ff, $7e, $fc, $fc, $59, $f0, $ff, $ff, $cf, $3f
	db $7a, $d6, $7c, $f3, $1f, $ff, $ff, $07, $0f, $1e, $7e, $fc, $f0, $80, $08, $00
	db $99, $01, $c0, $41, $c1, $c3, $4f, $cc, $cf, $cf, $ef, $ff, $f7, $b7, $6d, $fe
	db $fe, $ff, $f7, $f7, $e7, $c7, $00, $71, $b0, $f9, $03, $f7, $92, $c0, $30, $98
	db $9f, $8f, $83, $f3, $fc, $1c, $78, $f1, $e2, $c0, $e8, $70, $70, $e0, $c0, $03
	db $00, $c9, $0f, $1d, $1b, $36, $24, $08, $00, $01, $fe, $ef, $ef, $df, $bd, $7c
	db $cc, $8f, $06, $0e, $9c, $f8, $f8, $f1, $f1, $ff, $04, $0c, $38, $78, $f0, $e0
	db $c0, $80, $c1, $c3, $c3, $c7, $87, $8d, $8a, $15, $ff, $ff, $f1, $e0, $e0, $ac
	db $d8, $f0, $e0, $f0, $f8, $78, $3d, $1f, $1f, $0f, $1f, $3f, $7f, $fe, $f8, $f4
	db $ec, $f8, $f0, $fc, $fc, $7e, $1e, $0f, $07, $01, $03, $04, $01, $8c, $00, $01
	db $00, $c0, $c0, $40, $c0, $c0, $40, $42, $cf, $1f, $03, $3f, $95, $7c, $7b, $de
	db $ae, $ff, $ff, $90, $30, $f0, $d8, $b0, $60, $df, $ff, $1f, $0f, $07, $03, $01
	db $00, $80, $04, $00, $83, $80, $80, $41, $06, $00, $a2, $08, $fc, $01, $02, $00
	db $00, $01, $01, $03, $1f, $0f, $0f, $06, $00, $00, $01, $01, $c9, $9f, $1f, $3f
	db $7f, $f9, $f0, $e4, $df, $01, $81, $81, $e0, $e0, $70, $38, $cc, $09, $00, $a3
	db $80, $40, $20, $10, $08, $04, $02, $80, $40, $20, $10, $08, $04, $02, $01, $80
	db $40, $20, $10, $08, $04, $02, $01, $ff, $f8, $e0, $c0, $80, $03, $03, $01, $80
	db $00, $00, $38, $03, $fc, $85, $e0, $01, $00, $00, $1c, $03, $3f, $ac, $07, $ff
	db $1f, $07, $03, $11, $d0, $e0, $a4, $80, $c0, $f0, $fc, $f0, $e0, $e0, $f0, $01
	db $03, $0e, $00, $00, $0c, $1c, $3c, $80, $c0, $70, $00, $00, $30, $38, $3c, $25
	db $1b, $0f, $3f, $0f, $07, $07, $0f, $38, $7c, $fe, $09, $93, $89, $ff, $7f, $3e
	db $1c, $3c, $7e, $7e, $46, $66, $06, $26, $81, $66, $03, $7f, $84, $3f, $38, $7c
	db $fe, $03, $93, $86, $f3, $77, $26, $4e, $5c, $9e, $03, $ff, $8a, $7f, $38, $7c
	db $fe, $93, $93, $f3, $47, $46, $f2, $03, $93, $87, $ff, $7f, $3e, $1c, $fc, $fe
	db $fe, $06, $96, $90, $83, $83, $f7, $7f, $1e, $1e, $0e, $fe, $ff, $ff, $9f, $9f
	db $98, $84, $82, $f3, $03, $93, $8c, $ff, $7f, $3e, $1c, $38, $7c, $fe, $93, $93
	db $9f, $87, $82, $04, $93, $90, $ff, $7f, $3e, $1c, $fe, $ff, $ff, $f3, $73, $23
	db $27, $26, $46, $4e, $4c, $4c, $03, $7c, $84, $3c, $38, $7c, $fe, $03, $93, $83
	db $47, $46, $92, $03, $93, $87, $ff, $7f, $3e, $1c, $38, $7c, $fe, $03, $93, $83
	db $83, $43, $f3, $03, $93, $84, $ff, $7f, $3e, $1c, $12, $00, $84, $7c, $fe, $7c
	db $7e, $03, $ff, $87, $3e, $00, $00, $ff, $ff, $00, $00, $0a, $03, $84, $07, $0f
	db $ff, $fe, $04, $00, $8c, $38, $7c, $38, $fe, $7c, $38, $7e, $ef, $00, $00, $ff
	db $ff, $11, $00, $03, $ff, $1c, $00, $82, $ff, $8c, $0d, $00, $88, $03, $fe, $03
	db $8c, $ff, $fb, $fc, $ff, $03, $fc, $8d, $ff, $80, $9f, $bf, $df, $bf, $ff, $ff
	db $00, $ff, $ff, $02, $fe, $03, $03, $82, $ff, $00, $06, $ff, $84, $fb, $fc, $ff
	db $80, $07, $9f, $83, $bf, $df, $bf, $03, $ff, $83, $03, $ff, $00, $0c, $ff, $ae
	db $8c, $fc, $ff, $fc, $fc, $ff, $fc, $fc, $28, $3f, $fb, $3e, $0e, $ff, $0e, $0e
	db $14, $fc, $df, $7c, $70, $ff, $70, $70, $31, $3f, $ff, $3f, $3f, $ff, $3f, $3f
	db $ff, $fc, $fc, $ff, $fc, $fc, $8f, $ff, $ff, $07, $03, $ff, $00, $00, $03, $ff
	db $85, $e0, $c0, $ff, $00, $00, $03, $ff, $95, $3f, $3f, $ff, $3f, $3f, $f1, $ff
	db $ff, $88, $8c, $fb, $ff, $fc, $fc, $ff, $fc, $fc, $ff, $fc, $fc, $8f, $03, $ff
	db $8c, $00, $00, $ff, $ff, $00, $03, $fe, $02, $03, $ff, $03, $03, $04, $ff, $8c
	db $00, $00, $ff, $ff, $00, $c0, $7f, $40, $c0, $ff, $c0, $c0, $04, $ff, $8f, $11
	db $31, $df, $ff, $3f, $3f, $ff, $3f, $3f, $ff, $3f, $3f, $f1, $ff, $ff, $0b, $00
	db $85, $ff, $ff, $80, $9f, $9f, $08, $00, $88, $03, $02, $03, $ff, $ff, $00, $ff
	db $ff, $08, $00, $88, $c0, $40, $c0, $ff, $ff, $00, $ff, $ff, $0b, $00, $85, $ff
	db $ff, $01, $f9, $f9, $07, $9f, $87, $bf, $9f, $df, $9f, $bf, $df, $bf, $22, $ff
	db $07, $f9, $8a, $fd, $f9, $fb, $f9, $fd, $fb, $fd, $ff, $ff, $01, $03, $02, $87
	db $06, $0e, $7c, $80, $7c, $0e, $06, $03, $02, $81, $01, $05, $00, $87, $0c, $0b
	db $05, $06, $05, $0b, $0c, $0a, $00, $88, $1c, $17, $08, $04, $02, $06, $05, $02
	db $03, $00, $08, $ff, $08, $00, $81, $ff, $07, $80, $81, $ff, $07, $00, $11, $ff
	db $03, $80, $05, $ff, $03, $00, $05, $ff, $07, $80, $81, $ff, $03, $00, $04, $80
	db $83, $ff, $ff, $c0, $03, $cf, $8c, $ce, $ce, $ff, $ff, $01, $f1, $f9, $f9, $39
	db $39, $ff, $ff, $06, $c0, $84, $ff, $ff, $01, $31, $04, $39, $98, $ff, $ff, $c0
	db $cf, $cf, $c7, $c0, $cf, $ff, $ff, $01, $f1, $f9, $f9, $39, $f9, $ff, $ff, $c0
	db $cf, $cf, $c7, $c0, $c3, $05, $39, $83, $19, $01, $ff, $08, $80, $08, $00, $14
	db $ff, $04, $80, $04, $ff, $04, $00, $04, $80, $04, $00, $08, $80, $03, $ce, $85
	db $cf, $cf, $c7, $c0, $ff, $03, $39, $03, $f9, $82, $01, $ff, $07, $c0, $81, $ff
	db $05, $39, $9e, $19, $01, $ff, $cf, $cf, $ce, $cf, $cf, $c7, $c0, $ff, $f9, $f9
	db $01, $f1, $f9, $f9, $01, $ff, $c3, $c1, $c0, $cf, $cf, $c7, $c0, $ff, $f9, $f9
	db $39, $03, $f9, $81, $01, $03, $ff, $82, $c0, $cc, $03, $ce, $85, $cf, $ff, $ff
	db $01, $31, $03, $39, $84, $f9, $ff, $ff, $c0, $03, $cf, $94, $ce, $cf, $ff, $ff
	db $01, $f1, $f9, $f9, $01, $f1, $7d, $c7, $92, $9e, $9e, $92, $c7, $7d, $ff, $18
	db $04, $4c, $99, $18, $ff, $f7, $4d, $c5, $c5, $c9, $c9, $4d, $fb, $00, $00, $0f
	db $13, $2c, $3b, $37, $36, $00, $00, $ff, $ff, $00, $ff, $ff, $03, $00, $85, $f0
	db $f8, $fc, $f6, $f6, $0b, $36, $a8, $3b, $2f, $10, $0f, $07, $00, $36, $36, $d6
	db $f6, $0c, $f8, $f0, $00, $8b, $d3, $d3, $a5, $8b, $d3, $cd, $85, $b8, $f0, $ff
	db $be, $bd, $2d, $95, $39, $2d, $12, $73, $f7, $ff, $bc, $f4, $e9, $cf, $c7, $05
	db $c0, $83, $ff, $f9, $f9, $03, $39, $8a, $19, $01, $ff, $cf, $c7, $c0, $cf, $cf
	db $c7, $c0, $03, $ff, $87, $c0, $cf, $cf, $c7, $c0, $c0, $00, $03, $01, $9e, $19
	db $2d, $46, $83, $00, $e0, $38, $0c, $e6, $f2, $1b, $09, $e7, $f7, $32, $19, $1c
	db $0f, $07, $01, $09, $0b, $13, $e6, $0e, $3c, $f8, $c0, $38, $7c, $04, $ce, $94
	db $7c, $38, $00, $42, $24, $18, $18, $24, $42, $00, $fe, $82, $9c, $82, $72, $72
	db $82, $fc, $7c, $82, $04, $92, $f6, $82, $7c, $ff, $66, $08, $26, $51, $c8, $37
	db $ff, $ff, $83, $81, $99, $91, $81, $c1, $ff, $a1, $c3, $41, $87, $cf, $5e, $5f
	db $ff, $b0, $00, $fc, $fe, $87, $e3, $81, $50, $87, $0b, $78, $f3, $f7, $df, $fa
	db $fc, $ed, $c7, $d7, $6d, $d8, $a8, $30, $51, $5f, $ef, $97, $8f, $1d, $38, $66
	db $8c, $a2, $81, $97, $cf, $ed, $61, $70, $76, $c7, $84, $6e, $ff, $bc, $37, $4f
	db $bf, $9a, $b1, $9d, $2b, $3b, $e7, $ff, $7c, $ff, $be, $ff, $f3, $c0, $10, $60
	db $c0, $b7, $ef, $c1, $e1, $f1, $78, $3b, $1d, $ff, $db, $c6, $c5, $c3, $c0, $c0
	db $41, $a0, $60, $c0, $80, $00, $00, $90, $90, $3d, $02, $04, $01, $04, $00, $f8
	db $63, $e7, $c7, $0e, $0c, $1f, $1f, $3e, $ce, $87, $07, $07, $c3, $c3, $a3, $c0
	db $e7, $f3, $e3, $bd, $e9, $f0, $e0, $c8, $7f, $f7, $e3, $d1, $e9, $d8, $b0, $64
	db $7e, $ff, $e3, $f3, $e1, $d9, $b0, $6c, $b0, $03, $0f, $1e, $3c, $3d, $fb, $fe
	db $03, $f9, $b8, $0c, $8e, $82, $10, $a1, $1d, $1f, $0f, $00, $03, $79, $fc, $fc
	db $e0, $c0, $c0, $38, $1d, $81, $1f, $7f, $1c, $3f, $3c, $7f, $7e, $6c, $18, $3e
	db $bf, $1b, $3e, $3b, $7e, $6d, $5b, $1e, $80, $50, $b0, $60, $c8, $90, $61, $c3
	db $1c, $0c, $0c, $0e, $06, $06, $c6, $c6, $43, $c3, $c7, $47, $c7, $87, $47, $c3
	db $30, $b8, $78, $d8, $7f, $df, $bf, $fe, $07, $00, $94, $01, $3d, $3b, $3c, $1f
	db $0f, $03, $03, $c7, $c1, $43, $cf, $9f, $ff, $ff, $e6, $e2, $30, $60, $cc, $03
	db $ff, $85, $3c, $7c, $d8, $38, $f8, $03, $ff, $d3, $1c, $0f, $58, $31, $7f, $ff
	db $fe, $fc, $78, $3e, $c7, $0f, $8f, $9f, $cf, $df, $e7, $e0, $e2, $e2, $e3, $e1
	db $e3, $e1, $e1, $00, $c3, $47, $cf, $d8, $e0, $c6, $c7, $c3, $ff, $c7, $f0, $f8
	db $3c, $2e, $83, $e1, $83, $e7, $7f, $0f, $1f, $3c, $3b, $ff, $c3, $c0, $80, $80
	db $c0, $c0, $60, $e0, $a0, $00, $00, $01, $07, $0f, $1f, $1e, $18, $00, $00, $ff
	db $ff, $f3, $2e, $7f, $04, $00, $00, $c0, $f8, $fe, $ff, $1f, $10, $03, $00, $b8
	db $0f, $3f, $fe, $f4, $07, $1f, $3e, $7c, $f9, $f2, $f5, $03, $fc, $be, $f7, $e8
	db $78, $fc, $ce, $80, $cf, $cf, $df, $fb, $bf, $fd, $b3, $47, $87, $81, $a0, $78
	db $f0, $a0, $40, $e0, $c1, $e0, $f0, $f0, $78, $38, $30, $00, $ef, $fb, $7f, $1f
	db $03, $00, $07, $0f, $e0, $e0, $c0, $c0, $03, $00, $9d, $01, $00, $00, $01, $01
	db $03, $01, $00, $f0, $c1, $40, $c0, $80, $c0, $40, $c1, $43, $f8, $1c, $03, $01
	db $02, $fc, $ff, $ff, $fb, $fe, $9f, $0e, $03, $07, $d9, $c3, $20, $f8, $7c, $df
	db $ff, $73, $bd, $fe, $1c, $1e, $1f, $8f, $ff, $ff, $2f, $bd, $7c, $a9, $03, $07
	db $cf, $1d, $ff, $c6, $78, $f8, $d4, $54, $ed, $7a, $5b, $73, $2f, $bf, $6d, $d5
	db $65, $cf, $af, $1d, $03, $2f, $17, $37, $57, $f3, $4b, $c3, $00, $01, $80, $80
	db $87, $81, $83, $81, $cf, $cb, $c3, $c1, $41, $00, $80, $c0, $fb, $bf, $9f, $d6
	db $ec, $fb, $ff, $77, $ff, $ff, $83, $69, $d0, $e3, $f7, $f7, $0e, $fc, $f1, $e1
	db $03, $e3, $e7, $f7, $02, $00, $00, $00, $00, $00, $00, $00, $c0, $00, $55, $2a
	db $55, $2a, $55, $2a, $55, $2a, $55, $2a, $55, $2a, $55, $2a, $55, $00, $55, $aa
	db $55, $aa, $55, $aa, $55, $aa, $55, $aa, $55, $aa, $55, $aa, $55, $ca, $cd, $ca
	db $cd, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd, $af, $5f, $af
	db $5f, $af, $5f, $af, $5f, $af, $5f, $af, $5f, $af, $5f, $af, $5f, $10, $fc, $10
	db $3f, $81, $00, $0f, $7f, $81, $00, $0f, $ff, $10, $cf, $10, $ff, $84, $00, $1f
	db $2f, $5f, $0c, $7f, $81, $07, $03, $ff, $8d, $e7, $db, $bd, $66, $66, $7e, $66
	db $18, $ef, $97, $7b, $a7, $e0, $03, $ff, $8d, $d5, $15, $fe, $11, $93, $55, $52
	db $92, $c7, $bb, $c3, $9d, $00, $03, $ff, $88, $81, $7e, $42, $82, $3d, $c5, $cb
	db $b7, $03, $ff, $82, $df, $00, $03, $ff, $8d, $1f, $ed, $1a, $fa, $fa, $f5, $0b
	db $f7, $c3, $bd, $cb, $bd, $00, $03, $ff, $8d, $f5, $c0, $3e, $c9, $17, $d7, $e9
	db $f6, $ff, $b3, $55, $5a, $00, $0b, $ff, $85, $f7, $ab, $5d, $6a, $00, $0b, $ff
	db $85, $fb, $f5, $eb, $d7, $00, $0b, $ff, $88, $83, $7d, $8b, $9d, $00, $f8, $f4
	db $fa, $0c, $fe, $0c, $7f, $90, $5f, $2f, $1f, $00, $79, $aa, $a2, $dd, $ff, $c3
	db $bd, $c2, $f5, $bb, $41, $be, $03, $ff, $8d, $00, $62, $9a, $c5, $bb, $bf, $5d
	db $52, $ad, $b3, $4f, $41, $be, $03, $ff, $81, $00, $03, $ff, $89, $bd, $f5, $da
	db $25, $f2, $2a, $49, $8b, $37, $03, $ff, $8d, $00, $cb, $bb, $4d, $b3, $f5, $c0
	db $3e, $c9, $17, $d7, $e9, $f6, $03, $ff, $8d, $00, $5a, $42, $55, $af, $ef, $97
	db $7d, $89, $be, $85, $43, $bd, $03, $ff, $8d, $00, $d2, $b2, $aa, $d5, $c3, $bd
	db $cb, $bd, $cb, $bb, $4d, $b3, $03, $ff, $8d, $00, $af, $d7, $eb, $f5, $f7, $89
	db $7e, $89, $bb, $ab, $9b, $77, $03, $ff, $85, $00, $62, $9a, $2a, $dd, $0b, $ff
	db $81, $00, $0c, $fe, $88, $fa, $f4, $f8, $00, $00, $1f, $2f, $5f, $0c, $7f, $81
	db $00, $03, $ff, $8d, $03, $fd, $c3, $fd, $06, $fe, $86, $7d, $ea, $d5, $aa, $55
	db $00, $03, $ff, $83, $c7, $bb, $4d, $03, $d7, $87, $65, $bb, $11, $fe, $02, $e5
	db $00, $03, $ff, $83, $81, $7e, $82, $03, $fa, $87, $82, $7e, $d7, $97, $57, $55
	db $00, $03, $ff, $8d, $fa, $f5, $cb, $37, $cb, $2b, $eb, $eb, $f5, $da, $25, $f2
	db $00, $03, $ff, $8d, $1f, $ed, $1a, $fa, $fa, $f5, $0b, $f7, $e7, $db, $bb, $db
	db $00, $03, $ff, $8d, $f5, $c2, $bd, $c2, $f5, $bb, $41, $be, $c3, $bd, $cb, $bd
	db $07, $03, $ff, $8d, $bf, $5d, $52, $ad, $b3, $4f, $41, $be, $ff, $b3, $55, $5a
	db $e0, $04, $ff, $87, $a1, $5e, $41, $5f, $47, $49, $b6, $04, $ff, $84, $00, $f8
	db $f4, $fa, $0c, $fe, $0c, $7f, $90, $5f, $2f, $1f, $00, $55, $ba, $ba, $7a, $f7
	db $ab, $5d, $6a, $d2, $b2, $aa, $d5, $03, $ff, $8d, $00, $db, $35, $d2, $15, $fb
	db $f5, $eb, $d7, $af, $d7, $eb, $f5, $03, $ff, $8d, $00, $52, $52, $55, $9b, $c7
	db $bb, $c3, $ad, $52, $6a, $82, $dd, $03, $ff, $09, $00, $88, $ff, $eb, $cc, $cf
	db $c8, $bf, $bf, $b0, $08, $00, $8b, $c3, $c3, $00, $c3, $00, $ff, $ff, $00, $b0
	db $a0, $e0, $04, $20, $85, $10, $08, $04, $02, $01, $04, $00, $82, $ff, $db, $04
	db $bd, $86, $a5, $ff, $ff, $00, $00, $ff, $04, $00, $10, $ff, $81, $3f, $0e, $3d
	db $82, $3f, $38, $0e, $28, $ad, $38, $00, $01, $07, $0f, $1a, $17, $1f, $17, $1e
	db $3f, $7f, $ff, $f4, $6b, $30, $00, $00, $fc, $aa, $f5, $ff, $ff, $fd, $de, $ef
	db $ff, $fd, $fa, $7c, $08, $f0, $00, $2a, $49, $8b, $37, $f3, $ad, $55, $d5, $65
	db $55, $d5, $5a, $03, $ff, $81, $00, $03, $db, $89, $bd, $c3, $bd, $cb, $bd, $cb
	db $bb, $4d, $b3, $03, $ff, $8d, $00, $cb, $bb, $4d, $b3, $f7, $89, $7e, $89, $bb
	db $ab, $9b, $77, $03, $ff, $85, $00, $5a, $42, $55, $af, $0b, $ff, $81, $00, $0f
	db $ff, $81, $00, $0c, $fe, $95, $fa, $f4, $f8, $00, $00, $1f, $2f, $5f, $7f, $7b
	db $74, $7d, $76, $75, $7d, $74, $78, $77, $76, $77, $00, $04, $ff, $8c, $3c, $d2
	db $2f, $a4, $a4, $2a, $d3, $1d, $c1, $6f, $c1, $00, $03, $ff, $8d, $7f, $bf, $5f
	db $2e, $a9, $96, $b8, $7d, $58, $57, $e4, $18, $00, $03, $ff, $8d, $fe, $f9, $f7
	db $7a, $b4, $54, $59, $ba, $11, $ee, $21, $2f, $00, $03, $ff, $8d, $fb, $75, $d5
	db $1a, $eb, $14, $14, $eb, $fe, $d9, $a7, $aa, $00, $04, $ff, $8c, $dc, $2b, $dc
	db $3f, $fb, $14, $eb, $fd, $3a, $db, $16, $00, $03, $ff, $8d, $fe, $39, $d6, $29
	db $53, $bc, $12, $ed, $db, $25, $a5, $15, $00, $03, $ff, $b8, $3f, $dc, $b3, $3c
	db $d1, $2d, $2e, $df, $ff, $fc, $f3, $fc, $00, $f8, $f4, $fa, $5e, $0e, $ee, $9e
	db $7e, $7e, $9e, $6e, $9e, $6e, $de, $be, $76, $76, $77, $70, $7f, $7c, $7b, $7c
	db $7f, $7b, $74, $7b, $5f, $2f, $1f, $00, $69, $65, $c5, $19, $fe, $39, $d7, $2a
	db $54, $b4, $19, $ea, $03, $ff, $8d, $00, $33, $5c, $2c, $2b, $fc, $7b, $dc, $17
	db $e8, $1d, $1a, $e5, $03, $ff, $8d, $00, $df, $5f, $b0, $7f, $7f, $bc, $73, $dc
	db $b1, $7d, $9e, $6f, $03, $ff, $8d, $00, $a7, $59, $ba, $7b, $9f, $6f, $de, $bd
	db $7a, $7d, $9e, $6f, $03, $ff, $8d, $7e, $6b, $96, $1a, $e6, $be, $59, $b7, $7a
	db $f4, $74, $b5, $5a, $03, $ff, $8d, $00, $d5, $25, $a4, $5b, $5e, $29, $d7, $18
	db $ef, $1b, $14, $eb, $03, $ff, $8d, $00, $f1, $bd, $5e, $bf, $ff, $3b, $d5, $b5
	db $55, $54, $35, $da, $03, $ff, $99, $00, $7e, $7e, $9e, $6e, $fe, $3e, $5e, $ae
	db $ae, $2e, $5e, $fe, $fa, $f4, $f8, $00, $00, $01, $02, $05, $0b, $17, $2f, $3f
	db $08, $07, $20, $00, $61, $ff, $0f, $80, $81, $ff, $0f, $00, $10, $f8, $10, $0f
	db $84, $1f, $3f, $70, $e0, $0c, $c0, $87, $fc, $fc, $00, $00, $18, $3c, $7e, $04
	db $ff, $9a, $e7, $10, $78, $fc, $78, $3f, $3f, $00, $00, $3f, $ff, $ff, $fe, $7c
	db $fe, $ff, $ff, $38, $7c, $3c, $7e, $ff, $ff, $00, $00, $7e, $03, $ff, $aa, $fe
	db $3e, $3c, $78, $00, $18, $38, $38, $ff, $ff, $00, $00, $e0, $f2, $e7, $07, $07
	db $0e, $fc, $f8, $3c, $7e, $3c, $7e, $ff, $ff, $00, $00, $0f, $3f, $ff, $fe, $f8
	db $38, $1e, $0f, $00, $4c, $ee, $e7, $ff, $ff, $0a, $00, $83, $08, $5c, $fe, $03
	db $ff, $0a, $00, $86, $04, $0e, $1c, $38, $ff, $ff, $0a, $00, $88, $7c, $fe, $7c
	db $7e, $f8, $fc, $0e, $07, $0c, $03, $0c, $c0, $92, $e0, $70, $3f, $1f, $fe, $77
	db $7f, $3e, $00, $3c, $7e, $3f, $0e, $44, $fe, $7f, $00, $00, $03, $ff, $8f, $67
	db $3e, $7c, $40, $e2, $ef, $7e, $7c, $f0, $fe, $7f, $00, $00, $ff, $ff, $03, $18
	db $ab, $7e, $0f, $25, $fe, $ff, $ff, $fe, $fc, $f8, $00, $00, $ff, $ff, $3c, $7c
	db $fe, $7c, $0f, $3f, $ff, $fe, $f8, $38, $1e, $0f, $00, $00, $ff, $ff, $e7, $ff
	db $fa, $70, $10, $78, $fe, $7e, $7f, $7e, $fc, $7e, $00, $00, $04, $ff, $96, $f7
	db $6e, $3c, $7e, $3c, $7e, $3c, $7c, $fe, $7c, $00, $00, $ff, $ff, $70, $38, $1c
	db $0e, $08, $7e, $ff, $7e, $03, $7c, $83, $f8, $00, $00, $05, $ff, $81, $3e, $0a
	db $00, $82, $ff, $ff, $0c, $03, $88, $07, $0e, $fc, $f8, $1f, $3f, $70, $e0, $0c
	db $c0, $97, $ff, $ff, $00, $00, $fc, $fe, $fc, $fe, $ff, $07, $ff, $fe, $17, $3f
	db $5f, $ee, $ff, $ff, $00, $00, $38, $7c, $fe, $03, $ee, $8d, $fe, $7c, $fe, $ff
	db $ff, $1e, $ff, $ff, $00, $00, $7e, $ff, $7f, $03, $07, $95, $7f, $ff, $38, $78
	db $f8, $fa, $ff, $ff, $00, $00, $07, $0e, $3c, $f8, $fc, $dc, $1c, $1c, $0f, $25
	db $fe, $03, $ff, $b0, $00, $00, $e0, $f2, $e7, $07, $07, $0e, $fc, $f8, $18, $3c
	db $7c, $3c, $ff, $ff, $00, $00, $0f, $3d, $7e, $3f, $0e, $44, $fe, $7f, $3c, $7e
	db $3c, $7e, $fc, $fc, $00, $00, $40, $e2, $ef, $7e, $7c, $f0, $fe, $7f, $00, $4c
	db $ee, $e7, $3f, $3f, $03, $00, $87, $5e, $ff, $fe, $e0, $f8, $fe, $6f, $04, $00
	db $84, $f8, $fc, $0e, $07, $0c, $03, $0c, $c0, $8b, $e0, $70, $3f, $1f, $ee, $c7
	db $c7, $87, $08, $5c, $fe, $03, $ff, $94, $f7, $6e, $00, $00, $ff, $ff, $3c, $fe
	db $ff, $fa, $04, $0e, $1c, $38, $70, $38, $1c, $0e, $00, $00, $04, $ff, $8e, $fe
	db $fc, $38, $7c, $3c, $7e, $ff, $f7, $7f, $3e, $00, $00, $ff, $ff, $08, $00, $88
	db $ff, $9c, $bf, $bf, $b8, $ff, $e0, $ef, $08, $00, $8b, $c3, $00, $c3, $c3, $00
	db $ff, $00, $ff, $ef, $ff, $ff, $04, $3f, $85, $1f, $0f, $07, $03, $01, $04, $00
	db $86, $ff, $a5, $c3, $db, $db, $c3, $06, $ff, $04, $00, $81, $ff, $0e, $81, $82
	db $ff, $3f, $0e, $27, $81, $3f, $10, $38, $a6, $00, $01, $06, $08, $17, $1c, $18
	db $1b, $13, $20, $40, $86, $8f, $5b, $30, $00, $00, $fc, $76, $1b, $01, $01, $e7
	db $e2, $59, $79, $13, $36, $a4, $f8, $f0, $00, $ff, $fe, $fc, $f8, $0c, $5e, $03
	db $fe, $87, $ee, $ee, $e7, $00, $00, $ff, $ff, $03, $3c, $95, $7e, $3c, $7e, $3c
	db $7e, $3c, $7c, $fe, $7c, $00, $00, $ff, $ff, $3c, $7c, $fe, $7c, $08, $7e, $ff
	db $7e, $03, $7c, $89, $f8, $00, $00, $ff, $ff, $e7, $ff, $fa, $70, $0a, $00, $82
	db $ff, $ff, $0e, $00, $82, $ff, $ff, $0c, $03, $8a, $07, $0e, $fc, $f8, $1f, $3f
	db $70, $e0, $c0, $c4, $03, $cf, $84, $ce, $ce, $cf, $c7, $03, $cf, $82, $ff, $ff
	db $03, $00, $88, $c3, $ef, $ff, $7f, $7f, $fd, $ef, $e3, $05, $ff, $b0, $00, $00
	db $80, $c0, $e0, $f1, $f7, $ef, $c7, $83, $f7, $ff, $ff, $ef, $ff, $ff, $00, $00
	db $01, $07, $0f, $87, $cf, $ef, $ef, $cd, $ee, $ff, $fe, $f0, $ff, $ff, $00, $00
	db $04, $8e, $ee, $e7, $f7, $ef, $ef, $f7, $01, $27, $7f, $77, $ff, $ff, $03, $00
	db $af, $23, $f7, $e3, $c0, $04, $ef, $f7, $02, $c7, $e7, $ef, $ff, $ff, $00, $00
	db $01, $c7, $ef, $f7, $ef, $4f, $ed, $f3, $24, $fe, $fe, $ee, $ff, $ff, $00, $00
	db $c0, $e3, $cf, $cf, $ef, $f3, $f1, $e0, $00, $03, $0f, $0f, $f8, $fc, $0e, $07
	db $03, $f3, $89, $e3, $83, $83, $e3, $f3, $63, $f3, $e3, $c3, $04, $cf, $ff, $c0
	db $c3, $c7, $c3, $c0, $c4, $cf, $c7, $e0, $70, $3f, $1f, $f7, $ff, $ff, $ef, $01
	db $c7, $ef, $f7, $ef, $4f, $ef, $fd, $00, $00, $ff, $ff, $cf, $e3, $f3, $f7, $03
	db $87, $e3, $ef, $f7, $e3, $e7, $fe, $00, $00, $ff, $ff, $e0, $e0, $cf, $8f, $80
	db $c3, $8f, $ef, $cf, $83, $e1, $f0, $00, $00, $ff, $ff, $7f, $e7, $c7, $87, $60
	db $f0, $e1, $c3, $87, $83, $e1, $f0, $00, $00, $c3, $c3, $f7, $ef, $ef, $ff, $41
	db $e7, $cf, $87, $0f, $8f, $cf, $ed, $00, $00, $ff, $ff, $ee, $fe, $7f, $e7, $f1
	db $d7, $ef, $e7, $f0, $e4, $ef, $f7, $00, $00, $ff, $ff, $0f, $43, $e1, $c0, $00
	db $c4, $ee, $ce, $ee, $ef, $cf, $e7, $00, $00, $ff, $ff, $83, $83, $e3, $96, $f3
	db $03, $c3, $e3, $73, $73, $f3, $a3, $03, $07, $0e, $fc, $f8, $01, $03, $07, $0e
	db $1c, $38, $70, $7c, $7c, $07, $0c, $22, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00
