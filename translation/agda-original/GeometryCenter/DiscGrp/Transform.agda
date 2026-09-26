module GeometryCenter.DiscGrp.Transform where

open import GeometryCenter.Types

DiscGrpTransform : DiscGrp → Transform → DiscGrp
DiscGrpTransform dg transform = dg

DiscGrpTransformTo : DiscGrp → Transform → DiscGrp
DiscGrpTransformTo = DiscGrpTransform
