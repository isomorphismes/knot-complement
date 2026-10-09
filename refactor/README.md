# First refactor: quotient-space camera recentering

This directory extracts one small but central piece of the Geometry Center code before any new renderer or phone controls are added.

The historical source remains unchanged under `upstream/`.

## What the old code is actually doing

The old `flythrough/main.c` is mostly a demo player. It chooses precomputed camera paths and tessellation files and streams commands to Geomview. Interactive flight itself is delegated to Geomview.

Maniview is an interactive wrapper around the discrete-group object. It mixes file loading, UI state, rendering flags, and calls into the mathematical code.

The reusable geometry machinery is under:

`upstream/geometry-center/geomview/src/lib/gprim/discgrp/`

The useful reading order for this slice is:

1. `dgstream.c` — group data;
2. `dgdirdom.c` — Dirichlet domain, neighboring copies, `DiscGrpClosestGroupEl`;
3. `dgenum.c` — group-element enumeration;
4. `dgdraw.c` — camera recentering, visibility policy, and rendering mixed together;
5. `weeks_dirdom.c` — deeper Dirichlet-domain construction.

This first refactor extracts `DiscGrpClosestGroupEl` plus the camera-recentering part of `DiscGrpDraw`.

## Boundary discovered

The quotient-navigation core needs:

- a distinguished point in the fundamental domain;
- neighboring group transforms, with the identity first;
- transform application/composition/inversion;
- the metric distance;
- a camera-to-world transform;
- a model-to-world transform.

Its semantic operations are:

    find_nearest_copy(space, point)
        -> group transform + crossing count

    recenter_camera(space, camera_to_world, model_to_world)
        -> recentered camera + crossed group transform

That leaves the eventual phone controls outside the manifold code:

    moved_camera =
        apply_controls(previous_camera, controls, elapsed_time)

    camera_in_base_copy =
        recenter_camera(space, moved_camera, model_to_world)

The controls do not need to know about group words, tessellation, Geomview, or rendering.

## Comparison languages

The ordinary C extraction is the close reference refactor.

The intended language-design comparison is now:

- `c/` — close C reference extraction;
- `functorial-icky-c/` — Functorial ICKY C: named data transformations and the ICKY mathematical surface;
- `d/` — D;
- `idric/` — current Idriç/Edriç-facing design;
- `haskell/` — Haskell;
- `idris/` — Idris;
- `agda/` — Agda.

Python and Go were deliberately removed; they were not the comparison set for this language-design experiment.

The Haskell, Idris, Agda, and Idriç versions make the lower linear-algebra operations an explicit record/interface boundary. That is intentional: the quotient-space algorithm is the code under comparison here. The close C reference still contains the low-level matrix implementation so the extracted behavior remains executable.

## Numerical correction found while refactoring

Geomview's hyperbolic distance computes `acosh(ratio)`, where mathematically `ratio >= 1`. Floating-point roundoff can make an identity-distance calculation microscopically smaller than one, producing NaN.

The C reference clamps the argument to at least one. The two-crossing test exposed this; it is not a renderer change.

## Acceptance

`run-tests.sh` always compiles and runs the close C reference.

It also performs syntax/type checks for translated versions when the corresponding compiler is installed. Missing compilers are reported as `SKIP`, not `PASS`.

The Functorial ICKY C source intentionally uses ICKY operators such as `×`, `÷`, `−`, `√`, and `≟`; ordinary GCC is therefore not its acceptance compiler. Its quotient uses the account's division glyph. The qualified ICK revision `c61e448251744a2f40ad743ebef1a027bdcd2f9d` accepts `÷`, but does not yet accept this comparison's existing `−`, `√`, and `≟` surface. This remains a language-design comparison with the existing explicit `SKIP` in `run-tests.sh`; the executable close C reference and its tests remain the behavioral oracle.

The current tests/fixtures cover:

- known hyperbolic boost distance;
- one fundamental-domain crossing;
- two consecutive crossings;
- camera recentering to the base copy;
- the first generator matrix from historical `fig8.dgp`.

## Next refactor slices

Do not attach phone controls yet.

Next compare:

1. `.dgp` group data versus parser/application state;
2. `dgenum.c` as a producer of group transforms, removing its global enumeration state;
3. the Weeks Dirichlet-domain calculation as mathematics returning faces and neighboring transforms;
4. visible-tile selection as policy returning transforms;
5. renderer adapter;
6. existing phone controls attached only after those interfaces have settled.
