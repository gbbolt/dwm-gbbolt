# Dragon Warrior Monsters (Game Boy Color) - gbbolt disassembly

**Open it: <https://gbbolt.lingora.org/dwm/>**

A matching disassembly of *Dragon Warrior Monsters* (Enix, 1999, USA/Europe) for the Game Boy Color, a
2 MiB cartridge with 128 banks. It is read with [gbbolt](https://github.com/gbbolt/gbbolt): code and
pseudo-code side by side, each short piece of Python directly above the few instructions that do it.

**Complete.** All 4,334 code units are named, explained and given pseudo-code, and every unit sits
in a folder of the code tree; the data banks are split into labelled, described blocks. The ROM
rebuilds byte for byte.

- **Every bank is its own file** (`src/bank_000.asm` ... `src/bank_07f.asm`). Bank 0 is always mapped;
  each code bank starts with its own number and a table of entry points, and `ld hl, far_Name` +
  `rst $10` calls a routine in another bank through that table (`src/far.inc`).
- **What the code does:** the field and the gate worlds with their random floors, breeding and its
  pair tables, the battle engine (commands, skill effects, damage and resistances, the enemy AI's
  rules and target choice, turn order, recruiting), the Starry Night tournament, link play, the
  sound engine, the text printer, the opening, the ending and the debug menus.
- **Info sheets drawn from the game's own tables:** a page for each of the 217 monsters (picture,
  walking sprite, growth, resistances, experience curve, breeding pairs, where it is met), the
  breeding chart and special pairs, items, skills, the gate worlds with their monsters floor by floor
  and their chest items, every monster template, the tournament teams and prizes, experience and
  growth tables, palettes, the font, every system and story text decoded.
- **Graphics:** all monster pictures in their own colours, the field sprites of people and monsters,
  86 maps drawn from their tilesets and screen maps, the gate floor looks, the window tiles, the four
  Super Game Boy borders and the ending credits.
- **Music and sound effects**, played by the game's own sound engine: 29 songs and 62 effects.
- **Screens, played by the game's own code** on an emulated Game Boy Color: the opening from power-on
  (licence screen, the Eidos and Enix logos, the falling star, the logo) and the title screen, in the
  game's own colours.

## Building

The disassembly rebuilds the original ROM byte for byte. You need
[RGBDS](https://rgbds.gbdev.io) 1.0.1, Python 3.9+ with numpy, and gbbolt next to this folder:

```
git clone https://github.com/gbbolt/gbbolt
git clone https://github.com/gbbolt/dwm-gbbolt
cd dwm-gbbolt
python ../gbbolt/tools/gbbolt.py            # build, verify, write out/site/index.html
```

The build is checked against the SHA1 of the original ROM
(`728e458d4b13cdc8a0026dc28c5a14f1d72d9da4`, *Dragon Warrior Monsters (USA, Europe) (SGB Enhanced)*).
No ROM is needed to build it. If you put your own dump next to `game.json` as `dwm.gbc`, it is compared
byte by byte.

## Layout

```
game.json           what gbbolt needs to know about the game
src/bank_XXX.asm    the disassembly, one file per ROM bank, with its annotations
src/ram.inc         RAM variables: names, types, descriptions
src/far.inc         far-call constants (bank and entry number of each far-callable routine)
src/hardware.inc    hardware registers (Game Boy Color included)
src/sound.json      how the music is played through the game's own sound engine
assets/*.py         asset plugins: screens run on an emulated Game Boy Color, and the sheets read
                    from the game's tables (assets/_dwm.py holds the shared readers)
```

## Legal

Dragon Warrior Monsters and its code, graphics and music are the property of their respective owners
(Armor Project, Bird Studio, Enix / Square Enix). This repository contains no ROM. It is a research and
documentation project in the tradition of other community disassemblies; please buy the game.

The annotations, names, pseudo-code, descriptions, plugins and configuration written for this project
are available under the MIT license (see [LICENSE](LICENSE)), as far as they are separable from the
game itself.
