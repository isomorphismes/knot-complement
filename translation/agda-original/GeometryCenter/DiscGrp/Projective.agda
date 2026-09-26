module GeometryCenter.DiscGrp.Projective where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.DiscGrp.Complex
open import GeometryCenter.DiscGrp.Xform

m0 m1 m2 m3 : SL2CMatrix
m0 = makeSL2C
       (complex 0.0 0.0) (complex 0.0 1.0)
       (complex 0.0 (negf 1.0)) (complex 0.0 0.0)
m1 = makeSL2C
       (complex 0.0 0.0) (complex 1.0 0.0)
       (complex 1.0 0.0) (complex 0.0 0.0)
m2 = makeSL2C
       (complex (negf 1.0) 0.0) (complex 0.0 0.0)
       (complex 0.0 0.0) (complex 1.0 0.0)
m3 = makeSL2C
       (complex 1.0 0.0) (complex 0.0 0.0)
       (complex 0.0 0.0) (complex 1.0 0.0)

basisMatrices : List SL2CMatrix
basisMatrices = m0 ∷ m1 ∷ m2 ∷ m3 ∷ []

projectiveColumn : SL2CMatrix → SL2CMatrix → Point4
projectiveColumn s basis =
  let ad-s = sl2c-adjoint s
      temp = sl2c-mult s basis
      fs = sl2c-mult temp ad-s
      fs00 = slEntry fs 0 0
      fs01 = slEntry fs 0 1
      fs11 = slEntry fs 1 1
  in imag fs01 ∷
     real fs01 ∷
     (0.5 *f (real fs11 -f real fs00)) ∷
     (0.5 *f (real fs11 +f real fs00)) ∷ []

columnsToMatrix : List Point4 → Matrix4
columnsToMatrix columns =
  (pointEntry (row4 columns 0) 0 ∷
   pointEntry (row4 columns 1) 0 ∷
   pointEntry (row4 columns 2) 0 ∷
   pointEntry (row4 columns 3) 0 ∷ []) ∷
  (pointEntry (row4 columns 0) 1 ∷
   pointEntry (row4 columns 1) 1 ∷
   pointEntry (row4 columns 2) 1 ∷
   pointEntry (row4 columns 3) 1 ∷ []) ∷
  (pointEntry (row4 columns 0) 2 ∷
   pointEntry (row4 columns 1) 2 ∷
   pointEntry (row4 columns 2) 2 ∷
   pointEntry (row4 columns 3) 2 ∷ []) ∷
  (pointEntry (row4 columns 0) 3 ∷
   pointEntry (row4 columns 1) 3 ∷
   pointEntry (row4 columns 2) 3 ∷
   pointEntry (row4 columns 3) 3 ∷ []) ∷ []

sl2c-to-proj : SL2CMatrix → ProjMatrix
sl2c-to-proj s =
  columnsToMatrix (map (projectiveColumn s) basisMatrices)

proj-to-sl2c : ProjMatrix → Maybe SL2CMatrix
proj-to-sl2c p =
  let t2 = matrixEntry p 3 2 -f matrixEntry p 2 2
      t3 = matrixEntry p 3 3 -f matrixEntry p 2 3
      aa = t3 -f t2
      bb = t3 +f t2
      raw =
        if floatLess bb aa
          then
            makeSL2C
              (complex aa 0.0)
              (complex
                (matrixEntry p 3 1 -f matrixEntry p 2 1)
                (matrixEntry p 3 0 -f matrixEntry p 2 0))
              (complex
                (matrixEntry p 1 3 -f matrixEntry p 1 2)
                (matrixEntry p 0 2 -f matrixEntry p 0 3))
              (complex
                (matrixEntry p 0 0 +f matrixEntry p 1 1)
                (matrixEntry p 1 0 -f matrixEntry p 0 1))
          else
            makeSL2C
              (complex
                (matrixEntry p 3 1 -f matrixEntry p 2 1)
                (matrixEntry p 2 0 -f matrixEntry p 3 0))
              (complex bb 0.0)
              (complex
                (matrixEntry p 1 1 -f matrixEntry p 0 0)
                (negf (matrixEntry p 0 1 +f matrixEntry p 1 0)))
              (complex
                (matrixEntry p 1 3 +f matrixEntry p 1 2)
                (negf (matrixEntry p 0 2 +f matrixEntry p 0 3)))
  in sl2c-normalize raw

proj-mult : ProjMatrix → ProjMatrix → ProjMatrix
proj-mult = matmatmul4

proj-copy : ProjMatrix → ProjMatrix
proj-copy p = p

setGrid : Nat → Nat → Float → Matrix4 → Matrix4
setGrid row column value matrix with lookup matrix row
... | nothing = matrix
... | just oldRow = replaceAt row (replaceAt column value oldRow) matrix

swapRows : Nat → Nat → Matrix4 → Matrix4
swapRows a b matrix with lookup matrix a | lookup matrix b
... | just rowA | just rowB = replaceAt b rowA (replaceAt a rowB matrix)
... | _ | _ = matrix

pivotCandidates : Nat → List Nat
pivotCandidates 0 = 0 ∷ 1 ∷ 2 ∷ 3 ∷ []
pivotCandidates 1 = 1 ∷ 2 ∷ 3 ∷ []
pivotCandidates 2 = 2 ∷ 3 ∷ []
pivotCandidates 3 = 3 ∷ []
pivotCandidates n = []

bestPivot : Matrix4 → Nat → Nat
bestPivot matrix column with pivotCandidates column
... | [] = column
... | first ∷ rest =
  foldl choose first rest
  where
    choose : Nat → Nat → Nat
    choose best candidate =
      if floatLess
           (absf (matrixEntry matrix best column))
           (absf (matrixEntry matrix candidate column))
        then candidate
        else best

columnsAfter : Nat → List Nat
columnsAfter 0 = 1 ∷ 2 ∷ 3 ∷ 4 ∷ 5 ∷ 6 ∷ 7 ∷ []
columnsAfter 1 = 2 ∷ 3 ∷ 4 ∷ 5 ∷ 6 ∷ 7 ∷ []
columnsAfter 2 = 3 ∷ 4 ∷ 5 ∷ 6 ∷ 7 ∷ []
columnsAfter 3 = 4 ∷ 5 ∷ 6 ∷ 7 ∷ []
columnsAfter n = []

rowsAfter : Nat → List Nat
rowsAfter 0 = 1 ∷ 2 ∷ 3 ∷ []
rowsAfter 1 = 2 ∷ 3 ∷ []
rowsAfter 2 = 3 ∷ []
rowsAfter n = []

rowsBefore : Nat → List Nat
rowsBefore 0 = []
rowsBefore 1 = 0 ∷ []
rowsBefore 2 = 1 ∷ 0 ∷ []
rowsBefore 3 = 2 ∷ 1 ∷ 0 ∷ []
rowsBefore n = []

normalizePivotRow : Matrix4 → Nat → Matrix4
normalizePivotRow matrix pivot =
  let divisor = matrixEntry matrix pivot pivot
  in foldl
       (λ current column →
          setGrid pivot column
            (matrixEntry current pivot column /f divisor)
            current)
       matrix
       (columnsAfter pivot)

clearBelowPivot : Matrix4 → Nat → Matrix4
clearBelowPivot matrix pivot =
  foldl clearRow matrix (rowsAfter pivot)
  where
    clearRow : Matrix4 → Nat → Matrix4
    clearRow current row =
      let factor = matrixEntry current row pivot
      in foldl
           (λ next column →
              setGrid row column
                (matrixEntry next row column -f
                 factor *f matrixEntry next pivot column)
                next)
           current
           (columnsAfter pivot)

forwardStep : Matrix4 → Nat → Matrix4
forwardStep matrix pivot =
  let chosen = bestPivot matrix pivot
      swapped = swapRows pivot chosen matrix
      normalized = normalizePivotRow swapped pivot
  in clearBelowPivot normalized pivot

forwardEliminate : Matrix4 → Matrix4
forwardEliminate matrix =
  foldl forwardStep matrix (0 ∷ 1 ∷ 2 ∷ 3 ∷ [])

answerColumns : List Nat
answerColumns = 4 ∷ 5 ∷ 6 ∷ 7 ∷ []

backStep : Matrix4 → Nat → Matrix4
backStep matrix pivot =
  foldl clearRow matrix (rowsBefore pivot)
  where
    clearRow : Matrix4 → Nat → Matrix4
    clearRow current row =
      let factor = matrixEntry current row pivot
      in foldl
           (λ next column →
              setGrid row column
                (matrixEntry next row column -f
                 factor *f matrixEntry next pivot column)
                next)
           current
           answerColumns

backSubstitute : Matrix4 → Matrix4
backSubstitute matrix =
  foldl backStep matrix (3 ∷ 2 ∷ 1 ∷ 0 ∷ [])

augmentRow : Nat → Point4 → Point4
augmentRow row values =
  values ++
  map
    (λ column → if natEq row column then 1.0 else 0.0)
    (0 ∷ 1 ∷ 2 ∷ 3 ∷ [])

augment : Matrix4 → Matrix4
augment matrix =
  map
    (λ indexed → augmentRow (first indexed) (second indexed))
    (enumerate matrix)

extractInverse : Matrix4 → Matrix4
extractInverse augmented =
  map
    (λ row →
       matrixEntry augmented row 4 ∷
       matrixEntry augmented row 5 ∷
       matrixEntry augmented row 6 ∷
       matrixEntry augmented row 7 ∷ [])
    (0 ∷ 1 ∷ 2 ∷ 3 ∷ [])

proj-invert : ProjMatrix → ProjMatrix
proj-invert matrix =
  extractInverse (backSubstitute (forwardEliminate (augment matrix)))
