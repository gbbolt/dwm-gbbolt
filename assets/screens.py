"""The opening as the game plays it from power-on: the logos, the falling star and the title screen."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _game import Machine, image, record_sound, write_png, write_video, FRAME_HZ  # noqa: E402

GROUP = 'screens'
TITLE_FRAME = 1650                              # the title screen, settled
STILLS = [(150, 'licensed', 'Licensed by Nintendo'), (300, 'eidos', 'Eidos Interactive'),
          (500, 'enix', 'Enix presents'), (1050, 'logo', 'The logo arrives')]


def build(ctx):
    m = Machine(ctx.rom)
    record_sound(m)
    frames, stills = [], {}
    want = {f: (n, t) for f, n, t in STILLS}
    for f in range(1, TITLE_FRAME + 1):
        m.run(1)
        img, colors = m.screen(), m.colors()
        frames.append((img, colors))
        if f in want:
            stills[f] = (img, colors)
    title = frames[-1]
    path, _ = ctx.file('title.png')             # gen/screens_title.png: the hub's thumbnail
    write_png(path, title[0], title[1], 2)
    vpath, url = ctx.file('opening.mp4')
    write_video(frames, vpath, sound=m.sound)
    ppath, poster = ctx.file('opening.png')
    write_png(ppath, frames[1040][0], frames[1040][1], 3)
    out = [image(title[0], title[1], name='title-screen', title='Title screen', scale=2,
                 doc=['The title screen as the game draws it after its opening, in the Game Boy Color\'s '
                      'colours. START leads to the menu of saved games.'])]
    out.append({'name': 'opening', 'type': 'video', 'title': 'Opening',
                'subtitle': '{} frames, {:.0f} s'.format(len(frames), len(frames) / FRAME_HZ),
                'file': url, 'poster': poster, 'width': 160, 'height': 144, 'fps': FRAME_HZ,
                'doc': ['What the game shows from power-on until the title screen, played by its own code '
                        'without a button pressed: the licence line, the Eidos and Enix logos, a star '
                        'falling through the night sky and the logo coming in.']})
    for f, (name, title_) in sorted((f, want[f]) for f in stills):
        img, colors = stills[f]
        out.append(image(img, colors, name='opening-' + name, title=title_, scale=2,
                         subtitle='frame {}'.format(f)))
    return out
