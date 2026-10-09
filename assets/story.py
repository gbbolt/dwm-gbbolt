"""The dialogue of the text banks, decoded with the game's character set: one sheet per bank, every text of
every group, with its message number where PrintMessage reaches it."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, decode  # noqa: E402

GROUP = 'texts'
# PrintMessage's handlers (MessageGroupTable): message number of entry 0 of (bank, group)
MESSAGE_BASE = {(0x42, 0): 0x000, (0x43, 0): 0x0E2, (0x43, 1): 0x100, (0x44, 0): 0x198, (0x44, 1): 0x200,
                (0x45, 0): 0x244, (0x46, 0): 0x300, (0x47, 0): 0x3C8, (0x47, 1): 0x400, (0x48, 0): 0x474,
                (0x48, 1): 0x500, (0x49, 0): 0x512, (0x4A, 0): 0x5E0, (0x4A, 1): 0x600, (0x4A, 2): 0x700,
                (0x4B, 0): 0x7C0, (0x4B, 1): 0x800, (0x4E, 0): 0x868, (0x4E, 1): 0x900}
ABOUT = {0x4C: 'Group 5 holds the headings and group 6 the names of the staff credits (PrintCreditsPage).'}


def text_bank_groups(rom, b):
    """[(group table address, [text addresses])] of text bank b (far entries 3.. are the group tables)."""
    o = b * 0x4000
    pre = 'TextGroup_{:02X}_'.format(b)
    nums = sorted(int(n[len(pre):]) for n in rom.syms if n.startswith(pre) and n[len(pre):].isdigit())
    tables = [rom.lin(pre + str(n)) for n in nums]
    if not tables:
        return []
    lowest = min(o + rom.word(t) - 0x4000 for t in tables)
    out = []
    for g, t in enumerate(tables):
        end = tables[g + 1] if g + 1 < len(tables) else None
        ptrs = []
        p = t
        while (end is None or p < end) and p < lowest and len(ptrs) < 600:
            v = rom.word(p)
            if not 0x4000 <= v < 0x8000:
                break
            q = o + v - 0x4000
            lowest = min(lowest, q)
            ptrs.append(q)
            p += 2
        out.append((t, ptrs))
    return out


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    out = []
    for b in range(0x80):
        if b == 0x41 or 'StartText_{:02X}'.format(b) not in ctx.syms:
            continue
        try:
            groups = text_bank_groups(rom, b)
        except Exception:  # noqa: BLE001
            continue
        rows, count = [], 0
        for g, (t, ptrs) in enumerate(groups):
            base = MESSAGE_BASE.get((b, g))
            glabel = rom.label_at(t)
            for i, p in enumerate(ptrs):
                txt = decode(r, p)
                num = '${:03X}'.format(base + i) if base is not None and base + i < 0xA00 else ''
                rows.append([{'text': str(g), 'code': glabel} if glabel and i == 0 else g, i, num, txt])
                count += 1
        if not count:
            continue
        unit = rom.label_at(groups[0][0])
        doc = ['Every text of text bank ${:02X}: {} group(s), {} texts. Group and number are what the game puts '
               'in wTextGroup and wTextIndex before StartText_{:02X}; the message number is the one PrintMessage '
               'takes for it. The character set and control codes are described at TextGroup_1A_0: " / " is a new '
               'line, ▼ waits for a button, ¶ clears the box, <player> is the player\'s name, <monster> or <item> '
               'a word the code puts in, <yes/no> a choice.'.format(b, len(groups), count, b)]
        if b in ABOUT:
            doc.append(ABOUT[b])
        a = {'name': 'texts-{:02x}'.format(b), 'type': 'table', 'title': 'Texts of bank ${:02X}'.format(b),
             'subtitle': '{} texts'.format(count),
             'columns': ['Group', 'No.', 'Message', 'Text'], 'rows': rows, 'doc': doc,
             'users': ['StartText_{:02X}'.format(b), 'PrintMessage', 'TextPrinterStep']}
        if unit:
            a['unit'] = unit
        out.append(a)
    return out
