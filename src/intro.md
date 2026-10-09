# From power-on to Terry's bedroom

What the code does between switching the Game Boy on and the moment the player can first
walk Terry around his bedroom, in the order it happens: the start-up, the logos and the
falling stars, the title screen and its menu, the new game, the loading of the house and
the bedtime scene with his sister. Then the rest of that night: the visitor from the
dresser, the way into the Kingdom of GreatTree, and the name the King asks for.

## Power on

The CPU starts at `Boot`, at address `$0100`: a `nop` and a jump to `Start`, past the
cartridge header. The boot ROM leaves $11 in register a on a Game Boy Color, and `Start`
stores 1 or 0 in `wOnCGB`. Then it runs straight on into `SoftReset`, the routine that
A + B + SELECT + START and a lost link cable also come back to:

- the stack goes to `$DFFF`, and `DisableInterruptsAndLCD` waits for line $91 and
  switches the screen off;
- `ClearRAM` clears the work RAM from $C000 to $DDFF and HRAM from $FF8A to $FFFD, but
  keeps `wOnCGB`; the top 512 bytes, where the stack lives, are left alone;
- `CopyOAMDMARoutine` copies the 10-byte `OAMDMARoutine` to $FF80. During a sprite DMA
  the CPU can only reach HRAM, so the routine that starts the DMA has to live there;
- `FillMemory` clears $1C00 bytes of VRAM from $8000: all tiles and both BG maps;
- `wGameMode` becomes 0, the text speed `wMessageSpeed` 4, the cartridge gets RAM bank 0,
  its RAM enabled and ROM bank 1, and `InitSound` silences the sound engine.

The Game Boy Color is detected but never switched to double speed: no code in the
cartridge writes the speed register.

Then `DetectSGB` asks for two-player mode and watches the pad lines. A Super Game Boy
answers, and gets nine setup packets, $800 bytes of border tiles (`SGBTransfer`) and the
compressed border map and colours (`SGBTransferCompressed`). `wOnSGB` is set to 1 before
the check either way, or the check's own packets would not go out.

The interrupt vectors are short jumps: VBlank to `VBlankHandler`, LCD STAT to
`LCDInterruptHandler`, serial to `SerialInterruptEntry`. The timer handler,
`TimerOverflowInterrupt`, only returns, and between the vectors sit the bytes of an older
VBlank handler that nothing reaches (`UnusedOldInterruptCode`).

## The main loop: game modes

The end of `SoftReset` is the main loop of the whole game, and it does almost nothing.
Each pass starts the game mode in `wGameMode`:

- the BG maps, the sprites, the palettes, the scroll and the fade are reset
  (`ClearBGMaps`, `ClearShadowOAM`, `InitPalettes`, `ClearScroll`, `InitFade`);
- `InitGameMode` runs the mode's start-up routine from `GameModeInitTable`;
- then the loop calls `Random`, over and over, until the mode sets `wGameModeChange` and
  its fade-out has finished;
- the interrupts and the screen go off, and the next pass starts the new mode.

There are 13 modes. 0 is the title (`TitleModeInit`), 1 the field (`FieldInit`), 2 the
battle, 3 the cutscenes, 4 the ending, 6 the result of a link battle, 9 and 10 the battle
tutorials; the rest are development tools, viewers and debug menus. Each mode also has a
step, `wGameModeStep`: mode 0 step 0 is the opening, step 1 the title menu.

The per-frame work of a mode doesn't happen in this loop at all. It happens inside the
VBlank interrupt.

## Every frame: VBlank

`VBlankHandler` is the heart of the game. First the work that must happen while the
screen is not being drawn:

- the sprite DMA from `wShadowOAM`, through the routine in HRAM;
- `VBlankMapUpdate`: a queued row or column of the background (`CopyMapUpdate`), with
  its colour attributes on a Game Boy Color;
- the palettes (`ApplyPalettes`), the scroll and window (`ApplyScroll`), the screen
  shake (`UpdateScreenShake`) and the LCD control register (`ApplyLCDC`).

Then it enables interrupts again and runs the game itself, still inside the interrupt:
the pad (`ReadJoypad`, `UpdateJoypadPresses`, with key repeat after 20 frames and then
every 6), the sound engine (`UpdateSound`), the queued song and sound effect
(`PlayQueuedSounds`), the current mode's frame (`UpdateGameModeFrame`, through
`GameModeUpdateTable`), the text printer (`UpdateText`), the palette fade (`UpdateFade`)
and the frame counter `wFrameCounter`.

Bit 0 of `wVBlankFlags` is set while this runs. If the game's work takes longer than a
frame, the next VBlank finds the bit set and only writes the LCD register and updates the
sound, so the music keeps its tempo. At the end the handler stores the current screen line
in `wVBlankEndLY`, a measure of how much of the frame the game used.

The handler also checks for A + B + SELECT + START and jumps to `SoftReset`. Right after
it, A + B with SELECT would open debug menu $07, and START + SELECT menu $0C, but the
compare is followed by an unconditional jump past them.

## ROM banks

The cartridge holds 2 MiB: 128 banks of 16 KiB on an MBC5. Bank 0 (`$0000-$3FFF`) is
always there, the window at `$4000-$7FFF` shows one of the others.

Code in one bank calls code in another through `FarCall`, `rst $10`, with a far-call
number in hl: the bank in the high byte, an entry in the low byte. Each code bank starts
with its own number at $4000 (`BankNumber_15` in bank $15) and a table of entry points at
$4001 (`FarTable_15`). `FarCall` saves the number it finds at $4000, switches, calls the
entry and switches back. 354 such entries in 62 banks have names: `TitleModeInit` is
`$1500`, entry 0 of bank $15. An odd detail: every switch also writes bits 5-6 of the bank
number to the cartridge RAM bank register.

Graphics, tilemaps and many tables are packed. `Decompress` takes the same kind of
reference, a bank and an entry of its table, and `DecompressCore` unpacks it: a length, a
marker byte, plain bytes, and after each marker a back-reference into the last 4 KiB of
the output. `DecompressVRAM` does the same while the screen is on, and `wDecompressBusy`
keeps an unpacking in the VBlank handler from mixing with one in the game code.

The texts are spread over banks too. `PrintMessage` takes a message number from $000 to
$9FF, and `MessageGroupTable` finds its bank: $000-$0E1, for instance, are group 0 of bank
$42 (`texts-42`). The printer draws the letters into the tiles of the text box set up by
`SetUpTextBox`, with the font in bank $4F switched in (`DrawGlyph`).

## The opening

Game mode 0 step 0 is the opening. `TitleInitOpening` calls `OpeningInit` in bank $5F,
which builds scene `wOpeningScene` with the screen off, and each frame `OpeningUpdate`
runs it (`OpeningUpdateScenes`). The scenes, as the `opening` video shows them:

- Three logo screens, `wOpeningLogo` 0-2 (`OpeningInitLogo0`): the Nintendo licence line
  (`opening-licensed`) for 60 frames (`OpeningLogo0`), then Eidos (`opening-eidos`) and
  Enix (`opening-enix`) for 180 frames each.
- Three falling stars on black (`OpeningInitStarScene`). Each moves 2 pixels left and 2
  down per frame with a sound, and a sparkle lights up in the sky behind it
  (`OpeningStarScene1`); the start positions are small tables (`SetUpStarScene1`) copied
  into `wSceneObjects`.
- A picture, shown for 120 frames (`OpeningPicture`, `opening-logo`).
- Two more stars falling side by side (`OpeningStarScene5`).
- The title screen (`OpeningInitTitle`, `title-screen`): the picture's tiles with another
  tilemap, and song $06.

Every logo, and the picture, ends with a fade-out and `wGameModeChange`: each screen is a
full pass through the main loop, and `OpeningInit` builds the next one from scratch. The
three single stars share one set-up, though, and follow each other without a restart.

A, B or START cut the opening short (`OpeningSkip`), but not everywhere. The licence
screen cannot be skipped. A press during the Eidos logo jumps to the Enix logo, and from
there on a press jumps straight to the title screen. All along, the opening answers a
linked Game Boy with $F4, "not ready" (`TitleUpdateOpening`).

The title screen has no timer and never goes back to the logos. Each frame `OpeningTitle`
only checks whether all four music channels have ended, and if so starts song $06 again.
A, B or START fade out to mode 0 step 1, the title menu.

## The title menu

`TitleInitMenu` loads Super Game Boy border 2 (`sgb-border-2`; `LoadSGBBorder` sends
nothing if it is already up), the font and the window tiles, starts song $24, and checks
the save file with `CheckSaveChecksum`. If `sSaveValid` is set, `SRAMChecksum` adds up
$1FFE bytes of the battery RAM from $A002 and compares the sum with `sChecksum`. A bad
save is not reported: the whole save area is cleared, the checksum of the empty data is
stored, and the player only finds CONTINUE gone.

`TitleMenuOpen` draws the menu: without a save only NEW GAME, with one CONTINUE, NEW GAME,
VS MODE and BREEDING. `TitleMenuChoose` moves the cursor (`MoveMenuCursor_15`, Up and Down,
wrapping around) and A picks an entry. There is no B: the menu never goes back to the
title screen. The serial interrupt is on, and each frame tells a linked Game Boy which
entry is under the cursor, $F2 for VS MODE, $F3 for BREEDING, $F4 for the rest.

`TitleMenuRunChoice` runs the entry from `TitleMenuChoiceTable`; with only one entry on
the screen, its number is moved up by one, so that it still means NEW GAME.

- CONTINUE (`ContinueShowSave`) loads the save with `LoadGame` and shows the name, the
  play time and the party monsters' names and levels (`ContinueDrawSave`). A goes on to the
  field, B back to the menu. Between the two routines lie bytes that nothing runs: a warp
  back to map 0 for a game saved on a gate floor (`UnusedContinueWarp`).
- NEW GAME runs `NewGameSetup`. `TitleNewGameSteps` lists it three times; it runs once.

## A new game

`NewGameSetup` clears $21 bytes of HRAM and $1100 bytes of work RAM from `wGameStarted`
on, the whole game state, puts Terry on map $2F (`wMapId`), the house he lives in with his
sister (`map-2f`), and empties the party (`wPartyCount` 0, `wParty` all $FF). It sets no
position; that comes later from a table. `TitleMenuStartField` fades out and asks for
mode 1, and the main loop switches the screen off and calls `FieldInit`.

## Loading the house

`FieldInit` remembers the stack pointer in `wFieldStackPtr` (field code can jump back here
from deep inside), stops the sound and sends the Super Game Boy border the map needs:
`GetMapSGBBorder` gives 2 for map $2F, the one the title already loaded, 3 for the other
maps below $30. Then the text box tiles, a fade-in, and `LoadMap`, with the screen off:

- `InitNewGameState` sees `wGameStarted` 0 and sets up the story: story bytes and flags
  cleared, the step counters `wStepTimer` (100) and `wFarmStepTimer` (20), a default
  four-letter name in `wPlayerName`, no gold, an empty bag, none of the 20 monster slots in
  use, and the party emptied a second time.
- `LoadMapTileset` (bank $0B) reads the map's entry in `MapInfo`: tiles 2D:1A, unpacked to
  $9000; 320 x 256 pixels, two screens across and two down; tiles from $70 on are solid.
- The song comes from `MapSongs`: $9D. `PlayQueuedSounds` never starts $9D as music, so the
  house is silent.
- `PlacePlayerOnMap` unpacks Terry's sprite tiles to $8000 and, as this is a new game,
  takes his position from `MapStartPositions`: X 72, Y 184, facing down. All 49 entries of
  `wPlayerTrail`, the path the party monsters will follow, start on that spot.
- `DrawMapScreen` works out the screen: row 184 / 128 = 1, column 72 / 160 = 0, so screen 4
  (`wMapScreen`), with the camera at (0, 128). `GetScreenTilemapRef` reads the screen's
  record in `MapScreenTable`: the address of a story byte, then one version of the screen
  per value of that byte, each a tilemap, an object list and a warp list. The colours come
  the same way, from `MapPaletteTable` (`LoadMapPalettes`, `LoadMapAttrBuffer`), and
  `LoadFieldObjPalettes` adds the eight sprite palettes.
- `SpawnMapObjects` turns the screen's object list (`GetScreenObjects`) into 32-byte actor
  records in `wActors` and loads their sprites. Records with bit 7 set are not people but
  places where A or a step starts a script.
- `RunMapEntryEvent` starts script 0 of the map (`StartScript`). It runs up to its first
  waiting command before the screen is even on.
- `BuildStatusBar` and `DrawStatusBar` draw the bar at the bottom.

`LoadMapTileset` has a slip: extra tiles meant only for map $08 are loaded on the zero
flag, but the compare was written `ld a, $08` instead of `cp $08`, so whether they load
depends on the flags `DecompressVRAM` happens to leave.

Finally the screen goes on, with the VBlank and LCD STAT interrupts. The LY compare is set
to line $7F, where `LCDEffectHideSprites` turns the sprites off: the bottom 16 lines are
the status bar, and no sprite may cover it.

## Bedtime

A script is a list of 16-bit words: $FFxx is a command from `ScriptCommandTable`, any other
word a message, and `UpdateFieldScript` runs it a command at a time. Script 0 of map $2F
(`scripts-0e`) checks a row of story flags in `wEventFlags`; none is set yet, so the
evening begins:

- Terry's sister Milayou chases him round the room: three laps of the same loop, 32 pixels
  left, up, right, 64 right, down, left, at double speed.
- She speaks (message $000 of `texts-42`): "Terry! Wait! It's time for bed! ... Stay up too
  late and you will be carried away by monsters."
- She walks to her bed, where her actor is switched off and a second one, Milayou asleep,
  switched on. Terry walks to his; he is switched off too (bit 6 of `hPlayerFlags`), and a
  third actor, Terry in bed, takes his place.
- The script waits 32 x 8 = 256 frames, then for a direction on the pad
  (`ScriptCmdWaitDPad`). Terry gets up, steps to the right and faces down, and the script
  ends.

The texts of this night spell "Terry" in plain letters: the player hasn't named him yet.

## The field loop

The field's frame is `FieldFrame`, called from the VBlank handler. `FieldUpdate` runs, in
this order:

- `AnimateMapTiles`, the moving parts of the scenery;
- `UpdatePlayer` and `HandlePlayerInput`: a press turns Terry (a 5-frame pause) or starts a
  step of 16 pixels at 0.75 pixel per frame, about 21 frames, if the next tile is free;
- `CheckScreenEdge`: the field scrolls a whole screen at a time when Terry comes within 7
  pixels of the left or top edge, or past X $99 or Y $79 on the screen;
- `UpdateFieldScript`, the script and its movers;
- `FieldInput`, the buttons while Terry is free: START switches the status bar, A talks to
  what is in front of him;
- the sprites (`DrawPlayerAndFollowers`, `DrawFieldActors`, `DrawFloorObjects`),
  `CheckShootingStarEvent`, and `TickPlayTime`, the clock that stops at 99:59:59.

With the party empty, A in the open does nothing: the field menu only opens when
`wPartyCount` isn't 0. START, which switches between the two kinds of bar, sets
`wStatusBarMode` to 0 every time.

From this frame on, the player is in control: Terry at midnight, in a silent house, his
sister asleep. The things in the room answer A with their own scripts: "A Fairy Tale" and
"Diary of Milayou" on the bookshelves, clothes in the dresser, a stuffed animal ("Property
of Milayou"), the clock at midnight, and in front of him a flame that sparkles and
vanishes in the air.

## The visitor

The other half of the room is screen 5. When Terry walks off the right edge, the screen
scrolls, and step 2 of the scroll (`ScrollRunMapScript`) starts script 0 again. On screen
5, with flag 0 still clear:

- the dresser opens: a sound, and `ScriptCmdSwapTiles` swaps two pairs of tiles in VRAM;
- a monster comes out: "Are you Milayou? Hm, you don't look like her. ... I'm Warubou from
  the Kingdom of GreatLog."
- Warubou knocks Terry back a tile, leaves to the left, returns with Milayou, and both
  vanish into the dresser;
- Terry is moved up to it, it opens once more, and another one comes out: "You speak
  monster talk, don't you? Where is Milayou? Taken away!? ... I am Watabou!";
- Watabou asks him to follow, goes back in, and the script sets flag 0.

When Terry looks into the dresser now, it opens, and its script spins him round twice and
moves him in. It sets `wStoryStep` to 6 and warps him to map $08 (`ScriptCmdWarpNoFade`).

## The Kingdom of GreatTree

Map $08 (`map-08`, `scripts-0d`) is a single screen. Its script reads `wStoryStep`, and at
6 someone comes in: "Oh, you must be the master. ... You're in the Kingdom of GreatTree.
Watabou brought you here." Then it sets the story step to $FF, and at $FF the scripts of
the next maps take Terry along: the guide walks him through map $09 (`map-09`) and up map
$01 (`map-01`), screen after screen. "This kingdom is created inside a big tree. We are at
the bottom. The castle is at the top." Map $08 also needs another border, 3, and a new
border makes `FieldMapChange` restart the whole field mode instead of only loading a map.

In the castle, map $00, the minister meets him on screen 5, and Terry walks on by himself
to the King on screen 1 (`scripts-0c`).

## A name

"Welcome! I am the King of this kingdom. Identify yourself, my child." The King's script
sets `wChosenMonPic` to 0 (Terry, not a monster) and `wChosenMonName` to `wPlayerName`, and
opens window 15 (`ScriptCmdOpenFieldMenu`), the name entry (`NameEntryMenu`). Its keyboard
has 5 rows of 17 keys (`NameEntryInput`); A types, B erases (the first B on the default
name erases all of it), START jumps to End. A name holds 4 letters. `CheckForbiddenName`
turns down four times the same letter and a short list of names, and an empty name gets
the default back (`PickDefaultName`).

Right after the name, before the King says a word about monsters, the script adds a Slime
at level 1 (`ScriptCmdAddMonster`), into a free monster slot but not into the party. Then
the King asks Terry to win the Starry Night Tournament: the winner is granted a wish, and
his can be to find his sister. Pulio at the monster farm upstairs will hand over the
monsters. The script sets flag 2, and from here on the game is Terry's.
