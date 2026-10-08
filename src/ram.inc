; Named RAM / IO addresses.
; Format: DEF name EQU $addr ;@ type description
;   type: u8 | u16 (little endian) | u8[N] | code[N] | const
; Lines without ";@" are plain constants.
DEF hWX EQU $FFB5 ;@ u8 Window X position, copied to rWX every frame
DEF hWY EQU $FFB6 ;@ u8 Window Y position, copied to rWY every frame
DEF hScrollX EQU $FFB7 ;@ u16 Background scroll X (16-bit, the low byte goes to rSCX every frame)
DEF hScrollY EQU $FFBB ;@ u16 Background scroll Y (16-bit, the low byte goes to rSCY every frame)
DEF hSpriteX EQU $FFC3 ;@ u16 Metasprite to draw: world X position
DEF hSpriteY EQU $FFC5 ;@ u16 Metasprite to draw: world Y position
DEF hSpriteSet EQU $FFC7 ;@ u8 Metasprite to draw: index into the sprite set table
DEF hSpriteFrame EQU $FFC8 ;@ u8 Metasprite to draw: frame within the set
DEF hSpriteTileBase EQU $FFC9 ;@ u8 Metasprite to draw: added to every tile number
DEF hSpriteAttr EQU $FFCA ;@ u8 Metasprite to draw: XORed into every attribute byte (bit 5 also mirrors the offsets)
DEF hOAMCount EQU $FFCB ;@ u8 Number of shadow OAM slots used this frame (0-40)
DEF hSpriteScreenY EQU $FFCD ;@ u16 Metasprite OAM Y origin (Y position on screen + 16)
DEF hSpriteScreenX EQU $FFCF ;@ u16 Metasprite OAM X origin (X position on screen + 8)
DEF hSpriteScreenXFlip EQU $FFD1 ;@ u16 Metasprite OAM X origin for mirrored sprites (hSpriteScreenX - 8)
DEF hSpriteClip EQU $FFD3 ;@ u8 Hides sprites by OAM Y: 1 hides those above OAM line $34, 2 those from line $71 on, 0 none
DEF hSpriteBGTile EQU $FFD4 ;@ u8 Background tiles from this number up cover sprites (when hSpriteClip is set)
DEF hNumber EQU $FFD5 ;@ u8[3] 24-bit number being converted to decimal (little endian)
DEF hDivisorHigh EQU $FFDB ;@ u8 High byte of the 24-bit divisor for DecimalDigit24
DEF hLZMarker EQU $FFAB ;@ u8 Decompression: the byte value that marks a back-reference
DEF hLZDest EQU $FFAC ;@ u16 Decompression: start of the output
DEF hLZCount EQU $FFAF ;@ u8 Decompression: bytes left in the current back-reference
DEF hLZOffset EQU $FFB0 ;@ u8 Decompression: low byte of the current back-reference offset
DEF hLZEnd EQU $FFB1 ;@ u16 Decompression: end of the output (start + length)
DEF hLZStart EQU $FFB3 ;@ u16 Decompression: start of the output
DEF wShadowOAM EQU $C000 ;@ u8[160] Shadow OAM, 40 sprites of Y, X, tile, attribute; copied to OAM by DMA each VBlank
DEF wNumberBackup EQU $C0A0 ;@ u8[3] Copy of hNumber while a digit is tested
DEF wTilemapBuffer EQU $C500 ;@ u8[576] Copy of the visible background, 18 rows of 32 tiles (restored after a yes/no window)
DEF wMapUpdateDest EQU $C740 ;@ u16 BG map address for the row/column the VBlank handler writes (0 = nothing to do)
DEF wMapUpdateDir EQU $C742 ;@ u8 Direction of the map update: 0 a row (left to right), else a column (top to bottom); $FF disabled
DEF wMapUpdateLen EQU $C743 ;@ u8 Number of tiles in the map update
DEF wMapUpdateTiles EQU $C744 ;@ u8 Tiles of the map update, followed by their CGB attributes
DEF wSGBJoypads EQU $C76C ;@ u8[8] Super Game Boy multiplayer pads: held, newly pressed for each of the 4 players
DEF wSGBPacketID EQU $C774 ;@ u8 Number of the SGB packet to send from the packet table ($FF = send wSGBPacket)
DEF wSGBPacket EQU $C777 ;@ u8[16] Super Game Boy packet built in RAM
DEF wSGBPalettes EQU $C7D7 ;@ u8[32] Current (faded) SGB palette colors, 4 palettes of 4 RGB555 colors
DEF wSGBPalettesTarget EQU $C7F7 ;@ u8[32] SGB palette colors the fade starts from / ends at
DEF wOnSGB EQU $C81C ;@ u8 Nonzero when the game runs on a Super Game Boy
DEF wOnCGB EQU $C81D ;@ u8 Nonzero when the game runs on a Game Boy Color
DEF wTextGroup EQU $C822 ;@ u8 Text number, high byte (table group)
DEF wTextIndex EQU $C823 ;@ u8 Text number, low byte (entry in the group)
DEF wTextBank EQU $C824 ;@ u8 ROM bank of the text being printed
DEF wTextState EQU $C825 ;@ u8 Text printer state: bit 0 printing, 1 no delay, 2 waiting for a button, 3 custom speed, 5 prompt arrow shown, 6 timed wait (skippable), 7 timed pause
DEF wTextFlags EQU $C826 ;@ u8 Text printer flags: bit 0 beep per letter, 1 letter just printed, 7 a button sped it up
DEF wTextTiles EQU $C827 ;@ u16 VRAM address of the text box's letter tiles
DEF wTextBoxLines EQU $C829 ;@ u8 Number of text lines in the text box
DEF wTextBoxLineLength EQU $C82A ;@ u8 Number of characters in one line of the text box
DEF wTextCursor EQU $C82B ;@ u16 VRAM address where the next letter's tile is drawn
DEF wTextPtr EQU $C82D ;@ u16 Read pointer into the text
DEF wTextLineStart EQU $C82F ;@ u16 VRAM address of the start of the current text line
DEF wTextStart EQU $C831 ;@ u16 Start of the text being printed
DEF wTextSpeed EQU $C833 ;@ u8 Frames per letter when wTextState bit 3 is set (else 2)
DEF wTextWaitTimer EQU $C835 ;@ u8 Frames left in a wait that a button can cut short
DEF wTextPauseTimer EQU $C836 ;@ u8 Frames left in a pause
DEF wTextCopyDest EQU $C837 ;@ u16 Destination buffer for CopyTextString
DEF wTextDelay EQU $C839 ;@ u8 Frames since the last letter
DEF wTextControlCode EQU $C83A ;@ u8 Last control code ($E0-$FF) read from the text
DEF wTextChoice EQU $C83C ;@ u8 Yes/no answer: 0 yes, 1 no
DEF wTextBoxMap EQU $C83E ;@ u16 BG map address of the text box's top left corner
DEF wTextBeep EQU $C840 ;@ u8 Sound effect played for each letter
DEF wJoy2Active EQU $C841 ;@ u8 Nonzero when a second pad is read
DEF wJoyHeld EQU $C842 ;@ u8 Buttons held (bit 7-4 Down Up Left Right, 3-0 Start Select B A)
DEF wJoyHeldLast EQU $C843 ;@ u8 wJoyHeld of the previous frame
DEF wJoy2Held EQU $C844 ;@ u8 Second pad (Super Game Boy player 2 or the link partner): buttons held
DEF wJoy2HeldLast EQU $C845 ;@ u8 wJoy2Held of the previous frame
DEF wJoyPressed EQU $C846 ;@ u8 Buttons newly pressed this frame
DEF wJoyRepeat EQU $C847 ;@ u8 Buttons newly pressed, plus auto-repeat of held buttons
DEF wJoyRepeatTimer EQU $C848 ;@ u8 Frames until the next auto-repeat
DEF wJoy2Pressed EQU $C84A ;@ u8 Second pad: buttons newly pressed
DEF wJoy2Repeat EQU $C84B ;@ u8 Second pad: newly pressed plus auto-repeat
DEF wJoy2RepeatTimer EQU $C84C ;@ u8 Second pad: frames until the next auto-repeat
DEF wLinkJoyHeld EQU $C84E ;@ u8 Own buttons held, kept for the link partner
DEF wLinkJoyHeldLast EQU $C84F ;@ u8 Own buttons held last frame, kept for the link partner
DEF wFadeState EQU $C850 ;@ u8 Palette fade: 0 none, else speed; bit 7 set = fading in, clear = fading out
DEF wFadeType EQU $C851 ;@ u8 Fade colors: bit 7 set = black, clear = white; bits 0-2 which of BGP, OBP0, OBP1 fade on a Game Boy
DEF wFadeSGBMask EQU $C852 ;@ u8 Which SGB palettes fade: bits 0-3 palettes 0-3, bit 4 palettes 2-3 are sent too
DEF wFadePalettes EQU $C853 ;@ u8[3] BGP, OBP0, OBP1 the fade starts from / ends at
DEF wFadeLevel EQU $C856 ;@ u8 Current fade level (Game Boy 0-4, SGB 0-31)
DEF wFadeSpeed EQU $C857 ;@ u8 Frames between fade steps
DEF wFadeTimer EQU $C858 ;@ u8 Frames until the next fade step
DEF wFadeColorOffset EQU $C85A ;@ u8 Byte offset of the SGB color being faded
DEF wLinkActive EQU $C86C ;@ u8 Nonzero while two Game Boys are connected by link cable
DEF wLinkSendLength EQU $C871 ;@ u16 Bytes left in the link send buffer
DEF wLinkSendByte EQU $C873 ;@ u8 Single byte to send over the link next ($FF = none)
DEF wLinkSendPtr EQU $C874 ;@ u16 Read pointer into the link send buffer
DEF wVBlankEndLY EQU $C886 ;@ u8 LY when the VBlank handler finished (a timing measure)
DEF wGameMode EQU $C88A ;@ u8 Current game mode (index into GameModeInitTable / GameModeUpdateTable)
DEF wGameModeStep EQU $C88B ;@ u8 Step within the current game mode
DEF wGameModeChange EQU $C88E ;@ u8 Set to leave the current game mode and start wGameMode anew
DEF wRandomHigh EQU $C899 ;@ u8 Random number generator state, high byte
DEF wRandomLow EQU $C89A ;@ u8 Random number generator state, low byte
DEF wBGP EQU $C89B ;@ u8 Background palette (Game Boy), written to rBGP every frame
DEF wOBP0 EQU $C89C ;@ u8 Sprite palette 0 (Game Boy), written to rOBP0 every frame
DEF wOBP1 EQU $C89D ;@ u8 Sprite palette 1 (Game Boy), written to rOBP1 every frame
DEF wDefaultPalettes EQU $C89E ;@ u8[3] Initial BGP, OBP0, OBP1
DEF wLCDC EQU $C8A1 ;@ u8 Copy of rLCDC, written back every frame
DEF wVBlankFlags EQU $C8A2 ;@ u8 Bit 0 set while the VBlank handler runs (a VBlank arriving meanwhile only updates sound)
DEF wMapUpdateOn EQU $C8A3 ;@ u8 Nonzero: the VBlank handler copies the queued map row/column
DEF wFrameCounter EQU $C8A4 ;@ u16 Counts the frames the game logic ran
DEF wDebugSavedMode EQU $C8AD ;@ u8[4] Game mode variables saved when a debug menu was opened (that code is switched off)
DEF wShakeY EQU $C8B1 ;@ u8 Frames of vertical screen shake left
DEF wShakeX EQU $C8B2 ;@ u8 Frames of horizontal screen shake left
DEF wMusic EQU $C8B5 ;@ u8 Song now playing
DEF wQueuedMusic EQU $C8B7 ;@ u8 Song to start in the next VBlank ($FF = none)
DEF wQueuedSound EQU $C8B8 ;@ u8 Sound effect to start in the next VBlank ($FF = none)
DEF wSoundBusy EQU $C8B9 ;@ u8 Nonzero while the sound engine update runs
DEF wLinkTimeout EQU $C8C8 ;@ u16 Frames without an answer from the link partner (resets the game at 256)
DEF wDecompressBusy EQU $DA78 ;@ u8 Nonzero while a decompression runs
DEF wSoundID EQU $DE24 ;@ u8 Song or sound effect number handed to the sound engine
DEF hPlayerGfx EQU $FF8A ;@ u8 Player sprite graphics set handed to the sprite animator
DEF hPlayerFrame EQU $FF8B ;@ u8 Player animation frame
DEF hPlayerTileBase EQU $FF8C ;@ u8 First VRAM tile of the player sprite
DEF hPlayerAttr EQU $FF8D ;@ u8 Player OAM attributes ($20 = mirrored, when walking left)
DEF hPlayerDir EQU $FF8E ;@ u8 Player direction: 0 down, 1 left, 2 up, 3 right
DEF hPlayerPose EQU $FF8F ;@ u8 Player sprite pose: 0 front, 1 side, 2 back
DEF hPlayerFlags EQU $FF90 ;@ u8 bit0 moving, bit1 carried by a conveyor, bit4 walked into a map edge, bit5 overlapping an object, bit6/7 frozen
DEF hPlayerXSub EQU $FF91 ;@ u8 Player X, fraction byte
DEF hPlayerX EQU $FF92 ;@ u16 Player X in map pixels (the tile centre is at +8)
DEF hPlayerYSub EQU $FF94 ;@ u8 Player Y, fraction byte
DEF hPlayerY EQU $FF95 ;@ u16 Player Y in map pixels
DEF hPlayerTileX EQU $FF97 ;@ u8 Player column in 16-pixel map tiles
DEF hPlayerTileY EQU $FF98 ;@ u8 Player row in 16-pixel map tiles
DEF hPlayerPrevX EQU $FF99 ;@ u16 Player X at the end of the previous frame
DEF hPlayerPrevY EQU $FF9B ;@ u16 Player Y at the end of the previous frame
DEF hMapWidth EQU $FF9D ;@ u16 Map width in pixels
DEF hMapHeight EQU $FF9F ;@ u16 Map height in pixels
DEF hPlayerSpeedX EQU $FFA1 ;@ u16 Horizontal speed (signed, 1/256 pixel per frame)
DEF hPlayerSpeedY EQU $FFA3 ;@ u16 Vertical speed (signed, 1/256 pixel per frame)
DEF hTestX EQU $FFA5 ;@ u16 Map X to test for collision (GetCollisionAt)
DEF hTestY EQU $FFA7 ;@ u16 Map Y to test for collision
DEF hTestResult EQU $FFA9 ;@ u8 Collision result: $FF blocked (or off the map), $0F passable
DEF hTestTile EQU $FFAA ;@ u8 Map tile found at the tested spot
DEF hCameraPrevX EQU $FFB9 ;@ u16 Camera X of the previous frame
DEF hCameraPrevY EQU $FFBD ;@ u16 Camera Y of the previous frame
DEF hFindY EQU $FFDD ;@ u16 Position to look up an object at
DEF wMapId EQU $C968 ;@ u8 Current map (town, Great Tree rooms and fixed world maps)
DEF wOnGateFloor EQU $C969 ;@ u8 Non-zero while on a randomly generated floor behind a gate
DEF wPrevMapId EQU $C96A ;@ u8 Map before the last map load
DEF wPrevOnGateFloor EQU $C96B ;@ u8 wOnGateFloor before the last map load
DEF wWarpPending EQU $C96C ;@ u8 Non-zero: the next map load uses wWarpMap / wWarpX / wWarpY
DEF wWarpMap EQU $C96D ;@ u16 Destination map of a pending warp
DEF wWarpX EQU $C96F ;@ u16 Destination X of a pending warp
DEF wWarpY EQU $C971 ;@ u16 Destination Y of a pending warp
DEF wPlayerTrail EQU $C973 ;@ u8[196] Ring buffer of the last 49 player positions (4 bytes each), the party follows it
DEF wTrailPos EQU $CA37 ;@ u8 Next entry of wPlayerTrail to write
DEF wMapLoadState EQU $C88F ;@ u8 0 normal, 1 waiting to load the new map, 2 fading the new map in
DEF wFieldTimer EQU $C8A6 ;@ u16 Counts field frames (tile animations, palette cycles)
DEF wPlayerPause EQU $C8A8 ;@ u8 Frames the player stands still (after turning around or taking damage)
DEF wFieldPaused EQU $C8AA ;@ u8 Non-zero: field updates are paused
DEF wDebugSetup EQU $C8AB ;@ u8 Non-zero: the next field start sets up a debug party, gold and items
DEF wGameStarted EQU $C8EA ;@ u8 Non-zero once the new-game state has been set up ($80 special)
DEF wFieldFlags EQU $C8EB ;@ u8 bit0 field event pending, bit2 screen scrolling, bit1/3/4/5/6/7 other field states that stop the player
DEF wScrollDir EQU $C91D ;@ u8 Direction of the screen scroll: 0 left, 1 right, 2 up, 3 down
DEF wEventStep EQU $C915 ;@ u16 Step counter of the pending field event
DEF wEventRoutine EQU $C917 ;@ u16 Text id of the field event to show
DEF wScriptMap EQU $D8D3 ;@ u8 Map whose script is run
DEF wScriptId EQU $D8D4 ;@ u8 Script number within the map
DEF wScriptRunning EQU $D8D7 ;@ u8 Non-zero while a map script controls the field
DEF wPlayerAnimPtr EQU $D7B4 ;@ u16 Animation state the animator works on (points at wPlayerAnimTimer)
DEF wPlayerAnimTimer EQU $D7B6 ;@ u8 Player animation timer
DEF wPlayerAnimGfx EQU $D7B7 ;@ u8 Player animation graphics set
DEF wPlayerAnim EQU $D7B8 ;@ u8 Player animation: pose + 3 when walking, + 6 in scripts
DEF wPlayerAnimFrame EQU $D7BA ;@ u8 Frame the animator chose
DEF wPlayerAnimStep EQU $D7BB ;@ u8 Animation step
DEF wOverlapTimer EQU $D7BC ;@ u8 Frames the player has overlapped an object
DEF wActors EQU $D7D2 ;@ u8[256] Field actors, 32 bytes each, $FF ends the list
DEF wFloorObjects EQU $D793 ;@ u8[64] Objects on a gate floor (chests, holes), 4 bytes each, $FF ends the list
DEF wFloorObjectItem EQU $D78F ;@ u8 Content of the touched floor object ($FF trap, 0 gold, else item)
DEF wFoundGold EQU $D791 ;@ u16 Gold found in a chest
DEF wFloorEvent EQU $C92D ;@ u8 Floor event to start (4 every chest opened, 7 after 200 steps)
DEF wFloorSteps EQU $C92E ;@ u8 Steps on this floor since the last chest
DEF wGateWorld EQU $C935 ;@ u8 Gate world being explored
DEF wGateFloor EQU $C939 ;@ u8 Floor number in the gate world (0 = first)
DEF wGateFloors EQU $C93A ;@ u8 Number of floors of the gate world
DEF wGateWorldMap EQU $C93B ;@ u8 Map whose song the gate world plays
DEF wFloorLoot EQU $C93C ;@ u8 Kind of gold found in chests (1 small, 2 medium, else by floor)
DEF wFloorMusic EQU $C93D ;@ u8 Floor music / look from the floor table
DEF wFloorTable EQU $CA38 ;@ u8 Index of the floor's encounter table (FloorTables)
DEF wFloorStyle EQU $C8A9 ;@ u8 First byte of the floor table entry
DEF wStepTimer EQU $CA3B ;@ u16 Steps until party monsters grow tamer (counts 100 down)
DEF wFarmStepTimer EQU $CA3D ;@ u16 Steps until farm monsters grow wilder (counts 20 down)
DEF wPlayerName EQU $CA42 ;@ u8[4] Player name
DEF wGold EQU $CA4B ;@ u8[3] Gold, 24-bit little endian
DEF wBagItems EQU $CA51 ;@ u8[20] Items carried ($FF or 0 = empty)
DEF wStoredItems EQU $CA65 ;@ u8[40] Items kept in storage
DEF wPartyCount EQU $CA8D ;@ u8 Number of monsters in the party (0-3)
DEF wParty EQU $CA8E ;@ u8[3] Monster slots of the party ($FF = empty)
DEF wPartyGfx EQU $CA91 ;@ u8[3] Sprite graphics of each party monster (follower sprites)
DEF wCurPartyMember EQU $CAC0 ;@ u8 Party position the party helpers work on
DEF wMonsters EQU $CAC1 ;@ u8[2980] All 20 monsters the player owns, $95 bytes each (+0 0 none / 1 farm / 2 party)
DEF wEncCount EQU $DA02 ;@ u8 Encounter group size - 1
DEF wEncSpecies EQU $DA03 ;@ u8[6] Monster species of the encounter group (3 x u16, $FF = none)
DEF wPlayFrames EQU $CAB5 ;@ u8 Play time: frames (0-59)
DEF wPlaySeconds EQU $CAB6 ;@ u8 Play time: seconds
DEF wPlayMinutes EQU $CAB7 ;@ u8 Play time: minutes
DEF wPlayHours EQU $CAB8 ;@ u8 Play time: hours (stops at 99:59)
DEF wSceneObjects EQU $C0D8 ;@ u8[36] Cutscene objects (6 bytes each: hidden, X, Y, pose, script step, frames left); also used as a scratch buffer
DEF wSceneAux EQU $C0FA ;@ u8 Cutscene scratch: tile animation index or shake toggle
DEF wSceneAux2 EQU $C0F9 ;@ u8 Cutscene scratch: tile animation timer or swap temporary
DEF wSceneAux3 EQU $C0FB ;@ u8 Cutscene scratch: tile animation timer or swap temporary
DEF wSceneStep EQU $C0FC ;@ u8 Step of the running cutscene (also low byte of the object pointer for the far UpdateSceneObject entry)
DEF wSceneTimer EQU $C0FD ;@ u8 Frame counter of the current cutscene step
DEF wSceneObjectPtr EQU $C0FE ;@ u16 Object UpdateSceneObject is working on (also a row pointer for DrawTilemap)
DEF wPaletteSet EQU $C81E ;@ u8 Which palette set the CGB palette loader uses
DEF wLinkFlags EQU $C863 ;@ u8 Link state: bit 0 connected, bit 1 this Game Boy drives the clock (master)
DEF wSerialLock EQU $C864 ;@ u8 Bit 7: serial interrupts are ignored (bit 6 then notes that one was missed)
DEF wLinkMode EQU $C865 ;@ u8 Link mode the serial interrupt runs: 0 handshake, 1-3 the game modes played over the cable
DEF wLinkPhase EQU $C866 ;@ u8 Link transfer phase: 0 send, 1 receive
DEF wLinkReceived EQU $C86A ;@ u8 Last byte received over the link
DEF wLinkReceivedLast EQU $C86E ;@ u8 Copy of the last single byte received
DEF wLinkRecvPtr EQU $C86F ;@ u16 Write pointer into the link receive buffer
DEF wLinkChoice EQU $C8DA ;@ u8 Title menu cursor: 0 continue, 1 new game, 2 VS mode, 3 breeding (without a save only new game); bit 7 set once chosen
DEF wLinkRefused EQU $C8DF ;@ u8 Set to $FF when the partner's handshake byte did not match
DEF wLinkPartnerChoice EQU $C8E0 ;@ u8 Link mode the partner asked for (2 or 3) when ours differs
DEF wLinkNoEnd EQU $C8C7 ;@ u8 Nonzero: the partner's end byte $F3 is not looked for
DEF wMonSpecies EQU $DA31 ;@ u8 Monster number GetMonsterStats looks up
DEF wMonStats EQU $DA33 ;@ u8[43] Copy of a monster's record from MonsterStats
DEF wItemId EQU $DA5E ;@ u8 Item being checked or used ($FF afterwards = not usable / used up / not found)
DEF wItemBagSlot EQU $DA5F ;@ u8 Bag slot of the item being used
DEF wItemTarget EQU $DA60 ;@ u8 Party slot the item is used on
DEF wItemData EQU $DA62 ;@ u8[12] Copy of the item's ItemData record
DEF wItemUseUpChance EQU $DA65 ;@ u8 Item record byte 3: chance in percent that using the item uses it up
DEF wItemMessage EQU $DA6A ;@ u8 Message number for the party healing item ($26 + number of monsters it helps)
DEF wItemPower EQU $DA6B ;@ u8 Item record byte 9: base amount (healing, stat gain)
DEF wMonStatus EQU $CB0B ;@ u8 Party monster record field: status (bit 7 dead, bits 0-4 ailments); records are $95 bytes apart
DEF wMonHP EQU $CB11 ;@ u16 Party monster record field: HP
DEF wMonMaxHP EQU $CB13 ;@ u16 Party monster record field: maximum HP
DEF wMonMP EQU $CB15 ;@ u16 Party monster record field: MP
DEF wMonMaxMP EQU $CB17 ;@ u16 Party monster record field: maximum MP
DEF wMonAttack EQU $CB19 ;@ u16 Party monster record field: attack
DEF wMonDefense EQU $CB1B ;@ u16 Party monster record field: defense
DEF wMonAgility EQU $CB1D ;@ u16 Party monster record field: agility
DEF wMonIntelligence EQU $CB1F ;@ u16 Party monster record field: intelligence
DEF wMonName EQU $CAC2 ;@ u8[4] Party monster record field: name
DEF wTextArgs EQU $C1B0 ;@ u8[16] Strings and numbers that a message inserts
DEF wWorldFlags EQU $C93E ;@ u8 Flags for the current world visit (bit 1 set by an item)
DEF wFloorsSeen EQU $C950 ;@ u8[16] Seen flags per screen of the current floor map
DEF wGoalX EQU $C964 ;@ u16 X position of the floor's goal (the way on)
DEF wGoalY EQU $C966 ;@ u16 Y position of the floor's goal
DEF wShootingStarStage EQU $D9CB ;@ u8 Stage of the shooting-star event (0 before, 1 after the first shower, 2 after the second)
DEF wStoryStep EQU $D951 ;@ u8 Story progress counter (the shooting-star event runs at 7 and sets it to 8)
DEF wSGBPalSet EQU $C817 ;@ u8 Super Game Boy palette set of the field (4 palettes from SGBPalettes)
DEF wSGBAttrSet EQU $C818 ;@ u8 Super Game Boy attribute file of the field
DEF wSGBPalIds EQU $C85B ;@ u8[8] The 4 SGB palette numbers (u16 each) the fade works with
DEF wFieldStackPtr EQU $DA7B ;@ u16 Stack pointer saved when the field mode starts
DEF wLoadedGfxSet EQU $C81B ;@ u8 Super Game Boy border set now loaded ($FF none; see GetMapSGBBorder)
DEF wWarpOnGateFloor EQU $C96E ;@ u8 wOnGateFloor of the pending warp destination
DEF hOAMDMA EQU $FF80 ;@ code[10] OAM DMA routine (copied here from OAMDMARoutine at start-up)
DEF wHiddenSprites EQU $C8ED ;@ u8 Field sprites not drawn: bit 0 Terry, bits 1-3 the three party followers
DEF wScriptMenu EQU $C8EF ;@ u8 Menu a script opened (bank 12 runs 3 farm keeper, 8 monster library, 9 choose a monster, 10 item collector); set with wFieldFlags bit 4
DEF wScriptMenuText EQU $C8F0 ;@ u16 First message number of the open script menu (its messages are this + 1, + 2, ...)
DEF wMenuStep EQU $C905 ;@ u8 Step of the open script menu
DEF wMenuSubStep EQU $C906 ;@ u8 Step within the chosen menu option
DEF wMenuOverlay EQU $C8EC ;@ u8 Set while the monster status screen runs on top of a script menu
DEF wMenuChoice2 EQU $C8DB ;@ u8 Second menu cursor (party list, monsters/eggs choice, library page); bit 7 set once chosen
DEF wConfirmChoice EQU $C8DC ;@ u8 Cursor of a two-choice window (0 first choice, 1 second); bit 7 set once chosen
DEF wConfirmChoice2 EQU $C8DD ;@ u8 Cursor of a second two-choice window; bit 7 set once chosen
DEF wMenuChoice3 EQU $C8DE ;@ u8 Third menu cursor (party slot to exchange, release choice); bit 7 set once chosen
DEF wListLastRows EQU $C8E1 ;@ u8 Scratch of the list cursor: item count, then the rows on the last page - 1
DEF wListCursor EQU $C8E2 ;@ u8 Row of the cursor in a paged list; bit 7 set once chosen
DEF wListPage EQU $C8E3 ;@ u8 Page shown in a paged list
DEF wListKnown EQU $C8E8 ;@ u8 Entries of the list that are filled in (library: species already met)
DEF wListLength EQU $C8E9 ;@ u8 Number of entries in the paged list
DEF wChosenMonName EQU $C8F2 ;@ u16 Address of the name of the monster chosen in the choose-a-monster menu
DEF wChosenMonPic EQU $C8F4 ;@ u8 Species + $10 of the chosen monster (picture number), $FF = none chosen
DEF wChosenMonSpecies EQU $C8F5 ;@ u8 Species of the chosen monster
DEF wChosenMonGender EQU $C8F6 ;@ u8 Sex of the chosen monster (bit 0)
DEF wCollectedItems EQU $C903 ;@ u16 Items handed to the item collector so far (stops at 999)
DEF wItemsHandedIn EQU $C907 ;@ u8 Items the collector took from the bag this time
DEF wWindowBgMap EQU $C909 ;@ u16 BG map address of the screen's top left corner (where the menu windows are drawn)
DEF wCursorBlink EQU $C90C ;@ u8 Menu cursor blink counter (the cursor is redrawn every 16 frames, bit 4 hides it)
DEF wStatusViewVars EQU $C90D ;@ u8[2] Cleared before the monster status screen opens
DEF wViewList EQU $C930 ;@ u16 List of monster slots the monster status screen pages through
DEF wViewIndex EQU $C932 ;@ u8 Entry of wViewList the status screen starts at
DEF wViewCount EQU $C933 ;@ u8 Number of entries in wViewList
DEF wViewResult EQU $C934 ;@ u8 Entry of wViewList shown last when the status screen closed
DEF wFarm2Flags EQU $CA41 ;@ u8 Bit 7: the second farm pen in cartridge RAM is set up
DEF wLibraryFlags EQU $CA94 ;@ u8[28] One bit per monster species: the library has its entry
DEF wMonRecSpecies EQU $CACA ;@ u8 Party monster record field: species (records are $95 bytes apart)
DEF wMonGender EQU $CACC ;@ u8 Party monster record field: sex (bit 0)
DEF wMonMaster EQU $CACD ;@ u8[9] Party monster record field: master's name (compared with wPlayerName)
DEF wMonLevel EQU $CB0C ;@ u8 Party monster record field: level
DEF wMonEgg EQU $CB24 ;@ u8 Party monster record field: 0 monster, 1 egg, 2 egg whose sex is known
DEF sFarm2 EQU $B124 ;@ u8[2980] Second farm pen: 20 more monster records ($95 bytes each, laid out like wMonsters)
DEF wTextArg0 EQU $C180 ;@ u8[16] First string a message inserts (monster names, numbers)
DEF wTextArg1 EQU $C190 ;@ u8[16] Second string a message inserts
DEF wTextArg2 EQU $C1A0 ;@ u8[16] Third string a message inserts
DEF wPartyBarTiles EQU $C1C0 ;@ u8[64] Tiles of the party bar at the bottom of the screen: 2 rows of 32
DEF wSavedTilemap EQU $C300 ;@ u8[512] The first 16 rows of the background (32 wide) as they were before the menu opened
DEF wCollectorStep EQU $D9E1 ;@ u8 Rewards the item collector gave so far (0-4)
DEF wNewMonId EQU $DA12 ;@ u16 Monster to create as an egg (passed to the egg maker in bank $14)
DEF wNewMonSlot EQU $DA14 ;@ u8 Record slot the new egg goes into
DEF wNewMonNameText EQU $DA18 ;@ u8 Text number (in group 5) of the new monster's name
DEF wBreedQuery EQU $DA6F ;@ u8 Species whose breeding pair is looked up
DEF wBreedPair EQU $DA71 ;@ u8[2] Breeding pair of wBreedQuery: family number (0-$0F) or species + $10 each, $F0 and up = special, $FF none
DEF wScriptPos EQU $D8D5 ;@ u16 Word index of the next command in the running map script
DEF wScriptFlags EQU $D8D8 ;@ u8 Script flags: bit 0/1 set by script commands $3C/$3D, bit 2 a timed wait (wScriptWait) runs
DEF wScriptMessage EQU $D8D9 ;@ u16 Message the script asked for (printed by PrintScriptMessage when wScriptRunning bit 1 is set)
DEF wScriptWait EQU $D8DB ;@ u8 Frames (or 8-frame units) a script wait still lasts
DEF wScriptWalker EQU $D8DC ;@ u8 Who a script walk moves: 0 Terry, n actor n
DEF wScriptWalkX EQU $D8DD ;@ u16 Pixels the script walk still moves horizontally (signed)
DEF wScriptWalkY EQU $D8DF ;@ u16 Pixels the script walk still moves vertically (signed)
DEF wScriptResult EQU $D8E1 ;@ u8 Value a script test found (party position, count, rank), used by the messages
DEF wJumpHeight EQU $D8E3 ;@ u8 Height class (1-10) of the throw/fall arcs of mover types $15-$18
DEF wJumpFall EQU $D8E4 ;@ u8 Which fall table (1-4) mover types $15/$16 use
DEF wMovers EQU $D8E9 ;@ u8[64] 8 scripted movers, 8 bytes each: active, frame, type, actor (0 Terry), dx u16, dy u16
DEF wBattleKind EQU $DA09 ;@ u8 How the battle was started: 1 script, 2 random group, 3 special
DEF wMapScreen EQU $C925 ;@ u8 Screen of a multi-screen map Terry is on (row * 4 + column)
DEF wSavedMusic EQU $C8B6 ;@ u8 Song to go back to after a script changed the music
DEF wReturnMap EQU $C8FB ;@ u16 Map (and gate-floor flag) a script saved to come back to
DEF wReturnX EQU $C8FD ;@ u16 X position saved with wReturnMap
DEF wReturnY EQU $C8FF ;@ u16 Y position saved with wReturnMap
DEF wReturnDir EQU $C901 ;@ u8 Direction saved with wReturnMap
DEF wReturnActor EQU $C902 ;@ u8 Actor that turns to Terry when the script comes back (script command $43)
DEF wScriptMenuArg EQU $C8F7 ;@ u16 Argument of script command $42 for the field menu code
DEF wArenaClass EQU $D9CE ;@ u8 Starry Night tournament class being fought
DEF wArenaRound EQU $D9CD ;@ u8 Round within the tournament class
DEF wArenaWins EQU $D9CF ;@ u8 Tournament progress counter (bit 7 = stop counting)
DEF wArenaPrize EQU $D9D0 ;@ u8 Item won as the tournament prize
DEF wScriptChoiceRow EQU $D9DF ;@ u8 Row (1-5) used by script command $2E
DEF wScriptChoice EQU $D9E0 ;@ u8 Value script command $2E picked from its table
DEF wEncGfx EQU $D7CA ;@ u8[8] Encounter group sprites: graphics number and 1 for each of 3 monsters, plus 2 more bytes
DEF wLeaderSlot EQU $CA40 ;@ u8 Monster slot of the party leader
DEF wScriptBossIndex EQU $CAB4 ;@ u8 Index into the script's fixed-battle table (command $37)
DEF wSavedParty EQU $CAB9 ;@ u8[7] Copy of party count, slots and graphics restored by script command $45
DEF wScrollStep EQU $C91E ;@ u8 Step of the screen-to-screen scroll
DEF wHatchSlot EQU $C908 ;@ u8 Monster slot of the egg being hatched
DEF wListCursor2 EQU $C8E4 ;@ u8 Second monster list (the mates): cursor row; the egg gender change keeps its 24-bit price in $C8E4-$C8E6
DEF wListPage2 EQU $C8E5 ;@ u8 Second monster list (the mates): page shown
DEF wBreedParent1 EQU $D665 ;@ u8[149] Copy of the pedigree parent's record made when two monsters breed
DEF wBreedParent2 EQU $D6FA ;@ u8[149] Copy of the mate's record made when two monsters breed
DEF wBreedSpecies2 EQU $DA70 ;@ u8 Breeding: species of the mate
DEF wBreedSlot1 EQU $DA75 ;@ u8 Breeding: monster slot of the pedigree parent
DEF wBreedSlot2 EQU $DA76 ;@ u8 Breeding: monster slot of the mate
DEF wOffspringPlus EQU $DA77 ;@ u8 Breeding: plus value of the offspring
DEF wMonResistances EQU $DA42 ;@ u8[27] Part of wMonStats: the species' 27 resistance values
DEF sSaveValid EQU $A002 ;@ u8 Nonzero when the battery RAM holds a saved game
DEF sPlayerName EQU $A17C ;@ u8[4] Saved game: player name
DEF sPartyCount EQU $A1C7 ;@ u8 Saved game: number of party monsters
DEF sParty EQU $A1C8 ;@ u8[3] Saved game: monster slots of the party
DEF sPlayMinutes EQU $A1F1 ;@ u8 Saved game: play time minutes
DEF sPlayHours EQU $A1F2 ;@ u8 Saved game: play time hours
DEF sMonsters EQU $A1FB ;@ u8[2980] Saved game: the 20 monster records
DEF wNameInput EQU $C0C8 ;@ u8[10] Name being typed in the name entry: up to 8 letters, $9F = empty slot
DEF wNameLetterRows EQU $C0D2 ;@ u8[8] Name entry: for each letter typed, the keyboard column group it came from (decides which letters take a voicing mark)
DEF wPageToggle EQU $DF0D ;@ u8 Flips between 0 and 1 each time a paged list turns its page
DEF wNameCleared EQU $DF0E ;@ u8 Set once B has erased Terry's whole default name in the name entry (later presses erase one letter)
DEF wBankedGold EQU $CA4E ;@ u8[3] Gold kept in the vault, 24-bit little endian (at most 999,999)
DEF wMusicFadeDelay EQU $C894 ;@ u8 Frames between two volume steps of the music fade-out (0 = no fade running)
DEF wMusicFadeTimer EQU $C895 ;@ u8 Frames until the next volume step of the fade-out
DEF wMusicFadeSteps EQU $C896 ;@ u8 Volume steps the fade-out may still take
DEF wMusicFadeVolume EQU $C897 ;@ u8 Current master volume (rNR50 value) of the fade-out
DEF wSGBPacketPtr EQU $C775 ;@ u16 Where SGBAttrBlkAdd writes the next attribute block into wSGBPacket
DEF wScreenMap EQU $C200 ;@ u8[256] Decompressed map data of the current map screen
DEF wStatusBarMode EQU $CA3F ;@ u8 What the party status bar shows: 0 HP and MP, else level and status icons
DEF wEventFlags EQU $D99B ;@ u8[64] Story / event flags, one bit each (bit 7 of the first byte = flag 0)
DEF wLCDEffect EQU $C892 ;@ u8 Raster effect the LCD interrupt runs: 0 none, 1 hide sprites below the line, 2 per-line X scroll, 3 per-line Y scroll
DEF wLineScroll EQU $C100 ;@ u8[144] Scroll value per screen line for the wave raster effects
DEF wMonWildness EQU $CB21 ;@ u16 Party monster record field: wildness (drops as the party walks; a wild monster may not obey)
DEF wMonStat64 EQU $CB25 ;@ u8 Party monster record field +$64 (a byte stat, at most 255)
DEF wMonStat65 EQU $CB26 ;@ u8 Party monster record field +$65 (a byte stat, at most 255)
DEF wMonStat66 EQU $CB27 ;@ u8 Party monster record field +$66 (a byte stat, at most 255)
DEF wMonStat67 EQU $CB28 ;@ u8 Party monster record field +$67 (a byte stat, at most 255)
DEF wBattlerState EQU $DD1B ;@ u8[8] Per battle position (0-3 own side, 4-7 enemy side): 0 in the fight, $FF empty, other values out of action
DEF wBattlerStatus EQU $DB02 ;@ u8[64] Per battle position, 8 bytes of status flags (sleep, paralysis and the like)
DEF wBattlerHP EQU $DBA3 ;@ u8[16] HP of the 8 battle positions (u16 each)
DEF wBattlerMaxHP EQU $DBB3 ;@ u8[16] Maximum HP of the 8 battle positions (u16 each)
DEF wBattlerMP EQU $DBC3 ;@ u8[16] MP of the 8 battle positions (u16 each)
DEF wBattlerMaxMP EQU $DBD3 ;@ u8[16] Maximum MP of the 8 battle positions (u16 each)
DEF wBattlerAttack EQU $DBE3 ;@ u8[16] Attack of the 8 battle positions (u16 each)
DEF wBattlerDefense EQU $DBF3 ;@ u8[16] Defense of the 8 battle positions (u16 each)
DEF wBattlerAgility EQU $DC03 ;@ u8[16] Agility of the 8 battle positions (u16 each)
DEF wBattlerIntelligence EQU $DC13 ;@ u8[16] Intelligence of the 8 battle positions (u16 each)
DEF wSkillAnimActive EQU $DA80 ;@ u8 Nonzero while a skill animation plays in battle
DEF wSkillAnim EQU $DA81 ;@ u8 Skill animation number ($FF none; below $0E drawn by bank $5C, below $21 by $5D, else $5E)
DEF wSkillUser EQU $DB88 ;@ u8 Battle position of the monster using the skill (0-3 own side, 4-7 enemy side)
DEF wSkillTarget EQU $DB89 ;@ u8 Battle position the skill is aimed at
DEF wSkillId EQU $DB8A ;@ u8 Skill being used
DEF wEnemyCount EQU $DB75 ;@ u8 Number of enemy monsters in the battle (1-3)
DEF wEnemyDown EQU $DD1F ;@ u8[3] Nonzero for an enemy position that is empty or defeated (its animation is skipped)
DEF wSkillAnimSprites EQU $DD60 ;@ u8 Nonzero while the skill animation's sprites are drawn
DEF sChecksum EQU $A000 ;@ u16 Checksum of the save ($4638 + the sum of the bytes $A002-$BFFF)
DEF sSavedHRAM EQU $A003 ;@ u8[33] Copy of HRAM $FF8A-$FFAA (player position and map state)
DEF sSavedWRAM EQU $A024 ;@ u8[4352] Copy of WRAM $C8EA-$D9E9 (the game state: party, monsters, items, flags)
DEF sSavedScreenTiles EQU $BCC8 ;@ u8[512] Copy of wScreenTiles
DEF sSavedScreenMap EQU $BEC8 ;@ u8[256] Copy of wScreenMap
DEF wSoundChannels EQU $DD80 ;@ u8[156] Six sound channels of 26 bytes (the layout of the hChan variables); $FF in the first byte = free
DEF wSoundClaimed EQU $DE1C ;@ u8 NR51 bits of the hardware channels already written this frame (later channels leave them alone)
DEF wSoundPanning EQU $DE1D ;@ u8 rNR51 value being built by the sound update
DEF wSoundHWChannel EQU $DE1E ;@ u8 Hardware channel (0-3) of the channel being updated
DEF wSoundChannelBits EQU $DE1F ;@ u8 rNR51 bits (both sides) of that hardware channel
DEF wSoundChannelBits2 EQU $DE20 ;@ u8 Copy of wSoundChannelBits for the panning update
DEF wSoundRegOffset EQU $DE21 ;@ u8 Register offset of that hardware channel (0, 5, 10, 15 from rNR10)
DEF wSoundFrame EQU $DE22 ;@ u8 Counts sound updates (the vibrato phase)
DEF wSoundCurChannel EQU $DE23 ;@ u8 Channel (0-5) being updated
DEF wSyncSwitchChannels EQU $DE26 ;@ u8 Channels that switch their sound bank together at their next note (bit per channel)
DEF wSyncSwitchBank EQU $DE27 ;@ u8 Low nibble of the sound bank they switch to
DEF wSyncNoteEnds EQU $DE28 ;@ u8 Channels that started a new note this frame (bit per channel)
DEF wSoundFirstChannel EQU $DE29 ;@ u8 First channel the sound update runs (0 all, 4 sound effects only)
DEF wSoundWave EQU $DE2B ;@ u8 Wave pattern now in wave RAM
DEF hChanPos EQU $FFE4 ;@ u8 Sound channel being updated: event number, low byte ($FF with hChanPosHi $FF = channel off)
DEF hChanConfig EQU $FFE5 ;@ u8 bits 0-1 hardware channel, bit 7 vibrato on, bits 4-6 vibrato table
DEF hChanData EQU $FFE6 ;@ u16 Start of the channel's event data
DEF hChanBank EQU $FFE8 ;@ u8 ROM bank of the event data
DEF hChanDuty EQU $FFE9 ;@ u8 bits 6-7 duty, bit 4 second note table, bits 0-3 tempo slow-down
DEF hChanTempo EQU $FFEA ;@ u8 Tempo accumulator (a tick is skipped when it overflows past 16)
DEF hChanEnvelope EQU $FFEB ;@ u8 Volume envelope (NRx2 value)
DEF hChanNoteTimer EQU $FFEC ;@ u8 Ticks left in the current note
DEF hChanSweep EQU $FFED ;@ u8 Sweep (NR10) for channel 1, wave pattern number for the wave channel
DEF hChanLoop1 EQU $FFEE ;@ u8 Loop counter of the first loop command
DEF hChanLoop2 EQU $FFEF ;@ u8 Loop counter of the second loop command
DEF hChanInstLength EQU $FFF1 ;@ u8 Steps of the instrument envelope over one note
DEF hChanInstStep EQU $FFF2 ;@ u8 Current step within the note
DEF hChanVolSlide EQU $FFF3 ;@ u8 Volume slide: signed steps left (0 = none)
DEF hChanVolSlideRate EQU $FFF4 ;@ u8 Volume slide: ticks between steps
DEF hChanVolSlideTimer EQU $FFF5 ;@ u8 Volume slide: ticks to the next step
DEF hChanFreq EQU $FFF6 ;@ u16 Frequency (NRx3, NRx4 with the trigger bit)
DEF hChanLoopPos EQU $FFF8 ;@ u8 Event number the loop jumps back to (low byte)
DEF hChanPan EQU $FFF9 ;@ u8 NR51 bits this channel may set ($FF both sides)
DEF hChanVibDelay EQU $FFFA ;@ u8 Ticks of each note before the vibrato starts
DEF hChanVibTimer EQU $FFFB ;@ u8 Ticks left before the vibrato starts
DEF hChanInstrument EQU $FFFC ;@ u8 Instrument envelope table number
DEF hChanPosHi EQU $FFFD ;@ u8 Event number, high byte
DEF wScriptBlockPtr EQU $D8E7 ;@ u16 BG map address where a script tile block is being drawn
DEF wFieldMenuStep EQU $C90E ;@ u8 Step within the open field-menu option (also the step of the monster status screen)
DEF wMenuCount EQU $C90F ;@ u8 Number of entries in the field menu's current list (bag items, skills, monsters able to act)
DEF wMenuBgMap EQU $C911 ;@ u16 BG map address of the screen's top left corner while the field menu is open
DEF wLineUpPlaced EQU $C913 ;@ u8 Line-up menu: monsters already put into the new order
DEF wMenuBlink EQU $C914 ;@ u8 Field menu cursor blink counter (redrawn every 16 frames, bit 4 hides it)
DEF wMenuInfoPage EQU $C92F ;@ u8 Field menu: 1 while Start has switched the party panel to the player info page
DEF wLineUpOrder EQU $C0A3 ;@ u8[3] Line-up menu: the new party order picked so far ($FF = not yet)
DEF wMonFamily EQU $CACB ;@ u8 Party monster record field: family (0-9, text group 4)
DEF wMonParent1 EQU $CAD6 ;@ u8 Party monster record field: species of the first parent ($FF = none)
DEF wMonParent2 EQU $CAD7 ;@ u8 Party monster record field: species of the second parent ($FF = none)
DEF wMonParent1Master EQU $CAD8 ;@ u8[9] Party monster record field: master's name of the first parent
DEF wMonParent2Master EQU $CAE1 ;@ u8[9] Party monster record field: master's name of the second parent
DEF wMonSkills EQU $CAEA ;@ u8[8] Party monster record field: skills learned ($FF = none), shown as two pages of four
DEF wMonMaxLevel EQU $CB0D ;@ u8 Party monster record field: highest level the monster can reach
DEF wMonExp EQU $CB0E ;@ u8[3] Party monster record field: experience points (24-bit)
DEF wMonPlus EQU $CB23 ;@ u8 Party monster record field: plus value from breeding (shown as +N after the family)
DEF wMonParent1Name EQU $CB44 ;@ u8[8] Party monster record field: name of the first parent
DEF wMonParent1Plus EQU $CB4C ;@ u8 Party monster record field: plus value of the first parent
DEF wMonParent2Name EQU $CB4D ;@ u8[8] Party monster record field: name of the second parent
DEF wMonParent2Plus EQU $CB55 ;@ u8 Party monster record field: plus value of the second parent
DEF sSavedMonName EQU $A1FC ;@ u8[8] Saved monster record field: name
DEF sSavedMonFamily EQU $A205 ;@ u8 Saved monster record field: family
DEF sSavedMonLevel EQU $A246 ;@ u8 Saved monster record field: level
DEF wMonSkillList EQU $CAF2 ;@ u8[25] Party monster record field: skills it can still learn ($FF = none)
DEF wLevelGains EQU $C8CA ;@ u8[6] Stat gains of a level-up: HP, MP, attack, defense, agility, intelligence
DEF wOverLevelLimit EQU $C8D0 ;@ u8 Nonzero when the monster is past its level limit (smaller gains)
DEF wBaseGain EQU $C8D1 ;@ u8 Stat gain before the plus bonuses are added
DEF wCGBBGPalettes EQU $C797 ;@ u8[64] CGB background palettes, 8 x 4 RGB555 colors (fades and uploads work from here)
DEF wFloorNpcScreen EQU $C926 ;@ u8 Gate floor: screen where the floor's special character stands ($FF none)
DEF wFloorNpcX EQU $C927 ;@ u16 Gate floor: X of that character
DEF wFloorNpcY EQU $C929 ;@ u16 Gate floor: Y of that character
DEF wFloorNpcKind EQU $C92B ;@ u8 Gate floor: which character it is (object list of GateFloorNpcLists)
DEF wFloorLayout EQU $C940 ;@ u8[16] Gate floor: the 4 x 4 screens of the floor ($Fx = no screen there)
DEF wStairsScreen EQU $C960 ;@ u8 Gate floor: screen with the stairs to the next floor
DEF wStairsOffset EQU $C962 ;@ u16 Gate floor: offset of the stairs in the screen's tilemap
DEF wActorGfxSlots EQU $D7BE ;@ u8[12] Actor sprite graphics loaded in VRAM: 6 slots of (graphics number, source), $FF free
DEF wTitleStep EQU $C8D2 ;@ u8 Step of the title menu, and of the link modes run from it (VS battle, breeding)
DEF wTitleSubStep EQU $C8D3 ;@ u8 Sub-step within the current title menu step
DEF wTitleBgMap EQU $C8D6 ;@ u16 BG map address of the screen's top left corner (where the tilemap buffer is copied)
DEF wTitleBlink EQU $C8D9 ;@ u8 Menu cursor blink counter of the title and link menus (bit 4 hides the cursor)
DEF wLinkCommand EQU $C86D ;@ u8 Byte the title menu sends to the partner once ($F0 VS mode, $F1 breeding; 0 none)
DEF wMessageSpeed EQU $C8EE ;@ u8 Message speed setting (0-7, a new game starts with 4)
DEF wTitleListCount EQU $C8D8 ;@ u8 Number of monsters in the title-mode monster list (VS team, prize, breeding)
DEF wVSTeam EQU $C0EC ;@ u8[3] Monster slots chosen for the VS battle team ($FF = not chosen yet)
DEF wLinkPrizeSlot EQU $C8BA ;@ u8 Monster slot offered as the VS prize ($14 = none, $FF after the battle starts without one)
DEF wVSTeamCount EQU $C8C3 ;@ u8 Number of monsters in the VS team
DEF wVSTeamSlots EQU $C8C4 ;@ u8[3] Monster slots the VS team came from (they are copied to slots 0-2 for the battle)
DEF wTouchedActor EQU $D7BD ;@ u8 Number of the actor Terry overlaps (set by CheckActorOverlap)
DEF wScrollColumn EQU $C91F ;@ u8 Column or row counter of the screen-to-screen scroll
DEF wEventBoxMap EQU $C919 ;@ u16 BG map address of the field event's text box
DEF wArenaTeam1 EQU $D9D1 ;@ u8[6] Species (3 x u16) of the second team of the tournament class being fought
DEF wArenaTeam2 EQU $D9D9 ;@ u8[6] Species (3 x u16) of the third team of the tournament class being fought
DEF sStashedParty EQU $A1F3 ;@ u8[4] Saved game: wSavedParty, the party count and slots a script put aside
DEF sLibraryFlags EQU $A1CE ;@ u8[32] Saved game: wLibraryFlags (monster library entries)
DEF wBreedTemp EQU $DA72 ;@ u8 Breeding scratch: family + $F0 of the pedigree parent; resistance index while resistances are inherited
DEF wBreedFamily1 EQU $DA73 ;@ u8 Breeding: family + $F0 of the pedigree parent (special pairs)
DEF wBreedFamily2 EQU $DA74 ;@ u8 Breeding: family + $F0 of the mate (special pairs)
DEF wBreedCount EQU $D9E6 ;@ u8 Breeding counter of an unused rule (cleared after each breeding outside link mode)
DEF wGateFloorSet EQU $C936 ;@ u8 Gate world: which FloorMapTables entry picks the floor maps
DEF wGateSpecialSet EQU $C937 ;@ u8 Gate world: which SpecialFloorChances entry picks special floors (then the special floor kind)
DEF wGateClass EQU $C938 ;@ u8 Gate world: item, object and character class of its floors
DEF wFloorKind EQU $C93F ;@ u8 Kind of the floor layout: 0 random screens, 1 random screens without variants, 2 a preset layout
DEF wFloorNpcVariant EQU $C92C ;@ u8 Gate floor: variant (0-4) of the floor's special character
DEF wEncounterCounter EQU $CA39 ;@ u16 Counts down with each step on a gate floor; a random battle starts when it runs out
DEF wFloorTries EQU $C0A9 ;@ u8 Floor generator: tries left before the whole floor is made again
DEF wFloorObjKind EQU $C0AE ;@ u8 Floor generator: kind of the object being placed (+ $10 for an open chest)
DEF wArrivalScreen EQU $C0AF ;@ u8 Floor generator: screen where Terry arrives
DEF wSpotAround EQU $C0B0 ;@ u8[9] Floor generator: 3 x 3 spots around a place, 1 blocked / 0 free
DEF wMonResist EQU $CB29 ;@ u8[27] Party monster record field: the 27 resistances (0-3)
