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


	; unused bytes nothing reaches (a leftover code fragment)
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


	; unused bytes nothing reaches (a leftover code fragment)
	db $01, $1a, $18, $b8

;@ def LCDCInterrupt()
;@ path: system/vectors
;@ Interrupt vector $48 (LCD STAT).
;@ test: skip interrupt vector
LCDCInterrupt::
;> return LCDInterruptHandler()
	jp LCDInterruptHandler


	; unused bytes nothing reaches (a leftover code fragment)
	db $fa, $90, $cd, $18, $b0

;@ def TimerOverflowInterrupt()
;@ path: system/vectors
;@ Interrupt vector $50: the timer interrupt is not used, it just returns.
;@ test: skip interrupt vector
TimerOverflowInterrupt::
;> return
	reti


	; unused bytes nothing reaches (a leftover code fragment)
	db $fa, $02, $c0, $b7, $c9, $ff, $ff

;@ def SerialTransferCompleteInterrupt()
;@ path: system/vectors
;@ Interrupt vector $58 (link cable byte done). The bytes after it are leftovers
;@ of an older VBlank handler that nothing reaches.
;@ test: skip interrupt vector
SerialTransferCompleteInterrupt::
;> return SerialInterruptEntry()
	jp SerialInterruptEntry


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


;@ asset: logo
;@ The Nintendo logo. The boot ROM scrolls it down the screen and only starts the cartridge
;@ if these 48 bytes match its own copy.
;@ path: system/header
HeaderLogo::
	db $ce, $ed, $66, $66, $cc, $0d, $00, $0b, $03, $73, $00, $83, $00, $0c, $00, $0d
	db $00, $08, $11, $1f, $88, $89, $00, $0e, $dc, $cc, $6e, $e6, $dd, $dd, $d9, $99
	db $bb, $bb, $67, $63, $6e, $0e, $ec, $cc, $dd, $dc, $99, $9f, $bb, $b9, $33, $3e

;@ asset: header range=$0100-$014F
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
;> fill(addr(wGameMode), 0, 4)                  # mode, step and two mode variables
	ld hl, wGameMode
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
;> wMessageSpeed = 4
	ld a, $04
	ld [wMessageSpeed], a
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
	ld [rRAMG + $100], a
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
;>     SGBTransfer(0x0C, 0x0803, 0x800)   # border tiles: packet $0C, bank $08 entry 3, $800 bytes
	ld a, $0c
	ld de, $0803
	ld bc, $0800
	call SGBTransfer
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     SGBTransferCompressed(0x0D, 0x0804)  # border map and palettes: packet $0D, bank $08 entry 4
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
;>     wLoadedGfxSet = 0xFF
	ld a, $ff
	ld [wLoadedGfxSet], a

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
;>     wTextBoxLines = 0
	ld [wTextBoxLines], a
;>     wTextBoxLineLength = 0
	ld [wTextBoxLineLength], a
;>     wLinkTimeout = 0
	ld [wLinkTimeout], a
	ld [wLinkTimeout + 1], a
;>     wNameCleared = 0
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
;>     fill(addr(wShakeY), 0, 4)                # no screen shake
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
;> TitleModeInit()
	ld hl, far_TitleModeInit
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
;> InitBattleMode()
	ld hl, far_InitBattleMode
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
;> EndingInit()
	ld hl, far_EndingInit
	rst $10
	ret


;@ def InitGameMode05()
;@ path: system/modes
;@ Starts game mode $05 (bank $5F).
;@ test: skip calls a routine in another bank
InitGameMode05::
;> AnimViewerInit()
	ld hl, far_AnimViewerInit
	rst $10
	ret


;@ def InitGameMode06()
;@ path: system/modes
;@ Starts game mode $06: entry 0 of bank $18.
;@ test: skip calls a routine in another bank
InitGameMode06::
;> VSResultInit()
	ld hl, far_VSResultInit
	rst $10
	ret

;@ def InitGameMode07()
;@ path: system/modes
;@ Starts game mode $07, a debug menu: entry $0D of bank $55.
;@ test: skip calls a routine in another bank
InitGameMode07::
;> DebugMenuInit()
	ld hl, far_DebugMenuInit
	rst $10
	ret

;@ def InitGameMode08()
;@ path: system/modes
;@ Starts game mode $08, the debug monster sprite viewer (bank $59).
;@ test: skip calls a routine in another bank
InitGameMode08::
;> SpriteViewerInit()
	ld hl, far_SpriteViewerInit
	rst $10
	ret

;@ def InitGameMode09()
;@ path: system/modes
;@ Starts game mode $09, the battle screen tutorial (bank $59).
;@ test: skip calls a routine in another bank
InitGameMode09::
;> BattleTutorInit()
	ld hl, far_BattleTutorInit
	rst $10
	ret

;@ def InitGameMode0A()
;@ path: system/modes
;@ Starts game mode $0A, the battle command tutorial (bank $59).
;@ test: skip calls a routine in another bank
InitGameMode0A::
;> CommandTutorInit()
	ld hl, far_CommandTutorInit
	rst $10
	ret

;@ def InitGameMode0B()
;@ path: system/modes
;@ Starts game mode $0B: entry 3 of bank $56.
;@ test: skip calls a routine in another bank
InitGameMode0B::
;> MsgViewerInit()
	ld hl, far_MsgViewerInit
	rst $10
	ret

;@ def InitGameMode0C()
;@ path: system/modes
;@ Starts game mode $0C, a debug menu: entry 7 of bank $56.
;@ test: skip calls a routine in another bank
InitGameMode0C::
;> TileViewerInit()
	ld hl, far_TileViewerInit
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
;>     if (wJoyHeld & 0x0F) == 0x0F:        # A+B+Select+Start
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

;>         if (wJoyHeld & 3) == 3 and False:   # A+B held: debug menus, switched off (the jump always skips them)
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
;>                 wDebugSavedMode[2] = wOpeningScene
	ld a, [wOpeningScene]
	ld [hli], a
;>                 wDebugSavedMode[3] = wOpeningLogo
	ld a, [wOpeningLogo]
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
;>                 wDebugSavedMode[2] = wOpeningScene
	ld a, [wOpeningScene]
	ld [hli], a
;>                 wDebugSavedMode[3] = wOpeningLogo
	ld a, [wOpeningLogo]
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
;> TitleModeUpdate()
	ld hl, far_TitleModeUpdate
	rst $10
	ret


;@ def UpdateGameMode01()
;@ path: system/modes
;@ Per-frame routine of game mode $01, the field: entry 1 of bank $01.
;@ test: skip calls a routine in another bank
UpdateGameMode01::
;> FieldFrame()
	ld hl, far_FieldFrame
	rst $10
	ret


;@ def UpdateGameMode02()
;@ path: system/modes
;@ Per-frame routine of game mode $02 (bank $50).
;@ test: skip calls a routine in another bank
UpdateGameMode02::
;> BattleFrame()
	ld hl, far_BattleFrame
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
;> EndingUpdate()
	ld hl, far_EndingUpdate
	rst $10
	ret


;@ def UpdateGameMode05()
;@ path: system/modes
;@ Per-frame routine of game mode $05 (bank $5F).
;@ test: skip calls a routine in another bank
UpdateGameMode05::
;> AnimViewerUpdate()
	ld hl, far_AnimViewerUpdate
	rst $10
	ret


;@ def UpdateGameMode06()
;@ path: system/modes
;@ Per-frame routine of game mode $06 (bank $18).
;@ test: skip calls a routine in another bank
UpdateGameMode06::
;> VSResultUpdate()
	ld hl, far_VSResultUpdate
	rst $10
	ret


;@ def UpdateGameMode07()
;@ path: system/modes
;@ Per-frame routine of game mode $07, a debug menu: entry $0E of bank $55.
;@ test: skip calls a routine in another bank
UpdateGameMode07::
;> DebugMenuUpdate()
	ld hl, far_DebugMenuUpdate
	rst $10
	ret

;@ def UpdateGameMode08()
;@ path: system/modes
;@ Per-frame routine of game mode $08, the debug monster sprite viewer (bank $59).
;@ test: skip calls a routine in another bank
UpdateGameMode08::
;> SpriteViewerUpdate()
	ld hl, far_SpriteViewerUpdate
	rst $10
	ret

;@ def UpdateGameMode09()
;@ path: system/modes
;@ Per-frame routine of game mode $09, the battle screen tutorial (bank $59).
;@ test: skip calls a routine in another bank
UpdateGameMode09::
;> BattleTutorUpdate()
	ld hl, far_BattleTutorUpdate
	rst $10
	ret

;@ def UpdateGameMode0A()
;@ path: system/modes
;@ Per-frame routine of game mode $0A, the battle command tutorial (bank $59).
;@ test: skip calls a routine in another bank
UpdateGameMode0A::
;> CommandTutorUpdate()
	ld hl, far_CommandTutorUpdate
	rst $10
	ret

;@ def UpdateGameMode0B()
;@ path: system/modes
;@ Per-frame routine of game mode $0B: entry 4 of bank $56.
;@ test: skip calls a routine in another bank
UpdateGameMode0B::
;> MsgViewerUpdate()
	ld hl, far_MsgViewerUpdate
	rst $10
	ret

;@ def UpdateGameMode0C()
;@ path: system/modes
;@ Per-frame routine of game mode $0C, a debug menu: entry 8 of bank $56.
;@ test: skip calls a routine in another bank
UpdateGameMode0C::
;> TileViewerUpdate()
	ld hl, far_TileViewerUpdate
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
;@ test: skip CopyMapUpdate writes VRAM bank 1
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
;> ClearTextBoxTiles()                         # clear the text box tiles
	push de
	ld hl, far_ClearTextBoxTiles
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
;@ test: skip reads the switched-in bank
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
;@   letter, $E0-$FF are control codes (run by RunTextControlCode), anything else is a
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
;>         WriteVRAM(tile, MapAdvanceTiles(TextBoxMapAddress(0x60), 9))
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
;>             WriteVRAM(yes_tile, pos)
	pop bc
	ld a, c
	call WriteVRAM
;>             pos = MapAdvanceTiles(ScreenMapAddress(0x160), 15)   # screen row 11, column 15
	push bc
	ld hl, $0160
	call ScreenMapAddress
	ld b, $0f
	call MapAdvanceTiles
;>             WriteVRAM(no_tile, pos)
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
;>                         WriteVRAM(mem[src], pos)     # pos starts at row_addr, src at wTilemapBuffer
	ld a, [de]
	call WriteVRAM
;>                         next_col = (pos + 1) & 0x1F
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;>                         pos = (pos & ~0x1F) | next_col   # wraps within the map row
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
;>@ctl2             RunTextControlCode(c)                # runs the control code
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
	ld hl, far_RunTextControlCode
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
;> WriteVRAM(0xEE, pos)                   # box background tile
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
;@ `line_length` tiles; wTextBoxLines holds the line count, wTextBoxLineLength the line length) and clears them.
;@ test: skip calls a routine in another bank
SetUpTextBox::
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = line_length
	ld a, d
	ld [wTextBoxLineLength], a
;> ClearTextBoxTiles()                         # clear the tiles
	ld hl, far_ClearTextBoxTiles
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
;@ test: divisor = rand(1, 255)
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
;@ test: skip waits for the LCD
;@ path: text/box
;@ Fills the text box's area of the BG map at `box` with the box's letter tiles
;@ (numbered from wTextTiles / 16 on): wTextBoxLines lines of wTextBoxLineLength
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
;> lines = wTextBoxLines
	ld a, [wTextBoxLines]
	ld c, a
;> per_line = wTextBoxLineLength
	ld a, [wTextBoxLineLength]
	ld b, a
;> pos = wTextBoxMap
	ld a, [wTextBoxMap]
	ld l, a
	ld a, [wTextBoxMap + 1]
	ld h, a

.line
;>@line for _ in range(lines):
	push bc

.tile
;>@tile     for _ in range(per_line):
;>         WriteVRAM(lo(tile), pos)
	ld a, e
	call WriteVRAM
;>         pos = MapNextTile(pos)
	call MapNextTile
;>         tile += 1
	inc e
;=@tile
	dec b
	jr nz, .tile

;>     pos = TextBoxMapAddress(0x40)     # two map rows below the box's top
	pop bc
	ld hl, $0040
	call TextBoxMapAddress
;=@line
	dec c
	jr nz, .line

	ret


;@ def MapAdvanceTiles(pos: hl, count: b) -> hl
;@ path: gfx/tilemap
;@ Moves a BG map address `count` tiles to the right, wrapping within the row.
MapAdvanceTiles::
;> for _ in range(count):
;>     pos = MapNextTile(pos)
	call MapNextTile
	dec b
	jr nz, MapAdvanceTiles

;> return pos
	ret


;@ def MapNextTile(pos: hl) -> hl
;@ path: gfx/tilemap
;@ The BG map address one tile to the right of `pos`, wrapping from column 31
;@ back to column 0 of the same row. Keeps a.
MapNextTile::
;> col = (lo(pos) + 1) & 0x1F
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;> pos = (pos & 0xFFE0) | col
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
;> return pos
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


;@ def ClearMapTiles(pos: hl, count: b) -> hl
;@ path: gfx/tilemap
;@ Writes `count` blank tiles ($E0) into the BG map from `pos` to the right,
;@ wrapping within the row.
;@ test: skip waits for the LCD
ClearMapTiles::
;> for _ in range(count):
;>     WriteVRAM(0xE0, pos)
	ld a, $e0
	call WriteVRAM
;>     pos = MapNextTile(pos)
	call MapNextTile
	dec b
	jr nz, ClearMapTiles

;> return pos
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


;@ def ReadTextBankByte(pos: hl) -> a
;@ path: text/printer
;@ Reads the byte at `pos` in the text's bank (wTextBank).
;@ test: skip switches banks
ReadTextBankByte::
;> saved = rom_bank()
	ld a, [$4000]
	push af
;> set_rom_bank(wTextBank)
	ld a, [wTextBank]
	ld [$2100], a
;> value = mem[pos]
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
;> pos = row * 4                         # 32 tiles per row of 8 pixels
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
;> pos = 0x9800 + ((pos + col) & 0x3FF)
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

;> tile = mem[pos]
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
;> found = (rP1 & 3) != 3
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
;>     found = (pad & 3) != 3               # the SGB switched to pad 2
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
;> ApplyDMGPalettes()                   # Game Boy Color palettes
	ld hl, far_ApplyDMGPalettes
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


	; unused bytes nothing reaches (a leftover code fragment)
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
;> fill(addr(hScrollX), 0, 8)
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
;@ test: hOAMCount = rand(0, 40)
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

;>         dest = WriteVRAMInc(byte, dest)
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
;>             dest = WriteVRAMInc(value, dest)
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
;>@f fill(addr(wFadeLevel), 0, 5)                 # level, speed, timer, colour offset
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
;>         StartMusicFadeOut(wFadeSpeed)
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
;>             StartMusicFadeOut(wFadeSpeed)
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
;>             StartMusicFadeOut(wFadeSpeed)
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


	; unused bytes nothing reaches (a leftover code fragment)
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
;@ test: wFadeLevel = rand(0, 32)
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
;@ test: level = rand(0, 32)
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
;> UpdateCGBFade()
	ld hl, far_UpdateCGBFade
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
;>     FadeDMGPaletteToWhite(wFadePalettes[0], addr(wBGP))
	ld a, [wFadeType]
	bit 0, a
	ld a, [wFadePalettes]
	ld hl, wBGP
	call nz, FadeDMGPaletteToWhite
;> if wFadeType & 0x02:
;>     FadeDMGPaletteToWhite(wFadePalettes[1], addr(wOBP0))
	ld a, [wFadeType]
	bit 1, a
	ld a, [wFadePalettes + 1]
	inc hl
	call nz, FadeDMGPaletteToWhite
;> if wFadeType & 0x04:
;>     FadeDMGPaletteToWhite(wFadePalettes[2], addr(wOBP1))
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
;>     palette = ((palette >> 2) | (palette << 6)) & 0xFF; out = FadeDMGShadeToWhite(palette, level, out)   # (FadeDMGShadeToWhiteNext)
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
;> palette = ((palette >> 2) | (palette << 6)) & 0xFF   # rotate right by 2
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
;> return (((out | value) >> 2) | ((out | value) << 6)) & 0xFF   # out | value, rotated right by 2
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
;>     FadeDMGPaletteToBlack(wFadePalettes[0], addr(wBGP))
	ld a, [wFadeType]
	bit 0, a
	ld a, [wFadePalettes]
	ld hl, wBGP
	call nz, FadeDMGPaletteToBlack
;> if wFadeType & 0x02:
;>     FadeDMGPaletteToBlack(wFadePalettes[1], addr(wOBP0))
	ld a, [wFadeType]
	bit 1, a
	ld a, [wFadePalettes + 1]
	inc hl
	call nz, FadeDMGPaletteToBlack
;> if wFadeType & 0x04:
;>     FadeDMGPaletteToBlack(wFadePalettes[2], addr(wOBP1))
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
;>     palette = ((palette >> 2) | (palette << 6)) & 0xFF; out = FadeDMGShadeToBlack(palette, level, out)   # (FadeDMGShadeToBlackNext)
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
;> palette = ((palette >> 2) | (palette << 6)) & 0xFF   # rotate right by 2
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
;> return (((out | value) >> 2) | ((out | value) << 6)) & 0xFF   # out | value, rotated right by 2
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

;@ def WriteVRAM(value: a, pos: hl)
;@ path: system/lcd
;@ Writes `value` to VRAM at `pos` as soon as VRAM is accessible (interrupts
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

;> mem[pos] = value
	pop af
	ld [hl], a
;> enable_interrupts()
	ei
	ret


;@ def WriteVRAMInc(value: a, pos: hl) -> hl
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

;> mem[pos] = value
	pop af
	ld [hli], a
;> enable_interrupts()
	ei
;> return pos + 1
	ret


;@ def WriteVRAMAttr(value: a, pos: hl)
;@ path: system/lcd
;@ On a Game Boy Color, writes the BG map attribute `value` (VRAM bank 1) at
;@ `pos` once VRAM is accessible; does nothing on other models.
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
;> mem[pos] = value
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
;@ $44, $61 use StartSounds3; all others StartSoundChannel. Part $63 is also the
;@ third (noise) part of sound $61; asked for directly, it starts parts $63 and
;@ $64. Keeps all registers.
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

;@ def StartMusicFadeOut(delay: a)
;@ path: sound/fade
;@ Starts fading the music out: every `delay` frames (half as many on a plain
;@ Game Boy or Game Boy Color) the master volume drops one step, for at most 8
;@ steps. Nothing starts (and a running fade is cancelled) while a new map
;@ loads, for a delay of 0 or >= $80, or when the master volume is already 0
;@ or uses the cartridge's Vin input.
StartMusicFadeOut::
;> if wMapLoadState or delay & 0x80 or delay == 0:
	ld b, a
	ld a, [wMapLoadState]
	or a
	jr nz, .cancel

;>@cancel     wMusicFadeDelay = 0
;>@cancel     return
	ld a, b
	bit 7, a
	jr nz, .cancel

	or a
	jr z, .cancel

;> wMusicFadeDelay = delay
	ld [wMusicFadeDelay], a
;> if not wOnSGB:
	ld a, [wOnSGB]
	or a
	jr nz, .checkVolume

;>     wMusicFadeDelay >>= 1             # (sra; the delay is below $80)
	ld a, [wMusicFadeDelay]
	sra a
	ld [wMusicFadeDelay], a

.checkVolume
;> vol = rNR50
	ldh a, [rNR50]
;> if vol & 0x80 or vol & 0x08 or vol == 0:
	bit 7, a
	jr nz, .cancel

	bit 3, a
	jr nz, .cancel

;>@cancel     wMusicFadeDelay = 0
;>@cancel     return
	or a
	jr z, .cancel

;> wMusicFadeTimer = wMusicFadeDelay
	ld a, [wMusicFadeDelay]
	ld [wMusicFadeTimer], a
;> wMusicFadeSteps = 8
	ld a, $08
	ld [wMusicFadeSteps], a
;> wMusicFadeVolume = rNR50
	ldh a, [rNR50]
	ld [wMusicFadeVolume], a
	ret


.cancel
;=@cancel
	xor a
	ld [wMusicFadeDelay], a
	ret


;@ def UpdateMusicFadeOut()
;@ path: sound/fade
;@ Runs the music fade-out once per frame: counts the frames down, then lowers
;@ both master volumes (left and right, 0-7 each) by one. When the volume
;@ reaches 0 the sound engine is reset (not during a link session); after the
;@ last step, or if the fade was cancelled, wMusicFadeDelay goes back to 0.
UpdateMusicFadeOut::
;> if wMapLoadState or wMusicFadeDelay & 0x80:
	ld a, [wMapLoadState]
	or a
	jr nz, .stop

	ld a, [wMusicFadeDelay]
	bit 7, a
;>@stop     wMusicFadeDelay = 0
;>@stop     return
	jr nz, .stop

;> if wMusicFadeDelay == 0:
;>     return                             # no fade running
	or a
	ret z

;> if wMusicFadeTimer:
	ld a, [wMusicFadeTimer]
	or a
	jr z, .step

;>     wMusicFadeTimer -= 1
;>     return
	dec a
	ld [wMusicFadeTimer], a
	ret


.step
;> vol = rNR50
	ldh a, [rNR50]
;> if (vol & 0x88) == 0x88 or wMusicFadeVolume == 0:
	and $88
	cp $88
	jr z, .stop

	ld a, [wMusicFadeVolume]
	or a
;>@stop     wMusicFadeDelay = 0
;>@stop     return
	jr z, .stop

;> right = wMusicFadeVolume & 0x0F
	ld b, a
	and $0f
	ld d, a
;> left = wMusicFadeVolume >> 4
	ld a, b
	swap a
	and $0f
	ld c, a
;> if not left & 0x08 and left:
	bit 3, c
	jr nz, .leftDone

	ld a, c
	or a
	jr z, .leftDone

;>     left -= 1
	dec c

.leftDone
;> if not right & 0x08 and right:
	bit 3, d
	jr nz, .rightDone

	ld a, d
	or a
	jr z, .rightDone

;>     right -= 1
	dec d

.rightDone
;> vol = left << 4 | right
	ld a, c
	swap a
	or d
;> rNR50 = vol
	ldh [rNR50], a
;> wMusicFadeVolume = vol
	ld [wMusicFadeVolume], a
;> if vol and wMusicFadeSteps:
	or a
	jr z, .silent

	ld a, [wMusicFadeSteps]
	or a
	jr z, .stop

;>     wMusicFadeSteps -= 1
	dec a
	ld [wMusicFadeSteps], a
;>     wMusicFadeTimer = wMusicFadeDelay
;>     return
	ld a, [wMusicFadeDelay]
	ld [wMusicFadeTimer], a
	ret


.silent
;> if vol == 0 and not wLinkActive:
	ld a, [wLinkActive]
	or a
	jr nz, .stop

;>     disable_interrupts()
	di
;>     InitSound()                        # the music is off: reset the sound engine
	call InitSound
;>     enable_interrupts()
	ei

.stop
;=@stop
;> wMusicFadeDelay = 0
	xor a
	ld [wMusicFadeDelay], a
	ret


;@ def LoadSGBBorder(border: a)
;@ path: system/sgb
;@ Sends one of the four Super Game Boy borders (unless it is already the one in
;@ wLoadedGfxSet): two halves of $1000 bytes of border tiles (CHR_TRN, packets
;@ $10 and $11) and the compressed border map and colors (PCT_TRN, packet $0F).
;@ The data is named by bank and far-table entry: border 0 = 08:05, 08:06, 08:07;
;@ 1 = 08:08, 2C:00, 08:09; 2 = 2C:01, 32:11, 32:12; 3 = 2E:24, 2E:25, 32:13.
;@ On other hardware the transfers do nothing. The bytes after it are an unused
;@ copy of SetSyncedBankSwitch.
;@ test: skip talks to the Super Game Boy
LoadSGBBorder::
;> if border == wLoadedGfxSet:
;>     return
	ld hl, wLoadedGfxSet
	cp [hl]
	ret z

;> wLoadedGfxSet = border
	ld [hl], a
;> if border == 0:
	cp $00
	jr nz, .not0

;>     SGBTransfer(0x10, 0x0805, 0x1000)  # border tiles, first half
	ld a, $10
	ld de, $0805
	ld bc, $1000
	call SGBTransfer
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     SGBTransfer(0x11, 0x0806, 0x1000)  # second half
	ld a, $11
	ld de, $0806
	ld bc, $1000
	call SGBTransfer
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     SGBTransferCompressed(0x0F, 0x0807)   # map and colors
	ld a, $0f
	ld de, $0807
	call SGBTransferCompressed
	jr .done

.not0
;> elif border == 1:
	cp $01
	jr nz, .not1

;>     SGBTransfer(0x10, 0x0808, 0x1000)
	ld a, $10
	ld de, $0808
	ld bc, $1000
	call SGBTransfer
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     SGBTransfer(0x11, 0x2C00, 0x1000)
	ld a, $11
	ld de, $2c00
	ld bc, $1000
	call SGBTransfer
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     SGBTransferCompressed(0x0F, 0x0809)
	ld a, $0f
	ld de, $0809
	call SGBTransferCompressed
	jr .done

.not1
;> elif border == 2:
	cp $02
	jr nz, .not2

;>     SGBTransfer(0x10, 0x2C01, 0x1000)
	ld a, $10
	ld de, $2c01
	ld bc, $1000
	call SGBTransfer
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     SGBTransfer(0x11, 0x3211, 0x1000)
	ld a, $11
	ld de, $3211
	ld bc, $1000
	call SGBTransfer
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     SGBTransferCompressed(0x0F, 0x3212)
	ld a, $0f
	ld de, $3212
	call SGBTransferCompressed
	jr .done

.not2
;> elif border == 3:
	cp $03
	jr nz, .done

;>     SGBTransfer(0x10, 0x2E24, 0x1000)
	ld a, $10
	ld de, $2e24
	ld bc, $1000
	call SGBTransfer
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     SGBTransfer(0x11, 0x2E25, 0x1000)
	ld a, $11
	ld de, $2e25
	ld bc, $1000
	call SGBTransfer
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     SGBTransferCompressed(0x0F, 0x3213)
	ld a, $0f
	ld de, $3213
	call SGBTransferCompressed
	jr .done

.done
	ret


	db $78, $ea, $26, $de, $79, $ea, $27, $de, $af, $ea, $28, $de, $c9

;@ def CloseLink()
;@ path: link/serial
;@ Ends a link cable session: with only the serial interrupt enabled, both
;@ Game Boys exchange the closing byte $F5 (the one that does not drive the
;@ clock waits a moment first, and the byte is sent again if the answer was not
;@ $F5); the clock-driving side then sends $F8. Afterwards the link transfer
;@ phase and all pad variables ($C842-$C84F) are cleared, also without a link.
;@ test: skip talks over the link cable
CloseLink::
;> if wLinkActive:
	ld a, [wLinkActive]
	or a
	jr z, .clear

;>     SetInterrupts(0x08)                # serial only
	ld a, $08
	call SetInterrupts
;>     wSerialLock = (wSerialLock | 0x80) & ~0x40
	ld a, [wSerialLock]
	set 7, a
	res 6, a
	ld [wSerialLock], a
;>     if not wLinkFlags & 0x02:
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, .send

;>@wait         for _ in range(0x6000):     # a short pause
	ld hl, $6000

.wait
;>             pass
	dec hl
	ld a, h
	or l
;=@wait
	jr nz, .wait

.send
;>     enable_interrupts()
	ei
;>     LinkSendCloseByte()
	call LinkSendCloseByte
;>     wait_serial()
	call WaitSerialTransfer
;>     if rSB != 0xF5:
;>         LinkSendCloseByte()
	ldh a, [rSB]
	cp $f5
	call nz, LinkSendCloseByte
;>     disable_interrupts()
	di
;>     wSerialLock &= ~0x80
	ld a, [wSerialLock]
	res 7, a
	ld [wSerialLock], a
;>     wSerialLock &= ~0x03
	ld a, [wSerialLock]
	res 0, a
	res 1, a
	ld [wSerialLock], a
;>     if wLinkFlags & 0x02:
;>         SerialSendSlave(0xF8)
	ld a, [wLinkFlags]
	bit 1, a
	ld a, $f8
	call nz, SerialSendSlave

.clear
;> wLinkPhase = 0
	xor a
	ld [wLinkPhase], a
;> fill(addr(wJoyHeld), 0, 14)                  # all pad state
	ld hl, wJoyHeld
	ld b, $0e

.fill
	ld [hli], a
	dec b
	jr nz, .fill

	ret


;@ def LinkSendCloseByte()
;@ path: link/serial
;@ Sends $F5 over the link cable (waiting for the partner's clock when wLinkFlags
;@ bit 1 is set, else driving it) and waits until the serial interrupt has
;@ answered (wSerialLock bit 6).
;@ test: skip talks over the link cable
LinkSendCloseByte::
;> if wLinkFlags & 0x02:
;>     SerialSendSlave(0xF5)
	ld a, [wLinkFlags]
	bit 1, a
	ld a, $f5
	call nz, SerialSendSlave
;> else:
;>     SerialSendMaster(0xF5)
	ld a, [wLinkFlags]
	bit 1, a
	ld a, $f5
	call z, SerialSendMaster

.wait
;> while not wSerialLock & 0x40:
;>     wait_serial()
	ld a, [wSerialLock]
	bit 6, a
	jr z, .wait

	ret


;@ def Multiply(x: a, y: c) -> hl
;@ path: system/math
;@ 8 x 8 bit multiplication: returns x * y in hl (shift and add, four bits here
;@ and four more by running on into MultiplyNibble).
Multiply::
;> return x * y
	ld b, $00
	ld h, b
	ld l, b
	call MultiplyNibble

;@ def MultiplyNibble(x: a, y: bc, product: hl) -> hl
;@ path: system/math
;@ One half of Multiply: for the low four bits of x adds y to product, doubling
;@ y each time; x comes back rotated right by four.
MultiplyNibble::
;>@bits for i in range(4):
;>     if x >> i & 1:
	rrca
	jr nc, .bit1

;>         product = u16(product + (y << i))
	add hl, bc

.bit1
;=@bits
	sla c
	rl b
	rrca
	jr nc, .bit2

;=@bits
	add hl, bc

.bit2
;=@bits
	sla c
	rl b
	rrca
	jr nc, .bit3

;=@bits
	add hl, bc

.bit3
;=@bits
	sla c
	rl b
	rrca
	jr nc, .bit4

;=@bits
	add hl, bc

.bit4
;=@bits
	sla c
	rl b
;> return product
	ret


;@ def Multiply24(x: a, y: bc) -> (e, hl)
;@ path: system/math
;@ 8 x 16 bit multiplication: x * y as a 24-bit number, high byte in e, low
;@ word in hl.
Multiply24::
;> high = Multiply(x, hi(y))
	push af
	push bc
	ld c, b
	call Multiply
;> low = Multiply(x, lo(y))
	pop bc
	pop af
	push hl
	call Multiply
;> product = (high << 8) + low
	pop bc
	ld a, c
	add h
	ld h, a
	ld a, b
	adc $00
;> return product >> 16, product & 0xFFFF
	ld e, a
	ret


;@ def Divide8(n: b, d: a) -> (b, a)
;@ path: system/math
;@ 8-bit division: returns n // d in b and the remainder in a (bit by bit).
;@ test: d = rng.randint(1, 255)
Divide8::
;>@q return n // d, n % d
	ld d, $08
	ld e, a
	xor a

.loop
;=@q
	sla b
	rla
	jr c, .sub

	cp e
	jr c, .next

.sub
;=@q
	sub e
	inc b

.next
;=@q
	dec d
	jr nz, .loop

	ret


;@ def Divide16(n: hl, d: a) -> (hl, a)
;@ path: system/math
;@ 16 by 8 bit division: returns n // d in hl and the remainder in a.
;@ test: d = rng.randint(1, 255)
Divide16::
;>@q return n // d, n % d
	ld d, $10
	ld e, a
	xor a

.loop
;=@q
	add hl, hl
	rla
	jr c, .sub

	cp e
	jr c, .next

.sub
;=@q
	sub e
	inc l

.next
;=@q
	dec d
	jr nz, .loop

	ret


;@ def Divide24(n_high: e, n: hl, d: a) -> (e, hl, a)
;@ path: system/math
;@ 24 by 8 bit division of e:hl: returns the quotient in e:hl and the
;@ remainder in a.
;@ test: d = rng.randint(1, 255)
Divide24::
;>@q q = (n_high << 16 | n) // d; r = (n_high << 16 | n) % d
	ld d, $18
	ld b, a
	xor a

.loop
;=@q
	add hl, hl
	rl e
	rla
	jr c, .sub

	cp b
	jr c, .next

.sub
;=@q
	sub b
	inc l

.next
;=@q
	dec d
	jr nz, .loop

;> return q >> 16, q & 0xFFFF, r
	ret


;@ def GetCollisionAt()
;@ path: field/collision
;@ Tests the map spot hTestX, hTestY: hTestResult = $FF (walkable) when it lies
;@ outside the map, else $0F (solid) while the screen scrolls or when the spot
;@ is not on the visible screen. On screen the BG tile there is looked up in
;@ wSavedTilemap (the tile goes to hTestTile): tiles from the map's first solid
;@ tile on (byte 6 of its MapInfo / GateFloorMapInfo record) are solid. Leaves
;@ hTestX, hTestY relative to the screen.
GetCollisionAt::
;> hTestResult = 0xFF
	ld a, $ff
	ldh [hTestResult], a
;> if hTestX & 0x8000 or hTestY & 0x8000:
;>     return                             # left of / above the map
	ldh a, [hTestX + 1]
	bit 7, a
	ret nz

	ldh a, [hTestY + 1]
	bit 7, a
	ret nz

;>@w if hTestX >= hMapWidth:
;>     return
	ld hl, hMapWidth
	ldh a, [hTestX]
	sub [hl]
	inc hl
;=@w
	ldh a, [hTestX + 1]
	sbc [hl]
	ret nc

;>@h if hTestY >= hMapHeight:
;>     return
	ld hl, hMapHeight
	ldh a, [hTestY]
	sub [hl]
	inc hl
;=@h
	ldh a, [hTestY + 1]
	sbc [hl]
	ret nc

;> hTestResult = 0x0F
	ld a, $0f
	ldh [hTestResult], a
;> if wFieldFlags & 0x04:
;>     return                             # the screen is scrolling
	ld a, [wFieldFlags]
	bit 2, a
	ret nz

;>@sx hTestX = u16(hTestX - hScrollX)     # from here on relative to the screen
	ld hl, hScrollX
	ldh a, [hTestX]
	sub [hl]
	ldh [hTestX], a
	ld b, a
;=@sx
	inc hl
	ldh a, [hTestX + 1]
	sbc [hl]
	ldh [hTestX + 1], a
;> if hTestX >= 160:
;>     return
	or a
	ret nz

	ld a, b
	cp $a0
	ret nc

;>@sy hTestY = u16(hTestY - hScrollY)
	ld hl, hScrollY
	ldh a, [hTestY]
	sub [hl]
	ldh [hTestY], a
	ld b, a
;=@sy
	inc hl
	ldh a, [hTestY + 1]
	sbc [hl]
	ldh [hTestY + 1], a
;> if hTestY >= 128:
;>     return
	or a
	ret nz

	ld a, b
	cp $80
	ret nc

;>@c cell = wSavedTilemap + (hTestY >> 3) * 32
	ldh a, [hTestY]
	and $f8
	ld l, a
	ldh a, [hTestY + 1]
	sla l
	rla
;=@c
	sla l
	rla
	ld h, a
	ld de, wSavedTilemap
	add hl, de
;>@x cell += (hTestX >> 3) & 0x1F
	ldh a, [hTestX + 1]
	ld d, a
	ldh a, [hTestX]
	srl d
	rra
;=@x
	srl d
	rra
	srl d
	rra
	and $1f
	ld e, a
;=@x
	ld d, $00
	add hl, de
;> hTestTile = mem[cell]
	ld c, [hl]
	ld a, [hl]
	ldh [hTestTile], a
;> info = GateFloorMapInfo if wOnGateFloor else MapInfo
	ld de, MapInfo + 6
	ld a, [wOnGateFloor]
	or a
	jr z, .gotTable

	ld de, GateFloorMapInfo + 6

.gotTable
;>@f first_solid = mem[info + 8 * wMapId + 6]
	ld a, [wMapId]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@f
	add hl, de
;> result = 0xFF if hTestTile < first_solid else 0x0F
	ld a, c
	ld b, $ff
	cp [hl]
	jr c, .store

	ld b, $0f

.store
;> hTestResult = result
	ld a, b
	ldh [hTestResult], a
	ret


;@ def SGBAttrBlkBegin()
;@ path: system/sgb
;@ Starts a Super Game Boy ATTR_BLK packet (palettes for screen rectangles) in
;@ wSGBPacket: cleared, command $20, no blocks yet, write pointer after the
;@ count. The bytes after it are an unused variant of SGBAttrBlkAdd that always
;@ uses control byte 2 (color only the block's border).
SGBAttrBlkBegin::
;> fill(wSGBPacket, 0, 32)
	ld hl, wSGBPacket
	ld bc, $0020
	xor a
	call FillMemory
;> wSGBPacket[0] = 0x20                   # ATTR_BLK, packet count added when sent
	ld a, $20
	ld [wSGBPacket], a
;> wSGBPacket[1] = 0                      # number of blocks
	ld a, $00
	ld [wSGBPacket + 1], a
;> wSGBPacketPtr = wSGBPacket + 2
	ld hl, wSGBPacket + 2
	ld a, l
	ld [wSGBPacketPtr], a
	ld a, h
	ld [wSGBPacketPtr + 1], a
	ret


	db $57, $87, $87, $b2, $87, $87, $b2, $f5, $fa, $75, $c7, $5f, $fa, $76, $c7, $57
	db $3e, $02, $12, $13, $f1, $12, $13, $7c, $12, $13, $7d, $12, $13, $7c, $80, $12
	db $13, $7d, $81, $12, $13, $7b, $ea, $75, $c7, $7a, $ea, $76, $c7, $21, $78, $c7
	db $34, $c9

;@ def SGBAttrBlkAdd(palette: a, control: d, x: h, y: l, width: b, height: c)
;@ path: system/sgb
;@ Adds one rectangle to the ATTR_BLK packet: control byte (bit 0 color the
;@ inside, 1 the border, 2 the outside), palette `palette` for all three,
;@ corners (x, y) and (x + width, y + height) in tiles.
SGBAttrBlkAdd::
;>@p pals = palette << 4 | palette << 2 | palette
	ld e, a
	add a
	add a
	or e
	add a
	add a
;=@p
	or e
;> p = wSGBPacketPtr
	push af
	push de
	ld a, [wSGBPacketPtr]
	ld e, a
	ld a, [wSGBPacketPtr + 1]
	ld d, a
;> mem[p] = control
	pop af
	ld [de], a
	inc de
;> mem[p + 1] = pals
	pop af
	ld [de], a
	inc de
;> mem[p + 2] = x
	ld a, h
	ld [de], a
	inc de
;> mem[p + 3] = y
	ld a, l
	ld [de], a
	inc de
;> mem[p + 4] = u8(x + width)
	ld a, h
	add b
	ld [de], a
	inc de
;> mem[p + 5] = u8(y + height)
	ld a, l
	add c
	ld [de], a
	inc de
;> wSGBPacketPtr = p + 6
	ld a, e
	ld [wSGBPacketPtr], a
	ld a, d
	ld [wSGBPacketPtr + 1], a
;> wSGBPacket[1] = u8(wSGBPacket[1] + 1)
	ld hl, wSGBPacket + 1
	inc [hl]
	ret


;@ def SGBAttrBlkSend()
;@ path: system/sgb
;@ Sends the ATTR_BLK packet built by SGBAttrBlkAdd (if it has a block): the
;@ command byte gets the number of 16-byte packets the blocks need.
;@ test: skip far call
SGBAttrBlkSend::
;> if wSGBPacket[1] == 0:
;>     return
	ld a, [wSGBPacket + 1]
	or a
	ret z

;>@u used = wSGBPacketPtr - wSGBPacket
	ld a, [wSGBPacketPtr]
	ld l, a
	ld a, [wSGBPacketPtr + 1]
	ld h, a
	ld a, l
	sub LOW(wSGBPacket)
;=@u
	ld l, a
	ld a, h
	sbc HIGH(wSGBPacket)
	ld h, a
;>@n wSGBPacket[0] = 0x21 + (used >> 4 & 7)   # ATTR_BLK + number of packets
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
;=@n
	srl h
	rr l
	ld a, l
	and $07
	add $21
	ld [wSGBPacket], a
;> wSGBPacketID = 0xFF                    # send wSGBPacket
	ld a, $ff
	ld [wSGBPacketID], a
;> SendSGBPacket()
	ld hl, far_SendSGBPacket
	rst $10
	ret


;@ def PrintNumber7(dest: hl)
;@ path: text/numbers
;@ Draws the 24-bit number in hNumber as 7 digits from `dest` on (digit tiles
;@ $F0-$F9), leading zeros as blanks ($E0); each tile goes to the next column of
;@ the 32-tile row. hNumber is used up.
;@ test: skip writes through WriteVRAM
PrintNumber7::
;> hDivisorHigh = 0x0F
	ld a, $0f
	ldh [hDivisorHigh], a
;> digit = PeekDigit24(0x4240)            # millions ($0F4240)
	ld e, $40
	ld d, $42
	call PeekDigit24
;> if digit:
;>     return PrintNumber7Zeros(dest)
	or a
	jp nz, PrintNumber7Zeros

;> DrawBlankTile(dest)
	call DrawBlankTile
;> dest = NextTileColumn(dest)
;> return PrintNumber6(dest)              # runs on into it
	call NextTileColumn

;@ def PrintNumber6(dest: hl)
;@ path: text/numbers
;@ Like PrintNumber7 with 6 digits.
;@ test: skip writes through WriteVRAM
PrintNumber6::
;> hDivisorHigh = 0x01
	ld a, $01
	ldh [hDivisorHigh], a
;> digit = PeekDigit24(0x86A0)            # hundred thousands ($0186A0)
	ld e, $a0
	ld d, $86
	call PeekDigit24
;> if digit:
;>     return PrintNumber6Zeros(dest)
	or a
	jr nz, PrintNumber6Zeros

;> DrawBlankTile(dest)
	call DrawBlankTile
;> dest = NextTileColumn(dest)
;> return PrintNumber5(dest)
	call NextTileColumn

;@ def PrintNumber5(dest: hl)
;@ path: text/numbers
;@ Like PrintNumber7 with 5 digits (the last four from the low 16 bits).
;@ test: skip writes through WriteVRAM
PrintNumber5::
;> hDivisorHigh = 0x00
	ld a, $00
	ldh [hDivisorHigh], a
;> digit = PeekDigit24(0x2710)            # ten thousands
	ld e, $10
	ld d, $27
	call PeekDigit24
;> if digit:
;>     return PrintNumber5Zeros(dest)
	or a
	jr nz, PrintNumber5Zeros

;> DrawBlankTile(dest)
	call DrawBlankTile
;> dest = NextTileColumn(dest)
	call NextTileColumn
;> return PrintNumber4(dest, hNumber[0] | hNumber[1] << 8)
	ldh a, [hNumber]
	ld c, a
	ldh a, [hNumber + 1]
	ld b, a
	jp PrintNumber4


;@ def PrintNumber7Zeros(dest: hl)
;@ path: text/numbers
;@ Draws the 24-bit number in hNumber as 7 digits with leading zeros.
;@ test: skip writes through WriteVRAM
PrintNumber7Zeros::
;> hDivisorHigh = 0x0F
	ld a, $0f
	ldh [hDivisorHigh], a
;> digit = NextDigit24(0x4240)
	ld e, $40
	ld d, $42
	call NextDigit24
;> DrawDigitTile(digit, dest)
	call DrawDigitTile
;> dest = NextTileColumn(dest)
;> return PrintNumber6Zeros(dest)
	call NextTileColumn

;@ def PrintNumber6Zeros(dest: hl)
;@ path: text/numbers
;@ Draws hNumber as 6 digits with leading zeros.
;@ test: skip writes through WriteVRAM
PrintNumber6Zeros::
;> hDivisorHigh = 0x01
	ld a, $01
	ldh [hDivisorHigh], a
;> digit = NextDigit24(0x86A0)
	ld e, $a0
	ld d, $86
	call NextDigit24
;> DrawDigitTile(digit, dest)
	call DrawDigitTile
;> dest = NextTileColumn(dest)
;> return PrintNumber5Zeros(dest)
	call NextTileColumn

;@ def PrintNumber5Zeros(dest: hl)
;@ path: text/numbers
;@ Draws hNumber as 5 digits with leading zeros.
;@ test: skip writes through WriteVRAM
PrintNumber5Zeros::
;> hDivisorHigh = 0x00
	ld a, $00
	ldh [hDivisorHigh], a
;> digit = NextDigit24(0x2710)
	ld e, $10
	ld d, $27
	call NextDigit24
;> DrawDigitTile(digit, dest)
	call DrawDigitTile
;> dest = NextTileColumn(dest)
	call NextTileColumn
;> return PrintNumber4Zeros(dest, hNumber[0] | hNumber[1] << 8)
	ldh a, [hNumber]
	ld c, a
	ldh a, [hNumber + 1]
	ld b, a
	jp PrintNumber4Zeros


;@ def PeekDigit24(unit: de) -> a
;@ path: text/numbers
;@ NextDigit24 without using up hNumber: the digit of the 24-bit number for
;@ the unit hDivisorHigh:unit (hNumber is kept in wNumberBackup meanwhile).
;@ test: hDivisorHigh = rng.randint(1, 15)
PeekDigit24::
;> copy(wNumberBackup, hNumber, 3)
	ldh a, [hNumber]
	ld [wNumberBackup], a
	ldh a, [hNumber + 1]
	ld [wNumberBackup + 1], a
	ldh a, [hNumber + 2]
	ld [wNumberBackup + 2], a
;> digit = NextDigit24(unit)
	call NextDigit24
	push af
;> copy(hNumber, wNumberBackup, 3)
	ld a, [wNumberBackup]
	ldh [hNumber], a
	ld a, [wNumberBackup + 1]
	ldh [hNumber + 1], a
	ld a, [wNumberBackup + 2]
	ldh [hNumber + 2], a
;> return digit
	pop af
	ret


;@ def NextDigit24(unit: de) -> a
;@ path: text/numbers
;@ One decimal digit of the 24-bit number in hNumber: how often the unit
;@ hDivisorHigh:unit fits (counted by subtracting); hNumber keeps the rest.
;@ test: hDivisorHigh = rng.randint(1, 15)
NextDigit24::
;> n = hNumber[0] | hNumber[1] << 8 | hNumber[2] << 16
;> d = hDivisorHigh << 16 | unit
	push hl
	ldh a, [hDivisorHigh]
	ld l, a
	ld h, $ff

.loop
;>@q digit = n // d; n = n % d
	inc h
	ldh a, [hNumber]
	sub e
	ldh [hNumber], a
	ldh a, [hNumber + 1]
	sbc d
;=@q
	ldh [hNumber + 1], a
	ldh a, [hNumber + 2]
	sbc l
	ldh [hNumber + 2], a
	jr nc, .loop

;> hNumber[0] = n & 0xFF
	ldh a, [hNumber]
	add e
	ldh [hNumber], a
;> hNumber[1] = n >> 8 & 0xFF
	ldh a, [hNumber + 1]
	adc d
	ldh [hNumber + 1], a
;> hNumber[2] = n >> 16
	ldh a, [hNumber + 2]
	adc l
	ldh [hNumber + 2], a
;> return u8(digit)
	ld a, h
	pop hl
	ret


;@ def PrintNumber4(dest: hl, n: bc)
;@ path: text/numbers
;@ Draws the 16-bit number n as 4 digits (leading zeros blank) from `dest` on.
;@ test: skip writes through WriteVRAM
PrintNumber4::
;> digit, _ = NextDigit16(n, 1000)
	ld de, $03e8
	push bc
	call NextDigit16
	pop bc
;> if digit:
;>     return PrintNumber4Zeros(dest, n)
	or a
	jr nz, PrintNumber4Zeros

;> DrawBlankTile(dest)
	call DrawBlankTile
;> dest = NextTileColumn(dest)
;> return PrintNumber3(dest, n)
	call NextTileColumn

;@ def PrintNumber3(dest: hl, n: bc)
;@ path: text/numbers
;@ Draws n (below 1000) as 3 digits, leading zeros blank.
;@ test: skip writes through WriteVRAM
PrintNumber3::
;> digit, _ = NextDigit16(n, 100)
	ld de, $0064
	push bc
	call NextDigit16
	pop bc
;> if digit:
;>     return PrintNumber3Zeros(dest, n)
	or a
	jr nz, PrintNumber3Zeros

;> DrawBlankTile(dest)
	call DrawBlankTile
;> dest = NextTileColumn(dest)
;> return PrintNumber2(dest, n)
	call NextTileColumn

;@ def PrintNumber2(dest: hl, n: bc)
;@ path: text/numbers
;@ Draws n (below 100) as 2 digits, a leading zero blank.
;@ test: skip writes through WriteVRAM
PrintNumber2::
;> digit, _ = NextDigit16(n, 10)
	ld de, $000a
	push bc
	call NextDigit16
	pop bc
;> if digit:
;>     return PrintNumber2Zeros(dest, n)
	or a
	jr nz, PrintNumber2Zeros

;> DrawBlankTile(dest)
	call DrawBlankTile
;> dest = NextTileColumn(dest)
	call NextTileColumn
;> DrawDigitTile(n, dest)                 # the ones (shared tail of PrintNumber2Zeros)
	jr jr_000_20b9

;@ def PrintNumber4Zeros(dest: hl, n: bc)
;@ path: text/numbers
;@ Draws n as 4 digits with leading zeros.
;@ test: skip writes through WriteVRAM
PrintNumber4Zeros::
;> digit, n = NextDigit16(n, 1000)
	ld de, $03e8
	call NextDigit16
;> DrawDigitTile(digit, dest)
	call DrawDigitTile
;> dest = NextTileColumn(dest)
;> return PrintNumber3Zeros(dest, n)
	call NextTileColumn

;@ def PrintNumber3Zeros(dest: hl, n: bc)
;@ path: text/numbers
;@ Draws n (below 1000) as 3 digits with leading zeros.
;@ test: skip writes through WriteVRAM
PrintNumber3Zeros::
;> digit, n = NextDigit16(n, 100)
	ld de, $0064
	call NextDigit16
;> DrawDigitTile(digit, dest)
	call DrawDigitTile
;> dest = NextTileColumn(dest)
;> return PrintNumber2Zeros(dest, n)
	call NextTileColumn

;@ def PrintNumber2Zeros(dest: hl, n: bc)
;@ path: text/numbers
;@ Draws n (below 100) as 2 digits with a leading zero.
;@ test: skip writes through WriteVRAM
PrintNumber2Zeros::
;> digit, n = NextDigit16(n, 10)
	ld de, $000a
	call NextDigit16
;> DrawDigitTile(digit, dest)
	call DrawDigitTile
;> dest = NextTileColumn(dest)
	call NextTileColumn

jr_000_20b9:
;> DrawDigitTile(n, dest)                 # the ones
	ld a, c
	call DrawDigitTile
	ret


;@ def NextDigit16(n: bc, unit: de) -> (a, bc)
;@ path: text/numbers
;@ One decimal digit of n: how often `unit` fits (counted by subtracting), and
;@ the rest.
;@ test: unit = rng.randint(1, 0xFFFF)
;@ test: n = rng.randint(0, 0xFFFF) % (unit * 200 + 1)
NextDigit16::
;>@q return u8(n // unit), n % unit
	push hl
	ld h, $ff

.loop
;=@q
	inc h
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
;=@q
	ld b, a
	jr nc, .loop

;=@q
	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
;=@q
	ld a, h
	pop hl
	ret


;@ def DrawDigitTile(digit: a, dest: hl)
;@ path: text/numbers
;@ Writes the tile of a decimal digit ($F0 + digit) to `dest`.
;@ test: skip writes through WriteVRAM
DrawDigitTile::
;> WriteVRAM(0xF0 + digit, dest)
	add $f0
	call WriteVRAM
	ret


;@ def DrawBlankTile(dest: hl)
;@ path: text/numbers
;@ Writes the blank tile $E0 to `dest`.
;@ test: skip writes through WriteVRAM
DrawBlankTile::
;> WriteVRAM(0xE0, dest)
	ld a, $e0
	call WriteVRAM
	ret


;@ def NextTileColumn(pos: hl) -> hl
;@ path: gfx/tilemap
;@ Moves a BG map address one column to the right, wrapping within its
;@ 32-tile row.
NextTileColumn::
;>@n return (pos & 0xFFE0) | ((pos + 1) & 0x1F)
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;=@n
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	pop af
;=@n
	ret


;@ def ReadSRAMByte(addr: hl) -> a
;@ path: save/sram
;@ Reads one byte of the battery RAM (enabling it around the read).
;@ test: skip switches the cartridge RAM on and off
ReadSRAMByte::
;> disable_interrupts()
	di
;> mem[0x0100] = 0x0A                     # cartridge RAM on
	ld a, $0a
	ld [rRAMG + $100], a
;> value = mem[addr]
	ld a, [hl]
	push af
;> mem[0x0100] = 0x00                     # and off again
	ld a, $00
	ld [rRAMG + $100], a
;> enable_interrupts()
	pop af
	ei
;> return value
	ret


;@ def WriteSRAMByte(addr: hl, value: a)
;@ path: save/sram
;@ Writes one byte of the battery RAM (enabling it around the write).
;@ test: skip switches the cartridge RAM on and off
WriteSRAMByte::
;> disable_interrupts()
	di
;> mem[0x0100] = 0x0A
	push af
	ld a, $0a
	ld [rRAMG + $100], a
;> mem[addr] = value
	pop af
	ld [hl], a
;> mem[0x0100] = 0x00
	ld a, $00
	ld [rRAMG + $100], a
;> enable_interrupts()
	ei
	ret


;@ def SRAMChecksum(start: hl, count: bc) -> de
;@ path: save/sram
;@ Checksum of `count` bytes of the battery RAM: $4638 plus the sum of the
;@ bytes, 16 bits.
;@ test: skip switches the cartridge RAM on and off
SRAMChecksum::
;> mem[0x0100] = 0x0A
	ld a, $0a
	ld [rRAMG + $100], a
;> total = 0x4638
	ld de, $4638

.loop
;>@sum for i in range(count):
;>     total = u16(total + mem[start + i])
	ld a, [hli]
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;=@sum
	dec bc
	ld a, b
	or c
	jr nz, .loop

;> mem[0x0100] = 0x00
	ld a, $00
	ld [rRAMG + $100], a
;> return total
	ret


;@ def SaveGame()
;@ path: save/game
;@ Saves the game to the battery RAM: the player's HRAM state ($FF8A-$FFAA),
;@ the whole game state $C8EA-$D9E9, the current screen's tiles and map data;
;@ then FinishSave marks the save valid and writes the checksum.
;@ test: skip switches the cartridge RAM on and off
SaveGame::
;> CopyToSRAM(hPlayerGfx, sSavedHRAM, 0x21)
	ld hl, hPlayerGfx
	ld de, sSavedHRAM
	ld bc, $0021
	call CopyToSRAM
;> CopyToSRAM(wGameStarted, sSavedWRAM, 0x1100)
	ld hl, wGameStarted
	ld de, sSavedWRAM
	ld bc, $1100
	call CopyToSRAM
;> CopyToSRAM(wSavedTilemap, sSavedScreenTiles, 0x200)
	ld hl, wSavedTilemap
	ld de, sSavedScreenTiles
	ld bc, $0200
	call CopyToSRAM
;> CopyToSRAM(wScreenMap, sSavedScreenMap, 0x100)
;> FinishSave()                           # runs on into it
	ld hl, wScreenMap
	ld de, sSavedScreenMap
	ld bc, $0100
	call CopyToSRAM

;@ def FinishSave()
;@ path: save/game
;@ Ends a save: sSaveValid = 1, and sChecksum = SRAMChecksum over
;@ $A002-$BFFF.
;@ test: skip switches the cartridge RAM on and off
FinishSave::
;> mem[0x0100] = 0x0A
	ld hl, sSaveValid
	ld a, $01
	push af
	ld a, $0a
	ld [rRAMG + $100], a
;> sSaveValid = 1
	pop af
	ld [hl], a
;> mem[0x0100] = 0x00
	ld a, $00
	ld [rRAMG + $100], a
;> checksum = SRAMChecksum(sSaveValid, 0x1FFE)
	ld hl, sSaveValid
	ld bc, $1ffe
	call SRAMChecksum
;> mem[0x0100] = 0x0A
	ld a, $0a
	ld [rRAMG + $100], a
;> sChecksum = checksum
	ld hl, sChecksum
	ld [hl], e
	inc hl
	ld [hl], d
;> mem[0x0100] = 0x00
	ld a, $00
	ld [rRAMG + $100], a
	ret


;@ def CopyToSRAM(src: hl, dest: de, count: bc)
;@ path: save/sram
;@ Copies `count` bytes into the battery RAM (count 0 copies 65536).
;@ test: skip switches the cartridge RAM on and off
CopyToSRAM::
;> mem[0x0100] = 0x0A
	ld a, $0a
	ld [rRAMG + $100], a

.loop
;>@c copy(dest, src, count)
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
;=@c
	jr nz, .loop

;> mem[0x0100] = 0x00
	ld a, $00
	ld [rRAMG + $100], a
	ret


;@ def SaveMonsters()
;@ path: save/game
;@ Saves only the monsters (all $95-byte records) and the party (count and
;@ slots), then marks the save valid with a new checksum.
;@ test: skip switches the cartridge RAM on and off
SaveMonsters::
;> CopyToSRAM(wMonsters, sMonsters, 0xBA4)
	ld hl, wMonsters
	ld de, sMonsters
	ld bc, $0ba4
	call CopyToSRAM
;> CopyToSRAM(wPartyCount, sPartyCount, 7)
	ld hl, wPartyCount
	ld de, sPartyCount
	ld bc, $0007
	call CopyToSRAM
;> FinishSave()
	jp FinishSave


;@ def LoadGame()
;@ path: save/game
;@ Loads a saved game (if sSaveValid is set): the same four blocks SaveGame
;@ writes are copied back.
;@ test: skip switches the cartridge RAM on and off
LoadGame::
;> mem[0x0100] = 0x0A
	ld hl, sSaveValid
	ld a, $0a
	ld [rRAMG + $100], a
;> valid = sSaveValid
	ld a, [hl]
	push af
;> mem[0x0100] = 0x00
	ld a, $00
	ld [rRAMG + $100], a
;> if not valid:
;>     return
	pop af
	or a
	ret z

;> CopyFromSRAM(hPlayerGfx, sSavedHRAM, 0x21)
	ld hl, hPlayerGfx
	ld de, sSavedHRAM
	ld bc, $0021
	call CopyFromSRAM
;> CopyFromSRAM(wGameStarted, sSavedWRAM, 0x1100)
	ld hl, wGameStarted
	ld de, sSavedWRAM
	ld bc, $1100
	call CopyFromSRAM
;> CopyFromSRAM(wSavedTilemap, sSavedScreenTiles, 0x200)
	ld hl, wSavedTilemap
	ld de, sSavedScreenTiles
	ld bc, $0200
	call CopyFromSRAM
;> CopyFromSRAM(wScreenMap, sSavedScreenMap, 0x100)
	ld hl, wScreenMap
	ld de, sSavedScreenMap
	ld bc, $0100
	call CopyFromSRAM
	ret


;@ def CopyFromSRAM(dest: hl, src: de, count: bc)
;@ path: save/sram
;@ Copies `count` bytes out of the battery RAM.
;@ test: skip switches the cartridge RAM on and off
CopyFromSRAM::
;> mem[0x0100] = 0x0A
	ld a, $0a
	ld [rRAMG + $100], a

.loop
;>@c copy(dest, src, count)
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
;=@c
	jr nz, .loop

;> mem[0x0100] = 0x00
	ld a, $00
	ld [rRAMG + $100], a
	ret


;@ def GetPartySlot(pos: a) -> a
;@ path: monster/party
;@ Monster slot (index into wMonsters) of party position `pos` (bit 7
;@ ignored). In game mode 2 over the link cable the number already is a slot
;@ and comes back unchanged.
GetPartySlot::
;>@l if wLinkActive and wGameMode == 2:
	push bc
	ld b, a
	ld a, [wLinkActive]
	or a
	jr z, .party

;=@l
	ld a, [wGameMode]
	cp $02
	jr nz, .party

;>     return pos
	ld a, b
	pop bc
	ret


.party
;>@p return wParty[pos & 0x7F]
	ld a, b
	pop bc
	ld hl, wParty
	and $7f
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


;@ def PartyMonsterField(pos: a, field: hl) -> hl
;@ path: monster/party
;@ Address of a field of the monster at party position `pos`: `field` is the
;@ field's address in the first record (e.g. wMonHP), records are $95 bytes.
;@ Keeps all other registers.
PartyMonsterField::
;> slot = GetPartySlot(pos)
	push af
	push bc
	push de
	push hl
	call GetPartySlot
;>@r return u16(field + Multiply(slot, 0x95))
	ld c, $95
	call Multiply
	pop bc
	add hl, bc
	pop de
	pop bc
;=@r
	pop af
	ret


;@ def MonsterField(slot: a, field: hl) -> hl
;@ path: monster/party
;@ Address of a field of monster record `slot` (bit 7 ignored): field +
;@ slot * $95.
MonsterField::
;>@r return u16(field + (slot & 0x7F) * 0x95)
	push bc
	push de
	push hl
	ld c, $95
	and $7f
	call Multiply
;=@r
	pop bc
	add hl, bc
	pop de
	pop bc
	ret


;@ def GetPartyMonsterByte(pos: a, field: hl) -> a
;@ path: monster/party
;@ Reads a byte field of the monster at party position `pos`.
GetPartyMonsterByte::
;> return mem[PartyMonsterField(pos, field)]
	call PartyMonsterField
	ld a, [hl]
	ret


;@ def GetPartyMonsterWord(pos: a, field: hl) -> bc
;@ path: monster/party
;@ Reads a 16-bit field of the monster at party position `pos`. (The bytes after
;@ it are an unused byte setter.)
GetPartyMonsterWord::
;> return mem16[PartyMonsterField(pos, field)]
	call PartyMonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret


	db $c5, $cd, $29, $22, $c1, $71, $c9

;@ def SetPartyMonsterWord(pos: a, field: hl, value: bc)
;@ path: monster/party
;@ Writes a 16-bit field of the monster at party position `pos`.
SetPartyMonsterWord::
;> p = PartyMonsterField(pos, field)
	push bc
	call PartyMonsterField
	pop bc
;> mem16[p] = value
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


;@ def CurMonsterField(field: hl) -> hl
;@ path: monster/party
;@ Address of a field of the party monster wCurPartyMember (no link special
;@ case). Keeps all other registers.
CurMonsterField::
;>@s slot = wParty[wCurPartyMember & 0x7F]
	push af
	push bc
	push de
	push hl
	ld hl, wParty
	ld a, [wCurPartyMember]
;=@s
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@s
	ld a, [hl]
;>@r return u16(field + Multiply(slot, 0x95))
	ld c, $95
	call Multiply
	pop bc
	add hl, bc
	pop de
	pop bc
;=@r
	pop af
	ret


;@ def GetCurMonsterByte(field: hl) -> a
;@ path: monster/party
;@ Reads a byte field of the party monster wCurPartyMember.
GetCurMonsterByte::
;> return mem[CurMonsterField(field)]
	call CurMonsterField
	ld a, [hl]
	ret


;@ def GetCurMonsterWord(field: hl) -> bc
;@ path: monster/party
;@ Reads a 16-bit field of the party monster wCurPartyMember. (The bytes after
;@ it are unused setters for a byte and a word field.)
GetCurMonsterWord::
;> return mem16[CurMonsterField(field)]
	call CurMonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret


	db $c5, $cd, $66, $22, $c1, $71, $c9, $c5, $cd, $66, $22, $c1, $79, $22, $70, $c9

;@ def HealPartyHP(pos: a, amount: hl)
;@ path: monster/stats
;@ Gives the monster at party position `pos` `amount` HP, at most up to its
;@ maximum HP.
HealPartyHP::
;> slot = GetPartySlot(pos)
	push hl
	call GetPartySlot
	pop hl
;> cap = mem16[MonsterField(slot, addr(wMonMaxHP))]
	push hl
	push af
	ld hl, wMonMaxHP
	call MonsterField
	ld a, [hli]
	ld h, [hl]
;=@c
	ld l, a
;>@c AddWordCapped(MonsterField(slot, addr(wMonHP)), amount, cap)
	pop af
	push hl
	ld hl, wMonHP
	call MonsterField
	pop bc
	pop de
;=@c
	call AddWordCapped
	ret


;@ def DamagePartyHP(pos: a, amount: hl)
;@ path: monster/stats
;@ Takes `amount` HP from the monster at party position `pos` (not below 0).
DamagePartyHP::
;> slot = GetPartySlot(pos)
	push hl
	call GetPartySlot
	pop hl
;> hp = MonsterField(slot, addr(wMonHP))
	push hl
	ld hl, wMonHP
	call MonsterField
;> SubWordFloored(hp, amount, 0)
	pop de
	ld bc, $0000
	call SubWordFloored
	ret


;@ def RestorePartyMP(pos: a, amount: hl)
;@ path: monster/stats
;@ Gives the monster at party position `pos` `amount` MP, at most up to its
;@ maximum MP. The bytes after it are LosePartyMP (takes MP, not below 0),
;@ called from code in bank 1 that is not traced yet.
RestorePartyMP::
;> slot = GetPartySlot(pos)
	push hl
	call GetPartySlot
	pop hl
;> cap = mem16[MonsterField(slot, addr(wMonMaxMP))]
	push hl
	push af
	ld hl, wMonMaxMP
	call MonsterField
	ld a, [hli]
	ld h, [hl]
;=@c
	ld l, a
;>@c AddWordCapped(MonsterField(slot, addr(wMonMP)), amount, cap)
	pop af
	push hl
	ld hl, wMonMP
	call MonsterField
	pop bc
	pop de
;=@c
	call AddWordCapped
	ret


;@ def LosePartyMP(pos: a, amount: hl)
;@ path: monster/stats
;@ Takes `amount` MP from the monster at party position `pos` (not below 0).
;@ Called from code in bank 1 that is still in db form.
LosePartyMP::
;> slot = GetPartySlot(pos)
	push hl
	call GetPartySlot
	pop hl
;> mp = MonsterField(slot, addr(wMonMP))
	push hl
	ld hl, wMonMP
	call MonsterField
;> SubWordFloored(mp, amount, 0)
	pop de
	ld bc, $0000
	call SubWordFloored
	ret

;@ def RaisePartyAttack(pos: a, amount: hl)
;@ path: monster/stats
;@ Raises the attack of the monster at party position `pos` by `amount`, up to
;@ 999.
RaisePartyAttack::
;> slot = GetPartySlotForRaise(pos)
;> RaiseMonsterAttack(slot, amount)       # runs on into it
	call GetPartySlotForRaise

;@ def RaiseMonsterAttack(slot: a, amount: hl)
;@ path: monster/stats
;@ Raises the attack of monster record `slot` by `amount`, up to 999. (The
;@ three bytes after it, `call GetPartySlotForLower`, are an unused party
;@ entry to LowerMonsterAttack.)
RaiseMonsterAttack::
;> RaiseMonsterWord(slot, addr(wMonAttack), amount, 999)
	ld de, wMonAttack
	ld bc, $03e7
	call RaiseMonsterWord
	ret


	db $cd, $62, $24

;@ def LowerMonsterAttack(slot: a, amount: hl)
;@ path: monster/stats
;@ Lowers the attack of monster record `slot` by `amount`, not below 1.
LowerMonsterAttack::
;> LowerMonsterWord(slot, addr(wMonAttack), amount, 1)
	ld de, wMonAttack
	ld bc, $0001
	call LowerMonsterWord
	ret


;@ def RaisePartyDefense(pos: a, amount: hl)
;@ path: monster/stats
;@ Raises the defense of the monster at party position `pos`, up to 999.
RaisePartyDefense::
;> slot = GetPartySlotForRaise(pos)
;> RaiseMonsterDefense(slot, amount)      # runs on into it
	call GetPartySlotForRaise

;@ def RaiseMonsterDefense(slot: a, amount: hl)
;@ path: monster/stats
;@ Raises the defense of monster record `slot` by `amount`, up to 999.
RaiseMonsterDefense::
;> RaiseMonsterWord(slot, addr(wMonDefense), amount, 999)
	ld de, wMonDefense
	ld bc, $03e7
	call RaiseMonsterWord
	ret


	; unused bytes nothing reaches (a leftover code fragment)
	db $cd, $62, $24

;@ def LowerMonsterDefense(slot: a, amount: hl)
;@ path: monster/stats
;@ Lowers the defense of monster record `slot` by `amount`, not below 1.
LowerMonsterDefense::
;> LowerMonsterWord(slot, addr(wMonDefense), amount, 1)
	ld de, wMonDefense
	ld bc, $0001
	call LowerMonsterWord
	ret


;@ def RaisePartyAgility(pos: a, amount: hl)
;@ path: monster/stats
;@ Raises the agility of the monster at party position `pos`, up to 511.
RaisePartyAgility::
;> slot = GetPartySlotForRaise(pos)
;> RaiseMonsterAgility(slot, amount)      # runs on into it
	call GetPartySlotForRaise

;@ def RaiseMonsterAgility(slot: a, amount: hl)
;@ path: monster/stats
;@ Raises the agility of monster record `slot` by `amount`, up to 511.
RaiseMonsterAgility::
;> RaiseMonsterWord(slot, addr(wMonAgility), amount, 511)
	ld de, wMonAgility
	ld bc, $01ff
	call RaiseMonsterWord
	ret


	; unused bytes nothing reaches (a leftover code fragment)
	db $cd, $62, $24

;@ def LowerMonsterAgility(slot: a, amount: hl)
;@ path: monster/stats
;@ Lowers the agility of monster record `slot` by `amount`, not below 1.
LowerMonsterAgility::
;> LowerMonsterWord(slot, addr(wMonAgility), amount, 1)
	ld de, wMonAgility
	ld bc, $0001
	call LowerMonsterWord
	ret


;@ def RaisePartyIntelligence(pos: a, amount: hl)
;@ path: monster/stats
;@ Raises the intelligence of the monster at party position `pos`, up to 255.
RaisePartyIntelligence::
;> slot = GetPartySlotForRaise(pos)
;> RaiseMonsterIntelligence(slot, amount)   # runs on into it
	call GetPartySlotForRaise

;@ def RaiseMonsterIntelligence(slot: a, amount: hl)
;@ path: monster/stats
;@ Raises the intelligence of monster record `slot` by `amount`, up to 255.
;@ (The bytes after it: an unused RaisePartyWildness, up to 255.)
RaiseMonsterIntelligence::
;> RaiseMonsterWord(slot, addr(wMonIntelligence), amount, 255)
	ld de, wMonIntelligence
	ld bc, $00ff
	call RaiseMonsterWord
	ret


	db $cd, $62, $24

;@ def LowerMonsterIntelligence(slot: a, amount: hl)
;@ path: monster/stats
;@ Lowers the intelligence of monster record `slot` by `amount`, not below 1.
LowerMonsterIntelligence::
;> LowerMonsterWord(slot, addr(wMonIntelligence), amount, 1)
	ld de, wMonIntelligence
	ld bc, $0001
	call LowerMonsterWord
	ret


	; unused bytes nothing reaches (a leftover code fragment)
	db $cd, $42, $24, $11, $21, $cb, $01, $ff, $00, $cd, $48, $24, $c9

;@ def LowerPartyWildness(pos: a, amount: hl)
;@ path: monster/stats
;@ Lowers the wildness of the monster at party position `pos` by `amount`, not
;@ below 0.
LowerPartyWildness::
;> slot = GetPartySlotForLower(pos)
	call GetPartySlotForLower
;> LowerMonsterWord(slot, addr(wMonWildness), amount, 0)
	ld de, wMonWildness
	ld bc, $0000
	call LowerMonsterWord
	ret


;@ def RaisePartyStat64(pos: a, amount: l)
;@ path: monster/stats
;@ Raises the byte field +$64 of the monster at party position `pos`, up to 255.
RaisePartyStat64::
;> slot = GetPartySlotForRaise(pos)
	call GetPartySlotForRaise
;> RaiseMonsterByte(slot, addr(wMonStat64), amount, 255)
	ld de, wMonStat64
	ld c, $ff
	call RaiseMonsterByte
	ret


;@ def LowerPartyStat64(pos: a, amount: l)
;@ path: monster/stats
;@ Lowers the byte field +$64 of the monster at party position `pos`, not
;@ below 0.
LowerPartyStat64::
;> slot = GetPartySlotForLower(pos)
	call GetPartySlotForLower
;> LowerMonsterByte(slot, addr(wMonStat64), amount, 0)
	ld de, wMonStat64
	ld c, $00
	call LowerMonsterByte
	ret


;@ def RaisePartyStat67(pos: a, amount: l)
;@ path: monster/stats
;@ Raises the byte field +$67 of the monster at party position `pos`, up to 255.
RaisePartyStat67::
;> slot = GetPartySlotForRaise(pos)
	call GetPartySlotForRaise
;> RaiseMonsterByte(slot, addr(wMonStat67), amount, 255)
	ld de, wMonStat67
	ld c, $ff
	call RaiseMonsterByte
	ret


;@ def LowerPartyStat67(pos: a, amount: l)
;@ path: monster/stats
;@ Lowers the byte field +$67 of the monster at party position `pos`, not
;@ below 0. (The bytes after it: unused raise / lower functions for field +$66.)
LowerPartyStat67::
;> slot = GetPartySlotForLower(pos)
	call GetPartySlotForLower
;> LowerMonsterByte(slot, addr(wMonStat67), amount, 0)
	ld de, wMonStat67
	ld c, $00
	call LowerMonsterByte
	ret


	db $cd, $42, $24, $11, $27, $cb, $0e, $ff, $cd, $55, $24, $c9, $cd, $62, $24, $11
	db $27, $cb, $0e, $00, $cd, $75, $24, $c9

;@ def RaisePartyStat65(pos: a, amount: l)
;@ path: monster/stats
;@ Raises the byte field +$65 of the monster at party position `pos`, up to 255.
RaisePartyStat65::
;> slot = GetPartySlotForRaise(pos)
	call GetPartySlotForRaise
;> RaiseMonsterByte(slot, addr(wMonStat65), amount, 255)
	ld de, wMonStat65
	ld c, $ff
	call RaiseMonsterByte
	ret


;@ def LowerPartyStat65(pos: a, amount: l)
;@ path: monster/stats
;@ Lowers the byte field +$65 of the monster at party position `pos`, not
;@ below 0.
LowerPartyStat65::
;> slot = GetPartySlotForLower(pos)
	call GetPartySlotForLower
;> LowerMonsterByte(slot, addr(wMonStat65), amount, 0)
	ld de, wMonStat65
	ld c, $00
	call LowerMonsterByte
	ret


;@ def RaisePartyMaxHP(pos: a, amount: hl)
;@ path: monster/stats
;@ Raises the maximum HP of the monster at party position `pos`, up to 999.
RaisePartyMaxHP::
;> slot = GetPartySlotForRaise(pos)
;> RaiseMonsterMaxHP(slot, amount)        # runs on into it
	call GetPartySlotForRaise

;@ def RaiseMonsterMaxHP(slot: a, amount: hl)
;@ path: monster/stats
;@ Raises the maximum HP of monster record `slot` by `amount`, up to 999.
RaiseMonsterMaxHP::
;> RaiseMonsterWord(slot, addr(wMonMaxHP), amount, 999)
	ld de, wMonMaxHP
	ld bc, $03e7
	call RaiseMonsterWord
	ret


	; unused bytes nothing reaches (a leftover code fragment)
	db $cd, $62, $24

;@ def LowerMonsterMaxHP(slot: a, amount: hl)
;@ path: monster/stats
;@ Lowers the maximum HP of monster record `slot` by `amount`, not below 1.
LowerMonsterMaxHP::
;> LowerMonsterWord(slot, addr(wMonMaxHP), amount, 1)
	ld de, wMonMaxHP
	ld bc, $0001
	call LowerMonsterWord
	ret


;@ def RaisePartyMaxMP(pos: a, amount: hl)
;@ path: monster/stats
;@ Raises the maximum MP of the monster at party position `pos`, up to 999.
RaisePartyMaxMP::
;> slot = GetPartySlotForRaise(pos)
;> RaiseMonsterMaxMP(slot, amount)        # runs on into it
	call GetPartySlotForRaise

;@ def RaiseMonsterMaxMP(slot: a, amount: hl)
;@ path: monster/stats
;@ Raises the maximum MP of monster record `slot` by `amount`, up to 999.
RaiseMonsterMaxMP::
;> RaiseMonsterWord(slot, addr(wMonMaxMP), amount, 999)
	ld de, wMonMaxMP
	ld bc, $03e7
	call RaiseMonsterWord
	ret


	; unused bytes nothing reaches (a leftover code fragment)
	db $cd, $62, $24

;@ def LowerMonsterMaxMP(slot: a, amount: hl)
;@ path: monster/stats
;@ Lowers the maximum MP of monster record `slot` by `amount`, not below 1.
LowerMonsterMaxMP::
;> LowerMonsterWord(slot, addr(wMonMaxMP), amount, 1)
	ld de, wMonMaxMP
	ld bc, $0001
	call LowerMonsterWord
	ret


;@ def AddGold(amount_high: e, amount: hl)
;@ path: item/gold
;@ Adds the 24-bit amount e:hl to the gold carried (at most 99999).
AddGold::
;> AddGoldCapped(wGold, amount_high << 16 | amount)
	ld c, e
	ld d, h
	ld e, l
	ld hl, wGold
	call AddGoldCapped
	ret


;@ def SpendGold(amount_high: e, amount: hl)
;@ path: item/gold
;@ Takes the 24-bit amount e:hl from the gold carried (not below 0).
SpendGold::
;> Sub24Floored(wGold, amount_high << 16 | amount)
	ld c, e
	ld d, h
	ld e, l
	ld hl, wGold
	call Sub24Floored
	ret


;@ def AddBankGold(amount_high: e, amount: hl)
;@ path: item/gold
;@ Adds the 24-bit amount e:hl to the gold kept in the bank (at most 999999).
AddBankGold::
;> AddBankGoldCapped(wBankedGold, amount_high << 16 | amount)
	ld c, e
	ld d, h
	ld e, l
	ld hl, wBankedGold
	call AddBankGoldCapped
	ret


;@ def TakeBankGold(amount_high: e, amount: hl)
;@ path: item/gold
;@ Takes the 24-bit amount e:hl from the gold kept in the bank (not below 0).
TakeBankGold::
;> Sub24Floored(wBankedGold, amount_high << 16 | amount)
	ld c, e
	ld d, h
	ld e, l
	ld hl, wBankedGold
	call Sub24Floored
	ret


;@ def GetPartySlotForRaise(pos: a) -> a
;@ path: monster/stats
;@ GetPartySlot keeping hl (the amount), for the Raise... functions.
GetPartySlotForRaise::
;> return GetPartySlot(pos)
	push hl
	call GetPartySlot
	pop hl
	ret


;@ def RaiseMonsterWord(slot: a, field: de, amount: hl, cap: bc)
;@ path: monster/stats
;@ Adds `amount` to a 16-bit field of monster record `slot`, at most `cap`.
RaiseMonsterWord::
;> p = MonsterField(slot, field)
	push bc
	push hl
	ld l, e
	ld h, d
	call MonsterField
;> AddWordCapped(p, amount, cap)
	pop de
	pop bc
	call AddWordCapped
	ret


;@ def RaiseMonsterByte(slot: a, field: de, amount: l, cap: c)
;@ path: monster/stats
;@ Adds `amount` to a byte field of monster record `slot`, at most `cap`.
RaiseMonsterByte::
;> p = MonsterField(slot, field)
	push bc
	push hl
	ld l, e
	ld h, d
	call MonsterField
;> AddByteCapped(p, amount, cap)
	pop de
	pop bc
	call AddByteCapped
	ret


;@ def GetPartySlotForLower(pos: a) -> a
;@ path: monster/stats
;@ GetPartySlot keeping hl (the amount), for the Lower... functions.
GetPartySlotForLower::
;> return GetPartySlot(pos)
	push hl
	call GetPartySlot
	pop hl
	ret


;@ def LowerMonsterWord(slot: a, field: de, amount: hl, floor: bc)
;@ path: monster/stats
;@ Takes `amount` from a 16-bit field of monster record `slot`, not below
;@ `floor`.
LowerMonsterWord::
;> p = MonsterField(slot, field)
	push bc
	push hl
	ld l, e
	ld h, d
	call MonsterField
;> SubWordFloored(p, amount, floor)
	pop de
	pop bc
	call SubWordFloored
	ret


;@ def LowerMonsterByte(slot: a, field: de, amount: l, floor: c)
;@ path: monster/stats
;@ Takes `amount` from a byte field of monster record `slot`, not below
;@ `floor`.
LowerMonsterByte::
;> p = MonsterField(slot, field)
	push bc
	push hl
	ld l, e
	ld h, d
	call MonsterField
;> SubByteFloored(p, amount, floor)
	pop de
	pop bc
	call SubByteFloored
	ret


;@ def AddWordCapped(p: hl, amount: de, cap: bc)
;@ path: system/math
;@ mem16[p] += amount, limited to `cap`. (A sum past $FFFF is stored
;@ wrapped, not capped.)
AddWordCapped::
;> total = mem16[p] + amount
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
;> if total <= 0xFFFF and total >= cap:
	jr c, .keep

	ld a, l
	sub c
	ld a, h
	sbc b
;>     total = cap
	jr nc, .store

.keep
;> else:
;>     total = u16(total)
	ld c, l
	ld b, h

.store
;> mem16[p] = u16(total)
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


;@ def SubWordFloored(p: hl, amount: de, floor: bc)
;@ path: system/math
;@ mem16[p] -= amount, not below `floor` (and `floor` when it would go below 0).
SubWordFloored::
;>@d left = mem16[p] - amount
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub e
;=@d
	ld l, a
	ld a, h
	sbc d
	ld h, a
;> if left >= 0 and left >= floor:
	jr c, .store

	ld a, l
	sub c
	ld a, h
	sbc b
	jr c, .store

;>     floor = left
	ld c, l
	ld b, h

.store
;> mem16[p] = floor
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


;@ def AddByteCapped(p: hl, amount: e, cap: c)
;@ path: system/math
;@ mem[p] += amount, limited to `cap` (and 255).
AddByteCapped::
;> total = mem[p] + amount
	ld a, [hl]
	add e
;> if total > 0xFF or total >= cap:
	jr c, .cap

	cp c
	jr c, .store

.cap
;>     total = cap
	ld a, c

.store
;> mem[p] = total
	ld [hl], a
	ret


;@ def SubByteFloored(p: hl, amount: e, floor: c)
;@ path: system/math
;@ mem[p] -= amount, not below `floor` (and 0).
SubByteFloored::
;> left = mem[p] - amount
	ld a, [hl]
	sub e
;> if left < 0 or left < floor:
	jr c, .floor

	cp c
	jr nc, .store

.floor
;>     left = floor
	ld a, c

.store
;> mem[p] = left
	ld [hl], a
	ret


;@ def AddGoldCapped(p: hl, amount: cde)
;@ path: item/gold
;@ Adds a 24-bit amount (c high, d, e low) to the 24-bit number at p, at most
;@ 99999.
;@ test: skip 24-bit register pair
AddGoldCapped::
;>@s total = (mem[p] | mem[p + 1] << 8 | mem[p + 2] << 16) + amount & 0xFFFFFF
	push hl
	ld a, [hli]
	add e
	ld e, a
	ld a, [hli]
	adc d
;=@s
	ld d, a
	ld a, [hl]
	adc c
	ld c, a
;> if total >= 99999:
	ld a, e
	sub $9f
	ld a, d
	sbc $86
	ld a, c
	sbc $01
;=@m
	jr c, .store

;>@m     total = 99999
	ld de, $869f
	ld c, $01

.store
;> mem[p] = total & 0xFF
	pop hl
	ld a, e
	ld [hli], a
;> mem[p + 1] = total >> 8 & 0xFF
	ld a, d
	ld [hli], a
;> mem[p + 2] = total >> 16
	ld [hl], c
	ret


;@ def AddBankGoldCapped(p: hl, amount: cde)
;@ path: item/gold
;@ Like AddGoldCapped with the bank's limit 999999 (shares its store).
;@ test: skip 24-bit register pair
AddBankGoldCapped::
;>@s total = (mem[p] | mem[p + 1] << 8 | mem[p + 2] << 16) + amount & 0xFFFFFF
	push hl
	ld a, [hli]
	add e
	ld e, a
	ld a, [hli]
	adc d
;=@s
	ld d, a
	ld a, [hl]
	adc c
	ld c, a
;> if total >= 999999:
	ld a, e
	sub $3f
	ld a, d
	sbc $42
	ld a, c
	sbc $0f
;=@m
	jr c, AddGoldCapped.store

;>@m     total = 999999
	ld de, $423f
	ld c, $0f
;> mem[p] = total & 0xFF; mem[p + 1] = total >> 8 & 0xFF; mem[p + 2] = total >> 16   # AddGoldCapped's store
	jr AddGoldCapped.store

;@ def Sub24Floored(p: hl, amount: cde)
;@ path: item/gold
;@ Takes a 24-bit amount (c high, d, e low) from the 24-bit number at p, not
;@ below 0.
;@ test: skip 24-bit register pair
Sub24Floored::
;>@s left = (mem[p] | mem[p + 1] << 8 | mem[p + 2] << 16) - amount
	push hl
	ld a, [hli]
	sub e
	ld e, a
	ld a, [hli]
	sbc d
;=@s
	ld d, a
	ld a, [hl]
	sbc c
	ld c, a
;> if left < 0:
;>     left = 0
	jr nc, .store

	ld de, $0000
	ld c, $00

.store
;> mem[p] = left & 0xFF
	pop hl
	ld a, e
	ld [hli], a
;> mem[p + 1] = left >> 8 & 0xFF
	ld a, d
	ld [hli], a
;> mem[p + 2] = left >> 16
	ld [hl], c
	ret


;@ def BuildStatusBar()
;@ path: menu/statusbar
;@ Builds the party status bar in wPartyBarTiles (2 rows of 32 tiles, 7 columns
;@ per party monster): all tile $DC without a party, else blanks and one entry
;@ per monster (BuildStatusBarEntry).
BuildStatusBar::
;> if wPartyCount == 0:
	ld a, [wPartyCount]
	or a
	jr nz, .party

;>     FillMemory(wPartyBarTiles, 0x40, 0xDC)
;>     return
	ld hl, wPartyBarTiles
	ld bc, $0040
	ld a, $dc
	call FillMemory
	ret


.party
;> FillMemory(wPartyBarTiles, 0x40, 0xE0)
	ld hl, wPartyBarTiles
	ld bc, $0040
	ld a, $e0
	call FillMemory
;> if wPartyCount == 0:
;>     return
	ld a, [wPartyCount]
	or a
	ret z

;> BuildStatusBarEntry(0, wPartyBarTiles)
	ld hl, wPartyBarTiles
	ld a, $00
	call BuildStatusBarEntry
;> if wPartyCount == 1:
;>     return
	ld a, [wPartyCount]
	cp $01
	ret z

;> BuildStatusBarEntry(1, wPartyBarTiles + 7)
	ld hl, wPartyBarTiles + 7
	ld a, $01
	call BuildStatusBarEntry
;> if wPartyCount == 2:
;>     return
	ld a, [wPartyCount]
	cp $02
	ret z

;> BuildStatusBarEntry(2, wPartyBarTiles + 14)
	ld hl, wPartyBarTiles + 14
	ld a, $02
	call BuildStatusBarEntry
	ret


;@ def BuildStatusBarEntry(pos: a, dest: hl)
;@ path: menu/statusbar
;@ One party monster's entry in the status bar buffer. With wStatusBarMode 0:
;@ the monster's number (tile $DA + pos), $E1 $E3 and its HP, and below $E2 $E3
;@ and its MP (3 digits each). Else: number, $DE $DF $E4 and its level (2
;@ digits), and below status icons $D7 (status bit 0), $D8 (bit 2) and $D9
;@ (bit 7) two columns apart.
;@ test: skip writes through WriteVRAM
BuildStatusBarEntry::
;> hNumber[0] = pos
	ldh [hNumber], a
;> if wStatusBarMode == 0:
	ld a, [wStatusBarMode]
	or a
	jr nz, .level

;>     mem[dest] = 0xDA + pos
	push hl
	ldh a, [hNumber]
	add $da
	ld [hli], a
;>     mem[dest + 1] = 0xE1
	ld a, $e1
	ld [hli], a
;>     mem[dest + 2] = 0xE3
	ld a, $e3
	ld [hli], a
;>     hp = GetPartyMonsterWord(pos, addr(wMonHP))
	push hl
	ld hl, wMonHP
	ldh a, [hNumber]
	call GetPartyMonsterWord
;>     PrintNumber3(dest + 3, hp)
	pop hl
	call PrintNumber3
;>@r2     row2 = dest + 0x20
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
;=@r2
	ld h, a
;>     mem[row2] = 0xE0
	ld a, $e0
	ld [hli], a
;>     mem[row2 + 1] = 0xE2
	ld a, $e2
	ld [hli], a
;>     mem[row2 + 2] = 0xE3
	ld a, $e3
	ld [hli], a
;>     mp = GetPartyMonsterWord(pos, addr(wMonMP))
	push hl
	ld hl, wMonMP
	ldh a, [hNumber]
	call GetPartyMonsterWord
;>     PrintNumber3(row2 + 3, mp)
	pop hl
	call PrintNumber3
	ret


.level
;> else:
;>     mem[dest] = 0xDA + pos
	push hl
	ldh a, [hNumber]
	add $da
	ld [hli], a
;>     mem[dest + 1] = 0xDE
	ld a, $de
	ld [hli], a
;>     mem[dest + 2] = 0xDF
	ld a, $df
	ld [hli], a
;>     mem[dest + 3] = 0xE4
	ld a, $e4
	ld [hli], a
;>     level = GetPartyMonsterByte(pos, addr(wMonLevel))
	push hl
	ld hl, wMonLevel
	ldh a, [hNumber]
	call GetPartyMonsterByte
;>     PrintNumber2(dest + 4, level)
	pop hl
	ld c, a
	ld b, $00
	call PrintNumber2
;>@ic     icons = dest + 0x21
	pop hl
	ld a, l
	add $21
	ld l, a
	ld a, h
	adc $00
;=@ic
	ld h, a
;>     status = GetPartyMonsterByte(pos, addr(wMonStatus))
	push hl
	ld hl, wMonStatus
	ldh a, [hNumber]
	call GetPartyMonsterByte
	ld b, a
	pop hl
;>     mem[icons] = 0xD7 if status & 0x01 else 0xE0
	bit 0, b
	ld a, $e0
	jr z, .icon1

	ld a, $d7

.icon1
;>     mem[icons + 2] = 0xD8 if status & 0x04 else 0xE0
	ld [hli], a
	inc hl
	bit 2, b
	ld a, $e0
	jr z, .icon2

	ld a, $d8

.icon2
;>@i3     mem[icons + 4] = 0xD9 if status & 0x80 else 0xE0
	ld [hli], a
	inc hl
	bit 7, b
	ld a, $e0
	jr z, .icon3

	ld a, $d9

.icon3
;=@i3
	ld [hl], a
	ret


;@ def DrawStatusBar()
;@ path: menu/statusbar
;@ Copies the status bar buffer (2 rows of 20 tiles from wPartyBarTiles) to
;@ the BG map rows that are the bottom two of the screen (16 rows below the
;@ scroll position), with CGB palette 7.
;@ test: skip writes through WriteVRAM
DrawStatusBar::
;>@a row = (hScrollY >> 3) + 16
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
;=@a
	sla l
	rla
	ld h, $98
	add h
	ld h, a
;>@b dest = 0x9800 + (row * 32 + (hScrollX >> 3) & 0x3FF)   # wraps within the map
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	and $1f
	add l
;=@b
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	add $00
;=@b
	ld l, a
	ld a, h
	adc $02
	ld h, a
	res 2, h
;> src = wPartyBarTiles
	ld de, wPartyBarTiles
;>@rows for _ in range(2):
	ld c, $02

.row
;>     line_start = dest
;>@cols     for col in range(20):
	ld b, $14
	push hl

.col
;>         WriteVRAM(mem[src], dest)
	ld a, [de]
	call WriteVRAM
;>         WriteVRAMAttr(7, dest)
	ld a, $07
	call WriteVRAMAttr
;>@nc         dest = NextTileColumn(dest)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@nc
	ld l, a
	pop af
	or l
	ld l, a
;>         src += 1
	inc de
;=@cols
	dec b
	jr nz, .col

;>@s12     src += 12                      # to the next 32-tile row
	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
;=@s12
	ld d, a
;>@dn     dest = 0x9800 | (line_start + 0x20) & 0x3FF
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
	or $98
;=@dn
	ld h, a
;=@rows
	pop bc
	dec c
	jr nz, .row

	ret


;@ def IsInGateWorld() -> a
;@ path: field/map
;@ 1 (flags nz) on a gate floor and on the maps from $30 on (the worlds),
;@ except maps $5D and $5E; 0 (z) on the maps of the town and the castle.
IsInGateWorld::
;> if wOnGateFloor:
;>@y     return 1
	ld a, [wOnGateFloor]
	or a
	jr nz, .yes

;> if wMapId == 0x5D or wMapId == 0x5E:
;>@n     return 0
	ld a, [wMapId]
	cp $5d
	jr z, .no

	cp $5e
	jr z, .no

;> if wMapId >= 0x30:
;>@y     return 1
	ld a, [wMapId]
	cp $30
	jr nc, .yes

.no
;=@n
;> return 0
	xor a
	ret


.yes
;=@y
	ld a, $01
	or a
	ret


;@ def SetFlag(index: a, flags: hl)
;@ path: system/flags
;@ Sets bit `index` of the bit field at `flags` (bit 7 of the first byte is
;@ flag 0). The bytes after it are an unused ClearFlag.
SetFlag::
;> p, mask = FlagMask(index, flags)
	call FlagMask
;> mem[p] |= mask
	or [hl]
	ld [hl], a
	ret


	db $cd, $83, $26, $ee, $ff, $a6, $77, $c9

;@ def TestFlag(index: a, flags: hl) -> a
;@ path: system/flags
;@ Nonzero (flags nz) when bit `index` of the bit field at `flags` is set.
TestFlag::
;> p, mask = FlagMask(index, flags)
	call FlagMask
;> return mem[p] & mask
	and [hl]
	ret


;@ def FlagMask(index: a, flags: hl) -> (hl, a)
;@ path: system/flags
;@ Byte and bit mask of flag `index` in a bit field: flags + index / 8 and
;@ BitMasks[index % 8].
FlagMask::
;>@p p = u16(flags + (index >> 3))
	push af
	srl a
	srl a
	srl a
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
;> mask = mem[BitMasks + (index & 7)]
	pop af
	push hl
	ld hl, BitMasks
	and $07
	add l
	ld l, a
;=@m
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>@m return p, mask
	pop hl
	ret


;@ def SetEventFlag(index: bc)
;@ path: event/flags
;@ Sets story / event flag `index` in wEventFlags.
SetEventFlag::
;> p, mask = EventFlagMask(index)
	call EventFlagMask
;> mem[p] |= mask
	or [hl]
	ld [hl], a
	ret


;@ def ClearEventFlag(index: bc)
;@ path: event/flags
;@ Clears story / event flag `index` in wEventFlags.
ClearEventFlag::
;> p, mask = EventFlagMask(index)
	call EventFlagMask
;> mem[p] &= ~mask & 0xFF
	xor $ff
	and [hl]
	ld [hl], a
	ret


;@ def TestEventFlag(index: bc) -> a
;@ path: event/flags
;@ Nonzero (flags nz) when story / event flag `index` is set.
TestEventFlag::
;> p, mask = EventFlagMask(index)
	call EventFlagMask
;> return mem[p] & mask
	and [hl]
	ret


;@ def EventFlagMask(index: bc) -> (hl, a)
;@ path: event/flags
;@ Byte and bit mask of event flag `index`: wEventFlags + index / 8 and
;@ BitMasks[index % 8].
EventFlagMask::
;>@p p = u16(addr(wEventFlags) + (index >> 3))
	push bc
	srl b
	rr c
	srl b
	rr c
	srl b
;=@p
	rr c
	ld hl, wEventFlags
	add hl, bc
	pop bc
;> mask = mem[BitMasks + (index & 7)]
	push hl
	ld hl, BitMasks
	ld a, c
	and $07
	add l
	ld l, a
;=@m
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>@m return p, mask
	pop hl
	ret


;@ path: system/flags
;@ Bit masks of the bits 0-7 of a flag byte, flag 0 first (FlagMask,
;@ EventFlagMask).
BitMasks::
	db $80, $40, $20, $10, $08, $04, $02, $01

;@ path: field/map
;@ The fixed maps (town, Great Tree rooms, the worlds' fixed maps), indexed by
;@ wMapId, 8 bytes each (112 maps): byte 0 far-table entry and byte 1 bank of
;@ the compressed BG tile graphics (loaded to $9000), bytes 2-3 the map width
;@ and 4-5 its height in pixels (u16), byte 6 the first solid tile (BG tiles
;@ from this number on block the way, GetCollisionAt), byte 7 unused (0). Map 0
;@ and several unused slots repeat the record 2A:00, 320 x 256, $57.
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
	db $12, $24, $a0, $00, $80, $00, $50, $00

;@ path: field/map
;@ The randomly generated floors behind the gates, indexed by wMapId while
;@ wOnGateFloor is set: 16 records in the MapInfo format. All are 640 x 512
;@ pixels (4 x 4 screens) with first solid tile $30; the tile graphics are
;@ entries 0-15 of bank $28 (one look per world).
GateFloorMapInfo::
	db $00, $28, $80, $02, $00, $02, $30, $00
	db $01, $28, $80, $02, $00, $02, $30, $00, $02, $28, $80, $02, $00, $02, $30, $00
	db $03, $28, $80, $02, $00, $02, $30, $00, $04, $28, $80, $02, $00, $02, $30, $00
	db $05, $28, $80, $02, $00, $02, $30, $00, $06, $28, $80, $02, $00, $02, $30, $00
	db $07, $28, $80, $02, $00, $02, $30, $00, $08, $28, $80, $02, $00, $02, $30, $00
	db $09, $28, $80, $02, $00, $02, $30, $00, $0a, $28, $80, $02, $00, $02, $30, $00
	db $0b, $28, $80, $02, $00, $02, $30, $00, $0c, $28, $80, $02, $00, $02, $30, $00
	db $0d, $28, $80, $02, $00, $02, $30, $00, $0e, $28, $80, $02, $00, $02, $30, $00
	db $0f, $28, $80, $02, $00, $02, $30, $00

;@ path: system/sgb
;@ Super Game Boy palette set (byte 0) and attribute file (byte 1) of the
;@ field, read by InitSGBPalettes; both 0.
FieldSGBSettings::
	db $00, $00

;@ path: gfx/sprites
;@ Sprite graphics of the people on the field, by graphics number ($00-$5F), one
;@ u16 per sprite set: far-table entry in the low byte, bank in the high byte
;@ (banks $2E-$3A). Decompressed by LoadActorGfx and LoadFieldActorGfx. The
;@ monster picture table MonsterPicRefs follows directly.
ActorGfx::
	db $00, $31, $01, $31, $02, $31
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
	db $3a, $31, $3a, $31, $3a, $31, $00, $2f, $19, $2e

;@ path: monster/pictures
;@ The big picture of each monster, by species number: one u16 per species,
;@ far-table entry in the low byte, bank in the high byte (banks $2F and
;@ $32-$36). Read by LoadMonsterPicture and the other picture loaders, which
;@ pass the entry to DecompressVRAM. 260 entries: the first 216 are distinct
;@ pictures, the rest all repeat 32:0F.
MonsterPicRefs::
	db $11, $2f, $12, $2f, $13, $2f
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
	db $0f, $32

;@ path: field/floors
;@ Top left corners of the 16 screens of a gate floor (4 x 4 screens of
;@ 160 x 128 pixels), as X, Y pairs in pixels (u16 each), row by row.
ScreenOrigins::
	db $00, $00, $00, $00, $a0, $00, $00, $00, $40, $01, $00, $00, $e0, $01
	db $00, $00, $00, $00, $80, $00, $a0, $00, $80, $00, $40, $01, $80, $00, $e0, $01
	db $80, $00, $00, $00, $00, $01, $a0, $00, $00, $01, $40, $01, $00, $01, $e0, $01
	db $00, $01, $00, $00, $80, $01, $a0, $00, $80, $01, $40, $01, $80, $01, $e0, $01
	db $80, $01

;@ path: field/floors
;@ The same 16 screen corners as X, Y byte pairs in 16-pixel map blocks (10 x 8
;@ blocks per screen).
ScreenTileOrigins::
	db $00, $00, $0a, $00, $14, $00, $1e, $00, $00, $08, $0a, $08, $14, $08
	db $1e, $08, $00, $10, $0a, $10, $14, $10, $1e, $10, $00, $18, $0a, $18, $14, $18
	db $1e, $18

;@ path: menu/windows
;@ The message window at the bottom of the screen, in the window layout format
;@ (DrawTilemap): u16 BG map offset ($01A0 = row 13), then tiles, $D8 = next
;@ row, $D9 = end. A 20 x 5 frame (corners $FA $FB $FC $FD, edges $EF $EE
;@ $FE $FF) around the text box's two lines of letter tiles ($B0-$C1 and
;@ $C2-$D3) with a blank row ($E0) between them. Used by the window drawers of
;@ many banks.
MessageWindowLayout::
	db $a0, $01

;@ path: menu/windows
;@ The tiles of MessageWindowLayout after its offset word (the layout goes on
;@ here; nothing refers to this address itself).
NamePlateWindows::
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5
	db $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd
	db $ce, $cf, $d0, $d1, $d2, $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: menu/windows
;@ The same message window at the top of the screen (offset 0). No code that
;@ uses it was found.
MessageWindowLayoutTop::
	db $00, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba
	db $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $c2
	db $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0, $d1, $d2
	db $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ def SerialInterruptEntry()
;@ path: system/interrupts
;@ Serial interrupt (reached from the vector at $0058): saves the registers and
;@ runs SerialInterruptHandler in bank 3, the link cable protocol.
;@ test: skip interrupt handler
SerialInterruptEntry::
;> SerialInterruptHandler()               # registers saved around it
	push af
	push bc
	push de
	push hl
	ld hl, far_SerialInterruptHandler
	rst $10
;> return                                 # reti
	pop hl
	pop de
	pop bc
	pop af
	reti


;@ def LCDInterruptHandler()
;@ path: system/interrupts
;@ LCD STAT interrupt (on the LY=LYC line): runs the raster effect wLCDEffect
;@ from LCDEffectTable.
;@ test: skip interrupt handler
LCDInterruptHandler::
;> LCDEffectTable[wLCDEffect]()
	push af
	push bc
	push de
	push hl
	ld a, [wLCDEffect]
	rst $00

;@ path: system/interrupts
;@ Raster effects of the LCD interrupt, indexed by wLCDEffect: 0 none, 1 hide
;@ the sprites from the LYC line down (under a window), 2 and 3 a wave that
;@ sets the X or Y scroll of every second line from wLineScroll.
LCDEffectTable::
	dw LCDInterruptReturn
	dw LCDEffectHideSprites
	dw LCDEffectWaveX
	dw LCDEffectWaveY

;@ def LCDEffectHideSprites()
;@ path: system/interrupts
;@ Waits for the HBlank of the LYC line and switches the sprites off for the
;@ rest of the frame.
;@ test: skip interrupt handler
LCDEffectHideSprites::
;> wait_hblank()
	ldh a, [rSTAT]
	and $03
	jr nz, LCDEffectHideSprites

;> rLCDC &= ~0x02                         # sprites off
	ldh a, [rLCDC]
	res 1, a
	ldh [rLCDC], a
;> LCDInterruptReturn()
	jr LCDInterruptReturn

;@ def LCDEffectWaveX()
;@ path: system/interrupts
;@ Sets rSCX from wLineScroll for this line and asks for the interrupt again
;@ two lines further; from line 128 on the normal scroll is restored and the
;@ next frame starts at line 1.
;@ test: skip interrupt handler
LCDEffectWaveX::
;> rSCX = wLineScroll[rLY]
	ldh a, [rLY]
	ld l, a
	ld h, HIGH(wLineScroll)
	ld a, [hl]
	ldh [rSCX], a
;> rLYC += 2
	ldh a, [rLYC]
	add $02
	ldh [rLYC], a
;> if rLYC >= 0x80:
	cp $80
	jr c, LCDInterruptReturn

;>     rSCX = lo(hScrollX)
	ldh a, [hScrollX]
	ldh [rSCX], a
;>     rLYC = 1
	ld a, $01
	ldh [rLYC], a
;> LCDInterruptReturn()
	jr LCDInterruptReturn

;@ def LCDEffectWaveY()
;@ path: system/interrupts
;@ Like LCDEffectWaveX for rSCY (up to line 129, restarting at line 0).
;@ test: skip interrupt handler
LCDEffectWaveY::
;> rSCY = wLineScroll[rLY]
	ldh a, [rLY]
	ld l, a
	ld h, HIGH(wLineScroll)
	ld a, [hl]
	ldh [rSCY], a
;> rLYC += 2
	ldh a, [rLYC]
	add $02
	ldh [rLYC], a
;> if rLYC >= 0x81:
	cp $81
	jr c, LCDInterruptReturn

;>     rSCY = lo(hScrollY)
	ldh a, [hScrollY]
	ldh [rSCY], a
;>     rLYC = 0
	ld a, $00
	ldh [rLYC], a
;> LCDInterruptReturn()
	jr LCDInterruptReturn

;@ def LCDInterruptReturn()
;@ path: system/interrupts
;@ End of the LCD interrupt: restores the registers and returns with reti.
;@ test: skip interrupt handler
LCDInterruptReturn::
;> return                                 # registers restored, reti
	pop hl
	pop de
	pop bc
	pop af
	reti


;@ def CompareHLBC(x: hl, y: bc) -> zero
;@ path: system/math
;@ Sets the zero flag when x == y (carry as for the compare of the high bytes,
;@ or of the low bytes when those are equal).
CompareHLBC::
;> if hi(x) != hi(y):
;>     return False
	ld a, h
	cp b
	ret nz

;> return lo(x) == lo(y)
	ld a, l
	cp c
	ret


;@ def DivideHLBC(n: hl, d: bc) -> (hl, bc)
;@ path: system/math
;@ 16 by 16 bit division: quotient in hl, remainder in bc. Divisors below 256
;@ go through Divide16, larger ones are subtracted repeatedly.
;@ test: d = rng.randint(1, 0xFFFF)
DivideHLBC::
;> if hi(d) != 0:
;>@big     return n // d, n % d
	ld de, $0000
	ld a, b
	or a
	jr z, .small

.loop
;=@big
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
;=@big
	jr c, .done

	inc de
	jr .loop

.small
;> q, r = Divide16(n, lo(d))
	ld a, c
	call Divide16
;> return q, r
	ld c, a
	ld b, $00
	jr .ret

.done
;=@big
	add hl, bc
	ld b, h
	ld c, l
	ld h, d
	ld l, e

.ret
	ret


;@ def AddEightTimes(n: a, base: hl) -> hl
;@ path: system/math
;@ base + 8 * n (8 * n must fit in a byte), for tables of 8-byte records.
AddEightTimes::
;>@r return u16(base + (n * 8 & 0xFF))
	add a
	add a
	add a
	add l
	ld l, a
;=@r
	ld a, $00
	adc h
	ld h, a
	ret


;@ def CheckBattlerCanAct(pos: a) -> carry
;@ path: battle/state
;@ Carry when the monster at battle position `pos` cannot act: it is not in the
;@ fight (CheckBattlerPresent), or one of its status flags is set (bits $D0 of
;@ status byte 0, $3F of byte 3, $C0 of byte 5 in wBattlerStatus).
;@ test: pos = rng.randint(0, 9)
CheckBattlerCanAct::
;> if CheckBattlerPresent(pos):
;>@x     return True
	push hl
	push bc
	ld c, a
	call CheckBattlerPresent
	jr c, .return

;>@s status = wBattlerStatus + 8 * pos
	ld a, c
	ld hl, wBattlerStatus
	add a
	add a
	add a
	add l
;=@s
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> if mem[status] & 0xD0:
;>@y     return True
	ld a, [hli]
	and $d0
	jr nz, .cannot

;> if mem[status + 3] & 0x3F:
;>@y     return True
	inc hl
	inc hl
	ld a, [hli]
	and $3f
	jr nz, .cannot

;> if mem[status + 5] & 0xC0:
;>@y     return True
	inc hl
	ld a, [hl]
	and $c0
	jr nz, .cannot

;> return False
	xor a
	jr .return

.cannot
;=@y
	scf

.return
;=@x
	ld a, c
	pop bc
	pop hl
	ret


;@ def CheckBattlerPresent(pos: a) -> carry
;@ path: battle/state
;@ Carry when battle position `pos` (0-7) has no monster in the fight:
;@ wBattlerState is not 0 (or `pos` is out of range).
;@ test: pos = rng.randint(0, 9)
CheckBattlerPresent::
;> if pos >= 8:
;>@n     return True
	push hl
	push bc
	ld c, a
	cp $08
	jr nc, .none

;>@st state = wBattlerState[pos]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@st
	ld a, [hl]
;> if state == 0:
;>@p     return False
	and a
	jr z, .present

;> if state == 0xFF:
;>@n     return True
	cp $ff
	jr z, .none

;> return True                            # out of action
	scf
	jr .done

.none
;=@n
	xor a
	scf
	jr .done

.present
;=@p
	ld a, $0a
	cp $01

.done
	ld a, c
	pop bc
	pop hl
	ret


;@ def GetBattlerAttack(pos: a) -> hl
;@ path: battle/state
;@ Attack of the monster at battle position `pos`.
GetBattlerAttack::
;> return GetWordFromTable(pos, addr(wBattlerAttack))
	ld hl, wBattlerAttack
	call GetWordFromTable
	ret


;@ def GetBattlerDefense(pos: a) -> hl
;@ path: battle/state
;@ Defense of the monster at battle position `pos`.
GetBattlerDefense::
;> return GetWordFromTable(pos, addr(wBattlerDefense))
	ld hl, wBattlerDefense
	call GetWordFromTable
	ret


;@ def GetBattlerMaxHP(pos: a) -> hl
;@ path: battle/state
;@ Maximum HP of the monster at battle position `pos`.
GetBattlerMaxHP::
;> return GetWordFromTable(pos, addr(wBattlerMaxHP))
	ld hl, wBattlerMaxHP
	call GetWordFromTable
	ret


;@ def GetBattlerMaxMP(pos: a) -> hl
;@ path: battle/state
;@ Maximum MP of the monster at battle position `pos`.
GetBattlerMaxMP::
;> return GetWordFromTable(pos, addr(wBattlerMaxMP))
	ld hl, wBattlerMaxMP
	call GetWordFromTable
	ret


;@ def GetBattlerHP(pos: a) -> hl
;@ path: battle/state
;@ HP of the monster at battle position `pos`.
GetBattlerHP::
;> return GetWordFromTable(pos, addr(wBattlerHP))
	ld hl, wBattlerHP
	call GetWordFromTable
	ret


;@ def GetBattlerMP(pos: a) -> hl
;@ path: battle/state
;@ MP of the monster at battle position `pos`.
GetBattlerMP::
;> return GetWordFromTable(pos, addr(wBattlerMP))
	ld hl, wBattlerMP
	call GetWordFromTable
	ret


;@ def GetWordFromTable(index: a, table: hl) -> hl
;@ path: system/memory
;@ Entry `index` of a table of 16-bit words.
GetWordFromTable::
;>@w return mem16[u16(table + (2 * index & 0xFF))]   # (2 * index wraps at 8 bits)
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@w
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret


;@ def UpdateSkillAnimation()
;@ path: battle/animation
;@ Draws the sprites of the running skill animation (wSkillAnim) each frame,
;@ through the animation banks $5C (animations below $0E), $5D (below $21) and
;@ $5E. Animation $2C, and $15 for skill $C5, are drawn once over each enemy
;@ still standing (X $50 for one enemy, $38/$68 for two, $20/$50/$80 for
;@ three). Nothing is drawn when the skill's user and target are both on this
;@ Game Boy's own side. StartSkillAnimSprites, after it, starts the sprites
;@ (and sets the sprite palettes from SkillAnimOBP0).
;@ test: skip calls routines in other banks
UpdateSkillAnimation::
;> if not wSkillAnimActive:
;>     return
	ld a, [wSkillAnimActive]
	or a
	ret z

;> side = (wLinkFlags & 0x02) << 1        # 4 on the clock-driving Game Boy: the sides swap
	ld a, [wLinkFlags]
	and $02
	sla a
	ld b, a
;>@w if (wSkillUser ^ side) < 4 and (wSkillTarget ^ side) < 4:   # own side only
	ld a, [wSkillUser]
	xor b
	cp $04
	jr nc, .draw

	ld a, [wSkillTarget]
	xor b
;=@w
	cp $04
	jr nc, .draw

;>     wSkillAnimSprites = 0
	ld a, $00
	ld [wSkillAnimSprites], a
;>     wBattleAnimRunning = 0
;>     return
	ld a, $00
	ld [wBattleAnimRunning], a
	ret


.draw
;> GetSkillAnim()                         # animation step
	ld hl, far_GetSkillAnim
	rst $10
;> anim = wSkillAnim
;> if anim == 0xFF:
	ld a, [wSkillAnim]
	cp $ff
	ret z

;>     return
;> if anim < 0x0E:
;>@c5     DrawSkillAnimSprite_5C()
	cp $0e
	jr c, .bank5C

;> elif anim == 0x15:
;>@s     if wSkillId != 0xC5:
;>@d         DrawSkillAnimSprite_5D()
	cp $15
	jr z, .anim15

;> elif anim < 0x21:
;>@d     DrawSkillAnimSprite_5D()
	cp $21
	jr c, .bank5D

;> elif anim != 0x2C:
;>     DrawSkillAnimSprite_5E()
	cp $2c
	jr z, .eachEnemy

	ld hl, far_DrawSkillAnimSprite_5E
	rst $10
	ret


.bank5C
;=@c5
	ld hl, far_DrawSkillAnimSprite_5C
	rst $10
	ret


.bank5D
;=@d
	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	ret


.anim15
;=@s
	ld a, [wSkillId]
	cp $c5
	jr nz, .bank5D

.eachEnemy
;> if anim == 0x2C or anim == 0x15 and wSkillId == 0xC5:   # once over each enemy
;>     if wEnemyCount == 1:
;>@o1         if not wEnemyDown[0]:
;>@o2             hSpriteX = 0x50
;>@o3             if anim == 0x15:
;>@o4                 DrawSkillAnimSprite_5D()
;>             else:
;>@o5                 DrawSkillAnimSprite_5E()
	ld a, [wEnemyCount]
	cp $01
	jr z, .one

;>     elif wEnemyCount == 2:
;>@t1         if not wEnemyDown[0]:
;>@t2             hSpriteX = 0x38
;>@t3             if anim == 0x15:
;>@t4                 DrawSkillAnimSprite_5D()
;>             else:
;>@t5                 DrawSkillAnimSprite_5E()
;>@t6         if not wEnemyDown[1]:
;>@t7             hSpriteX = 0x68
;>@t8             if anim == 0x15:
;>@t9                 DrawSkillAnimSprite_5D()
;>             else:
;>@ta                 DrawSkillAnimSprite_5E()
	cp $02
	jr z, .two

;>     else:
;>         if not wEnemyDown[0]:
	ld a, [wEnemyDown]
	or a
	jr nz, .third2

;>             hSpriteX = 0x20
	ld a, $20
	ldh [hSpriteX], a
;>             if anim == 0x15:
	ld a, [wSkillAnim]
	cp $15
	jr nz, .third1E

;>                 DrawSkillAnimSprite_5D()
	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	jr .third2

.third1E
;>             else:
;>                 DrawSkillAnimSprite_5E()
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10

.third2
;>         if not wEnemyDown[1]:
	ld a, [wEnemyDown + 1]
	or a
	jr nz, .third3

;>             hSpriteX = 0x50
	ld a, $50
	ldh [hSpriteX], a
;>             if anim == 0x15:
	ld a, [wSkillAnim]
	cp $15
	jr nz, .third2E

;>                 DrawSkillAnimSprite_5D()
	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	jr .third3

.third2E
;>             else:
;>                 DrawSkillAnimSprite_5E()
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10

.third3
;>         if not wEnemyDown[2]:
	ld a, [wEnemyDown + 2]
	or a
	ret nz

;>             hSpriteX = 0x80
	ld a, $80
	ldh [hSpriteX], a
;>             if anim == 0x15:
	ld a, [wSkillAnim]
	cp $15
	jr nz, .third3E

;>                 DrawSkillAnimSprite_5D()
	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	ret


.third3E
;>             else:
;>                 DrawSkillAnimSprite_5E()
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10
	ret


.one
;=@o1
	ld a, [wEnemyDown]
	or a
	ret nz

;=@o2
	ld a, $50
	ldh [hSpriteX], a
;=@o3
	ld a, [wSkillAnim]
	cp $15
	jr nz, .oneE

;=@o4
	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	ret


.oneE
;=@o5
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10
	ret


.two
;=@t1
	ld a, [wEnemyDown]
	or a
	jr nz, .two2

;=@t2
	ld a, $38
	ldh [hSpriteX], a
;=@t3
	ld a, [wSkillAnim]
	cp $15
	jr nz, .twoE

;=@t4
	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	jr .two2

.twoE
;=@t5
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10

.two2
;=@t6
	ld a, [wEnemyDown + 1]
	or a
	ret nz

;=@t7
	ld a, $68
	ldh [hSpriteX], a
;=@t8
	ld a, [wSkillAnim]
	cp $15
	jr nz, .two2E

;=@t9
	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	ret


.two2E
;=@ta
	ld hl, far_DrawSkillAnimSprite_5E
	rst $10
	ret


;@ def StartSkillAnimSprites()
;@ path: battle/animation
;@ Starts the sprites of the skill animation (GetSkillAnim): sprite palettes OBP1 $E0 and
;@ OBP0 from SkillAnimOBP0, then the animation's start routine in bank $5C (animations below
;@ $0E), $5D (below $21) or $5E. Called by StartSkillAnimation in bank $5F and by the battle
;@ code.
;@ test: skip calls routines in other banks
StartSkillAnimSprites::
;> GetSkillAnim()
	ld hl, far_GetSkillAnim
	rst $10
;> anim = wSkillAnim
;> if anim == 0xFF:
	ld a, [wSkillAnim]
	cp $ff
;>     return
	ret z

;> wOBP0 = 0xD0
	ld hl, wBGP
	inc hl
	ld a, $d0
	ld [hli], a
;> wOBP1 = 0xE0
	ld a, $e0
	ld [hl], a
;> p = SkillAnimOBP0 + anim
	ld hl, SkillAnimOBP0
	ld a, [wSkillAnim]
	add l
	ld l, a
	ld a, $00
	adc h
;> wOBP0 = mem[p]
	ld h, a
	ld a, [hl]
	ld [wOBP0], a
;> if anim < 0x0E:
;>@c     StartSkillAnimSprite_5C(wSkillAnim)
	ld a, [wSkillAnim]
	cp $0e
	jr c, .bank5C

;> elif anim < 0x21:
;>@d     StartSkillAnimSprite_5D(wSkillAnim)
	cp $21
	jr c, .bank5D

;> else:
;>     StartSkillAnimSprite_5E(wSkillAnim)
	ld hl, far_StartSkillAnimSprite_5E
	rst $10
	ret


.bank5C
;=@c
	ld hl, far_StartSkillAnimSprite_5C
	rst $10
	ret


.bank5D
;=@d
	ld hl, far_StartSkillAnimSprite_5D
	rst $10
	ret

;@ path: battle/animation
;@ OBP0 sprite palette for each skill animation number ($D0 or $E0, 45
;@ entries), set by StartSkillAnimSprites.
SkillAnimOBP0::
	db $e0, $e0
	db $e0, $e0, $e0, $e0, $d0, $d0, $d0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $d0, $d0, $e0, $e0, $e0, $e0, $e0, $d0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $d0

;@ path: sound/data
;@ The 16 wave patterns of the wave channel, 16 bytes each (32 4-bit samples,
;@ high nibble first), as copied to wave RAM $FF30 (event $A1, the channel
;@ header's fourth byte).
WavePatterns::
	db $00, $01, $12, $35, $8a
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
	db $dd, $dd, $dd, $22, $22, $22, $22, $22, $22, $22, $22

;@ path: sound/data
;@ Instrument envelopes (event $A8 picks one; only instrument 0 exists): a
;@ pointer to its rows, then 12 rows of 16 steps (row n is chosen by event $Cn,
;@ the step is the position within the note). Step byte: high nibble a row of
;@ InstrumentVolumes, bit 3 envelope direction up, bit 2 no sweep pace, bit 1
;@ half pace, bit 0 always rewrite the envelope. The last byte ($C9) is
;@ padding.
InstrumentTable::
	dw InstrumentTable + 2
	db $f1, $d0, $b0
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

;@ def InitSound()
;@ path: sound/engine
;@ Resets the sound engine: sound on, all outputs off, master volume full, all
;@ six channels free. The bytes after it are two unused routines: one lets all
;@ channel records run again (wSoundFirstChannel = 0); the other sets
;@ wSoundFirstChannel to 4 and clears wSoundPanning, so only records 4-5, the
;@ music's wave and noise parts, keep playing (records 0-1 are the sound
;@ effects, 2-5 the music).
;@ test: skip writes the sound registers
InitSound::
;> SetSyncedBankSwitch(0, 0)
	ld bc, $0000
	call SetSyncedBankSwitch
;> rNR52 = 0x80                           # sound on
	ld a, $80
	ldh [rNR52], a
;> rNR51 = 0
	xor a
	ldh [rNR51], a
;> wSoundPanning = 0
	ld [wSoundPanning], a
;> rNR50 = 0x77                           # full volume left and right
	ld a, $77
	ldh [rNR50], a
;> chan = wSoundChannels
	ld hl, wSoundChannels
;>@ch for _ in range(6):
	ld b, $06
	ld a, $ff

.loop
;>     mem[chan] = 0xFF                   # event number $FFFF: channel free
	ld [hl], a
;>     mem[chan + 25] = 0xFF
	ld de, $0019
	add hl, de
	ld [hl], a
;>     chan += 26
	ld de, $0001
	add hl, de
;=@ch
	dec b
	jr nz, .loop

;> wSoundFirstChannel = 0
	xor a
	ld [wSoundFirstChannel], a
	ret


	db $af, $ea, $29, $de, $c9, $3e, $04, $ea, $29, $de, $af, $ea, $1d, $de, $c9

;@ def SetSyncedBankSwitch(channels: b, bank: c)
;@ path: sound/engine
;@ Arms a synchronised switch: once all channels in the bit mask `channels`
;@ start a new note in the same frame, their sound bank's low nibble becomes
;@ `bank` (ApplySyncedBankSwitch).
SetSyncedBankSwitch::
;> wSyncSwitchChannels = channels
	ld a, b
	ld [wSyncSwitchChannels], a
;> wSyncSwitchBank = bank
	ld a, c
	ld [wSyncSwitchBank], a
;> wSyncNoteEnds = 0
	xor a
	ld [wSyncNoteEnds], a
	ret


;@ def MarkNoteEnd()
;@ path: sound/engine
;@ Notes in wSyncNoteEnds that channel wSoundCurChannel starts a new note.
;@ test: wSoundCurChannel = rng.randint(0, 7)
MarkNoteEnd::
;>@b bit = 1 << wSoundCurChannel
	ld a, [wSoundCurChannel]
	inc a
	ld b, a
	ld a, $01

.shift
;=@b
	dec b
	jr z, .gotBit

	add a
	jr .shift

.gotBit
;> wSyncNoteEnds |= bit
	ld b, a
	ld a, [wSyncNoteEnds]
	or b
	ld [wSyncNoteEnds], a
	ret


;@ def ApplySyncedBankSwitch()
;@ path: sound/engine
;@ End of a sound update: when every channel of wSyncSwitchChannels started a
;@ new note this frame, their sound bank (record byte 4) gets the low nibble
;@ wSyncSwitchBank and the switch is disarmed. wSyncNoteEnds is cleared.
ApplySyncedBankSwitch::
;> if (wSyncNoteEnds & wSyncSwitchChannels) == wSyncSwitchChannels:
	ld a, [wSyncNoteEnds]
	ld hl, wSyncSwitchChannels
	and [hl]
	cp [hl]
	jr nz, .done

;>     p = wSoundChannels + 4             # the bank byte of channel 0
	ld hl, wSoundChannels + 4
;>     bank = wSyncSwitchBank & 0x0F
	ld a, [wSyncSwitchBank]
	and $0f
	ld b, a
;>     mask = wSyncSwitchChannels
	ld a, [wSyncSwitchChannels]

.loop
;>@lp     for _ in forever():
;>         wSyncNoteEnds = mask >> 1
	srl a
	ld [wSyncNoteEnds], a
;>         if mask & 1:
	jr nc, .next

;>             mem[p] = mem[p] & 0xF0 | bank
	ld a, [hl]
	and $f0
	or b
	ld [hl], a

.next
;>         p += 26
	ld a, l
	add $1a
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>         mask >>= 1
;>         if not mask:
	ld a, [wSyncNoteEnds]
	and a
;>             break
;=@lp
	jr nz, .loop

;>     wSyncSwitchChannels = 0
	xor a
	ld [wSyncSwitchChannels], a

.done
;> wSyncNoteEnds = 0
	xor a
	ld [wSyncNoteEnds], a
	ret


;@ def StartSounds4()
;@ path: sound/engine
;@ Starts the four channel parts wSoundID, wSoundID + 1, ... of a song.
;@ test: skip switches ROM banks
StartSounds4::
;> StartSoundChannel()
;> StartSounds3()                         # runs on into it
	call StartSoundChannel

;@ def StartSounds3()
;@ path: sound/engine
;@ Starts three channel parts from wSoundID on.
;@ test: skip switches ROM banks
StartSounds3::
;> StartSoundChannel()
;> StartSounds2()                         # runs on into it
	call StartSoundChannel

;@ def StartSounds2()
;@ path: sound/engine
;@ Starts two channel parts from wSoundID on.
;@ test: skip switches ROM banks
StartSounds2::
;> StartSoundChannel()
;> StartSoundChannel()                    # runs on into it
	call StartSoundChannel

;@ def StartSoundChannel()
;@ path: sound/engine
;@ Starts sound part wSoundID on its channel and moves wSoundID on by one.
;@ SoundBanks gives the bank and table of the part; its 4-byte record holds
;@ the channel (as a byte offset into wSoundChannels), the channel config byte
;@ and the address of its event data. A channel that was busy has its outputs
;@ switched off first. The channel starts at event 0 (its header) with no wave
;@ chosen yet.
;@ test: skip switches ROM banks
StartSoundChannel::
;> id = wSoundID
	push bc
	push de
	push hl
	ld a, [wSoundID]
;> entry = SoundBanks
	ld hl, SoundBanks

.find
;>@f while id >= mem[entry]:              # find the first entry above id
	cp [hl]
	jr c, .found

;>     entry += 4
	inc hl
	inc hl
	inc hl
	inc hl
;=@f
	jr .find

.found
;> saved = rom_bank()
	ld a, [$4000]
	push af
;>@sb set_rom_bank(mem[entry - 1])           # the entry before it covers id
	dec hl
	ld a, [hld]
	ld [$2100], a
	swap a
	rra
	and $03
;=@sb
	ld [$4100], a
;> table = mem16[entry - 3]
	ld a, [hld]
	ld d, a
	ld a, [hld]
	ld e, a
;>@r rec = table + 4 * (id - mem[entry - 4])
	ld a, [wSoundID]
	sub [hl]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
;=@r
	add hl, de
	push hl
	pop de
;> chan = wSoundChannels + mem[rec]
	ld a, [de]
	inc de
	ld c, a
	ld b, $00
	ld hl, wSoundChannels
	add hl, bc
;> if mem[chan] != 0xFF:                  # busy: switch its outputs off
	ld a, [hl]
	cp $ff
	jr z, .free

;>     hw = mem[chan + 1] & 3
	inc hl
	ld a, [hld]
	ld b, $ee
	and $03
;>@pm     wSoundPanning &= ~(0x11 << hw) & 0xFF
	jr z, .mask

	ld b, $dd
	cp $01
	jr z, .mask

	ld b, $bb
	cp $02
;=@pm
	jr z, .mask

	ld b, $77

.mask
;=@pm
	ld a, [wSoundPanning]
	and b
	ld [wSoundPanning], a

.free
;> mem[chan] = 0                          # event 0
	xor a
	ld [hli], a
;>@cp copy(chan + 1, rec + 1, 3)             # config byte and data address
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
;=@cp
	ld a, [de]
	inc de
	ld [hli], a
;> mem[chan + 4] = rom_bank()          # the bank of the data
	ld a, [$4000]
	ld [hl], a
;>@w mem[chan + 9] = 0xFF                   # no wave pattern yet
	push hl
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
;=@w
	ld a, $ff
	ld [hl], a
	pop hl
;> mem[chan + 25] = 0
	ld de, $0015
	add hl, de
	xor a
	ld [hl], a
;> set_rom_bank(saved)
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
;>@id wSoundID += 1
	ld a, [wSoundID]
	inc a
	ld [wSoundID], a
;=@id
	pop hl
	pop de
	pop bc
	ret


;@ path: sound/data
;@ Where the songs and sound effects are: entries of 4 bytes (first sound
;@ number, pointer to its records, ROM bank), $FF ends the list. Sounds $00-$20
;@ are in bank $1C, $21-$36 in bank $1D, from $37 on in bank $1E, each table at
;@ $4001. A sound record is 4 bytes: channel (byte offset into wSoundChannels:
;@ 26 times the channel number), channel config byte (hardware channel in bits
;@ 0-1) and the address of its event data (see ReadChannelEvents).
SoundBanks::
	db $00, $01, $40, $1c, $21, $01, $40, $1d, $37, $01, $40, $1e, $ff

;@ def UpdateSound()
;@ path: sound/engine
;@ The sound update, once per frame: runs the channels from wSoundFirstChannel
;@ to 5. Each channel's 26-byte record is copied to the hChan variables, its
;@ hardware channel noted (wSoundHWChannel, wSoundRegOffset, the NR51 bits),
;@ and, unless it is free, its bank switched in. A channel at event 0 reads its
;@ 4-byte header (tempo, duty or instrument length, envelope, sweep or wave)
;@ and starts. Otherwise the effects run, the tempo accumulator may skip the
;@ tick, and when the note's ticks are used up the next events are read. Then
;@ the record is copied back; at the end rNR51 is written.
;@ test: skip switches ROM banks and writes the sound registers
UpdateSound::
;> saved = rom_bank()
	ld a, [$4000]
	push af
;> wSoundCurChannel = wSoundFirstChannel
	ld a, [wSoundFirstChannel]
	ld [wSoundCurChannel], a
;> wSoundClaimed = 0
	xor a
	ld [wSoundClaimed], a
;> wSoundFrame += 1
	ld hl, wSoundFrame
	inc [hl]
;> chan = wSoundChannels
	ld hl, wSoundChannels

.channel
;>@lp for _ in forever():
;>@cp     copy(addr(hChanPos), chan, 26)
	push hl
	ld de, hChanPos
	ld b, $03

.copyIn
;=@cp
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
;=@cp
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
;=@cp
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
;=@cp
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
;=@cp
	dec b
	jr nz, .copyIn

	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hl]
;=@cp
	ld [de], a
;>     wSoundHWChannel = hChanConfig & 3
	ldh a, [hChanConfig]
	and $03
	ld [wSoundHWChannel], a
;>     wSoundRegOffset = 5 * wSoundHWChannel
	ld b, a
	add a
	add a
	add b
	ld [wSoundRegOffset], a
;>@bits     wSoundChannelBits = 0x11 << wSoundHWChannel
	inc b
	ld a, $88

.rotate
;=@bits
	rlca
	dec b
	jr nz, .rotate

;=@bits
	ld [wSoundChannelBits], a
;>     wSoundChannelBits2 = wSoundChannelBits
	ld [wSoundChannelBits2], a
;>     if not (hChanPos == 0xFF and hChanPosHi == 0xFF):     # free channel
	ldh a, [hChanPos]
	ld b, a
	ldh a, [hChanPosHi]
	and b
	cp $ff
	jp z, .next

;>         set_rom_bank(hChanBank)
	ldh a, [hChanBank]
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
;>         if hChanPos == 0 and hChanPosHi == 0:       # just started: read the header
;>@h1             p = hChanData
;>@h2             hChanTempo = 0
;>@h3             tempo = mem[p] & 0x0F
;>@h4             if wSoundHWChannel != 2:
;>@h5                 hChanDuty = (mem[p + 1] & 3) << 6 | tempo
;>@h6                 hChanEnvelope = swap(mem[p + 2])
;>@h7                 hChanSweep = mem[p + 3]
;>             else:                      # the wave channel
;>@h8                 hChanInstLength = mem[p + 1]
;>@h9                 hChanDuty = tempo
;>@ha                 hChanEnvelope = swap(mem[p + 2])
;>@hb                 rNR30 = 0          # wave off while its RAM is written
;>@hc                 if hChanSweep == 0xFF:     # no wave chosen yet: the header's
;>@hd                     hChanSweep = mem[p + 3]
;>@he                 wSoundWave = hChanSweep
;>@hf                 copy(0xFF30, WavePatterns + 16 * hChanSweep, 16)
;>@hg             hChanLoop1 = 0; hChanLoop2 = 0; mem[0xFFF0] = 0; hChanVolSlide = 0
;>@hh             hChanPosHi = 0; hChanPan = 0xFF
;>@hi             hChanPos = 2; new_note = True      # events 0-1 are the header
	ldh a, [hChanPosHi]
	or b
	and a
	jp z, .start

;>         else:
;>             UpdateVibrato()
	call UpdateVibrato
;>             UpdateInstrument()
	call UpdateInstrument
;>@is             hChanInstStep = min(hChanInstStep + 1, hChanInstLength)
	ldh a, [hChanInstLength]
	ld b, a
	ldh a, [hChanInstStep]
	inc a
	cp b
	jr c, .stepOk

;=@is
	ld a, b

.stepOk
	ldh [hChanInstStep], a
;>             t = (hChanDuty & 0x0F) + hChanTempo
	ld hl, hChanTempo
	ldh a, [hChanDuty]
	and $0f
	add [hl]
;>             if t >= 16:                # slow tempo: this tick is skipped
	cp $10
	jr c, .tick

;>                 hChanTempo = t - 16
;>                 new_note = False
	sub $10
	ld [hl], a
	jr .copyOut

.tick
;>             else:
;>                 hChanTempo = t
	ld [hl], a
;>                 UpdateVolumeSlide()
	call UpdateVolumeSlide
;>                 if hChanVibTimer:
;>                     hChanVibTimer -= 1
	ldh a, [hChanVibTimer]
	and a
	jr z, .vibDone

	dec a
	ldh [hChanVibTimer], a

.vibDone
;>                 hChanNoteTimer -= 1
;>                 new_note = hChanNoteTimer == 0
	ld hl, hChanNoteTimer
	dec [hl]
	jr nz, .copyOut

;>                 if new_note:
;>                     MarkNoteEnd()
	call MarkNoteEnd

.newNote
;>         if new_note:
;>             hChanVibTimer = hChanVibDelay
	ldh a, [hChanVibDelay]
	ldh [hChanVibTimer], a
;>             ReadChannelEvents()
	call ReadChannelEvents

.copyOut
;>         wSoundClaimed |= wSoundChannelBits
	ld a, [wSoundChannelBits]
	ld b, a
	ld a, [wSoundClaimed]
	or b
	ld [wSoundClaimed], a
;>@co         copy(chan, addr(hChanPos), 26)
	pop hl
	push hl
	ld de, hChanPos
	ld b, $03

.copyBack
;=@co
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
;=@co
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
;=@co
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
;=@co
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
;=@co
	dec b
	jr nz, .copyBack

	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
;=@co
	ld [hli], a

.next
;>     chan += 26
	pop hl
	ld de, $001a
	add hl, de
;>     wSoundCurChannel += 1
	ld a, [wSoundCurChannel]
	inc a
	ld [wSoundCurChannel], a
;>     if wSoundCurChannel >= 6:
;>         break
	cp $06
	jp c, .channel

;> rNR51 = wSoundPanning
	ld a, [wSoundPanning]
	ldh [rNR51], a
;> set_rom_bank(saved)
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
;> ApplySyncedBankSwitch()
	call ApplySyncedBankSwitch
	ret


.start
;=@h1
	ldh a, [hChanData]
	ld l, a
	ldh a, [hChanData + 1]
	ld h, a
;=@h2
	xor a
	ldh [hChanTempo], a
;=@h3
	ld a, [hli]
	and $0f
	ld d, a
;=@h4
	ld a, [wSoundHWChannel]
	cp $02
	jr z, .waveHeader

;=@h5
	ld a, [hli]
	rrca
	rrca
	and $c0
	or d

.setDuty
;=@h5
	ldh [hChanDuty], a
;=@h6
	ld a, [hli]
	swap a
	ldh [hChanEnvelope], a
;=@h4
	ld a, [wSoundHWChannel]
	cp $02
	jr z, .waveRAM

;=@h7
	ld a, [hli]
	ldh [hChanSweep], a

.common
;=@hg
	xor a
	ldh [hChanLoop1], a
	ldh [hChanLoop2], a
	ldh [$fff0], a
	ldh [hChanVolSlide], a
;=@hh
	ldh [hChanPosHi], a
	dec a
	ldh [hChanPan], a
;=@hi
	ld a, $02
	ldh [hChanPos], a
	jp .newNote


.waveHeader
;=@h8
	ld a, [hli]
	ldh [hChanInstLength], a
;=@h9
	ld a, d
	jr .setDuty

.waveRAM
;=@hb
	xor a
	ldh [rNR30], a
;=@hc
	ld d, a
	ldh a, [hChanSweep]
	ld e, a
	cp $ff
	jr nz, .haveWave

;=@hd
	ld e, [hl]
	ld a, e
	ldh [hChanSweep], a

.haveWave
;=@he
	ld [wSoundWave], a
;=@hf
	swap e
	ld hl, WavePatterns
	add hl, de
	ld de, $ff30
	ld b, $10

.copyWave
;=@hf
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copyWave

;=@hg
	jr .common

;@ def ReadChannelEvents()
;@ path: sound/engine
;@ Reads the channel's events from event number hChanPosHi:hChanPos on (every
;@ event is two bytes: a command and its operand) until a note or a pause.
;@ Commands: $00-$9F a note (PlayNote; the operand is its length in ticks);
;@ $A0 envelope (nibbles swapped), $A1 sweep / wave pattern, $A2 duty / wave
;@ instrument length, $A3 vibrato (bit 7 off; else delay in bits 0-3, table in
;@ bits 4-6), $A5 panning (1 = swap the sides), $A6 master volume, $A7 a pause
;@ of operand ticks, $A8 instrument, $AE note table (bit 4), $AF tempo
;@ slow-down; $Bn loop n times (operand 0: back to the loop point, operand $FC:
;@ to the event number in the next event), $Cn instrument envelope row n with
;@ operand steps, $Dn / $En volume slide up / down by n every operand ticks;
;@ $FD sets the loop point, $FF ends the channel; other commands are skipped.
;@ The loop point's high byte is kept in hLoopPosHi, one byte that all channels
;@ share, so a loop relies on no other channel setting a loop point in between.
;@ The bytes inside are an unused event skipper.
;@ test: skip sound engine with ROM data and hardware writes
ReadChannelEvents::
;>@p0 p = hChanData + 2 * (hChanPosHi << 8 | hChanPos)
	ldh a, [hChanPos]
	ld l, a
	ldh a, [hChanPosHi]
	ld h, a
	add hl, hl
	ldh a, [hChanData]
;=@p0
	ld e, a
	ldh a, [hChanData + 1]
	ld d, a
	add hl, de

.next
;> for _ in forever():
;>     hChanPos = u8(hChanPos + 1)
	ldh a, [hChanPos]
	add $01
	ldh [hChanPos], a
;>     hChanPosHi += hChanPos == 0        # 16-bit event number + 1
	ldh a, [hChanPosHi]
	adc $00
	ldh [hChanPosHi], a
;>     cmd = mem[p]; p += 1
	ld a, [hli]
;>     if cmd >= 0xD0:
;>@d1         if cmd >= 0xF0:
;>@d2             if cmd == 0xFD:          # the loop point is here
;>@d3                 hChanLoopPos = hChanPos
;>@d4                 hLoopPosHi = hChanPosHi
;>@d5             elif cmd == 0xFF:        # end of the channel
;>@d6                 hChanPos = 0xFF; hChanPosHi = 0xFF
;>@d7                 StopChannelOutput(); return
;>@d8             p += 1
;>@d9             continue
;>@da         slide = -(cmd & 0x0F) if cmd >= 0xE0 else cmd & 0x0F
;>@db         if wSoundHWChannel != 2:
;>@dc             hChanVolSlide = u8(slide)
;>@dd             hChanVolSlideRate = mem[p]
;>@de             hChanVolSlideTimer = mem[p]
;>@df         p += 1
	cp $d0
	jr nc, .cmdD0

;>     elif cmd >= 0xB0:
;>@b1         if cmd >= 0xC0:              # instrument envelope
;>@b2             if wSoundHWChannel != 2 and (hChanEnvelope & 0x0F) == 0:
;>@b3                 hChanInstLength = mem[p]
;>@b4                 mem[0xFFF0] = (cmd & 0x0F) << 4
;>@b5             p += 1
;>         else:                          # a loop
;>@b6                 n = cmd & 0x0F
;>@b7                 if n and mem[p] == 0:    # counter 1, back to the loop point
;>@b8                     hChanLoop1 = u8(hChanLoop1 - 1)
;>@b9                     if hChanLoop1 == 0:
;>@ba                         return ReadChannelEvents()      # done: on after the loop
;>@bb                     if hChanLoop1 & 0x80:   # first pass: arm the counter
;>@bc                         hChanLoop1 = n
;>@bd                 elif n:              # counter 2, to the event in the next event
;>@be                     hChanLoop2 = u8(hChanLoop2 - 1)
;>@bf                     if hChanLoop2 == 0:
;>@bg                         hChanPos += 1; return ReadChannelEvents()   # skip the target
;>@bh                     if hChanLoop2 & 0x80:
;>@bi                         hChanLoop2 = n
;>@bj                 if mem[p] == 0xFC:
;>@bk                     hChanPos = mem[p + 1]; hChanPosHi = mem[p + 2]
;>                 else:
;>@bl                     hChanPos = hChanLoopPos; hChanPosHi = hLoopPosHi
;>@bm                 return ReadChannelEvents()
	cp $b0
	jr nc, .cmdB0

;>     elif cmd >= 0xA0:
;>@a1         if cmd == 0xA0:              # envelope
;>@a2             hChanEnvelope = swap(mem[p])
;>@a3             if not wSoundClaimed & wSoundChannelBits:
;>@a4                 SetChannelEnvelope(hChanEnvelope)
;>@a5         elif cmd == 0xA1:            # sweep, or the wave pattern
;>@a6             if wSoundHWChannel != 2:
;>@a7                 hChanSweep = mem[p]
;>             else:
;>@a8                 rNR30 = 0
;>@a9                 hChanSweep = mem[p]
;>@aa                 if not wSoundClaimed & wSoundChannelBits:
;>@ab                     wSoundWave = hChanSweep
;>@ac                     copy(0xFF30, WavePatterns + 16 * hChanSweep, 16)
;>@ad         elif cmd == 0xA2:            # duty, or the wave channel's instrument length
;>@ae             if wSoundHWChannel != 2:
;>@af                 hChanDuty = (mem[p] & 3) << 6 | hChanDuty & 0x3F
;>             else:
;>@ag                 hChanInstLength = mem[p]
;>@ah         elif cmd == 0xA3:            # vibrato
;>@ai             v = mem[p]
;>@aj             if v & 0x80:
;>@ak                 hChanConfig &= 0x0F  # off
;>             else:
;>@al                 hChanVibDelay = (v & 0x0F) * 2; hChanVibTimer = hChanVibDelay
;>@am                 hChanConfig = hChanConfig & 0x0F | v & 0x70 | 0x80
;>@an         elif cmd == 0xA5:            # panning
;>@ao             hChanPan = swap(hChanPan) if mem[p] == 1 else mem[p]
;>@ap         elif cmd == 0xA6:
;>@aq             rNR50 = mem[p]           # master volume
;>@ar         elif cmd == 0xA7:            # a pause
;>@as             hChanNoteTimer = mem[p]
;>@at             return PlayNoteSetPan()
;>@au         elif cmd == 0xA8:
;>@av             hChanInstrument = mem[p]
;>@aw         elif cmd == 0xAE:
;>@ax             hChanDuty = hChanDuty & 0xEF | mem[p] & 0x10    # note table
;>@ay         elif cmd == 0xAF:
;>@az             hChanDuty = hChanDuty & 0xF0 | mem[p] & 0x0F    # tempo slow-down
;>@c1         p += 1
	cp $a0
	jp nc, .cmdA0

;>     else:
;>         return PlayNote(cmd, p)
	jp PlayNote


.cmdF0
;=@d2
	cp $fd
	jr nz, .notFD

;=@d3
	ldh a, [hChanPos]
	ldh [hChanLoopPos], a
;=@d4
	ldh a, [hChanPosHi]
	ldh [hLoopPosHi], a

.skip
;=@d8
	inc hl
;=@d9
	jr .next

.notFD
;=@d5
	cp $ff
	jr nz, .skip

;=@d6
	ldh [hChanPos], a
	ldh [hChanPosHi], a
;=@d7
	call StopChannelOutput
	ret


.cmdD0
;=@d1
	cp $f0
	jr nc, .cmdF0

;=@da
	cp $e0
	jr nc, .slideDown

	and $0f
	jr .slide

.slideDown
;=@da
	and $0f
	cpl
	inc a

.slide
;=@db
	ld b, a
	ld a, [wSoundHWChannel]
	cp $02
	jr z, .slideDone

;=@dc
	ld a, b
	ldh [hChanVolSlide], a
;=@dd
	ld a, [hl]
	ldh [hChanVolSlideRate], a
;=@de
	ldh [hChanVolSlideTimer], a

.slideDone
;=@df
	inc hl
	jr .next

.cmdC0
;=@b2
	and $0f
	ld b, a
	ld a, [wSoundHWChannel]
	cp $02
	jr z, .instDone

;=@b2
	ldh a, [hChanEnvelope]
	and $0f
	jr nz, .instDone

;=@b3
	ld a, [hl]
	ldh [hChanInstLength], a
;=@b4
	ld a, b
	swap a
	ldh [$fff0], a

.instDone
;=@b5
	inc hl
	jr .next

.cmdB0
;=@b1
	cp $c0
	jr nc, .cmdC0

;=@b6
	and $0f
;=@b7
	jr z, .jump

	ld e, a
	ld a, [hl]
	and a
	jr nz, .counter2

;=@b8
	ldh a, [hChanLoop1]
	dec a
	ldh [hChanLoop1], a
;=@b9
	jr z, .loopDone

;=@bb
	bit 7, a
	jr z, .jump

;=@bc
	ld a, e
	ldh [hChanLoop1], a
	jr .jump

.counter2
;=@be
	ldh a, [hChanLoop2]
	dec a
	ldh [hChanLoop2], a
;=@bf
	jr z, .loop2Done

;=@bh
	bit 7, a
	jr z, .jump

;=@bi
	ld a, e
	ldh [hChanLoop2], a

.jump
;=@bj
	ld a, [hl]
	cp $fc
	jr z, .jumpTarget

;=@bl
	ldh a, [hChanLoopPos]
	ldh [hChanPos], a
	ldh a, [hLoopPosHi]
	ldh [hChanPosHi], a
;=@bm
	jp ReadChannelEvents


.jumpTarget
;=@bk
	inc hl
	ld a, [hli]
	ldh [hChanPos], a
	ld a, [hl]
	ldh [hChanPosHi], a

.loopDone
;=@ba
	jp ReadChannelEvents


	db $f0, $e4, $c6, $01, $e0, $e4, $f0, $fd, $ce, $00, $e0, $fd, $c3, $ea, $35

.loop2Done
;=@bg
	ldh a, [hChanPos]
	add $01
	ldh [hChanPos], a
	jp ReadChannelEvents


.cmdA0
;=@a1
	cp $a0
	jr nz, .notA0

;=@a2
	ld a, [hli]
	swap a
	ldh [hChanEnvelope], a
;=@a3
	ld a, [wSoundChannelBits]
	ld b, a
	ld a, [wSoundClaimed]
	and b
	jp nz, .next

;=@a4
	call SetChannelEnvelope
	jp .next


.notA0
;=@a5
	cp $a1
	jr nz, .notA1

;=@a6
	ld a, [wSoundHWChannel]
	cp $02
	jr z, .waveA1

;=@a7
	ld a, [hli]
	ldh [hChanSweep], a
	jp .next


.waveA1
;=@a8
	xor a
	ldh [rNR30], a
	ld d, a
;=@a9
	ld a, [hli]
	ld e, a
	ldh [hChanSweep], a
;=@aa
	ld a, [wSoundChannelBits]
	ld b, a
	ld a, [wSoundClaimed]
	and b
	jr z, .loadWave

;=@aa
	jp .next


.loadWave
;=@ab
	push hl
	ld a, e
	ld [wSoundWave], a
;=@ac
	swap e
	ld hl, WavePatterns
	add hl, de
	ld de, $ff30
	ld b, $10

.copyWave
;=@ac
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copyWave

;=@ac
	pop hl
	jp .next


.notA1
;=@ad
	cp $a2
	jr nz, .notA2

;=@ae
	ld a, [wSoundHWChannel]
	cp $02
	jr z, .waveA2

;=@af
	ld a, [hli]
	rrca
	rrca
	and $c0
	ld d, a
;=@af
	ldh a, [hChanDuty]
	and $3f
	or d
	ldh [hChanDuty], a
	jp .next


.waveA2
;=@ag
	ld a, [hli]
	ldh [hChanInstLength], a
	jp .next


.notA2
;=@ah
	cp $a3
	jr nz, .notA3

;=@ai
	ld a, [hli]
;=@aj
	bit 7, a
	jr nz, .vibratoOff

;=@al
	ld b, a
	and $0f
	add a
	ldh [hChanVibDelay], a
	ldh [hChanVibTimer], a
;=@am
	ld a, b
	and $70
	ld e, a
	ldh a, [hChanConfig]
	and $0f
	or e
;=@am
	or $80

.setConfig
;=@am
	ldh [hChanConfig], a
	jp .next


.vibratoOff
;=@ak
	ldh a, [hChanConfig]
	and $0f
	jr .setConfig

.notA3
;=@an
	cp $a5
	jr nz, .notA5

;=@ao
	ld a, [hli]
	cp $01
	jr nz, .setPan

	ldh a, [hChanPan]
	swap a

.setPan
;=@ao
	ldh [hChanPan], a
	jp .next


.notA5
;=@ap
	cp $a6
	jr nz, .notA6

;=@aq
	ld a, [hli]
	ldh [rNR50], a
	jp .next


.notA6
;=@ar
	cp $a7
	jr nz, .notA7

;=@as
	ld a, [hl]
	ldh [hChanNoteTimer], a
;=@at
	jp PlayNoteSetPan


.notA7
;=@au
	cp $a8
	jr nz, .notA8

;=@av
	ld a, [hli]
	ldh [hChanInstrument], a
	jp .next


.notA8
;=@aw
	cp $ae
	jr nz, .notAE

;=@ax
	ld a, [hli]
	and $10
	ld b, a
	ldh a, [hChanDuty]
	and $ef
	or b
;=@ax
	ldh [hChanDuty], a
	jp .next


.notAE
;=@ay
	cp $af
	jr nz, .otherA

;=@az
	ld a, [hli]
	and $0f
	ld b, a
	ldh a, [hChanDuty]
	and $f0
	or b
;=@az
	ldh [hChanDuty], a
	jp .next


.otherA
;=@c1
	inc hl
	jp .next


;@ path: sound/data
;@ NR43 values (noise frequency) for noise note events $00-$0F.
NoiseNotes::
	db $00, $01, $11, $12, $14, $23, $07, $15, $17, $32, $33, $60, $61, $45, $53, $62

;@ def PlayRest()
;@ path: sound/engine
;@ A rest: frequency $8000 (no note), and the channel silenced (the wave
;@ channel switched off).
;@ test: skip writes the sound registers
PlayRest::
;> hChanFreq = 0x8000
	xor a
	ldh [hChanFreq], a
	ld a, $80
	ldh [hChanFreq + 1], a
;> if wSoundHWChannel != 2:
	ld a, [wSoundHWChannel]
	cp $02
	jr z, .wave

;>     SilenceChannel()
	call SilenceChannel
	ret


.wave
;> else:
;>     SkipIfChannelClaimed()
	call SkipIfChannelClaimed
;>     rNR30 = 0
	xor a
	ldh [rNR30], a
	ret


;@ def PlayNote(note: a, p: hl)
;@ path: sound/engine
;@ Plays note event `note` (operand at p: its length in ticks). Square and wave
;@ channels: low nibble 0-11 the note (12-15 a rest), high nibble the octave;
;@ the period comes from NoteFrequencies (the second set when hChanDuty bit 4
;@ is set) shifted right once per octave. The noise channel: $1F a rest, $00-$0F
;@ a NoiseNotes entry, else the byte itself is the NR43 value. Then the
;@ registers are written (sweep for channel 1, duty, envelope, frequency with the
;@ trigger bit) unless the hardware channel is claimed. PlayNoteSetPan inside
;@ sets the channel's bits in wSoundPanning.
;@ test: skip writes the sound registers
PlayNote::
;> hChanNoteTimer = mem[p]
	ld b, a
	ld a, [hl]
	ldh [hChanNoteTimer], a
;> if wSoundHWChannel == 3:               # noise
	ld a, [wSoundHWChannel]
	cp $03
	jr nz, .tone

;>     if note == 0x1F:
;>         return PlayRest()
	ld a, b
	cp $1f
	jr z, PlayRest

;>     if note < 0x10:
	cp $10
	jr nc, .rawNoise

;>@nf         freq = NoiseNotes[note]
	ld hl, NoiseNotes
	add l
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@nf
	ld l, [hl]
	ld h, $00
	jr .gotFreq

.rawNoise
;>     else:
;>         freq = note
	ld l, a
	ld h, $00
	jr .gotFreq

.tone
;> else:
;>     if (note & 0x0F) >= 12:
;>         return PlayRest()
	ld a, b
	and $0f
	cp $0c
	jr nc, PlayRest

;>     i = 2 * (note & 0x0F)
	add a
	ld e, a
;>     if hChanDuty & 0x10:
	ldh a, [hChanDuty]
	and $10
	jr z, .table

;>         i += 24                        # the second note table
	ld a, e
	add $18
	ld e, a

.table
;>     period = mem16[NoteFrequencies + i]
	ld d, $00
	ld hl, NoteFrequencies
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@oct     period >>= note >> 4               # one octave up per step
	ld a, b
	swap a
	and $0f
	jr z, .shifted

	ld b, a

.shift
;=@oct
	srl h
	rr l
	dec b
	jr nz, .shift

.shifted
;>     freq = u16(0x800 - period)
	ld a, $00
	sub l
	ld l, a
	ld a, $08
	sbc h
	ld h, a

.gotFreq
;> hChanInstStep = 0
	xor a
	ldh [hChanInstStep], a
;> SkipIfChannelClaimed()                 # returns from here if another channel owns it
	call SkipIfChannelClaimed
;> if wSoundHWChannel == 2:
	ld a, [wSoundHWChannel]
	cp $02
	jr nz, .volume

;>     LoadWavePattern()
	call LoadWavePattern
;>     rNR30 = 0x80                       # wave on
	ld a, $80
	ldh [rNR30], a

.volume
;> UpdateChannelVolume()
	push hl
	call UpdateChannelVolume
	pop hl
;> if wSoundHWChannel == 0:
;>     WriteChannelReg(hChanSweep, 0x10)  # NR10
	ld a, [wSoundHWChannel]
	and a
	ldh a, [hChanSweep]
	ld c, $10
	call z, WriteChannelReg
;> WriteChannelReg(lo(freq), 0x13)        # NRx3
	ld a, l
	ld c, $13
	call WriteChannelReg
;>@lf lo_freq = min(max(lo(freq), 2), 0xFD)  # room for the vibrato offsets
	ld a, l
	cp $02
	jr c, .low

	cp $fe
	jr c, .setLow

;=@lf
	ld a, $fd
	jr .setLow

.low
;=@lf
	ld a, $02

.setLow
;> hChanFreq = hChanFreq & 0xFF00 | lo_freq
	ldh [hChanFreq], a
;> if wSoundHWChannel == 2:
;>@hi2     rNR31 = 0
;>@hi3     if not rNR52 & 0x04:               # the wave channel stopped: trigger it
;>@hi4         hi_freq = hi(freq) & 7 | 0x80
;>     else:
;>@hi5         hi_freq = hi(freq) & 7
	ld a, [wSoundHWChannel]
	cp $02
	jr z, PlayNoteSetPan.waveHigh

;> else:
;>     if wSoundHWChannel < 2:
	cp $02
	jr nc, .high

;>         WriteChannelReg(hChanDuty & 0xC0 | 0x3F, 0x11)   # duty and length
	ldh a, [hChanDuty]
	and $c0
	or $3f
	ld c, $11
	call WriteChannelReg

.high
;>     hi_freq = hi(freq) & 7 | 0x80      # with the trigger bit
	ld a, h
	and $07
	or $80

.setHigh
;> hChanFreq = hi_freq << 8 | hChanFreq & 0xFF
	ldh [hChanFreq + 1], a
;> WriteChannelReg(hi_freq, 0x14)         # NRx4
	ld c, $14
	call WriteChannelReg

PlayNoteSetPan:
;>@pan wSoundPanning = wSoundPanning & ~wSoundChannelBits2 | hChanPan & wSoundChannelBits2
	ld a, [wSoundChannelBits2]
	ld b, a
	cpl
	ld c, a
	ldh a, [hChanPan]
	and b
;=@pan
	ld b, a
	ld a, [wSoundPanning]
	and c
	or b
	ld [wSoundPanning], a
	ret


.waveHigh
;=@hi2
	xor a
	ldh [rNR31], a
;=@hi3
	ldh a, [rNR52]
	and $04
	jr z, PlayNote.high

;=@hi5
	ld a, h
	and $07
	jr PlayNote.setHigh

;@ def UpdateVolumeSlide()
;@ path: sound/engine
;@ Volume slide ($Dn / $En events): every hChanVolSlideRate ticks the
;@ envelope's start volume goes one step up (count positive) or down
;@ (negative), between 0 and 15, until the count is used up. Not for the wave
;@ channel or envelopes that sweep by themselves.
;@ test: skip writes the sound registers
UpdateVolumeSlide::
;> if wSoundHWChannel == 2 or hChanVolSlide == 0:
;>     return
	ld a, [wSoundHWChannel]
	cp $02
	ret z

	ldh a, [hChanVolSlide]
	and a
	ret z

;> hChanVolSlideTimer -= 1
	ld hl, hChanVolSlideTimer
	dec [hl]
;> if hChanVolSlideTimer:
;>     return
	ret nz

;> if hChanEnvelope & 0x0F:
;>     return                             # the envelope sweeps by itself
	ldh a, [hChanEnvelope]
	swap a
	cp $10
	ret nc

;> volume = hChanEnvelope >> 4
	and $0f
	ld b, a
;> hChanVolSlideTimer = hChanVolSlideRate
	ldh a, [hChanVolSlideRate]
	ldh [hChanVolSlideTimer], a
;> if not hChanVolSlide & 0x80:           # up
	ld hl, hChanVolSlide
	ld a, [hl]
	bit 7, a
	jr nz, .down

;>     hChanVolSlide -= 1
	dec [hl]
;>     if volume == 15:
;>         return
	ld a, b
	cp $0f
	ret z

;>     hChanEnvelope += 0x10
	ldh a, [hChanEnvelope]
	add $10
	ldh [hChanEnvelope], a
;>     return SetChannelEnvelope(hChanEnvelope)
	jp SetChannelEnvelope


.down
;> else:
;>     hChanVolSlide += 1
	inc [hl]
;>     if volume == 0:
;>         return
	ld a, b
	and a
	ret z

;>     hChanEnvelope -= 0x10
	ldh a, [hChanEnvelope]
	sub $10
	ldh [hChanEnvelope], a
;>     return SetChannelEnvelope(hChanEnvelope)
	jr SetChannelEnvelope

;@ def UpdateVibrato()
;@ path: sound/engine
;@ Vibrato: once the note's vibrato delay is over, adds the offset for this
;@ frame (VibratoTables row hChanConfig bits 4-6, column wSoundFrame & 15) to
;@ the low frequency byte. Not for the noise channel.
;@ test: skip writes the sound registers
UpdateVibrato::
;> SkipIfChannelClaimed()
	call SkipIfChannelClaimed
;>@v if wSoundHWChannel == 3 or hChanVibTimer or not hChanConfig & 0x80:
;>     return
	ld a, [wSoundHWChannel]
	cp $03
	ret z

	ldh a, [hChanVibTimer]
	and a
	ret nz

;=@v
	ldh a, [hChanConfig]
	bit 7, a
	ret z

;>@o offset = VibratoTables[hChanConfig & 0x70 | wSoundFrame & 0x0F]
	and $70
	ld b, a
	ld a, [wSoundFrame]
	and $0f
	or b
	ld e, a
;=@o
	ld d, $00
	ld hl, VibratoTables
	add hl, de
;> WriteChannelReg(u8(lo(hChanFreq) + offset), 0x13)
	ldh a, [hChanFreq]
	add [hl]
	ld c, $13
	jr WriteChannelReg

;@ def UpdateChannelVolume()
;@ path: sound/engine
;@ Writes the channel's volume for a new note: the wave channel's output level,
;@ the instrument envelope if one is set, else the plain envelope
;@ (SetChannelEnvelope, which it runs on into).
;@ test: skip writes the sound registers
UpdateChannelVolume::
;> if wSoundHWChannel == 2:
;>     return SetWaveOutputLevel()
	ld a, [wSoundHWChannel]
	cp $02
	jr z, SetWaveOutputLevel

;> if mem[0xFFF0]:                        # an instrument envelope
;>     return InstrumentStep()
	ldh a, [$fff0]
	and a
	jr nz, InstrumentStep

;> return SetChannelEnvelope(hChanEnvelope)
	ldh a, [hChanEnvelope]

;@ def SetChannelEnvelope(env: a)
;@ path: sound/engine
;@ Writes a new volume envelope (NRx2) if it differs from the current one and
;@ restarts the note (NRx4 with the trigger bit). An envelope without sweep
;@ pace gets the "increase" bit so the volume holds.
;@ test: skip writes the sound registers
SetChannelEnvelope::
;> if (env & 0x07) == 0:
;>     env |= 0x08
	ld b, a
	and $07
	jr nz, .write

	ld a, b
	or $08
	ld b, a

.write
;> reg = 0x12 + wSoundRegOffset
	ld a, [wSoundRegOffset]
	add $12
	ld c, a
;> if mem[0xFF00 + reg] == env:
;>     return
	ldh a, [c]
	cp b
	ret z

;> mem[0xFF00 + reg] = env
	ld a, b
	ldh [c], a
;> WriteChannelReg(hi(hChanFreq), 0x14)   # restart; runs on into it
	ldh a, [hChanFreq + 1]
	ld c, $14

;@ def WriteChannelReg(value: a, reg: c)
;@ path: sound/engine
;@ Writes `value` to sound register $FF00 + reg of the current hardware
;@ channel (reg is the channel 1 number $10-$14; wSoundRegOffset is added).
;@ test: skip writes the sound registers
WriteChannelReg::
;>@w mem[0xFF00 + reg + wSoundRegOffset] = value
	ld b, a
	ld a, [wSoundRegOffset]
	add c
	ld c, a
	ld a, b
	ldh [c], a
;=@w
	ret


;@ def SetWaveOutputLevel()
;@ path: sound/engine
;@ The wave channel's volume: hChanEnvelope goes to its output level register.
;@ test: skip writes the sound registers
SetWaveOutputLevel::
;> WriteChannelReg(hChanEnvelope, 0x12)
	ldh a, [hChanEnvelope]
	ld c, $12
	jr WriteChannelReg

;@ def InstrumentWaveVolume(step: e)
;@ path: sound/engine
;@ Instrument envelope of the wave channel: from step 0-15 of the note an
;@ output level; written to rNR32 only once it is not below hChanEnvelope.
;@ test: skip writes the sound registers
InstrumentWaveVolume::
;> level = swap((step >> 1) + 2)
	ld a, e
	srl a
	add $02
	swap a
;> if level < hChanEnvelope:
;>     return
	ld hl, hChanEnvelope
	cp [hl]
	ret c

;> rNR32 = level & 0x60
	and $60
	ldh [rNR32], a
	ret


;@ def UpdateInstrument()
;@ path: sound/engine
;@ Instrument envelopes, each tick: silences a rest, then (with an instrument
;@ envelope row set, or for the wave channel) finds the note's step 0-15 =
;@ hChanInstStep * 16 / hChanInstLength and reads that step's byte from the
;@ instrument (InstrumentTable): high nibble a row of InstrumentVolumes (which
;@ scales the channel's volume), bit 3 the envelope direction, bit 2 no sweep
;@ pace, bit 1 half the pace, bit 0 write even if the direction is unchanged.
;@ The sweep pace comes from the note length. InstrumentStep inside is also
;@ the entry for UpdateChannelVolume.
;@ test: skip writes the sound registers
UpdateInstrument::
;> SkipIfChannelClaimed()
	call SkipIfChannelClaimed
;> if (hChanFreq & 0x7FFF) == 0:             # a rest
;>     return SilenceChannel()
	ldh a, [hChanFreq]
	and a
	jr nz, .notRest

	ldh a, [hChanFreq + 1]
	and $7f
	jp z, SilenceChannel

.notRest
;> if wSoundHWChannel != 2 and mem[0xFFF0] == 0:
;>     return                             # no instrument envelope
	ld a, [wSoundHWChannel]
	cp $02
	jr z, InstrumentStep

	ldh a, [$fff0]
	and a
	ret z

InstrumentStep:
;> length = hChanInstLength
;> if length == 0:
	ldh a, [hChanInstLength]
	and a
	ret z

;>     return
;> step = 0
	ld e, $00
	ld c, a
	ldh a, [hChanInstStep]
;>@div step = hChanInstStep * 16 // length   # four steps of a long division
	ld b, $04

.divide
;=@div
	add a
	cp c
	jr c, .bit

	sub c

.bit
;=@div
	ccf
	rl e
	dec b
	jr nz, .divide

;> if wSoundHWChannel == 2:
;>     return InstrumentWaveVolume(step)
	ld a, [wSoundHWChannel]
	cp $02
	jr z, InstrumentWaveVolume

;> i = mem[0xFFF0] | step
	ldh a, [$fff0]
	or e
	ld e, a
	ld d, $00
;>@t table = mem16[InstrumentTable + 2 * hChanInstrument]
	push de
	ldh a, [hChanInstrument]
	ld de, InstrumentTable
	sla a
	add e
	ld e, a
;=@t
	xor a
	adc d
	ld d, a
	ld a, [de]
	ld l, a
	inc de
;=@t
	ld a, [de]
	ld h, a
	pop de
;>@b byte = mem[table - 0x10 + i]          # rows start at 1
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
;=@b
	add hl, de
;>@vv v = byte & 0xF0 | swap(hChanEnvelope)  # InstrumentVolumes row and volume
	ldh a, [hChanEnvelope]
	swap a
	ld e, a
	ld a, [hl]
	ld h, a
	and $f0
;=@vv
	or e
	ld e, a
;> pace = 0
;> if not byte & 0x04:
	bit 2, h
	jr nz, .paceDone

;>     pace = 1
	inc b
;>     if hChanInstLength >> 4:
	ld a, c
	swap a
	and $0f
	jr z, .paceDone

;>         pace = hChanInstLength >> 4
	ld b, a
;>         if not v & 0x08:
;>             pace <<= 1
	bit 3, e
	jr nz, .checkPace

	sla b
;>             if not v & 0x04:
;>                 pace <<= 1
	bit 2, e
	jr nz, .checkPace

	sla b
;>                 if not v & 0x02:
;>                     pace = 0
	bit 1, e
	jr z, .noPace

.checkPace
;>         if pace >= 8:
;>             pace = 0
	ld a, b
	cp $08
	jr c, .paceDone

.noPace
	ld b, $00

.paceDone
;> if byte & 0x02:
;>     pace >>= 1
	bit 1, h
	jr z, .direction

	ld a, b
	jr z, .direction

	srl b

.direction
;> pace |= byte & 0x08                    # envelope direction
	ld a, h
	and $08
	or b
	ld b, a
;> if byte & 0x01:
	bit 0, h
	jr z, .compare

;>     return SetChannelEnvelope(InstrumentVolumes[v] | pace)
	ld hl, InstrumentVolumes
	add hl, de
	ld a, [hl]
	or b
	jp SetChannelEnvelope


.compare
;>@cmp if (mem[0xFF12 + wSoundRegOffset] & 0x08) == (byte & 0x08):
;>     return                             # same direction: leave it running
	ld c, $12
	ld a, [wSoundRegOffset]
	add c
	ld c, a
	ldh a, [c]
	and $08
;=@cmp
	ld l, a
	ld a, h
	and $08
	cp l
	ret z

;> return SetChannelEnvelope(InstrumentVolumes[v] | pace)
	ld hl, InstrumentVolumes
	add hl, de
	ld a, [hl]
	or b
	jp SetChannelEnvelope


;@ def SilenceChannel()
;@ path: sound/engine
;@ Envelope 0 (silent) for the current hardware channel, unless it is claimed.
;@ test: skip writes the sound registers
SilenceChannel::
;> SkipIfChannelClaimed()
	call SkipIfChannelClaimed
;> return SetChannelEnvelope(0)
	ld a, $00
	jp SetChannelEnvelope


;@ def StopChannelOutput()
;@ path: sound/engine
;@ Removes the current hardware channel from wSoundPanning (end of a channel),
;@ unless it is claimed.
;@ test: skip may return from its caller
StopChannelOutput::
;> SkipIfChannelClaimed()
	call SkipIfChannelClaimed
;>@p wSoundPanning &= ~wSoundChannelBits & 0xFF
	ld a, [wSoundChannelBits]
	cpl
	ld b, a
	ld a, [wSoundPanning]
	and b
	ld [wSoundPanning], a
;=@p
	ret


;@ def SkipIfChannelClaimed()
;@ path: sound/engine
;@ When a channel processed earlier this frame has already written the current
;@ hardware channel (wSoundClaimed), returns from the caller as well: the
;@ caller's register writes are skipped.
;@ test: skip returns from its caller
SkipIfChannelClaimed::
;> if wSoundClaimed & wSoundChannelBits:
	ld a, [wSoundChannelBits]
	ld b, a
	ld a, [wSoundClaimed]
	and b
	ret z

;>     return_from_caller()
	pop af
	ret


;@ path: sound/data
;@ Periods of the 12 notes of the lowest octave (u16, $800 minus the period is
;@ the NRx3/NRx4 frequency value), in two sets (the second, chosen by event $AE,
;@ slightly lower). PlayNote halves the period once per octave.
NoteFrequencies::
	db $d4, $07, $64, $07, $f9, $06, $95, $06, $37, $06, $dd, $05, $89, $05, $3a, $05
	db $f0, $04, $a8, $04, $65, $04, $26, $04, $9c, $07, $2e, $07, $c7, $06, $66, $06
	db $0a, $06, $b3, $05, $61, $05, $15, $05, $cc, $04, $86, $04, $45, $04, $08, $04
;@ path: sound/data
;@ Volume scaling for the instrument envelopes: 16 rows (the step's level) of
;@ 16 columns (the channel's volume 0-15); the value is the volume to play, in
;@ the high nibble.
InstrumentVolumes::
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
;@ path: sound/data
;@ Vibrato offsets added to the low frequency byte: 8 tables (event $A3 bits
;@ 4-6) of 16 frames each (signed bytes).
VibratoTables::
	db $00, $00, $01, $01, $00, $00, $ff, $ff, $00, $00, $01, $01, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00, $ff, $ff, $ff, $ff
	db $00, $01, $02, $01, $00, $ff, $fe, $ff, $00, $01, $02, $01, $00, $ff, $fe, $ff
	db $00, $00, $01, $01, $02, $02, $01, $01, $00, $00, $ff, $ff, $fe, $fe, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02

;@ def LoadWavePattern()
;@ path: sound/engine
;@ Copies wave pattern hChanSweep from WavePatterns into wave RAM ($FF30), if
;@ it is not the one there already.
;@ test: skip writes wave RAM
LoadWavePattern::
;> if hChanSweep == wSoundWave:
;>     return
	ld a, [wSoundWave]
	ld b, a
	ldh a, [hChanSweep]
	cp b
	ret z

;> wSoundWave = hChanSweep
	ld [wSoundWave], a
;> rNR30 = 0                              # wave off while it is written
	ld e, a
	swap e
	xor a
	ldh [rNR30], a
;>@c copy(0xFF30, WavePatterns + 16 * hChanSweep, 16)
	ld d, a
	ld hl, WavePatterns
	add hl, de
	ld de, $ff30
	ld b, $10

.copy
;=@c
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy

	ret


;@ path: unused
;@ The end of the home bank ($3C25-$3FFF): bytes that look like code from an
;@ earlier build of the game (they call addresses that hold other routines in
;@ this one, and jump to places inside this block), then $FF padding. Nothing
;@ refers to them.
LeftoverCode::
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
