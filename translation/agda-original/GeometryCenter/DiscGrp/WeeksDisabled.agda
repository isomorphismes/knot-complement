module GeometryCenter.DiscGrp.WeeksDisabled where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags
open import GeometryCenter.DiscGrp.Complex
open import GeometryCenter.DiscGrp.Projective
open import GeometryCenter.DiscGrp.DHPoint3
open import GeometryCenter.DiscGrp.Polyhedron
open import GeometryCenter.DiscGrp.Colormap
open import GeometryCenter.DiscGrp.WeeksDirdom

-- Routines below were present in weeks_dirdom.c but compiled out with #if 0.
-- They are kept here so the source translation does not silently drop them.

convert-generators : List SL2CMatrix → List ProjMatrix
convert-generators = map sl2c-to-proj

record HyperEdgeInit : Set where
  constructor hyperEdgeInit
  field
    hv0 hv1 he0L he0R he1L he1R hfL hfR : Nat
open HyperEdgeInit public

hyperEdgeData : List HyperEdgeInit
hyperEdgeData =
  hyperEdgeInit 0 4 8 4 9 6 1 0 ∷
  hyperEdgeInit 2 6 4 16 6 11 0 8 ∷
  hyperEdgeInit 1 5 20 8 7 9 5 1 ∷
  hyperEdgeInit 3 11 10 5 22 17 7 6 ∷
  hyperEdgeInit 0 2 0 8 1 10 0 2 ∷
  hyperEdgeInit 1 3 8 20 10 3 2 6 ∷
  hyperEdgeInit 4 6 12 0 11 1 3 0 ∷
  hyperEdgeInit 5 13 2 9 14 21 5 4 ∷
  hyperEdgeInit 0 1 4 0 5 2 2 1 ∷
  hyperEdgeInit 4 5 0 12 2 7 1 4 ∷
  hyperEdgeInit 2 3 16 4 3 5 7 2 ∷
  hyperEdgeInit 6 14 6 1 18 13 3 8 ∷
  hyperEdgeInit 4 12 9 6 21 18 4 3 ∷
  hyperEdgeInit 10 14 16 22 11 23 8 10 ∷
  hyperEdgeInit 9 13 17 20 19 7 9 5 ∷
  hyperEdgeInit 11 15 22 17 23 19 10 9 ∷
  hyperEdgeInit 2 10 1 10 13 22 8 7 ∷
  hyperEdgeInit 9 11 20 14 3 15 6 9 ∷
  hyperEdgeInit 12 14 21 12 23 11 11 3 ∷
  hyperEdgeInit 13 15 14 21 15 23 9 11 ∷
  hyperEdgeInit 1 9 5 2 17 14 6 5 ∷
  hyperEdgeInit 12 13 12 18 7 19 4 11 ∷
  hyperEdgeInit 10 11 13 16 15 3 10 7 ∷
  hyperEdgeInit 14 15 18 13 19 15 11 10 ∷ []

hyperFaceData : List Nat
hyperFaceData =
  0 ∷ 8 ∷ 4 ∷ 6 ∷ 9 ∷ 2 ∷ 5 ∷ 10 ∷ 1 ∷ 15 ∷ 23 ∷ 19 ∷ []

signedOne : Bool → Float
signedOne true = 1.0
signedOne false = negf 1.0

makeHyperVertex : Nat → WEVertex
makeHyperVertex index =
  weVertex true
    (makePoint4
      (signedOne (not (natEq (bitAnd index 8) 0)))
      (signedOne (not (natEq (bitAnd index 4) 0)))
      (signedOne (not (natEq (bitAnd index 2) 0)))
      (signedOne (not (natEq (bitAnd index 1) 0))))
    0.0
    false

makeHyperEdge : HyperEdgeInit → WEEdge
makeHyperEdge datum =
  weEdge true
    (hv0 datum) (hv1 datum)
    (just (he0L datum)) (just (he0R datum))
    (just (he1L datum)) (just (he1R datum))
    (just (hfL datum)) (just (hfR datum))

makeHyperFace : Nat → Nat → WEFace
makeHyperFace index firstEdge =
  weFace true
    4
    (negsuc 1)
    (just firstEdge)
    identity4
    nothing
    (if natLess index 11 then just (suc index) else nothing)
    (if natEq index 0 then nothing else just (natPred index))
    (if natLess index 11 then just (suc index) else nothing)

hypercubeVertexOrder : List Nat
hypercubeVertexOrder =
  0 ∷ 1 ∷ 2 ∷ 3 ∷ 4 ∷ 5 ∷ 6 ∷
  9 ∷ 10 ∷ 11 ∷ 12 ∷ 13 ∷ 14 ∷ 15 ∷ []

make-hypercube : WEPolyhedron
make-hypercube =
  wePolyhedron
    (map makeHyperVertex (range 16))
    (map makeHyperEdge hyperEdgeData)
    (map
      (λ indexed → makeHyperFace (first indexed) (second indexed))
      (enumerate hyperFaceData))
    hypercubeVertexOrder
    (range 24)
    (range 12)
    (range 12)
    []
    []

read-vertices : WEPolyhedron → Nat → List (List Float)
read-vertices poly faceIndex =
  map
    (λ vertexIndex →
      case lookup (vertices poly) vertexIndex of λ where
        nothing → 0.0 ∷ 0.0 ∷ 0.0 ∷ []
        (just vertex) →
          pointEntry (vertexCoordinates vertex) 0 ∷
          pointEntry (vertexCoordinates vertex) 1 ∷
          pointEntry (vertexCoordinates vertex) 2 ∷ [])
    (faceVertexIndices poly faceIndex)

record VertexDistanceStats : Set where
  constructor vertexDistanceStats
  field
    normalizedPolyhedron : WEPolyhedron
    idealVertexPresent finiteVertexPresent : Bool
    closestW furthestW : Float
open VertexDistanceStats public

normalizeDiagnosticVertex :
  Nat →
  Pair (List WEVertex) (Pair Bool (Pair Bool (Pair Float Float))) →
  WEVertex →
  Pair (List WEVertex) (Pair Bool (Pair Bool (Pair Float Float)))
normalizeDiagnosticVertex metric state vertex =
  let accumulated = first state
      flags = second state
      idealPresent = first flags
      finiteRest = second flags
      finitePresent = first finiteRest
      bounds = second finiteRest
      minimum = first bounds
      maximum = second bounds
  in if not (vertexAlive vertex)
       then accumulated ++ (vertex ∷ []) , flags
       else
         let norm =
               sqrtf
                 (absf
                   (DHPt3Dot3
                     (vertexCoordinates vertex)
                     (vertexCoordinates vertex)
                     metric))
             ideal = floatLess norm (sqrtf (100000.0 *f hardwarePrecision))
         in if ideal
              then
                accumulated ++
                  (record vertex { vertexIdeal = true } ∷ []) ,
                (true , finitePresent , minimum , maximum)
              else
                let normalized =
                      if floatEq norm 0.0
                        then vertexCoordinates vertex
                        else map (λ value → value /f norm)
                                 (vertexCoordinates vertex)
                    wvalue = pointEntry normalized 3
                in accumulated ++
                     (record vertex {
                       vertexIdeal = false ;
                       vertexCoordinates = normalized
                     } ∷ []) ,
                   (idealPresent ,
                    true ,
                    minf minimum wvalue ,
                    maxf maximum wvalue)

print-vertex-distances :
  Nat →
  WEPolyhedron →
  VertexDistanceStats
print-vertex-distances metric poly =
  let start =
        [] ,
        (false , false , cosf 17.0 , 0.0)
      result =
        if natEq metric DG-HYPERBOLIC
          then foldl (normalizeDiagnosticVertex metric) start (vertices poly)
          else start
      flags = second result
      finiteRest = second flags
      bounds = second finiteRest
  in vertexDistanceStats
       (record poly { vertices = first result })
       (first flags)
       (first finiteRest)
       (first bounds)
       (second bounds)

record EdgeLengthStats : Set where
  constructor edgeLengthStats
  field
    finiteEdgePresent infiniteEdgePresent : Bool
    shortestDot longestDot : Float
open EdgeLengthStats public

print-edge-lengths : Nat → WEPolyhedron → EdgeLengthStats
print-edge-lengths metric poly =
  foldl inspect
    (edgeLengthStats false false (cosf 17.0) 1.0)
    (edgeListOrder poly)
  where
    inspect : EdgeLengthStats → Nat → EdgeLengthStats
    inspect state edgeIndex with lookup (edges poly) edgeIndex
    ... | nothing = state
    ... | just edge =
      case lookup (vertices poly) (edgeTail edge) of λ where
        nothing → state
        (just v0) →
          case lookup (vertices poly) (edgeTip edge) of λ where
            nothing → state
            (just v1) →
              if vertexIdeal v0 || vertexIdeal v1
                then record state { infiniteEdgePresent = true }
                else
                  let dot =
                        negf
                          (DHPt3Dot3
                            (vertexCoordinates v0)
                            (vertexCoordinates v1)
                            metric)
                  in edgeLengthStats
                       true
                       (infiniteEdgePresent state)
                       (minf (shortestDot state) dot)
                       (maxf (longestDot state) dot)

record FaceDistanceStats : Set where
  constructor faceDistanceStats
  field
    closestFaceW furthestFaceW : Float
open FaceDistanceStats public

print-face-distances : WEPolyhedron → FaceDistanceStats
print-face-distances poly =
  foldl inspect (faceDistanceStats 1.0e30 0.0) (faceListOrder poly)
  where
    inspect : FaceDistanceStats → Nat → FaceDistanceStats
    inspect state faceIndex with lookup (faces poly) faceIndex
    ... | nothing = state
    ... | just face =
      let value = matrixEntry (faceGroupElement face) 3 3
      in faceDistanceStats
           (minf (closestFaceW state) value)
           (maxf (furthestFaceW state) value)

print-statistics :
  Nat →
  WEPolyhedron →
  Pair VertexDistanceStats
    (Pair EdgeLengthStats FaceDistanceStats)
print-statistics metric poly =
  let vertexStats = print-vertex-distances metric poly
      normalized = normalizedPolyhedron vertexStats
      edgeStats = print-edge-lengths metric normalized
      faceStats = print-face-distances normalized
  in vertexStats , (edgeStats , faceStats)

saveOOGL : ColorMapState → WEPolyhedron → String → Bool
saveOOGL colors poly filename =
  let built = WEPolyhedronToPolyList colors poly
  in
  let ignored = geomSave (second built) filename
  in true

free-polyhedron : WEPolyhedron → WEPolyhedron
free-polyhedron poly =
  record poly {
    vertices = map (λ v → record v { vertexAlive = false }) (vertices poly) ;
    edges = map (λ e → record e { edgeAlive = false }) (edges poly) ;
    faces = map (λ f → record f { faceAlive = false }) (faces poly) ;
    vertexListOrder = [] ;
    edgeListOrder = [] ;
    faceListOrder = [] ;
    dirtyFaces = [] ;
    cleanFaces = [] ;
    pendingFaces = []
  }
