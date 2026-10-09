INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $03c", ROMX[$4000], BANK[$3c]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_3C::
	db $3c

;@ path: gfx/palettes/attrmaps
;@ Entry table of bank $3C: the address of each compressed block (entry number = position), as DecompressSetup
;@ finds it for Decompress / DecompressVRAM (bank, entry).
FarTable_3C::
	dw AttrMap_00
	dw AttrMap_01
	dw AttrMap_02
	dw AttrMap_03
	dw AttrMap_04
	dw AttrMap_05
	dw AttrMap_06
	dw AttrMap_07
	dw AttrMap_08
	dw AttrMap_09
	dw AttrMap_0A
	dw AttrMap_0B
	dw AttrMap_0C
	dw AttrMap_0D
	dw AttrMap_0E
	dw AttrMap_0F
	dw AttrMap_10
	dw AttrMap_11
	dw AttrMap_12
	dw AttrMap_13
	dw AttrMap_14
	dw AttrMap_15
	dw AttrMap_16
	dw AttrMap_17
	dw AttrMap_18
	dw AttrMap_19
	dw AttrMap_1A
	dw AttrMap_1B
	dw AttrMap_1C
	dw AttrMap_1D
	dw AttrMap_1E
	dw AttrMap_1F
	dw AttrMap_20
	dw AttrMap_21
	dw AttrMap_22
	dw AttrMap_23
	dw AttrMap_24
	dw AttrMap_25
	dw AttrMap_26
	dw AttrMap_27
	dw AttrMap_28
	dw AttrMap_29
	dw AttrMap_2A
	dw AttrMap_2B
	dw AttrMap_2C
	dw AttrMap_2D
	dw AttrMap_2E
	dw AttrMap_2F
	dw AttrMap_30
	dw AttrMap_31
	dw AttrMap_32
	dw AttrMap_33
	dw AttrMap_34
	dw AttrMap_35
	dw AttrMap_36
	dw AttrMap_37
	dw AttrMap_38
	dw AttrMap_39
	dw AttrMap_3A
	dw AttrMap_3B
	dw AttrMap_3C
	dw AttrMap_3D
	dw AttrMap_3E
	dw AttrMap_3F
	dw AttrMap_40
	dw AttrMap_41
	dw AttrMap_42
	dw AttrMap_43
	dw AttrMap_44
	dw AttrMap_45
	dw AttrMap_46
	dw AttrMap_47
	dw AttrMap_48
	dw AttrMap_49
	dw AttrMap_4A
	dw AttrMap_4B
	dw AttrMap_4C
	dw AttrMap_4D
	dw AttrMap_4E
	dw AttrMap_4F
	dw AttrMap_50
	dw AttrMap_51
	dw AttrMap_52
	dw AttrMap_53
	dw AttrMap_54
	dw AttrMap_55
	dw AttrMap_56
	dw AttrMap_57
	dw AttrMap_58
	dw AttrMap_59
	dw AttrMap_5A
	dw AttrMap_5B
	dw AttrMap_5C
	dw AttrMap_5D
	dw AttrMap_5E
	dw AttrMap_5F
	dw AttrMap_60
	dw AttrMap_61
	dw AttrMap_62
	dw AttrMap_63
	dw AttrMap_64
	dw AttrMap_65
	dw AttrMap_66
	dw AttrMap_67
	dw AttrMap_68
	dw AttrMap_69
	dw AttrMap_6A
	dw AttrMap_6B
	dw AttrMap_6C
	dw AttrMap_6D
	dw AttrMap_6E
	dw AttrMap_6F
	dw AttrMap_70
	dw AttrMap_71
	dw AttrMap_72
	dw AttrMap_73
	dw AttrMap_74
	dw AttrMap_75
	dw AttrMap_76
	dw AttrMap_77
	dw AttrMap_78
	dw AttrMap_79
	dw AttrMap_7A
	dw AttrMap_7B
	dw AttrMap_7C
	dw AttrMap_7D
	dw AttrMap_7E
	dw AttrMap_7F
	dw AttrMap_80
	dw AttrMap_81
	dw AttrMap_82
	dw AttrMap_83
	dw AttrMap_84
	dw AttrMap_85
	dw AttrMap_86
	dw AttrMap_87
	dw AttrMap_88
	dw AttrMap_89
	dw AttrMap_8A
	dw AttrMap_8B
	dw AttrMap_8C
	dw AttrMap_8D
	dw AttrMap_8E
	dw AttrMap_8F
	dw AttrMap_90
	dw AttrMap_91
	dw AttrMap_92
	dw AttrMap_93
	dw AttrMap_94
	dw AttrMap_95
	dw AttrMap_96
	dw AttrMap_97
	dw AttrMap_98
	dw AttrMap_99
	dw AttrMap_9A
	dw AttrMap_9B
	dw AttrMap_9C
	dw AttrMap_9D
	dw AttrMap_9E
	dw AttrMap_9F
	dw AttrMap_A0
	dw AttrMap_A1
	dw AttrMap_A2
	dw AttrMap_A3
	dw AttrMap_A4
	dw AttrMap_A5
	dw AttrMap_A6
	dw AttrMap_A7
	dw AttrMap_A8
	dw AttrMap_A9
	dw AttrMap_AA
	dw AttrMap_AB
	dw AttrMap_AC
	dw AttrMap_AD
	dw AttrMap_AE
	dw AttrMap_AF
	dw AttrMap_B0
	dw AttrMap_B1
	dw AttrMap_B2
	dw AttrMap_B3
	dw AttrMap_B4
	dw AttrMap_B5
	dw AttrMap_B6
	dw AttrMap_B7
	dw AttrMap_B8
	dw AttrMap_B9
	dw AttrMap_BA
	dw AttrMap_BB
	dw AttrMap_BC
	dw AttrMap_BD
	dw AttrMap_BE
	dw AttrMap_BF
	dw AttrMap_C0
	dw AttrMap_C1
	dw AttrMap_C2
	dw AttrMap_C3
	dw AttrMap_C4
	dw AttrMap_C5
	dw AttrMap_C6
	dw AttrMap_C7
	dw AttrMap_C8
	dw AttrMap_C9
	dw AttrMap_CA
	dw AttrMap_CB
	dw AttrMap_CC
	dw AttrMap_CD
	dw AttrMap_CE
	dw AttrMap_CF
	dw AttrMap_D0
	dw AttrMap_D1
	dw AttrMap_D2
	dw AttrMap_D3
	dw AttrMap_D4
	dw AttrMap_D5
	dw AttrMap_D6
	dw AttrMap_D7
	dw AttrMap_D8
	dw AttrMap_D9
	dw AttrMap_DA
	dw AttrMap_DB
	dw AttrMap_DC
	dw AttrMap_DD
	dw AttrMap_DE
	dw AttrMap_DF
	dw AttrMap_E0
	dw AttrMap_E1
	dw AttrMap_E2
	dw AttrMap_E3
	dw AttrMap_E4
	dw AttrMap_E5
	dw AttrMap_E6
	dw AttrMap_E7
	dw AttrMap_E8
	dw AttrMap_E9
	dw AttrMap_EA
	dw AttrMap_EB
	dw AttrMap_EC
	dw AttrMap_ED
	dw AttrMap_EE

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $00 screen 0, map $0B screen 0, map $0E screen 0, map $11 screen 0, map $14 screen 0,
;@ map $15 screen 0, map $20 screen 0, map $21 screen 0, and 1 more (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3F packed).
AttrMap_00::
	db $00
	db $01, $01, $22, $01, $00, $05, $01, $fa, $f3, $11, $11, $01, $03, $0f, $1d, $11
	db $11, $01, $fc, $f1, $01, $fa, $f3, $00, $00, $01, $43, $0c, $01, $5a, $09, $01
	db $60, $0e, $01, $05, $03, $01, $79, $0f, $06, $23, $33, $33, $33, $32, $01, $97
	db $0f, $0f, $01, $62, $05, $01, $c2, $0b, $01, $01, $0c, $01, $01, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $00 screen 0 version 1, map $0B screen 0 version 1, map $0E screen 0 version 1, map
;@ $11 screen 0 version 1, map $14 screen 0 version 1, map $15 screen 0 version 1, map $20 screen 0 version 1,
;@ map $21 screen 0 version 1, and 1 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3F packed).
AttrMap_01::
	db $00, $01
	db $01, $22, $01, $00, $05, $01, $fa, $f3, $11, $11, $01, $03, $0f, $1d, $11, $11
	db $01, $fc, $f1, $01, $fa, $f3, $00, $00, $01, $43, $0c, $01, $5a, $09, $01, $60
	db $0e, $01, $05, $03, $01, $79, $0f, $06, $23, $33, $33, $33, $32, $01, $97, $0f
	db $0f, $01, $62, $05, $01, $c2, $0b, $01, $01, $0c, $01, $01, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $00 screen 0 version 2, map $0B screen 0 version 2, map $0E screen 0 version 2, map
;@ $11 screen 0 version 2, map $14 screen 0 version 2, map $15 screen 0 version 2, map $20 screen 0 version 2,
;@ map $21 screen 0 version 2, and 1 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3F packed).
AttrMap_02::
	db $00, $01, $01
	db $22, $01, $00, $05, $01, $fa, $f3, $11, $11, $01, $03, $0f, $1d, $11, $11, $01
	db $fc, $f1, $01, $fa, $f3, $00, $00, $01, $43, $0c, $01, $5a, $09, $01, $60, $0e
	db $01, $05, $03, $01, $79, $0f, $06, $23, $33, $33, $33, $32, $01, $97, $0f, $0f
	db $01, $62, $05, $01, $c2, $0b, $01, $01, $0c, $01, $01, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $00 screen 0 version 3, map $0B screen 0 version 3, map $0E screen 0 version 3, map
;@ $11 screen 0 version 3, map $14 screen 0 version 3, map $15 screen 0 version 3, map $20 screen 0 version 3,
;@ map $21 screen 0 version 3, and 1 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3F packed).
AttrMap_03::
	db $00, $01, $01, $22
	db $01, $00, $05, $01, $fa, $f3, $11, $11, $01, $03, $0f, $1d, $11, $11, $01, $fc
	db $f1, $01, $fa, $f3, $00, $00, $01, $43, $0c, $01, $5a, $09, $01, $60, $0e, $01
	db $05, $03, $01, $79, $0f, $06, $23, $33, $33, $33, $32, $01, $97, $0f, $0f, $01
	db $62, $05, $01, $c2, $0b, $01, $01, $0c, $01, $01, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $00 screen 1, map $00 screen 1 version 6, map $00 screen 1 version 7, map $00 screen
;@ 1 version 8, map $0B screen 1, map $0B screen 1 version 6, map $0B screen 1 version 7, map $0B screen 1
;@ version 8, and 28 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per
;@ byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3A packed).
AttrMap_04::
	db $00, $01, $01, $22, $01
	db $00, $05, $01, $fa, $f3, $11, $01, $11, $03, $01, $09, $0f, $15, $00, $33, $01
	db $11, $00, $33, $00, $01, $39, $0f, $27, $01, $82, $01, $01, $78, $0f, $07, $00
	db $00, $33, $33, $01, $9d, $03, $01, $9d, $0f, $00, $01, $fc, $f0, $01, $b4, $0f
	db $09, $01, $a0, $0f, $0d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $00 screen 1 version 1, map $00 screen 1 version 2, map $00 screen 1 version 3, map
;@ $00 screen 1 version 4, map $00 screen 1 version 5, map $0B screen 1 version 1, map $0B screen 1 version 2,
;@ map $0B screen 1 version 3, and 37 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3A packed).
AttrMap_05::
	db $00, $01, $01, $22, $01, $00, $05, $01, $fa, $f3, $11
	db $01, $11, $03, $01, $09, $0f, $15, $00, $33, $01, $11, $00, $33, $00, $01, $39
	db $0f, $27, $01, $82, $01, $01, $78, $0f, $07, $00, $00, $33, $33, $01, $9d, $03
	db $01, $9d, $0f, $00, $01, $fc, $f0, $01, $b4, $0f, $09, $01, $a0, $0f, $0d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $00 screen 5, map $00 screen 5 version 1, map $00 screen 5 version 2, map $00 screen
;@ 5 version 3, map $00 screen 5 version 4, map $0B screen 5, map $0B screen 5 version 1, map $0B screen 5
;@ version 2, and 37 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per
;@ byte. Compressed in the DecompressCore format ($100 bytes unpacked, $39 packed).
AttrMap_06::
	db $00
	db $01, $01, $22, $00, $00, $00, $33, $33, $01, $fd, $f3, $01, $fd, $ff, $4d, $01
	db $1d, $0f, $01, $11, $11, $11, $33, $33, $11, $11, $11, $01, $79, $0f, $06, $22
	db $01, $83, $00, $22, $01, $98, $0f, $07, $01, $82, $0f, $0c, $22, $22, $22, $33
	db $33, $01, $e0, $00, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $01 screen 0, map $01 screen 0 version 1, map $01 screen 0 version 2, map $01 screen
;@ 0 version 3, map $01 screen 0 version 4, map $6D screen 11, map $6D screen 11 version 1, map $6D screen 11
;@ version 2, and 2 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per
;@ byte. Compressed in the DecompressCore format ($100 bytes unpacked, $31 packed).
AttrMap_07::
	db $00, $01, $01, $11, $01, $00, $05, $01
	db $fa, $ff, $07, $21, $11, $12, $11, $11, $12, $01, $fa, $f2, $21, $11, $21, $12
	db $00, $21, $20, $00, $22, $20, $01, $c7, $ff, $26, $33, $01, $71, $01, $01, $69
	db $0f, $07, $01, $92, $0f, $4d, $01, $f2, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $01 screen 1, map $6D screen 12 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $2F packed).
AttrMap_08::
	db $00, $01, $01, $11, $01, $00, $02
	db $13, $33, $33, $01, $fa, $f9, $33, $01, $08, $04, $22, $11, $22, $01, $ff, $f0
	db $01, $17, $05, $01, $1c, $02, $01, $26, $0a, $00, $00, $13, $01, $37, $0b, $33
	db $01, $47, $0f, $4d, $01, $97, $0f, $36

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $01 screen 4, map $01 screen 4 version 1, map $01 screen 4 version 2, map $01 screen
;@ 4 version 3, map $6D screen 15, map $6D screen 15 version 1, map $6D screen 15 version 2, map $6D screen 15
;@ version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $F packed).
AttrMap_09::
	db $00, $01, $01, $01, $a0, $ff, $4d, $01
	db $5f, $0f, $4d, $01, $bf, $0f, $2d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $01 screen 5 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $1D packed).
AttrMap_0A::
	db $00, $01, $01, $01, $ff, $f2, $33, $33, $33
	db $33, $01, $fa, $ff, $09, $01, $05, $00, $01, $1a, $0f, $4d, $01, $7a, $0f, $4d
	db $01, $9a, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $01 screen 8, map $01 screen 8 version 1, map $01 screen 8 version 2
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $F packed).
AttrMap_0B::
	db $00, $01, $01, $01, $a0, $ff, $4d, $01, $5f, $0f, $4d, $01
	db $bf, $0f, $2d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $01 screen 9 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $23 packed).
AttrMap_0C::
	db $00, $01, $01, $01, $ff, $f3, $33, $33, $33, $01, $fa, $ff, $0a
	db $00, $01, $18, $0f, $0d, $00, $01, $39, $0f, $0d, $01, $68, $0f, $4d, $01, $19
	db $0b, $03, $01, $19, $0f, $14

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $01 screen 12, map $01 screen 12 version 1 (MapPaletteTable), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $F packed).
AttrMap_0D::
	db $00, $01, $01, $01, $a0, $ff, $4d, $01, $5f, $0f
	db $4d, $01, $bf, $0f, $2d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $01 screen 12 version 2, map $01 screen 12 version 3 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $F packed).
AttrMap_0E::
	db $00, $01, $01, $01, $a0, $ff, $4d, $01, $5f, $0f, $4d
	db $01, $bf, $0f, $2d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $01 screen 13 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $15 packed).
AttrMap_0F::
	db $00, $01, $01, $01, $ff, $f3, $33, $33, $33, $01, $fa, $ff
	db $4d, $01, $5a, $0f, $4d, $01, $9a, $0f, $23

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $01 screen 13 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $15 packed).
AttrMap_10::
	db $00, $01, $01, $01, $ff, $f3, $33
	db $33, $33, $01, $fa, $ff, $4d, $01, $5a, $0f, $4d, $01, $9a, $0f, $23

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $01 screen 13 version 2 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $15 packed).
AttrMap_11::
	db $00, $01
	db $01, $01, $ff, $f3, $33, $33, $33, $01, $fa, $ff, $4d, $01, $5a, $0f, $4d, $01
	db $9a, $0f, $23

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 0, map $02 screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $42 packed).
AttrMap_12::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $f8, $01, $fd, $f0
	db $01, $fa, $f4, $01, $fd, $f0, $22, $22, $22, $01, $f9, $f5, $01, $22, $0b, $01
	db $fb, $f1, $01, $36, $0f, $08, $01, $09, $03, $01, $f8, $f6, $01, $f2, $fa, $22
	db $20, $01, $72, $0f, $2b, $11, $10, $01, $62, $0f, $0b, $11, $01, $c0, $0b, $01
	db $07, $05, $01, $f8, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 1, map $02 screen 1 version 1, map $02 screen 1 version 2
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $1D packed).
AttrMap_13::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $03
	db $00, $01, $09, $02, $01, $19, $04, $01, $1f, $0e, $01, $40, $0f, $4d, $01, $a0
	db $0f, $4c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 2 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $2B packed).
AttrMap_14::
	db $00, $01, $02, $11, $02, $00, $05, $02, $fa, $ff, $03, $02, $fe, $f6
	db $02, $1a, $0f, $35, $01, $02, $13, $0b, $02, $ff, $f4, $02, $7a, $0f, $16, $02
	db $72, $03, $02, $f6, $fc, $02, $f3, $f9, $01, $02, $c8, $0f, $15

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 2 version 1, map $02 screen 2 version 2 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $3B packed).
AttrMap_15::
	db $00, $01, $02
	db $11, $02, $00, $05, $02, $fa, $ff, $03, $02, $fb, $f6, $02, $f5, $f8, $00, $00
	db $01, $02, $19, $08, $00, $22, $22, $02, $38, $0f, $0c, $02, $33, $01, $02, $5c
	db $0f, $08, $22, $02, $78, $0f, $0b, $02, $36, $0c, $02, $a6, $0f, $0f, $02, $18
	db $09, $02, $36, $00, $02, $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 4, map $02 screen 4 version 2 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $46 packed).
AttrMap_16::
	db $00, $01, $02, $11, $11, $11, $10, $02
	db $f4, $fb, $11, $02, $04, $0c, $02, $03, $08, $02, $02, $00, $02, $24, $0a, $22
	db $02, $33, $0d, $02, $f4, $f9, $00, $02, $52, $0b, $02, $51, $0c, $02, $71, $0f
	db $0e, $02, $2e, $01, $02, $13, $05, $02, $12, $00, $02, $10, $00, $02, $12, $04
	db $11, $11, $10, $01, $02, $b4, $0a, $02, $d0, $04, $02, $ca, $0f, $13

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 4 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $50 packed).
AttrMap_17::
	db $00, $01
	db $02, $11, $11, $11, $10, $02, $f4, $fb, $11, $02, $04, $0c, $02, $03, $08, $11
	db $11, $00, $01, $02, $24, $09, $10, $22, $00, $02, $34, $0f, $0a, $00, $22, $00
	db $02, $13, $08, $02, $60, $0d, $10, $02, $72, $0f, $02, $02, $03, $05, $02, $02
	db $00, $11, $10, $01, $11, $00, $01, $02, $2a, $05, $02, $0f, $01, $02, $12, $04
	db $11, $02, $a4, $00, $02, $b5, $09, $02, $d0, $04, $02, $ca, $0f, $13

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 5 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $43 packed).
AttrMap_18::
	db $00, $01
	db $02, $02, $a0, $ff, $4d, $02, $19, $0f, $06, $01, $02, $6a, $0f, $03, $10, $02
	db $71, $0b, $11, $02, $90, $04, $11, $02, $9a, $03, $02, $a9, $03, $02, $a8, $06
	db $10, $02, $8f, $02, $02, $a9, $05, $11, $01, $11, $00, $00, $01, $02, $b0, $04
	db $11, $02, $e0, $00, $10, $02, $e0, $00, $02, $da, $07, $02, $e0, $01, $02, $19
	db $02

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 5 version 1, map $02 screen 5 version 2 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $3F packed).
AttrMap_19::
	db $00, $01, $02, $02, $ff, $ff, $31, $22, $22, $22, $02, $37, $0f, $1f, $01
	db $02, $ff, $fb, $02, $79, $03, $10, $02, $81, $0b, $11, $02, $90, $04, $11, $02
	db $9a, $03, $02, $a9, $03, $02, $a8, $06, $10, $02, $8f, $02, $02, $a9, $05, $11
	db $01, $11, $00, $00, $01, $02, $b0, $04, $11, $02, $e0, $05, $02, $da, $0f, $03
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 6 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $60 packed).
AttrMap_1A::
	db $00, $01, $02, $02, $ff, $f3, $01, $11, $11, $02, $fa, $f9, $11, $02, $08, $07
	db $22, $02, $12, $02, $02, $1a, $0f, $06, $02, $11, $03, $02, $3a, $0f, $03, $10
	db $02, $41, $0b, $11, $02, $60, $01, $11, $02, $17, $05, $02, $70, $02, $10, $33
	db $02, $68, $0a, $02, $86, $0d, $02, $67, $06, $02, $09, $01, $10, $00, $00, $01
	db $02, $aa, $05, $11, $02, $27, $01, $02, $a9, $05, $11, $11, $00, $01, $11, $10
	db $02, $c8, $0b, $02, $c1, $01, $02, $72, $04, $10, $02, $76, $00, $02, $39, $03
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 6 version 1, map $02 screen 6 version 2 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $60 packed).
AttrMap_1B::
	db $00, $01, $02, $02, $ff, $f3, $01, $11, $11, $02, $fa, $f9, $11, $02, $08, $07
	db $33, $02, $12, $02, $02, $1a, $0f, $06, $02, $11, $03, $02, $3a, $0f, $03, $10
	db $02, $41, $0b, $11, $02, $60, $01, $11, $02, $17, $05, $02, $70, $02, $10, $33
	db $02, $68, $0a, $02, $86, $0d, $02, $67, $06, $02, $09, $01, $10, $00, $00, $01
	db $02, $aa, $05, $11, $02, $27, $01, $02, $a9, $05, $11, $11, $00, $01, $11, $10
	db $02, $c8, $0b, $02, $c1, $01, $02, $72, $04, $10, $02, $76, $00, $02, $39, $03
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 6 version 3, map $02 screen 6 version 4 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $58 packed).
AttrMap_1C::
	db $00, $01, $02, $02, $ff, $f3, $01, $11, $11, $02, $fa, $f9, $11, $02, $08, $07
	db $33, $02, $12, $02, $02, $1a, $0f, $06, $02, $11, $03, $02, $3a, $0f, $03, $10
	db $02, $41, $0b, $02, $09, $05, $02, $69, $04, $02, $60, $02, $22, $02, $78, $0f
	db $0c, $02, $67, $06, $02, $09, $04, $01, $02, $aa, $05, $02, $09, $02, $02, $b9
	db $05, $02, $08, $00, $11, $10, $02, $a8, $06, $11, $11, $02, $06, $01, $02, $d9
	db $07, $10, $02, $d0, $00, $02, $39, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $02 screen 6 version 5, map $02 screen 6 version 6, map $02 screen 6 version 7, map
;@ $02 screen 6 version 8 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per
;@ byte. Compressed in the DecompressCore format ($100 bytes unpacked, $54 packed).
AttrMap_1D::
	db $00, $01, $02, $02, $ff, $f3, $01, $11
	db $11, $02, $fa, $ff, $06, $33, $02, $ff, $f1, $02, $19, $0f, $07, $02, $ff, $f2
	db $02, $39, $0f, $04, $10, $02, $41, $0b, $02, $09, $05, $02, $69, $04, $02, $60
	db $02, $33, $02, $78, $0f, $0c, $02, $67, $06, $02, $09, $04, $01, $02, $aa, $05
	db $02, $09, $02, $02, $a9, $05, $02, $08, $00, $11, $10, $02, $c8, $0b, $02, $c1
	db $04, $02, $cf, $01, $10, $01, $02, $d0, $02, $02, $fb, $00

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $39 packed).
AttrMap_1E::
	db $00, $01, $01, $01
	db $ff, $ff, $01, $13, $31, $01, $ff, $fa, $33, $33, $01, $16, $0f, $09, $33, $00
	db $22, $22, $00, $01, $25, $07, $01, $42, $0b, $22, $01, $61, $03, $01, $59, $0f
	db $0d, $01, $68, $04, $01, $81, $0f, $1d, $01, $5f, $02, $01, $ff, $f8, $01, $c3
	db $0c, $01, $e2, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $38 packed).
AttrMap_1F::
	db $00, $01, $01, $01, $ff, $ff, $01, $13, $31, $01, $ff
	db $fa, $33, $33, $01, $16, $0f, $09, $33, $00, $22, $22, $01, $36, $0d, $01, $45
	db $06, $22, $01, $61, $03, $01, $59, $0f, $0d, $01, $45, $04, $01, $81, $0f, $1d
	db $01, $5f, $02, $01, $ff, $f8, $01, $c3, $0c, $01, $e2, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 0 version 2 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $30 packed).
AttrMap_20::
	db $00, $01, $01
	db $01, $ff, $ff, $21, $22, $22, $01, $ff, $f8, $33, $01, $33, $0f, $01, $01, $35
	db $06, $22, $01, $61, $03, $01, $59, $0f, $0d, $01, $35, $04, $01, $81, $0f, $1d
	db $01, $5f, $02, $01, $28, $0a, $01, $34, $0a, $01, $e2, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 0 version 3 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $30 packed).
AttrMap_21::
	db $00, $01, $01
	db $01, $ff, $ff, $21, $22, $22, $01, $26, $0f, $09, $22, $01, $33, $00, $01, $35
	db $06, $22, $01, $61, $03, $01, $59, $0f, $0d, $01, $35, $04, $01, $81, $0f, $1d
	db $01, $5f, $02, $01, $28, $0a, $01, $34, $0c, $01, $e4, $0f, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 1 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $39 packed).
AttrMap_22::
	db $00, $01, $01
	db $01, $ff, $ff, $01, $13, $31, $01, $ff, $fa, $33, $33, $01, $16, $0f, $09, $33
	db $00, $22, $22, $00, $01, $25, $07, $01, $42, $0b, $22, $01, $61, $03, $01, $59
	db $0f, $04, $01, $61, $04, $01, $78, $0f, $25, $01, $5e, $03, $01, $ff, $f8, $01
	db $c3, $0c, $01, $e2, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 1 version 1, map $03 screen 1 version 2 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $31 packed).
AttrMap_23::
	db $00, $01, $01, $01, $ff, $ff, $21, $22, $22, $01
	db $ff, $f8, $33, $01, $33, $00, $33, $01, $38, $0f, $06, $22, $01, $61, $03, $01
	db $59, $0f, $04, $01, $61, $04, $01, $78, $0f, $25, $01, $5e, $03, $01, $28, $0a
	db $01, $34, $0a, $01, $e2, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 1 version 3 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $2F packed).
AttrMap_24::
	db $00, $01, $01, $01, $ff, $ff, $21, $22, $22
	db $01, $26, $0d, $33, $01, $2a, $07, $01, $43, $0a, $22, $01, $61, $03, $01, $59
	db $0f, $04, $01, $61, $04, $01, $78, $0f, $25, $01, $5e, $03, $01, $28, $0a, $01
	db $34, $0c, $01, $e4, $0f, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 1 version 4 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $30 packed).
AttrMap_25::
	db $00, $01, $01, $01, $ff, $ff, $21, $22, $22, $01
	db $26, $0f, $09, $22, $01, $33, $00, $01, $35, $06, $22, $01, $61, $03, $01, $59
	db $0f, $04, $01, $61, $04, $01, $78, $0f, $25, $01, $5e, $03, $01, $28, $0a, $01
	db $34, $0c, $01, $e4, $0f, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 4 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $39 packed).
AttrMap_26::
	db $00, $01, $01, $01, $ff, $ff, $01, $13, $31, $01
	db $ff, $fa, $33, $33, $01, $16, $0f, $09, $33, $00, $22, $22, $00, $01, $25, $07
	db $01, $42, $0b, $22, $01, $61, $03, $01, $59, $0f, $0d, $01, $68, $04, $01, $81
	db $0f, $1d, $01, $5f, $02, $01, $ff, $f8, $01, $c3, $0c, $01, $e2, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 4 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $38 packed).
AttrMap_27::
	db $00
	db $01, $01, $01, $ff, $ff, $01, $13, $31, $01, $ff, $fa, $33, $33, $01, $16, $0f
	db $09, $33, $00, $22, $22, $01, $36, $0d, $01, $45, $06, $22, $01, $61, $03, $01
	db $59, $0f, $0d, $01, $45, $04, $01, $81, $0f, $1d, $01, $5f, $02, $01, $ff, $f8
	db $01, $c3, $0c, $01, $e2, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 4 version 2 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $39 packed).
AttrMap_28::
	db $00, $01, $01, $01, $ff, $ff, $01, $13, $31
	db $01, $ff, $fa, $33, $33, $01, $16, $0f, $0b, $22, $22, $01, $38, $09, $01, $43
	db $00, $01, $45, $06, $22, $01, $61, $03, $01, $59, $0f, $0d, $01, $45, $04, $01
	db $81, $0f, $1d, $01, $5f, $02, $01, $38, $0a, $01, $44, $0a, $01, $e2, $0f, $0a
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 4 version 3, map $03 screen 4 version 4 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $30 packed).
AttrMap_29::
	db $00, $01, $01, $01, $ff, $ff, $21, $22, $22, $01, $26, $0f, $09, $22, $01, $33
	db $00, $01, $35, $06, $22, $01, $61, $03, $01, $59, $0f, $0d, $01, $35, $04, $01
	db $81, $0f, $1d, $01, $5f, $02, $01, $28, $0a, $01, $34, $0c, $01, $e4, $0f, $08
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 5 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $39 packed).
AttrMap_2A::
	db $00, $01, $01, $01, $ff, $ff, $01, $13, $31, $01, $ff, $fa, $33, $33, $01, $16
	db $0f, $09, $33, $00, $22, $22, $00, $01, $25, $07, $01, $42, $0b, $22, $01, $61
	db $03, $01, $59, $0f, $04, $01, $61, $04, $01, $78, $0f, $25, $01, $5e, $03, $01
	db $ff, $f8, $01, $c3, $0c, $01, $e2, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $03 screen 5 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $30 packed).
AttrMap_2B::
	db $00, $01, $01, $01, $ff, $ff, $21
	db $22, $22, $01, $26, $0f, $09, $22, $01, $33, $00, $01, $35, $06, $22, $01, $61
	db $03, $01, $59, $0f, $04, $01, $61, $04, $01, $78, $0f, $25, $01, $5e, $03, $01
	db $28, $0a, $01, $34, $0c, $01, $e4, $0f, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $04 screen 0, map $04 screen 0 version 1, map $04 screen 0 version 2, map $04 screen
;@ 0 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $32 packed).
AttrMap_2C::
	db $00, $01, $01, $33, $01, $00, $05
	db $01, $fa, $ff, $4b, $11, $11, $01, $fa, $f9, $30, $01, $68, $0a, $01, $68, $04
	db $01, $fe, $f3, $01, $77, $05, $01, $fe, $f2, $01, $86, $06, $01, $fe, $f0, $30
	db $00, $01, $a4, $0b, $01, $a5, $07, $01, $be, $0f, $1f

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $04 screen 1, map $04 screen 1 version 1, map $04 screen 1 version 2
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $41 packed).
AttrMap_2D::
	db $00, $01, $01, $33, $01
	db $00, $05, $01, $fa, $ff, $06, $11, $01, $21, $01, $01, $09, $05, $30, $11, $11
	db $00, $11, $03, $01, $08, $05, $01, $33, $00, $00, $00, $11, $11, $01, $09, $03
	db $01, $32, $00, $00, $01, $45, $00, $03, $01, $fa, $f2, $01, $52, $01, $01, $5c
	db $07, $01, $60, $0c, $01, $7f, $0f, $4d, $01, $df, $0f, $0d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $04 screen 2, map $04 screen 2 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $59 packed).
AttrMap_2E::
	db $00, $01, $01, $33
	db $01, $00, $05, $01, $fa, $ff, $07, $11, $01, $24, $01, $01, $fa, $f5, $00, $01
	db $24, $0a, $30, $01, $29, $01, $33, $01, $39, $0f, $04, $11, $11, $01, $42, $02
	db $00, $01, $59, $05, $01, $68, $03, $01, $29, $03, $01, $6e, $01, $01, $75, $0b
	db $03, $01, $75, $09, $00, $00, $03, $01, $40, $04, $01, $7b, $04, $01, $96, $0a
	db $00, $11, $01, $6f, $00, $01, $94, $01, $01, $7a, $07, $01, $09, $03, $01, $ae
	db $05, $01, $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $04 screen 2 version 2, map $04 screen 2 version 3, map $04 screen 2 version 4
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $57 packed).
AttrMap_2F::
	db $00, $01, $01, $33, $01, $00, $05, $01, $fa, $ff, $07
	db $11, $01, $24, $01, $01, $fa, $f5, $00, $01, $24, $0a, $30, $01, $29, $01, $33
	db $01, $39, $0f, $04, $11, $11, $01, $42, $02, $00, $01, $59, $05, $01, $68, $03
	db $01, $29, $03, $01, $6e, $01, $01, $75, $0c, $33, $00, $33, $01, $78, $06, $01
	db $fd, $f0, $01, $47, $05, $01, $f7, $f5, $01, $a8, $0a, $11, $11, $00, $03, $01
	db $ba, $0b, $01, $09, $03, $01, $b2, $05, $01, $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $04 screen 4, map $04 screen 4 version 1, map $04 screen 4 version 2, map $04 screen
;@ 4 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $4C packed).
AttrMap_30::
	db $00, $01, $01, $33
	db $33, $30, $11, $01, $f4, $f9, $30, $00, $01, $03, $0b, $22, $01, $f3, $fa, $01
	db $21, $0d, $01, $f2, $fb, $01, $41, $0e, $01, $03, $0f, $0b, $01, $01, $01, $01
	db $22, $06, $01, $80, $0f, $00, $00, $11, $11, $01, $03, $06, $01, $a0, $0e, $01
	db $40, $01, $01, $a4, $05, $33, $33, $33, $33, $01, $c4, $0c, $01, $c1, $02, $01
	db $da, $08, $01, $d3, $00, $01, $f9, $02

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $04 screen 5, map $04 screen 5 version 1, map $04 screen 5 version 2
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $24 packed).
AttrMap_31::
	db $00, $01, $01, $01, $a0, $ff, $4d, $01
	db $47, $0f, $34, $11, $01, $98, $0f, $05, $11, $11, $01, $a7, $01, $01, $c0, $03
	db $01, $be, $0e, $01, $bd, $02, $01, $a7, $09, $01, $e3, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $04 screen 6, map $04 screen 6 version 1, map $04 screen 6 version 2, map $04 screen
;@ 6 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $3A packed).
AttrMap_32::
	db $00, $01, $01, $01
	db $ff, $f2, $11, $03, $33, $33, $01, $fa, $ff, $4d, $01, $3a, $0f, $26, $11, $11
	db $11, $00, $01, $97, $0c, $33, $01, $38, $04, $01, $a3, $00, $00, $01, $a6, $00
	db $01, $b9, $09, $33, $01, $b7, $05, $01, $3f, $00, $01, $c6, $00, $01, $38, $07
	db $01, $e5, $01, $01, $38, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $05 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3D packed).
AttrMap_33::
	db $00, $01, $01, $33, $01, $00, $05, $01, $fa, $ff
	db $04, $11, $11, $01, $fc, $f0, $11, $11, $01, $19, $0f, $05, $01, $f8, $f5, $01
	db $3a, $0f, $07, $01, $21, $01, $01, $59, $0f, $0d, $01, $42, $07, $01, $84, $0c
	db $01, $44, $0f, $0a, $11, $01, $21, $00, $11, $01, $27, $08, $01, $c3, $0a, $01
	db $01, $0f, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $05 screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $39 packed).
AttrMap_34::
	db $00, $01, $01, $33, $01, $00, $05, $01, $fa, $ff, $04, $11, $11
	db $01, $fc, $f0, $11, $11, $01, $19, $0f, $05, $01, $f8, $f5, $01, $3a, $0f, $07
	db $22, $22, $01, $56, $0f, $10, $01, $42, $07, $01, $84, $0c, $01, $44, $0f, $0a
	db $11, $01, $c1, $03, $01, $b9, $0f, $05, $01, $01, $0f, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $05 screen 1, map $05 screen 1 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $33 packed).
AttrMap_35::
	db $00, $01, $01, $33
	db $01, $00, $05, $01, $fa, $ff, $04, $01, $f8, $f5, $01, $1a, $0f, $07, $01, $08
	db $01, $01, $19, $07, $31, $13, $01, $26, $0a, $11, $11, $01, $56, $0f, $07, $01
	db $e0, $ff, $0e, $01, $21, $0f, $10, $01, $24, $0f, $0a, $01, $01, $0f, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $05 screen 2, map $05 screen 2 version 1, map $05 screen 2 version 2, map $05 screen
;@ 2 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $2C packed).
AttrMap_36::
	db $00
	db $01, $01, $33, $01, $00, $02, $11, $11, $33, $01, $fa, $ff, $04, $11, $01, $21
	db $03, $01, $19, $0f, $44, $01, $21, $04, $01, $78, $0f, $05, $01, $20, $04, $22
	db $01, $99, $0f, $25, $01, $e0, $05, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $06 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $43 packed).
AttrMap_37::
	db $00, $01, $01, $22, $01
	db $f1, $ff, $01, $33, $01, $f6, $f9, $33, $33, $01, $15, $0f, $09, $33, $01, $41
	db $02, $01, $38, $0f, $08, $01, $40, $01, $01, $58, $0f, $07, $22, $22, $22, $01
	db $63, $07, $22, $33, $22, $32, $23, $01, $85, $09, $01, $62, $02, $01, $98, $0f
	db $08, $01, $41, $09, $01, $c0, $0d, $01, $e0, $05, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $06 screen 1 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $42 packed).
AttrMap_38::
	db $00, $01
	db $02, $02, $ff, $ff, $20, $01, $11, $11, $10, $02, $ff, $f8, $11, $11, $02, $34
	db $09, $01, $02, $43, $0f, $1a, $33, $33, $33, $22, $33, $02, $84, $01, $02, $7a
	db $0f, $05, $22, $22, $02, $a0, $02, $02, $9a, $0f, $05, $02, $84, $00, $02, $83
	db $00, $02, $ba, $0f, $03, $22, $22, $02, $a2, $02, $22, $22, $02, $da, $0f, $03
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $06 screen 2 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3A packed).
AttrMap_39::
	db $00, $01, $01, $01, $ff, $f5, $22, $01, $ff, $f6, $33, $01, $05, $0c, $01, $14
	db $00, $01, $19, $0f, $06, $33, $33, $01, $34, $0f, $29, $01, $42, $00, $01, $80
	db $01, $01, $79, $0f, $09, $22, $01, $a5, $00, $01, $9a, $0f, $08, $01, $85, $0f
	db $08, $01, $a5, $01, $01, $a5, $07, $01, $e0, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $06 screen 13, map $07 screen 0 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $37 packed).
AttrMap_3A::
	db $00, $01, $01, $01, $ff, $ff
	db $22, $22, $01, $27, $0b, $22, $22, $01, $35, $08, $02, $01, $44, $00, $20, $01
	db $ff, $f6, $33, $01, $44, $00, $01, $35, $07, $01, $63, $02, $01, $58, $06, $01
	db $63, $02, $01, $35, $04, $20, $02, $01, $83, $0a, $01, $84, $02, $01, $97, $0f
	db $46

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $06 screen 14, map $07 screen 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $42 packed).
AttrMap_3B::
	db $00, $01, $01, $01, $ff, $ff, $2e, $22, $01, $41, $02, $01, $38, $0f, $06
	db $21, $12, $22, $22, $22, $21, $12, $01, $ff, $f4, $02, $11, $11, $22, $22, $22
	db $11, $11, $20, $02, $01, $3b, $03, $01, $71, $03, $01, $46, $04, $01, $80, $0d
	db $22, $22, $00, $11, $33, $01, $44, $06, $01, $a0, $0f, $00, $01, $41, $09, $01
	db $c0, $0f, $1d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $06 screen 14 version 1, map $07 screen 1 version 1 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $44 packed).
AttrMap_3C::
	db $00, $01, $01, $01, $ff, $ff, $2e, $22, $22, $22, $22, $11, $22
	db $22, $01, $38, $0f, $06, $21, $12, $22, $22, $22, $21, $12, $01, $ff, $f4, $02
	db $11, $11, $01, $42, $00, $11, $20, $02, $01, $3b, $03, $01, $71, $03, $01, $46
	db $04, $01, $80, $0d, $22, $22, $00, $11, $33, $01, $41, $00, $01, $9a, $0f, $06
	db $01, $c0, $03, $01, $ba, $0f, $23

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $06 screen 14 version 2, map $06 screen 14 version 3, map $07 screen 1 version 2, map
;@ $07 screen 1 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per
;@ byte. Compressed in the DecompressCore format ($100 bytes unpacked, $44 packed).
AttrMap_3D::
	db $00, $01, $01, $01, $ff, $ff, $2e, $21, $12
	db $22, $22, $11, $22, $22, $01, $ff, $f5, $11, $11, $01, $43, $0e, $22, $21, $12
	db $01, $ff, $f4, $02, $01, $61, $01, $11, $11, $20, $02, $01, $ff, $f2, $22, $22
	db $33, $01, $73, $01, $01, $46, $04, $01, $80, $0e, $22, $00, $11, $01, $82, $00
	db $01, $99, $0f, $07, $01, $c0, $03, $01, $ba, $0f, $23

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $06 screen 14 version 4, map $06 screen 14 version 5, map $06 screen 14 version 6,
;@ map $06 screen 14 version 7, map $07 screen 1 version 4, map $07 screen 1 version 5, map $07 screen 1 version
;@ 6, map $07 screen 1 version 7 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values
;@ per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $44 packed).
AttrMap_3E::
	db $00, $01, $01, $01, $ff
	db $ff, $2e, $21, $12, $22, $22, $11, $21, $12, $01, $ff, $f5, $11, $11, $22, $22
	db $11, $11, $11, $01, $48, $09, $22, $01, $56, $06, $02, $01, $61, $03, $20, $02
	db $01, $ff, $f2, $22, $22, $33, $22, $01, $80, $02, $01, $7a, $0f, $05, $22, $00
	db $11, $01, $82, $00, $01, $99, $0f, $07, $01, $c0, $03, $01, $ba, $0f, $23

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $06 screen 15, map $07 screen 2 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $36 packed).
AttrMap_3F::
	db $00
	db $01, $01, $01, $ff, $ff, $22, $22, $01, $ff, $f7, $11, $11, $00, $00, $22, $01
	db $35, $07, $01, $41, $0c, $01, $45, $00, $01, $45, $07, $22, $22, $22, $20, $02
	db $01, $65, $0a, $01, $80, $00, $01, $77, $0c, $20, $02, $01, $79, $0a, $01, $45
	db $05, $01, $a0, $0f, $3d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $07 screen 4, map $07 screen 4 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3D packed).
AttrMap_40::
	db $00, $01, $01, $00, $22, $01, $01, $04, $01, $fa, $ff
	db $05, $33, $01, $22, $02, $01, $19, $0f, $07, $01, $01, $01, $01, $38, $0f, $08
	db $21, $12, $22, $21, $12, $01, $28, $07, $11, $11, $22, $11, $11, $01, $68, $0f
	db $18, $01, $43, $0f, $0d, $01, $23, $0f, $0b, $01, $fd, $f1, $01, $f2, $fc, $01
	db $a0, $f6

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $07 screen 5 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $28 packed).
AttrMap_41::
	db $00, $01, $01, $22, $01, $00, $05, $01, $fa, $ff, $44, $11, $01, $61
	db $03, $01, $59, $05, $01, $fa, $f2, $01, $68, $07, $11, $00, $00, $11, $01, $77
	db $0f, $09, $01, $73, $0f, $2a, $01, $df, $0f, $0d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $07 screen 6 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $2E packed).
AttrMap_42::
	db $00, $01, $01, $22, $01, $00
	db $04, $01, $f9, $ff, $26, $33, $01, $42, $00, $01, $37, $0f, $0e, $11, $01, $59
	db $0f, $0b, $11, $01, $78, $0f, $07, $01, $00, $00, $11, $01, $97, $0f, $26, $01
	db $fc, $f1, $01, $f1, $fc, $01, $a0, $f7

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $08 screen 0, map $08 screen 0 version 1, map $08 screen 0 version 2, map $08 screen
;@ 0 version 3, map $08 screen 0 version 4, map $08 screen 0 version 5, map $08 screen 0 version 6, map $08
;@ screen 0 version 7, and 1 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit
;@ values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $37 packed).
AttrMap_43::
	db $00, $01, $01, $01, $a0, $ff, $4d, $01
	db $04, $00, $33, $33, $30, $01, $04, $08, $03, $33, $33, $33, $01, $58, $09, $32
	db $22, $23, $01, $66, $08, $01, $83, $0c, $03, $01, $94, $0c, $33, $11, $01, $65
	db $09, $01, $b3, $0f, $01, $01, $04, $0a, $11, $01, $04, $0b, $01, $e5, $07

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $09 screen 1, map $09 screen 1 version 1, map $09 screen 1 version 2
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $44 packed).
AttrMap_44::
	db $00
	db $01, $02, $01, $11, $11, $11, $11, $33, $11, $33, $33, $10, $02, $fa, $ff, $04
	db $00, $00, $00, $33, $02, $24, $00, $02, $19, $0a, $00, $00, $02, $29, $0f, $08
	db $02, $fb, $f1, $02, $49, $08, $33, $02, $56, $0f, $0c, $02, $55, $0c, $02, $85
	db $0f, $39, $11, $11, $11, $00, $02, $01, $00, $02, $09, $03, $02, $1d, $01, $02
	db $e9, $06, $00

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $09 screen 4, map $09 screen 4 version 1, map $09 screen 4 version 2
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $21 packed).
AttrMap_45::
	db $00, $01, $02, $02, $a0, $ff, $4d, $02, $43, $0f, $30, $01, $11
	db $02, $a4, $01, $02, $9a, $0f, $07, $33, $02, $95, $0b, $02, $c4, $0c, $02, $a4
	db $0b, $02, $f2, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $09 screen 5, map $09 screen 5 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3B packed).
AttrMap_46::
	db $00, $01, $02, $00, $00, $00, $01, $00, $10, $00, $00, $22
	db $02, $f9, $ff, $04, $01, $11, $33, $11, $00, $11, $33, $11, $22, $10, $02, $1a
	db $0f, $04, $02, $fb, $f4, $02, $39, $0f, $44, $11, $02, $91, $0f, $0c, $02, $fa
	db $f5, $02, $b9, $0f, $04, $11, $02, $e0, $04, $02, $b9, $0c, $02, $f8, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $0A screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $1B packed).
AttrMap_47::
	db $00
	db $01, $01, $01, $a0, $ff, $4d, $01, $5f, $0f, $4d, $01, $67, $03, $11, $11, $11
	db $01, $ba, $0f, $0b, $01, $b8, $0c, $01, $67, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $0A screen 1 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $1A packed).
AttrMap_48::
	db $00, $01, $01, $01, $a0, $ff
	db $4d, $01, $5f, $0f, $4d, $11, $11, $11, $11, $01, $b4, $0f, $09, $01, $bd, $00
	db $01, $d4, $0f, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $0A screen 10, map $0C screen 0 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $31 packed).
AttrMap_49::
	db $00, $01, $01, $01, $ff, $fd, $11, $11, $11, $01, $04, $0f
	db $1d, $01, $12, $09, $01, $41, $0c, $33, $33, $33, $33, $01, $55, $0f, $2d, $22
	db $01, $36, $0b, $01, $a5, $08, $22, $11, $11, $22, $01, $b5, $0f, $09, $00, $01
	db $13, $0a, $01, $e0, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $0A screen 14, map $0A screen 14 version 1, map $0C screen 4, map $0C screen 4
;@ version 1, map $0D screen 0, map $0D screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3F packed).
AttrMap_4A::
	db $00, $01, $02, $02, $ff, $ff, $00, $11, $02, $10, $03
	db $02, $0c, $04, $02, $13, $0f, $01, $02, $18, $08, $11, $11, $11, $22, $22, $33
	db $02, $39, $0f, $0a, $11, $22, $22, $02, $59, $0f, $08, $02, $7f, $03, $02, $3b
	db $05, $10, $01, $02, $86, $0a, $02, $41, $01, $02, $99, $0f, $25, $02, $0f, $04
	db $02, $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $0C screen 10, map $0D screen 6, map $0F screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $2F packed).
AttrMap_4B::
	db $00, $01, $01, $01, $ff, $fd, $02, $20, $22, $02, $20, $01
	db $06, $0f, $18, $11, $01, $41, $00, $01, $36, $0f, $0a, $01, $ff, $fa, $01, $61
	db $0c, $33, $11, $01, $60, $0a, $01, $81, $0f, $3d, $01, $3d, $01, $01, $06, $0a
	db $01, $e4, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $0C screen 14, map $0D screen 10, map $0F screen 4, map $10 screen 0, map $17 screen
;@ 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $46 packed).
AttrMap_4C::
	db $00, $01, $01, $01, $ff, $ff, $00, $11, $11, $00, $00, $11, $01
	db $09, $08, $01, $14, $0f, $00, $01, $18, $09, $11, $22, $22, $22, $22, $01, $39
	db $0f, $07, $33, $33, $33, $33, $01, $57, $0f, $07, $22, $01, $72, $0f, $0d, $22
	db $01, $63, $00, $01, $33, $06, $01, $a1, $0e, $01, $41, $00, $01, $b7, $0f, $07
	db $01, $10, $00, $01, $04, $0c, $01, $a0, $f7

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $0C screen 14 version 1, map $0D screen 10 version 1, map $0F screen 4 version 1, map
;@ $10 screen 0 version 1, map $17 screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $48 packed).
AttrMap_4D::
	db $00, $01, $01, $01, $ff, $ff, $00
	db $11, $11, $00, $00, $11, $01, $09, $08, $01, $14, $0f, $00, $01, $18, $09, $11
	db $22, $22, $22, $22, $01, $39, $0f, $07, $33, $33, $33, $33, $01, $57, $0f, $07
	db $22, $01, $72, $0f, $0d, $22, $01, $63, $00, $01, $33, $06, $01, $a1, $0e, $01
	db $41, $00, $11, $33, $01, $b9, $0f, $05, $01, $10, $00, $01, $04, $0c, $01, $a0
	db $f7

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $0F screen 10, map $10 screen 6, map $12 screen 0, map $17 screen 6
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $4B packed).
AttrMap_4E::
	db $00, $01, $01, $01, $ff, $fd, $11, $22, $11, $22, $01, $0f, $00, $01, $09
	db $0f, $05, $22, $11, $22, $11, $01, $2f, $00, $01, $09, $06, $22, $22, $11, $11
	db $11, $01, $38, $06, $01, $51, $03, $01, $49, $0f, $07, $22, $01, $71, $01, $01
	db $69, $0f, $06, $01, $31, $00, $01, $32, $01, $01, $6b, $05, $01, $92, $01, $01
	db $49, $0f, $17, $01, $53, $0b, $01, $db, $09, $01, $df, $0d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $0F screen 14, map $0F screen 14 version 1, map $10 screen 10, map $10 screen 10
;@ version 1, map $12 screen 4, map $12 screen 4 version 1, map $17 screen 10, map $17 screen 10 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $28 packed).
AttrMap_4F::
	db $00, $01, $01, $01
	db $ff, $ff, $30, $11, $11, $11, $11, $01, $37, $0f, $07, $01, $46, $01, $11, $01
	db $60, $02, $01, $5d, $0f, $02, $01, $81, $03, $01, $79, $0f, $45, $01, $5d, $05
	db $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $13 screen 0, map $13 screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $53 packed).
AttrMap_50::
	db $00, $01, $01, $01, $ff, $fd, $22, $11, $11, $22, $22, $11
	db $22, $11, $01, $09, $0f, $05, $01, $13, $01, $22, $22, $22, $01, $09, $06, $01
	db $14, $01, $01, $38, $05, $11, $01, $51, $03, $01, $49, $0f, $05, $01, $15, $00
	db $11, $01, $16, $09, $01, $73, $0a, $01, $34, $00, $01, $74, $00, $01, $09, $05
	db $01, $71, $01, $01, $37, $06, $01, $51, $0c, $33, $01, $b2, $0f, $0c, $01, $2c
	db $02, $01, $ff, $fb, $01, $e6, $06

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $13 screen 6, map $13 screen 6 version 3, map $16 screen 0, map $16 screen 0 version
;@ 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $1A packed).
AttrMap_51::
	db $00, $01, $01, $01, $ff, $ff, $20, $11, $01
	db $26, $0a, $11, $01, $33, $0f, $4d, $01, $73, $0f, $2b, $01, $31, $0c, $01, $e1
	db $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $13 screen 6 version 1, map $13 screen 6 version 2, map $13 screen 6 version 4, map
;@ $13 screen 6 version 5, map $16 screen 0 version 1, map $16 screen 0 version 2, map $16 screen 0 version 4,
;@ map $16 screen 0 version 5 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values
;@ per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $1F packed).
AttrMap_52::
	db $00, $01, $01, $01, $ff, $ff, $20, $11, $01, $26, $0a, $11, $01, $33, $0f
	db $4d, $01, $53, $0f, $0b, $33, $01, $b2, $0f, $0c, $01, $31, $0c, $01, $e1, $0b
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $16 screen 14, map $18 screen 0 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $19 packed).
AttrMap_53::
	db $00, $01, $01, $22, $22, $20, $22, $22, $22, $02, $22, $22, $22, $01, $fa, $ff
	db $4d, $01, $5a, $0f, $4d, $01, $9a, $0f, $23

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $18 screen 4 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $38 packed).
AttrMap_54::
	db $00, $01, $01, $00, $00, $00, $22
	db $22, $22, $01, $f8, $f7, $11, $01, $02, $01, $11, $11, $01, $09, $0f, $16, $22
	db $01, $42, $00, $01, $17, $06, $01, $42, $01, $01, $03, $07, $01, $51, $0f, $12
	db $11, $11, $01, $78, $0f, $0b, $01, $56, $0f, $1d, $01, $03, $0a, $01, $e3, $0f
	db $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $18 screen 4 version 1, map $18 screen 4 version 2 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $3A packed).
AttrMap_55::
	db $00, $01, $01, $00, $00, $00, $22, $22, $22, $01, $f8, $f7, $11, $01, $02
	db $01, $11, $11, $01, $09, $0f, $16, $22, $01, $42, $00, $01, $17, $06, $01, $42
	db $01, $01, $03, $07, $01, $51, $0f, $12, $11, $11, $01, $78, $0f, $0b, $01, $56
	db $0f, $09, $33, $01, $b3, $0f, $0b, $01, $e0, $0f, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $19 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $21 packed).
AttrMap_56::
	db $00, $01, $01, $01, $ff
	db $ff, $2e, $11, $11, $11, $01, $34, $0f, $2b, $33, $22, $01, $74, $0f, $0b, $01
	db $43, $0a, $01, $a0, $0e, $01, $32, $0c, $01, $c2, $0f, $1b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $19 screen 4, map $1A screen 0 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $25 packed).
AttrMap_57::
	db $00, $01, $01, $01
	db $ff, $ff, $30, $11, $11, $11, $01, $36, $0f, $2b, $33, $22, $01, $76, $0f, $08
	db $11, $01, $a1, $00, $01, $96, $0f, $28, $01, $40, $00, $01, $34, $0c, $01, $a0
	db $f7

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $19 screen 8, map $19 screen 8 version 1, map $19 screen 8 version 2, map $1A screen
;@ 4, map $1A screen 4 version 1, map $1A screen 4 version 2, map $1B screen 0, map $1B screen 0 version 1, and 1
;@ more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in
;@ the DecompressCore format ($100 bytes unpacked, $2F packed).
AttrMap_58::
	db $00, $01, $01, $00, $22, $22, $11, $11, $11, $11, $22, $22, $01, $f9, $ff
	db $45, $01, $03, $00, $01, $03, $00, $01, $f9, $f4, $13, $33, $01, $72, $01, $31
	db $01, $69, $0f, $45, $01, $61, $0c, $01, $5e, $01, $01, $f3, $fa, $01, $e4, $08
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $1A screen 12, map $1A screen 12 version 1, map $1B screen 8, map $1B screen 8
;@ version 1, map $1C screen 0, map $1C screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $31 packed).
AttrMap_59::
	db $00, $01, $01, $00, $33, $01, $01, $03, $01, $f9, $ff, $08, $11, $11, $01, $16
	db $0f, $2b, $22, $22, $01, $06, $08, $22, $01, $72, $01, $01, $68, $0f, $17, $01
	db $62, $0c, $01, $a2, $0f, $1c, $00, $00, $00, $22, $22, $01, $f3, $fa, $01, $e4
	db $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $1B screen 14, map $1C screen 6, map $1D screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $4C packed).
AttrMap_5A::
	db $00, $01, $01, $01, $ff, $ff, $01, $22, $22, $22, $01, $07, $0f, $0a, $01
	db $ff, $fb, $11, $01, $43, $00, $01, $38, $0f, $07, $11, $11, $33, $33, $33, $01
	db $46, $07, $01, $62, $0b, $11, $11, $03, $33, $01, $82, $00, $01, $79, $07, $30
	db $01, $92, $00, $01, $5a, $08, $01, $a2, $00, $01, $99, $0f, $07, $01, $c1, $02
	db $01, $b9, $0f, $05, $01, $3f, $01, $01, $34, $0c, $01, $a0, $f6

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $1C screen 10, map $1C screen 10 version 1, map $1D screen 4, map $1D screen 4
;@ version 1, map $1E screen 0, map $1E screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3A packed).
AttrMap_5B::
	db $00, $01, $01
	db $01, $ff, $ff, $01, $11, $11, $01, $06, $0c, $33, $01, $ff, $f8, $33, $01, $24
	db $0e, $01, $25, $09, $01, $43, $0b, $33, $01, $62, $01, $01, $15, $06, $01, $62
	db $0b, $11, $11, $01, $73, $0f, $0d, $01, $a1, $02, $01, $99, $0f, $25, $01, $10
	db $01, $01, $05, $0c, $01, $a0, $f6

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $1D screen 10, map $1D screen 10 version 1, map $1D screen 10 version 2, map $1E
;@ screen 6, map $1E screen 6 version 1, map $1E screen 6 version 2, map $1F screen 0, map $1F screen 0 version
;@ 1, and 1 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $60 packed).
AttrMap_5C::
	db $00, $01, $02, $00, $00, $03, $33, $33, $33
	db $33, $30, $02, $f8, $f7, $11, $11, $11, $11, $02, $07, $06, $03, $33, $02, $13
	db $00, $02, $06, $06, $02, $12, $01, $02, $15, $06, $03, $33, $11, $10, $01, $33
	db $22, $02, $26, $05, $03, $11, $02, $42, $02, $02, $16, $04, $03, $11, $22, $22
	db $00, $00, $22, $22, $02, $58, $0f, $06, $02, $62, $00, $02, $64, $00, $02, $79
	db $0f, $06, $02, $fc, $f2, $02, $98, $0f, $07, $33, $02, $b3, $0f, $0b, $02, $03
	db $00, $02, $03, $07, $02, $e0, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $1E screen 14, map $1E screen 14 version 1, map $1F screen 8, map $1F screen 8
;@ version 1, map $23 screen 0, map $23 screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3A packed).
AttrMap_5D::
	db $00, $01, $01, $01, $ff, $fd, $02, $20, $22
	db $01, $11, $01, $01, $09, $0f, $05, $01, $ff, $fc, $11, $01, $41, $02, $33, $01
	db $39, $0f, $06, $01, $32, $0c, $01, $62, $0f, $1d, $11, $00, $01, $a2, $02, $01
	db $9a, $0f, $06, $01, $41, $02, $01, $b9, $0f, $05, $01, $9b, $05, $01, $da, $0f
	db $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $1F screen 14, map $1F screen 14 version 1, map $1F screen 14 version 2, map $1F
;@ screen 14 version 3, map $23 screen 6, map $23 screen 6 version 1, map $23 screen 6 version 2, map $23 screen
;@ 6 version 3, and 4 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per
;@ byte. Compressed in the DecompressCore format ($100 bytes unpacked, $35 packed).
AttrMap_5E::
	db $00, $01, $01, $01, $ff, $ff, $2f, $33, $01, $33, $0f, $0c, $22, $01, $5e
	db $05, $01, $5c, $0f, $03, $11, $22, $01, $82, $00, $01, $78, $0f, $07, $01, $62
	db $00, $22, $11, $01, $98, $0f, $07, $01, $42, $00, $01, $a7, $07, $01, $c1, $0d
	db $01, $63, $0b, $01, $e1, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $24 screen 10, map $24 screen 10 version 1, map $24 screen 10 version 2, map $24
;@ screen 10 version 3, map $25 screen 0, map $25 screen 0 version 1, map $25 screen 0 version 2, map $25 screen
;@ 0 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $2C packed).
AttrMap_5F::
	db $00, $01, $01, $01, $ff, $ff, $11, $22, $33, $22
	db $33, $22, $01, $19, $0f, $09, $01, $44, $00, $01, $39, $0f, $25, $11, $11, $11
	db $01, $74, $0c, $12, $22, $22, $22, $21, $01, $79, $05, $01, $ff, $fb, $01, $a1
	db $0f, $3c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $25 screen 10, map $25 screen 10 version 1, map $25 screen 10 version 2, map $25
;@ screen 10 version 3, map $26 screen 0, map $26 screen 0 version 1, map $26 screen 0 version 2, map $26 screen
;@ 0 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $48 packed).
AttrMap_60::
	db $00, $01, $01, $01, $ff, $ff, $10, $22, $01, $21, $01, $01, $19, $0f
	db $06, $11, $00, $11, $11, $00, $11, $01, $ff, $f6, $33, $01, $43, $00, $33, $01
	db $48, $07, $33, $11, $11, $33, $01, $57, $0f, $07, $11, $33, $11, $11, $11, $11
	db $33, $01, $47, $05, $11, $01, $62, $02, $01, $88, $0f, $17, $01, $c1, $03, $01
	db $b9, $0f, $05, $01, $3b, $05, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $26 screen 10, map $26 screen 10 version 1, map $26 screen 10 version 2, map $27
;@ screen 0, map $27 screen 0 version 1, map $27 screen 0 version 2 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3A packed).
AttrMap_61::
	db $00, $01, $01, $01, $ff, $ff
	db $2e, $11, $11, $11, $01, $3f, $03, $01, $3b, $0f, $04, $33, $01, $43, $00, $01
	db $62, $00, $01, $5b, $0f, $04, $01, $42, $0f, $0d, $01, $a1, $03, $01, $99, $0f
	db $06, $01, $3f, $00, $01, $bf, $01, $01, $bb, $0f, $03, $01, $3e, $01, $01, $33
	db $0c, $01, $a0, $f6

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $27 screen 8, map $27 screen 8 version 1, map $27 screen 8 version 2, map $27 screen
;@ 8 version 3, map $28 screen 0, map $28 screen 0 version 1, map $28 screen 0 version 2, map $28 screen 0
;@ version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $4B packed).
AttrMap_62::
	db $00, $01, $01, $01, $ff, $ff, $2f, $12, $33, $22, $33, $21
	db $01, $ff, $f7, $22, $33, $22, $33, $22, $01, $ff, $f6, $11, $22, $01, $62, $00
	db $11, $01, $ff, $f5, $33, $01, $62, $01, $33, $01, $68, $06, $11, $01, $82, $00
	db $01, $77, $07, $33, $11, $33, $11, $33, $01, $87, $0f, $17, $01, $82, $01, $11
	db $01, $67, $06, $01, $c1, $0c, $01, $5e, $00, $01, $ff, $fb, $01, $e4, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $28 screen 10, map $28 screen 10 version 1, map $28 screen 10 version 2, map $28
;@ screen 10 version 3, map $29 screen 0, map $29 screen 0 version 1, map $29 screen 0 version 2, map $29 screen
;@ 0 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $39 packed).
AttrMap_63::
	db $00
	db $01, $01, $01, $ff, $ff, $0f, $22, $01, $1e, $05, $01, $1c, $0f, $03, $00, $33
	db $11, $11, $33, $01, $ff, $f8, $01, $43, $0b, $11, $01, $62, $01, $01, $58, $0f
	db $17, $33, $11, $33, $33, $01, $45, $08, $01, $92, $0f, $0d, $01, $62, $0f, $0d
	db $00, $00, $01, $d7, $09, $01, $e1, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $29 screen 10, map $29 screen 10 version 1, map $29 screen 10 version 2, map $29
;@ screen 10 version 3, map $2A screen 0, map $2A screen 0 version 1, map $2A screen 0 version 2, map $2A screen
;@ 0 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $3E packed).
AttrMap_64::
	db $00, $01, $01, $01, $ff, $ff, $10, $22
	db $01, $21, $01, $01, $19, $0f, $07, $00, $11, $11, $01, $ff, $fa, $01, $44, $09
	db $11, $00, $11, $11, $11, $11, $00, $01, $45, $05, $01, $61, $0d, $33, $01, $63
	db $00, $33, $01, $78, $0f, $07, $01, $a1, $03, $01, $99, $0f, $25, $01, $5e, $01
	db $01, $46, $0b, $01, $a0, $f7

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $2A screen 10, map $2A screen 10 version 1, map $2B screen 0, map $2B screen 0
;@ version 1 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $31 packed).
AttrMap_65::
	db $00, $01, $01, $01, $ff, $ff, $0e, $22, $01, $21
	db $00, $01, $16, $0f, $0a, $33, $01, $34, $0f, $0c, $01, $23, $0f, $0d, $01, $23
	db $0f, $0b, $11, $01, $a1, $00, $01, $96, $0f, $0d, $01, $a3, $07, $01, $c1, $0c
	db $01, $9b, $04, $01, $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $2B screen 6, map $2B screen 6 version 1, map $2B screen 6 version 2, map $2B screen
;@ 6 version 3, map $2C screen 0, map $2C screen 0 version 1, map $2C screen 0 version 2, map $2C screen 0
;@ version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $31 packed).
AttrMap_66::
	db $00, $01, $01, $01, $ff, $ff, $0e, $22, $00
	db $22, $01, $14, $0f, $0a, $00, $11, $01, $ff, $fb, $01, $42, $0b, $33, $11, $33
	db $01, $54, $0f, $0a, $01, $41, $0f, $0d, $01, $41, $0f, $0d, $11, $01, $c1, $03
	db $01, $b9, $0f, $05, $01, $7b, $0f, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $2C screen 10, map $2C screen 10 version 1, map $2C screen 10 version 2, map $2C
;@ screen 10 version 3, map $2D screen 0, map $2D screen 0 version 1, map $2D screen 0 version 2, map $2D screen
;@ 0 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $34 packed).
AttrMap_67::
	db $00, $01, $01, $01, $ff, $ff, $2f, $11
	db $00, $11, $11, $33, $11, $01, $38, $08, $33, $33, $33, $33, $01, $39, $06, $11
	db $01, $42, $01, $01, $58, $0f, $06, $00, $11, $00, $00, $11, $01, $56, $07, $01
	db $51, $0c, $01, $81, $00, $01, $35, $0b, $01, $a4, $0f, $39

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $2D screen 10, map $2D screen 10 version 1, map $2D screen 10 version 2, map $2D
;@ screen 10 version 3, map $2E screen 0, map $2E screen 0 version 1, map $2E screen 0 version 2, map $2E screen
;@ 0 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $3B packed).
AttrMap_68::
	db $00, $01, $01, $01
	db $ff, $ff, $2e, $22, $33, $22, $33, $22, $01, $36, $0f, $09, $01, $61, $00, $01
	db $56, $0f, $0f, $01, $45, $05, $01, $81, $0c, $12, $01, $61, $01, $01, $45, $06
	db $01, $a1, $0f, $00, $01, $5f, $00, $01, $ff, $f5, $11, $11, $11, $01, $c4, $09
	db $01, $5c, $03, $01, $d8, $0f, $05

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $2E screen 14, map $2E screen 14 version 1, map $2E screen 14 version 2, map $2E
;@ screen 14 version 3, map $2E screen 14 version 4, map $2E screen 14 version 5, map $2E screen 14 version 6,
;@ map $2F screen 4, and 6 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values
;@ per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $42 packed).
AttrMap_69::
	db $00, $01, $01, $01, $ff, $fd, $33, $33, $00
	db $03, $01, $05, $0b, $01, $21, $02, $01, $0a, $06, $31, $13, $01, $26, $09, $33
	db $31, $13, $33, $01, $37, $09, $01, $51, $01, $01, $49, $0f, $1d, $01, $28, $04
	db $01, $81, $0f, $05, $01, $49, $0f, $05, $01, $f2, $ff, $0c, $22, $20, $22, $20
	db $00, $00, $02, $22, $22, $01, $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $2E screen 15, map $2E screen 15 version 1, map $2F screen 5, map $2F screen 5
;@ version 1 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $35 packed).
AttrMap_6A::
	db $00, $01, $01, $01, $ff, $fd, $33
	db $33, $00, $00, $33, $01, $06, $0e, $01, $15, $05, $01, $21, $0e, $01, $41, $02
	db $01, $39, $0f, $24, $01, $41, $04, $01, $78, $0f, $05, $01, $40, $0f, $0e, $01
	db $f2, $ff, $0c, $22, $20, $01, $db, $02, $22, $22, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $30 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $52 packed).
AttrMap_6B::
	db $00, $01
	db $01, $11, $11, $11, $01, $ff, $f0, $11, $11, $01, $f9, $ff, $0d, $01, $08, $03
	db $01, $20, $0d, $00, $11, $01, $fe, $f0, $01, $44, $00, $01, $3b, $03, $33, $00
	db $00, $33, $33, $01, $47, $09, $22, $01, $51, $00, $01, $59, $0f, $08, $00, $01
	db $65, $0a, $33, $01, $54, $00, $01, $68, $06, $00, $01, $93, $0d, $01, $b3, $00
	db $01, $98, $07, $01, $ba, $09, $01, $c0, $0d, $01, $e0, $05, $01, $da, $0f, $03
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $30 screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $57 packed).
AttrMap_6C::
	db $00, $01, $01, $11, $11, $11, $01, $ff, $f0, $11, $11, $01, $f9, $ff, $0d, $01
	db $08, $03, $01, $20, $0d, $33, $11, $01, $fe, $f0, $01, $44, $00, $01, $3b, $03
	db $33, $00, $00, $33, $33, $01, $47, $06, $00, $33, $00, $22, $00, $33, $01, $5e
	db $00, $01, $5b, $0f, $06, $00, $01, $65, $0a, $33, $01, $54, $00, $01, $68, $06
	db $00, $01, $93, $0d, $01, $b3, $00, $01, $98, $07, $01, $ba, $09, $01, $c0, $0d
	db $01, $e0, $05, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $30 screen 6, map $31 screen 0 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $2F packed).
AttrMap_6D::
	db $00, $01, $01, $11, $01, $00, $02, $22, $22
	db $11, $01, $fa, $ff, $07, $00, $00, $00, $01, $17, $0f, $0d, $00, $00, $01, $39
	db $0f, $25, $01, $fe, $f1, $01, $76, $0f, $0d, $01, $40, $05, $01, $9f, $0e, $01
	db $c0, $05, $01, $ba, $0f, $23

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $30 screen 6 version 1, map $31 screen 0 version 1 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $30 packed).
AttrMap_6E::
	db $00, $01, $01, $11, $01, $00, $02, $22, $22, $11
	db $01, $fa, $ff, $07, $33, $00, $00, $01, $17, $0f, $0a, $01, $fb, $f2, $01, $3a
	db $0f, $24, $01, $fe, $f1, $01, $76, $0f, $0d, $01, $40, $05, $01, $9f, $0e, $01
	db $c0, $05, $01, $ba, $0f, $23

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $30 screen 12, map $31 screen 6, map $32 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $3D packed).
AttrMap_6F::
	db $00, $01, $01, $00, $00, $22, $22, $22, $22, $00
	db $00, $11, $11, $01, $fa, $ff, $07, $01, $f4, $fc, $01, $b3, $ff, $3c, $11, $01
	db $81, $01, $01, $79, $0f, $04, $01, $83, $00, $22, $22, $01, $96, $0f, $08, $11
	db $00, $11, $11, $01, $08, $06, $01, $bf, $0f, $00, $01, $09, $02, $01, $08, $04
	db $01, $e0, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $30 screen 12 version 1, map $31 screen 6 version 1, map $32 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $3F packed).
AttrMap_70::
	db $00, $01, $01, $00, $00, $22, $22, $22, $22, $00, $00, $11, $11
	db $01, $fa, $ff, $07, $01, $f4, $fc, $01, $b3, $ff, $3c, $11, $11, $33, $01, $09
	db $05, $01, $7f, $0d, $11, $00, $00, $11, $22, $22, $01, $96, $0f, $08, $11, $00
	db $11, $11, $01, $08, $06, $01, $bf, $0f, $00, $01, $09, $02, $01, $08, $04, $01
	db $e0, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $31 screen 12, map $32 screen 6, map $33 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $4D packed).
AttrMap_71::
	db $00, $01, $01, $00, $00, $00, $11, $11, $11, $11, $01, $f7, $ff, $08
	db $01, $03, $00, $01, $05, $08, $01, $22, $0a, $01, $03, $00, $22, $22, $01, $03
	db $06, $01, $40, $0f, $00, $22, $01, $61, $01, $01, $59, $0f, $05, $00, $00, $01
	db $63, $00, $01, $7e, $01, $01, $7c, $0f, $04, $01, $9a, $09, $01, $a0, $0d, $01
	db $05, $02, $01, $47, $08, $01, $c3, $0c, $01, $e0, $03, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $31 screen 12 version 1, map $32 screen 6 version 1, map $33 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $4D packed).
AttrMap_72::
	db $00
	db $01, $01, $00, $00, $00, $11, $11, $11, $11, $01, $f7, $ff, $08, $01, $03, $00
	db $01, $05, $08, $01, $22, $0a, $01, $03, $00, $22, $22, $01, $03, $06, $01, $40
	db $0f, $00, $22, $01, $61, $01, $01, $59, $0f, $05, $33, $00, $01, $63, $00, $00
	db $00, $01, $79, $0f, $05, $01, $fb, $f5, $01, $9a, $0f, $04, $01, $05, $02, $01
	db $47, $08, $01, $c3, $0c, $01, $e0, $03, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $32 screen 12, map $33 screen 6, map $34 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $30 packed).
AttrMap_73::
	db $00, $01, $01, $01
	db $ff, $ff, $01, $02, $20, $01, $ff, $fa, $22, $22, $00, $00, $11, $01, $19, $0f
	db $08, $01, $f0, $ff, $11, $01, $38, $0c, $01, $28, $06, $01, $28, $00, $01, $28
	db $08, $01, $82, $0c, $01, $4a, $0f, $25, $01, $d9, $0f, $13

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $32 screen 12 version 1, map $33 screen 6 version 1, map $34 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $31 packed).
AttrMap_74::
	db $00, $01, $01, $01
	db $ff, $f4, $11, $01, $f9, $ff, $09, $33, $01, $16, $0f, $08, $01, $08, $0f, $0a
	db $01, $01, $06, $01, $08, $09, $01, $65, $09, $01, $08, $00, $01, $08, $08, $01
	db $82, $0c, $01, $ea, $ff, $11, $01, $78, $0a, $01, $94, $0f, $19

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $33 screen 12, map $34 screen 6, map $35 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $4A packed).
AttrMap_75::
	db $00, $01, $01
	db $11, $00, $00, $11, $11, $11, $22, $11, $11, $11, $01, $fa, $ff, $08, $22, $01
	db $16, $0f, $0d, $11, $11, $01, $ff, $f0, $01, $3c, $0f, $04, $00, $00, $22, $22
	db $01, $5e, $03, $01, $5e, $0f, $01, $11, $01, $42, $02, $01, $79, $0f, $05, $01
	db $a0, $01, $01, $25, $00, $01, $9a, $0f, $09, $01, $a0, $00, $01, $ba, $0f, $03
	db $01, $9c, $06, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $33 screen 12 version 1, map $34 screen 6 version 1, map $35 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $48 packed).
AttrMap_76::
	db $00, $01, $01, $11, $00, $00, $11, $11, $11
	db $22, $11, $11, $11, $01, $fa, $ff, $08, $22, $01, $16, $0f, $0d, $11, $11, $01
	db $ff, $f0, $01, $3c, $0f, $04, $00, $00, $22, $22, $33, $01, $58, $0f, $07, $11
	db $01, $42, $02, $01, $79, $0f, $05, $01, $a0, $01, $01, $25, $00, $01, $9a, $0f
	db $09, $01, $a0, $00, $01, $ba, $0f, $03, $01, $9c, $06, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $34 screen 12, map $35 screen 6, map $36 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $3A packed).
AttrMap_77::
	db $00
	db $01, $01, $11, $11, $11, $01, $fc, $f7, $01, $fe, $ff, $00, $02, $22, $01, $22
	db $02, $01, $19, $0f, $35, $01, $fc, $f0, $01, $21, $00, $01, $09, $04, $01, $22
	db $00, $01, $75, $0f, $0a, $00, $00, $01, $94, $0f, $0e, $01, $6c, $05, $01, $be
	db $0f, $00, $01, $e0, $05, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $34 screen 12 version 1, map $35 screen 6 version 1, map $36 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $3B packed).
AttrMap_78::
	db $00, $01, $01, $11, $11, $11, $01
	db $fc, $f7, $01, $fe, $ff, $00, $02, $22, $01, $22, $02, $01, $19, $0f, $35, $01
	db $fc, $f0, $01, $21, $00, $01, $09, $04, $01, $22, $00, $01, $75, $0f, $0a, $00
	db $00, $01, $94, $0f, $0e, $00, $00, $00, $33, $01, $b9, $0f, $05, $01, $e0, $05
	db $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $35 screen 12, map $36 screen 6, map $37 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $24 packed).
AttrMap_79::
	db $00, $01, $01, $01, $ff, $ff, $10, $22, $22, $22, $22, $01
	db $17, $0f, $09, $00, $01, $35, $0b, $01, $43, $0d, $11, $11, $01, $56, $0f, $0b
	db $01, $83, $0f, $4d, $01, $64, $0f, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $35 screen 12 version 1, map $36 screen 6 version 1, map $37 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $24 packed).
AttrMap_7A::
	db $00, $01, $01, $01, $ff, $ff, $10, $22
	db $33, $22, $22, $01, $17, $0f, $09, $00, $01, $35, $0b, $01, $43, $0d, $11, $11
	db $01, $56, $0f, $0b, $01, $83, $0f, $4d, $01, $64, $0f, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $36 screen 12, map $37 screen 6, map $38 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $36 packed).
AttrMap_7B::
	db $00, $01, $01, $11
	db $01, $fa, $f3, $11, $01, $00, $04, $01, $01, $0d, $01, $08, $01, $01, $17, $0f
	db $0d, $01, $fe, $f6, $01, $41, $0d, $01, $04, $01, $01, $57, $0f, $2b, $01, $55
	db $0c, $01, $55, $0a, $01, $08, $02, $01, $b9, $0f, $05, $01, $e0, $05, $01, $da
	db $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $36 screen 12 version 1, map $37 screen 6 version 1, map $38 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $38 packed).
AttrMap_7C::
	db $00, $01, $01, $11, $01, $fa, $f3, $11, $01, $00, $04, $01, $01, $0d
	db $01, $08, $01, $01, $17, $0f, $0d, $01, $fe, $f6, $01, $41, $0d, $01, $04, $01
	db $01, $57, $0f, $2b, $00, $00, $00, $33, $01, $99, $0f, $07, $01, $08, $02, $01
	db $b9, $0f, $05, $01, $e0, $05, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $37 screen 12, map $38 screen 6, map $39 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $29 packed).
AttrMap_7D::
	db $00, $01, $01, $01, $ff, $ff
	db $0e, $11, $11, $11, $01, $14, $0f, $4d, $00, $00, $00, $22, $01, $78, $0f, $0c
	db $01, $23, $06, $01, $a1, $0c, $01, $1f, $01, $01, $21, $09, $01, $c3, $0c, $01
	db $e2, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $37 screen 12 version 1, map $38 screen 6 version 1, map $39 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $2B packed).
AttrMap_7E::
	db $00, $01, $01, $01, $ff, $ff, $0e, $11, $11, $11, $01, $14, $0f
	db $4d, $00, $00, $00, $22, $01, $78, $0f, $0c, $01, $23, $06, $01, $a1, $0c, $01
	db $1f, $01, $11, $33, $01, $23, $07, $01, $c3, $0c, $01, $e2, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $38 screen 12, map $39 screen 6, map $3A screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $2F packed).
AttrMap_7F::
	db $00, $01
	db $02, $33, $02, $00, $05, $02, $fa, $ff, $03, $30, $02, $f8, $f4, $03, $02, $1a
	db $0f, $14, $22, $02, $51, $03, $02, $49, $0f, $4d, $02, $29, $03, $10, $02, $51
	db $04, $01, $02, $ba, $0f, $04, $02, $f8, $f4, $02, $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $38 screen 12 version 1, map $39 screen 6 version 1, map $3A screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $36 packed).
AttrMap_80::
	db $00, $01, $02
	db $33, $02, $00, $05, $02, $fa, $ff, $03, $30, $02, $09, $03, $00, $03, $02, $1a
	db $0f, $04, $02, $f8, $f4, $02, $29, $04, $22, $02, $51, $03, $02, $49, $0f, $4d
	db $02, $29, $03, $10, $02, $51, $04, $01, $02, $ba, $0f, $04, $02, $f8, $f4, $02
	db $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $39 screen 12, map $3A screen 6, map $3B screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $39 packed).
AttrMap_81::
	db $00, $01, $01, $01, $ff, $f0, $22, $22, $01, $f6, $ff, $07, $22
	db $01, $20, $05, $01, $1a, $0f, $23, $01, $1f, $05, $01, $18, $0c, $01, $16, $0a
	db $01, $f8, $fa, $01, $04, $0c, $01, $d8, $ff, $19, $11, $01, $d0, $00, $01, $d1
	db $00, $01, $ca, $0f, $07, $11, $01, $cf, $00, $01, $f8, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $39 screen 12 version 1, map $3A screen 6 version 1, map $3B screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $3D packed).
AttrMap_82::
	db $00, $01, $01, $01
	db $ff, $f0, $22, $22, $01, $f6, $ff, $07, $22, $01, $20, $05, $01, $1a, $0f, $23
	db $01, $1f, $01, $33, $01, $57, $06, $01, $60, $0d, $01, $1e, $02, $01, $f8, $fa
	db $01, $04, $0c, $01, $d8, $ff, $19, $11, $01, $d0, $00, $01, $d1, $00, $01, $ca
	db $0f, $07, $11, $01, $cf, $00, $01, $f8, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $3A screen 12, map $3B screen 6, map $3C screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $49 packed).
AttrMap_83::
	db $00, $01, $01, $11, $01, $00, $05
	db $01, $fa, $ff, $08, $01, $fe, $f1, $01, $1a, $0f, $05, $22, $22, $22, $01, $35
	db $0f, $09, $01, $42, $01, $01, $fd, $f0, $01, $5a, $0f, $05, $01, $fb, $f1, $22
	db $22, $01, $79, $0f, $05, $01, $09, $01, $22, $22, $01, $08, $06, $01, $a2, $0f
	db $0e, $33, $33, $33, $01, $a6, $08, $11, $11, $33, $33, $22, $01, $07, $09, $01
	db $e4, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $3A screen 12 version 2, map $3B screen 6 version 2, map $3C screen 0 version 2
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $4B packed).
AttrMap_84::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $08, $00, $33, $01
	db $17, $0f, $08, $22, $22, $22, $01, $fe, $f1, $01, $3a, $0f, $04, $01, $42, $01
	db $01, $fd, $f0, $01, $5a, $0f, $05, $01, $fb, $f1, $22, $22, $01, $79, $0f, $05
	db $01, $09, $01, $22, $22, $01, $08, $06, $01, $a2, $0f, $0e, $33, $33, $33, $01
	db $a6, $08, $11, $11, $33, $33, $22, $01, $07, $09, $01, $e4, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $3A screen 12 version 1, map $3B screen 6 version 1, map $3C screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $49 packed).
AttrMap_85::
	db $00, $01, $01
	db $11, $01, $00, $05, $01, $fa, $ff, $08, $01, $fe, $f1, $01, $1a, $0f, $05, $22
	db $22, $22, $01, $35, $0f, $09, $01, $42, $01, $01, $fd, $f0, $01, $5a, $0f, $05
	db $01, $fb, $f1, $22, $22, $01, $79, $0f, $05, $01, $09, $01, $22, $22, $01, $08
	db $06, $01, $a2, $0f, $0e, $33, $33, $33, $01, $a6, $08, $11, $11, $33, $33, $22
	db $01, $07, $09, $01, $e4, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $3B screen 14, map $3B screen 14 version 1, map $3C screen 8, map $3C screen 8
;@ version 1, map $3D screen 0, map $3D screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $59 packed).
AttrMap_86::
	db $00, $01, $01, $00, $00, $00, $11, $11, $11, $11
	db $01, $f7, $f8, $33, $33, $33, $33, $01, $f8, $f8, $01, $13, $00, $01, $06, $07
	db $01, $13, $00, $01, $15, $06, $22, $01, $22, $01, $33, $33, $11, $22, $01, $3a
	db $03, $01, $32, $02, $33, $33, $01, $49, $0f, $18, $01, $11, $01, $01, $79, $0f
	db $04, $01, $11, $00, $01, $11, $00, $01, $99, $05, $01, $a1, $0d, $22, $01, $83
	db $00, $01, $a8, $06, $01, $c1, $0e, $22, $01, $e0, $02, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $3C screen 14, map $3D screen 6, map $3E screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $42 packed).
AttrMap_87::
	db $00
	db $01, $02, $11, $02, $00, $05, $02, $fa, $f4, $10, $02, $fc, $f0, $01, $02, $08
	db $0f, $18, $22, $00, $00, $22, $02, $17, $05, $10, $00, $00, $02, $43, $00, $00
	db $00, $01, $02, $4a, $05, $02, $fa, $f2, $02, $59, $03, $02, $ef, $fd, $22, $02
	db $7b, $09, $02, $7f, $0f, $22, $02, $08, $00, $02, $b8, $0f, $09, $02, $84, $0f
	db $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $3C screen 14 version 1, map $3D screen 6 version 1, map $3E screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $47 packed).
AttrMap_88::
	db $00, $01, $02, $11, $02, $00, $05, $02, $fa, $f4, $10, $02, $fc, $f0, $01
	db $02, $08, $0f, $18, $22, $00, $00, $22, $02, $17, $05, $10, $00, $00, $02, $43
	db $00, $00, $00, $01, $02, $4a, $03, $33, $02, $f9, $f3, $02, $59, $03, $00, $02
	db $61, $04, $02, $f8, $f4, $22, $02, $7b, $09, $02, $7f, $0f, $22, $02, $08, $00
	db $02, $b8, $0f, $09, $02, $84, $0f, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $3D screen 12, map $3E screen 6, map $3F screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $3B packed).
AttrMap_89::
	db $00, $01, $01, $01, $ff, $fc, $02, $20
	db $01, $0f, $03, $01, $09, $0f, $04, $01, $ff, $f1, $22, $01, $0e, $01, $01, $09
	db $06, $01, $35, $0c, $01, $33, $01, $01, $28, $0c, $01, $f6, $ff, $07, $01, $57
	db $0f, $09, $22, $01, $56, $0b, $01, $a0, $0e, $01, $9c, $0a, $01, $c0, $0c, $01
	db $9f, $0f, $0d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $3D screen 12 version 1, map $3E screen 6 version 1, map $3F screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $63 packed).
AttrMap_8A::
	db $00, $01, $01, $01, $ff, $f2, $22, $22, $01, $f8, $ff, $05, $11
	db $01, $20, $00, $00, $02, $22, $20, $01, $19, $09, $00, $22, $01, $27, $04, $01
	db $30, $03, $01, $26, $05, $01, $30, $03, $00, $22, $01, $54, $00, $01, $2d, $06
	db $01, $52, $02, $01, $5d, $0f, $16, $22, $01, $67, $05, $02, $33, $20, $02, $22
	db $22, $01, $96, $08, $22, $22, $22, $22, $20, $01, $67, $05, $00, $22, $01, $06
	db $01, $01, $b7, $06, $00, $02, $01, $06, $00, $01, $c7, $07, $01, $36, $01, $01
	db $d7, $08, $00, $01, $e4, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $3E screen 12, map $3F screen 6, map $40 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $21 packed).
AttrMap_8B::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $f3
	db $01, $0e, $07, $01, $0c, $0f, $4d, $01, $1c, $03, $01, $7a, $09, $01, $80, $0f
	db $3e, $01, $01, $0c, $01, $01, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $3F screen 10, map $3F screen 10 version 1, map $3F screen 10 version 2, map $40
;@ screen 4, map $40 screen 4 version 1, map $40 screen 4 version 2, map $41 screen 0, map $41 screen 0 version
;@ 1, and 1 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $1A packed).
AttrMap_8C::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa
	db $ff, $24, $01, $3e, $07, $01, $3c, $0f, $4d, $01, $7c, $0f, $22, $01, $01, $0f
	db $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $3F screen 10 version 3, map $40 screen 4 version 3, map $41 screen 0 version 3
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $22 packed).
AttrMap_8D::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $3f, $04
	db $01, $3a, $0f, $04, $01, $5e, $07, $01, $5c, $0f, $4d, $01, $7c, $0f, $02, $01
	db $01, $0f, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $40 screen 14, map $40 screen 14 version 1, map $40 screen 14 version 2, map $40
;@ screen 14 version 3, map $40 screen 14 version 4, map $40 screen 14 version 5, map $40 screen 14 version 6,
;@ map $40 screen 14 version 7, and 22 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $30 packed).
AttrMap_8E::
	db $00, $01, $01, $11, $11, $00, $11, $11, $01, $00, $01, $01, $aa
	db $ff, $4d, $01, $f7, $f6, $01, $71, $01, $01, $f6, $f7, $01, $74, $0b, $01, $ee
	db $fe, $33, $01, $96, $0f, $07, $01, $09, $05, $01, $09, $03, $01, $c0, $0d, $01
	db $01, $0f, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $40 screen 15, map $40 screen 15 version 1, map $41 screen 11, map $41 screen 11
;@ version 1, map $42 screen 1, map $42 screen 1 version 1, map $60 screen 0, map $60 screen 0 version 1, and 6
;@ more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in
;@ the DecompressCore format ($100 bytes unpacked, $32 packed).
AttrMap_8F::
	db $00, $01, $01, $11, $01, $00, $05, $01, $f6, $f8, $01, $f2, $fc
	db $01, $16, $0f, $0a, $22, $01, $34, $0f, $09, $01, $00, $0f, $30, $33, $01, $94
	db $0f, $09, $01, $09, $00, $01, $08, $01, $01, $09, $03, $01, $c0, $0d, $01, $01
	db $0f, $00, $01, $f3, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $43 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $32 packed).
AttrMap_90::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24
	db $22, $01, $09, $01, $11, $00, $01, $39, $0f, $27, $01, $00, $00, $22, $01, $41
	db $02, $01, $7e, $0f, $00, $01, $fa, $f2, $01, $97, $0f, $1d, $01, $9e, $05, $01
	db $00, $0f, $06, $10, $01, $a0, $f2

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $43 screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3A packed).
AttrMap_91::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa
	db $ff, $24, $22, $01, $09, $01, $11, $00, $01, $39, $0f, $27, $01, $00, $00, $22
	db $01, $41, $02, $01, $7e, $0f, $00, $00, $33, $01, $fc, $f0, $01, $97, $0f, $08
	db $01, $fb, $f1, $01, $b7, $0c, $01, $be, $05, $01, $00, $0f, $06, $10, $01, $a0
	db $f2

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $43 screen 6, map $44 screen 0 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $39 packed).
AttrMap_92::
	db $00, $01, $01, $22, $01, $00, $05, $01, $fa, $ff, $07, $01, $fd, $f2, $01
	db $1a, $0f, $06, $01, $fb, $f3, $01, $3a, $0f, $03, $01, $f7, $f6, $01, $5a, $0f
	db $23, $11, $11, $11, $01, $9b, $02, $01, $39, $0f, $07, $01, $a2, $00, $11, $01
	db $18, $0f, $09, $11, $11, $11, $01, $07, $0f, $06

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $43 screen 6 version 1, map $44 screen 0 version 1 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $45 packed).
AttrMap_93::
	db $00, $01, $01, $22, $01, $00
	db $05, $01, $fa, $ff, $07, $00, $00, $33, $01, $17, $0f, $09, $01, $fb, $f3, $01
	db $fa, $f2, $11, $11, $01, $42, $0a, $01, $f7, $f6, $01, $5a, $0f, $23, $11, $11
	db $11, $01, $4b, $02, $01, $39, $0f, $04, $22, $22, $22, $01, $a2, $00, $11, $01
	db $18, $0a, $01, $3f, $05, $01, $ff, $f1, $11, $11, $11, $01, $07, $0f, $06

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $43 screen 12, map $43 screen 12 version 2, map $44 screen 6, map $44 screen 6
;@ version 2, map $45 screen 0, map $45 screen 0 version 2 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4B packed).
AttrMap_94::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $23, $22, $22, $12, $22, $22, $22
	db $22, $21, $22, $22, $01, $3a, $0f, $03, $11, $12, $01, $49, $01, $22, $21, $01
	db $09, $04, $01, $61, $0b, $01, $48, $06, $01, $7a, $0f, $05, $01, $62, $02, $01
	db $98, $0f, $08, $22, $01, $be, $04, $01, $fc, $f2, $01, $c2, $02, $01, $08, $06
	db $01, $d2, $0c, $11, $01, $c3, $00, $01, $07, $05

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $43 screen 12 version 1, map $44 screen 6 version 1, map $45 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $4F packed).
AttrMap_95::
	db $00, $01, $01, $11, $01, $00
	db $05, $01, $fa, $ff, $23, $22, $22, $12, $22, $22, $22, $22, $21, $22, $22, $01
	db $3a, $0f, $03, $11, $12, $01, $49, $01, $22, $21, $01, $09, $04, $01, $61, $0b
	db $01, $48, $06, $01, $7a, $0f, $05, $22, $00, $00, $33, $01, $9f, $02, $01, $9c
	db $0f, $04, $22, $01, $be, $04, $01, $fc, $f2, $01, $c2, $02, $01, $08, $06, $01
	db $d2, $0c, $11, $01, $c3, $00, $01, $07, $05

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $44 screen 14, map $45 screen 8, map $46 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $3F packed).
AttrMap_96::
	db $00, $01, $01, $33, $33, $11, $01
	db $02, $01, $33, $33, $01, $fa, $ff, $04, $11, $11, $22, $22, $22, $22, $11, $11
	db $01, $19, $06, $01, $fc, $f0, $01, $27, $05, $11, $01, $31, $04, $01, $32, $01
	db $01, $3e, $0f, $01, $01, $5a, $0f, $4d, $01, $c0, $04, $01, $ba, $0f, $03, $01
	db $01, $03, $01, $27, $08, $01, $e3, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $44 screen 14 version 1, map $45 screen 8 version 1, map $46 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $4A packed).
AttrMap_97::
	db $00, $01, $01, $33, $33, $11, $01, $02
	db $01, $33, $33, $01, $fa, $ff, $04, $11, $11, $22, $22, $22, $22, $11, $11, $01
	db $19, $06, $01, $fc, $f0, $01, $27, $05, $11, $01, $31, $04, $01, $32, $01, $01
	db $3e, $0f, $01, $01, $5a, $0f, $0d, $01, $09, $02, $01, $78, $0f, $07, $01, $5a
	db $0f, $0d, $01, $c0, $04, $01, $ba, $0f, $03, $01, $01, $03, $01, $27, $08, $01
	db $e3, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $45 screen 14, map $45 screen 14 version 1, map $46 screen 6, map $46 screen 6
;@ version 1, map $47 screen 0, map $47 screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $48 packed).
AttrMap_98::
	db $00, $01, $01, $33, $33, $11, $01, $02, $01, $33, $33, $01, $fa, $ff
	db $04, $01, $02, $02, $11, $11, $01, $19, $0f, $04, $11, $11, $11, $22, $22, $22
	db $22, $11, $11, $11, $01, $3a, $0f, $04, $00, $01, $43, $00, $22, $22, $00, $01
	db $59, $0f, $25, $01, $42, $01, $01, $45, $00, $01, $9a, $0f, $05, $01, $49, $01
	db $01, $47, $08, $01, $c3, $09, $01, $20, $0f, $0d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $45 screen 14 version 2, map $46 screen 6 version 2, map $47 screen 0 version 2
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $4D packed).
AttrMap_99::
	db $00, $01, $01, $33, $33, $11
	db $01, $02, $01, $33, $33, $01, $fa, $ff, $04, $01, $02, $02, $11, $11, $01, $19
	db $0f, $04, $11, $11, $11, $22, $22, $22, $22, $11, $11, $11, $01, $3a, $0f, $04
	db $00, $01, $43, $00, $22, $22, $00, $01, $59, $0f, $07, $33, $01, $74, $0f, $0a
	db $01, $42, $01, $01, $45, $00, $01, $9a, $0f, $05, $01, $49, $01, $01, $47, $08
	db $01, $c3, $09, $01, $20, $0f, $0d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $46 screen 14, map $47 screen 8, map $48 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $4F packed).
AttrMap_9A::
	db $00, $01, $01, $11, $22, $11, $22, $22, $22
	db $22, $11, $22, $11, $01, $fa, $f3, $00, $11, $20, $00, $00, $02, $11, $00, $01
	db $09, $0f, $07, $01, $03, $01, $01, $18, $05, $22, $11, $01, $42, $01, $01, $08
	db $07, $01, $42, $01, $01, $18, $06, $00, $00, $20, $02, $01, $5d, $03, $01, $5d
	db $0f, $01, $01, $80, $05, $01, $7a, $0f, $03, $01, $fc, $f0, $01, $64, $01, $01
	db $f5, $f7, $01, $a4, $0f, $39

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $46 screen 14 version 1, map $47 screen 8 version 1, map $48 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $53 packed).
AttrMap_9B::
	db $00, $01, $01, $11, $22, $11, $22, $22, $22, $22
	db $11, $22, $11, $01, $fa, $f3, $00, $11, $20, $00, $00, $02, $11, $00, $01, $09
	db $07, $33, $01, $15, $0a, $22, $33, $22, $22, $01, $17, $06, $22, $11, $01, $42
	db $01, $01, $08, $07, $01, $42, $01, $01, $18, $06, $00, $00, $20, $02, $01, $5d
	db $03, $01, $5d, $0f, $01, $01, $80, $05, $01, $7a, $0f, $03, $01, $fc, $f0, $01
	db $64, $01, $01, $f5, $f7, $01, $a4, $0f, $39

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $47 screen 14, map $48 screen 6, map $49 screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $48 packed).
AttrMap_9C::
	db $00, $01, $01, $11, $01, $00, $05
	db $01, $fa, $ff, $06, $12, $12, $22, $21, $01, $07, $08, $22, $22, $22, $22, $01
	db $07, $05, $22, $01, $31, $04, $22, $01, $3a, $0f, $03, $11, $01, $3f, $00, $01
	db $47, $00, $01, $09, $04, $01, $fe, $f2, $01, $6e, $01, $01, $f9, $f7, $01, $f4
	db $fc, $01, $f5, $f7, $01, $62, $03, $01, $f5, $f9, $01, $f2, $fc, $01, $b6, $0f
	db $27

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $47 screen 14 version 1, map $48 screen 6 version 1, map $49 screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $4A packed).
AttrMap_9D::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $06, $12, $12, $22, $21
	db $01, $07, $08, $22, $22, $22, $22, $01, $07, $05, $22, $01, $31, $04, $22, $01
	db $3a, $0f, $03, $11, $01, $3f, $00, $01, $47, $00, $01, $09, $04, $01, $fe, $f2
	db $01, $6e, $01, $01, $fa, $f2, $33, $01, $06, $06, $01, $7d, $0f, $02, $01, $62
	db $03, $01, $f5, $f9, $01, $f2, $fc, $01, $b6, $0f, $27

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $48 screen 12, map $49 screen 6, map $4A screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $54 packed).
AttrMap_9E::
	db $00, $01, $03, $22, $22
	db $20, $01, $11, $11, $10, $02, $22, $22, $03, $fa, $f5, $11, $11, $11, $11, $03
	db $07, $0f, $19, $01, $00, $00, $03, $06, $08, $22, $03, $43, $00, $22, $03, $48
	db $08, $11, $03, $fd, $f1, $03, $5a, $0a, $02, $03, $09, $05, $03, $f9, $f4, $03
	db $7a, $0f, $04, $00, $00, $01, $03, $13, $00, $10, $03, $99, $0f, $04, $11, $03
	db $64, $00, $03, $bd, $0f, $0a, $03, $a4, $01, $03, $f7, $f5, $03, $e0, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $48 screen 12 version 1, map $49 screen 6 version 1, map $4A screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $50 packed).
AttrMap_9F::
	db $00
	db $01, $03, $22, $22, $20, $01, $11, $11, $10, $02, $22, $22, $03, $fa, $f5, $11
	db $11, $11, $11, $03, $07, $0f, $19, $01, $00, $00, $03, $06, $08, $22, $03, $43
	db $00, $22, $03, $48, $08, $11, $33, $03, $fe, $f0, $03, $5a, $0f, $05, $03, $f9
	db $f4, $03, $7a, $0f, $04, $00, $00, $01, $03, $13, $00, $10, $03, $99, $0f, $04
	db $11, $11, $03, $ba, $0f, $0d, $03, $a4, $01, $03, $f7, $f5, $03, $e0, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $49 screen 12, map $4A screen 6, map $4B screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $25 packed).
AttrMap_A0::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $07, $01, $1e, $04, $01, $1c, $0f
	db $04, $01, $3c, $07, $01, $3e, $0f, $01, $01, $5a, $0f, $4d, $01, $42, $0f, $0d
	db $01, $22, $0f, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $49 screen 12 version 1, map $4A screen 6 version 1, map $4B screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $2F packed).
AttrMap_A1::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $07, $01
	db $1e, $04, $01, $1c, $0f, $04, $01, $3c, $07, $01, $3e, $0f, $01, $00, $00, $33
	db $01, $5d, $03, $01, $5c, $0f, $05, $01, $7c, $0f, $2b, $01, $42, $0f, $0d, $01
	db $22, $0f, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4A screen 12, map $4B screen 6, map $4C screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $F packed).
AttrMap_A2::
	db $00, $01, $01, $01, $a0, $ff, $4d, $01, $5f, $0f, $4d, $01, $bf
	db $0f, $2d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4A screen 12 version 1, map $4B screen 6 version 1, map $4C screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $14 packed).
AttrMap_A3::
	db $00, $01, $01, $01, $a0, $ff, $4d, $01, $24, $0f, $11, $33, $01, $75
	db $0f, $0c, $01, $a3, $0f, $49

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4B screen 12, map $4C screen 6, map $4D screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $45 packed).
AttrMap_A4::
	db $00, $01, $01, $00, $00, $00, $11, $11, $11, $11
	db $01, $f7, $ff, $07, $22, $01, $03, $00, $11, $11, $22, $01, $19, $0f, $05, $01
	db $02, $01, $01, $05, $08, $01, $42, $0b, $22, $01, $01, $00, $01, $5f, $01, $01
	db $5b, $0f, $03, $01, $e2, $ff, $0e, $22, $01, $63, $00, $01, $78, $07, $01, $a2
	db $0c, $01, $81, $0f, $0f, $01, $36, $08, $01, $e0, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4B screen 12 version 1, map $4C screen 6 version 1, map $4D screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $46 packed).
AttrMap_A5::
	db $00, $01, $01, $00, $00
	db $00, $11, $11, $11, $11, $01, $f7, $ff, $07, $22, $01, $03, $00, $11, $11, $22
	db $01, $19, $0f, $05, $01, $02, $01, $01, $05, $08, $01, $42, $0b, $22, $00, $33
	db $01, $05, $00, $01, $28, $06, $01, $62, $0b, $01, $e2, $ff, $0e, $22, $00, $11
	db $11, $01, $77, $08, $01, $a2, $0c, $01, $81, $0f, $0f, $01, $36, $08, $01, $e0
	db $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4C screen 12, map $4D screen 6, map $4E screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $2F packed).
AttrMap_A6::
	db $00, $01, $02, $11, $02, $00, $05, $02, $fa, $ff, $4d, $02, $1a, $0f, $05
	db $10, $00, $00, $00, $01, $02, $77, $0f, $18, $02, $1b, $04, $02, $aa, $06, $22
	db $02, $85, $0b, $02, $c4, $0f, $0b, $11, $10, $22, $02, $1f, $01, $02, $a0, $f2
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4C screen 12 version 1, map $4D screen 6 version 1, map $4E screen 0 version 1
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $33 packed).
AttrMap_A7::
	db $00, $01, $02, $11, $02, $00, $05, $02, $fa, $ff, $4d, $02, $1a, $0f, $05, $10
	db $00, $33, $00, $01, $02, $77, $0f, $0a, $00, $02, $85, $09, $02, $1b, $04, $02
	db $aa, $06, $22, $02, $85, $0b, $02, $c4, $0f, $0b, $11, $10, $22, $02, $1f, $01
	db $02, $a0, $f2

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4D screen 10, map $4E screen 4 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4F packed).
AttrMap_A8::
	db $00, $01, $02, $11, $11, $00, $00, $22, $00, $00, $01, $02, $00
	db $00, $02, $fc, $ff, $03, $10, $02, $03, $00, $11, $02, $18, $0f, $06, $00, $02
	db $02, $01, $02, $3e, $02, $02, $3d, $0f, $24, $02, $7b, $08, $11, $10, $02, $82
	db $0b, $02, $09, $03, $01, $02, $19, $07, $02, $a5, $01, $02, $09, $05, $02, $90
	db $01, $02, $27, $07, $02, $90, $00, $01, $02, $c7, $08, $02, $bd, $02, $02, $d9
	db $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4F screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $60 packed).
AttrMap_A9::
	db $00, $01, $02, $00, $00, $00, $11, $11, $11, $11, $02, $f8, $fb, $02
	db $05, $07, $01, $02, $05, $00, $11, $11, $10, $02, $fb, $f6, $02, $2d, $06, $02
	db $1e, $04, $02, $24, $07, $02, $27, $04, $01, $02, $06, $03, $02, $50, $0d, $02
	db $fb, $f5, $02, $6a, $06, $22, $22, $02, $76, $07, $10, $11, $02, $83, $00, $11
	db $02, $58, $0f, $05, $02, $58, $0e, $02, $28, $01, $02, $c0, $03, $02, $44, $04
	db $02, $40, $03, $02, $1d, $03, $02, $03, $00, $02, $28, $05, $02, $e0, $02, $02
	db $e8, $05

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4F screen 0 version 1 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $68 packed).
AttrMap_AA::
	db $00, $01, $02, $00, $00, $00, $11, $11, $11, $11, $02, $f8, $fb, $02
	db $05, $07, $01, $02, $05, $00, $11, $11, $10, $02, $fb, $f6, $02, $2d, $06, $02
	db $1e, $04, $02, $24, $07, $02, $27, $04, $01, $02, $06, $03, $02, $50, $0d, $02
	db $fb, $f5, $02, $6a, $06, $22, $22, $02, $76, $07, $10, $11, $02, $83, $00, $11
	db $02, $58, $07, $33, $02, $54, $08, $01, $11, $02, $a2, $02, $02, $50, $06, $02
	db $28, $01, $02, $c0, $03, $02, $44, $04, $02, $40, $03, $02, $1d, $03, $02, $03
	db $00, $02, $28, $05, $02, $e0, $02, $02, $e8, $05

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4F screen 6, map $50 screen 0, map $5F screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $3A packed).
AttrMap_AB::
	db $00, $01, $02, $11, $02, $00
	db $05, $02, $fa, $f6, $10, $01, $02, $06, $0f, $09, $02, $ff, $f1, $02, $2f, $00
	db $02, $fb, $f2, $33, $00, $33, $33, $22, $22, $00, $33, $02, $39, $0f, $07, $02
	db $fb, $f1, $02, $58, $0f, $07, $02, $81, $03, $02, $79, $0f, $45, $02, $01, $0f
	db $00, $02, $04, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4F screen 10, map $50 screen 4, map $51 screen 0, map $5F screen 4
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $31 packed).
AttrMap_AC::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33
	db $01, $41, $03, $01, $39, $0f, $08, $00, $00, $01, $56, $0f, $0b, $01, $44, $0a
	db $22, $22, $33, $01, $91, $00, $01, $89, $0f, $06, $01, $42, $0f, $0f, $01, $44
	db $09, $01, $01, $0f, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $4F screen 14, map $50 screen 8, map $51 screen 4, map $52 screen 0, map $5F screen 8
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $1E packed).
AttrMap_AD::
	db $00, $01, $01, $22, $22, $11, $01, $02, $01, $22, $22
	db $01, $fa, $ff, $26, $01, $fc, $f0, $01, $37, $0f, $4d, $01, $77, $0f, $29, $01
	db $03, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $50 screen 12, map $51 screen 8, map $52 screen 4, map $53 screen 0, map $5F screen
;@ 12 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in
;@ the DecompressCore format ($100 bytes unpacked, $3E packed).
AttrMap_AE::
	db $00, $01, $01, $11, $33, $11, $01, $02, $01, $33, $11, $01, $fa
	db $ff, $15, $22, $01, $32, $01, $01, $08, $06, $01, $41, $03, $01, $09, $03, $22
	db $01, $41, $04, $22, $01, $fa, $f2, $01, $41, $04, $33, $33, $01, $5a, $0f, $03
	db $01, $04, $01, $01, $01, $01, $01, $7a, $0f, $47, $01, $02, $02, $01, $da, $0f
	db $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $50 screen 13, map $51 screen 9, map $52 screen 5, map $53 screen 1, map $5F screen
;@ 13, map $61 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per
;@ byte. Compressed in the DecompressCore format ($100 bytes unpacked, $32 packed).
AttrMap_AF::
	db $00, $01, $01, $11, $33, $11, $01, $02, $03, $01, $fa, $ff, $33, $22, $01
	db $01, $0b, $33, $01, $51, $0f, $0c, $01, $02, $04, $01, $78, $0f, $16, $22, $01
	db $b1, $03, $01, $09, $05, $01, $c1, $03, $01, $b9, $0f, $06, $01, $02, $02, $01
	db $d8, $0f, $05

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $50 screen 14, map $51 screen 10, map $52 screen 6, map $53 screen 2, map $5F screen
;@ 14, map $61 screen 1, map $62 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $2F packed).
AttrMap_B0::
	db $00, $01, $01, $11, $01, $00, $03, $33, $11, $01, $fa, $ff, $14
	db $22, $01, $31, $02, $01, $08, $05, $33, $01, $41, $03, $01, $39, $0c, $22, $01
	db $3a, $0b, $33, $01, $5a, $0f, $05, $01, $00, $04, $01, $7a, $0f, $4d, $01, $9a
	db $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $50 screen 15, map $51 screen 11, map $52 screen 7, map $53 screen 3, map $5F screen
;@ 15, map $61 screen 2, map $62 screen 1, map $63 screen 0 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $47 packed).
AttrMap_B1::
	db $00, $01, $01, $11, $33, $11, $01, $00, $00, $11, $11, $11, $01, $fa
	db $ff, $15, $22, $22, $01, $04, $0a, $33, $33, $01, $34, $0f, $0a, $11, $01, $02
	db $0b, $01, $61, $0f, $0c, $22, $22, $11, $01, $30, $00, $22, $22, $22, $01, $fa
	db $f2, $01, $43, $00, $01, $41, $00, $33, $33, $01, $9a, $0f, $03, $01, $03, $03
	db $11, $33, $01, $09, $07, $01, $c4, $0f, $19

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $51 screen 12, map $52 screen 8, map $53 screen 4, map $61 screen 3, map $62 screen
;@ 2, map $63 screen 1, map $64 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $20 packed).
AttrMap_B2::
	db $00, $01, $01, $11, $01, $00, $05
	db $01, $fa, $ff, $36, $22, $22, $22, $01, $06, $09, $33, $33, $33, $01, $56, $0f
	db $4a, $11, $01, $65, $01, $01, $b9, $0f, $24

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $54 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3C packed).
AttrMap_B3::
	db $00, $01, $01, $11, $01, $00, $05
	db $01, $fa, $ff, $04, $22, $01, $21, $04, $01, $1a, $0f, $04, $33, $01, $41, $04
	db $01, $3a, $0f, $07, $01, $04, $09, $01, $61, $0f, $01, $01, $35, $0b, $01, $84
	db $09, $00, $33, $33, $01, $40, $00, $01, $f8, $f5, $01, $a1, $0f, $05, $01, $49
	db $04, $01, $c1, $0f, $1c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $54 screen 1 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4B packed).
AttrMap_B4::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $03
	db $22, $22, $22, $22, $11, $01, $20, $00, $22, $01, $1a, $0f, $03, $33, $33, $33
	db $33, $01, $09, $03, $01, $3b, $0f, $02, $11, $11, $11, $33, $11, $01, $3f, $01
	db $01, $5a, $0f, $03, $22, $22, $22, $01, $73, $0f, $0a, $01, $fc, $f1, $01, $95
	db $0f, $08, $01, $67, $00, $11, $00, $33, $00, $01, $08, $04, $01, $c0, $0f, $1d
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $54 screen 2 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $30 packed).
AttrMap_B5::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $03, $22, $01, $20, $04, $01
	db $19, $0f, $04, $00, $00, $00, $33, $01, $43, $01, $01, $39, $0f, $04, $01, $43
	db $02, $01, $56, $0f, $47, $11, $11, $33, $01, $42, $01, $00, $01, $b9, $0f, $24
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $54 screen 4 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3C packed).
AttrMap_B6::
	db $00, $01, $01, $11, $00, $33, $33, $11, $33, $33, $33, $00, $33, $01, $fa, $ff
	db $29, $00, $00, $01, $38, $0f, $0c, $11, $11, $11, $01, $5a, $0f, $0a, $22, $22
	db $22, $01, $7a, $0f, $07, $22, $01, $09, $03, $01, $9c, $0f, $03, $01, $f2, $fc
	db $01, $f2, $fe, $33, $33, $11, $01, $67, $09, $01, $e4, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $54 screen 5 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $53 packed).
AttrMap_B7::
	db $00, $01, $01, $33
	db $33, $33, $00, $11, $00, $33, $00, $11, $11, $01, $fa, $ff, $07, $22, $01, $15
	db $0f, $0c, $01, $20, $01, $22, $01, $3a, $0f, $03, $11, $01, $60, $00, $01, $fd
	db $f1, $01, $5a, $0f, $03, $22, $22, $22, $22, $01, $09, $03, $01, $7b, $0f, $02
	db $01, $fe, $f0, $11, $01, $69, $03, $01, $9c, $0f, $03, $00, $00, $11, $33, $33
	db $01, $62, $02, $01, $bd, $0f, $00, $11, $01, $c4, $00, $01, $d5, $0f, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $54 screen 6 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3D packed).
AttrMap_B8::
	db $00
	db $01, $01, $11, $11, $33, $00, $33, $33, $33, $33, $00, $11, $01, $fa, $ff, $23
	db $22, $22, $01, $32, $0f, $0b, $01, $fc, $f0, $01, $54, $0f, $09, $01, $04, $00
	db $01, $74, $0f, $09, $01, $f7, $f6, $01, $9a, $0f, $03, $11, $01, $00, $00, $01
	db $62, $00, $01, $b9, $0f, $0b, $11, $11, $01, $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $54 screen 8 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $35 packed).
AttrMap_B9::
	db $00, $01, $01, $11
	db $00, $33, $33, $33, $33, $11, $11, $11, $11, $01, $fa, $ff, $09, $22, $22, $22
	db $22, $01, $1a, $0f, $04, $01, $02, $00, $01, $41, $01, $01, $3a, $0f, $28, $01
	db $f5, $f8, $01, $81, $0f, $01, $01, $45, $0f, $29, $01, $e0, $05, $01, $da, $0f
	db $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $54 screen 9 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $41 packed).
AttrMap_BA::
	db $00, $01, $01, $11, $11, $33, $33, $01, $01, $00, $11, $11, $01, $fa, $ff
	db $03, $22, $22, $01, $12, $0f, $0b, $33, $33, $01, $02, $01, $22, $22, $22, $01
	db $3a, $0f, $07, $22, $01, $40, $00, $33, $01, $5a, $0f, $03, $01, $e0, $ff, $0d
	db $01, $65, $01, $01, $77, $07, $01, $a0, $0f, $1d, $11, $01, $e0, $05, $01, $da
	db $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $54 screen 10 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3D packed).
AttrMap_BB::
	db $00, $01, $01, $11, $11, $11, $33, $01, $fd, $f2, $01, $fa, $ff, $0a
	db $22, $22, $01, $19, $0f, $04, $22, $22, $22, $01, $03, $00, $33, $33, $01, $39
	db $0f, $04, $33, $33, $33, $01, $53, $0f, $0a, $01, $5e, $03, $01, $77, $0f, $08
	db $01, $5a, $03, $01, $99, $0f, $24, $11, $01, $e0, $05, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $55 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $31 packed).
AttrMap_BC::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $04, $22, $01, $21, $04, $01, $1a
	db $0f, $04, $01, $f1, $fc, $01, $41, $0f, $1f, $11, $11, $33, $01, $85, $00, $01
	db $7a, $0f, $0b, $01, $78, $0c, $01, $78, $0c, $01, $08, $05, $01, $c1, $0f, $1c
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $55 screen 1 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $34 packed).
AttrMap_BD::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $03, $22, $01, $20, $05, $01
	db $1a, $0f, $03, $00, $00, $33, $01, $42, $01, $01, $f6, $f6, $01, $42, $0c, $01
	db $e2, $ff, $0b, $01, $42, $02, $01, $44, $06, $01, $80, $0c, $01, $e0, $ff, $2d
	db $01, $00, $0f, $0d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $55 screen 2 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3B packed).
AttrMap_BE::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $03, $22
	db $01, $20, $04, $01, $19, $0f, $04, $01, $f7, $f6, $01, $3a, $0f, $05, $01, $04
	db $03, $01, $59, $0f, $04, $33, $01, $1f, $03, $01, $78, $0f, $05, $01, $7d, $00
	db $01, $a3, $00, $01, $98, $0f, $05, $01, $66, $00, $11, $01, $b5, $0f, $28

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $55 screen 4 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4B packed).
AttrMap_BF::
	db $00
	db $01, $01, $11, $00, $00, $11, $11, $33, $33, $33, $11, $11, $01, $fa, $ff, $0b
	db $22, $22, $01, $1a, $0f, $04, $01, $26, $00, $33, $33, $33, $01, $f8, $f5, $01
	db $41, $0e, $01, $61, $01, $01, $58, $0f, $09, $11, $01, $84, $01, $01, $7a, $0f
	db $07, $22, $01, $a4, $01, $01, $9a, $0f, $04, $00, $01, $46, $06, $01, $bc, $0f
	db $05, $01, $61, $00, $01, $08, $06, $01, $e2, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $55 screen 5 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $40 packed).
AttrMap_C0::
	db $00, $01, $01, $11, $01, $00
	db $05, $01, $fa, $ff, $03, $22, $01, $20, $05, $01, $1a, $0f, $03, $01, $fb, $f1
	db $33, $01, $45, $00, $01, $3a, $0f, $23, $01, $07, $01, $33, $33, $33, $01, $08
	db $07, $01, $83, $09, $01, $27, $01, $01, $95, $0f, $08, $01, $40, $04, $01, $b8
	db $0f, $05, $11, $11, $33, $33, $01, $d4, $0f, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $55 screen 6 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3A packed).
AttrMap_C1::
	db $00, $01, $01, $11, $11, $00
	db $11, $11, $33, $33, $33, $00, $11, $01, $fa, $ff, $03, $22, $22, $01, $12, $0f
	db $0b, $33, $33, $33, $01, $03, $01, $33, $01, $39, $0f, $24, $11, $11, $00, $22
	db $22, $01, $75, $0f, $0b, $01, $45, $00, $01, $97, $0f, $09, $11, $01, $be, $04
	db $01, $bc, $0f, $21

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $55 screen 8 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3F packed).
AttrMap_C2::
	db $00, $01, $01, $11, $00, $33, $01, $02, $01, $11, $11, $01
	db $fa, $ff, $0b, $22, $22, $01, $1a, $0f, $07, $01, $f4, $fc, $01, $f4, $fd, $11
	db $01, $65, $00, $01, $5a, $0f, $09, $22, $22, $01, $28, $09, $01, $85, $0d, $01
	db $42, $06, $01, $a0, $0f, $05, $01, $42, $04, $01, $c0, $0d, $01, $e0, $05, $01
	db $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $55 screen 9 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4A packed).
AttrMap_C3::
	db $00, $01, $01, $11, $11, $33, $01, $02, $01, $11, $11, $01, $fa
	db $ff, $03, $22, $22, $01, $02, $02, $22, $22, $01, $1a, $0f, $03, $01, $e0, $ff
	db $0f, $01, $08, $04, $01, $5a, $0f, $03, $22, $22, $01, $38, $0a, $01, $80, $0c
	db $01, $fa, $f2, $01, $02, $00, $01, $9a, $0f, $03, $01, $02, $01, $01, $9b, $0b
	db $01, $a9, $08, $01, $60, $00, $01, $e0, $02, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $55 screen 10 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $3C packed).
AttrMap_C4::
	db $00, $01, $01
	db $11, $11, $00, $11, $01, $fe, $f4, $01, $fc, $ff, $01, $22, $22, $01, $12, $0f
	db $0b, $01, $1d, $00, $01, $34, $0f, $0c, $01, $fd, $f5, $01, $5c, $0f, $21, $33
	db $01, $a0, $01, $01, $20, $02, $01, $9c, $0f, $01, $01, $f7, $f6, $01, $ba, $0f
	db $03, $11, $01, $e0, $05, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $56 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $29 packed).
AttrMap_C5::
	db $00, $01, $01, $11, $01, $00, $05
	db $01, $fa, $ff, $04, $22, $01, $21, $04, $01, $1a, $0f, $04, $01, $f1, $fc, $01
	db $41, $0d, $33, $01, $62, $03, $01, $5a, $0f, $05, $01, $42, $0f, $2d, $01, $a2
	db $0f, $2b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $56 screen 1 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $38 packed).
AttrMap_C6::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $03, $22, $01, $20
	db $05, $01, $1a, $0f, $03, $01, $fa, $f2, $33, $33, $33, $33, $01, $3a, $0f, $03
	db $01, $46, $00, $33, $01, $55, $0f, $08, $01, $40, $0f, $10, $01, $f3, $f9, $01
	db $a0, $0f, $04, $01, $97, $0c, $01, $c7, $0f, $16

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $56 screen 2 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $31 packed).
AttrMap_C7::
	db $00, $01, $01, $11, $01, $00
	db $05, $01, $fa, $ff, $03, $22, $01, $20, $04, $01, $19, $0f, $04, $33, $01, $40
	db $02, $00, $00, $01, $39, $0f, $0b, $33, $01, $58, $0f, $25, $01, $f7, $f6, $01
	db $9a, $0f, $03, $01, $40, $0f, $14, $01, $47, $0f, $06

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $56 screen 4 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $29 packed).
AttrMap_C8::
	db $00, $01, $01, $11, $00
	db $33, $01, $02, $03, $01, $fa, $ff, $05, $01, $01, $04, $01, $1a, $0f, $06, $01
	db $f3, $fb, $01, $42, $0f, $3d, $01, $06, $06, $01, $9c, $0f, $08, $01, $07, $0b
	db $01, $c6, $0f, $17

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $56 screen 5 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $1E packed).
AttrMap_C9::
	db $00, $01, $01, $33, $33, $33, $01, $fc, $f7, $01, $fe, $ff
	db $1f, $01, $fd, $f2, $01, $39, $06, $01, $40, $0f, $4d, $01, $60, $0c, $01, $00
	db $0f, $2d

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $56 screen 6 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $20 packed).
AttrMap_CA::
	db $00, $01, $01, $33, $01, $00, $02, $00, $00, $11, $01, $fa, $ff, $23
	db $01, $f7, $f5, $01, $39, $0f, $4d, $01, $59, $0f, $04, $01, $02, $03, $01, $b7
	db $0f, $26

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $56 screen 8 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $27 packed).
AttrMap_CB::
	db $00, $01, $01, $11, $00, $33, $33, $33, $33, $01, $01, $00, $01, $fa
	db $ff, $4d, $01, $3a, $0f, $2a, $01, $f7, $fc, $01, $f7, $f7, $01, $f2, $fc, $01
	db $f2, $fb, $01, $e0, $05, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $56 screen 9 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $2A packed).
AttrMap_CC::
	db $00, $01, $01, $33, $33, $33, $01
	db $fc, $f7, $01, $fe, $ff, $26, $01, $f7, $fc, $01, $f7, $fb, $33, $01, $07, $0b
	db $01, $66, $0c, $01, $46, $0f, $07, $01, $c0, $ff, $2d, $11, $01, $e0, $05, $01
	db $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $56 screen 10 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $30 packed).
AttrMap_CD::
	db $00, $01, $01, $33, $01, $00, $00, $01, $fc, $f0, $11, $01, $fa
	db $ff, $23, $01, $f7, $f5, $01, $39, $0f, $04, $01, $00, $01, $01, $04, $00, $01
	db $59, $0f, $04, $01, $40, $0f, $0d, $01, $80, $0f, $2d, $11, $01, $e0, $05, $01
	db $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $57 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4B packed).
AttrMap_CE::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $04, $22, $22
	db $22, $22, $01, $20, $01, $01, $1a, $0f, $04, $33, $33, $33, $33, $01, $40, $01
	db $01, $3a, $0f, $0b, $01, $08, $05, $01, $61, $0d, $01, $00, $00, $01, $76, $0f
	db $0a, $22, $22, $22, $33, $33, $01, $38, $06, $01, $a2, $0d, $01, $41, $00, $01
	db $47, $07, $01, $c2, $0e, $01, $83, $00, $01, $78, $07, $01, $e3, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $57 screen 1 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $51 packed).
AttrMap_CF::
	db $00, $01
	db $01, $11, $01, $00, $05, $01, $fa, $ff, $03, $22, $22, $22, $22, $11, $01, $20
	db $00, $22, $01, $1a, $0f, $03, $33, $33, $33, $33, $11, $01, $40, $00, $33, $01
	db $3a, $0f, $03, $11, $11, $11, $33, $11, $33, $01, $06, $09, $01, $63, $0f, $00
	db $01, $26, $06, $01, $80, $0c, $22, $22, $22, $01, $43, $09, $01, $a0, $0c, $01
	db $40, $02, $01, $06, $06, $01, $c0, $0c, $01, $00, $01, $01, $d5, $0f, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $57 screen 2 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $49 packed).
AttrMap_D0::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $03, $22, $22, $22, $11, $22, $01
	db $24, $00, $01, $19, $0f, $04, $33, $33, $33, $11, $33, $01, $44, $00, $01, $39
	db $0f, $04, $01, $00, $00, $33, $01, $61, $01, $01, $5a, $0f, $03, $01, $24, $00
	db $33, $22, $22, $01, $77, $0f, $06, $01, $44, $01, $01, $41, $00, $01, $99, $0f
	db $04, $01, $62, $04, $01, $b8, $0f, $25

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $57 screen 4 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4D packed).
AttrMap_D1::
	db $00, $01, $01, $11, $33, $11, $33, $11
	db $11, $01, $02, $00, $01, $fa, $ff, $27, $22, $22, $22, $33, $22, $22, $01, $3a
	db $0f, $05, $22, $33, $01, $63, $02, $01, $5a, $0f, $05, $33, $33, $01, $03, $00
	db $01, $08, $06, $01, $82, $0b, $01, $04, $01, $22, $22, $01, $48, $05, $01, $a1
	db $0c, $01, $44, $00, $01, $80, $01, $01, $ba, $0f, $04, $01, $81, $01, $01, $83
	db $00, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $57 screen 5 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $51 packed).
AttrMap_D2::
	db $00, $01, $01, $11, $01, $00, $00, $33, $01, $00, $00
	db $01, $fa, $ff, $09, $22, $22, $22, $22, $01, $1a, $0f, $03, $01, $26, $00, $22
	db $33, $01, $45, $00, $01, $3a, $0f, $03, $01, $45, $01, $01, $05, $07, $01, $60
	db $0c, $01, $00, $03, $01, $27, $0b, $01, $86, $06, $01, $26, $00, $11, $33, $11
	db $01, $47, $09, $01, $a4, $08, $01, $62, $01, $01, $b5, $0f, $08, $01, $02, $01
	db $01, $05, $0a, $01, $e3, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $57 screen 6 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $51 packed).
AttrMap_D3::
	db $00, $01, $01, $11, $11, $33, $11, $01, $00, $00
	db $33, $11, $01, $fa, $ff, $03, $22, $22, $33, $22, $01, $14, $0f, $09, $33, $33
	db $33, $33, $01, $34, $0f, $09, $01, $03, $01, $01, $55, $0f, $08, $22, $22, $22
	db $01, $43, $01, $11, $01, $79, $0f, $04, $01, $40, $00, $22, $11, $33, $22, $22
	db $01, $99, $0f, $08, $33, $11, $01, $41, $00, $01, $ba, $0f, $03, $11, $01, $60
	db $02, $01, $57, $08, $01, $e3, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $57 screen 8 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4B packed).
AttrMap_D4::
	db $00, $01, $01, $11, $33, $33, $33, $33, $11
	db $33, $33, $11, $11, $01, $fa, $ff, $0b, $22, $22, $01, $1a, $0f, $08, $22, $01
	db $01, $00, $01, $3a, $0f, $08, $01, $02, $00, $01, $09, $08, $01, $65, $08, $01
	db $80, $04, $01, $29, $04, $01, $81, $0c, $22, $01, $a1, $03, $33, $30, $01, $9b
	db $0f, $03, $01, $61, $03, $01, $58, $0c, $01, $48, $05, $01, $80, $05, $01, $da
	db $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $57 screen 9 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $59 packed).
AttrMap_D5::
	db $00, $01, $01, $11, $11, $11, $33, $11, $33, $11, $11, $11, $11, $01
	db $fa, $ff, $03, $22, $22, $22, $33, $22, $33, $11, $22, $22, $22, $01, $1a, $0f
	db $03, $33, $01, $40, $01, $11, $33, $33, $33, $01, $3a, $0f, $03, $01, $06, $00
	db $01, $00, $01, $01, $09, $06, $01, $63, $09, $22, $01, $80, $02, $01, $77, $0f
	db $06, $01, $40, $02, $33, $33, $01, $38, $0a, $01, $a6, $0e, $01, $48, $0a, $01
	db $c6, $06, $01, $60, $03, $01, $07, $08, $01, $e3, $09

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $57 screen 10 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $54 packed).
AttrMap_D6::
	db $00, $01, $01, $11, $11
	db $11, $11, $33, $01, $01, $01, $01, $fa, $ff, $03, $22, $22, $22, $11, $33, $01
	db $21, $00, $01, $19, $0f, $04, $33, $33, $33, $11, $01, $40, $01, $01, $39, $0f
	db $04, $01, $02, $02, $01, $06, $08, $01, $62, $0e, $22, $22, $22, $22, $01, $78
	db $0f, $05, $22, $22, $33, $22, $33, $01, $a4, $00, $01, $99, $0f, $04, $01, $a4
	db $01, $01, $b5, $0f, $08, $01, $63, $01, $01, $63, $01, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $58 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4A packed).
AttrMap_D7::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $04, $22, $22, $22, $22, $01, $20
	db $01, $01, $1a, $0f, $04, $33, $33, $33, $33, $01, $40, $01, $01, $3a, $0f, $05
	db $11, $11, $33, $22, $33, $11, $33, $01, $09, $04, $01, $61, $0f, $01, $01, $43
	db $00, $01, $79, $0f, $08, $11, $11, $01, $96, $0f, $09, $01, $21, $00, $01, $b6
	db $0f, $09, $01, $e1, $01, $01, $d7, $0f, $06

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $58 screen 1 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4F packed).
AttrMap_D8::
	db $00, $01, $01, $11, $01, $00, $05
	db $01, $fa, $ff, $03, $22, $01, $20, $05, $01, $1a, $0f, $03, $33, $01, $40, $05
	db $01, $3a, $0f, $03, $11, $01, $40, $00, $11, $33, $01, $07, $06, $01, $61, $0c
	db $11, $11, $11, $33, $11, $33, $01, $27, $05, $01, $80, $0d, $22, $22, $22, $33
	db $01, $60, $01, $01, $9a, $0f, $04, $01, $61, $01, $01, $65, $00, $01, $ba, $0f
	db $05, $01, $00, $01, $01, $d7, $0f, $06

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $58 screen 2 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4A packed).
AttrMap_D9::
	db $00, $01, $01, $11, $01, $00, $05, $01
	db $fa, $ff, $03, $22, $01, $20, $03, $01, $18, $0f, $05, $33, $01, $40, $03, $22
	db $01, $39, $0f, $04, $11, $11, $33, $01, $00, $00, $33, $33, $01, $59, $0f, $04
	db $22, $22, $33, $01, $25, $01, $01, $78, $0f, $05, $01, $42, $04, $01, $98, $0f
	db $05, $01, $64, $00, $01, $66, $00, $01, $b8, $0f, $0a, $01, $c2, $00, $01, $d9
	db $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $58 screen 4 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $44 packed).
AttrMap_DA::
	db $00, $01, $01, $11, $33, $01, $01, $01, $11, $33, $11, $01, $fa, $ff
	db $07, $11, $11, $11, $01, $17, $0f, $0b, $22, $22, $22, $01, $38, $0f, $07, $01
	db $60, $00, $01, $04, $00, $01, $5a, $0f, $09, $01, $24, $00, $01, $7a, $0f, $09
	db $22, $22, $22, $22, $01, $9a, $0f, $09, $01, $01, $00, $01, $ba, $0f, $09, $01
	db $84, $00, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $58 screen 5 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $56 packed).
AttrMap_DB::
	db $00, $01, $01, $11, $33, $11, $01, $02, $00, $33
	db $11, $11, $01, $fa, $ff, $05, $22, $22, $22, $11, $22, $33, $22, $01, $19, $0f
	db $06, $33, $33, $33, $01, $40, $00, $01, $39, $0f, $05, $01, $04, $01, $01, $56
	db $0f, $09, $22, $22, $33, $01, $63, $00, $22, $01, $7a, $0f, $03, $22, $22, $01
	db $42, $01, $11, $33, $33, $01, $9a, $0f, $03, $01, $42, $00, $01, $62, $01, $01
	db $09, $03, $01, $c0, $0c, $01, $02, $01, $01, $d5, $0f, $08

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $58 screen 6 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $42 packed).
AttrMap_DC::
	db $00, $01, $01, $11
	db $11, $11, $33, $01, $01, $00, $33, $11, $01, $fa, $ff, $28, $22, $01, $36, $0f
	db $0c, $33, $01, $56, $0f, $07, $22, $22, $01, $45, $01, $01, $77, $0f, $06, $33
	db $33, $33, $33, $22, $01, $43, $01, $01, $9a, $0f, $03, $11, $01, $a0, $00, $01
	db $63, $01, $01, $ba, $0f, $05, $01, $60, $02, $11, $01, $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $58 screen 8 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4F packed).
AttrMap_DD::
	db $00, $01
	db $01, $11, $33, $01, $00, $03, $11, $01, $fa, $ff, $05, $22, $01, $01, $01, $22
	db $22, $01, $1a, $0f, $05, $33, $01, $01, $01, $33, $33, $01, $3a, $0f, $04, $01
	db $60, $00, $01, $05, $08, $01, $61, $0c, $22, $22, $22, $01, $22, $00, $01, $28
	db $05, $01, $81, $0c, $33, $01, $a1, $00, $22, $01, $47, $09, $01, $a4, $0e, $33
	db $01, $07, $07, $01, $c2, $0b, $01, $e0, $05, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $58 screen 9 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $53 packed).
AttrMap_DE::
	db $00, $01, $01
	db $11, $01, $00, $01, $33, $11, $33, $11, $01, $fa, $ff, $03, $22, $22, $11, $22
	db $22, $22, $01, $16, $0f, $07, $33, $33, $11, $33, $33, $01, $40, $00, $01, $39
	db $0f, $04, $01, $42, $01, $01, $55, $0f, $08, $22, $33, $01, $00, $04, $01, $7a
	db $0f, $03, $33, $33, $01, $22, $00, $22, $22, $33, $22, $01, $9a, $0f, $03, $01
	db $03, $00, $01, $61, $02, $01, $ba, $0f, $06, $01, $e0, $03, $01, $da, $0f, $03
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $58 screen 10 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $52 packed).
AttrMap_DF::
	db $00, $01, $01, $11, $33, $11, $11, $11, $33, $01, $00, $00, $01, $fa, $ff, $05
	db $22, $22, $22, $33, $11, $33, $22, $01, $19, $0f, $06, $01, $41, $00, $11, $33
	db $33, $01, $39, $0f, $05, $01, $60, $03, $01, $58, $0f, $06, $22, $22, $22, $22
	db $01, $75, $0f, $08, $22, $01, $41, $00, $01, $22, $01, $01, $9a, $0f, $03, $33
	db $33, $11, $01, $40, $03, $01, $ba, $0f, $03, $01, $60, $04, $01, $08, $05, $01
	db $e1, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $59 screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $52 packed).
AttrMap_E0::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $04, $22, $22, $22
	db $22, $01, $20, $01, $01, $1a, $0f, $04, $33, $33, $33, $33, $22, $01, $41, $00
	db $01, $3a, $0f, $05, $11, $01, $40, $00, $01, $07, $06, $01, $61, $0d, $22, $01
	db $00, $01, $01, $38, $06, $01, $82, $0c, $33, $01, $21, $00, $22, $01, $48, $07
	db $01, $a3, $0a, $01, $40, $01, $01, $64, $00, $01, $ba, $0f, $06, $01, $e0, $03
	db $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $59 screen 1 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $58 packed).
AttrMap_E1::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $03, $22
	db $22, $11, $11, $22, $01, $24, $00, $01, $19, $0f, $04, $33, $33, $11, $11, $33
	db $01, $44, $00, $01, $39, $0f, $04, $11, $33, $22, $22, $01, $46, $00, $33, $22
	db $01, $5a, $0f, $03, $01, $63, $00, $01, $64, $01, $33, $01, $7a, $0f, $03, $01
	db $40, $00, $11, $11, $33, $11, $01, $48, $08, $01, $a4, $08, $01, $60, $00, $22
	db $22, $01, $b6, $0f, $09, $01, $82, $03, $01, $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $59 screen 2 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $34 packed).
AttrMap_E2::
	db $00, $01, $01, $11
	db $01, $00, $05, $01, $fa, $ff, $05, $22, $01, $22, $02, $01, $19, $0f, $06, $33
	db $01, $42, $02, $01, $39, $0f, $04, $22, $22, $33, $11, $01, $62, $02, $01, $5a
	db $0f, $03, $01, $46, $00, $01, $74, $0f, $09, $01, $00, $00, $01, $94, $0f, $49
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $59 screen 4 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $41 packed).
AttrMap_E3::
	db $00, $01, $01, $11, $11, $33, $01, $00, $03, $01, $fa, $ff, $04, $22, $33, $22
	db $11, $33, $22, $22, $01, $18, $0f, $06, $33, $33, $33, $01, $40, $00, $01, $38
	db $0f, $07, $01, $60, $01, $11, $11, $01, $59, $0f, $0a, $22, $22, $22, $22, $01
	db $7a, $0f, $09, $01, $45, $00, $01, $9a, $0f, $08, $01, $00, $01, $01, $ba, $0f
	db $23

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $59 screen 5 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $49 packed).
AttrMap_E4::
	db $00, $01, $01, $11, $33, $01, $01, $01, $11, $33, $11, $01, $fa, $ff, $06
	db $11, $11, $11, $01, $16, $0f, $0a, $22, $22, $22, $01, $36, $0f, $08, $01, $00
	db $02, $01, $57, $0f, $06, $01, $44, $02, $01, $24, $00, $01, $7a, $0f, $03, $01
	db $04, $02, $11, $22, $01, $98, $0f, $05, $11, $01, $23, $00, $22, $22, $33, $01
	db $b8, $0f, $0a, $01, $04, $00, $01, $d9, $0f, $04

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $59 screen 6 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $46 packed).
AttrMap_E5::
	db $00, $01, $01, $11, $11, $11
	db $11, $33, $01, $03, $01, $01, $fa, $ff, $04, $22, $22, $22, $01, $14, $0f, $0a
	db $33, $33, $33, $01, $34, $0f, $0b, $01, $00, $04, $01, $5a, $0f, $05, $22, $22
	db $22, $01, $75, $0f, $0a, $33, $33, $33, $01, $23, $01, $01, $9a, $0f, $04, $01
	db $03, $00, $01, $43, $01, $01, $ba, $0f, $08, $01, $01, $01, $01, $da, $0f, $03
;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $59 screen 8 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4B packed).
AttrMap_E6::
	db $00, $01, $01, $11, $33, $11, $33, $11, $11, $01, $02, $00, $01, $fa, $ff, $0b
	db $22, $22, $01, $1a, $0f, $06, $01, $42, $00, $33, $33, $33, $01, $3a, $0f, $05
	db $22, $01, $62, $00, $33, $33, $01, $09, $05, $01, $62, $0c, $01, $81, $03, $01
	db $79, $0f, $05, $01, $a0, $03, $33, $01, $29, $04, $01, $a1, $0f, $05, $01, $49
	db $04, $01, $c1, $0f, $04, $01, $08, $05, $01, $e1, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $59 screen 9 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $5E packed).
AttrMap_E7::
	db $00, $01, $01, $11, $11
	db $11, $11, $33, $33, $33, $33, $11, $11, $01, $fa, $ff, $03, $22, $22, $22, $22
	db $33, $11, $33, $33, $22, $22, $01, $1a, $0f, $03, $01, $04, $00, $01, $24, $00
	db $33, $33, $01, $3a, $0f, $03, $01, $00, $00, $11, $11, $33, $11, $01, $08, $08
	db $01, $64, $0a, $01, $20, $01, $22, $01, $28, $04, $01, $80, $0c, $22, $22, $01
	db $40, $01, $01, $47, $05, $01, $a0, $0c, $01, $05, $01, $01, $60, $01, $01, $ba
	db $0f, $03, $01, $c3, $03, $01, $d7, $0f, $06

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $59 screen 10 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $4F packed).
AttrMap_E8::
	db $00, $01, $01, $11, $11, $33, $11
	db $33, $11, $01, $00, $00, $01, $fa, $ff, $03, $22, $22, $33, $11, $33, $22, $01
	db $20, $00, $01, $1a, $0f, $03, $33, $33, $33, $11, $33, $01, $44, $00, $01, $39
	db $0f, $04, $11, $01, $60, $05, $01, $5a, $0f, $03, $22, $22, $01, $72, $0f, $0b
	db $33, $01, $24, $00, $01, $a2, $00, $01, $99, $0f, $04, $01, $43, $02, $01, $56
	db $07, $01, $c1, $0c, $01, $61, $0f, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $5A screen 0 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $36 packed).
AttrMap_E9::
	db $00, $01, $01, $11, $01, $00, $05, $01
	db $fa, $ff, $24, $22, $33, $01, $42, $01, $22, $01, $39, $0f, $05, $33, $33, $22
	db $01, $61, $01, $01, $59, $0f, $07, $01, $42, $02, $01, $79, $0f, $06, $01, $41
	db $01, $22, $01, $98, $0f, $07, $01, $82, $0f, $0c, $01, $01, $0f, $0c

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $5A screen 4, map $5B screen 0 (MapPaletteTable), unpacked to wScreenMap by
;@ LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $25 packed).
AttrMap_EA::
	db $00, $01
	db $01, $33, $11, $01, $01, $03, $33, $01, $fa, $ff, $25, $33, $01, $42, $01, $01
	db $38, $0f, $08, $22, $33, $33, $22, $01, $57, $0f, $49, $01, $43, $0f, $0c, $01
	db $02, $0f, $0b

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $5A screen 8, map $5B screen 4, map $5C screen 0 (MapPaletteTable), unpacked to
;@ wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100
;@ bytes unpacked, $28 packed).
AttrMap_EB::
	db $00, $01, $01, $33, $33, $11, $01, $02, $01, $33, $33, $01, $fa
	db $ff, $26, $22, $22, $22, $22, $01, $37, $0f, $09, $33, $33, $01, $60, $01, $01
	db $5a, $0f, $46, $01, $43, $0f, $0d, $01, $03, $0f, $0a

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $5A screen 12, map $5B screen 8, map $5C screen 4, map $5D screen 0
;@ (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $33 packed).
AttrMap_EC::
	db $00, $01, $01, $01, $a0
	db $ff, $4d, $00, $02, $22, $01, $62, $01, $20, $01, $01, $04, $22, $11, $01, $72
	db $01, $22, $01, $69, $06, $22, $11, $11, $22, $01, $77, $0f, $09, $01, $73, $0f
	db $2a, $33, $33, $33, $33, $11, $11, $01, $e0, $00, $01, $da, $0f, $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $5A screen 12 version 1, map $5A screen 12 version 2, map $5A screen 12 version 3,
;@ map $5A screen 12 version 4, map $5B screen 8 version 1, map $5B screen 8 version 2, map $5B screen 8 version
;@ 3, map $5B screen 8 version 4, and 8 more (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $33 packed).
AttrMap_ED::
	db $00, $01
	db $01, $01, $a0, $ff, $4d, $00, $02, $22, $01, $62, $01, $20, $01, $01, $04, $22
	db $11, $01, $72, $01, $22, $01, $69, $06, $22, $11, $11, $22, $01, $77, $0f, $09
	db $01, $73, $0f, $2a, $33, $33, $33, $33, $11, $11, $01, $e0, $00, $01, $da, $0f
	db $03

;@ path: gfx/palettes/attrmaps
;@ CGB attribute map of map $5D screen 12, map $5D screen 12 version 1, map $5D screen 12 version 2, map $5D
;@ screen 12 version 3, map $5E screen 0, map $5E screen 0 version 1, map $5E screen 0 version 2, map $5E screen
;@ 0 version 3 (MapPaletteTable), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte.
;@ Compressed in the DecompressCore format ($100 bytes unpacked, $13 packed).
AttrMap_EE::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $4d, $01, $5a, $0f, $4d
	db $01, $9a, $0f, $23

;@ path: unused/filler
;@ Unused filler up to the end of the bank.
Unused_3C::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
