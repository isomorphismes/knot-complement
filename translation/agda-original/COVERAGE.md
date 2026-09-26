# Historical source coverage

This ledger defines what "full translation" means for this first Agda pass.

The target is the historical program source used by **Not Knot Flythrough** and
**Maniview**, plus the complete Geomview `discgrp` implementation vendored in
this repository.  Data files remain data; external libraries remain explicit
external boundaries.

## Geomview `discgrp`

| Historical source | Agda counterpart |
|---|---|
| `colormap.c` | `GeometryCenter/DiscGrp/Colormap.agda` |
| `complex.c`, `complex.h` | `DiscGrp/Complex.agda` |
| `dgbound.c` | `DiscGrp/Bound.agda` |
| `dgclass.c` | `DiscGrp/Class.agda` |
| `dgconstraint.c` | `DiscGrp/Constraint.agda` |
| `dgcopy.c` | `DiscGrp/Copy.agda` |
| `dgcreate.c` | `DiscGrp/Create.agda` |
| `dgdelete.c` | `DiscGrp/Delete.agda` |
| `dgdirdom.c` | `DiscGrp/Dirdom.agda` |
| `dgdraw.c` | `DiscGrp/Draw.agda` |
| `dgenum.c`, `enum.h` | `DiscGrp/Enum.agda`, `Stack.agda`, `OutStack.agda` |
| `dgevert.c` | `DiscGrp/Evert.agda` |
| `dgflag.h` | `DiscGrp/Flags.agda` |
| `dgmisc.c` | `DiscGrp/Misc.agda` |
| `dgpick.c` | `DiscGrp/Pick.agda` |
| `dgsave.c` | `DiscGrp/Save.agda` |
| `dgstream.c` | `DiscGrp/Stream.agda` |
| `dgtransform.c` | `DiscGrp/Transform.agda` |
| `dhpoint3.c` | `DiscGrp/DHPoint3.agda` |
| `discgrp.h`, `discgrpP.h` | `Types.agda`, `Create.agda` |
| `extern.h` | `Legacy.agda` boundary |
| `matlist.c` | `DiscGrp/MatList.agda` |
| `options.h` | constants distributed to `Flags.agda` / `WeeksDirdom.agda` |
| `polyhedron.c` | `DiscGrp/Polyhedron.agda` |
| `projective.c`, `projective.h` | `DiscGrp/Projective.agda` |
| `stack.c` | `DiscGrp/Stack.agda` |
| `util.c` | `DiscGrp/Util.agda` |
| `vec4.h` | point/list operations in `DHPoint3.agda` |
| `weeks_dirdom.c` active code | `DiscGrp/WeeksDirdom.agda` |
| `weeks_dirdom.c` `#if 0` routines | `DiscGrp/WeeksDisabled.agda` |
| `winged_edge.h` | winged-edge records in `Types.agda` |
| `xform.c` | `DiscGrp/Xform.agda` |

The Geomview geometry/camera/XForms/file APIs called by those files are outside
the selected source directory.  Their exact call boundaries are declared in
`GeometryCenter/Legacy.agda`; they are not replaced with invented behavior.

## Not Knot Flythrough

| Historical source | Agda counterpart |
|---|---|
| `main.c`, `flythrough.h` | `Flythrough/Main.agda` |
| `panel.c`, `panel.h` | `Flythrough/Panel.agda` plus exact generated call stream in `GeneratedPanelCalls.agda` |
| `panel.fd` | retained upstream as XForms designer input |
| `flyhelp`, `flyhelp.h` | retained as help data |
| `flythrough.1gv` | retained as manual/documentation |
| `data/*.gv`, `*.tlist`, `*.vect` | retained as runtime geometry/path data |

The historical 18-line camera-command playback rule, path naming, environment
lookup, Geomview command output, diagram launcher, and the source's uninitialized
`turbo` variable are represented in `Flythrough/Main.agda`.

## Maniview

| Historical source | Agda counterpart |
|---|---|
| `maniview.c`, `maniview.h` | `Maniview/State.agda`, `Maniview/Main.agda` |
| `callbacks.c` | `Maniview/Callbacks.agda` |
| `controlpanel.c`, `controlpanel.h` | exact generated call stream in `Maniview/GeneratedControlPanelCalls.agda` |
| `controlpanel.fd` | retained upstream as XForms designer input |
| `gvinit`, `gvinit.h` | initialization command data embedded in `Maniview/Main.agda` |
| `maniviewhelp`, `maniviewhelp.h` | retained as help data |
| `*.dgp`, `*.wa`, `*.vect`, `*.geom`, `*.off` | retained as manifold/geometry data |
| `Makefile.am`, `configure.ac`, `reconf` | retained build machinery, not application semantics |
| `README`, `NEWS`, `ChangeLog`, `AUTHORS`, `COPYING`, `maniview.1` | retained documentation/metadata |

## Deliberately preserved source behavior

This tree is not a cleanup pass.

Examples already preserved:

- `matlist.c` computes `d = fabs(...)` and then has a `d < 0` branch; the
  direct translation preserves that unreachable branch structure.
- `polyhedron.c` contains assignments inside conditions such as
  `if ((edge->e0L->v0 = edge->v0))`; the Agda translation models the mutation
  and always-taken non-null branch explicitly.
- `flythrough/main.c` leaves `turbo` uninitialized unless `-t` is supplied;
  the Agda state represents that as an explicit undefined boundary rather than
  silently initializing it.
- The historical hyperbolic-distance `acosh` call is preserved without the
  later clamp introduced by our refactor experiment.
- `DiscGrpScalePolyList`'s static Euclidean accumulator is represented as
  persistent state rather than reset on each call.

Any correction to those behaviors belongs in a later refactor derived from this
tree.

## Verification

`GeometryCenter/All.agda` imports every translated module.  CI typechecks that
umbrella module so a green check means the complete translated source tree is
accepted together, not merely that isolated snippets exist.
