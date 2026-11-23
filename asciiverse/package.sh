#!/bin/sh
# Packs same into its archive for av: dist/same-<target>.tar.gz (.zip for
# Windows targets), with the program, our README, upstream's README as
# README-upstream.md, the licence and PATCHES.md.
#   asciiverse/package.sh x86_64-unknown-linux-musl build/linux/same
set -eu
cd "$(dirname "$0")/.."
target=$1
binary=$2
stage=stage/same
rm -rf "$stage" && mkdir -p "$stage" dist
cp "$binary" "$stage/"
cp asciiverse/README.md "$stage/README.md"
cp README.md "$stage/README-upstream.md"
cp LICENSE PATCHES.md "$stage/"
case $target in
  *windows*)
    rm -f "dist/same-$target.zip"
    (cd "$stage" && zip -q -r "../../dist/same-$target.zip" .) ;;
  *)
    tar --owner=0 --group=0 --numeric-owner -czf "dist/same-$target.tar.gz" -C "$stage" . 2>/dev/null \
      || tar -czf "dist/same-$target.tar.gz" -C "$stage" . ;;
esac
ls -l dist
