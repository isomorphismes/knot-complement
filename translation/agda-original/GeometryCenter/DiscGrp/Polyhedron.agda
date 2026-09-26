module GeometryCenter.DiscGrp.Polyhedron where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Colormap
open import GeometryCenter.DiscGrp.DHPoint3

record VectSegment : Set where
  constructor vectSegment
  field
    segmentStart segmentEnd : Point4
    segmentColor : ColorA
open VectSegment public

record PolyFaceData : Set where
  constructor polyFaceData
  field
    polygonIndices : List Nat
    polygonColor : ColorA
open PolyFaceData public

record BeamQuad : Set where
  constructor beamQuad
  field
    beamPoints : List Point4
    beamColor : ColorA
open BeamQuad public

postulate
  buildVectGeom : List VectSegment → Geom
  buildPolyListGeom : List Point4 → List PolyFaceData → Geom
  buildBeamGeom : List BeamQuad → Geom

sameMaybeNat : Maybe Nat → Maybe Nat → Bool
sameMaybeNat nothing nothing = true
sameMaybeNat (just a) (just b) = natEq a b
sameMaybeNat left right = false

faceAt : WEPolyhedron → Nat → Maybe WEFace
faceAt poly index = lookup (faces poly) index

edgeAt : WEPolyhedron → Nat → Maybe WEEdge
edgeAt poly index = lookup (edges poly) index

vertexAt : WEPolyhedron → Nat → Maybe WEVertex
vertexAt poly index = lookup (vertices poly) index

setEdge : Nat → WEEdge → WEPolyhedron → WEPolyhedron
setEdge index edge poly =
  record poly { edges = replaceAt index edge (edges poly) }

faceColor :
  ColorMapState →
  WEFace →
  Pair ColorMapState ColorA
faceColor colors face =
  case intToNat (faceFillTone face) of λ where
    nothing → GetCmapEntry 0 colors
    (just tone) → GetCmapEntry tone colors

WEPolyhedronToVectSegments :
  ColorMapState →
  WEPolyhedron →
  Point4 →
  Pair ColorMapState (List VectSegment)
WEPolyhedronToVectSegments colors poly origin =
  go colors (faceListOrder poly)
  where
    go :
      ColorMapState →
      List Nat →
      Pair ColorMapState (List VectSegment)
    go current [] = current , []
    go current (faceIndex ∷ rest) with faceAt poly faceIndex
    ... | nothing = go current rest
    ... | just face =
      let colored = faceColor current face
          transform = transformTranspose (faceGroupElement face)
          groupOrigin = transformPoint transform origin
          later = go (first colored) rest
      in first later ,
         vectSegment origin groupOrigin (second colored) ∷ second later

WEPolyhedronToVect :
  ColorMapState →
  WEPolyhedron →
  Point4 →
  Pair ColorMapState Geom
WEPolyhedronToVect colors poly origin =
  let result = WEPolyhedronToVectSegments colors poly origin
  in first result , buildVectGeom (second result)

record VertexMap : Set where
  constructor vertexMap
  field
    sourceVertex : Nat
    outputVertex : Nat
open VertexMap public

buildVertexMap :
  WEPolyhedron →
  List Nat →
  Nat →
  Pair (List VertexMap) (List Point4)
buildVertexMap poly [] outputIndex = [] , []
buildVertexMap poly (vertexIndex ∷ rest) outputIndex with vertexAt poly vertexIndex
... | nothing = buildVertexMap poly rest outputIndex
... | just vertex =
  if not (vertexAlive vertex)
    then buildVertexMap poly rest outputIndex
    else
      let later = buildVertexMap poly rest (suc outputIndex)
      in vertexMap vertexIndex outputIndex ∷ first later ,
         vertexCoordinates vertex ∷ second later

mappedVertex : List VertexMap → Nat → Nat
mappedVertex [] source = 0
mappedVertex (entry ∷ rest) source =
  if natEq source (sourceVertex entry)
    then outputVertex entry
    else mappedVertex rest source

nextCounterclockwise : WEEdge → Nat → Maybe Nat
nextCounterclockwise edge faceIndex =
  if sameMaybeNat (edgeLeftFace edge) (just faceIndex)
    then edgeFrontLeft edge
    else edgeBackRight edge

directedStart : WEEdge → Nat → Nat
directedStart edge faceIndex =
  if sameMaybeNat (edgeLeftFace edge) (just faceIndex)
    then edgeTail edge
    else edgeTip edge

faceBoundary :
  WEPolyhedron →
  Nat →
  Nat →
  Nat →
  List Nat
faceBoundary poly faceIndex 0 edgeIndex = []
faceBoundary poly faceIndex (suc fuel) edgeIndex with edgeAt poly edgeIndex
... | nothing = []
... | just edge =
  directedStart edge faceIndex ∷
  case nextCounterclockwise edge faceIndex of λ where
    nothing → []
    (just next) → faceBoundary poly faceIndex fuel next

faceOutputIndices :
  WEPolyhedron →
  List VertexMap →
  Nat →
  List Nat
faceOutputIndices poly mapping faceIndex with faceAt poly faceIndex
... | nothing = []
... | just face =
  case faceSomeEdge face of λ where
    nothing → []
    (just firstEdge) →
      map
        (mappedVertex mapping)
        (faceBoundary poly faceIndex (faceOrder face) firstEdge)

buildPolyFaces :
  ColorMapState →
  WEPolyhedron →
  List VertexMap →
  List Nat →
  Pair ColorMapState (List PolyFaceData)
buildPolyFaces colors poly mapping [] = colors , []
buildPolyFaces colors poly mapping (faceIndex ∷ rest) with faceAt poly faceIndex
... | nothing = buildPolyFaces colors poly mapping rest
... | just face =
  let colored = faceColor colors face
      later = buildPolyFaces (first colored) poly mapping rest
  in first later ,
     polyFaceData
       (faceOutputIndices poly mapping faceIndex)
       (second colored) ∷ second later

WEPolyhedronToPolyList :
  ColorMapState →
  WEPolyhedron →
  Pair ColorMapState Geom
WEPolyhedronToPolyList colors poly =
  let verticesBuilt = buildVertexMap poly (vertexListOrder poly) 0
      mapping = first verticesBuilt
      points = second verticesBuilt
      facesBuilt =
        buildPolyFaces colors poly mapping (faceListOrder poly)
  in first facesBuilt ,
     buildPolyListGeom points (second facesBuilt)

scalePoint : Float → Point4 → Point4
scalePoint scale point =
  map (λ value → scale *f value) point

addPoint : Point4 → Point4 → Point4
addPoint = zipWith _+f_

-- The following deliberately preserves a source oddity in polyhedron.c.
-- Expressions such as
--
--   if ((eptr->e0L->v0 = eptr->v0)) ...
--
-- are assignments, not comparisons.  The assigned vertex pointer is non-null,
-- so the true branch is always selected and the neighboring edge's v0 is
-- mutated.  The translation does the same mutation explicitly.

assignNeighborTail :
  WEPolyhedron →
  Maybe Nat →
  Nat →
  Pair WEPolyhedron (Maybe Nat)
assignNeighborTail poly nothing vertexIndex = poly , nothing
assignNeighborTail poly (just neighborIndex) vertexIndex with edgeAt poly neighborIndex
... | nothing = poly , nothing
... | just neighbor =
  let changed = record neighbor { edgeTail = vertexIndex }
      poly1 = setEdge neighborIndex changed poly
  in poly1 , just (edgeTip changed)

pointForVertex : WEPolyhedron → Maybe Nat → Point4
pointForVertex poly nothing = zero4
pointForVertex poly (just vertexIndex) with vertexAt poly vertexIndex
... | nothing = zero4
... | just vertex = vertexCoordinates vertex

sameFaceRef : Maybe Nat → Maybe Nat → Bool
sameFaceRef = sameMaybeNat

beamForEdge :
  Float →
  Pair WEPolyhedron (List BeamQuad) →
  Nat →
  Pair WEPolyhedron (List BeamQuad)
beamForEdge alpha stateAndQuads edgeIndex =
  let poly0 = first stateAndQuads
      quads = second stateAndQuads
      omega = 1.0 -f alpha
  in case edgeAt poly0 edgeIndex of λ where
       nothing → stateAndQuads
       (just edge) →
         let v0index = edgeTail edge
             v0 = pointForVertex poly0 (just v0index)

             firstNeighbor =
               assignNeighborTail poly0 (edgeBackLeft edge) v0index
             poly1 = first firstNeighbor
             firstOther = pointForVertex poly1 (second firstNeighbor)
             p0a = scalePoint omega v0
             p1a = scalePoint alpha firstOther
             q0 = addPoint p0a p1a

             chosenBack =
               case edgeBackRight edge of λ where
                 nothing → edgeBackLeft edge
                 (just backRightIndex) →
                   case edgeAt poly1 backRightIndex of λ where
                     nothing → edgeBackLeft edge
                     (just backRight) →
                       if sameFaceRef
                            (edgeRightFace edge)
                            (edgeRightFace backRight)
                         then edgeBackRight edge
                         else edgeBackLeft edge

             secondNeighbor =
               assignNeighborTail poly1 chosenBack v0index
             poly2 = first secondNeighbor
             secondOther = pointForVertex poly2 (second secondNeighbor)
             p1b = scalePoint alpha secondOther
             q1 = addPoint p0a p1b

             v1index = edgeTip edge
             v1 = pointForVertex poly2 (just v1index)

             thirdNeighbor =
               assignNeighborTail poly2 (edgeFrontRight edge) v1index
             poly3 = first thirdNeighbor
             thirdOther = pointForVertex poly3 (second thirdNeighbor)
             p0c = scalePoint omega v1
             p1c = scalePoint alpha thirdOther
             q2 = addPoint p0c p1c

             fourthNeighbor =
               assignNeighborTail poly3 (edgeFrontLeft edge) v1index
             poly4 = first fourthNeighbor
             fourthOther = pointForVertex poly4 (second fourthNeighbor)
             p1d = scalePoint alpha fourthOther
             q3 = addPoint p0c p1d

             quad =
               beamQuad
                 (q0 ∷ q1 ∷ q2 ∷ q3 ∷ [])
                 (rgba 1.0 1.0 1.0 1.0)
         in poly4 , quads ++ (quad ∷ [])

WEPolyhedronToBeams :
  WEPolyhedron →
  Float →
  Pair WEPolyhedron Geom
WEPolyhedronToBeams poly alpha =
  let built =
        foldl (beamForEdge alpha)
          (poly , [])
          (edgeListOrder poly)
  in first built , buildBeamGeom (second built)
