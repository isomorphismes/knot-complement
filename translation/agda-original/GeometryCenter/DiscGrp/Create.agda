module GeometryCenter.DiscGrp.Create where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags

white : ColorA
white = rgba 1.0 1.0 1.0 0.75

emptyElement : DiscGrpEl
emptyElement =
  discGrpEl 0 "" transformIdentity white nothing

defaultMatrixGroup : MatrixGroup
defaultMatrixGroup = matrixGroup DG-GENERAL 4 0

defaultElementList : DiscGrpElList
defaultElementList = discGrpElList defaultMatrixGroup []

defaultViewInfo : DGViewInfo
defaultViewInfo =
  dgViewInfo
    (origin4 ∷ origin4 ∷ origin4 ∷ origin4 ∷ [])
    transformIdentity transformIdentity
    transformIdentity transformIdentity
    transformIdentity transformIdentity

defaultDiscGrp : DiscGrp
defaultDiscGrp =
  discGrp
    nothing
    nothing
    DG-DDSLICE
    0
    3
    nothing
    nothing
    nothing
    nothing
    nothing
    origin4
    nothing
    nothing
    nothing
    nothing
    nothing
    nothing
    0.2
    2
    5.0
    5.0
    nothing
    defaultViewInfo

DiscGrpSetPreDraw : DiscGrp → Callback → DiscGrp
DiscGrpSetPreDraw dg predraw =
  record dg { predrawCallback = just predraw }

data ElementListOption : Set where
  elementCount : Nat → ElementListOption
  packedElements : List DiscGrpEl → ElementListOption
  transforms : List Transform → ElementListOption
  colors : List ColorA → ElementListOption
  constantAttributes : Nat → ElementListOption
  attributeList : List Nat → ElementListOption
  words : List String → ElementListOption

setElementTransform : DiscGrpEl → Transform → DiscGrpEl
setElementTransform element transform =
  record element { elementTransform = transform }

setElementColor : DiscGrpEl → ColorA → DiscGrpEl
setElementColor element color =
  record element { elementColor = color }

setElementAttributes : DiscGrpEl → Nat → DiscGrpEl
setElementAttributes element attributes =
  record element { elementAttributes = attributes }

setElementWord : DiscGrpEl → String → DiscGrpEl
setElementWord element word =
  record element { elementWord = word }

zipReplace :
  {A B : Set} →
  (A → B → A) →
  List A →
  List B →
  List A
zipReplace change [] values = []
zipReplace change current [] = current
zipReplace change (x ∷ xs) (value ∷ values) =
  change x value ∷ zipReplace change xs values

applyElementListOption :
  DiscGrpElList →
  ElementListOption →
  DiscGrpElList
applyElementListOption current (elementCount count) =
  record current { elements = replicate count emptyElement }
applyElementListOption current (packedElements supplied) =
  record current { elements = supplied }
applyElementListOption current (transforms supplied) =
  record current {
    elements = zipReplace setElementTransform (elements current) supplied
  }
applyElementListOption current (colors supplied) =
  record current {
    elements = zipReplace setElementColor (elements current) supplied
  }
applyElementListOption current (constantAttributes attributes) =
  record current {
    elements = map (λ element → setElementAttributes element attributes)
                   (elements current)
  }
applyElementListOption current (attributeList supplied) =
  record current {
    elements = zipReplace setElementAttributes (elements current) supplied
  }
applyElementListOption current (words supplied) =
  record current {
    elements = zipReplace setElementWord (elements current) supplied
  }

DiscGrpElListCreate :
  Maybe DiscGrpElList →
  List ElementListOption →
  DiscGrpElList
DiscGrpElListCreate nothing options =
  foldl applyElementListOption defaultElementList options
DiscGrpElListCreate (just existing) options =
  foldl applyElementListOption existing options

data DiscGrpGetResult : Set where
  gotName : Maybe String → DiscGrpGetResult
  gotComment : Maybe String → DiscGrpGetResult
  gotNat : Nat → DiscGrpGetResult
  gotFloat : Float → DiscGrpGetResult
  gotPoint : Point4 → DiscGrpGetResult
  gotElementList : Maybe DiscGrpElList → DiscGrpGetResult
  gotGeom : Maybe Geom → DiscGrpGetResult
  gotHandle : Maybe Handle → DiscGrpGetResult

data DiscGrpGetKey : Set where
  nameKey commentKey flagKey attributeKey generatorsKey bigListKey : DiscGrpGetKey
  centerKey enumDepthKey enumDistanceKey drawDistanceKey scaleKey : DiscGrpGetKey
  cameraGeomKey cameraHandleKey dirichletGeomKey dirichletHandleKey : DiscGrpGetKey
  geomKey geomHandleKey : DiscGrpGetKey

DiscGrpGet : DiscGrp → DiscGrpGetKey → DiscGrpGetResult
DiscGrpGet dg nameKey = gotName (groupName dg)
DiscGrpGet dg commentKey = gotComment (groupComment dg)
DiscGrpGet dg flagKey = gotNat (groupFlag dg)
DiscGrpGet dg attributeKey = gotNat (groupAttributes dg)
DiscGrpGet dg generatorsKey = gotElementList (groupGenerators dg)
DiscGrpGet dg bigListKey = gotElementList (groupElements dg)
DiscGrpGet dg centerKey = gotPoint (groupCenter dg)
DiscGrpGet dg enumDepthKey = gotNat (enumerationDepth dg)
DiscGrpGet dg enumDistanceKey = gotFloat (enumerationDistance dg)
DiscGrpGet dg drawDistanceKey = gotFloat (drawingDistance dg)
DiscGrpGet dg scaleKey = gotFloat (dirichletScale dg)
DiscGrpGet dg cameraGeomKey = gotGeom (cameraGeometry dg)
DiscGrpGet dg cameraHandleKey = gotHandle (cameraGeometryHandle dg)
DiscGrpGet dg dirichletGeomKey = gotGeom (dirichletGeometry dg)
DiscGrpGet dg dirichletHandleKey = gotHandle (dirichletGeometryHandle dg)
DiscGrpGet dg geomKey = gotGeom (fundamentalGeometry dg)
DiscGrpGet dg geomHandleKey = gotHandle (fundamentalGeometryHandle dg)

data CreateOption : Set where
  setName : Maybe String → CreateOption
  setComment : Maybe String → CreateOption
  setFlag : Nat → CreateOption
  setAttributes : Nat → CreateOption
  setGenerators : Maybe DiscGrpElList → CreateOption
  setBigList : Maybe DiscGrpElList → CreateOption
  setCenter : Point4 → CreateOption
  setEnumDepth : Nat → CreateOption
  setEnumDistance : Float → CreateOption
  setDrawDistance : Float → CreateOption
  setScale : Float → CreateOption
  setGeomHandle : Maybe Handle → CreateOption
  setHandleGeom : Maybe Handle → Maybe Geom → CreateOption
  setGeom : Maybe Geom → CreateOption
  setCameraGeomHandle : Maybe Handle → CreateOption
  setHandleCameraGeom : Maybe Handle → Maybe Geom → CreateOption
  setCameraGeom : Maybe Geom → CreateOption
  setDirichletGeomHandle : Maybe Handle → CreateOption
  setHandleDirichletGeom : Maybe Handle → Maybe Geom → CreateOption
  setDirichletGeom : Maybe Geom → CreateOption

applyCreateOption : DiscGrp → CreateOption → DiscGrp
applyCreateOption dg (setName value) = record dg { groupName = value }
applyCreateOption dg (setComment value) = record dg { groupComment = value }
applyCreateOption dg (setFlag value) = record dg { groupFlag = value }
applyCreateOption dg (setAttributes value) = record dg { groupAttributes = value }
applyCreateOption dg (setGenerators value) = record dg { groupGenerators = value }
applyCreateOption dg (setBigList value) = record dg { groupElements = value }
applyCreateOption dg (setCenter value) = record dg { groupCenter = value }
applyCreateOption dg (setEnumDepth value) = record dg { enumerationDepth = value }
applyCreateOption dg (setEnumDistance value) = record dg { enumerationDistance = value }
applyCreateOption dg (setDrawDistance value) = record dg { drawingDistance = value }
applyCreateOption dg (setScale value) = record dg { dirichletScale = value }
applyCreateOption dg (setGeomHandle value) =
  record dg { fundamentalGeometryHandle = value }
applyCreateOption dg (setHandleGeom handle geom) =
  record dg {
    fundamentalGeometryHandle = handle ;
    fundamentalGeometry = geom
  }
applyCreateOption dg (setGeom value) =
  record dg {
    fundamentalGeometry = value ;
    fundamentalGeometryHandle = nothing
  }
applyCreateOption dg (setCameraGeomHandle value) =
  record dg { cameraGeometryHandle = value }
applyCreateOption dg (setHandleCameraGeom handle geom) =
  record dg {
    cameraGeometryHandle = handle ;
    cameraGeometry = geom
  }
applyCreateOption dg (setCameraGeom value) =
  record dg {
    cameraGeometry = value ;
    cameraGeometryHandle = nothing
  }
applyCreateOption dg (setDirichletGeomHandle value) =
  record dg { dirichletGeometryHandle = value }
applyCreateOption dg (setHandleDirichletGeom handle geom) =
  record dg {
    dirichletGeometryHandle = handle ;
    dirichletGeometry = geom
  }
applyCreateOption dg (setDirichletGeom value) =
  record dg {
    dirichletGeometry = value ;
    dirichletGeometryHandle = nothing
  }

DiscGrpCreate : Maybe DiscGrp → List CreateOption → DiscGrp
DiscGrpCreate nothing options =
  foldl applyCreateOption defaultDiscGrp options
DiscGrpCreate (just existing) options =
  foldl applyCreateOption existing options
