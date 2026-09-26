module GeometryCenter.DiscGrp.MatList where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags

epsilon : Float
epsilon = 0.005

record MatListContext : Set where
  constructor matListContext
  field
    debugLevel : Nat
    stringent : Bool
    metric : Nat
open MatListContext public

record MatrixCluster : Set where
  constructor matrixCluster
  field
    clusterNorm : Float
    clusterMatrices : List Transform
open MatrixCluster public

data MatrixTree : Set where
  emptyTree : MatrixTree
  matrixNode : MatrixCluster → MatrixTree → MatrixTree → MatrixTree

record MatListState : Set where
  constructor matListState
  field
    head : MatrixTree
open MatListState public

emptyState : MatListState
emptyState = matListState emptyTree

sphericalDifferenceSum : Transform → Float
sphericalDifferenceSum transform =
  sumFloats
    (map
      (λ pair →
        let i = first pair
            j = second pair
            expected = if natEq i j then 1.0 else 0.0
        in absf (matrixEntry transform i j -f expected))
      ((0 , 0) ∷ (0 , 1) ∷ (0 , 2) ∷ (0 , 3) ∷
       (1 , 0) ∷ (1 , 1) ∷ (1 , 2) ∷ (1 , 3) ∷
       (2 , 0) ∷ (2 , 1) ∷ (2 , 2) ∷ (2 , 3) ∷
       (3 , 0) ∷ (3 , 1) ∷ (3 , 2) ∷ (3 , 3) ∷ []))

getnorm : Nat → Transform → Float
getnorm metric transform =
  if natEq metric DG-EUCLIDEAN
    then sqrtf
      (matrixEntry transform 3 0 *f matrixEntry transform 3 0 +f
       matrixEntry transform 3 1 *f matrixEntry transform 3 1 +f
       matrixEntry transform 3 2 *f matrixEntry transform 3 2)
    else if natEq metric DG-HYPERBOLIC
      then
        let ww = absf (matrixEntry transform 3 3)
        in if floatLess ww 1.0
             then 0.0
             else acoshf ww
      else sphericalDifferenceSum transform

strictEntrySame : Transform → Transform → Nat → Nat → Float → Bool
strictEntrySame relative original i j factor =
  let expected = factor *f (if natEq i j then 1.0 else 0.0)
  in not (floatLess
            (absf factor *f epsilon)
            (absf (matrixEntry relative i j -f expected)))

allMatrixPairs : List (Pair Nat Nat)
allMatrixPairs =
  (0 , 0) ∷ (0 , 1) ∷ (0 , 2) ∷ (0 , 3) ∷
  (1 , 0) ∷ (1 , 1) ∷ (1 , 2) ∷ (1 , 3) ∷
  (2 , 0) ∷ (2 , 1) ∷ (2 , 2) ∷ (2 , 3) ∷
  (3 , 0) ∷ (3 , 1) ∷ (3 , 2) ∷ (3 , 3) ∷ []

looseEntrySame : Transform → Transform → Pair Nat Nat → Bool
looseEntrySame t0 t1 pair =
  not
    (floatLess epsilon
      (absf
        (matrixEntry t0 (first pair) (second pair) -f
         matrixEntry t1 (first pair) (second pair))))

is-same : MatListContext → Transform → Transform → Bool
is-same context t0 t1 =
  if stringent context
    then
      case transformInverse t0 of λ where
        nothing → false
        (just inverse0) →
          let relative = transformConcat t1 inverse0
              factor = matrixEntry relative 0 0
          in all
               (λ pair →
                 strictEntrySame relative t0
                   (first pair) (second pair) factor)
               allMatrixPairs
    else all (looseEntrySame t0 t1) allMatrixPairs

clusterContains : MatListContext → MatrixCluster → Transform → Bool
clusterContains context cluster transform =
  any (λ existing → is-same context existing transform)
      (clusterMatrices cluster)

-- This preserves the original source literally: d is fabs(p->norm - n->norm),
-- so the later d < 0 branch can never be taken.
insertTree :
  MatListContext →
  Transform →
  Float →
  MatrixTree →
  Pair MatrixTree Bool
insertTree context transform norm emptyTree =
  matrixNode (matrixCluster norm (transform ∷ [])) emptyTree emptyTree , true
insertTree context transform norm (matrixNode cluster leftTree rightTree) =
  let d = absf (clusterNorm cluster -f norm)
  in if floatLess d epsilon
       then
         matrixNode
           (matrixCluster
             (clusterNorm cluster)
             (clusterMatrices cluster ++ (transform ∷ [])))
           leftTree
           rightTree , true
       else if floatLess 0.0 d
         then
           let inserted = insertTree context transform norm rightTree
           in matrixNode cluster leftTree (first inserted) , second inserted
         else
           let inserted = insertTree context transform norm leftTree
           in matrixNode cluster (first inserted) rightTree , second inserted

matchTree :
  MatListContext →
  Transform →
  Float →
  MatrixTree →
  Bool
matchTree context transform norm emptyTree = false
matchTree context transform norm (matrixNode cluster leftTree rightTree) =
  let d = absf (clusterNorm cluster -f norm)
  in if floatLess d epsilon
       then clusterContains context cluster transform
       else if floatLess 0.0 d
         then matchTree context transform norm rightTree
         else matchTree context transform norm leftTree

insert-or-match-mat :
  MatListContext →
  MatListState →
  Transform →
  Nat →
  Pair MatListState Bool
insert-or-match-mat context state transform mode =
  let norm = getnorm (metric context) transform
      doInsert = hasBit mode INSERT
      doMatch = hasBit mode MATCH
  in if doInsert
       then
         let result = insertTree context transform norm (head state)
         in matListState (first result) , second result
       else if doMatch
         then state , matchTree context transform norm (head state)
         else state , false

is-new :
  MatListContext →
  MatListState →
  Transform →
  Nat
is-new context state transform =
  let result = insert-or-match-mat context state transform MATCH
  in if second result then 0 else DG-CONSTRAINT-NEW

traverse-list : MatrixTree → List (Pair Float Nat)
traverse-list emptyTree = []
traverse-list (matrixNode cluster leftTree rightTree) =
  traverse-list leftTree ++
  ((clusterNorm cluster , length (clusterMatrices cluster)) ∷ []) ++
  traverse-list rightTree

-delete-list : MatrixTree → MatrixTree
-delete-list tree = emptyTree

delete-list : MatListState → MatListState
delete-list state = matListState (-delete-list (head state))
