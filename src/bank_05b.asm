INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $05b", ROMX[$4000], BANK[$5b]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_5B::
	db $5b

;@ path: gfx/banks
;@ Entries of graphics bank $5B (battle, cutscene and title graphics): one pointer per compressed block. Decompress and
;@ DecompressVRAM take a block as bank and entry number (d = $5B, e = entry); the far_
;@ constants in far.inc carry the same pair.
FarTable_5B::
	dw BattleFrameGfx
	dw BattleSymbolGfx
	dw StatusIconGfx0
	dw StatusIconGfx1
	dw StatusIconGfx2
	dw StatusIconGfx3
	dw StatusIconGfx4
	dw StatusIconGfx5
	dw StatusIconGfx6
	dw StatusIconGfx7
	dw SkillAnimSprites20
	dw SkillAnimSprites21
	dw SkillAnimSprites22
	dw SkillAnimSprites23
	dw SkillAnimSprites24
	dw SkillAnimSprites25
	dw SkillAnimSprites26
	dw SkillAnimSprites27
	dw SkillAnimSprites28
	dw SkillAnimSprites29
	dw SkillAnimSprites2A
	dw SkillAnimSprites2B
	dw SkillAnimSprites2C
	dw Cutscene0Tiles
	dw ShootingStarSprites
	dw SparkleSprites
	dw Cutscene0ExtraTiles
	dw Cutscene12Tiles
	dw Cutscene12TilesHigh
	dw Cutscene3Tiles
	dw Cutscene3TilesHigh
	dw OpeningLogo2Tiles
	dw TitlePictureTiles
	dw TitlePictureTilesHigh

;@ path: battle/screen
;@ Battle screen tiles: window frame pieces and symbols, unpacked to $9600 (tiles $60-$7F) when a battle starts and after the recruit screens (bank $51). The last tiles still hold Japanese command words of the original release.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 512 bytes = 32 tiles, 2 bits per pixel.
BattleFrameGfx::
	db $00, $02, $01
	db $01, $a0, $ff, $4d, $01, $5f, $0f, $4d, $ff, $00, $ff, $20, $ff, $1e, $ff, $f8
	db $ff, $04, $ff, $0c, $ff, $40, $ff, $3c, $ff, $00, $ff, $08, $ff, $30, $ff, $60
	db $ff, $c0, $ff, $20, $ff, $10, $ff, $08, $01, $d0, $01, $4a, $ff, $fc, $ff, $48
	db $ff, $48, $ff, $42, $01, $ce, $01, $10, $ff, $10, $ff, $20, $ff, $30, $ff, $68
	db $ff, $4a, $ff, $8c, $01, $60, $0f, $4d, $01, $5f, $1f, $4d, $ff, $05, $ff, $45
	db $ff, $44, $ff, $38, $ff, $60, $ff, $80, $ff, $82, $ff, $7c, $ff, $00, $ff, $38
	db $ff, $00, $ff, $3c, $ff, $42, $ff, $02, $ff, $04, $ff, $38, $ff, $05, $ff, $0d
	db $01, $d4, $0b, $40, $ff, $8e, $ff, $90, $ff, $80, $ff, $80, $ff, $d0, $ff, $4e

;@ path: battle/screen
;@ More battle screen tiles, unpacked to $8800 (tiles $80-$8F) together with BattleFrameGfx.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 256 bytes = 16 tiles, 2 bits per pixel.
BattleSymbolGfx::
	db $00, $01, $01
	db $ff, $05, $ff, $15, $ff, $90, $ff, $bc, $ff, $88, $01, $08, $01, $50, $ff, $00
	db $ff, $7c, $ff, $08, $ff, $3c, $ff, $42, $ff, $9a, $ff, $24, $ff, $18, $01, $a0
	db $ff, $4d, $01, $7f, $0f, $4d, $01, $df, $0f, $0d

;@ path: battle/panel
;@ Status icon 0 (see StatusFaceGfx: 0 healthy, 1-6 an ailment, 7 out of action), one tile loaded by LoadStatusIcon after a monster's name on the party panel. The battle code also loads it to blank a slot.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 16 bytes = 1 tiles, 2 bits per pixel.
StatusIconGfx0::
	db $10, $00, $01
	db $ff, $01, $ff, $fb

;@ path: battle/panel
;@ Status icon 1 (see StatusFaceGfx: 0 healthy, 1-6 an ailment, 7 out of action), one tile loaded by LoadStatusIcon after a monster's name on the party panel.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 16 bytes = 1 tiles, 2 bits per pixel.
StatusIconGfx1::
	db $10, $00, $01
	db $ff, $00, $ff, $3e, $ff, $7f, $ff, $49, $ff, $49, $ff, $77, $ff, $3e, $ff, $2a

;@ path: battle/panel
;@ Status icon 2 (see StatusFaceGfx: 0 healthy, 1-6 an ailment, 7 out of action), one tile loaded by LoadStatusIcon after a monster's name on the party panel.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 16 bytes = 1 tiles, 2 bits per pixel.
StatusIconGfx2::
	db $10, $00, $00
	db $ff, $60, $ff, $90, $ff, $90, $ff, $64, $ff, $0a, $ff, $24, $ff, $50, $ff, $20

;@ path: battle/panel
;@ Status icon 3 (see StatusFaceGfx: 0 healthy, 1-6 an ailment, 7 out of action), one tile loaded by LoadStatusIcon after a monster's name on the party panel.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 16 bytes = 1 tiles, 2 bits per pixel.
StatusIconGfx3::
	db $10, $00, $00
	db $ff, $f0, $ff, $20, $ff, $40, $ff, $f0, $ff, $0f, $ff, $02, $ff, $04, $ff, $0f

;@ path: battle/panel
;@ Status icon 4 (see StatusFaceGfx: 0 healthy, 1-6 an ailment, 7 out of action), one tile loaded by LoadStatusIcon after a monster's name on the party panel.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 16 bytes = 1 tiles, 2 bits per pixel.
StatusIconGfx4::
	db $10, $00, $01
	db $ff, $00, $ff, $3c, $ff, $66, $ff, $66, $ff, $0c, $ff, $18, $ff, $00, $ff, $18

;@ path: battle/panel
;@ Status icon 5 (see StatusFaceGfx: 0 healthy, 1-6 an ailment, 7 out of action), one tile loaded by LoadStatusIcon after a monster's name on the party panel.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 16 bytes = 1 tiles, 2 bits per pixel.
StatusIconGfx5::
	db $10, $00, $01
	db $ff, $00, $ff, $1c, $ff, $22, $ff, $5d, $01, $06, $01, $22, $ff, $1c

;@ path: battle/panel
;@ Status icon 6 (see StatusFaceGfx: 0 healthy, 1-6 an ailment, 7 out of action), one tile loaded by LoadStatusIcon after a monster's name on the party panel.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 16 bytes = 1 tiles, 2 bits per pixel.
StatusIconGfx6::
	db $10, $00, $01
	db $ff, $00, $ff, $42, $ff, $18, $ff, $24, $ff, $24, $ff, $18, $ff, $42, $ff, $00

;@ path: battle/panel
;@ Status icon 7 (see StatusFaceGfx: 0 healthy, 1-6 an ailment, 7 out of action), one tile loaded by LoadStatusIcon after a monster's name on the party panel.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 16 bytes = 1 tiles, 2 bits per pixel.
StatusIconGfx7::
	db $10, $00, $01
	db $ff, $00, $ff, $1c, $ff, $36, $ff, $63, $ff, $77, $ff, $36, $ff, $3e, $ff, $3e

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $20 (SkillAnimGfx entry $20), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites20::
	db $00, $08, $0b
	db $0b, $ff, $f1, $0f, $00, $38, $00, $e0, $00, $f0, $00, $7e, $0b, $ff, $f1, $fe
	db $00, $87, $00, $07, $00, $0c, $00, $10, $0b, $fc, $f5, $0e, $0b, $06, $01, $ff
	db $00, $7f, $0b, $fe, $f3, $01, $00, $07, $00, $3c, $00, $f0, $0b, $fc, $f5, $01
	db $01, $0e, $0e, $31, $30, $4e, $40, $b0, $c0, $30, $00, $03, $03, $7c, $7c, $83
	db $c0, $3c, $00, $c0, $0b, $fe, $f3, $fc, $fc, $02, $06, $f9, $06, $09, $08, $16
	db $00, $38, $0b, $58, $01, $01, $00, $01, $0b, $f9, $f8, $f0, $0f, $00, $fc, $0b
	db $f2, $ff, $00, $03, $00, $0c, $0b, $3e, $05, $1e, $00, $ff, $0b, $58, $02, $01
	db $06, $04, $1b, $0b, $60, $00, $0e, $f1, $0e, $11, $1c, $22, $30, $cc, $80, $70
	db $00, $80, $00, $00, $00, $07, $00, $1c, $10, $28, $20, $50, $70, $8f, $7f, $80
	db $00, $7f, $0b, $58, $05, $01, $00, $ff, $e0, $1c, $00, $e0, $0b, $fe, $f3, $18
	db $0b, $de, $05, $0b, $fb, $f6, $01, $01, $06, $07, $18, $0b, $fe, $f4, $0f, $70
	db $7c, $83, $0b, $dc, $03, $0f, $0f, $f0, $fc, $03, $0b, $56, $07, $f8, $f8, $06
	db $1e, $e1, $0e, $11, $1c, $02, $10, $2c, $00, $70, $1c, $23, $30, $4c, $70, $8c
	db $7c, $83, $1f, $60, $00, $1f, $0b, $f8, $f9, $f8, $0b, $58, $03, $0c, $00, $30
	db $0b, $f2, $ff, $00, $07, $00, $3f, $0b, $3a, $05, $07, $07, $78, $60, $9f, $0b
	db $de, $01, $01, $01, $06, $0b, $20, $14, $1e, $21, $3c, $42, $70, $8c, $c0, $0b
	db $53, $12, $0b, $35, $00, $3e, $0b, $de, $02, $07, $18, $18, $67, $40, $b8, $0b
	db $58, $05, $0b, $59, $1b, $04, $1a, $18, $24, $30, $4c, $7c, $83, $7f, $80, $0b
	db $38, $17, $07, $07, $f8, $fe, $01, $e0, $1e, $0b, $e8, $09, $01, $01, $1e, $18
	db $e7, $c0, $0b, $6b, $00, $01, $00, $02, $00, $1c, $00, $f0, $0b, $58, $04, $3c
	db $43, $3f, $40, $3c, $43, $38, $44, $70, $88, $40, $b0, $00, $c0, $00, $80, $0b
	db $0c, $21, $0b, $8b, $0a, $22, $00, $26, $00, $27, $01, $26, $03, $2c, $02, $6d
	db $26, $59, $00, $22, $00, $44, $00, $d8, $00, $b0, $00, $e0, $00, $c4, $00, $98
	db $0b, $3a, $03, $02, $00, $06, $00, $06, $00, $0d, $01, $1a, $02, $15, $00, $01
	db $00, $03, $00, $06, $04, $2a, $08, $d4, $88, $54, $10, $aa, $20, $56, $00, $03
	db $00, $02, $00, $05, $00, $05, $01, $0a, $02, $15, $02, $15, $04, $0a, $22, $55
	db $44, $aa, $88, $55, $88, $55, $11, $aa, $22, $55, $0b, $70, $20, $20, $56, $40
	db $ac, $80, $48, $80, $58, $00, $b0, $00, $20, $00, $60, $0b, $ee, $11, $01, $01
	db $02, $02, $05, $02, $05, $04, $0a, $00, $0d, $08, $15, $0b, $74, $28, $88, $54
	db $88, $54, $80, $58, $80, $50, $00, $a0, $00, $40, $0b, $3d, $05, $1a, $02, $15
	db $02, $35, $04, $2a, $08, $55, $08, $15, $10, $2a, $20, $54, $10, $a8, $20, $50
	db $0b, $8c, $21, $0b, $13, $23, $0b, $98, $20, $04, $0a, $08, $14, $10, $28, $0b
	db $c6, $00, $40, $a0, $00, $02, $00, $04, $00, $04, $00, $08, $00, $10, $00, $10
	db $00, $20, $0b, $b6, $26, $0b, $07, $3f, $4d, $0b, $67, $3f, $4d, $0b, $c7, $3f
	db $4d, $0b, $27, $4f, $4d, $0b, $87, $4f, $4d, $0b, $e7, $4f, $4d, $0b, $47, $5f
	db $4d, $0b, $a7, $5f, $4d, $0b, $07, $6f, $4d, $0b, $67, $6f, $4d, $0b, $c7, $6f
	db $4d, $0b, $27, $7f, $4d, $0b, $87, $7f, $4d, $0b, $e7, $7f, $05

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $21 (SkillAnimGfx entry $21), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites21::
	db $00, $08, $0a
	db $0a, $ff, $f5, $20, $00, $60, $20, $50, $20, $d0, $00, $00, $00, $01, $00, $01
	db $00, $03, $01, $02, $01, $06, $02, $04, $03, $0c, $70, $88, $70, $88, $f8, $04
	db $b8, $04, $1c, $02, $8c, $02, $c4, $02, $62, $01, $0a, $ff, $f1, $80, $00, $c0
	db $40, $a0, $40, $90, $40, $88, $40, $86, $04, $08, $04, $18, $08, $10, $08, $30
	db $1c, $20, $1e, $60, $3f, $40, $3f, $c0, $b2, $01, $59, $00, $2d, $00, $16, $01
	db $08, $03, $05, $02, $09, $06, $8b, $04, $0a, $32, $01, $80, $00, $c0, $80, $40
	db $80, $40, $80, $42, $80, $42, $04, $08, $04, $08, $06, $0a, $73, $03, $02, $0c
	db $01, $0e, $20, $10, $10, $09, $08, $05, $0c, $03, $1c, $03, $3c, $03, $3c, $03
	db $7e, $01, $7f, $80, $7f, $80, $ff, $00, $ff, $00, $3f, $c0, $1f, $e0, $27, $d8
	db $3b, $c4, $c3, $0c, $e7, $08, $e7, $18, $e6, $19, $ce, $31, $cc, $33, $8d, $62
	db $89, $66, $80, $46, $04, $ca, $0c, $d2, $1c, $e2, $bc, $42, $be, $41, $be, $41
	db $3c, $c3, $0a, $14, $00, $00, $0e, $04, $1a, $0c, $32, $1c, $62, $38, $c4, $78
	db $84, $00, $0f, $00, $07, $00, $07, $00, $03, $00, $0f, $00, $0f, $04, $0b, $07
	db $08, $7a, $05, $78, $87, $1b, $e4, $03, $fc, $73, $8c, $0b, $f4, $42, $bc, $70
	db $8e, $1c, $e3, $0e, $f1, $0e, $f1, $86, $39, $02, $1d, $08, $07, $18, $07, $14
	db $0b, $8a, $45, $02, $cd, $04, $8b, $05, $9a, $09, $96, $0b, $b4, $12, $ed, $96
	db $69, $18, $e7, $90, $6d, $80, $79, $80, $71, $01, $e2, $01, $e2, $11, $e2, $19
	db $e2, $78, $84, $f8, $04, $f0, $08, $0a, $24, $12, $e0, $10, $e0, $10, $03, $04
	db $01, $46, $00, $3f, $1a, $25, $0d, $12, $06, $09, $02, $05, $00, $03, $7c, $83
	db $b8, $47, $b6, $49, $13, $ec, $c9, $36, $e8, $17, $2c, $d3, $04, $fb, $34, $0b
	db $2e, $91, $2e, $d1, $1e, $e1, $0f, $f0, $8f, $70, $87, $78, $43, $bc, $04, $fb
	db $78, $87, $fc, $03, $3d, $c2, $59, $a6, $44, $bb, $38, $c7, $30, $cf, $18, $e7
	db $93, $6c, $87, $78, $80, $7f, $3f, $c0, $00, $ff, $fc, $03, $00, $ff, $00, $f2
	db $c0, $3e, $88, $74, $10, $e8, $30, $c8, $60, $90, $c0, $20, $80, $40, $0a, $ff
	db $f5, $3c, $1c, $23, $0e, $31, $06, $19, $10, $28, $18, $24, $0a, $a2, $10, $2c
	db $52, $5c, $a2, $0c, $f2, $34, $cb, $0a, $ff, $f3, $10, $10, $28, $10, $68, $58
	db $a4, $d8, $24, $03, $0c, $03, $04, $01, $0e, $04, $0b, $0c, $13, $06, $19, $12
	db $2d, $00, $3f, $38, $c7, $19, $e6, $91, $6e, $93, $6c, $56, $a9, $05, $fa, $31
	db $ce, $96, $69, $d8, $24, $90, $6e, $8c, $72, $1c, $e2, $38, $c4, $b0, $48, $80
	db $7c, $a4, $5a, $0a, $fc, $f9, $c1, $41, $a2, $3c, $43, $3f, $40, $3c, $43, $38
	db $44, $70, $88, $40, $b0, $00, $c0, $0a, $34, $00, $00, $80, $0a, $fc, $f9, $03
	db $00, $22, $00, $26, $00, $27, $01, $26, $03, $2c, $02, $6d, $26, $59, $00, $22
	db $00, $44, $00, $d8, $00, $b0, $00, $e0, $00, $c4, $00, $98, $00, $f0, $00, $02
	db $00, $03, $01, $22, $01, $3a, $18, $27, $0d, $12, $0c, $13, $02, $3d, $00, $10
	db $00, $20, $00, $e0, $40, $bc, $90, $68, $a0, $50, $00, $f0, $f0, $0c, $03, $0c
	db $0f, $10, $1f, $20, $00, $ff, $0e, $11, $1c, $23, $30, $4f, $6d, $92, $cc, $33
	db $b0, $4e, $38, $c4, $38, $c4, $98, $64, $88, $74, $80, $4c, $80, $44, $04, $1b
	db $11, $2e, $03, $74, $06, $89, $0e, $11, $18, $27, $36, $49, $4d, $b2, $6c, $92
	db $6c, $92, $0a, $bc, $10, $d8, $24, $88, $54, $80, $58, $00, $88, $01, $3e, $03
	db $6c, $03, $8c, $02, $1d, $08, $16, $08, $36, $10, $6c, $10, $68, $a0, $51, $20
	db $d0, $00, $a0, $0a, $08, $00, $00, $60, $00, $40, $00, $40, $02, $0d, $04, $0b
	db $04, $1a, $08, $14, $00, $38, $00, $38, $00, $70, $00, $60, $00, $0c, $00, $08
	db $00, $18, $0a, $50, $21, $40, $00, $40, $00, $80, $02, $6d, $24, $5a, $34, $4a
	db $30, $4c, $10, $a8, $20, $d8, $60, $90, $40, $a0, $00, $02, $00, $04, $00, $04
	db $00, $08, $00, $10, $0a, $d6, $23, $0a, $00, $3f, $4d, $0a, $60, $3f, $4d, $0a
	db $c0, $3f, $4d, $0a, $20, $4f, $4d, $0a, $80, $4f, $4d, $0a, $e0, $4f, $4d, $0a
	db $40, $5f, $4d, $0a, $a0, $5f, $4d, $0a, $00, $6f, $4d, $0a, $60, $6f, $4d, $0a
	db $c0, $6f, $4d, $0a, $20, $7f, $4d, $0a, $80, $7f, $4d, $0a, $e0, $7f, $0c

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $22 (SkillAnimGfx entry $22), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites22::
	db $00, $08, $02
	db $00, $80, $00, $80, $00, $c0, $00, $c0, $00, $c1, $00, $d1, $00, $d1, $00, $d5
	db $00, $00, $00, $01, $00, $01, $00, $13, $02, $16, $01, $53, $20, $57, $20, $d5
	db $28, $02, $21, $05, $2a, $d5, $2a, $d5, $20, $57, $02, $30, $00, $a0, $57, $a0
	db $57, $a8, $02, $39, $01, $02, $2c, $00, $4a, $b5, $49, $b6, $67, $98, $7f, $80
	db $0f, $70, $00, $0f, $aa, $55, $aa, $55, $2a, $d5, $a6, $59, $ce, $31, $fe, $01
	db $f8, $06, $00, $f8, $02, $f4, $f9, $40, $00, $41, $00, $f7, $34, $ca, $06, $39
	db $00, $07, $00, $01, $00, $07, $00, $3c, $00, $e0, $00, $20, $00, $c0, $00, $80
	db $00, $60, $00, $c0, $02, $f6, $f9, $90, $00, $92, $00, $b2, $20, $d4, $b4, $4b
	db $02, $62, $09, $80, $00, $90, $fc, $03, $3f, $c0, $07, $38, $01, $06, $00, $09
	db $00, $17, $00, $bc, $00, $e0, $80, $60, $00, $c0, $c0, $3c, $80, $70, $02, $88
	db $05, $02, $01, $00, $88, $00, $88, $00, $89, $00, $99, $80, $52, $80, $52, $02
	db $f4, $f9, $08, $00, $11, $80, $52, $80, $76, $a0, $54, $a0, $5d, $e9, $16, $fa
	db $05, $7e, $81, $5d, $a2, $00, $22, $00, $64, $00, $c8, $80, $10, $00, $b1, $00
	db $67, $00, $cc, $00, $b8, $02, $a4, $07, $02, $fd, $f0, $60, $57, $a8, $0a, $f5
	db $01, $3e, $04, $8b, $0a, $b5, $bc, $43, $e0, $1c, $00, $e0, $20, $d3, $c0, $3e
	db $a0, $58, $c0, $02, $81, $00, $02, $fb, $f4, $02, $f3, $fa, $43, $03, $3c, $0e
	db $11, $09, $76, $07, $38, $00, $0f, $00, $03, $00, $00, $2a, $d5, $6a, $95, $da
	db $25, $96, $69, $35, $ca, $ed, $12, $19, $e6, $00, $7f, $00, $01, $00, $05, $00
	db $05, $08, $05, $08, $15, $08, $55, $2a, $55, $2a, $02, $0f, $00, $02, $82, $1f
	db $4d, $02, $e2, $1f, $4d, $02, $42, $2f, $4d, $02, $a2, $2f, $4d, $02, $02, $3f
	db $4d, $02, $62, $3f, $4d, $02, $c2, $3f, $4d, $02, $22, $4f, $4d, $02, $82, $4f
	db $4d, $02, $e2, $4f, $4d, $02, $42, $5f, $4d, $02, $a2, $5f, $4d, $02, $02, $6f
	db $4d, $02, $62, $6f, $4d, $02, $c2, $6f, $4d, $02, $22, $7f, $4d, $02, $82, $7f
	db $4d, $02, $e2, $7f, $0a

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $23 (SkillAnimGfx entry $23), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites23::
	db $00, $08, $05
	db $00, $00, $00, $03, $01, $06, $06, $09, $0f, $30, $3f, $40, $07, $f8, $00, $07
	db $00, $98, $00, $70, $00, $c7, $00, $fc, $e0, $10, $00, $ff, $80, $40, $00, $f0
	db $05, $fa, $f5, $3c, $00, $07, $00, $01, $05, $f6, $f9, $80, $00, $e0, $40, $b0
	db $30, $48, $30, $4c, $18, $24, $18, $26, $1c, $22, $05, $48, $00, $3c, $42, $05
	db $fa, $f5, $01, $00, $01, $01, $02, $01, $02, $38, $46, $38, $44, $78, $84, $70
	db $8c, $f0, $08, $e0, $18, $e0, $10, $e0, $10, $05, $52, $04, $01, $02, $03, $04
	db $07, $08, $0e, $11, $38, $46, $05, $64, $00, $e0, $18, $c0, $30, $80, $60, $00
	db $c0, $00, $80, $05, $72, $06, $04, $1b, $10, $2e, $00, $78, $1c, $63, $70, $8e
	db $e0, $18, $80, $70, $05, $8c, $05, $05, $ff, $f1, $00, $3c, $05, $fa, $f5, $1e
	db $00, $70, $05, $aa, $07, $05, $55, $03, $05, $5a, $02, $05, $78, $00, $78, $86
	db $f8, $04, $f8, $04, $f0, $0c, $05, $68, $04, $07, $18, $03, $04, $01, $02, $05
	db $d2, $01, $05, $fe, $f1, $f0, $08, $f0, $0c, $f8, $04, $f8, $06, $fc, $02, $7c
	db $82, $05, $0a, $10, $05, $f8, $f9, $1e, $00, $ff, $05, $fa, $f5, $0f, $07, $f8
	db $ff, $00, $01, $fe, $05, $fa, $f5, $c0, $80, $78, $f0, $0e, $fc, $03, $05, $54
	db $03, $02, $00, $0c, $00, $10, $00, $60, $00, $80, $00, $1f, $00, $05, $a7, $00
	db $05, $f9, $f6, $04, $00, $08, $05, $ec, $ff, $06, $1e, $0e, $f1, $05, $20, $1a
	db $05, $1e, $17, $05, $39, $18, $05, $b1, $02, $07, $00, $1c, $00, $30, $00, $07
	db $06, $19, $10, $6e, $40, $b0, $05, $54, $14, $e0, $1e, $00, $e0, $05, $c7, $09
	db $0e, $05, $2c, $0a, $e0, $18, $70, $8c, $38, $44, $05, $46, $00, $0c, $12, $0c
	db $12, $04, $0a, $00, $06, $00, $0c, $00, $18, $00, $30, $00, $20, $00, $40, $00
	db $80, $00, $80, $00, $0e, $00, $0c, $05, $02, $21, $08, $00, $18, $00, $10, $00
	db $05, $6f, $04, $05, $b1, $02, $1e, $05, $1e, $07, $0f, $05, $1e, $17, $05, $35
	db $11, $00, $f8, $00, $7e, $00, $0f, $05, $40, $1f, $0e, $38, $00, $1c, $00, $0c
	db $00, $0e, $00, $06, $05, $68, $23, $05, $01, $2c, $03, $00, $02, $05, $f0, $15
	db $05, $8b, $00, $05, $11, $28, $0e, $00, $38, $05, $9a, $21, $18, $05, $52, $11
	db $05, $c5, $0a, $05, $b8, $2f, $4d, $05, $18, $3f, $4d, $05, $78, $3f, $4d, $05
	db $d8, $3f, $4d, $05, $38, $4f, $4d, $05, $98, $4f, $4d, $05, $f8, $4f, $4d, $05
	db $58, $5f, $4d, $05, $b8, $5f, $4d, $05, $18, $6f, $4d, $05, $78, $6f, $4d, $05
	db $d8, $6f, $4d, $05, $38, $7f, $4d, $05, $98, $7f, $4d, $05, $f8, $73

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $24 (SkillAnimGfx entry $24), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites24::
	db $00, $08, $05
	db $10, $6c, $10, $28, $05, $02, $00, $00, $38, $00, $10, $05, $0a, $00, $38, $44
	db $05, $10, $0a, $05, $02, $01, $6c, $10, $6c, $05, $10, $04, $00, $38, $00, $38
	db $05, $02, $02, $05, $02, $03, $05, $0b, $01, $05, $40, $06, $ff, $00, $80, $7f
	db $bf, $40, $a0, $5f, $a0, $50, $05, $58, $02, $1f, $00, $10, $0f, $17, $08, $14
	db $0b, $14, $0a, $05, $68, $02, $ff, $00, $00, $ff, $05, $70, $00, $05, $f8, $f4
	db $a0, $50, $20, $d0, $e0, $10, $00, $f0, $05, $78, $06, $05, $90, $0f, $00, $5f
	db $bf, $40, $80, $7f, $05, $77, $02, $10, $ee, $54, $aa, $05, $1c, $01, $6c, $05
	db $06, $03, $00, $00, $08, $00, $08, $00, $0c, $00, $ce, $04, $7a, $14, $2b, $0e
	db $11, $10, $aa, $10, $aa, $05, $b0, $00, $05, $d6, $01, $ab, $d6, $29, $07, $08
	db $03, $04, $01, $02, $00, $0d, $01, $02, $00, $01, $05, $fc, $f0, $39, $c6, $d7
	db $28, $ff, $00, $fe, $01, $bb, $44, $54, $ab, $10, $6c, $28, $54, $05, $a0, $ff
	db $4d, $05, $5f, $1f, $4d, $05, $bf, $1f, $4d, $05, $1f, $2f, $4d, $05, $7f, $2f
	db $4d, $05, $df, $2f, $4d, $05, $3f, $3f, $4d, $05, $9f, $3f, $4d, $05, $ff, $3f
	db $4d, $05, $5f, $4f, $4d, $05, $bf, $4f, $4d, $05, $1f, $5f, $4d, $05, $7f, $5f
	db $4d, $05, $df, $5f, $4d, $05, $3f, $6f, $4d, $05, $9f, $6f, $4d, $05, $ff, $6f
	db $4d, $05, $5f, $7f, $4d, $05, $bf, $7f, $2d

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $25 (SkillAnimGfx entry $25), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites25::
	db $00, $08, $05
	db $10, $28, $05, $00, $00, $00, $10, $05, $06, $04, $10, $6c, $05, $00, $02, $05
	db $12, $04, $28, $54, $05, $20, $06, $38, $44, $38, $44, $10, $aa, $05, $30, $01
	db $ee, $54, $aa, $54, $aa, $6c, $92, $28, $d6, $05, $12, $0a, $05, $04, $08, $05
	db $06, $03, $92, $10, $ac, $30, $c8, $60, $90, $00, $60, $00, $c0, $00, $80, $05
	db $fd, $f0, $00, $11, $00, $31, $00, $33, $00, $37, $02, $75, $22, $5d, $37, $48
	db $05, $f9, $f3, $08, $00, $30, $00, $e0, $80, $40, $00, $80, $4e, $b1, $0c, $d2
	db $08, $94, $10, $2b, $18, $24, $20, $58, $00, $60, $00, $80, $00, $01, $00, $01
	db $00, $03, $00, $23, $00, $26, $00, $26, $00, $2e, $04, $6b, $05, $fb, $f1, $20
	db $00, $20, $00, $62, $00, $c4, $00, $cc, $00, $d8, $04, $7b, $2d, $52, $2b, $54
	db $3f, $40, $3f, $40, $33, $cc, $41, $b2, $01, $c2, $80, $70, $a0, $51, $40, $a6
	db $c0, $3c, $a0, $58, $c0, $30, $80, $7e, $c0, $38, $03, $84, $03, $04, $07, $08
	db $04, $0b, $08, $16, $00, $38, $05, $9c, $00, $80, $60, $40, $b8, $00, $e0, $05
	db $6c, $01, $05, $fb, $f1, $b8, $00, $3a, $05, $ff, $09, $34, $00, $58, $05, $0f
	db $19, $05, $1f, $1f, $4d, $05, $7f, $1f, $4d, $05, $df, $1f, $4d, $05, $3f, $2f
	db $4d, $05, $9f, $2f, $4d, $05, $ff, $2f, $4d, $05, $5f, $3f, $4d, $05, $bf, $3f
	db $4d, $05, $1f, $4f, $4d, $05, $7f, $4f, $4d, $05, $df, $4f, $4d, $05, $3f, $5f
	db $4d, $05, $9f, $5f, $4d, $05, $ff, $5f, $4d, $05, $5f, $6f, $4d, $05, $bf, $6f
	db $4d, $05, $1f, $7f, $4d, $05, $7f, $7f, $4d, $05, $df, $7f, $0d

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $26 (SkillAnimGfx entry $26), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites26::
	db $00, $08, $19
	db $07, $b8, $03, $e4, $44, $ab, $28, $55, $3c, $43, $38, $46, $20, $58, $00, $60
	db $80, $4c, $00, $b0, $00, $40, $00, $b0, $00, $c0, $19, $f5, $f7, $20, $00, $21
	db $01, $22, $03, $24, $06, $29, $0e, $b1, $00, $10, $00, $30, $00, $e0, $80, $40
	db $00, $80, $00, $80, $00, $00, $00, $e2, $fe, $01, $b9, $46, $f3, $0c, $b3, $4c
	db $9b, $64, $b7, $48, $7f, $80, $ed, $12, $00, $03, $02, $05, $06, $09, $0e, $11
	db $1c, $22, $1c, $22, $38, $44, $70, $88, $19, $fb, $f1, $01, $00, $03, $01, $42
	db $03, $44, $03, $c4, $07, $88, $19, $56, $00, $38, $44, $19, $5c, $00, $60, $90
	db $e0, $1c, $f8, $04, $00, $19, $7f, $00, $0c, $00, $0c, $00, $0d, $00, $0d, $08
	db $15, $08, $17, $03, $44, $07, $c8, $07, $c8, $0d, $92, $09, $96, $15, $aa, $15
	db $aa, $0a, $75, $f8, $04, $f0, $08, $e0, $10, $c0, $20, $80, $41, $80, $46, $00
	db $8c, $00, $38, $0a, $15, $1a, $25, $12, $2d, $16, $29, $14, $2b, $31, $4e, $33
	db $4c, $37, $48, $18, $66, $30, $cd, $71, $8e, $66, $99, $ec, $12, $d8, $24, $d0
	db $2b, $83, $7c, $00, $60, $00, $c0, $00, $80, $00, $0c, $00, $38, $00, $f0, $19
	db $36, $00, $07, $08, $06, $09, $07, $08, $0f, $10, $19, $e6, $02, $1f, $20, $78
	db $87, $fb, $04, $f7, $08, $f6, $09, $fc, $02, $f0, $0c, $19, $a4, $00, $e0, $10
	db $80, $60, $19, $3a, $01, $19, $f9, $f3, $1f, $20, $1e, $21, $3c, $42, $38, $44
	db $30, $48, $00, $70, $19, $d2, $00, $19, $36, $01, $19, $f5, $f7, $02, $05, $04
	db $0a, $04, $0a, $08, $14, $10, $28, $10, $28, $20, $50, $40, $a0, $00, $02, $19
	db $80, $01, $08, $00, $10, $00, $10, $00, $20, $00, $40, $11, $44, $2b, $84, $13
	db $c4, $0f, $60, $47, $38, $af, $00, $5f, $00, $9f, $60, $f9, $04, $f8, $03, $f5
	db $08, $ea, $10, $e0, $1c, $a8, $46, $94, $61, $88, $22, $05, $20, $0a, $40, $05
	db $60, $0b, $10, $17, $00, $03, $38, $17, $60, $2e, $40, $74, $02, $e0, $0e, $c4
	db $10, $e8, $01, $d0, $01, $a0, $07, $50, $04, $a0, $04, $19, $fb, $f1, $08, $00
	db $08, $00, $0c, $00, $04, $00, $06, $00, $06, $19, $1a, $09, $19, $37, $00, $06
	db $02, $05, $00, $03, $00, $03, $01, $02, $01, $f2, $13, $2c, $0f, $10, $00, $01
	db $00, $07, $04, $0a, $08, $34, $38, $c4, $19, $a2, $00, $e0, $10, $19, $f3, $f9
	db $01, $00, $03, $19, $e4, $02, $1c, $23, $30, $4c, $40, $19, $17, $01, $e0, $10
	db $c0, $38, $80, $40, $80, $40, $00, $c0, $00, $40, $00, $20, $00, $20, $00, $00
	db $00, $80, $00, $c0, $00, $60, $00, $38, $08, $14, $0c, $12, $06, $09, $19, $94
	db $11, $18, $19, $30, $01, $19, $19, $20, $60, $60, $90, $30, $48, $38, $46, $1e
	db $21, $0f, $10, $07, $08, $07, $08, $03, $04, $00, $18, $10, $28, $30, $48, $70
	db $89, $f8, $07, $fc, $02, $f8, $04, $f8, $19, $8f, $10, $06, $00, $38, $00, $e0
	db $19, $04, $14, $19, $ec, $00, $3f, $40, $0f, $f0, $06, $09, $19, $32, $10, $00
	db $1c, $e0, $10, $f0, $08, $f0, $08, $f8, $04, $38, $c4, $0c, $32, $06, $09, $03
	db $04, $00, $1c, $00, $18, $19, $72, $21, $19, $49, $10, $19, $fc, $f0, $03, $19
	db $f2, $fa, $80, $40, $40, $a0, $20, $50, $00, $30, $00, $18, $00, $0c, $00, $02
	db $00, $01, $ff, $00, $19, $a0, $2a, $00, $01, $00, $00, $00, $88, $00, $66, $22
	db $55, $11, $2a, $09, $16, $0c, $13, $00, $0c, $04, $ca, $46, $a9, $26, $59, $33
	db $cc, $9b, $64, $dd, $22, $ff, $00, $00, $51, $11, $ea, $51, $aa, $59, $a6, $7b
	db $84, $fb, $04, $19, $a0, $20, $06, $49, $03, $34, $11, $2e, $0e, $11, $07, $f8
	db $33, $4c, $1d, $22, $0f, $10, $7b, $84, $1f, $60, $07, $18, $0f, $70, $7f, $80
	db $03, $fc, $0f, $30, $3f, $40, $19, $a0, $ff, $4d, $19, $5f, $3f, $4d, $19, $bf
	db $3f, $4d, $19, $1f, $4f, $4d, $19, $7f, $4f, $4d, $19, $df, $4f, $4d, $19, $3f
	db $5f, $4d, $19, $9f, $5f, $4d, $19, $ff, $5f, $4d, $19, $5f, $6f, $4d, $19, $bf
	db $6f, $4d, $19, $1f, $7f, $4d, $19, $7f, $7f, $4d, $19, $df, $7f, $0d

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $27 (SkillAnimGfx entry $27), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites27::
	db $00, $08, $11
	db $01, $02, $07, $08, $0f, $10, $3b, $44, $67, $18, $1c, $61, $61, $9a, $02, $65
	db $00, $00, $01, $06, $07, $18, $19, $66, $63, $94, $06, $39, $38, $c6, $c2, $35
	db $01, $06, $06, $19, $18, $66, $60, $9b, $83, $44, $11, $1a, $00, $c0, $30, $3b
	db $44, $f7, $08, $fe, $01, $7f, $80, $ef, $10, $bd, $42, $f7, $08, $df, $20, $8f
	db $40, $3c, $83, $f3, $0c, $de, $21, $f9, $06, $e7, $18, $fe, $01, $38, $c6, $11
	db $ed, $ff, $00, $03, $06, $18, $18, $66, $62, $1d, $0c, $f2, $30, $4c, $c0, $30
	db $00, $00, $00, $18, $1e, $e0, $f0, $0f, $1f, $e0, $f8, $06, $c0, $38, $00, $00
	db $ff, $00, $ff, $00, $00, $ff, $03, $11, $7f, $01, $fc, $03, $c0, $3c, $11, $82
	db $00, $0f, $11, $89, $01, $c1, $3c, $1f, $c0, $fe, $01, $83, $7c, $7f, $80, $f8
	db $03, $83, $3c, $1f, $c0, $f8, $07, $c1, $38, $0f, $c0, $11, $a4, $00, $3c, $c3
	db $e1, $1c, $07, $e0, $3e, $00, $f0, $03, $c0, $1c, $3f, $00, $f8, $03, $e0, $0e
	db $80, $70, $03, $c0, $0f, $00, $3f, $11, $81, $00, $00, $00, $fe, $fc, $02, $11
	db $d4, $0f, $07, $00, $00, $00, $ff, $11, $80, $00, $11, $f4, $04, $03, $70, $0f
	db $80, $3f, $00, $fe, $00, $fc, $03, $f1, $0c, $c7, $30, $8f, $40, $41, $22, $eb
	db $04, $7e, $81, $fe, $01, $bc, $42, $3d, $40, $7b, $80, $ef, $10, $11, $f8, $f4
	db $04, $04, $0e, $0a, $07, $05, $02, $02, $7b, $04, $f7, $08, $bf, $00, $7e, $01
	db $dd, $22, $3b, $44, $5e, $a0, $34, $40, $11, $fd, $f0, $01, $06, $06, $09, $00
	db $0f, $03, $0c, $0c, $13, $00, $0d, $18, $67, $77, $88, $9c, $63, $7e, $81, $e3
	db $1c, $0c, $f3, $31, $ce, $c7, $38, $83, $4c, $0c, $b3, $30, $cf, $c6, $39, $fc
	db $03, $63, $9c, $fc, $03, $30, $ce, $0c, $33, $30, $48, $00, $70, $11, $f6, $f6
	db $1c, $14, $08, $08, $11, $fc, $f0, $08, $08, $11, $80, $12, $11, $88, $10, $11
	db $92, $16, $08, $08, $59, $26, $76, $89, $bd, $42, $5b, $a4, $3e, $c1, $35, $4a
	db $4b, $b4, $92, $6d, $11, $92, $18, $11, $92, $10, $11, $f9, $f3, $11, $f3, $00
	db $11, $ce, $01, $06, $06, $61, $63, $1e, $7f, $63, $7f, $1c, $1f, $ff, $11, $c7
	db $11, $60, $e0, $9c, $fc, $73, $cf, $0f, $f0, $11, $c8, $14, $11, $fc, $f0, $c0
	db $c0, $38, $f8, $c4, $3c, $f8, $f8, $11, $f6, $f6, $84, $84, $ce, $4a, $84, $84
	db $11, $f6, $f6, $7e, $7e, $ff, $81, $7e, $7e, $11, $fc, $f0, $40, $40, $a1, $e1
	db $43, $42, $01, $01, $11, $88, $10, $09, $09, $00, $00, $07, $05, $11, $30, $22
	db $57, $75, $57, $75, $2f, $3d, $2f, $3d, $af, $bd, $b7, $fd, $57, $7d, $53, $7d
	db $2b, $3d, $2b, $35, $1b, $15, $17, $19, $17, $19, $0f, $09, $0f, $09, $0b, $0d
	db $0b, $0d, $11, $31, $20, $02, $11, $ef, $00, $00, $40, $40, $f0, $b0, $7c, $4c
	db $3e, $32, $0f, $0d, $11, $5e, $20, $40, $40, $e0, $a0, $78, $58, $34, $2c, $1a
	db $16, $0d, $0f, $02, $02, $16, $1e, $0b, $0d, $c3, $c2, $71, $b1, $fc, $cc, $3f
	db $33, $0f, $0c, $03, $03, $00, $00, $02, $02, $c7, $c5, $e3, $22, $b9, $d9, $34
	db $2c, $da, $d6, $fd, $3b, $11, $84, $12, $9c, $94, $dc, $54, $da, $56, $ee, $aa
	db $7d, $5b, $ff, $cc, $3f, $33, $0e, $0d, $01, $fe, $11, $c8, $14, $df, $ed, $b6
	db $6d, $d9, $b6, $a5, $5a, $11, $c8, $14, $3b, $c4, $4f, $70, $e7, $f8, $1f, $e0
	db $11, $c8, $14, $76, $89, $b7, $48, $11, $f4, $03, $11, $ce, $01, $c0, $a0, $70
	db $b0, $a8, $78, $f0, $70, $70, $d0, $60, $a0, $e0, $20, $c0, $c0, $11, $a0, $ff
	db $4d, $11, $5f, $3f, $4d, $11, $bf, $3f, $4d, $11, $1f, $4f, $4d, $11, $7f, $4f
	db $4d, $11, $df, $4f, $4d, $11, $3f, $5f, $4d, $11, $9f, $5f, $4d, $11, $ff, $5f
	db $4d, $11, $5f, $6f, $4d, $11, $bf, $6f, $4d, $11, $1f, $7f, $4d, $11, $7f, $7f
	db $4d, $11, $df, $7f, $0d

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $28 (SkillAnimGfx entry $28), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites28::
	db $00, $08, $14
	db $00, $ff, $14, $00, $0f, $05, $01, $fe, $03, $fc, $06, $f9, $14, $00, $00, $0c
	db $f3, $18, $e7, $d0, $2f, $f0, $0f, $14, $00, $0c, $f0, $0f, $1c, $e3, $00, $f0
	db $f0, $0c, $1c, $e2, $0c, $32, $18, $e4, $d0, $28, $f0, $08, $00, $f0, $18, $1f
	db $10, $14, $51, $01, $00, $7f, $70, $8f, $c8, $37, $8f, $50, $14, $14, $04, $06
	db $f9, $04, $fb, $08, $f7, $06, $f9, $06, $07, $04, $1f, $18, $27, $20, $5f, $10
	db $2f, $18, $27, $06, $19, $09, $0e, $14, $00, $0a, $80, $7f, $60, $9f, $18, $e7
	db $0c, $f3, $03, $fc, $01, $fe, $14, $00, $0a, $87, $7f, $c4, $3c, $48, $b8, $08
	db $f8, $02, $14, $65, $01, $18, $e7, $61, $9f, $41, $bf, $81, $7f, $62, $9e, $60
	db $90, $80, $60, $00, $80, $80, $80, $14, $f8, $f6, $80, $7f, $80, $7f, $f8, $07
	db $0f, $f0, $14, $88, $03, $80, $c0, $c0, $60, $e0, $20, $e0, $c0, $30, $70, $88
	db $30, $c8, $60, $90, $00, $1f, $1e, $e1, $fc, $02, $cc, $32, $08, $d4, $18, $24
	db $30, $48, $18, $24, $08, $f8, $08, $f8, $04, $fc, $04, $fc, $06, $14, $65, $01
	db $19, $e7, $0c, $f3, $b0, $cf, $60, $9f, $80, $7f, $40, $ff, $20, $3f, $14, $1a
	db $10, $01, $02, $03, $04, $06, $09, $0c, $32, $30, $4c, $14, $c0, $02, $00, $00
	db $00, $01, $00, $1d, $0c, $13, $04, $0b, $03, $04, $00, $03, $00, $00, $40, $80
	db $40, $a0, $40, $a0, $20, $50, $20, $5e, $3e, $41, $03, $7c, $00, $03, $80, $4f
	db $08, $8f, $08, $0f, $14, $54, $10, $0d, $0f, $06, $06, $00, $00, $c0, $3f, $20
	db $df, $14, $00, $00, $e0, $ff, $20, $3f, $14, $54, $01, $14, $fd, $f0, $01, $14
	db $20, $16, $14, $74, $10, $06, $19, $18, $66, $60, $98, $40, $a0, $80, $60, $60
	db $98, $e0, $e0, $d8, $f8, $27, $3f, $10, $1f, $08, $0f, $04, $07, $04, $07, $02
	db $03, $14, $1a, $12, $40, $7f, $40, $7f, $c0, $ff, $80, $14, $65, $11, $1d, $1e
	db $14, $84, $18, $00, $00, $00, $03, $03, $0c, $0e, $11, $00, $0e, $14, $fb, $f2
	db $07, $f8, $0f, $f0, $18, $e7, $30, $cf, $c0, $3f, $80, $7f, $14, $00, $00, $40
	db $a0, $c0, $20, $10, $f0, $18, $f8, $0c, $fc, $06, $fe, $01, $ff, $01, $ff, $1c
	db $22, $18, $24, $14, $f2, $10, $10, $68, $30, $48, $20, $50, $60, $90, $14, $a6
	db $10, $60, $7f, $30, $3f, $14, $98, $10, $02, $03, $02, $03, $12, $f2, $1a, $fa
	db $0a, $fa, $0b, $fb, $0b, $fb, $05, $ff, $05, $ff, $04, $ff, $30, $30, $d8, $f8
	db $14, $00, $14, $14, $04, $10, $c4, $fc, $44, $7c, $14, $32, $28, $42, $7e, $41
	db $7f, $81, $ff, $81, $ff, $01, $ff, $02, $fe, $14, $4a, $20, $14, $fb, $f2, $21
	db $21, $71, $71, $51, $71, $49, $79, $ca, $fb, $14, $75, $10, $0e, $0f, $08, $0f
	db $78, $7f, $14, $ac, $10, $14, $de, $06, $30, $f0, $10, $14, $79, $21, $80, $80
	db $14, $e0, $00, $40, $c0, $60, $e0, $30, $f0, $18, $f8, $08, $f8, $30, $f0, $20
	db $e0, $40, $c0, $14, $80, $20, $14, $fb, $f2, $20, $e0, $10, $f0, $08, $f8, $84
	db $fc, $44, $7c, $22, $3e, $13, $1f, $09, $0f, $03, $03, $0c, $0f, $18, $1f, $14
	db $a4, $10, $14, $6a, $22, $14, $50, $04, $14, $54, $12, $08, $0f, $20, $50, $14
	db $fc, $10, $c0, $20, $00, $c0, $14, $fb, $f2, $80, $80, $60, $e0, $90, $f0, $58
	db $78, $8c, $14, $e9, $13, $14, $f7, $f6, $03, $03, $1c, $1f, $e0, $14, $ef, $27
	db $14, $09, $3f, $4d, $14, $69, $3f, $4d, $14, $c9, $3f, $4d, $14, $29, $4f, $4d
	db $14, $89, $4f, $4d, $14, $e9, $4f, $4d, $14, $49, $5f, $4d, $14, $a9, $5f, $4d
	db $14, $09, $6f, $4d, $14, $69, $6f, $4d, $14, $c9, $6f, $4d, $14, $29, $7f, $4d
	db $14, $89, $7f, $4d, $14, $e9, $7f, $03

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $29 (SkillAnimGfx entry $29), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites29::
	db $00, $08, $05
	db $05, $ff, $f4, $03, $03, $04, $07, $18, $1f, $28, $3f, $05, $ff, $f4, $80, $80
	db $40, $c0, $7c, $fc, $a2, $fe, $3c, $3f, $26, $3f, $42, $7f, $40, $7f, $44, $7f
	db $66, $7f, $3f, $3f, $1d, $1d, $01, $ff, $71, $ff, $13, $ff, $0f, $ff, $0e, $fe
	db $18, $f8, $f0, $f0, $e0, $e0, $05, $ff, $f0, $3e, $3e, $41, $7f, $e0, $ff, $30
	db $ff, $10, $ff, $00, $ff, $00, $ff, $30, $ff, $18, $ff, $08, $ff, $08, $ff, $1c
	db $ff, $ff, $ff, $f3, $f3, $05, $ff, $f4, $ef, $ef, $38, $05, $53, $01, $40, $40
	db $60, $60, $30, $30, $2c, $3c, $13, $1f, $10, $1f, $08, $0f, $09, $0e, $00, $00
	db $40, $40, $42, $42, $cc, $cc, $38, $f8, $10, $f0, $96, $76, $cc, $3c, $f9, $fe
	db $04, $07, $08, $0f, $0b, $0f, $1d, $1d, $10, $10, $20, $20, $00, $00, $e4, $1c
	db $8e, $7e, $10, $f0, $68, $f8, $98, $98, $8c, $8c, $82, $82, $05, $ff, $f2, $01
	db $05, $b4, $03, $11, $11, $1d, $1d, $05, $ae, $04, $02, $02, $06, $06, $8c, $8c
	db $94, $9c, $01, $01, $05, $02, $04, $05, $d0, $00, $03, $03, $ca, $cf, $a8, $ef
	db $51, $7e, $47, $78, $8f, $f0, $3f, $c0, $9f, $e0, $9f, $e0, $64, $fc, $08, $f8
	db $89, $79, $e7, $1f, $f2, $0e, $e4, $1c, $f3, $0f, $f8, $07, $05, $fc, $f8, $f0
	db $f0, $40, $c0, $05, $12, $04, $60, $60, $50, $70, $2c, $3c, $23, $3f, $02, $02
	db $05, $c8, $00, $06, $06, $0a, $0e, $12, $1e, $22, $3e, $ca, $f6, $05, $ec, $ff
	db $09, $0e, $0e, $34, $3c, $05, $b4, $00, $e1, $e1, $5f, $7f, $30, $3f, $09, $0e
	db $04, $07, $02, $03, $01, $fe, $bf, $c0, $9f, $e0, $3f, $c0, $7f, $80, $ff, $00
	db $7f, $80, $7f, $80, $98, $78, $c7, $3f, $e0, $1f, $fe, $01, $fc, $03, $fc, $03
	db $ff, $00, $fc, $03, $c8, $f8, $10, $f0, $20, $e0, $40, $c0, $f0, $f0, $0f, $ff
	db $1c, $fc, $60, $e0, $00, $ff, $c0, $ff, $8e, $ff, $19, $ff, $71, $ff, $d8, $ff
	db $8c, $ff, $80, $ff, $05, $ff, $f2, $04, $04, $0c, $0c, $94, $9c, $64, $fc, $44
	db $fc, $03, $00, $0c, $03, $11, $0e, $27, $18, $4f, $30, $5f, $20, $9f, $60, $bf
	db $40, $05, $00, $05, $00, $04, $03, $09, $06, $13, $0c, $07, $00, $18, $07, $60
	db $1f, $8f, $70, $05, $66, $12, $ff, $00, $17, $08, $05, $b6, $10, $05, $b8, $12
	db $05, $ea, $10, $05, $4d, $01, $05, $f1, $17, $05, $fe, $f6, $01, $00, $06, $01
	db $0c, $03, $05, $08, $20, $0e, $01, $30, $0f, $c1, $3e, $87, $78, $1f, $e0, $7f
	db $80, $1f, $00, $e0, $1f, $00, $ff, $1f, $e0, $05, $f8, $1c, $01, $00, $03, $00
	db $02, $01, $04, $03, $19, $06, $33, $0c, $67, $18, $cf, $30, $9f, $60, $05, $66
	db $12, $0c, $03, $09, $06, $11, $0e, $13, $0c, $23, $1c, $27, $18, $05, $e2, $12
	db $05, $e4, $10, $05, $ea, $12, $05, $ea, $10, $2a, $00, $55, $00, $aa, $05, $71
	db $25, $54, $00, $28, $00, $51, $00, $08, $00, $45, $00, $90, $00, $45, $00, $10
	db $00, $44, $05, $07, $21, $05, $14, $24, $1d, $e0, $7a, $05, $1f, $25, $f5, $00
	db $aa, $00, $50, $00, $81, $00, $04, $03, $08, $07, $05, $54, $20, $26, $18, $25
	db $18, $4e, $30, $9d, $60, $05, $40, $20, $66, $18, $cc, $30, $99, $60, $32, $c0
	db $65, $80, $ca, $05, $4f, $25, $22, $1c, $05, $b8, $22, $4d, $30, $4a, $30, $4c
	db $30, $9a, $60, $94, $60, $92, $60, $94, $60, $98, $60, $05, $a0, $ff, $4d, $05
	db $4f, $3f, $4d, $05, $af, $3f, $4d, $05, $0f, $4f, $4d, $05, $6f, $4f, $4d, $05
	db $cf, $4f, $4d, $05, $2f, $5f, $4d, $05, $8f, $5f, $4d, $05, $ef, $5f, $4d, $05
	db $4f, $6f, $4d, $05, $af, $6f, $4d, $05, $0f, $7f, $4d, $05, $6f, $7f, $4d, $05
	db $cf, $7f, $1d
;@ path: battle/skillanim
;@ Sprite tiles of skill animation $2A (SkillAnimGfx entry $2A), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites2A::
	db $00, $08, $05
	db $00, $10, $05, $00, $0a, $10, $28, $05, $10, $0a, $3c, $c2, $78, $86, $05, $20
	db $08, $3f, $c0, $5f, $a0, $05, $30, $08, $ff, $00, $05, $40, $0a, $0c, $0c, $14
	db $1c, $1c, $1c, $00, $00, $77, $77, $d5, $f7, $96, $f6, $e0, $e0, $1e, $1e, $32
	db $3e, $71, $7f, $71, $7f, $ab, $ff, $ac, $fc, $d8, $f8, $70, $70, $00, $00, $1c
	db $1c, $62, $7e, $f1, $ff, $e9, $ff, $4e, $7e, $38, $38, $05, $fb, $f2, $07, $07
	db $0c, $0f, $18, $1f, $30, $3f, $38, $3f, $2c, $3f, $05, $fd, $f0, $80, $80, $70
	db $f0, $68, $f8, $44, $fc, $02, $fe, $0a, $fe, $36, $3f, $33, $3f, $1b, $1f, $1a
	db $1f, $0e, $0f, $03, $03, $05, $fd, $f0, $3a, $fe, $e2, $fe, $04, $fc, $18, $f8
	db $e0, $e0, $80, $80, $05, $f9, $f4, $01, $01, $06, $07, $18, $1f, $3c, $3f, $26
	db $3f, $40, $7f, $05, $fd, $f0, $e0, $e0, $10, $f0, $08, $f8, $24, $fc, $24, $fc
	db $44, $fc, $60, $7f, $70, $7f, $7f, $7f, $39, $3f, $1b, $1f, $07, $07, $05, $fd
	db $f0, $44, $fc, $88, $f8, $88, $f8, $90, $f0, $a0, $e0, $c0, $c0, $05, $fb, $f2
	db $78, $78, $c4, $fc, $82, $fe, $82, $fe, $c1, $ff, $e1, $ff, $a2, $fe, $94, $fc
	db $dc, $fc, $d8, $f8, $b0, $f0, $a0, $e0, $e0, $05, $f9, $03, $1f, $1f, $2c, $3f
	db $50, $7f, $43, $7f, $7c, $7f, $33, $3f, $0f, $0f, $05, $fd, $f0, $c0, $c0, $f0
	db $f0, $0c, $fc, $02, $fe, $ce, $fe, $f0, $f0, $05, $f5, $f8, $03, $03, $04, $05
	db $eb, $01, $05, $80, $02, $7c, $7f, $b8, $ff, $10, $ff, $05, $f9, $f4, $c0, $c0
	db $30, $05, $37, $11, $04, $07, $08, $0f, $10, $1f, $10, $1f, $2f, $3f, $70, $7f
	db $70, $7f, $7a, $7f, $30, $ff, $20, $ff, $20, $05, $40, $01, $80, $ff, $c0, $ff
	db $30, $ff, $01, $05, $40, $03, $23, $ff, $2c, $ff, $10, $ff, $6c, $ff, $80, $80
	db $40, $c0, $40, $c0, $c0, $c0, $20, $e0, $05, $a8, $10, $10, $f0, $3e, $3f, $1c
	db $1f, $0e, $0f, $06, $07, $03, $03, $01, $01, $05, $fd, $f0, $3d, $ff, $27, $ff
	db $40, $05, $c3, $11, $e0, $ff, $3e, $3f, $03, $03, $82, $05, $87, $11, $43, $ff
	db $2e, $fe, $7c, $fc, $f0, $f0, $05, $d4, $00, $20, $05, $f9, $05, $05, $c0, $02
	db $02, $03, $04, $07, $05, $70, $12, $20, $3f, $20, $3f, $c0, $c0, $38, $f8, $14
	db $fc, $0b, $ff, $08, $ff, $10, $ff, $10, $05, $83, $10, $05, $fa, $f3, $05, $a0
	db $10, $30, $f0, $08, $f8, $40, $7f, $40, $7f, $e0, $ff, $f0, $ff, $c8, $ff, $c5
	db $ff, $c7, $ff, $e3, $ff, $26, $ff, $38, $ff, $60, $ff, $c0, $ff, $80, $05, $40
	db $03, $04, $fc, $02, $fe, $02, $fe, $01, $ff, $05, $46, $22, $06, $fe, $e2, $ff
	db $73, $7f, $71, $7f, $79, $7f, $65, $7f, $62, $7f, $3c, $3f, $20, $3f, $05, $41
	db $02, $80, $ff, $81, $ff, $87, $ff, $4c, $ff, $78, $ff, $1c, $fc, $38, $f8, $78
	db $f8, $f0, $f0, $f0, $f0, $60, $e0, $20, $e0, $40, $c0, $e0, $ff, $70, $7f, $74
	db $7f, $3c, $3f, $1e, $1f, $0f, $0f, $07, $07, $03, $03, $41, $ff, $05, $90, $20
	db $46, $fe, $48, $f8, $b0, $f0, $c0, $c0, $05, $ba, $06, $05, $a7, $2f, $4d, $05
	db $07, $3f, $4d, $05, $67, $3f, $4d, $05, $c7, $3f, $4d, $05, $27, $4f, $4d, $05
	db $87, $4f, $4d, $05, $e7, $4f, $4d, $05, $47, $5f, $4d, $05, $a7, $5f, $4d, $05
	db $07, $6f, $4d, $05, $67, $6f, $4d, $05, $c7, $6f, $4d, $05, $27, $7f, $4d, $05
	db $87, $7f, $4d, $05, $e7, $7f, $05

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $2B (SkillAnimGfx entry $2B), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites2B::
	db $00, $08, $0b
	db $03, $02, $0f, $08, $1f, $10, $7f, $44, $7f, $18, $7d, $61, $fb, $9a, $67, $65
	db $00, $00, $07, $06, $1f, $18, $7f, $66, $f7, $94, $3f, $39, $fe, $c6, $f7, $35
	db $07, $06, $1f, $19, $7e, $66, $fb, $9b, $c7, $44, $0b, $1a, $00, $f0, $30, $7f
	db $44, $ff, $08, $ff, $01, $ff, $80, $ff, $10, $ff, $42, $ff, $08, $ff, $20, $cf
	db $40, $bf, $83, $ff, $0c, $ff, $21, $ff, $06, $ff, $18, $ff, $01, $fe, $c6, $03
	db $03, $4f, $08, $bf, $33, $fe, $c6, $ff, $1c, $7f, $73, $fc, $cc, $f0, $30, $00
	db $00, $03, $03, $1e, $18, $7e, $66, $7f, $1d, $fe, $f2, $7c, $4c, $0b, $5e, $00
	db $18, $18, $fe, $e0, $ff, $0f, $ff, $e0, $fe, $06, $f8, $38, $0b, $fc, $f0, $0c
	db $08, $1c, $14, $38, $28, $76, $54, $ee, $aa, $dc, $54, $b8, $a8, $0f, $0c, $3f
	db $33, $7c, $4c, $71, $31, $0b, $20, $02, $78, $18, $fe, $1e, $f8, $00, $ff, $0f
	db $ff, $00, $ff, $3f, $f0, $00, $f8, $38, $ff, $07, $00, $00, $7f, $78, $7f, $00
	db $ff, $f0, $ff, $00, $ff, $f8, $3f, $00, $7f, $71, $fe, $fe, $fc, $04, $ff, $7f
	db $ff, $00, $ff, $ff, $f0, $10, $f8, $f8, $ff, $07, $39, $29, $b9, $a9, $b9, $a9
	db $fb, $aa, $ff, $8a, $ff, $0a, $ff, $00, $ff, $00, $ff, $02, $0b, $dc, $01, $88
	db $ff, $aa, $ff, $aa, $fb, $aa, $39, $28, $06, $06, $0f, $09, $1f, $11, $1e, $12
	db $3c, $2c, $70, $50, $60, $60, $80, $80, $0b, $d0, $00, $f9, $e9, $fb, $aa, $ff
	db $ae, $0b, $e8, $00, $ff, $8a, $63, $22, $ef, $04, $ff, $81, $ff, $01, $fe, $42
	db $7d, $40, $fb, $80, $ff, $10, $7f, $00, $ff, $00, $bf, $00, $7f, $00, $ff, $20
	db $7f, $40, $fe, $a0, $74, $40, $7f, $04, $ff, $08, $bf, $00, $7f, $01, $ff, $22
	db $7f, $44, $0b, $2c, $10, $00, $00, $01, $01, $07, $06, $0f, $09, $0f, $0f, $0f
	db $0c, $1f, $13, $0d, $0d, $7f, $67, $ff, $88, $ff, $63, $ff, $81, $ff, $1c, $ff
	db $f3, $ff, $ce, $ff, $38, $cf, $4c, $bf, $b3, $ff, $cf, $ff, $39, $ff, $03, $ff
	db $9c, $ff, $03, $fe, $ce, $3f, $33, $78, $48, $70, $70, $0b, $f6, $f6, $7f, $26
	db $ff, $09, $ff, $43, $ff, $a6, $ff, $c1, $7e, $5a, $fc, $b4, $f8, $68, $2b, $2a
	db $7f, $56, $ff, $85, $f7, $25, $fe, $4a, $7f, $42, $ff, $84, $ff, $90, $7f, $26
	db $ff, $89, $ff, $42, $ff, $a4, $ff, $c1, $7f, $4a, $ff, $b4, $ff, $6d, $ff, $a0
	db $bf, $29, $7e, $5a, $7e, $52, $ec, $a4, $ec, $a4, $c8, $48, $c0, $40, $0b, $fc
	db $f0, $01, $01, $06, $06, $1b, $18, $6d, $61, $b6, $86, $c8, $08, $0b, $c8, $12
	db $d8, $18, $0b, $fc, $00, $0b, $f6, $f7, $03, $0b, $90, $00, $0b, $5c, $00, $03
	db $02, $07, $05, $0e, $0a, $0b, $84, $00, $70, $50, $e0, $a0, $c0, $40, $03, $02
	db $0b, $f0, $10, $0b, $f2, $10, $0b, $f4, $10, $0b, $84, $00, $0b, $f8, $10, $0b
	db $fa, $10, $0b, $fc, $10, $0b, $be, $12, $0b, $23, $2f, $4d, $0b, $83, $2f, $4d
	db $0b, $e3, $2f, $4d, $0b, $43, $3f, $4d, $0b, $a3, $3f, $4d, $0b, $03, $4f, $4d
	db $0b, $63, $4f, $4d, $0b, $c3, $4f, $4d, $0b, $23, $5f, $4d, $0b, $83, $5f, $4d
	db $0b, $e3, $5f, $4d, $0b, $43, $6f, $4d, $0b, $a3, $6f, $4d, $0b, $03, $7f, $4d
	db $0b, $63, $7f, $4d, $0b, $c3, $7f, $29

;@ path: battle/skillanim
;@ Sprite tiles of skill animation $2C (SkillAnimGfx entry $2C), unpacked to $8000 by BattleFrameLogic.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
SkillAnimSprites2C::
	db $00, $08, $02
	db $02, $ff, $f7, $01, $02, $0a, $01, $02, $ff, $f0, $40, $40, $f0, $70, $f8, $f8
	db $fc, $9c, $fe, $8c, $fe, $01, $03, $01, $1f, $1f, $3f, $3f, $7f, $1e, $7f, $00
	db $3f, $02, $ff, $f0, $84, $de, $04, $ce, $00, $8c, $00, $84, $00, $80, $02, $a0
	db $ff, $4d, $02, $99, $0f, $4d, $02, $f9, $0f, $4d, $02, $59, $1f, $4d, $02, $b9
	db $1f, $4d, $02, $19, $2f, $4d, $02, $79, $2f, $4d, $02, $d9, $2f, $4d, $02, $39
	db $3f, $4d, $02, $99, $3f, $4d, $02, $f9, $3f, $4d, $02, $59, $4f, $4d, $02, $b9
	db $4f, $4d, $02, $19, $5f, $4d, $02, $79, $5f, $4d, $02, $d9, $5f, $4d, $02, $39
	db $6f, $4d, $02, $99, $6f, $4d, $02, $f9, $6f, $4d, $02, $59, $7f, $4d, $02, $b9
	db $7f, $33

;@ path: event/cutscene
;@ Background tiles of cutscene 0 (night sky over the hill), unpacked to $9000 by InitCutscene0.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 816 bytes = 51 tiles, 2 bits per pixel.
Cutscene0Tiles::
	db $30, $03, $0a
	db $02, $fa, $09, $ee, $27, $f8, $49, $f6, $54, $f9, $3a, $ba, $3f, $ff, $34, $f5
	db $07, $07, $d3, $33, $fd, $05, $45, $b9, $af, $5b, $37, $b7, $87, $97, $07, $57
	db $b2, $4a, $c9, $2e, $a7, $78, $49, $f6, $d4, $79, $ba, $3a, $bf, $7f, $b4, $75
	db $07, $18, $d3, $34, $fd, $06, $45, $b8, $af, $5a, $35, $b4, $85, $96, $05, $56
	db $fd, $fd, $fa, $fb, $ea, $eb, $d0, $dd, $b4, $ba, $42, $44, $b8, $cd, $c3, $b8
	db $9f, $9f, $57, $d7, $0b, $bb, $2d, $5d, $42, $22, $1d, $b3, $c3, $1d, $c3, $1d
	db $00, $00, $80, $bf, $80, $80, $b5, $b5, $80, $80, $b6, $b6, $80, $80, $aa, $aa
	db $00, $00, $01, $ff, $01, $01, $b5, $b5, $01, $01, $ad, $ad, $01, $01, $d5, $d5
	db $80, $80, $ff, $ff, $da, $26, $d6, $2a, $fa, $06, $da, $26, $66, $96, $a1, $5d
	db $01, $01, $ff, $ff, $5e, $61, $36, $89, $1b, $a4, $0b, $b4, $65, $6a, $9d, $a2
	db $54, $54, $88, $ab, $21, $56, $f6, $01, $e4, $13, $ee, $00, $bd, $40, $d7, $28
	db $2a, $2a, $11, $d5, $84, $6a, $6f, $80, $27, $c8, $77, $00, $bd, $02, $eb, $14
	db $f2, $f2, $c9, $ce, $a7, $b8, $49, $76, $54, $79, $ba, $ba, $bf, $bf, $b4, $b5
	db $0f, $0f, $0a, $12, $0a, $ff, $0a, $e0, $0e, $99, $ff, $66, $ff, $66, $ff, $00
	db $ff, $42, $ff, $bd, $ff, $c3, $30, $f1, $a8, $ad, $28, $ac, $a8, $6a, $a4, $66
	db $34, $b6, $0e, $4e, $01, $f9, $07, $37, $07, $57, $05, $37, $07, $14, $05, $96
	db $2d, $bc, $73, $f0, $83, $bc, $f0, $31, $e8, $2d, $e8, $2c, $a8, $6a, $a4, $26
	db $34, $76, $0e, $ce, $01, $f9, $07, $34, $07, $54, $06, $35, $07, $14, $05, $94
	db $2c, $bf, $73, $f4, $83, $bc, $f7, $08, $bd, $42, $de, $21, $d6, $29, $fb, $04
	db $db, $24, $6e, $91, $ab, $54, $df, $20, $d9, $26, $fe, $01, $b6, $49, $db, $24
	db $eb, $14, $ed, $12, $7d, $82, $bd, $42, $ed, $12, $ff, $00, $b9, $46, $0a, $44
	db $10, $7b, $84, $6d, $92, $77, $88, $db, $24, $6a, $95, $ae, $51, $bf, $40, $ee
	db $11, $f7, $08, $b7, $48, $0a, $e0, $04, $f7, $0a, $e0, $0b, $f7, $0a, $88, $19
	db $ef, $ef, $d7, $c7, $ef, $ef, $0a, $9c, $18, $c7, $0a, $a9, $19, $0a, $96, $1c
	db $0a, $e0, $0c, $0a, $b6, $1e, $0a, $d8, $1f, $0d, $0a, $eb, $1f, $01, $fc, $ff
	db $e0, $0a, $e0, $03, $fe, $ff, $e0, $ff, $00, $0a, $39, $21, $0a, $e0, $02, $0a
	db $3a, $22, $00, $ff, $7f, $80, $0a, $34, $20, $fc, $ff, $f0, $ff, $e0, $ff, $c0
	db $ff, $81, $fe, $03, $fc, $80, $ff, $00, $ff, $01, $fe, $07, $f8, $1f, $e0, $7f
	db $0a, $60, $20, $00, $07, $f8, $3f, $c0, $0a, $45, $25, $00, $ff, $00, $0a, $52
	db $20, $fc, $ff, $f8, $ff, $f8, $ff, $f0, $0a, $89, $21, $07, $f8, $0f, $f0, $1f
	db $e0, $1f, $e0, $3f, $c0, $3f, $c0, $7f, $80, $0a, $6a, $22, $0a, $a0, $29, $0a
	db $41, $29, $fe, $01, $0a, $e0, $02, $7f, $ff, $07, $0a, $39, $29, $0a, $e0, $02
	db $3f, $ff, $07, $ff, $e0, $1f, $fc, $03, $0a, $74, $28, $01, $ff, $00, $ff, $80
	db $7f, $e0, $1f, $f8, $07, $fe, $0a, $f0, $20, $00, $0a, $c4, $20, $3f, $ff, $0f
	db $ff, $07, $ff, $03, $ff, $81, $7f, $c0, $3f, $e0, $1f, $f0, $0f, $f8, $07, $f8
	db $07, $fc, $03, $fc, $03, $fe, $01, $fe, $01, $0a, $02, $30, $3f, $ff, $1f, $ff
	db $1f, $ff, $0f, $0a, $29, $31

;@ path: event/cutscene
;@ Sprite tiles of a shooting star: unpacked to $8600 by InitCutscene0, to $8700 by InitShootingStars and to $8000 by OpeningInitStarScene.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 64 bytes = 4 tiles, 2 bits per pixel.
ShootingStarSprites::
	db $40, $00, $01
	db $01, $ff, $f1, $03, $00, $0f, $07, $18, $0e, $11, $0c, $13, $00, $0e, $00, $02
	db $00, $18, $00, $70, $00, $e0, $00, $e0, $00, $c0, $00, $80, $01, $ff, $f1, $18
	db $18, $24, $01, $24, $02, $10, $2c, $10, $08, $10, $08, $00, $10, $00, $10, $00
	db $00, $01, $34, $01, $00, $00, $00

;@ path: event/cutscene
;@ Sprite tiles of the sparkle a shooting star leaves: unpacked next to ShootingStarSprites by the same routines.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 48 bytes = 3 tiles, 2 bits per pixel.
SparkleSprites::
	db $30, $00, $01
	db $01, $ff, $f3, $18, $18, $24, $18, $24, $00, $18, $01, $ff, $f4, $08, $00, $1c
	db $00, $08, $01, $fa, $f9, $01, $1a, $04

;@ path: event/cutscene
;@ More tiles of cutscene 0 (sparkle and hill edge pieces), unpacked to $8670 by InitCutscene0.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 208 bytes = 13 tiles, 2 bits per pixel.
Cutscene0ExtraTiles::
	db $d0, $00, $02
	db $02, $ff, $f3, $18, $18, $24, $18, $24, $00, $18, $02, $fe, $f5, $08, $08, $14
	db $00, $08, $02, $fb, $f8, $02, $1b, $09, $02, $ff, $f2, $07, $00, $1f, $03, $7c
	db $02, $ff, $f3, $1f, $00, $ff, $07, $f8, $7f, $80, $ff, $00, $00, $01, $00, $03
	db $00, $07, $01, $0e, $03, $1c, $07, $38, $07, $78, $0f, $70, $0f, $f0, $3f, $c0
	db $ff, $00, $02, $64, $0f, $07, $02, $fe, $f5, $03, $00, $0f, $00, $1f, $01, $3e
	db $02, $38, $02, $02, $48, $00, $02, $62, $02, $00, $7f, $00, $ff, $0f, $f0, $02
	db $76, $0b, $02, $51, $01, $00, $07, $00, $0f, $01, $0e, $07, $78, $0f, $f0, $1f
	db $e0, $3f, $c0, $02, $4c, $00, $02, $7c, $00

;@ path: event/cutscene
;@ Background tiles of cutscenes 1 and 2, unpacked to $9000 by InitCutscene1 and InitCutscene2.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
Cutscene12Tiles::
	db $00, $08, $05
	db $fe, $05, $00, $01, $fc, $fd, $fc, $fe, $fc, $fc, $f8, $f8, $fb, $fb, $55, $55
	db $aa, $aa, $05, $10, $08, $ff, $ff, $ff, $ff, $7f, $7f, $3d, $3d, $90, $90, $e3
	db $e3, $05, $20, $00, $05, $22, $00, $7d, $7d, $21, $21, $85, $85, $8b, $8b, $05
	db $20, $00, $dd, $dd, $ee, $ee, $05, $40, $02, $ef, $ef, $f7, $f7, $f7, $f7, $05
	db $2c, $02, $05, $50, $06, $f0, $f0, $50, $50, $07, $07, $4f, $4f, $5f, $5f, $df
	db $df, $05, $20, $02, $b7, $b7, $ef, $ef, $d7, $d7, $05, $50, $04, $76, $76, $3e
	db $3e, $16, $16, $1b, $5b, $97, $d7, $8b, $8b, $8d, $ad, $cb, $cb, $7f, $7f, $7f
	db $ff, $05, $90, $00, $3f, $3f, $3f, $7f, $bf, $ff, $3f, $3f, $f5, $f5, $fa, $fa
	db $f5, $f5, $f0, $f0, $f1, $f9, $f2, $f2, $f3, $fb, $f6, $f6, $05, $50, $06, $bf
	db $bf, $dd, $dd, $eb, $eb, $e0, $e0, $e4, $e6, $e4, $e5, $e6, $e7, $e6, $05, $c8
	db $01, $e7, $e7, $7f, $05, $d0, $01, $3f, $3f, $3f, $bf, $3f, $bf, $1f, $9f, $1f
	db $df, $fb, $fb, $af, $af, $5d, $5d, $ab, $ab, $05, $18, $06, $fb, $fb, $05, $f0
	db $00, $ef, $ef, $fb, $fb, $f7, $f7, $fb, $fb, $c0, $c0, $c2, $c2, $ce, $ce, $8e
	db $8e, $9e, $9e, $1e, $1e, $0f, $0f, $07, $07, $f7, $f7, $73, $73, $78, $78, $7c
	db $7c, $3e, $3e, $5e, $5e, $2a, $2a, $94, $94, $ff, $ff, $9f, $9f, $3f, $3f, $fe
	db $fe, $78, $78, $18, $18, $00, $00, $02, $02, $05, $2c, $04, $df, $df, $e7, $e7
	db $70, $70, $7b, $7b, $ff, $ff, $de, $de, $e5, $e5, $ff, $ff, $ef, $ef, $9f, $9f
	db $37, $37, $f3, $f3, $7f, $7f, $05, $46, $10, $f7, $f7, $b8, $b8, $c7, $c7, $ff
	db $ff, $fe, $fe, $05, $b6, $02, $6f, $6f, $e7, $e7, $f0, $f0, $f0, $f0, $f8, $f8
	db $05, $f0, $00, $f9, $f9, $f4, $f4, $ea, $ea, $d4, $d4, $a8, $a8, $50, $50, $c7
	db $e7, $c7, $d7, $e7, $e7, $e3, $eb, $f3, $fb, $f8, $fa, $fc, $fd, $fe, $fe, $9f
	db $bf, $8f, $9f, $43, $4b, $b1, $b1, $cc, $cc, $e3, $e3, $67, $67, $37, $f7, $eb
	db $fb, $e5, $e5, $ca, $ca, $46, $46, $4e, $4e, $97, $97, $5f, $5f, $af, $af, $f3
	db $f3, $fb, $fb, $75, $75, $7b, $7b, $bd, $bd, $5e, $5e, $8e, $8e, $66, $66, $e3
	db $e3, $e3, $eb, $05, $c2, $10, $f3, $f3, $f1, $f5, $05, $ca, $10, $0f, $4f, $0f
	db $6f, $0f, $2f, $87, $a7, $87, $b7, $87, $87, $87, $97, $87, $a7, $05, $3c, $02
	db $ff, $ff, $7d, $7d, $05, $12, $02, $ed, $ed, $fb, $fb, $05, $f0, $10, $e6, $e6
	db $f5, $f5, $ea, $ea, $f5, $f5, $82, $82, $a0, $a0, $30, $30, $91, $91, $8e, $8e
	db $c0, $c0, $05, $6e, $10, $80, $80, $03, $03, $73, $73, $38, $38, $1c, $1c, $80
	db $80, $c0, $c0, $ff, $ff, $04, $04, $2f, $2f, $3f, $3f, $1f, $1f, $3f, $3f, $3f
	db $3f, $05, $20, $00, $19, $19, $08, $08, $80, $80, $40, $40, $bf, $bf, $3f, $3f
	db $05, $d0, $00, $f8, $f8, $08, $08, $0e, $0e, $10, $10, $8c, $8c, $c0, $c0, $f0
	db $f0, $ff, $ff, $fc, $fc, $08, $08, $23, $23, $e3, $e3, $83, $83, $0a, $0a, $3d
	db $3d, $05, $5c, $10, $7c, $7c, $02, $02, $66, $66, $3d, $3d, $99, $99, $c4, $c4
	db $f9, $f9, $00, $00, $03, $03, $5f, $5f, $2f, $2f, $97, $97, $af, $af, $d7, $d7
	db $ef, $ef, $d0, $d0, $88, $88, $05, $10, $08, $9b, $9b, $9d, $bd, $cf, $df, $e1
	db $e1, $05, $6c, $10, $05, $00, $00, $df, $df, $ef, $ef, $05, $2c, $02, $05, $28
	db $20, $5f, $5f, $87, $87, $a7, $a7, $d3, $d3, $a9, $a9, $d1, $d1, $f9, $f9, $f5
	db $f5, $f9, $f9, $05, $2c, $02, $fd, $05, $c6, $21, $f9, $f9, $f9, $f9, $05, $76
	db $00, $05, $4a, $02, $eb, $eb, $05, $d8, $20, $05, $40, $10, $dc, $dc, $b8, $b8
	db $b0, $b2, $31, $35, $23, $23, $63, $6b, $0f, $0f, $05, $26, $20, $05, $50, $10
	db $05, $2c, $02, $f1, $f5, $e0, $e0, $e0, $e4, $e0, $e2, $e0, $e4, $e0, $ea, $e0
	db $e4, $c0, $c8, $07, $07, $2f, $2f, $6b, $6b, $c7, $c7, $a3, $b3, $05, $fa, $00
	db $ee, $ee, $3b, $3b, $93, $93, $4b, $4b, $05, $12, $06, $f3, $f3, $f7, $f7, $e7
	db $e7, $e7, $e7, $ef, $ef, $05, $a2, $22, $b8, $05, $40, $31, $3c, $3c, $bc, $bc
	db $7e, $7e, $bf, $bf, $7f, $7f, $f3, $f3, $f9, $f9, $f1, $f1, $78, $78, $78, $78
	db $30, $30, $38, $38, $38, $38, $05, $b6, $02, $5f, $1f, $bf, $bf, $05, $50, $06
	db $fb, $fb, $f1, $f5, $05, $f2, $00, $05, $50, $03, $05, $4f, $0d, $05, $50, $04
	db $05, $a2, $20, $3a, $3a, $1c, $1c, $8a, $8a, $85, $85, $cb, $cb, $c1, $c1, $c9
	db $c9, $e1, $e1, $f5, $f5, $e9, $e9, $f1, $f1, $eb, $eb, $d3, $d3, $eb, $eb, $c7
	db $c7, $ef, $ef, $00, $00, $38, $00, $7c, $00, $fe, $28, $fe, $00, $fe, $44, $7c
	db $38, $38, $00, $05, $f2, $02, $05, $fc, $00, $05, $4e, $00, $f7, $f7, $c7, $d7
	db $c7, $c7, $05, $e0, $32, $05, $da, $10, $05, $e2, $30, $8f, $af, $8f, $8f, $0f
	db $4f, $1f, $9f, $1f, $1f, $3f, $bf, $3f, $3f, $c1, $d1, $83, $83, $83, $83, $87
	db $87, $07, $07, $0f, $0f, $0f, $0f, $17, $17, $05, $a0, $20, $de, $de, $be, $be
	db $5e, $5e, $bc, $bc, $7d, $7d, $bb, $bb, $f5, $f5, $eb, $eb, $fc, $fc, $f0, $f0
	db $21, $21, $8a, $8a, $05, $48, $00, $57, $57, $af, $af, $7f, $7f, $0f, $0f, $47
	db $47, $a7, $a7, $63, $63, $fb, $fb, $bf, $bf, $5f, $5f, $05, $40, $40, $9f, $9f
	db $df, $df, $cf, $cf, $cf, $cf, $3c, $3c, $3e, $3e, $3c, $3c, $ba, $ba, $be, $be
	db $bd, $bd, $bf, $bf, $05, $4c, $30, $05, $d2, $03, $3f, $1f, $1f, $1f, $1f, $0f
	db $0f, $05, $20, $00, $fe, $fe, $fc, $fc, $f9, $f9, $fa, $fa, $f9, $f9, $f2, $f2
	db $ff, $ff, $87, $87, $51, $51, $f9, $f9, $fc, $fc, $05, $00, $02, $05, $20, $00
	db $81, $81, $18, $18, $7e, $7e, $05, $f6, $22, $05, $52, $30, $f3, $f3, $e3, $e3
	db $e7, $e7, $05, $4c, $40, $9f, $9f, $05, $c0, $3c, $05, $c0, $3c, $f2, $f2, $05
	db $da, $22, $05, $fc, $00, $05, $c4, $20, $e7, $e7, $a3, $a3, $a3, $a3, $b3, $b3
	db $b1, $05, $e8, $41, $31, $31, $05, $72, $10, $f1, $f1, $f0, $f0, $f1, $f1, $ed
	db $ed, $c1, $c1, $d2, $d2, $2e, $2e, $0c, $0c, $18, $18, $b1, $b1, $82, $82, $85
	db $85, $8a, $aa, $8d, $8d, $77, $77, $05, $20, $00, $6f, $6f, $ef, $ef, $67, $67
	db $05, $36, $30, $05, $9a, $32, $05, $4a, $00, $e7, $e7, $05, $32, $30, $05, $c0
	db $3c, $c7, $c7, $c3, $c3, $e3, $05, $44, $51, $f3, $05, $4a, $51, $51, $51, $b1
	db $b1, $40, $40, $12, $12, $05, $10, $04, $8f, $8f, $8f, $8f, $cf, $cf, $05, $62
	db $56, $05, $c0, $3c, $05, $b8, $00, $bf, $bf, $97, $97, $9f, $9f, $cb, $cb, $c9
	db $c9, $ed, $ed, $05, $c0, $3c, $1f, $1f, $05, $22, $10, $05, $44, $42, $2f, $2f
	db $9f, $9f, $c3, $d3, $81, $89, $a1, $a5, $c1, $c9, $71, $75, $30, $32, $78, $78
	db $38, $3a, $05, $c0, $3c, $df, $05, $d0, $51, $05, $20, $00, $05, $4c, $40, $ff
	db $ff, $11, $15, $11, $11, $05, $e0, $54, $00, $02, $00, $04, $90, $90, $bc, $bc
	db $fa, $fa, $d4, $d4, $29, $29, $51, $51, $0f, $0f, $7f, $7f, $8a, $aa, $8c, $8c
	db $88, $a8, $88, $88, $89, $a9, $89, $89, $02, $42, $02, $22, $eb, $eb, $df, $df
	db $bb, $bb, $bf, $bf, $7b, $7b, $f7, $f7, $05, $30, $30, $f7, $f7, $05, $48, $50
	db $05, $22, $62, $f1, $f1, $e1, $e1, $05, $c0, $3c, $05, $30, $3c, $05, $6c, $36
	db $fb, $fb, $05, $a4, $40, $05, $64, $54, $c7, $c7, $a7, $a7, $c7, $c7, $c7, $c7
	db $05, $c0, $3c, $e5, $e5, $f5, $f5, $f1, $f1, $f1, $f1, $05, $78, $34, $05, $c0
	db $3c, $05, $ac, $50, $0f, $0f, $df, $df, $05, $7a, $20, $af, $af, $c7, $c7, $58
	db $58, $39, $39, $5c, $5c, $bc, $bc, $d8, $d8, $98, $98, $f9, $f9, $91, $91, $05
	db $c0, $3c, $ef, $ef, $e7, $e7, $67, $67, $73, $73, $73, $73, $39, $39, $19, $19
	db $9c, $9c, $00, $02, $80, $82, $80, $86, $80, $82, $c0, $c0, $90, $95, $c0, $c2
	db $60, $61, $05, $2c, $04, $05, $f6, $64, $04, $44, $01, $21, $01, $61, $01, $41
	db $03, $03, $09, $a9, $03, $43, $06, $86, $05, $34, $30, $05, $a8, $40, $8d, $8d
	db $9d, $9d, $89, $89, $19, $19, $05, $2c, $60, $f1, $f1, $e3, $e3, $d3, $d3, $e7
	db $e7, $d3, $d3, $e3, $e3, $3c, $3c, $7a, $7a, $05, $bc, $20, $f3, $fb, $f3, $f3
	db $f1, $f9, $f0, $f1, $05, $04, $00, $f9, $f9, $f1, $f3, $e3, $eb, $cf, $df, $1e
	db $1e, $3d, $3d, $65, $e5, $e5, $e5, $df, $df, $8f, $8f, $bc, $bd, $70, $76, $c1
	db $d1, $87, $87, $e7, $e7, $ef, $ff, $cf, $cf, $9f, $05, $39, $21, $05, $8c, $6f
	db $01, $05, $c0, $3c, $05, $d8, $20, $05, $b0, $10, $f3, $f3, $eb, $eb, $f1, $f1
	db $f9, $f9, $ee, $ee, $fe, $fe, $ee, $ee, $fc, $05, $a6, $70, $fd, $f8, $f9, $f8
	db $f9, $11, $31, $33, $73, $33, $b3, $63, $e3, $67, $05, $b8, $71, $05, $2e, $5e
	db $9c, $9c, $cc, $cc, $ec, $ec, $05, $02, $01, $fc, $fe, $fe, $bd, $bd, $10, $12
	db $08, $09, $34, $34, $2a, $2a, $14, $14, $3a, $3a, $bd, $bd, $5a, $5a, $05, $d0
	db $03, $bf, $3f, $7f, $3f, $bf, $1f, $5f, $9f, $9f

;@ path: event/cutscene
;@ Second half of the cutscene 1/2 tiles, unpacked to $8800.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 768 bytes = 48 tiles, 2 bits per pixel.
Cutscene12TilesHigh::
	db $00, $03, $02
	db $08, $48, $10, $90, $2c, $2c, $54, $54, $28, $28, $5c, $5c, $3c, $3c, $58, $58
	db $21, $21, $13, $13, $2b, $2b, $73, $73, $7b, $7b, $77, $77, $7b, $7b, $33, $33
	db $c3, $c3, $a3, $a3, $02, $20, $04, $43, $43, $a3, $a3, $f8, $fa, $f8, $f8, $f1
	db $f1, $e9, $e9, $e7, $e7, $ff, $02, $3a, $01, $7b, $7b, $f7, $f7, $fc, $fc, $b8
	db $b9, $d0, $d2, $a3, $a7, $47, $47, $8f, $8f, $9f, $9f, $3f, $bf, $3f, $3f, $7f
	db $7f, $02, $3a, $02, $ff, $ff, $f9, $f9, $fc, $fc, $fc, $fc, $fe, $fe, $fd, $fd
	db $fa, $fa, $fd, $fd, $f9, $f9, $ff, $ff, $c1, $c1, $88, $88, $35, $35, $7e, $7e
	db $fd, $fd, $fe, $fe, $02, $6e, $00, $ff, $ff, $7f, $7f, $3f, $3f, $bf, $bf, $1f
	db $1f, $c7, $c7, $67, $67, $ee, $ee, $fe, $fe, $ee, $ee, $02, $62, $00, $fc, $fd
	db $f8, $f9, $f8, $f9, $11, $31, $33, $73, $33, $b3, $63, $e3, $67, $02, $a8, $01
	db $e7, $e7, $02, $6a, $00, $02, $6a, $00, $02, $58, $06, $f1, $f1, $f3, $f3, $e3
	db $e3, $e7, $e7, $cf, $cf, $cf, $cf, $9e, $9e, $43, $43, $a7, $a7, $57, $57, $02
	db $d2, $00, $e7, $e7, $d7, $d7, $e7, $e7, $eb, $eb, $f7, $f7, $02, $e0, $00, $fb
	db $fb, $f1, $f1, $f9, $fb, $f1, $f1, $fb, $fb, $02, $68, $02, $02, $66, $00, $fc
	db $fe, $fc, $fe, $ff, $ff, $d7, $d7, $81, $81, $c3, $db, $18, $24, $99, $a5, $18
	db $24, $81, $bd, $02, $3a, $00, $eb, $eb, $81, $89, $c3, $d3, $02, $16, $12, $ea
	db $ea, $d0, $d0, $a0, $a7, $c0, $df, $05, $3a, $8f, $b0, $0a, $35, $80, $bf, $ab
	db $ab, $07, $07, $01, $e1, $03, $fb, $60, $9c, $f1, $0d, $a0, $5c, $01, $fd, $ff
	db $ff, $fa, $fa, $e0, $e0, $d0, $d0, $c0, $c5, $80, $8b, $c0, $c7, $80, $8b, $ff
	db $ff, $af, $af, $07, $07, $0b, $8b, $03, $d3, $01, $e9, $03, $f3, $01, $e9, $55
	db $55, $aa, $aa, $57, $57, $a9, $a9, $ff, $ff, $bf, $bf, $77, $77, $af, $af, $02
	db $60, $10, $df, $df, $76, $76, $df, $df, $ff, $ff, $dd, $dd, $7f, $7f, $55, $55
	db $ea, $ea, $b7, $b7, $7f, $7f, $02, $b6, $04, $55, $55, $a2, $a2, $54, $54, $ea
	db $ea, $bf, $bf, $fb, $fb, $02, $82, $00, $fb, $fb, $af, $af, $5d, $5d, $ab, $ab
	db $02, $60, $10, $02, $60, $10, $02, $3a, $00, $dd, $dd, $ff, $ff, $7d, $7d, $02
	db $aa, $12, $1e, $1e, $9c, $9d, $3c, $3d, $bc, $bc, $5c, $5e, $98, $98, $29, $29
	db $99, $99, $02, $c4, $00, $f3, $f3, $eb, $eb, $fb, $fb, $02, $d2, $10, $f7, $f7
	db $f1, $f3, $71, $75, $71, $73, $71, $75, $31, $33, $78, $7a, $bd, $bd, $5c, $5c
	db $02, $fc, $00, $f9, $fd, $fb, $fb, $f3, $f3, $a7, $a7, $47, $47, $0f, $0f, $00
	db $00, $02, $60, $10, $f7, $f7, $02, $58, $04, $d5, $d5, $02, $58, $04, $02, $3a
	db $02, $02, $00, $22, $d7, $d7, $7d, $7d, $02, $1a, $28, $f7, $f7, $de, $de, $02
	db $3a, $02, $40, $40, $02, $ae, $12, $02, $18, $26, $02, $42, $2a, $02, $60, $10
	db $00, $00, $a2, $a2, $02, $ac, $14, $02, $90, $10, $00, $00, $a8, $a8, $02, $60
	db $10, $f5, $f5, $ea, $ea, $02, $60, $10, $45, $45, $28, $28, $00, $00, $80, $80
	db $40, $40, $02, $76, $20, $a8, $a8, $45, $45, $00, $00, $14, $14, $00, $00, $05
	db $05, $02, $aa, $12, $55, $55, $0a, $0a, $11, $11, $82, $82, $02, $ac, $12, $02
	db $7e, $22, $02, $a8, $14, $58, $58, $39, $39, $5c, $5c, $bc, $bc, $d8, $d8, $98
	db $98, $f9, $f9, $91, $91, $f7, $f7, $e7, $e7, $e7, $e7, $ef, $02, $d6, $21, $02
	db $3a, $00, $ae, $ae, $df, $df, $cf, $cf, $e7, $e7, $e9, $e9, $f0, $f0, $e8, $e8
	db $f5, $f5, $3d, $3d, $ff, $ff, $02, $c8, $00, $df, $df, $3f, $3f, $3e, $3e, $7c
	db $7c

;@ path: event/cutscene
;@ Background tiles of cutscene 3, unpacked to $9000 by InitCutscene3.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
Cutscene3Tiles::
	db $00, $08, $13
	db $ff, $13, $ff, $fb, $13, $ef, $ff, $0e, $55, $00, $aa, $13, $30, $09, $00, $2a
	db $2a, $1c, $1c, $7f, $7f, $3e, $3e, $13, $46, $00, $55, $55, $15, $15, $5f, $5f
	db $bf, $bf, $7f, $7f, $ff, $ff, $7f, $7f, $aa, $aa, $55, $55, $54, $54, $f8, $f8
	db $fe, $fe, $fc, $fc, $ff, $ff, $fe, $fe, $ab, $ab, $54, $54, $13, $ff, $f7, $be
	db $00, $88, $00, $c0, $13, $ff, $f5, $77, $00, $47, $00, $0f, $13, $ff, $f1, $fd
	db $00, $fc, $13, $32, $01, $0a, $00, $84, $00, $e1, $00, $fe, $00, $fe, $00, $d5
	db $00, $68, $00, $02, $00, $11, $00, $7f, $13, $ff, $f1, $7e, $00, $35, $00, $4a
	db $00, $01, $00, $4f, $13, $ff, $f1, $df, $00, $de, $00, $c0, $00, $21, $00, $0a
	db $00, $02, $00, $15, $00, $22, $00, $bf, $00, $3f, $00, $66, $00, $f0, $00, $10
	db $00, $83, $00, $54, $00, $a2, $18, $18, $20, $20, $f5, $f5, $eb, $eb, $fe, $fe
	db $7f, $7f, $bf, $bf, $ef, $ef, $00, $42, $30, $30, $d8, $d8, $15, $15, $7b, $7b
	db $ff, $13, $fa, $01, $00, $c7, $00, $53, $00, $68, $00, $70, $00, $3e, $00, $5c
	db $01, $29, $02, $12, $00, $d5, $00, $8b, $00, $44, $01, $09, $81, $a1, $87, $87
	db $5f, $5f, $ff, $ff, $00, $fb, $00, $f7, $00, $a2, $80, $85, $40, $4a, $b8, $b8
	db $8f, $8f, $94, $94, $01, $17, $01, $4f, $81, $9d, $01, $3b, $01, $15, $41, $49
	db $c0, $c0, $60, $60, $00, $b7, $80, $b3, $80, $d0, $80, $a8, $c0, $d4, $a1, $a1
	db $d5, $d5, $6a, $6a, $00, $65, $00, $8a, $00, $15, $00, $aa, $01, $55, $43, $4b
	db $af, $af, $57, $57, $00, $ff, $00, $bf, $00, $4a, $00, $15, $00, $2a, $00, $85
	db $00, $50, $00, $23, $f0, $30, $f0, $30, $f8, $38, $f8, $18, $f8, $18, $fe, $1e
	db $fe, $0e, $ff, $07, $7f, $70, $7f, $78, $bf, $be, $4f, $4f, $33, $33, $1d, $1d
	db $98, $98, $48, $48, $13, $8f, $01, $02, $ef, $10, $ba, $45, $ef, $10, $de, $21
	db $6b, $94, $fe, $01, $13, $00, $00, $5d, $a2, $af, $50, $55, $aa, $2a, $d5, $15
	db $ea, $ff, $00, $d7, $28, $aa, $55, $d5, $2a, $aa, $55, $55, $aa, $a2, $5d, $01
	db $fe, $13, $00, $04, $bb, $44, $ff, $00, $13, $9c, $10, $ff, $1f, $fd, $1d, $fe
	db $1e, $fa, $1a, $fd, $1d, $fd, $1d, $13, $d0, $10, $86, $86, $8c, $8c, $86, $86
	db $c2, $c2, $42, $42, $42, $42, $60, $60, $20, $20, $08, $08, $14, $14, $0c, $0c
	db $04, $04, $0c, $0c, $14, $14, $0e, $0e, $06, $06, $4b, $4b, $b5, $b5, $da, $da
	db $ed, $ed, $d7, $d7, $13, $58, $00, $96, $96, $13, $56, $00, $af, $af, $d6, $d6
	db $ab, $ab, $44, $44, $81, $81, $40, $40, $ea, $eb, $d5, $d5, $fb, $fb, $ff, $ff
	db $75, $75, $ab, $ab, $51, $51, $00, $00, $10, $10, $0b, $2b, $87, $97, $42, $62
	db $41, $41, $ad, $ad, $7a, $7a, $25, $a5, $7d, $7d, $fb, $fb, $ad, $ad, $f7, $f7
	db $ab, $ab, $7d, $7d, $aa, $aa, $54, $54, $6b, $6b, $55, $55, $b7, $b7, $ef, $ef
	db $cf, $cf, $13, $56, $00, $f1, $f1, $04, $05, $92, $92, $eb, $eb, $f7, $f7, $5d
	db $5d, $ea, $ea, $d7, $d7, $ff, $bc, $ff, $03, $ff, $13, $a1, $11, $13, $00, $04
	db $e4, $e4, $fa, $fa, $f8, $78, $fe, $3e, $ff, $1f, $ff, $07, $13, $70, $20, $ba
	db $45, $fd, $02, $b6, $49, $fd, $02, $ee, $11, $13, $00, $02, $13, $b8, $10, $13
	db $b8, $10, $bb, $44, $df, $20, $7f, $80, $13, $9e, $22, $ba, $45, $13, $a2, $20
	db $7d, $82, $ef, $10, $fd, $02, $bd, $42, $57, $a8, $ae, $51, $13, $b2, $22, $eb
	db $14, $77, $88, $27, $cf, $44, $ad, $ed, $1d, $52, $a7, $b7, $4f, $6b, $9f, $a5
	db $5f, $fb, $0f, $b0, $b0, $90, $d8, $50, $f2, $18, $5d, $d0, $fa, $68, $f9, $38
	db $7e, $d8, $d8, $13, $fc, $10, $02, $02, $06, $46, $02, $82, $06, $56, $00, $20
	db $02, $82, $ff, $1f, $ff, $0f, $13, $02, $30, $fe, $0e, $fd, $0d, $fe, $0e, $ff
	db $1f, $fd, $fd, $7f, $7f, $ae, $ae, $5b, $5b, $bf, $bf, $4b, $4b, $b2, $b2, $16
	db $16, $7d, $7d, $da, $da, $be, $be, $7a, $7a, $bc, $bc, $18, $18, $58, $58, $34
	db $34, $01, $21, $02, $42, $29, $29, $d6, $d6, $ef, $6f, $ff, $1c, $13, $00, $00
	db $a6, $a6, $ff, $ff, $5d, $5d, $bf, $be, $ff, $fa, $ff, $70, $13, $00, $00, $c1
	db $c1, $c1, $c1, $e9, $e9, $e4, $e4, $e8, $68, $e4, $64, $f2, $72, $f4, $34, $ff
	db $80, $ff, $80, $ff, $c0, $13, $64, $32, $7f, $40, $ff, $e0, $13, $00, $01, $7e
	db $81, $91, $80, $ee, $00, $77, $13, $ff, $f0, $13, $00, $03, $87, $78, $58, $20
	db $a5, $00, $9f, $00, $ff, $13, $02, $32, $ff, $cf, $36, $36, $15, $95, $02, $cb
	db $00, $ef, $a8, $a8, $58, $58, $80, $80, $f0, $f0, $f8, $f8, $18, $18, $2c, $2c
	db $04, $84, $06, $c6, $03, $bb, $03, $f3, $03, $eb, $02, $f6, $01, $f9, $00, $f4
	db $00, $ff, $80, $80, $be, $be, $77, $77, $e9, $e9, $80, $88, $00, $26, $80, $dd
	db $00, $3f, $13, $fc, $f0, $80, $80, $c0, $c0, $c0, $c0, $20, $20, $18, $18, $08
	db $c8, $00, $fa, $00, $e9, $00, $c8, $00, $14, $00, $0a, $00, $54, $03, $23, $af
	db $af, $0c, $ec, $06, $e6, $06, $d6, $03, $e3, $02, $52, $06, $a6, $0e, $ee, $0d
	db $cd, $fe, $1e, $ff, $1f, $f7, $37, $fb, $3b, $fd, $fd, $fc, $fc, $f8, $f8, $78
	db $78, $8c, $8c, $c6, $c6, $8d, $8d, $86, $86, $47, $47, $a3, $a3, $71, $71, $99
	db $99, $10, $10, $28, $28, $00, $00, $08, $08, $02, $02, $10, $10, $02, $02, $02
	db $02, $04, $2c, $54, $54, $ab, $ab, $fe, $fe, $f5, $f5, $ff, $ff, $5f, $5f, $af
	db $af, $03, $03, $b7, $b7, $df, $df, $ba, $ba, $75, $75, $fa, $fa, $d6, $d6, $2a
	db $2a, $01, $11, $c3, $c3, $ff, $ff, $ad, $ad, $57, $56, $ef, $ee, $3f, $3e, $3f
	db $3e, $ff, $fe, $ff, $fc, $e7, $e6, $f7, $f6, $e9, $69, $f1, $31, $f8, $18, $fc
	db $0c, $13, $2e, $20, $13, $2e, $20, $08, $08, $18, $18, $13, $78, $40, $13, $0c
	db $30, $fb, $1b, $fd, $1d, $fb, $1b, $f5, $15, $fb, $1b, $f7, $37, $f8, $f8, $d0
	db $d0, $94, $94, $38, $38, $4c, $4c, $04, $04, $08, $08, $11, $11, $14, $14, $28
	db $28, $1c, $3d, $08, $8a, $13, $30, $04, $0e, $0e, $1f, $1f, $0c, $4d, $11, $bb
	db $00, $54, $13, $32, $03, $cf, $00, $87, $13, $66, $11, $84, $00, $12, $00, $04
	db $00, $a8, $13, $e0, $34, $01, $09, $01, $55, $13, $ec, $30, $87, $87, $ff, $ff
	db $fd, $fd, $d6, $d6, $bd, $bd, $d2, $d2, $a8, $a8, $40, $40, $07, $07, $17, $97
	db $1d, $5d, $0f, $8f, $1e, $1e, $ae, $ae, $f8, $f8, $80, $80, $28, $28, $13, $7a
	db $40, $13, $fc, $f0, $e0, $e0, $f0, $f0, $f0, $f0, $78, $78, $58, $58, $2c, $2c
	db $5e, $5e, $2e, $2e, $0e, $0e, $13, $fc, $10, $06, $06, $0e, $0e, $1e, $1e, $1c
	db $1c, $0a, $0a, $14, $14, $13, $28, $50, $5f, $5f, $a6, $a6, $4e, $4e, $24, $24
	db $4e, $4e, $04, $04, $13, $2c, $40, $34, $34, $5c, $5c, $ac, $ac, $58, $58, $ac
	db $ac, $13, $aa, $30, $18, $18, $5f, $5c, $3f, $3c, $13, $50, $50, $7f, $7c, $3f
	db $3c, $6f, $6e, $3f, $3e, $fe, $0e, $fe, $06, $13, $8a, $21, $13, $67, $53, $08
	db $08, $1c, $1c, $0c, $0c, $13, $72, $52, $13, $22, $50, $ee, $2e, $fc, $7c, $fc
	db $7c, $f8, $78, $f8, $f8, $f0, $f0, $f1, $f1, $e9, $e9, $22, $22, $10, $10, $33
	db $33, $63, $63, $a3, $a3, $e7, $e7, $a6, $a6, $c4, $c4, $00, $74, $00, $a8, $00
	db $50, $01, $a1, $00, $50, $02, $22, $06, $86, $0d, $0d, $13, $f9, $f3, $13, $05
	db $51, $00, $15, $00, $82, $13, $fb, $f1, $04, $00, $8a, $00, $10, $00, $42, $00
	db $15, $00, $8a, $08, $0c, $10, $37, $0c, $4e, $01, $35, $0e, $8f, $15, $3f, $0c
	db $6e, $03, $37, $11, $31, $00, $85, $11, $39, $03, $a7, $02, $53, $00, $aa, $02
	db $17, $02, $bf, $df, $dc, $97, $bc, $27, $7c, $2b, $bc, $2b, $7c, $34, $7b, $eb
	db $fc, $8c, $db, $dd, $dd, $eb, $eb, $fd, $7d, $fa, $7a, $f4, $34, $fe, $3e, $f6
	db $36, $fe, $1e, $0a, $0a, $16, $16, $0c, $0c, $16, $16, $2a, $2a, $14, $14, $3e
	db $3e, $13, $72, $52, $28, $28, $1c, $1c, $38, $38, $18, $18, $13, $24, $60, $13
	db $60, $31, $13, $63, $32, $e0, $ff, $e0, $ff, $f0, $2e, $2e, $1c, $1c, $13, $40
	db $60, $24, $24, $1c, $13, $4a, $61, $6f, $6e, $b7, $b6, $af, $ae, $9b, $9b, $cf
	db $cf, $85, $85, $43, $43, $a3, $a3, $13, $66, $51, $07, $fe, $06, $fc, $0c, $fc
	db $1c, $f8, $b8, $f0, $f0, $13, $22, $50, $0e, $0e, $1c, $1c, $13, $4c, $50, $2c
	db $2c, $1c, $1c, $d3, $d3, $f3, $f3, $e7, $e7, $ef, $6f, $ff, $7f, $fb, $7b, $f5
	db $75, $f2, $72, $88, $88, $80, $80, $13, $2e, $20, $10, $10, $18, $18, $18, $18
	db $13, $72, $40, $00, $00, $00, $01, $00, $08, $00, $04, $13, $ba, $51, $a2, $00
	db $55, $13, $ae, $61, $28, $00, $00, $00, $84, $00, $40, $00, $80, $00, $55, $00
	db $a8, $00, $45, $00, $08, $00, $40, $13, $fa, $f2, $01, $4d, $00, $9a, $10, $35
	db $08, $58, $10, $12, $10, $38, $00, $02, $00, $00, $42, $67, $05, $d7, $01, $7f
	db $42, $ef, $43, $73, $80, $c5, $40, $52, $80, $80, $d7, $fc, $5b, $de, $d5, $fe
	db $5e, $df, $6b, $ff, $95, $df, $e9, $ff, $df, $df, $07, $07, $06, $06, $05, $05
	db $02, $82, $01, $09, $03, $83, $01, $53, $02, $0a, $86, $86, $8e, $8e, $8c, $8c
	db $9c, $9c, $18, $18, $30, $39, $30, $72, $61, $69, $3f, $30, $7f, $70, $13, $20
	db $71, $38, $5f, $58, $3f, $38, $3f, $38, $7f, $70, $13, $22, $73, $13, $21, $73
	db $13, $78, $40, $13, $96, $60, $13, $96, $60, $13, $fc, $f0, $51, $51, $30, $30
	db $34, $34, $1a, $1a, $1e, $1e, $0f, $0f, $1f, $1f, $0f, $0f, $c2, $c2, $00, $00
	db $18, $18, $30, $30, $60, $60, $e0, $e0, $c1, $c1, $c3, $c3, $3c, $3c, $5c, $5c
	db $13, $70, $74, $bc, $bc, $5c, $5c, $f5, $75, $fb, $7b, $f7, $77, $f7, $77, $fe
	db $7e, $f6, $76, $fd, $fd, $fd, $fd, $14, $14, $20, $20, $44, $44, $40, $40, $84
	db $84, $08, $08, $0c, $0c, $08, $08, $13, $3c, $02, $13, $ae, $61, $13, $33, $01
	db $13, $f0, $10, $13, $78, $40, $13, $78, $62, $18, $18, $00, $58, $01, $21, $6a
	db $6a, $d5, $d5, $ef, $ef, $7f, $7f, $ff, $bf, $ff, $7f, $00, $0a, $00, $85, $40
	db $60, $f0, $f4, $f8, $d8, $fa, $ca, $fd, $8d, $ff, $07, $00, $aa, $00, $50, $00
	db $a4, $00, $00, $09, $09, $b7, $b7, $13, $1c, $10, $0f, $0f, $17, $17, $4d, $4d
	db $bb, $bb, $57, $57, $ff, $ff, $13, $60, $40

;@ path: event/cutscene
;@ Second half of the cutscene 3 tiles, unpacked to $8800.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 784 bytes = 49 tiles, 2 bits per pixel.
Cutscene3TilesHigh::
	db $10, $03, $09
	db $00, $85, $00, $28, $00, $01, $00, $04, $00, $01, $00, $00, $02, $02, $94, $94
	db $e1, $e5, $60, $69, $c3, $e3, $42, $47, $a1, $ab, $67, $67, $d7, $d7, $66, $66
	db $05, $05, $07, $07, $0e, $0e, $16, $16, $18, $18, $09, $fb, $f2, $86, $86, $08
	db $08, $01, $01, $47, $47, $2f, $2f, $5f, $5c, $bf, $b8, $7f, $70, $7f, $70, $ff
	db $e0, $ff, $c0, $ff, $80, $ff, $00, $09, $48, $02, $40, $40, $a0, $a0, $09, $50
	db $00, $60, $60, $20, $20, $30, $30, $30, $30, $db, $db, $ef, $ef, $f3, $f3, $4d
	db $4d, $cd, $cd, $66, $66, $c1, $c1, $62, $62, $ff, $01, $09, $70, $01, $03, $09
	db $76, $01, $07, $fe, $06, $fb, $fb, $de, $de, $fe, $fe, $fe, $fe, $fc, $fc, $d6
	db $d6, $fc, $fc, $f9, $f9, $18, $18, $18, $18, $38, $38, $30, $30, $72, $72, $62
	db $62, $f6, $f6, $e6, $e6, $00, $55, $00, $a2, $09, $fa, $f3, $a8, $00, $55, $00
	db $aa, $38, $38, $78, $78, $38, $38, $58, $58, $38, $38, $5c, $5c, $bc, $bc, $5c
	db $5c, $ff, $7f, $ff, $ff, $db, $da, $af, $ae, $5f, $5c, $2f, $2c, $07, $06, $0f
	db $0f, $09, $74, $01, $07, $fd, $0d, $f6, $16, $e1, $21, $e1, $e1, $c2, $c2, $ff
	db $ff, $f5, $f5, $7e, $7e, $e9, $e9, $c3, $c3, $8b, $8b, $2f, $2e, $7f, $78, $ff
	db $f8, $7f, $78, $bf, $b0, $7f, $60, $09, $44, $04, $06, $06, $0e, $0e, $0c, $0c
	db $1c, $1c, $18, $18, $09, $5c, $00, $60, $60, $3f, $38, $09, $10, $12, $2f, $28
	db $7f, $78, $6f, $68, $3f, $38, $0a, $0a, $35, $35, $2f, $2f, $5f, $5f, $4f, $4f
	db $df, $de, $df, $dc, $9f, $9c, $09, $42, $01, $09, $45, $07, $7f, $60, $7e, $61
	db $39, $36, $3c, $33, $a2, $b5, $00, $aa, $09, $ac, $02, $3c, $3c, $1c, $09, $54
	db $11, $0c, $09, $5a, $11, $62, $62, $73, $73, $53, $53, $21, $21, $13, $13, $31
	db $31, $22, $22, $21, $21, $09, $70, $0c, $f7, $f7, $ef, $ef, $d3, $d3, $eb, $eb
	db $d7, $d7, $a3, $a3, $e3, $e3, $e7, $e7, $de, $de, $ec, $ec, $d4, $d4, $8c, $8c
	db $84, $84, $c8, $c8, $c4, $c4, $cc, $cc, $80, $90, $18, $18, $98, $98, $9c, $9c
	db $8c, $8c, $ce, $ce, $c6, $c6, $63, $63, $fb, $fb, $ef, $ef, $47, $47, $67, $09
	db $b6, $11, $37, $37, $bf, $bf, $09, $f6, $f7, $82, $09, $ac, $00, $00, $00, $40
	db $40, $40, $40, $68, $68, $60, $60, $34, $34, $36, $36, $12, $12, $d0, $d0, $60
	db $60, $f0, $f0, $20, $20, $70, $70, $28, $28, $50, $50, $38, $38, $a3, $a3, $c3
	db $c3, $a3, $a3, $47, $47, $27, $27, $6f, $6f, $0f, $0e, $7f, $7e, $e0, $e0, $60
	db $60, $c0, $c0, $09, $54, $02, $09, $e0, $10, $2f, $2c, $77, $76, $5f, $5e, $37
	db $36, $8b, $8a, $cf, $cf, $87, $87, $c3, $c3, $58, $a7, $80, $7b, $00, $d5, $00
	db $aa, $09, $24, $21, $55, $00, $aa, $09, $48, $00, $dd, $22, $6e, $91, $00, $7f
	db $09, $4a, $12, $09, $20, $2c, $09, $5a, $10, $09, $90, $00, $10, $10, $10, $10
	db $09, $f5, $f8, $04, $04, $04, $04, $09, $04, $10, $09, $10, $1c, $2f, $28, $5f
	db $50, $3f, $70, $aa, $b5, $5f, $e0, $a5, $fa, $6f, $50, $b5, $ca, $fe, $81, $55
	db $aa, $ff, $80, $ea, $95, $fd, $02, $09, $48, $02, $63, $63, $33, $33, $13, $13
	db $03, $03, $11, $11, $09, $a6, $20, $02, $02, $cf, $cf, $cf, $cf, $c7, $c7, $c7
	db $c7, $cb, $cb, $c5, $c5, $42, $42, $a5, $a5, $ff, $80, $09, $c0, $21, $09, $33
	db $10, $c0, $ff, $e0, $7f, $60, $09, $cc, $11, $45, $00, $28, $00, $00, $00, $80
	db $00, $40, $09, $aa, $01, $a8, $00, $45, $09, $fc, $f1, $09, $05, $00, $92, $09
	db $cc, $11, $55, $00, $0a, $00, $11, $00, $02, $00, $01, $00, $09, $47, $05, $09
	db $48, $04

;@ path: title/opening
;@ Tiles of the third logo screen of the opening ("Enix presents"), unpacked to $9000 by OpeningInitLogo2.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 1280 bytes = 80 tiles, 2 bits per pixel.
OpeningLogo2Tiles::
	db $00, $05, $05
	db $05, $ff, $ff, $06, $03, $07, $08, $1f, $20, $3f, $40, $05, $ff, $f0, $07, $08
	db $3f, $40, $ff, $00, $05, $28, $00, $fe, $00, $00, $0f, $7f, $80, $05, $28, $02
	db $e0, $11, $80, $05, $ff, $f0, $80, $e0, $18, $fc, $02, $05, $28, $02, $3f, $40
	db $1f, $20, $05, $ff, $f3, $80, $80, $00, $80, $40, $80, $40, $c0, $05, $4f, $04
	db $05, $ff, $f2, $01, $01, $02, $05, $6c, $00, $07, $08, $0f, $10, $3f, $00, $05
	db $32, $04, $05, $28, $02, $fc, $02, $f8, $04, $f0, $08, $e0, $10, $f8, $00, $e0
	db $00, $80, $05, $1f, $01, $05, $ff, $ff, $03, $1f, $05, $af, $02, $20, $1f, $20
	db $3f, $00, $3f, $40, $7f, $80, $c0, $20, $05, $c0, $02, $80, $40, $88, $40, $88
	db $40, $08, $90, $05, $ff, $fb, $01, $03, $04, $05, $74, $00, $05, $b8, $00, $7f
	db $05, $79, $0b, $fe, $01, $fe, $00, $fc, $02, $05, $c6, $00, $80, $00, $00, $05
	db $3c, $01, $05, $ff, $ff, $02, $01, $01, $00, $03, $00, $07, $00, $0f, $00, $05
	db $1c, $00, $05, $32, $00, $fe, $01, $05, $88, $04, $80, $40, $01, $80, $10, $88
	db $10, $20, $30, $00, $20, $50, $60, $10, $60, $05, $bf, $01, $01, $00, $01, $02
	db $03, $00, $03, $04, $07, $00, $07, $08, $0f, $00, $0f, $10, $05, $7c, $08, $05
	db $84, $01, $05, $6f, $12, $02, $fe, $01, $05, $f8, $01, $01, $05, $d8, $05, $fc
	db $ff, $00, $00, $f0, $00, $00, $05, $72, $00, $1f, $20, $7e, $81, $f0, $0c, $00
	db $c0, $05, $ff, $f0, $fc, $02, $f0, $0c, $c0, $20, $05, $06, $13, $01, $01, $06
	db $01, $02, $05, $e0, $02, $1e, $21, $3e, $c0, $05, $88, $00, $05, $5a, $00, $00
	db $80, $05, $06, $1e, $1e, $1e, $37, $37, $63, $63, $7f, $7f, $0f, $10, $05, $b0
	db $00, $3f, $20, $fb, $f8, $7d, $7c, $7f, $66, $7f, $66, $05, $28, $01, $60, $ff
	db $60, $ff, $1e, $fd, $6c, $ff, $e7, $fb, $63, $05, $7c, $04, $7f, $63, $ff, $c7
	db $ff, $83, $7f, $03, $00, $80, $05, $5c, $00, $f0, $0c, $ef, $63, $f7, $f7, $5f
	db $1b, $ef, $0b, $05, $68, $02, $07, $38, $6f, $ff, $fd, $f9, $7f, $31, $ff, $3f
	db $07, $18, $1f, $60, $05, $32, $00, $bf, $38, $ff, $ed, $ff, $f3, $fb, $bf, $f8
	db $00, $f0, $00, $e0, $10, $c1, $21, $f7, $f7, $bb, $fb, $1b, $9b, $fb, $fb, $05
	db $ff, $f2, $06, $06, $ef, $ef, $76, $76, $36, $36, $36, $36, $05, $ff, $f4, $38
	db $38, $64, $64, $70, $70, $38, $38, $60, $60, $71, $71, $3f, $3f, $1e, $1e, $05
	db $ff, $f4, $05, $ec, $10, $7f, $66, $f7, $f7, $0f, $10, $07, $08, $07, $08, $03
	db $04, $fb, $63, $fd, $65, $fe, $6c, $fe, $fe, $05, $7c, $05, $83, $bf, $83, $ff
	db $c3, $ef, $e3, $ff, $03, $ff, $07, $05, $28, $00, $ef, $0b, $7f, $1b, $ff, $f3
	db $5f, $47, $ff, $00, $ff, $c0, $05, $28, $01, $30, $ff, $38, $ff, $1f, $fe, $8e
	db $05, $f8, $00, $f8, $04, $e0, $10, $ff, $1f, $ff, $8f, $ed, $fd, $f8, $78, $05
	db $9a, $12, $00, $00, $03, $03, $0b, $0b, $9b, $9b, $f7, $f7, $05, $ff, $f4, $05
	db $5c, $20, $37, $37, $bb, $bb, $05, $ff, $f4, $1c, $1c, $4c, $4c, $44, $44, $b8
	db $b8, $05, $65, $05, $02, $00, $05, $7f, $14, $05, $21, $00, $05, $47, $02, $c0
	db $0f, $30, $00, $03, $05, $ff, $f0, $05, $7c, $06, $00, $fc, $05, $ff, $f0, $3c
	db $05, $f7, $01, $f0, $0c, $80, $60, $05, $67, $03, $05, $93, $0b, $9c, $05, $ff
	db $fb, $70, $00, $e0, $05, $8c, $10, $05, $ff, $ff, $06, $e0, $00, $0f, $00, $0e
	db $00, $0c, $05, $93, $37, $ff, $05, $ff, $fb, $3c, $00, $3c, $00, $3e, $00, $36
	db $00, $33, $00, $33, $00, $31, $00, $30, $00, $01, $05, $bf, $35, $81, $00, $81
	db $00, $c1, $00, $8c, $05, $cf, $3b, $38, $00, $18, $00, $0c, $00, $0e, $00, $06
	db $00, $03, $00, $03, $05, $bf, $33, $03, $00, $06, $00, $0e, $00, $1c, $00, $b8
	db $00, $f8, $00, $c0, $05, $06, $1b, $0f, $05, $0f, $4b, $05, $70, $10, $05, $c5
	db $10, $05, $24, $44, $30, $05, $2f, $4b, $f9, $00, $79, $00, $7d, $00, $3d, $00
	db $3f, $05, $af, $01, $0f, $00, $8f, $05, $4f, $4b, $05, $48, $34, $05, $24, $10
	db $05, $f8, $30, $f8, $00, $fc, $00, $fe, $00, $fe, $00, $bf, $05, $4b, $41, $07
	db $05, $ff, $f7, $05, $c5, $10, $c0, $05, $7b, $4b, $05, $2c, $32, $05, $ff, $f8
	db $05, $30, $40, $05, $04, $4a, $05, $92, $4a, $8f, $00, $0f, $05, $ff, $f9, $38
	db $00, $70, $05, $ff, $f9, $07, $05, $28, $32, $05, $f6, $45

;@ path: title/opening
;@ Tiles of the title picture (the game's logo and its artwork), unpacked to $9000 by OpeningInitPicture and OpeningInitTitle.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 2048 bytes = 128 tiles, 2 bits per pixel.
TitlePictureTiles::
	db $00, $08, $0a
	db $ff, $0a, $ff, $ff, $08, $f8, $07, $f2, $0d, $0a, $00, $08, $7f, $80, $9f, $60
	db $0a, $00, $04, $fe, $01, $fd, $02, $fe, $01, $ff, $00, $e7, $18, $d1, $2e, $b8
	db $47, $7c, $83, $fc, $03, $f8, $07, $f7, $08, $6f, $90, $ff, $0f, $fe, $10, $38
	db $d0, $18, $f0, $0a, $56, $02, $98, $70, $ff, $1e, $fb, $93, $fb, $92, $fe, $94
	db $fd, $99, $b3, $d2, $df, $fc, $30, $3f, $ff, $1f, $ff, $20, $f0, $a0, $ff, $9f
	db $ff, $00, $ff, $7f, $ff, $80, $c0, $80, $ff, $f8, $ff, $04, $07, $04, $ff, $f8
	db $ff, $00, $ff, $fe, $fd, $01, $01, $01, $0a, $78, $04, $0a, $96, $00, $ff, $7f
	db $ff, $00, $ff, $3c, $f7, $e6, $b7, $25, $3d, $29, $3b, $33, $37, $36, $fb, $fa
	db $e3, $22, $ff, $00, $ff, $30, $ff, $4c, $cf, $82, $83, $81, $e1, $61, $f3, $12
	db $ff, $0c, $0a, $00, $01, $07, $fc, $08, $0a, $c6, $00, $f8, $10, $18, $90, $ff
	db $07, $ff, $0a, $c9, $00, $90, $f8, $90, $f0, $a0, $e1, $c1, $e3, $c2, $ff, $80
	db $ff, $ff, $fe, $0a, $fb, $f1, $f0, $f0, $f0, $10, $f0, $10, $ff, $00, $ff, $1f
	db $ff, $a0, $f0, $0a, $f5, $01, $fe, $9e, $fe, $82, $ff, $00, $ff, $fc, $fb, $02
	db $03, $0a, $05, $11, $3f, $3c, $3f, $20, $ff, $00, $ff, $3f, $ff, $40, $e0, $0a
	db $15, $11, $ff, $3f, $c7, $28, $0a, $00, $10, $f3, $0a, $05, $13, $87, $84, $87
	db $84, $ff, $3c, $fb, $42, $e3, $0a, $33, $12, $43, $0a, $16, $10, $f6, $09, $e9
	db $16, $d8, $27, $d0, $2f, $80, $7f, $80, $ff, $c0, $ff, $f0, $3f, $c7, $38, $00
	db $ff, $06, $f9, $07, $f8, $0f, $f0, $0f, $f0, $17, $e8, $3e, $c1, $0a, $28, $02
	db $3f, $c0, $bf, $40, $3f, $c0, $7f, $80, $ff, $00, $9f, $60, $df, $20, $ef, $10
	db $ee, $11, $f6, $09, $fb, $04, $fc, $03, $fe, $01, $98, $70, $98, $70, $38, $d0
	db $58, $b0, $0a, $82, $10, $78, $90, $78, $90, $3c, $0f, $0e, $03, $83, $81, $e1
	db $e1, $b2, $f3, $8f, $fc, $87, $f8, $83, $fc, $c0, $80, $7f, $ff, $06, $f9, $00
	db $ff, $03, $ff, $9f, $7c, $fc, $20, $f0, $20, $01, $01, $c3, $c2, $63, $c2, $c4
	db $87, $84, $07, $08, $0f, $16, $19, $63, $7c, $0a, $26, $04, $7f, $ff, $0a, $94
	db $02, $e3, $22, $f3, $0a, $d1, $12, $e2, $e2, $0a, $06, $10, $02, $fe, $01, $fc
	db $00, $f9, $02, $f5, $01, $eb, $02, $1c, $8c, $50, $30, $a0, $60, $31, $21, $e1
	db $41, $c3, $82, $83, $02, $07, $04, $0f, $08, $1e, $11, $66, $79, $ff, $3c, $0a
	db $00, $01, $03, $ff, $3c, $fe, $40, $60, $c0, $60, $c0, $f1, $21, $f1, $41, $e3
	db $83, $c3, $02, $87, $04, $08, $0f, $10, $1f, $60, $7f, $ff, $02, $0a, $20, $23
	db $7e, $0a, $94, $02, $3f, $20, $3e, $21, $3c, $20, $38, $22, $33, $3f, $03, $18
	db $00, $70, $00, $e0, $8f, $10, $1d, $23, $3b, $46, $07, $fc, $3e, $f8, $f8, $c0
	db $c0, $80, $c1, $81, $c7, $84, $c8, $0f, $88, $0f, $05, $06, $03, $02, $41, $41
	db $a1, $e1, $11, $f1, $e0, $40, $60, $c0, $63, $c3, $0a, $34, $13, $42, $e3, $42
	db $38, $0f, $0c, $07, $84, $87, $cd, $ce, $b9, $7e, $a0, $5f, $3a, $c5, $7b, $84
	db $3c, $c3, $39, $c6, $db, $24, $e3, $1c, $e7, $18, $ef, $10, $1f, $e0, $0a, $2e
	db $06, $0a, $00, $0f, $05, $38, $d0, $3f, $cf, $9f, $60, $dd, $22, $c9, $36, $e3
	db $1c, $f7, $08, $f7, $08, $83, $fc, $81, $7e, $80, $7f, $c0, $3f, $c0, $3f, $e0
	db $1f, $e0, $1f, $f0, $0f, $f1, $21, $fe, $1f, $f8, $07, $f0, $0f, $68, $97, $7f
	db $9f, $3f, $e0, $30, $e0, $83, $fc, $01, $fe, $0a, $ff, $f2, $ff, $ff, $ff, $00
	db $00, $00, $0a, $9a, $00, $04, $fb, $04, $fb, $0c, $f3, $13, $fc, $99, $ff, $df
	db $b6, $05, $04, $fa, $f9, $a8, $46, $d0, $05, $a0, $0b, $c0, $97, $8b, $27, $2f
	db $74, $41, $c1, $3e, $7f, $7e, $81, $7e, $81, $42, $bd, $42, $bd, $ff, $8f, $ff
	db $50, $82, $fd, $32, $cd, $0a, $22, $34, $0a, $e2, $00, $31, $e1, $1e, $0a, $02
	db $23, $07, $fc, $06, $fc, $96, $ec, $c0, $bf, $8c, $73, $0a, $42, $31, $f3, $cc
	db $73, $7f, $7f, $3e, $00, $c0, $81, $7e, $fd, $44, $b1, $08, $e2, $10, $c5, $20
	db $8b, $40, $17, $80, $2f, $00, $c0, $3f, $bf, $0a, $c5, $10, $0a, $66, $30, $8e
	db $71, $8f, $70, $c6, $87, $fc, $7f, $0a, $ff, $f0, $40, $bf, $7c, $83, $0a, $c8
	db $10, $c9, $39, $77, $8e, $3f, $c0, $1f, $e0, $7e, $f9, $6e, $cf, $ed, $c9, $f9
	db $51, $63, $c2, $be, $7d, $be, $41, $7e, $81, $7c, $83, $fd, $02, $fd, $02, $f9
	db $06, $77, $88, $0a, $bc, $20, $f7, $08, $0a, $88, $20, $ef, $10, $cf, $30, $f3
	db $0c, $fb, $04, $f9, $06, $0a, $9a, $30, $0a, $7c, $10, $fe, $01, $f0, $0f, $f0
	db $0f, $e0, $1f, $c0, $3f, $90, $6f, $68, $97, $dc, $23, $fc, $03, $30, $e0, $1e
	db $fe, $03, $fe, $1f, $fe, $3c, $e0, $30, $e0, $0a, $d0, $30, $00, $00, $3f, $3f
	db $2c, $33, $3f, $3f, $0f, $0a, $fb, $f1, $3f, $3f, $fe, $f0, $7f, $c0, $3f, $f1
	db $9f, $f6, $d9, $7f, $59, $76, $58, $67, $9f, $e0, $c6, $7c, $a6, $dc, $06, $fc
	db $8c, $f8, $ec, $98, $98, $70, $70, $a0, $e0, $c0, $58, $70, $58, $70, $4f, $7f
	db $40, $7f, $78, $47, $47, $78, $ff, $80, $ff, $81, $0a, $e6, $02, $11, $f1, $71
	db $a1, $71, $c1, $e3, $82, $c1, $01, $9c, $e8, $99, $f1, $b1, $e1, $e1, $21, $df
	db $3f, $1f, $ec, $ff, $03, $ff, $01, $01, $00, $02, $00, $84, $81, $f8, $62, $f8
	db $0c, $f8, $18, $f0, $10, $f9, $69, $01, $5e, $01, $be, $5f, $7f, $7f, $60, $b0
	db $e0, $b0, $e0, $f0, $a0, $ff, $1f, $1f, $e0, $07, $f8, $ff, $fe, $ff, $01, $0a
	db $67, $42, $ff, $fe, $0a, $98, $01, $ff, $00, $ff, $01, $ff, $03, $fe, $37, $cc
	db $1e, $e8, $73, $62, $6f, $6c, $bc, $bf, $87, $84, $8f, $08, $8f, $08, $1f, $10
	db $1c, $1b, $fb, $04, $f3, $0c, $77, $88, $87, $78, $c3, $3c, $b9, $46, $7c, $83
	db $fe, $01, $df, $20, $0a, $a0, $40, $9f, $60, $bf, $40, $0a, $68, $12, $0a, $3c
	db $00, $0a, $00, $08, $7e, $81, $0a, $65, $30, $3f, $c0, $b8, $47, $87, $78, $0a
	db $00, $00, $3f, $c2, $ff, $02, $f3, $0e, $0f, $f2, $ff, $0a, $b1, $43, $31, $2e
	db $3f, $3f, $1f, $00, $00, $00, $e0, $0a, $e8, $20, $0a, $03, $22, $1c, $fc, $0a
	db $f5, $01, $ff, $1f, $fe, $19, $fc, $33, $c1, $01, $03, $02, $07, $04, $1f, $1f
	db $7f, $60, $80, $ff, $82, $7d, $c6, $39, $ff, $06, $fe, $18, $f8, $10, $f8, $f0
	db $f8, $10, $0f, $ff, $39, $c6, $45, $ba, $80, $00, $00, $00, $18, $18, $3c, $3c
	db $fe, $c2, $01, $ff, $13, $ec, $94, $6b, $ff, $83, $7f, $5d, $3c, $20, $30, $20
	db $38, $30, $cf, $ff, $9f, $60, $04, $fb, $d9, $d9, $0a, $02, $56, $7b, $84, $42
	db $bd, $0a, $00, $03, $0a, $eb, $20, $ff, $c3, $3c, $24, $db, $fc, $03, $0a, $00
	db $01, $c0, $ff, $30, $3f, $c8, $9f, $64, $0f, $f6, $7c, $b0, $f0, $0a, $4b, $22
	db $86, $ff, $0a, $cb, $41, $0f, $0c, $03, $02, $c1, $c1, $e1, $21, $f1, $11, $fe
	db $0f, $0a, $00, $00, $fc, $03, $fb, $04, $f7, $08, $cf, $30, $0a, $6a, $12, $ff
	db $00, $f8, $27, $f8, $27, $e0, $3f, $e0, $27, $f0, $13, $f8, $18, $fc, $0c, $ff
	db $03, $ee, $11, $ba, $45, $92, $6d, $92, $6d, $00, $0a, $ec, $20, $00, $ff, $ff
	db $45, $ba, $0a, $c0, $50, $39, $c6, $0a, $b8, $54, $d3, $2c, $70, $8f, $34, $cb
	db $13, $ec, $0a, $b8, $54, $84, $7b, $44, $bb, $44, $bb, $84, $7b, $0a, $b8, $54
	db $42, $bd, $0a, $4c, $50, $7a, $85, $0a, $b8, $54, $23, $dc, $c0, $3f, $24, $db
	db $23, $dc, $0a, $b8, $54, $ff, $fc, $ff, $e0, $0a, $90, $2f, $0d, $0a, $20, $6f
	db $3a, $0a, $b1, $4b, $ff, $ff, $ff, $0e, $0a, $72, $6d, $03, $ff, $07, $ff, $0f
	db $ff, $1f, $ff, $3f, $0a, $9c, $01, $e0, $ff, $1c, $ff, $83, $ff, $0a, $4a, $10
	db $c0, $0a, $12, $65, $80, $ff, $60, $ff, $18, $ff, $06, $0a, $80, $67, $01, $ff
	db $01, $0a, $20, $21, $00, $ff, $07, $ff, $38, $ff, $c0, $0a, $34, $02, $ff, $30
	db $0a, $62, $53, $60, $ff, $70, $ff, $78, $ff, $7c, $ff, $fe, $ff, $7f, $ff, $3f
	db $ff, $0a, $6f, $00, $1f, $ff, $07, $0a, $3c, $40, $fd, $fa, $ff, $fc, $fd, $fe
	db $fe, $ff, $ff, $fe, $0a, $e9, $20, $ff, $ff, $5f, $a0, $f7, $08, $5e, $bd, $af
	db $5e, $5e, $af, $0f, $f7, $57, $af, $83, $ff, $ff, $8e, $ff, $51, $bf, $70, $5f
	db $b8, $bf, $58, $5d, $ae, $8e, $7d, $d7, $ae, $0a, $64, $52, $ff, $0c, $7f, $c2
	db $ff, $71, $bd, $7a, $7a, $0a, $4f, $54, $00, $ff, $3c, $ff, $62, $ff, $e1, $ff
	db $e1, $0a, $00, $09, $1c, $ff, $0a, $af, $00, $0a, $ff, $f8, $38, $0a, $74, $6b
	db $e2, $0a, $76, $69, $e6, $ff, $14, $0a, $7a, $65, $02, $ff, $e4, $ff, $1c, $fa
	db $0a, $1f, $00, $03, $ff, $04, $ff, $c8, $ff, $30, $ef, $72, $f6, $4f, $df, $ee
	db $ff, $e4, $fd, $16, $fe, $1d, $ff, $18, $5b, $bd, $f5, $1b, $bb, $75, $f7, $3b
	db $75, $fa, $fe, $71, $f5, $eb, $eb, $f5, $d7, $eb, $eb, $d7, $d7, $af, $af, $5f
	db $0a, $1a, $72, $ff, $fe, $0a, $e6, $71, $fc, $ff, $fc, $0a, $e0, $73, $7f, $0a
	db $00, $71, $1f, $ff, $1f

;@ path: title/opening
;@ Second half of the title picture tiles, unpacked to $8800.
;@ Compressed (format: DecompressCore): u16 unpacked length, marker byte, then the stream; unpacks to 1536 bytes = 96 tiles, 2 bits per pixel.
TitlePictureTilesHigh::
	db $00, $06, $05
	db $d7, $ab, $c1, $ff, $e1, $ff, $e0, $ff, $f0, $ff, $f0, $ff, $f8, $ff, $f8, $ff
	db $86, $ff, $e3, $de, $c3, $ff, $e1, $ff, $e1, $ff, $70, $ff, $70, $ff, $38, $ff
	db $bd, $5e, $1e, $fd, $ac, $5f, $02, $fd, $80, $ff, $80, $ff, $c6, $ff, $c7, $ff
	db $7f, $e0, $ea, $75, $77, $ea, $fa, $77, $f7, $fa, $73, $ff, $31, $ff, $31, $ff
	db $ff, $c1, $fe, $cd, $5d, $ee, $ef, $77, $77, $ef, $2e, $f7, $32, $ff, $13, $ff
	db $ff, $44, $ff, $83, $fb, $9d, $fd, $db, $db, $ed, $6c, $df, $4c, $ff, $24, $ff
	db $ff, $ee, $ff, $99, $ff, $99, $bd, $db, $db, $ad, $ad, $fb, $b5, $ef, $95, $ff
	db $ff, $31, $ff, $4a, $ff, $4a, $df, $6c, $ee, $55, $d5, $6f, $c5, $7f, $e1, $3f
	db $ff, $cd, $ff, $53, $ff, $52, $77, $ee, $ae, $75, $35, $ef, $4f, $fd, $49, $ff
	db $ff, $22, $ff, $14, $ff, $1d, $db, $bd, $bd, $db, $da, $bd, $b0, $ff, $32, $ff
	db $fb, $0d, $fd, $8b, $db, $bf, $b7, $db, $7a, $b5, $b0, $7f, $60, $ff, $24, $ff
	db $bf, $c8, $cb, $bd, $b5, $db, $53, $bd, $36, $eb, $62, $ff, $e2, $ff, $44, $ff
	db $ee, $9d, $bd, $de, $fa, $fd, $7d, $ba, $b0, $7f, $71, $ff, $61, $ff, $63, $ff
	db $b1, $6e, $64, $fb, $c1, $7e, $c0, $ff, $8c, $ff, $9c, $ff, $1c, $ff, $18, $ff
	db $7f, $bf, $7f, $ff, $7f, $bf, $3f, $ff, $3f, $ff, $7f, $05, $e9, $01, $05, $0b
	db $01, $f0, $ff, $e0, $ff, $c0, $ff, $80, $ff, $00, $ff, $80, $ff, $0f, $ff, $0f
	db $ff, $07, $ff, $07, $ff, $03, $ff, $03, $ff, $01, $ff, $01, $fc, $ff, $fe, $ff
	db $fe, $ff, $05, $10, $12, $05, $1b, $10, $38, $ff, $18, $ff, $18, $ff, $00, $05
	db $25, $15, $43, $ff, $63, $ff, $21, $ff, $21, $ff, $31, $ff, $30, $ff, $38, $ff
	db $7f, $ff, $18, $ff, $98, $ff, $89, $ff, $89, $ff, $c8, $ff, $c4, $05, $1b, $11
	db $13, $ff, $09, $ff, $88, $ff, $cc, $ff, $c7, $05, $1b, $11, $ff, $e0, $26, $ff
	db $26, $ff, $20, $ff, $71, $05, $1b, $10, $de, $05, $25, $10, $91, $ff, $91, $05
	db $62, $00, $ff, $ff, $fe, $05, $6a, $12, $e1, $3f, $e3, $05, $81, $11, $ff, $1e
	db $ff, $1e, $05, $25, $10, $05, $22, $10, $13, $ff, $33, $05, $59, $12, $0f, $ff
	db $00, $32, $ff, $05, $60, $10, $24, $ff, $cc, $05, $1b, $10, $7f, $ff, $00, $24
	db $ff, $4c, $ff, $4c, $ff, $c8, $ff, $99, $ff, $f9, $05, $1b, $11, $44, $ff, $c4
	db $ff, $8c, $ff, $88, $ff, $88, $ff, $18, $ff, $9c, $ff, $ff, $ff, $e3, $ff, $c6
	db $ff, $c6, $ff, $8c, $ff, $0c, $ff, $18, $ff, $38, $ff, $f1, $ff, $38, $ff, $30
	db $ff, $30, $ff, $61, $ff, $61, $ff, $e1, $ff, $c3, $ff, $c3, $05, $59, $12, $05
	db $59, $12, $05, $12, $12, $05, $28, $00, $05, $26, $16, $05, $26, $10, $01, $ff
	db $01, $05, $25, $17, $05, $ef, $16, $05, $ea, $00, $38, $83, $05, $f7, $12, $fc
	db $ff, $f8, $ff, $c0, $05, $1c, $23, $fe, $ff, $f0, $05, $25, $17, $fc, $ff, $e0
	db $ff, $01, $ff, $06, $ff, $09, $ff, $11, $05, $5a, $21, $05, $1d, $22, $00, $ff
	db $86, $ff, $ce, $ff, $fe, $ff, $b6, $05, $60, $25, $7c, $ff, $ee, $05, $d1, $11
	db $05, $61, $24, $e6, $ff, $e6, $ff, $f6, $ff, $d6, $05, $60, $25, $7b, $ff, $cc
	db $ff, $f0, $ff, $3c, $05, $60, $25, $ff, $ff, $cc, $ff, $cc, $ff, $cf, $05, $60
	db $25, $be, $ff, $33, $ff, $33, $ff, $be, $05, $14, $21, $fe, $ff, $01, $ff, $3c
	db $ff, $66, $ff, $78, $ff, $1e, $ff, $ff, $ff, $0e, $05, $fc, $01, $40, $ff, $20
	db $05, $da, $21, $05, $1b, $10, $3f, $ff, $03, $05, $25, $14, $87, $05, $23, $26
	db $1f, $05, $e6, $25, $03, $ff, $04, $ff, $07, $ff, $04, $ff, $04, $05, $25, $13
	db $1c, $ff, $92, $ff, $9c, $ff, $92, $ff, $92, $05, $25, $13, $44, $ff, $6c, $ff
	db $54, $ff, $54, $ff, $44, $05, $25, $13, $63, $ff, $92, $ff, $93, $ff, $92, $ff
	db $62, $05, $25, $13, $05, $d7, $20, $05, $d7, $20, $40, $05, $25, $13, $e3, $ff
	db $92, $ff, $e3, $ff, $82, $ff, $82, $05, $25, $13, $86, $ff, $49, $ff, $89, $ff
	db $49, $ff, $46, $05, $25, $13, $05, $0b, $30, $04, $ff, $24, $05, $23, $15, $f1
	db $ff, $82, $ff, $e2, $ff, $82, $ff, $f1, $05, $25, $13, $8e, $ff, $44, $ff, $04
	db $ff, $44, $ff, $84, $ff, $00, $ff, $0f, $ff, $10, $ff, $26, $ff, $28, $ff, $28
	db $ff, $26, $ff, $10, $05, $9c, $10, $05, $64, $31, $49, $ff, $42, $ff, $44, $ff
	db $8f, $05, $25, $11, $05, $71, $01, $05, $c4, $31, $31, $05, $25, $11, $8c, $ff
	db $52, $05, $d4, $33, $8c, $05, $4e, $21, $05, $e1, $30, $05, $f1, $02, $f0, $ff
	db $e0, $df, $11, $cf, $09, $cf, $08, $e7, $06, $e1, $01, $f0, $00, $fc, $05, $26
	db $10, $3c, $ff, $42, $ff, $b9, $ff, $a5, $05, $04, $41, $42, $05, $9e, $21, $10
	db $ff, $11, $05, $33, $11, $41, $ff, $41, $05, $25, $13, $c2, $ff, $22, $05, $24
	db $43, $05, $26, $12, $38, $ff, $24, $05, $34, $41, $24, $05, $25, $13, $e0, $ff
	db $90, $05, $46, $41, $e0, $05, $0e, $35, $20, $ff, $18, $ff, $04, $ff, $38, $05
	db $25, $13, $e4, $ff, $44, $05, $66, $41, $43, $05, $25, $13, $05, $19, $32, $92
	db $ff, $1c, $05, $25, $13, $21, $ff, $22, $05, $86, $41, $21, $05, $0e, $23, $81
	db $ff, $42, $05, $b8, $31, $05, $9d, $30, $05, $26, $10, $1e, $ff, $10, $ff, $1c
	db $ff, $10, $05, $8a, $12, $ff, $00, $ff, $48, $ff, $68, $ff, $58, $ff, $48, $ff
	db $48, $05, $25, $13, $05, $44, $10, $86, $05, $43, $11, $00, $ff, $b6, $05, $6e
	db $24, $05, $fc, $f0, $ff, $00, $ff, $ee, $ff, $7c, $05, $d4, $49, $de, $ff, $ce
	db $05, $d4, $49, $cc, $ff, $78, $05, $f4, $4b, $05, $af, $23, $05, $da, $43, $33
	db $ff, $b3, $05, $d4, $49, $66, $05, $9e, $21, $01, $fe, $fe, $05, $da, $42, $ef
	db $20, $cf, $40, $cf, $40, $9f, $80, $1f, $00, $3f, $05, $26, $11, $05, $4f, $5f
	db $4d, $05, $af, $5f, $3d

;@ path: data
;@ Unused space at the end of bank $5B (zero bytes).
Bank5BPadding::
	ds 363, $00
