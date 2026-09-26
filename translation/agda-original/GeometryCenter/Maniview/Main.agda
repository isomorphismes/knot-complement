module GeometryCenter.Maniview.Main where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags
open import GeometryCenter.Maniview.State
open import GeometryCenter.Maniview.Callbacks

defaultfilename : String
defaultfilename = "3torus.dgp"

geomname : String
geomname = "maniview"

gvinitText : String
gvinitText =
  " (progn
  (merge-baseap {
	lighting {
		replacelights		
		attenmult  1		
		attenmult2  1
		light {
		    color 1 1 1
		    position  0 0 0 1	
		    location camera	
		}
		light {
		    color .5 1 1
		    position  .5 .5 0 1
		    location camera
		}
	}
  })
  (normalization target none)
  (soft-shader focus on)
  )
  (geometry maniview { : dghandle})
"

gvinit : Unit
gvinit = standardOutput gvinitText

spaceCommand : DiscGrp → Maybe String
spaceCommand dg =
  if hasBit (groupAttributes dg) DG-HYPERBOLIC
    then just "(space hyperbolic)
"
    else if hasBit (groupAttributes dg) DG-EUCLIDEAN
      then just "(space euclidean)
"
      else if hasBit (groupAttributes dg) DG-SPHERICAL
        then just "(space spherical)
"
        else nothing

lightingCommand : ManiviewState → String
lightingCommand state =
  let i = metricIndex state
  in stringAppend
       "(merge-ap maniview {lighting attenmult "
       (stringAppend
         (showFloat (rowFloat (attenuation state) i 0))
         (stringAppend
           " attenmult2 "
           (stringAppend
             (showFloat (rowFloat (attenuation state) i 1))
             (stringAppend
               " attenconst "
               (stringAppend
                 (showFloat (rowFloat (attenuation state) i 6))
                 ")})
"))))

applyDirDomUi : ManiviewState → Unit
applyDirDomUi state with currentGroup state
... | nothing = tt
... | just dg =
  if hasBit (currentTileMode state) USER-GEOM
    then
      case fundamentalGeometry dg of λ where
        nothing → tt
        (just geom) →
          case dirichletGeometry dg of λ where
            (just dd) →
              if sameGeom geom dd
                then tt
                else
                  let center = groupCenter dg
                      translate =
                        transformTranslate
                          (pointEntry center 0)
                          (pointEntry center 1)
                          (pointEntry center 2)
                      scale =
                        transformScale
                          (currentScale state)
                          (currentScale state)
                          (currentScale state)
                      axis = transformConcat scale translate
                  in setGeomAxis geom axis
            nothing →
              let center = groupCenter dg
                  translate =
                    transformTranslate
                      (pointEntry center 0)
                      (pointEntry center 1)
                      (pointEntry center 2)
                  scale =
                    transformScale
                      (currentScale state)
                      (currentScale state)
                      (currentScale state)
              in setGeomAxis geom (transformConcat scale translate)
    else tt

update-gv : ManiviewState → ManiviewState
update-gv state with currentGroup state
... | nothing = state
... | just dg =
  let begin = standardOutput "(progn
"
      centerTarget =
        if hasBit (groupFlag dg) DG-CENTERCAM
          then standardOutput "(ui-target c0)
"
          else tt
      newAppearance =
        if hasBit (changedBits state) NEW-AP
          then standardOutput (lightingCommand state)
          else tt
      newSpace =
        if hasBit (changedBits state) NEW-SPACE
          then
            let emittedSpace =
                  case spaceCommand dg of λ where
                    nothing → tt
                    (just command) → standardOutput command
                emittedLighting =
                  standardOutput (lightingCommand state)
            in tt
          else tt
      stateWithSpaceChange =
        if hasBit (changedBits state) NEW-SPACE
          then record state {
                 changedBits = bitOr (changedBits state) CHANGED
               }
          else state
      dirDomChanged =
        if hasBit (changedBits stateWithSpaceChange) DIRDOM
          then applyDirDomUi stateWithSpaceChange
          else tt
      fullGeometry =
        if hasBit (changedBits stateWithSpaceChange) CHANGED
          then
            let a =
                  standardOutput
                    "(read geometry {define dghandle {
"
                b = emitDiscGrpGeometry dg
                c = standardOutput "}})
"
            in tt
          else tt
      shade =
        if hasBit (changedBits stateWithSpaceChange) SOFTSHADE
          then
            standardOutput
              (if softwareShade stateWithSpaceChange
                 then "(soft-shader focus on )
"
                 else "(soft-shader focus off )
")
          else tt
      ending = standardOutput ")
"
  in stateWithSpaceChange


readAllLines : FileHandle → String
{-# TERMINATING #-}
readAllLines file with readLine file
... | nothing = ""
... | just line = stringAppend line (readAllLines file)

splitAfterNewline :
  List Char → List Char → Maybe (Pair String String)
splitAfterNewline accumulated [] = nothing
splitAfterNewline accumulated ('\n' ∷ rest) =
  just (charsToString (reverse accumulated) , charsToString rest)
splitAfterNewline accumulated (c ∷ rest) =
  splitAfterNewline (c ∷ accumulated) rest

-- maniview.c assigns first=p before advancing p, unlike flythrough's helper.
mygetline : String → Maybe (Pair String String)
mygetline text = splitAfterNewline [] (stringToChars text)

loadManiviewHelp : Unit
loadManiviewHelp with openTextFile "maniviewhelp"
... | nothing = installHelpText embeddedManiviewHelp
... | just file =
  let text = readAllLines file
      installed = installHelpText text
      closed = closeTextFile file
  in tt

ui-init : ManiviewState → ManiviewState
ui-init state =
  let helpLoaded = loadManiviewHelp
      checkedBounds = fl-set-bounds state
  in state

ui-main-loop-step : ManiviewState → ManiviewState
ui-main-loop-step state =
  let checked = checkForms tt
      afterInput =
        case inputFile state of λ where
          nothing → state
          (just file) →
            if sameIOBFile file stdinIOB && inputHasData file
              then loadedState
                     (loadstuff state file nothing LOAD-GROUP)
              else state
  in if natEq (changedBits afterInput) 0
       then afterInput
       else
         let updated = update-gv afterInput
             snapshot = fl-update-from-dg updated
         in record updated { changedBits = 0 }

ui-main-loop : ManiviewState → ManiviewState
{-# TERMINATING #-}
ui-main-loop state =
  if quitting state
    then state
    else ui-main-loop (ui-main-loop-step state)

loadDefaultOrRequested :
  ManiviewState →
  Maybe String →
  ManiviewState
loadDefaultOrRequested state requested =
  let filename =
        case requested of λ where
          nothing → defaultfilename
          (just value) → value
  in case get-input-fp filename (currentLoadType state) of λ where
       nothing →
         case get-input-fp defaultfilename (currentLoadType state) of λ where
           nothing → state
           (just fallback) →
             let loaded =
                   loadstuff
                     state
                     fallback
                     (just defaultfilename)
                     (currentLoadType state)
             in loadedState loaded
       (just file) →
         let loaded =
               loadstuff
                 state
                 file
                 (just filename)
                 (currentLoadType state)
             firstState = loadedState loaded
         in if loadSucceeded loaded &&
               case currentGroup firstState of λ where
                 nothing → false
                 (just dg) → true
              then firstState
              else
                case get-input-fp defaultfilename (currentLoadType state) of λ where
                  nothing → firstState
                  (just fallback) →
                    loadedState
                      (loadstuff
                        firstState
                        fallback
                        (just defaultfilename)
                        (currentLoadType firstState))

parseInitialFile :
  List String →
  Pair (Maybe String) (Maybe IOBFile)
parseInitialFile [] = just defaultfilename , nothing
parseInitialFile (argument ∷ rest) =
  -- The original treats any first argument beginning with '-' as stdin.
  case stringToChars argument of λ where
    '-' ∷ chars → nothing , just stdinIOB
    chars → just argument , nothing

main : List String → ManiviewState
main arguments =
  let initialized = ui-init initialState
      parsed = parseInitialFile arguments
      withInput =
        record initialized { inputFile = second parsed }
      loaded =
        case second parsed of λ where
          (just input) →
            loadedState
              (loadstuff withInput input nothing LOAD-GROUP)
          nothing →
            loadDefaultOrRequested withInput (first parsed)
      sentInit = gvinit
      sentGroup = update-gv loaded
      snapshot = fl-update-from-dg sentGroup
  in ui-main-loop sentGroup
