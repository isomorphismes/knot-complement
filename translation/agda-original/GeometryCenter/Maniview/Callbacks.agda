module GeometryCenter.Maniview.Callbacks where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags
open import GeometryCenter.DiscGrp.Stream
open import GeometryCenter.DiscGrp.Save
open import GeometryCenter.Maniview.State

setGroupFlag :
  ManiviewState → Nat → Bool → ManiviewState
setGroupFlag state bit enabled =
  withGroup state
    (λ dg →
      record dg {
        groupFlag = toggleBit (groupFlag dg) enabled bit
      })

DspyattrProc :
  ManiviewState → Nat → Bool → ManiviewState
DspyattrProc state bit enabled =
  orChanged (setGroupFlag state bit enabled) CHANGED

DisplayProc :
  ManiviewState → Nat → Bool → ManiviewState
DisplayProc = DspyattrProc

SoftshadeProc : ManiviewState → ManiviewState
SoftshadeProc state =
  record state {
    softwareShade = not (softwareShade state) ;
    changedBits = SOFTSHADE
  }

RadiusProc : ManiviewState → Float → ManiviewState
RadiusProc state radius =
  orChanged
    (withGroup state
      (λ dg → record dg { enumerationDistance = radius }))
    CHANGED

DrawRadiusProc : ManiviewState → Float → ManiviewState
DrawRadiusProc state radius =
  orChanged
    (withGroup state
      (λ dg → record dg { drawingDistance = radius }))
    CHANGED

TileModeProc : ManiviewState → Nat → ManiviewState
TileModeProc state mode =
  record state { currentTileMode = mode }

DDXYProc :
  ManiviewState → Float → Float → ManiviewState
DDXYProc state x y =
  orChanged
    (withGroup state
      (λ dg →
        let center = groupCenter dg
        in record dg {
          groupCenter =
            makePoint4 x y
              (pointEntry center 2)
              (pointEntry center 3)
        }))
    (bitOr DIRDOM CHANGED)

DDZProc : ManiviewState → Float → ManiviewState
DDZProc state z =
  orChanged
    (withGroup state
      (λ dg →
        let center = groupCenter dg
        in record dg {
          groupCenter =
            makePoint4
              (pointEntry center 0)
              (pointEntry center 1)
              z
              (pointEntry center 3)
        }))
    (bitOr DIRDOM CHANGED)

DDResetProc : ManiviewState → ManiviewState
DDResetProc state =
  orChanged
    (withGroup state
      (λ dg → record dg { groupCenter = origin4 }))
    (bitOr DIRDOM CHANGED)

WorddepthProc : ManiviewState → Nat → ManiviewState
WorddepthProc state depth =
  orChanged
    (withGroup state
      (λ dg → record dg { enumerationDepth = depth }))
    CHANGED

DDScaleProc : ManiviewState → Float → ManiviewState
DDScaleProc state scale =
  let scaledState = record state { currentScale = scale }
      withDg =
        if natEq (currentTileMode state) DIRDOM-MODE
          then withGroup scaledState
                 (λ dg → record dg { dirichletScale = scale })
          else scaledState
  in orChanged withDg (bitOr DIRDOM CHANGED)

Attenuation1SliderProc :
  ManiviewState → Float → ManiviewState
Attenuation1SliderProc state value =
  record state {
    attenuation =
      replaceNestedFloat (metricIndex state) 0 value (attenuation state) ;
    changedBits = NEW-AP
  }

Attenuation2SliderProc :
  ManiviewState → Float → ManiviewState
Attenuation2SliderProc state value =
  record state {
    attenuation =
      replaceNestedFloat (metricIndex state) 1 value (attenuation state) ;
    changedBits = NEW-AP
  }

Attenuation3SliderProc :
  ManiviewState → Float → ManiviewState
Attenuation3SliderProc state value =
  record state {
    attenuation =
      replaceNestedFloat (metricIndex state) 6 value (attenuation state) ;
    changedBits = NEW-AP
  }

setDisplayWindow : WindowFlags → Bool → WindowFlags
setDisplayWindow windows value =
  record windows { displayWindow = value }

setEnumWindow : WindowFlags → Bool → WindowFlags
setEnumWindow windows value =
  record windows { enumWindow = value }

setLoadWindow : WindowFlags → Bool → WindowFlags
setLoadWindow windows value =
  record windows { loadWindow = value }

setSaveWindow : WindowFlags → Bool → WindowFlags
setSaveWindow windows value =
  record windows { saveWindow = value }

setDirichletWindow : WindowFlags → Bool → WindowFlags
setDirichletWindow windows value =
  record windows { dirichletWindow = value }

setInfoWindow : WindowFlags → Bool → WindowFlags
setInfoWindow windows value =
  record windows { infoWindow = value }

setHelpWindow : WindowFlags → Bool → WindowFlags
setHelpWindow windows value =
  record windows { helpWindow = value }

DisplayButtonProc : ManiviewState → ManiviewState
DisplayButtonProc state =
  record state { windows = setDisplayWindow (windows state) true }

EnumerateButtonProc : ManiviewState → ManiviewState
EnumerateButtonProc state =
  record state { windows = setEnumWindow (windows state) true }

TileButtonProc : ManiviewState → ManiviewState
TileButtonProc state =
  record state { windows = setDirichletWindow (windows state) true }

HelpButtonProc : ManiviewState → ManiviewState
HelpButtonProc state =
  record state { windows = setHelpWindow (windows state) true }

LoadButtonProc : ManiviewState → ManiviewState
LoadButtonProc state =
  record state { windows = setLoadWindow (windows state) true }

SaveButtonProc : ManiviewState → ManiviewState
SaveButtonProc state =
  record state { windows = setSaveWindow (windows state) true }

InfoButtonProc : ManiviewState → ManiviewState
InfoButtonProc state =
  record state { windows = setInfoWindow (windows state) true }

QuitButtonProc : ManiviewState → ManiviewState
QuitButtonProc state =
  let exited = exitProcess 0
  in record state { quitting = true }

HelpOKButtonProc : ManiviewState → ManiviewState
HelpOKButtonProc state =
  record state { windows = setHelpWindow (windows state) false }

DisplayOKButtonProc : ManiviewState → ManiviewState
DisplayOKButtonProc state =
  record state { windows = setDisplayWindow (windows state) false }

EnumOKButtonProc : ManiviewState → ManiviewState
EnumOKButtonProc state =
  record state { windows = setEnumWindow (windows state) false }

TileOKButtonProc : ManiviewState → ManiviewState
TileOKButtonProc state =
  record state { windows = setDirichletWindow (windows state) false }

InfoOKButtonProc : ManiviewState → ManiviewState
InfoOKButtonProc state =
  record state { windows = setInfoWindow (windows state) false }

LoadCancelButtonProc : ManiviewState → ManiviewState
LoadCancelButtonProc state =
  record state { windows = setLoadWindow (windows state) false }

SaveCancelButtonProc : ManiviewState → ManiviewState
SaveCancelButtonProc state =
  record state { windows = setSaveWindow (windows state) false }

LoadProc :
  ManiviewState → Nat → Bool → ManiviewState
LoadProc state loadType selected =
  let marked = record state { loadTypeChanged = true }
  in if selected
       then record marked { currentLoadType = loadType }
       else marked

get-input-fp :
  String → Nat → Maybe IOBFile
get-input-fp filename loadType with openIOBFile filename
... | just file = just file
... | nothing with environment "GEOMDATA"
...   | nothing = nothing
...   | just root =
  let subdir =
        if hasBit loadType LOAD-GROUP
          then "/groups/"
          else "/geom/"
      path =
        stringAppend root
          (stringAppend subdir filename)
  in openIOBFile path

closeInputUnlessStdin : IOBFile → Unit
closeInputUnlessStdin file =
  if sameIOBFile file stdinIOB
    then tt
    else closeIOBFile file

record LoadResult : Set where
  constructor loadResult
  field
    loadedState : ManiviewState
    loadSucceeded : Bool
open LoadResult public

loadstuff :
  ManiviewState →
  IOBFile →
  Maybe String →
  Nat →
  LoadResult
loadstuff state file filename loadType =
  if hasBit loadType LOAD-GROUP ||
     hasBit loadType CHECK-PIPE
    then
      case DiscGrpImport file of λ where
        nothing →
          let closed = closeInputUnlessStdin file
          in loadResult state false
        (just dg) →
          let oldSpace = currentSpace state
              space =
                bitAnd (groupAttributes dg) DG-METRIC-BITS
              index = index-from-bit space
              changed0 =
                if natEq oldSpace space then 0 else NEW-SPACE
              changed1 =
                bitOr changed0 (bitOr CHANGED NEW-AP)
              next =
                record state {
                  currentGroup = just dg ;
                  currentSpace = space ;
                  metricIndex = index ;
                  changedBits = changed1
                }
              closed = closeInputUnlessStdin file
          in loadResult next true
  else if hasBit loadType LOAD-GEOM
    then
      case geomLoad file filename of λ where
        nothing →
          let closed = closeInputUnlessStdin file
          in loadResult state false
        (just geom) →
          let instance = makeGeomInstance geom transformIdentity
              next =
                orChanged
                  (withGroup state
                    (λ dg →
                      record dg { fundamentalGeometry = just instance }))
                  (bitOr DIRDOM CHANGED)
              closed = closeInputUnlessStdin file
          in loadResult next true
  else if hasBit loadType LOAD-CAMGEOM
    then
      case geomLoad file filename of λ where
        nothing →
          let closed = closeInputUnlessStdin file
          in loadResult state false
        (just geom) →
          let next =
                orChanged
                  (withGroup state
                    (λ dg → record dg { cameraGeometry = just geom }))
                  CHANGED
              closed = closeInputUnlessStdin file
          in loadResult next true
  else
    let closed = closeInputUnlessStdin file
    in loadResult state true

LoadOKButtonProc :
  ManiviewState → String → LoadResult
LoadOKButtonProc state filename =
  case get-input-fp filename (currentLoadType state) of λ where
    nothing → loadResult state false
    (just file) →
      let loaded =
            loadstuff
              state
              file
              (just filename)
              (currentLoadType state)
      in if loadSucceeded loaded
           then loadResult
                  (record (loadedState loaded) {
                    windows =
                      setLoadWindow (windows (loadedState loaded)) false
                  })
                  true
           else loaded

LoadShowBrowserProc :
  ManiviewState → Maybe String → LoadResult
LoadShowBrowserProc state nothing =
  loadResult (record state { loadTypeChanged = false }) false
LoadShowBrowserProc state (just filename) =
  LoadOKButtonProc
    (record state { loadTypeChanged = false })
    filename

savegroup : ManiviewState → String → Bool
savegroup state filename with currentGroup state
... | nothing = false
... | just dg = DiscGrpSave dg filename

SaveOKButtonProc :
  ManiviewState → String → Pair ManiviewState Bool
SaveOKButtonProc state filename =
  let saved = savegroup state filename
      next =
        record state {
          windows = setSaveWindow (windows state) false
        }
  in next , saved

SaveGeomButtonProc :
  ManiviewState → Bool → ManiviewState
SaveGeomButtonProc state selected =
  setGroupFlag state DG-SAVEDIRDOM selected

SaveGroupButtonProc :
  ManiviewState → Bool → ManiviewState
SaveGroupButtonProc state selected =
  setGroupFlag state DG-SAVEBIGLIST selected
