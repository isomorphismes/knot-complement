# Math fun: inhabitable mathematical spaces

This folder records the second chat thread's ideas so it can coexist with parallel notes. The organizing idea is simple:

> The mathematical space itself should be the world you move through.

The goal is not primarily to make a conventional game with mathematics added as decoration. A successful first version can simply let a person walk, fly, or auto-walk through a mathematically meaningful space and look around.

The intended target includes a phone renderer. A headset may be useful later, but it is not required for the basic idea.

## Main strands

1. **The eight Thurston geometries**
   - Euclidean 3-space: `E^3`
   - spherical 3-space: `S^3`
   - hyperbolic 3-space: `H^3`
   - `S^2 x R`
   - `H^2 x R`
   - Nil
   - Sol
   - the universal cover of `SL(2,R)`

   Make each one directly inhabitable: move through it, turn around, watch geodesics/perspective behave correctly, and compare the experience between geometries.

2. **Knot and link complements**
   - A knot complement is already a natural "place to go inside".
   - The Geometry Center film *Not Knot* is an especially direct ancestor of this project.
   - Start with well-understood examples such as the figure-eight knot complement and Borromean-rings complement.
   - Longer-term: choose a knot/link and enter the complement as a navigable world.

3. **Fractal traversal**
   - Take the visual experience of a fractal zoom and turn it into an explorable space rather than a precomputed movie.
   - Cohomology fractals are unusually relevant because their implementation already treats the controls as flying through hyperbolic 3-manifolds.

4. **Landscapes in unusual geometry**
   - Put familiar visual anchors into the space: terrain, mountains, trees, roads, markers, buildings, etc.
   - Let the geometry deform the apparent world rather than making the scene abstract by default.
   - An auto-walk / auto-ride mode matters. The motivating experience is the pleasure of simply roaming and looking at scenery, as in wandering through *World of Warcraft*.

5. **Other mathematical game spaces**
   - Keep open a lower-priority branch where the "world" is a state/configuration/transformation space rather than ordinary geometric space.
   - Possible inspiration includes knot-crossing moves, cancellations, operator-algebra or subfactor/Jones-type structures, and puzzle mechanics with reversible or irreversible transformations.
   - This connection is exploratory, not yet a mathematical claim.

## Files

- [ideas2.md](ideas2.md): detailed concept notes.
- [references2.md](references2.md): papers, books, software, and primary sources.
- [videos2.md](videos2.md): films, demos, and fly-throughs.
- [prototype2.md](prototype2.md): a conservative first executable target.
