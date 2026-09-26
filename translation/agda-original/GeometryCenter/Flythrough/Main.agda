module GeometryCenter.Flythrough.Main where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy

data FlightPath : Set where
  LOOP QUARTER DIRECT EQUI : FlightPath

data DiagramSpace : Set where
  EUC HYP : DiagramSpace

pathStem : FlightPath → String
pathStem LOOP = "loop"
pathStem QUARTER = "quart"
pathStem DIRECT = "dir"
pathStem EQUI = "equi"

record FlythroughState : Set where
  constructor flythroughState
  field
    dodecScale : Float
    pathFile : Maybe FileHandle
    go : Bool
    speed : Nat
    whichPath : FlightPath
    helpWindowId : Nat
    mainWindowId : Nat
    -- main.c leaves turbo uninitialized unless -t occurs.  Nothing preserves
    -- that source state rather than silently choosing false.
    turbo : Maybe Bool
    quitting : Bool
open FlythroughState public

postulate
  uninitializedTurboValue : Bool

turboActive : FlythroughState → Bool
turboActive state with turbo state
... | just value = value
... | nothing = uninitializedTurboValue

initialState : FlythroughState
initialState =
  flythroughState 0.99 nothing true 2 LOOP 0 0 nothing false

emit : String → Unit
emit = standardOutput

TilingProc : Nat → Unit
TilingProc level =
  emit
    (stringAppend
      "(read geometry {define tile { < br4."
      (stringAppend (showNat level) ".tlist}})
"))

ScaleProc : Float → Pair Float Unit
ScaleProc scale =
  scale ,
  emit
    (stringAppend
      "(read transform {define scale {1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 "
      (stringAppend (showFloat (1.0 /f scale)) "}})
"))

pathFileName : FlightPath → Nat → String
pathFileName path speedValue =
  let suffix =
        stringAppend "."
          (stringAppend (showNat speedValue) ".gv")
      localName = stringAppend (pathStem path) suffix
  in case environment "GEOMDATA" of λ where
       nothing → localName
       (just root) →
         stringAppend root
           (stringAppend "/groups/"
             localName)

closeCurrentPath : FlythroughState → Unit
closeCurrentPath state with pathFile state
... | nothing = tt
... | just handle = closeTextFile handle

PathProc : FlythroughState → FlightPath → FlythroughState
PathProc state path =
  let closed = closeCurrentPath state
      filename = pathFileName path (speed state)
  in case openTextFile filename of λ where
       nothing →
         let complained =
               standardError
                 (stringAppend
                   "Can't find path file "
                   (stringAppend filename
                     ".
Try setting environment variable GEOMDATA.
"))
             exited = exitProcess 0
         in record state {
              whichPath = path ;
              pathFile = nothing ;
              quitting = true
            }
       (just handle) →
         let rewound = rewindFile handle
             fov = emit " (merge camera c0 {fov 100})
"
         in record state {
              whichPath = path ;
              pathFile = just handle
            }

SpeedProc : FlythroughState → Nat → FlythroughState
SpeedProc state value =
  PathProc (record state { speed = value }) (whichPath state)

GoProc : FlythroughState → Bool → FlythroughState
GoProc state value = record state { go = value }

initGeomview : Unit
initGeomview =
  let a = emit "(progn 
"
      b = emit "(geometry notknot.vect { INST transforms : tile geom {"
      c = emit "    INST geom < dodec.vect transform : scale}})
"
      d = emit " (space hyperbolic) (bbox-draw allgeoms off)
"
      e = emit " (backcolor c0 0 0 0)
"
      f = emit " (merge camera c0 {fov 100})
"
      g = emit " (merge-ap notknot.vect {linewidth 2})
"
      h = emit " (load-path (. $GEOMDATA $GEOMDATA/geom $GEOMDATA/groups))
"
      i = emit " (echo 'caughtup
')
"
      j = emit ")
"
  in tt

init : FlythroughState
init =
  let setup = initGeomview
      scaled = ScaleProc 0.99
      state0 = record initialState { dodecScale = first scaled }
      state1 = SpeedProc state0 2
      state2 = PathProc state1 LOOP
      tiled = TilingProc 2
  in state2

todemogv : String
todemogv =
  "togeomview -c flythrough  geomview -nopanels -wpos 200x200@559,535 flythrough_diagram.gv"

InfoProc : FlythroughState → FlythroughState
InfoProc state =
  let command = stringAppend todemogv " < /dev/null&"
      launched = runSystem command
  in record state { helpWindowId = 1 }

DiagProc : DiagramSpace → Unit
DiagProc EUC =
  runSystem
    (stringAppend
      "echo '(space euclidean)' | "
      (stringAppend todemogv " &"))
DiagProc HYP =
  runSystem
    (stringAppend
      "echo '(space hyperbolic)' | "
      (stringAppend todemogv " &"))

DoneProc : FlythroughState → FlythroughState
DoneProc state =
  let command =
        stringAppend "echo '(exit)' | "
          (stringAppend todemogv " &")
      stopped = runSystem command
  in record state { helpWindowId = 0 }

QuitProc : FlythroughState → FlythroughState
QuitProc state =
  let done = DoneProc state
      exited = exitProcess 0
  in record done { quitting = true }

-- main.c copies exactly 18 lines from each precomputed camera command because
-- those files came from Mathematica.  EOF rewinds and breaks the 18-line loop.
copyEighteenLines : FileHandle → Nat → Bool
copyEighteenLines file 0 = false
copyEighteenLines file (suc remaining) with readLine file
... | nothing =
  let rewound = rewindFile file
  in true
... | just line =
  let printed = emit line
  in copyEighteenLines file remaining

playOneCommand : FlythroughState → FlythroughState
playOneCommand state with pathFile state
... | nothing = state
... | just file =
  let ended = copyEighteenLines file 18
      caught =
        if turboActive state
          then tt
          else emit "(echo 'caughtup
')
"
  in state

mainLoopStep : FlythroughState → FlythroughState
mainLoopStep state =
  let checked = checkForms tt
      permitted =
        go state &&
        (turboActive state || stdinCaughtUp)
  in if permitted then playOneCommand state else state

mainLoop : FlythroughState → FlythroughState
{-# TERMINATING #-}
mainLoop state =
  if quitting state
    then state
    else mainLoop (mainLoopStep state)

parseArguments : List String → FlythroughState → FlythroughState
parseArguments [] state = state
parseArguments (argument ∷ rest) state =
  if stringEq argument "-t"
    then parseArguments rest (record state { turbo = just true })
    else if stringEq argument "-h"
      then parseArguments rest (InfoProc state)
      else parseArguments rest state

main : List String → FlythroughState
main arguments =
  mainLoop (parseArguments arguments init)
