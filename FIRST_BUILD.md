# First build: walk inside `m004`

## Why this one

The first implementation will be the figure-eight knot complement, SnapPy census name `m004`.

It is the right first target because:

- it is an actual knot complement, so the project starts with its central subject;
- its standard ideal triangulation has only two ideal tetrahedra;
- there are strong external references for checking the geometry;
- it is complicated enough to produce genuinely non-Euclidean motion without requiring a general 3-manifold engine first.

## First visible result

A person can open the program on a phone and:

1. appear inside `m004`;
2. look around;
3. move forward/backward and turn;
4. cross ideal-tetrahedron faces continuously through the correct face identifications;
5. switch on auto-walk;
6. see enough scaffolding to understand where the triangulation/cusp structure is.

This is an inside view, not a picture of the knot in Euclidean 3-space.

## Geometry representation

Start from the canonical two-ideal-tetrahedra description.

Keep the initial state explicit and inspectable:

- current tetrahedron: 0 or 1
- camera position in a chosen model of hyperbolic 3-space
- camera orientation
- the four face-pairing maps for each tetrahedron
- cusp / ideal-vertex information
- optional accumulated path

Movement and rendering should be written in terms of named geometric operations rather than one large shader or one large coordinate formula.

## Minimal renderer

The first renderer does not need scenery.

Render:

- tetrahedron faces or a controllable translucent/debug version of them;
- edges;
- a cusp cross-section or other stable landmark;
- a few repeated markers whose copies make quotient identifications perceptible.

A later pass can remove the scaffolding once the space itself reads clearly.

## Core operation

For both the camera and each viewing ray:

1. advance along the hyperbolic geodesic;
2. find the next tetrahedron face crossed;
3. apply that face-pairing isometry;
4. continue in the neighboring tetrahedron;
5. stop only at the visual-distance / step bound.

This is the first function chain that should become clean and readable.

## Correctness oracles

Use existing programs as references, not runtime dependencies:

- SnapPy `Manifold("m004").inside_view()`
- *Not Knot* / Maniview
- cohomology-fractal implementations for ideal-triangulation ray traversal
- the general ray-marching Thurston-geometries work for rendering patterns

Checks should include:

- face pairings return to the expected tetrahedron;
- closed combinatorial loops compose to the expected deck transformation;
- cusp behavior agrees with the known `m004` cusp;
- camera motion remains continuous across face crossings.

## Phone constraint

The eventual normal target is a low-end phone, not a workstation.

For the first experiment:

- favor a small fixed geometric state;
- bound ray steps;
- expose frame time and step counts;
- keep an auto-walk path so performance can be compared reproducibly;
- avoid adding a large game engine before the geometry works.

## Done for version 0

Version 0 is done when a phone build can continuously auto-walk through `m004` for several minutes without losing the manifold state, while a debug overlay can show which tetrahedron the camera occupies and which face crossings occur.

After that, the next decision is whether to:

- make `m004` visually richer with familiar landmarks / terrain, or
- generalize the same renderer to another Thurston geometry / another census manifold.
