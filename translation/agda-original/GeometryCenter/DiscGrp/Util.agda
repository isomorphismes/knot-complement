module GeometryCenter.DiscGrp.Util where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags

replaceRow : Nat → Point4 → Transform → Transform
replaceRow = replaceAt

tuneup : Transform → Nat → Transform
tuneup matrix metric =
  let row0 = spaceNormalize (row4 matrix 0) metric

      row1a = spaceGramSchmidt row0 (row4 matrix 1) metric
      row1 = spaceNormalize row1a metric

      row2a = spaceGramSchmidt row0 (row4 matrix 2) metric
      row2b = spaceGramSchmidt row1 row2a metric
      row2 = spaceNormalize row2b metric

      row3a = spaceGramSchmidt row0 (row4 matrix 3) metric
      row3b = spaceGramSchmidt row1 row3a metric
      row3c = spaceGramSchmidt row2 row3b metric
      row3 = spaceNormalize row3c metric
  in row0 ∷ row1 ∷ row2 ∷ row3 ∷ []

expectedMinkowskiEntry : Nat → Nat → Float
expectedMinkowskiEntry i j =
  if natEq i j then 1.0 else 0.0

checkPair : Transform → Nat → Nat → Bool
checkPair matrix i j =
  let d0 =
        matrixEntry matrix i 0 *f matrixEntry matrix j 0 +f
        matrixEntry matrix i 1 *f matrixEntry matrix j 1 +f
        matrixEntry matrix i 2 *f matrixEntry matrix j 2 -f
        matrixEntry matrix i 3 *f matrixEntry matrix j 3
      d = if natEq i 3 then negf d0 else d0
  in floatLess 0.01 (absf (d -f expectedMinkowskiEntry i j))

upperPairs : List (Pair Nat Nat)
upperPairs =
  (0 , 0) ∷ (0 , 1) ∷ (0 , 2) ∷ (0 , 3) ∷
  (1 , 1) ∷ (1 , 2) ∷ (1 , 3) ∷
  (2 , 2) ∷ (2 , 3) ∷
  (3 , 3) ∷ []

needstuneup : Transform → Bool
needstuneup matrix =
  any
    (λ pair → checkPair matrix (first pair) (second pair))
    upperPairs
