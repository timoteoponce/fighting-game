#!/usr/bin/env bash
# Builds the Linux x86_64 version of the game into build/UlisesVsEmilia/ and packs it
# as build/UlisesVsEmilia-linux-x86_64.tar.gz.
#
# Needs Godot 4.7.x on the PATH as `godot` plus its export templates
# (Editor > Manage Export Templates, or the .tpz from the Godot releases page).
set -euo pipefail
cd "$(dirname "$0")"

GODOT="${GODOT:-godot}"
OUT=build/UlisesVsEmilia
NAME=UlisesVsEmilia

rm -rf "$OUT"
mkdir -p "$OUT"
"$GODOT" --headless --path . --import
"$GODOT" --headless --path . --export-release "Linux" "$OUT/$NAME.x86_64"
chmod +x "$OUT/$NAME.x86_64"
cp README.md "$OUT/"

tar -C build -czf "build/$NAME-linux-x86_64.tar.gz" UlisesVsEmilia
echo "Built build/$NAME-linux-x86_64.tar.gz"
