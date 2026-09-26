module GeometryCenter.DiscGrp.Delete where

open import GeometryCenter.Prelude
open import GeometryCenter.Types

DiscGrpElListDelete : Maybe DiscGrpElList → Maybe DiscGrpElList
DiscGrpElListDelete existing = nothing

-- C frees owned memory and returns NULL.  Agda values are reclaimed by the
-- runtime, so the direct value-level counterpart is simply Nothing.
DiscGrpDelete : Maybe DiscGrp → Maybe DiscGrp
DiscGrpDelete dg = nothing
