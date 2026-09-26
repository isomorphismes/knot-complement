module GeometryCenter.Types where

open import GeometryCenter.Prelude

Point4 : Set
Point4 = List Float

Plane4 : Set
Plane4 = List Float

Matrix4 : Set
Matrix4 = List Point4

Point : Set
Point = Point4

Transform : Set
Transform = Matrix4

ProjMatrix : Set
ProjMatrix = Matrix4

record ColorA : Set where
  constructor rgba
  field
    red green blue alpha : Float
open ColorA public

record Complex : Set where
  constructor complex
  field
    real imag : Float
open Complex public

SL2CMatrix : Set
SL2CMatrix = List (List Complex)

identity4 : Matrix4
identity4 =
  (1.0 ∷ 0.0 ∷ 0.0 ∷ 0.0 ∷ []) ∷
  (0.0 ∷ 1.0 ∷ 0.0 ∷ 0.0 ∷ []) ∷
  (0.0 ∷ 0.0 ∷ 1.0 ∷ 0.0 ∷ []) ∷
  (0.0 ∷ 0.0 ∷ 0.0 ∷ 1.0 ∷ []) ∷ []

origin4 : Point4
origin4 = 0.0 ∷ 0.0 ∷ 0.0 ∷ 1.0 ∷ []

zero4 : Point4
zero4 = 0.0 ∷ 0.0 ∷ 0.0 ∷ 0.0 ∷ []

pointEntry : Point4 → Nat → Float
pointEntry point index with lookup point index
... | nothing = 0.0
... | just value = value

matrixEntry : Matrix4 → Nat → Nat → Float
matrixEntry matrix row column with lookup matrix row
... | nothing = 0.0
... | just values = pointEntry values column

row4 : Matrix4 → Nat → Point4
row4 matrix row with lookup matrix row
... | nothing = zero4
... | just values = values

makePoint4 : Float → Float → Float → Float → Point4
makePoint4 x y z w = x ∷ y ∷ z ∷ w ∷ []

record MatrixGroup : Set where
  constructor matrixGroup
  field
    matrixAttributes : Nat
    matrixDimension : Nat
    matrixSignature : Nat
open MatrixGroup public

record WordAcceptor : Set where
  constructor wordAcceptor
  field
    waStart : Nat
    waFail : Nat
    waActions : List (List Nat)
    waGenerators : List Char
open WordAcceptor public

record DiscGrpEl : Set where
  constructor discGrpEl
  field
    elementAttributes : Nat
    elementWord : String
    elementTransform : Transform
    elementColor : ColorA
    -- C stores a pointer to the inverse element.  The direct Agda mirror
    -- stores its index in the containing element list.
    inverseIndex : Maybe Nat
open DiscGrpEl public

record DiscGrpElList : Set where
  constructor discGrpElList
  field
    elementMatrixGroup : MatrixGroup
    elements : List DiscGrpEl
open DiscGrpElList public

record DGViewInfo : Set where
  constructor dgViewInfo
  field
    frustum : List Point4
    modelToWorld : Transform
    worldToModel : Transform
    cameraToWorld : Transform
    worldToCamera : Transform
    cameraToModel : Transform
    modelToCamera : Transform
open DGViewInfo public

postulate
  Geom Handle Appearance Pick BBox GeomClass Pool IOBFile : Set
  GeomIterator GeomTransformN : Set
  Callback TokenStream FileHandle : Set

record DiscGrp : Set where
  constructor discGrp
  field
    groupName : Maybe String
    groupComment : Maybe String
    groupFlag : Nat
    groupAttributes : Nat
    groupDimension : Nat
    groupCameraToModel : Maybe Transform
    groupWordAcceptor : Maybe WordAcceptor
    groupGenerators : Maybe DiscGrpElList
    groupNeighbors : Maybe DiscGrpElList
    groupElements : Maybe DiscGrpElList
    groupCenter : Point4
    cameraGeometry : Maybe Geom
    cameraGeometryHandle : Maybe Handle
    dirichletGeometry : Maybe Geom
    dirichletGeometryHandle : Maybe Handle
    fundamentalGeometry : Maybe Geom
    fundamentalGeometryHandle : Maybe Handle
    dirichletScale : Float
    enumerationDepth : Nat
    enumerationDistance : Float
    drawingDistance : Float
    predrawCallback : Maybe Callback
    groupViewInfo : DGViewInfo
open DiscGrp public

record WEVertex : Set where
  constructor weVertex
  field
    vertexCoordinates : Point4
    vertexDistance : Float
    vertexIdeal : Bool
open WEVertex public

record WEEdge : Set where
  constructor weEdge
  field
    edgeTail edgeTip : Nat
    edgeBackLeft edgeBackRight edgeFrontLeft edgeFrontRight : Maybe Nat
    edgeLeftFace edgeRightFace : Maybe Nat
open WEEdge public

record WEFace : Set where
  constructor weFace
  field
    faceOrder : Nat
    faceFillTone : Int
    faceSomeEdge : Maybe Nat
    faceGroupElement : ProjMatrix
    faceInverse : Maybe Nat
    faceNext : Maybe Nat
    facePrevious : Maybe Nat
    faceCleanNext : Maybe Nat
open WEFace public

record WEPolyhedron : Set where
  constructor wePolyhedron
  field
    vertices : List WEVertex
    edges : List WEEdge
    faces : List WEFace
    dirtyFaces : List Nat
    cleanFaces : List Nat
    pendingFaces : List Nat
open WEPolyhedron public

numberOfVertices : WEPolyhedron → Nat
numberOfVertices poly = length (vertices poly)

numberOfEdges : WEPolyhedron → Nat
numberOfEdges poly = length (edges poly)

numberOfFaces : WEPolyhedron → Nat
numberOfFaces poly = length (faces poly)

record KeyTokenPair : Set where
  constructor keyToken
  field
    key : String
    token : Nat
open KeyTokenPair public

record BoundingResult : Set where
  constructor boundingResult
  field
    boundingBox : Maybe BBox
open BoundingResult public
