INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $050", ROMX[$4000], BANK[$50]

;@ path: battle/flow
;@ Bank number byte that FarCall reads to know which bank is switched in.
BankNumber_50::
	db $50

;@ path: battle/flow
;@ Far-call entry points of bank $50 (the battle mode): 0 battle init, 1 battle frame
;@ with the link and animation work, 2 battle frame logic, 3 redraw the battle windows,
;@ 4 status icon update, 5 copy the screen buffer, 6 HP/MP numbers, 7 the message that
;@ announces an action, 8 to 10 battle messages that end a menu or the battle.
FarTable_50::
	dw InitBattleMode
	dw BattleFrame
	dw BattleFrameLogic
	dw RedrawBattleScreen
	dw UpdateStatusIcon_50
	dw CopyTilemapBufferToScreen_50
	dw PrintPanelHPMP
	dw ShowActionMessage
	dw ShowItemBrokeMessage
	dw ShowVictoryMessage
	dw ShowLinkResultMessage

;@ def BattleMenu()
;@ path: battle/menu
;@ Battle step of the command menu: runs step wCommandStep of BattleMenuSteps.
;@ test: skip jump table
BattleMenu::
;> return BattleMenuSteps[wCommandStep]()
	ld a, [wCommandStep]
	rst $00

;@ path: battle/menu
;@ Steps of the battle command menu: 0 set up, 1 draw the menu, 2 choose a command,
;@ 3 run the chosen command, 4 the turn starts, 5-7 exchange the turn data over the link,
;@ 8 done, 9 wait for a message, 10 clear a name plate and go to a stored step.
BattleMenuSteps::
	dw BattleMenuStart
	dw BattleMenuOpen
	dw BattleMenuInput
	dw BattleMenuAction
	dw BattleMenuTurnStart
	dw BattleMenuLinkReady
	dw BattleMenuLinkSend
	dw BattleMenuLinkReceive
	dw BattleMenuDone
	dw BattleMenuWaitText
	dw BattleMenuClearTiles

;@ def BattleMenuStart()
;@ path: battle/menu
;@ Prepares the command menu of a new turn: clears the menu variables, finds the first own
;@ monster that can take orders (kept in wPartyBarTiles, $FF none) and counts them (into
;@ wSkillUser), counts the enemies present (into wSkillTarget), marks every position's
;@ menu memory as fresh (bit 7), and picks the monster the tactic menu starts with
;@ (wSkillStatusPtr): the first own one, or the first that is busy with a two-turn skill.
;@ On the link master the own team is at positions 4-6.
;@ test: skip calls a routine in another bank
BattleMenuStart::
;> LoadWindowLetters_3()
	ld hl, far_LoadWindowLetters_3
	rst $10
;> FillMemory(wCommandStep, 8, 0)
	xor a
	ld hl, wCommandStep
	ld bc, $0008
	call FillMemory
;> wBattleBGMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [wBattleBGMap + 1], a
;> wPartyBarTiles[0] = 0xFF               # first monster that takes orders: none yet
	ld a, $ff
	ld [wPartyBarTiles], a
;> first = 0
	ld bc, $0300
;> if wLinkActive and wLinkFlags & 0x02:
	ld a, [wLinkActive]
	or a
	jr z, .own

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .own

;>     first = 4
	ld bc, $0304

.own
;> n = 0
	ld d, $00
.count
;>@f for pos in range(first, first + 3):
;>@c     if not CheckAutoCommand(pos) and not mem[wBattlerStatus + 8 * pos] & 0x10:
	ld a, c
	call CheckAutoCommand
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr nz, .next

;>         n += 1
	inc d
;>         if wPartyBarTiles[0] == 0xFF:
	ld a, [wPartyBarTiles]
	cp $ff
	jr nz, .next

;>             wPartyBarTiles[0] = pos
	ld a, c
	ld [wPartyBarTiles], a

.next
;=@f
	inc c
	dec b
	jr nz, .count

;> wSkillUser = n                         # number of own monsters taking orders
	ld a, d
	ld [wSkillUser], a
;> first = 4
	ld bc, $0404
;> if wLinkActive and wLinkFlags & 0x02:
	ld a, [wLinkActive]
	or a
	jr z, .enemies

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .enemies

;>     first = 0
	ld bc, $0400

.enemies
;> n = 0
	ld d, $00
.countEnemies
;> for pos in range(first, first + 4):
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .absent

;>         n += 1
	inc d

.absent
	inc c
	dec b
	jr nz, .countEnemies

;> wSkillTarget = n                       # number of enemies present
	ld a, d
	ld [wSkillTarget], a
;> for i in range(8):
;>     wBattlerMenuMemory[i] |= 0x80
	ld b, $08
	ld hl, wBattlerMenuMemory
.fresh
	set 7, [hl]
	inc hl
	dec b
	jr nz, .fresh

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> first = 4 if wLinkFlags & 0x02 else 0
	ld bc, $0300
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .start

	ld c, $04

.start
;> mem[wSkillStatusPtr] = first
	ld a, c
	ld [wSkillStatusPtr], a
.busy
;>@b for pos in range(first, first + 3):
;>     if not CheckBattlerCanAct(pos):
	ld a, c
	call CheckBattlerCanAct
	jr c, .notBusy

;>@s         s = wBattlerStatus4 + 8 * pos
	ld a, c
	ld hl, wBattlerStatus4
	call AddEightTimes
;>         if mem[s] & 0x0C and mem[s + 1] & 0xF0:     # busy with a two-turn skill
	ld a, [hli]
	and $0c
	jr z, .notBusy

	ld a, [hl]
	and $f0
	jr z, .notBusy

;>             mem[wSkillStatusPtr] = pos
;>             return
	ld a, c
	ld [wSkillStatusPtr], a
	ret

.notBusy
;=@b
	inc c
	dec b
	jr nz, .busy

	ret


;@ def BattleMenuOpen()
;@ path: battle/menu
;@ Draws the battle screen with the command menu (BattleMenuWindow) and its cursor.
;@ test: skip calls a routine in another bank
BattleMenuOpen::
;> LoadWindowLetters_1_9()
	ld hl, far_LoadWindowLetters_1_9
	rst $10
;> ClearTilemapBuffer_50()
	call ClearTilemapBuffer_50
;> DrawEnemyPictures()
	call DrawEnemyPictures
;> DrawBattlePanel()
	call DrawBattlePanel
;> DrawWindowLayout_50(BattleMenuWindow)
	ld de, BattleMenuWindow
	call DrawWindowLayout_50
;> ResetCursorBlink_50()
	call ResetCursorBlink_50
;> DrawCursorAt_50(wMenuChoice, BattleMenuCursors)
	ld de, BattleMenuCursors
	ld a, [wMenuChoice]
	call DrawCursorAt_50
;> CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
	ret


;@ def BattleMenuInput()
;@ path: battle/menu
;@ The command menu: Start switches the party panel view, the d-pad moves the cursor over
;@ the four commands (0 fight, 1 tactics, 2 item, 3 run), A chooses. Choosing tactics
;@ goes straight to the first monster that takes orders, or prints message $0002 when
;@ none can (BattleMenuNoOrders).
;@ test: skip draws to the screen
BattleMenuInput::
;> if wJoyPressed & 0x08:                 # Start: other panel view
	ld a, [wJoyPressed]
	and $08
	jr z, .menu

;>     wPanelMode = 1 if wPanelMode == 0 else 3
	ld a, [wPanelMode]
	or a
	jr nz, .back

	inc a
	jr .mode

.back
	ld a, $03

.mode
;>     DrawPanelConditions(wPanelMode)
;>     return
	ld [wPanelMode], a
	call DrawPanelConditions
	ret

.menu
;> UpdateGridCursor_50(wMenuChoice, BattleMenuCursors)
	ld de, BattleMenuCursors
	ld hl, wMenuChoice
	call UpdateGridCursor_50
;> if not wJoyPressed & 0x01:
;>     return
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> wCommandSubStep = 0
	xor a
	ld [wCommandSubStep], a
;> wMenuChoice |= 0x80
	ld hl, wMenuChoice
	set 7, [hl]
;> FillMemory(wMenuChoice2, 7, 0)
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
;> if wMenuChoice & 0x0F != 1:            # not tactics
;>     return
	ld a, [wMenuChoice]
	and $0f
	cp $01
	ret nz

;> LoadWindowLetters_3()
	ld hl, far_LoadWindowLetters_3
	rst $10
;> wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice2], a
;> if wLinkFlags & 0x02:
;>     wConfirmChoice2 = 4
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .find

	ld a, $04
	ld [wConfirmChoice2], a

.find
;> if not FindOrderableMon():
;>     return BattleMenuNoOrders()
	call FindOrderableMon
	jr nc, BattleMenuNoOrders

;> wConfirmChoice2 = wPartyBarTiles[0]    # the first monster that takes orders
	ld a, [wPartyBarTiles]
	ld [wConfirmChoice2], a
;> wCommandSubStep += 2
	ld hl, wCommandSubStep
	inc [hl]
	ld hl, wCommandSubStep
	inc [hl]
;> Call_50_5708()
	call Call_50_5708
;> wCommandSubStep += 1
	ld hl, wCommandSubStep
	inc [hl]
;> wMenuChoice2 = 0x81
	ld a, $81
	ld [wMenuChoice2], a
;> wTacticMenuRow = 1
	ld a, $01
	ld [wTacticMenuRow], a

.done
	ret


;@ path: battle/menu
;@ Cursor places (screen positions) of the four battle commands: fight and tactics in the
;@ left column, item and run in the right one.
BattleMenuCursors::
	dw $01c1                     ; row 14, column 1
	dw $0201                     ; row 16, column 1
	dw $01c7                     ; row 14, column 7
	dw $0207                     ; row 16, column 7
	dw $ffff

;@ def FindOrderableMon() -> carry
;@ path: battle/menu
;@ Carry when one of the three positions from wConfirmChoice2 on can take orders
;@ (CheckAutoCommand clears the carry for it).
;@ test: skip calls routines with side effects
FindOrderableMon::
;> pos = wConfirmChoice2
	ld a, [wConfirmChoice2]
	ld c, a
;> for i in range(3):
	ld b, $03
.loop
;>     if not CheckAutoCommand(pos):
;>         return True
	ld a, c
	call CheckAutoCommand
	jr nc, .found

;>     pos += 1
	inc c
	dec b
	jr nz, .loop

;> return False
	xor a
	ret

.found
	scf
	ret


;@ def BattleMenuNoOrders()
;@ path: battle/menu
;@ No monster can take orders: prints message $0002 in the message window and goes to step
;@ 9 (wait, then back to the menu).
;@ test: skip prints through another bank
BattleMenuNoOrders::
;> ClearTilemapBuffer_50()
	call ClearTilemapBuffer_50
;> DrawEnemyPictures()
	call DrawEnemyPictures
;> DrawBattlePanel()
	call DrawBattlePanel
;> wCommandStep = 9
	ld hl, $0002
	ld a, $09
	ld [wCommandStep], a
;> wTextGroup = 0x02
	ld a, l
	ld [wTextGroup], a
;> wTextIndex = 0x00
	ld a, h
	ld [wTextIndex], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> DrawWindowLayout_50(0x2E07)            # message window
	ld de, $2e07
	call DrawWindowLayout_50
;> CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
	ret


;@ def BattleMenuWaitText()
;@ path: battle/menu
;@ Step 9: once the message is printed, back to drawing the command menu.
BattleMenuWaitText::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_50()
	call ClearTilemapBuffer_50
;> wCommandStep = 1
	ld a, $01
	ld [wCommandStep], a
	ret


;@ def BattleMenuAction()
;@ path: battle/menu
;@ Step 3: Start switches the panel view, otherwise the chosen command runs
;@ (BattleMenuActions).
;@ test: skip jump table
BattleMenuAction::
;> if wJoyPressed & 0x08:
	ld a, [wJoyPressed]
	and $08
	jr z, .run

;>     wPanelMode = 1 if wPanelMode == 0 else 3
	ld a, [wPanelMode]
	or a
	jr nz, .back

	inc a
	jr .mode

.back
	ld a, $03

.mode
;>     DrawPanelConditions(wPanelMode)
;>     return
	ld [wPanelMode], a
	call DrawPanelConditions
	ret

.run
;> return BattleMenuActions[wMenuChoice]()
	ld a, [wMenuChoice]
	rst $00

;@ path: battle/menu
;@ The battle commands: 0 fight (everyone follows the tactics), 1 tactics, 2 item, 3 run,
;@ 4 direct orders (chosen in the tactic menu).
BattleMenuActions::
	dw FightCommand
	dw TacticsCommand
	dw ItemCommand
	dw RunCommand
	dw OrdersCommand

;@ def BattleMenuTurnStart()
;@ path: battle/menu
;@ Step 4: the commands are given. Puts the panel back to the numbers if the condition view
;@ is shown (and waits a frame); in link battles prints message $F6 with the partner's
;@ name (waiting for the partner).
;@ test: skip prints through another bank
BattleMenuTurnStart::
;> if wPanelMode:
	ld a, [wPanelMode]
	or a
	jr z, .link

;>     wPanelMode = 3
	ld a, $03
	ld [wPanelMode], a
;>     DrawPanelLetters()
;>     return
	call DrawPanelLetters
	ret

.link
;> if wLinkActive:
	ld a, [wLinkActive]
	or a
	jr z, .next

;>     wLinkNoEnd = 1
	ld a, $01
	ld [wLinkNoEnd], a
;>     name = wMonMaster if wLinkFlags & 0x02 else 0xCD21    # the partner's name
	ld de, wMonMaster
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, .copy

	ld de, wMon4Master

.copy
;>     CopyName(name, wTextArg0)
	ld hl, wTextArg0
	call CopyName
;>     ShowBattleMessage(0xF6)
	ld a, $f6
	call ShowBattleMessage
;>     ClearTilemapBuffer_50()
	call ClearTilemapBuffer_50
;>     DrawEnemyPictures()
	call DrawEnemyPictures
;>     DrawMessageWindowAndPanel()
	call DrawMessageWindowAndPanel
;>     DrawWindowLayout_50(0x2E07)
	ld de, $2e07
	call DrawWindowLayout_50
;>     CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50

.next
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
	ret


;@ def BattleMenuLinkReady()
;@ path: link/battle
;@ Step 5: in link battles tells the partner (byte $01) that the turn data is ready.
BattleMenuLinkReady::
;> if wLinkActive:
	ld a, [wLinkActive]
	or a
	jr z, .next

;>     wLinkSendByte = 1
	ld a, $01
	ld [wLinkSendByte], a

.next
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
	ret


;@ def BattleMenuLinkSend()
;@ path: link/battle
;@ Step 6: once the partner answered $01, fills wLinkTurnOut with this side's turn: the
;@ three tactics, the random seed, the menu choice (twice), the three actions (skill and
;@ target) and the three command states, and starts sending it (16 bytes) while
;@ receiving the partner's into wLinkTurnIn. The link master's own team is at positions 4-6.
;@ test: skip runs the link protocol
BattleMenuLinkSend::
;> if wLinkActive:
	ld a, [wLinkActive]
	or a
	jp z, .next

;>     if wLinkReceivedLast != 0x01:
;>         return
	ld a, [wLinkReceivedLast]
	cp $01
	ret nz

;>     first = 4 if wLinkFlags & 0x02 else 0
	ld de, wBattlerTactic
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .tactics

	ld de, wBattlerTactic + 4

.tactics
;>@t     out = wLinkTurnOut; copy(wBattlerTactic + first, out, 3)
	ld hl, wLinkTurnOut
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
;=@t
	inc de
	ld a, [de]
	ld [hli], a
;>     mem[out + 3] = wRandomHigh
	ld a, [wRandomHigh]
	ld [hli], a
;>     mem[out + 4] = wRandomLow
	ld a, [wRandomLow]
	ld [hli], a
;>     mem[out + 5] = wMenuChoice
	ld a, [wMenuChoice]
	ld [hli], a
;>     mem[out + 6] = wMenuChoice
	ld a, [wMenuChoice]
	ld [hli], a
;>     src = wBattlerAction + 2 * first
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, .masterActions

	ld de, wBattlerAction
	jr .actions

.masterActions
	ld de, wBattlerAction + 8

.actions
;>@a     copy(src, out + 7, 6)
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
;=@a
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
;=@a
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
;>     src = wBattlerOrder + first
	ld de, wBattlerOrder
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .orders

	ld de, wBattlerOrder + 4

.orders
;>@o     copy(src, out + 13, 3)
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
;=@o
	ld a, [de]
	ld [hli], a
;>     wLinkSendLength = 16
	ld a, $10
	ld [wLinkSendLength], a
	xor a
	ld [wLinkSendLength + 1], a
;>     wLinkSendPtr = wLinkTurnOut
	ld hl, wLinkTurnOut
	ld a, l
	ld [wLinkSendPtr], a
	ld a, h
	ld [wLinkSendPtr + 1], a
;>     wLinkRecvPtr = wLinkTurnIn
	ld hl, wLinkTurnIn
	ld a, l
	ld [wLinkRecvPtr], a
	ld a, h
	ld [wLinkRecvPtr + 1], a
;>     wLinkSendByte = 0xFF
	ld a, $ff
	ld [wLinkSendByte], a

.next
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
	ret


;@ def BattleMenuLinkReceive()
;@ path: link/battle
;@ Step 7: once the partner's turn data has arrived (end byte $F0), copies its tactics,
;@ actions and command states to the partner's positions and its order flag to
;@ wOrderFlag0/1. Both sides then use the same random seed: the slave's (the slave keeps
;@ its own, the master takes it from the data).
;@ test: skip runs the link protocol
BattleMenuLinkReceive::
;> if wLinkActive:
	ld a, [wLinkActive]
	or a
	jp z, .next

;>     if wLinkReceivedLast != 0xF0:
;>         return
	ld a, [wLinkReceivedLast]
	cp $f0
	ret nz

;>     wLinkSendByte = 0
	xor a
	ld [wLinkSendByte], a
;>     other = 0 if wLinkFlags & 0x02 else 4         # the partner's positions
	ld de, wBattlerTactic + 4
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .tactics

	ld de, wBattlerTactic

.tactics
;>@t     inp = wLinkTurnIn; copy(inp, wBattlerTactic + other, 3)
	ld hl, wLinkTurnIn
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
;=@t
	inc de
	ld a, [hli]
	ld [de], a
	inc hl
	inc hl
;>     wOrderFlag0 = mem[inp + 5]
	ld a, [hli]
	ld [wOrderFlag0], a
;>     wOrderFlag1 = mem[inp + 6]
	ld a, [hli]
	ld [wOrderFlag1], a
;>     dest = wBattlerAction + 2 * other
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, .masterActions

	ld de, wBattlerAction + 8
	jr .actions

.masterActions
	ld de, wBattlerAction

.actions
;>@a     copy(inp + 7, dest, 6)
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
;=@a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
;=@a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
;>     dest = wBattlerOrder + other
	ld de, wBattlerOrder + 4
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .orders

	ld de, wBattlerOrder

.orders
;>@o     copy(inp + 13, dest, 3)
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
;=@o
	ld a, [hli]
	ld [de], a
;>     if not wLinkFlags & 0x02:          # slave: keep the own seed, store it
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, .master

;>         wLinkRandom = wRandomHigh | wRandomLow << 8
	ld a, [wRandomHigh]
	ld [wLinkRandom], a
	ld a, [wRandomLow]
	ld [wLinkRandom + 1], a
;>         mem[0xC1EF] = wMenuChoice
	ld a, [wMenuChoice]
	ld [$c1ef], a
;>         wOrderFlag0 = wMenuChoice
	ld a, [wMenuChoice]
	ld [wOrderFlag0], a
	jr .next

.master
;>     else:                              # master: take the slave's seed
;>         wRandomHigh = lo(wLinkRandom)
	ld a, [wLinkRandom]
	ld [wRandomHigh], a
;>         wRandomLow = hi(wLinkRandom)
	ld a, [wLinkRandom + 1]
	ld [wRandomLow], a
;>         mem[0xC1F0] = wMenuChoice
	ld a, [wMenuChoice]
	ld [$c1f0], a
;>         wOrderFlag1 = wMenuChoice
	ld a, [wMenuChoice]
	ld [wOrderFlag1], a

.next
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
	ret


;@ def BattleMenuDone()
;@ path: battle/menu
;@ Step 8: the turn's commands are complete: redraws the screen with the message window,
;@ resets the menu and goes on to the next battle step (the turn runs).
;@ test: skip calls a routine in another bank
BattleMenuDone::
;> Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;> ClearTilemapBuffer_50()
	call ClearTilemapBuffer_50
;> DrawEnemyPictures()
	call DrawEnemyPictures
;> DrawMessageWindowAndPanel()
	call DrawMessageWindowAndPanel
;> CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
;> wSkillUser = 0
	xor a
	ld [wSkillUser], a
;> wLinkNoEnd = 0
	xor a
	ld [wLinkNoEnd], a
;> wCommandStep = 0
	xor a
	ld [wCommandStep], a
;> wBattleStep += 1
	ld hl, wBattleStep
	inc [hl]
	ret


;@ def FightCommand()
;@ path: battle/menu
;@ The fight command: runs step wCommandSubStep of FightCommandSteps.
;@ test: skip jump table
FightCommand::
;> return FightCommandSteps[wCommandSubStep]()
	ld a, [wCommandSubStep]
	rst $00

;@ path: battle/menu
;@ Steps of the fight command.
FightCommandSteps::
	dw FightCommandStart
	dw FightCommandEnd

;@ def FightCommandStart()
;@ path: battle/menu
;@ Fight: every own monster in the fight counts as decided (its tactic picks the action),
;@ empty places get $FF; no item is used.
FightCommandStart::
;> wCommandSubStep += 1
	ld hl, wCommandSubStep
	inc [hl]
;> pos = 0; n = wPartyBattlers
	ld a, [wPartyBattlers]
	ld b, a
	ld c, $00
	ld hl, wBattlerOrder
;> if wLinkFlags & 0x02:                  # the link master's team is at 4-6
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .own

;>     pos = 4; n = wEnemyCount
	ld a, [wEnemyCount]
	ld b, a
	ld c, $04
	ld hl, wBattlerOrder + 4

.own
;> wBattleTemp = pos
	ld a, c
	ld [wBattleTemp], a
;> wBattleTempHigh = n
	ld a, b
	ld [wBattleTempHigh], a
.loop
;>@l for p in range(pos, pos + n):
;>     if CheckBattlerPresent(p):
	ld a, c
	call CheckBattlerPresent
	jr c, .empty

;>@a         wBattlerOrder[p] = 0xFF
;>     else:
;>         wBattlerOrder[p] = 1
	ld [hl], $01
	jr .next

.empty
;=@a
	ld [hl], $ff

.next
;=@l
	inc hl
	inc c
	dec b
	jr nz, .loop

;> wBattleItemTarget = 0xFF
	ld a, $ff
	ld [wBattleItemTarget], a
;> wBattleItemEffect = 0xFF
	ld a, $ff
	ld [wBattleItemEffect], a
	ret


;@ def FightCommandEnd()
;@ path: battle/menu
;@ Fight, second step: the commands are complete (command menu step 4).
FightCommandEnd::
;> wCommandStep = 4
	ld a, $04
	ld [wCommandStep], a
;> wCommandSubStep = 0
	xor a
	ld [wCommandSubStep], a
	ret


;@ def TacticsCommand()
;@ path: battle/tactics
;@ The tactics command: runs step wCommandSubStep of TacticsCommandSteps. The battle menu
;@ enters it at step 3 with one monster after the other (wMenuChoice2 = $81); steps 1-2
;@ (a "whole party / one by one" choice) are only reached by going back.
;@ test: skip jump table
TacticsCommand::
;> return TacticsCommandSteps[wCommandSubStep]()
	ld a, [wCommandSubStep]
	rst $00

;@ path: battle/tactics
;@ Steps of the tactics command: 0 back to the menu, 1 back to the menu (redrawn), 2 choose
;@ whole party or one monster, 3 open the tactic window for a monster, 4 choose its
;@ tactic, 5 done.
TacticsCommandSteps::
	dw TacticsCommandBack
	dw TacticsCommandOpen
	dw TacticsWhoInput
	dw TacticsMenuOpen
	dw TacticsMenuInput
	dw TacticsCommandEnd

;@ def TacticsCommandBack()
;@ path: battle/tactics
;@ Back to the start of the command menu.
TacticsCommandBack::
;> wCommandStep = 0
	ld a, $00
	ld [wCommandStep], a
	ret


;@ def UnusedTacticStepFar()
;@ path: unused
;@ Unused: far call of entry 6 of bank $55, then the next tactics step.
;@ test: skip calls a routine in another bank
UnusedTacticStepFar::
;> far_call(0x55, 0x06)
	ld hl, $5506
	rst $10
;> wCommandSubStep += 1
	ld hl, wCommandSubStep
	inc [hl]
	ret

;@ def TacticsCommandOpen()
;@ path: battle/tactics
;@ Leaving the tactics: redraws the battle screen with the command menu window and starts
;@ the command menu over.
;@ test: skip reads layouts from ROM
TacticsCommandOpen::
;> ClearTilemapBuffer_50()
	call ClearTilemapBuffer_50
;> DrawEnemyPictures()
	call DrawEnemyPictures
;> DrawBattlePanel()
	call DrawBattlePanel
;> wCommandStep = 0
	ld a, $00
	ld [wCommandStep], a
;> DrawWindowLayout_50(BattleMenuWindow)
	ld de, BattleMenuWindow
	call DrawWindowLayout_50
	ret


;@ def UnusedTacticWhoMenu()
;@ path: unused
;@ Unused tactics step: draws TacticWhoWindow with the cursor on wTacticMenuRow (marked
;@ chosen) and goes to the next step.
;@ test: skip reads layouts from ROM
UnusedTacticWhoMenu::
;> DrawWindowLayout_50(TacticWhoWindow)
	ld de, TacticWhoWindow
	call DrawWindowLayout_50
;> ResetCursorBlink_50()
	call ResetCursorBlink_50
;> wMenuChoice2 = wTacticMenuRow | 0x80
	ld de, TacticWhoCursors
	ld a, [wTacticMenuRow]
	set 7, a
	ld [wMenuChoice2], a
;> DrawCursorAt_50(wMenuChoice2, TacticWhoCursors)
	call DrawCursorAt_50
;> CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
;> wCommandSubStep += 1
	ld hl, wCommandSubStep
	inc [hl]
	ret

;@ def TacticsWhoInput()
;@ path: battle/tactics
;@ Chooses between the whole party (row 0) and one monster after the other (row 1); B goes
;@ back to the menu, A remembers the row in wTacticMenuRow and opens the tactic window,
;@ starting with the monster in wSkillStatusPtr.
;@ test: skip draws to the screen
TacticsWhoInput::
;> UpdateMenuCursor_50(wMenuChoice2, 2, TacticWhoCursors)
	ld de, TacticWhoCursors
	ld hl, wMenuChoice2
	ld b, $02
	call UpdateMenuCursor_50
;> if wJoyPressed & 0x02:                 # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .a

;>     wCommandStep = 1
	ld a, $01
	ld [wCommandStep], a
	jr .done

.a
;> elif wJoyPressed & 0x01:               # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     wTacticMenuRow = wMenuChoice2 & 0x7F
	ld a, [wMenuChoice2]
	res 7, a
	ld [wTacticMenuRow], a
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wCommandSubStep += 1
	ld hl, wCommandSubStep
	inc [hl]
;>     wConfirmChoice2 = mem[wSkillStatusPtr]
	ld a, [wSkillStatusPtr]
	ld [wConfirmChoice2], a
;>     Call_50_5708()
	call Call_50_5708

.done
	ret


;@ path: battle/tactics
;@ Cursor places of the whole party / one by one choice (the left column of the battle
;@ menu).
TacticWhoCursors::
	dw $01c1                     ; row 14, column 1
	dw $0201                     ; row 16, column 1
	dw $ffff

;@ def TacticsMenuOpen()
;@ path: battle/tactics
;@ Opens the tactic window for monster wConfirmChoice2 (skipping those that can't take
;@ orders; after the last one the tactics are done): its name plate, the four tactics,
;@ the cursor on its current tactic. wTacticSlot says where the choice will be stored:
;@ wTeamTactic for the whole party, else wMonTactics of the monster.
;@ test: skip prints through another bank
TacticsMenuOpen::
;> ClearTilemapBuffer_50()
	call ClearTilemapBuffer_50
;> DrawEnemyPictures()
	call DrawEnemyPictures
;> DrawBattlePanel()
	call DrawBattlePanel
;> if not CheckAutoCommand(wConfirmChoice2):  # it takes orders
	ld hl, wMonName
	ld a, [wConfirmChoice2]
	call CheckAutoCommand
	jr c, .next

;>     PrintNameToTiles_50(0x96C0, PartyMonsterField(wConfirmChoice2, wMonName))
	ld a, [wConfirmChoice2]
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, $96c0
	call PrintNameToTiles_50
;>     if wMenuChoice2 == 0x81:
;>         DrawWindowLayout_50(TacticNameWindow)
	ld de, TacticNameWindow
	ld a, [wMenuChoice2]
	cp $81
	call z, DrawWindowLayout_50
;>     DrawWindowLayout_50(TacticWindow)
	ld de, TacticWindow
	call DrawWindowLayout_50
;>     if wBattleType == 2:               # tournament
;>         DrawTournamentTactic()
	ld a, [wBattleType]
	cp $02
	call z, DrawTournamentTactic
;>     if wTacticMenuRow == 0:
	ld a, [wTacticMenuRow]
	or a
	jr z, .team

;>@team         wTacticSlot = 1
;>     elif wConfirmChoice2 & 3 == 0:
	ld a, [wConfirmChoice2]
	and $03
	or a
	jr z, .first

;>@first         wTacticSlot = 2
;>     elif wConfirmChoice2 & 3 == 1:
	cp $01
	jr z, .second

;>@second         wTacticSlot = 3
;>     else:
;>         wTacticSlot = 4
	ld a, $04
	ld [wTacticSlot], a
;>     t = mem[wTacticMenuRow + wTacticSlot]  # wTeamTactic or wMonTactics[slot - 2]
	ld a, [wMonTactics + 2]
	jr .cursor

.team
;=@team
	ld a, $01
	ld [wTacticSlot], a
	ld a, [wTeamTactic]
	jr .cursor

.first
;=@first
	ld a, $02
	ld [wTacticSlot], a
	ld a, [wMonTactics]
	jr .cursor

.second
;=@second
	ld a, $03
	ld [wTacticSlot], a
	ld a, [wMonTactics + 1]

.cursor
;>     wConfirmChoice = t | 0x80
	set 7, a
	ld [wConfirmChoice], a
;>     ResetCursorBlink_50()
	call ResetCursorBlink_50
;>     DrawCursorAt_50(wConfirmChoice, TacticCursors)
	ld de, TacticCursors
	ld a, [wConfirmChoice]
	call DrawCursorAt_50
;>     CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
;>     wCommandSubStep += 1
	ld hl, wCommandSubStep
	inc [hl]
	ret

.next
;> else:
;>     wConfirmChoice2 += 1               # the next monster
	ld a, [wConfirmChoice2]
	inc a
	ld [wConfirmChoice2], a
;>     if wConfirmChoice2 & 3 < 3:
;>         return TacticsMenuOpen()
	and $03
	cp $03
	jp c, TacticsMenuOpen

;>     wCommandSubStep += 2               # all done
	ld hl, wCommandSubStep
	inc [hl]
	inc [hl]
	ret


;@ def DrawTournamentTactic()
;@ path: battle/tactics
;@ In tournament battles (not link) the fourth row of the tactic window is a fourth tactic
;@ instead of direct orders: its label (TournamentTacticTiles) is written over row 16.
DrawTournamentTactic::
;> if wLinkActive:
;>     return
	ld a, [wLinkActive]
	or a
	ret nz

;>@c copy(TournamentTacticTiles, TilemapBufferAddr_50(0x0202), 8)
	ld hl, $0202
	call TilemapBufferAddr_50
	ld de, TournamentTacticTiles
	ld b, $08
.loop
;=@c
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, .loop

	ret


;@ path: battle/tactics
;@ Tiles of the fourth tactic's label in tournament battles (row 16, column 2).
TournamentTacticTiles::
	db $8f, $90, $e0, $d6, $e3, $e0, $d6, $98

;@ def TacticsMenuInput()
;@ path: battle/tactics
;@ The tactic window: Up / Down choose one of the four rows, A takes it
;@ (TacticMenuConfirm). B goes back to the previous monster that takes orders (its
;@ choice undone), or out of the tactics from the first one.
;@ test: skip draws to the screen
TacticsMenuInput::
;> UpdateMenuCursor_50(wConfirmChoice, 4, TacticCursors)
	ld de, TacticCursors
	ld hl, wConfirmChoice
	ld b, $04
	call UpdateMenuCursor_50
;> if not wJoyPressed & 0x02:
;>     return TacticMenuConfirm()
	ld a, [wJoyPressed]
	bit 1, a
	jr z, TacticMenuConfirm

.back
;> while True:
;>     LoadWindowLetters_5()
	ld hl, far_LoadWindowLetters_5
	rst $10
;>@out     if not (wMenuChoice2 == 0x80 or wConfirmChoice2 == wPartyBarTiles[0] or wConfirmChoice2 & 3 == 0):
	ld a, [wMenuChoice2]
	cp $80
	jr z, .leave

	ld a, [wConfirmChoice2]
	ld hl, wPartyBarTiles
	cp [hl]
;=@out
	jr z, .leave

	and $03
	or a
	jr z, .leave

;>         wConfirmChoice2 -= 1           # the previous monster
	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
;>         if CheckAutoCommand(wConfirmChoice2):
;>             continue
	call CheckAutoCommand
	jr c, .back

;>@o         order = wBattlerOrder + wConfirmChoice2
	ld a, [wConfirmChoice2]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@o
	ld h, a
;>         if mem[order] != 1:
;>             continue
	ld a, [hl]
	cp $01
	jr nz, .back

;>         mem[order] = 0                 # undone
	ld a, $00
	ld [hl], a
;>@c         mem16[wBattlerAction + 2 * wConfirmChoice2] = 0xFFFF
	ld a, [wConfirmChoice2]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@c
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], a
;>         wCommandSubStep -= 1           # its tactic window again
	ld hl, wCommandSubStep
	dec [hl]
;>         wConfirmChoice = 0
;>         return
	xor a
	ld [wConfirmChoice], a
	jp Jump_050_4714

.leave
;>     else:
;>         ClearMonAction()
	call ClearMonAction
;>         wCommandSubStep -= 3           # back to the menu
;>         return
	ld hl, wCommandSubStep
	dec [hl]
	dec [hl]
	dec [hl]
	jp Jump_050_4714


;@ def UnusedTacticBack()
;@ path: unused
;@ Unused: resets the command menu to step 1 and redraws it.
;@ test: skip draws to the screen
UnusedTacticBack::
;> wCommandSubStep = 0
	ld a, $00
	ld [wCommandSubStep], a
;> wCommandStep = 1
	ld a, $01
	ld [wCommandStep], a
;> Call_50_5708()
	call Call_50_5708
;> return BattleMenuOpen()
	jp BattleMenuOpen

	jp Jump_050_4714

;@ def TacticMenuConfirm()
;@ path: battle/tactics
;@ A in the tactic window: stores the chosen tactic (wTacticMenuRow + wTacticSlot). Row 3
;@ means direct orders (TacticDirectOrders). For the whole party every monster that can
;@ act gets it (SetTeamTactic); one by one, the monster gets it and the window opens for
;@ the next one (SetMonTactic).
;@ test: skip draws to the screen
TacticMenuConfirm::
;> if not wJoyPressed & 0x01:
;>     return
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_4714

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;>@s t = wConfirmChoice & 0x7F
	ld a, [wTacticSlot]
	ld hl, wTacticMenuRow
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld a, [wConfirmChoice]
	res 7, a
;> mem[wTacticMenuRow + wTacticSlot] = t
	ld [hl], a
;> if t == 3:                             # direct orders
;>     return TacticDirectOrders()
	cp $03
	jp z, TacticDirectOrders

;> if wMenuChoice2 == 0x80:               # the whole party
;>     return SetTeamTactic()
	ld a, [wMenuChoice2]
	cp $80
	jr z, SetTeamTactic

;> SetMonTactic()

;@ def SetMonTactic()
;@ path: battle/tactics
;@ Gives monster wConfirmChoice2 the tactic in wConfirmChoice (it counts as decided), then
;@ moves on to the next monster's tactic window, or ends the tactics after the last.
;@ test: skip calls routines with side effects
SetMonTactic::
;>@o wBattlerOrder[wConfirmChoice2] = 1
	ld a, [wConfirmChoice2]
	ld de, wBattlerOrder
	add e
	ld e, a
	ld a, $00
	adc d
;=@o
	ld d, a
	ld a, $01
	ld [de], a
;>@t wBattlerTactic[wConfirmChoice2] = wConfirmChoice & 0x7F
	ld a, [wConfirmChoice2]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
;=@t
	ld h, a
	ld a, [wConfirmChoice]
	ld [hl], a
	res 7, [hl]
;> RememberTactic(wBattlerTactic[wConfirmChoice2])
	ld a, [hl]
	call RememberTactic
;> wConfirmChoice2 += 1
	ld a, [wConfirmChoice2]
	inc a
	ld [wConfirmChoice2], a
;> if not wLinkFlags & 0x02:
	push af
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, .master

;>     count = wPartyBattlers
	ld hl, wPartyBattlers
	jr .compare

.master
;> else:
;>     count = wEnemyCount
	ld hl, wEnemyCount

.compare
;> if wConfirmChoice2 & 3 == count:       # the last one
;>     return TacticsMarkUnable()
	pop af
	and $03
	cp [hl]
	jr z, TacticsMarkUnable

;> wCommandSubStep -= 1                   # the next monster's window
	ld hl, wCommandSubStep
	dec [hl]
;> wConfirmChoice = 0
	xor a
	ld [wConfirmChoice], a
	jp Jump_050_4714


;@ def SetTeamTactic()
;@ path: battle/tactics
;@ The whole party gets the tactic in wConfirmChoice: walks the own positions until
;@ wSkillUser monsters (those taking orders) are done; held monsters (status bit 4) and
;@ undecided ones count as decided, the undecided ones get the tactic. Then
;@ TacticsMarkUnable.
;@ test: skip calls routines with side effects
SetTeamTactic::
;> n = wSkillUser
;> p = 0
	ld a, [wSkillUser]
	ld b, a
	ld c, $00
;> if wLinkFlags & 0x02:
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .loop

;>     p = 4
	ld c, $04

.loop
;> while True:
;>@h     if CheckBattlerCanAct(p) or mem[wBattlerStatus + 8 * p] & 0x10:   # can't act, or held
	ld a, c
	call CheckBattlerCanAct
	jr c, .skip

;=@h
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr z, .give

;>@m         if not CheckBattlerCanAct(p): wBattlerOrder[p] = 1     # held: decided, not counted
	ld a, c
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld [hl], $01

.skip
;>         p += 1
;>         continue
	inc c
	jr .loop

.give
;>@g     if wBattlerOrder[p] == 0:
	ld a, c
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@g
	ld h, a
	ld a, [hl]
	cp $00
	jr nz, .counted

;>         wBattlerOrder[p] = 1
	ld a, $01
	ld [hl], a
;>@w         wBattlerTactic[p] = wConfirmChoice & 0x7F
	ld a, c
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
;=@w
	ld h, a
	ld a, [wConfirmChoice]
	res 7, a
	ld [hl], a
;>         RememberTactic(wBattlerTactic[p])
	ld a, [hl]
	call RememberTactic

.counted
;>     p += 1; n -= 1
;>     if n == 0: break
	inc c
	dec b
	jr nz, .loop

;> TacticsMarkUnable()

;@ def TacticsMarkUnable()
;@ path: battle/tactics
;@ End of the tactic choice: own monsters that are busy or held (status 0 bit 4, status 3
;@ bits 0-5, status 4 bit 2, status 5 bits 6-7 or bit 4) count as decided too.
;@ test: skip calls routines with side effects
TacticsMarkUnable::
;> wCommandSubStep += 1
	ld hl, wCommandSubStep
	inc [hl]
;> pos = 4 if wLinkFlags & 0x02 else 0
	ld bc, $0400
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .loop

	ld c, $04

.loop
;>@f for p in range(pos, pos + 4):
;>     if not CheckBattlerPresent(p):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@s         s = wBattlerStatus + 8 * p
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
;>@c         if mem[s] & 0x10 or mem[s + 3] & 0x3F or mem[s + 4] & 0x04 or mem[s + 5] & 0xD0:
	bit 4, [hl]
	jr nz, .mark

	ld de, $0003
	add hl, de
	ld a, [hli]
	and $3f
;=@c
	jr nz, .mark

	bit 2, [hl]
	jr nz, .mark

	inc hl
	ld a, [hl]
	and $c0
;=@c
	jr nz, .mark

	bit 4, [hl]
	jr z, .next

.mark
;>             MarkOrderChosen(p)
	call MarkOrderChosen

.next
;=@f
	inc c
	dec b
	jr nz, .loop

	jr Jump_050_4714

;@ def MarkOrderChosen(pos: c)
;@ path: battle/tactics
;@ Marks battle position `pos` as decided for this turn (wBattlerOrder = 1).
MarkOrderChosen::
;>@m wBattlerOrder[pos] = 1
	ld a, c
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld [hl], $01
	ret

Jump_050_4714:
	ret


;@ path: battle/tactics
;@ Cursor places of the four rows of the tactic window (rows 10, 12, 14, 16).
TacticCursors::
	dw $0141                     ; row 10, column 1
	dw $0181                     ; row 12, column 1
	dw $01c1                     ; row 14, column 1
	dw $0201                     ; row 16, column 1
	dw $ffff

;@ def TacticDirectOrders()
;@ path: battle/tactics
;@ The fourth tactic row: direct orders for the monster. In tournament battles (not link)
;@ the row is an ordinary tactic instead (SetMonTactic). Otherwise the battle menu goes on
;@ with command 4 (OrdersCommand) for this monster; with more than one monster taking
;@ orders its name plate is already drawn (wOrderNameShown).
;@ test: skip calls routines with side effects
TacticDirectOrders::
;> if not IsCommandTacticBanned():
;>     return SetMonTactic()
	call IsCommandTacticBanned
	jp z, SetMonTactic

;> wMenuChoice = 4
	ld a, $04
	ld [wMenuChoice], a
;> wOrderStep = 0
	xor a
	ld [wOrderStep], a
;> OrdersStart()
	call OrdersStart
;> if wSkillUser == 1:                    # only one monster takes orders
;>     return
	ld a, [wSkillUser]
	cp $01
	ret z

;> wOrderNameShown = 1
	ld a, $01
	ld [wOrderNameShown], a
	ret


;@ def RememberTactic(tactic: a)
;@ path: battle/tactics
;@ Remembers the tactic of monster wConfirmChoice2 for its record (wBattlerSexBits67);
;@ direct orders (3) are not remembered.
RememberTactic::
;> if tactic == 3:
;>     return
	cp $03
	jr z, .done

;>@r wBattlerSexBits67[wConfirmChoice2] = tactic
	push af
	ld hl, wBattlerSexBits67
	ld a, [wConfirmChoice2]
	add l
	ld l, a
	ld a, $00
;=@r
	adc h
	ld h, a
	pop af
	ld [hl], a

.done
	ret


;@ def TacticsCommandEnd()
;@ path: battle/tactics
;@ Tactics done: every own monster still undecided counts as decided, the commands are
;@ complete (menu step 4), no item is used.
TacticsCommandEnd::
;> MarkUndecidedChosen()
	call MarkUndecidedChosen
;> ClearTilemapBuffer_50()
	call ClearTilemapBuffer_50
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> wBattleItemTarget = 0xFF
	ld a, $ff
	ld [wBattleItemTarget], a
;> wBattleItemEffect = 0xFF
	ld [wBattleItemEffect], a
	ret


;@ def MarkUndecidedChosen()
;@ path: battle/tactics
;@ Every present own monster with wBattlerOrder 0 (undecided) becomes decided (1).
MarkUndecidedChosen::
;> if wLinkActive and wLinkFlags & 0x02:
	ld a, [wLinkActive]
	or a
	jr z, .own

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .own

;>     pos = 4
	ld c, $04
	jr .count

.own
;> else:
;>     pos = 0
	ld c, $00

.count
;>@f for p in range(pos, pos + 3):
	ld b, $03
.loop
;>     if not CheckBattlerPresent(p) and wBattlerOrder[p] == 0:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@o         wBattlerOrder[p] = 1
	ld a, c
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@o
	ld h, a
	ld a, [hl]
	or a
	jr nz, .next

	ld [hl], $01

.next
;=@f
	inc c
	dec b
	jr nz, .loop

	ret


OrdersCommand::
	ld a, [wOrderStep]
	rst $00

OrdersSteps::
	dw OrdersStart
	dw OrdersOpen
	dw OrdersInput
	dw SkillListOpen
	dw OrderSkillInput
	dw AllyTargetOpen
	dw AllyTargetInput
	dw EnemyTargetOpen
	dw EnemyTargetInput
	dw OrdersWaitText
	dw OrdersWaitTextBack
	dw OrdersNextMon

OrdersSkipMon::
	ld hl, wConfirmChoice2
	inc [hl]
	ld a, [wConfirmChoice2]
	and $03
	cp $03
	jp z, Jump_050_4f36

OrdersStart::
	ld a, [wConfirmChoice2]
	call CheckBattlerCanAct
	jr c, OrdersSkipMon

	ld a, [wConfirmChoice2]
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr nz, OrdersSkipMon

	inc hl
	bit 4, [hl]
	jr nz, OrdersSkipMon

	ld hl, far_LoadWindowLetters_4
	rst $10
	ld hl, far_LoadWindowLetters_3
	rst $10
	xor a
	ld hl, wMenuChoice3
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [wBattleTemp], a
	ld a, [wConfirmChoice2]
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 2, [hl]
	jr z, jr_050_47ff

	ld a, $01
	ld [wLinkPartnerChoice], a

jr_050_47ff:
	ld a, [hl]
	and $03
	ld [wLinkRefused], a
	ld a, [hl]
	swap a
	and $03
	ld [wMenuChoice3], a
	ld hl, wOrderStep
	inc [hl]
	xor a
	ld [wOrderNameShown], a
	ret


OrdersOpen::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld a, [wOrderNameShown]
	or a
	jr nz, jr_050_4836

	ld hl, wMonName
	ld a, [wConfirmChoice2]
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, $96c0
	call PrintNameToTiles_50

jr_050_4836:
	ld de, $6f49
	ld a, [wMenuChoice2]
	call DrawWindowLayout_50
	ld de, $74ba
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $496d
	ld a, [wMenuChoice3]
	set 7, a
	ld [wMenuChoice3], a
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wOrderStep
	inc [hl]
	ret


OrdersInput::
	ld de, $496d
	ld hl, wMenuChoice3
	ld b, $03
	call UpdateMenuCursor_50
	ld a, [wJoyPressed]
	bit 1, a
	jr z, OrdersChoose

jr_050_4870:
	ld a, [wMenuChoice2]
	cp $80
	jr nz, OrdersBackToTactics

	ld a, [wConfirmChoice2]
	and $03
	or a
	jr z, OrdersBackToTactics

	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
	call CheckAutoCommand
	jr c, jr_050_4870

	ld a, [wConfirmChoice2]
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr nz, jr_050_4870

	inc hl
	bit 4, [hl]
	jr nz, jr_050_4870

	ld a, [wConfirmChoice2]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $00
	ld [hl], a
	xor a
	ld [wOrderStep], a
	call ClearMonAction
	call OrdersStart
	ret


OrdersBackToTactics::
	ld hl, far_LoadWindowLetters_3
	rst $10
	ld a, $81
	ld [wMenuChoice], a
	ld a, $03
	ld [wCommandSubStep], a
	ld a, [wConfirmChoice]
	res 7, a
	ld [wConfirmChoice], a
	xor a
	ld [wOrderStep], a
	jp TacticsMenuOpen


	db $c9

OrdersChoose::
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_496c

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	and $03
	swap a
	ld b, a
	ld a, [wConfirmChoice2]
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $0f
	or b
	ld [hl], a
	ld a, [wMenuChoice3]
	cp $81
	jr z, OrdersSkill

	cp $80
	jr z, OrdersAttack

	ld b, $8d
	ld a, [wConfirmChoice2]
	ld c, a

OrdersDecided::
	call SetActionSkillTarget
	call MarkOrderGiven
	ld a, $0b
	ld [wOrderStep], a
	ret


OrdersAttack::
	ld a, $3a
	ld [wSkillId], a
	ld a, [wConfirmChoice2]
	and $04
	xor $04
	call CountPresentOnSide
	ld a, b
	ld b, $3a
	cp $01
	jr z, OrdersDecided

	call SetActionSkill
	ld a, $07
	ld [wOrderStep], a
	ret


OrdersSkill::
	call CountUsableSkills
	ld a, [wBattlerReload]
	or a
	jr z, jr_050_4945

	ld hl, wOrderStep
	inc [hl]
	ret


jr_050_4945:
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $0202
	ld a, $09
	ld [wOrderStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


Jump_050_496c:
	ret


CommandCursors::
	db $81, $01, $c1, $01, $01, $02, $ff, $ff

CountUsableSkills::
	ld a, [wConfirmChoice2]
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a
	ld [wBattlerReload], a
	ld bc, $0800

jr_050_498a:
	ld a, [hli]
	or a
	jr z, jr_050_49a7

	ld a, [hl]
	cp $37
	jr z, jr_050_49a2

	cp $38
	jr z, jr_050_49a2

	cp $7e
	jr z, jr_050_49a2

	ld a, [wBattlerReload]
	inc a
	ld [wBattlerReload], a

jr_050_49a2:
	inc hl
	inc c
	dec b
	jr nz, jr_050_498a

jr_050_49a7:
	ld a, c
	ld [wBattleListCount], a
	ret


SkillListOpen::
	call PrintSkillPage
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $74f4
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $4cca
	ld b, $04
	ld a, [wBattleListCount]
	ld c, a
	ld hl, wLinkRefused
	call DrawListCursor_50
	call CopyTilemapBufferToScreen_50
	ld hl, wOrderStep
	inc [hl]
	ret


PrintSkillPage::
	ld a, [wConfirmChoice2]
	swap a
	ld de, $dc65
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [wLinkPartnerChoice]
	add a
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $88c0
	call PrintSkillName
	call PrintSkillName
	call PrintSkillName

PrintSkillName::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_050_4a11

	ld a, $00
	ld [wTextIndex], a
	ld a, $08
	ld [wTextGroup], a
	jr jr_050_4a19

jr_050_4a11:
	ld [wTextIndex], a
	ld a, $06
	ld [wTextGroup], a

jr_050_4a19:
	ld de, $0901
	call PrintTextToTiles_50
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	inc de
	ret


OrderSkillInput::
	ld de, $4cca
	ld hl, wLinkRefused
	ld a, [wBattleListCount]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	call UpdateListCursor_50
	pop af
	ld hl, wLinkPartnerChoice
	cp [hl]
	jr z, jr_050_4a48

	call PrintSkillPage

jr_050_4a48:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_4a65

	ld a, $01
	ld [wOrderStep], a
	jp OrdersOpen


jr_050_4a57:
	ld hl, $0302
	call ShowOrdersMessage
	ret


jr_050_4a5e:
	ld hl, $0402
	call ShowOrdersMessage
	ret


jr_050_4a65:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_4b97

	ld a, $59
	call QueueSound
	ld hl, wLinkRefused
	res 7, [hl]
	ld a, [wLinkPartnerChoice]
	add a
	add a
	add [hl]
	ld [wItemMsgGroup], a
	add a
	ld hl, $dc65
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wConfirmChoice2]
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	call IsPassiveSkill
	jr z, jr_050_4a57

	call CheckSkillMP
	jr c, jr_050_4a5e

	call SetActionSkill
	ld a, [hl]
	ld [wBattleArg0], a
	ld [wSkillId], a
	ld [wBattleArg3], a
	ld a, [wConfirmChoice2]
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $f0
	ld b, a
	ld a, [wItemMsgGroup]
	or b
	ld [hl], a
	xor a
	ld [wBattleArg1], a
	ld a, $02
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	call Call_50_56EB
	call PickSkillTarget
	ret c

	ld a, [wBattleArg0]
	bit 0, a
	jp z, Jump_050_4b6b

	bit 4, a
	jr z, jr_050_4af0

	ld a, $07
	ld [wOrderStep], a
	ld a, [wConfirmChoice2]
	and $04
	xor $04
	jr jr_050_4afe

jr_050_4af0:
	bit 6, a
	jr nz, jr_050_4b54

	ld a, $05
	ld [wOrderStep], a
	ld a, [wConfirmChoice2]
	and $04

jr_050_4afe:
	call CountPresentOnSide
	ld a, b
	cp $01
	ret nz

	ld a, [wSkillId]
	cp $30
	jr z, jr_050_4b20

	cp $31
	jr z, jr_050_4b20

	cp $88
	jr z, jr_050_4b20

	call SetActionTarget
	call MarkOrderGiven
	ld a, $0b
	ld [wOrderStep], a
	ret


jr_050_4b20:
	call IsSingleBattlerSide
	jr z, ShowNoOtherTarget

	ret


IsSingleBattlerSide::
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_4b34

	ld c, $04
	ld a, [wEnemyCount]
	jr jr_050_4b39

jr_050_4b34:
	ld c, $00
	ld a, [wPartyBattlers]

jr_050_4b39:
	ld b, a
	ld d, $00

jr_050_4b3c:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_050_4b44

	jr z, jr_050_4b45

jr_050_4b44:
	inc d

jr_050_4b45:
	inc c
	dec b
	jr nz, jr_050_4b3c

	ld a, d
	cp $01
	ret


ShowNoOtherTarget::
	ld hl, $fb00
	call ShowOrdersMessage
	ret


jr_050_4b54:
	ld a, [wConfirmChoice2]
	ld c, a
	call SetActionTarget
	call MarkOrderGiven
	ld a, $0b
	ld [wOrderStep], a
	call Call_50_56EB
	ld hl, far_LoadWindowLetters_3
	rst $10
	ret


Jump_050_4b6b:
	call MarkOrderGiven
	ld a, $0b
	ld [wOrderStep], a
	call Call_50_56EB
	ld hl, far_LoadWindowLetters_3
	rst $10
	ld a, [wConfirmChoice2]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattleArg0]
	ld b, a
	ld a, [wConfirmChoice2]
	and $04
	bit 4, b
	jr z, jr_050_4b96

	xor $04

jr_050_4b96:
	ld [hl], a

Jump_050_4b97:
	ret


IsPassiveSkill::
	ld a, b
	cp $37
	jr z, jr_050_4ba3

	cp $38
	jr z, jr_050_4ba3

	cp $7e

jr_050_4ba3:
	ret


CheckSkillMP::
	push bc
	ld a, b
	ld [wBattleArg0], a
	xor a
	ld [wBattleArg1], a
	ld a, $04
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	ld a, [wBattleArg0]
	ld c, a
	ld b, $00
	ld a, [wConfirmChoice2]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	pop bc
	ret


PickSkillTarget::
	ld a, [wBattleArg3]
	cp $14
	jr z, jr_050_4c21

	cp $80
	jr z, jr_050_4c21

	cp $24
	jr z, jr_050_4c34

	cp $26
	jr z, jr_050_4c34

	cp $2a
	jr z, jr_050_4c34

	cp $32
	jr z, jr_050_4c2a

	cp $89
	jr z, jr_050_4c2a

	cp $8b
	jr z, jr_050_4c34

	cp $8f
	jr z, jr_050_4c34

	cp $95
	jr z, jr_050_4c2a

	cp $96
	jr z, jr_050_4c2a

	cp $39
	jr z, jr_050_4c3b

	cp $3f
	jr z, jr_050_4c72

	cp $51
	jr z, jr_050_4c40

	cp $52
	jr z, jr_050_4c40

	cp $53
	jr z, jr_050_4c40

	cp $83
	jr z, jr_050_4c64

	cp $88
	ret nc

	cp $84
	jr nc, jr_050_4c6d

	xor a
	ret


jr_050_4c21:
	ld a, [wConfirmChoice2]
	and $04
	xor $04
	jr jr_050_4c96

jr_050_4c2a:
	call IsSingleBattlerSide
	jr nz, jr_050_4c34

	call ShowNoOtherTarget
	pop hl
	ret


jr_050_4c34:
	ld a, [wConfirmChoice2]
	and $04
	jr jr_050_4c96

jr_050_4c3b:
	ld a, [wConfirmChoice2]
	jr jr_050_4c96

jr_050_4c40:
	ld a, [wSkillUser]
	ld b, a
	ld a, [wSkillId]
	ld c, a
	push bc
	ld a, [wConfirmChoice2]
	ld [wSkillUser], a
	ld a, [wBattleArg3]
	ld [wSkillId], a
	ld hl, far_AITargetRandomEnemy
	rst $10
	pop bc
	ld a, b
	ld [wSkillUser], a
	ld a, c
	ld [wSkillId], a
	jr jr_050_4c9a

jr_050_4c64:
	ld a, [wConfirmChoice2]
	and $04
	xor $04
	jr jr_050_4c96

jr_050_4c6d:
	ld a, [wConfirmChoice2]
	jr jr_050_4c96

jr_050_4c72:
	ld a, [wSkillUser]
	ld b, a
	ld a, [wSkillId]
	ld c, a
	push bc
	ld a, [wConfirmChoice2]
	ld [wSkillUser], a
	ld a, [wBattleArg3]
	ld [wSkillId], a
	ld hl, far_AITargetAnyone
	rst $10
	pop bc
	ld a, b
	ld [wSkillUser], a
	ld a, c
	ld [wSkillId], a
	jr jr_050_4c9a

jr_050_4c96:
	ld c, a
	call SetActionTarget

jr_050_4c9a:
	call MarkOrderGiven
	ld a, $0b
	ld [wOrderStep], a
	scf
	ret


ShowOrdersMessage::
	push hl
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	pop hl
	ld a, $03
	ld [wOrderStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


SkillListCursors::
	db $2a, $02, $41, $01, $81, $01, $c1, $01, $01, $02, $ff, $ff

AllyTargetOpen::
	ld a, [wSkillId]
	ld [wTargetSkill], a
	ld a, a
	ld [wTargetCursorSkill], a
	ld hl, far_LoadWindowLetters_7
	rst $10
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $70c9
	call DrawWindowLayout_50
	call BlankAbsentTargetNames
	call ResetCursorBlink_50
	ld de, $5339
	ld a, [wLinkFlags]
	rlca
	and $04
	ld b, a
	call CheckBattlerPresent
	jr nc, jr_050_4d10

	inc b
	ld a, b
	call CheckBattlerPresent
	jr nc, jr_050_4d10

	inc b

jr_050_4d10:
	res 2, b
	set 7, b
	ld a, b
	ld [wBattleTemp], a
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wOrderStep
	inc [hl]
	ret


AllyTargetInput::
	ld de, $5339
	ld hl, wBattleTemp
	ld a, [wConfirmChoice2]
	cp $04
	jr c, jr_050_4d35

	ld a, [wEnemyCount]
	jr jr_050_4d38

jr_050_4d35:
	ld a, [wPartyBattlers]

jr_050_4d38:
	ld b, a
	ld a, [wLinkFlags]
	rlca
	and $04
	ld c, a
	call UpdateTargetCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_4d51

	ld a, $03
	ld [wOrderStep], a
	jr jr_050_4d9b

jr_050_4d51:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_4d9b

	ld a, [wBattleTemp]
	res 7, a
	ld c, a
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_4d68

	set 2, c

jr_050_4d68:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_050_4d84

	ld a, [wConfirmChoice2]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $30
	jr z, jr_050_4d84

	cp $31
	jr nz, jr_050_4d9c

jr_050_4d84:
	call SetActionTarget
	ld a, $59
	call QueueSound
	call MarkOrderGiven
	ld a, $0b
	ld [wOrderStep], a
	call Call_50_56EB
	ld hl, far_LoadWindowLetters_3
	rst $10

Jump_050_4d9b:
jr_050_4d9b:
	ret


Jump_050_4d9c:
jr_050_4d9c:
	ld a, c
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_50
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $fa00
	ld a, $0a
	ld [wOrderStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


EnemyTargetOpen::
	ld a, [wSkillId]
	ld [wTargetSkill], a
	ld a, a
	ld [wTargetCursorSkill], a
	call Call_50_53DC
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $7113
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $5664
	ld a, [wLinkFlags]
	rlca
	and $04
	xor $04
	ld b, a
	call CheckBattlerPresent
	jr nc, jr_050_4e05

	inc b
	ld a, b
	call CheckBattlerPresent
	jr nc, jr_050_4e05

	inc b

jr_050_4e05:
	res 2, b
	set 7, b
	ld a, b
	ld [wBattleTemp], a
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wOrderStep
	inc [hl]
	ret


EnemyTargetInput::
	ld de, $5664
	ld hl, wBattleTemp
	ld a, [wConfirmChoice2]
	cp $04
	jr c, jr_050_4e2a

	ld a, [wPartyBattlers]
	jr jr_050_4e2d

jr_050_4e2a:
	ld a, [wEnemyCount]

jr_050_4e2d:
	ld b, a
	ld a, [wLinkFlags]
	rlca
	and $04
	xor $04
	ld c, a
	call UpdateTargetCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_4e54

	ld a, [wMenuChoice3]
	cp $80
	ld a, $01
	jr z, jr_050_4e4c

	ld a, $03

jr_050_4e4c:
	ld [wOrderStep], a
	call Call_50_56EB
	jr jr_050_4e89

jr_050_4e54:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_4e89

	ld a, [wBattleTemp]
	res 7, a
	ld c, a
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_4e6b

	set 2, c

jr_050_4e6b:
	ld a, c
	call CheckBattlerPresent
	jp c, Jump_050_4d9c

	call SetActionTarget
	ld a, $59
	call QueueSound
	call MarkOrderGiven
	ld a, $0b
	ld [wOrderStep], a
	call Call_50_56EB
	ld hl, far_LoadWindowLetters_3
	rst $10

Jump_050_4e89:
jr_050_4e89:
	ret


OrdersWaitText::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	ld a, $01
	ld [wOrderStep], a
	ret


OrdersWaitTextBack::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	ld a, [wMenuChoice3]
	and $01
	add a
	inc a
	ld [wOrderStep], a
	ret


OrdersNextMon::
	ld a, [wMenuChoice2]
	cp $80
	jr z, jr_050_4ed7

	ld a, $81
	ld [wMenuChoice], a
	ld a, $04
	ld [wCommandSubStep], a
	call SetMonTactic
	call Call_50_56EB
	ld hl, far_LoadWindowLetters_3
	rst $10
	jp Jump_050_4f61


jr_050_4ec9:
	ld a, [wConfirmChoice2]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $02

jr_050_4ed7:
	ld a, [wSkillUser]
	cp $01
	jr z, jr_050_4f36

	ld b, a
	ld a, [wConfirmChoice2]
	and $03
	cp b
	jr z, jr_050_4f36

	ld hl, wConfirmChoice2
	inc [hl]
	ld a, [hl]
	and $03
	cp $03
	jr z, jr_050_4f36

	ld a, [hl]
	call CheckBattlerPresent
	jr c, jr_050_4ed7

	ld a, [hl]
	call CheckBattlerCanAct
	jr c, jr_050_4f16

	ld a, [wConfirmChoice2]
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr nz, jr_050_4ec9

	inc hl
	bit 4, [hl]
	jr nz, jr_050_4ec9

	xor a
	ld [wOrderStep], a
	jr jr_050_4f61

jr_050_4f16:
	ld a, [hl]
	push bc
	ld b, a
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $3a
	ld [hli], a
	ld a, b
	ld [hl], a
	pop bc
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	jr jr_050_4ed7

Jump_050_4f36:
jr_050_4f36:
	ld a, $81
	ld [wMenuChoice], a
	ld a, $04
	ld [wCommandSubStep], a
	call TacticsMarkUnable
	jr jr_050_4f61

MarkOrderGiven::
	ld a, [wConfirmChoice2]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ld a, [wConfirmChoice2]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03

Jump_050_4f61:
jr_050_4f61:
	ret


UnusedRedrawBattleWindows::
	db $cd, $4e, $77, $cd, $4c, $79, $cd, $b4, $79, $c9, $c9, $c9

ClearMonAction::
	ld a, [wConfirmChoice2]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], a
	ret


SetActionSkillTarget::
	call SetActionSkill
	inc hl
	ld [hl], c
	ret


SetActionSkill::
	ld a, [wConfirmChoice2]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ret


SetActionTarget::
	ld a, [wConfirmChoice2]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	ret


CountPresentOnSide::
	push de
	ld c, a
	ld b, $03
	ld de, $0000

jr_050_4fab:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_4fb3

	inc d
	ld e, c

jr_050_4fb3:
	inc c
	dec b
	jr nz, jr_050_4fab

	ld b, d
	ld c, e
	pop de
	ret


ItemCommand::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wCommandSubStep]
	rst $00

ItemCommandSteps::
	dw Jump_50_4FE2
	dw Jump_50_5040
	dw Jump_50_50C5
	dw Jump_50_51CC
	dw Jump_50_5207
	dw Jump_50_528E
	dw Jump_50_52D7
	dw Jump_50_5372
	dw Jump_50_5602
	dw Jump_50_5697
	dw Jump_50_56AC
	dw Jump_50_56BA
	dw Jump_50_56CB
	dw Jump_50_56D9
	dw Call_50_56EB

Jump_50_4FE2::
	ld a, [wBattleType]
	cp $02
	jr z, jr_050_503a

	ld bc, $1400

jr_050_4fec:
	ld hl, wBagItems
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_050_5020

	or a
	jr z, jr_050_5020

	push bc
	ld a, [hl]
	add $af
	ld a, a
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, $0a
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	ld a, [wBattleArg0]
	cp $01
	pop bc
	jr nz, jr_050_5035

	inc c
	dec b
	jr nz, jr_050_4fec

jr_050_5020:
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $f300
	call Call_50_51AA
	ld a, $0b
	ld [wCommandSubStep], a
	ret


jr_050_5035:
	ld hl, wCommandSubStep
	inc [hl]
	ret


jr_050_503a:
	ld a, $f4
	call ShowMenuMessage
	ret


Jump_50_5040::
	call Call_50_50AC
	call Call_50_506F
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $6fce
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $51c0
	ld b, $04
	ld a, [wBattleListCount]
	ld c, a
	ld hl, wMenuChoice2
	call DrawListCursor_50
	call CopyTilemapBufferToScreen_50
	ld hl, wCommandSubStep
	inc [hl]
	ret


Call_50_506F::
	ld de, wBagItems
	ld a, [wConfirmChoice]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $88c0
	call Call_50_5089
	call Call_50_5089
	call Call_50_5089

Call_50_5089::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_050_5092

	ld a, $00

jr_050_5092:
	ld [wTextIndex], a
	ld a, $08
	ld [wTextGroup], a
	ld de, $0901
	call PrintTextToTiles_50
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


Call_50_50AC::
	ld hl, wBagItems
	ld b, $14
	ld c, $00

jr_050_50b3:
	ld a, [hli]
	cp $00
	jr z, jr_050_50c0

	cp $ff
	jr z, jr_050_50c0

	inc c
	dec b
	jr nz, jr_050_50b3

jr_050_50c0:
	ld a, c
	ld [wBattleListCount], a
	ret


Jump_50_50C5::
	ld de, $51c0
	ld hl, wMenuChoice2
	ld a, [wBattleListCount]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	call UpdateListCursor_50
	pop af
	ld hl, wConfirmChoice
	cp [hl]
	jr z, jr_050_50e1

	call Call_50_506F

jr_050_50e1:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_50f4

	ld hl, far_LoadWindowLetters_5
	rst $10
	ld a, $01
	ld [wCommandStep], a
	jp Jump_050_517a


jr_050_50f4:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_517a

	ld hl, wMenuChoice2
	res 7, [hl]
	ld a, [wConfirmChoice]
	add a
	add a
	add [hl]
	ld hl, wBagItems
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $af
	add [hl]
	ld [wBattleArg0], a
	ld hl, far_GetBattleItemTarget
	rst $10
	ld a, [wBattleArg0]
	or a
	jr z, jr_050_5199

	ld a, [wBattleArg0]
	ld [wBattleItemTarget], a
	ld a, [wBattleArg1]
	ld [wBattleItemEffect], a
	ld a, $59
	call QueueSound
	ld hl, far_LoadWindowLetters_6
	rst $10
	ld a, [wBattleItemTarget]
	cp $11
	jr z, jr_050_514e

	cp $12
	jr z, jr_050_515d

	cp $21
	jr z, jr_050_5169

	cp $22
	jr z, jr_050_5170

	ld hl, wCommandSubStep
	inc [hl]
	jr jr_050_517a

jr_050_514e:
	call Call_50_517B
	jr z, jr_050_5175

	call Call_50_56EB
	ld a, $07
	ld [wCommandSubStep], a
	jr jr_050_517a

jr_050_515d:
	ld a, $04
	ld [wBattleItemTarget], a
	ld a, $09
	ld [wCommandSubStep], a
	jr jr_050_517a

jr_050_5169:
	ld a, $05
	ld [wCommandSubStep], a
	jr jr_050_517a

jr_050_5170:
	ld a, $00
	ld [wBattleItemTarget], a

jr_050_5175:
	ld a, $09
	ld [wCommandSubStep], a

Jump_050_517a:
jr_050_517a:
	ret


Call_50_517B::
	ld hl, wEnemyDown
	ld a, [wEnemyCount]
	ld b, a
	ld c, $00
	ld d, $04

jr_050_5186:
	ld a, [hli]
	or a
	jr nz, jr_050_518c

	inc c
	ld e, d

jr_050_518c:
	inc d
	dec b
	jr nz, jr_050_5186

	ld a, c
	cp $01
	ret nz

	ld a, e
	ld [wBattleItemTarget], a
	ret


jr_050_5199:
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $f200
	ld a, $0a
	ld [wCommandSubStep], a

Call_50_51AA::
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


ItemListCursors::
	db $2a, $02, $41, $01, $81, $01, $c1, $01, $01, $02, $ff, $ff

Jump_50_51CC::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $7045
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $5288
	xor a
	ld [wConfirmChoice2], a
	ld a, [wConfirmChoice2]
	ld b, a
	ld a, [wBattleItemEffect]
	cp $c2
	jr c, jr_050_51fb

	cp $c7
	jr nc, jr_050_51fb

	ld a, $01
	ld [wConfirmChoice2], a
	ld b, $01

jr_050_51fb:
	ld a, b
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wCommandSubStep
	inc [hl]
	ret


Jump_50_5207::
	ld de, $5288
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateMenuCursor_50
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_5227

	ld hl, wCommandSubStep
	dec [hl]
	ld hl, wCommandSubStep
	dec [hl]
	ld hl, wCommandSubStep
	dec [hl]
	jr jr_050_5287

jr_050_5227:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_5287

	ld a, $59
	call QueueSound
	ld hl, far_LoadWindowLetters_2
	rst $10
	ld a, $80
	ld [wMenuChoice3], a
	ld a, [wConfirmChoice2]
	cp $80
	jr z, jr_050_526d

	ld a, [wBattleItemEffect]
	cp $c2
	jr c, jr_050_524f

	cp $c7
	jr c, jr_050_525f

jr_050_524f:
	ld a, [wBattleItemTarget]
	and $0f
	bit 0, a
	jr z, jr_050_525f

	ld a, $07
	ld [wCommandSubStep], a
	jr jr_050_5287

jr_050_525f:
	ld a, $04
	ld [wBattleItemTarget], a
	ld a, $09
	ld [wCommandSubStep], a
	jr jr_050_5287

	db $18, $1a

jr_050_526d:
	ld a, [wBattleItemTarget]
	and $0f
	bit 0, a
	jr z, jr_050_527d

	ld a, $05
	ld [wCommandSubStep], a
	jr jr_050_5287

jr_050_527d:
	ld a, $09
	ld [wCommandSubStep], a
	ld a, $00
	ld [wBattleItemTarget], a

Jump_050_5287:
jr_050_5287:
	ret


ItemUseCursors::
	db $c1, $01, $01, $02, $ff, $ff

Jump_50_528E::
	ld a, [wBattleItemEffect]
	ld [wTargetSkill], a
	ld a, a
	ld [wTargetCursorSkill], a
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $707f
	call DrawWindowLayout_50
	call BlankAbsentTargetNames
	call ResetCursorBlink_50
	ld de, $5339
	ld a, [wLinkFlags]
	rlca
	and $04
	ld b, a
	call CheckBattlerPresent
	jr nc, jr_050_52c4

	inc b
	ld a, b
	call CheckBattlerPresent
	jr nc, jr_050_52c4

	inc b

jr_050_52c4:
	res 2, b
	set 7, b
	ld a, b
	ld [wMenuChoice3], a
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wCommandSubStep
	inc [hl]
	ret


Jump_50_52D7::
	ld de, $5339
	ld hl, wMenuChoice3
	ld a, [wPartyBattlers]
	ld b, a
	ld a, [wLinkFlags]
	rlca
	and $04
	ld c, a
	call UpdateTargetCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_5309

	ld a, [wBattleItemTarget]
	and $f0
	cp $20
	jr z, jr_050_5302

	ld a, $03
	ld [wCommandSubStep], a
	jr jr_050_5338

jr_050_5302:
	ld a, $01
	ld [wCommandSubStep], a
	jr jr_050_5338

jr_050_5309:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_5338

	ld a, [wMenuChoice3]
	res 7, a
	ld c, a
	call CheckBattlerPresent
	jr nc, jr_050_5323

	ld a, [wBattleItemEffect]
	cp $bb
	jr nz, ItemAllyTargetGone

jr_050_5323:
	ld a, c
	ld [wBattleItemTarget], a
	ld a, $59
	call QueueSound
	ld hl, wCommandSubStep
	inc [hl]
	ld hl, wCommandSubStep
	inc [hl]
	ld hl, wCommandSubStep
	inc [hl]

Jump_050_5338:
jr_050_5338:
	ret


AllyTargetCursors::
	db $81, $01, $c1, $01, $01, $02, $ff, $ff

ItemAllyTargetGone::
	ld a, c
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_50
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $fa00
	ld a, $0c
	ld [wCommandSubStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


Jump_50_5372::
	ld a, [wBattleItemEffect]
	ld [wTargetSkill], a
	ld a, a
	ld [wTargetCursorSkill], a
	call Call_50_53DC
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $7113
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $5664
	ld a, [wLinkFlags]
	rlca
	and $04
	xor $04
	ld b, a
	call CheckBattlerPresent
	jr nc, jr_050_53aa

	inc b
	ld a, b
	call CheckBattlerPresent
	jr nc, jr_050_53aa

	inc b

jr_050_53aa:
	res 2, b
	set 7, b
	ld a, b
	ld [wMenuChoice3], a
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wCommandSubStep
	inc [hl]
	ret


Call_50_53BD::
	ld a, [wLinkFlags]
	rlca
	and $04
	xor $04
	ld [wBattleTempHigh], a
	ret


Call_50_53C9::
	ld a, [wTargetSkill]
	cp $30
	jr z, jr_050_53da

	cp $31
	jr z, jr_050_53da

	cp $bb
	jr z, jr_050_53da

	scf
	ret


jr_050_53da:
	xor a
	ret


Call_50_53DC::
	ld a, [wLinkActive]
	or a
	jp nz, Jump_050_549e

	call Call_50_53BD
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr c, jr_050_53fe

	xor a
	ld [wBattleArg2], a
	ld a, [wEnemyMorph]
	cp $ff
	jr z, jr_050_5403

	call Call_50_5530
	jr jr_050_540e

jr_050_53fe:
	call Call_50_547E
	jr jr_050_540e

jr_050_5403:
	call Call_50_547E
	ld a, $01
	ld [wBattleArg2], a
	call Call_50_5530

jr_050_540e:
	xor a
	ld [wBattleArg2], a
	ld a, [wEncCount]
	cp $00
	jr nz, jr_050_541e

	call Call_50_5485
	jr Call_50_548C

jr_050_541e:
	ld a, [wBattleTempHigh]
	inc a
	ld [wBattleTempHigh], a
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr c, jr_050_5439

	ld a, [$c1cb]
	cp $ff
	jr z, jr_050_543e

	call Call_50_553D
	jr jr_050_5449

jr_050_5439:
	call Call_50_5485
	jr jr_050_5449

jr_050_543e:
	call Call_50_5485
	ld a, $01
	ld [wBattleArg2], a
	call Call_50_553D

jr_050_5449:
	xor a
	ld [wBattleArg2], a
	ld a, [wEncCount]
	cp $01
	jr nz, jr_050_5456

	jr Call_50_548C

jr_050_5456:
	ld a, [wBattleTempHigh]
	inc a
	ld [wBattleTempHigh], a
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr c, jr_050_5470

	ld a, [$c1cc]
	cp $ff
	jr z, jr_050_5472

	call Call_50_554A
	ret


jr_050_5470:
	jr Call_50_548C

jr_050_5472:
	call Call_50_548C
	ld a, $01
	ld [wBattleArg2], a
	call Call_50_554A
	ret


Call_50_547E::
	ld hl, $88c0
	ld b, $a0
	jr Call_50_5491

Call_50_5485::
	ld hl, $8960
	ld b, $a0
	jr Call_50_5491

Call_50_548C::
	ld hl, $8a00
	ld b, $a0

Call_50_5491::
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, Call_50_5491

	ret


Jump_050_549e:
	xor a
	ld [$c1d7], a
	ld a, [wPartyBattlers]
	ld [$c1d8], a
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_54ba

	ld a, $04
	ld [$c1d7], a
	ld a, [wEnemyCount]
	ld [$c1d8], a

jr_050_54ba:
	ld a, [$c1d7]
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr nc, jr_050_54ca

	call Call_50_547E
	jr jr_050_54d9

jr_050_54ca:
	ld a, [$c1d7]
	call Call_50_55F9
	ld a, [$c1d7]
	ld hl, $88c0
	call Call_50_5557

jr_050_54d9:
	ld a, [$c1d8]
	cp $01
	jr nz, jr_050_54e5

	call Call_50_5485
	jr Call_50_548C

jr_050_54e5:
	ld hl, $c1d7
	inc [hl]
	ld a, [hl]
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr nc, jr_050_54f7

	call Call_50_5485
	jr jr_050_5506

jr_050_54f7:
	ld a, [$c1d7]
	call Call_50_55F9
	ld a, [$c1d7]
	ld hl, $8960
	call Call_50_5557

jr_050_5506:
	ld a, [$c1d8]
	cp $02
	jr nz, jr_050_5510

	jp Call_50_548C


jr_050_5510:
	ld hl, $c1d7
	inc [hl]
	ld a, [hl]
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr nc, jr_050_5520

	jp Call_50_548C


jr_050_5520:
	ld a, [$c1d7]
	call Call_50_55F9
	ld a, [$c1d7]
	ld hl, $8a00
	call Call_50_5557
	ret


Call_50_5530::
	call Call_50_55F9
	ld hl, $88c0
	ld a, $00
	ld [wBattleArg0], a
	jr jr_050_556a

Call_50_553D::
	call Call_50_55F9
	ld hl, $8960
	ld a, $01
	ld [wBattleArg0], a
	jr jr_050_556a

Call_50_554A::
	call Call_50_55F9
	ld hl, $8a00
	ld a, $02
	ld [wBattleArg0], a
	jr jr_050_556a

Call_50_5557::
	push hl
	call PrintNameToTiles_50
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld b, $30
	call Call_50_5491
	ret


jr_050_556a:
	push hl
	push hl
	ld a, [wBattleArg0]
	add $04
	ld [wNamePos], a
	ld hl, wTextArg0
	call GetBattlerName_50
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
	ld a, [wBattleArg1]
	or a
	jr nz, jr_050_55a0

	ld de, $0801
	jr jr_050_55a3

jr_050_55a0:
	ld de, $0901

jr_050_55a3:
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
	pop hl
	ld a, [wBattleArg2]
	or a
	ret nz

	ld a, [wBattleArg1]
	or a
	jr nz, jr_050_55e3

	ld a, l
	add $80
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld b, $18
	jr jr_050_55f5

jr_050_55e3:
	ld a, l
	add $80
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld b, $10

jr_050_55f5:
	call Call_50_5491
	ret


Call_50_55F9::
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ret


Jump_50_5602::
	ld de, $5664
	ld hl, wMenuChoice3
	ld a, [wEncCount]
	inc a
	ld b, a
	ld a, [wLinkFlags]
	rlca
	and $04
	xor $04
	ld c, a
	call UpdateTargetCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_563a

	ld a, [wBattleItemTarget]
	and $f0
	cp $10
	jr z, jr_050_5630

	ld a, $03
	ld [wCommandSubStep], a
	jr jr_050_5663

jr_050_5630:
	call Call_50_56EB
	ld a, $01
	ld [wCommandSubStep], a
	jr jr_050_5663

jr_050_563a:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_5663

	ld a, [wMenuChoice3]
	res 7, a
	add $04
	ld c, a
	call CheckBattlerPresent
	jr nc, jr_050_5656

	ld a, [wBattleItemEffect]
	cp $bb
	jr nz, ItemEnemyTargetGone

jr_050_5656:
	ld a, c
	ld [wBattleItemTarget], a
	ld a, $59
	call QueueSound
	ld hl, wCommandSubStep
	inc [hl]

Jump_050_5663:
jr_050_5663:
	ret


EnemyTargetCursors::
	db $81, $01, $c1, $01, $01, $02, $ff, $ff

ItemEnemyTargetGone::
	ld a, c
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_50
	call Call_50_5708
	ld hl, $fa00
	ld a, $0d
	ld [wCommandSubStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


Jump_50_5697::
	ld hl, wBattlerOrder
	ld a, [wPartyBattlers]
	ld b, a
	ld a, $01

jr_050_56a0:
	ld [hli], a
	dec b
	jr nz, jr_050_56a0

	call ClearTilemapBuffer_50
	ld hl, wCommandStep
	inc [hl]
	ret


Jump_50_56AC::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	ld a, $01
	ld [wCommandSubStep], a
	ret


Jump_50_56BA::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	xor a
	ld [wCommandStep], a
	xor a
	ld [wCommandSubStep], a
	ret


Jump_50_56CB::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	ld a, $05
	ld [wCommandSubStep], a
	ret


Jump_50_56D9::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	ld a, $07
	ld [wCommandSubStep], a
	ret


UnusedFarCall55::
	db $21, $06, $55, $d7

Call_50_56EB::
	call Call_50_5708
	ld hl, $88c0

Call_50_56F1::
	ld c, $02

jr_050_56f3:
	ld b, $f0

jr_050_56f5:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_050_56f5

	dec c
	jr nz, jr_050_56f3

	call CopyTilemapBufferToScreen_50
	ret


Call_50_5708::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ret


;@ def RunCommand()
;@ path: battle/run
;@ The Run entry of the battle menu: runs step wCommandSubStep of RunSteps.
;@ test: skip jumps through a table
RunCommand::
;> return RunSteps[wCommandSubStep]()
	ld a, [wCommandSubStep]
	rst $00

;@ path: battle/run
;@ Steps of the Run command (wCommandSubStep): 0 start, 1 try to escape, 2 wait for the
;@ message, 3 the yes/no question when giving up a battle in the Starry Night arena.
RunSteps::
	dw RunStart
	dw RunTry
	dw RunWaitText
	dw GiveUpYesNo

;@ def RunStart()
;@ path: battle/run
;@ First step of Run. In a wild battle Terry tries to escape ("<PLAYER> tries to escape!",
;@ text $2A). A scripted battle, or a tournament / link battle outside the Starry Night arena
;@ (map $5D), gives "Can't run from this battle!" (text $F5) and goes back to the menu; in the
;@ arena Terry is asked whether he gives up the battle.
;@ test: skip draws the battle screen
RunStart::
;> if wBattleType != 0:                         # not a wild encounter
	ld a, [wBattleType]
	or a
	jr z, .wild

;>@no     if wBattleType == 1 or wScriptMap != 0x5D:    # scripted, or not in the arena
	cp $01
	jr z, .cannot

;=@no
	ld a, [wScriptMap]
	cp $5d
	jr nz, .cannot

;>@no2         return ShowMenuMessage(0xF5)         # "Can't run from this battle!"
;>     AskGiveUpBattle()
	call AskGiveUpBattle
;>     wOrderFlag0 = 1                          # the yes/no cursor starts on "No"
	ld a, $01
	ld [wOrderFlag0], a
;>     return
	ret


.wild
;> CopyName(wPlayerName, wTextArg0)
	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
;> ClearTilemapBuffer_50(); DrawEnemyPictures(); DrawBattlePanel()
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
;> ShowBattleMessage(0x2A)                     # "<PLAYER> tries to escape!"
	ld a, $2a
	call ShowBattleMessage
;> DrawWindowLayout_50(MessageWindowLayout)
	ld de, MessageWindowLayout
	call DrawWindowLayout_50
;> CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
;> wBattleItemTarget = 0xFF
	ld a, $ff
	ld [wBattleItemTarget], a
;> wBattleItemEffect = 0xFF
	ld a, $ff
	ld [wBattleItemEffect], a
;> wCommandSubStep += 1
	ld hl, wCommandSubStep
	inc [hl]
;> QueueSound(0x6D)
	ld a, $6d
	call QueueSound
	ret


.cannot
;=@no2
	ld a, $f5
	call ShowMenuMessage
	ret


;@ def AskGiveUpBattle()
;@ path: battle/run
;@ Redraws the battle screen with "Give up the battle?" (text 5 of group 2) and the yes/no
;@ window; the letters "Yes" / "No" are unpacked into tiles $9C on (bank $51, entry $12).
;@ Run goes on with the yes/no step (3).
;@ test: skip draws the battle screen
AskGiveUpBattle::
;> ClearTilemapBuffer_50(); DrawEnemyPictures(); DrawBattlePanel()
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
;> wCommandSubStep = 3                         # GiveUpYesNo
	ld hl, $0502
	ld a, $03
	ld [wCommandSubStep], a
;> wTextGroup = 2; wTextIndex = 5               # "Give up the battle?"
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> DrawWindowLayout_50(MessageWindowLayout)
	ld de, MessageWindowLayout
	call DrawWindowLayout_50
;> DecompressVRAM(0x51, 0x12, 0x89C0)           # the yes/no letters
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
;> DrawWindowLayout_50(YesNoWindow)
	ld de, YesNoWindow
	call DrawWindowLayout_50
;> CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
	ret


;@ def RunTry()
;@ path: battle/run
;@ Second step of Run, once the message is out: does the escape work? Outside wild battles,
;@ and in a wild battle from the fourth try on (wRunTurn 0 or 4 and up), always. In the first /
;@ second / third try it works with a random number below $40 / $80 / $C0, else still when no
;@ enemy can stand in the way (CheckNoEnemyCanBlock) or the own monsters are well above the
;@ enemies' level (CompareRunLevels). A failed try costs every own monster its turn: "But the
;@ enemy blocks the way!" (text $B9). An escape ends the battle (battle step $0A) as run away
;@ (wBattlerReload 2; 1 = lost when a tournament battle is given up) and costs the monsters
;@ some personality (ApplyRunPersonality).
;@ test: skip draws the battle screen
RunTry::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;>@ok if wBattleType == 0 and 1 <= wRunTurn <= 3:
	ld a, [wBattleType]
	or a
	jr nz, .escaped

;=@ok
	ld a, [wRunTurn]
	or a
	jr z, .escaped

;=@ok
	cp $04
	jr nc, .escaped

;>@ch     chance = (0, 0x40, 0x80, 0xC0)[wRunTurn]      # 25 %, 50 %, 75 %
	cp $03
	jr z, .three

	cp $02
	jr z, .two

	ld b, $40
	jr .roll

.two
;=@ch
	ld b, $80
	jr .roll

.three
;=@ch
	ld b, $c0

.roll
;>@f     if wRandomHigh >= chance and not CheckNoEnemyCanBlock() and not CompareRunLevels():
	ld a, [wRandomHigh]
	cp b
	jr c, .escaped

	call CheckNoEnemyCanBlock
	jr c, .escaped

;=@f
	call CompareRunLevels
	jr c, .escaped

;>         for i in range(wPartyBattlers):         # all own monsters lose their turn
	ld hl, wBattlerOrder
	ld a, [wPartyBattlers]
	ld b, a
;>             wBattlerOrder[i] = 3
	ld a, $03

.lose
	ld [hli], a
	dec b
	jr nz, .lose

;>         ClearTilemapBuffer_50(); DrawEnemyPictures(); DrawBattlePanel()
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
;>         ShowBattleMessage(0xB9)             # "But the enemy blocks the way!"
	ld a, $b9
	call ShowBattleMessage
;>         DrawWindowLayout_50(MessageWindowLayout)
	ld de, MessageWindowLayout
	call DrawWindowLayout_50
;>         CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
;>         wCommandSubStep += 1
;>         return
	ld hl, wCommandSubStep
	inc [hl]
	ret


.escaped
;> wBattleArg2 = 0
	xor a
	ld [wBattleArg2], a
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> wBattleStep = 0x0A                          # BattleStepEnd
	ld a, $0a
	ld [wBattleStep], a
;> for i in range(4):                          # no enemy counts as defeated: no reward
;>     mem[addr(wEnemyDown) + i] = 0xFF
	ld hl, wEnemyDown
	ld a, $ff
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
;> wBattlerReload = 2                          # ran away
	ld a, $02
	ld [wBattlerReload], a
;> ApplyRunPersonality()
	call ApplyRunPersonality
;> if wBattleType != 0:
;>     wBattlerReload = 1                      # giving up a tournament battle is a loss
	ld a, [wBattleType]
	or a
	ret z

	ld a, $01
	ld [wBattlerReload], a
	ret


;@ def RunWaitText()
;@ path: battle/run
;@ Third step of Run: waits for the message, then the command menu goes on to its next step.
;@ test: wTextState = rand(0, 1)
RunWaitText::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
	ret


;@ def GiveUpYesNo()
;@ path: battle/run
;@ Fourth step of Run (in the Starry Night arena): the yes/no cursor. Yes: "<PLAYER>s gives up
;@ the battle!" (text 6 of group 2), then RunTry, which ends the battle as lost. No or B:
;@ back to the command menu.
;@ test: skip draws the battle screen
GiveUpYesNo::
;> UpdateMenuCursor_50(wOrderFlag0, 2, YesNoCursors)
	ld de, YesNoCursors
	ld hl, wOrderFlag0
	ld b, $02
	call UpdateMenuCursor_50
;>@b if wJoyPressed & 0x01 and not wOrderFlag0 & 1:     # A on "Yes"
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .notA

;=@b
	ld a, [wOrderFlag0]
	bit 0, a
	jr nz, .back

;>     CopyName(wPlayerName, wTextArg0)
	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
;>     ClearTilemapBuffer_50(); DrawEnemyPictures(); DrawBattlePanel()
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
;>     wTextGroup = 2; wTextIndex = 6           # "<PLAYER>s gives up the battle!"
	ld a, $02
	ld [wTextGroup], a
	ld a, $06
	ld [wTextIndex], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>     DrawWindowLayout_50(MessageWindowLayout)
	ld de, MessageWindowLayout
	call DrawWindowLayout_50
;>     CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
;>     wBattleItemTarget = 0xFF
	ld a, $ff
	ld [wBattleItemTarget], a
;>     wBattleItemEffect = 0xFF
	ld a, $ff
	ld [wBattleItemEffect], a
;>     QueueSound(0x6D)
	ld a, $6d
	call QueueSound
;>     wCommandSubStep = 1                      # RunTry
;>     return
	ld a, $01
	ld [wCommandSubStep], a
	ret


.notA
;> if not wJoyPressed & 0x03:                   # A on "No" and B both go back
;>     return
	bit 1, a
	ret z

.back
;> wCommandStep = 0                            # back to the command menu
	xor a
	ld [wCommandStep], a
;> wMenuChoice = 0; wCommandSubStep = 0
	ld [wMenuChoice], a
	ld [wCommandSubStep], a
	ret


;@ path: battle/run
;@ Cursor places (screen positions) of the yes/no window (YesNoWindow): "Yes" and "No",
;@ ended by $FFFF.
YesNoCursors::
	dw $012f                     ; row 9, column 15
	dw $016f                     ; row 11, column 15
	dw $ffff

;@ def CheckNoEnemyCanBlock() -> carry
;@ path: battle/run
;@ Carry when none of the enemies (positions 4-6) can stand in Terry's way: each one is
;@ missing, asleep, paralyzed or confused (status byte 0, bits $D0), under one of the effects
;@ of status byte 3 bits 0-5 (frozen, lured, stumbling, licked, shocked, feeling good), or
;@ an iron lump. The same test as CheckBattlerCanAct.
CheckNoEnemyCanBlock::
;>@pos for pos in range(4, 7):
	ld bc, $0304

.loop
;>     if CheckBattlerPresent(pos):              # no monster there
;>         continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>     status = addr(wBattlerStatus) + 8 * pos
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
;>     if mem[status] & 0xD0:                   # asleep, paralyzed or confused
;>         continue
	ld a, [hli]
	and $d0
	jr nz, .next

;>     if mem[status + 3] & 0x3F:
;>         continue
	inc hl
	inc hl
	ld a, [hli]
	and $3f
	jr nz, .next

;>     if not mem[status + 5] & 0xC0:           # not an iron lump: it can block
;>@ok         return False
	inc hl
	ld a, [hl]
	and $c0
	jr z, .canBlock

.next
;=@pos
	inc c
	dec b
	jr nz, .loop

;> return True
	scf
	ret


.canBlock
;=@ok
	xor a
	ret


;@ def CompareRunLevels() -> carry
;@ path: battle/run
;@ Carry when the highest level among the own monsters (positions 0-2) is more than 4 above
;@ the highest enemy level (positions 4-6): then the escape works.
CompareRunLevels::
;> own = foe = 0                                 # highest levels found
	ld bc, $0300
	ld de, $0000

.own
;>@own for pos in range(3):
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .nextOwn

;>         own = max(own, GetBattlerLevel_50(pos))
	call GetBattlerLevel_50
	cp d
	jr c, .nextOwn

	ld d, a

.nextOwn
;=@own
	inc c
	dec b
	jr nz, .own

;>@foe for pos in range(4, 7):
	ld bc, $0304

.foe
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .nextFoe

;>         foe = max(foe, GetBattlerLevel_50(pos))
	call GetBattlerLevel_50
	cp e
	jr c, .nextFoe

	ld e, a

.nextFoe
;=@foe
	inc c
	dec b
	jr nz, .foe

;> return foe + 4 < own
	ld a, $04
	add e
	cp d
	ret


;@ def GetBattlerLevel_50(pos: c) -> a
;@ path: battle/state
;@ Level of the monster at battle position `pos`.
;@ test: pos = rand(0, 7)
GetBattlerLevel_50::
;>@r return wBattlerLevel[pos]
	ld a, c
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
;=@r
	ld h, a
	ld a, [hl]
	ret


;@ def ApplyRunPersonality()
;@ path: battle/run
;@ After an escape every own monster still in the fight loses some personality: the four
;@ signed changes of a RunPersonalityChanges row (chosen by its level and whether its third
;@ personality byte is $97 or more) go to wBattlerPersonality1, wBattlerStat67,
;@ wBattlerPersonality2 and wBattlerPersonality3, each kept within 0-255.
ApplyRunPersonality::
;>@pos for pos in range(3):
	ld bc, $0300

.loop
;>     wBattleArg0 = pos; wBattleArg1 = 3 - pos  # the loop state, kept over the calls
	ld a, c
	ld [wBattleArg0], a
	ld a, b
	ld [wBattleArg1], a
;>     if CheckBattlerPresent(pos):              # no monster there
;>         continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@p3     row = 0x10 if wBattlerPersonality3[pos] >= 0x97 else 0
	ld de, $0000
	ld a, c
	ld hl, wBattlerPersonality3
	add l
	ld l, a
	ld a, $00
;=@p3
	adc h
	ld h, a
	ld a, [hl]
	cp $97
	jr c, .level

;=@p3
	ld e, $10

.level
;>@lv     level = wBattlerLevel[pos]
	ld a, c
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
;=@lv
	ld h, a
	ld a, [hl]
;>     if level >= 10:
	cp $0a
	jr c, .apply

;>         if level < 20:
;>@r4             row += 4
	cp $14
	jr c, .r4

;>         elif level < 30:
;>@r8             row += 8
	cp $1e
	jr c, .r8

;>         else:
;>             row += 12
	ld a, e
	add $0c
	ld e, a
	jr .apply

.r4
;=@r4
	ld a, e
	add $04
	ld e, a
	jr .apply

.r8
;=@r8
	ld a, e
	add $08
	ld e, a
	jr .apply

.apply
;>     changes = RunPersonalityChanges + row
	ld hl, RunPersonalityChanges
	add hl, de
;>@k     for k in range(4):                   # the four personality arrays are 8 bytes apart
;>@a         AddSignedClamped(changes + k, addr(wBattlerPersonality1) + 8 * k + pos)
	ld a, [wBattleArg0]
	ld bc, wBattlerPersonality1
	add c
	ld c, a
	ld a, $00
	adc b
;=@a
	ld b, a
	call AddSignedClamped
;=@k
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
;=@a
	ld b, a
	call AddSignedClamped
;=@k
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
;=@a
	ld b, a
	call AddSignedClamped
;=@k
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
;=@a
	ld b, a
	call AddSignedClamped

.next
;=@pos
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	ld b, a
;=@pos
	inc c
	dec b
	jp nz, .loop

	ret


;@ def AddSignedClamped(delta: hl, value: bc)
;@ path: battle/run
;@ Adds the signed byte at `delta` to the byte at `value`, kept within 0-255.
;@ test: delta = rand(0xC000, 0xCFFF); value = rand(0xC000, 0xCFFF)
AddSignedClamped::
;> if mem[delta] < 0x80:                        # a rise
	bit 7, [hl]
	jr nz, .fall

;>     v = min(mem[value] + mem[delta], 0xFF)
	ld a, [bc]
	add [hl]
	jr nc, .store

	ld a, $ff
	jr .store

.fall
;> else:
;>     drop = 0x100 - mem[delta]
	ld a, [hl]
	cpl
	inc a
	ld d, a
;>     v = max(mem[value] - drop, 0)
	ld a, [bc]
	sub d
	jr nc, .store

	xor a

.store
;> mem[value] = v
	ld [bc], a
	ret


;@ path: battle/run
;@ Personality changes after an escape (ApplyRunPersonality), 8 rows of four signed bytes
;@ for wBattlerPersonality1, wBattlerStat67, wBattlerPersonality2 and wBattlerPersonality3.
;@ Rows 0-3: third personality byte below $97, for levels below 10, 10-19, 20-29 and 30 up;
;@ rows 4-7 the same for $97 and more.
RunPersonalityChanges::
	db $fc, $00, $00, $f6        ; -4, 0, 0, -10
	db $fd, $00, $00, $fb        ; -3, 0, 0, -5
	db $fe, $00, $00, $fd        ; -2, 0, 0, -3
	db $ff, $00, $00, $fe        ; -1, 0, 0, -2
	db $f8, $00, $00, $f1        ; -8, 0, 0, -15
	db $fa, $00, $00, $f6        ; -6, 0, 0, -10
	db $fc, $00, $00, $fb        ; -4, 0, 0, -5
	db $fe, $00, $00, $fd        ; -2, 0, 0, -3

;@ def BattleMenuClearTiles()
;@ path: battle/menu
;@ Step 10 of the command menu: redraws the battle screen, fills tiles from the VRAM address
;@ kept in wTargetScores (Call_50_56F1) and goes on with command step wSkillAmount2. No code
;@ was found that selects this step.
;@ test: skip writes VRAM
BattleMenuClearTiles::
;> Call_50_5708()
	call Call_50_5708
;> Call_50_56F1(mem16[addr(wTargetScores)])
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	call Call_50_56F1
;> wCommandStep = wSkillAmount2 & 0xFF
	ld a, [wSkillAmount2]
	ld [wCommandStep], a
	ret


ShowActionMessage::
	ld a, [wSkillUser]
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_50
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	cp $4f
	jr z, jr_050_5a19

	cp $a6
	jr z, jr_050_5a16

	cp $ac
	jr z, jr_050_5a19

	call SetTargetName
	jr StartActionMessage

jr_050_5a16:
	call SetGroupUserName

jr_050_5a19:
	call SetActionTargetName

StartActionMessage::
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	call z, GetAttackSkill
	cp $da
	call nc, GetSpecialActionName
	ld l, a
	ld h, $06
	ld de, wTextArg1
	call CopySystemText
	ld a, $00
	ld [wTextGroup], a
	ld a, [wBattleArg0]
	ld [wTextIndex], a
	cp $ff
	ret z

	ld hl, far_StartText_4C
	rst $10
	ret


GetAttackSkill::
	ld a, $3a
	ret


SetTargetName::
	ld a, [hl]
	ld hl, wTextArg2
	ld [wNamePos], a
	call GetBattlerName_50
	ret


SetGroupUserName::
	ld a, [hl]
	ld [wSkillTarget], a
	ld hl, far_CountTargetNames
	rst $10
	ld a, [wBattleTemp]
	or a
	jr z, StartActionMessage

	ld hl, wTextArg0
	jr TrimNameTag

SetActionTargetName::
	ld a, [hl]
	ld [wSkillTarget], a
	ld hl, far_CountTargetNames
	rst $10
	ld a, [wBattleTemp]
	or a
	jr z, NameSkillTarget

	cp $01
	jr nz, SetGangTargetName

	call NameSkillTarget
	ld hl, wTextArg2

TrimNameTag::
	ld a, [hli]
	cp $f0
	jr nz, TrimNameTag

jr_050_5a8e:
	dec hl
	ld a, [hl]
	cp $f0
	jr z, jr_050_5a8e

	cp $24
	jr c, jr_050_5a99

	inc hl

jr_050_5a99:
	ld [hl], $f0
	ret


SetGangTargetName::
	ld a, [wLinkActive]
	or a
	jr nz, NameSkillTarget

	ld a, [wSkillTarget]
	cp $04
	jr nc, jr_050_5aad

	call NameSkillTarget
	ret


jr_050_5aad:
	ld hl, wTextArg2
	ld a, $3e
	ld [hli], a
	ld a, $62
	ld [hli], a
	ld a, $44
	ld [hli], a
	ld a, $3e
	ld [hli], a
	ld a, $4b
	ld [hli], a
	ld a, $44
	ld [hli], a
	ld [hl], $f0
	ret


NameSkillTarget::
	ld a, [wSkillTarget]
	ld hl, wTextArg2
	ld [wNamePos], a
	call GetBattlerName_50
	ret


GetSpecialActionName::
	push hl
	sub $da
	ld hl, $5ae1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	ret


SpecialActionNames::
	db $19, $a1, $2a, $70

ShowMenuMessage::
	push af
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	pop af
	call ShowBattleMessage
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ld a, $00
	ld [wCommandStep], a
	ld a, $00
	ld [wCommandSubStep], a
	ret


CheckAutoCommand::
	push bc
	ld [wBattleTemp], a
	ld b, a
	call CheckBattlerCanAct
	jr c, jr_050_5b55

	ld a, b
	ld bc, wBattlerStatus
	add a
	add a
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	bit 4, a
	jr nz, jr_050_5b35

	inc bc
	inc bc
	inc bc
	inc bc
	ld a, [bc]
	and $0c
	jr nz, jr_050_5b35

	inc bc
	ld a, [bc]
	and $f0
	jr nz, jr_050_5b35

	xor a
	jr jr_050_5b56

jr_050_5b35:
	push hl
	ld a, [wBattleTemp]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or $e0
	ld [hl], a
	ld a, [wBattleTemp]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	pop hl

jr_050_5b55:
	scf

jr_050_5b56:
	pop bc
	ret


ShowItemBrokeMessage::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld a, $e0
	call ShowBattleMessage
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ld a, $00
	ld [wCommandStep], a
	ld a, $00
	ld [wCommandSubStep], a
	ret


UpdateTargetCursor::
	res 7, [hl]
	ld a, [wJoyRepeat]
	and $40
	jp z, Jump_050_5b9a

jr_050_5b84:
	ld a, [hl]
	dec a
	bit 7, a
	call nz, LastTargetRow
	call IsTargetAbsent
	jp nc, StoreMenuCursor_50

	call IsRevivalTarget
	ld [hl], a
	jr nz, jr_050_5b84

	jp StoreMenuCursor_50


Jump_050_5b9a:
	ld a, [wJoyRepeat]
	and $80
	jp z, FinishMenuCursor_50

jr_050_5ba2:
	ld a, [hl]
	inc a
	cp b
	call nc, FirstTargetRow
	call IsTargetAbsent
	jp nc, StoreMenuCursor_50

	call IsRevivalTarget
	ld [hl], a
	jr nz, jr_050_5ba2

	jp StoreMenuCursor_50


LastTargetRow::
	ld a, b
	dec a
	ret


FirstTargetRow::
	xor a
	ret


IsTargetAbsent::
	push bc
	ld b, a
	or c
	call CheckBattlerPresent
	ld a, b
	pop bc
	ret


IsRevivalTarget::
	push bc
	ld b, a
	ld a, [wTargetCursorSkill]
	cp $30
	jr z, jr_050_5bd4

	cp $31
	jr z, jr_050_5bd4

	cp $bb

jr_050_5bd4:
	ld a, b
	pop bc
	ret


BlankAbsentTargetNames::
	ld a, [wLinkFlags]
	rlca
	and $04
	ld c, a
	ld b, $03

jr_050_5be0:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_050_5bfb

	ld a, [wTargetSkill]
	cp $30
	jr z, jr_050_5bfb

	cp $31
	jr z, jr_050_5bfb

	cp $bb
	jr z, jr_050_5bfb

	ld a, c
	res 2, a
	call BlankTargetName

jr_050_5bfb:
	inc c
	dec b
	jr nz, jr_050_5be0

	ret


BlankTargetName::
	push bc
	ld hl, $0060

jr_050_5c04:
	ld a, c
	and $03
	jr z, jr_050_5c14

	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec c
	jr jr_050_5c04

jr_050_5c14:
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $01
	ld h, a
	call TilemapBufferAddr_50

jr_050_5c1f:
	ld a, [hl]
	cp $ff
	jr z, jr_050_5c2d

	cp $80
	jr nc, jr_050_5c2a

	ld [hl], $e0

jr_050_5c2a:
	inc hl
	jr jr_050_5c1f

jr_050_5c2d:
	pop bc
	ret


IsCommandTacticBanned::
	ld a, [wConfirmChoice]
	cp $83
	ret nz

	ld a, [wBattleType]
	cp $02
	ret nz

	ld a, [wLinkActive]
	or a
	ret


SumBattleReward::
	ld a, $00
	ld [wRewardTotal], a
	ld a, $00
	ld [$dd24], a
	ld a, $00
	ld [$dd25], a
	ld a, [wEnemyCount]
	ld b, a
	ld hl, wEnemyDown
	ld de, wEnemyReward

jr_050_5c59:
	ld a, [hli]
	cp $01
	jr nz, jr_050_5c71

	push hl
	ld hl, wRewardTotal
	ld a, [de]
	add [hl]
	ld [hli], a
	inc de
	ld a, [de]
	adc [hl]
	ld [hli], a
	inc de
	ld a, [de]
	adc [hl]
	ld [hl], a
	inc de
	pop hl
	jr jr_050_5c74

jr_050_5c71:
	inc de
	inc de
	inc de

jr_050_5c74:
	dec b
	jr nz, jr_050_5c59

	ret


ShowVictoryMessage::
	ld a, [wLinkActive]
	or a
	jr nz, ShowLinkResultMessage

	call ClassifyEnemyGroup
	call NameFirstEnemy
	ld bc, $0304
	ld de, $0000

jr_050_5c8a:
	ld a, c
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr nz, jr_050_5c9a

	inc d

jr_050_5c9a:
	inc c
	dec b
	jr nz, jr_050_5c8a

	ld a, d
	or a
	jr nz, jr_050_5ca4

	ld e, $03

jr_050_5ca4:
	ld a, [wBattleArg0]
	cp $02
	jr c, jr_050_5cad

	ld a, $02

jr_050_5cad:
	add e
	add $ec
	call ShowBattleMessage
	ret


ShowLinkResultMessage::
	ld b, $03
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_5cc1

	ld c, $04
	jr jr_050_5cc3

jr_050_5cc1:
	ld c, $00

jr_050_5cc3:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_5cd4

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	jr z, jr_050_5cf5

jr_050_5cd4:
	inc c
	dec b
	jr nz, jr_050_5cc3

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_5ce4

	call CopyRecord4Master
	jr jr_050_5ce7

jr_050_5ce4:
	call CopyRecord0Master

jr_050_5ce7:
	ld a, $4f
	ld [wBattleTemp], a
	ld a, $ff
	ld [wBattleType], a
	ld a, $eb
	jr jr_050_5d0b

jr_050_5cf5:
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_5d01

	call CopyRecord0Master
	jr jr_050_5d04

jr_050_5d01:
	call CopyRecord4Master

jr_050_5d04:
	ld a, $69
	ld [wBattleTemp], a
	ld a, $ed

jr_050_5d0b:
	call ShowBattleMessage
	ld a, $02
	call QueueMusic
	ld a, [wBattleTemp]
	call QueueSound
	ret


CopyRecord0Master::
	ld de, wMonMaster
	jr jr_050_5d22

CopyRecord4Master::
	ld de, wMon4Master

jr_050_5d22:
	ld hl, wTextArg0
	call CopyName
	ret


RollSurprise::
	ld a, $02
	ld [wBattlerReload], a
	ld a, [wBattleType]
	or a
	jr nz, jr_050_5d46

	ld a, [wRandomHigh]
	and $1f
	cp $1f
	jr z, jr_050_5d4c

	ld a, [wRandomLow]
	and $1f
	cp $1f
	jr z, jr_050_5d71

jr_050_5d46:
	ld a, $01
	ld [wRunTurn], a
	ret


jr_050_5d4c:
	ld hl, wBattleStep
	inc [hl]
	call ClassifyAndNameEnemies
	ld a, [wBattleArg0]
	cp $02
	jr c, jr_050_5d5c

	ld a, $02

jr_050_5d5c:
	ld c, a
	ld a, [wRandomLow]
	and $01
	ld b, a
	add a
	add b
	add c
	add $03
	call ShowBattleMessage
	ld a, $00
	ld [wBattlerReload], a
	ret


jr_050_5d71:
	ld hl, wBattleStep
	inc [hl]
	ld hl, wBattleStep
	inc [hl]
	call ClassifyAndNameEnemies
	ld a, $04
	ld [wSkillUser], a
	ld a, [wBattleArg0]
	cp $02
	jr c, jr_050_5d8a

	ld a, $02

jr_050_5d8a:
	ld c, a
	ld a, [wRandomHigh]
	and $01
	ld b, a
	add a
	add b
	add c
	add $09
	call ShowBattleMessage
	ld a, $01
	ld [wBattlerReload], a
	ret


ResetTurnOrder::
	ld a, $ff
	ld hl, wTurnOrder
	ld bc, $000a
	call FillMemory
	ld b, $08
	ld c, $00
	ld h, $00

jr_050_5db0:
	ld a, c
	ld e, a
	ld d, a
	ld a, c
	call CheckBattlerCanAct
	ld a, d
	and a
	jr nz, jr_050_5dbc

	inc h

jr_050_5dbc:
	inc c
	dec b
	jr nz, jr_050_5db0

	ld a, h
	or a
	jr nz, jr_050_5dc8

	ld hl, wBattleStep
	inc [hl]

jr_050_5dc8:
	ret


InitBattleMode::
	ld hl, sp+$00
	ld a, l
	ld [wBattleStackPtr], a
	ld a, h
	ld [$da7a], a
	xor a
	ld hl, wMenuChoice
	ld bc, $0008
	call FillMemory
	xor a
	ld hl, wTextTiles
	ld bc, $0012
	call FillMemory
	ld hl, $99c1
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
	ld [$c83f], a
	xor a
	ld hl, wBattleStep
	ld bc, $0008
	call FillMemory
	xor a
	ld hl, wCommandStep
	ld bc, $0008
	call FillMemory
	xor a
	ld [wBattleSubStep], a
	ld [wBattleAnimRunning], a
	call DisableSTATInterrupts
	xor a
	ld [wSkillAnimSprites], a
	xor a
	ld [wMenuOverlay], a
	xor a
	ld [$c87e], a
	ld hl, far_StartBattleScreen
	rst $10
	ret


BattleFrame::
	ld a, [wLinkActive]
	or a
	jr z, jr_050_5e3e

	call LinkFrameUpdate
	ld a, [wFadeState]
	or a
	ret nz

	call UpdateSkillAnimation
	ld a, [wBattleAnimRunning]
	or a
	ret z

	di
	ld hl, far_StepAnimation
	rst $10
	ei
	ret


jr_050_5e3e:
	ld a, [wFadeState]
	or a
	ret nz

	call UpdateSkillAnimation
	call UpdatePlayTime

BattleFrameLogic::
	ld a, [wFadeState]
	or a
	ret nz

	ld a, [wSkillAnimActive]
	cp $01
	jp nz, RunBattleStep

	ld a, [wSkillAnim]
	cp $ff
	ret z

	ld a, [wSkillAnim]
	ld [wPaletteSet], a
	ld hl, far_LoadObjPaletteB
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ld a, [wSkillAnim]
	ld hl, $5e84
	ld c, a
	ld b, $00
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, $8000
	call DecompressVRAM
	ld a, $02
	ld [wSkillAnimActive], a
	ret


SkillAnimGfx::
	db $00, $5a, $01, $5a, $02, $5a, $03, $5a, $04, $5a, $05, $5a, $06, $5a, $07, $5a
	db $08, $5a, $09, $5a, $0a, $5a, $0b, $5a, $0c, $5a, $0d, $5a, $0e, $5a, $0f, $5a
	db $10, $5a, $11, $5a, $12, $5a, $13, $5a, $14, $5a, $15, $5a, $16, $5a, $17, $5a
	db $18, $5a, $19, $5a, $1a, $5a, $1b, $5a, $1c, $5a, $1d, $5a, $1e, $5a, $1f, $5a
	db $0a, $5b, $0b, $5b, $0c, $5b, $0d, $5b, $0e, $5b, $0f, $5b, $10, $5b, $11, $5b
	db $12, $5b, $13, $5b, $14, $5b, $15, $5b, $16, $5b

RunBattleStep::
	ld a, [wBattleAnimRunning]
	or a
	jr z, jr_050_5ef9

	ld a, [wLinkActive]
	or a
	jr nz, jr_050_5eee

	ld hl, far_StepAnimation
	rst $10

jr_050_5eee:
	ld a, [wBattleAnimRunning]
	or a
	ret nz

	ld a, $00
	ld [wSkillAnimActive], a
	ret


jr_050_5ef9:
	ld a, [wBattleStep]
	cp $0d
	jr z, jr_050_5f17

	ld a, [wTextState]
	or a
	jr z, jr_050_5f17

	ld a, [wBattleAnimDone]
	or a
	jr z, jr_050_5f17

	ld hl, far_UpdateScreenEffect
	rst $10
	ld a, [$c87e]
	or a
	jr nz, jr_050_5f17

	ret


jr_050_5f17:
	ld a, [wBattleAnimDone]
	or a
	jr z, jr_050_5f2f

	ld a, [wScreenEffect]
	cp $09
	jr nz, jr_050_5f2f

	ld hl, far_UpdateScreenEffect
	rst $10
	ld a, [$c87e]
	or a
	jr nz, jr_050_5f2f

	ret


jr_050_5f2f:
	ld a, [wBattleType]
	cp $ff
	jr z, WaitBattleEndSound

	ld a, [wBattleStep]
	rst $00

BattleSteps::
	dw BattleStepStart
	dw BattleStepIntro
	dw BattleStepSurprise
	dw BattleStepNewTurn
	dw BattleStepCommand
	dw BattleStepPlanTurn
	dw BattleStepActStart
	dw BattleStepAct
	dw BattleStepActDone
	dw BattleStepTurnEnd
	dw BattleStepEnd
	dw BattleStepLevelUps
	dw BattleStepLevelUpScreen
	dw BattleStepRecruit
	dw BattleStepExit
	dw BattleStepIdle
	dw BattleStepLinkEnd
	dw BattleStepLinkResult

WaitBattleEndSound::
	ld a, [wSoundChannels]
	ld hl, $dd9a
	and [hl]
	cp $ff
	ret nz

	xor a
	ld [wBattleType], a
	ret


BattleStepStart::
	ld hl, far_LoadFieldObjPalettes
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ld a, [wPartyCount]
	or a
	jr nz, jr_050_5f86

	ld hl, $0c00
	call PrintSystemText
	ld hl, wBattleStep
	inc [hl]
	ret


jr_050_5f86:
	call ClassifyEnemyGroup
	ld a, $05
	ld [wMonStats], a
	ld hl, wBattleStep
	inc [hl]
	ret


BattleStepIntro::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wMonStats]
	or a
	jr z, jr_050_5fa3

	dec a
	ld [wMonStats], a
	ret


jr_050_5fa3:
	ld a, [wPartyCount]
	or a
	jp z, BattleStepExit

	call ShowIntroMessage
	ret


BattleStepSurprise::
	call RollSurprise
	call SetFirstTurnOrder
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


BattleStepNewTurn::
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wMenuChoice], a
	call ResetTurnOrder
	call ResetBattlerActions
	ld hl, wPersonalityNudge
	ld bc, $0008
	xor a
	call FillMemory
	ld a, [wPartyBattlers]
	ld b, a
	ld c, $00
	ld hl, wBattlerTactic
	call MarkTacticPresence
	ld a, [wLinkFlags]
	bit 1, a
	ret z

	ld a, [wEnemyCount]
	ld b, a
	ld c, $04
	ld hl, $dd07
	call MarkTacticPresence
	ret


MarkTacticPresence::
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6004

	ld a, [hl]
	and $0f
	ld [hli], a
	jr jr_050_6008

jr_050_6004:
	ld a, [hl]
	or $e0
	ld [hli], a

jr_050_6008:
	inc c
	dec b
	jr nz, MarkTacticPresence

	ret


ResetBattlerActions::
	ld de, wBattlerAction
	ld bc, $0800

jr_050_6013:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6046

	ld a, c
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr z, jr_050_6046

	ld a, c
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 7, [hl]
	jr nz, jr_050_6046

	ld a, c
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 6, [hl]
	jr nz, jr_050_6046

	ld a, $ff
	ld [de], a
	inc de
	jr jr_050_604b

jr_050_6046:
	ld a, $ff
	ld [de], a
	inc de
	ld [de], a

jr_050_604b:
	inc de
	inc c
	dec b
	jr nz, jr_050_6013

	ret


BattleStepCommand::
	jr BattleStepCommandMenu

RedrawBattleScreen::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	ld a, [wDebugStatsShown]
	or a
	jr nz, jr_050_6063

	call DrawMessageWindowAndPanel
	ret


jr_050_6063:
	call DrawBattlePanel
	ret


BattleStepCommandMenu::
	call BattleMenu
	xor a
	ld [wBattleSubStep], a
	ret


BattleStepPlanTurn::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, far_ChooseTargetsAndOrder
	rst $10
	ret


BattleStepActStart::
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wBattleSubStep], a
	ld [wBattleSubStep2], a
	ld [$dd75], a
	ld [wReactionKind], a
	ld [wSkillAnimPhase], a
	ld a, [wLinkActive]
	or a
	jr z, BattleStepAct

	ld a, [wLinkRandom]
	ld l, a
	ld a, [$c1ee]
	ld h, a
	ld a, l
	ld [wRandomHigh], a
	ld a, h
	ld [wRandomLow], a
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, l
	ld [wLinkRandom], a
	ld a, h
	ld [$c1ee], a

BattleStepAct::
	ld hl, far_RunActionStep
	rst $10
	call DrawBattlePanel
	call RefreshPanelDigits
	ld a, [wBattleStep]
	cp $08
	ret nz

	ld a, $05
	ld [wMonStats], a

BattleStepActDone::
	ld a, [wMonStats]
	or a
	jr z, jr_050_60d6

	dec a
	ld [wMonStats], a
	ret


jr_050_60d6:
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wBattleArg0], a
	ld [wBattleArg1], a
	ld [wBattleArg2], a
	ld [wBattleSubStep], a
	call RedrawBattleScreen
	jp BattleStepTurnEnd


BattleStepEnd::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wBGP
	ld a, $d2
	ld [hli], a
	ld a, $d2
	ld [hli], a
	ld [hl], $e2
	ld a, [wBattleArg2]
	cp $02
	jr nz, jr_050_6112

	ld hl, far_CheckBattleOver
	rst $10
	xor a
	ld [wBattleArg2], a
	ld a, $05
	ld [wMonStats], a
	ret


jr_050_6112:
	ld a, [wMonStats]
	or a
	jr z, jr_050_611d

	dec a
	ld [wMonStats], a
	ret


jr_050_611d:
	call ClearTilemapBuffer_50
	call DrawMessageWindowAndPanel
	call CopyTilemapBufferToScreen_50
	ld a, [wLinkActive]
	or a
	jr z, jr_050_6139

	ld a, $01
	ld [wLinkNoEnd], a
	ld a, $10
	ld [wBattleStep], a
	jp Jump_050_6196


jr_050_6139:
	call SumBattleReward
	ld hl, far_SaveBattleResults
	rst $10
	ld a, [wBattlerReload]
	or a
	jr z, jr_050_6150

	xor a
	ld [wJoinCandidate], a
	ld hl, wBattleStep
	inc [hl]
	jr jr_050_6196

jr_050_6150:
	ld hl, wRewardTotal
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr z, jr_050_6192

	call GiveBattleExp
	ld hl, far_PruneLearnableSkills
	rst $10
	call GetExpShare
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	ld a, e
	ldh [$ffd7], a
	ld hl, wTextArg0
	call Number24ToDecimal
	call CountLivingParty
	ld a, b
	ld hl, $0b0e
	cp $01
	jr nz, jr_050_618f

	ld a, c
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	ld hl, $0b23

jr_050_618f:
	call PrintSystemText

jr_050_6192:
	ld hl, wBattleStep
	inc [hl]

Jump_050_6196:
jr_050_6196:
	ret


GetExpShare::
	call CountLivingParty
	ld a, [wRewardTotal]
	ld l, a
	ld a, [$dd24]
	ld h, a
	ld a, [$dd25]
	ld e, a
	ld a, b
	push af
	call Divide24
	pop af
	cp $02
	ret z

	cp $03
	jr z, jr_050_61c0

	ld a, l
	sub $01
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, e
	sbc $00
	ld e, a
	ret


jr_050_61c0:
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, e
	adc $00
	ld e, a
	ret


CountLivingParty::
	ld b, $00
	ld a, [wParty]
	call CountIfAlive
	ld a, [$ca8f]
	call CountIfAlive
	ld a, [$ca90]
	call CountIfAlive
	ret


GiveBattleExp::
	call GetExpShare
	ld a, l
	ldh [$ffd8], a
	ld a, h
	ldh [$ffd9], a
	ld a, e
	ldh [$ffda], a
	ld a, [wRewardTotal]
	ld l, a
	ld a, [$dd24]
	ld h, a
	ld a, [$dd25]
	ld e, a
	ld a, $10
	call Divide24
	ld a, l
	ldh [hDivisorHigh], a
	ld a, h
	ldh [$ffdc], a
	ld a, e
	ldh [hFindY], a
	ld hl, wMonsters
	ld b, $14
	xor a
	ld [wCurPartyMember], a

Jump_050_6211:
	push hl
	ld a, [hl]
	or a
	jp z, Jump_050_62c4

	cp $02
	jr z, jr_050_6272

	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	or a
	jp nz, Jump_050_62c4

	ld a, l
	add $e8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	cp $63
	jp z, Jump_050_62c4

	push af
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	cp [hl]
	jp nc, Jump_050_62c4

	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ldh a, [hDivisorHigh]
	add [hl]
	ld [hli], a
	ld e, a
	ldh a, [$ffdc]
	adc [hl]
	ld [hli], a
	ld d, a
	ldh a, [hFindY]
	adc [hl]
	ld [hl], a
	ld c, a
	ld a, e
	sub $7f
	ld a, d
	sbc $96
	ld a, c
	sbc $98
	jr c, jr_050_62c4

	ld de, $967f
	ld c, $98
	ld [hl], c
	dec hl
	ld [hl], d
	dec hl
	ld [hl], e
	jr jr_050_62c4

jr_050_6272:
	ld a, l
	add $4a
	ld l, a
	ld a, h
	adc $00
	ld h, a
	bit 7, [hl]
	jr nz, jr_050_62c4

	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp $63
	jr z, jr_050_62c4

	push af
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	cp [hl]
	jr nc, jr_050_62c4

	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ldh a, [$ffd8]
	add [hl]
	ld [hli], a
	ld e, a
	ldh a, [$ffd9]
	adc [hl]
	ld [hli], a
	ld d, a
	ldh a, [$ffda]
	adc [hl]
	ld [hl], a
	ld c, a
	ld a, e
	sub $7f
	ld a, d
	sbc $96
	ld a, c
	sbc $98
	jr c, jr_050_62c4

	ld de, $967f
	ld c, $98
	ld [hl], c
	dec hl
	ld [hl], d
	dec hl
	ld [hl], e

Jump_050_62c4:
jr_050_62c4:
	pop hl
	push bc
	push hl
	call CapExpAtMaxLevel
	ld hl, wCurPartyMember
	inc [hl]
	pop hl
	pop bc
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jp nz, Jump_050_6211

	ret


CountIfAlive::
	cp $ff
	ret z

	ld hl, wMonStatus
	push af
	push bc
	call MonsterField
	pop bc
	pop af
	bit 7, [hl]
	ret nz

	ld c, a
	inc b
	ret


BattleStepLevelUps::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wParty]
	call CheckLevelUpDue
	jr nc, jr_050_630d

	ld a, [$ca8f]
	call CheckLevelUpDue
	jr nc, jr_050_630d

	ld a, [$ca90]
	call CheckLevelUpDue
	jr c, jr_050_6316

jr_050_630d:
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wCommandStep], a
	ret


jr_050_6316:
	ld b, $00

jr_050_6318:
	push bc
	ld a, b
	call CheckLevelUpDue
	pop bc
	jr nc, jr_050_6337

	inc b
	ld a, b
	cp $14
	jr nz, jr_050_6318

	ld hl, wBattleStep
	inc [hl]
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wCommandStep], a
	ld hl, far_CheckEnemyJoins
	rst $10
	ret


jr_050_6337:
	ld hl, far_RollLevelUpGains
	rst $10
	ld hl, far_ApplyLevelUp
	rst $10
	ret


UnusedPartyCode::
	db $fe, $ff, $c8, $ea, $c0, $ca, $78, $21, $15, $da, $85, $6f, $3e, $00, $8c, $67
	db $e5, $fa, $c0, $ca, $57, $21, $07, $01, $d7, $7a, $e1, $be, $c8, $77, $6f, $26
	db $0a, $11, $90, $c1, $cd, $7a, $09, $fa, $c0, $ca, $21, $c2, $ca, $cd, $3b, $22
	db $5d, $54, $21, $80, $c1, $cd, $80, $0c, $21, $21, $0b, $cd, $6d, $09, $fa, $25
	db $c8, $b7, $c9

CheckLevelUpDue::
	cp $ff
	jr z, jr_050_63a2

	ld [wCurPartyMember], a
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $63
	jr z, jr_050_63a2

	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	or a
	jr nz, jr_050_63a4

jr_050_63a2:
	scf
	ret


jr_050_63a4:
	ld hl, far_GetExpForNextLevel
	rst $10
	ld a, [wCurPartyMember]
	ld hl, wMonExp
	call MonsterField
	ldh a, [hNumber]
	ld b, a
	ld a, [hli]
	sub b
	ldh a, [$ffd6]
	ld b, a
	ld a, [hli]
	sbc b
	ldh a, [$ffd7]
	ld b, a
	ld a, [hli]
	sbc b
	ret


BattleStepLevelUpScreen::
	ld a, [wBattlerReload]
	or a
	jr nz, jr_050_63cc

	ld hl, far_LevelUpScreen
	rst $10
	ret


jr_050_63cc:
	ld a, $0e
	ld [wBattleStep], a
	ret


BattleStepRecruit::
	ld a, [wCommandStep]
	cp $24
	jr z, jr_050_63de

	ld a, [wTextState]
	or a
	ret nz

jr_050_63de:
	ld a, [wJoinCandidate]
	cp $ff
	jr nz, jr_050_63ea

	ld hl, wBattleStep
	inc [hl]
	ret


jr_050_63ea:
	ld a, [wJoinCandidate]
	sub $04
	add a
	ld hl, wEncSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wNewMonId], a
	ld a, [hl]
	ld [$da13], a
	ld hl, far_RemapMonId
	rst $10
	ld hl, far_RecruitScreen
	rst $10
	ret


BattleStepExit::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, far_PruneLearnableSkills
	rst $10
	ld hl, wGameStarted
	set 7, [hl]
	ld a, $04
	call StartFade
	ld a, $01
	ld [wGameMode], a
	ld a, $00
	ld [wGameModeStep], a
	ld a, $00
	ld [wOpeningScene], a
	ld a, $00
	ld [wOpeningLogo], a
	ld hl, wGameModeChange
	inc [hl]
	ld a, [wMapId]
	cp $5d
	jp nz, Jump_050_64e0

	ld hl, wGameStarted
	res 7, [hl]
	ld a, [wArenaFight]
	cp $02
	jr z, jr_050_64a0

	cp $01
	jr z, jr_050_6486

	call LoadArenaOpponents
	xor a
	ld [wScriptRunning], a
	ld a, [wBattlerReload]
	cp $01
	ret nz

	ld a, $ff
	ld [wArenaRound], a
	ld hl, $0006
	ld a, l
	ld [wWarpMap], a
	ld a, h
	ld [wWarpOnGateFloor], a
	ld hl, $00e8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ret


jr_050_6486:
	call LoadArenaOpponents
	xor a
	ld [wScriptRunning], a
	ld a, [wBattlerReload]
	cp $01
	jr z, jr_050_64af

	ld a, [wArenaRound]
	cp $02
	ret nz

	ld a, $02
	ld [wArenaFight], a
	ret


jr_050_64a0:
	xor a
	ld [wScriptRunning], a
	ld a, $03
	ld [wArenaFight], a
	ld a, [wBattlerReload]
	cp $01
	ret nz

jr_050_64af:
	ld a, $08
	ld [$d92b], a
	ld hl, $0000
	ld a, l
	ld [wWarpMap], a
	ld a, h
	ld [wWarpOnGateFloor], a
	ld hl, $00e8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0058
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld hl, wGameStarted
	res 7, [hl]
	ret


Jump_050_64e0:
	ld a, [wMapId]
	cp $52
	jr nz, jr_050_64f5

	call LoadNextArenaTeam
	xor a
	ld [wScriptRunning], a
	ld hl, wGameStarted
	res 7, [hl]
	jr FinishBattleExit

jr_050_64f5:
	ld a, [wBattleKind]
	cp $02
	jr nz, FinishBattleExit

	ld a, [wBattlerReload]
	cp $01
	ret nz

	ld b, $00
	ld c, $00
	ld a, [wParty]
	call ClearPartyAilments
	ld a, [$ca8f]
	call ClearPartyAilments
	ld a, [$ca90]
	call ClearPartyAilments
	ld a, b
	cp c
	ret nz

	ld a, [wParty]
	ld hl, wMonHP
	call MonsterField
	ld [hl], $01
	inc hl
	ld [hl], $00
	ld a, [wParty]
	ld hl, wMonStatus
	call MonsterField
	ld [hl], $00
	ret


ClearPartyAilments::
	cp $ff
	ret z

	inc b
	ld hl, wMonStatus
	call MonsterField
	ld a, [hl]
	and $80
	ld [hl], a
	ret z

	inc c
	ret


FinishBattleExit::
	ld a, [wBattlerReload]
	cp $01
	jr z, jr_050_6559

	ld a, [wBattleKind]
	cp $03
	ret nz

	ld a, $0e
	ld [wHiddenSprites], a
	ret


jr_050_6559:
	ld a, $08
	ld [$d92b], a
	ld hl, $0000
	ld a, l
	ld [wWarpMap], a
	ld a, h
	ld [wWarpOnGateFloor], a
	ld hl, $00e8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0058
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld hl, wGameStarted
	res 7, [hl]
	ld a, [wGold]
	ld l, a
	ld a, [$ca4c]
	ld h, a
	ld a, [$ca4d]
	ld e, a
	ld a, $02
	call Divide24
	ld a, l
	ld [wGold], a
	ld a, h
	ld [$ca4c], a
	ld a, e
	ld [$ca4d], a
	ld hl, wBagItems
	ld b, $14

jr_050_65ab:
	ld a, [hl]
	or a
	jr z, jr_050_65c7

	cp $ff
	jr z, jr_050_65c7

	ld [wItemId], a
	push hl
	push bc
	ld hl, far_GetItemData
	rst $10
	pop bc
	pop hl
	ld a, [wItemFlags]
	bit 2, a
	jr nz, jr_050_65c7

	ld [hl], $ff

jr_050_65c7:
	inc hl
	dec b
	jr nz, jr_050_65ab

	ld hl, far_CompactBag
	rst $10
	xor a
	ldh [hPlayerFlags], a
	xor a
	ld [wScriptRunning], a
	ld hl, wFieldFlags
	res 0, [hl]
	ret


BattleStepLinkEnd::
	ld a, $01
	ld [wLinkSendByte], a
	ld hl, wBattleStep
	inc [hl]
	ret


BattleStepLinkResult::
	ld a, [wLinkReceivedLast]
	cp $01
	ret nz

	ld hl, wMonMaster
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_65f9

	ld hl, wMon4Master

jr_050_65f9:
	ld de, wLinkPartnerName
	ld b, $08
	call CopyBytes_50
	ld a, [wLinkPrizeSlot]
	cp $ff
	jr z, jr_050_6663

	ld a, [wBattlerReload]
	or a
	jr z, jr_050_6663

	di
	ld hl, wMonsters
	ld de, sMonsters
	ld bc, $0ba4
	call CopyFromSave
	ei
	ld a, [wLinkPrizeSlot]
	ld hl, wMonsters
	call MonsterField
	ld de, wBreedParent1
	ld b, $95
	call CopyBytes_50
	ld a, [wLinkPrizeSlot]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
	di
	ld hl, wPartyCount
	ld de, sPartyCount
	ld bc, $0007
	call CopyFromSave
	ei
	ld hl, far_CompactMonsters
	rst $10
	di
	call SaveMonsters
	ei
	ld a, $00
	call FixVSTeamSlot
	ld a, $01
	call FixVSTeamSlot
	ld a, $02
	call FixVSTeamSlot
	ld a, $14
	ld [wLinkPrizeSlot], a

jr_050_6663:
	ld a, $04
	call StartFade
	ld a, $06
	ld [wGameMode], a
	ld a, $00
	ld [wGameModeStep], a
	ld a, $00
	ld [wOpeningScene], a
	ld a, $00
	ld [wOpeningLogo], a
	ld hl, wGameModeChange
	inc [hl]
	xor a
	ld [wLinkMode], a
	ld [wLinkPhase], a
	xor a
	ld [wLinkFlags], a
	ld [wSerialLock], a
	xor a
	ld [wLinkActive], a
	xor a
	ld [wLinkReceivedLast], a
	xor a
	ld [wLinkSendByte], a
	xor a
	ld [wLinkCommand], a
	ret


FixVSTeamSlot::
	ld c, a
	ld hl, wVSTeamSlots
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	cp [hl]
	ret z

	ld a, [wLinkPrizeSlot]
	cp [hl]
	jr z, jr_050_66b6

	ret nc

	dec [hl]
	ret


jr_050_66b6:
	ld [hl], $14
	ret


CopyFromSave::
	ld a, $0a
	ld [$0100], a

jr_050_66be:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_050_66be

	ld a, $00
	ld [$0100], a
	ret


CopyBytes_50::
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, CopyBytes_50

	ret


LoadArenaOpponents::
	ld a, [wArenaRound]
	cp $03
	ret z

	ld a, [wArenaClass]
	ld b, a
	add a
	add b
	ld b, a
	ld a, [wArenaRound]
	add b
	ld b, a
	add a
	add b
	ld hl, $00e0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wEncSpecies], a
	ld a, h
	ld [$da04], a
	inc hl
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	inc hl
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a
	ld a, $02
	ld [wEncCount], a
	ld a, [wArenaClass]
	ld b, a
	add a
	add b
	ld b, a
	ld a, [wArenaRound]
	add b
	add a
	ld hl, $6778
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wEncGfx], a
	ld a, [hl]
	ld [$d7cb], a
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	call GetMonSpriteNumber
	ld [$d7ce], a
	ld a, $01
	ld [$d7cf], a
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	call GetMonSpriteNumber
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	call GetMonSpriteNumber
	ld [$d7d0], a
	ld a, $01
	ld [$d7d1], a
	ret


GetMonSpriteNumber::
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wNewMonNameText]
	add $10
	ret


ArenaTeamGfx::
	db $0b, $00, $0a, $00, $11, $00, $0b, $00, $0a, $00, $da, $01, $0b, $00, $0a, $00
	db $0b, $00, $0b, $00, $0a, $00, $02, $00, $0b, $00, $0a, $00, $0b, $00, $0b, $00
	db $0a, $00, $0f, $00, $0b, $00, $0a, $00, $0c, $00, $0b, $00, $0a, $00, $13, $00
	db $0b, $00, $0a, $00, $14, $00

LoadNextArenaTeam::
	ld hl, wEncGfx
	ld a, $ff
	ld [hli], a
	xor a
	ld [hli], a
	ld a, $ff
	ld [hli], a
	xor a
	ld [hli], a
	ld a, $ff
	ld [hli], a
	xor a
	ld [hl], a
	ld a, [wArenaRound]
	or a
	jr nz, jr_050_682d

	ld a, $01
	ld [wArenaRound], a
	ld a, $02
	ld [wEncCount], a
	ld a, [wArenaTeam1]
	ld l, a
	ld a, [$d9d2]
	ld h, a
	ld a, l
	ld [wEncSpecies], a
	ld a, h
	ld [$da04], a
	call GetMonSpriteNumber
	ld [wEncGfx], a
	ld a, $01
	ld [$d7cb], a
	ld a, [wEncCount]
	or a
	ret z

	ld a, [$d9d3]
	ld l, a
	ld a, [$d9d4]
	ld h, a
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	call GetMonSpriteNumber
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [wEncCount]
	cp $01
	ret z

	ld a, [$d9d5]
	ld l, a
	ld a, [$d9d6]
	ld h, a
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a
	call GetMonSpriteNumber
	ld [$d7ce], a
	ld a, $01
	ld [$d7cf], a
	ret


jr_050_682d:
	cp $01
	jr nz, jr_050_6898

	ld a, $02
	ld [wArenaRound], a
	ld a, $02
	ld [wEncCount], a
	ld a, [wArenaTeam2]
	ld l, a
	ld a, [$d9da]
	ld h, a
	ld a, l
	ld [wEncSpecies], a
	ld a, h
	ld [$da04], a
	call GetMonSpriteNumber
	ld [wEncGfx], a
	ld a, $01
	ld [$d7cb], a
	ld a, [wEncCount]
	or a
	ret z

	ld a, [$d9db]
	ld l, a
	ld a, [$d9dc]
	ld h, a
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	call GetMonSpriteNumber
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [wEncCount]
	cp $01
	ret z

	ld a, [$d9dd]
	ld l, a
	ld a, [$d9de]
	ld h, a
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a
	call GetMonSpriteNumber
	ld [$d7ce], a
	ld a, $01
	ld [$d7cf], a
	ret


jr_050_6898:
	ld a, $03
	ld [wArenaRound], a
	ret


CapExpAtMaxLevel::
	ld a, [hl]
	or a
	ret z

	ld a, l
	add $4b
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp $63
	jr z, jr_050_68fb

	push af
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	cp [hl]
	jr nc, jr_050_68fb

	push hl
	ld a, l
	add $b4
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	pop hl
	cp $01
	jr z, jr_050_68fb

	ld a, [hl]
	push af
	ld a, l
	add $ff
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	pop af
	ld b, [hl]
	ld [hl], a
	push bc
	push hl
	ld a, [wCurPartyMember]
	call CheckLevelUpDue
	pop hl
	pop bc
	ld [hl], b
	jr c, jr_050_68fb

	ld a, l
	add $02
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ldh a, [hNumber]
	sub $01
	ld [hli], a
	ldh a, [$ffd6]
	sbc $00
	ld [hli], a
	ldh a, [$ffd7]
	sbc $00
	ld [hl], a

jr_050_68fb:
	ret


SetFirstTurnOrder::
	ld a, [wBattlerReload]
	cp $02
	jr z, jr_050_6913

	cp $01
	jr z, jr_050_690d

	ld d, $00
	ld e, $03
	jr jr_050_6922

jr_050_690d:
	ld d, $03
	ld e, $01
	jr jr_050_6922

jr_050_6913:
	ld a, [wLinkActive]
	or a
	jr nz, jr_050_691f

	ld d, $00
	ld e, $01
	jr jr_050_6922

jr_050_691f:
	ld de, $0000

jr_050_6922:
	ld hl, wBattlerOrder
	ld b, $04
	ld c, $00

jr_050_6929:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6932

	ld [hl], d
	jr jr_050_6934

jr_050_6932:
	ld [hl], $ff

jr_050_6934:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6929

	ld hl, $dd17
	ld b, $04
	ld c, $04

jr_050_6940:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6949

	ld [hl], e
	jr jr_050_694b

jr_050_6949:
	ld [hl], $ff

jr_050_694b:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6940

	ret


BattleStepIdle::
	ret


ShowLinkIntro::
	ld de, wMonMaster
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_695f

	ld de, wMon4Master

jr_050_695f:
	ld hl, wTextArg0
	call CopyName
	ld a, $01
	ld [wTextIndex], a
	jp StartIntroText


ClassifyAndNameEnemies::
	call ClassifyEnemyGroup
	call NameFirstEnemy
	ret


ClassifyEnemyGroup::
	ld a, [wLinkActive]
	or a
	jr nz, ShowLinkIntro

	ld a, [wEncCount]
	or a
	jr z, jr_050_69bb

	cp $01
	jr z, jr_050_6999

	ld a, [$dc40]
	ld b, a
	ld a, [$dc41]
	cp b
	jr z, jr_050_69ab

	ld b, a
	ld a, [$dc42]
	cp b
	jr z, jr_050_69b9

	ld a, $05
	jr jr_050_69bb

jr_050_6999:
	ld a, [$dc40]
	ld b, a
	ld a, [$dc41]
	cp b
	jr z, jr_050_69a7

	ld a, $02
	jr jr_050_69bb

jr_050_69a7:
	ld a, $01
	jr jr_050_69bb

jr_050_69ab:
	ld a, [$dc41]
	ld b, a
	ld a, [$dc42]
	cp b
	jr z, jr_050_69a7

	ld a, $03
	jr jr_050_69bb

jr_050_69b9:
	ld a, $04

jr_050_69bb:
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ret


ShowIntroMessage::
	ld a, $00
	ld [wTextGroup], a
	ld a, [wBattleArg1]
	or a
	jr z, jr_050_69d3

	call ShowIntroSecondPart
	ret


jr_050_69d3:
	ld a, [wBattleArg0]
	cp $05
	jr z, jr_050_6a1c

	cp $04
	jr z, jr_050_6a12

	cp $03
	jr z, jr_050_6a08

	cp $02
	jr z, jr_050_69fe

	cp $01
	jr z, jr_050_69f4

	call NameFirstEnemy
	ld a, $00
	ld [wTextIndex], a
	jr jr_050_6a4f

jr_050_69f4:
	call NameFirstEnemy
	ld a, $01
	ld [wTextIndex], a
	jr jr_050_6a4f

jr_050_69fe:
	call NameFirstTwoEnemies
	ld a, $02
	ld [wTextIndex], a
	jr jr_050_6a4f

jr_050_6a08:
	call NameFirstEnemy
	ld a, $01
	ld [wTextIndex], a
	jr StartIntroTextMore

jr_050_6a12:
	call NameFirstEnemy
	ld a, $00
	ld [wTextIndex], a
	jr StartIntroTextMore

jr_050_6a1c:
	call NameFirstTwoEnemies
	ld a, $02
	ld [wTextIndex], a
	jr StartIntroTextMore

ShowIntroSecondPart::
	ld a, [wBattleArg0]
	cp $05
	jr z, jr_050_6a45

	cp $04
	jr z, jr_050_6a3b

	call NameThirdEnemy
	ld a, $00
	ld [wTextIndex], a
	jr jr_050_6a4f

jr_050_6a3b:
	call NameSecondEnemy
	ld a, $01
	ld [wTextIndex], a
	jr jr_050_6a4f

jr_050_6a45:
	call NameThirdEnemy
	ld a, $00
	ld [wTextIndex], a
	jr jr_050_6a4f

StartIntroText::
jr_050_6a4f:
	call StartBattleText
	ld hl, wBattleStep
	inc [hl]
	ret


StartIntroTextMore::
	call StartBattleText
	ld a, $01
	ld [wBattleArg1], a
	ld a, $05
	ld [wMonStats], a
	ret


NameFirstEnemy::
	ld a, $04
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetSpeciesName_50
	ret


NameFirstTwoEnemies::
	ld a, $04
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetSpeciesName_50
	ld a, $05
	ld hl, wTextArg1
	ld [wNamePos], a
	call GetSpeciesName_50
	ret


NameSecondEnemy::
	ld a, $05
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetSpeciesName_50
	ret


NameThirdEnemy::
	ld a, $06
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetSpeciesName_50
	ret


ShowBattleMessage::
	ld [wTextIndex], a

StartBattleText::
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


BattleStepTurnEnd::
	ld a, [wBattleSubStep]
	rst $00

TurnEndSteps::
	dw TurnEndClearFlags
	dw TurnEndNextBattler
	dw TurnEndStatus
	dw TurnEndPoison
	dw TurnEndCheckSides
	dw TurnEndAdvance

TurnEndClearFlags::
	ld hl, wSideFlags
	res 4, [hl]
	res 6, [hl]
	inc hl
	res 4, [hl]
	res 6, [hl]
	inc hl
	ld b, $08

jr_050_6acb:
	inc hl
	inc hl
	res 7, [hl]
	inc hl
	inc hl
	ld a, [hl]
	rrca
	and $55
	ld [hli], a
	ld a, [hl]
	and $30
	call nz, StepLifeSong
	inc hl
	ld a, [hl]
	and $c0
	ld [hli], a
	xor a
	ld [hli], a
	dec b
	jr nz, jr_050_6acb

	ld b, $08
	xor a

jr_050_6ae9:
	ld [hli], a
	dec b
	jr nz, jr_050_6ae9

	ld a, [hl]
	and $03
	ld [hli], a
	ld a, [hl]
	and $03
	ld [hli], a
	ld hl, wBattleSubStep
	inc [hl]
	xor a
	ld [wSkillUser], a
	ld [wAbsorbMP], a
	ld [wPanelMode], a
	jr TurnEndNextBattler

	db $c9

StepLifeSong::
	ld a, [hl]
	and $cf
	ld e, a
	ld a, [hl]
	rrca
	and $10
	or e
	ld [hl], a
	ret


TurnEndNextBattler::
	ld hl, wBattleSubStep
	inc [hl]
	ld a, [wSkillUser]
	call CheckBattlerPresent
	jr nc, TurnEndStatus

	ld a, $05
	ld [wBattleSubStep], a
	jp TurnEndAdvance


TurnEndStatus::
	ld hl, wBattleSubStep
	inc [hl]
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $3f
	ld d, a
	ld a, [hl]
	and $c0
	jp z, Jump_050_6b5e

	ld b, $00
	push hl
	push de
	sub $40
	jr nz, jr_050_6b4f

	call GetSkillUserName
	ld a, $dd
	call ShowBattleMessage
	xor a
	ld b, $01

jr_050_6b4f:
	pop de
	pop hl
	or d
	ld [hl], a
	ld a, $05
	ld [wBattleSubStep], a
	ld a, b
	or a
	jp z, TurnEndAdvance

	ret


Jump_050_6b5e:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $03
	jr nz, jr_050_6b74

	ld a, $05
	ld [wBattleSubStep], a
	jp TurnEndAdvance


jr_050_6b74:
	bit 0, a
	jr z, jr_050_6b81

	ld a, $e1
	ld [wBattleArg0], a
	ld d, $10
	jr jr_050_6b88

jr_050_6b81:
	ld a, $e2
	ld [wBattleArg0], a
	ld d, $06

jr_050_6b88:
	ld a, [wSkillUser]
	call GetBattlerMaxHP
	ld a, d
	call Divide16
	ld a, h
	or l
	jr nz, jr_050_6b99

	ld hl, $0001

jr_050_6b99:
	call LimitPoisonDamage
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld a, [wSkillUser]
	call GetSkillUserName
	ld hl, wTextArg1
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	call Number16ToDecimal
	ld a, [wBattleArg0]
	call ShowBattleMessage
	ld a, $05
	ld [wMonStats], a
	ret


LimitPoisonDamage::
	ld a, [wBattleArg0]
	cp $e1
	jr z, jr_050_6be7

	ld bc, $001e
	call CompareHLBC
	jr c, jr_050_6c01

	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $0b
	call Divide16
	add $1e
	ld l, a
	ld h, $00
	jr jr_050_6c01

jr_050_6be7:
	ld bc, $000a
	call CompareHLBC
	jr c, jr_050_6c01

	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $06
	call Divide16
	add $0a
	ld l, a
	ld h, $00

jr_050_6c01:
	ret


TurnEndPoison::
	ld a, [wMonStats]
	or a
	jr z, jr_050_6c14

	dec a
	ld [wMonStats], a
	or a
	ret nz

	ld a, $fd
	call ShowBattleMessage
	ret


jr_050_6c14:
	ld hl, wBattleSubStep
	inc [hl]
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	call CompareHLBC
	jr z, jr_050_6c40

	jr c, jr_050_6c40

	ld a, l
	sub c
	ld c, a
	ld a, h
	sbc b
	ld b, a
	jr jr_050_6c43

jr_050_6c40:
	ld bc, $0000

jr_050_6c43:
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, b
	or c
	jr z, jr_050_6c59

	call DrawBattlePanel
	call RefreshPanelDigits
	ld a, $05
	ld [wBattleSubStep], a
	jp TurnEndAdvance


jr_050_6c59:
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	ld hl, far_BlankEnemyPicture
	rst $10
	ld a, [wSkillUser]
	ld [wBattleArg0], a
	ld hl, far_DefeatBattler
	rst $10
	call UpdateStatusIcon_50
	ld a, $04
	ld [wBattleSubStep], a
	ld a, [wSkillUser]
	call GetSkillUserName
	ld a, $ea
	call ShowBattleMessage
	call DrawBattlePanel
	call RefreshPanelDigits
	ld a, [wLinkActive]
	or a
	ret nz

	ld a, [wSkillUser]
	cp $04
	ret c

	cp $07
	ret z

	ld a, [wSkillUser]
	ld [wJoinCandidate], a
	ret


TurnEndCheckSides::
	ld hl, wBattleSubStep
	inc [hl]
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03
	ld a, [wLinkActive]
	or a
	jr nz, jr_050_6cd3

	ld a, [wSkillUser]
	cp $04
	jr c, jr_050_6cd3

jr_050_6cb4:
	ld a, c
	call CheckBattlerPresent
	jr nc, TurnEndAdvance

	inc c
	dec b
	jr nz, jr_050_6cb4

jr_050_6cbe:
	ld a, $00
	ld [wBattlerReload], a

jr_050_6cc3:
	ld a, $0a
	ld [wBattleStep], a
	ld a, $02
	call QueueMusic
	ld a, $02
	ld [wBattleArg2], a
	ret


jr_050_6cd3:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6ce4

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	jr z, TurnEndAdvance

jr_050_6ce4:
	inc c
	dec b
	jr nz, jr_050_6cd3

	ld a, $01
	ld [wBattlerReload], a
	ld a, [wLinkActive]
	or a
	jr z, jr_050_6cc3

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_6d03

	ld a, [wSkillUser]
	cp $04
	jr nc, jr_050_6cc3

	jr jr_050_6cbe

jr_050_6d03:
	ld a, [wSkillUser]
	cp $04
	jr c, jr_050_6cc3

	jr jr_050_6cbe

TurnEndAdvance::
	ld hl, wSkillUser
	inc [hl]
	ld a, [hl]
	cp $08
	jr z, jr_050_6d22

	call CheckBattlerPresent
	jr c, TurnEndAdvance

	ld a, $01
	ld [wBattleSubStep], a
	jp TurnEndNextBattler


jr_050_6d22:
	ld bc, $0300
	ld de, $0001
	ld hl, wBattlerOrder
	ld a, [wLinkActive]
	or a
	jr z, jr_050_6d33

	ld e, $00

jr_050_6d33:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6d3c

	ld [hl], d
	jr jr_050_6d3e

jr_050_6d3c:
	ld [hl], $ff

jr_050_6d3e:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6d33

	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6d4b

	ld [hl], $01

jr_050_6d4b:
	inc hl
	inc c
	ld bc, $0304

jr_050_6d50:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6d59

	ld [hl], e
	jr jr_050_6d5b

jr_050_6d59:
	ld [hl], $ff

jr_050_6d5b:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6d50

	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6d68

	ld [hl], $01

jr_050_6d68:
	inc hl
	inc c
	ld a, $03
	ld [wBattleStep], a
	ld hl, wRunTurn
	ld a, [hl]
	cp $ff
	ret z

	inc [hl]
	ret


;@ def UpdatePlayTime()
;@ path: system/clock
;@ Counts the play time on by one frame: 60 frames make a second, 60 seconds a minute,
;@ 60 minutes an hour. The clock stops at 99:59:59.
;@ test: wPlayFrames = rand(0, 59); wPlaySeconds = rand(0, 59); wPlayMinutes = rand(0, 59); wPlayHours = rand(0, 99)
UpdatePlayTime::
;> wPlayFrames += 1
	ld a, [wPlayFrames]
	inc a
	ld [wPlayFrames], a
;> if wPlayFrames != 60:
;>     return
	cp $3c
	ret nz

;> wPlayFrames = 0
	xor a
	ld [wPlayFrames], a
;> wPlaySeconds += 1
	ld a, [wPlaySeconds]
	inc a
	ld [wPlaySeconds], a
;> if wPlaySeconds != 60:
;>     return
	cp $3c
	ret nz

;> wPlaySeconds = 0
	xor a
	ld [wPlaySeconds], a
;> wPlayMinutes += 1
	ld a, [wPlayMinutes]
	inc a
	ld [wPlayMinutes], a
;> if wPlayMinutes != 60:
;>     return
	cp $3c
	ret nz

;> wPlayMinutes = 0
	xor a
	ld [wPlayMinutes], a
;> wPlayHours += 1
	ld a, [wPlayHours]
	inc a
	ld [wPlayHours], a
;> if wPlayHours != 100:
;>     return
	cp $64
	ret nz

;> wPlayHours = 99                       # the clock stops at 99:59:59
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
	ret


;@ path: battle/panel
;@ Window layout (DrawWindowLayout_50 format: a u16 buffer offset, then tile rows ended by
;@ $D8, $D9 at the end) of the party panel at the top of the battle screen with three
;@ monsters: name tiles $70-$73 / $74-$77 / $78-$7B, slot marks $DA-$DC, an "HP" row
;@ ($E1) and an "MP" row ($E2) under each name; $EC/$EB/$ED a divider line.
StatusWindow3::
	dw $0000                     ; row 0, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $74, $75, $76, $77, $db, $e0, $78, $79, $7a, $7b, $dc, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: battle/panel
;@ Party panel layout for two monsters (see StatusWindow3).
StatusWindow2::
	dw $0000                     ; row 0, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $74, $75, $76, $77, $db, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/panel
;@ Party panel layout for one monster (see StatusWindow3).
StatusWindow1::
	dw $0000                     ; row 0, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/menu
;@ Layout of the battle menu at the bottom left: four commands in two columns (their
;@ words are text tiles $7C-$8B printed into VRAM), cursor places in BattleMenuCursors.
BattleMenuWindow::
	dw $01a0                     ; row 13, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $88, $89, $e0, $86, $89, $8a, $8b, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $7c, $81, $80, $7f, $e0, $e0, $7d, $7e, $7f, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/tactics
;@ Layout of a small two-row window at the bottom left; only UnusedTacticWhoMenu draws it.
TacticWhoWindow::
	dw $01a0                     ; row 13, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9a, $82, $9b, $82, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $84, $9c, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/orders
;@ Name plate (tiles $6C-$6F) of the monster that gets direct orders, row 8.
CommandNameWindow::
	dw $0100                     ; row 8, column 0
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $6c, $6d, $6e, $6f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/tactics
;@ Layout of the tactic window: four rows of words (text tiles $86-$96), cursor places
;@ in TacticCursors.
TacticWindow::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $96, $88, $91, $8d, $87, $8a, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $8b, $86, $94, $8a, $95, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $91, $8e, $89, $86, $90, $8e, $8c, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $90, $8b, $8b, $91, $8f, $95, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: battle/item
;@ Layout of the item list in battle: four rows of item names printed into tiles $8C-$AF.
BattleItemWindow::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/item
;@ Layout of a two-choice window under a title (tiles $85-$87), cursor places in
;@ ItemUseCursors.
ItemUseWindow::
	dw $0160                     ; row 11, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $7e, $84, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $88, $87, $89, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/item
;@ Layout of the window that picks an own monster for an item: a title and the three
;@ name tiles $70-$7B, cursor places in AllyTargetCursors.
ItemAllyTargetWindow::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/orders
;@ Layout of the window that picks an own monster as a skill's target (as
;@ ItemAllyTargetWindow with another title).
SkillAllyTargetWindow::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $86, $88, $87, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/orders
;@ Layout of the window that picks an enemy: three rows of enemy names printed into tiles
;@ $8C-$A9, cursor places in EnemyTargetCursors.
EnemyTargetWindow::
	dw $0160                     ; row 11, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $95, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $9f, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout (DrawWindowLayout_50 format) that nothing draws: a small 4x3 window at
;@ row 8, column 0.
UnusedWindow7177::
	dw $0100                     ; row 8, column 0
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $e0, $d5, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d5, $d5, $d6, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: four text rows of tiles $36-$59 at row 2, column 8.
UnusedWindow719C::
	dw $0048                     ; row 2, column 8
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $51, $52, $53, $54, $55, $56, $57, $58, $59, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/run
;@ Layout of the small yes/no window (tiles $D4-$D6 and $9D-$9E) at row 8, column 14, used
;@ when giving up a tournament battle; cursor places in YesNoCursors.
YesNoWindow::
	dw $010e                     ; row 8, column 14
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9d, $9e, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: a title and four rows at row 2, column 0.
UnusedWindow7238::
	dw $0040                     ; row 2, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $82, $83, $84, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $90, $91, $92, $93, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $94, $95, $96, $97, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $98, $99, $9a, $9b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: two rows at row 8, column 13.
UnusedWindow7292::
	dw $010d                     ; row 8, column 13
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $88, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $89, $8a, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: a title and the three name tiles, at row 9.
UnusedWindow72BC::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $82, $83, $84, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: a full-width window of three text rows (tiles
;@ $00-$35) at row 11.
UnusedWindow7306::
	dw $0160                     ; row 11, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: a small window at row 6.
UnusedWindow739B::
	dw $00c0                     ; row 6, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $9c, $d6, $d5, $e0, $e2, $e3, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e5, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: two rows at row 8, column 14.
UnusedWindow73CF::
	dw $010e                     ; row 8, column 14
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a0, $a1, $a2, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a3, $a4, $a5, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: four text rows of tiles $24-$4B at row 4.
UnusedWindow73F4::
	dw $0080                     ; row 4, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $48, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $49, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $4a, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $4b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: two rows at row 8, column 12.
UnusedWindow7474::
	dw $010c                     ; row 8, column 12
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a6, $a7, $a8, $a9, $aa, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $89, $8a, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/tactics
;@ Name plate (tiles $6C-$6F) of the monster whose tactic is being set, row 6.
TacticNameWindow::
	dw $00c0                     ; row 6, column 0
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $6c, $6d, $6e, $6f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/orders
;@ Layout of the order window for one monster: three rows (attack, skill, defend; text
;@ tiles $80-$8A), cursor places in CommandCursors.
CommandWindow::
	dw $0160                     ; row 11, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $80, $89, $82, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $84, $82, $86, $81, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $83, $8a, $85, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/orders
;@ Layout of the skill list in battle: four rows of skill names printed into tiles $8C-$AF,
;@ cursor places in SkillListCursors.
BattleSkillWindow::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ def NextBufferColumn_50(addr: hl) -> hl
;@ path: battle/screen
;@ Steps a tile address one column to the right, wrapping from column 31 back to column 0
;@ of the same 32-tile row.
NextBufferColumn_50::
;>@r return (addr & 0xFFE0) | ((addr + 1) & 0x1F)
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;=@r
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	pop af
;=@r
	ret


;@ def BattleOffsetToMap(offset: hl) -> hl
;@ path: battle/screen
;@ Turns an offset (row * 32 + column) into a BG map address counted from wBattleBGMap,
;@ wrapping around inside the 1 KiB map.
BattleOffsetToMap::
;> addr = wBattleBGMap + offset
	ld a, [wBattleBGMap]
	add l
	ld l, a
	ld a, [wBattleBGMap + 1]
	adc h
;>@r return (wBattleBGMap & 0xFC00) | (addr & 0x03FF)
	and $03
	ld h, a
	ld a, [wBattleBGMap + 1]
	and $fc
	or h
	ld h, a
;=@r
	ret


;@ def TilemapBufferAddr_50(offset: hl) -> hl
;@ path: battle/screen
;@ Address of an offset (row * 32 + column) in wTilemapBuffer.
TilemapBufferAddr_50::
;>@r return wTilemapBuffer + offset
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;=@r
	ret


;@ def PosToScreenMap_50(pos: hl) -> hl
;@ path: battle/screen
;@ BG map address of a screen position (row * 32 + column): the start of its row through
;@ BattleOffsetToMap, then stepped right column by column so the column wraps within the
;@ row.
PosToScreenMap_50::
;> addr = BattleOffsetToMap(pos & 0xFFE0)
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call BattleOffsetToMap
;> for i in range(pos & 0x1F):
	ld a, b
	and $1f
	jr z, .done

	ld b, a
.column
;>     addr = NextBufferColumn_50(addr)
	call NextBufferColumn_50
	dec b
	jr nz, .column

.done
;> return addr
	pop bc
	ret


;@ def DrawWindowLayoutVRAM_50(layout: de)
;@ path: unused
;@ Unused: draws a window layout (see DrawWindowLayout_50) straight to the BG map instead
;@ of into wTilemapBuffer. Nothing calls it.
;@ test: skip writes VRAM while waiting for the LCD
DrawWindowLayoutVRAM_50::
;>@row addr = PosToScreenMap_50(mem16[layout]); layout += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@row
	call PosToScreenMap_50
;> wLayoutRow = addr
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a
.loop
;> while True:
;>     t = mem[layout]; layout += 1
	ld a, [de]
	inc de
;>     if t == 0xD9:                      # end of the layout
;>         return
	cp $d9
	ret z

;>     if t == 0xD8:                      # next row, wrapping inside the BG map
	cp $d8
	jr nz, .tile

;>@nl         wLayoutRow = 0x9800 | ((wLayoutRow + 32) & 0x03FF)
	ld a, [wLayoutRow]
	ld l, a
	ld a, [wLayoutRow + 1]
	ld h, a
	ld a, l
	add $20
;=@nl
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, h
	and $03
;=@nl
	or $98
	ld h, a
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a
;>         addr = wLayoutRow
	jr .loop

.tile
;>     else:
;>         WriteVRAM(addr, t)
	call WriteVRAM
;>         addr = NextBufferColumn_50(addr)
	call NextBufferColumn_50
	jr .loop

;@ def DrawWindowLayout_50(layout: de)
;@ path: battle/screen
;@ Draws a window layout into wTilemapBuffer. A layout is a u16 offset (row * 32 + column
;@ in the 32-wide buffer) followed by tile numbers; $D8 starts the next row below the
;@ first tile of the current one, $D9 ends the layout. Window tiles: $FA/$EF/$FB top
;@ frame, $FE/$FF left and right sides, $FC/$EE/$FD bottom frame, $EC/$EB/$ED a divider,
;@ $E0 blank.
;@ test: skip reads a layout from ROM
DrawWindowLayout_50::
;>@row p = TilemapBufferAddr_50(mem16[layout]); layout += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@row
	call TilemapBufferAddr_50
;> wLayoutRow = p
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a

.loop
;> while (t := mem[layout]) != 0xD9:
;>     layout += 1
	ld a, [de]
	inc de
	cp $d9
	ret z

;>     if t == 0xD8:                      # next row
	cp $d8
	jr nz, .tile

;>@nl         wLayoutRow += 32
	ld a, [wLayoutRow]
	ld l, a
	ld a, [wLayoutRow + 1]
	ld h, a
	ld a, l
	add $20
;=@nl
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ld [wLayoutRow], a
;=@nl
	ld a, h
	ld [wLayoutRow + 1], a
;>         p = wLayoutRow
	jr .loop

.tile
;>     else:
;>         mem[p] = t; p += 1
	ld [hli], a
	jr .loop

;@ def RefreshPanelDigits()
;@ path: battle/panel
;@ Copies the changing parts of the party panel from wTilemapBuffer to the screen for each
;@ monster of the side shown (own side, or the link master's partner side): the mark after
;@ the name and the two 3-digit HP / MP numbers.
;@ test: skip writes VRAM while waiting for the LCD
RefreshPanelDigits::
;> count = wPartyBattlers
	ld a, [wPartyBattlers]
	ld c, a
;> if wLinkFlags & 0x02:
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .count

;>     count = wEnemyCount               # the link master shows the other side's team
	ld a, [wEnemyCount]
	ld c, a

.count
;> CopyPanelSlotToScreen(0x25, 0x62)    # first monster
	push bc
	ld b, $25
	ld c, $62
	call CopyPanelSlotToScreen
	pop bc
;> if count == 1:
;>     return
	dec c
	ret z

;> CopyPanelSlotToScreen(0x2B, 0x68)    # second monster
	push bc
	ld b, $2b
	ld c, $68
	call CopyPanelSlotToScreen
	pop bc
;> if count == 2:
;>     return
	dec c
	ret z

;> CopyPanelSlotToScreen(0x31, 0x6E)    # third monster
	push bc
	ld b, $31
	ld c, $6e
	call CopyPanelSlotToScreen
	pop bc
	ret


;@ def CopyPanelSlotToScreen(mark: b, digits: c)
;@ path: battle/panel
;@ Copies one tile at offset `mark` and two rows of three tiles at offsets `digits` and
;@ `digits` + 32 from wTilemapBuffer to the BG map at $9800.
;@ test: skip writes VRAM while waiting for the LCD
CopyPanelSlotToScreen::
;>@m WriteVRAM(0x9800 + mark, wTilemapBuffer[mark])
	ld l, b
	ld h, $98
	ld a, b
	ld de, wTilemapBuffer
	add e
	ld e, a
;=@m
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	call WriteVRAM
;>@r CopyTileRowToScreen_50(0x9800 + digits, wTilemapBuffer + digits, 3)
	ld b, $03
	ld l, c
	ld h, $98
	ld a, c
	ld de, wTilemapBuffer
	add e
;=@r
	ld e, a
	ld a, $00
	adc d
	ld d, a
	call CopyTileRowToScreen_50
;>@r2 CopyTileRowToScreen_50(0x9820 + digits, wTilemapBuffer + 0x20 + digits, 3)
	ld b, $03
	ld a, c
	add $20
	ld l, a
	ld h, $98
	ld de, wTilemapBuffer
;=@r2
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	call CopyTileRowToScreen_50
;=@r2
	ret


;@ def CopyTilemapBufferToScreen_50()
;@ path: battle/screen
;@ Copies the whole wTilemapBuffer (18 rows of 32 tiles) to the BG map at wBattleBGMap,
;@ wrapping inside the 1 KiB map.
;@ test: skip writes VRAM while waiting for the LCD
CopyTilemapBufferToScreen_50::
;> dest = wBattleBGMap
	ld a, [wBattleBGMap]
	ld l, a
	ld a, [wBattleBGMap + 1]
	ld h, a
;> src = wTilemapBuffer
	ld de, wTilemapBuffer
;> for row in range(18):
	ld c, $12

.row
;>     src = CopyTileRowToScreen_50(dest, src, 32)
	ld b, $20
	push hl
	call CopyTileRowToScreen_50
	pop hl
;>@d     dest = 0x9800 | ((dest + 32) & 0x03FF)
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
	or $98
;=@d
	ld h, a
	pop bc
	dec c
	jr nz, .row

	ret


;@ def CopyTileRowToScreen_50(dest: hl, src: de, count: b) -> de
;@ path: battle/screen
;@ Writes `count` tiles from `src` to the BG map at `dest`, the column wrapping within the
;@ 32-tile row. Returns the source address after the last tile.
;@ test: skip writes VRAM while waiting for the LCD
CopyTileRowToScreen_50::
.loop
;> for i in range(count):
;>     WriteVRAM(dest, mem[src])
	ld a, [de]
	call WriteVRAM
;>@n     dest = (dest & 0xFFE0) | ((dest + 1) & 0x1F)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@n
	ld l, a
	pop af
	or l
	ld l, a
;>     src += 1
	inc de
	dec b
	jr nz, .loop

;> return src
	ret


;@ def PrintTextToTiles_50(tiles: hl, lines: e, length: d)
;@ path: battle/screen
;@ Prints the text wTextGroup / wTextIndex at once into the letter tiles at `tiles` (a text
;@ box of `lines` lines of `length` letters), then restores the text box settings.
;@ test: skip prints through another bank
PrintTextToTiles_50::
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;> saved_lines = wTextBoxLines
;> saved_length = wTextBoxLineLength
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = length
	ld a, d
	ld [wTextBoxLineLength], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = saved_lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved_length
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def PrintNameToTiles_50(tiles: hl, name: de)
;@ path: battle/screen
;@ Prints a name (copied into wTextArg0, shown by text $0200) at once into the four letter
;@ tiles at `tiles`, then restores the text box settings.
;@ test: skip prints through another bank
PrintNameToTiles_50::
;> CopyName(wTextArg0, name)
	push hl
	ld hl, wTextArg0
	call CopyName
	pop hl
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;> saved_lines = wTextBoxLines
;> saved_length = wTextBoxLineLength
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 1
	ld de, $0401
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 4
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0                        # text $0200 shows wTextArg0
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = saved_lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved_length
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def ClearTilemapBuffer_50()
;@ path: battle/screen
;@ Fills wTilemapBuffer (576 tiles) with the blank tile $E0.
ClearTilemapBuffer_50::
;>@f fill(wTilemapBuffer, 0x240, 0xE0)
	ld hl, wTilemapBuffer
	ld bc, $0240
.loop
	ld a, $e0
	ld [hli], a
	dec bc
;=@f
	ld a, b
	or c
	jr nz, .loop

	ret


;@ def ClearScreenMap_50()
;@ path: unused
;@ Unused: fills the whole BG map at $9800 with the blank tile $E0.
;@ test: skip writes VRAM while waiting for the LCD
ClearScreenMap_50::
;>@l for i in range(0x400):
	ld hl, $9800
	ld bc, $0400
.loop
;>     WriteVRAMInc(0x9800 + i, 0xE0)
	ld a, $e0
	call WriteVRAMInc
;=@l
	dec bc
	ld a, b
	or c
	jr nz, .loop

	ret

;@ def UpdateListCursor_50(cursor: hl, table: de, rows: b, count: c)
;@ path: menu/cursor
;@ Moves the cursor of a paged list (skills, items): `cursor` points at the row (bit 7 =
;@ chosen) and the page number, `table` at the list's cursor table (the page marker
;@ position, then one position per row), `rows` is the page size and `count` the number of
;@ entries. Left / Right turn the pages (wrapping, and pulling the row up on a short last
;@ page); otherwise the page number is drawn and Up / Down move within the page
;@ (UpdateMenuCursor_50). Pages don't turn while a text prints.
;@ test: skip draws to the screen
UpdateListCursor_50::
;> turned = False
;> wListLastRows = count
	ld a, c
	ld [wListLastRows], a
;> rows_table = table + 2
	inc de
	inc de
;> if not wTextState:
	ld a, [wTextState]
	or a
	jp nz, .draw

;>     if wJoyRepeat & 0x20:              # Left: previous page, wrapping to the last
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, .right

;>         page = mem[cursor + 1] - 1
	inc hl
	ld a, [hl]
	dec a
	push af
;>@pl         pages = (count - 1) // rows + 1
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;=@pl
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
	pop af
;>         turned = True
;>         if page < 0:
	cp c
	jr c, .setPage

;>             page = pages - 1
	ld a, c
	dec a
	jr .setPage

.right
;>     elif wJoyRepeat & 0x10:            # Right: next page, wrapping to the first
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, .draw

;>         page = mem[cursor + 1] + 1
	inc hl
	ld a, [hl]
	inc a
	push af
;>@pr         pages = (count - 1) // rows + 1
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;=@pr
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
	pop af
;>         turned = True
;>         if page >= pages:
	cp c
	jr c, .setPage

;>             page = 0
	ld a, $00

.setPage
;> if turned:
;>     mem[cursor + 1] = page
	ld [hld], a
;>     if page == pages - 1:              # the last page may be short
	dec c
	cp c
	jr nz, RestartMenuCursor_50

;>@rest         rest = count % rows
	ld a, [wListLastRows]
	ld c, a
	push de
	push bc
	ld a, b
	ld b, c
;=@rest
	call Divide8
	pop bc
	pop de
;>         if rest != 0 and mem[cursor] > rest - 1:
	or a
	jr z, RestartMenuCursor_50

	dec a
	cp [hl]
	jr nc, RestartMenuCursor_50

;>             mem[cursor] = rest - 1
	ld [hl], a
;>     return RestartMenuCursor_50(cursor, rows_table)
	jr RestartMenuCursor_50

.draw
;>@pn DrawPageNumber_50(cursor, rows_table, rows, count)
	push bc
	push de
	push hl
	call DrawPageNumber_50
	pop hl
	pop de
;=@pn
	pop bc
;>@dm q, r = divmod(count - 1, rows)
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;> wListLastRows = r
	ld [wListLastRows], a
;> last_page = q
	ld a, b
	pop bc
	pop de
	ld c, a
;> if mem[cursor + 1] == last_page:
	inc hl
	ld a, [hld]
	cp c
	jr nz, UpdateMenuCursor_50

;>     rows = wListLastRows + 1          # rows on the last page
	ld a, [wListLastRows]
	inc a
	ld b, a
;> UpdateMenuCursor_50(cursor, rows, rows_table)

;@ def UpdateMenuCursor_50(cursor: hl, rows: b, table: de)
;@ path: menu/cursor
;@ Moves a menu cursor with Up / Down (wrapping over `rows` rows), restarts the blink when
;@ it moved, marks it chosen (bit 7) when A is pressed, and draws it at the positions of
;@ `table` (DrawMenuCursor_50).
;@ test: skip draws to the screen
UpdateMenuCursor_50::
;> mem[cursor] &= 0x7F
	res 7, [hl]
;> if wJoyRepeat & 0x40:                  # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .down

;>     row = mem[cursor] - 1
	ld a, [hl]
	dec a
;>     if row < 0:
	cp b
	jr c, StoreMenuCursor_50

;>         row = rows - 1
	dec b
	ld a, b
;>     return StoreMenuCursor_50(cursor, row, table)
	jr StoreMenuCursor_50

.down
;> if wJoyRepeat & 0x80:                  # Down
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, FinishMenuCursor_50

;>     row = mem[cursor] + 1
	ld a, [hl]
	inc a
;>     if row >= rows:
	cp b
	jr c, StoreMenuCursor_50

;>         row = 0
	ld a, $00
;>     return StoreMenuCursor_50(cursor, row, table)
;> FinishMenuCursor_50(cursor, table)

;@ def StoreMenuCursor_50(cursor: hl, row: a, table: de)
;@ path: menu/cursor
;@ Tail of the cursor routines when the cursor moved: stores the new row, then
;@ RestartMenuCursor_50.
;@ test: skip draws to the screen
StoreMenuCursor_50::
;> mem[cursor] = row
	ld [hl], a
;> RestartMenuCursor_50(cursor, table)

;@ def RestartMenuCursor_50(cursor: hl, table: de)
;@ path: menu/cursor
;@ Restarts the cursor blink (so the moved cursor shows at once), then FinishMenuCursor_50.
;@ test: skip draws to the screen
RestartMenuCursor_50::
;> wCursorBlinkTimer = 0
	xor a
	ld [wCursorBlinkTimer], a
	push hl
	push de
	pop de
	pop hl
;> FinishMenuCursor_50(cursor, table)

;@ def FinishMenuCursor_50(cursor: hl, table: de)
;@ path: menu/cursor
;@ Tail of the cursor routines: A marks the cursor chosen (bit 7), then it is drawn at its
;@ position of `table` (DrawMenuCursor_50).
;@ test: skip draws to the screen
FinishMenuCursor_50::
;> if wJoyPressed & 0x01:                 # A chooses
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .draw

;>     mem[cursor] |= 0x80
	set 7, [hl]

.draw
;> DrawMenuCursor_50(mem[cursor], table)
	ld a, [hl]
	call DrawMenuCursor_50
	ret


;@ def UpdateGridCursor_50(cursor: hl, table: de)
;@ path: menu/cursor
;@ Moves the cursor of a 2 x 2 menu (the battle menu): Up / Down switch the row (bit 0),
;@ Left / Right the column (bit 1). Then as UpdateMenuCursor_50: blink restart, A chooses,
;@ the cursor is drawn.
;@ test: skip draws to the screen
UpdateGridCursor_50::
;> mem[cursor] &= 0x7F
	res 7, [hl]
;> if wJoyRepeat & 0xC0:                  # Up or Down: the other row
	ld a, [wJoyRepeat]
	and $c0
	jr z, .leftRight

;>     return StoreMenuCursor_50(cursor, mem[cursor] ^ 0x01, table)
	ld a, [hl]
	xor $01
	jr StoreMenuCursor_50

.leftRight
;> if not wJoyRepeat & 0x30:              # Left or Right: the other column
;>     return FinishMenuCursor_50(cursor, table)
	ld a, [wJoyRepeat]
	and $30
	jr z, FinishMenuCursor_50

;> return StoreMenuCursor_50(cursor, mem[cursor] ^ 0x02, table)
	ld a, [hl]
	xor $02
	jr StoreMenuCursor_50

;@ def ResetCursorBlink_50()
;@ path: menu/cursor
;@ Restarts the cursor blink, so the next DrawMenuCursor_50 draws at once.
ResetCursorBlink_50::
;> wCursorBlinkTimer = 0
	xor a
	ld [wCursorBlinkTimer], a
	ret


;@ def DrawMenuCursor_50(sel: a, table: de)
;@ path: menu/cursor
;@ Redraws the cursor column of a menu: every row of the cursor table (screen positions up
;@ to $FFFF) gets a blank $E0, except row sel & $7F, which gets the arrow $E8 (blinking:
;@ blank while wCursorBlinkTimer bit 4 is set) or the filled arrow $E9 once chosen (bit 7).
;@ Drawn to the screen and into wTilemapBuffer. While nothing is chosen it only redraws
;@ every 16th frame.
;@ test: skip writes VRAM while waiting for the LCD
DrawMenuCursor_50::
;> if not sel & 0x80:
	ld c, a
	bit 7, a
	jr nz, .draw

;>     t = wCursorBlinkTimer & 0x0F
	ld a, [wCursorBlinkTimer]
	and $0f
	push af
;>     wCursorBlinkTimer += 1
	ld a, [wCursorBlinkTimer]
	inc a
	ld [wCursorBlinkTimer], a
;>     if t != 0:
;>         return
	pop af
	ld a, c
	ret nz

.draw
;> row = 0
	ld c, a
	ld b, $00
.loop
;> while True:
;>     pos = mem16[table]; table += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;>     if pos == 0xFFFF:
;>         return
	and l
	cp $ff
	ret z

;>@a     addr = PosToScreenMap_50(pos); wLayoutRow = pos
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a
	push de
	push bc
;=@a
	call PosToScreenMap_50
	pop bc
	pop de
;>     if sel & 0x7F != row:
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, .tile

;>         tile = 0xE0
;>     elif sel & 0x80:
	ld a, $e9
	bit 7, c
	jr nz, .tile

;>         tile = 0xE9
;>     elif wCursorBlinkTimer & 0x10:
	ld a, [wCursorBlinkTimer]
	bit 4, a
	ld a, $e0
	jr nz, .tile

;>         tile = 0xE0
;>     else:
;>         tile = 0xE8
	ld a, $e8

.tile
;>     WriteVRAM(addr, tile)
	call WriteVRAM
;>@buf     mem[TilemapBufferAddr_50(pos)] = tile
	push af
	ld a, [wLayoutRow]
	ld l, a
	ld a, [wLayoutRow + 1]
	ld h, a
	ld a, l
;=@buf
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@buf
	ld [hl], a
;>     row += 1
	inc b
	jr .loop

;@ def DrawPageNumber_50(cursor: hl, table: de, rows: b, count: c)
;@ path: menu/cursor
;@ When the list has more entries than a page has rows, draws the page number
;@ (cursor[1] + 1, as tile $F1 + page) one tile left of the page marker position (the
;@ first entry of the cursor table; `table` points just past it), on the screen and in
;@ wTilemapBuffer.
;@ test: skip writes VRAM while waiting for the LCD
DrawPageNumber_50::
;> if rows >= count:
;>     return
	ld a, b
	cp c
	ret nc

;> page = mem[cursor + 1]
	inc hl
	ld c, [hl]
;>@pos pos = mem16[table - 2]
	dec de
	dec de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
;=@pos
	ld h, a
	inc de
;> if pos == 0xFFFF:
;>     return
	and l
	cp $ff
	ret z

;> pos -= 1
	dec hl
;>@w WriteVRAM(PosToScreenMap_50(pos), (page & 0x7F) + 0xF1)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@w
	call PosToScreenMap_50
	pop bc
	pop de
	ld a, c
	and $7f
	add $f1
;=@w
	call WriteVRAM
;>@buf mem[TilemapBufferAddr_50(pos)] = (page & 0x7F) + 0xF1
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
;=@buf
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@buf
	ld [hl], a
	ret


;@ def DrawListCursor_50(cursor: hl, table: de, rows: b, count: c)
;@ path: menu/cursor
;@ Draws a paged list's markers into wTilemapBuffer. `cursor` points at the cursor row
;@ (bit 7 = chosen), followed by the page number; `table` is the list's cursor table: the
;@ position of the page marker, then the position of each row. When the list has more
;@ entries than a page has rows the marker shows an arrow ($E7) with the page number
;@ ($F1 = "1") left of it, else a plain frame tile ($EE). Then the row cursor is drawn.
;@ test: skip draws a list from tables
DrawListCursor_50::
;> sel = mem[cursor]
	ld a, [hli]
	push af
	push hl
;>@p p = TilemapBufferAddr_50(mem16[table])
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	inc de
;=@p
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
;=@p
	ld h, a
;> tile = 0xE7 if rows < count else 0xEE    # more than one page: an arrow
	ld a, b
	cp c
	ld a, $ee
	jr nc, .onePage

	ld a, $e7

.onePage
;> mem[p] = tile
	ld [hld], a
	pop bc
;> if rows < count:
	jr nc, .marked

;>     mem[p - 1] = mem[cursor + 1] + 0xF1     # page number
	ld a, [bc]
	add $f1
	ld [hl], a
.marked
;> DrawCursorAt_50(sel, table + 2)
	pop af

;@ def DrawCursorAt_50(sel: a, table: de)
;@ path: menu/cursor
;@ Draws the cursor of entry sel & $7F of a menu cursor table (a list of screen positions)
;@ into wTilemapBuffer: a filled arrow $E9 once chosen (bit 7), else the arrow $E8 or, in
;@ the blinking-off phase, a blank $E0.
;@ test: skip draws from a table
DrawCursorAt_50::
;>@pos pos = mem16[table + 2 * (sel & 0x7F)]
	ld c, a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
;=@pos
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
;>@ps wLayoutRow = pos; PosToScreenMap_50(pos)      # result not used
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a
	push de
	push bc
;=@ps
	call PosToScreenMap_50
	pop bc
	pop de
;> if sel & 0x80:
	ld a, $e9
	bit 7, c
	jr nz, .draw

;>     tile = 0xE9
;> elif wCursorBlinkTimer & 0x10:
	ld a, [wCursorBlinkTimer]
	bit 4, a
	ld a, $e0
	jr nz, .draw

;>     tile = 0xE0
;> else:
;>     tile = 0xE8
	ld a, $e8

.draw
;>@d mem[TilemapBufferAddr_50(pos)] = tile
	push af
	ld a, [wLayoutRow]
	ld l, a
	ld a, [wLayoutRow + 1]
	ld h, a
	ld a, l
;=@d
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@d
	ld [hl], a
	ret


;@ def DrawEnemyPictures()
;@ path: battle/screen
;@ Lays out the enemy pictures in wTilemapBuffer: each enemy is a block of 6 x 6 tiles
;@ (tiles 0-35 for the first, 36-71 the second, 72-107 the third) at row 6, centred for one
;@ enemy, at columns 4 and 10 for two, at 1, 7 and 13 for three. On the link master the
;@ partner's team is the own one (positions 0-2), so its size counts.
DrawEnemyPictures::
;> if wLinkActive and wLinkFlags & 0x02:
	ld a, [wLinkActive]
	or a
	jr z, .enemies

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .enemies

;>     count = wPartyBattlers
	ld a, [wPartyBattlers]
	jr .count

.enemies
;> else:
;>     count = wEnemyCount
	ld a, [wEnemyCount]

.count
;> if count == 3:
	cp $03
	jr z, .three

;>@t1     tile = DrawPictureBlock(0, 0x00C1)
;>@t2     tile = DrawPictureBlock(tile, 0x00C7)
;>@t3     DrawPictureBlock(tile, 0x00CD)
;> elif count == 2:
	cp $02
	jr z, .two

;>@w1     tile = DrawPictureBlock(0, 0x00C4)
;>@w2     DrawPictureBlock(tile, 0x00CA)
;> else:
;>     DrawPictureBlock(0, 0x00C7)
	ld a, $00
	ld hl, $00c7
	call DrawPictureBlock
	ret

.two
;=@w1
	ld a, $00
	ld hl, $00c4
	call DrawPictureBlock
;=@w2
	ld hl, $00ca
	call DrawPictureBlock
	ret

.three
;=@t1
	ld a, $00
	ld hl, $00c1
	call DrawPictureBlock
;=@t2
	ld hl, $00c7
	call DrawPictureBlock
;=@t3
	ld hl, $00cd
	call DrawPictureBlock
	ret


;@ def DrawPictureBlock(tile: a, offset: hl) -> a
;@ path: battle/screen
;@ Writes a block of 6 x 6 consecutive tile numbers, starting with `tile`, into
;@ wTilemapBuffer at `offset` (row * 32 + column). Returns the tile after the last one.
DrawPictureBlock::
;> for row in range(6):
	ld c, $06
.row
;>     p = TilemapBufferAddr_50(offset)
	push hl
	push af
	call TilemapBufferAddr_50
	pop af
;>     for i in range(6):
	ld b, $06
.column
;>         mem[p] = tile; p += 1; tile += 1
	ld [hli], a
	inc a
	dec b
	jr nz, .column

;>     offset += 32
	pop hl
	ld de, $0020
	add hl, de
	dec c
	jr nz, .row

;> return tile
	ret


;@ def DrawMessageWindowAndPanel()
;@ path: battle/panel
;@ Draws the message window (layout $2E07 in the home bank) and the party panel into
;@ wTilemapBuffer.
;@ test: skip reads layouts from ROM
DrawMessageWindowAndPanel::
;> DrawWindowLayout_50(0x2E07)            # message window
	ld de, $2e07
	call DrawWindowLayout_50
;> DrawBattlePanel()

;@ def DrawBattlePanel()
;@ path: battle/panel
;@ Draws the party panel into wTilemapBuffer in the view wPanelMode asks for: HP and MP
;@ numbers, or levels and ailments.
;@ test: skip reads layouts from ROM
DrawBattlePanel::
;> if wPanelMode:
;>     return DrawPanelConditions(wPanelMode)
	ld a, [wPanelMode]
	or a
	jp nz, DrawPanelConditions

;> DrawPanelNumbers()

;@ def DrawPanelNumbers()
;@ path: battle/panel
;@ Draws the party panel frame and the HP / MP numbers (nothing when the party is empty,
;@ outside link battles).
;@ test: skip reads layouts from ROM
DrawPanelNumbers::
;> if not wLinkActive and wPartyCount == 0:
;>     return
	ld a, [wLinkActive]
	or a
	jr nz, .draw

	ld a, [wPartyCount]
	or a
	ret z

.draw
;> DrawPanelFrame()
	call DrawPanelFrame
;> PrintPanelHPMP()
	jr PrintPanelHPMP

;@ def DrawPanelFrame()
;@ path: battle/panel
;@ Draws the party panel layout for the number of monsters on the panel's side
;@ (StatusWindowLayouts).
;@ test: skip reads layouts from ROM
DrawPanelFrame::
;> count = wPartyBattlers
;> if wLinkFlags & 0x02:
	ld hl, StatusWindowLayouts
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .own

;>     count = wEnemyCount               # the link master's team is at positions 4-6
	ld a, [wEnemyCount]
	jr .draw

.own
	ld a, [wPartyBattlers]

.draw
;>@d DrawWindowLayout_50(mem16[StatusWindowLayouts + 2 * count])
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@d
	ld e, [hl]
	inc hl
	ld d, [hl]
	call DrawWindowLayout_50
	ret


;@ def PrintPanelHPMP()
;@ path: battle/panel
;@ Prints the HP and MP of each monster on the panel (3 digits each) into wTilemapBuffer:
;@ HP on row 3, MP on row 4, under the first, second and third name. The link master shows
;@ positions 4-6.
;@ test: skip writes the digits through other routines
PrintPanelHPMP::
;> p = wBattlerHP
;> if wLinkFlags & 0x02:
	ld hl, wBattlerHP
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .first

;>     p = wBattlerHP + 8                # positions 4-6
	ld hl, wBattlerHP + 8

.first
;>@hp1 PrintNumber3(TilemapBufferAddr_50(0x0062), mem16[p])
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0062
	call TilemapBufferAddr_50
;=@hp1
	call PrintNumber3
;>@mp1 PrintNumber3(TilemapBufferAddr_50(0x0082), mem16[p + 32])     # wBattlerMP
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@mp1
	ld hl, $0082
	call TilemapBufferAddr_50
	call PrintNumber3
;> if wPanelCount == 1:
;>     return
	ld a, [wPanelCount]
	cp $01
	ret z

;> p = wBattlerHP + 2 if not wLinkFlags & 0x02 else wBattlerHP + 10
	ld hl, wBattlerHP + 2
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .second

	ld hl, wBattlerHP + 10

.second
;>@hp2 PrintNumber3(TilemapBufferAddr_50(0x0068), mem16[p])
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0068
	call TilemapBufferAddr_50
;=@hp2
	call PrintNumber3
;>@mp2 PrintNumber3(TilemapBufferAddr_50(0x0088), mem16[p + 32])
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@mp2
	ld hl, $0088
	call TilemapBufferAddr_50
	call PrintNumber3
;> if wPanelCount == 2:
;>     return
	ld a, [wPanelCount]
	cp $02
	ret z

;> p = wBattlerHP + 4 if not wLinkFlags & 0x02 else wBattlerHP + 12
	ld hl, wBattlerHP + 4
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .third

	ld hl, wBattlerHP + 12

.third
;>@hp3 PrintNumber3(TilemapBufferAddr_50(0x006E), mem16[p])
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $006e
	call TilemapBufferAddr_50
;=@hp3
	call PrintNumber3
;>@mp3 PrintNumber3(TilemapBufferAddr_50(0x008E), mem16[p + 32])
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@mp3
	ld hl, $008e
	call TilemapBufferAddr_50
	call PrintNumber3
	ret


;@ path: unused
;@ Three code addresses inside PrintPanelHPMP (the starts of its first, second and third
;@ monster); nothing reads them.
UnusedHPPrintParts::
	dw PrintPanelHPMP
	dw PrintPanelHPMP + $2b
	dw PrintPanelHPMP + $5c

;@ path: battle/panel
;@ Party panel layout for each number of monsters (0-3) on the panel.
StatusWindowLayouts::
	dw StatusWindow1
	dw StatusWindow1
	dw StatusWindow2
	dw StatusWindow3

;@ def DrawPanelConditions(mode: a)
;@ path: battle/panel
;@ The condition view of the party panel (the Start button switches to it): for each
;@ monster on the panel the mark after its name shows $D9 when it is out of action, the HP
;@ row shows "Lv" ($DE $E4) and its level, the MP row the symbols of its ailments. The
;@ first time (mode 1) the panel is copied to the screen and the ailment symbols 2, 4, 6
;@ and 3 are loaded into tiles $DA-$DD (where the face icons of the monsters normally are);
;@ wPanelMode then becomes 2. Mode 3 switches back (DrawPanelLetters).
;@ test: skip writes VRAM
DrawPanelConditions::
;> if mode == 3:
;>     return DrawPanelLetters()
	cp $03
	jp z, DrawPanelLetters

;> DrawPanelFrame()
	call DrawPanelFrame
;> wBattleBGMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [wBattleBGMap + 1], a
;> pos = 0
	ld a, [wPanelCount]
	ld b, a
	ld c, $00
;> if wLinkFlags & 0x02:
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .slot

;>     pos = 4
	ld c, $04

.slot
;> for i in range(wPanelCount):
;>     mark = PanelSlotAddr(StatusNamePositions, pos)
	ld hl, StatusNamePositions
	call PanelSlotAddr
	push hl
;>     if CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr nc, .present

;>         mem[mark] = 0xD9               # out of action
	ld a, $d9
	jr .mark

.present
;>     else:
;>         mem[mark] = 0xE0
	ld a, $e0

.mark
	pop hl
	ld [hl], a
;>     p = PanelSlotAddr(StatusHPPositions, pos)
	ld hl, StatusHPPositions
	call PanelSlotAddr
;>     mem[p] = 0xDE; mem[p + 1] = 0xE4   # "Lv"
	ld [hl], $de
	inc hl
	ld a, $e4
	ld [hld], a
;>@f     fill(p + 32, 4, 0xE0)              # the MP row is cleared
	ld a, $20
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@f
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
;>     pos += 1
	inc c
	dec b
	jr nz, .slot

;> if wPanelMode != 2:
	ld a, [wPanelMode]
	cp $02
	jr z, .numbers

;>     CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
;>     LoadStatusIcon(0x8DA0, 2)
	ld hl, $8da0
	ld a, $02
	call LoadStatusIcon
;>     LoadStatusIcon(0x8DB0, 4)
	ld hl, $8db0
	ld a, $04
	call LoadStatusIcon
;>     LoadStatusIcon(0x8DC0, 6)
	ld hl, $8dc0
	ld a, $06
	call LoadStatusIcon
;>     LoadStatusIcon(0x8DD0, 3)
	ld hl, $8dd0
	ld a, $03
	call LoadStatusIcon
;>     wPanelMode += 1
	ld hl, wPanelMode
	inc [hl]

.numbers
;> pos = 0
	ld a, [wPanelCount]
	ld b, a
	ld c, $00
;> if wLinkFlags & 0x02:
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .level

;>     pos = 4
	ld c, $04

.level
;> for i in range(wPanelCount):
;>     p = PanelSlotAddr(StatusHPPositions, pos) + 2
	ld hl, StatusHPPositions
	call PanelSlotAddr
	inc hl
	inc hl
;>@lv     PrintNumber2(p, wBattlerLevel[pos])
	push bc
	ld a, c
	ld bc, wBattlerLevel
	add c
	ld c, a
	ld a, $00
;=@lv
	adc b
	ld b, a
	ld a, [bc]
	ld c, a
	ld b, $00
	call PrintNumber2
;>     if not CheckBattlerPresent(pos):
	pop bc
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>         p = PanelSlotAddr(StatusIconPositions, pos)
	ld hl, StatusIconPositions
	call PanelSlotAddr
;>         status = mem[wBattlerStatus + 8 * pos]
	push hl
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	pop de
;>         if status:
	ld a, [hl]
	or a
	jr z, .next

;>             if status & 0x40: PutAilmentTile(0, p)
	bit 6, [hl]
	jr z, .bit5

	ld a, $00
	call PutAilmentTile

.bit5
;>             if status & 0x20: PutAilmentTile(1, p + 1)
	inc de
	bit 5, [hl]
	jr z, .bit4

	ld a, $01
	call PutAilmentTile

.bit4
;>             if status & 0x10: PutAilmentTile(2, p + 2)
	inc de
	bit 4, [hl]
	jr z, .bit7

	ld a, $02
	call PutAilmentTile

.bit7
;>             if status & 0x80: PutAilmentTile(3, p + 3)
	inc de
	bit 7, [hl]
	jr z, .bit1

	ld a, $03
	call PutAilmentTile

.bit1
;>             if status & 0x02: PutAilmentTile(4, p + 4)
	inc de
	bit 1, [hl]
	jr z, .bit0

	ld a, $04
	call PutAilmentTile

.bit0
;>             if status & 0x01: PutAilmentTile(5, p + 4)
	bit 0, [hl]
	jr z, .next

	ld a, $05
	call PutAilmentTile

.next
;>     pos += 1
	inc c
	dec b
	jr nz, .level

;> CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
	ret


;@ def DrawPanelLetters()
;@ path: battle/panel
;@ Switches the party panel back from the condition view: the face icon tile ($DA + slot)
;@ after each name, the "HP" ($E1) and "MP" ($E2) labels, the face icons reloaded
;@ (UpdateStatusIcon_50 with wStatusIconShown cleared), then the HP / MP numbers.
;@ wPanelMode becomes 0.
;@ test: skip writes VRAM
DrawPanelLetters::
;> pos = 0
	ld a, [wPanelCount]
	ld b, a
	ld c, $00
;> if wLinkFlags & 0x02:
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .slot

;>     pos = 4
	ld c, $04

.slot
;> for i in range(wPanelCount):
;>     mem[PanelSlotAddr(StatusNamePositions, pos)] = 0xDA + (pos & 3)
	ld hl, StatusNamePositions
	call PanelSlotAddr
	ld a, c
	and $03
	add $da
	ld [hl], a
;>     p = PanelSlotAddr(StatusHPPositions, pos)
	ld hl, StatusHPPositions
	call PanelSlotAddr
;>     mem[p] = 0xE1                      # "HP"
	ld [hl], $e1
;>@mp     mem[p + 32] = 0xE2                 # "MP"
	ld a, $20
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@mp
	ld a, $e2
	ld [hli], a
;>     fill(p + 33, 3, 0xE0)
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hl], a
;>     wSkillUser = pos
	ld a, c
	ld [wSkillUser], a
;>     wSkillTarget = pos
	ld [wSkillTarget], a
;>@ic     wStatusIconShown[pos] = 0xFF
	push af
	push bc
	push de
	push hl
	ld hl, wStatusIconShown
	add l
;=@ic
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
;>     UpdateStatusIcon_50()
	call UpdateStatusIcon_50
;>@nx     pos += 1
	pop hl
	pop de
	pop bc
	pop af
	inc c
	dec b
;=@nx
	jr nz, .slot

;> wPanelMode = 0
	xor a
	ld [wPanelMode], a
;> DrawPanelNumbers()
	call DrawPanelNumbers
;> CopyTilemapBufferToScreen_50()
	call CopyTilemapBufferToScreen_50
	ret


;@ path: battle/panel
;@ Buffer offsets of the face icon / mark after each of the three names on the panel.
StatusNamePositions::
	dw $0025, $002b, $0031

;@ path: battle/panel
;@ Buffer offsets of the "HP" label of each of the three monsters on the panel.
StatusHPPositions::
	dw $0061, $0067, $006d

;@ path: battle/panel
;@ Buffer offsets of the first ailment symbol of each monster (the MP row).
StatusIconPositions::
	dw $0081, $0087, $008d

;@ path: battle/panel
;@ Tile numbers of the six ailment symbols the condition view shows (for status bits 6,
;@ 5, 4, 7, 1 and 0).
StatusIconTiles::
	db $dc, $d7, $db, $dd, $da, $d8

;@ def PanelSlotAddr(table: hl, pos: c) -> hl
;@ path: battle/panel
;@ Buffer address of the entry for panel slot pos & 3 of a table of buffer offsets.
PanelSlotAddr::
;>@a offset = mem16[table + 2 * (pos & 3)]
	ld a, c
	and $03
	add a
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@b return TilemapBufferAddr_50(offset)
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;=@b
	ret


;@ def PutAilmentTile(n: a, dest: de)
;@ path: battle/panel
;@ Writes the tile of ailment symbol `n` (StatusIconTiles) to `dest`.
PutAilmentTile::
;>@t mem[dest] = mem[StatusIconTiles + n]
	push hl
	ld hl, StatusIconTiles
	add l
	ld l, a
	ld a, $00
	adc h
;=@t
	ld h, a
	ld a, [hl]
	ld [de], a
	pop hl
	ret


;@ def LoadStatusIcon(dest: hl, icon: a)
;@ path: battle/panel
;@ Decompresses status icon `icon` (StatusFaceGfx) into VRAM at `dest`.
;@ test: skip switches banks
LoadStatusIcon::
;>@g gfx = mem16[StatusFaceGfx + 2 * icon]
	push hl
	ld hl, StatusFaceGfx
	add a
	add l
	ld l, a
	ld a, $00
;=@g
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
;> DecompressVRAM(hi(gfx), lo(gfx), dest)
	call DecompressVRAM
	ret


;@ path: battle/panel
;@ Compressed graphics of the status icons, as DecompressVRAM entry and bank: 0 healthy,
;@ 1 status bit 0 (poison), 2 bit 1, 3 bit 7, 4 bit 4, 5 bit 5, 6 bit 6, 7 out of action.
;@ Each is one tile, shown after the monster's name on the party panel.
StatusFaceGfx::
	db $02, $5b
	db $03, $5b
	db $04, $5b
	db $05, $5b
	db $06, $5b
	db $07, $5b
	db $08, $5b
	db $09, $5b

;@ def UpdateStatusIcon_50()
;@ path: battle/panel
;@ Refreshes the status icon of the own monster a skill just touched (wSkillTarget, else
;@ wSkillUser; on the link master the positions 4-6 are its own): picks the icon for its
;@ state (7 out of action, else the first of status bits 6, 5, 4, 7, 1, 0 that is set as
;@ icon 6, 5, 4, 3, 2, 1, or 0 healthy) and loads it into tile $DA + slot when it changed.
;@ test: skip writes VRAM
UpdateStatusIcon_50::
;> if wLinkActive and wLinkFlags & 0x02:
	ld a, [wLinkActive]
	or a
	jr z, .normal

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .normal

;>     pos = wSkillTarget
	ld a, [wSkillTarget]
	ld c, a
;>     if pos < 4:
	cp $04
	jr c, .masterUser

;>         if pos == 7:
;>             return
	cp $07
	ret z

	jr .masterSlot

.masterUser
;>     else:
;>         pos = wSkillUser
	ld a, [wSkillUser]
	ld c, a
;>         if pos < 4 or pos == 7:
;>             return
	cp $04
	ret c

	cp $07
	ret z

	jr .masterSlot

.normal
;> else:
;>     pos = wSkillTarget
	ld a, [wSkillTarget]
	ld c, a
;>     if pos >= 3:
	cp $03
	jr c, .slot

;>         pos = wSkillUser
	ld a, [wSkillUser]
	ld c, a
;>         if pos >= 3:
;>             return
	cp $03
	jr c, .slot

	ret

.masterSlot
;> slot = pos ^ 4 if wLinkActive and wLinkFlags & 0x02 else pos
	xor $04

.slot
;>@v dest = 0x8DA0 + 16 * slot
	push de
	swap a
	ld hl, $8da0
	add l
	ld l, a
	ld a, $00
;=@v
	adc h
	ld h, a
	push hl
;> if CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .out

;>@out     icon = 7                       # out of action
;> else:
;>     status = mem[wBattlerStatus + 8 * pos]
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
;>@i6     if status & 0x40: icon = 6
	bit 6, [hl]
	jr nz, .icon6

;>@i5     elif status & 0x20: icon = 5
	bit 5, [hl]
	jr nz, .icon5

;>@i4     elif status & 0x10: icon = 4
	bit 4, [hl]
	jr nz, .icon4

;>@i3     elif status & 0x80: icon = 3
	bit 7, [hl]
	jr nz, .icon3

;>@i2     elif status & 0x02: icon = 2
	bit 1, [hl]
	jr nz, .icon2

;>@i1     elif status & 0x01: icon = 1
	bit 0, [hl]
	jr nz, .icon1

;>     else: icon = 0
	ld a, $00
	jr .chosen

.out
;=@out
	ld a, $07
	jr .chosen

.icon6
;=@i6
	ld a, $06
	jr .chosen

.icon5
;=@i5
	ld a, $05
	jr .chosen

.icon4
;=@i4
	ld a, $04
	jr .chosen

.icon3
;=@i3
	ld a, $03
	jr .chosen

.icon2
;=@i2
	ld a, $02
	jr .chosen

.icon1
;=@i1
	ld a, $01

.chosen
;>@s if icon != wStatusIconShown[pos]:
	push af
	ld a, c
	ld hl, wStatusIconShown
	add l
	ld l, a
	ld a, $00
;=@s
	adc h
	ld h, a
	ld d, [hl]
	pop af
	cp d
;>     wStatusIconShown[pos] = icon
	call nz, StoreStatusIcon_50
;>     LoadStatusIcon(dest, icon)
	pop hl
	call nz, LoadStatusIcon
	pop de
	ret


;@ def StoreStatusIcon_50(icon: a, p: hl)
;@ path: battle/panel
;@ Stores `icon` at `p` (UpdateStatusIcon_50 calls it on a condition).
StoreStatusIcon_50::
;> mem[p] = icon
	ld [hl], a
	ret


;@ def UnusedClearAttrMap()
;@ path: unused
;@ Unused: on a Game Boy Color, clears the CGB attributes of the battle screen (18 rows of
;@ 32 tiles from wBattleBGMap in VRAM bank 1). Nothing calls it.
;@ test: skip writes VRAM
UnusedClearAttrMap::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> rVBK = 1
	ld a, $01
	ldh [rVBK], a
;> dest = wBattleBGMap
	ld a, [wBattleBGMap]
	ld l, a
	ld a, [wBattleBGMap + 1]
	ld h, a
;> for row in range(18):
	ld c, $12
.row
;>     for i in range(32):
	ld b, $20
	push hl
.column
;>         WriteVRAM(0, dest)
	ld a, $00
	call WriteVRAM
;>@n         dest = (dest & 0xFFE0) | ((dest + 1) & 0x1F)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@n
	ld l, a
	pop af
	or l
	ld l, a
	dec b
	jr nz, .column

;>@r     dest = 0x9800 | ((row_start + 32) & 0x03FF)
	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
;=@r
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, .row

;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
	ret

;@ def GetBattlerName_50(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Writes the name of battle position `pos` to `dest` and returns the address of its $F0
;@ end mark: an own monster's name from its record, an enemy's through GetEnemyName_50.
;@ test: skip copies names through other banks
GetBattlerName_50::
;> if pos >= 3:
;>     return GetEnemyName_50(pos, dest)
	cp $03
	jr nc, GetEnemyName_50

;> return GetPartyMonName_50(pos, dest)

;@ def GetPartyMonName_50(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Copies the name of party monster `pos` to `dest`; returns the address of the $F0 end.
;@ test: skip copies names through other routines
GetPartyMonName_50::
;>@c CopyName(PartyMonsterField(pos, wMonName), dest)
	push hl
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
;=@c
	push hl
	call CopyName
	pop hl

.find
;> while mem[dest] != 0xF0:
;>     dest += 1
	ld a, [hl]
	cp $f0
	ret z

	inc hl
	jr .find
;> return dest

;@ def GetLinkEnemyName_50(pos: b, dest: hl) -> hl
;@ path: battle/names
;@ Part of GetEnemyName_50 in link battles: the partner's monsters have records too, so
;@ their names are copied like the own ones (the saved bc is restored here).
;@ test: skip copies names through other routines
GetLinkEnemyName_50::
;> return GetPartyMonName_50(pos, dest)
	ld a, b
	pop bc
	jr GetPartyMonName_50

;@ def GetEnemyName_50(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Name of an enemy (or master) position: in link battles the partner's monster name; an
;@ enemy that turned into a party monster (wEnemyMorph) gets that monster's name + "Like";
;@ otherwise the species name with the enemy letter (AppendEnemyLetter).
;@ test: skip copies names through other banks
GetEnemyName_50::
;>@e if pos & 3 != 3:                      # not the master's slot
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
	pop bc
;=@e
	jr z, .species

;>     if wLinkActive:
;>         return GetLinkEnemyName_50(pos, dest)
	push bc
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, GetLinkEnemyName_50

;>@m     morph = wEnemyMorph[pos & 3]
	push hl
	ld a, b
	and $03
	ld hl, wEnemyMorph
	add l
	ld l, a
;=@m
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
;>     if morph != 0xFF:
;>         return GetLikeName_50(morph, dest)
	cp $ff
	jr nz, .morphed

	ld a, b

.morphed
	pop bc
	jr nz, GetLikeName_50

.species
;> dest = GetSpeciesName_50(pos, dest)
	push af
	call GetSpeciesName_50
	pop af
;> return AppendEnemyLetter(pos)
	ld hl, far_AppendEnemyLetter
	rst $10
	ret


;@ def GetSpeciesName_50(pos: a, dest: hl)
;@ path: battle/names
;@ Copies the species name of battle position `pos` (text $05xx in bank $41) to `dest`
;@ and remembers the position and destination for AppendEnemyLetter.
;@ test: skip copies a text through another bank
GetSpeciesName_50::
;> wNameBattler = pos
	ld [wNameBattler], a
;>@s id = 0x0500 + wBattlerSpecies[pos]
	push hl
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld a, [hl]
	ld l, a
	ld h, $05
;> wNameDest = dest
	pop de
	ld a, e
	ld [wNameDest], a
	ld a, d
	ld [wNameDest + 1], a
;> CopySystemText(id, dest)
	call CopySystemText
	ret


;@ def GetLikeName_50(slot: a, dest: hl)
;@ path: battle/names
;@ Name of an enemy that turned into party monster `slot`: that monster's name followed by
;@ "Like" ($2F $46 $48 $42); when two transformed enemies copy the same monster a number
;@ 1-3 is appended too (stored in wBattleArg1, 0 when none).
;@ test: skip copies names through other routines
GetLikeName_50::
;> end = GetPartyMonName_50(slot, dest)
	call GetPartyMonName_50
;>@k mem[end:end + 5] = [0x2F, 0x46, 0x48, 0x42, 0xF0]     # "Like"
	ld a, $2f
	ld [hli], a
	ld a, $46
	ld [hli], a
	ld a, $48
	ld [hli], a
;=@k
	ld a, $42
	ld [hli], a
	ld [hl], $f0
;> m = wEnemyMorph
	push hl
	ld hl, wEnemyMorph
;> i = wNamePos & 3
	ld a, [wNamePos]
	and $03
;> if i == 1:
	cp $01
	jr z, .second

;>@s1     n = 2 if m[0] == m[1] else 1 if m[1] == m[2] else 0
;> elif i == 2:
	cp $02
	jr z, .third

;>@s2     n = [0, 2, 3][(m[2] == m[0]) + (m[2] == m[1])]
;> else:                                 # the first enemy
;>@s0     n = 1 if m[0] == m[1] or m[0] == m[2] else 0
	ld a, [hli]
	cp [hl]
	jr z, .one

	inc hl
	cp [hl]
	jr z, .one

;=@s0
	jr .none

.second
;=@s1
	ld a, [hli]
	cp [hl]
	jr z, .two

	ld a, [hli]
	cp [hl]
	jr z, .one

;=@s1
	jr .none

.third
;=@s2
	ld d, $00
	inc hl
	inc hl
	ld a, [hld]
	dec hl
	cp [hl]
;=@s2
	jr nz, .notFirst

	inc d

.notFirst
;=@s2
	inc hl
	cp [hl]
	jr nz, .counted

	inc d

.counted
;=@s2
	ld a, d
	or a
	jr z, .none

	cp $01
	jr z, .two

;=@s2
	pop hl
	ld a, $03
	jr .store

.one
;>@st if n:
	pop hl
	ld a, $01
	jr .store

.two
;=@st
	pop hl
	ld a, $02

.store
;>     wBattleArg1 = n
	ld [wBattleArg1], a
;>     mem[end + 4] = n; mem[end + 5] = 0xF0
	ld [hli], a
	ld [hl], $f0
	ret

.none
;> else:
;>     wBattleArg1 = 0
	pop hl
	xor a
	ld [wBattleArg1], a
	ret


;@ def UnusedTargetName()
;@ path: unused
;@ Unused: the name of wSkillTarget into wTextArg2 (this entry) or wTextArg0 (5 bytes in),
;@ through GetBattlerName_50 like GetSkillUserName. Nothing calls either entry.
;@ test: skip copies names through other banks
UnusedTargetName::
;> dest = wTextArg2
	ld hl, wTextArg2
	jr .store

	ld hl, wTextArg0

.store
;> wBattleArg2 = lo(dest)
	ld a, l
	ld [wBattleArg2], a
;> wBattleArg3 = hi(dest)
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillTarget
	ld a, [wSkillTarget]
	ld [wNamePos], a
;> GetBattlerName_50(wSkillTarget, dest)
	call GetBattlerName_50
	ret

;@ def GetSkillUserName()
;@ path: battle/names
;@ Writes the name of wSkillUser into wTextArg0 for a message.
;@ test: skip copies names through other banks
GetSkillUserName::
;> wBattleArg2 = lo(wTextArg0)
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
;> wBattleArg3 = hi(wTextArg0)
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillUser
	ld a, [wSkillUser]
	ld [wNamePos], a
;> GetBattlerName_50(wSkillUser, wTextArg0)
	call GetBattlerName_50
	ret


;@ path: data
;@ Unused space at the end of bank $50 (zero bytes).
Bank50Padding::
	ds 461, $00
