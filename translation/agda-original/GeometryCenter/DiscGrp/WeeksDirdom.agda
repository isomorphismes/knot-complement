module GeometryCenter.DiscGrp.WeeksDirdom where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags
open import GeometryCenter.DiscGrp.DHPoint3
open import GeometryCenter.DiscGrp.Projective
open import GeometryCenter.DiscGrp.Xform

-- Direct translation of weeks_dirdom.c.  C heap pointers are stable numeric
-- indices into the storage lists in WEPolyhedron.  The separate *ListOrder
-- fields reproduce the C next chains.

VERTEX-EPSILON : Float
VERTEX-EPSILON = 0.001

MATRIX-EPSILON : Float
MATRIX-EPSILON = 0.00001

MAGIC-SCALE : Float
MAGIC-SCALE = 0.99

record WeeksState : Set where
  constructor weeksState
  field
    weeksOrigin : Point4
    weeksMetric : Nat
    weeksDebug : Nat
    weeksPolyhedron : WEPolyhedron
    matrixEpsilonMessageGiven : Bool
    vertexEpsilonMessageGiven : Bool
    edgeHeapCount : Nat
open WeeksState public

emptyPolyhedron : WEPolyhedron
emptyPolyhedron =
  wePolyhedron [] [] [] [] [] [] [] [] []

initialWeeksState : Point4 → Nat → WeeksState
initialWeeksState origin metric =
  weeksState origin metric 0 emptyPolyhedron false false 0

sameMaybeNat : Maybe Nat → Maybe Nat → Bool
sameMaybeNat nothing nothing = true
sameMaybeNat (just a) (just b) = natEq a b
sameMaybeNat left right = false

containsNat : Nat → List Nat → Bool
containsNat wanted [] = false
containsNat wanted (x ∷ xs) =
  natEq wanted x || containsNat wanted xs

removeNat : Nat → List Nat → List Nat
removeNat wanted [] = []
removeNat wanted (x ∷ xs) =
  if natEq wanted x
    then removeNat wanted xs
    else x ∷ removeNat wanted xs

vertexAt : WEPolyhedron → Nat → Maybe WEVertex
vertexAt poly index = lookup (vertices poly) index

edgeAt : WEPolyhedron → Nat → Maybe WEEdge
edgeAt poly index = lookup (edges poly) index

faceAt : WEPolyhedron → Nat → Maybe WEFace
faceAt poly index = lookup (faces poly) index

setVertex : Nat → WEVertex → WEPolyhedron → WEPolyhedron
setVertex index vertex poly =
  record poly { vertices = replaceAt index vertex (vertices poly) }

setEdge : Nat → WEEdge → WEPolyhedron → WEPolyhedron
setEdge index edge poly =
  record poly { edges = replaceAt index edge (edges poly) }

setFace : Nat → WEFace → WEPolyhedron → WEPolyhedron
setFace index face poly =
  record poly { faces = replaceAt index face (faces poly) }

setPoly : WeeksState → WEPolyhedron → WeeksState
setPoly state poly =
  record state { weeksPolyhedron = poly }

setFaceSomeEdge : WEPolyhedron → Maybe Nat → Nat → WEPolyhedron
setFaceSomeEdge poly nothing edgeIndex = poly
setFaceSomeEdge poly (just faceIndex) edgeIndex with faceAt poly faceIndex
... | nothing = poly
... | just face =
  setFace faceIndex (record face { faceSomeEdge = just edgeIndex }) poly

incrementFaceOrder : WEPolyhedron → Maybe Nat → WEPolyhedron
incrementFaceOrder poly nothing = poly
incrementFaceOrder poly (just faceIndex) with faceAt poly faceIndex
... | nothing = poly
... | just face =
  setFace faceIndex
    (record face { faceOrder = suc (faceOrder face) })
    poly

clearInverseOf : WEPolyhedron → Maybe Nat → WEPolyhedron
clearInverseOf poly nothing = poly
clearInverseOf poly (just faceIndex) with faceAt poly faceIndex
... | nothing = poly
... | just face =
  setFace faceIndex (record face { faceInverse = nothing }) poly

markFaceDead : WEPolyhedron → Nat → WEPolyhedron
markFaceDead poly faceIndex with faceAt poly faceIndex
... | nothing = poly
... | just face =
  let without =
        record poly {
          faceListOrder = removeNat faceIndex (faceListOrder poly) ;
          dirtyFaces = removeNat faceIndex (dirtyFaces poly) ;
          cleanFaces = removeNat faceIndex (cleanFaces poly) ;
          pendingFaces = removeNat faceIndex (pendingFaces poly)
        }
  in setFace faceIndex (record face { faceAlive = false }) without

markEdgeDead : WEPolyhedron → Nat → WEPolyhedron
markEdgeDead poly edgeIndex with edgeAt poly edgeIndex
... | nothing = poly
... | just edge =
  setEdge edgeIndex (record edge { edgeAlive = false })
    (record poly { edgeListOrder = removeNat edgeIndex (edgeListOrder poly) })

markVertexDead : WEPolyhedron → Nat → WEPolyhedron
markVertexDead poly vertexIndex with vertexAt poly vertexIndex
... | nothing = poly
... | just vertex =
  setVertex vertexIndex (record vertex { vertexAlive = false })
    (record poly { vertexListOrder = removeNat vertexIndex (vertexListOrder poly) })

-- --------------------------------------------------------------------------
-- Initial cube (make_cube)
-- --------------------------------------------------------------------------

record EdgeInit : Set where
  constructor edgeInit
  field
    iv0 iv1 ie0L ie0R ie1L ie1R ifL ifR : Nat
open EdgeInit public

edgeData : List EdgeInit
edgeData =
  edgeInit 0 4 8 4 9 6 2 4 ∷
  edgeInit 2 6 4 10 6 11 4 3 ∷
  edgeInit 1 5 5 8 7 9 5 2 ∷
  edgeInit 3 7 10 5 11 7 3 5 ∷
  edgeInit 0 2 0 8 1 10 4 0 ∷
  edgeInit 1 3 8 2 10 3 0 5 ∷
  edgeInit 4 6 9 0 11 1 1 4 ∷
  edgeInit 5 7 2 9 3 11 5 1 ∷
  edgeInit 0 1 4 0 5 2 0 2 ∷
  edgeInit 4 5 0 6 2 7 2 1 ∷
  edgeInit 2 3 1 4 3 5 3 0 ∷
  edgeInit 6 7 6 1 7 3 1 3 ∷ []

faceData : List Nat
faceData = 4 ∷ 6 ∷ 0 ∷ 1 ∷ 0 ∷ 2 ∷ []

signed17 : Bool → Float
signed17 true = 17.0
signed17 false = negf 17.0

makeCubeVertex : Nat → WEVertex
makeCubeVertex index =
  weVertex true
    (makePoint4
      (signed17 (not (natEq (bitAnd index 4) 0)))
      (signed17 (not (natEq (bitAnd index 2) 0)))
      (signed17 (not (natEq (bitAnd index 1) 0)))
      1.0)
    0.0
    false

makeCubeEdge : EdgeInit → WEEdge
makeCubeEdge datum =
  weEdge true
    (iv0 datum) (iv1 datum)
    (just (ie0L datum)) (just (ie0R datum))
    (just (ie1L datum)) (just (ie1R datum))
    (just (ifL datum)) (just (ifR datum))

makeCubeFace : Nat → Nat → WEFace
makeCubeFace index firstEdge =
  weFace true
    4
    (negsuc 1)              -- -2, the original cube marker
    (just firstEdge)
    identity4
    nothing
    (if natLess index 5 then just (suc index) else nothing)
    (if natEq index 0 then nothing else just (natPred index))
    (if natLess index 5 then just (suc index) else nothing)

make-cube : WeeksState → WeeksState
make-cube state =
  let cubeVertices = map makeCubeVertex (range 8)
      cubeEdges = map makeCubeEdge edgeData
      cubeFaces =
        map
          (λ indexed → makeCubeFace (first indexed) (second indexed))
          (enumerate faceData)
      poly =
        wePolyhedron
          cubeVertices
          cubeEdges
          cubeFaces
          (range 8)
          (range 12)
          (range 6)
          (range 6)
          []
          []
  in setPoly state poly

-- --------------------------------------------------------------------------
-- Face/edge traversal helpers
-- --------------------------------------------------------------------------

nextCounterclockwiseEdge : WEEdge → Nat → Maybe Nat
nextCounterclockwiseEdge edge faceIndex =
  if sameMaybeNat (edgeLeftFace edge) (just faceIndex)
    then edgeFrontLeft edge
    else edgeBackRight edge

nextClockwiseEdge : WEEdge → Nat → Maybe Nat
nextClockwiseEdge edge faceIndex =
  if sameMaybeNat (edgeLeftFace edge) (just faceIndex)
    then edgeBackLeft edge
    else edgeFrontRight edge

faceBoundaryEdges : WEPolyhedron → Nat → List Nat
faceBoundaryEdges poly faceIndex with faceAt poly faceIndex
... | nothing = []
... | just face =
  case faceSomeEdge face of λ where
    nothing → []
    (just firstEdge) → walk (faceOrder face) firstEdge
  where
    walk : Nat → Nat → List Nat
    walk 0 edgeIndex = []
    walk (suc fuel) edgeIndex with edgeAt poly edgeIndex
    ... | nothing = []
    ... | just edge =
      edgeIndex ∷
      case nextCounterclockwiseEdge edge faceIndex of λ where
        nothing → []
        (just next) → walk fuel next

clockwiseBoundaryEdges : WEPolyhedron → Nat → List Nat
clockwiseBoundaryEdges poly faceIndex with faceAt poly faceIndex
... | nothing = []
... | just face =
  case faceSomeEdge face of λ where
    nothing → []
    (just firstEdge) → walk (faceOrder face) firstEdge
  where
    walk : Nat → Nat → List Nat
    walk 0 edgeIndex = []
    walk (suc fuel) edgeIndex with edgeAt poly edgeIndex
    ... | nothing = []
    ... | just edge =
      edgeIndex ∷
      case nextClockwiseEdge edge faceIndex of λ where
        nothing → []
        (just next) → walk fuel next

directedVertices : WEPolyhedron → Nat → Nat → Maybe (Pair Nat Nat)
directedVertices poly faceIndex edgeIndex with edgeAt poly edgeIndex
... | nothing = nothing
... | just edge =
  if sameMaybeNat (edgeLeftFace edge) (just faceIndex)
    then just (edgeTail edge , edgeTip edge)
    else just (edgeTip edge , edgeTail edge)

oppositeFace : WEEdge → Nat → Maybe Nat
oppositeFace edge faceIndex =
  if sameMaybeNat (edgeLeftFace edge) (just faceIndex)
    then edgeRightFace edge
    else edgeLeftFace edge

faceVertexIndices : WEPolyhedron → Nat → List Nat
faceVertexIndices poly faceIndex =
  map pickStart (faceBoundaryEdges poly faceIndex)
  where
    pickStart : Nat → Nat
    pickStart edgeIndex with directedVertices poly faceIndex edgeIndex
    ... | nothing = 0
    ... | just pair = first pair

faceNeighborMatrices : WEPolyhedron → Nat → List ProjMatrix
faceNeighborMatrices poly faceIndex =
  map matrixFor (clockwiseBoundaryEdges poly faceIndex)
  where
    matrixFor : Nat → ProjMatrix
    matrixFor edgeIndex with edgeAt poly edgeIndex
    ... | nothing = identity4
    ... | just edge =
      case oppositeFace edge faceIndex of λ where
        nothing → identity4
        (just neighborIndex) →
          case faceAt poly neighborIndex of λ where
            nothing → identity4
            (just neighbor) → faceGroupElement neighbor

-- --------------------------------------------------------------------------
-- Matrix equality and diagnostics
-- --------------------------------------------------------------------------

matrixPairs : List (Pair Nat Nat)
matrixPairs =
  (0 , 0) ∷ (0 , 1) ∷ (0 , 2) ∷ (0 , 3) ∷
  (1 , 0) ∷ (1 , 1) ∷ (1 , 2) ∷ (1 , 3) ∷
  (2 , 0) ∷ (2 , 1) ∷ (2 , 2) ∷ (2 , 3) ∷
  (3 , 0) ∷ (3 , 1) ∷ (3 , 2) ∷ (3 , 3) ∷ []

roundoff-message : String → Unit
roundoff-message epsilonName =
  standardError
    (stringAppend
      "WARNING: roundoff error is getting perilously large: "
      epsilonName)

proj-same-matrix : WeeksState → ProjMatrix → ProjMatrix → Pair WeeksState Bool
proj-same-matrix state m0 m1 =
  checkPairs state matrixPairs
  where
    checkPairs :
      WeeksState →
      List (Pair Nat Nat) →
      Pair WeeksState Bool
    checkPairs current [] = current , true
    checkPairs current (pair ∷ rest) =
      let diff =
            absf
              (matrixEntry m0 (first pair) (second pair) -f
               matrixEntry m1 (first pair) (second pair))
      in if floatLess MATRIX-EPSILON diff
           then current , false
           else
             let nearLimit =
                   floatLess
                     (0.01 *f MATRIX-EPSILON)
                     diff
                 next =
                   if nearLimit &&
                      not (matrixEpsilonMessageGiven current)
                     then
                       let ignored =
                             if natEq (weeksDebug current) 0
                               then tt
                               else roundoff-message "MATRIX_EPSILON"
                       in record current { matrixEpsilonMessageGiven = true }
                     else current
             in checkPairs next rest

-- --------------------------------------------------------------------------
-- Edge cutting
-- --------------------------------------------------------------------------

scalePoint4 : Float → Point4 → Point4
scalePoint4 scale point =
  map (λ value → scale *f value) point

addPoint4 : Point4 → Point4 → Point4
addPoint4 left right = zipWith _+f_ left right

edgeEndpointDistance : WEPolyhedron → Nat → Float
edgeEndpointDistance poly vertexIndex with vertexAt poly vertexIndex
... | nothing = 0.0
... | just vertex = vertexDistance vertex

replaceEdgeReference :
  Nat → Nat → (WEEdge → Maybe Nat) → (WEEdge → Maybe Nat → WEEdge) →
  WEPolyhedron → WEPolyhedron
replaceEdgeReference edgeIndex oldReference projection setter poly
  with edgeAt poly edgeIndex
... | nothing = poly
... | just edge =
  if sameMaybeNat (projection edge) (just oldReference)
    then setEdge edgeIndex (setter edge (just (length (edges poly)))) poly
    else poly

setE0L : WEEdge → Maybe Nat → WEEdge
setE0L edge value = record edge { edgeBackLeft = value }

setE0R : WEEdge → Maybe Nat → WEEdge
setE0R edge value = record edge { edgeBackRight = value }

setE1L : WEEdge → Maybe Nat → WEEdge
setE1L edge value = record edge { edgeFrontLeft = value }

setE1R : WEEdge → Maybe Nat → WEEdge
setE1R edge value = record edge { edgeFrontRight = value }

splitEdge : WeeksState → Nat → WeeksState
splitEdge state edgeIndex with edgeAt (weeksPolyhedron state) edgeIndex
... | nothing = state
... | just edge =
  let poly0 = weeksPolyhedron state
      d0 = edgeEndpointDistance poly0 (edgeTail edge)
      d1 = edgeEndpointDistance poly0 (edgeTip edge)
      crosses =
        (floatLess d0 0.0 && floatLess 0.0 d1) ||
        (floatLess 0.0 d0 && floatLess d1 0.0)
  in if not crosses
       then state
       else
         case vertexAt poly0 (edgeTail edge) of λ where
           nothing → state
           (just v0) →
             case vertexAt poly0 (edgeTip edge) of λ where
               nothing → state
               (just v1) →
                 let t = negf d0 /f (d1 -f d0)
                     s = 1.0 -f t
                     newCoordinates =
                       addPoint4
                         (scalePoint4 s (vertexCoordinates v0))
                         (scalePoint4 t (vertexCoordinates v1))
                     newVertexIndex = length (vertices poly0)
                     newEdgeIndex = length (edges poly0)
                     newVertex =
                       weVertex true newCoordinates 0.0 false
                     newEdge =
                       weEdge true
                         newVertexIndex
                         (edgeTip edge)
                         (just edgeIndex)
                         (just edgeIndex)
                         (edgeFrontLeft edge)
                         (edgeFrontRight edge)
                         (edgeLeftFace edge)
                         (edgeRightFace edge)
                     shortened =
                       record edge {
                         edgeTip = newVertexIndex ;
                         edgeFrontLeft = just newEdgeIndex ;
                         edgeFrontRight = just newEdgeIndex
                       }
                     poly1 =
                       record poly0 {
                         vertices = vertices poly0 ++ (newVertex ∷ []) ;
                         vertexListOrder =
                           newVertexIndex ∷ vertexListOrder poly0 ;
                         edges = edges poly0 ++ (newEdge ∷ []) ;
                         edgeListOrder =
                           newEdgeIndex ∷ edgeListOrder poly0
                       }
                     poly2 = setEdge edgeIndex shortened poly1
                     poly3 =
                       case edgeFrontLeft edge of λ where
                         nothing → poly2
                         (just neighbor) →
                           case edgeAt poly2 neighbor of λ where
                             nothing → poly2
                             (just ne) →
                               if sameMaybeNat (edgeBackLeft ne) (just edgeIndex)
                                 then setEdge neighbor
                                        (record ne { edgeBackLeft = just newEdgeIndex })
                                        poly2
                                 else setEdge neighbor
                                        (record ne { edgeFrontRight = just newEdgeIndex })
                                        poly2
                     poly4 =
                       case edgeFrontRight edge of λ where
                         nothing → poly3
                         (just neighbor) →
                           case edgeAt poly3 neighbor of λ where
                             nothing → poly3
                             (just ne) →
                               if sameMaybeNat (edgeBackRight ne) (just edgeIndex)
                                 then setEdge neighbor
                                        (record ne { edgeBackRight = just newEdgeIndex })
                                        poly3
                                 else setEdge neighbor
                                        (record ne { edgeFrontLeft = just newEdgeIndex })
                                        poly3
                     poly5 = incrementFaceOrder poly4 (edgeLeftFace edge)
                     poly6 = incrementFaceOrder poly5 (edgeRightFace edge)
                 in setPoly state poly6

cut-edges : WeeksState → WeeksState
cut-edges state =
  foldl splitEdge state (edgeListOrder (weeksPolyhedron state))

adjust-f-e-ptrs : WeeksState → WeeksState
adjust-f-e-ptrs state =
  foldl adjust state (edgeListOrder (weeksPolyhedron state))
  where
    adjust : WeeksState → Nat → WeeksState
    adjust current edgeIndex with edgeAt (weeksPolyhedron current) edgeIndex
    ... | nothing = current
    ... | just edge =
      let poly = weeksPolyhedron current
          d0 = edgeEndpointDistance poly (edgeTail edge)
          d1 = edgeEndpointDistance poly (edgeTip edge)
      in if floatLess d0 0.0 || floatLess d1 0.0
           then
             setPoly current
               (setFaceSomeEdge
                 (setFaceSomeEdge poly (edgeLeftFace edge) edgeIndex)
                 (edgeRightFace edge)
                 edgeIndex)
           else current

-- --------------------------------------------------------------------------
-- Face cutting
-- --------------------------------------------------------------------------

record CutAnalysis : Set where
  constructor cutAnalysis
  field
    zeroCount : Nat
    seenCount : Nat
    e0 e1 e2 e3 : Maybe Nat
    count1 count3 : Nat
    zeroZeroEdge : Maybe Nat
open CutAnalysis public

emptyAnalysis : CutAnalysis
emptyAnalysis =
  cutAnalysis 0 0 nothing nothing nothing nothing 0 0 nothing

analyzeBoundaryEdge :
  WEPolyhedron → Nat → CutAnalysis → Nat → CutAnalysis
analyzeBoundaryEdge poly faceIndex analysis edgeIndex =
  case directedVertices poly faceIndex edgeIndex of λ where
    nothing → record analysis { seenCount = suc (seenCount analysis) }
    (just direction) →
      let d0 = edgeEndpointDistance poly (first direction)
          d1 = edgeEndpointDistance poly (second direction)
          count = seenCount analysis
      in if floatEq d0 0.0
           then if floatEq d1 0.0
             then record analysis {
                    zeroZeroEdge = just edgeIndex ;
                    seenCount = suc count
                  }
             else if floatLess d1 0.0
               then record analysis {
                      zeroCount = suc (zeroCount analysis) ;
                      e3 = just edgeIndex ;
                      count3 = count ;
                      seenCount = suc count
                    }
               else record analysis {
                      zeroCount = suc (zeroCount analysis) ;
                      e1 = just edgeIndex ;
                      count1 = count ;
                      seenCount = suc count
                    }
           else if floatEq d1 0.0
             then if floatLess d0 0.0
               then record analysis {
                      e0 = just edgeIndex ;
                      seenCount = suc count
                    }
               else record analysis {
                      e2 = just edgeIndex ;
                      seenCount = suc count
                    }
             else record analysis { seenCount = suc count }

analyzeFace : WEPolyhedron → Nat → CutAnalysis
analyzeFace poly faceIndex =
  foldl
    (analyzeBoundaryEdge poly faceIndex)
    emptyAnalysis
    (faceBoundaryEdges poly faceIndex)

zeroEndpoint : WEPolyhedron → Nat → Maybe Nat
zeroEndpoint poly edgeIndex with edgeAt poly edgeIndex
... | nothing = nothing
... | just edge =
  if floatEq (edgeEndpointDistance poly (edgeTail edge)) 0.0
    then just (edgeTail edge)
    else if floatEq (edgeEndpointDistance poly (edgeTip edge)) 0.0
      then just (edgeTip edge)
      else nothing

setOppositeFaceTo :
  WEPolyhedron → Nat → Nat → Nat → WEPolyhedron
setOppositeFaceTo poly edgeIndex oldFace newFace with edgeAt poly edgeIndex
... | nothing = poly
... | just edge =
  if sameMaybeNat (edgeLeftFace edge) (just oldFace)
    then setEdge edgeIndex (record edge { edgeRightFace = just newFace }) poly
    else setEdge edgeIndex (record edge { edgeLeftFace = just newFace }) poly

installZeroZeroEdge :
  WeeksState → Nat → Nat → WeeksState
installZeroZeroEdge state faceIndex newFaceIndex =
  let analysis = analyzeFace (weeksPolyhedron state) faceIndex
  in case zeroZeroEdge analysis of λ where
       nothing → state
       (just edgeIndex) →
         let poly0 = weeksPolyhedron state
             poly1 = setOppositeFaceTo poly0 edgeIndex faceIndex newFaceIndex
             poly2 = setFaceSomeEdge poly1 (just newFaceIndex) edgeIndex
             poly3 = incrementFaceOrder poly2 (just newFaceIndex)
         in setPoly state poly3

connectCutEdge :
  WeeksState →
  Nat →
  Nat →
  CutAnalysis →
  WeeksState
connectCutEdge state faceIndex newFaceIndex analysis =
  case e0 analysis of λ where
    nothing → state
    (just e0i) →
      case e1 analysis of λ where
        nothing → state
        (just e1i) →
          case e2 analysis of λ where
            nothing → state
            (just e2i) →
              case e3 analysis of λ where
                nothing → state
                (just e3i) →
                  case zeroEndpoint (weeksPolyhedron state) e0i of λ where
                    nothing → state
                    (just v01) →
                      case zeroEndpoint (weeksPolyhedron state) e2i of λ where
                        nothing → state
                        (just v23) →
                          let poly0 = weeksPolyhedron state
                              newEdgeIndex = length (edges poly0)
                              newEdge =
                                weEdge true
                                  v01 v23
                                  (just e0i) (just e1i)
                                  (just e3i) (just e2i)
                                  (just faceIndex) (just newFaceIndex)
                              poly1 =
                                record poly0 {
                                  edges = edges poly0 ++ (newEdge ∷ []) ;
                                  edgeListOrder =
                                    newEdgeIndex ∷ edgeListOrder poly0
                                }
                              poly2 =
                                setFaceSomeEdge poly1 (just newFaceIndex) newEdgeIndex
                              poly3 =
                                incrementFaceOrder poly2 (just newFaceIndex)
                              poly4 =
                                case faceAt poly3 faceIndex of λ where
                                  nothing → poly3
                                  (just face) →
                                    let oldOrder = faceOrder face
                                        newOrder =
                                          suc
                                            (natMod
                                              (count1 analysis +
                                               oldOrder -
                                               count3 analysis)
                                              oldOrder)
                                    in setFace faceIndex
                                         (record face { faceOrder = newOrder })
                                         poly3
                              poly5 =
                                record poly4 {
                                  dirtyFaces =
                                    faceIndex ∷ removeNat faceIndex (dirtyFaces poly4) ;
                                  cleanFaces =
                                    removeNat faceIndex (cleanFaces poly4) ;
                                  pendingFaces =
                                    removeNat faceIndex (pendingFaces poly4)
                                }
                          in setPoly state poly5

postulate _-_ : Nat → Nat → Nat

faceEntirelyNonnegative : WEPolyhedron → Nat → Bool
faceEntirelyNonnegative poly faceIndex with faceAt poly faceIndex
... | nothing = false
... | just face =
  case faceSomeEdge face of λ where
    nothing → false
    (just edgeIndex) →
      case edgeAt poly edgeIndex of λ where
        nothing → false
        (just edge) →
          let d0 = edgeEndpointDistance poly (edgeTail edge)
              d1 = edgeEndpointDistance poly (edgeTip edge)
          in floatLessOrEqual 0.0 d0 && floatLessOrEqual 0.0 d1

cutOneFace : Nat → WeeksState → Nat → WeeksState
cutOneFace newFaceIndex state faceIndex =
  if natEq faceIndex newFaceIndex
    then state
    else if not (faceEntirelyNonnegative (weeksPolyhedron state) faceIndex)
      then
        let analysis = analyzeFace (weeksPolyhedron state) faceIndex
            withZeroEdge =
              case zeroZeroEdge analysis of λ where
                nothing → state
                (just edgeIndex) →
                  installZeroZeroEdge state faceIndex newFaceIndex
        in if natEq (zeroCount analysis) 2
             then connectCutEdge withZeroEdge faceIndex newFaceIndex analysis
             else withZeroEdge
      else
        case faceAt (weeksPolyhedron state) faceIndex of λ where
          nothing → state
          (just face) →
            let cleared =
                  clearInverseOf
                    (weeksPolyhedron state)
                    (faceInverse face)
            in setPoly state (markFaceDead cleared faceIndex)

cut-faces : WeeksState → Nat → WeeksState
cut-faces state newFaceIndex =
  foldl
    (cutOneFace newFaceIndex)
    state
    (faceListOrder (weeksPolyhedron state))

-- --------------------------------------------------------------------------
-- Dead edge/vertex cleanup
-- --------------------------------------------------------------------------

repairAtTail : WEPolyhedron → Nat → WEEdge → WEPolyhedron
repairAtTail poly edgeIndex edge =
  if not (floatEq (edgeEndpointDistance poly (edgeTail edge)) 0.0)
    then poly
    else
      case edgeBackLeft edge of λ where
        nothing → poly
        (just leftIndex) →
          case edgeBackRight edge of λ where
            nothing → poly
            (just rightIndex) →
              case edgeAt poly leftIndex of λ where
                nothing → poly
                (just leftEdge) →
                  case edgeAt poly rightIndex of λ where
                    nothing → poly
                    (just rightEdge) →
                      let leftChanged =
                            if sameMaybeNat (edgeBackRight leftEdge) (just edgeIndex)
                              then record leftEdge { edgeBackRight = just rightIndex }
                              else record leftEdge { edgeFrontLeft = just rightIndex }
                          poly1 = setEdge leftIndex leftChanged poly
                          rightChanged =
                            if sameMaybeNat (edgeBackLeft rightEdge) (just edgeIndex)
                              then record rightEdge { edgeBackLeft = just leftIndex }
                              else record rightEdge { edgeFrontRight = just leftIndex }
                      in setEdge rightIndex rightChanged poly1

repairAtTip : WEPolyhedron → Nat → WEEdge → WEPolyhedron
repairAtTip poly edgeIndex edge =
  if not (floatEq (edgeEndpointDistance poly (edgeTip edge)) 0.0)
    then poly
    else
      case edgeFrontLeft edge of λ where
        nothing → poly
        (just leftIndex) →
          case edgeFrontRight edge of λ where
            nothing → poly
            (just rightIndex) →
              case edgeAt poly leftIndex of λ where
                nothing → poly
                (just leftEdge) →
                  case edgeAt poly rightIndex of λ where
                    nothing → poly
                    (just rightEdge) →
                      let leftChanged =
                            if sameMaybeNat (edgeFrontRight leftEdge) (just edgeIndex)
                              then record leftEdge { edgeFrontRight = just rightIndex }
                              else record leftEdge { edgeBackLeft = just rightIndex }
                          poly1 = setEdge leftIndex leftChanged poly
                          rightChanged =
                            if sameMaybeNat (edgeFrontLeft rightEdge) (just edgeIndex)
                              then record rightEdge { edgeFrontLeft = just leftIndex }
                              else record rightEdge { edgeBackRight = just leftIndex }
                      in setEdge rightIndex rightChanged poly1

removeOneDeadEdge : WeeksState → Nat → WeeksState
removeOneDeadEdge state edgeIndex with edgeAt (weeksPolyhedron state) edgeIndex
... | nothing = state
... | just edge =
  let poly = weeksPolyhedron state
      d0 = edgeEndpointDistance poly (edgeTail edge)
      d1 = edgeEndpointDistance poly (edgeTip edge)
  in if floatLess 0.0 d0 || floatLess 0.0 d1
       then
         let repaired0 = repairAtTail poly edgeIndex edge
             repaired1 = repairAtTip repaired0 edgeIndex edge
         in setPoly state (markEdgeDead repaired1 edgeIndex)
       else state

remove-dead-edges : WeeksState → WeeksState
remove-dead-edges state =
  foldl removeOneDeadEdge state (edgeListOrder (weeksPolyhedron state))

removeOneDeadVertex : WeeksState → Nat → WeeksState
removeOneDeadVertex state vertexIndex with vertexAt (weeksPolyhedron state) vertexIndex
... | nothing = state
... | just vertex =
  if floatLess 0.0 (vertexDistance vertex)
    then setPoly state (markVertexDead (weeksPolyhedron state) vertexIndex)
    else state

remove-dead-vertices : WeeksState → WeeksState
remove-dead-vertices state =
  foldl removeOneDeadVertex state (vertexListOrder (weeksPolyhedron state))

-- --------------------------------------------------------------------------
-- add_face / add_element
-- --------------------------------------------------------------------------

computePlane : WeeksState → ProjMatrix → Point4
computePlane state matrix =
  let groupOrigin = matvecmul4 matrix (weeksOrigin state)
  in DHPt3PerpBisect
       (weeksOrigin state)
       groupOrigin
       (weeksMetric state)

distanceVertexFromPlane :
  WeeksState → Point4 → WEVertex → WEVertex
distanceVertexFromPlane state plane vertex =
  let raw =
        DHPt3Dot plane (vertexCoordinates vertex) (weeksMetric state)
      snapped =
        if floatLess (negf VERTEX-EPSILON) raw &&
           not (floatLess VERTEX-EPSILON raw)
          then 0.0
          else raw
  in record vertex { vertexDistance = snapped }

setAllVertexDistances : WeeksState → Point4 → WeeksState
setAllVertexDistances state plane =
  let poly = weeksPolyhedron state
  in setPoly state
       (record poly {
         vertices =
           map (distanceVertexFromPlane state plane) (vertices poly)
       })

faceNeeded : WEPolyhedron → Bool
faceNeeded poly =
  any
    (λ vertex → vertexAlive vertex &&
                floatLess VERTEX-EPSILON (vertexDistance vertex))
    (vertices poly)

reserveFace :
  WeeksState →
  Maybe Nat →
  Pair WeeksState Nat
reserveFace state inverse =
  let poly = weeksPolyhedron state
      index = length (faces poly)
      face =
        weFace false 0 (negsuc 0) nothing identity4 inverse
          nothing nothing nothing
      nextPoly =
        record poly { faces = faces poly ++ (face ∷ []) }
  in setPoly state nextPoly , index

setReservedInverse : WeeksState → Nat → Maybe Nat → WeeksState
setReservedInverse state faceIndex inverse with faceAt (weeksPolyhedron state) faceIndex
... | nothing = state
... | just face =
  setPoly state
    (setFace faceIndex (record face { faceInverse = inverse })
      (weeksPolyhedron state))

add-face-at :
  WeeksState →
  ProjMatrix →
  Nat →
  Pair WeeksState Bool
add-face-at state matrix faceIndex =
  let plane = computePlane state matrix
      withDistances = setAllVertexDistances state plane
  in if not (faceNeeded (weeksPolyhedron withDistances))
       then
         case faceAt (weeksPolyhedron withDistances) faceIndex of λ where
           nothing → withDistances , false
           (just face) →
             let cleared =
                   clearInverseOf
                     (weeksPolyhedron withDistances)
                     (faceInverse face)
                 dead = markFaceDead cleared faceIndex
             in setPoly withDistances dead , false
       else
         case faceAt (weeksPolyhedron withDistances) faceIndex of λ where
           nothing → withDistances , false
           (just face) →
             let activatedFace =
                   record face {
                     faceAlive = true ;
                     faceOrder = 0 ;
                     faceFillTone = negsuc 0 ;
                     faceGroupElement = matrix
                   }
                 activated =
                   setPoly withDistances
                     (setFace faceIndex activatedFace
                       (weeksPolyhedron withDistances))
                 edgesCut = cut-edges activated
                 pointersAdjusted = adjust-f-e-ptrs edgesCut
                 facesCut = cut-faces pointersAdjusted faceIndex
                 edgesCleaned = remove-dead-edges facesCut
                 verticesCleaned = remove-dead-vertices edgesCleaned
                 poly0 = weeksPolyhedron verticesCleaned
                 poly1 =
                   record poly0 {
                     faceListOrder =
                       faceIndex ∷ removeNat faceIndex (faceListOrder poly0) ;
                     dirtyFaces =
                       faceIndex ∷ removeNat faceIndex (dirtyFaces poly0)
                   }
             in setPoly verticesCleaned poly1 , true

add-element :
  WeeksState →
  ProjMatrix →
  Pair WeeksState Bool
add-element state matrix =
  let inverseMatrix = proj-invert matrix
      same = second (proj-same-matrix state matrix inverseMatrix)
      comparedState = first (proj-same-matrix state matrix inverseMatrix)
  in if same
       then
         let reserved = reserveFace comparedState nothing
             faceIndex = second reserved
             selfInverse =
               setReservedInverse (first reserved) faceIndex (just faceIndex)
         in add-face-at selfInverse matrix faceIndex
       else
         let firstReserved = reserveFace comparedState nothing
             firstIndex = second firstReserved
             secondReserved = reserveFace (first firstReserved) nothing
             secondIndex = second secondReserved
             paired0 =
               setReservedInverse
                 (first secondReserved)
                 firstIndex
                 (just secondIndex)
             paired1 =
               setReservedInverse paired0 secondIndex (just firstIndex)
             result0 = add-face-at paired1 matrix firstIndex
             result1 = add-face-at (first result0) inverseMatrix secondIndex
         in first result1 , (second result0 || second result1)

-- --------------------------------------------------------------------------
-- Initialization and Dirichlet-domain completion
-- --------------------------------------------------------------------------

initialize-polyhedron :
  WeeksState →
  List ProjMatrix →
  WeeksState
initialize-polyhedron state generators =
  foldl
    (λ current matrix → first (add-element current matrix))
    state
    (reverse generators)

all-dirty-faces-unmatched : WeeksState → Bool
all-dirty-faces-unmatched state =
  let poly = weeksPolyhedron state
      realDirty =
        filter
          (λ faceIndex →
             case faceAt poly faceIndex of λ where
               nothing → false
               (just face) → not (intEq (faceFillTone face) (negsuc 1)))
          (dirtyFaces poly)
  in case realDirty of λ where
       [] → false
       facesToCheck →
         all
           (λ faceIndex →
             case faceAt poly faceIndex of λ where
               nothing → true
               (just face) →
                 case faceInverse face of λ where
                   nothing → true
                   (just inverse) → false)
           facesToCheck

unsophisticated-inner :
  Nat →
  WeeksState →
  List Nat →
  Pair WeeksState Bool
unsophisticated-inner firstFace state [] = state , false
unsophisticated-inner firstFace state (secondFace ∷ rest) =
  let poly = weeksPolyhedron state
  in case faceAt poly firstFace of λ where
       nothing → unsophisticated-inner firstFace state rest
       (just face0) →
         case faceAt poly secondFace of λ where
           nothing → unsophisticated-inner firstFace state rest
           (just face1) →
             let product =
                   proj-mult
                     (faceGroupElement face0)
                     (faceGroupElement face1)
                 result = add-element state product
             in if second result
                  then result
                  else unsophisticated-inner firstFace (first result) rest

unsophisticated-search-list :
  WeeksState →
  List Nat →
  Pair WeeksState Bool
unsophisticated-search-list state [] = state , false
unsophisticated-search-list state (faceIndex ∷ rest) =
  let result =
        unsophisticated-inner
          faceIndex
          state
          (faceListOrder (weeksPolyhedron state))
  in if second result
       then result
       else unsophisticated-search-list (first result) rest

unsophisticated-search : WeeksState → Pair WeeksState Bool
unsophisticated-search state =
  unsophisticated-search-list
    state
    (faceListOrder (weeksPolyhedron state))

ensureMatchedDirtyFace : WeeksState → Pair WeeksState Bool
{-# TERMINATING #-}
ensureMatchedDirtyFace state =
  if not (all-dirty-faces-unmatched state)
    then state , true
    else
      let searched = unsophisticated-search state
      in if second searched
           then ensureMatchedDirtyFace (first searched)
           else first searched , false

allVerticesInsidePlane :
  WeeksState →
  Nat →
  ProjMatrix →
  Bool
allVerticesInsidePlane state matchFace matrix =
  let groupOrigin = matvecmul4 matrix (weeksOrigin state)
      plane =
        DHPt3PerpBisect
          (weeksOrigin state)
          groupOrigin
          (weeksMetric state)
      poly = weeksPolyhedron state
  in all
       (λ vertexIndex →
          case vertexAt poly vertexIndex of λ where
            nothing → true
            (just vertex) →
              not
                (floatLess
                  VERTEX-EPSILON
                  (DHPt3Dot plane
                    (vertexCoordinates vertex)
                    (weeksMetric state))))
       (faceVertexIndices poly matchFace)

matrixMatchesAny : WeeksState → ProjMatrix → List ProjMatrix → Pair WeeksState Bool
matrixMatchesAny state matrix [] = state , false
matrixMatchesAny state matrix (candidate ∷ rest) =
  let compared = proj-same-matrix state matrix candidate
  in if second compared
       then compared
       else matrixMatchesAny (first compared) matrix rest

check-face-edges :
  Nat →
  Nat →
  ProjMatrix →
  List Nat →
  WeeksState →
  Pair WeeksState Bool
{-# TERMINATING #-}
check-face-edges faceIndex matchFace alpha [] state = state , true
check-face-edges faceIndex matchFace alpha (edgeIndex ∷ rest) state =
  let poly = weeksPolyhedron state
  in case edgeAt poly edgeIndex of λ where
       nothing →
         check-face-edges faceIndex matchFace alpha rest state
       (just edge) →
         case oppositeFace edge faceIndex of λ where
           nothing →
             check-face-edges faceIndex matchFace alpha rest state
           (just betaFaceIndex) →
             case faceAt poly betaFaceIndex of λ where
               nothing →
                 check-face-edges faceIndex matchFace alpha rest state
               (just betaFace) →
                 let alphaBeta =
                       proj-mult alpha (faceGroupElement betaFace)
                     matching =
                       matrixMatchesAny
                         state
                         alphaBeta
                         (faceNeighborMatrices poly matchFace)
                 in if second matching
                      then
                        check-face-edges
                          faceIndex matchFace alpha rest (first matching)
                      else if allVerticesInsidePlane
                                (first matching)
                                matchFace
                                alphaBeta
                        then
                          check-face-edges
                            faceIndex matchFace alpha rest (first matching)
                        else
                          let added = add-element (first matching) alphaBeta
                              nextState = first added
                              nextPoly = weeksPolyhedron nextState
                          in if not (containsNat faceIndex (pendingFaces nextPoly))
                               then nextState , true
                               else
                                 case faceAt nextPoly faceIndex of λ where
                                   nothing → nextState , true
                                   (just currentFace) →
                                     case faceInverse currentFace of λ where
                                       nothing →
                                         let dirtied =
                                               record nextPoly {
                                                 dirtyFaces =
                                                   dirtyFaces nextPoly ++
                                                   (faceIndex ∷ []) ;
                                                 pendingFaces =
                                                   removeNat faceIndex
                                                     (pendingFaces nextPoly)
                                               }
                                         in setPoly nextState dirtied , true
                                       (just currentMatch) →
                                         case faceAt nextPoly currentMatch of λ where
                                           nothing → nextState , true
                                           (just currentMatchFace) →
                                             check-face-edges
                                               faceIndex
                                               currentMatch
                                               (faceGroupElement currentMatchFace)
                                               (faceBoundaryEdges nextPoly faceIndex)
                                               nextState

check-face : WeeksState → Nat → Pair WeeksState Bool
check-face state faceIndex =
  let poly = weeksPolyhedron state
  in case faceAt poly faceIndex of λ where
       nothing → state , true
       (just face) →
         case faceInverse face of λ where
           nothing →
             let dirtied =
                   if intEq (faceFillTone face) (negsuc 1)
                     then poly
                     else record poly {
                            dirtyFaces =
                              dirtyFaces poly ++ (faceIndex ∷ []) ;
                            pendingFaces = []
                          }
                 prepared = setPoly state dirtied
                 ensured = ensureMatchedDirtyFace prepared
             in first ensured , second ensured
           (just matchFace) →
             case faceAt poly matchFace of λ where
               nothing → state , false
               (just match) →
                 check-face-edges
                   faceIndex
                   matchFace
                   (faceGroupElement match)
                   (faceBoundaryEdges poly faceIndex)
                   state

find-Dirichlet-domain : WeeksState → Pair WeeksState Bool
{-# TERMINATING #-}
find-Dirichlet-domain state with dirtyFaces (weeksPolyhedron state)
... | [] = state , true
... | faceIndex ∷ rest =
  let poly0 = weeksPolyhedron state
      poly1 =
        record poly0 {
          dirtyFaces = rest ;
          pendingFaces = faceIndex ∷ []
        }
      pending = setPoly state poly1
      checked = check-face pending faceIndex
      afterCheck = first checked
      ok = second checked
      poly2 = weeksPolyhedron afterCheck
      originalCube =
        case faceAt poly2 faceIndex of λ where
          nothing → false
          (just face) → intEq (faceFillTone face) (negsuc 1)
  in if not ok && not originalCube
       then afterCheck , false
       else
         let poly3 =
               if containsNat faceIndex (pendingFaces poly2)
                 then record poly2 {
                        pendingFaces =
                          removeNat faceIndex (pendingFaces poly2) ;
                        cleanFaces =
                          faceIndex ∷ removeNat faceIndex (cleanFaces poly2)
                      }
                 else poly2
         in find-Dirichlet-domain (setPoly afterCheck poly3)

-- --------------------------------------------------------------------------
-- Face numbering and cusp slicing
-- --------------------------------------------------------------------------

numberFace :
  Pair WeeksState Nat →
  Nat →
  Pair WeeksState Nat
numberFace stateAndCount faceIndex =
  let state = first stateAndCount
      count = second stateAndCount
      poly = weeksPolyhedron state
  in case faceAt poly faceIndex of λ where
       nothing → stateAndCount
       (just face) →
         if not (intLess (faceFillTone face) (pos 0))
           then stateAndCount
           else
             let tone = natToInt count
                 poly1 =
                   setFace faceIndex (record face { faceFillTone = tone }) poly
                 poly2 =
                   case faceInverse face of λ where
                     nothing → poly1
                     (just inverseIndex) →
                       case faceAt poly1 inverseIndex of λ where
                         nothing → poly1
                         (just inverseFace) →
                           setFace inverseIndex
                             (record inverseFace { faceFillTone = tone })
                             poly1
             in setPoly state poly2 , suc count

number-faces : WeeksState → WeeksState
number-faces state =
  first
    (foldl numberFace
      (state , 0)
      (faceListOrder (weeksPolyhedron state)))

sliceVertex : WeeksState → Nat → WeeksState
sliceVertex state vertexIndex with vertexAt (weeksPolyhedron state) vertexIndex
... | nothing = state
... | just vertex =
  let ideal =
        not
          (floatLess
            (DHPt3Dot
              (vertexCoordinates vertex)
              (vertexCoordinates vertex)
              (weeksMetric state))
            (negf 0.00005))
      poly0 =
        setVertex vertexIndex
          (record vertex { vertexIdeal = ideal })
          (weeksPolyhedron state)
      updated = setPoly state poly0
  in if not ideal
       then updated
       else
         let point = vertexCoordinates vertex
             scaled =
               makePoint4
                 (pointEntry point 0 *f MAGIC-SCALE)
                 (pointEntry point 1 *f MAGIC-SCALE)
                 (pointEntry point 2 *f MAGIC-SCALE)
                 (pointEntry point 3)
             translation = hyperbolicTranslateOrigin scaled
             transposed = transformTranspose translation
         in first (add-element updated transposed)

slice-off-cusps : WeeksState → WeeksState
slice-off-cusps state =
  foldl
    sliceVertex
    state
    (vertexListOrder (weeksPolyhedron state))

-- --------------------------------------------------------------------------
-- Diagnostics active in the historical build
-- --------------------------------------------------------------------------

print-vef : WeeksState → Unit
print-vef state =
  let poly = weeksPolyhedron state
      v = numberOfVertices poly
      e = numberOfEdges poly
      f = numberOfFaces poly
  in if natEq (weeksDebug state) 0
       then tt
       else standardError
              (stringAppend
                (showNat v)
                (stringAppend " vertices, "
                  (stringAppend (showNat e)
                    (stringAppend " edges, " (showNat f)))))

print-vertices : WeeksState → Unit
print-vertices state =
  if natEq (weeksDebug state) 0
    then tt
    else standardError "Vertices"

print-poly : WeeksState → Unit
print-poly state =
  let a = print-vef state
      b = print-vertices state
  in tt

-- --------------------------------------------------------------------------
-- Top-level direct translation
-- --------------------------------------------------------------------------

do-weeks-code :
  Point4 →
  List ProjMatrix →
  Nat →
  Bool →
  Maybe WEPolyhedron
do-weeks-code origin generators metric slice =
  let start = make-cube (initialWeeksState origin metric)
      initialized = initialize-polyhedron start generators
      found = find-Dirichlet-domain initialized
  in if not (second found)
       then nothing
       else
         let numbered = number-faces (first found)
             final =
               if slice && natEq metric DG-HYPERBOLIC
                 then slice-off-cusps numbered
                 else numbered
         in just (weeksPolyhedron final)
