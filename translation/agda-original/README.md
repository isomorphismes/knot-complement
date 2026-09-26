# Direct Agda translation of the Geometry Center source

This tree is deliberately **pre-refactor**.

The source of truth is the historical code under:

- `upstream/geometry-center/geomview/src/bin/flythrough/`
- `upstream/geometry-center/geomview/src/lib/gprim/discgrp/`
- `upstream/geometry-center/maniview/`

The translation follows the original file/function structure before trying to
improve the architecture.  C pointer graphs are represented by integer indices
into Agda lists; calls into Geomview, XForms, file I/O, and other libraries
outside the selected historical source are isolated in `GeometryCenter.Legacy`.

Large historical data files (`.gv`, `.tlist`, `.dgp`, `.wa`, `.vect`,
`.geom`) remain data files.  The C programs loaded them as data, so copying
their bytes into Agda source would not be a source translation.

`COVERAGE.md` records every handwritten C function and its Agda counterpart.
No architectural cleanup should be done in this tree; later refactors should be
derived from this translation, not folded into it.
