# References and existing work

This is a working reading/viewing list, not a bibliography polished for publication. Items are grouped by why they matter to the project.

## Foundations explicitly motivating this project

### William P. Thurston — *The Geometry and Topology of Three-Manifolds*

Electronic edition of the Princeton notes:

- https://library.slmath.org/nonmsri/gt3m/

The central source for the geometric viewpoint on 3-manifolds.

### Peter Scott — "The Geometries of 3-Manifolds"

*Bulletin of the London Mathematical Society* 15 (1983), 401–487.

- DOI: https://doi.org/10.1112/blms/15.5.401
- PDF mirror: https://www.maths.gla.ac.uk/~mpowell/Scott%20-%20Geometries_of_three-manifolds.pdf

Especially useful as a systematic account of the eight 3-dimensional geometries.

**Unbuilt features tracked:** [all eight geometries #13](https://github.com/isomorphismes/knot-complement/issues/13) and [navigable hyperbolic honeycombs #14](https://github.com/isomorphismes/knot-complement/issues/14). These issues link the companion projects.

#### Reading Scott by project question

- **§§1–2:** surface geometries and orbifolds, for the 2-dimensional intuition behind geometric pieces.
- **§3:** Seifert fiber spaces, for examples that are not generic hyperbolic quotients.
- **§4 (pp. 441–473):** the eight model geometries: `S^3`, `E^3`, `H^3`, `S^2 × R`, `H^2 × R`, `~SL_2(R)`, Nil and Sol.
- **§5:** what is meant by classifying 3-dimensional geometries.
- **§6:** geometrization, distinguishing a geometric piece from a general 3-manifold.

**Rendering distinction:** a model geometry `X` is not automatically a particular quotient `X/Γ`. Model-space geodesics, quotient identifications, and the observer's frame are separate parts of a correct fly-through. Do not use Euclidean straight-line camera motion as a substitute for geodesics in Nil or Sol merely because a shader looks non-Euclidean. Scott is the mathematical classification reference; [Coulon–Matsumoto–Segerman–Trettel](https://arxiv.org/abs/2010.15801) is the computational rendering reference.

### Benson Farb — "On being Thurstonized"

- https://math.uchicago.edu/~farb/papers/thurston.pdf

Keep this here for the intellectual goal of the project: geometric intuition can be acquired by learning to think and move inside the right pictures, not only by reading finished formal statements.

### Jeff Weeks — *The Shape of Space*

Background for thinking of topology and geometry as something an observer can inhabit.

## Geometry Center / Geometry Supercomputer Project

Tamara Munzner has collected the old Geometry Center video archive and supplements here:

- **Geometry Center Videos, Revisited** — https://www.cs.ubc.ca/~tmm/gc/

The Geometry Center was the NSF Center for the Computation and Visualization of Geometric Structures (1991–1998); its predecessor was the Geometry Supercomputer Project.

Items from that collection to keep close to this project:

- **Not Knot** — hyperbolic knot complements
- **Dirichlet Domains for Low Volume Hyperbolic Manifolds** — Charlie Gunn
- **Hyperbolic Dodecahedral Tilings** — Charlie Gunn and Tamara Munzner
- **Pleated Surfaces, Conformal & Projective Models of Hyperbolic Space**
- **Good Fibrations: Visualizing the Hopf Fibration** — Mark Goldman and Mark Phillips
- **The Cubic Connectedness Locus** — Charlie Gunn
- **Crossing External Rays of the Mandelbrot Set** — Adrien Douady, Rene Adad, Charlie Gunn
- **A Zoom into the Mandelbrot Set** — Charlie Gunn and Matt Grayson

A convenient current page for *Not Knot*:

- https://amathr.org/videos/

Historical navigation software:

- **Maniview** — https://github.com/geomview/maniview
- UBC Geometry Center self-study/report material — https://www.cs.ubc.ca/~tmm/gc/gc-selfstudy-1994.pdf

## Hyperbolic 3-manifolds and cohomology fractals

### David Bachman, Saul Schleimer, Henry Segerman — "Cohomology fractals"

- arXiv: https://arxiv.org/abs/2002.00239
- explorer: https://henryseg.github.io/cohomology_fractals/
- source: https://github.com/henryseg/cohomology_fractals
- video: https://www.youtube.com/watch?v=fhBPhie1Tm0

This is directly relevant to the "fractal as somewhere to explore" branch.

### David Bachman, Matthias Goerner, Saul Schleimer, Henry Segerman — "Cohomology fractals, Cannon–Thurston maps, and the geodesic flow"

- arXiv: https://arxiv.org/abs/2010.05840
- published article: https://doi.org/10.1080/10586458.2021.1994059

### Henry Segerman / Saul Schleimer — Cannon--Thurston maps video

- **Cannon-Thurston maps: naturally occurring space-filling curves**
- https://www.youtube.com/watch?v=FpeeFcK3lTk

### Henry Segerman — hyperbolic-geometry video

- **Illuminating hyperbolic geometry**
- https://www.youtube.com/watch?v=eGEQ_UuQtYs

## Real-time rendering of non-Euclidean geometry

### Rémi Coulon, Elisabetta A. Matsumoto, Henry Segerman, Steve J. Trettel — "Ray-marching Thurston geometries"

- https://arxiv.org/abs/2010.15801

This is the obvious technical reference for a common real-time renderer spanning all eight Thurston geometries.

### Henry Segerman — "Raytracing and raymarching simulations of non-euclidean geometries"

IAS talk, 4 December 2020:

- https://www.ias.edu/video/raytracing-and-raymarching-simulations-non-euclidean-geometries

The talk connects the eight-geometry ray-marching work to the cohomology-fractal / hyperbolic-3-manifold work.

### 3-Dimensional Space / non-euclidean_VR

- interactive site: https://3-dimensional.space/
- source: https://github.com/henryseg/non-euclidean_VR

Related papers in the series include the Nil and Sol implementations; keep them as implementation references when those geometries become active targets.

## Existing software to inspect rather than reinvent blindly

### SnapPy

- https://snappy.computop.org/
- source: https://github.com/3-manifolds/SnapPy

Important reference behavior:

```python
Manifold("m004").inside_view()
```

Also inspect the Borromean-rings complement (`L6a4`).

### Jeff Weeks — Curved Spaces

- https://www.geometrygames.org/CurvedSpaces/index.html.en

A flight simulator through multiply connected 3-manifolds.

### Jeff Weeks — 4D Maze

- https://www.geometrygames.org/Maze4D/index.html.en

### Jeff Weeks — 4D Draw

- https://www.geometrygames.org/Draw4D/

### Jelle Vermandere — 4D Explorer

- https://jellever.itch.io/4dexplorer

Not part of the 3-manifold implementation, but relevant to interaction design for spaces whose geometry is initially unintuitive.

## Specific implementation questions to answer from these sources

- How should a camera state be represented so motion remains geometrically correct?
- How are rays or geodesics continued across quotient-domain boundaries?
- Which visual landmarks teach the geometry rather than merely decorate it?
- What is the smallest representation of `m004` that still supports a convincing inside view?
- Which parts of SnapPy / Maniview / Curved Spaces are useful as correctness oracles?
- Which algorithms are realistic on a low-end phone?
