"""The dialogue of the text banks, decoded with the game's character set: one sheet per bank, every text of
every group, with the message number PrintMessage prints it by (it often lives in another bank than its
number suggests: several text banks hand groups on to others)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import MessageFinder, Rom, decode, group_length  # noqa: E402

GROUP = 'texts'
ABOUT = {0x4C: 'Group 5 holds the headings and group 6 the names of the staff credits (PrintCreditsPage).'}


def text_banks(rom, mf):
    """{bank: [(group, table address, [text addresses], {index: [message numbers]})]} for every text bank,
    and {message number: (bank, group, index, text address)} for every message PrintMessage can print."""
    tables = {}                                          # table address -> (bank, group)
    for n in rom.syms:
        if n.startswith('TextGroup_') and n.count('_') == 2:
            _, b, g = n.split('_')
            try:
                tables[rom.lin(n)] = (int(b, 16), int(g))
            except (ValueError, Exception):  # noqa: BLE001
                continue
    msgs = {}
    for n in range(0xA00):
        w = mf.where(n)
        if w:
            tables.setdefault(w[3], (w[0], w[1]))
            msgs[n] = w
    lengths = {t: group_length(rom, t, rom.next_label(t)) for t in tables}
    numbers, valid = {}, {}
    for n, (b, g, i, t) in msgs.items():
        if i < lengths[t]:                               # past the table's end: no text of this group
            numbers.setdefault((t, i), []).append(n)
            valid[n] = (b, g, i, b * 0x4000 - 0x4000 + rom.word(t + 2 * i))
    banks = {}
    for t in sorted(tables):
        b, g = tables[t]
        if b == 0x41:
            continue                                     # the system texts have their own sheet
        o = b * 0x4000 - 0x4000
        ptrs = [o + rom.word(t + 2 * i) for i in range(lengths[t])]
        banks.setdefault(b, []).append((g, t, ptrs, {i: numbers.get((t, i), []) for i in range(len(ptrs))}))
    for b in banks:
        banks[b].sort()
    return banks, valid


def anchors(banks):
    """{message number: 'texts-xx@mNNN'}, the sheet row of each message (named after its first number)."""
    out = {}
    for b, groups in banks.items():
        for g, t, ptrs, nums in groups:
            for i, ns in nums.items():
                for n in ns:
                    out[n] = 'texts-{:02x}@m{:03X}'.format(b, min(ns))
    return out


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    mf = MessageFinder(ctx, rom)
    banks, valid = text_banks(rom, mf)
    out = []
    for b in sorted(banks):
        rows, ids, count, numbered = [], [], 0, 0
        for g, t, ptrs, nums in banks[b]:
            glabel = rom.label_at(t)
            for i, p in enumerate(ptrs):
                ns = sorted(nums[i])
                rows.append([{'text': str(g), 'code': glabel} if glabel and i == 0 else g, i,
                             ', '.join('${:03X}'.format(n) for n in ns), decode(r, p)])
                ids.append('m{:03X}'.format(ns[0]) if ns else '')
                count += 1
                numbered += len(ns)
        if not count:
            continue
        unit = rom.label_at(banks[b][0][1])
        doc = ['Every text of text bank ${:02X}: {} group(s), {} texts, {} of them with a message number. Group and '
               'number are what the game puts in wTextGroup and wTextIndex before StartText_{:02X}; the message '
               'number is the one PrintMessage takes for it ($000-$9FF: MessageGroupTable picks a handler by the high '
               'byte, and some text banks hand a group on to another bank, so a number\'s text is not always in the '
               'bank the handler names). Texts without a number are printed by other code that sets the group '
               'directly. The character set and control codes are described at TextGroup_1A_0: " / " is a new '
               'line, ▼ waits for a button, ¶ clears the box, <player> is the player\'s name, <monster> or <item> '
               'a word the code puts in, <yes/no> a choice.'.format(b, len(banks[b]), count, numbered, b)]
        if b in ABOUT:
            doc.append(ABOUT[b])
        a = {'name': 'texts-{:02x}'.format(b), 'type': 'card', 'title': 'Texts of bank ${:02X}'.format(b),
             'subtitle': '{} texts'.format(count),
             'summary': '{} texts of bank ${:02X}, {} with a message number'.format(count, b, numbered),
             'sections': [{'columns': ['Group', 'No.', 'Message', 'Text'], 'rows': rows, 'ids': ids,
                           'wide': True}],
             'doc': doc, 'users': ['StartText_{:02X}'.format(b), 'PrintMessage', 'LookUpTextPointer',
                                   'MessageGroupTable', 'TextPrinterStep']}
        if unit:
            a['unit'] = unit
        out.append(a)
    return out
