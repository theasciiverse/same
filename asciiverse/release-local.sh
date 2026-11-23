#!/bin/sh
# Builds same on a Linux machine without GitHub Actions and attaches
# the archives to the GitHub release of a tag (made if missing): static
# Linux x86-64 with musl-gcc against a static ncursesw, and Windows x86-64
# with mingw-w64 against PDCurses (wincon), both linked statically, plus
# SHA256SUMS. The release workflow builds the full set (ARM64, macOS and
# the system packages) when it runs; it uploads with --clobber, so its
# files replace these.
#
#   NCURSES_MUSL=<prefix> PDCURSES=<dir> asciiverse/release-local.sh v<version>-av.<n>
#
# NCURSES_MUSL: an ncurses 6 install prefix built with CC=musl-gcc,
#   --enable-widec --without-shared (include/ncursesw, lib/libncursesw.a),
#   with --with-terminfo-dirs naming the usual system terminfo folders.
# PDCURSES: a folder with PDCurses' curses.h and libpdcurses.a, built with
#   x86_64-w64-mingw32-gcc from pdcurses/*.c and wincon/*.c.
set -eu
cd "$(dirname "$0")/.."
tag=$1
: "${NCURSES_MUSL:?set NCURSES_MUSL}" "${PDCURSES:?set PDCURSES}"
git diff --quiet "$tag" -- . ':!asciiverse/release-local.sh' 2>/dev/null \
  || { echo "the work tree differs from $tag" >&2; exit 1; }
rm -rf build stage dist

PLATFORM=linux CC=musl-gcc CFLAGS="-O2 -I$NCURSES_MUSL/include/ncursesw -I$NCURSES_MUSL/include" \
  LIBS="-static -L$NCURSES_MUSL/lib -lncursesw" sh asciiverse/build.sh
file build/linux/same | grep -q 'statically linked' || { echo "not static" >&2; exit 1; }
sh asciiverse/package.sh x86_64-unknown-linux-musl build/linux/same

PLATFORM=windows CC=x86_64-w64-mingw32-gcc CFLAGS="-O2 -I$PDCURSES" \
  LIBS="-static -L$PDCURSES -lpdcurses" STRIP=x86_64-w64-mingw32-strip sh asciiverse/build.sh
sh asciiverse/package.sh x86_64-pc-windows-msvc build/windows/same.exe

(cd dist && sha256sum * > SHA256SUMS && cat SHA256SUMS)
gh release view "$tag" >/dev/null 2>&1 \
  || gh release create "$tag" --verify-tag --title "same $tag" --notes "same ${tag%%-av.*}, Josh Williams' SameGame with vi keys (github.com/jodawill/same), built for the Asciiverse catalog. GPL-2.0. Changes: see PATCHES.md."
gh release upload "$tag" dist/* --clobber
rm -rf build stage
