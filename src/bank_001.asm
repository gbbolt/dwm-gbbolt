INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]

;@ path: field/core
;@ Bank number byte: RST $10 reads it to know which bank to switch back to.
BankNumber_01::
	db $01

;@ path: field/core
;@ Far-call entry points of bank 1 (entry n is called with `ld hl, $01nn` + `rst $10`).
FarTable_01::
	dw FieldInit
	dw FieldFrame
	dw InitNewGameState
	dw RefreshPartyGfx
	dw SortPartyOrClearIcons
	dw CompactMonsters
	dw PruneLearnableSkills
	dw GetMonsterPersonality
	dw TouchFloorObject
	dw HealAllMonsters
	dw HandleConveyor
	dw RollEncounterGroup
	dw LoadFloorMusic
	dw SelectFloorTable

;@ def FieldInit()
;@ path: field/core
;@ Setup of the field game mode (game mode 1): Terry walking around the town, the Great Tree
;@ and the gate worlds. Loads the graphics set, the SGB palettes, the text box tiles and the
;@ map with the player and his party on it, then switches the screen on.
;@ test: skip sets up the whole field mode (many far calls)
FieldInit::
;> wFieldStackPtr = sp            # the field can return here from deep inside
	ld hl, sp+$00
	ld a, l
	ld [wFieldStackPtr], a
	ld a, h
	ld [$da7c], a
;> fill(wTextTiles, 0x12, 0)      # forget any text box
	xor a
	ld hl, wTextTiles
	ld bc, $0012
	call FillMemory
;> InitSound()
	call InitSound
;> wMusic = 0
	xor a
	ld [wMusic], a
;> wMapLoadState = 0
	xor a
	ld [wMapLoadState], a
;> LoadSGBBorder(GetMapSGBBorder())       # load the font / tile set this map needs
	call GetMapSGBBorder
	call LoadSGBBorder
;> InitSGBPalettes()
	call InitSGBPalettes
;> SetUpTextBox(0x8B00, 0x1202)    # letter tiles at $8B00, box 18 x 2 lines
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> LoadMap()
	call LoadMap
;> hWX = 7
	ld a, $07
	ldh [hWX], a
;> hWY = 0xFF                      # window hidden
	ld a, $ff
	ldh [hWY], a
;> rLYC = 0x7F
	ld a, $7f
	ldh [rLYC], a
;> wLCDC = 0x63                    # LCD stays off until EnableLCDAndInterrupts
	ld a, $63
	ld [wLCDC], a
;> mem[0xC892] = 1
	ld a, $01
	ld [wLCDEffect], a
;> EnableLYCInterrupt()
	call EnableLYCInterrupt
;> return EnableLCDAndInterrupts(3)
	ld a, $03
	jp EnableLCDAndInterrupts


;@ def LoadMap()
;@ path: field/map
;@ Builds the current map: game state on a first start, map graphics and song, the
;@ player's position, the party (compacted, sprites loaded), the map's objects, its entry
;@ script and the player's first animation frame. Remembers the map as the previous one
;@ and resets the scroll and map-update state.
;@ test: skip loads a whole map (many far calls)
LoadMap::
;> InitNewGameState()
	call InitNewGameState
;> LoadMapGfxAndSong()
	call LoadMapGfxAndSong
;> PlacePlayerOnMap()
	call PlacePlayerOnMap
;> LoadFieldObjPalettes()
	ld hl, far_LoadFieldObjPalettes
	rst $10
;> if wDebugSetup:
	ld a, [wDebugSetup]
	or a
;>     DebugSetupGame()
	call nz, DebugSetupGame
;> CompactMonsters()
	call CompactMonsters
;> RefreshPartyGfx()
	call RefreshPartyGfx
;> DrawMapScreen()
	ld hl, far_DrawMapScreen
	rst $10
;> SpawnMapObjects()
	ld hl, far_SpawnMapObjects
	rst $10
;> RunMapEntryEvent()
	call RunMapEntryEvent
;> saved = wFieldTimer
	ld a, [wFieldTimer]
	push af
;> wFieldTimer = 0                 # the map setup below sees timer 0
	xor a
	ld [wFieldTimer], a
;> UpdateAllActors()
	ld hl, far_UpdateAllActors
	rst $10
;> wFieldTimer = saved
	pop af
	ld [wFieldTimer], a
;> wPlayerAnimPtr = wPlayerAnimTimer   # animate the player's state block
	ld hl, wPlayerAnimTimer
	ld a, l
	ld [wPlayerAnimPtr], a
	ld a, h
	ld [$d7b5], a
;> wPlayerAnimFrame = 0
	xor a
	ld [wPlayerAnimFrame], a
;> wPlayerAnimStep = 0
	ld [wPlayerAnimStep], a
;> wPlayerAnimTimer = 0
	ld [wPlayerAnimTimer], a
;> wPlayerAnimGfx = hPlayerGfx
	ldh a, [hPlayerGfx]
	ld [wPlayerAnimGfx], a
;> wPlayerAnim = hPlayerPose      # standing animation of the current pose
	ldh a, [hPlayerPose]
	add $00
	ld [wPlayerAnim], a
;> StepAnimation()
	ld hl, far_StepAnimation
	rst $10
;> hPlayerFrame = wPlayerAnimFrame
	ld a, [wPlayerAnimFrame]
	ldh [hPlayerFrame], a
;> hTestX = hPlayerX
	ldh a, [hPlayerX]
	ldh [hTestX], a
	ldh a, [$ff93]
	ldh [$ffa6], a
;> hTestY = hPlayerY
	ldh a, [hPlayerY]
	ldh [hTestY], a
	ldh a, [$ff96]
	ldh [$ffa8], a
;> GetCollisionAt()                     # read the tile under the player
	call GetCollisionAt
;> wPrevMapId = wMapId
	ld a, [wMapId]
	ld [wPrevMapId], a
;> wPrevOnGateFloor = wOnGateFloor
	ld a, [wOnGateFloor]
	ld [wPrevOnGateFloor], a
;> if not wOnGateFloor and wMapId == 0x5E:
	ld a, [wOnGateFloor]
	or a
	jr nz, .normal
	ld a, [wMapId]
	cp $5e
	jr nz, .normal
;>     Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
	jr .done
;> else:
.normal
;>     BuildStatusBar()
	call BuildStatusBar
;>     DrawStatusBar()
	call DrawStatusBar
.done
;> wGameStarted = 1
	ld a, $01
	ld [wGameStarted], a
;> wPlayerPause = 0
	xor a
	ld [wPlayerPause], a
;> wWarpPending = 0
	xor a
	ld [wWarpPending], a
;> wMapUpdateDest = 0              # no map row / column queued
	xor a
	ld [wMapUpdateDest], a
	ld [$c741], a
;> wMapUpdateDir = 0xFF
	ld a, $ff
	ld [wMapUpdateDir], a
;> hCameraPrevX = hScrollX
	ldh a, [hScrollX]
	ldh [hCameraPrevX], a
	ldh a, [$ffb8]
	ldh [$ffba], a
;> hCameraPrevY = hScrollY
	ldh a, [hScrollY]
	ldh [hCameraPrevY], a
	ldh a, [$ffbc]
	ldh [$ffbe], a
;> HandleConveyor()
	ld hl, far_HandleConveyor
	rst $10
;> return
	ret


;@ def FieldMapChange()
;@ path: field/map
;@ Runs instead of the normal field frame while a map change is under way (wMapLoadState
;@ 1 or 2). State 1: once the fade-out is done, either restarts the field mode (when the
;@ new map needs another graphics set) or blanks the screen, loads the new map, sends the
;@ SGB palettes and draws one frame; state 2: one more frame, then the fade-in starts.
;@ test: skip loads a whole map (many far calls)
FieldMapChange::
;> if wMapLoadState != 2:
	ld a, [wMapLoadState]
	cp $02
	jp z, .fadeIn
;>     if wFadeState:
	ld a, [wFadeState]
	or a
;>         return                  # wait until the fade-out has finished
	ret nz
;>     if GetMapSGBBorder() != wLoadedGfxSet:
	call GetMapSGBBorder
	ld b, a
	ld a, [wLoadedGfxSet]
	cp b
	jr z, .sameGfx
;>         wGameModeChange += 1    # restart the field mode: FieldInit loads the other set
	ld hl, wGameModeChange
	inc [hl]
;>         return
	ret

.sameGfx
;>     rBGP = 0                    # all black while the map is rebuilt
	xor a
	ldh [rBGP], a
;>     rOBP0 = 0
	ldh [rOBP0], a
;>     rOBP1 = 0
	ldh [rOBP1], a
;>@clr     for i in range(256):    # blank the background map: 1024 tiles $E0
	ld hl, $9800
	ld b, $00
.clear
;>         fill(0x9800 + i * 4, 4, 0xE0)   # (waits for VRAM access before each write)
	ld a, $e0
	call WriteVRAMInc
	call WriteVRAMInc
	call WriteVRAMInc
	call WriteVRAMInc
;=@clr
	dec b
	jr nz, .clear

;>     LoadMap()
	call LoadMap
;>     ApplyScroll()
	call ApplyScroll
;>     n = wSGBPalSet * 4
	ld a, [wSGBPalSet]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
;>@pal     for i in range(4):      # the field's 4 SGB palettes
;>@pal         mem16[wSGBPalIds + 2 * i] = n + i
	ld a, l
	ld [wSGBPalIds], a
	ld a, h
	ld [$c85c], a
;=@pal
	inc hl
	ld a, l
	ld [$c85d], a
	ld a, h
	ld [$c85e], a
;=@pal
	inc hl
	ld a, l
	ld [$c85f], a
	ld a, h
	ld [$c860], a
;=@pal
	inc hl
	ld a, l
	ld [$c861], a
	ld a, h
	ld [$c862], a
;>     wSGBPacket[0] = 0xB1        # SGB command ATTR_SET: color the screen areas
	ld a, $b1
	ld [wSGBPacket], a
;>     wSGBPacket[1] = wSGBAttrSet
	ld a, [wSGBAttrSet]
	ld [$c778], a
;>     wSGBPacketID = 0xFF         # send the packet built in RAM
	ld a, $ff
	ld [wSGBPacketID], a
;>     SendSGBPacket()
	ld hl, far_SendSGBPacket
	rst $10
;>     SGBPacketDelay()
	call SGBPacketDelay
;>     SGBLoadPalettes()
	ld hl, far_SGBLoadPalettes
	rst $10
;>     wJoyHeld = 0                # no button carries over into the new map
	xor a
	ld [wJoyHeld], a
;>     wJoyHeldLast = 0
	ld [wJoyHeldLast], a
;>     wJoyPressed = 0
	xor a
	ld [wJoyPressed], a
;>     wJoyRepeat = 0
	ld [wJoyRepeat], a
;>     wJoyRepeatTimer = 0
	xor a
	ld [wJoyRepeatTimer], a
;>     mem[0xC849] = 0
	ld [$c849], a
;>     FieldUpdate()
	call FieldUpdate
;>     wMapLoadState = 2
	ld a, $02
	ld [wMapLoadState], a
;>     return
	ret


.fadeIn
;> wJoyHeld = 0
	xor a
	ld [wJoyHeld], a
;> wJoyHeldLast = 0
	ld [wJoyHeldLast], a
;> wJoyPressed = 0
	xor a
	ld [wJoyPressed], a
;> wJoyRepeat = 0
	ld [wJoyRepeat], a
;> wJoyRepeatTimer = 0
	xor a
	ld [wJoyRepeatTimer], a
;> mem[0xC849] = 0
	ld [$c849], a
;> FieldUpdate()
	call FieldUpdate
;> wMapLoadState = 0
	xor a
	ld [wMapLoadState], a
;> wBGP = 0xD2                     # the field's normal palettes
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
;> InitFade()
	call InitFade
;> StartFade(0xFD)
	ld a, $fd
	call StartFade
;> return
	ret


;@ def InitNewGameState()
;@ path: field/core
;@ Field state reset done on every map load (pause, sprite clip, event step); on the very
;@ first start of a game (wGameStarted 0) it also sets up a new game: story flags cleared,
;@ step timers, the default player name, and - unless the debug setup is on - no party, no
;@ gold, empty bag and storage and no monsters.
;@ test: skip clears large RAM areas
InitNewGameState::
;> wFieldPaused = 0
	xor a
	ld [wFieldPaused], a
;> hSpriteClip = 0
	xor a
	ldh [hSpriteClip], a
;> hSpriteBGTile = 0x80
	ld a, $80
	ldh [hSpriteBGTile], a
;> wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [$c916], a
;> if wGameStarted:
	ld a, [wGameStarted]
	or a
;>     return
	ret nz

;> wWorldFlags = 0
	xor a
	ld [wWorldFlags], a
;> mem[0xCA3F] = 0
	xor a
	ld [wStatusBarMode], a
;> mem[0xC8EC] = 0
	xor a
	ld [wMenuOverlay], a
;> wFieldFlags = 0
	xor a
	ld [wFieldFlags], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> mem[0xD8D8] = 0
	ld [wScriptFlags], a
;> mem[0xC8EE] = 4
	ld a, $04
	ld [wMessageSpeed], a
;> wStepTimer = 100
	ld hl, $0064
	ld a, l
	ld [wStepTimer], a
	ld a, h
	ld [$ca3c], a
;> wFarmStepTimer = 20
	ld hl, $0014
	ld a, l
	ld [wFarmStepTimer], a
	ld a, h
	ld [$ca3e], a
;> fill(0xD92A, 0xC0, 0)           # story progress
	ld hl, $d92a
	ld bc, $00c0
	ld a, $00
	call FillMemory
;> if wOnGateFloor or wMapId != 0x08:
	ld a, [wOnGateFloor]
	or a
	jr nz, .defaultName
	ld a, [wMapId]
	cp $08
	jr z, .nameDone
.defaultName
;>     wPlayerName[0] = 0xD3       # default name (map 8 is where the player names Terry)
	ld a, $d3
	ld [wPlayerName], a
;>     wPlayerName[1] = 0xD4
	ld a, $d4
	ld [$ca43], a
;>     wPlayerName[2] = 0xD5
	ld a, $d5
	ld [$ca44], a
;>     wPlayerName[3] = 0xD6
	ld a, $d6
	ld [$ca45], a

.nameDone
;> mem[0xCA4A] = wRandomHigh
	ld a, [wRandomHigh]
	ld [$ca4a], a
;> if wDebugSetup:
	ld a, [wDebugSetup]
	or a
;>     return                      # DebugSetupGame fills these in
	ret nz

;> wPartyCount = 0
	ld a, $00
	ld [wPartyCount], a
;> wParty[0] = 0xFF
	ld a, $ff
	ld [wParty], a
;> wParty[1] = 0xFF
	ld a, $ff
	ld [$ca8f], a
;> wParty[2] = 0xFF
	ld a, $ff
	ld [$ca90], a
;> wGold[0] = 0
	ld a, $00
	ld [wGold], a
;> wGold[1] = 0
	ld a, $00
	ld [$ca4c], a
;> wGold[2] = 0
	ld a, $00
	ld [$ca4d], a
;> fill(wBagItems, 20, 0xFF)
	ld hl, wBagItems
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> fill(wStoredItems, 40, 0xFF)
	ld hl, wStoredItems
	ld bc, $0028
	ld a, $ff
	call FillMemory
;> for i in range(20):             # no monsters
	ld hl, wMonsters
	ld b, $14
	ld de, $0095
.clearMonsters
;>     wMonsters[i * 0x95] = 0
	ld [hl], $00
	add hl, de
	dec b
	jr nz, .clearMonsters

;> return
	ret


;@ def LoadMapGfxAndSong()
;@ path: field/map
;@ Loads the map's graphics (bank $0B), starts the map's song if another one is playing,
;@ and on a fresh field start decompresses the common field tiles to $8D00.
;@ test: skip far call into the map loader
LoadMapGfxAndSong::
;> if not wGameModeChange and wMapLoadState:
	ld a, [wGameModeChange]
	or a
	jr nz, .keep
	ld a, [wMapLoadState]
	or a
	jr z, .keep
;>     mem[0xD988] = mem[0xD9E9]
	ld a, [$d9e9]
	ld [$d988], a

.keep
;> mem[0xD9E9] = 0
	xor a
	ld [$d9e9], a
;> LoadMapTileset()
	ld hl, far_LoadMapTileset
	rst $10
;> song = GetMapSong()
	ld a, [wMusic]
	ld b, a
	push bc
	call GetMapSong
	pop bc
;> if song != wMusic:
	cp b
;>     QueueMusic(song)
	call nz, QueueMusic
;> if wMapLoadState:
	ld a, [wMapLoadState]
	or a
;>     return
	ret nz

;> Decompress(0x2E00, 0x8D00)      # common field tiles
	ld de, $2e00
	ld hl, $8d00
	call Decompress
;> return
	ret


;@ def InitSGBPalettes()
;@ path: system/sgb
;@ Sets the Super Game Boy palette set and attribute file of the field (both 0, from two
;@ bytes in the home bank) and sends them.
;@ test: skip far call
InitSGBPalettes::
;> wSGBPalSet = mem[0x2ADD]
	ld hl, $2add
	ld a, [hl]
	ld [wSGBPalSet], a
;> wSGBAttrSet = mem[0x2ADE]
	ld hl, $2ade
	ld a, [hl]
	ld [wSGBAttrSet], a
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> return
	ret


;@ def GetMapSong() -> a
;@ path: sound/map
;@ Song of the current map. Fixed maps (below $50, $52, $5D-$60) take it from MapSongs.
;@ On a gate floor, and on the other world maps, song $34 plays - except on the floor
;@ before the last one, which plays the song of wGateWorldMap.
;@ test: wMapId = rng.randrange(0x70)
;@ test: wGateWorldMap = rng.randrange(0x70)
GetMapSong::
;>@cond if not wOnGateFloor and (wMapId < 0x50 or wMapId == 0x52 or 0x5D <= wMapId < 0x61):
	ld a, [wOnGateFloor]
	or a
	jr nz, .world
	ld a, [wMapId]
	cp $50
	jr c, .fixed
;=@cond
	cp $52
	jr z, .fixed
	cp $5d
	jr c, .world
	cp $61
	jr nc, .world

.fixed
;>@fix     return MapSongs[wMapId]
	ld hl, MapSongs
	ld a, [wMapId]
	add l
	ld l, a
	ld a, $00
	adc h
;=@fix
	ld h, a
	ld b, [hl]
	ld a, b
	cp $09
	ret nz
	ret


.world
;> if wGateFloor != wGateFloors - 2:
	ld a, [wGateFloor]
	ld b, a
	ld a, [wGateFloors]
	sub $02
	cp b
;>     return 0x34
	ld a, $34
	ret nz

;>@wm return MapSongs[wGateWorldMap]
	ld hl, MapSongs
	ld a, [wGateWorldMap]
	add l
	ld l, a
	ld a, $00
	adc h
;=@wm
	ld h, a
	ld a, [hl]
	ret


;@ path: sound/map
;@ Song number of each map ($00-$6F), read by GetMapSong.
MapSongs::
	db $09, $09, $09, $09, $09, $09, $1e, $1e, $31, $31, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $1e, $1e, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $9d
	db $34, $0c, $0c, $18, $15, $0c, $2e, $18, $0f, $18, $12, $2e, $1b, $12, $1b, $1b
	db $1b, $1b, $1b, $1b, $12, $1b, $0c, $0f, $12, $12, $15, $15, $18, $1b, $1b, $1b
	db $34, $34, $61, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $61, $02, $02
	db $1b, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34

;@ def GetMapSGBBorder() -> a
;@ path: field/map
;@ Graphics set the map (or the pending warp's destination) needs: 0 on gate floors and
;@ maps from $30 on, 3 for maps below $30, 2 for map $2F, 1 for map $5D; map $5E keeps
;@ whatever set is loaded.
;@ test: wWarpPending = rng.choice([0, 1])
;@ test: wMapId = rng.choice([0x2F, 0x5D, 0x5E, 0x10, 0x40])
;@ test: wWarpMap = rng.choice([0x2F, 0x5D, 0x5E, 0x10, 0x40])
GetMapSGBBorder::
;> hNumber[0] = wMapId                # map to look at
	ld a, [wMapId]
	ldh [hNumber], a
;> mem[0xFFD6] = wOnGateFloor
	ld a, [wOnGateFloor]
	ldh [$ffd6], a
;> if wWarpPending:                # a warp is pending: look at its destination
	ld a, [wWarpPending]
	or a
	jr z, .look
;>     hNumber[0] = wWarpMap
	ld a, [wWarpMap]
	ldh [hNumber], a
;>     mem[0xFFD6] = wWarpOnGateFloor
	ld a, [wWarpOnGateFloor]
	ldh [$ffd6], a

.look
;> if mem[0xFFD6]:
	ldh a, [$ffd6]
	or a
	jr z, .fixedMap
;>     return 0
	ld a, $00
	ret


.fixedMap
;> if hNumber[0] == 0x5E:
	ldh a, [hNumber]
	cp $5e
	jr z, .keep
;>@keep     return wLoadedGfxSet
;> if hNumber[0] == 0x5D:
	cp $5d
	jr nz, .not5D
;>     return 1
	ld a, $01
	ret


.not5D
;> if hNumber[0] == 0x2F:
	ldh a, [hNumber]
	cp $2f
	jr nz, .not2F
;>     return 2
	ld a, $02
	ret


.not2F
;> if hNumber[0] < 0x30:
	ldh a, [hNumber]
	cp $30
;>     return 3
	ld a, $03
	ret c

;> return 0
	ld a, $00
	ret


.keep
;=@keep
	ld a, [wLoadedGfxSet]
	ret


;@ def PlacePlayerOnMap()
;@ path: field/player
;@ Loads Terry's sprite tiles and puts him on the map: at the warp destination when a warp
;@ is pending, at the map's start position (MapStartPositions) on a brand-new game, else
;@ where he already is. A new position also resets the party trail. Then works out his
;@ tile coordinates and the previous-position copy.
;@ test: skip decompresses graphics
PlacePlayerOnMap::
;> DecompressVRAM(0x2F00, 0x8000)   # Terry's sprite tiles
	ld de, $2f00
	ld hl, $8000
	call DecompressVRAM
;> DecompressVRAM(0x2E1D, 0x8180)
	ld de, $2e1d
	ld hl, $8180
	call DecompressVRAM
;> hPlayerSpeedX = 0
	xor a
	ldh [hPlayerSpeedX], a
	ldh [$ffa2], a
;> hPlayerSpeedY = 0
	ldh [hPlayerSpeedY], a
	ldh [$ffa4], a
;> hPlayerXSub = 0
	ldh [hPlayerXSub], a
;> hPlayerYSub = 0
	ldh [hPlayerYSub], a
;> if wWarpPending:
	ld a, [wWarpPending]
	or a
	jr z, .noWarp
;>     hPlayerX = wWarpX
	ld a, [wWarpX]
	ldh [hPlayerX], a
	ld a, [$c970]
	ldh [$ff93], a
;>     hPlayerY = wWarpY
	ld a, [wWarpY]
	ldh [hPlayerY], a
	ld a, [$c972]
	ldh [$ff96], a
	jr .resetTrail

;> elif wGameStarted:
.noWarp
	ld a, [wGameStarted]
	or a
;>     pass                        # keep the current position
	jp nz, .finish

;> else:                           # a new game: the map's start position, facing down
;>     hPlayerGfx = 0
	ld hl, hPlayerGfx
	xor a
	ld [hli], a
;>     hPlayerFrame = 0
	ld [hli], a
;>     hPlayerTileBase = 0
	ld [hli], a
;>     hPlayerAttr = 0
	ld [hl], a
;>     hPlayerPose = 0
	ldh [hPlayerPose], a
;>     hPlayerDir = 0
	ldh [hPlayerDir], a
;>     hPlayerFlags = 0
	ldh [hPlayerFlags], a
;>     mem[0xD7BD] = 0
	ld [wTouchedActor], a
;>@p     p = MapStartPositions + wMapId * 4
	ld a, [wMapId]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
;=@p
	ld a, l
	add LOW(MapStartPositions)
	ld l, a
	ld a, h
	adc HIGH(MapStartPositions)
	ld h, a
;>     hPlayerX = mem16[p]
	ld a, [hli]
	ldh [hPlayerX], a
	ld a, [hli]
	ldh [$ff93], a
;>     hPlayerY = mem16[p + 2]
	ld a, [hli]
	ldh [hPlayerY], a
	ld a, [hl]
	ldh [$ff96], a

.resetTrail
;>@tr     for i in range(49):     # (also after a warp) the whole trail starts at the player
	ld b, $31
	ld hl, wPlayerTrail
.fill
;>         wPlayerTrail[4 * i] = hPlayerX & 0xFF
	ldh a, [hPlayerX]
	ld [hli], a
;>         wPlayerTrail[4 * i + 1] = hPlayerY & 0xFF
	ldh a, [hPlayerY]
	ld [hli], a
;>         wPlayerTrail[4 * i + 2] = (hPlayerX >> 8) << 4 | (hPlayerY >> 8)
	ldh a, [$ff93]
	swap a
	ld c, a
	ldh a, [$ff96]
	or c
	ld [hli], a
;>         wPlayerTrail[4 * i + 3] = hPlayerFrame | hPlayerAttr
	ldh a, [hPlayerFrame]
	ld c, a
	ldh a, [hPlayerAttr]
	or c
	ld [hli], a
;=@tr
	dec b
	jr nz, .fill

;>     wTrailPos = 0
	xor a
	ld [wTrailPos], a

.finish
;> hTestX = hPlayerX
	ldh a, [hPlayerX]
	ldh [hTestX], a
	ldh a, [$ff93]
	ldh [$ffa6], a
;> hTestY = hPlayerY
	ldh a, [hPlayerY]
	ldh [hTestY], a
	ldh a, [$ff96]
	ldh [$ffa8], a
;> GetCollisionAt()                     # tile under the player
	call GetCollisionAt
;>@tx hPlayerTileX = (hPlayerX >> 4) & 0xFF
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	swap h
	swap l
;=@tx
	ld a, h
	and $f0
	ld h, a
	ld a, l
	and $0f
	or h
;=@tx
	ldh [hPlayerTileX], a
;>@ty hPlayerTileY = (hPlayerY >> 4) & 0xFF
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	swap h
	swap l
;=@ty
	ld a, h
	and $f0
	ld h, a
	ld a, l
	and $0f
	or h
;=@ty
	ldh [hPlayerTileY], a
;> hPlayerPrevX = hPlayerX
	ldh a, [hPlayerX]
	ldh [hPlayerPrevX], a
	ldh a, [$ff93]
	ldh [$ff9a], a
;> hPlayerPrevY = hPlayerY
	ldh a, [hPlayerY]
	ldh [hPlayerPrevY], a
	ldh a, [$ff96]
	ldh [$ff9c], a
;> return
	ret


;@ path: field/map
;@ Where Terry starts on each map ($00-$5F) in a new game: X (u16), Y (u16) in map pixels.
MapStartPositions::
	db $f8, $00, $d8, $00, $e8, $00, $b8, $00, $48, $00, $38, $00, $e8, $00, $c8, $00
	db $e8, $00, $a8, $00, $48, $00, $38, $00, $e8, $00, $38, $00, $e8, $00, $38, $00
	db $48, $00, $38, $00, $e8, $00, $48, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $48, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $38, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $58, $00, $58, $00, $68, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $b8, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $78, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $78, $00, $48, $00, $48, $00, $48, $00, $48, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $48, $00, $48, $00, $38, $00, $48, $00, $48, $00, $48, $00, $68, $00
	db $48, $00, $68, $00, $48, $00, $68, $00, $68, $00, $68, $00, $48, $00, $68, $00
	db $d8, $00, $d8, $00, $48, $00, $68, $01, $e8, $00, $b8, $00, $f8, $00, $b8, $00
	db $18, $00, $28, $00, $18, $00, $28, $00, $48, $00, $48, $00, $48, $00, $48, $00
	db $68, $00, $48, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00

;@ def PruneLearnableSkills()
;@ path: monster/skills
;@ For every monster the player owns: removes the skills it already knows from its list
;@ of skills still to learn.
;@ test: skip walks all 20 monster records
PruneLearnableSkills::
;>@m for m in range(20):
	ld hl, wMonsters
	ld b, $00
.monster
;>     if wMonsters[m * 0x95]:
	ld a, [hl]
	or a
	jr z, .next
;>         PruneMonsterSkills(m)
	push hl
	push bc
	call PruneMonsterSkills
	pop bc
	pop hl
.next
;=@m
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@m
	inc b
	ld a, b
	cp $14
	jr nz, .monster
;> return
	ret


;@ def PruneMonsterSkills(m: b)
;@ path: monster/skills
;@ Goes through the 8 known skills of monster m (record +$29, $FF = none) and takes each
;@ out of its to-learn list.
;@ test: skip walks a monster record
PruneMonsterSkills::
;> p = MonsterField(m, wMonsters + 0x29)  # its known skills
	push bc
	ld a, b
	ld hl, wMonSkills
	call MonsterField
	pop bc
;>@k for k in range(8):
	ld c, $08
.skill
;>     if mem[p + k] != 0xFF:
	ld a, [hli]
	cp $ff
;>         RemoveLearnableSkill(mem[p + k], m)
	push hl
	push bc
	call nz, RemoveLearnableSkill
	pop bc
	pop hl
;=@k
	dec c
	jr nz, .skill
;> return
	ret


;@ def RemoveLearnableSkill(skill: a, m: b)
;@ path: monster/skills
;@ Strikes the skill from monster m's to-learn list (25 bytes at record +$31) and closes
;@ the gap, so the remaining skills stay in order with $FF at the end.
;@ test: skip walks a monster record
RemoveLearnableSkill::
;> p = MonsterField(m, wMonsters + 0x31)  # its to-learn list
	ld d, a
	push de
	ld a, b
	ld hl, wMonSkillList
	call MonsterField
	pop de
;>@a for i in range(25):
	push hl
	ld c, $19
.find
;>     if mem[p + i] == skill:
	ld a, [hl]
	cp d
	jr nz, .other
;>         mem[p + i] = 0xFF
	ld [hl], $ff
.other
;=@a
	inc hl
	dec c
	jr nz, .find
;>@b for i in range(25):              # move the list aside, leaving $FF behind
	pop hl
	push hl
	ld de, wNumberBackup
	ld b, $19
.move
;>     wNumberBackup[i] = mem[p + i]
	ld a, [hl]
	ld [de], a
;>     mem[p + i] = 0xFF
	ld a, $ff
	ld [hli], a
;=@b
	inc de
	dec b
	jr nz, .move
;> q = p
	pop hl
;>@c for i in range(25):              # and copy back only the real skills
	ld de, wNumberBackup
	ld b, $19
.copy
;>     if wNumberBackup[i] != 0xFF:
	ld a, [de]
	cp $ff
	jr z, .gap
;>         mem[q] = wNumberBackup[i]
;>         q += 1
	ld [hli], a
.gap
;=@c
	inc de
	dec b
	jr nz, .copy
;> return
	ret


;@ def CompactMonsters()
;@ path: monster/party
;@ Tidies the monster list: party slots whose monster is gone become empty, every monster
;@ is marked "at the farm" (1) and the party's "in the party" (2), the party list closes
;@ its gaps, the records are sorted so the empty ones come last (with the party indexes
;@ renumbered), wPartyCount is recounted and the skill lists are pruned.
;@ test: skip moves whole monster records around
CompactMonsters::
;>@f0 for i in range(3):              # party slots pointing at an empty record
;>@f1     if wParty[i] != 0xFF:
	ld a, [wParty]
	cp $ff
	jr z, .check1
;>@f2         if MonsterField(wParty[i], wMonsters)[0] == 0:
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	or a
	jr nz, .check1
;>@f3             wParty[i] = 0xFF
	ld a, $ff
	ld [wParty], a
.check1
;=@f1
	ld a, [$ca8f]
	cp $ff
	jr z, .check2
;=@f2
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	or a
	jr nz, .check2
;=@f3
	ld a, $ff
	ld [$ca8f], a
.check2
;=@f1
	ld a, [$ca90]
	cp $ff
	jr z, .farm
;=@f2
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	or a
	jr nz, .farm
;=@f3
	ld a, $ff
	ld [$ca90], a

.farm
;>@m for m in range(20):
	ld hl, wMonsters
	ld b, $14
.mark
;>     if wMonsters[m * 0x95]:
	ld a, [hl]
	or a
	jr z, .noMonster
;>         wMonsters[m * 0x95] = 1     # at the farm
	ld [hl], $01
.noMonster
;=@m
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@m
	dec b
	jr nz, .mark
;>@p for i in range(3):
;>@p     MarkInParty(wParty[i])
	ld a, [wParty]
	call MarkInParty
;=@p
	ld a, [$ca8f]
	call MarkInParty
;=@p
	ld a, [$ca90]
	call MarkInParty
;>@g for k in range(2):               # twice: close a gap in slot 0
;>@g     if wParty[0] == 0xFF:
	ld a, [wParty]
	cp $ff
	jr nz, .slot0Full
;>@h         wParty[0] = wParty[1]
	ld hl, wParty
	ld a, [$ca8f]
	ld [hli], a
;>@i         wParty[1] = wParty[2]
	ld a, [$ca90]
	ld [hli], a
;>@j         wParty[2] = 0xFF
	ld [hl], $ff
.slot0Full
;=@g
	ld a, [wParty]
	cp $ff
	jr nz, .slot0Done
;=@h
	ld hl, wParty
	ld a, [$ca8f]
	ld [hli], a
;=@i
	ld a, [$ca90]
	ld [hli], a
;=@j
	ld [hl], $ff
.slot0Done
;> if wParty[1] == 0xFF:              # and a gap in slot 1
	ld a, [$ca8f]
	cp $ff
	jr nz, .slot1Full
;>     wParty[1] = wParty[2]
	ld hl, $ca8f
	ld a, [$ca90]
	ld [hli], a
;>     wParty[2] = 0xFF
	ld [hl], $ff
.slot1Full
;> fill(wSceneObjects, 20, 0xFF)    # new index of each record
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;>@n n = 0
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00
;>@n for m in range(20):
.number
;>     if wMonsters[m * 0x95]:
	ld a, [de]
	or a
	jr z, .unused
;>         wSceneObjects[m] = n
	ld [hl], c
;>         n += 1
	inc c
.unused
;=@n
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@n
	inc hl
	dec b
	jr nz, .number
;>@s for k in range(20):              # bubble the empty records to the end
	ld c, $14
.pass
;>@t     for m in range(19):
	ld hl, wMonsters
	ld b, $13
.slot
;>         if wMonsters[m * 0x95] == 0:
	ld a, [hl]
	or a
;>             SwapWithNextMonster(m)
	call z, SwapWithNextMonster
;=@t
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@t
	dec b
	jr nz, .slot
;=@s
	dec c
	jr nz, .pass
;>@r for i in range(3):               # the party follows its monsters
;>@r     wParty[i] = RemapMonsterIndex(wParty[i])
	ld a, [wParty]
	call RemapMonsterIndex
	ld [wParty], a
;=@r
	ld a, [$ca8f]
	call RemapMonsterIndex
	ld [$ca8f], a
;=@r
	ld a, [$ca90]
	call RemapMonsterIndex
	ld [$ca90], a
;>@c n = 0
	ld hl, wParty
	ld b, $03
	ld c, $00
;>@c for i in range(3):
.count
;>     if wParty[i] != 0xFF:
	ld a, [hli]
	cp $ff
	jr z, .empty
;>         n += 1
	inc c
.empty
;=@c
	dec b
	jr nz, .count
;> wPartyCount = n
	ld a, c
	ld [wPartyCount], a
;> PruneLearnableSkills()
	ld hl, far_PruneLearnableSkills
	rst $10
;> return
	ret


;@ def MarkInParty(m: a)
;@ path: monster/party
;@ Marks monster m (unless $FF) as being in the party.
;@ test: skip writes a monster record
MarkInParty::
;> if m == 0xFF:
	cp $ff
;>     return
	ret z
;> MonsterField(m, wMonsters)[0] = 2
	ld hl, wMonsters
	call MonsterField
	ld [hl], $02
;> return
	ret


;@ def SwapWithNextMonster(p: hl)
;@ path: monster/party
;@ Swaps the empty record at p with the next one (all $95 bytes), if that one is used.
;@ test: skip moves monster records
SwapWithNextMonster::
;>@q q = p + 0x95
	push bc
	push hl
	ld e, l
	ld d, h
	ld a, e
	add $95
;=@q
	ld e, a
	ld a, d
	adc $00
	ld d, a
;> if mem[q]:
	ld a, [de]
	or a
	jr z, .done
;>@sw     for i in range(0x95):
	ld b, $95
.swap
;>         mem[p + i], mem[q + i] = mem[q + i], mem[p + i]
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
;=@sw
	inc de
	dec b
	jr nz, .swap
.done
;> return
	pop hl
	pop bc
	ret


;@ def RemapMonsterIndex(m: a) -> a
;@ path: monster/party
;@ New index of monster m after CompactMonsters' sort ($FF stays $FF).
;@ test: skip reads the CompactMonsters scratch table
RemapMonsterIndex::
;> if m == 0xFF:
	cp $ff
;>     return 0xFF
	ret z
;>@rm return wSceneObjects[m]
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@rm
	ld a, [hl]
	ret


;@ def SortPartyOrClearIcons()
;@ path: monster/party
;@ With a party: puts the fainted members last. Without one: clears the 16 bytes of
;@ party icon tiles at $8DC0.
;@ test: skip writes VRAM
SortPartyOrClearIcons::
;> if wPartyCount:
	ld a, [wPartyCount]
	or a
;>     return SortPartyFaintedLast()
	jr nz, SortPartyFaintedLast
;> return RefreshPartyGfx()        # no party: that clears the icon tiles
	jr RefreshPartyGfx.clearIcons

	db $c9

;@ def RefreshPartyGfx()
;@ path: monster/party
;@ With a party: puts the fainted members last and loads the party's sprites and family
;@ icons. Without one: clears the 16 bytes of party icon tiles at $8DC0.
;@ test: skip writes VRAM
RefreshPartyGfx::
;> if wPartyCount:
	ld a, [wPartyCount]
	or a
	jr nz, .party
;>@pg     SortPartyFaintedLast()
;>@pg     LoadPartyGfx()
;>@pg     return
;> for i in range(16):             # no party: clear the icon tiles
.clearIcons
	ld hl, $8dc0
	ld b, $10
.clear
;>     WriteVRAMInc(0xFF)
	ld a, $ff
	call WriteVRAMInc
	dec b
	jr nz, .clear
;> return
	ret


.party
;=@pg
	call SortPartyFaintedLast
	call LoadPartyGfx
	ret


;@ def SortPartyFaintedLast()
;@ path: monster/party
;@ Reorders the party so the members still standing come first and the fainted ones
;@ (condition bit 7) last; a fainted member's condition is set to exactly $80.
;@ test: skip reads monster records through the party helpers
SortPartyFaintedLast::
;> fill(wNumberBackup, 4, 0xFF)    # the new order
	ld hl, wNumberBackup
	ld bc, $0004
	ld a, $ff
	call FillMemory
;> out = 0
;> if wPartyCount:
	ld a, [wPartyCount]
	or a
	jr z, .fainted
;>@u     for i in range(wPartyCount):    # members standing
;>@v         if not GetPartyMonsterByte(i, wMonStatus) & 0x80:
	ld hl, wNumberBackup
	push hl
	ld a, $00
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop hl
;=@v
	bit 7, a
	jr nz, .alive1
;>@w             wNumberBackup[out] = wParty[i]
;>@w             out += 1
	ld a, [wParty]
	ld [hli], a
.alive1
;=@u
	ld a, [wPartyCount]
	cp $01
	jr z, .fainted
;=@v
	push hl
	ld a, $01
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop hl
;=@v
	bit 7, a
	jr nz, .alive2
;=@w
	ld a, [$ca8f]
	ld [hli], a
.alive2
;=@u
	ld a, [wPartyCount]
	cp $02
	jr z, .fainted
;=@v
	push hl
	ld a, $02
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop hl
;=@v
	bit 7, a
	jr nz, .fainted
;=@w
	ld a, [$ca90]
	ld [hli], a

.fainted
;> if wPartyCount:
	ld a, [wPartyCount]
	or a
	jr z, .store
;>@x     for i in range(wPartyCount):    # then the fainted ones
;>@y         if GetPartyMonsterByte(i, wMonStatus) & 0x80:
	push hl
	ld a, $00
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop hl
;=@y
	bit 7, a
	jr z, .down1
;>@z             wNumberBackup[out] = wParty[i]
;>@z             out += 1
	ld a, [wParty]
	ld [hli], a
;>@q             PartyMonsterField(i, wMonStatus)[0] = 0x80
	push hl
	ld a, $00
	ld hl, wMonStatus
	call PartyMonsterField
	ld [hl], $80
	pop hl
.down1
;=@x
	ld a, [wPartyCount]
	cp $01
	jr z, .store
;=@y
	push hl
	ld a, $01
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop hl
;=@y
	bit 7, a
	jr z, .down2
;=@z
	ld a, [$ca8f]
	ld [hli], a
;=@q
	push hl
	ld a, $01
	ld hl, wMonStatus
	call PartyMonsterField
	ld [hl], $80
	pop hl
.down2
;=@x
	ld a, [wPartyCount]
	cp $02
	jr z, .store
;=@y
	push hl
	ld a, $02
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop hl
;=@y
	bit 7, a
	jr z, .store
;=@z
	ld a, [$ca90]
	ld [hli], a
;=@q
	push hl
	ld a, $02
	ld hl, wMonStatus
	call PartyMonsterField
	ld [hl], $80
	pop hl

.store
;> wParty[0] = wNumberBackup[0]
	ld a, [wNumberBackup]
	ld [wParty], a
;> wParty[1] = wNumberBackup[1]
	ld a, [$c0a1]
	ld [$ca8f], a
;> wParty[2] = wNumberBackup[2]
	ld a, [$c0a2]
	ld [$ca90], a
;> return
	ret


;@ def LoadPartyGfx()
;@ path: monster/party
;@ Clears the three party icon tiles at $8DA0 and loads, for each party member, its walking
;@ sprite and family icon; remembers each member's sprite number in wPartyGfx.
;@ test: skip decompresses graphics
LoadPartyGfx::
;>@c for i in range(24):              # blank the icon tiles (rows $FF, $00)
	ld hl, $8da0
	ld b, $18
.clear
;>     WriteVRAMInc(0xFF)
	ld a, $ff
	call WriteVRAMInc
;>     WriteVRAMInc(0x00)
	xor a
	call WriteVRAMInc
;=@c
	dec b
	jr nz, .clear
;> if wPartyCount == 0:
	ld a, [wPartyCount]
	or a
;>     return
	ret z
;>@m for i in range(wPartyCount):
;>@m     wCurPartyMember = i
	ld a, $00
	ld [wCurPartyMember], a
;>@g     wPartyGfx[i] = LoadPartyMemberGfx()
	call LoadPartyMemberGfx
	ld [wPartyGfx], a
;=@m
	ld a, [wPartyCount]
	cp $01
	ret z
;=@m
	ld a, $01
	ld [wCurPartyMember], a
;=@g
	call LoadPartyMemberGfx
	ld [$ca92], a
;=@m
	ld a, [wPartyCount]
	cp $02
	ret z
;=@m
	ld a, $02
	ld [wCurPartyMember], a
;=@g
	call LoadPartyMemberGfx
	ld [$ca93], a
;> return
	ret


;@ def LoadPartyMemberGfx() -> a
;@ path: monster/party
;@ Loads the walking sprite of party member wCurPartyMember to $8200 + member * $100 (a
;@ fainted monster shows sprite 1) and its family icon to $8DA0 + member * 16. Returns
;@ the sprite number (species + $10), or 0 for an empty slot.
;@ test: skip decompresses graphics
LoadPartyMemberGfx::
;> if GetCurMonsterByte(wMonsters) == 0:   # empty record
	ld hl, wMonsters
	call GetCurMonsterByte
	or a
;>     return 0
	ret z
;> if GetCurMonsterByte(wMonStatus) & 0x80:
	ld hl, wMonStatus
	call GetCurMonsterByte
	bit 7, a
;>     gfx = 1                     # fainted
	ld a, $01
	jr nz, .load
;> else:
;>     gfx = GetCurMonsterByte(wMonsters + 9) + 0x10   # its species
	ld hl, wMonRecSpecies
	call GetCurMonsterByte
	add $10
.load
;>@g ref = mem16[MonsterGfxRefs + gfx * 2]
	push af
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(MonsterGfxRefs)
;=@g
	ld l, a
	ld a, h
	adc HIGH(MonsterGfxRefs)
	ld h, a
	ld e, [hl]
	inc hl
;=@g
	ld d, [hl]
;> DecompressVRAM(ref, 0x8200 + wCurPartyMember * 0x100)
	ld a, [wCurPartyMember]
	add $82
	ld h, a
	ld l, $00
	call DecompressVRAM
;>@i ref = mem16[FamilyIconRefs + GetCurMonsterByte(wMonsters + 0x0A) * 2]   # its family
	ld hl, wMonFamily
	call GetCurMonsterByte
	add a
	ld hl, FamilyIconRefs
	add l
	ld l, a
;=@i
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
;> DecompressVRAM(ref, 0x8DA0 + wCurPartyMember * 16)
	ld a, [wCurPartyMember]
	swap a
	add $a0
	ld l, a
	ld h, $8d
	call DecompressVRAM
;> return gfx
	pop af
	ret


;@ path: gfx/monsters
;@ Walking sprite of each monster in the field (index = species + $10; 0 and 1-$0F are
;@ Terry-sized and fainted placeholders): 2 bytes each, the graphics entry number and the
;@ bank of the compressed tiles, as Decompress takes them (e = entry, d = bank).
MonsterGfxRefs::
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
	db $30, $3a, $31, $3a, $32, $3a, $33, $3a, $34, $3a, $35, $3a, $36, $3a

;@ path: gfx/monsters
;@ Family icon of each of the 10 monster families (slime, dragon, beast, bird, plant, bug,
;@ devil, zombie, material, boss): graphics entry number and bank, as in MonsterGfxRefs.
FamilyIconRefs::
	db $03, $2e
	db $04, $2e, $05, $2e, $06, $2e, $07, $2e, $08, $2e, $09, $2e, $0a, $2e, $0b, $2e
	db $0c, $2e

;@ def HealAllMonsters()
;@ path: monster/stats
;@ Fully heals every monster the player owns: condition cleared, HP and MP back to their
;@ maximum (record +$4A condition, +$50 HP, +$52 max HP, +$54 MP, +$56 max MP).
;@ test: skip walks all monster records
HealAllMonsters::
;>@m for m in range(20):
	ld hl, wMonsters
	ld b, $14
.monster
;>     r = wMonsters + m * 0x95
	push hl
;>     if mem[r]:
	ld a, [hl]
	or a
	jr z, .next
;>@c         mem[r + 0x4A] = 0       # condition
	ld a, l
	add $4a
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@c
	ld [hl], $00
;>@h         mem16[r + 0x50] = mem16[r + 0x52]   # HP = max HP
	ld a, l
	add $08
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@h
	ld e, l
	ld d, h
	ld a, e
	add $fe
	ld e, a
	ld a, d
;=@h
	adc $ff
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
;=@h
	ld [de], a
;>@p         mem16[r + 0x54] = mem16[r + 0x56]   # MP = max MP
	ld a, l
	add $03
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@p
	ld e, l
	ld d, h
	ld a, e
	add $fe
	ld e, a
	ld a, d
;=@p
	adc $ff
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
;=@p
	ld [de], a
.next
;=@m
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
;=@m
	ld h, a
	dec b
	jr nz, .monster
;> return
	ret


;@ def RunMapEntryEvent()
;@ path: event/scripts
;@ Clears the map's event variables and, unless a script is already running, starts the
;@ map's entry script (script 0 of the map, or of map $70 on a gate floor).
;@ test: skip far call into the script engine
RunMapEntryEvent::
;> if wGameStarted == 0x80:
	ld a, [wGameStarted]
	cp $80
;>     return
	ret z
;> fill(0xD8E9, 0x40, 0)
	ld hl, wMovers
	ld bc, $0040
	xor a
	call FillMemory
;> wShootingStarStage = 0
	xor a
	ld [wShootingStarStage], a
;> mem[0xD9CC] = 0
	ld [$d9cc], a
;> mem16[0xD9DF] = 0
	xor a
	ld [wScriptChoiceRow], a
	ld [wScriptChoice], a
;> if wScriptRunning:
	ld a, [wScriptRunning]
	or a
;>     return
	ret nz
;> if not wOnGateFloor:
	ld a, [wOnGateFloor]
	or a
	jr nz, .gateFloor
;>     wScriptId = 0
	ld a, $00
	ld [wScriptId], a
;>     wScriptMap = wMapId
	ld a, [wMapId]
	ld [wScriptMap], a
;>     StartScript()
	ld hl, far_StartScript
	rst $10
;>     return
	ret

.gateFloor
;> wScriptId = 0
	ld a, $00
	ld [wScriptId], a
;> wScriptMap = 0x70               # the scripts shared by all gate floors
	ld a, $70
	ld [wScriptMap], a
;> StartScript()
	ld hl, far_StartScript
	rst $10
;> return
	ret


;@ def GetMonsterPersonality(m: d) -> d
;@ path: monster/stats
;@ Personality of monster m (0-26) from its three personality bytes (record +$64..+$66):
;@ each byte counts 0 when $C0 or more, 1 when $40-$BF, 2 below $40; the result is
;@ first * 9 + second * 3 + third.
;@ test: skip reads a monster record
GetMonsterPersonality::
;> p = MonsterField(m, wMonsters + 0x64)
	ld a, d
	ld hl, wMonStat64
	call MonsterField
	ld e, l
	ld d, h
;> b = ClassifyPersonalityByte(mem[p]) * 9
	call ClassifyPersonalityByte
	ld a, $09
	call Multiply
	ld b, l
;> p += 1
	ld a, e
	add $01
	ld e, a
	ld a, d
	adc $00
	ld d, a
;> b += ClassifyPersonalityByte(mem[p]) * 3
	call ClassifyPersonalityByte
	ld a, c
	add a
	add c
	add b
	ld b, a
;> p += 2   # (skips one byte: the third value is read from +$67)
	ld a, e
	add $02
	ld e, a
	ld a, d
	adc $00
	ld d, a
;> return b + ClassifyPersonalityByte(mem[p])
	call ClassifyPersonalityByte
	ld a, c
	add b
	ld d, a
	ret


;@ def ClassifyPersonalityByte(p: de) -> c
;@ path: monster/stats
;@ 0 when the byte at p is $C0 or more, 1 when it is $40-$BF, 2 below $40.
;@ test: mem[0xC000] = rng.randrange(256)
;@ test: de = 0xC000
ClassifyPersonalityByte::
;> if mem[p] >= 0xC0:
	ld a, [de]
	ld c, $00
	cp $c0
;>     return 0
	ret nc
;> if mem[p] >= 0x40:
	inc c
	cp $40
;>     return 1
	ret nc
;> return 2
	inc c
	ret


;@ def DebugSetupGame()
;@ path: unused/debug
;@ Debug start (when wDebugSetup is set): a fixed player name, all 20 monster slots filled
;@ with generated monsters, the first three in the party, 87040 gold and items 1-8.
;@ test: skip generates monsters through far calls
DebugSetupGame::
;> wDebugSetup = 0
	xor a
	ld [wDebugSetup], a
;> wPlayerName[0] = 0x6E
	ld a, $6e
	ld [wPlayerName], a
;> wPlayerName[1] = 0x86
	ld a, $86
	ld [$ca43], a
;> wPlayerName[2] = 0x9C
	ld a, $9c
	ld [$ca44], a
;> wPlayerName[3] = 0xF0
	ld a, $f0
	ld [$ca45], a
;> wParty[0] = 0
	ld a, $00
	ld [wParty], a
;> wParty[1] = 1
	ld a, $01
	ld [$ca8f], a
;> wParty[2] = 2
	ld a, $02
	ld [$ca90], a
;>@g for m in range(20):
	ld b, $14
	ld c, $00
.generate
;>     DebugGenerateMonster(m)
	push bc
	ld a, c
	call DebugGenerateMonster
	pop bc
;=@g
	inc c
	dec b
	jr nz, .generate
;> wGold[0] = 0x00                 # $015400 = 87040 gold
	ld a, $00
	ld [wGold], a
;> wGold[1] = 0x54
	ld a, $54
	ld [$ca4c], a
;> wGold[2] = 0x01
	ld a, $01
	ld [$ca4d], a
;>@i for i in range(8):               # items 1 to 8 in the bag
;>@i     wBagItems[i] = i + 1
	ld a, $01
	ld [wBagItems], a
;=@i
	ld a, $02
	ld [$ca52], a
;=@i
	ld a, $03
	ld [$ca53], a
;=@i
	ld a, $04
	ld [$ca54], a
;=@i
	ld a, $05
	ld [$ca55], a
;=@i
	ld a, $06
	ld [$ca56], a
;=@i
	ld a, $07
	ld [$ca57], a
;=@i
	ld a, $08
	ld [$ca58], a
;> return
	ret


;@ def DebugGenerateMonster(m: a)
;@ path: unused/debug
;@ Debug start: creates monster m at a random level 1-64 (bank $14), picks random parent
;@ species (record +$15, +$16), a random name of its family (+$01), two more random names
;@ (+$17, +$20) and names for the parents from their families (+$83, +$8C).
;@ test: skip far calls
DebugGenerateMonster::
;> mem[0xDA14] = m
	push af
	ld [wNewMonSlot], a
;> mem[0xDA12] = (Random() & 0x3F) + 1
	call Random
	ld a, [wRandomHigh]
	and $3f
	inc a
	ld [wNewMonId], a
;> mem[0xDA13] = 0
	xor a
	ld [$da13], a
;> CreateMonster()                  # create the monster
	ld hl, far_CreateMonster
	rst $10
;> wMonSpecies = Random() & 0x7F
	pop af
	push af
	call Random
	and $7f
	ld [wMonSpecies], a
;> SetMonsterByte(m, wMonsters + 0x15, wMonSpecies)   # father's species
	ld hl, wMonParent1
	ld c, a
	pop af
	call SetMonsterByte
;> wMonSpecies = Random() & 0x7F
	push af
	pop af
	push af
	call Random
	and $7f
	ld [wMonSpecies], a
;> SetMonsterByte(m, wMonsters + 0x16, wMonSpecies)   # mother's species
	ld hl, wMonParent2
	ld c, a
	pop af
	call SetMonsterByte
;> family = MonsterField(m, wMonsters + 0x0A)[0]
	push af
	pop af
	push af
	ld hl, wMonFamily
	call MonsterField
	ld a, [hl]
;> GenerateMonsterName(m, wMonName, family)
	ld c, a
	pop af
	ld hl, wMonName
	call GenerateMonsterName
;>@n1 GenerateMonsterName(m, wMonsters + 0x17, Random() & 7)
	push af
	call Random
	ld a, [wRandomHigh]
	and $07
	ld c, a
;=@n1
	pop af
	ld hl, wMonParent1Master
	call GenerateMonsterName
;>@n2 GenerateMonsterName(m, wMonsters + 0x20, Random() & 7)
	push af
	call Random
	ld a, [wRandomHigh]
	and $07
	ld c, a
;=@n2
	pop af
	ld hl, wMonParent2Master
	call GenerateMonsterName
;> wMonSpecies = MonsterField(m, wMonsters + 0x15)[0]
	push af
	ld hl, wMonParent1
	call MonsterField
	ld a, [hl]
	ld [wMonSpecies], a
;> GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;> GenerateMonsterName(m, wMonsters + 0x83, wMonStats)   # named after its family
	ld a, [wMonStats]
	ld c, a
	pop af
	ld hl, wMonParent1Name
	call GenerateMonsterName
;> wMonSpecies = MonsterField(m, wMonsters + 0x16)[0]
	push af
	ld hl, wMonParent2
	call MonsterField
	ld a, [hl]
	ld [wMonSpecies], a
;> GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;> GenerateMonsterName(m, wMonsters + 0x8C, wMonStats)
	ld a, [wMonStats]
	ld c, a
	pop af
	ld hl, wMonParent2Name
	call GenerateMonsterName
;> return
	ret


;@ def SetMonsterByte(m: a, field: hl, value: c)
;@ path: monster/stats
;@ Writes value into a field of monster m's record (hl = the field in record 0).
;@ The bytes after it are an unused word-sized variant (writes bc).
;@ test: skip writes a monster record
SetMonsterByte::
;> MonsterField(m, field)[0] = value
	push af
	call MonsterField
	ld [hl], c
	pop af
;> return
	ret


	db $f5, $cd, $3b, $22, $71, $23, $70, $f1, $c9

;@ def GenerateMonsterName(m: a, field: hl, group: c)
;@ path: monster/stats
;@ Writes a random monster name into a field of monster m's record: one of the 16 names
;@ of the given group (text group 3, entry group * 16 + random 0-15).
;@ test: skip copies text through a far call
GenerateMonsterName::
;> dest = MonsterField(m, field)
	push af
	push bc
	call MonsterField
	ld e, l
	ld d, h
;> n = Random() & 0x0F
	call Random
	ld a, [wRandomHigh]
	and $0f
;> CopySystemText(dest, 0x0300 | group << 4 | n)
	pop bc
	swap c
	or c
	ld l, a
	ld h, $03
	call CopySystemText
;> return
	pop af
	ret


;@ def FieldFrame()
;@ path: field/core
;@ Per-frame routine of the field mode (far entry 1, called from the VBlank handler): during
;@ a map change FieldMapChange runs instead of the normal update.
;@ test: skip runs the whole field frame
FieldFrame::
;> if wMapLoadState:
	ld a, [wMapLoadState]
	or a
;>     return FieldMapChange()
	jp nz, FieldMapChange
;> FieldUpdate()
;> return

;@ def FieldUpdate()
;@ path: field/core
;@ One frame of the field: tile animations, the player (input, movement, the screen-edge
;@ scroll), the map's actors and sprites, the party following Terry, the gate floor's
;@ objects and the play-time clock. The first bytes after the jump are a switched-off
;@ debug pause (Select muted the sound and froze the field); the block after the final
;@ ret is unused debug code (a CPU-load bar drawn with sprites).
;@ test: skip runs the whole field frame
FieldUpdate::
;> # (debug pause skipped)
	jr .update

	db $fa, $46, $c8, $e6, $04, $28, $19, $fa, $aa, $c8, $b7, $20, $0a, $f0, $24, $ea
	db $aa, $c8, $af, $e0, $24, $18, $09, $fa, $aa, $c8, $e0, $24, $af, $ea, $aa, $c8

.update
;> if not wFieldPaused:
	ld a, [wFieldPaused]
	or a
	jr nz, .paused
;>     AnimateMapTiles()
	call AnimateMapTiles
;>     UpdatePlayer()
	call UpdatePlayer
;>     CheckScreenEdge()
	call CheckScreenEdge
.paused
;> far_call(0x04, 0x04)
	ld hl, $0404
	rst $10
;> far_call(0x06, 0x06)
	ld hl, $0606
	rst $10
;> DrawPlayerAndFollowers()
	call DrawPlayerAndFollowers
;> far_call(0x06, 0x01)
	ld hl, $0601
	rst $10
;> DrawFloorObjects()
	call DrawFloorObjects
;> CheckShootingStarEvent()
	call CheckShootingStarEvent
;> if not wFieldPaused:
	ld a, [wFieldPaused]
	or a
	jr nz, .done
;>     TickPlayTime()
	call TickPlayTime
.done
;> return
	ret


	db $fa, $86, $c8, $47, $fa, $88, $c8, $80, $ea, $88, $c8, $fa, $89, $c8, $ce, $00
	db $ea, $89, $c8, $fa, $a4, $c8, $e6, $3f, $20, $17, $fa, $88, $c8, $47, $fa, $89
	db $c8, $cb, $10, $17, $cb, $10, $17, $ea, $87, $c8, $af, $ea, $88, $c8, $ea, $89
	db $c8, $21, $a0, $c0, $fa, $87, $c8, $47, $3e, $91, $90, $4f, $06, $00, $cd, $a1
	db $20, $21, $c3, $ff, $3e, $80, $22, $3e, $00, $22, $3e, $78, $22, $3e, $00, $22
	db $3e, $00, $22, $3e, $00, $22, $3e, $00, $22, $3e, $00, $22, $fa, $a0, $c0, $e0
	db $c9, $21, $01, $04, $d7, $3e, $88, $e0, $c3, $fa, $a1, $c0, $e0, $c9, $21, $01
	db $04, $d7, $3e, $90, $e0, $c3, $fa, $a2, $c0, $e0, $c9, $21, $01, $04, $d7, $c9

;@ def UpdatePlayer()
;@ path: field/player
;@ Counts the field frame, runs down the player's pause (its end also ends the damage
;@ flash), then - unless the field is busy or fading - reads the pad and moves Terry,
;@ animates him, and sorts out overlaps and what happens after a step.
;@ test: skip calls the whole movement code
UpdatePlayer::
;> wFieldTimer += 1
	ld a, [wFieldTimer]
	add $01
	ld [wFieldTimer], a
	ld a, [$c8a7]
	adc $00
	ld [$c8a7], a
;> if wPlayerPause:
	ld a, [wPlayerPause]
	or a
	jr z, .noPause
;>     wPlayerPause -= 1
	dec a
	ld [wPlayerPause], a
;>     if wPlayerPause == 0 and not wFadeState:
	or a
	jr nz, .noPause
	ld a, [wFadeState]
	or a
	jr nz, .noPause
;>         wBGP = 0xD2             # normal palette again after a damage flash
	ld a, $d2
	ld [wBGP], a
.noPause
;>@busy if wFieldFlags & 0x60 or wFadeState:
	ld a, [wFieldFlags]
	bit 5, a
	jr nz, .done
	bit 6, a
	jr nz, .done
;=@busy
	ld a, [wFadeState]
	or a
	jr nz, .done
;>     return
;> if not wPlayerPause:
	ld a, [wPlayerPause]
	or a
	jr nz, .paused
;>     HandlePlayerInput()
	call HandlePlayerInput
;>     MovePlayer()
	call MovePlayer
;>     far_call(0x06, 0x02)        # animate Terry
	ld hl, $0602
	rst $10
.paused
;> ResolvePlayerOverlap()
	call ResolvePlayerOverlap
;> UpdatePlayerAfterMove()
	call UpdatePlayerAfterMove
.done
;> return
	ret


;@ def CheckScreenEdge()
;@ path: field/scroll
;@ The field scrolls a screen at a time: when Terry comes within 7 pixels of a screen
;@ edge (left/top) or past $99 / $79 (right/bottom), the scroll in that direction starts
;@ (wFieldFlags bit 2). Nothing happens during a script, while scrolling or in the other
;@ busy states.
;@ test: wScriptRunning = 0
;@ test: wFieldFlags = rng.choice([0, 0, 0, 4])
;@ test: hPlayerX = rng.randrange(0x400)
;@ test: hScrollX = rng.randrange(0x400)
;@ test: hPlayerY = rng.randrange(0x400)
;@ test: hScrollY = rng.randrange(0x400)
CheckScreenEdge::
;>@bz if wScriptRunning or wFieldFlags & 0x9E:
	ld a, [wScriptRunning]
	or a
	ret nz
	ld a, [wFieldFlags]
	bit 1, a
	ret nz
;=@bz
	bit 7, a
	ret nz
	bit 4, a
	ret nz
	bit 3, a
	ret nz
;=@bz
	bit 2, a
	ret nz
;>     return
;>@dx dx = hPlayerX - hScrollX      # where Terry is on the screen
	ld hl, hScrollX
	ldh a, [hPlayerX]
	sub [hl]
	ld e, a
	inc hl
	ldh a, [$ff93]
;=@dx
	sbc [hl]
;>@l if dx < 7:
;>@lb     wScrollDir = 0              # left
	bit 7, a
	jr nz, .left
;>@r elif dx >= 0x99:
;>@rb     wScrollDir = 1              # right
	or a
	jr nz, .right
;=@l
	ld a, e
	cp $07
	jr c, .left
;=@r
	cp $99
	jr nc, .right
;> else:
;>@dy     dy = hPlayerY - hScrollY
	ld hl, hScrollY
	ldh a, [hPlayerY]
	sub [hl]
	ld e, a
	inc hl
	ldh a, [$ff96]
;=@dy
	sbc [hl]
;>@u     if dy < 7:
;>@ub         wScrollDir = 2          # up
	bit 7, a
	jr nz, .up
;>@d     elif dy >= 0x79:
;>@db         wScrollDir = 3          # down
	or a
	jr nz, .down
;=@u
	ld a, e
	cp $07
	jr c, .up
;=@d
	cp $79
	jr nc, .down
;>     else:
;>         return
	jr .done

.left
;=@lb
	ld a, $00
	ld [wScrollDir], a
	jr .start

.right
;=@rb
	ld a, $01
	ld [wScrollDir], a
	jr .start

.up
;=@ub
	ld a, $02
	ld [wScrollDir], a
	jr .start

.down
;=@db
	ld a, $03
	ld [wScrollDir], a

.start
;> wFieldFlags |= 0x04               # scrolling
	ld hl, wFieldFlags
	set 2, [hl]
;> mem16[0xC91E] = 0                # scroll progress
	xor a
	ld [wScrollStep], a
	ld [wScrollColumn], a
.done
;> return
	ret


;@ def HandlePlayerInput()
;@ path: field/player
;@ Reads the d-pad while Terry stands on a tile: he turns to the pressed direction (a
;@ turn costs a 5-frame pause) or starts walking one tile at speed $C0 (0.75 pixel per
;@ frame) when the next tile is free; a blocked step may leave the map through its edge
;@ and counts as a bump (hPlayerFlags bit 4). Then picks his walking animation, reads the
;@ tile under him, and plays the standing animation (the script pose during a script)
;@ when he does not move. Map tiles test as blocked when GetCollisionAt says $FF.
;@ test: skip drives the animator and the collision code
HandlePlayerInput::
;> if wFieldFlags & 0x04:           # scrolling to the next screen
	ld a, [wFieldFlags]
	bit 2, a
;>     return
	jp nz, .return
;> if not wFieldFlags & 0x01:       # (a pending field event skips to the standing pose)
	bit 0, a
	jp nz, .stand
;>@bz     if wFieldFlags & 0x9A:
	bit 1, a
	jp nz, .return
	bit 7, a
	jp nz, .return
;=@bz
	bit 4, a
	jp nz, .return
	bit 3, a
	jp nz, .return
;>         return
;>     hPlayerFlags &= ~0x10        # no bump yet
	ld hl, hPlayerFlags
	res 4, [hl]
;>     if hPlayerFlags & 0x40:
	ldh a, [hPlayerFlags]
	bit 6, a
;>         return
	jp nz, .return
;>     if not hPlayerFlags & 0x80:
	ldh a, [hPlayerFlags]
	bit 7, a
	jp nz, .stand
;>         idle = False
;>@ok         if not hPlayerFlags & 0x01 and not wScriptRunning and 7 <= hPlayerX - hScrollX < 0x99 and 7 <= hPlayerY - hScrollY < 0x79:
	bit 0, a
	jp nz, .walkAnim
	ld a, [wScriptRunning]
	or a
	jp nz, .walkAnim
;=@ok
	ld hl, hScrollX
	ldh a, [hPlayerX]
	sub [hl]
	ld e, a
	inc hl
	ldh a, [$ff93]
;=@ok
	sbc [hl]
	or a
	jp nz, .walkAnim
	ld a, e
	cp $07
	jp c, .walkAnim
;=@ok
	cp $99
	jp nc, .walkAnim
;=@ok
	ld hl, hScrollY
	ldh a, [hPlayerY]
	sub [hl]
	ld e, a
	inc hl
	ldh a, [$ff96]
;=@ok
	sbc [hl]
	or a
	jp nz, .walkAnim
	ld a, e
	cp $07
	jp c, .walkAnim
;=@ok
	cp $79
	jp nc, .walkAnim
;>             speed = 0xC0
	ld hl, $00c0
;>             if wJoyHeld & 0x10:      # Right
	ld a, [wJoyHeld]
	bit 4, a
	jr z, .notRight
;>                 hPlayerAttr = 0
	ld a, $00
	ldh [hPlayerAttr], a
;>                 hPlayerPose = 1      # side view
	ld a, $01
	ldh [hPlayerPose], a
;>                 ForceBackViewOnMap18()
	call ForceBackViewOnMap18
;>                 old = hPlayerDir
	ldh a, [hPlayerDir]
	push af
;>                 hPlayerDir = 3
	ld a, $03
	ldh [hPlayerDir], a
;>                 if old != 3:         # only turning around this time
	pop af
	cp $03
	jr z, .goRight
;>                     hPlayerSpeedX = 0
	xor a
	ldh [hPlayerSpeedX], a
	ldh [$ffa2], a
;>                     wPlayerPause = 5
	ld a, $05
	ld [wPlayerPause], a
	jp .walkAnim

;>                 else:
.goRight
;>                     hPlayerSpeedX = speed
	ld a, l
	ldh [hPlayerSpeedX], a
	ld a, h
	ldh [$ffa2], a
;>                     if hPlayerY & 0x0F != 8:   # not lined up with the tile row
	ldh a, [hPlayerY]
	and $0f
	cp $08
;>                         blocked = True
	jr nz, .blockedRight
;>                     else:
;>@bx                         hTestX = hPlayerX + 16
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	add $10
;=@bx
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@bx
	ld a, h
	ldh [$ffa6], a
;>                         hTestY = hPlayerY
	ldh a, [hPlayerY]
	ldh [hTestY], a
	ldh a, [$ff96]
	ldh [$ffa8], a
;>                         GetCollisionAt()
	call GetCollisionAt
;>                         blocked = hTestResult == 0xFF
	ldh a, [hTestResult]
	cp $ff
	jp nz, .walkAnim
;>                     if blocked:
.blockedRight
;>                         hPlayerSpeedX = 0
	xor a
	ldh [hPlayerSpeedX], a
	ldh [$ffa2], a
;>                         ExitMapEast()   # at the map's edge this leaves the map
	call ExitMapEast
;>                         hPlayerFlags |= 0x10
	ld hl, hPlayerFlags
	set 4, [hl]
	jp .walkAnim

;>             elif wJoyHeld & 0x20:    # Left
.notRight
	ld a, [wJoyHeld]
	bit 5, a
	jr z, .notLeft
;>@neg                 speed = -speed
	ld a, l
	cpl
	add $01
	ld l, a
	ld a, h
	cpl
;=@neg
	adc $00
	ld h, a
;>                 hPlayerAttr = 0x20   # mirrored side view
	ld a, $20
	ldh [hPlayerAttr], a
;>                 hPlayerPose = 1
	ld a, $01
	ldh [hPlayerPose], a
;>                 ForceBackViewOnMap18()
	call ForceBackViewOnMap18
;>                 old = hPlayerDir
	ldh a, [hPlayerDir]
	push af
;>                 hPlayerDir = 1
	ld a, $01
	ldh [hPlayerDir], a
;>                 if old != 1:
	pop af
	cp $01
	jr z, .goLeft
;>                     hPlayerSpeedX = 0
	xor a
	ldh [hPlayerSpeedX], a
	ldh [$ffa2], a
;>                     wPlayerPause = 5
	ld a, $05
	ld [wPlayerPause], a
	jp .walkAnim

;>                 else:
.goLeft
;>                     hPlayerSpeedX = speed
	ld a, l
	ldh [hPlayerSpeedX], a
	ld a, h
	ldh [$ffa2], a
;>                     if hPlayerY & 0x0F != 8:
	ldh a, [hPlayerY]
	and $0f
	cp $08
;>                         blocked = True
	jr nz, .blockedLeft
;>                     else:
;>@cx                         hTestX = hPlayerX - 16
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	sub $10
;=@cx
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@cx
	ld a, h
	ldh [$ffa6], a
;>                         hTestY = hPlayerY
	ldh a, [hPlayerY]
	ldh [hTestY], a
	ldh a, [$ff96]
	ldh [$ffa8], a
;>                         GetCollisionAt()
	call GetCollisionAt
;>                         blocked = hTestResult == 0xFF
	ldh a, [hTestResult]
	cp $ff
	jp nz, .walkAnim
;>                     if blocked:
.blockedLeft
;>                         hPlayerSpeedX = 0
	xor a
	ldh [hPlayerSpeedX], a
	ldh [$ffa2], a
;>                         ExitMapWest()
	call ExitMapWest
;>                         hPlayerFlags |= 0x10
	ld hl, hPlayerFlags
	set 4, [hl]
	jp .walkAnim

;>             elif wJoyHeld & 0x80:    # Down
.notLeft
	ld hl, $00c0
	ld a, [wJoyHeld]
	bit 7, a
	jp z, .notDown
;>                 hPlayerAttr = 0
	ld a, $00
	ldh [hPlayerAttr], a
;>                 hPlayerPose = 0      # front view
	ld a, $00
	ldh [hPlayerPose], a
;>                 ForceBackViewOnMap18()
	call ForceBackViewOnMap18
;>                 old = hPlayerDir
	ldh a, [hPlayerDir]
	push af
;>                 hPlayerDir = 0
	ld a, $00
	ldh [hPlayerDir], a
;>                 if old != 0:
	pop af
	cp $00
	jr z, .goDown
;>                     hPlayerSpeedY = 0
	xor a
	ldh [hPlayerSpeedY], a
	ldh [$ffa4], a
;>                     wPlayerPause = 5
	ld a, $05
	ld [wPlayerPause], a
	jp .walkAnim

;>                 else:
.goDown
;>                     hPlayerSpeedY = speed
	ld a, l
	ldh [hPlayerSpeedY], a
	ld a, h
	ldh [$ffa4], a
;>@dy                     hTestY = ((hPlayerY - 8) & ~0x0F) + 0x18   # centre of the tile below
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	sub $08
;=@dy
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	and $f0
;=@dy
	ld l, a
	ld a, l
	add $18
	ld l, a
	ld a, h
	adc $00
;=@dy
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
;>                     hTestX = hPlayerX
	ldh a, [hPlayerX]
	ldh [hTestX], a
	ldh a, [$ff93]
	ldh [$ffa6], a
;>                     GetCollisionAt()
	call GetCollisionAt
;>                     if hTestResult == 0xFF:
	ldh a, [hTestResult]
	cp $ff
	jp nz, .walkAnim
;>                         hPlayerSpeedY = 0
	xor a
	ldh [hPlayerSpeedY], a
	ldh [$ffa4], a
;>                         ExitMapSouth()
	call ExitMapSouth
;>                         hPlayerFlags |= 0x10
	ld hl, hPlayerFlags
	set 4, [hl]
	jr .walkAnim

;>             elif wJoyHeld & 0x40:    # Up
.notDown
	ld a, [wJoyHeld]
	bit 6, a
	jp z, .probe
;>@neg2                 speed = -speed
	ld a, l
	cpl
	add $01
	ld l, a
	ld a, h
	cpl
;=@neg2
	adc $00
	ld h, a
;>                 hPlayerAttr = 0
	ld a, $00
	ldh [hPlayerAttr], a
;>                 hPlayerPose = 2      # back view
	ld a, $02
	ldh [hPlayerPose], a
;>                 old = hPlayerDir
	ldh a, [hPlayerDir]
	push af
;>                 hPlayerDir = 2
	ld a, $02
	ldh [hPlayerDir], a
;>                 if old != 2:
	pop af
	cp $02
	jr z, .goUp
;>                     hPlayerSpeedY = 0
	xor a
	ldh [hPlayerSpeedY], a
	ldh [$ffa4], a
;>                     wPlayerPause = 5
	ld a, $05
	ld [wPlayerPause], a
	jp .walkAnim

;>                 else:
.goUp
;>                     hPlayerSpeedY = speed
	ld a, l
	ldh [hPlayerSpeedY], a
	ld a, h
	ldh [$ffa4], a
;>@uy                     hTestY = hPlayerY - 16
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	sub $10
;=@uy
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [hTestY], a
;=@uy
	ld a, h
	ldh [$ffa8], a
;>                     hTestX = hPlayerX
	ldh a, [hPlayerX]
	ldh [hTestX], a
	ldh a, [$ff93]
	ldh [$ffa6], a
;>                     GetCollisionAt()
	call GetCollisionAt
;>                     if hTestResult == 0xFF:
	ldh a, [hTestResult]
	cp $ff
	jr nz, .walkAnim
;>                         hPlayerSpeedY = 0
	xor a
	ldh [hPlayerSpeedY], a
	ldh [$ffa4], a
;>                         ExitMapNorth()
	call ExitMapNorth
;>                         hPlayerFlags |= 0x10
	ld hl, hPlayerFlags
	set 4, [hl]
	jr .walkAnim
;>             else:
;>                 idle = True          # no direction held

.walkAnim
;>         if not idle and not hPlayerFlags & 0x02:   # (a conveyor keeps the pose)
	ldh a, [hPlayerFlags]
	bit 1, a
	jr nz, .probe
;>             anim = hPlayerPose + 3   # walking animation of this pose
	ldh a, [hPlayerPose]
	add $03
	ld b, a
;>             if wPlayerAnim != anim:
	ld a, [wPlayerAnim]
	cp b
	jr z, .walkSame
;>                 wPlayerAnim = anim
	ld a, b
	ld [wPlayerAnim], a
;>                 wPlayerAnimFrame = 0
	xor a
	ld [wPlayerAnimFrame], a
;>                 wPlayerAnimStep = 0
	ld [wPlayerAnimStep], a
;>                 wPlayerAnimTimer = 0
	ld [wPlayerAnimTimer], a
.walkSame
;>             wPlayerAnimPtr = wPlayerAnimTimer
	ld hl, wPlayerAnimTimer
	ld a, l
	ld [wPlayerAnimPtr], a
	ld a, h
	ld [$d7b5], a
;>             wPlayerAnimGfx = hPlayerGfx
	ldh a, [hPlayerGfx]
	ld [wPlayerAnimGfx], a
;>             StepAnimation()
	ld hl, far_StepAnimation
	rst $10
;>             hPlayerFrame = wPlayerAnimFrame
	ld a, [wPlayerAnimFrame]
	ldh [hPlayerFrame], a

.probe
;>         hTestX = hPlayerX            # look at the tile under Terry
	ldh a, [hPlayerX]
	ldh [hTestX], a
	ldh a, [$ff93]
	ldh [$ffa6], a
;>         hTestY = hPlayerY
	ldh a, [hPlayerY]
	ldh [hTestY], a
	ldh a, [$ff96]
	ldh [$ffa8], a
;>         GetCollisionAt()
	call GetCollisionAt

.stand
;> if hPlayerFlags & 0x01:            # still walking
	ldh a, [hPlayerFlags]
	bit 0, a
;>     return
	jp nz, .return
;> if not wScriptRunning and wJoyHeld & 0xF0:
	ld a, [wScriptRunning]
	or a
	jp nz, .standAnim
	ld a, [wJoyHeld]
	and $f0
;>     return
	jr nz, .return
.standAnim
;>@an anim = hPlayerPose + (6 if wScriptRunning else 0)   # standing, or the script pose
	ld c, $00
	ld a, [wScriptRunning]
	or a
	jr z, .noScript
	ld c, $06
.noScript
;=@an
	ldh a, [hPlayerPose]
	add c
	ld b, a
;> if wPlayerAnim != anim:
	ld a, [wPlayerAnim]
	cp b
	jr z, .standSame
;>     wPlayerAnim = anim
	ld a, b
	ld [wPlayerAnim], a
;>     wPlayerAnimFrame = 0
	xor a
	ld [wPlayerAnimFrame], a
;>     wPlayerAnimStep = 0
	ld [wPlayerAnimStep], a
;>     wPlayerAnimTimer = 0
	ld [wPlayerAnimTimer], a
.standSame
;> wPlayerAnimPtr = wPlayerAnimTimer
	ld hl, wPlayerAnimTimer
	ld a, l
	ld [wPlayerAnimPtr], a
	ld a, h
	ld [$d7b5], a
;> wPlayerAnimGfx = hPlayerGfx
	ldh a, [hPlayerGfx]
	ld [wPlayerAnimGfx], a
;> StepAnimation()
	ld hl, far_StepAnimation
	rst $10
;> if wPlayerAnimTimer:
	ld a, [wPlayerAnimTimer]
	or a
	jr z, .return
;>     hPlayerFrame = wPlayerAnimFrame
	ld a, [wPlayerAnimFrame]
	ldh [hPlayerFrame], a

.return
;> return
	ret


;@ def ForceBackViewOnMap18()
;@ path: field/player
;@ On map $18, in the strip above Y $90, Terry is always drawn from behind (pose 2).
;@ test: wOnGateFloor = rng.choice([0, 0, 1])
;@ test: wMapId = rng.choice([0x18, 0x18, 0x10])
ForceBackViewOnMap18::
;> if wOnGateFloor or wMapId != 0x18:
	ld a, [wOnGateFloor]
	or a
	ret nz
	ld a, [wMapId]
	cp $18
	ret nz
;>     return
;>@y if hPlayerY >= 0x90:
	ldh a, [hPlayerY]
	ld e, a
	ldh a, [$ff96]
	ld d, a
	ld a, e
	sub $90
;=@y
	ld e, a
	ld a, d
	sbc $00
	ld d, a
;>     return
	ret nc
;> hPlayerAttr = 0
	ld a, $00
	ldh [hPlayerAttr], a
;> hPlayerPose = 2
	ld a, $02
	ldh [hPlayerPose], a
;> return
	ret


;@ def MovePlayer()
;@ path: field/player
;@ Moves Terry by his speed. While the screen scrolls the trail gets two extra entries per
;@ frame and he moves twice (the party catches up), the second time in ApplyPlayerSpeed.
;@ test: skip moves the player through the scroll code
MovePlayer::
;> if wFieldFlags & 0x04:
	ld a, [wFieldFlags]
	bit 2, a
	jr z, ApplyPlayerSpeed
;>     RecordTrailPosition()
	call RecordTrailPosition
;>     RecordTrailPosition()
	call RecordTrailPosition
;>     ApplyPlayerSpeed()
	call ApplyPlayerSpeed
;> return ApplyPlayerSpeed()

;@ def ApplyPlayerSpeed()
;@ path: field/player
;@ Moves Terry by his speed (X before Y; positions are 16.8 fixed point with the fraction
;@ byte first), keeps him 8 pixels inside the map, and once he reaches a tile centre stops
;@ him. Arriving on a new tile runs everything a step triggers: floor objects, events,
;@ wildness, poison, damage floors, fainting and conveyors.
;@ test: skip runs the step handlers
ApplyPlayerSpeed::
;> if hPlayerSpeedX:
	ld hl, hPlayerSpeedX
	ld a, [hli]
	or [hl]
	jr z, .noX
;>@sx     mem24[hPlayerXSub] += sign16(hPlayerSpeedX)   # X with its fraction
	ld b, $00
	ldh a, [$ffa2]
	bit 7, a
	jr z, .xPos
	dec b
.xPos
;=@sx
	ld hl, hPlayerXSub
	ldh a, [hPlayerSpeedX]
	add [hl]
	ld [hli], a
	ldh a, [$ffa2]
	adc [hl]
;=@sx
	ld [hli], a
	ld a, b
	adc [hl]
	ld [hl], a
;>     hPlayerFlags |= 0x01         # moving
	ld hl, hPlayerFlags
	set 0, [hl]
	jr .clamp

;> elif hPlayerSpeedY:
.noX
	ld hl, hPlayerSpeedY
	ld a, [hli]
	or [hl]
	jr z, .clamp
;>@sy     mem24[hPlayerYSub] += sign16(hPlayerSpeedY)
	ld b, $00
	ldh a, [$ffa4]
	bit 7, a
	jr z, .yPos
	dec b
.yPos
;=@sy
	ld hl, hPlayerYSub
	ldh a, [hPlayerSpeedY]
	add [hl]
	ld [hli], a
	ldh a, [$ffa4]
	adc [hl]
;=@sy
	ld [hli], a
	ld a, b
	adc [hl]
	ld [hl], a
;>     hPlayerFlags |= 0x01
	ld hl, hPlayerFlags
	set 0, [hl]

.clamp
;> if hPlayerX < 8:
	ldh a, [$ff93]
	or a
	jr nz, .xNotLow
	ldh a, [hPlayerX]
	cp $08
	jr nc, .xNotLow
;>     hPlayerXSub = 0
	ld a, $00
	ldh [hPlayerXSub], a
;>     hPlayerX = 8
	ld a, $08
	ldh [hPlayerX], a
	ld a, $00
	ldh [$ff93], a
	jr .clampY

;>@xh elif hPlayerX >= hMapWidth - 8:
.xNotLow
	ldh a, [hMapWidth]
	ld l, a
	ldh a, [$ff9e]
	ld h, a
	ld a, l
	sub $08
;=@xh
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ldh a, [$ff93]
	cp h
;=@xh
	jr c, .clampY
	ldh a, [hPlayerX]
	cp l
	jr c, .clampY
;>     hPlayerXSub = 0
	ld a, $00
	ldh [hPlayerXSub], a
;>     hPlayerX = hMapWidth - 8
	ld a, l
	ldh [hPlayerX], a
	ld a, h
	ldh [$ff93], a

.clampY
;> if hPlayerY < 8:
	ldh a, [$ff96]
	or a
	jr nz, .yNotLow
	ldh a, [hPlayerY]
	cp $08
	jr nc, .yNotLow
;>     hPlayerYSub = 0
	ld a, $00
	ldh [hPlayerYSub], a
;>     hPlayerY = 8
	ld a, $08
	ldh [hPlayerY], a
	ld a, $00
	ldh [$ff96], a
	jr .arrived

;>@yh elif hPlayerY >= hMapHeight - 8:
.yNotLow
	ldh a, [hMapHeight]
	ld l, a
	ldh a, [$ffa0]
	ld h, a
	ld a, l
	sub $08
;=@yh
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ldh a, [$ff96]
	cp h
;=@yh
	jr c, .arrived
	ldh a, [hPlayerY]
	cp l
	jr c, .arrived
;>     hPlayerYSub = 0
	ld a, $00
	ldh [hPlayerYSub], a
;>     hPlayerY = hMapHeight - 8
	ld a, l
	ldh [hPlayerY], a
	ld a, h
	ldh [$ff96], a

.arrived
;> if not hPlayerFlags & 0x01:
	ldh a, [hPlayerFlags]
	bit 0, a
;>     return
	jp z, .done
;> if hPlayerX & 0x0F == 8:          # on a tile centre: stop
	ldh a, [hPlayerX]
	and $0f
	cp $08
	jr nz, .xMid
;>     hPlayerSpeedX = 0
	xor a
	ldh [hPlayerSpeedX], a
	ldh [$ffa2], a
.xMid
;> if hPlayerY & 0x0F == 8:
	ldh a, [hPlayerY]
	and $0f
	cp $08
	jr nz, .yMid
;>     hPlayerSpeedY = 0
	xor a
	ldh [hPlayerSpeedY], a
	ldh [$ffa4], a
.yMid
;>@mv if hPlayerSpeedX or hPlayerSpeedY:
	ld hl, hPlayerSpeedX
	ld a, [hli]
	or [hl]
	jr nz, .done
;=@mv
	ld hl, hPlayerSpeedY
	ld a, [hli]
	or [hl]
	jr nz, .done
;>     return
;> hPlayerFlags &= ~0x01
	ld hl, hPlayerFlags
	res 0, [hl]
;>@tx tx = (hPlayerX >> 4) & 0xFF
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	swap h
	swap l
;=@tx
	ld a, h
	and $f0
	ld h, a
	ld a, l
	and $0f
	or h
;=@tx
	ld b, a
;>@ty ty = (hPlayerY >> 4) & 0xFF
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	swap h
	swap l
;=@ty
	ld a, h
	and $f0
	ld h, a
	ld a, l
	and $0f
	or h
;=@ty
	ld c, a
;> if tx == hPlayerTileX and ty == hPlayerTileY:
	ldh a, [hPlayerTileX]
	cp b
	jr nz, .newTile
	ldh a, [hPlayerTileY]
	cp c
	jr z, .done
;>     return
.newTile
;> hPlayerTileX = tx                 # a new tile: everything a step does
	ld a, b
	ldh [hPlayerTileX], a
;> hPlayerTileY = ty
	ld a, c
	ldh [hPlayerTileY], a
;> CheckStepOnObject()
	call CheckStepOnObject
;> CheckFloorCleared()
	call CheckFloorCleared
;> TickFloorTimer()
	call TickFloorTimer
;> far_call(0x0B, 0x06)
	ld hl, $0b06
	rst $10
;> CheckStepEvent()
	call CheckStepEvent
;> TickMonsterWildness()
	call TickMonsterWildness
;> WalkingConditionTicks()
	call WalkingConditionTicks
;> CheckDamageFloor()
	call CheckDamageFloor
;> CheckPartyFainted()
	call CheckPartyFainted
;> HandleConveyor()
	call HandleConveyor
.done
;> return
	ret


;@ def UpdatePlayerAfterMove()
;@ path: field/player
;@ After the movement code: a moved Terry adds a trail entry, his position becomes the
;@ previous one, the actors keep theirs, and walking into a wall (or overlapping an
;@ object) while the walking animation is at its start plays the bump sound.
;@ test: skip calls the trail code
UpdatePlayerAfterMove::
;>@m if hPlayerX != hPlayerPrevX or hPlayerY != hPlayerPrevY:
	ld hl, hPlayerPrevX
	ldh a, [hPlayerX]
	cp [hl]
	jr nz, .moved
	inc hl
	ldh a, [$ff93]
;=@m
	cp [hl]
	jr nz, .moved
	inc hl
	ldh a, [hPlayerY]
	cp [hl]
	jr nz, .moved
;=@m
	inc hl
	ldh a, [$ff96]
	cp [hl]
	jr z, .same
.moved
;>     RecordTrailPosition()
	call RecordTrailPosition
.same
;> hPlayerPrevX = hPlayerX
	ldh a, [hPlayerX]
	ldh [hPlayerPrevX], a
	ldh a, [$ff93]
	ldh [$ff9a], a
;> hPlayerPrevY = hPlayerY
	ldh a, [hPlayerY]
	ldh [hPlayerPrevY], a
	ldh a, [$ff96]
	ldh [$ff9c], a
;> SaveActorPositions()
	call SaveActorPositions
;>@w if wPlayerAnim not in (3, 4, 5):   # not walking
	ld a, [wPlayerAnim]
	cp $03
	jr z, .walking
	cp $04
	jr z, .walking
;=@w
	cp $05
	jr z, .walking
;>     return
	ret


.walking
;>@b if not hPlayerFlags & 0x20:       # not overlapping an object
	ld hl, hPlayerFlags
	bit 5, [hl]
	jr nz, .bump
;>     if not hPlayerFlags & 0x10:
	bit 4, [hl]
;>         return
	ret z
;>@s     if hPlayerSpeedX or hPlayerSpeedY:   # still on the way
	ld hl, hPlayerSpeedX
	ld a, [hli]
	or [hl]
	ret nz
;=@s
	ld hl, hPlayerSpeedY
	ld a, [hli]
	or [hl]
	ret nz
;>         return
.bump
;>@f if wFadeState or wPlayerAnimTimer or wScriptRunning:
	ld a, [wFadeState]
	or a
	ret nz
	ld a, [wPlayerAnimTimer]
	or a
	ret nz
;=@f
	ld a, [wScriptRunning]
	or a
	ret nz
;>     return
;> QueueSound(0x54)                  # bump
	ld a, $54
	call QueueSound
;> hPlayerXSub = 0x80
	ld a, $80
	ldh [hPlayerXSub], a
;> hPlayerYSub = 0x80
	ldh [hPlayerYSub], a
;> return
	ret


;@ def SaveActorPositions()
;@ path: field/actors
;@ For every field actor (32-byte records, $FF ends the list): the position at +$18..+$1B
;@ is copied to +$1C..+$1F (its position in the previous frame).
;@ test: skip walks the actor list
SaveActorPositions::
;> a = wActors
	ld hl, wActors
.actor
;>@l while mem[a] != 0xFF:
	ld a, [hl]
	cp $ff
	ret z
;>@c     copy(a + 0x1C, a + 0x18, 4)
	push hl
	ld a, l
	add $18
	ld l, a
	ld a, h
	adc $00
;=@c
	ld h, a
	ld e, l
	ld d, h
	inc hl
	inc hl
	inc hl
;=@c
	inc hl
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
;=@c
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hl], a
;>     a += 0x20
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
;=@l
	ld h, a
	jr .actor
;> return

	db $c9

;@ def ExitMapWest()
;@ path: field/map
;@ Blocked while walking left: at the map's left edge (X = 8) Terry leaves the map.
;@ test: skip far call into the map-exit code
ExitMapWest::
;> if hPlayerX != 8:
	ldh a, [$ff93]
	or a
	ret nz
	ldh a, [hPlayerX]
	cp $08
	ret nz
;>     return
;> hPlayerXSub = 0
	ld a, $00
	ldh [hPlayerXSub], a
;> hPlayerX = 8
	ld a, $08
	ldh [hPlayerX], a
	ld a, $00
	ldh [$ff93], a
;> CheckEdgeWarp()                    # leave through the edge
	ld hl, far_CheckEdgeWarp
	rst $10
;> return
	ret


;@ def ExitMapEast()
;@ path: field/map
;@ Blocked while walking right: at the right edge (X = map width - 8) Terry leaves the map.
;@ test: skip far call into the map-exit code
ExitMapEast::
;>@e if hPlayerX != hMapWidth - 8:
	ldh a, [hMapWidth]
	ld l, a
	ldh a, [$ff9e]
	ld h, a
	ld a, l
	sub $08
;=@e
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ldh a, [$ff93]
	cp h
;=@e
	ret c
	ldh a, [hPlayerX]
	cp l
	ret nz
;>     return
;> hPlayerXSub = 0
	ld a, $00
	ldh [hPlayerXSub], a
;> hPlayerX = hMapWidth - 8
	ld a, l
	ldh [hPlayerX], a
	ld a, h
	ldh [$ff93], a
;> CheckEdgeWarp()
	ld hl, far_CheckEdgeWarp
	rst $10
;> return
	ret


;@ def ExitMapNorth()
;@ path: field/map
;@ Blocked while walking up: at the top edge (Y = 8) Terry leaves the map.
;@ test: skip far call into the map-exit code
ExitMapNorth::
;> if hPlayerY != 8:
	ldh a, [$ff96]
	or a
	ret nz
	ldh a, [hPlayerY]
	cp $08
	ret nz
;>     return
;> hPlayerYSub = 0
	ld a, $00
	ldh [hPlayerYSub], a
;> hPlayerY = 8
	ld a, $08
	ldh [hPlayerY], a
	ld a, $00
	ldh [$ff96], a
;> CheckEdgeWarp()
	ld hl, far_CheckEdgeWarp
	rst $10
;> return
	ret


;@ def ExitMapSouth()
;@ path: field/map
;@ Blocked while walking down: at the bottom edge (Y = map height - 8) Terry leaves the map.
;@ test: skip far call into the map-exit code
ExitMapSouth::
;>@s if hPlayerY != hMapHeight - 8:
	ldh a, [hMapHeight]
	ld l, a
	ldh a, [$ffa0]
	ld h, a
	ld a, l
	sub $08
;=@s
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ldh a, [$ff96]
	cp h
;=@s
	ret c
	ldh a, [hPlayerY]
	cp l
	ret nz
;>     return
;> hPlayerYSub = 0
	ld a, $00
	ldh [hPlayerYSub], a
;> hPlayerY = hMapHeight - 8
	ld a, l
	ldh [hPlayerY], a
	ld a, h
	ldh [$ff96], a
;> CheckEdgeWarp()
	ld hl, far_CheckEdgeWarp
	rst $10
;> return
	ret


;@ def IsWorldMap() -> zero
;@ path: field/map
;@ Z set when the current map is one of the world maps where walking has effects on the
;@ party ($53-$59, $61-$64).
;@ test: skip the test harness cannot compare a zero-flag result
IsWorldMap::
;>@w return wMapId in (0x53, 0x61, 0x62, 0x63, 0x64, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59)
	ld a, [wMapId]
	cp $53
	ret z
	cp $61
	ret z
	cp $62
;=@w
	ret z
	cp $63
	ret z
	cp $64
	ret z
;=@w
	cp $54
	ret z
	cp $55
	ret z
	cp $56
	ret z
;=@w
	cp $57
	ret z
	cp $58
	ret z
	cp $59
	ret z
;=@w
	ret


;@ def TickMonsterWildness()
;@ path: monster/wildness
;@ Counts Terry's steps on gate floors and world maps (not while busy): every 100 steps
;@ the party's monsters lose 1 point of wildness (record +$60), every 20 steps the
;@ farm's monsters gain one.
;@ test: skip walks the monster records
TickMonsterWildness::
;> if not wOnGateFloor and not IsWorldMap():
	ld a, [wOnGateFloor]
	or a
	jr nz, .counts
	call IsWorldMap
;>     return
	ret nz
.counts
;>@b if wFadeState or wFieldFlags & 0x45:
	ld a, [wFadeState]
	or a
	ret nz
	ld a, [wFieldFlags]
	bit 6, a
	ret nz
;=@b
	bit 2, a
	ret nz
	bit 0, a
	ret nz
;>     return
;>@t wStepTimer -= 1
	ld a, [wStepTimer]
	ld l, a
	ld a, [$ca3c]
	ld h, a
	dec hl
	ld a, l
;=@t
	ld [wStepTimer], a
	ld a, h
	ld [$ca3c], a
;> if wStepTimer == 0:
	ld a, h
	or l
	jr nz, .farm
;>     wStepTimer = 100
	ld hl, $0064
	ld a, l
	ld [wStepTimer], a
	ld a, h
	ld [$ca3c], a
;>@p     for i in range(3):
;>@p         TamePartyMonster(wParty[i])
	ld a, [wParty]
	call TamePartyMonster
;=@p
	ld a, [$ca8f]
	call TamePartyMonster
;=@p
	ld a, [$ca90]
	call TamePartyMonster

.farm
;>@f wFarmStepTimer -= 1
	ld a, [wFarmStepTimer]
	ld l, a
	ld a, [$ca3e]
	ld h, a
	dec hl
	ld a, l
;=@f
	ld [wFarmStepTimer], a
	ld a, h
	ld [$ca3e], a
;> if wFarmStepTimer == 0:
	ld a, h
	or l
	jr nz, .done
;>     wFarmStepTimer = 20
	ld hl, $0014
	ld a, l
	ld [wFarmStepTimer], a
	ld a, h
	ld [$ca3e], a
;>@m     for m in range(20):
	ld b, $14
	ld c, $00
.monster
;>         WildenFarmMonster(m)
	push bc
	ld a, c
	call WildenFarmMonster
	pop bc
;=@m
	inc c
	dec b
	jr nz, .monster
.done
;> return
	ret


;@ def TamePartyMonster(m: a)
;@ path: monster/wildness
;@ A party monster (status 2, not fainted) loses 1 point of wildness (record +$60).
;@ test: skip reads a monster record
TamePartyMonster::
;> if m == 0xFF:
	cp $ff
;>     return
	ret z
;> r = MonsterField(m, wMonsters)
	ld hl, wMonsters
	call MonsterField
;> if mem[r] != 2:
	ld a, [hl]
	cp $02
;>     return
	ret nz
;>@c if mem[r + 0x4A] & 0x80:          # fainted
	ld a, l
	add $4a
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@c
	bit 7, [hl]
;>     return
	ret nz
;>@w if mem[r + 0x60]:
	ld a, l
	add $16
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@w
	ld a, [hl]
	or a
	ret z
;>     mem[r + 0x60] -= 1
	dec [hl]
;> return
	ret


;@ def WildenFarmMonster(m: a)
;@ path: monster/wildness
;@ A monster at the farm (status 1, not fainted) gains 1 point of wildness, up to 255.
;@ test: skip reads a monster record
WildenFarmMonster::
;> if m == 0xFF:
	cp $ff
;>     return
	ret z
;> r = MonsterField(m, wMonsters)
	ld hl, wMonsters
	call MonsterField
;> if mem[r] != 1:
	ld a, [hl]
	cp $01
;>     return
	ret nz
;>@c if mem[r + 0x4A] & 0x80:
	ld a, l
	add $4a
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@c
	bit 7, [hl]
;>     return
	ret nz
;>@w if mem[r + 0x60] != 0xFF:
	ld a, l
	add $16
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@w
	ld a, [hl]
	cp $ff
	ret z
;>     mem[r + 0x60] += 1
	inc [hl]
;> return
	ret


;@ def CheckStepEvent()
;@ path: event/scripts
;@ Looks for a step trigger at Terry's position (bank $0B). If there is one, runs that
;@ script of the map; a script that asks for it (wScriptRunning bit 1) also queues a
;@ field event with text $FFFF.
;@ test: skip far calls into the trigger and script code
CheckStepEvent::
;>@px hDivisorHigh = hPlayerX        # position to look up (u16 at $FFDB)
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	ldh [hDivisorHigh], a
;=@px
	ld a, h
	ldh [$ffdc], a
;>@py hFindY = hPlayerY
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	ldh [hFindY], a
;=@py
	ld a, h
	ldh [$ffde], a
;> far_call(0x0B, 0x05)           # finds the trigger -> hNumber ($FF = none)
	ld hl, $0b05
	rst $10
;> if hNumber == 0xFF:
	ldh a, [hNumber]
	cp $ff
;>     return
	ret z
;> wScriptId = hNumber
	ld [wScriptId], a
;> wScriptMap = wMapId
	ld a, [wMapId]
	ld [wScriptMap], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> StartScript()                    # run the script
	ld hl, far_StartScript
	rst $10
;> if not wScriptRunning & 0x02:
	ld a, [wScriptRunning]
	or a
	ret z
	bit 1, a
;>     return
	ret z
;> wEventRoutine = 0xFFFF
	ld hl, $ffff
	ld a, l
	ld [wEventRoutine], a
	ld a, h
	ld [$c918], a
;> wFieldFlags |= 0x01
	ld hl, wFieldFlags
	set 0, [hl]
;> wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [$c916], a
;> return
	ret


;@ def RecordTrailPosition()
;@ path: field/party
;@ Writes Terry's position and sprite frame into the next entry of the party trail:
;@ X low, Y low, X high << 4 | Y high, frame | OAM attributes.
;@ test: hPlayerX = rng.randrange(0x400)
;@ test: hPlayerY = rng.randrange(0x400)
;@ test: wTrailPos = rng.randrange(49)
RecordTrailPosition::
;>@p p = wPlayerTrail + wTrailPos * 4
	ld a, [wTrailPos]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld a, l
;=@p
	add LOW(wPlayerTrail)
	ld l, a
	ld a, h
	adc HIGH(wPlayerTrail)
	ld h, a
;> mem[p] = hPlayerX & 0xFF
	ldh a, [hPlayerX]
	ld [hli], a
;> mem[p + 1] = hPlayerY & 0xFF
	ldh a, [hPlayerY]
	ld [hli], a
;> mem[p + 2] = (hPlayerX >> 8) << 4 | (hPlayerY >> 8)
	ldh a, [$ff93]
	swap a
	ld c, a
	ldh a, [$ff96]
	or c
	ld [hli], a
;> mem[p + 3] = hPlayerFrame | hPlayerAttr
	ldh a, [hPlayerFrame]
	ld c, a
	ldh a, [hPlayerAttr]
	or c
	ld [hli], a
;> wTrailPos += 1
	ld a, [wTrailPos]
	inc a
	ld [wTrailPos], a
;> if wTrailPos >= 49:
	cp $31
	ret c
;>     wTrailPos = 0
	xor a
	ld [wTrailPos], a
;> return
	ret


;@ def DrawPlayerAndFollowers()
;@ path: field/party
;@ Draws Terry and the (up to three) party monsters following him: they are drawn at the
;@ trail positions 16, 32 and 48 entries back, with sprite tiles $20, $30 and $40.
;@ $C8ED hides sprites (bit 0 Terry, bits 1-3 the followers); outside scripts and a few
;@ maps it is cleared every frame.
;@ test: skip draws sprites through far calls
DrawPlayerAndFollowers::
;>@k if not wScriptRunning and (wOnGateFloor or wMapId not in (0x06, 0x5D)) and not (mem[0xD92B] == 7 and mem[0xDA09] == 3 and mem[0xC8ED] == 0x0E):
	ld a, [wScriptRunning]
	or a
	jr nz, .keepHidden
	ld a, [wOnGateFloor]
	or a
	jr nz, .show
;=@k
	ld a, [wMapId]
	cp $06
	jr z, .keepHidden
	cp $5d
	jr z, .keepHidden
;=@k
	ld a, [$d92b]
	cp $07
	jr nz, .show
	ld a, [wBattleKind]
	cp $03
	jr nz, .show
;=@k
	ld a, [wHiddenSprites]
	cp $0e
	jr nz, .show
	jr .keepHidden
.show
;>     mem[0xC8ED] = 0
	xor a
	ld [wHiddenSprites], a
.keepHidden
;>@b if mem[0xC8EC] or wFieldFlags & 0x8A or (wFieldFlags & 0x10 and mem[0xC8EF] == 0x0F):
	ld a, [wMenuOverlay]
	or a
	ret nz
	ld a, [wFieldFlags]
	bit 1, a
	ret nz
;=@b
	bit 3, a
	ret nz
	bit 7, a
	ret nz
	bit 4, a
	jr z, .draw
;=@b
	ld a, [wScriptMenu]
	cp $0f
	ret z
;>     return
.draw
;> if hPlayerFlags & 0x40:
	ldh a, [hPlayerFlags]
	bit 6, a
;>     return
	ret nz
;> hSpriteX = hPlayerX
	ld hl, hSpriteX
	ldh a, [hPlayerX]
	ld [hli], a
	ldh a, [$ff93]
	ld [hli], a
;> hSpriteY = hPlayerY + 8
	ldh a, [hPlayerY]
	add $08
	ld [hli], a
	ldh a, [$ff96]
	adc $00
	ld [hli], a
;> hSpriteSet = hPlayerGfx
	ldh a, [hPlayerGfx]
	ld [hli], a
;> hSpriteFrame = hPlayerFrame
	ldh a, [hPlayerFrame]
	ld [hli], a
;> hSpriteTileBase = hPlayerTileBase
	ldh a, [hPlayerTileBase]
	ld [hli], a
;> hSpriteAttr = hPlayerAttr
	ldh a, [hPlayerAttr]
	ld [hl], a
;> if hSpriteFrame == 0xFF:
	ldh a, [hSpriteFrame]
	cp $ff
;>     return
	ret z
;> if not mem[0xC8ED] & 0x01:
	ld a, [wHiddenSprites]
	bit 0, a
	jr nz, .party
;>     DrawActorSprite()                # draw Terry
	ld hl, far_DrawActorSprite
	rst $10
.party
;> if wPartyCount == 0:
	ld a, [wPartyCount]
	cp $00
;>     return
	ret z
;>@f for i in range(wPartyCount):
;>@s     hSpriteSet = wPartyGfx[i]
	ld a, [wPartyGfx]
	ldh [hSpriteSet], a
;>@t     hSpriteTileBase = 0x20 + 0x10 * i
	ld a, $20
	ldh [hSpriteTileBase], a
;>@d     if not mem[0xC8ED] & (2 << i):
;>@e         DrawFollower(16 * (i + 1))   # this far back in the trail
	ld b, $10
	ld a, [wHiddenSprites]
	bit 1, a
	call z, DrawFollower
;=@f
	ld a, [wPartyCount]
	cp $01
	ret z
;=@s
	ld a, [$ca92]
	ldh [hSpriteSet], a
;=@t
	ld a, $30
	ldh [hSpriteTileBase], a
;=@d
	ld b, $20
	ld a, [wHiddenSprites]
	bit 2, a
	call z, DrawFollower
;=@f
	ld a, [wPartyCount]
	cp $02
	ret z
;=@s
	ld a, [$ca93]
	ldh [hSpriteSet], a
;=@t
	ld a, $40
	ldh [hSpriteTileBase], a
;=@d
	ld b, $30
	ld a, [wHiddenSprites]
	bit 3, a
	call z, DrawFollower
;> return
	ret


;@ def DrawFollower(back: b)
;@ path: field/party
;@ Draws a party monster at the trail entry `back` entries behind the newest one (sprite
;@ set and tiles already in hSpriteSet / hSpriteTileBase), stepping in time with Terry.
;@ test: skip draws a sprite through a far call
DrawFollower::
;>@i i = (wTrailPos - back) % 49
	ld a, [wTrailPos]
	sub b
	jr nc, .inRange
	add $31
.inRange
;=@i
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld a, l
	add LOW(wPlayerTrail)
;=@i
	ld l, a
	ld a, h
	adc HIGH(wPlayerTrail)
	ld h, a
	ld e, l
	ld d, h
;> t = wPlayerTrail + i * 4
;>@x hSpriteX = mem[t] | (mem[t + 2] >> 4) << 8
	ld hl, hSpriteX
	ld a, [de]
	ld [hli], a
	inc de
	inc de
	ld a, [de]
;=@x
	swap a
	and $0f
	ld [hli], a
;>@y hSpriteY = mem[t + 1] + 8 + ((mem[t + 2] & 0x0F) << 8)
	dec de
	ld a, [de]
	inc de
	add $08
	ld [hli], a
	ld a, [de]
;=@y
	inc de
	adc $00
	and $0f
	ld [hli], a
;> hSpriteFrame = mem[t + 3] & 0x0F
	inc hl
	ld a, [de]
	and $0f
	ld [hli], a
;> hSpriteAttr = mem[t + 3] & 0xF0
	inc hl
	ld a, [de]
	and $f0
	ld [hli], a
	inc de
;> SyncFollowerStep()
	call SyncFollowerStep
;> DrawActorSprite()
	ld hl, far_DrawActorSprite
	rst $10
;> return
	ret


;@ def SyncFollowerStep()
;@ path: field/party
;@ While Terry stands or walks (animations 0-5), a follower takes his step phase: bit 0 of
;@ its frame becomes bit 0 of Terry's.
;@ test: wPlayerAnim = rng.randrange(8)
SyncFollowerStep::
;>@a if wPlayerAnim > 5:
	ld a, [wPlayerAnim]
	cp $00
	jr z, .sync
	cp $01
	jr z, .sync
;=@a
	cp $02
	jr z, .sync
	cp $03
	jr z, .sync
;=@a
	cp $04
	jr z, .sync
	cp $05
	jr z, .sync
;>     return
	ret


.sync
;>@sy hSpriteFrame = (hSpriteFrame & 0xFE) + (hPlayerFrame & 0x01)
	ldh a, [hSpriteFrame]
	and $fe
	ld b, a
	ldh a, [hPlayerFrame]
	and $01
	add b
;=@sy
	ldh [hSpriteFrame], a
;> return
	ret


;@ def ResolvePlayerOverlap()
;@ path: field/player
;@ Checks Terry against the actors (bank 6) and the floor objects. Overlapping for one
;@ frame puts him and the actors back where they were; overlapping for two frames stops
;@ him on the nearest tile centre and, if he is still stuck there, moves him a tile
;@ down, up or left - whichever is free - or else right until he is clear.
;@ test: skip far calls into the actor code
ResolvePlayerOverlap::
;> CheckActorOverlap()                    # sets hPlayerFlags bit 5 when touching an actor
	ld hl, far_CheckActorOverlap
	rst $10
;> CheckObjectOverlap()
	call CheckObjectOverlap
;> if not hPlayerFlags & 0x20:
	ld hl, hPlayerFlags
	bit 5, [hl]
	jr nz, .overlap
;>     wOverlapTimer = 0
	xor a
	ld [wOverlapTimer], a
;>     return
	ret


.overlap
;> wOverlapTimer += 1
	ld a, [wOverlapTimer]
	inc a
	ld [wOverlapTimer], a
;> if wOverlapTimer != 2:
;>@b1     hPlayerX = hPlayerPrevX   # first frame: undo the move
;>@b2     hPlayerY = hPlayerPrevY
;>@b3     SnapActorsToTiles()       # the actors step back too
;>@b4     return
	cp $02
	jp nz, .backOff
;> wOverlapTimer = 0
	xor a
	ld [wOverlapTimer], a
;> hPlayerSpeedX = 0
	xor a
	ldh [hPlayerSpeedX], a
	ldh [$ffa2], a
;> hPlayerSpeedY = 0
	xor a
	ldh [hPlayerSpeedY], a
	ldh [$ffa4], a
;> hPlayerFlags &= ~0x01
	ld hl, hPlayerFlags
	res 0, [hl]
;> hPlayerX = (hPlayerX & 0xFFF0) + 8   # tile centre
	ldh a, [hPlayerX]
	and $f0
	add $08
	ldh [hPlayerX], a
;> hPlayerY = (hPlayerY & 0xFFF0) + 8
	ldh a, [hPlayerY]
	and $f0
	add $08
	ldh [hPlayerY], a
;> hTestX = hPlayerX
	ldh a, [hPlayerX]
	ldh [hTestX], a
	ldh a, [$ff93]
	ldh [$ffa6], a
;> hTestY = hPlayerY
	ldh a, [hPlayerY]
	ldh [hTestY], a
	ldh a, [$ff96]
	ldh [$ffa8], a
;> GetCollisionAt()
	call GetCollisionAt
;> if hTestResult != 0xFF:           # the tile itself is free
	ldh a, [hTestResult]
	cp $ff
	jr z, .tryBelow
;>     CheckActorOverlap()
	ld hl, far_CheckActorOverlap
	rst $10
;>     if not hPlayerFlags & 0x20:
	ldh a, [hPlayerFlags]
	bit 5, a
;>         return
	ret z
.tryBelow
;>@ty hTestY = hPlayerY + 16
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	add $10
;=@ty
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestY], a
;=@ty
	ld a, h
	ldh [$ffa8], a
;> hTestX = hPlayerX
	ldh a, [hPlayerX]
	ldh [hTestX], a
	ldh a, [$ff93]
	ldh [$ffa6], a
;> GetCollisionAt()
	call GetCollisionAt
;> if hTestResult != 0xFF:           # a tile down
	ldh a, [hTestResult]
	cp $ff
	jr z, .tryAbove
;>@yd     hPlayerY += 16
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	add $10
;=@yd
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hPlayerY], a
;=@yd
	ld a, h
	ldh [$ff96], a
;>     CheckActorOverlap()
	ld hl, far_CheckActorOverlap
	rst $10
;>     if not hPlayerFlags & 0x20:
	ldh a, [hPlayerFlags]
	bit 5, a
;>         return
	ret z
;>@yu     hPlayerY -= 16
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	sub $10
;=@yu
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [hPlayerY], a
;=@yu
	ld a, h
	ldh [$ff96], a
.tryAbove
;>@tu hTestY = hPlayerY - 16
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	sub $10
;=@tu
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [hTestY], a
;=@tu
	ld a, h
	ldh [$ffa8], a
;> hTestX = hPlayerX
	ldh a, [hPlayerX]
	ldh [hTestX], a
	ldh a, [$ff93]
	ldh [$ffa6], a
;> GetCollisionAt()
	call GetCollisionAt
;> if hTestResult != 0xFF:           # a tile up
	ldh a, [hTestResult]
	cp $ff
	jr z, .tryLeft
;>@uu     hPlayerY -= 16
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	sub $10
;=@uu
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [hPlayerY], a
;=@uu
	ld a, h
	ldh [$ff96], a
;>     CheckActorOverlap()
	ld hl, far_CheckActorOverlap
	rst $10
;>     if not hPlayerFlags & 0x20:
	ldh a, [hPlayerFlags]
	bit 5, a
;>         return
	ret z
;>@ud     hPlayerY += 16
	ldh a, [hPlayerY]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	add $10
;=@ud
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hPlayerY], a
;=@ud
	ld a, h
	ldh [$ff96], a
.tryLeft
;>@tl hTestX = hPlayerX - 16
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	sub $10
;=@tl
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@tl
	ld a, h
	ldh [$ffa6], a
;> hTestY = hPlayerY
	ldh a, [hPlayerY]
	ldh [hTestY], a
	ldh a, [$ff96]
	ldh [$ffa8], a
;> GetCollisionAt()
	call GetCollisionAt
;> if hTestResult != 0xFF:           # a tile left
	ldh a, [hTestResult]
	cp $ff
	jr z, .goRight
;>@xl     hPlayerX -= 16
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	sub $10
;=@xl
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [hPlayerX], a
;=@xl
	ld a, h
	ldh [$ff93], a
;>     CheckActorOverlap()
	ld hl, far_CheckActorOverlap
	rst $10
;>     if not hPlayerFlags & 0x20:
	ldh a, [hPlayerFlags]
	bit 5, a
;>         return
	ret z
;>@xr     hPlayerX += 16
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	add $10
;=@xr
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hPlayerX], a
;=@xr
	ld a, h
	ldh [$ff93], a
.goRight
;>@r while True:                     # else walk right until clear
;>@x     hPlayerX += 16
	ldh a, [hPlayerX]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	add $10
;=@x
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hPlayerX], a
;=@x
	ld a, h
	ldh [$ff93], a
;>     CheckActorOverlap()
	ld hl, far_CheckActorOverlap
	rst $10
;>     if not hPlayerFlags & 0x20:
	ldh a, [hPlayerFlags]
	bit 5, a
;=@r
	jr nz, .goRight
;>         return
	ret


	db $af, $ea, $bc, $d7

.backOff
;=@b1
	ldh a, [hPlayerPrevX]
	ldh [hPlayerX], a
	ldh a, [$ff9a]
	ldh [$ff93], a
;=@b2
	ldh a, [hPlayerPrevY]
	ldh [hPlayerY], a
	ldh a, [$ff9c]
	ldh [$ff96], a
;=@b3
	call SnapActorsToTiles
;=@b4
	ret


;@ def SnapActorsToTiles()
;@ path: field/actors
;@ Runs SnapActorToTile for every field actor.
;@ test: skip walks the actor list
SnapActorsToTiles::
;> a = wActors
	ld hl, wActors
.actor
;>@l while mem[a] != 0xFF:
	ld a, [hl]
	cp $ff
	ret z
;>     SnapActorToTile(a)
	call SnapActorToTile
;>     a += 0x20
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@l
	jr .actor
;> return

	db $c9

;@ def SnapActorToTile(a: hl)
;@ path: field/actors
;@ A walking actor (+$05 bit 5) whose previous position (+$1C) was a tile centre goes back
;@ to it (+$18) and waits ($20 into +$07). The bytes after the routine are unused code.
;@ test: skip walks an actor record
SnapActorToTile::
;>@w if mem[a + 0x05] & 0x20:
	push hl
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
;=@w
	ld h, a
	bit 5, [hl]
	jr z, .done
;>@p     if mem[a + 0x1C] & 0x0F == 8 and mem[a + 0x1E] & 0x0F == 8:
	ld a, l
	add $13
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@p
	ld e, l
	ld d, h
	inc hl
	inc hl
	inc hl
	inc hl
;=@p
	ld a, [hli]
	and $0f
	cp $08
	jr nz, .done
;=@p
	inc hl
	ld a, [hld]
	and $0f
	cp $08
	jr nz, .done
;>@c         copy(a + 0x18, a + 0x1C, 4)
	dec hl
	ld a, [hli]
	ld [de], a
	ld c, a
	inc de
	ld a, [hli]
;=@c
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld b, a
	inc de
;=@c
	ld a, [hl]
	ld [de], a
;=@p
	ld a, c
	and $0f
	cp $08
	jr nz, .done
;=@p
	ld a, b
	and $0f
	cp $08
	jr nz, .done
;>@t         mem[a + 0x07] = 0x20
	pop hl
	push hl
	ld a, l
	add $07
	ld l, a
	ld a, h
;=@t
	adc $00
	ld h, a
	ld [hl], $20
.done
;> return
	pop hl
	ret


	db $f0, $8a, $ea, $b7, $d7, $7d, $ea, $b8, $d7, $7c, $ea, $b9, $d7, $21, $b6, $d7
	db $7d, $ea, $b4, $d7, $7c, $ea, $b5, $d7, $af, $ea, $b6, $d7, $21, $00, $02, $d7
	db $fa, $ba, $d7, $e0, $8b, $c9

;@ def CheckObjectOverlap()
;@ path: field/gatefloor
;@ On a gate floor: sets hPlayerFlags bit 5 when Terry is less than a tile away (in both
;@ X and Y) from a solid floor object (flags $08 or more) that is still there (bit 7 clear).
;@ Floor objects: 4 bytes each - flags (bit 7 taken, bit 5 opened, bits 3-6 kind of
;@ chest; below 8 = hidden), content ($FF trap, 0 gold, else an item), tile X, tile Y.
;@ test: skip walks the floor object list
CheckObjectOverlap::
;> if not wOnGateFloor:
	ld a, [wOnGateFloor]
	or a
;>     return
	ret z
;> o = wFloorObjects
	ld hl, wFloorObjects
.object
;>@l while mem[o] != 0xFF:
	ld a, [hl]
	cp $ff
	ret z
;>     if mem[o] & 0xF8 and not mem[o] & 0x80:
	push hl
	and $f8
	jr z, .next
	bit 7, a
	jr nz, .next
;>@x         if TileDistance(o + 2, hPlayerX) < 0 and TileDistance(o + 3, hPlayerY) < 0:
	inc hl
	inc hl
	ld de, hPlayerX
	call TileDistance
	jr nc, .next
	inc hl
;=@x
	ld de, hPlayerY
	call TileDistance
	jr nc, .next
;>             hPlayerFlags |= 0x20
	pop hl
	ld hl, hPlayerFlags
	set 5, [hl]
;>             return
	ret

.next
;>     o += 4
	pop hl
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
;=@l
	ld h, a
	jr .object

;@ def TileDistance(tile: hl, pos: de) -> bc
;@ path: field/gatefloor
;@ Distance between a map position (u16 at de) and the centre of a map tile (byte at hl),
;@ minus 16: negative (carry set) when they are less than a tile apart.
;@ test: mem[0xC000] = rng.randrange(64)
;@ test: mem[0xC002] = rng.randrange(256)
;@ test: mem[0xC003] = rng.randrange(4)
;@ test: tile = 0xC000
;@ test: pos = 0xC002
TileDistance::
;>@c centre = mem[tile] * 16 + 8
	ld a, [hl]
	swap a
	ld b, a
	and $f0
	or $08
	ld c, a
;=@c
	ld a, b
	and $0f
	ld b, a
;>@d d = mem16[pos] - centre
	ld a, [de]
	inc de
	sub c
	ld c, a
	ld a, [de]
	sbc b
;=@d
	ld b, a
;> if d < 0:
	bit 7, b
	jr z, .positive
;>@n     d = -d
	ld a, c
	cpl
	add $01
	ld c, a
	ld a, b
	cpl
;=@n
	adc $00
	ld b, a
.positive
;>@r return u16(d - 16)
	ld a, c
	sub $10
	ld c, a
	ld a, b
	sbc $00
	ld b, a
;=@r
	ret


;@ def CheckFloorCleared()
;@ path: field/gatefloor
;@ On a gate floor: once every object after the first has been taken, asks for floor
;@ event 4.
;@ test: skip walks the floor object list
CheckFloorCleared::
;> if not wOnGateFloor or wFloorObjects[0] == 0xFF:
	ld a, [wOnGateFloor]
	or a
	ret z
	ld a, [wFloorObjects]
	cp $ff
	ret z
;>     return
;> o = wFloorObjects
	ld hl, wFloorObjects
.object
;>@l while True:
;>     o += 4
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>     if not mem[o] & 0x80:         # one is still there
	ld a, [hl]
	bit 7, a
;>         return
	ret z
;>     if mem[o] == 0xFF:
	cp $ff
;=@l
	jr nz, .object
;>         break
;> wFloorEvent = 4
	ld a, $04
	ld [wFloorEvent], a
;> return
	ret


;@ def TickFloorTimer()
;@ path: field/gatefloor
;@ On a gate floor: every 200 steps without touching an object asks for floor event 7.
;@ test: wOnGateFloor = rng.choice([0, 1])
;@ test: wFloorSteps = rng.choice([0, 198, 199, 200])
TickFloorTimer::
;> if not wOnGateFloor:
	ld a, [wOnGateFloor]
	or a
;>     return
	ret z
;> wFloorSteps += 1
	ld a, [wFloorSteps]
	inc a
	ld [wFloorSteps], a
;> if wFloorSteps < 200:
	cp $c8
;>     return
	ret c
;> wFloorSteps = 0
	xor a
	ld [wFloorSteps], a
;> wFloorEvent = 7
	ld a, $07
	ld [wFloorEvent], a
;> return
	ret


;@ def CheckStepOnObject()
;@ path: field/gatefloor
;@ After a step: looks for a floor object (any kind) on Terry's new tile and takes it
;@ (TouchFloorObject).
;@ test: skip see TouchFloorObject
CheckStepOnObject::
;> hDivisorHigh = hPlayerTileX       # tile to look at
	ldh a, [hPlayerTileX]
	ldh [hDivisorHigh], a
;> hFindY = hPlayerTileY
	ldh a, [hPlayerTileY]
	ldh [hFindY], a
;> wFloorObjectItem = 0              # 0: hidden objects count too
	xor a
	ld [wFloorObjectItem], a
;> return TouchFloorObject()

;@ def TouchFloorObject()
;@ path: field/gatefloor
;@ Takes the floor object at tile (hDivisorHigh, hFindY) - with wFloorObjectItem non-zero
;@ only chests count. A chest opens (sound $53). A trap starts field text $0217; gold
;@ (amount by wFloorLoot: 7-19, 40-69, or (table + 10) * (floor + 1) * (50..99) / 100) is
;@ added with text $0215; an item goes into the first free bag slot (text $0208), or
;@ with a full bag the chest stays and text $0211 says so. (The check of the gold total
;@ against 100000 is computed but not used.)
;@ test: skip far calls and text setup
TouchFloorObject::
;> if wFadeState or not wOnGateFloor:
	ld a, [wFadeState]
	or a
	ret nz
	ld a, [wOnGateFloor]
	or a
	ret z
;>     return
;> o = wFloorObjects
	ld hl, wFloorObjects
.object
;>@l while True:
;>     if mem[o] == 0xFF:
	ld a, [hl]
	cp $ff
;>         return
	ret z
;>@k     if not mem[o] & 0x80 and (wFloorObjectItem == 0 or mem[o] & 0x78):
	push hl
	bit 7, a
	jr nz, .next
	ld a, [wFloorObjectItem]
	or a
	jr z, .compare
;=@k
	ld a, [hl]
	and $78
	jr z, .next
.compare
;>@m         if mem[o + 2] == hDivisorHigh and mem[o + 3] == hFindY:
	inc hl
	inc hl
	ldh a, [hDivisorHigh]
	cp [hl]
	jr nz, .next
	inc hl
;=@m
	ldh a, [hFindY]
	cp [hl]
	jr z, .found
;>             break
.next
;>     o += 4
	pop hl
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
;=@l
	ld h, a
	jr .object

.found
;> wFloorSteps = 0
	xor a
	ld [wFloorSteps], a
;> wFloorObjectItem = mem[o + 1]
	pop hl
	inc hl
	ld a, [hl]
	ld [wFloorObjectItem], a
	dec hl
;> if wFloorObjectItem == 0xFF:       # a trap
	cp $ff
;>     pass
	jp z, .take
;> elif wFloorObjectItem == 0:        # gold
	cp $00
	jp nz, .item
;>     SelectFloorTable()
	push hl
	ld hl, far_SelectFloorTable
	rst $10
;>     if wFloorLoot == 1:
	ld a, [wFloorLoot]
	cp $01
	jr nz, .notSmall
;>@g1         wFoundGold = wRandomHigh % 13 + 7
	ld a, [wRandomHigh]
	ld b, a
	ld a, $0d
	call Divide8
	add $07
	ld [wFoundGold], a
;=@g1
	xor a
	ld [$d792], a
	jr .gold
;>     elif wFloorLoot == 2:
.notSmall
	cp $02
	jr nz, .byFloor
;>@g2         wFoundGold = wRandomHigh % 30 + 40
	ld a, [wRandomHigh]
	ld b, a
	ld a, $1e
	call Divide8
	add $28
	ld [wFoundGold], a
;=@g2
	xor a
	ld [$d792], a
	jr .gold
;>     else:
.byFloor
;>@g3         wFoundGold = (wFloorTable + 10) * (wGateFloor + 1) * (wRandomHigh % 50 + 50) // 100
	ld a, [wFloorTable]
	add $0a
	ld c, a
	ld a, [wGateFloor]
	inc a
	call Multiply
;=@g3
	push hl
	ld a, [wRandomHigh]
	ld b, a
	ld a, $32
	call Divide8
	add $32
;=@g3
	pop bc
	call Multiply24
	ld a, $64
	call Divide24
;=@g3
	ld a, l
	ld [wFoundGold], a
	ld a, h
	ld [$d792], a
.gold
;>@cap     total = wGold + wFoundGold    # compared with 100000, result unused
	ld hl, wFoundGold
	ld a, [wGold]
	add [hl]
	ld e, a
	inc hl
	ld a, [$ca4c]
;=@cap
	adc [hl]
	ld d, a
	inc hl
	ld a, [$ca4d]
	adc $00
	ld c, a
;=@cap
	pop hl
	ld a, e
	sub $a0
	ld a, d
	sbc $86
	ld a, c
;=@cap
	sbc $01
	jr .take

;> else:                             # an item
.item
;>@bag     full = all(wBagItems[i] not in (0, 0xFF) for i in range(20))
	ld de, wBagItems
	ld b, $14
.findSlot
	ld a, [de]
	or a
	jr z, .take
;=@bag
	cp $ff
	jr z, .take
	inc de
	dec b
	jr nz, .findSlot
;>     if full:                      # the chest opens but the item stays
;>@f1         if mem[o] & 0x78:
;>@f2             mem[o] |= 0x20
;>@f3             QueueSound(0x53)
;>@f4         wFieldFlags |= 0x01
;>@f5         wEventStep = 0
;>@f6         CopySystemText(0xC180, 0x0800 | wFloorObjectItem)
;>@f7         wEventRoutine = 0x0211    # text: the bag is full
;>@f8         return
	jp .bagFull

.take
;> mem[o] |= 0x80                    # taken
	set 7, [hl]
;> if mem[o] & 0x78:                 # a visible chest: show it open
	ld a, [hl]
	and $78
	jr z, .noChest
;>     mem[o] |= 0x20
	set 5, [hl]
;>     mem[o + 1] = 0x20
	inc hl
	ld [hl], $20
;>     QueueSound(0x53)
	ld a, $53
	call QueueSound
.noChest
;> if wFloorObjectItem == 0xFF:
	ld a, [wFloorObjectItem]
	cp $ff
	jr nz, .notTrap
;>     wFieldFlags |= 0x01
	ld hl, wFieldFlags
	set 0, [hl]
;>     wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [$c916], a
;>     wEventRoutine = 0x0217        # text: a trap
	ld hl, $0217
	ld a, l
	ld [wEventRoutine], a
	ld a, h
	ld [$c918], a
;>     return
	ret


.notTrap
;> if wFloorObjectItem == 0:
	or a
	jr nz, .gotItem
;>     wFieldFlags |= 0x01
	ld hl, wFieldFlags
	set 0, [hl]
;>     wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [$c916], a
;>     hNumber = wFoundGold          # the amount as text
	ld a, [wFoundGold]
	ldh [hNumber], a
	ld a, [$d792]
	ldh [$ffd6], a
	ld a, $00
	ldh [$ffd7], a
;>     Number24ToDecimal(0xC180)
	ld hl, wTextArg0
	call Number24ToDecimal
;>     wEventRoutine = 0x0215        # text: found gold
	ld hl, $0215
	ld a, l
	ld [wEventRoutine], a
	ld a, h
	ld [$c918], a
;>     AddGold(wFoundGold)         # add it to the gold
	ld a, [wFoundGold]
	ld l, a
	ld a, [$d792]
	ld h, a
	ld e, $00
	call AddGold
;>     return
	ret


.gotItem
;> wFieldFlags |= 0x01
	ld hl, wFieldFlags
	set 0, [hl]
;> wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [$c916], a
;> CopySystemText(0xC180, 0x0800 | wFloorObjectItem)   # the item's name
	ld a, [wFloorObjectItem]
	ld l, a
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
;> wEventRoutine = 0x0208             # text: found an item
	ld hl, $0208
	ld a, l
	ld [wEventRoutine], a
	ld a, h
	ld [$c918], a
;>@s for i in range(20):              # into the first free bag slot
	ld hl, wBagItems
	ld b, $14
.slot
;>     if wBagItems[i] in (0, 0xFF):
	ld a, [hl]
	or a
	jr z, .store
	cp $ff
	jr nz, .used
.store
;>         wBagItems[i] = wFloorObjectItem
	ld a, [wFloorObjectItem]
	ld [hl], a
;>         return
	ret


.used
;=@s
	inc hl
	dec b
	jr nz, .slot
;> return
	ret


.bagFull
;=@f1
	ld a, [hl]
	and $78
	jr z, .noChest2
;=@f2
	set 5, [hl]
;=@f3
	ld a, $53
	call QueueSound
.noChest2
;=@f4
	ld hl, wFieldFlags
	set 0, [hl]
;=@f5
	xor a
	ld [wEventStep], a
	ld [$c916], a
;=@f6
	ld a, [wFloorObjectItem]
	ld l, a
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
;=@f7
	ld hl, $0211
	ld a, l
	ld [wEventRoutine], a
	ld a, h
	ld [$c918], a
;=@f8
	ret


	db $7e, $e6, $78, $28, $07, $cb, $ee, $3e, $53, $cd, $2c, $1b, $21, $eb, $c8, $cb
	db $c6, $af, $ea, $15, $c9, $ea, $16, $c9, $fa, $91, $d7, $e0, $d5, $fa, $92, $d7
	db $e0, $d6, $3e, $00, $e0, $d7, $21, $80, $c1, $cd, $c7, $09, $21, $16, $02, $7d
	db $ea, $17, $c9, $7c, $ea, $18, $c9, $c9

;@ def WalkingConditionTicks()
;@ path: monster/walking
;@ Step effects on the party (gate floors and world maps, not while busy): when the step
;@ timer is 1 more than a multiple of 10, every member gains 1 MP; when it is 4 more than
;@ a multiple of 5, every poisoned member loses 1 HP. The status display is refreshed.
;@ test: skip changes HP / MP through the party helpers
WalkingConditionTicks::
;> if not wOnGateFloor and not IsWorldMap():
	ld a, [wOnGateFloor]
	or a
	jr nz, .counts
	call IsWorldMap
;>     return
	ret nz
.counts
;>@b if wFadeState or wFieldFlags & 0x65:
	ld a, [wFadeState]
	or a
	ret nz
	ld a, [wFieldFlags]
	bit 5, a
	ret nz
;=@b
	bit 6, a
	ret nz
	bit 2, a
	ret nz
	bit 0, a
	ret nz
;>     return
;>@t if wStepTimer % 10 == 1:
	ld a, [wStepTimer]
	ld l, a
	ld a, [$ca3c]
	ld h, a
	ld a, $0a
	call Divide16
;=@t
	cp $01
	jr nz, .poison
;>@f     for i in range(3):
;>@r         RegainPartyMemberMP(i)  # +1 MP
	ld hl, $0001
	ld a, $00
	call RegainPartyMemberMP
;=@r
	ld a, $01
	call RegainPartyMemberMP
;=@r
	ld a, $02
	call RegainPartyMemberMP
;>     BuildStatusBar()
	call BuildStatusBar
;>     DrawStatusBar()
	call DrawStatusBar
.poison
;>@p if wStepTimer % 5 == 4:
	ld a, [wStepTimer]
	ld l, a
	ld a, [$ca3c]
	ld h, a
	ld a, $05
	call Divide16
;=@p
	cp $04
	jr nz, .done
;>@q     for i in range(3):
;>@s         PoisonPartyMember(i)    # -1 HP
	ld a, $00
	call PoisonPartyMember
;=@s
	ld a, $01
	call PoisonPartyMember
;=@s
	ld a, $02
	call PoisonPartyMember
;>     BuildStatusBar()
	call BuildStatusBar
;>     DrawStatusBar()
	call DrawStatusBar
.done
;> return
	ret


;@ def RegainPartyMemberMP(i: a)
;@ path: monster/walking
;@ Party member i (if there is one, it is not fainted and its condition bit 0 is clear)
;@ gains 1 MP, up to its maximum. The bytes after it are an unused variant that heals
;@ 1 HP with the damage flash.
;@ test: skip changes MP through the party helpers
RegainPartyMemberMP::
;> if i >= wPartyCount:
	ld b, a
	ld a, [wPartyCount]
	cp b
	ret z
	ret c
;>     return
;> if PartyMonsterField(i, wMonStatus)[0] & 0x01:
	ld a, b
	push bc
	ld hl, wMonStatus
	call PartyMonsterField
	bit 0, [hl]
	pop bc
;>     return
	ret nz
;> if PartyMonsterField(i, wMonStatus)[0] & 0x80:   # fainted
	push bc
	ld hl, wMonStatus
	call PartyMonsterField
	bit 7, [hl]
	pop bc
;>     return
	ret nz
;> RestorePartyMP(i, 1)                   # MP + 1
	ld a, b
	ld hl, $0001
	call RestorePartyMP
;> return
	ret


	db $47, $f0, $90, $cb, $4f, $c0, $fa, $8d, $ca, $b8, $c8, $d8, $78, $c5, $21, $0b
	db $cb, $cd, $29, $22, $cb, $46, $c1, $c8, $c5, $21, $0b, $cb, $cd, $29, $22, $cb
	db $7e, $c1, $c0, $78, $21, $01, $00, $cd, $f0, $22, $3e, $6c, $cd, $2c, $1b, $3e
	db $08, $ea, $a8, $c8, $3e, $2d, $ea, $9b, $c8, $c9

;@ def PoisonPartyMember(i: a)
;@ path: monster/walking
;@ A poisoned (condition bit 2), not fainted party member loses 1 HP: damage sound, the
;@ player pauses 8 frames and the screen flashes (wBGP $2D). Not on a conveyor.
;@ test: skip changes HP through the party helpers
PoisonPartyMember::
;> if hPlayerFlags & 0x02:
	ld b, a
	ldh a, [hPlayerFlags]
	bit 1, a
;>     return
	ret nz
;> if i >= wPartyCount:
	ld a, [wPartyCount]
	cp b
	ret z
	ret c
;>     return
;> if not PartyMonsterField(i, wMonStatus)[0] & 0x04:   # not poisoned
	ld a, b
	push bc
	ld hl, wMonStatus
	call PartyMonsterField
	bit 2, [hl]
	pop bc
;>     return
	ret z
;> if PartyMonsterField(i, wMonStatus)[0] & 0x80:
	push bc
	ld hl, wMonStatus
	call PartyMonsterField
	bit 7, [hl]
	pop bc
;>     return
	ret nz
;> DamagePartyHP(i, 1)                   # HP - 1
	ld a, b
	ld hl, $0001
	call DamagePartyHP
;> QueueSound(0x6C)
	ld a, $6c
	call QueueSound
;> wPlayerPause = 8
	ld a, $08
	ld [wPlayerPause], a
;> wBGP = 0x2D                       # flash; UpdatePlayer restores it
	ld a, $2d
	ld [wBGP], a
;> return
	ret


;@ def HandleConveyor()
;@ path: field/conveyor
;@ Conveyor tiles carry Terry along (hPlayerFlags bit 1). When a ride ends (the tile
;@ under him is no conveyor any more) and the screen is not scrolling, script 1 of
;@ map $54 runs.
;@ test: skip far call into the script engine
HandleConveyor::
;> if hPlayerFlags & 0x80:
	ldh a, [hPlayerFlags]
	bit 7, a
;>     return
	ret nz
;> if not hPlayerFlags & 0x02:
	bit 1, a
;>     return CheckConveyorTile()
	jr z, CheckConveyorTile
;> hPlayerFlags &= ~0x02
	ld hl, hPlayerFlags
	res 1, [hl]
;> CheckConveyorTile()
	call CheckConveyorTile
;> if hPlayerFlags & 0x02:           # still riding
	ldh a, [hPlayerFlags]
	bit 1, a
;>     return
	ret nz
;> if wFieldFlags & 0x04:
	ld a, [wFieldFlags]
	bit 2, a
;>     return
	ret nz
;> wScriptId = 1
	ld a, $01
	ld [wScriptId], a
;> wScriptMap = 0x54
	ld a, $54
	ld [wScriptMap], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> StartScript()
	ld hl, far_StartScript
	rst $10
;> return
	ret


;@ def CheckConveyorTile()
;@ path: field/conveyor
;@ On the world maps (see IsWorldMap; not while busy): when the tile under Terry is a
;@ conveyor (tile number / 4 = $0F right, $10 left, $11 down, $12 up) he is pushed at one
;@ pixel per frame in that direction.
;@ test: wOnGateFloor = 0
;@ test: wFadeState = 0
;@ test: wMapLoadState = 0
;@ test: wFieldFlags = 0
;@ test: wMapId = rng.choice([0x10, 0x53, 0x61])
;@ test: hTestTile = rng.randrange(0x38, 0x50)
CheckConveyorTile::
;> if wOnGateFloor:
	ld a, [wOnGateFloor]
	or a
;>     return
	ret nz
;> if 0 < wFadeState <= 0x80:        # fading out
	ld a, [wFadeState]
	cpl
	inc a
	bit 7, a
;>     return
	ret nz
;>@b if wMapLoadState or wFieldFlags & 0x45 or not IsWorldMap():
	ld a, [wMapLoadState]
	or a
	ret nz
	ld a, [wFieldFlags]
	bit 6, a
	ret nz
;=@b
	bit 2, a
	ret nz
	bit 0, a
	ret nz
	call IsWorldMap
	ret nz
;>     return
;> kind = hTestTile >> 2
	ldh a, [hTestTile]
	srl a
	srl a
;> if kind == 0x0F:
	cp $0f
	jr z, .right
;>@r     hPlayerSpeedX = 0x0100
;>@r2     hPlayerFlags |= 0x03
;> elif kind == 0x10:
	cp $10
	jr z, .left
;>@l     hPlayerSpeedX = 0xFF00
;>@l2     hPlayerFlags |= 0x03
;> elif kind == 0x11:
	cp $11
	jr z, .down
;>@d     hPlayerSpeedY = 0x0100
;>@d2     hPlayerFlags |= 0x03
;> elif kind == 0x12:
	cp $12
	jr z, .up
;>@u     hPlayerSpeedY = 0xFF00
;>@u2     hPlayerFlags |= 0x03
;> return
	ret


.right
;=@r
	ld hl, $0100
	ld a, l
	ldh [hPlayerSpeedX], a
	ld a, h
	ldh [$ffa2], a
;=@r2
	ld hl, hPlayerFlags
	set 1, [hl]
	set 0, [hl]
	ret


.left
;=@l
	ld hl, $ff00
	ld a, l
	ldh [hPlayerSpeedX], a
	ld a, h
	ldh [$ffa2], a
;=@l2
	ld hl, hPlayerFlags
	set 1, [hl]
	set 0, [hl]
	ret


.down
;=@d
	ld hl, $0100
	ld a, l
	ldh [hPlayerSpeedY], a
	ld a, h
	ldh [$ffa4], a
;=@d2
	ld hl, hPlayerFlags
	set 1, [hl]
	set 0, [hl]
	ret


.up
;=@u
	ld hl, $ff00
	ld a, l
	ldh [hPlayerSpeedY], a
	ld a, h
	ldh [$ffa4], a
;=@u2
	ld hl, hPlayerFlags
	set 1, [hl]
	set 0, [hl]
	ret


;@ def CheckDamageFloor()
;@ path: field/damage
;@ On gate floors and world maps: standing on a damage tile (tile number / 4 = $0E) hurts
;@ every party member by the map's DamageFloorTable amount, with the damage sound, a pause
;@ and the screen flash. wWorldFlags bit 0 (set by an item) protects the party.
;@ test: skip changes HP through the party helpers
CheckDamageFloor::
;> if not wOnGateFloor and not IsWorldMap():
	ld a, [wOnGateFloor]
	or a
	jr nz, .counts
	call IsWorldMap
;>     return
	ret nz
.counts
;>@b if wFadeState or wFieldFlags & 0x45 or wWorldFlags & 0x01:
	ld a, [wFadeState]
	or a
	ret nz
	ld a, [wFieldFlags]
	bit 6, a
	ret nz
;=@b
	bit 2, a
	ret nz
	bit 0, a
	ret nz
	ld a, [wWorldFlags]
	bit 0, a
;=@b
	ret nz
;>     return
;> if hTestTile >> 2 != 0x0E:
	ldh a, [hTestTile]
	srl a
	srl a
	cp $0e
;>     return
	jr nz, .done
;>@d damage = DamageFloorTable[wMapId]
	ld a, [wMapId]
	ld hl, DamageFloorTable
	add l
	ld l, a
	ld a, $00
	adc h
;=@d
	ld h, a
	ld a, [hl]
;> if damage == 0:
	or a
;>     return
	jr z, .done
;>@m for i in range(3):
;>@m     DamagePartyMember(i, damage)
	ld c, a
	ld l, a
	ld h, $00
	ld a, $00
	call DamagePartyMember
;=@m
	ld a, $01
	call DamagePartyMember
;=@m
	ld a, $02
	call DamagePartyMember
;> QueueSound(0x6C)
	ld a, $6c
	call QueueSound
;> wPlayerPause = 8
	ld a, $08
	ld [wPlayerPause], a
;> wBGP = 0x2D
	ld a, $2d
	ld [wBGP], a
;> BuildStatusBar()
	call BuildStatusBar
;> DrawStatusBar()
	call DrawStatusBar
.done
;> return
	ret


;@ path: field/damage
;@ HP lost per step on a damage tile, by map number ($00-$0F; 0 = harmless).
DamageFloorTable::
	db $00, $00, $00, $05, $00, $00, $0a, $00, $00, $00, $00, $00, $02, $00, $02, $00

;@ def DamagePartyMember(i: a, damage: hl)
;@ path: field/damage
;@ Party member i, if there is one and it has not fainted, loses damage HP.
;@ test: skip changes HP through the party helpers
DamagePartyMember::
;> if i >= wPartyCount:
	ld b, a
	ld a, [wPartyCount]
	cp b
	ret z
	ret c
;>     return
;>@f if PartyMonsterField(i, wMonStatus)[0] & 0x80:
	ld a, b
	push bc
	push hl
	ld hl, wMonStatus
	call PartyMonsterField
	bit 7, [hl]
;=@f
	pop hl
	pop bc
;>     return
	ret nz
;> DamagePartyHP(i, damage)              # HP - damage
	push hl
	ld a, b
	call DamagePartyHP
	pop hl
;> return
	ret


;@ def CheckPartyFainted()
;@ path: field/damage
;@ After a step: party members whose HP reached 0 faint (their names go to the message
;@ buffer). If the whole party is down, the field event for text $021A runs with song
;@ $4F (back to the start); otherwise text $0217 + number fainted reports them.
;@ test: skip calls the party helpers
CheckPartyFainted::
;> n = 0
	ld c, $00
;>@a for i in range(3):
;>@a     n += CheckMemberFainted(i)
	ld a, $00
	call CheckMemberFainted
;=@a
	ld a, $01
	call CheckMemberFainted
;=@a
	ld a, $02
	call CheckMemberFainted
;> if n == 0:
	ld a, c
	or a
;>     return
	ret z
;> down = 0
	push bc
	ld c, $00
;>@d for i in range(3):
;>@d     down += CountFaintedMember(i)
	ld a, $00
	call CountFaintedMember
;=@d
	ld a, $01
	call CountFaintedMember
;=@d
	ld a, $02
	call CountFaintedMember
;> if down == wPartyCount:           # everyone is down
	ld a, [wPartyCount]
	cp c
	pop bc
	jr nz, .someLeft
;>     RefreshPartyGfx()
	call RefreshPartyGfx
;>     BuildStatusBar()
	call BuildStatusBar
;>     DrawStatusBar()
	call DrawStatusBar
;>     hPlayerFlags &= ~0x02
	ld hl, hPlayerFlags
	res 1, [hl]
;>     QueueMusic(0x4F)
	ld a, $4f
	call QueueMusic
;>     wEventRoutine = 0x021A
	ld hl, $021a
	ld a, l
	ld [wEventRoutine], a
	ld a, h
	ld [$c918], a
;>     wFieldFlags |= 0x01
	ld hl, wFieldFlags
	set 0, [hl]
;>     wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [$c916], a
;>     return
	ret


.someLeft
;>@e wEventRoutine = 0x0217 + n        # "... fainted" for n monsters
	ld a, $17
	add c
	ld l, a
	ld h, $02
	ld a, l
	ld [wEventRoutine], a
;=@e
	ld a, h
	ld [$c918], a
;> wFieldFlags |= 0x01
	ld hl, wFieldFlags
	set 0, [hl]
;> wEventStep = 0
	xor a
	ld [wEventStep], a
	ld [$c916], a
;> RefreshPartyGfx()
	call RefreshPartyGfx
;> BuildStatusBar()
	call BuildStatusBar
;> DrawStatusBar()
	call DrawStatusBar
;> return
	ret


;@ def CheckMemberFainted(i: a, n: c) -> c
;@ path: field/damage
;@ If party member i is standing but has 0 HP: it faints (condition bit 7), its name is
;@ copied to message slot n ($C180 + n * 16) and n goes up by one (returns NZ).
;@ test: skip calls the party helpers
CheckMemberFainted::
;> if i >= wPartyCount:
	ld b, a
	ld a, [wPartyCount]
	cp b
	jr z, .no
	jr c, .no
;>     return 0
;> if PartyMonsterField(i, wMonStatus)[0] & 0x80:
	ld a, b
	push bc
	ld hl, wMonStatus
	call PartyMonsterField
	bit 7, [hl]
	pop bc
;>     return 0
	jr nz, .no
;> if GetPartyMonsterWord(i, wMonHP):          # HP left
	ld a, b
	push bc
	ld hl, wMonHP
	call GetPartyMonsterWord
	ld a, b
	or c
;>@n3     return 0
	pop bc
	jr nz, .no
;> PartyMonsterField(i, wMonStatus)[0] |= 0x80
	ld a, b
	push bc
	ld hl, wMonStatus
	call PartyMonsterField
	set 7, [hl]
	pop bc
;>@slot CopyName(0xC180 + n * 16, PartyMonsterField(i, wMonName))
	ld a, c
	push bc
	swap a
	ld hl, wTextArg0
	add l
	ld l, a
;=@slot
	ld a, $00
	adc h
	ld h, a
	push hl
	ld hl, wMonName
	ld a, b
;=@slot
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
	call CopyName
;> return n + 1
	pop bc
	inc c
	ld a, $01
	or a
	ret


.no
;=@n3
	xor a
	ret


;@ def CountFaintedMember(i: a, n: c) -> c
;@ path: field/damage
;@ n + 1 when party member i exists and has fainted.
;@ test: skip reads through the party helpers
CountFaintedMember::
;> if i >= wPartyCount:
	ld b, a
	ld a, [wPartyCount]
	cp b
	ret z
	ret c
;>     return n
;> if not PartyMonsterField(i, wMonStatus)[0] & 0x80:
	ld a, b
	push bc
	ld hl, wMonStatus
	call PartyMonsterField
	bit 7, [hl]
	pop bc
;>     return n
	ret z
;> return n + 1
	inc c
	ret


;@ def DrawFloorObjects()
;@ path: field/gatefloor
;@ On a gate floor (and when the field is not busy) draws every floor object.
;@ test: skip draws sprites through far calls
DrawFloorObjects::
;>@b if mem[0xC8EC] or wFieldFlags & 0x8A or (wFieldFlags & 0x10 and mem[0xC8EF] == 0x0F):
	ld a, [wMenuOverlay]
	or a
	ret nz
	ld a, [wFieldFlags]
	bit 1, a
	ret nz
;=@b
	bit 3, a
	ret nz
	bit 7, a
	ret nz
	bit 4, a
	jr z, .check
;=@b
	ld a, [wScriptMenu]
	cp $0f
	ret z
;>     return
.check
;> if not wOnGateFloor:
	ld a, [wOnGateFloor]
	or a
;>     return
	ret z
;> o = wFloorObjects
	ld de, wFloorObjects
.object
;>@l while mem[o] != 0xFF:
	ld a, [de]
	cp $ff
	ret z
;>     DrawFloorObject(o)
	push de
	call DrawFloorObject
	pop de
;>     o += 4
	ld a, e
	add $04
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@l
	jr .object

;@ def DrawFloorObject(o: de, flags: a)
;@ path: field/gatefloor
;@ Draws one floor object as a sprite at its tile. Kinds below 8 are items lying on the
;@ floor, drawn by the item's kind (ItemObjectKinds); 8 and up are chests (bit 5 = open).
;@ A taken chest blinks while its timer (+1, $20 frames) runs down, then disappears;
;@ taken items are not drawn.
;@ test: skip draws a sprite through a far call
DrawFloorObject::
;> if flags & 0x80:                  # taken
	bit 7, a
	jr z, .draw
;>     if flags & 0x78 == 0 or mem[o + 1] == 0:
	and $78
	ret z
	inc de
	ld a, [de]
	or a
	ret z
;>         return
;>     if not wFieldFlags & 0x41:    # the blink timer stops during events
	ld a, [wFieldFlags]
	bit 0, a
	jr nz, .drawTaken
	bit 6, a
	jr nz, .drawTaken
;>         mem[o + 1] -= 1
	ld a, [de]
	dec a
	ld [de], a
;>         if mem[o + 1] & 1 == 0:   # every other frame
	and $01
;>             return
	ret z
.drawTaken
	dec de
.draw
;> kind = mem[o] & 0x7F
	ld a, [de]
	and $7f
	ld c, a
	inc de
	ld a, [de]
	ld b, a
;> if kind < 8:
	inc de
	ld a, c
	cp $08
	jr nc, .chest
;>@k     kind = ItemObjectKinds[mem[o + 1]]
	ld a, b
	ld hl, ItemObjectKinds
	add l
	ld l, a
	ld a, $00
	adc h
;=@k
	ld h, a
	ld a, [hl]
.chest
;>@t hSpriteTileBase = FloorObjectTiles[kind]
	push af
	ld hl, FloorObjectTiles
	add l
	ld l, a
	ld a, $00
	adc h
;=@t
	ld h, a
	ld a, [hl]
	ldh [hSpriteTileBase], a
;>@a hSpriteAttr = FloorObjectAttrs[kind]
	pop af
	ld hl, FloorObjectAttrs
	add l
	ld l, a
	ld a, $00
	adc h
;=@a
	ld h, a
	ld a, [hl]
	ldh [hSpriteAttr], a
;>@x hSpriteX = mem[o + 2] * 16
	ld hl, hSpriteX
	ld a, [de]
	swap a
	ld c, a
	and $f0
	ld [hli], a
;=@x
	ld a, c
	and $0f
	ld [hli], a
;>@y hSpriteY = mem[o + 3] * 16
	inc de
	ld a, [de]
	swap a
	ld c, a
	and $f0
	ld [hli], a
;=@y
	ld a, c
	and $0f
	ld [hli], a
;> hSpriteSet = 1
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteFrame = 0
	ld a, $00
	ldh [hSpriteFrame], a
;> DrawFieldMarker()
	ld hl, far_DrawFieldMarker
	rst $10
;> return
	ret


;@ path: field/gatefloor
;@ First sprite tile of each floor-object kind: 0-7 item icons, 8-$1F closed chest,
;@ $20-$3F open chest.
FloorObjectTiles::
	db $50, $54, $58, $5c, $60, $64, $68, $6c, $18, $18, $18, $18, $18, $18, $18, $18
	db $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18
	db $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c
	db $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c
;@ path: field/gatefloor
;@ Sprite attributes (CGB palette) of each floor-object kind, as FloorObjectTiles.
FloorObjectAttrs::
	db $01, $02, $06, $07, $00, $07, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;@ path: item/data
;@ Icon kind (0-7) of each item when it lies on a gate floor, by item number ($00-$2F).
ItemObjectKinds::
	db $07, $00, $01, $00, $01, $01, $01, $00, $00, $02, $00, $01, $00, $03, $03, $03
	db $03, $03, $03, $04, $04, $04, $04, $04, $05, $05, $05, $05, $05, $06, $07, $00
	db $00, $00, $00, $00, $00, $05, $00, $05, $01, $00, $00, $00, $00, $05, $00, $05

;@ def AnimateMapTiles()
;@ path: field/tileanim
;@ Animated scenery of the fixed maps (water, waterfalls, flames, lights): runs the
;@ current map's routine from MapTileAnimTable, unless the field is busy.
;@ test: skip jumps through a table to VRAM writers
AnimateMapTiles::
;>@b if wFadeState or wMapLoadState or wOnGateFloor or wFieldFlags & 0xEE or (wFieldFlags & 0x10 and mem[0xC8EF] == 0x0F):
	ld a, [wFadeState]
	or a
	ret nz
	ld a, [wMapLoadState]
	or a
	ret nz
;=@b
	ld a, [wOnGateFloor]
	or a
	ret nz
	ld a, [wFieldFlags]
	bit 5, a
	ret nz
;=@b
	bit 6, a
	ret nz
	bit 2, a
	ret nz
	bit 1, a
	ret nz
;=@b
	bit 3, a
	ret nz
	bit 7, a
	ret nz
	bit 4, a
	jr z, .run
;=@b
	ld a, [wScriptMenu]
	cp $0f
	ret z
;>     return
.run
;> return MapTileAnimTable[wMapId]()
	ld a, [wMapId]
	rst $00

;@ path: field/tileanim
;@ Tile animation routine of each map ($00-$6F), used by AnimateMapTiles.
MapTileAnimTable::
	dw TileAnimMap00
	dw TileAnimMap01
	dw TileAnimMap02
	dw TileAnimMap03
	dw TileAnimMap03
	dw TileAnimMap03
	dw TileAnimMap03
	dw TileAnimMap03
	dw TileAnimMap08
	dw TileAnimMap09
	dw TileAnimMap0A
	dw TileAnimMap0B
	dw TileAnimMap0B
	dw TileAnimMap0B
	dw TileAnimMap0B
	dw TileAnimMap0B
	dw TileAnimMap10
	dw TileAnimMap10
	dw TileAnimMap10
	dw TileAnimMap10
	dw TileAnimMap10
	dw TileAnimMap10
	dw TileAnimMap10
	dw TileAnimMap10
	dw TileAnimMap10
	dw TileAnimMap19
	dw TileAnimMap19
	dw TileAnimMap1B
	dw TileAnimMap1C
	dw TileAnimMap1D
	dw TileAnimMap1E
	dw TileAnimMap1F
	dw TileAnimMap20
	dw TileAnimMap20
	dw TileAnimMap22
	dw TileAnimMap23
	dw TileAnimMap24
	dw TileAnimMap25
	dw TileAnimMap26
	dw TileAnimMap27
	dw TileAnimMap28
	dw TileAnimMap29
	dw TileAnimMap2A
	dw TileAnimMap2B
	dw TileAnimMap2A
	dw TileAnimMap2D
	dw TileAnimMap2E
	dw TileAnimMap2F
	dw TileAnimMap30
	dw TileAnimMap31
	dw TileAnimMap32
	dw TileAnimMap33
	dw TileAnimMap34
	dw TileAnimMap35
	dw TileAnimMap36
	dw TileAnimMap37
	dw TileAnimMap38
	dw TileAnimMap39
	dw TileAnimMap3A
	dw TileAnimMap3B
	dw TileAnimMap3C
	dw TileAnimMap3D
	dw TileAnimMap37
	dw TileAnimMap3F
	dw TileAnimMap40
	dw TileAnimMap41
	dw TileAnimMap42
	dw TileAnimMap43
	dw TileAnimMap44
	dw TileAnimMap45
	dw TileAnimMap46
	dw TileAnimMap47
	dw TileAnimMap48
	dw TileAnimMap49
	dw TileAnimMap4A
	dw TileAnimMap4B
	dw TileAnimMap4C
	dw TileAnimMap4D
	dw TileAnimMap4E
	dw TileAnimMap4F
	dw TileAnimMap50
	dw TileAnimMap50
	dw TileAnimMap52
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap5D
	dw TileAnimMap5E
	dw TileAnimMap5E
	dw TileAnimMap42
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap53
	dw TileAnimMap42
	dw TileAnimMap42
	dw TileAnimMap42
	dw TileAnimMap42
	dw TileAnimMap42
	dw TileAnimMap42
	dw TileAnimMap42
	dw TileAnimMap42
	dw TileAnimMap42
	dw TileAnimMap42
	dw TileAnimMap42

;@ def TileAnimMap00()
;@ path: field/tileanim
;@ Map $00: sways the two tiles at $94D0 (ScrollTilePairOnTick).
;@ test: skip writes VRAM
TileAnimMap00::
;> ScrollTilePairOnTick(0x94D0)
	ld hl, $94d0
	call ScrollTilePairOnTick
;> return
	ret


;@ def TileAnimMap01()
;@ path: field/tileanim
;@ Map $01: flowing water (ScrollWaterTiles).
;@ test: skip writes VRAM
TileAnimMap01::
;> ScrollWaterTiles()
	call ScrollWaterTiles
;> return
	ret


;@ def TileAnimMap02()
;@ path: field/tileanim
;@ Map $02: no animated tiles. The bytes after it are two unused routines that shift the
;@ tiles at $9210 and $93F0 right / left.
TileAnimMap02::
;> return
	ret


	db $21, $10, $92, $cd, $36, $66, $21, $f0, $93, $cd, $36, $66, $c9, $21, $10, $92
	db $cd, $8f, $66, $21, $f0, $93, $cd, $8f, $66, $c9

;@ def TileAnimMap03()
;@ path: field/tileanim
;@ Maps $03-$07: no animated tiles.
TileAnimMap03::
;> return
	ret


;@ def TileAnimMap08()
;@ path: field/tileanim
;@ Map $08 has no tile animation but a palette cycle (Game Boy colours): before the
;@ shooting-star event the background palette steps through Map08PaletteCycleA every
;@ 32 frames, after the first shower through Map08PaletteCycleB at 3x speed; after the
;@ second it stays.
;@ test: wShootingStarStage = 0
TileAnimMap08::
;> if wShootingStarStage == 2:
	ld a, [wShootingStarStage]
	cp $02
;>     return TileAnimMap08Done()
	jp z, TileAnimMap08Done
;> if wShootingStarStage != 0:
	or a
;>     return TileAnimMap08AfterStar()
	jr nz, TileAnimMap08AfterStar
;>@b wBGP = mem[Map08PaletteCycleA + ((wFieldTimer >> 5) & 7)]
	ld a, [wFieldTimer]
	ld l, a
	ld a, [$c8a7]
	ld h, a
	srl h
	rr l
;=@b
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
;=@b
	srl h
	rr l
	ld a, l
	and $07
	ld hl, Map08PaletteCycleA
	add l
;=@b
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wBGP], a
;> return
	ret


;@ path: field/tileanim
;@ Background palettes (rBGP values) map $08 cycles through before the shooting star.
Map08PaletteCycleA::
	db $d2, $d2, $d2, $d1, $c1, $c1, $c1, $d1

;@ def TileAnimMap08AfterStar()
;@ path: field/tileanim
;@ Map $08 after the first shooting-star shower: wBGP = Map08PaletteCycleB[(timer * 3
;@ >> 5) & 31].
;@ test: wFieldTimer = rng.randrange(0x10000)
TileAnimMap08AfterStar::
;>@t t = wFieldTimer * 3
	ld a, [wFieldTimer]
	ld l, a
	ld a, [$c8a7]
	ld h, a
	ld c, l
	ld b, h
;=@t
	add hl, hl
	add hl, bc
;>@b wBGP = mem[Map08PaletteCycleB + ((t >> 5) & 0x1F)]
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
;=@b
	srl h
	rr l
	srl h
	rr l
	ld a, l
	and $1f
;=@b
	ld hl, Map08PaletteCycleB
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@b
	ld a, [hl]
	ld [wBGP], a
;> return
	ret


;@ path: field/tileanim
;@ Background palettes map $08 cycles through after the first shooting-star shower.
Map08PaletteCycleB::
	db $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e6, $e6, $e6, $d2, $d2, $d2, $d1, $d1, $d1
	db $c1, $c1, $c1, $c1, $c1, $c1, $c1, $d1, $d1, $d1, $d2, $d2, $d2, $e6, $e6, $e6

;@ def TileAnimMap08Done()
;@ path: field/tileanim
;@ Map $08 after the second shooting-star shower: the palette stays.
TileAnimMap08Done::
;> return
	ret


;@ def TileAnimMap09()
;@ path: field/tileanim
;@ Map $09: no animated tiles.
TileAnimMap09::
;> return
	ret


;@ def TileAnimMap0A()
;@ path: field/tileanim
;@ Map $0A: flowing water (ScrollWaterTiles).
;@ test: skip writes VRAM
TileAnimMap0A::
;> ScrollWaterTiles()
	call ScrollWaterTiles
;> return
	ret


;@ def TileAnimMap0B()
;@ path: field/tileanim
;@ Maps $0B-$0F: no animated tiles.
TileAnimMap0B::
;> return
	ret


;@ def TileAnimMap10()
;@ path: field/tileanim
;@ Maps $10-$18: no animated tiles.
TileAnimMap10::
;> return
	ret


;@ def TileAnimMap19()
;@ path: field/tileanim
;@ Maps $19-$1A: every 32 frames the two tiles at $9320 swap with the ones at $93D0.
;@ test: skip writes VRAM
TileAnimMap19::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x9320, 0x93D0, 0x20)
	ld hl, $9320
	ld de, $93d0
	ld b, $20
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap1B()
;@ path: field/tileanim
;@ Map $1B: no animated tiles.
TileAnimMap1B::
;> return
	ret


;@ def TileAnimMap1C()
;@ path: field/tileanim
;@ Map $1C: every 32 frames the tiles at $9240 and $92C0 swap (2 tiles).
;@ test: skip writes VRAM
TileAnimMap1C::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x9240, 0x92C0, 0x20)
	ld hl, $9240
	ld de, $92c0
	ld b, $20
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap1D()
;@ path: field/tileanim
;@ Map $1D: no animated tiles.
TileAnimMap1D::
;> return
	ret


;@ def TileAnimMap1E()
;@ path: field/tileanim
;@ Map $1E: no animated tiles.
TileAnimMap1E::
;> return
	ret


;@ def TileAnimMap1F()
;@ path: field/tileanim
;@ Map $1F: no animated tiles.
TileAnimMap1F::
;> return
	ret


;@ def TileAnimMap20()
;@ path: field/tileanim
;@ Maps $20-$21: every 32 frames the tiles at $9320 and $9380 swap (2 tiles).
;@ test: skip writes VRAM
TileAnimMap20::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x9320, 0x9380, 0x20)
	ld hl, $9320
	ld de, $9380
	ld b, $20
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap22()
;@ path: field/tileanim
;@ Map $22: no animated tiles.
TileAnimMap22::
;> return
	ret


;@ def TileAnimMap23()
;@ path: field/tileanim
;@ Map $23: every 32 frames the tiles at $9130 and $9190 swap (4 tiles).
;@ test: skip writes VRAM
TileAnimMap23::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x9130, 0x9190, 0x40)
	ld hl, $9130
	ld de, $9190
	ld b, $40
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap24()
;@ path: field/tileanim
;@ Map $24: no animated tiles.
TileAnimMap24::
;> return
	ret


;@ def TileAnimMap25()
;@ path: field/tileanim
;@ Map $25: no animated tiles.
TileAnimMap25::
;> return
	ret


;@ def TileAnimMap26()
;@ path: field/tileanim
;@ Map $26: sways the tiles at $9240, and every 32 frames swaps $9060 with $9200 and
;@ $9160 with $9220 (2 tiles each).
;@ test: skip writes VRAM
TileAnimMap26::
;> ScrollTilePairOnTick(0x9240)
	ld hl, $9240
	call ScrollTilePairOnTick
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x9060, 0x9200, 0x20)
	ld hl, $9060
	ld de, $9200
	ld b, $20
	call SwapVRAMBytes
;> SwapVRAMBytes(0x9160, 0x9220, 0x20)
	ld hl, $9160
	ld de, $9220
	ld b, $20
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap27()
;@ path: field/tileanim
;@ Map $27: no animated tiles.
TileAnimMap27::
;> return
	ret


;@ def TileAnimMap28()
;@ path: field/tileanim
;@ Map $28: sways the tiles at $9250.
;@ test: skip writes VRAM
TileAnimMap28::
;> ScrollTilePairOnTick(0x9250)
	ld hl, $9250
	call ScrollTilePairOnTick
;> return
	ret


;@ def TileAnimMap29()
;@ path: field/tileanim
;@ Map $29: sways the tiles at $90A0, and every 32 frames swaps $9060 with $90C0 and
;@ $9160 with $90E0.
;@ test: skip writes VRAM
TileAnimMap29::
;> ScrollTilePairOnTick(0x90A0)
	ld hl, $90a0
	call ScrollTilePairOnTick
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x9060, 0x90C0, 0x20)
	ld hl, $9060
	ld de, $90c0
	ld b, $20
	call SwapVRAMBytes
;> SwapVRAMBytes(0x9160, 0x90E0, 0x20)
	ld hl, $9160
	ld de, $90e0
	ld b, $20
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap2A()
;@ path: field/tileanim
;@ Maps $2A and $2C: every 32 frames the tiles at $9060 and $91A0 swap (4 tiles).
;@ test: skip writes VRAM
TileAnimMap2A::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x9060, 0x91A0, 0x40)
	ld hl, $9060
	ld de, $91a0
	ld b, $40
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap2B()
;@ path: field/tileanim
;@ Map $2B: no animated tiles.
TileAnimMap2B::
;> return
	ret


;@ def TileAnimMap2D()
;@ path: field/tileanim
;@ Map $2D: sways the tiles at $9180.
;@ test: skip writes VRAM
TileAnimMap2D::
;> ScrollTilePairOnTick(0x9180)
	ld hl, $9180
	call ScrollTilePairOnTick
;> return
	ret


;@ def TileAnimMap2E()
;@ path: field/tileanim
;@ Map $2E: every 32 frames swaps $9060 with $9200 and $9160 with $9220.
;@ test: skip writes VRAM
TileAnimMap2E::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x9060, 0x9200, 0x20)
	ld hl, $9060
	ld de, $9200
	ld b, $20
	call SwapVRAMBytes
;> SwapVRAMBytes(0x9160, 0x9220, 0x20)
	ld hl, $9160
	ld de, $9220
	ld b, $20
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap2F()
;@ path: field/tileanim
;@ Map $2F: every 32 frames the tile at $94E0 swaps with the one at $94F0.
;@ test: skip writes VRAM
TileAnimMap2F::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x94E0, 0x94F0, 0x10)
	ld hl, $94e0
	ld de, $94f0
	ld b, $10
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap30()
;@ path: field/tileanim
;@ Map $30: sways the tiles at $91E0.
;@ test: skip writes VRAM
TileAnimMap30::
;> ScrollTilePairOnTick(0x91E0)
	ld hl, $91e0
	call ScrollTilePairOnTick
;> return
	ret


;@ def TileAnimMap31()
;@ path: field/tileanim
;@ Map $31: no animated tiles.
TileAnimMap31::
;> return
	ret


;@ def TileAnimMap32()
;@ path: field/tileanim
;@ Map $32: no animated tiles.
TileAnimMap32::
;> return
	ret


;@ def TileAnimMap33()
;@ path: field/tileanim
;@ Map $33: no animated tiles.
TileAnimMap33::
;> return
	ret


;@ def TileAnimMap34()
;@ path: field/tileanim
;@ Map $34: no animated tiles.
TileAnimMap34::
;> return
	ret


;@ def TileAnimMap35()
;@ path: field/tileanim
;@ Map $35: no animated tiles.
TileAnimMap35::
;> return
	ret


;@ def TileAnimMap36()
;@ path: field/tileanim
;@ Map $36: no animated tiles.
TileAnimMap36::
;> return
	ret


;@ def TileAnimMap37()
;@ path: field/tileanim
;@ Maps $37 and $3E: every 32 frames the tile at $9230 swaps with the one at $9240.
;@ test: skip writes VRAM
TileAnimMap37::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x9230, 0x9240, 0x10)
	ld hl, $9230
	ld de, $9240
	ld b, $10
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap38()
;@ path: field/tileanim
;@ Map $38: no animated tiles.
TileAnimMap38::
;> return
	ret


;@ def TileAnimMap39()
;@ path: field/tileanim
;@ Map $39: no animated tiles.
TileAnimMap39::
;> return
	ret


;@ def TileAnimMap3A()
;@ path: field/tileanim
;@ Map $3A: no animated tiles.
TileAnimMap3A::
;> return
	ret


;@ def TileAnimMap3B()
;@ path: field/tileanim
;@ Map $3B: no animated tiles.
TileAnimMap3B::
;> return
	ret


;@ def TileAnimMap3C()
;@ path: field/tileanim
;@ Map $3C: sways the tiles at $9560.
;@ test: skip writes VRAM
TileAnimMap3C::
;> ScrollTilePairOnTick(0x9560)
	ld hl, $9560
	call ScrollTilePairOnTick
;> return
	ret


;@ def TileAnimMap3D()
;@ path: field/tileanim
;@ Map $3D: sways the tiles at $90A0.
;@ test: skip writes VRAM
TileAnimMap3D::
;> ScrollTilePairOnTick(0x90A0)
	ld hl, $90a0
	call ScrollTilePairOnTick
;> return
	ret


;@ def TileAnimMap3F()
;@ path: field/tileanim
;@ Map $3F: every 32 frames the tiles at $9380 and $93C0 swap (4 tiles).
;@ test: skip writes VRAM
TileAnimMap3F::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x9380, 0x93C0, 0x40)
	ld hl, $9380
	ld de, $93c0
	ld b, $40
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap40()
;@ path: field/tileanim
;@ Map $40: no animated tiles.
TileAnimMap40::
;> return
	ret


;@ def TileAnimMap41()
;@ path: field/tileanim
;@ Map $41: no animated tiles.
TileAnimMap41::
;> return
	ret


;@ def TileAnimMap42()
;@ path: field/tileanim
;@ Map $42 and maps $60, $65-$6F: no animated tiles.
TileAnimMap42::
;> return
	ret


;@ def TileAnimMap43()
;@ path: field/tileanim
;@ Map $43: no animated tiles.
TileAnimMap43::
;> return
	ret


;@ def TileAnimMap44()
;@ path: field/tileanim
;@ Map $44: two tiles flicker at different times in a 64-frame cycle: $90E0/$90F0 swap
;@ at frame 3, $91E0/$91F0 at frame $23.
;@ test: skip writes VRAM
TileAnimMap44::
;> if wFieldTimer & 0x3F == 0x03:
	ld a, [wFieldTimer]
	and $3f
	cp $03
	ld hl, $90e0
	ld de, $90f0
	ld b, $10
;>     SwapVRAMBytes(0x90E0, 0x90F0, 0x10)
	call z, SwapVRAMBytes
;> if wFieldTimer & 0x3F != 0x23:
	ld a, [wFieldTimer]
	and $3f
	cp $23
;>     return
	ret nz
;> SwapVRAMBytes(0x91E0, 0x91F0, 0x10)
	ld hl, $91e0
	ld de, $91f0
	ld b, $10
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap45()
;@ path: field/tileanim
;@ Map $45: no animated tiles.
TileAnimMap45::
;> return
	ret


;@ def TileAnimMap46()
;@ path: field/tileanim
;@ Map $46: sways the tiles at $9460.
;@ test: skip writes VRAM
TileAnimMap46::
;> ScrollTilePairOnTick(0x9460)
	ld hl, $9460
	call ScrollTilePairOnTick
;> return
	ret


;@ def TileAnimMap47()
;@ path: field/tileanim
;@ Map $47: every 32 frames swaps $94C0 with $95A0 and $94E0 with $95B0 (1 tile each).
;@ test: skip writes VRAM
TileAnimMap47::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x94C0, 0x95A0, 0x10)
	ld hl, $94c0
	ld de, $95a0
	ld b, $10
	call SwapVRAMBytes
;> SwapVRAMBytes(0x94E0, 0x95B0, 0x10)
	ld hl, $94e0
	ld de, $95b0
	ld b, $10
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap48()
;@ path: field/tileanim
;@ Map $48: every 32 frames the tile at $9190 swaps with the one at $91A0.
;@ test: skip writes VRAM
TileAnimMap48::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x9190, 0x91A0, 0x10)
	ld hl, $9190
	ld de, $91a0
	ld b, $10
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap49()
;@ path: field/tileanim
;@ Map $49: sways the tiles at $9310, and every 32 frames swaps $92A0/$92C0,
;@ $93A0/$93C0 and $9400/$9420 (2 tiles each).
;@ test: skip writes VRAM
TileAnimMap49::
;> ScrollTilePairOnTick(0x9310)
	ld hl, $9310
	call ScrollTilePairOnTick
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x92A0, 0x92C0, 0x20)
	ld hl, $92a0
	ld de, $92c0
	ld b, $20
	call SwapVRAMBytes
;> SwapVRAMBytes(0x93A0, 0x93C0, 0x20)
	ld hl, $93a0
	ld de, $93c0
	ld b, $20
	call SwapVRAMBytes
;> SwapVRAMBytes(0x9400, 0x9420, 0x20)
	ld hl, $9400
	ld de, $9420
	ld b, $20
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap4A()
;@ path: field/tileanim
;@ Map $4A: no animated tiles.
TileAnimMap4A::
;> return
	ret


;@ def TileAnimMap4B()
;@ path: field/tileanim
;@ Map $4B: in a 32-frame cycle $90C0/$90D0 swap at frame 3 and $90E0/$90F0 at frame $13.
;@ test: skip writes VRAM
TileAnimMap4B::
;> if wFieldTimer & 0x1F == 0x03:
	ld a, [wFieldTimer]
	and $1f
	cp $03
	ld hl, $90c0
	ld de, $90d0
	ld b, $10
;>     SwapVRAMBytes(0x90C0, 0x90D0, 0x10)
	call z, SwapVRAMBytes
;> if wFieldTimer & 0x1F != 0x13:
	ld a, [wFieldTimer]
	and $1f
	cp $13
;>     return
	ret nz
;> SwapVRAMBytes(0x90E0, 0x90F0, 0x10)
	ld hl, $90e0
	ld de, $90f0
	ld b, $10
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap4C()
;@ path: field/tileanim
;@ Map $4C: no animated tiles.
TileAnimMap4C::
;> return
	ret


;@ def TileAnimMap4D()
;@ path: field/tileanim
;@ Map $4D: sways the tiles at $9340, and every 32 frames swaps $90A0/$90C0 and
;@ $9200/$9220.
;@ test: skip writes VRAM
TileAnimMap4D::
;> ScrollTilePairOnTick(0x9340)
	ld hl, $9340
	call ScrollTilePairOnTick
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x90A0, 0x90C0, 0x20)
	ld hl, $90a0
	ld de, $90c0
	ld b, $20
	call SwapVRAMBytes
;> SwapVRAMBytes(0x9200, 0x9220, 0x20)
	ld hl, $9200
	ld de, $9220
	ld b, $20
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap4E()
;@ path: field/tileanim
;@ Map $4E: no animated tiles.
TileAnimMap4E::
;> return
	ret


;@ def TileAnimMap4F()
;@ path: field/tileanim
;@ Map $4F: every 32 frames the tiles at $95C0 and $95E0 swap (2 tiles).
;@ test: skip writes VRAM
TileAnimMap4F::
;> if wFieldTimer & 0x1F != 3:
	ld a, [wFieldTimer]
	and $1f
	cp $03
;>     return
	ret nz
;> SwapVRAMBytes(0x95C0, 0x95E0, 0x20)
	ld hl, $95c0
	ld de, $95e0
	ld b, $20
	call SwapVRAMBytes
;> return
	ret


;@ def TileAnimMap50()
;@ path: field/tileanim
;@ Maps $50-$51: no animated tiles.
TileAnimMap50::
;> return
	ret


;@ def TileAnimMap52()
;@ path: field/tileanim
;@ Map $52: two tile groups flicker on their own cycles: $91B0/$90D0 and $91C0/$91D0
;@ swap whenever (timer + 5) is a multiple of 32, $9200/$9220 whenever (timer + 10) is a
;@ multiple of 25.
;@ test: skip writes VRAM
TileAnimMap52::
;>@a if (wFieldTimer + 5) % 0x20 == 0:
	ld a, [wFieldTimer]
	ld l, a
	ld a, [$c8a7]
	ld h, a
	ld a, l
	add $05
;=@a
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, $20
	call Divide16
;=@a
	or a
	jr nz, .second
;>     SwapVRAMBytes(0x91B0, 0x90D0, 0x10)
	ld hl, $91b0
	ld de, $90d0
	ld b, $10
	call SwapVRAMBytes
;>     SwapVRAMBytes(0x91C0, 0x91D0, 0x10)
	ld hl, $91c0
	ld de, $91d0
	ld b, $10
	call SwapVRAMBytes
.second
;>@b if (wFieldTimer + 10) % 25 == 0:
	ld a, [wFieldTimer]
	ld l, a
	ld a, [$c8a7]
	ld h, a
	ld a, l
	add $0a
;=@b
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, $19
	call Divide16
;=@b
	or a
	jr nz, .done
;>     SwapVRAMBytes(0x9200, 0x9220, 0x20)
	ld hl, $9200
	ld de, $9220
	ld b, $20
	call SwapVRAMBytes
.done
;> return
	ret


;@ def TileAnimMap53()
;@ path: field/tileanim
;@ Maps $53-$5C, $61-$64: no animated tiles.
TileAnimMap53::
;> return
	ret


;@ def TileAnimMap5D()
;@ path: field/tileanim
;@ Map $5D: every 8 frames, three tile groups flicker whenever the (shifted) low timer
;@ byte is a multiple of 56, 32 and 24.
;@ test: skip writes VRAM
TileAnimMap5D::
;> if wFieldTimer & 7:
	ld a, [wFieldTimer]
	and $07
;>     return
	ret nz
;> if (wFieldTimer & 0xFF) % 0x38 == 0:
	ld a, [wFieldTimer]
	ld b, a
	ld a, $38
	call Divide8
	or a
	jr nz, .second
;>     SwapVRAMBytes(0x93C0, 0x9440, 0x20)
	ld hl, $93c0
	ld de, $9440
	ld b, $20
	call SwapVRAMBytes
.second
;>@c if ((wFieldTimer + 8) & 0xFF) % 0x20 == 0:
	ld a, [wFieldTimer]
	add $08
	ld b, a
	ld a, $20
	call Divide8
	or a
;=@c
	jr nz, .third
;>     SwapVRAMBytes(0x93E0, 0x9460, 0x20)
	ld hl, $93e0
	ld de, $9460
	ld b, $20
	call SwapVRAMBytes
;>     SwapVRAMBytes(0x9520, 0x94A0, 0x20)
	ld hl, $9520
	ld de, $94a0
	ld b, $20
	call SwapVRAMBytes
.third
;>@d if ((wFieldTimer + 16) & 0xFF) % 0x18 == 0:
	ld a, [wFieldTimer]
	add $10
	ld b, a
	ld a, $18
	call Divide8
	or a
;=@d
	jr nz, .done
;>     SwapVRAMBytes(0x9500, 0x9480, 0x20)
	ld hl, $9500
	ld de, $9480
	ld b, $20
	call SwapVRAMBytes
.done
;> return
	ret


;@ def TileAnimMap5E()
;@ path: field/tileanim
;@ Maps $5E-$5F: no animated tiles.
TileAnimMap5E::
;> return
	ret


;@ def ScrollWaterTiles()
;@ path: field/tileanim
;@ Flowing water: every 32 frames the 16 tiles at $9400 shift by one pixel, groups of
;@ four tiles in alternating directions; the directions swap every 512 frames.
;@ test: skip writes VRAM
ScrollWaterTiles::
;> if wFieldTimer & 0x1F != 5:
	ld a, [wFieldTimer]
	and $1f
	cp $05
	jr z, .tick
;>     return
	ret


.tick
;> if not wFieldTimer & 0x0200:
	ld a, [$c8a7]
	bit 1, a
;>     return ScrollWaterTilesOtherWay()
	jr z, ScrollWaterTilesOtherWay
;> p = RotateTilesRightX4(0x9400)
	ld hl, $9400
	call RotateTilesRightX4
;> p = RotateTilesLeftX4(p)
	call RotateTilesLeftX4
;> p = RotateTilesRightX4(p)
	call RotateTilesRightX4
;> return RotateTilesLeftX4(p)

;@ def RotateTilesLeftX4(p: hl) -> hl
;@ path: field/tileanim
;@ Shifts the 4 tiles at p one pixel left (with wrap-around); returns the address after.
;@ test: skip writes VRAM
RotateTilesLeftX4::
;>@l for i in range(4):
;>@l     p = RotateTileRowsLeft(p)
	call RotateTileRowsLeft
;=@l
	call RotateTileRowsLeft
;=@l
	call RotateTileRowsLeft
;=@l
	jp RotateTileRowsLeft
;> return p


;@ def ScrollWaterTilesOtherWay()
;@ path: field/tileanim
;@ ScrollWaterTiles with the directions the other way round (left, right, left, right).
;@ test: skip writes VRAM
ScrollWaterTilesOtherWay::
;> p = RotateTilesLeftX4(0x9400)
	ld hl, $9400
	call RotateTilesLeftX4
;> p = RotateTilesRightX4(p)
	call RotateTilesRightX4
;> p = RotateTilesLeftX4(p)
	call RotateTilesLeftX4
;> return RotateTilesRightX4(p)

;@ def RotateTilesRightX4(p: hl) -> hl
;@ path: field/tileanim
;@ Shifts the 4 tiles at p one pixel right (with wrap-around); returns the address after.
;@ test: skip writes VRAM
RotateTilesRightX4::
;>@r for i in range(4):
;>@r     p = RotateTileRowsRight(p)
	call RotateTileRowsRight
;=@r
	call RotateTileRowsRight
;=@r
	call RotateTileRowsRight
;=@r
	jp RotateTileRowsRight
;> return p


;@ def ScrollTilePairOnTick(p: hl)
;@ path: field/tileanim
;@ A slow sway of the two tiles at p: in every 128 frames they shift a pixel right at
;@ frames 7, $27 and $47 and a pixel left at frame $67.
;@ test: skip writes VRAM
ScrollTilePairOnTick::
;> t = wFieldTimer & 0x7F
	ld a, [wFieldTimer]
	and $7f
;> if t in (0x07, 0x27, 0x47):
	cp $07
	jr z, .right
	cp $27
	jr z, .right
	cp $47
	jr z, .right
;>@r1     p = RotateTileRowsRight(p)
;>@r2     return RotateTileRowsRight(p)
;> if t == 0x67:
	cp $67
	jr z, .left
;>@l1     p = RotateTileRowsLeft(p)
;>@l2     return RotateTileRowsLeft(p)
;> return
	ret


.right
;=@r1
	call RotateTileRowsRight
;=@r2
	jp RotateTileRowsRight


.left
;=@l1
	call RotateTileRowsLeft
;=@l2
	jp RotateTileRowsLeft


;@ def SwapVRAMBytes(p: hl, q: de, n: b)
;@ path: field/tileanim
;@ Swaps n bytes of VRAM at p and q (two animation frames of a tile trade places).
;@ Interrupts are off around each byte while it waits for VRAM access.
;@ test: skip writes VRAM
SwapVRAMBytes::
;>@s for i in range(n):
;>     WaitVRAMAccess()
	di
	call WaitVRAMAccess
;>     mem[p + i], mem[q + i] = mem[q + i], mem[p + i]
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
;=@s
	ei
	inc de
	dec b
	jr nz, SwapVRAMBytes
;> return
	ret


;@ def CheckShootingStarEvent()
;@ path: event/shootingstar
;@ On map $08 at story step 7 (and with nothing else going on) the shooting-star event
;@ runs.
;@ test: skip far call into the event
CheckShootingStarEvent::
;>@c if wFadeState or wMapLoadState or wOnGateFloor or wScriptRunning:
	ld a, [wFadeState]
	or a
	ret nz
	ld a, [wMapLoadState]
	or a
	ret nz
;=@c
	ld a, [wOnGateFloor]
	or a
	ret nz
	ld a, [wScriptRunning]
	or a
	ret nz
;>     return
;> if wMapId != 0x08 or wStoryStep != 7:
	ld a, [wMapId]
	cp $08
	ret nz
	ld a, [wStoryStep]
	cp $07
	ret nz
;>     return
;> RunShootingStarEvent()
	ld hl, far_RunShootingStarEvent
	rst $10
;> return
	ret


;@ def RotateTileRowsRight(p: hl) -> hl
;@ path: field/tileanim
;@ Shifts one tile (8 rows, both bitplanes) one pixel right with wrap-around; returns
;@ the address of the next tile.
;@ test: skip writes VRAM
RotateTileRowsRight::
;>@r for row in range(8):
;>@a     mem[p] = rrc8(mem[p])
	di
	call WaitVRAMAccess
	rrc [hl]
	inc l
;>@b     mem[p + 1] = rrc8(mem[p + 1])
;>@b     p += 2
	rrc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rrc [hl]
	inc l
;=@b
	rrc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rrc [hl]
	inc l
;=@b
	rrc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rrc [hl]
	inc l
;=@b
	rrc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rrc [hl]
	inc l
;=@b
	rrc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rrc [hl]
	inc l
;=@b
	rrc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rrc [hl]
	inc l
;=@b
	rrc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rrc [hl]
	inc l
;=@b
	rrc [hl]
	ei
	inc hl
;> return p
	ret


;@ def RotateTileRowsLeft(p: hl) -> hl
;@ path: field/tileanim
;@ Shifts one tile one pixel left with wrap-around; returns the address of the next tile.
;@ The bytes after it are two unused routines that roll a tile's rows up / down.
;@ test: skip writes VRAM
RotateTileRowsLeft::
;>@r for row in range(8):
;>@a     mem[p] = rlc8(mem[p])
	di
	call WaitVRAMAccess
	rlc [hl]
	inc l
;>@b     mem[p + 1] = rlc8(mem[p + 1])
;>@b     p += 2
	rlc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rlc [hl]
	inc l
;=@b
	rlc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rlc [hl]
	inc l
;=@b
	rlc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rlc [hl]
	inc l
;=@b
	rlc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rlc [hl]
	inc l
;=@b
	rlc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rlc [hl]
	inc l
;=@b
	rlc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rlc [hl]
	inc l
;=@b
	rlc [hl]
	ei
	inc hl
;=@a
	di
	call WaitVRAMAccess
	rlc [hl]
	inc l
;=@b
	rlc [hl]
	ei
	inc hl
;> return p
	ret


	db $5d, $54, $1b, $1b, $f3, $cd, $a6, $1a, $4e, $2b, $46, $23, $fb, $c5, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $c1, $f3
	db $cd, $a6, $1a, $71, $2b, $70, $fb, $c9, $5d, $54, $13, $13, $f3, $cd, $a6, $1a
	db $4e, $23, $46, $2b, $fb, $c5, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $c1, $f3, $cd, $a6, $1a, $71, $23, $70, $fb, $c9

;@ def TickPlayTime()
;@ path: field/core
;@ Advances the play-time clock by one frame (60 frames a second); it stops at 99:59:59.
;@ test: wPlayFrames = rng.choice([0, 59])
;@ test: wPlaySeconds = rng.choice([0, 59])
;@ test: wPlayMinutes = rng.choice([0, 59])
;@ test: wPlayHours = rng.choice([0, 98, 99])
TickPlayTime::
;> wPlayFrames += 1
	ld a, [wPlayFrames]
	inc a
	ld [wPlayFrames], a
;> if wPlayFrames != 60:
	cp $3c
;>     return
	ret nz
;> wPlayFrames = 0
	xor a
	ld [wPlayFrames], a
;> wPlaySeconds += 1
	ld a, [wPlaySeconds]
	inc a
	ld [wPlaySeconds], a
;> if wPlaySeconds != 60:
	cp $3c
;>     return
	ret nz
;> wPlaySeconds = 0
	xor a
	ld [wPlaySeconds], a
;> wPlayMinutes += 1
	ld a, [wPlayMinutes]
	inc a
	ld [wPlayMinutes], a
;> if wPlayMinutes != 60:
	cp $3c
;>     return
	ret nz
;> wPlayMinutes = 0
	xor a
	ld [wPlayMinutes], a
;> wPlayHours += 1
	ld a, [wPlayHours]
	inc a
	ld [wPlayHours], a
;> if wPlayHours != 100:
	cp $64
;>     return
	ret nz
;> wPlayHours = 99                   # the clock stops at 99:59:59
	ld a, $63
	ld [wPlayHours], a
;> wPlayMinutes = 59
	ld a, $3b
	ld [wPlayMinutes], a
;> wPlaySeconds = 59
	ld [wPlaySeconds], a
;> wPlayFrames = 0
	xor a
	ld [wPlayFrames], a
;> return
	ret


;@ def RollEncounterGroup()
;@ path: battle/encounter
;@ Rolls the wild monster group of the current gate floor from its FloorTables entry:
;@ first the group size (1-3, weights at +2..+4), then a species slot for each member
;@ (weights at +5..+9). A species may not appear more often than its limit (+$14..+$18);
;@ limit 1 means it always comes alone. The chosen slots become species numbers in
;@ wEncSpecies (u16 each, $FF = no monster) and wEncCount = members - 1.
;@ test: skip uses the random generator through many helpers
RollEncounterGroup::
;> SelectFloorTable()
	call SelectFloorTable
;>@t t = FloorTables + wFloorTable * 26
	ld a, [wFloorTable]
	ld bc, $001a
	call Multiply24
	ld a, l
	add LOW(FloorTables + 2)
	ld l, a
;=@t
	ld a, h
	adc HIGH(FloorTables + 2)
	ld h, a
;> s = 0
	ld b, $00
	ld de, wSceneObjects
;>@s0 for k in range(3):              # cumulative group-size weights
;>@s     s = AddWeightClass(t + 2 + k, wSceneObjects + k, s)
	call AddWeightClass
;=@s
	call AddWeightClass
;=@s
	call AddWeightClass
;> wEncCount = PickWeighted(wSceneObjects)
	ld hl, wSceneObjects
	call PickWeighted
	ld [wEncCount], a
;>@u s = 0                           # (and point at t + 5)
	ld a, [wFloorTable]
	ld bc, $001a
	call Multiply24
	ld a, l
	add LOW(FloorTables + 5)
	ld l, a
;=@u
	ld a, h
	adc HIGH(FloorTables + 5)
	ld h, a
	ld de, wSceneObjects
;>@u4 for k in range(5):              # cumulative species weights
;>@u5     s = AddWeightClass(t + 5 + k, wSceneObjects + k, s)
	call AddWeightClass
;=@u5
	call AddWeightClass
;=@u5
	call AddWeightClass
;=@u5
	call AddWeightClass
;=@u5
	call AddWeightClass
;> wEncSpecies[0] = 0xFF
	ld a, $ff
	ld [wEncSpecies], a
;> wEncSpecies[2] = 0xFF
	ld [$da05], a
;> wEncSpecies[4] = 0xFF
	ld [$da07], a
;> wEncSpecies[0] = PickWeighted(wSceneObjects)
	ld hl, wSceneObjects
	call PickWeighted
	ld [wEncSpecies], a
;> if GetSpeciesLimit(wEncSpecies[0]) != 1 and wEncCount:   # not a loner, more members
	call GetSpeciesLimit
	cp $01
	jr z, .toSpecies
	ld a, [wEncCount]
	or a
	jr z, .toSpecies
.second
;>@b     while True:
;>         wEncSpecies[2] = PickWeighted(wSceneObjects)
	ld hl, wSceneObjects
	call PickWeighted
	ld [$da05], a
;>         limit = CheckSpeciesLimit(wEncSpecies[2])
	call CheckSpeciesLimit
;>@b2         if limit >= count and limit != 1:   # (count: slots holding this species)
	jr c, .second
	cp $01
;=@b2
	jr z, .second
;>             break
;>     if wEncCount != 1:
	ld a, [wEncCount]
	cp $01
	jr z, .toSpecies
.third
;>@c         while True:
;>             wEncSpecies[4] = PickWeighted(wSceneObjects)
	ld hl, wSceneObjects
	call PickWeighted
	ld [$da07], a
;>             limit = CheckSpeciesLimit(wEncSpecies[4])
	call CheckSpeciesLimit
;>@c2             if limit >= count and limit != 1:
	jr c, .third
	cp $01
;=@c2
	jr z, .third
;>                 break
.toSpecies
;>@v ids = FloorTables + wFloorTable * 26 + 0x0A   # the five species numbers (u16)
	ld a, [wFloorTable]
	ld bc, $001a
	call Multiply24
	ld a, l
	add LOW(FloorTables + $0a)
	ld l, a
;=@v
	ld a, h
	adc HIGH(FloorTables + $0a)
	ld h, a
;>@m for m in range(3):              # slot numbers become species
;>@n     if wEncSpecies[2 * m] == 0xFF:
	ld a, [wEncSpecies]
	cp $ff
	jr z, .done
;>         return
;>@p     mem16[wEncSpecies + 2 * m] = mem16[ids + wEncSpecies[2 * m] * 2]
	add a
	push hl
	add l
	ld l, a
	ld a, $00
	adc h
;=@p
	ld h, a
	ld a, [hli]
	ld [wEncSpecies], a
	ld a, [hl]
	ld [$da04], a
;>@q     wEncCount = m
	ld a, $00
	ld [wEncCount], a
	pop hl
;=@n
	ld a, [$da05]
	cp $ff
	jr z, .done
;=@p
	add a
	push hl
	add l
	ld l, a
	ld a, $00
	adc h
;=@p
	ld h, a
	ld a, [hli]
	ld [$da05], a
	ld a, [hl]
	ld [$da06], a
;=@q
	ld a, $01
	ld [wEncCount], a
	pop hl
;=@n
	ld a, [$da07]
	cp $ff
	jr z, .done
;=@p
	add a
	push hl
	add l
	ld l, a
	ld a, $00
	adc h
;=@p
	ld h, a
	ld a, [hli]
	ld [$da07], a
	ld a, [hl]
	ld [$da08], a
;=@q
	ld a, $02
	ld [wEncCount], a
	pop hl
.done
;> return
	ret


;@ def CheckSpeciesLimit(slot: a) -> a
;@ path: battle/encounter
;@ Counts how many group members already hold species slot `slot` (count in b) and
;@ returns its limit compared with that count (carry: too many).
;@ test: skip reads the floor table
CheckSpeciesLimit::
;> count = 0
	ld b, $00
	push af
	ld c, a
;>@k for m in range(3):
;>@l     if wEncSpecies[2 * m] == 0xFF:
	ld a, [wEncSpecies]
	cp $ff
	jr z, .limit
;>@l2         break
;>@m     if wEncSpecies[2 * m] == slot:
	cp c
	jr nz, .next1
;>@n         count += 1
	inc b
.next1
;=@l
	ld a, [$da05]
	cp $ff
	jr z, .limit
;=@m
	cp c
	jr nz, .next2
;=@n
	inc b
.next2
;=@l
	ld a, [$da07]
	cp $ff
	jr z, .limit
;=@m
	cp c
	jr nz, .limit
;=@n
	inc b
.limit
;> return GetSpeciesLimit(slot)      # (flags: compared with count)
	pop af
	call GetSpeciesLimit
	cp b
	ret


;@ def GetSpeciesLimit(slot: a) -> a
;@ path: battle/encounter
;@ Most monsters of species slot `slot` in one group (FloorTables entry +$14 + slot).
;@ test: skip reads the floor table
GetSpeciesLimit::
;>@t return FloorTables[wFloorTable * 26 + 0x14 + slot]
	push af
	push bc
	ld a, [wFloorTable]
	ld bc, $001a
	call Multiply24
	ld a, l
;=@t
	add LOW(FloorTables + $14)
	ld l, a
	ld a, h
	adc HIGH(FloorTables + $14)
	ld h, a
	pop bc
;=@t
	pop af
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@t
	ld a, [hl]
	ret


;@ def PickWeighted(list: hl) -> a
;@ path: battle/encounter
;@ Picks an index from a list of cumulative percentages: rolls 0-99 and returns the first
;@ entry (zero entries skipped) that is at least the roll, or that is 100.
;@ test: skip uses the random generator
PickWeighted::
;>@r roll = Random16() % 100
	push hl
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
;=@r
	ld a, $64
	call Divide16
	pop hl
;> i = -1
	ld c, a
	ld b, $ff
.next
;>@w while True:
;>     i += 1
;>     if list[i] and (list[i] == 100 or list[i] >= roll):
	ld a, [hl]
	inc b
	inc hl
	or a
	jr z, .next
	cp $64
;=@w
	jr z, .found
	cp c
	jr c, .next
;>         return i
.found
	ld a, b
	ret


;@ def AddWeightClass(p: hl, out: de, s: b) -> b
;@ path: battle/encounter
;@ Adds the percentage of weight class mem[p] (WeightClasses) to the running sum s and
;@ stores the sum at out; advances both pointers.
;@ test: mem[0xC000] = rng.randrange(8)
;@ test: p = 0xC000
;@ test: out = 0xC100
AddWeightClass::
;>@a s = u8(s + mem[WeightClasses + mem[p]])
	ld a, [hl]
	push hl
	ld hl, WeightClasses
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	add b
	ld b, a
;> mem[out] = s
	ld [de], a
;> return s                          # (p and out advanced)
	inc de
	inc hl
	ret


;@ path: battle/encounter
;@ Percentages of the 8 weight classes used in FloorTables.
WeightClasses::
	db $00, $0a, $14, $1e, $28, $32, $46, $64

;@ def LoadFloorMusic()
;@ path: field/gatefloor
;@ Sets wFloorMusic from the current floor's FloorTables entry (+$19).
;@ test: skip reads the floor tables
LoadFloorMusic::
;> SelectFloorTable()
	call SelectFloorTable
;>@t wFloorMusic = FloorTables[wFloorTable * 26 + 0x19]
	ld a, [wFloorTable]
	ld bc, $001a
	call Multiply24
	ld a, l
	add LOW(FloorTables + $19)
	ld l, a
;=@t
	ld a, h
	adc HIGH(FloorTables + $19)
	ld h, a
	ld a, [hl]
	ld [wFloorMusic], a
;> return
	ret


;@ def SelectFloorTable()
;@ path: field/gatefloor
;@ Picks the FloorTables entry of the current floor: the gate world's first entry plus
;@ the number of its floor thresholds already reached (floor number + 1 >= threshold).
;@ Also sets wFloorStyle from the entry's first byte.
;@ test: skip reads the floor tables
SelectFloorTable::
;>@f first = GateWorldFirstTable[wGateWorld]
	ld a, [wGateWorld]
	ld hl, GateWorldFirstTable
	add l
	ld l, a
	ld a, $00
	adc h
;=@f
	ld h, a
	ld a, [hl]
	push af
;>@s splits = mem16[GateWorldFloorSplits + wGateWorld * 2]
	ld a, [wGateWorld]
	add a
	ld hl, GateWorldFloorSplits
	add l
	ld l, a
	ld a, $00
;=@s
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> n = 0
	ld c, $ff
.count
;>@n while wGateFloor + 1 >= mem[splits + n]:
;>     n += 1
	ld a, [wGateFloor]
	inc a
	cp [hl]
	inc c
	inc hl
	jr nc, .count
;> wFloorTable = first + n
	pop af
	add c
	ld [wFloorTable], a
;>@y wFloorStyle = FloorTables[wFloorTable * 26]
	ld bc, $001a
	call Multiply24
	ld a, l
	add LOW(FloorTables)
	ld l, a
	ld a, h
;=@y
	adc HIGH(FloorTables)
	ld h, a
	ld a, [hl]
	ld [wFloorStyle], a
;> return
	ret


;@ path: field/gatefloor
;@ First FloorTables entry of each of the 32 gate worlds.
GateWorldFirstTable::
	db $00, $01, $03, $05, $07, $09, $0c, $0f, $12, $16, $1a, $1e, $22, $27, $2c, $31
	db $36, $3b, $40, $45, $4a, $4f, $55, $59, $5d, $61, $65, $69, $6d, $71, $75, $79
;@ path: field/gatefloor
;@ Per gate world a pointer (32 x u16) to its list of floor thresholds ($FF ends it):
;@ each threshold reached moves the world to its next FloorTables entry.
GateWorldFloorSplits::
	db $82, $6a, $83, $6a, $83, $6a, $83, $6a, $83, $6a, $83, $6a, $86, $6a, $86, $6a
	db $86, $6a, $8a, $6a, $8a, $6a, $8a, $6a, $8e, $6a, $83, $6a, $8e, $6a, $93, $6a
	db $93, $6a, $86, $6a, $98, $6a, $98, $6a, $98, $6a, $9d, $6a, $a3, $6a, $a3, $6a
	db $a3, $6a, $a3, $6a, $a3, $6a, $a3, $6a, $a3, $6a, $a3, $6a, $a3, $6a, $a7, $6a
	db $ff, $03, $06, $ff, $04, $06, $09, $ff, $04, $06, $09, $ff, $04, $06, $09, $0d
	db $ff, $05, $09, $0d, $11, $ff, $06, $0b, $10, $15, $ff, $06, $0b, $10, $15, $1a
	db $ff, $06, $0b, $15, $ff, $06, $0b, $15, $29, $3d, $51, $ff

;@ path: field/gatefloor
;@ Wild-monster tables of the gate floors: 128 records of 26 bytes, picked by
;@ SelectFloorTable. +0 floor style (wFloorStyle), +1 unknown, +2..+4 weights of the
;@ group sizes (one, two or three monsters, see WeightClasses), +5..+9 weights of the
;@ five species, +$0A..+$13 the five species numbers (u16), +$14..+$18 per-species
;@ limit (1 = only appears alone), +$19 the floor's music (wFloorMusic).
FloorTables::
	db $03, $01, $07, $00
	db $00, $03, $05, $02, $00, $00, $02, $00, $04, $00, $03, $00, $00, $00, $00, $00
	db $01, $01, $01, $00, $00, $08, $03, $02, $05, $05, $00, $03, $03, $02, $02, $00
	db $05, $00, $06, $00, $03, $00, $0e, $00, $00, $00, $03, $03, $03, $01, $00, $08
	db $03, $03, $03, $05, $02, $03, $03, $03, $01, $00, $05, $00, $06, $00, $07, $00
	db $0f, $00, $00, $00, $03, $03, $03, $02, $00, $08, $03, $03, $03, $05, $02, $03
	db $03, $02, $02, $00, $08, $00, $0a, $00, $03, $00, $0d, $00, $00, $00, $03, $03
	db $03, $01, $00, $08, $03, $03, $03, $05, $02, $03, $03, $03, $01, $00, $08, $00
	db $09, $00, $0a, $00, $0e, $00, $00, $00, $03, $03, $03, $02, $00, $08, $03, $03
	db $03, $06, $00, $03, $03, $02, $02, $00, $09, $00, $0f, $00, $11, $00, $13, $00
	db $00, $00, $03, $03, $03, $02, $00, $08, $03, $03, $02, $03, $05, $04, $03, $02
	db $01, $00, $0e, $00, $14, $00, $13, $00, $19, $00, $00, $00, $03, $03, $03, $02
	db $00, $08, $03, $03, $03, $06, $00, $03, $03, $02, $02, $00, $0d, $00, $15, $00
	db $11, $00, $19, $00, $00, $00, $03, $03, $03, $02, $00, $08, $03, $03, $02, $03
	db $05, $04, $03, $02, $01, $00, $12, $00, $16, $00, $19, $00, $10, $00, $00, $00
	db $03, $03, $03, $02, $00, $08, $04, $03, $03, $05, $02, $03, $03, $02, $02, $00
	db $14, $00, $15, $00, $19, $00, $1a, $00, $00, $00, $03, $03, $03, $02, $00, $03
	db $04, $03, $03, $05, $02, $04, $03, $02, $01, $00, $15, $00, $11, $00, $13, $00
	db $1b, $00, $00, $00, $03, $03, $03, $02, $00, $03, $04, $03, $03, $04, $03, $04
	db $03, $02, $01, $00, $16, $00, $13, $00, $10, $00, $1c, $00, $00, $00, $03, $03
	db $03, $02, $00, $03, $03, $03, $03, $05, $02, $03, $03, $03, $01, $00, $15, $00
	db $19, $00, $1d, $00, $1a, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03
	db $02, $05, $03, $04, $03, $02, $01, $00, $11, $00, $1a, $00, $17, $00, $21, $00
	db $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $03, $04, $03, $04, $03, $02
	db $01, $00, $10, $00, $1a, $00, $21, $00, $22, $00, $00, $00, $03, $03, $03, $02
	db $00, $0f, $03, $03, $03, $05, $02, $03, $03, $03, $01, $00, $16, $00, $1b, $00
	db $1c, $00, $23, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $02, $05
	db $03, $04, $03, $02, $01, $00, $1b, $00, $23, $00, $18, $00, $24, $00, $00, $00
	db $03, $03, $03, $02, $00, $0f, $03, $03, $03, $04, $03, $04, $03, $02, $01, $00
	db $1b, $00, $23, $00, $24, $00, $22, $00, $00, $00, $03, $03, $03, $02, $00, $0f
	db $04, $03, $00, $06, $03, $03, $03, $03, $01, $00, $17, $00, $21, $00, $23, $00
	db $26, $00, $00, $00, $03, $03, $03, $03, $00, $03, $04, $03, $00, $06, $03, $04
	db $03, $02, $01, $00, $21, $00, $28, $00, $23, $00, $26, $00, $00, $00, $03, $03
	db $03, $03, $00, $03, $04, $03, $00, $06, $03, $04, $03, $02, $01, $00, $24, $00
	db $22, $00, $23, $00, $27, $00, $00, $00, $03, $03, $03, $03, $00, $03, $04, $03
	db $00, $06, $03, $03, $02, $02, $02, $01, $22, $00, $18, $00, $23, $00, $27, $00
	db $1e, $00, $03, $03, $03, $03, $03, $03, $03, $03, $01, $05, $04, $03, $03, $02
	db $02, $00, $27, $00, $28, $00, $25, $00, $2f, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $03, $03, $01, $05, $04, $03, $03, $03, $01, $00, $27, $00, $25, $00
	db $2f, $00, $2b, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $01, $05
	db $04, $04, $03, $02, $01, $00, $28, $00, $25, $00, $2b, $00, $2e, $00, $00, $00
	db $03, $03, $03, $02, $00, $0f, $03, $03, $01, $05, $04, $04, $03, $02, $01, $00
	db $28, $00, $2b, $00, $2f, $00, $2e, $00, $00, $00, $03, $03, $03, $02, $00, $0f
	db $03, $03, $01, $05, $04, $03, $03, $02, $02, $00, $24, $00, $26, $00, $29, $00
	db $2a, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $03, $03, $01, $05, $04, $03
	db $03, $03, $01, $00, $26, $00, $29, $00, $2a, $00, $2c, $00, $00, $00, $03, $03
	db $03, $02, $00, $0f, $03, $03, $01, $05, $04, $04, $03, $02, $01, $00, $2a, $00
	db $29, $00, $2c, $00, $2d, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03
	db $01, $05, $04, $04, $03, $02, $01, $00, $2a, $00, $2c, $00, $2d, $00, $2e, $00
	db $00, $00, $03, $03, $03, $02, $00, $0f, $04, $03, $00, $05, $05, $03, $03, $02
	db $02, $00, $2f, $00, $31, $00, $32, $00, $30, $00, $00, $00, $03, $03, $03, $02
	db $00, $03, $04, $03, $00, $05, $05, $03, $03, $03, $01, $00, $2f, $00, $32, $00
	db $30, $00, $39, $00, $00, $00, $03, $03, $03, $02, $00, $03, $04, $03, $00, $05
	db $05, $04, $03, $02, $01, $00, $2e, $00, $32, $00, $30, $00, $3a, $00, $00, $00
	db $03, $03, $03, $02, $00, $03, $04, $03, $00, $05, $05, $04, $03, $02, $01, $00
	db $2e, $00, $30, $00, $39, $00, $3a, $00, $00, $00, $03, $03, $03, $02, $00, $03
	db $03, $03, $01, $04, $05, $03, $03, $02, $02, $00, $3b, $00, $3c, $00, $3e, $00
	db $3d, $00, $00, $00, $03, $03, $03, $01, $00, $0f, $03, $03, $01, $04, $05, $03
	db $03, $03, $01, $00, $3b, $00, $3c, $00, $3e, $00, $3d, $00, $00, $00, $03, $03
	db $03, $02, $00, $0f, $03, $03, $01, $04, $05, $04, $03, $02, $01, $00, $3c, $00
	db $3e, $00, $3f, $00, $3d, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03
	db $01, $04, $05, $04, $03, $02, $01, $00, $3c, $00, $3f, $00, $41, $00, $40, $00
	db $00, $00, $03, $03, $03, $02, $00, $0f, $04, $03, $01, $04, $05, $04, $03, $02
	db $01, $00, $41, $00, $3f, $00, $3d, $00, $40, $00, $00, $00, $03, $03, $03, $02
	db $00, $0f, $03, $03, $01, $04, $05, $03, $03, $02, $02, $00, $3a, $00, $43, $00
	db $44, $00, $42, $00, $00, $00, $03, $03, $03, $01, $00, $0f, $03, $03, $01, $04
	db $05, $03, $03, $03, $01, $00, $3a, $00, $43, $00, $44, $00, $42, $00, $00, $00
	db $03, $03, $03, $02, $00, $0f, $03, $03, $01, $04, $05, $04, $03, $02, $01, $00
	db $43, $00, $44, $00, $42, $00, $46, $00, $00, $00, $03, $03, $03, $02, $00, $0f
	db $03, $03, $01, $04, $05, $04, $03, $02, $01, $00, $43, $00, $42, $00, $45, $00
	db $46, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $04, $03, $01, $04, $05, $04
	db $03, $02, $01, $00, $42, $00, $45, $00, $47, $00, $46, $00, $00, $00, $03, $03
	db $03, $02, $00, $0f, $04, $03, $00, $03, $06, $03, $03, $02, $02, $00, $49, $00
	db $48, $00, $47, $00, $4a, $00, $00, $00, $03, $03, $03, $01, $00, $03, $04, $03
	db $00, $03, $06, $03, $03, $03, $01, $00, $49, $00, $48, $00, $47, $00, $4a, $00
	db $00, $00, $03, $03, $03, $02, $00, $03, $04, $03, $00, $03, $06, $04, $03, $02
	db $01, $00, $48, $00, $47, $00, $4a, $00, $51, $00, $00, $00, $03, $03, $03, $02
	db $00, $03, $04, $03, $00, $03, $06, $04, $03, $02, $01, $00, $48, $00, $4a, $00
	db $53, $00, $51, $00, $00, $00, $03, $03, $03, $02, $00, $03, $04, $03, $00, $03
	db $06, $04, $03, $02, $01, $00, $4a, $00, $53, $00, $51, $00, $52, $00, $00, $00
	db $03, $03, $03, $02, $00, $03, $03, $03, $01, $04, $05, $03, $03, $02, $02, $00
	db $55, $00, $56, $00, $57, $00, $52, $00, $00, $00, $03, $03, $03, $02, $00, $0f
	db $03, $03, $01, $04, $05, $03, $03, $03, $01, $00, $55, $00, $56, $00, $57, $00
	db $58, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $01, $04, $05, $04
	db $03, $02, $01, $00, $55, $00, $56, $00, $57, $00, $58, $00, $00, $00, $03, $03
	db $03, $02, $00, $0f, $03, $03, $01, $04, $05, $04, $03, $02, $01, $00, $56, $00
	db $57, $00, $58, $00, $54, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $04, $03
	db $01, $04, $05, $04, $03, $02, $01, $00, $56, $00, $58, $00, $59, $00, $54, $00
	db $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $01, $04, $05, $03, $03, $02
	db $02, $00, $59, $00, $5b, $00, $5c, $00, $5a, $00, $00, $00, $03, $03, $03, $02
	db $00, $0f, $03, $03, $01, $04, $05, $03, $03, $03, $01, $00, $59, $00, $5b, $00
	db $5c, $00, $5a, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $01, $04
	db $05, $04, $03, $02, $01, $00, $5b, $00, $5c, $00, $5a, $00, $5e, $00, $00, $00
	db $03, $03, $03, $02, $00, $0f, $03, $03, $01, $04, $05, $04, $03, $02, $01, $00
	db $5b, $00, $5a, $00, $5d, $00, $5e, $00, $00, $00, $03, $03, $03, $02, $00, $0f
	db $04, $03, $01, $04, $05, $04, $03, $02, $01, $00, $5a, $00, $5d, $00, $5f, $00
	db $5e, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $04, $03, $00, $03, $06, $03
	db $03, $02, $02, $00, $60, $00, $62, $00, $6b, $00, $69, $00, $00, $00, $03, $03
	db $03, $01, $00, $03, $04, $03, $00, $03, $06, $03, $03, $03, $01, $00, $60, $00
	db $62, $00, $6b, $00, $69, $00, $00, $00, $03, $03, $03, $02, $00, $03, $04, $03
	db $00, $03, $06, $04, $03, $02, $01, $00, $62, $00, $6b, $00, $69, $00, $61, $00
	db $00, $00, $03, $03, $03, $02, $00, $03, $04, $03, $00, $03, $06, $04, $03, $02
	db $01, $00, $62, $00, $69, $00, $6a, $00, $61, $00, $00, $00, $03, $03, $03, $02
	db $00, $03, $04, $03, $00, $03, $06, $04, $03, $02, $01, $00, $69, $00, $6a, $00
	db $6b, $00, $61, $00, $00, $00, $03, $03, $03, $02, $00, $03, $03, $03, $01, $04
	db $05, $03, $02, $02, $02, $01, $6c, $00, $6d, $00, $70, $00, $71, $00, $6b, $00
	db $03, $03, $03, $03, $02, $0f, $03, $03, $01, $04, $05, $03, $02, $02, $02, $01
	db $6c, $00, $6f, $00, $70, $00, $71, $00, $6b, $00, $03, $03, $03, $03, $02, $0f
	db $03, $03, $01, $04, $05, $03, $02, $02, $02, $01, $6c, $00, $6f, $00, $70, $00
	db $6b, $00, $72, $00, $03, $03, $03, $02, $02, $0f, $03, $03, $01, $04, $05, $03
	db $02, $02, $02, $01, $6c, $00, $6f, $00, $71, $00, $6b, $00, $72, $00, $03, $03
	db $03, $02, $02, $0f, $04, $03, $01, $04, $05, $02, $02, $02, $02, $02, $6c, $00
	db $6f, $00, $6b, $00, $72, $00, $73, $00, $03, $03, $03, $03, $02, $0f, $03, $03
	db $01, $04, $05, $03, $02, $02, $02, $01, $74, $00, $77, $00, $78, $00, $79, $00
	db $75, $00, $03, $03, $03, $03, $02, $0f, $03, $03, $01, $04, $05, $03, $02, $02
	db $02, $01, $77, $00, $78, $00, $79, $00, $7a, $00, $75, $00, $03, $03, $03, $03
	db $02, $0f, $03, $03, $01, $04, $05, $03, $02, $02, $02, $01, $77, $00, $79, $00
	db $7a, $00, $75, $00, $76, $00, $03, $03, $03, $02, $02, $0f, $03, $03, $01, $04
	db $05, $03, $02, $02, $02, $01, $77, $00, $79, $00, $81, $00, $75, $00, $76, $00
	db $03, $03, $03, $02, $02, $0f, $04, $03, $01, $04, $05, $02, $02, $02, $02, $02
	db $77, $00, $78, $00, $81, $00, $75, $00, $76, $00, $03, $03, $03, $03, $02, $0f
	db $04, $03, $00, $03, $06, $03, $02, $02, $02, $01, $82, $00, $84, $00, $88, $00
	db $89, $00, $83, $00, $03, $03, $03, $03, $02, $03, $04, $03, $00, $03, $06, $03
	db $02, $02, $02, $01, $82, $00, $84, $00, $86, $00, $89, $00, $83, $00, $03, $03
	db $03, $03, $02, $03, $04, $03, $00, $03, $06, $03, $02, $02, $02, $01, $82, $00
	db $84, $00, $86, $00, $89, $00, $85, $00, $03, $03, $03, $03, $02, $03, $04, $03
	db $00, $03, $06, $03, $02, $02, $02, $01, $82, $00, $83, $00, $86, $00, $89, $00
	db $85, $00, $03, $03, $03, $03, $02, $03, $04, $03, $00, $03, $06, $02, $02, $02
	db $02, $02, $82, $00, $83, $00, $85, $00, $86, $00, $87, $00, $03, $03, $03, $03
	db $02, $03, $03, $03, $00, $03, $06, $03, $02, $02, $02, $01, $8a, $00, $8b, $00
	db $8c, $00, $8d, $00, $8e, $00, $03, $03, $03, $03, $02, $0f, $03, $03, $00, $03
	db $06, $03, $02, $02, $02, $01, $8a, $00, $8b, $00, $8d, $00, $8e, $00, $8f, $00
	db $03, $03, $03, $03, $02, $0f, $03, $03, $00, $03, $06, $03, $02, $02, $02, $01
	db $8e, $00, $8d, $00, $90, $00, $91, $00, $8f, $00, $03, $03, $03, $03, $02, $0f
	db $03, $03, $00, $03, $06, $03, $02, $02, $02, $01, $8e, $00, $90, $00, $92, $00
	db $9d, $00, $8f, $00, $03, $03, $03, $03, $02, $0f, $03, $03, $00, $03, $06, $03
	db $02, $02, $02, $01, $90, $00, $92, $00, $9d, $00, $9e, $00, $8f, $00, $03, $03
	db $03, $03, $02, $0f, $04, $03, $00, $03, $06, $02, $02, $02, $02, $02, $8f, $00
	db $92, $00, $9d, $00, $9e, $00, $9f, $00, $03, $03, $03, $03, $03, $0f, $02, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $06, $00, $0a, $00, $13, $00, $24, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02
	db $02, $00, $26, $00, $2c, $00, $31, $00, $46, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $03, $03, $00, $00, $07, $03, $03, $02, $02, $00, $56, $00, $5e, $00
	db $71, $00, $74, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03, $00, $00
	db $07, $03, $03, $02, $02, $00, $7a, $00, $81, $00, $89, $00, $92, $00, $00, $00
	db $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02, $02, $00
	db $05, $00, $12, $00, $1b, $00, $23, $00, $00, $00, $03, $03, $03, $03, $00, $0f
	db $02, $03, $00, $00, $07, $03, $03, $02, $02, $00, $2b, $00, $3e, $00, $45, $00
	db $55, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $03, $03, $00, $00, $07, $03
	db $03, $02, $02, $00, $70, $00, $79, $00, $88, $00, $91, $00, $00, $00, $03, $03
	db $03, $03, $00, $0f, $04, $03, $00, $00, $07, $03, $03, $02, $02, $00, $91, $00
	db $a3, $00, $a9, $00, $bd, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $04, $00, $0e, $00, $15, $00, $22, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02
	db $02, $00, $32, $00, $3d, $00, $44, $00, $54, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $03, $03, $00, $00, $07, $03, $03, $02, $02, $00, $5d, $00, $6f, $00
	db $78, $00, $87, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03, $00, $00
	db $07, $03, $03, $02, $02, $00, $90, $00, $a2, $00, $c5, $00, $c6, $00, $00, $00
	db $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02, $02, $00
	db $02, $00, $19, $00, $1e, $00, $28, $00, $00, $00, $03, $03, $03, $03, $00, $0f
	db $02, $03, $00, $00, $07, $03, $03, $02, $02, $00, $2e, $00, $3b, $00, $41, $00
	db $49, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $03, $03, $00, $00, $07, $03
	db $03, $02, $02, $00, $51, $00, $5a, $00, $62, $00, $6c, $00, $00, $00, $03, $03
	db $03, $03, $00, $0f, $04, $03, $00, $00, $07, $03, $03, $02, $02, $00, $6c, $00
	db $75, $00, $8d, $00, $b5, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $02, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $07, $00, $16, $00, $1c, $00, $25, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02
	db $02, $00, $3f, $00, $47, $00, $57, $00, $5f, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $03, $03, $00, $00, $07, $03, $03, $02, $02, $00, $69, $00, $72, $00
	db $82, $00, $8a, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03, $00, $00
	db $07, $03, $03, $02, $02, $00, $9d, $00, $a4, $00, $aa, $00, $be, $00, $00, $00
	db $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02, $02, $00
	db $08, $00, $10, $00, $17, $00, $2d, $00, $00, $00, $03, $03, $03, $03, $00, $0f
	db $02, $03, $00, $00, $07, $03, $03, $02, $02, $00, $39, $00, $40, $00, $58, $00
	db $60, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $03, $03, $00, $00, $07, $03
	db $03, $02, $02, $00, $6a, $00, $73, $00, $83, $00, $8b, $00, $00, $00, $03, $03
	db $03, $03, $00, $0f, $04, $03, $00, $00, $07, $02, $02, $02, $02, $02, $9e, $00
	db $a5, $00, $ab, $00, $ba, $00, $bf, $00, $03, $03, $03, $03, $03, $0f, $02, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $09, $00, $18, $00, $1d, $00, $27, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02
	db $02, $00, $3a, $00, $48, $00, $59, $00, $61, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $03, $03, $00, $00, $07, $02, $02, $02, $02, $02, $6b, $00, $84, $00
	db $8c, $00, $9f, $00, $a6, $00, $03, $03, $03, $03, $03, $0f, $04, $03, $00, $00
	db $07, $02, $02, $02, $02, $02, $ac, $00, $b7, $00, $bb, $00, $c0, $00, $c1, $00
	db $03, $03, $03, $03, $03, $0f, $02, $03, $00, $00, $07, $02, $02, $02, $02, $02
	db $0f, $00, $14, $00, $21, $00, $2a, $00, $30, $00, $03, $03, $03, $03, $03, $0f
	db $02, $03, $00, $00, $07, $02, $02, $02, $02, $02, $3c, $00, $43, $00, $4a, $00
	db $53, $00, $5c, $00, $03, $03, $03, $03, $03, $0f, $03, $03, $00, $00, $07, $02
	db $02, $02, $02, $02, $6e, $00, $77, $00, $86, $00, $8f, $00, $a1, $00, $03, $03
	db $03, $03, $03, $0f, $04, $03, $00, $00, $07, $02, $02, $02, $02, $02, $a8, $00
	db $ae, $00, $b6, $00, $b9, $00, $c3, $00, $03, $03, $03, $03, $03, $0f, $02, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $0d, $00, $11, $00, $1a, $00, $29, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $02, $02, $02
	db $02, $02, $2f, $00, $42, $00, $52, $00, $5b, $00, $6d, $00, $03, $03, $03, $03
	db $03, $0f, $03, $03, $00, $00, $07, $02, $02, $02, $02, $02, $76, $00, $85, $00
	db $8e, $00, $a0, $00, $a7, $00, $03, $03, $03, $03, $03, $0f, $04, $03, $00, $00
	db $07, $02, $02, $02, $02, $02, $ad, $00, $b8, $00, $bc, $00, $c2, $00, $c4, $00
	db $03, $03, $03, $03, $03, $0f, $04, $03, $00, $00, $07, $03, $03, $02, $02, $00
	db $ba, $00, $b9, $00, $bb, $00, $bc, $00, $00, $00, $03, $03, $03, $03, $00, $0f
	db $04, $03, $00, $00, $07, $03, $03, $02, $02, $00, $bb, $00, $bc, $00, $bd, $00
	db $be, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03, $00, $00, $07, $03
	db $03, $02, $02, $00, $bd, $00, $be, $00, $bf, $00, $c0, $00, $00, $00, $03, $03
	db $03, $03, $00, $0f, $04, $03, $00, $00, $07, $03, $03, $02, $02, $00, $bf, $00
	db $c0, $00, $c1, $00, $c2, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $c1, $00, $c2, $00, $c3, $00, $c4, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03, $00, $00, $07, $03, $03, $02
	db $02, $00, $c3, $00, $c4, $00, $c5, $00, $c6, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $04, $03, $00, $00, $07, $03, $03, $02, $02, $00, $c5, $00, $c6, $00
	db $1e, $00, $b5, $00, $00, $00, $03, $03, $03, $03, $00, $0f

;@ path: unused
;@ Not referenced anywhere: leftover bytes after the last table of the bank (they look
;@ like code and tables of an earlier build).
UnusedBank01Tail::
	db $5a, $e7, $c9, $d7
	db $c0, $3e, $07, $ea, $80, $c9, $3e, $06, $ea, $81, $c9, $c9, $f7, $fe, $e8, $62
	db $2e, $12, $38, $10, $3a, $fe, $02, $38, $05, $c0, $7e, $fe, $80, $d0, $01, $0c
	db $00, $c3, $98, $05, $fe, $3c, $d8, $fe, $48, $01, $20, $01, $d2, $5a, $05, $3a
	db $fe, $01, $d8, $20, $04, $7e, $fe, $80, $d8, $01, $f8, $ff, $c3, $98, $05, $fa
	db $96, $ca, $cb, $6f, $3e, $03, $20, $57, $fa, $c1, $ca, $a7, $c0, $cd, $82, $03
	db $38, $23, $fa, $08, $cc, $e0, $d8, $3e, $61, $e7, $cd, $82, $03, $f0, $d8, $e7
	db $d0, $21, $0f, $cc, $fa, $0f, $c0, $fe, $6a, $d0, $d6, $0c, $be, $26, $c0, $30
	db $02, $34, $c9, $35, $c9, $21, $c0, $ca, $cb, $c6, $21, $07, $c0, $cb, $86, $01
	db $5b, $78, $cd, $be, $02, $2e, $10, $36, $02, $3e, $80, $cd, $ce, $06, $cd, $0b
	db $05, $cd, $60, $78, $1e, $01, $1a, $fe, $02, $3e, $06, $28, $02, $3e, $07, $cd
	db $d8, $07, $21, $8b, $c9, $cb, $ce, $c1, $c9, $08, $58, $08, $59, $fe, $26, $c0
	db $01, $00, $00, $cd, $ff, $05, $c5, $26, $d0, $cd, $b8, $07, $36, $64, $c1, $cd
	db $e3, $05, $16, $d0, $cd, $86, $06, $3e, $1f, $e7, $01, $00, $01, $cd, $52, $05
	db $01, $00, $fe, $cd, $64, $05, $16, $cc, $c9, $1e, $01, $1a, $fe, $01, $28, $13
	db $30, $34, $d7, $c0, $36, $18, $ff, $01, $80, $00, $cd, $64, $05, $01, $80, $ff
	db $c3, $52, $05, $1e, $0f, $1a, $fe, $98, $30, $13, $01, $f8, $ff, $cd, $8e, $05
	db $d7, $c0, $36, $28, $01, $00, $01, $cd, $6c, $05, $c3, $7c, $05, $cd, $c3, $05
	db $ff, $3e, $80, $c3, $ce, $06, $d7, $c0, $3e, $03, $ea, $c0, $c9, $c3, $33, $07
	db $01, $0c, $00, $c3, $8e, $05, $c3, $84, $07, $cd, $43, $00, $e4, $78, $06, $79
	db $1b, $79, $fa, $86, $ca, $fe, $08, $d8, $ff, $01, $fd, $78, $cd, $7e, $06, $01
	db $10, $f0, $cd, $e2, $05, $01, $80, $02, $c3, $52, $05, $08, $5d, $04, $5e, $08
	db $5f, $04, $5e, $fe, $01, $fd, $78, $cd, $98, $02, $cd, $5c, $07, $d0, $ff, $3e
	db $80, $cd, $ce, $06, $2e, $10, $36, $02, $c9, $d7, $c0, $3e, $01, $cd, $d8, $07
	db $cd, $3b, $06, $01, $00, $10, $cd, $12, $06, $cd, $e2, $05, $2e, $10, $36, $01
	db $fa, $01, $cc, $fe, $03, $30, $0f, $01, $80, $02, $cd, $32, $06, $ca, $5a, $05
	db $01, $00, $ff, $c3, $5a, $05, $01, $80, $00, $c3, $4a, $05, $c9, $1e, $01, $1a
	db $fe, $08, $f5, $dc, $6f, $03, $f1, $c7, $6e, $79, $92, $79, $fc, $79, $1c, $7a
	db $34, $7a, $44, $7a, $49, $7a, $4e, $7a, $69, $7a, $c5, $7a, $1e, $02, $1a, $a7
	db $20, $0f, $cd, $0c, $7b, $fa, $86, $ca, $fe, $03, $c0, $cd, $0b, $05, $c3, $37
	db $61, $ff, $3e, $5c, $e7, $3e, $40, $cd, $ce, $06, $01, $43, $98, $c3, $22, $37
	db $cd, $0c, $7b, $d7, $c0, $36, $20, $ff, $3e, $3e, $cd, $15, $05, $cd, $4b, $16
	db $21, $14, $c0, $86, $21, $0f, $c0, $86, $cb, $47, $20, $15, $1e, $02, $1a, $fe
	db $0a, $30, $0e, $3e, $09, $01, $54, $74, $cd, $d1, $79, $21, $a8, $7b, $c3, $1e
	db $09, $3e, $0b, $01, $64, $74, $cd, $d1, $79, $21, $8f, $7b, $c3, $1e, $09, $1e
	db $1c, $12, $c5, $cd, $cc, $07, $c1, $c0, $36, $65, $54, $3e, $5b, $e7, $cd, $8a
	db $06, $cd, $e8, $07, $01, $00, $fe, $cd, $52, $05, $cd, $cf, $01, $44, $4d, $21
	db $c0, $c0, $cd, $ea, $0a, $16, $cc, $c3, $d3, $07, $d7, $c0, $36, $08, $21, $71
	db $7b, $cd, $1e, $09, $1e, $02, $1a, $fe, $10, $3e, $04, $d2, $d8, $07, $21, $8e
	db $8f, $cd, $1d, $7b, $ff, $62, $2e, $1c, $34, $c9, $d7, $c0, $3e, $40, $2e, $02
	db $96, $96, $96, $96, $cd, $ce, $06, $21, $8f, $8e, $cd, $1d, $7b, $3e, $01, $c3
	db $d8, $07, $01, $bb, $7b, $d7, $c0, $36, $20, $ff, $60, $69, $cd, $1e, $09, $c3
	db $0b, $05, $01, $c0, $7b, $18, $ee, $01, $c5, $7b, $18, $e9, $d7, $c0, $ff, $01
	db $00, $80, $cd, $e2, $05, $0e, $00, $3e, $60, $cd, $71, $63, $01, $00, $04, $cd
	db $64, $05, $3e, $48, $c3, $15, $05, $cd, $89, $64, $c8, $16, $c0, $cd, $7f, $30
	db $16, $cc, $28, $1a, $fa, $0f, $c0, $c6, $08, $fe, $6a, $30, $40, $16, $c0, $cd
	db $ff, $2f, $16, $cc, $20, $37, $fa, $0f, $c0, $c6, $08, $ea, $0f, $c0, $01, $f4
	db $fc, $21, $c0, $c0, $cd, $61, $64, $01, $fc, $e4, $21, $d4, $7b, $cd, $57, $64
	db $01, $fc, $04, $21, $e0, $7b, $cd, $57, $64, $cd, $83, $65, $d8, $3e, $1a, $cd
	db $15, $05, $3e, $20, $cd, $e6, $08, $ff, $3e, $40, $c3, $ce, $06, $3e, $01, $ea
	db $c1, $ca, $c9, $fa, $01, $c0, $fe, $03, $30, $0a, $21, $c0, $ca, $cb, $c6, $21
	db $07, $c0, $cb, $c6, $d7, $c0, $fa, $c1, $ca, $a7, $c0, $cd, $26, $04, $3e, $ac
	db $77, $ea, $96, $ca, $21, $c0, $ca, $cb, $86, $cd, $30, $07, $c3, $8c, $5e, $1e
	db $01, $1a, $a7, $c2, $ae, $08, $01, $fc, $ff, $cd, $98, $05, $cd, $38, $08, $c8
	db $ff, $cd, $c6, $05, $01, $00, $01, $c3, $64, $05, $21, $65, $7b, $fa, $82, $c9
	db $cb, $5f, $ca, $1e, $09, $21, $6b, $7b, $c3, $1e, $09, $e5, $cd, $2a, $37, $1e
	db $02, $1a, $fe, $0b, $38, $1e, $af, $cd, $59, $7b, $cd, $22, $37, $1e, $01, $1a
	db $fe, $03, $28, $10, $62, $2e, $02, $3e, $10, $96, $87, $3d, $1e, $1c, $12, $3e
	db $8e, $cd, $59, $7b, $e1, $1e, $1c, $1a, $5f, $7c, $cd, $59, $7b, $1d, $c8, $7d
	db $cd, $59, $7b, $1d, $c8, $18, $f2, $cd, $07, $0b, $0d, $cd, $07, $0b, $0c, $3e
	db $20, $df, $c9, $24, $99, $40, $41, $42, $ff, $24, $99, $67, $41, $68, $ff, $24
	db $99, $40, $41, $42, $43, $fe, $43, $99, $00, $44, $45, $46, $47, $fe, $63, $99
	db $00, $48, $49, $4a, $4b, $fe, $84, $99, $4c, $4d, $4e, $4f, $ff, $25, $99, $54
	db $55, $56, $fe, $46, $99, $57, $58, $fe, $64, $99, $59, $49, $5a, $5b, $fe, $84
	db $99, $5c, $5d, $5e, $5f, $ff, $24, $99, $60, $61, $fe, $43, $99, $62, $63, $fe
	db $63, $99, $64, $65, $fe, $84, $99, $66, $ff, $44, $99, $6b, $6c, $ff, $44, $99
	db $69, $6a, $ff, $44, $99, $6d, $6e, $fe, $64, $99, $6f, $70, $fe, $84, $99, $71
	db $72, $ff, $00, $00, $00, $00, $73, $74, $75, $76, $73, $74, $75, $76, $7a, $7e
	db $7b, $00, $74, $74, $74, $74, $74, $74, $74, $74, $cd, $64, $05, $01, $00, $02
	db $cd, $52, $05, $fa, $0f, $c0, $4f, $06, $60, $cd, $8a, $06, $2e, $00, $36, $66
	db $3e, $5a, $e7, $14, $c9, $f7, $fe, $98, $d8, $c3, $33, $07, $1e, $01, $1a, $a7
	db $20, $0f, $cd, $8d, $06, $ff, $01, $53, $7d, $cd, $be, $02, $3e, $48, $c3, $15
	db $05, $01, $53, $7d, $cd, $b1, $06, $c0, $c3, $33, $07, $cd, $4b, $00, $44, $7c
	db $3e, $59, $5a, $7c, $71, $7c, $84, $7c, $9d, $7c, $c5, $7c, $d1, $7c, $30, $7d
	db $40, $7d, $cd, $82, $4e, $cd, $47, $05, $cd, $f5, $23, $cd, $86, $06, $3e, $61
	db $cd, $10, $05, $3e, $60, $c3, $e5, $3c, $cd, $9b, $0b, $c2, $8d, $4e, $01, $a0
	db $ff, $cd, $6c, $05, $3e, $52, $e7, $3e, $21, $cd, $15, $05, $c3, $e8, $3c, $fa
	db $0f, $c0, $fe, $38, $c2, $d6, $08, $ea, $1a, $c0, $3e, $c0, $ea, $80, $ca, $c3
	db $e8, $3c, $cd, $9c, $4e, $fe, $05, $c0, $01, $4e, $7d, $cd, $be, $02, $14, $01
	db $1c, $9c, $cd, $e2, $05, $cd, $f5, $23, $c3, $e8, $3c, $cd, $9c, $4e, $cd, $b4
	db $06, $01, $4e, $7d, $c2, $98, $02, $16, $cc, $01, $40, $ff, $cd, $ec, $7b, $01
	db $00, $00, $cd, $ec, $7b, $01, $c0, $00, $cd, $ec, $7b, $3e, $44, $cd, $15, $05
	db $c3, $e8, $3c, $fa, $00, $cc, $b7, $c2, $9c, $4e, $3e, $20, $c3, $e5, $3c, $cd
	db $9c, $4e, $fa, $82, $c9, $e6, $07, $c0, $cd, $9b, $0b, $28, $1a, $cd, $cc, $07
	db $54, $36, $67, $cd, $4b, $16, $34, $e6, $3f, $c6, $14, $4f, $cd, $4b, $16, $e6
	db $0f, $c6, $94, $47, $c3, $e2, $05, $3e, $52, $e7, $01, $38, $00, $cd, $6c, $05
	db $16, $c1, $01, $20, $f8, $cd, $ba, $08, $af, $cd, $07, $0b, $01, $f8, $00, $cd
	db $ba, $08, $3e, $8b, $cd, $07, $0b, $3c, $04, $cd, $07, $0b, $01, $00, $00, $cd
	db $ba, $08, $11, $07, $01, $cd, $0c, $0b, $cd, $3c, $0b, $c3, $e8, $3c, $fa, $0f
	db $c0, $fe, $57, $c2, $dc, $2e, $ea, $1a, $c0, $3e, $c0, $c3, $e5, $3c, $cd, $9b
	db $0b, $c2, $9c, $4e, $3e, $5d, $ea, $0f, $c0, $c3, $80, $4d, $34, $53, $01, $54
	db $ff, $08, $56, $08, $57, $08, $58, $ff, $01, $82, $99, $cd, $7b, $74, $21, $76
	db $1f, $cd, $42, $20, $af, $ea, $95, $c9, $11, $00, $4f, $cd, $65, $1e, $cd, $8d
	db $1e, $cd, $a9, $7d, $c3, $f7, $15, $cd, $3d, $09, $c0, $3e, $50, $cd, $10, $05
	db $cd, $43, $1e, $3e, $5c, $c3, $f4, $15, $fa, $ff, $cd, $3c, $28, $0c, $fa, $aa
	db $cd, $c7, $ba, $7d, $c6, $7d, $de, $7d, $e6, $7d, $fa, $a5, $cd, $fe, $06, $28
	db $11, $3d, $cb, $97, $ea, $aa, $cd, $21, $a5, $cd, $7e, $34, $21, $f8, $5b, $c3
	db $5a, $09, $af, $cd, $f4, $15, $18, $ef, $cd, $d5, $7d, $cd, $07, $74, $01, $a3
	db $98, $c3, $ea, $0a, $cd, $74, $1e, $11, $6f, $57, $01, $12, $99, $cd, $d5, $7d
	db $c3, $07, $0b, $cd, $20, $74, $21, $81, $c9, $36, $04, $c9, $11, $4d, $54, $01
	db $0d, $99, $18, $e9, $11, $46, $55, $01, $ef, $98, $cd, $cf, $7d, $3c, $0c, $c3
	db $07, $0b, $cd, $20, $74, $18, $c4, $af, $cd, $2b, $05, $af, $c3, $f4, $15, $cd
	db $4b, $00, $0a, $7e, $97, $7e, $ca, $7e, $cd, $d1, $1f, $06, $ab, $cd, $43, $20
	db $cd, $74, $1e, $01, $48, $11, $cd, $93, $11, $cd, $4f, $7e, $fa, $a5, $cd, $fe
	db $04, $28, $13, $fe, $07, $cc, $8d, $7e, $14, $cd, $9e, $06, $1e, $00, $16, $68
	db $cd, $99, $1e, $c3, $e8, $3c, $14, $01, $7c, $bc, $cd, $e2, $05, $cd, $86, $06
	db $3e, $12, $e7, $01, $2f, $1c, $cd, $96, $11, $1e, $50, $18, $e1, $16, $c0, $21
	db $6d, $7e, $fa, $a5, $cd, $87, $87, $ef, $cd, $5e, $7e, $14, $4e, $23, $46, $23
	db $e5, $cd, $e2, $05, $2e, $08, $34, $e1, $c3, $86, $06, $28, $bc, $74, $e4, $28
	db $bc, $74, $e6, $24, $bc, $74, $ea, $28, $c0, $74, $e2, $18, $bc, $4d, $e6, $24
	db $bc, $74, $e4, $20, $bc, $74, $e6, $1f, $bc, $6c, $e6, $3e, $31, $cd, $8f, $06
	db $06, $eb, $c3, $43, $20, $cd, $8d, $1e, $21, $14, $c0, $35, $24, $34, $24, $35
	db $21, $92, $c9, $34, $c0, $21, $e0, $cd, $af, $cf, $cd, $1e, $09, $01, $e0, $cd
	db $7d, $02, $0c, $7c, $02, $fa, $a5, $cd, $fe, $04, $cc, $c4, $7e, $3e, $f0, $c3
	db $e5, $3c, $11, $70, $4f, $c3, $65, $1e, $cd, $9b, $0b, $c0, $cd, $80, $1e, $cd
	db $3c, $0b, $21, $a5, $cd, $7e, $34, $fe, $07, $c2, $ed, $3c, $af, $cd, $2b, $05
	db $3e, $0e, $c3, $e6, $15, $69, $98, $1b, $17, $25, $18, $14, $15, $fe, $ac, $98
	db $1b, $17, $23, $23, $13, $fe, $78, $98, $1d, $19, $29, $29, $13, $fe, $bb, $98
	db $1d, $14, $26, $19, $11, $ff, $69, $98, $10, $11, $17, $1c, $22, $13, $fe, $ad
	db $98, $1d, $17, $1c, $22, $fe, $98, $98, $1e, $17, $15, $15, $1b, $12, $11, $11
	db $ff, $89, $98, $20, $12, $1a, $18, $16, $23, $fe, $98, $98, $1e, $19, $1e, $19
	db $ff, $69, $98, $25, $20, $19, $15, $11, $14, $13, $fe, $a9, $98, $18, $20, $14
	db $00, $11, $16, $16, $23, $fe, $78, $98, $1c, $12, $11, $12, $1a, $19, $18, $13
	db $fe, $ba, $98, $1c, $16, $13, $16, $18, $14, $ff, $89, $99, $1b, $16, $16, $22
	db $27, $16, $15, $1a, $fe, $98, $99, $25, $27, $14, $14, $18, $19, $14, $fe, $00
	db $9c, $11, $19, $18, $18, $11, $14, $fe, $41, $9c, $1b, $14, $14, $10, $14, $15
	db $ff, $69, $98, $1f, $16, $1f, $16, $fe, $ad, $98, $1d, $16, $1d, $16, $fe, $98
	db $98, $25, $23, $14, $14, $29, $14, $15, $ff, $69, $98, $1c, $16, $23, $1c, $16
	db $15, $1d, $fe, $ab, $98, $1c, $16, $23, $1d, $16, $15, $fe, $98, $98, $14, $11
	db $1a, $13, $15, $12, $ff, $69, $98, $1a, $16, $23, $18, $12, $23, $12, $fe, $ae
	db $98, $1a, $12, $28, $fe, $78, $98, $1b, $12, $1b, $25, $fe, $bb, $98, $1b, $17
	db $23, $23, $13, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $01
