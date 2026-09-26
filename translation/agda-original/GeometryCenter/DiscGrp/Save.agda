module GeometryCenter.DiscGrp.Save where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags
open import GeometryCenter.DiscGrp.Stream

data SaveChunk : Set where
  saveText : String → SaveChunk
  saveGeometry : Geom → SaveChunk

postulate
  writeSaveChunks : String → List SaveChunk → Bool

appendText : String → String → String
appendText = stringAppend

attributeChunks : DiscGrp → List SaveChunk
attributeChunks dg =
  map
    (λ entry →
      saveText
        (appendText "(attribute "
          (appendText (key entry) " )
")))
    (filter
      (λ entry → hasBit (groupAttributes dg) (token entry))
      attr-list)

displayChunks : DiscGrp → List SaveChunk
displayChunks dg =
  map
    (λ entry →
      saveText
        (appendText "(display "
          (appendText (key entry) " )
")))
    (filter
      (λ entry → hasBit (groupFlag dg) (token entry))
      display-attr-list)

elementText : Bool → DiscGrpEl → String
elementText commentWord element =
  let prefix =
        if commentWord
          then appendText "# " (appendText (elementWord element) "
")
          else appendText (elementWord element) "
"
  in appendText prefix
       (appendText (showTransform (elementTransform element)) "
")

generatorChunks : DiscGrp → List SaveChunk
generatorChunks dg =
  case groupGenerators dg of λ where
    nothing → []
    (just generators) →
      saveText
        (appendText "(ngens "
          (appendText (showNat (length (elements generators))) " )
")) ∷
      saveText "(gens
" ∷
      map (λ element → saveText (elementText false element))
          (elements generators) ++
      (saveText ")
" ∷ [])

bigListChunks : DiscGrp → List SaveChunk
bigListChunks dg =
  if not (hasBit (groupFlag dg) DG-SAVEBIGLIST)
    then []
    else
      case groupElements dg of λ where
        nothing → []
        (just big) →
          saveText
            (appendText "(nels "
              (appendText (showNat (length (elements big))) " )
")) ∷
          saveText "(els
" ∷
          map (λ element → saveText (elementText true element))
              (elements big) ++
          (saveText ")
" ∷ [])

pointText : Point4 → String
pointText point =
  appendText "(cpoint "
    (appendText (showFloat (pointEntry point 0))
      (appendText " " (appendText (showFloat (pointEntry point 1))
        (appendText " " (appendText (showFloat (pointEntry point 2))
          (appendText " " (appendText (showFloat (pointEntry point 3))
            " )
"))))))))

configurationChunks : DiscGrp → List SaveChunk
configurationChunks dg =
  saveText (pointText (groupCenter dg)) ∷
  (case groupCameraToModel dg of λ where
    nothing → []
    (just transform) →
      saveText
        (appendText "(c2m "
          (appendText (showTransform transform) ")
")) ∷ []) ++
  (saveText
    (appendText "(enumdepth "
      (appendText (showNat (enumerationDepth dg)) " )
")) ∷
   saveText
    (appendText "(enumdist "
      (appendText (showFloat (enumerationDistance dg)) " )
")) ∷
   saveText
    (appendText "(drawdist "
      (appendText (showFloat (drawingDistance dg)) " )
")) ∷
   saveText
    (appendText "(scale "
      (appendText (showFloat (dirichletScale dg)) " )
")) ∷ [])

geometryChunks : DiscGrp → List SaveChunk
geometryChunks dg =
  case fundamentalGeometry dg of λ where
    (just geom) →
      case dirichletGeometry dg of λ where
        (just dd) →
          if sameGeom geom dd
            then
              if hasBit (groupFlag dg) DG-SAVEDIRDOM
                then saveText "(geom
" ∷ saveGeometry dd ∷ saveText ")
" ∷ []
                else []
            else saveText "(geom
" ∷ saveGeometry geom ∷ saveText ")
" ∷ []
        nothing →
          saveText "(geom
" ∷ saveGeometry geom ∷ saveText ")
" ∷ []
    nothing →
      case dirichletGeometry dg of λ where
        nothing → []
        (just dd) →
          if hasBit (groupFlag dg) DG-SAVEDIRDOM
            then saveText "(geom
" ∷ saveGeometry dd ∷ saveText ")
" ∷ []
            else []

cameraChunks : DiscGrp → List SaveChunk
cameraChunks dg =
  case cameraGeometry dg of λ where
    nothing → []
    (just geom) →
      saveText "(camgeom
" ∷
      saveGeometry geom ∷
      saveText ")
" ∷ []

DiscGrpFSave : DiscGrp → List SaveChunk
DiscGrpFSave dg =
  saveText "DISCGRP
" ∷
  (case groupName dg of λ where
    nothing → []
    (just name) →
      saveText
        (appendText "(group " "
          (appendText name " " )
")) ∷ []) ++
  (case groupComment dg of λ where
    nothing → []
    (just comment) →
      saveText
        (appendText "(comment " "
          (appendText comment " " )
")) ∷ []) ++
  attributeChunks dg ++
  displayChunks dg ++
  (saveText
    (appendText "(dimn "
      (appendText (showNat (groupDimension dg)) " )
")) ∷ []) ++
  generatorChunks dg ++
  bigListChunks dg ++
  configurationChunks dg ++
  geometryChunks dg ++
  cameraChunks dg

DiscGrpSave : DiscGrp → String → Bool
DiscGrpSave dg name =
  writeSaveChunks name (DiscGrpFSave dg)
