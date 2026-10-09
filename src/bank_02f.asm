INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $02f", ROMX[$4000], BANK[$2f]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_2F::
	db $2f

;@ path: gfx/monsters/tables
;@ Entry table of bank $2F: the address of each compressed block (entry number = position), as DecompressSetup
;@ finds it for Decompress / DecompressVRAM (bank, entry).
FarTable_2F::
	dw TerrySprite
	dw MonSprite_DrakSlime
	dw MonSprite_SpotSlime
	dw MonSprite_WingSlime
	dw MonSprite_TreeSlime
	dw MonSprite_Snaily
	dw MonSprite_SlimeNite
	dw MonSprite_Babble
	dw MonSprite_BoxSlime
	dw MonSprite_Slime
	dw MonSprite_Healer
	dw MonSprite_FangSlime
	dw MonSprite_RockSlime
	dw MonSprite_SlimeBorg
	dw MonSprite_Slabbit
	dw MonSprite_SpotKing
	dw MonSprite_KingSlime
	dw MonPic_DrakSlime
	dw MonPic_SpotSlime
	dw MonPic_WingSlime
	dw MonPic_TreeSlime
	dw MonPic_Snaily
	dw MonPic_SlimeNite
	dw MonPic_Babble
	dw MonPic_BoxSlime
	dw MonPic_Slime
	dw MonPic_Healer
	dw MonPic_FangSlime
	dw MonPic_RockSlime
	dw MonPic_SlimeBorg
	dw MonPic_Slabbit
	dw MonPic_SpotKing
	dw MonPic_KingSlime
	dw MonPic_Metaly
	dw MonPic_Metabble
	dw MonPic_MetalKing
	dw MonPic_GoldSlime
	dw MonPic_DragonKid
	dw MonPic_Tortragon
	dw MonPic_Pteranod
	dw MonPic_Gasgon
	dw MonPic_FairyDrak
	dw MonPic_LizardMan
	dw MonPic_Poisongon
	dw MonPic_Swordgon
	dw MonPic_Dragon
	dw MonPic_MiniDrak
	dw MonPic_MadDragon
	dw MonPic_Rayburn
	dw MonPic_Chamelgon
	dw MonPic_LizardFly
	dw MonPic_Andreal
	dw MonPic_KingCobra
	dw MonPic_Spikerous
	dw MonPic_GreatDrak
	dw MonPic_Crestpent

;@ path: gfx/sprites/terry
;@ Terry's walking sprite (20 tiles): unpacked to $8000 by PlacePlayerOnMap, the opening cutscene and the VS
;@ result screen; also entry 0 of MonsterGfxRefs and ActorGfx. Compressed in the DecompressCore format ($140
;@ bytes unpacked, $11A packed).
TerrySprite::
	db $40, $01, $01, $03, $03, $0c, $0f, $16, $1f, $2d, $3b, $3e, $31, $2d, $32
	db $5d, $72, $7b, $5e, $37, $3a, $4b, $7c, $f7, $9f, $68, $77, $1f, $1c, $2a, $37
	db $3f, $21, $1f, $1f, $ec, $5c, $d8, $38, $f4, $fc, $24, $fc, $f8, $48, $3c, $fc
	db $ec, $f4, $78, $78, $01, $fe, $f2, $1e, $1f, $2d, $33, $5e, $71, $3d, $22, $6b
	db $74, $01, $0e, $00, $1b, $1c, $2f, $3f, $2c, $37, $3b, $3c, $3c, $2f, $1f, $1f
	db $de, $7a, $ec, $5c, $d2, $3e, $ee, $fa, $3c, $fc, $d4, $6c, $fc, $84, $f8, $f8
	db $07, $07, $09, $0f, $12, $1f, $24, $3f, $29, $3f, $2a, $3f, $33, $3f, $16, $1d
	db $f0, $f0, $88, $f8, $3c, $fc, $f6, $ca, $ba, $de, $fc, $ac, $78, $c8, $fc, $2c
	db $1f, $1c, $1a, $17, $0f, $0f, $0a, $0f, $17, $1d, $1a, $1f, $37, $2f, $1e, $1e
	db $fc, $24, $e8, $18, $01, $70, $00, $78, $b8, $5c, $e4, $01, $5c, $00, $00, $00
	db $f0, $f0, $b8, $f8, $7c, $cc, $d6, $ba, $bb, $6d, $fe, $ce, $f8, $08, $16, $1d
	db $01, $80, $02, $19, $1f, $34, $2f, $1e, $13, $0f, $0f, $fc, $2c, $01, $90, $02
	db $28, $f8, $bc, $dc, $72, $fe, $fc, $fc, $0c, $0c, $1b, $17, $3c, $2f, $10, $1f
	db $20, $3f, $20, $3f, $70, $7f, $f0, $bf, $ec, $bf, $73, $7f, $3c, $3f, $5b, $77
	db $7f, $7c, $3e, $33, $21, $3f, $1f, $1f, $37, $fd, $ce, $fe, $38, $f8, $d4, $fc
	db $fc, $24, $1c, $01, $2b, $03, $1c, $1c, $3b, $27, $1c, $1f, $01, $d6, $0a, $2c
	db $3f, $6b, $5f, $3b, $3c, $01, $8c, $00, $0f, $fd, $01, $f0, $00, $3c, $fc, $fa
	db $fe, $fc, $4c, $84, $fc, $01, $9e, $00, $01, $60, $0a

;@ path: gfx/monsters/sprites
;@ Walking sprite of DrakSlime (species $00) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $D0 packed).
MonSprite_DrakSlime::
	db $00, $01, $09, $00, $00
	db $08, $08, $6c, $6c, $9a, $fe, $8a, $fe, $ab, $ff, $da, $df, $92, $9d, $27, $3a
	db $22, $3d, $24, $3f, $13, $1f, $0c, $0f, $03, $03, $01, $01, $00, $00, $e4, $5c
	db $44, $bc, $24, $fc, $c8, $f8, $30, $f0, $c0, $c0, $a0, $e0, $70, $70, $09, $00
	db $00, $0c, $0c, $0a, $0e, $3a, $3e, $4b, $7f, $9a, $ff, $f2, $fd, $09, $fe, $f0
	db $30, $30, $48, $78, $84, $fc, $83, $ff, $89, $ff, $bc, $ff, $00, $00, $80, $80
	db $09, $2a, $00, $a0, $e0, $98, $f8, $94, $fc, $06, $fa, $ca, $cf, $98, $9f, $28
	db $3f, $4c, $7f, $53, $73, $60, $60, $40, $40, $00, $00, $0f, $f5, $05, $fb, $23
	db $ff, $1e, $fe, $0c, $fc, $f0, $f0, $09, $f6, $f8, $1c, $1c, $23, $3f, $41, $7f
	db $80, $ff, $8e, $ff, $b8, $ff, $c8, $cf, $8c, $8f, $13, $1f, $14, $1c, $14, $1c
	db $0e, $0e, $09, $00, $04, $86, $fe, $87, $ff, $a2, $ff, $d2, $df, $a0, $bf, $20
	db $3f, $22, $3f, $12, $1f, $0e, $0f, $02, $03, $05, $07, $0e, $0e, $05, $fd, $04
	db $fc, $44, $fc, $48, $f8, $70, $f0, $c0, $c0, $80, $80, $09, $fe, $f2, $09, $34
	db $02, $47, $7f, $82, $ff, $f2, $ff, $09, $a0, $ff, $0d

;@ path: gfx/monsters/sprites
;@ Walking sprite of SpotSlime (species $01) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $E9 packed).
MonSprite_SpotSlime::
	db $00, $01, $05, $05, $ff
	db $f4, $01, $01, $02, $03, $02, $03, $04, $07, $1c, $1f, $22, $3d, $77, $7a, $72
	db $7d, $2c, $3f, $17, $1f, $0c, $0f, $03, $03, $78, $f8, $74, $bc, $ee, $5e, $4e
	db $be, $34, $fc, $e8, $f8, $30, $f0, $c0, $c0, $05, $fe, $f8, $03, $03, $06, $07
	db $05, $ff, $f0, $60, $60, $90, $f0, $90, $f0, $88, $f8, $1c, $fc, $0e, $fe, $12
	db $1d, $27, $3a, $3a, $3d, $3c, $3f, $3f, $3f, $18, $1f, $08, $0f, $07, $07, $48
	db $b8, $fc, $5c, $5c, $bc, $34, $fc, $e4, $fc, $38, $f8, $70, $f0, $e0, $e0, $1e
	db $1f, $26, $3f, $70, $7f, $71, $7f, $21, $3f, $1c, $1f, $1e, $1f, $0f, $0f, $10
	db $f0, $10, $f0, $48, $b8, $e8, $58, $c8, $b8, $f8, $f8, $30, $f0, $e0, $e0, $05
	db $ff, $f0, $06, $06, $09, $0f, $09, $0f, $11, $1f, $38, $3f, $78, $7f, $10, $1f
	db $30, $3f, $3a, $3f, $39, $3f, $10, $1f, $17, $1f, $0f, $0f, $03, $03, $05, $84
	db $00, $48, $b8, $88, $f8, $05, $8a, $00, $20, $e0, $c0, $c0, $1c, $1f, $20, $3f
	db $73, $7f, $77, $7f, $23, $3f, $14, $05, $1b, $03, $34, $fc, $0e, $fe, $8e, $fe
	db $34, $fc, $78, $f8, $70, $f0, $c0, $c0, $13, $1f, $33, $3f, $23, $3f, $38, $3f
	db $3c, $3f, $1c, $05, $5b, $01, $38, $f8, $8c, $fc, $0c, $fc, $04, $fc, $64, $05
	db $d9, $01, $e0, $e0

;@ path: gfx/monsters/sprites
;@ Walking sprite of WingSlime (species $02) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $BA packed).
MonSprite_WingSlime::
	db $00, $01, $01, $70, $70, $88, $f8, $87, $ff, $86, $fd, $8f
	db $fa, $52, $7d, $54, $7f, $2b, $3f, $18, $18, $24, $3c, $47, $7f, $46, $7d, $4f
	db $7a, $01, $0a, $02, $1f, $1f, $0f, $0a, $1f, $16, $3f, $2a, $3f, $3a, $07, $05
	db $02, $02, $00, $00, $f0, $f0, $f8, $a8, $fe, $ae, $fe, $b2, $ec, $ec, $c0, $40
	db $c0, $c0, $00, $00, $0f, $0f, $1f, $15, $7f, $75, $7f, $4d, $37, $37, $03, $02
	db $03, $03, $01, $2e, $00, $f0, $50, $f8, $68, $fc, $54, $fc, $5c, $e0, $a0, $40
	db $40, $00, $00, $30, $30, $4c, $7c, $47, $7f, $42, $7f, $24, $3f, $28, $3f, $18
	db $1f, $0c, $0f, $01, $fc, $f0, $c0, $c0, $60, $a0, $f0, $50, $48, $b8, $88, $f8
	db $78, $f8, $1c, $1c, $24, $3c, $27, $3f, $22, $3f, $01, $68, $0f, $05, $0f, $0f
	db $01, $22, $0a, $e6, $e6, $fe, $ba, $fe, $a2, $fc, $dc, $b8, $b8, $01, $3a, $0f
	db $07, $fc, $6c, $01, $56, $06, $01, $10, $02, $44, $7f, $40, $7f, $50, $7f, $30
	db $3f, $18, $1f, $60, $60, $90, $f0, $8b, $fb, $84, $ff, $01, $e8, $04

;@ path: gfx/monsters/sprites
;@ Walking sprite of TreeSlime (species $03) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $AF packed).
MonSprite_TreeSlime::
	db $00, $01
	db $04, $1e, $1e, $1d, $13, $0f, $09, $06, $07, $05, $07, $05, $07, $0a, $0e, $0a
	db $0e, $3e, $3e, $5c, $64, $f8, $88, $f0, $f0, $80, $80, $04, $fa, $f2, $12, $1e
	db $21, $3f, $54, $6b, $7e, $55, $94, $eb, $a2, $ff, $5c, $7f, $3f, $3f, $04, $fc
	db $f0, $80, $80, $40, $c0, $04, $36, $00, $04, $18, $04, $07, $07, $03, $02, $01
	db $01, $01, $01, $06, $07, $09, $0f, $04, $fc, $f0, $8e, $8e, $57, $d9, $ee, $f6
	db $38, $f8, $c0, $c0, $04, $fc, $f2, $0d, $0b, $06, $05, $03, $03, $04, $fa, $f2
	db $7c, $7c, $b8, $c8, $f0, $90, $e0, $e0, $a0, $e0, $a0, $e0, $50, $70, $50, $70
	db $48, $78, $84, $fc, $0a, $f6, $1e, $ea, $0a, $f6, $22, $fe, $1c, $fc, $f8, $f8
	db $04, $fa, $f2, $0d, $0d, $3b, $37, $0f, $09, $07, $07, $04, $fa, $f2, $f0, $f0
	db $60, $a0, $c0, $40, $c0, $c0, $20, $e0, $90, $f0, $04, $80, $00, $02, $fe, $02
	db $fe, $01, $ff, $01, $ff, $02, $fe, $fc, $fc, $04, $a0, $ff, $2d

;@ path: gfx/monsters/sprites
;@ Walking sprite of Snaily (species $04) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $E5 packed).
MonSprite_Snaily::
	db $00, $01, $02
	db $00, $00, $01, $01, $0a, $0b, $0c, $0f, $2b, $2f, $33, $3f, $ea, $ff, $a0, $ff
	db $0f, $0f, $31, $3f, $f9, $ff, $87, $ff, $5a, $fe, $2a, $fe, $4f, $ff, $09, $ff
	db $4f, $7f, $5f, $7f, $35, $3a, $1f, $15, $25, $3a, $28, $3f, $1f, $1f, $00, $00
	db $e2, $fe, $f4, $fc, $38, $f8, $98, $78, $10, $f0, $a0, $e0, $c0, $c0, $00, $00
	db $02, $20, $00, $30, $3f, $10, $1f, $6a, $75, $9f, $ea, $aa, $f5, $7f, $7f, $02
	db $30, $00, $78, $f8, $18, $f8, $08, $f8, $02, $38, $04, $00, $00, $40, $40, $c0
	db $c0, $d0, $d0, $70, $f0, $48, $f8, $04, $fc, $46, $7f, $25, $3f, $14, $1f, $09
	db $0f, $07, $07, $03, $03, $01, $01, $00, $00, $3a, $fe, $7e, $fe, $e6, $fa, $8f
	db $f5, $05, $fb, $89, $ff, $fe, $fe, $02, $7e, $02, $e2, $fe, $82, $fe, $05, $fb
	db $0f, $f5, $85, $fb, $7e, $7e, $02, $fe, $f0, $f0, $f0, $8c, $fc, $9f, $ff, $e1
	db $ff, $5a, $7f, $54, $7f, $02, $fc, $f2, $80, $80, $50, $d0, $30, $f0, $d4, $f4
	db $cc, $fc, $f2, $ff, $90, $ff, $43, $7f, $22, $3f, $18, $1f, $1f, $1f, $04, $07
	db $03, $03, $57, $ff, $05, $ff, $2a, $fe, $a2, $fe, $1c, $fc, $e8, $f8, $04, $fc
	db $f8, $f8, $02, $c0, $08, $03, $03, $00, $00, $02, $d0, $06, $e2, $fe, $fc, $fc
	db $00, $00

;@ path: gfx/monsters/sprites
;@ Walking sprite of SlimeNite (species $05) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $DE packed).
MonSprite_SlimeNite::
	db $00, $01, $02, $00, $00, $21, $21, $77, $56, $79, $5e, $7f, $57, $7f
	db $50, $8f, $fb, $7f, $58, $00, $00, $f0, $f0, $c8, $f8, $26, $fe, $fc, $dc, $fe
	db $1e, $ff, $a1, $b3, $6d, $2f, $2f, $06, $07, $08, $0f, $10, $1f, $24, $3b, $2e
	db $35, $14, $1b, $0f, $0f, $f3, $ed, $73, $ed, $fe, $f2, $1e, $fe, $24, $dc, $74
	db $ac, $28, $d8, $f0, $f0, $e6, $e6, $1a, $fe, $c4, $fc, $28, $f8, $f0, $d0, $02
	db $1a, $04, $0e, $0f, $30, $3f, $40, $7f, $84, $fb, $6e, $75, $1f, $1f, $00, $00
	db $02, $30, $04, $21, $df, $76, $ae, $f8, $f8, $02, $fe, $f0, $84, $84, $ee, $6a
	db $3e, $fa, $fc, $d4, $fc, $14, $f8, $f8, $fc, $3c, $cf, $b7, $ce, $b7, $7f, $4f
	db $78, $7f, $20, $3f, $20, $3f, $10, $1f, $0f, $0f, $02, $70, $0f, $05, $80, $ff
	db $60, $7f, $02, $5c, $00, $00, $00, $07, $07, $19, $1f, $60, $7f, $33, $3f, $7c
	db $7f, $ff, $84, $cd, $b6, $02, $70, $02, $9e, $fa, $1e, $ea, $1e, $ea, $f1, $1f
	db $fe, $3a, $d4, $f4, $18, $f8, $c8, $f8, $38, $f8, $08, $f8, $08, $f8, $10, $f0
	db $e0, $e0, $67, $67, $58, $7f, $21, $3f, $12, $1f, $0c, $0f, $7c, $7b, $02, $bc
	db $00, $d4, $f4, $10, $f0, $c8, $f8, $3e, $fe, $01, $ff, $06, $fe, $02, $6c, $00
;@ path: gfx/monsters/sprites
;@ Walking sprite of Babble (species $06) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $BC packed).
MonSprite_Babble::
	db $00, $01, $01, $04, $07, $0a, $0d, $17, $1a, $62, $7d, $84, $ff, $83, $ff, $70
	db $7f, $0f, $0f, $01, $02, $00, $12, $1d, $24, $3f, $43, $7f, $40, $7f, $30, $3f
	db $0f, $0f, $01, $fc, $f0, $41, $41, $e3, $a2, $41, $41, $08, $08, $1c, $14, $0b
	db $0b, $04, $04, $0e, $0a, $04, $04, $80, $80, $00, $00, $01, $30, $00, $c4, $c4
	db $20, $20, $70, $50, $21, $21, $03, $02, $41, $41, $e3, $a3, $44, $47, $08, $0f
	db $10, $10, $38, $28, $10, $10, $80, $80, $02, $02, $c7, $c5, $22, $e2, $10, $f0
	db $01, $20, $0f, $2d, $04, $07, $08, $0f, $08, $0f, $30, $3f, $40, $7f, $40, $7f
	db $38, $3f, $07, $07, $20, $e0, $50, $b0, $e8, $58, $44, $bc, $84, $fc, $7c, $fc
	db $0c, $fc, $f0, $f0, $01, $a2, $00, $08, $0f, $11, $1f, $20, $3f, $20, $3f, $18
	db $1f, $07, $07, $50, $b0, $f0, $50, $50, $b0, $08, $f8, $fc, $fc, $04, $fc, $18
	db $f8, $e0, $e0, $01, $a0, $00, $10, $1f, $60, $7f, $80, $ff, $80, $01, $0b, $01
	db $01, $e2, $00, $10, $1f, $20, $01, $a7, $01, $01, $1c, $00

;@ path: gfx/monsters/sprites
;@ Walking sprite of BoxSlime (species $07) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $82 packed).
MonSprite_BoxSlime::
	db $00, $01, $01, $01
	db $ff, $f4, $0f, $0f, $10, $1f, $12, $1d, $17, $1a, $12, $1d, $14, $1f, $13, $1f
	db $10, $1f, $0f, $0f, $01, $f8, $fc, $07, $07, $18, $1f, $22, $3d, $47, $7a, $4a
	db $7d, $27, $3f, $01, $16, $0e, $01, $08, $00, $01, $4a, $00, $01, $ff, $f4, $f0
	db $f0, $08, $f8, $28, $d8, $78, $a8, $01, $4a, $02, $01, $16, $06, $28, $d8, $48
	db $f8, $38, $f8, $08, $f8, $f0, $f0, $01, $f8, $fc, $03, $03, $0c, $0f, $30, $3f
	db $01, $fe, $f6, $e0, $e0, $18, $f8, $14, $ec, $40, $7f, $01, $a0, $00, $30, $3f
	db $01, $18, $04, $3a, $d6, $52, $ee, $3c, $fc, $01, $76, $0e, $01, $48, $04, $01
	db $60, $0c, $01, $20, $0a, $20, $3f, $01, $a0, $00, $20, $01, $35, $07

;@ path: gfx/monsters/sprites
;@ Walking sprite of Slime (species $08) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Also people graphics $3A in ActorGfx. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $66 packed).
MonSprite_Slime::
	db $00, $01
	db $01, $01, $ff, $f6, $20, $20, $20, $20, $50, $70, $04, $07, $0a, $0d, $17, $1a
	db $22, $3d, $24, $3f, $13, $1f, $0f, $0f, $00, $00, $01, $10, $02, $17, $1a, $12
	db $1d, $14, $1f, $0b, $0f, $07, $07, $04, $07, $08, $0f, $10, $1f, $20, $3f, $20
	db $3f, $10, $01, $1b, $03, $01, $32, $00, $01, $44, $02, $08, $0f, $07, $07, $40
	db $c0, $60, $a0, $f0, $50, $48, $b8, $88, $f8, $70, $f0, $e0, $e0, $00, $00, $01
	db $50, $02, $f0, $50, $50, $b0, $90, $f0, $60, $e0, $c0, $c0, $01, $a0, $ff, $4d
	db $01, $cf, $0f, $1d

;@ path: gfx/monsters/sprites
;@ Walking sprite of Healer (species $09) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $AE packed).
MonSprite_Healer::
	db $00, $01, $02, $07, $07, $08, $0f, $10, $1f, $10, $1f, $22
	db $3d, $47, $7a, $42, $7d, $44, $7f, $23, $3f, $1c, $1f, $1b, $17, $3f, $2a, $3f
	db $2a, $3f, $2d, $17, $15, $03, $03, $88, $f8, $70, $f0, $b0, $d0, $f8, $a8, $f8
	db $a8, $70, $50, $70, $50, $20, $20, $02, $10, $00, $0f, $0b, $1f, $15, $3f, $2d
	db $3f, $3a, $07, $06, $01, $01, $02, $20, $00, $e0, $a0, $f0, $50, $f0, $50, $f8
	db $a8, $d8, $d8, $02, $fe, $f6, $20, $3f, $40, $7f, $02, $5a, $00, $c0, $c0, $20
	db $e0, $10, $f0, $10, $f0, $28, $d8, $74, $ac, $24, $dc, $44, $fc, $1c, $fc, $38
	db $f8, $d8, $e8, $fc, $54, $fc, $54, $fc, $b4, $e8, $a8, $c0, $c0, $02, $70, $00
	db $f0, $d0, $f8, $a8, $fc, $b4, $fc, $5c, $e0, $60, $80, $80, $20, $3f, $18, $1f
	db $1f, $02, $15, $07, $08, $f8, $30, $f0, $02, $84, $00, $02, $28, $04, $02, $90
	db $00, $0f, $0f, $02, $36, $06, $02, $a0, $00, $e0, $e0, $02, $46, $06, $02, $cf
	db $0f, $1d

;@ path: gfx/monsters/sprites
;@ Walking sprite of FangSlime (species $0A) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $E1 packed).
MonSprite_FangSlime::
	db $00, $01, $04, $01, $01, $03, $02, $05, $06, $75, $76, $3c, $2f, $1e
	db $17, $09, $0f, $d2, $dd, $00, $00, $e0, $e0, $e0, $a0, $70, $b0, $b8, $48, $f0
	db $d0, $20, $e0, $96, $76, $e7, $ba, $42, $7d, $d7, $ff, $fe, $ab, $6f, $53, $3f
	db $23, $1c, $1c, $00, $00, $04, $20, $00, $c7, $ff, $e2, $bf, $71, $7f, $2f, $3f
	db $7e, $56, $28, $28, $02, $02, $07, $05, $0b, $0d, $ea, $ed, $79, $5e, $39, $2f
	db $ce, $f7, $ac, $df, $00, $00, $c0, $c0, $c0, $40, $e0, $60, $70, $90, $e0, $a0
	db $c0, $c0, $60, $a0, $70, $7f, $f8, $8f, $70, $5f, $d0, $bf, $a8, $ff, $58, $7f
	db $27, $27, $00, $00, $f0, $50, $4e, $be, $7f, $f9, $5b, $f7, $24, $fc, $48, $f8
	db $b0, $b0, $04, $fc, $f0, $04, $52, $08, $40, $c0, $37, $3f, $3e, $29, $2b, $37
	db $3e, $3b, $74, $5f, $5b, $67, $2e, $31, $1f, $1f, $0a, $f6, $9d, $eb, $09, $f7
	db $0f, $ff, $05, $ff, $05, $ff, $fa, $fa, $04, $fe, $f2, $03, $02, $75, $76, $3d
	db $2e, $1d, $16, $0d, $0a, $d5, $de, $04, $10, $04, $78, $88, $b0, $50, $e0, $60
	db $56, $f6, $f4, $bf, $7a, $4f, $e9, $9f, $f6, $cf, $6d, $53, $6a, $75, $19, $1f
	db $06, $06, $fe, $ab, $77, $49, $d6, $fd, $ff, $aa, $be, $eb, $43, $7f, $3c, $3c
	db $04, $a0, $fe

;@ path: gfx/monsters/sprites
;@ Walking sprite of RockSlime (species $0B) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $E2 packed).
MonSprite_RockSlime::
	db $00, $01, $02, $02, $ff, $f4, $0c, $0c, $1a, $16, $16, $1a, $2f
	db $31, $1f, $19, $27, $3a, $7b, $45, $7d, $4a, $4f, $7f, $2f, $33, $1d, $1e, $03
	db $03, $d8, $b8, $f4, $4c, $ae, $d2, $d2, $3e, $fe, $f2, $d4, $ec, $b8, $78, $c0
	db $c0, $02, $fc, $f8, $3c, $3c, $e7, $db, $17, $19, $37, $2e, $5d, $62, $67, $59
	db $7b, $46, $2d, $3b, $1b, $14, $0f, $0f, $e8, $98, $f4, $6c, $9e, $62, $f2, $8e
	db $c6, $7a, $8c, $f4, $68, $98, $f0, $f0, $1e, $19, $3a, $25, $6d, $52, $72, $4f
	db $75, $4b, $2d, $32, $1e, $19, $07, $07, $f0, $30, $b8, $68, $7c, $9c, $9c, $64
	db $5c, $fc, $f8, $f8, $f0, $30, $02, $2e, $06, $0e, $0e, $1b, $15, $33, $2c, $76
	db $49, $02, $fe, $f6, $b8, $b8, $78, $c8, $f0, $10, $55, $6a, $27, $3a, $33, $2e
	db $1f, $13, $1f, $1b, $0f, $0d, $07, $06, $01, $01, $70, $90, $90, $70, $b8, $48
	db $78, $98, $f8, $28, $d8, $b8, $f0, $d0, $e0, $e0, $1f, $18, $23, $3c, $78, $47
	db $7d, $42, $5b, $64, $26, $39, $02, $1c, $00, $18, $f8, $74, $8c, $6e, $92, $92
	db $6e, $be, $42, $54, $ac, $02, $2c, $00, $15, $1a, $36, $29, $5f, $60, $64, $5b
	db $7b, $44, $2d, $32, $02, $4c, $00, $c8, $38, $b4, $4c, $02, $d4, $00, $d6, $2a
	db $8c, $74, $02, $5c, $00

;@ path: gfx/monsters/sprites
;@ Walking sprite of SlimeBorg (species $0C) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $C3 packed).
MonSprite_SlimeBorg::
	db $00, $01, $05, $05, $ff, $f4, $01, $01, $02, $03, $02
	db $03, $04, $07, $05, $ff, $f4, $80, $80, $4e, $ce, $51, $df, $65, $ff, $18, $1f
	db $24, $3b, $4e, $75, $44, $7b, $44, $7f, $23, $3f, $18, $1f, $07, $07, $fd, $ff
	db $fd, $ff, $fe, $de, $7e, $fe, $3e, $fe, $c4, $fc, $18, $f8, $e0, $e0, $05, $02
	db $0a, $08, $0f, $05, $12, $0a, $cd, $ff, $14, $1b, $1e, $15, $24, $3b, $20, $3f
	db $22, $3f, $11, $1f, $0c, $0f, $03, $03, $05, $32, $04, $44, $fc, $88, $f8, $30
	db $f0, $c0, $c0, $93, $ff, $df, $ff, $7f, $7f, $5f, $7f, $4f, $7f, $20, $05, $2b
	db $01, $f8, $f8, $fc, $fc, $fe, $ee, $fa, $fe, $e2, $fe, $04, $05, $3b, $01, $9f
	db $ff, $5f, $7f, $7f, $7f, $2f, $3f, $23, $3f, $10, $05, $6b, $01, $f8, $f8, $f8
	db $d8, $fc, $fc, $f4, $fc, $c4, $fc, $08, $05, $7b, $01, $bf, $ff, $bf, $ff, $7f
	db $7f, $7e, $7f, $7c, $05, $89, $03, $18, $f8, $04, $fc, $02, $fe, $05, $d4, $00
	db $05, $9a, $02, $05, $a2, $00, $05, $c6, $02, $05, $aa, $02, $08, $f8, $08, $f8
	db $04, $fc, $05, $f4, $00, $05, $ba, $02

;@ path: gfx/monsters/sprites
;@ Walking sprite of Slabbit (species $0D) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $AD packed).
MonSprite_Slabbit::
	db $00, $01, $05, $05, $ff, $f0, $01, $01
	db $02, $03, $02, $03, $04, $07, $08, $0f, $12, $1d, $27, $3a, $22, $3d, $34, $3f
	db $4b, $7f, $44, $7f, $47, $7f, $54, $7c, $38, $38, $05, $04, $0c, $24, $3f, $53
	db $7f, $4c, $7f, $8b, $fb, $88, $f8, $a8, $f8, $a8, $f8, $70, $70, $05, $04, $06
	db $10, $1f, $20, $3f, $2c, $3f, $80, $80, $40, $c0, $40, $c0, $20, $e0, $10, $f0
	db $28, $d8, $74, $ac, $24, $dc, $22, $3f, $11, $1f, $09, $0f, $19, $1f, $21, $3f
	db $2b, $3f, $36, $3e, $1c, $1c, $8c, $fc, $78, $f8, $30, $f0, $e0, $e0, $05, $f8
	db $ff, $03, $10, $1f, $05, $ff, $f0, $05, $50, $08, $20, $3f, $27, $3f, $21, $3f
	db $10, $1f, $0c, $0f, $08, $0f, $09, $0f, $07, $07, $05, $5c, $00, $8c, $fc, $f8
	db $f8, $b0, $f0, $05, $52, $00, $80, $80, $05, $40, $0a, $05, $cc, $00, $30, $3f
	db $4c, $7f, $47, $7f, $38, $38, $05, $fe, $f2, $20, $3f, $50, $05, $33, $01, $05
	db $3a, $02, $05, $a0, $fe

;@ path: gfx/monsters/sprites
;@ Walking sprite of SpotKing (species $0E) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $E2 packed).
MonSprite_SpotKing::
	db $00, $01, $04, $00, $00, $01, $01, $07, $06, $1a, $1d
	db $1e, $15, $17, $1a, $77, $7f, $fc, $ff, $fa, $fd, $ef, $fa, $4e, $7d, $5f, $7b
	db $47, $7c, $3b, $3f, $1c, $1f, $07, $07, $4f, $bf, $f7, $5f, $76, $be, $fe, $de
	db $e2, $3e, $f4, $fc, $38, $f8, $e0, $e0, $04, $fe, $ff, $01, $5f, $7a, $8e, $fd
	db $9f, $fb, $7f, $7c, $3b, $3f, $0f, $0f, $3f, $ff, $47, $bf, $f2, $5e, $77, $bf
	db $ff, $df, $fa, $3e, $cc, $fc, $f0, $f0, $00, $00, $03, $03, $0d, $0e, $0f, $0a
	db $1f, $1f, $3f, $04, $6a, $01, $80, $80, $e0, $60, $58, $b8, $78, $a8, $e8, $58
	db $f8, $f8, $94, $ec, $3c, $d4, $2e, $3f, $20, $3f, $38, $3f, $3c, $3f, $1e, $1f
	db $1e, $1f, $0e, $0f, $03, $03, $52, $ee, $62, $fe, $7e, $de, $fe, $e2, $1e, $fe
	db $64, $fc, $78, $f8, $e0, $e0, $5e, $7f, $40, $7f, $78, $7f, $3c, $3f, $3e, $3f
	db $1e, $1f, $07, $07, $00, $00, $04, $90, $06, $6c, $04, $5d, $01, $f9, $ff, $e3
	db $ff, $43, $7f, $41, $7f, $58, $7f, $3c, $04, $1b, $01, $8f, $ff, $cf, $ff, $c6
	db $fe, $8e, $fe, $02, $fe, $3c, $04, $9b, $01, $fc, $ff, $f9, $ff, $63, $7f, $83
	db $ff, $b1, $ff, $78, $7f, $38, $04, $4d, $01, $87, $ff, $c2, $fe, $c7, $ff, $87
	db $ff, $7a, $fe, $fc, $fc, $f0, $f0

;@ path: gfx/monsters/sprites
;@ Walking sprite of KingSlime (species $0F) on the field: 16 tiles (four 16 x 16 frames). Found through
;@ MonsterGfxRefs (index species + $10) and its copies ActorGfxIds, ActorGfxRefs, MonsterSpriteGfx,
;@ MonsterSpriteGfx_18, NamePictures and BreedIconGfx. Compressed in the DecompressCore format ($100 bytes
;@ unpacked, $B8 packed).
MonSprite_KingSlime::
	db $00, $01, $02, $01, $01, $17, $17, $1d, $1f
	db $1b, $16, $1e, $11, $1f, $17, $1a, $1d, $27, $3a, $02, $fe, $fa, $3a, $3d, $2a
	db $3d, $4c, $7f, $5f, $7b, $47, $7c, $43, $7f, $20, $3f, $18, $1f, $07, $07, $47
	db $7a, $8a, $fd, $8c, $ff, $9f, $fb, $87, $fc, $43, $7f, $30, $3f, $0f, $0f, $00
	db $00, $0b, $0b, $0e, $0f, $0d, $0b, $0f, $08, $0f, $0f, $10, $1f, $10, $1f, $80
	db $80, $e8, $e8, $b8, $f8, $d8, $68, $38, $c8, $f8, $f8, $14, $ec, $3c, $d4, $20
	db $3f, $02, $60, $02, $02, $4c, $00, $0c, $0f, $03, $03, $52, $ee, $62, $fe, $7e
	db $de, $fe, $e2, $1e, $fe, $04, $fc, $18, $f8, $e0, $e0, $02, $fc, $f0, $02, $42
	db $04, $1f, $1f, $20, $3f, $00, $00, $02, $50, $0a, $40, $7f, $02, $a0, $02, $02
	db $60, $00, $02, $2c, $00, $3c, $d4, $02, $70, $06, $0c, $fc, $f0, $f0, $02, $00
	db $06, $1e, $1d, $13, $02, $8d, $01, $02, $c0, $08, $33, $3f, $20, $3f, $02, $a0
	db $06, $02, $2c, $00, $40, $7f, $80, $ff, $02, $f2, $02, $40, $02, $3b, $01

;@ path: gfx/monsters/pictures
;@ Picture of DrakSlime (species $00): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $F0 packed).
MonPic_DrakSlime::
	db $40
	db $02, $08, $ff, $08, $ff, $ff, $4d, $08, $0f, $0a, $01, $08, $6a, $03, $01, $df
	db $1d, $c7, $5d, $af, $d9, $4f, $b9, $ff, $00, $ff, $80, $7f, $c0, $7f, $c0, $5f
	db $e0, $1f, $80, $3f, $a0, $bf, $67, $ff, $00, $ff, $02, $fd, $07, $fd, $07, $f5
	db $0f, $f1, $03, $f9, $0f, $fd, $cb, $08, $0e, $04, $f7, $70, $c7, $74, $eb, $36
	db $e5, $3b, $08, $0e, $0c, $fc, $00, $fe, $03, $08, $c2, $01, $02, $08, $6e, $02
	db $0f, $f9, $87, $4f, $39, $bf, $7e, $46, $fe, $83, $fe, $03, $f8, $01, $fd, $06
	db $98, $5f, $90, $5f, $88, $6f, $c4, $27, $c0, $37, $80, $7f, $00, $ff, $04, $fb
	db $35, $fb, $15, $fb, $29, $f5, $51, $ed, $00, $f8, $08, $bf, $00, $40, $be, $e0
	db $3e, $c2, $e4, $38, $fa, $fc, $c4, $fe, $82, $ff, $81, $bf, $80, $7f, $40, $7f
	db $00, $ff, $80, $08, $12, $13, $08, $0f, $0f, $02, $fd, $06, $fc, $07, $f8, $01
	db $08, $c8, $04, $ff, $00, $0e, $f5, $04, $fb, $18, $ff, $10, $f0, $00, $78, $c0
	db $df, $f0, $30, $ff, $0f, $e0, $5e, $40, $be, $30, $fc, $10, $1c, $01, $39, $07
	db $e6, $1f, $18, $ff, $e0, $7f, $40, $7f, $40, $bf, $08, $17, $1f, $06, $08, $0e
	db $0f, $0f, $fc, $04, $fc, $05, $fe, $03, $08, $38, $14, $ff, $00, $3f, $20, $3f
	db $a0, $1f, $d0, $0f, $68, $7f, $70, $08, $0e, $0f, $4d, $08, $e0, $1f, $13

;@ path: gfx/monsters/pictures
;@ Picture of SpotSlime (species $01): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $91 packed).
MonPic_SpotSlime::
	db $40
	db $02, $05, $ff, $05, $ff, $ff, $4d, $05, $5f, $0f, $4d, $05, $bf, $0f, $4d, $05
	db $e3, $0f, $0f, $01, $fe, $03, $ff, $02, $ff, $02, $f9, $00, $fc, $07, $fe, $0f
	db $05, $e2, $01, $80, $05, $54, $10, $3f, $00, $ff, $40, $3f, $e0, $05, $0c, $1f
	db $27, $fe, $06, $ff, $07, $ff, $07, $de, $1f, $fc, $7f, $80, $cf, $64, $fb, $6e
	db $75, $04, $7b, $b0, $ff, $f8, $ff, $17, $f0, $37, $c4, $7f, $f2, $ff, $b9, $fa
	db $5d, $71, $bf, $19, $ff, $38, $ff, $05, $e2, $05, $80, $ff, $c0, $ff, $c0, $7f
	db $c0, $05, $e2, $0f, $0e, $07, $ff, $03, $ff, $01, $05, $e2, $06, $df, $ff, $c7
	db $df, $80, $87, $c0, $c0, $f0, $30, $ff, $05, $4f, $11, $f0, $ff, $ce, $ff, $1f
	db $ff, $1f, $1e, $1f, $18, $ff, $05, $5f, $12, $c0, $ff, $80, $05, $e2, $0f, $09
;@ path: gfx/monsters/pictures
;@ Picture of WingSlime (species $02): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $120 packed).
MonPic_WingSlime::
	db $40, $02, $02, $ff, $02, $ff, $ff, $4d, $00, $fb, $03, $e8, $0b, $e0, $2f, $c4
	db $7b, $d8, $67, $d8, $67, $ec, $33, $ff, $00, $f7, $f0, $05, $f4, $11, $ed, $06
	db $f9, $03, $fc, $00, $fe, $00, $ff, $02, $02, $02, $7f, $00, $7f, $40, $3f, $e0
	db $1f, $70, $0f, $38, $02, $02, $02, $fd, $01, $fc, $05, $f8, $0f, $f0, $1c, $e0
	db $39, $ff, $00, $df, $1f, $40, $5f, $1f, $60, $60, $9f, $02, $01, $02, $ff, $00
	db $bf, $80, $2f, $a0, $0f, $e8, $67, $9c, $27, $dc, $07, $fc, $0f, $f8, $f2, $1d
	db $f9, $0e, $fc, $05, $fd, $01, $02, $02, $04, $00, $ff, $80, $7f, $00, $ff, $20
	db $df, $80, $ff, $c0, $7f, $f1, $3f, $f9, $09, $27, $bc, $13, $9f, $10, $9f, $28
	db $b7, $70, $4f, $e4, $9b, $4e, $b5, $04, $fb, $c8, $7b, $90, $f3, $10, $f3, $08
	db $fb, $04, $fd, $42, $bf, $e1, $5f, $41, $bf, $01, $fe, $03, $fc, $00, $ff, $09
	db $f7, $f3, $0e, $67, $9c, $1f, $f8, $3f, $20, $1f, $f0, $3f, $e0, $7f, $40, $7f
	db $02, $01, $0f, $07, $07, $fb, $0f, $ff, $0c, $ff, $1b, $ff, $16, $ff, $16, $fb
	db $0e, $f9, $09, $0c, $ff, $08, $f8, $80, $f8, $c0, $7f, $b0, $ff, $bf, $ef, $bf
	db $ab, $ff, $6a, $61, $ff, $21, $3f, $03, $3e, $07, $fd, $1f, $fd, $fb, $ee, $fb
	db $5a, $ff, $ad, $ff, $c0, $bf, $e0, $ff, $60, $ff, $b0, $7f, $d0, $ff, $d0, $bf
	db $e0, $3f, $20, $02, $02, $0f, $0e, $07, $02, $02, $0b, $6d, $ff, $ad, $ff, $16
	db $ff, $15, $ff, $08, $02, $02, $03, $6b, $ff, $6a, $ff, $d4, $ff, $50, $ff, $a0
	db $ff, $a0, $ff, $40, $ff, $00, $ff, $c0, $02, $02, $0f, $4d, $02, $e0, $1f, $0b
;@ path: gfx/monsters/pictures
;@ Picture of TreeSlime (species $03): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $A4 packed).
MonPic_TreeSlime::
	db $40, $02, $08, $ff, $08, $ff, $ff, $4d, $08, $2f, $0f, $1b, $01, $08, $2e, $09
	db $ff, $fb, $06, $08, $54, $0f, $2a, $08, $db, $00, $02, $ff, $04, $ff, $05, $fe
	db $77, $fe, $9f, $f7, $2f, $ee, $5b, $3f, $f1, $f7, $6c, $e3, $90, $cf, $38, $1f
	db $f0, $ff, $e0, $ff, $00, $ff, $80, $7f, $c0, $08, $aa, $0f, $24, $08, $2f, $05
	db $7f, $c1, $ff, $80, $08, $2e, $08, $7f, $c0, $bf, $e0, $08, $52, $10, $df, $70
	db $08, $58, $12, $08, $4c, $0f, $31, $fe, $07, $fa, $1d, $ec, $33, $d8, $67, $91
	db $ee, $81, $fe, $9f, $f0, $0f, $f8, $0f, $f8, $07, $fc, $03, $fe, $cd, $33, $dc
	db $aa, $dc, $ab, $08, $44, $19, $00, $08, $42, $1a, $08, $2e, $0f, $11, $80, $ff
	db $80, $fc, $c0, $7c, $e0, $3f, $f8, $1f, $ff, $07, $08, $2e, $00, $88, $77, $06
	db $ff, $02, $03, $01, $07, $07, $fe, $ff, $f8, $08, $2e, $01, $80, $08, $20, $21
	db $08, $2f, $0f, $06

;@ path: gfx/monsters/pictures
;@ Picture of Snaily (species $04): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $B7 packed).
MonPic_Snaily::
	db $40, $02, $08, $ff, $08, $ff, $ff, $4d, $08, $5f, $0f, $4d
	db $08, $bf, $0f, $4d, $08, $dd, $0f, $09, $06, $ff, $05, $08, $dc, $03, $02, $ff
	db $05, $ff, $05, $fb, $1c, $e4, $3c, $08, $dc, $01, $17, $fb, $2c, $f8, $69, $a5
	db $dd, $e3, $7e, $14, $f7, $ff, $00, $ff, $60, $ff, $90, $9f, $f0, $5f, $d0, $5f
	db $d0, $bf, $e0, $bf, $a0, $08, $dc, $0f, $0e, $02, $fe, $03, $ff, $01, $fe, $03
	db $fc, $06, $fc, $04, $fd, $05, $fd, $05, $fe, $ba, $cd, $7b, $18, $e7, $01, $0f
	db $70, $71, $fc, $fc, $83, $83, $48, $b0, $3e, $2b, $ea, $de, $d2, $b6, $11, $f3
	db $29, $e9, $04, $4c, $02, $06, $c7, $c7, $bf, $a0, $7f, $c0, $7f, $40, $3f, $60
	db $7f, $40, $ff, $80, $ff, $80, $08, $dc, $0f, $0f, $fe, $02, $fc, $07, $f8, $0f
	db $f8, $0b, $fc, $04, $ff, $03, $08, $dc, $00, $fc, $48, $48, $b6, $88, $fe, $70
	db $fc, $00, $00, $ff, $ff, $08, $dc, $00, $20, $23, $17, $17, $0b, $6a, $0f, $6c
	db $1f, $10, $ff, $e0, $08, $dc, $01, $08, $cd, $1f, $0c

;@ path: gfx/monsters/pictures
;@ Picture of SlimeNite (species $05): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $FB packed).
MonPic_SlimeNite::
	db $40, $02, $05, $ff, $05
	db $ff, $ff, $4d, $05, $17, $0f, $03, $01, $ff, $02, $ff, $02, $fe, $03, $fe, $03
	db $05, $16, $05, $83, $fc, $44, $f8, $48, $fb, $4b, $05, $16, $05, $98, $7f, $4c
	db $37, $34, $87, $84, $05, $16, $0f, $1d, $05, $7c, $00, $05, $d0, $02, $ff, $01
	db $ff, $03, $fc, $07, $fc, $4c, $fb, $4b, $fd, $46, $fd, $46, $fb, $4f, $70, $d7
	db $f5, $fe, $d3, $3b, $4f, $48, $7f, $70, $ff, $c0, $ff, $a0, $7f, $90, $5f, $88
	db $df, $4f, $af, $88, $05, $16, $09, $80, $ff, $40, $05, $16, $0f, $0e, $03, $fe
	db $02, $ff, $01, $fe, $02, $05, $d8, $01, $00, $ff, $00, $f9, $fe, $0f, $af, $34
	db $b5, $7b, $5f, $7f, $c7, $fd, $87, $fe, $06, $fa, $0e, $f8, $30, $f4, $e1, $72
	db $e0, $d8, $b1, $14, $f8, $ec, $ef, $47, $4f, $2b, $3a, $ff, $40, $7f, $20, $05
	db $62, $10, $ff, $40, $7f, $c0, $ff, $80, $05, $4e, $0f, $18, $01, $05, $d0, $02
	db $f7, $1e, $eb, $7c, $85, $fc, $02, $fe, $d9, $27, $fc, $4b, $fc, $4b, $48, $b7
	db $f1, $f1, $c8, $78, $84, $fc, $83, $ff, $0d, $f3, $0c, $f3, $00, $ff, $04, $fb
	db $05, $0a, $11, $05, $c3, $10, $05, $c1, $16, $05, $b3, $0f, $0c, $05, $96, $10
	db $05, $16, $06, $80, $f9, $c0, $c1, $00, $83, $80, $ff, $e0, $7f, $ff, $1f, $05
	db $16, $00, $0c, $f2, $19, $e7, $63, $9e, $0f, $fc, $3f, $f0, $ff, $c0, $05, $16
	db $00, $7f, $05, $17, $0f, $0c

;@ path: gfx/monsters/pictures
;@ Picture of Babble (species $06): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $B7 packed).
MonPic_Babble::
	db $40, $02, $02, $ff, $02, $ff, $ff, $4d, $02, $5f
	db $0f, $4d, $02, $bf, $0f, $4d, $02, $d3, $0e, $07, $ff, $08, $fe, $09, $f8, $0f
	db $ff, $07, $ff, $00, $ff, $10, $ff, $00, $ff, $01, $ff, $82, $fe, $83, $ff, $81
	db $02, $3c, $11, $28, $ff, $00, $ff, $80, $ff, $40, $7f, $c0, $ff, $80, $ff, $0c
	db $ff, $12, $f3, $1e, $02, $d2, $0f, $1e, $28, $ff, $10, $ff, $01, $02, $d2, $03
	db $03, $fc, $0f, $ff, $10, $ff, $81, $ff, $46, $fe, $89, $f8, $17, $e2, $fd, $07
	db $fa, $32, $fd, $ff, $0c, $ff, $f0, $9f, $78, $07, $fc, $03, $fe, $41, $bf, $e0
	db $5f, $40, $bf, $ff, $00, $ff, $20, $ff, $50, $ff, $20, $02, $50, $10, $7f, $f0
	db $0f, $f8, $02, $d2, $0f, $0d, $f0, $1f, $fc, $0f, $fe, $03, $fc, $07, $ff, $03
	db $02, $d2, $02, $20, $e7, $00, $e0, $00, $f8, $02, $51, $10, $ff, $7f, $02, $d2
	db $00, $00, $cf, $00, $0f, $00, $3f, $00, $ff, $1f, $ff, $ff, $e0, $02, $d2, $00
	db $07, $fc, $07, $fc, $1f, $f8, $02, $1a, $22, $02, $d2, $0f, $01

;@ path: gfx/monsters/pictures
;@ Picture of BoxSlime (species $07): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $B6 packed).
MonPic_BoxSlime::
	db $40, $02, $04
	db $ff, $04, $ff, $ff, $4d, $04, $5f, $0f, $4d, $04, $8b, $0f, $18, $fb, $03, $f9
	db $1a, $04, $8c, $08, $ef, $e0, $8f, $48, $04, $8c, $0f, $1f, $fe, $00, $fe, $02
	db $fc, $07, $04, $36, $14, $e4, $7b, $80, $ff, $00, $ff, $06, $f9, $67, $9a, $77
	db $aa, $72, $ad, $20, $dc, $c7, $1c, $4b, $96, $4d, $93, $28, $f7, $00, $df, $20
	db $ff, $04, $5a, $10, $04, $8c, $03, $80, $3f, $00, $7f, $c0, $04, $6a, $10, $04
	db $8c, $0f, $0d, $fc, $07, $fe, $05, $04, $92, $10, $fd, $06, $fc, $07, $fd, $07
	db $fa, $02, $c0, $f8, $80, $81, $00, $87, $01, $fd, $0c, $ec, $60, $e0, $80, $80
	db $00, $00, $20, $ff, $21, $fe, $20, $ff, $f1, $fe, $0b, $0c, $05, $06, $02, $03
	db $01, $01, $04, $6a, $12, $04, $c0, $16, $04, $12, $1f, $0e, $02, $ff, $01, $04
	db $8c, $08, $04, $fc, $f0, $80, $80, $c0, $40, $f0, $30, $ef, $1f, $04, $fc, $14
	db $03, $03, $0f, $0c, $7f, $70, $bf, $04, $6f, $12, $c0, $ff, $04, $42, $10, $04
	db $8b, $0f, $06

;@ path: gfx/monsters/pictures
;@ Picture of Slime (species $08): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked by
;@ LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $65 packed).
MonPic_Slime::
	db $40, $02, $02, $ff, $02, $ff, $ff, $4d, $02, $5f, $0f, $4d, $02
	db $bf, $0f, $4d, $02, $eb, $0f, $17, $01, $ff, $01, $fe, $03, $02, $ea, $0b, $80
	db $02, $0e, $1f, $2f, $fc, $07, $f8, $0f, $d8, $17, $f0, $4f, $e4, $9b, $4e, $b5
	db $04, $fb, $ff, $80, $7f, $c0, $3f, $e0, $17, $f0, $07, $f4, $43, $be, $e1, $5f
	db $41, $bf, $02, $1a, $1f, $21, $02, $ea, $08, $18, $ff, $10, $70, $80, $f8, $c0
	db $7f, $f0, $3f, $ff, $0f, $02, $ea, $00, $31, $ff, $11, $1d, $03, $3e, $07, $fc
	db $1f, $f8, $ff, $e0, $02, $ea, $0f, $11

;@ path: gfx/monsters/pictures
;@ Picture of Healer (species $09): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $9C packed).
MonPic_Healer::
	db $40, $02, $09, $ff, $09, $ff, $ff, $4d
	db $09, $5f, $0f, $4d, $09, $85, $0f, $12, $fb, $07, $fc, $0c, $f3, $10, $ec, $20
	db $f8, $20, $09, $86, $02, $df, $e0, $3f, $30, $0f, $08, $07, $04, $07, $04, $09
	db $86, $0f, $24, $01, $09, $36, $11, $00, $ff, $00, $d0, $40, $c0, $40, $82, $80
	db $07, $02, $02, $00, $00, $04, $80, $83, $e0, $60, $0b, $02, $07, $0a, $41, $05
	db $e0, $42, $40, $00, $00, $20, $01, $c1, $07, $06, $09, $86, $03, $80, $09, $66
	db $11, $09, $85, $0f, $20, $df, $3f, $e9, $3f, $d2, $7f, $d6, $7f, $aa, $ff, $ea
	db $7f, $d5, $7f, $b5, $ff, $fb, $fc, $57, $fc, $ab, $fe, $ab, $fe, $ad, $ff, $b7
	db $fe, $b7, $fc, $db, $7e, $09, $86, $0f, $2d, $f5, $df, $fb, $0e, $fb, $0e, $fd
	db $07, $fe, $03, $09, $3a, $12, $df, $76, $df, $70, $bf, $e0, $bf, $e0, $ff, $c0
	db $09, $86, $0f, $13

;@ path: gfx/monsters/pictures
;@ Picture of FangSlime (species $0A): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $E6 packed).
MonPic_FangSlime::
	db $40, $02, $02, $ff, $02, $ff, $ff, $4d, $02, $5f, $0f, $4d
	db $02, $85, $0f, $11, $01, $ff, $03, $fd, $07, $fb, $0d, $fb, $3c, $fb, $2c, $02
	db $84, $01, $38, $ff, $48, $ff, $90, $df, $3c, $ef, $34, $bf, $65, $02, $84, $0b
	db $80, $02, $84, $0f, $0e, $03, $fc, $07, $fe, $03, $ff, $01, $02, $84, $03, $0c
	db $db, $ec, $4b, $f4, $29, $f2, $15, $fe, $85, $de, $d4, $77, $ea, $7f, $81, $cf
	db $3f, $86, $77, $8d, $d7, $2d, $4f, $1a, $2d, $72, $73, $7d, $bf, $ce, $1f, $e2
	db $02, $0e, $11, $e0, $ff, $40, $02, $0e, $13, $60, $02, $84, $0f, $0e, $0b, $fa
	db $1f, $e4, $3c, $f4, $1c, $e4, $34, $ec, $2c, $f2, $3e, $f5, $1f, $04, $bb, $0e
	db $35, $04, $7b, $30, $7f, $20, $67, $00, $20, $00, $18, $00, $07, $47, $b9, $e2
	db $5d, $40, $bf, $18, $ff, $08, $cf, $00, $0f, $00, $3f, $01, $f9, $ff, $a0, $ff
	db $b0, $7f, $c8, $7f, $d0, $5f, $e8, $6f, $f8, $bf, $d8, $5f, $f0, $02, $84, $0f
	db $0e, $1f, $f9, $0e, $fc, $15, $ff, $1d, $ff, $0a, $ff, $0c, $02, $84, $00, $c0
	db $c0, $f0, $30, $5f, $3f, $3f, $a0, $ff, $a0, $ff, $c0, $02, $84, $00, $07, $07
	db $1e, $19, $f5, $f8, $f9, $0b, $ff, $0a, $ff, $06, $02, $84, $01, $f0, $7f, $a0
	db $7f, $50, $ff, $70, $ff, $a0, $02, $6e, $1f, $03

;@ path: gfx/monsters/pictures
;@ Picture of RockSlime (species $0B): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $96 packed).
MonPic_RockSlime::
	db $40, $02, $05, $ff, $05, $ff
	db $ff, $4d, $05, $5f, $0f, $4d, $05, $bf, $0f, $4d, $05, $e3, $0f, $0f, $01, $ff
	db $02, $ff, $02, $ff, $04, $ff, $04, $fa, $09, $fd, $08, $05, $e2, $01, $80, $ff
	db $80, $7f, $c0, $7f, $c0, $3f, $60, $bf, $20, $05, $0e, $1f, $25, $fe, $03, $fe
	db $04, $ff, $04, $fd, $06, $ff, $33, $e7, $cc, $ad, $1b, $cf, $0a, $1d, $a9, $1f
	db $a4, $17, $1b, $38, $73, $df, $b8, $c7, $7e, $69, $b5, $ea, $b1, $67, $20, $c2
	db $79, $94, $f1, $3e, $18, $05, $e2, $03, $05, $55, $13, $7f, $40, $05, $e2, $0f
	db $0d, $fc, $06, $fe, $02, $ff, $01, $05, $e2, $06, $5f, $9f, $e7, $07, $1b, $c0
	db $88, $94, $a0, $2d, $ef, $0f, $05, $e2, $00, $f4, $f1, $c0, $cb, $8d, $61, $03
	db $1a, $0b, $e8, $ef, $e0, $05, $e2, $00, $7f, $c0, $ff, $80, $05, $e2, $0f, $09
;@ path: gfx/monsters/pictures
;@ Picture of SlimeBorg (species $0C): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $A3 packed).
MonPic_SlimeBorg::
	db $40, $02, $02, $ff, $02, $ff, $ff, $4d, $02, $5f, $0f, $4d, $02, $bf, $0f, $4d
	db $02, $e1, $0f, $0d, $04, $fb, $0e, $02, $42, $10, $e0, $04, $f1, $1f, $e1, $3f
	db $c2, $7e, $02, $e0, $03, $07, $ff, $19, $fc, $27, $e3, $cf, $af, $9c, $02, $e0
	db $03, $80, $ff, $40, $ff, $a0, $df, $f0, $bf, $f0, $02, $e0, $0f, $0e, $01, $fe
	db $03, $fd, $06, $f9, $0e, $e0, $07, $f0, $1f, $02, $9a, $10, $a2, $de, $c4, $3c
	db $87, $7f, $17, $ef, $3f, $d6, $13, $eb, $81, $bd, $c0, $de, $d7, $94, $93, $f3
	db $e1, $e1, $c0, $c0, $c2, $c2, $e9, $e9, $87, $87, $f9, $f9, $02, $6c, $10, $7f
	db $e0, $bf, $a0, $ff, $c0, $ff, $80, $02, $e0, $0f, $11, $e0, $07, $f8, $0b, $fc
	db $05, $ff, $03, $02, $e0, $04, $7f, $ff, $0e, $ce, $00, $ff, $00, $3f, $c0, $c0
	db $ff, $3f, $02, $e0, $00, $c2, $c2, $03, $62, $07, $c4, $1f, $18, $7f, $60, $02
	db $ca, $1f, $13

;@ path: gfx/monsters/pictures
;@ Picture of Slabbit (species $0D): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $C4 packed).
MonPic_Slabbit::
	db $40, $02, $02, $ff, $02, $ff, $ff, $4d, $02, $5f, $0f, $4d, $02
	db $7d, $0f, $09, $01, $fe, $03, $02, $7c, $03, $03, $fd, $1e, $e6, $79, $80, $ff
	db $00, $ff, $02, $7c, $03, $e0, $9f, $70, $3f, $e0, $7f, $c0, $7f, $c0, $02, $7c
	db $0f, $1d, $fc, $07, $f8, $0f, $f3, $14, $d3, $3d, $e3, $2d, $e1, $2e, $e6, $2f
	db $e6, $2e, $01, $fe, $01, $fe, $30, $cf, $b8, $57, $b8, $57, $10, $ef, $00, $e7
	db $00, $05, $bf, $60, $9f, $70, $4f, $b8, $23, $d0, $27, $dc, $07, $fc, $0f, $fc
	db $87, $7f, $02, $7c, $0f, $1d, $d0, $36, $f0, $13, $f8, $08, $fe, $06, $ff, $01
	db $02, $7c, $02, $01, $1a, $05, $fe, $04, $f7, $04, $05, $fe, $fe, $c1, $41, $fe
	db $3e, $fc, $04, $04, $02, $7c, $00, $f3, $08, $eb, $18, $1f, $f8, $ef, $f0, $97
	db $f0, $97, $ff, $80, $02, $c0, $18, $02, $fe, $0f, $1f, $f8, $0b, $f8, $0f, $f8
	db $0f, $f8, $0a, $fd, $05, $ff, $02, $df, $01, $02, $bc, $10, $78, $cb, $78, $c9
	db $7d, $45, $ff, $83, $02, $7c, $00, $3f, $f0, $0f, $f8, $8f, $f8, $7f, $f0, $1f
	db $10, $ff, $e0, $02, $7c, $0f, $01

;@ path: gfx/monsters/pictures
;@ Picture of SpotKing (species $0E): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $164 packed).
MonPic_SpotKing::
	db $40, $02, $08, $ff, $08, $ff, $ff, $15, $03
	db $ff, $04, $ff, $04, $fc, $07, $08, $00, $05, $80, $7f, $c0, $08, $3a, $00, $08
	db $00, $0f, $16, $08, $ff, $fc, $01, $08, $78, $01, $03, $ff, $03, $fd, $3e, $c7
	db $7f, $88, $f8, $10, $f0, $13, $f3, $17, $f4, $0f, $eb, $ff, $80, $7f, $f8, $c7
	db $fc, $23, $3e, $11, $1f, $91, $9f, $d1, $5f, $e1, $af, $08, $00, $0b, $80, $08
	db $5e, $0f, $0a, $03, $fb, $07, $ff, $02, $ff, $02, $fe, $03, $bf, $7f, $ff, $ff
	db $ff, $ff, $fe, $ff, $fc, $ff, $9d, $f6, $fd, $66, $ff, $23, $7f, $9f, $e0, $ff
	db $38, $bb, $7c, $7d, $fe, $ff, $73, $de, $7f, $cc, $fe, $89, $fd, $f3, $3f, $ff
	db $1d, $08, $76, $01, $ff, $80, $08, $00, $10, $fb, $fc, $ff, $fe, $08, $d8, $00
	db $7f, $ff, $08, $a2, $0a, $bf, $c0, $ff, $07, $08, $20, $13, $03, $fe, $03, $fc
	db $06, $fc, $06, $f8, $fb, $f8, $ff, $f0, $ff, $e0, $ff, $f0, $bf, $b8, $3f, $f8
	db $7f, $79, $7f, $fe, $e3, $fc, $e9, $7c, $e3, $40, $ff, $60, $ff, $58, $ff, $d7
	db $ef, $3f, $f0, $71, $8d, $73, $af, $75, $8f, $04, $ff, $0c, $ff, $34, $ff, $d6
	db $ef, $f9, $1f, $bf, $ff, $9f, $9f, $cf, $ef, $e7, $f7, $03, $ff, $00, $f8, $07
	db $f7, $0f, $f9, $ff, $c0, $08, $70, $13, $08, $01, $10, $c0, $ff, $c0, $fc, $06
	db $fc, $04, $08, $82, $12, $fa, $06, $fe, $02, $ff, $01, $08, $32, $10, $60, $7f
	db $00, $1f, $00, $0f, $01, $05, $07, $07, $0f, $0f, $0f, $08, $00, $05, $f0, $f7
	db $fc, $fd, $ff, $ff, $e0, $08, $26, $01, $08, $25, $11, $08, $00, $01, $0f, $f9
	db $0f, $ff, $07, $f7, $87, $f9, $87, $f9, $04, $f9, $0c, $e0, $19, $83, $08, $70
	db $15, $c0, $ff, $80, $7f, $08, $ff, $ff, $00, $9f, $9f, $df, $5f, $ff, $3f, $ef
	db $1f, $fb, $08, $2f, $04, $08, $00, $23, $fe, $fe, $3f, $bf, $08, $00, $00, $00
	db $7c, $81, $81, $81, $81, $03, $03, $03, $03, $fd, $fe, $08, $00, $00, $73, $46
	db $ff, $fc, $ff, $f8, $ef, $f0, $bf, $08, $3f, $0f, $04

;@ path: gfx/monsters/pictures
;@ Picture of KingSlime (species $0F): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $148 packed).
MonPic_KingSlime::
	db $40, $02, $05, $ff, $05
	db $ff, $ff, $15, $01, $ff, $01, $ff, $02, $ff, $02, $05, $00, $09, $80, $ff, $80
	db $05, $00, $0f, $16, $05, $17, $0f, $00, $fe, $02, $fe, $02, $fc, $0c, $ff, $10
	db $ff, $1f, $e0, $6c, $81, $b9, $43, $72, $e3, $b3, $63, $f2, $7f, $60, $ff, $10
	db $ff, $f0, $0f, $6c, $03, $3a, $85, $9d, $8e, $9a, $8c, $9e, $05, $30, $0f, $1d
	db $fe, $0e, $ff, $0b, $fd, $0e, $fe, $02, $fe, $03, $fb, $03, $e8, $0b, $e0, $2f
	db $7f, $dc, $ff, $80, $80, $60, $3f, $40, $ff, $05, $00, $03, $fc, $76, $ff, $03
	db $03, $0c, $f8, $04, $fe, $ff, $01, $05, $00, $01, $ff, $e0, $ff, $a0, $7f, $e0
	db $05, $3c, $00, $bf, $80, $2f, $a0, $0f, $e8, $05, $14, $0f, $03, $fc, $00, $fe
	db $03, $f8, $01, $fc, $06, $fc, $06, $c0, $7f, $98, $e7, $30, $8f, $60, $9f, $40
	db $3f, $80, $3f, $80, $3f, $01, $3f, $1c, $e3, $9c, $eb, $5c, $e3, $40, $ff, $60
	db $ff, $58, $ff, $d7, $ef, $3f, $f0, $70, $8f, $72, $af, $74, $8f, $04, $ff, $0c
	db $ff, $34, $ff, $d6, $ef, $f9, $1f, $07, $fc, $03, $fe, $01, $ff, $00, $fe, $05
	db $ff, $f2, $06, $f9, $05, $00, $02, $7f, $00, $ff, $80, $3f, $00, $7f, $c0, $7f
	db $c0, $fc, $04, $05, $80, $14, $05, $7c, $00, $ff, $01, $00, $3f, $00, $3f, $00
	db $1f, $00, $1f, $00, $0f, $00, $07, $00, $03, $00, $00, $0f, $05, $00, $0a, $7f
	db $e0, $05, $00, $0b, $06, $f9, $00, $fe, $00, $fe, $06, $f8, $06, $f9, $04, $f9
	db $0c, $e0, $19, $83, $05, $7c, $10, $05, $7c, $10, $3f, $00, $ff, $80, $7f, $05
	db $ff, $ff, $00, $80, $80, $c0, $40, $f0, $30, $fc, $0c, $ff, $03, $05, $00, $02
	db $00, $0f, $05, $fa, $f2, $80, $80, $ff, $7f, $05, $fc, $11, $fc, $05, $fa, $f2
	db $03, $03, $ff, $fc, $05, $00, $00, $33, $06, $07, $04, $1f, $18, $7f, $60, $05
	db $3e, $0f, $05

;@ path: gfx/monsters/pictures
;@ Picture of Metaly (species $10): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $65 packed).
MonPic_Metaly::
	db $40, $02, $05, $ff, $05, $ff, $ff, $4d, $05, $5f, $0f, $4d, $05
	db $bf, $0f, $4d, $05, $eb, $0f, $17, $01, $ff, $01, $fe, $02, $05, $ea, $0b, $80
	db $05, $0e, $1f, $2f, $fc, $04, $e8, $18, $f8, $30, $f0, $40, $e4, $80, $4e, $04
	db $04, $00, $ff, $80, $7f, $40, $2f, $30, $1f, $18, $07, $04, $43, $02, $e1, $41
	db $41, $01, $05, $1a, $1f, $21, $05, $ea, $08, $00, $18, $00, $1f, $80, $87, $c0
	db $40, $f0, $30, $ef, $1f, $05, $ea, $00, $01, $31, $01, $f1, $03, $c2, $07, $04
	db $1f, $18, $ef, $f0, $05, $ea, $0f, $11

;@ path: gfx/monsters/pictures
;@ Picture of Metabble (species $11): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $B7 packed).
MonPic_Metabble::
	db $40, $02, $05, $ff, $05, $ff, $ff, $4d
	db $05, $5f, $0f, $4d, $05, $bf, $0f, $4d, $05, $d3, $0e, $07, $f8, $0f, $f8, $0c
	db $f8, $08, $ff, $07, $ff, $00, $ff, $10, $ff, $00, $ff, $01, $fe, $83, $fe, $82
	db $ff, $81, $05, $3c, $10, $ef, $28, $ff, $00, $ff, $80, $7f, $c0, $7f, $40, $ff
	db $80, $ff, $0c, $f3, $1e, $f3, $12, $05, $d2, $0f, $1d, $ef, $28, $ff, $10, $ff
	db $01, $05, $d2, $03, $03, $fc, $0c, $ff, $10, $ff, $81, $7f, $46, $fc, $8a, $f8
	db $10, $e2, $e0, $07, $02, $02, $30, $ff, $0c, $ff, $f0, $9f, $58, $07, $04, $03
	db $02, $41, $01, $e0, $40, $40, $05, $d3, $00, $20, $df, $50, $ff, $20, $05, $50
	db $11, $70, $0f, $08, $05, $d2, $0f, $0d, $f0, $10, $fc, $0c, $fe, $02, $fc, $04
	db $ff, $03, $05, $d2, $02, $00, $38, $00, $1f, $00, $07, $00, $00, $80, $80, $ff
	db $7f, $05, $fc, $11, $30, $00, $f0, $00, $c0, $00, $00, $1f, $1f, $ff, $e0, $05
	db $d2, $00, $07, $04, $07, $04, $1f, $18, $05, $1a, $22, $05, $d2, $0f, $01

;@ path: gfx/monsters/pictures
;@ Picture of MetalKing (species $12): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $147 packed).
MonPic_MetalKing::
	db $40
	db $02, $09, $ff, $09, $ff, $ff, $15, $01, $ff, $01, $ff, $02, $ff, $02, $09, $00
	db $09, $80, $ff, $80, $09, $00, $0f, $16, $09, $17, $0f, $01, $03, $ff, $03, $fc
	db $0c, $ff, $10, $ff, $1f, $f3, $7f, $c7, $df, $c7, $f6, $ef, $bf, $6f, $fe, $7f
	db $60, $ff, $10, $ff, $f0, $9f, $fc, $c7, $f6, $c7, $df, $ef, $fb, $ed, $ff, $09
	db $30, $0f, $1e, $0f, $ff, $0b, $fd, $0e, $fe, $02, $fe, $03, $f7, $0f, $f8, $18
	db $e0, $20, $7f, $dc, $ff, $80, $80, $60, $3f, $40, $ff, $ff, $09, $fa, $f2, $fd
	db $77, $ff, $03, $03, $0c, $f8, $04, $fe, $ff, $01, $01, $09, $fc, $f1, $e0, $ff
	db $a0, $7f, $e0, $09, $3c, $00, $df, $e0, $3f, $30, $0f, $08, $09, $14, $0f, $03
	db $fd, $03, $fe, $02, $fa, $06, $fd, $05, $fd, $05, $c0, $40, $98, $80, $70, $40
	db $60, $00, $c0, $80, $c0, $40, $c0, $40, $c1, $c1, $08, $14, $9c, $88, $48, $54
	db $40, $40, $60, $60, $58, $78, $d7, $ef, $3f, $30, $20, $50, $72, $22, $24, $54
	db $04, $04, $0c, $0c, $34, $3c, $d6, $ee, $f9, $19, $07, $04, $03, $02, $01, $01
	db $09, $fa, $02, $00, $00, $06, $09, $ff, $f3, $7f, $80, $ff, $80, $bf, $c0, $7f
	db $40, $7f, $40, $ff, $07, $09, $80, $12, $fb, $03, $fb, $07, $ff, $03, $ff, $01
	db $c0, $c0, $c0, $c0, $e0, $e0, $e0, $e0, $f0, $f0, $f8, $f8, $fc, $fc, $ff, $ff
	db $0f, $0f, $09, $f4, $f8, $80, $80, $e0, $e0, $09, $f2, $fa, $06, $00, $09, $64
	db $10, $07, $01, $06, $00, $06, $02, $1e, $12, $7d, $65, $09, $7c, $10, $09, $d0
	db $12, $bf, $c0, $09, $3e, $0f, $02, $ff, $ff, $7f, $ff, $3f, $ef, $1f, $fb, $07
	db $09, $00, $02, $f0, $f0, $ff, $09, $02, $23, $3f, $bf, $09, $00, $00, $03, $03
	db $09, $02, $24, $f9, $fa, $09, $00, $00, $fb, $ca, $ff, $fc, $ff, $f8, $ef, $f0
	db $bf, $c0, $09, $00, $0f, $03

;@ path: gfx/monsters/pictures
;@ Picture of GoldSlime (species $13): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1EB packed).
MonPic_GoldSlime::
	db $40, $02, $0d, $ff, $0d, $ff, $f0, $01, $ff, $02
	db $ff, $04, $ff, $08, $f7, $1b, $ff, $14, $0d, $00, $01, $f0, $ff, $0c, $ff, $03
	db $ff, $00, $ef, $f0, $fb, $1c, $0d, $02, $03, $02, $fd, $1e, $ff, $e4, $cf, $7c
	db $fb, $3c, $0d, $00, $01, $80, $ff, $80, $7f, $f1, $ff, $4e, $e7, $7c, $bf, $78
	db $0d, $00, $01, $1f, $ff, $60, $ff, $80, $ff, $00, $ef, $1f, $bf, $70, $0d, $00
	db $01, $0d, $33, $00, $40, $ff, $20, $df, $b0, $ff, $50, $f7, $1c, $f7, $1c, $fb
	db $0e, $fd, $07, $fe, $03, $ff, $04, $0d, $08, $00, $fe, $2f, $db, $75, $96, $f9
	db $fd, $13, $0a, $c7, $e5, $3e, $e8, $3f, $f6, $39, $ff, $1b, $f7, $8c, $f7, $c4
	db $b4, $e7, $1b, $f3, $8c, $78, $07, $fc, $03, $ff, $fe, $b1, $5f, $e3, $5f, $c6
	db $5b, $cf, $b0, $9f, $60, $3f, $c0, $7f, $80, $ff, $ff, $e8, $df, $34, $93, $7e
	db $3f, $d1, $c7, $a0, $40, $f7, $2f, $f8, $1f, $f8, $df, $70, $df, $70, $bf, $e0
	db $7f, $c0, $ff, $80, $7f, $c0, $0d, $58, $00, $f9, $0e, $ff, $10, $f0, $1f, $ff
	db $11, $e2, $3f, $e6, $3c, $ef, $39, $df, $71, $ec, $33, $d8, $47, $d0, $ef, $90
	db $af, $a0, $df, $20, $5f, $0d, $ff, $f2, $1c, $e3, $9c, $eb, $5c, $e3, $40, $ff
	db $60, $ff, $58, $ff, $d7, $ef, $00, $ff, $70, $8f, $72, $af, $74, $8f, $04, $ff
	db $0c, $ff, $34, $ff, $d6, $ef, $08, $ff, $04, $f7, $06, $fe, $03, $fb, $02, $ff
	db $00, $fc, $01, $ff, $01, $ff, $3f, $e0, $1f, $f0, $1f, $10, $1f, $f0, $8f, $88
	db $cf, $48, $6f, $a8, $d7, $34, $fd, $63, $f9, $47, $f3, $6d, $d7, $59, $ed, $2b
	db $e4, $2e, $e6, $2b, $f7, $19, $01, $0d, $50, $03, $00, $7f, $00, $7f, $80, $ff
	db $80, $bf, $3f, $f0, $0f, $0d, $31, $14, $0d, $00, $01, $f9, $1f, $e0, $0d, $43
	db $19, $01, $ff, $19, $e7, $19, $e7, $01, $ff, $01, $fd, $30, $cc, $32, $cf, $23
	db $db, $9f, $6c, $27, $dc, $4f, $bc, $97, $74, $2f, $e8, $4f, $e8, $8f, $a8, $1f
	db $b0, $f6, $19, $f6, $19, $fe, $09, $fe, $09, $fe, $05, $fe, $05, $fe, $03, $ff
	db $01, $c0, $ff, $c0, $5f, $a0, $7f, $b0, $7f, $a8, $7f, $8c, $45, $9f, $53, $9c
	db $53, $0d, $44, $18, $00, $7f, $0d, $52, $12, $01, $fe, $0d, $ff, $f3, $fd, $0e
	db $ff, $66, $9f, $c6, $35, $8a, $7d, $1a, $fd, $2a, $fd, $4a, $7d, $a2, $c5, $53
	db $b5, $1f, $b0, $1f, $b0, $3f, $a0, $3f, $a0, $7f, $c0, $0d, $b6, $00, $0d, $43
	db $19, $0d, $ff, $f1, $91, $de, $c3, $44, $ee, $29, $f9, $1d, $fe, $0e, $ff, $0d
	db $30, $11, $9f, $7f, $07, $f7, $33, $b4, $8b, $94, $0b, $54, $cb, $d4, $db, $18
	db $fb, $03, $f4, $fb, $c9, $d6, $1a, $d9, $03, $d3, $00, $d4, $07, $d7, $37, $b0
	db $bf, $80, $93, $76, $07, $c4, $2f, $e8, $3f, $70, $ff, $0d, $52, $1a, $0d, $44
	db $15

;@ path: gfx/monsters/pictures
;@ Picture of DragonKid (species $14): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $12D packed).
MonPic_DragonKid::
	db $40, $02, $0c, $ff, $0c, $ff, $ff, $4d, $0c, $3d, $0f, $29, $0f, $fc, $7e
	db $0c, $3c, $09, $f0, $ff, $c0, $0c, $3c, $0f, $00, $1f, $fe, $7f, $f9, $1f, $fc
	db $07, $fe, $03, $fe, $03, $ff, $01, $0c, $aa, $00, $0f, $fc, $f3, $fe, $09, $ff
	db $12, $fb, $1d, $fd, $36, $ff, $ff, $01, $fe, $02, $fc, $07, $fd, $05, $f9, $0b
	db $fb, $8f, $7d, $df, $b1, $f7, $b3, $fb, $67, $f4, $9f, $d8, $1f, $90, $1f, $91
	db $9e, $92, $7d, $f5, $1a, $9a, $0c, $c0, $00, $e0, $60, $9f, $9f, $20, $20, $90
	db $90, $70, $70, $d9, $d9, $0c, $aa, $01, $fc, $3f, $30, $7f, $40, $ff, $80, $ff
	db $80, $ff, $00, $ff, $01, $0c, $20, $11, $0c, $3d, $05, $44, $ff, $e8, $ff, $fb
	db $1f, $ff, $0e, $ff, $0b, $0c, $20, $12, $a1, $bd, $d1, $ff, $41, $db, $81, $ff
	db $e1, $75, $71, $9f, $b9, $df, $a7, $f7, $0a, $8a, $16, $9e, $05, $05, $03, $82
	db $0f, $8d, $1d, $93, $3b, $37, $ca, $fe, $45, $45, $2f, $2f, $bf, $b1, $ff, $e0
	db $ff, $a0, $0c, $3c, $01, $0c, $1d, $10, $0c, $3d, $0f, $0b, $03, $ff, $03, $fd
	db $07, $ff, $0d, $0c, $ca, $00, $0c, $e2, $00, $c0, $f8, $40, $eb, $40, $7f, $40
	db $da, $28, $6f, $7d, $f7, $9a, $f3, $8c, $fd, $06, $6e, $05, $b5, $05, $e5, $04
	db $a4, $28, $e8, $7c, $dc, $b2, $92, $62, $62, $ff, $80, $7f, $40, $7f, $e0, $0c
	db $1a, $11, $0c, $c1, $10, $40, $0c, $3c, $0f, $0d, $fc, $05, $fd, $1a, $ff, $0d
	db $ff, $06, $0c, $3c, $04, $c0, $7e, $fa, $bf, $f7, $1f, $fc, $08, $ff, $04, $ff
	db $03, $0c, $3c, $00, $06, $07, $bf, $b9, $df, $f0, $7f, $20, $ff, $0c, $19, $10
	db $00, $ff, $00, $3f, $70, $7f, $e0, $0c, $ae, $0f, $02, $0c, $3d, $03

;@ path: gfx/monsters/pictures
;@ Picture of Tortragon (species $15): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $17C packed).
MonPic_Tortragon::
	db $40, $02
	db $04, $ff, $04, $ff, $ff, $4d, $04, $0b, $06, $02, $ff, $03, $fe, $02, $ff, $80
	db $ff, $40, $ff, $60, $ff, $31, $ff, $31, $ee, $3b, $ea, $3b, $fb, $bb, $ff, $20
	db $ff, $40, $ff, $c0, $ff, $80, $ff, $80, $ff, $88, $ff, $98, $ef, $a8, $04, $0a
	db $0f, $04, $01, $fe, $02, $fd, $0d, $f6, $37, $db, $dd, $04, $0a, $03, $c0, $bf
	db $a0, $df, $d0, $3f, $f0, $df, $b8, $ff, $01, $04, $c0, $05, $04, $0b, $01, $64
	db $7f, $b1, $bb, $6a, $7b, $a4, $ae, $5b, $5f, $df, $f5, $ca, $ea, $c0, $5f, $df
	db $d0, $bf, $b0, $df, $d0, $bf, $bc, $57, $56, $7b, $fb, $66, $fe, $71, $4b, $04
	db $c0, $00, $fe, $02, $fd, $05, $ff, $07, $fd, $85, $fa, $8b, $76, $56, $a7, $ba
	db $4f, $64, $9f, $e8, $9f, $c8, $3f, $d0, $3f, $90, $7f, $a0, $7f, $a0, $ff, $6e
	db $ff, $1c, $04, $0a, $0f, $09, $e0, $75, $f1, $3f, $ff, $2e, $ff, $35, $ee, $2e
	db $ee, $64, $b1, $ff, $ce, $fe, $f8, $f7, $8e, $f8, $87, $fc, $87, $c4, $bf, $be
	db $c3, $fe, $03, $c2, $3f, $bc, $fe, $ff, $47, $ff, $41, $ff, $20, $66, $b9, $79
	db $a6, $3e, $a1, $67, $b8, $7a, $7f, $a0, $ff, $a0, $7f, $60, $9f, $b0, $cf, $d8
	db $37, $fc, $0b, $7e, $87, $be, $04, $96, $0f, $00, $03, $fe, $02, $fd, $0f, $f0
	db $1b, $e1, $3e, $e7, $30, $e7, $3b, $85, $b7, $49, $cd, $3e, $ff, $44, $7e, $c5
	db $c5, $fe, $3f, $f7, $7b, $fd, $8e, $4f, $7c, $8f, $e8, $1f, $d8, $3f, $38, $d7
	db $e8, $ff, $00, $fb, $fc, $f6, $0f, $e5, $3d, $e3, $2f, $f0, $37, $f8, $3b, $d7
	db $2f, $fe, $01, $bf, $7f, $df, $e0, $43, $db, $24, $67, $f8, $fe, $45, $fd, $46
	db $47, $ff, $f8, $df, $bc, $7f, $e3, $ff, $00, $04, $86, $00, $7f, $e0, $1f, $b0
	db $0f, $f8, $cf, $18, $cf, $b8, $e7, $30, $e3, $3c, $f3, $19, $ef, $3f, $ff, $7e
	db $ff, $28, $04, $0a, $00, $f3, $9f, $e0, $bf, $e3, $ff, $ff, $3e, $04, $ea, $12
	db $ff, $00, $ff, $04, $00, $20, $80, $04, $0a, $07, $ff, $fe, $ff, $ff, $03, $04
	db $0a, $06, $9f, $f2, $0f, $fa, $8f, $ff, $ff, $f9, $04, $f8, $14, $cf, $18, $8f
	db $78, $9f, $30, $ef, $f8, $ff, $fc, $04, $ea, $12

;@ path: gfx/monsters/pictures
;@ Picture of Pteranod (species $16): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $156 packed).
MonPic_Pteranod::
	db $40, $02, $0c, $ff, $0c, $ff
	db $ff, $05, $04, $fb, $08, $ff, $0b, $ff, $0a, $0c, $00, $07, $c0, $ff, $40, $ff
	db $80, $0c, $10, $07, $32, $ff, $2d, $ff, $15, $0c, $00, $0f, $06, $0c, $ff, $fa
	db $03, $ff, $04, $ff, $0b, $fe, $0a, $fc, $15, $ff, $09, $fb, $34, $ff, $cd, $f7
	db $35, $c7, $dd, $07, $7d, $07, $fd, $07, $fd, $bf, $a0, $0c, $2c, $09, $00, $df
	db $59, $fd, $22, $ff, $1b, $fe, $0b, $0c, $96, $02, $fa, $17, $ff, $c0, $ff, $3c
	db $ff, $c3, $3f, $bc, $03, $fb, $00, $fe, $0c, $ff, $f0, $0c, $00, $01, $80, $7f
	db $0c, $2b, $00, $a0, $ff, $a0, $7f, $50, $fc, $17, $f8, $2b, $f8, $2f, $f0, $57
	db $f0, $5f, $f0, $5f, $e1, $af, $e3, $be, $05, $fe, $02, $fb, $01, $fd, $00, $fc
	db $00, $fe, $00, $fe, $e0, $fe, $f9, $1f, $ff, $c0, $bf, $7f, $7f, $80, $f7, $98
	db $af, $f0, $7f, $61, $fd, $87, $fa, $07, $f4, $ef, $78, $8f, $e8, $1f, $d0, $3f
	db $f0, $1f, $c8, $3f, $e8, $1f, $68, $9f, $0c, $ff, $f6, $1f, $ff, $7f, $e0, $ff
	db $80, $7f, $d0, $3f, $a8, $3f, $e8, $1f, $d4, $1f, $f4, $0f, $ea, $8f, $fa, $c7
	db $74, $e7, $bc, $cf, $58, $cf, $58, $ef, $28, $ff, $30, $ff, $10, $ff, $10, $ff
	db $08, $fd, $07, $fe, $03, $ff, $01, $ff, $01, $fe, $03, $ff, $02, $fd, $07, $ff
	db $06, $fe, $2b, $57, $7f, $fd, $f7, $7b, $b5, $de, $53, $dc, $d7, $fe, $77, $f6
	db $3d, $39, $cf, $29, $df, $3b, $ce, $3b, $ce, $3f, $f7, $4f, $fa, $77, $bd, $ff
	db $4a, $0c, $00, $05, $80, $7f, $40, $0c, $b2, $00, $e7, $34, $e7, $34, $ef, $38
	db $ff, $18, $ff, $18, $0c, $2a, $11, $0c, $ff, $f3, $f5, $05, $fa, $35, $d7, $ef
	db $e5, $2a, $fa, $0c, $1f, $05, $7f, $40, $ff, $f0, $7f, $ff, $ff, $87, $ff, $1a
	db $ff, $12, $ff, $05, $fd, $07, $fb, $0e, $f7, $3e, $ff, $f8, $ff, $c0, $fb, $89
	db $ff, $84, $0c, $00, $09, $0c, $85, $07, $0c, $ca, $1f, $4d, $0c, $00, $0f, $01
;@ path: gfx/monsters/pictures
;@ Picture of Gasgon (species $17): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1B5 packed).
MonPic_Gasgon::
	db $40, $02, $05, $ff, $05, $ff, $ff, $09, $01, $fe, $03, $05, $00, $01, $20, $df
	db $70, $df, $70, $df, $7c, $a3, $fa, $0f, $ed, $ff, $38, $c7, $7f, $f3, $ae, $f7
	db $7c, $f7, $ac, $f7, $7c, $f3, $ef, $13, $1e, $05, $00, $09, $80, $ff, $60, $05
	db $00, $0f, $0a, $05, $19, $01, $05, $00, $01, $03, $ff, $0c, $f7, $38, $c3, $44
	db $f9, $82, $ff, $f8, $e7, $37, $ff, $7c, $b2, $c7, $9f, $27, $d8, $18, $ef, $60
	db $ff, $80, $cb, $ce, $69, $ef, $a4, $e7, $7f, $ff, $e6, $81, $39, $40, $86, $08
	db $f1, $02, $df, $f0, $cf, $d8, $2f, $af, $23, $ef, $ef, $ec, $5b, $db, $a5, $75
	db $22, $7a, $05, $48, $03, $20, $df, $76, $db, $7e, $d7, $5c, $cf, $c8, $ff, $01
	db $fe, $02, $ff, $02, $ff, $04, $05, $c6, $00, $f9, $0a, $fc, $68, $fd, $01, $1f
	db $22, $c7, $0c, $f8, $08, $ff, $08, $ff, $10, $ff, $10, $7f, $90, $01, $02, $fc
	db $00, $ff, $00, $1f, $20, $c3, $04, $f8, $05, $ff, $f1, $fc, $01, $3e, $40, $8f
	db $10, $e3, $04, $f9, $02, $7c, $81, $1f, $21, $c7, $09, $a3, $3b, $65, $af, $20
	db $7f, $c4, $7e, $c3, $7f, $80, $f4, $00, $dc, $01, $fd, $c7, $4c, $bb, $be, $7f
	db $46, $bf, $a0, $9f, $90, $05, $16, $10, $7f, $60, $db, $7c, $ab, $ec, $d9, $da
	db $e8, $2c, $e4, $27, $d4, $d7, $9c, $9d, $fe, $66, $11, $12, $fc, $20, $ef, $30
	db $27, $f8, $21, $2e, $20, $f7, $20, $f9, $10, $fe, $ff, $00, $7f, $80, $0f, $10
	db $e0, $01, $f0, $0e, $05, $ff, $f1, $7f, $f2, $07, $f2, $0b, $c4, $3f, $04, $fe
	db $08, $3f, $08, $cf, $10, $ff, $10, $fb, $01, $b9, $01, $e9, $01, $f9, $01, $f9
	db $02, $ba, $03, $f3, $02, $d2, $03, $63, $3f, $20, $9f, $90, $1f, $10, $ff, $f0
	db $ff, $80, $7f, $40, $7f, $40, $ff, $c0, $fe, $03, $05, $70, $03, $05, $ff, $f3
	db $10, $17, $08, $fb, $88, $fc, $c4, $67, $f2, $3f, $fd, $0f, $ff, $03, $ff, $00
	db $00, $87, $00, $05, $ea, $00, $3f, $00, $c0, $00, $ff, $80, $bf, $f0, $70, $10
	db $ff, $10, $1f, $10, $fd, $0a, $9e, $09, $79, $04, $e4, $03, $9f, $06, $77, $02
	db $c2, $c3, $c3, $23, $a3, $2f, $ee, $33, $7e, $cf, $dc, $3f, $70, $6f, $e8, $ff
	db $80, $ff, $80, $05, $50, $0f, $10, $05, $f5, $10, $05, $ff, $f1, $ef, $6f, $f0
	db $90, $e9, $29, $e7, $77, $f0, $98, $bf, $ef, $ea, $7f, $ff, $1f, $fd, $ff, $7f
	db $42, $ff, $80, $ef, $ec, $3f, $3e, $ff, $fe, $9f, $dc, $ff, $e0, $f7, $dc, $ff
	db $0c, $05, $00, $0f, $09

;@ path: gfx/monsters/pictures
;@ Picture of FairyDrak (species $18): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $12D packed).
MonPic_FairyDrak::
	db $40, $02, $09, $ff, $09, $ff, $ff, $4d, $09, $15, $0f
	db $01, $30, $ff, $3c, $fb, $1a, $f1, $17, $f8, $0f, $f8, $0c, $09, $14, $09, $80
	db $7f, $ce, $09, $14, $07, $01, $fe, $02, $fc, $05, $ff, $00, $ff, $03, $fc, $0d
	db $f0, $37, $c0, $c3, $00, $3d, $60, $9d, $91, $6b, $ff, $e0, $ff, $f0, $7f, $70
	db $3f, $a0, $7f, $c0, $ff, $80, $ff, $80, $09, $14, $01, $0f, $09, $96, $02, $ff
	db $02, $ff, $04, $ff, $08, $fc, $05, $fc, $06, $fe, $c2, $ff, $7b, $fe, $96, $fc
	db $0f, $f0, $15, $fa, $18, $33, $7e, $6f, $fc, $9f, $f0, $2f, $fb, $24, $ec, $68
	db $eb, $38, $ff, $10, $f7, $f9, $0a, $f3, $15, $f3, $15, $e4, $ab, $47, $48, $20
	db $7f, $30, $f8, $10, $b4, $11, $eb, $a3, $d6, $c7, $ac, $87, $5c, $0f, $d8, $cf
	db $18, $0f, $d8, $1f, $b0, $09, $14, $0f, $04, $01, $ff, $03, $ff, $02, $09, $14
	db $00, $f6, $1f, $ee, $70, $fd, $85, $fb, $fa, $fb, $0b, $ff, $0d, $fe, $03, $fe
	db $03, $d0, $ff, $d2, $1f, $e6, $7b, $ff, $c5, $ff, $ff, $2f, $3d, $13, $10, $0b
	db $4a, $18, $fb, $8e, $ce, $45, $d5, $64, $ff, $67, $f6, $66, $e7, $d7, $d5, $cb
	db $69, $1f, $30, $3f, $e0, $df, $f8, $07, $dc, $43, $ae, $a3, $56, $43, $b6, $47
	db $ac, $09, $14, $0f, $0e, $01, $09, $14, $0a, $0b, $9a, $8b, $fa, $df, $75, $df
	db $70, $df, $70, $9f, $b0, $ff, $e0, $ff, $e0, $eb, $5e, $09, $b0, $10, $fd, $2d
	db $f6, $2f, $fd, $13, $ff, $0e, $ff, $00, $87, $ec, $8f, $98, $9f, $f0, $df, $fc
	db $5f, $7f, $df, $f1, $df, $50, $ff, $38, $09, $82, $08, $09, $14, $0f, $12, $e0
	db $ff, $e0, $df, $40, $09, $14, $0f, $08, $38, $09, $20, $20, $df, $10, $09, $14
	db $0f, $05

;@ path: gfx/monsters/pictures
;@ Picture of LizardMan (species $19): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1DF packed).
MonPic_LizardMan::
	db $40, $02, $11, $ff, $11, $ff, $f4, $01, $ff, $01, $ff, $02, $ff, $02
	db $11, $00, $03, $80, $11, $16, $01, $81, $ff, $81, $ff, $30, $cf, $78, $cf, $78
	db $9f, $f0, $9f, $f0, $9f, $b0, $5f, $70, $5f, $73, $11, $00, $01, $1c, $fb, $0a
	db $fd, $05, $fe, $0a, $f5, $35, $fb, $fa, $ff, $00, $ff, $60, $9f, $b0, $9f, $b0
	db $9f, $b8, $5f, $f8, $af, $f8, $ff, $78, $11, $00, $05, $11, $ff, $f4, $02, $ff
	db $02, $fd, $06, $11, $64, $06, $fe, $82, $fe, $82, $fd, $85, $fb, $8b, $fb, $8b
	db $f6, $96, $ea, $aa, $ec, $ac, $df, $f1, $df, $f3, $4e, $5a, $47, $4d, $2e, $2f
	db $74, $77, $94, $f7, $94, $d5, $86, $bf, $61, $67, $d9, $f9, $0e, $ff, $0a, $8f
	db $0b, $0f, $3d, $3d, $05, $05, $ff, $08, $7f, $84, $ff, $04, $8f, $72, $77, $fb
	db $bc, $af, $c0, $ec, $33, $e1, $11, $00, $05, $80, $7f, $c0, $7f, $e0, $ff, $d0
	db $fd, $06, $fc, $07, $fe, $03, $fe, $03, $ff, $11, $c7, $02, $06, $d5, $d5, $d6
	db $57, $e4, $67, $ee, $6f, $f1, $7f, $7e, $cf, $7f, $a5, $bd, $e7, $95, $f7, $1c
	db $bf, $3e, $e3, $3f, $a1, $2f, $b0, $27, $38, $51, $5f, $cb, $ce, $13, $9f, $a7
	db $ff, $0f, $b8, $bf, $b0, $fe, $41, $5c, $e3, $f1, $bf, $fa, $0e, $1f, $7e, $81
	db $bd, $ff, $fe, $47, $ec, $47, $ec, $a3, $ff, $47, $4f, $6f, $6b, $ef, $f8, $ff
	db $a8, $ff, $6c, $ff, $6c, $bf, $ec, $ff, $d4, $7f, $d4, $ff, $d4, $fe, $07, $fe
	db $07, $fd, $05, $11, $24, $13, $0d, $fe, $0e, $a5, $ff, $7e, $c7, $0e, $fb, $fe
	db $fb, $57, $57, $7a, $7a, $87, $ff, $c0, $cf, $27, $b4, $27, $bc, $27, $2c, $1d
	db $1e, $55, $56, $be, $bf, $e2, $fb, $71, $fd, $fc, $05, $fc, $07, $fc, $06, $f7
	db $0f, $f5, $0d, $ef, $1f, $48, $bb, $10, $f7, $bc, $b7, $b5, $bf, $b6, $bf, $7f
	db $5f, $fe, $9b, $ff, $1b, $fe, $8b, $fe, $eb, $11, $1a, $10, $f7, $ac, $ff, $a8
	db $ef, $b8, $ef, $b8, $bf, $f0, $bf, $f0, $fb, $1b, $f7, $15, $ef, $29, $ff, $31
	db $11, $00, $04, $e0, $20, $f9, $19, $ff, $11, $c3, $04, $04, $ff, $04, $80, $fe
	db $04, $ef, $04, $d5, $04, $74, $08, $28, $1f, $df, $ff, $f0, $9f, $70, $e1, $ef
	db $00, $1f, $04, $fd, $0c, $0c, $7f, $73, $ff, $80, $11, $00, $00, $1f, $f1, $0f
	db $79, $0f, $d9, $0f, $48, $0f, $fc, $ff, $f4, $9f, $e4, $cf, $f4, $7f, $e0, $7f
	db $c0, $7f, $c0, $11, $ba, $12, $11, $d8, $1f, $02, $04, $ff, $06, $f9, $1f, $e4
	db $35, $dd, $7d, $fe, $63, $ff, $01, $ff, $00, $3f, $e0, $7f, $e0, $bf, $e0, $5f
	db $d0, $6f, $f8, $ff, $98, $11, $02, $04, $11, $c6, $01, $11, $ff, $f3, $bf, $be
	db $09, $6b, $e3, $ef, $fd, $1f, $11, $16, $26, $11, $b8, $00, $ff, $c0, $11, $00
	db $04

;@ path: gfx/monsters/pictures
;@ Picture of Poisongon (species $1A): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $180 packed).
MonPic_Poisongon::
	db $40, $02, $0c, $ff, $0c, $ff, $ff, $4d, $0c, $0d, $08, $01, $fe, $07, $0c
	db $0c, $09, $f0, $7f, $e0, $0c, $68, $02, $ff, $01, $ff, $02, $ff, $02, $fe, $07
	db $0c, $6e, $01, $10, $df, $10, $37, $32, $f7, $d4, $ec, $ac, $fd, $b5, $bb, $ea
	db $0c, $0c, $03, $08, $df, $10, $ff, $e0, $ff, $40, $ff, $80, $0c, $0c, $0c, $f8
	db $0b, $f1, $1b, $e1, $37, $e3, $37, $c0, $7b, $c0, $6c, $c0, $7d, $c0, $77, $0c
	db $ae, $05, $c0, $3f, $ff, $00, $36, $00, $c0, $ff, $0b, $fb, $0f, $ff, $1d, $fd
	db $77, $d7, $7f, $f9, $f9, $22, $ff, $43, $76, $77, $d5, $7f, $da, $ff, $b4, $ff
	db $a8, $ff, $6e, $f1, $57, $f0, $5d, $a0, $f7, $0c, $0c, $07, $80, $7f, $c0, $3f
	db $0c, $7f, $02, $0c, $0d, $07, $e0, $3e, $f0, $2b, $f8, $17, $ff, $09, $fe, $07
	db $fe, $03, $fe, $03, $fe, $02, $00, $ff, $3d, $fd, $c2, $f7, $02, $bf, $05, $ef
	db $04, $7f, $08, $dd, $08, $7f, $83, $de, $03, $fe, $01, $af, $c1, $fb, $21, $ff
	db $d0, $ff, $28, $ff, $16, $7f, $e0, $bf, $e0, $bd, $c0, $77, $c1, $7f, $c2, $6f
	db $85, $7f, $02, $f7, $34, $ff, $1f, $b7, $18, $fd, $08, $ff, $88, $fd, $44, $fe
	db $87, $ef, $04, $ff, $08, $be, $0c, $08, $12, $7f, $40, $7f, $40, $ff, $80, $7f
	db $e0, $1f, $f0, $0c, $86, $01, $03, $0c, $80, $04, $fe, $03, $7c, $3d, $c3, $ff
	db $fc, $7f, $c3, $f3, $81, $ff, $06, $d7, $18, $7f, $26, $ff, $34, $ff, $c0, $ff
	db $00, $fd, $00, $8f, $20, $57, $70, $af, $20, $df, $00, $7f, $16, $ff, $01, $7f
	db $00, $ff, $00, $d8, $02, $75, $07, $fa, $02, $fd, $00, $ff, $1e, $df, $e1, $ff
	db $1e, $ff, $63, $ed, $7f, $42, $3f, $fe, $0f, $fd, $33, $7e, $0f, $b8, $0f, $e8
	db $0f, $78, $0f, $e8, $8f, $48, $ff, $14, $ff, $ac, $ff, $78, $fe, $02, $fe, $02
	db $ff, $05, $ff, $06, $ff, $01, $0c, $0c, $02, $3b, $ff, $1f, $25, $ff, $0a, $ff
	db $b5, $ff, $ce, $0c, $0c, $02, $c1, $5f, $78, $bb, $af, $cf, $db, $63, $f7, $38
	db $ff, $0f, $0c, $0c, $00, $41, $fd, $0f, $ee, $fa, $f9, $ed, $e3, $f7, $0e, $ff
	db $f8, $0c, $0c, $01, $4e, $7f, $c0, $ff, $a0, $ff, $50, $ff, $30, $0c, $0c, $0f
	db $03

;@ path: gfx/monsters/pictures
;@ Picture of Swordgon (species $1B): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1DE packed).
MonPic_Swordgon::
	db $40, $02, $0a, $ff, $0a, $ff, $f8, $01, $ff, $01, $0a, $00, $01, $02, $ff
	db $03, $ff, $23, $ff, $32, $f9, $2a, $ec, $b7, $0a, $00, $03, $08, $ff, $08, $ff
	db $99, $fb, $92, $ad, $36, $0a, $00, $05, $80, $ff, $90, $ff, $b0, $7f, $54, $0a
	db $00, $09, $00, $ff, $40, $0a, $40, $0b, $00, $ff, $09, $fc, $0c, $fe, $64, $fd
	db $56, $f8, $2b, $fa, $17, $f5, $1b, $fa, $0d, $ce, $53, $66, $ab, $b7, $d9, $9b
	db $ed, $db, $6d, $6d, $b6, $6d, $b6, $b7, $da, $ad, $36, $6d, $b6, $6f, $b5, $0a
	db $84, $00, $bf, $d5, $bf, $d5, $be, $d7, $af, $cd, $ba, $d3, $0a, $7a, $00, $db
	db $6d, $f6, $5a, $fc, $55, $a9, $f2, $ff, $c0, $ff, $80, $ff, $f0, $8f, $bc, $c3
	db $4f, $fc, $ff, $fb, $83, $f7, $e4, $0a, $00, $07, $80, $7f, $c0, $bf, $e0, $fd
	db $06, $fe, $03, $fc, $04, $ff, $05, $ff, $02, $fe, $03, $0a, $0e, $00, $b6, $db
	db $db, $6d, $6d, $b7, $b6, $db, $54, $fe, $ac, $7d, $54, $bc, $d9, $eb, $ff, $56
	db $ef, $7f, $82, $cb, $0f, $2f, $3f, $b0, $7f, $c0, $bf, $c1, $7f, $80, $fb, $ad
	db $f6, $5f, $ab, $fd, $76, $db, $fd, $ee, $f3, $7d, $ee, $93, $9c, $67, $6f, $a8
	db $df, $71, $bf, $e0, $ff, $40, $bf, $e0, $1f, $70, $8f, $b8, $87, $9c, $ff, $a0
	db $df, $30, $ff, $90, $ef, $58, $cf, $78, $ff, $28, $f7, $2c, $f7, $1c, $ff, $00
	db $ff, $0d, $f2, $16, $f9, $2f, $fc, $3f, $f4, $15, $e6, $37, $ff, $5d, $e9, $f9
	db $56, $7e, $69, $7f, $6b, $7d, $cf, $fc, $8b, $ee, $71, $ff, $57, $d8, $0f, $f0
	db $e7, $f8, $50, $ff, $79, $5f, $d6, $ce, $e9, $2b, $fc, $d5, $bf, $6b, $78, $89
	db $f9, $19, $76, $be, $b4, $fc, $63, $ef, $31, $f7, $4e, $fe, $d6, $ef, $c7, $cc
	db $33, $f6, $4b, $fe, $9f, $f6, $3f, $7e, $2b, $ee, $67, $ee, $ff, $ba, $ff, $14
	db $0a, $70, $12, $f7, $1c, $ff, $18, $0a, $7a, $11, $67, $fe, $02, $0a, $0e, $03
	db $0a, $09, $01, $97, $98, $0f, $08, $06, $37, $c1, $dd, $e1, $23, $fe, $1e, $fc
	db $0d, $f9, $fb, $df, $36, $ef, $19, $f6, $0f, $1f, $a0, $e3, $ff, $7c, $df, $fc
	db $c5, $ff, $03, $b9, $c9, $78, $88, $e8, $18, $7c, $fc, $8b, $f7, $0e, $f1, $1d
	db $e3, $37, $ce, $e7, $fe, $03, $fe, $07, $7c, $07, $7c, $0f, $38, $ff, $f0, $df
	db $d0, $cf, $78, $ff, $10, $ff, $30, $ff, $20, $ff, $60, $ff, $40, $ff, $40, $ff
	db $80, $ff, $00, $fe, $07, $ff, $09, $ff, $0e, $ff, $0b, $ff, $02, $0a, $00, $02
	db $61, $6f, $8f, $ff, $ff, $70, $ff, $c0, $0a, $30, $07, $40, $ff, $c0, $0a, $4e
	db $07, $f8, $ff, $03, $fe, $06, $ff, $09, $ff, $0f, $ff, $08, $0a, $00, $00, $87
	db $ac, $33, $77, $79, $cb, $ff, $ce, $ff, $03, $0a, $b0, $08, $0a, $02, $26

;@ path: gfx/monsters/pictures
;@ Picture of Dragon (species $1C): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $17E packed).
MonPic_Dragon::
	db $40
	db $02, $0b, $ff, $0b, $ff, $ff, $17, $08, $ff, $0a, $f5, $1f, $0b, $00, $0f, $18
	db $0b, $ff, $ff, $09, $01, $fe, $03, $fc, $07, $fc, $07, $f8, $0f, $f5, $3f, $f5
	db $3f, $cd, $ff, $06, $ff, $06, $ff, $05, $ff, $05, $ff, $06, $ff, $ff, $00, $ff
	db $80, $ff, $e0, $9f, $90, $8f, $8b, $45, $d7, $47, $d7, $82, $9a, $0b, $00, $07
	db $c1, $7f, $f3, $dd, $0b, $8f, $00, $0b, $ff, $f2, $fc, $67, $e6, $8f, $b8, $1f
	db $70, $0b, $00, $0c, $f8, $0f, $f8, $0f, $f0, $1f, $f0, $3f, $f0, $5f, $f8, $5f
	db $fc, $97, $fc, $a7, $04, $0b, $89, $03, $06, $ff, $02, $ff, $23, $ff, $21, $ff
	db $c2, $db, $42, $db, $41, $cd, $a1, $ed, $e1, $e5, $91, $91, $4d, $cd, $63, $e3
	db $36, $be, $1c, $dd, $0b, $91, $00, $c3, $fc, $7f, $43, $bf, $bc, $df, $50, $3f
	db $e0, $7f, $a0, $ff, $40, $ff, $40, $ff, $80, $0b, $6c, $08, $0b, $24, $13, $03
	db $ff, $7e, $fe, $a3, $ff, $a1, $ff, $20, $fb, $24, $bf, $64, $bd, $66, $ba, $67
	db $f3, $4f, $41, $ff, $40, $ff, $c0, $ff, $c0, $7f, $c0, $7f, $e0, $3f, $70, $bf
	db $1c, $ff, $51, $f1, $d0, $f3, $58, $fb, $74, $ff, $5c, $df, $46, $e7, $42, $fb
	db $42, $ff, $cf, $48, $ef, $f8, $27, $bc, $13, $fe, $0d, $ff, $02, $ff, $79, $ff
	db $2d, $e7, $0b, $00, $07, $80, $ff, $80, $7f, $40, $ff, $a4, $ff, $f8, $ff, $2b
	db $ff, $5c, $ff, $60, $0b, $22, $11, $0e, $77, $cc, $e7, $5c, $ef, $58, $ef, $d8
	db $ff, $50, $ff, $90, $ef, $98, $c7, $3e, $cb, $ff, $fe, $3f, $ff, $01, $0b, $00
	db $06, $84, $ff, $9c, $ff, $e2, $e3, $c7, $5d, $e7, $3c, $ef, $38, $f7, $1c, $fb
	db $67, $1f, $f3, $0c, $ff, $70, $ff, $e8, $af, $e7, $27, $f0, $10, $f0, $10, $ff
	db $8f, $ff, $40, $ff, $f8, $07, $e4, $03, $fa, $eb, $fa, $73, $5a, $3f, $2c, $1f
	db $10, $ff, $15, $ff, $1e, $ff, $05, $ff, $09, $ff, $0a, $ff, $0c, $0b, $00, $01
	db $09, $ff, $3f, $ff, $c0, $0b, $00, $0f, $07, $fc, $93, $fe, $fd, $ff, $03, $0b
	db $00, $07, $c7, $7f, $e5, $bf, $f2, $df, $b9, $df, $74, $ff, $33, $0b, $00, $00
	db $df, $d0, $ff, $e0, $ff, $40, $ff, $e0, $bf, $60, $0b, $f4, $12

;@ path: gfx/monsters/pictures
;@ Picture of MiniDrak (species $1D): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $EC packed).
MonPic_MiniDrak::
	db $40, $02, $08
	db $ff, $08, $ff, $ff, $4d, $08, $27, $0f, $13, $03, $fe, $02, $fe, $02, $fe, $06
	db $fd, $05, $ff, $00, $ff, $18, $ef, $28, $cf, $48, $df, $d0, $9f, $97, $19, $19
	db $eb, $ea, $08, $26, $0f, $2d, $fe, $07, $f3, $36, $ed, $2c, $d0, $17, $e0, $3f
	db $e3, $3b, $ff, $1f, $fc, $c5, $07, $bf, $82, $7e, $85, $8f, $01, $7f, $21, $ef
	db $b3, $8e, $6f, $94, $ef, $04, $ff, $80, $ff, $80, $08, $26, $0f, $16, $01, $ff
	db $01, $ff, $0c, $fb, $0b, $fc, $7f, $d0, $5f, $ef, $70, $d2, $ef, $6f, $5f, $9f
	db $f0, $bb, $a3, $9f, $98, $77, $f5, $16, $f7, $0a, $fb, $c6, $3f, $6e, $9e, $b5
	db $df, $83, $ee, $83, $9e, $09, $f7, $7c, $87, $7e, $c7, $f8, $ce, $3d, $ef, $7f
	db $08, $9f, $04, $08, $01, $10, $80, $7f, $c0, $3f, $f8, $08, $1a, $1f, $04, $01
	db $08, $26, $04, $bf, $e0, $7f, $c0, $7f, $c0, $08, $02, $16, $a9, $fe, $c9, $7e
	db $c9, $7e, $87, $fc, $85, $fe, $82, $fb, $81, $b1, $c1, $41, $ff, $a0, $08, $26
	db $04, $7c, $83, $83, $ff, $ff, $7d, $27, $fc, $23, $fe, $23, $be, $c3, $5e, $43
	db $ca, $f7, $f4, $7f, $68, $bf, $fc, $08, $26, $0f, $1d, $fd, $3d, $f1, $11, $e4
	db $3e, $fa, $5f, $ff, $65, $ff, $06, $08, $82, $04, $ff, $81, $08, $02, $16, $07
	db $8e, $1f, $1d, $ff, $e3, $08, $26, $0f, $07

;@ path: gfx/monsters/pictures
;@ Picture of MadDragon (species $1E): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $1EE packed).
MonPic_MadDragon::
	db $40, $02, $05, $ff, $05, $ff, $ff
	db $19, $18, $ff, $17, $ff, $c0, $ff, $a0, $df, $70, $df, $68, $df, $68, $ef, $37
	db $ec, $f5, $98, $b8, $ff, $06, $ff, $0a, $f7, $1c, $ef, $34, $ef, $34, $df, $e8
	db $5f, $ee, $33, $ff, $05, $00, $09, $30, $ff, $d0, $05, $00, $01, $01, $fe, $02
	db $fc, $04, $f8, $38, $d9, $69, $f9, $7b, $05, $00, $01, $e0, $1f, $70, $0f, $38
	db $0f, $18, $07, $1c, $07, $1c, $fd, $0b, $ff, $07, $fc, $1c, $f9, $39, $f8, $6b
	db $f9, $cb, $fb, $8b, $fe, $07, $c0, $78, $92, $fe, $18, $1e, $94, $97, $c0, $c3
	db $f0, $f0, $5f, $ef, $7f, $f0, $07, $fd, $93, $ff, $30, $ff, $53, $ff, $07, $fe
	db $1f, $1f, $f7, $ed, $ff, $1c, $7f, $a0, $ff, $c0, $7f, $f0, $3f, $f8, $bf, $6c
	db $bf, $66, $bf, $e2, $ff, $c0, $f3, $17, $e7, $2e, $d9, $7f, $b7, $dd, $ee, $ef
	db $ee, $2b, $fe, $33, $fe, $13, $c3, $ce, $83, $8e, $03, $0e, $01, $0f, $01, $07
	db $00, $05, $d9, $01, $fc, $0f, $ff, $0b, $ff, $19, $ff, $11, $fe, $02, $fc, $84
	db $79, $d9, $62, $e3, $2f, $ef, $2c, $fc, $b8, $e8, $b8, $e8, $5f, $77, $af, $f8
	db $97, $ff, $59, $fe, $ef, $e8, $6f, $79, $3f, $2a, $3f, $2a, $ff, $d4, $ff, $28
	db $ff, $d0, $ff, $20, $7f, $e0, $ff, $a0, $ff, $30, $ff, $10, $ff, $10, $05, $00
	db $03, $13, $fe, $06, $fb, $1b, $fc, $3f, $e1, $7f, $c2, $ff, $e4, $3f, $fe, $1f
	db $e0, $e3, $1d, $1f, $e6, $e6, $7c, $fc, $ac, $fc, $4c, $fc, $4c, $fc, $8a, $fa
	db $85, $87, $08, $0f, $0c, $0f, $53, $5f, $30, $3f, $af, $bf, $60, $7f, $1e, $1f
	db $37, $ff, $f3, $de, $39, $ef, $f8, $cf, $fc, $1f, $f8, $ef, $fa, $0f, $fc, $3f
	db $ff, $de, $e1, $ff, $9f, $ff, $fe, $f9, $d7, $fe, $6d, $db, $7e, $c9, $57, $ed
	db $ff, $00, $ff, $80, $7f, $e0, $ff, $f0, $df, $38, $ef, $1c, $ff, $90, $ff, $e0
	db $ff, $31, $ff, $01, $ff, $01, $05, $60, $02, $05, $82, $10, $f1, $f1, $b0, $b0
	db $40, $c0, $80, $80, $80, $80, $05, $fc, $f0, $02, $02, $89, $89, $a7, $a7, $b4
	db $b7, $cf, $05, $30, $00, $ff, $df, $ff, $60, $7f, $c0, $ff, $b3, $ff, $4a, $df
	db $da, $ff, $6e, $ee, $16, $f6, $ec, $ec, $15, $d5, $bf, $fe, $3f, $f2, $0f, $fc
	db $03, $fe, $01, $7f, $00, $1f, $00, $0f, $00, $07, $ff, $30, $05, $00, $05, $80
	db $05, $da, $11, $05, $85, $12, $0f, $f6, $1a, $ff, $1f, $05, $00, $00, $01, $01
	db $80, $80, $c1, $c1, $3e, $3e, $30, $30, $df, $ef, $ff, $78, $ff, $00, $5f, $7f
	db $a0, $ff, $ff, $ff, $7f, $60, $1f, $18, $f7, $fc, $ff, $0c, $ff, $00, $ea, $ea
	db $1c, $9c, $ff, $f7, $fe, $06, $f8, $18, $e0, $60, $bf, $ff, $ff, $c0, $01, $07
	db $01, $07, $c3, $ce, $0f, $0e, $73, $73, $31, $3f, $05, $fa, $12, $05, $00, $03
	db $c0, $7f, $a0, $ff, $e0, $ff, $00

;@ path: gfx/monsters/pictures
;@ Picture of Rayburn (species $1F): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1B0 packed).
MonPic_Rayburn::
	db $40, $02, $10, $ff, $10, $ff, $ff, $07, $01
	db $fe, $02, $fd, $07, $10, $00, $05, $c0, $ff, $80, $ff, $83, $fc, $87, $10, $00
	db $03, $03, $fc, $0f, $f0, $7c, $80, $f1, $00, $10, $2f, $00, $60, $9f, $f0, $0f
	db $b8, $6f, $78, $3f, $f0, $2f, $e8, $77, $fc, $10, $00, $0f, $08, $10, $ff, $f1
	db $fc, $07, $fc, $07, $f9, $0f, $f1, $1f, $f5, $1f, $ed, $3f, $d6, $7f, $d8, $7b
	db $fb, $8f, $fc, $9f, $e0, $3f, $5c, $7f, $78, $6e, $90, $dd, $01, $7f, $03, $de
	db $c1, $df, $33, $fe, $8f, $bc, $c7, $dc, $07, $ec, $e3, $d6, $b3, $66, $f3, $2e
	db $e7, $bc, $e7, $3c, $f3, $1e, $f1, $1f, $f6, $1f, $f5, $1f, $e2, $3f, $ea, $3f
	db $10, $00, $05, $80, $7f, $c0, $bf, $e0, $5f, $f0, $ff, $06, $f9, $0f, $f1, $1d
	db $f6, $1b, $ee, $33, $ed, $37, $dd, $6f, $fd, $57, $b9, $fb, $5c, $ff, $54, $ff
	db $96, $ff, $95, $ff, $54, $bf, $68, $bf, $6b, $bc, $03, $fa, $1f, $be, $37, $e2
	db $67, $c4, $ce, $85, $79, $df, $22, $ff, $9c, $7f, $fb, $2e, $8f, $7c, $97, $7c
	db $67, $ff, $92, $ef, $78, $87, $78, $03, $fc, $02, $ed, $3f, $ed, $3f, $cd, $ff
	db $0d, $df, $35, $7f, $45, $ff, $82, $ff, $86, $fb, $5f, $f0, $2f, $f8, $2f, $f8
	db $57, $bc, $10, $16, $10, $eb, $9e, $eb, $9e, $fd, $a7, $fa, $cf, $fa, $0f, $10
	db $24, $14, $fb, $0f, $6f, $b8, $ef, $38, $ef, $38, $ef, $39, $fe, $1b, $fd, $7e
	db $fe, $9f, $ff, $09, $c5, $3e, $f9, $1e, $eb, $38, $cb, $fc, $43, $dc, $43, $f4
	db $cf, $64, $ad, $f6, $fe, $01, $fe, $01, $10, $00, $06, $fe, $01, $8e, $f3, $7e
	db $e3, $5e, $f3, $4e, $fb, $0f, $ef, $cf, $3b, $ef, $8b, $ef, $9a, $10, $1c, $10
	db $10, $70, $11, $1e, $eb, $de, $eb, $3e, $ff, $1c, $fb, $0e, $fb, $0e, $ff, $0c
	db $ff, $04, $10, $86, $11, $10, $ff, $f0, $08, $10, $00, $0a, $ee, $73, $fd, $13
	db $fd, $0b, $f7, $05, $ff, $09, $fe, $09, $fe, $05, $ff, $05, $79, $87, $87, $ff
	db $ff, $79, $ff, $01, $fe, $03, $fe, $83, $ff, $81, $ff, $01, $5f, $b2, $7f, $a0
	db $5f, $c0, $ff, $20, $ff, $20, $ff, $40, $ff, $40, $ff, $20, $ff, $1c, $ff, $1c
	db $ff, $0c, $ff, $08, $10, $d6, $11, $10, $03, $0f, $08, $ff, $03, $10, $00, $02
	db $fd, $0b, $fd, $72, $ee, $9b, $ff, $ff, $fb, $0a, $10, $8a, $13, $02, $fe, $c7
	db $fb, $6b, $df, $dc, $ff, $30, $10, $00, $02, $bf, $58, $ef, $bc, $fb, $fa, $df
	db $56, $ff, $20, $10, $00, $0f, $03

;@ path: gfx/monsters/pictures
;@ Picture of Chamelgon (species $20): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $11F packed).
MonPic_Chamelgon::
	db $40, $02, $04, $ff, $04, $ff, $ff, $4d, $04
	db $25, $0f, $11, $06, $fd, $0d, $f9, $0b, $fd, $0d, $f0, $17, $f8, $1a, $04, $24
	db $07, $01, $fe, $83, $fe, $83, $04, $24, $02, $fb, $78, $bd, $fc, $7e, $c6, $e7
	db $83, $cf, $04, $9f, $03, $04, $60, $0f, $14, $05, $fe, $02, $f0, $17, $f8, $1b
	db $f0, $15, $f8, $1b, $f0, $16, $f8, $1b, $f0, $37, $e0, $ae, $04, $9c, $00, $fe
	db $83, $ff, $b1, $df, $f0, $9f, $99, $6e, $fb, $5c, $f5, $de, $82, $dd, $94, $6b
	db $48, $7f, $60, $bf, $f0, $5f, $c8, $df, $e8, $cf, $f4, $04, $24, $0f, $0e, $61
	db $df, $70, $ef, $3c, $f3, $1f, $f0, $17, $fc, $0d, $fa, $0a, $fd, $1f, $70, $77
	db $e1, $ef, $b0, $b4, $21, $2d, $ba, $bb, $44, $ef, $44, $fe, $45, $d7, $ad, $ef
	db $55, $df, $69, $7b, $98, $ff, $14, $dc, $64, $7d, $a2, $bf, $42, $df, $cf, $54
	db $cf, $74, $cf, $54, $8f, $f4, $0f, $b4, $1f, $68, $1f, $e8, $3f, $d0, $04, $24
	db $0f, $0a, $01, $ff, $03, $ec, $3d, $f4, $37, $eb, $2b, $ff, $7b, $8e, $cf, $95
	db $f7, $4f, $6e, $cf, $fc, $ba, $ff, $44, $fe, $83, $bb, $01, $d7, $ba, $ff, $c7
	db $45, $c6, $83, $ff, $47, $61, $ef, $50, $d5, $ab, $ab, $ff, $be, $ef, $f9, $47
	db $ee, $c7, $cf, $e3, $3e, $ff, $e0, $3f, $a0, $bf, $e0, $bf, $e0, $bf, $f0, $1f
	db $f8, $c7, $fc, $ff, $3c, $04, $24, $0c, $fd, $07, $fe, $07, $ff, $03, $04, $24
	db $06, $8f, $f2, $7f, $be, $ff, $c0, $04, $24, $07, $38, $04, $24, $0a, $f3, $1e
	db $f3, $1f, $f0, $3f, $f1, $4f, $fe, $7d, $04, $e4, $17, $c0, $bf, $e0, $7f, $e0
	db $ff, $e0, $04, $24, $0f, $01

;@ path: gfx/monsters/pictures
;@ Picture of LizardFly (species $21): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $180 packed).
MonPic_LizardFly::
	db $40, $02, $08, $ff, $08, $ff, $f6, $70, $ff, $8c
	db $8f, $f3, $08, $00, $07, $07, $fe, $0b, $f4, $1e, $08, $00, $05, $c0, $7f, $e0
	db $ff, $a8, $ff, $e4, $08, $00, $05, $06, $fd, $0f, $fe, $2b, $fe, $4e, $08, $00
	db $07, $c0, $ff, $a0, $5f, $f1, $08, $00, $07, $1c, $ff, $62, $e3, $9e, $f3, $4c
	db $c4, $7b, $fb, $24, $f5, $2a, $fe, $11, $fd, $0a, $ff, $06, $ff, $01, $f0, $9e
	db $fc, $6f, $7d, $97, $9b, $6e, $6b, $9f, $89, $7b, $5c, $a5, $e2, $de, $ff, $a4
	db $5f, $f2, $9f, $f2, $ff, $63, $fc, $07, $f8, $ce, $79, $eb, $16, $f7, $fe, $4a
	db $f4, $9f, $f3, $9f, $ff, $8c, $7f, $c1, $3f, $e7, $3c, $af, $d0, $de, $1f, $f2
	db $7e, $ed, $7d, $d2, $b3, $ec, $ac, $f3, $23, $bc, $75, $4a, $8f, $f7, $9f, $64
	db $47, $bc, $bf, $48, $5f, $a8, $ff, $10, $7f, $a0, $ff, $c0, $08, $00, $07, $08
	db $ff, $f0, $03, $ff, $0c, $fb, $35, $ff, $0e, $ff, $01, $ff, $01, $ff, $0e, $fe
	db $71, $f1, $8e, $87, $79, $17, $7d, $92, $ba, $d0, $f7, $d8, $fd, $cc, $6f, $8f
	db $eb, $8f, $ed, $8b, $eb, $d1, $7d, $93, $ba, $17, $df, $37, $7f, $67, $ec, $e2
	db $af, $e3, $6e, $a3, $af, $bf, $58, $ff, $e0, $08, $00, $01, $e0, $ff, $1c, $1f
	db $e3, $c3, $3c, $08, $be, $09, $80, $ff, $60, $fc, $13, $f3, $1c, $fe, $0d, $ff
	db $03, $08, $00, $04, $6e, $93, $02, $ff, $de, $3f, $b9, $eb, $fc, $7d, $fc, $04
	db $fb, $0b, $ff, $1c, $6b, $e9, $14, $b7, $03, $1b, $40, $40, $f8, $b8, $7f, $c7
	db $7e, $62, $ff, $a3, $ac, $2f, $50, $db, $80, $b1, $05, $05, $3e, $3b, $fc, $c6
	db $fd, $8d, $ff, $8a, $ec, $93, $81, $fe, $f6, $f9, $3b, $af, $7f, $7c, $7f, $40
	db $bf, $a0, $ff, $70, $7f, $90, $9f, $70, $ff, $60, $ff, $80, $08, $be, $0b, $08
	db $ff, $f6, $28, $ff, $30, $08, $be, $08, $fc, $c4, $ff, $07, $fc, $04, $ff, $07
	db $f8, $0c, $ff, $0f, $08, $a8, $10, $7f, $46, $ff, $c0, $7f, $40, $ff, $c0, $3f
	db $60, $ff, $e0, $08, $b8, $10, $ff, $28, $ff, $18, $08, $78, $1f, $06, $08, $c5
	db $1f, $10, $f8, $0c, $fc, $07, $08, $26, $16, $ff, $00, $3f, $60, $7f, $c0, $08
	db $76, $1f, $08, $08, $79, $1d

;@ path: gfx/monsters/pictures
;@ Picture of Andreal (species $22): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and unpacked
;@ by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240 bytes
;@ unpacked, $1CC packed).
MonPic_Andreal::
	db $40, $02, $09, $ff, $09, $ff, $f2, $01, $09, $00
	db $03, $09, $ff, $f4, $c0, $bf, $b0, $cf, $6c, $e3, $5a, $f9, $85, $ef, $00, $c7
	db $10, $ef, $38, $ef, $6c, $93, $fe, $6d, $7c, $ff, $d6, $39, $bb, $09, $00, $03
	db $07, $fb, $1a, $e7, $6c, $8f, $b4, $3f, $42, $09, $08, $09, $40, $ff, $60, $09
	db $08, $0b, $09, $05, $02, $01, $fe, $02, $fe, $03, $fc, $05, $fd, $07, $f9, $0b
	db $82, $83, $f4, $ce, $44, $67, $64, $ec, $9b, $b3, $91, $f3, $19, $7d, $66, $f6
	db $82, $ff, $7c, $fe, $aa, $83, $d6, $92, $7d, $7d, $7d, $39, $45, $45, $ee, $aa
	db $83, $83, $5f, $e4, $47, $cc, $4f, $6c, $bf, $91, $1e, $93, $3e, $7e, $e9, $e9
	db $ff, $50, $ff, $70, $8f, $a8, $a7, $f4, $97, $fc, $73, $fa, $eb, $be, $7d, $75
	db $09, $50, $0c, $fb, $0f, $f5, $17, $ff, $1b, $fe, $1e, $e4, $2e, $e7, $3f, $e7
	db $3d, $e3, $3b, $92, $fb, $dc, $5f, $a9, $ac, $3b, $3c, $8f, $bc, $ff, $f4, $5b
	db $de, $43, $de, $ba, $93, $c6, $fc, $ff, $78, $cf, $70, $e7, $3a, $ff, $0c, $09
	db $00, $00, $47, $e7, $0c, $df, $cf, $3b, $f6, $0f, $e0, $1f, $e0, $06, $e8, $38
	db $ef, $3f, $1d, $1f, $48, $5e, $fc, $ff, $7c, $6f, $74, $7f, $44, $5f, $84, $bd
	db $02, $3b, $ff, $00, $ff, $80, $09, $12, $10, $7f, $40, $7f, $c0, $09, $1a, $10
	db $c4, $5d, $c4, $7f, $c4, $7f, $c5, $7f, $9f, $be, $bf, $a4, $ff, $c5, $fe, $c3
	db $45, $cf, $24, $a5, $18, $9f, $91, $9c, $f3, $74, $e3, $fc, $27, $70, $27, $b8
	db $ff, $18, $e7, $ff, $09, $08, $08, $e4, $4c, $e3, $9f, $e0, $1b, $f0, $0f, $f0
	db $0a, $f8, $07, $fa, $07, $fa, $03, $02, $7f, $02, $7f, $c2, $df, $3a, $ff, $17
	db $f7, $0a, $ba, $0a, $7b, $04, $ef, $3f, $a0, $3f, $f8, $27, $e4, $23, $f2, $93
	db $da, $53, $7a, $7b, $fe, $ff, $f6, $fc, $c5, $fc, $86, $fc, $87, $fc, $04, $fe
	db $02, $09, $06, $02, $2f, $e0, $27, $a8, $13, $1c, $08, $1f, $06, $0f, $81, $85
	db $fe, $7e, $fc, $04, $09, $08, $04, $3e, $c1, $80, $ff, $ff, $ff, $ff, $80, $fb
	db $02, $f5, $0e, $e7, $1c, $8b, $7c, $37, $f8, $d6, $d9, $e4, $e3, $e0, $23, $87
	db $3f, $87, $7c, $87, $6c, $0f, $f8, $0f, $b8, $1f, $f0, $7f, $e0, $ff, $80, $ff
	db $36, $ff, $12, $ff, $10, $09, $08, $09, $03, $ff, $04, $ff, $07, $09, $08, $04
	db $f8, $78, $b2, $fa, $ff, $cf, $ff, $78, $09, $08, $05, $80, $7f, $e0, $ff, $d0
	db $ff, $70, $09, $e0, $14, $e7, $27, $f3, $12, $f3, $16, $e1, $2d, $c0, $ce, $16
	db $77, $ff, $f9, $ff, $8f, $09, $0e, $06, $7f, $60, $ff, $90, $09, $06, $21, $09
	db $09, $09

;@ path: gfx/monsters/pictures
;@ Picture of KingCobra (species $23): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $F1 packed).
MonPic_KingCobra::
	db $40, $02, $05, $ff, $05, $ff, $ff, $4d, $05, $2b, $0f, $17, $03, $fc
	db $04, $f8, $1c, $05, $2a, $07, $80, $7f, $40, $3f, $70, $05, $2a, $0f, $22, $01
	db $ff, $01, $fe, $02, $fe, $03, $05, $da, $00, $e4, $7e, $ce, $bb, $f8, $1b, $6c
	db $3f, $4b, $4f, $6f, $5a, $47, $c6, $73, $ce, $4f, $fc, $e7, $ba, $3f, $b1, $6d
	db $f9, $a4, $e4, $ec, $b5, $c4, $c7, $9c, $e7, $05, $92, $06, $05, $08, $13, $05
	db $b5, $0f, $10, $05, $2a, $08, $e6, $25, $f7, $2d, $f6, $96, $9f, $90, $d0, $50
	db $f3, $3c, $f8, $18, $f8, $7f, $cf, $49, $df, $69, $df, $d2, $f3, $12, $17, $14
	db $9f, $78, $1f, $1f, $3c, $f0, $ff, $18, $ef, $28, $df, $50, $ff, $50, $ff, $a0
	db $bf, $e0, $3f, $e0, $7f, $c0, $05, $6a, $0f, $0f, $fd, $0e, $f4, $1f, $e3, $33
	db $e7, $20, $f6, $11, $fe, $0d, $ff, $03, $88, $88, $ef, $08, $78, $b8, $cf, $f8
	db $08, $e8, $1f, $d0, $11, $d0, $fe, $f0, $37, $39, $bf, $7f, $71, $6f, $c0, $7c
	db $c0, $78, $78, $78, $ff, $46, $7f, $41, $05, $0e, $11, $c0, $7f, $70, $2f, $28
	db $ff, $24, $4f, $f4, $87, $fc, $05, $2a, $0f, $1d, $e0, $3f, $e0, $20, $e0, $3f
	db $f0, $10, $fc, $0f, $ff, $03, $05, $2a, $00, $7e, $fe, $4c, $70, $27, $f8, $1f
	db $38, $0f, $df, $f7, $f0, $05, $2a, $00, $0f, $38, $1f, $10, $3f, $20, $ff, $05
	db $6f, $1f, $06

;@ path: gfx/monsters/pictures
;@ Picture of Spikerous (species $24): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $140 packed).
MonPic_Spikerous::
	db $40, $02, $08, $ff, $08, $ff, $ff, $4d, $08, $1d, $0f, $09, $0c
	db $fb, $0b, $08, $1c, $03, $01, $ff, $11, $ff, $32, $ff, $5d, $f7, $57, $08, $1c
	db $01, $80, $7f, $c0, $ff, $c0, $bf, $e0, $3f, $64, $1f, $3e, $08, $1c, $05, $01
	db $ff, $01, $ff, $19, $f6, $7f, $08, $1c, $05, $80, $7f, $fe, $ef, $bc, $3f, $f0
	db $08, $1c, $09, $01, $ff, $00, $fc, $05, $fe, $02, $fe, $1a, $f4, $16, $f8, $0c
	db $f8, $f8, $04, $fc, $85, $85, $fd, $fb, $d9, $b7, $d8, $b7, $71, $5f, $52, $7f
	db $40, $6b, $80, $fe, $00, $5b, $3f, $32, $6f, $5f, $ca, $bb, $90, $72, $1f, $ff
	db $7b, $e6, $e3, $9f, $1c, $fc, $ad, $fb, $32, $bf, $7d, $7f, $63, $5f, $a3, $fe
	db $fb, $7e, $ff, $fe, $87, $fc, $6f, $f8, $ff, $98, $ff, $80, $08, $1c, $0f, $06
	db $01, $c1, $41, $f8, $38, $e1, $21, $ff, $3f, $d6, $79, $e9, $2f, $fe, $7e, $a2
	db $e3, $98, $bb, $b8, $ef, $73, $77, $07, $cf, $06, $ff, $1a, $fb, $69, $f9, $cd
	db $fd, $38, $f8, $68, $d8, $74, $cc, $fc, $8c, $fa, $1e, $e2, $3e, $e6, $7e, $aa
	db $7a, $8f, $8c, $1f, $18, $6f, $78, $0f, $1c, $eb, $ea, $2f, $ac, $cf, $c8, $1f
	db $18, $08, $1c, $0f, $0d, $f3, $73, $f3, $53, $ed, $9f, $f9, $f9, $cd, $bd, $c2
	db $be, $fe, $fe, $e1, $59, $3d, $3d, $07, $06, $85, $86, $e3, $e3, $5f, $5f, $f3
	db $f3, $bf, $ef, $ff, $e0, $f1, $71, $c3, $43, $86, $86, $1e, $1e, $ef, $ef, $3a
	db $3e, $ff, $cf, $ff, $01, $3f, $34, $2f, $32, $bf, $be, $e7, $fa, $87, $fa, $ff
	db $fe, $0f, $34, $8f, $fc, $08, $1c, $0f, $0d, $e3, $7f, $fd, $7d, $c1, $41, $ff
	db $bf, $ff, $aa, $ff, $54, $08, $b2, $04, $ff, $40, $ff, $c0, $08, $1c, $05, $03
	db $ff, $05, $ff, $07, $08, $1c, $06, $7f, $7c, $07, $04, $ff, $fa, $08, $f8, $17
	db $08, $1d, $0b

;@ path: gfx/monsters/pictures
;@ Picture of GreatDrak (species $25): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $217 packed).
MonPic_GreatDrak::
	db $40, $02, $06, $ff, $06, $ff, $f4, $01, $06, $08, $03, $30, $ff
	db $50, $ff, $a1, $ff, $a1, $7f, $e1, $ff, $2f, $ff, $2a, $ff, $25, $ff, $74, $df
	db $6e, $ef, $b5, $ff, $52, $f7, $79, $ff, $89, $fb, $1e, $ef, $fc, $ff, $0a, $ff
	db $15, $ff, $15, $ff, $a5, $ff, $c6, $ff, $86, $f7, $cc, $ef, $b8, $ff, $0c, $ff
	db $0a, $ff, $05, $ff, $05, $fe, $07, $ff, $04, $ff, $04, $ff, $05, $06, $00, $05
	db $80, $06, $58, $01, $40, $ff, $02, $ff, $02, $06, $44, $00, $ff, $05, $ff, $0a
	db $06, $6a, $01, $b9, $ff, $98, $7f, $d1, $7f, $d3, $7f, $e7, $bd, $e7, $bb, $ed
	db $bb, $ec, $ff, $10, $bf, $d0, $7f, $e0, $ff, $8c, $ff, $12, $ff, $26, $ef, $35
	db $ff, $97, $ff, $18, $ff, $5c, $fb, $8e, $fb, $ce, $ff, $e6, $ff, $56, $ff, $3c
	db $f7, $0c, $06, $64, $03, $05, $ff, $09, $fe, $0b, $fe, $0b, $fe, $13, $ff, $a0
	db $ff, $a0, $ff, $50, $ff, $50, $ff, $a8, $06, $b8, $03, $06, $6b, $02, $0a, $ff
	db $0b, $fe, $17, $ff, $16, $ff, $16, $bf, $ef, $bb, $ec, $f7, $d8, $f6, $d9, $7f
	db $9f, $f7, $38, $f7, $19, $ff, $1a, $f7, $f8, $db, $3c, $ed, $1e, $ff, $ff, $7c
	db $87, $ff, $84, $ff, $5c, $ff, $25, $fb, $86, $fb, $8e, $fb, $47, $67, $be, $fd
	db $fb, $fc, $13, $ec, $9b, $fe, $09, $fc, $27, $f8, $cf, $e8, $1f, $d1, $3f, $25
	db $ff, $a5, $ff, $c5, $ff, $49, $ff, $ff, $b4, $06, $10, $10, $df, $74, $06, $16
	db $10, $cf, $7a, $cf, $7a, $ff, $16, $fd, $17, $06, $22, $10, $fc, $17, $fc, $17
	db $fd, $06, $cb, $00, $26, $ff, $03, $ff, $01, $ef, $f8, $ff, $fb, $ef, $bd, $e7
	db $3e, $f1, $3f, $ff, $a5, $ff, $55, $ff, $4e, $ff, $d4, $3f, $ed, $3f, $ea, $bf
	db $f2, $ff, $f7, $f6, $0d, $f6, $0d, $f6, $ed, $e6, $5d, $c8, $7f, $f7, $be, $ff
	db $98, $ff, $d0, $49, $ff, $59, $ff, $59, $ff, $79, $ef, $fd, $e7, $bd, $67, $df
	db $33, $cf, $3b, $cf, $7a, $8f, $fa, $06, $72, $12, $0f, $fa, $4f, $fa, $ef, $ba
	db $ff, $1a, $ff, $1c, $ff, $2c, $ff, $2c, $ff, $4c, $ff, $54, $ff, $92, $ff, $a1
	db $fb, $1c, $f5, $1e, $fb, $0f, $e5, $1e, $c2, $3f, $c1, $3f, $e2, $1f, $0c, $ff
	db $ee, $1b, $f7, $0d, $7b, $87, $fd, $fe, $fe, $01, $01, $ff, $fe, $ff, $20, $ff
	db $ff, $a0, $ff, $60, $ff, $c0, $7f, $c0, $7f, $c0, $06, $b4, $10, $3f, $e0, $ef
	db $1d, $e7, $1f, $e7, $1c, $c7, $3f, $c5, $3f, $c7, $3f, $8f, $79, $8b, $7c, $ef
	db $3a, $ff, $da, $bf, $fa, $df, $74, $ff, $f4, $5f, $f6, $db, $fe, $fb, $2e, $06
	db $b0, $01, $a7, $ff, $5c, $ff, $57, $ff, $2e, $ff, $1b, $ff, $0e, $c0, $ff, $fc
	db $3f, $ff, $c8, $fb, $36, $f7, $cf, $df, $3d, $ff, $fe, $ff, $00, $30, $ff, $3f
	db $ef, $7e, $c7, $ff, $81, $ff, $80, $06, $00, $02, $7f, $f0, $8c, $ff, $1b, $ff
	db $e1, $ff, $cf, $7e, $ff, $30, $ff, $5f, $ff, $70, $18, $f7, $2c, $ff, $f3, $ff
	db $8c, $7f, $e7, $1f, $ff, $99, $ff, $e7, $ff, $3c, $f3, $3e, $27, $fe, $0b, $fe
	db $f7, $fc, $5f, $f8, $ff, $e0, $ff, $40, $ff, $c0

;@ path: gfx/monsters/pictures
;@ Picture of Crestpent (species $26): 36 tiles, 6 x 6 (48 x 48 pixels). Found through MonsterPicRefs and
;@ unpacked by LoadMonsterPicture and the other picture loaders. Compressed in the DecompressCore format ($240
;@ bytes unpacked, $178 packed).
MonPic_Crestpent::
	db $40, $02, $09, $ff, $09, $ff
	db $ff, $0b, $01, $09, $00, $0b, $80, $09, $00, $0b, $c0, $09, $00, $0f, $0c, $09
	db $ff, $f8, $03, $fe, $02, $ff, $01, $fe, $02, $fe, $02, $fc, $04, $fc, $04, $f8
	db $08, $f8, $88, $78, $68, $18, $18, $ff, $83, $fc, $84, $f8, $88, $f0, $90, $e1
	db $a1, $41, $41, $81, $81, $8e, $8e, $7f, $40, $ff, $80, $09, $92, $01, $09, $ff
	db $f0, $f8, $07, $06, $09, $12, $0a, $fe, $02, $09, $00, $03, $0c, $f7, $3c, $cf
	db $78, $9f, $f0, $bf, $60, $09, $00, $08, $fc, $00, $f1, $00, $9f, $9f, $e0, $7c
	db $e2, $27, $fa, $43, $d8, $74, $fe, $3e, $32, $32, $82, $02, $30, $30, $c0, $c0
	db $00, $80, $01, $81, $c3, $c2, $3f, $fc, $c3, $fb, $c0, $06, $03, $03, $1f, $1c
	db $7f, $60, $09, $2e, $03, $80, $7f, $f0, $fd, $04, $fe, $05, $f8, $0b, $f9, $0f
	db $f9, $0f, $f1, $17, $f1, $1d, $f0, $1c, $7f, $c0, $09, $94, $05, $09, $2b, $01
	db $eb, $09, $ff, $fb, $fa, $3a, $fd, $3c, $fd, $28, $f3, $11, $ff, $0e, $ff, $0f
	db $f4, $3e, $c8, $7f, $c8, $61, $fa, $f8, $ff, $87, $ff, $00, $ff, $fe, $77, $8f
	db $19, $ff, $26, $bf, $0f, $dc, $07, $1a, $a3, $05, $c9, $c3, $f0, $2b, $f0, $f1
	db $98, $f5, $34, $f1, $f1, $18, $f0, $1c, $f1, $14, $f0, $3c, $f1, $bc, $d0, $f8
	db $e1, $fc, $b1, $f9, $09, $92, $03, $09, $71, $14, $09, $1b, $02, $09, $6f, $01
	db $fe, $02, $ff, $02, $ff, $01, $90, $fb, $10, $fe, $55, $bc, $53, $be, $49, $bf
	db $24, $df, $03, $7f, $80, $37, $44, $7f, $c3, $6f, $80, $ff, $80, $f6, $80, $ff
	db $7f, $ff, $1c, $e3, $ff, $ff, $70, $d9, $ad, $e3, $21, $f1, $5a, $c7, $ac, $cf
	db $f1, $ff, $06, $ff, $f9, $fe, $ab, $f9, $25, $fd, $47, $fe, $43, $fa, $a3, $ca
	db $43, $ba, $87, $72, $0f, $e4, $09, $0e, $0f, $0d, $00, $9d, $a0, $87, $c8, $60
	db $f2, $38, $ff, $0f, $09, $ea, $13, $ff, $00, $db, $00, $7e, $80, $00, $5d, $80
	db $ff, $ff, $09, $00, $00, $04, $fb, $00, $7f, $00, $f0, $0a, $00, $d7, $0f, $ff
	db $f8, $09, $00, $00, $07, $cc, $2f, $08, $9f, $30, $7f, $e0, $09, $2e, $0d, $09
	db $e9, $13

;@ path: unused/filler
;@ Unused filler up to the end of the bank.
Unused_2F::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
