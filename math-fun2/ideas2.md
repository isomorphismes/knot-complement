# Ideas 2

## "Thurstonizing" as the design goal

Benson Farb's *On being Thurstonized* describes Thurston's way of trying to understand mathematical objects by mentally inhabiting them rather than relying only on symbols or static pictures. Farb's anecdote about Thurston seeing a negatively curved problem as a "froth of bubbles" is exactly the kind of intuition this project should try to make externally available.

The renderer should therefore be judged partly by a question like:

**Does moving around inside this thing make the mathematics easier to see?**

This is stronger than "does it make a pretty picture?"

## Geometry Center lineage

The half-remembered "geometry supercomputer place" was not Berkeley. It was the **Geometry Supercomputer Project**, begun in 1987, followed by the NSF-funded **Geometry Center at the University of Minnesota**, active from 1991 to 1998.

This is a direct intellectual ancestor of the project:

- *Not Knot* (1991): a guided trip from knots into hyperbolic knot-complement spaces.
- *The Shape of Space* (1995): fly-throughs of finite-but-unbounded spaces, based on Jeff Weeks's work.
- Geometry Center compilations include explicit "Flying in Hyperbolic Space" and "Exploring Hyperbolic Space Using Geomview" segments.
- Tamara Munzner has preserved and indexed much of the video archive.

This project can be thought of as: **take that tradition, make it interactive, make it portable, and let it run on a phone.**

## Eight Thurston geometries

Treat the eight geometries as eight worlds, not eight entries in a classification table.

Questions to preserve for each one:

- What does walking straight look like?
- What does turning around look like?
- What happens to parallel-looking objects?
- What does a regular room/grid/tree line look like?
- What does distant scenery do?
- What happens if the world is quotiented to a compact manifold/orbifold?
- Which visual landmarks help a human build intuition fastest?

The 2022 paper *Ray-marching Thurston geometries* is almost exactly the rendering problem: accurate real-time in-space views of all eight geometries, including quotient manifolds and orbifolds.

## Knot complements as worlds

For a knot `K`, use the complement `S^3 \ K` (or a computational model of it) as a world that can be entered.

Natural starting examples:

- figure-eight knot complement;
- Borromean-rings complement;
- other SnapPy census manifolds with useful triangulations.

The figure-eight knot complement is especially useful because it decomposes into two ideal hyperbolic tetrahedra and appears repeatedly in the visualization literature.

Possible interface:

- choose a knot/link;
- show the ordinary outside knot diagram;
- enter the complement;
- fly through the hyperbolic interior;
- optionally show the current path simultaneously in the outside diagram.

The SnapPy Views project explicitly proposed this inside/outside pairing.

## Cohomology fractals

David Bachman, Saul Schleimer, and Henry Segerman's cohomology-fractal work is a strong bridge between two ideas in this folder:

- fractal zooming;
- moving through hyperbolic 3-manifolds.

Their real-time viewer lets the user pan, rotate, and zoom deeply because the image is produced by ray-casting through an ideal triangulation. Their explanatory video explicitly describes the controls as flying around in the underlying space.

This suggests two modes rather than one:

1. **surface/image mode** — interact with the fractal as an image;
2. **inhabited-space mode** — expose the 3-manifold traversal that produces it.

## Fractal zooms as traversable worlds

The basic question is not only "can we zoom forever?" but:

**Can zooming be recast as motion through a space with a consistent local notion of position, direction, and neighborhood?**

Even when a particular fractal does not naturally provide a 3-dimensional manifold to inhabit, the user experience of continuous zooming is worth treating as a navigation primitive.

Relevant old Geometry Center material includes Mandelbrot zoom/crossing videos. Cohomology fractals provide a more literal 3-manifold realization.

## Familiar landscapes

Abstract walls and tilings are mathematically useful, but familiar scenery may make geometry easier to feel.

Experiments:

- a road with regularly spaced trees;
- a forest;
- mountain silhouettes at several distances;
- a grid of lampposts;
- a sparse town;
- stars or lights in quotient spaces;
- a rider or camera that simply keeps moving.

The geometry should control geodesics, visibility, repetition, apparent scale, and deformation. The trees are not the mathematics; they are measuring sticks for perception.

An **auto-walk** or **auto-ride** mode should be a first-class feature. No goals, score, combat, or puzzle are required.

## Video-game mechanics as mathematics

A later branch can ask whether some game mechanics should literally take place in a mathematical state/configuration space.

The current thought is deliberately loose:

- states connected by allowed operations;
- some operations invertible, some not;
- crossings and local moves;
- cancellation relations;
- spaces or graphs generated by operators;
- possible Jones/subfactor/knot-theoretic connections.

The remembered Zelda example and the user's older blog post should be located later before making this branch more specific. Do **not** treat the Jones/subfactor connection as established merely because it is suggestive.

## A useful comparison point: HyperRogue

HyperRogue matters because it demonstrates two distinct possibilities:

- geometry can change the *appearance* of a world;
- geometry can change the *gameplay itself*.

For this project, the first goal is even simpler than HyperRogue: let the user inhabit the space. But its work on all eight Thurston geometries is relevant both as implementation precedent and as evidence that the geometry can eventually drive mechanics.
