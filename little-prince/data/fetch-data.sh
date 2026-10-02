#!/bin/sh
set -eu

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$here/source"

base=https://svs.gsfc.nasa.gov/vis/a000000/a004700/a004720

curl -fL \
    "$base/ldem_4_uint.tif" \
    -o "$here/source/ldem_4_uint.tif"

curl -fL \
    "$base/lroc_color_2k.jpg" \
    -o "$here/source/lroc_color_2k.jpg"

printf '%s\n' \
    "Fetched NASA SVS CGI Moon Kit source assets." \
    "Do not commit little-prince/data/source/."
