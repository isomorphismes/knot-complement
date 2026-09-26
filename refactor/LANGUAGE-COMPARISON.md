# Recenter translation comparison

This is a first reading, not a language ranking.

All versions implement the same quotient-space idea extracted from the Geometry Center code:

1. locate the camera in model coordinates;
2. find the neighboring fundamental-domain copy closest to it;
3. accumulate group transforms until the point is back in the base copy;
4. conjugate that group transform into world coordinates;
5. recenter the camera;
6. preserve the hyperbolic-isometry cleanup step.

The renderer and controls are deliberately absent.

## Close C reference

The C reference is closest to the historical implementation and remains the executable oracle.

It also shows why the old routine is hard to see at a glance: generic 4x4 inversion, row-vector conventions, mutation, status propagation, hyperbolic normalization, and quotient navigation all occupy the same implementation language.

The refactor already improves this by naming the quotient operations separately.

## Functorial ICKY C

The Functorial ICKY C version keeps C's data representation but makes the computation read as named transformations:

- `neighbor_center`;
- `distance_to_neighbor`;
- `nearest_neighbor_index`;
- `move_point_into_accumulated_copy`;
- `camera_position_in_model`;
- `find_nearest_copy`;
- `recenter_camera`.

The ICKY mathematical surface lets multiplication, subtraction, square root, and equality-question notation remain visibly mathematical without spending `*` on multiplication when `*` also means pointer syntax.

This is intentionally not ordinary-GCC source.

## D

D stays close to the concrete numerical implementation while removing some C bookkeeping.

Fixed-size value arrays make `Point4` and `Transform` direct values. Slices make the neighbor iteration less mechanical. The Gaussian inversion and hyperbolic Gram--Schmidt remain explicit, so D is a useful comparison against the C reference rather than an abstract rewrite.

## Idriç / Edriç-facing source

The Idriç version treats the linear-algebra operations as a named semantic boundary.

The quotient algorithm speaks in terms of:

- `Space`;
- `NearestCopy`;
- `RecenteredCamera`;
- `RecenterError`;
- `GeometryOperations`.

It uses `Number`, `Float32`, Unicode arrows, and ordinary domain names rather than importing the old Geomview object vocabulary.

The immediate design question for later slices is whether more invariants belong in the types -- for example, distinguishing an arbitrary transform from a hyperbolic isometry -- or whether that would obscure the program.

## Haskell

Haskell makes the dependency injection compact: a `Geometry` record supplies the transform and metric operations, while `Either` and `Maybe` carry failure.

The quotient recursion itself becomes short. Some meaning moves into inferred types and typeclass constraints, which is exactly one of the things this comparison is meant to make visible.

## Idris

The Idris version is close enough to Haskell to make the extra type-system structure visible without changing the algorithm.

The recursive search is explicitly fuel-bounded. The next slices can test whether indexing transforms, spaces, or group elements buys enough clarity to justify the additional type structure.

This is deliberately separate from Idriç: inherited Idris vocabulary and style are not being treated as the Idriç design.

## Agda

Agda makes the algorithm's assumptions most explicit at the module boundary:

- point type;
- transform type;
- scalar type;
- transform operations;
- metric comparison;
- failure cases;
- finite search fuel.

The cost is more structural ceremony even before proving anything.

That makes Agda useful here even if it never becomes the runtime implementation: it exposes assumptions that another version may have hidden.

## What this slice does not decide

Do not choose the implementation language from camera recentering alone.

The more informative comparisons are likely to be:

1. `dgenum.c` -- recursive group-word generation, duplicate suppression, constraints, optional word-acceptor automaton;
2. `weeks_dirdom.c` -- mathematical geometry with a substantial data structure;
3. `.dgp` parsing -- boundary between mathematical input and application configuration;
4. visible-tile production -- pure geometry/policy versus renderer state.

Those will put materially different pressure on C-family composition, algebraic datatypes, dependent types, and proof-oriented structure.
