INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $032", ROMX[$4000], BANK[$32]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_32::
	db $32

;@ path: gfx/monsters/tables
;@ Entry table of bank $32: the address of each compressed block (entry number = position), as DecompressSetup
;@ finds it for Decompress / DecompressVRAM (bank, entry).
FarTable_32::
	dw MonPic_GoldGolem
	dw MonPic_DracoLord
	dw MonPic_DracoLord_2
	dw MonPic_Hargon
	dw MonPic_Sidoh
	dw MonPic_Baramos
	dw MonPic_Zoma
	dw MonPic_Pizzaro
	dw MonPic_Esterk
	dw MonPic_Mirudraas
	dw MonPic_Mirudraas_2
	dw MonPic_Mudou
	dw MonPic_DeathMore
	dw MonPic_DeathMore_2
	dw MonPic_DeathMore_3
	dw MonPic_Darkdrium
	dw MonPic_TERRY
	dw SGBBorder2TilesB
	dw SGBBorder2Map
	dw SGBBorder3Map

;@ path: gfx/monsters/pictures
;@ Picture of GoldGolem (species $C7): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $232 packed).
MonPic_GoldGolem::
	db $40, $02, $09, $ff, $00, $ff, $18
	db $e7, $3c, $c3, $7e, $f1, $7f, $f9, $cf, $fc, $87, $fe, $03, $ff, $12, $fd, $15
	db $f9, $39, $f2, $33, $d5, $76, $db, $7d, $d5, $fb, $ef, $f7, $ff, $03, $fc, $cc
	db $70, $f0, $80, $80, $80, $80, $09, $fc, $f0, $80, $80, $ff, $f0, $0f, $0e, $01
	db $01, $01, $01, $03, $02, $07, $04, $0f, $08, $1f, $10, $ff, $07, $f9, $3e, $d9
	db $e6, $98, $67, $c8, $37, $c0, $21, $c0, $00, $80, $00, $ff, $f0, $8f, $78, $3f
	db $f8, $4f, $fe, $93, $fe, $af, $fc, $ff, $f0, $bf, $e8, $ff, $01, $ff, $07, $f8
	db $0f, $f1, $1f, $f1, $1f, $e0, $3f, $c4, $7f, $c2, $7f, $ff, $ff, $50, $d3, $a0
	db $ff, $cc, $ff, $ff, $ff, $ff, $cf, $cf, $b1, $7e, $c7, $cf, $cf, $50, $df, $e0
	db $ff, $c0, $ff, $c0, $ff, $a0, $ff, $61, $ff, $9b, $ff, $3f, $3f, $8f, $8c, $7f
	db $f0, $7f, $c0, $3f, $f3, $dc, $fc, $5b, $eb, $7e, $c7, $83, $03, $8c, $8f, $d3
	db $5c, $af, $f3, $bc, $cc, $f0, $fc, $00, $ff, $3c, $ff, $7f, $90, $ff, $20, $ff
	db $c0, $ff, $80, $ff, $80, $7f, $60, $5f, $70, $4f, $f8, $8a, $ff, $8f, $e6, $af
	db $c2, $bb, $c7, $f7, $4f, $ef, $39, $fe, $37, $f8, $2f, $39, $ff, $06, $ff, $c7
	db $38, $ef, $10, $ff, $e3, $fc, $cc, $7f, $b7, $7c, $cf, $05, $ff, $0d, $ff, $f5
	db $36, $cf, $ce, $3f, $31, $ff, $c3, $7c, $07, $bc, $07, $3f, $e5, $7f, $85, $ff
	db $1d, $ef, $7b, $bf, $db, $7e, $e5, $bc, $db, $7f, $e7, $0f, $0f, $10, $1f, $23
	db $3c, $47, $78, $4d, $73, $cf, $f2, $bb, $e6, $9f, $f4, $c7, $fc, $07, $fc, $e3
	db $1e, $f3, $0e, $b3, $ce, $db, $66, $fb, $26, $fb, $26, $f0, $5f, $f1, $5e, $fb
	db $3c, $ff, $4c, $ff, $b3, $ff, $c0, $ff, $00, $ff, $00, $f7, $70, $e0, $37, $e1
	db $5a, $fb, $c0, $fd, $40, $d8, $e5, $bc, $e1, $ac, $f2, $b0, $0f, $b0, $0f, $b8
	db $07, $f0, $0f, $d0, $3f, $61, $bf, $ea, $37, $ff, $26, $18, $09, $2c, $10, $ff
	db $0f, $f0, $ff, $c0, $7f, $e0, $ff, $90, $ff, $f0, $17, $fc, $0f, $f8, $0f, $f8
	db $07, $fc, $87, $7c, $e7, $5c, $e3, $5e, $e3, $5e, $ef, $34, $ff, $14, $ff, $14
	db $f7, $1c, $ff, $0c, $ff, $0c, $ff, $66, $9f, $f2, $09, $51, $11, $30, $cf, $7f
	db $fa, $5f, $fd, $6b, $ff, $69, $be, $d1, $9e, $f0, $96, $f8, $ae, $d8, $db, $ec
	db $35, $ee, $fe, $07, $ff, $c5, $ff, $f8, $ff, $22, $dd, $36, $ff, $14, $6b, $1c
	db $f7, $18, $ef, $34, $af, $fa, $ef, $79, $ff, $40, $09, $b6, $01, $c0, $3f, $f9
	db $85, $7f, $ff, $1e, $ff, $16, $e3, $5f, $a2, $df, $e2, $9f, $f7, $8a, $7d, $86
	db $ff, $84, $bf, $c0, $df, $61, $1f, $f0, $6f, $98, $ff, $48, $f7, $6c, $df, $74
	db $9f, $fc, $bf, $ea, $bf, $ea, $ff, $9c, $ff, $f3, $ff, $50, $ff, $50, $ff, $30
	db $09, $51, $11, $00, $bf, $60, $ff, $20, $ff, $e0, $ff, $a0, $ff, $a0, $09, $2a
	db $12, $ff, $1d, $ff, $17, $fc, $0f, $f9, $0f, $fb, $0d, $ff, $07, $ff, $05, $ff
	db $03, $ff, $f4, $3f, $f8, $ff, $68, $ff, $50, $ff, $40, $ff, $38, $ff, $a8, $ff
	db $70, $fe, $3f, $ff, $03, $fe, $03, $ff, $01, $09, $ea, $12, $ff, $00, $ff, $a6
	db $ff, $b0, $ff, $e8, $ff, $a8, $ff, $09, $50, $12, $00

;@ path: gfx/monsters/pictures
;@ Picture of DracoLord (species $C8): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1B0 packed).
MonPic_DracoLord::
	db $40, $02, $06, $ff, $06
	db $ff, $ff, $07, $30, $ff, $38, $ff, $3c, $06, $00, $0b, $1f, $06, $00, $07, $01
	db $ff, $03, $ff, $07, $06, $00, $07, $80, $06, $4a, $01, $06, $ff, $ff, $09, $06
	db $ff, $f0, $3f, $ff, $1f, $ff, $1f, $ff, $0f, $fb, $0b, $f3, $13, $e5, $27, $eb
	db $2e, $e0, $60, $c0, $c0, $ff, $06, $84, $01, $ee, $ee, $e4, $f5, $e4, $ff, $ff
	db $df, $7f, $7f, $ff, $ff, $ff, $fe, $fb, $fa, $f9, $f9, $f4, $fc, $fa, $ee, $ff
	db $80, $ff, $0c, $f3, $13, $fc, $0c, $ff, $0f, $f1, $11, $fc, $8c, $fe, $82, $ff
	db $00, $ff, $e0, $5f, $dc, $83, $82, $9f, $9c, $a7, $a4, $3f, $38, $3f, $20, $06
	db $36, $02, $fe, $02, $fc, $05, $fd, $07, $fd, $07, $fc, $07, $cb, $4e, $fb, $7e
	db $86, $b7, $01, $fd, $cc, $fe, $33, $ff, $0c, $ff, $e0, $ff, $f5, $f5, $ee, $64
	db $e0, $75, $ee, $f1, $91, $ff, $1f, $fe, $35, $ff, $df, $f5, $fa, $ee, $fb, $cf
	db $ec, $dd, $f0, $b7, $d0, $7f, $a0, $af, $50, $ff, $61, $ef, $7e, $42, $fc, $c4
	db $38, $a8, $39, $f9, $49, $f9, $9f, $ff, $a4, $ff, $28, $ff, $7f, $40, $7f, $40
	db $06, $4e, $03, $80, $ff, $80, $7f, $c0, $ff, $07, $f8, $0f, $f8, $0f, $ff, $07
	db $fe, $03, $fc, $0f, $f9, $0f, $fe, $07, $c1, $f7, $01, $f7, $c6, $e7, $0e, $ef
	db $4e, $ef, $dc, $fd, $5c, $ff, $58, $fb, $ce, $ff, $a4, $f5, $d5, $ff, $a4, $f5
	db $8a, $ee, $99, $f7, $8a, $ee, $84, $b5, $53, $ff, $a5, $fd, $4a, $fb, $92, $f7
	db $04, $ef, $04, $ff, $08, $ff, $30, $ff, $28, $06, $1c, $01, $3b, $bb, $6b, $fa
	db $73, $72, $d7, $f6, $a7, $e6, $7f, $c0, $7f, $c0, $06, $4e, $08, $fe, $03, $06
	db $80, $10, $fc, $05, $06, $86, $11, $04, $ff, $03, $58, $ff, $70, $f7, $30, $bf
	db $20, $af, $20, $bf, $20, $bf, $40, $df, $40, $7f, $c0, $ff, $c0, $df, $a0, $a6
	db $5f, $ff, $40, $ff, $40, $df, $20, $e0, $1e, $ff, $00, $ff, $20, $bf, $c0, $06
	db $7c, $11, $01, $ff, $01, $ff, $02, $fe, $ab, $ee, $cb, $ce, $d3, $de, $d3, $de
	db $d3, $da, $4b, $4a, $2f, $ec, $2f, $e8, $06, $00, $0c, $fc, $05, $f8, $0b, $fc
	db $05, $ff, $03, $06, $00, $04, $c0, $df, $61, $ef, $3e, $fe, $e0, $ef, $c7, $47
	db $ff, $38, $06, $00, $00, $06, $49, $00, $06, $47, $01, $be, $ff, $7f, $06, $fc
	db $12, $07, $f7, $06, $10, $20, $ff, $f8, $06, $00, $02, $6f, $ec, $ab, $aa, $2f
	db $ec, $ef, $e8, $ef, $28, $ff, $10, $06, $00, $0f, $01

;@ path: gfx/monsters/pictures
;@ Picture of DracoLord (species $C9): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1E6 packed).
MonPic_DracoLord_2::
	db $40, $02, $09, $e0, $00
	db $c0, $00, $c0, $06, $c0, $07, $c0, $03, $e0, $00, $f0, $04, $fa, $00, $ff, $00
	db $0f, $10, $1f, $20, $07, $00, $0f, $81, $07, $01, $03, $01, $0d, $90, $ff, $18
	db $ef, $38, $ef, $68, $9d, $f9, $07, $f7, $e2, $fa, $f0, $5f, $f8, $ef, $ff, $00
	db $09, $30, $00, $df, $c0, $3f, $3f, $84, $57, $0b, $3b, $77, $f7, $09, $30, $02
	db $ff, $00, $ff, $c0, $3f, $f0, $ef, $fc, $1f, $1e, $09, $40, $05, $09, $41, $03
	db $fd, $02, $09, $30, $01, $01, $fe, $07, $ff, $0f, $f0, $3f, $c0, $43, $c7, $20
	db $ff, $01, $fe, $02, $ff, $03, $ff, $80, $7f, $ee, $df, $ff, $3f, $ff, $fe, $77
	db $8f, $8d, $7f, $76, $ff, $ac, $fc, $f3, $f7, $8f, $ff, $f9, $ff, $83, $ec, $9c
	db $f6, $36, $89, $69, $75, $fd, $03, $fb, $83, $9a, $03, $72, $05, $8d, $bf, $b3
	db $7f, $59, $ff, $88, $09, $30, $01, $07, $ff, $1f, $fd, $3d, $09, $50, $09, $80
	db $ff, $c0, $b8, $bd, $fd, $c7, $ff, $03, $fe, $06, $fc, $0c, $f8, $18, $fc, $3c
	db $ff, $63, $77, $f7, $c4, $c4, $8c, $8c, $0e, $0e, $19, $1f, $1d, $15, $38, $3c
	db $30, $38, $fd, $ef, $f1, $ff, $43, $5e, $43, $7e, $84, $fc, $87, $fc, $cb, $dc
	db $48, $68, $85, $7d, $44, $34, $02, $8e, $fa, $06, $03, $03, $fa, $07, $fc, $06
	db $05, $07, $f1, $71, $e1, $e1, $3d, $3d, $27, $37, $6f, $7b, $c7, $e7, $83, $c3
	db $30, $b0, $ff, $c0, $7f, $60, $7f, $60, $3f, $30, $3f, $30, $9f, $90, $9f, $98
	db $9f, $98, $ff, $01, $09, $50, $0a, $43, $73, $dd, $fd, $bf, $ef, $9b, $9f, $84
	db $df, $c8, $4f, $d0, $7f, $d0, $5f, $29, $ae, $a8, $ef, $d0, $70, $e0, $ff, $21
	db $ee, $20, $f1, $a4, $ea, $a3, $e4, $fd, $07, $fa, $07, $71, $89, $00, $07, $fc
	db $03, $f8, $04, $00, $03, $f0, $0e, $6e, $ee, $ff, $bd, $fe, $f6, $5f, $df, $57
	db $54, $57, $54, $53, $52, $53, $52, $8f, $8c, $c7, $c4, $df, $de, $7f, $62, $ff
	db $c0, $ff, $40, $09, $50, $0c, $09, $30, $00, $e0, $7f, $e0, $3f, $e0, $3f, $f0
	db $1f, $f0, $16, $f8, $08, $fe, $06, $ff, $03, $a0, $e9, $50, $76, $50, $53, $28
	db $2c, $1c, $1f, $07, $07, $0f, $0c, $ff, $f8, $c0, $39, $00, $06, $01, $f9, $02
	db $06, $0d, $fd, $fe, $fe, $f0, $33, $f1, $11, $93, $92, $a3, $a2, $23, $32, $47
	db $54, $87, $a4, $0f, $c8, $3f, $b0, $ff, $c0, $09, $7c, $1f, $01, $09, $50, $09
	db $01, $fe, $02, $fd, $07, $fb, $3f, $ff, $4c, $ff, $77, $09, $30, $00, $4f, $48
	db $af, $e8, $37, $be, $bf, $b9, $ff, $cf, $09, $30, $02, $f8, $0c, $fc, $07, $fe
	db $07, $f8, $1f, $f3, $3b, $ff, $4c, $ff, $70, $09, $ba, $00, $7f, $70, $0f, $ee
	db $63, $fb, $1f, $7e, $df, $d9, $ff, $24, $ff, $1c, $09, $b6, $05, $40, $09, $ce
	db $12

;@ path: gfx/monsters/pictures
;@ Picture of Hargon (species $CA): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1AF packed).
MonPic_Hargon::
	db $40, $02, $02, $ff, $38, $e7, $5c, $c7, $fe, $ff, $ba, $ff, $c6, $bb, $fe
	db $c7, $7c, $ff, $3c, $ff, $00, $02, $10, $0f, $26, $1c, $f3, $1e, $f9, $0f, $02
	db $10, $03, $18, $ef, $38, $df, $70, $bf, $e0, $3f, $fc, $e7, $3c, $f7, $1c, $ff
	db $1c, $f7, $1c, $ff, $1e, $f5, $1f, $f5, $17, $f3, $1f, $02, $10, $01, $38, $ff
	db $16, $ff, $09, $fd, $06, $fc, $07, $fe, $c3, $02, $10, $05, $80, $ff, $40, $7f
	db $a0, $3f, $d7, $02, $10, $05, $03, $ff, $04, $fc, $0b, $f8, $d7, $fc, $07, $fc
	db $07, $fe, $3b, $fd, $d7, $fd, $2d, $73, $d6, $69, $ff, $c9, $f9, $83, $fe, $bf
	db $fc, $3f, $e0, $df, $f0, $ef, $38, $ff, $18, $02, $10, $00, $f1, $11, $f1, $1d
	db $ff, $0f, $fb, $02, $c5, $05, $be, $bf, $4d, $cd, $ab, $ee, $e9, $ff, $ed, $fb
	db $ef, $f9, $ef, $e9, $ef, $e9, $1f, $ef, $8f, $ff, $fe, $7f, $7b, $9b, $99, $fd
	db $f9, $ff, $dd, $bd, $7b, $59, $f0, $ef, $e3, $ff, $ff, $fc, $bd, $b3, $32, $7f
	db $3e, $ff, $77, $7b, $bc, $34, $98, $e8, $5c, $65, $bc, $c7, $3c, $c7, $fc, $85
	db $f4, $8c, $f4, $8c, $e4, $9d, $ff, $80, $02, $10, $1a, $02, $c6, $06, $02, $c6
	db $00, $fd, $07, $cf, $c9, $cf, $e9, $d7, $f8, $d7, $f8, $93, $9c, $93, $9c, $a1
	db $fe, $38, $e7, $78, $fd, $6b, $fc, $ad, $be, $ab, $fb, $d5, $7d, $fa, $3b, $fe
	db $0d, $fa, $03, $3c, $7e, $ac, $7f, $69, $f9, $a9, $bd, $53, $7e, $af, $ac, $7f
	db $f0, $bf, $80, $e4, $9f, $e4, $9f, $c4, $3d, $d8, $28, $99, $69, $b9, $4b, $f9
	db $0f, $f9, $0f, $02, $10, $15, $02, $11, $03, $fd, $07, $02, $80, $1a, $3e, $a1
	db $3f, $20, $3f, $20, $4f, $f1, $63, $df, $7b, $c6, $5f, $60, $2f, $30, $7d, $81
	db $ff, $38, $ff, $f2, $ff, $f3, $ff, $ff, $7d, $7d, $ff, $97, $fc, $04, $7f, $02
	db $73, $00, $9e, $ff, $9f, $ff, $ff, $7f, $7d, $ff, $d4, $7f, $40, $e9, $1b, $c9
	db $39, $d9, $29, $a9, $5b, $f1, $1f, $f3, $1e, $d3, $36, $a3, $62, $02, $10, $0d
	db $07, $fe, $03, $ff, $03, $fe, $07, $fa, $0f, $fa, $0b, $ff, $07, $ff, $00, $17
	db $38, $8f, $ef, $80, $e2, $e0, $e6, $de, $df, $bf, $b9, $ff, $c0, $02, $96, $00
	db $7f, $80, $ff, $ff, $00, $18, $00, $3c, $ff, $ff, $02, $84, $02, $fb, $07, $fc
	db $fc, $00, $30, $01, $79, $ff, $fe, $02, $10, $00, $47, $c4, $87, $fc, $0f, $7c
	db $3b, $fb, $d2, $d3, $e4, $e6, $ff, $02, $6f, $02, $02, $83, $04, $02, $77, $11
;@ path: gfx/monsters/pictures
;@ Picture of Sidoh (species $CB): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked by
;@ LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $218 packed).
MonPic_Sidoh::
	db $40, $02, $08, $ff, $08, $ff, $f8, $01, $ff, $02, $ff, $01, $fe, $06, $f9, $19
	db $ff, $2f, $f9, $59, $f7, $f6, $bb, $af, $9b, $be, $ff, $80, $ff, $80, $08, $00
	db $01, $08, $21, $00, $80, $ff, $c0, $ff, $03, $fe, $02, $ff, $01, $ff, $01, $ff
	db $03, $ff, $02, $ff, $03, $ff, $06, $ff, $00, $ff, $c0, $3f, $30, $ff, $e8, $3f
	db $34, $df, $de, $bb, $eb, $b3, $fa, $08, $00, $09, $00, $ff, $80, $fe, $03, $ff
	db $05, $ff, $0b, $ff, $0b, $ff, $17, $f6, $1f, $fe, $2e, $ef, $3f, $c1, $db, $e0
	db $ee, $cf, $ef, $9b, $df, $3f, $fb, $3f, $bb, $5b, $df, $0f, $3f, $7f, $c0, $7f
	db $40, $ff, $b0, $ef, $38, $f7, $9c, $73, $f6, $9b, $eb, $fc, $ff, $fd, $07, $fc
	db $04, $ff, $1b, $ef, $39, $df, $73, $9d, $df, $b3, $af, $7f, $ff, $06, $b7, $0f
	db $ef, $e7, $ef, $b3, $f7, $f9, $bf, $f8, $bb, $b4, $f6, $e1, $f9, $ff, $80, $ff
	db $40, $ff, $a0, $ff, $a0, $ff, $d0, $df, $f0, $ff, $e8, $ef, $f8, $ff, $3f, $e7
	db $2f, $ef, $6b, $e7, $6f, $fb, $7a, $b9, $a9, $90, $bb, $c1, $df, $c3, $df, $a1
	db $e7, $f8, $ba, $fd, $bd, $a1, $ef, $61, $ff, $a2, $ff, $ca, $ff, $32, $d6, $e9
	db $eb, $e6, $bf, $77, $f5, $e8, $e1, $e5, $aa, $fb, $ff, $b7, $97, $99, $d7, $2f
	db $af, $ce, $fa, $dd, $5f, $2f, $0f, $4f, $ab, $be, $ff, $da, $d3, $87, $f7, $0b
	db $cf, $3f, $bb, $7f, $7b, $0b, $ee, $0d, $ff, $8a, $ff, $a7, $ff, $ff, $f8, $cf
	db $e8, $ef, $ac, $cf, $ec, $bf, $bc, $3b, $2a, $13, $ba, $07, $f6, $b9, $f9, $fc
	db $bd, $fe, $be, $fe, $be, $ff, $bf, $08, $28, $10, $bf, $ff, $ca, $fa, $8a, $ea
	db $5d, $fd, $14, $dc, $3e, $36, $f6, $fe, $be, $fe, $f1, $bf, $35, $95, $3d, $19
	db $78, $5a, $fb, $e8, $5c, $f4, $4f, $df, $67, $ec, $3d, $fc, $58, $52, $78, $30
	db $3d, $b5, $be, $2e, $74, $5e, $e4, $f6, $cc, $6e, $79, $7f, $a7, $bf, $a2, $af
	db $74, $7e, $50, $76, $f9, $d9, $df, $ff, $fb, $ff, $1f, $fb, $3b, $3e, $7f, $7a
	db $ff, $fa, $08, $74, $14, $fb, $fe, $ff, $5f, $ff, $5f, $f9, $59, $fc, $56, $fe
	db $5f, $ff, $53, $fe, $57, $f8, $5b, $e0, $bf, $a2, $fb, $c2, $73, $86, $e6, $4e
	db $4a, $3f, $b1, $1f, $d0, $8f, $e8, $a6, $ec, $53, $f6, $1d, $fd, $0b, $ff, $0c
	db $3f, $8b, $8b, $ff, $7f, $f8, $18, $ca, $6f, $94, $df, $70, $7f, $a0, $fe, $60
	db $f8, $a3, $a3, $ff, $fc, $7f, $60, $0f, $fb, $8b, $bf, $87, $9d, $c2, $ce, $e4
	db $a5, $f9, $1b, $f0, $17, $e2, $ef, $ff, $f4, $ff, $f4, $3f, $34, $7f, $d4, $ff
	db $f4, $ff, $94, $ff, $d4, $3f, $b4, $f3, $57, $ff, $5c, $df, $74, $ff, $3c, $ff
	db $30, $ff, $10, $ff, $10, $ff, $00, $c7, $f4, $f7, $34, $ff, $28, $ff, $30, $08
	db $00, $05, $0f, $fc, $0c, $ff, $07, $ff, $03, $08, $00, $05, $e3, $5c, $5c, $e3
	db $e3, $bf, $bd, $fe, $7b, $fe, $02, $e8, $00, $c3, $01, $47, $5f, $db, $da, $fb
	db $2e, $fb, $fe, $87, $7c, $3f, $78, $3f, $60, $ff, $c0, $9f, $d4, $ff, $74, $f7
	db $5c, $ff, $78, $ff, $18, $08, $ea, $12

;@ path: gfx/monsters/pictures
;@ Picture of Baramos (species $CC): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1A9 packed).
MonPic_Baramos::
	db $40, $02, $06, $ff, $06, $ff, $ff, $1b
	db $0c, $06, $00, $0f, $1c, $06, $ff, $ff, $05, $1c, $fb, $0f, $fc, $07, $fc, $07
	db $fe, $03, $fb, $0e, $fb, $0e, $ff, $0a, $fd, $0b, $f7, $18, $eb, $ec, $7a, $d1
	db $c5, $d3, $06, $00, $03, $c0, $bf, $21, $fe, $27, $38, $bf, $b0, $df, $06, $00
	db $03, $3c, $cf, $f8, $1f, $f6, $3f, $f5, $4e, $cf, $06, $00, $03, $30, $ff, $50
	db $bf, $e0, $bf, $b8, $4f, $54, $06, $00, $03, $03, $ff, $02, $ff, $01, $ff, $00
	db $ff, $01, $ff, $0f, $f2, $3b, $cd, $7d, $dd, $f5, $56, $de, $a9, $fd, $cd, $ef
	db $1f, $d5, $bb, $c6, $7f, $bc, $fa, $f8, $4c, $c9, $be, $b1, $7d, $e3, $32, $cf
	db $ff, $ff, $d8, $6f, $d8, $6b, $b9, $cb, $ea, $9e, $95, $fd, $5e, $de, $f9, $f9
	db $b6, $f7, $97, $97, $ab, $be, $57, $7d, $af, $e4, $2f, $b4, $7f, $52, $f6, $99
	db $f8, $0f, $1f, $1c, $ff, $f0, $9f, $78, $ef, $f8, $8f, $78, $1f, $f0, $3f, $e0
	db $ff, $c0, $ff, $02, $ff, $03, $ff, $01, $06, $ca, $02, $fe, $03, $fc, $07, $ef
	db $f5, $cf, $b9, $f3, $7d, $82, $7f, $84, $fd, $78, $fd, $50, $dd, $90, $9d, $b6
	db $bf, $fb, $5f, $a4, $7f, $fb, $57, $bf, $68, $dd, $35, $aa, $1b, $c6, $05, $d9
	db $fa, $bf, $f4, $4b, $fc, $bf, $d4, $fb, $2c, $77, $58, $ae, $b1, $5f, $e3, $ff
	db $0f, $da, $0b, $d5, $0d, $94, $4c, $94, $4c, $34, $8c, $24, $9c, $e4, $dc, $ff
	db $00, $ff, $80, $7f, $c0, $bf, $e0, $5f, $70, $5f, $70, $2f, $38, $2f, $38, $f9
	db $0f, $f2, $1e, $f2, $1e, $e4, $3c, $06, $86, $10, $f6, $1e, $f7, $1d, $14, $1a
	db $16, $18, $2f, $38, $4f, $70, $4f, $70, $9f, $e0, $9f, $e0, $80, $f8, $7a, $83
	db $79, $85, $3c, $43, $9f, $00, $e3, $04, $ff, $00, $fb, $07, $1f, $20, $bf, $8c
	db $3f, $50, $7f, $a0, $fc, $41, $f8, $43, $f3, $84, $ef, $00, $df, $01, $e4, $3c
	db $f4, $1c, $e8, $18, $e8, $18, $e4, $1c, $e4, $7c, $95, $fd, $bf, $fe, $17, $1c
	db $06, $d0, $10, $77, $7c, $f7, $9c, $ff, $98, $ff, $18, $ff, $10, $ff, $0c, $ff
	db $05, $06, $2a, $10, $ff, $05, $ff, $07, $06, $00, $00, $f7, $f8, $7f, $80, $fe
	db $ff, $b1, $ff, $fb, $6f, $ff, $fc, $06, $00, $02, $c0, $20, $ff, $00, $ff, $ff
	db $06, $00, $04, $3e, $07, $f9, $0f, $ff, $3f, $ff, $fd, $ff, $03, $06, $00, $02
	db $77, $5c, $23, $26, $8f, $8e, $ff, $fa, $06, $2e, $05, $06, $03, $20, $06, $ff
	db $f7

;@ path: gfx/monsters/pictures
;@ Picture of Zoma (species $CD): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked by
;@ LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1F1 packed).
MonPic_Zoma::
	db $40, $02, $11, $ff, $11, $ff, $fe, $01, $11, $12, $03, $11, $0d, $03, $fe
	db $06, $fb, $89, $f7, $94, $6f, $e2, $ff, $b9, $bf, $cf, $cb, $7b, $ff, $fc, $03
	db $03, $fe, $24, $ff, $f9, $ff, $ca, $ff, $f4, $8f, $8f, $26, $56, $ff, $00, $ff
	db $04, $ff, $8c, $7f, $4c, $b7, $3c, $ff, $e8, $ef, $98, $9f, $f0, $11, $00, $0f
	db $00, $11, $0f, $04, $11, $ff, $f6, $78, $87, $fe, $01, $1f, $e0, $e7, $f8, $7b
	db $fc, $3d, $b7, $b7, $bf, $9f, $bf, $a7, $bb, $97, $bb, $8f, $5e, $46, $5e, $56
	db $2d, $2f, $77, $27, $27, $57, $8f, $8f, $de, $df, $56, $57, $8b, $8b, $fa, $fb
	db $fa, $ab, $6f, $68, $ef, $c8, $ef, $2b, $ec, $4f, $e8, $8f, $d0, $16, $d1, $55
	db $a2, $a3, $ff, $00, $ff, $f0, $0f, $fc, $07, $c4, $3f, $38, $ff, $f0, $ff, $e0
	db $ff, $c0, $11, $00, $0c, $f2, $1e, $ef, $33, $fd, $2d, $ec, $3c, $fd, $1d, $fe
	db $0e, $ff, $07, $fb, $0f, $2d, $27, $d5, $d7, $3d, $ff, $cd, $ff, $30, $f8, $10
	db $f0, $21, $71, $c9, $e9, $27, $af, $76, $8f, $9f, $df, $e5, $fd, $1a, $7b, $2e
	db $2f, $d2, $d3, $e6, $ef, $ac, $2f, $77, $79, $af, $f0, $cf, $fe, $d1, $f9, $e1
	db $fd, $cf, $ff, $b3, $ff, $ff, $40, $7f, $a0, $ff, $a0, $ff, $60, $11, $bc, $01
	db $80, $ff, $80, $11, $0a, $06, $fe, $03, $fc, $07, $f9, $0f, $f7, $1f, $e9, $39
	db $d1, $71, $a2, $e3, $42, $c3, $82, $82, $84, $86, $04, $06, $3f, $ff, $e7, $f2
	db $21, $71, $27, $71, $21, $71, $27, $f1, $60, $b0, $66, $b0, $9e, $ff, $e0, $f8
	db $f0, $10, $5e, $1e, $b2, $12, $5d, $b1, $e0, $e1, $ec, $e1, $cf, $ff, $3b, $77
	db $3b, $37, $1a, $36, $4e, $5e, $f3, $f7, $fd, $8f, $f9, $8f, $7f, $c0, $11, $70
	db $10, $bf, $e0, $11, $76, $10, $5f, $70, $5f, $70, $fa, $0e, $f2, $1e, $e4, $3c
	db $e4, $3c, $c8, $78, $c8, $78, $90, $f0, $90, $f0, $08, $0e, $0a, $0c, $12, $1c
	db $16, $18, $26, $38, $2e, $30, $2f, $30, $4f, $70, $11, $4c, $10, $72, $99, $70
	db $9a, $79, $8c, $78, $8c, $34, $47, $33, $47, $e0, $e1, $4c, $41, $09, $13, $a1
	db $0b, $b3, $06, $a3, $06, $05, $1c, $1b, $f8, $f9, $8f, $f9, $8f, $fa, $0d, $11
	db $c4, $12, $fb, $0c, $fb, $0c, $4f, $78, $27, $3c, $a7, $bc, $93, $9e, $11, $d6
	db $10, $4b, $ce, $4b, $ce, $9e, $fe, $bf, $f1, $ff, $60, $11, $e4, $11, $23, $fc
	db $0c, $ff, $1f, $5f, $60, $5f, $60, $9f, $e0, $9f, $e0, $f7, $f8, $0f, $ef, $0e
	db $3f, $ff, $f0, $30, $47, $b8, $02, $99, $22, $dc, $01, $ee, $00, $7f, $80, $fb
	db $fc, $ff, $07, $e3, $f8, $07, $f0, $0f, $00, $ff, $00, $7f, $80, $ff, $00, $fd
	db $03, $ff, $fe, $11, $cc, $10, $fb, $0c, $eb, $1c, $f3, $1f, $dc, $3f, $f8, $fe
	db $ff, $0f, $5f, $dc, $7f, $ec, $7f, $c8, $7f, $c8, $ff, $c0, $7f, $e0, $1f, $18
	db $ff, $fc

;@ path: gfx/monsters/pictures
;@ Picture of Pizzaro (species $CE): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $22E packed).
MonPic_Pizzaro::
	db $40, $02, $05, $ff, $60, $ff, $50, $ff, $28, $ef, $34, $ff, $13, $f7
	db $18, $ff, $08, $fb, $0c, $ff, $00, $05, $10, $01, $03, $fc, $07, $fd, $ff, $d5
	db $35, $e2, $3b, $05, $12, $03, $c7, $3b, $ff, $cd, $fe, $27, $f5, $f3, $1b, $05
	db $10, $01, $80, $7f, $c7, $b8, $ff, $67, $ff, $c9, $5f, $9e, $b1, $05, $10, $03
	db $80, $7f, $c1, $7f, $fe, $57, $58, $8f, $b8, $ff, $0c, $ff, $14, $ff, $28, $ef
	db $58, $ff, $90, $df, $30, $ff, $20, $bf, $60, $fe, $07, $ff, $01, $ff, $00, $ff
	db $0c, $f3, $1e, $f3, $1e, $fd, $1f, $fc, $17, $a2, $7b, $a3, $e3, $e4, $66, $f8
	db $18, $f0, $19, $e0, $3f, $f9, $ff, $8e, $fe, $f8, $2a, $7c, $9d, $f3, $ff, $0f
	db $7d, $5b, $ff, $fc, $ac, $d0, $b0, $ba, $da, $3e, $a9, $7d, $73, $9e, $fe, $e0
	db $7c, $b4, $ff, $7e, $6b, $17, $1b, $ba, $b6, $8a, $bd, $8b, $8f, $4f, $cc, $3f
	db $30, $1f, $30, $0f, $f8, $3f, $ff, $e2, $ff, $ff, $c0, $05, $10, $01, $60, $9f
	db $f0, $9f, $f0, $7f, $f0, $7f, $d0, $fc, $75, $9c, $f5, $88, $c8, $d4, $d4, $f0
	db $b0, $e0, $a0, $f4, $d4, $ef, $6f, $c3, $ff, $70, $ff, $08, $fd, $ac, $fe, $7a
	db $5b, $b2, $d6, $ed, $bd, $65, $7d, $7f, $75, $8f, $9f, $60, $ef, $3b, $bb, $46
	db $7f, $93, $d7, $bd, $ad, $b4, $af, $fd, $5d, $e2, $f3, $0c, $ef, $b8, $ba, $c4
	db $fd, $92, $d6, $7b, $6b, $5b, $eb, $86, $ff, $1c, $ff, $20, $7e, $6a, $fe, $bc
	db $b4, $9a, $d6, $6e, $7a, $4d, $7d, $7f, $5c, $73, $5e, $23, $26, $57, $56, $1f
	db $1a, $0f, $0a, $5f, $56, $ef, $ec, $de, $7a, $fe, $6a, $ef, $35, $ff, $1d, $05
	db $10, $01, $18, $f7, $1d, $23, $7f, $22, $6e, $17, $37, $4c, $5d, $ae, $af, $f5
	db $77, $84, $87, $07, $07, $48, $4f, $30, $bd, $15, $df, $aa, $bc, $5d, $ff, $33
	db $37, $d6, $fb, $ad, $ba, $25, $e5, $18, $7a, $51, $f7, $aa, $7b, $74, $ff, $99
	db $d9, $d6, $bf, $6b, $bb, $88, $fc, $88, $ec, $d1, $d9, $65, $75, $eb, $ea, $5f
	db $dc, $43, $c2, $c1, $c1, $f7, $bc, $ff, $ac, $ef, $58, $ff, $70, $05, $10, $01
	db $30, $df, $70, $fb, $0f, $fc, $07, $fc, $0d, $f2, $12, $e7, $25, $cf, $49, $df
	db $51, $ff, $61, $0c, $0f, $f1, $ff, $12, $ff, $14, $bf, $14, $54, $3f, $3f, $f3
	db $fa, $11, $1d, $57, $5f, $b8, $bf, $1c, $9c, $33, $3f, $fc, $df, $fb, $0b, $fc
	db $04, $ff, $07, $d4, $f5, $3b, $fb, $70, $73, $98, $f9, $7e, $f6, $bf, $a1, $7f
	db $40, $ff, $c1, $61, $e1, $1e, $ff, $90, $ff, $50, $fa, $51, $55, $f9, $f9, $9f
	db $bf, $11, $71, $bf, $e0, $7f, $c0, $7f, $60, $9f, $90, $cf, $48, $e7, $24, $f7
	db $14, $ff, $05, $0f, $00, $03, $fe, $3f, $f7, $7f, $f8, $8e, $fc, $ff, $fe, $22
	db $ff, $3f, $90, $bc, $90, $b0, $68, $e8, $1f, $ff, $e0, $f9, $1f, $9f, $ff, $f0
	db $ff, $00, $ff, $83, $ff, $80, $ff, $f0, $4f, $f8, $9f, $9c, $df, $d2, $ff, $3e
	db $ff, $00, $fe, $82, $fe, $02, $fe, $1e, $e5, $3f, $f2, $73, $f7, $97, $ff, $f8
	db $ff, $00, $13, $7a, $13, $1b, $2c, $2f, $f1, $ff, $0e, $3e, $f0, $f3, $fe, $1e
	db $05, $62, $01, $80, $ff, $f8, $df, $fc, $3f, $e2, $7f, $fe, $ff, $88, $ff, $f8
;@ path: gfx/monsters/pictures
;@ Picture of Esterk (species $CF): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1ED packed).
MonPic_Esterk::
	db $40, $02, $09, $ff, $03, $fd, $0f, $fb, $16, $f7, $2c, $f7, $4c, $f7, $4c, $e3
	db $9f, $e1, $9f, $ff, $80, $ff, $08, $ff, $0c, $ff, $0c, $fb, $0e, $fb, $0e, $fd
	db $07, $fc, $05, $ff, $00, $09, $20, $07, $80, $7f, $f3, $09, $20, $09, $03, $fc
	db $9f, $ff, $03, $ff, $21, $ff, $60, $ff, $60, $bf, $e0, $bf, $e0, $7f, $c1, $7f
	db $41, $ff, $80, $7f, $e0, $bf, $d0, $df, $68, $df, $64, $df, $64, $8f, $f2, $0f
	db $f2, $e3, $9e, $e3, $9e, $e7, $9c, $09, $64, $00, $f7, $4c, $f7, $4f, $f2, $4f
	db $fe, $02, $ff, $01, $09, $20, $03, $f8, $07, $ff, $01, $ff, $2d, $ff, $23, $3a
	db $a1, $a7, $f6, $7e, $d7, $75, $ba, $fa, $63, $e4, $a8, $ba, $68, $fe, $89, $b9
	db $0b, $ca, $df, $fc, $d7, $5c, $bb, $be, $8d, $4f, $2b, $bb, $ff, $80, $09, $20
	db $05, $3e, $c1, $ff, $00, $ff, $8f, $f2, $8f, $f2, $cf, $72, $09, $b4, $00, $df
	db $64, $df, $e4, $9f, $e4, $fb, $27, $fa, $26, $f9, $17, $fd, $13, $fe, $0b, $fd
	db $07, $fb, $0e, $fc, $0f, $e0, $ff, $18, $1d, $14, $16, $ea, $fb, $b3, $fb, $f3
	db $3b, $55, $f5, $b8, $e8, $ff, $fc, $47, $77, $80, $fe, $81, $ff, $81, $bd, $43
	db $43, $3c, $7e, $a8, $b8, $fe, $7f, $c4, $dd, $02, $fe, $02, $ff, $03, $7b, $85
	db $85, $79, $fd, $2a, $3a, $0f, $ff, $30, $70, $51, $d1, $af, $bf, $9a, $bf, $9f
	db $b9, $55, $5e, $3a, $2f, $bf, $c8, $bf, $c8, $3f, $d0, $7f, $90, $ff, $a0, $7f
	db $c0, $bf, $e0, $7f, $e0, $f9, $0f, $fb, $0d, $ff, $05, $fd, $06, $ff, $03, $09
	db $20, $02, $58, $78, $be, $ae, $4a, $7e, $9d, $9d, $77, $fe, $ff, $fd, $9e, $97
	db $f8, $6f, $c8, $ee, $98, $d8, $68, $7e, $8b, $fb, $84, $e7, $c8, $ce, $33, $bb
	db $1c, $df, $26, $ee, $32, $36, $2c, $fc, $a3, $bf, $43, $ce, $27, $e7, $98, $bb
	db $70, $f7, $35, $3d, $fb, $eb, $a5, $fd, $73, $72, $dd, $ff, $ff, $7e, $f3, $d2
	db $3f, $ec, $3f, $e0, $bf, $60, $ff, $40, $7f, $c0, $09, $a0, $07, $09, $7b, $19
	db $f0, $1f, $f1, $3f, $ca, $7f, $ca, $6a, $df, $5f, $f3, $3f, $e4, $2f, $e4, $2e
	db $f0, $fc, $1f, $9f, $38, $2c, $ff, $cf, $fc, $04, $ff, $03, $ff, $80, $ff, $80
	db $1e, $7f, $f1, $f3, $38, $69, $fe, $e6, $7f, $41, $ff, $81, $fe, $03, $fe, $02
	db $1f, $f0, $1f, $f8, $a7, $fc, $a7, $ac, $f7, $f4, $9f, $f8, $4f, $e8, $4f, $e8
	db $09, $7a, $1f, $03, $ff, $01, $ff, $02, $ff, $03, $09, $72, $00, $e2, $26, $f1
	db $11, $ef, $ff, $b0, $f9, $c9, $ef, $ff, $7e, $09, $a0, $01, $80, $ff, $80, $7f
	db $c0, $bf, $b0, $ff, $e8, $ff, $18, $09, $20, $00, $09, $f5, $00, $fd, $07, $fa
	db $1b, $ff, $2f, $ff, $30, $09, $20, $00, $8f, $c8, $1f, $10, $ef, $fe, $1b, $3f
	db $27, $ee, $ff, $fd, $09, $28, $14, $09, $28, $02, $09, $a0, $02

;@ path: gfx/monsters/pictures
;@ Picture of Mirudraas (species $D0): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $182 packed).
MonPic_Mirudraas::
	db $40, $02, $02
	db $ff, $02, $ff, $ff, $01, $04, $ff, $03, $ff, $01, $02, $00, $01, $02, $19, $02
	db $07, $fb, $1c, $ef, $f0, $bf, $b9, $f6, $ff, $bb, $e7, $02, $00, $01, $c0, $bf
	db $71, $ef, $1f, $fb, $3a, $df, $fe, $bb, $cf, $02, $00, $01, $40, $ff, $80, $02
	db $00, $0f, $02, $02, $ff, $ff, $01, $f3, $8e, $df, $b2, $c7, $97, $e2, $cf, $73
	db $ce, $62, $c7, $69, $e5, $28, $5d, $f3, $b7, $b8, $91, $d6, $56, $f8, $d9, $72
	db $ea, $aa, $7f, $fd, $e8, $e9, $75, $9f, $da, $3b, $12, $d7, $d5, $3e, $37, $9d
	db $ae, $aa, $fd, $7f, $2f, $2e, $ff, $9e, $e3, $f6, $9b, $c6, $d3, $8e, $e7, $9c
	db $e7, $8c, $c7, $2c, $4f, $28, $02, $48, $0f, $0d, $e2, $29, $e3, $29, $e7, $29
	db $e7, $29, $f3, $19, $02, $d8, $02, $db, $fc, $2c, $79, $3d, $ba, $9d, $3e, $d7
	db $96, $8f, $df, $48, $5e, $40, $7d, $b6, $7f, $69, $3d, $79, $bb, $73, $f9, $f7
	db $f3, $23, $37, $25, $f5, $c5, $fd, $8f, $28, $8f, $28, $cf, $28, $cf, $28, $9f
	db $30, $02, $08, $12, $02, $48, $0f, $0d, $f3, $17, $f6, $1e, $f8, $08, $fb, $0b
	db $fc, $0c, $f8, $0c, $f9, $0c, $fb, $08, $a3, $bb, $bf, $bf, $ed, $ed, $2a, $eb
	db $1d, $fe, $5a, $8b, $5d, $0d, $df, $0f, $8b, $fb, $fa, $fa, $6e, $6e, $a9, $af
	db $70, $fe, $b4, $a2, $75, $60, $f7, $e0, $9f, $d0, $df, $f0, $3f, $20, $bf, $a0
	db $7f, $60, $3f, $60, $3f, $60, $bf, $20, $02, $10, $1f, $0e, $18, $02, $90, $12
	db $e6, $39, $e6, $39, $e4, $3b, $c4, $7a, $df, $2f, $bf, $4f, $fb, $0b, $f4, $14
	db $f3, $13, $f2, $12, $f2, $32, $ea, $2a, $f7, $e8, $fb, $e4, $bf, $a0, $5f, $50
	db $9e, $91, $9e, $91, $9e, $99, $ae, $a8, $02, $08, $14, $cf, $38, $cf, $38, $4f
	db $b8, $47, $bc, $02, $00, $0f, $00, $01, $fe, $03, $fe, $02, $17, $04, $00, $c1
	db $f8, $47, $e0, $9f, $cf, $b9, $1f, $e7, $ff, $ff, $ff, $02, $00, $00, $c8, $48
	db $84, $84, $70, $70, $8c, $8c, $f0, $f0, $ff, $0f, $02, $00, $00, $27, $24, $43
	db $42, $1d, $1d, $63, $63, $1f, $1f, $ff, $e1, $02, $00, $00, $07, $3e, $c5, $0f
	db $f2, $e7, $3a, $f1, $cf, $ff, $ff, $fe, $02, $00, $05, $80, $02, $46, $06

;@ path: gfx/monsters/pictures
;@ Picture of Mirudraas (species $D1): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $231 packed).
MonPic_Mirudraas_2::
	db $40
	db $02, $09, $ff, $00, $ff, $ec, $f3, $72, $f5, $3d, $d8, $5a, $d1, $77, $f3, $7f
	db $de, $7e, $ff, $20, $ff, $60, $ff, $e2, $9f, $d3, $5f, $71, $4f, $69, $67, $f4
	db $df, $fe, $ff, $09, $ff, $f0, $09, $ff, $f0, $80, $7f, $41, $bf, $a1, $be, $f3
	db $09, $20, $03, $01, $ff, $03, $fd, $05, $fb, $0a, $fb, $9e, $ff, $08, $ff, $0c
	db $ff, $8e, $f3, $97, $f4, $1c, $e5, $2d, $cd, $5f, $f6, $09, $1f, $00, $6e, $9f
	db $9c, $5f, $78, $37, $b4, $17, $dc, $9f, $fc, $f7, $fc, $f1, $33, $f0, $16, $f8
	db $1f, $f8, $3b, $ec, $3d, $cb, $5b, $d0, $74, $d0, $72, $37, $77, $ea, $eb, $95
	db $9d, $6a, $6e, $18, $dc, $89, $ed, $72, $fb, $22, $63, $de, $7a, $df, $df, $35
	db $f5, $92, $d6, $e1, $f9, $04, $ee, $06, $16, $b1, $d1, $f7, $bd, $f6, $f7, $59
	db $5f, $92, $d6, $0e, $3e, $41, $ef, $c0, $d1, $1a, $17, $d9, $dd, $ae, $ae, $52
	db $73, $ac, $ed, $30, $77, $23, $6f, $9c, $be, $88, $8c, $1f, $98, $1f, $d0, $3f
	db $f0, $3f, $b8, $6f, $78, $a7, $b4, $17, $5c, $17, $9c, $d0, $79, $91, $b9, $a3
	db $eb, $a7, $ff, $a5, $fd, $a5, $fd, $a4, $fc, $a2, $fa, $53, $5b, $c9, $cd, $39
	db $3d, $c9, $fd, $35, $35, $2c, $6d, $b2, $f3, $c9, $c9, $7f, $b5, $c7, $4f, $e8
	db $62, $87, $b5, $00, $08, $00, $e7, $00, $f8, $81, $ff, $fd, $5b, $c7, $e5, $2f
	db $8d, $c3, $5b, $01, $21, $00, $cf, $00, $3f, $03, $ff, $94, $b5, $27, $67, $39
	db $79, $27, $7f, $59, $59, $69, $6d, $9a, $9e, $26, $26, $17, $3c, $13, $3a, $8b
	db $ae, $cb, $fe, $4b, $7e, $09, $18, $10, $8b, $be, $a3, $fb, $a3, $fb, $a7, $ff
	db $a6, $fe, $ae, $fe, $ab, $eb, $bd, $fd, $b1, $f1, $48, $59, $2c, $7c, $ba, $fb
	db $d2, $f6, $72, $ff, $dc, $df, $01, $0f, $0e, $1e, $7e, $fe, $20, $60, $1e, $fe
	db $10, $30, $1f, $ff, $62, $e2, $80, $80, $00, $1f, $fc, $ff, $08, $0c, $f0, $ff
	db $10, $18, $f0, $ff, $dc, $df, $1b, $1b, $03, $e3, $25, $35, $69, $7d, $bb, $bf
	db $96, $de, $9c, $fe, $77, $f7, $01, $e1, $81, $f1, $8b, $be, $8b, $be, $cb, $fe
	db $cb, $fe, $eb, $fe, $ab, $ae, $7b, $7e, $3b, $3e, $9a, $fa, $92, $b2, $da, $7a
	db $e4, $64, $f4, $74, $ed, $2d, $ee, $2e, $ff, $3b, $38, $3a, $1c, $3e, $10, $35
	db $20, $63, $f1, $fb, $f0, $fb, $42, $57, $e5, $ed, $00, $7f, $1f, $ff, $63, $fb
	db $c0, $fc, $40, $f7, $80, $f8, $80, $ff, $c0, $e7, $03, $fb, $c1, $fd, $b0, $be
	db $08, $7f, $04, $df, $04, $3f, $02, $ff, $02, $cf, $40, $70, $60, $78, $e0, $f8
	db $50, $5c, $50, $5c, $38, $bc, $34, $b4, $17, $d7, $bb, $be, $bf, $be, $a7, $a4
	db $7f, $7e, $47, $46, $7f, $7e, $9f, $9e, $ef, $ee, $fe, $1a, $fd, $0d, $fe, $06
	db $ff, $1f, $f9, $39, $f7, $77, $ff, $19, $ff, $00, $2c, $2c, $be, $ff, $ec, $ef
	db $6e, $6f, $eb, $eb, $3f, $3c, $ff, $d8, $ff, $08, $40, $78, $00, $0f, $00, $e0
	db $00, $ff, $ff, $ff, $09, $20, $02, $01, $39, $01, $e1, $01, $0f, $09, $06, $26
	db $0d, $cd, $0d, $ed, $0b, $eb, $83, $f3, $c3, $fb, $e0, $7c, $f8, $1f, $ff, $07
	db $77, $76, $7f, $7e, $bf, $bc, $b7, $b4, $ef, $e8, $1f, $10, $7f, $e0, $ff, $80
;@ path: gfx/monsters/pictures
;@ Picture of Mudou (species $D2): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked by
;@ LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1F1 packed).
MonPic_Mudou::
	db $40, $02, $0b, $ff, $0b, $ff, $fc, $02, $ff, $03, $ff, $01, $ff, $01, $0b, $00
	db $09, $80, $7f, $40, $bf, $a0, $bf, $f0, $df, $78, $df, $5e, $ff, $00, $ff, $01
	db $ff, $03, $fd, $05, $fb, $0a, $fb, $1e, $f7, $3c, $f7, $f4, $ff, $81, $fe, $87
	db $f9, $0f, $f1, $1d, $e3, $2a, $e3, $3a, $c3, $52, $c3, $52, $ff, $c0, $ff, $80
	db $0b, $00, $0b, $0b, $15, $00, $0b, $63, $06, $fc, $1b, $d7, $4e, $ef, $81, $ff
	db $9e, $fe, $28, $ec, $36, $f5, $66, $e5, $f0, $3c, $f2, $9a, $61, $65, $24, $ae
	db $c6, $f6, $81, $c9, $98, $df, $87, $b7, $1f, $78, $9f, $b3, $0c, $4d, $49, $eb
	db $c6, $de, $02, $26, $32, $f7, $c2, $db, $ff, $7e, $b1, $d7, $e5, $ef, $03, $ff
	db $f3, $ff, $29, $6f, $d9, $5f, $cd, $4f, $0b, $00, $0d, $01, $ff, $01, $fe, $03
	db $0b, $c4, $02, $fd, $07, $fd, $07, $63, $ea, $4f, $de, $c3, $fb, $c1, $fd, $c1
	db $fd, $a3, $bf, $24, $3d, $20, $2b, $c0, $4f, $78, $38, $60, $27, $30, $10, $1f
	db $0f, $cf, $c0, $21, $e0, $17, $f0, $07, $e4, $3d, $38, $0d, $c9, $19, $11, $f1
	db $e1, $e7, $07, $08, $0f, $d0, $1f, $8d, $af, $e5, $f7, $86, $bf, $06, $7f, $06
	db $7f, $8a, $fb, $49, $79, $09, $a9, $0b, $20, $02, $0b, $14, $12, $7f, $c0, $7f
	db $c0, $0b, $cc, $00, $fa, $0e, $fa, $0e, $fb, $0f, $fb, $0f, $f6, $1e, $f6, $1e
	db $30, $37, $51, $51, $89, $89, $87, $87, $01, $19, $21, $7d, $41, $dd, $41, $fd
	db $0f, $7f, $08, $de, $56, $7c, $ad, $fe, $74, $f1, $06, $a0, $87, $20, $8b, $20
	db $e0, $fd, $21, $f7, $d5, $7d, $6b, $ff, $5d, $1f, $c1, $1b, $d3, $09, $93, $29
	db $19, $d9, $15, $15, $22, $22, $c2, $c2, $01, $31, $09, $7d, $04, $76, $04, $7e
	db $0b, $1c, $10, $bf, $e0, $0b, $74, $12, $df, $f0, $df, $f0, $f6, $1e, $f6, $1f
	db $f5, $1d, $f4, $1c, $f4, $1c, $fd, $0d, $ff, $0e, $ff, $04, $81, $bd, $80, $be
	db $80, $be, $80, $ba, $84, $bd, $84, $9c, $82, $9e, $c1, $4f, $8b, $20, $c5, $90
	db $c6, $90, $c3, $94, $60, $4b, $60, $4c, $39, $26, $b0, $ab, $b3, $09, $f6, $02
	db $f6, $02, $a6, $52, $2c, $85, $6c, $04, $b8, $48, $1b, $ab, $02, $7a, $02, $fb
	db $03, $fb, $02, $ba, $42, $7a, $43, $73, $83, $f2, $07, $e4, $0b, $7c, $10, $5f
	db $70, $0b, $d4, $10, $7f, $60, $ff, $e0, $ff, $40, $ff, $06, $ff, $02, $0b, $30
	db $00, $fe, $03, $ff, $07, $0b, $16, $00, $e0, $e3, $9c, $fc, $e3, $ff, $9c, $df
	db $fb, $fb, $27, $b7, $ff, $fc, $ff, $00, $78, $f4, $0c, $6b, $67, $64, $1f, $ff
	db $00, $0c, $f0, $f0, $ff, $0f, $ff, $00, $3c, $5f, $60, $ac, $cd, $4d, $f0, $ff
	db $01, $61, $1f, $1f, $ff, $e0, $ff, $00, $0f, $8e, $73, $7e, $8f, $fe, $73, $f7
	db $be, $bf, $c9, $db, $ff, $7f, $ff, $00, $0b, $50, $05, $80, $ff, $c0, $0b, $00
	db $00

;@ path: gfx/monsters/pictures
;@ Picture of DeathMore (species $D3): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $16B packed).
MonPic_DeathMore::
	db $40, $02, $05, $ff, $05, $ff, $f4, $07, $ff, $08, $f9, $16, $f9, $16, $05
	db $00, $05, $00, $ff, $81, $fe, $42, $fe, $42, $05, $10, $07, $c0, $3f, $20, $3f
	db $a0, $05, $10, $07, $05, $31, $0f, $13, $35, $ed, $3d, $f2, $1f, $fc, $1f, $e3
	db $23, $fa, $3b, $ee, $2f, $f5, $1d, $fe, $42, $fe, $8f, $f8, $ce, $be, $b6, $8c
	db $8d, $b4, $b4, $ac, $be, $97, $9e, $3f, $20, $3f, $f8, $0f, $b9, $3e, $36, $18
	db $58, $16, $96, $9a, $be, $f4, $bc, $05, $00, $01, $f0, $0f, $0c, $03, $02, $0f
	db $0e, $13, $12, $2f, $3f, $05, $00, $01, $08, $ff, $0c, $ff, $0e, $ff, $0c, $f7
	db $16, $e7, $ec, $05, $00, $01, $38, $ff, $44, $cf, $b2, $cf, $b2, $ff, $82, $ff
	db $44, $f4, $1f, $fc, $0f, $fe, $07, $ff, $01, $05, $c6, $00, $fe, $03, $ff, $07
	db $b6, $b6, $bb, $bc, $ff, $f3, $dd, $ef, $f4, $b6, $d6, $5c, $d6, $d5, $55, $5e
	db $36, $b6, $6e, $9e, $ff, $e7, $5d, $7b, $17, $b6, $35, $9d, $35, $55, $d5, $3d
	db $51, $7f, $bf, $ff, $3f, $e0, $ff, $c0, $ff, $c0, $ff, $40, $bf, $e0, $7f, $70
	db $3f, $f8, $ff, $c0, $05, $30, $09, $38, $05, $30, $0b, $09, $fe, $02, $ff, $03
	db $fe, $07, $f8, $0e, $f0, $1f, $f3, $1a, $f1, $1d, $95, $94, $9b, $9e, $f7, $f6
	db $1b, $ea, $3d, $44, $37, $86, $97, $4e, $cd, $24, $54, $94, $ec, $3c, $f7, $37
	db $ec, $2b, $de, $11, $f6, $30, $f4, $39, $d9, $12, $ff, $c8, $bf, $a0, $ff, $e0
	db $3f, $f0, $0f, $38, $07, $fc, $e7, $2c, $c7, $5c, $05, $30, $0f, $0d, $fe, $09
	db $fe, $0c, $fb, $0b, $f5, $15, $05, $86, $10, $f7, $17, $f7, $15, $a7, $96, $7d
	db $fc, $92, $93, $6e, $6e, $17, $17, $16, $1e, $1f, $1d, $3f, $2d, $f2, $34, $df
	db $1f, $a4, $64, $bb, $3b, $f4, $74, $b4, $3c, $7c, $dc, $7e, $5a, $bf, $c8, $3f
	db $98, $ef, $e8, $57, $54, $05, $b6, $10, $77, $74, $77, $54, $05, $30, $0f, $0e
	db $18, $ff, $08, $ff, $08, $05, $10, $07, $e4, $ff, $04, $05, $30, $09, $93, $ff
	db $90, $05, $30, $09, $8c, $05, $e2, $1b, $05, $31, $0f, $0c

;@ path: gfx/monsters/pictures
;@ Picture of DeathMore (species $D4): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $230 packed).
MonPic_DeathMore_2::
	db $40, $02, $08, $ff
	db $08, $ff, $f0, $01, $fe, $02, $fe, $02, $fc, $05, $f8, $cb, $f9, $7f, $ff, $38
	db $df, $70, $bf, $a1, $ff, $e1, $3f, $e1, $1f, $91, $0f, $cd, $83, $e3, $08, $00
	db $01, $00, $ff, $01, $ff, $01, $fe, $82, $fe, $e3, $de, $d7, $08, $22, $04, $ff
	db $01, $ff, $81, $ff, $8f, $f7, $d7, $ff, $38, $f7, $1c, $fb, $0b, $fe, $0e, $f8
	db $0e, $f0, $13, $e0, $67, $83, $8f, $08, $20, $03, $80, $ff, $80, $7f, $40, $3f
	db $a6, $3f, $fc, $ee, $2e, $f7, $1f, $eb, $2f, $ed, $3d, $ca, $5a, $d3, $73, $d1
	db $71, $d1, $71, $49, $f9, $bd, $ff, $e3, $eb, $d3, $d3, $80, $c0, $03, $8f, $61
	db $79, $60, $7c, $5e, $76, $6b, $fb, $71, $f1, $bd, $fd, $a4, $a4, $60, $70, $4a
	db $5a, $e9, $ed, $f5, $dd, $ad, $bf, $1d, $1f, $7b, $7f, $4a, $4a, $0d, $1d, $a5
	db $b5, $2e, $6e, $24, $3e, $7b, $ff, $8f, $af, $97, $97, $02, $06, $81, $e3, $0d
	db $3d, $0d, $7d, $ef, $e8, $df, $f0, $af, $e8, $6f, $78, $a7, $b4, $97, $9c, $17
	db $1c, $17, $1c, $91, $b1, $a1, $e1, $a2, $e2, $a4, $e5, $08, $c6, $00, $a9, $eb
	db $aa, $ea, $0c, $3e, $84, $de, $40, $7c, $3d, $bd, $46, $c6, $86, $86, $06, $1f
	db $09, $39, $57, $7d, $33, $37, $f2, $f9, $17, $1f, $19, $59, $ca, $ed, $48, $7c
	db $14, $f7, $d4, $7c, $98, $d8, $9e, $3e, $d1, $f1, $30, $34, $a6, $6e, $24, $7d
	db $51, $df, $61, $f9, $43, $f7, $04, $7c, $78, $7b, $c4, $c7, $c2, $c3, $c1, $f1
	db $20, $38, $13, $1a, $0b, $0e, $8b, $8e, $4b, $4e, $08, $16, $10, $2b, $ae, $ab
	db $ae, $f2, $f2, $b2, $ba, $e1, $e9, $a0, $ea, $a0, $f7, $e1, $f7, $c1, $d5, $c3
	db $c6, $10, $73, $28, $69, $c7, $c7, $81, $81, $81, $81, $83, $82, $c3, $42, $e7
	db $24, $fb, $ff, $ad, $ad, $31, $3d, $03, $63, $01, $cf, $83, $fb, $e1, $77, $e3
	db $3b, $be, $ff, $6a, $6b, $19, $79, $81, $8d, $01, $e7, $83, $be, $0f, $dc, $8f
	db $b8, $10, $9c, $28, $2c, $c7, $c7, $02, $02, $02, $03, $83, $83, $87, $85, $cf
	db $48, $9f, $9e, $9b, $ba, $0f, $2e, $0b, $ae, $0b, $de, $0f, $de, $07, $56, $87
	db $c6, $e3, $e2, $e3, $ea, $c1, $c9, $c0, $5e, $c6, $5f, $cf, $5b, $ce, $5a, $ef
	db $7f, $e7, $24, $ff, $18, $ff, $00, $ff, $81, $7e, $c2, $7f, $c1, $ff, $80, $ff
	db $00, $f0, $7c, $c8, $cf, $c4, $ef, $84, $9f, $8f, $bf, $0c, $ac, $94, $f5, $e4
	db $6c, $1f, $7c, $27, $e6, $47, $ee, $43, $f3, $e2, $fa, $61, $6b, $53, $df, $4c
	db $ed, $cf, $48, $ff, $30, $ff, $01, $fe, $0a, $fc, $bf, $55, $f7, $42, $52, $1f
	db $df, $8f, $8e, $8f, $ae, $07, $26, $07, $f4, $c7, $f4, $a7, $b4, $e7, $f4, $ef
	db $fc, $e3, $6e, $fd, $3d, $fb, $1b, $ff, $1c, $ff, $0c, $ff, $04, $08, $20, $03
	db $08, $03, $00, $1f, $f3, $7f, $96, $97, $f9, $f9, $ff, $0e, $ee, $3a, $cf, $59
	db $8f, $f8, $5f, $f8, $87, $f4, $3f, $be, $ff, $c0, $ff, $00, $28, $38, $e7, $f7
	db $e3, $3f, $f4, $3f, $c3, $5f, $f8, $fb, $ff, $07, $ff, $00, $7f, $73, $ef, $a9
	db $f7, $17, $fb, $fb, $9c, $fc, $d7, $d7, $3f, $3f, $ff, $e0, $8f, $ee, $7b, $7e
	db $bb, $be, $f3, $fa, $e3, $f2, $c7, $e4, $1f, $18, $ff, $e0

;@ path: gfx/monsters/pictures
;@ Picture of DeathMore (species $D5): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1A9 packed).
MonPic_DeathMore_3::
	db $40, $02, $0d, $ff
	db $0d, $ff, $f1, $7f, $70, $cf, $cf, $f5, $35, $fb, $0f, $fc, $07, $0d, $00, $02
	db $ff, $00, $ff, $98, $77, $7c, $ab, $af, $d5, $d7, $0d, $10, $05, $0d, $ff, $f0
	db $08, $f7, $dc, $0d, $20, $09, $21, $df, $77, $0d, $10, $05, $33, $dd, $7d, $ab
	db $eb, $56, $0d, $1f, $03, $fd, $1c, $e7, $e6, $5f, $58, $bf, $e0, $7f, $c0, $ff
	db $03, $0d, $20, $09, $00, $6a, $eb, $95, $f5, $ea, $7a, $f7, $1f, $fa, $0f, $fd
	db $07, $ff, $07, $fd, $05, $f7, $fc, $6b, $ee, $9b, $df, $8a, $ee, $cb, $cf, $42
	db $c2, $b1, $f1, $29, $69, $de, $7f, $ad, $ef, $b2, $f6, $a3, $ef, $a6, $e7, $85
	db $87, $1b, $1f, $29, $2d, $ad, $af, $53, $5e, $af, $bc, $df, $f0, $0d, $5c, $01
	db $c0, $7f, $40, $ff, $80, $0d, $62, $0a, $0d, $b2, $0c, $fe, $02, $ff, $01, $ff
	db $00, $ff, $01, $ff, $03, $fc, $0f, $f3, $1f, $ec, $3c, $d1, $db, $dd, $cd, $aa
	db $f6, $18, $ba, $18, $5d, $ae, $f6, $4f, $69, $2e, $2a, $16, $b6, $77, $67, $ab
	db $de, $31, $bb, $31, $75, $ea, $df, $e5, $2d, $e8, $a8, $0d, $b0, $05, $80, $7f
	db $e0, $9f, $f0, $6f, $78, $0d, $b2, $0f, $06, $06, $f9, $09, $ff, $0f, $fa, $0a
	db $dc, $74, $f8, $69, $f8, $0b, $f0, $02, $f8, $08, $fc, $1d, $e4, $25, $f4, $f7
	db $13, $97, $13, $13, $29, $bb, $5a, $fc, $5b, $f8, $28, $ac, $1c, $f7, $1f, $b3
	db $90, $d2, $90, $91, $28, $bb, $b4, $7e, $b4, $3e, $28, $6b, $70, $df, $f0, $9b
	db $77, $5c, $3f, $2c, $3f, $a0, $1f, $80, $3f, $20, $7f, $40, $7f, $40, $3f, $b1
	db $0d, $20, $09, $c0, $3f, $20, $fe, $0b, $fe, $6b, $9c, $9c, $e0, $f1, $d0, $9b
	db $e9, $cb, $f2, $f6, $a2, $b6, $d4, $df, $b6, $9f, $ef, $af, $cf, $ce, $cf, $d8
	db $07, $1e, $21, $21, $40, $49, $3f, $20, $0d, $b0, $09, $80, $f8, $09, $fe, $03
	db $0d, $d2, $01, $0d, $ff, $f3, $4f, $c9, $de, $de, $d6, $f7, $da, $f3, $ee, $2a
	db $e6, $27, $e6, $37, $c1, $f1, $ff, $e0, $bf, $a0, $ff, $a0, $ff, $ac, $73, $72
	db $0f, $1e, $17, $b2, $2f, $a6, $d4, $dc, $e8, $4b, $f8, $3f, $ff, $0d, $0f, $05
	db $46, $77, $7b, $f9, $f7, $d3, $ff, $0c, $0d, $a6, $16, $0d, $b0, $0b, $01, $fe
	db $03, $fe, $03, $ff, $0d, $b3, $15, $08, $08, $04, $24, $c4, $dc, $bc, $3f, $de
	db $97, $ff, $61, $0d, $00, $00, $9f, $de, $8b, $da, $57, $76, $2f, $a4, $3f, $f8
	db $ff, $c0, $0d, $00, $00

;@ path: gfx/monsters/pictures
;@ Picture of Darkdrium (species $D6): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Also used for species $D8, $D9, $DA, $DB, $DC,
;@ $DD, ... (the unused records at the end of MonsterPicRefs). Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1A9 packed).
MonPic_Darkdrium::
	db $40, $02, $06, $ff, $06, $ff, $fc, $18, $ff, $0c, $ff
	db $0a, $ff, $0a, $ff, $12, $fb, $16, $06, $1a, $00, $06, $00, $01, $04, $ff, $07
	db $fc, $05, $fe, $02, $fe, $02, $ff, $01, $06, $00, $03, $36, $d5, $d5, $d7, $7d
	db $55, $dd, $5d, $7f, $06, $00, $01, $08, $ff, $38, $df, $e8, $1f, $d0, $1f, $10
	db $ff, $e0, $06, $00, $0d, $06, $ff, $fb, $f7, $2a, $f7, $2c, $f7, $4c, $e7, $5b
	db $e3, $5d, $e7, $5a, $d7, $6a, $fb, $75, $ff, $00, $ff, $01, $ff, $63, $df, $f8
	db $e7, $3f, $fb, $1e, $ed, $1d, $f4, $3c, $a2, $be, $b6, $aa, $ff, $63, $ff, $dd
	db $ff, $10, $ef, $30, $20, $ff, $ff, $ff, $ff, $80, $ff, $c0, $ff, $60, $ff, $8f
	db $f6, $7f, $df, $76, $bf, $f5, $ff, $f5, $06, $00, $05, $80, $ff, $80, $7f, $f0
	db $df, $b0, $06, $00, $09, $01, $ff, $02, $ff, $09, $ff, $0b, $fd, $1f, $fb, $3d
	db $ff, $17, $ff, $6c, $ff, $9a, $ef, $79, $f6, $5a, $fb, $bf, $fa, $66, $b5, $eb
	db $73, $fe, $d7, $ef, $ad, $bf, $39, $3f, $df, $a7, $7f, $f9, $bf, $e6, $bb, $e5
	db $ff, $f1, $bb, $e7, $ac, $fc, $73, $73, $6f, $b0, $fb, $c4, $fe, $65, $ff, $ff
	db $8f, $fa, $ef, $fa, $47, $7d, $87, $fd, $ff, $60, $06, $b8, $00, $06, $00, $07
	db $04, $ff, $09, $ff, $09, $ff, $13, $ff, $12, $ff, $14, $ff, $0c, $ff, $0c, $87
	db $fe, $02, $ff, $05, $ff, $8f, $fe, $c2, $7f, $c1, $7f, $c3, $7f, $ee, $3d, $c2
	db $ff, $e2, $ff, $c2, $7f, $82, $ff, $82, $ff, $42, $ff, $42, $ff, $f1, $7f, $8f
	db $8c, $4f, $c8, $57, $d8, $37, $f8, $57, $b8, $53, $bc, $8b, $7c, $89, $7e, $47
	db $fd, $c7, $7d, $a3, $7e, $e3, $3e, $06, $66, $12, $c3, $7e, $06, $b4, $04, $06
	db $74, $15, $04, $06, $00, $0a, $fe, $19, $fc, $0b, $fc, $0b, $fe, $09, $fe, $0d
	db $ff, $0c, $fb, $0e, $fd, $07, $61, $bf, $c2, $7e, $06, $a2, $12, $41, $ff, $61
	db $bf, $a1, $7f, $5d, $be, $74, $b7, $54, $d7, $52, $d3, $50, $d2, $18, $1a, $14
	db $1c, $dc, $dd, $c3, $7e, $63, $be, $b7, $7c, $d7, $7d, $57, $fd, $27, $bd, $37
	db $bd, $3f, $6a, $06, $74, $13, $06, $51, $0f, $06, $fe, $03, $06, $2e, $05, $06
	db $ff, $f1, $e7, $bf, $df, $bb, $fe, $53, $fc, $54, $f8, $3f, $ff, $3f, $ff, $60
	db $ff, $00, $3e, $e3, $df, $b1, $9f, $11, $7f, $61, $06, $14, $14, $3f, $2c, $1f
	db $50, $3f, $50, $2f, $38, $9f, $a8, $ef, $78, $ff, $30, $06, $50, $0e

;@ path: gfx/monsters/pictures
;@ Picture of TERRY (species $D7): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked by
;@ LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $19D packed).
MonPic_TERRY::
	db $40, $02
	db $04, $ff, $04, $ff, $ff, $03, $80, $ff, $c0, $bf, $e0, $5f, $30, $ff, $50, $04
	db $00, $01, $03, $fc, $05, $fb, $0b, $f8, $0f, $f0, $14, $f0, $13, $04, $00, $01
	db $e0, $3f, $b0, $1f, $58, $1f, $98, $e7, $f4, $0f, $ce, $04, $00, $07, $78, $c7
	db $44, $d7, $56, $04, $00, $0f, $04, $04, $ff, $f5, $ef, $58, $bf, $08, $f7, $2c
	db $d7, $0c, $fb, $16, $eb, $07, $fd, $0b, $f5, $03, $fb, $1b, $d4, $16, $fb, $3f
	db $c4, $77, $93, $d7, $3c, $3f, $47, $d7, $82, $ba, $7d, $7f, $95, $35, $ea, $ea
	db $12, $d2, $65, $6d, $07, $37, $0b, $6b, $f2, $fa, $d9, $5c, $53, $5a, $d1, $dc
	db $d3, $da, $d1, $dc, $f3, $fa, $91, $dc, $93, $da, $04, $50, $0f, $08, $01, $fe
	db $03, $f8, $03, $fe, $05, $fa, $09, $f3, $12, $e1, $28, $c1, $d3, $01, $65, $03
	db $cf, $02, $ba, $b2, $f2, $fe, $fe, $59, $d9, $5c, $dc, $ae, $6f, $b9, $79, $d7
	db $bf, $5c, $34, $0c, $ac, $14, $14, $eb, $eb, $1e, $3e, $7f, $ff, $f1, $f7, $90
	db $93, $08, $3d, $91, $dd, $f2, $fa, $d0, $dc, $d2, $db, $d0, $dd, $f3, $7b, $f3
	db $de, $b7, $fe, $04, $14, $00, $3f, $00, $7f, $40, $1f, $80, $3f, $e0, $8f, $c0
	db $df, $70, $fc, $07, $f0, $07, $f8, $0d, $f8, $0b, $e0, $0b, $f0, $17, $04, $2a
	db $10, $06, $77, $0c, $ef, $1d, $f7, $1e, $d6, $3e, $e6, $3f, $a1, $3f, $a0, $7f
	db $c1, $76, $6e, $ea, $da, $f6, $37, $e2, $fa, $e3, $bb, $ff, $9f, $ff, $86, $e7
	db $17, $08, $bb, $08, $e9, $11, $17, $13, $93, $1e, $7f, $bf, $e7, $fc, $67, $fe
	db $07, $ef, $9c, $ff, $88, $7f, $88, $ef, $d8, $1f, $f0, $5f, $b0, $ff, $f0, $3f
	db $a0, $ff, $30, $f7, $10, $ff, $18, $ff, $08, $ff, $08, $ff, $10, $ff, $10, $ff
	db $20, $e0, $07, $f8, $0b, $f8, $09, $fc, $05, $fe, $02, $ff, $01, $04, $00, $00
	db $7f, $c1, $7f, $c1, $7f, $c3, $7e, $c3, $7c, $c7, $3e, $a7, $bb, $e3, $fc, $65
	db $c7, $07, $e7, $0f, $cf, $18, $9f, $f8, $7f, $f0, $1f, $d0, $df, $d0, $7f, $60
	db $ff, $0f, $f9, $09, $fc, $0c, $ff, $03, $04, $8a, $12, $04, $32, $00, $ff, $c0
	db $ff, $f0, $1f, $58, $ff, $f8, $04, $50, $0f, $0d, $04, $00, $02, $fe, $16, $fd
	db $05, $f8, $08, $f8, $0e, $f9, $0b, $fd, $0d, $ff, $07, $04, $be, $13, $04, $03
	db $20, $80, $ff, $80, $04, $ca, $1f, $13, $04, $00, $0a

;@ path: system/sgb/border
;@ Super Game Boy border 2, second half of its tiles (CHR_TRN packet $11): $1000 bytes of uncompressed 4-bit SNES
;@ tiles, copied as they are by SGBTransfer from LoadSGBBorder.
SGBBorder2TilesB::
	db $6e, $14, $ef, $ed, $ff
	db $d4, $ee, $4c, $da, $9a, $bd, $89, $5d, $01, $56, $52, $63, $c3, $6f, $d3, $7b
	db $ff, $ff, $ff, $9f, $ff, $bb, $7f, $3b, $ff, $7b, $ff, $d5, $83, $eb, $2c, $f6
	db $a3, $be, $17, $e3, $c2, $a0, $a6, $d9, $d1, $aa, $a5, $1d, $e3, $b3, $c7, $b6
	db $cf, $fe, $ff, $f1, $ff, $c6, $f9, $fd, $fe, $ff, $72, $df, $dc, $94, $d8, $c3
	db $cf, $ab, $e0, $3d, $59, $ff, $24, $67, $42, $ff, $c0, $c7, $a8, $07, $e8, $82
	db $7d, $af, $5f, $bc, $fe, $ff, $ff, $ef, $ff, $f7, $ef, $d6, $b7, $f6, $b5, $ee
	db $19, $fd, $d7, $f3, $ab, $5f, $db, $5a, $07, $8e, $2d, $58, $e0, $58, $e0, $e0
	db $f0, $e8, $f0, $f4, $78, $b4, $38, $b8, $dc, $da, $ec, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $cf, $63, $cb, $00, $c6
	db $00, $8f, $01, $92, $30, $8e, $21, $ce, $20, $8e, $21, $b7, $cf, $97, $ef, $9a
	db $ef, $d6, $ef, $e7, $cf, $f6, $cf, $b6, $cf, $f6, $cf, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $da, $d3, $ff, $d7, $ff
	db $b7, $7f, $1a, $db, $ab, $fa, $aa, $db, $a9, $fe, $8c, $f7, $fe, $f7, $ff, $f7
	db $ff, $ff, $ff, $5f, $ff, $7f, $df, $5f, $ff, $7f, $ff, $be, $75, $37, $99, $af
	db $93, $fe, $fe, $f9, $98, $a5, $55, $17, $77, $f6, $72, $fb, $aa, $77, $ff, $ef
	db $df, $ff, $ff, $ff, $fe, $7e, $8e, $8e, $ec, $fd, $f8, $1a, $31, $e2, $9a, $e2
	db $f2, $e8, $09, $a9, $7c, $ff, $fc, $3e, $60, $b9, $68, $e6, $cf, $f6, $0f, $16
	db $0f, $2e, $16, $2a, $17, $3f, $1f, $fa, $3f, $b1, $7e, $c6, $b3, $fc, $6d, $4c
	db $45, $72, $b1, $ee, $63, $83, $1c, $3b, $2c, $f0, $9f, $d6, $ec, $f6, $c6, $7e
	db $fe, $3c, $7e, $fc, $f0, $f0, $e0, $f0, $c0, $50, $e0, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $86, $87, $f4, $bc, $b3
	db $99, $d3, $b1, $c7, $82, $cb, $83, $d7, $ba, $dc, $b4, $d1, $ee, $aa, $c7, $ee
	db $c7, $e6, $cf, $d7, $ef, $97, $ef, $ae, $c7, $a7, $cf, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $fc, $94, $fe, $ae, $ef
	db $b7, $d7, $84, $cb, $88, $e2, $a2, $e6, $ba, $76, $3a, $7f, $ff, $6f, $ff, $7f
	db $ef, $7f, $ff, $7e, $ff, $7d, $de, $7d, $c2, $e5, $c2, $11, $40, $7c, $82, $ab
	db $79, $ff, $fe, $f4, $33, $fe, $1f, $7f, $ce, $eb, $f9, $1f, $e0, $7d, $83, $a7
	db $df, $ff, $ff, $f8, $ff, $3a, $fd, $1e, $ff, $8f, $77, $69, $8b, $6d, $4c, $f9
	db $68, $f3, $b0, $f1, $c1, $d7, $03, $f8, $1b, $f1, $cc, $60, $fc, $e7, $f8, $f7
	db $fc, $fe, $dd, $ff, $bf, $ef, $ff, $1f, $fc, $f3, $fc, $90, $8f, $eb, $1c, $f3
	db $8c, $f6, $a9, $e6, $e9, $b6, $39, $00, $37, $ec, $17, $50, $e0, $d0, $e0, $b0
	db $40, $50, $e0, $f0, $f0, $f0, $f0, $f8, $c0, $d8, $e0, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $fd, $96, $dd, $c0, $f9
	db $d6, $fd, $c4, $df, $c0, $9e, $80, $bc, $80, $a8, $c4, $b3, $f9, $b3, $f9, $d3
	db $b9, $d1, $bb, $f1, $bb, $b1, $fb, $bb, $f3, $bb, $f3, $62, $00, $59, $01, $7d
	db $01, $0d, $01, $41, $00, $f1, $00, $89, $00, $0d, $01, $81, $ff, $87, $ff, $83
	db $ff, $f3, $ff, $bf, $ff, $0f, $ff, $77, $ff, $f3, $ff, $0f, $c5, $fe, $01, $c6
	db $da, $5e, $1d, $cd, $0a, $c3, $14, $c7, $4c, $c1, $0a, $2e, $b3, $be, $e7, $f5
	db $ee, $fa, $e4, $a4, $78, $f0, $28, $b0, $38, $b4, $f8, $cf, $e3, $cb, $80, $c6
	db $80, $8f, $81, $92, $b0, $8e, $a1, $ce, $a0, $8e, $a1, $b7, $cf, $97, $ef, $9a
	db $ef, $d6, $ef, $e7, $cf, $f6, $cf, $b6, $cf, $f6, $cf, $86, $87, $f4, $bc, $b3
	db $99, $d3, $b1, $c7, $82, $cb, $83, $d7, $ba, $dc, $b4, $d1, $ee, $aa, $c7, $ee
	db $c7, $e6, $cf, $d7, $ef, $97, $ef, $ae, $c7, $a7, $cf, $ff, $ff, $ff, $fe, $fe
	db $fc, $fd, $f8, $fd, $f2, $fb, $e5, $f7, $cb, $d4, $91, $ff, $ff, $ff, $ff, $ff
	db $ff, $fd, $fe, $fd, $fb, $fb, $f7, $e7, $ff, $de, $ef, $ff, $ff, $7f, $3f, $7f
	db $ff, $fe, $fc, $f8, $fd, $fb, $e7, $f5, $cc, $9a, $38, $ff, $ff, $ff, $ff, $ff
	db $7f, $ff, $ff, $f9, $fe, $f4, $f8, $eb, $f0, $c7, $e1, $ff, $fc, $ef, $ce, $e8
	db $4a, $eb, $65, $87, $a7, $5f, $5f, $ff, $3f, $f0, $30, $ff, $ff, $f4, $f8, $87
	db $f1, $5b, $87, $6f, $1f, $ff, $3f, $7f, $ff, $cf, $ff, $ff, $7f, $ff, $bf, $7f
	db $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $c7, $c3, $ff, $ff, $7f, $7f, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $3f, $fe, $ff, $ff, $ff, $ff, $fd
	db $f9, $f6, $f4, $fa, $ee, $e5, $88, $b8, $48, $5c, $c4, $ff, $ff, $ff, $ff, $ff
	db $ff, $fd, $fb, $fd, $f3, $f6, $f3, $b6, $27, $27, $38, $ff, $ff, $fe, $fe, $cc
	db $c8, $2d, $61, $fb, $80, $08, $00, $1b, $84, $bf, $c0, $ff, $ff, $ff, $ff, $df
	db $fe, $9b, $9c, $3c, $19, $b3, $7c, $a0, $40, $00, $00, $ff, $ff, $73, $73, $c6
	db $54, $0e, $59, $79, $52, $81, $f7, $fc, $03, $e0, $1f, $ff, $ff, $ff, $f3, $7f
	db $f3, $af, $c6, $9c, $8c, $09, $00, $00, $00, $00, $00, $ff, $ff, $df, $bf, $af
	db $4f, $7a, $c0, $ff, $82, $6e, $0c, $3a, $c8, $57, $b2, $ff, $ff, $df, $ff, $ff
	db $5f, $b7, $9d, $68, $31, $d3, $e3, $4c, $3f, $00, $0c, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $3f, $bf, $bf, $30, $6f, $45, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $7f, $ff, $bf, $7f, $f3, $fc, $ce, $0c, $de, $93, $79
	db $47, $e2, $be, $73, $3d, $67, $28, $6e, $84, $ff, $ff, $62, $31, $6d, $61, $f6
	db $e6, $fd, $fd, $ee, $ce, $d7, $d2, $5f, $fd, $ff, $ff, $3b, $a7, $43, $bd, $27
	db $f8, $80, $7f, $87, $78, $db, $24, $96, $71, $bf, $1f, $59, $87, $80, $80, $fc
	db $00, $ff, $7f, $78, $78, $21, $23, $8e, $0f, $ff, $ff, $a8, $ac, $f9, $80, $e0
	db $cc, $e4, $c8, $f1, $80, $d1, $80, $c2, $90, $aa, $a8, $e3, $f3, $f6, $e3, $d6
	db $e3, $d2, $e7, $ee, $c7, $ee, $c7, $ec, $c7, $dc, $c7, $9b, $00, $b2, $00, $0e
	db $01, $5e, $02, $0f, $07, $0b, $09, $4d, $08, $99, $18, $67, $ff, $0f, $ff, $3f
	db $fe, $3f, $ff, $7f, $ff, $7f, $ff, $39, $ff, $7d, $ff, $ff, $a0, $87, $90, $cf
	db $64, $37, $52, $f9, $40, $7d, $20, $76, $1a, $1f, $0d, $c8, $f0, $e8, $f0, $d8
	db $b0, $a4, $d8, $9a, $fc, $cd, $fe, $e4, $ff, $fa, $f7, $88, $03, $70, $ff, $07
	db $f8, $00, $ff, $87, $ff, $bb, $3e, $0b, $c3, $87, $04, $03, $fc, $00, $00, $00
	db $00, $00, $00, $00, $00, $c6, $01, $c7, $3f, $7f, $ff, $27, $b8, $03, $e8, $c3
	db $20, $c7, $d0, $ef, $0e, $7a, $02, $cd, $0d, $36, $b0, $b9, $47, $1b, $07, $17
	db $0f, $3f, $0f, $df, $3f, $ff, $fc, $e3, $f0, $4d, $83, $df, $00, $3c, $28, $59
	db $00, $e4, $10, $70, $27, $a5, $87, $9a, $02, $ef, $c0, $8f, $ff, $9e, $ff, $bd
	db $fe, $e7, $f8, $bf, $c0, $67, $18, $62, $fd, $f0, $ff, $25, $60, $5b, $40, $27
	db $00, $ff, $20, $9f, $cf, $bc, $1d, $70, $37, $63, $34, $5f, $83, $3f, $87, $ef
	db $1f, $ef, $1f, $bf, $7f, $7f, $fe, $fd, $f9, $ec, $f4, $80, $00, $30, $b0, $6b
	db $97, $b2, $1a, $3f, $8e, $3f, $bb, $8d, $25, $f9, $09, $c5, $fa, $0f, $c0, $61
	db $80, $e7, $c1, $79, $c7, $77, $4f, $5f, $7f, $ff, $7f, $cb, $43, $f6, $95, $bb
	db $00, $a7, $18, $3d, $08, $7c, $30, $78, $60, $f0, $80, $fb, $3e, $f1, $7a, $e3
	db $f7, $be, $e7, $7e, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $73, $83, $21, $0d, $c4
	db $06, $e2, $03, $f0, $06, $70, $04, $10, $03, $3e, $00, $64, $78, $ce, $f0, $07
	db $f8, $03, $fc, $07, $f8, $87, $f8, $e3, $fc, $c0, $ff, $9f, $e0, $0c, $f3, $01
	db $0f, $04, $f4, $00, $00, $70, $77, $09, $f9, $7e, $00, $00, $00, $00, $00, $f0
	db $00, $fb, $00, $ff, $00, $8f, $00, $f9, $06, $00, $ff, $00, $ff, $a3, $bf, $f0
	db $ff, $49, $4e, $00, $61, $43, $f8, $83, $f8, $87, $e1, $00, $00, $40, $00, $00
	db $00, $b0, $00, $ff, $00, $f8, $07, $f8, $07, $e0, $1f, $7b, $81, $03, $fe, $3a
	db $fd, $45, $c6, $62, $fb, $20, $05, $1c, $05, $08, $05, $07, $00, $01, $00, $00
	db $00, $38, $00, $fc, $00, $c6, $f8, $e6, $f8, $f6, $f8, $fb, $31, $ae, $eb, $41
	db $08, $b9, $15, $df, $25, $ea, $0b, $f7, $06, $70, $89, $6d, $86, $9e, $1c, $f6
	db $3f, $73, $00, $19, $03, $1e, $05, $0c, $00, $06, $03, $ff, $80, $bd, $c3, $72
	db $8e, $48, $7f, $93, $10, $18, $14, $cc, $9c, $60, $53, $00, $00, $00, $00, $81
	db $00, $87, $80, $90, $ef, $d0, $ef, $2f, $70, $dc, $e0, $bd, $14, $37, $10, $72
	db $30, $5a, $10, $5e, $49, $ee, $45, $ee, $65, $fe, $74, $7f, $ff, $f7, $ff, $f7
	db $ff, $ff, $ff, $fe, $ff, $fa, $ff, $fa, $ff, $fa, $ff, $e0, $a0, $fd, $d0, $b7
	db $90, $f7, $c0, $d1, $c0, $d1, $e0, $f0, $88, $f8, $b8, $9c, $cf, $a8, $cf, $e8
	db $cf, $f8, $cf, $dc, $ef, $dc, $ef, $f7, $ef, $ff, $e7, $bd, $00, $fb, $03, $eb
	db $e1, $c0, $d1, $11, $02, $df, $0b, $4b, $03, $9d, $41, $ff, $ff, $fc, $00, $18
	db $07, $36, $0f, $ce, $3c, $3c, $fc, $dd, $3d, $bb, $7f, $c3, $00, $98, $88, $08
	db $38, $37, $07, $c6, $46, $f7, $83, $9b, $58, $07, $6f, $ff, $ff, $78, $07, $47
	db $80, $d8, $e0, $7e, $39, $2f, $1f, $60, $87, $f0, $80, $ff, $07, $3f, $77, $d7
	db $d2, $c7, $07, $1c, $ed, $f2, $c3, $92, $22, $b1, $f7, $ff, $ff, $0f, $ff, $3f
	db $0f, $3e, $0f, $1e, $ff, $fa, $fd, $3e, $c1, $0f, $00, $7b, $03, $ae, $8e, $ff
	db $7c, $4f, $0b, $86, $00, $2c, $01, $e0, $00, $4f, $07, $f7, $8f, $9f, $ff, $fe
	db $ff, $3f, $ff, $7d, $fe, $d1, $fe, $1f, $ff, $3f, $ff, $bf, $20, $dc, $00, $02
	db $00, $d2, $30, $86, $80, $8c, $90, $89, $00, $83, $81, $f0, $bf, $23, $bf, $e1
	db $7f, $b9, $c7, $71, $0f, $73, $0f, $07, $ff, $ff, $ff, $7f, $30, $5f, $0f, $61
	db $08, $62, $44, $fd, $57, $dd, $87, $cb, $84, $7b, $24, $e0, $e0, $e0, $e0, $c7
	db $ff, $d1, $ff, $ed, $c3, $e1, $c3, $f7, $e7, $f3, $fb, $bb, $95, $ff, $d4, $ff
	db $fc, $ff, $80, $fe, $00, $f0, $00, $8c, $08, $14, $0a, $ff, $7b, $73, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f3, $ff, $e0, $ff, $e0, $00, $f0, $00, $f0
	db $00, $f9, $00, $39, $10, $11, $10, $58, $18, $78, $48, $ff, $ff, $ff, $ff, $ff
	db $ff, $fe, $ff, $fe, $ff, $f6, $ef, $a3, $c7, $87, $03, $38, $00, $78, $02, $78
	db $00, $ed, $00, $c2, $00, $86, $00, $83, $32, $87, $30, $c0, $ff, $82, $fd, $80
	db $ff, $00, $ff, $01, $ff, $01, $fe, $30, $cc, $38, $c0, $ff, $00, $e0, $00, $81
	db $03, $27, $18, $1c, $23, $9c, $63, $ef, $10, $f9, $0f, $00, $ff, $1f, $ff, $7e
	db $fc, $d0, $e0, $43, $83, $03, $03, $60, $00, $30, $00, $46, $00, $41, $00, $e7
	db $e8, $e2, $09, $56, $a9, $61, $b3, $4f, $e4, $e1, $44, $3f, $ff, $bf, $ff, $1b
	db $07, $1f, $06, $95, $8e, $9f, $8c, $32, $19, $d8, $33, $92, $0b, $af, $1f, $c2
	db $63, $01, $f9, $71, $05, $80, $04, $f8, $03, $6c, $61, $ec, $f0, $d0, $e0, $7c
	db $80, $fe, $00, $06, $f8, $77, $f8, $03, $fc, $61, $9e, $01, $fc, $e0, $fe, $00
	db $ff, $1c, $ff, $11, $f0, $47, $4c, $03, $f8, $40, $1c, $03, $01, $00, $01, $00
	db $00, $00, $00, $0f, $00, $bc, $03, $f8, $07, $1f, $e3, $91, $0e, $9b, $43, $7f
	db $03, $bf, $93, $2f, $00, $07, $09, $87, $09, $0f, $0c, $e8, $f0, $f7, $b8, $7b
	db $9c, $73, $7c, $b9, $7f, $47, $bf, $7f, $97, $af, $df, $fe, $54, $7a, $44, $ea
	db $24, $7b, $a5, $3f, $35, $bf, $0d, $3a, $89, $1e, $4d, $fa, $ff, $fa, $ff, $7a
	db $ff, $7b, $fe, $7f, $fa, $f7, $7a, $32, $ff, $b6, $fb, $fc, $a0, $ff, $96, $f6
	db $9d, $de, $8c, $ca, $8b, $e4, $85, $86, $96, $cf, $e3, $ef, $f7, $f8, $f7, $f6
	db $fb, $fe, $fb, $de, $fd, $de, $ff, $df, $ef, $b7, $cf, $fe, $70, $3b, $90, $3a
	db $10, $9c, $68, $9e, $0c, $ff, $1e, $1f, $1b, $ff, $e1, $f9, $ff, $7c, $ff, $bc
	db $7f, $9f, $7f, $7f, $ff, $ff, $ff, $07, $ff, $1f, $ff, $c0, $4f, $7f, $00, $f6
	db $00, $29, $30, $fa, $52, $53, $cd, $e0, $7f, $bc, $03, $4f, $b0, $00, $ff, $1f
	db $ff, $ff, $ef, $f1, $fd, $c0, $60, $df, $9f, $c0, $80, $51, $4f, $87, $06, $fa
	db $05, $0b, $91, $92, $96, $4f, $b2, $9f, $67, $ff, $38, $bf, $00, $06, $f9, $01
	db $fe, $f7, $6f, $fd, $f8, $9f, $00, $3f, $1f, $ff, $7f, $5b, $08, $e0, $c7, $0f
	db $00, $5c, $63, $e0, $9f, $52, $45, $d6, $2b, $ea, $c3, $3c, $ff, $38, $f0, $f0
	db $e0, $83, $83, $1f, $1f, $b9, $01, $bc, $c0, $f3, $fc, $bf, $22, $49, $e1, $f6
	db $01, $06, $fb, $08, $f6, $39, $cc, $67, $ed, $cf, $33, $7e, $ff, $3e, $1c, $09
	db $00, $f9, $f8, $f3, $f1, $c7, $c3, $1f, $03, $f7, $0f, $fe, $02, $5e, $99, $df
	db $10, $de, $1b, $fa, $83, $fb, $db, $e7, $e0, $f9, $1b, $7b, $ff, $e6, $7f, $7f
	db $e0, $fc, $e0, $fc, $e0, $f4, $e0, $f7, $f8, $fd, $fe, $5f, $0a, $3f, $d0, $f0
	db $8f, $e0, $1f, $fc, $03, $d0, $ea, $d1, $14, $66, $e0, $ec, $f0, $60, $80, $0f
	db $0f, $1f, $1f, $00, $00, $07, $01, $ee, $03, $ff, $1f, $ff, $0c, $fa, $11, $7b
	db $a2, $67, $a6, $eb, $d2, $5d, $a7, $de, $e3, $3d, $19, $04, $03, $0e, $04, $94
	db $8c, $8c, $98, $2c, $18, $d8, $38, $d8, $3c, $ff, $fe, $2c, $03, $18, $47, $f0
	db $0f, $00, $ff, $80, $7f, $60, $9f, $b9, $c6, $e8, $f7, $d3, $e3, $e7, $07, $0f
	db $0f, $ff, $ff, $7f, $7f, $1f, $1f, $06, $06, $07, $07, $3f, $f7, $3e, $d2, $2a
	db $f3, $28, $ea, $5c, $90, $7b, $e0, $3e, $1e, $d5, $67, $d8, $c0, $d5, $c8, $cb
	db $dc, $fc, $df, $ff, $bf, $ff, $3f, $7f, $ff, $2c, $18, $c3, $58, $b7, $58, $66
	db $d1, $27, $00, $17, $00, $f7, $f0, $7b, $38, $9e, $ee, $e6, $31, $f6, $21, $ef
	db $30, $37, $f8, $ff, $f8, $ff, $f8, $ff, $fc, $5f, $3f, $be, $80, $bf, $00, $c7
	db $00, $30, $80, $df, $20, $f1, $0b, $f9, $01, $60, $81, $80, $7f, $00, $ff, $00
	db $ff, $c0, $7f, $e0, $1f, $fa, $04, $fe, $00, $ff, $00, $20, $3c, $07, $70, $19
	db $77, $a7, $18, $70, $2f, $7f, $84, $93, $e0, $6e, $9c, $3f, $c3, $72, $8d, $74
	db $88, $50, $e0, $8f, $cf, $00, $00, $7b, $1c, $6d, $f3, $29, $57, $0f, $1c, $ca
	db $21, $88, $41, $7e, $a3, $d6, $22, $fd, $41, $fd, $60, $b9, $cf, $df, $e5, $4e
	db $f5, $6a, $37, $8e, $93, $07, $1b, $d7, $3b, $f7, $fb, $db, $8d, $ff, $e9, $fe
	db $85, $eb, $91, $c3, $a9, $53, $ba, $7b, $b9, $7a, $4c, $f7, $fa, $f7, $fa, $7e
	db $f3, $7a, $e7, $43, $fe, $41, $fe, $7b, $c6, $3a, $c7, $cf, $b3, $ab, $92, $9f
	db $a1, $92, $b0, $8e, $91, $e6, $80, $8e, $91, $cb, $e1, $f7, $cf, $d7, $ef, $f6
	db $cf, $e7, $cf, $d6, $ef, $ce, $ff, $d6, $ef, $b6, $cf, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $a2, $84, $7f, $06, $0e
	db $00, $e1, $81, $e7, $e7, $30, $3c, $00, $00, $ff, $ff, $fd, $c3, $ff, $ff, $3f
	db $ff, $60, $1e, $18, $00, $3c, $c3, $ff, $ff, $ff, $ff, $ff, $ff, $f0, $10, $58
	db $1f, $80, $9f, $e0, $e0, $16, $40, $00, $00, $ff, $ff, $ff, $ff, $ef, $ff, $9f
	db $e0, $60, $00, $1f, $00, $40, $bf, $ff, $ff, $ff, $ff, $fd, $f8, $1f, $0e, $43
	db $c1, $18, $f8, $e7, $e7, $30, $3c, $00, $00, $ff, $ff, $fe, $ff, $ff, $ff, $ff
	db $3f, $01, $07, $18, $00, $3c, $c3, $ff, $ff, $ff, $ff, $7f, $87, $ff, $1a, $e3
	db $e0, $0f, $08, $04, $ff, $7b, $0e, $00, $00, $ff, $ff, $0f, $ff, $ff, $ff, $ff
	db $fe, $eb, $f7, $ff, $00, $0e, $f1, $ff, $ff, $ff, $ff, $ff, $ed, $ff, $4f, $ff
	db $b2, $3e, $06, $0d, $e5, $7d, $05, $02, $02, $ff, $fe, $9f, $7f, $bf, $ff, $ff
	db $fe, $fe, $ff, $ef, $1f, $07, $ff, $ff, $ff, $ff, $ff, $ff, $fc, $33, $07, $70
	db $6f, $79, $64, $22, $55, $d6, $dd, $6e, $69, $9f, $97, $ff, $ff, $f6, $f8, $0f
	db $cf, $03, $80, $fa, $8c, $f1, $f9, $f1, $f1, $f8, $f0, $ff, $0e, $1b, $c0, $ef
	db $00, $ff, $40, $87, $78, $1e, $e5, $7f, $b6, $bf, $3f, $ff, $ff, $47, $3f, $1f
	db $00, $80, $00, $78, $78, $e3, $e0, $9f, $8f, $ff, $7f, $67, $78, $f7, $03, $fc
	db $ad, $c3, $39, $be, $66, $7d, $30, $de, $07, $ff, $ff, $c0, $80, $fc, $f8, $42
	db $01, $1f, $07, $3f, $1f, $fe, $ff, $e6, $f9, $ff, $ff, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $db, $5c, $fc, $03, $eb
	db $1e, $1f, $e0, $3b, $e1, $af, $32, $f8, $98, $ff, $ff, $9b, $e7, $fc, $7f, $01
	db $00, $e3, $e1, $03, $07, $ff, $c7, $7f, $ff, $ff, $ff, $a7, $63, $ef, $87, $7f
	db $3f, $ff, $71, $f5, $e0, $f3, $66, $fc, $34, $ba, $b4, $af, $df, $df, $3f, $7f
	db $ff, $ff, $ff, $fb, $ff, $ff, $f9, $f5, $fb, $b5, $fb, $e4, $80, $c0, $02, $d1
	db $06, $b1, $02, $8d, $00, $83, $00, $b0, $02, $a0, $0c, $f7, $fb, $f5, $fb, $e5
	db $fb, $c1, $ff, $f1, $ff, $fd, $ff, $c3, $fd, $cf, $f1, $bf, $47, $ff, $80, $71
	db $0e, $2d, $df, $da, $1d, $f7, $92, $7e, $55, $c7, $0a, $bf, $7f, $ff, $bf, $f1
	db $ff, $2d, $f3, $6a, $a7, $f5, $ae, $ea, $fd, $f7, $39

;@ path: system/sgb/border
;@ Super Game Boy border 2: its map and colours for the PCT_TRN packet ($0F), unpacked to $8800 and sent by
;@ SGBTransferCompressed from LoadSGBBorder. Compressed in the DecompressCore format ($880 bytes unpacked, $37D
;@ packed).
SGBBorder2Map::
	db $80, $08, $66, $07, $10
	db $01, $10, $02, $10, $03, $10, $04, $10, $05, $10, $06, $66, $0b, $0f, $04, $b5
	db $10, $b6, $10, $b7, $10, $b8, $10, $b9, $10, $ba, $10, $bb, $10, $bc, $10, $bd
	db $10, $04, $50, $03, $50, $02, $50, $01, $50, $07, $10, $10, $10, $11, $10, $12
	db $10, $13, $10, $14, $10, $15, $10, $16, $10, $17, $10, $18, $66, $4b, $07, $66
	db $4c, $00, $c3, $10, $c4, $10, $c5, $10, $c6, $10, $c7, $10, $c8, $10, $c9, $10
	db $ca, $10, $cb, $10, $cc, $10, $cd, $10, $ce, $10, $13, $50, $12, $50, $11, $50
	db $10, $50, $20, $10, $21, $10, $22, $14, $23, $14, $24, $10, $25, $10, $26, $10
	db $27, $10, $28, $66, $8b, $07, $d1, $10, $d2, $10, $d3, $10, $d4, $10, $d5, $10
	db $d6, $10, $d7, $10, $d8, $10, $d9, $10, $da, $10, $db, $10, $dc, $10, $dd, $10
	db $de, $10, $23, $54, $22, $54, $21, $50, $20, $50, $30, $10, $31, $10, $32, $14
	db $33, $14, $34, $10, $35, $10, $36, $10, $37, $10, $38, $66, $cb, $07, $e1, $10
	db $e2, $10, $e3, $10, $e4, $10, $e5, $10, $e6, $10, $e7, $10, $e8, $10, $e9, $10
	db $ea, $10, $eb, $10, $ec, $10, $ed, $10, $ee, $10, $33, $54, $32, $54, $31, $50
	db $30, $50, $40, $10, $41, $10, $42, $10, $43, $10, $44, $10, $45, $10, $46, $10
	db $47, $10, $48, $66, $0b, $17, $46, $10, $f2, $10, $f3, $10, $f4, $10, $f5, $10
	db $f6, $10, $f7, $10, $f8, $10, $f9, $10, $be, $10, $bf, $10, $fc, $10, $fd, $10
	db $fe, $10, $ff, $10, $42, $50, $41, $50, $40, $50, $50, $10, $51, $10, $52, $10
	db $53, $10, $54, $10, $55, $10, $fa, $66, $4b, $1f, $14, $b0, $10, $b1, $10, $b2
	db $10, $52, $50, $51, $50, $50, $50, $60, $10, $61, $10, $62, $10, $63, $10, $64
	db $10, $65, $66, $4b, $1f, $16, $c0, $10, $c1, $10, $c2, $10, $52, $50, $71, $d0
	db $50, $50, $70, $10, $71, $10, $72, $10, $73, $10, $74, $10, $75, $66, $4b, $1f
	db $16, $d0, $10, $cf, $10, $73, $50, $72, $50, $71, $50, $70, $50, $70, $90, $71
	db $90, $72, $90, $73, $90, $54, $66, $89, $1f, $18, $e0, $10, $df, $10, $73, $d0
	db $72, $d0, $61, $d0, $70, $d0, $60, $90, $71, $10, $62, $90, $63, $90, $64, $90
	db $66, $ca, $1f, $17, $f0, $10, $ef, $10, $63, $d0, $62, $d0, $71, $50, $60, $d0
	db $66, $80, $14, $66, $08, $2f, $19, $65, $50, $64, $50, $63, $50, $62, $50, $71
	db $50, $60, $66, $bf, $1f, $22, $75, $50, $74, $50, $66, $f8, $1c, $74, $90, $66
	db $8a, $1f, $17, $b4, $10, $80, $10, $81, $10, $82, $10, $83, $10, $66, $3e, $26
	db $54, $66, $c9, $1f, $18, $b3, $10, $90, $10, $91, $10, $92, $10, $93, $10, $66
	db $7e, $26, $66, $88, $1f, $19, $65, $d0, $a0, $10, $a1, $10, $a2, $10, $a3, $10
	db $70, $d0, $66, $c0, $14, $66, $48, $3f, $19, $66, $f4, $2f, $2d, $65, $50, $74
	db $d0, $66, $38, $20, $71, $66, $3d, $2f, $24, $75, $50, $54, $50, $66, $78, $20
	db $61, $d0, $66, $7e, $2f, $2b, $61, $66, $bd, $27, $64, $66, $c9, $3f, $1a, $54
	db $66, $f7, $25, $09, $10, $0a, $10, $0b, $10, $0c, $66, $c7, $3f, $1d, $66, $37
	db $45, $19, $10, $1a, $10, $1b, $10, $1c, $10, $1d, $10, $1e, $66, $8b, $3f, $18
	db $64, $d0, $66, $78, $44, $29, $10, $2a, $10, $2b, $10, $2c, $10, $2d, $10, $2e
	db $66, $8b, $4f, $22, $39, $10, $3a, $10, $3b, $10, $3c, $10, $3d, $10, $3e, $10
	db $48, $90, $0f, $10, $56, $10, $47, $90, $48, $90, $46, $90, $66, $d2, $56, $66
	db $d2, $5e, $45, $d0, $44, $d0, $43, $d0, $42, $d0, $41, $d0, $40, $d0, $49, $10
	db $4a, $10, $4b, $10, $4c, $10, $4d, $10, $4e, $10, $4f, $10, $1f, $10, $57, $10
	db $58, $10, $37, $90, $36, $90, $37, $90, $38, $66, $15, $63, $66, $18, $66, $66
	db $1c, $64, $35, $d0, $34, $d0, $33, $d4, $32, $d4, $31, $d0, $30, $d0, $59, $10
	db $5a, $10, $5b, $10, $5c, $10, $5d, $10, $5e, $10, $5f, $10, $2f, $10, $67, $10
	db $68, $10, $28, $90, $26, $90, $27, $90, $66, $54, $64, $66, $58, $66, $66, $5c
	db $64, $25, $d0, $24, $d0, $23, $d4, $22, $d4, $21, $d0, $20, $d0, $69, $10, $6a
	db $10, $6b, $10, $6c, $10, $6d, $10, $6e, $10, $6f, $10, $3f, $10, $77, $10, $78
	db $10, $18, $90, $16, $90, $17, $90, $66, $94, $64, $66, $98, $66, $66, $9c, $64
	db $15, $d0, $14, $d0, $13, $d0, $12, $d0, $11, $d0, $10, $d0, $07, $10, $01, $90
	db $02, $90, $03, $90, $7d, $10, $7e, $10, $7f, $10, $0d, $10, $0e, $10, $06, $90
	db $66, $d2, $6f, $0d, $05, $d0, $04, $d0, $03, $d0, $02, $d0, $01, $d0, $07, $10
	db $fb, $66, $ff, $6f, $4d, $66, $5f, $7f, $4d, $66, $9f, $7f, $2c, $00, $00, $d6
	db $56, $94, $4a, $72, $42, $30, $42, $ef, $39, $ee, $35, $ad, $31, $ac, $2d, $6b
	db $25, $6a, $29, $29, $25, $28, $1d, $e6, $18, $7b, $6f, $66, $fc, $f0, $ef, $2d
	db $cd, $35, $8c, $2d, $49, $4d, $4a, $25, $08, $31, $08, $21, $08, $1d, $c6, $18
	db $c6, $28, $a5, $2c, $85, $24, $a5, $10, $64, $20, $30, $46, $00, $00, $1f, $7c
	db $66, $42, $8f, $09, $66, $40, $8f, $0d

;@ path: system/sgb/border
;@ Super Game Boy border 3: its map and colours for the PCT_TRN packet ($0F), unpacked to $8800 and sent by
;@ SGBTransferCompressed from LoadSGBBorder. Compressed in the DecompressCore format ($880 bytes unpacked, $3F3
;@ packed).
SGBBorder3Map::
	db $80, $08, $34, $15, $50, $14, $50, $13
	db $50, $12, $50, $11, $50, $20, $90, $21, $90, $20, $d0, $01, $10, $34, $10, $0f
	db $01, $11, $10, $21, $d0, $34, $24, $00, $1a, $50, $13, $10, $13, $d0, $22, $50
	db $34, $10, $04, $13, $10, $15, $10, $14, $10, $34, $00, $02, $10, $50, $11, $90
	db $21, $50, $20, $34, $35, $05, $34, $10, $06, $20, $10, $21, $10, $11, $d0, $34
	db $64, $00, $15, $10, $23, $10, $11, $34, $0f, $05, $13, $10, $14, $10, $14, $50
	db $24, $10, $25, $10, $25, $10, $15, $10, $13, $10, $10, $34, $51, $07, $34, $0a
	db $00, $12, $10, $1a, $10, $11, $34, $51, $0f, $00, $34, $22, $02, $13, $10, $25
	db $50, $24, $50, $10, $10, $34, $06, $00, $21, $10, $22, $10, $34, $82, $00, $14
	db $50, $34, $a0, $06, $11, $90, $34, $c8, $00, $22, $34, $4f, $09, $1a, $50, $12
	db $34, $5f, $07, $34, $10, $00, $22, $10, $23, $10, $34, $4e, $02, $eb, $10, $ec
	db $10, $ed, $10, $ee, $10, $f0, $10, $f1, $10, $ef, $34, $0b, $11, $34, $14, $10
	db $ef, $50, $f1, $50, $ed, $50, $ec, $50, $34, $20, $10, $f0, $50, $ee, $34, $23
	db $11, $eb, $34, $51, $07, $02, $58, $34, $40, $14, $f2, $10, $fa, $00, $34, $4c
	db $1f, $13, $f2, $50, $02, $18, $34, $76, $14, $30, $50, $34, $40, $14, $f3, $34
	db $4b, $1f, $16, $f3, $34, $75, $15, $30, $10, $19, $50, $18, $50, $17, $50, $16
	db $50, $03, $58, $f4, $34, $4b, $1f, $16, $f4, $50, $03, $18, $16, $10, $17, $10
	db $18, $10, $19, $10, $29, $50, $28, $50, $27, $50, $26, $50, $40, $50, $f5, $34
	db $4b, $1f, $16, $f5, $50, $40, $10, $26, $10, $27, $10, $28, $10, $29, $10, $05
	db $18, $34, $40, $24, $f6, $34, $4b, $1f, $16, $f6, $50, $2a, $10, $05, $10, $0d
	db $10, $0e, $10, $0f, $34, $3f, $21, $e5, $34, $3f, $21, $f7, $34, $4b, $1f, $16
	db $f7, $50, $1b, $10, $1c, $10, $1d, $10, $1e, $10, $1f, $10, $05, $18, $e6, $10
	db $e7, $10, $e8, $10, $e9, $10, $34, $4a, $1f, $19, $2b, $10, $2c, $10, $2d, $10
	db $2e, $10, $2f, $10, $06, $58, $34, $00, $34, $34, $8a, $1f, $19, $3b, $10, $3c
	db $10, $3d, $10, $3e, $10, $3f, $34, $ff, $27, $34, $ca, $1f, $19, $4b, $10, $4c
	db $10, $4d, $10, $4e, $10, $4f, $10, $07, $58, $34, $80, $34, $f4, $90, $34, $cc
	db $1f, $16, $d0, $5b, $10, $5c, $10, $5d, $10, $5e, $10, $5f, $10, $08, $58, $34
	db $c0, $34, $f3, $34, $8b, $3f, $16, $f3, $d0, $6b, $10, $6c, $10, $6d, $10, $6e
	db $10, $6f, $10, $09, $18, $34, $00, $44, $f2, $34, $8b, $3f, $16, $f2, $d0, $7b
	db $10, $7c, $10, $7d, $10, $7e, $10, $7f, $34, $ff, $31, $0a, $34, $01, $41, $f7
	db $34, $8b, $3f, $16, $f7, $d0, $34, $00, $44, $8d, $34, $01, $41, $0b, $34, $01
	db $41, $f6, $34, $8b, $3f, $16, $f6, $d0, $8c, $34, $01, $41, $8e, $18, $8f, $18
	db $31, $18, $32, $18, $0c, $18, $33, $58, $32, $58, $f5, $34, $8b, $3f, $16, $f5
	db $d0, $9b, $18, $9c, $18, $9d, $18, $9e, $18, $9f, $18, $39, $18, $36, $18, $37
	db $18, $38, $58, $39, $18, $34, $8a, $3f, $19, $ab, $18, $ac, $18, $ad, $18, $ae
	db $18, $af, $18, $46, $18, $99, $d8, $45, $58, $46, $58, $45, $34, $c9, $3f, $1a
	db $bb, $18, $bc, $18, $bd, $18, $be, $18, $bf, $18, $45, $18, $41, $14, $42, $14
	db $43, $14, $99, $98, $34, $0a, $4f, $19, $cb, $98, $cc, $18, $cd, $18, $ce, $18
	db $cf, $18, $50, $14, $51, $14, $52, $14, $53, $14, $54, $14, $eb, $90, $ec, $90
	db $ed, $90, $ee, $90, $f0, $90, $f1, $90, $ef, $34, $cb, $51, $34, $d4, $50, $ef
	db $d0, $f1, $d0, $ed, $d0, $ec, $d0, $34, $e0, $50, $f0, $d0, $ee, $34, $e3, $51
	db $eb, $d0, $cd, $98, $c6, $18, $8a, $18, $c6, $98, $8b, $18, $60, $14, $61, $14
	db $62, $14, $63, $14, $64, $14, $65, $14, $66, $14, $67, $14, $68, $14, $69, $14
	db $8b, $58, $59, $58, $a0, $18, $a1, $98, $a2, $18, $a3, $18, $a4, $18, $8b, $d8
	db $b6, $18, $c8, $14, $a6, $18, $8a, $18, $47, $18, $48, $18, $c8, $14, $b7, $98
	db $b7, $18, $89, $98, $ce, $18, $cc, $18, $c6, $18, $89, $98, $70, $14, $71, $14
	db $72, $14, $73, $14, $74, $14, $75, $14, $76, $14, $77, $14, $78, $14, $79, $14
	db $d0, $18, $d1, $18, $b0, $18, $b1, $18, $b2, $18, $b3, $18, $b4, $18, $b5, $18
	db $d5, $58, $a7, $18, $a8, $58, $a9, $14, $44, $18, $a8, $58, $b8, $18, $b6, $98
	db $47, $d8, $8b, $d8, $d7, $18, $d8, $18, $d9, $18, $da, $18, $80, $14, $81, $14
	db $82, $14, $83, $14, $84, $14, $85, $14, $86, $14, $87, $14, $88, $14, $89, $58
	db $b0, $58, $b1, $18, $c0, $18, $c1, $18, $c2, $18, $c3, $18, $c4, $18, $c5, $18
	db $c6, $18, $b7, $18, $b8, $18, $b9, $18, $8b, $d8, $89, $98, $a6, $d8, $34, $7a
	db $62, $dc, $18, $dd, $58, $de, $18, $dd, $18, $90, $14, $91, $14, $92, $14, $93
	db $14, $94, $14, $95, $14, $96, $14, $97, $14, $98, $18, $a0, $34, $97, $61, $d6
	db $18, $c6, $18, $d2, $18, $d3, $18, $d4, $18, $44, $58, $a5, $18, $c7, $d8, $c8
	db $14, $db, $18, $e0, $18, $e1, $34, $b7, $64, $58, $e2, $18, $e3, $18, $05, $18
	db $df, $18, $fb, $10, $34, $00, $7f, $4d, $34, $20, $7f, $0b, $34, $a0, $ff, $4d
	db $34, $e0, $ff, $0d, $ff, $47, $00, $00, $61, $00, $c3, $08, $82, $09, $8a, $12
	db $0e, $23, $92, $33, $a7, $00, $cf, $31, $71, $4a, $d8, $52, $ff, $7f, $06, $72
	db $69, $7e, $ed, $7e, $ff, $47, $25, $00, $61, $00, $c0, $04, $42, $09, $09, $0e
	db $8e, $3a, $f4, $3e, $e8, $14, $4b, $21, $cf, $31, $92, $4e, $58, $67, $9d, $0c
	db $34, $3a, $80, $34, $20, $82, $34, $06, $88, $aa, $00, $0f, $01, $72, $01, $f3
	db $1d, $34, $1a, $84, $34, $3a, $82, $34, $62, $8f, $05

;@ path: unused/leftovers
;@ Bytes after the last block that nothing reads: leftovers from building the ROM (pieces of other data), then
;@ filler.
Leftover_32::
	db $3e, $49, $32, $3a, $07
	db $38, $04, $3e, $06, $18, $02, $3e, $0e, $e0, $90, $3e, $0a, $e0, $94, $2e, $80
	db $cb, $d6, $fa, $3e, $d5, $a7, $20, $09, $21, $9a, $ff, $7e, $ee, $80, $77, $18
	db $08, $3e, $0a, $cd, $90, $43, $c3, $6b, $3a, $21, $9b, $ff, $3e, $48, $32, $3a
	db $07, $38, $04, $3e, $06, $18, $02, $3e, $0e, $e0, $90, $3e, $0a, $e0, $94, $2e
	db $80, $cb, $d6, $fa, $3e, $d5, $a7, $28, $0a, $21, $9a, $ff, $7e, $ee, $80, $77
	db $c3, $08, $77, $3e, $0a, $cd, $90, $43, $c3, $78, $3a, $21, $9c, $ff, $3e, $9f
	db $32, $3e, $42, $32, $2d, $af, $32, $2e, $89, $7e, $e6, $c0, $f6, $00, $32, $3e
	db $0a, $cd, $90, $43, $c3, $85, $3a, $21, $94, $ff, $35, $c0, $2c, $35, $4e, $35
	db $20, $03, $3e, $08, $77, $6b, $62, $06, $00, $09, $3a, $e0, $94, $7e, $21, $9a
	db $ff, $cb, $7e, $28, $02, $c6, $08, $e0, $90, $c9, $02, $0c, $00, $07, $01, $0c
	db $00, $07, $05, $0f, $04, $10, $03, $06, $00, $10, $21, $85, $ff, $7e, $d6, $02
	db $22, $30, $0d, $35, $18, $0a, $21, $85, $ff, $7e, $c6, $02, $22, $30, $01, $34
	db $2e, $80, $cb, $de, $f0, $98, $a7, $28, $29, $3e, $81, $e0, $9c, $18, $23, $f0
	db $9b, $a7, $20, $42, $2e, $83, $2a, $e0, $a6, $2a, $e0, $a5, $2a, $e0, $a8, $7e
	db $e0, $a7, $af, $ea, $a0, $c6, $cd, $0f, $14, $a7, $28, $06, $fa, $a0, $c6, $a7
	db $28, $24, $21, $99, $ff, $7e, $06, $42, $c6, $e0, $4f, $0a, $fe, $80, $20, $04
	db $0d, $0a, $18, $01, $34, $2e, $83, $fe, $80, $4e, $30, $05, $81, $22, $d0, $34
	db $c9, $81, $22, $d8, $35, $c9, $21, $99, $ff, $af, $32, $3e, $01, $77, $c9, $3e
	db $81, $e0, $9c, $21, $9f, $ff, $3e, $78, $32, $3e, $49, $32, $2e, $80, $cb, $e6
	db $2e, $8d, $3e, $06, $32, $3e, $f9, $32, $c9, $f0, $9b, $ef, $06, $79, $b3, $79
	db $d8, $7a, $e0, $7a, $4c, $7c, $54, $7c, $77, $7c, $8f, $7c, $03, $7c, $0d, $7c
	db $b1, $38, $06, $79, $06, $79, $06, $79, $06, $79, $85, $7b, $af, $7b, $35, $79
	db $0a, $7d, $cd, $7b, $5c, $7b, $64, $7b, $fc, $7a, $2c, $7b, $d8, $7c, $a7, $7c
	db $81, $39, $8e, $39, $9b, $39, $06, $79, $06, $79, $06, $79, $cb, $38, $e5, $38
	db $ff, $38, $19, $39, $33, $39, $4d, $39, $67, $39, $74, $39, $42, $7c, $38, $7c
	db $47, $79, $bc, $7a, $06, $79, $06, $79, $06, $79, $06, $79, $a8, $39, $ce, $79
	db $e0, $3a, $ed, $3a, $37, $3a, $1d, $3a, $87, $7c, $9f, $7c, $26, $39, $0c, $39
	db $be, $38, $06, $79, $06, $79, $06, $79, $06, $79, $92, $7b, $bc, $7b, $3f, $79
	db $1e, $7d, $eb, $7b, $dc, $39, $e9, $39, $1a, $7b, $4a, $7b, $f2, $7c, $c1, $7c
	db $92, $3a, $9f, $3a, $c6, $3a, $d3, $3a, $ac, $3a, $b9, $3a, $d8, $38, $f2, $38
	db $0c, $39, $26, $39, $40, $39, $5a, $39, $dc, $39, $e9, $39, $06, $79, $06, $79
	db $5c, $79, $ce, $7a, $06, $79, $21, $9b, $ff, $3e, $30, $32, $fa, $60, $c6, $c6
	db $2a, $47, $f0, $8f, $c6, $2a, $b8, $38, $06, $cb, $be, $3e, $00, $18, $04, $cb
	db $fe, $3e, $04, $e0, $90, $2d, $af, $32, $2e, $89, $7e, $e6, $c0, $f6, $10, $32
	db $2e, $80, $cb, $a6, $c9, $21, $9b, $ff, $3e, $41, $32, $2d, $af, $32, $c9, $3e
	db $04, $cd, $9d, $43, $c3, $b5, $39, $21, $9b, $ff, $3e, $5a, $32, $2e, $96, $3e
	db $30, $32, $3e, $04, $32, $3e, $01, $32, $3e, $71, $e0, $ac, $fa, $c8, $c6, $fe
	db $10, $38, $05, $3e, $1c, $e0, $9b, $c9, $21, $94, $ff, $35, $20, $1e, $2c, $35
	db $4e, $35, $20, $03, $3e, $04, $77, $21, $af, $79, $06, $00, $09, $3a, $e0, $94
	db $7e, $21, $9a, $ff, $cb, $7e, $28, $02, $c6, $04, $e0, $90, $2e, $96, $7e, $fe
	db $18, $20, $13, $f0, $9a, $07, $38, $05, $01, $2b, $48, $18, $03, $01, $42, $48
	db $cd, $c1, $37, $21, $96, $ff, $35, $c2, $10, $3a, $3e, $2b, $e0, $9b, $c9, $03
	db $20, $00, $10, $21, $9b, $ff, $3e, $31, $32, $3a, $07, $38, $04, $3e, $00, $18
	db $02, $3e, $04, $e0, $90, $2e, $95, $3e, $04, $32, $3e, $0d, $32, $c9, $fa, $c8
	db $c6, $fe, $10, $38, $05, $3e, $1a, $e0, $9b, $c9, $3e, $0d, $cd, $9d, $43, $0e
	db $2a, $fa, $5f, $c6, $81, $47, $f0, $8e, $81, $90, $fe, $21, $38, $04, $fe, $e0
	db $38, $20, $21, $9a, $ff, $fa, $60, $c6, $81, $47, $f0, $8f, $81, $90, $fe, $c0
	db $30, $0c, $fe, $40, $30, $0c, $2a, $17, $38, $08, $3e, $2a, $77, $c9, $2a, $17
	db $38, $f8, $21, $83, $ff, $2a, $e0, $a6, $2a, $e0, $a5, $2a, $e0, $a8, $7e, $e0
	db $a7, $cd, $cd, $13, $a7, $21, $89, $ff, $20, $07, $cb, $b6, $3e, $11, $e0, $9b
	db $c9, $cb, $f6, $2e, $83, $f0, $a6, $22, $f0, $a5, $22, $f0, $9a, $07, $38, $3e
	db $7e, $e6, $0f, $d6, $07, $30, $07, $cd, $f5, $13, $e6, $0f, $28, $2b, $21, $83
	db $ff, $2a, $d6, $04, $e0, $a6, $2a, $de, $00, $e0, $a5, $2a, $d6, $07, $e0, $a8
	db $2a, $de, $00, $e0, $a7, $cd, $b8, $14, $a7, $20, $0e, $f0, $a9, $1f, $d0, $21
	db $85, $ff, $7e, $d6, $01, $22, $d0, $35, $c9, $3e, $13, $e0, $9b, $c9, $7e, $e6
	db $0f, $c6, $06, $fe, $10, $38, $07, $cd, $fd, $13, $e6, $0f, $28, $29, $21, $83
	db $ff, $2a, $d6, $04, $e0, $a6, $2a, $de, $00, $e0, $a5, $2a, $c6, $06, $e0, $a8
	db $2a, $ce, $00, $e0, $a7, $cd, $b8, $14, $a7, $20, $0c, $f0, $a9, $1f, $d8, $21
	db $85, $ff, $34, $c0, $2c, $34, $c9, $3e, $13, $e0, $9b, $c9, $21, $9b, $ff, $3e
	db $5b, $32, $7e, $ee, $80, $77, $3e, $08, $e0, $96, $3e, $0e, $e0, $90, $21, $96
	db $ff, $35, $c0, $3e, $01, $e0, $9b, $c9, $21, $9b, $ff, $3e, $32, $32, $18, $06
	db $21, $9b, $ff, $3e, $33, $32, $3a, $07, $38, $04, $3e, $09, $18, $02, $3e, $0b
	db $e0, $90, $2e, $98, $3e, $02, $32, $2d, $3e, $20, $32, $c9, $21, $9b, $ff, $3e
	db $46, $32, $3a, $07, $38, $04, $3e, $08, $18, $02, $3e, $0a, $e0, $90, $3e, $0c
	db $e0, $94, $2e, $89, $7e, $e6, $c0, $f6, $00, $32, $3e, $0c, $cd, $90, $43, $21
	db $98, $ff, $7e, $a7, $c2, $c2, $39, $3e, $0f, $e0, $9b, $c9, $21, $9b, $ff, $3e
	db $47, $32, $3a, $07, $38, $04, $3e, $08, $18, $02, $3e, $0a, $e0, $90, $3e, $0c
	db $e0, $94, $2e, $89, $7e, $e6, $c0, $f6, $00, $32, $3e, $0c, $cd, $90, $43, $21
	db $98, $ff, $7e, $a7, $c2, $cf, $39, $3e, $0f, $e0, $9b, $c9, $21, $9b, $ff, $3e
	db $44, $32, $18, $06, $21, $9b, $ff, $3e, $45, $32, $3a, $07, $38, $04, $3e, $08
	db $18, $02, $3e, $0a, $e0, $90, $af, $32, $3e, $0c, $e0, $94, $2e, $89, $7e, $e6
	db $c0, $f6, $00, $32, $c9, $3e, $3f, $e0, $9b, $3e, $64, $e0, $96, $21, $80, $ff
	db $cb, $96, $fa, $c8, $c6, $fe, $10, $38, $05, $3e, $1c, $e0, $9b, $c9, $3e, $0c
	db $cd, $90, $43, $21, $96, $ff, $35, $c2, $f6, $39, $3e, $10, $e0, $9b, $c9, $21
	db $9b, $ff, $3e, $40, $32, $2d, $af, $32, $3e, $07, $e0, $96, $3e, $0c, $cd, $90
	db $43, $21, $96, $ff, $35, $c2, $03, $3a, $3e, $00, $e0, $9b, $c9, $21, $9b, $ff
	db $3e, $43, $32, $3a, $07, $38, $04, $3e, $00, $18, $02, $3e, $04, $e0, $90, $2e
	db $96, $3e, $30, $32, $3e, $04, $32, $3e, $04, $32, $c9, $fa, $c8, $c6, $fe, $10
	db $38, $05, $3e, $1a, $e0, $9b, $c9, $21, $96, $ff, $35, $c2, $10, $3a, $3e, $2b
	db $e0, $9b, $c9, $21, $9c, $ff, $3e, $8f, $32, $3e, $38, $18, $08, $21, $9c, $ff
	db $3e, $8f, $32, $3e, $39, $32, $3a, $07, $38, $04, $3e, $08, $18, $02, $3e, $0a
	db $e0, $90, $af, $32, $3e, $02, $32, $2d, $3e, $04, $32, $2d, $3e, $0c, $32, $2e
	db $89, $7e, $e6, $c0, $f6, $00, $32, $c9, $21, $9b, $ff, $3e, $34, $32, $06, $02
	db $18, $1a, $21, $9b, $ff, $3e, $35, $32, $06, $02, $18, $10, $21, $9b, $ff, $3e
	db $34, $32, $18, $06, $21, $9b, $ff, $3e, $35, $32, $06, $03, $7e, $e6, $f0, $32
	db $07, $38, $04, $3e, $09, $18, $02, $3e, $0b, $e0, $90, $af, $32, $78, $32, $3e
	db $01, $32, $3e, $81, $e0, $9c, $c9, $21, $9b, $ff, $3e, $36, $32, $2d, $3e, $42
	db $32, $3e, $10, $32, $3e, $01, $32, $3e, $0c, $cd, $90, $43, $c3, $51, $3a, $21
	db $9b, $ff, $3e, $37, $32, $2d, $3e, $42, $32, $3e, $30, $32, $3e, $01, $32, $3e
	db $0c, $cd, $90, $43, $c3, $5e, $3a, $21, $9b, $ff, $3e, $49, $32, $3a, $07, $38
	db $04, $3e, $08, $18, $02, $3e, $0a, $e0, $90, $3e, $0c, $e0, $94, $2e, $80, $cb
	db $d6, $fa, $3e, $d5, $a7, $20, $09, $21, $9a, $ff, $7e, $ee, $80, $77, $18, $08
	db $3e, $0c, $cd, $90, $43, $c3, $6b, $3a, $21, $9b, $ff, $3e, $48, $32, $3a, $07
	db $38, $04, $3e, $08, $18, $02, $3e, $0a, $e0, $90, $3e, $0c, $e0, $94, $2e, $80
	db $cb, $d6, $fa, $3e, $d5, $a7, $28, $0a, $21, $9a, $ff, $7e, $ee, $80, $77, $c3
	db $a7, $7c, $3e, $0c, $cd, $90, $43, $c3, $78, $3a, $21, $9c, $ff, $3e, $9f, $32
	db $3e, $42, $32, $2d, $af, $32, $2e, $89, $7e, $e6, $c0, $f6, $00, $32, $3e, $0c
	db $cd, $90, $43, $c3, $85, $3a, $21, $85, $ff, $7e, $d6, $02, $22, $30, $0d, $35
	db $18, $0a, $21, $85, $ff, $7e, $c6, $02, $22, $30, $01, $34, $2e, $80, $cb, $de
	db $f0, $98, $a7, $28, $29, $3e, $81, $e0, $9c, $18, $23, $f0, $9b, $a7, $20, $42
	db $2e, $83, $2a, $e0, $a6, $2a, $e0, $a5, $2a, $e0, $a8, $7e, $e0, $a7, $af, $ea
	db $a0, $c6, $cd, $0f, $14, $a7, $28, $06, $fa, $a0, $c6, $a7, $28, $24, $21, $99
	db $ff, $7e, $06, $42, $c6, $e0, $4f, $0a, $fe, $80, $20, $04, $0d, $0a, $18, $01
	db $34, $2e, $83, $fe, $80, $4e, $30, $05, $81, $22, $d0, $34, $c9, $81, $22, $d8
	db $35, $c9, $21, $99, $ff, $af, $32, $3e, $01, $77, $c9, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
