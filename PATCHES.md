# Changes from upstream

This is the Asciiverse packaging of [same](https://github.com/jodawill/same),
Josh Williams' SameGame with vi-like commands (C and ncurses, GNU GPL
version 2, `LICENSE`). Upstream is the `upstream` remote; this build is
its `master` at `856146c` (2015-11-04), tagged `v0.9`. Upstream's
`issue4` branch is the same commit as `master`, so there was nothing
further to take from it; its one open issue (#4) is fixed below. The
`asciiverse` branch carries the changes below, one commit each.

## The game

Unchanged: same board (32x16, four colours), scoring ((n-1) squared),
keys, commands, scripting and texts. The screen is the same, but centred
in the terminal (below). It needs a terminal of at
least 57x17 for the default board, its side panel and its longest
question.

## Code

- **State folder** (`src/sysdep.c`): saved games, the highscores
  (`.hst-<difficulty>-<width>-<height>`) and the `.samerc` script lived
  in `~/.same`. They now live in `$XDG_STATE_HOME/same` (else
  `~/.local/state/same`; `%LOCALAPPDATA%\same` on Windows), and a
  `~/.same` from an earlier version is moved there the first time.
- **Messages as text** (`src/graphics.c`): messages were passed to
  `mvprintw` as the format, so a command like `:%n%n` (echoed back in
  "Not a command: ...") or a save name with `%` could crash the game.
- **No buffer overflows** (`src/graphics.c`, `src/save.c`,
  `src/scripts.c`, `src/command.c`, `src/hst.c`, `src/init.c`): the
  highscore prompt wrote past a buffer sized for the answer, and the
  answer's end one byte past the name; save, load, script and
  unknown-command messages were built with `strcpy`/`strcat` into 32- and
  64-byte buffers (the missing `.samerc` message crashed every start with
  a long home path; `.samerc` is now read only when there is one);
  commands are scanned with bounded widths; a save that cannot be
  created is reported instead of written through a null pointer; a save
  that cannot be read is refused before its sizes are trusted, and
  loading keeps the undo history in static memory instead of 2 MB of
  stack. The highscore name is read without its newline, and two
  variables used before being set are initialised.
- **Board size limit** (`src/board.c`, `src/flags.c`): the undo history
  holds 64x64 blocks a step, but any width or height the terminal had
  room for was accepted, and a bigger board wrote past it on the first
  move. Width and height now stop at 64.
- **Yes/no answers through curses** (`src/common.c`): `confirm()` read
  keys with stdio's `getchar()`, which PDCurses never sees.
- **Side panel on short boards** (`src/board.c`, `src/draw.c`), upstream
  issue #4: on boards shorter than 14 rows the highscore was drawn over
  "by Josh Williams", and "Highscore: Not Set" went off the top of the
  screen.
- **Mouse** (`src/graphics.c`, `src/command.c`): a click on a block
  lights up its group, a click on the lit group clears it, like Enter.
  The vi keys are unchanged.
- **Centred** (`src/graphics.c`, `src/board.c`, `src/command.c`,
  `src/save.c`): the board, the panel beside it and the command row
  under them sit in the middle of the terminal instead of its top left
  corner and bottom row, and move back to the middle when the terminal is
  resized. Loading a saved game now redraws the whole screen, which also
  brings back the "SameGame" title that a load used to leave blank.
- **No "Highscore file does not exist"** (`src/hst.c`): the first game on
  every board size started with that message, though the panel already
  says "Not Set". A highscore file that exists but cannot be read is
  still reported.
- **Windows** (`src/same.h`, `src/sysdep.c`, `src/scripts.c`,
  `src/command.c`): builds with MinGW and PDCurses. `same.h` refused
  Windows outright; it now uses PDCurses' `curses.h` with ncurses-style
  mouse events, `Sleep()` for the short pauses of the end-of-game replay,
  and the one-argument `mkdir`. Scripts are read with `fgets` and
  `strchr` instead of `getline`, `strsep` and `strtok_r`, which also makes
  a comment start at `//` as the README says (`strsep` cut at a single
  `/`). Enter also counts as `\r` and as the keypad's `KEY_ENTER`.
- `README.md`: the new save folder and the mouse.

## Build settings

`asciiverse/build.sh`, not upstream's Makefile, builds it, with
`-fcommon`: `same.h` defines its globals in the header itself, which GCC
10 and Clang 11 no longer merge by default (the link fails with
"multiple definition"). Upstream's Makefile now passes `-fcommon` too,
so `make` as the README describes builds again. Linux links ncurses statically in Alpine, so the
binary needs nothing installed and reads the system's terminfo; macOS
links the system ncurses; Windows links PDCurses statically from MSYS2.

## Packaging

- `asciiverse/build.sh` (new): the build above.
- `asciiverse/package.sh` (new): the av archive, with the program, our
  `README.md`, upstream's README as `README-upstream.md`, `LICENSE` and
  this file.
- `asciiverse/nfpm.yaml` (new): .deb, .rpm, .apk and Arch packages named
  `same`, with the program as `/usr/bin/same`.
- `.github/workflows/asciiverse-release.yml` (new): av archives for Linux
  (static, x86-64 and ARM64), macOS (Intel and Apple silicon) and Windows
  (x86-64 and ARM64), the system packages and SHA256SUMS, on a `*-av.*`
  tag.
- `asciiverse/release-local.sh` (new): builds the static Linux x86-64
  (musl-gcc and a static ncursesw) and Windows x86-64 (mingw-w64 and
  PDCurses) archives on a Linux machine and attaches them to a tag's
  release, for when the workflow cannot run; `asciiverse/build.sh` takes
  `PLATFORM`, `CC`, `CFLAGS`, `LIBS` and `STRIP` for such cross builds.
- `asciiverse/README.md` (new): the package README.
- `asciiverse/record-preview.sh`, `asciiverse/drive.py`,
  `asciiverse/solve.py` (new): the catalog preview, a whole board cleared
  with moves from a beam search over the board on screen.
- `asciiverse/same.toml`, `asciiverse/same.md`, `asciiverse/same.cast`
  (new): the catalog manifest, store page and preview, as drafts for hub.
- `PATCHES.md` (new): this file.
