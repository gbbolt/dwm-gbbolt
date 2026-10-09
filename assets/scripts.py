"""The map scripts of banks $0C-$0F, decoded command by command: what each map's events say and do."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import MessageFinder, Rom, SPECIES, decode, ram_names, species_cell  # noqa: E402
from story import anchors, text_banks  # noqa: E402

GROUP = 'scripts'
BANKS = {0x0C: (0x00, 0x06), 0x0D: (0x06, 0x20), 0x0E: (0x20, 0x40), 0x0F: (0x40, 0x100)}
ITEMS = 44
TEXT_CUT = 50                 # characters of a text shown beside its number

# command: (words it reads, what it is called, its routine, how it ends the script)
#   argument kinds: flag, target, msg, mon (monster number), species, item, addr, val, who, dx, dir, n,
#   map, x, y, screen, block, word, slot, amount, sound, song, raw
# 'end': nothing after it runs (the script is left); 'jump': goes on at its target only
CMDS = {
    0x00: (['flag', 'target'], 'if flag clear', 'ScriptCmdJumpIfFlagClear'),
    0x01: (['flag', 'target'], 'if flag set', 'ScriptCmdJumpIfFlagSet'),
    0x02: (['flag'], 'clear flag', 'ScriptCmdClearFlag'),
    0x03: (['flag'], 'set flag', 'ScriptCmdSetFlag'),
    0x04: (['menu', 'basemsg'], 'open window', 'ScriptCmdOpenFieldMenu'),
    0x05: (['mon'], 'battle with', 'ScriptCmdBattle'),
    0x06: ([], 'next event step', 'ScriptCmdNextEventStep'),
    0x07: ([], 'start event', 'ScriptCmdStartEvent'),
    0x08: ([], 'pause a frame', 'ScriptCmdNop'),
    0x09: (['n8'], 'wait', 'ScriptCmdWait'),
    0x0A: (['who', 'dx'], 'walk sideways', 'ScriptCmdWalkX'),
    0x0B: (['who', 'dy'], 'walk up/down', 'ScriptCmdWalkY'),
    0x0C: (['who', 'dir'], 'face', 'ScriptCmdFace'),
    0x0D: (['who', 'offset', 'val'], 'set actor byte', 'ScriptCmdSetActorByte'),
    0x0E: (['screen', 'target'], 'if on screen', 'ScriptCmdJumpIfScreen'),
    0x0F: (['map', 'x', 'y'], 'warp', 'ScriptCmdWarp', 'end'),
    0x10: (['who', 'x'], 'walk to x', 'ScriptCmdWalkToX'),
    0x11: (['who', 'y'], 'walk to y', 'ScriptCmdWalkToY'),
    0x12: (['addr', 'val'], 'write byte', 'ScriptCmdWriteByte'),
    0x13: (['addr', 'val'], 'write word', 'ScriptCmdWriteWord'),
    0x14: (['target'], 'jump', 'ScriptCmdJump', 'jump'),
    0x15: (['addr', 'val', 'target'], 'if byte', 'ScriptCmdJumpIfByte'),
    0x16: ([], 'redraw party bar', 'ScriptCmdRedrawFollowers'),
    0x17: ([], 'swap scenery tiles', 'ScriptCmdSwapTiles'),
    0x18: (['mon'], 'give monster', 'ScriptCmdGiveMonster'),
    0x19: ([], 'wait for movers', 'ScriptCmdWaitMovers'),
    0x1A: (['who', 'dx'], 'mover sideways', 'ScriptCmdMoveX'),
    0x1B: (['who', 'dy'], 'mover up/down', 'ScriptCmdMoveY'),
    0x1C: (['mover'], 'start mover', 'ScriptCmdStartMover'),
    0x1D: ([], 'keep facing', 'ScriptCmdKeepFacing'),
    0x1E: ([], 'turn while moving', 'ScriptCmdTurnWhileMoving'),
    0x1F: ([], 'set up tournament fight', 'ScriptCmdSetupArenaBattle'),
    0x20: ([], 'start battle', 'ScriptCmdStartBattle'),
    0x21: (['sound'], 'play sound', 'ScriptCmdPlaySound'),
    0x22: ([], 'fast movers', 'ScriptCmdFastMovers'),
    0x23: (['slot', 'target'], 'if knows skill group A', 'ScriptCmdJumpIfHasSkillsA'),
    0x24: (['block'], 'draw tiles', 'ScriptCmdDrawScriptTiles'),
    0x25: ([], 'release monster', 'ScriptCmdReleaseMonster'),
    0x26: ([], 'fade out, reload map', 'ScriptCmdFadeOut'),
    0x27: ([], 'heal party', 'ScriptCmdHealParty'),
    0x28: (['target'], 'if monster slots full', 'ScriptCmdJumpIfMonstersFull'),
    0x29: (['mon'], 'add monster', 'ScriptCmdAddMonster'),
    0x2A: (['item'], 'give item', 'ScriptCmdGiveItem'),
    0x2B: (['target'], 'if named monster', 'ScriptCmdJumpIfNamedMonster'),
    0x2C: (['target'], 'if bag full', 'ScriptCmdJumpIfBagFull'),
    0x2D: (['slot'], 'monster reaction', 'ScriptCmdMonsterReaction'),
    0x2E: (['n'], 'pick from table', 'ScriptCmdPickFromTable'),
    0x2F: (['addr'], 'increment byte', 'ScriptCmdIncByte'),
    0x30: (['slot', 'target'], 'if attack 100+', 'ScriptCmdJumpIfAttack100'),
    0x31: (['target'], 'if library 100+', 'ScriptCmdJumpIfLibrary100'),
    0x32: (['slot', 'target'], 'if species $AF', 'ScriptCmdJumpIfSpeciesAF'),
    0x33: (['amount'], 'give gold', 'ScriptCmdGiveGold'),
    0x34: (['slot', 'target'], 'if knows skill group B', 'ScriptCmdJumpIfHasSkillsB'),
    0x35: ([], 'heal party', 'ScriptCmdHealParty2'),
    0x36: ([], 'boss battle', 'ScriptCmdBossBattle'),
    0x37: (['n'], 'give prize item', 'ScriptCmdGivePrizeItem'),
    0x38: (['slot', 'target'], 'if knows skill group C', 'ScriptCmdJumpIfHasSkillsC'),
    0x39: (['msg'], 'print text now', 'ScriptCmdPrintMessage'),
    0x3A: ([], 'leader leaves', 'ScriptCmdLeaderLeaves', 'end'),
    0x3B: (['map', 'x', 'y'], 'warp without fade', 'ScriptCmdWarpNoFade', 'end'),
    0x3C: ([], 'next box at the bottom', 'ScriptCmdSetScriptFlag0'),
    0x3D: ([], 'next box at the top', 'ScriptCmdSetScriptFlag1'),
    0x3E: ([], 'leave the field', 'ScriptCmdEndGameMode'),
    0x3F: ([], 'name the leader\'s species', 'ScriptCmdCopyLeaderSpecies'),
    0x40: (['species', 'target'], 'if owns species', 'ScriptCmdJumpIfOwnsSpecies'),
    0x41: (['song'], 'play music', 'ScriptCmdPlayMusic'),
    0x42: (['raw', 'who'], 'save return point for window', 'ScriptCmdSaveReturnMenu'),
    0x43: ([], 'warp back', 'ScriptCmdReturnWarp', 'end'),
    0x44: ([], 'back: face and print', 'ScriptCmdReturnMenuText'),
    0x45: ([], 'restore party', 'ScriptCmdRestoreParty'),
    0x46: ([], 'wait for sound', 'ScriptCmdWaitSoundEnd'),
    0x47: (['who'], 'face up', 'ScriptCmdActorFaceUp'),
    0x48: (['who'], 'face down', 'ScriptCmdActorFaceDown'),
    0x49: (['who'], 'face left', 'ScriptCmdActorFaceLeft'),
    0x4A: (['who'], 'face right', 'ScriptCmdActorFaceRight'),
    0x4B: ([], 'restore music', 'ScriptCmdRestoreMusic'),
    0x4C: ([], 'wait for the pad', 'ScriptCmdWaitDPad'),
    0x4D: (['frames'], 'wait', 'ScriptCmdWaitFrames'),
    0x4E: ([], 'save return point', 'ScriptCmdSaveReturnPoint'),
    0x4F: ([], 'warp back', 'ScriptCmdReturnWarp2', 'end'),
    0x50: ([], 'face back', 'ScriptCmdReturnFace'),
    0x51: ([], 'library rank', 'ScriptCmdLibraryRank'),
    0x52: ([], 'random battle', 'ScriptCmdRandomBattle'),
    0x53: ([], 'face actor 1', 'ScriptCmdFaceActor1'),
    0x54: ([], 'give random item', 'ScriptCmdGiveRandomItem'),
    0x55: ([], 'lose random item', 'ScriptCmdLoseRandomItem'),
    0x56: ([], 'lose a tenth of the gold', 'ScriptCmdLoseTenthOfGold'),
    0x57: ([], 'give random seed', 'ScriptCmdGiveRandomSeed'),
    0x58: ([], 'skip floors', 'ScriptCmdSkipFloors', 'end'),
    0x59: (['slot'], 'boost weakest stat', 'ScriptCmdBoostWeakestStat'),
    0x5A: (['mon'], 'tournament battle with', 'ScriptCmdSpecialBattle'),
    0x5B: ([], 'start tournament battle', 'ScriptCmdStartSpecialBattle'),
    0x5C: ([], 'set up tournament class', 'ScriptCmdSetupTournament'),
    0x5D: ([], 'give tournament prize', 'ScriptCmdGivePrize'),
    0x5E: ([], 'start the shooting stars', 'ScriptCmdStartShootingStars'),
    0x5F: (['slot', 'target'], 'if at level cap', 'ScriptCmdJumpIfLevelBelowCap'),
    0x60: (['target'], 'pay per level, else', 'ScriptCmdPayPerLevel'),
    0x61: (['block'], 'draw colours', 'ScriptCmdDrawScriptAttrs'),
    0x62: ([], 'blank screen', 'ScriptCmdBlankScreen'),
    0x63: ([], 'redraw screen', 'ScriptCmdRedrawScreen'),
    0x64: (['target'], 'if party fit', 'ScriptCmdJumpIfPartyFit'),
    0x65: ([], 'wait for channels', 'ScriptCmdWaitChannelsEnd'),
}
DIRS = ['down', 'left', 'up', 'right']


def signed(v):
    return v - 0x10000 if v & 0x8000 else v


class Decoder:
    def __init__(self, ctx, rom):
        self.rom, self.r = rom, ctx.rom
        self.names = rom.texts('SysText_MonsterNames', SPECIES)
        n_items = min(ITEMS, rom.table_length('SysText_ItemNames', 'SysText_ItemDescriptions'))
        self.items = rom.texts('SysText_ItemNames', n_items)
        self.ram = ram_names()
        self.ram_sorted = sorted(self.ram)
        self.n_mons = rom.templates_count()
        banks, self.msgs = text_banks(rom, MessageFinder(ctx, rom))
        self.anchors = anchors(banks)
        self.problems = []

    # ---- argument cells
    def msg(self, v, with_text=True):
        got = self.msgs.get(v)
        if not got:
            return 'text ${:03X}'.format(v)
        p = got[3]
        link = {'asset': self.anchors[v], 'text': 'text ${:03X}'.format(v)}
        if not with_text:
            return link
        t = decode(self.r, p)
        if len(t) > TEXT_CUT:
            t = t[:TEXT_CUT].rsplit(' ', 1)[0] + ' ...'
        return [link, '"{}"'.format(t)]

    def mon(self, v):
        if v >= self.n_mons:
            return 'monster number ${:03X}'.format(v)
        t = self.rom.template(v)
        s = t['species']
        name = self.names[s] if s < SPECIES else '#{}'.format(s)
        return [{'asset': 'monster-numbers@n{}'.format(v), 'text': 'monster number ${:03X}'.format(v)},
                '({} Lv {})'.format(name, t['level'])]

    def addr(self, v):
        if v in self.ram:
            return '{} (${:04X})'.format(self.ram[v][0], v)
        import bisect
        i = bisect.bisect_right(self.ram_sorted, v) - 1
        if i >= 0:
            a = self.ram_sorted[i]
            n, size = self.ram[a]
            if v < a + size:
                return '{} + {} (${:04X})'.format(n, v - a, v)
        return '${:04X}'.format(v)

    def arg(self, kind, v, anchor):
        if kind == 'target':
            return {'asset': anchor(v), 'text': 'jump to ${:04X}'.format(v)}
        if kind == 'flag':
            return 'flag ${:03X}'.format(v)
        if kind == 'msg':
            return self.msg(v)
        if kind == 'basemsg':
            return ['base', self.msg(v, False)]
        if kind == 'mon':
            return self.mon(v)
        if kind == 'species':
            return species_cell(self.names, v & 0xFF)
        if kind == 'item':
            if 0 < v < len(self.items):
                return {'asset': 'item-list@i{}'.format(v), 'text': self.items[v]}
            return 'item #{}'.format(v)
        if kind == 'addr':
            return self.addr(v)
        if kind == 'who':
            return 'Terry' if v == 0 else 'actor {}'.format(v)
        if kind in ('dx', 'dy'):
            d = signed(v)
            return '{} px {}'.format(abs(d), ('right' if d >= 0 else 'left') if kind == 'dx' else
                                     ('down' if d >= 0 else 'up'))
        if kind == 'dir':
            return DIRS[v] if v < 4 else 'direction {}'.format(v)
        if kind == 'map':
            return 'map ${:02X}{}'.format(v & 0xFF, ' (gate floor)' if v >> 8 else '')
        if kind in ('x', 'y'):
            return '{} {}'.format(kind, v)
        if kind == 'n8':
            return '{} x 8 frames'.format(v)
        if kind == 'frames':
            return '{} frames'.format(v)
        if kind == 'n':
            return str(v)
        if kind == 'menu':
            return 'window {}'.format(v)
        if kind == 'mover':
            return '{}, movement type ${:02X}'.format('Terry' if v & 0xFF == 0 else 'actor {}'.format(v & 0xFF), v >> 8)
        if kind == 'block':
            return 'block ${:04X}'.format(v)
        if kind == 'slot':
            return 'party monster {}'.format(v)
        if kind == 'amount':
            return '{} gold'.format(v)
        if kind in ('sound', 'song'):
            return '{} ${:02X}'.format(kind, v)
        if kind == 'screen':
            return 'screen {}'.format(v)
        if kind == 'offset':
            return 'byte ${:02X}'.format(v)
        if kind == 'val':
            return '${:02X}'.format(v) if v < 0x100 else '${:04X}'.format(v)
        return '${:04X}'.format(v)


def decode_bank(dec, bank, name):
    rom, r = dec.rom, dec.r
    o = bank * 0x4000 - 0x4000                       # linear = o + CPU address
    lo, hi = BANKS[bank]
    table = rom.lin('MapScripts_{:02X}'.format(bank))
    ta = table - o
    # the table runs up to the first list it points at
    lowest, maps = 0x8000, []
    m = 0
    while ta + 2 * m < lowest and m < 0x100:
        v = rom.word(table + 2 * m)
        if not 0x4000 <= v < 0x8000:
            break
        maps.append(v)
        if lo <= m < hi:
            lowest = min(lowest, v)
        m += 1
    stand_in = maps[0] if lo > 0 else None
    # each map's list of script pointers: up to the lowest thing it or another list points at
    lists = {}
    starts = sorted(set(v for k, v in enumerate(maps) if lo <= k < hi and v != stand_in))
    for k, v in enumerate(maps):
        if not lo <= k < hi or v == stand_in:
            continue
        bound = min([s for s in starts if s > v] + [0x8000])
        ptrs, p = [], v
        while p < bound:
            w = rom.word(o + p)
            if not 0x4000 <= w < 0x8000 or w < p + 2 and w != v:
                break
            ptrs.append(w)
            bound = min(bound, w) if w > v else bound
            p += 2
        lists[k] = (v, ptrs)

    def anchor(a):
        return '{}@a{:04X}'.format(name, a)

    # decode every script: instructions by address
    instr = {}                                       # address -> (cmd or None, args, end kind)
    blocks = set()

    def run(start):
        todo, seen, vis = [start], [], set()
        while todo:
            a = todo.pop()
            while 0x4000 <= a < 0x8000 and a not in vis:
                vis.add(a)
                seen.append(a)
                if a in instr:
                    if instr[a][2] in ('end', 'jump', 'stop'):
                        if instr[a][2] == 'jump':
                            todo.append(instr[a][1][-1])
                        break
                    for k, v in zip(CMDS.get(instr[a][0], ([],))[0] if instr[a][0] is not None else [],
                                    instr[a][1]):
                        if k == 'target':
                            todo.append(v)
                    a = instr[a][3]
                    continue
                w = rom.word(o + a)
                if w == 0xFFFF:
                    instr[a] = ('stop', [], 'stop', a + 2)
                    break
                if w >> 8 != 0xFF:
                    if w not in dec.msgs:
                        dec.problems.append('{:02X}:{:04X} word ${:04X} is no message'.format(bank, a, w))
                    instr[a] = (None, [w], '', a + 2)
                    a += 2
                    continue
                c = w & 0xFF
                if c not in CMDS:
                    dec.problems.append('{:02X}:{:04X} unknown command ${:04X}'.format(bank, a, w))
                    instr[a] = ('bad', [w], 'end', a + 2)
                    break
                spec = CMDS[c]
                args = [rom.word(o + a + 2 + 2 * i) for i in range(len(spec[0]))]
                for i, k in enumerate(spec[0]):
                    if k == 'target':           # ScriptJumpTo moves by whole words from the target word
                        here = a + 2 + 2 * i
                        args[i] = here + 2 * (signed((args[i] - here) & 0xFFFF) >> 1)
                kind = spec[3] if len(spec) > 3 else ''
                instr[a] = (c, args, kind, a + 2 + 2 * len(args))
                for k, v in zip(spec[0], args):
                    if k == 'target':
                        todo.append(v)
                    if k == 'block':
                        blocks.add(v)
                if kind == 'end':
                    break
                if kind == 'jump':
                    todo.append(args[-1])
                    break
                a = instr[a][3]
        return seen

    sections, done = [], set()
    total = 0
    list_owner = {}
    for m_ in sorted(lists):
        lst, ptrs = lists[m_]
        title = 'Map ${:02X}{}: {} script{}'.format(m_, ' (shared by the actors)' if m_ == 0x70 else '',
                                                  len(ptrs), 's' if len(ptrs) != 1 else '')
        if lst in list_owner:
            sections.append({'title': title, 'text': ['The same list of scripts as map ${:02X}.'.format(list_owner[lst])]})
            continue
        list_owner[lst] = m_
        rows, ids = [], []
        for sid, sa in enumerate(ptrs):
            if sa in done:
                rows.append(['script {}'.format(sid), {'asset': anchor(sa), 'text': '${:04X}'.format(sa)},
                             'the same script as above, from ${:04X}'.format(sa)])
                ids.append('')
                continue
            reach = sorted(set(run(sa)) - done)
            first = True
            prev_end = None
            for a in reach:
                if a not in instr:
                    continue
                c, args, kind, end = instr[a]
                if prev_end is not None and a != prev_end:
                    rows.append(['', '', '...'])
                    ids.append('')
                prev_end = end
                done.add(a)
                total += 1
                if c is None:
                    cmd = [{'text': 'show', 'code': 'ScriptQueueMessage'}, dec.msg(args[0])]
                elif c == 'stop':
                    cmd = [{'text': 'end', 'code': 'RunScriptCommand'}]
                elif c == 'bad':
                    cmd = ['unknown command ${:04X}'.format(args[0])]
                else:
                    spec = CMDS[c]
                    cmd = [{'text': spec[1], 'code': spec[2]}]
                    kinds = spec[0]
                    if c == 0x0D and args[0] == 0:       # Terry: the offset is a RAM address
                        kinds = ['who', 'addr', 'val']
                    for k, v in zip(kinds, args):
                        cmd.append(dec.arg(k, v, anchor))
                rows.append(['script {}'.format(sid) if first else '', '${:04X}'.format(a), cmd])
                ids.append('a{:04X}'.format(a))
                first = False
        if rows:
            sections.append({'title': title, 'columns': ['Script', 'Address', 'Command'], 'rows': rows, 'ids': ids, 'wide': True})
    return sections, total, len(lists), blocks


def build(ctx):
    rom = Rom(ctx)
    dec = Decoder(ctx, rom)
    out = []
    for bank in sorted(BANKS):
        name = 'scripts-{:02x}'.format(bank)
        sections, total, nmaps, blocks = decode_bank(dec, bank, name)
        lo, hi = BANKS[bank]
        span = 'maps ${:02X}-${:02X}'.format(lo, hi - 1) if hi < 0x100 else 'maps ${:02X} and up'.format(lo)
        out.append({'name': name, 'type': 'card', 'title': 'Scripts of bank ${:02X}'.format(bank),
                    'unit': 'MapScripts_{:02X}'.format(bank),
                    'subtitle': '{}, {} commands'.format(span, total),
                    'summary': 'the event scripts of {}, command by command'.format(span),
                    'sections': sections,
                    'doc': ['The event scripts of {} (MapScripts_{:02X}): every map has a list of scripts, picked by '
                            'wScriptId when Terry talks to someone or steps on an event place. A script is a list of '
                            '16-bit words that the interpreter in bank 4 runs (RunScriptCommand): $FFxx is command xx '
                            'of ScriptCommandTable followed by its arguments, $FFFF ends the script, and any other '
                            'word is a message to show (ScriptQueueMessage) - the script waits until it has been '
                            'printed.'.format(span, bank),
                            'Each line is one command, with its address in the bank; the command names lead to their '
                            'routines, jumps to the line they go on at, texts to their text bank, monster numbers and '
                            'items to their sheets. Only what can be reached from the start of a script is listed; '
                            '"..." marks a gap (words no script runs, or the tile blocks that "draw tiles" and "draw '
                            'colours" point at). Flags are the story flags of wEventFlags; "who" is Terry (0) or an '
                            'actor of the map.'],
                    'users': ['MapScripts_{:02X}'.format(bank), 'GetScriptWord_{:02X}'.format(bank), 'ReadScriptWord',
                              'RunScriptCommand', 'ScriptCommandTable', 'ScriptJumpTo']})
    if os.environ.get('SCRIPTS_DEBUG'):
        print('\n'.join(dec.problems), file=sys.stderr)
    return out
