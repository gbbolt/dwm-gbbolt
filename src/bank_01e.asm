INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $01e", ROMX[$4000], BANK[$1e]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_1E::
	db $1e

;@ path: sound/data
;@ The sound records of bank $1E, sounds $37-$A1 (see SoundBanks): 4 bytes each - channel (byte offset into
;@ wSoundChannels, 26 per channel), channel config byte (hardware channel in bits 0-1) and the address of the
;@ part's event data.
SoundTable_1E::
	db $34, $00
	dw SoundPart_37
	db $4e, $01
	dw SoundPart_38
	db $68, $02
	dw SoundPart_39
	db $34, $00
	dw SoundPart_3A
	db $4e, $01
	dw SoundPart_3B
	db $34, $00
	dw SoundPart_3C
	db $4e, $01
	dw SoundPart_3D
	db $68, $02
	dw SoundPart_3E
	db $00, $00
	dw SoundPart_3F
	db $1a, $01
	dw SoundPart_40
	db $34, $00
	dw SoundPart_41
	db $4e, $01
	dw SoundPart_42
	db $68, $02
	dw SoundPart_43
	db $34, $00
	dw SoundPart_44
	db $4e, $01
	dw SoundPart_45
	db $68, $02
	dw SoundPart_46
	db $00, $00
	dw SoundPart_47
	db $1a, $01
	dw SoundPart_48
	db $00, $00
	dw SoundPart_49
	db $1a, $01
	dw SoundPart_4A
	db $34, $00
	dw SoundPart_4B
	db $4e, $01
	dw SoundPart_4C
	db $34, $00
	dw SoundPart_4D
	db $4e, $01
	dw SoundPart_4E
	db $00, $00
	dw SoundPart_4F
	db $1a, $01
	dw SoundPart_50
	db $00, $03
	dw SoundPart_51
	db $00, $00
	dw SoundPart_52
	db $00, $00
	dw SoundPart_53
	db $00, $00
	dw SoundPart_54
	db $00, $00
	dw SoundPart_55
	db $00, $03
	dw SoundPart_56
	db $00, $00
	dw SoundPart_57
	db $1a, $01
	dw SoundPart_58
	db $00, $00
	dw SoundPart_59
	db $00, $00
	dw SoundPart_5A
	db $00, $00
	dw SoundPart_5B
	db $00, $00
	dw SoundPart_5C
	db $34, $00
	dw SoundPart_5D
	db $4e, $01
	dw SoundPart_5E
	db $00, $00
	dw SoundPart_5F
	db $00, $03
	dw SoundPart_60
	db $34, $00
	dw SoundPart_61
	db $4e, $01
	dw SoundPart_62
	db $68, $03
	dw SoundPart_63
	db $00, $00
	dw SoundPart_64
	db $00, $00
	dw SoundPart_65
	db $00, $03
	dw SoundPart_66
	db $00, $00
	dw SoundPart_67
	db $00, $03
	dw SoundPart_68
	db $00, $00
	dw SoundPart_69
	db $1a, $01
	dw SoundPart_6A
	db $00, $00
	dw SoundPart_6B
	db $00, $03
	dw SoundPart_6C
	db $00, $03
	dw SoundPart_6D
	db $00, $03
	dw SoundPart_6E
	db $00, $00
	dw SoundPart_6F
	db $00, $00
	dw SoundPart_70
	db $00, $00
	dw SoundPart_71
	db $00, $00
	dw SoundPart_72
	db $00, $00
	dw SoundPart_73
	db $00, $00
	dw SoundPart_74
	db $1a, $03
	dw SoundPart_75
	db $00, $00
	dw SoundPart_76
	db $1a, $03
	dw SoundPart_77
	db $00, $00
	dw SoundPart_78
	db $1a, $03
	dw SoundPart_79
	db $00, $00
	dw SoundPart_7A
	db $00, $03
	dw SoundPart_7B
	db $00, $00
	dw SoundPart_7C
	db $1a, $03
	dw SoundPart_7D
	db $00, $03
	dw SoundPart_7E
	db $00, $03
	dw SoundPart_7F
	db $00, $00
	dw SoundPart_80
	db $00, $03
	dw SoundPart_81
	db $00, $03
	dw SoundPart_82
	db $00, $03
	dw SoundPart_83
	db $00, $03
	dw SoundPart_84
	db $00, $01
	dw SoundPart_85
	db $00, $00
	dw SoundPart_86
	db $1a, $01
	dw SoundPart_87
	db $00, $03
	dw SoundPart_88
	db $00, $03
	dw SoundPart_89
	db $00, $00
	dw SoundPart_8A
	db $1a, $03
	dw SoundPart_8B
	db $00, $03
	dw SoundPart_8C
	db $00, $03
	dw SoundPart_8D
	db $00, $03
	dw SoundPart_8E
	db $00, $03
	dw SoundPart_8F
	db $00, $00
	dw SoundPart_90
	db $1a, $03
	dw SoundPart_91
	db $00, $03
	dw SoundPart_92
	db $00, $03
	dw SoundPart_93
	db $00, $03
	dw SoundPart_94
	db $00, $03
	dw SoundPart_95
	db $00, $03
	dw SoundPart_96
	db $00, $00
	dw SoundPart_97
	db $1a, $03
	dw SoundPart_98
	db $00, $00
	dw SoundPart_99
	db $1a, $03
	dw SoundPart_9A
	db $00, $03
	dw SoundPart_9B
	db $00, $03
	dw SoundPart_9C
	db $34, $00
	dw SoundPart_9D
	db $4e, $01
	dw SoundPart_9E
	db $34, $00
	dw SoundPart_9F
	db $4e, $01
	dw SoundPart_A0
	db $68, $02
	dw SoundPart_A1

;@ path: sound/parts
;@ Sound part $37: events for channel 2 (hardware channel: pulse 1). First part of sound $37 (parts $37-$39 on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_37::
	db $04, $00, $0f
	db $00, $c1, $2f, $24, $0a, $a0, $06, $24, $04, $a0, $0f, $24, $04, $24, $08, $25
	db $08, $25, $08, $25, $08, $24, $08, $24, $08, $24, $08, $22, $08, $22, $08, $22
	db $08, $24, $06, $14, $06, $15, $06, $17, $06, $19, $06, $1b, $06, $20, $06, $22
	db $06, $24, $0e, $a0, $06, $24, $0c, $a0, $0f, $2b, $0c, $2b, $0d, $2b, $0f, $c3
	db $40, $34, $04, $37, $03, $34, $03, $37, $03, $b3, $fc, $24, $00, $a0, $0d, $34
	db $03, $37, $03, $b3, $fc, $29, $00, $34, $03, $37, $02, $c1, $7f, $a0, $06, $34
	db $18, $ff

;@ path: sound/parts
;@ Sound part $38: events for channel 3 (hardware channel: pulse 2). Part 2 of sound $37 (parts $37-$39 on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_38::
	db $04, $00, $0f, $00, $c1, $2f, $27, $0a, $a0, $06, $27, $04, $a0, $0f
	db $27, $04, $27, $08, $29, $08, $29, $08, $29, $08, $27, $08, $27, $08, $27, $08
	db $25, $08, $25, $08, $25, $08, $27, $06, $20, $06, $22, $06, $24, $06, $25, $06
	db $27, $06, $29, $06, $2b, $06, $30, $0e, $a0, $06, $30, $0c, $a0, $0f, $37, $0c
	db $37, $0d, $37, $0f, $c1, $fe, $40, $54, $c1, $30, $a0, $06, $40, $18, $ff

;@ path: sound/parts
;@ Sound part $39: events for channel 4 (hardware channel: wave). Part 3 of sound $37 (parts $37-$39 on channels
;@ 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep
;@ or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_39::
	db $04
	db $ff, $02, $03, $20, $62, $a0, $04, $20, $18, $1f, $59, $a0, $02, $a2, $30, $a1
	db $09, $20, $0f, $17, $0f, $20, $0f, $17, $0f, $a2, $ff, $20, $18, $a0, $06, $20
	db $18, $ff

;@ path: sound/parts
;@ Sound part $3A: events for channel 2 (hardware channel: pulse 1). First part of sound $3A (parts $3A-$3B on
;@ channels 2-3, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_3A::
	db $09, $02, $0f, $00, $c1, $60, $24, $04, $14, $03, $15, $03, $17, $03
	db $19, $03, $1b, $03, $20, $03, $22, $03, $c2, $15, $24, $06, $2b, $06, $c1, $1f
	db $34, $0c, $ff

;@ path: sound/parts
;@ Sound part $3B: events for channel 3 (hardware channel: pulse 2). Part 2 of sound $3A (parts $3A-$3B on
;@ channels 2-3, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_3B::
	db $09, $02, $0f, $00, $c1, $60, $27, $04, $20, $03, $22, $03, $24
	db $03, $25, $03, $27, $03, $29, $03, $2b, $03, $c2, $15, $30, $06, $37, $06, $c1
	db $1f, $40, $0c, $ff

;@ path: sound/parts
;@ Sound part $3C: events for channel 2 (hardware channel: pulse 1). First part of sound $3C (parts $3C-$3E on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_3C::
	db $05, $00, $0d, $00, $a0, $0f, $24, $04, $a0, $0d, $14, $03
	db $15, $03, $17, $03, $19, $03, $1b, $03, $20, $03, $22, $03, $a0, $0f, $24, $03
	db $a0, $0d, $20, $03, $22, $03, $24, $03, $25, $03, $27, $03, $29, $03, $2b, $03
	db $a0, $0f, $30, $03, $a0, $0d, $24, $03, $25, $03, $27, $03, $29, $03, $2b, $03
	db $30, $03, $32, $03, $a0, $0f, $34, $03, $a0, $0d, $24, $03, $25, $03, $27, $03
	db $a0, $0f, $29, $03, $2b, $03, $30, $03, $32, $03, $c1, $2f, $24, $0a, $a0, $06
	db $24, $04, $a0, $0f, $24, $04, $24, $08, $25, $08, $25, $08, $25, $08, $24, $08
	db $24, $08, $24, $08, $22, $08, $22, $08, $22, $08, $a0, $0d, $c1, $2f, $24, $09
	db $a0, $06, $24, $04, $a0, $0f, $24, $04, $24, $08, $25, $08, $25, $08, $25, $08
	db $24, $08, $24, $08, $24, $08, $22, $08, $22, $08, $22, $08, $a0, $0b, $24, $08
	db $20, $08, $24, $08, $27, $08, $24, $08, $27, $08, $30, $08, $27, $08, $30, $08
	db $34, $08, $30, $08, $34, $08, $a0, $0d, $c1, $2f, $38, $0b, $a0, $06, $c1, $1f
	db $38, $04, $a0, $0f, $38, $04, $c1, $2f, $38, $08, $34, $09, $34, $0a, $34, $0a
	db $33, $0b, $33, $0c, $33, $0d, $35, $0e, $35, $0f, $35, $10, $c3, $40, $34, $04
	db $37, $04, $34, $03, $37, $03, $34, $03, $37, $03, $34, $03, $37, $03, $b6, $fc
	db $71, $00, $34, $03, $37, $03, $34, $04, $37, $03, $34, $03, $37, $03, $34, $03
	db $37, $03, $34, $03, $37, $03, $34, $03, $37, $03, $34, $03, $37, $03, $34, $03
	db $37, $03, $34, $03, $37, $04, $c1, $60, $a0, $09, $34, $18, $a0, $03, $34, $18
	db $ff

;@ path: sound/parts
;@ Sound part $3D: events for channel 3 (hardware channel: pulse 2). Part 2 of sound $3C (parts $3C-$3E on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_3D::
	db $05, $00, $0f, $00, $27, $04, $20, $03, $22, $03, $24, $03, $25, $03, $27
	db $03, $29, $03, $2b, $03, $30, $03, $24, $03, $25, $03, $27, $03, $29, $03, $2b
	db $03, $30, $03, $32, $03, $34, $03, $27, $03, $29, $03, $2b, $03, $30, $03, $32
	db $03, $34, $03, $35, $03, $37, $03, $30, $03, $32, $03, $34, $03, $35, $03, $37
	db $03, $39, $03, $3b, $03, $c1, $2f, $27, $0a, $a0, $06, $27, $04, $a0, $0f, $27
	db $04, $27, $08, $29, $08, $29, $08, $29, $08, $27, $08, $27, $08, $27, $08, $25
	db $08, $25, $08, $25, $08, $a0, $0d, $c1, $2f, $27, $09, $a0, $06, $27, $04, $a0
	db $0f, $27, $04, $27, $08, $29, $08, $29, $08, $29, $08, $27, $08, $27, $08, $27
	db $08, $25, $08, $25, $08, $25, $08, $a0, $0b, $c1, $28, $27, $08, $24, $08, $27
	db $08, $30, $08, $27, $08, $30, $08, $34, $08, $30, $08, $34, $08, $37, $08, $34
	db $08, $37, $08, $c1, $20, $a0, $0d, $40, $0b, $a0, $06, $c1, $1f, $40, $04, $c1
	db $28, $a0, $0f, $40, $04, $40, $08, $c1, $2f, $37, $09, $37, $0a, $37, $0a, $38
	db $0b, $38, $0c, $38, $0d, $3a, $0e, $3a, $0f, $3a, $10, $c0, $fe, $40, $9b, $c1
	db $70, $40, $30, $ff

;@ path: sound/parts
;@ Sound part $3E: events for channel 4 (hardware channel: wave). Part 3 of sound $3C (parts $3C-$3E on channels
;@ 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep
;@ or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_3E::
	db $05, $ff, $02, $03, $20, $49, $a0, $04, $20, $18, $a0, $02
	db $50, $04, $52, $04, $50, $02, $52, $02, $50, $02, $52, $02, $50, $02, $52, $02
	db $50, $02, $52, $02, $50, $02, $52, $02, $50, $02, $52, $02, $50, $02, $52, $02
	db $50, $02, $52, $02, $50, $02, $52, $02, $50, $02, $52, $02, $50, $02, $52, $02
	db $b2, $fc, $12, $00, $50, $02, $52, $02, $50, $02, $52, $02, $50, $02, $52, $02
	db $50, $02, $52, $02, $50, $02, $52, $02, $50, $02, $52, $02, $b3, $fc, $20, $00
	db $50, $02, $52, $02, $50, $02, $52, $02, $50, $02, $52, $02, $50, $02, $52, $02
	db $50, $02, $52, $02, $50, $02, $52, $02, $b2, $fc, $2e, $00, $50, $02, $52, $02
	db $50, $02, $52, $02, $50, $02, $52, $02, $50, $02, $52, $02, $50, $02, $52, $02
	db $50, $02, $52, $01, $a2, $10, $43, $0b, $a0, $06, $43, $04, $a0, $02, $43, $04
	db $a2, $1f, $43, $08, $40, $09, $40, $0a, $40, $0a, $40, $0b, $40, $0c, $40, $0d
	db $42, $0e, $42, $0f, $42, $10, $a1, $0b, $a2, $40, $20, $11, $17, $11, $20, $11
	db $17, $11, $20, $12, $17, $12, $20, $18, $17, $1b, $a2, $50, $20, $18, $a0, $06
	db $20, $18, $ff

;@ path: sound/parts
;@ Sound part $3F: events for channel 0 (hardware channel: pulse 1). First part of sound effect $3F (parts
;@ $3F-$40, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_3F::
	db $04, $02, $0e, $00, $c1, $50, $36, $0c, $35, $0c, $34, $0c, $32
	db $0c, $c2, $15, $30, $0d, $26, $0d, $c1, $7f, $a0, $0d, $36, $18, $a0, $06, $c1
	db $30, $36, $18, $ff

;@ path: sound/parts
;@ Sound part $40: events for channel 1 (hardware channel: pulse 2). Part 2 of sound effect $3F (parts $3F-$40,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_40::
	db $04, $02, $0f, $00, $c1, $50, $42, $0c, $41, $0c, $40, $0c
	db $3b, $0c, $c2, $15, $39, $0d, $32, $0d, $c1, $7f, $a0, $0e, $42, $18, $a0, $07
	db $c1, $30, $42, $18, $ff

;@ path: sound/parts
;@ Sound part $41: events for channel 2 (hardware channel: pulse 1). First part of sound $41 (parts $41-$43 on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_41::
	db $05, $00, $0c, $00, $1f, $40, $c0, $fe, $29, $40, $27
	db $40, $a0, $08, $c1, $70, $27, $30, $ff

;@ path: sound/parts
;@ Sound part $42: events for channel 3 (hardware channel: pulse 2). Part 2 of sound $41 (parts $41-$43 on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_42::
	db $05, $00, $0f, $00, $a0, $04, $1f, $10
	db $14, $10, $17, $10, $20, $10, $a0, $0d, $c0, $fe, $30, $3c, $a0, $05, $c1, $20
	db $30, $04, $a0, $0d, $c0, $fe, $30, $40, $a0, $08, $c1, $70, $30, $30, $ff

;@ path: sound/parts
;@ Sound part $43: events for channel 4 (hardware channel: wave). Part 3 of sound $41 (parts $41-$43 on channels
;@ 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep
;@ or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_43::
	db $05
	db $ff, $02, $0c, $24, $10, $27, $10, $30, $10, $34, $10, $35, $20, $32, $20, $34
	db $40, $a2, $40, $a0, $04, $34, $20, $ff

;@ path: sound/parts
;@ Sound part $44: events for channel 2 (hardware channel: pulse 1). First part of sound $44 (parts $44-$46 on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_44::
	db $01, $00, $0f, $00, $c1, $60, $15, $12
	db $c1, $30, $a0, $0e, $29, $11, $29, $10, $30, $0f, $30, $0e, $2a, $0e, $2a, $0e
	db $29, $0e, $a0, $0f, $c1, $60, $22, $0f, $c1, $30, $a0, $0e, $29, $0f, $29, $0e
	db $29, $0e, $29, $0e, $26, $0e, $26, $0e, $26, $0e, $22, $07, $1a, $07, $20, $07
	db $22, $07, $24, $07, $25, $07, $27, $07, $29, $07, $2a, $0f, $22, $10, $25, $11
	db $32, $13, $c0, $fe, $31, $3e, $a0, $08, $c1, $70, $31, $0e, $c0, $fe, $a0, $0d
	db $34, $4c, $c1, $70, $a0, $08, $34, $1c, $ff

;@ path: sound/parts
;@ Sound part $45: events for channel 3 (hardware channel: pulse 2). Part 2 of sound $44 (parts $44-$46 on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_45::
	db $01, $00, $0f, $00, $c1, $30, $1f
	db $12, $35, $11, $35, $10, $34, $0f, $34, $0e, $32, $0e, $32, $0e, $30, $0e, $a0
	db $08, $30, $0f, $a0, $0d, $32, $0f, $32, $0e, $30, $0e, $30, $0e, $2a, $0e, $2a
	db $0e, $29, $0e, $27, $07, $22, $07, $24, $07, $25, $07, $27, $07, $29, $07, $2a
	db $07, $30, $07, $32, $0f, $2a, $10, $32, $11, $35, $13, $c0, $fe, $39, $3e, $a0
	db $08, $c1, $70, $39, $0e, $c0, $fe, $a0, $0d, $37, $4c, $c1, $70, $a0, $08, $37
	db $1c, $ff

;@ path: sound/parts
;@ Sound part $46: events for channel 4 (hardware channel: wave). Part 3 of sound $44 (parts $44-$46 on channels
;@ 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep
;@ or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_46::
	db $01, $30, $02, $02, $a2, $70, $a1, $09, $15, $12, $a1, $02, $a2, $30
	db $30, $11, $30, $10, $35, $10, $35, $0e, $35, $0e, $35, $0e, $35, $0e, $a1, $09
	db $a2, $70, $22, $0f, $a1, $02, $a2, $30, $36, $0f, $36, $0e, $36, $0e, $36, $0e
	db $32, $0e, $32, $0e, $30, $0e, $a1, $09, $a2, $ff, $17, $31, $a0, $04, $17, $07
	db $a0, $02, $27, $3c, $a0, $04, $27, $07, $a0, $02, $a2, $70, $29, $13, $24, $12
	db $21, $12, $19, $15, $a2, $ff, $20, $4c, $a0, $04, $20, $1c, $ff

;@ path: sound/parts
;@ Sound part $47: events for channel 0 (hardware channel: pulse 1). First part of sound effect $47 (parts
;@ $47-$48, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_47::
	db $07, $01, $0f
	db $00, $c2, $1f, $30, $04, $2b, $04, $2a, $04, $c2, $15, $29, $08, $27, $08, $2a
	db $08, $c1, $30, $29, $0c, $a0, $06, $29, $0c, $ff

;@ path: sound/parts
;@ Sound part $48: events for channel 1 (hardware channel: pulse 2). Part 2 of sound effect $47 (parts $47-$48,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_48::
	db $07, $01, $0f, $00, $c2, $1f
	db $35, $04, $35, $04, $35, $04, $c2, $15, $35, $08, $33, $08, $37, $08, $c1, $30
	db $35, $0c, $a0, $06, $35, $0c, $ff

;@ path: sound/parts
;@ Sound part $49: events for channel 0 (hardware channel: pulse 1). First part of sound effect $49 (parts
;@ $49-$4A, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_49::
	db $05, $00, $0e, $00, $c1, $50, $12, $04, $21
	db $04, $11, $04, $20, $04, $b3, $fc, $03, $00, $16, $0c, $17, $02, $18, $02, $10
	db $08, $a0, $08, $10, $14, $ff

;@ path: sound/parts
;@ Sound part $4A: events for channel 1 (hardware channel: pulse 2). Part 2 of sound effect $49 (parts $49-$4A,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_4A::
	db $05, $00, $0f, $00, $c1, $50, $02, $04, $11, $04
	db $01, $04, $10, $04, $b3, $fc, $03, $00, $06, $0c, $07, $02, $08, $02, $00, $08
	db $a0, $08, $00, $14, $ff

;@ path: sound/parts
;@ Sound part $4B: events for channel 2 (hardware channel: pulse 1). First part of sound $4B (parts $4B-$4C on
;@ channels 2-3, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_4B::
	db $05, $00, $0e, $00, $39, $08, $38, $04, $39, $02, $35
	db $02, $37, $02, $b3, $fc, $05, $00, $35, $02, $34, $02, $33, $02, $32, $02, $31
	db $02, $30, $02, $2b, $02, $2a, $02, $29, $02, $28, $02, $a0, $08, $27, $02, $26
	db $02, $a0, $04, $25, $02, $24, $02, $ff

;@ path: sound/parts
;@ Sound part $4C: events for channel 3 (hardware channel: pulse 2). Part 2 of sound $4B (parts $4B-$4C on
;@ channels 2-3, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_4C::
	db $05, $00, $0f, $00, $2a, $08, $32, $04
	db $2a, $02, $2b, $02, $28, $02, $b3, $fc, $05, $00, $2b, $02, $2a, $02, $29, $02
	db $28, $02, $27, $02, $26, $02, $25, $02, $24, $02, $23, $02, $22, $02, $a0, $08
	db $21, $02, $20, $02, $a0, $04, $1b, $02, $1a, $02, $ff

;@ path: sound/parts
;@ Sound part $4D: events for channel 2 (hardware channel: pulse 1). First part of sound $4D (parts $4D-$4E on
;@ channels 2-3, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_4D::
	db $05, $00, $0e, $00, $39
	db $08, $38, $04, $39, $02, $35, $02, $28, $02, $2b, $02, $22, $02, $35, $02, $37
	db $02, $3b, $02, $42, $02, $45, $02, $47, $02, $b3, $fc, $0d, $00, $45, $02, $44
	db $02, $43, $02, $42, $02, $41, $02, $40, $02, $3b, $02, $3a, $02, $39, $02, $38
	db $02, $a0, $06, $37, $02, $36, $02, $a0, $04, $35, $02, $34, $02, $ff

;@ path: sound/parts
;@ Sound part $4E: events for channel 3 (hardware channel: pulse 2). Part 2 of sound $4D (parts $4D-$4E on
;@ channels 2-3, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_4E::
	db $05, $00
	db $0f, $00, $2a, $08, $32, $04, $2a, $02, $2b, $02, $25, $02, $28, $02, $2b, $02
	db $32, $02, $35, $02, $38, $02, $35, $02, $3b, $02, $38, $02, $b3, $fc, $0d, $00
	db $3b, $02, $3a, $02, $39, $02, $38, $02, $37, $02, $36, $02, $35, $02, $34, $02
	db $33, $02, $32, $02, $a0, $06, $31, $02, $30, $02, $a0, $04, $2b, $02, $2a, $02
	db $ff

;@ path: sound/parts
;@ Sound part $4F: events for channel 0 (hardware channel: pulse 1). First part of sound effect $4F (parts
;@ $4F-$50, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_4F::
	db $0b, $00, $05, $00, $1f, $04, $35, $06, $22, $04, $29, $04, $35, $04, $34
	db $04, $21, $04, $29, $04, $34, $04, $32, $04, $1a, $04, $27, $04, $32, $04, $31
	db $04, $2a, $05, $29, $05, $28, $06, $29, $02, $28, $02, $29, $18, $ff

;@ path: sound/parts
;@ Sound part $50: events for channel 1 (hardware channel: pulse 2). Part 2 of sound effect $4F (parts $4F-$50,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_50::
	db $0b, $00
	db $0f, $00, $35, $06, $22, $04, $29, $04, $35, $04, $34, $04, $21, $04, $29, $04
	db $34, $04, $32, $04, $1a, $04, $27, $04, $32, $04, $31, $04, $2a, $05, $29, $05
	db $28, $06, $29, $02, $28, $02, $29, $18, $ff

;@ path: sound/parts
;@ Sound part $51: events for channel 0 (hardware channel: noise). Sound effect $51, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_51::
	db $00, $00, $0d, $00, $47, $05, $a0
	db $02, $47, $08, $a0, $0d, $43, $05, $a0, $02, $43, $08, $a0, $0d, $47, $05, $a0
	db $02, $47, $08, $a0, $0d, $43, $05, $a0, $03, $43, $09, $ff

;@ path: sound/parts
;@ Sound part $52: events for channel 0 (hardware channel: pulse 1). Sound effect $52, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_52::
	db $00, $02, $02, $00
	db $30, $02, $33, $02, $b5, $fc, $02, $00, $a0, $03, $30, $02, $33, $02, $b5, $fc
	db $07, $00, $a0, $04, $30, $02, $33, $02, $b5, $fc, $0c, $00, $a0, $05, $30, $02
	db $33, $02, $b5, $fc, $11, $00, $a0, $07, $30, $02, $33, $02, $b5, $fc, $16, $00
	db $a0, $09, $30, $02, $33, $02, $b5, $fc, $1b, $00, $a0, $0c, $30, $02, $33, $02
	db $b5, $fc, $20, $00, $a0, $0f, $31, $02, $33, $02, $ba, $fc, $25, $00, $a0, $0d
	db $31, $02, $34, $02, $ba, $fc, $2a, $00, $31, $02, $34, $02, $ba, $fc, $2e, $00
	db $a0, $09, $31, $02, $34, $02, $b6, $fc, $33, $00, $a0, $07, $31, $02, $34, $02
	db $b3, $fc, $38, $00, $a0, $04, $31, $02, $34, $02, $b5, $fc, $3d, $00, $a0, $03
	db $31, $02, $34, $02, $ba, $fc, $42, $00, $a0, $02, $31, $02, $34, $02, $b5, $fc
	db $47, $00, $ff, $ff

;@ path: sound/parts
;@ Sound part $53: events for channel 0 (hardware channel: pulse 1). Sound effect $53, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_53::
	db $00, $01, $0f, $37, $1b, $02, $1f, $01, $20, $01, $1f, $01
	db $21, $02, $a0, $05, $21, $03, $ff

;@ path: sound/parts
;@ Sound part $54: events for channel 0 (hardware channel: pulse 1). Sound effect $54, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_54::
	db $00, $00, $07, $00, $14, $02, $a0, $0a, $12
	db $02, $a0, $0f, $10, $04, $a0, $04, $10, $04, $ff

;@ path: sound/parts
;@ Sound part $55: events for channel 0 (hardware channel: pulse 1). Sound effect $55, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_55::
	db $00, $02, $0f, $17, $c1, $60
	db $29, $06, $a1, $2f, $42, $30, $ff

;@ path: sound/parts
;@ Sound part $56: events for channel 0 (hardware channel: noise). Sound effect $56, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_56::
	db $00, $00, $0f, $00, $13, $03, $37, $06, $a0
	db $04, $37, $02, $ff

;@ path: sound/parts
;@ Sound part $57: events for channel 0 (hardware channel: pulse 1). First part of sound effect $57 (parts
;@ $57-$58, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_57::
	db $00, $00, $0f, $17, $18, $12, $a1, $2f, $6b, $12, $a1, $17
	db $1f, $01, $18, $12, $a1, $2f, $6b, $12, $a0, $06, $6b, $12, $a0, $02, $6b, $12
	db $ff

;@ path: sound/parts
;@ Sound part $58: events for channel 1 (hardware channel: pulse 2). Part 2 of sound effect $57 (parts $57-$58,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_58::
	db $00, $00, $0c, $17, $15, $01, $17, $01, $19, $01, $20, $01, $23, $01, $25
	db $01, $27, $01, $29, $01, $2b, $01, $30, $01, $33, $01, $35, $01, $37, $01, $39
	db $01, $3b, $01, $40, $01, $42, $01, $44, $01, $46, $01, $48, $01, $4b, $01, $50
	db $01, $4b, $01, $49, $01, $47, $01, $45, $01, $43, $01, $41, $01, $3b, $01, $39
	db $01, $37, $01, $35, $01, $33, $01, $30, $01, $b1, $fc, $02, $00, $a0, $04, $52
	db $01, $50, $01, $4b, $01, $49, $01, $47, $01, $45, $01, $43, $01, $41, $01, $3b
	db $01, $39, $01, $37, $01, $35, $01, $33, $01, $30, $01, $a0, $02, $52, $01, $50
	db $01, $4b, $01, $49, $01, $47, $01, $45, $01, $43, $01, $41, $01, $3b, $01, $39
	db $01, $37, $01, $35, $01, $33, $01, $30, $01, $ff

;@ path: sound/parts
;@ Sound part $59: events for channel 0 (hardware channel: pulse 1). Sound effect $59, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_59::
	db $00, $02, $0f, $00, $57, $02
	db $a0, $03, $57, $04, $ff

;@ path: sound/parts
;@ Sound part $5A: events for channel 0 (hardware channel: pulse 1). Sound effect $5A, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_5A::
	db $00, $02, $0f, $00, $30, $01, $ff

;@ path: sound/parts
;@ Sound part $5B: events for channel 0 (hardware channel: pulse 1). Sound effect $5B, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_5B::
	db $00, $02, $0f, $00
	db $29, $01, $ff

;@ path: sound/parts
;@ Sound part $5C: events for channel 0 (hardware channel: pulse 1). Sound effect $5C, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_5C::
	db $00, $00, $0f, $00, $50, $02, $1f, $01, $56, $02, $1f, $01, $50
	db $02, $1f, $01, $56, $02, $1f, $01, $a0, $05, $50, $02, $1f, $01, $56, $02, $a0
	db $02, $56, $04, $ff

;@ path: sound/parts
;@ Sound part $5D: events for channel 2 (hardware channel: pulse 1). First part of sound $5D (parts $5D-$5E on
;@ channels 2-3, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_5D::
	db $00, $00, $07, $00, $a2, $00, $a5, $0f, $1f, $30, $a0, $08
	db $60, $01, $c1, $7f, $61, $58, $a5, $f0, $a2, $02, $a0, $06, $61, $40, $1f, $23
	db $a0, $08, $60, $01, $61, $58, $1f, $78, $a5, $0f, $1f, $2a, $c1, $7f, $60, $01
	db $a0, $08, $61, $40, $1f, $78, $a5, $f0, $60, $01, $a0, $08, $c1, $7f, $a0, $07
	db $61, $40, $1f, $49, $1f, $98, $b0, $fc, $02, $00, $ff

;@ path: sound/parts
;@ Sound part $5E: events for channel 3 (hardware channel: pulse 2). Part 2 of sound $5D (parts $5D-$5E on
;@ channels 2-3, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_5E::
	db $00, $00, $07, $00, $a5
	db $f0, $a0, $05, $c1, $0f, $60, $01, $a0, $0e, $61, $08, $1f, $01, $a0, $0b, $61
	db $08, $a0, $0c, $61, $08, $a0, $09, $c0, $fe, $60, $01, $a0, $0f, $61, $18, $c1
	db $7f, $a0, $08, $61, $40, $1f, $90, $ae, $10, $a5, $0f, $c1, $0f, $a0, $05, $5b
	db $01, $a0, $08, $60, $08, $1f, $01, $a0, $09, $60, $08, $a0, $07, $60, $08, $a0
	db $06, $c0, $fe, $5b, $01, $a0, $07, $60, $18, $c1, $7f, $a0, $06, $60, $40, $1f
	db $70, $1f, $70, $ae, $00, $a5, $ff, $a0, $05, $c1, $0f, $60, $01, $a0, $0a, $61
	db $08, $1f, $01, $a0, $08, $61, $08, $a0, $0a, $61, $08, $a0, $09, $c0, $fe, $60
	db $01, $a0, $0c, $61, $18, $c1, $7f, $a0, $08, $61, $40, $1f, $70, $a5, $0f, $a0
	db $09, $c0, $fe, $60, $01, $a0, $08, $61, $19, $c1, $7f, $a0, $07, $61, $40, $1f
	db $30, $b0, $fc, $02, $00, $ff

;@ path: sound/parts
;@ Sound part $5F: events for channel 0 (hardware channel: pulse 1). Sound effect $5F, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_5F::
	db $00, $02, $0f, $17, $22, $02, $a1, $16, $1f, $03
	db $27, $04, $ff

;@ path: sound/parts
;@ Sound part $60: events for channel 0 (hardware channel: noise). Sound effect $60, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_60::
	db $00, $00, $0f, $00, $51, $02, $1f, $01, $23, $02, $1f, $02, $15
	db $02, $a0, $04, $15, $05, $ff

;@ path: sound/parts
;@ Sound part $61: events for channel 2 (hardware channel: pulse 1). First part of sound $61 (parts $61-$63 on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_61::
	db $00, $02, $0f, $00, $a3, $20, $a2, $02, $a0, $05
	db $a5, $ff, $1f, $08, $58, $01, $59, $01, $5a, $01, $5b, $01, $60, $01, $5b, $01
	db $58, $01, $59, $01, $5a, $01, $5b, $01, $60, $01, $5b, $01, $5a, $01, $59, $01
	db $58, $01, $57, $01, $56, $01, $55, $01, $54, $01, $53, $01, $52, $01, $51, $01
	db $50, $01, $4b, $01, $4a, $01, $49, $01, $a5, $f0, $1f, $10, $5a, $01, $5b, $01
	db $60, $01, $5b, $01, $5a, $01, $5b, $01, $60, $01, $61, $01, $62, $01, $61, $01
	db $59, $01, $60, $01, $61, $01, $62, $01, $63, $01, $62, $01, $62, $01, $60, $01
	db $5b, $01, $5a, $01, $59, $01, $58, $01, $57, $01, $56, $01, $55, $01, $54, $01
	db $53, $01, $52, $01, $51, $01, $50, $01, $4b, $01, $4a, $01, $49, $01, $48, $01
	db $1f, $22, $a5, $0f, $64, $01, $63, $01, $62, $01, $61, $01, $60, $01, $5b, $01
	db $5a, $01, $59, $01, $60, $01, $5b, $01, $62, $01, $61, $01, $61, $01, $5b, $01
	db $58, $01, $57, $01, $56, $01, $55, $01, $54, $01, $53, $01, $52, $01, $51, $01
	db $50, $01, $4b, $01, $4a, $01, $49, $01, $1f, $1c, $a5, $f0, $62, $01, $61, $01
	db $60, $01, $5b, $01, $5a, $01, $59, $01, $56, $01, $55, $01, $54, $01, $53, $01
	db $52, $01, $51, $01, $52, $01, $53, $01, $54, $01, $55, $01, $56, $01, $57, $01
	db $56, $01, $55, $01, $54, $01, $53, $01, $52, $01, $50, $01, $4b, $01, $4a, $01
	db $49, $01, $48, $01, $1f, $1d, $a2, $01, $a0, $0a, $a5, $f0, $68, $01, $69, $01
	db $6a, $01, $6b, $01, $6a, $01, $69, $01, $68, $01, $67, $01, $66, $01, $65, $01
	db $64, $01, $63, $01, $62, $01, $61, $01, $60, $01, $5b, $01, $5a, $01, $59, $01
	db $58, $01, $57, $01, $56, $01, $55, $01, $54, $01, $53, $01, $52, $01, $51, $01
	db $50, $01, $4b, $01, $4a, $01, $49, $01, $48, $01, $48, $01, $b0, $fc, $03, $00
	db $ff

;@ path: sound/parts
;@ Sound part $62: events for channel 3 (hardware channel: pulse 2). Part 2 of sound $61 (parts $61-$63 on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_62::
	db $00, $02, $0f, $00, $a2, $02, $a0, $0f, $a5, $ff, $58, $01, $59, $01, $5a
	db $01, $5b, $01, $60, $01, $5b, $01, $58, $01, $59, $01, $5a, $01, $5b, $01, $60
	db $01, $5b, $01, $5a, $01, $59, $01, $58, $01, $57, $01, $56, $01, $55, $01, $54
	db $01, $53, $01, $52, $01, $51, $01, $50, $01, $4b, $01, $4a, $01, $49, $01, $a5
	db $f0, $1f, $10, $5a, $01, $5b, $01, $60, $01, $5b, $01, $5a, $01, $5b, $01, $60
	db $01, $61, $01, $62, $01, $61, $01, $59, $01, $60, $01, $61, $01, $62, $01, $63
	db $01, $62, $01, $62, $01, $60, $01, $5b, $01, $5a, $01, $59, $01, $58, $01, $57
	db $01, $56, $01, $55, $01, $54, $01, $53, $01, $52, $01, $51, $01, $50, $01, $4b
	db $01, $4a, $01, $49, $01, $48, $01, $1f, $22, $a0, $0d, $a5, $0f, $64, $01, $63
	db $01, $62, $01, $61, $01, $60, $01, $5b, $01, $5a, $01, $59, $01, $60, $01, $5b
	db $01, $62, $01, $61, $01, $61, $01, $5b, $01, $58, $01, $57, $01, $56, $01, $55
	db $01, $54, $01, $53, $01, $52, $01, $51, $01, $50, $01, $4b, $01, $4a, $01, $49
	db $01, $1f, $1c, $a0, $0f, $a5, $f0, $62, $01, $61, $01, $60, $01, $5b, $01, $5a
	db $01, $59, $01, $56, $01, $55, $01, $54, $01, $53, $01, $52, $01, $51, $01, $52
	db $01, $53, $01, $54, $01, $55, $01, $56, $01, $57, $01, $56, $01, $55, $01, $54
	db $01, $53, $01, $52, $01, $50, $01, $4b, $01, $4a, $01, $49, $01, $48, $01, $1f
	db $09, $a0, $0c, $a5, $0f, $5a, $01, $5b, $01, $60, $01, $61, $01, $62, $01, $63
	db $01, $64, $01, $65, $01, $66, $01, $65, $01, $64, $01, $63, $01, $62, $01, $61
	db $01, $60, $01, $60, $01, $5b, $01, $5a, $01, $59, $01, $58, $01, $57, $01, $56
	db $01, $55, $01, $54, $01, $53, $01, $52, $01, $51, $01, $50, $01, $4b, $01, $4a
	db $01, $49, $01, $48, $01, $47, $01, $46, $01, $45, $01, $44, $01, $1f, $18, $b0
	db $fc, $03, $00, $ff

;@ path: sound/parts
;@ Sound part $63: events for channel 4 (hardware channel: noise). Part 3 of sound $61 (parts $61-$63 on channels
;@ 2-4, started together by PlayMusic or PlaySound). Asked for directly, PlaySound($63) starts it and part $64. A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_63::
	db $00, $00, $0f, $00, $a3, $3a, $21, $60, $30, $60, $21, $44
	db $b0, $fc, $03, $00, $ff

;@ path: sound/parts
;@ Sound part $64: events for channel 0 (hardware channel: pulse 1). Sound effect $64, a single part;
;@ PlaySound($63) also starts it after part $63. A 4-byte header (tempo, duty or wave length, envelope, sweep or
;@ wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_64::
	db $00, $00, $0f, $1f, $44, $03, $43, $03, $42, $03, $44
	db $03, $a1, $1e, $47, $02, $a0, $06, $47, $03, $1f, $05, $a0, $0f, $a1, $27, $34
	db $02, $32, $03, $1f, $02, $41, $03, $1f, $02, $a0, $06, $41, $03, $1f, $03, $a0
	db $03, $41, $03, $ff

;@ path: sound/parts
;@ Sound part $65: events for channel 0 (hardware channel: pulse 1). Sound effect $65, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_65::
	db $00, $01, $0f, $00, $c2, $40, $ae, $10, $30, $05, $ae, $00
	db $33, $05, $31, $05, $34, $05, $32, $05, $35, $05, $36, $05, $a0, $04, $36, $0a
	db $ff

;@ path: sound/parts
;@ Sound part $66: events for channel 0 (hardware channel: noise). Sound effect $66, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_66::
	db $00, $00, $0f, $00, $12, $02, $1f, $02, $c7, $30, $10, $18, $a0, $07, $10
	db $10, $a0, $05, $10, $20, $ff

;@ path: sound/parts
;@ Sound part $67: events for channel 0 (hardware channel: pulse 1). Sound effect $67, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_67::
	db $00, $01, $0f, $00, $45, $02, $46, $02, $44, $02
	db $45, $02, $46, $02, $44, $02, $a0, $07, $46, $02, $44, $02, $ff

;@ path: sound/parts
;@ Sound part $68: events for channel 0 (hardware channel: noise). Sound effect $68, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_68::
	db $00, $00, $0f
	db $00, $33, $02, $62, $03, $1f, $01, $42, $02, $51, $02, $1f, $01, $b0, $fc, $02
	db $00, $ff

;@ path: sound/parts
;@ Sound part $69: events for channel 0 (hardware channel: pulse 1). First part of sound effect $69 (parts
;@ $69-$6A, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_69::
	db $00, $02, $0f, $00, $10, $03, $17, $03, $20, $03, $22, $02, $24, $02
	db $25, $02, $27, $02, $29, $02, $2a, $02, $30, $02, $32, $02, $34, $02, $35, $02
	db $37, $02, $39, $02, $3a, $02, $c1, $30, $40, $15, $a0, $05, $40, $10, $ff

;@ path: sound/parts
;@ Sound part $6A: events for channel 1 (hardware channel: pulse 2). Part 2 of sound effect $69 (parts $69-$6A,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_6A::
	db $00
	db $02, $05, $00, $1f, $03, $10, $03, $17, $03, $20, $03, $22, $02, $24, $02, $25
	db $02, $27, $02, $29, $02, $2a, $02, $30, $02, $32, $02, $34, $02, $35, $02, $37
	db $02, $39, $02, $3a, $02, $c1, $40, $a3, $0d, $40, $25, $ff

;@ path: sound/parts
;@ Sound part $6B: events for channel 0 (hardware channel: pulse 1). Sound effect $6B, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_6B::
	db $00, $01, $0f, $00
	db $32, $02, $2b, $02, $33, $02, $32, $02, $2b, $02, $33, $02, $a0, $07, $33, $02
	db $2b, $02, $33, $02, $ff

;@ path: sound/parts
;@ Sound part $6C: events for channel 0 (hardware channel: noise). Sound effect $6C, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_6C::
	db $00, $00, $0f, $00, $50, $04, $51, $04, $61, $03, $a0
	db $03, $50, $03, $ff

;@ path: sound/parts
;@ Sound part $6D: events for channel 0 (hardware channel: noise). Sound effect $6D, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_6D::
	db $00, $00, $0f, $00, $47, $04, $1f, $02, $43, $03, $1f, $02
	db $47, $04, $1f, $02, $43, $04, $1f, $02, $44, $04, $1f, $02, $34, $04, $ff

;@ path: sound/parts
;@ Sound part $6E: events for channel 0 (hardware channel: noise). Sound effect $6E, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_6E::
	db $00
	db $00, $0f, $00, $50, $02, $33, $06, $50, $02, $33, $06, $50, $02, $33, $06, $60
	db $03, $ff

;@ path: sound/parts
;@ Sound part $6F: events for channel 0 (hardware channel: pulse 1). Sound effect $6F, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_6F::
	db $00, $02, $0f, $00, $3b, $04, $39, $04, $35, $04, $a0, $07, $35, $05
	db $ff

;@ path: sound/parts
;@ Sound part $70: events for channel 0 (hardware channel: pulse 1). Sound effect $70, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_70::
	db $00, $01, $0f, $00, $45, $02, $49, $02, $50, $02, $54, $02, $50, $02, $54
	db $02, $49, $02, $50, $02, $a0, $0b, $45, $02, $49, $02, $50, $02, $54, $02, $a0
	db $09, $50, $02, $54, $02, $49, $02, $50, $02, $a0, $05, $45, $02, $49, $02, $50
	db $02, $54, $02, $a0, $03, $50, $02, $54, $02, $49, $02, $50, $02, $ff

;@ path: sound/parts
;@ Sound part $71: events for channel 0 (hardware channel: pulse 1). Sound effect $71, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_71::
	db $00, $02
	db $0f, $26, $a0, $0c, $0a, $14, $a1, $00, $c1, $3f, $a0, $0e, $ae, $10, $15, $14
	db $a0, $04, $15, $04, $a0, $02, $15, $02, $ff

;@ path: sound/parts
;@ Sound part $72: events for channel 0 (hardware channel: pulse 1). Sound effect $72, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_72::
	db $00, $02, $0f, $2e, $47, $05, $44
	db $07, $a0, $0c, $40, $06, $38, $06, $a0, $0a, $35, $06, $33, $06, $a0, $07, $2b
	db $05, $ff

;@ path: sound/parts
;@ Sound part $73: events for channel 0 (hardware channel: pulse 1). Sound effect $73, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_73::
	db $00, $02, $0f, $1f, $38, $03, $a1, $17, $a0, $0e, $33, $03, $1f, $01
	db $a0, $0e, $a1, $1f, $38, $03, $a1, $17, $a0, $0c, $33, $03, $1f, $01, $a0, $0d
	db $a1, $1f, $38, $03, $a1, $17, $a0, $0b, $33, $03, $1f, $01, $a0, $0c, $a1, $1f
	db $38, $03, $a1, $17, $a0, $0a, $33, $03, $1f, $01, $a0, $0a, $a1, $1f, $38, $03
	db $a1, $17, $a0, $08, $33, $03, $a0, $08, $a1, $1f, $38, $03, $a1, $17, $a0, $06
	db $33, $03, $a0, $06, $a1, $1f, $38, $03, $a1, $17, $a0, $05, $33, $03, $a0, $04
	db $a1, $1f, $38, $03, $a1, $17, $33, $03, $a0, $02, $a1, $1f, $38, $03, $a1, $17
	db $33, $03, $ff, $00, $00, $00, $00, $ff

;@ path: sound/parts
;@ Sound part $74: events for channel 0 (hardware channel: pulse 1). First part of sound effect $74 (parts
;@ $74-$75, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_74::
	db $00, $00, $0f, $23, $ae, $10, $19, $01
	db $ae, $00, $16, $01, $ae, $10, $19, $01, $ae, $00, $16, $02, $a0, $0c, $ae, $10
	db $19, $01, $ae, $00, $16, $01, $a0, $0a, $ae, $10, $19, $01, $ae, $00, $16, $02
	db $a0, $09, $ae, $10, $19, $01, $ae, $00, $16, $02, $a0, $07, $ae, $10, $19, $01
	db $ae, $00, $16, $02, $ae, $10, $a0, $04, $19, $01, $ae, $00, $16, $01, $ae, $10
	db $18, $01, $ae, $10, $1b, $01, $17, $01, $16, $01, $ae, $00, $ff, $ff

;@ path: sound/parts
;@ Sound part $75: events for channel 1 (hardware channel: noise). Part 2 of sound effect $74 (parts $74-$75,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_75::
	db $00, $00
	db $0f, $00, $27, $02, $27, $02, $a0, $05, $27, $08, $ff, $ff

;@ path: sound/parts
;@ Sound part $76: events for channel 0 (hardware channel: pulse 1). First part of sound effect $76 (parts
;@ $76-$77, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_76::
	db $00, $00, $0f, $23
	db $ae, $10, $19, $01, $ae, $00, $16, $01, $ae, $10, $19, $01, $ae, $00, $16, $02
	db $a0, $0c, $ae, $10, $19, $01, $ae, $00, $16, $01, $a0, $0a, $ae, $10, $19, $01
	db $ae, $00, $16, $02, $a0, $09, $ae, $10, $19, $01, $ae, $00, $16, $02, $a0, $07
	db $ae, $10, $19, $01, $ae, $00, $16, $02, $ae, $10, $18, $02, $ae, $00, $19, $02
	db $ae, $10, $20, $02, $1f, $15, $a2, $01, $a1, $1d, $a0, $0f, $23, $01, $21, $01
	db $22, $01, $39, $02, $37, $02, $36, $02, $35, $02, $34, $02, $33, $02, $32, $02
	db $31, $02, $31, $02, $3b, $02, $2a, $02, $29, $02, $28, $02, $27, $02, $26, $02
	db $25, $02, $24, $02, $23, $02, $22, $02, $21, $02, $20, $02, $1a, $02, $a0, $06
	db $18, $02, $16, $02, $14, $02, $12, $02, $10, $02, $0a, $02, $08, $02, $06, $02
	db $ff, $ff, $ff, $ff

;@ path: sound/parts
;@ Sound part $77: events for channel 1 (hardware channel: noise). Part 2 of sound effect $76 (parts $76-$77,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_77::
	db $00, $00, $0f, $00, $27, $02, $27, $02, $a0, $05, $27, $06
	db $ff, $ff

;@ path: sound/parts
;@ Sound part $78: events for channel 0 (hardware channel: pulse 1). First part of sound effect $78 (parts
;@ $78-$79, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_78::
	db $00, $00, $0f, $23, $ae, $10, $20, $01, $ae, $00, $19, $01, $ae, $10
	db $20, $01, $ae, $00, $19, $02, $ae, $10, $22, $01, $ae, $00, $22, $01, $ae, $10
	db $19, $01, $ae, $00, $16, $02, $a0, $09, $ae, $10, $19, $01, $ae, $00, $16, $02
	db $a0, $07, $ae, $10, $19, $01, $ae, $00, $16, $02, $a2, $01, $a1, $1d, $a0, $0f
	db $ae, $00, $26, $01, $ae, $10, $24, $01, $ae, $00, $24, $01, $ae, $10, $22, $01
	db $ae, $00, $20, $02, $ae, $10, $24, $01, $ae, $00, $22, $01, $ae, $00, $22, $01
	db $ae, $10, $20, $01, $ae, $00, $19, $02, $ae, $10, $20, $01, $ae, $00, $22, $01
	db $ae, $10, $20, $01, $ae, $00, $22, $02, $ae, $00, $16, $02, $ae, $00, $22, $02
	db $ae, $00, $19, $02, $ae, $00, $22, $02, $ae, $00, $19, $02, $ae, $00, $22, $02
	db $ae, $00, $19, $02, $ae, $10, $14, $01, $ae, $00, $10, $02, $ae, $10, $14, $01
	db $ae, $00, $10, $02, $ae, $10, $14, $01, $ae, $00, $10, $02, $ae, $10, $14, $01
	db $ae, $00, $10, $02, $ae, $10, $14, $01, $ae, $00, $10, $02, $a0, $09, $ae, $10
	db $14, $01, $ae, $00, $10, $02, $ae, $10, $14, $01, $ae, $00, $10, $02, $ae, $10
	db $14, $01, $ae, $00, $10, $02, $ae, $10, $06, $02, $ff, $ff

;@ path: sound/parts
;@ Sound part $79: events for channel 1 (hardware channel: noise). Part 2 of sound effect $78 (parts $78-$79,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_79::
	db $00, $00, $0f, $00
	db $37, $02, $37, $02, $a0, $08, $37, $06, $ff, $ff

;@ path: sound/parts
;@ Sound part $7A: events for channel 0 (hardware channel: pulse 1). Sound effect $7A, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_7A::
	db $00, $01, $0f, $1d, $a2, $01
	db $a1, $1d, $ae, $10, $20, $01, $ae, $00, $19, $01, $ae, $10, $20, $01, $ae, $00
	db $19, $02, $ae, $10, $22, $01, $ae, $00, $22, $01, $ae, $10, $19, $01, $ae, $00
	db $16, $02, $a0, $09, $ae, $10, $19, $01, $ae, $00, $16, $02, $a0, $07, $ae, $10
	db $19, $01, $ae, $00, $16, $02, $a0, $0f, $ae, $00, $26, $01, $ae, $10, $24, $01
	db $ae, $00, $26, $01, $ae, $10, $24, $01, $ae, $00, $26, $02, $ae, $10, $24, $01
	db $ae, $00, $26, $01, $ae, $00, $22, $01, $ae, $10, $24, $01, $ae, $00, $26, $02
	db $ae, $10, $24, $01, $ae, $00, $26, $01, $ae, $10, $24, $01, $ae, $00, $26, $02
	db $ae, $00, $28, $02, $ae, $00, $27, $02, $ae, $00, $28, $02, $ae, $00, $27, $02
	db $ae, $00, $28, $02, $ae, $00, $27, $02, $ae, $00, $29, $02, $ae, $10, $28, $01
	db $ae, $00, $29, $02, $ae, $10, $28, $01, $ae, $00, $29, $02, $ae, $10, $28, $01
	db $ae, $00, $29, $02, $ae, $10, $28, $01, $ae, $00, $29, $02, $ae, $10, $28, $01
	db $ae, $00, $29, $02, $1f, $01, $a0, $09, $ae, $10, $2a, $01, $ae, $00, $2b, $02
	db $ae, $10, $28, $01, $ae, $00, $29, $02, $ae, $10, $28, $01, $ae, $00, $29, $02
	db $ae, $10, $28, $01, $a0, $03, $ae, $10, $25, $01, $ae, $00, $26, $02, $ae, $10
	db $25, $01, $ae, $00, $26, $02, $ae, $10, $25, $01, $ae, $00, $26, $02, $ff, $ff
;@ path: sound/parts
;@ Sound part $7B: events for channel 0 (hardware channel: noise). Sound effect $7B, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_7B::
	db $00, $00, $0f, $00, $11, $02, $45, $03, $15, $01, $50, $03, $45, $03, $16, $01
	db $45, $02, $55, $02, $14, $01, $45, $02, $45, $06, $a0, $06, $45, $05, $a0, $04
	db $45, $05, $ff, $ff

;@ path: sound/parts
;@ Sound part $7C: events for channel 0 (hardware channel: pulse 1). First part of sound effect $7C (parts
;@ $7C-$7D, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_7C::
	db $00, $00, $0f, $17, $a0, $08, $23, $02, $24, $02, $25, $02
	db $26, $02, $a0, $0b, $27, $02, $28, $02, $29, $02, $2a, $02, $a0, $0d, $2b, $02
	db $30, $02, $31, $02, $32, $02, $33, $03, $34, $02, $35, $02, $a0, $09, $35, $02
	db $a0, $0f, $1f, $02, $ff, $ff

;@ path: sound/parts
;@ Sound part $7D: events for channel 1 (hardware channel: noise). Part 2 of sound effect $7C (parts $7C-$7D,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_7D::
	db $00, $00, $0f, $00, $1f, $20, $11, $02, $45, $03
	db $15, $01, $50, $03, $45, $03, $16, $01, $45, $02, $55, $02, $14, $01, $45, $02
	db $45, $06, $a0, $0b, $45, $05, $45, $05, $a0, $0e, $55, $02, $14, $01, $45, $02
	db $45, $06, $a0, $06, $45, $05, $45, $05, $a0, $08, $55, $02, $14, $01, $45, $02
	db $45, $06, $45, $05, $a0, $04, $45, $05, $ff, $ff

;@ path: sound/parts
;@ Sound part $7E: events for channel 0 (hardware channel: noise). Sound effect $7E, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_7E::
	db $00, $00, $0f, $00, $c3, $07
	db $21, $05, $23, $05, $c0, $fe, $23, $05, $22, $08, $22, $07, $a0, $08, $c7, $30
	db $22, $20, $ff, $ff

;@ path: sound/parts
;@ Sound part $7F: events for channel 0 (hardware channel: noise). Sound effect $7F, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_7F::
	db $00, $00, $0f, $00, $11, $06, $13, $04, $22, $03, $23, $04
	db $23, $07, $22, $07, $12, $07, $11, $18, $a0, $0b, $11, $10, $a0, $0e, $11, $10
	db $a0, $0a, $11, $08, $c1, $20, $a0, $06, $11, $20, $ff, $ff

;@ path: sound/parts
;@ Sound part $80: events for channel 0 (hardware channel: pulse 1). Sound effect $80, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_80::
	db $00, $00, $0f, $14
	db $ae, $10, $30, $02, $2b, $03, $1f, $02, $28, $03, $2b, $03, $1f, $02, $2b, $04
	db $1f, $02, $28, $02, $1a, $03, $2f, $01, $1a, $03, $1f, $02, $29, $01, $18, $02
	db $1f, $02, $27, $01, $17, $02, $26, $01, $25, $02, $24, $01, $23, $02, $1f, $01
	db $22, $01, $21, $02, $20, $01, $1b, $01, $1a, $01, $19, $01, $18, $01, $17, $01
	db $1f, $01, $16, $01, $15, $01, $14, $01, $a0, $08, $1f, $01, $15, $01, $17, $01
	db $19, $01, $a0, $06, $1f, $02, $18, $01, $1b, $01, $17, $01, $1a, $01, $18, $01
	db $1b, $02, $14, $01, $a0, $04, $1f, $02, $18, $01, $1b, $01, $18, $01, $1f, $02
	db $1a, $01, $18, $01, $1f, $02, $14, $01, $19, $01, $1b, $01, $19, $01, $1a, $01
	db $ff, $ff

;@ path: sound/parts
;@ Sound part $81: events for channel 0 (hardware channel: noise). Sound effect $81, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_81::
	db $00, $00, $0f, $00, $21, $08, $31, $05, $20, $05, $10, $03, $20, $04
	db $40, $05, $40, $05, $30, $03, $23, $05, $40, $06, $21, $08, $30, $04, $21, $05
	db $30, $05, $21, $02, $20, $07, $a0, $08, $c1, $20, $20, $08, $ff, $ff

;@ path: sound/parts
;@ Sound part $82: events for channel 0 (hardware channel: noise). Sound effect $82, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_82::
	db $00, $00
	db $0f, $00, $20, $07, $12, $08, $11, $08, $1f, $01, $50, $04, $60, $10, $c7, $20
	db $a0, $06, $60, $20, $ff, $ff

;@ path: sound/parts
;@ Sound part $83: events for channel 0 (hardware channel: noise). Sound effect $83, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_83::
	db $00, $00, $0f, $00, $45, $02, $11, $02, $1f, $01
	db $c3, $20, $45, $10, $30, $09, $c7, $30, $50, $06, $43, $08, $60, $20, $ff, $ff
;@ path: sound/parts
;@ Sound part $84: events for channel 0 (hardware channel: noise). Sound effect $84, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_84::
	db $00, $02, $0f, $15, $08, $06, $09, $04, $10, $03, $09, $05, $a0, $06, $10, $05
	db $08, $04, $09, $05, $a0, $04, $09, $05, $0b, $03, $ff, $ff

;@ path: sound/parts
;@ Sound part $85: events for channel 0 (hardware channel: pulse 2). Sound effect $85, a single part (PlaySound).
;@ A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_85::
	db $00, $02, $0f, $2f
	db $12, $02, $19, $02, $12, $03, $1a, $05, $10, $05, $a0, $08, $10, $04, $a0, $06
	db $10, $05, $ff, $ff

;@ path: sound/parts
;@ Sound part $86: events for channel 0 (hardware channel: pulse 1). First part of sound effect $86 (parts
;@ $86-$87, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_86::
	db $00, $01, $0f, $00, $a3, $14, $49, $01, $4a, $02, $49, $02
	db $a0, $06, $c7, $20, $4b, $25, $ff, $ff

;@ path: sound/parts
;@ Sound part $87: events for channel 1 (hardware channel: pulse 2). Part 2 of sound effect $86 (parts $86-$87,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_87::
	db $00, $01, $0f, $00, $a3, $14, $4b, $01
	db $49, $01, $4a, $02, $4b, $10, $c7, $20, $4b, $10, $ff, $ff

;@ path: sound/parts
;@ Sound part $88: events for channel 0 (hardware channel: noise). Sound effect $88, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_88::
	db $00, $00, $0f, $00
	db $c7, $30, $50, $02, $a0, $0f, $40, $02, $12, $08, $30, $02, $12, $09, $40, $02
	db $12, $08, $a0, $0f, $40, $02, $1f, $01, $12, $0c, $a0, $06, $12, $10, $ff, $ff
;@ path: sound/parts
;@ Sound part $89: events for channel 0 (hardware channel: noise). Sound effect $89, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_89::
	db $00, $00, $0f, $00, $43, $02, $50, $02, $1f, $01, $42, $07, $a0, $08, $42, $07
	db $a0, $04, $42, $07, $ff, $ff

;@ path: sound/parts
;@ Sound part $8A: events for channel 0 (hardware channel: pulse 1). First part of sound effect $8A (parts
;@ $8A-$8B, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_8A::
	db $00, $00, $0f, $23, $ae, $10, $20, $01, $ae, $00
	db $19, $01, $ae, $10, $20, $01, $ae, $00, $19, $02, $ae, $10, $22, $01, $ae, $00
	db $22, $01, $ae, $10, $19, $01, $ae, $00, $16, $02, $a0, $09, $ae, $10, $19, $01
	db $ae, $00, $16, $02, $a0, $07, $ae, $10, $19, $01, $ae, $00, $16, $02, $a2, $01
	db $a1, $1d, $a0, $0f, $ae, $00, $26, $01, $28, $01, $ae, $10, $24, $01, $29, $01
	db $ae, $00, $26, $01, $28, $01, $ae, $10, $24, $01, $ae, $00, $26, $02, $28, $01
	db $ae, $10, $24, $01, $29, $01, $ae, $00, $26, $01, $28, $01, $ae, $00, $22, $01
	db $ae, $10, $24, $01, $28, $01, $ae, $00, $26, $02, $ae, $10, $24, $01, $28, $01
	db $ae, $00, $26, $01, $ae, $10, $24, $01, $28, $01, $ae, $00, $26, $02, $ae, $00
	db $28, $02, $28, $01, $ae, $00, $27, $02, $ae, $00, $28, $02, $28, $01, $ae, $00
	db $27, $02, $ae, $00, $28, $02, $28, $01, $ae, $00, $27, $02, $ae, $00, $29, $02
	db $28, $01, $ae, $10, $28, $01, $29, $01, $ae, $00, $29, $02, $28, $01, $ae, $10
	db $28, $01, $ae, $00, $29, $02, $28, $01, $ae, $10, $28, $01, $29, $01, $ae, $00
	db $29, $02, $28, $01, $ae, $10, $28, $01, $ae, $00, $29, $02, $28, $01, $ae, $10
	db $28, $01, $29, $01, $ae, $00, $29, $02, $28, $01, $1f, $01, $ae, $10, $28, $01
	db $29, $01, $ae, $00, $29, $02, $28, $01, $a0, $09, $ae, $10, $2a, $01, $28, $01
	db $ae, $00, $2b, $02, $ae, $10, $28, $01, $ae, $00, $29, $02, $28, $01, $ae, $10
	db $28, $01, $ae, $00, $29, $02, $ae, $10, $28, $01, $28, $01, $a0, $03, $ae, $10
	db $25, $01, $ae, $00, $26, $02, $ae, $10, $25, $01, $28, $01, $ae, $00, $26, $02
	db $ae, $10, $25, $01, $ae, $00, $26, $02, $ff, $ff

;@ path: sound/parts
;@ Sound part $8B: events for channel 1 (hardware channel: noise). Part 2 of sound effect $8A (parts $8A-$8B,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_8B::
	db $00, $00, $07, $00, $1f, $03
	db $c3, $40, $70, $20, $c7, $70, $70, $50, $ff, $ff

;@ path: sound/parts
;@ Sound part $8C: events for channel 0 (hardware channel: noise). Sound effect $8C, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_8C::
	db $00, $00, $0f, $00, $40, $02
	db $60, $03, $20, $08, $11, $02, $40, $03, $a0, $06, $c7, $10, $40, $05, $ff, $ff
;@ path: sound/parts
;@ Sound part $8D: events for channel 0 (hardware channel: noise). Sound effect $8D, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_8D::
	db $00, $00, $0f, $00, $40, $05, $60, $05, $20, $08, $11, $02, $40, $08, $a0, $06
	db $c7, $20, $40, $08, $1f, $02, $a0, $0f, $c0, $fe, $88, $12, $50, $05, $60, $05
	db $40, $10, $c7, $10, $30, $20, $ff, $ff

;@ path: sound/parts
;@ Sound part $8E: events for channel 0 (hardware channel: noise). Sound effect $8E, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_8E::
	db $00, $00, $0f, $00, $40, $02, $60, $03
	db $20, $08, $11, $02, $40, $03, $a0, $06, $c7, $10, $40, $05, $c0, $fe, $20, $07
	db $12, $08, $11, $08, $1f, $01, $a0, $0f, $50, $04, $60, $10, $c7, $20, $a0, $06
	db $60, $20, $ff, $ff

;@ path: sound/parts
;@ Sound part $8F: events for channel 0 (hardware channel: noise). Sound effect $8F, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_8F::
	db $00, $00, $0f, $00, $40, $02, $60, $03, $20, $08, $11, $02
	db $a0, $08, $40, $03, $a0, $05, $c7, $10, $40, $08, $c0, $fe, $a0, $0f, $c3, $07
	db $21, $05, $23, $05, $c0, $fe, $23, $05, $22, $08, $22, $07, $a0, $08, $c7, $40
	db $22, $20, $ff, $ff

;@ path: sound/parts
;@ Sound part $90: events for channel 0 (hardware channel: pulse 1). First part of sound effect $90 (parts
;@ $90-$91, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_90::
	db $00, $00, $0f, $14, $1f, $12, $ae, $10, $30, $02, $2b, $03
	db $1f, $02, $28, $03, $2b, $03, $1f, $02, $2b, $04, $1f, $02, $28, $02, $1a, $03
	db $2f, $01, $1a, $03, $1f, $02, $29, $01, $18, $02, $1f, $02, $27, $01, $17, $02
	db $26, $01, $25, $02, $24, $01, $23, $02, $1f, $01, $22, $01, $21, $02, $20, $01
	db $1b, $01, $1a, $01, $19, $01, $18, $01, $17, $01, $1f, $01, $16, $01, $15, $01
	db $14, $01, $a0, $08, $1f, $01, $15, $01, $17, $01, $19, $01, $a0, $06, $1f, $02
	db $18, $01, $1b, $01, $17, $01, $1a, $01, $18, $01, $1b, $02, $14, $01, $a0, $04
	db $1f, $02, $18, $01, $1b, $01, $18, $01, $1f, $02, $1a, $01, $18, $01, $1f, $02
	db $14, $01, $19, $01, $1b, $01, $19, $01, $1a, $01, $ff, $ff

;@ path: sound/parts
;@ Sound part $91: events for channel 1 (hardware channel: noise). Part 2 of sound effect $90 (parts $90-$91,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_91::
	db $00, $00, $0f, $00
	db $40, $02, $60, $03, $20, $08, $11, $02, $40, $03, $a0, $06, $c7, $10, $40, $05
	db $ff, $ff

;@ path: sound/parts
;@ Sound part $92: events for channel 0 (hardware channel: noise). Sound effect $92, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_92::
	db $00, $00, $0f, $00, $60, $02, $98, $03, $43, $06, $c1, $10, $a0, $06
	db $43, $10, $ff, $ff

;@ path: sound/parts
;@ Sound part $93: events for channel 0 (hardware channel: noise). Sound effect $93, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_93::
	db $00, $00, $0f, $00, $23, $02, $31, $04, $12, $05, $13, $05
	db $c7, $20, $30, $05, $c0, $fe, $10, $10, $a0, $05, $c7, $20, $20, $10, $ff, $ff
;@ path: sound/parts
;@ Sound part $94: events for channel 0 (hardware channel: noise). Sound effect $94, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_94::
	db $00, $00, $0f, $00, $40, $02, $60, $03, $20, $08, $11, $02, $40, $03, $a0, $06
	db $c7, $10, $40, $05, $a0, $0f, $1f, $03, $c3, $30, $70, $20, $c7, $30, $70, $30
	db $ff, $ff, $ff, $ff

;@ path: sound/parts
;@ Sound part $95: events for channel 0 (hardware channel: noise). Sound effect $95, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_95::
	db $00, $00, $0f, $00, $c7, $20, $50, $01, $40, $08, $21, $08
	db $a0, $08, $21, $10, $a0, $0f, $53, $05, $46, $06, $50, $03, $30, $03, $42, $08
	db $c7, $20, $42, $20, $ff, $ff

;@ path: sound/parts
;@ Sound part $96: events for channel 0 (hardware channel: noise). Sound effect $96, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_96::
	db $00, $00, $0f, $00, $60, $04, $30, $02, $50, $02
	db $20, $02, $40, $02, $1f, $01, $50, $02, $60, $04, $30, $02, $50, $02, $20, $02
	db $40, $02, $60, $02, $40, $05, $22, $07, $c1, $20, $40, $08, $a0, $05, $40, $10
	db $ff, $ff

;@ path: sound/parts
;@ Sound part $97: events for channel 0 (hardware channel: pulse 1). First part of sound effect $97 (parts
;@ $97-$98, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_97::
	db $00, $02, $0f, $25, $12, $06, $1f, $01, $12, $06, $1f, $01, $12, $06
	db $1f, $01, $ae, $10, $12, $06, $1f, $01, $ae, $00, $15, $06, $1f, $01, $15, $06
	db $1f, $01, $15, $06, $1f, $01, $ae, $10, $15, $06, $1f, $01, $a0, $08, $15, $06
	db $1f, $01, $15, $06, $1f, $01, $15, $06, $1f, $01, $12, $09, $1f, $01, $ff, $ff
;@ path: sound/parts
;@ Sound part $98: events for channel 1 (hardware channel: noise). Part 2 of sound effect $97 (parts $97-$98,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_98::
	db $00, $00, $0f, $00, $1f, $55, $40, $03, $41, $06, $70, $05, $60, $22, $c1, $50
	db $a0, $07, $60, $10, $ff, $ff

;@ path: sound/parts
;@ Sound part $99: events for channel 0 (hardware channel: pulse 1). First part of sound effect $99 (parts
;@ $99-$9A, started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave)
;@ and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_99::
	db $00, $00, $0f, $26, $a0, $0a, $26, $03, $27, $03
	db $a0, $0f, $28, $03, $29, $03, $30, $03, $31, $03, $a0, $0c, $32, $03, $33, $03
	db $a0, $0a, $36, $03, $37, $02, $38, $02, $39, $02, $a0, $07, $38, $02, $39, $02
	db $3a, $02, $a0, $05, $39, $02, $3a, $02, $1f, $01, $39, $02, $3a, $02, $1f, $02
	db $a0, $0f, $a1, $17, $13, $03, $12, $04, $a1, $15, $11, $03, $10, $04, $a0, $07
	db $10, $04, $a0, $0f, $0b, $03, $a0, $06, $0b, $03, $a0, $0f, $0a, $03, $a0, $08
	db $0a, $03, $a0, $0f, $09, $03, $a0, $08, $09, $03, $a0, $0f, $09, $04, $08, $06
	db $a0, $06, $08, $06, $a0, $04, $08, $06, $ff, $ff

;@ path: sound/parts
;@ Sound part $9A: events for channel 1 (hardware channel: noise). Part 2 of sound effect $99 (parts $99-$9A,
;@ started together by PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and
;@ 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_9A::
	db $00, $00, $0f, $00, $c3, $7f
	db $11, $20, $c1, $40, $11, $20, $1f, $02, $c0, $fe, $a0, $05, $51, $10, $c1, $40
	db $51, $30, $ff, $ff

;@ path: sound/parts
;@ Sound part $9B: events for channel 0 (hardware channel: noise). Sound effect $9B, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_9B::
	db $00, $00, $0f, $00, $c3, $0a, $21, $03, $13, $02, $a0, $0f
	db $20, $09, $12, $10, $c7, $20, $a0, $08, $12, $20, $ff, $ff

;@ path: sound/parts
;@ Sound part $9C: events for channel 0 (hardware channel: noise). Sound effect $9C, a single part (PlaySound). A
;@ 4-byte header (tempo, duty or wave length, envelope, sweep or wave) and 2-byte events up to $FF, read by
;@ UpdateSound and ReadChannelEvents.
SoundPart_9C::
	db $00, $00, $0f, $00
	db $50, $02, $42, $02, $a0, $0a, $50, $01, $a0, $0c, $40, $02, $42, $02, $a0, $07
	db $40, $01, $a0, $0a, $40, $02, $42, $02, $a0, $05, $40, $01, $40, $02, $42, $02
	db $40, $01, $a0, $03, $40, $01, $40, $02, $42, $02, $40, $01, $ff, $ff

;@ path: sound/parts
;@ Sound part $9D: events for channel 2 (hardware channel: pulse 1). First part of sound $9D (parts $9D-$9E on
;@ channels 2-3, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_9D::
	db $00, $01
	db $0f, $00, $fd, $fe, $ae, $10, $a5, $f0, $cc, $10, $60, $15, $a0, $0f, $cc, $30
	db $60, $25, $c1, $30, $60, $20, $a0, $08, $c3, $01, $60, $04, $a0, $09, $60, $04
	db $a0, $0a, $60, $04, $a0, $09, $60, $04, $a0, $08, $60, $04, $a0, $06, $60, $04
	db $1f, $04, $a0, $07, $60, $04, $a0, $08, $60, $04, $a0, $09, $60, $04, $a0, $08
	db $60, $04, $a0, $06, $60, $04, $1f, $04, $a0, $07, $60, $04, $a0, $08, $60, $04
	db $a0, $06, $60, $04, $1f, $04, $a0, $07, $c1, $40, $60, $40, $1f, $80, $b1, $fc
	db $05, $00, $1f, $20, $ae, $00, $a5, $0f, $cc, $10, $61, $15, $a0, $0f, $cc, $30
	db $61, $25, $c1, $19, $61, $10, $a0, $08, $c3, $01, $61, $04, $a0, $09, $61, $04
	db $a0, $0a, $61, $04, $a0, $09, $61, $04, $a0, $08, $61, $04, $a0, $06, $61, $04
	db $1f, $04, $a0, $07, $61, $04, $a0, $08, $61, $04, $a0, $09, $61, $04, $a0, $08
	db $61, $04, $a0, $06, $61, $04, $1f, $04, $a0, $07, $61, $04, $a0, $08, $61, $04
	db $a0, $06, $61, $04, $1f, $04, $a0, $07, $c1, $40, $61, $40, $1f, $20, $ae, $10
	db $a5, $f0, $cc, $10, $60, $15, $a0, $0c, $cc, $30, $60, $15, $c1, $20, $60, $20
	db $1f, $20, $ae, $00, $cc, $10, $61, $15, $a0, $0d, $cc, $30, $61, $25, $c1, $19
	db $61, $10, $a0, $05, $c3, $01, $61, $04, $a0, $07, $61, $04, $a0, $08, $61, $04
	db $a0, $07, $61, $04, $a0, $06, $61, $04, $a0, $04, $61, $04, $1f, $04, $a0, $05
	db $61, $04, $a0, $06, $61, $04, $a0, $07, $61, $04, $a0, $06, $61, $04, $a0, $04
	db $61, $04, $1f, $04, $a0, $05, $61, $04, $a0, $06, $61, $04, $a0, $04, $61, $04
	db $1f, $04, $a0, $05, $c1, $40, $61, $40, $1f, $20, $b0, $00, $ff, $ff

;@ path: sound/parts
;@ Sound part $9E: events for channel 3 (hardware channel: pulse 2). Part 2 of sound $9D (parts $9D-$9E on
;@ channels 2-3, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_9E::
	db $00, $02
	db $0f, $00, $fd, $fe, $1f, $70, $ae, $10, $a5, $0f, $cc, $10, $60, $15, $a0, $0f
	db $cc, $30, $60, $25, $c1, $30, $60, $40, $a0, $08, $1f, $24, $cc, $30, $60, $20
	db $c1, $50, $60, $20, $1f, $80, $b1, $fc, $06, $00, $ae, $00, $a5, $f0, $cc, $10
	db $61, $15, $a0, $0f, $cc, $30, $61, $25, $c1, $19, $61, $10, $a0, $08, $c3, $01
	db $61, $04, $a0, $09, $61, $04, $a0, $0a, $61, $04, $a0, $09, $61, $04, $a0, $08
	db $61, $04, $a0, $06, $61, $04, $1f, $04, $a0, $07, $61, $04, $a0, $08, $61, $04
	db $a0, $09, $61, $04, $a0, $08, $61, $04, $a0, $06, $61, $04, $1f, $04, $a0, $07
	db $61, $04, $a0, $08, $61, $04, $a0, $06, $61, $04, $1f, $04, $a0, $07, $c1, $40
	db $61, $40, $1f, $20, $ae, $10, $a5, $0f, $cc, $10, $60, $15, $a0, $0c, $cc, $30
	db $60, $15, $c1, $20, $60, $10, $1f, $20, $ae, $00, $cc, $10, $61, $15, $a0, $0d
	db $cc, $30, $61, $25, $c1, $19, $61, $10, $a0, $05, $c3, $01, $61, $04, $a0, $07
	db $61, $04, $a0, $08, $61, $04, $a0, $07, $61, $04, $a0, $06, $61, $04, $a0, $04
	db $61, $04, $1f, $04, $a0, $05, $61, $04, $a0, $06, $61, $04, $a0, $07, $61, $04
	db $a0, $06, $61, $04, $a0, $04, $61, $04, $1f, $04, $a0, $05, $61, $04, $a0, $06
	db $61, $04, $a0, $04, $61, $04, $1f, $04, $a0, $05, $c1, $40, $61, $10, $1f, $10
	db $b0, $00, $ff, $ff

;@ path: sound/parts
;@ Sound part $9F: events for channel 2 (hardware channel: pulse 1). First part of sound $9F (parts $9F-$A1 on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_9F::
	db $03, $00, $0c, $00, $fd, $fe, $a0, $0c, $1f, $18, $c1, $3f
	db $a0, $0d, $25, $18, $a0, $0c, $25, $18, $22, $18, $22, $18, $1a, $18, $1b, $18
	db $20, $18, $1a, $18, $a0, $0d, $27, $18, $a0, $0c, $27, $18, $23, $18, $23, $18
	db $23, $18, $23, $18, $20, $18, $19, $18, $a0, $0d, $1b, $18, $a0, $0c, $20, $18
	db $22, $18, $1b, $18, $23, $18, $27, $18, $1a, $18, $20, $18, $a0, $0d, $24, $18
	db $a0, $0c, $24, $18, $1a, $18, $1a, $18, $a0, $0a, $19, $18, $a0, $0c, $1a, $18
	db $a0, $0e, $1b, $18, $a0, $0d, $20, $18, $a0, $0c, $25, $18, $25, $18, $22, $18
	db $22, $18, $1a, $18, $1b, $18, $20, $18, $1a, $18, $a0, $0d, $27, $18, $a0, $0c
	db $27, $18, $23, $18, $23, $18, $23, $18, $23, $18, $20, $18, $19, $18, $a0, $0d
	db $1b, $18, $a0, $0c, $20, $18, $22, $18, $1b, $18, $23, $18, $27, $18, $1a, $18
	db $20, $18, $a0, $0d, $24, $18, $a0, $0c, $24, $18, $23, $18, $23, $18, $22, $18
	db $c1, $1f, $a0, $0d, $23, $08, $23, $08, $23, $08, $c1, $50, $22, $18, $1f, $18
	db $af, $03, $a2, $00, $a0, $0d, $a1, $00, $c1, $50, $29, $18, $19, $08, $20, $08
	db $25, $08, $c1, $2f, $29, $18, $1f, $18, $c1, $50, $25, $18, $22, $08, $25, $08
	db $2a, $08, $c1, $2f, $32, $18, $1f, $18, $c1, $3f, $27, $18, $2a, $18, $21, $18
	db $2a, $18, $30, $18, $2a, $18, $29, $18, $19, $18, $20, $18, $19, $18, $20, $18
	db $26, $18, $22, $18, $22, $18, $25, $18, $25, $18, $a0, $05, $25, $18, $a0, $0d
	db $2a, $18, $a0, $05, $2a, $18, $a0, $0d, $29, $18, $a0, $08, $23, $05, $25, $04
	db $23, $03, $25, $03, $23, $03, $25, $03, $23, $03, $25, $03, $23, $03, $25, $03
	db $23, $03, $25, $03, $23, $03, $25, $03, $23, $03, $c1, $70, $a0, $0a, $22, $0c
	db $a0, $05, $22, $18, $1f, $0c, $a0, $0d, $c1, $4f, $1f, $08, $1f, $08, $a0, $0d
	db $23, $08, $a0, $06, $23, $10, $a0, $0d, $23, $08, $a0, $06, $23, $10, $a0, $0d
	db $23, $08, $a0, $06, $23, $10, $a0, $0d, $23, $08, $a0, $06, $23, $10, $a0, $0d
	db $22, $08, $a0, $06, $22, $10, $a0, $0d, $22, $08, $a0, $06, $22, $10, $a0, $0d
	db $22, $08, $a0, $06, $22, $10, $a0, $0d, $22, $08, $a0, $0c, $c1, $30, $1a, $08
	db $a0, $05, $1a, $08, $a0, $0c, $1a, $08, $b2, $fc, $c5, $00, $20, $08, $a0, $05
	db $20, $08, $a0, $0c, $20, $08, $21, $08, $a0, $05, $21, $08, $a0, $0c, $21, $08
	db $b3, $fc, $d1, $00, $23, $08, $a0, $05, $23, $08, $a0, $0c, $23, $08, $b3, $fc
	db $d8, $00, $c2, $20, $23, $18, $c2, $15, $1a, $08, $1a, $08, $1a, $08, $27, $08
	db $27, $08, $27, $08, $2a, $08, $2a, $08, $2a, $08, $c1, $30, $28, $08, $27, $08
	db $28, $08, $30, $08, $a0, $05, $30, $08, $a0, $0c, $30, $08, $2a, $08, $a0, $05
	db $2a, $08, $a0, $0c, $2a, $08, $28, $08, $a0, $05, $28, $08, $a0, $0c, $28, $08
	db $23, $08, $a0, $05, $23, $08, $a0, $0c, $23, $08, $23, $18, $27, $08, $a0, $05
	db $27, $08, $a0, $0c, $27, $08, $23, $18, $23, $08, $a0, $05, $23, $08, $a0, $0c
	db $23, $08, $b3, $fc, $0a, $01, $22, $08, $a0, $05, $22, $08, $a0, $0c, $22, $08
	db $b3, $fc, $11, $01, $af, $03, $a2, $00, $a0, $0c, $a1, $00, $c1, $30, $23, $08
	db $a0, $05, $23, $08, $a0, $0c, $23, $08, $b9, $fc, $1d, $01, $20, $08, $a0, $05
	db $20, $08, $a0, $0c, $20, $08, $b1, $fc, $24, $01, $1a, $08, $a0, $05, $1a, $08
	db $a0, $0c, $1a, $08, $1a, $08, $a0, $05, $1a, $08, $a0, $0c, $22, $08, $23, $08
	db $a0, $05, $23, $08, $a0, $0c, $23, $08, $b1, $fc, $35, $01, $c1, $40, $24, $08
	db $27, $08, $2a, $08, $34, $18, $25, $08, $29, $08, $30, $08, $35, $18, $22, $08
	db $25, $08, $28, $08, $32, $18, $27, $08, $2a, $08, $31, $08, $37, $18, $20, $08
	db $23, $08, $26, $08, $30, $18, $19, $08, $20, $08, $26, $08, $29, $18, $22, $08
	db $25, $08, $2b, $08, $32, $08, $2b, $08, $25, $08, $1a, $08, $24, $08, $27, $08
	db $2a, $08, $27, $08, $24, $08, $c1, $7f, $a0, $0f, $15, $18, $a0, $0c, $1f, $18
	db $24, $18, $23, $18, $22, $18, $23, $18, $23, $18, $26, $18, $c2, $15, $27, $18
	db $c1, $30, $23, $08, $27, $08, $2a, $08, $c2, $15, $33, $18, $c1, $30, $27, $18
	db $c0, $fe, $23, $18, $c1, $7f, $a0, $08, $23, $18, $a0, $0d, $c2, $15, $23, $18
	db $b0, $00, $ff

;@ path: sound/parts
;@ Sound part $A0: events for channel 3 (hardware channel: pulse 2). Part 2 of sound $9F (parts $9F-$A1 on
;@ channels 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length,
;@ envelope, sweep or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_A0::
	db $03, $01, $0f, $00, $fd, $fe, $a0, $0f, $a3, $08, $c1, $3f, $25
	db $18, $c1, $7f, $32, $18, $a0, $08, $32, $12, $a0, $0d, $30, $06, $2a, $12, $29
	db $06, $2a, $12, $32, $06, $c0, $fe, $a3, $0f, $27, $30, $c1, $7f, $a3, $08, $a0
	db $07, $27, $18, $a0, $0d, $27, $18, $33, $18, $a0, $08, $33, $12, $a0, $0d, $32
	db $06, $30, $12, $2b, $06, $30, $12, $33, $06, $c0, $fe, $a3, $0f, $29, $30, $c1
	db $7f, $a3, $08, $a0, $07, $29, $18, $a0, $0d, $25, $18, $a3, $fe, $35, $18, $a0
	db $08, $35, $12, $a0, $0d, $33, $06, $32, $12, $33, $06, $35, $12, $36, $06, $37
	db $18, $33, $18, $30, $18, $32, $12, $33, $06, $32, $18, $30, $12, $2a, $06, $27
	db $18, $32, $18, $c0, $fe, $30, $30, $a0, $06, $c1, $60, $a3, $08, $30, $18, $c1
	db $7f, $a0, $0d, $25, $18, $32, $18, $a0, $08, $32, $12, $a0, $0d, $30, $06, $2a
	db $12, $29, $06, $2a, $12, $32, $06, $a3, $0f, $c0, $fe, $27, $30, $c1, $7f, $a3
	db $08, $a0, $07, $27, $18, $a0, $0d, $27, $18, $33, $18, $a0, $08, $33, $12, $a0
	db $0d, $32, $06, $30, $12, $2b, $06, $30, $12, $33, $06, $a3, $0f, $c0, $fe, $29
	db $30, $a3, $08, $c1, $7f, $a0, $07, $29, $18, $a0, $0d, $25, $18, $a3, $fe, $35
	db $18, $a0, $08, $35, $12, $a0, $0d, $33, $06, $32, $12, $33, $06, $35, $12, $36
	db $06, $37, $18, $33, $18, $30, $18, $32, $12, $33, $06, $32, $18, $30, $12, $2a
	db $06, $27, $18, $29, $18, $c0, $fe, $a3, $0f, $2a, $30, $a3, $08, $a0, $06, $c1
	db $60, $2a, $12, $a0, $0d, $c1, $7f, $2a, $06, $29, $12, $2a, $06, $af, $03, $a2
	db $01, $a0, $0d, $a1, $00, $c1, $40, $a3, $08, $30, $18, $25, $08, $29, $08, $30
	db $08, $35, $0c, $a0, $06, $35, $06, $a0, $0d, $c1, $70, $30, $06, $2a, $12, $30
	db $06, $32, $18, $25, $08, $2a, $08, $32, $08, $35, $0c, $a0, $06, $35, $06, $a0
	db $0d, $c1, $70, $32, $06, $30, $12, $32, $06, $a3, $fe, $33, $12, $32, $06, $33
	db $12, $35, $06, $37, $12, $36, $06, $37, $12, $3a, $06, $39, $18, $37, $18, $c1
	db $50, $a0, $0b, $35, $18, $a0, $0d, $c1, $7f, $25, $18, $c0, $fe, $a3, $08, $26
	db $30, $c1, $7f, $a3, $fe, $33, $18, $32, $18, $30, $18, $2a, $18, $29, $18, $2a
	db $18, $c1, $50, $27, $12, $c1, $7f, $27, $06, $33, $18, $c1, $50, $25, $12, $c1
	db $7f, $a0, $0d, $25, $06, $33, $18, $a0, $09, $30, $05, $32, $04, $30, $03, $32
	db $03, $30, $03, $32, $03, $30, $03, $32, $03, $30, $03, $32, $03, $30, $03, $32
	db $03, $30, $03, $32, $03, $30, $03, $c1, $70, $a0, $0a, $2a, $0c, $a0, $07, $2a
	db $18, $1f, $0c, $a0, $0d, $c1, $30, $1f, $10, $27, $08, $a0, $08, $27, $08, $1f
	db $08, $a0, $0d, $27, $08, $a0, $08, $27, $08, $1f, $08, $a0, $0d, $27, $08, $a0
	db $08, $27, $08, $1f, $08, $a0, $0d, $27, $08, $a0, $08, $27, $08, $1f, $08, $a0
	db $0d, $28, $08, $a0, $08, $28, $08, $1f, $08, $a0, $0d, $28, $08, $a0, $08, $28
	db $08, $1f, $08, $a0, $0d, $28, $08, $a0, $08, $28, $08, $1f, $08, $a0, $0d, $28
	db $08, $a0, $05, $28, $08, $a0, $0d, $a3, $0a, $1f, $10, $c1, $50, $27, $18, $c1
	db $7f, $27, $18, $28, $18, $c0, $fe, $2a, $24, $a0, $08, $c1, $7f, $a3, $00, $2a
	db $0c, $a0, $0d, $a3, $08, $27, $18, $23, $18, $30, $08, $2b, $08, $30, $08, $33
	db $18, $32, $18, $30, $18, $c2, $15, $2a, $18, $23, $08, $23, $08, $23, $08, $2a
	db $08, $2a, $08, $2a, $08, $33, $08, $33, $08, $33, $08, $c1, $7f, $30, $08, $2b
	db $08, $30, $08, $33, $18, $32, $18, $30, $18, $c0, $fe, $2a, $30, $c1, $7f, $33
	db $18, $c1, $50, $37, $18, $c1, $7f, $c0, $fe, $37, $30, $c1, $7f, $30, $18, $37
	db $18, $c0, $fe, $35, $30, $c1, $7f, $a0, $08, $35, $18, $a0, $0d, $25, $08, $24
	db $08, $25, $08, $af, $03, $a2, $01, $a0, $0f, $a1, $00, $a3, $0a, $a0, $0d, $27
	db $08, $a0, $04, $27, $08, $a0, $0d, $30, $08, $c0, $fe, $37, $30, $c1, $7f, $a0
	db $08, $37, $18, $b1, $fc, $55, $01, $a0, $0d, $27, $08, $a0, $04, $27, $08, $a0
	db $0d, $30, $08, $c0, $fe, $35, $30, $c1, $7f, $a0, $08, $35, $18, $a0, $0d, $32
	db $08, $a0, $04, $32, $08, $a0, $0d, $33, $08, $c0, $fe, $2a, $30, $c1, $7f, $a0
	db $08, $2a, $18, $c1, $40, $a0, $0d, $30, $08, $34, $08, $37, $08, $40, $18, $30
	db $08, $33, $08, $39, $08, $40, $18, $2a, $08, $32, $08, $35, $08, $3a, $18, $2a
	db $08, $31, $08, $37, $08, $3a, $18, $28, $08, $30, $08, $33, $08, $38, $18, $26
	db $08, $29, $08, $30, $08, $36, $18, $25, $08, $2b, $08, $32, $08, $35, $08, $32
	db $08, $2b, $08, $24, $08, $27, $08, $2a, $08, $34, $08, $2a, $08, $27, $08, $a0
	db $04, $c1, $50, $27, $18, $a0, $0d, $c1, $7f, $25, $18, $27, $18, $29, $18, $2a
	db $18, $2b, $18, $30, $18, $32, $18, $c0, $fe, $33, $18, $a0, $08, $33, $18, $a0
	db $0d, $a3, $fe, $37, $18, $33, $18, $c1, $7f, $35, $10, $37, $10, $38, $10, $c2
	db $15, $39, $18, $b0, $00, $ff

;@ path: sound/parts
;@ Sound part $A1: events for channel 4 (hardware channel: wave). Part 3 of sound $9F (parts $9F-$A1 on channels
;@ 2-4, started together by PlayMusic or PlaySound). A 4-byte header (tempo, duty or wave length, envelope, sweep
;@ or wave) and 2-byte events up to $FF, read by UpdateSound and ReadChannelEvents.
SoundPart_A1::
	db $03, $40, $02, $0b, $fd, $fe, $a2, $40, $1f, $18
	db $1a, $18, $19, $18, $17, $18, $15, $18, $13, $18, $12, $18, $10, $18, $13, $18
	db $20, $18, $1a, $18, $19, $18, $17, $18, $15, $18, $17, $18, $19, $18, $15, $18
	db $17, $18, $19, $18, $1b, $18, $17, $18, $20, $18, $23, $18, $27, $18, $23, $18
	db $20, $18, $17, $18, $14, $18, $20, $18, $15, $18, $16, $18, $17, $18, $19, $18
	db $1a, $18, $19, $18, $17, $18, $15, $18, $13, $18, $12, $18, $10, $18, $13, $18
	db $20, $18, $1a, $18, $19, $18, $17, $18, $15, $18, $17, $18, $19, $18, $15, $18
	db $17, $18, $19, $18, $1b, $18, $17, $18, $20, $18, $23, $18, $27, $18, $23, $18
	db $20, $18, $20, $18, $15, $18, $15, $18, $1a, $18, $a2, $10, $15, $08, $15, $08
	db $15, $08, $a2, $30, $1a, $18, $a0, $06, $1a, $18, $af, $03, $a2, $40, $a0, $02
	db $a1, $0b, $a2, $30, $a0, $02, $15, $18, $20, $08, $25, $08, $29, $08, $30, $18
	db $a0, $06, $a2, $10, $30, $18, $a0, $02, $a2, $30, $1a, $18, $2a, $08, $32, $08
	db $35, $08, $3a, $18, $a2, $10, $a0, $06, $3a, $18, $a0, $02, $a2, $20, $20, $18
	db $a2, $30, $20, $18, $24, $18, $14, $18, $15, $18, $17, $18, $19, $18, $15, $18
	db $12, $18, $22, $18, $26, $18, $22, $18, $17, $18, $27, $18, $17, $18, $27, $18
	db $a0, $06, $27, $18, $a0, $02, $20, $18, $a0, $06, $20, $18, $a0, $02, $25, $18
	db $1a, $18, $15, $18, $1a, $0c, $a0, $06, $1a, $0c, $a0, $02, $a2, $4f, $1a, $10
	db $20, $04, $22, $04, $23, $18, $22, $18, $20, $18, $1a, $18, $18, $18, $17, $18
	db $15, $18, $1a, $18, $a2, $50, $13, $08, $a0, $06, $13, $08, $a0, $02, $27, $08
	db $1a, $08, $a0, $06, $1a, $08, $a0, $02, $27, $08, $13, $08, $a0, $06, $13, $08
	db $a0, $02, $27, $08, $23, $08, $a0, $06, $23, $08, $a0, $02, $28, $08, $13, $08
	db $a0, $06, $13, $08, $a0, $02, $27, $08, $1a, $08, $a0, $06, $1a, $08, $a0, $02
	db $27, $08, $13, $08, $a0, $06, $13, $08, $a0, $02, $27, $08, $1a, $08, $a0, $06
	db $1a, $08, $a0, $02, $27, $08, $18, $08, $a0, $06, $18, $08, $a0, $02, $30, $08
	db $b3, $fc, $b8, $00, $a2, $1f, $17, $18, $27, $08, $27, $08, $27, $08, $33, $08
	db $33, $08, $33, $08, $37, $08, $37, $08, $37, $08, $a2, $20, $18, $08, $a0, $06
	db $18, $08, $a0, $02, $33, $08, $18, $08, $a0, $06, $18, $08, $a0, $02, $28, $08
	db $b1, $fc, $d0, $00, $18, $08, $a0, $06, $18, $08, $a0, $02, $33, $08, $17, $08
	db $a0, $04, $17, $08, $a0, $02, $17, $08, $27, $18, $20, $08, $a0, $04, $20, $08
	db $a0, $02, $20, $08, $30, $18, $15, $08, $a0, $06, $15, $08, $a0, $02, $29, $08
	db $b1, $fc, $e8, $00, $20, $08, $a0, $04, $20, $08, $a0, $02, $29, $08, $15, $08
	db $a0, $04, $15, $08, $a0, $02, $29, $08, $1a, $08, $a0, $04, $1a, $08, $a0, $02
	db $a2, $15, $28, $08, $a2, $20, $28, $08, $a0, $04, $28, $08, $a0, $02, $28, $08
	db $17, $08, $a0, $04, $17, $08, $a0, $02, $a2, $15, $2b, $08, $a2, $20, $2b, $08
	db $a0, $04, $2b, $08, $a0, $02, $2b, $08, $af, $03, $a0, $02, $a1, $0b, $20, $08
	db $a0, $04, $20, $08, $a0, $02, $30, $08, $30, $08, $a0, $04, $30, $08, $a0, $02
	db $30, $08, $1b, $08, $a0, $04, $1b, $08, $a0, $02, $2b, $08, $2b, $08, $a0, $04
	db $2b, $08, $a0, $02, $2b, $08, $1a, $08, $a0, $04, $1a, $08, $a0, $02, $2a, $08
	db $2a, $08, $a0, $04, $2a, $08, $a0, $02, $2a, $08, $19, $08, $a0, $04, $19, $08
	db $a0, $02, $29, $08, $29, $08, $a0, $04, $29, $08, $a0, $02, $29, $08, $18, $08
	db $a0, $04, $18, $08, $a0, $02, $28, $08, $28, $08, $a0, $04, $28, $08, $a0, $02
	db $28, $08, $12, $08, $a0, $04, $12, $08, $a0, $02, $28, $08, $28, $08, $a0, $04
	db $28, $08, $a0, $02, $28, $08, $17, $08, $a0, $04, $17, $08, $a0, $02, $27, $08
	db $27, $08, $a0, $04, $27, $08, $a0, $02, $27, $08, $20, $08, $a0, $04, $20, $08
	db $a0, $02, $27, $08, $27, $08, $a0, $04, $27, $08, $a0, $02, $27, $08, $27, $08
	db $2a, $08, $34, $08, $37, $18, $29, $08, $30, $08, $33, $08, $39, $18, $25, $08
	db $28, $08, $32, $08, $35, $18, $23, $08, $27, $08, $2a, $08, $33, $18, $23, $08
	db $26, $08, $30, $08, $33, $18, $22, $08, $26, $08, $29, $08, $32, $18, $27, $08
	db $a0, $04, $27, $08, $a0, $02, $27, $08, $a1, $0a, $17, $18, $a1, $0b, $30, $08
	db $a0, $04, $30, $08, $a0, $02, $30, $08, $a1, $0a, $20, $18, $a2, $ff, $15, $18
	db $a0, $04, $15, $18, $a0, $06, $15, $18, $a0, $02, $a2, $70, $a1, $0b, $30, $18
	db $2a, $18, $27, $18, $19, $18, $22, $18, $a2, $28, $20, $18, $a2, $20, $20, $08
	db $23, $08, $27, $08, $a2, $1f, $30, $18, $a2, $20, $20, $18, $a2, $ff, $2b, $18
	db $a0, $04, $2b, $18, $a2, $20, $a0, $02, $30, $18, $b0, $00, $ff, $ff

;@ path: unused/sound
;@ Bytes after the end event of SoundPart_A1 that no sound record points at.
UnusedSoundData_1E_661E::
	db $0e, $0f
	db $00, $01, $0d, $0f, $78, $37, $46, $1c, $0d, $0f, $08, $09, $0d, $06, $0e, $82
	db $0f, $78, $04, $5c, $85, $78, $12, $13, $78, $20, $07, $78, $82, $65, $4f, $04
	db $5c, $82, $78, $0d, $03, $0e, $83, $68, $7f, $69, $04, $0e, $81, $0f, $03, $78
	db $84, $46, $3a, $78, $0d, $04, $0e, $8a, $0f, $78, $38, $38, $65, $65, $73, $52
	db $56, $0d, $06, $0e, $81, $0f, $09, $78, $83, $4f, $65, $65, $06, $78, $84, $4f
	db $78, $65, $65, $08, $78, $82, $65, $65, $08, $78, $82, $65, $65, $04, $5c, $8b
	db $0d, $0f, $1d, $1f, $78, $38, $3b, $1d, $1e, $1e, $1f, $04, $78, $84, $4f, $78
	db $78, $15, $06, $16, $81, $27, $03, $0e, $8e, $0f, $08, $09, $0d, $0f, $78, $37
	db $3a, $1c, $0d, $0f, $00, $01, $0d, $05, $0e, $82, $75, $72, $03, $78, $8a, $12
	db $13, $78, $1a, $1b, $12, $13, $78, $78, $40, $04, $78, $82, $65, $57, $04, $5c
	db $82, $78, $0d, $03, $0e, $83, $68, $7f, $69, $04, $0e, $82, $0f, $40, $03, $78
	db $83, $46, $3a, $0d, $04, $0e, $81, $0f, $03, $78, $86, $65, $65, $62, $62, $7a
	db $0d, $06, $0e, $87, $0f, $7c, $78, $78, $73, $51, $56, $03, $78, $83, $57, $65
	db $65, $03, $78, $87, $73, $51, $56, $57, $40, $65, $65, $03, $78, $91, $73, $51
	db $56, $40, $40, $65, $65, $40, $40, $78, $73, $51, $56, $78, $40, $65, $65, $04
	db $5c, $95, $0d, $0f, $78, $7c, $78, $3a, $38, $78, $73, $51, $56, $40, $78, $40
	db $40, $57, $73, $51, $56, $78, $65, $04, $78, $81, $70, $04, $71, $8d, $00, $01
	db $0d, $0f, $78, $37, $46, $1c, $0d, $0f, $08, $09, $0d, $05, $0e, $95, $75, $72
	db $f8, $78, $20, $1a, $1b, $20, $78, $20, $1a, $1b, $20, $20, $48, $78, $78, $24
	db $25, $65, $3c, $05, $78, $81, $0d, $03, $0e, $83, $68, $7f, $69, $04, $0e, $82
	db $0f, $48, $04, $78, $82, $46, $0d, $04, $0e, $81, $0f, $03, $78, $86, $65, $65
	db $62, $62, $7a, $0d, $06, $0e, $82, $0f, $fd, $08, $78, $83, $3c, $65, $65, $06
	db $78, $84, $3c, $48, $65, $65, $06, $78, $86, $48, $48, $65, $65, $48, $48, $05
	db $78, $83, $48, $65, $65, $04, $5c, $87, $0d, $0f, $78, $fd, $78, $46, $34, $04
	db $78, $85, $48, $78, $48, $48, $3c, $04, $78, $81, $65, $04, $78, $81, $70, $04
	db $71, $8d, $08, $09, $0d, $0f, $78, $37, $3a, $05, $2f, $0f, $00, $01, $0d, $06
	db $0e, $81, $2e, $0b, $06, $83, $6a, $6b, $6c, $03, $06, $88, $07, $38, $3b, $63
	db $63, $3a, $38, $0d, $03, $0e, $83, $68, $7f, $69, $04, $0e, $88, $0f, $38, $3b
	db $38, $38, $3a, $38, $0d, $04, $0e, $81, $0f, $03, $78, $82, $65, $65, $03, $78
	db $81, $0d, $06, $0e, $81, $2e, $2e, $06, $82, $2f, $2e, $17, $06, $81, $2f, $03
	db $0e, $8e, $2e, $06, $06, $2f, $0f, $78, $37, $46, $15, $16, $17, $08, $09, $0d
	db $12, $0e, $83, $68, $7f, $69, $03, $0e, $88, $0f, $35, $47, $78, $78, $46, $34
	db $0d, $03, $0e, $83, $68, $7f, $69, $04, $0e, $88, $0f, $35, $47, $78, $78, $46
	db $34, $0d, $04, $0e, $81, $0f, $03, $78, $82, $37, $37, $03, $78, $81, $0d, $56
	db $0e, $8a, $0f, $78, $37, $3a, $78, $78, $2d, $00, $01, $0d, $12, $0e, $83, $68
	db $7f, $69, $03, $0e, $88, $0f, $38, $3b, $78, $78, $3a, $38, $0d, $03, $0e, $83
	db $68, $7f, $69, $04, $0e, $82, $0f, $47, $04, $78, $82, $46, $0d, $04, $0e, $81
	db $0f, $03, $7a, $86, $65, $65, $38, $3b, $78, $0d, $56, $0e, $8a, $0f, $73, $51
	db $56, $05, $06, $07, $08, $09, $0d, $12, $0e, $83, $68, $7f, $69, $03, $0e, $88
	db $0f, $35, $47, $78, $78, $46, $34, $15, $03, $16, $83, $68, $7f, $69, $04, $16
	db $88, $17, $78, $78, $73, $53, $56, $78, $0d, $04, $0e, $81, $0f, $03, $7a, $86
	db $65, $65, $35, $47, $78, $0d, $56, $0e, $8a, $0f, $78, $37, $3a, $0d, $0e, $0f
	db $00, $01, $0d, $12, $0e, $83, $68, $7f, $69, $03, $0e, $88, $0f, $47, $73, $53
	db $56, $78, $46, $65, $03, $7a, $83, $6d, $6e, $6f, $06, $7a, $04, $62, $82, $7a
	db $0d, $04, $0e, $81, $0f, $03, $78, $86, $65, $65, $38, $38, $78, $0d, $56, $0e
	db $8a, $0f, $78, $37, $46, $15, $16, $17, $08, $09, $0d, $12, $0e, $83, $68, $7f
	db $69, $03, $0e, $82, $0f, $78, $04, $5c, $82, $4f, $65, $0c, $7a, $04, $62, $82
	db $7a, $0d, $04, $0e, $86, $0f, $78, $38, $3b, $65, $65, $03, $78, $81, $0d, $56
	db $0e, $8a, $0f, $78, $37, $3a, $78, $78, $2d, $00, $01, $0d, $12, $0e, $83, $68
	db $7f, $69, $03, $0e, $82, $0f, $78, $04, $5c, $82, $57, $65, $03, $78, $8f, $40
	db $40, $12, $13, $78, $78, $12, $13, $20, $78, $12, $13, $20, $20, $0d, $04, $0e
	db $8a, $0f, $78, $35, $47, $65, $65, $73, $53, $56, $0d, $56, $0e, $8a, $0f, $78
	db $37, $46, $05, $06, $07, $08, $09, $0d, $12, $0e, $83, $68, $7f, $69, $03, $0e
	db $81, $0f, $05, $78, $94, $3c, $65, $24, $25, $78, $48, $48, $1a, $1b, $20, $20
	db $1a, $1b, $20, $20, $1a, $1b, $20, $20, $0d, $04, $0e, $86, $0f, $78, $3a, $38
	db $65, $65, $03, $7a, $81, $0d, $56, $0e, $8a, $0f, $78, $37, $3a, $0d, $0e, $0f
	db $00, $01, $0d, $12, $0e, $83, $68, $7f, $69, $03, $0e, $88, $0f, $38, $3b, $63
	db $63, $3a, $38, $05, $03, $06, $83, $6a, $6b, $6c, $0b, $06, $81, $2f, $04, $0e
	db $8a, $0f, $78, $46, $34, $65, $65, $62, $62, $7a, $0d, $56, $0e, $8a, $0f, $78
	db $37, $46, $15, $16, $17, $08, $09, $0d, $06, $0e, $81, $26, $06, $16, $81, $27
	db $04, $0e, $83, $68, $7f, $69, $03, $0e, $88, $0f, $35, $47, $78, $78, $46, $34
	db $0d, $03, $0e, $83, $68, $7f, $69, $10, $0e, $8a, $0f, $78, $38, $38, $65, $65
	db $5c, $5c, $78, $0d, $56, $0e, $8a, $0f, $78, $37, $3a, $78, $78, $2d, $78, $78
	db $0d, $06, $0e, $81, $0f, $06, $78, $81, $0d, $04, $0e, $83, $68, $7f, $69, $03
	db $0e, $88, $0f, $38, $3b, $78, $78, $3a, $38, $0d, $03, $0e, $83, $68, $7f, $69
	db $10, $0e, $81, $0f, $03, $7a, $86, $65, $65, $5c, $5c, $78, $0d, $56, $0e, $8a
	db $0f, $73, $52, $56, $05, $06, $07, $78, $78, $0d, $06, $0e, $88, $0f, $78, $73
	db $54, $56, $78, $78, $15, $04, $16, $83, $68, $7f, $69, $03, $16, $88, $17, $35
	db $47, $78, $78, $46, $34, $0d, $03, $0e, $83, $68, $7f, $69, $10, $0e, $81, $0f
	db $03, $7a, $82, $65, $65, $03, $78, $81, $0d, $56, $0e, $8a, $0f, $78, $37, $3a
	db $15, $16, $17, $78, $78, $0d, $06, $0e, $81, $0f, $0b, $79, $83, $6d, $6e, $6f
	db $03, $79, $88, $65, $47, $73, $54, $56, $78, $46, $0d, $03, $0e, $83, $68, $7f
	db $69, $10, $0e, $81, $0f, $03, $78, $82, $37, $37, $03, $78, $81, $0d, $56, $0e
	db $85, $0f, $78, $78, $46, $34, $04, $78, $81, $0d, $06, $0e, $81, $0f, $03, $78
	db $82, $12, $13, $0c, $78, $82, $65, $4f, $04, $5c, $82, $78, $0d, $03, $0e, $83
	db $68, $7f, $69, $10, $0e, $81, $0f, $03, $78, $86, $65, $65, $3a, $3a, $78, $0d
	db $56, $0e, $8b, $0f, $78, $78, $3a, $46, $3a, $78, $3b, $78, $78, $75, $05, $0e
	db $8f, $0f, $12, $13, $21, $1a, $1b, $12, $13, $78, $20, $78, $78, $12, $13, $40
	db $03, $78, $82, $65, $57, $04, $5c, $82, $78, $0d, $03, $0e, $83, $68, $7f, $69
	db $10, $0e, $8a, $0f, $7c, $78, $78, $65, $65, $73, $54, $56, $0d, $56, $0e, $8b
	db $0f, $3c, $78, $46, $34, $46, $3b, $47, $78, $f8, $75, $05, $0e, $88, $0f, $1a
	db $1b, $a2, $20, $20, $1a, $1b, $03, $20, $89, $78, $1a, $1b, $48, $78, $24, $25
	db $65, $3c, $05, $78, $81, $0d, $03, $0e, $83, $68, $7f, $69, $10, $0e, $8a, $0f
	db $fd, $78, $78, $65, $65, $3a, $3a, $78, $0d, $56, $0e, $81, $2e, $09, $06, $06
	db $0e, $81, $2e, $0b, $06, $83, $6a, $6b, $6c, $0a, $06, $81, $2f, $03, $0e, $83
	db $68, $7f, $69, $10, $0e, $81, $2e, $08, $06, $81, $2f, $56, $0e, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
