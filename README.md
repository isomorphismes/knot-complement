# knot-complement

A notebook and experimental codebase for making mathematical spaces into places you can move through.

The guiding idea is not to paste mathematics onto a conventional game. The mathematical space itself is the world. The basic interaction can be as simple as walking, flying, or auto-walking and looking around.

## Main directions

### 1. Walk inside knot complements and hyperbolic 3-manifolds

The central target is an actual inside view of a knot complement: start with the figure-eight knot complement, then other cusped hyperbolic 3-manifolds. The player should move through the quotient geometry rather than merely look at a knot embedded in ordinary Euclidean space.

Useful existing models include:

- SnapPy `inside_view()`
- *Not Knot* / Maniview
- Jeff Weeks's *Curved Spaces*
- Henry Segerman and collaborators' real-time ray-casting/ray-marching work

### 2. Walk through the eight Thurston geometries

Build a common movement/rendering experiment for

- Euclidean 3-space
- spherical 3-space
- hyperbolic 3-space
- \(S^2 \times R\)
- \(H^2 \times R\)
- \(\widetilde{SL_2(R)}\)
- Nil
- Sol

The interesting part is perceptual: what does ordinary locomotion, distance, parallelism, horizon structure, and familiar scenery feel like when the geometry changes?

### 3. Fractals as traversable spaces

Do not stop at precomputed zoom videos. Treat a fractal as somewhere to move.

Starting references include cohomology fractals, Cannon--Thurston maps, classical Mandelbrot zooms, and the old Geometry Center visualization work.

### 4. Familiar landscapes inside unfamiliar geometry

Put recognizable things -- mountains, trees, paths, rooms, horizons -- into non-Euclidean geometry. The same scene should become a visual measuring instrument for the geometry.

An auto-walk/ride mode matters here: the user should be able to watch the geometry reveal itself without needing a complicated game mechanic.

### 5. Later: spaces built from mathematical operations

Possible later experiments include worlds organized around crossings, cancellations, transformations, operator-algebra-like composition, and knot-theoretic moves. These are intentionally less specified than the geometric fly-through work.

## First playable experiment

Before the quotient-space walker, make the ordinary geometry loop work on the
smallest visually interesting world:

> **Walk around a tiny lunar planet.**

The `little-prince/` prototype is an ordinary 2-sphere embedded in Euclidean
3-space, using real lunar relief rescaled onto a toy-sized planet. It provides a
baseline for walking, local up/down, camera behavior, horizon, touch controls,
terrain, Android rendering, and auto-walk without any quotient geometry.

After that baseline works on the phone, return to:

> **Walk inside the figure-eight knot complement (`m004`).**

See [little-prince/README.md](little-prince/README.md) for the tiny-planet scope
and [FIRST_BUILD.md](FIRST_BUILD.md) for the `m004` scope.

## Notes

The reading/viewing list belongs in [notes/references.md](notes/references.md). It includes the papers, books, historical Geometry Center material, videos, and existing software that motivated the project.
