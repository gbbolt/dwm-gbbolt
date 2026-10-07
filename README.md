# Dragon Warrior Monsters (Game Boy Color) - gbbolt disassembly

**Open it: <https://gbbolt.lingora.org/dwm/>**

A matching disassembly of *Dragon Warrior Monsters* (Enix, 1999, USA/Europe) for the Game Boy Color, a
2 MiB cartridge with 128 banks. It is read with [gbbolt](https://github.com/gbbolt/gbbolt): code and
pseudo-code side by side, each short piece of Python directly above the few instructions that do it.

**Work in progress.** The whole ROM is disassembled and rebuilds byte for byte; the code is being
named, explained and given pseudo-code bank by bank. The viewer always shows the current state.

- **Every bank is its own file** (`src/bank_000.asm` ... `src/bank_07f.asm`). Bank 0 is always mapped;
  each code bank starts with its own number and a table of entry points, and `ld hl, far_Name` +
  `rst $10` calls a routine in another bank through that table (`src/far.inc`).
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
assets/*.py         asset plugins: the opening and the title screen, run on an emulated Game Boy Color
```

## Legal

Dragon Warrior Monsters and its code, graphics and music are the property of their respective owners
(Armor Project, Bird Studio, Enix / Square Enix). This repository contains no ROM. It is a research and
documentation project in the tradition of other community disassemblies; please buy the game.

The annotations, names, pseudo-code, descriptions, plugins and configuration written for this project
are available under the MIT license (see [LICENSE](LICENSE)), as far as they are separable from the
game itself.
