module GeometryCenter.DiscGrp.Constraint where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags

record StandardConstraint : Set where
  constructor standardConstraint
  field
    constraintDepth : Nat
    constraintStored : Float
    constraintPrintDistance : Float
open StandardConstraint public

DiscGrpInitStandardConstraint : Nat → Float → Float → StandardConstraint
DiscGrpInitStandardConstraint depth stored printDistance =
  standardConstraint depth stored printDistance

DiscGrpStandardConstraint : StandardConstraint → DiscGrpEl → Nat
DiscGrpStandardConstraint config element =
  let wordLength = stringLength (elementWord element)
      metric = bitAnd (elementAttributes element) DG-METRIC-BITS
  in if natLess (constraintDepth config) wordLength
       then DG-CONSTRAINT-LONG
       else
         let lengthBits =
               if natEq wordLength (constraintDepth config)
                 then DG-CONSTRAINT-MAXLEN
                 else 0
             image = transformPoint (elementTransform element) origin4
             distance = spaceDistance origin4 image metric
         in if floatLess distance (constraintStored config)
              then bitOr
                     lengthBits
                     (bitOr
                       DG-CONSTRAINT-STORE
                       (if floatLess distance (constraintPrintDistance config)
                          then DG-CONSTRAINT-PRINT
                          else 0))
              else bitOr lengthBits DG-CONSTRAINT-TOOFAR
