INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $007", ROMX[$4000], BANK[$7]

BankNumber_07::
	db $07

FarTable_07::
	dw FieldMenu
	dw ShowMonsterStatus
	dw UpdateMonsterStatus
	dw GetSkillMPCost

;@ def FieldMenu()
;@ path: menu/field
;@ The field menu (opened with Start while walking), run once a frame: wStatusViewVars
;@ is its state - 0 open, 1 draw, 2 main menu input, 3 the chosen option, 4 close.
;@ test: skip jumps through a state table
FieldMenu::
;> FieldMenuStates[wStatusViewVars]()
	ld a, [wStatusViewVars]
	rst $00

;@ path: menu/field
;@ States of the field menu (FieldMenu): open, draw, main menu input, run the
;@ chosen option, close.
FieldMenuStates::
	dw FieldMenuOpen
	dw FieldMenuDraw
	dw FieldMenuInput
	dw FieldMenuRunOption
	dw FieldMenuClose

;@ def FieldMenuDraw()
;@ path: menu/field
;@ Field menu state 1: draws the main menu, the gold window and the party panel.
;@ test: skip draws into VRAM
FieldMenuDraw::
;> wStatusViewVars += 1
	ld hl, wStatusViewVars
	inc [hl]
;> MenuClearBuffer()
	call MenuClearBuffer
;> DrawMainMenuWindows()
	call DrawMainMenuWindows
;> MenuShowBuffer()
	call MenuShowBuffer
;> DrawPartyPanel()
	call DrawPartyPanel
;> MenuShowBuffer()
	call MenuShowBuffer
	ret


;@ def DrawMainMenuWindows()
;@ path: menu/field
;@ Draws the main menu window (four options in a 2x2 grid) and the gold window with
;@ the player's gold into the tilemap buffer, and the cursor on the current option.
;@ test: skip draws into VRAM
DrawMainMenuWindows::
;> DrawWindow(MainMenuWindow)
	ld de, $704d
	call DrawWindow
;> DrawWindow(GoldWindow)
	ld de, $7090
	call DrawWindow
;> hNumber[0:3] = wGold[0:3]
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(BufferAddress(0x002E))       # row 1, column 14
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
;> MenuResetBlink()
	call MenuResetBlink
;> MenuDrawCursorAt(wLinkChoice, MainMenuCursorPos)
	ld de, $44b4
	ld a, [wLinkChoice]
	call MenuDrawCursorAt
	ret


;@ def DrawPartyPanel()
;@ path: menu/field
;@ Lower half of the field menu: for each party monster its picture (6x6 tiles), its
;@ walking sprite tiles, its name, sex mark, level, HP and MP - or, after Start, the
;@ player info page (DrawInfoPage).
;@ test: skip draws into VRAM
DrawPartyPanel::
;> if wPartyCount:
	ld a, [wPartyCount]
	or a
	jr z, .names
;>@pic     for i in range(wPartyCount):      # pictures at $95C0/$8800/$8A40, sprites at $8500/$8600/$8700
;>         LoadMonsterPicture(GetPartyMonsterByte(i, wMonRecSpecies), (0x95C0, 0x8800, 0x8A40)[i])
	ld a, $00
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $95c0
	call LoadMonsterPicture
;>         LoadMonsterSprite(GetPartyMonsterByte(i, wMonRecSpecies), 0x8500 + 0x100 * i)
	ld a, $00
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $8500
	call LoadMonsterSprite
;=@pic
	ld a, [wPartyCount]
	cp $01
	jr z, .names

;=@pic
	ld a, $01
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $8800
	call LoadMonsterPicture
;=@pic
	ld a, $01
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $8600
	call LoadMonsterSprite
;=@pic
	ld a, [wPartyCount]
	cp $02
	jr z, .names

;=@pic
	ld a, $02
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $8a40
	call LoadMonsterPicture
;=@pic
	ld a, $02
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $8700
	call LoadMonsterSprite

.names
;> MenuLoadPartyNames()
	call MenuLoadPartyNames
;> DrawInfoPage()
	call DrawInfoPage
;>@st for i in range(wPartyCount):             # columns 1, 7, 13
	ld a, [wPartyCount]
	or a
	ret z

;>     DrawPicTiles(0x5C + 0x24 * i, 0x00E1 + 6 * i)
	ld a, $5c
	ld hl, $00e1
	call DrawPicTiles
;>     DrawNameTileRow(0x20 + 4 * i, 0x01C1 + 6 * i)
	ld a, $20
	ld hl, $01c1
	call DrawNameTileRow
;>     SetPartyPicPalette(i, 0x00E1 + 6 * i)
	ld hl, $00e1
	ld a, $00
	call SetPartyPicPalette
;>     LoadPartySexMark(i, 0x9590 + 0x10 * i)
	ld a, $00
	ld hl, $9590
	call LoadPartySexMark
;>     DrawPartyMemberStats(i, 0x01E1 + 6 * i)
	ld hl, $01e1
	ld a, $00
	call DrawPartyMemberStats
;=@st
	ld a, [wPartyCount]
	cp $01
	ret z

;=@st
	ld a, $80
	ld hl, $00e7
	call DrawPicTiles
;=@st
	ld a, $24
	ld hl, $01c7
	call DrawNameTileRow
;=@st
	ld hl, $00e7
	ld a, $01
	call SetPartyPicPalette
;=@st
	ld a, $01
	ld hl, $95a0
	call LoadPartySexMark
;=@st
	ld hl, $01e7
	ld a, $01
	call DrawPartyMemberStats
;=@st
	ld a, [wPartyCount]
	cp $02
	ret z

;=@st
	ld a, $a4
	ld hl, $00ed
	call DrawPicTiles
;=@st
	ld a, $28
	ld hl, $01cd
	call DrawNameTileRow
;=@st
	ld hl, $00ed
	ld a, $02
	call SetPartyPicPalette
;=@st
	ld a, $02
	ld hl, $95b0
	call LoadPartySexMark
;=@st
	ld hl, $01ed
	ld a, $02
	call DrawPartyMemberStats
	ret


;@ def DrawPicTiles(first: a, pos: hl)
;@ path: menu/field
;@ Writes a 6x6 block of consecutive tile numbers from `first` into the tilemap
;@ buffer at offset `pos` (row * 32 + column): a monster picture. Not on the info page.
;@ test: skip writes the tilemap buffer through BufferAddress
DrawPicTiles::
;> if wMenuInfoPage:
;>     return
	ld c, a
	ld a, [wMenuInfoPage]
	or a
	ret nz

;> tile = first
	ld a, c
;>@row for row in range(6):
	ld c, $06
.row
;>     p = BufferAddress(pos + 32 * row)
	push hl
	push af
	call BufferAddress
	pop af
;>     for col in range(6):
;>         mem[p + col] = tile + col
	ld b, $06
.col
	ld [hli], a
	inc a
	dec b
	jr nz, .col

;>     tile += 6
;=@row
	pop hl
	ld de, $0020
	add hl, de
	dec c
	jr nz, .row

	ret


;@ def DrawNameTileRow(first: a, pos: hl) -> a
;@ path: menu/field
;@ Writes the four tile numbers `first`..`first`+3 (a name drawn into tiles) into the
;@ tilemap buffer at offset `pos`; returns `first` + 4.
;@ test: skip writes the tilemap buffer through BufferAddress
DrawNameTileRow::
;> p = BufferAddress(pos)
	push af
	call BufferAddress
	pop af
;>@r for i in range(4):
;>     mem[p + i] = first + i
	ld [hli], a
	inc a
	ld [hli], a
	inc a
;=@r
	ld [hli], a
	inc a
	ld [hl], a
	inc a
;> return first + 4
	ret


;@ def SetPartyPicPalette(slot: a, pos: hl)
;@ path: menu/field
;@ Gives the picture of party monster `slot` (drawn at buffer offset `pos`) its
;@ species' CGB palette, palette number 4 + `slot`. Not on the info page.
;@ test: skip calls routines in another bank
SetPartyPicPalette::
;> mem16[0xC820] = pos            # where the palette applies
	push af
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
;> wPaletteSet = PartyMonsterField(slot, wMonRecSpecies)[0]
	pop af
	push af
	ld hl, wMonRecSpecies
	call PartyMonsterField
	ld a, [hl]
	ld [wPaletteSet], a
;> mem[0xC81F] = 4 + slot         # palette number
	pop af
	add $04
	ld [$c81f], a
;> if wMenuInfoPage:
;>     return
	ld a, [wMenuInfoPage]
	or a
	ret nz

;> LoadMonPicPalette()
	ld hl, far_LoadMonPicPalette
	rst $10
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
	ret


;@ def LoadPartySexMark(slot: a, dest: hl)
;@ path: menu/field
;@ Draws the sex mark of party monster `slot` into the tile at `dest`.
;@ test: skip draws text tiles in another bank
LoadPartySexMark::
;>@c1 DrawSexMark(PartyMonsterField(slot, wMonGender)[0], dest)
	push hl
	ld hl, wMonGender
	call PartyMonsterField
	ld a, [hl]
	pop hl
	call DrawSexMark
;=@c1
	ret


;@ def DrawPartyMemberStats(slot: a, pos: hl)
;@ path: menu/field
;@ Three rows under a party monster's name in the field menu: "LV" with the level and
;@ the sex mark tile, "HP" and "MP" with their values (tiles $DE $DF, $E0 $E1,
;@ $E0 $E2, each followed by the colon $E4).
;@ test: skip writes the tilemap buffer through BufferAddress
DrawPartyMemberStats::
;> hNumber[0] = slot
;> p = BufferAddress(pos)
	push hl
	ldh [hNumber], a
	call BufferAddress
;> mem[p:p + 3] = [0xDE, 0xDF, 0xE4]        # "LV:"
	ld a, $de
	ld [hli], a
	ld a, $df
	ld [hli], a
	ld a, $e4
	ld [hli], a
;> mem[p + 5] = 0x59 + slot                 # the tile LoadPartySexMark drew into
	ldh a, [hNumber]
	add $59
	inc hl
	inc hl
	ld [hld], a
	dec hl
;>@c1 DrawNumber2(GetPartyMonsterByte(slot, wMonLevel), p + 3)
	push hl
	ld hl, wMonLevel
	ldh a, [hNumber]
	call GetPartyMonsterByte
	pop hl
;=@c1
	ld c, a
	ld b, $00
	call DrawNumber2
;>@c2 p = BufferAddress(pos + 0x20)
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
;=@c2
	ld h, a
;=@c2
	push hl
	call BufferAddress
;> mem[p:p + 3] = [0xE0, 0xE1, 0xE4]        # " H:"
	ld a, $e0
	ld [hli], a
	ld a, $e1
	ld [hli], a
	ld a, $e4
	ld [hli], a
;> DrawNumber3(GetPartyMonsterWord(slot, wMonHP), p + 3)
	push hl
	ld hl, wMonHP
	ldh a, [hNumber]
	call GetPartyMonsterWord
	pop hl
	call DrawNumber3
;>@c3 p = BufferAddress(pos + 0x40)
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
;=@c3
	ld h, a
;=@c3
	push hl
	call BufferAddress
;> mem[p:p + 3] = [0xE0, 0xE2, 0xE4]        # " M:"
	ld a, $e0
	ld [hli], a
	ld a, $e2
	ld [hli], a
	ld a, $e4
	ld [hli], a
;>@c2 DrawNumber3(GetPartyMonsterWord(slot, wMonMP), p + 3)
	push hl
	ld hl, wMonMP
	ldh a, [hNumber]
	call GetPartyMonsterWord
	pop hl
	call DrawNumber3
;=@c2
	pop hl
	ret


;@ def DrawInfoPage()
;@ path: menu/field
;@ The player info page that Start shows in place of the party panel: the player's
;@ name, how many library entries are filled in, the play time and the numbers of
;@ monsters and eggs on the farm and in the second farm pen.
;@ test: skip draws text tiles in another bank
DrawInfoPage::
;> if not wMenuInfoPage:
;>     return
	ld a, [wMenuInfoPage]
	or a
	ret z

;> wTextIndex = 0x59         # text 2/$59: the page's captions
	ld a, $59
	ld [wTextIndex], a
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> MenuDrawTextTiles(0x95C0, width=1, height=0x14)
	ld hl, $95c0
	ld de, $1401
	call MenuDrawTextTiles
;> MenuDrawNameTiles(wPlayerName, 0x93C0)
	ld de, wPlayerName
	ld hl, $93c0
	call MenuDrawNameTiles
;> DrawWindow(InfoPageWindow)
	ld de, $7cee
	call DrawWindow
;> known = 0
;>@L for species in range(0xF0):
	ld b, $00
	ld c, $00
.count
;>     if TestFlag(wLibraryFlags, species):
	push bc
	ld hl, wLibraryFlags
	ld a, b
	call TestFlag
	pop bc
	jr z, .next

;>         known += 1
	inc c

.next
;=@L
	inc b
	ld a, b
	cp $f0
	jr nz, .count

;> PrintNumber3(known, BufferAddress(0x0110))
	ld b, $00
	ld hl, $0110
	call BufferAddress
	call PrintNumber3
;> PrintNumber2Zeros(wPlayHours, BufferAddress(0x00AE))
	ld a, [wPlayHours]
	ld c, a
	ld b, $00
	ld hl, $00ae
	call BufferAddress
	call PrintNumber2Zeros
;> PrintNumber2Zeros(wPlayMinutes, BufferAddress(0x00B1))
	ld a, [wPlayMinutes]
	ld c, a
	ld b, $00
	ld hl, $00b1
	call BufferAddress
	call PrintNumber2Zeros
;> DrawMonsterCounts()
	call DrawMonsterCounts
	ret


;@ def UpdateInfoPlayTime()
;@ path: menu/field
;@ While the info page is shown, redraws the play time straight into the BG map
;@ every frame, so the clock keeps running on screen.
;@ test: skip writes VRAM
UpdateInfoPlayTime::
;> if not wMenuInfoPage:
;>     return
	ld a, [wMenuInfoPage]
	or a
	ret z

;> PrintNumber2Zeros(wPlayHours, MenuMapAddress(0x00AE))
	ld a, [wPlayHours]
	ld c, a
	ld b, $00
	ld hl, $00ae
	call MenuMapAddress
	call PrintNumber2Zeros
;>@c3 PrintNumber2Zeros(wPlayMinutes, MenuMapAddress(0x00B1))
	ld a, [wPlayMinutes]
	ld c, a
	ld b, $00
	ld hl, $00b1
	call MenuMapAddress
	call PrintNumber2Zeros
;=@c3
	ret


;@ def DrawMonsterCounts()
;@ path: menu/field
;@ The four counts of the info page: monsters at the farm, eggs, and the same two
;@ for the second farm pen.
;@ test: skip writes the tilemap buffer through BufferAddress
DrawMonsterCounts::
;> CountFarmMonstersMenu(0x014B)
	ld hl, $014b
	call CountFarmMonstersMenu
;> CountEggs(0x0151)
	ld hl, $0151
	call CountEggs
;> CountFarm2Monsters(0x016B)
	ld hl, $016b
	call CountFarm2Monsters
;> CountFarm2Eggs(0x0171)
	ld hl, $0171
	call CountFarm2Eggs
	ret


;@ def CountFarmMonstersMenu(pos: hl)
;@ path: menu/field
;@ Counts the monsters kept at the farm (record state 1, not in the party) that are
;@ not eggs, and prints the number at buffer offset `pos`.
;@ test: skip writes the tilemap buffer through BufferAddress
CountFarmMonstersMenu::
;> p = BufferAddress(pos)
	call BufferAddress
;> n = 0
;>@L for rec in range(20):
	push hl
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>     m = wMonsters + 0x95 * rec
;>@c4     if mem[m] not in (0, 2) and mem[m + 0x63] == 0:     # +$63 = wMonEgg
	push de
	ld a, [de]
	or a
	jr z, .next

;=@c4
	cp $02
	jr z, .next

;=@c4
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@c4
	ld a, [de]
	or a
	jr nz, .next

;>@c4         n += 1
	inc c

.next
;=@L
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@c4
	ld d, a
;=@L
	dec b
	jr nz, .loop

;> PrintNumber2(n, p)
	pop hl
	ld b, $00
	call PrintNumber2
	ret


;@ def CountEggs(pos: hl)
;@ path: menu/field
;@ Counts the player's eggs (records in use whose wMonEgg is set) and prints the
;@ number at buffer offset `pos`.
;@ test: skip writes the tilemap buffer through BufferAddress
CountEggs::
;> p = BufferAddress(pos)
	call BufferAddress
;> n = 0
;>@L for rec in range(20):
	push hl
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>     m = wMonsters + 0x95 * rec
;>@c5     if mem[m] and mem[m + 0x63]:
	push de
	ld a, [de]
	or a
	jr z, .next

;=@c5
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@c5
	ld a, [de]
	or a
	jr z, .next

;>@c5         n += 1
	inc c

.next
;=@L
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@c5
	ld d, a
;=@L
	dec b
	jr nz, .loop

;> PrintNumber2(n, p)
	pop hl
	ld b, $00
	call PrintNumber2
	ret


;@ def CountFarm2Monsters(pos: hl)
;@ path: menu/field
;@ Counts the monsters (not eggs) in the second farm pen in battery RAM - 0 while
;@ it is not set up - and prints the number at buffer offset `pos`.
;@ test: skip reads cartridge RAM
CountFarm2Monsters::
;> p = BufferAddress(pos)
	call BufferAddress
;> n = 0
;> if wFarm2Flags & 0x80:
	ld c, $00
	ld a, [wFarm2Flags]
	bit 7, a
	jr z, .print

;>@L     for rec in range(20):
	push hl
	ld hl, sFarm2
	ld b, $14
	ld c, $00
.loop
;>         m = sFarm2 + 0x95 * rec
;>@c6         if ReadSRAMByte(m) and not ReadSRAMByte(m + 0x63):
	push hl
	call ReadSRAMByte
	or a
	jr z, .next

;=@c6
	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@c6
	call ReadSRAMByte
	or a
	jr nz, .next

;>@c6             n += 1
	inc c

.next
;=@L
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
;=@c6
	ld h, a
;=@L
	dec b
	jr nz, .loop

	pop hl

.print
;> PrintNumber2(n, p)
	ld b, $00
	call PrintNumber2
	ret


;@ def CountFarm2Eggs(pos: hl)
;@ path: menu/field
;@ Counts the eggs in the second farm pen in battery RAM - 0 while it is not set
;@ up - and prints the number at buffer offset `pos`.
;@ test: skip reads cartridge RAM
CountFarm2Eggs::
;> p = BufferAddress(pos)
	call BufferAddress
;> n = 0
;> if wFarm2Flags & 0x80:
	ld c, $00
	ld a, [wFarm2Flags]
	bit 7, a
	jr z, .print

;>@L     for rec in range(20):
	push hl
	ld hl, sFarm2
	ld b, $14
	ld c, $00
.loop
;>         m = sFarm2 + 0x95 * rec
;>@c7         if ReadSRAMByte(m) and ReadSRAMByte(m + 0x63):
	push hl
	call ReadSRAMByte
	or a
	jr z, .next

;=@c7
	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@c7
	call ReadSRAMByte
	or a
	jr z, .next

;>@c7             n += 1
	inc c

.next
;=@L
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
;=@c7
	ld h, a
;=@L
	dec b
	jr nz, .loop

	pop hl

.print
;> PrintNumber2(n, p)
	ld b, $00
	call PrintNumber2
	ret


;@ def LoadMonsterPicture(species: a, dest: hl)
;@ path: menu/field
;@ Unpacks the big picture of monster `species` (graphics number from the table at
;@ $2B9F in the home bank) to VRAM `dest`; nothing for $FF or on the info page.
;@ test: skip decompresses into VRAM
LoadMonsterPicture::
;> if species == 0xFF:
;>     return
	cp $ff
	ret z

;>@c8 gfx = mem16[0x2B9F + 2 * species]
	push hl
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add $9f
;=@c8
	ld l, a
;=@c8
	ld a, h
	adc $2b
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
;> if wMenuInfoPage:
;>     return
	pop hl
	ld a, [wMenuInfoPage]
	or a
	ret nz

;> DecompressVRAM(gfx >> 8, gfx & 0xFF, dest)
	call DecompressVRAM
	ret


;@ def FieldMenuInput()
;@ path: menu/field
;@ Field menu state 2, the main menu: the pad moves the cursor in the 2x2 grid of
;@ options, Start switches between the party panel and the player info page, B or
;@ Select closes the menu and A opens the option under the cursor.
;@ test: skip draws into VRAM
FieldMenuInput::
;> UpdateInfoPlayTime()
	call UpdateInfoPlayTime
;> wLinkChoice &= 0x7F               # main menu cursor (bit 7 = chosen)
	ld hl, wLinkChoice
	res 7, [hl]
;> if wJoyPressed & 0x30:            # Left / Right: other column
	ld a, [wJoyPressed]
	and $30
	jr z, .notSideways

;>     wLinkChoice ^= 1
	ld a, [wLinkChoice]
	xor $01
	ld [wLinkChoice], a
;>@mv     wMenuBlink = 0
	jr .moved

.notSideways
;> elif wJoyPressed & 0xC0:          # Up / Down: other row
	ld a, [wJoyPressed]
	and $c0
	jr z, .notUpDown

;>     wLinkChoice ^= 2
	ld a, [wLinkChoice]
	xor $02
	ld [wLinkChoice], a

.moved
;>     wMenuBlink = 0
	xor a
	ld [wMenuBlink], a
;=@mv
	jr .cursor

.notUpDown
;> elif wJoyPressed & 0x08:          # Start: party panel <-> info page
	ld a, [wJoyPressed]
	and $08
	jr z, .notStart

;>     wMenuInfoPage ^= 1
	ld a, [wMenuInfoPage]
	xor $01
	ld [wMenuInfoPage], a
;>     fill(wTilemapBuffer + 0xA0, 0x100, 0xE0)    # clear rows 5-12
	ld hl, $c5a0
	ld bc, $0100
	ld a, $e0
	call FillMemory
;>     MenuShowBuffer()
	call MenuShowBuffer
;>     DrawPartyPanel()
	call DrawPartyPanel
;>     MenuShowBuffer()
	call MenuShowBuffer
	jr .cursor

.notStart
;> elif wJoyPressed & 0x06:          # B or Select: close (state 4)
	ld a, [wJoyPressed]
	and $06
	jr z, .notB

;>     wStatusViewVars += 2
	ld hl, wStatusViewVars
	inc [hl]
	ld hl, wStatusViewVars
	inc [hl]
	jr .cursor

.notB
;> elif wJoyPressed & 0x01:          # A: run the option (state 3)
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .cursor

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wStatusViewVars += 1
	ld hl, wStatusViewVars
	inc [hl]
;>     MenuClearBuffer()
	call MenuClearBuffer
;>     DrawMainMenuWindows()
	call DrawMainMenuWindows
;>     MenuShowBuffer()
	call MenuShowBuffer
;>     wFieldMenuStep = 0
	xor a
	ld [wFieldMenuStep], a
;>     wLinkChoice |= 0x80
	ld hl, wLinkChoice
	set 7, [hl]
;>     fill(wMenuChoice2, 7, 0)       # the option's own cursors
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
;>     MenuLoadPartyNames()
	call MenuLoadPartyNames

.cursor
;> BlinkMenuCursor(wLinkChoice, MainMenuCursorPos)
	ld de, $44b4
	ld a, [wLinkChoice]
	call BlinkMenuCursor
;> DrawPartySprites()
	call DrawPartySprites
	ret


;@ def MenuLoadPartyNames()
;@ path: menu/field
;@ Draws the names of the three party monsters into the tiles at $9200, $9240 and
;@ $9280 (blank tiles for empty places).
;@ test: skip draws into VRAM
MenuLoadPartyNames::
;> for i in range(1, 4):
;>@c1     LoadPartyNameTile(i, 0x9200 + 0x40 * (i - 1))
	ld hl, $9200
	ld a, $01
	call LoadPartyNameTile
;=@c1
	ld hl, $9240
	ld a, $02
	call LoadPartyNameTile
;=@c1
	ld hl, $9280
	ld a, $03
	call LoadPartyNameTile
	ret


;@ def LoadPartyNameTile(place: a, dest: hl)
;@ path: menu/field
;@ Draws the name of party monster `place` (1-3) into the four tiles at `dest`, or
;@ blanks the tiles when the party is smaller.
;@ test: skip draws into VRAM
LoadPartyNameTile::
;> if wPartyCount < place:
	ld b, a
	ld a, [wPartyCount]
	cp b
	jr nc, .name

;>     for i in range(0x20):
;>         dest = WriteVRAMInc(0xFF, dest)        # blank tile rows
;>@c2         dest = WriteVRAMInc(0x00, dest)
	ld b, $20
.clear
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@c2
	dec b
	jr nz, .clear

;>     return
	ret


.name
;>@c3 MenuDrawNameTiles(PartyMonsterField(place - 1, wMonName), dest)
	push hl
	ld a, b
	dec a
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
;=@c3
	ld d, h
	pop hl
	call MenuDrawNameTiles
	ret


;@ def FieldMenuRunOption()
;@ path: menu/field
;@ Field menu state 3: runs the option chosen in the main menu.
;@ test: skip jumps through a table
FieldMenuRunOption::
;> FieldMenuOptions[wLinkChoice & 0x7F]()
	ld a, [wLinkChoice]
	rst $00

;@ path: menu/field
;@ The four main menu options - monster status, items, skills, options - followed
;@ by the main menu's cursor positions (MainMenuCursorPos at $44B4: buffer offsets
;@ row * 32 + column of the four options, $FFFF ends the list).
FieldMenuOptions::
	dw StatusMenu
	dw ItemMenu
	dw SkillMenu
	dw OptionMenu
	dw $0021
	dw $0026
	dw $0061
	dw $0066
	dw $ffff

;@ def StatusMenu()
;@ path: menu/status
;@ The status option of the field menu: four pages per party monster (stats,
;@ personality and experience, skills, pedigree); wFieldMenuStep is the step.
;@ test: skip jumps through a table
StatusMenu::
;> StatusMenuSteps[wFieldMenuStep]()
	ld a, [wFieldMenuStep]
	rst $00

;@ path: menu/status
;@ Steps of the status option (StatusMenu).
StatusMenuSteps::
	dw StatusMenuOpen
	dw StatusPage1Input
	dw StatusShowPicture
	dw StatusStepNext
	dw StatusStepSkip
	dw StatusStepBack4
	dw StatusShowPage2
	dw StatusPage2Input
	dw StatusShowSkills
	dw StatusSkillsInput
	dw StatusShowPedigree
	dw StatusPedigreeInput
	dw StatusClose
	dw StatusRedrawPage2
	dw StatusRedrawPedigree

;@ def StatusMenuOpen()
;@ path: menu/status
;@ Status step 0: loads the party names, then draws the first page (StatusDrawPage1).
;@ test: skip draws into VRAM
StatusMenuOpen::
;> MenuLoadPartyNames()
	call MenuLoadPartyNames
;> StatusDrawPage1()

;@ def StatusDrawPage1()
;@ path: menu/status
;@ Draws the first status page: the party list, the stats window and the HP/MP
;@ window, the chosen monster's picture and its numbers; then the next step.
;@ test: skip draws into VRAM
StatusDrawPage1::
;> DrawWindow(StatusListWindow)
	ld de, StatusListWindow
	call DrawWindow
;> DrawWindow(StatusStatsWindow)
	ld de, StatusStatsWindow
	call DrawWindow
;> DrawWindow(StatusHPWindow)
	ld de, StatusHPWindow
	call DrawWindow
;> wCurPartyMember = wMenuChoice2
	ld a, [wMenuChoice2]
	ld [wCurPartyMember], a
;> LoadStatusPicture()
	call LoadStatusPicture
;> SetStatusPicPalette()
	call SetStatusPicPalette
;> DrawWindow(StatusPicWindow)
	ld de, StatusPicWindow
	call DrawWindow
;> DrawStatusStats()
	call DrawStatusStats
;> MenuResetBlink()
	call MenuResetBlink
;> MenuDrawCursorAt(wMenuChoice2, StatusMonCursorPos)
	ld de, StatusMonCursorPos
	ld a, [wMenuChoice2]
	call MenuDrawCursorAt
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def DrawStatusStats()
;@ path: menu/status
;@ First status page of the viewed monster: name, sex mark, level (the "LV" tile
;@ turns into a "max" tile once the level cap is reached), attack, defense, agility,
;@ intelligence, wildness, HP/max HP, MP/max MP and the ailment marks (tile $D7
;@ for status bit 0, $D8 for bit 2, $D9 for bit 7).
;@ test: skip draws text tiles in another bank
DrawStatusStats::
;> SyncStatusMonster()
	call SyncStatusMonster
;> MenuDrawNameTiles(GetViewedMonsterField(wMonName), 0x93C0)
	ld hl, wMonName
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $93c0
	call MenuDrawNameTiles
;> DrawSexMark(GetViewedMonsterByte(wMonGender), 0x9300)
	ld hl, wMonGender
	call GetViewedMonsterByte
	ld hl, $9300
	call DrawSexMark
;>@c4 mark = 0x90 if GetViewedMonsterByte(wMonLevel) < GetViewedMonsterField(wMonMaxLevel)[0] else 0xAC
	ld hl, wMonLevel
	call GetViewedMonsterByte
	push af
	ld hl, wMonMaxLevel
	call GetViewedMonsterField
	pop af
;=@c4
	cp [hl]
	ld a, $90
	jr c, .mark

	ld a, $ac

.mark
;> MenuDrawCharTile(mark, 0x8800)
	ld hl, $8800
	call MenuDrawCharTile
;>@c5 PrintNumber2(GetViewedMonsterByte(wMonLevel), BufferAddress(0x0031))
	ld hl, wMonLevel
	call GetViewedMonsterByte
	ld c, a
	ld b, $00
	ld hl, $0031
	call BufferAddress
;=@c5
	call PrintNumber2
;> DrawStatValue(wMonAttack, 0x0070)
	ld hl, wMonAttack
	ld de, $0070
	call DrawStatValue
;> DrawStatValue(wMonDefense, 0x00B0)
	ld hl, wMonDefense
	ld de, $00b0
	call DrawStatValue
;> DrawStatValue(wMonAgility, 0x00F0)
	ld hl, wMonAgility
	ld de, $00f0
	call DrawStatValue
;> DrawStatValue(wMonIntelligence, 0x0130)
	ld hl, wMonIntelligence
	ld de, $0130
	call DrawStatValue
;> DrawStatValue(wMonWildness, 0x0170)
	ld hl, wMonWildness
	ld de, $0170
	call DrawStatValue
;> DrawStatValue(wMonHP, 0x01CC)
	ld hl, wMonHP
	ld de, $01cc
	call DrawStatValue
;> DrawStatValue(wMonMaxHP, 0x01D0)
	ld hl, wMonMaxHP
	ld de, $01d0
	call DrawStatValue
;> DrawStatValue(wMonMP, 0x020C)
	ld hl, wMonMP
	ld de, $020c
	call DrawStatValue
;> DrawStatValue(wMonMaxMP, 0x0210)
	ld hl, wMonMaxMP
	ld de, $0210
	call DrawStatValue
;> status = GetViewedMonsterByte(wMonStatus)
	ld hl, wMonStatus
	call GetViewedMonsterByte
	ld b, a
;> p = BufferAddress(0x01F0)
	ld hl, $01f0
	call BufferAddress
;>@c6 mem[p] = 0xD7 if status & 0x01 else 0xE0
	bit 0, b
	ld a, $e0
	jr z, .mark1

	ld a, $d7

.mark1
;=@c6
	ld [hli], a
;>@c7 mem[p + 1] = 0xD8 if status & 0x04 else 0xE0
	bit 2, b
	ld a, $e0
	jr z, .mark2

	ld a, $d8

.mark2
;=@c7
	ld [hli], a
;>@c8 mem[p + 2] = 0xD9 if status & 0x80 else 0xE0
	bit 7, b
	ld a, $e0
	jr z, .mark3

	ld a, $d9

.mark3
;=@c8
	ld [hl], a
	ret


;@ def DrawStatValue(field: hl, pos: de)
;@ path: menu/status
;@ Prints the 16-bit record field `field` of the viewed monster (3 digits) at
;@ buffer offset `pos`.
;@ test: skip reads monster records through the party helpers
DrawStatValue::
;> PrintNumber3(GetViewedMonsterWord(field), BufferAddress(pos))
	push de
	call GetViewedMonsterWord
	pop hl
	call BufferAddress
	call PrintNumber3
	ret


;@ def SyncStatusMonster()
;@ path: menu/status
;@ In the field menu (wFieldFlags bit 1) the viewed monster is the party place under
;@ the cursor: wCurPartyMember = wMenuChoice2.
SyncStatusMonster::
;> if not wFieldFlags & 0x02:
;>     return
	ld a, [wFieldFlags]
	bit 1, a
	ret z

;> wCurPartyMember = wMenuChoice2
	ld a, [wMenuChoice2]
	ld [wCurPartyMember], a
	ret


;@ def StatusPage1Input()
;@ path: menu/status
;@ First status page: Up/Down shows another party monster, B goes back to the main
;@ menu, A turns to the next page.
;@ test: skip draws into VRAM
StatusPage1Input::
;> if MoveStatusMonCursor():          # another monster: redraw the page
	call MoveStatusMonCursor
	jr z, .buttons

;>     SyncStatusMonster()
	call SyncStatusMonster
;>     DrawStatusStats()
	call DrawStatusStats
;>     MenuShowBuffer()
	call MenuShowBuffer
;>     LoadStatusPicture()
	call LoadStatusPicture
;>     SetStatusPicPalette()
	call SetStatusPicPalette

.buttons
;> if wJoyPressed & 0x02:             # B: back to the main menu
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     MenuClearBuffer()
	call MenuClearBuffer
;>     wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a
	jr .done

.notB
;> elif wJoyPressed & 0x01:           # A: next page
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]

.done
	ret


;@ path: menu/status
;@ Cursor positions of the status party list: buffer offsets (row * 32 + column) of
;@ the three names, $FFFF ends the list.
StatusMonCursorPos::
	dw $0061, $00a1, $00e1
	dw $ffff

;@ def MoveStatusMonCursor() -> f
;@ path: menu/status
;@ Moves the status party-list cursor with Up/Down; returns nz (flag) when it now
;@ points at another monster.
;@ test: skip draws into VRAM
MoveStatusMonCursor::
;> old = wMenuChoice2
	ld de, StatusMonCursorPos
	ld hl, wMenuChoice2
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
	push af
;> MoveMenuCursorNoSelect(wMenuChoice2, wPartyCount, StatusMonCursorPos)
	call MoveMenuCursorNoSelect
;>@c1 return (wMenuChoice2 & 0x7F) != (old & 0x7F)
	pop af
	ld hl, wMenuChoice2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@c1
	cp b
	ret


;@ def StatusShowPicture()
;@ path: menu/status
;@ Status step 2: draws the viewed monster's picture window and goes on; also the
;@ entry the monster status screen uses to show the picture.
;@ test: skip draws into VRAM
StatusShowPicture::
;> LoadStatusPicture()
	call LoadStatusPicture
;> SetStatusPicPalette()
	call SetStatusPicPalette
;> DrawWindow(StatusPicWindow)
	ld de, StatusPicWindow
	call DrawWindow
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
;> wMenuCount = 0
	xor a
	ld [wMenuCount], a
	ret


;@ def LoadStatusPicture()
;@ path: menu/status
;@ Unpacks the viewed monster's big picture (graphics number from the table at $2B9F
;@ in the home bank) to $8B00.
;@ test: skip decompresses into VRAM
LoadStatusPicture::
;>@c2 gfx = mem16[0x2B9F + 2 * GetViewedMonsterByte(wMonRecSpecies)]
	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
;=@c2
	add $9f
	ld l, a
	ld a, h
	adc $2b
	ld h, a
	ld e, [hl]
;=@c2
	inc hl
	ld d, [hl]
;> DecompressVRAM(gfx >> 8, gfx & 0xFF, 0x8B00)
	ld hl, $8b00
	call DecompressVRAM
	ret


;@ def SetStatusPicPalette()
;@ path: menu/status
;@ Gives the status picture (buffer offset $0141) the viewed monster's CGB palette
;@ as palette 4.
;@ test: skip calls routines in another bank
SetStatusPicPalette::
;> mem16[0xC820] = 0x0141
	ld hl, $0141
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
;> wPaletteSet = GetViewedMonsterByte(wMonRecSpecies)
	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
	ld [wPaletteSet], a
;> mem[0xC81F] = 4
	ld a, $04
	ld [$c81f], a
;> LoadMonPicPalette()
	ld hl, far_LoadMonPicPalette
	rst $10
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
	ret


;@ def StatusStepNext()
;@ path: menu/status
;@ Status step 3: just goes on to the next step.
StatusStepNext::
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def StatusStepSkip()
;@ path: menu/status
;@ Status step 4: skips a step (to step 6).
StatusStepSkip::
;> wFieldMenuStep += 2
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def StatusStepBack4()
;@ path: menu/status
;@ Status step 5: goes back four steps (to step 1, the first page's input).
StatusStepBack4::
;>@c3 wFieldMenuStep -= 4
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
;=@c3
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ret


;@ def StatusShowPage2()
;@ path: menu/status
;@ Status step 6: draws the second page (DrawStatusPage2) and goes on.
;@ test: skip draws into VRAM
StatusShowPage2::
;> DrawStatusPage2()
	call DrawStatusPage2
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def DrawStatusPage2()
;@ path: menu/status
;@ Second status page: name, sex, level mark, personality, family with its plus
;@ value, species name, the master's name, level, experience points and the points
;@ still needed for the next level (blank at level 99 or at the level cap), and the
;@ monster's walking sprite tiles at $8500.
;@ test: skip draws text tiles in another bank
DrawStatusPage2::
;> SyncStatusMonster()
	call SyncStatusMonster
;> MenuDrawNameTiles(GetViewedMonsterField(wMonName), 0x93C0)
	ld hl, wMonName
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $93c0
	call MenuDrawNameTiles
;> DrawSexMark(GetViewedMonsterByte(wMonGender), 0x9300)
	ld hl, wMonGender
	call GetViewedMonsterByte
	ld hl, $9300
	call DrawSexMark
;>@c4 mark = 0x90 if GetViewedMonsterByte(wMonLevel) < GetViewedMonsterField(wMonMaxLevel)[0] else 0xAC
	ld hl, wMonLevel
	call GetViewedMonsterByte
	push af
	ld hl, wMonMaxLevel
	call GetViewedMonsterField
	pop af
;=@c4
	cp [hl]
	ld a, $90
	jr c, .mark

	ld a, $ac

.mark
;> MenuDrawCharTile(mark, 0x8800)
	ld hl, $8800
	call MenuDrawCharTile
;> wTextIndex = GetMonsterPersonality(GetViewedMonster())
	call GetViewedMonster
	ld d, a
	ld hl, far_GetMonsterPersonality
	rst $10
	ld a, d
	ld [wTextIndex], a
;> wTextGroup = 0x0A                       # personality names
	ld a, $0a
	ld [wTextGroup], a
;> MenuDrawTextTiles(0x9330, width=1, height=9)
	ld hl, $9330
	ld de, $0901
	call MenuDrawTextTiles
;>@c5 DrawFamilyPlus(GetViewedMonsterByte(wMonPlus), GetViewedMonsterByte(wMonFamily), 0x95B0)
	ld hl, wMonFamily
	call GetViewedMonsterByte
	ld c, a
	push bc
	ld hl, wMonPlus
	call GetViewedMonsterByte
;=@c5
	ld hl, $95b0
	pop bc
	call DrawFamilyPlus
;> wTextIndex = GetViewedMonsterByte(wMonRecSpecies)
	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
	ld [wTextIndex], a
;> wTextGroup = 5                         # monster names
	ld a, $05
	ld [wTextGroup], a
;> MenuDrawTextTiles(0x94C0, width=1, height=9)
	ld hl, $94c0
	ld de, $0901
	call MenuDrawTextTiles
;> MenuDrawNameTiles(GetViewedMonsterField(wMonMaster), 0x9550)
	ld hl, wMonMaster
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $9550
	call MenuDrawNameTiles
;> DrawWindow(StatusInfoWindow)
	ld de, StatusInfoWindow
	call DrawWindow
;> DrawWindow(StatusExpWindow)
	ld de, StatusExpWindow
	call DrawWindow
;>@c6 PrintNumber2(GetViewedMonsterByte(wMonLevel), BufferAddress(0x0031))
	ld hl, wMonLevel
	call GetViewedMonsterByte
	ld c, a
	ld b, $00
	ld hl, $0031
	call BufferAddress
;=@c6
	call PrintNumber2
;>@c7 hNumber[0:3] = GetViewedMonsterField(wMonExp)[0:3]
	ld hl, wMonExp
	call GetViewedMonsterField
	ld a, [hli]
	ldh [hNumber], a
	ld a, [hli]
	ldh [hNumber + 1], a
;=@c7
	ld a, [hl]
	ldh [hNumber + 2], a
;> PrintNumber7(BufferAddress(0x016B))
	ld hl, $016b
	call BufferAddress
	call PrintNumber7
;>@c8 hNumber[0:3] = GetViewedMonsterField(wMonExp)[0:3]
	ld hl, wMonExp
	call GetViewedMonsterField
	ld a, [hli]
	ldh [hNumber], a
	ld a, [hli]
	ldh [hNumber + 1], a
;=@c8
	ld a, [hl]
	ldh [hNumber + 2], a
;> saved = wCurPartyMember
;> wCurPartyMember = GetViewedMonster()       # the record slot
	ld a, [wCurPartyMember]
	push af
	call GetViewedMonster
	ld [wCurPartyMember], a
;> level = MonsterField(wCurPartyMember, wMonLevel)[0]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
;>@c9 if level != 99 and level != MonsterField(wCurPartyMember, wMonMaxLevel)[0]:
	cp $63
	jr z, .restore

;=@c9
	push af
	ld a, [wCurPartyMember]
	ld hl, wMonMaxLevel
	call MonsterField
	pop af
	cp [hl]
;=@c9
	jr z, .restore

;>     GetExpForNextLevel()                    # hNumber = experience the next level needs
	ld hl, far_GetExpForNextLevel
	rst $10

.restore
;> wCurPartyMember = saved
	pop af
	ld [wCurPartyMember], a
;>@c10 hNumber -= GetViewedMonsterField(wMonExp)   # 24-bit: points still to go
	ld hl, wMonExp
	call GetViewedMonsterField
	ldh a, [hNumber]
	sub [hl]
	inc hl
	ldh [hNumber], a
;=@c10
	ldh a, [hNumber + 1]
	sbc [hl]
	inc hl
	ldh [hNumber + 1], a
	ldh a, [hNumber + 2]
	sbc [hl]
;=@c10
	ldh [hNumber + 2], a
;> PrintNumber7(BufferAddress(0x020B))
	ld hl, $020b
	call BufferAddress
	call PrintNumber7
;> MenuShowBuffer()
	call MenuShowBuffer
;> LoadMonsterSprite(GetViewedMonsterByte(wMonRecSpecies), 0x8500)
	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
	ld hl, $8500
	call LoadMonsterSprite
	ret


;@ def StatusPage2Input()
;@ path: menu/status
;@ Second status page: Up/Down shows another party monster, B goes back to the
;@ first page, A turns to the skills page; the monster's sprite walks on screen.
;@ test: skip draws into VRAM
StatusPage2Input::
;> if MoveStatusMonCursor():
	call MoveStatusMonCursor
	jr z, .buttons

;>     wFieldMenuStep = 0x0D             # redraw page 2 for the new monster
	ld a, $0d
	ld [wFieldMenuStep], a
	jr .done

.buttons
;> elif wJoyPressed & 0x02:            # B: back to page 1
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     StatusDrawPage1()
	call StatusDrawPage1
;>     wFieldMenuStep = 1
	ld a, $01
	ld [wFieldMenuStep], a
	jr .done

.notB
;> else:
;>     if wJoyPressed & 0x01:          # A: on to the skills
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .sprite

;>         QueueSound(0x59)
	ld a, $59
	call QueueSound
;>         wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]

.sprite
;>     DrawStatusSprite()
	call DrawStatusSprite

.done
	ret


;@ def StatusShowSkills()
;@ path: menu/status
;@ Status step 8: the skills page - the eight skill names in two columns, with the
;@ monster's picture.
;@ test: skip draws into VRAM
StatusShowSkills::
;> DrawWindowToMap(BlankPicWindow)
	ld de, BlankPicWindow
	call DrawWindowToMap
;> DrawMonSkillNames()
	call DrawMonSkillNames
;> DrawWindow(StatusSkillsWindow)
	ld de, StatusSkillsWindow
	call DrawWindow
;> MenuShowBuffer()
	call MenuShowBuffer
;>@c1 gfx = mem16[0x2B9F + 2 * GetViewedMonsterByte(wMonRecSpecies)]
	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
;=@c1
	add $9f
	ld l, a
	ld a, h
	adc $2b
	ld h, a
	ld e, [hl]
;=@c1
	inc hl
	ld d, [hl]
;> DecompressVRAM(gfx >> 8, gfx & 0xFF, 0x8B00)
	ld hl, $8b00
	call DecompressVRAM
;> DrawWindow(StatusPicWindow)
	ld de, StatusPicWindow
	call DrawWindow
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def DrawMonSkillNames()
;@ path: menu/status
;@ Draws the names of the viewed monster's eight skills: three into the tiles from
;@ $9650 on, five from $8830 on ($90 bytes, nine tiles, each).
;@ test: skip draws text tiles in another bank
DrawMonSkillNames::
;> skills = GetViewedMonsterField(wMonSkills)
	ld hl, wMonSkills
	call GetViewedMonsterField
	ld e, l
	ld d, h
;> tiles = 0x9650
	ld hl, $9650
;>@s for i in range(8):
;>     skills, tiles = DrawSkillName(skills, tiles)
	call DrawSkillName
;=@s
	call DrawSkillName
	call DrawSkillName
;>     if i == 2:
;>         tiles = 0x8830          # second column
	ld hl, $8830
;=@s
	call DrawSkillName
	call DrawSkillName
	call DrawSkillName
	call DrawSkillName

;@ def DrawSkillName(skill: de, tiles: hl) -> (de, hl)
;@ path: menu/status
;@ Draws the name of skill number [`skill`] (text group 6) into nine tiles at `tiles`;
;@ returns `skill` + 1 and `tiles` + $90.
;@ test: skip draws text tiles in another bank
DrawSkillName::
;> wTextIndex = mem[skill]
	push de
	push hl
	ld a, [de]
	ld [wTextIndex], a
;> wTextGroup = 6
	ld a, $06
	ld [wTextGroup], a
;> MenuDrawTextTiles(tiles, width=1, height=9)
	ld de, $0901
	call MenuDrawTextTiles
;>@c2 return skill + 1, tiles + 0x90
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@c2
	ld h, a
	pop de
	inc de
	ret


;@ def StatusSkillsInput()
;@ path: menu/status
;@ Skills page: Up/Down shows another party monster's skills, then the buttons
;@ (StatusSkillsButtons).
;@ test: skip draws into VRAM
StatusSkillsInput::
;> if MoveStatusMonCursor():
	call MoveStatusMonCursor
	jr z, StatusSkillsButtons

;>     SyncStatusMonster()
	call SyncStatusMonster
;>     DrawMonSkillNames()
	call DrawMonSkillNames
;>     MenuShowBuffer()
	call MenuShowBuffer
;>     LoadStatusPicture()
	call LoadStatusPicture
;>     SetStatusPicPalette()
	call SetStatusPicPalette
;> StatusSkillsButtons()

;@ def StatusSkillsButtons()
;@ path: menu/status
;@ Skills page buttons: B goes back to the second page (3 steps back), A on to the
;@ pedigree.
StatusSkillsButtons::
;> if wJoyPressed & 0x02:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>@c7     wFieldMenuStep -= 3
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;=@c7
	jr .done

.notB
;> elif wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]

.done
	ret


;@ def StatusShowPedigree()
;@ path: menu/status
;@ Status step 10: the pedigree page (DrawPedigree).
;@ test: skip draws into VRAM
StatusShowPedigree::
;> DrawWindow(StatusPedigreeWindow)
	ld de, StatusPedigreeWindow
	call DrawWindow
;> MenuShowBuffer()
	call MenuShowBuffer
;> DrawPedigree()
	call DrawPedigree
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def DrawPedigree()
;@ path: menu/status
;@ The pedigree page: for both parents their name, their master's name, family with
;@ plus value and species name, and their walking sprite tiles ($8600, $8700). A
;@ monster without parents ($FF) shows blank entries. The family of a parent is
;@ looked up in its MonsterStats record (first byte).
;@ test: skip draws text tiles in another bank
DrawPedigree::
;> MenuDrawNameTiles(GetViewedMonsterField(wMonParent1Name), 0x88C0)
	ld hl, wMonParent1Name
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $88c0
	call MenuDrawNameTiles
;> MenuDrawNameTiles(GetViewedMonsterField(wMonParent1Master), 0x8900)
	ld hl, wMonParent1Master
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $8900
	call MenuDrawNameTiles
;> family = GetViewedMonsterByte(wMonParent1)
	ld hl, wMonParent1
	call GetViewedMonsterByte
;> if family != 0xFF:
	cp $ff
	jr z, .family1

;>     wMonSpecies = family
	ld [wMonSpecies], a
;>     GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;>     family = wMonStats[0]
	ld a, [wMonStats]

.family1
;>@c3 DrawFamilyPlus(GetViewedMonsterByte(wMonParent1Plus), family, 0x95E0)
	ld c, a
	push bc
	ld hl, wMonParent1Plus
	call GetViewedMonsterByte
	ld hl, $95e0
	pop bc
;=@c3
	call DrawFamilyPlus
;> wTextIndex = GetViewedMonsterByte(wMonParent1)
	ld hl, wMonParent1
	call GetViewedMonsterByte
	ld [wTextIndex], a
;> wTextGroup = 5
	ld a, $05
	ld [wTextGroup], a
;> DrawTextOrBlank(0x94C0, width=1, height=9)
	ld hl, $94c0
	ld de, $0901
	call DrawTextOrBlank
;> MenuDrawNameTiles(GetViewedMonsterField(wMonParent2Name), 0x8940)
	ld hl, wMonParent2Name
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $8940
	call MenuDrawNameTiles
;> MenuDrawNameTiles(GetViewedMonsterField(wMonParent2Master), 0x8980)
	ld hl, wMonParent2Master
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $8980
	call MenuDrawNameTiles
;> family = GetViewedMonsterByte(wMonParent2)
	ld hl, wMonParent2
	call GetViewedMonsterByte
;> if family != 0xFF:
	cp $ff
	jr z, .family2

;>     wMonSpecies = family
	ld [wMonSpecies], a
;>     GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;>     family = wMonStats[0]
	ld a, [wMonStats]

.family2
;>@c4 DrawFamilyPlus(GetViewedMonsterByte(wMonParent2Plus), family, 0x9660)
	ld c, a
	push bc
	ld hl, wMonParent2Plus
	call GetViewedMonsterByte
	ld hl, $9660
	pop bc
;=@c4
	call DrawFamilyPlus
;> wTextIndex = GetViewedMonsterByte(wMonParent2)
	ld hl, wMonParent2
	call GetViewedMonsterByte
	ld [wTextIndex], a
;> wTextGroup = 5
	ld a, $05
	ld [wTextGroup], a
;> DrawTextOrBlank(0x9550, width=1, height=9)
	ld hl, $9550
	ld de, $0901
	call DrawTextOrBlank
;> DrawWindow(PedigreeParent1Window)
	ld de, PedigreeParent1Window
	call DrawWindow
;> DrawWindow(PedigreeParent2Window)
	ld de, PedigreeParent2Window
	call DrawWindow
;> MenuShowBuffer()
	call MenuShowBuffer
;> if GetViewedMonsterByte(wMonParent2) == 0xFF:
	ld hl, wMonParent2
	call GetViewedMonsterByte
	cp $ff
	jr nz, .parents

;>     DrawWindow(BlankPicWindow2)
	ld de, BlankPicWindow2
	call DrawWindow
;>     MenuShowBuffer()
	call MenuShowBuffer
;>     return
	ret


.parents
;> # (looks up a picture number here and drops it again)
;>@c5 DrawWindow(StatusPicWindow)
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add $9f
	ld l, a
;=@c5
	ld a, h
	adc $2b
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
;=@c5
	ld de, StatusPicWindow
	call DrawWindow
;> DrawWindow(PedigreePic2Window)
	ld de, PedigreePic2Window
	call DrawWindow
;> MenuShowBuffer()
	call MenuShowBuffer
;>@c6 LoadMonsterSprite(GetViewedMonsterByte(wMonParent1), 0x8600)
	ld hl, wMonParent1
	call GetViewedMonsterByte
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
;=@c6
	add $9f
	ld l, a
	ld a, h
	adc $2b
	ld h, a
	ld e, [hl]
;=@c6
	inc hl
	ld d, [hl]
	ld hl, wMonParent1
	call GetViewedMonsterByte
	ld hl, $8600
	call LoadMonsterSprite
;> LoadMonsterSprite(GetViewedMonsterByte(wMonParent2), 0x8700)
	ld hl, wMonParent2
	call GetViewedMonsterByte
	ld hl, $8700
	call LoadMonsterSprite
	ret


;@ def StatusPedigreeInput()
;@ path: menu/status
;@ Pedigree page: Up/Down redraws it for another party monster, then the buttons
;@ (StatusPedigreeButtons).
;@ test: skip draws into VRAM
StatusPedigreeInput::
;> if MoveStatusMonCursor():
	call MoveStatusMonCursor
	jr z, StatusPedigreeButtons

;>     wFieldMenuStep = 0x0E
	ld a, $0e
	ld [wFieldMenuStep], a
;>     return
	jr jr_007_4a59
;> StatusPedigreeButtons()

;@ def StatusPedigreeButtons()
;@ path: menu/status
;@ Pedigree page buttons: B goes back to the skills page, A closes the status pages;
;@ the parents' sprites walk on screen meanwhile.
;@ test: skip draws into VRAM
StatusPedigreeButtons::
;> if wJoyPressed & 0x02:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     wFieldMenuStep -= 3
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;>     DrawWindow(BlankPicWindow)
	ld de, BlankPicWindow
	call DrawWindow
;>     MenuShowBuffer()
	call MenuShowBuffer
;>     DrawWindow(StatusPedigreeWindow)
	ld de, StatusPedigreeWindow
	call DrawWindow
;>     MenuShowBuffer()
	call MenuShowBuffer
	jr jr_007_4a59

.notB
;> else:
;>     if wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .sprites

;>         QueueSound(0x59)
	ld a, $59
	call QueueSound
;>         wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]

.sprites
;>     DrawPedigreeSprites()
	call DrawPedigreeSprites

jr_007_4a59:
	ret


;@ def StatusClose()
;@ path: menu/status
;@ Status step 12: clears the screen and returns to the main menu.
;@ test: skip draws into VRAM
StatusClose::
;> MenuClearBuffer()
	call MenuClearBuffer
;> MenuShowBuffer()
	call MenuShowBuffer
;> wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a
	ret


;@ def StatusRedrawPage2()
;@ path: menu/status
;@ Status step 13: redraws the second page for another monster, then back to its
;@ input (step 7).
;@ test: skip draws into VRAM
StatusRedrawPage2::
;> SyncStatusMonster()
	call SyncStatusMonster
;> DrawStatusPage2()
	call DrawStatusPage2
;> LoadStatusPicture()
	call LoadStatusPicture
;> SetStatusPicPalette()
	call SetStatusPicPalette
;> wFieldMenuStep = 7
	ld a, $07
	ld [wFieldMenuStep], a
	ret


;@ def StatusRedrawPedigree()
;@ path: menu/status
;@ Status step 14: redraws the pedigree for another monster, then back to its input
;@ (step 11).
;@ test: skip draws into VRAM
StatusRedrawPedigree::
;> SyncStatusMonster()
	call SyncStatusMonster
;> DrawPedigree()
	call DrawPedigree
;> LoadStatusPicture()
	call LoadStatusPicture
;> SetStatusPicPalette()
	call SetStatusPicPalette
;> wFieldMenuStep = 0x0B
	ld a, $0b
	ld [wFieldMenuStep], a
	ret


;@ def ItemMenu()
;@ path: menu/items
;@ The item option of the field menu: the bag list (five items a page), use or
;@ discard, choosing the monster to use it on; wFieldMenuStep is the step.
;@ test: skip jumps through a table
ItemMenu::
;> ItemMenuSteps[wFieldMenuStep]()
	ld a, [wFieldMenuStep]
	rst $00

;@ path: menu/items
;@ Steps of the item option (ItemMenu).
ItemMenuSteps::
	dw ItemMenuOpen
	dw ItemMenuDraw
	dw ItemListInput
	dw ItemShowUseDiscard
	dw ItemUseDiscardInput
	dw ItemShowTargets
	dw ItemTargetInput
	dw ItemStartUse
	dw ItemShowMessage
	dw ItemApply
	dw ItemCloseAfterText
	dw ItemStepIdle
	dw ItemMenuEmpty
	dw ItemEmptyInput
	dw ItemAskDiscard
	dw ItemDiscardInput
	dw ItemDiscard

;@ def ItemMenuOpen()
;@ path: menu/items
;@ Item step 0: draws the names of the bag page and the description of the item
;@ under the cursor; with an empty bag goes to the "no items" message (step 12).
;@ test: skip draws text tiles in another bank
ItemMenuOpen::
;> DrawItemDescription()
	call DrawItemDescription
;> DrawBagPage()
	call DrawBagPage
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
;> CountBagItems()
	call CountBagItems
;> if wMenuCount == 0:
	ld a, [wMenuCount]
	or a
	ret nz

;>     wFieldMenuStep = 0x0C
	ld a, $0c
	ld [wFieldMenuStep], a
	ret


;@ def ItemMenuDraw()
;@ path: menu/items
;@ Item step 1: draws the main menu, gold, the bag list and the description window,
;@ the cursors and the page marks.
;@ test: skip draws into VRAM
ItemMenuDraw::
;> CountBagItems()
	call CountBagItems
;> MenuClearBuffer()
	call MenuClearBuffer
;> DrawWindow(MainMenuWindow)
	ld de, MainMenuWindow
	call DrawWindow
;> DrawWindow(GoldWindow)
	ld de, GoldWindow
	call DrawWindow
;> DrawWindow(ItemListWindow)
	ld de, ItemListWindow
	call DrawWindow
;> DrawWindow(ItemInfoWindow)
	ld de, ItemInfoWindow
	call DrawWindow
;> hNumber[0:3] = wGold[0:3]
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(BufferAddress(0x002E))
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
;> MenuResetBlink()
	call MenuResetBlink
;> MenuDrawCursorAt(wLinkChoice, MainMenuCursorPos)
	ld de, $44b4
	ld a, [wLinkChoice]
	call MenuDrawCursorAt
;> DrawListMarks(wMenuChoice2, ItemListCursorPos, 5, wMenuCount)
	ld de, ItemListCursorPos
	ld b, $05
	ld a, [wMenuCount]
	ld c, a
	ld hl, wMenuChoice2
	call DrawListMarks
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def DrawBagPage()
;@ path: menu/items
;@ Draws six item names from the start of the current bag page (wConfirmChoice is the
;@ page; the list shows five) into nine tiles each: the first at $9700, the others
;@ from $8800 on.
;@ test: skip draws text tiles in another bank
DrawBagPage::
;>@c1 items = wBagItems + 5 * wConfirmChoice
	ld de, wBagItems
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
;=@c1
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;> tiles = 0x9700
	ld hl, $9700
;>@i for i in range(6):
;>     items, tiles = DrawItemName(items, tiles)
	call DrawItemName
;>     if i == 0:
;>         tiles = 0x8800
	ld hl, $8800
;=@i
	call DrawItemName
	call DrawItemName
	call DrawItemName
	call DrawItemName

;@ def DrawItemName(item: de, tiles: hl) -> (de, hl)
;@ path: menu/items
;@ Draws the name of item [`item`] (text group 8; an empty slot $FF as item 0)
;@ into nine tiles at `tiles`; returns `item` + 1 and `tiles` + $90.
;@ test: skip draws text tiles in another bank
DrawItemName::
;>@c2 wTextIndex = mem[item] if mem[item] != 0xFF else 0
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, .text

	ld a, $00

.text
;=@c2
	ld [wTextIndex], a
;> wTextGroup = 8
	ld a, $08
	ld [wTextGroup], a
;> MenuDrawTextTiles(tiles, width=1, height=9)
	ld de, $0901
	call MenuDrawTextTiles
;>@c3 return item + 1, tiles + 0x90
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@c3
	ld h, a
	pop de
	inc de
	ret


;@ def DrawItemDescription()
;@ path: menu/items
;@ Draws the description (text group 9, two lines of 18) of the item under the
;@ cursor into the tiles at $94C0.
;@ test: skip draws text tiles in another bank
DrawItemDescription::
;>@c4 item = wBagItems[5 * wConfirmChoice + (wMenuChoice2 & 0x7F)]
	ld hl, wBagItems
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
;=@c4
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	add l
	ld l, a
;=@c4
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>@c5 wTextIndex = item if item != 0xFF else 0
	cp $ff
	jr nz, .text

	ld a, $00

.text
;=@c5
	ld [wTextIndex], a
;> wTextGroup = 9
	ld a, $09
	ld [wTextGroup], a
;> MenuDrawTextTiles(0x94C0, width=2, height=0x12)
	ld hl, $94c0
	ld de, $1202
	call MenuDrawTextTiles
	ret


;@ def CountBagItems()
;@ path: menu/items
;@ Counts the items at the front of the bag (up to the first empty slot, 0 or $FF)
;@ into wMenuCount.
CountBagItems::
;> n = 0
;>@c6 while n < 20 and wBagItems[n] not in (0x00, 0xFF):
	ld hl, wBagItems
	ld b, $14
	ld c, $00
.loop
	ld a, [hli]
	cp $00
	jr z, .done

;=@c6
	cp $ff
	jr z, .done

;>@c7     n += 1
	inc c
;=@c7
	dec b
	jr nz, .loop

.done
;> wMenuCount = n
	ld a, c
	ld [wMenuCount], a
	ret


;@ def ItemListInput()
;@ path: menu/items
;@ Item step 2, the bag list: Up/Down moves the cursor, Left/Right turns the page
;@ (the description and names follow), B leaves to the main menu, A goes on to
;@ "use / discard", Select sorts the bag and redraws it.
;@ test: skip draws into VRAM
ItemListInput::
;> old_cursor = wMenuChoice2
;>@c8 old_page = wConfirmChoice
	ld de, ItemListCursorPos
	ld hl, wMenuChoice2
	ld a, [wMenuCount]
	ld c, a
	ld b, $05
	inc hl
;=@c8
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> MoveListCursor(wMenuChoice2, ItemListCursorPos, 5, wMenuCount)
	call MoveListCursor
;>@c9 if (wMenuChoice2 & 0x7F) != (old_cursor & 0x7F):
	pop af
	ld hl, wMenuChoice2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@c9
	cp b
	jr z, .samePlace

;>     DrawItemDescription()
	call DrawItemDescription

.samePlace
;> if wConfirmChoice != old_page:
	pop af
	ld hl, wConfirmChoice
	cp [hl]
	jr z, .buttons

;>     DrawBagPage()
	call DrawBagPage
;>     DrawItemDescription()
	call DrawItemDescription

.buttons
;> if wJoyPressed & 0x02:             # B: back to the main menu
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     MenuClearBuffer()
	call MenuClearBuffer
;>     wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a
	jr .done

.notB
;> elif wJoyPressed & 0x01:           # A: use / discard
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .notA

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	jr .done

.notA
;> elif wJoyPressed & 0x04:           # Select: sort the bag
	ld a, [wJoyPressed]
	bit 2, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     SortBag()
	call SortBag
;>     wMenuChoice2 = 0
;>     wConfirmChoice = 0
	xor a
	ld [wMenuChoice2], a
	ld [wConfirmChoice], a
;>     wFieldMenuStep -= 2             # redraw from step 0
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ret


.done
	ret


;@ def SortBag()
;@ path: menu/items
;@ Sorts the bag by item number (bubble sort, 20 passes); empty slots (0 become $FF)
;@ end up at the back.
SortBag::
;> for i in range(20):
;>     if wBagItems[i] == 0:
;>@c10         wBagItems[i] = 0xFF
	ld hl, wBagItems
	ld b, $14
.empty
	ld a, [hl]
	or a
	jr nz, .next

	ld [hl], $ff

.next
;=@c10
	inc hl
	dec b
	jr nz, .empty

;>@p for p in range(20):
	ld c, $14
.pass
;>     for i in range(19):
	ld hl, wBagItems
	ld de, wBagItems + 1
	ld b, $13
.compare
;>         if wBagItems[i + 1] < wBagItems[i]:
;>@c11             wBagItems[i:i + 2] = [wBagItems[i + 1], wBagItems[i]]
	ld a, [de]
	cp [hl]
	jr nc, .inOrder

	push af
	ld a, [hl]
	ld [de], a
;=@c11
	pop af
	ld [hl], a

.inOrder
;=@c11
	inc de
	inc hl
	dec b
	jr nz, .compare

;=@p
	dec c
	jr nz, .pass

	ret


;@ path: menu/items
;@ Bag list marks: first the buffer offset of the page number / "more" arrow, then
;@ the cursor offsets of the five rows; $FFFF ends the list.
ItemListCursorPos::
	dw $0191
	dw $0069, $00a9, $00e9, $0129, $0169
	dw $ffff

;@ def ItemShowUseDiscard()
;@ path: menu/items
;@ Item step 3: redraws the menu with the small "use / discard" window and loads its
;@ tiles (graphics $56/$0B to $8E50).
;@ test: skip draws into VRAM
ItemShowUseDiscard::
;> MenuClearBuffer()
	call MenuClearBuffer
;> MenuResetBlink()
	call MenuResetBlink
;> DrawWindow(MainMenuWindow)
	ld de, MainMenuWindow
	call DrawWindow
;> MenuDrawCursorAt(wLinkChoice, MainMenuCursorPos)
	ld de, $44b4
	ld a, [wLinkChoice]
	call MenuDrawCursorAt
;> DrawWindow(GoldWindow)
	ld de, GoldWindow
	call DrawWindow
;> hNumber[0:3] = wGold[0:3]
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(BufferAddress(0x002E))
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
;> DrawWindow(ItemListWindow)
	ld de, ItemListWindow
	call DrawWindow
;> DrawListMarks(wMenuChoice2, ItemListCursorPos, 5, wMenuCount)
	ld de, ItemListCursorPos
	ld b, $05
	ld a, [wMenuCount]
	ld c, a
	ld hl, wMenuChoice2
	call DrawListMarks
;> DrawWindow(ItemInfoWindow)
	ld de, ItemInfoWindow
	call DrawWindow
;> DrawWindow(UseDiscardWindow)
	ld de, UseDiscardWindow
	call DrawWindow
;> MenuDrawCursorAt(wConfirmChoice2, UseDiscardCursorPos)
	ld de, UseDiscardCursorPos
	ld a, [wConfirmChoice2]
	call MenuDrawCursorAt
;> MenuShowBuffer()
	call MenuShowBuffer
;> DecompressVRAM(0x56, 0x0B, 0x8E50)
	ld de, $560b
	ld hl, $8e50
	call DecompressVRAM
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def ItemUseDiscardInput()
;@ path: menu/items
;@ Item step 4: "use" or "discard". B goes back to the list; A reads the item's
;@ record (GetItemData) and goes on to step 5 for use, step 14 for discard.
;@ test: skip draws into VRAM
ItemUseDiscardInput::
;> MoveMenuCursor(wConfirmChoice2, 2, UseDiscardCursorPos)
	ld de, UseDiscardCursorPos
	ld hl, wConfirmChoice2
	ld b, $02
	call MoveMenuCursor
;> if wJoyPressed & 0x02:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>@c11     wFieldMenuStep -= 3
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;=@c11
	jr .done

.notB
;> elif wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>@c1     wItemId = wBagItems[5 * wConfirmChoice + (wMenuChoice2 & 0x7F)]
	ld hl, wBagItems
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
;=@c1
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	add l
	ld l, a
;=@c1
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
;>     GetItemData()
	ld hl, far_GetItemData
	rst $10
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
;>     if wConfirmChoice2 != 0x80:     # "discard" chosen
	ld a, [wConfirmChoice2]
	cp $80
	jr z, .done

;>@c2         wFieldMenuStep += 9         # step 14
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
;=@c2
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
;=@c2
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]

.done
;=@c2
	ret


;@ path: menu/items
;@ Cursor offsets of the "use / discard" window; $FFFF ends the list.
UseDiscardCursorPos::
	dw $0061, $00a1
	dw $ffff

;@ def ItemShowTargets()
;@ path: menu/items
;@ Item step 5: items used on one monster (ItemData byte 4 below 2 and byte 5 0, 2
;@ or 4) get the party list to choose from, with the HP or MP of the monster under
;@ the cursor; other items skip straight to step 7.
;@ test: skip draws into VRAM
ItemShowTargets::
;>@c3 if wItemData[4] in (2, 3) or wItemData[5] not in (0, 2, 4):
	ld a, [wItemData + 4]
	cp $02
	jr z, .noTarget

	cp $03
	jr z, .noTarget

;=@c3
	ld a, [wItemData + 5]
	cp $00
	jr z, .target

	cp $02
	jr z, .target

;=@c3
	cp $04
	jr z, .target

.noTarget
;>     wFieldMenuStep += 2
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
;>     return
	ret


.target
;> DrawWindow(ItemListWindow)
	ld de, ItemListWindow
	call DrawWindow
;> DrawListMarks(wMenuChoice2, ItemListCursorPos, 5, wMenuCount)
	ld de, ItemListCursorPos
	ld b, $05
	ld a, [wMenuCount]
	ld c, a
	ld hl, wMenuChoice2
	call DrawListMarks
;> DrawWindow(ItemTargetListWindow)
	ld de, ItemTargetListWindow
	call DrawWindow
;> DrawItemTargetStats()
	call DrawItemTargetStats
;> MenuResetBlink()
	call MenuResetBlink
;> MenuDrawCursorAt(wMenuChoice3, ItemTargetCursorPos)
	ld de, ItemTargetCursorPos
	ld a, [wMenuChoice3]
	call MenuDrawCursorAt
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def DrawItemTargetStats()
;@ path: menu/items
;@ The window next to the target list: MP and max MP of the monster under the
;@ cursor for the MP items (5, 6, $0E), nothing for the items $08, $09, $0B,
;@ $0F-$17 and $1F-$24, HP and max HP for the others; then its ailment marks.
;@ test: skip writes the tilemap buffer through BufferAddress
DrawItemTargetStats::
;>@c4 wItemId = wBagItems[5 * wConfirmChoice + (wMenuChoice2 & 0x7F)]
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
;=@c4
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld hl, wBagItems
	add l
	ld l, a
;=@c4
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
;> if wItemId not in (0x05, 0x06, 0x0E):          # not an MP item
	cp $05
	jp z, .mp

	cp $06
	jp z, .mp

	cp $0e
	jp z, .mp

;>@ns     if wItemId in (0x08, 0x09, 0x0B, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x1F, 0x20, 0x21, 0x22, 0x23, 0x24):
;>         return
	cp $08
	jp z, .done

	cp $09
	jp z, .done

	cp $0b
	jp z, .done

;=@ns
	cp $0f
	jp z, .done

	cp $10
	jp z, .done

	cp $11
	jp z, .done

;=@ns
	cp $12
	jp z, .done

	cp $13
	jp z, .done

	cp $14
	jp z, .done

;=@ns
	cp $15
	jp z, .done

	cp $16
	jp z, .done

	cp $17
	jp z, .done

;=@ns
	cp $1f
	jp z, .done

	cp $20
	jp z, .done

	cp $21
	jp z, .done

;=@ns
	cp $22
	jp z, .done

	cp $23
	jp z, .done

	cp $24
	jp z, .done

;>     DrawWindow(TargetHPWindow)
	ld de, TargetHPWindow
	call DrawWindow
;>     PrintNumber3(GetPartyMonsterWord(wMenuChoice3, wMonHP), BufferAddress(0x0201))
	ld hl, wMonHP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0201
	call BufferAddress
	call PrintNumber3
;>@c12     PrintNumber3(GetPartyMonsterWord(wMenuChoice3, wMonMaxHP), BufferAddress(0x0205))
	ld hl, wMonMaxHP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0205
	call BufferAddress
	call PrintNumber3
;=@c12
	jr .marks

.mp
;> else:
;>     DrawWindow(TargetMPWindow)
	ld de, TargetMPWindow
	call DrawWindow
;>     PrintNumber3(GetPartyMonsterWord(wMenuChoice3, wMonMP), BufferAddress(0x0201))
	ld hl, wMonMP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0201
	call BufferAddress
	call PrintNumber3
;>     PrintNumber3(GetPartyMonsterWord(wMenuChoice3, wMonMaxMP), BufferAddress(0x0205))
	ld hl, wMonMaxMP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0205
	call BufferAddress
	call PrintNumber3

.marks
;> status = GetPartyMonsterByte(wMenuChoice3, wMonStatus)
	ld hl, wMonStatus
	ld a, [wMenuChoice3]
	call GetPartyMonsterByte
	ld b, a
;> p = BufferAddress(0x01C5)
	ld hl, $01c5
	call BufferAddress
;>@c5 mem[p] = 0xD7 if status & 0x01 else 0xE0
	bit 0, b
	ld a, $e0
	jr z, .mark1

	ld a, $d7

.mark1
;=@c5
	ld [hli], a
;>@c6 mem[p + 1] = 0xD8 if status & 0x04 else 0xE0
	bit 2, b
	ld a, $e0
	jr z, .mark2

	ld a, $d8

.mark2
;=@c6
	ld [hli], a
;>@c7 mem[p + 2] = 0xD9 if status & 0x80 else 0xE0
	bit 7, b
	ld a, $e0
	jr z, .mark3

	ld a, $d9

.mark3
;=@c7
	ld [hl], a

.done
	ret


;@ def ItemTargetInput()
;@ path: menu/items
;@ Item step 6, choosing the monster: Up/Down moves (the HP/MP window follows), B
;@ goes back to "use / discard", A goes on.
;@ test: skip draws into VRAM
ItemTargetInput::
;> old = wMenuChoice3
	ld de, ItemTargetCursorPos
	ld hl, wMenuChoice3
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
	push af
;> MoveMenuCursor(wMenuChoice3, wPartyCount, ItemTargetCursorPos)
	call MoveMenuCursor
;>@c8 if (wMenuChoice3 & 0x7F) != (old & 0x7F):
	pop af
	ld hl, wMenuChoice3
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@c8
	cp b
	jr z, .buttons

;>     DrawItemTargetStats()
	call DrawItemTargetStats
;>     MenuShowBuffer()
	call MenuShowBuffer

.buttons
;> if wJoyPressed & 0x02:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>@c13     wFieldMenuStep -= 3
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;=@c13
	jr .done

.notB
;> elif wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]

.done
	ret


;@ path: menu/items
;@ Cursor offsets of the item target list (the three party monsters); $FFFF ends it.
ItemTargetCursorPos::
	dw $00e1, $0121, $0161
	dw $ffff

;@ def ItemStartUse()
;@ path: menu/items
;@ Item step 7: puts the player's name, the target's name and the item's name into
;@ the message arguments and prints the item's "use" message (ItemData byte 7) -
;@ or "can't use that here" when byte 4 says it is not a field item (wItemId is
;@ then $FF); CheckItemUsable decides whether it does anything. Item $1D plays
;@ sound $57.
;@ test: skip prints text through another bank
ItemStartUse::
;> CopyName(wPlayerName, wTextArg0)
	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
;>@c9 CopyName(PartyMonsterField(wMenuChoice3, wMonName), wTextArg1)
	ld hl, wMonName
	ld a, [wMenuChoice3]
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
;=@c9
	call CopyName
;>@c10 wItemId = wBagItems[5 * wConfirmChoice + (wMenuChoice2 & 0x7F)]
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
;=@c10
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld hl, wBagItems
	add l
	ld l, a
;=@c10
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
;> CopySystemText(0x0800 | wItemId, wTextArg2)       # the item's name
	ld l, a
	ld h, $08
	ld de, wTextArg2
	call CopySystemText
;> if wItemData[4] not in (0, 1):
	ld a, [wItemData + 4]
	cp $00
	jr z, .usable

	cp $01
	jr z, .usable

;>     PrintSystemText(0x0D01)
	ld h, $0d
	ld a, $01
	ld l, a
	call PrintSystemText
;>     wItemId = 0xFF
	ld a, $ff
	ld [wItemId], a
	jr .shown

.usable
;> else:
;>     PrintSystemText(0x0D00 | wItemData[7])
	ld h, $0d
	ld a, [wItemData + 7]
	ld l, a
	call PrintSystemText
;>     wItemTarget = wMenuChoice3
	ld a, [wMenuChoice3]
	ld [wItemTarget], a
;>     CheckItemUsable()
	ld hl, far_CheckItemUsable
	rst $10

.shown
;> DrawWindow(0x2E07)                 # the message window
	ld de, $2e07
	call DrawWindow
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
;> if wItemId == 0x1D:
	ld a, [wItemId]
	cp $1d
	ret nz

;>     QueueSound(0x57)
	ld a, $57
	call QueueSound
	ret


;@ def ItemShowMessage()
;@ path: menu/items
;@ Item step 8: once the first message is done, prints the item's result message
;@ (wItemMessage, or message 2 when the item can't be used), then goes on.
;@ test: skip prints text through another bank
ItemShowMessage::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> msg = wItemMessage
	ld h, $0d
	ld a, [wItemMessage]
	ld l, a
;> if msg or wItemId == 0xFF:
	or a
	jr nz, .print

	ld a, [wItemId]
	cp $ff
	jr nz, .next

.print
;>     if wItemId == 0xFF:
;>         msg = 2
	ld a, [wItemId]
	cp $ff
	jr nz, .text

	ld l, $02

.text
;>     PrintSystemText(0x0D00 | msg)
	call PrintSystemText

.next
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def ItemApply()
;@ path: menu/items
;@ Item step 9, after the messages: uses the item (UseItem) and closes the menu, or
;@ goes on to show its result message. Two items act on the field themselves: $1D
;@ takes Terry home (a warp to map 0 at X $E8, Y $58, healing everyone when used in
;@ a gate world) and $27 reshuffles the gate floor - Terry lands on a random free
;@ spot of the floor's layout, with the exit drawn in.
;@ test: skip uses items and reloads the map
ItemApply::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> if wItemId == 0x1D:                  # back home
	ld a, [wItemId]
	cp $1d
	jr z, .home

;>@h1     wItemBagSlot = 5 * wConfirmChoice + (wMenuChoice2 & 0x7F)
;>@h2     wItemTarget = wMenuChoice3
;>@h3     UseItem()
;>@h3     BuildStatusBar()
;>@h4     mem[0xD92B] = 6
;>@h4     wWarpMap = 0
;>@h5     wWarpOnGateFloor = 0
;>@h5     wWarpX = 0x00E8
;>@h6     wWarpY = 0x0058
;>@h6     wWarpPending = 1
;>@h7     wFieldFlags &= ~0x02
;>@h7     wMenuOverlay = 1
;>@h8     StartFade(3)
;>@h8     wMapLoadState += 1
;>@h9     if IsInGateWorld():
;>@h9         HealAllMonsters()
;>@ha     return
;> elif wItemId == 0x27:                # reshuffle the floor
	cp $27
	jp z, .shuffle

;>@s1     wItemBagSlot = 5 * wConfirmChoice + (wMenuChoice2 & 0x7F)
;>@s2     wItemTarget = wMenuChoice3
;>@s3     UseItem()
;>@s3     BuildStatusBar()
;>@s4     scroll_x = hScrollX
;>@s4     scroll_y = hScrollY
;>@s5     mem[0xC925] = mem[0xC960]       # the floor's layout
;>@s5     layout = GetScreenTilemapRef()  # where the floor's tilemap is packed
;>@s6     Decompress(layout >> 8, layout & 0xFF, wSavedTilemap)
;>@s6     p = wSavedTilemap + mem16[0xC962]
;>@s7     mem[p:p + 2] = [0x3C, 0x3D]       # the exit, a 2x2 block of tiles
;>@s7     mem[p + 0x20:p + 0x22] = [0x3E, 0x3F]
;>@s8     LoadMapAttrBuffer()
;>@s8     hScrollX = 0
;>@s9     hScrollY = 0
;>@sa     while True:
;>@sa         PickRandomFloorSpot()
;>@sb         origin = 0x2DA7 + 4 * mem[0xC925]
;>@sb         hPlayerX = mem16[origin] + hTestX
;>@sc         hPlayerY = mem16[origin + 2] + hTestY
;>@sd         if not CheckPlayerOnFloorObject():
;>@sd             break
;>@se     hScrollY = scroll_y
;>@se     hScrollX = scroll_x
;>@sf     for i in range(49):             # the party walks in from where Terry stands
;>@sf         wPlayerTrail[4 * i:4 * i + 4] = [hPlayerX & 0xFF, hPlayerY & 0xFF, (hPlayerX >> 8) << 4 | hPlayerY >> 8, hPlayerFrame | hPlayerAttr]
;>@sg     wTrailPos = 0
;>@sg     wMenuOverlay = 1
;>@sh     wGameStarted |= 0x80
;>@sh     wFieldFlags &= ~0x02
;>@si     StartFade(3)
;>@si     wMapLoadState += 1
;>@sj     return
;> if wItemId != 0xFF:
	ld a, [wItemId]
	cp $ff
	jr z, .close

;>@c1     wItemBagSlot = 5 * wConfirmChoice + (wMenuChoice2 & 0x7F)
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
;=@c1
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld [wItemBagSlot], a
;>     wItemTarget = wMenuChoice3
	ld a, [wMenuChoice3]
	ld [wItemTarget], a
;>     UseItem()
	ld hl, far_UseItem
	rst $10
;>     RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;>     BuildStatusBar()
	call BuildStatusBar
;>@k     if wTextState or (wItemId == 0xFF and wItemUseUpChance != 100):
	ld a, [wTextState]
	or a
	jr nz, .next

;=@k
	ld a, [wItemId]
	cp $ff
	jr nz, .close

;=@k
	ld a, [wItemUseUpChance]
	cp $64
	jr z, .close

;>         if not wTextState:
;>             PrintSystemText(0x0D00)     # the item is used up
	ld h, $0d
	ld l, $00
	call PrintSystemText

.next
;>         wFieldMenuStep += 1
;>         return
	ld hl, wFieldMenuStep
	inc [hl]
	jr .ret

.close
;> if wFieldFlags & 0x40:
;>     return
	ld a, [wFieldFlags]
	bit 6, a
	ret nz

;> MenuClearBuffer()
	call MenuClearBuffer
;> wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a
	ret


.ret
	ret


.home
;=@h1
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
;=@h1
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld [wItemBagSlot], a
;=@h2
	ld a, [wMenuChoice3]
	ld [wItemTarget], a
;=@h3
	ld hl, far_UseItem
	rst $10
	call BuildStatusBar
;=@h4
	ld a, $06
	ld [$d92b], a
	ld hl, $0000
	ld a, l
	ld [wWarpMap], a
;=@h5
	ld a, h
	ld [wWarpOnGateFloor], a
	ld hl, $00e8
	ld a, l
	ld [wWarpX], a
	ld a, h
;=@h5
	ld [wWarpX + 1], a
;=@h6
	ld hl, $0058
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [wWarpY + 1], a
	ld a, $01
;=@h6
	ld [wWarpPending], a
;=@h7
	ld hl, wFieldFlags
	res 1, [hl]
	ld a, $01
	ld [wMenuOverlay], a
;=@h8
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
;=@h9
	call IsInGateWorld
	ret z

;=@h9
	ld hl, far_HealAllMonsters
	rst $10
;=@ha
	ret


.shuffle
;=@s1
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
;=@s1
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld [wItemBagSlot], a
;=@s2
	ld a, [wMenuChoice3]
	ld [wItemTarget], a
;=@s3
	ld hl, far_UseItem
	rst $10
	call BuildStatusBar
;=@s4
	ldh a, [hScrollX]
	ld l, a
	ldh a, [hScrollX + 1]
	ld h, a
	push hl
;=@s4
	ldh a, [hScrollY]
	ld l, a
	ldh a, [hScrollY + 1]
	ld h, a
	push hl
;=@s5
	ld a, [$c960]
	ld [$c925], a
	ld hl, far_GetScreenTilemapRef
	rst $10
;=@s6
	ld hl, wSavedTilemap
	call Decompress
	ld de, wSavedTilemap
	ld a, [$c962]
	ld l, a
	ld a, [$c963]
;=@s6
	ld h, a
	add hl, de
;=@s7
	ld a, $3c
	ld [hli], a
	inc a
	ld [hl], a
	ld a, l
	add $1f
;=@s7
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, $3e
	ld [hli], a
;=@s7
	inc a
	ld [hl], a
;=@s8
	ld hl, far_LoadMapAttrBuffer
	rst $10
	xor a
	ldh [hScrollX], a
	ldh [hScrollX + 1], a
;=@s9
	xor a
	ldh [hScrollY], a
	ldh [hScrollY + 1], a

.place
;=@sa
	call PickRandomFloorSpot
;=@sb
	ld a, [$c925]
	add a
	add a
	ld hl, $2da7
	add l
	ld l, a
;=@sb
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ldh [hPlayerX], a
	ld a, [hli]
;=@sb
	ldh [hPlayerX + 1], a
;=@sc
	ld a, [hli]
	ldh [hPlayerY], a
	ld a, [hli]
	ldh [hPlayerY + 1], a
;=@sb
	ld hl, hPlayerX
	ldh a, [hTestX]
	add [hl]
	ld [hli], a
	ldh a, [hTestX + 1]
	adc [hl]
;=@sb
	ld [hl], a
;=@sc
	ld hl, hPlayerY
	ldh a, [hTestY]
	add [hl]
	ld [hli], a
	ldh a, [hTestY + 1]
	adc [hl]
;=@sc
	ld [hl], a
;=@sd
	call CheckPlayerOnFloorObject
	jr z, .place

;=@se
	pop hl
	ld a, l
	ldh [hScrollY], a
	ld a, h
	ldh [hScrollY + 1], a
;=@se
	pop hl
	ld a, l
	ldh [hScrollX], a
	ld a, h
	ldh [hScrollX + 1], a
;=@sf
	ld b, $31
	ld hl, wPlayerTrail
.trail
;=@sf
	ldh a, [hPlayerX]
	ld [hli], a
	ldh a, [hPlayerY]
	ld [hli], a
	ldh a, [hPlayerX + 1]
	swap a
;=@sf
	ld c, a
	ldh a, [hPlayerY + 1]
	or c
	ld [hli], a
	ldh a, [hPlayerFrame]
	ld c, a
;=@sf
	ldh a, [hPlayerAttr]
	or c
	ld [hli], a
	dec b
	jr nz, .trail

;=@sg
	xor a
	ld [wTrailPos], a
	ld a, $01
	ld [wMenuOverlay], a
;=@sh
	ld hl, wGameStarted
	set 7, [hl]
	ld hl, wFieldFlags
	res 1, [hl]
;=@si
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
;=@sj
	ret


;@ def PickRandomFloorSpot()
;@ path: menu/items
;@ Picks random map coordinates for the floor reshuffle - X one of 8 tile centres
;@ ($18-$88), Y one of 6 ($18-$68) - until GetCollisionAt finds floor there (tile
;@ type $0C or $0D); the result is in hTestX / hTestY.
;@ test: skip loops on the collision test
PickRandomFloorSpot::
;> while True:
;>     Random()
	call Random
;>@c2     hTestX = (wRandomHigh % 8 + 1) * 16 + 8
	ld a, [wRandomHigh]
	ld b, a
	ld a, $08
	call Divide8
	add $01
	swap a
;=@c2
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
	and $0f
;=@c2
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [hTestX + 1], a
;>     Random()
	call Random
;>@c3     hTestY = (wRandomHigh % 6 + 1) * 16 + 8
	ld a, [wRandomHigh]
	ld b, a
	ld a, $06
	call Divide8
	add $01
	swap a
;=@c3
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
	and $0f
;=@c3
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [hTestY + 1], a
;>     GetCollisionAt()
	call GetCollisionAt
;>     if hTestTile >> 2 in (0x0C, 0x0D):
;>@c4         return
	ldh a, [hTestTile]
	srl a
	srl a
	cp $0c
	ret z

;=@c4
	cp $0d
	ret z

	jr PickRandomFloorSpot

;@ def CheckPlayerOnFloorObject() -> f
;@ path: menu/items
;@ Returns z (flag) when Terry stands on one of the floor's objects (wFloorObjects,
;@ entries with bit 7 set are skipped), nz otherwise.
;@ test: skip walks the floor object list
CheckPlayerOnFloorObject::
;> obj = wFloorObjects
	ld hl, wFloorObjects
.loop
;>@c5 while mem[obj] != 0xFF:
	ld a, [hl]
	cp $ff
	jr nz, .entry

;=@c5
	or a
	ret

.entry
;>     if not mem[obj] & 0x80 and IsPlayerAtObject(obj):
;>         return True
	bit 7, a
	jr nz, .next

	push hl
	call IsPlayerAtObject
	pop hl
	ret z

.next
;>     obj += 4
	inc hl
	inc hl
	inc hl
	inc hl
	jr .loop

;> return False

;@ def IsPlayerAtObject(obj: hl) -> f
;@ path: menu/items
;@ Returns z (flag) when Terry's position is the centre of the map tile of floor
;@ object `obj` (column in byte 2, row in byte 3; 16-pixel tiles, centre at +8).
;@ test: skip compares HRAM positions
IsPlayerAtObject::
;>@c6 x = mem[obj + 2] * 16 + 8
	inc hl
	inc hl
	ld a, [hli]
	swap a
	ld b, a
	and $f0
;=@c6
	or $08
	ld c, a
	ld a, b
	and $0f
	ld b, a
;> if hPlayerX != x:
;>@c7     return False
	ldh a, [hPlayerX]
	ld e, a
	ldh a, [hPlayerX + 1]
	ld d, a
	ld a, e
	sub c
;=@c7
	ld e, a
	ld a, d
	sbc b
	ld d, a
	ld a, d
	or e
;=@c7
	ret nz

;>@c8 y = mem[obj + 3] * 16 + 8
	ld a, [hl]
	swap a
	ld b, a
	and $f0
	or $08
	ld c, a
;=@c8
	ld a, b
	and $0f
	ld b, a
;>@c9 return hPlayerY == y
	ldh a, [hPlayerY]
	ld e, a
	ldh a, [hPlayerY + 1]
	ld d, a
	ld a, e
	sub c
;=@c9
	ld e, a
	ld a, d
	sbc b
	ld d, a
	ld a, d
	or e
;=@c9
	ret


;@ def ItemCloseAfterText()
;@ path: menu/items
;@ Item step 10: once the message is done, back to the main menu.
;@ test: skip draws into VRAM
ItemCloseAfterText::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> MenuClearBuffer()
	call MenuClearBuffer
;> wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a
	ret


;@ def ItemStepIdle()
;@ path: menu/items
;@ Item step 11: does nothing.
ItemStepIdle::
;> return
	ret


;@ def ItemMenuEmpty()
;@ path: menu/items
;@ Item step 12, the bag is empty: draws the menu with the word for "nothing"
;@ (text 2/$0D) in the list.
;@ test: skip draws into VRAM
ItemMenuEmpty::
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x0D
	ld a, $0d
	ld [wTextIndex], a
;> MenuDrawTextTiles(0x9700, width=1, height=9)
	ld hl, $9700
	ld de, $0901
	call MenuDrawTextTiles
;> DrawWindow(MainMenuWindow)
	ld de, MainMenuWindow
	call DrawWindow
;> DrawWindow(GoldWindow)
	ld de, GoldWindow
	call DrawWindow
;> hNumber[0:3] = wGold[0:3]
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(BufferAddress(0x002E))
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
;> MenuResetBlink()
	call MenuResetBlink
;> DrawWindow(ItemListWindow)
	ld de, ItemListWindow
	call DrawWindow
;> MenuDrawCursorAt(wLinkChoice, MainMenuCursorPos)
	ld de, $44b4
	ld a, [wLinkChoice]
	call MenuDrawCursorAt
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def ItemEmptyInput()
;@ path: menu/items
;@ Item step 13: A or B leaves the empty bag for the main menu.
;@ test: skip draws into VRAM
ItemEmptyInput::
;> if wJoyPressed & 0x03:
	ld a, [wJoyPressed]
	and $03
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     MenuClearBuffer()
	call MenuClearBuffer
;>     wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a

.done
	ret


;@ def ItemAskDiscard()
;@ path: menu/items
;@ Item step 14: asks whether to throw the item away (message 2/$01 with the
;@ item's name) and shows the yes/no window.
;@ test: skip prints text through another bank
ItemAskDiscard::
;>@c1 item = wBagItems[5 * wConfirmChoice + (wMenuChoice2 & 0x7F)]
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
;=@c1
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld hl, wBagItems
	add l
	ld l, a
;=@c1
	ld a, $00
	adc h
	ld h, a
;> CopySystemText(0x0800 | item, wTextArg1)
	ld l, [hl]
	ld h, $08
	ld de, wTextArg1
	call CopySystemText
;> PrintSystemText(0x0201)
	ld hl, $0201
	call PrintSystemText
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawWindow(0x2E07)                 # the message window
	ld de, $2e07
	call DrawWindow
;> DrawWindow(DiscardYesNoWindow)
	ld de, DiscardYesNoWindow
	call DrawWindow
;> MenuResetBlink()
	call MenuResetBlink
;> MenuDrawCursorAt(wLinkRefused, DiscardCursorPos)     # yes/no cursor
	ld de, DiscardCursorPos
	ld a, [wLinkRefused]
	call MenuDrawCursorAt
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def ItemDiscardInput()
;@ path: menu/items
;@ Item step 15, yes/no to throwing the item away: B or "no" goes back to the
;@ "use / discard" window (step 3); "yes" prints the "threw it away" message (2/$02,
;@ with the player's name) and goes on.
;@ test: skip prints text through another bank
ItemDiscardInput::
;> MoveMenuCursor(wLinkRefused, 2, DiscardCursorPos)
	ld de, DiscardCursorPos
	ld hl, wLinkRefused
	ld b, $02
	call MoveMenuCursor
;> if wJoyPressed & 0x02:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

.back
;>@back     wFieldMenuStep -= 12
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;=@back
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;=@back
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;=@back
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;=@back
	jr .done

.notB
;> elif wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wLinkRefused == 0x81:        # "no": same as B
;>         wFieldMenuStep -= 12
	ld a, [wLinkRefused]
	cp $81
	jr z, .back

;>     else:
;>         wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
;>         CopyName(wPlayerName, wTextArg0)
	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
;>         PrintSystemText(0x0202)
	ld hl, $0202
	call PrintSystemText

.done
	ret


;@ path: menu/items
;@ Cursor offsets of the discard yes/no window; $FFFF ends the list.
DiscardCursorPos::
	dw $0121, $0161
	dw $ffff

;@ def ItemDiscard()
;@ path: menu/items
;@ Item step 16: once the message is done, empties the item's bag slot, closes the
;@ gap (CompactBag) and returns to the main menu.
;@ test: skip calls a routine in another bank
ItemDiscard::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;>@c2 wBagItems[5 * wConfirmChoice + (wMenuChoice2 & 0x7F)] = 0xFF
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
;=@c2
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld hl, wBagItems
	add l
	ld l, a
;=@c2
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
;> CompactBag()
	ld hl, far_CompactBag
	rst $10
;> MenuClearBuffer()
	call MenuClearBuffer
;> wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a
	ret


;@ def SkillMenu()
;@ path: menu/skills
;@ The skill option of the field menu: choose a party monster, then one of its
;@ skills (two pages of four) and, for healing skills, the monster to heal;
;@ wFieldMenuStep is the step.
;@ test: skip jumps through a table
SkillMenu::
;> SkillMenuSteps[wFieldMenuStep]()
	ld a, [wFieldMenuStep]
	rst $00

;@ path: menu/skills
;@ Steps of the skill option (SkillMenu).
SkillMenuSteps::
	dw SkillMenuOpen
	dw SkillMenuDraw
	dw SkillMonInput
	dw SkillListShow
	dw SkillListInput
	dw SkillShowTargets
	dw SkillTargetInput
	dw SkillStartUse
	dw SkillApply
	dw SkillCloseAfterText
	dw SkillShowTextWindow
	dw SkillCloseAfterText2
	dw SkillHealAllReport0
	dw SkillHealAllReport1
	dw SkillHealAllReport2
	dw SkillHealAllApply

;@ def SkillMenuOpen()
;@ path: menu/skills
;@ Skill step 0: counts the skills of the monster under the cursor and draws their
;@ first page.
;@ test: skip draws text tiles in another bank
SkillMenuOpen::
;> wCurPartyMember = wMenuChoice2
	ld a, [wMenuChoice2]
	ld [wCurPartyMember], a
;> CountMonSkills()
	call CountMonSkills
;> DrawSkillListPage()
	call DrawSkillListPage
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def SkillMenuDraw()
;@ path: menu/skills
;@ Skill step 1: draws the main menu, gold, the party list and the skill list.
;@ test: skip draws into VRAM
SkillMenuDraw::
;> MenuClearBuffer()
	call MenuClearBuffer
;> DrawWindow(MainMenuWindow)
	ld de, MainMenuWindow
	call DrawWindow
;> DrawWindow(GoldWindow)
	ld de, GoldWindow
	call DrawWindow
;> hNumber[0:3] = wGold[0:3]
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(BufferAddress(0x002E))
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
;> DrawWindow(SkillListWindow)
	ld de, SkillListWindow
	call DrawWindow
;> DrawWindow(SkillMonListWindow)
	ld de, SkillMonListWindow
	call DrawWindow
;> MenuResetBlink()
	call MenuResetBlink
;> MenuDrawCursorAt(wMenuChoice2, SkillMonCursorPos)
	ld de, SkillMonCursorPos
	ld a, [wMenuChoice2]
	call MenuDrawCursorAt
;> MenuShowBuffer()
	call MenuShowBuffer
;> DrawSkillListPage()
	call DrawSkillListPage
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def SkillMonInput()
;@ path: menu/skills
;@ Skill step 2, choosing the monster: Up/Down shows another monster's skills, B
;@ leaves to the main menu, A (when it has skills) goes on - a fainted monster
;@ only gets message $0E0B.
;@ test: skip draws into VRAM
SkillMonInput::
;> old = wMenuChoice2
	ld de, SkillMonCursorPos
	ld hl, wMenuChoice2
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
	push af
;> MoveMenuCursor(wMenuChoice2, wPartyCount, SkillMonCursorPos)
	call MoveMenuCursor
;>@c3 if (wMenuChoice2 & 0x7F) != (old & 0x7F):
	pop af
	ld hl, wMenuChoice2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@c3
	cp b
	jr z, .buttons

;>     wCurPartyMember = wMenuChoice2
	ld a, [wMenuChoice2]
	ld [wCurPartyMember], a
;>     CountMonSkills()
	call CountMonSkills
;>     DrawSkillListPage()
	call DrawSkillListPage

.buttons
;> if wJoyPressed & 0x02:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     MenuClearBuffer()
	call MenuClearBuffer
;>     wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a
	jr .done

.notB
;> elif wMenuCount and wJoyPressed & 0x01:
	ld a, [wMenuCount]
	or a
	jr z, .done

	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     if PartyMonsterField(wMenuChoice2, wMonStatus)[0] & 0x80:     # fainted
	ld hl, wMonStatus
	ld a, [wMenuChoice2]
	call PartyMonsterField
	bit 7, [hl]
	jr nz, .dead
;>@dead1         PrintSystemText(0x0E0B)
;>@dead1         wFieldMenuStep = 0x0A
;>@dead2         return

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wConfirmChoice = 0
	xor a
	ld [wConfirmChoice], a
;>     wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]

.done
	ret


.dead
;=@dead1
	ld hl, $0e0b
	call PrintSystemText
	ld a, $0a
	ld [wFieldMenuStep], a
;=@dead2
	ret


;@ path: menu/skills
;@ Cursor offsets of the skill menu's party list; $FFFF ends the list.
SkillMonCursorPos::
	dw $00a1, $00e1, $0121
	dw $ffff

;@ def DrawSkillListPage()
;@ path: menu/skills
;@ Draws the current page of the monster's skill names, or - for a monster without
;@ skills - the word for "nothing" (text 2/$0D) and seven blank slots.
;@ test: skip draws into VRAM
DrawSkillListPage::
;> if wMenuCount:
;>     return DrawSkillPage()
	ld a, [wMenuCount]
	or a
	jr nz, DrawSkillPage

;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x0D
	ld a, $0d
	ld [wTextIndex], a
;> MenuDrawTextTiles(0x8800, width=1, height=9)
	ld hl, $8800
	ld de, $0901
	call MenuDrawTextTiles
;>@b tiles = 0x8890
;>@b for i in range(7):
	ld hl, $8890
;>     tiles = ClearTextTiles(0x48, tiles)
	ld b, $48
	call ClearTextTiles
;=@b
	ld b, $48
	call ClearTextTiles
	ld b, $48
	call ClearTextTiles
	ld b, $48
	call ClearTextTiles
;=@b
	ld b, $48
	call ClearTextTiles
	ld b, $48
	call ClearTextTiles
	ld b, $48

;@ def ClearTextTiles(count: b, dest: hl) -> hl
;@ path: menu/skills
;@ Blanks `count` rows of tile data (2 bytes each, $FF $00 = light background) at
;@ `dest` in VRAM; returns the address after them.
;@ test: skip writes VRAM
ClearTextTiles::
;> for i in range(count):
;>     dest = WriteVRAMInc(0xFF, dest)
	ld a, $ff
	call WriteVRAMInc
;>     dest = WriteVRAMInc(0x00, dest)
	xor a
	call WriteVRAMInc
	dec b
	jr nz, ClearTextTiles

;> return dest
	ret


;@ def DrawSkillPage()
;@ path: menu/skills
;@ Draws the four skill names of the current page (wConfirmChoice2: 0 skills 1-4, 1
;@ skills 5-8) of the viewed monster into the tiles from $8800 on.
;@ test: skip draws text tiles in another bank
DrawSkillPage::
;>@c1 field = wMonSkills + 4 if wConfirmChoice2 else wMonSkills
	ld a, [wConfirmChoice2]
	cp $00
	jr z, .first

	ld hl, wMonSkills + 4
	jr .draw

.first
;=@c1
	ld hl, wMonSkills

.draw
;> skills = GetViewedMonsterField(field)
	call GetViewedMonsterField
	ld e, l
	ld d, h
;> tiles = 0x8800
	ld hl, $8800
;> for i in range(4):
;>     skills, tiles = DrawSkillName(skills, tiles)
	call DrawSkillName
	call DrawSkillName
	call DrawSkillName
	call DrawSkillName
	ret


;@ def SkillListShow()
;@ path: menu/skills
;@ Skill step 3: the skill list with the description and MP cost of the skill under
;@ the cursor, the monster's MP and the page marks.
;@ test: skip draws into VRAM
SkillListShow::
;> DrawSkillDescription()
	call DrawSkillDescription
;> DrawWindow(SkillInfoWindow)
	ld de, SkillInfoWindow
	call DrawWindow
;> DrawWindow(SkillMPWindow)
	ld de, SkillMPWindow
	call DrawWindow
;> DrawSkillMPCost()
	call DrawSkillMPCost
;> PrintNumber3(GetPartyMonsterWord(wMenuChoice2, wMonMP), BufferAddress(0x0125))
	ld hl, wMonMP
	ld a, [wMenuChoice2]
	call GetPartyMonsterWord
	ld hl, $0125
	call BufferAddress
	call PrintNumber3
;> MenuResetBlink()
	call MenuResetBlink
;>@c2 DrawListMarks(wConfirmChoice, SkillListCursorPos, 4, wMenuCount)
	ld de, SkillListCursorPos
	ld a, [wConfirmChoice]
	ld b, $04
	ld hl, wConfirmChoice
	ld a, [wMenuCount]
	ld c, a
;=@c2
	call DrawListMarks
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def DrawSkillDescription()
;@ path: menu/skills
;@ Draws the description (text group 1, three lines of 18) of the skill under the
;@ cursor (an empty slot as entry $0F) into the tiles at $94A0, through the text
;@ renderer of bank $56; the text box settings are kept.
;@ test: skip draws text tiles in another bank
DrawSkillDescription::
;>@c3 field = wMonSkills + 4 if wConfirmChoice2 else wMonSkills
	ld a, [wConfirmChoice2]
	cp $00
	jr z, .first

	ld hl, wMonSkills + 4
	jr .pick

.first
;=@c3
	ld hl, wMonSkills

.pick
;>@c4 skill = PartyMonsterField(wMenuChoice2, field)[wConfirmChoice & 0x7F]
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld a, [wConfirmChoice]
	and $7f
	add l
	ld l, a
;=@c4
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>@c5 wTextIndex = skill if skill != 0xFF else 0x0F
	cp $ff
	jr nz, .text

	ld a, $0f

.text
;=@c5
	ld [wTextIndex], a
;> wTextGroup = 1
	ld a, $01
	ld [wTextGroup], a
;>@c6 saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)
	ld hl, $94a0
	ld de, $1203
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
;=@c6
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = 0x94A0
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 3
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 0x12
	ld a, d
	ld [wTextBoxLineLength], a
;> RenderSkillText()
	ld hl, far_Call_56_490F
	rst $10
;>@c7 restore(saved)                  # wTextTiles, wTextBoxLines, wTextBoxLineLength as they were
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;=@c7
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def CountMonSkills()
;@ path: menu/skills
;@ Counts the skills of party monster wMenuChoice2 (up to the first $FF, at most 8)
;@ into wMenuCount.
;@ test: skip reads monster records through the party helpers
CountMonSkills::
;> skills = PartyMonsterField(wMenuChoice2, wMonSkills)
	ld hl, wMonSkills
	ld a, [wMenuChoice2]
	call PartyMonsterField
;> n = 0
;> while n < 8 and skills[n] != 0xFF:
	ld b, $08
	ld c, $00
.loop
	ld a, [hli]
	cp $ff
	jr z, .done

;>     n += 1
	inc c
	dec b
	jr nz, .loop

.done
;> wMenuCount = n
	ld a, c
	ld [wMenuCount], a
	ret


;@ def DrawSkillMPCost()
;@ path: menu/skills
;@ Prints the MP cost of the skill under the cursor at buffer offset $0121; a cost
;@ of 999 (the skill uses up all MP) shows the monster's current MP instead.
;@ test: skip reads monster records through the party helpers
DrawSkillMPCost::
;>@c8 field = wMonSkills + 4 if wConfirmChoice2 else wMonSkills
	ld a, [wConfirmChoice2]
	cp $00
	jr z, .first

	ld hl, wMonSkills + 4
	jr .pick

.first
;=@c8
	ld hl, wMonSkills

.pick
;>@c9 skill = PartyMonsterField(wMenuChoice2, field)[wConfirmChoice & 0x7F]
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld a, [wConfirmChoice]
	and $7f
	add l
	ld l, a
;=@c9
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	ld d, $00
;> cost = GetSkillMPCost(skill)
	call GetSkillMPCost
	ld c, e
	ld b, d
;>@c10 if cost != 999:
	ld a, e
	add $19
	ld e, a
	ld a, d
	adc $fc
	ld d, a
;=@c10
	ld a, d
	or e
	jr z, .allMP

;>     PrintNumber3(cost, BufferAddress(0x0121))
	ld hl, $0121
	call BufferAddress
	call PrintNumber3
	ret


.allMP
;> else:
;>@c19     PrintNumber3(GetPartyMonsterWord(wMenuChoice2, wMonMP), BufferAddress(0x0121))
	ld hl, wMonMP
	ld a, [wMenuChoice2]
	call GetPartyMonsterWord
	ld hl, $0121
	call BufferAddress
	call PrintNumber3
;=@c19
	ret


;@ def SkillListInput()
;@ path: menu/skills
;@ Skill step 4: Up/Down moves in the list, Left/Right turns the page (description
;@ and cost follow); B goes back to the party list; A takes the skill if it can be
;@ used on the field (skills $2B-$31, $33, $36-$38, $7E), else prints message $0E0A.
;@ test: skip draws into VRAM
SkillListInput::
;> old_cursor = wConfirmChoice
;>@c11 old_page = wConfirmChoice2
	ld de, SkillListCursorPos
	ld hl, wConfirmChoice
	ld a, [wMenuCount]
	ld c, a
	ld b, $04
	inc hl
;=@c11
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> MoveListCursor(wConfirmChoice, SkillListCursorPos, 4, wMenuCount)
	call MoveListCursor
;>@c12 if (wConfirmChoice & 0x7F) != (old_cursor & 0x7F):
	pop af
	ld hl, wConfirmChoice
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@c12
	cp b
	jr z, .samePlace

;>     DrawSkillMPCost()
	call DrawSkillMPCost
;>     MenuShowBuffer()
	call MenuShowBuffer
;>     DrawSkillDescription()
	call DrawSkillDescription

.samePlace
;> if wConfirmChoice2 != old_page:
	pop af
	ld hl, wConfirmChoice2
	cp [hl]
	jr z, .buttons

;>     DrawSkillPage()
	call DrawSkillPage
;>     DrawSkillMPCost()
	call DrawSkillMPCost
;>     MenuShowBuffer()
	call MenuShowBuffer
;>     DrawSkillDescription()
	call DrawSkillDescription

.buttons
;> if wJoyPressed & 0x02:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     wFieldMenuStep -= 3
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;>     wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice2], a
	jp .done


.notB
;> elif wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
;>@c13     wItemId = PartyMonsterField(wMenuChoice2, wMonSkills)[4 * (wConfirmChoice2 & 0x7F) + (wConfirmChoice & 0x7F)]
	ld hl, wMonSkills
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld a, [wConfirmChoice2]
	and $7f
	add a
;=@c13
	add a
	ld b, a
	ld a, [wConfirmChoice]
	and $7f
	add b
	add l
;=@c13
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
;>@c14     if wItemId not in (0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x33, 0x36, 0x37, 0x38, 0x7E):
	cp $2b
	jr z, .done

	cp $2c
	jr z, .done

	cp $2d
	jr z, .done

;=@c14
	cp $2e
	jr z, .done

	cp $2f
	jr z, .done

	cp $30
	jr z, .done

;=@c14
	cp $31
	jr z, .done

	cp $33
	jr z, .done

	cp $36
	jr z, .done

;=@c14
	cp $37
	jr z, .done

	cp $38
	jr z, .done

	cp $7e
	jr z, .done

;>         PrintSystemText(0x0E0A)       # can't use that here
	ld hl, $0e0a
	call PrintSystemText
;>         wFieldMenuStep = 0x0A
	ld a, $0a
	ld [wFieldMenuStep], a
	ret


.done
	ret


;@ path: menu/skills
;@ Skill list marks: the buffer offset of the page number, then the cursor offsets of
;@ the four rows; $FFFF ends the list.
SkillListCursorPos::
	dw $0151
	dw $0069, $00a9, $00e9, $0129
	dw $ffff

;@ def UnusedDrawSkillPageMark()
;@ path: unused
;@ Never called: writes the page number (tile $F1 + page) and the arrow tile $E7 at
;@ offsets $0150/$0151 straight into the BG map and into the tilemap buffer.
;@ test: skip writes VRAM
UnusedDrawSkillPageMark::
;> tile = 0xF1 + (wConfirmChoice2 & 1)
;> WriteVRAM(tile, MenuMapAddress(0x0150))
	ld hl, $0150
	call MenuMapAddress
	ld a, [wConfirmChoice2]
	and $01
	add $f1
	call WriteVRAM
;>@c15 mem[BufferAddress(0x0150)] = tile
	push af
	ld hl, $0150
	ld a, l
	add $00
	ld l, a
	ld a, h
;=@c15
	adc $c5
	ld h, a
	pop af
	ld [hl], a
;> WriteVRAM(0xE7, MenuMapAddress(0x0151))
	ld hl, $0151
	call MenuMapAddress
	ld a, $e7
	call WriteVRAM
;>@c16 mem[BufferAddress(0x0151)] = 0xE7
	push af
	ld hl, $0151
	ld a, l
	add $00
	ld l, a
	ld a, h
;=@c16
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	ret

;@ def GetSkillMPCost(skill: e) -> de
;@ path: menu/skills
;@ Returns the MP cost of skill `skill` from SkillMPCosts. Skill $70 costs like
;@ skill $72 when the viewed monster's sex bit is 0. (Far entry 3 of bank 7.)
;@ test: skip reads monster records through the party helpers
GetSkillMPCost::
;>@c17 if skill == 0x70 and not GetViewedMonsterByte(wMonGender) & 0x01:
	ld a, e
	cp $70
	jr nz, .look

	ld hl, wMonGender
	call GetViewedMonsterByte
	and $01
;=@c17
	cp $00
	jr nz, .look

;>     skill += 2
	ld a, e
	inc a
	inc a
	ld e, a

.look
;>@c18 return SkillMPCosts[skill]
	ld l, e
	ld h, d
	add hl, hl
	ld a, l
	add LOW(SkillMPCosts)
	ld l, a
;=@c18
	ld a, h
	adc HIGH(SkillMPCosts)
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
;=@c18
	ret


;@ path: menu/skills
;@ MP cost of every skill, one u16 per skill number (GetSkillMPCost); 999 ($03E7)
;@ means the skill uses up all of the user's MP.
SkillMPCosts::
	dw $0002, $0004, $000a, $0004, $0006, $000a, $0005, $0008    ; $00
	dw $000f, $0002, $0004, $0008, $0003, $0005, $000c, $0005    ; $08
	dw $000a, $000f, $0004, $0007, $0001, $0003, $0005, $0003    ; $10
	dw $0003, $0005, $0000, $0002, $0003, $0004, $0002, $0003    ; $18
	dw $0003, $0004, $0002, $0003, $0003, $0006, $0003, $0004    ; $20
	dw $0004, $0005, $0002, $0002, $0005, $0007, $0012, $0024    ; $28
	dw $000a, $0014, $03e7, $0002, $0002, $0002, $0002, $0002    ; $30
	dw $0002, $0014, $0000, $0002, $0001, $0001, $0001, $0003    ; $38
	dw $0003, $0000, $0005, $0000, $0003, $0003, $0003, $0003    ; $40
	dw $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0014    ; $48
	dw $0003, $0006, $0004, $0008, $0000, $0002, $0003, $0005    ; $50
	dw $0003, $0006, $0003, $0005, $0002, $0004, $0008, $0010    ; $58
	dw $0002, $0004, $0008, $0010, $0019, $001e, $03e7, $0002    ; $60
	dw $0002, $0003, $0003, $0004, $0003, $0004, $0004, $0003    ; $68
	dw $0001, $0006, $0002, $0002, $0002, $0000, $0000, $0001    ; $70
	dw $0002, $0002, $0004, $0001, $0003, $0003, $0000, $0004    ; $78
	dw $0007, $0007, $0007, $0008, $0014, $0014, $0014, $0014    ; $80
	dw $0002, $0004, $0006, $000a, $0004, $0000, $0003, $0002    ; $88
	dw $0003, $0006, $0006, $0008, $000c, $0014, $0001, $0000    ; $90
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; $98
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; $A0
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; $A8
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; $B0
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; $B8
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; $C0
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; $C8
	dw $0000, $0000, $0000, $0000, $0000, $0009, $0003, $0003    ; $D0
	dw $0003, $0014, $0005, $0000, $0002, $0002, $0000, $0000    ; $D8

;@ def SkillShowTargets()
;@ path: menu/skills
;@ Skill step 5: the healing skills for one monster ($2B-$2D, $30, $31, $33, $36)
;@ show the party list with the HP of the monster under the cursor; the others
;@ skip to step 7.
;@ test: skip draws into VRAM
SkillShowTargets::
;>@c1 if wItemId not in (0x2B, 0x2C, 0x2D, 0x30, 0x31, 0x33, 0x36):
	ld a, [wItemId]
	cp $2b
	jr z, .target

	cp $2c
	jr z, .target

;=@c1
	cp $2d
	jr z, .target

	cp $30
	jr z, .target

	cp $31
	jr z, .target

;=@c1
	cp $33
	jr z, .target

	cp $36
	jr z, .target

;>     wFieldMenuStep += 2
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
;>     return
	ret


.target
;> DrawWindow(SkillListWindow)
	ld de, SkillListWindow
	call DrawWindow
;> DrawWindow(SkillTargetListWindow)
	ld de, SkillTargetListWindow
	call DrawWindow
;> DrawWindow(TargetHPWindow)
	ld de, TargetHPWindow
	call DrawWindow
;> DrawSkillTargetHP()
	call DrawSkillTargetHP
;> MenuResetBlink()
	call MenuResetBlink
;> MenuDrawCursorAt(wConfirmChoice2, SkillMonCursorPos)
	ld de, SkillMonCursorPos
	ld a, [wConfirmChoice2]
	call MenuDrawCursorAt
;>@c2 DrawListMarks(wConfirmChoice, SkillListCursorPos, 4, wMenuCount)
	ld de, SkillListCursorPos
	ld a, [wConfirmChoice]
	ld b, $04
	ld hl, wConfirmChoice
	ld a, [wMenuCount]
	ld c, a
;=@c2
	call DrawListMarks
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def UnusedDrawTargetHP()
;@ path: unused
;@ Never called: DrawSkillTargetHP for the monster in wConfirmChoice2.
;@ test: skip writes the tilemap buffer through BufferAddress
UnusedDrawTargetHP::
;> PrintNumber3(GetPartyMonsterWord(wConfirmChoice2, wMonHP), BufferAddress(0x0201))
	ld hl, wMonHP
	ld a, [wConfirmChoice2]
	call GetPartyMonsterWord
	ld hl, $0201
	call BufferAddress
	call PrintNumber3
;> PrintNumber3(GetPartyMonsterWord(wConfirmChoice2, wMonMaxHP), BufferAddress(0x0205))
	ld hl, wMonMaxHP
	ld a, [wConfirmChoice2]
	call GetPartyMonsterWord
	ld hl, $0205
	call BufferAddress
	call PrintNumber3
;> status = GetPartyMonsterByte(wConfirmChoice2, wMonStatus)
	ld hl, wMonStatus
	ld a, [wConfirmChoice2]
	call GetPartyMonsterByte
	ld b, a
;> p = BufferAddress(0x01C5)
	ld hl, $01c5
	call BufferAddress
;>@c3 mem[p] = 0xD7 if status & 0x01 else 0xE0
	bit 0, b
	ld a, $e0
	jr z, .mark1

	ld a, $d7

.mark1
;=@c3
	ld [hli], a
;>@c4 mem[p + 1] = 0xD8 if status & 0x04 else 0xE0
	bit 2, b
	ld a, $e0
	jr z, .mark2

	ld a, $d8

.mark2
;=@c4
	ld [hli], a
;>@c5 mem[p + 2] = 0xD9 if status & 0x80 else 0xE0
	bit 7, b
	ld a, $e0
	jr z, .mark3

	ld a, $d9

.mark3
;=@c5
	ld [hl], a
	ret

;@ def SkillTargetInput()
;@ path: menu/skills
;@ Skill step 6, choosing the monster to heal: Up/Down moves (the HP window
;@ follows), B goes back to the skill list, A takes the monster (wItemTarget, its
;@ name into wTextArg1).
;@ test: skip draws into VRAM
SkillTargetInput::
;> old = wMenuChoice3
	ld de, SkillMonCursorPos
	ld hl, wMenuChoice3
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
	push af
;> MoveMenuCursor(wMenuChoice3, wPartyCount, SkillMonCursorPos)
	call MoveMenuCursor
;>@c6 if (wMenuChoice3 & 0x7F) != (old & 0x7F):
	pop af
	and $7f
	ld b, a
	ld hl, wMenuChoice3
	ld a, [hl]
	and $7f
;=@c6
	cp b
	jr z, .buttons

;>     DrawSkillTargetHP()
	call DrawSkillTargetHP
;>     MenuShowBuffer()
	call MenuShowBuffer

.buttons
;> if wJoyPressed & 0x02:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>@c27     wFieldMenuStep -= 3
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;=@c27
	jr .done

.notB
;> elif wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     wItemTarget = wMenuChoice3 & 0x7F
	ld a, [wMenuChoice3]
	and $7f
	ld [wItemTarget], a
;>     CopyName(PartyMonsterField(wItemTarget, wMonName), wTextArg1)
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]

.done
	ret


;@ def DrawSkillTargetHP()
;@ path: menu/skills
;@ HP, max HP and ailment marks of the monster under the target cursor
;@ (wMenuChoice3).
;@ test: skip writes the tilemap buffer through BufferAddress
DrawSkillTargetHP::
;> PrintNumber3(GetPartyMonsterWord(wMenuChoice3, wMonHP), BufferAddress(0x0201))
	ld hl, wMonHP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0201
	call BufferAddress
	call PrintNumber3
;> PrintNumber3(GetPartyMonsterWord(wMenuChoice3, wMonMaxHP), BufferAddress(0x0205))
	ld hl, wMonMaxHP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0205
	call BufferAddress
	call PrintNumber3
;> status = GetPartyMonsterByte(wMenuChoice3, wMonStatus)
	ld hl, wMonStatus
	ld a, [wMenuChoice3]
	call GetPartyMonsterByte
	ld b, a
;> p = BufferAddress(0x01C5)
	ld hl, $01c5
	call BufferAddress
;>@c7 mem[p] = 0xD7 if status & 0x01 else 0xE0
	bit 0, b
	ld a, $e0
	jr z, .mark1

	ld a, $d7

.mark1
;=@c7
	ld [hli], a
;>@c8 mem[p + 1] = 0xD8 if status & 0x04 else 0xE0
	bit 2, b
	ld a, $e0
	jr z, .mark2

	ld a, $d8

.mark2
;=@c8
	ld [hli], a
;>@c9 mem[p + 2] = 0xD9 if status & 0x80 else 0xE0
	bit 7, b
	ld a, $e0
	jr z, .mark3

	ld a, $d9

.mark3
;=@c9
	ld [hl], a
	ret


;@ def SkillStartUse()
;@ path: menu/skills
;@ Skill step 7: the user's name and the skill's name (text group 6) into the
;@ message arguments, then message $0E00 ("X used Y") - $0E09 for skill $7E - in
;@ the message window, with sound $65.
;@ test: skip prints text through another bank
SkillStartUse::
;>@c10 CopyName(PartyMonsterField(wMenuChoice2, wMonName), wTextArg0)
	ld hl, wMonName
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
;=@c10
	call CopyName
;> CopySystemText(0x0600 | wItemId, wTextArg2)
	ld a, [wItemId]
	ld l, a
	ld h, $06
	ld de, wTextArg2
	call CopySystemText
;>@c11 PrintSystemText(0x0E09 if wItemId == 0x7E else 0x0E00)
	ld hl, $0e00
	ld a, [wItemId]
	cp $7e
	jr nz, .print

	ld hl, $0e09

.print
;=@c11
	call PrintSystemText
;> DrawWindow(0x2E07)                 # the message window
	ld de, $2e07
	call DrawWindow
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
;> QueueSound(0x65)
	ld a, $65
	call QueueSound
	ret


;@ def SkillApply()
;@ path: menu/skills
;@ Skill step 8, after the message: checks the MP (message $0E02 if too few), lets
;@ the battle code check the skill (wItemId $FF afterwards = no effect: message
;@ $0E01, $0E08 for skill $38), then: the party heals $2E/$2F report per monster
;@ (step 12 on); $37, $38 and $7E just take effect; the others print their
;@ result ($0E07 for $36, $0E06 for $33, $0E04 for $30/$31, else $0E03) and take
;@ effect (PaySkillMP).
;@ test: skip calls routines in another bank
SkillApply::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;>@c12 field = wMonSkills + 4 if wConfirmChoice2 else wMonSkills
	ld a, [wConfirmChoice2]
	cp $00
	jr z, .first

	ld hl, wMonSkills + 4
	jr .pick

.first
;=@c12
	ld hl, wMonSkills

.pick
;>@c13 skill = PartyMonsterField(wMenuChoice2, field)[wConfirmChoice & 0x7F]
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld a, [wConfirmChoice]
	and $7f
	add l
	ld l, a
;=@c13
	ld a, $00
	adc h
	ld h, a
;>@c14 cost = SkillMPCosts[skill]
	ld l, [hl]
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(SkillMPCosts)
	ld l, a
;=@c14
	ld a, h
	adc HIGH(SkillMPCosts)
	ld h, a
	ld c, [hl]
	inc hl
	ld b, [hl]
;>@c15 if GetPartyMonsterWord(wMenuChoice2, wMonMP) < cost:
	push bc
	ld hl, wMonMP
	ld a, [wMenuChoice2]
	call PartyMonsterField
	pop bc
	ld a, [hli]
;=@c15
	sub c
	ld a, [hl]
	sbc b
;>     msg = 0x0E02                    # not enough MP
	ld hl, $0e02
	jp c, .say

;> else:
;>     skill = wItemId
	ld a, [wItemId]
	push af
;>     CheckFieldItemUse()                 # leaves $FF in wItemId when it would do nothing
	ld hl, far_CheckFieldItemUse
	rst $10
;>     if wItemId == 0xFF:
	pop bc
	ld a, [wItemId]
	cp $ff
	ld a, b
	jr z, .failed

;>@f1         msg = 0x0E08 if skill == 0x38 else 0x0E01
;>     elif wItemId in (0x2E, 0x2F):    # party heal: one message per monster first
	ld a, [wItemId]
	cp $2e
	jr z, .healAll

	cp $2f
	jr z, .healAll

;>@ha         wFieldMenuStep = 0x0C
;>@ha         return
;>     else:
;>         if wItemId not in (0x37, 0x38, 0x7E):     # these have no result message
	cp $37
	jr z, .noText

	cp $38
	jr z, .noText

	cp $7e
	jr z, .noText

;>@c16             msg = 0x0E07 if wItemId == 0x36 else 0x0E06 if wItemId == 0x33 else 0x0E04 if wItemId in (0x30, 0x31) else 0x0E03
	ld hl, $0e07
	cp $36
	jr z, .result

	ld hl, $0e06
	cp $33
;=@c16
	jr z, .result

	ld hl, $0e04
	cp $30
	jr z, .result

	cp $31
;=@c16
	jr z, .result

	ld hl, $0e03

.result
;>             PrintSystemText(msg)
	call PrintSystemText

.noText
;>         wFieldMenuStep += 1
;>         PaySkillMP()
	ld hl, wFieldMenuStep
	inc [hl]
	call PaySkillMP
;>         return
	ret

.healAll
;=@ha
	ld a, $0c
	ld [wFieldMenuStep], a
	ret


.failed
;=@f1
	ld hl, $0e08
	cp $38
	jr z, .say

	ld hl, $0e01

.say
;> PrintSystemText(msg)
	call PrintSystemText
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def PaySkillMP()
;@ path: menu/skills
;@ Lets the skill take effect (bank $14), refreshes the party sprites and status
;@ bar, then takes the skill's MP cost from the user (party place wMenuChoice2).
;@ test: skip calls routines in another bank
PaySkillMP::
;> UseFieldItem()
	ld hl, far_UseFieldItem
	rst $10
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;> BuildStatusBar()
	call BuildStatusBar
;>@c17 field = wMonSkills + 4 if wConfirmChoice2 else wMonSkills
	ld a, [wConfirmChoice2]
	cp $00
	jr z, .first

	ld hl, wMonSkills + 4
	jr .pick

.first
;=@c17
	ld hl, wMonSkills

.pick
;>@c18 skill = PartyMonsterField(wMenuChoice2, field)[wConfirmChoice & 0x7F]
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld a, [wConfirmChoice]
	and $7f
	add l
	ld l, a
;=@c18
	ld a, $00
	adc h
	ld h, a
;>@c19 cost = SkillMPCosts[skill]
	ld l, [hl]
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(SkillMPCosts)
	ld l, a
;=@c19
	ld a, h
	adc HIGH(SkillMPCosts)
	ld h, a
	ld c, [hl]
	inc hl
	ld b, [hl]
;>@c20 mem16[PartyMonsterField(wMenuChoice2, wMonMP)] -= cost
	push bc
	ld hl, wMonMP
	ld a, [wMenuChoice2]
	call PartyMonsterField
	pop bc
	ld a, [hl]
;=@c20
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
	ret


;@ def SkillCloseAfterText()
;@ path: menu/skills
;@ Skill step 9: once the message is done, back to the main menu.
;@ test: skip draws into VRAM
SkillCloseAfterText::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> MenuClearBuffer()
	call MenuClearBuffer
;> wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a
	ret


;@ def SkillShowTextWindow()
;@ path: menu/skills
;@ Skill step 10: shows the message window (after "can't use that here" or a
;@ fainted user) and goes on.
;@ test: skip draws into VRAM
SkillShowTextWindow::
;> DrawWindow(0x2E07)
	ld de, $2e07
	call DrawWindow
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def SkillCloseAfterText2()
;@ path: menu/skills
;@ Skill step 11: once the message is done, back to the main menu.
;@ test: skip draws into VRAM
SkillCloseAfterText2::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> MenuClearBuffer()
	call MenuClearBuffer
;> wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a
	ret


;@ def SkillHealAllReport0()
;@ path: menu/skills
;@ Skill step 12, party heal: if the first party monster is standing and not at full
;@ HP, prints message $0E03 with its name (it is about to be healed).
;@ test: skip prints text through another bank
SkillHealAllReport0::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;>@c21 if not PartyMonsterField(0, wMonStatus)[0] & 0x80 and GetPartyMonsterWord(0, wMonMaxHP) != GetPartyMonsterWord(0, wMonHP):
	ld hl, wMonStatus
	ld a, $00
	call PartyMonsterField
	bit 7, [hl]
	jr nz, .next

;=@c21
	ld a, $00
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
	ld a, $00
	ld hl, wMonHP
;=@c21
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
;=@c21
	sbc b
	ld h, a
	ld a, h
	or l
	jr z, .next

;>@c22     CopyName(PartyMonsterField(0, wMonName), wTextArg1)
	ld hl, wMonName
	ld a, $00
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
;=@c22
	call CopyName
;>     PrintSystemText(0x0E03)
	ld hl, $0e03
	call PrintSystemText
;>     DrawWindow(0x2E07)
	ld de, $2e07
	call DrawWindow
;>     MenuShowBuffer()
	call MenuShowBuffer

.next
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def SkillHealAllReport1()
;@ path: menu/skills
;@ Skill step 13: SkillHealAllReport0 for the second party place (if filled).
;@ test: skip prints text through another bank
SkillHealAllReport1::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;>@c23 if wParty[1] != 0xFF and not PartyMonsterField(1, wMonStatus)[0] & 0x80 and GetPartyMonsterWord(1, wMonMaxHP) != GetPartyMonsterWord(1, wMonHP):
	ld a, [wParty + 1]
	cp $ff
	jr z, .next

	ld hl, wMonStatus
	ld a, $01
	call PartyMonsterField
;=@c23
	bit 7, [hl]
	jr nz, .next

	ld a, $01
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
;=@c23
	ld a, $01
	ld hl, wMonHP
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
;=@c23
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
	or l
;=@c23
	jr z, .next

;>@c24     CopyName(PartyMonsterField(1, wMonName), wTextArg1)
	ld hl, wMonName
	ld a, $01
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
;=@c24
	call CopyName
;>     PrintSystemText(0x0E03)
	ld hl, $0e03
	call PrintSystemText

.next
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def SkillHealAllReport2()
;@ path: menu/skills
;@ Skill step 14: SkillHealAllReport0 for the third party place (if filled).
;@ test: skip prints text through another bank
SkillHealAllReport2::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;>@c25 if wParty[2] != 0xFF and not PartyMonsterField(2, wMonStatus)[0] & 0x80 and GetPartyMonsterWord(2, wMonMaxHP) != GetPartyMonsterWord(2, wMonHP):
	ld a, [wParty + 2]
	cp $ff
	jr z, .next

	ld hl, wMonStatus
	ld a, $02
	call PartyMonsterField
;=@c25
	bit 7, [hl]
	jr nz, .next

	ld a, $02
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
;=@c25
	ld a, $02
	ld hl, wMonHP
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
;=@c25
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
	or l
;=@c25
	jr z, .next

;>@c26     CopyName(PartyMonsterField(2, wMonName), wTextArg1)
	ld hl, wMonName
	ld a, $02
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
;=@c26
	call CopyName
;>     PrintSystemText(0x0E03)
	ld hl, $0e03
	call PrintSystemText

.next
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def SkillHealAllApply()
;@ path: menu/skills
;@ Skill step 15: once the messages are done, the party heal takes effect
;@ (PaySkillMP) and the menu returns to the main menu.
;@ test: skip calls routines in another bank
SkillHealAllApply::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> PaySkillMP()
	call PaySkillMP
;> MenuClearBuffer()
	call MenuClearBuffer
;> wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a
	ret


;@ def OptionMenu()
;@ path: menu/options
;@ The fourth field menu option: message speed, line-up, tactics and saving;
;@ wFieldMenuStep is the step.
;@ test: skip jumps through a table
OptionMenu::
;> OptionMenuSteps[wFieldMenuStep]()
	ld a, [wFieldMenuStep]
	rst $00

;@ path: menu/options
;@ Steps of the option menu (OptionMenu).
OptionMenuSteps::
	dw OptionMenuDraw
	dw OptionMenuInput
	dw MessageSpeedShow
	dw MessageSpeedInput
	dw LineUpShow
	dw LineUpInput
	dw SaveShow
	dw SaveInput
	dw SaveDone
	dw OptionCloseAfterText
	dw TacticsStart
	dw TacticsInput

;@ def OptionMenuDraw()
;@ path: menu/options
;@ Option step 0: reloads the font (graphics $2E/$0D to $9000) and draws the main
;@ menu, gold and the window of the four options.
;@ test: skip draws into VRAM
OptionMenuDraw::
;> DecompressVRAM(0x2E, 0x0D, 0x9000)
	ld de, $2e0d
	ld hl, $9000
	call DecompressVRAM
;> MenuClearBuffer()
	call MenuClearBuffer
;> DrawWindow(MainMenuWindow)
	ld de, MainMenuWindow
	call DrawWindow
;> DrawWindow(GoldWindow)
	ld de, GoldWindow
	call DrawWindow
;> hNumber[0:3] = wGold[0:3]
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(BufferAddress(0x002E))
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
;> DrawWindow(OptionWindow)
	ld de, OptionWindow
	call DrawWindow
;> MenuResetBlink()
	call MenuResetBlink
;> MenuDrawCursorAt(wMenuChoice2, OptionCursorPos)
	ld de, OptionCursorPos
	ld a, [wMenuChoice2]
	call MenuDrawCursorAt
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def OptionMenuInput()
;@ path: menu/options
;@ Option step 1: B leaves to the main menu; A opens message speed (step 2),
;@ line-up (step 4), tactics (step 10, from the first monster) or save (step 6).
;@ test: skip draws into VRAM
OptionMenuInput::
;> MoveMenuCursor(wMenuChoice2, 4, OptionCursorPos)
	ld de, OptionCursorPos
	ld hl, wMenuChoice2
	ld b, $04
	call MoveMenuCursor
;> if wJoyPressed & 0x02:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     MenuClearBuffer()
	call MenuClearBuffer
;>     wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a
	jr .done

.notB
;> elif wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice2 == 0x80:
;>         wFieldMenuStep = 2           # message speed
	ld b, $02
	ld a, [wMenuChoice2]
	cp $80
	jr z, .step

;>     elif wMenuChoice2 == 0x81:
;>         wFieldMenuStep = 4           # line-up
	ld b, $04
	cp $81
	jr z, .step

;>     elif wMenuChoice2 == 0x83:
;>         wFieldMenuStep = 6           # save
	ld b, $06
	cp $83
	jr z, .step

;>     else:
;>         wLinkPartnerChoice = 0       # tactics: start with the first monster
	xor a
	ld [wLinkPartnerChoice], a
;>@c1         wFieldMenuStep = 0x0A
	ld b, $0a

.step
;=@c1
	ld a, b
	ld [wFieldMenuStep], a

.done
	ret


;@ path: menu/options
;@ Cursor offsets of the four options (message speed, line-up, tactics, save);
;@ $FFFF ends the list.
OptionCursorPos::
	dw $0066, $00a6, $00e6, $0126
	dw $ffff

;@ def MessageSpeedShow()
;@ path: menu/options
;@ Option step 2: the message speed window (eight speeds in a row), the cursor on
;@ the current speed.
;@ test: skip draws into VRAM
MessageSpeedShow::
;> DrawWindow(MessageSpeedWindow)
	ld de, MessageSpeedWindow
	call DrawWindow
;> MenuResetBlink()
	call MenuResetBlink
;> wConfirmChoice = mem[0xC8EE]       # the message speed
	ld de, MessageSpeedCursorPos
	ld a, [$c8ee]
	ld [wConfirmChoice], a
;> MenuDrawCursorAt(wConfirmChoice, MessageSpeedCursorPos)
	ld a, [wConfirmChoice]
	call MenuDrawCursorAt
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def MessageSpeedInput()
;@ path: menu/options
;@ Option step 3: Left/Right picks the speed, B goes back without change, A sets
;@ it (0 slowest ... 7 instant) and returns to the main menu.
;@ test: skip draws into VRAM
MessageSpeedInput::
;> MoveMenuCursorSideways(wConfirmChoice, 8, MessageSpeedCursorPos)
	ld de, MessageSpeedCursorPos
	ld hl, wConfirmChoice
	ld b, $08
	call MoveMenuCursorSideways
;> if wJoyPressed & 0x02:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>@c17     wFieldMenuStep -= 3
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;=@c17
	jr .done

.notB
;> elif wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     mem[0xC8EE] = wConfirmChoice & 0x7F
	ld a, [wConfirmChoice]
	and $7f
	ld [$c8ee], a
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     MenuClearBuffer()
	call MenuClearBuffer
;>     wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a

.done
	ret


;@ path: menu/options
;@ Cursor offsets of the eight message speeds (row 14, every second column);
;@ $FFFF ends the list.
MessageSpeedCursorPos::
	dw $01c3, $01c5, $01c7, $01c9, $01cb, $01cd, $01cf, $01d1
	dw $ffff

;@ def LineUpShow()
;@ path: menu/options
;@ Option step 4, the line-up: the standing party monsters (fainted ones stay at
;@ the back) are listed on the left (wNumberBackup holds their party places, $FF
;@ empty); the new order is built on the right (wLineUpOrder).
;@ test: skip draws into VRAM
LineUpShow::
;> MenuLoadPartyNames()
	call MenuLoadPartyNames
;>@L n = 0
;>@L for i in range(wPartyCount):
	ld b, $00
;>@i     if not GetPartyMonsterByte(i, wMonStatus) & 0x80:
	ld a, $00
	push bc
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop bc
;=@i
	bit 7, a
	jr nz, .fainted0

;>@n         n += 1
	inc b

.fainted0
;=@L
	ld a, [wPartyCount]
	cp $01
	jr z, .counted

;=@i
	ld a, $01
	push bc
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop bc
;=@i
	bit 7, a
	jr nz, .fainted1

;=@n
	inc b

.fainted1
;=@L
	ld a, [wPartyCount]
	cp $02
	jr z, .counted

;=@i
	ld a, $02
	push bc
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop bc
;=@i
	bit 7, a
	jr nz, .counted

;=@n
	inc b

.counted
;> wMenuCount = n
	ld a, b
	ld [wMenuCount], a
;> wNumberBackup[0] = 0
	ld hl, wNumberBackup
	ld a, $00
	ld [hli], a
;>@c2 wNumberBackup[1] = 1 if n >= 2 else 0xFF
	ld b, $ff
	ld a, [wMenuCount]
	cp $02
	jr c, .one

	ld b, $01

.one
;=@c2
	ld [hl], b
	inc hl
;>@c3 wNumberBackup[2] = 2 if n >= 3 else 0xFF
	ld b, $ff
	ld a, [wMenuCount]
	cp $03
	jr c, .two

	ld b, $02

.two
;=@c3
	ld [hl], b
	inc hl
;> wLineUpOrder[0:3] = [0xFF, 0xFF, 0xFF]
	ld a, $ff
	ld [hli], a
	ld a, $ff
	ld [hli], a
	ld a, $ff
	ld [hli], a
;> wLineUpPlaced = 0
	xor a
	ld [wLineUpPlaced], a
;> DrawWindow(LineUpWindow)
	ld de, LineUpWindow
	call DrawWindow
;> DrawWindow(LineUpOrderWindow)
	ld de, LineUpOrderWindow
	call DrawWindow
;> DrawLineUp()
	call DrawLineUp
;> MenuResetBlink()
	call MenuResetBlink
;> MenuDrawCursorAt(wConfirmChoice2, LineUpCursorPos)
	ld de, LineUpCursorPos
	ld a, [wConfirmChoice2]
	call MenuDrawCursorAt
;> MenuShowBuffer()
	call MenuShowBuffer
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def DrawLineUp()
;@ path: menu/options
;@ Closes the gap left in the list of monsters still to place, then draws both
;@ columns: each entry a number tile and the monster's four name tiles.
;@ test: skip writes the tilemap buffer
DrawLineUp::
;> if wNumberBackup[0] == 0xFF:        # close the gap
	ld a, [wNumberBackup]
	cp $ff
	jr z, .gap0

;>@g0     wNumberBackup[0] = wNumberBackup[1]
;>@g1     wNumberBackup[1:3] = [wNumberBackup[2], 0xFF]
;> elif wNumberBackup[1] == 0xFF:
	ld a, [wNumberBackup + 1]
	cp $ff
	jr z, .gap1

	jr .draw

;>@g1     wNumberBackup[1:3] = [wNumberBackup[2], 0xFF]
.gap0
;=@g0
	ld a, [wNumberBackup + 1]
	ld [wNumberBackup], a

.gap1
;=@g1
	ld a, [wNumberBackup + 2]
	ld [wNumberBackup + 1], a
	ld a, $ff
	ld [wNumberBackup + 2], a
.draw
;> for i in range(3):                  # left: still to place, numbered by party place
;>@c4     DrawLineUpEntry(wNumberBackup[i], 0xF1 + wNumberBackup[i], wTilemapBuffer + 0x185 + 0x40 * i)
	ld hl, $c685
	ld a, [wNumberBackup]
	add $f1
	ld b, a
	ld a, [wNumberBackup]
	call DrawLineUpEntry
;=@c4
	ld hl, $c6c5
	ld a, [wNumberBackup + 1]
	add $f1
	ld b, a
	ld a, [wNumberBackup + 1]
	call DrawLineUpEntry
;=@c4
	ld hl, $c705
	ld a, [wNumberBackup + 2]
	add $f1
	ld b, a
	ld a, [wNumberBackup + 2]
	call DrawLineUpEntry
;> for i in range(3):                  # right: the new order, numbered 1-3
;>@c5     DrawLineUpEntry(wLineUpOrder[i], 0xF1 + i, wTilemapBuffer + 0x18D + 0x40 * i)
	ld hl, $c68d
	ld b, $f1
	ld a, [wLineUpOrder]
	call DrawLineUpEntry
;=@c5
	ld hl, $c6cd
	ld b, $f2
	ld a, [wLineUpOrder + 1]
	call DrawLineUpEntry
;=@c5
	ld hl, $c70d
	ld b, $f3
	ld a, [wLineUpOrder + 2]
	call DrawLineUpEntry
	ret


;@ def DrawLineUpEntry(place: a, number: b, dest: hl)
;@ path: menu/options
;@ One line-up entry at `dest` in the tilemap buffer: tile `number`, a gap, then the
;@ four name tiles of party place `place` ($20 + 4 * place on); all blank for $FF.
DrawLineUpEntry::
;> if place != 0xFF:
	cp $ff
	jr z, .blank

;>     mem[dest] = number
	ld [hl], b
	inc hl
	inc hl
;>@c6     mem[dest + 2:dest + 6] = [0x20 + 4 * place + i for i in range(4)]
	add a
	add a
	add $20
	ld [hli], a
	inc a
	ld [hli], a
;=@c6
	inc a
	ld [hli], a
	inc a
	ld [hl], a
;>     return
	ret


.blank
;> mem[dest] = 0xE0
;>@c7 mem[dest + 2:dest + 6] = [0xE0] * 4
	ld a, $e0
	ld [hli], a
	inc hl
	ld [hli], a
	ld [hli], a
	ld [hli], a
;=@c7
	ld [hl], a
	ret


;@ def LineUpInput()
;@ path: menu/options
;@ Option step 5: Up/Down in the list of monsters still to place; B takes back the
;@ last placed monster (or, with none placed, leaves: LineUpBack); otherwise
;@ LineUpConfirm handles A.
;@ test: skip draws into VRAM
LineUpInput::
;> if wLineUpPlaced != wMenuCount:
	ld a, [wMenuCount]
	ld c, a
	ld a, [wLineUpPlaced]
	cp c
	jr z, .moved

;>@c8     MoveMenuCursor(wConfirmChoice2, wMenuCount - wLineUpPlaced, LineUpCursorPos)
	ld de, LineUpCursorPos
	ld hl, wConfirmChoice2
	ld a, [wLineUpPlaced]
	ld b, a
	ld a, c
	sub b
;=@c8
	ld b, a
	call MoveMenuCursor

.moved
;> wConfirmChoice2 &= 0x7F
	ld a, [wConfirmChoice2]
	and $7f
	ld [wConfirmChoice2], a
;> if not wJoyPressed & 0x02:
;>     return LineUpConfirm()
	ld a, [wJoyPressed]
	bit 1, a
	jr z, LineUpConfirm

;> if wLineUpPlaced == 0:
;>     return LineUpBack()
	ld a, [wLineUpPlaced]
	cp $00
	jr z, LineUpBack

;>@c9 place = wLineUpOrder[wLineUpPlaced - 1]    # take back the last one
	dec a
	ld hl, wLineUpOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@c9
	ld h, a
	ld a, [hl]
;> wLineUpOrder[wLineUpPlaced - 1] = 0xFF
	ld [hl], $ff
;> wNumberBackup[2] = place
	ld [wNumberBackup + 2], a
;>@s for i in range(3):                 # bubble sort, $FF last
;>     SortStep(wNumberBackup)
	ld hl, wNumberBackup
	call SortStep
;>     SortStep(wNumberBackup + 1)
	call SortStep
;=@s
	ld hl, wNumberBackup
	call SortStep
	call SortStep
	ld hl, wNumberBackup
	call SortStep
;=@s
	call SortStep
;> DrawLineUp()
	call DrawLineUp
;> MenuShowBuffer()
	call MenuShowBuffer
;> wLineUpPlaced -= 1
	ld hl, wLineUpPlaced
	dec [hl]
	jp LineUpDone


;@ def SortStep(pair: hl) -> hl
;@ path: menu/options
;@ Swaps the bytes [`pair`] and [`pair` + 1] unless the first is smaller; returns
;@ `pair` + 1.
;@ test: skip works on any address
SortStep::
;> if mem[pair] >= mem[pair + 1]:
	ld a, [hli]
	ld b, [hl]
	cp b
	ret c

;>     mem[pair:pair + 2] = [mem[pair + 1], mem[pair]]
	ld [hld], a
	ld [hl], b
	inc hl
;> return pair + 1
	ret


;@ def LineUpBack()
;@ path: menu/options
;@ B with no monster placed yet: back to the option window (step 0).
LineUpBack::
;>@c10 wFieldMenuStep -= 5
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
;=@c10
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;=@c10
	jp LineUpDone


;@ def LineUpConfirm()
;@ path: menu/options
;@ A in the line-up: places the monster under the cursor next in the new order;
;@ once all are placed, writes the new order into wParty, refreshes the party
;@ sprites (and the followers' sprites in the town, map 6) and closes the menu.
;@ test: skip draws into VRAM
LineUpConfirm::
;> if not wJoyPressed & 0x01:
;>     return
	ld a, [wJoyPressed]
	bit 0, a
	jp z, LineUpDone

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> if wLineUpPlaced != wMenuCount:
	ld a, [wMenuCount]
	ld c, a
	ld a, [wLineUpPlaced]
	cp c
	jr z, .allPlaced

;>     wLineUpOrder[wLineUpPlaced] = wNumberBackup[wConfirmChoice2]
;>@c11     wNumberBackup[wConfirmChoice2] = 0xFF
	ld hl, wLineUpOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@c11
	ld a, [wConfirmChoice2]
	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
	adc d
;=@c11
	ld d, a
	ld a, [de]
	ld [hl], a
	ld a, $ff
	ld [de], a
;>     if wLineUpPlaced == wMenuCount - 1:     # the last one: clear the left column
	ld a, [wMenuCount]
	ld c, a
	dec c
	ld a, [wLineUpPlaced]
	cp c
	jr nz, .more

;>         DrawWindow(LineUpWindow)
	ld de, LineUpWindow
	call DrawWindow
	jr .redraw

.more
;>@c12     elif wConfirmChoice2 >= wMenuCount - 1 - wLineUpPlaced:     # cursor below the shorter list
	ld b, a
	ld a, c
	sub b
	ld b, a
	ld a, [wConfirmChoice2]
	cp b
;=@c12
	jr c, .redraw

;>         wConfirmChoice2 -= 1
	dec a
	ld [wConfirmChoice2], a
;>         MenuDrawCursorMarks(wConfirmChoice2, LineUpCursorPos)
	ld de, LineUpCursorPos
	call MenuDrawCursorMarks

.redraw
;>     DrawLineUp()
	call DrawLineUp
;>     MenuShowBuffer()
	call MenuShowBuffer
;>     wLineUpPlaced += 1
	ld hl, wLineUpPlaced
	inc [hl]
;>     return
	jp LineUpDone


.allPlaced
;> for i in range(3):
;>@c13     wNumberBackup[i] = LineUpGetSlot(wLineUpOrder[i])     # party place -> record slot
	ld a, [wLineUpOrder]
	call LineUpGetSlot
	ld [wNumberBackup], a
;=@c13
	ld a, [wLineUpOrder + 1]
	call LineUpGetSlot
	ld [wNumberBackup + 1], a
;=@c13
	ld a, [wLineUpOrder + 2]
	call LineUpGetSlot
	ld [wNumberBackup + 2], a
;> wParty[0] = wNumberBackup[0]
	ld a, [wNumberBackup]
	ld [wParty], a
;> if wMenuCount != 1:
	ld a, [wMenuCount]
	cp $01
	jr z, .written

;>     wParty[1] = wNumberBackup[1]
	ld a, [wNumberBackup + 1]
	ld [wParty + 1], a
;>     if wMenuCount != 2:
	ld a, [wMenuCount]
	cp $02
	jr z, .written

;>         wParty[2] = wNumberBackup[2]
	ld a, [wNumberBackup + 2]
	ld [wParty + 2], a

.written
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;>@c14 if not wOnGateFloor and wMapId == 6 and mem[0xC925] == 0:     # in the town the followers walk on screen
	ld a, [wOnGateFloor]
	or a
	jr nz, .bar

	ld a, [wMapId]
	cp $06
	jr nz, .bar

;=@c14
	ld a, [$c925]
	or a
	jr nz, .bar

;>     for i in range(3):
;>@c15         mem[wActors + 0x31 + 0x20 * i] = wPartyGfx[i]    # the follower actors' sprite graphics
	ld a, [wPartyGfx]
	cp $ff
	jr z, .gfx0

.gfx0
;=@c15
	ld [wActors + $31], a
	ld a, [wPartyGfx + 1]
	cp $ff
	jr z, .gfx1

.gfx1
;=@c15
	ld [wActors + $51], a
	ld a, [wPartyGfx + 2]
	cp $ff
	jr z, .gfx2

.gfx2
;=@c15
	ld [wActors + $71], a

.bar
;> BuildStatusBar()
	call BuildStatusBar
;> MenuClearBuffer()
	call MenuClearBuffer
;> wStatusViewVars = 1
	ld a, $01
	ld [wStatusViewVars], a

LineUpDone:
	ret


;@ path: menu/options
;@ Cursor offsets of the line-up's left column; $FFFF ends the list.
LineUpCursorPos::
	dw $0186, $01c6, $0206
	dw $ffff

;@ def LineUpGetSlot(place: a) -> a
;@ path: menu/options
;@ Returns wParty[`place`], the record slot of a party place; $FF stays $FF.
LineUpGetSlot::
;> if place == 0xFF:
;>     return 0xFF
	cp $ff
	ret z

;>@c16 return wParty[place]
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
;=@c16
	ld h, a
	ld a, [hl]
	ret


SaveShow::
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_007_6090

	ld a, [wMapId]
	cp $60
	jr z, jr_007_6090

	cp $61
	jr z, jr_007_6090

	cp $62
	jr z, jr_007_6090

	cp $63
	jr z, jr_007_6090

	cp $64
	jr z, jr_007_6090

	cp $30
	jr c, jr_007_60a5

	cp $5a
	jr z, jr_007_60a5

	cp $5b
	jr z, jr_007_60a5

	cp $5c
	jr z, jr_007_60a5

	cp $50
	jr z, jr_007_60a5

	cp $51
	jr z, jr_007_60a5

jr_007_6090:
	ld hl, $0243
	call PrintSystemText
	ld de, $2e07
	call DrawWindow
	call MenuShowBuffer
	ld a, $09
	ld [wFieldMenuStep], a
	ret


jr_007_60a5:
	ld a, $5c
	call QueueSound
	ld de, $7bca
	call DrawWindow
	ld de, $7c44
	call DrawWindow
	ld de, $2e07
	call DrawWindow
	ld hl, sSaveValid
	call ReadSRAMByte
	or a
	jr nz, jr_007_6122

	ld hl, $0021
	call BufferAddress
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0041
	call BufferAddress
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0061
	call BufferAddress
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0081
	call BufferAddress
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0044
	call BufferAddress
	ld b, $0a
	ld a, $40

jr_007_6107:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_007_6107

	ld a, $31
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
	ld hl, $9400
	ld de, $0a01
	call MenuDrawTextTiles
	jp Jump_007_61de


jr_007_6122:
	di
	ld a, $0a
	ld [$0100], a
	ld de, sPlayerName
	ld hl, $93c0
	call MenuDrawNameTiles
	ei
	call DrawSaveParty
	ld hl, sPartyCount
	call ReadSRAMByte
	or a
	jr z, jr_007_61a8

	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonLevel
	ld a, [sParty]
	call MonsterField
	ld c, [hl]
	ei
	ld b, $00
	ld hl, $0084
	call BufferAddress
	call PrintNumber2
	ld hl, sPartyCount
	call ReadSRAMByte
	cp $01
	jr z, jr_007_61ae

	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonLevel
	ld a, [$a1c9]
	call MonsterField
	ld c, [hl]
	ei
	ld b, $00
	ld hl, $008a
	call BufferAddress
	call PrintNumber2
	ld hl, sPartyCount
	call ReadSRAMByte
	cp $02
	jr z, jr_007_61b4

	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonLevel
	ld a, [$a1ca]
	call MonsterField
	ld c, [hl]
	ei
	ld b, $00
	ld hl, $0090
	call BufferAddress
	call PrintNumber2
	jr jr_007_61ba

jr_007_61a8:
	ld hl, $0061
	call ClearSaveMemberLevel

jr_007_61ae:
	ld hl, $0067
	call ClearSaveMemberLevel

jr_007_61b4:
	ld hl, $006d
	call ClearSaveMemberLevel

jr_007_61ba:
	ld hl, sPlayHours
	call ReadSRAMByte
	ld c, a
	ld b, $00
	ld hl, $002d
	call BufferAddress
	call PrintNumber2Zeros
	ld hl, sPlayMinutes
	call ReadSRAMByte
	ld c, a
	ld b, $00
	ld hl, $0030
	call BufferAddress
	call PrintNumber2Zeros

Jump_007_61de:
	ld a, $00
	ld [$0100], a
	ld hl, $0207
	call PrintSystemText
	call MenuResetBlink
	ld de, $6330
	ld a, [wMenuChoice3]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


DrawSaveParty::
	ld hl, $8da0
	ld b, $18
	call ClearTextTiles2
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonName
	ld a, [sParty]
	call MonsterField
	ei
	ld e, l
	ld d, h
	ld hl, $9400
	ld a, $01
	call DrawSaveMember
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonName
	ld a, [$a1c9]
	call MonsterField
	ei
	ld e, l
	ld d, h
	ld hl, $9440
	ld a, $02
	call DrawSaveMember
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonName
	ld a, [$a1ca]
	call MonsterField
	ei
	ld e, l
	ld d, h
	ld hl, $9480
	ld a, $03
	call DrawSaveMember
	ret


DrawSaveMember::
	ld b, a
	di
	ld a, $0a
	ld [$0100], a
	ld a, [sPartyCount]
	cp b
	ei
	jr nc, DrawSaveMemberIcon

	ld b, $20

ClearTextTiles2::
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, ClearTextTiles2

	ret


DrawSaveMemberIcon::
	push bc
	call MenuDrawNameTiles
	pop bc
	dec b
	push bc
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sParty
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld hl, sSavedMonFamily
	call MonsterField
	ld a, [hl]
	ei
	add a
	ld hl, $62ab
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop bc
	ld a, b
	swap a
	add $a0
	ld l, a
	ld h, $8d
	call DecompressVRAM
	ret


FamilyIconGfx::
	db $03, $2e, $04, $2e, $05, $2e, $06, $2e, $07, $2e, $08, $2e, $09, $2e, $0a, $2e
	db $0b, $2e, $0c, $2e

ClearSaveMemberLevel::
	push hl
	call BufferAddress
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	pop hl
	ld a, l
	add $21
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call BufferAddress
	ld a, $e0
	ld [hli], a
	ld [hl], a
	ret


SaveInput::
	ld de, $6330
	ld hl, wMenuChoice3
	ld b, $02
	call MoveMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_630b

jr_007_62ed:
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_632f

jr_007_630b:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_632f

	ld a, [wMenuChoice3]
	cp $81
	jr nz, jr_007_6321

	ld a, $59
	call QueueSound
	jr jr_007_62ed

jr_007_6321:
	di
	call SaveGame
	ei
	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]

Jump_007_632f:
jr_007_632f:
	ret


SaveCursorPos::
	db $2f, $01, $6f, $01, $ff, $ff

SaveDone::
	ld hl, $0232
	call PrintSystemText
	ld hl, wFieldMenuStep
	inc [hl]
	ret


OptionCloseAfterText::
	ld a, [wTextState]
	or a
	ret nz

	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	ret


TacticsStart::
	ld a, [wPartyCount]
	or a
	jr z, jr_007_637c

	ld hl, wMonStatus

jr_007_6358:
	ld a, [wLinkPartnerChoice]
	ld hl, wMonStatus
	call PartyMonsterField
	bit 7, [hl]
	jr z, jr_007_6374

	ld hl, wLinkPartnerChoice
	inc [hl]
	ld a, [wLinkPartnerChoice]
	ld hl, wPartyCount
	cp [hl]
	jr nz, jr_007_6358

	jr jr_007_637c

jr_007_6374:
	call TacticsShow
	ld hl, wFieldMenuStep
	inc [hl]
	ret


jr_007_637c:
	call MenuClearBuffer
	ld a, $00
	ld [wFieldMenuStep], a
	ret


TacticsShow::
	ld hl, wMonName
	ld a, [wLinkPartnerChoice]
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, $93c0
	call MenuDrawNameTiles
	ld de, $7c69
	call DrawWindow
	ld de, $7cd7
	call DrawWindow
	ld hl, wMonGender
	ld a, [wLinkPartnerChoice]
	call PartyMonsterField
	ld a, [hl]
	swap a
	and $03
	ld [wLinkRefused], a
	call MenuResetBlink
	ld de, $644c
	ld a, [wLinkRefused]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ret


TacticsInput::
	ld de, $644c
	ld hl, wLinkRefused
	ld b, $04
	call MoveMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_63fc

jr_007_63d5:
	ld a, [wLinkPartnerChoice]
	or a
	jr z, jr_007_63f2

	ld hl, wLinkPartnerChoice
	dec [hl]
	ld a, [wLinkPartnerChoice]
	ld hl, wMonStatus
	call PartyMonsterField
	bit 7, [hl]
	jr nz, jr_007_63d5

	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_644b

jr_007_63f2:
	call MenuClearBuffer
	ld a, $00
	ld [wFieldMenuStep], a
	jr jr_007_644b

jr_007_63fc:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_007_644b

	ld a, $59
	call QueueSound
	ld a, [wLinkRefused]
	and $03
	swap a
	ld b, a
	push bc
	ld hl, wMonGender
	ld a, [wLinkPartnerChoice]
	call PartyMonsterField
	ld a, [hl]
	and $cf
	pop bc
	or b
	ld [hl], a

jr_007_6420:
	ld hl, wLinkPartnerChoice
	inc [hl]
	ld a, [wPartyCount]
	ld b, a
	ld a, [wLinkPartnerChoice]
	cp b
	jr z, jr_007_6441

	ld a, [wLinkPartnerChoice]
	ld hl, wMonStatus
	call PartyMonsterField
	bit 7, [hl]
	jr nz, jr_007_6420

	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_644b

jr_007_6441:
	call MenuClearBuffer
	ld a, $00
	ld [wFieldMenuStep], a
	jr jr_007_644b

jr_007_644b:
	ret


TacticsCursorPos::
	db $41, $01, $81, $01, $c1, $01, $01, $02, $ff, $ff

;@ def ShowMonsterStatus()
;@ path: menu/viewer
;@ Far entry 1 of bank 7: opens the monster status screen (the field menu's status
;@ pages) on top of another screen, for the single monster wCurPartyMember (a
;@ record slot); then runs it like UpdateMonsterStatus.
;@ test: skip jumps through a table
ShowMonsterStatus::
;> wViewList = address(wCurPartyMember)     # a list of one entry
	ld hl, wCurPartyMember
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [wViewList + 1], a
;> wViewIndex = 0
;> wViewCount = 0
	xor a
	ld [wViewIndex], a
	ld [wViewCount], a
;> UpdateMonsterStatus()

;@ def UpdateMonsterStatus()
;@ path: menu/viewer
;@ Far entry 2 of bank 7, once a frame while the monster status screen is open:
;@ runs step wFieldMenuStep. Up/Down pages through the monsters of wViewList
;@ (wViewCount entries).
;@ test: skip jumps through a table
UpdateMonsterStatus::
;> MonsterStatusSteps[wFieldMenuStep]()
	ld a, [wFieldMenuStep]
	rst $00

;@ path: menu/viewer
;@ Steps of the monster status screen (UpdateMonsterStatus).
MonsterStatusSteps::
	dw ViewerStart
	dw ViewerOpen
	dw ViewerDrawPage1
	dw ViewerPage1Input
	dw ViewerShowPage2
	dw ViewerPage2Input
	dw ViewerShowSkills
	dw ViewerSkillsInput
	dw ViewerShowPedigree
	dw ViewerPedigreeInput
	dw ViewerStepNext
	dw ViewerClose
	dw ViewerRedrawPage2
	dw ViewerRedrawPedigree

;@ def ViewerStart()
;@ path: menu/viewer
;@ Viewer step 0: marks the overlay, starts at entry wViewIndex of the list.
ViewerStart::
;> wMenuOverlay = 1
	ld a, $01
	ld [wMenuOverlay], a
;> wViewResult = wViewIndex
	ld a, [wViewIndex]
	ld [wViewResult], a
;>@c1 wCurPartyMember = mem[wViewList + wViewIndex]
	ld a, [wViewList]
	ld l, a
	ld a, [wViewList + 1]
	ld h, a
	ld a, [wViewIndex]
	add l
;=@c1
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def ViewerOpen()
;@ path: menu/viewer
;@ Viewer step 1: sets up the menu screen; an egg only gets its picture and the
;@ pedigree page (step 8).
;@ test: skip draws into VRAM
ViewerOpen::
;> SetUpMenuScreen()
	call SetUpMenuScreen
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
;> if MonsterField(wCurPartyMember, wMonEgg)[0]:
	ld a, [wCurPartyMember]
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	or a
	ret z

;>     StatusShowPicture()
	call StatusShowPicture
;>     wFieldMenuStep = 8
	ld a, $08
	ld [wFieldMenuStep], a
	ret


;@ def ViewerDrawPage1()
;@ path: menu/viewer
;@ Viewer step 2: the first status page (stats) with the picture.
;@ test: skip draws into VRAM
ViewerDrawPage1::
;> DrawWindow(StatusStatsWindow)
	ld de, StatusStatsWindow
	call DrawWindow
;> DrawWindow(StatusHPWindow)
	ld de, StatusHPWindow
	call DrawWindow
;> DrawStatusStats()
	call DrawStatusStats
;> StatusShowPicture()
	call StatusShowPicture
	ret


;@ def ViewerPage1Input()
;@ path: menu/viewer
;@ Viewer step 3: Up/Down shows the previous/next monster of the list, B closes
;@ the viewer, A turns to the second page.
;@ test: skip draws into VRAM
ViewerPage1Input::
;> if ViewerChangeMonster():
	call ViewerChangeMonster
	jr z, .buttons

;>     ViewerDrawPage1()
	call ViewerDrawPage1
;>     wFieldMenuStep -= 1
	ld hl, wFieldMenuStep
	dec [hl]

.buttons
;> if wJoyPressed & 0x02:
;>     return ViewerClose()
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

	jp ViewerClose


.notB
;> if wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]

.done
	ret


;@ def ViewerChangeMonster() -> f
;@ path: menu/viewer
;@ Up/Down (with repeat) moves to the previous/next entry of wViewList (wrapping)
;@ and makes it wCurPartyMember; returns nz (flag) when the entry changed.
;@ test: skip reads the list through a pointer
ViewerChangeMonster::
;> old = wViewResult
	ld a, [wViewResult]
	push af
;> if wViewCount == 0:
;>     return False
	ld a, [wViewCount]
	ld b, a
	or a
	jr z, .none

;> if wJoyRepeat & 0x40:                 # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .notUp

;>@c3     pos = wViewResult - 1 if wViewResult > 0 else wViewCount - 1
	ld a, [wViewResult]
	dec a
	cp b
	jr c, .store

	dec b
	ld a, b
;=@c3
	jr .store

.notUp
;> elif wJoyRepeat & 0x80:               # Down
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, .none

;>     pos = wViewResult + 1 if wViewResult + 1 < wViewCount else 0
	ld a, [wViewResult]
	inc a
	cp b
	jr c, .store

	ld a, $00
;>@no else:
;>@no     return False
.store
;> wViewResult = pos
	ld [wViewResult], a
;>@c2 wCurPartyMember = mem[wViewList + pos]
	ld b, a
	ld a, [wViewList]
	ld l, a
	ld a, [wViewList + 1]
	ld h, a
	ld a, b
;=@c2
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;=@c2
	ld [wCurPartyMember], a
;> return pos != old
	pop af
	cp b
	ret


.none
;=@no
	pop af
	xor a
	ret


;@ def ViewerShowPage2()
;@ path: menu/viewer
;@ Viewer step 4: the second status page.
;@ test: skip draws into VRAM
ViewerShowPage2::
;> StatusShowPage2()
	call StatusShowPage2
	ret


;@ def ViewerPage2Input()
;@ path: menu/viewer
;@ Viewer step 5: Up/Down redraws the page for another monster (step 12), B goes
;@ back to page 1, A on to the skills; the monster's sprite walks meanwhile.
;@ test: skip draws into VRAM
ViewerPage2Input::
;> if ViewerChangeMonster():
	call ViewerChangeMonster
	jr z, .buttons

;>     wFieldMenuStep = 0x0C
	ld a, $0c
	ld [wFieldMenuStep], a
	jr .done

.buttons
;> elif wJoyPressed & 0x02:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>@c4     wFieldMenuStep -= 3
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
;=@c4
	jr .done

.notB
;> else:
;>     if wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .sprite

;>         QueueSound(0x59)
	ld a, $59
	call QueueSound
;>         wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]

.sprite
;>     DrawStatusSprite()
	call DrawStatusSprite

.done
	ret


;@ def ViewerShowSkills()
;@ path: menu/viewer
;@ Viewer step 6: the skills page (an egg closes the viewer instead).
;@ test: skip draws into VRAM
ViewerShowSkills::
;> if MonsterField(wCurPartyMember, wMonEgg)[0]:
;>     return ViewerClose()
	ld a, [wCurPartyMember]
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	or a
	jr nz, ViewerClose

;> DrawMonSkillNames()
	call DrawMonSkillNames
;> DrawWindow(StatusSkillsWindow)
	ld de, StatusSkillsWindow
	call DrawWindow
;> MenuShowBuffer()
	call MenuShowBuffer
;> LoadStatusPicture()
	call LoadStatusPicture
;> SetStatusPicPalette()
	call SetStatusPicPalette
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def ViewerSkillsInput()
;@ path: menu/viewer
;@ Viewer step 7: Up/Down redraws the skills for another monster, then the skills
;@ page buttons (StatusSkillsButtons).
;@ test: skip draws into VRAM
ViewerSkillsInput::
;> if ViewerChangeMonster():
	call ViewerChangeMonster
	jr z, .buttons

;>     ViewerShowSkills()
	call ViewerShowSkills
;>     wFieldMenuStep -= 1
	ld hl, wFieldMenuStep
	dec [hl]

.buttons
;> StatusSkillsButtons()
	call StatusSkillsButtons
	ret


;@ def ViewerShowPedigree()
;@ path: menu/viewer
;@ Viewer step 8: the pedigree page.
;@ test: skip draws into VRAM
ViewerShowPedigree::
;> StatusShowPedigree()
	call StatusShowPedigree
	ret


;@ def ViewerPedigreeInput()
;@ path: menu/viewer
;@ Viewer step 9: Up/Down redraws the pedigree for another monster (step 13),
;@ otherwise the pedigree page buttons (StatusPedigreeButtons).
;@ test: skip draws into VRAM
ViewerPedigreeInput::
;> if ViewerChangeMonster():
	call ViewerChangeMonster
	jr z, .buttons

;>     wFieldMenuStep = 0x0D
	ld a, $0d
	ld [wFieldMenuStep], a
	jr .done

.buttons
;> else:
;>     StatusPedigreeButtons()
	call StatusPedigreeButtons

.done
	ret


;@ def ViewerStepNext()
;@ path: menu/viewer
;@ Viewer step 10: goes on (to ViewerClose).
ViewerStepNext::
;> wFieldMenuStep += 1
	ld hl, wFieldMenuStep
	inc [hl]
	ret


;@ def ViewerRedrawPage2()
;@ path: menu/viewer
;@ Viewer step 12: page 2 for the new monster, back to its input (step 5).
;@ test: skip draws into VRAM
ViewerRedrawPage2::
;> SyncStatusMonster()
	call SyncStatusMonster
;> DrawStatusPage2()
	call DrawStatusPage2
;> LoadStatusPicture()
	call LoadStatusPicture
;> SetStatusPicPalette()
	call SetStatusPicPalette
;> wFieldMenuStep = 5
	ld a, $05
	ld [wFieldMenuStep], a
	ret


;@ def ViewerRedrawPedigree()
;@ path: menu/viewer
;@ Viewer step 13: the pedigree for the new monster, back to its input (step 9).
;@ test: skip draws into VRAM
ViewerRedrawPedigree::
;> SyncStatusMonster()
	call SyncStatusMonster
;> DrawPedigree()
	call DrawPedigree
;> LoadStatusPicture()
	call LoadStatusPicture
;> SetStatusPicPalette()
	call SetStatusPicPalette
;> wFieldMenuStep = 9
	ld a, $09
	ld [wFieldMenuStep], a
	ret


;@ def ViewerClose()
;@ path: menu/viewer
;@ Viewer step 11: clears the menu screen; from a game mode other than 0 the field
;@ screen and its palettes and CGB attributes are restored. The caller's step
;@ (wMenuSubStep) moves on.
;@ test: skip calls routines in other banks
ViewerClose::
;> MenuClearBuffer()
	call MenuClearBuffer
;> MenuShowBuffer()
	call MenuShowBuffer
;> ClearMenuBgMap()
	call ClearMenuBgMap
;> if wGameMode:
	ld a, [wGameMode]
	or a
	jr z, .done

;>     ReloadMapTileset()
	ld hl, far_ReloadMapTileset
	rst $10
;>     LoadMapPalettes()
	ld hl, far_LoadMapPalettes
	rst $10
;>     UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
;>     RestoreFieldAttrMap()
	call RestoreFieldAttrMap
;>     LoadFieldActorGfx()
	ld hl, far_LoadFieldActorGfx
	rst $10

.done
;> wMenuOverlay = 0
	ld a, $00
	ld [wMenuOverlay], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def RestoreFieldAttrMap()
;@ path: menu/screen
;@ On a Game Boy Color, writes the field's BG attributes back after a menu: 16
;@ rows of 20 tiles from the screen's top left corner, two 4-bit attributes per
;@ byte of wScreenMap (high nibble first, 16 bytes a row of which 10 are used).
;@ test: skip writes VRAM
RestoreFieldAttrMap::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> WaitVRAMAccess()
;> rVBK = 1
	di
	call WaitVRAMAccess
	ld a, $01
	ldh [rVBK], a
	ei
;>@c1 p = 0x9800 + (hScrollY & 0xF8) * 4 + ((hScrollX >> 3) & 0x1F)
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
;=@c1
	sla l
	rla
	ld h, $98
	add h
	ld h, a
	ldh a, [hScrollX]
;=@c1
	rrca
	rrca
	rrca
	and $1f
	add l
	ld l, a
;=@c1
	ld a, $00
	adc h
	ld h, a
;> src = wScreenMap
;>@r for row in range(16):
	ld de, wScreenMap
	ld c, $10
.row
;>     q = p
;>@c     for i in range(10):
	ld b, $0a
	push hl
.byte
;>         WriteVRAM(mem[src] >> 4, q)
	ld a, [de]
	swap a
	and $0f
	call WriteVRAM
;>@c2         q = NextMapColumn(q)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@c2
	ld l, a
	pop af
	or l
	ld l, a
;>         WriteVRAM(mem[src] & 0x0F, q)
	ld a, [de]
	and $0f
	call WriteVRAM
;>@c3         q = NextMapColumn(q)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@c3
	ld l, a
	pop af
	or l
	ld l, a
;>         src += 1
	inc de
;=@c
	dec b
	jr nz, .byte

;>@c4     src += 6
	pop hl
	ld a, e
	add $06
	ld e, a
	ld a, d
	adc $00
;=@c4
	ld d, a
;>@c5     p = 0x9800 | ((p + 0x20) & 0x3FF)
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
	or $98
;=@c5
	ld h, a
	pop bc
;=@r
	dec c
	jr nz, .row

;> WaitVRAMAccess()
;> rVBK = 0
	di
	call WaitVRAMAccess
	ld a, $00
	ldh [rVBK], a
	ei
	ret


;@ def AlignScrollToTile(scroll: hl)
;@ path: menu/screen
;@ Rounds the 16-bit scroll position at `scroll` to the nearest multiple of 8, so
;@ the menu windows line up with the background tiles.
;@ test: skip writes through a pointer
AlignScrollToTile::
;> mem16[scroll] += 4
	ld a, [hl]
	add $04
	ld [hli], a
	ld a, [hl]
	adc $00
	ld [hld], a
;> mem[scroll] &= 0xF8
	ld a, [hl]
	and $f8
	ld [hl], a
	ret


;@ def LoadMonsterSprite(species: a, dest: hl)
;@ path: menu/screen
;@ Unpacks the walking sprite tiles of `species` (MonsterSpriteGfx entry species +
;@ $10) to VRAM `dest`.
;@ test: skip decompresses into VRAM
LoadMonsterSprite::
;>@c6 gfx = MonsterSpriteGfx[species + 0x10]
	push hl
	add $10
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
;=@c6
	add LOW(MonsterSpriteGfx)
	ld l, a
	ld a, h
	adc HIGH(MonsterSpriteGfx)
	ld h, a
	ld e, [hl]
;=@c6
	inc hl
	ld d, [hl]
;> DecompressVRAM(gfx >> 8, gfx & 0xFF, dest)
	pop hl
	call DecompressVRAM
	ret


;@ def DrawStatusSprite()
;@ path: menu/screen
;@ On the second status page (not in game mode 0): the viewed monster's walking
;@ sprite at X $90, Y $40 (tiles from $50 on), stepping every 16 frames unless it
;@ has fainted.
;@ test: skip calls a routine in another bank
DrawStatusSprite::
;> if not wGameMode:
;>     return
	ld a, [wGameMode]
	or a
	ret z

;> species = GetViewedMonsterByte(wMonRecSpecies)
	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
	push af
;> hSpriteX = 0x0090
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x0040
	ld a, $40
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = species + 0x10
	pop af
	add $10
	ld [hli], a
;>@c7 hSpriteFrame = 1 if not GetViewedMonsterByte(wMonStatus) & 0x80 and wFrameCounter & 0x10 else 0
	ld b, $00
	push bc
	push hl
	ld hl, wMonStatus
	call GetViewedMonsterByte
	ld a, [hl]
;=@c7
	pop hl
	pop bc
	bit 7, a
	jr nz, .frame

	ld a, [wFrameCounter]
	bit 4, a
;=@c7
	jr z, .frame

	ld b, $01

.frame
;=@c7
	ld a, b
	ld [hli], a
;> hSpriteTileBase = 0x50
	ld a, $50
	ld [hli], a
;> hSpriteAttr = 0
	ld a, $00
	ld [hl], a
;> DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


;@ def DrawPedigreeSprites()
;@ path: menu/screen
;@ On the pedigree page (not in game mode 0): the two parents' walking sprites at
;@ X $90, Y $30 (tiles $60) and Y $78 (tiles $70), stepping every 16 frames;
;@ nothing without parents.
;@ test: skip calls a routine in another bank
DrawPedigreeSprites::
;> if not wGameMode:
;>     return
	ld a, [wGameMode]
	or a
	ret z

;> if GetViewedMonsterByte(wMonParent1) == 0xFF:
;>     return
	ld hl, wMonParent1
	call GetViewedMonsterByte
	cp $ff
	ret z

;> for parent in range(2):
;>     hSpriteX = 0x0090
	push af
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
	ld a, $00
	ld [hli], a
;>     hSpriteY = (0x0030, 0x0078)[parent]
	ld a, $30
	ld [hli], a
	ld a, $00
	ld [hli], a
;>     hSpriteSet = GetViewedMonsterByte((wMonParent1, wMonParent2)[parent]) + 0x10
	pop af
	add $10
	ld [hli], a
;>@c8     hSpriteFrame = 1 if wFrameCounter & 0x10 else 0
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame1

	ld b, $01

.frame1
;=@c8
	ld a, b
	ld [hli], a
;>     hSpriteTileBase = (0x60, 0x70)[parent]
	ld a, $60
	ld [hli], a
;>     hSpriteAttr = 0
	ld a, $00
	ld [hl], a
;>@c9     DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
;=@c9
	ld hl, wMonParent2
	call GetViewedMonsterByte
	push af
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
;=@c9
	ld a, $00
	ld [hli], a
	ld a, $78
	ld [hli], a
	ld a, $00
	ld [hli], a
;=@c9
	pop af
	add $10
	ld [hli], a
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
;=@c9
	jr z, .frame2

	ld b, $01

.frame2
;=@c9
	ld a, b
	ld [hli], a
	ld a, $70
	ld [hli], a
	ld a, $00
	ld [hl], a
;=@c9
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


;@ def DrawPartySprites()
;@ path: menu/screen
;@ On the main menu (state 2): each party monster's walking sprite under its
;@ picture, at X $2F, $5F, $8F and Y $78 (tiles $50, $60, $70), stepping every 16
;@ frames unless it has fainted.
;@ test: skip calls a routine in another bank
DrawPartySprites::
;> if wStatusViewVars != 2 or not wPartyCount:
;>     return
	ld a, [wStatusViewVars]
	cp $02
	ret nz

	ld a, [wPartyCount]
	or a
	ret z

;>@p for i in range(wPartyCount):
;>     species = GetPartyMonsterByte(i, wMonRecSpecies)
	ld a, $00
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	push af
;>     hSpriteX = 0x002F + 0x30 * i
	ld hl, hSpriteX
	ld a, $2f
	ld [hli], a
	ld a, $00
	ld [hli], a
;>     hSpriteY = 0x0078
	ld a, $78
	ld [hli], a
	ld a, $00
	ld [hli], a
;>     hSpriteSet = species + 0x10
	pop af
	add $10
	ld [hli], a
;>@c10     hSpriteFrame = 1 if not GetPartyMonsterByte(i, wMonStatus) & 0x80 and wFrameCounter & 0x10 else 0
	ld b, $00
	push bc
	push hl
	ld hl, wMonStatus
	ld a, $00
	call GetPartyMonsterByte
;=@c10
	ld a, [hl]
	pop hl
	pop bc
	bit 7, a
	jr nz, .frame0

	ld a, [wFrameCounter]
;=@c10
	bit 4, a
	jr z, .frame0

	ld b, $01

.frame0
;=@c10
	ld a, b
	ld [hli], a
;>     hSpriteTileBase = 0x50 + 0x10 * i
	ld a, $50
	ld [hli], a
;>     hSpriteAttr = 0
	ld a, $00
	ld [hl], a
;>     DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
;=@p
	ld a, [wPartyCount]
	cp $01
	ret z

;=@p
	ld a, $01
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	push af
	ld hl, hSpriteX
	ld a, $5f
;=@p
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $78
	ld [hli], a
	ld a, $00
;=@p
	ld [hli], a
	pop af
	add $10
	ld [hli], a
	ld b, $00
	push bc
;=@p
	push hl
	ld hl, wMonStatus
	ld a, $01
	call GetPartyMonsterByte
	ld a, [hl]
	pop hl
;=@p
	pop bc
	bit 7, a
	jr nz, .frame1

	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame1

;=@p
	ld b, $01

.frame1
;=@p
	ld a, b
	ld [hli], a
	ld a, $60
	ld [hli], a
	ld a, $00
	ld [hl], a
;=@p
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ld a, [wPartyCount]
	cp $02
	ret z

;=@p
	ld a, $02
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	push af
	ld hl, hSpriteX
	ld a, $8f
;=@p
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $78
	ld [hli], a
	ld a, $00
;=@p
	ld [hli], a
	pop af
	add $10
	ld [hli], a
	ld b, $00
	push bc
;=@p
	push hl
	ld hl, wMonStatus
	ld a, $02
	call GetPartyMonsterByte
	ld a, [hl]
	pop hl
;=@p
	pop bc
	bit 7, a
	jr nz, .frame2

	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame2

;=@p
	ld b, $01

.frame2
;=@p
	ld a, b
	ld [hli], a
	ld a, $70
	ld [hli], a
	ld a, $00
	ld [hl], a
;=@p
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


;@ def NextMapColumn(addr: hl) -> hl
;@ path: menu/screen
;@ The BG map address one column to the right, wrapping within the 32-tile row.
NextMapColumn::
;>@c11 return (addr & 0xFFE0) | ((addr + 1) & 0x1F)
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;=@c11
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	pop af
;=@c11
	ret


;@ def AddMenuBgMap(offset: hl) -> hl
;@ path: menu/screen
;@ wMenuBgMap + `offset`, wrapped to stay inside the 1 KiB BG map wMenuBgMap is in.
AddMenuBgMap::
;> sum = wMenuBgMap + offset
	ld a, [wMenuBgMap]
	add l
	ld l, a
	ld a, [wMenuBgMap + 1]
	adc h
;>@c12 return (wMenuBgMap & 0xFC00) | (sum & 0x3FF)
	and $03
	ld h, a
;=@c12
	ld a, [wMenuBgMap + 1]
	and $fc
	or h
	ld h, a
	ret


;@ def BufferAddress(offset: hl) -> hl
;@ path: menu/screen
;@ The address in wTilemapBuffer of screen offset `offset` (row * 32 + column).
BufferAddress::
;>@c19 return wTilemapBuffer + offset
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;=@c19
	ret


;@ def MenuMapAddress(offset: hl) -> hl
;@ path: menu/screen
;@ The BG map address of screen offset `offset` (row * 32 + column) for the
;@ scrolled menu screen: the row from wMenuBgMap (AddMenuBgMap), then the column
;@ with wrapping inside the row.
MenuMapAddress::
;> addr = AddMenuBgMap(offset & 0xFFE0)
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call AddMenuBgMap
;> for i in range(offset & 0x1F):
;>@c20     addr = NextMapColumn(addr)
	ld a, b
	and $1f
	jr z, .done

	ld b, a
.column
	call NextMapColumn
	dec b
;=@c20
	jr nz, .column

.done
;> return addr
	pop bc
	ret


;@ def DrawWindowToMap(window: de)
;@ path: menu/screen
;@ DrawWindow straight into the BG map (wrapping like the scrolled screen) instead
;@ of the tilemap buffer.
;@ test: skip writes VRAM
DrawWindowToMap::
;>@c13 line = addr = MenuMapAddress(mem16[window]); p = window + 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@c13
	call MenuMapAddress
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
.loop
;> while (t := mem[p]) != 0xD9:        # $D9 ends the window
	ld a, [de]
	inc de
	cp $d9
	ret z

;>     p += 1
;>     if t == 0xD8:                   # $D8: next row
	cp $d8
	jr nz, .tile

;>@c14         line = 0x9800 | ((line + 0x20) & 0x3FF)
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
	add $20
;=@c14
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, h
	and $03
;=@c14
	or $98
	ld h, a
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
;>         addr = line
	jr .loop

.tile
;>     else:
;>         WriteVRAM(t, addr)
	call WriteVRAM
;>         addr = NextMapColumn(addr)
	call NextMapColumn
	jr .loop

;@ def DrawWindow(window: de)
;@ path: menu/screen
;@ Draws a window template into wTilemapBuffer. A template is a u16 screen offset
;@ (row * 32 + column) followed by tile numbers, $D8 starting the next row and $D9
;@ ending it.
;@ test: skip reads a ROM template
DrawWindow::
;>@c15 line = addr = BufferAddress(mem16[window]); p = window + 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@c15
	call BufferAddress
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
.loop
;> while (t := mem[p]) != 0xD9:
	ld a, [de]
	inc de
	cp $d9
	ret z

;>     p += 1
;>     if t == 0xD8:
	cp $d8
	jr nz, .tile

;>@c16         line += 0x20
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
	add $20
;=@c16
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hNumber], a
;=@c16
	ld a, h
	ldh [hNumber + 1], a
;>         addr = line
	jr .loop

.tile
;>     else:
;>         mem[addr] = t
;>         addr += 1
	ld [hli], a
	jr .loop

;@ def MenuShowBuffer()
;@ path: menu/screen
;@ Copies wTilemapBuffer (18 rows of 32 tiles) to the BG map at wMenuBgMap,
;@ wrapping inside the map as the scrolled screen does.
;@ test: skip writes VRAM
MenuShowBuffer::
;> line = wMenuBgMap
	ld a, [wMenuBgMap]
	ld l, a
	ld a, [wMenuBgMap + 1]
	ld h, a
;> src = wTilemapBuffer
;>@r for row in range(18):
	ld de, wTilemapBuffer
	ld c, $12
.row
;>     addr = line
;>@c     for col in range(32):
	ld b, $20
	push hl
.col
;>         WriteVRAM(mem[src], addr)
	ld a, [de]
	call WriteVRAM
;>@c17         addr = NextMapColumn(addr)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@c17
	ld l, a
	pop af
	or l
	ld l, a
;>         src += 1
	inc de
;=@c
	dec b
	jr nz, .col

;>@c18     line = 0x9800 | ((line + 0x20) & 0x3FF)
	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
;=@c18
	or $98
	ld h, a
	pop bc
;=@r
	dec c
	jr nz, .row

	ret


DrawFamilyPlus::
	ld b, a
	ld de, $0801
	ld a, c
	cp $ff
	jr z, DrawBlankEntryText

	ld a, b
	push hl
	push af
	ld l, c
	ld h, $04
	ld de, wTextArg0
	call CopySystemText
	pop af
	ld de, wTextArg0
	call MenuAppendPlus
	pop hl
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld de, $0801
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld a, $02
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
	ld hl, far_PrintText_41
	rst $10
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


DrawTextOrBlank::
	ld a, [wTextIndex]
	cp $ff
	jr nz, MenuDrawTextTiles

DrawBlankEntryText:
	ld a, $0a
	ld [wTextIndex], a
	ld a, $04
	ld [wTextGroup], a

MenuDrawTextTiles::
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld hl, far_PrintText_41
	rst $10
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


MenuDrawNameTiles::
	push hl
	ld hl, wTextArg0
	call CopyName
	pop hl
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld de, $0401
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld a, $02
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
	ld hl, far_PrintText_41
	rst $10
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


DrawSexMark::
	and $01
	add $a7

MenuDrawCharTile::
	ld [wTextArg0], a
	ld a, $f0
	ld [$c181], a
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld a, $02
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
	ld hl, far_PrintText_41
	rst $10
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


MenuClearBuffer::
	ld hl, wTilemapBuffer
	ld bc, $0240

jr_007_6a95:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_007_6a95

	ret


ClearMenuBgMap::
	ld hl, $9800
	ld bc, $0400

jr_007_6aa4:
	ld a, $e0
	call WriteVRAMInc
	dec bc
	ld a, b
	or c
	jr nz, jr_007_6aa4

	ret


FieldMenuOpen::
	ld hl, wLinkChoice
	ld bc, $0008
	ld a, $00
	call FillMemory

SetUpMenuScreen::
	ld hl, hScrollX
	call AlignScrollToTile
	ld hl, hScrollY
	call AlignScrollToTile
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	add l
	ld l, a
	ld a, h
	adc $98
	ld h, a
	ld a, h
	and $03
	or $98
	ld h, a
	ld a, l
	ld [wMenuBgMap], a
	ld a, h
	ld [$c912], a
	call MenuClearBuffer
	call MenuShowBuffer
	call ClearMenuBgMap
	ld de, $2e0d
	ld hl, $9000
	call DecompressVRAM
	call MenuResetBlink
	ld hl, far_ClearAttrMap
	rst $10
	ld hl, wStatusViewVars
	inc [hl]
	ret


FieldMenuClose::
	call MenuClearBuffer
	call MenuShowBuffer
	ld hl, far_ClearAttrMap
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	ld hl, far_ReloadMapTileset
	rst $10
	ld hl, far_DrawMapScreen
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	call BuildStatusBar
	call DrawStatusBar
	ld hl, far_LoadFieldActorGfx
	rst $10
	ld hl, wFieldFlags
	res 1, [hl]
	xor a
	ld [wStatusViewVars], a
	ld a, [wOnGateFloor]
	or a
	ret z

	ld de, $2e15
	ld hl, $8500
	call DecompressVRAM
	ld de, $2e16
	ld hl, $8540
	call DecompressVRAM
	ld de, $2e17
	ld hl, $8580
	call DecompressVRAM
	ld de, $2e18
	ld hl, $85c0
	call DecompressVRAM
	ld de, $2e19
	ld hl, $8600
	call DecompressVRAM
	ld de, $2e1a
	ld hl, $8640
	call DecompressVRAM
	ld de, $2e1b
	ld hl, $8680
	call DecompressVRAM
	ld de, $2e1c
	ld hl, $86c0
	call DecompressVRAM
	ret


MoveListCursor::
	ld a, c
	ld [wListLastRows], a
	inc de
	inc de
	ld a, [wTextState]
	or a
	jp nz, Jump_007_6be6

	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_007_6bac

	inc hl
	ld a, [hl]
	dec a
	push af
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
	pop af
	cp c
	jr c, jr_007_6bca

	ld a, c
	dec a
	jr jr_007_6bca

jr_007_6bac:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, jr_007_6be6

	inc hl
	ld a, [hl]
	inc a
	push af
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
	pop af
	cp c
	jr c, jr_007_6bca

	ld a, $00

jr_007_6bca:
	ld [hld], a
	dec c
	cp c
	jr nz, jr_007_6c29

	ld a, [wListLastRows]
	ld c, a
	push de
	push bc
	ld a, b
	ld b, c
	call Divide8
	pop bc
	pop de
	or a
	jr z, jr_007_6c29

	dec a
	cp [hl]
	jr nc, jr_007_6c29

	ld [hl], a
	jr jr_007_6c29

Jump_007_6be6:
jr_007_6be6:
	push bc
	push de
	push hl
	call DrawListPageDigit
	pop hl
	pop de
	pop bc
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
	ld [wListLastRows], a
	ld a, b
	pop bc
	pop de
	ld c, a
	inc hl
	ld a, [hld]
	cp c
	jr nz, MoveMenuCursor

	ld a, [wListLastRows]
	inc a
	ld b, a

MoveMenuCursor::
	res 7, [hl]
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_007_6c1a

	ld a, [hl]
	dec a
	cp b
	jr c, MenuCursorStore

	dec b
	ld a, b
	jr MenuCursorStore

jr_007_6c1a:
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, MenuCursorDone

	ld a, [hl]
	inc a
	cp b
	jr c, MenuCursorStore

	ld a, $00

MenuCursorStore:
	ld [hl], a

jr_007_6c29:
	xor a
	ld [wMenuBlink], a
	push hl
	push de
	pop de
	pop hl

MenuCursorDone:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_007_6c3a

	set 7, [hl]

jr_007_6c3a:
	ld a, [hl]
	call BlinkMenuCursor
	ret


MoveMenuCursorNoSelect::
	res 7, [hl]
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_007_6c51

	ld a, [hl]
	dec a
	cp b
	jr c, jr_007_6c5f

	dec b
	ld a, b
	jr jr_007_6c5f

jr_007_6c51:
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_007_6c68

	ld a, [hl]
	inc a
	cp b
	jr c, jr_007_6c5f

	ld a, $00

jr_007_6c5f:
	ld [hl], a
	xor a
	ld [wMenuBlink], a
	push hl
	push de
	pop de
	pop hl

jr_007_6c68:
	ld a, [hl]
	call BlinkMenuCursor
	ret


MoveMenuCursorSideways::
	res 7, [hl]
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_007_6c7f

	ld a, [hl]
	dec a
	cp b
	jr c, MenuCursorStore

	dec b
	ld a, b
	jr MenuCursorStore

jr_007_6c7f:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, MenuCursorDone

	ld a, [hl]
	inc a
	cp b
	jr c, MenuCursorStore

	ld a, $00
	jr MenuCursorStore

MenuResetBlink::
	xor a
	ld [wMenuBlink], a
	ret


BlinkMenuCursor::
	ld c, a
	bit 7, a
	jr nz, MenuDrawCursorMarks

	ld a, [wMenuBlink]
	and $0f
	push af
	ld a, [wMenuBlink]
	inc a
	ld [wMenuBlink], a
	pop af
	ld a, c
	ret nz

MenuDrawCursorMarks::
	ld c, a
	ld b, $00

jr_007_6cac:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	and l
	cp $ff
	ret z

	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call MenuMapAddress
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_007_6cdc

	ld a, $e9
	bit 7, c
	jr nz, jr_007_6cdc

	ld a, [wMenuBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_007_6cdc

	ld a, $e8

jr_007_6cdc:
	call WriteVRAM
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	inc b
	jr jr_007_6cac

DrawListPageDigit::
	ld a, b
	cp c
	ret nc

	inc hl
	ld c, [hl]
	dec de
	dec de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	and l
	cp $ff
	ret z

	dec hl
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call MenuMapAddress
	pop bc
	pop de
	ld a, c
	and $7f
	add $f1
	call WriteVRAM
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	ret


DrawListMarks::
	ld a, [hli]
	push af
	push hl
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	inc de
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ld a, b
	cp c
	ld a, $ee
	jr nc, jr_007_6d45

	ld a, $e7

jr_007_6d45:
	ld [hld], a
	pop bc
	jr nc, jr_007_6d4d

	ld a, [bc]
	add $f1
	ld [hl], a

jr_007_6d4d:
	pop af

MenuDrawCursorAt::
	ld c, a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call MenuMapAddress
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_007_6d79

	ld a, [wMenuBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_007_6d79

	ld a, $e8

jr_007_6d79:
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	ret


GetViewedMonster::
	ld a, [wFieldFlags]
	bit 1, a
	jr z, jr_007_6da2

	ld a, [wCurPartyMember]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


jr_007_6da2:
	ld a, [wCurPartyMember]
	and $7f
	ret


GetViewedMonsterField::
	ld a, [wFieldFlags]
	bit 1, a
	jr z, jr_007_6db3

	call CurMonsterField
	ret


jr_007_6db3:
	ld a, [wCurPartyMember]
	call MonsterField
	ret


GetViewedMonsterByte::
	ld a, [wFieldFlags]
	bit 1, a
	jr z, jr_007_6dc5

	call GetCurMonsterByte
	ret


jr_007_6dc5:
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hl]
	ret


GetViewedMonsterWord::
	ld a, [wFieldFlags]
	bit 1, a
	jr z, jr_007_6dd8

	call GetCurMonsterWord
	ret


jr_007_6dd8:
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret


MenuAppendPlus::
	push af

jr_007_6de3:
	ld a, [de]
	inc de
	cp $f0
	jr nz, jr_007_6de3

	dec de
	ld a, $a2
	ld [de], a
	pop af
	or a
	jr z, jr_007_6df8

	inc de
	ld l, e
	ld h, d
	call ByteToDecimal
	ret


jr_007_6df8:
	ld a, $43
	ld [de], a
	inc de
	ld a, $3e
	ld [de], a
	inc de
	ld a, $4a
	ld [de], a
	inc de
	ld a, $46
	ld [de], a
	inc de
	ld a, $49
	ld [de], a
	inc de
	ld a, $56
	ld [de], a
	inc de
	ld a, $f0
	ld [de], a
	ret


MonsterSpriteGfx::
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

DrawNumber3::
	ld de, $0064
	push bc
	call DivideDigit
	pop bc
	or a
	jr z, DrawNumber2

	ld de, $0064
	call DivideDigit
	call MenuDrawDigit
	call NextMapColumn2
	ld de, $000a
	call DivideDigit
	call MenuDrawDigit
	call NextMapColumn2
	jr jr_007_701e

DrawNumber2::
	ld de, $000a
	push bc
	call DivideDigit
	pop bc
	or a
	jr z, jr_007_701e

	ld de, $000a
	call DivideDigit
	call MenuDrawDigit
	call NextMapColumn2

jr_007_701e:
	ld a, c
	call MenuDrawDigit
	ret


DivideDigit::
	push hl
	ld h, $ff

jr_007_7026:
	inc h
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jr nc, jr_007_7026

	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
	ld a, h
	pop hl
	ret


MenuDrawDigit::
	add $f0
	call WriteVRAM
	ret


NextMapColumn2::
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


MainMenuWindow::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $05, $08, $03, $09, $e0, $05, $0b, $d5, $07, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d6, $06, $05, $de, $e0
	db $09, $e3, $0b, $08, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

GoldWindow::
	db $0c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $dd
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
StatusListWindow::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $05, $08, $03, $09
	db $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $20, $21, $22, $23
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $24, $25, $26, $27
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $28, $29, $2a, $2b
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

StatusStatsWindow::
	db $07, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $3c, $3d, $3e, $3f, $e0
	db $30, $80, $12, $e4, $e0, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb
	db $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $00, $0b, $06, $e0, $e0, $e4, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $02, $d5, $03, $e0, $e0, $e4, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $00, $dd, $de, $e0, $e0, $e4, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $05, $08, $0b, $e0
	db $e0, $e4, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $0d, $de, $02, $e0, $e0, $e4, $e0, $e0
	db $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9

StatusHPWindow::
	db $a7, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $e1, $e3, $e4, $e0, $e0, $e0, $e5, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $e2, $e3, $e4, $e0, $e0, $e0, $e5, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

BlankPicWindow::
	db $55, $01, $e0, $e0, $e0, $e0
	db $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0, $e0
	db $d8, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0
	db $e0, $e0, $e0, $e0, $e0, $d9

BlankPicWindow2::
	db $35, $00, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0
	db $e0, $e0, $e0, $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0, $e0, $e0
	db $e0, $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0
	db $e0, $d9

StatusPicWindow::
	db $41, $01, $b0, $b1, $b2, $b3, $b4, $b5, $d8, $b6, $b7, $b8, $b9, $ba
	db $bb, $d8, $bc, $bd, $be, $bf, $c0, $c1, $d8, $c2, $c3, $c4, $c5, $c6, $c7, $d8
	db $c8, $c9, $ca, $cb, $cc, $cd, $d8, $ce, $cf, $d0, $d1, $d2, $d3, $d9

StatusInfoWindow::
	db $07, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $3c
	db $3d, $3e, $3f, $e0, $30, $80, $12, $e4, $e0, $e0, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $33, $34, $35, $36
	db $37, $38, $39, $3a, $3b, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $4c, $4d, $4e, $4f, $50, $51, $52, $53
	db $54, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $5b, $5c, $5d, $5e, $5f, $60, $61, $62, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $07
	db $00, $d6, $0b, $d5, $0a, $e4, $55, $56, $57, $58, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $13, $e4, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9

StatusExpWindow::
	db $a7, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $08, $d5, $0f, $0b, $e0, $de, $df, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $13, $e4, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

StatusSkillsWindow::
	db $07, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6e, $6f, $70, $71
	db $72, $73, $74, $75, $76, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $77, $78, $79, $7a, $7b, $7c, $7d, $7e
	db $7f, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $83, $84, $85, $86, $87, $88, $89, $8a, $8b, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $95, $96, $97, $98
	db $99, $9a, $9b, $9c, $9d, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5
	db $a6, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

StatusPedigreeWindow::
	db $07, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

PedigreeParent1Window::
	db $07, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $02
	db $00, $02, $e4, $8c, $8d, $8e, $8f, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $4c, $4d, $4e, $4f
	db $50, $51, $52, $53, $54, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $5e, $5f, $60, $61, $62, $63, $64, $65
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $07, $00, $d6, $0b, $d5, $0a, $e4, $90, $91, $92, $93, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

PedigreeParent2Window::
	db $27, $01
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $07
	db $09, $07, $e4, $94, $95, $96, $97, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $55, $56, $57, $58
	db $59, $5a, $5b, $5c, $5d, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $66, $67, $68, $69, $6a, $6b, $6c, $6d
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $07, $00, $d6, $0b, $d5, $0a, $e4, $98, $99, $9a, $9b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

PedigreePic2Window::
	db $55, $01
	db $8c, $8d, $8e, $8f, $90, $91, $d8, $92, $93, $94, $95, $96, $97, $d8, $98, $99
	db $9a, $9b, $9c, $9d, $d8, $9e, $9f, $a0, $a1, $a2, $a3, $d8, $a4, $a5, $a6, $a7
	db $a8, $a9, $d8, $aa, $ab, $ac, $ad, $ae, $af, $d9

SkillMonListWindow::
	db $40, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $d6, $06, $05, $de, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $ed, $d8, $fe, $e0, $20, $21, $22, $23, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $24, $25, $26, $27, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $28, $29, $2a, $2b, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

SkillListWindow::
	db $48, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89
	db $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98
	db $99, $9a, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

ItemListWindow::
	db $48, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $70, $71, $72, $73
	db $74, $75, $76, $77, $78, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97
	db $98, $99, $9a, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

ItemInfoWindow::
	db $a0, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $4c, $4d, $4e, $4f, $50, $51, $52, $53, $54, $55, $56, $57
	db $58, $59, $5a, $5b, $5c, $5d, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $5e, $5f
	db $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $6e, $6f
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9

SkillInfoWindow::
	db $60, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $4a
	db $4b, $4c, $4d, $4e, $4f, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a
	db $5b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $5c, $5d, $5e, $5f, $60, $61, $62
	db $63, $64, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $6e, $6f, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7a
	db $7b, $7c, $7d, $7e, $7f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

SkillMPWindow::
	db $c0, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $0c, $d6, $d5, $e0, $e2, $e3, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e5, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
SkillTargetListWindow::
	db $40, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $0d, $04, $09, $e0
	db $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $20, $21, $22, $23
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $24, $25, $26, $27
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $28, $29, $2a, $2b
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TargetHPWindow::
	db $a0, $01, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e1, $e3, $e4, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e5, $e0
	db $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UseDiscardWindow::
	db $00, $00
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $05, $0b, $d5, $07, $ff, $d8, $ec, $eb
	db $eb, $eb, $eb, $ed, $d8, $fe, $e0, $0c, $d6, $d5, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $02, $d5, $de, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd
	db $d9

ItemTargetListWindow::
	db $80, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $0d, $04, $09
	db $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $20, $21, $22
	db $23, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $24, $25, $26
	db $27, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $28, $29, $2a
	db $2b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TargetMPWindow::
	db $a0, $01, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e2, $e3, $e4, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e5
	db $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

DiscardYesNoWindow::
	db $00
	db $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $08, $09, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $fd, $d9

OptionWindow::
	db $05, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $09, $e3, $0b, $08, $e0, $e0, $e0, $e0, $ff, $d8, $ec, $eb
	db $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $0b, $d5, $0f, $0b
	db $e0, $d6, $e3, $02, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $01, $04, $e0, $09, $0a, $02, $d5, $0a, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $01, $04, $e0, $e3
	db $de, $00, $08, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $0e, $09, $0c, $0a, $08, $00, $de, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

MessageSpeedWindow::
	db $62, $01, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $03, $00, $d6, $0b, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $d6, $de, $09, $0d
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $f1, $e0, $f2, $e0, $f3, $e0, $f4, $e0, $f5
	db $e0, $f6, $e0, $f7, $e0, $f8, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

LineUpWindow::
	db $64, $01, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

LineUpOrderWindow::
	db $6c, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $07, $00, $d6, $0b, $d5, $0a, $e4, $3c, $3d, $3e, $3f, $e0
	db $e0, $e0, $e4, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $da, $40, $41, $42
	db $43, $e0, $db, $44, $45, $46, $47, $e0, $dc, $48, $49, $4a, $4b, $ff, $d8, $fe
	db $e0, $12, $e4, $e0, $e0, $e0, $e0, $12, $e4, $e0, $e0, $e0, $e0, $12, $e4, $e0
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9

SaveYesNoWindow::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $08, $09, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

TacticsWindow::
	db $20, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $01, $04, $00, $0a
	db $dd, $d5, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $07, $05, $0f, $d5, $02, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $01, $00, $0c, $0b
	db $05, $09, $0c, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $01, $09, $07, $07, $00, $08, $02, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TacticsMonWindow::
	db $c0, $00, $fa, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $3c, $3d, $3e, $3f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd
	db $d9

InfoPageWindow::
	db $a0, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $e0, $e0, $e4, $e0, $e0, $fb, $d8, $fe, $07, $00, $d6, $0b, $d5, $0a, $15
	db $15, $15, $15, $15, $15, $15, $15, $3c, $3d, $3e, $3f, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $0e, $09, $05, $08, $d5, $02, $15, $15, $15, $15, $15, $15, $15
	db $15, $15, $15, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $03, $00, $0a
	db $07, $e0, $e0, $e0, $07, $09, $08, $e0, $e0, $e0, $d5, $dd, $dd, $e0, $e0, $ff
	db $d8, $fe, $d6, $de, $d5, $d5, $e3, $e0, $16, $07, $09, $08, $e0, $e0, $16, $d5
	db $dd, $dd, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedBank07Data::
	db $0f, $05, $fc, $a7, $04
	db $ac, $00, $01, $24, $13, $11, $8c, $60, $ff, $9e, $86, $79, $7d, $82, $f2, $0d
	db $06, $ff, $f9, $ca, $35, $07, $04, $fd, $fc, $fe, $9f, $fe, $bf, $7f, $0b, $07
	db $2c, $03, $c7, $00, $80, $f9, $00, $25, $24, $1a, $21, $82, $7c, $e4, $02, $c0
	db $7f, $02, $40, $16, $80, $96, $7e, $fc, $54, $10, $3e, $cf, $12, $0b, $04, $07
	db $08, $07, $d9, $1f, $eb, $16, $1f, $f4, $08, $f8, $04, $f8, $f9, $1f, $0b, $20
	db $45, $07, $83, $08, $1f, $00, $45, $fa, $85, $02, $fe, $00, $02, $06, $46, $fa
	db $82, $10, $08, $4e, $07, $88, $99, $77, $11, $11, $77, $11, $77, $11, $43, $07
	db $87, $87, $67, $27, $07, $e7, $99, $99, $43, $ff, $83, $00, $ff, $00, $45, $5a
	db $95, $42, $ff, $23, $11, $77, $77, $11, $77, $11, $11, $ff, $4b, $37, $4b, $37
	db $4b, $37, $4b, $37, $81, $7f, $43, $01, $8b, $7f, $01, $7f, $01, $7f, $01, $7f
	db $01, $01, $7f, $ff, $48, $5a, $02, $44, $ff, $42, $99, $8a, $c3, $89, $00, $00
	db $7e, $bd, $c3, $ff, $3f, $c0, $46, $80, $82, $8e, $71, $06, $82, $7f, $81, $06
	db $84, $ff, $c0, $60, $10, $04, $83, $fe, $30, $18, $05, $87, $80, $c0, $e0, $b8
	db $9e, $88, $54, $06, $82, $80, $c0, $05, $83, $20, $28, $1c, $06, $82, $02, $07
	db $04, $95, $32, $11, $3a, $d8, $04, $01, $01, $ff, $aa, $fa, $aa, $bf, $a1, $80
	db $80, $b6, $80, $be, $9c, $88, $80, $7f, $45, $10, $83, $17, $0f, $00, $45, $06
	db $85, $fe, $fc, $00, $fc, $02, $46, $06, $81, $0f, $4f, $10, $81, $66, $47, $99
	db $43, $10, $87, $70, $90, $90, $f0, $70, $22, $66, $03, $42, $ff, $81, $00, $45
	db $63, $42, $7b, $81, $c6, $43, $99, $8e, $ff, $99, $ff, $ff, $66, $87, $cf, $87
	db $cf, $87, $cf, $87, $cf, $7e, $49, $81, $82, $ff, $81, $43, $ff, $81, $7e, $48
	db $63, $81, $ff, $05, $89, $22, $66, $3c, $42, $91, $ff, $81, $42, $3c, $04, $85
	db $37, $25, $25, $27, $35, $03, $85, $4e, $4a, $4e, $4a, $6a, $03, $42, $8a, $83
	db $da, $aa, $8a, $03, $82, $ea, $4a, $43, $44, $89, $00, $01, $01, $dd, $51, $9d
	db $05, $1d, $00, $45, $01, $8c, $08, $7f, $00, $dd, $15, $d5, $1d, $15, $00, $ff
	db $00, $bb, $43, $12, $93, $93, $00, $ff, $00, $ba, $aa, $b1, $a9, $a9, $00, $ff
	db $01, $81, $81, $01, $02, $04, $24, $f8, $10, $ff, $9f, $70, $00, $88, $70, $80
	db $78, $84, $78, $40, $3c, $12, $0c, $04, $02, $01, $00, $0e, $00, $11, $0e, $01
	db $1e, $21, $1e, $02, $3c, $48, $30, $20, $40, $80, $02, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $07
