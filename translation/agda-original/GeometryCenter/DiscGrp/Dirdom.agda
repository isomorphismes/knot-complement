module GeometryCenter.DiscGrp.Dirdom where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags
open import GeometryCenter.DiscGrp.Colormap
open import GeometryCenter.DiscGrp.DHPoint3
open import GeometryCenter.DiscGrp.Projective
open import GeometryCenter.DiscGrp.WeeksDirdom
open import GeometryCenter.DiscGrp.Polyhedron

DGorigin : Point4
DGorigin = origin4

DGrandom : Point4
DGrandom = makePoint4 0.1 0.2 0.3 0.4

matrixIsIdentity : Transform → Bool
matrixIsIdentity transform =
  all
    (λ pair →
      let i = first pair
          j = second pair
          expected = if natEq i j then 1.0 else 0.0
      in not
           (floatLess
             0.0005
             (absf (matrixEntry transform i j -f expected))))
    ((0 , 0) ∷ (0 , 1) ∷ (0 , 2) ∷ (0 , 3) ∷
     (1 , 0) ∷ (1 , 1) ∷ (1 , 2) ∷ (1 , 3) ∷
     (2 , 0) ∷ (2 , 1) ∷ (2 , 2) ∷ (2 , 3) ∷
     (3 , 0) ∷ (3 , 1) ∷ (3 , 2) ∷ (3 , 3) ∷ [])

dehomogenize : Point4 → Point4
dehomogenize point =
  let weight = pointEntry point 3
  in if floatEq weight 0.0 || floatEq weight 1.0
       then point
       else makePoint4
              (pointEntry point 0 /f weight)
              (pointEntry point 1 /f weight)
              (pointEntry point 2 /f weight)
              1.0

pointAdd4 : Point4 → Point4 → Point4
pointAdd4 = zipWith _+f_

fixedByGenerator : DiscGrp → DiscGrpEl → Bool
fixedByGenerator dg generator =
  let transformed =
        transformPoint (elementTransform generator) (groupCenter dg)
      distance =
        spaceDistance
          (groupCenter dg)
          transformed
          (bitAnd (groupAttributes dg) DG-METRIC-BITS)
  in floatLess (absf distance) 0.0005

clearTmp : DiscGrpEl → DiscGrpEl
clearTmp element =
  record element {
    elementAttributes =
      bitAnd (elementAttributes element) (bitNot DG-TMP)
  }

sumOneFromEachInversePair :
  List DiscGrpEl →
  Nat →
  List Nat →
  Point4 →
  Point4
sumOneFromEachInversePair generators index seen total
  with lookup generators index
... | nothing = total
... | just generator =
  if containsNat index seen
    then
      sumOneFromEachInversePair generators (suc index) seen total
    else
      let image =
            transformPoint (elementTransform generator) DGrandom
          nextSeen =
            case inverseIndex generator of λ where
              nothing → index ∷ seen
              (just inverse) → inverse ∷ index ∷ seen
      in sumOneFromEachInversePair
           generators
           (suc index)
           nextSeen
           (pointAdd4 total image)

DiscGrpCheckCPoint : DiscGrp → DiscGrp
DiscGrpCheckCPoint dg =
  case groupGenerators dg of λ where
    nothing → dg
    (just generatorList) →
      let generators = elements generatorList
      in if not (any (fixedByGenerator dg) generators)
           then dg
           else
             let cleared = map clearTmp generators
                 total =
                   sumOneFromEachInversePair cleared 0 [] zero4
                 center = dehomogenize total
             in record dg {
                  groupCenter = center ;
                  groupGenerators =
                    just
                      (record generatorList { elements = cleared })
                }

toggleWordCase : String → String
toggleWordCase word with stringToChars word
... | [] = word
... | firstChar ∷ rest =
  charsToString (upperLowerMate firstChar ∷ rest)

setInverseIndex : Nat → DiscGrpEl → DiscGrpEl
setInverseIndex index element =
  record element { inverseIndex = just index }

findExistingInverse :
  List DiscGrpEl →
  Nat →
  DiscGrpEl →
  Maybe Nat
findExistingInverse generators start generator =
  findFrom start
  where
    findFrom : Nat → Maybe Nat
    findFrom index with lookup generators index
    ... | nothing = nothing
    ... | just candidate =
      if matrixIsIdentity
           (transformConcat
             (elementTransform generator)
             (elementTransform candidate))
        then just index
        else findFrom (suc index)

pairExistingInverses :
  List DiscGrpEl →
  Nat →
  List DiscGrpEl
pairExistingInverses generators index with lookup generators index
... | nothing = generators
... | just generator =
  case inverseIndex generator of λ where
    (just inverse) →
      pairExistingInverses generators (suc index)
    nothing →
      case findExistingInverse generators index generator of λ where
        nothing →
          pairExistingInverses generators (suc index)
        (just partner) →
          case lookup generators partner of λ where
            nothing →
              pairExistingInverses generators (suc index)
            (just partnerElement) →
              let withFirst =
                    replaceAt index
                      (setInverseIndex partner generator)
                      generators
                  withBoth =
                    replaceAt partner
                      (setInverseIndex index partnerElement)
                      withFirst
              in pairExistingInverses withBoth (suc index)

appendMissingInverses :
  Nat →
  List DiscGrpEl →
  Nat →
  List DiscGrpEl
appendMissingInverses originalCount generators index =
  if natEq index originalCount
    then generators
    else
      case lookup generators index of λ where
        nothing → generators
        (just generator) →
          case inverseIndex generator of λ where
            (just inverse) →
              appendMissingInverses originalCount generators (suc index)
            nothing →
              case transformInverse (elementTransform generator) of λ where
                nothing →
                  appendMissingInverses originalCount generators (suc index)
                (just inverseTransform) →
                  let inverseIndexValue = length generators
                      inverseElement =
                        discGrpEl
                          (elementAttributes generator)
                          (toggleWordCase (elementWord generator))
                          inverseTransform
                          (elementColor generator)
                          (just index)
                      withOriginal =
                        replaceAt index
                          (setInverseIndex inverseIndexValue generator)
                          generators
                      withNew = withOriginal ++ (inverseElement ∷ [])
                  in appendMissingInverses
                       originalCount
                       withNew
                       (suc index)

DiscGrpAddInverses : DiscGrp → DiscGrp
DiscGrpAddInverses dg =
  case groupGenerators dg of λ where
    nothing → dg
    (just generatorList) →
      let withoutIdentities =
            filter
              (λ generator →
                 not (matrixIsIdentity (elementTransform generator)))
              (elements generatorList)
          paired = pairExistingInverses withoutIdentities 0
          completed =
            appendMissingInverses (length paired) paired 0
      in record dg {
           groupGenerators =
             just (record generatorList { elements = completed })
         }

record DirdomState : Set where
  constructor dirdomState
  field
    colorState : ColorMapState
    -- DiscGrpScalePolyList used a static Euclidean accumulator.
    scaleAverage : Point4
open DirdomState public

initialDirdomState : DirdomState
initialDirdomState = dirdomState initialColorMap zero4

faceToneColor :
  ColorMapState →
  WEFace →
  Pair ColorMapState ColorA
faceToneColor colors face =
  case intToNat (faceFillTone face) of λ where
    nothing → GetCmapEntry 0 colors
    (just tone) → GetCmapEntry tone colors

extractFaces :
  ColorMapState →
  List WEFace →
  Nat →
  Pair ColorMapState (List DiscGrpEl)
extractFaces colors [] index = colors , []
extractFaces colors (face ∷ rest) index =
  if not (faceAlive face)
    then extractFaces colors rest index
    else
      let colored = faceToneColor colors face
          element =
            discGrpEl
              0
              ""
              (transformTranspose (faceGroupElement face))
              (second colored)
              nothing
          later = extractFaces (first colored) rest (suc index)
      in first later , element ∷ second later

DiscGrpExtractNhbrs :
  ColorMapState →
  WEPolyhedron →
  Pair ColorMapState DiscGrpElList
DiscGrpExtractNhbrs colors poly =
  let identity =
        discGrpEl
          DGEL-IS-IDENTITY
          ""
          transformIdentity
          (rgba 1.0 1.0 1.0 1.0)
          nothing
      extracted = extractFaces colors (faces poly) 1
  in first extracted ,
     discGrpElList
       (matrixGroup DG-GENERAL 4 0)
       (identity ∷ second extracted)

generatorProjectiveMatrices : DiscGrp → List ProjMatrix
generatorProjectiveMatrices dg =
  case groupGenerators dg of λ where
    nothing → []
    (just generators) →
      map convert (elements generators)
  where
    convert : DiscGrpEl → ProjMatrix
    convert element =
      if hasBit (groupAttributes dg) DG-TRANSPOSED
        then elementTransform element
        else transformTranspose (elementTransform element)

DiscGrpMakeDirdom :
  DiscGrp →
  Bool →
  Maybe WEPolyhedron
DiscGrpMakeDirdom dg slice =
  do-weeks-code
    (groupCenter dg)
    (generatorProjectiveMatrices dg)
    (bitAnd (groupAttributes dg) DG-METRIC-BITS)
    slice

DiscGrpSetupDirdom :
  DirdomState →
  DiscGrp →
  Pair DirdomState DiscGrp
DiscGrpSetupDirdom state dg =
  let checked = DiscGrpCheckCPoint dg
  in case DiscGrpMakeDirdom checked false of λ where
       nothing → state , checked
       (just poly) →
         let extracted =
               DiscGrpExtractNhbrs (colorState state) poly
             nextState =
               record state { colorState = first extracted }
         in nextState ,
            record checked { groupNeighbors = just (second extracted) }

nearestNeighbor :
  DiscGrp →
  Point4 →
  DiscGrpElList →
  Pair Nat DiscGrpEl
nearestNeighbor dg point neighbors =
  choose 0 nothing (elements neighbors)
  where
    choose :
      Nat →
      Maybe (Pair Float DiscGrpEl) →
      List DiscGrpEl →
      Pair Nat DiscGrpEl
    choose index nothing [] =
      0 ,
      discGrpEl DGEL-IS-IDENTITY "" transformIdentity
        (rgba 1.0 1.0 1.0 1.0) nothing
    choose index (just best) [] =
      0 , second best
    choose index best (candidate ∷ rest) =
      let image =
            transformPoint
              (elementTransform candidate)
              (groupCenter dg)
          distance =
            spaceDistance
              point
              image
              (bitAnd (groupAttributes dg) DG-METRIC-BITS)
          nextBest =
            case best of λ where
              nothing → just (distance , candidate)
              (just old) →
                if floatLess distance (first old)
                  then just (distance , candidate)
                  else best
          later = choose (suc index) nextBest rest
      in case nextBest of λ where
           nothing → later
           (just selected) →
             -- Recover the selected index by a second scan below.
             selectedIndex (elements neighbors) (second selected) 0 ,
             second selected

    selectedIndex : List DiscGrpEl → DiscGrpEl → Nat → Nat
    selectedIndex [] target index = 0
    selectedIndex (candidate ∷ rest) target index =
      if matrixIsIdentity
           (transformConcat
             (elementTransform candidate)
             (case transformInverse (elementTransform target) of λ where
               nothing → transformIdentity
               (just inv) → inv))
        then index
        else selectedIndex rest target (suc index)

record ClosestResult : Set where
  constructor closestResult
  field
    closestState : DirdomState
    closestGroup : DiscGrp
    closestElement : DiscGrpEl
open ClosestResult public

DiscGrpClosestGroupEl :
  DirdomState →
  DiscGrp →
  Point4 →
  ClosestResult
DiscGrpClosestGroupEl state dg point =
  let prepared =
        case groupNeighbors dg of λ where
          nothing → DiscGrpSetupDirdom state dg
          (just neighbors) → state , dg
  in search 1000
       (first prepared)
       (second prepared)
       point
       transformIdentity
  where
    search :
      Nat →
      DirdomState →
      DiscGrp →
      Point4 →
      Transform →
      ClosestResult
    search 0 currentState currentGroup currentPoint accumulated =
      closestResult currentState currentGroup
        (discGrpEl 0 "" accumulated
          (rgba 1.0 1.0 1.0 1.0)
          nothing)
    search (suc fuel) currentState currentGroup currentPoint accumulated =
      case groupNeighbors currentGroup of λ where
        nothing →
          closestResult currentState currentGroup
            (discGrpEl 0 "" accumulated
              (rgba 1.0 1.0 1.0 1.0)
              nothing)
        (just neighbors) →
          let nearest = nearestNeighbor currentGroup currentPoint neighbors
              nearestIndex = first nearest
              nearestElement = second nearest
          in if natEq nearestIndex 0
               then
                 closestResult currentState currentGroup
                   (discGrpEl
                     (if matrixIsIdentity accumulated
                        then DGEL-IS-IDENTITY else 0)
                     ""
                     accumulated
                     (elementColor nearestElement)
                     nothing)
               else
                 let nextAccumulated =
                       transformConcat
                         (elementTransform nearestElement)
                         accumulated
                 in case transformInverse nextAccumulated of λ where
                      nothing →
                        closestResult currentState currentGroup
                          (discGrpEl 0 "" accumulated
                            (elementColor nearestElement)
                            nothing)
                      (just inverse) →
                        search fuel
                          currentState
                          currentGroup
                          (transformPoint inverse point)
                          nextAccumulated

normalizeForMetric : Point4 → Nat → Point4
normalizeForMetric point metric = spaceNormalize point metric

scaleNonEuclideanVertex :
  Nat → Point4 → Float → WEVertex → WEVertex
scaleNonEuclideanVertex metric center scale vertex =
  if not (vertexAlive vertex)
    then vertex
    else
      let centerN = normalizeForMetric center metric
          pointN = normalizeForMetric (vertexCoordinates vertex) metric
          centerPart =
            map (λ value → (1.0 -f scale) *f value) centerN
          pointPart =
            map (λ value → scale *f value) pointN
      in record vertex {
           vertexCoordinates = zipWith _+f_ pointPart centerPart
         }

sumActiveVertices : WEPolyhedron → Point4 → Point4
sumActiveVertices poly initial =
  foldl
    (λ total vertex →
       if vertexAlive vertex
         then zipWith _+f_ total (vertexCoordinates vertex)
         else total)
    initial
    (vertices poly)

dehomogenizedAverage : Point4 → Point4
dehomogenizedAverage = dehomogenize

scaleEuclideanVertex :
  Point4 → Float → WEVertex → WEVertex
scaleEuclideanVertex average scale vertex =
  if not (vertexAlive vertex)
    then vertex
    else
      let point = vertexCoordinates vertex
          moved =
            makePoint4
              (pointEntry average 0 +f
               scale *f (pointEntry point 0 -f pointEntry average 0))
              (pointEntry average 1 +f
               scale *f (pointEntry point 1 -f pointEntry average 1))
              (pointEntry average 2 +f
               scale *f (pointEntry point 2 -f pointEntry average 2))
              (pointEntry point 3)
      in record vertex { vertexCoordinates = moved }

DiscGrpScalePolyhedron :
  DirdomState →
  DiscGrp →
  WEPolyhedron →
  Point4 →
  Float →
  Pair DirdomState WEPolyhedron
DiscGrpScalePolyhedron state dg poly center scale =
  let metric = bitAnd (groupAttributes dg) DG-METRIC-BITS
  in if not (natEq metric DG-EUCLIDEAN)
       then
         state ,
         record poly {
           vertices =
             map (scaleNonEuclideanVertex metric center scale)
                 (vertices poly)
         }
       else
         -- The C source's average is static and is not reset between calls.
         let accumulated =
               sumActiveVertices poly (scaleAverage state)
             average = dehomogenizedAverage accumulated
             nextState = record state { scaleAverage = accumulated }
         in nextState ,
            record poly {
              vertices =
                map (scaleEuclideanVertex average scale) (vertices poly)
            }

record DirDomResult : Set where
  constructor dirDomResult
  field
    dirDomState : DirdomState
    dirDomGroup : DiscGrp
    dirDomGeometry : Maybe Geom
open DirDomResult public

DiscGrpDirDom : DirdomState → DiscGrp → DirDomResult
DiscGrpDirDom state dg =
  if hasBit (groupFlag dg) DG-DDBEAM
    then
      case DiscGrpMakeDirdom dg false of λ where
        nothing → dirDomResult state dg nothing
        (just poly) →
          let beams =
                WEPolyhedronToBeams poly (dirichletScale dg)
          in dirDomResult state dg (just (second beams))
    else
      case DiscGrpMakeDirdom dg false of λ where
        nothing → dirDomResult state dg nothing
        (just largePoly) →
          let largeScaled =
                DiscGrpScalePolyhedron state dg largePoly (groupCenter dg) 1.0
              largeBuilt =
                WEPolyhedronToPolyList
                  (colorState (first largeScaled))
                  (second largeScaled)
              afterLarge =
                record (first largeScaled) {
                  colorState = first largeBuilt
                }
              largeGeom = second largeBuilt
          in case DiscGrpMakeDirdom dg true of λ where
               nothing → dirDomResult afterLarge dg nothing
               (just smallPoly) →
                 let smallScaled =
                       DiscGrpScalePolyhedron
                         afterLarge
                         dg
                         smallPoly
                         (groupCenter dg)
                         (dirichletScale dg)
                     smallBuilt =
                       WEPolyhedronToPolyList
                         (colorState (first smallScaled))
                         (second smallScaled)
                     finalState =
                       record (first smallScaled) {
                         colorState = first smallBuilt
                       }
                     smallGeom = second smallBuilt
                     combined = combineGeomList largeGeom smallGeom
                 in dirDomResult
                      finalState
                      (record dg {
                        dirichletGeometry = just combined
                      })
                      (just combined)
