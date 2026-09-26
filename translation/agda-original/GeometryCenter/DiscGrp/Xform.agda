module GeometryCenter.DiscGrp.Xform where

open import GeometryCenter.Prelude
open import GeometryCenter.Types

dot4 : Point4 → Point4 → Float
dot4 left right = sumFloats (zipWith _*f_ left right)

column4 : Matrix4 → Nat → Point4
column4 matrix column =
  matrixEntry matrix 0 column ∷
  matrixEntry matrix 1 column ∷
  matrixEntry matrix 2 column ∷
  matrixEntry matrix 3 column ∷ []

matvecmul4 : Matrix4 → Point4 → Point4
matvecmul4 matrix vector =
  dot4 (row4 matrix 0) vector ∷
  dot4 (row4 matrix 1) vector ∷
  dot4 (row4 matrix 2) vector ∷
  dot4 (row4 matrix 3) vector ∷ []

vecmatmul4 : Point4 → Matrix4 → Point4
vecmatmul4 vector matrix =
  dot4 vector (column4 matrix 0) ∷
  dot4 vector (column4 matrix 1) ∷
  dot4 vector (column4 matrix 2) ∷
  dot4 vector (column4 matrix 3) ∷ []

matmatmul4 : Matrix4 → Matrix4 → Matrix4
matmatmul4 left right =
  vecmatmul4 (row4 left 0) right ∷
  vecmatmul4 (row4 left 1) right ∷
  vecmatmul4 (row4 left 2) right ∷
  vecmatmul4 (row4 left 3) right ∷ []
