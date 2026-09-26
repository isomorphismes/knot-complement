module GeometryCenter.Maniview.State where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.DiscGrp.Flags
open import GeometryCenter.DiscGrp.Create

CHANGED NEW-SPACE NEW-AP SOFTSHADE DIRDOM : Nat
CHANGED = 1
NEW-SPACE = 2
NEW-AP = 4
SOFTSHADE = 8
DIRDOM = 16

LOAD-GROUP LOAD-GEOM LOAD-CAMGEOM CHECK-PIPE : Nat
LOAD-GROUP = 1
LOAD-GEOM = 2
LOAD-CAMGEOM = 4
CHECK-PIPE = 8

DIRDOM-MODE USER-GEOM : Nat
DIRDOM-MODE = 1
USER-GEOM = 2

record WindowFlags : Set where
  constructor windowFlags
  field
    displayWindow enumWindow loadWindow saveWindow : Bool
    dirichletWindow infoWindow helpWindow : Bool
open WindowFlags public

closedWindows : WindowFlags
closedWindows =
  windowFlags false false false false false false false

record ManiviewState : Set where
  constructor maniviewState
  field
    currentGroup : Maybe DiscGrp
    changedBits : Nat
    currentSpace : Nat
    metricIndex : Nat
    softwareShade : Bool
    currentLoadType : Nat
    loadTypeChanged : Bool
    currentTileMode : Nat
    currentScale : Float
    attenuation : List (List Float)
    backgroundBlend : Float
    radiusLimits : List Float
    drawRadiusLimits : List Float
    depthLimits : List Float
    mainPlacement : Nat
    displayPlacement : Nat
    loadPlacement : Nat
    savePlacement : Nat
    enumPlacement : Nat
    dirichletPlacement : Nat
    helpPlacement : Nat
    infoPlacement : Nat
    inputFile : Maybe IOBFile
    windows : WindowFlags
    quitting : Bool
open ManiviewState public

initialState : ManiviewState
initialState =
  maniviewState
    nothing
    0
    DG-EUCLIDEAN
    1
    true
    LOAD-GROUP
    true
    DIRDOM-MODE
    0.2
    ((0.5 ∷ 1.0 ∷ 0.0 ∷ 1.0 ∷ 0.0 ∷ 6.0 ∷ 0.0 ∷ []) ∷
     (0.5 ∷ 0.5 ∷ 0.0 ∷ 2.0 ∷ 0.0 ∷ 1.0 ∷ 0.0 ∷ []) ∷
     (0.5 ∷ 0.3 ∷ 0.0 ∷ 1.0 ∷ 0.0 ∷ 1.57 ∷ 0.0 ∷ []) ∷ [])
    0.0
    (6.0 ∷ 15.0 ∷ 4.0 ∷ [])
    (6.0 ∷ 15.0 ∷ 4.0 ∷ [])
    (6.0 ∷ 15.0 ∷ 4.0 ∷ [])
    0 0 0 0 0 0 0 0
    nothing
    closedWindows
    false

floatAt : List Float → Nat → Float
floatAt values index with lookup values index
... | nothing = 0.0
... | just value = value

rowFloat : List (List Float) → Nat → Nat → Float
rowFloat rows row column with lookup rows row
... | nothing = 0.0
... | just values = floatAt values column

replaceFloatAt : Nat → Float → List Float → List Float
replaceFloatAt = replaceAt

replaceNestedFloat :
  Nat → Nat → Float → List (List Float) → List (List Float)
replaceNestedFloat row column value rows with lookup rows row
... | nothing = rows
... | just values =
  replaceAt row (replaceAt column value values) rows

withGroup :
  ManiviewState →
  (DiscGrp → DiscGrp) →
  ManiviewState
withGroup state change with currentGroup state
... | nothing = state
... | just dg =
  record state { currentGroup = just (change dg) }

orChanged : ManiviewState → Nat → ManiviewState
orChanged state bits =
  record state { changedBits = bitOr (changedBits state) bits }

toggleBit : Nat → Bool → Nat → Nat
toggleBit bits true bit = bitOr bits bit
toggleBit bits false bit = bitAnd bits (bitNot bit)

index-from-bit : Nat → Nat
index-from-bit bit =
  if natEq bit 1 then 0
  else if natEq bit 2 then 1
  else if natEq bit 4 then 2
  else 1

record UiSnapshot : Set where
  constructor uiSnapshot
  field
    uiCenter : Point4
    uiEnumDepth : Nat
    uiEnumDistance uiDrawDistance uiScale : Float
    uiAttenuation1 uiAttenuation2 uiAttenuation3 : Float
    uiDrawDirdom uiDrawGeom uiCenterCamera uiShowCamera uiCullZ : Bool
    uiSaveGeom uiSaveGroup : Bool
    uiDirdomMode uiUserGeom : Bool
    uiLoadGroup uiLoadGeom uiLoadCameraGeom : Bool
    uiSoftshade : Bool
open UiSnapshot public

flagSet : Nat → Nat → Bool
flagSet flags bit = hasBit flags bit

fl-update-from-dg : ManiviewState → Maybe UiSnapshot
fl-update-from-dg state with currentGroup state
... | nothing = nothing
... | just dg =
  let flags = groupFlag dg
      index = metricIndex state
  in just
    (uiSnapshot
      (groupCenter dg)
      (enumerationDepth dg)
      (enumerationDistance dg)
      (drawingDistance dg)
      (currentScale state)
      (rowFloat (attenuation state) index 0)
      (rowFloat (attenuation state) index 1)
      (rowFloat (attenuation state) index 6)
      (flagSet flags DG-DRAWDIRDOM)
      (flagSet flags DG-DRAWGEOM)
      (flagSet flags DG-CENTERCAM)
      (flagSet flags DG-DRAWCAM)
      (flagSet flags DG-ZCULL)
      (flagSet flags DG-SAVEDIRDOM)
      (flagSet flags DG-SAVEBIGLIST)
      (hasBit (currentTileMode state) DIRDOM-MODE)
      (hasBit (currentTileMode state) USER-GEOM)
      (hasBit (currentLoadType state) LOAD-GROUP)
      (hasBit (currentLoadType state) LOAD-GEOM)
      (hasBit (currentLoadType state) LOAD-CAMGEOM)
      (softwareShade state))

record UiBounds : Set where
  constructor uiBounds
  field
    attenuation1Min attenuation1Max : Float
    attenuation2Min attenuation2Max : Float
    attenuation3Min attenuation3Max : Float
    radiusMin radiusMax : Float
    drawRadiusMin drawRadiusMax : Float
    wordDepthMin wordDepthMax : Float
    centerMin centerMax : Float
open UiBounds public

fl-set-bounds : ManiviewState → UiBounds
fl-set-bounds state =
  let i = metricIndex state
  in uiBounds
       (rowFloat (attenuation state) i 2)
       (rowFloat (attenuation state) i 3)
       (rowFloat (attenuation state) i 4)
       (rowFloat (attenuation state) i 5)
       0.0 1.0
       0.0 (floatAt (radiusLimits state) i)
       0.0 (floatAt (drawRadiusLimits state) i)
       0.0 (floatAt (depthLimits state) i)
       (negf 0.5) 0.5
