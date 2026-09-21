#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
xdg_root=$(mktemp -d "${TMPDIR:-/tmp}/theme-nvim-test.XXXXXX")
trap 'rm -rf -- "$xdg_root"' EXIT HUP INT TERM

export XDG_CONFIG_HOME="$xdg_root/config"
export XDG_DATA_HOME="$xdg_root/data"
export XDG_STATE_HOME="$xdg_root/state"
export XDG_CACHE_HOME="$xdg_root/cache"

cd "$xdg_root"
nvim --clean --headless -i NONE \
    --cmd "set runtimepath^=$root" \
    -c "lua dofile([[$root/tests/theme_spec.lua]])"
