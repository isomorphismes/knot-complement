#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tmp=${TMPDIR:-/tmp}/knot-complement-recenter-$$
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
mkdir -p "$tmp"

green='\033[32m'
yellow='\033[33m'
red='\033[31m'
reset='\033[0m'

pass() { printf '%bPASS%b %s\n' "$green" "$reset" "$1"; }
skip() { printf '%bSKIP%b %s\n' "$yellow" "$reset" "$1"; }
fail() { printf '%bFAIL%b %s\n' "$red" "$reset" "$1" >&2; exit 1; }

cc_bin=${CC:-cc}
if "$cc_bin" -std=c11 -Wall -Wextra -Werror \
    "$root/c/recenter.c" "$root/c/test_recenter.c" -lm -o "$tmp/test_recenter" &&
   "$tmp/test_recenter"
then
    pass "C reference"
else
    fail "C reference"
fi

if command -v dmd >/dev/null 2>&1; then
    dmd -c "$root/d/recenter.d" -of="$tmp/recenter-d.o" && pass "D syntax"
elif command -v ldc2 >/dev/null 2>&1; then
    ldc2 -c "$root/d/recenter.d" -of="$tmp/recenter-d.o" && pass "D syntax"
elif command -v gdc >/dev/null 2>&1; then
    gdc -c "$root/d/recenter.d" -o "$tmp/recenter-d.o" && pass "D syntax"
else
    skip "D compiler unavailable"
fi

if command -v ghc >/dev/null 2>&1; then
    ghc -fno-code -outputdir "$tmp/ghc" "$root/haskell/Recenter.hs" >/dev/null &&
        pass "Haskell typecheck"
else
    skip "GHC unavailable"
fi

if command -v idris2 >/dev/null 2>&1; then
    idris2 --check "$root/idris/Recenter.idr" >/dev/null &&
        pass "Idris typecheck"
else
    skip "Idris 2 unavailable"
fi

if command -v agda >/dev/null 2>&1; then
    agda "$root/agda/Recenter.agda" >/dev/null &&
        pass "Agda typecheck"
else
    skip "Agda unavailable"
fi

if [ -n "${IDRIC_CHECK_COMMAND:-}" ]; then
    sh -c "$IDRIC_CHECK_COMMAND \"$root/idric/Recenter.idric\"" &&
        pass "Idriç check"
else
    skip "Idriç checker not configured (set IDRIC_CHECK_COMMAND)"
fi

skip "Functorial ICKY C requires the ICKY C frontend"
