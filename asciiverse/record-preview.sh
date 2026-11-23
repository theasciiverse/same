#!/bin/sh
# Records the catalog preview, asciiverse/same.cast (hub/RECORDING.md):
# a whole 32x16 board cleared, block by block, with moves from
# asciiverse/solve.py played by asciiverse/drive.py, then the end-of-game
# replay and a new highscore. The 57x17 game sits in the middle of the
# 100x30 recording: it runs in its own tmux session, shown in a borderless
# popup of the 100x30 session asciinema records (own sockets, no user
# config). The driver deals boards until it finds one it can clear before
# the recording starts. Needs asciinema 3, tmux 3.2 or newer and the
# built binary.
#   asciiverse/record-preview.sh build/linux/same
set -eu
binary=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
here=$(cd "$(dirname "$0")" && pwd)
out=$here/same.cast
home=$(mktemp -d)
trap 'tmux -L avin kill-server 2>/dev/null; tmux -L avrec kill-server 2>/dev/null; rm -rf "$home"' EXIT
mkdir -p "$home/bin"
cp "$binary" "$home/bin/same"
cd "$home"  # nothing in the recording names a local path
export HOME="$home" XDG_STATE_HOME="$home/state" PATH="$home/bin:$PATH" \
  USER=player LOGNAME=player TERM=xterm-256color COLORTERM=truecolor LANG=C.UTF-8
tmux -L avin -f /dev/null new-session -d -s in -x 57 -y 17 "same" \; set -g status off
python3 -I "$here/drive.py" "$home/ready" &
drive=$!
while [ ! -e "$home/ready" ]; do
  kill -0 "$drive" 2>/dev/null || exit 1
  sleep 0.5
done
tmux -L avrec -f /dev/null new-session -d -s rec -x 100 -y 30 \
  "while tmux -L avin has-session 2>/dev/null; do sleep 0.2; done" \; set -g status off
asciinema rec --headless --overwrite -q \
  --window-size 100x30 --idle-time-limit 2 \
  --capture-env "TERM,COLORTERM,LANG" --title "same" \
  --command "tmux -L avrec attach -t rec" "$out"
wait "$drive"
