# Little Prince / tiny-planet prototype

This is the first playable geometry experiment before `m004`.

The world is an ordinary 2-sphere embedded in Euclidean 3-space. That is
deliberately simpler than spherical 3-space or a quotient manifold: it gives us
a place to settle walking, camera motion, terrain, horizon behavior, touch
controls, and the Android renderer before changing the ambient geometry.

## First picture

A small prince-shaped placeholder stands on a tiny lunar planet.

The player can:

- walk forward and backward around the whole planet;
- turn without hitting a longitude seam or a pole singularity;
- look around while "down" always points toward the planet center;
- walk over real lunar relief rescaled onto the toy planet;
- keep walking until the starting point comes back over the horizon.

No missions, combat, inventory, or conventional game machinery are needed.
The point is to make the geometry itself immediately perceptible.

Do not copy book illustrations or prose into the prototype. The first avatar can
be a simple geometric child-sized figure; the visual reference is only the
small-person-on-small-planet idea.

## Geometry

Use a game-space base radius of about 20 m.

Walker state is:

- `up`: unit vector from planet center to the walker's feet;
- `forward`: unit tangent vector;
- `radius`: base planet radius.

Walking a distance `s` is a Euclidean 3-D rotation through angle `s / radius`
about the tangent axis `up × forward`. Turning rotates `forward` about
`up`.

That representation has no special north pole and no longitude seam. Latitude
and longitude exist only for sampling the lunar maps.

The initial implementation is in `core/tiny_planet.c` and has a small
executable test.

## Terrain

Start with NASA's CGI Moon Kit / LOLA data. For the first phone build, use the
global 4-pixels-per-degree elevation map and the 2K color map. Keep the source
files out of git and fetch them reproducibly.

The Moon's real relief is tiny compared with its radius, so a physically scaled
20 m Moon would look almost smooth. Apply a tunable vertical exaggeration
(default about 20x) after converting the LOLA heights into game-space units.

See `data/SOURCES.md` and `data/fetch-data.sh`.

## Rendering target

First renderer:

1. build a UV sphere with enough subdivisions to show the 4-ppd terrain;
2. displace vertices with the lunar height field;
3. texture it with the LROC color map;
4. place a simple prince placeholder on the terrain;
5. use a chase camera whose local up vector is the walker's `up`;
6. use a single distant light so crater relief reads clearly.

The first Android path should be NativeActivity + Android NDK + OpenGL ES.
No Java game engine is required.

The ICK path remains desirable, but this prototype should use the NDK until the
ICK Android graphics/runtime path can build the same executable cleanly. That
gap should stay explicit rather than blocking the geometry experiment.

## Controls for version 0

- left half drag / virtual stick: walk and turn;
- right half drag: camera look;
- two-finger tap: reset camera behind the walker;
- optional auto-walk toggle for repeatable performance testing.

## Acceptance for version 0

On the MIRO A1:

- launch directly into the tiny planet;
- hold forward and circumnavigate the sphere continuously;
- cross the texture seam and both polar regions without a camera flip;
- remain attached to the local surface while terrain changes;
- no visible discontinuity in walking direction;
- expose frame time and triangle count;
- auto-walk for five minutes without losing the local frame.

Once that works, the same input/camera/render loop becomes the baseline against
which the `m004` quotient-space walker is compared.
