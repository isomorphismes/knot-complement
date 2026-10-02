#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tmp=${TMPDIR:-/tmp}/little-prince-$$
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
mkdir -p "$tmp"

cc_bin=${CC:-cc}

"$cc_bin" \
    -std=c11 \
    -Wall \
    -Wextra \
    -Werror \
    "$root/core/tiny_planet.c" \
    "$root/core/test_tiny_planet.c" \
    -lm \
    -o "$tmp/test-tiny-planet"

"$tmp/test-tiny-planet"
