#!/usr/bin/env bash
# Task runner for PJ's Clash — thin wrappers over the Godot invocations in
# AGENTS.md, so a fresh checkout can be imported, played and verified by name.
#
# Usage: ./build.sh <task> [args...]
#
#   import            build the class cache (REQUIRED after clone / after pulling scripts)
#   run               play the game (starts fullscreen; F11/Alt+Enter toggles)
#   test              headless gameplay tests; exit 0 pass / 1 fail
#   balance           test + ~60 CPU-vs-CPU matches per pairing (slow, no pass/fail)
#   demo              CPU vs CPU
#   screen NAME       jump straight to one screen: splash title select fight setup howto options
#   linux             export the Linux build (wraps build_linux.sh)
#   web               export the web build (wraps build_web.sh)
#   clean             remove build/ and the .godot/ import cache
#
# Extra args are forwarded after `--` for run/test/balance/demo.
# Override the engine with GODOT=/path/to/godot ./build.sh <task>.
#
# run/demo/screen import on demand when the class cache is missing, so a fresh
# checkout plays with no separate step. test/balance import unconditionally,
# which also refreshes a cache left stale by a pull that added scripts.
set -euo pipefail
cd "$(dirname "$0")"

GODOT="${GODOT:-godot}"

# The class cache (.godot/global_script_class_cache.cfg) is gitignored and every
# cross-file type resolves through it, so a checkout that has never been
# imported dies on the first script with "Identifier not declared" parse errors.
# Play tasks build it on demand.
import_if_needed() {
    if [ ! -f .godot/global_script_class_cache.cfg ]; then
        echo "no .godot class cache — importing first (one-time per checkout)"
        "$GODOT" --headless --path . --import
    fi
}

usage() {
    echo "usage: ./build.sh <import|run|test|balance|demo|screen NAME|linux|web|clean> [args...]"
}

case "${1:-help}" in
    import)
        "$GODOT" --headless --path . --import
        ;;
    run)
        shift
        import_if_needed
        "$GODOT" --path . -- "$@"
        ;;
    test)
        shift
        "$GODOT" --headless --path . --import
        "$GODOT" --headless --path . -- --test "$@"
        ;;
    balance)
        shift
        "$GODOT" --headless --path . --import
        "$GODOT" --headless --path . -- --test --balance "$@"
        ;;
    demo)
        shift
        import_if_needed
        "$GODOT" --path . -- --demo "$@"
        ;;
    screen)
        import_if_needed
        "$GODOT" --path . -- --screen="${2:?usage: ./build.sh screen NAME}"
        ;;
    linux)
        ./build_linux.sh
        ;;
    web)
        ./build_web.sh
        ;;
    clean)
        rm -rf build .godot
        echo "removed build/ and .godot/ — the next run or test re-imports"
        ;;
    *)
        usage
        exit 1
        ;;
esac
