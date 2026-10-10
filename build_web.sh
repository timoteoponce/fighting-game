#!/usr/bin/env bash
# Builds the web version into build/web/ (index.html and the files beside it).
#
# Needs Godot 4.7.x on the PATH as `godot`, plus the matching export templates
# (Editor > Manage Export Templates, or the .tpz from the Godot releases page).
# The export is threaded, so the page must be served over https with the
# cross-origin isolation headers in deploy/nginx/pjclash.conf; opening
# index.html from disk will not run.
set -euo pipefail
cd "$(dirname "$0")"

GODOT="${GODOT:-godot}"
OUT=build/web

rm -rf "$OUT"
mkdir -p "$OUT"
# Portrait .import sidecars are gitignored, so a checkout reimports them.
# Drop any local ones first: the project default is lossless, which a browser
# can show without S3TC. A stale VRAM import comes out black on some machines.
rm -f art/portraits/*.import
"$GODOT" --headless --path . --import
"$GODOT" --headless --path . --export-release "Web" "$OUT/index.html"
echo "Built $OUT/ — serve that directory over https with the COOP/COEP headers in deploy/nginx/pjclash.conf."
