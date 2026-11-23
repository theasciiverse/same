#!/bin/sh
# Builds same for the Asciiverse catalog. Leaves the binary in
# build/<platform>/same (same.exe on Windows).
#   Linux:   docker run --rm -v "$PWD":/src -w /src alpine:3.22 sh asciiverse/build.sh
#            (fully static against Alpine's ncurses; reads the system's terminfo)
#   macOS:   sh asciiverse/build.sh  (links the system's ncurses)
#   Windows: sh asciiverse/build.sh  in an MSYS2 UCRT64 or CLANGARM64 shell
#            with pdcurses installed (linked statically)
#
# -fcommon: same.h defines its globals in the header itself, which GCC 10
# and Clang 11 stopped merging by default. Outside Alpine on Linux it
# links the system's ncurses dynamically, for trying it out.
#
# Cross builds set PLATFORM (linux, macos or windows), CC, CFLAGS, LIBS
# and STRIP, e.g. a static Linux build with musl-gcc against a static
# ncursesw, or Windows with x86_64-w64-mingw32-gcc against PDCurses
# (asciiverse/release-local.sh).
set -eu
cd "$(dirname "$0")/.."
[ -n "${PLATFORM:-}" ] && platform=$PLATFORM || case "$(uname -s)" in
  Linux)  platform=linux ;;
  Darwin) platform=macos ;;
  MINGW*|MSYS*|UCRT*|CLANG*) platform=windows ;;
  *) echo "unknown platform $(uname -s)" >&2; exit 1 ;;
esac

if [ -f /etc/alpine-release ] && [ -z "${PLATFORM:-}" ]; then
  apk add --no-cache build-base ncurses-dev ncurses-static >/dev/null
fi

out=build/$platform
mkdir -p "$out"
CC=${CC:-cc}
CFLAGS=${CFLAGS:--O2 -Wno-format-truncation}
case $platform in
  linux)
    if [ -f /etc/alpine-release ]; then libs="-static -lncursesw"; else libs="-lncurses"; fi
    exe=same ;;
  macos)   libs="-lncurses"; exe=same ;;
  windows) libs="-static -lpdcurses_wincon -lwinmm"; exe=same.exe ;;
esac
# MSYS2's pdcurses (PDCursesMod) keeps curses.h in include/pdcurses and
# the console build as libpdcurses_wincon.a, built wide and UTF-8 (the
# header's endwin must match: its pdcurses.h sets these two), and plays
# sounds through winmm
inc=
[ "$platform" = windows ] && [ -d "${MSYSTEM_PREFIX:-/nonexistent}/include/pdcurses" ] \
  && inc="-I$MSYSTEM_PREFIX/include/pdcurses -DPDC_WIDE -DPDC_FORCE_UTF8"
libs=${LIBS:-$libs}
$CC $CFLAGS $inc -fcommon -I. -o "$out/$exe" src/*.c $libs
${STRIP:-strip} "$out/$exe"
