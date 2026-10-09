INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $036", ROMX[$4000], BANK[$36]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_36::
	db $36

;@ path: gfx/monsters/tables
;@ Entry table of bank $36: the address of each compressed block (entry number = position), as DecompressSetup
;@ finds it for Decompress / DecompressVRAM (bank, entry).
FarTable_36::
	dw MonPic_WingSnake
	dw MonPic_Coatol
	dw MonPic_Orochi
	dw MonPic_BattleRex
	dw MonPic_SkyDragon
	dw MonPic_Divinegon
	dw MonPic_Tonguella
	dw MonPic_Almiraj
	dw MonPic_CatFly
	dw MonPic_PillowRat
	dw MonPic_Saccer
	dw MonPic_GulpBeast
	dw MonPic_Skullroo
	dw MonPic_WindBeast
	dw MonPic_Anteater
	dw MonPic_SuperTen
	dw MonPic_IronTurt
	dw MonPic_Mommonja
	dw MonPic_HammerMan
	dw MonPic_Grizzly
	dw MonPic_Yeti
	dw MonPic_MadGopher
	dw MonPic_FairyRat
	dw MonPic_Unicorn
	dw MonPic_Goategon
	dw MonPic_WildApe
	dw MonPic_Trumpeter
	dw MonPic_KingLeo
	dw MonPic_DarkHorn
	dw MonPic_MadCat
	dw MonPic_BigEye
	dw MonPic_Picky
	dw MonPic_Wyvern
	dw MonPic_BullBird
	dw MonPic_Florajay
	dw MonPic_DuckKite
	dw MonPic_MadPecker
	dw MonPic_MadRaven
	dw MonPic_MistyWing
	dw MonPic_Dracky

;@ path: gfx/monsters/pictures
;@ Picture of WingSnake (species $27): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1DF packed).
MonPic_WingSnake::
	db $40, $02, $02, $ff, $02, $ff, $f4, $ff, $e0, $6d, $ff, $1f, $fc, $04, $02
	db $00, $05, $00, $ff, $f1, $8e, $ff, $73, $7f, $ff, $00, $ff, $0f, $f0, $3a, $cf
	db $6f, $b6, $f9, $40, $ff, $a4, $db, $fc, $ff, $02, $00, $01, $c0, $3f, $a0, $df
	db $f0, $2f, $f8, $97, $7c, $4b, $be, $02, $10, $07, $01, $fe, $07, $f9, $fd, $02
	db $00, $05, $78, $bf, $f0, $ff, $c0, $ff, $00, $ff, $03, $02, $00, $01, $06, $fd
	db $07, $fe, $03, $ff, $0f, $fe, $31, $0c, $0f, $c3, $c3, $e0, $60, $b0, $f0, $68
	db $df, $cc, $ae, $be, $73, $7e, $cb, $03, $7f, $80, $e8, $70, $7f, $0f, $0f, $04
	db $07, $08, $cc, $19, $31, $11, $d7, $0b, $fb, $95, $ef, $45, $bd, $82, $ff, $4a
	db $f6, $a2, $bf, $21, $3f, $15, $1b, $07, $2e, $1f, $d8, $7f, $f0, $bf, $a0, $ff
	db $c0, $ff, $a8, $57, $7c, $7b, $fb, $02, $10, $07, $02, $ff, $f1, $f0, $4d, $80
	db $f9, $bc, $ff, $fc, $c7, $fe, $03, $fe, $03, $ff, $01, $ff, $00, $8f, $f5, $87
	db $fd, $f7, $fd, $ff, $8c, $ff, $80, $ff, $80, $7f, $c0, $ff, $c1, $19, $f1, $1c
	db $93, $08, $e8, $8f, $f8, $84, $c4, $83, $fe, $81, $f9, $00, $c7, $11, $1f, $8b
	db $8f, $8c, $8d, $49, $4b, $a8, $6c, $17, $97, $7b, $0a, $c7, $a7, $c0, $e4, $88
	db $d2, $10, $cb, $86, $a6, $7f, $7d, $45, $f7, $a6, $f6, $da, $7e, $ff, $80, $5f
	db $c0, $3f, $60, $ff, $e0, $ff, $a0, $bf, $e0, $7f, $40, $f3, $80, $02, $b0, $0c
	db $ff, $01, $ff, $01, $02, $c8, $00, $fe, $07, $fc, $0f, $f4, $1f, $e8, $3f, $00
	db $fc, $00, $f3, $00, $cf, $00, $bf, $03, $ff, $0d, $fe, $31, $ff, $c7, $c6, $5d
	db $c1, $33, $e0, $3f, $f0, $cc, $fa, $a9, $f8, $57, $dc, $d7, $fc, $52, $5e, $df
	db $fb, $6f, $ff, $b0, $7f, $1f, $1f, $f9, $19, $e8, $1c, $8c, $4d, $36, $0e, $0d
	db $00, $e7, $c0, $fb, $02, $1f, $12, $80, $ff, $80, $02, $5c, $01, $02, $ff, $f2
	db $03, $fc, $07, $f9, $1f, $e3, $3e, $f1, $3d, $e3, $7b, $cc, $6f, $92, $dd, $28
	db $b7, $c0, $ff, $e2, $3d, $f1, $3e, $cc, $c9, $3f, $bf, $c0, $ea, $3f, $ff, $40
	db $bf, $0c, $f3, $00, $ff, $21, $de, $db, $f6, $23, $be, $c2, $fe, $0b, $f6, $83
	db $7e, $24, $dc, $86, $7d, $0b, $f8, $f5, $0d, $f6, $0e, $05, $07, $e4, $1d, $e5
	db $1f, $cf, $3e, $0f, $08, $1f, $f0, $7f, $c0, $ff, $c0, $7f, $40, $bf, $a0, $bf
	db $a0, $ff, $60, $02, $00, $00, $e7, $3c, $ff, $18, $02, $b0, $08, $fc, $1f, $fb
	db $0f, $fe, $07, $02, $cc, $00, $02, $00, $02, $08, $f7, $c0, $ff, $3f, $7f, $80
	db $b6, $ff, $02, $1f, $00, $00, $ff, $00, $18, $f4, $60, $e7, $a1, $99, $0f, $ce
	db $ff, $f0, $02, $00, $02, $3f, $20, $7f, $c0, $ff, $02, $1f, $1e, $02, $ff, $f5
;@ path: gfx/monsters/pictures
;@ Picture of Coatol (species $28): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1CB packed).
MonPic_Coatol::
	db $40, $02, $05, $ff, $05, $ff, $f0, $ff, $e6, $27, $f1, $11, $f9, $09, $fe, $07
	db $fd, $07, $05, $00, $01, $f0, $0f, $fc, $b3, $fe, $55, $ff, $aa, $bb, $31, $31
	db $05, $00, $01, $01, $ff, $01, $fe, $03, $fe, $83, $7d, $c7, $3d, $e5, $ff, $00
	db $ff, $80, $ff, $c0, $bf, $bb, $94, $9f, $9a, $9f, $25, $3d, $48, $78, $05, $00
	db $02, $0e, $fe, $d0, $f0, $a9, $b9, $57, $de, $cb, $ce, $05, $10, $02, $7f, $40
	db $ff, $80, $05, $00, $01, $00, $ff, $07, $ff, $04, $05, $5a, $03, $05, $ff, $f1
	db $b0, $b0, $fc, $7c, $fe, $22, $ff, $01, $fe, $07, $f8, $0e, $f9, $0d, $fc, $07
	db $9d, $fd, $49, $7f, $a0, $bf, $70, $df, $69, $df, $30, $76, $00, $39, $c0, $cf
	db $90, $f0, $23, $e3, $55, $d7, $e8, $bf, $66, $bf, $c1, $e7, $09, $cb, $32, $3e
	db $df, $de, $ef, $ea, $4f, $48, $8f, $88, $4f, $c8, $4f, $c8, $27, $e4, $bf, $fe
	db $05, $64, $08, $05, $b0, $0f, $02, $03, $05, $64, $07, $0c, $f3, $1e, $30, $f0
	db $df, $f6, $c9, $79, $ef, $36, $e0, $2f, $ff, $1f, $e0, $3c, $c2, $45, $cc, $fd
	db $b1, $f7, $31, $eb, $4a, $c7, $75, $47, $aa, $9e, $b4, $7c, $5c, $7c, $a3, $ff
	db $7f, $fc, $4f, $c8, $9f, $90, $5f, $d0, $bf, $e0, $7f, $60, $ff, $90, $05, $b0
	db $0f, $0d, $fb, $ee, $bb, $df, $f6, $6f, $f6, $3f, $cc, $7c, $db, $7c, $e9, $7e
	db $f0, $10, $b7, $ce, $09, $0f, $7d, $f7, $dd, $6f, $3b, $37, $9b, $5f, $e7, $3e
	db $2b, $7f, $ab, $ef, $67, $e6, $af, $ea, $7f, $70, $ff, $a5, $ff, $07, $fc, $5f
	db $b0, $bd, $ff, $00, $ff, $10, $ff, $1c, $e3, $23, $f9, $f9, $06, $ef, $01, $bf
	db $00, $fb, $05, $00, $01, $60, $bf, $e0, $7f, $e0, $bf, $a0, $3f, $20, $9f, $05
	db $0f, $1d, $f7, $18, $e3, $3c, $e0, $20, $cf, $70, $cf, $70, $c7, $58, $c0, $60
	db $c7, $59, $36, $b6, $d3, $37, $08, $0b, $e6, $16, $c3, $29, $0a, $90, $f2, $84
	db $64, $d1, $c0, $ef, $00, $fd, $0f, $5f, $30, $fa, $c0, $ea, $a8, $02, $a8, $02
	db $a9, $03, $30, $7e, $40, $ff, $b0, $fd, $c0, $ff, $a0, $ff, $c0, $fb, $80, $df
	db $00, $ff, $05, $a6, $00, $7f, $fc, $4f, $fc, $77, $7c, $4f, $cc, $97, $9c, $a7
	db $b4, $05, $b0, $0c, $e3, $3d, $e0, $20, $f1, $1e, $fc, $0c, $05, $d0, $04, $25
	db $a8, $9d, $de, $c3, $73, $31, $3d, $9e, $ef, $ff, $7f, $05, $00, $00, $a1, $0d
	db $02, $6f, $fc, $ff, $3f, $3f, $48, $c8, $c0, $ff, $ff, $3f, $ff, $00, $01, $fb
	db $02, $df, $0d, $7d, $f8, $fb, $88, $8e, $03, $fb, $ff, $fc, $ff, $00, $4f, $78
	db $8f, $e8, $9f, $d0, $3f, $a0, $ff, $c0, $05, $5a, $02

;@ path: gfx/monsters/pictures
;@ Picture of Orochi (species $29): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1C1 packed).
MonPic_Orochi::
	db $40, $02, $15, $ff, $15
	db $ff, $ff, $05, $01, $fe, $06, $f9, $0d, $f6, $07, $ff, $00, $ff, $30, $df, $50
	db $9f, $90, $1f, $1c, $e7, $e4, $2f, $ee, $db, $da, $ff, $00, $ff, $18, $f7, $14
	db $f3, $12, $f1, $71, $ce, $4e, $e9, $ef, $b6, $b7, $15, $00, $07, $c0, $3f, $60
	db $df, $c0, $15, $00, $0f, $06, $15, $13, $03, $ff, $05, $fa, $0f, $fc, $1f, $e0
	db $2b, $fd, $3f, $ff, $2a, $f5, $d5, $7b, $4b, $c7, $7f, $95, $fd, $2b, $fe, $5b
	db $fa, $db, $fe, $ab, $ee, $35, $f7, $6d, $ed, $c7, $fd, $52, $7f, $a8, $ff, $b4
	db $bf, $b7, $ff, $ab, $ee, $59, $df, $6d, $6f, $ff, $40, $bf, $e0, $7f, $f0, $0f
	db $a8, $7f, $f8, $ff, $a8, $5f, $56, $bd, $a5, $15, $00, $0c, $fe, $02, $fe, $02
	db $fc, $04, $fd, $05, $fe, $0f, $f5, $77, $8f, $de, $81, $ff, $75, $75, $1f, $1f
	db $60, $7d, $80, $f7, $4f, $ff, $9a, $ba, $8f, $ff, $0f, $d8, $f5, $b7, $eb, $ee
	db $d3, $d2, $23, $e6, $13, $b2, $89, $f9, $4f, $6f, $a8, $be, $5f, $db, $af, $ef
	db $96, $97, $88, $cf, $91, $9b, $22, $3e, $e5, $ed, $2b, $fa, $5c, $5c, $f0, $f0
	db $0c, $7c, $03, $df, $e4, $ff, $b3, $bb, $e3, $fe, $e1, $37, $ff, $80, $ff, $80
	db $7f, $40, $7f, $40, $ff, $e0, $5f, $dc, $e3, $f6, $03, $fe, $fc, $7f, $ff, $57
	db $e0, $20, $fb, $11, $fe, $1f, $f1, $1f, $ff, $0e, $ff, $00, $6f, $e8, $9f, $f1
	db $9e, $f3, $7e, $e2, $fc, $8f, $f4, $1d, $e4, $3f, $e4, $3f, $e0, $fb, $a0, $af
	db $61, $7b, $42, $fe, $03, $d7, $0a, $fa, $0b, $7f, $0a, $da, $0f, $be, $0b, $eb
	db $0c, $bd, $84, $fe, $80, $d7, $a0, $bf, $a0, $fd, $a0, $b7, $ec, $2f, $f3, $1f
	db $f2, $9e, $fd, $8f, $7e, $e3, $5f, $71, $4f, $f8, $4f, $f8, $7f, $fc, $ff, $d4
	db $0f, $08, $bf, $10, $ff, $f0, $1f, $f0, $ff, $e0, $15, $62, $0b, $00, $ff, $00
	db $e6, $37, $e4, $26, $e8, $2f, $f8, $1d, $f0, $fe, $f1, $b5, $e8, $cc, $f8, $7c
	db $0b, $ff, $0e, $fe, $0a, $de, $09, $3b, $96, $97, $d7, $dd, $f2, $ba, $f0, $97
	db $a0, $ff, $e0, $fe, $a0, $f7, $20, $b9, $d2, $d2, $d7, $77, $9e, $ba, $1e, $d2
	db $cf, $d8, $4f, $c8, $2f, $e8, $3f, $70, $1f, $fe, $1f, $5b, $2f, $66, $3f, $7c
	db $15, $50, $0f, $0c, $00, $e0, $78, $f3, $d3, $ff, $6c, $ff, $30, $15, $00, $04
	db $78, $5d, $fc, $af, $ff, $eb, $ff, $0d, $fb, $0b, $fb, $09, $fc, $07, $ff, $03
	db $3c, $74, $7f, $eb, $ff, $ae, $ff, $60, $bf, $a0, $bf, $20, $7f, $c0, $ff, $80
	db $0f, $3c, $9f, $96, $ff, $6c, $ff, $18, $15, $00, $0f, $05

;@ path: gfx/monsters/pictures
;@ Picture of BattleRex (species $2A): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1A0 packed).
MonPic_BattleRex::
	db $40, $02, $04, $ff
	db $04, $ff, $ff, $0b, $03, $ff, $40, $ff, $60, $ff, $60, $df, $78, $ef, $38, $f7
	db $2c, $ff, $7f, $e4, $f5, $ff, $01, $ff, $07, $fb, $1d, $ef, $32, $df, $62, $b1
	db $c3, $47, $8a, $df, $c4, $ff, $80, $04, $00, $0f, $0c, $04, $ff, $fb, $fc, $0f
	db $f8, $0f, $ff, $0f, $ef, $08, $ff, $10, $ff, $10, $f8, $17, $f8, $0f, $9e, $db
	db $07, $f7, $83, $be, $e3, $7e, $bf, $5c, $ea, $14, $ff, $00, $1f, $e0, $23, $a7
	db $a7, $aa, $9f, $54, $d3, $16, $17, $3c, $df, $14, $df, $18, $bf, $68, $04, $00
	db $07, $01, $fe, $07, $f9, $1f, $04, $00, $05, $78, $df, $f0, $7f, $e6, $fb, $ce
	db $04, $00, $0c, $fe, $07, $ff, $0d, $f3, $12, $f5, $15, $fa, $1e, $f1, $1f, $f1
	db $3f, $fb, $2f, $1c, $ff, $c3, $c3, $e0, $2f, $d1, $7f, $8f, $ae, $97, $99, $26
	db $3f, $b9, $bf, $4f, $ee, $f3, $d7, $7c, $bf, $b2, $57, $f0, $72, $89, $f9, $7e
	db $ff, $d3, $b3, $e6, $7e, $98, $b8, $a0, $e0, $c0, $c0, $e0, $e0, $20, $e3, $cf
	db $c1, $3f, $06, $33, $36, $03, $06, $0f, $02, $07, $1c, $7f, $08, $3f, $f0, $ff
	db $c0, $04, $a2, $07, $06, $f8, $09, $f0, $16, $f1, $11, $fc, $05, $fa, $1e, $e9
	db $6b, $89, $99, $06, $66, $1f, $9b, $7e, $66, $fa, $8a, $47, $fe, $79, $fe, $a3
	db $ff, $7d, $fe, $a0, $bc, $43, $44, $80, $f8, $83, $8c, $ec, $1d, $f7, $10, $8f
	db $fb, $fc, $7f, $78, $0f, $c4, $07, $3c, $07, $c2, $23, $1f, $f8, $ff, $e0, $7f
	db $c0, $04, $64, $12, $bf, $a0, $9f, $f0, $04, $00, $0d, $0e, $ff, $03, $fc, $0c
	db $f0, $10, $e0, $22, $c3, $4b, $df, $7c, $bf, $e0, $f2, $f2, $11, $11, $20, $22
	db $20, $67, $20, $a7, $e0, $e7, $e0, $23, $f0, $10, $83, $f0, $80, $9c, $81, $e6
	db $60, $7b, $10, $dc, $28, $af, $57, $77, $91, $d6, $9e, $03, $43, $33, $ce, $02
	db $0c, $bc, $1c, $74, $3f, $e7, $fc, $c4, $fc, $85, $8f, $f8, $0f, $f8, $07, $fc
	db $07, $7c, $07, $3c, $0f, $08, $ff, $f0, $7f, $e0, $04, $00, $0d, $04, $1d, $16
	db $04, $ff, $f2, $0f, $fe, $02, $fe, $0e, $fc, $7d, $f0, $b6, $f6, $de, $ff, $79
	db $ff, $00, $23, $6b, $3f, $fc, $1f, $d8, $1f, $f4, $3f, $fc, $bf, $e0, $ff, $40
	db $ff, $c0, $f8, $19, $f9, $29, $fc, $3c, $ff, $03, $04, $00, $04, $3f, $fc, $9f
	db $fa, $df, $d6, $ff, $bc, $ff, $04, $cf, $1e, $04, $ff, $f1

;@ path: gfx/monsters/pictures
;@ Picture of SkyDragon (species $2B): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1D5 packed).
MonPic_SkyDragon::
	db $40, $02, $05, $ff
	db $05, $ff, $ff, $05, $01, $fe, $03, $fc, $07, $f9, $0f, $ff, $00, $ff, $07, $f8
	db $3f, $c7, $ff, $3a, $fa, $55, $df, $af, $bf, $5b, $7b, $ff, $06, $f9, $8f, $7c
	db $f7, $8c, $fd, $f2, $fe, $5f, $df, $e1, $ff, $00, $ff, $ff, $30, $df, $50, $bf
	db $ec, $37, $f4, $df, $f8, $1f, $10, $ff, $e0, $3f, $b8, $05, $00, $0f, $06, $05
	db $ff, $f1, $e7, $00, $fa, $0e, $f3, $1f, $f2, $1f, $e2, $3b, $e5, $3f, $e5, $3f
	db $e7, $3e, $e7, $3e, $b4, $f7, $78, $df, $f0, $9f, $f0, $9f, $e1, $3f, $e3, $3f
	db $e2, $3e, $e3, $3f, $05, $ff, $f0, $3f, $ff, $d5, $d5, $1a, $7a, $3d, $eb, $7e
	db $c5, $7c, $c7, $0f, $e8, $0f, $e4, $07, $f2, $83, $fa, $c3, $f9, $61, $79, $a3
	db $b9, $e1, $f9, $05, $00, $08, $f3, $00, $ef, $08, $fb, $08, $fd, $04, $fe, $02
	db $ff, $01, $05, $66, $05, $3e, $f7, $1e, $f3, $1a, $73, $1a, $f3, $9a, $b3, $9a
	db $fb, $4a, $db, $4a, $e2, $3e, $f1, $1f, $f0, $1f, $f8, $0f, $f4, $17, $f6, $17
	db $f7, $17, $f6, $77, $3c, $eb, $19, $7f, $86, $be, $5d, $dd, $2a, $eb, $ec, $ef
	db $e8, $ee, $a9, $ac, $a3, $b9, $41, $79, $87, $f2, $13, $f3, $4c, $ff, $80, $ff
	db $86, $ff, $cc, $fe, $df, $10, $ff, $20, $bf, $20, $ff, $40, $ff, $c0, $ff, $c0
	db $ff, $80, $ff, $80, $05, $0e, $08, $ff, $03, $ff, $06, $eb, $2a, $f7, $34, $f7
	db $14, $ff, $38, $ff, $70, $f7, $d0, $ff, $09, $ff, $08, $c3, $43, $f2, $32, $e9
	db $39, $d1, $71, $cc, $7c, $c2, $7e, $e3, $ff, $dc, $df, $4b, $c9, $ef, $ea, $af
	db $ac, $4f, $c8, $ef, $ab, $fd, $fd, $27, $fe, $93, $ff, $fd, $37, $fd, $07, $fd
	db $07, $ff, $07, $fa, $1f, $e7, $3f, $ed, $3f, $f7, $97, $05, $1e, $11, $60, $bf
	db $a0, $ff, $c0, $7f, $40, $05, $1e, $11, $1c, $e7, $24, $cb, $4a, $e9, $69, $cb
	db $cb, $a9, $a9, $a2, $a2, $d5, $55, $ff, $08, $ff, $08, $ef, $08, $ff, $11, $ff
	db $10, $df, $10, $ff, $a0, $ff, $a0, $e5, $27, $f8, $1f, $fe, $7f, $cd, $cb, $ff
	db $31, $d7, $59, $ff, $f9, $ff, $04, $7d, $7d, $89, $89, $6f, $ee, $7f, $5a, $27
	db $bf, $04, $ff, $88, $ff, $c2, $df, $ff, $8d, $05, $00, $05, $80, $ff, $e0, $bf
	db $f1, $7f, $00, $ff, $80, $bf, $80, $ff, $40, $ff, $40, $bf, $80, $ff, $80, $7f
	db $00, $f6, $76, $f3, $53, $fb, $0a, $fb, $0a, $ff, $04, $05, $00, $03, $a0, $ff
	db $a0, $df, $10, $ef, $08, $f7, $07, $05, $00, $03, $02, $ff, $01, $fe, $06, $fb
	db $18, $ef, $e0, $05, $00, $02, $b7, $bd, $7f, $7f, $ff, $bf, $f5, $5f, $e7, $41
	db $ff, $24, $ff, $2b, $ff, $30, $ee, $4e, $05, $1e, $15, $05, $1d, $1a, $05, $ff
	db $f3

;@ path: gfx/monsters/pictures
;@ Picture of Divinegon (species $2C): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1D6 packed).
MonPic_Divinegon::
	db $40, $02, $0a, $ff, $0a, $ff, $ff, $05, $01, $fe, $03, $fd, $06, $fb, $0d
	db $ff, $00, $ff, $07, $fb, $3c, $df, $e7, $7a, $bf, $df, $75, $bf, $ef, $7b, $df
	db $ff, $06, $ff, $89, $7f, $f4, $ed, $9e, $fa, $f7, $df, $7f, $ef, $f1, $7f, $80
	db $ff, $30, $df, $70, $ff, $ac, $f7, $3c, $ff, $d8, $1f, $f0, $ff, $e0, $bf, $30
	db $0a, $00, $0f, $06, $0a, $ff, $f1, $e7, $00, $fe, $0b, $f7, $1b, $ff, $12, $eb
	db $36, $ff, $25, $ff, $25, $ff, $26, $ff, $26, $f5, $be, $fb, $5c, $f7, $98, $ff
	db $90, $ef, $31, $ff, $23, $fe, $23, $ff, $23, $0a, $00, $01, $3f, $d5, $ff, $3a
	db $9f, $7b, $2d, $7d, $46, $fd, $46, $ef, $08, $f7, $04, $f7, $02, $fb, $82, $fb
	db $c1, $7d, $e1, $bd, $e1, $fd, $e1, $0a, $00, $08, $f3, $00, $ef, $08, $fb, $08
	db $fd, $04, $fe, $02, $ff, $01, $0a, $00, $04, $ef, $36, $ff, $16, $fb, $16, $7b
	db $16, $fb, $96, $b3, $9e, $fb, $4e, $db, $4e, $ee, $33, $ff, $11, $f7, $18, $fb
	db $0c, $f5, $1e, $fe, $17, $ff, $17, $ff, $76, $7b, $2c, $3b, $9d, $9e, $c7, $dd
	db $7f, $eb, $3e, $ff, $ec, $ff, $e8, $fe, $a9, $bd, $e1, $79, $c3, $fb, $82, $f3
	db $17, $ff, $4c, $ff, $80, $b7, $ce, $ce, $fd, $df, $10, $ff, $20, $bf, $20, $ff
	db $40, $ff, $c0, $ff, $c0, $ff, $80, $ff, $80, $0a, $0e, $08, $ff, $03, $ff, $06
	db $eb, $2e, $f7, $3c, $f7, $1c, $ff, $38, $ff, $70, $f7, $d0, $ff, $09, $ff, $08
	db $db, $67, $f6, $3b, $fd, $2b, $d7, $79, $fe, $4d, $fb, $46, $ff, $e3, $df, $fc
	db $fd, $4b, $fb, $ee, $ff, $ac, $ff, $48, $ef, $bb, $fd, $ff, $ff, $26, $ff, $93
	db $ff, $35, $ff, $05, $fd, $07, $ff, $07, $ff, $1a, $ef, $37, $ff, $2d, $f7, $9f
	db $0a, $1e, $11, $60, $bf, $e0, $ff, $c0, $7f, $0a, $1b, $10, $00, $ff, $1c, $e7
	db $3c, $cb, $7e, $e9, $7f, $cb, $ff, $a9, $ff, $a2, $ff, $d5, $7f, $ff, $08, $ff
	db $08, $ef, $08, $ff, $11, $ff, $10, $df, $10, $ff, $a0, $ff, $a0, $ff, $25, $ff
	db $18, $ff, $7e, $df, $e9, $ff, $31, $f7, $59, $ff, $f9, $ff, $04, $7d, $ff, $bb
	db $cd, $ef, $7e, $7f, $da, $a7, $7f, $ff, $04, $ff, $88, $df, $c2, $ff, $8d, $0a
	db $00, $05, $80, $ff, $e0, $ff, $b1, $7f, $00, $ff, $80, $bf, $80, $ff, $40, $ff
	db $40, $bf, $80, $ff, $80, $7f, $00, $f6, $7f, $f3, $5f, $fb, $0e, $fb, $0e, $ff
	db $04, $0a, $00, $03, $a0, $ff, $a0, $df, $10, $ef, $08, $f7, $07, $0a, $00, $03
	db $02, $ff, $01, $fe, $06, $fb, $18, $ef, $e0, $0a, $00, $02, $bf, $b5, $7f, $7f
	db $ff, $bf, $f5, $5f, $e7, $41, $ff, $24, $ff, $2b, $ff, $30, $ee, $4e, $0a, $1e
	db $15, $0a, $1d, $1a, $0a, $ff, $f3

;@ path: gfx/monsters/pictures
;@ Picture of Tonguella (species $2D): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $128 packed).
MonPic_Tonguella::
	db $40, $02, $05, $ff, $05, $ff, $ff, $4d, $05
	db $5f, $0f, $4d, $05, $73, $0e, $01, $ff, $01, $ff, $03, $fd, $0f, $f1, $3f, $c6
	db $5f, $89, $fd, $05, $d0, $01, $ff, $45, $ff, $bb, $7d, $c7, $ff, $00, $83, $01
	db $7d, $05, $72, $03, $80, $7f, $e0, $1f, $f8, $c7, $f4, $23, $7e, $05, $b2, $0f
	db $0f, $fe, $03, $fc, $07, $f8, $0b, $f8, $0d, $f0, $15, $f0, $13, $e0, $2e, $0f
	db $fd, $3e, $ff, $40, $d7, $4c, $ef, $4e, $de, $2f, $e7, $5d, $57, $6f, $7b, $7d
	db $ff, $aa, $c7, $d6, $ff, $38, $bb, $00, $fe, $ff, $ff, $11, $55, $55, $bb, $e1
	db $7f, $f8, $ff, $04, $d7, $64, $ef, $f4, $f7, $d8, $ef, $f4, $95, $dc, $bc, $05
	db $f4, $01, $c0, $3f, $a0, $3f, $60, $1f, $50, $1f, $90, $0f, $e8, $05, $72, $0c
	db $e0, $2c, $e1, $3d, $e3, $3a, $e7, $3d, $ef, $4d, $fe, $56, $d6, $7e, $fe, $2a
	db $9f, $9b, $8d, $9f, $81, $af, $02, $5f, $02, $ff, $02, $ff, $01, $ef, $01, $67
	db $7d, $93, $7d, $93, $ff, $11, $ef, $01, $fd, $03, $fe, $03, $7a, $87, $86, $ff
	db $72, $32, $e3, $b3, $e3, $ab, $41, $f5, $01, $ff, $00, $fe, $00, $ee, $00, $cc
	db $0f, $68, $0f, $78, $8e, $bf, $49, $ff, $6c, $e7, $fc, $d5, $d4, $fc, $af, $af
	db $05, $72, $02, $df, $e0, $3f, $f0, $0f, $7c, $03, $0e, $ff, $fe, $ff, $01, $ff
	db $07, $fe, $0d, $ff, $07, $ff, $01, $05, $72, $02, $81, $83, $60, $60, $df, $df
	db $bf, $78, $ff, $c0, $05, $72, $02, $7a, $ff, $f6, $8a, $ef, $9b, $ff, $54, $ff
	db $50, $ff, $20, $05, $72, $00, $03, $83, $0d, $0d, $f6, $f7, $fb, $3d, $ff, $07
	db $05, $72, $02, $7f, $70, $ff, $c0, $ff, $60, $05, $f8, $14, $05, $72, $0e

;@ path: gfx/monsters/pictures
;@ Picture of Almiraj (species $2E): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $DE packed).
MonPic_Almiraj::
	db $40
	db $02, $03, $ff, $03, $ff, $ff, $4d, $03, $5f, $0f, $4d, $03, $87, $0f, $13, $01
	db $ff, $01, $fe, $02, $ff, $02, $fe, $02, $03, $86, $07, $80, $03, $fa, $01, $03
	db $87, $0f, $1c, $fb, $7c, $f6, $8f, $fd, $81, $fe, $40, $fe, $21, $ff, $10, $fe
	db $08, $fb, $0c, $ff, $0e, $f2, $1a, $e5, $be, $44, $fc, $a7, $fc, $58, $fc, $2b
	db $f8, $a8, $3c, $ff, $e0, $9e, $b1, $4f, $fb, $44, $7e, $ca, $7f, $35, $7e, $a8
	db $3e, $2b, $78, $bf, $7c, $df, $e2, $7f, $02, $ff, $04, $ff, $08, $ff, $10, $ff
	db $20, $bf, $60, $03, $86, $0f, $0d, $fd, $06, $fb, $0f, $fa, $0f, $f4, $1f, $03
	db $96, $12, $fa, $0f, $17, $dc, $f3, $ff, $28, $ff, $5c, $f7, $55, $fc, $4f, $fc
	db $3f, $e2, $17, $f1, $d1, $76, $9f, $ff, $28, $ff, $74, $df, $54, $7f, $e4, $7f
	db $f8, $8f, $d0, $1f, $7f, $c0, $bf, $e0, $bf, $e0, $5f, $f0, $03, $c6, $12, $bf
	db $e0, $03, $86, $0f, $0d, $fe, $07, $f9, $1f, $fe, $21, $d7, $43, $ff, $3c, $03
	db $86, $02, $1b, $ed, $3f, $d7, $b7, $d8, $af, $9f, $ff, $88, $ff, $70, $03, $86
	db $00, $b0, $6f, $f9, $d7, $da, $37, $eb, $f3, $ff, $22, $ff, $1c, $03, $86, $01
	db $c0, $3f, $f0, $ff, $08, $d7, $84, $ff, $78, $03, $86, $0f, $03

;@ path: gfx/monsters/pictures
;@ Picture of CatFly (species $2F): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $18F packed).
MonPic_CatFly::
	db $40, $02, $0d
	db $ff, $0d, $ff, $fa, $03, $0d, $00, $01, $08, $ff, $18, $e7, $3c, $e7, $3c, $c7
	db $ff, $18, $ff, $0d, $00, $0b, $c0, $0d, $00, $09, $01, $fe, $07, $0d, $00, $01
	db $20, $ff, $30, $cf, $78, $cf, $78, $c7, $fe, $31, $0d, $1f, $0c, $80, $ff, $01
	db $0d, $36, $05, $03, $fd, $07, $fa, $0e, $18, $ff, $c7, $df, $c7, $4c, $b7, $fc
	db $53, $de, $93, $96, $09, $0f, $08, $0f, $ff, $80, $0d, $36, $06, $f8, $ff, $84
	db $fe, $fe, $03, $0d, $60, $05, $c0, $3f, $ff, $42, $ff, $31, $ff, $c7, $f6, $c7
	db $64, $db, $7e, $95, $f7, $92, $d3, $21, $e1, $20, $e0, $0d, $54, $08, $7f, $c0
	db $bf, $e0, $f4, $1c, $e8, $38, $88, $18, $d0, $70, $10, $30, $a0, $e0, $a1, $e1
	db $a7, $e6, $08, $0b, $04, $05, $02, $02, $01, $01, $0d, $fc, $f0, $f0, $f0, $fc
	db $0c, $9c, $f8, $6f, $f9, $47, $7f, $89, $ff, $88, $bf, $47, $47, $77, $75, $4f
	db $4f, $72, $3f, $ec, $3f, $d4, $fc, $23, $ff, $22, $fa, $c4, $c4, $dc, $5c, $e4
	db $e4, $20, $a0, $40, $40, $80, $80, $0d, $fa, $f2, $1f, $1f, $7f, $60, $5f, $70
	db $2f, $38, $23, $30, $17, $1c, $11, $18, $0b, $0e, $0b, $0e, $cb, $ce, $af, $e8
	db $bf, $f0, $bf, $a0, $ff, $60, $ff, $27, $fe, $03, $0d, $90, $00, $fe, $02, $ff
	db $01, $ff, $23, $fd, $37, $c9, $ff, $49, $ff, $28, $fb, $74, $fc, $47, $45, $85
	db $b6, $03, $7b, $00, $7c, $00, $7f, $00, $3f, $80, $bf, $40, $df, $c4, $44, $43
	db $db, $81, $bd, $01, $7d, $01, $fd, $01, $f9, $02, $fb, $04, $f6, $0d, $80, $01
	db $88, $7f, $d8, $27, $ff, $24, $ff, $28, $bf, $5d, $7f, $eb, $2e, $fb, $1e, $fb
	db $0a, $ff, $0c, $ff, $c8, $ff, $80, $0d, $80, $00, $fe, $03, $fe, $02, $ff, $0d
	db $3f, $02, $0d, $ff, $f1, $23, $af, $70, $72, $fc, $8d, $0d, $30, $11, $0d, $ff
	db $f1, $20, $67, $80, $82, $3c, $3c, $3e, $22, $fe, $c2, $0d, $2a, $10, $fe, $03
	db $01, $c5, $02, $82, $78, $79, $f8, $88, $ff, $87, $0d, $7a, $11, $80, $88, $eb
	db $1c, $9c, $7f, $63, $0d, $80, $05, $0d, $5d, $00, $80, $0d, $2e, $0b, $0d, $d7
	db $1f, $0a, $0d, $90, $07, $0d, $ff, $f1, $7f, $e0, $1f, $fe, $c1, $ff, $f8, $3d
	db $fc, $06, $0d, $0e, $03, $0d, $cb, $16, $0d, $d7, $1f, $02

;@ path: gfx/monsters/pictures
;@ Picture of PillowRat (species $30): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $C4 packed).
MonPic_PillowRat::
	db $40, $02, $02, $ff
	db $02, $ff, $ff, $4d, $02, $5f, $0f, $4d, $02, $7b, $0f, $07, $10, $ef, $3c, $ff
	db $13, $02, $7a, $09, $7f, $be, $c1, $02, $7a, $07, $04, $fb, $1e, $ff, $e4, $02
	db $7a, $0f, $1e, $03, $ff, $04, $ff, $08, $ff, $08, $ff, $10, $ff, $10, $f7, $18
	db $f7, $18, $ff, $00, $ff, $80, $7f, $02, $ef, $01, $eb, $77, $be, $dd, $ff, $a2
	db $ff, $60, $df, $b0, $6f, $98, $ef, $18, $f7, $0c, $f7, $0c, $e7, $9c, $e7, $9c
	db $02, $7a, $0b, $f0, $02, $7a, $0f, $0d, $fb, $1c, $e5, $3e, $db, $67, $ee, $51
	db $df, $62, $de, $63, $cf, $71, $e7, $38, $ff, $49, $ab, $76, $22, $e3, $dd, $ff
	db $f3, $6f, $7f, $14, $9c, $f7, $ff, $63, $cf, $3d, $12, $f7, $61, $ef, $81, $bf
	db $e1, $3f, $21, $7b, $c1, $fd, $23, $d2, $7f, $88, $d7, $2c, $07, $fc, $3f, $f8
	db $ff, $c0, $02, $7a, $0f, $13, $f9, $1e, $fe, $07, $ff, $01, $fe, $07, $fc, $07
	db $ff, $03, $02, $7a, $02, $00, $ff, $ff, $ff, $1c, $dd, $ff, $e3, $02, $7a, $02
	db $8f, $7c, $3f, $f0, $ff, $c0, $3f, $f0, $9f, $f0, $ff, $60, $02, $7a, $0f, $11
;@ path: gfx/monsters/pictures
;@ Picture of Saccer (species $31): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $11E packed).
MonPic_Saccer::
	db $40, $02, $04, $ff, $04, $ff, $ff, $19, $01, $fe, $03, $04, $00, $09, $80, $7f
	db $c0, $04, $00, $0f, $1a, $04, $21, $09, $04, $2c, $00, $fe, $03, $fe, $23, $dc
	db $77, $dd, $77, $cd, $ff, $6a, $ff, $6a, $ff, $b2, $fb, $a4, $ff, $ff, $80, $ff
	db $a2, $5d, $f7, $dd, $f7, $cd, $ff, $9a, $bf, $9a, $ff, $a5, $f7, $04, $00, $05
	db $a0, $df, $f0, $bf, $e0, $04, $3e, $0f, $10, $09, $f7, $1d, $fa, $0f, $fd, $07
	db $ff, $03, $fe, $06, $ff, $07, $fb, $0f, $a4, $b5, $4e, $7e, $ef, $ed, $3f, $3a
	db $5f, $5d, $a7, $a7, $ab, $af, $f2, $57, $b5, $fd, $f2, $ff, $fb, $df, $fe, $ae
	db $fd, $dd, $f2, $f2, $aa, $fa, $a7, $f5, $7f, $e0, $9f, $f0, $bf, $e0, $5f, $70
	db $5f, $70, $af, $b8, $ef, $f8, $ff, $70, $04, $00, $0f, $0d, $fd, $07, $fe, $03
	db $ff, $07, $fc, $07, $04, $7c, $00, $ff, $03, $fd, $07, $52, $ff, $b1, $bf, $34
	db $ff, $57, $df, $95, $bd, $d5, $ff, $7a, $7f, $2a, $af, $a5, $ff, $36, $fe, $d5
	db $fd, $55, $ff, $49, $ff, $52, $ff, $6a, $ff, $ba, $fe, $7f, $e0, $df, $f0, $4f
	db $f8, $ef, $f8, $7f, $d0, $7f, $40, $ff, $80, $ff, $80, $04, $10, $1f, $0f, $ff
	db $02, $04, $00, $08, $a9, $bd, $d5, $7f, $d6, $7f, $b6, $f7, $b5, $b7, $da, $5b
	db $ba, $ab, $fa, $ca, $9b, $ff, $54, $ff, $d2, $f7, $ca, $fb, $56, $76, $5f, $79
	db $d7, $fc, $b3, $b6, $ff, $80, $ff, $c0, $3f, $e0, $ff, $c0, $ff, $80, $04, $6a
	db $11, $04, $41, $0f, $1e, $f5, $1d, $ed, $3f, $ff, $12, $04, $00, $06, $9b, $9a
	db $bf, $a4, $bf, $a0, $bf, $e0, $bf, $e0, $ff, $40, $04, $00, $0f, $11

;@ path: gfx/monsters/pictures
;@ Picture of GulpBeast (species $32): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1BD packed).
MonPic_GulpBeast::
	db $40, $02
	db $09, $ff, $09, $ff, $f8, $07, $f8, $18, $09, $00, $09, $f0, $0f, $0c, $09, $00
	db $03, $05, $fa, $0f, $fa, $0f, $fb, $0d, $fd, $06, $09, $00, $01, $e0, $7f, $c0
	db $ff, $80, $09, $34, $01, $c0, $09, $00, $09, $09, $41, $0f, $00, $e0, $23, $c7
	db $4f, $9f, $98, $bf, $a0, $09, $3e, $04, $03, $02, $01, $e1, $c0, $f0, $e1, $39
	db $f2, $1e, $f4, $1d, $f8, $0b, $f8, $0f, $fb, $1a, $e5, $e5, $87, $8f, $07, $35
	db $05, $f6, $03, $fa, $05, $fe, $16, $fd, $bf, $b0, $cf, $4c, $c3, $52, $41, $fd
	db $e0, $be, $c0, $5f, $80, $bf, $a0, $ff, $09, $00, $05, $80, $7f, $40, $3f, $a0
	db $3f, $e0, $09, $40, $0d, $7c, $83, $ff, $fc, $7f, $ff, $03, $ff, $00, $ff, $01
	db $fe, $03, $fc, $07, $f0, $1f, $f0, $9f, $70, $ff, $98, $ff, $e4, $7f, $fa, $ff
	db $25, $ef, $22, $ef, $0f, $ed, $0b, $fd, $09, $88, $00, $15, $fe, $2b, $fe, $7a
	db $ef, $b8, $e8, $c0, $5f, $c0, $7f, $80, $bf, $80, $ff, $d0, $ff, $68, $ff, $bd
	db $ef, $2a, $3f, $1f, $f0, $1f, $f3, $1c, $ff, $33, $ff, $4f, $fc, $bf, $ff, $48
	db $eb, $88, $eb, $ff, $7c, $83, $fe, $7f, $fc, $ff, $80, $09, $a4, $03, $c0, $fc
	db $05, $fc, $04, $fe, $02, $ff, $01, $fe, $07, $ff, $1d, $f9, $2f, $fe, $3f, $2f
	db $ed, $2b, $2d, $2d, $2f, $5d, $53, $f2, $ef, $bd, $ff, $0a, $ff, $0f, $fe, $4c
	db $f7, $2f, $77, $18, $3f, $80, $ef, $48, $eb, $ad, $f9, $c7, $77, $e4, $ac, $65
	db $df, $e9, $dd, $31, $f9, $03, $ef, $24, $af, $6b, $3f, $c6, $dd, $4f, $6a, $e8
	db $69, $ae, $7e, $61, $ff, $70, $9f, $98, $ef, $78, $fd, $a2, $fb, $e4, $e5, $3f
	db $e0, $3f, $e0, $3f, $20, $ff, $09, $3d, $00, $c0, $ff, $bc, $b7, $d2, $09, $cc
	db $00, $fc, $07, $fc, $05, $09, $24, $10, $09, $6c, $01, $f3, $01, $f1, $03, $e3
	db $07, $84, $0f, $08, $8f, $88, $87, $e4, $87, $e4, $f3, $9f, $ef, $df, $7c, $73
	db $b7, $bf, $fd, $7d, $fd, $1f, $fc, $0f, $ff, $0b, $9f, $f3, $ef, $f7, $7d, $9d
	db $db, $fa, $7f, $7c, $7f, $f0, $7f, $e0, $ff, $a0, $88, $89, $78, $7b, $f8, $89
	db $f8, $30, $dc, $60, $cb, $5c, $fc, $b6, $ff, $c3, $df, $ce, $ff, $b8, $ff, $80
	db $ff, $70, $7f, $88, $8f, $e4, $ff, $7c, $ff, $c0, $ff, $0f, $fc, $13, $eb, $27
	db $ff, $2d, $ff, $10, $09, $00, $02, $0f, $e6, $c7, $19, $ea, $0c, $9f, $16, $ff
	db $a1, $ff, $60, $09, $00, $00, $fb, $0c, $ff, $07, $ff, $80, $09, $04, $21, $09
	db $ff, $f1, $bf, $60, $09, $3e, $0f, $0f, $09, $00, $08

;@ path: gfx/monsters/pictures
;@ Picture of Skullroo (species $33): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $112 packed).
MonPic_Skullroo::
	db $40, $02, $05, $ff, $05
	db $ff, $ff, $4d, $05, $1d, $0f, $09, $01, $ff, $02, $05, $1c, $06, $fe, $80, $7e
	db $c2, $7c, $c7, $05, $1c, $07, $e0, $3f, $e0, $ff, $20, $05, $1c, $0f, $1d, $f9
	db $00, $ff, $04, $ff, $04, $fe, $04, $fe, $04, $fd, $07, $fe, $03, $fe, $03, $7b
	db $cc, $77, $d8, $7f, $d0, $6b, $f0, $77, $e1, $5d, $f3, $f7, $ee, $cf, $f8, $ff
	db $40, $ff, $40, $ff, $80, $ff, $80, $05, $44, $0f, $27, $fe, $0f, $f1, $1f, $fb
	db $2e, $ea, $2a, $f1, $13, $f0, $17, $e1, $7d, $5f, $f7, $38, $bf, $24, $fd, $92
	db $fe, $88, $fe, $08, $bb, $88, $e9, $10, $91, $ff, $80, $7f, $e0, $1f, $f0, $0f
	db $f8, $07, $f4, $07, $fc, $03, $fa, $03, $7e, $05, $1c, $06, $dd, $1c, $c1, $5d
	db $80, $e0, $05, $1c, $0b, $80, $ff, $03, $05, $dc, $00, $ff, $01, $05, $1c, $04
	db $87, $f7, $1e, $bf, $7f, $e7, $fa, $8f, $f8, $0d, $fa, $1f, $ea, $3e, $e9, $3b
	db $60, $e0, $9f, $9f, $2a, $f1, $77, $40, $48, $64, $f7, $bf, $ff, $77, $eb, $bf
	db $03, $5f, $01, $4d, $91, $b5, $49, $fd, $49, $d9, $e9, $b9, $c9, $c9, $52, $13
	db $0f, $cf, $1f, $b0, $3f, $20, $3f, $60, $7f, $c0, $ff, $c0, $7f, $40, $3f, $20
	db $05, $f6, $0f, $0d, $e4, $3d, $f2, $1a, $fd, $1d, $fc, $23, $ff, $47, $ff, $78
	db $05, $1c, $00, $d8, $db, $68, $d4, $95, $c1, $ff, $ff, $05, $1c, $04, $e2, $f3
	db $44, $67, $9e, $99, $e3, $ff, $f7, $78, $ff, $0f, $05, $1c, $00, $3f, $20, $3f
	db $20, $7f, $c0, $ff, $80, $ff, $40, $ff, $c0, $05, $1c, $0f, $01

;@ path: gfx/monsters/pictures
;@ Picture of WindBeast (species $34): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $199 packed).
MonPic_WindBeast::
	db $40, $02, $05
	db $ff, $05, $ff, $f4, $06, $fd, $07, $fe, $03, $ff, $01, $ff, $00, $ff, $20, $df
	db $70, $df, $73, $dc, $77, $d9, $7f, $d3, $fe, $07, $fc, $05, $00, $05, $80, $ff
	db $60, $9f, $f0, $ef, $78, $05, $00, $03, $01, $fe, $03, $ff, $0d, $f3, $1e, $ef
	db $3c, $ff, $00, $ff, $08, $f7, $1c, $f7, $9c, $77, $dc, $37, $fd, $96, $ff, $c1
	db $7f, $05, $00, $05, $c0, $7f, $c0, $ff, $80, $05, $34, $00, $05, $34, $02, $fc
	db $07, $fc, $07, $fc, $04, $ff, $03, $07, $fe, $c9, $ff, $3d, $37, $7f, $73, $4e
	db $ff, $80, $ff, $0c, $0f, $fe, $ff, $f7, $1f, $f8, $0d, $f0, $f9, $66, $f0, $87
	db $ba, $b6, $f9, $cf, $ff, $d0, $ff, $df, $f0, $3f, $61, $1f, $3f, $cd, $1f, $c2
	db $bb, $da, $3f, $e6, $ff, $16, $ff, $e1, $ff, $27, $fe, $79, $d9, $fc, $9d, $e4
	db $ff, $02, $ff, $60, $e0, $ff, $ff, $05, $22, $04, $7f, $c0, $7f, $c0, $7f, $40
	db $05, $5c, $01, $05, $ff, $f4, $01, $ff, $02, $ff, $04, $ca, $7f, $b6, $da, $f9
	db $8f, $ff, $47, $ff, $b0, $e8, $9b, $7f, $c0, $bf, $7f, $6f, $ff, $27, $b4, $17
	db $1c, $f3, $f7, $f8, $7b, $e7, $1f, $f8, $07, $ff, $00, $ec, $ff, $c8, $5a, $d1
	db $71, $9f, $df, $3f, $bc, $ce, $f1, $3f, $c0, $ff, $00, $a7, $fe, $dd, $b3, $3f
	db $e0, $ff, $c1, $fe, $0f, $13, $9c, $ff, $03, $84, $67, $05, $24, $03, $80, $ff
	db $40, $ff, $05, $bd, $00, $40, $ff, $04, $ff, $02, $05, $0e, $01, $05, $ff, $f3
	db $d8, $3f, $e7, $1f, $fe, $c1, $ff, $7c, $e3, $9f, $fc, $63, $ff, $1c, $ff, $03
	db $fe, $fe, $87, $f8, $70, $f1, $ff, $00, $fe, $fe, $07, $f8, $ff, $00, $ff, $ff
	db $0f, $30, $fe, $01, $7f, $80, $ff, $00, $03, $1c, $ff, $00, $ff, $03, $fc, $ff
	db $f9, $06, $07, $f8, $ff, $01, $0f, $ce, $ff, $01, $f7, $0e, $ff, $fc, $3f, $c4
	db $ff, $20, $bf, $60, $ff, $c0, $05, $c0, $07, $05, $77, $1c, $05, $23, $14, $01
	db $05, $ca, $02, $c0, $3f, $f8, $f9, $f8, $47, $b3, $f4, $e0, $1f, $f8, $86, $0f
	db $90, $cf, $3f, $01, $ff, $ff, $00, $1f, $e7, $8f, $49, $ff, $06, $7f, $78, $05
	db $74, $11, $f8, $05, $be, $09, $05, $c5, $1f, $0f, $03, $05, $76, $1a, $9f, $a4
	db $e7, $9b, $ff, $7c, $fd, $07, $ff, $02, $ff, $07, $ff, $08, $05, $22, $05, $05
	db $13, $22, $05, $c5, $1f, $10

;@ path: gfx/monsters/pictures
;@ Picture of Anteater (species $35): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $142 packed).
MonPic_Anteater::
	db $40, $02, $02, $ff, $02, $ff, $ff, $4d, $02, $5f
	db $0f, $4d, $02, $6d, $08, $07, $fe, $03, $02, $6c, $09, $80, $ff, $40, $02, $6c
	db $05, $03, $fd, $07, $f8, $0d, $f0, $1a, $02, $6c, $01, $2e, $f7, $ff, $aa, $ff
	db $55, $ff, $0b, $5f, $04, $ed, $02, $6c, $03, $c0, $ff, $80, $ff, $70, $bf, $e1
	db $ff, $f2, $02, $6c, $09, $e0, $ff, $40, $ff, $01, $ff, $07, $fe, $09, $ff, $1f
	db $fd, $07, $ff, $0b, $ff, $1c, $ff, $10, $7f, $b0, $cf, $f8, $87, $8d, $b2, $b7
	db $78, $7b, $f1, $f1, $e1, $21, $f1, $11, $e0, $3f, $c0, $da, $4e, $ff, $dd, $f3
	db $be, $b2, $dc, $6d, $bc, $f4, $fb, $07, $01, $fb, $01, $e5, $00, $df, $00, $f5
	db $00, $af, $01, $bf, $89, $bf, $08, $3f, $0e, $3d, $93, $df, $61, $71, $4d, $ed
	db $9c, $dc, $1d, $dd, $0b, $8b, $04, $07, $02, $08, $10, $ef, $98, $bf, $7c, $ff
	db $c0, $ff, $20, $ff, $d0, $7f, $70, $ff, $0f, $fe, $11, $f7, $2e, $ff, $29, $ff
	db $11, $ff, $01, $02, $6c, $00, $f2, $13, $ff, $8e, $7f, $c2, $fe, $43, $ff, $43
	db $bf, $62, $df, $bd, $ff, $43, $ec, $1c, $dc, $34, $b8, $6c, $f0, $5f, $e0, $bf
	db $e0, $ff, $a0, $ef, $10, $f3, $08, $38, $04, $7c, $03, $ff, $00, $f6, $00, $fb
	db $00, $df, $00, $f4, $00, $b0, $08, $0c, $30, $37, $c0, $ca, $00, $0f, $07, $1f
	db $08, $02, $6c, $00, $0e, $3f, $a0, $ff, $f0, $3f, $a0, $1f, $50, $7f, $f8, $bf
	db $e0, $5f, $70, $7f, $70, $02, $6c, $0d, $3d, $02, $ca, $00, $fd, $08, $ff, $1d
	db $ff, $06, $02, $6c, $00, $0c, $4c, $8f, $8f, $70, $f0, $67, $4f, $ff, $b8, $ff
	db $c0, $02, $6c, $00, $03, $03, $ff, $fd, $ff, $81, $02, $6c, $06, $c0, $dc, $01
	db $01, $0e, $3f, $e0, $f8, $ff, $19, $ff, $07, $02, $d8, $03, $c0, $bf, $f0, $9f
	db $08, $ff, $bc, $ff, $60, $02, $6c, $00

;@ path: gfx/monsters/pictures
;@ Picture of SuperTen (species $36): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $112 packed).
MonPic_SuperTen::
	db $40, $02, $06, $ff, $06, $ff, $ff, $4d
	db $06, $2b, $0f, $18, $fd, $3c, $fd, $41, $06, $2c, $01, $60, $ff, $10, $ff, $08
	db $06, $98, $01, $78, $06, $2c, $0f, $24, $14, $ff, $2a, $ff, $22, $ff, $41, $f7
	db $2e, $ff, $80, $e6, $89, $e2, $85, $32, $00, $da, $62, $ed, $31, $f5, $19, $fa
	db $7c, $bf, $cf, $80, $f6, $80, $be, $60, $ef, $b8, $3e, $84, $b7, $74, $0c, $b3
	db $83, $ff, $00, $ff, $80, $ff, $b8, $ff, $c4, $7f, $42, $7f, $42, $7f, $40, $ff
	db $e0, $06, $2c, $0f, $0d, $fb, $1f, $fd, $0b, $ff, $08, $fe, $05, $ff, $03, $fe
	db $05, $fe, $05, $ff, $08, $f6, $c4, $b6, $64, $ab, $76, $61, $ef, $e0, $a6, $7c
	db $1d, $86, $02, $e3, $1d, $cd, $4b, $7d, $bc, $00, $00, $fc, $02, $f9, $fe, $8e
	db $4f, $07, $f5, $0b, $2e, $7f, $90, $ff, $08, $3f, $48, $3f, $08, $ef, $18, $1f
	db $f0, $ff, $e0, $ff, $b0, $06, $6c, $0f, $0e, $0a, $fe, $08, $ff, $10, $f9, $27
	db $fe, $3f, $ff, $05, $ff, $04, $ff, $04, $84, $02, $78, $01, $bc, $7a, $46, $fd
	db $83, $be, $83, $8a, $c2, $43, $a2, $63, $ff, $f3, $7b, $11, $11, $9f, $4f, $3f
	db $7f, $38, $77, $4c, $57, $bf, $be, $ed, $ff, $88, $ff, $10, $7f, $88, $bf, $f0
	db $ff, $40, $06, $00, $11, $80, $06, $2c, $0f, $0e, $02, $ff, $01, $ff, $0f, $ff
	db $12, $fe, $1d, $ff, $03, $06, $2c, $00, $1f, $ff, $cf, $f8, $ef, $18, $7f, $e8
	db $ff, $a8, $ff, $10, $06, $88, $01, $ab, $fb, $87, $ff, $80, $e7, $5f, $ff, $38
	db $06, $2c, $05, $80, $ff, $40, $06, $ce, $1f, $07

;@ path: gfx/monsters/pictures
;@ Picture of IronTurt (species $37): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1A2 packed).
MonPic_IronTurt::
	db $40, $02, $09, $ff, $09, $ff
	db $ff, $19, $02, $ff, $82, $09, $00, $0b, $08, $09, $00, $0f, $1a, $09, $ff, $f2
	db $21, $ff, $31, $ef, $39, $ef, $25, $d7, $3b, $f1, $15, $f2, $91, $ff, $85, $fd
	db $87, $7d, $ca, $78, $cd, $70, $38, $32, $fa, $d2, $df, $bf, $bd, $ff, $08, $ff
	db $0c, $f7, $9c, $f7, $9c, $77, $e5, $67, $fe, $5c, $dd, $ea, $ec, $ff, $00, $ff
	db $20, $ff, $60, $bf, $e0, $bf, $20, $5f, $e0, $7f, $40, $7f, $48, $09, $00, $0f
	db $08, $06, $fd, $05, $fe, $02, $f9, $cf, $be, $ee, $dc, $7c, $ce, $56, $e3, $29
	db $f3, $31, $c9, $cf, $77, $f7, $07, $05, $e8, $ea, $e8, $ed, $08, $08, $08, $0d
	db $0d, $0f, $07, $07, $3f, $3f, $04, $07, $bb, $bb, $b9, $b9, $83, $83, $86, $84
	db $86, $84, $04, $07, $e7, $e7, $ff, $98, $ef, $b8, $df, $f0, $9f, $50, $3f, $a0
	db $7f, $63, $bd, $bd, $73, $7a, $09, $00, $0d, $03, $fc, $0d, $f0, $30, $c7, $40
	db $ef, $87, $98, $88, $df, $8a, $f8, $9f, $f7, $f7, $cb, $2b, $16, $26, $8b, $12
	db $c3, $0a, $e1, $81, $be, $c0, $c0, $ff, $dd, $e0, $7d, $80, $72, $8f, $9f, $df
	db $ff, $ff, $ff, $ff, $f1, $f6, $e6, $f6, $df, $3f, $f6, $0e, $72, $8a, $cd, $db
	db $fe, $f9, $fa, $f9, $7f, $fd, $fd, $3f, $77, $74, $5f, $58, $1f, $1f, $1b, $1a
	db $b9, $bd, $fc, $f4, $7e, $fb, $dd, $67, $09, $00, $01, $80, $7f, $c0, $ff, $40
	db $ff, $c0, $bf, $20, $3f, $60, $ff, $67, $ef, $30, $f0, $1f, $ff, $0f, $fd, $10
	db $fd, $10, $f2, $11, $f9, $0f, $bf, $7f, $f2, $0e, $3f, $fd, $f5, $f8, $9c, $ce
	db $b6, $8f, $83, $fb, $ec, $2f, $39, $7a, $ac, $01, $41, $77, $e9, $e9, $df, $3f
	db $3f, $80, $81, $fd, $fe, $fe, $1e, $7f, $5e, $df, $79, $7f, $d2, $fd, $42, $b8
	db $45, $3e, $fe, $ff, $79, $87, $ff, $23, $62, $bf, $fc, $ff, $0f, $2b, $1b, $90
	db $18, $33, $d4, $18, $98, $ff, $3f, $20, $bf, $60, $bf, $38, $ff, $14, $bf, $fc
	db $7f, $40, $ff, $60, $5f, $d0, $fe, $06, $fc, $04, $ff, $1c, $ff, $29, $ff, $76
	db $ff, $1b, $09, $00, $00, $7f, $13, $ef, $18, $ff, $88, $cf, $38, $ff, $f0, $09
	db $00, $02, $02, $ff, $ff, $fd, $09, $00, $08, $07, $fe, $ff, $f8, $09, $00, $08
	db $f7, $7f, $f8, $0c, $fd, $06, $fe, $03, $fe, $03, $ff, $01, $09, $00, $00, $9f
	db $b0, $0f, $9c, $7f, $1a, $ef, $34, $7f, $de, $09, $f8, $12

;@ path: gfx/monsters/pictures
;@ Picture of Mommonja (species $38): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $119 packed).
MonPic_Mommonja::
	db $40, $02, $05, $ff
	db $05, $ff, $ff, $4d, $05, $5f, $0f, $4d, $05, $75, $0f, $01, $01, $ff, $01, $fe
	db $02, $fc, $04, $fc, $1c, $e2, $3e, $ff, $80, $ff, $80, $7f, $40, $7f, $40, $3f
	db $20, $1f, $10, $1f, $1c, $23, $3e, $05, $74, $0f, $07, $f7, $07, $f0, $17, $e0
	db $3f, $05, $74, $06, $bf, $80, $3f, $a0, $1f, $d0, $05, $d0, $06, $fe, $07, $f8
	db $0f, $f8, $0f, $c1, $7f, $80, $e2, $08, $40, $1d, $c9, $0b, $c2, $07, $e4, $0b
	db $fc, $37, $f8, $41, $7f, $80, $a3, $88, $81, $dc, $c9, $e8, $21, $70, $13, $68
	db $1f, $76, $0f, $ff, $00, $05, $e2, $01, $c0, $3f, $a0, $3e, $f0, $0f, $f9, $0f
	db $f9, $80, $19, $c0, $70, $06, $26, $8f, $e9, $9f, $d1, $1f, $51, $1f, $90, $3f
	db $a0, $1f, $f0, $0f, $c8, $0f, $08, $05, $74, $12, $9f, $90, $ff, $60, $f0, $1f
	db $f1, $1f, $f0, $17, $f8, $1b, $f7, $17, $f7, $1c, $f7, $17, $f8, $0f, $5f, $e0
	db $ff, $c0, $7f, $ff, $7f, $ef, $ff, $b0, $ef, $6f, $c0, $70, $c0, $ff, $fd, $03
	db $ff, $01, $ff, $ff, $ff, $fb, $ff, $06, $fb, $fb, $01, $07, $01, $ff, $04, $f4
	db $c6, $f7, $04, $f7, $0c, $ee, $f4, $f4, $f5, $15, $f7, $76, $8f, $e8, $3f, $a0
	db $3f, $20, $05, $e4, $00, $ff, $80, $05, $74, $0f, $03, $f8, $0b, $fc, $04, $ff
	db $1b, $fe, $25, $fd, $3b, $ff, $05, $4f, $10, $05, $fe, $f0, $bf, $00, $00, $ff
	db $ff, $bf, $70, $ff, $c0, $05, $ec, $11, $fb, $00, $ec, $05, $f4, $10, $fe, $07
	db $ff, $01, $05, $74, $00, $0f, $08, $1f, $10, $7f, $6c, $bf, $d2, $df, $6e, $ff
	db $f8, $05, $74, $0f, $11

;@ path: gfx/monsters/pictures
;@ Picture of HammerMan (species $39): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $13E packed).
MonPic_HammerMan::
	db $40, $02, $05, $ff, $05, $ff, $ff, $4d, $05, $5f, $0f
	db $4d, $05, $7b, $0f, $07, $01, $fe, $03, $fc, $07, $05, $7a, $01, $10, $ef, $38
	db $c7, $f4, $07, $b4, $03, $f2, $01, $f9, $05, $d0, $09, $02, $fe, $03, $05, $7a
	db $01, $0f, $f0, $3e, $c0, $f1, $01, $8f, $0e, $3e, $70, $f0, $05, $7a, $01, $80
	db $7f, $e0, $1f, $10, $ff, $e0, $bf, $a0, $bf, $a0, $05, $d0, $0a, $fe, $03, $f8
	db $0f, $f0, $1f, $f0, $1f, $e0, $3f, $e3, $7f, $87, $fc, $0f, $f8, $0f, $f8, $01
	db $f9, $00, $fc, $05, $42, $10, $8e, $fe, $d9, $77, $fc, $23, $fc, $8b, $ff, $83
	db $7f, $40, $7f, $40, $3f, $20, $1f, $10, $1f, $10, $8f, $89, $86, $87, $a8, $ec
	db $88, $dc, $04, $2e, $c4, $6e, $c4, $6e, $c2, $56, $a0, $f4, $10, $f5, $bf, $a0
	db $3f, $28, $b7, $bc, $23, $3e, $17, $16, $53, $52, $1f, $1c, $2f, $28, $fc, $07
	db $fd, $07, $ff, $06, $ff, $04, $ff, $08, $05, $88, $10, $f6, $7d, $07, $9c, $e3
	db $ef, $d0, $37, $a8, $78, $d7, $ef, $bc, $7f, $63, $ff, $5c, $df, $fd, $73, $8e
	db $fe, $0f, $8f, $71, $7d, $8f, $ff, $7e, $f1, $ff, $80, $07, $f8, $78, $7f, $f0
	db $98, $8f, $7f, $95, $7d, $c5, $bd, $45, $fd, $3b, $fa, $13, $f2, $10, $1b, $e0
	db $eb, $f0, $1a, $f0, $1e, $f0, $1a, $f1, $1b, $f5, $3f, $ef, $3f, $2f, $28, $2f
	db $28, $17, $94, $57, $d6, $4f, $ce, $2b, $ea, $33, $f2, $c7, $e4, $8b, $fb, $b3
	db $f3, $cf, $4c, $ff, $71, $ff, $02, $ff, $05, $ff, $01, $e7, $f8, $9f, $e0, $bf
	db $c0, $df, $60, $b0, $7f, $ff, $ff, $05, $7a, $00, $f0, $0f, $fc, $03, $fe, $01
	db $f8, $07, $00, $ff, $05, $fa, $12, $0b, $fa, $0f, $fc, $1f, $f0, $2f, $f8, $c7
	db $fc, $ff, $fc, $05, $fc, $11, $1f, $ff, $0f, $05, $7a, $08, $1f, $d8, $ff, $e0
	db $05, $7a, $08

;@ path: gfx/monsters/pictures
;@ Picture of Grizzly (species $3A): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $189 packed).
MonPic_Grizzly::
	db $40, $02, $11, $ff, $11, $ff, $f4, $1a, $ff, $0d, $ff, $77, $f8
	db $3f, $11, $00, $05, $11, $ff, $f0, $80, $ff, $80, $11, $10, $09, $11, $21, $0f
	db $0d, $01, $ff, $01, $11, $00, $05, $58, $ff, $b0, $ff, $ee, $1f, $fc, $f6, $de
	db $ef, $7f, $ef, $3f, $ee, $ff, $f0, $1f, $fe, $0f, $f8, $0b, $f8, $0a, $7f, $c0
	db $11, $70, $00, $3f, $e0, $1f, $f3, $1c, $ff, $10, $ff, $10, $ff, $11, $00, $05
	db $f8, $07, $ff, $03, $ff, $3c, $11, $7f, $06, $1f, $e0, $ff, $c0, $ff, $3c, $ff
	db $fe, $03, $11, $a0, $00, $fc, $07, $f8, $cf, $38, $ff, $08, $ff, $08, $ff, $6f
	db $7a, $f7, $fe, $f7, $fc, $77, $fe, $0f, $f8, $7f, $f0, $1f, $d0, $1f, $50, $f8
	db $09, $fc, $05, $fc, $04, $fe, $02, $11, $4e, $04, $00, $ff, $00, $77, $00, $b7
	db $08, $0b, $c4, $c7, $fc, $3f, $fc, $07, $fc, $07, $38, $ef, $36, $ff, $46, $fc
	db $87, $ff, $8b, $ff, $89, $ff, $c9, $ff, $47, $fe, $1c, $f7, $6c, $ff, $62, $3f
	db $e1, $ff, $d1, $ff, $91, $ff, $93, $ff, $e2, $7f, $00, $ff, $00, $ee, $00, $ed
	db $10, $d0, $23, $e3, $3f, $fc, $3f, $e0, $3f, $e0, $1f, $90, $3f, $a0, $3f, $20
	db $7f, $40, $11, $1e, $0f, $05, $fc, $05, $fc, $05, $fe, $02, $fe, $06, $fd, $07
	db $f8, $0b, $f8, $0f, $f0, $17, $27, $fd, $17, $ff, $0f, $ef, $07, $f5, $07, $7e
	db $05, $c7, $02, $f3, $01, $fd, $e4, $bf, $e8, $ff, $f0, $f7, $e0, $af, $b0, $1e
	db $b0, $d3, $a0, $e7, $e0, $bf, $3f, $a0, $3f, $a0, $7f, $40, $7f, $60, $bf, $e0
	db $1f, $d0, $1f, $f0, $0f, $e8, $11, $20, $0f, $0d, $f0, $1f, $f0, $17, $f0, $13
	db $e8, $3e, $c0, $7f, $80, $bf, $80, $bf, $80, $9f, $11, $ff, $f5, $2f, $80, $81
	db $70, $f0, $0f, $cf, $e0, $bf, $11, $b0, $10, $40, $ff, $00, $f4, $01, $41, $0e
	db $0f, $f0, $f3, $0f, $f8, $0f, $e8, $0f, $e8, $17, $5c, $03, $fe, $01, $fd, $01
	db $fd, $01, $f9, $11, $20, $0f, $0d, $c0, $4b, $f0, $30, $ef, $7f, $fa, $ff, $ff
	db $3f, $ff, $0c, $11, $00, $00, $3f, $b0, $5f, $50, $0f, $48, $7f, $f0, $11, $1e
	db $04, $fc, $0d, $fa, $0a, $f0, $12, $fe, $0f, $11, $4e, $04, $03, $d2, $0f, $0c
	db $f7, $fe, $5f, $ff, $ff, $fc, $ff, $30, $11, $20, $0f, $01

;@ path: gfx/monsters/pictures
;@ Picture of Yeti (species $3B): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked by
;@ LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1D2 packed).
MonPic_Yeti::
	db $40, $02, $09, $ff
	db $09, $ff, $f2, $03, $fc, $07, $fd, $35, $cd, $7d, $c4, $4c, $09, $00, $03, $00
	db $ff, $80, $ff, $20, $df, $70, $9f, $d0, $09, $10, $05, $09, $ff, $f2, $06, $09
	db $20, $0b, $60, $09, $10, $05, $01, $ff, $04, $fb, $0e, $f9, $0b, $09, $00, $03
	db $c0, $3f, $e0, $bf, $ac, $b3, $be, $23, $32, $e0, $60, $90, $d0, $87, $87, $fb
	db $7c, $f3, $1c, $09, $68, $02, $3f, $20, $ff, $c0, $ff, $60, $ff, $10, $ff, $0d
	db $ff, $03, $ff, $02, $ff, $05, $ff, $1d, $ff, $22, $ff, $70, $ff, $80, $ff, $c0
	db $f6, $07, $ef, $0d, $ef, $0a, $ff, $b8, $ff, $44, $ff, $0e, $ff, $01, $ff, $03
	db $6f, $e0, $f7, $b0, $f7, $50, $fc, $04, $ff, $03, $ff, $06, $ff, $08, $ff, $b0
	db $ff, $c0, $ff, $40, $ff, $a0, $07, $04, $0b, $0a, $e3, $e2, $df, $3c, $cf, $38
	db $09, $b8, $02, $f1, $1a, $f1, $1e, $f0, $1b, $f8, $0e, $f8, $0d, $fc, $06, $fe
	db $03, $ff, $01, $ff, $06, $ff, $04, $ff, $04, $7f, $06, $7f, $82, $3f, $71, $7f
	db $c0, $ff, $80, $ff, $0d, $c7, $0b, $bf, $3c, $bf, $33, $df, $1f, $f4, $06, $fc
	db $06, $fc, $07, $ff, $b0, $e3, $d0, $fd, $3c, $fd, $cc, $fb, $f8, $2f, $60, $3f
	db $60, $3f, $60, $ff, $60, $ff, $20, $ff, $20, $fe, $60, $fe, $41, $fc, $8e, $09
	db $cc, $00, $8f, $58, $8f, $78, $0f, $d8, $1f, $70, $1f, $b0, $3f, $60, $09, $dc
	db $01, $01, $09, $7a, $01, $04, $09, $d0, $00, $fe, $08, $09, $2e, $0d, $00, $fc
	db $07, $f8, $0f, $09, $42, $13, $0e, $f8, $0e, $f8, $0f, $3f, $60, $1f, $70, $09
	db $52, $13, $f0, $09, $5a, $10, $09, $30, $1c, $09, $86, $00, $ff, $40, $ff, $20
	db $09, $00, $10, $7f, $10, $ff, $60, $ff, $04, $fd, $07, $fe, $03, $fe, $03, $ff
	db $07, $f8, $1e, $e0, $38, $e0, $40, $7f, $00, $ff, $00, $df, $00, $d5, $80, $b7
	db $c0, $a5, $f0, $61, $7c, $18, $1f, $fc, $07, $ff, $03, $09, $00, $00, $7f, $00
	db $d7, $00, $7d, $00, $17, $40, $3f, $e0, $ff, $c0, $09, $00, $00, $fe, $00, $eb
	db $00, $be, $00, $e8, $02, $fe, $00, $ff, $00, $fb, $00, $ab, $01, $ed, $03, $a5
	db $0f, $86, $3e, $18, $f8, $ff, $20, $bf, $e0, $7f, $c0, $7f, $c0, $ff, $e0, $1f
	db $78, $07, $1c, $07, $02, $cf, $4f, $fe, $33, $fe, $04, $09, $a0, $01, $09, $ff
	db $f1, $0e, $cf, $01, $01, $71, $79, $eb, $b2, $e7, $24, $ff, $18, $09, $00, $00
	db $00, $d5, $c0, $f9, $fc, $fe, $09, $e8, $14, $ff, $00, $00, $6b, $03, $5f, $3f
	db $bf, $09, $b2, $12, $09, $00, $00, $70, $f3, $80, $80, $8e, $9e, $d7, $4d, $09
	db $f8, $14, $f3, $f2, $7f, $cc, $7f, $20, $09, $70, $01, $09, $0b, $21

;@ path: gfx/monsters/pictures
;@ Picture of MadGopher (species $3C): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $E8 packed).
MonPic_MadGopher::
	db $40, $02
	db $05, $ff, $05, $ff, $ff, $4d, $05, $3d, $0f, $29, $01, $fc, $05, $3d, $06, $70
	db $ff, $88, $ff, $04, $f9, $05, $3d, $0f, $28, $ed, $0c, $a1, $2d, $80, $bf, $ff
	db $02, $f9, $00, $ff, $04, $05, $f4, $02, $7f, $04, $7f, $47, $ff, $02, $fc, $00
	db $df, $01, $af, $01, $a7, $09, $a5, $0b, $a1, $0f, $07, $cf, $05, $7c, $0f, $0f
	db $fe, $03, $fa, $07, $fc, $05, $35, $13, $fe, $03, $05, $3d, $04, $c0, $ff, $a1
	db $ff, $e1, $ad, $61, $ed, $3f, $a0, $1f, $d0, $17, $d8, $0f, $e8, $cf, $e8, $4f
	db $e8, $cf, $68, $9f, $df, $df, $d8, $df, $50, $05, $62, $14, $ff, $70, $ff, $a8
	db $05, $80, $0f, $0b, $ff, $01, $ff, $03, $fc, $0f, $f4, $1f, $e8, $3f, $e9, $ef
	db $f8, $9f, $f8, $2f, $ec, $3f, $00, $de, $e1, $ed, $12, $92, $ff, $ff, $4c, $de
	db $80, $05, $3c, $01, $30, $bf, $c9, $cf, $09, $09, $c7, $c7, $a7, $e4, $47, $c4
	db $07, $c4, $0f, $c8, $ff, $b8, $ff, $a8, $cf, $78, $7f, $f0, $df, $d0, $05, $66
	db $13, $05, $3d, $0f, $0c, $9c, $f7, $fe, $7e, $f3, $1f, $f0, $22, $ff, $33, $ff
	db $1c, $05, $3c, $00, $05, $3d, $01, $3e, $c0, $c0, $ff, $3f, $05, $3c, $02, $0f
	db $88, $1f, $1c, $33, $36, $c3, $d1, $ff, $33, $ff, $0e, $05, $3c, $00, $05, $64
	db $15, $20, $05, $3c, $0f, $03

;@ path: gfx/monsters/pictures
;@ Picture of FairyRat (species $3D): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $F4 packed).
MonPic_FairyRat::
	db $40, $02, $06, $ff, $06, $ff, $ff, $4d, $06, $11
	db $0d, $fb, $38, $fb, $42, $3f, $01, $fe, $80, $ff, $80, $fd, $82, $fe, $80, $06
	db $12, $04, $7f, $00, $ff, $80, $ff, $40, $ff, $40, $ff, $00, $ff, $01, $ff, $02
	db $ff, $04, $ff, $04, $ff, $08, $fe, $09, $fd, $10, $ff, $f0, $ff, $08, $ff, $04
	db $f9, $00, $ff, $02, $06, $a8, $03, $06, $11, $0f, $07, $06, $93, $00, $02, $fe
	db $80, $3c, $03, $dc, $63, $e6, $39, $f8, $ff, $ff, $07, $ff, $00, $fc, $03, $7f
	db $a0, $ff, $a0, $7f, $d0, $3f, $ef, $1f, $f0, $ff, $f0, $2f, $e0, $34, $e2, $f8
	db $13, $f8, $2f, $f0, $5f, $f1, $9e, $a0, $7f, $ef, $3f, $50, $3f, $a8, $1f, $f9
	db $00, $f7, $0c, $ef, $1b, $9f, $7c, $6f, $f0, $9f, $e0, $3f, $c0, $06, $12, $03
	db $06, $8b, $02, $40, $3f, $06, $89, $00, $02, $ff, $01, $06, $12, $0a, $fc, $03
	db $83, $bf, $bf, $3d, $ff, $03, $ff, $05, $06, $22, $10, $39, $e9, $5b, $f0, $90
	db $d7, $7b, $ff, $fe, $bf, $ff, $95, $ff, $09, $fe, $03, $8c, $3f, $0b, $7f, $94
	db $ff, $7f, $ff, $ff, $fb, $ad, $df, $d5, $cf, $af, $67, $7d, $81, $07, $fe, $ff
	db $f8, $bf, $f0, $ff, $78, $ff, $50, $ff, $10, $06, $12, $0f, $20, $03, $ff, $02
	db $ff, $05, $ff, $0a, $ff, $0c, $ff, $10, $ff, $20, $ff, $00, $77, $3e, $bf, $fc
	db $f7, $f0, $06, $12, $0f, $4d, $06, $e0, $1f, $17

;@ path: gfx/monsters/pictures
;@ Picture of Unicorn (species $3E): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1A3 packed).
MonPic_Unicorn::
	db $40, $02, $06, $ff, $06, $ff
	db $f5, $f9, $1a, $f7, $07, $fa, $03, $06, $00, $06, $06, $00, $01, $c0, $06, $00
	db $05, $01, $fe, $62, $fc, $c5, $fc, $cd, $ff, $00, $fb, $38, $e3, $e2, $f1, $13
	db $f8, $c9, $f8, $88, $f9, $99, $e9, $eb, $ff, $00, $ff, $20, $ff, $10, $ff, $18
	db $ef, $bc, $cb, $de, $53, $f6, $53, $f7, $06, $10, $07, $60, $ff, $c0, $ff, $80
	db $ff, $01, $06, $10, $0a, $3f, $71, $af, $9d, $f3, $67, $d4, $39, $fb, $08, $fe
	db $07, $f9, $09, $fa, $1a, $77, $5f, $34, $3c, $98, $98, $cf, $cf, $38, $b8, $10
	db $73, $f3, $37, $cc, $cf, $49, $4b, $f2, $b6, $f2, $d6, $b4, $fd, $98, $fa, $5f
	db $ff, $a0, $bf, $60, $ff, $6f, $ef, $50, $d3, $63, $e7, $45, $4d, $89, $99, $8b
	db $9a, $73, $f3, $14, $f4, $ff, $80, $7f, $c0, $bf, $e0, $ff, $60, $ff, $20, $06
	db $1c, $00, $3f, $06, $b9, $00, $06, $25, $01, $06, $26, $01, $02, $ff, $07, $fc
	db $04, $fc, $05, $fd, $f7, $cf, $ce, $e7, $36, $f3, $fa, $11, $75, $e8, $f8, $c4
	db $e7, $a3, $bb, $be, $ff, $a1, $ff, $db, $fe, $b7, $fc, $c7, $7b, $c4, $fb, $00
	db $ff, $a0, $ff, $1f, $f0, $9f, $f0, $df, $b0, $ff, $98, $75, $9e, $fd, $22, $08
	db $f9, $0b, $fb, $85, $7d, $c5, $3d, $e5, $1d, $e7, $1e, $e9, $1f, $e0, $1f, $1f
	db $d0, $df, $f0, $7f, $70, $7f, $50, $06, $5c, $01, $00, $ff, $80, $ff, $0c, $ff
	db $08, $06, $10, $08, $d7, $7f, $e8, $3c, $e4, $b7, $f3, $5b, $fc, $7c, $e1, $3d
	db $fe, $1e, $fe, $0f, $45, $7a, $4f, $70, $4a, $75, $df, $b8, $b7, $d8, $ff, $c3
	db $3f, $25, $3f, $fe, $fe, $61, $5f, $f8, $87, $fc, $93, $ee, $bb, $e7, $1c, $f3
	db $3f, $f2, $1f, $f2, $e6, $19, $6e, $b1, $5e, $e1, $9e, $e1, $3f, $c2, $7f, $83
	db $cf, $35, $87, $7e, $ff, $80, $06, $70, $15, $06, $11, $0a, $06, $21, $05, $06
	db $10, $0a, $d3, $ee, $ff, $45, $ff, $44, $ff, $29, $cf, $79, $86, $ff, $87, $86
	db $8e, $8a, $8f, $ff, $df, $a8, $ff, $97, $7f, $90, $8f, $79, $ff, $99, $6f, $f8
	db $ef, $08, $9f, $64, $bf, $c4, $bb, $ce, $8b, $fd, $9f, $69, $ff, $09, $ff, $92
	db $ff, $92, $06, $7a, $1f, $04, $06, $d1, $1f, $07, $71, $06, $10, $0a, $1f, $17
	db $fb, $ee, $f1, $16, $f7, $10, $f3, $10, $f8, $08, $ff, $07, $ff, $00, $63, $be
	db $23, $e2, $e7, $24, $7f, $d8, $7f, $06, $19, $12, $06, $7b, $1d

;@ path: gfx/monsters/pictures
;@ Picture of Goategon (species $3F): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $105 packed).
MonPic_Goategon::
	db $40, $02, $0a
	db $ff, $0a, $ff, $ff, $4d, $0a, $5f, $0f, $4d, $0a, $75, $0f, $02, $f7, $07, $f6
	db $10, $f1, $2b, $ef, $4e, $dd, $54, $ff, $03, $fe, $0e, $f2, $12, $e8, $a8, $f0
	db $f0, $78, $08, $6e, $06, $0d, $65, $ff, $80, $ff, $e0, $9f, $90, $2f, $2b, $1e
	db $1e, $3d, $21, $ed, $c0, $61, $4c, $0a, $76, $02, $df, $c0, $df, $10, $1f, $a8
	db $ef, $e4, $77, $54, $0a, $76, $0f, $00, $01, $0a, $76, $08, $bc, $e5, $fe, $c4
	db $fc, $07, $fe, $06, $fd, $05, $f8, $08, $f9, $09, $fd, $0d, $08, $a8, $7c, $7c
	db $68, $e8, $0c, $5c, $16, $de, $ff, $fb, $75, $93, $b6, $1f, $20, $2b, $7c, $7c
	db $2c, $2f, $60, $74, $d1, $f7, $fe, $be, $5d, $93, $db, $f1, $7b, $4e, $ff, $47
	db $7f, $c0, $ff, $c0, $7f, $40, $3f, $20, $3f, $20, $7f, $60, $0a, $76, $0f, $0d
	db $f9, $09, $f8, $08, $fc, $0c, $fc, $04, $fc, $04, $fe, $06, $fe, $02, $ff, $03
	db $f8, $8b, $fc, $87, $df, $a7, $dd, $e6, $57, $6b, $27, $30, $9b, $9c, $85, $86
	db $3f, $a3, $7e, $c2, $f6, $ca, $76, $4e, $d4, $ac, $c8, $18, $b2, $72, $43, $c3
	db $0a, $6a, $12, $7f, $40, $7f, $40, $ff, $c0, $ff, $80, $ff, $80, $0a, $76, $0f
	db $0d, $fe, $03, $0a, $f0, $10, $ff, $03, $ff, $07, $0a, $22, $12, $c2, $c3, $51
	db $d1, $34, $b4, $7d, $4d, $ff, $83, $0a, $76, $02, $86, $87, $14, $17, $58, $5b
	db $7d, $65, $ff, $83, $0a, $22, $13, $0a, $cd, $10, $0a, $cd, $10, $c0, $0a, $76
	db $0f, $03

;@ path: gfx/monsters/pictures
;@ Picture of WildApe (species $40): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $184 packed).
MonPic_WildApe::
	db $40, $02, $04, $ff, $04, $ff, $f6, $03, $fc, $07, $f8, $0b, $04, $00
	db $07, $c0, $3f, $f0, $0f, $a8, $04, $00, $07, $04, $21, $0f, $22, $f8, $09, $ff
	db $07, $04, $00, $05, $01, $fe, $03, $07, $f4, $87, $ec, $c7, $7c, $c7, $74, $cf
	db $78, $8f, $e8, $1f, $d0, $3f, $a1, $04, $00, $07, $01, $fe, $f7, $0d, $ff, $04
	db $00, $05, $38, $e7, $ec, $53, $f7, $01, $fd, $04, $20, $09, $80, $7f, $e0, $04
	db $20, $0c, $04, $0c, $00, $f9, $0f, $f1, $17, $f3, $1e, $e3, $2e, $e3, $2e, $e3
	db $26, $7e, $c3, $fc, $87, $fc, $0f, $f0, $1f, $e0, $25, $c0, $5d, $c0, $7b, $84
	db $9e, $07, $fe, $02, $ff, $02, $ff, $01, $04, $e5, $00, $fd, $01, $ff, $01, $f9
	db $81, $f7, $80, $fb, $bb, $fb, $dd, $e6, $d9, $fd, $7f, $d6, $4f, $db, $bf, $cd
	db $1f, $f0, $8f, $f8, $87, $bc, $87, $bc, $23, $fe, $a3, $fe, $93, $de, $d3, $5e
	db $04, $20, $0c, $e3, $26, $f1, $13, $f1, $11, $f9, $09, $fe, $07, $fc, $04, $29
	db $11, $84, $bd, $84, $fc, $82, $fa, $02, $fa, $01, $f1, $01, $f1, $01, $e1, $1c
	db $dc, $01, $fd, $04, $40, $11, $bd, $01, $9f, $01, $1f, $00, $1e, $80, $bf, $fe
	db $b1, $bf, $ef, $7f, $57, $59, $7f, $df, $ce, $2e, $31, $a1, $af, $9e, $9e, $53
	db $de, $d3, $de, $d1, $5f, $a1, $af, $a0, $af, $c0, $c7, $40, $47, $80, $87, $04
	db $a4, $06, $ff, $80, $7f, $40, $3f, $e0, $04, $2a, $11, $05, $fe, $02, $fe, $04
	db $e4, $00, $00, $ff, $00, $03, $bf, $00, $7e, $00, $ff, $00, $fe, $00, $3c, $80
	db $80, $f8, $78, $81, $81, $80, $bf, $04, $a0, $11, $9f, $40, $5f, $40, $4f, $e0
	db $a7, $e0, $e7, $41, $41, $47, $c6, $3f, $f8, $27, $a4, $27, $e4, $2f, $e8, $2f
	db $ae, $39, $7f, $c0, $c3, $c0, $43, $e0, $23, $f0, $11, $fc, $1c, $e4, $3c, $fa
	db $26, $f7, $1d, $1f, $b0, $1f, $d0, $1f, $f0, $1f, $f0, $1f, $d8, $3f, $28, $5f
	db $78, $ff, $90, $04, $20, $0c, $9f, $9f, $8c, $bf, $f3, $7f, $ff, $0e, $04, $00
	db $04, $20, $e7, $f0, $f0, $9f, $ef, $cf, $7a, $f3, $3f, $ff, $0c, $04, $00, $00
	db $67, $fe, $ff, $dc, $df, $70, $7f, $e0, $ff, $80, $04, $00, $03, $0c, $ff, $03
	db $04, $20, $09, $04, $af, $0b

;@ path: gfx/monsters/pictures
;@ Picture of Trumpeter (species $41): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1E8 packed).
MonPic_Trumpeter::
	db $40, $02, $0d, $ff, $00, $ff, $01, $fe, $07, $f8
	db $0f, $f8, $0f, $f8, $1f, $e0, $3f, $e0, $3f, $ff, $00, $f7, $f0, $05, $f4, $01
	db $cd, $08, $fb, $04, $fd, $02, $fe, $01, $ff, $0d, $00, $01, $03, $fc, $04, $f8
	db $9b, $e1, $af, $42, $de, $24, $7d, $ff, $00, $ff, $80, $7f, $c0, $3f, $61, $1e
	db $fb, $86, $ff, $42, $ff, $24, $fe, $ff, $00, $ff, $3f, $c0, $ff, $00, $cf, $40
	db $df, $80, $bf, $80, $ff, $80, $0d, $1f, $00, $c0, $7f, $c0, $ff, $80, $ff, $e0
	db $1f, $f0, $1f, $f0, $0f, $e8, $c0, $5f, $c0, $7f, $0d, $4a, $00, $c0, $7f, $c0
	db $5f, $e0, $3f, $e0, $2f, $00, $fe, $0d, $ff, $f0, $0d, $72, $01, $f8, $07, $f7
	db $18, $ff, $ac, $ff, $98, $bb, $50, $77, $61, $6d, $43, $5a, $61, $7f, $d0, $ff
	db $78, $6e, $35, $fd, $19, $f9, $0a, $fa, $86, $be, $c2, $de, $86, $ee, $0b, $ef
	db $1e, $77, $00, $7f, $00, $7f, $0d, $ff, $f0, $30, $0d, $43, $00, $ff, $00, $ff
	db $0d, $07, $00, $0f, $e8, $0d, $5a, $00, $1f, $f0, $0d, $07, $00, $0d, $b7, $00
	db $0d, $0c, $00, $e0, $3f, $fc, $1f, $fc, $07, $fc, $07, $00, $ff, $00, $fe, $0d
	db $d2, $00, $01, $ff, $02, $ff, $02, $ff, $01, $f9, $58, $5d, $80, $b7, $80, $a6
	db $d0, $ff, $20, $ec, $20, $eb, $e0, $e6, $10, $f5, $1a, $bb, $01, $ef, $03, $2f
	db $09, $ff, $08, $3b, $0b, $db, $0f, $7c, $0b, $dc, $0d, $72, $02, $80, $ff, $40
	db $ff, $47, $ff, $9b, $9c, $ef, $70, $0d, $07, $00, $3f, $f8, $3f, $e0, $1f, $d0
	db $df, $f0, $ff, $30, $ff, $08, $ff, $03, $fd, $0e, $f7, $18, $fd, $21, $f5, $4c
	db $2f, $18, $df, $b0, $ff, $a0, $fe, $ff, $e3, $1c, $ff, $00, $9f, $a0, $a0, $3f
	db $f9, $19, $f6, $17, $f0, $13, $90, $71, $88, $68, $9c, $7c, $23, $e3, $40, $43
	db $80, $83, $30, $33, $08, $89, $19, $fe, $04, $ff, $02, $3f, $81, $91, $41, $cd
	db $21, $ef, $2d, $ef, $32, $fe, $f8, $07, $01, $ff, $7b, $fe, $87, $b4, $07, $cc
	db $03, $fa, $47, $e1, $5e, $4e, $3f, $c4, $c9, $d0, $d7, $1a, $ff, $0a, $ff, $06
	db $ff, $06, $ff, $02, $ff, $80, $ff, $c0, $0d, $4b, $01, $0d, $72, $05, $f0, $13
	db $f8, $0b, $fc, $04, $f8, $0b, $f8, $09, $f8, $08, $f8, $0b, $f0, $11, $14, $d4
	db $13, $d3, $30, $f1, $28, $68, $46, $46, $47, $c5, $47, $cc, $27, $fc, $23, $37
	db $c2, $e6, $59, $fb, $55, $f7, $55, $55, $e2, $b2, $f2, $1a, $fe, $0c, $d0, $d0
	db $61, $61, $47, $46, $3f, $78, $3f, $20, $3f, $a0, $1f, $d0, $3f, $90, $0d, $84
	db $18, $0d, $d2, $1f, $01, $f0, $12, $fa, $10, $ff, $0f, $0d, $86, $16, $27, $6c
	db $a3, $36, $c1, $c7, $e1, $ef, $e3, $25, $e7, $32, $ff, $1c, $ff, $00, $fe, $02
	db $ff, $01, $0d, $d2, $19, $20, $ff, $0d, $aa, $02, $0d, $d3, $1f, $04

;@ path: gfx/monsters/pictures
;@ Picture of KingLeo (species $42): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $232 packed).
MonPic_KingLeo::
	db $40, $02
	db $14, $ff, $00, $ff, $0e, $ff, $19, $ff, $15, $ff, $36, $e8, $df, $ef, $bf, $ff
	db $bf, $ff, $14, $ff, $f0, $61, $ff, $90, $ff, $3b, $fc, $ac, $ff, $d3, $ff, $e3
	db $ff, $00, $ff, $04, $ff, $f6, $cd, $4d, $e5, $e5, $22, $22, $12, $12, $80, $80
	db $ff, $00, $ff, $40, $ff, $df, $67, $64, $4f, $4f, $88, $88, $91, $91, $03, $03
	db $14, $10, $01, $0d, $ff, $13, $ff, $b8, $7e, $6b, $ff, $97, $ff, $8f, $ff, $00
	db $ff, $e0, $ff, $30, $ff, $50, $ff, $d8, $2f, $f6, $ef, $fa, $ff, $fa, $fe, $5e
	db $f8, $0f, $f8, $17, $f8, $17, $f0, $2f, $14, $68, $01, $1f, $fc, $9c, $f8, $e8
	db $fc, $5c, $e0, $60, $c0, $40, $b0, $b0, $e0, $e0, $40, $c0, $14, $fc, $f0, $0c
	db $0c, $1e, $12, $3d, $23, $7e, $58, $6e, $5c, $7f, $6b, $14, $fc, $f0, $60, $60
	db $f0, $90, $78, $88, $fc, $34, $ec, $74, $fc, $ac, $7e, $72, $3e, $2f, $7e, $75
	db $0e, $0d, $06, $05, $1a, $1b, $0e, $0f, $04, $07, $ff, $f4, $3f, $e0, $3f, $d0
	db $3f, $d0, $1f, $e8, $14, $b8, $01, $f0, $f8, $0f, $ff, $07, $ff, $01, $ff, $0f
	db $ff, $11, $ff, $75, $ff, $9b, $f7, $df, $80, $80, $01, $01, $31, $31, $61, $61
	db $e0, $a0, $c0, $40, $d0, $d0, $e0, $60, $ff, $9c, $ff, $07, $ff, $03, $71, $8f
	db $8f, $ff, $7a, $75, $2d, $37, $3f, $37, $fe, $72, $ff, $c1, $ff, $81, $1d, $e3
	db $e2, $fe, $bc, $5c, $68, $d8, $f8, $d8, $02, $03, $01, $01, $19, $19, $0d, $0d
	db $0f, $0b, $07, $05, $17, $17, $0f, $0d, $3f, $e0, $ff, $c0, $14, $50, $01, $10
	db $ff, $5c, $ff, $b2, $df, $f6, $ef, $bf, $ef, $7e, $fc, $9f, $fc, $af, $fe, $73
	db $ff, $05, $ff, $08, $f7, $18, $e0, $20, $c0, $40, $c0, $40, $44, $c4, $6c, $ec
	db $fc, $b4, $bc, $64, $fe, $42, $3f, $3f, $1d, $17, $1c, $1f, $1c, $18, $1b, $1c
	db $1f, $1f, $1f, $17, $0f, $08, $f8, $f8, $70, $d0, $70, $f0, $70, $30, $b0, $70
	db $f0, $f0, $f0, $d0, $e0, $20, $0f, $09, $07, $04, $06, $05, $44, $47, $6c, $6f
	db $7f, $5b, $7b, $4c, $ff, $84, $ef, $fa, $ef, $fc, $7f, $f2, $7f, $ea, $ff, $9c
	db $ff, $40, $ff, $20, $df, $30, $ff, $10, $ff, $10, $f7, $18, $f8, $0f, $fc, $07
	db $ff, $03, $fe, $3b, $fe, $47, $be, $c2, $fe, $82, $ff, $81, $fc, $83, $78, $c7
	db $20, $ff, $1f, $ff, $3e, $e3, $07, $04, $83, $83, $c0, $c0, $a0, $e0, $1c, $fc
	db $8e, $ba, $0f, $79, $1f, $f0, $c0, $40, $82, $82, $07, $07, $0a, $0f, $70, $7f
	db $e2, $bb, $e1, $3d, $f0, $1f, $fb, $86, $ff, $82, $ff, $02, $7e, $83, $3c, $c7
	db $09, $ff, $f0, $ff, $f8, $8f, $14, $80, $10, $df, $30, $3f, $e0, $7f, $c0, $ff
	db $80, $ff, $b8, $ff, $c4, $ff, $a0, $ef, $fa, $ff, $b7, $ff, $19, $ff, $01, $ff
	db $01, $14, $10, $00, $3c, $e7, $ff, $7f, $a7, $d8, $57, $f1, $ff, $6a, $ff, $ae
	db $ff, $11, $ff, $00, $3f, $e0, $3f, $e0, $bf, $60, $ff, $20, $ff, $14, $d9, $10
	db $00, $ff, $00, $f8, $0f, $f9, $0f, $fb, $0c, $ff, $09, $ff, $06, $ff, $02, $14
	db $ea, $10, $79, $ce, $ff, $fc, $cb, $37, $d5, $1f, $ff, $ad, $ff, $eb, $ff, $10
	db $ff, $00, $ff, $0a, $ef, $be, $ff, $da, $ff, $30, $14, $10, $01, $00, $ff, $00
;@ path: gfx/monsters/pictures
;@ Picture of DarkHorn (species $43): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1DE packed).
MonPic_DarkHorn::
	db $40, $02, $0a, $ff, $0a, $ff, $f0, $01, $ff, $02, $fe, $05, $f2, $00, $fd, $0b
	db $fd, $09, $ff, $00, $7b, $7c, $4f, $2e, $3f, $b0, $7f, $40, $ff, $80, $0a, $1a
	db $01, $0a, $ff, $f2, $0a, $01, $01, $fe, $17, $e8, $2f, $0a, $20, $07, $00, $ff
	db $d0, $2f, $e8, $ff, $00, $bd, $7c, $e5, $e9, $f9, $1a, $fc, $05, $fe, $02, $ff
	db $03, $ff, $03, $0a, $20, $03, $80, $ff, $40, $9f, $00, $7f, $a0, $7f, $20, $fb
	db $0f, $fb, $0b, $fb, $0b, $fd, $05, $fd, $0a, $49, $00, $01, $ff, $00, $ff, $c0
	db $ff, $e0, $df, $de, $d1, $c9, $cf, $d0, $e3, $e4, $78, $78, $ff, $ff, $e3, $37
	db $e7, $ec, $9f, $b8, $ef, $f0, $f7, $18, $d7, $38, $3f, $20, $fb, $c4, $8f, $d8
	db $cf, $6e, $f3, $3a, $ef, $1f, $df, $30, $d7, $38, $f8, $08, $bf, $47, $ff, $07
	db $ff, $0f, $f7, $f7, $17, $27, $e7, $17, $8e, $4e, $3d, $3d, $ff, $fe, $bf, $e0
	db $bf, $a0, $bf, $a0, $7f, $40, $0a, $18, $01, $0a, $21, $07, $0a, $c6, $01, $0a
	db $ff, $f0, $3e, $c7, $75, $8c, $e9, $0c, $d9, $0c, $bb, $27, $3d, $c7, $f7, $ca
	db $ed, $fd, $30, $ff, $eb, $7e, $ee, $b4, $dd, $b9, $ca, $49, $fa, $30, $71, $90
	db $f0, $7f, $18, $ff, $af, $fc, $ef, $5a, $77, $3a, $a7, $25, $bf, $19, $1d, $12
	db $1f, $ff, $f8, $c7, $5c, $63, $2e, $61, $37, $61, $bb, $c9, $79, $c7, $de, $a7
	db $6e, $0a, $30, $09, $0a, $c3, $04, $0a, $31, $07, $5f, $50, $ae, $b1, $a5, $b3
	db $ef, $78, $d6, $5d, $d5, $5e, $eb, $36, $65, $6b, $90, $bc, $d0, $d2, $ec, $2c
	db $f3, $1b, $50, $be, $7f, $ef, $f8, $04, $91, $ed, $13, $7a, $16, $97, $6f, $69
	db $9f, $b0, $14, $fb, $fd, $ee, $3f, $40, $13, $6f, $f5, $15, $eb, $1b, $4b, $9a
	db $ef, $3c, $d7, $74, $57, $f4, $af, $d8, $4f, $a8, $0a, $10, $1f, $00, $02, $fd
	db $06, $ff, $04, $fd, $06, $ff, $02, $fe, $03, $ff, $01, $6f, $10, $ff, $00, $fd
	db $02, $fc, $01, $ed, $13, $72, $8d, $51, $23, $87, $be, $66, $fe, $d8, $3b, $fc
	db $03, $ff, $00, $bf, $40, $5a, $f5, $24, $df, $85, $93, $cd, $fe, $37, $b8, $7f
	db $80, $fe, $01, $fb, $05, $b4, $5f, $49, $f7, $43, $93, $ed, $14, $fd, $01, $7f
	db $80, $7f, $00, $6f, $90, $8f, $70, $1c, $e3, $00, $5e, $0a, $52, $04, $ff, $40
	db $7f, $c0, $0a, $da, $10, $ff, $00, $ff, $03, $fe, $04, $fd, $09, $ff, $0e, $0a
	db $4e, $02, $c1, $4d, $99, $e7, $e3, $de, $df, $5c, $ff, $e0, $0a, $1e, $02, $f1
	db $76, $ef, $2f, $f8, $18, $fe, $06, $0a, $22, $14, $1f, $dd, $ee, $eb, $3e, $33
	db $ff, $c1, $0a, $22, $14, $c0, $fa, $27, $d7, $7f, $84, $3f, $c3, $0d, $7c, $de
	db $f2, $ff, $3b, $ff, $06, $0a, $1e, $05, $0a, $d5, $10, $c0, $ff, $00

;@ path: gfx/monsters/pictures
;@ Picture of MadCat (species $44): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $16B packed).
MonPic_MadCat::
	db $40, $02
	db $02, $ff, $02, $ff, $ff, $0b, $05, $02, $00, $03, $01, $fe, $23, $fc, $6f, $90
	db $ff, $00, $6f, $02, $00, $03, $80, $ff, $80, $ff, $a0, $ff, $e0, $3f, $e0, $02
	db $00, $0f, $0c, $02, $ff, $fc, $01, $ff, $0d, $f6, $1e, $f4, $1c, $e2, $2f, $c1
	db $4f, $c1, $4f, $c0, $df, $40, $57, $00, $5d, $00, $db, $00, $f3, $00, $b5, $38
	db $bb, $7c, $cf, $7e, $f3, $7f, $db, $7f, $c0, $7f, $c0, $7f, $c4, $bb, $af, $b1
	db $ff, $07, $d7, $0f, $59, $9f, $d5, $02, $00, $09, $80, $ff, $40, $02, $5e, $0f
	db $00, $01, $fe, $03, $fe, $03, $ff, $0f, $ff, $09, $fd, $07, $ff, $07, $00, $07
	db $80, $85, $80, $81, $e3, $e3, $d7, $f5, $9f, $fa, $63, $f7, $77, $d5, $7f, $c1
	db $3f, $f4, $7f, $d0, $ff, $a6, $fb, $fe, $f9, $ce, $d5, $7f, $f9, $3f, $ff, $70
	db $ff, $49, $ff, $9a, $fe, $43, $fa, $37, $e7, $bf, $ee, $bb, $ff, $1d, $ff, $60
	db $ff, $20, $ff, $30, $ff, $a8, $ff, $38, $ff, $24, $ef, $96, $2f, $f5, $02, $00
	db $07, $60, $9f, $f4, $1f, $fc, $fe, $0b, $fd, $0b, $fd, $17, $f8, $17, $fd, $1b
	db $fe, $1b, $f7, $1e, $f7, $2e, $be, $f7, $7f, $9c, $6b, $9c, $94, $ff, $f7, $63
	db $ff, $3e, $d5, $7f, $ff, $dd, $fd, $ae, $fe, $5f, $fc, $57, $fe, $87, $f9, $4f
	db $bb, $6e, $ff, $3c, $ff, $a0, $ff, $82, $ff, $22, $ff, $92, $2f, $f5, $df, $f5
	db $cf, $74, $df, $68, $bf, $c8, $ef, $f6, $ff, $25, $ff, $ec, $ff, $52, $ff, $f6
	db $ff, $fc, $02, $00, $00, $07, $7c, $8f, $a8, $8f, $88, $ff, $70, $02, $00, $04
	db $fb, $4e, $fd, $27, $f9, $17, $e3, $07, $eb, $1d, $fd, $0a, $ff, $08, $ff, $0c
	db $ff, $e3, $ff, $5d, $ff, $41, $ff, $22, $ff, $1c, $02, $36, $01, $40, $ff, $a1
	db $ff, $46, $fe, $0b, $fe, $0f, $ff, $07, $02, $00, $03, $8c, $ff, $52, $ff, $d6
	db $bf, $d4, $ff, $f8, $02, $40, $0f, $14, $18, $ff, $26, $ff, $39, $ef, $3d, $fb
	db $1d, $ff, $06, $02, $00, $01, $30, $ff, $c8, $ff, $38, $ff, $78, $bf, $60, $ff
	db $c0, $02, $40, $0f, $1c, $02, $ff, $ff, $02

;@ path: gfx/monsters/pictures
;@ Picture of BigEye (species $45): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1BC packed).
MonPic_BigEye::
	db $40, $02, $09, $ff, $09, $ff, $ff
	db $01, $03, $ff, $02, $ff, $02, $fe, $03, $fe, $03, $fc, $09, $ff, $f4, $80, $7f
	db $c0, $9f, $00, $7f, $26, $b9, $1f, $09, $00, $03, $01, $fe, $03, $f9, $00, $fe
	db $64, $9d, $f8, $09, $00, $01, $c0, $ff, $40, $ff, $40, $7f, $c0, $7f, $c0, $3f
	db $09, $ff, $ff, $03, $09, $ff, $f8, $01, $09, $70, $02, $fe, $07, $f8, $0f, $f1
	db $3f, $c1, $7f, $fc, $5f, $b0, $7f, $c0, $7c, $c3, $7b, $87, $f4, $8f, $e8, $16
	db $f8, $1d, $f0, $3f, $fa, $0d, $fe, $03, $3e, $c3, $de, $e1, $2f, $f1, $17, $68
	db $1f, $b8, $0f, $ff, $80, $09, $a0, $02, $7f, $e0, $1f, $f0, $8f, $fc, $83, $fe
	db $09, $5e, $0f, $05, $09, $1a, $00, $fd, $07, $fe, $07, $80, $ff, $00, $ff, $86
	db $ff, $01, $09, $00, $01, $0f, $ff, $10, $df, $1d, $f1, $15, $f9, $0e, $f8, $07
	db $fc, $83, $ff, $40, $ff, $c2, $ff, $61, $fd, $b8, $8f, $a8, $9f, $70, $1f, $e0
	db $3f, $c1, $ff, $02, $ff, $43, $ff, $86, $bf, $09, $d6, $00, $61, $ff, $09, $d0
	db $00, $00, $ff, $f0, $ff, $08, $fb, $09, $24, $00, $09, $a4, $01, $c0, $7f, $c0
	db $bf, $e0, $7f, $e0, $fe, $02, $fc, $04, $fd, $05, $fe, $02, $ff, $03, $fd, $05
	db $fc, $04, $fc, $04, $00, $bf, $09, $ff, $f1, $7e, $01, $7f, $41, $7d, $81, $a1
	db $a3, $a3, $18, $fe, $04, $09, $16, $00, $09, $70, $02, $bf, $82, $97, $18, $7f
	db $20, $09, $46, $00, $09, $a0, $02, $fd, $41, $e9, $00, $fd, $09, $32, $12, $80
	db $fe, $82, $be, $81, $85, $c5, $c5, $7f, $40, $3f, $20, $bf, $a0, $7f, $40, $ff
	db $c0, $bf, $a0, $3f, $20, $3f, $20, $f8, $0c, $f9, $0d, $f9, $0f, $f9, $0b, $fc
	db $0f, $fc, $05, $fe, $06, $ff, $03, $fc, $fc, $00, $00, $10, $93, $20, $af, $a0
	db $bf, $a0, $bf, $30, $3f, $20, $3f, $ff, $fd, $f6, $bf, $5e, $57, $0a, $ef, $09
	db $44, $10, $02, $fe, $82, $fe, $ff, $bf, $6f, $fd, $7a, $ea, $50, $f7, $09, $54
	db $10, $40, $7f, $41, $7f, $3f, $3f, $00, $00, $08, $c9, $04, $f5, $05, $fd, $05
	db $fd, $0c, $fc, $04, $fc, $1f, $30, $9f, $b0, $9f, $f0, $9f, $d0, $3f, $f0, $3f
	db $a0, $7f, $60, $ff, $c0, $09, $00, $0c, $e9, $ff, $f0, $3f, $f8, $1b, $e7, $3f
	db $fe, $2b, $ff, $11, $09, $00, $00, $02, $fa, $06, $de, $39, $7f, $ef, $fd, $7f
	db $ea, $ff, $50, $09, $05, $10, $40, $5f, $60, $7b, $9c, $fe, $f7, $bf, $fe, $57
	db $ff, $0a, $09, $d5, $00, $97, $ff, $0f, $fc, $1f, $d8, $e7, $fc, $7f, $d4, $ff
	db $88, $09, $00, $0f, $01

;@ path: gfx/monsters/pictures
;@ Picture of Picky (species $46): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked by
;@ LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $174 packed).
MonPic_Picky::
	db $40, $02, $08, $ff, $08, $ff, $ff, $0e, $df, $40, $ff
	db $30, $ff, $18, $e7, $14, $df, $ea, $bf, $75, $fc, $1d, $08, $00, $05, $40, $ff
	db $20, $ff, $30, $f7, $90, $08, $00, $0f, $0f, $08, $00, $09, $01, $ff, $03, $ff
	db $00, $ff, $0e, $fb, $16, $f5, $2f, $ef, $5f, $fb, $9c, $6f, $b2, $fb, $ee, $d9
	db $fb, $f7, $2d, $fb, $16, $fc, $0b, $fe, $9d, $ff, $7e, $ff, $ff, $6f, $48, $ff
	db $4c, $bb, $6a, $fb, $be, $df, $bb, $f9, $5d, $a9, $1b, $c3, $11, $08, $00, $01
	db $c0, $ff, $a0, $ff, $50, $ff, $e8, $ff, $14, $fb, $4e, $08, $5e, $0f, $00, $02
	db $ff, $02, $ff, $05, $fe, $04, $fe, $05, $ff, $04, $fd, $06, $ff, $47, $ff, $8f
	db $ff, $8f, $ff, $1f, $08, $d6, $00, $ef, $1f, $ef, $1f, $f1, $f7, $fd, $fc, $ff
	db $ff, $ff, $ff, $fe, $fe, $08, $e4, $00, $ff, $ff, $d7, $8d, $f7, $4d, $7f, $05
	db $db, $e1, $6e, $f0, $de, $b1, $f5, $ca, $ed, $f0, $75, $cf, $bd, $e7, $ba, $e7
	db $38, $75, $58, $d5, $50, $df, $50, $5f, $a0, $bf, $08, $00, $01, $80, $08, $14
	db $17, $02, $fe, $03, $ff, $01, $08, $00, $06, $d7, $3f, $0f, $c3, $3f, $e1, $bf
	db $a0, $ff, $60, $ff, $20, $ff, $10, $ff, $10, $08, $e6, $00, $fc, $fc, $fd, $7c
	db $c5, $3d, $f4, $0c, $fe, $02, $dd, $03, $fa, $f7, $32, $3a, $9e, $1f, $d9, $99
	db $d4, $94, $a1, $21, $5c, $5c, $eb, $f7, $a1, $ff, $51, $ff, $53, $7e, $93, $fa
	db $97, $f4, $bf, $f8, $bf, $e0, $7f, $c0, $08, $00, $0f, $0d, $f9, $22, $fe, $23
	db $fd, $23, $fc, $13, $f8, $0f, $ff, $07, $08, $00, $00, $ee, $21, $73, $95, $8d
	db $fd, $63, $ef, $1c, $fd, $bf, $fb, $cf, $48, $7f, $f7, $c9, $f5, $41, $d9, $63
	db $7b, $a3, $b3, $66, $e6, $ee, $ea, $ff, $33, $ff, $00, $7f, $dc, $bb, $be, $57
	db $56, $f5, $f7, $7f, $5e, $ff, $c0, $bf, $60, $bf, $e0, $08, $00, $0f, $0d, $fe
	db $0f, $ff, $1f, $f8, $13, $f2, $2e, $ef, $3f, $ff, $30, $08, $00, $00, $da, $fb
	db $5d, $dd, $e7, $ef, $e7, $b2, $fb, $1e, $ff, $06, $08, $10, $12, $7f, $c0, $ff
	db $80, $08, $00, $07, $40, $08, $00, $0f, $0b

;@ path: gfx/monsters/pictures
;@ Picture of Wyvern (species $47): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $136 packed).
MonPic_Wyvern::
	db $40, $02, $02, $ff, $02, $ff, $ff
	db $27, $60, $ff, $60, $ff, $c0, $02, $00, $09, $03, $ff, $03, $02, $00, $0b, $80
	db $02, $00, $0f, $04, $01, $fe, $03, $fd, $0e, $fb, $0c, $ff, $1b, $02, $74, $00
	db $ff, $01, $ff, $c3, $ff, $22, $fe, $17, $7f, $15, $7d, $17, $ff, $c0, $ff, $80
	db $02, $92, $01, $c0, $ff, $c0, $7f, $e1, $7f, $e3, $ff, $03, $ff, $07, $ff, $07
	db $fe, $0f, $fd, $1e, $fb, $7c, $f7, $fb, $cd, $fe, $ff, $80, $7f, $e0, $bf, $d0
	db $ff, $10, $ff, $60, $bf, $d0, $7f, $90, $ff, $60, $02, $74, $02, $ff, $07, $ff
	db $04, $02, $00, $02, $f7, $1d, $da, $df, $21, $ef, $87, $ff, $f9, $79, $f3, $13
	db $fe, $1f, $fe, $07, $7f, $97, $bf, $cc, $b9, $ce, $bf, $d6, $6f, $f1, $7b, $fd
	db $e7, $be, $e5, $b0, $ff, $e3, $ff, $67, $7f, $27, $df, $3f, $fe, $1f, $df, $1f
	db $fe, $1f, $fd, $3f, $9e, $fd, $e7, $ff, $1d, $fe, $e7, $ff, $1b, $fc, $ed, $fe
	db $17, $fb, $fb, $fe, $ff, $c0, $7f, $a0, $bf, $02, $3d, $00, $02, $93, $00, $02
	db $ff, $ff, $00, $fd, $0f, $fb, $0e, $fb, $0e, $ff, $0c, $02, $00, $03, $70, $ef
	db $30, $fb, $10, $ff, $0f, $f8, $08, $fb, $0c, $f1, $10, $e6, $38, $cf, $c0, $be
	db $7f, $7b, $ff, $fc, $bf, $ff, $1f, $3f, $1f, $df, $1f, $7f, $be, $7f, $7e, $2f
	db $f4, $ff, $f8, $bf, $d0, $02, $be, $01, $02, $61, $0f, $07, $06, $fd, $05, $02
	db $34, $11, $08, $ff, $00, $af, $df, $b0, $0a, $fb, $e0, $ff, $fc, $ff, $7f, $ff
	db $3f, $ff, $1f, $ff, $07, $67, $90, $fb, $00, $7d, $01, $bf, $07, $ff, $02, $a8
	db $12, $fc, $ff, $7c, $ff, $fc, $ff, $f8, $ff, $f0, $ff, $e0, $02, $3e, $0b, $02
	db $ff, $ff, $15, $01, $02, $00, $0b, $f0, $02, $00, $0f, $28, $00, $ff, $00

;@ path: gfx/monsters/pictures
;@ Picture of BullBird (species $48): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $156 packed).
MonPic_BullBird::
	db $40
	db $02, $06, $ff, $06, $ff, $ff, $4d, $06, $25, $0f, $11, $01, $fe, $07, $f9, $1f
	db $e2, $3f, $c4, $7f, $90, $ff, $ff, $00, $ff, $70, $cf, $fc, $83, $fe, $01, $06
	db $24, $03, $06, $24, $07, $80, $7f, $c0, $7f, $e0, $06, $24, $0f, $00, $0e, $f9
	db $17, $f2, $29, $cc, $5e, $de, $7f, $be, $ef, $fb, $d7, $ff, $01, $ff, $07, $f8
	db $1f, $e0, $bf, $40, $ff, $47, $ff, $88, $ff, $10, $ff, $60, $ff, $80, $ff, $00
	db $ff, $08, $ff, $10, $ff, $14, $ff, $94, $f7, $08, $06, $24, $09, $10, $ff, $10
	db $df, $3f, $f1, $2e, $ff, $11, $ff, $1f, $fe, $0f, $f8, $87, $fc, $83, $fe, $83
	db $fe, $ff, $e0, $ff, $f0, $ef, $08, $f7, $04, $ff, $1c, $e7, $2c, $c3, $56, $c3
	db $6e, $f2, $e7, $ea, $bf, $dc, $76, $fd, $6f, $fb, $4b, $ff, $05, $ff, $08, $ff
	db $08, $10, $ff, $80, $ff, $ce, $ff, $dd, $73, $ff, $ed, $f6, $9b, $ee, $33, $fd
	db $23, $08, $ff, $08, $fb, $04, $fc, $03, $06, $24, $00, $bf, $00, $3f, $40, $5f
	db $e0, $ff, $21, $ff, $11, $7f, $8a, $8f, $7a, $ff, $04, $ff, $04, $ff, $c4, $ff
	db $81, $fd, $01, $ff, $00, $fe, $00, $fe, $00, $fc, $01, $fd, $01, $f9, $03, $f2
	db $e3, $2a, $f7, $1c, $ff, $b8, $ff, $80, $06, $e1, $01, $06, $f8, $01, $f3, $2c
	db $fb, $2c, $f3, $2c, $ef, $31, $f3, $1d, $fc, $0f, $ff, $03, $dd, $63, $fb, $47
	db $f6, $4f, $ae, $db, $0f, $f9, $7f, $f1, $fe, $83, $fe, $83, $41, $7f, $82, $9a
	db $47, $47, $3f, $3c, $0f, $88, $1f, $d0, $3f, $a0, $3f, $20, $04, $75, $02, $22
	db $07, $05, $8f, $88, $ff, $70, $06, $24, $02, $07, $e4, $0f, $e8, $0f, $68, $87
	db $b4, $87, $f4, $8f, $b8, $cf, $58, $e7, $2c, $06, $64, $0f, $10, $03, $ff, $07
	db $f8, $0a, $ff, $1f, $06, $24, $02, $7f, $40, $3f, $20, $ff, $e0, $ff, $c0, $06
	db $24, $0f, $05, $e7, $2c, $c3, $5e, $ff, $7f, $e0, $2d, $fa, $1e, $ff, $07, $06
	db $a0, $08, $06, $76, $14

;@ path: gfx/monsters/pictures
;@ Picture of Florajay (species $49): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $15F packed).
MonPic_Florajay::
	db $40, $02, $06, $ff, $06, $ff, $ff, $19, $02, $fd, $05
	db $06, $00, $09, $80, $7f, $40, $06, $00, $0f, $0e, $10, $ef, $38, $e7, $3c, $f3
	db $1e, $f1, $77, $c8, $7b, $e4, $3d, $f3, $1f, $06, $00, $05, $07, $f8, $d8, $20
	db $e3, $30, $70, $f8, $08, $f0, $12, $f0, $14, $e0, $2c, $e0, $a8, $60, $69, $20
	db $a1, $10, $d4, $3f, $20, $3f, $20, $1f, $10, $1f, $10, $1f, $17, $18, $18, $30
	db $36, $20, $28, $06, $00, $05, $81, $7e, $67, $18, $1f, $21, $3d, $06, $60, $00
	db $cf, $78, $9f, $f0, $1f, $dc, $27, $bc, $4f, $78, $9f, $f0, $f8, $3b, $e6, $3e
	db $f1, $1f, $f8, $0b, $fe, $1e, $f1, $1f, $fc, $0c, $ff, $03, $c0, $c0, $40, $c0
	db $e0, $e0, $10, $d1, $3c, $3c, $db, $d7, $3a, $3e, $c4, $c5, $39, $39, $56, $6f
	db $7b, $5e, $4f, $f9, $75, $7b, $9a, $96, $2e, $f6, $36, $ae, $c0, $d0, $a0, $60
	db $e0, $ac, $a0, $67, $d8, $d8, $07, $37, $02, $0b, $01, $85, $36, $37, $08, $0e
	db $1f, $1f, $20, $27, $d8, $f8, $57, $b7, $b8, $7f, $47, $c7, $3f, $b8, $cf, $f8
	db $1f, $f0, $3f, $a0, $ff, $f0, $1f, $d0, $7f, $60, $ff, $80, $fe, $03, $ff, $01
	db $06, $00, $08, $1c, $dd, $fc, $e4, $fc, $04, $fd, $05, $ff, $6b, $ff, $9a, $ff
	db $6b, $ff, $12, $3a, $2a, $3b, $2b, $2b, $3b, $2c, $3f, $ad, $ae, $eb, $ec, $dd
	db $be, $7a, $fb, $01, $81, $01, $41, $01, $01, $87, $87, $67, $e6, $9f, $7a, $b3
	db $7f, $5d, $de, $f0, $f0, $ff, $0f, $ff, $00, $ff, $40, $ff, $ac, $ff, $b2, $ff
	db $ac, $df, $b0, $ff, $80, $06, $00, $0f, $0c, $0b, $fb, $0e, $f7, $1c, $ff, $18
	db $06, $00, $04, $ed, $ad, $dd, $7d, $fb, $6b, $fb, $cf, $f5, $9f, $f5, $1f, $eb
	db $3f, $f6, $7f, $d7, $d7, $5f, $5c, $5b, $7e, $5f, $76, $5f, $f2, $5f, $f2, $7f
	db $e0, $bf, $e0, $ff, $a0, $bf, $e0, $df, $70, $ff, $30, $06, $00, $0f, $1a, $06
	db $ff, $f7, $fe, $9b, $ff, $13, $ff, $03, $ff, $02, $ff, $04, $06, $00, $03, $c0
	db $06, $c8, $1f, $1b

;@ path: gfx/monsters/pictures
;@ Picture of DuckKite (species $4A): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1F5 packed).
MonPic_DuckKite::
	db $40, $02, $06, $ff, $00, $ff, $0c, $f3, $12, $ff, $1e, $ff
	db $07, $ff, $37, $ce, $4e, $bf, $bf, $ff, $06, $ff, $f0, $00, $ff, $30, $df, $50
	db $ff, $f0, $7f, $60, $ff, $c0, $06, $10, $01, $01, $fe, $03, $fc, $0f, $f0, $1d
	db $e0, $2f, $c0, $f7, $06, $10, $03, $80, $7f, $e0, $1f, $70, $0f, $e8, $07, $de
	db $06, $10, $03, $18, $f7, $15, $ff, $1f, $fc, $0c, $ff, $07, $ff, $00, $ff, $60
	db $9f, $90, $ff, $f0, $ff, $c0, $ff, $d8, $e7, $e4, $fb, $fa, $ff, $cf, $fe, $9e
	db $ff, $3f, $ef, $2b, $fe, $33, $fe, $03, $ff, $01, $06, $6c, $01, $83, $7e, $42
	db $bd, $a5, $de, $de, $e0, $e0, $7f, $ff, $bf, $7f, $00, $5f, $80, $06, $34, $00
	db $ae, $c5, $d7, $4b, $5b, $6d, $7f, $b3, $b3, $01, $f5, $03, $ff, $00, $fe, $03
	db $eb, $46, $d6, $a4, $b4, $6d, $fd, $9b, $9b, $ff, $01, $fe, $82, $fd, $85, $7b
	db $4b, $f6, $f7, $0e, $0f, $fd, $ff, $fb, $fd, $ff, $e6, $ff, $f2, $ff, $f8, $ef
	db $a8, $ff, $98, $ff, $06, $82, $00, $00, $ff, $01, $06, $10, $03, $06, $c3, $03
	db $00, $87, $d8, $81, $dc, $80, $d4, $86, $df, $8e, $9f, $ce, $e5, $4c, $e7, $40
	db $af, $ac, $57, $da, $49, $ce, $31, $7e, $60, $3f, $40, $78, $43, $43, $7f, $3f
	db $ea, $6b, $d4, $b7, $24, $e6, $18, $fc, $0d, $f8, $05, $3c, $85, $84, $fd, $f8
	db $01, $c3, $37, $02, $77, $02, $57, $c2, $f7, $e2, $f3, $e6, $4f, $64, $cf, $04
	db $06, $c2, $0a, $06, $10, $1e, $d8, $40, $c7, $40, $e1, $50, $fc, $40, $cf, $40
	db $e3, $41, $fa, $42, $de, $42, $74, $34, $53, $5f, $c8, $4b, $8f, $8f, $8f, $8f
	db $07, $07, $00, $20, $20, $00, $5c, $58, $95, $f4, $27, $a4, $e2, $e2, $e3, $e2
	db $c1, $c1, $00, $08, $08, $00, $37, $04, $c7, $04, $0f, $14, $7f, $04, $e7, $04
	db $8f, $04, $bf, $84, $f7, $84, $06, $10, $1f, $04, $1c, $fb, $0a, $ff, $0e, $fd
	db $05, $ff, $3f, $c6, $46, $f7, $47, $ff, $47, $bf, $c7, $fb, $8b, $f7, $b7, $cf
	db $4f, $98, $9f, $20, $00, $33, $04, $d7, $c0, $e7, $f8, $e8, $ef, $fc, $fc, $ff
	db $ff, $3f, $ff, $08, $00, $99, $41, $d7, $07, $cf, $3f, $2f, $ef, $7f, $7f, $ff
	db $ff, $f8, $ff, $c7, $c4, $df, $c4, $ff, $c4, $fb, $c6, $bf, $a2, $df, $da, $e7
	db $e5, $33, $f3, $06, $10, $03, $70, $bf, $a0, $ff, $e0, $7f, $40, $ff, $f8, $ee
	db $6e, $bf, $bf, $ff, $cf, $ff, $1d, $f7, $14, $ff, $0c, $06, $10, $00, $77, $78
	db $fe, $ff, $ff, $c1, $06, $d8, $10, $ff, $20, $06, $10, $00, $8f, $7f, $f7, $0f
	db $db, $e3, $ff, $33, $ff, $0b, $ff, $07, $ff, $03, $ff, $01, $e3, $fc, $de, $e1
	db $b7, $8f, $ff, $98, $ff, $a0, $ff, $c0, $06, $ba, $00, $dc, $3c, $ff, $ff, $ff
	db $07, $fb, $0b, $ff, $0e, $ff, $08, $06, $10, $00, $ef, $ec, $fb, $fa, $ff, $e6
	db $ff, $70, $df, $50, $ff, $60, $06, $cc, $00

;@ path: gfx/monsters/pictures
;@ Picture of MadPecker (species $4B): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $113 packed).
MonPic_MadPecker::
	db $40, $02, $04, $ff, $04, $ff, $ff
	db $4d, $04, $1d, $0f, $09, $01, $fe, $02, $04, $1c, $01, $03, $fe, $1c, $f5, $22
	db $ef, $50, $ff, $8f, $90, $f0, $ff, $00, $ff, $78, $ef, $9e, $fd, $33, $b7, $07
	db $e7, $08, $fc, $02, $f2, $8d, $04, $1c, $07, $c0, $bf, $60, $ff, $c0, $04, $1c
	db $0f, $0e, $07, $fb, $1c, $ef, $30, $dc, $6b, $f8, $47, $e0, $5f, $e0, $5f, $c6
	db $7e, $66, $60, $92, $8c, $b2, $88, $5c, $c0, $22, $e2, $1e, $fe, $1a, $da, $65
	db $67, $7c, $46, $7e, $53, $7f, $61, $7f, $41, $bf, $c1, $bf, $c1, $9f, $a1, $9b
	db $c4, $3f, $a0, $3f, $60, $7f, $e0, $7f, $40, $ff, $80, $04, $a6, $02, $04, $1c
	db $0f, $0d, $ef, $39, $ff, $18, $04, $7a, $00, $ff, $01, $04, $1c, $02, $c4, $c6
	db $c8, $ce, $f1, $fd, $63, $fb, $8f, $ff, $7f, $f3, $fe, $02, $ff, $03, $c4, $fb
	db $e1, $eb, $fe, $df, $fe, $c2, $ff, $c1, $bf, $c1, $ff, $81, $ff, $81, $ff, $20
	db $3f, $e0, $3f, $a0, $7f, $40, $ff, $c0, $04, $66, $13, $04, $1d, $0f, $17, $03
	db $fd, $0d, $ff, $1f, $fa, $06, $ff, $07, $fd, $05, $f8, $08, $f1, $31, $ca, $ca
	db $77, $75, $cf, $c8, $ff, $81, $7f, $81, $ff, $01, $fe, $82, $7f, $43, $7e, $62
	db $fc, $f4, $fa, $0a, $04, $68, $14, $3f, $30, $0f, $08, $6f, $6c, $7f, $5e, $04
	db $5c, $0f, $0f, $ff, $03, $ff, $07, $04, $1c, $06, $3f, $30, $ff, $c1, $ff, $03
	db $ff, $03, $04, $1c, $04, $f7, $77, $ae, $ae, $ff, $f7, $f9, $09, $ff, $0e, $ff
	db $0c, $04, $1c, $01, $80, $04, $08, $13, $04, $1d, $0f, $04

;@ path: gfx/monsters/pictures
;@ Picture of MadRaven (species $4C): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $103 packed).
MonPic_MadRaven::
	db $40, $02, $06, $ff
	db $06, $ff, $ff, $4d, $06, $2b, $0f, $17, $03, $fc, $0c, $f0, $d0, $06, $2a, $07
	db $60, $9f, $90, $4f, $48, $06, $2a, $0f, $1e, $01, $fe, $02, $fc, $04, $fc, $04
	db $f8, $08, $06, $d8, $02, $21, $21, $10, $10, $10, $10, $08, $08, $09, $09, $0b
	db $0a, $09, $09, $08, $08, $87, $84, $e7, $e4, $d3, $92, $ef, $df, $f3, $f4, $ff
	db $02, $ff, $60, $f7, $90, $06, $2a, $05, $80, $ff, $40, $ff, $20, $cf, $06, $2b
	db $0f, $0e, $f8, $08, $fa, $0a, $fa, $0a, $fc, $04, $fd, $05, $fe, $02, $fe, $02
	db $ff, $07, $08, $08, $08, $08, $10, $10, $90, $90, $20, $20, $20, $20, $4f, $4f
	db $97, $9a, $55, $66, $3b, $37, $0e, $0d, $03, $03, $00, $00, $01, $01, $9f, $9e
	db $ef, $f5, $f7, $18, $ef, $18, $bb, $cc, $57, $cc, $ff, $f4, $ff, $0c, $06, $2a
	db $0f, $11, $f8, $18, $e2, $22, $cd, $4d, $f2, $72, $f6, $16, $ff, $1b, $06, $2a
	db $00, $5a, $5f, $a7, $bf, $5f, $60, $7f, $5b, $bf, $fb, $ff, $bb, $f7, $b3, $fd
	db $b1, $95, $ff, $fe, $0f, $06, $06, $11, $c0, $ff, $e8, $fe, $ea, $fc, $ed, $06
	db $06, $10, $7f, $c0, $df, $60, $9f, $00, $3f, $e0, $06, $ca, $10, $06, $ae, $0f
	db $12, $03, $ff, $05, $ff, $05, $ff, $03, $06, $2a, $00, $ee, $9c, $fd, $1e, $bd
	db $e3, $fb, $5e, $ff, $55, $ff, $9e, $06, $2a, $00, $f4, $d7, $e0, $2b, $81, $bd
	db $cf, $ee, $ff, $30, $06, $2a, $02, $7f, $c0, $ff, $80, $06, $2a, $0f, $09

;@ path: gfx/monsters/pictures
;@ Picture of MistyWing (species $4D): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $DD packed).
MonPic_MistyWing::
	db $40
	db $02, $01, $ff, $01, $ff, $ff, $4d, $01, $25, $0f, $12, $fe, $01, $85, $03, $fa
	db $01, $25, $07, $7f, $00, $2f, $80, $0f, $80, $01, $60, $0f, $15, $01, $82, $04
	db $bf, $00, $cf, $00, $c7, $10, $47, $10, $13, $08, $1b, $40, $59, $a4, $79, $84
	db $f0, $00, $f0, $05, $a0, $0f, $04, $4b, $06, $79, $23, $50, $39, $40, $9d, $20
	db $0f, $a0, $87, $30, $d7, $20, $f3, $08, $f2, $08, $90, $08, $30, $0a, $72, $0c
	db $f7, $00, $e7, $00, $c7, $10, $c5, $10, $93, $28, $93, $28, $11, $68, $30, $c8
	db $01, $26, $0c, $fc, $00, $f0, $03, $e7, $08, $c0, $1c, $81, $20, $9f, $00, $be
	db $00, $ff, $00, $5c, $a2, $9c, $43, $16, $29, $a5, $12, $04, $62, $10, $04, $e0
	db $0c, $c3, $10, $17, $00, $09, $d0, $8c, $70, $fe, $00, $9b, $64, $09, $d6, $04
	db $09, $70, $04, $d4, $09, $3c, $03, $7d, $02, $ff, $00, $d2, $2d, $80, $57, $00
	db $c2, $1d, $00, $f2, $0c, $d1, $26, $c0, $39, $42, $98, $41, $0c, $51, $00, $0e
	db $60, $87, $10, $3f, $00, $1f, $c0, $cf, $20, $27, $d0, $03, $08, $f3, $00, $fb
	db $01, $25, $0f, $00, $cf, $00, $df, $01, $25, $09, $01, $7c, $1c, $bf, $01, $25
	db $0b, $e7, $00, $f7, $01, $25, $0f, $4d, $01, $df, $1f, $0a

;@ path: gfx/monsters/pictures
;@ Picture of Dracky (species $4E): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $BA packed).
MonPic_Dracky::
	db $40, $02, $02, $ff
	db $02, $ff, $ff, $4d, $02, $19, $0f, $06, $de, $3f, $bf, $3f, $7f, $7f, $02, $1a
	db $05, $18, $ff, $04, $ff, $83, $ff, $c7, $02, $80, $07, $20, $ff, $c1, $ff, $e3
	db $02, $1a, $06, $7b, $fc, $fd, $fc, $fe, $fe, $02, $1a, $0c, $fe, $01, $ff, $02
	db $c1, $00, $02, $19, $06, $ff, $ff, $ff, $df, $3f, $ff, $0f, $f7, $0f, $ff, $06
	db $ff, $04, $ff, $00, $ff, $ef, $ff, $fd, $ff, $fa, $ff, $fd, $f7, $f7, $f7, $73
	db $f8, $38, $fc, $3c, $ff, $f7, $ff, $bf, $ff, $5f, $ff, $bf, $ef, $ef, $ef, $ce
	db $1f, $1c, $3f, $3c, $02, $d0, $00, $fb, $fc, $ff, $f0, $ef, $f0, $ff, $60, $ff
	db $20, $ff, $00, $7f, $80, $ff, $02, $11, $10, $02, $19, $0f, $07, $02, $c1, $0c
	db $bf, $ff, $df, $ff, $f7, $ff, $e0, $ff, $60, $02, $30, $13, $fd, $ff, $fb, $ff
	db $ef, $ff, $87, $ff, $86, $02, $1a, $00, $fd, $03, $02, $12, $11, $02, $15, $11
	db $bf, $78, $ff, $fc, $7f, $8c, $02, $1a, $0f, $2d, $bf, $c6, $fb, $7c, $02, $1a
	db $0f, $4d, $02, $e0, $1f, $19

;@ path: unused/filler
;@ Unused filler up to the end of the bank.
Unused_36::
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
