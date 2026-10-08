INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $000", ROM0[$0]

;@ def JumpTable(index: a)
;@ path: system/vectors
;@ Jump-table dispatch, used as `rst $00`: the `rst` is followed by a table of
;@ 16-bit addresses, and execution continues at entry `index` of that table
;@ (it falls into JumpToPointer).
;@ test: skip rewrites the return address on the stack
JumpTable::
;> table = pop_return_address()          # the table starts right after `rst $00`
	pop hl
;> return JumpToPointer(table + 2 * index)
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a

;@ def JumpToPointer(ptr: hl)
;@ path: system/vectors
;@ `rst $08`: jumps to the address stored at `ptr`. FarCall calls it to enter a
;@ routine through a bank's table of entry points. The four bytes after it are an
;@ unused copy that returns the address instead of jumping.
;@ test: skip jumps to a computed address
JumpToPointer::
;> return call(mem16[ptr])
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl


	db $2a, $66, $6f, $c9

;@ def FarCall(target: hl)
;@ path: system/bank
;@ `rst $10`: calls a routine in another ROM bank. `target` is a far-call number:
;@ the high byte is the bank, the low byte the entry in that bank's table of
;@ entry points at $4001. The current bank (each bank keeps its own number in its
;@ first byte, $4000) is switched back afterwards. Bits 5-6 of the bank number
;@ also go to the cartridge RAM bank register ($4100), so every bank switch
;@ selects a RAM bank too.
;@ test: skip calls a routine from another bank's table
FarCall::
;> saved = mem[0x4000]                   # number of the bank switched in now
	ld a, [$4000]
	push af
;> set_rom_bank(hi(target))
	ld a, h
	ld [$2100], a
;> mem[0x4100] = (hi(target) >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
;> call(mem16[0x4001 + 2 * lo(target)])
	add hl, hl
	ld h, $00
	ld bc, $4001
	add hl, bc
	call JumpToPointer
;> set_rom_bank(saved)
	pop af
	ld [$2100], a
;> mem[0x4100] = (saved >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
	ret


	db $ff, $1e, $01, $1a, $3c, $12, $c9, $ff, $ff

;@ def VBlankInterrupt()
;@ path: system/vectors
;@ Interrupt vector $40: disables further interrupts and runs the VBlank handler.
;@ test: skip interrupt vector
VBlankInterrupt::
;> disable_interrupts()
	di
;> return VBlankHandler()
	jp VBlankHandler


	db $01, $1a, $18, $b8

;@ def LCDCInterrupt()
;@ path: system/vectors
;@ Interrupt vector $48 (LCD STAT).
;@ test: skip interrupt vector
LCDCInterrupt::
;> return LCDInterruptHandler()
	jp LCDInterruptHandler


	db $fa, $90, $cd, $18, $b0

;@ def TimerOverflowInterrupt()
;@ path: system/vectors
;@ Interrupt vector $50: the timer interrupt is not used, it just returns.
;@ test: skip interrupt vector
TimerOverflowInterrupt::
;> return
	reti


	db $fa, $02, $c0, $b7, $c9, $ff, $ff

;@ def SerialTransferCompleteInterrupt()
;@ path: system/vectors
;@ Interrupt vector $58 (link cable byte done). The bytes after it are leftovers
;@ of an older VBlank handler that nothing reaches.
;@ test: skip interrupt vector
SerialTransferCompleteInterrupt::
;> return Jump_000_2edd()
	jp Jump_000_2edd


	db $d9, $ff, $ff, $ff, $ff, $d9, $f3, $f5, $c5, $d5, $e5, $21, $40, $ff, $cb, $86
	db $cb, $8e, $21, $c2, $dd, $34, $fa, $84, $c9, $b7, $20, $34, $3c, $ea, $84, $c9
	db $cd, $90, $ff, $cd, $f7

;@ def CopyOAMDMARoutine()
;@ path: gfx/oam
;@ Copies the 10-byte OAM DMA routine to HRAM $FF80, where it can run while the
;@ DMA blocks the rest of the address space.
;@ test: skip writes the HRAM routine the VBlank handler runs
CopyOAMDMARoutine::
;> for i in range(10):
	ld c, $80
	ld b, $0a
	ld hl, OAMDMARoutine

.copy
;>     mem[0xFF80 + i] = mem[OAMDMARoutine + i]
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, .copy

	ret


;@ path: gfx/oam
;@ The OAM DMA routine, run from HRAM $FF80 (CopyOAMDMARoutine puts it there):
;@ `ld a, $C0` / `ldh [rDMA], a` / `ld a, $28` / `.wait dec a` / `jr nz, .wait` / `ret` -
;@ copies the shadow OAM at $C000 (wShadowOAM) to OAM and waits the 160 cycles
;@ the transfer takes.
OAMDMARoutine::
	db $3e, $c0, $e0, $46, $3e, $28, $3d, $20, $fd, $c9

;@ path: unused/leftovers
;@ Leftover bytes of an older interrupt handler (pieces of a VBlank handler that
;@ pushes registers, runs the DMA, and copies scroll and palette registers).
;@ Nothing jumps here.
UnusedOldInterruptCode::
	db $13, $cd, $90, $12, $cd, $00
	db $40, $cd, $ba, $17, $af, $ea, $84, $c9, $e1, $d1, $c1, $f1, $d9, $cd, $c2, $00
	db $af, $e0, $0f, $fa, $99, $c9, $e0, $ff, $fb, $cd, $ed, $04, $e1, $d1, $c1, $f1
	db $cd, $a7, $04, $d9, $21, $91, $c9, $2a, $e0, $42, $2a, $e0, $43, $2a, $e0, $4a
	db $2a, $e0, $4b, $2a, $e0, $47, $2a, $e0, $48, $2a, $e0, $49, $7e, $e0, $45, $fa
	db $c1, $dd, $ea, $c0, $dd, $fa, $90, $c9, $e0, $40, $fa, $c7, $dd, $b7, $c8, $c3
	db $14, $12, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff

;@ def Boot()
;@ path: system/boot
;@ Cartridge entry point at $0100 (the boot ROM jumps here with the console type in a).
;@ test: skip entry point
Boot::
;> return Start()
	nop
	jp Start


;@ path: system/header
;@ Cartridge header: the Nintendo logo the boot ROM checks.
;@ asset: tiles bpp=1 length=$30
HeaderLogo::
	db $ce, $ed, $66, $66, $cc, $0d, $00, $0b, $03, $73, $00, $83, $00, $0c, $00, $0d
	db $00, $08, $11, $1f, $88, $89, $00, $0e, $dc, $cc, $6e, $e6, $dd, $dd, $d9, $99
	db $bb, $bb, $67, $63, $6e, $0e, $ec, $cc, $dd, $dc, $99, $9f, $bb, $b9, $33, $3e

;@ path: system/header
;@ Cartridge header: game title "DRAGON WMON".
HeaderTitle::
	db "DRAGON WMON"

;@ path: system/header
;@ Cartridge header: game code "AWQE" (the E is the region: North America).
HeaderManufacturerCode::
	db "AWQE"

;@ path: system/header
;@ Cartridge header: $80 = uses Game Boy Color features but also runs on a Game Boy.
HeaderCGBFlag::
	db $80

;@ path: system/header
;@ Cartridge header: new licensee code "4F".
HeaderNewLicenseeCode::
	db $34, $46

;@ path: system/header
;@ Cartridge header: $03 = Super Game Boy functions supported.
HeaderSGBFlag::
	db $03

;@ path: system/header
;@ Cartridge header: $1B = MBC5 with RAM and battery.
HeaderCartridgeType::
	db $1b

;@ path: system/header
;@ Cartridge header: $06 = 2 MiB ROM (128 banks).
HeaderROMSize::
	db $06

;@ path: system/header
;@ Cartridge header: $02 = 8 KiB cartridge RAM.
HeaderRAMSize::
	db $02

;@ path: system/header
;@ Cartridge header: $01 = sold outside Japan.
HeaderDestinationCode::
	db $01

;@ path: system/header
;@ Cartridge header: $33 = the licensee is given by the new licensee code.
HeaderOldLicenseeCode::
	db $33

;@ path: system/header
;@ Cartridge header: ROM version 0.
HeaderMaskROMVersion::
	db $00

;@ path: system/header
;@ Cartridge header: checksum of the header bytes $0134-$014C.
HeaderComplementCheck::
	db $49

;@ path: system/header
;@ Cartridge header: checksum of the whole ROM (big endian).
HeaderGlobalChecksum::
	db $52, $71

;@ def Start(console: a)
;@ path: system/boot
;@ First code after the header: the boot ROM leaves $11 in a on a Game Boy
;@ Color. Remembers that in wOnCGB, then continues into SoftReset.
;@ test: skip falls through into SoftReset
Start::
;> on_cgb = 1 if console == 0x11 else 0
	cp $11
	ld a, $00
	jr nz, .store

	inc a

.store
;> wOnCGB = on_cgb                       # and on into SoftReset
	ld [wOnCGB], a

;@ def SoftReset()
;@ path: system/boot
;@ Starts (or restarts, after A+B+Select+Start or a lost link) the game: clears
;@ RAM and VRAM, sets up the cartridge, looks for a Super Game Boy and sends it
;@ its setup packets, border tiles and border picture. Then the main loop: start
;@ the current game mode, and while it runs (its per-frame work happens in the
;@ VBlank handler) keep stirring the random numbers until the mode asks to be
;@ replaced; then start the new one.
;@ test: skip never returns
SoftReset::
;> reset_stack(0xDFFF)
	ld sp, $dfff
;> DisableInterruptsAndLCD()
	call DisableInterruptsAndLCD
;> ClearRAM()
	call ClearRAM
;> CopyOAMDMARoutine()
	call CopyOAMDMARoutine
;> FillMemory(0x8000, 0x1C00, 0)          # all tiles and both maps of VRAM bank 0
	ld hl, $8000
	ld bc, $1c00
	xor a
	call FillMemory
;> fill(wGameMode, 0, 4)                  # mode, step and two mode variables
	ld hl, wGameMode
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
;> mem[0xC8EE] = 4
	ld a, $04
	ld [$c8ee], a
;> wGameMode = 0
	ld a, $00
	ld [wGameMode], a
;> mem[0x6100] = 1                        # cartridge registers: RAM bank 0 ...
	ld a, $01
	ld [$6100], a
;> mem[0x4100] = 0
	ld a, $00
	ld [$4100], a
;> mem[0x6100] = 0
	ld a, $00
	ld [$6100], a
;> mem[0x4100] = 0
	ld a, $00
	ld [$4100], a
;> mem[0x0100] = 0x0A                     # ... cartridge RAM enabled ...
	ld a, $0a
	ld [$0100], a
;> set_rom_bank(1)                        # ... ROM bank 1
	ld a, $01
	ld [$2100], a
;> mem[0x4100] = 0
	ld a, $00
	ld [$4100], a
;> wOnSGB = 1                             # so that DetectSGB's packets are sent
	ld a, $01
	ld [wOnSGB], a
;> wQueuedMusic = 0xFF
	ld a, $ff
	ld [wQueuedMusic], a
;> wQueuedSound = 0xFF
	ld [wQueuedSound], a
;> InitSound()                            # silence the sound
	call InitSound
;> wLinkNoEnd = 0
	xor a
	ld [wLinkNoEnd], a
;> if wOnCGB:
	ld a, [wOnCGB]
	or a
	jr z, .detectSGB

;>     rVBK = 0
	xor a
	ldh [rVBK], a
;>     rSVBK = 0
	ldh [rSVBK], a
;>     rRP = 0
	ldh [rRP], a

.detectSGB
;> if not DetectSGB():                    # carry = a Super Game Boy answered
	call DetectSGB
	jr c, .sgb

;>     wOnSGB = 0
	xor a
	ld [wOnSGB], a
	jp .startMode

;> else:
.sgb
;>     SGBDelay(12)
	ld bc, $000c
	call SGBDelay
;>@pk1     for packet in [0x14, 2, 3, 4, 5, 6, 7, 8, 9]:   # setup packets from the packet table
	ld a, $14
;>         wSGBPacketID = packet
	ld [wSGBPacketID], a
;>         SendSGBPacket()                # packet wSGBPacketID
	ld hl, far_SendSGBPacket
	rst $10
;>         SGBPacketDelay()
	call SGBPacketDelay
;=@pk1
	ld a, $02
	ld [wSGBPacketID], a
	ld hl, far_SendSGBPacket
	rst $10
	call SGBPacketDelay
;=@pk1
	ld a, $03
	ld [wSGBPacketID], a
	ld hl, far_SendSGBPacket
	rst $10
	call SGBPacketDelay
;=@pk1
	ld a, $04
	ld [wSGBPacketID], a
	ld hl, far_SendSGBPacket
	rst $10
	call SGBPacketDelay
;=@pk1
	ld a, $05
	ld [wSGBPacketID], a
	ld hl, far_SendSGBPacket
	rst $10
	call SGBPacketDelay
;=@pk1
	ld a, $06
	ld [wSGBPacketID], a
	ld hl, far_SendSGBPacket
	rst $10
	call SGBPacketDelay
;=@pk1
	ld a, $07
	ld [wSGBPacketID], a
	ld hl, far_SendSGBPacket
	rst $10
	call SGBPacketDelay
;=@pk1
	ld a, $08
	ld [wSGBPacketID], a
	ld hl, far_SendSGBPacket
	rst $10
	call SGBPacketDelay
;=@pk1
	ld a, $09
	ld [wSGBPacketID], a
	ld hl, far_SendSGBPacket
	rst $10
	call SGBPacketDelay
;>     SGBTransfer(0x0C, 0x08, 0x03, 0x800)   # border tiles: packet $0C, bank $08 entry 3, $800 bytes
	ld a, $0c
	ld de, $0803
	ld bc, $0800
	call SGBTransfer
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     SGBTransferCompressed(0x0D, 0x08, 0x04)  # border map and palettes: packet $0D, bank $08 entry 4
	ld a, $0d
	ld de, $0804
	call SGBTransferCompressed
;>     SGBPacketDelay()
	call SGBPacketDelay
;>@pk2     for packet in [0x12, 0x0A, 0x13]:
	ld a, $12
;>         wSGBPacketID = packet
	ld [wSGBPacketID], a
;>         SendSGBPacket()
	ld hl, far_SendSGBPacket
	rst $10
;>         SGBPacketDelay()
	call SGBPacketDelay
;=@pk2
	ld a, $0a
	ld [wSGBPacketID], a
	ld hl, far_SendSGBPacket
	rst $10
	call SGBPacketDelay
;=@pk2
	ld a, $13
	ld [wSGBPacketID], a
	ld hl, far_SendSGBPacket
	rst $10
	call SGBPacketDelay
;>     wOnSGB = 1
	ld a, $01
	ld [wOnSGB], a
;>     mem[0xC81B] = 0xFF
	ld a, $ff
	ld [$c81b], a

.startMode
;>@mode for _ in forever():                # each pass starts wGameMode anew
;>     ClearBGMaps()
	call ClearBGMaps
;>     ClearShadowOAM()
	call ClearShadowOAM
;>     InitPalettes()
	call InitPalettes
;>     ClearScroll()
	call ClearScroll
;>     InitFade()
	call InitFade
;>     wLinkReceived = 0
	xor a
	ld [wLinkReceived], a
;>     wTextState = 0
	ld [wTextState], a
;>     wTextBoxWidth = 0
	ld [wTextBoxWidth], a
;>     wTextBoxHeight = 0
	ld [wTextBoxHeight], a
;>     wLinkTimeout = 0
	ld [wLinkTimeout], a
	ld [wLinkTimeout + 1], a
;>     mem[0xDF0E] = 0
	ld [wNameCleared], a
;>     InitGameMode()
	call InitGameMode
;>     wGameModeChange = 0
	xor a
	ld [wGameModeChange], a
;>     wMapLoadState = 0
	ld [wMapLoadState], a
;>     wMapUpdateOn = 0
	ld [wMapUpdateOn], a
;>     wMapUpdateDest = 0
	ld [wMapUpdateDest], a
	ld [wMapUpdateDest + 1], a
;>     wVBlankFlags = 0
	ld [wVBlankFlags], a
;>     wFrameCounter = 0
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
;>     hSpriteClip = 0
	ldh [hSpriteClip], a
;>     wSoundBusy = 0
	ld [wSoundBusy], a
;>     wDecompressBusy = 0
	ld [wDecompressBusy], a
;>     fill(wShakeY, 0, 4)                # no screen shake
	ld hl, wShakeY
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a

.wait
;>@w     while True:                      # the mode runs from the VBlank handler meanwhile
;>         if not wLinkActive:            # linked games must keep their random numbers in step
	ld a, [wLinkActive]
	or a
;>             Random()
	call z, Random
;>         if not wGameModeChange:
;>             continue
	ld a, [wGameModeChange]
	or a
	jr z, .wait

;>         if wFadeState == 0 or wFadeState & 0x80:   # wait while a fade-out runs
;>             break
	ld a, [wFadeState]
	or a
	jr z, .change

	bit 7, a
;=@w
	jr z, .wait

.change
;>     disable_interrupts()
	di
;>     if wLinkActive:
	ld a, [wLinkActive]
	or a
;>         InitSound()                    # silence the sound
	call nz, InitSound
;>     DisableInterruptsAndLCD()
	call DisableInterruptsAndLCD
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     wSGBPacketID = 0
	ld a, $00
	ld [wSGBPacketID], a
;>     SendSGBPacket()                    # SGB packet 0
	ld hl, far_SendSGBPacket
	rst $10
;>     SGBPacketDelay()
	call SGBPacketDelay
;=@mode
	jp .startMode


;@ def InitGameMode()
;@ path: system/modes
;@ Runs the start-up routine of the current game mode (wGameMode).
;@ test: skip calls routines in other banks
InitGameMode::
;> GameModeInitTable[wGameMode]()
	ld a, [wGameMode]
	rst $00

;@ path: system/modes
;@ Start-up routine of each game mode, indexed by wGameMode (13 modes, $00-$0C).
;@ GameModeUpdateTable has the matching per-frame routines. Modes $07 and $0C
;@ are debug menus (opened by a button combination in the VBlank handler, which
;@ is switched off).
GameModeInitTable::
	dw InitGameMode00
	dw InitGameMode01
	dw InitGameMode02
	dw InitGameMode03
	dw InitGameMode04
	dw InitGameMode05
	dw InitGameMode06
	dw InitGameMode07
	dw InitGameMode08
	dw InitGameMode09
	dw InitGameMode0A
	dw InitGameMode0B
	dw InitGameMode0C

;@ def InitGameMode00()
;@ path: system/modes
;@ Starts game mode $00 (bank $15).
;@ test: skip calls a routine in another bank
InitGameMode00::
;> Call_15_4009()
	ld hl, far_Call_15_4009
	rst $10
	ret


;@ def InitGameMode01()
;@ path: system/modes
;@ Starts game mode $01, the field (bank $01).
;@ test: skip calls a routine in another bank
InitGameMode01::
;> FieldInit()
	ld hl, far_FieldInit
	rst $10
	ret


;@ def InitGameMode02()
;@ path: system/modes
;@ Starts game mode $02 (bank $50).
;@ test: skip calls a routine in another bank
InitGameMode02::
;> Call_50_5DC9()
	ld hl, far_Call_50_5DC9
	rst $10
	ret


;@ def InitGameMode03()
;@ path: system/modes
;@ Starts game mode $03 (bank $02).
;@ test: skip calls a routine in another bank
InitGameMode03::
;> InitCutscene()
	ld hl, far_InitCutscene
	rst $10
	ret


;@ def InitGameMode04()
;@ path: system/modes
;@ Starts game mode $04 (bank $5F).
;@ test: skip calls a routine in another bank
InitGameMode04::
;> Call_5F_4017()
	ld hl, far_Call_5F_4017
	rst $10
	ret


;@ def InitGameMode05()
;@ path: system/modes
;@ Starts game mode $05 (bank $5F).
;@ test: skip calls a routine in another bank
InitGameMode05::
;> Call_5F_5BB7()
	ld hl, far_Call_5F_5BB7
	rst $10
	ret


;@ def InitGameMode06()
;@ path: system/modes
;@ Starts game mode $06: entry 0 of bank $18.
;@ test: skip calls a routine in another bank
InitGameMode06::
;> far_call(0x18, 0x00)
	ld hl, $1800
	rst $10
	ret

;@ def InitGameMode07()
;@ path: system/modes
;@ Starts game mode $07, a debug menu: entry $0D of bank $55.
;@ test: skip calls a routine in another bank
InitGameMode07::
;> far_call(0x55, 0x0D)
	ld hl, $550d
	rst $10
	ret

;@ def InitGameMode08()
;@ path: system/modes
;@ Starts game mode $08: entry 0 of bank $59.
;@ test: skip calls a routine in another bank
InitGameMode08::
;> far_call(0x59, 0x00)
	ld hl, $5900
	rst $10
	ret

;@ def InitGameMode09()
;@ path: system/modes
;@ Starts game mode $09: entry 2 of bank $59.
;@ test: skip calls a routine in another bank
InitGameMode09::
;> far_call(0x59, 0x02)
	ld hl, $5902
	rst $10
	ret

;@ def InitGameMode0A()
;@ path: system/modes
;@ Starts game mode $0A: entry 4 of bank $59.
;@ test: skip calls a routine in another bank
InitGameMode0A::
;> far_call(0x59, 0x04)
	ld hl, $5904
	rst $10
	ret

;@ def InitGameMode0B()
;@ path: system/modes
;@ Starts game mode $0B: entry 3 of bank $56.
;@ test: skip calls a routine in another bank
InitGameMode0B::
;> far_call(0x56, 0x03)
	ld hl, $5603
	rst $10
	ret

;@ def InitGameMode0C()
;@ path: system/modes
;@ Starts game mode $0C, a debug menu: entry 7 of bank $56.
;@ test: skip calls a routine in another bank
InitGameMode0C::
;> far_call(0x56, 0x07)
	ld hl, $5607
	rst $10
	ret

;@ def VBlankHandler()
;@ path: system/vblank
;@ The VBlank interrupt, and the heart of the game: besides the screen updates
;@ (sprites by DMA, the queued map row, palettes, scroll, screen shake, LCDC) it
;@ reads the pad, runs the sound engine and then, with interrupts enabled again,
;@ the current game mode's per-frame routine, the text printer and the palette
;@ fade. If that work is still running when the next VBlank comes, the new
;@ interrupt only writes LCDC and updates the sound. Holding A+B+Select+Start
;@ restarts the game (not while linked).
;@ test: skip interrupt handler (ends in reti)
VBlankHandler::
;> # (all registers are saved and restored)
	push af
	push bc
	push de
	push hl
;>@busy if wVBlankFlags & 1:              # the previous frame's work is still running
	ld hl, wVBlankFlags
	bit 0, [hl]
	jp nz, .busy

;>@b1     ApplyLCDC()
;>@b2     if not wSoundBusy:
;>@b3         UpdateSound()                 # sound engine update
;>@b4     enable_interrupts()
;> else:
;>     wVBlankFlags |= 1
	set 0, [hl]
;>     hOAMDMA()                          # copy wShadowOAM to OAM
	call hOAMDMA
;>     VBlankMapUpdate()
	call VBlankMapUpdate
;>     ApplyPalettes()
	call ApplyPalettes
;>     ApplyScroll()
	call ApplyScroll
;>     UpdateScreenShake()
	call UpdateScreenShake
;>     ApplyLCDC()
	call ApplyLCDC
;>     if wLinkActive:                    # linked: the sound runs before the game logic
	ld a, [wLinkActive]
	or a
	jr z, .soundDone

;>         if not wSoundBusy:
;>             UpdateSound()
	ld a, [wSoundBusy]
	or a
	call z, UpdateSound

.soundDone
;>     enable_interrupts()
	ei
;>     if not wLinkActive:                # (linked games read the pad in LinkFrameUpdate)
	ld a, [wLinkActive]
	or a
	jr nz, .logic

;>         ReadJoypad()
	call ReadJoypad
;>         UpdateJoypadPresses()
	call UpdateJoypadPresses
;>         wSoundBusy += 1
	ld hl, wSoundBusy
	inc [hl]
;>         UpdateSound()                    # sound engine update
	call UpdateSound
;>         wSoundBusy = 0
	xor a
	ld [wSoundBusy], a

.logic
;>     PlayQueuedSounds()
	call PlayQueuedSounds
;>     UpdateGameModeFrame()
	call UpdateGameModeFrame
;>     if not wLinkActive:
	ld a, [wLinkActive]
	or a
	jr nz, .checkReset

;>         if wTextState:
;>             UpdateText()
	ld a, [wTextState]
	or a
	call nz, UpdateText
;>         UpdateFade()
	call UpdateFade
;>         wFrameCounter += 1
	ld a, [wFrameCounter]
	add $01
	ld [wFrameCounter], a
	ld a, [wFrameCounter + 1]
	adc $00
	ld [wFrameCounter + 1], a

.checkReset
;>     if wJoyHeld & 0x0F == 0x0F:        # A+B+Select+Start
	ld a, [wJoyHeld]
	and $0f
	cp $0f
	jr nz, .debug

;>         if not wLinkActive:
;>             return SoftReset()
	ld a, [wLinkActive]
	or a
	jp z, SoftReset

.debug
;>     if not wLinkActive:
	ld a, [wLinkActive]
	or a
	jr nz, .done

;>         if wJoyHeld & 3 == 3 and False:   # A+B held: debug menus, switched off (the jump always skips them)
	ld a, [wJoyHeld]
	and $03
	cp $03
	jr .done

;>             if wJoyPressed & 0x04:     # Select: debug menu $07
	ld a, [wJoyPressed]
	bit 2, a
	jr z, .debug2

;>                 wDebugSavedMode[0] = wGameMode
	ld hl, wDebugSavedMode
	ld a, [wGameMode]
	ld [hli], a
;>                 wDebugSavedMode[1] = wGameModeStep
	ld a, [wGameModeStep]
	ld [hli], a
;>                 wDebugSavedMode[2] = mem[0xC88C]
	ld a, [$c88c]
	ld [hli], a
;>                 wDebugSavedMode[3] = mem[0xC88D]
	ld a, [$c88d]
	ld [hl], a
;>                 wGameMode = 0x07
	ld a, $07
	ld [wGameMode], a
;>                 wGameModeStep = 0
	xor a
	ld [wGameModeStep], a
;>                 wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]

.debug2
;>             if wJoyHeld & 0x08 and wJoyPressed & 0x04:   # Start held, Select: debug menu $0C
	ld a, [wJoyHeld]
	bit 3, a
	jr z, .done

	ld a, [wJoyPressed]
	bit 2, a
	jr z, .done

;>                 wDebugSavedMode[0] = wGameMode
	ld hl, wDebugSavedMode
	ld a, [wGameMode]
	ld [hli], a
;>                 wDebugSavedMode[1] = wGameModeStep
	ld a, [wGameModeStep]
	ld [hli], a
;>                 wDebugSavedMode[2] = mem[0xC88C]
	ld a, [$c88c]
	ld [hli], a
;>                 wDebugSavedMode[3] = mem[0xC88D]
	ld a, [$c88d]
	ld [hl], a
;>                 wGameMode = 0x0C
	ld a, $0c
	ld [wGameMode], a
;>                 wGameModeStep = 0
	xor a
	ld [wGameModeStep], a
;>                 wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]

.done
;>     wVBlankFlags &= ~1
	ld hl, wVBlankFlags
	res 0, [hl]

.exit
;> wVBlankEndLY = rLY
	ldh a, [rLY]
	ld [wVBlankEndLY], a
;> return                                 # registers restored, reti
	pop hl
	pop de
	pop bc
	pop af
	reti


.busy
;=@b1
	call ApplyLCDC
;=@b2
	ld a, [wSoundBusy]
	or a
	jr nz, .busyDone

;=@b3
	call UpdateSound

.busyDone
;=@b4
	ei
	jr .exit

;@ def UpdateGameModeFrame()
;@ path: system/modes
;@ Per-frame game work done by the VBlank handler: starts a new sprite list, runs
;@ the current game mode, then hides the sprite slots it did not use (not while
;@ the screen fades out, so the last picture stays).
;@ test: skip calls game mode routines in other banks
UpdateGameModeFrame::
;> hOAMCount = 0
	xor a
	ldh [hOAMCount], a
;> UpdateGameMode()
	call UpdateGameMode
;> if wFadeState and not wFadeState & 0x80:   # fading out
;>     return
	ld a, [wFadeState]
	or a
	jr z, .hide

	bit 7, a
	ret z

.hide
;> HideUnusedSprites()
	call HideUnusedSprites
	ret


;@ def LinkFrameUpdate()
;@ path: link/frame
;@ Called every frame by the game modes while two Game Boys are linked. Counts
;@ the frames since the partner last answered (after 256 the game restarts),
;@ keeps the own pad state for the partner, reads the pad, and starts the next
;@ transfer as master: the single byte in wLinkSendByte, else the next byte of
;@ the send buffer, else $F0 (nothing to say).
;@ test: skip starts a serial transfer
LinkFrameUpdate::
;> if not wLinkActive:
;>     return
	ld a, [wLinkActive]
	or a
	ret z

;> wLinkTimeout += 1
	ld a, [wLinkTimeout]
	add $01
	ld [wLinkTimeout], a
	ld a, [wLinkTimeout + 1]
	adc $00
	ld [wLinkTimeout + 1], a
;> if wLinkTimeout >= 0x100:              # the partner is gone
;>     return SoftReset()
	ld a, [wLinkTimeout + 1]
	or a
	jp nz, SoftReset

;> if wLinkFlags & 0x02:
;>     return
	ld a, [wLinkFlags]
	bit 1, a
	ret nz

;> if wVBlankFlags & 0x02:
;>     return
	ld a, [wVBlankFlags]
	bit 1, a
	ret nz

;> wLinkJoyHeld = wJoyHeld
	ld a, [wJoyHeld]
	ld [wLinkJoyHeld], a
;> wLinkJoyHeldLast = wJoyHeldLast
	ld a, [wJoyHeldLast]
	ld [wLinkJoyHeldLast], a
;> ReadJoypad()
	call ReadJoypad
;> if wLinkSendByte != 0xFF:
	ld a, [wLinkSendByte]
	cp $ff
	jr z, .buffer

;>     wLinkPhase = 0
	ld a, $00
	ld [wLinkPhase], a
;>     return SerialSendMaster(wLinkSendByte)
	ld a, [wLinkSendByte]
	jp SerialSendMaster


.buffer
;> if wLinkSendLength:
	ld hl, wLinkSendLength
	ld a, [hli]
	or [hl]
	jr z, .nothing

;>     ptr = wLinkSendPtr
	ld a, [wLinkSendPtr]
	ld l, a
	ld a, [wLinkSendPtr + 1]
	ld h, a
	push hl
;>     wLinkSendPtr += 1
	ld a, [wLinkSendPtr]
	add $01
	ld [wLinkSendPtr], a
	ld a, [wLinkSendPtr + 1]
	adc $00
	ld [wLinkSendPtr + 1], a
;>     wLinkPhase = 0
	pop hl
	ld a, $00
	ld [wLinkPhase], a
;>     return SerialSendMaster(mem[ptr])
	ld a, [hl]
	jp SerialSendMaster


.nothing
;> wLinkPhase = 0
	ld a, $00
	ld [wLinkPhase], a
;> return SerialSendMaster(0xF0)
	ld a, $f0
	jp SerialSendMaster


;@ def UpdateGameMode()
;@ path: system/modes
;@ Runs the per-frame routine of the current game mode, unless a mode change is
;@ pending or (without a link) the screen is fading out.
;@ test: skip calls routines in other banks
UpdateGameMode::
;> if wGameModeChange:
;>     return
	ld a, [wGameModeChange]
	or a
	ret nz

;> if not wLinkActive and wFadeState and not wFadeState & 0x80:
	ld a, [wLinkActive]
	or a
	jr nz, .run

	ld a, [wFadeState]
	or a
	jr z, .run

;>     return
	bit 7, a
	ret z

.run
;> GameModeUpdateTable[wGameMode]()
	ld a, [wGameMode]
	rst $00

;@ path: system/modes
;@ Per-frame routine of each game mode, indexed by wGameMode (see GameModeInitTable).
GameModeUpdateTable::
	dw UpdateGameMode00
	dw UpdateGameMode01
	dw UpdateGameMode02
	dw UpdateGameMode03
	dw UpdateGameMode04
	dw UpdateGameMode05
	dw UpdateGameMode06
	dw UpdateGameMode07
	dw UpdateGameMode08
	dw UpdateGameMode09
	dw UpdateGameMode0A
	dw UpdateGameMode0B
	dw UpdateGameMode0C

;@ def UpdateGameMode00()
;@ path: system/modes
;@ Per-frame routine of game mode $00: entry 1 of bank $15.
;@ test: skip calls a routine in another bank
UpdateGameMode00::
;> far_call(0x15, 0x01)
	ld hl, $1501
	rst $10
	ret


;@ def UpdateGameMode01()
;@ path: system/modes
;@ Per-frame routine of game mode $01, the field: entry 1 of bank $01.
;@ test: skip calls a routine in another bank
UpdateGameMode01::
;> far_call(0x01, 0x01)
	ld hl, $0101
	rst $10
	ret


;@ def UpdateGameMode02()
;@ path: system/modes
;@ Per-frame routine of game mode $02 (bank $50).
;@ test: skip calls a routine in another bank
UpdateGameMode02::
;> Call_50_5E21()
	ld hl, far_Call_50_5E21
	rst $10
	ret


;@ def UpdateGameMode03()
;@ path: system/modes
;@ Per-frame routine of game mode $03 (bank $02).
;@ test: skip calls a routine in another bank
UpdateGameMode03::
;> RunCutscene()
	ld hl, far_RunCutscene
	rst $10
	ret


;@ def UpdateGameMode04()
;@ path: system/modes
;@ Per-frame routine of game mode $04 (bank $5F).
;@ test: skip calls a routine in another bank
UpdateGameMode04::
;> Call_5F_40F7()
	ld hl, far_Call_5F_40F7
	rst $10
	ret


;@ def UpdateGameMode05()
;@ path: system/modes
;@ Per-frame routine of game mode $05 (bank $5F).
;@ test: skip calls a routine in another bank
UpdateGameMode05::
;> Call_5F_5C8D()
	ld hl, far_Call_5F_5C8D
	rst $10
	ret


;@ def UpdateGameMode06()
;@ path: system/modes
;@ Per-frame routine of game mode $06 (bank $18).
;@ test: skip calls a routine in another bank
UpdateGameMode06::
;> Call_18_42DE()
	ld hl, far_Call_18_42DE
	rst $10
	ret


;@ def UpdateGameMode07()
;@ path: system/modes
;@ Per-frame routine of game mode $07, a debug menu: entry $0E of bank $55.
;@ test: skip calls a routine in another bank
UpdateGameMode07::
;> far_call(0x55, 0x0E)
	ld hl, $550e
	rst $10
	ret

;@ def UpdateGameMode08()
;@ path: system/modes
;@ Per-frame routine of game mode $08: entry 1 of bank $59.
;@ test: skip calls a routine in another bank
UpdateGameMode08::
;> far_call(0x59, 0x01)
	ld hl, $5901
	rst $10
	ret

;@ def UpdateGameMode09()
;@ path: system/modes
;@ Per-frame routine of game mode $09: entry 3 of bank $59.
;@ test: skip calls a routine in another bank
UpdateGameMode09::
;> far_call(0x59, 0x03)
	ld hl, $5903
	rst $10
	ret

;@ def UpdateGameMode0A()
;@ path: system/modes
;@ Per-frame routine of game mode $0A: entry 5 of bank $59.
;@ test: skip calls a routine in another bank
UpdateGameMode0A::
;> far_call(0x59, 0x05)
	ld hl, $5905
	rst $10
	ret

;@ def UpdateGameMode0B()
;@ path: system/modes
;@ Per-frame routine of game mode $0B: entry 4 of bank $56.
;@ test: skip calls a routine in another bank
UpdateGameMode0B::
;> far_call(0x56, 0x04)
	ld hl, $5604
	rst $10
	ret

;@ def UpdateGameMode0C()
;@ path: system/modes
;@ Per-frame routine of game mode $0C, a debug menu: entry 8 of bank $56.
;@ test: skip calls a routine in another bank
UpdateGameMode0C::
;> far_call(0x56, 0x08)
	ld hl, $5608
	rst $10
	ret

;@ def UpdateScreenShake()
;@ path: gfx/scroll
;@ Shakes the screen while wShakeY / wShakeX count down: each frame the scroll
;@ register is moved by -4..+3 pixels following a triangle wave of the timer.
;@ (ApplyScroll has just written the real position, so the shake never sticks.)
UpdateScreenShake::
;> if wShakeY:
	ld a, [wShakeY]
	or a
	jr z, .x

;>     wShakeY -= 1
	dec a
	ld [wShakeY], a
;>     t = wShakeY * 2
	ldh a, [rSCY]
	ld b, a
	ld a, [wShakeY]
	add a
	ld c, a
;>     wave = t & 7 if t & 8 else (t & 7) ^ 7
	and $07
	bit 3, c
	jr nz, .y

	xor $07

.y
;>     rSCY = u8(rSCY + wave - 4)
	sub $04
	add b
	ldh [rSCY], a

.x
;> if wShakeX:
	ld a, [wShakeX]
	or a
	jr z, .done

;>     wShakeX -= 1
	dec a
	ld [wShakeX], a
;>     t = wShakeX * 2
	ldh a, [rSCX]
	ld b, a
	ld a, [wShakeX]
	add a
	ld c, a
;>     wave = t & 7 if t & 8 else (t & 7) ^ 7
	and $07
	bit 3, c
	jr nz, .xx

	xor $07

.xx
;>     rSCX = u8(rSCX + wave - 4)
	sub $04
	add b
	ldh [rSCX], a

.done
	ret


;@ def VBlankMapUpdate()
;@ path: gfx/tilemap
;@ Copies the queued background row or column (CopyMapUpdate) when one is on.
VBlankMapUpdate::
;> if not wMapUpdateOn:
;>     return
	ld a, [wMapUpdateOn]
	or a
	ret z

;> CopyMapUpdate()
	call CopyMapUpdate
	ret


;@ def StartText(table: de)
;@ path: text/printer
;@ Starts printing text number wTextGroup/wTextIndex from the two-level pointer
;@ table `table` (in the current bank) into the text box set up by SetUpTextBox:
;@ clears the box's letter tiles, puts the cursor at their start and switches
;@ the text printer on. The text banks call it from their entry points.
;@ test: skip calls a routine in another bank
StartText::
;> Call_56_4485()                         # clear the text box tiles
	push de
	ld hl, far_Call_56_4485
	rst $10
;> tiles = wTextTiles
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
;> text = LookUpTextPointer(table)
	pop de
	call LookUpTextPointer
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


;@ def CopyTextString(table: de)
;@ path: text/printer
;@ Copies text number wTextGroup/wTextIndex from the pointer table `table`, up
;@ to and including its $F0 end mark, to the buffer at wTextCopyDest.
CopyTextString::
;> src = LookUpTextPointer(table)
	call LookUpTextPointer
;> dest = wTextCopyDest
	ld a, [wTextCopyDest]
	ld l, a
	ld a, [wTextCopyDest + 1]
	ld h, a

.copy
;> while True:
;>     c = mem[src]; mem[dest] = c; src += 1; dest += 1
	ld a, [de]
	ld [hli], a
	inc de
;>     if c == 0xF0:
;>         break
	cp $f0
	jr nz, .copy

	ret


;@ def RunTextToEnd()
;@ path: text/printer
;@ Prints the current text without letter delay and waits until it is done
;@ (prompts in it still wait for a button, read by the VBlank handler).
;@ test: skip waits for the pad
RunTextToEnd::
;> wTextState |= 0x02                     # no delay
	ld hl, wTextState
	set 1, [hl]

.loop
;> while True:
;>     UpdateText()
	call UpdateText
;>     if not wTextState:
;>         break
	ld a, [wTextState]
	or a
	jr nz, .loop

	ret


;@ def UpdateText()
;@ path: text/printer
;@ The text printer's per-frame step (the VBlank handler calls it while
;@ wTextState is on). Once a button has sped the text up (wTextFlags bit 7), it
;@ keeps printing letters without delay in this same frame for as long as that
;@ flag stays set.
;@ test: skip runs the text printer
UpdateText::
;> if not wTextFlags & 0x80:
;>     return TextPrinterStep()
	ld a, [wTextFlags]
	bit 7, a
	jr z, TextPrinterStep

.fast
;> while True:
;>     wTextState |= 0x02
	ld hl, wTextState
	set 1, [hl]
;>     TextPrinterStep()
	call TextPrinterStep
;>     if not wTextFlags & 0x80:
;>         break
	ld a, [wTextFlags]
	bit 7, a
	jr nz, .fast

	ret


;@ def TextPrinterStep()
;@ path: text/printer
;@ One step of the text printer, with the text's bank switched in:
;@ - blinks the prompt arrow (box row 3, column 9) while wTextState bit 5 is set;
;@ - bit 2, waiting for a button: for a yes/no question (control code $E6 or
;@   $FF) Up/Down move the arrow between the two lines of the yes/no window
;@   (screen column 15, rows 9 and 11); A answers (yes plays sound $59 unless the
;@   code was $E6), B answers no; then the screen under the window is restored
;@   from wTilemapBuffer and its tiles are reloaded. Otherwise any button except
;@   Start goes on;
;@ - bit 6: a wait that ends after wTextWaitTimer frames or on a button;
;@ - bit 7: a pause of wTextPauseTimer frames;
;@ - else the next byte of the text: $8D/$8E add a diacritic mark to the last
;@   letter, $E0-$FF are control codes (run by Call_56_44C7), anything else is a
;@   letter, drawn once wTextDelay has reached the speed (2 frames, or wTextSpeed);
;@   a button press (not Start) makes the rest print without delay.
;@ test: skip switches banks and calls a routine in another bank
TextPrinterStep::
;> saved = rom_bank()
	ld a, [$4000]
	push af
;> set_rom_bank(wTextBank)
	ld a, [wTextBank]
	ld [$2100], a
;> mem[0x4100] = (wTextBank >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
;> if wTextState:
	ld a, [wTextState]
	or a
	jp z, .done

;>     if wTextState & 0x20:              # the prompt arrow blinks
	bit 5, a
	jr z, .waiting

;>         tile = 0xEE if wFrameCounter & 0x10 else 0xEA   # box background / arrow
	ld c, $ea
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .arrow

	ld c, $ee

.arrow
;>         WriteVRAM(MapAdvanceTiles(TextBoxMapAddress(0x60), 9), tile)
	ld hl, $0060
	call TextBoxMapAddress
	ld b, $09
	call MapAdvanceTiles
	ld a, c
	call WriteVRAM

.waiting
;>     if wTextState & 0x04:              # waiting for a button
	ld a, [wTextState]
	bit 2, a
	jp z, .timedWait

;>         if wTextControlCode in (0xE6, 0xFF):   # a yes/no question
	ld a, [wTextControlCode]
	cp $e6
	jp z, .choice

	ld a, [wTextControlCode]
	cp $ff
	jp nz, .anyButton

.choice
;>             pressed = wJoyPressed | wJoy2Pressed
	ld a, [wJoyPressed]
	ld b, a
	ld a, [wJoy2Pressed]
	or b
;>             if pressed & 0x40:         # Up: yes
	bit 6, a
	jr z, .down

;>                 wTextChoice = 0
	ld a, [wTextChoice]
	cp $00
	jr z, .draw

	ld a, $00
	ld [wTextChoice], a
	jr .draw

.down
;>             elif pressed & 0x80:       # Down: no
	bit 7, a
	jr z, .draw

;>                 wTextChoice = 1
	ld a, [wTextChoice]
	cp $01
	jr z, .draw

	ld a, $01
	ld [wTextChoice], a

.draw
;>             yes_tile, no_tile = 0xE8, 0xE0     # arrow on the "yes" line
	ld c, $e8
	ld b, $e0
;>             if wTextChoice:
;>                 yes_tile, no_tile = 0xE0, 0xE8   # arrow on the "no" line
	ld a, [wTextChoice]
	or a
	jr z, .blink

	ld c, $e0
	ld b, $e8

.blink
;>             if wFrameCounter & 0x10:
;>                 yes_tile, no_tile = 0xE0, 0xE0   # blinked off
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .drawArrows

	ld c, $e0
	ld b, $e0

.drawArrows
;>             pos = MapAdvanceTiles(ScreenMapAddress(0x120), 15)   # screen row 9, column 15
	push bc
	ld hl, $0120
	call ScreenMapAddress
	ld b, $0f
	call MapAdvanceTiles
;>             WriteVRAM(pos, yes_tile)
	pop bc
	ld a, c
	call WriteVRAM
;>             pos = MapAdvanceTiles(ScreenMapAddress(0x160), 15)   # screen row 11, column 15
	push bc
	ld hl, $0160
	call ScreenMapAddress
	ld b, $0f
	call MapAdvanceTiles
;>             WriteVRAM(pos, no_tile)
	pop bc
	ld a, b
	call WriteVRAM
;>             pressed = wJoyPressed | wJoy2Pressed
	ld a, [wJoyPressed]
	ld b, a
	ld a, [wJoy2Pressed]
	or b
;>@ab             if pressed & 0x03:         # A or B answers
;>                 if pressed & 0x01 and wTextChoice == 0:   # A on "yes"
	bit 0, a
	jr z, .notA

	ld a, [wTextChoice]
	or a
	jr nz, .answerNo

;>                     if wTextControlCode != 0xE6:
	ld a, [wTextControlCode]
	cp $e6
	jp z, .close

;>                         QueueSound(0x59)
	ld a, $59
	call QueueSound
	jr .close

.notA
;=@ab
	bit 1, a
	jp z, .done

.answerNo
;>                 else:
;>                     wTextChoice = 1
	ld a, $01
	ld [wTextChoice], a

.close
;>                 wTextState &= ~0x06    # no longer waiting
	ld hl, wTextState
	res 2, [hl]
	res 1, [hl]
;>                 row_addr = ScreenMapAddress(0)   # put back the screen under the window
	ld hl, $0000
	call ScreenMapAddress
;>@row                 for row in range(18):
	ld de, wTilemapBuffer
	ld c, $12

.row
;>@col                     for col in range(32):
	ld b, $20
	push hl

.col
;>                         WriteVRAM(addr, mem[src])     # addr starts at row_addr, src at wTilemapBuffer
	ld a, [de]
	call WriteVRAM
;>                         next_col = (addr + 1) & 0x1F
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;>                         addr = (addr & ~0x1F) | next_col   # wraps within the map row
	ld l, a
	pop af
	or l
	ld l, a
;>                         src += 1
	inc de
;=@col
	dec b
	jr nz, .col

;>                     row_addr += 0x20
	pop hl
	push bc
	ld bc, $0020
	add hl, bc
;>                     row_addr = 0x9800 | (row_addr & 0x3FF)   # wraps within the map
	ld a, h
	and $03
	or $98
	ld h, a
	pop bc
;=@row
	dec c
	jr nz, .row

;>                 DecompressVRAM(0x56, 0x0B, 0x8E50)   # reload the tiles the window used
	ld de, $560b
	ld hl, $8e50
	call DecompressVRAM
	jp .done


.anyButton
;>         else:
;>             if (wJoyPressed | wJoy2Pressed) & ~0x08:   # any button but Start
	ld a, [wJoyPressed]
	ld b, a
	ld a, [wJoy2Pressed]
	or b
	and $f7
	jp z, .done

;>                 wTextState &= ~0x06
	ld hl, wTextState
	res 2, [hl]
	res 1, [hl]
;>                 EraseTextPromptArrow()
	call EraseTextPromptArrow
	jp .done


.timedWait
;>     elif wTextState & 0x40:            # a wait that a button can cut short
	bit 6, a
	jr z, .pause

;>         wTextWaitTimer -= 1
	ld a, [wTextWaitTimer]
	dec a
	ld [wTextWaitTimer], a
;>@wt         if wTextWaitTimer == 0 or (wJoyPressed | wJoy2Pressed) & ~0x08:
	or a
	jp z, .endWait

	ld a, [wJoyPressed]
	ld b, a
;=@wt
	ld a, [wJoy2Pressed]
	or b
	and $f7
	jp z, .done

.endWait
;>             wTextState &= ~0x40
	ld hl, wTextState
	res 6, [hl]
;>             EraseTextPromptArrow()
	call EraseTextPromptArrow
	jp .done


.pause
;>     elif wTextState & 0x80:            # a pause
	bit 7, a
	jr z, .letter

;>         wTextPauseTimer -= 1
	ld a, [wTextPauseTimer]
	dec a
	ld [wTextPauseTimer], a
;>         if wTextPauseTimer == 0:
	or a
	jp nz, .done

;>             wTextState &= ~0x80
	ld hl, wTextState
	res 7, [hl]
	jp .done


.letter
;>     else:
;>         ptr = wTextPtr
	ld a, [wTextPtr]
	ld l, a
	ld a, [wTextPtr + 1]
	ld h, a
;>         c = mem[ptr]
	ld a, [hl]
;>         if c in (0x8D, 0x8E):          # a diacritic mark for the last letter
	cp $8d
	jp z, .diacritic

	cp $8e
	jp z, .diacritic

;>@dia1             wTextPtr += 1
;>@dia2             DrawDiacritic(c)
;>         elif c >= 0xE0:                # a control code
	cp $e0
	jp nc, .control

;>@ctl1             wTextPtr += 1
;>@ctl2             Call_56_44C7(c)                # runs the control code
;>@ctl3             wTextFlags &= ~0x02
;>         else:
;>             ready = True
;>             if not wTextState & 0x02:  # with letter delay
	ld a, [wTextState]
	bit 1, a
	jr nz, .print

;>                 if (wJoyPressed | wJoy2Pressed) & ~0x08:   # a button speeds the text up
	ld a, [wJoyPressed]
	ld b, a
	ld a, [wJoy2Pressed]
	or b
	and $f7
	jr z, .speed

;>                     wTextFlags |= 0x80
	ld hl, wTextFlags
	set 7, [hl]

.speed
;>                 speed = 2
	ld a, $02
	ld b, a
;>                 if wTextState & 0x08:
;>                     speed = wTextSpeed
	ld a, [wTextState]
	bit 3, a
	jr z, .delay

	ld a, [wTextSpeed]
	ld b, a

.delay
;>                 ready = wTextDelay >= speed
	ld a, [wTextDelay]
	cp b
	jp c, .done

.print
;>             if ready:
;>                 wTextDelay = 0
	xor a
	ld [wTextDelay], a
;>                 wTextFlags &= ~0x02
	ld hl, wTextFlags
	res 1, [hl]
;>                 ptr = NextTextByte()   # (its re-check for a control code can never fire)
	call NextTextByte
	ld a, [hl]
	cp $e0
	jp nc, .control

;>                 DrawGlyph(c)
	call DrawGlyph
;>                 if wTextFlags & 0x01:  # beep per letter
	ld a, [wTextFlags]
	bit 0, a
	jr z, .done

;>                     if speed not in (0x90, 0x9A):   # tests b, which still holds the delay, not the letter
	ld a, b
	cp $90
	jr z, .done

	cp $9a
	jr z, .done

;>                         QueueSound(wTextBeep)
	ld a, [wTextBeep]
	call QueueSound
;>                         wTextFlags |= 0x02
	ld hl, wTextFlags
	set 1, [hl]
	jr .done

.diacritic
;=@dia1
	ld a, [wTextPtr]
	add $01
	ld [wTextPtr], a
	ld a, [wTextPtr + 1]
	adc $00
	ld [wTextPtr + 1], a
;=@dia2
	ld a, [hl]
	call DrawDiacritic
	jr .done

.control
;=@ctl1
	ld a, [wTextPtr]
	add $01
	ld [wTextPtr], a
	ld a, [wTextPtr + 1]
	adc $00
	ld [wTextPtr + 1], a
;=@ctl2
	ld a, [hl]
	ld d, a
	ld hl, far_Call_56_44C7
	rst $10
;=@ctl3
	ld hl, wTextFlags
	res 1, [hl]

.done
;> wTextDelay += 1
	ld hl, wTextDelay
	inc [hl]
;> set_rom_bank(saved)
	pop af
	ld [$2100], a
;> mem[0x4100] = (saved >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
	ret


;@ def EraseTextPromptArrow()
;@ path: text/printer
;@ Removes the blinking prompt arrow (box row 3, column 9) if it is shown.
EraseTextPromptArrow::
;> if not wTextState & 0x20:
;>     return
	ld a, [wTextState]
	bit 5, a
	ret z

;> wTextState &= ~0x20
	res 5, a
	ld [wTextState], a
;> pos = MapAdvanceTiles(TextBoxMapAddress(0x60), 9)
	ld hl, $0060
	call TextBoxMapAddress
	ld b, $09
	call MapAdvanceTiles
;> WriteVRAM(pos, 0xEE)                   # box background tile
	ld a, $ee
	call WriteVRAM
	ret


;@ def DrawGlyph(char: a)
;@ path: text/font
;@ Draws letter `char` at the text cursor (CopyGlyphToCursor) with the font
;@ bank $4F switched in.
;@ test: skip switches banks
DrawGlyph::
;> saved = rom_bank()
	ld l, a
	ld a, [$4000]
	push af
;> set_rom_bank(0x4F)                     # the font
	ld a, $4f
	ld [$2100], a
;> mem[0x4100] = (0x4F >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
;> CopyGlyphToCursor(char)
	call CopyGlyphToCursor
;> set_rom_bank(saved)
	pop af
	ld [$2100], a
;> mem[0x4100] = (saved >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
	ret


;@ def CopyGlyphToCursor(char: l)
;@ path: text/font
;@ Copies the 16-byte tile of letter `char` from the font (bank $4F, $4010 +
;@ 16 * char) to the VRAM tile at wTextCursor, two bytes at a time whenever
;@ VRAM is accessible, and moves the cursor to the next tile.
;@ test: skip waits for the LCD
CopyGlyphToCursor::
;> src, dest = GetGlyphAddress(char)
	call GetGlyphAddress
;> for i in range(8):
	ld c, $08

.pair
;>     disable_interrupts()
	di

.wait
;>     while rSTAT & 0x02:                # wait until VRAM is accessible
;>         wait_hblank()
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .wait

;>     mem[dest] = mem[src]
	ld a, [de]
	ld [hli], a
	inc e
;>     mem[dest + 1] = mem[src + 1]
	ld a, [de]
	ld [hli], a
;>     enable_interrupts()
	ei
;>     src += 2; dest += 2
	inc de
	dec c
	jr nz, .pair

;> wTextCursor = dest
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [wTextCursor + 1], a
	ret


;@ def DrawDiacritic(char: a)
;@ path: text/font
;@ Adds diacritic mark `char` ($8D or $8E) to the letter just drawn
;@ (OverlayDiacritic), with the font bank $4F switched in.
;@ test: skip switches banks
DrawDiacritic::
;> saved = rom_bank()
	ld l, a
	ld a, [$4000]
	push af
;> set_rom_bank(0x4F)                     # the font
	ld a, $4f
	ld [$2100], a
;> mem[0x4100] = (0x4F >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
;> OverlayDiacritic(char)
	call OverlayDiacritic
;> set_rom_bank(saved)
	pop af
	ld [$2100], a
;> mem[0x4100] = (saved >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
	ret


;@ def OverlayDiacritic(char: l)
;@ path: text/font
;@ ORs the font tile of `char` into the tile drawn last (the one before
;@ wTextCursor), so the mark sits on that letter; in byte 3 (row 1, high
;@ bitplane) bit 1 is cleared.
;@ test: skip waits for the LCD
OverlayDiacritic::
;> src, cursor = GetGlyphAddress(char)
	call GetGlyphAddress
;> dest = cursor - 16                     # the last letter
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
;>@byte for i in range(16):
	ld b, $10

.byte
;>     disable_interrupts()
	di
;>     if i != 3:
	ld a, b
	cp $0d
	jr z, .row1

.wait
;>         while rSTAT & 0x02:            # wait until VRAM is accessible
;>             wait_hblank()
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .wait

;>         mem[dest + i] |= mem[src + i]
	ld a, [de]
	or [hl]
	ld [hli], a
	jr .next

.row1
;>     else:
;>         while rSTAT & 0x02:
;>             wait_hblank()
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .row1

;>         mem[dest + i] = (mem[dest + i] | mem[src + i]) & 0xFD
	ld a, [de]
	or [hl]
	and $fd
	ld [hli], a

.next
;>     enable_interrupts()
	ei
;=@byte
	inc de
	dec b
	jr nz, .byte

;> wTextCursor = dest + 16
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [wTextCursor + 1], a
	ret


;@ def GetGlyphAddress(char: l) -> (de, hl)
;@ path: text/font
;@ Returns the font address of letter `char` ($4010 + 16 * char in bank $4F)
;@ and the text cursor.
GetGlyphAddress::
;> offset = 16 * char
	ld de, $4010
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
;> glyph = 0x4010 + offset
	add hl, de
	ld e, l
	ld d, h
;> return glyph, wTextCursor
	ld a, [wTextCursor]
	ld l, a
	ld a, [wTextCursor + 1]
	ld h, a
	ret


;@ def LookUpTextPointer(table: de) -> de
;@ path: text/printer
;@ Finds text number wTextGroup/wTextIndex in a two-level pointer table of the
;@ current bank: `table` lists one pointer per group, each group lists one
;@ pointer per text. Remembers the current bank in wTextBank.
;@ test: skip reads the switched-in bank
LookUpTextPointer::
;> wTextBank = rom_bank()
	ld a, [$4000]
	push af
	ld a, [$4000]
	ld [wTextBank], a
;> entry = table + 2 * wTextGroup
	ld a, [wTextGroup]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
;> group = mem16[entry]
	ld e, [hl]
	inc hl
	ld d, [hl]
;> entry = group + 2 * wTextIndex
	ld a, [wTextIndex]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
;> text = mem16[entry]
	ld e, [hl]
	inc hl
	ld d, [hl]
;> set_rom_bank(wTextBank)                # (the same bank again)
	pop af
	ld [$2100], a
;> return text
	ret


;@ def NextTextByte() -> hl
;@ path: text/printer
;@ Returns the text read pointer and advances it by one.
NextTextByte::
;> ptr = wTextPtr
	ld a, [wTextPtr]
	ld l, a
	ld a, [wTextPtr + 1]
	ld h, a
;> wTextPtr = ptr + 1
	ld a, [wTextPtr]
	add $01
	ld [wTextPtr], a
	ld a, [wTextPtr + 1]
	adc $00
	ld [wTextPtr + 1], a
;> return ptr
	ret


;@ def PrintSystemText(id: hl)
;@ path: text/printer
;@ Starts printing text `id` (high byte group, low byte entry) of the texts in
;@ bank $41.
;@ test: skip calls a routine in another bank
PrintSystemText::
;> wTextGroup = hi(id)
	ld a, h
	ld [wTextGroup], a
;> wTextIndex = lo(id)
	ld a, l
	ld [wTextIndex], a
;> StartText_41()                         # StartText with bank $41's table
	ld hl, far_StartText_41
	rst $10
	ret


;@ def CopySystemText(id: hl, dest: de)
;@ path: text/printer
;@ Copies text `id` of the texts in bank $41 into the buffer `dest`.
;@ test: skip calls a routine in another bank
CopySystemText::
;> wTextCopyDest = dest
	ld a, e
	ld [wTextCopyDest], a
	ld a, d
	ld [wTextCopyDest + 1], a
;> wTextGroup = hi(id)
	ld a, h
	ld [wTextGroup], a
;> wTextIndex = lo(id)
	ld a, l
	ld [wTextIndex], a
;> CopyText_41()                         # CopyTextString with bank $41's table
	ld hl, far_CopyText_41
	rst $10
	ret


;@ def SetUpTextBox(tiles: hl, lines: e, line_length: d)
;@ path: text/printer
;@ Sets the VRAM tiles the text box draws its letters into (`lines` lines of
;@ `line_length` tiles; wTextBoxWidth holds the line count, wTextBoxHeight the line length) and clears them.
;@ test: skip calls a routine in another bank
SetUpTextBox::
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxWidth = lines
	ld a, e
	ld [wTextBoxWidth], a
;> wTextBoxHeight = line_length
	ld a, d
	ld [wTextBoxHeight], a
;> Call_56_4485()                         # clear the tiles
	ld hl, far_Call_56_4485
	rst $10
	ret


;@ def ByteToDecimal(value: a, dest: hl) -> hl
;@ path: text/numbers
;@ Writes `value` (0-255) as decimal digits (character codes 0-9, no leading
;@ zeros) to `dest`, followed by the $F0 end mark. Returns the address of the
;@ end mark.
ByteToDecimal::
;> digits = 3 if value >= 100 else 2 if value >= 10 else 1
	cp $64
	jr nc, .hundreds

	cp $0a
	jr nc, .tens

	jr .ones

.hundreds
;> if digits >= 3:
;>     value, dest = DecimalDigit(value, 100, dest)
	ld e, $64
	call DecimalDigit

.tens
;> if digits >= 2:
;>     value, dest = DecimalDigit(value, 10, dest)
	ld e, $0a
	call DecimalDigit

.ones
;> mem[dest] = value
	ld [hli], a
;> mem[dest + 1] = 0xF0                   # end mark
	ld a, $f0
	ld [hl], a
;> return dest + 1
	ret


;@ def DecimalDigit(value: a, divisor: e, dest: hl) -> (a, hl)
;@ path: text/numbers
;@ Writes the digit value // divisor to `dest` and returns the remainder and
;@ the next address.
DecimalDigit::
;> q = -1
	ld d, $ff

.sub
;> while True:
;>     q += 1
	inc d
;>     value -= divisor
	sub e
;>     if value < 0:
;>         break
	jr nc, .sub

;> value += divisor
	add e
;> mem[dest] = q
	ld [hl], d
;> return value, dest + 1
	inc hl
	ret


;@ def Number24ToDecimal(dest: hl) -> hl
;@ path: text/numbers
;@ Writes the 24-bit number in hNumber (below 10,000,000) as decimal digits
;@ (character codes 0-9, no leading zeros) to `dest`, followed by the $F0 end
;@ mark. Divisors are 24-bit: hDivisorHigh holds their top byte. hNumber is
;@ used up (left as the remainder).
;@ test: skip works on a 24-bit number spread over three HRAM bytes
Number24ToDecimal::
;> hDivisorHigh = 0x0F                    # 1,000,000 = $0F4240
	ld a, $0f
	ldh [hDivisorHigh], a
;> if PeekDecimalDigit24(0x4240):         # a millions digit: 7 digits
;>     start = 7
	ld e, $40
	ld d, $42
	call PeekDecimalDigit24
	or a
	jp nz, .from7

;> else:
;>     hDivisorHigh = 0x01                # 100,000 = $0186A0
	ld a, $01
	ldh [hDivisorHigh], a
;>     if PeekDecimalDigit24(0x86A0):
;>         start = 6
	ld e, $a0
	ld d, $86
	call PeekDecimalDigit24
	or a
	jr nz, .from6

;>     else:
;>         hDivisorHigh = 0x00            # 10,000 = $002710
	ld a, $00
	ldh [hDivisorHigh], a
;>         if PeekDecimalDigit24(0x2710):
;>             start = 5
	ld e, $10
	ld d, $27
	call PeekDecimalDigit24
	or a
	jr nz, .from5

;>         else:                          # below 10,000
;>             return Number16ToDecimal(hNumber[0] | hNumber[1] << 8, dest)
	ldh a, [hNumber]
	ld c, a
	ldh a, [hNumber + 1]
	ld b, a
	jp Number16ToDecimal


.from7
;> if start >= 7:
;>     hDivisorHigh = 0x0F
	ld a, $0f
	ldh [hDivisorHigh], a
;>     dest = PutDigit(DecimalDigit24(0x4240), dest)
	ld e, $40
	ld d, $42
	call DecimalDigit24
	call PutDigit

.from6
;> if start >= 6:
;>     hDivisorHigh = 0x01
	ld a, $01
	ldh [hDivisorHigh], a
;>     dest = PutDigit(DecimalDigit24(0x86A0), dest)
	ld e, $a0
	ld d, $86
	call DecimalDigit24
	call PutDigit

.from5
;> hDivisorHigh = 0x00
	ld a, $00
	ldh [hDivisorHigh], a
;> dest = PutDigit(DecimalDigit24(0x2710), dest)
	ld e, $10
	ld d, $27
	call DecimalDigit24
	call PutDigit
;> return Number16ToDecimal4Digits(hNumber[0] | hNumber[1] << 8, dest)   # the rest, with zeros
	ldh a, [hNumber]
	ld c, a
	ldh a, [hNumber + 1]
	ld b, a
	jp Number16ToDecimal4Digits


;@ def PeekDecimalDigit24(divisor_low: de) -> a
;@ path: text/numbers
;@ Returns the digit DecimalDigit24 would produce, without changing hNumber.
;@ test: skip works on a 24-bit number spread over three HRAM bytes
PeekDecimalDigit24::
;> copy(wNumberBackup, hNumber, 3)
	ldh a, [hNumber]
	ld [wNumberBackup], a
	ldh a, [hNumber + 1]
	ld [wNumberBackup + 1], a
	ldh a, [hNumber + 2]
	ld [wNumberBackup + 2], a
;> digit = DecimalDigit24(divisor_low)
	call DecimalDigit24
;> copy(hNumber, wNumberBackup, 3)
	push af
	ld a, [wNumberBackup]
	ldh [hNumber], a
	ld a, [wNumberBackup + 1]
	ldh [hNumber + 1], a
;> # (third byte)
	ld a, [wNumberBackup + 2]
	ldh [hNumber + 2], a
;> return digit
	pop af
	ret


;@ def DecimalDigit24(divisor_low: de) -> a
;@ path: text/numbers
;@ Divides the 24-bit number in hNumber by the 24-bit divisor hDivisorHigh:d:e:
;@ returns the quotient (a digit) and leaves the remainder in hNumber.
;@ test: skip works on a 24-bit number spread over three HRAM bytes
DecimalDigit24::
;> divisor = hDivisorHigh << 16 | divisor_low
	push hl
	ldh a, [hDivisorHigh]
	ld l, a
;> q = -1
	ld h, $ff

.sub
;> while True:
;>     q += 1
	inc h
;>     number -= divisor                  # number = the 24 bits of hNumber; low two bytes ...
	ldh a, [hNumber]
	sub e
	ldh [hNumber], a
	ldh a, [hNumber + 1]
	sbc d
	ldh [hNumber + 1], a
;>     # ... and the top byte, with the borrow
	ldh a, [hNumber + 2]
	sbc l
	ldh [hNumber + 2], a
;>     if number < 0:
;>         break
	jr nc, .sub

;> number += divisor                      # undo the last subtraction: low two bytes ...
	ldh a, [hNumber]
	add e
	ldh [hNumber], a
	ldh a, [hNumber + 1]
	adc d
	ldh [hNumber + 1], a
;> # ... and the top byte
	ldh a, [hNumber + 2]
	adc l
	ldh [hNumber + 2], a
;> return q
	ld a, h
	pop hl
	ret


;@ def Number16ToDecimal(value: bc, dest: hl) -> hl
;@ path: text/numbers
;@ Writes `value` (below 10,000) as decimal digits (character codes 0-9, no
;@ leading zeros) to `dest`, followed by the $F0 end mark. Entered at
;@ Number16ToDecimal4Digits it always writes four digits (Number24ToDecimal
;@ uses that for the lower digits).
;@ test: skip has a second entry point
Number16ToDecimal::
;> if DecimalDigit16(value, 1000)[0]:     # a thousands digit
;>     start = 4
	ld de, $03e8
	push bc
	call DecimalDigit16
	pop bc
	or a
	jr nz, Number16ToDecimal4Digits

;> elif DecimalDigit16(value, 100)[0]:
;>     start = 3
	ld de, $0064
	push bc
	call DecimalDigit16
	pop bc
	or a
	jr nz, Number16ToDecimal4Digits.hundreds

;> elif DecimalDigit16(value, 10)[0]:
;>     start = 2
	ld de, $000a
	push bc
	call DecimalDigit16
	pop bc
	or a
	jr nz, Number16ToDecimal4Digits.tens

;> else:
;>     start = 1
	jr Number16ToDecimal4Digits.ones

Number16ToDecimal4Digits:
;> if start >= 4:
;>     digit, value = DecimalDigit16(value, 1000)
	ld de, $03e8
	call DecimalDigit16
;>     dest = PutDigit(digit, dest)
	call PutDigit

.hundreds
;> if start >= 3:
;>     digit, value = DecimalDigit16(value, 100)
	ld de, $0064
	call DecimalDigit16
;>     dest = PutDigit(digit, dest)
	call PutDigit

.tens
;> if start >= 2:
;>     digit, value = DecimalDigit16(value, 10)
	ld de, $000a
	call DecimalDigit16
;>     dest = PutDigit(digit, dest)
	call PutDigit

.ones
;> return PutDigit(value, dest)
	ld a, c
	call PutDigit
	ret


;@ def DecimalDigit16(value: bc, divisor: de) -> (a, bc)
;@ path: text/numbers
;@ Returns value // divisor and value % divisor.
DecimalDigit16::
;> q = -1
	push hl
	ld h, $ff

.sub
;> while True:
;>     q += 1
	inc h
;>     value -= divisor
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
;>     if value < 0:
;>         break
	jr nc, .sub

;> value += divisor                       # undo the last subtraction
	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
;> return q, value
	ld a, h
	pop hl
	ret


;@ def PutDigit(digit: a, dest: hl) -> hl
;@ path: text/numbers
;@ Writes `digit` and an $F0 end mark after it; returns the end mark's address
;@ (where the next digit goes).
PutDigit::
;> mem[dest] = digit
	ld [hli], a
;> mem[dest + 1] = 0xF0
	ld a, $f0
	ld [hl], a
;> return dest + 1
	ret


;@ def PrintMessage(n: hl)
;@ path: text/messages
;@ Starts printing dialogue message number `n` ($000-$9FF). The messages are
;@ spread over the text banks $42-$4E; the handler for the high byte works out
;@ the bank and the (group, entry) within that bank's pointer table.
;@ test: skip calls routines in other banks
PrintMessage::
;> MessageGroupTable[hi(n)](n)
	ld e, l
	ld d, h
	ld a, h
	rst $00

;@ path: text/messages
;@ Handlers of PrintMessage, one per 256 message numbers.
MessageGroupTable::
	dw PrintMessageGroup0
	dw PrintMessageGroup1
	dw PrintMessageGroup2
	dw PrintMessageGroup3
	dw PrintMessageGroup4
	dw PrintMessageGroup5
	dw PrintMessageGroup6
	dw PrintMessageGroup7
	dw PrintMessageGroup8
	dw PrintMessageGroup9

;@ def PrintMessageGroup0(n: de)
;@ path: text/messages
;@ Messages $000-$0E1: bank $42 group 0; $0E2-$0FF: bank $43 group 0.
;@ test: skip calls routines in other banks
PrintMessageGroup0::
;> if lo(n) < 0xE2:
	ld a, e
	cp $e2
	jr nc, .bank43

;>     wTextGroup = 0
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = lo(n)
	ld a, e
	ld [wTextIndex], a
;>     StartText_42()                     # print from bank $42
	ld hl, far_StartText_42
	rst $10
	ret


.bank43
;> else:
;>     index = lo(n) - 0xE2
	sub $e2
	ld e, a
;>     wTextGroup = 0
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_43()                     # print from bank $43
	ld hl, far_StartText_43
	rst $10
	ret


;@ def PrintMessageGroup1(n: de)
;@ path: text/messages
;@ Messages $100-$197: bank $43 group 1; $198-$1FF: bank $44 group 0.
;@ test: skip calls routines in other banks
PrintMessageGroup1::
;> index = n - 0x100
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $01
	ld d, a
;> if index < 0x98:
	ld a, e
	cp $98
	jr nc, .bank44

;>     wTextGroup = 1
	inc d
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_43()                     # print from bank $43
	ld hl, far_StartText_43
	rst $10
	ret


.bank44
;> else:
;>     index -= 0x98
	sub $98
	ld e, a
;>     wTextGroup = 0
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_44()                     # print from bank $44
	ld hl, far_StartText_44
	rst $10
	ret


;@ def PrintMessageGroup2(n: de)
;@ path: text/messages
;@ Messages $200-$243: bank $44 group 1; $244-$2FF: bank $45 group 0.
;@ test: skip calls routines in other banks
PrintMessageGroup2::
;> index = n - 0x200
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $02
	ld d, a
;> if index < 0x44:
	ld a, e
	cp $44
	jr nc, .bank45

;>     wTextGroup = 1
	inc d
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_44()                     # print from bank $44
	ld hl, far_StartText_44
	rst $10
	ret


.bank45
;> else:
;>     index -= 0x44
	sub $44
	ld e, a
;>     wTextGroup = 0
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_45()                     # print from bank $45
	ld hl, far_StartText_45
	rst $10
	ret


;@ def PrintMessageGroup3(n: de)
;@ path: text/messages
;@ Messages $300-$3C7: bank $46 group 0; $3C8-$3FF: bank $47 group 0.
;@ test: skip calls routines in other banks
PrintMessageGroup3::
;> index = n - 0x300
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $03
	ld d, a
;> if index < 0xC8:
	ld a, e
	cp $c8
	jr nc, .bank47

;>     wTextGroup = 0
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_46()                     # print from bank $46
	ld hl, far_StartText_46
	rst $10
	ret


.bank47
;> else:
;>     index -= 0xC8
	sub $c8
	ld e, a
;>     wTextGroup = 0
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_47()                     # print from bank $47
	ld hl, far_StartText_47
	rst $10
	ret


;@ def PrintMessageGroup4(n: de)
;@ path: text/messages
;@ Messages $400-$473: bank $47 group 1; $474-$4FF: bank $48 group 0.
;@ test: skip calls routines in other banks
PrintMessageGroup4::
;> index = n - 0x400
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $04
	ld d, a
;> if index < 0x74:
	ld a, e
	cp $74
	jr nc, .bank48

;>     wTextGroup = 1
	inc d
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_47()                     # print from bank $47
	ld hl, far_StartText_47
	rst $10
	ret


.bank48
;> else:
;>     index -= 0x74
	sub $74
	ld e, a
;>     wTextGroup = 0
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_48()                     # print from bank $48
	ld hl, far_StartText_48
	rst $10
	ret


;@ def PrintMessageGroup5(n: de)
;@ path: text/messages
;@ Messages $500-$511: bank $48 group 1; $512-$5DF: bank $49 group 0;
;@ $5E0-$5FF: bank $4A group 0.
;@ test: skip calls routines in other banks
PrintMessageGroup5::
;> index = n - 0x500
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $05
	ld d, a
;> if index < 0x12:
	ld a, e
	cp $12
	jr nc, .bank49

;>     wTextGroup = 1
	inc d
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_48()                     # print from bank $48
	ld hl, far_StartText_48
	rst $10
	ret


.bank49
;> elif index < 0xE0:
	cp $e0
	jr nc, .bank4A

;>     index -= 0x12
	sub $12
	ld e, a
;>     wTextGroup = 0
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_49()                     # print from bank $49
	ld hl, far_StartText_49
	rst $10
	ret


.bank4A
;> else:
;>     index -= 0xE0
	sub $e0
	ld e, a
;>     wTextGroup = 0
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_4A()                     # print from bank $4A
	ld hl, far_StartText_4A
	rst $10
	ret


;@ def PrintMessageGroup6(n: de)
;@ path: text/messages
;@ Messages $600-$6FF: bank $4A group 1.
;@ test: skip calls routines in other banks
PrintMessageGroup6::
;> index = n - 0x600
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $06
	ld d, a
;> wTextGroup = 1
	inc d
	ld a, d
	ld [wTextGroup], a
;> wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;> StartText_4A()                         # print from bank $4A
	ld hl, far_StartText_4A
	rst $10
	ret


;@ def PrintMessageGroup7(n: de)
;@ path: text/messages
;@ Messages $700-$7BF: bank $4A group 2; $7C0-$7FF: bank $4B group 0.
;@ test: skip calls routines in other banks
PrintMessageGroup7::
;> index = n - 0x700
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $07
	ld d, a
;> if index < 0xC0:
	ld a, e
	cp $c0
	jr nc, .bank4B

;>     wTextGroup = 2
	inc d
	inc d
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_4A()                     # print from bank $4A
	ld hl, far_StartText_4A
	rst $10
	ret


.bank4B
;> else:
;>     index -= 0xC0
	sub $c0
	ld e, a
;>     wTextGroup = 0
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_4B()                     # print from bank $4B
	ld hl, far_StartText_4B
	rst $10
	ret


;@ def PrintMessageGroup8(n: de)
;@ path: text/messages
;@ Messages $800-$867: bank $4B group 1; $868-$8FF: bank $4E group 0.
;@ test: skip calls routines in other banks
PrintMessageGroup8::
;> index = n - 0x800
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $08
	ld d, a
;> if index < 0x68:
	ld a, e
	cp $68
	jr nc, .bank4E

;>     wTextGroup = 1
	inc d
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_4B()                     # print from bank $4B
	ld hl, far_StartText_4B
	rst $10
	ret


.bank4E
;> else:
;>     index -= 0x68
	sub $68
	ld e, a
;>     wTextGroup = 0
	ld a, d
	ld [wTextGroup], a
;>     wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;>     StartText_4E()                     # print from bank $4E
	ld hl, far_StartText_4E
	rst $10
	ret


;@ def PrintMessageGroup9(n: de)
;@ path: text/messages
;@ Messages $900-$9FF: bank $4E group 1.
;@ test: skip calls routines in other banks
PrintMessageGroup9::
;> index = n - 0x900
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $09
	ld d, a
;> wTextGroup = 1
	inc d
	ld a, d
	ld [wTextGroup], a
;> wTextIndex = index
	ld a, e
	ld [wTextIndex], a
;> StartText_4E()                         # print from bank $4E
	ld hl, far_StartText_4E
	rst $10
	ret


;@ def CopyName(src: de, dest: hl)
;@ path: text/names
;@ Copies a 4-letter name from `src` to `dest` and ends it with $F0. Diacritic
;@ marks ($8D, $8E) are copied too but do not count as letters, so a mark after
;@ the fourth letter is kept.
CopyName::
;> count = 4
	ld b, $04

.copy
;> while True:
;>     c = mem[src]; mem[dest] = c; src += 1; dest += 1
	ld a, [de]
	ld [hli], a
	inc de
;>     if c in (0x8D, 0x8E):              # a mark is not a letter
;>         continue
	cp $8d
	jr z, .copy

	cp $8e
	jr z, .copy

;>     count -= 1
	dec b
;>     if count == 0:
;>         break
	jr nz, .copy

;> if mem[src] not in (0x8D, 0x8E):
	ld a, [de]
	cp $8d
	jr z, .mark

	cp $8e
	jr z, .mark

;>     mem[dest] = 0xF0
	ld [hl], $f0
	ret


.mark
;> else:
;>     mem[dest] = mem[src]               # the mark of the last letter
	ld [hli], a
;>     mem[dest + 1] = 0xF0
	ld [hl], $f0
	ret


;@ def DrawTextBoxTiles(box: hl)
;@ path: text/box
;@ Fills the text box's area of the BG map at `box` with the box's letter tiles
;@ (numbered from wTextTiles / 16 on): wTextBoxWidth lines of wTextBoxHeight
;@ tiles (those two names are the wrong way round: $C829 is the line count,
;@ $C82A the line length). Every line after the first is placed at the same
;@ address, two map rows below the box's top.
DrawTextBoxTiles::
;> wTextBoxMap = box
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
	ld [wTextBoxMap + 1], a
;> tiles = wTextTiles
	ld a, [wTextTiles]
	ld e, a
	ld a, [wTextTiles + 1]
	ld d, a
;> tile = tiles >> 2
	srl d
	rr e
	srl d
	rr e
;> tile >>= 2                             # the tile number of the first letter tile
	srl d
	rr e
	srl d
	rr e
;> lines = wTextBoxWidth
	ld a, [wTextBoxWidth]
	ld c, a
;> per_line = wTextBoxHeight
	ld a, [wTextBoxHeight]
	ld b, a
;> addr = wTextBoxMap
	ld a, [wTextBoxMap]
	ld l, a
	ld a, [wTextBoxMap + 1]
	ld h, a

.line
;>@line for _ in range(lines):
	push bc

.tile
;>@tile     for _ in range(per_line):
;>         WriteVRAM(addr, lo(tile))
	ld a, e
	call WriteVRAM
;>         addr = MapNextTile(addr)
	call MapNextTile
;>         tile += 1
	inc e
;=@tile
	dec b
	jr nz, .tile

;>     addr = TextBoxMapAddress(0x40)     # two map rows below the box's top
	pop bc
	ld hl, $0040
	call TextBoxMapAddress
;=@line
	dec c
	jr nz, .line

	ret


;@ def MapAdvanceTiles(addr: hl, count: b) -> hl
;@ path: gfx/tilemap
;@ Moves a BG map address `count` tiles to the right, wrapping within the row.
MapAdvanceTiles::
;> for _ in range(count):
;>     addr = MapNextTile(addr)
	call MapNextTile
	dec b
	jr nz, MapAdvanceTiles

;> return addr
	ret


;@ def MapNextTile(addr: hl) -> hl
;@ path: gfx/tilemap
;@ The BG map address one tile to the right of `addr`, wrapping from column 31
;@ back to column 0 of the same row. Keeps a.
MapNextTile::
;> col = (lo(addr) + 1) & 0x1F
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;> addr = (addr & 0xFFE0) | col
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
;> return addr
	pop af
	ret


;@ def TextBoxMapAddress(offset: hl) -> hl
;@ path: text/box
;@ The BG map address `offset` bytes after the text box's corner wTextBoxMap,
;@ wrapping within the 1 KiB map.
TextBoxMapAddress::
;> total = wTextBoxMap + offset
	ld a, [wTextBoxMap]
	add l
	ld l, a
	ld a, [wTextBoxMap + 1]
	adc h
;> high = hi(total) & 0x03
	and $03
	ld h, a
;> return (hi(wTextBoxMap) & 0xFC | high) << 8 | lo(total)
	ld a, [wTextBoxMap + 1]
	and $fc
	or h
	ld h, a
	ret


;@ def ScreenMapAddress(offset: hl) -> hl
;@ path: gfx/tilemap
;@ The address in the BG map at $9800 of the tile `offset` bytes (32 per row)
;@ after the tile at the top left corner of the screen (from hScrollX/Y),
;@ wrapping within the map.
ScreenMapAddress::
;> # (the offset waits on the stack)
	push hl
;> corner_row = (lo(hScrollY) & 0xF8) * 4
	ldh a, [hScrollY]
	and $f8
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
;> corner = corner_row + (lo(hScrollX) & 0xF8) // 8
	ldh a, [hScrollX]
	and $f8
	rrca
	rrca
	rrca
	add l
;> total = corner + offset
	ld c, a
	ld b, h
	pop hl
	ld a, c
	add l
	ld l, a
;> high = hi(total) & 0x03
	ld a, b
	adc h
	and $03
	ld h, a
;> return 0x9800 | high << 8 | lo(total)
	and $03
	or $98
	ld h, a
	ret


;@ def ClearMapTiles(addr: hl, count: b) -> hl
;@ path: gfx/tilemap
;@ Writes `count` blank tiles ($E0) into the BG map from `addr` to the right,
;@ wrapping within the row.
;@ test: skip waits for the LCD
ClearMapTiles::
;> for _ in range(count):
;>     WriteVRAM(addr, 0xE0)
	ld a, $e0
	call WriteVRAM
;>     addr = MapNextTile(addr)
	call MapNextTile
	dec b
	jr nz, ClearMapTiles

;> return addr
	ret


;@ def CopyGlyph(char: a, dest: hl)
;@ path: text/font
;@ Copies the 16-byte font tile of letter `char` (bank $4F, $4010 + 16 * char)
;@ to `dest` (without waiting for VRAM access).
;@ test: skip switches banks
CopyGlyph::
;> offset = 16 * char
	push hl
	ld l, a
	ld de, $4010
	ld h, $00
	add hl, hl
	add hl, hl
;> src = 0x4010 + offset
	add hl, hl
	add hl, hl
	add hl, de
	ld e, l
	ld d, h
	pop hl
;> saved = rom_bank()
	ld a, [$4000]
	push af
;> set_rom_bank(0x4F)                     # the font
	ld a, $4f
	ld [$2100], a
;> mem[0x4100] = (0x4F >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
;>@copy copy(dest, src, 16)
	ld b, $08

.copy
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
;=@copy
	inc de
	dec b
	jr nz, .copy

;> set_rom_bank(saved)
	pop af
	ld [$2100], a
;> mem[0x4100] = (saved >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
	ret


;@ def ReadTextBankByte(addr: hl) -> a
;@ path: text/printer
;@ Reads the byte at `addr` in the text's bank (wTextBank).
;@ test: skip switches banks
ReadTextBankByte::
;> saved = rom_bank()
	ld a, [$4000]
	push af
;> set_rom_bank(wTextBank)
	ld a, [wTextBank]
	ld [$2100], a
;> value = mem[addr]
	ld a, [hl]
	ld b, a
;> set_rom_bank(saved)
	pop af
	ld [$2100], a
;> return value
	ld a, b
	ret


;@ path: unused/leftovers
;@ The text "MESBUF" (message buffer) in the game's character codes, ended by
;@ $F0; nothing uses it.
UnusedMesbufText::
	db $30, $28, $36, $25, $38, $29, $f0

;@ def DrawMetasprite(table: de)
;@ path: gfx/sprites
;@ Adds a metasprite to the shadow OAM (from slot hOAMCount on). `table` lists
;@ one pointer per sprite set, each set one pointer per frame; hSpriteSet and
;@ hSpriteFrame choose the frame. A frame is a list of 4-byte entries ended by
;@ $80: Y offset (signed), X offset (signed), tile (hSpriteTileBase is added),
;@ attributes (hSpriteAttr is XORed in; with its bit 5, X flip, the X offsets are
;@ mirrored too). The offsets are relative to hSpriteX/hSpriteY minus the
;@ scroll position; entries off the screen are left out. With hSpriteClip set,
;@ entries are also left out above OAM line $34 (1) or from line $71 on (2), and
;@ wherever the background tile under the entry is hSpriteBGTile or higher.
;@ Stops at 40 sprites (and does nothing from 39 on).
;@ test: skip writes OAM entries through pointer tables; SpriteInFrontOfBG polls the LCD
DrawMetasprite::
;> if hOAMCount >= 39:
;>     return
	ldh a, [hOAMCount]
	cp $27
	ret nc

;> offset_y = 0x10 - hScrollY             # computed as ~(hScrollY - $11): low byte ...
	ld hl, hScrollY
	ld a, [hli]
	sub $11
	cpl
	ld c, a
;> # ... and high byte
	ld a, [hl]
	sbc $00
	cpl
	ld b, a
;> hSpriteScreenY = u16(hSpriteY + offset_y)
	ldh a, [hSpriteY]
	add c
	ldh [hSpriteScreenY], a
	ldh a, [hSpriteY + 1]
	adc b
	ldh [hSpriteScreenY + 1], a
;> offset_x = 8 - hScrollX                # computed as ~(hScrollX - 9): low byte ...
	ld hl, hScrollX
	ld a, [hli]
	sub $09
	cpl
	ld c, a
;> # ... and high byte
	ld a, [hl]
	sbc $00
	cpl
	ld b, a
;> hSpriteScreenX = u16(hSpriteX + offset_x)   # low byte ...
	ld hl, hSpriteScreenX
	ldh a, [hSpriteX]
	add c
	ld c, a
	ld [hli], a
;> # ... and high byte
	ldh a, [hSpriteX + 1]
	adc b
	ld b, a
	ld [hli], a
;> hSpriteScreenXFlip = u16(hSpriteScreenX - 8)
	ld a, c
	sub $08
	ld [hli], a
	ld a, b
	sbc $00
	ld [hl], a
;> entry = table + 2 * hSpriteSet
	ldh a, [hSpriteSet]
	add a
	add e
	ld l, a
	ld a, $00
	adc d
;> frames = mem16[entry]
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
;> entry = frames + 2 * hSpriteFrame
	ldh a, [hSpriteFrame]
	add a
	add e
	ld l, a
	ld a, $00
	adc d
;> data = mem16[entry]
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> oam = wShadowOAM + 4 * hOAMCount
	ldh a, [hOAMCount]
	add a
	add a
	ld e, a
	ld d, $c0
;> if hSpriteClip == 0:
	ldh a, [hSpriteClip]
	or a
	jp nz, .clipped

;>     tile_base = hSpriteTileBase
	ldh a, [hSpriteTileBase]
	ld c, a
;>     if not hSpriteAttr & 0x20:         # not mirrored
	ldh a, [hSpriteAttr]
	and $20
	jr nz, .mirrored

.aLoop
;>         while True:
;>             dy = mem[data]; data += 1
	ld a, [hli]
;>             if dy == 0x80:             # end of the list
;>                 return
	cp $80
	ret z

;>             if dy < 0x80:
	ld b, a
	jr nc, .aYNeg

;>                 y = hSpriteScreenY + dy
	ldh a, [hSpriteScreenY]
	add b
	ld b, a
	ldh a, [hSpriteScreenY + 1]
	adc $00
;>                 visible = hi(y) == 0 and lo(y) < 0xA8
	jr nz, .aSkip

	ld a, b
	cp $a8
	jr c, .aY

	jr .aSkip

.aYNeg
;>             else:
;>                 y = hSpriteScreenY + dy - 0x100
	ldh a, [hSpriteScreenY]
	add b
	ld b, a
	ldh a, [hSpriteScreenY + 1]
	adc $ff
;>                 visible = hi(y) == 0 and lo(y) < 0xA8
	jr nz, .aSkip

	ld a, b
	cp $a8
	jr c, .aY

.aSkip
;>             if not visible:            # leave the entry out
;>                 data += 3
	inc hl
	inc hl
	inc hl
;>                 continue
	jr .aLoop

.aY
;>             mem[oam] = lo(y); oam += 1
	ld a, b
	ld [de], a
	inc e
;>             dx = mem[data]; data += 1
	ld a, [hli]
	ld b, a
;>             if dx < 0x80:
	rlca
	jr c, .aXNeg

;>                 x = hSpriteScreenX + dx
	ldh a, [hSpriteScreenX]
	add b
	ld b, a
	ldh a, [hSpriteScreenX + 1]
	adc $00
;>                 visible = hi(x) == 0 and lo(x) < 0xB8
	jr nz, .aUndo

	ld a, b
	cp $b8
	jr c, .aPut

	jr .aUndo

.aXNeg
;>             else:
;>                 x = hSpriteScreenX + dx - 0x100
	ldh a, [hSpriteScreenX]
	add b
	ld b, a
	ldh a, [hSpriteScreenX + 1]
	adc $ff
;>                 visible = hi(x) == 0 and lo(x) < 0xB8
	jr nz, .aUndo

	ld a, b
	cp $b8
	jr c, .aPut

.aUndo
;>             if not visible:            # take the entry back
;>                 data += 2
	inc hl
	inc hl
;>                 oam -= 1; mem[oam] = 0
	dec e
	xor a
	ld [de], a
;>                 continue
	jr .aLoop

.aPut
;>             mem[oam] = lo(x); oam += 1
	ld a, b
	ld [de], a
	inc e
;>             mem[oam] = u8(mem[data] + tile_base); oam += 1; data += 1
	ld a, [hli]
	add c
	ld [de], a
	inc e
;>             mem[oam] = mem[data] ^ hSpriteAttr; oam += 1; data += 1
	ldh a, [hSpriteAttr]
	xor [hl]
	inc hl
	ld [de], a
	inc e
;>             hOAMCount += 1
	ldh a, [hOAMCount]
	inc a
	ldh [hOAMCount], a
;>             if hOAMCount == 40:
;>                 return
	cp $28
	jr nz, .aLoop

	ret


.mirrored
;>     else:
;>         while True:
;>             dy = mem[data]; data += 1
	ld a, [hli]
;>             if dy == 0x80:
;>                 return
	cp $80
	ret z

;>             if dy < 0x80:
	ld b, a
	jr nc, .bYNeg

;>                 y = hSpriteScreenY + dy
	ldh a, [hSpriteScreenY]
	add b
	ld b, a
	ldh a, [hSpriteScreenY + 1]
	adc $00
;>                 visible = hi(y) == 0 and lo(y) < 0xA8
	jr nz, .bSkip

	ld a, b
	cp $a8
	jr c, .bY

	jr .bSkip

.bYNeg
;>             else:
;>                 y = hSpriteScreenY + dy - 0x100
	ldh a, [hSpriteScreenY]
	add b
	ld b, a
	ldh a, [hSpriteScreenY + 1]
	adc $ff
;>                 visible = hi(y) == 0 and lo(y) < 0xA8
	jr nz, .bSkip

	ld a, b
	cp $a8
	jr c, .bY

.bSkip
;>             if not visible:
;>                 data += 3
	inc hl
	inc hl
	inc hl
;>                 continue
	jr .mirrored

.bY
;>             mem[oam] = lo(y); oam += 1
	ld a, b
	ld [de], a
	inc e
;>             dx = mem[data]; data += 1
	ld a, [hli]
	ld b, a
;>             if dx < 0x80:
	rlca
	jr c, .bXNeg

;>                 x = hSpriteScreenXFlip - dx    # mirrored
	ldh a, [hSpriteScreenXFlip]
	sub b
	ld b, a
	ldh a, [hSpriteScreenXFlip + 1]
	sbc $00
;>                 visible = hi(x) == 0           # (no right-edge test on this side)
	jr z, .bPut

	jr nz, .bUndo

;>                 # (an unreachable right-edge test)
	ld a, b
	cp $b8
	jr c, .bPut

	jr .bUndo

.bXNeg
;>             else:
;>                 x = hSpriteScreenXFlip - (dx - 0x100)
	ldh a, [hSpriteScreenXFlip]
	sub b
	ld b, a
	ldh a, [hSpriteScreenXFlip + 1]
	sbc $ff
;>                 visible = hi(x) == 0 and lo(x) < 0xB8
	jr nz, .bUndo

	ld a, b
	cp $b8
	jr c, .bPut

.bUndo
;>             if not visible:
;>                 data += 2
	inc hl
	inc hl
;>                 oam -= 1; mem[oam] = 0
	dec e
	xor a
	ld [de], a
;>                 continue
	jr .mirrored

.bPut
;>             mem[oam] = lo(x); oam += 1
	ld a, b
	ld [de], a
	inc e
;>             mem[oam] = u8(mem[data] + tile_base); oam += 1; data += 1
	ld a, [hli]
	add c
	ld [de], a
	inc e
;>             mem[oam] = mem[data] ^ hSpriteAttr; oam += 1; data += 1
	ldh a, [hSpriteAttr]
	xor [hl]
	inc hl
	ld [de], a
	inc e
;>             hOAMCount += 1
	ldh a, [hOAMCount]
	inc a
	ldh [hOAMCount], a
;>             if hOAMCount == 40:
;>                 return
	cp $28
	jr nz, .mirrored

	ret


.clipped
;> else:                                  # clipped
;>     if not hSpriteAttr & 0x20:
	ldh a, [hSpriteAttr]
	and $20
	jr nz, .dLoop

.cLoop
;>         while True:
;>             dy = mem[data]; data += 1
	ld a, [hli]
;>             if dy == 0x80:
;>                 return
	cp $80
	ret z

;>             dy = dy if dy < 0x80 else dy - 0x100
	ld c, a
	ld b, $00
	rlca
	jr nc, .cY

	dec b

.cY
;>             y = hSpriteScreenY + dy
	ldh a, [hSpriteScreenY]
	add c
	ld c, a
	ldh a, [hSpriteScreenY + 1]
	adc b
;>             visible = hi(y) == 0 and lo(y) < 0xA8
	jr nz, .cSkip

	ld a, c
	cp $a8
	jr nc, .cSkip

;>             if hSpriteClip == 1:       # (0 cannot happen here)
	ldh a, [hSpriteClip]
	or a
	jr z, .cShow

	cp $01
	jr nz, .cClip2

;>                 visible = lo(y) >= 0x34
	ld a, c
	cp $34
	jr c, .cSkip

	jr .cShow

.cClip2
;>             elif hSpriteClip == 2:
	cp $02
	jr nz, .cClipOther

;>                 visible = lo(y) < 0x71
	ld a, c
	cp $71
	jr c, .cShow

	jr .cSkip

.cClipOther
;>             # (other values: no band)
	jr .cShow

.cSkip
;>             if not visible:
;>                 data += 3
	inc hl
	inc hl
	inc hl
;>                 continue
	jr .cLoop

.cShow
;>             mem[oam] = lo(y); oam += 1
	ld a, c
	ld [de], a
	inc e
;>             dx = mem[data]; data += 1
	ld a, [hli]
	ld c, a
;>             dx = dx if dx < 0x80 else dx - 0x100
	ld b, $00
	rlca
	jr nc, .cX

	dec b

.cX
;>             x = hSpriteScreenX + dx
	ldh a, [hSpriteScreenX]
	add c
	ld c, a
	ldh a, [hSpriteScreenX + 1]
	adc b
;>             visible = hi(x) == 0 and lo(x) < 0xB8
	jr nz, .cUndo

	ld a, c
	cp $b8
	jr c, .cPut

.cUndo
;>             if not visible:
;>                 data += 2
	inc hl
	inc hl
;>                 oam -= 1; mem[oam] = 0
	dec e
	xor a
	ld [de], a
;>                 continue
	jr .cLoop

.cPut
;>             mem[oam] = lo(x)
	ld a, c
	ld [de], a
;>             if not SpriteInFrontOfBG(oam):   # a background tile covers it: take the entry back
;>                 data += 2; oam -= 1; mem[oam] = 0; continue   # (the code at .cUndo)
	call SpriteInFrontOfBG
	jr nc, .cUndo

;>             oam += 1
	inc e
;>             mem[oam] = u8(mem[data] + hSpriteTileBase); oam += 1; data += 1
	ldh a, [hSpriteTileBase]
	ld b, a
	ld a, [hli]
	add b
	ld [de], a
	inc e
;>             mem[oam] = mem[data] ^ hSpriteAttr; oam += 1; data += 1
	ldh a, [hSpriteAttr]
	xor [hl]
	inc hl
	ld [de], a
	inc e
;>             hOAMCount += 1
	ldh a, [hOAMCount]
	inc a
	ldh [hOAMCount], a
;>             if hOAMCount == 40:
;>                 return
	cp $28
	jr nz, .cLoop

	ret


.dLoop
;>     else:                              # clipped and mirrored
;>         while True:
;>             dy = mem[data]; data += 1
	ld a, [hli]
;>             if dy == 0x80:
;>                 return
	cp $80
	ret z

;>             dy = dy if dy < 0x80 else dy - 0x100
	ld c, a
	ld b, $00
	rlca
	jr nc, .dY

	dec b

.dY
;>             y = hSpriteScreenY + dy
	ldh a, [hSpriteScreenY]
	add c
	ld c, a
	ldh a, [hSpriteScreenY + 1]
	adc b
;>             visible = hi(y) == 0 and lo(y) < 0xA8
	jr nz, .dSkip

	ld a, c
	cp $a8
	jr nc, .dSkip

;>             if hSpriteClip == 1:
	ldh a, [hSpriteClip]
	or a
	jr z, .dShow

	cp $01
	jr nz, .dClip2

;>                 visible = lo(y) >= 0x34
	ld a, c
	cp $34
	jr c, .dSkip

	jr .dShow

.dClip2
;>             elif hSpriteClip == 2:
	cp $02
	jr nz, .dClipOther

;>                 visible = lo(y) < 0x71
	ld a, c
	cp $71
	jr c, .dShow

	jr .dSkip

.dClipOther
;>             # (other values: no band)
	jr .dShow

.dSkip
;>             if not visible:
;>                 data += 3
	inc hl
	inc hl
	inc hl
;>                 continue
	jr .dLoop

.dShow
;>             mem[oam] = lo(y); oam += 1
	ld a, c
	ld [de], a
	inc e
;>             dx = mem[data]; data += 1
	ld a, [hli]
	ld c, a
;>             dx = dx if dx < 0x80 else dx - 0x100
	ld b, $00
	rlca
	jr nc, .dX

	dec b

.dX
;>             x = hSpriteScreenXFlip - dx    # mirrored
	ldh a, [hSpriteScreenXFlip]
	sub c
	ld c, a
	ldh a, [hSpriteScreenXFlip + 1]
	sbc b
;>             visible = hi(x) == 0 and lo(x) < 0xB8
	jr nz, .dUndo

	ld a, c
	cp $b8
	jr c, .dPut

.dUndo
;>             if not visible:
;>                 data += 2
	inc hl
	inc hl
;>                 oam -= 1; mem[oam] = 0
	dec e
	xor a
	ld [de], a
;>                 continue
	jr .dLoop

.dPut
;>             mem[oam] = lo(x)
	ld a, c
	ld [de], a
;>             if not SpriteInFrontOfBG(oam):   # a background tile covers it: take the entry back
;>                 data += 2; oam -= 1; mem[oam] = 0; continue   # (the code at .dUndo)
	call SpriteInFrontOfBG
	jr nc, .dUndo

;>             oam += 1
	inc e
;>             mem[oam] = u8(mem[data] + hSpriteTileBase); oam += 1; data += 1
	ldh a, [hSpriteTileBase]
	ld b, a
	ld a, [hli]
	add b
	ld [de], a
	inc e
;>             mem[oam] = mem[data] ^ hSpriteAttr; oam += 1; data += 1
	ldh a, [hSpriteAttr]
	xor [hl]
	inc hl
	ld [de], a
	inc e
;>             hOAMCount += 1
	ldh a, [hOAMCount]
	inc a
	ldh [hOAMCount], a
;>             if hOAMCount == 40:
;>                 return
	cp $28
	jr nz, .dLoop

	ret


;@ def SpriteInFrontOfBG(oam: de) -> carry
;@ path: gfx/sprites
;@ For the OAM entry whose Y and X were just written (`oam` points at X): looks
;@ up the background tile under the sprite's pixel (4, 4) and returns carry
;@ (the sprite stays) when that tile number is below hSpriteBGTile; higher
;@ tiles are in front of sprites.
;@ test: skip polls the LCD
SpriteInFrontOfBG::
;> y = mem[oam - 1]
	push hl
	push bc
	ldh a, [hScrollY]
	ld b, a
	dec e
	ld a, [de]
;> row = (y + lo(hScrollY) - 12) & 0xF8   # OAM Y - 16 + 4
	inc e
	add b
	sub $0c
	and $f8
;> addr = row * 4                         # 32 tiles per row of 8 pixels
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
;> x = mem[oam]
	ldh a, [hScrollX]
	ld b, a
	ld a, [de]
;> col = ((x + lo(hScrollX) - 4) & 0xF8) // 8   # OAM X - 8 + 4
	add b
	sub $04
	and $f8
	rrca
	rrca
	rrca
;> addr = 0x9800 + ((addr + col) & 0x3FF)
	add l
	ld l, a
	ld a, h
	and $03
	adc $98
	ld h, a
;> limit = hSpriteBGTile
	ldh a, [hSpriteBGTile]
	ld b, a
;> disable_interrupts()
	di

.wait
;> while rSTAT & 0x02:                    # wait until VRAM is accessible
;>     wait_hblank()
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .wait

;> tile = mem[addr]
	ld a, [hl]
;> enable_interrupts()
	ei
;> return tile < limit
	cp b
	pop bc
	pop hl
	ret


;@ def SGBPacketDelay()
;@ path: system/sgb
;@ On a Super Game Boy, waits about 4 frames (a busy loop), the time the SGB
;@ needs between packets.
;@ test: skip long busy loop
SGBPacketDelay::
;> if not wOnSGB:
;>     return
	ld a, [wOnSGB]
	or a
	ret z

;>@x for _ in range(0x1B58):
	ld de, $1b58

.loop
;>     pass                               # 10 cycles per pass
	nop
	nop
	nop
	dec de
	ld a, d
	or e
;=@x
	jr nz, .loop

	ret


;@ def DetectSGB() -> carry
;@ path: system/sgb
;@ Looks for a Super Game Boy: asks for two-player mode (packet $0B), then
;@ clocks the pad lines; a Super Game Boy answers by switching the pad number
;@ seen in the low bits of rP1. Then back to one player (packet $0A). Returns
;@ carry when a Super Game Boy was found.
;@ test: skip talks to the Super Game Boy through rP1
DetectSGB::
;> wSGBPacketID = 0x0B                    # two players
	ld a, $0b
	ld [wSGBPacketID], a
;> SendSGBPacket()
	ld hl, far_SendSGBPacket
	rst $10
;> SGBPacketDelay()
	call SGBPacketDelay
;> found = rP1 & 3 != 3
	ldh a, [rP1]
	and $03
	cp $03
	jr nz, .found

;> if not found:
;>     rP1 = 0x20                         # one clock pulse on the pad lines ...
	ld a, $20
	ldh [rP1], a
;>     read_buttons(0x20)
	ldh a, [rP1]
	ldh a, [rP1]
;>     rP1 = 0x30
	ld a, $30
	ldh [rP1], a
;>     rP1 = 0x10
	ld a, $10
	ldh [rP1], a
;>     read_buttons(0x10)                 # (six reads)
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
;>     rP1 = 0x30                         # ... then read the pad number
	ld a, $30
	ldh [rP1], a
;>     pad = rP1                          # (four reads)
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
;>     found = pad & 3 != 3               # the SGB switched to pad 2
	and $03
	cp $03
	jr nz, .found

;>@f1 wSGBPacketID = 0x0A                  # back to one player
	ld a, $0a
	ld [wSGBPacketID], a
;>@f2 SendSGBPacket()
	ld hl, far_SendSGBPacket
	rst $10
;>@f3 SGBPacketDelay()
	call SGBPacketDelay
;>@f4 return found
	sub a
	ret


.found
;=@f1
	ld a, $0a
	ld [wSGBPacketID], a
;=@f2
	ld hl, far_SendSGBPacket
	rst $10
;=@f3
	call SGBPacketDelay
;=@f4
	scf
	ret


;@ def ReadSGBJoypads()
;@ path: system/joypad
;@ Reads the pads of all players connected to a Super Game Boy (up to four):
;@ each read tells which player's pad is selected (the low bits of rP1), and
;@ writing $30 afterwards moves on to the next one; it stops when it is back at
;@ the first. Each player gets the buttons held and the buttons newly pressed in
;@ wSGBJoypads (two bytes per player, bits as in wJoyHeld).
;@ test: skip reads the pad through rP1
ReadSGBJoypads::
;> first = rP1
	ldh a, [rP1]
	ld b, $04
	ld c, a
;>@pl for i in range(4):
	jr .read

.next
;>     if i > 0:
;>         p1 = rP1
	ldh a, [rP1]
;>         if p1 == first:                # all players read
;>             return
	cp c
	ret z

.read
;>     player = ~p1 & 3                   # (p1 = first in the first pass)
	cpl
	and $03
;>     slot = wSGBJoypads + 2 * player
	sla a
	ld d, $00
	ld e, a
	ld hl, wSGBJoypads
	add hl, de
;>     rP1 = 0x20                         # the direction keys
	ld a, $20
	ldh [rP1], a
;>     dirs = (~rP1 & 0x0F) << 4
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0f
	swap a
	ld d, a
;>     rP1 = 0x30
	ld a, $30
	ldh [rP1], a
;>     rP1 = 0x10                         # the buttons
	ld a, $10
	ldh [rP1], a
;>     raw = rP1                          # (six reads while the lines settle)
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
;>     held = dirs | (~raw & 0x0F)
	cpl
	and $0f
	or d
	ld d, a
;>     mem[slot + 1] = (mem[slot] ^ held) & held   # newly pressed
	ld a, [hli]
	xor d
	and d
	ld [hld], a
;>     mem[slot] = held
	ld a, d
	ld [hl], a
;>     rP1 = 0x30                         # on to the next player
	ld a, $30
	ldh [rP1], a
;=@pl
	dec b
	jp nz, .next

	ret


;@ def SGBDelay(frames: bc)
;@ path: system/sgb
;@ On a Super Game Boy, waits about `frames` frames (a busy loop).
;@ test: skip long busy loop
SGBDelay::
;> if not wOnSGB:
;>     return
	ld a, [wOnSGB]
	or a
	ret z

.frame
;>@fr for _ in range(frames):
;>@in     for _ in range(0x06D6):
	ld de, $06d6

.loop
;>         pass                           # 10 cycles per pass
	nop
	nop
	nop
	dec de
	ld a, d
	or e
;=@in
	jr nz, .loop

;=@fr
	dec bc
	ld a, b
	or c
	jr nz, .frame

	ret


;@ def SGBTransferCompressed(packet: a, data: de)
;@ path: system/sgb
;@ Sends a block of graphics data to the Super Game Boy (for the border): the
;@ data (compressed, bank d, entry e of that bank's table) is unpacked to VRAM
;@ $8800, the BG map shows those $1000 bytes as 20 x 13 tiles, and with the
;@ screen on the SGB is sent `packet` (a transfer command), which makes it read
;@ the screen. The LCD is off again afterwards.
;@ test: skip talks to the Super Game Boy
SGBTransferCompressed::
;> wSGBPacketID = packet
	ld [wSGBPacketID], a
;> if not wOnSGB:
;>     return
	ld a, [wOnSGB]
	or a
	ret z

;> TurnOffLCD()
	call TurnOffLCD
;> ClearScroll()
	call ClearScroll
;> rSCX = 0
	xor a
	ldh [rSCX], a
;> rSCY = 0
	ldh [rSCY], a
;> FillMemory(0x8800, 0x1000, 0)
	push de
	ld hl, $8800
	ld bc, $1000
	xor a
	call FillMemory
;> rBGP = 0xE4                            # plain grey shades: bytes go through unchanged
	pop de
	ld a, $e4
	ldh [rBGP], a
;> Decompress(hi(data), lo(data), 0x8800)
	ld hl, $8800
	call Decompress
;> tile = 0x80
	ld hl, $9800
	ld de, $000c
	ld a, $80
;>@rows for row in range(13):
	ld c, $0d

.row
;>@cols     for col in range(20):
	ld b, $14

.col
;>         mem[0x9800 + 32 * row + col] = tile
	ld [hli], a
;>         tile = u8(tile + 1)
	inc a
;=@cols
	dec b
	jr nz, .col

;=@rows
	add hl, de
	dec c
	jr nz, .row

;> rLCDC = 0x81                           # screen on, BG tiles at $8800
	ld a, $81
	ldh [rLCDC], a
;> wLCDC = 0x81
	ld [wLCDC], a
;> SGBDelay(5)
	ld bc, $0005
	call SGBDelay
;> SendSGBPacket()
	ld hl, far_SendSGBPacket
	rst $10
;> SGBDelay(6)
	ld bc, $0006
	call SGBDelay
;> TurnOffLCD()
	call TurnOffLCD
	ret


;@ def SGBTransfer(packet: a, data: de, length: bc)
;@ path: system/sgb
;@ Like SGBTransferCompressed, for `length` bytes of uncompressed data (bank d,
;@ entry e of that bank's table) copied to VRAM $8800.
;@ test: skip talks to the Super Game Boy
SGBTransfer::
;> wSGBPacketID = packet
	ld [wSGBPacketID], a
;> if not wOnSGB:
;>     return
	ld a, [wOnSGB]
	or a
	ret z

;> TurnOffLCD()
	push bc
	call TurnOffLCD
;> ClearScroll()
	call ClearScroll
;> rSCX = 0
	xor a
	ldh [rSCX], a
;> rSCY = 0
	ldh [rSCY], a
;> rBGP = 0xE4
	ld a, $e4
	ldh [rBGP], a
;> saved = rom_bank()
	pop bc
	ld a, [$4000]
	push af
;> set_rom_bank(hi(data))
	push bc
	ld a, d
	ld [$2100], a
;> mem[0x4100] = (hi(data) >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
;> entry = 0x4001 + 2 * lo(data)          # the bank's table of entry points
	ld a, e
	add a
	ld e, a
	ld d, $00
	ld hl, $4001
	add hl, de
;> src = mem16[entry]
	ld e, [hl]
	inc hl
	ld d, [hl]
;>@cp copy(0x8800, src, length)
	pop bc
	ld hl, $8800

.copy
	ld a, [de]
	ld [hli], a
	inc de
;=@cp
	dec bc
	ld a, b
	or c
	jr nz, .copy

;> tile = 0x80
	ld hl, $9800
	ld de, $000c
	ld a, $80
;>@rows for row in range(13):
	ld c, $0d

.row
;>@cols     for col in range(20):
	ld b, $14

.col
;>         mem[0x9800 + 32 * row + col] = tile
	ld [hli], a
;>         tile = u8(tile + 1)
	inc a
;=@cols
	dec b
	jr nz, .col

;=@rows
	add hl, de
	dec c
	jr nz, .row

;> rLCDC = 0x81
	ld a, $81
	ldh [rLCDC], a
;> wLCDC = 0x81
	ld [wLCDC], a
;> SGBDelay(5)
	ld bc, $0005
	call SGBDelay
;> SendSGBPacket()
	ld hl, far_SendSGBPacket
	rst $10
;> SGBDelay(6)
	ld bc, $0006
	call SGBDelay
;> TurnOffLCD()
	call TurnOffLCD
;> set_rom_bank(saved)
	pop af
	ld [$2100], a
;> mem[0x4100] = (saved >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
	ret


;@ def ClearSGBPacket()
;@ path: system/sgb
;@ Clears the 16-byte packet buffer wSGBPacket.
ClearSGBPacket::
;>@f fill(wSGBPacket, 0, 16)
	push hl
	push bc
	xor a
	ld hl, wSGBPacket
	ld c, $10

.loop
;=@f
	ld [hli], a
	dec c
	jr nz, .loop

	pop bc
	pop hl
	ret


;@ def EnableLCDAndInterrupts(enabled: a)
;@ path: system/lcd
;@ Turns the screen on and enables the interrupts in `enabled` (an rIE mask).
;@ Linked games first run CloseLink.
;@ test: skip calls into the link code
EnableLCDAndInterrupts::
;> if wLinkActive:
	push af
	ld a, [wLinkActive]
	or a
	jr z, .on

;>     CloseLink()
	call CloseLink

.on
;> TurnOnLCD()
	call TurnOnLCD
;> SetInterrupts(enabled)
	pop af
	call SetInterrupts
;> enable_interrupts()
	ei
	ret


;@ def DisableInterruptsAndLCD()
;@ path: system/lcd
;@ Clears pending interrupts, disables the VBlank, timer, serial and joypad
;@ interrupts (keeps LCD STAT), then turns the screen off (continues into
;@ TurnOffLCD).
;@ test: skip waits for the LCD
DisableInterruptsAndLCD::
;> rIF = 0
	xor a
	ldh [rIF], a
;> rIE &= 0xE2
	ldh a, [rIE]
	and $e2
	ldh [rIE], a

;@ def TurnOffLCD()
;@ path: system/lcd
;@ Turns the screen off, waiting for line $91 (VBlank) first so the LCD is not
;@ stopped mid-frame.
;@ test: skip waits for the LCD
TurnOffLCD::
;> if not rLCDC & 0x80:
;>     return
	ld hl, rLCDC
	bit 7, [hl]
	ret z

.wait
;> wait_ly(0x91)
	ldh a, [rLY]
	cp $91
	jr nz, .wait

;> rLCDC &= ~0x80
	res 7, [hl]
;> wLCDC &= ~0x80
	ld hl, wLCDC
	res 7, [hl]
	ret


;@ def TurnOnLCD()
;@ path: system/lcd
;@ Turns the screen on (through wLCDC); on a Super Game Boy sends packet 1.
;@ The bytes after it are an unused routine that disables the serial interrupt.
;@ test: skip talks to the Super Game Boy
TurnOnLCD::
;> wLCDC |= 0x80
	ld hl, wLCDC
	set 7, [hl]
;> rLCDC = wLCDC
	ld a, [hl]
	ldh [rLCDC], a
;> if not wOnSGB:
;>     return
	ld a, [wOnSGB]
	or a
	ret z

;> wSGBPacketID = 1
	ld a, $01
	ld [wSGBPacketID], a
;> SendSGBPacket()
	ld hl, far_SendSGBPacket
	rst $10
;> SGBPacketDelay()
	call SGBPacketDelay
	ret


	db $c9, $af, $e0, $0f, $f0, $ff, $e6, $f7, $e0, $ff, $c9

;@ def WaitSerialTransfer()
;@ path: link/serial
;@ Waits until the current link cable transfer is done.
;@ test: skip polls rSC
WaitSerialTransfer::
;> wait_serial()
	ldh a, [rSC]
	bit 7, a
	jr nz, WaitSerialTransfer

	ret


;@ def SetInterrupts(enabled: a)
;@ path: system/interrupts
;@ Clears pending interrupts and enables those in `enabled`.
SetInterrupts::
;> rIF = 0
	ld b, a
	xor a
	ldh [rIF], a
;> rIE = enabled
	ld a, b
	ldh [rIE], a
	ret


;@ def ApplyScroll()
;@ path: gfx/scroll
;@ Copies the scroll and window positions to the LCD registers (VBlank).
ApplyScroll::
;> rSCX = lo(hScrollX)
	ldh a, [hScrollX]
	ldh [rSCX], a
;> rSCY = lo(hScrollY)
	ldh a, [hScrollY]
	ldh [rSCY], a
;> rWX = hWX
	ldh a, [hWX]
	ldh [rWX], a
;> rWY = hWY
	ldh a, [hWY]
	ldh [rWY], a
	ret


;@ def ApplyLCDC()
;@ path: system/lcd
;@ Writes wLCDC to rLCDC once the LCD is not reading VRAM.
;@ test: skip polls the LCD
ApplyLCDC::
;> while rSTAT & 0x02:
;>     wait_hblank()
	ldh a, [rSTAT]
	bit 1, a
	jr nz, ApplyLCDC

;> rLCDC = wLCDC
	ld a, [wLCDC]
	ldh [rLCDC], a
	ret


;@ def ApplyPalettes()
;@ path: gfx/palettes
;@ VBlank palette update: the Game Boy Color palettes (bank $17 entry 3), then
;@ the Game Boy palettes wBGP, wOBP0, wOBP1.
;@ test: skip calls a routine in another bank
ApplyPalettes::
;> far_call(0x17, 0x03)                   # Game Boy Color palettes
	ld hl, $1703
	rst $10
;> rBGP = wBGP
	ld hl, wBGP
	ld a, [hli]
	ldh [rBGP], a
;> rOBP0 = wOBP0
	ld a, [hli]
	ldh [rOBP0], a
;> rOBP1 = wOBP1
	ld a, [hl]
	ldh [rOBP1], a
	ret


;@ def EnableLYCInterrupt()
;@ path: system/interrupts
;@ Lets the LCD STAT interrupt fire on the LY=LYC match.
EnableLYCInterrupt::
;> rSTAT |= 0x40
	ldh a, [rSTAT]
	or $40
	ldh [rSTAT], a
	ret


;@ def DisableSTATInterrupts()
;@ path: system/interrupts
;@ Switches off all LCD STAT interrupt sources.
DisableSTATInterrupts::
;> rSTAT &= 0x07
	ldh a, [rSTAT]
	and $07
	ldh [rSTAT], a
	ret


;@ def SerialSendMaster(value: a)
;@ path: link/serial
;@ Starts sending `value` over the link cable with the internal clock (this
;@ Game Boy drives the transfer).
;@ test: skip starts a serial transfer
SerialSendMaster::
;> disable_interrupts()
	di
;> SetSerialByte(value)
	call SetSerialByte
;> rSC = 0x81
	ld a, $81
	ldh [rSC], a
;> enable_interrupts()
	ei
	ret


;@ def SerialSendSlave(value: a)
;@ path: link/serial
;@ Puts `value` up for sending and waits for the other Game Boy's clock.
;@ test: skip starts a serial transfer
SerialSendSlave::
;> disable_interrupts()
	di
;> SetSerialByte(value)
	call SetSerialByte
;> rSC = 0x80
	ld a, $80
	ldh [rSC], a
;> enable_interrupts()
	ei
	ret


;@ def SetSerialByte(value: a)
;@ path: link/serial
;@ Stops any transfer and loads `value` into the serial data register.
;@ test: skip writes the serial registers
SetSerialByte::
;> rSC = 0
	ld b, a
	ld a, $00
	ldh [rSC], a
;> rSB = value
	ld a, b
	ldh [rSB], a
	ret


;@ def ClearRAM()
;@ path: system/boot
;@ Clears WRAM $C000-$DDFF and HRAM $FF8A-$FFFD, keeping wOnCGB.
;@ test: skip clears the whole RAM
ClearRAM::
;> on_cgb = wOnCGB
	ld a, [wOnCGB]
	push af
;> FillMemory(wShadowOAM, 0x1E00, 0)
	ld hl, wShadowOAM
	ld bc, $1e00
	xor a
	call FillMemory
;> FillMemory(hPlayerGfx, 0x74, 0)        # $FF8A-$FFFD
	ld hl, hPlayerGfx
	ld bc, $0074
	xor a
	call FillMemory
;> wOnCGB = on_cgb
	pop af
	ld [wOnCGB], a
	ret


;@ def ClearBGMaps()
;@ path: gfx/tilemap
;@ Clears both BG maps ($9800-$9FFF) to tile 0, and on a Game Boy Color their
;@ attributes too.
;@ test: skip writes VRAM bank 1
ClearBGMaps::
;> FillMemory(0x9800, 0x800, 0)
	ld hl, $9800
	ld bc, $0800
	xor a
	call FillMemory
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> rVBK = 1
	ld a, $01
	ldh [rVBK], a
;> FillMemory(0x9800, 0x800, 0)           # the attributes
	ld hl, $9800
	ld bc, $0800
	xor a
	call FillMemory
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
	ret


;@ def FillMemory(dest: hl, count: bc, value: a)
;@ path: system/memory
;@ Sets `count` bytes from `dest` on to `value` (count 0 means 65536).
;@ test: count = rand(1, 0x100)
FillMemory::
;>@fill fill(dest, value, count)
	ld d, a

.loop
	ld [hl], d
	inc hl
	dec bc
	ld a, b
;=@fill
	or c
	jr nz, .loop

	ret


;@ def Random() -> a
;@ path: system/random
;@ Steps the random number generator: x = x * 5 + $1357 (16 bits), returns the
;@ new low byte. The main loop calls it all the time while the game waits.
Random::
;> x = (wRandomHigh << 8 | wRandomLow)
	push hl
	push de
	ld a, [wRandomHigh]
	ld h, a
	ld a, [wRandomLow]
	ld l, a
;>@x x = u16(x * 5 + 0x1357)
	ld d, h
	ld e, l
	add hl, hl
	add hl, hl
	add hl, de
;=@x
	ld de, $1357
	add hl, de
;> wRandomHigh = hi(x)
	ld a, h
	ld [wRandomHigh], a
;> wRandomLow = lo(x)
	ld a, l
	ld [wRandomLow], a
;> return lo(x)
	pop de
	pop hl
	ret


;@ def ReadJoypad()
;@ path: system/joypad
;@ Reads the pad into wJoyHeld (and keeps the previous state in wJoyHeldLast).
;@ On a Super Game Boy it reads all players' pads; player 2's goes to
;@ wJoy2Held. The bytes after it are an unused variant that reads the pad into
;@ wJoy2Held.
;@ test: skip reads the pad through rP1
ReadJoypad::
;> if wOnSGB:
	ld a, [wOnSGB]
	or a
	jr z, .plain

;>     ReadSGBJoypads()
	call ReadSGBJoypads
;>     wJoyHeldLast = wJoyHeld
	ld a, [wJoyHeld]
	ld [wJoyHeldLast], a
;>     wJoyHeld = wSGBJoypads[0]          # player 1
	ld a, [wSGBJoypads]
	ld [wJoyHeld], a
;>     wJoy2HeldLast = wJoy2Held
	ld a, [wJoy2Held]
	ld [wJoy2HeldLast], a
;>     wJoy2Held = wSGBJoypads[2]         # player 2
	ld a, [wSGBJoypads + 2]
	ld [wJoy2Held], a
	ret


.plain
;> else:
;>     wJoy2Active = 0
	xor a
	ld [wJoy2Active], a
;>     held = ReadButtons()
	call ReadButtons
;>     wJoyHeldLast = wJoyHeld
	ld a, [wJoyHeld]
	ld [wJoyHeldLast], a
;>     wJoyHeld = held
	ld a, b
	ld [wJoyHeld], a
;>     rP1 = 0x30                         # deselect both groups
	ld a, $30
	ldh [rP1], a
	ret


	db $cd, $38, $13, $fa, $44, $c8, $ea, $45, $c8, $78, $ea, $44, $c8, $3e, $30, $e0
	db $00, $c9

;@ def ReadButtons() -> b
;@ path: system/joypad
;@ Reads the pad: returns Down Up Left Right in bits 7-4 and Start Select B A
;@ in bits 3-0 (set = pressed). The extra reads give the lines time to settle.
;@ test: skip reads the pad through rP1
ReadButtons::
;> rP1 = 0x20                             # the direction keys
	ld a, $20
	ldh [rP1], a
;> dirs = (~rP1 & 0x0F) << 4              # (two reads)
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0f
	swap a
	ld b, a
;> rP1 = 0x10                             # the buttons
	ld a, $10
	ldh [rP1], a
;> raw = rP1                              # (ten reads) ...
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
;> # ...
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
;> return dirs | (~raw & 0x0F)
	cpl
	and $0f
	or b
	ld b, a
	ret


;@ def UpdateJoypadPresses()
;@ path: system/joypad
;@ From the held buttons works out, for both pads, the buttons newly pressed
;@ this frame and the "repeat" buttons: new presses, and while the same buttons
;@ stay held, all of them again after 20 frames and then every 6 frames (for
;@ scrolling through menus). The second pad is cleared unless it is in use.
UpdateJoypadPresses::
;> if not wLinkActive and not wJoy2Active:
	ld a, [wLinkActive]
	or a
	jr nz, .pad1

	ld a, [wJoy2Active]
	or a
	jr nz, .pad1

;>     wJoy2Held = 0
	xor a
	ld [wJoy2Held], a
;>     wJoy2HeldLast = 0
	ld [wJoy2HeldLast], a

.pad1
;> wJoyRepeat = 0
	xor a
	ld [wJoyRepeat], a
;> changed = wJoyHeld ^ wJoyHeldLast
	ld hl, wJoyHeld
	ld a, [hl]
	inc hl
	xor [hl]
;> wJoyPressed = wJoyHeld & changed
	dec hl
	and [hl]
	ld [wJoyPressed], a
;> if wJoyHeld == 0 or wJoyHeld != wJoyHeldLast:
	ld hl, wJoyHeld
	ld a, [hli]
	or a
	jr z, .new1

	cp [hl]
	jr z, .same1

.new1
;>     wJoyRepeat = wJoyPressed
	ld a, [wJoyPressed]
	ld [wJoyRepeat], a
;>     wJoyRepeatTimer = 20
	ld a, $14
	ld [wJoyRepeatTimer], a
	jr .pad2

.same1
;> else:
;>     if wJoyRepeatTimer == 0:
	ld hl, wJoyRepeatTimer
	ld a, [hl]
	or a
	jr nz, .tick1

;>         wJoyRepeatTimer = 6
	ld [hl], $06
;>         wJoyRepeat = wJoyHeld
	ld a, [wJoyHeld]
	ld [wJoyRepeat], a

.tick1
;>     wJoyRepeatTimer -= 1
	dec [hl]

.pad2
;> wJoy2Repeat = 0
	xor a
	ld [wJoy2Repeat], a
;> changed = wJoy2Held ^ wJoy2HeldLast
	ld hl, wJoy2Held
	ld a, [hl]
	inc hl
	xor [hl]
;> wJoy2Pressed = wJoy2Held & changed
	dec hl
	and [hl]
	ld [wJoy2Pressed], a
;> if wJoy2Held == 0 or wJoy2Held != wJoy2HeldLast:
	ld hl, wJoy2Held
	ld a, [hli]
	or a
	jr z, .new2

	cp [hl]
	jr z, .same2

.new2
;>     wJoy2Repeat = wJoy2Pressed
	ld a, [wJoy2Pressed]
	ld [wJoy2Repeat], a
;>     wJoy2RepeatTimer = 20
	ld a, $14
	ld [wJoy2RepeatTimer], a
	jr .done

.same2
;> else:
;>     if wJoy2RepeatTimer == 0:
	ld hl, wJoy2RepeatTimer
	ld a, [hl]
	or a
	jr nz, .tick2

;>         wJoy2RepeatTimer = 6
	ld [hl], $06
;>         wJoy2Repeat = wJoy2Held
	ld a, [wJoy2Held]
	ld [wJoy2Repeat], a

.tick2
;>     wJoy2RepeatTimer -= 1
	dec [hl]

.done
	ret


	db $87, $85, $6f, $3e, $00, $8c, $67, $2a, $66, $6f, $c9

;@ def InitPalettes()
;@ path: gfx/palettes
;@ Sets the Game Boy palettes to their start values (BGP $D2, OBP0 $D2,
;@ OBP1 $E2) and keeps a copy in wDefaultPalettes. (The bytes before it are an
;@ unused table-pointer lookup.)
InitPalettes::
;> wBGP = 0xD2
	ld hl, wBGP
	ld a, $d2
	ld [hli], a
;> wOBP0 = 0xD2
	ld a, $d2
	ld [hli], a
;> wOBP1 = 0xE2
	ld a, $e2
	ld [hl], a
;> wDefaultPalettes[0] = wBGP
	ld hl, wDefaultPalettes
	ld a, [wBGP]
	ld [hli], a
;> wDefaultPalettes[1] = wOBP0
	ld a, [wOBP0]
	ld [hli], a
;> wDefaultPalettes[2] = wOBP1
	ld a, [wOBP1]
	ld [hl], a
	ret


;@ def ClearScroll()
;@ path: gfx/scroll
;@ Zeroes the eight HRAM bytes from hScrollX on (both scroll positions): four
;@ here, four more by running on into Clear4Bytes.
;@ test: skip falls through into Clear4Bytes
ClearScroll::
;> fill(hScrollX, 0, 8)
	xor a
	ld hl, hScrollX
	call Clear4Bytes

;@ def Clear4Bytes(dest: hl, value: a) -> hl
;@ path: system/memory
;@ Writes `value` to four bytes from `dest` on; returns the address after them.
Clear4Bytes::
;> fill(dest, value, 4)
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
;> return dest + 4
	ret


;@ def ClearShadowOAM()
;@ path: gfx/oam
;@ Empties the sprite list: hOAMCount = 0 and all of wShadowOAM zero.
ClearShadowOAM::
;> hOAMCount = 0
	xor a
	ldh [hOAMCount], a
;> FillMemory(wShadowOAM, 160, 0)
	ld hl, wShadowOAM
	ld bc, $00a0
	call FillMemory
	ret


;@ def HideUnusedSprites()
;@ path: gfx/oam
;@ Hides the shadow OAM slots from hOAMCount to 39 (Y = 0).
HideUnusedSprites::
;> if hOAMCount == 40:
;>     return
	ldh a, [hOAMCount]
	cp $28
	ret z

;>@hide for slot in range(hOAMCount, 40):
	ld l, a
	sla l
	sla l
	ld h, $c0
	sub $28
	ld b, a
;>     wShadowOAM[4 * slot] = 0
	xor a

.loop
	ld [hli], a
	inc l
	inc l
	inc l
;=@hide
	inc b
	jr nz, .loop

	ret


;@ def CopyMapUpdate()
;@ path: gfx/tilemap
;@ VBlank part of the map streaming: copies the queued row or column of tiles
;@ (wMapUpdateTiles, wMapUpdateLen of them) to the BG map at wMapUpdateDest; on
;@ a Game Boy Color the attributes that follow the tiles in the buffer go to VRAM
;@ bank 1. A row wraps within its 32 columns, a column within the map at
;@ $9800. Then the queue is emptied.
;@ test: skip writes VRAM bank 1
CopyMapUpdate::
;> dest = wMapUpdateDest
	ld a, [wMapUpdateDest]
	ld e, a
	ld a, [wMapUpdateDest + 1]
	ld d, a
;> if dest == 0:                          # nothing queued
;>     return
	ld a, d
	or e
	jr nz, .queued

	ret


.queued
;> count = wMapUpdateLen
	ld a, [wMapUpdateLen]
	ld b, a
;> src = wMapUpdateTiles
	ld hl, wMapUpdateTiles
;> if wMapUpdateDir == 0xFF:
;>     return
	ld a, [wMapUpdateDir]
	cp $ff
	ret z

;> if wMapUpdateDir == 0:                 # a row
	or a
	jr nz, .column

;>     row = lo(dest) & 0xE0
	ld a, e
	and $e0
	ld c, a

.row
;>@r1     for _ in range(count):
;>         mem[dest] = mem[src]; src += 1
	ld a, [hli]
	ld [de], a
;>         dest = (dest & 0xFF00) | row | ((lo(dest) + 1) & 0x1F)
	inc e
	ld a, e
	and $1f
	or c
	ld e, a
;=@r1
	dec b
	jr nz, .row

;>     if wOnCGB:
	ld a, [wOnCGB]
	or a
	jr z, .done

;>         rVBK = 1                       # the attributes
	ld a, $01
	ldh [rVBK], a
;>         dest = wMapUpdateDest
	ld a, [wMapUpdateDest]
	ld e, a
	ld a, [wMapUpdateDest + 1]
	ld d, a
;>         count = wMapUpdateLen
	ld a, [wMapUpdateLen]
	ld b, a

.rowAttr
;>@r2         for _ in range(count):
;>             mem[dest] = mem[src]; src += 1
	ld a, [hli]
	ld [de], a
;>             dest = (dest & 0xFF00) | row | ((lo(dest) + 1) & 0x1F)
	inc e
	ld a, e
	and $1f
	or c
	ld e, a
;=@r2
	dec b
	jr nz, .rowAttr

;>         rVBK = 0
	ld a, $00
	ldh [rVBK], a
	jr .done

.column
;> else:                                  # a column
;>@c1     for _ in range(count):
;>         mem[dest] = mem[src]; src += 1
	ld a, [hli]
	ld [de], a
;>         dest = (dest + 0x20) & ~0x0400  # next row, wrapping from $9C00 to $9800
	ld a, e
	add $20
	ld e, a
	ld a, d
	adc $00
	res 2, a
;=@c1
	ld d, a
	dec b
	jr nz, .column

;>     if wOnCGB:
	ld a, [wOnCGB]
	or a
	jr z, .done

;>         rVBK = 1
	ld a, $01
	ldh [rVBK], a
;>         dest = wMapUpdateDest
	ld a, [wMapUpdateDest]
	ld e, a
	ld a, [wMapUpdateDest + 1]
	ld d, a
;>         count = wMapUpdateLen
	ld a, [wMapUpdateLen]
	ld b, a

.columnAttr
;>@c2         for _ in range(count):
;>             mem[dest] = mem[src]; src += 1
	ld a, [hli]
	ld [de], a
;>             dest = (dest + 0x20) & ~0x0400
	ld a, e
	add $20
	ld e, a
	ld a, d
	adc $00
	res 2, a
;=@c2
	ld d, a
	dec b
	jr nz, .columnAttr

;>         rVBK = 0
	ld a, $00
	ldh [rVBK], a

.done
;> wMapUpdateDest = 0
	xor a
	ld [wMapUpdateDest], a
	ld [wMapUpdateDest + 1], a
	ret


;@ def Decompress(bank: d, entry: e, dest: hl)
;@ path: gfx/decompress
;@ Unpacks compressed data (entry `entry` of bank `bank`'s table) to `dest` in
;@ RAM (see DecompressCore for the format). wDecompressBusy keeps two
;@ decompressions (one may run from the VBlank handler) from mixing their
;@ HRAM state: this one waits until the other is done.
;@ test: skip switches banks
Decompress::
;> while wDecompressBusy:
;>     wait_vblank_flag()
	ld a, [wDecompressBusy]
	or a
	jr nz, Decompress

;> wDecompressBusy = 1
	inc a
	ld [wDecompressBusy], a
;> DecompressCore(bank, entry, dest)
	call DecompressCore
;> wDecompressBusy = 0
	xor a
	ld [wDecompressBusy], a
	ret


;@ def DecompressCore(bank: d, entry: e, dest: hl)
;@ path: gfx/decompress
;@ The game's compression format (graphics, maps and more). The data starts
;@ with a header: the unpacked length (2 bytes, little endian) and a marker
;@ byte. Then a stream of bytes: any byte other than the marker is copied
;@ as it is. The marker starts a back-reference of 2 or 3 more bytes:
;@ `ll`, `hc` (and `nn`): offset = h << 8 | ll (12 bits), count = c + 4, and when
;@ c is $F the count is nn + $13 instead. The reference copies `count` bytes
;@ from dest + offset on (dest = the start of the output); a position at or past
;@ the end of the output (dest + length) is taken $1000 lower, and a position
;@ that then lies before dest gives 0. So the output works as a 4 KiB window.
;@ Unpacking stops after `length` bytes, even inside a reference.
;@ test: skip switches banks
DecompressCore::
;> saved = rom_bank()
	ld a, [$4000]
	push af
;> length, data = DecompressSetup(bank, entry, dest)   # switches to the data's bank
	call DecompressSetup

.next
;> while True:
;>     byte = mem[data]; data += 1
	ld a, [de]
	inc de
;>     if byte != hLZMarker:              # a literal byte
	push hl
	ld hl, hLZMarker
	cp [hl]
	jr z, .reference

;>         mem[dest] = byte; dest += 1
	pop hl
	ld [hl], a
	inc hl
;>         length -= 1
	dec bc
;>         if length == 0:
;>             break
	ld a, b
	or c
	jr nz, .next

	jp .end


.reference
;>     else:                              # a back-reference
;>         hLZOffset = mem[data]; data += 1
	pop hl
	ld a, [de]
	ldh [hLZOffset], a
	inc de
;>         x = mem[data]; data += 1
	ld a, [de]
	ldh [hLZCount], a
	inc de
;>         count = (x & 0x0F) + 4
	ldh a, [hLZCount]
	push af
	and $0f
	add $04
;>         if count == 0x13:              # a long one: the count follows
;>             count = mem[data] + 0x13; data += 1
	cp $13
	jr nz, .count

	ld a, [de]
	inc de
	add $13

.count
;>         hLZCount = count
	ldh [hLZCount], a
;>         offset = (x >> 4) << 8 | hLZOffset
	pop af
	push de
	swap a
	and $0f
	ld d, a
	ldh a, [hLZOffset]
;>@src         src = hLZDest + offset
	ld e, a
	push hl
	ldh a, [hLZDest]
	ld l, a
	ldh a, [hLZDest + 1]
	ld h, a
;=@src
	add hl, de
	ld e, l
	ld d, h
	pop hl

.copy
;>         while True:
;>             value = None               # (set to 0 below for a position before the output)
;>@ge             if src >= hLZEnd:          # past the end: back by 4 KiB
	ldh a, [hLZEnd + 1]
	cp d
	jr z, .endLow

	jr c, .wrap

	jr .byte

.endLow
;=@ge
	ldh a, [hLZEnd]
	cp e
	jr z, .wrap

	jr nc, .byte

.wrap
;>                 src -= 0x1000
	ld a, $f0
	add d
	ld d, a
;>@zero                 if src < hLZStart:      # before the output: a zero
	ldh a, [hLZStart + 1]
	cp d
	jr z, .startLow

	jr nc, .zero

	jr .byte

.startLow
;=@zero
	ldh a, [hLZStart]
	cp e
	jr z, .byte

	jr c, .byte

.zero
;>                     src += 0x1000
	ld a, $10
	add d
	ld d, a
;>                     value = 0
	xor a
	jr .put

.byte
;>             if value is None:
;>                 value = mem[src]
	ld a, [de]

.put
;>             mem[dest] = value; dest += 1
	ld [hli], a
;>             src += 1
	inc de
;>             length -= 1
	dec bc
;>             if length == 0:
;>                 break
	ld a, b
	or c
	jr z, .finish

;>             hLZCount -= 1
	ldh a, [hLZCount]
	dec a
	ldh [hLZCount], a
;>             if hLZCount == 0:
;>                 break
	jr nz, .copy

;>@fin         if length == 0: break
;>         # (data pointer back from the stack)
	pop de
	jp .next


.finish
;=@fin
	pop de

.end
;> set_rom_bank(saved)
	pop af
	ld [$2100], a
;> mem[0x4100] = (saved >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
	ret


;@ def DecompressVRAM(bank: d, entry: e, dest: hl)
;@ path: gfx/decompress
;@ Like Decompress, for a destination in VRAM while the screen is on (every
;@ byte is read and written when VRAM is accessible).
;@ test: skip switches banks
DecompressVRAM::
;> while wDecompressBusy:
;>     wait_vblank_flag()
	ld a, [wDecompressBusy]
	or a
	jr nz, DecompressVRAM

;> wDecompressBusy = 1
	inc a
	ld [wDecompressBusy], a
;> DecompressVRAMCore(bank, entry, dest)
	call DecompressVRAMCore
;> wDecompressBusy = 0
	xor a
	ld [wDecompressBusy], a
	ret


;@ def DecompressVRAMCore(bank: d, entry: e, dest: hl)
;@ path: gfx/decompress
;@ DecompressCore for VRAM: writes through WriteVRAMInc, and back-references
;@ read the earlier output from VRAM once it is accessible.
;@ test: skip switches banks
DecompressVRAMCore::
;> saved = rom_bank()
	ld a, [$4000]
	push af
;> length, data = DecompressSetup(bank, entry, dest)
	call DecompressSetup

.next
;> while True:
;>     byte = mem[data]; data += 1
	ld a, [de]
	inc de
;>     if byte != hLZMarker:
	push hl
	ld hl, hLZMarker
	cp [hl]
	jr z, .reference

;>         dest = WriteVRAMInc(dest, byte)
	pop hl
	call WriteVRAMInc
;>         length -= 1
	dec bc
;>         if length == 0:
;>             break
	ld a, b
	or c
	jr nz, .next

	jp .end


.reference
;>     else:
;>         hLZOffset = mem[data]; data += 1
	pop hl
	ld a, [de]
	ldh [hLZOffset], a
	inc de
;>         x = mem[data]; data += 1
	ld a, [de]
	ldh [hLZCount], a
	inc de
;>         count = (x & 0x0F) + 4
	ldh a, [hLZCount]
	push af
	and $0f
	add $04
;>         if count == 0x13:
;>             count = mem[data] + 0x13; data += 1
	cp $13
	jr nz, .count

	ld a, [de]
	inc de
	add $13

.count
;>         hLZCount = count
	ldh [hLZCount], a
;>         offset = (x >> 4) << 8 | hLZOffset
	pop af
	push de
	swap a
	and $0f
	ld d, a
	ldh a, [hLZOffset]
;>@src         src = hLZDest + offset
	ld e, a
	push hl
	ldh a, [hLZDest]
	ld l, a
	ldh a, [hLZDest + 1]
	ld h, a
;=@src
	add hl, de
	ld e, l
	ld d, h
	pop hl

.copy
;>         while True:
;>             value = None
;>@ge             if src >= hLZEnd:
	ldh a, [hLZEnd + 1]
	cp d
	jr z, .endLow

	jr c, .wrap

	jr .byte

.endLow
;=@ge
	ldh a, [hLZEnd]
	cp e
	jr z, .wrap

	jr nc, .byte

.wrap
;>                 src -= 0x1000
	ld a, $f0
	add d
	ld d, a
;>@zero                 if src < hLZStart:
	ldh a, [hLZStart + 1]
	cp d
	jr z, .startLow

	jr nc, .zero

	jr .byte

.startLow
;=@zero
	ldh a, [hLZStart]
	cp e
	jr z, .byte

	jr c, .byte

.zero
;>                     src += 0x1000
	ld a, $10
	add d
	ld d, a
;>                     value = 0
	xor a
	jr .put

.byte
;>             if value is None:
;>                 disable_interrupts()
	di
;>                 WaitVRAMAccess()
	call WaitVRAMAccess
;>                 value = mem[src]
	ld a, [de]
;>                 enable_interrupts()
	ei

.put
;>             dest = WriteVRAMInc(dest, value)
	call WriteVRAMInc
;>             src += 1
	inc de
;>             length -= 1
	dec bc
;>             if length == 0:
;>                 break
	ld a, b
	or c
	jr z, .finish

;>             hLZCount -= 1
	ldh a, [hLZCount]
	dec a
	ldh [hLZCount], a
;>             if hLZCount == 0:
;>                 break
	jr nz, .copy

;>@fin         if length == 0: break
;>         # (data pointer back from the stack)
	pop de
	jp .next


.finish
;=@fin
	pop de

.end
;> set_rom_bank(saved)
	pop af
	ld [$2100], a
;> mem[0x4100] = (saved >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
	ret


;@ def DecompressSetup(bank: d, entry: e, dest: hl) -> (bc, de)
;@ path: gfx/decompress
;@ Switches to `bank`, finds entry `entry` of its table at $4001 and reads the
;@ compressed data's header: returns the unpacked length and the address of
;@ the stream, and sets hLZMarker, hLZDest/hLZStart (= dest) and hLZEnd
;@ (= dest + length). Leaves the bank switched in.
;@ test: skip switches banks
DecompressSetup::
;> set_rom_bank(bank)
	ld a, d
	ld [$2100], a
;> mem[0x4100] = (bank >> 5) & 3
	swap a
	rra
	and $03
	ld [$4100], a
;> slot = 0x4001 + 2 * entry              # the bank's table of entry points
	push hl
	ld l, e
	ld h, $00
	add hl, hl
	ld de, $4001
	add hl, de
;> header = mem16[slot]
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
;> length = mem16[header]
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	inc de
;> hLZMarker = mem[header + 2]
	ld a, [de]
	ldh [hLZMarker], a
	inc de
;> hLZDest = dest
	ld a, l
	ldh [hLZDest], a
	ld a, h
	ldh [hLZDest + 1], a
;> hLZEnd = dest + length
	push hl
	add hl, bc
	ld a, l
	ldh [hLZEnd], a
	ld a, h
	ldh [hLZEnd + 1], a
;> hLZStart = dest
	pop hl
	ld a, l
	ldh [hLZStart], a
	ld a, h
	ldh [hLZStart + 1], a
;> return length, header + 3
	ret


;@ def InitFade()
;@ path: gfx/fade
;@ Resets the palette fade: the current Game Boy palettes become the fade
;@ palettes, no fade runs, fades go to white on all three Game Boy palettes and
;@ all four SGB palettes.
InitFade::
;> wFadePalettes[0] = wBGP
	ld hl, wFadePalettes
	ld a, [wBGP]
	ld [hli], a
;> wFadePalettes[1] = wOBP0
	ld a, [wOBP0]
	ld [hli], a
;> wFadePalettes[2] = wOBP1
	ld a, [wOBP1]
	ld [hl], a
	jr .clear

.clear
;>@f fill(wFadeLevel, 0, 5)                 # level, speed, timer, colour offset
	xor a
	ld hl, wFadeLevel
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
;=@f
	ld [hl], a
;> wFadeState = 0
	ld [wFadeState], a
;> wFadeType = 0x07                       # to white, all of BGP, OBP0, OBP1
	ld a, $07
	ld [wFadeType], a
;> wFadeSGBMask = 0x1F                    # all four SGB palettes
	ld a, $1f
	ld [wFadeSGBMask], a
	ret


;@ def StartFade(state: a)
;@ path: gfx/fade
;@ Starts a palette fade; UpdateFade then runs it in the VBlank handler. `state`
;@ bit 7 set = fade in (from white, or black when wFadeType bit 7 is set, to the
;@ palettes), clear = fade out. The rest sets the speed: frames per step are
;@ state / 4 on a Super Game Boy and state + 2 on a Game Boy for a fade-out,
;@ and (~state) / 4 or ~state + 2 for a fade-in. On a Game Boy Color bank $17
;@ does the work. A fade-out also calls StartMusicFadeOut.
;@ test: skip talks to the Super Game Boy and calls routines in other banks
StartFade::
;> if wOnCGB:
	ld b, a
	ld a, [wOnCGB]
	or a
	jp nz, .cgb

;>@cgb1     wFadeState = state
;>@cgb2     StartCGBFade()
;> elif wOnSGB:
	ld a, [wOnSGB]
	or a
	jp z, .dmg

;>     if not state & 0x80:               # fade out
	bit 7, b
	jr nz, .sgbIn

;>         wFadeState = state
	ld a, b
	ld [wFadeState], a
;>@t1         copy(wSGBPalettesTarget, wSGBPalettes, 32)   # fade from the current colours
	ld hl, wSGBPalettesTarget
	ld de, wSGBPalettes
	ld c, $20

.copy1
;=@t1
	ld a, [de]
	ld [hli], a
	inc de
	dec c
	jr nz, .copy1

;>         wFadeLevel = 0
	ld a, $00
	ld [wFadeLevel], a
;>         wFadeSpeed = wFadeState >> 2
	ld a, [wFadeState]
	srl a
	srl a
	ld [wFadeSpeed], a
;>         wFadeTimer = wFadeSpeed
	ld [wFadeTimer], a
;>         StartMusicFadeOut()
	call StartMusicFadeOut
	jp .done


.sgbIn
;>     else:                              # fade in
;>         wFadeState = state
	ld a, b
	ld [wFadeState], a
;>         wFadeLevel = 0x20
	ld a, $20
	ld [wFadeLevel], a
;>         wFadeSpeed = (~wFadeState & 0xFF) >> 2
	ld a, [wFadeState]
	cpl
	srl a
	srl a
	ld [wFadeSpeed], a
;>         wFadeTimer = wFadeSpeed
	ld [wFadeTimer], a
;>@t2         copy(wSGBPalettesTarget, wSGBPalettes, 32)   # the colours to fade to
	ld hl, wSGBPalettesTarget
	ld de, wSGBPalettes
	ld c, $20

.copy2
;=@t2
	ld a, [de]
	ld [hli], a
	inc de
	dec c
	jr nz, .copy2

;>         color = 0x7FFF                 # white ...
	ld de, $7fff
;>         if wFadeType & 0x80:
;>             color = 0x0000             # ... or black
	ld a, [wFadeType]
	bit 7, a
	jr z, .fill

	ld de, $0000

.fill
;>@fl         for i in range(16):
	ld hl, wSGBPalettes
	ld c, $10

.fillLoop
;>             mem16[wSGBPalettes + 2 * i] = color
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
;=@fl
	dec c
	jr nz, .fillLoop

;>         ClearSGBPacket()
	call ClearSGBPacket
;>         wSGBPacket[0] = 0x01               # PAL01: palettes 0 and 1
	ld hl, wSGBPalettes
	ld de, wSGBPacket
	ld a, $01
	ld [de], a
;>         SendSGBPalettePacket(wSGBPalettes, wSGBPacket + 1)
	inc de
	call SendSGBPalettePacket
;>         SGBPacketDelay()
	call SGBPacketDelay
;>         if wFadeSGBMask & 0x10:
	ld a, [wFadeSGBMask]
	bit 4, a
	jp z, .done

;>             ClearSGBPacket()
	call ClearSGBPacket
;>             wSGBPacket[0] = 0x09           # PAL23: palettes 2 and 3
	ld hl, wSGBPalettes + 16
	ld de, wSGBPacket
	ld a, $09
	ld [de], a
;>             SendSGBPalettePacket(wSGBPalettes + 16, wSGBPacket + 1)
	inc de
	call SendSGBPalettePacket
;>             SGBPacketDelay()
	call SGBPacketDelay
	jp .done


.cgb
;=@cgb1
	ld a, b
	ld [wFadeState], a
;=@cgb2
	ld hl, far_StartCGBFade
	rst $10
	jp .done


.dmg
;> else:                                  # Game Boy
;>     if not wFadeType & 0x80:           # white
	ld a, [wFadeType]
	bit 7, a
	jr nz, .dmgBlack

;>         if not state & 0x80:           # fade out
	bit 7, b
	jr nz, .whiteIn

;>             wFadeState = state
	ld a, b
	ld [wFadeState], a
;>             wFadePalettes[0] = wBGP
	ld hl, wFadePalettes
	ld a, [wBGP]
	ld [hli], a
;>             wFadePalettes[1] = wOBP0
	ld a, [wOBP0]
	ld [hli], a
;>             wFadePalettes[2] = wOBP1
	ld a, [wOBP1]
	ld [hl], a
;>             wFadeLevel = 0
	ld a, $00
	ld [wFadeLevel], a
;>             wFadeSpeed = u8(wFadeState + 2)
	ld a, [wFadeState]
	add $02
	ld [wFadeSpeed], a
;>             wFadeTimer = wFadeSpeed
	ld [wFadeTimer], a
;>             StartMusicFadeOut()
	call StartMusicFadeOut
	jr .done

.whiteIn
;>         else:                          # fade in
;>             wFadeState = state
	ld a, b
	ld [wFadeState], a
;>             wFadeLevel = 4
	ld a, $04
	ld [wFadeLevel], a
;>             wFadeSpeed = u8(~wFadeState + 2)
	ld a, [wFadeState]
	cpl
	add $02
	ld [wFadeSpeed], a
;>             wFadeTimer = wFadeSpeed
	ld [wFadeTimer], a
;>             wBGP = 0                   # all white
	ld a, $00
	ld hl, wBGP
	ld [hli], a
;>             wOBP0 = 0
	ld [hli], a
;>             wOBP1 = 0
	ld [hl], a
	jp .done


.dmgBlack
;>     else:                              # black
;>         if not state & 0x80:
	bit 7, b
	jr nz, .blackIn

;>             wFadeState = state
	ld a, b
	ld [wFadeState], a
;>             wFadePalettes[0] = wBGP
	ld hl, wFadePalettes
	ld a, [wBGP]
	ld [hli], a
;>             wFadePalettes[1] = wOBP0
	ld a, [wOBP0]
	ld [hli], a
;>             wFadePalettes[2] = wOBP1
	ld a, [wOBP1]
	ld [hl], a
;>             wFadeLevel = 0
	ld a, $00
	ld [wFadeLevel], a
;>             wFadeSpeed = u8(wFadeState + 2)
	ld a, [wFadeState]
	add $02
	ld [wFadeSpeed], a
;>             wFadeTimer = wFadeSpeed
	ld [wFadeTimer], a
;>             StartMusicFadeOut()
	call StartMusicFadeOut
	jr .done

.blackIn
;>         else:
;>             wFadeState = state
	ld a, b
	ld [wFadeState], a
;>             wFadeLevel = 4
	ld a, $04
	ld [wFadeLevel], a
;>             wFadeSpeed = u8(~wFadeState + 2)
	ld a, [wFadeState]
	cpl
	add $02
	ld [wFadeSpeed], a
;>             wFadeTimer = wFadeSpeed
	ld [wFadeTimer], a
;>             wBGP = 0xFF                # all black
	ld a, $ff
	ld hl, wBGP
	ld [hli], a
;>             wOBP0 = 0xFF
	ld [hli], a
;>             wOBP1 = 0xFF
	ld [hl], a

.done
	ret


	db $29, $29, $29, $01, $00, $88, $09, $0e, $08, $2a, $12, $13, $0d, $20, $fa, $c9

;@ def UpdateFade()
;@ path: gfx/fade
;@ One frame of the palette fade (from the VBlank handler): every wFadeSpeed
;@ frames the fade level moves one step and the palettes are recomputed. On a
;@ Super Game Boy the level goes 0 -> 31 (out) or 32 -> 0 (in) in steps of 5;
;@ the Game Boy and Game Boy Color versions are UpdateFadeDMG / UpdateFadeCGB.
;@ During a fade-out UpdateMusicFadeOut runs too.
;@ test: skip talks to the Super Game Boy and calls routines in other banks
UpdateFade::
;> if not wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret z

;> if not wFadeState & 0x80:
;>     UpdateMusicFadeOut()
	bit 7, a
	call z, UpdateMusicFadeOut
;> if wOnCGB:
;>     return UpdateFadeCGB()
	ld a, [wOnCGB]
	or a
	jp nz, UpdateFadeCGB

;> if not wOnSGB:
;>     return UpdateFadeDMG()
	ld a, [wOnSGB]
	or a
	jp z, UpdateFadeDMG

;> if not wFadeState & 0x80:              # fade out
	ld a, [wFadeState]
	bit 7, a
	jr nz, .in

;>     if wFadeTimer:
	ld a, [wFadeTimer]
	or a
	jr z, .outStep

;>         wFadeTimer -= 1
;>         return
	dec a
	ld [wFadeTimer], a
	ret


.outStep
;>     wFadeLevel = min(wFadeLevel + 5, 31)
	ld a, [wFadeLevel]
	add $05
	cp $1f
	jr c, .outSet

	ld a, $1f

.outSet
	ld [wFadeLevel], a
;>     FadeSGBPalettes()
	call FadeSGBPalettes
;>     wFadeTimer = wFadeSpeed
	ld a, [wFadeSpeed]
	ld [wFadeTimer], a
;>     if wFadeLevel == 31:
;>         return EndFade()
	ld a, [wFadeLevel]
	cp $1f
	jp z, EndFade

	ret


.in
;> else:                                  # fade in
;>     if wFadeTimer:
	ld a, [wFadeTimer]
	or a
	jr z, .inStep

;>         wFadeTimer -= 1
;>         return
	dec a
	ld [wFadeTimer], a
	ret


.inStep
;>     wFadeLevel = max(wFadeLevel - 5, 0)
	ld a, [wFadeLevel]
	sub $05
	bit 7, a
	jr z, .inSet

	xor a

.inSet
	ld [wFadeLevel], a
;>     FadeSGBPalettes()
	call FadeSGBPalettes
;>     wFadeTimer = wFadeSpeed
	ld a, [wFadeSpeed]
	ld [wFadeTimer], a
;>     if wFadeLevel == 0:
;>         return EndFade()
	ld a, [wFadeLevel]
	or a
	jp z, EndFade

	ret


;@ def FadeSGBPalettes()
;@ path: gfx/fade
;@ Recomputes the SGB palettes chosen by wFadeSGBMask at the current fade level
;@ and sends them: palettes 0 and 1 (PAL01 packet), and with mask bit 4 also
;@ palettes 2 and 3 (PAL23). It runs on into SendSGBPalettePacket for the second.
;@ test: skip talks to the Super Game Boy
FadeSGBPalettes::
;> if wFadeSGBMask & 0x01:
;>     wFadeColorOffset = 0x00            # palette 0
	ld a, [wFadeSGBMask]
	bit 0, a
	ld a, $00
	ld [wFadeColorOffset], a
;>     FadePaletteColors()
	call nz, FadePaletteColors
;> if wFadeSGBMask & 0x02:
;>     wFadeColorOffset = 0x08            # palette 1
	ld a, [wFadeSGBMask]
	bit 1, a
	ld a, $08
	ld [wFadeColorOffset], a
;>     FadePaletteColors()
	call nz, FadePaletteColors
;> if wFadeSGBMask & 0x10:
	ld a, [wFadeSGBMask]
	bit 4, a
	jr z, .send

;>     if wFadeSGBMask & 0x04:
;>         wFadeColorOffset = 0x10        # palette 2
	ld a, [wFadeSGBMask]
	bit 2, a
	ld a, $10
	ld [wFadeColorOffset], a
;>         FadePaletteColors()
	call nz, FadePaletteColors
;>     if wFadeSGBMask & 0x08:
;>         wFadeColorOffset = 0x18        # palette 3
	ld a, [wFadeSGBMask]
	bit 3, a
	ld a, $18
	ld [wFadeColorOffset], a
;>         FadePaletteColors()
	call nz, FadePaletteColors

.send
;> ClearSGBPacket()
	call ClearSGBPacket
;> wSGBPacket[0] = 0x01                   # PAL01
	ld hl, wSGBPalettes
	ld de, wSGBPacket
	ld a, $01
	ld [de], a
;> SendSGBPalettePacket(wSGBPalettes, wSGBPacket + 1)
	inc de
	call SendSGBPalettePacket
;> if not wFadeSGBMask & 0x10:
;>     return
	ld a, [wFadeSGBMask]
	bit 4, a
	ret z

;> SGBPacketDelay()
	call SGBPacketDelay
;> ClearSGBPacket()
	call ClearSGBPacket
;> wSGBPacket[0] = 0x09                   # PAL23
	ld hl, wSGBPalettes + 16
	ld de, wSGBPacket
	ld a, $09
	ld [de], a
;> return SendSGBPalettePacket(wSGBPalettes + 16, wSGBPacket + 1)   # (runs on into it)
	inc de

;@ def SendSGBPalettePacket(src: hl, dest: de)
;@ path: system/sgb
;@ Completes an SGB palette packet (PAL01 or PAL23) whose command byte is
;@ already in place: copies the four colours of the first palette at `src`
;@ and colours 1-3 of the second (colour 0 is shared), then sends wSGBPacket.
;@ test: skip talks to the Super Game Boy
SendSGBPalettePacket::
;>@c1 copy(dest, src, 8)                  # first palette, colours 0-3
	ld c, $08

.first
	ld a, [hli]
	ld [de], a
	inc de
;=@c1
	dec c
	jr nz, .first

;>@c2 copy(dest + 8, src + 10, 6)         # second palette, colours 1-3
	inc hl
	inc hl
	ld c, $06

.second
	ld a, [hli]
	ld [de], a
;=@c2
	inc de
	dec c
	jr nz, .second

;> wSGBPacketID = 0xFF                    # send the packet in wSGBPacket
	ld a, $ff
	ld [wSGBPacketID], a
;> SendSGBPacket()
	ld hl, far_SendSGBPacket
	rst $10
	ret


;@ def FadePaletteColors()
;@ path: gfx/fade
;@ Fades the four colours of one SGB palette, from wFadeColorOffset on.
;@ test: skip runs on into FadeNextColor
FadePaletteColors::
;> FadeColor()
	call FadeColor
;> FadeNextColor()
	call FadeNextColor
;> FadeNextColor()
	call FadeNextColor
;> # (and once more by running on into FadeNextColor)

;@ def FadeNextColor()
;@ path: gfx/fade
;@ Moves on to the next colour and fades it (runs on into FadeColor).
;@ test: skip runs on into FadeColor
FadeNextColor::
;> wFadeColorOffset += 2
	ld a, [wFadeColorOffset]
	add $02
	ld [wFadeColorOffset], a

;@ def FadeColor()
;@ path: gfx/fade
;@ Fades one SGB colour (RGB555, offset wFadeColorOffset): each 5-bit part of
;@ the target colour goes through FadeComponent; the result is stored in
;@ wSGBPalettes.
FadeColor::
;>@col color = mem16[wSGBPalettesTarget + wFadeColorOffset]
	ld hl, wSGBPalettesTarget
	ld a, [wFadeColorOffset]
	add l
	ld l, a
	ld a, $00
	adc h
;=@col
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
;> red = FadeComponent(color & 0x1F, wFadeLevel)
	push de
	ld hl, $0000
	ld a, [wFadeLevel]
	ld b, a
	ld a, e
	call FadeComponent
;> result = red
	ld l, a
;>@g green = FadeComponent((color >> 5) & 0x1F, wFadeLevel)
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
;=@g
	ld a, d
	call FadeComponent
;>@gr result += green << 5
	ld d, a
	ld e, $00
	srl d
	rr e
	srl d
	rr e
;=@gr
	srl d
	rr e
	add hl, de
;> blue = FadeComponent((color >> 10) & 0x1F, wFadeLevel)
	pop de
	ld a, d
	srl a
	srl a
	call FadeComponent
;> result += blue << 10
	sla a
	sla a
	add h
	ld h, a
;>@st mem16[wSGBPalettes + wFadeColorOffset] = result
	push hl
	pop de
	ld hl, wSGBPalettes
	ld b, $00
	ld a, [wFadeColorOffset]
	ld c, a
;=@st
	add hl, bc
	ld [hl], e
	inc hl
	ld [hl], d
	ret


;@ def FadeComponent(value: a, level: b) -> a
;@ path: gfx/fade
;@ One 5-bit colour part at fade level `level`: towards white (31) or, when
;@ wFadeType bit 7 is set, towards black (0).
FadeComponent::
;> if not wFadeType & 0x80:
	push af
	ld a, [wFadeType]
	ld c, a
	pop af
	bit 7, c
	jr nz, .black

;>     return min((value & 0x1F) + level, 31)
	and $1f
	add b
	cp $1f
	jr c, .done

	ld a, $1f
	jr .done

.black
;> else:
;>     return max((value & 0x1F) - level, 0)
	and $1f
	sub b
	jr nc, .done

	xor a

.done
	ret


;@ def UpdateFadeCGB()
;@ path: gfx/fade
;@ Game Boy Color fade step: entry 5 of bank $17.
;@ test: skip calls a routine in another bank
UpdateFadeCGB::
;> far_call(0x17, 0x05)
	ld hl, $1705
	rst $10
	ret


;@ def UpdateFadeDMG()
;@ path: gfx/fade
;@ Game Boy fade step: every wFadeSpeed frames the level moves one step (out:
;@ 0 -> 4, in: 4 -> -1) and the palettes in wFadeType are recomputed from
;@ wFadePalettes. Fades to black are UpdateFadeDMGBlack.
UpdateFadeDMG::
;> if wFadeType & 0x80:
;>     return UpdateFadeDMGBlack()
	ld a, [wFadeType]
	bit 7, a
	jp nz, UpdateFadeDMGBlack

;> if not wFadeState & 0x80:              # fade out
	ld a, [wFadeState]
	bit 7, a
	jr nz, .in

;>     if wFadeTimer:
	ld a, [wFadeTimer]
	or a
	jr z, .outStep

;>         wFadeTimer -= 1
;>         return
	dec a
	ld [wFadeTimer], a
	ret


.outStep
;>     FadeDMGToWhite()
	call FadeDMGToWhite
;>     wFadeTimer = wFadeSpeed
	ld a, [wFadeSpeed]
	ld [wFadeTimer], a
;>     wFadeLevel += 1
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a
;>     if wFadeLevel == 4:
;>         return EndFade()
	cp $04
	jp z, EndFade

	ret


.in
;> else:                                  # fade in
;>     if wFadeTimer:
	ld a, [wFadeTimer]
	or a
	jr z, .inStep

;>         wFadeTimer -= 1
;>         return
	dec a
	ld [wFadeTimer], a
	ret


.inStep
;>     FadeDMGToWhite()
	call FadeDMGToWhite
;>     wFadeTimer = wFadeSpeed
	ld a, [wFadeSpeed]
	ld [wFadeTimer], a
;>     wFadeLevel = u8(wFadeLevel - 1)
	ld a, [wFadeLevel]
	dec a
	ld [wFadeLevel], a
;>     if wFadeLevel == 0xFF:
;>         return EndFade()
	cp $ff
	jp z, EndFade

	ret


;@ def FadeDMGToWhite()
;@ path: gfx/fade
;@ Sets wBGP / wOBP0 / wOBP1 (those chosen by wFadeType bits 0-2) to their
;@ wFadePalettes value lightened by wFadeLevel shades.
FadeDMGToWhite::
;> if wFadeType & 0x01:
;>     FadeDMGPaletteToWhite(wFadePalettes[0], wBGP)
	ld a, [wFadeType]
	bit 0, a
	ld a, [wFadePalettes]
	ld hl, wBGP
	call nz, FadeDMGPaletteToWhite
;> if wFadeType & 0x02:
;>     FadeDMGPaletteToWhite(wFadePalettes[1], wOBP0)
	ld a, [wFadeType]
	bit 1, a
	ld a, [wFadePalettes + 1]
	inc hl
	call nz, FadeDMGPaletteToWhite
;> if wFadeType & 0x04:
;>     FadeDMGPaletteToWhite(wFadePalettes[2], wOBP1)
	ld a, [wFadeType]
	bit 2, a
	ld a, [wFadePalettes + 2]
	inc hl
	jr nz, FadeDMGPaletteToWhite

	ret


;@ def FadeDMGPaletteToWhite(palette: a, dest: hl)
;@ path: gfx/fade
;@ Writes `palette` with each of its four 2-bit shades lowered by wFadeLevel
;@ (not below 0, white) to `dest`.
FadeDMGPaletteToWhite::
;> level = wFadeLevel
	ld d, a
	ld a, [wFadeLevel]
	ld b, a
;> out = 0
	ld c, $00
;> out = FadeDMGShadeToWhite(palette, level, out)   # shade 0 ...
	ld a, d
	call FadeDMGShadeToWhite
;>@sh for _ in range(3):                  # ... and shades 1-3
;>     out = FadeDMGShadeToWhiteNext(...)
	call FadeDMGShadeToWhiteNext
;=@sh
	call FadeDMGShadeToWhiteNext
;=@sh
	call FadeDMGShadeToWhiteNext
;> mem[dest] = out
	ld [hl], c
	ret


;@ def FadeDMGShadeToWhiteNext(palette: d, level: b, out: c) -> c
;@ path: gfx/fade
;@ Rotates the palette to its next shade and fades it (runs on into
;@ FadeDMGShadeToWhite).
;@ test: skip runs on into FadeDMGShadeToWhite
FadeDMGShadeToWhiteNext::
;> palette = rotate_right(palette, 2)
	rrc d
	rrc d
	ld a, d

;@ def FadeDMGShadeToWhite(shade: a, level: b, out: c) -> c
;@ path: gfx/fade
;@ Adds the low 2-bit shade of `shade`, lowered by `level` (not below 0), on
;@ top of `out`, which rotates right by 2 so that after four shades they are
;@ back in their places.
FadeDMGShadeToWhite::
;> value = max((shade & 3) - level, 0)
	and $03
	sub b
	jr nc, .put

	xor a

.put
;> out = rotate_right(out | value, 2)
	or c
	ld c, a
	rrc c
	rrc c
	ret


;@ def UpdateFadeDMGBlack()
;@ path: gfx/fade
;@ UpdateFadeDMG for fades to and from black.
UpdateFadeDMGBlack::
;> if not wFadeState & 0x80:              # fade out
	ld a, [wFadeState]
	bit 7, a
	jr nz, .in

;>     if wFadeTimer:
	ld a, [wFadeTimer]
	or a
	jr z, .outStep

;>         wFadeTimer -= 1
;>         return
	dec a
	ld [wFadeTimer], a
	ret


.outStep
;>     FadeDMGToBlack()
	call FadeDMGToBlack
;>     wFadeTimer = wFadeSpeed
	ld a, [wFadeSpeed]
	ld [wFadeTimer], a
;>     wFadeLevel += 1
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a
;>     if wFadeLevel == 4:
;>         return EndFade()
	cp $04
	jp z, EndFade

	ret


.in
;> else:
;>     if wFadeTimer:
	ld a, [wFadeTimer]
	or a
	jr z, .inStep

;>         wFadeTimer -= 1
;>         return
	dec a
	ld [wFadeTimer], a
	ret


.inStep
;>     FadeDMGToBlack()
	call FadeDMGToBlack
;>     wFadeTimer = wFadeSpeed
	ld a, [wFadeSpeed]
	ld [wFadeTimer], a
;>     wFadeLevel = u8(wFadeLevel - 1)
	ld a, [wFadeLevel]
	dec a
	ld [wFadeLevel], a
;>     if wFadeLevel == 0xFF:
;>         return EndFade()
	cp $ff
	jr z, EndFade

	ret


;@ def FadeDMGToBlack()
;@ path: gfx/fade
;@ Sets wBGP / wOBP0 / wOBP1 (those chosen by wFadeType bits 0-2) to their
;@ wFadePalettes value darkened by wFadeLevel shades.
FadeDMGToBlack::
;> if wFadeType & 0x01:
;>     FadeDMGPaletteToBlack(wFadePalettes[0], wBGP)
	ld a, [wFadeType]
	bit 0, a
	ld a, [wFadePalettes]
	ld hl, wBGP
	call nz, FadeDMGPaletteToBlack
;> if wFadeType & 0x02:
;>     FadeDMGPaletteToBlack(wFadePalettes[1], wOBP0)
	ld a, [wFadeType]
	bit 1, a
	ld a, [wFadePalettes + 1]
	inc hl
	call nz, FadeDMGPaletteToBlack
;> if wFadeType & 0x04:
;>     FadeDMGPaletteToBlack(wFadePalettes[2], wOBP1)
	ld a, [wFadeType]
	bit 2, a
	ld a, [wFadePalettes + 2]
	inc hl
	jr nz, FadeDMGPaletteToBlack

	ret


;@ def FadeDMGPaletteToBlack(palette: a, dest: hl)
;@ path: gfx/fade
;@ Writes `palette` with each of its four 2-bit shades raised by wFadeLevel
;@ (not above 3, black) to `dest`.
FadeDMGPaletteToBlack::
;> level = wFadeLevel
	ld d, a
	ld a, [wFadeLevel]
	ld b, a
;> out = 0
	ld c, $00
;> out = FadeDMGShadeToBlack(palette, level, out)   # shade 0 ...
	ld a, d
	call FadeDMGShadeToBlack
;>@sh for _ in range(3):                  # ... and shades 1-3
;>     out = FadeDMGShadeToBlackNext(...)
	call FadeDMGShadeToBlackNext
;=@sh
	call FadeDMGShadeToBlackNext
;=@sh
	call FadeDMGShadeToBlackNext
;> mem[dest] = out
	ld [hl], c
	ret


;@ def FadeDMGShadeToBlackNext(palette: d, level: b, out: c) -> c
;@ path: gfx/fade
;@ Rotates the palette to its next shade and fades it (runs on into
;@ FadeDMGShadeToBlack).
;@ test: skip runs on into FadeDMGShadeToBlack
FadeDMGShadeToBlackNext::
;> palette = rotate_right(palette, 2)
	rrc d
	rrc d
	ld a, d

;@ def FadeDMGShadeToBlack(shade: a, level: b, out: c) -> c
;@ path: gfx/fade
;@ Adds the low 2-bit shade of `shade`, raised by `level` (not above 3), on top
;@ of `out`, which rotates right by 2.
FadeDMGShadeToBlack::
;> value = min((shade & 3) + level, 3)
	and $03
	add b
	cp $03
	jr c, .put

	ld a, $03

.put
;> out = rotate_right(out | value, 2)
	or c
	ld c, a
	rrc c
	rrc c
	ret


;@ def EndFade()
;@ path: gfx/fade
;@ Marks the palette fade as finished.
EndFade::
;> wFadeState = 0
	xor a
	ld [wFadeState], a
	ret


;@ def WaitVRAMAccess()
;@ path: system/lcd
;@ Waits until the LCD is in HBlank or VBlank, when VRAM can be accessed.
;@ test: skip polls the LCD
WaitVRAMAccess::
;> while rSTAT & 0x02:
;>     wait_hblank()
	ldh a, [rSTAT]
	bit 1, a
	ret z

	jr WaitVRAMAccess

;@ def WriteVRAM(value: a, addr: hl)
;@ path: system/lcd
;@ Writes `value` to VRAM at `addr` as soon as VRAM is accessible (interrupts
;@ off meanwhile, so the moment is not missed).
;@ test: skip polls the LCD
WriteVRAM::
;> disable_interrupts()
	push af
	di

.wait
;> while rSTAT & 0x02:
;>     wait_hblank()
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .wait

;> mem[addr] = value
	pop af
	ld [hl], a
;> enable_interrupts()
	ei
	ret


;@ def WriteVRAMInc(value: a, addr: hl) -> hl
;@ path: system/lcd
;@ WriteVRAM, returning the next address.
;@ test: skip polls the LCD
WriteVRAMInc::
;> disable_interrupts()
	push af
	di

.wait
;> while rSTAT & 0x02:
;>     wait_hblank()
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .wait

;> mem[addr] = value
	pop af
	ld [hli], a
;> enable_interrupts()
	ei
;> return addr + 1
	ret


;@ def WriteVRAMAttr(value: a, addr: hl)
;@ path: system/lcd
;@ On a Game Boy Color, writes the BG map attribute `value` (VRAM bank 1) at
;@ `addr` once VRAM is accessible; does nothing on other models.
;@ test: skip polls the LCD
WriteVRAMAttr::
;> if not wOnCGB:
;>     return
	push af
	ld a, [wOnCGB]
	or a
	jr nz, .cgb

	pop af
	ret


.cgb
;> disable_interrupts()
	di

.wait
;> while rSTAT & 0x02:
;>     wait_hblank()
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .wait

;> rVBK = 1
	ld a, $01
	ldh [rVBK], a
;> mem[addr] = value
	pop af
	ld [hl], a
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
;> enable_interrupts()
	ei
	ret


;@ def QueueMusic(song: a)
;@ path: sound/queue
;@ Asks for song `song` to start in the next VBlank (PlayQueuedSounds).
QueueMusic::
;> wQueuedMusic = song
	ld [wQueuedMusic], a
	ret


;@ def PlayMusic(song: a)
;@ path: sound/queue
;@ Stops all sound and starts song `song` (0 = silence). The sound engine has
;@ entry points that start a song on a different number of passes through
;@ StartSoundChannel: song $27 uses StartSounds4, songs $3A, $3F, $47, $49, $4B, $4D, $4F,
;@ $5D and $9D use StartSounds2, all others StartSounds3.
;@ test: skip runs the sound engine
PlayMusic::
;> wMusic = song
	ld [wMusic], a
;> disable_interrupts()
	di
;> InitSound()                            # stop all sound
	call InitSound
;> if song:
	ld a, [wMusic]
	or a
	jr z, .done

;>     wSoundID = song
	ld [wSoundID], a
;>     if song == 0x27:
	cp $27
	jr z, .s27

;>@a         StartSounds4()
;>@b     elif song in (0x3A, 0x3F, 0x47, 0x49, 0x4B, 0x4D, 0x4F, 0x5D, 0x9D):
	cp $3a
	jr z, .short

	cp $3f
	jr z, .short

	cp $47
	jr z, .short

;=@b
	cp $49
	jr z, .short

	cp $4b
	jr z, .short

	cp $4d
	jr z, .short

;=@b
	cp $4f
	jr z, .short

	cp $5d
	jr z, .short

	cp $9d
	jr z, .short

;>@c         StartSounds2()
;>     else:
;>         StartSounds3()
	call StartSounds3
;>@ei enable_interrupts()
	ei
	ret


.s27
;=@a
	call StartSounds4
;=@ei
	ei
	ret


.short
;=@c
	call StartSounds2

.done
;=@ei
	ei
	ret


;@ def QueueSound(id: a)
;@ path: sound/queue
;@ Asks for sound effect `id` to start in the next VBlank (PlayQueuedSounds).
QueueSound::
;> wQueuedSound = id
	ld [wQueuedSound], a
	ret


;@ def PlaySound(id: a)
;@ path: sound/queue
;@ Starts sound effect `id` without stopping the music. Like PlayMusic it picks
;@ the engine entry by number: $3F, $47, $49, $4B, $4D, $4F, $57, $5D, $63,
;@ $69, $74, $76, $78, $7C, $86, $8A, $90, $97, $99, $9D use StartSounds2; $41,
;@ $44, $61 use StartSounds3; all others StartSoundChannel. Keeps all registers.
;@ test: skip runs the sound engine
PlaySound::
;> wSoundID = id                          # (all registers are kept)
	push af
	push bc
	push de
	push hl
	ld [wSoundID], a
;>@k kind = (2 if id in (0x3F, 0x47, 0x49, 0x4B, 0x4D, 0x4F, 0x57, 0x5D, 0x63, 0x69, 0x74, 0x76, 0x78, 0x7C, 0x86, 0x8A, 0x90, 0x97, 0x99, 0x9D) else 3 if id in (0x41, 0x44, 0x61) else 1)
	cp $3f
	jr z, .two

	cp $41
	jr z, .three

	cp $44
	jr z, .three

;=@k
	cp $47
	jr z, .two

	cp $49
	jr z, .two

	cp $4b
	jr z, .two

;=@k
	cp $4d
	jr z, .two

	cp $4f
	jr z, .two

	cp $57
	jr z, .two

;=@k
	cp $5d
	jr z, .two

	cp $63
	jr z, .two

	cp $61
	jr z, .three

;=@k
	cp $69
	jr z, .two

	cp $74
	jr z, .two

	cp $76
	jr z, .two

;=@k
	cp $78
	jr z, .two

	cp $7c
	jr z, .two

	cp $86
	jr z, .two

;=@k
	cp $8a
	jr z, .two

	cp $90
	jr z, .two

	cp $97
	jr z, .two

;=@k
	cp $99
	jr z, .two

	cp $9d
	jr z, .two

;> if kind == 1:
;>     disable_interrupts()
	di
;>     StartSoundChannel()
	call StartSoundChannel
;>     enable_interrupts()
	ei
;>     return
	pop hl
	pop de
	pop bc
	pop af
	ret


.two
;> elif kind == 2:
;>     disable_interrupts()
	di
;>     StartSounds2()
	call StartSounds2
;>     enable_interrupts()
	ei
;>     return
	pop hl
	pop de
	pop bc
	pop af
	ret


.three
;> else:
;>     disable_interrupts()
	di
;>     StartSounds3()
	call StartSounds3
;>     enable_interrupts()
	ei
;>     return
	pop hl
	pop de
	pop bc
	pop af
	ret


;@ def PlayQueuedSounds()
;@ path: sound/queue
;@ VBlank: starts the queued song (song $9D is ignored here) and the queued
;@ sound effect, then empties the queue. The byte after it is an unused `ret`.
;@ test: skip runs the sound engine
PlayQueuedSounds::
;> if wQueuedMusic not in (0xFF, 0x9D):
	ld a, [wQueuedMusic]
	cp $ff
	jr z, .sound

	cp $9d
	jr z, .sound

;>     PlayMusic(wQueuedMusic)
	call PlayMusic
;>     wQueuedMusic = 0xFF
	ld a, $ff
	ld [wQueuedMusic], a

.sound
;> if wQueuedSound != 0xFF:
	ld a, [wQueuedSound]
	cp $ff
	jr z, .done

;>     PlaySound(wQueuedSound)
	call PlaySound
;>     wQueuedSound = 0xFF
	ld a, $ff
	ld [wQueuedSound], a

.done
	ret


	db $c9

StartMusicFadeOut::
	ld b, a
	ld a, [wMapLoadState]
	or a
	jr nz, jr_000_1c13

	ld a, b
	bit 7, a
	jr nz, jr_000_1c13

	or a
	jr z, jr_000_1c13

	ld [wMusicFadeDelay], a
	ld a, [wOnSGB]
	or a
	jr nz, jr_000_1bf5

	ld a, [wMusicFadeDelay]
	sra a
	ld [wMusicFadeDelay], a

jr_000_1bf5:
	ldh a, [rNR50]
	bit 7, a
	jr nz, jr_000_1c13

	bit 3, a
	jr nz, jr_000_1c13

	or a
	jr z, jr_000_1c13

	ld a, [wMusicFadeDelay]
	ld [wMusicFadeTimer], a
	ld a, $08
	ld [wMusicFadeSteps], a
	ldh a, [rNR50]
	ld [wMusicFadeVolume], a
	ret


jr_000_1c13:
	xor a
	ld [wMusicFadeDelay], a
	ret


UpdateMusicFadeOut::
	ld a, [wMapLoadState]
	or a
	jr nz, jr_000_1c84

	ld a, [wMusicFadeDelay]
	bit 7, a
	jr nz, jr_000_1c84

	or a
	ret z

	ld a, [wMusicFadeTimer]
	or a
	jr z, jr_000_1c32

	dec a
	ld [wMusicFadeTimer], a
	ret


jr_000_1c32:
	ldh a, [rNR50]
	and $88
	cp $88
	jr z, jr_000_1c84

	ld a, [wMusicFadeVolume]
	or a
	jr z, jr_000_1c84

	ld b, a
	and $0f
	ld d, a
	ld a, b
	swap a
	and $0f
	ld c, a
	bit 3, c
	jr nz, jr_000_1c53

	ld a, c
	or a
	jr z, jr_000_1c53

	dec c

jr_000_1c53:
	bit 3, d
	jr nz, jr_000_1c5c

	ld a, d
	or a
	jr z, jr_000_1c5c

	dec d

jr_000_1c5c:
	ld a, c
	swap a
	or d
	ldh [rNR50], a
	ld [wMusicFadeVolume], a
	or a
	jr z, jr_000_1c79

	ld a, [wMusicFadeSteps]
	or a
	jr z, jr_000_1c84

	dec a
	ld [wMusicFadeSteps], a
	ld a, [wMusicFadeDelay]
	ld [wMusicFadeTimer], a
	ret


jr_000_1c79:
	ld a, [wLinkActive]
	or a
	jr nz, jr_000_1c84

	di
	call InitSound
	ei

jr_000_1c84:
	xor a
	ld [wMusicFadeDelay], a
	ret


LoadSGBBorder::
	ld hl, wLoadedGfxSet
	cp [hl]
	ret z

	ld [hl], a
	cp $00
	jr nz, jr_000_1cb9

	ld a, $10
	ld de, $0805
	ld bc, $1000
	call SGBTransfer
	call SGBPacketDelay
	ld a, $11
	ld de, $0806
	ld bc, $1000
	call SGBTransfer
	call SGBPacketDelay
	ld a, $0f
	ld de, $0807
	call SGBTransferCompressed
	jr jr_000_1d37

jr_000_1cb9:
	cp $01
	jr nz, jr_000_1ce3

	ld a, $10
	ld de, $0808
	ld bc, $1000
	call SGBTransfer
	call SGBPacketDelay
	ld a, $11
	ld de, $2c00
	ld bc, $1000
	call SGBTransfer
	call SGBPacketDelay
	ld a, $0f
	ld de, $0809
	call SGBTransferCompressed
	jr jr_000_1d37

jr_000_1ce3:
	cp $02
	jr nz, jr_000_1d0d

	ld a, $10
	ld de, $2c01
	ld bc, $1000
	call SGBTransfer
	call SGBPacketDelay
	ld a, $11
	ld de, $3211
	ld bc, $1000
	call SGBTransfer
	call SGBPacketDelay
	ld a, $0f
	ld de, $3212
	call SGBTransferCompressed
	jr jr_000_1d37

jr_000_1d0d:
	cp $03
	jr nz, jr_000_1d37

	ld a, $10
	ld de, $2e24
	ld bc, $1000
	call SGBTransfer
	call SGBPacketDelay
	ld a, $11
	ld de, $2e25
	ld bc, $1000
	call SGBTransfer
	call SGBPacketDelay
	ld a, $0f
	ld de, $3213
	call SGBTransferCompressed
	jr jr_000_1d37

jr_000_1d37:
	ret


	db $78, $ea, $26, $de, $79, $ea, $27, $de, $af, $ea, $28, $de, $c9

CloseLink::
	ld a, [wLinkActive]
	or a
	jr z, jr_000_1d94

	ld a, $08
	call SetInterrupts
	ld a, [wSerialLock]
	set 7, a
	res 6, a
	ld [wSerialLock], a
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_000_1d69

	ld hl, $6000

jr_000_1d64:
	dec hl
	ld a, h
	or l
	jr nz, jr_000_1d64

jr_000_1d69:
	ei
	call LinkSendCloseByte
	call WaitSerialTransfer
	ldh a, [rSB]
	cp $f5
	call nz, LinkSendCloseByte
	di
	ld a, [wSerialLock]
	res 7, a
	ld [wSerialLock], a
	ld a, [wSerialLock]
	res 0, a
	res 1, a
	ld [wSerialLock], a
	ld a, [wLinkFlags]
	bit 1, a
	ld a, $f8
	call nz, SerialSendSlave

jr_000_1d94:
	xor a
	ld [wLinkPhase], a
	ld hl, wJoyHeld
	ld b, $0e

jr_000_1d9d:
	ld [hli], a
	dec b
	jr nz, jr_000_1d9d

	ret


LinkSendCloseByte::
	ld a, [wLinkFlags]
	bit 1, a
	ld a, $f5
	call nz, SerialSendSlave
	ld a, [wLinkFlags]
	bit 1, a
	ld a, $f5
	call z, SerialSendMaster

jr_000_1db6:
	ld a, [wSerialLock]
	bit 6, a
	jr z, jr_000_1db6

	ret


Multiply::
	ld b, $00
	ld h, b
	ld l, b
	call MultiplyNibble

MultiplyNibble::
	rrca
	jr nc, jr_000_1dc9

	add hl, bc

jr_000_1dc9:
	sla c
	rl b
	rrca
	jr nc, jr_000_1dd1

	add hl, bc

jr_000_1dd1:
	sla c
	rl b
	rrca
	jr nc, jr_000_1dd9

	add hl, bc

jr_000_1dd9:
	sla c
	rl b
	rrca
	jr nc, jr_000_1de1

	add hl, bc

jr_000_1de1:
	sla c
	rl b
	ret


Multiply24::
	push af
	push bc
	ld c, b
	call Multiply
	pop bc
	pop af
	push hl
	call Multiply
	pop bc
	ld a, c
	add h
	ld h, a
	ld a, b
	adc $00
	ld e, a
	ret


Divide8::
	ld d, $08
	ld e, a
	xor a

jr_000_1dff:
	sla b
	rla
	jr c, jr_000_1e07

	cp e
	jr c, jr_000_1e09

jr_000_1e07:
	sub e
	inc b

jr_000_1e09:
	dec d
	jr nz, jr_000_1dff

	ret


Divide16::
	ld d, $10
	ld e, a
	xor a

jr_000_1e11:
	add hl, hl
	rla
	jr c, jr_000_1e18

	cp e
	jr c, jr_000_1e1a

jr_000_1e18:
	sub e
	inc l

jr_000_1e1a:
	dec d
	jr nz, jr_000_1e11

	ret


Divide24::
	ld d, $18
	ld b, a
	xor a

jr_000_1e22:
	add hl, hl
	rl e
	rla
	jr c, jr_000_1e2b

	cp b
	jr c, jr_000_1e2d

jr_000_1e2b:
	sub b
	inc l

jr_000_1e2d:
	dec d
	jr nz, jr_000_1e22

	ret


GetCollisionAt::
	ld a, $ff
	ldh [hTestResult], a
	ldh a, [$ffa6]
	bit 7, a
	ret nz

	ldh a, [$ffa8]
	bit 7, a
	ret nz

	ld hl, hMapWidth
	ldh a, [hTestX]
	sub [hl]
	inc hl
	ldh a, [$ffa6]
	sbc [hl]
	ret nc

	ld hl, hMapHeight
	ldh a, [hTestY]
	sub [hl]
	inc hl
	ldh a, [$ffa8]
	sbc [hl]
	ret nc

	ld a, $0f
	ldh [hTestResult], a
	ld a, [wFieldFlags]
	bit 2, a
	ret nz

	ld hl, hScrollX
	ldh a, [hTestX]
	sub [hl]
	ldh [hTestX], a
	ld b, a
	inc hl
	ldh a, [$ffa6]
	sbc [hl]
	ldh [$ffa6], a
	or a
	ret nz

	ld a, b
	cp $a0
	ret nc

	ld hl, hScrollY
	ldh a, [hTestY]
	sub [hl]
	ldh [hTestY], a
	ld b, a
	inc hl
	ldh a, [$ffa8]
	sbc [hl]
	ldh [$ffa8], a
	or a
	ret nz

	ld a, b
	cp $80
	ret nc

	ldh a, [hTestY]
	and $f8
	ld l, a
	ldh a, [$ffa8]
	sla l
	rla
	sla l
	rla
	ld h, a
	ld de, wSavedTilemap
	add hl, de
	ldh a, [$ffa6]
	ld d, a
	ldh a, [hTestX]
	srl d
	rra
	srl d
	rra
	srl d
	rra
	and $1f
	ld e, a
	ld d, $00
	add hl, de
	ld c, [hl]
	ld a, [hl]
	ldh [hTestTile], a
	ld de, $26e3
	ld a, [wOnGateFloor]
	or a
	jr z, jr_000_1ebf

	ld de, $2a63

jr_000_1ebf:
	ld a, [wMapId]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	ld a, c
	ld b, $ff
	cp [hl]
	jr c, jr_000_1ed1

	ld b, $0f

jr_000_1ed1:
	ld a, b
	ldh [hTestResult], a
	ret


SGBAttrBlkBegin::
	ld hl, wSGBPacket
	ld bc, $0020
	xor a
	call FillMemory
	ld a, $20
	ld [wSGBPacket], a
	ld a, $00
	ld [$c778], a
	ld hl, $c779
	ld a, l
	ld [wSGBPacketPtr], a
	ld a, h
	ld [$c776], a
	ret


	db $57, $87, $87, $b2, $87, $87, $b2, $f5, $fa, $75, $c7, $5f, $fa, $76, $c7, $57
	db $3e, $02, $12, $13, $f1, $12, $13, $7c, $12, $13, $7d, $12, $13, $7c, $80, $12
	db $13, $7d, $81, $12, $13, $7b, $ea, $75, $c7, $7a, $ea, $76, $c7, $21, $78, $c7
	db $34, $c9

SGBAttrBlkAdd::
	ld e, a
	add a
	add a
	or e
	add a
	add a
	or e
	push af
	push de
	ld a, [wSGBPacketPtr]
	ld e, a
	ld a, [$c776]
	ld d, a
	pop af
	ld [de], a
	inc de
	pop af
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	ld a, l
	ld [de], a
	inc de
	ld a, h
	add b
	ld [de], a
	inc de
	ld a, l
	add c
	ld [de], a
	inc de
	ld a, e
	ld [wSGBPacketPtr], a
	ld a, d
	ld [$c776], a
	ld hl, $c778
	inc [hl]
	ret


SGBAttrBlkSend::
	ld a, [$c778]
	or a
	ret z

	ld a, [wSGBPacketPtr]
	ld l, a
	ld a, [$c776]
	ld h, a
	ld a, l
	sub $77
	ld l, a
	ld a, h
	sbc $c7
	ld h, a
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	and $07
	add $21
	ld [wSGBPacket], a
	ld a, $ff
	ld [wSGBPacketID], a
	ld hl, far_SendSGBPacket
	rst $10
	ret


PrintNumber7::
	ld a, $0f
	ldh [hDivisorHigh], a
	ld e, $40
	ld d, $42
	call PeekDigit24
	or a
	jp nz, PrintNumber7Zeros

	call DrawBlankTile
	call NextTileColumn

PrintNumber6::
	ld a, $01
	ldh [hDivisorHigh], a
	ld e, $a0
	ld d, $86
	call PeekDigit24
	or a
	jr nz, PrintNumber6Zeros

	call DrawBlankTile
	call NextTileColumn

PrintNumber5::
	ld a, $00
	ldh [hDivisorHigh], a
	ld e, $10
	ld d, $27
	call PeekDigit24
	or a
	jr nz, PrintNumber5Zeros

	call DrawBlankTile
	call NextTileColumn
	ldh a, [hNumber]
	ld c, a
	ldh a, [$ffd6]
	ld b, a
	jp PrintNumber4


PrintNumber7Zeros::
	ld a, $0f
	ldh [hDivisorHigh], a
	ld e, $40
	ld d, $42
	call NextDigit24
	call DrawDigitTile
	call NextTileColumn

PrintNumber6Zeros::
	ld a, $01
	ldh [hDivisorHigh], a
	ld e, $a0
	ld d, $86
	call NextDigit24
	call DrawDigitTile
	call NextTileColumn

PrintNumber5Zeros::
	ld a, $00
	ldh [hDivisorHigh], a
	ld e, $10
	ld d, $27
	call NextDigit24
	call DrawDigitTile
	call NextTileColumn
	ldh a, [hNumber]
	ld c, a
	ldh a, [$ffd6]
	ld b, a
	jp PrintNumber4Zeros


PeekDigit24::
	ldh a, [hNumber]
	ld [wNumberBackup], a
	ldh a, [$ffd6]
	ld [$c0a1], a
	ldh a, [$ffd7]
	ld [$c0a2], a
	call NextDigit24
	push af
	ld a, [wNumberBackup]
	ldh [hNumber], a
	ld a, [$c0a1]
	ldh [$ffd6], a
	ld a, [$c0a2]
	ldh [$ffd7], a
	pop af
	ret


NextDigit24::
	push hl
	ldh a, [hDivisorHigh]
	ld l, a
	ld h, $ff

jr_000_203c:
	inc h
	ldh a, [hNumber]
	sub e
	ldh [hNumber], a
	ldh a, [$ffd6]
	sbc d
	ldh [$ffd6], a
	ldh a, [$ffd7]
	sbc l
	ldh [$ffd7], a
	jr nc, jr_000_203c

	ldh a, [hNumber]
	add e
	ldh [hNumber], a
	ldh a, [$ffd6]
	adc d
	ldh [$ffd6], a
	ldh a, [$ffd7]
	adc l
	ldh [$ffd7], a
	ld a, h
	pop hl
	ret


PrintNumber4::
	ld de, $03e8
	push bc
	call NextDigit16
	pop bc
	or a
	jr nz, jr_000_2095

	call DrawBlankTile
	call NextTileColumn

PrintNumber3::
	ld de, $0064
	push bc
	call NextDigit16
	pop bc
	or a
	jr nz, PrintNumber3Zeros

	call DrawBlankTile
	call NextTileColumn

PrintNumber2::
	ld de, $000a
	push bc
	call NextDigit16
	pop bc
	or a
	jr nz, PrintNumber2Zeros

	call DrawBlankTile
	call NextTileColumn
	jr jr_000_20b9

PrintNumber4Zeros::
jr_000_2095:
	ld de, $03e8
	call NextDigit16
	call DrawDigitTile
	call NextTileColumn

PrintNumber3Zeros::
	ld de, $0064
	call NextDigit16
	call DrawDigitTile
	call NextTileColumn

PrintNumber2Zeros::
	ld de, $000a
	call NextDigit16
	call DrawDigitTile
	call NextTileColumn

jr_000_20b9:
	ld a, c
	call DrawDigitTile
	ret


NextDigit16::
	push hl
	ld h, $ff

jr_000_20c1:
	inc h
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jr nc, jr_000_20c1

	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
	ld a, h
	pop hl
	ret


DrawDigitTile::
	add $f0
	call WriteVRAM
	ret


DrawBlankTile::
	ld a, $e0
	call WriteVRAM
	ret


NextTileColumn::
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	pop af
	ret


ReadSRAMByte::
	di
	ld a, $0a
	ld [$0100], a
	ld a, [hl]
	push af
	ld a, $00
	ld [$0100], a
	pop af
	ei
	ret


WriteSRAMByte::
	di
	push af
	ld a, $0a
	ld [$0100], a
	pop af
	ld [hl], a
	ld a, $00
	ld [$0100], a
	ei
	ret


SRAMChecksum::
	ld a, $0a
	ld [$0100], a
	ld de, $4638

jr_000_2116:
	ld a, [hli]
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, jr_000_2116

	ld a, $00
	ld [$0100], a
	ret


SaveGame::
	ld hl, hPlayerGfx
	ld de, sSavedHRAM
	ld bc, $0021
	call CopyToSRAM
	ld hl, wGameStarted
	ld de, sSavedWRAM
	ld bc, $1100
	call CopyToSRAM
	ld hl, wSavedTilemap
	ld de, sSavedScreenTiles
	ld bc, $0200
	call CopyToSRAM
	ld hl, wScreenMap
	ld de, sSavedScreenMap
	ld bc, $0100
	call CopyToSRAM

FinishSave::
	ld hl, sSaveValid
	ld a, $01
	push af
	ld a, $0a
	ld [$0100], a
	pop af
	ld [hl], a
	ld a, $00
	ld [$0100], a
	ld hl, sSaveValid
	ld bc, $1ffe
	call SRAMChecksum
	ld a, $0a
	ld [$0100], a
	ld hl, sChecksum
	ld [hl], e
	inc hl
	ld [hl], d
	ld a, $00
	ld [$0100], a
	ret


CopyToSRAM::
	ld a, $0a
	ld [$0100], a

jr_000_2189:
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_000_2189

	ld a, $00
	ld [$0100], a
	ret


SaveMonsters::
	ld hl, wMonsters
	ld de, sMonsters
	ld bc, $0ba4
	call CopyToSRAM
	ld hl, wPartyCount
	ld de, sPartyCount
	ld bc, $0007
	call CopyToSRAM
	jp FinishSave


LoadGame::
	ld hl, sSaveValid
	ld a, $0a
	ld [$0100], a
	ld a, [hl]
	push af
	ld a, $00
	ld [$0100], a
	pop af
	or a
	ret z

	ld hl, hPlayerGfx
	ld de, sSavedHRAM
	ld bc, $0021
	call CopyFromSRAM
	ld hl, wGameStarted
	ld de, sSavedWRAM
	ld bc, $1100
	call CopyFromSRAM
	ld hl, wSavedTilemap
	ld de, sSavedScreenTiles
	ld bc, $0200
	call CopyFromSRAM
	ld hl, wScreenMap
	ld de, sSavedScreenMap
	ld bc, $0100
	call CopyFromSRAM
	ret


CopyFromSRAM::
	ld a, $0a
	ld [$0100], a

jr_000_21fa:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_000_21fa

	ld a, $00
	ld [$0100], a
	ret


GetPartySlot::
	push bc
	ld b, a
	ld a, [wLinkActive]
	or a
	jr z, jr_000_221a

	ld a, [wGameMode]
	cp $02
	jr nz, jr_000_221a

	ld a, b
	pop bc
	ret


jr_000_221a:
	ld a, b
	pop bc
	ld hl, wParty
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


PartyMonsterField::
	push af
	push bc
	push de
	push hl
	call GetPartySlot
	ld c, $95
	call Multiply
	pop bc
	add hl, bc
	pop de
	pop bc
	pop af
	ret


MonsterField::
	push bc
	push de
	push hl
	ld c, $95
	and $7f
	call Multiply
	pop bc
	add hl, bc
	pop de
	pop bc
	ret


GetPartyMonsterByte::
	call PartyMonsterField
	ld a, [hl]
	ret


GetPartyMonsterWord::
	call PartyMonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret


	db $c5, $cd, $29, $22, $c1, $71, $c9

SetPartyMonsterWord::
	push bc
	call PartyMonsterField
	pop bc
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


CurMonsterField::
	push af
	push bc
	push de
	push hl
	ld hl, wParty
	ld a, [wCurPartyMember]
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld c, $95
	call Multiply
	pop bc
	add hl, bc
	pop de
	pop bc
	pop af
	ret


GetCurMonsterByte::
	call CurMonsterField
	ld a, [hl]
	ret


GetCurMonsterWord::
	call CurMonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret


	db $c5, $cd, $66, $22, $c1, $71, $c9, $c5, $cd, $66, $22, $c1, $79, $22, $70, $c9

HealPartyHP::
	push hl
	call GetPartySlot
	pop hl
	push hl
	push af
	ld hl, wMonMaxHP
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	push hl
	ld hl, wMonHP
	call MonsterField
	pop bc
	pop de
	call AddWordCapped
	ret


DamagePartyHP::
	push hl
	call GetPartySlot
	pop hl
	push hl
	ld hl, wMonHP
	call MonsterField
	pop de
	ld bc, $0000
	call SubWordFloored
	ret


RestorePartyMP::
	push hl
	call GetPartySlot
	pop hl
	push hl
	push af
	ld hl, wMonMaxMP
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	push hl
	ld hl, wMonMP
	call MonsterField
	pop bc
	pop de
	call AddWordCapped
	ret


	db $e5, $cd, $08, $22, $e1, $e5, $21, $15, $cb, $cd, $3b, $22, $d1, $01, $00, $00
	db $cd, $96, $24, $c9

RaisePartyAttack::
	call GetPartySlotForRaise

RaiseMonsterAttack::
	ld de, wMonAttack
	ld bc, $03e7
	call RaiseMonsterWord
	ret


	db $cd, $62, $24

LowerMonsterAttack::
	ld de, wMonAttack
	ld bc, $0001
	call LowerMonsterWord
	ret


RaisePartyDefense::
	call GetPartySlotForRaise

RaiseMonsterDefense::
	ld de, wMonDefense
	ld bc, $03e7
	call RaiseMonsterWord
	ret


	db $cd, $62, $24

LowerMonsterDefense::
	ld de, wMonDefense
	ld bc, $0001
	call LowerMonsterWord
	ret


RaisePartyAgility::
	call GetPartySlotForRaise

RaiseMonsterAgility::
	ld de, wMonAgility
	ld bc, $01ff
	call RaiseMonsterWord
	ret


	db $cd, $62, $24

LowerMonsterAgility::
	ld de, wMonAgility
	ld bc, $0001
	call LowerMonsterWord
	ret


RaisePartyIntelligence::
	call GetPartySlotForRaise

RaiseMonsterIntelligence::
	ld de, wMonIntelligence
	ld bc, $00ff
	call RaiseMonsterWord
	ret


	db $cd, $62, $24

LowerMonsterIntelligence::
	ld de, wMonIntelligence
	ld bc, $0001
	call LowerMonsterWord
	ret


	db $cd, $42, $24, $11, $21, $cb, $01, $ff, $00, $cd, $48, $24, $c9

LowerPartyWildness::
	call GetPartySlotForLower
	ld de, wMonWildness
	ld bc, $0000
	call LowerMonsterWord
	ret


RaisePartyStat64::
	call GetPartySlotForRaise
	ld de, wMonStat64
	ld c, $ff
	call RaiseMonsterByte
	ret


LowerPartyStat64::
	call GetPartySlotForLower
	ld de, wMonStat64
	ld c, $00
	call LowerMonsterByte
	ret


RaisePartyStat67::
	call GetPartySlotForRaise
	ld de, wMonStat67
	ld c, $ff
	call RaiseMonsterByte
	ret


LowerPartyStat67::
	call GetPartySlotForLower
	ld de, wMonStat67
	ld c, $00
	call LowerMonsterByte
	ret


	db $cd, $42, $24, $11, $27, $cb, $0e, $ff, $cd, $55, $24, $c9, $cd, $62, $24, $11
	db $27, $cb, $0e, $00, $cd, $75, $24, $c9

RaisePartyStat65::
	call GetPartySlotForRaise
	ld de, wMonStat65
	ld c, $ff
	call RaiseMonsterByte
	ret


LowerPartyStat65::
	call GetPartySlotForLower
	ld de, wMonStat65
	ld c, $00
	call LowerMonsterByte
	ret


RaisePartyMaxHP::
	call GetPartySlotForRaise

RaiseMonsterMaxHP::
	ld de, wMonMaxHP
	ld bc, $03e7
	call RaiseMonsterWord
	ret


	db $cd, $62, $24

LowerMonsterMaxHP::
	ld de, wMonMaxHP
	ld bc, $0001
	call LowerMonsterWord
	ret


RaisePartyMaxMP::
	call GetPartySlotForRaise

RaiseMonsterMaxMP::
	ld de, wMonMaxMP
	ld bc, $03e7
	call RaiseMonsterWord
	ret


	db $cd, $62, $24

LowerMonsterMaxMP::
	ld de, wMonMaxMP
	ld bc, $0001
	call LowerMonsterWord
	ret


AddGold::
	ld c, e
	ld d, h
	ld e, l
	ld hl, wGold
	call AddGoldCapped
	ret


SpendGold::
	ld c, e
	ld d, h
	ld e, l
	ld hl, wGold
	call Sub24Floored
	ret


AddBankGold::
	ld c, e
	ld d, h
	ld e, l
	ld hl, wBankedGold
	call AddBankGoldCapped
	ret


TakeBankGold::
	ld c, e
	ld d, h
	ld e, l
	ld hl, wBankedGold
	call Sub24Floored
	ret


GetPartySlotForRaise::
	push hl
	call GetPartySlot
	pop hl
	ret


RaiseMonsterWord::
	push bc
	push hl
	ld l, e
	ld h, d
	call MonsterField
	pop de
	pop bc
	call AddWordCapped
	ret


RaiseMonsterByte::
	push bc
	push hl
	ld l, e
	ld h, d
	call MonsterField
	pop de
	pop bc
	call AddByteCapped
	ret


GetPartySlotForLower::
	push hl
	call GetPartySlot
	pop hl
	ret


LowerMonsterWord::
	push bc
	push hl
	ld l, e
	ld h, d
	call MonsterField
	pop de
	pop bc
	call SubWordFloored
	ret


LowerMonsterByte::
	push bc
	push hl
	ld l, e
	ld h, d
	call MonsterField
	pop de
	pop bc
	call SubByteFloored
	ret


AddWordCapped::
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	jr c, jr_000_248f

	ld a, l
	sub c
	ld a, h
	sbc b
	jr nc, jr_000_2491

jr_000_248f:
	ld c, l
	ld b, h

jr_000_2491:
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


SubWordFloored::
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	jr c, jr_000_24aa

	ld a, l
	sub c
	ld a, h
	sbc b
	jr c, jr_000_24aa

	ld c, l
	ld b, h

jr_000_24aa:
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


AddByteCapped::
	ld a, [hl]
	add e
	jr c, jr_000_24b6

	cp c
	jr c, jr_000_24b7

jr_000_24b6:
	ld a, c

jr_000_24b7:
	ld [hl], a
	ret


SubByteFloored::
	ld a, [hl]
	sub e
	jr c, jr_000_24c0

	cp c
	jr nc, jr_000_24c1

jr_000_24c0:
	ld a, c

jr_000_24c1:
	ld [hl], a
	ret


AddGoldCapped::
	push hl
	ld a, [hli]
	add e
	ld e, a
	ld a, [hli]
	adc d
	ld d, a
	ld a, [hl]
	adc c
	ld c, a
	ld a, e
	sub $9f
	ld a, d
	sbc $86
	ld a, c
	sbc $01
	jr c, jr_000_24dd

	ld de, $869f
	ld c, $01

jr_000_24dd:
	pop hl
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld [hl], c
	ret


AddBankGoldCapped::
	push hl
	ld a, [hli]
	add e
	ld e, a
	ld a, [hli]
	adc d
	ld d, a
	ld a, [hl]
	adc c
	ld c, a
	ld a, e
	sub $3f
	ld a, d
	sbc $42
	ld a, c
	sbc $0f
	jr c, jr_000_24dd

	ld de, $423f
	ld c, $0f
	jr jr_000_24dd

Sub24Floored::
	push hl
	ld a, [hli]
	sub e
	ld e, a
	ld a, [hli]
	sbc d
	ld d, a
	ld a, [hl]
	sbc c
	ld c, a
	jr nc, jr_000_2511

	ld de, $0000
	ld c, $00

jr_000_2511:
	pop hl
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld [hl], c
	ret


BuildStatusBar::
	ld a, [wPartyCount]
	or a
	jr nz, jr_000_252a

	ld hl, wPartyBarTiles
	ld bc, $0040
	ld a, $dc
	call FillMemory
	ret


jr_000_252a:
	ld hl, wPartyBarTiles
	ld bc, $0040
	ld a, $e0
	call FillMemory
	ld a, [wPartyCount]
	or a
	ret z

	ld hl, wPartyBarTiles
	ld a, $00
	call BuildStatusBarEntry
	ld a, [wPartyCount]
	cp $01
	ret z

	ld hl, $c1c7
	ld a, $01
	call BuildStatusBarEntry
	ld a, [wPartyCount]
	cp $02
	ret z

	ld hl, $c1ce
	ld a, $02
	call BuildStatusBarEntry
	ret


BuildStatusBarEntry::
	ldh [hNumber], a
	ld a, [wStatusBarMode]
	or a
	jr nz, jr_000_25a0

	push hl
	ldh a, [hNumber]
	add $da
	ld [hli], a
	ld a, $e1
	ld [hli], a
	ld a, $e3
	ld [hli], a
	push hl
	ld hl, wMonHP
	ldh a, [hNumber]
	call GetPartyMonsterWord
	pop hl
	call PrintNumber3
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, $e0
	ld [hli], a
	ld a, $e2
	ld [hli], a
	ld a, $e3
	ld [hli], a
	push hl
	ld hl, wMonMP
	ldh a, [hNumber]
	call GetPartyMonsterWord
	pop hl
	call PrintNumber3
	ret


jr_000_25a0:
	push hl
	ldh a, [hNumber]
	add $da
	ld [hli], a
	ld a, $de
	ld [hli], a
	ld a, $df
	ld [hli], a
	ld a, $e4
	ld [hli], a
	push hl
	ld hl, wMonLevel
	ldh a, [hNumber]
	call GetPartyMonsterByte
	pop hl
	ld c, a
	ld b, $00
	call PrintNumber2
	pop hl
	ld a, l
	add $21
	ld l, a
	ld a, h
	adc $00
	ld h, a
	push hl
	ld hl, wMonStatus
	ldh a, [hNumber]
	call GetPartyMonsterByte
	ld b, a
	pop hl
	bit 0, b
	ld a, $e0
	jr z, jr_000_25db

	ld a, $d7

jr_000_25db:
	ld [hli], a
	inc hl
	bit 2, b
	ld a, $e0
	jr z, jr_000_25e5

	ld a, $d8

jr_000_25e5:
	ld [hli], a
	inc hl
	bit 7, b
	ld a, $e0
	jr z, jr_000_25ef

	ld a, $d9

jr_000_25ef:
	ld [hl], a
	ret


DrawStatusBar::
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
	sla l
	rla
	ld h, $98
	add h
	ld h, a
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	and $1f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $02
	ld h, a
	res 2, h
	ld de, wPartyBarTiles
	ld c, $02

jr_000_261d:
	ld b, $14
	push hl

jr_000_2620:
	ld a, [de]
	call WriteVRAM
	ld a, $07
	call WriteVRAMAttr
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	inc de
	dec b
	jr nz, jr_000_2620

	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, jr_000_261d

	ret


IsInGateWorld::
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_000_266c

	ld a, [wMapId]
	cp $5d
	jr z, jr_000_266a

	cp $5e
	jr z, jr_000_266a

	ld a, [wMapId]
	cp $30
	jr nc, jr_000_266c

jr_000_266a:
	xor a
	ret


jr_000_266c:
	ld a, $01
	or a
	ret


SetFlag::
	call FlagMask
	or [hl]
	ld [hl], a
	ret


	db $cd, $83, $26, $ee, $ff, $a6, $77, $c9

TestFlag::
	call FlagMask
	and [hl]
	ret


FlagMask::
	push af
	srl a
	srl a
	srl a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	push hl
	ld hl, $26d5
	and $07
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	ret


SetEventFlag::
	call EventFlagMask
	or [hl]
	ld [hl], a
	ret


ClearEventFlag::
	call EventFlagMask
	xor $ff
	and [hl]
	ld [hl], a
	ret


TestEventFlag::
	call EventFlagMask
	and [hl]
	ret


EventFlagMask::
	push bc
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld hl, wEventFlags
	add hl, bc
	pop bc
	push hl
	ld hl, $26d5
	ld a, c
	and $07
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	ret


BitMasks::
	db $80, $40, $20, $10, $08, $04, $02, $01

MapInfo::
	db $00, $2a, $40, $01, $00, $01, $57, $00
	db $08, $2a, $40, $01, $00, $02, $50, $00, $14, $2a, $e0, $01, $00, $01, $49, $00
	db $21, $2a, $40, $01, $00, $01, $30, $00, $01, $29, $e0, $01, $00, $01, $3a, $00
	db $09, $29, $e0, $01, $80, $00, $50, $00, $0e, $29, $e0, $01, $80, $00, $5a, $00
	db $12, $29, $e0, $01, $00, $01, $52, $00, $1c, $29, $a0, $00, $80, $00, $a2, $00
	db $1f, $29, $40, $01, $00, $01, $18, $00, $23, $29, $40, $01, $80, $00, $18, $00
	db $00, $2a, $40, $01, $00, $01, $57, $00, $26, $29, $a0, $00, $80, $00, $30, $00
	db $00, $30, $a0, $00, $80, $00, $40, $00, $00, $2a, $40, $01, $00, $01, $57, $00
	db $02, $30, $a0, $00, $80, $00, $50, $00, $04, $30, $a0, $00, $80, $00, $38, $00
	db $00, $2a, $40, $01, $00, $01, $57, $00, $07, $30, $a0, $00, $00, $01, $40, $00
	db $0a, $30, $a0, $00, $80, $00, $40, $00, $00, $2a, $40, $01, $00, $01, $57, $00
	db $00, $2a, $40, $01, $00, $01, $57, $00, $0c, $30, $a0, $00, $80, $00, $40, $00
	db $00, $2a, $40, $01, $00, $01, $57, $00, $0f, $30, $a0, $00, $00, $01, $4e, $00
	db $13, $30, $a0, $00, $80, $00, $40, $00, $15, $30, $a0, $00, $80, $00, $40, $00
	db $17, $30, $a0, $00, $80, $00, $50, $00, $19, $30, $a0, $00, $80, $00, $50, $00
	db $1b, $30, $a0, $00, $80, $00, $30, $00, $1d, $30, $a0, $00, $80, $00, $24, $00
	db $00, $2d, $a0, $00, $80, $00, $30, $00, $00, $2a, $40, $01, $00, $01, $57, $00
	db $00, $2a, $40, $01, $00, $01, $57, $00, $00, $2a, $40, $01, $00, $01, $57, $00
	db $02, $2d, $a0, $00, $80, $00, $20, $00, $04, $2d, $a0, $00, $80, $00, $18, $00
	db $06, $2d, $a0, $00, $80, $00, $20, $00, $08, $2d, $a0, $00, $80, $00, $30, $00
	db $0a, $2d, $a0, $00, $80, $00, $10, $00, $0c, $2d, $a0, $00, $80, $00, $30, $00
	db $0e, $2d, $a0, $00, $80, $00, $20, $00, $10, $2d, $a0, $00, $80, $00, $20, $00
	db $12, $2d, $a0, $00, $80, $00, $20, $00, $14, $2d, $a0, $00, $80, $00, $20, $00
	db $16, $2d, $a0, $00, $80, $00, $30, $00, $18, $2d, $a0, $00, $80, $00, $28, $00
	db $1a, $2d, $40, $01, $00, $01, $70, $00, $0c, $26, $a0, $00, $80, $00, $40, $00
	db $0f, $26, $a0, $00, $80, $00, $50, $00, $15, $24, $a0, $00, $80, $00, $20, $00
	db $12, $26, $a0, $00, $80, $00, $40, $00, $15, $26, $a0, $00, $80, $00, $50, $00
	db $18, $26, $a0, $00, $80, $00, $20, $00, $1b, $26, $a0, $00, $80, $00, $50, $00
	db $1a, $25, $a0, $00, $80, $00, $40, $00, $00, $25, $a0, $00, $80, $00, $50, $00
	db $03, $23, $a0, $00, $80, $00, $20, $00, $03, $25, $a0, $00, $80, $00, $40, $00
	db $06, $24, $a0, $00, $80, $00, $50, $00, $06, $23, $a0, $00, $80, $00, $66, $00
	db $06, $25, $a0, $00, $80, $00, $10, $00, $08, $25, $a0, $00, $80, $00, $50, $00
	db $00, $24, $a0, $00, $80, $00, $50, $00, $15, $25, $a0, $00, $80, $00, $40, $00
	db $17, $25, $a0, $00, $80, $00, $40, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $0f, $24, $a0, $00, $80, $00, $40, $00, $18, $24, $a0, $00, $80, $00, $20, $00
	db $09, $24, $a0, $00, $80, $00, $50, $00, $00, $23, $a0, $00, $80, $00, $50, $00
	db $1b, $24, $a0, $00, $80, $00, $65, $00, $0c, $24, $a0, $00, $80, $00, $40, $00
	db $0b, $25, $a0, $00, $80, $00, $50, $00, $0a, $23, $a0, $00, $80, $00, $40, $00
	db $0d, $23, $a0, $00, $80, $00, $14, $00, $10, $23, $a0, $00, $80, $00, $68, $00
	db $0e, $25, $a0, $00, $80, $00, $40, $00, $11, $25, $a0, $00, $00, $01, $55, $00
	db $03, $24, $a0, $00, $80, $00, $60, $00, $00, $26, $a0, $00, $80, $00, $20, $00
	db $02, $26, $a0, $00, $80, $00, $20, $00, $04, $26, $a0, $00, $80, $00, $2b, $00
	db $18, $23, $a0, $00, $80, $00, $30, $00, $00, $37, $e0, $01, $80, $01, $30, $00
	db $0a, $37, $e0, $01, $80, $01, $30, $00, $14, $37, $e0, $01, $80, $01, $30, $00
	db $1e, $37, $e0, $01, $80, $01, $30, $00, $28, $37, $e0, $01, $80, $01, $30, $00
	db $32, $37, $e0, $01, $80, $01, $30, $00, $06, $26, $a0, $00, $80, $00, $37, $00
	db $08, $26, $a0, $00, $80, $00, $37, $00, $0a, $26, $a0, $00, $80, $00, $37, $00
	db $13, $23, $a0, $00, $80, $00, $60, $00, $16, $23, $a0, $00, $80, $00, $00, $00
	db $00, $26, $a0, $00, $80, $00, $20, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $18, $23, $a0, $00, $80, $00, $30, $00, $18, $23, $a0, $00, $80, $00, $30, $00
	db $18, $23, $a0, $00, $80, $00, $30, $00, $18, $23, $a0, $00, $80, $00, $30, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $00, $28, $80, $02, $00, $02, $30, $00
	db $01, $28, $80, $02, $00, $02, $30, $00, $02, $28, $80, $02, $00, $02, $30, $00
	db $03, $28, $80, $02, $00, $02, $30, $00, $04, $28, $80, $02, $00, $02, $30, $00
	db $05, $28, $80, $02, $00, $02, $30, $00, $06, $28, $80, $02, $00, $02, $30, $00
	db $07, $28, $80, $02, $00, $02, $30, $00, $08, $28, $80, $02, $00, $02, $30, $00
	db $09, $28, $80, $02, $00, $02, $30, $00, $0a, $28, $80, $02, $00, $02, $30, $00
	db $0b, $28, $80, $02, $00, $02, $30, $00, $0c, $28, $80, $02, $00, $02, $30, $00
	db $0d, $28, $80, $02, $00, $02, $30, $00, $0e, $28, $80, $02, $00, $02, $30, $00
	db $0f, $28, $80, $02, $00, $02, $30, $00, $00, $00, $00, $31, $01, $31, $02, $31
	db $03, $31, $04, $31, $05, $31, $06, $31, $07, $31, $08, $31, $09, $31, $0a, $31
	db $0b, $31, $0c, $31, $0d, $31, $0e, $31, $0f, $31, $10, $31, $11, $31, $12, $31
	db $13, $31, $14, $31, $15, $31, $16, $31, $17, $31, $18, $31, $19, $31, $1a, $31
	db $1b, $31, $1c, $31, $1d, $31, $1e, $31, $1f, $31, $20, $31, $21, $31, $22, $31
	db $23, $31, $24, $31, $25, $31, $26, $31, $27, $31, $28, $31, $29, $31, $2a, $31
	db $2b, $31, $2c, $31, $2d, $31, $2e, $31, $2f, $31, $30, $31, $31, $31, $32, $31
	db $33, $31, $34, $31, $35, $31, $36, $31, $37, $31, $38, $31, $39, $31, $09, $2f
	db $04, $38, $34, $38, $37, $38, $08, $39, $1e, $39, $2d, $39, $03, $3a, $26, $3a
	db $2a, $3a, $3e, $38, $31, $38, $04, $39, $39, $38, $0b, $3a, $14, $3a, $06, $39
	db $29, $38, $00, $38, $42, $31, $00, $31, $00, $31, $3a, $31, $3b, $31, $3c, $31
	db $3d, $31, $3e, $31, $3f, $31, $40, $31, $41, $31, $3a, $31, $3a, $31, $3a, $31
	db $3a, $31, $3a, $31, $3a, $31, $00, $2f, $19, $2e, $11, $2f, $12, $2f, $13, $2f
	db $14, $2f, $15, $2f, $16, $2f, $17, $2f, $18, $2f, $19, $2f, $1a, $2f, $1b, $2f
	db $1c, $2f, $1d, $2f, $1e, $2f, $1f, $2f, $20, $2f, $21, $2f, $22, $2f, $23, $2f
	db $24, $2f, $25, $2f, $26, $2f, $27, $2f, $28, $2f, $29, $2f, $2a, $2f, $2b, $2f
	db $2c, $2f, $2d, $2f, $2e, $2f, $2f, $2f, $30, $2f, $31, $2f, $32, $2f, $33, $2f
	db $34, $2f, $35, $2f, $36, $2f, $37, $2f, $00, $36, $01, $36, $02, $36, $03, $36
	db $04, $36, $05, $36, $06, $36, $07, $36, $08, $36, $09, $36, $0a, $36, $0b, $36
	db $0c, $36, $0d, $36, $0e, $36, $0f, $36, $10, $36, $11, $36, $12, $36, $13, $36
	db $14, $36, $15, $36, $16, $36, $17, $36, $18, $36, $19, $36, $1a, $36, $1b, $36
	db $1c, $36, $1d, $36, $1e, $36, $1f, $36, $20, $36, $21, $36, $22, $36, $23, $36
	db $24, $36, $25, $36, $26, $36, $27, $36, $00, $35, $01, $35, $02, $35, $03, $35
	db $04, $35, $05, $35, $06, $35, $07, $35, $08, $35, $09, $35, $0a, $35, $0b, $35
	db $0c, $35, $0d, $35, $0e, $35, $0f, $35, $10, $35, $11, $35, $12, $35, $13, $35
	db $14, $35, $15, $35, $16, $35, $17, $35, $18, $35, $19, $35, $1a, $35, $1b, $35
	db $1c, $35, $1d, $35, $1e, $35, $1f, $35, $20, $35, $21, $35, $22, $35, $23, $35
	db $24, $35, $25, $35, $26, $35, $27, $35, $00, $34, $01, $34, $02, $34, $03, $34
	db $04, $34, $05, $34, $06, $34, $07, $34, $08, $34, $09, $34, $0a, $34, $0b, $34
	db $0c, $34, $0d, $34, $0e, $34, $0f, $34, $10, $34, $11, $34, $12, $34, $13, $34
	db $14, $34, $15, $34, $16, $34, $17, $34, $18, $34, $19, $34, $1a, $34, $1b, $34
	db $1c, $34, $1d, $34, $1e, $34, $1f, $34, $20, $34, $21, $34, $22, $34, $23, $34
	db $24, $34, $25, $34, $26, $34, $27, $34, $00, $33, $01, $33, $02, $33, $03, $33
	db $04, $33, $05, $33, $06, $33, $07, $33, $08, $33, $09, $33, $0a, $33, $0b, $33
	db $0c, $33, $0d, $33, $0e, $33, $0f, $33, $10, $33, $11, $33, $12, $33, $13, $33
	db $14, $33, $15, $33, $16, $33, $17, $33, $18, $33, $19, $33, $1a, $33, $1b, $33
	db $1c, $33, $1d, $33, $1e, $33, $1f, $33, $20, $33, $21, $33, $22, $33, $23, $33
	db $24, $33, $25, $33, $26, $33, $27, $33, $00, $32, $01, $32, $02, $32, $03, $32
	db $04, $32, $05, $32, $06, $32, $07, $32, $08, $32, $09, $32, $0a, $32, $0b, $32
	db $0c, $32, $0d, $32, $0e, $32, $0f, $32, $10, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $00, $00, $00, $00, $a0, $00, $00, $00, $40, $01, $00, $00, $e0, $01
	db $00, $00, $00, $00, $80, $00, $a0, $00, $80, $00, $40, $01, $80, $00, $e0, $01
	db $80, $00, $00, $00, $00, $01, $a0, $00, $00, $01, $40, $01, $00, $01, $e0, $01
	db $00, $01, $00, $00, $80, $01, $a0, $00, $80, $01, $40, $01, $80, $01, $e0, $01
	db $80, $01, $00, $00, $0a, $00, $14, $00, $1e, $00, $00, $08, $0a, $08, $14, $08
	db $1e, $08, $00, $10, $0a, $10, $14, $10, $1e, $10, $00, $18, $0a, $18, $14, $18
	db $1e, $18, $a0, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5
	db $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd
	db $ce, $cf, $d0, $d1, $d2, $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba
	db $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $c2
	db $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0, $d1, $d2
	db $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

Jump_000_2edd:
	push af
	push bc
	push de
	push hl
	ld hl, far_SerialInterruptHandler
	rst $10
	pop hl
	pop de
	pop bc
	pop af
	reti


LCDInterruptHandler::
	push af
	push bc
	push de
	push hl
	ld a, [wLCDEffect]
	rst $00

LCDEffectTable::
	dw LCDInterruptReturn
	dw LCDEffectHideSprites
	dw LCDEffectWaveX
	dw LCDEffectWaveY

LCDEffectHideSprites::
	ldh a, [rSTAT]
	and $03
	jr nz, LCDEffectHideSprites

	ldh a, [rLCDC]
	res 1, a
	ldh [rLCDC], a
	jr LCDInterruptReturn

LCDEffectWaveX::
	ldh a, [rLY]
	ld l, a
	ld h, $c1
	ld a, [hl]
	ldh [rSCX], a
	ldh a, [rLYC]
	add $02
	ldh [rLYC], a
	cp $80
	jr c, LCDInterruptReturn

	ldh a, [hScrollX]
	ldh [rSCX], a
	ld a, $01
	ldh [rLYC], a
	jr LCDInterruptReturn

LCDEffectWaveY::
	ldh a, [rLY]
	ld l, a
	ld h, $c1
	ld a, [hl]
	ldh [rSCY], a
	ldh a, [rLYC]
	add $02
	ldh [rLYC], a
	cp $81
	jr c, LCDInterruptReturn

	ldh a, [hScrollY]
	ldh [rSCY], a
	ld a, $00
	ldh [rLYC], a
	jr LCDInterruptReturn

LCDInterruptReturn::
	pop hl
	pop de
	pop bc
	pop af
	reti


CompareHLBC::
	ld a, h
	cp b
	ret nz

	ld a, l
	cp c
	ret


DivideHLBC::
	ld de, $0000
	ld a, b
	or a
	jr z, jr_000_2f5d

jr_000_2f52:
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr c, jr_000_2f66

	inc de
	jr jr_000_2f52

jr_000_2f5d:
	ld a, c
	call Divide16
	ld c, a
	ld b, $00
	jr jr_000_2f6b

jr_000_2f66:
	add hl, bc
	ld b, h
	ld c, l
	ld h, d
	ld l, e

jr_000_2f6b:
	ret


AddEightTimes::
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ret


CheckBattlerCanAct::
	push hl
	push bc
	ld c, a
	call CheckBattlerPresent
	jr c, jr_000_2fa1

	ld a, c
	ld hl, wBattlerStatus
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	and $d0
	jr nz, jr_000_2fa0

	inc hl
	inc hl
	ld a, [hli]
	and $3f
	jr nz, jr_000_2fa0

	inc hl
	ld a, [hl]
	and $c0
	jr nz, jr_000_2fa0

	xor a
	jr jr_000_2fa1

jr_000_2fa0:
	scf

jr_000_2fa1:
	ld a, c
	pop bc
	pop hl
	ret


CheckBattlerPresent::
	push hl
	push bc
	ld c, a
	cp $08
	jr nc, jr_000_2fc0

	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and a
	jr z, jr_000_2fc4

	cp $ff
	jr z, jr_000_2fc0

	scf
	jr jr_000_2fc8

jr_000_2fc0:
	xor a
	scf
	jr jr_000_2fc8

jr_000_2fc4:
	ld a, $0a
	cp $01

jr_000_2fc8:
	ld a, c
	pop bc
	pop hl
	ret


GetBattlerAttack::
	ld hl, wBattlerAttack
	call GetWordFromTable
	ret


GetBattlerDefense::
	ld hl, wBattlerDefense
	call GetWordFromTable
	ret


GetBattlerMaxHP::
	ld hl, wBattlerMaxHP
	call GetWordFromTable
	ret


GetBattlerMaxMP::
	ld hl, wBattlerMaxMP
	call GetWordFromTable
	ret


GetBattlerHP::
	ld hl, wBattlerHP
	call GetWordFromTable
	ret


GetBattlerMP::
	ld hl, wBattlerMP
	call GetWordFromTable
	ret


GetWordFromTable::
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret


UpdateSkillAnimation::
	ld a, [wSkillAnimActive]
	or a
	ret z

	ld a, [wLinkFlags]
	and $02
	sla a
	ld b, a
	ld a, [wSkillUser]
	xor b
	cp $04
	jr nc, jr_000_3029

	ld a, [wSkillTarget]
	xor b
	cp $04
	jr nc, jr_000_3029

	ld a, $00
	ld [wSkillAnimSprites], a
	ld a, $00
	ld [$dd62], a
	ret


jr_000_3029:
	ld hl, far_Call_5F_5630
	rst $10
	ld a, [wSkillAnim]
	cp $ff
	ret z

	cp $0e
	jr c, jr_000_3048

	cp $15
	jr z, jr_000_3052

	cp $21
	jr c, jr_000_304d

	cp $2c
	jr z, jr_000_3059

	ld hl, far_DrawSkillAnimSprite_5E
	rst $10
	ret


jr_000_3048:
	ld hl, far_DrawSkillAnimSprite_5C
	rst $10
	ret


jr_000_304d:
	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	ret


jr_000_3052:
	ld a, [wSkillId]
	cp $c5
	jr nz, jr_000_304d

jr_000_3059:
	ld a, [wEnemyCount]
	cp $01
	jr z, jr_000_30b4

	cp $02
	jr z, jr_000_30ce

	ld a, [wEnemyDown]
	or a
	jr nz, jr_000_307f

	ld a, $20
	ldh [hSpriteX], a
	ld a, [wSkillAnim]
	cp $15
	jr nz, jr_000_307b

	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	jr jr_000_307f

jr_000_307b:
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10

jr_000_307f:
	ld a, [$dd20]
	or a
	jr nz, jr_000_309a

	ld a, $50
	ldh [hSpriteX], a
	ld a, [wSkillAnim]
	cp $15
	jr nz, jr_000_3096

	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	jr jr_000_309a

jr_000_3096:
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10

jr_000_309a:
	ld a, [$dd21]
	or a
	ret nz

	ld a, $80
	ldh [hSpriteX], a
	ld a, [wSkillAnim]
	cp $15
	jr nz, jr_000_30af

	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	ret


jr_000_30af:
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10
	ret


jr_000_30b4:
	ld a, [wEnemyDown]
	or a
	ret nz

	ld a, $50
	ldh [hSpriteX], a
	ld a, [wSkillAnim]
	cp $15
	jr nz, jr_000_30c9

	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	ret


jr_000_30c9:
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10
	ret


jr_000_30ce:
	ld a, [wEnemyDown]
	or a
	jr nz, jr_000_30e9

	ld a, $38
	ldh [hSpriteX], a
	ld a, [wSkillAnim]
	cp $15
	jr nz, jr_000_30e5

	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	jr jr_000_30e9

jr_000_30e5:
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10

jr_000_30e9:
	ld a, [$dd20]
	or a
	ret nz

	ld a, $68
	ldh [hSpriteX], a
	ld a, [wSkillAnim]
	cp $15
	jr nz, jr_000_30fe

	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	ret


jr_000_30fe:
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10
	ret


	db $21, $07, $5f, $d7, $fa, $81, $da, $fe, $ff, $c8, $21, $9b, $c8, $23, $3e, $d0
	db $22, $3e, $e0, $77, $21, $41, $31, $fa, $81, $da, $85, $6f, $3e, $00, $8c, $67
	db $7e, $ea, $9c, $c8, $fa, $81, $da, $fe, $0e, $38, $09, $fe, $21, $38, $0a, $21
	db $01, $5e, $d7, $c9, $21, $01, $5c, $d7, $c9, $21, $01, $5d, $d7, $c9, $e0, $e0
	db $e0, $e0, $e0, $e0, $d0, $d0, $d0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $d0, $d0, $e0, $e0, $e0, $e0, $e0, $d0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $d0, $00, $01, $12, $35, $8a
	db $cd, $ee, $ff, $ff, $fe, $ed, $ca, $85, $32, $11, $00, $01, $23, $45, $67, $89
	db $ab, $cd, $ef, $fe, $dc, $ba, $98, $76, $54, $32, $10, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ee, $dd, $cc, $bb
	db $aa, $99, $88, $77, $66, $55, $44, $33, $22, $11, $00, $ff, $ff, $de, $bd, $24
	db $12, $00, $00, $00, $00, $21, $42, $db, $ed, $ff, $ff, $ff, $ff, $ee, $ca, $53
	db $11, $00, $00, $00, $00, $11, $35, $ac, $ee, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $ff, $00, $00, $00, $66, $aa, $bb
	db $dd, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ee, $ed, $dd
	db $cc, $cb, $ba, $a9, $98, $87, $65, $54, $43, $31, $10, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $aa, $bb, $cc, $dd, $ee, $ff, $ff, $00, $00, $00, $00, $aa
	db $aa, $bb, $cc, $dd, $dd, $ff, $ff, $ff, $ff, $00, $ff, $00, $00, $00, $00, $aa
	db $aa, $bb, $cc, $dd, $dd, $ff, $ff, $ff, $ff, $aa, $ff, $01, $12, $22, $33, $35
	db $55, $77, $99, $55, $99, $aa, $bb, $cc, $dd, $ee, $ff, $fc, $dc, $ba, $90, $70
	db $50, $30, $15, $15, $15, $15, $22, $55, $77, $aa, $cc, $ee, $ee, $cd, $ac, $35
	db $23, $11, $11, $11, $11, $32, $53, $ca, $dc, $ee, $ee, $dd, $dd, $dd, $dd, $dd
	db $dd, $dd, $dd, $22, $22, $22, $22, $22, $22, $22, $22, $70, $32, $f1, $d0, $b0
	db $90, $70, $50, $30, $15, $15, $15, $15, $15, $15, $15, $15, $15, $f3, $d0, $b0
	db $90, $70, $50, $30, $10, $51, $40, $30, $20, $15, $15, $15, $15, $89, $98, $a8
	db $b8, $c8, $d8, $e8, $f5, $f5, $f5, $f5, $f5, $f5, $f5, $f5, $f5, $b9, $c8, $d8
	db $e8, $f1, $d0, $b0, $90, $70, $50, $30, $15, $15, $15, $15, $15, $99, $a8, $b8
	db $c8, $d8, $e8, $f4, $f4, $f0, $e0, $d0, $b0, $90, $70, $50, $35, $db, $f3, $d0
	db $b0, $90, $81, $70, $60, $50, $40, $30, $20, $15, $15, $15, $15, $f1, $e0, $d0
	db $c0, $b0, $a0, $90, $80, $70, $60, $50, $40, $30, $20, $10, $05, $f1, $70, $50
	db $30, $20, $15, $15, $15, $15, $05, $05, $05, $05, $05, $05, $05, $f1, $b0, $70
	db $50, $30, $20, $20, $15, $15, $15, $15, $15, $15, $15, $15, $05, $f1, $b0, $70
	db $50, $30, $10, $51, $40, $30, $20, $15, $15, $15, $15, $15, $05, $f3, $d0, $b0
	db $90, $70, $50, $30, $10, $51, $40, $30, $20, $15, $15, $15, $05, $09, $18, $28
	db $38, $48, $58, $68, $78, $88, $98, $a8, $b8, $c8, $d8, $e8, $f5, $c9

InitSound::
	ld bc, $0000
	call SetSyncedBankSwitch
	ld a, $80
	ldh [rNR52], a
	xor a
	ldh [rNR51], a
	ld [wSoundPanning], a
	ld a, $77
	ldh [rNR50], a
	ld hl, wSoundChannels
	ld b, $06
	ld a, $ff

jr_000_334c:
	ld [hl], a
	ld de, $0019
	add hl, de
	ld [hl], a
	ld de, $0001
	add hl, de
	dec b
	jr nz, jr_000_334c

	xor a
	ld [wSoundFirstChannel], a
	ret


	db $af, $ea, $29, $de, $c9, $3e, $04, $ea, $29, $de, $af, $ea, $1d, $de, $c9

SetSyncedBankSwitch::
	ld a, b
	ld [wSyncSwitchChannels], a
	ld a, c
	ld [wSyncSwitchBank], a
	xor a
	ld [wSyncNoteEnds], a
	ret


MarkNoteEnd::
	ld a, [wSoundCurChannel]
	inc a
	ld b, a
	ld a, $01

jr_000_3381:
	dec b
	jr z, jr_000_3387

	add a
	jr jr_000_3381

jr_000_3387:
	ld b, a
	ld a, [wSyncNoteEnds]
	or b
	ld [wSyncNoteEnds], a
	ret


ApplySyncedBankSwitch::
	ld a, [wSyncNoteEnds]
	ld hl, wSyncSwitchChannels
	and [hl]
	cp [hl]
	jr nz, jr_000_33c4

	ld hl, $dd84
	ld a, [wSyncSwitchBank]
	and $0f
	ld b, a
	ld a, [wSyncSwitchChannels]

jr_000_33a6:
	srl a
	ld [wSyncNoteEnds], a
	jr nc, jr_000_33b2

	ld a, [hl]
	and $f0
	or b
	ld [hl], a

jr_000_33b2:
	ld a, l
	add $1a
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [wSyncNoteEnds]
	and a
	jr nz, jr_000_33a6

	xor a
	ld [wSyncSwitchChannels], a

jr_000_33c4:
	xor a
	ld [wSyncNoteEnds], a
	ret


StartSounds4::
	call StartSoundChannel

StartSounds3::
	call StartSoundChannel

StartSounds2::
	call StartSoundChannel

StartSoundChannel::
	push bc
	push de
	push hl
	ld a, [wSoundID]
	ld hl, $3466

jr_000_33db:
	cp [hl]
	jr c, jr_000_33e4

	inc hl
	inc hl
	inc hl
	inc hl
	jr jr_000_33db

jr_000_33e4:
	ld a, [$4000]
	push af
	dec hl
	ld a, [hld]
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ld a, [hld]
	ld d, a
	ld a, [hld]
	ld e, a
	ld a, [wSoundID]
	sub [hl]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, de
	push hl
	pop de
	ld a, [de]
	inc de
	ld c, a
	ld b, $00
	ld hl, wSoundChannels
	add hl, bc
	ld a, [hl]
	cp $ff
	jr z, jr_000_3430

	inc hl
	ld a, [hld]
	ld b, $ee
	and $03
	jr z, jr_000_3429

	ld b, $dd
	cp $01
	jr z, jr_000_3429

	ld b, $bb
	cp $02
	jr z, jr_000_3429

	ld b, $77

jr_000_3429:
	ld a, [wSoundPanning]
	and b
	ld [wSoundPanning], a

jr_000_3430:
	xor a
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [$4000]
	ld [hl], a
	push hl
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, $ff
	ld [hl], a
	pop hl
	ld de, $0015
	add hl, de
	xor a
	ld [hl], a
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ld a, [wSoundID]
	inc a
	ld [wSoundID], a
	pop hl
	pop de
	pop bc
	ret


	db $00, $01, $40, $1c, $21, $01, $40, $1d, $37, $01, $40, $1e, $ff

UpdateSound::
	ld a, [$4000]
	push af
	ld a, [wSoundFirstChannel]
	ld [wSoundCurChannel], a
	xor a
	ld [wSoundClaimed], a
	ld hl, wSoundFrame
	inc [hl]
	ld hl, wSoundChannels

Jump_000_3488:
	push hl
	ld de, hChanPos
	ld b, $03

jr_000_348e:
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	dec b
	jr nz, jr_000_348e

	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hl]
	ld [de], a
	ldh a, [hChanConfig]
	and $03
	ld [wSoundHWChannel], a
	ld b, a
	add a
	add a
	add b
	ld [wSoundRegOffset], a
	inc b
	ld a, $88

jr_000_34bf:
	rlca
	dec b
	jr nz, jr_000_34bf

	ld [wSoundChannelBits], a
	ld [wSoundChannelBits2], a
	ldh a, [hChanPos]
	ld b, a
	ldh a, [hChanPosHi]
	and b
	cp $ff
	jp z, Jump_000_3559

	ldh a, [hChanBank]
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ldh a, [hChanPosHi]
	or b
	and a
	jp z, Jump_000_357f

	call UpdateVibrato
	call UpdateInstrument
	ldh a, [hChanInstLength]
	ld b, a
	ldh a, [hChanInstStep]
	inc a
	cp b
	jr c, jr_000_34f8

	ld a, b

jr_000_34f8:
	ldh [hChanInstStep], a
	ld hl, hChanTempo
	ldh a, [hChanDuty]
	and $0f
	add [hl]
	cp $10
	jr c, jr_000_350b

	sub $10
	ld [hl], a
	jr jr_000_3527

jr_000_350b:
	ld [hl], a
	call UpdateVolumeSlide
	ldh a, [hChanVibTimer]
	and a
	jr z, jr_000_3517

	dec a
	ldh [hChanVibTimer], a

jr_000_3517:
	ld hl, hChanNoteTimer
	dec [hl]
	jr nz, jr_000_3527

	call MarkNoteEnd

Jump_000_3520:
	ldh a, [hChanVibDelay]
	ldh [hChanVibTimer], a
	call ReadChannelEvents

jr_000_3527:
	ld a, [wSoundChannelBits]
	ld b, a
	ld a, [wSoundClaimed]
	or b
	ld [wSoundClaimed], a
	pop hl
	push hl
	ld de, hChanPos
	ld b, $03

jr_000_3539:
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	dec b
	jr nz, jr_000_3539

	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a

Jump_000_3559:
	pop hl
	ld de, $001a
	add hl, de
	ld a, [wSoundCurChannel]
	inc a
	ld [wSoundCurChannel], a
	cp $06
	jp c, Jump_000_3488

	ld a, [wSoundPanning]
	ldh [rNR51], a
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	call ApplySyncedBankSwitch
	ret


Jump_000_357f:
	ldh a, [hChanData]
	ld l, a
	ldh a, [$ffe7]
	ld h, a
	xor a
	ldh [hChanTempo], a
	ld a, [hli]
	and $0f
	ld d, a
	ld a, [wSoundHWChannel]
	cp $02
	jr z, jr_000_35bf

	ld a, [hli]
	rrca
	rrca
	and $c0
	or d

jr_000_3599:
	ldh [hChanDuty], a
	ld a, [hli]
	swap a
	ldh [hChanEnvelope], a
	ld a, [wSoundHWChannel]
	cp $02
	jr z, jr_000_35c5

	ld a, [hli]
	ldh [hChanSweep], a

jr_000_35aa:
	xor a
	ldh [hChanLoop1], a
	ldh [hChanLoop2], a
	ldh [$fff0], a
	ldh [hChanVolSlide], a
	ldh [hChanPosHi], a
	dec a
	ldh [hChanPan], a
	ld a, $02
	ldh [hChanPos], a
	jp Jump_000_3520


jr_000_35bf:
	ld a, [hli]
	ldh [hChanInstLength], a
	ld a, d
	jr jr_000_3599

jr_000_35c5:
	xor a
	ldh [rNR30], a
	ld d, a
	ldh a, [hChanSweep]
	ld e, a
	cp $ff
	jr nz, jr_000_35d4

	ld e, [hl]
	ld a, e
	ldh [hChanSweep], a

jr_000_35d4:
	ld [wSoundWave], a
	swap e
	ld hl, $316e
	add hl, de
	ld de, $ff30
	ld b, $10

jr_000_35e2:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_35e2

	jr jr_000_35aa

ReadChannelEvents::
	ldh a, [hChanPos]
	ld l, a
	ldh a, [hChanPosHi]
	ld h, a
	add hl, hl
	ldh a, [hChanData]
	ld e, a
	ldh a, [$ffe7]
	ld d, a
	add hl, de

Jump_000_35f8:
jr_000_35f8:
	ldh a, [hChanPos]
	add $01
	ldh [hChanPos], a
	ldh a, [hChanPosHi]
	adc $00
	ldh [hChanPosHi], a
	ld a, [hli]
	cp $d0
	jr nc, jr_000_3630

	cp $b0
	jr nc, jr_000_366e

	cp $a0
	jp nc, Jump_000_36cb

	jp Jump_000_37ee


jr_000_3615:
	cp $fd
	jr nz, jr_000_3624

	ldh a, [hChanPos]
	ldh [hChanLoopPos], a
	ldh a, [hChanPosHi]
	ldh [$fffe], a

jr_000_3621:
	inc hl
	jr jr_000_35f8

jr_000_3624:
	cp $ff
	jr nz, jr_000_3621

	ldh [hChanPos], a
	ldh [hChanPosHi], a
	call StopChannelOutput
	ret


jr_000_3630:
	cp $f0
	jr nc, jr_000_3615

	cp $e0
	jr nc, jr_000_363c

	and $0f
	jr jr_000_3640

jr_000_363c:
	and $0f
	cpl
	inc a

jr_000_3640:
	ld b, a
	ld a, [wSoundHWChannel]
	cp $02
	jr z, jr_000_3650

	ld a, b
	ldh [hChanVolSlide], a
	ld a, [hl]
	ldh [hChanVolSlideRate], a
	ldh [hChanVolSlideTimer], a

jr_000_3650:
	inc hl
	jr jr_000_35f8

jr_000_3653:
	and $0f
	ld b, a
	ld a, [wSoundHWChannel]
	cp $02
	jr z, jr_000_366b

	ldh a, [hChanEnvelope]
	and $0f
	jr nz, jr_000_366b

	ld a, [hl]
	ldh [hChanInstLength], a
	ld a, b
	swap a
	ldh [$fff0], a

jr_000_366b:
	inc hl
	jr jr_000_35f8

jr_000_366e:
	cp $c0
	jr nc, jr_000_3653

	and $0f
	jr z, jr_000_3699

	ld e, a
	ld a, [hl]
	and a
	jr nz, jr_000_368b

	ldh a, [hChanLoop1]
	dec a
	ldh [hChanLoop1], a
	jr z, jr_000_36b0

	bit 7, a
	jr z, jr_000_3699

	ld a, e
	ldh [hChanLoop1], a
	jr jr_000_3699

jr_000_368b:
	ldh a, [hChanLoop2]
	dec a
	ldh [hChanLoop2], a
	jr z, jr_000_36c2

	bit 7, a
	jr z, jr_000_3699

	ld a, e
	ldh [hChanLoop2], a

jr_000_3699:
	ld a, [hl]
	cp $fc
	jr z, jr_000_36a9

	ldh a, [hChanLoopPos]
	ldh [hChanPos], a
	ldh a, [$fffe]
	ldh [hChanPosHi], a
	jp ReadChannelEvents


jr_000_36a9:
	inc hl
	ld a, [hli]
	ldh [hChanPos], a
	ld a, [hl]
	ldh [hChanPosHi], a

jr_000_36b0:
	jp ReadChannelEvents


	db $f0, $e4, $c6, $01, $e0, $e4, $f0, $fd, $ce, $00, $e0, $fd, $c3, $ea, $35

jr_000_36c2:
	ldh a, [hChanPos]
	add $01
	ldh [hChanPos], a
	jp ReadChannelEvents


Jump_000_36cb:
	cp $a0
	jr nz, jr_000_36e5

	ld a, [hli]
	swap a
	ldh [hChanEnvelope], a
	ld a, [wSoundChannelBits]
	ld b, a
	ld a, [wSoundClaimed]
	and b
	jp nz, Jump_000_35f8

	call SetChannelEnvelope
	jp Jump_000_35f8


jr_000_36e5:
	cp $a1
	jr nz, jr_000_3725

	ld a, [wSoundHWChannel]
	cp $02
	jr z, jr_000_36f6

	ld a, [hli]
	ldh [hChanSweep], a
	jp Jump_000_35f8


jr_000_36f6:
	xor a
	ldh [rNR30], a
	ld d, a
	ld a, [hli]
	ld e, a
	ldh [hChanSweep], a
	ld a, [wSoundChannelBits]
	ld b, a
	ld a, [wSoundClaimed]
	and b
	jr z, jr_000_370b

	jp Jump_000_35f8


jr_000_370b:
	push hl
	ld a, e
	ld [wSoundWave], a
	swap e
	ld hl, $316e
	add hl, de
	ld de, $ff30
	ld b, $10

jr_000_371b:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_371b

	pop hl
	jp Jump_000_35f8


jr_000_3725:
	cp $a2
	jr nz, jr_000_3746

	ld a, [wSoundHWChannel]
	cp $02
	jr z, jr_000_3740

	ld a, [hli]
	rrca
	rrca
	and $c0
	ld d, a
	ldh a, [hChanDuty]
	and $3f
	or d
	ldh [hChanDuty], a
	jp Jump_000_35f8


jr_000_3740:
	ld a, [hli]
	ldh [hChanInstLength], a
	jp Jump_000_35f8


jr_000_3746:
	cp $a3
	jr nz, jr_000_376d

	ld a, [hli]
	bit 7, a
	jr nz, jr_000_3767

	ld b, a
	and $0f
	add a
	ldh [hChanVibDelay], a
	ldh [hChanVibTimer], a
	ld a, b
	and $70
	ld e, a
	ldh a, [hChanConfig]
	and $0f
	or e
	or $80

jr_000_3762:
	ldh [hChanConfig], a
	jp Jump_000_35f8


jr_000_3767:
	ldh a, [hChanConfig]
	and $0f
	jr jr_000_3762

jr_000_376d:
	cp $a5
	jr nz, jr_000_377f

	ld a, [hli]
	cp $01
	jr nz, jr_000_377a

	ldh a, [hChanPan]
	swap a

jr_000_377a:
	ldh [hChanPan], a
	jp Jump_000_35f8


jr_000_377f:
	cp $a6
	jr nz, jr_000_3789

	ld a, [hli]
	ldh [rNR50], a
	jp Jump_000_35f8


jr_000_3789:
	cp $a7
	jr nz, jr_000_3793

	ld a, [hl]
	ldh [hChanNoteTimer], a
	jp Jump_000_38a5


jr_000_3793:
	cp $a8
	jr nz, jr_000_379d

	ld a, [hli]
	ldh [hChanInstrument], a
	jp Jump_000_35f8


jr_000_379d:
	cp $ae
	jr nz, jr_000_37af

	ld a, [hli]
	and $10
	ld b, a
	ldh a, [hChanDuty]
	and $ef
	or b
	ldh [hChanDuty], a
	jp Jump_000_35f8


jr_000_37af:
	cp $af
	jr nz, jr_000_37c1

	ld a, [hli]
	and $0f
	ld b, a
	ldh a, [hChanDuty]
	and $f0
	or b
	ldh [hChanDuty], a
	jp Jump_000_35f8


jr_000_37c1:
	inc hl
	jp Jump_000_35f8


	db $00, $01, $11, $12, $14, $23, $07, $15, $17, $32, $33, $60, $61, $45, $53, $62

jr_000_37d5:
	xor a
	ldh [hChanFreq], a
	ld a, $80
	ldh [$fff7], a
	ld a, [wSoundHWChannel]
	cp $02
	jr z, jr_000_37e7

	call SilenceChannel
	ret


jr_000_37e7:
	call SkipIfChannelClaimed
	xor a
	ldh [rNR30], a
	ret


Jump_000_37ee:
	ld b, a
	ld a, [hl]
	ldh [hChanNoteTimer], a
	ld a, [wSoundHWChannel]
	cp $03
	jr nz, jr_000_3815

	ld a, b
	cp $1f
	jr z, jr_000_37d5

	cp $10
	jr nc, jr_000_3810

	ld hl, $37c5
	add l
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld l, [hl]
	ld h, $00
	jr jr_000_3848

jr_000_3810:
	ld l, a
	ld h, $00
	jr jr_000_3848

jr_000_3815:
	ld a, b
	and $0f
	cp $0c
	jr nc, jr_000_37d5

	add a
	ld e, a
	ldh a, [hChanDuty]
	and $10
	jr z, jr_000_3828

	ld a, e
	add $18
	ld e, a

jr_000_3828:
	ld d, $00
	ld hl, $3a53
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, b
	swap a
	and $0f
	jr z, jr_000_3840

	ld b, a

jr_000_3839:
	srl h
	rr l
	dec b
	jr nz, jr_000_3839

jr_000_3840:
	ld a, $00
	sub l
	ld l, a
	ld a, $08
	sbc h
	ld h, a

jr_000_3848:
	xor a
	ldh [hChanInstStep], a
	call SkipIfChannelClaimed
	ld a, [wSoundHWChannel]
	cp $02
	jr nz, jr_000_385c

	call LoadWavePattern
	ld a, $80
	ldh [rNR30], a

jr_000_385c:
	push hl
	call UpdateChannelVolume
	pop hl
	ld a, [wSoundHWChannel]
	and a
	ldh a, [hChanSweep]
	ld c, $10
	call z, WriteChannelReg
	ld a, l
	ld c, $13
	call WriteChannelReg
	ld a, l
	cp $02
	jr c, jr_000_387f

	cp $fe
	jr c, jr_000_3881

	ld a, $fd
	jr jr_000_3881

jr_000_387f:
	ld a, $02

jr_000_3881:
	ldh [hChanFreq], a
	ld a, [wSoundHWChannel]
	cp $02
	jr z, jr_000_38b8

	cp $02
	jr nc, jr_000_3899

	ldh a, [hChanDuty]
	and $c0
	or $3f
	ld c, $11
	call WriteChannelReg

jr_000_3899:
	ld a, h
	and $07
	or $80

jr_000_389e:
	ldh [$fff7], a
	ld c, $14
	call WriteChannelReg

Jump_000_38a5:
	ld a, [wSoundChannelBits2]
	ld b, a
	cpl
	ld c, a
	ldh a, [hChanPan]
	and b
	ld b, a
	ld a, [wSoundPanning]
	and c
	or b
	ld [wSoundPanning], a
	ret


jr_000_38b8:
	xor a
	ldh [rNR31], a
	ldh a, [rNR52]
	and $04
	jr z, jr_000_3899

	ld a, h
	and $07
	jr jr_000_389e

UpdateVolumeSlide::
	ld a, [wSoundHWChannel]
	cp $02
	ret z

	ldh a, [hChanVolSlide]
	and a
	ret z

	ld hl, hChanVolSlideTimer
	dec [hl]
	ret nz

	ldh a, [hChanEnvelope]
	swap a
	cp $10
	ret nc

	and $0f
	ld b, a
	ldh a, [hChanVolSlideRate]
	ldh [hChanVolSlideTimer], a
	ld hl, hChanVolSlide
	ld a, [hl]
	bit 7, a
	jr nz, jr_000_38f9

	dec [hl]
	ld a, b
	cp $0f
	ret z

	ldh a, [hChanEnvelope]
	add $10
	ldh [hChanEnvelope], a
	jp SetChannelEnvelope


jr_000_38f9:
	inc [hl]
	ld a, b
	and a
	ret z

	ldh a, [hChanEnvelope]
	sub $10
	ldh [hChanEnvelope], a
	jr SetChannelEnvelope

UpdateVibrato::
	call SkipIfChannelClaimed
	ld a, [wSoundHWChannel]
	cp $03
	ret z

	ldh a, [hChanVibTimer]
	and a
	ret nz

	ldh a, [hChanConfig]
	bit 7, a
	ret z

	and $70
	ld b, a
	ld a, [wSoundFrame]
	and $0f
	or b
	ld e, a
	ld d, $00
	ld hl, $3b83
	add hl, de
	ldh a, [hChanFreq]
	add [hl]
	ld c, $13
	jr WriteChannelReg

UpdateChannelVolume::
	ld a, [wSoundHWChannel]
	cp $02
	jr z, jr_000_395d

	ldh a, [$fff0]
	and a
	jr nz, jr_000_398e

	ldh a, [hChanEnvelope]

SetChannelEnvelope::
	ld b, a
	and $07
	jr nz, jr_000_3945

	ld a, b
	or $08
	ld b, a

jr_000_3945:
	ld a, [wSoundRegOffset]
	add $12
	ld c, a
	ldh a, [c]
	cp b
	ret z

	ld a, b
	ldh [c], a
	ldh a, [$fff7]
	ld c, $14

WriteChannelReg::
	ld b, a
	ld a, [wSoundRegOffset]
	add c
	ld c, a
	ld a, b
	ldh [c], a
	ret


jr_000_395d:
	ldh a, [hChanEnvelope]
	ld c, $12
	jr WriteChannelReg

jr_000_3963:
	ld a, e
	srl a
	add $02
	swap a
	ld hl, hChanEnvelope
	cp [hl]
	ret c

	and $60
	ldh [rNR32], a
	ret


UpdateInstrument::
	call SkipIfChannelClaimed
	ldh a, [hChanFreq]
	and a
	jr nz, jr_000_3983

	ldh a, [$fff7]
	and $7f
	jp z, SilenceChannel

jr_000_3983:
	ld a, [wSoundHWChannel]
	cp $02
	jr z, jr_000_398e

	ldh a, [$fff0]
	and a
	ret z

jr_000_398e:
	ldh a, [hChanInstLength]
	and a
	ret z

	ld e, $00
	ld c, a
	ldh a, [hChanInstStep]
	ld b, $04

jr_000_3999:
	add a
	cp c
	jr c, jr_000_399e

	sub c

jr_000_399e:
	ccf
	rl e
	dec b
	jr nz, jr_000_3999

	ld a, [wSoundHWChannel]
	cp $02
	jr z, jr_000_3963

	ldh a, [$fff0]
	or e
	ld e, a
	ld d, $00
	push de
	ldh a, [hChanInstrument]
	ld de, $326e
	sla a
	add e
	ld e, a
	xor a
	adc d
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	pop de
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	add hl, de
	ldh a, [hChanEnvelope]
	swap a
	ld e, a
	ld a, [hl]
	ld h, a
	and $f0
	or e
	ld e, a
	bit 2, h
	jr nz, jr_000_39fc

	inc b
	ld a, c
	swap a
	and $0f
	jr z, jr_000_39fc

	ld b, a
	bit 3, e
	jr nz, jr_000_39f5

	sla b
	bit 2, e
	jr nz, jr_000_39f5

	sla b
	bit 1, e
	jr z, jr_000_39fa

jr_000_39f5:
	ld a, b
	cp $08
	jr c, jr_000_39fc

jr_000_39fa:
	ld b, $00

jr_000_39fc:
	bit 1, h
	jr z, jr_000_3a05

	ld a, b
	jr z, jr_000_3a05

	srl b

jr_000_3a05:
	ld a, h
	and $08
	or b
	ld b, a
	bit 0, h
	jr z, jr_000_3a17

	ld hl, $3a83
	add hl, de
	ld a, [hl]
	or b
	jp SetChannelEnvelope


jr_000_3a17:
	ld c, $12
	ld a, [wSoundRegOffset]
	add c
	ld c, a
	ldh a, [c]
	and $08
	ld l, a
	ld a, h
	and $08
	cp l
	ret z

	ld hl, $3a83
	add hl, de
	ld a, [hl]
	or b
	jp SetChannelEnvelope


SilenceChannel::
	call SkipIfChannelClaimed
	ld a, $00
	jp SetChannelEnvelope


StopChannelOutput::
	call SkipIfChannelClaimed
	ld a, [wSoundChannelBits]
	cpl
	ld b, a
	ld a, [wSoundPanning]
	and b
	ld [wSoundPanning], a
	ret


SkipIfChannelClaimed::
	ld a, [wSoundChannelBits]
	ld b, a
	ld a, [wSoundClaimed]
	and b
	ret z

	pop af
	ret


	db $d4, $07, $64, $07, $f9, $06, $95, $06, $37, $06, $dd, $05, $89, $05, $3a, $05
	db $f0, $04, $a8, $04, $65, $04, $26, $04, $9c, $07, $2e, $07, $c7, $06, $66, $06
	db $0a, $06, $b3, $05, $61, $05, $15, $05, $cc, $04, $86, $04, $45, $04, $08, $04
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $10, $10, $10, $10, $10, $10, $10, $10
	db $00, $00, $00, $00, $10, $10, $10, $10, $10, $10, $10, $10, $20, $20, $20, $20
	db $00, $00, $00, $10, $10, $10, $10, $10, $20, $20, $20, $20, $20, $30, $30, $30
	db $00, $00, $10, $10, $10, $10, $20, $20, $20, $20, $30, $30, $30, $30, $40, $40
	db $00, $00, $10, $10, $10, $20, $20, $20, $30, $30, $30, $40, $40, $40, $50, $50
	db $00, $00, $10, $10, $20, $20, $20, $30, $30, $40, $40, $40, $50, $50, $60, $60
	db $00, $00, $10, $10, $20, $20, $30, $30, $40, $40, $50, $50, $60, $60, $70, $70
	db $00, $10, $10, $20, $20, $30, $30, $40, $40, $50, $50, $60, $60, $70, $70, $80
	db $00, $10, $10, $20, $20, $30, $40, $40, $50, $50, $60, $70, $70, $80, $80, $90
	db $00, $10, $10, $20, $30, $30, $40, $50, $50, $60, $70, $70, $80, $90, $90, $a0
	db $00, $10, $10, $20, $30, $40, $40, $50, $60, $70, $70, $80, $90, $a0, $a0, $b0
	db $00, $10, $20, $20, $30, $40, $50, $60, $60, $70, $80, $90, $a0, $a0, $b0, $c0
	db $00, $10, $20, $30, $30, $40, $50, $60, $70, $80, $90, $a0, $a0, $b0, $c0, $d0
	db $00, $10, $20, $30, $40, $50, $60, $70, $70, $80, $90, $a0, $b0, $c0, $d0, $e0
	db $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $a0, $b0, $c0, $d0, $e0, $f0
	db $00, $00, $01, $01, $00, $00, $ff, $ff, $00, $00, $01, $01, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00, $ff, $ff, $ff, $ff
	db $00, $01, $02, $01, $00, $ff, $fe, $ff, $00, $01, $02, $01, $00, $ff, $fe, $ff
	db $00, $00, $01, $01, $02, $02, $01, $01, $00, $00, $ff, $ff, $fe, $fe, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02

LoadWavePattern::
	ld a, [wSoundWave]
	ld b, a
	ldh a, [hChanSweep]
	cp b
	ret z

	ld [wSoundWave], a
	ld e, a
	swap e
	xor a
	ldh [rNR30], a
	ld d, a
	ld hl, $316e
	add hl, de
	ld de, $ff30
	ld b, $10

jr_000_3c1e:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_3c1e

	ret


	db $fa, $ff, $cd, $3d, $fe, $f7, $30, $08, $7e, $f6, $7f, $2f, $77, $cb, $7e, $c9
	db $af, $77, $c9, $cd, $4b, $00, $43, $3c, $4a, $3c, $83, $3c, $c6, $3c, $cd, $ab
	db $3d, $c0, $c3, $e8, $3c, $16, $c1, $cd, $c1, $07, $21, $b0, $53, $cd, $57, $09
	db $fa, $c1, $c9, $fe, $03, $cc, $63, $3c, $cd, $f0, $3b, $c3, $e8, $3c, $21, $a1
	db $cd, $7e, $36, $01, $b7, $c8, $21, $b0, $53, $3e, $05, $c3, $5a, $09, $3e, $08
	db $ea, $c0, $c9, $3e, $04, $ea, $93, $c9, $ea, $a1, $cd, $c3, $ed, $3c, $cd, $7b
	db $3b, $ca, $e8, $3c, $fa, $c1, $c9, $fe, $02, $20, $11, $fa, $98, $cd, $fe, $04
	db $30, $dc, $fe, $03, $20, $06, $fa, $a1, $cd, $b7, $20, $d2, $cd, $ab, $3d, $21
	db $bc, $3c, $e5, $cd, $13, $3c, $7e, $e6, $80, $07, $47, $e1, $fa, $c1, $c9, $87
	db $80, $ef, $7e, $16, $cc, $e7, $c9, $50, $51, $50, $51, $50, $51, $50, $51, $50
	db $51, $fa, $c1, $c9, $c7, $d4, $3c, $d4, $3c, $d4, $3c, $da, $3c, $d4, $3c, $3e
	db $05, $ea, $c0, $c9, $c9, $cd, $ff, $12, $cd, $3c, $20, $af, $ea, $c0, $c9, $c9
	db $ea, $80, $cd, $21, $90, $cd, $34, $c9, $af, $ea, $90, $cd, $c9, $cd, $84, $12
	db $c3, $d0, $74, $cd, $84, $12, $c3, $3d, $5a, $65, $9c, $6b, $9c, $fa, $8b, $c9
	db $cb, $47, $c2, $ab, $1a, $fa, $c1, $c9, $3d, $c7, $37, $3d, $17, $3d, $4b, $3d
	db $17, $3d, $cd, $4b, $00, $43, $3c, $22, $3d, $28, $3d, $37, $3d, $21, $b1, $55
	db $c3, $52, $3c, $cd, $7b, $3b, $ca, $e8, $3c, $cd, $ab, $3d, $21, $bc, $3c, $c3
	db $a7, $3c, $16, $cc, $cd, $30, $07, $3e, $20, $cd, $10, $05, $21, $8b, $c9, $cb
	db $c6, $3e, $07, $c3, $9d, $1c, $cd, $84, $12, $c3, $57, $6a, $fa, $8b, $c9, $cb
	db $47, $c2, $ab, $1a, $cd, $96, $12, $cd, $4a, $35, $cd, $8a, $12, $cd, $98, $23
	db $cd, $c8, $6d, $cd, $f7, $71, $cd, $7b, $74, $cd, $84, $12, $cd, $7d, $3d, $cd
	db $0e, $42, $cd, $cd, $0b, $c3, $ba, $17, $16, $c0, $fa, $c1, $c9, $c7, $0c, $4c
	db $0c, $4c, $1a, $59, $c0, $6a, $2d, $7c, $fa, $c1, $c9, $c7, $9b, $3d, $9b, $3d
	db $29, $3e, $67, $3e, $7b, $3e, $cd, $84, $12, $cd, $4b, $00, $e5, $3d, $ec, $3d
	db $f2, $3d, $0b, $3e, $1c, $3e, $cd, $dc, $23, $16, $c0, $cd, $57, $05, $af, $ea
	db $99, $cd, $cd, $9e, $1a, $c5, $fa, $9a, $cd, $32, $fa, $99, $cd, $77, $cd, $b0
	db $17, $af, $ea, $9a, $cd, $c1, $cd, $97, $1a, $11, $08, $c0, $1a, $fe, $02, $c0
	db $21, $07, $c0, $cb, $ae, $fa, $14, $c0, $fe, $70, $38, $02, $cb, $ee, $af, $c9
	db $cd, $ab, $3d, $c0, $c3, $e8, $3c, $cd, $ab, $3d, $c3, $0e, $42, $cd, $7b, $3b
	db $ca, $e8, $3c, $cd, $ab, $3d, $21, $01, $3e, $c3, $a7, $3c, $50, $51, $50, $51
	db $50, $51, $50, $51, $6f, $67, $3e, $10, $ea, $9a, $cd, $cd, $b4, $3d, $fa, $0f
	db $c0, $fe, $34, $d0, $c3, $e8, $3c, $06, $8d, $cd, $43, $20, $01, $37, $05, $cd
	db $96, $11, $18, $34, $cd, $84, $12, $cd, $4b, $00, $e5, $3d, $f2, $3d, $53, $3e
	db $3e, $12, $ea, $9a, $cd, $cd, $b4, $3d, $fa, $01, $c0, $fe, $01, $c0, $16, $c0
	db $cd, $57, $05, $3e, $01, $ea, $9a, $cd, $cd, $b4, $3d, $c3, $e8, $3c, $06, $c9
	db $cd, $43, $20, $3e, $5b, $cd, $10, $05, $af, $ea, $c0, $c9, $21, $8b, $c9, $cb
	db $8e, $c9, $cd, $84, $12, $cd, $4b, $00, $e5, $3d, $f2, $3d, $73, $3e, $21, $0c
	db $1f, $cd, $42, $20, $18, $dd, $06, $03, $cd, $41, $2e, $20, $11, $cd, $84, $12
	db $cd, $0c, $7b, $cd, $4b, $00, $e5, $3d, $f2, $3d, $35, $3e, $58, $3e, $cd, $4b
	db $00, $e5, $3d, $b4, $3e, $cb, $3e, $e4, $3e, $66, $3f, $cb, $3e, $e4, $3e, $22
	db $3f, $2c, $3f, $33, $3f, $50, $3f, $22, $3f, $22, $3f, $66, $3f, $5a, $3f, $cd
	db $7b, $3b, $fa, $98, $cd, $fe, $03, $c0, $3c, $ea, $98, $cd, $af, $ea, $81, $cd
	db $01, $0b, $02, $c3, $77, $3f, $cd, $66, $3f, $c0, $af, $ea, $b7, $cc, $21, $d9
	db $3e, $c3, $1e, $09, $66, $9c, $37, $38, $39, $00, $00, $00, $23, $24, $ff, $cd
	db $85, $3f, $fa, $b7, $cc, $a7, $28, $11, $fa, $90, $cd, $fe, $03, $01, $0f, $04
	db $ca, $77, $3f, $01, $10, $07, $c3, $77, $3f, $21, $f5, $c9, $7e, $fe, $05, $38
	db $12, $21, $80, $cb, $36, $f4, $2c, $36, $01, $3e, $08, $ea, $90, $cd, $3e, $20
	db $c3, $a1, $0b, $01, $0e, $0c, $c3, $77, $3f, $66, $9c, $6b, $9c, $cd, $66, $3f
	db $c0, $01, $0c, $0d, $c3, $77, $3f, $cd, $9b, $0b, $c0, $c3, $e8, $3c, $21, $80
	db $cb, $7e, $d6, $01, $22, $7e, $de, $00, $77, $38, $08, $3e, $01, $01, $cb, $9f
	db $c3, $13, $0c, $3e, $20, $cd, $a1, $0b, $c3, $e8, $3c, $cd, $9b, $0b, $c0, $01
	db $0d, $0b, $c3, $77, $3f, $cd, $7b, $3b, $c0, $06, $ec, $cd, $43, $20, $c3, $5d
	db $3e, $cd, $3d, $09, $f5, $21, $01, $3e, $cd, $a7, $3c, $f1, $c0, $cd, $e8, $3c
	db $af, $c9, $78, $ea, $90, $cd, $79, $21, $ce, $55, $cd, $5a, $09, $c3, $98, $0b
	db $21, $1e, $3f, $cd, $41, $05, $3e, $0f, $c2, $15, $05, $cd, $90, $12, $cd, $f1
	db $68, $c1, $c9, $3e, $0a, $ea, $c0, $c9, $21, $8b, $c9, $cb, $ce, $c9, $3e, $06
	db $ea, $82, $cd, $d5, $21, $ce, $55, $cd, $57, $09, $d1, $c3, $f0, $3b, $cd, $e4
	db $16, $21, $e9, $76, $cd, $b6, $04, $7e, $e6, $0f, $ea, $8d, $ca, $2a, $cb, $37
	db $e6, $0f, $ea, $86, $ca, $06, $01, $fa, $94, $ca, $cb, $47, $28, $02, $06, $10
	db $5e, $23, $16, $d7, $2a, $fe, $ff, $c8, $fe, $fe, $28, $f4, $12, $78, $cd, $40
	db $16, $18, $f1, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
