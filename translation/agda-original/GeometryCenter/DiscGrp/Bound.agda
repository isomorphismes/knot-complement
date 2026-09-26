module GeometryCenter.DiscGrp.Bound where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy

unionMaybeBox : Maybe BBox → Maybe BBox → Maybe BBox
unionMaybeBox nothing next = next
unionMaybeBox current nothing = current
unionMaybeBox (just current) (just next) = just (bboxUnion current next)

DiscGrpBound : DiscGrp → Maybe Transform → Maybe BBox
DiscGrpBound dg suppliedTransform =
  case fundamentalGeometry dg of λ where
    nothing → nothing
    (just geom) →
      let outer =
            case suppliedTransform of λ where
              nothing → transformIdentity
              (just transform) → transform
      in foldl
           (λ result elementTransform →
              let combined = transformConcat elementTransform outer
              in unionMaybeBox result (geomBound geom combined))
           nothing
           (geomIterateTransforms dg)
