"""Puts a rendered screen next to the matching reference tile.

  python3 -I tool/screens/compare.py today ../path/to/ui-sample-screens.png

Reads build/screens/<name>.png and writes build/screens/cmp_<name>.png.
"""
import sys
from PIL import Image

TILES = {
    'today': (0, 0), 'log': (0, 1), 'timer': (0, 2), 'week': (0, 3), 'habits': (0, 4),
    'sleep': (1, 0), 'screentime': (1, 1), 'groups': (1, 2), 'insights': (1, 3), 'chat': (1, 4),
    'hobbies': (2, 0), 'milestones': (2, 1), 'summary': (2, 2), 'profile': (2, 3), 'splash': (2, 4),
}
COLS = [(8, 264), (270, 526), (534, 790), (796, 1052), (1060, 1312)]
ROWS = [(4, 502), (517, 983), (990, 1199)]


def main(name, sheet):
    r, c = TILES[name]
    ref = Image.open(sheet).convert('RGB').crop((COLS[c][0], ROWS[r][0], COLS[c][1], ROWS[r][1]))
    mine = Image.open(f'build/screens/{name}.png').convert('RGB')
    h = 1100
    ref = ref.resize((round(ref.width * h / ref.height), h), Image.LANCZOS)
    mine = mine.resize((round(mine.width * h / mine.height), h), Image.LANCZOS)
    out = Image.new('RGB', (ref.width + mine.width + 30, h), (255, 255, 255))
    out.paste(ref, (0, 0))
    out.paste(mine, (ref.width + 30, 0))
    out.save(f'build/screens/cmp_{name}.png')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
