# SameGame

**Clear the board. Every last block.**

Five hundred and twelve blocks in four colours fill a board 32 wide and
16 tall. Pick any two or more of one colour touching side by side and
they vanish; everything above falls into the gap, and a column that
empties closes up from the right. Big groups pay far better than small
ones: a group of n blocks scores (n-1) squared, so two blocks earn a
single point and twenty earn 361. The whole art is in the order. Take
the small groups that join big ones together, save the colour you are
building, and try not to strand one lonely block of a colour that can
never be cleared again.

Josh Williams wrote his SameGame to be driven like vi. Move with `hjkl`
or the arrows, put a count in front (`12l`, `5j`, `3x`), clear with
`x`, `dd` or Enter, and talk to it in `:`commands. Every move can be
undone with `u` and redone with `r`, all the way back to the first.
Save a game by name with `:w`, open one with `:e`, quit with `:q`, which
refuses, vi style, while there are unsaved changes, and `:q!`, which
does not. When a game ends it plays itself back to you, the whole board
filling up again and emptying move by move.

There is more under the lid. `:easy` deals boards where one colour turns
up far more often; `:revgrav on` makes the blocks fall up; `:setw` and
`:seth` change the board's size, up to 64 by 64, and each size and
difficulty keeps its own highscore. `:god` fills the board with one
colour, and as the game's history puts it, god mode still counts on the
highscore, "because it's for cheaters".

## Playing

Run `same` in a terminal of at least 57x17.

- **h j k l** or the **arrow keys**: move; a number first moves that far
- **x**, **dd** or **Enter**: clear the group under the cursor
- **Mouse**: click a block to light up its group, click the group again
  to clear it
- **u** / **r**: undo / redo
- **n** or **:new**: a new board
- **:w** *name* save, **:e** *name* open, **:x** save and quit
- **:q** quit (when saved), **:q!** quit anyway
- **:easy**, **:hard**, **:god**: the difficulty
- **:setw** *n*, **:seth** *n*: board width and height
- **:revgrav on** / **off**: blocks fall upward
- **:animation off**: skip the replay at the end

Options: `--easy`, `--hard`, `--god`, `--reverse-gravity`, `--width n`,
`--height n`.

Saved games, highscores and your settings script live in
`$XDG_STATE_HOME/same` (`~/.local/state/same`; `%LOCALAPPDATA%\same` on
Windows). Any `:`command can go in the script, `.samerc` there, one per
line or separated by `;`, with `//` comments; it runs at every start.
Upstream's README, with the scripting language, is
`README-upstream.md`.

## Credits

- SameGame: Josh Williams (jodawill),
  https://github.com/jodawill/same, GNU GPL version 2 (`LICENSE`)
- Packaged for Asciiverse: changes listed in `PATCHES.md`

## Building

`sh asciiverse/build.sh` leaves the program in `build/<platform>/`;
static Linux builds run it in Alpine (`docker run --rm -v "$PWD":/src -w
/src alpine:3.22 sh asciiverse/build.sh`), Windows in an MSYS2 shell
with PDCurses. `asciiverse/package.sh` makes the av archive and
`.github/workflows/asciiverse-release.yml` builds every release.
