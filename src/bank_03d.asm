INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $03d", ROMX[$4000], BANK[$3d]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_3D::
	db $3d

;@ path: gfx/palettes/floorattrmaps
;@ Entry table of bank $3D: the address of each compressed block (entry number = position), as DecompressSetup
;@ finds it for Decompress / DecompressVRAM (bank, entry).
FarTable_3D::
	dw FloorAttrMap_3D_00
	dw FloorAttrMap_3D_01
	dw FloorAttrMap_3D_02
	dw FloorAttrMap_3D_03
	dw FloorAttrMap_3D_04
	dw FloorAttrMap_3D_05
	dw FloorAttrMap_3D_06
	dw FloorAttrMap_3D_07
	dw FloorAttrMap_3D_08
	dw FloorAttrMap_3D_09
	dw FloorAttrMap_3D_0A
	dw FloorAttrMap_3D_0B
	dw FloorAttrMap_3D_0C
	dw FloorAttrMap_3D_0D
	dw FloorAttrMap_3D_0E
	dw FloorAttrMap_3D_0F
	dw FloorAttrMap_3D_10
	dw FloorAttrMap_3D_11
	dw FloorAttrMap_3D_12
	dw FloorAttrMap_3D_13
	dw FloorAttrMap_3D_14
	dw FloorAttrMap_3D_15
	dw FloorAttrMap_3D_16
	dw FloorAttrMap_3D_17
	dw FloorAttrMap_3D_18
	dw FloorAttrMap_3D_19
	dw FloorAttrMap_3D_1A
	dw FloorAttrMap_3D_1B
	dw FloorAttrMap_3D_1C
	dw FloorAttrMap_3D_1D
	dw FloorAttrMap_3D_1E
	dw FloorAttrMap_3D_1F
	dw FloorAttrMap_3D_20
	dw FloorAttrMap_3D_21
	dw FloorAttrMap_3D_22
	dw FloorAttrMap_3D_23
	dw FloorAttrMap_3D_24
	dw FloorAttrMap_3D_25
	dw FloorAttrMap_3D_26
	dw FloorAttrMap_3D_27
	dw FloorAttrMap_3D_28
	dw FloorAttrMap_3D_29
	dw FloorAttrMap_3D_2A
	dw FloorAttrMap_3D_2B
	dw FloorAttrMap_3D_2C
	dw FloorAttrMap_3D_2D
	dw FloorAttrMap_3D_2E
	dw FloorAttrMap_3D_2F
	dw FloorAttrMap_3D_30
	dw FloorAttrMap_3D_31
	dw FloorAttrMap_3D_32
	dw FloorAttrMap_3D_33
	dw FloorAttrMap_3D_34
	dw FloorAttrMap_3D_35
	dw FloorAttrMap_3D_36
	dw FloorAttrMap_3D_37
	dw FloorAttrMap_3D_38
	dw FloorAttrMap_3D_39
	dw FloorAttrMap_3D_3A
	dw FloorAttrMap_3D_3B
	dw FloorAttrMap_3D_3C
	dw FloorAttrMap_3D_3D
	dw FloorAttrMap_3D_3E
	dw FloorAttrMap_3D_3F
	dw FloorAttrMap_3D_40
	dw FloorAttrMap_3D_41
	dw FloorAttrMap_3D_42
	dw FloorAttrMap_3D_43
	dw FloorAttrMap_3D_44
	dw FloorAttrMap_3D_45
	dw FloorAttrMap_3D_46
	dw FloorAttrMap_3D_47
	dw FloorAttrMap_3D_48
	dw FloorAttrMap_3D_49
	dw FloorAttrMap_3D_4A
	dw FloorAttrMap_3D_4B
	dw FloorAttrMap_3D_4C
	dw FloorAttrMap_3D_4D
	dw FloorAttrMap_3D_4E
	dw FloorAttrMap_3D_4F
	dw FloorAttrMap_3D_50
	dw FloorAttrMap_3D_51
	dw FloorAttrMap_3D_52
	dw FloorAttrMap_3D_53
	dw FloorAttrMap_3D_54
	dw FloorAttrMap_3D_55
	dw FloorAttrMap_3D_56
	dw FloorAttrMap_3D_57
	dw FloorAttrMap_3D_58
	dw FloorAttrMap_3D_59
	dw FloorAttrMap_3D_5A
	dw FloorAttrMap_3D_5B
	dw FloorAttrMap_3D_5C
	dw FloorAttrMap_3D_5D
	dw FloorAttrMap_3D_5E
	dw FloorAttrMap_3D_5F
	dw FloorAttrMap_3D_60
	dw FloorAttrMap_3D_61
	dw FloorAttrMap_3D_62
	dw FloorAttrMap_3D_63
	dw FloorAttrMap_3D_64
	dw FloorAttrMap_3D_65
	dw FloorAttrMap_3D_66
	dw FloorAttrMap_3D_67
	dw FloorAttrMap_3D_68
	dw FloorAttrMap_3D_69
	dw FloorAttrMap_3D_6A
	dw FloorAttrMap_3D_6B
	dw FloorAttrMap_3D_6C
	dw FloorAttrMap_3D_6D
	dw FloorAttrMap_3D_6E
	dw FloorAttrMap_3D_6F
	dw FloorAttrMap_3D_70
	dw FloorAttrMap_3D_71
	dw FloorAttrMap_3D_72
	dw FloorAttrMap_3D_73
	dw FloorAttrMap_3D_74
	dw FloorAttrMap_3D_75
	dw FloorAttrMap_3D_76
	dw FloorAttrMap_3D_77
	dw FloorAttrMap_3D_78
	dw FloorAttrMap_3D_79
	dw FloorAttrMap_3D_7A
	dw FloorAttrMap_3D_7B
	dw FloorAttrMap_3D_7C
	dw FloorAttrMap_3D_7D
	dw FloorAttrMap_3D_7E
	dw FloorAttrMap_3D_7F
	dw FloorAttrMap_3D_80
	dw FloorAttrMap_3D_81
	dw FloorAttrMap_3D_82
	dw FloorAttrMap_3D_83
	dw FloorAttrMap_3D_84
	dw FloorAttrMap_3D_85
	dw FloorAttrMap_3D_86
	dw FloorAttrMap_3D_87
	dw FloorAttrMap_3D_88
	dw FloorAttrMap_3D_89
	dw FloorAttrMap_3D_8A
	dw FloorAttrMap_3D_8B
	dw FloorAttrMap_3D_8C
	dw FloorAttrMap_3D_8D
	dw FloorAttrMap_3D_8E
	dw FloorAttrMap_3D_8F
	dw FloorAttrMap_3D_90
	dw FloorAttrMap_3D_91
	dw FloorAttrMap_3D_92
	dw FloorAttrMap_3D_93
	dw FloorAttrMap_3D_94
	dw FloorAttrMap_3D_95
	dw FloorAttrMap_3D_96
	dw FloorAttrMap_3D_97
	dw FloorAttrMap_3D_98
	dw FloorAttrMap_3D_99
	dw FloorAttrMap_3D_9A
	dw FloorAttrMap_3D_9B
	dw FloorAttrMap_3D_9C
	dw FloorAttrMap_3D_9D
	dw FloorAttrMap_3D_9E
	dw FloorAttrMap_3D_9F
	dw FloorAttrMap_3D_A0
	dw FloorAttrMap_3D_A1
	dw FloorAttrMap_3D_A2
	dw FloorAttrMap_3D_A3
	dw FloorAttrMap_3D_A4
	dw FloorAttrMap_3D_A5
	dw FloorAttrMap_3D_A6
	dw FloorAttrMap_3D_A7
	dw FloorAttrMap_3D_A8
	dw FloorAttrMap_3D_A9
	dw FloorAttrMap_3D_AA
	dw FloorAttrMap_3D_AB
	dw FloorAttrMap_3D_AC
	dw FloorAttrMap_3D_AD
	dw FloorAttrMap_3D_AE
	dw FloorAttrMap_3D_AF
	dw FloorAttrMap_3D_B0
	dw FloorAttrMap_3D_B1
	dw FloorAttrMap_3D_B2
	dw FloorAttrMap_3D_B3
	dw FloorAttrMap_3D_B4
	dw FloorAttrMap_3D_B5
	dw FloorAttrMap_3D_B6
	dw FloorAttrMap_3D_B7
	dw FloorAttrMap_3D_B8
	dw FloorAttrMap_3D_B9
	dw FloorAttrMap_3D_BA
	dw FloorAttrMap_3D_BB
	dw FloorAttrMap_3D_BC
	dw FloorAttrMap_3D_BD
	dw FloorAttrMap_3D_BE
	dw FloorAttrMap_3D_BF
	dw FloorAttrMap_3D_C0
	dw FloorAttrMap_3D_C1
	dw FloorAttrMap_3D_C2
	dw FloorAttrMap_3D_C3

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $00, $0D, $0E, $0F, $1D, $1E, ..., by the room's layout
;@ byte), unpacked to wScreenMap by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the
;@ DecompressCore format ($100 bytes unpacked, $48 packed).
FloorAttrMap_3D_00::
	db $00, $01, $01, $11, $11, $11, $11
	db $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $00, $00, $33, $33, $33, $33, $01
	db $3e, $01, $01, $3c, $0f, $01, $01, $43, $00, $33, $01, $5c, $01, $01, $5a, $0f
	db $0c, $01, $f9, $f3, $01, $80, $0c, $22, $01, $60, $04, $22, $01, $fa, $f3, $01
	db $60, $04, $01, $09, $04, $22, $22, $22, $33, $33, $22, $22, $22, $01, $09, $0f
	db $24

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $01, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $58 packed).
FloorAttrMap_3D_01::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff
	db $08, $22, $01, $06, $0b, $01, $00, $00, $01, $09, $06, $01, $04, $02, $01, $39
	db $0f, $04, $33, $01, $60, $00, $01, $00, $01, $01, $5a, $0f, $04, $22, $22, $01
	db $61, $01, $33, $01, $69, $04, $01, $02, $00, $01, $85, $07, $22, $11, $11, $22
	db $33, $01, $5e, $00, $22, $01, $fa, $f7, $01, $5e, $00, $01, $09, $09, $22, $22
	db $22, $01, $09, $0f, $09, $01, $05, $0f, $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $02, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3E packed).
FloorAttrMap_3D_02::
	db $00, $01, $01, $11, $11, $11, $11
	db $33, $33, $01, $00, $00, $01, $fa, $ff, $25, $33, $01, $42, $00, $00, $01, $38
	db $0f, $05, $01, $42, $01, $33, $33, $00, $00, $33, $01, $5a, $0f, $08, $01, $5e
	db $01, $01, $7a, $0f, $03, $22, $22, $22, $22, $33, $01, $9f, $01, $01, $fa, $f7
	db $01, $ff, $f1, $01, $fa, $ff, $33

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $03, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $40 packed).
FloorAttrMap_3D_03::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33
	db $01, $00, $00, $01, $fa, $ff, $25, $33, $33, $01, $34, $0f, $09, $33, $33, $33
	db $22, $33, $33, $01, $41, $00, $01, $5a, $05, $01, $03, $00, $01, $67, $0f, $16
	db $22, $22, $22, $01, $41, $01, $22, $22, $01, $fa, $f8, $01, $04, $00, $01, $fa
	db $f8, $22, $22, $01, $08, $0f, $25

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $04, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $51 packed).
FloorAttrMap_3D_04::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33
	db $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41, $03, $01, $39, $0f, $04, $33
	db $33, $33, $22, $22, $22, $22, $33, $33, $33, $01, $5a, $05, $01, $00, $02, $01
	db $69, $03, $01, $fd, $f5, $01, $79, $0f, $04, $22, $01, $5c, $03, $33, $01, $a0
	db $01, $00, $00, $01, $09, $01, $01, $45, $08, $22, $22, $22, $00, $01, $62, $00
	db $01, $09, $07, $00, $01, $05, $0f, $18

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $05, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $41 packed).
FloorAttrMap_3D_05::
	db $00, $01, $01, $11, $11, $11, $11, $33
	db $33, $01, $00, $00, $01, $fa, $ff, $24, $00, $00, $01, $03, $00, $01, $3e, $01
	db $01, $3c, $0f, $01, $33, $00, $00, $33, $33, $33, $01, $60, $00, $01, $5a, $0f
	db $23, $22, $00, $00, $22, $33, $33, $01, $a0, $00, $01, $3a, $0f, $04, $22, $22
	db $01, $03, $00, $22, $22, $01, $09, $0f, $24

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $06, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $56 packed).
FloorAttrMap_3D_06::
	db $00, $01, $01, $11, $11, $11, $11
	db $33, $33, $01, $00, $00, $01, $fa, $ff, $07, $22, $01, $05, $0b, $11, $01, $25
	db $0d, $33, $00, $00, $01, $39, $0f, $04, $01, $05, $05, $33, $01, $5a, $0f, $04
	db $01, $05, $00, $01, $f5, $f7, $01, $80, $0c, $01, $24, $01, $01, $69, $00, $22
	db $01, $fa, $f3, $01, $a1, $04, $01, $09, $04, $33, $01, $c1, $01, $22, $22, $01
	db $b9, $0a, $01, $07, $06, $22, $22, $22, $33, $33, $22, $01, $07, $0f, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $07, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $67 packed).
FloorAttrMap_3D_07::
	db $00
	db $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $25, $00
	db $00, $00, $33, $01, $04, $00, $01, $3a, $0f, $03, $33, $11, $33, $33, $22, $22
	db $33, $33, $11, $33, $01, $5a, $06, $01, $02, $01, $01, $69, $04, $33, $33, $22
	db $11, $11, $22, $33, $33, $01, $79, $06, $01, $00, $02, $01, $69, $03, $01, $65
	db $00, $01, $01, $01, $22, $01, $fa, $f3, $01, $91, $04, $01, $09, $04, $01, $86
	db $00, $01, $80, $01, $01, $fa, $f4, $01, $c2, $02, $01, $08, $06, $01, $64, $00
	db $22, $22, $01, $08, $0f, $05

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $08, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $66 packed).
FloorAttrMap_3D_08::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01
	db $00, $00, $01, $fa, $ff, $08, $22, $01, $06, $0b, $01, $00, $00, $01, $09, $04
	db $33, $33, $01, $04, $01, $33, $01, $39, $0f, $04, $33, $33, $22, $01, $41, $00
	db $00, $00, $33, $01, $5a, $04, $01, $40, $01, $01, $67, $06, $22, $11, $22, $01
	db $83, $00, $01, $68, $05, $01, $35, $01, $11, $11, $01, $68, $04, $01, $25, $01
	db $01, $21, $01, $01, $fa, $f6, $01, $30, $02, $01, $aa, $07, $01, $41, $01, $01
	db $ba, $0f, $07, $33, $33, $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $09, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $53 packed).
FloorAttrMap_3D_09::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $07, $22, $01, $05, $0b
	db $11, $01, $25, $0f, $18, $33, $01, $02, $00, $01, $60, $01, $01, $5a, $0f, $04
	db $01, $80, $00, $22, $01, $76, $0b, $01, $01, $01, $01, $fa, $f2, $22, $22, $22
	db $22, $01, $ff, $f0, $33, $22, $01, $fa, $f6, $01, $a4, $01, $01, $09, $07, $01
	db $7f, $01, $01, $b9, $0f, $08, $33, $33, $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $0A, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $55 packed).
FloorAttrMap_3D_0A::
	db $00
	db $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $08, $22
	db $01, $06, $0b, $01, $00, $00, $01, $09, $04, $01, $fc, $f4, $01, $39, $0f, $04
	db $33, $01, $5f, $00, $01, $00, $01, $01, $5a, $0f, $05, $01, $5f, $00, $01, $85
	db $00, $01, $7a, $0f, $03, $22, $01, $a0, $00, $01, $85, $00, $22, $01, $fa, $f6
	db $11, $01, $85, $00, $01, $09, $07, $01, $b4, $0f, $0d, $33, $33, $22, $22, $22
	db $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $0B, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $5B packed).
FloorAttrMap_3D_0B::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00
	db $01, $fa, $ff, $24, $33, $00, $33, $33, $33, $33, $00, $01, $38, $0f, $05, $01
	db $43, $00, $33, $22, $22, $00, $00, $33, $01, $5a, $07, $01, $08, $00, $01, $69
	db $04, $01, $42, $00, $11, $11, $22, $22, $01, $79, $0a, $11, $11, $01, $69, $03
	db $22, $01, $41, $00, $01, $00, $00, $22, $01, $3a, $07, $01, $00, $00, $01, $39
	db $05, $01, $92, $03, $01, $b9, $0f, $05, $22, $22, $22, $01, $04, $0f, $09

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $10, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $42 packed).
FloorAttrMap_3D_0C::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $25, $01, $3a, $0f, $0b, $33, $33
	db $33, $01, $5b, $03, $01, $5a, $0f, $0a, $01, $60, $04, $01, $7f, $0d, $22, $22
	db $33, $01, $a2, $01, $22, $22, $01, $fa, $f4, $01, $a2, $02, $01, $08, $06, $01
	db $b2, $0f, $0d, $01, $a0, $00, $22, $22, $01, $08, $08, $01, $b6, $00, $01, $08
	db $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $11, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3A packed).
FloorAttrMap_3D_0D::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $41, $03
	db $01, $39, $0f, $04, $33, $33, $22, $22, $01, $60, $02, $01, $5a, $04, $11, $11
	db $01, $70, $02, $01, $6a, $0f, $13, $22, $22, $01, $72, $02, $22, $22, $01, $fa
	db $f6, $01, $70, $00, $01, $08, $08, $01, $b4, $0f, $29

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $12, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $5B packed).
FloorAttrMap_3D_0E::
	db $00, $01, $01, $11, $01
	db $00, $05, $01, $fa, $ff, $24, $01, $fb, $f1, $33, $33, $33, $01, $39, $0f, $04
	db $33, $33, $22, $22, $22, $22, $33, $33, $33, $33, $01, $5a, $04, $01, $00, $00
	db $01, $66, $0c, $01, $64, $00, $01, $6a, $08, $01, $74, $00, $01, $fa, $f2, $01
	db $65, $01, $01, $73, $00, $22, $01, $fa, $f3, $01, $a1, $04, $01, $09, $04, $01
	db $63, $01, $00, $00, $01, $48, $05, $01, $95, $03, $01, $c8, $0a, $22, $22, $22
	db $01, $c9, $09, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $13, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $44 packed).
FloorAttrMap_3D_0F::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff
	db $24, $33, $01, $41, $00, $01, $36, $0f, $07, $01, $41, $01, $01, $45, $00, $33
	db $01, $5a, $0f, $0b, $00, $01, $79, $0f, $04, $22, $01, $81, $04, $22, $01, $3a
	db $0a, $00, $01, $39, $09, $01, $fd, $f0, $01, $ba, $0f, $04, $22, $22, $22, $33
	db $33, $22, $22, $22, $01, $09, $07, $01, $44, $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $14, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $47 packed).
FloorAttrMap_3D_10::
	db $00, $01, $01, $11, $01, $00
	db $05, $01, $fa, $ff, $28, $33, $33, $00, $00, $01, $39, $0f, $04, $33, $01, $60
	db $03, $01, $f8, $f4, $01, $60, $0d, $22, $01, $81, $01, $01, $65, $05, $33, $01
	db $00, $02, $01, $65, $05, $22, $01, $91, $03, $22, $22, $01, $fa, $f9, $33, $01
	db $08, $08, $01, $60, $00, $01, $b8, $0f, $0b, $22, $22, $01, $b8, $0a, $01, $06
	db $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $15, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $54 packed).
FloorAttrMap_3D_11::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $01, $fd, $f5, $01
	db $3a, $0f, $03, $33, $33, $22, $01, $ff, $f2, $33, $01, $5a, $04, $11, $01, $63
	db $0c, $33, $01, $65, $01, $01, $79, $0f, $04, $22, $22, $11, $33, $01, $a3, $01
	db $22, $01, $fa, $f5, $01, $a3, $02, $01, $09, $06, $00, $01, $a3, $00, $01, $3f
	db $01, $01, $bd, $0f, $03, $22, $33, $33, $22, $22, $22, $01, $09, $07, $33, $01
	db $83, $01, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $16, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $45 packed).
FloorAttrMap_3D_12::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $28
	db $00, $00, $00, $33, $01, $39, $0f, $04, $33, $33, $01, $07, $00, $22, $22, $33
	db $33, $01, $5a, $08, $11, $11, $01, $68, $0f, $15, $22, $33, $01, $a1, $00, $11
	db $11, $22, $22, $01, $fa, $f3, $01, $a1, $03, $01, $08, $05, $01, $b1, $0f, $0d
	db $22, $01, $66, $00, $01, $06, $0a, $01, $b4, $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $17, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4C packed).
FloorAttrMap_3D_13::
	db $00, $01, $01, $11, $01, $00
	db $05, $01, $fa, $ff, $24, $33, $01, $41, $03, $01, $39, $0f, $04, $33, $33, $22
	db $01, $62, $00, $33, $33, $33, $01, $5a, $04, $01, $00, $01, $01, $67, $06, $22
	db $01, $72, $0b, $01, $00, $02, $01, $67, $05, $01, $81, $02, $11, $33, $33, $22
	db $01, $fa, $f9, $01, $47, $06, $01, $73, $03, $01, $b8, $0f, $09, $01, $60, $01
	db $01, $d9, $09, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $18, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $55 packed).
FloorAttrMap_3D_14::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff
	db $24, $00, $00, $33, $00, $00, $33, $33, $33, $01, $39, $0f, $04, $33, $33, $22
	db $22, $33, $01, $45, $00, $33, $01, $5a, $04, $11, $11, $01, $64, $09, $22, $11
	db $11, $01, $66, $00, $01, $68, $05, $11, $01, $82, $0a, $22, $11, $11, $11, $22
	db $01, $66, $00, $22, $01, $fa, $f7, $01, $66, $00, $01, $09, $08, $01, $b5, $0f
	db $0c, $01, $60, $00, $22, $01, $d9, $09, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $19, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $5C packed).
FloorAttrMap_3D_15::
	db $00, $01, $01, $11, $01
	db $00, $05, $01, $fa, $ff, $24, $33, $33, $33, $00, $33, $33, $01, $37, $0f, $06
	db $33, $33, $22, $22, $22, $22, $33, $11, $11, $33, $01, $5a, $04, $01, $00, $00
	db $01, $66, $07, $22, $01, $72, $02, $33, $01, $69, $04, $01, $00, $01, $01, $86
	db $06, $22, $11, $01, $40, $00, $33, $11, $00, $22, $01, $fa, $f5, $01, $a3, $02
	db $01, $09, $06, $01, $41, $01, $01, $b8, $0f, $08, $22, $01, $60, $01, $01, $09
	db $07, $01, $70, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $1A, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $57 packed).
FloorAttrMap_3D_16::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa
	db $ff, $24, $33, $00, $33, $11, $01, $40, $01, $01, $3a, $0f, $03, $33, $00, $22
	db $01, $43, $00, $22, $00, $33, $01, $5a, $04, $11, $01, $43, $00, $11, $01, $68
	db $05, $33, $01, $72, $02, $33, $01, $79, $0f, $04, $22, $22, $11, $33, $33, $33
	db $33, $11, $22, $22, $01, $fa, $f5, $01, $a3, $01, $01, $08, $07, $01, $b3, $0f
	db $0d, $22, $33, $33, $22, $01, $07, $09, $01, $b5, $01, $01, $09, $03

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $1B, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $50 packed).
FloorAttrMap_3D_17::
	db $00, $01
	db $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $00, $33, $00, $33, $01, $44, $00
	db $01, $39, $0f, $04, $33, $33, $22, $01, $43, $02, $33, $01, $5a, $04, $11, $01
	db $63, $0c, $01, $64, $02, $01, $79, $0f, $04, $22, $22, $01, $82, $03, $22, $01
	db $fa, $f5, $01, $64, $02, $01, $09, $06, $01, $43, $01, $00, $01, $b9, $0f, $07
	db $22, $33, $33, $22, $22, $22, $01, $09, $07, $33, $33, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $20, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $2F packed).
FloorAttrMap_3D_18::
	db $00, $01
	db $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $01
	db $41, $03, $01, $39, $0f, $04, $01, $41, $04, $33, $33, $01, $5a, $0f, $23, $22
	db $01, $a0, $05, $01, $fa, $f6, $01, $b0, $02, $01, $aa, $0f, $33

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $21, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $43 packed).
FloorAttrMap_3D_19::
	db $00, $01, $01
	db $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41
	db $03, $01, $39, $0f, $04, $33, $33, $33, $01, $5c, $07, $01, $5e, $0e, $00, $01
	db $71, $0f, $0c, $22, $01, $61, $04, $22, $01, $3a, $05, $01, $5c, $02, $01, $39
	db $0f, $14, $11, $22, $01, $e1, $03, $01, $09, $07, $01, $f0, $02, $01, $a0, $f2
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $22, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $57 packed).
FloorAttrMap_3D_1A::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $26
	db $00, $00, $00, $33, $33, $33, $01, $39, $0f, $04, $33, $11, $11, $33, $22, $22
	db $22, $22, $33, $33, $01, $5a, $06, $01, $00, $02, $01, $5a, $03, $33, $01, $72
	db $0f, $0b, $22, $33, $01, $5f, $00, $11, $11, $22, $22, $01, $fa, $f3, $01, $a1
	db $03, $01, $08, $05, $01, $fd, $f3, $01, $b8, $0f, $06, $22, $22, $22, $01, $b4
	db $09, $01, $f0, $05, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $23, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $45 packed).
FloorAttrMap_3D_1B::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33
	db $01, $00, $00, $01, $fa, $ff, $43, $01, $05, $00, $01, $04, $01, $33, $01, $5a
	db $0f, $04, $01, $80, $05, $01, $7a, $0f, $03, $22, $22, $22, $01, $80, $00, $22
	db $22, $22, $01, $fa, $f5, $01, $80, $00, $01, $07, $08, $01, $b3, $0f, $0d, $22
	db $22, $22, $22, $01, $07, $09, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $24, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $57 packed).
FloorAttrMap_3D_1C::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33, $11, $33
	db $01, $44, $00, $01, $39, $0f, $04, $01, $46, $00, $22, $22, $22, $22, $33, $33
	db $01, $5a, $06, $01, $00, $02, $01, $6a, $0f, $13, $22, $01, $41, $02, $11, $33
	db $22, $01, $3a, $09, $11, $01, $48, $07, $33, $33, $22, $01, $46, $09, $01, $a1
	db $03, $01, $fa, $f3, $01, $64, $00, $01, $63, $00, $01, $09, $07, $01, $f0, $02
	db $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $25, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4A packed).
FloorAttrMap_3D_1D::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01
	db $fa, $ff, $24, $33, $01, $41, $03, $01, $39, $0f, $04, $33, $33, $01, $5a, $0f
	db $0e, $22, $22, $22, $22, $01, $5f, $08, $01, $06, $01, $01, $60, $04, $22, $01
	db $91, $04, $22, $01, $3a, $04, $01, $92, $03, $01, $39, $0f, $14, $11, $01, $83
	db $00, $01, $83, $00, $01, $09, $07, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $26, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $53 packed).
FloorAttrMap_3D_1E::
	db $00, $01, $01
	db $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41
	db $00, $01, $36, $0f, $07, $33, $33, $22, $22, $22, $22, $01, $01, $00, $01, $5a
	db $04, $01, $00, $00, $01, $66, $0e, $00, $01, $79, $0f, $04, $22, $01, $81, $04
	db $22, $01, $3a, $04, $01, $82, $03, $01, $39, $09, $01, $43, $00, $01, $ba, $0f
	db $04, $01, $62, $00, $01, $62, $01, $01, $fa, $f6, $01, $82, $03, $01, $fa, $01
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $27, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4E packed).
FloorAttrMap_3D_1F::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24
	db $33, $01, $41, $03, $01, $39, $0f, $04, $33, $33, $33, $22, $22, $22, $22, $33
	db $33, $33, $01, $5a, $05, $01, $00, $02, $01, $69, $04, $22, $22, $01, $00, $00
	db $22, $22, $01, $69, $04, $01, $00, $00, $01, $00, $01, $01, $fa, $f2, $01, $82
	db $01, $01, $83, $01, $01, $fa, $f6, $01, $91, $02, $01, $aa, $0f, $33

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $28, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $5B packed).
FloorAttrMap_3D_20::
	db $00, $01
	db $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33
	db $01, $fd, $f3, $01, $3a, $0f, $03, $33, $33, $22, $33, $33, $01, $04, $00, $01
	db $42, $00, $01, $5d, $01, $11, $01, $63, $0a, $22, $11, $22, $22, $22, $01, $71
	db $00, $01, $5a, $03, $01, $00, $00, $11, $01, $86, $06, $22, $01, $91, $04, $22
	db $01, $fa, $f6, $01, $94, $01, $01, $09, $07, $01, $02, $00, $01, $b8, $0f, $0b
	db $22, $22, $22, $01, $b9, $09, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $29, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4B packed).
FloorAttrMap_3D_21::
	db $00, $01, $01, $11, $11, $11, $11
	db $33, $33, $01, $00, $00, $01, $fa, $ff, $43, $33, $01, $60, $00, $22, $01, $01
	db $00, $01, $5a, $07, $01, $00, $01, $01, $6a, $0a, $33, $01, $79, $0f, $04, $22
	db $01, $81, $04, $22, $01, $fa, $f3, $01, $81, $04, $01, $09, $04, $01, $60, $01
	db $01, $72, $00, $01, $ba, $0f, $04, $22, $01, $e1, $03, $01, $09, $07, $01, $f0
	db $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $2A, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $68 packed).
FloorAttrMap_3D_22::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00
	db $01, $fa, $ff, $08, $01, $ff, $f1, $01, $1a, $0f, $07, $22, $33, $33, $33, $00
	db $01, $09, $07, $11, $01, $45, $07, $01, $05, $01, $33, $01, $65, $00, $01, $5a
	db $0f, $04, $01, $46, $00, $33, $22, $22, $22, $01, $79, $09, $01, $21, $01, $01
	db $fb, $f1, $22, $33, $33, $00, $01, $04, $01, $22, $01, $fa, $f3, $01, $a1, $04
	db $01, $09, $04, $01, $65, $00, $22, $01, $b6, $0b, $01, $50, $01, $01, $fa, $f3
	db $22, $22, $22, $01, $c5, $01, $01, $49, $08, $01, $d5, $07

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $2B, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $5C packed).
FloorAttrMap_3D_23::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $25, $33, $01, $42, $01
	db $01, $38, $0f, $05, $33, $11, $00, $00, $22, $22, $00, $00, $33, $33, $01, $5a
	db $06, $01, $08, $00, $01, $68, $05, $33, $00, $33, $11, $11, $33, $00, $22, $01
	db $79, $0b, $11, $01, $69, $03, $22, $22, $00, $01, $42, $00, $00, $11, $22, $01
	db $fa, $f4, $01, $a2, $03, $01, $39, $0f, $14, $11, $11, $22, $01, $e2, $01, $01
	db $08, $08, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $30, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $43 packed).
FloorAttrMap_3D_24::
	db $00, $01, $01, $11, $11, $11, $11, $33
	db $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41, $03, $01, $39, $0f, $0d
	db $33, $01, $5a, $0f, $04, $00, $00, $01, $73, $0f, $0b, $01, $69, $00, $01, $41
	db $00, $22, $01, $9a, $0b, $01, $39, $07, $01, $a2, $01, $01, $b9, $0f, $05, $22
	db $22, $22, $33, $33, $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $31, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3D packed).
FloorAttrMap_3D_25::
	db $00, $01, $01, $11, $11
	db $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $27, $00, $33, $33, $33, $33
	db $01, $39, $0f, $09, $01, $44, $01, $01, $5a, $0f, $07, $33, $01, $64, $01, $01
	db $7a, $0f, $0a, $00, $00, $22, $01, $9a, $0b, $01, $09, $09, $33, $01, $b7, $0f
	db $0c, $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $32, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4D packed).
FloorAttrMap_3D_26::
	db $00, $01, $01, $11, $11, $11, $11, $33
	db $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41, $00, $01, $36, $0f, $09
	db $22, $22, $22, $22, $01, $01, $00, $01, $3a, $04, $01, $00, $00, $01, $66, $0d
	db $33, $33, $01, $79, $0f, $05, $01, $fc, $f0, $33, $33, $33, $22, $22, $01, $9a
	db $0a, $01, $08, $05, $22, $01, $a8, $00, $01, $64, $00, $01, $fa, $f6, $01, $ce
	db $04, $01, $fc, $ff, $11

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $33, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4F packed).
FloorAttrMap_3D_27::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00
	db $00, $01, $fa, $ff, $24, $33, $33, $00, $00, $00, $33, $33, $33, $01, $39, $0f
	db $06, $22, $01, $62, $01, $01, $41, $01, $01, $3d, $01, $01, $00, $00, $01, $02
	db $00, $01, $6a, $0f, $15, $01, $71, $02, $33, $22, $01, $9a, $0b, $01, $39, $06
	db $11, $33, $01, $c4, $00, $01, $b9, $0f, $05, $22, $22, $11, $33, $01, $61, $00
	db $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $34, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $1F packed).
FloorAttrMap_3D_28::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00
	db $01, $fa, $ff, $49, $01, $64, $00, $01, $5a, $0f, $29, $22, $22, $22, $22, $01
	db $fa, $ff, $43

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $35, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $49 packed).
FloorAttrMap_3D_29::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01
	db $fa, $ff, $24, $00, $33, $01, $42, $02, $01, $39, $0f, $06, $01, $41, $04, $01
	db $5a, $0f, $04, $33, $00, $22, $22, $22, $22, $01, $77, $08, $01, $00, $02, $01
	db $89, $0c, $22, $01, $8a, $0b, $01, $09, $04, $01, $69, $00, $01, $45, $08, $01
	db $c1, $0c, $01, $84, $01, $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $36, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4D packed).
FloorAttrMap_3D_2A::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $26, $33, $01, $43, $01
	db $01, $39, $0f, $05, $33, $33, $33, $22, $22, $22, $22, $33, $33, $01, $5a, $06
	db $01, $00, $02, $01, $fa, $f3, $00, $00, $01, $05, $01, $22, $01, $79, $0b, $11
	db $01, $69, $0b, $11, $22, $01, $9a, $0b, $01, $59, $07, $01, $ff, $f1, $01, $b9
	db $0f, $05, $01, $65, $01, $01, $06, $0f, $07

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $37, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $53 packed).
FloorAttrMap_3D_2B::
	db $00, $01, $01, $11, $11, $11, $11
	db $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33, $11, $22, $33, $33, $33
	db $33, $01, $39, $07, $11, $01, $45, $09, $00, $11, $11, $00, $01, $45, $00, $01
	db $5a, $0f, $04, $01, $65, $02, $22, $22, $01, $79, $0a, $11, $11, $01, $69, $05
	db $33, $33, $33, $22, $22, $11, $11, $22, $01, $9a, $07, $01, $00, $00, $01, $39
	db $06, $01, $b3, $0f, $0b, $22, $22, $22, $01, $04, $0f, $09

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $38, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3E packed).
FloorAttrMap_3D_2C::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $28, $22, $01, $06, $0b
	db $01, $00, $00, $01, $09, $06, $01, $04, $02, $33, $01, $5a, $0f, $08, $01, $83
	db $01, $01, $7a, $0f, $08, $22, $01, $a5, $00, $01, $5a, $0b, $01, $09, $06, $22
	db $01, $54, $0b, $01, $53, $0c, $01, $03, $0f, $0a

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $39, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $40 packed).
FloorAttrMap_3D_2D::
	db $00, $01, $01, $11, $11, $11
	db $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $27, $22, $33, $33, $33, $33, $01
	db $09, $07, $11, $01, $45, $0c, $22, $22, $00, $33, $33, $01, $4a, $07, $11, $11
	db $01, $67, $0f, $1d, $33, $33, $22, $01, $9a, $0b, $01, $49, $0f, $09, $01, $45
	db $0b, $33, $33, $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $3A, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $50 packed).
FloorAttrMap_3D_2E::
	db $00, $01, $01, $11, $11, $11
	db $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33, $33, $33, $22, $01
	db $36, $0b, $01, $00, $00, $01, $39, $05, $22, $22, $22, $01, $02, $00, $33, $01
	db $3a, $04, $01, $55, $01, $01, $67, $0f, $18, $33, $00, $01, $41, $00, $33, $22
	db $01, $9a, $0b, $01, $39, $05, $00, $00, $01, $a3, $01, $01, $b9, $0f, $05, $22
	db $22, $22, $33, $01, $61, $01, $01, $fa, $ff, $03

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $3B, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $52 packed).
FloorAttrMap_3D_2F::
	db $00, $01, $01, $11, $11, $11
	db $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $25, $33, $01, $42, $02, $01, $39
	db $0f, $05, $00, $00, $33, $33, $22, $22, $22, $33, $33, $01, $5a, $07, $01, $01
	db $01, $01, $fa, $f3, $33, $22, $22, $01, $74, $0a, $11, $01, $90, $00, $01, $87
	db $0a, $01, $42, $00, $22, $01, $9a, $0b, $01, $09, $04, $01, $69, $00, $01, $b5
	db $0f, $09, $01, $65, $01, $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $40, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $34 packed).
FloorAttrMap_3D_30::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41, $03
	db $01, $39, $0f, $04, $01, $41, $04, $01, $58, $0f, $25, $22, $01, $41, $0f, $0c
	db $01, $b0, $0f, $0e, $22, $22, $22, $33, $33, $22, $22, $22, $01, $09, $0f, $04
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $41, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $42 packed).
FloorAttrMap_3D_31::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $08
	db $01, $ff, $f1, $01, $1a, $0f, $04, $33, $33, $33, $01, $fe, $f2, $01, $3a, $0f
	db $03, $01, $41, $01, $01, $55, $0f, $0c, $01, $24, $08, $01, $80, $0c, $22, $01
	db $61, $0b, $11, $01, $a1, $0e, $01, $43, $0f, $0a, $11, $22, $22, $22, $01, $04
	db $0f, $09

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $42, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $2A packed).
FloorAttrMap_3D_32::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa
	db $ff, $43, $33, $01, $60, $01, $01, $56, $0f, $27, $22, $22, $22, $22, $01, $fe
	db $f2, $01, $fa, $f6, $01, $a4, $0f, $1d, $01, $04, $0f, $09

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $43, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $46 packed).
FloorAttrMap_3D_33::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41, $03
	db $01, $39, $0f, $04, $01, $41, $04, $01, $58, $0f, $08, $22, $22, $22, $22, $01
	db $57, $08, $01, $00, $03, $01, $fa, $f2, $01, $86, $00, $01, $94, $08, $01, $03
	db $03, $01, $47, $0f, $06, $01, $40, $0d, $01, $84, $01, $22, $22, $22, $01, $09
	db $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $44, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4A packed).
FloorAttrMap_3D_34::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa
	db $ff, $24, $33, $01, $41, $00, $01, $fd, $f0, $01, $3a, $0f, $03, $33, $33, $22
	db $01, $62, $00, $01, $57, $07, $01, $00, $00, $11, $01, $67, $0c, $33, $33, $01
	db $79, $0f, $04, $22, $22, $01, $82, $0a, $01, $72, $01, $01, $a5, $0b, $01, $41
	db $01, $01, $b9, $0f, $0a, $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $45, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4E packed).
FloorAttrMap_3D_35::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $26, $33, $01, $43, $01
	db $01, $39, $0f, $04, $33, $00, $01, $52, $0f, $0e, $22, $01, $83, $00, $00, $01
	db $59, $06, $01, $92, $01, $01, $88, $04, $22, $01, $05, $01, $01, $96, $06, $11
	db $01, $a1, $0d, $00, $01, $43, $00, $00, $01, $48, $05, $01, $c1, $0c, $22, $22
	db $22, $33, $33, $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $46, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $50 packed).
FloorAttrMap_3D_36::
	db $00, $01, $01, $11, $11, $11
	db $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41, $02, $01, $38
	db $0f, $05, $01, $41, $00, $22, $22, $22, $33, $33, $01, $59, $07, $01, $01, $02
	db $01, $5a, $03, $22, $22, $22, $01, $74, $09, $01, $00, $00, $01, $75, $07, $01
	db $83, $00, $11, $01, $5e, $00, $01, $09, $07, $01, $a4, $0d, $01, $44, $01, $01
	db $ba, $0f, $07, $01, $62, $01, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $47, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $50 packed).
FloorAttrMap_3D_37::
	db $00, $01, $01, $11, $11, $11
	db $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $08, $01, $ff, $f1, $01, $1a, $0f
	db $05, $33, $33, $00, $22, $01, $36, $0b, $01, $00, $00, $01, $09, $03, $33, $33
	db $33, $33, $01, $45, $01, $01, $59, $07, $01, $55, $01, $01, $69, $0f, $14, $22
	db $22, $33, $01, $fe, $f2, $01, $39, $06, $01, $a3, $0b, $22, $22, $01, $fe, $f2
	db $01, $fa, $f6, $01, $c4, $0c, $01, $04, $0f, $09

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $48, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $54 packed).
FloorAttrMap_3D_38::
	db $00, $01, $01, $11, $11, $11
	db $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $27, $22, $33, $33, $33, $33, $01
	db $09, $07, $11, $01, $45, $07, $01, $46, $00, $11, $22, $22, $22, $01, $58, $09
	db $01, $01, $00, $01, $59, $06, $01, $05, $01, $01, $78, $0f, $05, $01, $44, $00
	db $00, $00, $33, $01, $77, $05, $01, $54, $00, $01, $a4, $0f, $00, $01, $47, $06
	db $01, $c1, $0c, $01, $65, $00, $33, $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $49, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $58 packed).
FloorAttrMap_3D_39::
	db $00, $01
	db $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33
	db $33, $33, $22, $01, $36, $0b, $01, $00, $00, $01, $09, $03, $01, $42, $00, $22
	db $01, $02, $01, $01, $5a, $05, $01, $00, $03, $01, $6a, $0f, $13, $22, $33, $33
	db $33, $01, $3f, $00, $22, $01, $39, $07, $01, $3f, $00, $01, $08, $05, $22, $01
	db $a0, $00, $01, $44, $00, $01, $fa, $f5, $01, $51, $03, $01, $fa, $f5, $22, $01
	db $43, $02, $01, $fa, $ff, $03

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $4A, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $50 packed).
FloorAttrMap_3D_3A::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01
	db $00, $00, $01, $fa, $ff, $24, $33, $01, $41, $00, $01, $fd, $f0, $01, $3a, $0f
	db $03, $33, $33, $22, $22, $01, $60, $00, $01, $58, $06, $01, $02, $02, $01, $68
	db $0f, $15, $22, $01, $41, $0f, $0c, $11, $33, $01, $a0, $00, $00, $22, $33, $01
	db $39, $05, $01, $40, $00, $01, $cf, $00, $01, $fa, $f3, $22, $11, $01, $63, $00
	db $11, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $4B, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3E packed).
FloorAttrMap_3D_3B::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01
	db $00, $00, $01, $fa, $ff, $27, $00, $01, $35, $0f, $08, $01, $05, $00, $01, $04
	db $08, $01, $60, $0d, $00, $33, $01, $73, $0f, $0a, $22, $22, $33, $33, $01, $04
	db $0a, $01, $a2, $0c, $22, $22, $33, $01, $3f, $02, $01, $fb, $f6, $01, $c5, $0c
	db $01, $05, $0f, $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $50, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $1B packed).
FloorAttrMap_3D_3C::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $43, $33
	db $01, $60, $05, $01, $5a, $0f, $23, $22, $01, $a0, $05, $01, $fa, $ff, $43

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $51, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3D packed).
FloorAttrMap_3D_3D::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $41, $03, $01, $39
	db $0f, $04, $33, $33, $01, $5a, $0f, $0e, $33, $00, $00, $33, $01, $77, $0f, $06
	db $22, $01, $85, $02, $33, $00, $22, $01, $fa, $f3, $01, $a1, $04, $01, $09, $04
	db $01, $b1, $0f, $0d, $22, $01, $e1, $03, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $52, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4B packed).
FloorAttrMap_3D_3E::
	db $00, $01, $01, $11
	db $01, $00, $05, $01, $fa, $ff, $24, $01, $3c, $04, $01, $39, $0f, $04, $33, $33
	db $33, $01, $3e, $01, $01, $61, $00, $01, $5c, $0f, $04, $33, $33, $11, $01, $5f
	db $02, $01, $7c, $0f, $01, $22, $22, $00, $33, $33, $11, $33, $33, $33, $22, $01
	db $fa, $f4, $01, $a2, $03, $01, $09, $05, $01, $80, $01, $01, $b7, $0f, $08, $22
	db $01, $e2, $02, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $53, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $49 packed).
FloorAttrMap_3D_3F::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa
	db $ff, $29, $33, $33, $33, $01, $39, $0f, $04, $33, $01, $fe, $f1, $00, $22, $33
	db $33, $01, $5a, $09, $11, $01, $68, $05, $33, $01, $72, $0f, $0b, $22, $33, $01
	db $a1, $01, $11, $22, $22, $01, $fa, $f3, $01, $a1, $03, $01, $08, $05, $01, $a1
	db $00, $01, $61, $02, $01, $bb, $0f, $03, $22, $01, $e1, $01, $01, $07, $0f, $06
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $54, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4E packed).
FloorAttrMap_3D_40::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $41, $00, $01
	db $ff, $f0, $01, $3a, $0f, $03, $33, $33, $22, $22, $22, $22, $01, $3f, $00, $01
	db $5a, $04, $01, $06, $01, $01, $67, $0b, $33, $01, $77, $0f, $06, $22, $22, $01
	db $40, $01, $11, $33, $22, $01, $fa, $f5, $01, $a3, $02, $01, $09, $06, $01, $42
	db $01, $01, $b8, $0f, $08, $01, $62, $00, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $55, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $40 packed).
FloorAttrMap_3D_41::
	db $00, $01
	db $01, $11, $01, $00, $05, $01, $fa, $ff, $43, $33, $01, $60, $05, $01, $5a, $0f
	db $05, $22, $22, $01, $80, $02, $01, $5a, $04, $11, $11, $01, $90, $02, $01, $fa
	db $f2, $22, $01, $91, $04, $22, $01, $fa, $f3, $01, $91, $04, $01, $09, $04, $01
	db $60, $04, $01, $b9, $0f, $05, $22, $01, $e1, $03, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $56, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $49 packed).
FloorAttrMap_3D_42::
	db $00, $01
	db $01, $11, $01, $00, $05, $01, $fa, $ff, $2a, $33, $33, $01, $39, $0f, $04, $33
	db $01, $41, $04, $33, $01, $5a, $0f, $04, $33, $33, $01, $65, $01, $01, $78, $0f
	db $05, $22, $01, $85, $01, $33, $22, $22, $22, $01, $fa, $f3, $01, $a1, $02, $01
	db $07, $06, $22, $22, $01, $a5, $00, $01, $07, $08, $01, $b5, $01, $01, $08, $07
	db $01, $c5, $01, $01, $08, $0f, $05

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $57, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4C packed).
FloorAttrMap_3D_43::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa
	db $ff, $43, $33, $11, $11, $33, $01, $5f, $00, $11, $33, $01, $5a, $0f, $04, $33
	db $11, $33, $22, $00, $33, $00, $33, $01, $79, $07, $11, $01, $85, $07, $22, $01
	db $91, $02, $33, $33, $22, $01, $fa, $f3, $01, $a1, $04, $01, $09, $04, $00, $33
	db $00, $11, $22, $22, $22, $22, $01, $b9, $08, $01, $05, $08, $01, $c6, $00, $01
	db $05, $0f, $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $58, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $44 packed).
FloorAttrMap_3D_44::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $43, $33, $33
	db $33, $33, $00, $33, $11, $11, $11, $33, $01, $5a, $0f, $04, $22, $22, $01, $61
	db $01, $33, $01, $69, $04, $11, $11, $01, $83, $09, $22, $01, $91, $01, $33, $33
	db $22, $22, $01, $fa, $f5, $01, $a3, $01, $01, $08, $07, $01, $b3, $0f, $0d, $22
	db $01, $e3, $00, $01, $08, $0f, $05

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $59, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $59 packed).
FloorAttrMap_3D_45::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa
	db $ff, $24, $33, $01, $41, $03, $01, $39, $0f, $04, $33, $00, $22, $22, $22, $33
	db $22, $22, $33, $33, $01, $5a, $04, $11, $11, $11, $33, $11, $11, $01, $68, $05
	db $22, $01, $72, $02, $22, $01, $69, $04, $01, $00, $00, $01, $90, $00, $01, $69
	db $03, $22, $01, $76, $00, $33, $01, $85, $00, $01, $fa, $f5, $01, $a3, $02, $01
	db $09, $06, $01, $b3, $0f, $0d, $22, $22, $22, $01, $81, $00, $01, $fa, $ff, $03
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $5A, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4B packed).
FloorAttrMap_3D_46::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $41, $01, $01
	db $37, $0f, $06, $33, $33, $22, $22, $22, $33, $33, $11, $33, $33, $01, $5a, $04
	db $11, $11, $11, $01, $65, $0c, $22, $01, $66, $0b, $11, $01, $66, $06, $01, $64
	db $00, $01, $94, $01, $22, $01, $3a, $05, $01, $93, $02, $01, $39, $0a, $33, $01
	db $b8, $0f, $06, $22, $01, $e1, $03, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $5B, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $45 packed).
FloorAttrMap_3D_47::
	db $00, $01, $01, $11, $01
	db $00, $05, $01, $fa, $ff, $2a, $33, $33, $01, $39, $0f, $04, $33, $01, $41, $04
	db $33, $01, $5a, $0f, $04, $01, $80, $03, $22, $01, $79, $0b, $11, $01, $69, $03
	db $22, $01, $84, $01, $22, $22, $11, $22, $01, $fa, $f3, $01, $94, $01, $01, $06
	db $07, $01, $67, $00, $01, $b5, $0f, $09, $22, $01, $a5, $00, $01, $06, $0f, $07
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $60, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $21 packed).
FloorAttrMap_3D_48::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $47, $33, $01, $64, $01, $01
	db $5a, $0f, $29, $22, $22, $22, $22, $01, $5a, $08, $01, $56, $0c, $01, $b6, $0f
	db $27

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $61, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $40 packed).
FloorAttrMap_3D_49::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $41, $03
	db $01, $39, $0f, $06, $01, $fa, $f2, $33, $01, $61, $03, $01, $60, $0f, $00, $01
	db $41, $00, $01, $77, $0f, $09, $01, $63, $02, $22, $01, $5a, $0b, $01, $39, $0f
	db $15, $22, $22, $22, $33, $33, $22, $22, $22, $01, $09, $07, $33, $33, $01, $06
	db $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $62, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $2F packed).
FloorAttrMap_3D_4A::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $41, $00
	db $01, $36, $0f, $0d, $01, $41, $00, $01, $5a, $0f, $29, $22, $22, $22, $22, $01
	db $3a, $0f, $04, $22, $22, $22, $01, $44, $09, $11, $11, $11, $01, $c4, $0f, $19
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $63, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $42 packed).
FloorAttrMap_3D_4B::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $00, $00, $33, $01, $43
	db $01, $01, $39, $0f, $06, $33, $22, $01, $63, $00, $33, $33, $01, $5a, $05, $01
	db $00, $01, $01, $68, $0f, $17, $01, $ff, $f2, $22, $22, $01, $9a, $0a, $01, $08
	db $05, $33, $01, $42, $00, $01, $b6, $0f, $08, $01, $65, $01, $01, $06, $0a, $01
	db $c4, $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $64, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4B packed).
FloorAttrMap_3D_4C::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $41
	db $01, $01, $37, $0f, $08, $22, $01, $62, $00, $11, $33, $33, $01, $3a, $04, $01
	db $00, $02, $01, $68, $0f, $16, $00, $01, $76, $00, $33, $33, $33, $22, $01, $9a
	db $0b, $01, $09, $04, $00, $00, $01, $a6, $00, $22, $22, $01, $b9, $09, $01, $06
	db $07, $22, $22, $22, $01, $d4, $09, $01, $75, $01, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $65, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4E packed).
FloorAttrMap_3D_4D::
	db $00, $01, $01
	db $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $41, $03, $01, $39, $0f, $06
	db $22, $01, $62, $00, $33, $33, $33, $01, $3a, $04, $01, $00, $01, $01, $67, $06
	db $01, $ff, $f2, $01, $77, $0f, $08, $33, $01, $71, $00, $33, $33, $22, $01, $9a
	db $0b, $01, $09, $04, $00, $00, $01, $43, $0a, $01, $c1, $0c, $01, $64, $01, $22
	db $22, $22, $01, $09, $07, $01, $a2, $01, $01, $09, $03

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $66, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $2F packed).
FloorAttrMap_3D_4E::
	db $00, $01, $01, $11, $01
	db $00, $05, $01, $fa, $ff, $4c, $33, $01, $5a, $0f, $0b, $33, $01, $79, $0f, $0b
	db $33, $33, $22, $01, $9a, $0b, $01, $09, $08, $33, $33, $01, $b7, $0f, $0a, $33
	db $33, $22, $22, $22, $01, $d9, $09, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $67, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $46 packed).
FloorAttrMap_3D_4F::
	db $00, $01, $01, $11, $01, $00
	db $05, $01, $fa, $ff, $28, $33, $33, $33, $33, $01, $39, $0f, $09, $00, $00, $33
	db $33, $33, $01, $5a, $0f, $06, $00, $33, $01, $66, $00, $01, $79, $0f, $08, $01
	db $85, $01, $22, $01, $9a, $0b, $01, $09, $06, $01, $a5, $01, $22, $01, $b9, $0a
	db $01, $07, $08, $22, $33, $33, $22, $01, $07, $09, $01, $d5, $01, $01, $09, $03
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $68, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4B packed).
FloorAttrMap_3D_50::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $33, $33, $01, $34
	db $0f, $0a, $00, $00, $01, $43, $02, $33, $01, $5a, $0f, $04, $33, $01, $fe, $f2
	db $33, $01, $79, $0f, $05, $00, $01, $42, $01, $33, $33, $22, $01, $9a, $0b, $01
	db $59, $05, $33, $01, $c2, $02, $01, $b9, $0f, $05, $22, $22, $22, $33, $33, $22
	db $22, $22, $01, $09, $07, $01, $42, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $69, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4A packed).
FloorAttrMap_3D_51::
	db $00, $01, $01, $11, $01
	db $00, $05, $01, $fa, $ff, $24, $00, $00, $33, $01, $43, $01, $01, $39, $0f, $06
	db $01, $43, $00, $22, $22, $33, $33, $01, $5a, $08, $11, $11, $01, $68, $06, $01
	db $42, $00, $11, $11, $22, $01, $79, $0b, $11, $01, $79, $08, $22, $11, $11, $11
	db $22, $01, $3a, $07, $01, $35, $0c, $01, $b5, $0f, $09, $22, $01, $66, $00, $01
	db $06, $0a, $01, $e4, $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $6A, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $36 packed).
FloorAttrMap_3D_52::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $28
	db $33, $33, $33, $33, $01, $39, $0f, $0d, $33, $01, $5a, $0f, $09, $22, $22, $01
	db $68, $0a, $01, $43, $00, $01, $8a, $0b, $22, $01, $8a, $0b, $01, $39, $0f, $18
	db $33, $33, $22, $22, $22, $01, $d9, $09, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $6B, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $43 packed).
FloorAttrMap_3D_53::
	db $00, $01, $01, $11, $01
	db $00, $05, $01, $fa, $ff, $28, $33, $33, $33, $33, $01, $39, $0f, $0d, $33, $01
	db $5a, $0f, $04, $00, $01, $65, $01, $22, $22, $01, $79, $0a, $11, $11, $01, $79
	db $08, $22, $22, $11, $11, $22, $01, $7a, $07, $01, $05, $08, $00, $00, $01, $b3
	db $0f, $0b, $22, $22, $22, $01, $b3, $02, $01, $fa, $f6, $01, $e4, $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $70, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $2D packed).
FloorAttrMap_3D_54::
	db $00, $01
	db $01, $11, $01, $00, $05, $01, $fa, $ff, $43, $33, $01, $60, $01, $01, $56, $0f
	db $0a, $00, $00, $01, $75, $0f, $08, $22, $22, $22, $22, $01, $fe, $f2, $01, $fa
	db $f6, $01, $a4, $0f, $1d, $01, $64, $08, $01, $e0, $0c

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $71, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4E packed).
FloorAttrMap_3D_55::
	db $00, $01, $01, $11, $01
	db $00, $05, $01, $fa, $ff, $24, $00, $33, $33, $33, $33, $01, $3d, $01, $01, $3b
	db $0f, $02, $01, $43, $01, $01, $43, $00, $01, $59, $0f, $06, $00, $01, $45, $00
	db $33, $33, $01, $79, $0f, $04, $22, $33, $01, $41, $02, $01, $88, $04, $11, $01
	db $a1, $0d, $01, $c1, $03, $01, $b9, $0f, $05, $22, $22, $22, $33, $33, $22, $22
	db $22, $01, $09, $07, $33, $33, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $72, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $47 packed).
FloorAttrMap_3D_56::
	db $00, $01, $01, $11, $01, $00, $05
	db $01, $fa, $ff, $24, $00, $00, $00, $33, $01, $44, $00, $01, $39, $0f, $04, $33
	db $33, $22, $01, $62, $01, $01, $58, $06, $01, $00, $02, $01, $68, $0f, $15, $22
	db $22, $11, $01, $44, $00, $01, $3e, $02, $01, $fd, $f2, $01, $a3, $0f, $00, $22
	db $22, $22, $01, $a9, $09, $01, $06, $09, $22, $01, $d4, $0b, $11, $01, $d4, $08
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $73, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $47 packed).
FloorAttrMap_3D_57::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $00, $00, $00, $33
	db $33, $33, $33, $01, $39, $0f, $04, $33, $33, $22, $01, $62, $00, $01, $57, $07
	db $01, $00, $01, $01, $67, $0f, $16, $22, $01, $ff, $f2, $01, $47, $06, $01, $a1
	db $0d, $33, $33, $00, $33, $01, $b6, $0f, $08, $01, $64, $02, $22, $22, $01, $09
	db $07, $01, $70, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $74, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $41 packed).
FloorAttrMap_3D_58::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa
	db $ff, $27, $33, $01, $44, $00, $01, $39, $0f, $04, $33, $33, $33, $01, $5b, $02
	db $01, $59, $0f, $07, $01, $61, $01, $01, $78, $0f, $05, $22, $22, $22, $22, $01
	db $84, $08, $01, $40, $01, $01, $a5, $0c, $01, $45, $0f, $08, $01, $40, $02, $22
	db $22, $22, $01, $39, $09, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $75, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $41 packed).
FloorAttrMap_3D_59::
	db $00, $01, $01, $11, $01, $00, $05, $01
	db $fa, $ff, $24, $33, $01, $41, $03, $01, $39, $0f, $04, $33, $33, $33, $22, $01
	db $54, $0b, $01, $40, $02, $01, $69, $0f, $14, $22, $01, $3e, $04, $01, $09, $04
	db $01, $a1, $0c, $01, $71, $0b, $01, $c0, $0d, $22, $22, $11, $33, $33, $22, $22
	db $22, $01, $09, $07, $33, $33, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $76, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $34 packed).
FloorAttrMap_3D_5A::
	db $00, $01, $01, $11, $01, $00, $05
	db $01, $fa, $ff, $43, $33, $01, $51, $0f, $0d, $01, $60, $05, $01, $7a, $0f, $03
	db $22, $01, $80, $05, $01, $fa, $f3, $01, $a1, $0e, $33, $01, $ff, $f2, $01, $ba
	db $0f, $04, $22, $22, $01, $a0, $03, $01, $fa, $f6, $01, $e4, $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $77, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3E packed).
FloorAttrMap_3D_5B::
	db $00, $01, $01
	db $11, $01, $00, $05, $01, $fa, $ff, $43, $33, $33, $33, $01, $5e, $02, $01, $59
	db $0f, $05, $22, $01, $81, $01, $33, $33, $01, $59, $04, $01, $00, $02, $01, $87
	db $05, $22, $01, $91, $0b, $01, $00, $03, $01, $a7, $0a, $33, $33, $01, $b7, $0f
	db $0a, $33, $01, $80, $00, $01, $d9, $09, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $78, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3D packed).
FloorAttrMap_3D_5C::
	db $00, $01, $01, $11, $01
	db $00, $05, $01, $fa, $ff, $24, $00, $00, $00, $33, $33, $01, $36, $0f, $07, $33
	db $33, $33, $22, $22, $01, $55, $0a, $11, $11, $01, $55, $08, $22, $22, $01, $73
	db $0a, $01, $00, $00, $01, $45, $07, $22, $01, $91, $0b, $01, $00, $01, $01, $a5
	db $0f, $1c, $01, $44, $09, $01, $e1, $0b

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $79, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $58 packed).
FloorAttrMap_3D_5D::
	db $00, $01, $01, $11, $01, $00, $05, $01
	db $fa, $ff, $26, $00, $00, $33, $33, $33, $01, $38, $0f, $05, $33, $33, $33, $33
	db $22, $22, $22, $33, $33, $01, $59, $07, $11, $11, $11, $01, $67, $07, $22, $22
	db $01, $74, $0a, $01, $00, $01, $01, $67, $05, $22, $01, $ff, $f1, $01, $45, $00
	db $01, $fa, $f3, $01, $a1, $0d, $33, $33, $01, $7f, $02, $01, $ba, $09, $01, $07
	db $06, $01, $64, $01, $01, $83, $00, $01, $fa, $f6, $01, $90, $02, $01, $a0, $f2
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $7A, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $42 packed).
FloorAttrMap_3D_5E::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $26, $33, $01, $43, $01, $01
	db $39, $0f, $04, $33, $01, $08, $03, $01, $58, $0f, $06, $33, $11, $33, $33, $01
	db $75, $0f, $08, $22, $01, $81, $0b, $11, $01, $a1, $0d, $01, $c1, $03, $01, $b9
	db $0f, $05, $22, $22, $22, $33, $33, $22, $22, $22, $01, $09, $07, $33, $33, $01
	db $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $7B, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $50 packed).
FloorAttrMap_3D_5F::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $33, $33
	db $01, $40, $01, $01, $39, $0f, $04, $33, $33, $22, $33, $11, $01, $61, $00, $01
	db $59, $05, $11, $01, $71, $02, $01, $69, $07, $01, $70, $01, $01, $79, $0f, $04
	db $22, $01, $3f, $03, $01, $08, $05, $01, $a1, $0c, $33, $01, $c1, $02, $01, $b8
	db $0f, $06, $22, $22, $22, $33, $33, $22, $22, $01, $08, $08, $01, $46, $00, $01
	db $08, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $80, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $25 packed).
FloorAttrMap_3D_60::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa
	db $ff, $49, $01, $64, $00, $01, $5a, $0f, $27, $22, $01, $a4, $01, $01, $fa, $f6
	db $01, $b0, $02, $01, $aa, $0f, $33

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $81, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $47 packed).
FloorAttrMap_3D_61::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33
	db $01, $00, $00, $01, $fa, $ff, $24, $00, $00, $33, $01, $43, $01, $01, $39, $0f
	db $05, $33, $01, $41, $04, $01, $5a, $0f, $05, $01, $61, $04, $01, $7a, $0f, $06
	db $01, $61, $02, $22, $01, $9a, $0b, $01, $59, $05, $01, $a1, $03, $01, $b9, $0f
	db $05, $22, $01, $e1, $03, $01, $09, $07, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $82, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $55 packed).
FloorAttrMap_3D_62::
	db $00, $01
	db $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33
	db $01, $fd, $f3, $01, $3a, $0f, $06, $22, $22, $22, $01, $01, $00, $01, $3a, $05
	db $01, $00, $00, $01, $67, $06, $00, $01, $05, $01, $33, $01, $41, $01, $01, $7d
	db $0f, $02, $01, $ff, $f3, $22, $01, $9a, $0b, $01, $09, $04, $00, $00, $00, $01
	db $87, $01, $01, $b9, $0f, $05, $22, $01, $e1, $03, $01, $09, $07, $01, $73, $02
	db $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $83, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4C packed).
FloorAttrMap_3D_63::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01
	db $fa, $ff, $08, $01, $ff, $f1, $01, $1a, $0f, $07, $01, $3e, $04, $01, $3c, $0f
	db $0a, $33, $01, $5a, $0f, $04, $33, $33, $33, $33, $00, $00, $01, $82, $01, $01
	db $7c, $0f, $06, $33, $22, $22, $22, $22, $01, $9a, $08, $01, $06, $07, $01, $b1
	db $0f, $0d, $01, $a6, $00, $22, $01, $06, $0a, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $84, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $57 packed).
FloorAttrMap_3D_64::
	db $00
	db $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33
	db $01, $41, $03, $01, $39, $0f, $09, $22, $22, $22, $33, $33, $01, $3a, $07, $01
	db $01, $01, $01, $fa, $f3, $00, $33, $22, $22, $01, $75, $0a, $01, $00, $00, $01
	db $77, $07, $01, $ff, $f0, $33, $33, $00, $22, $01, $9a, $0b, $01, $39, $05, $00
	db $00, $33, $01, $68, $00, $01, $b9, $0f, $05, $22, $01, $e1, $03, $01, $09, $07
	db $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $85, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $62 packed).
FloorAttrMap_3D_65::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01
	db $00, $00, $01, $fa, $ff, $24, $33, $33, $11, $33, $33, $33, $00, $00, $01, $39
	db $0f, $08, $22, $22, $22, $22, $00, $33, $01, $3a, $06, $01, $06, $01, $01, $69
	db $05, $22, $01, $73, $01, $01, $45, $00, $01, $3c, $02, $01, $73, $01, $01, $87
	db $06, $01, $ff, $f1, $11, $11, $33, $22, $01, $9a, $0b, $01, $09, $04, $00, $00
	db $00, $33, $01, $c4, $00, $01, $b9, $0f, $05, $01, $64, $00, $01, $64, $00, $01
	db $09, $07, $01, $92, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $86, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3F packed).
FloorAttrMap_3D_66::
	db $00, $01, $01, $11, $11, $11, $11, $33
	db $33, $01, $00, $00, $01, $fa, $ff, $27, $22, $01, $04, $01, $01, $fa, $f6, $01
	db $03, $02, $01, $4a, $09, $33, $11, $33, $01, $5a, $0f, $08, $22, $33, $33, $33
	db $01, $69, $08, $01, $64, $00, $01, $89, $09, $22, $22, $22, $22, $01, $8a, $08
	db $01, $06, $0a, $01, $b4, $0f, $29

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $87, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $34 packed).
FloorAttrMap_3D_67::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33
	db $01, $00, $00, $01, $fa, $ff, $29, $33, $33, $33, $01, $39, $0f, $08, $22, $22
	db $01, $44, $00, $01, $fa, $f6, $01, $42, $02, $01, $6a, $0f, $19, $22, $22, $22
	db $22, $01, $6a, $08, $01, $06, $0a, $01, $b4, $0f, $29

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $88, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $56 packed).
FloorAttrMap_3D_68::
	db $00, $01, $01, $11, $11
	db $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33, $00, $00, $22
	db $01, $36, $0b, $01, $00, $00, $01, $39, $06, $01, $04, $02, $33, $01, $5a, $0f
	db $04, $00, $01, $61, $00, $01, $61, $00, $01, $7a, $0f, $05, $01, $81, $00, $22
	db $22, $22, $22, $01, $9a, $08, $01, $06, $07, $00, $00, $00, $22, $01, $b5, $0b
	db $11, $01, $05, $08, $22, $22, $22, $11, $01, $45, $08, $01, $f0, $05, $01, $a0
	db $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $89, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $6A packed).
FloorAttrMap_3D_69::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff
	db $08, $01, $ff, $f1, $01, $1a, $0f, $05, $33, $33, $00, $00, $01, $05, $00, $01
	db $3a, $0f, $04, $33, $33, $22, $22, $22, $33, $33, $11, $33, $01, $5a, $05, $01
	db $01, $02, $01, $69, $09, $22, $33, $01, $42, $00, $01, $6c, $06, $11, $01, $87
	db $06, $01, $65, $00, $01, $02, $00, $22, $01, $3a, $06, $01, $01, $02, $01, $fa
	db $f4, $01, $86, $00, $33, $01, $b7, $07, $01, $96, $00, $01, $c6, $09, $22, $01
	db $e3, $01, $01, $09, $07, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $8A, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $51 packed).
FloorAttrMap_3D_6A::
	db $00, $01, $01, $11, $11
	db $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41, $02, $01
	db $38, $0f, $0d, $33, $33, $01, $5a, $0f, $04, $00, $22, $33, $22, $33, $22, $00
	db $22, $01, $79, $05, $11, $33, $11, $33, $01, $90, $00, $01, $8a, $05, $01, $8f
	db $02, $22, $01, $9a, $0b, $01, $39, $05, $01, $c0, $03, $01, $b9, $0f, $05, $22
	db $01, $e0, $03, $01, $09, $07, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $8B, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4D packed).
FloorAttrMap_3D_6B::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $27, $22, $33, $33, $00
	db $00, $01, $09, $07, $11, $01, $45, $0e, $33, $00, $33, $01, $5a, $0f, $0b, $01
	db $45, $00, $01, $7c, $0f, $02, $00, $33, $33, $11, $33, $22, $22, $22, $22, $01
	db $9a, $08, $01, $06, $07, $01, $85, $01, $01, $b6, $0f, $08, $01, $a6, $00, $22
	db $01, $06, $0a, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $90, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $26 packed).
FloorAttrMap_3D_6C::
	db $00, $01, $01, $11, $11, $11, $11
	db $33, $33, $01, $00, $00, $01, $fa, $ff, $43, $33, $01, $60, $01, $01, $56, $0f
	db $27, $22, $01, $a0, $01, $01, $06, $0a, $01, $b0, $02, $01, $aa, $0f, $33

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $91, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4C packed).
FloorAttrMap_3D_6D::
	db $00
	db $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $00
	db $00, $33, $01, $43, $01, $01, $39, $0f, $04, $33, $33, $01, $5d, $01, $01, $57
	db $0f, $08, $01, $60, $03, $01, $79, $0f, $04, $22, $01, $43, $01, $00, $00, $01
	db $48, $05, $01, $a1, $0f, $02, $33, $01, $3e, $01, $01, $bc, $0f, $02, $22, $01
	db $e1, $03, $01, $09, $07, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $92, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4E packed).
FloorAttrMap_3D_6E::
	db $00, $01, $01, $11, $11
	db $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $29, $33, $33, $00, $01, $39
	db $0f, $04, $01, $04, $00, $22, $22, $22, $33, $33, $01, $59, $07, $01, $01, $02
	db $01, $6a, $09, $00, $01, $58, $08, $01, $84, $08, $22, $01, $71, $0b, $11, $01
	db $a1, $0d, $33, $00, $00, $01, $c2, $00, $01, $b9, $0f, $05, $22, $01, $e1, $03
	db $01, $09, $07, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $93, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $58 packed).
FloorAttrMap_3D_6F::
	db $00, $01, $01, $11, $11, $11, $11
	db $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33, $00, $33, $33, $33, $33
	db $00, $01, $39, $0f, $04, $33, $33, $22, $22, $22, $33, $33, $00, $01, $58, $06
	db $01, $01, $01, $01, $67, $0a, $22, $22, $22, $01, $68, $09, $01, $07, $00, $01
	db $09, $03, $22, $01, $91, $03, $33, $01, $39, $05, $01, $a2, $0c, $01, $c1, $03
	db $01, $b9, $0f, $05, $22, $01, $e1, $03, $01, $09, $07, $01, $92, $03, $01, $fa
	db $01

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $94, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4F packed).
FloorAttrMap_3D_70::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff
	db $29, $01, $fd, $f0, $01, $3a, $0f, $03, $33, $01, $02, $00, $01, $44, $00, $01
	db $59, $0f, $05, $01, $80, $03, $01, $78, $0f, $05, $22, $22, $01, $7d, $02, $01
	db $48, $06, $01, $a2, $0c, $01, $a0, $00, $33, $22, $22, $01, $09, $07, $01, $5e
	db $01, $01, $09, $07, $22, $22, $22, $01, $07, $09, $01, $f0, $02, $01, $a0, $f2
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $95, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $49 packed).
FloorAttrMap_3D_71::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $07
	db $00, $01, $15, $0f, $09, $33, $33, $33, $00, $00, $01, $04, $00, $01, $3a, $0f
	db $03, $33, $33, $22, $22, $22, $22, $33, $00, $01, $58, $06, $01, $00, $01, $01
	db $67, $0f, $16, $22, $22, $01, $00, $02, $33, $01, $09, $07, $01, $a4, $0f, $1f
	db $22, $22, $22, $01, $a9, $09, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $96, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $43 packed).
FloorAttrMap_3D_72::
	db $00, $01, $01, $11, $11, $11, $11
	db $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33, $33, $33, $22, $01, $36
	db $0b, $01, $00, $00, $01, $09, $03, $01, $42, $00, $01, $45, $01, $01, $59, $06
	db $01, $55, $01, $01, $58, $05, $01, $63, $03, $01, $58, $05, $01, $73, $03, $01
	db $08, $04, $01, $82, $04, $01, $08, $08, $01, $a4, $0f, $39

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $97, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $48 packed).
FloorAttrMap_3D_73::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $27, $22, $01, $05, $0b
	db $11, $01, $05, $07, $01, $05, $01, $01, $55, $0f, $09, $33, $33, $33, $11, $01
	db $ff, $f1, $01, $7a, $0f, $03, $22, $01, $81, $00, $01, $05, $08, $01, $a1, $0f
	db $00, $01, $04, $09, $01, $c1, $0c, $22, $01, $e1, $00, $01, $46, $0b, $01, $50
	db $01, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $98, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $49 packed).
FloorAttrMap_3D_74::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00
	db $01, $fa, $ff, $27, $22, $33, $33, $33, $33, $01, $09, $07, $11, $01, $45, $07
	db $01, $05, $01, $22, $22, $01, $57, $0a, $01, $02, $01, $01, $5a, $03, $01, $46
	db $00, $01, $75, $0f, $08, $22, $01, $65, $00, $01, $45, $0a, $01, $a3, $0c, $22
	db $01, $c3, $01, $01, $49, $08, $01, $50, $01, $01, $ca, $0f, $13

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $99, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4E packed).
FloorAttrMap_3D_75::
	db $00, $01, $01
	db $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $27, $22, $33, $33
	db $33, $00, $01, $09, $07, $11, $01, $45, $07, $01, $05, $01, $33, $33, $00, $01
	db $58, $0f, $06, $01, $80, $03, $01, $78, $0f, $05, $01, $44, $00, $33, $22, $22
	db $22, $22, $01, $09, $04, $01, $80, $00, $01, $50, $01, $01, $aa, $0f, $14, $01
	db $a5, $01, $01, $06, $0a, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $9A, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4B packed).
FloorAttrMap_3D_76::
	db $00, $01, $01, $11, $11
	db $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $28, $22, $01, $06, $0b, $01
	db $00, $00, $01, $09, $03, $33, $01, $02, $04, $01, $59, $0f, $05, $01, $80, $00
	db $01, $75, $0f, $08, $22, $22, $22, $22, $01, $7f, $00, $00, $01, $09, $07, $01
	db $a4, $0d, $01, $7f, $00, $01, $b9, $0f, $08, $01, $a0, $00, $22, $01, $09, $07
	db $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $9B, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $47 packed).
FloorAttrMap_3D_77::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01
	db $00, $00, $01, $fa, $ff, $07, $00, $01, $15, $0f, $09, $33, $33, $33, $01, $1e
	db $03, $01, $3b, $0f, $02, $33, $33, $22, $22, $22, $01, $05, $07, $01, $04, $01
	db $01, $65, $0f, $18, $22, $33, $01, $a1, $00, $01, $36, $0a, $01, $a4, $0f, $1a
	db $22, $01, $e1, $00, $01, $06, $0a, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $A0, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3A packed).
FloorAttrMap_3D_78::
	db $00, $01, $01
	db $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41
	db $03, $01, $39, $0f, $06, $01, $fa, $f2, $01, $58, $0f, $08, $01, $41, $00, $01
	db $77, $0f, $09, $01, $63, $0f, $0c, $01, $42, $0f, $0c, $22, $22, $22, $33, $33
	db $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $A1, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $18 packed).
FloorAttrMap_3D_79::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33
	db $01, $00, $00, $01, $fa, $ff, $4d, $01, $5a, $0f, $4d, $01, $9a, $0f, $23

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $A2, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $38 packed).
FloorAttrMap_3D_7A::
	db $00
	db $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $25, $00
	db $00, $01, $34, $0f, $0d, $22, $22, $01, $36, $0a, $01, $00, $00, $01, $08, $06
	db $01, $04, $02, $01, $78, $0f, $07, $01, $72, $0c, $01, $a2, $0e, $01, $34, $0f
	db $0b, $22, $22, $01, $04, $0f, $09

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $A3, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $41 packed).
FloorAttrMap_3D_7B::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33
	db $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41, $00, $01, $36, $0f, $09, $22
	db $22, $22, $22, $01, $36, $08, $01, $00, $00, $01, $66, $0f, $18, $01, $ff, $f1
	db $01, $96, $0f, $09, $00, $01, $41, $03, $01, $ba, $0f, $04, $22, $22, $22, $33
	db $33, $01, $64, $00, $01, $fa, $ff, $03

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $A4, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $22 packed).
FloorAttrMap_3D_7C::
	db $00, $01, $01, $11, $11, $11, $11, $33
	db $33, $01, $00, $00, $01, $fa, $ff, $4d, $01, $1a, $0f, $09, $00, $33, $33, $01
	db $79, $0f, $4a, $22, $22, $22, $01, $19, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $A5, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $32 packed).
FloorAttrMap_3D_7D::
	db $00, $01, $01, $11, $11, $11
	db $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33, $00, $01, $34, $0f
	db $2f, $01, $43, $00, $01, $7a, $0f, $04, $22, $22, $22, $01, $84, $09, $01, $01
	db $01, $01, $a6, $0f, $1d, $22, $22, $22, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $A6, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $38 packed).
FloorAttrMap_3D_7E::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $01, $41, $03
	db $01, $39, $0f, $06, $00, $22, $22, $22, $22, $00, $01, $58, $07, $01, $06, $01
	db $01, $68, $0f, $37, $01, $42, $0f, $0c, $22, $22, $22, $33, $33, $22, $22, $22
	db $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $A7, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $37 packed).
FloorAttrMap_3D_7F::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00
	db $01, $fa, $ff, $27, $22, $01, $04, $01, $01, $fa, $f6, $01, $03, $02, $01, $4a
	db $0f, $16, $33, $33, $01, $75, $0f, $0d, $22, $22, $01, $77, $0a, $01, $50, $01
	db $01, $aa, $0f, $16, $01, $44, $02, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $A8, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $36 packed).
FloorAttrMap_3D_80::
	db $00, $01, $01, $11, $11
	db $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $27, $22, $33, $33, $33, $33
	db $01, $09, $07, $11, $01, $45, $0c, $01, $44, $00, $01, $49, $08, $01, $54, $00
	db $01, $69, $0f, $39, $01, $45, $0f, $0c, $33, $33, $22, $22, $22, $01, $09, $0f
	db $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $A9, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $54 packed).
FloorAttrMap_3D_81::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff
	db $27, $22, $01, $04, $01, $01, $fa, $f6, $01, $03, $02, $01, $4a, $09, $33, $01
	db $58, $0f, $06, $01, $04, $00, $22, $01, $65, $00, $01, $7a, $07, $01, $64, $01
	db $01, $fa, $f3, $00, $01, $04, $00, $01, $96, $0f, $08, $22, $00, $33, $01, $c3
	db $00, $22, $01, $09, $05, $01, $c2, $02, $01, $08, $06, $22, $22, $33, $33, $22
	db $22, $01, $08, $0f, $05

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $AA, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3C packed).
FloorAttrMap_3D_82::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00
	db $00, $01, $fa, $ff, $24, $33, $01, $41, $03, $01, $39, $0f, $06, $22, $22, $33
	db $33, $22, $22, $00, $01, $39, $05, $01, $02, $02, $01, $68, $0f, $17, $33, $01
	db $a0, $03, $01, $9a, $0f, $24, $22, $22, $01, $03, $00, $22, $22, $01, $09, $0f
	db $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $AB, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4D packed).
FloorAttrMap_3D_83::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff
	db $24, $33, $00, $33, $33, $22, $01, $36, $0b, $01, $00, $00, $01, $39, $06, $00
	db $01, $54, $0f, $0a, $22, $22, $00, $33, $33, $01, $fe, $f0, $01, $fa, $f5, $01
	db $83, $0c, $22, $22, $33, $33, $01, $87, $08, $01, $02, $00, $01, $a7, $0b, $00
	db $22, $01, $b8, $0b, $01, $07, $0b, $01, $45, $00, $01, $fa, $ff, $03

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $B0, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $33 packed).
FloorAttrMap_3D_84::
	db $00, $01
	db $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33
	db $01, $fc, $f0, $33, $33, $01, $39, $0f, $08, $01, $61, $01, $01, $59, $0f, $48
	db $01, $44, $0f, $0a, $22, $01, $e1, $03, $01, $09, $07, $01, $f0, $02, $01, $a0
	db $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $B1, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $23 packed).
FloorAttrMap_3D_85::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff
	db $4d, $01, $5a, $0f, $4d, $01, $7a, $0f, $07, $22, $22, $01, $76, $0a, $01, $f0
	db $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $B2, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3D packed).
FloorAttrMap_3D_86::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00
	db $01, $fa, $ff, $24, $33, $01, $41, $00, $01, $36, $0f, $08, $00, $22, $22, $22
	db $22, $01, $56, $08, $01, $00, $00, $01, $66, $0f, $18, $01, $41, $01, $01, $43
	db $00, $01, $9a, $0f, $24, $01, $62, $00, $01, $62, $01, $01, $fa, $f6, $01, $74
	db $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $B3, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $2F packed).
FloorAttrMap_3D_87::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff
	db $29, $33, $33, $33, $01, $39, $0f, $08, $22, $22, $22, $22, $01, $48, $08, $01
	db $00, $01, $01, $69, $0f, $4d, $01, $79, $0b, $22, $01, $79, $0b, $01, $08, $04
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $B4, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $43 packed).
FloorAttrMap_3D_88::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $29
	db $33, $33, $33, $01, $39, $0f, $05, $00, $33, $00, $01, $54, $0f, $0b, $01, $61
	db $03, $01, $79, $0f, $05, $33, $00, $00, $33, $22, $22, $22, $22, $01, $99, $08
	db $01, $00, $00, $01, $09, $04, $01, $a5, $01, $01, $06, $0a, $01, $d0, $02, $01
	db $ca, $0f, $13

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $B5, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4C packed).
FloorAttrMap_3D_89::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01
	db $fa, $ff, $24, $33, $01, $41, $03, $01, $39, $0f, $09, $22, $22, $22, $01, $48
	db $09, $01, $01, $00, $01, $39, $05, $22, $22, $22, $01, $75, $09, $01, $00, $00
	db $01, $86, $0e, $00, $01, $99, $0f, $06, $33, $33, $33, $01, $fc, $f1, $01, $ba
	db $0f, $04, $22, $01, $e1, $03, $01, $09, $07, $01, $a2, $03, $01, $fa, $01

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $B6, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $38 packed).
FloorAttrMap_3D_8A::
	db $00
	db $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $25, $33
	db $00, $00, $22, $01, $36, $0b, $01, $00, $00, $01, $39, $06, $01, $04, $02, $01
	db $59, $0f, $07, $00, $01, $74, $0f, $0b, $22, $22, $01, $45, $01, $01, $09, $07
	db $01, $b0, $02, $01, $aa, $0f, $33

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $B7, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $56 packed).
FloorAttrMap_3D_8B::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33
	db $01, $00, $00, $01, $fa, $ff, $27, $22, $01, $04, $01, $01, $fa, $f6, $01, $03
	db $02, $01, $4a, $09, $33, $33, $01, $59, $0f, $05, $01, $04, $00, $22, $00, $01
	db $77, $0a, $11, $01, $86, $08, $00, $33, $01, $02, $00, $00, $01, $99, $0f, $05
	db $01, $85, $00, $33, $33, $22, $22, $01, $09, $05, $01, $c2, $01, $01, $07, $07
	db $22, $01, $e2, $00, $01, $47, $0a, $01, $50, $01, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $B8, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $48 packed).
FloorAttrMap_3D_8C::
	db $00, $01, $01
	db $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $28, $22, $01, $06
	db $0b, $01, $00, $00, $01, $09, $06, $01, $04, $02, $01, $59, $0f, $0b, $33, $33
	db $01, $79, $0f, $05, $33, $01, $a1, $03, $01, $99, $0f, $08, $22, $01, $c4, $00
	db $01, $99, $07, $01, $55, $01, $01, $09, $04, $01, $c6, $00, $01, $55, $0a, $01
	db $f0, $03, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $B9, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $40 packed).
FloorAttrMap_3D_8D::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00
	db $00, $01, $fa, $ff, $27, $22, $33, $01, $04, $00, $01, $fa, $f6, $11, $01, $45
	db $0f, $1b, $00, $00, $01, $75, $0f, $0b, $33, $33, $33, $22, $22, $01, $98, $0a
	db $01, $06, $09, $00, $01, $b4, $0f, $0c, $22, $01, $a6, $00, $01, $48, $09, $01
	db $50, $01, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $BA, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $23 packed).
FloorAttrMap_3D_8E::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00
	db $00, $01, $fa, $ff, $4d, $01, $1a, $0f, $07, $22, $22, $01, $16, $0a, $01, $90
	db $02, $01, $8a, $0f, $4d, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $BB, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $5D packed).
FloorAttrMap_3D_8F::
	db $00, $01, $01, $11, $11, $11, $11, $33
	db $33, $01, $00, $00, $01, $fa, $ff, $24, $33, $33, $33, $33, $22, $11, $11, $00
	db $01, $39, $08, $01, $07, $00, $01, $49, $0a, $00, $33, $01, $59, $0f, $07, $22
	db $33, $00, $00, $33, $01, $48, $07, $11, $01, $84, $0a, $22, $11, $22, $00, $33
	db $00, $01, $48, $06, $01, $07, $00, $01, $a6, $07, $22, $11, $11, $11, $22, $01
	db $43, $00, $01, $fa, $f6, $01, $02, $02, $01, $ca, $08, $22, $01, $45, $00, $01
	db $cb, $07, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $C0, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $27 packed).
FloorAttrMap_3D_90::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24
	db $33, $01, $41, $03, $01, $39, $0f, $4d, $01, $79, $0f, $25, $22, $22, $22, $33
	db $33, $22, $22, $22, $01, $09, $07, $33, $33, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $C1, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $23 packed).
FloorAttrMap_3D_91::
	db $00, $01, $01, $11
	db $01, $00, $05, $01, $fa, $ff, $27, $00, $33, $01, $36, $0f, $2c, $01, $7f, $03
	db $01, $7c, $0f, $25, $33, $01, $b5, $0f, $0d, $01, $45, $0b, $01, $e4, $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $C2, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $27 packed).
FloorAttrMap_3D_92::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $41, $03, $01, $39
	db $0f, $25, $22, $22, $22, $33, $33, $22, $22, $22, $01, $09, $07, $33, $33, $01
	db $06, $0a, $01, $94, $0f, $49

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $C3, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $43 packed).
FloorAttrMap_3D_93::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff
	db $24, $33, $01, $41, $00, $01, $fd, $f0, $01, $3a, $0f, $05, $22, $01, $62, $01
	db $01, $48, $06, $01, $04, $03, $01, $69, $0f, $1b, $33, $33, $01, $99, $0f, $06
	db $01, $41, $00, $01, $b6, $0f, $08, $22, $22, $22, $33, $33, $11, $22, $22, $01
	db $09, $07, $33, $01, $71, $01, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $C4, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4F packed).
FloorAttrMap_3D_94::
	db $00, $01, $01, $11, $01, $00, $05
	db $01, $fa, $ff, $24, $33, $33, $33, $33, $01, $fc, $f1, $01, $3a, $0f, $08, $22
	db $22, $22, $33, $01, $39, $08, $11, $11, $11, $01, $68, $06, $22, $22, $22, $01
	db $75, $09, $01, $00, $02, $01, $88, $0a, $01, $72, $00, $01, $9a, $0f, $04, $01
	db $fc, $f0, $01, $71, $01, $01, $ba, $0f, $04, $01, $65, $00, $01, $81, $01, $01
	db $fa, $f6, $01, $73, $01, $01, $09, $03

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $C5, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $2E packed).
FloorAttrMap_3D_95::
	db $00, $01, $01, $11, $01, $00, $05, $01
	db $fa, $ff, $24, $33, $01, $41, $00, $01, $36, $0f, $28, $22, $22, $22, $22, $01
	db $ff, $f1, $01, $fa, $f7, $01, $85, $0f, $1d, $01, $45, $08, $01, $c1, $0f, $00
	db $01, $44, $09, $01, $e1, $0b

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $C6, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $40 packed).
FloorAttrMap_3D_96::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff
	db $25, $33, $33, $33, $01, $fc, $f1, $01, $3a, $0f, $07, $22, $01, $64, $00, $01
	db $39, $07, $01, $04, $09, $33, $01, $72, $0f, $0f, $01, $73, $02, $01, $9a, $0f
	db $04, $22, $22, $01, $fe, $f3, $01, $fa, $f5, $01, $c3, $0c, $22, $01, $72, $02
	db $01, $fa, $f6, $01, $e4, $08

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $C7, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $19 packed).
FloorAttrMap_3D_97::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff
	db $4d, $01, $1a, $0f, $07, $33, $33, $01, $76, $0f, $4d, $01, $96, $0f, $07

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $C8, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $3A packed).
FloorAttrMap_3D_98::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $27, $33, $33, $33, $01, $37, $0f
	db $0b, $00, $01, $56, $0f, $0c, $01, $84, $00, $01, $79, $0f, $08, $22, $33, $01
	db $64, $00, $01, $fa, $f7, $01, $a5, $0e, $01, $87, $09, $01, $c4, $0c, $33, $33
	db $22, $22, $22, $01, $39, $09, $01, $06, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $C9, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $41 packed).
FloorAttrMap_3D_99::
	db $00, $01, $01, $11, $01, $00, $05
	db $01, $fa, $ff, $27, $33, $01, $44, $00, $01, $39, $0f, $0a, $22, $22, $01, $48
	db $0a, $11, $11, $01, $48, $08, $22, $22, $01, $76, $0a, $01, $40, $01, $01, $09
	db $0a, $01, $47, $09, $01, $a4, $0d, $00, $33, $33, $22, $01, $b9, $0b, $01, $38
	db $0a, $01, $84, $00, $01, $6a, $0a, $01, $08, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $CA, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $36 packed).
FloorAttrMap_3D_9A::
	db $00, $01, $01, $11, $01, $00
	db $05, $01, $fa, $ff, $26, $33, $01, $43, $00, $01, $38, $0f, $0c, $00, $01, $58
	db $0f, $0b, $00, $01, $47, $0b, $01, $86, $09, $22, $22, $33, $22, $22, $01, $08
	db $09, $33, $01, $06, $0b, $01, $b5, $0f, $0c, $01, $46, $00, $01, $d8, $0f, $05
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $CB, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $50 packed).
FloorAttrMap_3D_9B::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $00, $00, $00, $33, $33
	db $01, $3d, $03, $01, $3d, $0f, $02, $33, $01, $62, $01, $01, $58, $0f, $08, $22
	db $22, $22, $22, $01, $67, $08, $01, $00, $00, $01, $67, $06, $22, $01, $92, $02
	db $22, $01, $09, $05, $01, $92, $02, $01, $08, $06, $01, $62, $02, $01, $b8, $0f
	db $07, $22, $22, $33, $33, $22, $22, $01, $08, $08, $01, $c6, $00, $01, $08, $04
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $D0, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $34 packed).
FloorAttrMap_3D_9C::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $fa, $f2, $33
	db $01, $39, $0f, $04, $33, $33, $01, $5e, $03, $01, $59, $0f, $24, $22, $01, $61
	db $0b, $01, $40, $00, $01, $a4, $0c, $01, $44, $0f, $09, $11, $22, $01, $e1, $03
	db $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $D1, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $1B packed).
FloorAttrMap_3D_9D::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $43, $33
	db $01, $60, $04, $01, $59, $0f, $24, $22, $01, $a0, $04, $01, $09, $0f, $44

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $D2, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $49 packed).
FloorAttrMap_3D_9E::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $25, $33, $01, $42, $02, $01, $39
	db $0f, $04, $01, $42, $00, $22, $22, $22, $22, $01, $58, $08, $01, $00, $00, $01
	db $58, $05, $22, $22, $22, $01, $74, $09, $01, $00, $03, $01, $48, $04, $01, $83
	db $01, $01, $75, $07, $01, $00, $04, $01, $48, $0f, $05, $01, $40, $0e, $01, $64
	db $00, $01, $81, $00, $01, $fa, $ff, $03

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $D3, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $48 packed).
FloorAttrMap_3D_9F::
	db $00, $01, $01, $11, $01, $00, $05, $01
	db $fa, $ff, $28, $33, $33, $33, $33, $01, $39, $0f, $04, $33, $01, $41, $01, $22
	db $22, $01, $58, $0a, $01, $73, $00, $01, $5a, $03, $33, $33, $33, $01, $fe, $f0
	db $01, $78, $0f, $05, $22, $22, $22, $01, $fd, $f1, $01, $48, $07, $01, $a3, $0f
	db $00, $00, $01, $47, $08, $01, $c3, $0c, $22, $01, $e3, $01, $01, $09, $0f, $04
;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $D4, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $41 packed).
FloorAttrMap_3D_A0::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $28, $33, $33, $33, $33, $01
	db $39, $0f, $04, $01, $45, $00, $01, $5e, $01, $01, $59, $0f, $08, $01, $63, $01
	db $01, $79, $0f, $04, $22, $22, $22, $22, $01, $62, $01, $01, $09, $07, $01, $a4
	db $0e, $33, $22, $22, $01, $b9, $0a, $01, $07, $09, $22, $22, $22, $01, $07, $0f
	db $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $D5, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4D packed).
FloorAttrMap_3D_A1::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $26, $33, $01, $43, $01
	db $01, $39, $0f, $04, $33, $01, $41, $00, $00, $22, $22, $01, $58, $0a, $11, $11
	db $01, $58, $05, $01, $43, $00, $22, $01, $76, $0b, $01, $40, $00, $01, $09, $03
	db $22, $22, $01, $92, $01, $00, $01, $48, $06, $01, $a2, $0c, $01, $a1, $00, $01
	db $46, $0f, $07, $11, $11, $11, $22, $01, $e3, $01, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $D6, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $49 packed).
FloorAttrMap_3D_A2::
	db $00, $01
	db $01, $11, $01, $00, $05, $01, $fa, $ff, $29, $33, $33, $33, $01, $39, $0f, $04
	db $33, $01, $42, $03, $01, $58, $0f, $06, $33, $00, $01, $64, $01, $01, $78, $0f
	db $05, $22, $33, $01, $7e, $00, $22, $22, $22, $01, $09, $04, $01, $a1, $01, $01
	db $06, $07, $22, $00, $00, $22, $22, $01, $06, $08, $01, $fe, $f4, $01, $fa, $f4
	db $01, $c4, $02, $01, $08, $0f, $05

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $D7, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $1B packed).
FloorAttrMap_3D_A3::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa
	db $ff, $43, $33, $33, $33, $33, $01, $54, $0f, $29, $22, $22, $22, $22, $01, $04
	db $0f, $49

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $D8, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $42 packed).
FloorAttrMap_3D_A4::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $27, $33, $01, $44
	db $00, $01, $39, $0f, $04, $33, $01, $51, $0f, $0d, $01, $44, $00, $22, $22, $22
	db $22, $01, $79, $08, $01, $05, $07, $22, $00, $00, $33, $01, $ff, $f2, $01, $fa
	db $f3, $01, $a1, $0c, $33, $33, $01, $5f, $01, $01, $b8, $0f, $06, $01, $85, $01
	db $01, $06, $0f, $07

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $D9, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4D packed).
FloorAttrMap_3D_A5::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33
	db $01, $41, $03, $01, $39, $0f, $04, $33, $33, $22, $01, $62, $00, $01, $57, $07
	db $01, $00, $01, $01, $67, $0c, $22, $22, $01, $69, $0a, $01, $07, $05, $22, $33
	db $33, $00, $01, $71, $02, $01, $3a, $05, $01, $a3, $0a, $22, $00, $33, $33, $01
	db $6e, $01, $01, $fa, $f4, $01, $c2, $0c, $01, $62, $01, $01, $87, $05, $01, $00
	db $0c

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $DA, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4A packed).
FloorAttrMap_3D_A6::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $25, $33, $33, $33, $01
	db $35, $0f, $08, $33, $33, $33, $33, $01, $fe, $f2, $01, $5a, $0f, $04, $22, $01
	db $61, $00, $01, $56, $07, $01, $41, $00, $01, $65, $07, $22, $11, $33, $00, $01
	db $43, $02, $01, $3a, $05, $01, $a3, $0b, $22, $33, $33, $22, $01, $06, $09, $01
	db $43, $0b, $11, $22, $01, $c5, $01, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $DB, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $4A packed).
FloorAttrMap_3D_A7::
	db $00, $01, $01, $11, $01
	db $00, $05, $01, $fa, $ff, $26, $33, $01, $43, $00, $01, $38, $0f, $05, $33, $01
	db $41, $00, $00, $01, $56, $0f, $08, $33, $11, $33, $22, $01, $55, $08, $33, $11
	db $33, $01, $42, $00, $01, $08, $04, $22, $01, $91, $00, $22, $22, $22, $01, $08
	db $05, $01, $91, $00, $01, $05, $08, $01, $45, $01, $01, $b6, $0f, $08, $01, $a5
	db $01, $01, $06, $0f, $07

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $E0, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $40 packed).
FloorAttrMap_3D_A8::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24
	db $01, $fc, $f0, $33, $33, $33, $33, $01, $39, $0f, $06, $01, $45, $00, $01, $45
	db $00, $01, $5a, $0f, $04, $01, $62, $04, $01, $79, $0f, $07, $01, $43, $02, $22
	db $01, $9a, $0b, $01, $39, $08, $01, $44, $00, $01, $b9, $0f, $05, $22, $01, $e1
	db $03, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $E1, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $23 packed).
FloorAttrMap_3D_A9::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $44
	db $00, $33, $01, $62, $03, $01, $5a, $0f, $04, $01, $62, $04, $01, $79, $0f, $05
	db $22, $01, $a1, $04, $01, $fa, $ff, $43

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $E2, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $2B packed).
FloorAttrMap_3D_AA::
	db $00, $01, $01, $11, $01, $00, $05, $01
	db $fa, $ff, $24, $33, $33, $33, $01, $34, $0f, $0d, $01, $61, $02, $01, $5a, $0f
	db $27, $22, $01, $a4, $01, $01, $3a, $0f, $17, $01, $04, $09, $22, $22, $22, $01
	db $04, $0f, $09

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $E3, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $46 packed).
FloorAttrMap_3D_AB::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $01, $fc
	db $f0, $33, $33, $01, $37, $0f, $08, $22, $22, $22, $01, $45, $00, $33, $01, $3a
	db $04, $11, $11, $11, $01, $65, $0c, $22, $22, $11, $00, $01, $69, $08, $01, $07
	db $00, $01, $89, $0c, $22, $01, $8a, $0b, $01, $39, $08, $01, $bc, $07, $01, $c0
	db $0d, $22, $01, $e1, $03, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $E4, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $44 packed).
FloorAttrMap_3D_AC::
	db $00, $01, $01, $11, $01, $00, $05
	db $01, $fa, $ff, $26, $33, $01, $43, $00, $01, $38, $0f, $08, $00, $01, $43, $01
	db $33, $01, $5a, $0f, $07, $22, $01, $65, $0b, $01, $42, $02, $01, $fa, $f3, $33
	db $33, $00, $11, $00, $00, $22, $22, $22, $01, $9a, $09, $01, $07, $06, $01, $67
	db $02, $01, $b7, $0f, $07, $22, $01, $e1, $01, $01, $07, $0f, $06

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $E5, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $35 packed).
FloorAttrMap_3D_AD::
	db $00, $01, $01
	db $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $00, $00, $11, $00, $00, $33, $33
	db $01, $39, $0f, $06, $33, $00, $11, $00, $33, $33, $33, $33, $01, $5a, $0f, $06
	db $01, $69, $00, $01, $77, $0f, $07, $22, $01, $a1, $04, $01, $fa, $ff, $34, $01
	db $01, $0b

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $E6, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $49 packed).
FloorAttrMap_3D_AE::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $25, $33, $01, $fe
	db $f3, $01, $3a, $0f, $06, $33, $33, $01, $00, $00, $33, $01, $5a, $0f, $08, $33
	db $01, $61, $00, $01, $7a, $0f, $05, $22, $22, $00, $01, $82, $00, $22, $01, $fa
	db $f6, $01, $a4, $01, $01, $09, $07, $22, $22, $33, $33, $22, $01, $09, $09, $01
	db $63, $00, $01, $fa, $f8, $22, $22, $01, $08, $0f, $05

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $E7, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $1B packed).
FloorAttrMap_3D_AF::
	db $00, $01, $01, $11, $01
	db $00, $05, $01, $fa, $ff, $49, $33, $33, $33, $33, $01, $5a, $0f, $29, $22, $22
	db $22, $22, $01, $fa, $ff, $43

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $E8, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $37 packed).
FloorAttrMap_3D_B0::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff
	db $28, $33, $33, $33, $33, $01, $39, $0f, $07, $01, $45, $00, $33, $33, $33, $01
	db $5a, $0f, $09, $22, $22, $22, $01, $69, $09, $01, $42, $00, $01, $8a, $0b, $22
	db $01, $8a, $0b, $01, $09, $06, $22, $22, $22, $01, $06, $0f, $27

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $E9, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $31 packed).
FloorAttrMap_3D_B1::
	db $00, $01, $01
	db $11, $01, $00, $05, $01, $fa, $ff, $24, $01, $f8, $f5, $01, $3a, $0f, $04, $33
	db $33, $01, $fa, $f2, $01, $62, $03, $01, $60, $0f, $1e, $01, $f8, $f4, $22, $01
	db $3a, $0f, $14, $01, $41, $0c, $22, $01, $e1, $03, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $EA, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $49 packed).
FloorAttrMap_3D_B2::
	db $00, $01
	db $01, $11, $01, $00, $05, $01, $fa, $ff, $24, $33, $01, $41, $00, $01, $36, $0f
	db $09, $00, $22, $33, $33, $01, $40, $00, $01, $5a, $05, $11, $01, $64, $0a, $01
	db $65, $00, $01, $76, $0f, $0c, $00, $11, $33, $22, $22, $01, $9a, $0a, $01, $08
	db $05, $22, $22, $01, $09, $00, $01, $b7, $06, $01, $07, $02, $01, $c7, $09, $22
	db $22, $22, $22, $01, $08, $0f, $05

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $EB, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $50 packed).
FloorAttrMap_3D_B3::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa
	db $ff, $26, $00, $33, $00, $33, $01, $37, $0f, $08, $33, $01, $43, $00, $33, $33
	db $33, $01, $5a, $0f, $06, $33, $00, $00, $33, $33, $22, $01, $79, $0b, $11, $01
	db $69, $05, $22, $01, $66, $00, $22, $11, $22, $01, $fa, $f5, $01, $66, $00, $01
	db $07, $08, $22, $01, $a5, $00, $01, $08, $08, $01, $b5, $01, $01, $09, $07, $22
	db $01, $c6, $00, $01, $09, $0f, $04

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $F0, $F1, $F2, $F3, $F4, $F5, ...; GateAttrMaps2 $F0,
;@ $F1, $F2, $F3, $F4, $F5, ..., by the room's layout byte), unpacked to wScreenMap by LoadMapAttrBuffer: two
;@ 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked, $13 packed).
FloorAttrMap_3D_B4::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa
	db $ff, $4d, $01, $5a, $0f, $4d, $01, $9a, $0f, $23

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $0C, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $25 packed).
FloorAttrMap_3D_B5::
	db $00, $01, $01, $11, $11, $11
	db $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $43, $33, $01, $60, $05, $01, $5a
	db $0f, $23, $22, $22, $22, $22, $33, $33, $01, $a0, $00, $01, $fa, $ff, $43

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $1C, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $28 packed).
FloorAttrMap_3D_B6::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $43, $33, $01, $60, $05, $01, $5a
	db $0f, $23, $22, $22, $22, $22, $33, $33, $01, $a0, $00, $01, $fa, $f6, $33, $33
	db $01, $06, $0a, $01, $b4, $0f, $29

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $2C, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $26 packed).
FloorAttrMap_3D_B7::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33
	db $01, $00, $00, $01, $fa, $ff, $43, $33, $01, $60, $05, $01, $5a, $0f, $23, $22
	db $01, $a0, $05, $01, $fa, $f6, $01, $b0, $02, $01, $aa, $0f, $33

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $3C, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $1F packed).
FloorAttrMap_3D_B8::
	db $00, $01, $01
	db $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $49, $01, $64, $00
	db $01, $5a, $0f, $29, $22, $22, $22, $22, $01, $fa, $ff, $43

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $4C, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $20 packed).
FloorAttrMap_3D_B9::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $43, $33, $01, $60, $01
	db $01, $56, $0f, $27, $22, $22, $22, $22, $01, $04, $0f, $49

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $5C, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $1B packed).
FloorAttrMap_3D_BA::
	db $00, $01, $01, $11
	db $01, $00, $05, $01, $fa, $ff, $43, $33, $01, $60, $05, $01, $5a, $0f, $23, $22
	db $01, $a0, $05, $01, $fa, $ff, $43

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $6C, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $21 packed).
FloorAttrMap_3D_BB::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa
	db $ff, $47, $33, $01, $64, $01, $01, $5a, $0f, $29, $22, $22, $22, $22, $01, $5a
	db $08, $01, $56, $0c, $01, $b6, $0f, $27

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $7C, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $21 packed).
FloorAttrMap_3D_BC::
	db $00, $01, $01, $11, $01, $00, $05, $01
	db $fa, $ff, $43, $33, $01, $60, $01, $01, $56, $0f, $27, $22, $22, $22, $22, $01
	db $64, $08, $01, $00, $00, $01, $a4, $0f, $39

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $8C, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $25 packed).
FloorAttrMap_3D_BD::
	db $00, $01, $01, $11, $11, $11, $11
	db $33, $33, $01, $00, $00, $01, $fa, $ff, $49, $01, $64, $00, $01, $5a, $0f, $27
	db $22, $01, $a4, $01, $01, $fa, $f6, $01, $b0, $02, $01, $aa, $0f, $33

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $9C, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $26 packed).
FloorAttrMap_3D_BE::
	db $00, $01
	db $01, $11, $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $43, $33, $01
	db $60, $01, $01, $56, $0f, $27, $22, $01, $a0, $01, $01, $06, $0a, $01, $b0, $02
	db $01, $aa, $0f, $33

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $AC, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $18 packed).
FloorAttrMap_3D_BF::
	db $00, $01, $01, $11, $11, $11, $11, $33, $33, $01, $00, $00
	db $01, $fa, $ff, $4d, $01, $5a, $0f, $4d, $01, $9a, $0f, $23

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $BC, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $23 packed).
FloorAttrMap_3D_C0::
	db $00, $01, $01, $11
	db $11, $11, $11, $33, $33, $01, $00, $00, $01, $fa, $ff, $4d, $01, $5a, $0f, $4d
	db $01, $7a, $0f, $07, $22, $22, $01, $76, $0a, $01, $f0, $02, $01, $a0, $f2

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $CC, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $15 packed).
FloorAttrMap_3D_C1::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $27, $33, $33, $01, $36, $0f, $4d
	db $01, $96, $0f, $47

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $DC, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $1B packed).
FloorAttrMap_3D_C2::
	db $00, $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $43, $33
	db $01, $60, $04, $01, $59, $0f, $24, $22, $01, $a0, $04, $01, $09, $0f, $44

;@ path: gfx/palettes/floorattrmaps
;@ CGB attribute map of a gate floor room (GateAttrMaps1 $EC, by the room's layout byte), unpacked to wScreenMap
;@ by LoadMapAttrBuffer: two 4-bit values per byte. Compressed in the DecompressCore format ($100 bytes unpacked,
;@ $1B packed).
FloorAttrMap_3D_C3::
	db $00
	db $01, $01, $11, $01, $00, $05, $01, $fa, $ff, $44, $33, $01, $61, $04, $01, $5a
	db $0f, $24, $22, $01, $a1, $04, $01, $fa, $ff, $43

;@ path: unused/filler
;@ Unused filler up to the end of the bank.
Unused_3D::
	db $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
