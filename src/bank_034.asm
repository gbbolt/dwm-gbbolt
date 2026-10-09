INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $034", ROMX[$4000], BANK[$34]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_34::
	db $34

;@ path: gfx/monsters/tables
;@ Entry table of bank $34: the address of each compressed block (entry number = position), as DecompressSetup
;@ finds it for Decompress / DecompressVRAM (bank, entry).
FarTable_34::
	dw MonPic_GoHopper
	dw MonPic_TailEater
	dw MonPic_ArmorPede
	dw MonPic_Eyeder
	dw MonPic_GiantMoth
	dw MonPic_Droll
	dw MonPic_ArmyCrab
	dw MonPic_MadHornet
	dw MonPic_HornBeet
	dw MonPic_Armorpion
	dw MonPic_Digster
	dw MonPic_Pixy
	dw MonPic_ArcDemon
	dw MonPic_AgDevil
	dw MonPic_Demonite
	dw MonPic_DarkEye
	dw MonPic_EyeBall
	dw MonPic_SkulRider
	dw MonPic_EvilBeast
	dw MonPic_X1EyeClown
	dw MonPic_Gremlin
	dw MonPic_MedusaEye
	dw MonPic_Lionex
	dw MonPic_GoatHorn
	dw MonPic_Orc
	dw MonPic_Ogre
	dw MonPic_GateGuard
	dw MonPic_ChopClown
	dw MonPic_Grendal
	dw MonPic_Akubar
	dw MonPic_MadKnight
	dw MonPic_Gigantes
	dw MonPic_Centasaur
	dw MonPic_EvilArmor
	dw MonPic_Jamirus
	dw MonPic_Durran
	dw MonPic_Spooky
	dw MonPic_Skullgon
	dw MonPic_Putrepup
	dw MonPic_RotRaven

;@ path: gfx/monsters/pictures
;@ Picture of GoHopper (species $77): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $9E packed).
MonPic_GoHopper::
	db $40, $02, $05, $ff, $05, $ff, $ff, $4d, $05, $5f, $0f, $4d, $05, $75, $0f
	db $01, $01, $ff, $02, $ff, $04, $05, $74, $07, $c1, $ff, $22, $ff, $14, $ff, $3e
	db $d5, $5d, $f7, $3e, $05, $74, $01, $c0, $ff, $20, $ff, $10, $05, $74, $0f, $33
	db $f7, $1c, $e3, $3e, $c1, $7f, $dd, $7f, $ff, $36, $ff, $2a, $ff, $1d, $f6, $1e
	db $05, $74, $09, $9c, $e7, $bc, $05, $74, $0f, $20, $03, $fe, $03, $ff, $03, $ff
	db $02, $05, $98, $12, $f4, $7c, $9b, $ff, $65, $fd, $f9, $bb, $f8, $1f, $fc, $14
	db $fe, $13, $ff, $11, $cf, $fc, $9f, $fc, $1f, $f6, $27, $fb, $d3, $fe, $0f, $df
	db $02, $b7, $83, $ef, $05, $74, $03, $80, $ff, $40, $ff, $80, $ff, $80, $05, $74
	db $0f, $10, $04, $05, $f0, $17, $05, $75, $00, $10, $05, $00, $27, $05, $75, $00
	db $7e, $ff, $22, $ff, $21, $ff, $21, $ff, $01, $ff, $01, $05, $74, $0f, $11

;@ path: gfx/monsters/pictures
;@ Picture of TailEater (species $78): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $12B packed).
MonPic_TailEater::
	db $40
	db $02, $09, $ff, $09, $ff, $ff, $4d, $09, $27, $0f, $13, $0d, $fe, $77, $da, $ff
	db $aa, $ff, $d0, $7f, $09, $26, $03, $80, $ff, $b0, $df, $f0, $bf, $fc, $67, $fc
	db $09, $26, $07, $03, $ff, $05, $ff, $0a, $09, $26, $0f, $10, $01, $fe, $03, $ff
	db $03, $fc, $07, $ff, $07, $09, $d2, $00, $e0, $ff, $00, $f8, $c2, $f7, $07, $f7
	db $c2, $f7, $80, $f8, $60, $ff, $d0, $ff, $1f, $f8, $3f, $fc, $07, $7f, $1f, $7c
	db $04, $7f, $3a, $ff, $4e, $cf, $b0, $f3, $ff, $34, $ef, $d8, $df, $30, $3f, $e0
	db $7f, $c0, $ff, $80, $ff, $80, $7f, $c0, $09, $26, $0f, $0e, $03, $ff, $c0, $ff
	db $30, $ff, $0b, $ff, $04, $ff, $08, $ff, $10, $ff, $12, $ea, $7f, $eb, $3f, $fe
	db $1e, $ff, $d1, $ff, $21, $ff, $11, $ee, $1b, $ff, $8a, $d0, $f1, $70, $ff, $a0
	db $e0, $c0, $7c, $00, $c7, $e0, $19, $38, $c4, $8c, $70, $7f, $f0, $3f, $c8, $5f
	db $f0, $3f, $e0, $1f, $f8, $1f, $e4, $2f, $f8, $1f, $f0, $09, $26, $0f, $0e, $20
	db $ff, $21, $ff, $23, $ff, $23, $ff, $27, $ff, $24, $ef, $30, $e7, $38, $f4, $0d
	db $fc, $06, $fa, $87, $fc, $83, $fc, $c3, $fe, $41, $ee, $11, $ce, $31, $c4, $3b
	db $60, $93, $30, $41, $00, $39, $00, $9f, $09, $b8, $11, $ff, $1f, $f8, $07, $fc
	db $03, $fe, $17, $fc, $1f, $f8, $0f, $f8, $07, $fc, $1f, $f8, $09, $26, $0f, $0e
	db $10, $ff, $10, $ff, $08, $fd, $06, $fb, $0f, $ff, $0c, $09, $26, $00, $fe, $01
	db $fc, $03, $fb, $04, $e3, $1e, $01, $ff, $ff, $ff, $09, $26, $00, $00, $ff, $02
	db $ff, $72, $cf, $7b, $e7, $ff, $7a, $ff, $c6, $09, $26, $00, $bf, $e0, $7f, $c0
	db $bf, $60, $ff, $a0, $ff, $60, $09, $26, $0f, $03

;@ path: gfx/monsters/pictures
;@ Picture of ArmorPede (species $79): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $E7 packed).
MonPic_ArmorPede::
	db $40, $02, $04, $ff, $04, $ff
	db $ff, $4d, $04, $5f, $0f, $4d, $04, $bf, $0f, $4d, $04, $c5, $01, $fc, $03, $f9
	db $06, $ff, $00, $f1, $0f, $e6, $1a, $04, $c6, $01, $05, $7e, $be, $69, $e9, $dc
	db $5d, $aa, $ab, $49, $4b, $ff, $00, $ff, $4f, $b5, $b5, $25, $27, $24, $6f, $92
	db $fe, $4b, $cb, $26, $26, $ff, $00, $ff, $80, $ff, $00, $ff, $f0, $bf, $a0, $9f
	db $90, $83, $e4, $21, $b6, $04, $c6, $0f, $0a, $20, $ff, $20, $ef, $17, $fe, $02
	db $e7, $1f, $cf, $31, $df, $21, $df, $20, $04, $c6, $00, $88, $8b, $1c, $1d, $3e
	db $3e, $dd, $ff, $ff, $3e, $dd, $5d, $dd, $49, $ff, $22, $f8, $fe, $20, $a1, $71
	db $7d, $e8, $ca, $c8, $7a, $9c, $6c, $b4, $44, $e4, $1c, $11, $5a, $11, $54, $ac
	db $ab, $0e, $f9, $19, $fe, $ec, $eb, $06, $fd, $0e, $fe, $04, $c6, $05, $05, $fa
	db $2a, $d1, $53, $88, $8b, $ff, $30, $df, $50, $df, $50, $9f, $b0, $1f, $50, $3f
	db $a0, $0f, $30, $e7, $d8, $04, $c6, $0d, $14, $04, $c6, $0a, $cb, $33, $de, $22
	db $f9, $07, $f2, $0c, $e6, $19, $ee, $11, $04, $c6, $00, $f7, $f7, $07, $7f, $fa
	db $fa, $c1, $cf, $3f, $bf, $04, $c6, $02, $44, $54, $33, $77, $01, $0e, $1c, $f3
	db $ce, $f1, $ef, $10, $04, $c6, $00, $37, $48, $1f, $e0, $04, $8a, $12, $04, $c6
	db $02

;@ path: gfx/monsters/pictures
;@ Picture of Eyeder (species $7A): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $CC packed).
MonPic_Eyeder::
	db $40, $02, $05, $ff, $05, $ff, $ff, $4d, $05, $27, $0f, $13, $01, $fe, $07
	db $f9, $0f, $f6, $1f, $ed, $3f, $05, $26, $01, $0f, $f0, $ff, $cf, $ff, $3f, $fd
	db $f7, $dd, $ff, $18, $05, $26, $03, $80, $7f, $c0, $7f, $c0, $ff, $80, $05, $26
	db $0f, $12, $03, $fc, $0c, $f0, $10, $e0, $20, $c0, $40, $f0, $70, $a8, $d8, $db
	db $7e, $f3, $ff, $14, $1c, $24, $3c, $44, $7c, $05, $fa, $f5, $c0, $3f, $30, $0f
	db $08, $07, $04, $03, $02, $05, $fa, $00, $05, $5e, $0f, $17, $05, $28, $12, $d8
	db $b8, $a8, $d8, $f7, $7f, $c9, $ff, $38, $ff, $28, $3c, $48, $cb, $48, $7f, $60
	db $60, $90, $f0, $08, $c8, $89, $b9, $87, $e7, $c4, $de, $c2, $f2, $a1, $ed, $07
	db $07, $18, $18, $6f, $6f, $b4, $bc, $c9, $d9, $13, $b2, $67, $e6, $9b, $9e, $ff
	db $00, $ff, $f0, $0f, $0c, $73, $72, $dd, $dd, $ff, $33, $05, $14, $1f, $04, $05
	db $27, $09, $48, $cc, $c4, $f7, $e4, $6f, $f2, $16, $ff, $0f, $05, $26, $02, $f0
	db $fb, $8c, $8e, $43, $43, $3f, $fc, $0f, $be, $e3, $ee, $ff, $1c, $ff, $00, $e7
	db $ec, $1f, $b8, $ff, $e0, $05, $26, $0f, $4d, $05, $e0, $1f, $17

;@ path: gfx/monsters/pictures
;@ Picture of GiantMoth (species $7B): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $152 packed).
MonPic_GiantMoth::
	db $40, $02, $09
	db $ff, $09, $ff, $ff, $4d, $78, $ff, $87, $87, $fa, $c2, $7f, $c2, $7f, $e1, $3f
	db $e1, $3f, $f0, $1f, $09, $00, $01, $ff, $ff, $20, $1f, $f3, $7f, $f8, $4f, $fc
	db $a3, $ff, $09, $00, $01, $80, $ff, $60, $ff, $f8, $ff, $17, $fd, $6e, $b7, $da
	db $ff, $00, $ff, $01, $ff, $06, $ff, $19, $ff, $3e, $ff, $d0, $7f, $ef, $d8, $b7
	db $ff, $00, $ff, $fd, $ff, $06, $fe, $c9, $f0, $3f, $dd, $ff, $65, $ff, $8a, $ff
	db $ff, $3c, $ff, $c2, $c3, $be, $87, $fc, $87, $fc, $0f, $f8, $0f, $f8, $1f, $f0
	db $f8, $0f, $fc, $07, $fe, $03, $ff, $01, $09, $00, $04, $99, $ff, $47, $ff, $20
	db $ff, $d1, $ff, $fb, $3e, $fe, $0d, $f8, $17, $f1, $6f, $1f, $f3, $3f, $ec, $7b
	db $f6, $f3, $bf, $db, $5e, $ef, $ad, $ff, $da, $ff, $6f, $f1, $9f, $f9, $6f, $bc
	db $df, $9f, $fb, $b7, $f4, $ee, $6b, $fe, $b7, $ff, $ed, $32, $ff, $c4, $ff, $08
	db $ff, $17, $ff, $bf, $f8, $ff, $60, $7f, $90, $1f, $ec, $3f, $e0, $7f, $c0, $ff
	db $80, $09, $00, $09, $01, $ff, $02, $fe, $05, $fc, $0b, $09, $28, $10, $ff, $07
	db $c1, $bf, $9b, $7e, $27, $fe, $4b, $ff, $3f, $fd, $1f, $f2, $3f, $e5, $ff, $f9
	db $fb, $7f, $ff, $da, $ff, $dd, $fb, $be, $fd, $af, $fe, $eb, $ff, $69, $ff, $68
	db $bf, $fd, $ff, $b6, $ff, $76, $bf, $fb, $7f, $eb, $ff, $ae, $ff, $2d, $ff, $2d
	db $0f, $f2, $b3, $fd, $c9, $fe, $a4, $ff, $f8, $7f, $f0, $9f, $f8, $4f, $ff, $3f
	db $09, $80, $03, $40, $7f, $a0, $09, $78, $10, $ff, $c0, $09, $00, $0d, $01, $09
	db $90, $11, $02, $ff, $04, $ff, $05, $ff, $06, $ff, $00, $ff, $70, $ff, $68, $ff
	db $a8, $09, $a4, $11, $14, $09, $aa, $11, $1d, $09, $5c, $10, $ff, $2a, $ff, $2a
	db $ff, $51, $ff, $50, $ff, $50, $09, $00, $03, $80, $ff, $40, $ff, $40, $09, $7e
	db $1f, $00, $09, $01, $0f, $0f, $0c, $09, $00, $0b, $60, $09, $00, $0f, $1b

;@ path: gfx/monsters/pictures
;@ Picture of Droll (species $7C): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked by
;@ LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $119 packed).
MonPic_Droll::
	db $40
	db $02, $08, $ff, $08, $ff, $ff, $4d, $08, $1b, $0f, $07, $01, $ff, $01, $08, $1a
	db $09, $80, $7f, $40, $bf, $a0, $08, $70, $08, $fe, $02, $fd, $05, $08, $80, $08
	db $ff, $80, $08, $1a, $0f, $15, $8f, $00, $27, $00, $77, $25, $27, $07, $8f, $03
	db $df, $50, $ef, $2f, $e0, $20, $c0, $40, $80, $80, $00, $00, $81, $81, $02, $03
	db $fb, $0a, $f7, $f4, $07, $04, $03, $02, $01, $01, $08, $ea, $00, $40, $c0, $08
	db $1a, $02, $f1, $00, $e4, $00, $ee, $a4, $e4, $e0, $f1, $08, $ff, $03, $08, $1a
	db $0f, $07, $fe, $02, $fc, $04, $08, $32, $14, $fe, $02, $fe, $06, $82, $83, $02
	db $03, $02, $03, $04, $07, $04, $05, $04, $07, $09, $0f, $0b, $0e, $41, $c1, $40
	db $c0, $40, $c0, $20, $e0, $20, $a0, $20, $e0, $90, $f0, $d0, $70, $7f, $40, $3f
	db $20, $08, $62, $14, $7f, $40, $7f, $60, $08, $1a, $0f, $0d, $f9, $09, $ff, $1f
	db $fe, $02, $ff, $03, $08, $7a, $00, $fe, $03, $fe, $03, $17, $1d, $26, $3f, $4a
	db $7f, $96, $fb, $2c, $f7, $5c, $e7, $9b, $ef, $b4, $dc, $e8, $b8, $64, $fc, $72
	db $de, $79, $cf, $3c, $e7, $3f, $e3, $df, $f1, $2f, $39, $9f, $90, $ff, $f8, $7f
	db $40, $ff, $c0, $08, $aa, $01, $40, $ff, $40, $08, $1a, $0f, $0d, $fd, $07, $fb
	db $0f, $f7, $1d, $ef, $3b, $fc, $37, $ff, $0f, $08, $1a, $00, $78, $b8, $63, $e3
	db $9f, $9f, $70, $f0, $cf, $3f, $ff, $f0, $08, $1a, $00, $1f, $1c, $c7, $c6, $f9
	db $f9, $0e, $0f, $f3, $fc, $08, $fa, $12, $ff, $a0, $ff, $d0, $ff, $a8, $ff, $d4
	db $ff, $2c, $08, $0a, $22, $08, $1a, $0c

;@ path: gfx/monsters/pictures
;@ Picture of ArmyCrab (species $7D): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $127 packed).
MonPic_ArmyCrab::
	db $40, $02, $04, $ff, $04, $ff, $ff, $4d
	db $04, $5f, $0f, $4d, $04, $7b, $0f, $07, $03, $fe, $02, $ff, $01, $04, $7a, $09
	db $80, $7f, $40, $04, $7a, $07, $01, $fe, $02, $fd, $05, $04, $e2, $08, $ff, $80
	db $04, $7a, $0f, $06, $01, $ff, $03, $fd, $07, $f9, $0f, $fa, $0e, $ff, $60, $df
	db $f0, $af, $b8, $f7, $dd, $7b, $eb, $9f, $ff, $64, $7c, $7e, $7e, $bf, $a4, $db
	db $5a, $e9, $e9, $54, $b4, $b3, $73, $5c, $bf, $e0, $ff, $8f, $ff, $fb, $4a, $b7
	db $b4, $2f, $2e, $55, $5b, $9b, $9d, $75, $fb, $0e, $fe, $e2, $fe, $ff, $0c, $f7
	db $1e, $eb, $3a, $df, $77, $bd, $af, $f3, $ff, $4d, $7d, $fc, $fc, $04, $e4, $07
	db $c0, $3f, $e0, $bf, $e0, $f3, $1f, $f6, $3f, $ce, $6f, $f1, $31, $e2, $22, $e8
	db $28, $c3, $43, $d7, $57, $c7, $ff, $4c, $ff, $3f, $ff, $3b, $ee, $fd, $e7, $9e
	db $93, $0f, $09, $8f, $88, $3a, $f5, $d5, $ef, $bf, $ff, $7f, $ff, $a5, $df, $7a
	db $f5, $0f, $ff, $c1, $fe, $b9, $5f, $56, $ef, $fb, $ff, $fd, $fe, $4b, $f7, $bc
	db $5f, $e1, $ff, $e7, $1e, $c7, $ff, $64, $ff, $f8, $ff, $b9, $ef, $7e, $ce, $f2
	db $92, $e1, $21, $e3, $23, $9f, $f0, $df, $f8, $e7, $ec, $1f, $18, $8f, $88, $2f
	db $28, $87, $84, $d7, $d4, $c7, $44, $d7, $54, $e3, $22, $eb, $2a, $f1, $11, $ff
	db $0f, $04, $7a, $00, $cf, $48, $cf, $48, $df, $50, $ff, $60, $04, $7a, $04, $f0
	db $3f, $ff, $0f, $fe, $00, $fe, $04, $7b, $06, $18, $ff, $20, $df, $00, $bf, $00
	db $7f, $04, $7b, $03, $e7, $24, $e7, $24, $f7, $14, $ff, $0c, $ff, $01, $04, $de
	db $02, $04, $e0, $10, $8f, $88, $af, $a8, $1f, $10, $ff, $e0, $04, $7a, $00

;@ path: gfx/monsters/pictures
;@ Picture of MadHornet (species $7E): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $15A packed).
MonPic_MadHornet::
	db $40
	db $02, $09, $ff, $09, $ff, $f2, $03, $ff, $02, $ff, $01, $ff, $01, $09, $00, $03
	db $09, $ff, $f0, $80, $ff, $40, $7f, $a0, $bf, $d0, $09, $0e, $07, $09, $21, $0f
	db $09, $01, $ff, $06, $fb, $0d, $f7, $39, $df, $e2, $09, $12, $05, $80, $09, $20
	db $0f, $03, $df, $a8, $e7, $5c, $c7, $7a, $f7, $2a, $fb, $15, $fb, $0d, $fd, $06
	db $ff, $03, $09, $20, $09, $80, $ff, $7d, $ff, $01, $ff, $02, $fe, $0d, $f9, $16
	db $fa, $25, $f1, $4e, $ef, $91, $d7, $2e, $c7, $3c, $3f, $c4, $8f, $78, $7f, $90
	db $3f, $e0, $ff, $40, $09, $58, $0f, $05, $09, $0a, $03, $09, $0b, $00, $01, $ff
	db $70, $9f, $fd, $7f, $e7, $fa, $8e, $fc, $d5, $b3, $ff, $7a, $ff, $7e, $ef, $9f
	db $fe, $73, $ff, $cd, $ff, $a3, $a3, $70, $50, $9c, $fc, $b2, $fa, $e7, $ff, $bf
	db $78, $ff, $f8, $7f, $87, $8f, $f8, $f8, $df, $ee, $bd, $f7, $bf, $f7, $3c, $09
	db $14, $03, $60, $3f, $d8, $9f, $66, $a7, $d9, $ff, $7f, $09, $20, $0c, $fe, $03
	db $fe, $03, $09, $06, $01, $02, $09, $00, $02, $dd, $f7, $9b, $bf, $cf, $5d, $fe
	db $33, $fc, $04, $f8, $08, $f8, $18, $f0, $33, $4b, $ee, $fd, $ff, $86, $87, $01
	db $f9, $00, $06, $00, $01, $00, $00, $00, $f0, $db, $7e, $cb, $ee, $9f, $de, $ef
	db $f6, $f7, $aa, $77, $59, $7b, $d4, $3d, $2a, $09, $80, $0b, $40, $09, $2c, $0f
	db $0a, $01, $ff, $02, $f0, $37, $f0, $5c, $d0, $78, $90, $f1, $d8, $ab, $59, $bb
	db $7e, $a6, $7d, $c5, $00, $fc, $00, $1e, $00, $0e, $00, $c7, $00, $e3, $80, $f3
	db $80, $f3, $01, $e5, $3c, $6b, $3d, $26, $2d, $36, $2f, $32, $73, $6f, $7b, $55
	db $fb, $95, $f9, $0f, $7f, $c0, $7f, $a0, $7f, $90, $1f, $e8, $47, $bc, $d7, $ac
	db $f3, $6e, $fd, $1b, $09, $20, $0d, $02, $09, $7e, $0a, $fb, $8b, $f7, $1c, $ef
	db $38, $ff, $30, $09, $aa, $04, $07, $06, $ff, $f8, $09, $20, $08, $fd, $0b, $ff
	db $05, $09, $7e, $09, $07, $09, $20, $0f, $0b

;@ path: gfx/monsters/pictures
;@ Picture of HornBeet (species $7F): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $148 packed).
MonPic_HornBeet::
	db $40, $02, $09, $ff, $09, $ff, $ff
	db $4d, $00, $ff, $0c, $fb, $0e, $fd, $07, $fe, $03, $ff, $01, $09, $02, $05, $01
	db $fe, $02, $fe, $c2, $3e, $72, $cf, $df, $f0, $36, $ff, $60, $ff, $c0, $ff, $80
	db $ff, $81, $fe, $82, $7e, $c3, $3c, $7d, $02, $3b, $ff, $0c, $ff, $06, $ff, $03
	db $fe, $02, $fe, $82, $fc, $85, $79, $7b, $80, $f8, $09, $02, $03, $81, $fe, $87
	db $f9, $9b, $e7, $ee, $1f, $09, $9f, $00, $60, $bf, $e0, $7f, $09, $83, $00, $09
	db $03, $0f, $03, $0f, $09, $02, $07, $03, $fe, $03, $e2, $e2, $f9, $19, $fc, $04
	db $fe, $02, $fe, $32, $ee, $3a, $e6, $2e, $fa, $ba, $8f, $cf, $3f, $30, $7f, $40
	db $ff, $80, $ff, $98, $ef, $b8, $cf, $d9, $be, $ba, $ff, $e0, $09, $02, $07, $80
	db $09, $b8, $0f, $06, $09, $03, $05, $fe, $02, $ff, $01, $ff, $0f, $fd, $05, $ff
	db $03, $fd, $05, $fb, $0b, $ff, $0e, $62, $e2, $22, $62, $02, $03, $84, $85, $18
	db $19, $38, $29, $36, $2e, $9f, $9d, $8c, $8d, $89, $bb, $81, $b5, $43, $43, $31
	db $b1, $39, $a9, $d9, $e9, $f3, $72, $09, $b8, $01, $e0, $09, $f4, $00, $7f, $40
	db $bf, $a0, $09, $00, $19, $09, $03, $0f, $02, $f1, $11, $e0, $2e, $c0, $43, $c0
	db $40, $80, $09, $98, $13, $fd, $f6, $56, $5f, $39, $b9, $1c, $dc, $0a, $6a, $0d
	db $2d, $07, $27, $06, $06, $7f, $df, $d4, $f4, $38, $3b, $70, $76, $a0, $ac, $60
	db $68, $c0, $c8, $c0, $c0, $1f, $10, $0f, $e8, $07, $84, $07, $04, $03, $02, $09
	db $c8, $12, $09, $02, $0f, $0d, $c0, $40, $e0, $20, $f8, $18, $e6, $26, $c1, $41
	db $ff, $7e, $09, $02, $00, $0b, $0b, $0d, $0d, $15, $15, $23, $2b, $c1, $c7, $09
	db $fa, $12, $a0, $a0, $60, $60, $50, $50, $88, $a8, $07, $c7, $ff, $fc, $09, $02
	db $00, $07, $04, $0f, $08, $3f, $30, $cf, $d8, $07, $0c, $09, $1a, $22, $09, $02
	db $0c

;@ path: gfx/monsters/pictures
;@ Picture of Armorpion (species $80): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $188 packed).
MonPic_Armorpion::
	db $40, $02, $02, $ff, $02, $ff, $ff, $0d, $07, $f8, $0f, $f0, $1c, $e3, $3b
	db $e4, $35, $e4, $37, $e4, $27, $f4, $15, $ff, $c0, $3f, $e0, $1f, $70, $8f, $b8
	db $4f, $58, $4f, $d8, $4f, $c8, $5f, $50, $02, $00, $0f, $0e, $02, $ff, $ff, $0c
	db $fa, $1b, $fe, $0f, $fa, $0b, $fa, $0b, $fd, $05, $fc, $04, $fc, $06, $fc, $05
	db $bf, $b0, $ff, $e0, $bf, $a0, $bf, $a0, $7f, $40, $7f, $40, $7f, $c0, $7f, $40
	db $02, $40, $0f, $16, $01, $ff, $01, $02, $00, $09, $80, $7f, $c0, $bf, $e0, $9f
	db $b0, $fc, $07, $f8, $0c, $f8, $0b, $ff, $1f, $f1, $1f, $ee, $3f, $f2, $3e, $e4
	db $7e, $7f, $c0, $3f, $60, $3f, $a0, $ff, $f0, $1f, $f0, $ef, $f8, $9f, $f8, $4f
	db $fc, $02, $00, $05, $03, $fd, $07, $fb, $0e, $f3, $1a, $02, $00, $0f, $04, $19
	db $e7, $3d, $cf, $5f, $d9, $5f, $fc, $3c, $8f, $be, $c9, $5f, $c8, $cf, $30, $ff
	db $00, $ff, $81, $ff, $43, $7f, $fc, $fc, $cc, $7c, $d2, $76, $d1, $fd, $f0, $fc
	db $af, $ff, $59, $fd, $4f, $ff, $89, $ea, $67, $7c, $97, $dd, $16, $7f, $1e, $7f
	db $ea, $ff, $35, $7f, $e5, $ff, $22, $ae, $e3, $fa, $27, $f4, $27, $e6, $19, $ff
	db $01, $ff, $03, $ff, $85, $fd, $7e, $7e, $02, $00, $03, $30, $cf, $78, $e7, $f4
	db $37, $f4, $7f, $78, $e3, $2f, $e3, $22, $e1, $2f, $e8, $2f, $fc, $17, $f5, $1d
	db $f9, $09, $ff, $0f, $f8, $08, $fc, $e4, $1f, $ff, $09, $fd, $c7, $ff, $64, $ff
	db $77, $ff, $b7, $bc, $58, $7c, $7d, $7e, $f3, $f3, $1f, $9f, $c7, $c7, $60, $63
	db $e0, $e0, $f0, $10, $34, $7c, $7c, $fc, $9f, $9f, $f1, $f3, $c7, $c7, $0c, $8d
	db $0f, $0f, $1f, $10, $3f, $21, $7f, $4e, $f1, $ff, $20, $7f, $c6, $ff, $4d, $ff
	db $dd, $ff, $db, $7b, $8f, $e8, $8f, $88, $0f, $e8, $2f, $e8, $7f, $d0, $5f, $70
	db $3f, $20, $ff, $e0, $f8, $09, $fc, $05, $fe, $06, $f9, $1d, $e3, $3b, $ff, $3c
	db $02, $00, $00, $af, $ec, $a7, $e6, $5f, $de, $3f, $70, $df, $f0, $ff, $02, $36
	db $10, $00, $ff, $0f, $02, $00, $0b, $e0, $02, $00, $0a, $ea, $6f, $ca, $cf, $f4
	db $f6, $f9, $1d, $f7, $1f, $ff, $18, $02, $00, $00, $3f, $20, $7f, $40, $ff, $c0
	db $3f, $70, $8f, $b8, $ff, $78, $02, $00, $00

;@ path: gfx/monsters/pictures
;@ Picture of Digster (species $81): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1AA packed).
MonPic_Digster::
	db $40, $02, $09, $ff, $09, $ff, $ff
	db $04, $fc, $00, $f3, $00, $ef, $00, $df, $09, $ff, $f3, $80, $00, $79, $00, $f7
	db $09, $1b, $03, $c0, $00, $1f, $00, $ff, $00, $1f, $00, $e7, $00, $fb, $09, $ff
	db $f1, $7f, $00, $8f, $00, $f3, $00, $fd, $00, $fe, $09, $ff, $fd, $7f, $00, $bf
	db $09, $ff, $f3, $fe, $09, $65, $05, $bf, $01, $be, $03, $7c, $07, $f8, $cf, $b0
	db $be, $80, $8e, $80, $9e, $40, $5e, $bb, $b8, $07, $3f, $01, $7f, $04, $7f, $0a
	db $7f, $12, $f7, $12, $de, $00, $de, $ff, $00, $ff, $f0, $0f, $7f, $81, $ef, $81
	db $bf, $40, $d8, $20, $ae, $18, $df, $09, $00, $05, $c0, $bf, $f0, $8f, $fc, $47
	db $7c, $df, $00, $ef, $09, $ff, $fe, $03, $fd, $07, $fe, $06, $fe, $06, $fe, $02
	db $ff, $01, $41, $7d, $82, $bf, $c1, $ff, $5f, $7f, $7f, $6a, $7f, $77, $88, $ff
	db $88, $ff, $00, $e9, $80, $09, $64, $00, $7f, $80, $bf, $c0, $ff, $c0, $df, $38
	db $bf, $04, $87, $02, $1e, $03, $7f, $05, $fe, $07, $fd, $05, $fe, $0f, $ff, $3c
	db $fc, $27, $e4, $13, $fa, $89, $bd, $49, $cf, $d1, $5f, $52, $fb, $b2, $fb, $14
	db $f7, $09, $00, $07, $80, $09, $1a, $11, $09, $ff, $fb, $88, $ab, $cc, $4c, $ff
	db $3f, $f0, $10, $e0, $20, $c0, $40, $cf, $4f, $90, $90, $1f, $17, $3f, $2f, $dc
	db $fc, $39, $39, $1a, $1a, $0f, $2f, $cc, $fc, $27, $37, $dd, $dd, $66, $66, $8c
	db $8d, $3f, $3f, $c0, $c3, $00, $0f, $00, $1f, $c0, $ff, $94, $f7, $79, $f9, $22
	db $eb, $24, $ef, $d4, $df, $49, $c9, $23, $ea, $25, $ed, $09, $1e, $11, $09, $1b
	db $1a, $01, $09, $82, $15, $00, $ff, $00, $a0, $a7, $20, $2f, $40, $4f, $09, $94
	db $12, $e0, $ef, $d0, $df, $18, $98, $08, $c8, $10, $d0, $10, $d0, $20, $e1, $09
	db $a8, $13, $3f, $10, $5f, $08, $ef, $08, $ff, $04, $f7, $0a, $fb, $11, $fd, $11
	db $f7, $14, $ff, $18, $fb, $10, $f7, $10, $f7, $10, $ff, $20, $eb, $20, $fb, $40
	db $d3, $09, $1a, $10, $7f, $c0, $7f, $c0, $3f, $a0, $3f, $e0, $09, $da, $10, $09
	db $00, $0c, $f0, $77, $ef, $2f, $f0, $17, $ff, $0f, $09, $00, $04, $20, $a1, $d0
	db $d0, $3f, $bf, $fe, $c6, $09, $8a, $12, $ff, $00, $60, $fe, $81, $df, $86, $fe
	db $18, $38, $f0, $f0, $f8, $08, $ff, $07, $ff, $00, $80, $b3, $00, $33, $02, $73
	db $12, $73, $13, $53, $7f, $7e, $09, $1e, $10, $09, $da, $12, $3f, $e0, $ff, $c0
	db $09, $00, $02

;@ path: gfx/monsters/pictures
;@ Picture of Pixy (species $82): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked by
;@ LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $F4 packed).
MonPic_Pixy::
	db $40, $02, $05, $ff, $05, $ff, $ff, $4d, $05, $5f, $0f, $4d, $05
	db $7b, $0f, $07, $18, $f7, $1c, $f3, $1e, $ff, $00, $ff, $01, $ff, $02, $ff, $06
	db $fc, $1e, $e5, $26, $c9, $4c, $c8, $4e, $05, $7a, $01, $80, $ff, $c0, $ff, $70
	db $cf, $48, $67, $24, $e7, $24, $05, $7a, $07, $30, $df, $70, $9f, $f0, $05, $7a
	db $0f, $0d, $f9, $0b, $f8, $0d, $fc, $06, $fc, $06, $fe, $02, $fe, $7f, $fb, $87
	db $91, $83, $84, $87, $c3, $c3, $20, $a0, $40, $40, $3d, $bd, $2f, $7b, $4d, $fb
	db $c4, $fd, $43, $c3, $86, $87, $08, $0a, $04, $04, $78, $7a, $e8, $bd, $65, $bf
	db $47, $7f, $3f, $a0, $3f, $60, $7f, $c0, $7f, $c0, $ff, $80, $ff, $fc, $bf, $c2
	db $13, $82, $05, $7a, $0f, $0d, $fc, $41, $e7, $21, $ff, $11, $fb, $09, $ff, $07
	db $05, $7a, $01, $01, $b3, $fc, $0f, $ff, $30, $ff, $49, $ff, $0e, $ff, $88, $ff
	db $ff, $ff, $00, $7a, $9c, $7f, $e4, $ff, $6e, $ff, $8d, $ff, $07, $df, $3f, $bc
	db $e3, $fa, $01, $bd, $ff, $84, $6f, $c8, $3f, $f0, $3f, $e0, $ff, $c0, $05, $7a
	db $0f, $14, $01, $ff, $01, $fe, $03, $ff, $06, $fa, $0d, $ff, $0f, $05, $7a, $00
	db $00, $ff, $f0, $ff, $3f, $ef, $ff, $40, $7f, $a0, $ff, $e0, $05, $7a, $00, $01
	db $ff, $1f, $ff, $f8, $ef, $ff, $04, $fc, $0b, $05, $fa, $12, $05, $f0, $04, $bf
	db $60, $05, $0a, $22, $05, $7a, $0c

;@ path: gfx/monsters/pictures
;@ Picture of ArcDemon (species $83): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1CD packed).
MonPic_ArcDemon::
	db $40, $02, $0a, $ff, $00, $ff, $04, $ff, $0c
	db $fb, $0f, $f3, $1e, $ff, $1f, $ff, $0a, $ff, $f0, $0a, $0d, $02, $f8, $f7, $3e
	db $f9, $0d, $fc, $35, $dc, $77, $0a, $0c, $07, $80, $ff, $80, $7f, $c0, $0a, $0c
	db $07, $0a, $31, $0e, $60, $df, $70, $0a, $30, $0f, $00, $01, $fe, $03, $fc, $06
	db $fc, $06, $f8, $0c, $f0, $19, $f0, $19, $9d, $f7, $19, $bf, $19, $3d, $09, $5b
	db $09, $5f, $04, $8d, $07, $0f, $1b, $1f, $3f, $60, $fc, $c0, $fb, $cb, $f4, $54
	db $b0, $70, $fa, $9a, $f5, $df, $68, $ed, $ff, $04, $ff, $8c, $7f, $cc, $bf, $b4
	db $6f, $74, $ff, $c9, $7f, $df, $b6, $bf, $cf, $78, $c7, $6c, $c3, $66, $81, $d3
	db $81, $d3, $00, $89, $00, $84, $c0, $c4, $0a, $20, $08, $7f, $c0, $7f, $c0, $e0
	db $31, $e0, $32, $e0, $32, $e1, $33, $c1, $65, $c2, $67, $c2, $67, $c4, $67, $65
	db $7e, $43, $77, $80, $fe, $00, $9e, $00, $b7, $03, $ff, $14, $ff, $08, $3f, $df
	db $77, $ca, $e7, $4f, $5f, $27, $2f, $2f, $3f, $ef, $ff, $50, $f0, $4d, $fd, $dd
	db $73, $9e, $3f, $90, $d3, $20, $a3, $a1, $e7, $be, $ff, $52, $7f, $92, $ff, $20
	db $e4, $18, $7a, $09, $db, $0f, $ff, $0e, $cf, $0c, $6d, $07, $ff, $ef, $ff, $3f
	db $60, $3f, $60, $ff, $f8, $ff, $e0, $1f, $30, $3f, $3e, $ff, $f8, $df, $f0, $c4
	db $67, $c8, $6d, $c4, $67, $c4, $67, $ce, $6f, $df, $73, $fe, $62, $ff, $61, $08
	db $7f, $08, $ff, $34, $f7, $1c, $7f, $6a, $eb, $8d, $8d, $13, $13, $03, $03, $47
	db $ff, $20, $ff, $37, $f7, $17, $f8, $2f, $ff, $ff, $0a, $14, $10, $ff, $11, $ff
	db $23, $ff, $7e, $7e, $fe, $fe, $e3, $ff, $1c, $fc, $0c, $fc, $34, $fe, $3f, $3f
	db $9b, $9f, $17, $17, $27, $25, $c7, $c5, $cf, $c8, $3f, $30, $5f, $50, $0a, $18
	db $14, $9f, $b0, $df, $70, $ff, $30, $ff, $30, $ff, $74, $ff, $67, $ff, $3f, $fe
	db $7f, $fe, $fa, $fc, $17, $fc, $1d, $fc, $07, $c2, $c2, $c4, $c5, $b8, $bf, $00
	db $eb, $00, $bc, $00, $f8, $00, $c0, $3f, $3f, $9f, $ff, $c0, $ff, $bf, $ff, $40
	db $ff, $7f, $ff, $20, $3f, $ff, $ff, $ff, $00, $c8, $ff, $18, $fe, $e8, $fb, $10
	db $f1, $f1, $f1, $3e, $fe, $ff, $e3, $fe, $02, $1f, $1c, $23, $be, $01, $b7, $01
	db $fd, $c1, $df, $03, $77, $ff, $fe, $07, $04, $ff, $10, $0a, $30, $0a, $fe, $07
	db $fd, $05, $fe, $02, $fd, $05, $f8, $08, $f8, $0f, $ff, $07, $ff, $00, $1b, $9a
	db $e5, $e5, $09, $0b, $83, $86, $07, $3c, $3f, $f8, $ff, $0a, $2f, $0f, $00, $fd
	db $05, $fc, $07, $ff, $03, $0a, $0c, $06, $1b, $1a, $01, $81, $81, $ff, $ff, $7e
	db $0a, $30, $0f, $05

;@ path: gfx/monsters/pictures
;@ Picture of AgDevil (species $84): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $176 packed).
MonPic_AgDevil::
	db $40, $02, $02, $ff, $02, $ff, $ff, $29, $01, $fe, $07, $02
	db $00, $09, $e0, $df, $38, $02, $00, $0f, $0a, $f0, $ef, $7e, $02, $00, $09, $03
	db $fe, $03, $02, $00, $0b, $c0, $fb, $0c, $f5, $1b, $eb, $36, $ff, $24, $d7, $6c
	db $ff, $48, $df, $69, $fe, $4f, $b7, $4c, $eb, $f6, $f5, $1b, $f9, $0f, $ff, $06
	db $ff, $00, $ff, $80, $ff, $80, $02, $00, $09, $1e, $ef, $fc, $f1, $3f, $fe, $1f
	db $ff, $1f, $ff, $1f, $fe, $0f, $fd, $0f, $fd, $0f, $fb, $0f, $ff, $81, $7f, $e1
	db $9f, $f0, $0f, $f8, $f7, $fc, $cb, $ff, $bd, $fe, $79, $fe, $3f, $e0, $1f, $90
	db $8f, $e8, $8b, $cb, $ce, $fd, $4e, $c9, $df, $70, $b7, $24, $d9, $6f, $d1, $73
	db $e3, $2e, $a3, $a6, $e7, $7e, $e5, $27, $f7, $1c, $db, $48, $ff, $03, $fc, $0f
	db $f3, $1f, $e1, $3f, $de, $7f, $a7, $ff, $7b, $ff, $3d, $ff, $1f, $f8, $ff, $f0
	db $02, $12, $11, $e0, $7f, $e0, $7f, $e0, $bf, $e0, $fb, $0f, $fe, $0f, $fe, $03
	db $ff, $01, $ff, $01, $02, $00, $02, $7f, $f8, $f3, $fc, $ff, $f0, $e7, $f8, $ff
	db $61, $ff, $21, $ce, $72, $ff, $47, $d3, $66, $f7, $4f, $db, $61, $e2, $37, $f3
	db $17, $f8, $1b, $57, $bf, $13, $5b, $97, $cc, $df, $e4, $b7, $0c, $8f, $d8, $9f
	db $d1, $3f, $b1, $d4, $fa, $91, $b5, $fd, $3f, $9e, $7f, $fe, $1f, $cf, $3f, $ff
	db $0d, $ff, $08, $e7, $9c, $ff, $c4, $bf, $e0, $ff, $e0, $02, $ae, $0b, $02, $ff
	db $fa, $45, $ff, $49, $ff, $4a, $ff, $4c, $dd, $6e, $ff, $26, $ef, $34, $f7, $1b
	db $fb, $ff, $9c, $a7, $df, $63, $cf, $30, $f7, $d8, $ff, $3f, $df, $30, $ef, $f8
	db $bf, $ff, $73, $cb, $f7, $8c, $e7, $18, $df, $36, $fb, $fc, $f7, $18, $ef, $3f
	db $ff, $44, $ff, $24, $ff, $a4, $ff, $64, $77, $ec, $ff, $c8, $ef, $58, $df, $b0
	db $02, $00, $0f, $0e, $09, $fb, $0d, $fe, $0f, $f5, $1f, $f5, $1f, $ff, $1b, $02
	db $00, $00, $37, $fc, $ff, $ec, $ff, $80, $7f, $c0, $ff, $c0, $02, $00, $02, $d9
	db $7f, $ff, $6f, $fe, $03, $fd, $07, $ff, $07, $02, $28, $13, $20, $bf, $60, $ff
	db $e0, $5f, $f0, $5f, $f0, $ff, $02, $cf, $1f, $02

;@ path: gfx/monsters/pictures
;@ Picture of Demonite (species $85): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $10F packed).
MonPic_Demonite::
	db $40, $02, $06, $ff, $06, $ff
	db $ff, $4d, $06, $4b, $0f, $37, $0f, $f7, $1d, $f7, $1d, $06, $4a, $07, $c0, $ff
	db $40, $ff, $40, $06, $4a, $0f, $18, $40, $ff, $60, $df, $70, $06, $4a, $07, $04
	db $ff, $0c, $f7, $1c, $ef, $3a, $ef, $3a, $df, $75, $06, $04, $11, $61, $df, $61
	db $ff, $36, $ff, $80, $ff, $80, $06, $4a, $0d, $0d, $f7, $1c, $e7, $3c, $cf, $7e
	db $e7, $3f, $06, $ae, $01, $7c, $83, $83, $86, $fe, $da, $7f, $e4, $7f, $f4, $7f
	db $fe, $8b, $eb, $3b, $e4, $3f, $d0, $1f, $e0, $bf, $60, $7f, $64, $ff, $2a, $bb
	db $f3, $f1, $af, $b8, $4f, $f8, $17, $f1, $0e, $fb, $0c, $ff, $4c, $ff, $a8, $bf
	db $9f, $1f, $ff, $14, $ff, $6c, $bb, $ef, $fb, $ee, $bf, $ec, $7f, $dc, $7f, $dc
	db $ff, $d0, $06, $14, $1e, $ff, $01, $ff, $01, $06, $4a, $06, $7f, $c3, $7c, $c5
	db $7c, $cf, $ba, $eb, $b1, $ff, $b3, $fe, $df, $7c, $e7, $3f, $36, $72, $12, $f0
	db $14, $f4, $4b, $5b, $c5, $ff, $85, $bf, $84, $ff, $83, $ff, $d8, $9f, $90, $1f
	db $50, $5c, $a5, $b5, $47, $fe, $43, $fa, $43, $fe, $83, $fe, $ff, $f0, $9f, $f0
	db $9f, $f0, $ff, $f0, $ff, $50, $06, $c8, $13, $06, $4b, $0f, $0c, $f8, $1f, $ff
	db $07, $fe, $02, $fe, $02, $fc, $05, $ff, $0f, $06, $4a, $00, $80, $ff, $00, $ef
	db $d0, $d3, $3f, $ff, $1f, $f0, $ff, $f8, $06, $4a, $00, $03, $fe, $01, $ef, $16
	db $97, $f8, $fb, $f0, $17, $ff, $3f, $06, $4a, $01, $06, $c9, $10, $c8, $df, $e8
	db $5f, $e4, $ef, $f4, $ff, $18, $06, $4a, $0e

;@ path: gfx/monsters/pictures
;@ Picture of DarkEye (species $86): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $FE packed).
MonPic_DarkEye::
	db $40, $02, $04, $ff, $04, $ff, $fe
	db $0f, $fc, $0c, $ff, $03, $ff, $01, $04, $00, $01, $04, $19, $00, $c7, $38, $38
	db $d7, $d7, $2c, $2c, $f6, $f6, $ff, $1f, $f4, $f4, $ff, $00, $ff, $f6, $8f, $8f
	db $78, $78, $97, $97, $ef, $e8, $9f, $90, $4f, $4f, $04, $00, $01, $c0, $ff, $c0
	db $04, $00, $0f, $00, $04, $49, $0f, $03, $01, $ff, $03, $fd, $07, $fd, $07, $fb
	db $0e, $fb, $0e, $fb, $0f, $fa, $0f, $10, $d3, $9b, $9f, $e6, $ed, $ad, $ba, $8b
	db $9c, $8f, $d9, $55, $de, $c3, $c7, $51, $d7, $9b, $db, $c6, $66, $69, $bb, $a6
	db $77, $e2, $33, $42, $e6, $95, $d7, $04, $42, $00, $3f, $e0, $df, $f0, $ff, $b0
	db $ff, $80, $ff, $9c, $e3, $fe, $04, $48, $0f, $0d, $fb, $3f, $db, $7e, $b7, $fc
	db $bf, $e8, $ff, $41, $ff, $01, $fe, $03, $fe, $03, $e0, $73, $d9, $79, $b5, $ff
	db $ad, $ff, $6d, $ff, $75, $df, $f6, $9f, $f5, $9d, $2e, $ab, $35, $35, $ab, $ff
	db $ab, $ee, $b7, $fc, $57, $5c, $d7, $fc, $57, $fc, $1d, $ff, $fd, $e7, $7d, $c7
	db $bf, $e2, $ff, $60, $04, $48, $0f, $13, $fd, $07, $fb, $1e, $e7, $3c, $df, $78
	db $bf, $e0, $bf, $e0, $ff, $40, $ff, $00, $f5, $1f, $ee, $3b, $ed, $3d, $fb, $1f
	db $fb, $0f, $04, $78, $00, $fd, $07, $6f, $68, $af, $b8, $6f, $f8, $5f, $d0, $5f
	db $f0, $df, $f0, $ff, $20, $04, $48, $0f, $16, $04, $17, $1f, $08, $ff, $02, $04
	db $5e, $1f, $2f, $04, $e0, $1f, $47

;@ path: gfx/monsters/pictures
;@ Picture of EyeBall (species $87): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $D7 packed).
MonPic_EyeBall::
	db $40, $02, $02, $ff, $02, $ff, $ff, $4d, $02
	db $1d, $0f, $09, $03, $fe, $03, $02, $1c, $09, $80, $7f, $c0, $02, $70, $0a, $fc
	db $07, $02, $80, $0a, $ff, $80, $02, $1c, $0f, $0e, $01, $02, $1c, $05, $0f, $f3
	db $1e, $ff, $1c, $ff, $e0, $ff, $33, $f8, $1b, $f0, $1c, $e3, $38, $c7, $d0, $cd
	db $e2, $cd, $61, $ff, $0f, $ff, $98, $3f, $b0, $1f, $70, $8f, $38, $c7, $17, $67
	db $8e, $67, $0c, $02, $1c, $07, $e0, $9f, $f0, $ff, $70, $02, $1c, $0f, $12, $01
	db $ff, $07, $fb, $0e, $fb, $0e, $ff, $0c, $ff, $00, $cc, $62, $c7, $50, $e3, $e8
	db $f0, $14, $f8, $08, $fe, $06, $f8, $09, $f8, $1f, $67, $8c, $c7, $14, $8f, $2f
	db $1f, $51, $3f, $20, $ff, $c0, $3f, $20, $3f, $f0, $02, $1c, $03, $c0, $bf, $e0
	db $bf, $e0, $ff, $60, $02, $1c, $0f, $1f, $e2, $3f, $ca, $7e, $c9, $7f, $e5, $27
	db $f2, $17, $f7, $15, $f7, $14, $f7, $1c, $8f, $f8, $a7, $fc, $27, $fc, $4f, $c8
	db $9f, $d0, $df, $50, $df, $50, $df, $02, $0f, $1f, $13, $02, $bf, $0f, $00, $fe
	db $03, $ff, $02, $7f, $01, $ef, $38, $ef, $38, $c7, $6c, $b7, $fc, $6f, $f8, $ff
	db $b0, $02, $fc, $16, $db, $7f, $ec, $3f, $ff, $1b, $02, $a0, $0f, $11

;@ path: gfx/monsters/pictures
;@ Picture of SkulRider (species $88): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $151 packed).
MonPic_SkulRider::
	db $40, $02
	db $05, $ff, $05, $ff, $fa, $01, $05, $00, $03, $20, $ff, $60, $ff, $a0, $ff, $a0
	db $bf, $68, $05, $00, $0b, $05, $21, $0f, $1f, $01, $05, $60, $01, $05, $ff, $f5
	db $9f, $70, $9f, $70, $df, $30, $df, $b0, $df, $b0, $ef, $58, $ef, $58, $ff, $78
	db $ff, $04, $fb, $0a, $fb, $0a, $f5, $15, $f6, $16, $ef, $2f, $e7, $27, $ef, $2f
	db $ff, $40, $bf, $a0, $bf, $a0, $5f, $50, $df, $d0, $ef, $e8, $cf, $c8, $ef, $e8
	db $05, $00, $07, $02, $ff, $04, $ff, $0c, $05, $20, $0f, $0d, $c7, $74, $ff, $7e
	db $e3, $3f, $ee, $3f, $f7, $17, $f6, $16, $f7, $15, $ff, $14, $eb, $2f, $f1, $3f
	db $f0, $fb, $92, $fd, $98, $bf, $ee, $ff, $35, $35, $9f, $9f, $af, $e8, $1f, $f8
	db $1f, $bc, $93, $7e, $23, $fb, $cc, $ff, $1d, $df, $f3, $f2, $ff, $0c, $ff, $14
	db $f7, $7c, $fb, $ce, $ff, $8a, $fb, $8e, $f7, $1c, $ef, $78, $05, $20, $0f, $0d
	db $fb, $0f, $fa, $3e, $eb, $3f, $fe, $3f, $f5, $35, $e9, $79, $ad, $fd, $ff, $ef
	db $58, $d7, $6f, $f0, $ef, $b2, $bf, $f1, $af, $7d, $f5, $c5, $ed, $72, $de, $3b
	db $35, $d7, $ec, $1e, $ef, $9b, $fa, $1f, $eb, $7d, $5f, $47, $6f, $9d, $f7, $b9
	db $bf, $f0, $bf, $f8, $af, $f8, $ff, $f8, $5f, $58, $2f, $3c, $6b, $7e, $ff, $ee
	db $05, $4c, $0f, $06, $05, $ff, $f4, $3f, $fe, $f1, $ef, $5f, $df, $f8, $ff, $28
	db $ff, $28, $f7, $1c, $f7, $3e, $be, $7b, $bf, $f8, $db, $f7, $dd, $76, $ff, $3f
	db $f7, $1f, $fd, $06, $ff, $03, $fb, $bd, $fa, $3f, $b7, $df, $77, $dc, $ff, $f8
	db $df, $f0, $7f, $c0, $ff, $80, $ff, $28, $cf, $f6, $fb, $7d, $ff, $b7, $df, $68
	db $ef, $78, $ff, $50, $ff, $50, $05, $50, $0e, $fe, $03, $05, $64, $08, $fb, $ce
	db $dd, $bf, $ff, $e3, $05, $44, $0f, $0d, $fe, $03, $ff, $03, $05, $00, $02, $bf
	db $e0, $bf, $f0, $7f, $c8, $d7, $fc, $eb, $36, $ff, $1e, $05, $20, $0f, $01

;@ path: gfx/monsters/pictures
;@ Picture of EvilBeast (species $89): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1CE packed).
MonPic_EvilBeast::
	db $40
	db $02, $04, $ff, $04, $ff, $ff, $01, $03, $fc, $07, $f8, $0e, $f1, $1d, $ed, $3d
	db $d5, $75, $04, $00, $03, $80, $ff, $80, $04, $00, $01, $01, $04, $2a, $02, $fe
	db $03, $fe, $02, $ff, $01, $04, $3a, $01, $04, $23, $01, $7f, $c0, $3f, $e0, $1f
	db $70, $6f, $78, $57, $5c, $04, $00, $0f, $02, $04, $35, $00, $03, $fd, $07, $fd
	db $07, $fb, $0f, $a5, $e5, $aa, $ea, $4a, $da, $ff, $ff, $f3, $9b, $f0, $3b, $ff
	db $2f, $fa, $36, $ff, $01, $ff, $82, $ff, $9a, $fd, $d4, $fb, $78, $a1, $c6, $d6
	db $ff, $25, $2f, $ff, $01, $fe, $82, $fe, $b2, $7f, $57, $bf, $3d, $0a, $c7, $d7
	db $ff, $48, $e8, $4b, $4e, $ab, $ae, $a5, $b7, $fe, $ff, $9e, $b3, $1f, $b9, $ff
	db $e9, $bf, $d9, $04, $20, $06, $7f, $c0, $7f, $c0, $bf, $e0, $fb, $0e, $f7, $1c
	db $f7, $1c, $ef, $34, $ef, $33, $ee, $31, $ef, $37, $df, $65, $f2, $fe, $ec, $de
	db $ec, $db, $ee, $d9, $6f, $d4, $6e, $d2, $3e, $db, $a6, $ff, $32, $23, $1b, $14
	db $6d, $ec, $8b, $cf, $c5, $bf, $7c, $cf, $72, $f3, $df, $5e, $98, $88, $b0, $50
	db $6c, $6f, $a2, $e7, $47, $fa, $7c, $e6, $9c, $9f, $f6, $f5, $9f, $fe, $6d, $f6
	db $6d, $b6, $ed, $36, $ec, $57, $ec, $97, $f9, $b7, $cb, $ff, $bf, $e0, $df, $70
	db $df, $30, $ef, $18, $ef, $18, $ef, $d8, $ef, $38, $f7, $2c, $df, $64, $df, $62
	db $df, $64, $df, $69, $df, $69, $df, $68, $ef, $38, $ef, $38, $fe, $77, $fb, $2f
	db $dc, $f3, $1f, $e7, $ff, $52, $fd, $bf, $ff, $65, $fe, $06, $d1, $7f, $cf, $ef
	db $50, $ff, $cf, $6f, $d8, $ef, $ce, $f7, $3f, $21, $0b, $70, $16, $fd, $e7, $ef
	db $14, $ff, $e7, $ed, $37, $ee, $e7, $df, $f9, $09, $a0, $1c, $ff, $dc, $bf, $e8
	db $77, $9e, $f1, $cf, $ff, $95, $7f, $fa, $ff, $4c, $ff, $80, $f7, $4c, $f7, $8c
	db $f7, $4c, $f7, $2c, $04, $76, $10, $04, $2c, $10, $04, $2c, $10, $ff, $30, $04
	db $84, $13, $10, $ff, $10, $f8, $09, $f0, $13, $f3, $1c, $f7, $18, $ff, $08, $fe
	db $05, $ff, $03, $fe, $03, $3c, $c0, $ff, $00, $ff, $1f, $ff, $60, $04, $b6, $02
	db $ff, $40, $78, $07, $fe, $01, $ff, $f8, $ff, $0c, $f9, $0f, $fb, $0e, $fb, $0f
	db $f8, $08, $7f, $40, $3f, $a0, $bf, $60, $ff, $20, $ff, $04, $a1, $10, $00, $ff
	db $e0, $04, $80, $11, $18, $04, $d4, $13, $10, $04, $dc, $13, $04, $ff, $f7, $fd
	db $06, $f8, $78, $af, $f0, $df, $ef, $ff, $b0, $04, $c8, $13, $80, $7f, $60, $9f
	db $70, $ff, $e8, $ff, $18, $04, $00, $02, $f7, $18, $ff, $2f, $ff, $30, $04, $00
	db $06, $5f, $f0, $bf, $70, $ff, $d0, $04, $14, $27, $04, $df, $1b

;@ path: gfx/monsters/pictures
;@ Picture of 1EyeClown (species $8A): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $131 packed).
MonPic_X1EyeClown::
	db $40, $02, $08
	db $ff, $08, $ff, $ff, $1b, $03, $08, $28, $04, $fd, $0f, $f3, $36, $c7, $dc, $0f
	db $78, $08, $00, $03, $80, $08, $00, $0f, $1c, $08, $ff, $f5, $fc, $04, $fc, $05
	db $f8, $09, $f8, $0b, $f7, $17, $f8, $18, $f0, $30, $ef, $2f, $5f, $f0, $3f, $e0
	db $08, $92, $00, $df, $f0, $3f, $30, $1f, $18, $ef, $e8, $ff, $00, $ff, $01, $ff
	db $02, $ff, $02, $ff, $07, $ff, $05, $ff, $0a, $ff, $0a, $08, $44, $01, $40, $ff
	db $40, $08, $46, $0f, $08, $03, $fc, $1c, $e0, $20, $df, $5f, $ea, $7f, $f3, $3f
	db $e1, $3f, $f0, $37, $ff, $ff, $00, $00, $c7, $c7, $b9, $fe, $53, $7d, $51, $fe
	db $a7, $e8, $1f, $f8, $08, $e2, $00, $c6, $c6, $3b, $ff, $94, $7d, $15, $ff, $ca
	db $2e, $ff, $14, $ff, $94, $7f, $68, $3f, $28, $f7, $d4, $ff, $fc, $9f, $f0, $9f
	db $f0, $08, $00, $0f, $0d, $fe, $1f, $f4, $17, $f8, $09, $fe, $06, $ff, $19, $ff
	db $15, $ff, $13, $f6, $1a, $5b, $f7, $2f, $f8, $27, $f7, $12, $bb, $8f, $bf, $85
	db $ba, $42, $5c, $a1, $ee, $b5, $dd, $e9, $2b, $c8, $df, $90, $bb, $e3, $ff, $43
	db $bf, $84, $7f, $0b, $ff, $ff, $70, $df, $d0, $3f, $e0, $ff, $c0, $ff, $30, $ff
	db $50, $ff, $90, $df, $b0, $08, $00, $0f, $0e, $09, $fa, $0d, $ff, $05, $ff, $03
	db $ff, $01, $ff, $01, $08, $00, $00, $50, $77, $a3, $bf, $58, $7f, $27, $3f, $18
	db $1f, $07, $07, $80, $80, $c1, $41, $15, $ff, $8a, $ff, $35, $fd, $c9, $f9, $31
	db $f1, $c1, $c1, $03, $02, $07, $04, $ff, $20, $bf, $60, $08, $b6, $0f, $0a, $08
	db $ff, $ff, $0c, $c3, $42, $e3, $22, $f7, $14, $ff, $0c, $ff, $04, $08, $00, $02
	db $87, $84, $8f, $88, $df, $50, $ff, $08, $c3, $10, $08, $ff, $ff, $12

;@ path: gfx/monsters/pictures
;@ Picture of Gremlin (species $8B): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $D5 packed).
MonPic_Gremlin::
	db $40, $02
	db $02, $ff, $02, $ff, $ff, $4d, $02, $1d, $0f, $09, $3c, $ff, $1f, $02, $1c, $03
	db $c0, $bf, $f3, $cd, $7e, $d3, $7c, $e7, $38, $02, $1c, $03, $06, $fb, $9e, $e7
	db $7c, $f7, $1c, $ff, $09, $02, $1c, $09, $78, $ff, $f0, $02, $1c, $0f, $0e, $0f
	db $ff, $1f, $ff, $15, $ff, $09, $ff, $10, $ff, $1f, $fd, $06, $fe, $03, $e7, $b8
	db $ef, $fc, $2b, $fe, $93, $fb, $d7, $fd, $73, $bf, $f0, $9a, $ea, $3b, $ff, $0b
	db $ff, $6f, $b9, $ef, $93, $bf, $d7, $7e, $9b, $fd, $17, $ba, $ae, $b9, $ff, $e0
	db $ff, $f0, $ff, $50, $ff, $20, $ff, $10, $ff, $f0, $7f, $c0, $ff, $80, $02, $1c
	db $0f, $0e, $01, $02, $2e, $10, $fe, $07, $ff, $0b, $fb, $0d, $fd, $06, $fd, $06
	db $c5, $fd, $a5, $fd, $9c, $bc, $5b, $cf, $ff, $2f, $b8, $4f, $df, $67, $f4, $bf
	db $47, $7f, $4f, $7a, $7b, $73, $b7, $e4, $ff, $e9, $3b, $e5, $f5, $ce, $5e, $fb
	db $02, $80, $04, $ff, $a0, $bf, $60, $7f, $c0, $7f, $c0, $02, $1c, $0f, $0e, $03
	db $02, $28, $17, $02, $9b, $10, $0f, $fc, $07, $fb, $1f, $e1, $6b, $9f, $de, $ff
	db $e0, $02, $0e, $11, $e1, $7f, $c0, $ff, $02, $0d, $18, $02, $0f, $1f, $0f, $02
	db $df, $1f, $4a

;@ path: gfx/monsters/pictures
;@ Picture of MedusaEye (species $8C): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $106 packed).
MonPic_MedusaEye::
	db $40, $02, $04, $ff, $04, $ff, $ff, $4d, $04, $17, $0f, $03, $0c
	db $ff, $1a, $f3, $1f, $fc, $0f, $fe, $02, $ff, $06, $ff, $0b, $f9, $0f, $f7, $1e
	db $ef, $39, $ee, $2b, $fe, $bf, $e2, $fb, $04, $16, $01, $06, $f9, $cf, $39, $ef
	db $1b, $fe, $db, $fe, $d7, $f7, $04, $16, $01, $30, $df, $68, $9f, $f0, $bf, $f8
	db $bf, $e0, $bf, $ec, $04, $16, $0f, $0e, $01, $ff, $0d, $fa, $17, $f9, $0f, $ff
	db $1f, $e7, $7f, $8a, $fd, $98, $f9, $9e, $ff, $71, $f9, $a7, $b7, $ae, $ff, $a8
	db $bf, $6a, $7c, $c8, $f8, $17, $f7, $58, $ff, $57, $f7, $7f, $f9, $46, $de, $92
	db $9f, $ab, $af, $c9, $cf, $64, $a7, $b7, $ba, $77, $fc, $8f, $fe, $7f, $70, $ff
	db $86, $fb, $fd, $1b, $fe, $5f, $37, $04, $16, $0f, $0d, $f8, $61, $ff, $07, $ff
	db $61, $de, $bf, $c1, $7f, $ff, $fe, $ff, $01, $fe, $03, $e6, $e5, $c3, $42, $a5
	db $a5, $49, $c9, $ce, $ce, $e1, $2f, $fd, $ff, $81, $7f, $b3, $d3, $64, $a5, $c4
	db $c4, $2b, $2b, $e4, $ef, $11, $77, $ce, $fe, $58, $7b, $1f, $10, $ff, $f0, $cf
	db $dc, $23, $ee, $73, $fe, $0f, $fc, $df, $a8, $8f, $88, $04, $16, $0f, $0d, $fe
	db $02, $fe, $04, $cf, $00, $04, $17, $05, $3e, $7e, $3d, $67, $fb, $ce, $f7, $1c
	db $f7, $3c, $cf, $78, $ff, $68, $ff, $50, $47, $ff, $d5, $cd, $c4, $45, $e6, $27
	db $fe, $03, $04, $94, $12, $8f, $f8, $ff, $70, $ff, $80, $7f, $c0, $7f, $c0, $ff
	db $80, $04, $16, $0f, $4d, $04, $e0, $1f, $01

;@ path: gfx/monsters/pictures
;@ Picture of Lionex (species $8D): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $203 packed).
MonPic_Lionex::
	db $40, $02, $08, $ff, $00, $ff, $03
	db $fc, $07, $fc, $05, $fa, $0a, $fb, $0b, $fb, $0b, $fa, $0a, $ff, $04, $ff, $06
	db $ff, $83, $fe, $83, $7f, $c1, $7f, $c0, $3f, $60, $9f, $b8, $ff, $08, $ff, $f0
	db $00, $ff, $c0, $7f, $bc, $93, $fb, $e0, $7e, $e0, $af, $08, $20, $01, $01, $fe
	db $07, $fd, $7b, $93, $be, $0f, $7c, $0f, $ea, $ff, $40, $ff, $c1, $fe, $83, $fe
	db $83, $fc, $06, $fd, $07, $f9, $0d, $f2, $3b, $ff, $00, $ff, $80, $7f, $c0, $7f
	db $40, $bf, $e0, $08, $58, $02, $fe, $1e, $fa, $1a, $f5, $15, $f6, $16, $ea, $2e
	db $eb, $2f, $eb, $2f, $ea, $2e, $c7, $de, $a1, $a7, $be, $be, $70, $f0, $20, $60
	db $44, $5c, $84, $9c, $89, $99, $f0, $df, $f3, $f7, $5b, $5e, $56, $76, $b7, $b5
	db $5b, $5b, $f4, $f5, $0e, $0e, $1f, $f6, $9f, $ff, $b5, $f7, $d5, $dd, $dd, $7d
	db $b5, $bd, $47, $6f, $c9, $ef, $c6, $f7, $0a, $cf, $fb, $ff, $1c, $fc, $09, $f8
	db $47, $f5, $43, $fb, $22, $3f, $ff, $f0, $bf, $b0, $5f, $70, $df, $f0, $af, $f8
	db $08, $b8, $02, $d5, $5d, $08, $c0, $02, $a5, $bd, $aa, $bb, $08, $ca, $00, $92
	db $96, $c3, $d7, $86, $96, $85, $97, $85, $87, $88, $8f, $48, $cf, $44, $c7, $02
	db $03, $03, $03, $fd, $fd, $92, $92, $0c, $0c, $f0, $f0, $50, $d0, $78, $f8, $91
	db $9f, $61, $7f, $81, $bf, $01, $7d, $01, $fd, $02, $fb, $04, $77, $0c, $0f, $93
	db $9f, $87, $9f, $c3, $cf, $43, $cf, $43, $c7, $22, $ef, $24, $ef, $44, $cf, $57
	db $fc, $08, $10, $12, $4b, $fe, $ab, $08, $19, $11, $aa, $bb, $a6, $bf, $e6, $7f
	db $e6, $7f, $e2, $7f, $f2, $3f, $f3, $3f, $f1, $1f, $84, $8f, $82, $8b, $d7, $df
	db $bb, $be, $87, $8c, $47, $cc, $47, $cc, $bf, $fc, $2f, $ef, $6a, $ea, $e3, $a3
	db $f4, $35, $e8, $28, $d8, $58, $c4, $44, $83, $83, $f8, $ff, $ac, $bf, $8f, $bb
	db $5f, $f8, $2f, $68, $37, $7f, $44, $7f, $82, $be, $42, $d7, $82, $9f, $d6, $df
	db $ba, $bf, $c2, $4f, $c4, $4f, $c5, $cf, $7b, $ff, $ab, $fe, $cb, $fe, $cf, $fc
	db $cf, $fc, $8f, $fc, $9f, $f8, $9f, $f8, $1f, $f0, $f1, $1f, $fb, $0f, $fb, $0e
	db $ff, $06, $ff, $06, $ff, $02, $ff, $02, $ff, $01, $e7, $e4, $e3, $26, $e9, $2b
	db $eb, $2b, $fb, $1b, $fd, $0f, $ff, $06, $ff, $00, $82, $8a, $87, $af, $87, $a6
	db $cb, $4e, $f3, $36, $e7, $26, $fd, $1f, $fb, $0b, $a2, $be, $a1, $bf, $a1, $bf
	db $91, $97, $c3, $47, $e3, $63, $c3, $46, $e7, $6c, $4f, $5f, $8f, $bf, $2b, $7e
	db $ab, $fe, $b7, $f6, $77, $74, $f7, $d4, $f7, $15, $1f, $f0, $08, $58, $00, $ff
	db $c0, $ff, $c0, $ff, $80, $ff, $80, $08, $20, $03, $08, $df, $1f, $08, $fd, $0f
	db $f1, $13, $fa, $1f, $fd, $3d, $ff, $01, $fe, $03, $ff, $03, $ff, $00, $df, $5c
	db $c7, $cc, $ff, $fd, $87, $bc, $03, $7e, $95, $bf, $7f, $6a, $f5, $15, $f7, $74
	db $8f, $88, $ff, $f0, $08, $20, $03, $80, $7f, $08, $df, $1d

;@ path: gfx/monsters/pictures
;@ Picture of GoatHorn (species $8E): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1A5 packed).
MonPic_GoatHorn::
	db $40, $02, $04, $ff
	db $04, $ff, $ff, $4d, $04, $09, $04, $03, $fc, $07, $f8, $0c, $f0, $19, $04, $08
	db $01, $30, $df, $f0, $1f, $f0, $0f, $7f, $1b, $bc, $3c, $27, $04, $08, $07, $c0
	db $3f, $70, $cf, $b8, $04, $08, $07, $07, $f9, $1c, $e6, $3b, $04, $08, $01, $18
	db $f7, $1e, $f1, $1f, $e0, $fd, $b0, $7a, $78, $c9, $04, $08, $05, $80, $7f, $c0
	db $3f, $60, $1f, $30, $e0, $31, $e0, $32, $c1, $63, $c1, $65, $e1, $e5, $f7, $9f
	db $ff, $09, $fe, $02, $4f, $5f, $b7, $fd, $43, $e6, $8f, $af, $10, $36, $f0, $ff
	db $80, $ff, $00, $fe, $77, $ae, $55, $ef, $88, $ff, $d0, $ff, $a4, $ef, $da, $ff
	db $a9, $bf, $96, $d7, $dd, $eb, $55, $ef, $23, $fe, $17, $ff, $4a, $fe, $b6, $ff
	db $2a, $fb, $d2, $d6, $e4, $f5, $da, $7e, $85, $cf, $e3, $eb, $11, $d9, $1f, $ff
	db $03, $ff, $00, $ff, $0f, $18, $0f, $98, $07, $8c, $07, $4c, $0f, $4e, $df, $f2
	db $ff, $20, $ff, $80, $fe, $03, $fc, $05, $04, $22, $12, $ff, $07, $f9, $0f, $ff
	db $0b, $0c, $ff, $c2, $f3, $2e, $ef, $3e, $f2, $ff, $e7, $3d, $e5, $b9, $79, $c8
	db $78, $57, $7d, $2a, $ab, $55, $f7, $4b, $ff, $8f, $fc, $83, $ff, $80, $ff, $c1
	db $ff, $d4, $7d, $a8, $ab, $54, $df, $a4, $fe, $e3, $7f, $83, $ff, $03, $ff, $06
	db $fe, $60, $ff, $86, $9f, $e8, $eb, $f8, $9b, $fe, $cf, $79, $4f, $3b, $3d, $27
	db $3d, $04, $b8, $00, $04, $72, $12, $ff, $c0, $3f, $e0, $ff, $a0, $fd, $0f, $fa
	db $0e, $ff, $0b, $ff, $0c, $04, $08, $04, $ac, $b4, $38, $38, $f8, $d8, $e4, $24
	db $c4, $44, $c2, $42, $c0, $40, $e0, $20, $66, $7e, $58, $5b, $20, $36, $10, $1c
	db $0c, $0e, $03, $03, $00, $00, $80, $80, $cc, $fc, $34, $b4, $08, $d8, $10, $70
	db $60, $e0, $80, $80, $00, $00, $02, $02, $6b, $5b, $38, $38, $3f, $37, $4f, $48
	db $47, $47, $84, $84, $07, $07, $0f, $08, $7f, $e0, $bf, $e0, $ff, $a0, $ff, $60
	db $ff, $80, $7f, $40, $bf, $a0, $ff, $70, $04, $08, $03, $01, $04, $e6, $11, $00
	db $ff, $00, $f8, $18, $f1, $71, $83, $82, $43, $42, $bf, $bc, $ff, $f8, $04, $08
	db $00, $f0, $f0, $fc, $0c, $04, $0b, $11, $04, $09, $03, $1e, $1e, $7f, $61, $04
	db $db, $00, $04, $08, $04, $3f, $30, $1f, $1c, $83, $82, $85, $85, $fb, $7b, $ff
	db $3f, $04, $08, $00, $cf, $c8, $97, $94, $d3, $52, $cf, $4c, $ff, $38, $04, $08
	db $02

;@ path: gfx/monsters/pictures
;@ Picture of Orc (species $8F): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked by
;@ LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $168 packed).
MonPic_Orc::
	db $40, $02, $06, $ff, $06, $ff, $ff, $39, $01, $ff, $01, $06, $00, $01, $04
	db $ff, $18, $ff, $68, $ff, $90, $bf, $50, $7f, $a0, $06, $00, $0f, $12, $03, $fc
	db $0d, $f5, $3f, $e8, $7d, $a0, $f8, $81, $b3, $06, $00, $01, $80, $ff, $e0, $3f
	db $b8, $5f, $50, $ef, $ac, $67, $a5, $ff, $03, $ff, $05, $ff, $0a, $ff, $1c, $ff
	db $28, $ff, $50, $ff, $a0, $ff, $40, $ff, $c0, $06, $32, $0f, $0c, $01, $ff, $0f
	db $f2, $3f, $d1, $fd, $aa, $ef, $ed, $c5, $af, $c2, $ae, $d8, $02, $ef, $01, $b9
	db $00, $60, $3c, $7c, $f6, $da, $a8, $70, $f8, $84, $fd, $7b, $c3, $42, $8f, $8d
	db $0e, $0b, $1c, $17, $3c, $2f, $78, $5f, $f5, $bf, $ea, $6e, $ff, $80, $7f, $f0
	db $0f, $f8, $07, $fc, $77, $fc, $9f, $9c, $0f, $c8, $0f, $e8, $06, $3c, $0e, $fe
	db $02, $06, $22, $14, $06, $4e, $00, $7d, $6b, $3e, $ff, $0f, $7f, $1c, $ff, $22
	db $7f, $01, $7f, $01, $3f, $80, $98, $bf, $ce, $f1, $13, $e0, $e7, $20, $27, $e0
	db $e7, $10, $70, $1e, $fe, $31, $f1, $ca, $cf, $0c, $0d, $fc, $fd, $8e, $fe, $81
	db $ff, $00, $3f, $00, $14, $00, $00, $07, $c4, $07, $e4, $07, $c4, $07, $84, $0f
	db $88, $0f, $88, $1f, $10, $3f, $20, $06, $32, $0f, $09, $fe, $02, $ff, $03, $e3
	db $63, $ff, $3f, $ce, $7b, $9c, $f4, $bb, $ef, $70, $5f, $ff, $bf, $c0, $70, $3f
	db $2e, $ff, $f5, $0f, $ce, $0f, $fa, $87, $be, $61, $ff, $00, $ff, $e0, $ff, $e0
	db $e0, $9f, $9f, $98, $98, $e1, $e1, $80, $87, $00, $ff, $07, $ff, $78, $f8, $df
	db $d0, $0f, $08, $37, $3c, $c7, $fc, $1f, $f8, $e7, $e4, $07, $74, $07, $f4, $06
	db $00, $0d, $02, $ff, $05, $ff, $0b, $ff, $14, $ef, $38, $ff, $30, $06, $00, $00
	db $81, $e1, $07, $77, $ff, $06, $f4, $10, $7f, $ff, $ff, $06, $00, $01, $9f, $06
	db $92, $01, $c0, $ff, $c0, $ff, $80, $06, $00, $00, $f0, $91, $fe, $0e, $ff, $0f
	db $ff, $1f, $ff, $1f, $ff, $0f, $06, $00, $00, $0f, $ec, $1f, $d8, $ff, $f0, $ff
	db $f8, $ff, $fc, $ff, $f8, $06, $00, $0f, $01

;@ path: gfx/monsters/pictures
;@ Picture of Ogre (species $90): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked by
;@ LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1CA packed).
MonPic_Ogre::
	db $40, $02, $08, $ff, $08, $ff, $ff
	db $09, $01, $08, $1c, $03, $1e, $ff, $60, $ff, $80, $ff, $80, $ff, $11, $ff, $2a
	db $ff, $80, $ff, $40, $ff, $20, $ff, $30, $ff, $50, $ff, $10, $ff, $20, $ff, $bc
	db $08, $12, $09, $07, $ff, $0a, $08, $00, $07, $c0, $bf, $e0, $df, $70, $08, $16
	db $0b, $01, $ff, $06, $fd, $7f, $ff, $87, $fc, $04, $fe, $02, $ff, $07, $7f, $80
	db $bf, $c0, $ff, $a4, $ff, $51, $ff, $6a, $df, $ff, $ee, $ca, $ff, $b5, $ff, $8e
	db $ff, $71, $ff, $af, $f7, $5c, $ff, $dc, $67, $e4, $ef, $68, $ef, $a9, $ef, $29
	db $df, $d1, $ff, $7b, $ff, $9e, $f7, $1f, $e7, $3c, $e7, $bf, $75, $9f, $19, $ff
	db $9f, $f2, $ff, $d0, $ff, $68, $ff, $e8, $ff, $e8, $7f, $d4, $7f, $d4, $ff, $94
	db $ff, $94, $fe, $02, $fe, $02, $fd, $05, $fd, $05, $f9, $09, $f3, $12, $e7, $24
	db $c7, $44, $df, $e7, $c8, $ff, $28, $ff, $31, $ff, $13, $fe, $8b, $7e, $c7, $3e
	db $c7, $3e, $ff, $c0, $7f, $c4, $7b, $ea, $f9, $99, $ff, $07, $fc, $17, $ef, $3f
	db $e7, $3e, $dd, $53, $fa, $67, $e7, $7f, $ff, $78, $ff, $e3, $fc, $0f, $f8, $ff
	db $ef, $ff, $7f, $e5, $ff, $cd, $f7, $1f, $ea, $7b, $87, $ff, $04, $fd, $04, $fc
	db $fb, $fb, $7f, $68, $ff, $e8, $3f, $ec, $9b, $fe, $87, $fc, $27, $fc, $57, $f4
	db $2b, $2a, $cf, $48, $8f, $88, $8f, $8e, $9f, $91, $9f, $90, $df, $50, $df, $50
	db $ff, $30, $e5, $1f, $ef, $1b, $ff, $10, $ff, $a0, $ff, $40, $ff, $40, $08, $28
	db $00, $f7, $1c, $ff, $97, $fe, $f3, $fe, $33, $df, $39, $af, $59, $5f, $bf, $fd
	db $7f, $9f, $f0, $1f, $f0, $3f, $e0, $23, $fc, $4f, $f0, $47, $f8, $e0, $ff, $9f
	db $ff, $fe, $6e, $ff, $31, $ff, $28, $ff, $2c, $ff, $0a, $ff, $12, $1d, $f7, $e4
	db $ff, $9f, $9e, $ff, $f0, $df, $50, $ff, $20, $08, $00, $03, $80, $ff, $10, $08
	db $1c, $00, $fe, $03, $08, $86, $14, $ff, $84, $fe, $59, $bd, $63, $9f, $fe, $4f
	db $f2, $3f, $fc, $1f, $f8, $3f, $e1, $54, $dd, $e4, $fd, $c2, $7e, $c1, $7f, $80
	db $ff, $e3, $ff, $94, $ff, $04, $cf, $47, $fc, $43, $ff, $41, $ff, $87, $ff, $09
	db $ff, $90, $ff, $50, $fc, $49, $79, $c8, $7f, $f0, $ff, $7f, $cf, $08, $28, $00
	db $7f, $c0, $08, $28, $01, $08, $c9, $10, $c0, $08, $00, $06, $fe, $03, $ff, $03
	db $08, $00, $08, $fe, $c3, $08, $e2, $1a, $14, $94, $e7, $e7, $c0, $41, $e0, $20
	db $f0, $30, $ec, $2c, $ef, $2f, $ff, $30, $47, $7f, $81, $fd, $01, $f1, $62, $62
	db $97, $b7, $9f, $b8, $df, $d0, $ff, $20, $08, $c6, $12, $7f, $40, $08, $d4, $18
	db $08, $00, $08

;@ path: gfx/monsters/pictures
;@ Picture of GateGuard (species $91): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1DC packed).
MonPic_GateGuard::
	db $40, $02, $04, $ff, $00, $ff, $c1, $ff, $b1, $ff, $48, $df, $6c
	db $ff, $36, $fd, $1d, $f8, $08, $ff, $00, $ff, $f0, $ef, $1c, $e7, $9a, $c5, $5b
	db $c5, $43, $85, $82, $81, $82, $ff, $04, $ff, $f0, $04, $21, $02, $60, $bf, $e0
	db $bf, $e0, $04, $20, $07, $01, $04, $3a, $01, $04, $21, $06, $80, $7f, $e0, $1f
	db $f8, $04, $20, $07, $04, $21, $01, $f4, $1c, $f2, $1a, $e3, $31, $e3, $34, $e3
	db $34, $c1, $66, $c8, $67, $cd, $63, $0d, $0e, $3f, $36, $19, $1f, $98, $9f, $fb
	db $6f, $f7, $be, $ff, $b9, $cb, $7e, $04, $2c, $00, $bf, $f0, $3f, $ec, $3b, $ee
	db $bf, $e6, $fd, $57, $fd, $d7, $04, $3a, $03, $01, $fe, $03, $fe, $03, $fe, $23
	db $fd, $27, $07, $fc, $03, $fe, $01, $ff, $10, $ff, $20, $ff, $60, $ff, $60, $ff
	db $a0, $ff, $04, $44, $05, $c0, $3f, $e0, $3f, $e0, $1f, $f0, $c5, $6b, $c7, $6a
	db $8b, $c6, $9b, $c6, $9f, $c5, $04, $c8, $02, $c5, $7f, $86, $ff, $85, $ff, $8d
	db $fb, $0f, $f9, $1f, $f0, $1f, $f0, $17, $f9, $7d, $d7, $7c, $cd, $be, $eb, $de
	db $77, $ef, $3d, $f7, $ff, $fa, $9f, $fd, $07, $fe, $66, $de, $ff, $de, $f3, $dd
	db $f7, $5e, $82, $7f, $b3, $cd, $fd, $4f, $ed, $40, $ff, $40, $7f, $80, $ff, $80
	db $ff, $e3, $ff, $97, $fc, $7f, $98, $7f, $88, $1f, $f0, $0f, $f8, $0f, $f8, $07
	db $fc, $87, $fc, $e7, $7c, $f3, $1e, $fb, $0e, $04, $c8, $02, $df, $45, $df, $45
	db $df, $44, $cf, $42, $ef, $22, $10, $ff, $0f, $ff, $07, $ff, $0f, $f8, $1f, $f0
	db $bf, $e0, $bf, $e1, $ff, $62, $1e, $e3, $ef, $f3, $dc, $f7, $fc, $37, $fc, $15
	db $fe, $ea, $ff, $19, $fe, $05, $8f, $e7, $7d, $fd, $a2, $ef, $5e, $ff, $28, $ff
	db $14, $1c, $eb, $ff, $85, $ef, $7f, $c8, $5f, $64, $2f, $b2, $7f, $d9, $7f, $49
	db $fd, $93, $fb, $16, $f7, $2c, $ff, $06, $ff, $02, $ff, $02, $04, $20, $06, $ef
	db $22, $ef, $22, $f7, $12, $f7, $12, $ff, $0a, $ff, $0a, $ff, $05, $ff, $05, $ff
	db $42, $ff, $43, $fe, $0f, $ff, $33, $ff, $1c, $f0, $1f, $ec, $3f, $fb, $3f, $ff
	db $12, $cf, $f9, $ef, $b8, $7b, $dc, $bc, $9f, $1f, $73, $1e, $f3, $1e, $f3, $8e
	db $db, $9f, $d5, $ff, $65, $ff, $0a, $7f, $81, $9f, $e0, $67, $f8, $7b, $dc, $ef
	db $d8, $ff, $30, $5f, $b0, $9f, $f3, $ed, $7e, $f7, $ff, $bb, $de, $fd, $67, $04
	db $20, $03, $e0, $ff, $fa, $ff, $0e, $ff, $1e, $ff, $ca, $ff, $03, $04, $3e, $09
	db $00, $f7, $5c, $ff, $18, $ff, $90, $04, $20, $07, $e1, $04, $50, $0a, $2d, $fe
	db $c0, $ff, $ff, $4f, $fb, $a6, $fb, $ef, $ed, $3f, $ff, $1a, $ff, $00, $fe, $43
	db $ff, $83, $ff, $02, $04, $3e, $07, $a6, $ff, $42, $ff, $80, $04, $20, $06

;@ path: gfx/monsters/pictures
;@ Picture of ChopClown (species $92): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1D0 packed).
MonPic_ChopClown::
	db $40
	db $02, $15, $ff, $15, $ff, $fa, $61, $15, $00, $01, $03, $fc, $0c, $f0, $10, $ef
	db $2f, $ff, $f0, $3f, $e0, $15, $00, $01, $c0, $3f, $30, $0f, $08, $87, $84, $c3
	db $43, $e4, $24, $15, $00, $01, $07, $f8, $18, $e0, $20, $c3, $43, $87, $84, $4f
	db $48, $15, $00, $01, $80, $7f, $60, $1f, $10, $ef, $e8, $ff, $1e, $f9, $0f, $15
	db $00, $0b, $0c, $ff, $51, $ff, $2c, $ff, $13, $ff, $0d, $ff, $02, $ff, $19, $ff
	db $14, $ff, $0a, $3f, $60, $ff, $c0, $ff, $81, $fe, $4f, $fe, $bf, $fc, $4f, $fc
	db $b7, $fe, $4b, $e0, $60, $90, $90, $13, $13, $12, $93, $23, $e3, $2c, $ec, $27
	db $e3, $11, $f5, $0f, $0c, $13, $12, $91, $91, $90, $93, $88, $8f, $68, $6f, $c8
	db $8f, $10, $5f, $f9, $0b, $ff, $06, $ff, $03, $ff, $e5, $ff, $fa, $7f, $e5, $7f
	db $da, $ff, $a4, $ff, $14, $ff, $68, $ff, $90, $ff, $60, $ff, $80, $ff, $30, $ff
	db $50, $ff, $a0, $ff, $05, $ff, $02, $ff, $01, $15, $00, $05, $01, $f7, $65, $f3
	db $f2, $f9, $79, $fc, $9c, $fe, $6c, $bf, $b1, $9f, $9b, $07, $07, $cf, $ff, $fb
	db $f8, $f8, $fc, $75, $76, $8a, $8a, $a7, $a7, $52, $52, $a7, $a7, $e7, $ff, $bf
	db $3e, $3f, $7f, $5c, $dc, $a2, $a2, $4b, $4b, $95, $95, $cb, $cb, $df, $4d, $9f
	db $9e, $3f, $3d, $7f, $72, $ff, $6c, $fb, $1a, $f3, $b2, $c1, $c1, $ff, $40, $ff
	db $80, $15, $00, $08, $fe, $02, $fe, $02, $fc, $04, $f8, $08, $f8, $08, $f0, $10
	db $f7, $17, $ff, $39, $04, $07, $0f, $08, $1f, $10, $1b, $16, $37, $3c, $78, $7f
	db $f8, $ff, $fc, $7f, $69, $e9, $1e, $fe, $db, $3f, $f9, $1f, $f6, $16, $70, $90
	db $d0, $38, $10, $ff, $2f, $2f, $f0, $ff, $33, $fc, $37, $f8, $df, $d1, $1f, $30
	db $1f, $f0, $16, $f9, $00, $00, $c0, $c0, $e0, $20, $e0, $20, $d0, $30, $dc, $bc
	db $9f, $f3, $df, $f0, $ff, $80, $ff, $80, $7f, $40, $3f, $20, $3f, $20, $1f, $10
	db $df, $d0, $ff, $38, $ff, $01, $15, $c4, $03, $02, $ff, $06, $fb, $0f, $fa, $0e
	db $fe, $fb, $37, $35, $87, $84, $87, $84, $cf, $4c, $e7, $64, $83, $82, $47, $46
	db $20, $ff, $e0, $ff, $e0, $3f, $e0, $3f, $e1, $3f, $e7, $3e, $ff, $38, $ff, $20
	db $09, $ff, $0b, $ff, $09, $ff, $0f, $fe, $0f, $f8, $cf, $f8, $ff, $38, $ff, $08
	db $ff, $e0, $ff, $f6, $fb, $fa, $f3, $72, $a7, $a4, $15, $94, $10, $c7, $44, $15
	db $00, $0b, $00, $f9, $0f, $ff, $07, $15, $00, $08, $1f, $18, $ff, $15, $1f, $02
	db $15, $f5, $1f, $14, $c7, $44, $eb, $6a, $c1, $41, $82, $82, $e0, $e0, $ff, $1f
	db $15, $00, $01, $40, $ff, $60, $df, $f0, $5f, $70, $9f, $f0, $15, $f2, $12

;@ path: gfx/monsters/pictures
;@ Picture of Grendal (species $93): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1E1 packed).
MonPic_Grendal::
	db $40
	db $02, $04, $ff, $04, $ff, $ff, $07, $01, $ff, $00, $ff, $03, $04, $16, $03, $02
	db $ff, $02, $ff, $cf, $b4, $f7, $88, $9c, $04, $00, $03, $81, $fe, $8f, $f7, $f7
	db $5a, $df, $22, $73, $04, $00, $03, $e0, $1f, $f0, $0f, $ff, $00, $df, $00, $11
	db $04, $00, $09, $c0, $3f, $f0, $04, $00, $09, $03, $fc, $1f, $fc, $07, $f8, $0f
	db $fb, $0f, $f0, $1e, $e5, $3f, $c9, $7d, $f9, $f9, $07, $ff, $40, $ce, $a6, $af
	db $a7, $bd, $c2, $f3, $83, $97, $b4, $bd, $4c, $7f, $93, $d7, $05, $e5, $cd, $ed
	db $ca, $7e, $86, $9e, $83, $d3, $5a, $7b, $65, $fd, $92, $d7, $00, $ff, $02, $cf
	db $b3, $b3, $fe, $ef, $be, $e3, $df, $f1, $3f, $f1, $ff, $d3, $1f, $f0, $7f, $f8
	db $ff, $88, $0f, $fc, $ff, $3c, $cf, $fc, $0b, $7a, $cb, $ea, $e3, $3f, $ed, $3d
	db $e9, $39, $eb, $3b, $d4, $77, $db, $7f, $d4, $7c, $c4, $7c, $79, $ff, $45, $c7
	db $04, $d2, $00, $25, $e7, $dd, $ff, $25, $3f, $29, $3f, $d4, $f6, $ad, $7d, $37
	db $ff, $78, $ef, $ff, $b7, $5f, $fd, $b6, $f6, $dc, $7c, $57, $df, $6f, $79, $db
	db $fc, $3d, $ee, $fa, $df, $f7, $79, $d6, $db, $76, $7b, $ee, $3a, $de, $7a, $be
	db $ea, $ff, $c5, $ff, $45, $7f, $c6, $ff, $ce, $f7, $dc, $4b, $4a, $53, $52, $b3
	db $b2, $f3, $7e, $f3, $7e, $53, $de, $4f, $cc, $ff, $b8, $da, $7e, $d5, $77, $d2
	db $73, $e9, $39, $e8, $38, $f4, $1c, $fb, $0f, $fc, $07, $55, $77, $a5, $e7, $45
	db $c7, $8a, $8f, $15, $1d, $6c, $7c, $9f, $f7, $78, $ff, $f6, $3e, $df, $3d, $df
	db $f7, $38, $ff, $c7, $f7, $3f, $3f, $82, $82, $42, $c2, $d6, $fb, $f5, $7f, $f5
	db $df, $38, $ff, $c7, $df, $fa, $fa, $85, $85, $9f, $9f, $ae, $fd, $de, $f9, $2f
	db $e9, $dd, $d3, $1d, $13, $3d, $23, $fa, $c7, $fa, $06, $ff, $80, $ff, $80, $04
	db $5a, $01, $e0, $1f, $f0, $1f, $f0, $4f, $f8, $04, $1e, $03, $04, $ff, $f5, $e1
	db $bf, $c6, $7f, $c0, $7e, $c1, $5d, $e3, $6f, $df, $7e, $ee, $30, $f1, $38, $22
	db $a2, $3e, $3e, $7e, $42, $fe, $82, $fe, $42, $7e, $42, $ff, $41, $ff, $c0, $8b
	db $8c, $89, $8e, $84, $87, $84, $87, $83, $83, $cd, $cd, $33, $32, $cf, $cc, $f3
	db $0f, $c4, $3c, $06, $fe, $0b, $fd, $19, $fa, $ff, $f7, $ff, $6c, $d9, $5f, $4f
	db $78, $1f, $10, $3f, $20, $ff, $e0, $ff, $40, $ff, $e0, $ff, $10, $ff, $f0, $ff
	db $01, $ff, $07, $f8, $0a, $fb, $0f, $ff, $16, $ff, $1f, $04, $00, $01, $ff, $9b
	db $ee, $7f, $45, $3f, $e3, $bf, $fc, $ff, $c0, $04, $00, $01, $60, $bf, $e0, $04
	db $fa, $13, $04, $ff, $f2, $30, $04, $00, $0a, $f2, $3e, $fc, $0c, $fe, $02, $04
	db $1a, $01, $04, $ff, $f1, $2f, $e8, $6f, $7c, $ff, $b4, $ff, $fc, $04, $00, $04
;@ path: gfx/monsters/pictures
;@ Picture of Akubar (species $94): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1FD packed).
MonPic_Akubar::
	db $40, $02, $12, $ff, $00, $ff, $18, $ef, $3f, $f4, $77, $da, $7e, $eb, $6f, $b3
	db $fa, $9f, $dc, $ff, $12, $ff, $f0, $00, $ff, $80, $ff, $98, $ff, $30, $df, $70
	db $8f, $f8, $12, $10, $03, $12, $13, $02, $80, $ff, $c0, $12, $20, $07, $02, $ff
	db $02, $ff, $06, $12, $10, $01, $01, $fe, $03, $fe, $32, $ff, $19, $f7, $1c, $e3
	db $3e, $ff, $00, $ff, $30, $ef, $f8, $5f, $dc, $b7, $fc, $af, $ec, $9b, $be, $f3
	db $76, $f7, $7c, $ef, $25, $ea, $27, $ea, $67, $dd, $5f, $c0, $4e, $c0, $4e, $f0
	db $37, $af, $f8, $27, $bf, $7c, $7c, $f1, $f1, $c0, $c0, $a8, $ec, $54, $f6, $72
	db $df, $bf, $a0, $de, $d6, $d9, $d9, $30, $b0, $96, $fe, $66, $6c, $83, $e3, $e1
	db $f5, $fb, $0a, $f7, $d7, $36, $36, $19, $1b, $d2, $fe, $cc, $6c, $82, $8e, $0e
	db $5f, $eb, $3e, $c9, $fb, $7c, $7d, $1e, $1f, $07, $07, $2a, $6e, $54, $de, $9c
	db $f7, $df, $7c, $ef, $48, $af, $c8, $af, $cc, $77, $f4, $07, $e4, $07, $e4, $1f
	db $d8, $fe, $1f, $e3, $33, $12, $c2, $00, $c7, $67, $c7, $67, $c6, $67, $c6, $67
	db $ea, $bf, $f1, $f7, $31, $b7, $12, $d4, $00, $28, $ab, $04, $05, $17, $17, $9d
	db $f7, $78, $90, $fb, $3c, $c7, $77, $c0, $ff, $20, $bc, $a0, $ff, $10, $7f, $72
	db $df, $3d, $13, $bf, $79, $c7, $dd, $07, $ff, $08, $7b, $0a, $ff, $11, $fd, $ae
	db $fb, $1f, $df, $19, $db, $12, $04, $10, $29, $ab, $40, $41, $d0, $d1, $ff, $f0
	db $8f, $98, $12, $12, $10, $c7, $cc, $12, $18, $12, $c6, $67, $8e, $cf, $9e, $d3
	db $be, $e3, $fe, $c3, $fe, $c3, $fe, $83, $fe, $83, $17, $17, $37, $37, $37, $37
	db $3f, $3f, $3f, $3f, $7c, $7c, $70, $70, $60, $61, $28, $ef, $27, $7f, $a0, $e0
	db $f4, $ff, $ab, $db, $f4, $cd, $7c, $f6, $3b, $3f, $29, $ef, $c9, $fd, $0b, $0f
	db $5f, $ff, $ab, $b7, $5e, $66, $7c, $de, $b8, $f9, $d0, $d1, $d8, $d9, $d8, $d9
	db $f8, $f9, $f8, $f9, $7c, $7d, $1c, $1d, $0c, $0d, $c7, $cc, $e3, $e6, $f3, $96
	db $fb, $8e, $ff, $86, $ff, $86, $ff, $82, $ff, $82, $fe, $83, $fe, $03, $fe, $03
	db $ff, $03, $12, $3a, $01, $00, $ff, $00, $40, $4f, $40, $5e, $81, $bf, $82, $be
	db $82, $be, $c3, $7f, $fd, $3d, $f8, $0a, $54, $57, $b0, $b7, $97, $90, $77, $70
	db $f3, $d4, $f7, $10, $fa, $09, $fd, $84, $54, $d5, $1a, $da, $d3, $13, $dc, $1c
	db $9e, $56, $df, $11, $bf, $21, $7e, $42, $04, $e5, $04, $f5, $02, $fb, $83, $fb
	db $83, $fa, $87, $fc, $7f, $78, $3f, $a0, $ff, $82, $12, $2a, $01, $12, $d3, $12
	db $12, $21, $06, $00, $ff, $01, $ff, $03, $ff, $01, $ff, $00, $f0, $13, $e1, $2f
	db $c3, $5e, $c7, $ec, $a7, $fc, $4f, $58, $ff, $f0, $ff, $00, $fe, $82, $12, $ec
	db $10, $12, $20, $06, $fe, $83, $12, $02, $2a, $1f, $90, $0f, $e8, $87, $f4, $c7
	db $6e, $cb, $7f, $e5, $35, $ff, $1f, $12, $dc, $19, $12, $db, $11

;@ path: gfx/monsters/pictures
;@ Picture of MadKnight (species $95): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1DB packed).
MonPic_MadKnight::
	db $40, $02, $01
	db $ff, $00, $ff, $07, $ff, $19, $e7, $3a, $e7, $5f, $ff, $4f, $ff, $9f, $9f, $fc
	db $ff, $00, $ff, $80, $ff, $c0, $ff, $00, $ff, $90, $ff, $a8, $ff, $f8, $ff, $f0
	db $ff, $01, $ff, $f0, $01, $21, $0f, $17, $03, $01, $20, $0c, $9f, $fe, $ff, $9f
	db $ff, $8f, $ff, $53, $ff, $61, $ff, $23, $fe, $03, $fe, $03, $ff, $f0, $ff, $f0
	db $ff, $e1, $ff, $e0, $ff, $e0, $ff, $c0, $ff, $80, $ff, $8f, $ff, $3e, $c9, $ff
	db $45, $7f, $a0, $bf, $c7, $4f, $fa, $3e, $f4, $3c, $e8, $28, $01, $10, $00, $7f
	db $c0, $3f, $e0, $3f, $e1, $be, $e6, $78, $68, $50, $50, $fc, $04, $fb, $0b, $fa
	db $0b, $fa, $0b, $f4, $f7, $14, $17, $34, $37, $74, $77, $ff, $80, $7f, $40, $ff
	db $01, $95, $00, $e0, $1f, $f0, $1f, $f0, $2f, $f8, $fd, $07, $01, $c0, $00, $fb
	db $0e, $ff, $0e, $fb, $0e, $ff, $1c, $e7, $3d, $f0, $10, $e0, $20, $e0, $20, $f0
	db $10, $f0, $10, $f9, $19, $e6, $3e, $e5, $fd, $c0, $c0, $7f, $7f, $5e, $7f, $40
	db $5f, $a0, $a3, $e1, $63, $de, $fe, $88, $fb, $e0, $a0, $61, $e1, $41, $c1, $53
	db $d3, $fb, $eb, $b5, $f5, $19, $ff, $00, $ff, $d4, $f7, $94, $d7, $b4, $b7, $f4
	db $f7, $4a, $6b, $7a, $fb, $4a, $eb, $fa, $fb, $5f, $f8, $57, $f4, $57, $f4, $53
	db $f2, $01, $16, $10, $2b, $fa, $2b, $fa, $ea, $7e, $fc, $7c, $dc, $7c, $dc, $dc
	db $b2, $f6, $df, $fd, $bf, $f0, $ff, $f0, $44, $7d, $44, $75, $66, $66, $3f, $3f
	db $1f, $18, $ff, $e0, $ff, $03, $fc, $3f, $08, $fb, $08, $eb, $1c, $dd, $3e, $3e
	db $ff, $ff, $ff, $7f, $dd, $de, $e6, $fc, $01, $21, $01, $fe, $07, $77, $fe, $ff
	db $f9, $fb, $62, $ee, $cd, $7d, $2a, $ab, $7d, $7d, $fd, $dd, $bd, $a5, $be, $ba
	db $2e, $3a, $cf, $f9, $87, $fd, $2b, $fa, $17, $fe, $0b, $fe, $07, $fe, $83, $fe
	db $83, $fe, $43, $7e, $47, $7e, $01, $20, $0c, $d8, $5f, $98, $9f, $9c, $9f, $8e
	db $8e, $87, $87, $d1, $51, $01, $d2, $00, $dd, $de, $e3, $e3, $70, $f0, $33, $33
	db $f0, $f0, $fb, $0b, $f8, $88, $7b, $4b, $73, $f3, $87, $87, $0f, $0f, $8f, $8f
	db $0f, $09, $8f, $88, $1f, $10, $9f, $90, $83, $fe, $07, $ff, $08, $78, $10, $30
	db $10, $10, $e0, $e0, $c4, $44, $c3, $43, $a7, $be, $df, $dc, $67, $64, $3f, $38
	db $3f, $20, $3f, $20, $7f, $60, $bf, $a0, $01, $20, $0c, $e0, $20, $d2, $52, $8f
	db $bd, $ff, $ff, $01, $20, $04, $7c, $44, $bf, $e3, $7f, $e0, $ff, $80, $01, $20
	db $04, $3f, $20, $01, $14, $01, $01, $21, $05, $c0, $40, $c0, $40, $c3, $43, $ec
	db $af, $f0, $b1, $f8, $78, $ff, $07, $01, $0e, $20, $3f, $20, $ff, $e0, $1f, $f0
	db $0f, $f8, $1f, $78, $ff, $e0, $ff, $00

;@ path: gfx/monsters/pictures
;@ Picture of Gigantes (species $96): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $209 packed).
MonPic_Gigantes::
	db $40, $02, $05, $ff, $05, $ff, $ff, $03
	db $01, $ff, $02, $ff, $c5, $ff, $aa, $bc, $d8, $ff, $40, $ff, $a0, $ff, $a0, $1f
	db $10, $ff, $e8, $1f, $f4, $5f, $ea, $07, $03, $05, $12, $03, $01, $ff, $01, $fe
	db $63, $ff, $bf, $b0, $7f, $ff, $3f, $ff, $c0, $c0, $3f, $9f, $60, $e0, $df, $3f
	db $f0, $8f, $ff, $00, $f7, $ff, $c0, $ff, $30, $1f, $ec, $e7, $1a, $0f, $f2, $ff
	db $0e, $f3, $f6, $03, $b6, $05, $00, $01, $03, $fc, $0e, $f0, $1e, $e0, $3f, $c0
	db $77, $c0, $55, $df, $77, $dc, $75, $fe, $f2, $7f, $ff, $7f, $c0, $7f, $c0, $3f
	db $61, $3f, $61, $ff, $fd, $07, $f5, $3f, $ff, $ff, $c0, $ff, $00, $ff, $80, $05
	db $00, $00, $7c, $df, $7f, $e3, $fe, $c3, $fe, $03, $fe, $03, $ff, $09, $ef, $19
	db $f7, $18, $00, $f7, $00, $f7, $80, $f7, $00, $77, $00, $6f, $00, $6f, $03, $af
	db $81, $af, $03, $b6, $05, $b0, $01, $76, $03, $76, $07, $74, $c7, $f4, $27, $ec
	db $c0, $5d, $e0, $3f, $e0, $3f, $f0, $3b, $f0, $3b, $f8, $2e, $f4, $2e, $fa, $17
	db $1f, $f1, $09, $ff, $07, $bf, $01, $bf, $00, $fd, $00, $f5, $00, $d7, $00, $de
	db $ff, $00, $0f, $f0, $f0, $ff, $8f, $ff, $60, $ff, $1e, $d9, $07, $fc, $03, $d6
	db $d7, $38, $97, $78, $33, $fd, $eb, $fd, $06, $ff, $02, $ff, $82, $7f, $c2, $3f
	db $81, $af, $80, $af, $c1, $6f, $c0, $6e, $e0, $2e, $e0, $36, $e0, $76, $f0, $95
	db $2f, $e8, $cf, $e8, $9f, $d0, $1f, $d0, $3f, $a0, $05, $78, $00, $ff, $c0, $fd
	db $13, $ff, $15, $fe, $09, $fc, $13, $fd, $13, $fe, $23, $fb, $37, $fc, $4f, $00
	db $fe, $07, $ef, $ff, $ff, $ff, $ff, $80, $bd, $00, $b5, $e0, $f7, $1a, $ff, $71
	db $f5, $fe, $8f, $ff, $af, $ff, $8f, $70, $ff, $00, $bd, $00, $ad, $00, $ef, $e7
	db $1f, $ff, $8a, $ff, $d2, $fe, $f3, $1e, $bb, $07, $bf, $07, $ed, $03, $6e, $d0
	db $35, $f0, $75, $4f, $ff, $40, $ff, $c0, $ff, $60, $ff, $5f, $ff, $c0, $ff, $05
	db $22, $00, $7f, $90, $3f, $d0, $05, $76, $10, $7f, $90, $7f, $90, $fb, $4c, $ff
	db $48, $ff, $b8, $ff, $98, $ef, $98, $ff, $7c, $df, $7f, $ff, $60, $f4, $0e, $fa
	db $06, $f9, $07, $fd, $0f, $ff, $02, $ff, $01, $ff, $e1, $ff, $1d, $00, $fb, $01
	db $db, $93, $df, $fe, $ff, $fc, $ef, $fe, $03, $ff, $03, $ff, $02, $17, $7e, $7f
	db $fe, $83, $ff, $1f, $e1, $7f, $81, $05, $b8, $10, $f3, $8e, $e0, $3f, $de, $7f
	db $c0, $7f, $e0, $3f, $ff, $1f, $f1, $15, $05, $ca, $10, $7f, $a0, $ff, $20, $ff
	db $20, $ff, $40, $05, $8a, $02, $ff, $00, $c0, $7f, $a4, $ff, $fc, $ff, $c3, $7f
	db $a8, $ff, $f0, $ff, $d4, $7f, $ff, $7b, $1f, $e3, $03, $fc, $05, $d7, $14, $18
	db $ff, $ff, $e7, $ff, $04, $fb, $8c, $fb, $4c, $79, $ce, $7e, $c7, $7f, $c1, $05
	db $8a, $00, $ef, $1c, $1f, $f8, $ff, $6e, $ff, $03, $ff, $09, $3f, $c6, $c7, $fd
	db $ff, $3f, $ff, $0e, $05, $00, $01, $80, $05, $65, $11, $05, $d9, $13, $05, $00
	db $08

;@ path: gfx/monsters/pictures
;@ Picture of Centasaur (species $97): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1A0 packed).
MonPic_Centasaur::
	db $40, $02, $08, $ff, $08, $ff, $f0, $01, $ff, $01, $08, $00, $01, $08, $ff
	db $f0, $70, $ff, $e9, $3e, $f7, $3c, $ec, $d1, $db, $c1, $65, $e3, $3b, $ff, $1d
	db $ff, $80, $7f, $e0, $3f, $70, $ff, $c0, $ff, $00, $ff, $c0, $3f, $60, $1f, $70
	db $08, $08, $05, $08, $31, $0f, $17, $0c, $fb, $0a, $fd, $05, $ff, $03, $fe, $02
	db $08, $04, $03, $01, $ff, $02, $ff, $0c, $f9, $8e, $f9, $8f, $fc, $cf, $7b, $df
	db $ff, $f0, $ff, $9c, $bf, $ca, $df, $21, $57, $b9, $7b, $fd, $87, $bf, $11, $7f
	db $08, $30, $07, $80, $7f, $40, $bf, $a0, $08, $30, $0f, $0d, $fe, $02, $ff, $03
	db $fd, $05, $f9, $19, $e2, $23, $c7, $57, $c5, $5f, $82, $93, $f9, $db, $74, $dd
	db $e4, $f4, $46, $ee, $c4, $d4, $e4, $b4, $e4, $6c, $a4, $fc, $0c, $6f, $3f, $bb
	db $57, $ef, $2e, $f1, $99, $ff, $7e, $7f, $44, $7f, $03, $7f, $df, $d0, $ef, $e8
	db $b7, $f4, $9b, $fb, $5e, $77, $ac, $bf, $fc, $f7, $9e, $f2, $08, $08, $05, $87
	db $7f, $c4, $7c, $45, $be, $a2, $08, $08, $05, $c0, $ff, $30, $0f, $f8, $7f, $04
	db $81, $8d, $80, $8a, $80, $84, $81, $81, $c1, $41, $c1, $41, $e1, $21, $f9, $19
	db $e2, $fe, $b2, $fe, $91, $fb, $1c, $df, $04, $47, $02, $02, $01, $01, $01, $01
	db $00, $3b, $00, $03, $38, $38, $87, $87, $70, $f1, $60, $e0, $5f, $ff, $a0, $bf
	db $8b, $ff, $0f, $cc, $37, $3c, $c7, $fe, $0f, $f9, $15, $f9, $e7, $f8, $07, $f0
	db $ff, $51, $fe, $2a, $fe, $16, $f9, $0b, $f8, $09, $fc, $84, $fe, $e2, $9d, $f5
	db $07, $1c, $03, $1e, $0f, $02, $07, $02, $97, $92, $7f, $ea, $3f, $66, $7f, $72
	db $fe, $06, $fe, $02, $08, $6a, $02, $08, $82, $10, $fe, $02, $89, $89, $10, $08
	db $92, $11, $70, $70, $38, $38, $1c, $74, $1f, $f3, $1f, $1f, $00, $01, $00, $03
	db $00, $03, $00, $07, $00, $07, $00, $01, $10, $13, $ef, $f0, $1e, $f1, $0e, $f9
	db $0c, $fb, $09, $ff, $09, $ef, $0b, $8f, $9f, $9e, $8f, $db, $8f, $98, $cf, $d8
	db $9f, $90, $1f, $10, $3f, $20, $ff, $e0, $ff, $a0, $ff, $d8, $ff, $64, $ef, $34
	db $ff, $1a, $ff, $06, $08, $08, $03, $03, $ff, $02, $08, $30, $08, $3f, $60, $ff
	db $e0, $ff, $80, $08, $30, $06, $f0, $f2, $f0, $11, $e0, $26, $c1, $47, $c1, $49
	db $e3, $fe, $ff, $3c, $ff, $28, $ff, $f0, $ff, $80, $08, $f4, $18, $08, $30, $0f
	db $0d

;@ path: gfx/monsters/pictures
;@ Picture of EvilArmor (species $98): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1C8 packed).
MonPic_EvilArmor::
	db $40, $02, $02, $ff, $02, $ff, $ff, $11, $20, $ff, $10, $ff, $18, $ff, $28
	db $ff, $29, $ef, $37, $02, $00, $01, $04, $ff, $08, $ff, $18, $ff, $14, $ff, $94
	db $6f, $74, $ff, $0e, $fd, $05, $fd, $04, $fc, $06, $fe, $03, $fe, $03, $fe, $13
	db $fe, $1b, $02, $00, $01, $80, $ff, $40, $7f, $20, $3f, $60, $1f, $70, $3f, $50
	db $ff, $00, $ff, $07, $fb, $0c, $fe, $09, $ff, $1f, $f8, $18, $f6, $16, $f3, $33
	db $ff, $01, $ff, $03, $ff, $c6, $7b, $aa, $fb, $1b, $cf, $8f, $4c, $4c, $4c, $7c
	db $e7, $3b, $f7, $1f, $ff, $4d, $ff, $de, $fb, $db, $75, $75, $aa, $aa, $33, $33
	db $57, $ec, $2f, $f8, $7f, $b2, $bf, $7b, $2f, $fa, $67, $ff, $ca, $ff, $b2, $ff
	db $f6, $9d, $f2, $d5, $f9, $6a, $d8, $78, $f8, $d8, $1c, $f4, $6c, $9d, $2d, $dc
	db $7f, $08, $02, $b0, $00, $ff, $08, $ff, $10, $7f, $90, $3f, $e0, $7f, $c0, $e5
	db $27, $f4, $35, $fe, $3e, $fd, $3b, $f6, $19, $ff, $16, $02, $ca, $00, $4f, $7f
	db $cf, $ff, $a5, $bd, $a5, $bd, $e7, $fe, $67, $fc, $e7, $7c, $e7, $7d, $3c, $3c
	db $bd, $bd, $fd, $fd, $f3, $73, $ef, $2f, $f9, $79, $fb, $7b, $ee, $2e, $6b, $f7
	db $a3, $ff, $c1, $ff, $33, $fe, $3f, $cc, $53, $aa, $03, $fe, $8f, $fc, $0d, $fc
	db $e9, $fc, $93, $f0, $b9, $dc, $da, $7c, $ee, $7c, $d6, $6f, $ca, $f7, $ff, $40
	db $ff, $80, $02, $54, $00, $02, $16, $10, $7f, $20, $7f, $20, $f7, $1a, $fe, $19
	db $fa, $1d, $fa, $0f, $ff, $0d, $ff, $0f, $fb, $0f, $ff, $06, $e7, $7d, $53, $df
	db $93, $9f, $93, $9f, $5f, $d3, $df, $53, $bf, $f3, $f7, $ba, $f0, $b1, $6c, $6d
	db $96, $96, $9f, $9f, $ff, $ff, $eb, $eb, $eb, $eb, $fc, $fc, $f5, $7d, $4f, $fe
	db $98, $ff, $51, $be, $93, $7c, $10, $f7, $54, $b7, $a3, $67, $f7, $bf, $f9, $8f
	db $7d, $c7, $7f, $cf, $7f, $cd, $7f, $cc, $ff, $8c, $ff, $0c, $02, $58, $00, $3f
	db $60, $7f, $c0, $7f, $c0, $ff, $c0, $02, $00, $00, $fd, $07, $fe, $03, $ff, $01
	db $02, $00, $06, $f7, $6c, $bf, $a4, $af, $b8, $df, $e8, $ff, $70, $02, $00, $02
	db $fc, $7c, $ee, $6e, $fb, $7b, $f7, $36, $ff, $1f, $ff, $1f, $fb, $1b, $fb, $0a
	db $23, $ee, $57, $dc, $bf, $ac, $cf, $74, $af, $bc, $9f, $f8, $9f, $c8, $8f, $d8
	db $ff, $0c, $02, $c0, $16, $f3, $00, $f3, $16, $02, $00, $0f, $12, $02, $ff, $f8
	db $0f, $ff, $0f, $f3, $1b, $f3, $36, $ff, $3c, $02, $00, $02, $9f, $d0, $9f, $d0
	db $ff, $f0, $9f, $f0, $8f, $d8, $cf, $64, $02, $08, $20, $f7, $1a, $f3, $1e, $f3
	db $12, $02, $c0, $11, $08, $02, $00, $0f, $01

;@ path: gfx/monsters/pictures
;@ Picture of Jamirus (species $99): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1DF packed).
MonPic_Jamirus::
	db $40, $02, $0b, $ff, $0b, $ff, $f6
	db $01, $fe, $03, $fc, $07, $0b, $00, $05, $78, $8f, $e8, $1f, $d0, $3f, $a1, $0b
	db $00, $05, $1e, $e1, $7f, $bd, $cf, $93, $77, $0b, $00, $01, $10, $ef, $29, $c7
	db $5d, $87, $bc, $03, $72, $01, $b1, $0b, $00, $03, $e0, $1f, $f8, $87, $fe, $c1
	db $7d, $e0, $38, $0b, $00, $07, $0b, $ff, $f0, $80, $f8, $0d, $f8, $0a, $f1, $15
	db $f2, $1a, $e2, $3a, $e5, $35, $c4, $74, $c4, $74, $7f, $42, $fe, $83, $fd, $87
	db $ff, $85, $7f, $f9, $3f, $e1, $ff, $c1, $9f, $e0, $f1, $7f, $a0, $bf, $05, $df
	db $06, $ff, $84, $ff, $04, $ff, $02, $7f, $80, $bf, $00, $f0, $00, $f0, $00, $f8
	db $00, $f8, $00, $fc, $09, $fd, $08, $28, $0c, $64, $f1, $bd, $f8, $9e, $f4, $9f
	db $62, $7b, $71, $77, $e8, $dd, $f4, $4e, $24, $3f, $ff, $c0, $3f, $20, $1f, $10
	db $0f, $88, $17, $d4, $8f, $cc, $8f, $ee, $4b, $6a, $c8, $68, $88, $e8, $88, $e8
	db $93, $d3, $94, $d7, $95, $d7, $93, $d3, $96, $d7, $bf, $f1, $4f, $5c, $43, $7a
	db $37, $34, $cf, $fc, $9b, $bc, $b9, $be, $14, $1f, $0a, $ef, $8c, $af, $c8, $4f
	db $e4, $26, $ea, $6a, $f9, $19, $67, $9f, $43, $bf, $65, $f5, $73, $da, $7d, $6e
	db $98, $f5, $7e, $51, $7f, $58, $f7, $f4, $07, $04, $b8, $bd, $60, $e6, $79, $fb
	db $a6, $7f, $b3, $7b, $fb, $3b, $f0, $3c, $ba, $7f, $47, $e4, $43, $72, $ab, $fa
	db $6b, $fa, $67, $76, $a7, $f6, $a7, $f6, $67, $f4, $dc, $ff, $dd, $f7, $df, $f3
	db $cf, $e8, $cf, $68, $cf, $68, $ef, $78, $ef, $78, $b2, $bb, $cb, $cb, $c7, $e6
	db $c3, $62, $e3, $32, $ff, $1d, $fe, $07, $f8, $0f, $04, $fe, $09, $fd, $f2, $fb
	db $c8, $5f, $c5, $6f, $82, $fa, $02, $fa, $00, $f8, $7f, $7c, $af, $ff, $7f, $f9
	db $bf, $b0, $5f, $50, $0f, $0c, $03, $02, $01, $01, $67, $ff, $87, $f7, $07, $24
	db $8f, $88, $ff, $70, $0b, $5a, $02, $67, $74, $e7, $b4, $e7, $34, $ef, $38, $0b
	db $76, $10, $df, $70, $df, $50, $ef, $38, $ff, $38, $f7, $1c, $ff, $0c, $ff, $04
	db $0b, $00, $02, $f0, $1f, $e0, $3f, $0b, $92, $10, $f1, $1f, $fc, $0c, $ff, $03
	db $fe, $03, $10, $fc, $10, $f0, $08, $c8, $3f, $3f, $ff, $c0, $7f, $40, $0b, $aa
	db $10, $40, $58, $40, $6c, $80, $bf, $e0, $ff, $f8, $1f, $fc, $0e, $f8, $0e, $f1
	db $1d, $7f, $40, $3f, $20, $0b, $c2, $12, $7f, $40, $ff, $80, $ff, $00, $ff, $60
	db $ff, $60, $ff, $c0, $0b, $cc, $11, $0b, $d9, $1f, $02, $fc, $07, $fc, $7e, $a8
	db $be, $e9, $e9, $ff, $7e, $0b, $58, $04, $0b, $00, $21, $0b, $ff, $f5, $e9, $0d
	db $f8, $0e, $f8, $0e, $fc, $07, $0b, $16, $20, $ff, $03, $0b, $fc, $15, $e0, $5f
	db $f8, $57, $54, $ff, $fc, $0b, $d8, $1e

;@ path: gfx/monsters/pictures
;@ Picture of Durran (species $9A): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1B0 packed).
MonPic_Durran::
	db $40, $02, $0a, $ff, $0a, $ff, $fc, $18
	db $ff, $0c, $fb, $0e, $fb, $0e, $f3, $1e, $f3, $1a, $f3, $1a, $fb, $12, $0a, $00
	db $01, $04, $ff, $07, $fe, $06, $ff, $03, $ff, $03, $ff, $01, $0a, $00, $03, $36
	db $f7, $f7, $55, $d7, $77, $77, $dd, $dd, $0a, $00, $01, $08, $ff, $38, $cf, $d8
	db $3f, $30, $ff, $f0, $ff, $e0, $0a, $00, $0d, $0a, $ff, $fb, $f7, $22, $e7, $34
	db $c7, $74, $c7, $63, $c1, $63, $c3, $66, $c7, $52, $f3, $79, $ff, $00, $ff, $01
	db $ff, $63, $df, $d8, $e7, $27, $fa, $1b, $ef, $0f, $f7, $37, $e3, $e3, $e3, $f7
	db $e3, $7f, $dd, $ff, $57, $b8, $21, $ee, $20, $20, $ff, $ff, $ff, $80, $ff, $c0
	db $ff, $60, $ff, $8f, $76, $f6, $56, $df, $b5, $bf, $f5, $ff, $0a, $00, $05, $80
	db $ff, $80, $7f, $70, $9f, $d0, $0a, $00, $09, $01, $fe, $03, $fb, $0d, $fb, $0f
	db $fd, $1d, $f9, $3b, $f7, $1f, $ec, $7f, $9a, $ff, $69, $ef, $d3, $77, $bb, $fb
	db $73, $eb, $a1, $b5, $73, $72, $d7, $c7, $ed, $ed, $f9, $f9, $8f, $d7, $79, $7f
	db $ae, $b7, $a1, $bb, $f1, $ff, $a3, $bb, $af, $af, $ff, $ff, $20, $6f, $c0, $fb
	db $64, $fe, $ff, $ff, $8b, $8e, $eb, $ee, $c5, $c7, $85, $87, $7f, $e0, $0a, $b8
	db $00, $0a, $00, $06, $fc, $07, $f9, $0f, $f9, $0f, $f3, $1f, $f3, $1e, $f7, $1c
	db $ff, $0c, $ff, $0c, $86, $87, $02, $02, $05, $05, $8f, $8e, $c2, $42, $c1, $41
	db $c3, $43, $ec, $2e, $c2, $c2, $e2, $e2, $c2, $42, $82, $82, $82, $82, $42, $42
	db $42, $42, $f1, $71, $fc, $ff, $78, $7f, $72, $75, $32, $35, $12, $55, $11, $52
	db $09, $8a, $08, $89, $45, $47, $c5, $47, $a2, $23, $a2, $63, $62, $a3, $62, $a3
	db $22, $e3, $42, $c3, $0a, $b4, $04, $0a, $74, $15, $04, $0a, $00, $0a, $fc, $1a
	db $f8, $0c, $f8, $0c, $f8, $0e, $fc, $0e, $fc, $0f, $fa, $0b, $fd, $05, $21, $61
	db $43, $c3, $c3, $43, $c3, $43, $43, $c3, $41, $41, $21, $61, $21, $a1, $1c, $5d
	db $3c, $7c, $7c, $7c, $7e, $7e, $7d, $7d, $fd, $fd, $f7, $f7, $fe, $fe, $42, $c3
	db $22, $63, $34, $b7, $55, $d7, $55, $57, $65, $67, $75, $77, $bb, $ae, $0a, $74
	db $13, $0a, $51, $0f, $06, $fe, $02, $0a, $2e, $05, $0a, $ff, $f1, $a7, $e7, $9f
	db $db, $de, $72, $df, $77, $f8, $38, $ff, $3f, $ff, $60, $ff, $00, $3e, $22, $9f
	db $d1, $7f, $f1, $ff, $e1, $0a, $14, $15, $ec, $bf, $b0, $9f, $b0, $ef, $e8, $cf
	db $d8, $ef, $68, $ff, $30, $0a, $50, $0e

;@ path: gfx/monsters/pictures
;@ Picture of Spooky (species $9B): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $DD packed).
MonPic_Spooky::
	db $40, $02, $04, $ff, $04, $ff, $ff, $4d
	db $04, $2b, $0f, $17, $01, $fe, $02, $ff, $07, $ff, $00, $ff, $07, $f8, $18, $e0
	db $60, $80, $80, $02, $02, $01, $01, $f1, $f1, $ff, $00, $ff, $c0, $3f, $20, $3f
	db $20, $7f, $40, $ff, $80, $04, $2a, $0f, $16, $03, $ff, $1f, $ff, $3f, $ff, $3f
	db $ff, $1f, $fe, $0d, $fc, $07, $f8, $0f, $ff, $04, $e4, $01, $fb, $fc, $e7, $f8
	db $cf, $f0, $0d, $fd, $03, $ff, $81, $ff, $f9, $ff, $ff, $ff, $bf, $7f, $ef, $1f
	db $f7, $0f, $04, $2a, $05, $80, $ff, $e0, $bf, $d0, $bf, $dc, $04, $2a, $0f, $0d
	db $fe, $05, $ff, $1d, $ee, $31, $ff, $3c, $fd, $06, $fb, $0f, $fb, $0c, $fd, $06
	db $cf, $f0, $9f, $f8, $d7, $fd, $ef, $30, $bf, $f0, $ff, $ef, $9e, $ff, $0a, $ff
	db $fb, $07, $f9, $c7, $7b, $c6, $fe, $33, $ff, $f1, $fa, $a5, $fd, $c6, $ff, $83
	db $ff, $d2, $fb, $c6, $ff, $0e, $5f, $e8, $bf, $f0, $3f, $e0, $3f, $e0, $ff, $c0
	db $04, $b4, $0f, $10, $04, $2b, $09, $c8, $ff, $c8, $7f, $ec, $37, $e7, $3b, $f3
	db $1c, $f9, $0e, $fe, $07, $ff, $01, $ff, $81, $ff, $80, $04, $aa, $03, $01, $7f
	db $86, $ff, $f8, $ff, $60, $bf, $d6, $7f, $8a, $e7, $3c, $ff, $78, $04, $aa, $0f
	db $18, $04, $df, $1f, $38

;@ path: gfx/monsters/pictures
;@ Picture of Skullgon (species $9C): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $206 packed).
MonPic_Skullgon::
	db $40, $02, $04, $ff, $01, $ff, $03, $fe, $03, $fd, $07
	db $fd, $07, $fb, $0f, $fb, $0f, $f6, $1f, $ff, $f0, $5f, $e8, $df, $e8, $7f, $e8
	db $7f, $e8, $6f, $f4, $7f, $d5, $f7, $9a, $ff, $06, $ff, $0a, $ff, $14, $ff, $29
	db $ef, $5a, $dd, $fc, $fb, $67, $fe, $81, $ff, $1c, $f7, $2c, $ef, $d8, $df, $30
	db $bf, $60, $3f, $e0, $7f, $c0, $ff, $80, $ff, $0f, $fa, $17, $fb, $17, $fe, $17
	db $fe, $17, $f7, $2f, $ff, $2d, $ef, $5d, $ff, $80, $ff, $c0, $7f, $c0, $bf, $e0
	db $bf, $e0, $ff, $70, $ff, $50, $ff, $dc, $f6, $1f, $ee, $3b, $04, $62, $00, $de
	db $73, $dd, $77, $df, $75, $df, $75, $ff, $8d, $ff, $8c, $ff, $8c, $fb, $8e, $ff
	db $fc, $04, $50, $01, $9f, $f7, $01, $fb, $31, $fd, $78, $ed, $f9, $f7, $7d, $ca
	db $3f, $73, $fe, $ff, $f7, $ff, $00, $ff, $00, $ff, $80, $ff, $41, $7f, $22, $ff
	db $a5, $7f, $ad, $f7, $7d, $ff, $57, $dd, $b6, $af, $fa, $ee, $fb, $af, $79, $ff
	db $f1, $7f, $d1, $7f, $cd, $ef, $ba, $ff, $ba, $ef, $76, $fb, $9e, $3b, $de, $fb
	db $ee, $7b, $ce, $fb, $4e, $df, $75, $dd, $77, $dd, $77, $fd, $67, $fd, $67, $fd
	db $47, $ff, $43, $ff, $43, $6a, $be, $dd, $f5, $fd, $25, $fb, $3b, $ee, $5f, $d9
	db $bf, $ff, $fe, $f6, $59, $7c, $6e, $fe, $e9, $77, $cf, $ed, $9f, $db, $bf, $bf
	db $7e, $59, $e7, $ff, $ff, $9f, $9a, $9f, $fa, $3f, $b5, $5f, $bb, $f7, $ff, $fe
	db $1e, $e7, $f8, $ff, $3f, $ca, $f7, $f2, $bf, $fe, $4f, $fe, $a3, $7f, $21, $bf
	db $61, $5f, $f1, $ff, $d1, $fb, $4e, $04, $10, $10, $7f, $c6, $ff, $c6, $7f, $c2
	db $ff, $82, $ff, $82, $ff, $01, $04, $20, $13, $04, $ff, $f0, $01, $ff, $07, $7f
	db $ff, $7e, $4a, $ef, $b5, $f7, $7f, $9b, $fd, $ff, $e7, $ff, $42, $ff, $a2, $7d
	db $7f, $1f, $e1, $7a, $f9, $35, $33, $97, $af, $fd, $ff, $ff, $c1, $fe, $87, $ef
	db $3f, $3f, $e0, $d7, $e7, $ab, $b3, $fb, $fc, $27, $7f, $7f, $a0, $ef, $fc, $bf
	db $d1, $df, $31, $ff, $a1, $3f, $60, $04, $3c, $01, $40, $ff, $20, $04, $90, $01
	db $04, $71, $17, $f8, $1d, $e7, $2f, $ff, $78, $ff, $c0, $04, $22, $14, $7f, $7b
	db $c7, $ef, $ff, $3f, $ff, $c0, $e3, $3f, $bf, $7d, $ff, $f0, $9f, $e8, $bb, $c7
	db $ed, $f3, $ff, $3c, $17, $fe, $f2, $ff, $88, $cf, $ff, $7f, $ff, $00, $fb, $1c
	db $f6, $f9, $ff, $07, $3a, $df, $19, $ff, $c3, $fe, $ff, $3c, $ff, $00, $bf, $60
	db $ff, $e0, $ff, $98, $3f, $c7, $cf, $f2, $f6, $3d, $fd, $3f, $c7, $fe, $04, $70
	db $15, $80, $ff, $80, $04, $70, $15, $03, $ff, $06, $ff, $0b, $ff, $1f, $ff, $05
	db $ff, $0f, $df, $68, $ef, $34, $e7, $fb, $5f, $fc, $f6, $ef, $df, $3f, $ff, $e1
	db $04, $26, $11, $04, $91, $02, $40, $ff, $c0, $ff, $40, $ff, $80, $ff, $01, $ff
	db $02, $ff, $03, $ff, $02, $04, $fe, $14, $9b, $ff, $fb, $62, $9f, $ef, $ef, $fa
	db $ff, $9f, $04, $da, $15, $80, $ff, $c0, $04, $70, $16

;@ path: gfx/monsters/pictures
;@ Picture of Putrepup (species $9D): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $BF packed).
MonPic_Putrepup::
	db $40, $02, $01, $ff, $01
	db $ff, $ff, $4d, $01, $5f, $0f, $4d, $01, $bf, $0f, $4d, $01, $d9, $0f, $05, $06
	db $fd, $07, $fe, $05, $ff, $04, $01, $d8, $00, $ef, $2e, $c1, $6b, $80, $ff, $00
	db $ff, $fc, $ff, $5e, $f3, $01, $d8, $03, $9e, $61, $01, $d8, $01, $0c, $ff, $01
	db $d8, $07, $80, $ff, $f0, $4f, $f8, $01, $d8, $0f, $0d, $fb, $0a, $fb, $0f, $f2
	db $17, $f4, $1f, $e4, $2e, $f2, $1f, $f6, $3e, $ff, $0f, $9f, $f1, $0f, $f8, $07
	db $ff, $44, $ef, $fa, $ba, $70, $11, $6e, $fc, $83, $f9, $1a, $fb, $8e, $fb, $8a
	db $ff, $4e, $fb, $4a, $ff, $85, $ff, $c6, $ff, $c7, $fd, $47, $fc, $47, $fc, $43
	db $df, $23, $fd, $27, $e6, $3f, $f8, $7f, $c0, $ff, $c0, $ff, $00, $7f, $01, $69
	db $10, $01, $d9, $0f, $07, $0a, $fb, $0a, $ff, $0a, $f7, $1a, $fd, $3c, $ff, $14
	db $01, $d8, $00, $c2, $75, $d7, $52, $d2, $65, $ff, $3f, $ff, $24, $ff, $18, $01
	db $d8, $00, $67, $7d, $7f, $e5, $fe, $a7, $f7, $5b, $ff, $6e, $01, $d8, $03, $40
	db $7f, $c0, $ff, $20, $6f, $60, $01, $d8, $0f, $05

;@ path: gfx/monsters/pictures
;@ Picture of RotRaven (species $9E): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $FC packed).
MonPic_RotRaven::
	db $40, $02, $06, $ff, $06, $ff
	db $ff, $4d, $06, $2b, $0f, $17, $01, $f3, $02, $fb, $1c, $06, $2a, $07, $c0, $e7
	db $20, $ef, $06, $8f, $08, $06, $2b, $0f, $08, $fd, $01, $06, $2a, $07, $38, $07
	db $34, $ff, $fa, $ff, $05, $fe, $3e, $df, $42, $ff, $bd, $ff, $25, $ef, $36, $ff
	db $1c, $fe, $14, $fb, $0a, $fd, $95, $fc, $94, $fe, $57, $fb, $d6, $ff, $32, $ff
	db $1c, $bf, $14, $ef, $28, $ff, $68, $9f, $f8, $0f, $f8, $06, $6a, $0f, $0f, $fe
	db $03, $fe, $02, $fd, $07, $fb, $0e, $f7, $1c, $ff, $18, $ff, $10, $ff, $45, $ff
	db $8a, $fb, $0a, $ff, $14, $ff, $14, $f7, $1c, $f7, $14, $ef, $38, $fe, $4a, $bf
	db $ab, $ff, $a4, $ff, $a3, $df, $90, $ff, $68, $ff, $17, $fd, $0d, $0f, $f8, $8f
	db $b8, $ff, $f0, $df, $70, $bf, $e0, $ff, $a0, $ff, $b0, $5f, $f0, $06, $2a, $0f
	db $1d, $ef, $38, $ff, $18, $ff, $08, $f7, $06, $2b, $05, $f8, $08, $f7, $07, $fb
	db $0f, $f7, $04, $fb, $0f, $ff, $04, $ff, $0f, $ff, $1b, $0f, $f8, $0f, $7c, $cf
	db $fc, $4b, $7e, $cb, $fe, $49, $6d, $99, $ff, $64, $f6, $06, $2a, $08, $f7, $10
	db $af, $06, $ff, $0f, $0f, $06, $2b, $0b, $ea, $2e, $c6, $46, $fe, $fa, $ff, $1d
	db $ff, $2a, $fd, $36, $06, $2a, $00, $bc, $bf, $3c, $37, $7c, $6d, $fe, $9e, $ff
	db $2b, $df, $06, $0b, $21, $ff, $fc, $81, $bc, $1f, $de, $00, $fe, $ff, $ff, $06
	db $2a, $0a, $7f, $06, $2b, $03

;@ path: unused/filler
;@ Unused filler up to the end of the bank.
Unused_34::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
