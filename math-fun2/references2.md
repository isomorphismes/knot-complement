# References 2

These are starting references for the ideas in this thread. They are notes, not a claim that every source must be implemented.

## Thurston geometries and 3-manifolds

### Peter Scott — *The Geometries of 3-Manifolds* (1983)

Classic survey containing the eight 3-dimensional geometries.

- Bibliographic page: https://deepblue.lib.umich.edu/handle/2027.42/135276
- PDF mirror: https://sschleimer.warwick.ac.uk/Teach/2021_3MFDS/References/1983the_geometries_of_three-manifolds.pdf
- Bulletin of the London Mathematical Society 15(5), 401–487.

### Rémi Coulon, Elisabetta A. Matsumoto, Henry Segerman, Steve J. Trettel — *Ray-marching Thurston geometries*

This is one of the most directly relevant technical references: accurate real-time interactive in-space views of **all eight** Thurston geometries, including quotient manifolds and orbifolds.

- arXiv: https://arxiv.org/abs/2010.15801
- Published in *Experimental Mathematics* 31(4), 2022, 1197–1277.
- Code: https://github.com/henryseg/non-euclidean_VR
- Project page: http://www.segerman.org/XR.html

### Coulon, Matsumoto, Segerman, Trettel — *Non-Euclidean Virtual Reality III: Nil*

- arXiv: https://arxiv.org/abs/2002.00513
- Interactive simulation noted by the paper: https://www.3-dimensional.space/nil.html

### Coulon, Matsumoto, Segerman, Trettel — *Non-Euclidean Virtual Reality IV: Sol*

- arXiv/html: https://ar5iv.labs.arxiv.org/html/2002.00369
- Bridges PDF: https://archive.bridgesmathart.org/2020/bridges2020-161.pdf
- Interactive simulation noted by the paper: https://www.3-dimensional.space/sol.html

### Vi Hart, Andrea Hawksley, Elisabetta A. Matsumoto, Henry Segerman — *Non-Euclidean Virtual Reality I/II*

Earlier interactive work on `H^3` and `H^2 x E`, feeding directly into the later eight-geometry renderer.

- Part I / H3: https://arxiv.org/abs/1702.04004
- Part II / H2 x E: https://arxiv.org/abs/1702.04862

## Knot complements and fractals

### David Bachman, Saul Schleimer, Henry Segerman — *Cohomology fractals*

Introduces real-time ray-cast fractals associated to cohomology classes on hyperbolic 3-manifolds. The figure-eight knot complement is a central example.

- arXiv: https://arxiv.org/abs/2002.00239
- HTML: https://ar5iv.labs.arxiv.org/html/2002.00239
- Interactive viewer: https://henryseg.github.io/cohomology_fractals/
- Code: https://github.com/henryseg/cohomology_fractals

### SnapPy Views — Matthias Goerner, Saul Schleimer, Henry Segerman

Project to show what a hyperbolic 3-manifold looks like from the inside and to connect the inside fly-through to the outside link diagram.

- https://im.icerm.brown.edu/portfolio/snappy-views/

### SnapPy

Computational system for hyperbolic 3-manifolds, descended from Jeff Weeks's work and built around the same ideal-triangulation world needed for knot-complement exploration.

- https://snappy.math.uic.edu/

## Geometry Center

### Geometry Center videos and supplements

Tamara Munzner's archive page is the best index found so far. It also corrects the location/history: the Geometry Center was at the University of Minnesota (1991–1998); its predecessor, the Geometry Supercomputer Project, began in 1987.

- https://www.cs.ubc.ca/~tmm/gc/

### David Epstein and Charlie Gunn — *Supplement to Not Knot*

Companion material for the 1991 Geometry Center film.

- Indexed/downloadable from: https://www.cs.ubc.ca/~tmm/gc/

### Jeffrey R. Weeks — *Exploring The Shape of Space*

Companion material to the Geometry Center film.

- Indexed/downloadable from: https://www.cs.ubc.ca/~tmm/gc/

### Jeffrey R. Weeks — *The Shape of Space*

Book-length background on finite/unbounded spaces and 3-manifold visualization.

### William P. Thurston and Silvio Levy — *Three-Dimensional Geometry and Topology, Vol. 1*

General background for the geometry/topology being rendered.

## Thurston's way of seeing

### Benson Farb — *On being Thurstonized*

This is the short note remembered in the conversation. It explicitly discusses Thurston's insistence on mentally living inside mathematical objects and contains the "froth of bubbles" anecdote.

- PDF: https://www.math.uchicago.edu/~farb/papers/thurston.pdf
- Appeared in *Notices of the AMS*, January 2016.

## Games / interactive geometry

### Eryk Kopczyński, Dorota Celińska, Marek Čtrnáct — *HyperRogue: Playing with Hyperbolic Geometry*

Useful because the geometry affects both perception and actual game mechanics.

- Paper: https://roguetemple.com/z/hyper/papers/hyperrogue.pdf
- Bridges page: https://archive.bridgesmathart.org/2017/bridges2017-9.html
- Source: https://github.com/zenorogue/hyperrogue
- Geometry experiments: https://roguetemple.com/z/hyper/geoms.php
- Thurston-geometries update: https://zenorogue.itch.io/hyperrogue/devlog/99827/hyperrogue-112-thurston-geometries-free-update

## Older rendering lineage worth following

The ray-marching paper explicitly places itself in a chain running through Jeff Weeks's *Curved Spaces* and Geometry Center work.

- Jeff Weeks, Curved Spaces: https://www.geometrygames.org/CurvedSpaces/
- Henry Segerman VR/real-time graphics index: http://www.segerman.org/XR.html

The Geometry Center archive should also be mined for Geomview, hyperbolic-space, low-volume-manifold, Mandelbrot, and knot/link material before deciding what to reproduce.
