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
set -eu
cd "$(dirname "$0")/.."
case "$(uname -s)" in
  Linux)  platform=linux ;;
  Darwin) platform=macos ;;
  MINGW*|MSYS*|UCRT*|CLANG*) platform=windows ;;
  *) echo "unknown platform $(uname -s)" >&2; exit 1 ;;
esac

if [ -f /etc/alpine-release ]; then
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
  windows) libs="-static -lpdcurses"; exe=same.exe ;;
esac
$CC $CFLAGS -fcommon -I. -o "$out/$exe" src/*.c $libs
strip "$out/$exe"
