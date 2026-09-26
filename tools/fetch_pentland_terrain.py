#!/usr/bin/env python3
"""Fetch the OS Terrain 50 tiles for the central Pentland Hills.

This program deliberately knows about the terrain source, not about any
Euclidean or non-Euclidean renderer.  It can be run from any working directory.
"""

from __future__ import annotations

import datetime
import hashlib
import io
import re
import shutil
import sys
import tempfile
import urllib.request
import zipfile
from pathlib import Path


TILES = ("NT15", "NT16", "NT25", "NT26")

SOURCE_URLS = (
    "https://api.os.uk/downloads/v1/products/Terrain50/downloads"
    "?area=GB&format=ASCII%20Grid%20and%20GML%20%28Grid%29&redirect",
    "https://omseprd1stdstordownload.blob.core.windows.net/downloads/"
    "Terrain50/2020-07/allGB/ASCII%20Grid%20and%20GML/terr50_gagg_gb.zip",
)

ATTRIBUTION = "Contains OS data © Crown copyright and database right {year}."


def download_archive(destination: Path) -> str:
    last_error: Exception | None = None

    for source_url in SOURCE_URLS:
        print(f"fetching {source_url}", file=sys.stderr)
        request = urllib.request.Request(
            source_url,
            headers={"User-Agent": "knot-complement Pentland terrain fetcher"},
        )

        try:
            with urllib.request.urlopen(request, timeout=180) as response:
                with destination.open("wb") as output:
                    shutil.copyfileobj(response, output)
            with zipfile.ZipFile(destination):
                pass
            return source_url
        except Exception as error:
            last_error = error
            if destination.exists():
                destination.unlink()
            print(f"source failed: {error}", file=sys.stderr)

    raise RuntimeError("could not download an OS Terrain 50 archive") from last_error


def matching_inner_archive(outer: zipfile.ZipFile, tile: str) -> str:
    tile_lower = tile.lower()
    pattern = re.compile(
        rf"(?:^|/)data/nt/{tile_lower}_ost50grid_.*\.zip$",
        re.IGNORECASE,
    )
    matches = [name for name in outer.namelist() if pattern.search(name)]

    if len(matches) != 1:
        raise RuntimeError(
            f"expected one inner archive for {tile}, found {len(matches)}: {matches}"
        )

    return matches[0]


def copy_tile(outer: zipfile.ZipFile, tile: str, output_root: Path) -> None:
    inner_name = matching_inner_archive(outer, tile)
    inner_bytes = outer.read(inner_name)

    with zipfile.ZipFile(io.BytesIO(inner_bytes)) as inner:
        tile_dir = output_root / tile
        tile_dir.mkdir(parents=True, exist_ok=True)

        wanted_suffixes = (
            f"/{tile}.asc",
            f"/{tile}.prj",
            f"/{tile}.asc.aux.xml",
            f"/Metadata_{tile}.xml",
        )

        extracted = []
        for name in inner.namelist():
            normalized = "/" + name.replace("\\", "/")
            if any(normalized.lower().endswith(suffix.lower()) for suffix in wanted_suffixes):
                destination = tile_dir / Path(name).name
                destination.write_bytes(inner.read(name))
                extracted.append(destination.name)

        asc_path = tile_dir / f"{tile}.asc"
        if not asc_path.exists():
            raise RuntimeError(f"{tile}: missing ASCII elevation grid")

        validate_ascii_grid(asc_path)
        print(f"{tile}: {', '.join(sorted(extracted))}", file=sys.stderr)


def validate_ascii_grid(path: Path) -> None:
    header = {}
    with path.open("r", encoding="ascii") as input_file:
        for _ in range(6):
            parts = input_file.readline().split()
            if len(parts) >= 2:
                header[parts[0].lower()] = parts[1]

    expected = {"ncols": "200", "nrows": "200", "cellsize": "50"}
    for key, value in expected.items():
        if header.get(key) != value:
            raise RuntimeError(
                f"{path.name}: expected {key}={value}, got {header.get(key)!r}"
            )


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as input_file:
        while chunk := input_file.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def write_source_note(
    output_root: Path,
    source_url: str,
    archive_sha256: str,
) -> None:
    today = datetime.date.today()
    tiles = ", ".join(TILES)
    text = f"""# Pentland Hills terrain data

This directory contains the raw 50 m elevation grids needed for the first
Pentland Hills fly-through experiment.

Dataset: **OS Terrain 50**, ASCII grid, British National Grid (EPSG:27700).

Tiles: **{tiles}**.  Together they cover the central Pentland Hills around
Scald Law and Carnethy Hill, from 310–330 km east and 650–670 km north in the
British National Grid.

The files are deliberately kept as terrain data.  They contain no assumptions
about Euclidean, hyperbolic, Nil, Sol, or any other geometry.

## Provenance

Official product page:
https://www.ordnancesurvey.co.uk/products/os-terrain-50

Download used on {today.isoformat()}:
{source_url}

SHA-256 of the national archive downloaded before extracting the four tiles:

    {archive_sha256}

OS Terrain 50 is OS OpenData and is supplied under the Open Government Licence.
https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/

{ATTRIBUTION.format(year=today.year)}

## Reproduce

From any working directory:

    python3 tools/fetch_pentland_terrain.py

The program downloads the national OS Terrain 50 grid archive, extracts only
NT15, NT16, NT25, and NT26, and verifies that each ASCII grid is a 200 × 200
grid with 50 m cells.
"""
    (output_root / "SOURCE.md").write_text(text, encoding="utf-8")


def main() -> None:
    repository_root = Path(__file__).resolve().parents[1]
    output_root = repository_root / "data" / "pentland-hills" / "os-terrain-50"
    output_root.mkdir(parents=True, exist_ok=True)

    for tile in TILES:
        shutil.rmtree(output_root / tile, ignore_errors=True)

    with tempfile.TemporaryDirectory(prefix="pentland-terrain-") as temp_dir:
        archive_path = Path(temp_dir) / "terrain50.zip"
        source_url = download_archive(archive_path)
        archive_sha256 = sha256(archive_path)

        with zipfile.ZipFile(archive_path) as outer:
            for tile in TILES:
                copy_tile(outer, tile, output_root)

    write_source_note(output_root, source_url, archive_sha256)
    print(output_root)


if __name__ == "__main__":
    main()
