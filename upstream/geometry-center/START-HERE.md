# Start reading here

The historical source is much easier to understand if read in this order.

1. **`geomview/src/bin/flythrough/flyhelp`**  
   Read this first. It says what the program does in ordinary language: the four flight paths, the dodecahedral tiling, interactive camera motion, and the Geometry Center authorship.

2. **`geomview/src/bin/flythrough/main.c`**  
   This is the small controller for the actual *Not Knot* fly-through. The important separation is already visible:
   - choose/load a tessellation;
   - choose/load a camera path;
   - set speed/step count;
   - emit commands to Geomview.

3. **`geomview/src/bin/flythrough/data/`**  
   This is the content rather than the controller:
   - `dodec.vect`: the decorated dodecahedron;
   - `br4.*.tlist`: increasing tessellation depths;
   - `dir.*.gv`: direct path;
   - `quart.*.gv`: quarter-turn path;
   - `loop.*.gv`: full-loop path;
   - `equi.*.gv`: equidistant path;
   - `flythrough_diagram.gv`: explanatory diagram.

4. **`geomview/src/lib/gprim/discgrp/`**  
   This is the deeper reusable machinery: discrete groups, enumeration, Dirichlet domains, hyperbolic distance/model handling, and drawing quotient-space geometry. This is the main candidate for separating "mathematics of the space" from the old Geomview application.

5. **`geomview/data/groups/notknot.dgp`**, **`fig8.dgp`**, and **`borrom*.dgp`**  
   Concrete manifold/group descriptions. These are useful for asking what should become data in a new renderer rather than hard-coded program logic.

6. **`maniview/README`**, then **`maniview/maniview.c`**  
   A second Geometry Center view of the same problem: an interactive 3-manifold/orbifold viewer. Compare its responsibilities with Flythrough before designing the replacement API.

## First refactoring question

Before translating anything, identify the boundary between:

- **space/manifold data**
- **geometry operations**
- **camera path / motion**
- **scene decoration**
- **rendering**
- **1990s UI / process plumbing**

The old code already separates several of these. The first new implementation should preserve the useful separation rather than mechanically translating the program file-for-file.
