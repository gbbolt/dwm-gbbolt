INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $00b", ROMX[$4000], BANK[$b]

;@ path: field/map
;@ Bank number byte: RST $10 reads it to know which bank to switch back to.
BankNumber_0B::
	db $0b

;@ path: field/map
;@ Far-call entry points of bank $0B, the map-screen bank (tilesets, screens, objects,
;@ triggers and warps).
FarTable_0B::
	dw LoadMapTileset
	dw ReloadMapTileset
	dw DrawMapScreen
	dw RedrawScreenBuffer
	dw FindObjectAtPosition
	dw CheckStepTrigger
	dw CheckStandingWarp
	dw SpawnMapObjects
	dw GetScreenTilemapRef
	dw CheckEdgeWarp

;@ def LoadMapTileset()
;@ path: field/map
;@ Map setup: takes over a pending warp's destination as the current map, then loads
;@ the map's tileset to $9000 and its size from the map info table in the home bank
;@ ($26DD, 8 bytes per map: tileset reference, width u16, height u16, solid-tile limit;
;@ $2A5D on gate floors). The extra tiles for map 8 ($291D to $8800) are meant for map 8
;@ only, but the check lost its compare (`ld a, $08` instead of `cp $08`), so whether
;@ they load depends on the flags DecompressVRAM leaves.
;@ test: skip decompresses graphics
LoadMapTileset::
;> if wWarpPending:
	ld a, [wWarpPending]
	or a
	jr z, .noWarp
;>     wMapId = wWarpMap
	ld a, [wWarpMap]
	ld [wMapId], a
;>     wOnGateFloor = wWarpOnGateFloor
	ld a, [wWarpOnGateFloor]
	ld [wOnGateFloor], a
.noWarp
;> NextGateFloor()
	ld hl, far_NextGateFloor
	rst $10
;> info = GateFloorMapInfo if wOnGateFloor else MapInfo
	ld de, MapInfo
	ld a, [wOnGateFloor]
	or a
	jr z, .fixed
	ld de, GateFloorMapInfo
.fixed
;>@i info += wMapId * 8
	ld a, [wMapId]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@i
	add hl, de
;>@d DecompressVRAM(hi(mem16[info]), lo(mem16[info]), 0x9000)   # the map's tiles
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	push hl
;=@d
	ld hl, $9000
	call DecompressVRAM
;> if flags_nz:                        # (meant: wMapId == 8)
	ld a, [wMapId]
	ld a, $08
	jr nz, .size
;>     DecompressVRAM(0x29, 0x1D, 0x8800)
	ld de, $291d
	ld hl, $8800
	call DecompressVRAM
;>     wFieldTimer = 0
	xor a
	ld [wFieldTimer], a
	ld [wFieldTimer + 1], a
	jr .size

	; unused bytes nothing reaches (a leftover code fragment)
	db $fa, $51, $d9, $fe, $07, $20, $0a, $af, $21, $d8, $c0, $01, $28, $00, $cd, $c7
	db $12

.size
;> hMapWidth = mem16[info + 2]
	pop hl
	ld a, [hli]
	ldh [hMapWidth], a
	ld a, [hli]
	ldh [hMapWidth + 1], a
;> hMapHeight = mem16[info + 4]
	ld a, [hli]
	ldh [hMapHeight], a
	ld a, [hl]
	ldh [hMapHeight + 1], a
;> MakeGateFloor()
	ld hl, far_MakeGateFloor
	rst $10
;> return
	ret


;@ def ReloadMapTileset()
;@ path: field/map
;@ Reloads the current map's tileset and size (as LoadMapTileset without the warp and the
;@ far calls; same lost compare for map 8).
;@ test: skip decompresses graphics
ReloadMapTileset::
;> info = GateFloorMapInfo if wOnGateFloor else MapInfo
	ld de, MapInfo
	ld a, [wOnGateFloor]
	or a
	jr z, .fixed
	ld de, GateFloorMapInfo
.fixed
;>@i info += wMapId * 8
	ld a, [wMapId]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@i
	add hl, de
;>@d DecompressVRAM(hi(mem16[info]), lo(mem16[info]), 0x9000)
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	push hl
;=@d
	ld hl, $9000
	call DecompressVRAM
;> if flags_nz:                        # (meant: wMapId == 8)
	ld a, [wMapId]
	ld a, $08
	jr nz, .size
;>     DecompressVRAM(0x29, 0x1D, 0x8800)
	ld de, $291d
	ld hl, $8800
	call DecompressVRAM
;>     wFieldTimer = 0
	xor a
	ld [wFieldTimer], a
	ld [wFieldTimer + 1], a
.size
;> hMapWidth = mem16[info + 2]
	pop hl
	ld a, [hli]
	ldh [hMapWidth], a
	ld a, [hli]
	ldh [hMapWidth + 1], a
;> hMapHeight = mem16[info + 4]
	ld a, [hli]
	ldh [hMapHeight], a
	ld a, [hl]
	ldh [hMapHeight + 1], a
;> return
	ret


;@ def DrawMapScreen()
;@ path: field/map
;@ Draws the map screen Terry is on. Maps are made of screens of 10 x 8 tiles (160 x 128
;@ pixels), up to 4 across: wMapScreen = row * 4 + column, and the camera goes to the
;@ screen's corner. The screen's tilemap is decompressed to wSavedTilemap (20 x 16 tiles,
;@ rows 32 bytes apart) and copied to the background map at the scroll position; on a
;@ Game Boy Color the attributes come from wScreenMap (two 4-bit values per byte).
;@ The screen is marked as seen. The code after the final ret (far entry 3) only
;@ rebuilds the screen's tilemap buffer.
;@ test: skip draws a whole screen
DrawMapScreen::
;>@r row = hPlayerY // 128
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [hPlayerY + 1]
	ld h, a
	ld a, $80
	call Divide16
;> wMapScreen = row * 4
	ld a, l
	add a
	add a
	ld [wMapScreen], a
;>@sy hScrollY = row * 128
	ld a, $80
	ld c, l
	ld b, h
	call Multiply24
	ld a, l
	ldh [hScrollY], a
;=@sy
	ld a, h
	ldh [hScrollY + 1], a
;> col = hPlayerX // 160
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [hPlayerX + 1]
	ld h, a
	ld a, $a0
	call Divide16
;> wMapScreen += col
	ld a, [wMapScreen]
	add l
	ld [wMapScreen], a
;>@sx hScrollX = col * 160
	ld a, $a0
	ld c, l
	ld b, h
	call Multiply24
	ld a, l
	ldh [hScrollX], a
;=@sx
	ld a, h
	ldh [hScrollX + 1], a
;> if not wFieldFlags & 0x0A:
	ld a, [wFieldFlags]
	bit 1, a
	jr nz, .draw
	bit 3, a
	jr nz, .draw
;>     LoadMapPalettes()
	ld hl, far_LoadMapPalettes
	rst $10
;>     if not wGameStarted & 0x80:
	ld a, [wGameStarted]
	bit 7, a
	jr nz, .draw
;>         ref = GetScreenTilemapRef(); Decompress(hi(ref), lo(ref), wSavedTilemap)   # the screen's tilemap
	call GetScreenTilemapRef
	ld hl, wSavedTilemap
	call Decompress
;>         PlaceFloorStairs(wSavedTilemap)  # the stairs of a gate floor
	ld de, wSavedTilemap
	call PlaceFloorStairs
;>         LoadMapAttrBuffer()
	ld hl, far_LoadMapAttrBuffer
	rst $10
.draw
;> if wOnCGB:
	ld a, [wOnCGB]
	or a
	jr z, .tiles
;>     rVBK = 1                      # attributes
	di
	call WaitVRAMAccess
	ld a, $01
	ldh [rVBK], a
	ei
;>@b     base = 0x9800 + (hScrollY & 0xF8) * 4 + (hScrollX >> 3 & 0x1F)
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
;=@b
	sla l
	rla
	ld h, $98
	add h
	ld h, a
	ldh a, [hScrollX]
;=@b
	rrca
	rrca
	rrca
	and $1f
	add l
	ld l, a
;=@b
	ld a, $00
	adc h
	ld h, a
;>@y     for y in range(16):
	ld de, wScreenMap
	ld c, $10
.attrRow
;>@x         for x in range(10):
	ld b, $0a
	push hl
.attrPair
;>@n1             WriteVRAM(wScreenMap[16 * y + x] >> 4, 0x9800 | (base + 32 * y) & 0x3E0 | (base + 2 * x) & 0x1F)   # left tile (column wraps at 32)
	ld a, [de]
	swap a
	and $0f
	call WriteVRAM
;=@n1
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@n1
	ld l, a
	pop af
	or l
	ld l, a
;>@n2             WriteVRAM(wScreenMap[16 * y + x] & 0x0F, 0x9800 | (base + 32 * y) & 0x3E0 | (base + 2 * x + 1) & 0x1F)  # right tile
	ld a, [de]
	and $0f
	call WriteVRAM
;=@n2
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@n2
	ld l, a
	pop af
	or l
	ld l, a
;=@x
	inc de
	dec b
	jr nz, .attrPair
;=@y
	pop hl
	ld a, e
	add $06
	ld e, a
	ld a, d
	adc $00
;=@y
	ld d, a
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
;=@y
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, .attrRow
;>     rVBK = 0
	di
	call WaitVRAMAccess
	ld a, $00
	ldh [rVBK], a
	ei
.tiles
;>@t base = 0x9800 + (hScrollY & 0xF8) * 4 + (hScrollX >> 3 & 0x1F)
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
;=@t
	sla l
	rla
	ld h, $98
	add h
	ld h, a
	ldh a, [hScrollX]
;=@t
	rrca
	rrca
	rrca
	and $1f
	add l
	ld l, a
;=@t
	ld a, $00
	adc h
	ld h, a
;>@ty for y in range(16):              # 16 rows of 20 tiles
	ld de, wSavedTilemap
	ld c, $10
.tileRow
;>@tx     for x in range(20):
	ld b, $14
	push hl
.tile
;>@tw         WriteVRAM(wSavedTilemap[32 * y + x], 0x9800 | (base + 32 * y) & 0x3E0 | (base + x) & 0x1F)   # (columns wrap at 32)
	ld a, [de]
	call WriteVRAM
	ld a, l
	and $e0
	push af
	ld a, l
;=@tw
	inc a
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
;=@tx
	inc de
	dec b
	jr nz, .tile
;=@ty
	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
;=@ty
	ld d, a
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
;=@ty
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, .tileRow
;>@sn wFloorsSeen[wMapScreen] = 1      # this screen has been visited
	ld a, [wMapScreen]
	ld hl, wFloorsSeen
	add l
	ld l, a
	ld a, $00
	adc h
;=@sn
	ld h, a
	ld [hl], $01
;> return
	ret


;@ def RedrawScreenBuffer()
;@ path: field/map
;@ Far entry: rebuilds the current screen's tilemap in wTilemapBuffer (with the gate
;@ floor stairs) and its palettes and attributes without drawing it, and marks the
;@ screen as seen.
;@ test: skip decompresses a screen
RedrawScreenBuffer::
;> LoadMapPalettes()
	ld hl, far_LoadMapPalettes
	rst $10
;> ref = GetScreenTilemapRef(); Decompress(hi(ref), lo(ref), wTilemapBuffer)
	call GetScreenTilemapRef
	ld hl, wTilemapBuffer
	call Decompress
;> PlaceFloorStairs(wTilemapBuffer)
	ld de, wTilemapBuffer
	call PlaceFloorStairs
;> LoadMapAttrBuffer()
	ld hl, far_LoadMapAttrBuffer
	rst $10
;>@sn wFloorsSeen[wMapScreen] = 1
	ld a, [wMapScreen]
	ld hl, wFloorsSeen
	add l
	ld l, a
	ld a, $00
	adc h
;=@sn
	ld h, a
	ld [hl], $01
;> return
	ret


;@ def GetScreenTilemapRef() -> de
;@ path: field/map
;@ Tilemap reference (entry, bank) of the current screen. Fixed maps: MapScreenTable gives
;@ the map's list of 16 screen pointers; a screen starts with the address of the story
;@ variable that selects its version, followed by 6-byte versions (tilemap reference,
;@ object list, warp list) indexed by that variable's value. Gate floors build theirs in
;@ bank $16.
;@ test: skip reads the map tables
GetScreenTilemapRef::
;> if wOnGateFloor:
	ld a, [wOnGateFloor]
	or a
	jr z, .fixedMap
;>     return GetFloorScreenMap()
	ld hl, far_GetFloorScreenMap
	rst $10
	ret


.fixedMap
;>@m screens = mem16[MapScreenTable + wMapId * 2]
	ld hl, MapScreenTable
	ld a, [wMapId]
	add a
	add l
	ld l, a
	ld a, $00
;=@m
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@s screen = mem16[screens + wMapScreen * 2]
	ld a, [wMapScreen]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@v version = screen + 2 + mem[mem16[screen]] * 6
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [de]
	ld e, a
;=@v
	add a
	add e
	add a
	add l
	ld l, a
	ld a, $00
;=@v
	adc h
	ld h, a
;> return mem16[version]
	ld e, [hl]
	inc hl
	ld d, [hl]
	ret


;@ def GetScreenObjects() -> hl
;@ path: field/map
;@ Object list of the current screen (version field +2, see GetScreenTilemapRef): 5-byte records
;@ ($FF ends) - flags, sprite or trigger parameter, tile X, tile Y (in the screen), script
;@ number. Flags bit 7 clear: an actor (bits 4-5 its facing); $8x: a talk trigger (low
;@ nibble = direction Terry must face, $F any); $9x: a step trigger. On a gate floor the
;@ list is GateFloorNpcLists[wFloorNpcKind], or an empty one without a special character.
;@ test: skip reads the map tables
GetScreenObjects::
;> if not wOnGateFloor:
	ld a, [wOnGateFloor]
	or a
	jr nz, .gateFloor
;>@m     screens = mem16[MapScreenTable + wMapId * 2]
	ld hl, MapScreenTable
	ld a, [wMapId]
	add a
	add l
	ld l, a
	ld a, $00
;=@m
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@s     screen = mem16[screens + wMapScreen * 2]
	ld a, [wMapScreen]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@v     version = screen + 2 + mem[mem16[screen]] * 6
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [de]
	ld e, a
;=@v
	add a
	add e
	add a
	add l
	ld l, a
	ld a, $00
;=@v
	adc h
	ld h, a
;>     return mem16[version + 2]
	inc hl
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret


.gateFloor
;> if wFloorNpcScreen == 0xFF:
	ld a, [wFloorNpcScreen]
	cp $ff
	jr nz, .npc
;>     return GateFloorNoObjects
	ld hl, GateFloorNoObjects
	ret


.npc
;>@n return GateFloorNpcLists[wFloorNpcKind]
	ld hl, GateFloorNpcLists
	ld a, [wFloorNpcKind]
	add a
	add l
	ld l, a
	ld a, $00
;=@n
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret


;@ path: field/gatefloor
;@ Object lists of the gate floors' special characters, by wFloorNpcKind: 8 pointers,
;@ then one actor record each (flags $0F, sprite, tile 1/1 - SpawnMapObjects moves it to
;@ wFloorNpcX/Y - and script 1-6) ended by $FF.
GateFloorNpcLists::
	db $d8, $42, $de, $42, $e4, $42, $ea, $42, $f0, $42, $f6, $42, $fc, $42, $02, $43
	db $0f, $0b, $01, $01, $01, $ff, $0f, $0b, $01, $01, $01, $ff, $0f, $0c, $01, $01
	db $02, $ff, $0f, $0c, $01, $01, $02, $ff, $0f, $11, $01, $01, $03, $ff, $0f, $08
	db $01, $01, $04, $ff, $0f, $0f, $01, $01, $05, $ff, $0f, $06, $01, $01, $06, $ff
;@ path: field/gatefloor
;@ An empty object list (only the $FF end), for gate floors without a special character.
GateFloorNoObjects::
	db $ff

;@ def PlaceFloorStairs(tilemap: de)
;@ path: field/gatefloor
;@ On the gate floor's stairs screen, writes the 2 x 2 stairs tiles ($3C-$3F) into the
;@ screen's tilemap at wStairsOffset.
;@ test: skip writes a tilemap buffer
PlaceFloorStairs::
;> if not wOnGateFloor or wMapScreen != wStairsScreen:
	ld a, [wOnGateFloor]
	or a
	ret z
	ld hl, wStairsScreen
	ld a, [wMapScreen]
	cp [hl]
;>     return
	ret nz
;> p = tilemap + wStairsOffset
	ld a, [wStairsOffset]
	ld l, a
	ld a, [wStairsOffset + 1]
	ld h, a
	add hl, de
;> mem[p] = 0x3C
	ld a, $3c
	ld [hli], a
;> mem[p + 1] = 0x3D
	inc a
	ld [hl], a
;>@r mem[p + 32] = 0x3E                # next row
	ld a, l
	add $1f
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r
	ld a, $3e
	ld [hli], a
;> mem[p + 33] = 0x3F
	inc a
	ld [hl], a
;> return
	ret


;@ def FindObjectAtPosition() -> hNumber
;@ path: field/objects
;@ Far entry: script number of the actor or talk trigger at the position in
;@ hDivisorHigh/hFindY (see FindObjectAt) into hNumber, $FF for nothing.
;@ test: skip reads the map tables
FindObjectAtPosition::
;> hNumber[1] = 0
	ld a, $00
	ldh [hNumber + 1], a
;> hNumber[0] = FindObjectAt(wActors)
	ld hl, wActors
	call FindObjectAt
	ldh [hNumber], a
;> return
	ret


;@ def FindObjectAt(actors: hl) -> a
;@ path: field/objects
;@ What is at position (X in hDivisorHigh/$FFDC, Y in hFindY/$FFDE, pixels): first the
;@ actors (32-byte records, $FF ends; bit 6 of the flags = ignore) - an actor within 16
;@ pixels gives its script number (+4) and leaves its index in $FFD6. Otherwise the
;@ screen's talk triggers ($8x records of the object list, low nibble = the direction
;@ Terry must face, $F any) on that tile; $FFD6 = $FF then. $FF = nothing.
;@ test: skip reads the map tables
FindObjectAt::
;> while mem[actors] != 0xFF:
	ld a, [hl]
	cp $ff
	jr z, .triggers
;>     if not mem[actors] & 0x40 and IsActorAt(actors):
	bit 6, a
	jr nz, .nextActor
	call IsActorAt
	jr nz, .nextActor
;>@ra         return mem[actors + 4]
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@ra
	ld a, [hl]
	ret


.nextActor
;>@na     actors += 0x20
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>     hNumber[1] += 1
	ldh a, [hNumber + 1]
	inc a
	ldh [hNumber + 1], a
;=@na
	jr FindObjectAt

.triggers
;> hNumber[1] = 0xFF
	ld a, $ff
	ldh [hNumber + 1], a
;> obj = GetScreenObjects()
	call GetScreenObjects

.trigger
;>@t while mem[obj] != 0xFF:
	ld a, [hl]
	cp $ff
	ret z
;>     if not mem[obj] & 0x80:          # the actor records follow the triggers
;>         return 0xFF
	bit 7, a
	jr z, .none
;>     if (mem[obj] & 0xF0) == 0x80 and IsTriggerAt(obj):
	and $f0
	cp $80
	jr nz, .nextTrigger
	call IsTriggerAt
	jr nz, .nextTrigger
;>         need = mem[obj] & 0x0F
	ld a, [hl]
	and $0f
;>         if need == 0x0F or need == hPlayerDir:
	cp $0f
	jr z, .found
	ld b, a
	ldh a, [hPlayerDir]
	cp b
	jr nz, .nextTrigger

.found
;>@rf             return mem[obj + 4]
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@rf
	ld a, [hl]
	ret


.nextTrigger
;>     obj += 5
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@t
	jr .trigger

.none
;> return 0xFF
	ld a, $ff
	ret


;@ def CheckStepTrigger() -> hNumber
;@ path: field/objects
;@ Far entry: script number of the step trigger ($9x object record) under Terry into
;@ hNumber; $FF when there is none, Terry is busy (bit 6 of hPlayerFlags) or a script
;@ is running.
;@ test: skip reads the map tables
CheckStepTrigger::
;> hNumber[0] = 0xFF
	ld a, $ff
	ldh [hNumber], a
;> if hPlayerFlags & 0x40 or wScriptRunning:
	ldh a, [hPlayerFlags]
	bit 6, a
	ret nz
	ld a, [wScriptRunning]
	or a
;>     return
	ret nz
;> hNumber[0] = FindStepTrigger()
	call FindStepTrigger
	ldh [hNumber], a
;> return
	ret


;@ def FindStepTrigger() -> a
;@ path: field/objects
;@ Script number of the step trigger ($9x object record) on the tile at hDivisorHigh/
;@ hFindY, $FF when none.
;@ test: skip reads the map tables
FindStepTrigger::
;> obj = GetScreenObjects()
	call GetScreenObjects

.loop
;>@t while mem[obj] != 0xFF:
	ld a, [hl]
	cp $ff
	ret z
;>     if not mem[obj] & 0x80:
;>         return 0xFF
	bit 7, a
	jr z, .none
;>     if (mem[obj] & 0xF0) == 0x90 and IsTriggerAt(obj):
	and $f0
	cp $90
	jr nz, .next
	call IsTriggerAt
	jr nz, .next
;>@r         return mem[obj + 4]
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r
	ld a, [hl]
	ret


.next
;>     obj += 5
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@t
	jr .loop

.none
;> return 0xFF
	ld a, $ff
	ret


;@ def IsActorAt(actor: hl) -> zero
;@ path: field/objects
;@ Zero flag set when the actor (not hidden: bit 0 of +5) stands less than 16 pixels from
;@ position (hDivisorHigh/$FFDC, hFindY/$FFDE) in both X (+$18) and Y (+$1A).
;@ test: skip reads HRAM inputs
IsActorAt::
;>@h if mem[actor + 5] & 1:
	push hl
	push bc
	push de
	ld a, l
	add $05
	ld l, a
;=@h
	ld a, h
	adc $00
	ld h, a
	bit 0, [hl]
;>     return False
	jr nz, PositionMiss
;>@dx dx = mem16[0xFFDB] - mem16[actor + 0x18]
	ld a, l
	add $13
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@dx
	ldh a, [hDivisorHigh]
	sub [hl]
	inc hl
	ld c, a
	ldh a, [$ffdc]
	sbc [hl]
;=@dx
	inc hl
	ld b, a
;>@ax if abs(dx) >= 16:
	jr nz, .negX
	ld a, c
	cp $10
	jr nc, PositionMiss
	jr .checkY

.negX
;=@ax
	ld a, c
	cpl
	add $01
	ld c, a
	ld a, b
	cpl
;=@ax
	adc $00
	ld b, a
	ld a, b
	or a
	jr nz, PositionMiss
;=@ax
	ld a, c
	cp $10
;>     return False
	jr nc, PositionMiss

.checkY
;>@dy dy = hFindY - mem16[actor + 0x1A]
	ldh a, [hFindY]
	sub [hl]
	inc hl
	ld c, a
	ldh a, [hFindY + 1]
	sbc [hl]
;=@dy
	ld b, a
;>@ay if abs(dy) >= 16:
	jr nz, .negY
	ld a, c
	cp $10
	jr nc, PositionMiss
	jr PositionHit

.negY
;=@ay
	ld a, c
	cpl
	add $01
	ld c, a
	ld a, b
	cpl
;=@ay
	adc $00
	ld b, a
	ld a, b
	or a
	jr nz, PositionMiss
;=@ay
	ld a, c
	cp $10
;>     return False
	jr nc, PositionMiss

PositionHit:
;> return True
	xor a
	pop de
	pop bc
	pop hl
	ret


PositionMiss:
;> return False
	xor a
	inc a
	pop de
	pop bc
	pop hl
	ret


;@ def IsTriggerAt(obj: hl) -> zero
;@ path: field/objects
;@ Zero flag set when the object record's tile (+2 X, +3 Y, inside the 10 x 8 screen)
;@ is the tile of position (hDivisorHigh/$FFDC, hFindY/$FFDE).
;@ test: skip reads HRAM inputs
IsTriggerAt::
;>@x if (mem16[0xFFDB] >> 4) % 10 != mem[obj + 2]:
	push hl
	push bc
	push de
	inc hl
	inc hl
	ldh a, [hDivisorHigh]
;=@x
	swap a
	and $0f
	ld b, a
	ldh a, [$ffdc]
	swap a
	and $f0
;=@x
	or b
	ld b, a
	ld a, $0a
	call Divide8
	cp [hl]
;>     return False
	jr nz, PositionMiss
;>@y if (hFindY >> 4) % 8 != mem[obj + 3]:
	inc hl
	ldh a, [hFindY]
	swap a
	and $0f
	ld b, a
	ldh a, [hFindY + 1]
;=@y
	swap a
	and $f0
	or b
	ld b, a
	ld a, $08
	call Divide8
;=@y
	cp [hl]
;>     return False
	jr nz, PositionMiss
;> return True
	jr PositionHit

;@ def CheckEdgeWarp()
;@ path: field/warps
;@ Warps on the screen edge: when Terry stands on the tile of a warp record that lies on
;@ the border of its screen (X 0 or 9, Y 0 or 7), takes it. Warp records (7 bytes, $FF
;@ ends; the list is field +4 of the screen version): tile X, tile Y in the screen,
;@ destination map, destination gate-floor flag, destination screen (low nibble; bit 7 =
;@ half a tile lower), destination tile X and Y in that screen.
;@ test: skip reads the map tables
CheckEdgeWarp::
;> if wFadeState or wGameModeChange or wMapLoadState:
;>@c     return
	ld a, [wFadeState]
	or a
	ret nz
	ld a, [wGameModeChange]
	or a
	ret nz
;=@c
	ld a, [wMapLoadState]
	or a
	ret nz
;> if wFieldFlags & 1 or hPlayerFlags & 1 or wOnGateFloor:
;>@g     return
	ld a, [wFieldFlags]
	bit 0, a
	ret nz
	ldh a, [hPlayerFlags]
	bit 0, a
	ret nz
;=@g
	ld a, [wOnGateFloor]
	or a
	ret nz
;>@m screens = mem16[MapScreenTable + wMapId * 2]
	ld hl, MapScreenTable
	ld a, [wMapId]
	add a
	add l
	ld l, a
	ld a, $00
;=@m
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@s screen = mem16[screens + wMapScreen * 2]
	ld a, [wMapScreen]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@v version = screen + 2 + mem[mem16[screen]] * 6
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [de]
	ld e, a
;=@v
	add a
	add e
	add a
	add l
	ld l, a
	ld a, $00
;=@v
	adc h
	ld h, a
;>@w warp = mem16[version + 4]
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [hli]
	ld h, [hl]
;=@w
	ld l, a
;>@o origin = ScreenTileOrigins[wMapScreen]   # tile position of the screen in the map
	ld bc, ScreenTileOrigins
	ld a, [wMapScreen]
	add a
	add c
	ld c, a
	ld a, $00
;=@o
	adc b
	ld b, a
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
;=@o
	ld d, a

.loop
;>@l while mem[warp] != 0xFF:
	ld a, [hl]
	cp $ff
	ret z
;>@e     if mem[warp] in (0, 9) or mem[warp + 1] in (0, 7):
	ld a, [hl]
	or a
	jr z, .edge
	cp $09
	jr z, .edge
;=@e
	inc hl
	ld a, [hl]
	dec hl
	or a
	jr z, .edge
;=@e
	cp $07
	jr z, .edge
	jr .next

.edge
;>@t         if hPlayerTileX - origin.x == mem[warp] and hPlayerTileY - origin.y == mem[warp + 1]:
	ldh a, [hPlayerTileX]
	sub e
	cp [hl]
	jr nz, .next
	inc hl
	ldh a, [hPlayerTileY]
;=@t
	sub d
	cp [hl]
	dec hl
;>             return TakeWarp(warp)
	jp z, TakeWarp

.next
;>     warp += 7
	ld a, l
	add $07
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@l
	jr .loop


;@ def CheckStandingWarp()
;@ path: field/warps
;@ Far entry: takes a warp inside the screen (not on its border) when Terry stands on its
;@ tile, or on a gate floor the stairs to the next floor (a stairs tile on wStairsScreen).
;@ TakeWarp sets the destination (wWarpMap, wWarpOnGateFloor, wWarpX/Y in pixels from the
;@ destination screen's origin) and starts the change: a fade, or the gate-world
;@ transition (bit 5 of wFieldFlags) when going to a gate floor or coming back from a
;@ gate world - the party is healed then. Afterwards, on maps $53-$59 and $61-$64,
;@ bank $16 runs CountEncounterSteps.
;@ test: skip reads the map tables
CheckStandingWarp::
;> if wFieldFlags & 1 or hPlayerFlags & 1:
	ld a, [wFieldFlags]
	bit 0, a
	jp nz, AfterWarpCheck
	ldh a, [hPlayerFlags]
	bit 0, a
;>     return AfterWarpCheck()
	jp nz, AfterWarpCheck
;> if wOnGateFloor:
;>     return CheckFloorStairs()
	ld a, [wOnGateFloor]
	or a
	jp nz, CheckFloorStairs
;>@m screens = mem16[MapScreenTable + wMapId * 2]
	ld hl, MapScreenTable
	ld a, [wMapId]
	add a
	add l
	ld l, a
	ld a, $00
;=@m
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@s screen = mem16[screens + wMapScreen * 2]
	ld a, [wMapScreen]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@v version = screen + 2 + mem[mem16[screen]] * 6
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [de]
	ld e, a
;=@v
	add a
	add e
	add a
	add l
	ld l, a
	ld a, $00
;=@v
	adc h
	ld h, a
;>@w warp = mem16[version + 4]
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [hli]
	ld h, [hl]
;=@w
	ld l, a
;>@o origin = ScreenTileOrigins[wMapScreen]
	ld bc, ScreenTileOrigins
	ld a, [wMapScreen]
	add a
	add c
	ld c, a
	ld a, $00
;=@o
	adc b
	ld b, a
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
;=@o
	ld d, a

.loop
;>@l while mem[warp] != 0xFF:          # warps inside the screen
	ld a, [hl]
	cp $ff
	jp z, AfterWarpCheck
;>@x     if mem[warp] not in (0, 9) and hPlayerTileX - origin.x == mem[warp]:
	ld a, [hl]
	or a
	jr z, .next
	cp $09
	jr z, .next
;=@x
	ldh a, [hPlayerTileX]
	sub e
	cp [hl]
	jr nz, .next
;>@y         if mem[warp + 1] not in (0, 7) and hPlayerTileY - origin.y == mem[warp + 1]:
	inc hl
	ld a, [hl]
	dec hl
	or a
	jr z, .next
	cp $07
;=@y
	jr z, .next
	inc hl
	ldh a, [hPlayerTileY]
	sub d
	cp [hl]
	dec hl
;>             return TakeWarp(warp)
	jr z, TakeWarp

.next
;>     warp += 7
	ld a, l
	add $07
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@l
	jr .loop

TakeWarp:
;> wWarpMap = mem[warp + 2]
	inc hl
	inc hl
	ld a, [hli]
	ld [wWarpMap], a
;> wWarpOnGateFloor = mem[warp + 3]
	ld a, [hli]
	ld [wWarpOnGateFloor], a
;>@sc screen = mem[warp + 4]
	ld de, ScreenTileOrigins
	ld a, [hli]
	push af
	and $0f
	add a
	add e
;=@sc
	ld e, a
	ld a, $00
	adc d
	ld d, a
;>@wx wWarpX = (ScreenTileOrigins[screen & 0x0F].x + mem[warp + 5]) * 16 + 8
	ld a, [de]
	add [hl]
	inc de
	inc hl
	swap a
	ld b, a
;=@wx
	and $f0
	ld c, a
	ld a, b
	and $0f
	ld b, a
	ld a, c
;=@wx
	add $08
	ld c, a
	ld a, b
	adc $00
	ld b, a
	ld a, c
;=@wx
	ld [wWarpX], a
	ld a, b
	ld [wWarpX + 1], a
;>@wy y = (ScreenTileOrigins[screen & 0x0F].y + mem[warp + 6]) * 16 + 8
	ld a, [de]
	add [hl]
	inc de
	inc hl
	swap a
	ld b, a
;=@wy
	and $f0
	ld c, a
	ld a, b
	and $0f
	ld b, a
	ld a, c
;=@wy
	add $08
	ld c, a
	ld a, b
	adc $00
	ld b, a
;> if screen & 0x80:
	pop af
	bit 7, a
	jr z, .setY
;>     y += 8
	ld a, c
	add $08
	ld c, a
	ld a, b
	adc $00
	ld b, a

.setY
;> wWarpY = y
	ld a, c
	ld [wWarpY], a
	ld a, b
	ld [wWarpY + 1], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> fade = False                      # False: the gate-world transition instead
;> if not wWarpOnGateFloor:
	ld a, [wWarpOnGateFloor]
	or a
	jr nz, .special
;>     fade = True
;>@lv     leaving = not wOnGateFloor and wMapId == 0x10 and hPlayerY == 0x68
	ld a, [wOnGateFloor]
	or a
	jr nz, .checkWorld
	ld a, [wMapId]
	cp $10
	jr nz, .checkWorld
;=@lv
	ldh a, [hPlayerY]
	cp $68
	jr z, .leaving

.checkWorld
;>     if leaving or IsInGateWorld():
	call IsInGateWorld
	jr z, .fade

.leaving
;>         save = (wMapId, wOnGateFloor)
	ld a, [wMapId]
	ld l, a
	ld a, [wOnGateFloor]
	ld h, a
	push hl
;>         wMapId = wWarpMap
;>@dw         wOnGateFloor = wWarpOnGateFloor
	ld a, [wWarpMap]
	ld l, a
	ld a, [wWarpOnGateFloor]
	ld h, a
	ld a, l
	ld [wMapId], a
;=@dw
	ld a, h
	ld [wOnGateFloor], a
;>         inWorld = IsInGateWorld()      # the destination
	call IsInGateWorld
;>         wMapId = save[0]
;>@rs         wOnGateFloor = save[1]
	pop hl
	push af
	ld a, l
	ld [wMapId], a
	ld a, h
	ld [wOnGateFloor], a
;=@rs
	pop af
;>         if not inWorld:
	jr nz, .fade
;>             HealAllMonsters()          # back from a gate world
	ld hl, far_HealAllMonsters
	rst $10
;>             fade = False
	jr .special

.fade
;> if fade:
;>     StartFade(3)
	ld a, $03
	call StartFade
;>     wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
;>     QueueSound(0x51)
	ld a, $51
	call QueueSound
	jr AfterWarpCheck

.special
;> else:
;>     wFieldFlags |= 0x20
	ld hl, wFieldFlags
	set 5, [hl]
;>     wMenuStep = 0
	xor a
	ld [wMenuStep], a

AfterWarpCheck:
;> if wMapId in (0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x61, 0x62, 0x63, 0x64):
;>@mp     return FieldWarpHook()
	ld a, [wMapId]
	ld a, [wMapId]
	cp $53
	jr z, FieldWarpHook
	cp $61
	jr z, FieldWarpHook
;=@mp
	cp $62
	jr z, FieldWarpHook
	cp $63
	jr z, FieldWarpHook
	cp $64
	jr z, FieldWarpHook
;=@mp
	cp $54
	jr z, FieldWarpHook
	cp $55
	jr z, FieldWarpHook
	cp $56
	jr z, FieldWarpHook
;=@mp
	cp $57
	jr z, FieldWarpHook
	cp $58
	jr z, FieldWarpHook
	cp $59
	jr z, FieldWarpHook
;> return
	ret

CheckFloorStairs:
;>@st if wMapScreen == wStairsScreen and hTestTile >> 2 == 0x0F:   # a stairs tile ($3C-$3F)
	ld hl, wStairsScreen
	ld a, [wMapScreen]
	cp [hl]
	jr nz, FieldWarpHook
	ldh a, [hTestTile]
	srl a
;=@st
	srl a
	cp $0f
	jr nz, FieldWarpHook
;>     wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;>     wWarpMap = 0
	ld a, $00
	ld [wWarpMap], a
;>     wWarpOnGateFloor = 0x80            # to the next floor
	ld a, $80
	ld [wWarpOnGateFloor], a
;>     CheckFloorExplored()
	call CheckFloorExplored
;>     wFieldFlags |= 0x20
	ld hl, wFieldFlags
	set 5, [hl]
;>     wMenuStep = 0
	xor a
	ld [wMenuStep], a

FieldWarpHook:
;> CountEncounterSteps()
	ld hl, far_CountEncounterSteps
	rst $10
;> return
	ret


;@ def CheckFloorExplored()
;@ path: field/gatefloor
;@ When every existing screen of the gate floor has been seen, sets wFloorEvent: 5 for
;@ a full floor of 16 screens, 6 for a floor of only 2.
;@ test: skip gate floor state
CheckFloorExplored::
;> if not wOnGateFloor:
	ld a, [wOnGateFloor]
	or a
;>     return
	ret z
;> count = 0
	ld hl, wFloorLayout
	ld de, wFloorsSeen
	ld b, $10
	ld c, $00

.loop
;>@f for i in range(16):
;>     if (wFloorLayout[i] & 0xF0) != 0xF0:     # a screen exists there
	ld a, [hl]
	and $f0
	cp $f0
	jr z, .skip
;>         if not wFloorsSeen[i]:
	ld a, [de]
	or a
;>             return
	ret z
;>         count += 1
	inc c

.skip
;=@f
	inc hl
	inc de
	dec b
	jr nz, .loop
;> if count == 16:
;>@e5     wFloorEvent = 5
	ld a, c
	cp $10
	jr z, .full
;> elif count == 2:
;>@e6     wFloorEvent = 6
	cp $02
	jr z, .two
;> return
	ret


.full
;=@e5
	ld a, $05
	ld [wFloorEvent], a
	ret


.two
;=@e6
	ld a, $06
	ld [wFloorEvent], a
	ret


;@ def SpawnMapObjects()
;@ path: field/objects
;@ Creates the actors of the current screen from its object list (see GetScreenObjects)
;@ and loads their sprite graphics. On a gate floor the floor's special character is
;@ placed with the screen origin of its own screen and then moved to wFloorNpcX/Y.
;@ During the intro/ending sequences (bit 7 of wGameStarted) bank 6 sets the actors up.
;@ test: skip loads graphics
SpawnMapObjects::
;> if wGameStarted & 0x80:
	ld a, [wGameStarted]
	bit 7, a
	jr z, .field
;>     return LoadFieldActorGfx()
	ld hl, far_LoadFieldActorGfx
	rst $10
	ret


.field
;> FillMemory(wActors, 0x101, 0)
	ld hl, wActors
	ld bc, $0101
	ld a, $00
	call FillMemory
;> ClearActorGfxSlots()
	call ClearActorGfxSlots
;> wActors[0] = 0xFF
	ld a, $ff
	ld [wActors], a
;> obj = GetScreenObjects()
	call GetScreenObjects
;> if not wOnGateFloor or wFloorNpcScreen == 0xFF:
;>     return SpawnObjectList(obj)
	ld a, [wOnGateFloor]
	or a
	jr z, SpawnObjectList
	ld a, [wFloorNpcScreen]
	cp $ff
	jr z, SpawnObjectList
;>@sw swap(wMapScreen, wFloorNpcScreen)
	ld a, [wMapScreen]
	ld b, a
	ld a, [wFloorNpcScreen]
	ld [wMapScreen], a
	ld a, b
	ld [wFloorNpcScreen], a
;> SpawnObjectList(obj)
	call SpawnObjectList
;>@sb swap(wMapScreen, wFloorNpcScreen)
	ld a, [wMapScreen]
	ld b, a
	ld a, [wFloorNpcScreen]
	ld [wMapScreen], a
	ld a, b
	ld [wFloorNpcScreen], a
;>@nx mem16[0xD7EA] = wFloorNpcX          # the first actor's X
	ld a, [wFloorNpcX]
	ld l, a
	ld a, [wFloorNpcX + 1]
	ld h, a
	ld a, l
	ld [wActors + 24], a
;=@nx
	ld a, h
	ld [wActors + 25], a
;>@ny mem16[0xD7EC] = wFloorNpcY
	ld a, [wFloorNpcY]
	ld l, a
	ld a, [wFloorNpcY + 1]
	ld h, a
	ld a, l
	ld [wActors + 26], a
;=@ny
	ld a, h
	ld [wActors + 27], a
;> return
	ret


;@ def SpawnObjectList(obj: hl)
;@ path: field/objects
;@ Turns the actor records of an object list into actors (32 bytes each, from wActors):
;@ +0 flags, +1 sprite, +2/+3 tile X/Y in the map (screen origin added), +4 script,
;@ +6 facing (flags bits 4-5), +$11 graphics number, +$16 first sprite tile,
;@ +$18/+$1A X/Y in pixels (tile * 16 + 8). Trigger records ($8x/$9x) are skipped;
;@ the $FF end marker is copied as the end of the actor list.
;@ test: skip loads graphics
SpawnObjectList::
;> actor = wActors
	ld de, wActors

.loop
;>@l while True:
;>     mem16[0xFFD5] = actor        # kept in hNumber
	ld a, e
	ldh [hNumber], a
	ld a, d
	ldh [hNumber + 1], a
;>     flags = mem[obj]
;>     obj += 1
	ld a, [hli]
;>     mem[actor] = flags
	ld [de], a
;>     if flags == 0xFF:
;>         return
	cp $ff
	ret z
;>     if flags & 0x80:                   # a trigger
	bit 7, a
	jr z, .actor
;>         obj += 4
;>@sk         continue
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@sk
	jr .loop

.actor
;>@or     origin = ScreenTileOrigins[wMapScreen]
	ldh [hNumber + 2], a
	ld bc, ScreenTileOrigins
	ld a, [wMapScreen]
	add a
	add c
	ld c, a
;=@or
	ld a, $00
	adc b
	ld b, a
;>     mem[actor + 1] = mem[obj]          # sprite
	push de
	inc de
	ld a, [hli]
	ld [de], a
;>     mem[actor + 2] = origin.x + mem[obj + 1]
	inc de
	ld a, [bc]
	add [hl]
	ld [de], a
;>     mem[actor + 3] = origin.y + mem[obj + 2]
	inc hl
	inc de
	inc bc
	ld a, [bc]
	add [hl]
	ld [de], a
;>     mem[actor + 4] = mem[obj + 3]      # script
	inc hl
	inc de
	ld a, [hli]
	ld [de], a
;>     mem[actor + 6] = flags >> 4 & 3    # facing
	inc de
	inc de
	ldh a, [hNumber + 2]
	swap a
	and $03
	ld [de], a
;>@g     mem[actor + 0x11] = mem[actor + 1]
	push hl
	ldh a, [hNumber]
	ld e, a
	ldh a, [hNumber + 1]
	ld d, a
	ld a, e
;=@g
	add $11
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ldh a, [hNumber]
;=@g
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	inc hl
	ld a, [hli]
	ld [de], a
;>     tiles = LoadActorGfx(mem[actor + 1], actor + 0x11)
	push hl
	call LoadActorGfx
	pop hl
;>@t     mem[actor + 0x16] = tiles
	push af
	ldh a, [hNumber]
	ld e, a
	ldh a, [hNumber + 1]
	ld d, a
	ld a, e
;=@t
	add $16
	ld e, a
	ld a, d
	adc $00
	ld d, a
	pop af
;=@t
	ld [de], a
;>@p     p = actor + 0x18
	ldh a, [hNumber]
	ld e, a
	ldh a, [hNumber + 1]
	ld d, a
	ld a, e
	add $18
;=@p
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@x     mem16[p] = mem[actor + 2] * 16 + 8
	ld a, [hli]
	swap a
	ld c, a
	and $f0
	or $08
	ld [de], a
;=@x
	inc de
	ld a, c
	and $0f
	ld [de], a
	inc de
;>@y     mem16[p + 2] = mem[actor + 3] * 16 + 8
	ld a, [hl]
	swap a
	ld c, a
	and $f0
	or $08
	ld [de], a
;=@y
	inc de
	ld a, c
	and $0f
	ld [de], a
	inc de
;>@n     actor += 0x20
	pop hl
	pop de
	ld a, e
	add $20
	ld e, a
	ld a, d
;=@n
	adc $00
	ld d, a
;=@l
	jp .loop


;@ def ClearActorGfxSlots()
;@ path: field/objects
;@ Frees the 6 actor sprite-graphics slots of wActorGfxSlots.
;@ test: skip
ClearActorGfxSlots::
;> for i in range(6):
;>@c     wActorGfxSlots[2 * i] = 0xFF
	ld hl, wActorGfxSlots
	ld b, $06

.loop
;=@c
	ld a, $ff
	ld [hli], a
;>     wActorGfxSlots[2 * i + 1] = 0
	xor a
	ld [hli], a
;=@c
	dec b
	jr nz, .loop
;> return
	ret


;@ def LoadActorGfx(sprite: a, gfx: de) -> a
;@ path: field/objects
;@ Makes sure the graphics of an actor's sprite are in VRAM and returns its first sprite
;@ tile; gfx points at the actor's +$11 (graphics number; +$0F graphics source).
;@ $E0: Terry (tile 0, graphics $5E); $E1-$E3: party monster 1-3 following him (tiles
;@ $20/$30/$40); $F0-$F3: the monsters of the encounter list wEncGfx; anything else is
;@ a person sprite. Other graphics share 6 slots of 16 tiles (wActorGfxSlots: number,
;@ source), decompressed from ActorGfx (people) or ActorGfxRefs
;@ (monsters) to $8000 + slot * $100 plus an area offset (gate floors $700, map 8 none,
;@ map $45 $200, others $500). Graphics $15 and $55 of people take two slots. An actor
;@ without its monster is removed (sprite $FF); with no slot free $50 is returned.
;@ test: skip decompresses graphics
LoadActorGfx::
;> if sprite == 0xFF:
;>     return
	cp $ff
	ret z
;> if sprite == 0xE0:
;>@te     mem[gfx] = 0x5E
;>@tr     return 0
	ld b, $00
	cp $e0
	jr z, .terry
;> if sprite in (0xE1, 0xE2, 0xE3):    # tiles $20, $30, $40
;>@p1     if wParty[sprite - 0xE1] == 0xFF:
;>@p2         mem[gfx - 0x10] = 0xFF        # no such follower: remove the actor
;>@p3         return 0
;>@p4     mem[gfx] = wPartyGfx[sprite - 0xE1]
;>@p5     mem[gfx - 2] = 1                  # graphics source: the party
;>@p6     return tiles
	ld b, $20
	cp $e1
	jr z, .party
	ld b, $30
	cp $e2
	jr z, .party
;=@p1
	ld b, $40
	cp $e3
	jr z, .party
;> if sprite >= 0xF0:                 # a monster of the encounter
	cp $f0
	jr c, .person
;>@en     enc = wEncGfx + (sprite & 3) * 2
	and $03
	add a
	ld hl, wEncGfx
	add l
	ld l, a
	ld a, $00
;=@en
	adc h
	ld h, a
;>@sr     mem[gfx - 2] = mem[enc + 1]      # the graphics source
	inc hl
	dec de
	dec de
	ld a, [hld]
	ld [de], a
	inc de
;=@sr
	inc de
	ld b, a
;>     mem[gfx] = mem[enc]
	ld a, [hl]
	ld [de], a
;>     if mem[enc] == 0xFF:               # no monster there
	cp $ff
	jr nz, .monster
;>@rm         mem[gfx - 0x10] = 0xFF        # remove the actor
	push de
	ld a, e
	sub $10
	ld e, a
	ld a, d
	sbc $00
;=@rm
	ld d, a
	ld a, $ff
	ld [de], a
;>         mem[gfx - 0x12] = 0
	dec de
	dec de
	ld a, $00
	ld [de], a
;>         return 0
	pop de
	ld a, $00
	ret


.monster
;>     source = mem[enc + 1]
	ld e, b
	jr .search

.person
;> else:
;>     source = 0
	ld e, $00

.search
;> slot = 0                          # number = mem[gfx]
;>@lp for i in range(6):
	ld hl, wActorGfxSlots
	ld b, $06
	ld c, $00
	ld d, a

.slot
;>     if wActorGfxSlots[2 * i] == 0xFF:  # free: load the graphics here
;>@l1         wActorGfxSlots[2 * i] = number
;>@l2         wActorGfxSlots[2 * i + 1] = source
;>@l3         ref = ActorGfx[number] if source == 0 else ActorGfxRefs[number]
;>@l4         DecompressVRAM(hi(ref), lo(ref), 0x8000 + (slot + area) * 0x100)
;>@l5         return ActorGfxTiles(slot)
	ld a, [hl]
	cp $ff
	jr z, .load
;>     if wActorGfxSlots[2 * i] == number and wActorGfxSlots[2 * i + 1] == source:
;>         return ActorGfxTiles(slot)
	cp d
	jr nz, .count
	inc hl
	ld a, [hld]
	cp e
	jp z, ActorGfxTiles

.count
;>@big     if wActorGfxSlots[2 * i] in (0x55, 0x15) and wActorGfxSlots[2 * i + 1] == 0:
	ld a, [hl]
	cp $55
	jr z, .big
	cp $15
	jr nz, .next

.big
;=@big
	inc hl
	ld a, [hld]
	or a
	jr nz, .next
;>         slot += 1                      # these graphics take two slots
	inc c

.next
;>     slot += 1
	inc hl
	inc hl
	inc c
;=@lp
	dec b
	jr nz, .slot
;> return 0x50                        # no free slot
	ld a, $50
	ret


.terry
;=@te
	ld a, $5e
	ld [de], a
;=@tr
	ld a, b
	ret


.party
;=@p1
	sub $e1
	push af
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
;=@p1
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr nz, .follower
;=@p2
	pop af
	push de
	ld a, e
	sub $10
	ld e, a
	ld a, d
;=@p2
	sbc $00
	ld d, a
	ld a, $ff
	ld [de], a
	pop de
;=@p3
	ld a, $00
	ret


.follower
;=@p4
	pop af
	ld hl, wPartyGfx
	add l
	ld l, a
	ld a, $00
	adc h
;=@p4
	ld h, a
	ld a, [hl]
	ld [de], a
;=@p5
	dec de
	dec de
	ld a, $01
	ld [de], a
	inc de
	inc de
;=@p6
	ld a, b
	ret


.load
;=@l1
	ld [hl], d
	inc hl
;=@l2
	ld [hl], e
	push bc
;=@l3
	ld a, e
	or a
	jr nz, .monsterRef
	ld hl, ActorGfx
	ld a, d
	add a
;=@l3
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	jr .decompress

.monsterRef
;=@l3
	ld l, d
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(ActorGfxRefs)
	ld l, a
;=@l3
	ld a, h
	adc HIGH(ActorGfxRefs)
	ld h, a

.decompress
;=@l3
	ld e, [hl]
	inc hl
	ld d, [hl]
;=@l4
	ld a, c
	add $80
	ld h, a
	ld a, [wOnGateFloor]
	or a
	jr z, .notFloor
;=@l4
	ld a, h
	add $07
	ld h, a
	jr .go

.notFloor
;=@l4
	ld a, [wMapId]
	cp $08
	jr z, .go
	cp $45
	jr nz, .other
	ld a, h
;=@l4
	add $02
	ld h, a
	jr .go

.other
;=@l4
	ld a, h
	add $05
	ld h, a

.go
;=@l4
	ld l, $00
	call DecompressVRAM
	pop bc

ActorGfxTiles:
;> if wOnGateFloor:
;>@gt     return slot * 16 + 0x70
	ld a, [wOnGateFloor]
	or a
	jr nz, .floor
;> if wMapId == 0x08:
;>@m8     return slot * 16
	ld a, [wMapId]
	cp $08
	jr z, .map08
;> if wMapId == 0x45:
;>@m45     return slot * 16 + 0x20
	cp $45
	jr z, .map45
;>@r return slot * 16 + 0x50
	ld a, c
	add a
	add a
	add a
	add a
	add $50
;=@r
	ret


.map08
;=@m8
	ld a, c
	add a
	add a
	add a
	add a
	ret


.floor
;=@gt
	ld a, c
	add a
	add a
	add a
	add a
	add $70
;=@gt
	ret


.map45
;=@m45
	ld a, c
	add a
	add a
	add a
	add a
	add $20
;=@m45
	ret


;@ path: field/objects
;@ Graphics references (entry number, bank) of the monster sprites that appear as
;@ actors, by graphics number (used by LoadActorGfx); ends with $FF.
ActorGfxRefs::
	db $00, $2f, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31
	db $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31
	db $01, $2f, $02, $2f, $03, $2f, $04, $2f, $05, $2f, $06, $2f, $07, $2f, $08, $2f
	db $09, $2f, $0a, $2f, $0b, $2f, $0c, $2f, $0d, $2f, $0e, $2f, $0f, $2f, $10, $2f
	db $00, $38, $01, $38, $02, $38, $03, $38, $04, $38, $05, $38, $06, $38, $07, $38
	db $08, $38, $09, $38, $0a, $38, $0b, $38, $0c, $38, $0d, $38, $0e, $38, $0f, $38
	db $10, $38, $11, $38, $12, $38, $13, $38, $14, $38, $15, $38, $16, $38, $17, $38
	db $18, $38, $19, $38, $1a, $38, $1b, $38, $1c, $38, $1d, $38, $1e, $38, $1f, $38
	db $20, $38, $21, $38, $22, $38, $23, $38, $24, $38, $25, $38, $26, $38, $27, $38
	db $28, $38, $29, $38, $2a, $38, $2b, $38, $2c, $38, $2d, $38, $2e, $38, $2f, $38
	db $30, $38, $31, $38, $32, $38, $33, $38, $34, $38, $35, $38, $36, $38, $37, $38
	db $38, $38, $39, $38, $3a, $38, $3b, $38, $3c, $38, $3d, $38, $3e, $38, $3f, $38
	db $40, $38, $41, $38, $42, $38, $43, $38, $44, $38, $45, $38, $46, $38, $47, $38
	db $00, $39, $01, $39, $02, $39, $03, $39, $04, $39, $05, $39, $06, $39, $07, $39
	db $08, $39, $09, $39, $0a, $39, $0b, $39, $0c, $39, $0d, $39, $0e, $39, $0f, $39
	db $10, $39, $11, $39, $12, $39, $13, $39, $14, $39, $15, $39, $16, $39, $17, $39
	db $18, $39, $19, $39, $1a, $39, $1b, $39, $1c, $39, $1d, $39, $1e, $39, $1f, $39
	db $20, $39, $21, $39, $22, $39, $23, $39, $24, $39, $25, $39, $26, $39, $27, $39
	db $28, $39, $29, $39, $2a, $39, $2b, $39, $2c, $39, $2d, $39, $2e, $39, $2f, $39
	db $30, $39, $31, $39, $32, $39, $33, $39, $34, $39, $35, $39, $36, $39, $37, $39
	db $38, $39, $39, $39, $3a, $39, $3b, $39, $3c, $39, $3d, $39, $3e, $39, $3f, $39
	db $40, $39, $41, $39, $42, $39, $43, $39, $44, $39, $45, $39, $46, $39, $47, $39
	db $00, $3a, $01, $3a, $02, $3a, $03, $3a, $04, $3a, $05, $3a, $06, $3a, $07, $3a
	db $08, $3a, $09, $3a, $0a, $3a, $0b, $3a, $0c, $3a, $0d, $3a, $0e, $3a, $0f, $3a
	db $10, $3a, $11, $3a, $12, $3a, $13, $3a, $14, $3a, $15, $3a, $16, $3a, $17, $3a
	db $18, $3a, $19, $3a, $1a, $3a, $1b, $3a, $1c, $3a, $1d, $3a, $1e, $3a, $1f, $3a
	db $20, $3a, $21, $3a, $22, $3a, $23, $3a, $24, $3a, $25, $3a, $26, $3a, $27, $3a
	db $28, $3a, $29, $3a, $2a, $3a, $2b, $3a, $2c, $3a, $2d, $3a, $2e, $3a, $2f, $3a
	db $30, $3a, $31, $3a, $32, $3a, $33, $3a, $34, $3a, $35, $3a, $36, $3a, $ff

;@ path: field/map
;@ The screens of the fixed maps, to the end of the bank. MapScreenTable: one pointer per
;@ map to a list of 16 screen pointers (wMapScreen = row * 4 + column; $FFFF = no screen).
;@ A screen: the address of the story variable that picks its version, then 6 bytes per
;@ version - tilemap reference (entry, bank), object list, warp list. Object records
;@ are 5 bytes (flags, sprite or direction, tile X, tile Y, script; see GetScreenObjects),
;@ warp records 7 bytes (see CheckEdgeWarp); both lists end with $FF.
MapScreenTable::
	db $13
	db $4c, $23, $4e, $5d, $50, $f2, $52, $ae, $55, $3a, $58, $9e, $59, $2b, $5a, $86
	db $5c, $45, $5d, $6a, $5e, $13, $4c, $94, $5e, $c0, $5e, $13, $4c, $4a, $5f, $71
	db $5f, $13, $4c, $db, $5f, $7d, $60, $13, $4c, $13, $4c, $39, $61, $71, $5f, $f8
	db $61, $bb, $62, $e2, $62, $13, $63, $5e, $63, $c5, $63, $f6, $63, $38, $64, $13
	db $4c, $13, $4c, $13, $4c, $a4, $64, $db, $64, $39, $65, $97, $65, $f5, $65, $58
	db $66, $b6, $66, $14, $67, $72, $67, $a9, $67, $07, $68, $65, $68, $ca, $68, $af
	db $6a, $d4, $6a, $12, $6b, $41, $6b, $66, $6b, $c2, $6b, $fb, $6b, $84, $6c, $17
	db $6d, $fa, $6d, $33, $6e, $3e, $6f, $63, $6f, $e3, $6f, $23, $70, $52, $70, $77
	db $70, $e4, $70, $42, $71, $db, $74, $1e, $75, $61, $75, $c9, $75, $f8, $75, $43
	db $76, $72, $76, $a1, $76, $d0, $76, $ff, $76, $2e, $77, $5d, $77, $a9, $77, $dd
	db $77, $fa, $77, $17, $78, $4b, $78, $08, $79, $78, $79, $e8, $79, $58, $7a, $c8
	db $7a, $38, $7b, $a8, $7b, $d9, $7b, $0a, $7c, $45, $7c, $e2, $7c, $dd, $77, $44
	db $71, $4d, $78, $4f, $78, $51, $78, $53, $78, $44, $71, $44, $71, $44, $71, $23
	db $4c, $3d, $4c, $ff, $ff, $ff, $ff, $ff, $ff, $75, $4c, $ff, $ff, $ff, $ff, $2a
	db $d9, $01, $2a, $95, $4c, $fc, $4d, $02, $2a, $95, $4c, $fc, $4d, $03, $2a, $95
	db $4c, $fc, $4d, $04, $2a, $95, $4c, $fc, $4d, $2b, $d9, $05, $2a, $cd, $4c, $fe
	db $4d, $06, $2a, $ec, $4c, $fe, $4d, $06, $2a, $01, $4d, $fe, $4d, $06, $2a, $1b
	db $4d, $fe, $4d, $06, $2a, $2b, $4d, $fe, $4d, $06, $2a, $54, $4d, $fe, $4d, $06
	db $2a, $88, $4d, $fe, $4d, $05, $2a, $64, $4d, $fd, $4d, $06, $2a, $88, $4d, $fe
	db $4d, $2c, $d9, $07, $2a, $a2, $4d, $06, $4e, $07, $2a, $bc, $4d, $06, $4e, $07
	db $2a, $cc, $4d, $06, $4e, $07, $2a, $dc, $4d, $06, $4e, $07, $2a, $ec, $4d, $06
	db $4e, $8f, $ff, $01, $01, $01, $8f, $ff, $02, $01, $02, $8f, $ff, $03, $02, $03
	db $8f, $ff, $04, $02, $04, $8f, $ff, $02, $07, $05, $8f, $ff, $03, $07, $06, $8f
	db $ff, $04, $07, $07, $8f, $ff, $05, $07, $08, $8f, $ff, $06, $07, $13, $01, $10
	db $05, $02, $09, $00, $10, $07, $04, $0a, $ff, $00, $10, $02, $02, $0c, $00, $10
	db $07, $02, $0d, $30, $11, $03, $05, $0e, $60, $00, $06, $08, $0f, $00, $0d, $04
	db $03, $0b, $60, $37, $05, $08, $ff, $ff, $00, $10, $02, $02, $0c, $00, $10, $07
	db $02, $0d, $30, $11, $03, $05, $0e, $20, $00, $06, $06, $0f, $ff, $00, $10, $02
	db $02, $0c, $00, $10, $07, $02, $0d, $30, $11, $03, $05, $0e, $20, $00, $06, $06
	db $0f, $00, $0d, $04, $03, $0b, $ff, $00, $10, $02, $02, $0c, $00, $10, $07, $02
	db $0d, $30, $11, $03, $05, $0e, $ff, $00, $10, $02, $02, $0c, $00, $10, $07, $02
	db $0d, $20, $11, $04, $06, $0e, $60, $00, $06, $06, $ff, $00, $0d, $04, $03, $0b
	db $60, $00, $06, $06, $ff, $40, $e0, $04, $05, $ff, $40, $52, $04, $06, $ff, $ff
	db $00, $10, $02, $02, $0c, $00, $10, $08, $02, $0d, $30, $11, $03, $05, $0e, $ff
	db $00, $10, $02, $02, $0c, $00, $10, $07, $02, $0d, $30, $11, $03, $05, $0e, $60
	db $00, $06, $06, $ff, $00, $0d, $04, $03, $ff, $60, $38, $05, $08, $ff, $40, $10
	db $08, $02, $0d, $ff, $00, $10, $02, $02, $0c, $00, $10, $07, $02, $0d, $30, $11
	db $03, $05, $0e, $60, $00, $06, $06, $0f, $40, $10, $08, $02, $0d, $ff, $30, $0b
	db $02, $05, $10, $10, $0b, $07, $05, $11, $10, $0b, $06, $03, $12, $00, $11, $04
	db $04, $ff, $60, $e0, $04, $07, $ff, $ff, $30, $0b, $02, $05, $10, $10, $0b, $07
	db $05, $11, $10, $0b, $06, $03, $12, $ff, $30, $0b, $02, $05, $10, $10, $0b, $08
	db $05, $11, $10, $0b, $06, $03, $12, $ff, $30, $0b, $01, $04, $10, $10, $0b, $07
	db $05, $11, $10, $0b, $06, $03, $12, $ff, $30, $0b, $01, $04, $10, $10, $0b, $08
	db $05, $11, $10, $0b, $06, $03, $12, $ff, $ff, $ff, $07, $01, $0a, $00, $00, $07
	db $07, $ff, $02, $05, $03, $00, $01, $02, $05, $07, $05, $04, $00, $05, $07, $05
	db $04, $07, $01, $00, $80, $04, $04, $05, $07, $01, $00, $80, $05, $04, $ff, $43
	db $4e, $63, $4e, $ff, $ff, $ff, $ff, $6b, $4e, $85, $4e, $ff, $ff, $ff, $ff, $8d
	db $4e, $a1, $4e, $ff, $ff, $ff, $ff, $a9, $4e, $c3, $4e, $ff, $ff, $ff, $ff, $2d
	db $d9, $09, $2a, $d7, $4e, $be, $4f, $09, $2a, $e2, $4e, $bf, $4f, $09, $2a, $ed
	db $4e, $bf, $4f, $09, $2a, $f8, $4e, $bf, $4f, $09, $2a, $fe, $4e, $be, $4f, $2e
	db $d9, $0a, $2a, $09, $4f, $ce, $4f, $2f, $d9, $0b, $2a, $0f, $4f, $d6, $4f, $0b
	db $2a, $1f, $4f, $d6, $4f, $0b, $2a, $34, $4f, $d6, $4f, $0b, $2a, $3f, $4f, $d6
	db $4f, $30, $d9, $0c, $2a, $4f, $4f, $e5, $4f, $31, $d9, $0d, $2a, $5a, $4f, $e6
	db $4f, $0d, $2a, $6f, $4f, $e6, $4f, $0d, $2a, $84, $4f, $e6, $4f, $32, $d9, $0e
	db $2a, $94, $4f, $f5, $4f, $33, $d9, $0f, $2a, $9f, $4f, $04, $50, $0f, $2a, $a5
	db $4f, $04, $50, $10, $2a, $b0, $4f, $1a, $50, $10, $2a, $9f, $4f, $1a, $50, $34
	db $d9, $11, $2a, $bb, $4f, $30, $50, $12, $2a, $bc, $4f, $38, $50, $13, $2a, $bd
	db $4f, $47, $50, $20, $08, $02, $06, $ff, $10, $05, $06, $05, $02, $ff, $00, $08
	db $02, $06, $01, $00, $05, $06, $05, $02, $ff, $90, $ff, $06, $06, $12, $00, $05
	db $06, $05, $02, $ff, $90, $ff, $06, $06, $12, $ff, $90, $ff, $06, $06, $12, $20
	db $08, $02, $06, $ff, $ff, $30, $03, $05, $02, $03, $ff, $20, $08, $02, $06, $ff
	db $00, $03, $07, $03, $04, $40, $0b, $04, $03, $ff, $ff, $90, $ff, $06, $06, $13
	db $00, $03, $07, $03, $04, $00, $05, $06, $05, $05, $00, $08, $02, $06, $06, $ff
	db $90, $ff, $06, $06, $13, $00, $03, $07, $03, $04, $ff, $90, $ff, $06, $06, $13
	db $00, $03, $07, $03, $04, $00, $0b, $03, $05, $07, $ff, $00, $0b, $03, $02, $08
	db $30, $0f, $06, $01, $09, $ff, $90, $ff, $06, $07, $14, $20, $08, $02, $06, $ff
	db $17, $01, $03, $06, $0a, $00, $09, $08, $03, $0b, $ff, $90, $ff, $06, $07, $14
	db $00, $09, $08, $03, $0b, $07, $01, $02, $07, $0a, $00, $05, $06, $06, $0c, $ff
	db $90, $ff, $06, $07, $14, $00, $09, $08, $03, $0b, $10, $04, $03, $06, $0d, $ff
	db $00, $02, $04, $02, $0e, $10, $00, $07, $04, $0f, $ff, $20, $08, $04, $05, $ff
	db $ff, $07, $01, $01, $06, $10, $00, $05, $07, $05, $11, $ff, $07, $01, $01, $06
	db $10, $00, $05, $07, $05, $11, $ff, $ff, $ff, $ff, $ff, $04, $04, $00, $00, $05
	db $04, $07, $05, $04, $00, $00, $05, $05, $07, $ff, $03, $02, $16, $00, $00, $03
	db $07, $ff, $04, $03, $06, $00, $01, $04, $07, $05, $03, $06, $00, $01, $05, $07
	db $ff, $ff, $05, $03, $12, $00, $04, $05, $07, $04, $05, $18, $00, $00, $04, $00
	db $ff, $05, $01, $0f, $00, $00, $05, $07, $09, $03, $02, $00, $00, $00, $03, $ff
	db $04, $06, $09, $00, $04, $04, $06, $05, $01, $0d, $00, $00, $05, $07, $04, $04
	db $10, $00, $00, $04, $07, $ff, $04, $06, $09, $00, $04, $04, $06, $05, $01, $0d
	db $00, $00, $05, $07, $04, $04, $10, $00, $00, $04, $07, $ff, $02, $01, $0c, $00
	db $00, $02, $07, $ff, $02, $01, $0c, $00, $00, $02, $07, $01, $04, $19, $00, $00
	db $01, $07, $ff, $02, $01, $0c, $00, $00, $02, $07, $01, $04, $19, $00, $00, $01
	db $07, $04, $06, $1a, $00, $00, $04, $07, $ff, $6d, $50, $7b, $50, $8f, $50, $ff
	db $ff, $a3, $50, $b7, $50, $cb, $50, $ff, $ff, $35, $d9, $15, $2a, $03, $51, $c3
	db $52, $15, $2a, $1d, $51, $c3, $52, $36, $d9, $16, $2a, $3c, $51, $cb, $52, $16
	db $2a, $4c, $51, $cb, $52, $16, $2a, $61, $51, $cb, $52, $37, $d9, $17, $2a, $76
	db $51, $cc, $52, $18, $2a, $7c, $51, $cd, $52, $18, $2a, $8c, $51, $cd, $52, $38
	db $d9, $19, $2a, $a1, $51, $ce, $52, $1a, $2a, $ac, $51, $cf, $52, $19, $2a, $b7
	db $51, $ce, $52, $39, $d9, $1b, $2a, $c2, $51, $d0, $52, $1c, $2a, $c8, $51, $d1
	db $52, $1c, $2a, $dd, $51, $d1, $52, $3a, $d9, $1d, $2a, $f7, $51, $d2, $52, $1e
	db $2a, $11, $52, $d3, $52, $1e, $2a, $2b, $52, $d3, $52, $1f, $2a, $40, $52, $db
	db $52, $1f, $2a, $5a, $52, $db, $52, $20, $2a, $6f, $52, $e3, $52, $20, $2a, $89
	db $52, $e3, $52, $20, $2a, $9e, $52, $e3, $52, $20, $2a, $b3, $52, $e3, $52, $8f
	db $ff, $06, $02, $01, $8f, $ff, $08, $02, $02, $8f, $ff, $08, $01, $03, $00, $06
	db $07, $02, $04, $00, $03, $03, $04, $05, $ff, $8f, $ff, $06, $02, $01, $8f, $ff
	db $08, $02, $02, $8f, $ff, $08, $01, $03, $00, $06, $07, $02, $04, $00, $03, $03
	db $04, $05, $30, $04, $04, $05, $06, $ff, $00, $04, $04, $04, $07, $20, $04, $04
	db $05, $08, $50, $39, $0a, $04, $ff, $ff, $00, $04, $04, $04, $07, $20, $04, $04
	db $05, $08, $50, $39, $0a, $04, $ff, $00, $00, $03, $02, $09, $ff, $00, $04, $04
	db $04, $07, $20, $04, $04, $05, $08, $50, $39, $0a, $04, $ff, $02, $00, $04, $02
	db $09, $ff, $30, $0f, $01, $04, $0a, $ff, $8f, $ff, $06, $03, $0b, $32, $0f, $02
	db $04, $0a, $10, $06, $07, $03, $0c, $ff, $8f, $ff, $06, $03, $0b, $32, $0f, $02
	db $04, $0a, $10, $06, $07, $03, $0c, $00, $12, $04, $06, $0d, $ff, $30, $06, $03
	db $03, $0e, $00, $0a, $08, $01, $0f, $ff, $30, $06, $03, $03, $0e, $00, $0a, $08
	db $01, $0f, $ff, $30, $06, $03, $03, $0e, $00, $0a, $08, $01, $0f, $ff, $10, $05
	db $08, $02, $10, $ff, $8f, $ff, $04, $03, $11, $8f, $ff, $06, $03, $12, $20, $06
	db $05, $03, $13, $10, $05, $08, $02, $10, $ff, $8f, $ff, $04, $03, $11, $8f, $ff
	db $06, $03, $12, $20, $06, $05, $03, $13, $10, $05, $08, $02, $10, $00, $03, $02
	db $01, $14, $ff, $8f, $ff, $03, $01, $15, $17, $0a, $04, $01, $16, $27, $0a, $03
	db $02, $17, $00, $07, $04, $03, $18, $00, $4d, $07, $04, $ff, $ff, $17, $0a, $04
	db $01, $16, $27, $0a, $03, $02, $17, $00, $07, $04, $03, $18, $00, $4d, $03, $01
	db $ff, $00, $4d, $07, $04, $ff, $ff, $17, $0a, $04, $01, $16, $27, $0a, $03, $02
	db $17, $00, $07, $04, $03, $18, $00, $4d, $07, $04, $ff, $ff, $8f, $ff, $07, $04
	db $15, $07, $0a, $07, $03, $16, $37, $0a, $06, $04, $17, $00, $07, $04, $02, $18
	db $00, $4d, $03, $01, $ff, $ff, $8f, $ff, $07, $04, $15, $07, $0a, $07, $03, $16
	db $37, $0a, $06, $04, $17, $00, $07, $04, $02, $18, $ff, $07, $0a, $07, $03, $16
	db $37, $0a, $06, $04, $17, $20, $07, $04, $02, $18, $00, $4d, $03, $01, $ff, $00
	db $4d, $07, $04, $ff, $ff, $07, $0a, $07, $03, $16, $37, $0a, $06, $04, $17, $20
	db $07, $04, $02, $18, $00, $4d, $07, $04, $ff, $ff, $07, $0a, $07, $03, $16, $37
	db $0a, $06, $04, $17, $20, $07, $04, $02, $18, $00, $4d, $03, $01, $ff, $ff, $07
	db $0a, $07, $03, $16, $37, $0a, $06, $04, $17, $20, $07, $04, $02, $18, $ff, $00
	db $03, $01, $00, $09, $09, $03, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $03
	db $01, $05, $01, $00, $00, $00, $ff, $03, $01, $05, $01, $00, $00, $00, $ff, $03
	db $01, $05, $01, $00, $00, $00, $07, $04, $1c, $01, $00, $00, $00, $ff, $02, $53
	db $1c, $53, $ff, $ff, $ff, $ff, $3c, $53, $5c, $53, $ff, $ff, $ff, $ff, $3b, $d9
	db $22, $2a, $6a, $53, $88, $54, $23, $2a, $84, $53, $90, $54, $24, $2a, $99, $53
	db $9f, $54, $25, $2a, $a4, $53, $bc, $54, $3c, $d9, $26, $2a, $aa, $53, $e0, $54
	db $27, $2a, $ce, $53, $e8, $54, $27, $2a, $e8, $53, $e8, $54, $28, $2a, $f8, $53
	db $fe, $54, $29, $2a, $03, $54, $1b, $55, $3d, $d9, $2a, $2a, $09, $54, $3f, $55
	db $2b, $2a, $28, $54, $47, $55, $2c, $2a, $42, $54, $56, $55, $2d, $2a, $57, $54
	db $6c, $55, $2d, $2a, $62, $54, $6c, $55, $3e, $d9, $2e, $2a, $68, $54, $90, $55
	db $00, $29, $82, $54, $91, $55, $8f, $ff, $04, $01, $01, $8f, $ff, $05, $01, $01
	db $8f, $ff, $02, $02, $02, $8f, $ff, $07, $02, $03, $20, $0b, $03, $05, $04, $ff
	db $8f, $ff, $04, $01, $01, $8f, $ff, $05, $01, $01, $8f, $ff, $02, $02, $02, $20
	db $0b, $03, $05, $04, $ff, $8f, $ff, $02, $02, $02, $20, $0b, $03, $05, $04, $ff
	db $20, $0b, $03, $05, $04, $ff, $8f, $ff, $04, $01, $05, $8f, $ff, $05, $01, $05
	db $8f, $ff, $02, $02, $06, $8f, $ff, $07, $02, $07, $30, $0b, $00, $04, $08, $30
	db $0b, $00, $05, $09, $20, $0b, $04, $06, $0a, $ff, $8f, $ff, $02, $02, $06, $8f
	db $ff, $07, $02, $07, $30, $0b, $00, $04, $08, $30, $0b, $00, $05, $09, $20, $0b
	db $04, $06, $0a, $ff, $8f, $ff, $02, $02, $06, $8f, $ff, $07, $02, $07, $22, $0b
	db $05, $05, $0a, $ff, $8f, $ff, $07, $02, $07, $22, $0b, $05, $05, $0a, $ff, $22
	db $0b, $05, $05, $0a, $ff, $8f, $ff, $04, $01, $0b, $8f, $ff, $05, $01, $0b, $8f
	db $ff, $02, $02, $0c, $8f, $ff, $07, $02, $0d, $10, $0b, $09, $04, $0e, $10, $0b
	db $09, $05, $0f, $ff, $8f, $ff, $04, $01, $0b, $8f, $ff, $05, $01, $0b, $8f, $ff
	db $02, $02, $0c, $10, $0b, $09, $04, $0e, $10, $0b, $09, $05, $0f, $ff, $8f, $ff
	db $04, $01, $0b, $8f, $ff, $05, $01, $0b, $10, $0b, $09, $04, $0e, $10, $0b, $09
	db $05, $0f, $ff, $10, $0b, $09, $04, $0e, $10, $0b, $09, $05, $0f, $ff, $00, $0b
	db $03, $04, $0e, $ff, $8f, $ff, $04, $01, $10, $8f, $ff, $05, $01, $10, $8f, $ff
	db $02, $02, $11, $8f, $ff, $07, $02, $12, $20, $0b, $04, $06, $13, $ff, $20, $0b
	db $04, $06, $13, $ff, $07, $05, $03, $00, $04, $07, $05, $ff, $07, $05, $03, $00
	db $04, $07, $05, $07, $02, $26, $00, $00, $08, $07, $ff, $07, $05, $03, $00, $04
	db $07, $05, $07, $02, $26, $00, $00, $08, $07, $04, $01, $27, $00, $00, $04, $07
	db $05, $01, $27, $00, $00, $05, $07, $ff, $07, $05, $03, $00, $04, $07, $05, $07
	db $02, $26, $00, $00, $08, $07, $04, $01, $27, $00, $00, $04, $07, $05, $01, $27
	db $00, $00, $05, $07, $02, $02, $28, $00, $00, $04, $07, $ff, $02, $05, $00, $00
	db $05, $02, $05, $ff, $02, $05, $00, $00, $05, $02, $05, $04, $01, $23, $00, $00
	db $07, $07, $05, $01, $23, $00, $00, $08, $07, $ff, $02, $05, $00, $00, $05, $02
	db $05, $04, $01, $23, $00, $00, $07, $07, $05, $01, $23, $00, $00, $08, $07, $02
	db $02, $24, $00, $00, $06, $07, $ff, $02, $05, $00, $00, $05, $02, $05, $04, $01
	db $23, $00, $00, $07, $07, $05, $01, $23, $00, $00, $08, $07, $02, $02, $24, $00
	db $00, $06, $07, $07, $02, $25, $00, $00, $01, $07, $ff, $07, $05, $03, $00, $00
	db $07, $05, $ff, $07, $05, $03, $00, $00, $07, $05, $07, $02, $29, $00, $00, $04
	db $07, $ff, $07, $05, $03, $00, $00, $07, $05, $07, $02, $29, $00, $00, $04, $07
	db $02, $02, $2a, $00, $00, $04, $07, $ff, $07, $05, $03, $00, $00, $07, $05, $07
	db $02, $29, $00, $00, $04, $07, $02, $02, $2a, $00, $00, $04, $07, $04, $01, $2b
	db $00, $00, $07, $07, $05, $01, $2b, $00, $00, $08, $07, $ff, $ff, $02, $02, $2c
	db $00, $00, $08, $07, $07, $02, $2d, $00, $00, $02, $07, $04, $01, $2e, $00, $00
	db $06, $07, $05, $01, $2e, $00, $00, $07, $07, $ff, $be, $55, $d8, $55, $ec, $55
	db $ff, $ff, $0c, $56, $26, $56, $3a, $56, $ff, $ff, $3f, $d9, $02, $29, $54, $56
	db $1e, $58, $02, $29, $55, $56, $1e, $58, $02, $29, $6a, $56, $1e, $58, $02, $29
	db $7f, $56, $1e, $58, $40, $d9, $03, $29, $8f, $56, $1f, $58, $03, $29, $9f, $56
	db $1f, $58, $03, $29, $b4, $56, $1f, $58, $41, $d9, $04, $29, $d3, $56, $20, $58
	db $04, $29, $e8, $56, $20, $58, $05, $29, $02, $57, $21, $58, $05, $29, $26, $57
	db $21, $58, $05, $29, $45, $57, $21, $58, $42, $d9, $06, $29, $6e, $57, $29, $58
	db $06, $29, $7e, $57, $29, $58, $06, $29, $8e, $57, $29, $58, $06, $29, $9e, $57
	db $29, $58, $43, $d9, $07, $29, $b3, $57, $31, $58, $07, $29, $c3, $57, $31, $58
	db $07, $29, $d3, $57, $31, $58, $44, $d9, $08, $29, $ed, $57, $39, $58, $08, $29
	db $ee, $57, $39, $58, $08, $29, $f4, $57, $39, $58, $08, $29, $ff, $57, $39, $58
	db $ff, $90, $ff, $06, $05, $02, $02, $18, $04, $01, $ff, $10, $20, $04, $06, $01
	db $40, $53, $06, $01, $ff, $ff, $90, $ff, $06, $05, $02, $02, $1b, $04, $01, $ff
	db $00, $2c, $04, $06, $03, $40, $53, $06, $01, $ff, $ff, $02, $1b, $04, $01, $ff
	db $30, $0c, $04, $06, $04, $30, $02, $06, $05, $05, $ff, $90, $ff, $05, $02, $06
	db $8f, $ff, $04, $01, $07, $00, $19, $06, $02, $08, $ff, $90, $ff, $05, $02, $06
	db $8f, $ff, $04, $01, $07, $00, $19, $06, $02, $08, $00, $19, $03, $04, $09, $ff
	db $00, $0d, $05, $02, $0a, $00, $0e, $04, $02, $0b, $00, $10, $02, $03, $0c, $00
	db $10, $01, $04, $0d, $00, $10, $07, $03, $0e, $00, $10, $08, $04, $0f, $ff, $8f
	db $ff, $04, $05, $10, $26, $1d, $05, $06, $11, $06, $1c, $05, $03, $12, $00, $4d
	db $08, $02, $ff, $ff, $90, $ff, $05, $05, $29, $8f, $ff, $04, $05, $10, $37, $1d
	db $01, $04, $11, $06, $1c, $05, $03, $12, $00, $4d, $08, $02, $ff, $ff, $90, $ff
	db $05, $04, $29, $90, $ff, $05, $05, $29, $90, $ff, $07, $04, $2a, $90, $ff, $07
	db $05, $2a, $37, $1d, $04, $02, $11, $16, $1c, $05, $02, $12, $00, $4d, $08, $02
	db $ff, $ff, $90, $ff, $05, $04, $29, $90, $ff, $05, $05, $29, $90, $ff, $07, $04
	db $2a, $90, $ff, $07, $05, $2a, $37, $1d, $04, $02, $11, $16, $1c, $05, $02, $12
	db $ff, $90, $ff, $05, $04, $29, $90, $ff, $05, $05, $29, $90, $ff, $07, $04, $2a
	db $90, $ff, $07, $05, $2a, $36, $1d, $04, $02, $11, $16, $1c, $05, $02, $12, $10
	db $08, $04, $05, $13, $10, $0f, $05, $06, $14, $ff, $8f, $ff, $02, $01, $15, $17
	db $05, $02, $02, $16, $00, $3f, $06, $04, $17, $ff, $8f, $ff, $02, $01, $15, $17
	db $05, $02, $02, $16, $00, $3f, $05, $04, $17, $ff, $8f, $ff, $02, $01, $15, $17
	db $05, $02, $02, $16, $00, $1a, $05, $04, $18, $ff, $8f, $ff, $02, $01, $15, $17
	db $05, $02, $02, $16, $00, $1a, $06, $04, $18, $03, $00, $06, $01, $19, $ff, $00
	db $00, $05, $03, $1a, $00, $3a, $05, $02, $1b, $30, $44, $04, $06, $1c, $ff, $00
	db $00, $05, $03, $1a, $00, $3a, $05, $02, $1b, $30, $45, $04, $06, $1d, $ff, $00
	db $00, $05, $03, $1a, $00, $3a, $05, $02, $1b, $32, $01, $04, $05, $1e, $00, $11
	db $07, $05, $1f, $33, $0b, $02, $02, $20, $ff, $ff, $00, $46, $03, $03, $21, $ff
	db $02, $47, $02, $01, $22, $00, $48, $03, $03, $23, $ff, $10, $12, $05, $01, $24
	db $10, $12, $05, $02, $25, $10, $12, $05, $03, $26, $01, $04, $01, $02, $27, $00
	db $0f, $02, $05, $28, $40, $54, $05, $00, $ff, $ff, $ff, $ff, $ff, $08, $02, $0b
	db $01, $00, $00, $00, $ff, $06, $04, $05, $00, $02, $06, $04, $ff, $07, $05, $00
	db $00, $05, $07, $05, $ff, $ff, $40, $58, $4e, $58, $5c, $58, $45, $d9, $0a, $29
	db $76, $58, $69, $59, $0b, $29, $86, $58, $78, $59, $46, $d9, $0c, $29, $aa, $58
	db $87, $59, $0c, $29, $bf, $58, $87, $59, $47, $d9, $0d, $29, $e3, $58, $96, $59
	db $0d, $29, $07, $59, $96, $59, $0d, $29, $26, $59, $96, $59, $0d, $29, $4a, $59
	db $96, $59, $01, $3b, $02, $02, $01, $36, $3a, $04, $06, $02, $00, $3a, $05, $06
	db $03, $ff, $8f, $ff, $04, $03, $04, $8f, $ff, $05, $03, $04, $8f, $ff, $04, $04
	db $04, $8f, $ff, $05, $04, $04, $01, $1b, $02, $02, $05, $06, $2a, $04, $06, $06
	db $00, $16, $05, $06, $07, $ff, $8f, $ff, $04, $02, $ff, $8f, $ff, $05, $02, $ff
	db $8f, $ff, $04, $03, $08, $8f, $ff, $05, $03, $08, $ff, $8f, $ff, $04, $02, $ff
	db $8f, $ff, $05, $02, $ff, $8f, $ff, $04, $03, $08, $8f, $ff, $05, $03, $08, $00
	db $49, $01, $01, $09, $10, $4a, $08, $03, $0a, $20, $4b, $03, $06, $0b, $ff, $8f
	db $ff, $04, $03, $0c, $8f, $ff, $05, $03, $0d, $8f, $ff, $07, $00, $0e, $8f, $ff
	db $08, $00, $0f, $06, $25, $02, $01, $11, $00, $3e, $08, $02, $12, $37, $21, $03
	db $03, $10, $ff, $8f, $ff, $04, $03, $0c, $8f, $ff, $05, $03, $0d, $8f, $ff, $07
	db $00, $0e, $8f, $ff, $08, $00, $0f, $06, $25, $02, $01, $11, $00, $3e, $08, $02
	db $12, $ff, $8f, $ff, $04, $03, $0c, $8f, $ff, $05, $03, $0d, $8f, $ff, $07, $00
	db $0e, $8f, $ff, $08, $00, $0f, $06, $25, $02, $01, $11, $00, $3d, $08, $02, $14
	db $37, $39, $03, $03, $13, $ff, $8f, $ff, $04, $03, $0c, $8f, $ff, $05, $03, $0d
	db $8f, $ff, $07, $00, $0e, $8f, $ff, $08, $00, $0f, $06, $25, $02, $01, $11, $00
	db $3d, $08, $02, $14, $ff, $04, $00, $1b, $00, $00, $04, $07, $05, $00, $1b, $00
	db $00, $05, $07, $ff, $04, $00, $1b, $00, $00, $04, $07, $05, $00, $1b, $00, $00
	db $05, $07, $ff, $04, $00, $1c, $00, $00, $04, $07, $05, $00, $1c, $00, $00, $05
	db $07, $ff, $06, $04, $04, $00, $04, $06, $04, $ff, $a6, $59, $ae, $59, $b6, $59
	db $ff, $ff, $48, $d9, $0f, $29, $be, $59, $0c, $5a, $49, $d9, $10, $29, $d8, $59
	db $14, $5a, $4a, $d9, $11, $29, $01, $5a, $23, $5a, $90, $ff, $05, $04, $01, $50
	db $e0, $05, $04, $ff, $70, $e1, $03, $05, $02, $40, $e2, $02, $04, $03, $50, $e3
	db $03, $03, $04, $ff, $8f, $ff, $04, $02, $05, $8f, $ff, $05, $02, $05, $8f, $ff
	db $03, $04, $06, $8f, $ff, $06, $06, $07, $37, $12, $02, $04, $08, $17, $12, $07
	db $06, $09, $60, $11, $04, $08, $0e, $40, $54, $06, $05, $ff, $ff, $82, $ff, $06
	db $05, $0a, $00, $0b, $06, $04, $0b, $ff, $05, $00, $07, $00, $04, $05, $07, $ff
	db $04, $07, $01, $00, $84, $04, $03, $05, $07, $01, $00, $84, $05, $03, $ff, $04
	db $00, $07, $00, $06, $04, $07, $ff, $3b, $5a, $43, $5a, $75, $5a, $ff, $ff, $7d
	db $5a, $8b, $5a, $93, $5a, $ff, $ff, $4b, $d9, $13, $29, $9b, $5a, $29, $5c, $4c
	db $d9, $14, $29, $b5, $5a, $31, $5c, $15, $29, $b5, $5a, $32, $5c, $16, $29, $d4
	db $5a, $3a, $5c, $16, $29, $f8, $5a, $3a, $5c, $17, $29, $17, $5b, $49, $5c, $17
	db $29, $40, $5b, $49, $5c, $17, $29, $64, $5b, $49, $5c, $17, $29, $88, $5b, $49
	db $5c, $4d, $d9, $18, $29, $a7, $5b, $5f, $5c, $4e, $d9, $19, $29, $c1, $5b, $67
	db $5c, $19, $29, $d1, $5b, $67, $5c, $4f, $d9, $1a, $29, $e1, $5b, $6f, $5c, $50
	db $d9, $1b, $29, $f1, $5b, $7e, $5c, $82, $ff, $03, $04, $01, $00, $41, $08, $03
	db $02, $40, $52, $03, $04, $ff, $40, $e0, $03, $04, $ff, $00, $11, $04, $02, $1a
	db $ff, $90, $ff, $03, $05, $03, $90, $ff, $04, $05, $04, $90, $ff, $05, $05, $05
	db $06, $1f, $04, $02, $06, $00, $08, $03, $06, $07, $00, $08, $07, $05, $08, $ff
	db $90, $ff, $03, $05, $03, $90, $ff, $04, $05, $04, $90, $ff, $05, $05, $05, $06
	db $1f, $04, $02, $06, $00, $08, $03, $06, $07, $00, $08, $07, $05, $08, $00, $4d
	db $02, $04, $ff, $ff, $90, $ff, $03, $05, $03, $90, $ff, $04, $05, $04, $90, $ff
	db $05, $05, $05, $06, $1f, $04, $02, $06, $00, $08, $03, $06, $07, $00, $08, $07
	db $05, $08, $ff, $90, $ff, $03, $05, $03, $90, $ff, $04, $05, $04, $90, $ff, $05
	db $05, $05, $06, $1f, $04, $02, $06, $00, $08, $03, $06, $07, $00, $08, $07, $05
	db $08, $00, $4d, $02, $04, $ff, $00, $4d, $06, $04, $ff, $ff, $90, $ff, $03, $05
	db $03, $90, $ff, $04, $05, $04, $90, $ff, $05, $05, $05, $06, $1f, $04, $02, $06
	db $00, $08, $03, $06, $07, $00, $08, $07, $05, $08, $00, $4d, $06, $04, $ff, $ff
	db $90, $ff, $03, $05, $03, $90, $ff, $04, $05, $04, $90, $ff, $05, $05, $05, $06
	db $1f, $04, $02, $06, $00, $08, $03, $06, $07, $00, $08, $07, $05, $08, $00, $4d
	db $02, $04, $ff, $ff, $90, $ff, $03, $05, $03, $90, $ff, $04, $05, $04, $90, $ff
	db $05, $05, $05, $06, $1f, $04, $02, $06, $00, $08, $03, $06, $07, $00, $08, $07
	db $05, $08, $ff, $8f, $ff, $01, $02, $09, $8f, $ff, $02, $02, $0a, $00, $04, $03
	db $04, $0b, $00, $0b, $06, $02, $0c, $17, $0a, $08, $05, $0d, $ff, $07, $09, $02
	db $01, $0e, $04, $42, $08, $05, $0f, $30, $0a, $01, $06, $10, $ff, $04, $09, $08
	db $05, $0e, $06, $42, $02, $01, $0f, $30, $0a, $01, $06, $10, $ff, $00, $0b, $05
	db $01, $11, $20, $0f, $05, $02, $12, $22, $17, $04, $05, $ff, $ff, $8f, $ff, $08
	db $03, $13, $8f, $ff, $07, $04, $14, $8f, $ff, $06, $05, $15, $8f, $ff, $06, $06
	db $16, $06, $0a, $03, $02, $17, $26, $20, $03, $03, $18, $30, $0b, $02, $06, $19
	db $40, $e0, $05, $00, $ff, $40, $e1, $05, $00, $ff, $40, $e2, $05, $00, $ff, $40
	db $e3, $05, $00, $ff, $ff, $05, $01, $1d, $00, $00, $05, $07, $ff, $ff, $05, $02
	db $1f, $00, $00, $05, $02, $ff, $05, $02, $1f, $00, $00, $05, $02, $02, $04, $0e
	db $01, $00, $00, $00, $ff, $05, $02, $1f, $00, $00, $05, $02, $02, $04, $0e, $01
	db $00, $00, $00, $06, $04, $1d, $01, $00, $00, $00, $ff, $05, $01, $1e, $00, $00
	db $05, $07, $ff, $05, $07, $06, $00, $00, $05, $00, $ff, $04, $07, $06, $00, $01
	db $04, $03, $05, $07, $06, $00, $01, $05, $03, $ff, $04, $07, $06, $00, $02, $04
	db $00, $ff, $88, $5c, $51, $d9, $1e, $29, $c0, $5c, $ff, $ff, $1e, $29, $d0, $5c
	db $ff, $ff, $1e, $29, $e0, $5c, $ff, $ff, $1e, $29, $e0, $5c, $ff, $ff, $1e, $29
	db $f0, $5c, $ff, $ff, $1e, $29, $00, $5d, $ff, $ff, $1e, $29, $10, $5d, $ff, $ff
	db $1e, $29, $1b, $5d, $ff, $ff, $1e, $29, $30, $5d, $ff, $ff, $20, $08, $05, $08
	db $ff, $40, $f0, $05, $04, $ff, $40, $f1, $05, $04, $ff, $ff, $20, $08, $05, $08
	db $ff, $00, $55, $05, $04, $ff, $00, $55, $05, $04, $ff, $ff, $20, $08, $05, $08
	db $ff, $40, $f0, $05, $04, $ff, $40, $55, $05, $04, $ff, $ff, $20, $08, $05, $08
	db $ff, $40, $f0, $05, $04, $ff, $40, $f1, $05, $04, $ff, $ff, $20, $08, $05, $08
	db $ff, $00, $55, $05, $04, $ff, $00, $55, $05, $04, $ff, $ff, $60, $08, $05, $08
	db $ff, $20, $5e, $05, $04, $ff, $ff, $60, $08, $05, $08, $ff, $70, $21, $00, $04
	db $ff, $40, $55, $05, $04, $ff, $20, $5e, $05, $07, $ff, $ff, $20, $08, $05, $07
	db $ff, $40, $21, $05, $04, $ff, $40, $55, $05, $04, $ff, $20, $5e, $05, $06, $ff
	db $ff, $ff, $ff, $55, $5d, $ff, $ff, $ff, $ff, $69, $5d, $7d, $5d, $ff, $ff, $ff
	db $ff, $52, $d9, $20, $29, $8b, $5d, $5f, $5e, $20, $29, $be, $5d, $5f, $5e, $20
	db $29, $f6, $5d, $5f, $5e, $53, $d9, $21, $29, $29, $5e, $60, $5e, $21, $29, $2f
	db $5e, $60, $5e, $21, $29, $29, $5e, $68, $5e, $54, $d9, $22, $29, $30, $5e, $69
	db $5e, $22, $29, $4a, $5e, $69, $5e, $8f, $ff, $05, $00, $01, $8f, $ff, $07, $00
	db $02, $8f, $ff, $08, $00, $03, $00, $26, $02, $01, $04, $00, $08, $05, $01, $05
	db $00, $0f, $06, $04, $06, $40, $e0, $05, $00, $ff, $40, $e1, $05, $00, $ff, $40
	db $e2, $05, $00, $ff, $40, $e3, $05, $00, $ff, $ff, $8f, $ff, $05, $00, $01, $8f
	db $ff, $07, $00, $02, $8f, $ff, $08, $00, $03, $81, $ff, $05, $03, $07, $00, $26
	db $02, $01, $04, $00, $08, $04, $03, $05, $00, $0f, $06, $04, $06, $40, $e0, $07
	db $00, $ff, $40, $e1, $07, $00, $ff, $40, $e2, $07, $00, $ff, $40, $e3, $07, $00
	db $ff, $ff, $8f, $ff, $05, $00, $01, $8f, $ff, $07, $00, $02, $8f, $ff, $08, $00
	db $03, $40, $26, $02, $02, $04, $30, $08, $06, $05, $ff, $40, $e0, $02, $00, $ff
	db $40, $e0, $07, $00, $ff, $40, $e1, $07, $00, $ff, $40, $e2, $07, $00, $ff, $40
	db $e3, $07, $00, $ff, $ff, $10, $08, $08, $06, $ff, $ff, $ff, $90, $ff, $08, $01
	db $0b, $00, $07, $03, $02, $08, $00, $0b, $02, $04, $09, $00, $11, $07, $05, $0a
	db $00, $08, $04, $01, $ff, $ff, $90, $ff, $08, $01, $0b, $00, $07, $03, $02, $08
	db $00, $0b, $02, $04, $09, $00, $11, $07, $05, $0a, $ff, $ff, $04, $06, $01, $00
	db $0c, $04, $06, $ff, $ff, $ff, $72, $5e, $7a, $5e, $ff, $ff, $ff, $ff, $55, $d9
	db $24, $29, $82, $5e, $84, $5e, $56, $d9, $25, $29, $83, $5e, $8c, $5e, $ff, $ff
	db $07, $07, $00, $00, $81, $07, $01, $ff, $03, $07, $16, $00, $80, $03, $01, $ff
	db $96, $5e, $57, $d9, $27, $29, $9e, $5e, $b8, $5e, $8f, $ff, $01, $01, $01, $8f
	db $ff, $02, $01, $02, $8f, $ff, $03, $01, $03, $82, $ff, $02, $04, $04, $00, $0f
	db $02, $03, $05, $ff, $02, $07, $01, $00, $8d, $02, $01, $ff, $c2, $5e, $58, $d9
	db $01, $30, $d0, $5e, $3b, $5f, $01, $30, $08, $5f, $3b, $5f, $90, $ff, $06, $04
	db $08, $90, $ff, $07, $05, $08, $90, $ff, $08, $05, $09, $8f, $ff, $02, $01, $01
	db $8f, $ff, $03, $01, $02, $8f, $ff, $01, $05, $03, $8f, $ff, $01, $06, $04, $00
	db $05, $03, $05, $05, $00, $04, $06, $03, $06, $00, $08, $08, $04, $07, $00, $4d
	db $08, $02, $ff, $ff, $90, $ff, $06, $04, $08, $90, $ff, $07, $05, $08, $90, $ff
	db $08, $05, $09, $8f, $ff, $02, $01, $01, $8f, $ff, $03, $01, $02, $8f, $ff, $01
	db $05, $03, $8f, $ff, $01, $06, $04, $00, $05, $03, $05, $05, $00, $04, $06, $03
	db $06, $00, $08, $08, $04, $07, $ff, $05, $07, $01, $00, $8c, $05, $01, $08, $02
	db $1e, $01, $00, $00, $00, $ff, $4c, $5f, $59, $d9, $03, $30, $54, $5f, $69, $5f
	db $8f, $ff, $05, $03, $01, $8f, $ff, $03, $05, $02, $00, $09, $05, $02, $01, $30
	db $02, $02, $05, $02, $ff, $05, $07, $01, $00, $89, $05, $01, $ff, $73, $5f, $5a
	db $d9, $05, $30, $81, $5f, $c4, $5f, $06, $30, $a5, $5f, $cc, $5f, $8f, $ff, $02
	db $01, $01, $8f, $ff, $03, $01, $02, $8f, $ff, $04, $01, $03, $82, $ff, $05, $04
	db $04, $20, $03, $05, $03, $05, $00, $0a, $04, $06, $06, $50, $21, $0a, $00, $ff
	db $ff, $90, $ff, $07, $06, $07, $90, $ff, $08, $05, $07, $8f, $ff, $02, $01, $01
	db $8f, $ff, $03, $01, $02, $8f, $ff, $04, $01, $03, $00, $0a, $04, $06, $06, $ff
	db $04, $07, $01, $00, $8c, $04, $04, $ff, $04, $07, $01, $00, $8c, $04, $04, $08
	db $06, $00, $00, $01, $04, $05, $ff, $eb, $5f, $ff, $ff, $ff, $ff, $ff, $ff, $f3
	db $5f, $ff, $ff, $ff, $ff, $ff, $ff, $5b, $d9, $08, $30, $01, $60, $6d, $60, $5c
	db $d9, $09, $30, $43, $60, $6e, $60, $09, $30, $5d, $60, $6e, $60, $8f, $ff, $01
	db $01, $01, $8f, $ff, $02, $01, $02, $8f, $ff, $03, $01, $03, $8f, $ff, $04, $01
	db $04, $8f, $ff, $07, $01, $05, $8f, $ff, $08, $01, $06, $8f, $ff, $02, $04, $07
	db $8f, $ff, $03, $04, $08, $8f, $ff, $04, $04, $09, $8f, $ff, $06, $04, $0a, $8f
	db $ff, $07, $04, $0b, $8f, $ff, $06, $01, $0c, $10, $02, $02, $06, $0d, $ff, $82
	db $ff, $04, $03, $0e, $00, $02, $04, $02, $0f, $00, $03, $06, $03, $11, $30, $03
	db $01, $06, $10, $40, $54, $06, $02, $ff, $ff, $82, $ff, $04, $03, $0e, $00, $02
	db $04, $02, $0f, $30, $03, $01, $06, $10, $ff, $ff, $05, $07, $01, $00, $88, $05
	db $03, $06, $01, $13, $00, $00, $06, $07, $ff, $7f, $60, $5d, $d9, $0b, $30, $8d
	db $60, $2a, $61, $0b, $30, $de, $60, $2a, $61, $8f, $ff, $01, $01, $01, $8f, $ff
	db $02, $01, $02, $8f, $ff, $03, $01, $03, $8f, $ff, $04, $01, $04, $8f, $ff, $05
	db $01, $05, $8f, $ff, $06, $01, $06, $8f, $ff, $07, $01, $07, $8f, $ff, $08, $01
	db $08, $8f, $ff, $01, $04, $09, $8f, $ff, $02, $04, $0a, $8f, $ff, $03, $04, $0b
	db $8f, $ff, $04, $04, $0c, $8f, $ff, $07, $04, $0d, $8f, $ff, $08, $04, $0e, $10
	db $03, $06, $04, $0f, $00, $4d, $01, $06, $ff, $ff, $8f, $ff, $01, $01, $01, $8f
	db $ff, $02, $01, $02, $8f, $ff, $03, $01, $03, $8f, $ff, $04, $01, $04, $8f, $ff
	db $05, $01, $05, $8f, $ff, $06, $01, $06, $8f, $ff, $07, $01, $07, $8f, $ff, $08
	db $01, $08, $8f, $ff, $01, $04, $09, $8f, $ff, $02, $04, $0a, $8f, $ff, $03, $04
	db $0b, $8f, $ff, $04, $04, $0c, $8f, $ff, $07, $04, $0d, $8f, $ff, $08, $04, $0e
	db $10, $03, $06, $04, $0f, $ff, $06, $07, $12, $00, $84, $06, $01, $01, $06, $14
	db $01, $00, $00, $00, $ff, $3b, $61, $5e, $d9, $0d, $30, $61, $61, $cb, $61, $0e
	db $30, $71, $61, $d3, $61, $0e, $30, $86, $61, $d3, $61, $0d, $30, $96, $61, $e9
	db $61, $0e, $30, $a6, $61, $d3, $61, $0e, $30, $bb, $61, $d3, $61, $82, $ff, $02
	db $04, $01, $00, $13, $02, $03, $02, $00, $4c, $03, $02, $03, $ff, $82, $ff, $02
	db $04, $01, $00, $13, $02, $03, $02, $00, $4c, $03, $02, $03, $00, $4d, $01, $06
	db $ff, $ff, $82, $ff, $02, $04, $01, $00, $13, $02, $03, $02, $00, $4c, $03, $02
	db $03, $ff, $82, $ff, $02, $04, $01, $00, $13, $02, $03, $02, $00, $4c, $01, $02
	db $03, $ff, $82, $ff, $02, $04, $01, $00, $13, $02, $03, $02, $00, $4c, $01, $02
	db $03, $00, $4d, $01, $06, $ff, $ff, $82, $ff, $02, $04, $01, $00, $13, $02, $03
	db $02, $00, $4c, $01, $02, $03, $ff, $03, $07, $01, $00, $81, $03, $02, $ff, $03
	db $07, $01, $00, $81, $03, $02, $03, $01, $0a, $00, $01, $03, $07, $01, $06, $11
	db $01, $00, $00, $00, $ff, $03, $07, $01, $00, $81, $03, $02, $03, $01, $0a, $00
	db $01, $03, $07, $ff, $08, $62, $ff, $ff, $ff, $ff, $ff, $ff, $10, $62, $ff, $ff
	db $ff, $ff, $ff, $ff, $5f, $d9, $10, $30, $24, $62, $aa, $62, $60, $d9, $11, $30
	db $25, $62, $b2, $62, $12, $30, $5d, $62, $b3, $62, $12, $30, $86, $62, $b3, $62
	db $ff, $8f, $ff, $01, $01, $01, $8f, $ff, $07, $01, $02, $8f, $ff, $08, $01, $03
	db $8f, $ff, $02, $05, $04, $8f, $ff, $03, $05, $04, $8f, $ff, $02, $06, $04, $8f
	db $ff, $03, $06, $04, $8f, $ff, $01, $06, $05, $82, $ff, $06, $04, $06, $07, $43
	db $06, $03, $07, $02, $07, $06, $05, $08, $ff, $8f, $ff, $01, $01, $01, $8f, $ff
	db $07, $01, $02, $8f, $ff, $08, $01, $03, $8f, $ff, $01, $06, $05, $82, $ff, $06
	db $04, $06, $07, $43, $06, $03, $07, $02, $07, $06, $05, $08, $00, $4d, $02, $06
	db $ff, $ff, $8f, $ff, $01, $01, $01, $8f, $ff, $07, $01, $02, $8f, $ff, $08, $01
	db $03, $8f, $ff, $01, $06, $05, $82, $ff, $06, $04, $06, $07, $43, $06, $03, $07
	db $02, $07, $06, $05, $08, $ff, $04, $00, $01, $00, $08, $04, $05, $ff, $ff, $02
	db $06, $08, $01, $00, $00, $00, $ff, $bd, $62, $61, $d9, $14, $30, $c5, $62, $da
	db $62, $90, $ff, $01, $04, $02, $90, $ff, $02, $04, $03, $90, $ff, $03, $04, $04
	db $06, $1f, $02, $02, $01, $ff, $01, $07, $01, $00, $8d, $01, $04, $ff, $e4, $62
	db $62, $d9, $16, $30, $ec, $62, $0b, $63, $90, $ff, $03, $04, $04, $90, $ff, $04
	db $04, $05, $90, $ff, $05, $04, $06, $06, $1f, $04, $02, $01, $00, $11, $05, $05
	db $02, $08, $3b, $02, $06, $03, $ff, $04, $07, $01, $00, $8d, $04, $06, $ff, $15
	db $63, $63, $d9, $18, $30, $29, $63, $4f, $63, $18, $30, $34, $63, $4f, $63, $18
	db $30, $3f, $63, $4f, $63, $00, $22, $04, $02, $01, $00, $ff, $05, $02, $01, $ff
	db $00, $24, $04, $02, $02, $00, $ff, $05, $02, $02, $ff, $00, $3b, $03, $03, $03
	db $00, $24, $04, $02, $02, $00, $ff, $05, $02, $02, $ff, $04, $07, $05, $00, $80
	db $04, $00, $05, $07, $05, $00, $80, $05, $00, $ff, $60, $63, $64, $d9, $1a, $30
	db $6e, $63, $b6, $63, $1a, $30, $92, $63, $b6, $63, $8f, $ff, $04, $02, $01, $8f
	db $ff, $05, $02, $01, $8f, $ff, $01, $04, $02, $8f, $ff, $08, $04, $03, $40, $41
	db $04, $02, $01, $40, $41, $05, $02, $01, $02, $40, $03, $05, $04, $ff, $8f, $ff
	db $04, $02, $05, $8f, $ff, $05, $02, $05, $8f, $ff, $01, $04, $02, $8f, $ff, $08
	db $04, $03, $40, $2b, $04, $02, $05, $40, $2b, $05, $02, $05, $02, $1e, $03, $05
	db $06, $ff, $04, $07, $05, $00, $81, $04, $00, $05, $07, $05, $00, $81, $05, $00
	db $ff, $c7, $63, $65, $d9, $1c, $30, $cf, $63, $ee, $63, $8f, $ff, $04, $01, $01
	db $8f, $ff, $06, $01, $02, $8f, $ff, $05, $03, $03, $07, $11, $05, $02, $04, $27
	db $00, $03, $05, $05, $20, $02, $08, $06, $06, $ff, $05, $07, $07, $00, $80, $05
	db $01, $ff, $f8, $63, $66, $d9, $1e, $30, $06, $64, $30, $64, $1e, $30, $1b, $64
	db $30, $64, $8f, $ff, $05, $03, $01, $00, $05, $05, $02, $01, $37, $0f, $02, $03
	db $02, $20, $0b, $06, $04, $03, $ff, $8f, $ff, $05, $03, $01, $00, $05, $05, $02
	db $01, $37, $0f, $02, $03, $02, $20, $0c, $06, $04, $04, $ff, $05, $07, $07, $00
	db $82, $05, $01, $ff, $3a, $64, $67, $d9, $01, $2d, $4e, $64, $9c, $64, $01, $2d
	db $68, $64, $9c, $64, $01, $2d, $82, $64, $9c, $64, $8f, $ff, $02, $06, $01, $00
	db $0e, $05, $06, $02, $00, $11, $07, $03, $03, $00, $02, $04, $04, $04, $81, $ff
	db $05, $04, $07, $ff, $8f, $ff, $02, $06, $01, $00, $0e, $05, $06, $02, $00, $11
	db $07, $03, $03, $00, $13, $04, $04, $05, $81, $ff, $05, $04, $08, $ff, $8f, $ff
	db $02, $06, $01, $00, $0e, $05, $06, $02, $00, $11, $07, $03, $03, $00, $14, $04
	db $04, $06, $81, $ff, $05, $04, $09, $ff, $05, $02, $07, $00, $01, $05, $02, $ff
	db $a6, $64, $68, $d9, $03, $2d, $b4, $64, $c5, $64, $03, $2d, $bf, $64, $c5, $64
	db $00, $0b, $08, $05, $01, $00, $4d, $08, $02, $ff, $ff, $00, $0b, $08, $05, $01
	db $ff, $07, $07, $03, $00, $81, $04, $01, $08, $07, $03, $00, $81, $05, $01, $08
	db $02, $00, $01, $00, $00, $00, $ff, $dd, $64, $69, $d9, $05, $2d, $f7, $64, $23
	db $65, $05, $2d, $07, $65, $23, $65, $05, $2d, $12, $65, $23, $65, $05, $2d, $1d
	db $65, $23, $65, $10, $0b, $07, $05, $01, $00, $4d, $02, $02, $ff, $00, $4d, $02
	db $06, $ff, $ff, $10, $0b, $07, $05, $01, $00, $4d, $02, $06, $ff, $ff, $10, $0b
	db $07, $05, $01, $00, $4d, $02, $02, $ff, $ff, $10, $0b, $07, $05, $01, $ff, $06
	db $07, $03, $00, $81, $02, $02, $02, $02, $01, $01, $00, $00, $00, $02, $06, $02
	db $01, $00, $00, $00, $ff, $3b, $65, $6a, $d9, $07, $2d, $55, $65, $81, $65, $07
	db $2d, $65, $65, $81, $65, $07, $2d, $70, $65, $81, $65, $07, $2d, $7b, $65, $81
	db $65, $00, $0b, $06, $03, $01, $00, $4d, $05, $01, $ff, $00, $4d, $07, $01, $ff
	db $ff, $00, $0b, $06, $03, $01, $00, $4d, $07, $01, $ff, $ff, $00, $0b, $06, $03
	db $01, $00, $4d, $05, $01, $ff, $ff, $00, $0b, $06, $03, $01, $ff, $01, $07, $03
	db $00, $81, $07, $02, $05, $01, $03, $01, $00, $00, $00, $07, $01, $04, $01, $00
	db $00, $00, $ff, $99, $65, $6b, $d9, $09, $2d, $b3, $65, $df, $65, $09, $2d, $c3
	db $65, $df, $65, $09, $2d, $ce, $65, $df, $65, $09, $2d, $d9, $65, $df, $65, $00
	db $0b, $08, $05, $01, $00, $4d, $03, $03, $ff, $00, $4d, $06, $03, $ff, $ff, $00
	db $0b, $08, $05, $01, $00, $4d, $06, $03, $ff, $ff, $00, $0b, $08, $05, $01, $00
	db $4d, $03, $03, $ff, $ff, $00, $0b, $08, $05, $01, $ff, $08, $07, $03, $00, $80
	db $07, $02, $03, $03, $06, $01, $00, $00, $00, $06, $03, $07, $01, $00, $00, $00
	db $ff, $f7, $65, $6c, $d9, $0b, $2d, $0b, $66, $3b, $66, $0b, $2d, $20, $66, $3b
	db $66, $0b, $2d, $30, $66, $3b, $66, $01, $0b, $02, $04, $01, $01, $0b, $08, $05
	db $02, $00, $4d, $02, $03, $ff, $00, $4d, $07, $03, $ff, $ff, $20, $0b, $01, $06
	db $01, $10, $0b, $08, $05, $02, $00, $4d, $02, $03, $ff, $ff, $20, $0b, $01, $06
	db $01, $10, $0b, $08, $05, $02, $ff, $04, $07, $03, $00, $80, $04, $01, $05, $07
	db $03, $00, $80, $05, $01, $02, $03, $09, $01, $00, $00, $00, $07, $03, $0a, $01
	db $00, $00, $00, $ff, $5a, $66, $6d, $d9, $0d, $2d, $74, $66, $a0, $66, $0d, $2d
	db $84, $66, $a0, $66, $0d, $2d, $8f, $66, $a0, $66, $0d, $2d, $9a, $66, $a0, $66
	db $10, $0b, $06, $06, $01, $00, $4d, $03, $02, $ff, $00, $4d, $05, $02, $ff, $ff
	db $10, $0b, $06, $06, $01, $00, $4d, $03, $02, $ff, $ff, $10, $0b, $06, $06, $01
	db $00, $4d, $05, $02, $ff, $ff, $10, $0b, $06, $06, $01, $ff, $04, $07, $03, $00
	db $80, $02, $02, $03, $02, $0c, $01, $00, $00, $00, $05, $02, $0d, $01, $00, $00
	db $00, $ff, $b8, $66, $6e, $d9, $0f, $2d, $d2, $66, $fe, $66, $0f, $2d, $e2, $66
	db $fe, $66, $0f, $2d, $ed, $66, $fe, $66, $0f, $2d, $f8, $66, $fe, $66, $10, $0b
	db $07, $06, $01, $00, $4d, $03, $02, $ff, $00, $4d, $06, $02, $ff, $ff, $10, $0b
	db $07, $06, $01, $00, $4d, $06, $02, $ff, $ff, $10, $0b, $07, $06, $01, $00, $4d
	db $03, $02, $ff, $ff, $10, $0b, $07, $06, $01, $ff, $04, $07, $03, $00, $84, $07
	db $02, $03, $02, $0f, $01, $00, $00, $00, $06, $02, $10, $01, $00, $00, $00, $ff
	db $16, $67, $6f, $d9, $11, $2d, $30, $67, $5c, $67, $11, $2d, $40, $67, $5c, $67
	db $11, $2d, $4b, $67, $5c, $67, $11, $2d, $56, $67, $5c, $67, $00, $0b, $05, $02
	db $01, $00, $4d, $02, $04, $ff, $00, $4d, $07, $04, $ff, $ff, $00, $0b, $05, $02
	db $01, $00, $4d, $07, $04, $ff, $ff, $00, $0b, $05, $02, $01, $00, $4d, $02, $04
	db $ff, $ff, $00, $0b, $05, $02, $01, $ff, $04, $07, $03, $00, $84, $02, $02, $02
	db $04, $12, $01, $00, $00, $00, $07, $04, $13, $01, $00, $00, $00, $ff, $74, $67
	db $70, $d9, $13, $2d, $82, $67, $93, $67, $13, $2d, $8d, $67, $93, $67, $30, $0b
	db $01, $06, $01, $00, $4d, $03, $02, $ff, $ff, $30, $0b, $01, $06, $01, $ff, $07
	db $07, $03, $00, $84, $04, $01, $08, $07, $03, $00, $84, $05, $01, $03, $02, $15
	db $01, $00, $00, $00, $ff, $ab, $67, $71, $d9, $15, $2d, $c5, $67, $f1, $67, $15
	db $2d, $d5, $67, $f1, $67, $15, $2d, $e0, $67, $f1, $67, $15, $2d, $eb, $67, $f1
	db $67, $30, $0b, $01, $06, $01, $00, $4d, $01, $03, $ff, $00, $4d, $03, $03, $ff
	db $ff, $30, $0b, $01, $06, $01, $00, $4d, $03, $03, $ff, $ff, $30, $0b, $01, $06
	db $01, $00, $4d, $01, $03, $ff, $ff, $30, $0b, $01, $06, $01, $ff, $08, $07, $03
	db $00, $85, $02, $02, $01, $03, $16, $01, $00, $00, $00, $03, $03, $17, $01, $00
	db $00, $00, $ff, $09, $68, $72, $d9, $17, $2d, $23, $68, $4f, $68, $17, $2d, $33
	db $68, $4f, $68, $17, $2d, $3e, $68, $4f, $68, $17, $2d, $49, $68, $4f, $68, $00
	db $0b, $02, $02, $01, $00, $4d, $06, $02, $ff, $00, $4d, $06, $04, $ff, $ff, $00
	db $0b, $02, $02, $01, $00, $4d, $06, $04, $ff, $ff, $00, $0b, $02, $02, $01, $00
	db $4d, $06, $02, $ff, $ff, $00, $0b, $02, $02, $01, $ff, $02, $07, $03, $00, $85
	db $07, $02, $06, $02, $18, $01, $00, $00, $00, $06, $04, $19, $01, $00, $00, $00
	db $ff, $67, $68, $73, $d9, $19, $2d, $81, $68, $ad, $68, $19, $2d, $91, $68, $ad
	db $68, $19, $2d, $9c, $68, $ad, $68, $19, $2d, $a7, $68, $ad, $68, $00, $0b, $03
	db $04, $01, $00, $4d, $02, $02, $ff, $00, $4d, $04, $02, $ff, $ff, $00, $0b, $03
	db $04, $01, $00, $4d, $04, $02, $ff, $ff, $00, $0b, $03, $04, $01, $00, $4d, $02
	db $02, $ff, $ff, $00, $0b, $03, $04, $01, $ff, $06, $07, $03, $00, $85, $04, $01
	db $07, $07, $03, $00, $85, $05, $01, $02, $02, $1a, $01, $00, $00, $00, $04, $02
	db $1b, $01, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d6, $68
	db $02, $69, $74, $d9, $1b, $2d, $10, $69, $ad, $6a, $1b, $2d, $43, $69, $ad, $6a
	db $1b, $2d, $67, $69, $ad, $6a, $1b, $2d, $a4, $69, $ad, $6a, $1b, $2d, $e1, $69
	db $ad, $6a, $1b, $2d, $28, $6a, $ad, $6a, $1b, $2d, $67, $69, $ad, $6a, $75, $d9
	db $1c, $2d, $65, $6a, $ae, $6a, $1c, $2d, $8e, $6a, $ae, $6a, $8f, $ff, $01, $01
	db $01, $8f, $ff, $02, $01, $02, $8f, $ff, $07, $01, $03, $8f, $ff, $08, $01, $04
	db $8f, $ff, $05, $04, $05, $8f, $ff, $04, $01, $06, $8f, $ff, $05, $01, $06, $50
	db $14, $05, $03, $07, $00, $51, $06, $04, $07, $40, $50, $03, $04, $ff, $ff, $8f
	db $ff, $01, $01, $01, $8f, $ff, $02, $01, $02, $8f, $ff, $07, $01, $03, $8f, $ff
	db $08, $01, $04, $8f, $ff, $05, $04, $05, $8f, $ff, $04, $01, $06, $8f, $ff, $05
	db $01, $06, $ff, $8f, $ff, $01, $01, $01, $8f, $ff, $02, $01, $02, $8f, $ff, $07
	db $01, $03, $8f, $ff, $08, $01, $04, $8f, $ff, $05, $04, $05, $8f, $ff, $04, $01
	db $06, $8f, $ff, $05, $01, $06, $50, $14, $07, $04, $07, $50, $21, $0b, $00, $ff
	db $00, $51, $06, $04, $07, $40, $5f, $05, $03, $ff, $40, $50, $03, $04, $ff, $ff
	db $8f, $ff, $01, $01, $01, $8f, $ff, $02, $01, $02, $8f, $ff, $07, $01, $03, $8f
	db $ff, $08, $01, $04, $8f, $ff, $05, $04, $05, $8f, $ff, $04, $01, $06, $8f, $ff
	db $05, $01, $06, $50, $14, $07, $04, $07, $50, $21, $0b, $00, $ff, $00, $51, $06
	db $04, $07, $40, $5f, $05, $03, $ff, $40, $50, $03, $04, $ff, $ff, $90, $ff, $02
	db $03, $0d, $90, $ff, $04, $03, $0e, $8f, $ff, $01, $01, $01, $8f, $ff, $02, $01
	db $02, $8f, $ff, $07, $01, $03, $8f, $ff, $08, $01, $04, $8f, $ff, $05, $04, $05
	db $8f, $ff, $04, $01, $06, $8f, $ff, $05, $01, $06, $10, $14, $07, $04, $07, $40
	db $21, $0b, $04, $ff, $70, $14, $07, $04, $07, $40, $5f, $05, $03, $ff, $40, $50
	db $03, $04, $ff, $ff, $8f, $ff, $01, $01, $01, $8f, $ff, $02, $01, $02, $8f, $ff
	db $07, $01, $03, $8f, $ff, $08, $01, $04, $8f, $ff, $05, $04, $05, $8f, $ff, $04
	db $01, $06, $8f, $ff, $05, $01, $06, $50, $14, $06, $04, $06, $50, $21, $0b, $00
	db $ff, $00, $51, $06, $04, $06, $00, $5f, $04, $05, $ff, $00, $50, $03, $04, $ff
	db $ff, $8f, $ff, $01, $01, $08, $8f, $ff, $02, $01, $09, $8f, $ff, $08, $01, $0a
	db $8f, $ff, $08, $05, $0b, $8f, $ff, $05, $01, $0c, $40, $21, $08, $01, $ff, $40
	db $39, $08, $01, $ff, $50, $14, $00, $04, $07, $ff, $8f, $ff, $01, $01, $08, $8f
	db $ff, $02, $01, $09, $8f, $ff, $08, $01, $0a, $8f, $ff, $08, $05, $0b, $8f, $ff
	db $05, $01, $0c, $40, $21, $08, $02, $ff, $ff, $ff, $ff, $b1, $6a, $76, $d9, $0d
	db $26, $bf, $6a, $cb, $6a, $0e, $26, $ca, $6a, $cc, $6a, $00, $16, $01, $02, $01
	db $50, $21, $0a, $00, $ff, $ff, $ff, $ff, $01, $02, $00, $00, $01, $04, $05, $ff
	db $d6, $6a, $77, $d9, $10, $26, $e4, $6a, $09, $6b, $11, $26, $03, $6b, $0a, $6b
	db $8f, $ff, $04, $01, $02, $8f, $ff, $05, $01, $02, $8f, $ff, $04, $02, $02, $8f
	db $ff, $05, $02, $02, $00, $0e, $08, $03, $01, $70, $21, $00, $00, $ff, $ff, $00
	db $0e, $08, $03, $01, $ff, $ff, $04, $01, $00, $00, $01, $04, $05, $ff, $14, $6b
	db $78, $d9, $16, $24, $22, $6b, $38, $6b, $17, $24, $37, $6b, $39, $6b, $90, $ff
	db $05, $04, $02, $00, $20, $04, $04, $01, $40, $39, $08, $00, $ff, $50, $21, $0a
	db $01, $ff, $ff, $ff, $ff, $05, $04, $00, $00, $01, $04, $05, $ff, $43, $6b, $79
	db $d9, $13, $26, $51, $6b, $5d, $6b, $14, $26, $5c, $6b, $5e, $6b, $00, $3c, $04
	db $04, $01, $50, $21, $0a, $00, $ff, $ff, $ff, $ff, $01, $04, $00, $00, $01, $04
	db $05, $ff, $68, $6b, $7a, $d9, $16, $26, $76, $6b, $b9, $6b, $17, $26, $b3, $6b
	db $ba, $6b, $90, $ff, $07, $01, $07, $90, $ff, $04, $04, $08, $90, $ff, $05, $05
	db $09, $90, $ff, $01, $03, $0a, $8f, $ff, $00, $06, $01, $8f, $ff, $04, $01, $02
	db $8f, $ff, $05, $01, $02, $06, $25, $01, $02, $03, $06, $25, $08, $00, $04, $06
	db $25, $05, $03, $05, $06, $25, $06, $06, $06, $50, $21, $0a, $00, $ff, $ff, $8f
	db $ff, $00, $06, $01, $ff, $ff, $05, $01, $00, $00, $01, $04, $05, $ff, $c4, $6b
	db $7b, $d9, $19, $26, $d2, $6b, $f2, $6b, $1a, $26, $e7, $6b, $f3, $6b, $8f, $ff
	db $06, $06, $01, $82, $ff, $05, $00, $02, $10, $1d, $07, $03, $03, $50, $21, $0a
	db $00, $ff, $ff, $8f, $ff, $06, $06, $01, $82, $ff, $05, $00, $02, $ff, $ff, $07
	db $03, $00, $00, $01, $04, $05, $ff, $fd, $6b, $7c, $d9, $1c, $26, $0b, $6c, $7b
	db $6c, $1d, $26, $52, $6c, $7c, $6c, $82, $ff, $06, $02, $01, $80, $ff, $06, $02
	db $01, $82, $ff, $08, $02, $02, $80, $ff, $08, $02, $02, $82, $ff, $06, $04, $03
	db $80, $ff, $06, $04, $03, $82, $ff, $08, $04, $04, $80, $ff, $08, $04, $04, $8f
	db $ff, $04, $06, $07, $00, $12, $03, $01, $05, $00, $12, $03, $02, $06, $30, $02
	db $03, $06, $07, $20, $17, $08, $05, $08, $70, $21, $00, $02, $ff, $ff, $8f, $ff
	db $06, $02, $01, $8f, $ff, $08, $02, $02, $8f, $ff, $06, $04, $03, $8f, $ff, $08
	db $04, $04, $8f, $ff, $04, $06, $07, $00, $12, $03, $01, $05, $00, $12, $03, $02
	db $06, $30, $02, $03, $06, $07, $ff, $ff, $08, $06, $00, $00, $01, $04, $05, $ff
	db $86, $6c, $7d, $d9, $1b, $25, $94, $6c, $0e, $6d, $1c, $25, $db, $6c, $0f, $6d
	db $90, $ff, $04, $04, $03, $90, $ff, $03, $05, $03, $90, $ff, $03, $06, $03, $90
	db $ff, $06, $04, $04, $90, $ff, $06, $05, $04, $90, $ff, $05, $06, $04, $90, $ff
	db $05, $03, $02, $40, $e0, $05, $00, $ff, $40, $e1, $05, $00, $ff, $40, $e2, $05
	db $00, $ff, $40, $e3, $05, $00, $ff, $00, $19, $04, $01, $01, $60, $15, $04, $08
	db $ff, $50, $21, $0a, $01, $ff, $ff, $90, $ff, $04, $04, $03, $90, $ff, $03, $05
	db $03, $90, $ff, $03, $06, $03, $90, $ff, $06, $04, $04, $90, $ff, $06, $05, $04
	db $90, $ff, $05, $06, $04, $40, $e0, $05, $00, $ff, $40, $e1, $05, $00, $ff, $40
	db $e2, $05, $00, $ff, $40, $e3, $05, $00, $ff, $ff, $ff, $04, $01, $00, $00, $01
	db $04, $05, $ff, $19, $6d, $7e, $d9, $01, $25, $27, $6d, $f1, $6d, $02, $25, $96
	db $6d, $f2, $6d, $90, $ff, $04, $00, $02, $90, $ff, $05, $00, $03, $90, $ff, $06
	db $00, $04, $90, $ff, $01, $01, $05, $90, $ff, $05, $02, $06, $90, $ff, $08, $02
	db $07, $90, $ff, $02, $04, $08, $90, $ff, $03, $04, $09, $90, $ff, $04, $04, $0a
	db $90, $ff, $07, $04, $0b, $90, $ff, $08, $04, $0c, $90, $ff, $07, $05, $0d, $90
	db $ff, $01, $06, $0e, $90, $ff, $05, $06, $0f, $90, $ff, $06, $02, $10, $40, $e0
	db $08, $00, $ff, $40, $e1, $08, $00, $ff, $40, $e2, $08, $00, $ff, $40, $e3, $08
	db $00, $ff, $40, $39, $02, $00, $ff, $00, $1e, $08, $05, $01, $70, $21, $00, $00
	db $ff, $ff, $90, $ff, $04, $00, $02, $90, $ff, $05, $00, $03, $90, $ff, $06, $00
	db $04, $90, $ff, $01, $01, $05, $90, $ff, $05, $02, $06, $90, $ff, $08, $02, $07
	db $90, $ff, $02, $04, $08, $90, $ff, $03, $04, $09, $90, $ff, $04, $04, $0a, $90
	db $ff, $07, $04, $0b, $90, $ff, $08, $04, $0c, $90, $ff, $07, $05, $0d, $90, $ff
	db $01, $06, $0e, $90, $ff, $05, $06, $0f, $40, $e0, $08, $00, $ff, $40, $e1, $08
	db $00, $ff, $40, $e2, $08, $00, $ff, $40, $e3, $08, $00, $ff, $ff, $ff, $08, $05
	db $00, $00, $01, $04, $05, $ff, $fc, $6d, $7f, $d9, $04, $23, $0a, $6e, $2a, $6e
	db $05, $23, $24, $6e, $2b, $6e, $90, $ff, $06, $06, $04, $8f, $ff, $08, $06, $01
	db $8f, $ff, $07, $04, $02, $00, $2c, $01, $01, $03, $50, $21, $0a, $00, $ff, $ff
	db $8f, $ff, $07, $04, $02, $ff, $ff, $07, $06, $00, $00, $01, $04, $05, $ff, $35
	db $6e, $80, $d9, $04, $25, $43, $6e, $35, $6f, $05, $25, $d0, $6e, $36, $6f, $90
	db $ff, $02, $02, $02, $90, $ff, $02, $03, $02, $90, $ff, $02, $05, $02, $90, $ff
	db $02, $06, $02, $90, $ff, $04, $02, $02, $90, $ff, $04, $04, $02, $90, $ff, $04
	db $06, $02, $90, $ff, $06, $02, $02, $90, $ff, $06, $03, $02, $90, $ff, $06, $05
	db $02, $90, $ff, $06, $06, $02, $90, $ff, $08, $02, $02, $90, $ff, $08, $03, $02
	db $90, $ff, $08, $04, $02, $90, $ff, $08, $05, $02, $90, $ff, $08, $06, $02, $90
	db $ff, $01, $05, $03, $90, $ff, $02, $04, $04, $90, $ff, $05, $03, $05, $90, $ff
	db $05, $04, $06, $90, $ff, $07, $03, $07, $90, $ff, $07, $05, $08, $40, $e0, $01
	db $00, $ff, $40, $e1, $01, $00, $ff, $40, $e2, $01, $00, $ff, $40, $e3, $01, $00
	db $ff, $00, $18, $01, $01, $01, $50, $21, $0a, $00, $ff, $ff, $90, $ff, $02, $02
	db $02, $90, $ff, $02, $03, $02, $90, $ff, $02, $05, $02, $90, $ff, $02, $06, $02
	db $90, $ff, $04, $02, $02, $90, $ff, $04, $04, $02, $90, $ff, $04, $06, $02, $90
	db $ff, $06, $02, $02, $90, $ff, $06, $03, $02, $90, $ff, $06, $05, $02, $90, $ff
	db $06, $06, $02, $90, $ff, $08, $02, $02, $90, $ff, $08, $03, $02, $90, $ff, $08
	db $04, $02, $90, $ff, $08, $05, $02, $90, $ff, $08, $06, $02, $40, $e0, $01, $00
	db $ff, $40, $e1, $01, $00, $ff, $40, $e2, $01, $00, $ff, $40, $e3, $01, $00, $ff
	db $ff, $ff, $01, $01, $00, $00, $01, $04, $05, $ff, $40, $6f, $81, $d9, $07, $24
	db $4e, $6f, $5a, $6f, $08, $24, $59, $6f, $5b, $6f, $05, $1b, $03, $04, $01, $50
	db $21, $0a, $01, $ff, $ff, $ff, $ff, $05, $03, $00, $00, $01, $04, $05, $ff, $65
	db $6f, $82, $d9, $07, $23, $79, $6f, $da, $6f, $09, $23, $79, $6f, $db, $6f, $08
	db $23, $b6, $6f, $db, $6f, $8f, $ff, $04, $02, $01, $8f, $ff, $02, $03, $02, $8f
	db $ff, $01, $04, $03, $8f, $ff, $08, $04, $04, $8f, $ff, $06, $05, $05, $8f, $ff
	db $03, $03, $06, $8f, $ff, $07, $04, $07, $60, $15, $02, $06, $ff, $70, $21, $00
	db $00, $ff, $00, $23, $05, $01, $08, $00, $ff, $05, $01, $08, $00, $ff, $06, $01
	db $08, $ff, $8f, $ff, $04, $02, $01, $8f, $ff, $02, $03, $02, $8f, $ff, $01, $04
	db $03, $8f, $ff, $08, $04, $04, $8f, $ff, $06, $05, $05, $8f, $ff, $03, $03, $06
	db $8f, $ff, $07, $04, $07, $ff, $ff, $06, $01, $00, $00, $01, $04, $05, $ff, $e5
	db $6f, $83, $d9, $07, $25, $f3, $6f, $22, $70, $07, $25, $17, $70, $22, $70, $90
	db $ff, $04, $04, $01, $90, $ff, $05, $04, $02, $40, $e1, $04, $04, $ff, $40, $5f
	db $04, $02, $ff, $40, $05, $04, $02, $ff, $40, $39, $00, $00, $ff, $60, $e0, $05
	db $04, $ff, $ff, $90, $ff, $04, $04, $03, $90, $ff, $05, $04, $03, $ff, $ff, $25
	db $70, $84, $d9, $09, $25, $33, $70, $49, $70, $0a, $25, $48, $70, $4a, $70, $50
	db $21, $0a, $01, $ff, $00, $28, $04, $05, $01, $00, $ff, $04, $04, $01, $00, $ff
	db $05, $04, $01, $ff, $ff, $ff, $01, $03, $00, $00, $01, $04, $05, $ff, $54, $70
	db $85, $d9, $01, $24, $62, $70, $6e, $70, $02, $24, $6d, $70, $6f, $70, $00, $2b
	db $01, $05, $01, $50, $21, $0a, $00, $ff, $ff, $ff, $ff, $01, $05, $00, $00, $01
	db $04, $05, $ff, $79, $70, $86, $d9, $16, $25, $81, $70, $b9, $70, $90, $ff, $01
	db $01, $06, $90, $ff, $02, $01, $06, $90, $ff, $04, $01, $07, $90, $ff, $05, $01
	db $07, $90, $ff, $07, $01, $08, $90, $ff, $08, $01, $08, $8f, $ff, $03, $03, $01
	db $8f, $ff, $06, $03, $02, $00, $05, $02, $02, $03, $00, $05, $05, $02, $04, $00
	db $05, $08, $02, $05, $ff, $01, $01, $41, $00, $00, $01, $06, $02, $01, $41, $00
	db $00, $02, $06, $04, $01, $41, $00, $00, $04, $06, $05, $01, $41, $00, $00, $05
	db $06, $07, $01, $41, $00, $00, $07, $06, $08, $01, $41, $00, $00, $08, $06, $ff
	db $e6, $70, $87, $d9, $18, $25, $00, $71, $2b, $71, $18, $25, $0b, $71, $2b, $71
	db $18, $25, $20, $71, $2b, $71, $19, $25, $42, $4b, $2c, $71, $00, $1c, $01, $04
	db $01, $50, $21, $0a, $00, $ff, $ff, $00, $22, $04, $03, $02, $50, $21, $0a, $00
	db $ff, $00, $ff, $04, $03, $02, $00, $ff, $05, $03, $02, $ff, $00, $3e, $07, $04
	db $03, $50, $21, $0a, $00, $ff, $ff, $ff, $01, $02, $00, $00, $01, $04, $05, $04
	db $02, $00, $00, $01, $04, $05, $07, $02, $00, $00, $01, $04, $05, $ff, $46, $71
	db $84, $71, $88, $d9, $13, $24, $92, $71, $be, $73, $13, $24, $c0, $71, $7e, $73
	db $13, $24, $ee, $71, $7e, $73, $13, $24, $1c, $72, $fe, $73, $13, $24, $4a, $72
	db $7e, $73, $13, $24, $78, $72, $3e, $74, $13, $24, $a6, $72, $7e, $73, $13, $24
	db $d4, $72, $7e, $73, $13, $24, $02, $73, $7e, $73, $13, $24, $30, $73, $7e, $74
	db $89, $d9, $14, $24, $5e, $73, $be, $74, $14, $24, $73, $73, $be, $74, $90, $ff
	db $04, $04, $0f, $90, $ff, $02, $07, $01, $90, $ff, $07, $07, $01, $90, $ff, $09
	db $02, $0f, $90, $ff, $09, $05, $0f, $90, $ff, $02, $00, $04, $90, $ff, $07, $00
	db $04, $90, $ff, $00, $02, $0f, $90, $ff, $00, $05, $0f, $ff, $90, $ff, $04, $04
	db $0f, $90, $ff, $02, $07, $02, $90, $ff, $07, $07, $02, $90, $ff, $09, $02, $0f
	db $90, $ff, $09, $05, $0f, $90, $ff, $02, $00, $0f, $90, $ff, $07, $00, $0f, $90
	db $ff, $00, $02, $0f, $90, $ff, $00, $05, $0f, $ff, $90, $ff, $04, $04, $0f, $90
	db $ff, $02, $07, $03, $90, $ff, $07, $07, $03, $90, $ff, $09, $02, $0f, $90, $ff
	db $09, $05, $0f, $90, $ff, $02, $00, $0f, $90, $ff, $07, $00, $0f, $90, $ff, $00
	db $02, $0f, $90, $ff, $00, $05, $0f, $ff, $90, $ff, $04, $04, $0f, $90, $ff, $02
	db $07, $0f, $90, $ff, $07, $07, $0f, $90, $ff, $09, $02, $0f, $90, $ff, $09, $05
	db $03, $90, $ff, $02, $00, $0f, $90, $ff, $07, $00, $0f, $90, $ff, $00, $02, $0f
	db $90, $ff, $00, $05, $0f, $ff, $90, $ff, $04, $04, $0f, $90, $ff, $02, $07, $0f
	db $90, $ff, $07, $07, $0f, $90, $ff, $09, $02, $0f, $90, $ff, $09, $05, $0f, $90
	db $ff, $02, $00, $05, $90, $ff, $07, $00, $05, $90, $ff, $00, $02, $0f, $90, $ff
	db $00, $05, $0f, $ff, $90, $ff, $04, $04, $0f, $90, $ff, $02, $07, $0f, $90, $ff
	db $07, $07, $0f, $90, $ff, $09, $02, $0f, $90, $ff, $09, $05, $0f, $90, $ff, $02
	db $00, $06, $90, $ff, $07, $00, $06, $90, $ff, $00, $02, $0f, $90, $ff, $00, $05
	db $05, $ff, $90, $ff, $04, $04, $0f, $90, $ff, $02, $07, $0f, $90, $ff, $07, $07
	db $0f, $90, $ff, $09, $02, $0f, $90, $ff, $09, $05, $0f, $90, $ff, $02, $00, $0f
	db $90, $ff, $07, $00, $0f, $90, $ff, $00, $02, $07, $90, $ff, $00, $05, $07, $ff
	db $90, $ff, $04, $04, $0f, $90, $ff, $02, $07, $08, $90, $ff, $07, $07, $08, $90
	db $ff, $09, $02, $0f, $90, $ff, $09, $05, $0f, $90, $ff, $02, $00, $0f, $90, $ff
	db $07, $00, $0f, $90, $ff, $00, $02, $0f, $90, $ff, $00, $05, $0f, $ff, $90, $ff
	db $04, $04, $0f, $90, $ff, $02, $07, $09, $90, $ff, $07, $07, $09, $90, $ff, $09
	db $02, $0f, $90, $ff, $09, $05, $0f, $90, $ff, $02, $00, $0f, $90, $ff, $07, $00
	db $0f, $90, $ff, $00, $02, $0f, $90, $ff, $00, $05, $0f, $ff, $90, $ff, $04, $04
	db $0f, $90, $ff, $02, $07, $0f, $90, $ff, $07, $07, $0f, $90, $ff, $09, $02, $0f
	db $90, $ff, $09, $05, $0f, $90, $ff, $02, $00, $0f, $90, $ff, $07, $00, $0f, $90
	db $ff, $00, $02, $09, $90, $ff, $00, $05, $0f, $ff, $8f, $ff, $03, $02, $10, $8f
	db $ff, $03, $05, $12, $00, $1a, $06, $02, $11, $70, $21, $00, $01, $ff, $ff, $8f
	db $ff, $03, $02, $10, $8f, $ff, $03, $05, $12, $ff, $05, $05, $00, $00, $01, $04
	db $05, $02, $00, $42, $00, $00, $02, $07, $07, $00, $42, $00, $00, $07, $07, $00
	db $02, $42, $00, $00, $09, $02, $00, $05, $42, $00, $00, $09, $05, $02, $07, $42
	db $00, $00, $02, $00, $07, $07, $42, $00, $00, $07, $00, $09, $02, $42, $00, $00
	db $00, $02, $09, $05, $42, $00, $00, $00, $05, $ff, $05, $05, $00, $00, $01, $04
	db $05, $02, $00, $42, $00, $00, $02, $07, $07, $00, $42, $00, $00, $07, $07, $00
	db $02, $42, $00, $00, $09, $02, $00, $05, $42, $00, $00, $09, $05, $02, $07, $42
	db $00, $00, $02, $00, $07, $07, $42, $00, $00, $07, $00, $09, $02, $60, $00, $00
	db $00, $02, $09, $05, $42, $00, $00, $00, $05, $ff, $05, $05, $00, $00, $01, $04
	db $05, $02, $00, $42, $00, $00, $02, $07, $07, $00, $42, $00, $00, $07, $07, $00
	db $02, $42, $00, $00, $09, $02, $00, $05, $42, $00, $00, $09, $05, $02, $07, $42
	db $00, $00, $02, $00, $07, $07, $42, $00, $00, $07, $00, $09, $02, $42, $00, $00
	db $00, $02, $09, $05, $60, $00, $00, $00, $05, $ff, $05, $05, $00, $00, $01, $04
	db $05, $02, $00, $42, $00, $00, $02, $07, $07, $00, $42, $00, $00, $07, $07, $00
	db $02, $42, $00, $00, $09, $02, $00, $05, $60, $00, $00, $09, $05, $02, $07, $42
	db $00, $00, $02, $00, $07, $07, $42, $00, $00, $07, $00, $09, $02, $42, $00, $00
	db $00, $02, $09, $05, $42, $00, $00, $00, $05, $ff, $05, $05, $00, $00, $01, $04
	db $05, $02, $00, $42, $00, $00, $02, $07, $07, $00, $42, $00, $00, $07, $07, $00
	db $02, $60, $00, $00, $09, $02, $00, $05, $42, $00, $00, $09, $05, $02, $07, $42
	db $00, $00, $02, $00, $07, $07, $42, $00, $00, $07, $00, $09, $02, $42, $00, $00
	db $00, $02, $09, $05, $42, $00, $00, $00, $05, $ff, $00, $02, $42, $00, $00, $09
	db $02, $00, $05, $42, $00, $00, $09, $05, $09, $02, $42, $00, $00, $00, $02, $09
	db $05, $42, $00, $00, $00, $05, $ff, $dd, $74, $8a, $d9, $10, $24, $eb, $74, $15
	db $75, $11, $24, $0a, $75, $16, $75, $82, $ff, $07, $05, $01, $82, $ff, $08, $05
	db $01, $50, $21, $0a, $01, $ff, $06, $27, $04, $02, $02, $00, $ff, $04, $02, $02
	db $00, $ff, $05, $02, $02, $ff, $82, $ff, $07, $05, $01, $82, $ff, $08, $05, $01
	db $ff, $ff, $02, $05, $00, $00, $01, $04, $05, $ff, $20, $75, $8b, $d9, $19, $24
	db $2e, $75, $58, $75, $1a, $24, $57, $75, $59, $75, $60, $15, $00, $07, $02, $50
	db $21, $0a, $01, $ff, $00, $24, $05, $02, $01, $60, $e0, $05, $03, $ff, $60, $e1
	db $05, $04, $ff, $60, $e2, $05, $04, $ff, $60, $e3, $05, $04, $ff, $00, $ff, $06
	db $02, $01, $ff, $ff, $ff, $06, $01, $00, $00, $01, $04, $05, $ff, $63, $75, $8c
	db $d9, $0a, $24, $77, $75, $c0, $75, $0b, $24, $bf, $75, $c1, $75, $0a, $24, $9b
	db $75, $c0, $75, $20, $e0, $04, $07, $ff, $40, $2b, $04, $06, $ff, $40, $2b, $05
	db $06, $ff, $40, $15, $04, $06, $ff, $40, $39, $04, $00, $ff, $50, $21, $0a, $01
	db $ff, $00, $29, $04, $05, $ff, $ff, $20, $e0, $04, $07, $ff, $40, $2b, $04, $06
	db $ff, $40, $2b, $05, $06, $ff, $20, $15, $03, $04, $ff, $40, $39, $04, $00, $ff
	db $50, $21, $0a, $01, $ff, $00, $29, $04, $05, $ff, $ff, $ff, $ff, $05, $05, $00
	db $00, $01, $04, $05, $ff, $cb, $75, $8d, $d9, $01, $23, $d9, $75, $ef, $75, $02
	db $23, $ee, $75, $f0, $75, $50, $21, $0a, $00, $ff, $00, $2d, $04, $03, $01, $00
	db $ff, $04, $03, $01, $00, $ff, $05, $03, $01, $ff, $ff, $ff, $02, $04, $00, $00
	db $01, $04, $05, $ff, $fa, $75, $8e, $d9, $1c, $24, $0e, $76, $39, $76, $1c, $24
	db $23, $76, $3a, $76, $1d, $24, $38, $76, $3b, $76, $50, $21, $0a, $00, $ff, $00
	db $2e, $04, $03, $01, $00, $ff, $05, $03, $01, $00, $ff, $04, $03, $01, $ff, $50
	db $21, $0a, $00, $ff, $00, $2f, $04, $03, $02, $00, $ff, $05, $03, $02, $00, $ff
	db $04, $03, $02, $ff, $ff, $ff, $ff, $03, $04, $00, $00, $01, $04, $05, $ff, $45
	db $76, $8f, $d9, $0d, $24, $53, $76, $69, $76, $0e, $24, $68, $76, $6a, $76, $50
	db $21, $0a, $00, $ff, $00, $30, $04, $01, $01, $00, $ff, $04, $01, $01, $00, $ff
	db $05, $01, $01, $ff, $ff, $ff, $04, $01, $00, $00, $01, $04, $05, $ff, $74, $76
	db $90, $d9, $0c, $25, $82, $76, $98, $76, $0d, $25, $97, $76, $99, $76, $50, $21
	db $0a, $00, $ff, $00, $31, $04, $02, $01, $00, $ff, $04, $02, $01, $00, $ff, $05
	db $02, $01, $ff, $ff, $ff, $02, $04, $00, $00, $01, $04, $05, $ff, $a3, $76, $91
	db $d9, $0b, $23, $b1, $76, $c7, $76, $0c, $23, $c6, $76, $c8, $76, $50, $21, $0a
	db $00, $ff, $00, $32, $04, $01, $01, $00, $ff, $04, $01, $01, $00, $ff, $05, $01
	db $01, $ff, $ff, $ff, $05, $03, $00, $00, $01, $04, $05, $ff, $d2, $76, $92, $d9
	db $0e, $23, $e0, $76, $f6, $76, $0f, $23, $f5, $76, $f7, $76, $50, $21, $0a, $00
	db $ff, $00, $33, $04, $01, $01, $00, $ff, $04, $01, $01, $00, $ff, $05, $01, $01
	db $ff, $ff, $ff, $04, $03, $00, $00, $01, $04, $05, $ff, $01, $77, $93, $d9, $11
	db $23, $0f, $77, $25, $77, $12, $23, $24, $77, $26, $77, $50, $21, $0a, $02, $ff
	db $00, $34, $04, $02, $01, $00, $ff, $04, $03, $01, $00, $ff, $05, $03, $01, $ff
	db $ff, $ff, $04, $04, $00, $00, $01, $04, $05, $ff, $30, $77, $94, $d9, $0f, $25
	db $3e, $77, $54, $77, $10, $25, $53, $77, $55, $77, $50, $21, $0a, $00, $ff, $00
	db $35, $04, $01, $01, $00, $ff, $04, $01, $01, $00, $ff, $05, $01, $01, $ff, $ff
	db $ff, $03, $03, $00, $00, $01, $04, $05, $ff, $6d, $77, $ff, $ff, $ff, $ff, $ff
	db $ff, $7b, $77, $ff, $ff, $ff, $ff, $ff, $ff, $95, $d9, $12, $25, $83, $77, $9f
	db $77, $13, $25, $9d, $77, $a0, $77, $96, $d9, $14, $25, $9e, $77, $a8, $77, $50
	db $21, $0a, $01, $ff, $0a, $36, $04, $02, $01, $00, $ff, $03, $03, $01, $00, $ff
	db $04, $03, $01, $00, $ff, $05, $03, $01, $ff, $ff, $ff, $ff, $04, $04, $00, $00
	db $01, $04, $05, $ff, $ff, $ab, $77, $97, $d9, $04, $24, $b9, $77, $d4, $77, $05
	db $24, $d3, $77, $d5, $77, $90, $ff, $04, $04, $01, $90, $ff, $05, $04, $01, $40
	db $37, $04, $03, $02, $40, $ff, $04, $03, $02, $40, $ff, $05, $03, $02, $ff, $ff
	db $ff, $03, $05, $00, $00, $01, $04, $05, $ff, $df, $77, $98, $d9, $01, $26, $e7
	db $77, $f2, $77, $8f, $ff, $04, $03, $01, $00, $06, $04, $02, $01, $ff, $01, $06
	db $00, $80, $00, $00, $00, $ff, $fc, $77, $98, $d9, $03, $26, $04, $78, $0f, $78
	db $82, $ff, $04, $03, $02, $00, $11, $04, $02, $01, $ff, $08, $02, $00, $80, $00
	db $00, $00, $ff, $19, $78, $98, $d9, $05, $26, $21, $78, $4a, $78, $00, $0b, $04
	db $03, $ff, $00, $f0, $03, $03, $ff, $00, $f1, $05, $03, $ff, $00, $f2, $06, $03
	db $ff, $20, $e1, $05, $05, $ff, $20, $e2, $03, $05, $ff, $20, $e3, $06, $05, $ff
	db $20, $e0, $04, $05, $ff, $ff, $ff, $55, $78, $5d, $78, $65, $78, $6d, $78, $75
	db $78, $98, $d9, $19, $23, $7d, $78, $7e, $78, $98, $d9, $1a, $23, $7d, $78, $9b
	db $78, $98, $d9, $1b, $23, $7d, $78, $b8, $78, $98, $d9, $1c, $23, $7d, $78, $ce
	db $78, $98, $d9, $1d, $23, $7d, $78, $f9, $78, $ff, $00, $03, $62, $00, $00, $09
	db $03, $01, $00, $61, $00, $00, $01, $07, $08, $00, $63, $00, $00, $08, $07, $09
	db $03, $61, $00, $00, $00, $03, $ff, $01, $07, $53, $00, $00, $01, $00, $08, $07
	db $53, $00, $00, $08, $00, $00, $03, $53, $00, $00, $09, $03, $01, $00, $62, $00
	db $00, $01, $07, $ff, $01, $07, $61, $00, $00, $01, $00, $08, $00, $61, $00, $00
	db $08, $07, $09, $03, $53, $00, $00, $00, $03, $ff, $08, $07, $62, $00, $00, $08
	db $00, $09, $05, $63, $00, $00, $00, $05, $01, $00, $63, $00, $00, $01, $07, $04
	db $00, $64, $00, $00, $04, $07, $00, $05, $63, $00, $00, $09, $05, $01, $07, $63
	db $00, $00, $01, $00, $ff, $04, $07, $63, $00, $00, $04, $00, $04, $04, $00, $80
	db $00, $00, $00, $ff, $20, $79, $28, $79, $30, $79, $ff, $ff, $38, $79, $40, $79
	db $48, $79, $ff, $ff, $50, $79, $58, $79, $60, $79, $ff, $ff, $98, $d9, $01, $37
	db $42, $4b, $68, $79, $98, $d9, $02, $37, $42, $4b, $69, $79, $98, $d9, $03, $37
	db $42, $4b, $6a, $79, $98, $d9, $04, $37, $42, $4b, $6b, $79, $98, $d9, $05, $37
	db $42, $4b, $6c, $79, $98, $d9, $06, $37, $42, $4b, $6d, $79, $98, $d9, $07, $37
	db $42, $4b, $6e, $79, $98, $d9, $08, $37, $42, $4b, $6f, $79, $98, $d9, $09, $37
	db $42, $4b, $70, $79, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $08, $02, $00, $80
	db $00, $00, $00, $ff, $90, $79, $98, $79, $a0, $79, $ff, $ff, $a8, $79, $b0, $79
	db $b8, $79, $ff, $ff, $c0, $79, $c8, $79, $d0, $79, $ff, $ff, $98, $d9, $0b, $37
	db $42, $4b, $d8, $79, $98, $d9, $0c, $37, $42, $4b, $d9, $79, $98, $d9, $0d, $37
	db $42, $4b, $da, $79, $98, $d9, $0e, $37, $42, $4b, $db, $79, $98, $d9, $0f, $37
	db $42, $4b, $dc, $79, $98, $d9, $10, $37, $42, $4b, $dd, $79, $98, $d9, $11, $37
	db $42, $4b, $de, $79, $98, $d9, $12, $37, $42, $4b, $e6, $79, $98, $d9, $13, $37
	db $42, $4b, $e7, $79, $ff, $ff, $ff, $ff, $ff, $ff, $06, $06, $00, $80, $00, $00
	db $00, $ff, $ff, $ff, $00, $7a, $08, $7a, $10, $7a, $ff, $ff, $18, $7a, $20, $7a
	db $28, $7a, $ff, $ff, $30, $7a, $38, $7a, $40, $7a, $ff, $ff, $98, $d9, $15, $37
	db $42, $4b, $48, $7a, $98, $d9, $16, $37, $42, $4b, $49, $7a, $98, $d9, $17, $37
	db $42, $4b, $4a, $7a, $98, $d9, $18, $37, $42, $4b, $52, $7a, $98, $d9, $19, $37
	db $42, $4b, $53, $7a, $98, $d9, $1a, $37, $42, $4b, $54, $7a, $98, $d9, $1b, $37
	db $42, $4b, $55, $7a, $98, $d9, $1c, $37, $42, $4b, $56, $7a, $98, $d9, $1d, $37
	db $42, $4b, $57, $7a, $ff, $ff, $03, $03, $00, $80, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $70, $7a, $78, $7a, $80, $7a, $ff, $ff, $88, $7a, $90, $7a
	db $98, $7a, $ff, $ff, $a0, $7a, $a8, $7a, $b0, $7a, $ff, $ff, $98, $d9, $1f, $37
	db $42, $4b, $b8, $7a, $98, $d9, $20, $37, $42, $4b, $b9, $7a, $98, $d9, $21, $37
	db $42, $4b, $ba, $7a, $98, $d9, $22, $37, $42, $4b, $bb, $7a, $98, $d9, $23, $37
	db $42, $4b, $bc, $7a, $98, $d9, $24, $37, $42, $4b, $bd, $7a, $98, $d9, $25, $37
	db $42, $4b, $be, $7a, $98, $d9, $26, $37, $42, $4b, $c6, $7a, $98, $d9, $27, $37
	db $42, $4b, $c7, $7a, $ff, $ff, $ff, $ff, $ff, $ff, $01, $06, $00, $80, $00, $00
	db $00, $ff, $ff, $ff, $e0, $7a, $e8, $7a, $f0, $7a, $ff, $ff, $f8, $7a, $00, $7b
	db $08, $7b, $ff, $ff, $10, $7b, $18, $7b, $20, $7b, $ff, $ff, $98, $d9, $29, $37
	db $42, $4b, $28, $7b, $98, $d9, $2a, $37, $42, $4b, $29, $7b, $98, $d9, $2b, $37
	db $42, $4b, $2a, $7b, $98, $d9, $2c, $37, $42, $4b, $2b, $7b, $98, $d9, $2d, $37
	db $42, $4b, $2c, $7b, $98, $d9, $2e, $37, $42, $4b, $2d, $7b, $98, $d9, $2f, $37
	db $42, $4b, $2e, $7b, $98, $d9, $30, $37, $42, $4b, $2f, $7b, $98, $d9, $31, $37
	db $42, $4b, $37, $7b, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $03, $06, $00, $80, $00
	db $00, $00, $ff, $ff, $50, $7b, $58, $7b, $60, $7b, $ff, $ff, $68, $7b, $70, $7b
	db $78, $7b, $ff, $ff, $80, $7b, $88, $7b, $90, $7b, $ff, $ff, $98, $d9, $33, $37
	db $42, $4b, $98, $7b, $98, $d9, $34, $37, $42, $4b, $99, $7b, $98, $d9, $35, $37
	db $42, $4b, $9a, $7b, $98, $d9, $36, $37, $42, $4b, $9b, $7b, $98, $d9, $37, $37
	db $42, $4b, $9c, $7b, $98, $d9, $38, $37, $42, $4b, $9d, $7b, $98, $d9, $39, $37
	db $42, $4b, $9e, $7b, $98, $d9, $3a, $37, $42, $4b, $9f, $7b, $98, $d9, $3b, $37
	db $42, $4b, $a0, $7b, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $08, $06, $00, $80
	db $00, $00, $00, $ff, $aa, $7b, $98, $d9, $07, $26, $b2, $7b, $d1, $7b, $8f, $ff
	db $01, $02, $01, $8f, $ff, $08, $02, $02, $8f, $ff, $03, $03, $03, $8f, $ff, $06
	db $03, $04, $8f, $ff, $02, $05, $05, $8f, $ff, $07, $05, $06, $ff, $05, $06, $00
	db $80, $00, $00, $00, $ff, $db, $7b, $98, $d9, $09, $26, $e3, $7b, $02, $7c, $8f
	db $ff, $03, $03, $01, $8f, $ff, $06, $03, $02, $8f, $ff, $03, $04, $03, $8f, $ff
	db $06, $04, $04, $8f, $ff, $03, $05, $05, $8f, $ff, $06, $05, $06, $ff, $05, $02
	db $00, $80, $00, $00, $00, $ff, $0c, $7c, $98, $d9, $0b, $26, $14, $7c, $3d, $7c
	db $8f, $ff, $03, $02, $01, $8f, $ff, $04, $02, $02, $8f, $ff, $05, $02, $03, $8f
	db $ff, $06, $02, $04, $8f, $ff, $03, $06, $05, $8f, $ff, $04, $06, $06, $8f, $ff
	db $05, $06, $07, $8f, $ff, $06, $06, $08, $ff, $03, $04, $00, $80, $00, $00, $00
	db $ff, $47, $7c, $99, $d9, $14, $23, $67, $7c, $ff, $ff, $15, $23, $67, $7c, $ff
	db $ff, $15, $23, $90, $7c, $ff, $ff, $15, $23, $b9, $7c, $ff, $ff, $15, $23, $67
	db $7c, $ff, $ff, $10, $f0, $04, $09, $ff, $10, $f1, $04, $0a, $ff, $10, $f3, $04
	db $0b, $ff, $10, $f2, $04, $0c, $ff, $10, $e0, $07, $05, $ff, $10, $e1, $06, $05
	db $ff, $10, $e2, $06, $04, $ff, $10, $e3, $06, $06, $ff, $ff, $40, $f0, $04, $05
	db $ff, $70, $f3, $03, $04, $ff, $70, $f1, $03, $05, $ff, $70, $f2, $03, $06, $ff
	db $10, $e1, $06, $05, $ff, $10, $e2, $06, $04, $ff, $10, $e3, $06, $06, $ff, $40
	db $52, $04, $05, $ff, $ff, $30, $f0, $02, $05, $ff, $30, $f3, $03, $04, $ff, $30
	db $f1, $03, $05, $ff, $30, $f2, $03, $06, $ff, $10, $e1, $06, $05, $ff, $10, $e2
	db $06, $04, $ff, $50, $39, $0a, $01, $ff, $10, $e3, $06, $06, $ff, $ff, $e4, $7c
	db $9a, $d9, $17, $23, $fe, $7c, $ff, $ff, $17, $23, $0e, $7d, $ff, $ff, $17, $23
	db $19, $7d, $ff, $ff, $17, $23, $42, $4b, $ff, $ff, $10, $e0, $07, $05, $ff, $40
	db $57, $04, $00, $ff, $40, $52, $04, $05, $ff, $ff, $70, $08, $00, $04, $ff, $40
	db $55, $05, $04, $ff, $ff, $20, $e0, $05, $05, $ff, $50, $21, $09, $05, $ff, $ff
	db $e0, $1f, $70, $8f, $18, $e7, $83, $7c, $07, $f8, $c1, $3e, $81, $ff, $c0, $ff
	db $c0, $ff, $81, $ff, $81, $ff, $03, $ff, $03, $ff, $81, $ff, $04, $04, $0a, $0e
	db $35, $3b, $ca, $f7, $33, $cf, $81, $ff, $67, $ff, $9c, $7f, $1c, $e3, $36, $c9
	db $22, $dd, $82, $7d, $c0, $3f, $c1, $3e, $49, $b6, $1d, $e2, $07, $f8, $70, $8f
	db $c1, $3e, $83, $7c, $c1, $3e, $60, $9f, $0e, $f1, $1c, $e3, $c0, $ff, $81, $ff
	db $81, $ff, $03, $ff, $03, $ff, $81, $ff, $81, $ff, $c0, $ff, $01, $01, $82, $83
	db $4d, $ce, $b2, $fd, $cc, $f3, $62, $ff, $9d, $ff, $72, $fd, $11, $ee, $41, $be
	db $60, $9f, $e0, $1f, $a4, $5b, $8e, $71, $0e, $f1, $1b, $e4, $c1, $3e, $07, $f8
	db $0e, $f1, $07, $f8, $81, $7e, $38, $c7, $70, $8f, $1c, $e3, $81, $ff, $03, $ff
	db $03, $ff, $81, $ff, $81, $ff, $c0, $ff, $c0, $ff, $81, $ff, $40, $40, $a0, $e0
	db $53, $b3, $ac, $7f, $33, $fc, $18, $ff, $76, $ff, $c9, $f7, $30, $cf, $70, $8f
	db $52, $ad, $47, $b8, $07, $f8, $8d, $72, $88, $77, $a0, $5f, $1c, $e3, $38, $c7
	db $1c, $e3, $06, $f9, $e0, $1f, $c1, $3e, $70, $8f, $07, $f8, $03, $ff, $81, $ff
	db $81, $ff, $c0, $ff, $c0, $ff, $81, $ff, $81, $ff, $03, $ff, $00, $ff, $00, $ff
	db $00, $ff, $10, $ef, $20, $cf, $40, $8f, $40, $9e, $40, $88, $00, $ff, $00, $ff
	db $00, $ff, $08, $f7, $04, $f3, $02, $f1, $02, $79, $02, $11, $20, $c0, $60, $80
	db $a0, $10, $92, $22, $97, $17, $97, $17, $be, $3e, $b8, $38, $04, $03, $06, $01
	db $05, $08, $49, $44, $e9, $e8, $e9, $e8, $7d, $7c, $1d, $1c, $04, $fb, $0e, $f5
	db $0f, $f6, $0f, $f7, $0f, $f7, $3f, $cf, $7d, $ad, $78, $a8, $20, $df, $70, $af
	db $f0, $6f, $f0, $ef, $f0, $ef, $fc, $f3, $be, $b5, $1e, $15, $70, $b0, $60, $a0
	db $60, $a0, $20, $c0, $20, $c0, $10, $e0, $10, $e0, $10, $e0, $0e, $0d, $06, $05
	db $06, $05, $04, $03, $04, $03, $08, $07, $08, $07, $08, $07, $00, $ff, $00, $ff
	db $00, $ff, $10, $ef, $20, $cf, $40, $8f, $40, $9e, $40, $88, $00, $ff, $00, $ff
	db $00, $ff, $08, $f7, $04, $f3, $02, $f1, $02, $79, $02, $11, $20, $c0, $60, $80
	db $a0, $10, $92, $22, $97, $17, $97, $17, $be, $3e, $b8, $38, $04, $03, $06, $01
	db $05, $08, $49, $44, $e9, $e8, $e9, $e8, $7d, $7c, $1d, $1c, $04, $fb, $0e, $f5
	db $0f, $f6, $0f, $f7, $0f, $f7, $3f, $cf, $7d, $ad, $78, $a8, $20, $df, $70, $af
	db $f0, $6f, $f0, $ef, $f0, $ef, $fc, $f3, $be, $b5, $1e, $15, $70, $b0, $60, $a0
	db $60, $a0, $20, $c0, $20, $c0, $10, $e0, $10, $e0, $10, $e0, $0e, $0d, $06, $05
	db $06, $05, $04, $03, $04, $03, $08, $07, $08, $07, $08, $07, $10, $10, $28, $38
	db $d4, $ec, $2b, $df, $cc, $3f, $26, $ff, $d9, $ff, $27, $df, $06, $f9, $1d, $e2
	db $3b, $c4, $f7, $08, $2e, $d1, $6d, $92, $6d, $92, $b6, $48, $c0, $3f, $6a, $95
	db $ba, $45, $ba, $45, $dc, $23, $6a, $95, $6e, $91, $dc, $23, $00, $ff, $40, $ba
	db $a0, $5f, $40, $bf, $00, $ff, $08, $57, $14, $eb, $08, $f7, $04, $04, $0a, $0e
	db $35, $3b, $ca, $f7, $33, $cf, $81, $ff, $67, $ff, $9c, $7f, $03, $fc, $16, $e9
	db $0e, $f1, $fd, $02, $1b, $e4, $36, $c9, $55, $aa, $ba, $44, $60, $9f, $ba, $45
	db $da, $25, $de, $21, $ec, $13, $f6, $09, $76, $89, $ee, $11, $00, $ff, $00, $fa
	db $08, $f7, $14, $eb, $09, $f6, $82, $5d, $01, $ee, $00, $ff, $01, $01, $82, $83
	db $4d, $ce, $b2, $fd, $cc, $f3, $62, $ff, $9d, $ff, $72, $fd, $06, $f9, $1d, $e2
	db $3b, $c4, $f7, $08, $2e, $d1, $6d, $92, $6d, $92, $b6, $48, $c0, $3f, $6a, $95
	db $ba, $45, $ba, $45, $dc, $23, $6a, $95, $6e, $91, $dc, $23, $00, $ff, $02, $f8
	db $05, $fa, $02, $fd, $00, $ff, $40, $1f, $a0, $4f, $40, $bf, $40, $40, $a0, $e0
	db $53, $b3, $ac, $7f, $33, $fc, $18, $ff, $76, $ff, $c9, $f7, $03, $fc, $16, $e9
	db $0e, $f1, $fd, $02, $1b, $e4, $36, $c9, $55, $aa, $ba, $44, $60, $9f, $ba, $45
	db $da, $25, $de, $21, $ec, $13, $f6, $09, $76, $89, $ee, $11, $00, $ff, $00, $fa
	db $80, $7f, $41, $be, $90, $6f, $28, $57, $10, $cf, $00, $ff
