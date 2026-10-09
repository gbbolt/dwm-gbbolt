INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $02b", ROMX[$4000], BANK[$2b]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_2B::
	db $2b

;@ path: field/gatefloor/tables
;@ Entry table of bank $2B: the address of each compressed block (entry number = position), as DecompressSetup
;@ finds it for Decompress / DecompressVRAM (bank, entry).
FarTable_2B::
	dw FloorScreen_2B_00
	dw FloorScreen_2B_01
	dw FloorScreen_2B_02
	dw FloorScreen_2B_03
	dw FloorScreen_2B_04
	dw FloorScreen_2B_05
	dw FloorScreen_2B_06
	dw FloorScreen_2B_07
	dw FloorScreen_2B_08
	dw FloorScreen_2B_09
	dw FloorScreen_2B_0A
	dw FloorScreen_2B_0B
	dw FloorScreen_2B_0C
	dw FloorScreen_2B_0D
	dw FloorScreen_2B_0E
	dw FloorScreen_2B_0F
	dw FloorScreen_2B_10
	dw FloorScreen_2B_11
	dw FloorScreen_2B_12
	dw FloorScreen_2B_13
	dw FloorScreen_2B_14
	dw FloorScreen_2B_15
	dw FloorScreen_2B_16
	dw FloorScreen_2B_17
	dw FloorScreen_2B_18
	dw FloorScreen_2B_19
	dw FloorScreen_2B_1A
	dw FloorScreen_2B_1B
	dw FloorScreen_2B_1C
	dw FloorScreen_2B_1D
	dw FloorScreen_2B_1E
	dw FloorScreen_2B_1F
	dw FloorScreen_2B_20
	dw FloorScreen_2B_21
	dw FloorScreen_2B_22
	dw FloorScreen_2B_23
	dw FloorScreen_2B_24
	dw FloorScreen_2B_25
	dw FloorScreen_2B_26
	dw FloorScreen_2B_27
	dw FloorScreen_2B_28
	dw FloorScreen_2B_29
	dw FloorScreen_2B_2A
	dw FloorScreen_2B_2B
	dw FloorScreen_2B_2C
	dw FloorScreen_2B_2D
	dw FloorScreen_2B_2E
	dw FloorScreen_2B_2F
	dw FloorScreen_2B_30
	dw FloorScreen_2B_31
	dw FloorScreen_2B_32
	dw FloorScreen_2B_33
	dw FloorScreen_2B_34
	dw FloorScreen_2B_35
	dw FloorScreen_2B_36
	dw FloorScreen_2B_37
	dw FloorScreen_2B_38
	dw FloorScreen_2B_39
	dw FloorScreen_2B_3A
	dw FloorScreen_2B_3B
	dw FloorScreen_2B_3C
	dw FloorScreen_2B_3D
	dw FloorScreen_2B_3E
	dw FloorScreen_2B_3F
	dw FloorScreen_2B_40
	dw FloorScreen_2B_41
	dw FloorScreen_2B_42
	dw FloorScreen_2B_43
	dw FloorScreen_2B_44
	dw FloorScreen_2B_45
	dw FloorScreen_2B_46
	dw FloorScreen_2B_47

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $06, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $106 packed).
FloorScreen_2B_00::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24
	db $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32
	db $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $0c, $00, $02, $28, $29
	db $04, $05, $30, $31, $06, $07, $08, $09, $08, $09, $24, $25, $0c, $14, $0e, $2a
	db $2b, $14, $15, $32, $33, $16, $17, $18, $19, $18, $19, $26, $27, $0c, $14, $08
	db $0c, $50, $00, $0c, $02, $06, $38, $39, $38, $39, $06, $07, $0c, $14, $08, $0c
	db $70, $00, $0c, $22, $06, $3a, $3b, $3a, $3b, $16, $17, $0c, $14, $08, $0c, $4a
	db $00, $0c, $0c, $00, $2c, $2d, $0c, $8e, $00, $0c, $8e, $00, $30, $31, $0c, $14
	db $08, $0c, $6a, $00, $0c, $2c, $00, $2e, $2f, $0c, $ae, $00, $0c, $ae, $00, $32
	db $33, $0c, $b4, $0a, $0c, $0a, $02, $0c, $c8, $06, $38, $39, $0c, $d4, $0a, $0c
	db $2a, $02, $0c, $e8, $06, $3a, $3b, $0c, $14, $08, $0c, $48, $04, $0a, $0b, $34
	db $35, $0c, $ca, $02, $00, $01, $0c, $14, $08, $0c, $68, $04, $1a, $1b, $36, $37
	db $0c, $ea, $02, $10, $11, $0c, $14, $08, $0c, $06, $02, $30, $31, $34, $35, $0c
	db $88, $10, $00, $01, $02, $03, $0c, $12, $0a, $0c, $26, $02, $32, $33, $36, $37
	db $0c, $a8, $10, $10, $11, $12, $13, $0c, $32, $0c, $02, $03, $02, $03, $0c, $48
	db $00, $30, $31, $00, $01, $0c, $0e, $0f, $01, $12, $13, $12, $13, $0c, $68, $00
	db $32, $33, $10, $11, $0c, $2e, $0e

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $07, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $10E packed).
FloorScreen_2B_01::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c
	db $2d, $30, $31, $30, $31, $24, $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b
	db $0c, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14
	db $08, $0c, $04, $00, $08, $09, $0a, $0b, $0c, $08, $00, $06, $07, $08, $09, $0c
	db $0c, $00, $0c, $14, $0a, $2e, $2f, $18, $19, $1a, $1b, $0c, $28, $00, $16, $17
	db $18, $19, $0c, $2c, $00, $0c, $14, $08, $08, $09, $0e, $0f, $38, $39, $0c, $84
	db $00, $0c, $08, $00, $30, $31, $0e, $0f, $08, $09, $0c, $14, $08, $18, $19, $1e
	db $1f, $3a, $3b, $0c, $a4, $00, $0c, $28, $00, $32, $33, $1e, $1f, $18, $19, $0c
	db $14, $08, $34, $35, $20, $21, $0c, $08, $00, $00, $01, $04, $05, $0c, $08, $00
	db $0c, $c2, $00, $0c, $14, $08, $36, $37, $22, $23, $0c, $28, $00, $10, $11, $14
	db $15, $0c, $28, $00, $0c, $e2, $00, $0c, $b4, $0a, $0c, $c4, $02, $0c, $00, $00
	db $0c, $ca, $02, $0c, $d2, $0c, $0c, $e4, $02, $0c, $20, $00, $0c, $ea, $02, $0c
	db $f2, $0a, $0c, $ca, $02, $0c, $4c, $00, $0c, $44, $04, $00, $01, $0c, $14, $08
	db $0c, $ea, $02, $0c, $6c, $00, $0c, $64, $04, $10, $11, $0c, $34, $0a, $0c, $ca
	db $02, $34, $35, $0c, $88, $12, $0c, $06, $10, $0c, $14, $0a, $0c, $ea, $02, $36
	db $37, $0c, $a8, $12, $0c, $26, $10, $0c, $34, $0a, $28, $29, $02, $03, $04, $05
	db $0c, $8c, $12, $02, $03, $0c, $10, $0f, $01, $12, $13, $14, $15, $0c, $ac, $12
	db $12, $13, $0c, $30, $0c

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $08, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $10C packed).
FloorScreen_2B_02::
	db $00, $02, $0e, $28, $29, $0e, $00, $00, $2c, $2d, $30
	db $31, $30, $31, $24, $25, $0e, $00, $02, $ff, $0e, $14, $07, $2a, $2b, $0e, $20
	db $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0e, $20, $02, $0e, $14, $08, $2c
	db $2d, $08, $09, $08, $09, $0a, $0b, $34, $35, $00, $01, $0e, $04, $00, $08, $09
	db $24, $25, $0e, $14, $08, $2e, $2f, $18, $19, $18, $19, $1a, $1b, $36, $37, $10
	db $11, $0e, $24, $00, $18, $19, $26, $27, $0e, $14, $08, $0a, $0b, $30, $31, $34
	db $35, $0e, $84, $00, $06, $07, $0e, $44, $00, $30, $31, $06, $07, $0e, $14, $08
	db $1a, $1b, $32, $33, $36, $37, $0e, $a4, $00, $16, $17, $0e, $64, $00, $32, $33
	db $16, $17, $0e, $14, $08, $0e, $08, $00, $0c, $0d, $34, $35, $0e, $08, $00, $30
	db $31, $38, $39, $38, $39, $30, $31, $0e, $14, $08, $0e, $28, $00, $1c, $1d, $36
	db $37, $0e, $28, $00, $32, $33, $3a, $3b, $3a, $3b, $32, $33, $0e, $b4, $0a, $0e
	db $4a, $00, $02, $03, $0e, $06, $12, $04, $05, $0e, $d0, $0e, $0e, $6a, $00, $12
	db $13, $0e, $26, $12, $14, $15, $0e, $f0, $0c, $02, $03, $0e, $00, $04, $0e, $42
	db $02, $0e, $00, $10, $0e, $14, $08, $12, $13, $0e, $20, $04, $0e, $62, $02, $0e
	db $20, $10, $0e, $14, $08, $0e, $00, $04, $0e, $80, $00, $0e, $c8, $02, $0e, $52
	db $0a, $0e, $20, $04, $0e, $a0, $00, $0e, $e8, $02, $0e, $72, $0a, $0e, $00, $08
	db $00, $01, $0e, $06, $10, $0e, $12, $0f, $07, $10, $11, $0e, $26, $10, $0e, $32
	db $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $09, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $107 packed).
FloorScreen_2B_03::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24
	db $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32
	db $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $0c, $00, $02, $28, $29
	db $04, $05, $34, $35, $0c, $0c, $0f, $07, $2a, $2b, $14, $15, $36, $37, $0c, $2c
	db $0f, $01, $08, $09, $24, $25, $2c, $2d, $08, $09, $0a, $0b, $0c, $4a, $00, $0c
	db $84, $00, $08, $09, $0c, $14, $08, $18, $19, $26, $27, $2e, $2f, $18, $19, $1a
	db $1b, $0c, $6a, $00, $0c, $a4, $00, $18, $19, $0c, $14, $08, $30, $31, $06, $07
	db $0a, $0b, $30, $31, $34, $35, $0c, $8a, $02, $0c, $08, $00, $0c, $14, $08, $32
	db $33, $16, $17, $1a, $1b, $32, $33, $36, $37, $0c, $aa, $02, $0c, $28, $00, $0c
	db $b4, $0a, $0c, $c8, $00, $0c, $08, $00, $00, $01, $0c, $04, $00, $0c, $04, $10
	db $0c, $d4, $0a, $0c, $e8, $00, $0c, $28, $00, $10, $11, $0c, $24, $00, $0c, $24
	db $10, $0c, $14, $08, $02, $03, $0c, $40, $10, $04, $05, $38, $39, $06, $07, $0c
	db $86, $00, $0c, $08, $10, $0c, $14, $08, $12, $13, $0c, $60, $10, $14, $15, $3a
	db $3b, $16, $17, $0c, $a6, $00, $0c, $28, $10, $0c, $34, $0e, $2c, $2d, $38, $39
	db $0c, $08, $00, $0c, $08, $02, $0c, $14, $0f, $01, $3a, $3b, $0c, $28, $00, $0c
	db $28, $02, $0c, $74, $1f, $01, $0c, $06, $12, $0c, $40, $10, $0c, $12, $0f, $07
	db $10, $11, $0c, $60, $10, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $0A, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $FD packed).
FloorScreen_2B_04::
	db $00, $02, $0c, $28, $29, $0c, $00, $00
	db $2c, $2d, $30, $31, $30, $31, $24, $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a
	db $2b, $0c, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0c, $20, $02, $0c
	db $14, $08, $2c, $2d, $08, $09, $08, $09, $0a, $0b, $30, $31, $00, $01, $0c, $00
	db $02, $0c, $12, $0a, $2e, $2f, $18, $19, $18, $19, $1a, $1b, $32, $33, $10, $11
	db $0c, $20, $02, $0c, $32, $0a, $0a, $0b, $38, $39, $0c, $82, $02, $0c, $0c, $02
	db $0c, $40, $00, $0c, $14, $08, $1a, $1b, $3a, $3b, $0c, $a2, $02, $0c, $2c, $02
	db $0c, $60, $00, $0c, $14, $08, $30, $31, $38, $39, $0c, $c0, $02, $06, $07, $0c
	db $42, $02, $34, $35, $0c, $14, $08, $32, $33, $3a, $3b, $0c, $e0, $02, $16, $17
	db $0c, $62, $02, $36, $37, $0c, $b4, $0c, $0c, $c2, $04, $30, $31, $34, $35, $0c
	db $08, $00, $0c, $d4, $0c, $0c, $e2, $04, $32, $33, $36, $37, $0c, $28, $00, $0c
	db $14, $08, $02, $03, $0c, $40, $12, $04, $05, $0c, $0c, $12, $34, $35, $00, $01
	db $0c, $14, $08, $12, $13, $0c, $60, $12, $14, $15, $0c, $2c, $12, $36, $37, $10
	db $11, $0c, $14, $08, $0c, $00, $04, $0c, $d0, $00, $0c, $8a, $10, $0c, $0a, $00
	db $0c, $14, $0f, $01, $0c, $f0, $00, $0c, $aa, $10, $0c, $2a, $00, $0c, $74, $1f
	db $01, $0c, $08, $00, $00, $01, $0c, $40, $10, $0c, $12, $0f, $07, $10, $11, $0c
	db $60, $10, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $0B, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $FF packed).
FloorScreen_2B_05::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30
	db $31, $30, $31, $24, $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20
	db $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $2c
	db $2d, $08, $09, $08, $09, $0a, $0b, $0c, $08, $00, $06, $07, $08, $09, $0c, $0c
	db $00, $0c, $14, $08, $2e, $2f, $18, $19, $18, $19, $1a, $1b, $0c, $28, $00, $16
	db $17, $18, $19, $0c, $2c, $00, $0c, $14, $08, $0a, $0b, $34, $35, $38, $39, $34
	db $35, $0c, $08, $00, $30, $31, $38, $39, $0c, $4c, $00, $0c, $14, $08, $1a, $1b
	db $36, $37, $3a, $3b, $36, $37, $0c, $28, $00, $32, $33, $3a, $3b, $0c, $6c, $00
	db $0c, $14, $08, $0c, $08, $00, $0c, $86, $02, $00, $01, $04, $05, $38, $39, $38
	db $39, $30, $31, $0c, $14, $08, $0c, $28, $00, $0c, $a6, $02, $10, $11, $14, $15
	db $3a, $3b, $3a, $3b, $32, $33, $0c, $b4, $0a, $0c, $84, $04, $0c, $0c, $00, $02
	db $03, $04, $05, $0c, $d2, $0c, $0c, $a4, $04, $0c, $2c, $00, $12, $13, $14, $15
	db $0c, $f2, $0a, $04, $05, $0c, $82, $04, $0c, $0c, $04, $02, $03, $0c, $14, $08
	db $14, $15, $0c, $a2, $04, $0c, $2c, $04, $12, $13, $0c, $34, $0a, $0c, $86, $04
	db $06, $07, $0c, $0c, $0f, $01, $2e, $2f, $0c, $a6, $04, $16, $17, $0c, $2c, $0f
	db $01, $0c, $0c, $10, $0c, $0e, $12, $0c, $0a, $0f, $05, $12, $13, $0c, $2e, $12
	db $0c, $2a, $0f, $03

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $16, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $E7 packed).
FloorScreen_2B_06::
	db $00, $02, $0c, $28, $29, $0c, $00, $0e, $ff, $0c, $14, $07
	db $2a, $2b, $0c, $20, $0e, $0c, $14, $08, $0c, $00, $04, $2c, $2d, $08, $09, $0c
	db $4a, $02, $24, $25, $0c, $14, $0f, $01, $2e, $2f, $18, $19, $0c, $6a, $02, $26
	db $27, $0c, $14, $08, $0c, $4e, $02, $0c, $46, $00, $38, $39, $0c, $8a, $00, $30
	db $31, $06, $07, $0c, $14, $08, $0c, $6e, $02, $0c, $66, $00, $3a, $3b, $0c, $aa
	db $00, $32, $33, $16, $17, $0c, $14, $08, $30, $31, $30, $31, $0c, $84, $04, $00
	db $01, $04, $05, $0c, $c0, $00, $0c, $14, $08, $32, $33, $32, $33, $0c, $a4, $04
	db $10, $11, $14, $15, $0c, $e0, $00, $0c, $b4, $0c, $06, $07, $08, $09, $0a, $0b
	db $38, $39, $24, $25, $2c, $2d, $0c, $d0, $0f, $01, $16, $17, $18, $19, $1a, $1b
	db $3a, $3b, $26, $27, $2e, $2f, $0c, $f0, $0c, $0c, $ce, $00, $34, $35, $0c, $44
	db $10, $0c, $c2, $02, $02, $03, $02, $03, $0c, $14, $08, $0c, $ee, $00, $36, $37
	db $0c, $64, $10, $0c, $e2, $02, $12, $13, $12, $13, $0c, $14, $08, $0c, $0e, $10
	db $0c, $44, $12, $34, $35, $0c, $84, $00, $0c, $10, $0c, $0c, $2e, $10, $0c, $64
	db $12, $36, $37, $0c, $a4, $00, $0c, $30, $0e, $0c, $50, $10, $04, $05, $0c, $88
	db $1f, $05, $0c, $6e, $12, $14, $15, $0c, $a8, $1f, $05

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $17, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $C0 packed).
FloorScreen_2B_07::
	db $00, $02, $0c, $28, $29
	db $0c, $00, $0e, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $0e, $0c, $14, $08, $2c
	db $2d, $08, $09, $0c, $42, $0a, $24, $25, $0c, $14, $08, $2e, $2f, $18, $19, $0c
	db $62, $0a, $26, $27, $0c, $14, $08, $0a, $0b, $30, $31, $0c, $82, $0a, $06, $07
	db $0c, $14, $08, $1a, $1b, $32, $33, $0c, $a2, $0a, $16, $17, $0c, $14, $08, $0c
	db $82, $00, $00, $01, $02, $03, $0c, $c6, $00, $04, $05, $0c, $82, $02, $0c, $14
	db $08, $0c, $a2, $00, $10, $11, $12, $13, $0c, $e6, $00, $14, $15, $0c, $a2, $02
	db $0c, $b4, $0a, $00, $01, $0c, $00, $04, $2c, $2d, $0c, $ce, $0f, $01, $10, $11
	db $0c, $20, $04, $2e, $2f, $0c, $ee, $0e, $02, $03, $0c, $06, $14, $08, $09, $0c
	db $80, $02, $00, $01, $0c, $14, $08, $12, $13, $0c, $26, $14, $18, $19, $0c, $a0
	db $02, $10, $11, $0c, $14, $08, $0c, $06, $14, $0c, $80, $06, $0c, $52, $0a, $0c
	db $26, $14, $0c, $a0, $06, $0c, $72, $0a, $0c, $06, $18, $0c, $c4, $02, $0c, $12
	db $0f, $01, $0c, $2c, $12, $0c, $e4, $02, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $18, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $F0 packed).
FloorScreen_2B_08::
	db $00, $02, $0c, $28, $29
	db $0c, $00, $0e, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $0e, $0c, $14, $08, $2c
	db $2d, $08, $09, $0c, $42, $0a, $24, $25, $0c, $14, $08, $2e, $2f, $18, $19, $0c
	db $62, $0a, $26, $27, $0c, $14, $08, $0a, $0b, $38, $39, $38, $39, $30, $31, $0c
	db $82, $00, $34, $35, $30, $31, $30, $31, $06, $07, $0c, $14, $08, $1a, $1b, $3a
	db $3b, $3a, $3b, $32, $33, $0c, $a2, $00, $36, $37, $32, $33, $32, $33, $16, $17
	db $0c, $14, $08, $0c, $8e, $00, $00, $01, $04, $05, $34, $35, $0c, $84, $00, $0c
	db $cc, $02, $0c, $14, $08, $0c, $ae, $00, $10, $11, $14, $15, $36, $37, $0c, $a4
	db $00, $0c, $ec, $02, $0c, $b4, $0a, $00, $01, $28, $29, $2c, $2d, $30, $31, $0c
	db $8c, $02, $0c, $d0, $0e, $10, $11, $2a, $2b, $2e, $2f, $32, $33, $0c, $ac, $02
	db $0c, $f0, $0c, $02, $03, $0c, $00, $02, $04, $05, $0c, $cc, $04, $00, $01, $0c
	db $14, $08, $12, $13, $0c, $20, $02, $14, $15, $0c, $ec, $04, $10, $11, $0c, $14
	db $08, $0c, $00, $02, $2c, $2d, $0a, $0b, $0c, $cc, $04, $0c, $52, $0a, $0c, $20
	db $02, $2e, $2f, $1a, $1b, $0c, $ec, $04, $0c, $72, $0a, $0c, $80, $14, $34, $35
	db $34, $35, $00, $01, $02, $03, $0c, $40, $10, $0c, $94, $1f, $01, $36, $37, $36
	db $37, $10, $11, $12, $13, $0c, $60, $10, $0c, $14, $08

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $19, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $10C packed).
FloorScreen_2B_09::
	db $00, $02, $06, $28, $29
	db $06, $00, $0e, $ff, $06, $14, $07, $2a, $2b, $06, $20, $0e, $06, $14, $08, $2c
	db $2d, $08, $09, $06, $42, $06, $24, $25, $06, $10, $0c, $2e, $2f, $18, $19, $06
	db $62, $06, $26, $27, $06, $30, $0c, $0a, $0b, $30, $31, $06, $82, $00, $38, $39
	db $34, $35, $30, $31, $24, $25, $06, $40, $00, $06, $14, $08, $1a, $1b, $32, $33
	db $06, $a2, $00, $3a, $3b, $36, $37, $32, $33, $26, $27, $06, $60, $00, $06, $14
	db $08, $06, $82, $00, $00, $01, $02, $03, $02, $03, $04, $05, $30, $31, $0e, $0f
	db $06, $80, $00, $06, $14, $08, $06, $a2, $00, $10, $11, $12, $13, $12, $13, $14
	db $15, $32, $33, $1e, $1f, $06, $a0, $00, $06, $14, $08, $34, $35, $00, $01, $06
	db $40, $02, $06, $80, $00, $0e, $0f, $06, $82, $00, $06, $14, $08, $36, $37, $10
	db $11, $06, $60, $02, $06, $a0, $00, $1e, $1f, $06, $a2, $00, $06, $14, $08, $02
	db $03, $28, $29, $2c, $2d, $06, $8a, $00, $06, $82, $00, $20, $21, $38, $39, $00
	db $01, $06, $14, $08, $12, $13, $2a, $2b, $2e, $2f, $06, $aa, $00, $06, $a2, $00
	db $22, $23, $3a, $3b, $10, $11, $06, $14, $08, $06, $00, $00, $06, $44, $10, $06
	db $86, $10, $06, $88, $00, $38, $39, $24, $25, $06, $14, $0c, $06, $64, $10, $06
	db $a6, $10, $06, $a8, $00, $3a, $3b, $26, $27, $06, $74, $1c, $28, $29, $06, $ca
	db $00, $06, $00, $10, $06, $c6, $00, $06, $12, $0f, $01, $06, $ea, $00, $06, $20
	db $10, $06, $e6, $00, $06, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $1A, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $EC packed).
FloorScreen_2B_0A::
	db $00, $02, $20, $28, $29, $20, $00, $0e, $ff
	db $20, $14, $07, $2a, $2b, $20, $20, $0e, $20, $14, $08, $2c, $2d, $08, $09, $20
	db $42, $00, $24, $25, $20, $40, $06, $20, $14, $08, $2e, $2f, $18, $19, $20, $62
	db $00, $26, $27, $20, $60, $06, $20, $14, $08, $0a, $0b, $30, $31, $38, $39, $30
	db $31, $20, $48, $00, $20, $82, $02, $06, $07, $20, $14, $08, $1a, $1b, $32, $33
	db $3a, $3b, $32, $33, $20, $68, $00, $20, $a2, $02, $16, $17, $20, $14, $08, $20
	db $82, $00, $0c, $0d, $34, $35, $20, $48, $00, $34, $35, $0c, $0d, $20, $84, $00
	db $20, $14, $08, $20, $a2, $00, $1c, $1d, $36, $37, $20, $68, $00, $36, $37, $1c
	db $1d, $20, $a4, $00, $20, $b4, $0a, $30, $31, $0e, $0f, $20, $90, $00, $20, $80
	db $00, $20, $04, $10, $20, $d2, $0c, $32, $33, $1e, $1f, $20, $b0, $00, $20, $a0
	db $00, $20, $24, $10, $20, $f2, $0a, $02, $03, $02, $03, $20, $8a, $00, $20, $46
	db $12, $24, $25, $20, $40, $10, $20, $14, $08, $12, $13, $12, $13, $20, $aa, $00
	db $20, $66, $12, $26, $27, $20, $60, $10, $20, $14, $08, $20, $00, $00, $20, $44
	db $18, $20, $10, $0f, $01, $20, $64, $18, $20, $30, $0c, $20, $00, $02, $04, $05
	db $20, $00, $10, $00, $01, $20, $0e, $0f, $05, $14, $15, $20, $20, $10, $10, $11
	db $20, $2e, $0e

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $1B, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $E0 packed).
FloorScreen_2B_0B::
	db $00, $02, $20, $28, $29, $20, $00, $0e, $ff, $20, $14, $07, $2a
	db $2b, $20, $20, $0e, $20, $14, $08, $2c, $2d, $08, $09, $20, $42, $0a, $24, $25
	db $20, $14, $08, $2e, $2f, $18, $19, $20, $62, $0a, $26, $27, $20, $14, $08, $0a
	db $0b, $38, $39, $34, $35, $20, $82, $00, $30, $31, $20, $8a, $02, $06, $07, $20
	db $14, $08, $1a, $1b, $3a, $3b, $36, $37, $20, $a2, $00, $32, $33, $20, $aa, $02
	db $16, $17, $20, $14, $08, $20, $8a, $00, $0c, $0d, $38, $39, $20, $8a, $04, $20
	db $8a, $00, $20, $14, $08, $20, $aa, $00, $1c, $1d, $3a, $3b, $20, $aa, $04, $20
	db $aa, $00, $20, $b4, $0c, $0e, $0f, $20, $88, $06, $20, $88, $00, $20, $d4, $0c
	db $1e, $1f, $20, $a8, $06, $20, $a8, $00, $20, $14, $08, $02, $03, $02, $03, $2c
	db $2d, $20, $c8, $06, $34, $35, $00, $01, $20, $14, $08, $12, $13, $12, $13, $2e
	db $2f, $20, $e8, $06, $36, $37, $10, $11, $20, $14, $08, $20, $00, $00, $2c, $2d
	db $20, $86, $06, $38, $39, $20, $52, $0a, $20, $20, $00, $2e, $2f, $20, $a6, $06
	db $3a, $3b, $20, $72, $0a, $20, $00, $02, $04, $05, $34, $35, $20, $50, $10, $20
	db $40, $10, $20, $12, $0f, $01, $14, $15, $36, $37, $20, $70, $10, $20, $60, $10
	db $20, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $26, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $F2 packed).
FloorScreen_2B_0C::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $34, $35, $34
	db $35, $24, $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e
	db $2f, $36, $37, $36, $37, $26, $27, $0c, $20, $02, $0c, $14, $08, $2c, $2d, $08
	db $09, $08, $09, $0a, $0b, $0c, $08, $0f, $05, $2e, $2f, $18, $19, $18, $19, $1a
	db $1b, $0c, $28, $0f, $05, $0c, $46, $02, $0c, $82, $02, $0c, $0c, $00, $0c, $40
	db $00, $0c, $14, $08, $0c, $66, $02, $0c, $a2, $02, $0c, $2c, $00, $0c, $60, $00
	db $0c, $14, $08, $0c, $08, $00, $00, $01, $02, $03, $0c, $c6, $00, $0c, $04, $00
	db $0c, $46, $00, $0c, $14, $08, $0c, $28, $00, $10, $11, $12, $13, $0c, $e6, $00
	db $0c, $24, $00, $0c, $66, $00, $0c, $b4, $0a, $30, $31, $0c, $0c, $04, $0c, $04
	db $00, $38, $39, $30, $31, $0c, $d4, $0a, $32, $33, $0c, $2c, $04, $0c, $24, $00
	db $3a, $3b, $32, $33, $0c, $14, $08, $04, $05, $30, $31, $06, $07, $0c, $42, $00
	db $0c, $42, $02, $38, $39, $00, $01, $0c, $14, $08, $14, $15, $32, $33, $16, $17
	db $0c, $62, $00, $0c, $62, $02, $3a, $3b, $10, $11, $0c, $34, $0a, $30, $31, $0c
	db $82, $1a, $24, $25, $0c, $54, $0a, $32, $33, $0c, $a2, $1a, $26, $27, $0c, $14
	db $08, $28, $29, $0c, $c6, $02, $0c, $c2, $16, $0c, $12, $0c, $0c, $e6, $02, $0c
	db $e2, $16, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $27, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $D6 packed).
FloorScreen_2B_0D::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30
	db $31, $30, $31, $24, $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20
	db $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $2c
	db $2d, $08, $09, $08, $09, $0a, $0b, $34, $35, $34, $35, $06, $07, $0c, $42, $00
	db $24, $25, $0c, $14, $08, $2e, $2f, $18, $19, $18, $19, $1a, $1b, $36, $37, $36
	db $37, $16, $17, $0c, $62, $00, $26, $27, $0c, $14, $08, $0c, $46, $02, $30, $31
	db $0c, $82, $06, $06, $07, $0c, $14, $08, $0c, $66, $02, $32, $33, $0c, $a2, $06
	db $16, $17, $0c, $14, $08, $0c, $84, $00, $30, $31, $00, $01, $02, $03, $02, $03
	db $04, $05, $0c, $08, $00, $34, $35, $0c, $14, $08, $0c, $a4, $00, $32, $33, $10
	db $11, $12, $13, $12, $13, $14, $15, $0c, $28, $00, $36, $37, $0c, $14, $08, $0c
	db $c4, $02, $0c, $00, $02, $28, $29, $0c, $ca, $02, $0c, $14, $08, $0c, $e4, $02
	db $0c, $20, $02, $2a, $2b, $0c, $ea, $02, $0c, $14, $08, $0c, $04, $16, $0c, $06
	db $16, $0c, $14, $08, $0c, $24, $16, $0c, $26, $16, $0c, $14, $08, $0c, $42, $1c
	db $0c, $10, $0f, $03, $0c, $62, $1a, $0c, $74, $1f, $39

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $28, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $101 packed).
FloorScreen_2B_0E::
	db $00, $02, $3c, $28, $29
	db $3c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $3c, $00, $02, $ff, $3c
	db $14, $07, $2a, $2b, $3c, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $3c
	db $20, $02, $3c, $14, $08, $2c, $2d, $08, $09, $08, $09, $0a, $0b, $3c, $08, $0f
	db $05, $2e, $2f, $18, $19, $18, $19, $1a, $1b, $3c, $28, $0f, $05, $3c, $46, $02
	db $38, $39, $3c, $86, $00, $06, $07, $24, $25, $3c, $40, $00, $3c, $14, $08, $3c
	db $66, $02, $3a, $3b, $3c, $a6, $00, $16, $17, $26, $27, $3c, $60, $00, $3c, $14
	db $08, $3c, $08, $00, $0c, $0d, $34, $35, $3c, $08, $00, $30, $31, $0e, $0f, $3c
	db $46, $00, $3c, $14, $08, $3c, $28, $00, $1c, $1d, $36, $37, $3c, $28, $00, $32
	db $33, $1e, $1f, $3c, $66, $00, $3c, $b4, $0a, $00, $01, $28, $29, $02, $03, $02
	db $03, $04, $05, $3c, $cc, $00, $3c, $c6, $00, $3c, $d4, $0a, $10, $11, $2a, $2b
	db $12, $13, $12, $13, $14, $15, $3c, $ec, $00, $3c, $e6, $00, $3c, $14, $08, $02
	db $03, $3c, $00, $02, $3c, $04, $00, $34, $35, $20, $21, $3c, $00, $10, $3c, $14
	db $08, $12, $13, $3c, $20, $02, $3c, $24, $00, $36, $37, $22, $23, $3c, $20, $10
	db $3c, $14, $08, $3c, $42, $14, $3c, $48, $12, $3c, $08, $02, $3c, $14, $0e, $3c
	db $66, $14, $3c, $28, $02, $3c, $74, $1f, $03, $3c, $04, $12, $3c, $40, $10, $3c
	db $94, $1f, $03, $3c, $24, $12, $3c, $60, $10, $3c, $14, $08

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $29, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $CA packed).
FloorScreen_2B_0F::
	db $00, $02, $0c, $28
	db $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $0c, $00, $02, $ff
	db $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27
	db $0c, $20, $02, $0c, $14, $08, $0c, $00, $0f, $2d, $08, $09, $0c, $80, $00, $0a
	db $0b, $0c, $08, $04, $2c, $2d, $08, $09, $0c, $14, $08, $18, $19, $0c, $a0, $00
	db $1a, $1b, $0c, $28, $04, $2e, $2f, $18, $19, $0c, $14, $08, $0c, $08, $00, $0c
	db $c0, $02, $00, $01, $0c, $04, $00, $0c, $86, $00, $0c, $14, $08, $0c, $28, $00
	db $0c, $e0, $02, $10, $11, $0c, $24, $00, $0c, $a6, $00, $0c, $b4, $0f, $03, $0c
	db $8c, $02, $0c, $08, $00, $0c, $d4, $0f, $03, $0c, $ac, $02, $0c, $28, $00, $0c
	db $14, $08, $04, $05, $0c, $c0, $04, $06, $07, $0c, $84, $02, $00, $01, $0c, $14
	db $08, $14, $15, $0c, $e0, $04, $16, $17, $0c, $a4, $02, $10, $11, $0c, $14, $08
	db $0c, $06, $02, $0c, $82, $18, $24, $25, $0c, $14, $08, $0c, $26, $02, $0c, $a2
	db $18, $26, $27, $0c, $34, $0a, $02, $03, $0c, $c2, $1a, $0c, $12, $0c, $12, $13
	db $0c, $e2, $1a, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $2A, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $104 packed).
FloorScreen_2B_10::
	db $00, $02, $0a, $28, $29, $0a, $00, $00, $2c, $2d
	db $30, $31, $30, $31, $24, $25, $0a, $00, $02, $ff, $0a, $14, $07, $2a, $2b, $0a
	db $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0a, $20, $02, $0a, $14, $08
	db $0a, $00, $06, $38, $39, $06, $07, $08, $09, $08, $09, $24, $25, $0a, $14, $0f
	db $03, $3a, $3b, $16, $17, $18, $19, $18, $19, $26, $27, $0a, $14, $08, $0a, $50
	db $00, $0a, $00, $00, $04, $05, $34, $35, $0a, $8a, $00, $0a, $4a, $00, $0a, $14
	db $08, $0a, $70, $00, $0a, $20, $00, $14, $15, $36, $37, $0a, $aa, $00, $0a, $6a
	db $00, $0a, $14, $08, $30, $31, $0a, $4c, $02, $0e, $0f, $0a, $08, $00, $0a, $ca
	db $02, $0a, $14, $08, $32, $33, $0a, $6c, $02, $1e, $1f, $0a, $28, $00, $0a, $ea
	db $02, $0a, $b4, $0a, $0a, $08, $00, $38, $39, $20, $21, $30, $31, $00, $01, $02
	db $03, $04, $05, $0a, $d2, $0c, $0a, $28, $00, $3a, $3b, $22, $23, $32, $33, $10
	db $11, $12, $13, $14, $15, $0a, $f2, $0a, $0a, $88, $02, $38, $39, $0a, $8a, $00
	db $0a, $0c, $02, $02, $03, $0a, $14, $08, $0a, $a8, $02, $3a, $3b, $0a, $aa, $00
	db $0a, $2c, $02, $12, $13, $0a, $14, $08, $0a, $06, $00, $0a, $8a, $02, $00, $01
	db $0a, $00, $02, $0a, $12, $0a, $0a, $26, $00, $0a, $aa, $02, $10, $11, $0a, $20
	db $02, $0a, $32, $0c, $02, $03, $0a, $c2, $12, $0a, $8c, $14, $0a, $12, $0c, $12
	db $13, $0a, $e2, $12, $0a, $ac, $14, $0a, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $2B, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $106 packed).
FloorScreen_2B_11::
	db $00, $02, $3c, $28, $29, $3c
	db $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $3c, $00, $02, $ff, $3c, $14
	db $07, $2a, $2b, $3c, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $3c, $20
	db $02, $3c, $14, $08, $3c, $04, $00, $08, $09, $0a, $0b, $3c, $08, $00, $06, $07
	db $08, $09, $3c, $0c, $00, $3c, $14, $0a, $2e, $2f, $18, $19, $1a, $1b, $3c, $28
	db $00, $16, $17, $18, $19, $3c, $2c, $00, $3c, $14, $08, $08, $09, $0e, $0f, $34
	db $35, $3c, $84, $06, $3c, $4c, $00, $3c, $14, $08, $18, $19, $1e, $1f, $36, $37
	db $3c, $a4, $06, $3c, $6c, $00, $3c, $14, $08, $30, $31, $20, $21, $38, $39, $38
	db $39, $00, $01, $04, $05, $3c, $c4, $00, $34, $35, $30, $31, $3c, $14, $08, $32
	db $33, $22, $23, $3a, $3b, $3a, $3b, $10, $11, $14, $15, $3c, $e4, $00, $36, $37
	db $32, $33, $3c, $b4, $0a, $34, $35, $38, $39, $3c, $4a, $00, $3c, $46, $00, $38
	db $39, $0c, $0d, $3c, $d2, $0c, $36, $37, $3a, $3b, $3c, $6a, $00, $3c, $66, $00
	db $3a, $3b, $1c, $1d, $3c, $f2, $0a, $02, $03, $3c, $ca, $00, $3c, $08, $00, $3c
	db $08, $00, $38, $39, $24, $25, $02, $03, $3c, $14, $08, $12, $13, $3c, $ea, $00
	db $3c, $28, $00, $3c, $28, $00, $3a, $3b, $26, $27, $12, $13, $3c, $34, $0c, $3c
	db $84, $08, $3c, $50, $0f, $01, $3c, $a4, $08, $3c, $70, $0c, $3c, $00, $00, $02
	db $03, $3c, $c4, $16, $3c, $10, $0f, $01, $12, $13, $3c, $e4, $16, $3c, $30, $0c
;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $36, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $E5 packed).
FloorScreen_2B_12::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25
	db $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32, $33
	db $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $0c, $02, $02, $0a, $0b, $0c
	db $08, $00, $06, $07, $08, $09, $08, $09, $24, $25, $0c, $14, $0c, $2e, $2f, $1a
	db $1b, $0c, $28, $00, $16, $17, $18, $19, $18, $19, $26, $27, $0c, $14, $08, $2c
	db $2d, $08, $09, $0c, $46, $02, $0c, $86, $04, $06, $07, $0c, $14, $08, $2e, $2f
	db $18, $19, $0c, $66, $02, $0c, $a6, $04, $16, $17, $0c, $74, $0a, $34, $35, $0c
	db $c2, $00, $00, $01, $02, $03, $02, $03, $04, $05, $0c, $08, $00, $0c, $94, $0a
	db $36, $37, $0c, $e2, $00, $10, $11, $12, $13, $12, $13, $14, $15, $0c, $28, $00
	db $0c, $74, $0a, $38, $39, $38, $39, $0c, $0a, $06, $04, $05, $34, $35, $0c, $94
	db $0a, $3a, $3b, $3a, $3b, $0c, $2a, $06, $14, $15, $36, $37, $0c, $74, $0a, $0c
	db $8c, $04, $0c, $0c, $04, $02, $03, $0c, $94, $0a, $0c, $ac, $04, $0c, $2c, $04
	db $12, $13, $0c, $34, $1f, $01, $38, $39, $0c, $48, $16, $0c, $54, $1f, $01, $3a
	db $3b, $0c, $68, $16, $0c, $34, $0a, $0c, $ca, $06, $0c, $0c, $0f, $03, $0c, $ea
	db $06, $0c, $2c, $0f, $01

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $37, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $FA packed).
FloorScreen_2B_13::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30
	db $31, $30, $31, $24, $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20
	db $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $2c
	db $2d, $08, $09, $08, $09, $0e, $0f, $0c, $08, $00, $06, $07, $0c, $42, $00, $24
	db $25, $0c, $14, $08, $2e, $2f, $18, $19, $18, $19, $1e, $1f, $0c, $28, $00, $16
	db $17, $0c, $62, $00, $26, $27, $0c, $34, $0a, $0c, $08, $02, $04, $05, $34, $35
	db $0c, $8a, $02, $06, $07, $0c, $54, $0a, $0c, $28, $02, $14, $15, $36, $37, $0c
	db $aa, $02, $16, $17, $0c, $74, $0c, $38, $39, $06, $07, $0a, $0b, $38, $39, $30
	db $31, $0c, $8a, $02, $0c, $94, $0c, $3a, $3b, $16, $17, $1a, $1b, $3a, $3b, $32
	db $33, $0c, $aa, $02, $0c, $34, $0a, $0c, $ca, $00, $0c, $04, $12, $38, $39, $00
	db $01, $0c, $88, $00, $0c, $54, $0a, $0c, $ea, $00, $0c, $24, $12, $3a, $3b, $10
	db $11, $0c, $a8, $00, $0c, $34, $0a, $34, $35, $0c, $04, $12, $00, $01, $02, $03
	db $0c, $00, $00, $02, $03, $0c, $54, $0a, $36, $37, $0c, $24, $12, $10, $11, $12
	db $13, $0c, $20, $00, $12, $13, $0c, $74, $0e, $0c, $48, $02, $0c, $0c, $0f, $01
	db $0c, $26, $02, $0c, $68, $02, $0c, $2c, $0f, $01, $0c, $50, $10, $02, $03, $04
	db $05, $0c, $08, $0f, $07, $12, $13, $12, $13, $14, $15, $0c, $28, $0f, $05

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $38, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $A2 packed).
FloorScreen_2B_14::
	db $00
	db $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $0c
	db $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32, $33, $32
	db $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $0c, $00, $0f, $31, $2c, $2d, $0a
	db $0b, $30, $31, $00, $01, $0c, $02, $02, $08, $09, $0c, $14, $0c, $2e, $2f, $1a
	db $1b, $32, $33, $10, $11, $0c, $22, $02, $18, $19, $0c, $74, $0e, $0c, $08, $00
	db $06, $07, $08, $09, $08, $09, $0c, $86, $00, $0c, $94, $0e, $0c, $28, $00, $16
	db $17, $18, $19, $18, $19, $0c, $a6, $00, $0c, $b4, $0f, $03, $0c, $06, $16, $0c
	db $d4, $0f, $03, $0c, $26, $16, $0c, $b4, $0f, $03, $00, $01, $02, $03, $0c, $4c
	db $12, $0c, $d4, $0f, $03, $10, $11, $12, $13, $0c, $6c, $12, $0c, $34, $0e, $04
	db $05, $0c, $c8, $00, $0c, $0c, $0f, $07, $14, $15, $0c, $e8, $00, $0c, $2c, $0f
	db $41

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $39, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $DA packed).
FloorScreen_2B_15::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24
	db $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32
	db $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $0c, $00, $08, $06, $07
	db $08, $09, $08, $09, $24, $25, $0c, $14, $0f, $05, $16, $17, $18, $19, $18, $19
	db $26, $27, $0c, $34, $0e, $28, $29, $04, $05, $30, $31, $34, $35, $34, $35, $0c
	db $4a, $00, $0c, $14, $0e, $2a, $2b, $14, $15, $32, $33, $36, $37, $36, $37, $0c
	db $6a, $00, $0c, $74, $0f, $01, $28, $29, $02, $03, $04, $05, $38, $39, $0c, $8e
	db $00, $0c, $94, $0f, $01, $2a, $2b, $12, $13, $14, $15, $3a, $3b, $0c, $ae, $00
	db $0c, $b4, $0f, $03, $0c, $04, $00, $0c, $ce, $0f, $09, $0c, $24, $00, $0c, $ee
	db $0f, $07, $2c, $2d, $08, $09, $0a, $0b, $0c, $8a, $00, $00, $01, $0c, $94, $0f
	db $01, $2e, $2f, $18, $19, $1a, $1b, $0c, $aa, $00, $10, $11, $0c, $34, $0f, $01
	db $0a, $0b, $0c, $8e, $00, $0c, $08, $02, $0c, $14, $0f, $01, $1a, $1b, $0c, $ae
	db $00, $0c, $28, $02, $0c, $34, $0f, $05, $00, $01, $02, $03, $02, $03, $0c, $12
	db $0f, $07, $10, $11, $12, $13, $12, $13, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $3A, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $EA packed).
FloorScreen_2B_16::
	db $00, $02, $0c, $28, $29
	db $0c, $00, $00, $2c, $2d, $34, $35, $34, $35, $24, $25, $0c, $00, $02, $ff, $0c
	db $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $36, $37, $36, $37, $26, $27, $0c
	db $20, $02, $0c, $14, $08, $2c, $2d, $08, $09, $08, $09, $0a, $0b, $0c, $08, $0f
	db $05, $2e, $2f, $18, $19, $18, $19, $1a, $1b, $0c, $28, $0f, $07, $30, $31, $0c
	db $82, $00, $34, $35, $00, $01, $0c, $40, $02, $08, $09, $0c, $54, $0a, $32, $33
	db $0c, $a2, $00, $36, $37, $10, $11, $0c, $60, $02, $18, $19, $0c, $74, $0c, $00
	db $01, $02, $03, $02, $03, $0c, $04, $04, $34, $35, $0c, $94, $0c, $10, $11, $12
	db $13, $12, $13, $0c, $24, $04, $36, $37, $0c, $74, $0c, $06, $07, $0c, $8e, $02
	db $0c, $46, $02, $0c, $d2, $0e, $16, $17, $0c, $ae, $02, $0c, $66, $02, $0c, $f2
	db $0e, $30, $31, $38, $39, $0c, $82, $02, $0c, $82, $00, $00, $01, $0c, $94, $0e
	db $3a, $3b, $0c, $a2, $02, $0c, $a2, $00, $10, $11, $0c, $74, $0c, $38, $39, $0c
	db $84, $10, $0c, $82, $04, $24, $25, $0c, $94, $0c, $3a, $3b, $0c, $a4, $10, $0c
	db $a2, $04, $26, $27, $0c, $14, $08, $28, $29, $0c, $c6, $00, $04, $05, $0c, $08
	db $00, $0c, $c4, $04, $0c, $14, $0a, $0c, $e6, $00, $14, $15, $0c, $28, $00, $0c
	db $e4, $04, $0c, $14, $08

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $3B, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $F9 packed).
FloorScreen_2B_17::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30
	db $31, $30, $31, $24, $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20
	db $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $0c
	db $04, $00, $08, $09, $0a, $0b, $0c, $08, $00, $06, $07, $08, $09, $08, $09, $24
	db $25, $0c, $14, $0a, $2e, $2f, $18, $19, $1a, $1b, $0c, $28, $00, $16, $17, $18
	db $19, $18, $19, $26, $27, $0c, $14, $08, $2c, $2d, $0c, $46, $02, $0c, $84, $06
	db $06, $07, $0c, $14, $08, $2e, $2f, $0c, $66, $02, $0c, $a4, $06, $16, $17, $0c
	db $74, $0a, $38, $39, $38, $39, $0c, $08, $00, $00, $01, $02, $03, $04, $05, $0c
	db $08, $00, $0c, $94, $0a, $3a, $3b, $3a, $3b, $0c, $28, $00, $10, $11, $12, $13
	db $14, $15, $0c, $28, $00, $0c, $74, $0a, $34, $35, $00, $01, $0c, $ce, $00, $0c
	db $4c, $00, $0c, $46, $02, $0c, $94, $0a, $36, $37, $10, $11, $0c, $ee, $00, $0c
	db $6c, $00, $0c, $66, $02, $0c, $f4, $0c, $06, $07, $0c, $82, $08, $00, $01, $0c
	db $14, $1c, $16, $17, $0c, $a2, $08, $10, $11, $0c, $f4, $0c, $0c, $c2, $00, $0c
	db $c4, $02, $0c, $08, $02, $0c, $14, $1c, $0c, $e2, $00, $0c, $e4, $02, $0c, $28
	db $02, $0c, $34, $0a, $02, $03, $0c, $cc, $04, $0c, $ca, $00, $02, $03, $0c, $12
	db $0c, $12, $13, $0c, $ec, $04, $0c, $ea, $00, $12, $13, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $46, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $102 packed).
FloorScreen_2B_18::
	db $00, $02
	db $0c, $28, $29, $0c, $00, $00, $2c, $2d, $34, $35, $34, $35, $24, $25, $0c, $00
	db $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $36, $37, $36, $37
	db $26, $27, $0c, $20, $02, $0c, $14, $08, $2c, $2d, $08, $09, $08, $09, $0a, $0b
	db $30, $31, $34, $35, $06, $07, $08, $09, $0c, $0c, $00, $0c, $14, $08, $2e, $2f
	db $18, $19, $18, $19, $1a, $1b, $32, $33, $36, $37, $16, $17, $18, $19, $0c, $2c
	db $00, $0c, $14, $08, $0a, $0b, $34, $35, $30, $31, $0c, $84, $00, $0c, $08, $00
	db $0c, $4a, $00, $24, $25, $0c, $14, $08, $1a, $1b, $36, $37, $32, $33, $0c, $a4
	db $00, $0c, $28, $00, $0c, $6a, $00, $26, $27, $0c, $14, $08, $0c, $08, $00, $0c
	db $84, $00, $00, $01, $02, $03, $04, $05, $0c, $08, $02, $0c, $14, $08, $0c, $28
	db $00, $0c, $a4, $00, $10, $11, $12, $13, $14, $15, $0c, $28, $02, $0c, $b4, $0a
	db $0c, $c8, $00, $02, $03, $0c, $40, $00, $0c, $46, $02, $0c, $d2, $0c, $0c, $e8
	db $00, $12, $13, $0c, $60, $00, $0c, $66, $02, $0c, $b2, $0a, $02, $03, $0c, $00
	db $04, $38, $39, $38, $39, $0c, $0e, $1e, $12, $13, $0c, $20, $04, $3a, $3b, $3a
	db $3b, $0c, $2e, $1e, $0c, $00, $04, $0c, $46, $00, $0c, $88, $02, $0c, $92, $0a
	db $0c, $20, $04, $0c, $66, $00, $0c, $a8, $02, $0c, $72, $1f, $03, $0c, $82, $00
	db $0c, $02, $12, $0c, $12, $0f, $05, $0c, $e6, $02, $0c, $60, $10, $0c, $14, $08
;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $47, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $D5 packed).
FloorScreen_2B_19::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25
	db $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32, $33
	db $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $0c, $04, $00, $08, $09, $0a
	db $0b, $30, $31, $38, $39, $0c, $0c, $0f, $03, $2e, $2f, $18, $19, $1a, $1b, $32
	db $33, $3a, $3b, $0c, $2c, $0f, $01, $0c, $44, $00, $34, $35, $0c, $48, $00, $00
	db $01, $0c, $00, $02, $0c, $12, $0a, $0c, $64, $00, $36, $37, $0c, $68, $00, $10
	db $11, $0c, $20, $02, $0c, $32, $0a, $34, $35, $0c, $84, $00, $30, $31, $0c, $8a
	db $06, $0c, $12, $0a, $36, $37, $0c, $a4, $00, $32, $33, $0c, $aa, $06, $0c, $32
	db $0a, $0c, $08, $00, $0c, $08, $00, $06, $07, $0c, $0c, $04, $0c, $12, $0a, $0c
	db $28, $00, $0c, $28, $00, $16, $17, $0c, $2c, $04, $0c, $32, $0a, $02, $03, $04
	db $05, $0c, $48, $00, $38, $39, $0c, $08, $16, $0c, $14, $08, $12, $13, $14, $15
	db $0c, $68, $00, $3a, $3b, $0c, $28, $16, $0c, $34, $0a, $28, $29, $0c, $40, $10
	db $0c, $46, $10, $0c, $0c, $0f, $05, $0c, $60, $10, $0c, $66, $10, $0c, $6c, $1f
	db $05, $0c, $04, $0f, $29

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $48, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $EC packed).
FloorScreen_2B_1A::
	db $00, $02, $0a, $28, $29, $0a, $00, $00, $2c, $2d, $30
	db $31, $30, $31, $24, $25, $0a, $00, $02, $ff, $0a, $14, $07, $2a, $2b, $0a, $20
	db $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0a, $20, $02, $0a, $14, $08, $0a
	db $00, $08, $06, $07, $08, $09, $08, $09, $24, $25, $0a, $14, $0f, $05, $16, $17
	db $18, $19, $18, $19, $26, $27, $0a, $14, $08, $0a, $4e, $00, $0a, $50, $00, $04
	db $05, $0a, $08, $00, $0a, $08, $02, $0a, $14, $08, $0a, $6e, $00, $0a, $70, $00
	db $14, $15, $0a, $28, $00, $0a, $28, $02, $0a, $14, $08, $0a, $8a, $02, $06, $07
	db $24, $25, $02, $03, $02, $03, $0a, $88, $00, $0a, $52, $0a, $0a, $aa, $02, $16
	db $17, $26, $27, $12, $13, $12, $13, $0a, $a8, $00, $0a, $72, $0a, $34, $35, $0a
	db $00, $12, $0a, $4c, $02, $0e, $0f, $0a, $90, $0c, $36, $37, $0a, $20, $12, $0a
	db $6c, $02, $1e, $1f, $0a, $b0, $0c, $0a, $88, $04, $38, $39, $38, $39, $30, $31
	db $20, $21, $0a, $90, $0c, $0a, $a8, $04, $3a, $3b, $3a, $3b, $32, $33, $22, $23
	db $0a, $b0, $0c, $0a, $06, $02, $0a, $46, $14, $0a, $8e, $0e, $0a, $26, $02, $0a
	db $66, $14, $0a, $ae, $0e, $28, $29, $0a, $ca, $04, $30, $31, $00, $01, $0a, $ca
	db $00, $0a, $12, $0c, $0a, $ea, $04, $32, $33, $10, $11, $0a, $ea, $00, $0a, $32
	db $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $49, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $F6 packed).
FloorScreen_2B_1B::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24
	db $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32
	db $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $2c, $2d, $08, $09, $08
	db $09, $0a, $0b, $0c, $08, $0f, $05, $2e, $2f, $18, $19, $18, $19, $1a, $1b, $0c
	db $28, $0f, $05, $0a, $0b, $34, $35, $0c, $82, $02, $00, $01, $0c, $40, $02, $24
	db $25, $0c, $14, $08, $1a, $1b, $36, $37, $0c, $a2, $02, $10, $11, $0c, $60, $02
	db $26, $27, $0c, $14, $08, $30, $31, $0c, $86, $02, $02, $03, $0c, $04, $00, $34
	db $35, $0c, $0a, $00, $0c, $14, $08, $32, $33, $0c, $a6, $02, $12, $13, $0c, $24
	db $00, $36, $37, $0c, $2a, $00, $0c, $b4, $0a, $0c, $08, $00, $06, $07, $08, $09
	db $0e, $0f, $0c, $80, $00, $0c, $d0, $0e, $0c, $28, $00, $16, $17, $18, $19, $1e
	db $1f, $0c, $a0, $00, $0c, $f0, $0c, $04, $05, $0c, $00, $12, $38, $39, $20, $21
	db $0c, $ce, $00, $00, $01, $0c, $12, $0a, $14, $15, $0c, $20, $12, $3a, $3b, $22
	db $23, $0c, $ee, $00, $10, $11, $0c, $32, $0a, $28, $29, $02, $03, $0c, $40, $14
	db $0c, $88, $00, $0c, $10, $0e, $12, $13, $0c, $60, $14, $0c, $a8, $00, $0c, $30
	db $0c, $0c, $00, $02, $0c, $40, $12, $0c, $8e, $12, $0c, $12, $0f, $01, $0c, $60
	db $12, $0c, $ae, $12, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $4A, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $FD packed).
FloorScreen_2B_1C::
	db $00, $02, $0e, $28, $29, $0e, $00, $00, $2c
	db $2d, $30, $31, $30, $31, $24, $25, $0e, $00, $02, $ff, $0e, $14, $07, $2a, $2b
	db $0e, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0e, $20, $02, $0e, $14
	db $08, $2c, $2d, $08, $09, $08, $09, $0a, $0b, $0e, $08, $00, $06, $07, $0e, $42
	db $00, $24, $25, $0e, $14, $08, $2e, $2f, $18, $19, $18, $19, $1a, $1b, $0e, $28
	db $00, $16, $17, $0e, $62, $00, $26, $27, $0e, $14, $08, $0a, $0b, $34, $35, $0e
	db $82, $00, $0e, $08, $00, $38, $39, $0e, $8c, $00, $0e, $52, $0a, $1a, $1b, $36
	db $37, $0e, $a2, $00, $0e, $28, $00, $3a, $3b, $0e, $ac, $00, $0e, $72, $0a, $0e
	db $08, $00, $00, $01, $04, $05, $0e, $86, $00, $0e, $c4, $00, $0e, $90, $0c, $0e
	db $28, $00, $10, $11, $14, $15, $0e, $a6, $00, $0e, $e4, $00, $0e, $b0, $0f, $01
	db $06, $07, $0e, $80, $00, $0e, $02, $12, $0e, $d0, $0f, $01, $16, $17, $0e, $a0
	db $00, $0e, $22, $12, $0e, $b0, $0c, $0e, $c6, $02, $0e, $86, $0f, $07, $0e, $e6
	db $02, $0e, $a6, $0f, $07, $0e, $06, $00, $0c, $0d, $0e, $44, $12, $38, $39, $0e
	db $84, $10, $0e, $52, $0c, $32, $33, $1c, $1d, $0e, $64, $12, $3a, $3b, $0e, $a4
	db $10, $0e, $72, $0a, $28, $29, $02, $03, $28, $29, $04, $05, $0e, $c0, $02, $0e
	db $c0, $12, $0e, $14, $0a, $12, $13, $2a, $2b, $14, $15, $0e, $e0, $02, $0e, $e0
	db $12, $0e, $14, $08

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $4B, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $AB packed).
FloorScreen_2B_1D::
	db $00, $02, $00, $28, $29, $00, $00, $00, $2c, $2d, $30, $31
	db $30, $31, $24, $25, $00, $00, $02, $ff, $00, $14, $07, $2a, $2b, $00, $20, $00
	db $2e, $2f, $32, $33, $32, $33, $26, $27, $00, $20, $02, $00, $14, $08, $00, $00
	db $0f, $2d, $08, $09, $00, $0c, $00, $2c, $2d, $38, $39, $00, $0a, $0f, $03, $18
	db $19, $00, $2c, $00, $2e, $2f, $3a, $3b, $00, $2a, $0f, $03, $30, $31, $06, $07
	db $08, $09, $0e, $0f, $30, $31, $34, $35, $00, $0c, $0f, $01, $32, $33, $16, $17
	db $18, $19, $1e, $1f, $32, $33, $36, $37, $00, $ac, $0f, $03, $00, $88, $00, $20
	db $21, $34, $35, $00, $0a, $0f, $03, $32, $33, $00, $a8, $00, $22, $23, $36, $37
	db $00, $2a, $0f, $03, $02, $03, $04, $05, $00, $08, $00, $00, $c8, $0f, $05, $12
	db $13, $14, $15, $00, $28, $00, $00, $e8, $0f, $05, $00, $00, $00, $00, $40, $12
	db $38, $39, $00, $0c, $0f, $05, $00, $60, $12, $3a, $3b, $00, $2c, $0f, $41

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $56, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $D4 packed).
FloorScreen_2B_1E::
	db $00
	db $02, $0c, $28, $29, $0c, $00, $0e, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $0e
	db $0c, $14, $08, $0c, $00, $08, $2c, $2d, $08, $09, $08, $09, $24, $25, $0c, $14
	db $0f, $05, $2e, $2f, $18, $19, $18, $19, $26, $27, $0c, $14, $08, $0c, $50, $00
	db $0c, $44, $06, $34, $35, $34, $35, $06, $07, $0c, $14, $08, $0c, $70, $00, $0c
	db $64, $06, $36, $37, $36, $37, $16, $17, $0c, $14, $08, $30, $31, $06, $07, $0c
	db $50, $00, $0c, $4c, $00, $0a, $0b, $34, $35, $30, $31, $30, $31, $0c, $14, $08
	db $32, $33, $16, $17, $0c, $70, $00, $0c, $6c, $00, $1a, $1b, $36, $37, $32, $33
	db $32, $33, $0c, $b4, $0a, $30, $31, $0c, $90, $00, $0c, $cc, $04, $0c, $d0, $0e
	db $32, $33, $0c, $b0, $00, $0c, $ec, $04, $0c, $f0, $0c, $04, $05, $0c, $0c, $14
	db $0c, $d0, $00, $00, $01, $02, $03, $02, $03, $0c, $14, $08, $14, $15, $0c, $2c
	db $14, $0c, $f0, $00, $10, $11, $12, $13, $12, $13, $0c, $34, $0a, $02, $03, $0c
	db $40, $12, $0c, $4e, $10, $0c, $0e, $0f, $01, $12, $13, $0c, $60, $12, $0c, $6e
	db $10, $0c, $2e, $0f, $05, $0c, $50, $10, $0c, $0a, $0f, $09, $0c, $70, $10, $0c
	db $2a, $0f, $03

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $57, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $EA packed).
FloorScreen_2B_1F::
	db $00, $02, $3c, $28, $29, $3c, $00, $0e, $ff, $3c, $14, $07, $2a
	db $2b, $3c, $20, $0e, $3c, $14, $08, $3c, $00, $0f, $2d, $08, $09, $24, $25, $2c
	db $2d, $08, $09, $3c, $86, $00, $24, $25, $28, $29, $3c, $84, $00, $3c, $14, $08
	db $18, $19, $26, $27, $2e, $2f, $18, $19, $3c, $a6, $00, $26, $27, $2a, $2b, $3c
	db $a4, $00, $3c, $14, $08, $30, $31, $06, $07, $0e, $0f, $34, $35, $38, $39, $34
	db $35, $06, $07, $08, $09, $0a, $0b, $30, $31, $3c, $14, $08, $32, $33, $16, $17
	db $1e, $1f, $36, $37, $3a, $3b, $36, $37, $16, $17, $18, $19, $1a, $1b, $32, $33
	db $3c, $b4, $0a, $30, $31, $0e, $0f, $30, $31, $0c, $0d, $38, $39, $30, $31, $3c
	db $0a, $10, $3c, $d2, $0c, $32, $33, $1e, $1f, $32, $33, $1c, $1d, $3a, $3b, $32
	db $33, $3c, $2a, $10, $3c, $f2, $0a, $04, $05, $34, $35, $20, $21, $3c, $02, $10
	db $3c, $c8, $00, $30, $31, $34, $35, $00, $01, $3c, $14, $08, $14, $15, $36, $37
	db $22, $23, $3c, $22, $10, $3c, $e8, $00, $32, $33, $36, $37, $10, $11, $3c, $14
	db $08, $2c, $2d, $3c, $0a, $12, $24, $25, $02, $03, $3c, $8a, $12, $3c, $12, $0a
	db $2e, $2f, $3c, $2a, $12, $26, $27, $12, $13, $3c, $aa, $12, $3c, $32, $0c, $3c
	db $8c, $14, $3c, $0a, $0f, $05, $3c, $ac, $14, $3c, $2a, $0f, $03

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $58, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $D9 packed).
FloorScreen_2B_20::
	db $00, $02, $0c
	db $28, $29, $0c, $00, $0e, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $0e, $0c, $14
	db $08, $0c, $00, $0f, $2d, $08, $09, $0c, $80, $06, $24, $25, $28, $29, $2c, $2d
	db $08, $09, $0c, $14, $08, $18, $19, $0c, $a0, $06, $26, $27, $2a, $2b, $2e, $2f
	db $18, $19, $0c, $14, $08, $30, $31, $0c, $c0, $00, $34, $35, $38, $39, $34, $35
	db $06, $07, $08, $09, $0a, $0b, $30, $31, $0c, $14, $08, $32, $33, $0c, $e0, $00
	db $36, $37, $3a, $3b, $36, $37, $16, $17, $18, $19, $1a, $1b, $32, $33, $0c, $b4
	db $0a, $00, $01, $04, $05, $0c, $c0, $02, $0c, $c8, $00, $0c, $c0, $00, $0c, $d4
	db $0a, $10, $11, $14, $15, $0c, $e0, $02, $0c, $e8, $00, $0c, $e0, $00, $0c, $14
	db $08, $02, $03, $0c, $8e, $00, $0c, $c2, $02, $0c, $c0, $00, $00, $01, $02, $03
	db $0c, $14, $08, $12, $13, $0c, $ae, $00, $0c, $e2, $02, $0c, $e0, $00, $10, $11
	db $12, $13, $0c, $34, $0c, $2c, $2d, $34, $35, $0c, $0e, $10, $0c, $86, $10, $0c
	db $8c, $00, $0c, $14, $0c, $2e, $2f, $36, $37, $0c, $2e, $10, $0c, $a6, $10, $0c
	db $ac, $00, $0c, $34, $0e, $02, $03, $0c, $c6, $14, $0c, $10, $0f, $03, $12, $13
	db $0c, $e6, $14, $0c, $30, $0c

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $59, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $F3 packed).
FloorScreen_2B_21::
	db $00, $02, $0c, $28, $29, $0c, $00, $0e, $ff, $0c
	db $14, $07, $2a, $2b, $0c, $20, $0e, $0c, $14, $08, $2c, $2d, $08, $09, $0c, $42
	db $0a, $24, $25, $0c, $14, $08, $2e, $2f, $18, $19, $0c, $62, $0a, $26, $27, $0c
	db $14, $08, $0a, $0b, $30, $31, $34, $35, $34, $35, $30, $31, $0c, $82, $00, $0c
	db $88, $00, $06, $07, $0c, $14, $08, $1a, $1b, $32, $33, $36, $37, $36, $37, $32
	db $33, $0c, $a2, $00, $0c, $a8, $00, $16, $17, $0c, $14, $08, $30, $31, $38, $39
	db $00, $01, $02, $03, $04, $05, $30, $31, $00, $01, $04, $05, $0c, $86, $00, $0c
	db $14, $08, $32, $33, $3a, $3b, $10, $11, $12, $13, $14, $15, $32, $33, $10, $11
	db $14, $15, $0c, $a6, $00, $0c, $b4, $0a, $00, $01, $0c, $40, $00, $0c, $80, $00
	db $06, $07, $24, $25, $0c, $c8, $00, $0c, $d4, $0a, $10, $11, $0c, $60, $00, $0c
	db $a0, $00, $16, $17, $26, $27, $0c, $e8, $00, $0c, $14, $08, $02, $03, $28, $29
	db $2c, $2d, $0c, $88, $00, $0c, $88, $00, $24, $25, $28, $29, $02, $03, $0c, $14
	db $08, $12, $13, $2a, $2b, $2e, $2f, $0c, $a8, $00, $0c, $a8, $00, $26, $27, $2a
	db $2b, $12, $13, $0c, $14, $08, $0c, $00, $00, $0c, $44, $1a, $0c, $12, $0e, $0c
	db $64, $1a, $0c, $32, $0a, $0c, $00, $02, $02, $03, $0c, $c6, $12, $0c, $0e, $0f
	db $05, $12, $13, $0c, $e6, $12, $0c, $2e, $0e

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $5A, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $E7 packed).
FloorScreen_2B_22::
	db $00, $02, $0c, $28, $29, $0c, $00
	db $0e, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $0e, $0c, $14, $08, $2c, $2d, $08
	db $09, $0c, $42, $06, $24, $25, $0c, $10, $0c, $2e, $2f, $18, $19, $0c, $62, $06
	db $26, $27, $0c, $30, $0c, $0a, $0b, $34, $35, $0c, $82, $00, $30, $31, $0c, $88
	db $00, $0e, $0f, $0c, $42, $00, $0c, $14, $08, $1a, $1b, $36, $37, $0c, $a2, $00
	db $32, $33, $0c, $a8, $00, $1e, $1f, $0c, $62, $00, $0c, $14, $08, $0c, $88, $00
	db $00, $01, $02, $03, $04, $05, $0c, $8a, $02, $0c, $88, $00, $0c, $14, $08, $0c
	db $a8, $00, $10, $11, $12, $13, $14, $15, $0c, $aa, $02, $0c, $a8, $00, $0c, $b4
	db $0c, $06, $07, $0c, $4e, $00, $04, $05, $34, $35, $0c, $ce, $0f, $03, $16, $17
	db $0c, $6e, $00, $14, $15, $36, $37, $0c, $ee, $0e, $0c, $c8, $02, $06, $07, $08
	db $09, $0a, $0b, $30, $31, $20, $21, $34, $35, $00, $01, $0c, $14, $08, $0c, $e8
	db $02, $16, $17, $18, $19, $1a, $1b, $32, $33, $22, $23, $36, $37, $10, $11, $0c
	db $34, $0a, $0c, $88, $00, $0c, $84, $02, $0c, $88, $12, $24, $25, $0c, $54, $0a
	db $0c, $a8, $00, $0c, $a4, $02, $0c, $a8, $12, $26, $27, $0c, $14, $08, $28, $29
	db $02, $03, $0c, $c2, $1a, $0c, $12, $0c, $12, $13, $0c, $e2, $1a, $0c, $32, $0a
;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $5B, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $E8 packed).
FloorScreen_2B_23::
	db $00, $02, $0e, $28, $29, $0e, $00, $0e, $ff, $0e, $14, $07, $2a, $2b, $0e, $20
	db $0e, $0e, $14, $08, $0e, $00, $08, $2c, $2d, $08, $09, $08, $09, $24, $25, $0e
	db $14, $0f, $05, $2e, $2f, $18, $19, $18, $19, $26, $27, $0e, $14, $08, $0e, $50
	db $00, $0e, $44, $06, $30, $31, $30, $31, $06, $07, $0e, $14, $08, $0e, $70, $00
	db $0e, $64, $06, $32, $33, $32, $33, $16, $17, $0e, $14, $08, $0e, $90, $00, $0e
	db $4e, $00, $0e, $4e, $00, $0a, $0b, $0e, $8e, $00, $30, $31, $0e, $14, $08, $0e
	db $b0, $00, $0e, $6e, $00, $0e, $6e, $00, $1a, $1b, $0e, $ae, $00, $32, $33, $0e
	db $b4, $0a, $30, $31, $34, $35, $0e, $04, $10, $0e, $00, $12, $0c, $0d, $0e, $d2
	db $0c, $32, $33, $36, $37, $0e, $24, $10, $0e, $20, $12, $1c, $1d, $0e, $f2, $0a
	db $04, $05, $0e, $02, $10, $0e, $8e, $00, $00, $01, $02, $03, $02, $03, $28, $29
	db $02, $03, $0e, $14, $08, $14, $15, $0e, $22, $10, $0e, $ae, $00, $10, $11, $12
	db $13, $12, $13, $2a, $2b, $12, $13, $0e, $14, $08, $0e, $8c, $02, $30, $31, $38
	db $39, $0e, $82, $06, $0e, $14, $08, $0e, $ac, $02, $32, $33, $3a, $3b, $0e, $a2
	db $06, $0e, $34, $0a, $0e, $4c, $10, $0e, $4c, $12, $0e, $0c, $0f, $03, $0e, $6c
	db $10, $0e, $6c, $12, $0e, $2c, $0f, $01

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $66, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $8F packed).
FloorScreen_2B_24::
	db $00, $02, $04, $28, $29, $04, $00, $0e
	db $ff, $04, $14, $07, $2a, $2b, $04, $20, $0e, $04, $14, $08, $04, $00, $0f, $3d
	db $2c, $2d, $08, $09, $04, $14, $0f, $09, $2e, $2f, $18, $19, $04, $34, $0f, $07
	db $2c, $2d, $0a, $0b, $30, $31, $04, $14, $0f, $07, $2e, $2f, $1a, $1b, $32, $33
	db $04, $34, $0f, $05, $04, $ce, $02, $04, $d2, $0f, $07, $04, $ee, $02, $04, $f2
	db $0f, $03, $04, $90, $00, $04, $0e, $12, $00, $01, $04, $14, $0f, $01, $04, $b0
	db $00, $04, $2e, $12, $10, $11, $04, $34, $0e, $04, $0c, $14, $04, $10, $10, $24
	db $25, $04, $14, $0e, $04, $2c, $14, $04, $30, $10, $26, $27, $04, $74, $1f, $01
	db $04, $4e, $12, $02, $03, $02, $03, $04, $12, $0f, $01, $2e, $2f, $04, $6e, $12
	db $12, $13, $12, $13, $04, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $67, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $BE packed).
FloorScreen_2B_25::
	db $00, $02, $0c, $28, $29, $0c, $00, $0e, $ff
	db $0c, $14, $07, $2a, $2b, $0c, $20, $0e, $0c, $14, $08, $0c, $00, $04, $2c, $2d
	db $08, $09, $0c, $4a, $02, $24, $25, $0c, $14, $0f, $01, $2e, $2f, $18, $19, $0c
	db $6a, $02, $26, $27, $0c, $34, $0f, $03, $34, $35, $0c, $8a, $02, $06, $07, $0c
	db $54, $0f, $03, $36, $37, $0c, $aa, $02, $16, $17, $0c, $34, $0c, $0c, $48, $00
	db $0a, $0b, $38, $39, $38, $39, $30, $31, $0c, $8a, $00, $0c, $14, $0c, $0c, $68
	db $00, $1a, $1b, $3a, $3b, $3a, $3b, $32, $33, $0c, $aa, $00, $0c, $b4, $0e, $0c
	db $cc, $00, $0c, $cc, $00, $0c, $0c, $12, $0c, $d4, $0e, $0c, $ec, $00, $0c, $ec
	db $00, $0c, $2c, $12, $0c, $f4, $0f, $01, $0c, $0a, $16, $00, $01, $0c, $14, $1f
	db $01, $0c, $2a, $16, $10, $11, $0c, $b4, $0e, $0c, $8a, $00, $0c, $4e, $12, $02
	db $03, $0c, $12, $0e, $0c, $a8, $02, $0c, $6e, $12, $12, $13, $0c, $32, $0f, $01
	db $04, $05, $0c, $88, $10, $00, $01, $0c, $0e, $0f, $05, $14, $15, $0c, $a8, $10
	db $10, $11, $0c, $2e, $0e

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $68, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $EA packed).
FloorScreen_2B_26::
	db $00, $02, $0c, $28, $29, $0c, $00, $0e, $ff, $0c, $14
	db $07, $2a, $2b, $0c, $20, $0e, $0c, $14, $08, $2c, $2d, $08, $09, $0c, $42, $00
	db $24, $25, $0c, $0a, $0f, $03, $2e, $2f, $18, $19, $0c, $62, $00, $26, $27, $0c
	db $2a, $0f, $05, $34, $35, $34, $35, $30, $31, $0c, $48, $04, $0c, $40, $00, $0c
	db $54, $0a, $36, $37, $36, $37, $32, $33, $0c, $68, $04, $0c, $60, $00, $0c, $34
	db $0a, $38, $39, $38, $39, $34, $35, $0c, $48, $02, $2c, $2d, $0a, $0b, $30, $31
	db $0c, $54, $0a, $3a, $3b, $3a, $3b, $36, $37, $0c, $68, $02, $2e, $2f, $1a, $1b
	db $32, $33, $0c, $74, $0c, $0c, $c2, $00, $0c, $48, $00, $0c, $ce, $02, $0c, $d2
	db $0c, $36, $37, $0c, $e2, $00, $0c, $68, $00, $0c, $ee, $02, $0c, $f2, $0c, $0c
	db $c4, $00, $34, $35, $06, $07, $08, $09, $0c, $0e, $12, $00, $01, $0c, $d4, $0c
	db $0c, $a2, $00, $16, $17, $18, $19, $0c, $2e, $12, $10, $11, $0c, $b4, $0c, $0c
	db $10, $10, $30, $31, $0c, $84, $00, $0c, $10, $10, $24, $25, $0c, $d4, $0c, $0c
	db $30, $10, $32, $33, $0c, $a4, $00, $0c, $30, $10, $26, $27, $0c, $14, $08, $28
	db $29, $02, $03, $02, $03, $04, $05, $0c, $4e, $12, $0c, $c2, $10, $0c, $12, $0c
	db $12, $13, $12, $13, $14, $15, $0c, $6e, $12, $0c, $e2, $10, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $69, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $CA packed).
FloorScreen_2B_27::
	db $00
	db $02, $0a, $28, $29, $0a, $00, $0e, $ff, $0a, $14, $07, $2a, $2b, $0a, $20, $0e
	db $0a, $14, $08, $2c, $2d, $08, $09, $0a, $42, $0a, $24, $25, $0a, $14, $08, $2e
	db $2f, $18, $19, $0a, $62, $0a, $26, $27, $0a, $34, $0a, $38, $39, $38, $39, $34
	db $35, $0a, $86, $06, $06, $07, $0a, $54, $0a, $3a, $3b, $3a, $3b, $36, $37, $0a
	db $a6, $06, $16, $17, $0a, $74, $0c, $30, $31, $0a, $c4, $02, $00, $01, $04, $05
	db $34, $35, $30, $31, $0a, $94, $0c, $32, $33, $0a, $e4, $02, $10, $11, $14, $15
	db $36, $37, $32, $33, $0a, $74, $0e, $0a, $c4, $00, $34, $35, $24, $25, $28, $29
	db $04, $05, $0a, $d2, $0e, $0a, $e2, $02, $36, $37, $26, $27, $2a, $2b, $14, $15
	db $0a, $f2, $0f, $05, $00, $01, $0a, $00, $02, $02, $03, $0a, $14, $1f, $03, $10
	db $11, $0a, $20, $02, $12, $13, $0a, $f4, $0f, $03, $06, $07, $0a, $0c, $10, $0a
	db $10, $0c, $0a, $20, $16, $16, $17, $0a, $2c, $10, $0a, $30, $0c, $0a, $50, $10
	db $02, $03, $0a, $10, $10, $30, $31, $0a, $8c, $1f, $01, $0a, $70, $10, $12, $13
	db $0a, $30, $10, $32, $33, $0a, $ac, $1f, $01

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $6A, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $A9 packed).
FloorScreen_2B_28::
	db $00, $02, $0c, $28, $29, $0c, $00
	db $0e, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $0e, $0c, $14, $08, $0c, $00, $04
	db $2c, $2d, $08, $09, $0c, $4a, $02, $24, $25, $0c, $14, $0f, $01, $2e, $2f, $18
	db $19, $0c, $6a, $02, $26, $27, $0c, $34, $0f, $03, $30, $31, $0c, $8a, $02, $06
	db $07, $0c, $54, $0f, $03, $32, $33, $0c, $aa, $02, $16, $17, $0c, $74, $0f, $0b
	db $30, $31, $0c, $94, $0f, $0b, $32, $33, $0c, $74, $0f, $05, $00, $01, $04, $05
	db $0c, $d0, $0f, $09, $10, $11, $14, $15, $0c, $f0, $0f, $09, $06, $07, $0a, $0b
	db $0c, $0a, $10, $0c, $94, $0f, $05, $16, $17, $1a, $1b, $0c, $2a, $10, $0c, $34
	db $0e, $2c, $2d, $0c, $4e, $10, $0c, $8a, $02, $0c, $52, $0f, $01, $2e, $2f, $0c
	db $6e, $10, $0c, $aa, $02, $0c, $72, $0f, $01, $0c, $88, $02, $00, $01, $02, $03
	db $02, $03, $0c, $12, $0f, $01, $0c, $a8, $02, $10, $11, $12, $13, $12, $13, $0c
	db $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $6B, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $DD packed).
FloorScreen_2B_29::
	db $00, $02, $0c, $28, $29, $0c, $00, $0e, $ff, $0c, $14, $07, $2a, $2b
	db $0c, $20, $0e, $0c, $14, $08, $0c, $00, $04, $2c, $2d, $08, $09, $0c, $4a, $02
	db $24, $25, $0c, $14, $0f, $01, $2e, $2f, $18, $19, $0c, $6a, $02, $26, $27, $0c
	db $34, $0f, $03, $30, $31, $34, $35, $0c, $8c, $00, $06, $07, $0c, $54, $0f, $03
	db $32, $33, $36, $37, $0c, $ac, $00, $16, $17, $0c, $14, $08, $0c, $48, $04, $0a
	db $0b, $30, $31, $0c, $ca, $00, $0c, $8c, $00, $0c, $14, $08, $0c, $68, $04, $1a
	db $1b, $32, $33, $0c, $ea, $00, $0c, $ac, $00, $0c, $b4, $0a, $38, $39, $0c, $ca
	db $02, $0c, $ca, $00, $00, $01, $04, $05, $30, $31, $0c, $d4, $0a, $3a, $3b, $0c
	db $ea, $02, $0c, $ea, $00, $10, $11, $14, $15, $32, $33, $0c, $f4, $0c, $34, $35
	db $0c, $0a, $12, $02, $03, $0c, $00, $00, $02, $03, $0c, $14, $1c, $36, $37, $0c
	db $2a, $12, $12, $13, $0c, $20, $00, $12, $13, $0c, $f4, $0c, $0c, $42, $12, $06
	db $07, $24, $25, $0c, $0e, $0e, $0c, $20, $10, $0c, $62, $12, $16, $17, $26, $27
	db $0c, $2e, $0f, $01, $02, $03, $02, $03, $0c, $10, $10, $30, $31, $0c, $8c, $1f
	db $01, $0c, $70, $10, $12, $13, $0c, $30, $10, $32, $33, $0c, $ac, $1f, $01

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $76, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $A2 packed).
FloorScreen_2B_2A::
	db $00
	db $02, $00, $28, $29, $00, $00, $0e, $ff, $00, $14, $07, $2a, $2b, $00, $20, $0e
	db $00, $14, $08, $00, $00, $0f, $2d, $08, $09, $24, $25, $00, $04, $0f, $09, $18
	db $19, $26, $27, $00, $24, $0f, $09, $30, $31, $06, $07, $00, $82, $0c, $00, $14
	db $08, $32, $33, $16, $17, $00, $a2, $0c, $00, $b4, $0a, $34, $35, $00, $c2, $0c
	db $00, $d4, $0a, $36, $37, $00, $e2, $0c, $00, $14, $08, $04, $05, $30, $31, $00
	db $c0, $00, $00, $80, $08, $00, $14, $08, $14, $15, $32, $33, $00, $e0, $00, $00
	db $a0, $08, $00, $14, $08, $2c, $2d, $00, $42, $10, $30, $31, $38, $39, $00, $c2
	db $06, $00, $14, $08, $2e, $2f, $00, $62, $10, $32, $33, $3a, $3b, $00, $e2, $06
	db $00, $34, $0a, $02, $03, $02, $03, $04, $05, $34, $35, $30, $31, $00, $8c, $1f
	db $01, $2a, $2b, $12, $13, $12, $13, $14, $15, $36, $37, $32, $33, $00, $ac, $1f
	db $01

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $77, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $BA packed).
FloorScreen_2B_2B::
	db $00, $02, $06, $28, $29, $06, $00, $0e, $ff, $06, $14, $07, $2a, $2b, $06
	db $20, $0e, $06, $14, $08, $06, $00, $0f, $2d, $08, $09, $06, $80, $0c, $24, $25
	db $06, $14, $08, $18, $19, $06, $a0, $0c, $26, $27, $06, $14, $08, $30, $31, $06
	db $c0, $00, $38, $39, $38, $39, $34, $35, $06, $c2, $02, $06, $92, $0a, $32, $33
	db $06, $e0, $00, $3a, $3b, $3a, $3b, $36, $37, $06, $e2, $02, $06, $b2, $0c, $00
	db $01, $02, $03, $06, $04, $12, $04, $05, $06, $c0, $00, $06, $d2, $0c, $10, $11
	db $12, $13, $06, $24, $12, $14, $15, $06, $e0, $00, $06, $b2, $0a, $02, $03, $06
	db $00, $02, $2c, $2d, $08, $09, $0a, $0b, $06, $0e, $1e, $12, $13, $06, $20, $02
	db $2e, $2f, $18, $19, $1a, $1b, $06, $2e, $1e, $06, $42, $14, $06, $4c, $10, $34
	db $35, $06, $8c, $10, $06, $92, $0a, $06, $62, $14, $06, $6c, $10, $36, $37, $06
	db $ac, $10, $06, $72, $1f, $03, $06, $c0, $00, $06, $02, $12, $06, $12, $0f, $01
	db $2e, $2f, $06, $e0, $00, $06, $22, $12, $06, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $78, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $B8 packed).
FloorScreen_2B_2C::
	db $00, $02, $06, $28, $29
	db $06, $00, $0e, $ff, $06, $14, $07, $2a, $2b, $06, $20, $0e, $06, $14, $08, $2c
	db $2d, $08, $09, $06, $42, $04, $24, $25, $06, $0e, $0e, $2e, $2f, $18, $19, $06
	db $62, $04, $26, $27, $06, $2e, $0e, $0a, $0b, $38, $39, $06, $82, $00, $34, $35
	db $34, $35, $06, $4c, $0f, $01, $1a, $1b, $3a, $3b, $06, $a2, $00, $36, $37, $36
	db $37, $06, $6c, $0f, $01, $30, $31, $06, $c0, $00, $00, $01, $04, $05, $30, $31
	db $06, $4c, $0f, $01, $32, $33, $06, $e0, $00, $10, $11, $14, $15, $32, $33, $06
	db $ac, $0f, $03, $00, $01, $02, $03, $28, $29, $2c, $2d, $06, $ca, $0f, $05, $10
	db $11, $12, $13, $2a, $2b, $2e, $2f, $06, $ea, $0f, $03, $06, $04, $10, $06, $00
	db $00, $2c, $2d, $06, $8a, $0f, $03, $06, $24, $10, $06, $20, $00, $2e, $2f, $06
	db $aa, $0f, $03, $06, $42, $14, $0a, $0b, $06, $8a, $0f, $03, $06, $62, $14, $1a
	db $1b, $06, $6a, $1f, $0b, $06, $c0, $00, $06, $8c, $1f, $09, $06, $e0, $00, $06
	db $6c, $0f, $01

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $79, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $F2 packed).
FloorScreen_2B_2D::
	db $00, $02, $0c, $28, $29, $0c, $00, $0e, $ff, $0c, $14, $07, $2a
	db $2b, $0c, $20, $0e, $0c, $14, $08, $0c, $00, $00, $2c, $2d, $08, $09, $0c, $46
	db $04, $24, $25, $0c, $12, $0e, $2e, $2f, $18, $19, $0c, $66, $04, $26, $27, $0c
	db $32, $0a, $0c, $46, $00, $0a, $0b, $38, $39, $38, $39, $34, $35, $30, $31, $34
	db $35, $06, $07, $24, $25, $0c, $14, $08, $0c, $66, $00, $1a, $1b, $3a, $3b, $3a
	db $3b, $36, $37, $32, $33, $36, $37, $16, $17, $26, $27, $0c, $14, $08, $30, $31
	db $0c, $c0, $02, $00, $01, $02, $03, $04, $05, $0c, $8c, $00, $0c, $92, $0a, $32
	db $33, $0c, $e0, $02, $10, $11, $12, $13, $14, $15, $0c, $ac, $00, $0c, $b2, $0e
	db $0c, $c8, $00, $0c, $42, $00, $0a, $0b, $0c, $c0, $00, $0c, $d2, $0e, $0c, $e8
	db $00, $0c, $62, $00, $1a, $1b, $0c, $e0, $00, $0c, $b2, $0a, $04, $05, $38, $39
	db $06, $07, $0c, $80, $02, $0c, $c0, $02, $0c, $92, $0a, $14, $15, $3a, $3b, $16
	db $17, $0c, $a0, $02, $0c, $e0, $02, $0c, $b2, $0a, $2c, $2d, $0c, $88, $00, $34
	db $35, $38, $39, $0c, $8c, $00, $0c, $04, $12, $0c, $14, $08, $2e, $2f, $0c, $a8
	db $00, $36, $37, $3a, $3b, $0c, $ac, $00, $0c, $24, $12, $0c, $34, $0a, $02, $03
	db $0c, $ca, $02, $0c, $c6, $00, $0c, $0e, $0f, $01, $12, $13, $0c, $ea, $02, $0c
	db $e6, $00, $0c, $2e, $0e

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $7A, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $C9 packed).
FloorScreen_2B_2E::
	db $00, $02, $0a, $28, $29, $0a, $00, $0e, $ff, $0a, $14
	db $07, $2a, $2b, $0a, $20, $0e, $0a, $14, $08, $0a, $00, $00, $2c, $2d, $08, $09
	db $0a, $46, $06, $24, $25, $0a, $14, $0c, $2e, $2f, $18, $19, $0a, $66, $06, $26
	db $27, $0a, $14, $08, $0a, $50, $00, $2c, $2d, $30, $31, $34, $35, $0a, $88, $04
	db $0a, $52, $0a, $0a, $70, $00, $2e, $2f, $32, $33, $36, $37, $0a, $a8, $04, $0a
	db $72, $0a, $30, $31, $06, $07, $0e, $0f, $38, $39, $0a, $c6, $04, $0a, $90, $0c
	db $32, $33, $16, $17, $1e, $1f, $3a, $3b, $0a, $e6, $04, $0a, $b0, $0e, $30, $31
	db $0e, $0f, $0a, $00, $10, $0a, $ca, $0f, $05, $32, $33, $1e, $1f, $0a, $20, $10
	db $0a, $ea, $0f, $03, $04, $05, $30, $31, $20, $21, $0a, $06, $1f, $07, $14, $15
	db $32, $33, $22, $23, $0a, $26, $1f, $07, $0a, $84, $00, $0a, $82, $16, $0a, $8e
	db $0e, $0a, $a4, $00, $0a, $a2, $16, $0a, $ae, $0e, $28, $29, $02, $03, $02, $03
	db $0a, $40, $10, $30, $31, $00, $01, $0a, $c2, $10, $0a, $12, $0c, $12, $13, $12
	db $13, $0a, $60, $10, $32, $33, $10, $11, $0a, $e2, $10, $0a, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $7B, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $EA packed).
FloorScreen_2B_2F::
	db $00, $02
	db $06, $28, $29, $06, $00, $0e, $ff, $06, $14, $07, $2a, $2b, $06, $20, $0e, $06
	db $14, $08, $2c, $2d, $08, $09, $06, $42, $00, $0e, $0f, $06, $42, $02, $24, $25
	db $06, $12, $0a, $2e, $2f, $18, $19, $06, $62, $00, $1e, $1f, $06, $62, $02, $26
	db $27, $06, $32, $0a, $0a, $0b, $34, $35, $34, $35, $30, $31, $0e, $0f, $30, $31
	db $06, $82, $00, $06, $50, $0c, $1a, $1b, $36, $37, $36, $37, $32, $33, $1e, $1f
	db $32, $33, $06, $a2, $00, $06, $70, $0c, $06, $82, $00, $0c, $0d, $30, $31, $20
	db $21, $30, $31, $0c, $0d, $06, $8e, $0e, $06, $a2, $00, $1c, $1d, $32, $33, $22
	db $23, $32, $33, $1c, $1d, $06, $ae, $0e, $30, $31, $06, $86, $04, $06, $86, $00
	db $06, $8e, $0e, $32, $33, $06, $a6, $04, $06, $a6, $00, $06, $ae, $0e, $04, $05
	db $38, $39, $06, $c8, $00, $06, $84, $00, $20, $21, $06, $8e, $0e, $14, $15, $3a
	db $3b, $06, $e8, $00, $06, $a4, $00, $22, $23, $06, $ae, $0e, $2c, $2d, $06, $00
	db $10, $06, $8a, $02, $06, $84, $00, $06, $50, $0e, $06, $20, $10, $06, $aa, $02
	db $06, $a4, $00, $06, $70, $0c, $28, $29, $02, $03, $02, $03, $04, $05, $06, $00
	db $10, $00, $01, $02, $03, $06, $10, $0e, $12, $13, $12, $13, $14, $15, $06, $20
	db $10, $10, $11, $12, $13, $06, $30, $0c

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $86, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $AD packed).
FloorScreen_2B_30::
	db $00, $02, $00, $28, $29, $00, $00, $00
	db $2c, $2d, $30, $31, $30, $31, $24, $25, $00, $00, $02, $ff, $00, $14, $07, $2a
	db $2b, $00, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $00, $20, $02, $00
	db $14, $08, $00, $00, $08, $06, $07, $00, $0c, $02, $00, $14, $0f, $05, $16, $17
	db $00, $2c, $02, $00, $34, $0e, $28, $29, $04, $05, $00, $48, $02, $0e, $0f, $08
	db $09, $00, $14, $0e, $2a, $2b, $14, $15, $00, $68, $02, $1e, $1f, $18, $19, $00
	db $74, $0f, $01, $00, $06, $02, $30, $31, $20, $21, $30, $31, $00, $94, $0f, $01
	db $00, $26, $02, $32, $33, $22, $23, $32, $33, $00, $74, $0f, $01, $00, $86, $04
	db $00, $08, $00, $00, $94, $0f, $01, $00, $a6, $04, $00, $28, $00, $00, $f4, $0f
	db $03, $28, $29, $02, $03, $00, $4c, $12, $00, $14, $1f, $03, $2a, $2b, $12, $13
	db $00, $6c, $12, $00, $34, $1f, $05, $00, $80, $04, $00, $54, $1f, $05, $00, $a0
	db $04, $00, $74, $1f, $39

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $87, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $A5 packed).
FloorScreen_2B_31::
	db $00, $02, $00, $28, $29, $00, $00, $00, $2c, $2d, $30
	db $31, $30, $31, $24, $25, $00, $00, $02, $ff, $00, $14, $07, $2a, $2b, $00, $20
	db $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $00, $20, $02, $00, $14, $08, $00
	db $00, $08, $06, $07, $08, $09, $08, $09, $24, $25, $00, $14, $0f, $05, $16, $17
	db $18, $19, $18, $19, $26, $27, $00, $34, $0f, $05, $30, $31, $34, $35, $34, $35
	db $06, $07, $00, $14, $0f, $05, $32, $33, $36, $37, $36, $37, $16, $17, $00, $34
	db $0e, $28, $29, $02, $03, $04, $05, $00, $8a, $04, $00, $14, $0e, $2a, $2b, $12
	db $13, $14, $15, $00, $aa, $04, $00, $b4, $0f, $01, $00, $84, $08, $00, $d4, $0f
	db $01, $00, $a4, $08, $00, $f4, $0f, $03, $00, $c6, $00, $00, $4c, $12, $00, $14
	db $1f, $03, $00, $e6, $00, $00, $6c, $12, $00, $34, $1f, $05, $00, $c0, $04, $00
	db $54, $1f, $05, $00, $e0, $04, $00, $74, $1f, $39

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $88, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $E7 packed).
FloorScreen_2B_32::
	db $00, $02, $04, $28, $29, $04
	db $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $04, $00, $02, $ff, $04, $14
	db $07, $2a, $2b, $04, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $04, $20
	db $02, $04, $14, $08, $2c, $2d, $08, $09, $08, $09, $0a, $0b, $04, $08, $0f, $05
	db $2e, $2f, $18, $19, $18, $19, $1a, $1b, $04, $28, $0f, $07, $04, $08, $00, $38
	db $39, $38, $39, $00, $01, $04, $02, $02, $08, $09, $04, $54, $0a, $04, $28, $00
	db $3a, $3b, $3a, $3b, $10, $11, $04, $22, $02, $18, $19, $04, $34, $0a, $34, $35
	db $04, $08, $00, $30, $31, $06, $07, $04, $42, $04, $04, $54, $0a, $36, $37, $04
	db $28, $00, $32, $33, $16, $17, $04, $62, $04, $04, $34, $0a, $38, $39, $04, $c2
	db $04, $04, $06, $14, $04, $54, $0a, $3a, $3b, $04, $e2, $04, $04, $26, $14, $04
	db $f4, $0c, $38, $39, $04, $08, $00, $34, $35, $00, $01, $02, $03, $04, $4e, $10
	db $04, $14, $1c, $3a, $3b, $04, $28, $00, $36, $37, $10, $11, $12, $13, $04, $6e
	db $10, $04, $34, $1e, $38, $39, $0c, $0d, $04, $4a, $0f, $05, $04, $a6, $00, $3a
	db $3b, $1c, $1d, $04, $2a, $0f, $03, $28, $29, $04, $4e, $12, $04, $c0, $10, $04
	db $00, $02, $04, $12, $0c, $04, $6e, $12, $04, $e0, $10, $04, $20, $02, $04, $32
	db $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $89, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $101 packed).
FloorScreen_2B_33::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24
	db $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32
	db $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $0c, $04, $00, $08, $09
	db $0a, $0b, $30, $31, $38, $39, $06, $07, $0c, $0c, $02, $0c, $14, $0a, $2e, $2f
	db $18, $19, $1a, $1b, $32, $33, $3a, $3b, $16, $17, $0c, $2c, $02, $0c, $14, $08
	db $2c, $2d, $0c, $46, $00, $0c, $48, $00, $38, $39, $30, $31, $06, $07, $0e, $0f
	db $08, $09, $0c, $14, $08, $2e, $2f, $0c, $66, $00, $0c, $68, $00, $3a, $3b, $32
	db $33, $16, $17, $1e, $1f, $18, $19, $0c, $74, $0a, $0c, $08, $00, $00, $01, $02
	db $03, $04, $05, $0c, $08, $00, $20, $21, $30, $31, $0c, $94, $0a, $0c, $28, $00
	db $10, $11, $12, $13, $14, $15, $0c, $28, $00, $22, $23, $32, $33, $0c, $74, $0a
	db $34, $35, $34, $35, $0c, $4c, $02, $0c, $ca, $02, $0c, $d2, $0c, $36, $37, $36
	db $37, $0c, $6c, $02, $0c, $ea, $02, $0c, $f2, $0a, $0c, $0a, $10, $0c, $02, $12
	db $0c, $44, $02, $0c, $c4, $00, $0c, $14, $0a, $14, $15, $0c, $22, $12, $0c, $64
	db $02, $0c, $e4, $00, $0c, $34, $0a, $0c, $40, $14, $0c, $0e, $12, $0c, $0a, $00
	db $0c, $14, $0c, $0c, $62, $12, $0c, $2e, $12, $0c, $2a, $00, $0c, $74, $1c, $28
	db $29, $02, $03, $0c, $c6, $16, $0c, $12, $0f, $01, $12, $13, $0c, $e6, $16, $0c
	db $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $8A, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $F4 packed).
FloorScreen_2B_34::
	db $00, $02, $00, $28, $29, $00, $00, $00, $2c, $2d, $30, $31, $30, $31
	db $24, $25, $00, $00, $02, $ff, $00, $14, $07, $2a, $2b, $00, $20, $00, $2e, $2f
	db $32, $33, $32, $33, $26, $27, $00, $20, $02, $00, $14, $08, $2c, $2d, $08, $09
	db $08, $09, $0a, $0b, $00, $08, $00, $06, $07, $08, $09, $00, $0c, $00, $00, $14
	db $08, $2e, $2f, $18, $19, $18, $19, $1a, $1b, $00, $28, $00, $16, $17, $18, $19
	db $00, $2c, $00, $00, $34, $0a, $00, $08, $00, $30, $31, $34, $35, $00, $82, $02
	db $00, $4c, $00, $00, $54, $0a, $00, $28, $00, $32, $33, $36, $37, $00, $a2, $02
	db $00, $6c, $00, $00, $34, $0a, $00, $88, $04, $00, $88, $04, $30, $31, $00, $54
	db $0a, $00, $a8, $04, $00, $a8, $04, $32, $33, $00, $34, $0a, $38, $39, $0c, $0d
	db $34, $35, $0c, $0d, $30, $31, $0c, $0d, $00, $02, $10, $00, $d2, $0c, $3a, $3b
	db $1c, $1d, $36, $37, $1c, $1d, $32, $33, $1c, $1d, $00, $22, $10, $00, $f2, $0e
	db $0e, $0f, $00, $42, $14, $34, $35, $24, $25, $02, $03, $00, $14, $1c, $1e, $1f
	db $00, $62, $14, $36, $37, $26, $27, $12, $13, $00, $74, $0c, $0e, $0f, $00, $82
	db $14, $00, $4e, $10, $00, $52, $0c, $32, $33, $1e, $1f, $00, $a2, $14, $00, $6e
	db $10, $00, $32, $0a, $28, $29, $02, $03, $00, $c0, $1a, $00, $12, $0c, $12, $13
	db $00, $e0, $1a, $00, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $8B, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $F3 packed).
FloorScreen_2B_35::
	db $00, $02, $0a, $28, $29, $0a, $00, $00, $2c, $2d
	db $30, $31, $30, $31, $24, $25, $0a, $00, $02, $ff, $0a, $14, $07, $2a, $2b, $0a
	db $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0a, $20, $02, $0a, $14, $08
	db $0a, $00, $08, $06, $07, $08, $09, $08, $09, $24, $25, $0a, $14, $0f, $05, $16
	db $17, $18, $19, $18, $19, $26, $27, $0a, $34, $0e, $28, $29, $04, $05, $30, $31
	db $34, $35, $38, $39, $38, $39, $06, $07, $0a, $14, $0e, $2a, $2b, $14, $15, $32
	db $33, $36, $37, $3a, $3b, $3a, $3b, $16, $17, $0a, $74, $0f, $01, $0a, $06, $02
	db $0a, $8c, $00, $30, $31, $0a, $94, $0f, $01, $0a, $26, $02, $0a, $ac, $00, $32
	db $33, $0a, $14, $08, $2c, $2d, $0a, $4e, $00, $08, $09, $0e, $0f, $0a, $08, $00
	db $0a, $0a, $12, $0a, $14, $08, $2e, $2f, $0a, $6e, $00, $18, $19, $1e, $1f, $0a
	db $28, $00, $0a, $2a, $12, $0a, $f4, $0a, $38, $39, $34, $35, $34, $35, $20, $21
	db $30, $31, $00, $01, $02, $03, $0a, $4e, $10, $0a, $14, $1a, $3a, $3b, $36, $37
	db $36, $37, $22, $23, $32, $33, $10, $11, $12, $13, $0a, $6e, $10, $0a, $f4, $0a
	db $0a, $0a, $16, $0a, $0c, $0f, $01, $0a, $26, $02, $0a, $2a, $12, $0a, $2c, $0f
	db $03, $0a, $4e, $12, $0a, $4e, $10, $0a, $80, $04, $0a, $14, $0a, $0a, $6e, $12
	db $0a, $6e, $10, $0a, $a0, $04, $0a, $14, $08

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $96, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $97 packed).
FloorScreen_2B_36::
	db $00, $02, $04, $28, $29, $04, $00
	db $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $04, $00, $02, $ff, $04, $14, $07
	db $2a, $2b, $04, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $04, $20, $02
	db $04, $14, $08, $2c, $2d, $08, $09, $08, $09, $0a, $0b, $04, $08, $0f, $05, $2e
	db $2f, $18, $19, $18, $19, $1a, $1b, $04, $28, $0f, $05, $04, $46, $02, $04, $08
	db $00, $00, $01, $04, $00, $02, $04, $12, $0a, $04, $66, $02, $04, $28, $00, $10
	db $11, $04, $20, $02, $04, $32, $0a, $04, $84, $04, $02, $03, $04, $8c, $04, $04
	db $12, $0a, $04, $a4, $04, $12, $13, $04, $ac, $04, $04, $b2, $0c, $04, $c6, $0a
	db $04, $d0, $0e, $04, $e6, $0a, $04, $30, $0c, $04, $04, $1c, $04, $10, $0c, $04
	db $24, $1c, $04, $30, $0c, $04, $42, $1e, $04, $12, $0f, $01, $04, $66, $1f, $47
;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $97, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $CE packed).
FloorScreen_2B_37::
	db $00, $02, $00, $28, $29, $00, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25
	db $00, $00, $02, $ff, $00, $14, $07, $2a, $2b, $00, $20, $00, $2e, $2f, $32, $33
	db $32, $33, $26, $27, $00, $20, $02, $00, $14, $08, $00, $00, $06, $34, $35, $00
	db $0c, $0f, $0b, $36, $37, $00, $2c, $0f, $01, $08, $09, $00, $0c, $02, $04, $05
	db $00, $4a, $0f, $03, $18, $19, $00, $2c, $02, $14, $15, $00, $6a, $0f, $03, $30
	db $31, $06, $07, $08, $09, $08, $09, $0e, $0f, $00, $0a, $0f, $03, $32, $33, $16
	db $17, $18, $19, $18, $19, $1e, $1f, $00, $2a, $0f, $03, $00, $48, $00, $34, $35
	db $30, $31, $0e, $0f, $38, $39, $00, $cc, $0f, $03, $36, $37, $36, $37, $32, $33
	db $1e, $1f, $3a, $3b, $00, $2c, $0f, $01, $04, $05, $00, $00, $12, $20, $21, $00
	db $0a, $0f, $03, $14, $15, $00, $20, $12, $22, $23, $00, $2a, $0f, $03, $2c, $2d
	db $00, $04, $10, $00, $02, $10, $00, $4a, $0f, $03, $2e, $2f, $00, $24, $10, $00
	db $22, $10, $00, $6a, $0f, $03, $28, $29, $02, $03, $00, $c2, $14, $00, $00, $02
	db $00, $12, $0c, $12, $13, $00, $e2, $14, $00, $20, $02, $00, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $98, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $E1 packed).
FloorScreen_2B_38::
	db $00, $02
	db $00, $28, $29, $00, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $00, $00
	db $02, $ff, $00, $14, $07, $2a, $2b, $00, $20, $00, $2e, $2f, $32, $33, $32, $33
	db $26, $27, $00, $20, $02, $00, $14, $08, $00, $00, $08, $06, $07, $08, $09, $08
	db $09, $24, $25, $00, $14, $0f, $05, $16, $17, $18, $19, $18, $19, $26, $27, $00
	db $14, $08, $00, $50, $00, $00, $00, $00, $04, $05, $00, $08, $00, $34, $35, $00
	db $0a, $00, $00, $14, $08, $00, $70, $00, $00, $20, $00, $14, $15, $00, $28, $00
	db $36, $37, $00, $2a, $00, $00, $14, $08, $00, $4a, $06, $02, $03, $04, $05, $34
	db $35, $34, $35, $00, $52, $0a, $00, $6a, $06, $12, $13, $14, $15, $36, $37, $36
	db $37, $00, $b2, $0c, $00, $8a, $02, $00, $4c, $00, $0a, $0b, $00, $08, $02, $00
	db $d4, $0a, $00, $aa, $02, $00, $6c, $00, $1a, $1b, $00, $28, $02, $00, $14, $08
	db $02, $03, $00, $ca, $00, $00, $8c, $00, $00, $8e, $00, $00, $0e, $1e, $12, $13
	db $00, $ea, $00, $00, $ac, $00, $00, $ae, $00, $00, $2e, $1e, $00, $00, $02, $00
	db $40, $10, $00, $86, $14, $00, $12, $0f, $01, $00, $60, $10, $00, $a6, $14, $00
	db $32, $0f, $01, $00, $c0, $1a, $00, $14, $0e, $00, $e0, $1a, $00, $14, $08

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $99, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $E2 packed).
FloorScreen_2B_39::
	db $00
	db $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $0c
	db $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32, $33, $32
	db $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $0c, $00, $08, $06, $07, $08, $09
	db $08, $09, $24, $25, $0c, $14, $0f, $05, $16, $17, $18, $19, $18, $19, $26, $27
	db $0c, $14, $08, $0c, $50, $00, $0c, $00, $00, $04, $05, $0c, $08, $00, $30, $31
	db $38, $39, $0c, $52, $0a, $0c, $70, $00, $0c, $20, $00, $14, $15, $0c, $28, $00
	db $32, $33, $3a, $3b, $0c, $72, $0a, $0c, $4a, $04, $0a, $0b, $0c, $8c, $02, $0c
	db $90, $0c, $0c, $6a, $04, $1a, $1b, $0c, $ac, $02, $0c, $b0, $0e, $0c, $00, $1a
	db $0c, $d0, $0e, $0c, $20, $1a, $0c, $b0, $0c, $04, $05, $34, $35, $30, $31, $0c
	db $42, $10, $00, $01, $02, $03, $0c, $4c, $10, $0c, $12, $0a, $14, $15, $36, $37
	db $32, $33, $0c, $62, $10, $10, $11, $12, $13, $0c, $6c, $10, $0c, $32, $0a, $2c
	db $2d, $0c, $42, $10, $0c, $44, $10, $0c, $0c, $04, $0c, $12, $0a, $2e, $2f, $0c
	db $62, $10, $0c, $64, $10, $0c, $2c, $04, $0c, $32, $0c, $0c, $4c, $12, $0c, $50
	db $10, $0c, $8c, $1f, $01, $2a, $2b, $0c, $6c, $12, $0c, $70, $10, $0c, $ac, $1f
	db $01

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $9A, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $EB packed).
FloorScreen_2B_3A::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24
	db $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32
	db $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $0c, $00, $0f, $2d, $08
	db $09, $24, $25, $2c, $2d, $0a, $0b, $34, $35, $00, $01, $0c, $00, $02, $0c, $12
	db $0a, $18, $19, $26, $27, $2e, $2f, $1a, $1b, $36, $37, $10, $11, $0c, $20, $02
	db $0c, $32, $0a, $30, $31, $06, $07, $0c, $86, $00, $34, $35, $0c, $0c, $04, $0c
	db $12, $0a, $32, $33, $16, $17, $0c, $a6, $00, $36, $37, $0c, $2c, $04, $0c, $b2
	db $0c, $30, $31, $0c, $c6, $00, $0c, $c0, $00, $08, $09, $0c, $0c, $10, $24, $25
	db $0c, $d4, $0a, $32, $33, $0c, $e6, $00, $0c, $e0, $00, $18, $19, $0c, $2c, $10
	db $26, $27, $0c, $14, $08, $02, $03, $0c, $40, $10, $04, $05, $38, $39, $0c, $02
	db $10, $30, $31, $38, $39, $0c, $12, $1a, $12, $13, $0c, $60, $10, $14, $15, $3a
	db $3b, $0c, $22, $10, $32, $33, $3a, $3b, $0c, $32, $1a, $0c, $00, $04, $38, $39
	db $0c, $48, $12, $0c, $c8, $00, $0c, $14, $0f, $01, $3a, $3b, $0c, $68, $12, $0c
	db $e8, $00, $0c, $34, $0e, $28, $29, $0c, $40, $12, $0c, $40, $10, $0c, $12, $0f
	db $01, $2a, $2b, $0c, $60, $12, $0c, $60, $10, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $9B, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $CE packed).
FloorScreen_2B_3B::
	db $00, $02, $0c, $28
	db $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $0c, $00, $02, $ff
	db $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27
	db $0c, $20, $02, $0c, $14, $08, $2c, $2d, $08, $09, $08, $09, $0a, $0b, $38, $39
	db $0c, $0a, $0f, $03, $2e, $2f, $18, $19, $18, $19, $1a, $1b, $3a, $3b, $0c, $2a
	db $0f, $03, $0a, $0b, $34, $35, $0c, $82, $00, $38, $39, $38, $39, $0c, $0c, $0f
	db $01, $1a, $1b, $36, $37, $0c, $a2, $00, $3a, $3b, $3a, $3b, $0c, $2c, $0f, $01
	db $0c, $08, $00, $00, $01, $02, $03, $04, $05, $0c, $0a, $0f, $03, $0c, $28, $00
	db $10, $11, $12, $13, $14, $15, $0c, $2a, $0f, $03, $0c, $08, $00, $06, $07, $0c
	db $44, $00, $0c, $ca, $0f, $07, $16, $17, $0c, $64, $00, $0c, $2a, $0f, $03, $0c
	db $c8, $00, $34, $35, $0c, $42, $12, $0c, $0c, $0f, $01, $0c, $e8, $00, $36, $37
	db $0c, $62, $12, $0c, $2c, $0f, $03, $0c, $42, $1f, $0b, $0c, $26, $00, $0c, $64
	db $1f, $09, $28, $29, $02, $03, $0c, $c2, $14, $0c, $00, $02, $0c, $12, $0c, $12
	db $13, $0c, $e2, $14, $0c, $20, $02, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $A6, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $EF packed).
FloorScreen_2B_3C::
	db $00, $02, $0c, $28, $29, $0c
	db $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $0c, $00, $02, $ff, $0c, $14
	db $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0c, $20
	db $02, $0c, $14, $08, $2c, $2d, $08, $09, $08, $09, $0a, $0b, $0c, $08, $00, $06
	db $07, $0c, $42, $00, $24, $25, $0c, $14, $08, $2e, $2f, $18, $19, $18, $19, $1a
	db $1b, $0c, $28, $00, $16, $17, $0c, $62, $00, $26, $27, $0c, $34, $0a, $0c, $08
	db $00, $0c, $82, $02, $34, $35, $0c, $8c, $00, $0c, $52, $0c, $0c, $28, $00, $0c
	db $a2, $02, $36, $37, $0c, $ac, $00, $0c, $72, $0e, $38, $39, $00, $01, $02, $03
	db $02, $03, $04, $05, $38, $39, $0c, $90, $0f, $01, $3a, $3b, $10, $11, $12, $13
	db $12, $13, $14, $15, $3a, $3b, $0c, $b0, $0e, $34, $35, $38, $39, $0c, $0c, $02
	db $2c, $2d, $0c, $ce, $0f, $01, $36, $37, $3a, $3b, $0c, $2c, $02, $2e, $2f, $0c
	db $ee, $0f, $05, $0c, $4c, $02, $0a, $0b, $38, $39, $0c, $0a, $00, $0c, $14, $1e
	db $0c, $6c, $02, $1a, $1b, $3a, $3b, $0c, $2a, $00, $0c, $f4, $0c, $0c, $8c, $00
	db $0c, $82, $06, $0c, $12, $1e, $0c, $ac, $00, $0c, $a2, $06, $0c, $72, $0a, $28
	db $29, $0c, $c8, $02, $0c, $08, $00, $0c, $c6, $02, $0c, $12, $0c, $0c, $e8, $02
	db $0c, $28, $00, $0c, $e6, $02, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $A7, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $A2 packed).
FloorScreen_2B_3D::
	db $00, $02, $0c, $28, $29, $0c, $00
	db $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $0c, $00, $02, $ff, $0c, $14, $07
	db $2a, $2b, $0c, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0c, $20, $02
	db $0c, $14, $08, $0c, $00, $08, $06, $07, $0c, $0c, $02, $0c, $14, $0f, $05, $16
	db $17, $0c, $2c, $02, $0c, $34, $0e, $28, $29, $04, $05, $0c, $08, $06, $0c, $14
	db $0e, $2a, $2b, $14, $15, $0c, $28, $06, $0c, $34, $0c, $2c, $2d, $08, $09, $0a
	db $0b, $0c, $8a, $0f, $07, $2e, $2f, $18, $19, $1a, $1b, $0c, $aa, $0f, $09, $0c
	db $08, $00, $0c, $ca, $0f, $09, $0c, $28, $00, $0c, $ea, $0f, $0d, $00, $01, $02
	db $03, $0c, $0e, $0f, $03, $0c, $26, $02, $10, $11, $12, $13, $0c, $2e, $0f, $03
	db $0c, $46, $0a, $0c, $12, $1f, $05, $0c, $6c, $04, $0c, $32, $0f, $01, $0c, $88
	db $08, $0c, $12, $0f, $01, $0c, $a8, $08, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $A8, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $AF packed).
FloorScreen_2B_3E::
	db $00, $02, $0c, $28, $29
	db $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $0c, $00, $02, $ff, $0c
	db $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0c
	db $20, $02, $0c, $14, $08, $0c, $00, $08, $06, $07, $08, $09, $08, $09, $24, $25
	db $0c, $14, $0f, $05, $16, $17, $18, $19, $18, $19, $26, $27, $0c, $34, $0e, $28
	db $29, $04, $05, $0c, $08, $00, $0c, $08, $02, $0c, $14, $0e, $2a, $2b, $14, $15
	db $0c, $28, $00, $0c, $28, $02, $0c, $74, $0f, $01, $0c, $86, $06, $0c, $92, $0f
	db $03, $0c, $a6, $06, $0c, $b2, $0f, $05, $0c, $06, $02, $0c, $d0, $0f, $07, $0c
	db $26, $02, $0c, $b0, $0f, $05, $2c, $2d, $0a, $0b, $0c, $8c, $0f, $09, $2e, $2f
	db $1a, $1b, $0c, $ac, $0f, $07, $0c, $48, $16, $0c, $90, $0f, $03, $0c, $68, $16
	db $0c, $70, $1f, $05, $0c, $08, $00, $00, $01, $02, $03, $02, $03, $0c, $12, $0f
	db $07, $10, $11, $12, $13, $12, $13, $0c, $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $A9, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $E6 packed).
FloorScreen_2B_3F::
	db $00, $02, $0c, $28, $29, $0c
	db $00, $00, $2c, $2d, $34, $35, $30, $31, $24, $25, $0c, $00, $02, $ff, $0c, $14
	db $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $36, $37, $32, $33, $26, $27, $0c, $20
	db $02, $0c, $14, $08, $0c, $00, $06, $34, $35, $06, $07, $0c, $0c, $02, $0c, $14
	db $0f, $03, $36, $37, $16, $17, $0c, $2c, $02, $0c, $34, $0e, $28, $29, $04, $05
	db $0c, $08, $00, $0c, $4c, $02, $0c, $14, $0e, $2a, $2b, $14, $15, $0c, $28, $00
	db $0c, $6c, $02, $0c, $14, $08, $2c, $2d, $08, $09, $08, $09, $24, $25, $0c, $06
	db $02, $0c, $8c, $02, $0c, $14, $08, $2e, $2f, $18, $19, $18, $19, $26, $27, $0c
	db $26, $02, $0c, $ac, $02, $0c, $b4, $0a, $0c, $8a, $04, $0c, $88, $02, $0c, $0a
	db $00, $0c, $d4, $0a, $0c, $aa, $04, $0c, $a8, $02, $0c, $2a, $00, $0c, $b4, $0a
	db $38, $39, $0c, $cc, $02, $0a, $0b, $0c, $0c, $1f, $03, $3a, $3b, $0c, $ec, $02
	db $1a, $1b, $0c, $2c, $1f, $01, $0c, $86, $00, $38, $39, $0c, $48, $00, $0c, $86
	db $12, $00, $01, $0c, $12, $0c, $14, $15, $3a, $3b, $0c, $68, $00, $0c, $a6, $12
	db $10, $11, $0c, $32, $0e, $02, $03, $0c, $88, $00, $0c, $8e, $10, $02, $03, $0c
	db $10, $0f, $01, $12, $13, $0c, $a8, $00, $0c, $ae, $10, $12, $13, $0c, $30, $0c
;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $AA, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $E2 packed).
FloorScreen_2B_40::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25
	db $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32, $33
	db $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $2c, $2d, $08, $09, $08, $09
	db $0a, $0b, $0c, $08, $00, $06, $07, $0c, $42, $00, $24, $25, $0c, $14, $08, $2e
	db $2f, $18, $19, $18, $19, $1a, $1b, $0c, $28, $00, $16, $17, $0c, $62, $00, $26
	db $27, $0c, $34, $0a, $0c, $08, $00, $30, $31, $34, $35, $34, $35, $0c, $82, $02
	db $0c, $52, $0c, $0c, $28, $00, $32, $33, $36, $37, $36, $37, $0c, $a2, $02, $0c
	db $72, $0c, $34, $35, $00, $01, $04, $05, $0c, $88, $00, $0c, $c4, $00, $38, $39
	db $0c, $52, $0c, $36, $37, $10, $11, $14, $15, $0c, $a8, $00, $0c, $e4, $00, $3a
	db $3b, $0c, $b2, $0e, $06, $07, $0e, $0f, $0c, $88, $00, $0e, $0f, $0a, $0b, $0c
	db $d0, $0f, $01, $16, $17, $1e, $1f, $0c, $a8, $00, $1e, $1f, $1a, $1b, $0c, $f0
	db $0e, $0c, $08, $00, $0c, $06, $14, $0c, $8e, $0f, $05, $0c, $26, $14, $0c, $ae
	db $0f, $01, $0c, $42, $1f, $2b, $28, $29, $02, $03, $02, $03, $0c, $06, $04, $0c
	db $c2, $10, $0c, $12, $0c, $12, $13, $12, $13, $0c, $26, $04, $0c, $e2, $10, $0c
	db $32, $0a

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $AB, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $E5 packed).
FloorScreen_2B_41::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31
	db $24, $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f
	db $32, $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08, $2c, $2d, $08, $09
	db $08, $09, $0a, $0b, $0c, $08, $0f, $05, $2e, $2f, $18, $19, $18, $19, $1a, $1b
	db $0c, $28, $0f, $07, $30, $31, $38, $39, $0c, $08, $00, $00, $01, $0c, $00, $02
	db $0c, $52, $0c, $32, $33, $3a, $3b, $0c, $28, $00, $10, $11, $0c, $20, $02, $0c
	db $72, $0f, $01, $38, $39, $34, $35, $06, $07, $0c, $42, $00, $0c, $0c, $00, $0c
	db $94, $0e, $3a, $3b, $36, $37, $16, $17, $0c, $62, $00, $0c, $2c, $00, $0c, $14
	db $08, $28, $29, $02, $03, $04, $05, $0c, $c6, $00, $34, $35, $0c, $c4, $00, $0c
	db $d0, $0c, $2a, $2b, $12, $13, $14, $15, $0c, $e6, $00, $36, $37, $0c, $e4, $00
	db $0c, $f0, $0e, $0c, $00, $00, $0c, $02, $10, $34, $35, $0c, $82, $00, $0c, $10
	db $1e, $0c, $20, $00, $0c, $22, $10, $36, $37, $0c, $a2, $00, $0c, $30, $1f, $03
	db $2c, $2d, $0c, $46, $00, $38, $39, $0c, $8a, $02, $0c, $14, $0f, $01, $0c, $66
	db $00, $3a, $3b, $0c, $aa, $02, $0c, $74, $1f, $01, $0c, $86, $08, $0c, $14, $0f
	db $05, $0c, $aa, $04, $0c, $14, $08

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $B6, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $9F packed).
FloorScreen_2B_42::
	db $00, $02, $04, $28, $29, $04, $00, $00, $2c
	db $2d, $30, $31, $30, $31, $24, $25, $04, $00, $02, $ff, $04, $14, $07, $2a, $2b
	db $04, $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $04, $20, $02, $04, $14
	db $08, $04, $04, $00, $08, $09, $0a, $0b, $04, $08, $0f, $07, $2e, $2f, $18, $19
	db $1a, $1b, $04, $28, $0f, $09, $34, $35, $38, $39, $38, $39, $00, $01, $04, $00
	db $02, $04, $52, $0e, $36, $37, $3a, $3b, $3a, $3b, $10, $11, $04, $20, $02, $04
	db $32, $0e, $04, $08, $00, $04, $0a, $06, $04, $52, $0e, $04, $28, $00, $04, $2a
	db $06, $04, $b2, $0f, $01, $38, $39, $04, $c8, $0f, $0b, $3a, $3b, $04, $e8, $0f
	db $07, $28, $29, $02, $03, $04, $44, $10, $04, $8c, $04, $04, $12, $0e, $12, $13
	db $04, $64, $10, $04, $ac, $04, $04, $32, $1e, $04, $80, $1c, $04, $14, $0e, $04
	db $a0, $1a, $04, $74, $1f, $39

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $B7, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $EF packed).
FloorScreen_2B_43::
	db $00, $02, $0c, $28, $29, $0c, $00, $00, $2c, $2d
	db $30, $31, $30, $31, $24, $25, $0c, $00, $02, $ff, $0c, $14, $07, $2a, $2b, $0c
	db $20, $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $0c, $20, $02, $0c, $14, $08
	db $0c, $00, $06, $34, $35, $06, $07, $0c, $0c, $02, $0c, $14, $0f, $03, $36, $37
	db $16, $17, $0c, $2c, $02, $0c, $34, $0e, $28, $29, $04, $05, $0c, $08, $00, $06
	db $07, $08, $09, $24, $25, $0c, $14, $0e, $2a, $2b, $14, $15, $0c, $28, $00, $16
	db $17, $18, $19, $26, $27, $0c, $14, $08, $2c, $2d, $08, $09, $0c, $90, $00, $0c
	db $06, $02, $34, $35, $0c, $0a, $00, $0c, $14, $08, $2e, $2f, $18, $19, $0c, $b0
	db $00, $0c, $26, $02, $36, $37, $0c, $2a, $00, $0c, $b4, $0a, $0c, $8a, $02, $24
	db $25, $04, $05, $38, $39, $0c, $ce, $0f, $01, $0c, $aa, $02, $26, $27, $14, $15
	db $3a, $3b, $0c, $ee, $0f, $03, $0c, $0c, $10, $06, $07, $0a, $0b, $0c, $ce, $00
	db $38, $39, $0c, $12, $1e, $0c, $2c, $10, $16, $17, $1a, $1b, $0c, $ee, $00, $3a
	db $3b, $0c, $b2, $0a, $0c, $86, $00, $38, $39, $0c, $cc, $02, $30, $31, $00, $01
	db $02, $03, $0c, $12, $0c, $0c, $2a, $10, $0c, $ec, $02, $32, $33, $10, $11, $12
	db $13, $0c, $32, $0e, $02, $03, $0c, $c4, $14, $0c, $0e, $0f, $03, $12, $13, $0c
	db $e4, $14, $0c, $2e, $0e

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $B8, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $D9 packed).
FloorScreen_2B_44::
	db $00, $02, $04, $28, $29, $04, $00, $00, $2c, $2d, $30
	db $31, $30, $31, $24, $25, $04, $00, $02, $ff, $04, $14, $07, $2a, $2b, $04, $20
	db $00, $2e, $2f, $32, $33, $32, $33, $26, $27, $04, $20, $02, $04, $14, $08, $04
	db $00, $0f, $31, $2c, $2d, $0a, $0b, $30, $31, $00, $01, $04, $00, $02, $04, $12
	db $0e, $2e, $2f, $1a, $1b, $32, $33, $10, $11, $04, $20, $02, $04, $72, $0f, $01
	db $04, $08, $02, $2c, $2d, $08, $09, $08, $09, $24, $25, $04, $94, $0e, $04, $28
	db $02, $2e, $2f, $18, $19, $18, $19, $26, $27, $04, $14, $08, $04, $cc, $00, $04
	db $86, $00, $30, $31, $06, $07, $04, $04, $12, $04, $d2, $0a, $04, $ec, $00, $04
	db $a6, $00, $32, $33, $16, $17, $04, $24, $12, $04, $f2, $0c, $30, $31, $34, $35
	db $04, $08, $00, $04, $08, $00, $04, $44, $10, $04, $12, $1c, $32, $33, $36, $37
	db $04, $28, $00, $04, $28, $00, $04, $64, $10, $04, $f2, $0c, $04, $44, $10, $34
	db $35, $00, $01, $02, $03, $04, $8a, $12, $04, $12, $0a, $2e, $2f, $04, $64, $10
	db $36, $37, $10, $11, $12, $13, $04, $aa, $12, $04, $32, $0c, $04, $8c, $14, $04
	db $c8, $16, $04, $14, $0a, $04, $ac, $14, $04, $e8, $16, $04, $14, $08

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $B9, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $D1 packed).
FloorScreen_2B_45::
	db $00, $02
	db $0c, $28, $29, $0c, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $0c, $00
	db $02, $ff, $0c, $14, $07, $2a, $2b, $0c, $20, $00, $2e, $2f, $32, $33, $32, $33
	db $26, $27, $0c, $20, $02, $0c, $14, $08, $0c, $00, $08, $06, $07, $08, $09, $0c
	db $0c, $00, $0c, $14, $0f, $05, $16, $17, $18, $19, $0c, $2c, $00, $0c, $34, $0e
	db $28, $29, $04, $05, $0c, $08, $00, $34, $35, $0c, $50, $0f, $03, $2a, $2b, $14
	db $15, $0c, $28, $00, $36, $37, $0c, $70, $0f, $01, $2c, $2d, $08, $09, $0a, $0b
	db $0c, $8c, $00, $0c, $8e, $0f, $03, $2e, $2f, $18, $19, $1a, $1b, $0c, $ac, $00
	db $0c, $ae, $0f, $05, $38, $39, $38, $39, $0c, $08, $00, $0c, $0a, $02, $0c, $d4
	db $0e, $3a, $3b, $3a, $3b, $0c, $28, $00, $0c, $2a, $02, $0c, $b4, $0e, $0c, $ca
	db $02, $00, $01, $02, $03, $0c, $10, $0f, $01, $0c, $26, $00, $0c, $ec, $00, $10
	db $11, $12, $13, $0c, $30, $0f, $01, $0c, $04, $10, $34, $35, $0c, $0a, $0f, $07
	db $0c, $24, $10, $36, $37, $0c, $2a, $0f, $09, $02, $03, $0c, $c6, $10, $0c, $80
	db $04, $0c, $14, $0e, $12, $13, $0c, $e6, $10, $0c, $a0, $04, $0c, $14, $08

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $BA, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $60 packed).
FloorScreen_2B_46::
	db $00
	db $02, $00, $28, $29, $00, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $00
	db $00, $02, $ff, $00, $14, $07, $2a, $2b, $00, $20, $00, $2e, $2f, $32, $33, $32
	db $33, $26, $27, $00, $20, $02, $00, $14, $08, $00, $00, $0f, $4d, $00, $60, $0f
	db $4d, $00, $80, $02, $28, $29, $02, $03, $02, $03, $00, $00, $14, $00, $94, $0e
	db $2a, $2b, $12, $13, $12, $13, $00, $20, $14, $00, $f4, $0f, $01, $00, $40, $18
	db $00, $14, $1f, $01, $00, $60, $18, $00, $34, $1f, $4d, $00, $94, $1f, $19

;@ path: field/gatefloor/screens
;@ Tilemap of a gate floor room (ScreenMapRefs $BB, picked by GetFloorScreenMap): 20 x 16 tiles in rows of 32
;@ bytes, unpacked to wSavedTilemap by DrawMapScreen. Compressed in the DecompressCore format ($200 bytes
;@ unpacked, $102 packed).
FloorScreen_2B_47::
	db $00
	db $02, $0e, $28, $29, $0e, $00, $00, $2c, $2d, $30, $31, $30, $31, $24, $25, $0e
	db $00, $02, $ff, $0e, $14, $07, $2a, $2b, $0e, $20, $00, $2e, $2f, $32, $33, $32
	db $33, $26, $27, $0e, $20, $02, $0e, $14, $08, $2c, $2d, $08, $09, $08, $09, $0a
	db $0b, $34, $35, $0e, $0a, $00, $0e, $40, $00, $24, $25, $0e, $14, $08, $2e, $2f
	db $18, $19, $18, $19, $1a, $1b, $36, $37, $0e, $2a, $00, $0e, $60, $00, $26, $27
	db $0e, $34, $0a, $34, $35, $0e, $82, $02, $00, $01, $2c, $2d, $0a, $0b, $38, $39
	db $0e, $52, $0c, $36, $37, $0e, $a2, $02, $10, $11, $2e, $2f, $1a, $1b, $3a, $3b
	db $0e, $72, $0f, $01, $0e, $08, $00, $06, $07, $0e, $8e, $00, $34, $35, $0e, $92
	db $0f, $01, $0e, $28, $00, $16, $17, $0e, $ae, $00, $36, $37, $0e, $72, $0e, $30
	db $31, $0c, $0d, $30, $31, $38, $39, $0e, $ce, $00, $0e, $90, $0f, $01, $32, $33
	db $1c, $1d, $32, $33, $3a, $3b, $0e, $ee, $00, $0e, $b0, $0f, $01, $00, $01, $28
	db $29, $04, $05, $38, $39, $0e, $08, $12, $0e, $92, $0e, $10, $11, $2a, $2b, $14
	db $15, $3a, $3b, $0e, $28, $12, $0e, $72, $0a, $28, $29, $02, $03, $0e, $00, $02
	db $04, $05, $0e, $08, $00, $0e, $44, $10, $0e, $14, $0a, $12, $13, $0e, $20, $02
	db $14, $15, $0e, $28, $00, $0e, $64, $10, $0e, $74, $1a, $0e, $c0, $16, $02, $03
	db $0e, $82, $12, $0e, $14, $0e, $0e, $20, $02, $12, $13, $0e, $a2, $12, $0e, $14
	db $08

;@ path: unused/filler
;@ Unused filler up to the end of the bank.
Unused_2B::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
