module GeometryCenter.DiscGrp.Copy where

open import GeometryCenter.Prelude
open import GeometryCenter.Types

-- The C version is a shallow struct copy, including pointer fields.
DiscGrpCopy : Maybe DiscGrp → Maybe DiscGrp
DiscGrpCopy nothing = nothing
DiscGrpCopy (just dg) = just dg
