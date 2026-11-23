"""Finds a way to clear a whole same board, for the preview driver
(asciiverse/drive.py). Same rules as the game: a group is two or more
blocks of one colour touching side by side; clearing it lets the blocks
above fall, and empty columns close up to the left. A beam search keeps
the most promising boards at each step: fewest blocks left, fewest blocks
with no partner of their colour beside them.
    python3 -I solve.py   (tries random 32x16 boards, prints the results)
"""
import random

W, H = 32, 16


def groups(cols):
    """every group of two or more: (cells, colour), cells as (col, row)"""
    seen = set()
    out = []
    for c, col in enumerate(cols):
        for r, v in enumerate(col):
            if (c, r) in seen:
                continue
            stack, cells = [(c, r)], []
            seen.add((c, r))
            while stack:
                x, y = stack.pop()
                cells.append((x, y))
                for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                    if 0 <= nx < len(cols) and 0 <= ny < len(cols[nx]) \
                            and (nx, ny) not in seen and cols[nx][ny] == v:
                        seen.add((nx, ny))
                        stack.append((nx, ny))
            if len(cells) > 1:
                out.append(cells)
    return out


def remove(cols, cells):
    gone = {}
    for x, y in cells:
        gone.setdefault(x, set()).add(y)
    new = []
    for x, col in enumerate(cols):
        if x in gone:
            col = tuple(v for y, v in enumerate(col) if y not in gone[x])
        if col:
            new.append(col)
    return tuple(new)


def lonely(cols):
    n = 0
    for x, col in enumerate(cols):
        for y, v in enumerate(col):
            if not ((y + 1 < len(col) and col[y + 1] == v) or (y > 0 and col[y - 1] == v)
                    or (x > 0 and y < len(cols[x - 1]) and cols[x - 1][y] == v)
                    or (x + 1 < len(cols) and y < len(cols[x + 1]) and cols[x + 1][y] == v)):
                n += 1
    return n


def colour_odd(cols):
    """colours with a single block left can never be cleared"""
    count = {}
    for col in cols:
        for v in col:
            count[v] = count.get(v, 0) + 1
    return sum(1 for n in count.values() if n == 1)


def solve(cols, beam=60):
    """cols: tuple of columns, each a tuple of colours from the bottom up.
    Returns [(col, row_from_bottom), ...] clicks that clear everything, or None."""
    layer = [(cols, [])]
    seen = set()
    while layer:
        nxt = []
        for b, path in layer:
            for cells in groups(b):
                nb = remove(b, cells)
                if not nb:
                    return path + [cells[0]]
                if nb in seen:
                    continue
                seen.add(nb)
                if colour_odd(nb):
                    continue
                n = sum(len(c) for c in nb)
                nxt.append((n + 2 * lonely(nb), nb, path + [cells[0]]))
        nxt.sort(key=lambda t: t[0])
        layer = [(b, p) for _, b, p in nxt[:beam]]
    return None


if __name__ == "__main__":
    import time
    for seed in range(6):
        rnd = random.Random(seed)
        cols = tuple(tuple(rnd.randrange(4) for _ in range(H)) for _ in range(W))
        t = time.time()
        r = solve(cols)
        print(seed, None if r is None else len(r), round(time.time() - t, 1), "s")
