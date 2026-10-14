# A checked two-cell atlas for the figure-eight complement

This slice follows a ray through the complete regular ideal triangulation of
`m004`. Its origin is Flexible Pipes issue 133:
https://github.com/isomorphisms/flexible-pipes/issues/133 .
It builds on the checked H³ kernel at
`ed2938fab243741a0380d920289cd7377eb2106b`. Historical `upstream/` files remain
unchanged. This is the repository's close C reference, compiled through ICK;
it does not claim an Idriç implementation or a general manifold engine.

## Authoritative input

The labelled topology comes from SnapPy's preserved triangulation:
https://github.com/3-manifolds/SnapPy/blob/c3da53c2b3105489b4d71531c4f781c92b237753/src/snappy/tests/files/example_m004.tri

`m004-source.tri` retains that source verbatim, including cusp peripheral
curves and the printed shape approximations. The implementation uses the
exact complete regular shape `(1 + i√3)/2`, not rounded decimal shape data.
The fixture alone is source evidence. Executed SnapPy comparison is owned by
the separate AI-CI acceptance job and must be reported by its actual receipt.

Faces are numbered by the opposite vertex. A permutation lists the images
of vertices 0,1,2,3, in that order.

| Source | Target | Vertex images |
|---|---|---|
| 0, face 0 | 1, face 0 | 0132 |
| 0, face 1 | 1, face 2 | 1230 |
| 0, face 2 | 1, face 1 | 2310 |
| 0, face 3 | 1, face 3 | 2103 |
| 1, face 0 | 0, face 0 | 0132 |
| 1, face 1 | 0, face 2 | 3201 |
| 1, face 2 | 0, face 1 | 3012 |
| 1, face 3 | 0, face 3 | 2103 |

Each local tetrahedron has ideal directions
`w₀=(1,1,1)/√3`, `w₁=(1,−1,−1)/√3`,
`w₂=(−1,1,−1)/√3`, `w₃=(−1,−1,1)/√3`.
The ideal vertices `(wᵢ,1)` are null vectors, never finite camera positions.
The center is `(0,0,0,1)`. With Lorentz signature `+++−`, face normal
`Nᵢ=(wᵢ,−1/3)` has norm squared `8/9`; the interior satisfies
`⟨P,Nᵢ⟩>0`.

For face `i`, reflect by `Rᵢ(P)=P−(9/4)⟨P,Nᵢ⟩Nᵢ`. Then apply the unique
orthogonal tetrahedral symmetry carrying `wᵥ` to `wπ(v)` for every vertex.
Both operations reverse orientation, so their product preserves it.
The row-vector matrix is `Rᵢ Tπ`. The spatial permutation matrix has entries
`(1/4) Σᵥ signs(v,row) signs(π(v),column)`, which are exact small integers.
Only √3 and floating arithmetic enter the numerical realization.

The inverse is the transition at the target face. Tests check the complete
matrix product, the three ordered face vertices, and point, tangent, and all
three frame vectors. Walking each oriented edge incidence gives six regular
wedges, total dihedral angle `2π`, and identity developed holonomy. Independent
acceptance must also check the source peripheral data and complete shapes;
local inverse matrices alone do not identify a knot complement.

## State and event semantics

`kc_m004_state` owns the tetrahedron, the H³ ray including accumulated travel,
the entire camera frame, and an incoming-face witness. An interior state has
`incoming_face = −1`. Immediately after crossing, its position is on the
target face and its direction points into the target cell.

The witness suppresses only that incoming seam. It is checked against the
position and inward direction; it cannot hide another face. A user-supplied
boundary without a valid witness, an edge tie, or a grazing ray returns an
explicit unresolved result. There is no spatial nudge, artificial seam
length, or reflection of the physical ray.

`kc_m004_first_event` solves `tanh(s)=−⟨P,N⟩/⟨V,N⟩` for all outgoing faces
and chooses the earliest isolated finite event. It records the boundary state
before the chart change and the complete state after it. The outgoing
`before` state is evidence, not an admissible incoming navigation state.
All failure, range, and budget statuses leave output objects unchanged.

`kc_m004_travel` repeats events and ordinary H³ advances with segments at most
one unit, total requested length at most 64, and an explicit crossing budget
at most 4096. These are numerical/resource policies; they are not boundaries
of the mathematical space. Ideal vertices remain infinitely far away. Cusp
excursions can still reach the underlying H³ component limit and return a
numerical-range refusal.

`kc_m004_reorient` selects a new viewing tangent at the same position. At a
seam, an outward tangent is moved through the inverse face pairing, carrying
the complete frame and preserving travel. This zero-distance representative
change lets a camera resting on a seam cast rays into either adjacent cell.
A grazing choice remains unresolved. The physical camera frame is independent
of an individual viewing ray's direction.

The numerical admission tolerance is `2×10⁻¹⁰` for seams and event separation,
in addition to the H³ kernel's own checks. This bounded double reference does
not provide interval certification, arbitrary cusp precision, or a globally
conditioned accumulated developing matrix.

## Exact worked event

Begin at tetrahedron 0's center with direction `−w₀`, travel already 2, and
side vectors `(1,−1,0,0)/√2` and `(−1,−1,2,0)/√6`. The first face is 0 at
`s=(log 2)/2`. The boundary position is
`(−1/(2√6),−1/(2√6),−1/(2√6),3/(2√2))` and tangent is
`(−3/(2√6),−3/(2√6),−3/(2√6),1/(2√2))`.

Pairing `0132` exchanges y and z after the reflection. It fixes this boundary
point, reverses these tangent coordinates, and sends the side vectors to
`(1,0,−1,0)/√2` and `(−1,2,−1,0)/√6`. Continuing another `(log 2)/2` reaches
tetrahedron 1's center with direction `w₀`. Total accumulated travel is
`2+log 2`. Pulling all target vectors back by the inverse map reproduces the
unbroken developed geodesic; comparing raw coordinates in different cells
would give the wrong continuity test.

## Executable contract and acceptance boundaries

The candidate compiles `h3_ray.c`, `m004_atlas.c`, and `test_m004_atlas.c`
through pinned ICK, with C17, `-O2 -Wall -Wextra -Werror`, and the math library.
The existing qualified ICK host requires `-fno-link-libatomic`.
`test_m004_atlas --emit PATH` writes strict ordered `key<TAB>number` rows:
all eight pairing permutations/matrices; the exact worked event and center;
four successive generic events with every point/tangent/frame component;
and a twelve-unit path endpoint. No timestamps or ambient randomness enter
the numeric fixture. Without `--emit`, the same mathematical tests run except
the four export-only event assertions.

Tests also exercise all oriented edge cycles; 32 deterministic interior rays
and their returns; a longer return; seam viewing reversal; a tied edge event;
invalid points, frames, cell IDs, and seam witnesses; output preservation;
crossing/distance/range budgets; and finite movement toward an ideal cusp.
Two separately compiled mutants replace an ordered pairing or leave a
tangent in its former chart. Both must fail an actual executable check.

The independent checker belongs to `isomorphisms/ai-ci`; its source must not
import the candidate implementation. It compares exported source software
data, separate mathematical constructions, and actual rejecting exits.
The final hosted receipt, exact leaf/oracle/pipeline/compiler heads, and
artifact digest are the evidence of execution. This source file itself does
not assert that a test has passed.

No Android, GPU, physical-device, release, or handmade construction evidence
is supplied by this atlas. MIRO A1/C67 precision and performance require
separate target execution. No renderer convention may alter the authoritative
face table, shape, camera frame, or travelled intrinsic distance.

## Relationship to the preserved Geometry Center work

The historical `fig8.dgp` is a Dirichlet/group presentation in another frame.
Its first-generator displacement `log 3` remains a useful separate oracle.
An atlas face transition is not automatically that deck generator. Compare
matrices only after establishing the exact conjugacy and group-word
correspondence. This implementation reuses the checked Lorentz operations
and event propagation, while preserving the archived domain construction and
recentring sources for that later comparison.
