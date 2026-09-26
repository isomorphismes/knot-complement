# Pentland Hills terrain data

This directory contains the raw 50 m elevation grids needed for the first
Pentland Hills fly-through experiment.

Dataset: **OS Terrain 50**, ASCII grid, British National Grid (EPSG:27700).

Tiles: **NT15, NT16, NT25, NT26**.  Together they cover the central Pentland Hills around
Scald Law and Carnethy Hill, from 310–330 km east and 650–670 km north in the
British National Grid.

The files are deliberately kept as terrain data.  They contain no assumptions
about Euclidean, hyperbolic, Nil, Sol, or any other geometry.

## Provenance

Official product page:
https://www.ordnancesurvey.co.uk/products/os-terrain-50

Download used on 2026-09-26:
https://api.os.uk/downloads/v1/products/Terrain50/downloads?area=GB&format=ASCII%20Grid%20and%20GML%20%28Grid%29&redirect

SHA-256 of the national archive downloaded before extracting the four tiles:

    d03e91d3adcf5927b2f2e2ef0d7b6ccf18a2e63728d6ebef83c6c9aa2a3c64a7

OS Terrain 50 is OS OpenData and is supplied under the Open Government Licence.
https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/

Contains OS data © Crown copyright and database right 2026.

## Reproduce

From any working directory:

    python3 tools/fetch_pentland_terrain.py

The program downloads the national OS Terrain 50 grid archive, extracts only
NT15, NT16, NT25, and NT26, and verifies that each ASCII grid is a 200 × 200
grid with 50 m cells.
