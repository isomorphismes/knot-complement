module GeometryCenter.DiscGrp.Stream where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags
open import GeometryCenter.DiscGrp.Create
open import GeometryCenter.DiscGrp.Complex
open import GeometryCenter.DiscGrp.Projective
open import GeometryCenter.DiscGrp.Dirdom
open import GeometryCenter.DiscGrp.Constraint
open import GeometryCenter.DiscGrp.Enum

DG-GROUPNAME DG-COMMENT DG-ATTRIBUTE DG-MODEL DG-NGENS DG-NELS : Nat
DG-GROUPNAME = 1
DG-COMMENT = 2
DG-ATTRIBUTE = 3
DG-MODEL = 4
DG-NGENS = 5
DG-NELS = 6

DG-GENS DG-ELS DG-DIMN DG-CAMGEOM DG-GEOM DG-CAMGEOMFILE : Nat
DG-GENS = 7
DG-ELS = 8
DG-DIMN = 9
DG-CAMGEOM = 10
DG-GEOM = 11
DG-CAMGEOMFILE = 12

DG-GEOMFILE DG-WAFILE DG-MATRIXGROUP DG-CPOINT DG-ENUMDEPTH : Nat
DG-GEOMFILE = 13
DG-WAFILE = 14
DG-MATRIXGROUP = 15
DG-CPOINT = 16
DG-ENUMDEPTH = 17

DG-ENUMDIST DG-DSPYATTR DG-SCALE DG-C2M DG-DRAWDIST : Nat
DG-ENUMDIST = 18
DG-DSPYATTR = 19
DG-SCALE = 20
DG-C2M = 21
DG-DRAWDIST = 22

keytokenlist : List KeyTokenPair
keytokenlist =
  keyToken "group" DG-GROUPNAME ∷
  keyToken "comment" DG-COMMENT ∷
  keyToken "attribute" DG-ATTRIBUTE ∷
  keyToken "model" DG-MODEL ∷
  keyToken "ngens" DG-NGENS ∷
  keyToken "nels" DG-NELS ∷
  keyToken "gens" DG-GENS ∷
  keyToken "els" DG-ELS ∷
  keyToken "dimn" DG-DIMN ∷
  keyToken "dimension" DG-DIMN ∷
  keyToken "camgeom" DG-CAMGEOM ∷
  keyToken "geom" DG-GEOM ∷
  keyToken "camgeomfile" DG-CAMGEOMFILE ∷
  keyToken "geomfile" DG-GEOMFILE ∷
  keyToken "wafile" DG-WAFILE ∷
  keyToken "matrixgroup" DG-MATRIXGROUP ∷
  keyToken "mgroup" DG-MATRIXGROUP ∷
  keyToken "cpoint" DG-CPOINT ∷
  keyToken "enumdepth" DG-ENUMDEPTH ∷
  keyToken "enumdist" DG-ENUMDIST ∷
  keyToken "drawdist" DG-DRAWDIST ∷
  keyToken "display" DG-DSPYATTR ∷
  keyToken "scale" DG-SCALE ∷
  keyToken "cam2model" DG-C2M ∷ []

attr-list : List KeyTokenPair
attr-list =
  keyToken "hyperbolic" DG-HYPERBOLIC ∷
  keyToken "euclidean" DG-EUCLIDEAN ∷
  keyToken "spherical" DG-SPHERICAL ∷
  keyToken "finite" DG-FINITE ∷
  keyToken "transposed" DG-TRANSPOSED ∷
  keyToken "conformalball" DG-CONFORMALBALL ∷
  keyToken "upperhalfspace" DG-UPPERHALFSPACE ∷
  keyToken "projective" DG-PROJECTIVEMODEL ∷ []

display-attr-list : List KeyTokenPair
display-attr-list =
  keyToken "centercam" DG-CENTERCAM ∷
  keyToken "zcull" DG-ZCULL ∷
  keyToken "drawcam" DG-DRAWCAM ∷
  keyToken "drawdirdom" DG-DRAWDIRDOM ∷
  keyToken "drawgeom" DG-DRAWGEOM ∷ []

token-from-string : String → List KeyTokenPair → Nat
token-from-string wanted [] = 0
token-from-string wanted (entry ∷ rest) =
  if stringEq wanted (key entry)
    then token entry
    else token-from-string wanted rest

get-keyword : IOBFile → Maybe String
get-keyword file with nextChar file
... | nothing = nothing
... | just '(' =
  let consumed = consumeChar file
  in readStringToken file
... | just ')' = nothing
... | just other = nothing

get-matching-parenthesis : IOBFile → Bool
get-matching-parenthesis file with nextChar file
... | just ')' =
  let consumed = consumeChar file
  in true
... | _ = false

included-file : IOBFile → Maybe IOBFile
included-file file with nextChar file
... | just '<' =
  let ignored = standardError "Discrete groups: included files not implemented"
  in nothing
... | _ = nothing

parse-group-name : String → MatrixGroup
parse-group-name ignored =
  matrixGroup DG-GENERAL 4 0

white : ColorA
white = rgba 1.0 1.0 1.0 0.75

floatAt : List Float → Nat → Float
floatAt values index with lookup values index
... | nothing = 0.0
... | just value = value

sl2cFromEight : List Float → SL2CMatrix
sl2cFromEight values =
  makeSL2C
    (complex (floatAt values 0) (floatAt values 1))
    (complex (floatAt values 2) (floatAt values 3))
    (complex (floatAt values 4) (floatAt values 5))
    (complex (floatAt values 6) (floatAt values 7))

defaultGeneratorWord : Nat → String
defaultGeneratorWord index =
  charToString (charAddNat 'a' index)

readElementWord : IOBFile → Nat → String
readElementWord file index with nextChar file
... | nothing = defaultGeneratorWord index
... | just character =
  if charBetween 'A' character 'z'
    then
      case readStringToken file of λ where
        nothing → defaultGeneratorWord index
        (just word) → word
    else defaultGeneratorWord index

readElementTransform : DiscGrp → IOBFile → Transform
readElementTransform dg file =
  if hasBit (groupAttributes dg) DG-CONFORMALBALL
    then transformIdentity
    else if hasBit (groupAttributes dg) DG-UPPERHALFSPACE
      then
        case readFloats 8 file of λ where
          nothing → transformIdentity
          (just values) → sl2c-to-proj (sl2cFromEight values)
      else
        case readTransform file of λ where
          nothing → transformIdentity
          (just transform) → transform

readElements :
  DiscGrp →
  IOBFile →
  Nat →
  Nat →
  List DiscGrpEl →
  List DiscGrpEl
readElements dg file 0 index accumulated = reverse accumulated
readElements dg file (suc remaining) index accumulated =
  let word = readElementWord file index
      transform = readElementTransform dg file
      element =
        discGrpEl 0 word transform white nothing
  in readElements dg file remaining (suc index) (element ∷ accumulated)

transposeIntoBigList :
  DiscGrp →
  List DiscGrpEl →
  DiscGrp
transposeIntoBigList dg parsed =
  if not (hasBit (groupAttributes dg) DG-TRANSPOSED)
    then dg
    else
      -- The C source writes transposed parsed transforms into big_list even
      -- while reading another element list.  Preserve that destination.
      case groupElements dg of λ where
        nothing → dg
        (just big) →
          let transposed =
                zipReplace
                  (λ old fresh →
                    record old {
                      elementTransform =
                        transformTranspose (elementTransform fresh)
                    })
                  (elements big)
                  parsed
          in record dg {
               groupElements =
                 just (record big { elements = transposed })
             }

get-el-list :
  DiscGrp →
  DiscGrpElList →
  IOBFile →
  Pair DiscGrp DiscGrpElList
get-el-list dg list file =
  let parsed =
        readElements dg file (length (elements list)) 0 []
      filled = record list { elements = parsed }
      updatedGroup = transposeIntoBigList dg parsed
      clearedModel =
        record updatedGroup {
          groupAttributes =
            bitAnd (groupAttributes updatedGroup)
                   (bitNot DG-UPPERHALFSPACE)
        }
  in clearedModel , filled

record StreamState : Set where
  constructor streamState
  field
    streamGroup : DiscGrp
    currentMatrixGroup : MatrixGroup
open StreamState public

initialStreamState : StreamState
initialStreamState =
  streamState defaultDiscGrp (matrixGroup DG-GENERAL 4 0)

setGeneratorMatrixGroup :
  MatrixGroup →
  DiscGrpElList →
  DiscGrpElList
setGeneratorMatrixGroup matrixGroupValue list =
  record list { elementMatrixGroup = matrixGroupValue }

readPoint4 : IOBFile → Maybe Point4
readPoint4 file with readFloats 4 file
... | nothing = nothing
... | just values =
  just
    (makePoint4
      (floatAt values 0)
      (floatAt values 1)
      (floatAt values 2)
      (floatAt values 3))

applyKeyword :
  IOBFile →
  String →
  StreamState →
  StreamState
applyKeyword file keyword state =
  let code = token-from-string keyword keytokenlist
      dg = streamGroup state
  in
  if natEq code DG-WAFILE then
    case readStringToken file of λ where
      nothing → state
      (just name) →
        case findFile nothing name of λ where
          nothing → state
          (just path) →
            case openWordAcceptor path of λ where
              nothing → state
              (just handle) →
                case parseWordAcceptor handle of λ where
                  nothing → state
                  (just automaton) →
                    record state {
                      streamGroup =
                        record dg { groupWordAcceptor = just automaton }
                    }
  else if natEq code DG-DSPYATTR then
    case readStringToken file of λ where
      nothing → state
      (just name) →
        record state {
          streamGroup =
            record dg {
              groupFlag =
                bitOr (groupFlag dg)
                  (token-from-string name display-attr-list)
            }
        }
  else if natEq code DG-ATTRIBUTE || natEq code DG-MODEL then
    case readStringToken file of λ where
      nothing → state
      (just name) →
        record state {
          streamGroup =
            record dg {
              groupAttributes =
                bitOr (groupAttributes dg)
                  (token-from-string name attr-list)
            }
        }
  else if natEq code DG-COMMENT then
    case readStringToken file of λ where
      nothing → state
      (just comment) →
        record state {
          streamGroup = record dg { groupComment = just comment }
        }
  else if natEq code DG-MATRIXGROUP then
    case readStringToken file of λ where
      nothing → state
      (just name) →
        record state { currentMatrixGroup = parse-group-name name }
  else if natEq code DG-SCALE then
    case readFloat file of λ where
      nothing → state
      (just value) →
        record state {
          streamGroup = record dg { dirichletScale = value }
        }
  else if natEq code DG-C2M then
    case readTransform file of λ where
      nothing → state
      (just transform) →
        record state {
          streamGroup =
            record dg { groupCameraToModel = just transform }
        }
  else if natEq code DG-ENUMDEPTH then
    case readNat file of λ where
      nothing → state
      (just value) →
        record state {
          streamGroup = record dg { enumerationDepth = value }
        }
  else if natEq code DG-ENUMDIST then
    case readFloat file of λ where
      nothing → state
      (just value) →
        record state {
          streamGroup = record dg { enumerationDistance = value }
        }
  else if natEq code DG-DRAWDIST then
    case readFloat file of λ where
      nothing → state
      (just value) →
        record state {
          streamGroup = record dg { drawingDistance = value }
        }
  else if natEq code DG-CPOINT then
    case readPoint4 file of λ where
      nothing → state
      (just point) →
        record state {
          streamGroup = record dg { groupCenter = point }
        }
  else if natEq code DG-CAMGEOM then
    case geomLoad file nothing of λ where
      nothing → state
      (just geom) →
        record state {
          streamGroup = record dg { cameraGeometry = just geom }
        }
  else if natEq code DG-GROUPNAME then
    case readStringToken file of λ where
      nothing → state
      (just name) →
        record state {
          streamGroup = record dg { groupName = just name }
        }
  else if natEq code DG-DIMN then
    case readNat file of λ where
      nothing → state
      (just dimension) →
        record state {
          streamGroup = record dg { groupDimension = dimension } ;
          currentMatrixGroup =
            record (currentMatrixGroup state) {
              matrixDimension = suc dimension
            }
        }
  else if natEq code DG-NGENS then
    case readNat file of λ where
      nothing → state
      (just count) →
        record state {
          streamGroup =
            record dg {
              groupGenerators =
                just
                  (discGrpElList
                    (currentMatrixGroup state)
                    (replicate count emptyElement))
            }
        }
  else if natEq code DG-NELS then
    case readNat file of λ where
      nothing → state
      (just count) →
        record state {
          streamGroup =
            record dg {
              groupElements =
                just
                  (discGrpElList
                    (currentMatrixGroup state)
                    (replicate count emptyElement))
            }
        }
  else if natEq code DG-GENS then
    case groupGenerators dg of λ where
      nothing → state
      (just generators) →
        let parsed = get-el-list dg
              (setGeneratorMatrixGroup
                (currentMatrixGroup state) generators)
              file
        in record state {
             streamGroup =
               record (first parsed) {
                 groupGenerators = just (second parsed)
               }
           }
  else if natEq code DG-ELS then
    case groupElements dg of λ where
      nothing → state
      (just big) →
        let parsed = get-el-list dg
              (setGeneratorMatrixGroup
                (currentMatrixGroup state) big)
              file
        in record state {
             streamGroup =
               record (first parsed) {
                 groupElements = just (second parsed) ;
                 groupFlag =
                   bitOr (groupFlag (first parsed)) DG-SAVEBIGLIST
               }
           }
  else if natEq code DG-GEOM then
    case geomLoad file nothing of λ where
      nothing → state
      (just geom) →
        record state {
          streamGroup =
            record dg { fundamentalGeometry = just geom }
        }
  else state

parseKeywords : IOBFile → StreamState → StreamState
{-# TERMINATING #-}
parseKeywords file state with get-keyword file
... | nothing = state
... | just keyword =
  let next = applyKeyword file keyword state
      matched = get-matching-parenthesis file
  in if matched then parseKeywords file next else next

DiscGrpImport : IOBFile → Maybe DiscGrp
DiscGrpImport file =
  case nextToken file of λ where
    nothing → nothing
    (just header) →
      if not (stringEq header "DISCGRP")
        then nothing
        else
          let parsed = parseKeywords file initialStreamState
              withInverses = DiscGrpAddInverses (streamGroup parsed)
              final =
                case groupElements withInverses of λ where
                  (just existing) → withInverses
                  nothing →
                    let config =
                          DiscGrpInitStandardConstraint
                            (enumerationDepth withInverses)
                            (enumerationDistance withInverses)
                            (enumerationDistance withInverses)
                        enumerated =
                          DiscGrpEnum
                            withInverses
                            (DiscGrpStandardConstraint config)
                    in record withInverses {
                         groupElements = just enumerated
                       }
          in just final
