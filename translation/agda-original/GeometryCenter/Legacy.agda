module GeometryCenter.Legacy where

open import GeometryCenter.Prelude
open import GeometryCenter.Types

-- Calls outside the selected Geometry Center source.  They are kept in one
-- module so the direct translation can preserve the old program's structure
-- without pretending to have translated Geomview/XForms/libc themselves.

postulate
  transformConcat : Transform → Transform → Transform
  transformInverse : Transform → Maybe Transform
  transformIdentity : Transform
  transformCopy : Transform → Transform
  transformTranspose : Transform → Transform
  transformScale : Float → Float → Float → Transform
  transformTranslate : Float → Float → Float → Transform
  transformPoint : Transform → Point4 → Point4

  spaceDistance : Point4 → Point4 → Nat → Float
  spaceNormalize : Point4 → Nat → Point4
  spaceGramSchmidt : Point4 → Point4 → Nat → Point4
  r40Dot : Point4 → Point4 → Float
  r31Dot : Point4 → Point4 → Float

  geomIterateTransforms : DiscGrp → List Transform
  geomBound : Geom → Transform → Maybe BBox
  bboxUnion : BBox → BBox → BBox
  geomPick : Geom → Pick → Appearance → Transform → Bool
  pickSetPathIndex : Pick → Nat → Nat → Pick
  scanHandle : Maybe Handle → Callback → Unit
  geomDelete : Geom → Unit
  geomHandleScan : Geom → Callback → Unit

  geomSave : Geom → String → Unit
  geomFSave : Geom → FileHandle → String → Unit
  geomLoad : IOBFile → Maybe String → Maybe Geom

  cameraWorldToCamera : Transform
  cameraSetCameraToWorld : Transform → Unit
  currentModelToWorld : Transform
  cameraHalfYField : Float
  cameraAspect : Float

  drawGeom : Geom → Unit
  pushTransform : Unit → Unit
  popTransform : Unit → Unit
  multiplyCurrentTransform : Transform → Unit

  parseWordAcceptor : FileHandle → Maybe WordAcceptor
  openWordAcceptor : String → Maybe FileHandle
  closeFile : FileHandle → Unit
  findFile : Maybe String → String → Maybe String

  fileOpen : String → String → Maybe FileHandle
  fileReadColor : FileHandle → Maybe ColorA
  loadColorMap : String → Maybe (List ColorA)
  environment : String → Maybe String

  errorMessage : String → Unit
  standardError : String → Unit
  standardOutput : String → Unit

  makeGeomClass : String → GeomClass

  -- The Weeks Dirichlet-domain source calls conversion/rendering helpers
  -- outside the selected source after it has built the winged-edge polyhedron.
  polyhedronToGeom : WEPolyhedron → Geom
  polyhedronToBeamsGeom : WEPolyhedron → Float → Geom

  -- Stream/parser primitives used by dgstream.c and Maniview.
  nextToken : IOBFile → Maybe String
  nextChar : IOBFile → Maybe Char
  consumeChar : IOBFile → Unit
  readNat : IOBFile → Maybe Nat
  readFloat : IOBFile → Maybe Float
  readFloats : Nat → IOBFile → Maybe (List Float)
  readTransform : IOBFile → Maybe Transform
  readStringToken : IOBFile → Maybe String

  -- Geomview/XForms command transport used by Flythrough and Maniview.
  emitGeomview : String → Unit
  readLine : FileHandle → Maybe String
  rewindFile : FileHandle → Unit
  openTextFile : String → Maybe FileHandle
  closeTextFile : FileHandle → Unit

  FormObject : Set
