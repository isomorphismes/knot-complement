# Prototype 2

This is a conservative executable target extracted from the discussion. It is not a final architecture.

## What counts as success

A phone build where the user can:

- enter one mathematically defined 3-space;
- look around;
- move forward/backward and turn;
- enable auto-walk;
- see enough repeated/familiar objects to notice what the geometry is doing;
- run interactively rather than watching a pre-rendered movie.

No combat, score, quest, or puzzle is required.

## First comparison scene

Use the same sparse scene in every geometry:

- floor/reference surface when meaningful;
- regularly spaced posts or trees;
- a few glowing spheres/lights;
- a distant mountain-like silhouette or large landmark;
- optional grid;
- distance markers that can be turned on/off.

This makes the *geometry* the independent variable.

## Geometry sequence

The ultimate set is all eight Thurston geometries:

1. `E^3` — control case.
2. `H^3`.
3. `S^3`.
4. `H^2 x R`.
5. `S^2 x R`.
6. Nil.
7. Sol.
8. universal cover of `SL(2,R)`.

The order above is not a commitment about implementation difficulty. The existing ray-marching literature/code should be inspected before choosing an implementation order.

## Knot-complement prototype

After a general hyperbolic-space viewer works:

1. load the figure-eight knot complement;
2. use its standard ideal-tetrahedron decomposition;
3. place the camera inside;
4. render a stable first-person view;
5. allow continuous motion across tetrahedron faces;
6. optionally show which tetrahedron/copy the camera occupies;
7. later add a synchronized outside knot diagram.

Then repeat with the Borromean-rings complement.

## Fractal prototype

Two related targets:

1. run or reproduce the cohomology-fractal viewer for one small census manifold;
2. expose the relation between screen-space zoom/pan and movement through the manifold.

A more speculative later target is a navigable rendering inspired by ordinary Mandelbrot zoom videos even where there is no literal underlying 3-manifold.

## Performance principle

The first phone version should prefer mathematical legibility and stable interaction over photorealism.

Useful constraints:

- few object types;
- simple materials;
- no need for high-poly terrain;
- strong visual landmarks;
- deterministic camera motion;
- an auto-walk mode that can run indefinitely;
- save enough state that a user can return to a location/view.

The 2022 *Ray-marching Thurston geometries* implementation and HyperRogue should be treated as executable prior art before inventing a new renderer.
