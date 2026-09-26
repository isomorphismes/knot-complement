module GeometryCenter.DiscGrp.Pick where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy

record PickLoopState : Set where
  constructor pickLoopState
  field
    currentPick : Pick
    picked : Bool
    elementNumber : Nat
open PickLoopState public

DiscGrpPick :
  DiscGrp →
  Pick →
  Appearance →
  Transform →
  Maybe GeomTransformN →
  Maybe DiscGrp
DiscGrpPick dg pick appearance outerTransform (just transformN) = nothing
DiscGrpPick dg pick appearance outerTransform nothing =
  case fundamentalGeometry dg of λ where
    nothing → nothing
    (just geom) →
      let final =
            foldl
              (λ state tileTransform →
                let numberedPick =
                      pickSetPathIndex
                        (currentPick state)
                        0
                        (elementNumber state)
                    transform =
                      transformConcat tileTransform outerTransform
                    hit =
                      geomPick geom numberedPick appearance transform
                in pickLoopState
                     numberedPick
                     (picked state || hit)
                     (suc (elementNumber state)))
              (pickLoopState pick false 0)
              (geomIterateTransforms dg)
      in if picked final then just dg else nothing
