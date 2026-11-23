"""Plays same for the catalog preview (record-preview.sh).

The game runs in its own 57x17 tmux session (socket avin). Before the
recording starts, this reads each new board off the screen and asks
solve.py for a way to clear all of it, dealing new boards (n, y) until it
finds one; it then touches the file named on the command line, and
record-preview.sh starts asciinema on the 100x30 session (socket avrec),
which shows the game in a borderless popup in its middle. Then it plays
the solution with the vi keys (counts and hjkl to move, x to clear),
types a name for the highscore, and quits with :q!.
    python3 -I drive.py <ready file>
"""
import os
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import solve  # noqa: E402

READY = sys.argv[1]
W, H = solve.W, solve.H
STEP = 0.15


def tmux(sock, *args):
    return subprocess.run(["tmux", "-L", sock, *args], capture_output=True,
                          text=True).stdout


def screen():
    return tmux("avin", "capture-pane", "-p", "-t", "in").split("\n")


def board():
    """columns from the bottom up, as solve.py wants them"""
    rows = [(r + " " * W)[:W] for r in screen()[:H]]
    cols = []
    for x in range(W):
        col = tuple("abcd".index(rows[y][x].lower()) for y in range(H - 1, -1, -1)
                    if rows[y][x].lower() in "abcd")
        if col:
            cols.append(col)
    return tuple(cols)


def key(*keys, wait=STEP):
    tmux("avin", "send-keys", "-t", "in", *keys)
    time.sleep(wait)


time.sleep(1.0)
while True:
    plan = solve.solve(board())
    if plan:
        break
    key("n", wait=0.3)
    key("y", wait=0.5)
open(READY, "w").close()

# wait for asciinema's client, then open the game in the middle of it
for _ in range(100):
    if tmux("avrec", "list-clients").strip():
        break
    time.sleep(0.1)
subprocess.Popen(["tmux", "-L", "avrec", "display-popup", "-B", "-x", "21",
                  "-y", "23", "-w", "57", "-h", "17", "-E",
                  "tmux -L avin attach -t in"])
time.sleep(2.0)

cx, cy = 0, 0
model = board()
while plan:
    col, up = plan.pop(0)
    row = H - 1 - up
    dx, dy = col - cx, row - cy
    moves = []
    if dx:
        moves += (list(str(abs(dx))) if abs(dx) > 1 else []) + ["l" if dx > 0 else "h"]
    if dy:
        moves += (list(str(abs(dy))) if abs(dy) > 1 else []) + ["j" if dy > 0 else "k"]
    if moves:
        key(*moves, wait=0.12)
    cx, cy = col, row
    time.sleep(0.2)                # the group lit up
    group = next(g for g in solve.groups(model) if (col, up) in g)
    model = solve.remove(model, group)
    key("x", wait=0.1)
    if model and board() != model:  # off the plan: think again from here
        plan = solve.solve(board()) or []
        model = board()

for _ in range(80):                # the replay of the game, then the name
    if "New highscore" in "\n".join(screen()):
        break
    time.sleep(0.25)
time.sleep(0.8)
for ch in "player":
    key(ch, wait=0.12)
key("Enter", wait=0.5)
for _ in range(80):                # the replay, then "Game Over"
    if "Game Over" in "\n".join(screen()):
        break
    time.sleep(0.25)
time.sleep(2.5)                    # the new highscore beside the empty board
key(":", wait=0.3)
for ch in "q!":
    key(ch, wait=0.15)
key("Enter", wait=1.0)
