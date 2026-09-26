module GeometryCenter.DiscGrp.Colormap where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy

builtin : List ColorA
builtin =
  rgba 0.8 0.1 0.1 0.75 ∷
  rgba 0.1 0.65 0.4 0.75 ∷
  rgba 0.1 0.1 0.8 0.75 ∷
  rgba 0.9 0.6 0.0 0.75 ∷
  rgba 0.0 0.6 0.8 0.75 ∷
  rgba 0.5 0.0 0.9 0.75 ∷
  rgba 0.7 0.15 0.1 0.75 ∷
  rgba 0.2 0.2 0.8 0.75 ∷
  rgba 0.9 0.6 0.02 0.75 ∷
  rgba 0.1 0.3 0.8 0.75 ∷
  rgba 0.1 0.7 0.2 0.75 ∷
  rgba 0.8 0.8 0.4 0.75 ∷
  rgba 0.7 0.7 0.0 0.75 ∷
  rgba 0.7 0.0 0.7 0.75 ∷
  rgba 0.0 0.7 0.7 0.75 ∷
  rgba 0.9 0.0 0.2 0.75 ∷
  rgba 0.2 0.9 0.0 0.75 ∷
  rgba 0.0 0.2 0.9 0.75 ∷
  rgba 0.75 0.75 0.75 0.75 ∷
  rgba 0.8 0.4 0.0 0.75 ∷
  rgba 0.8 0.4 0.0 0.75 ∷
  rgba 0.0 0.4 0.8 0.75 ∷
  rgba 0.0 0.4 0.8 0.75 ∷
  rgba 0.0 0.8 0.4 0.75 ∷
  rgba 0.0 0.8 0.4 0.75 ∷
  rgba 0.4 0.0 0.8 0.75 ∷ []

record ColorMapState : Set where
  constructor colorMapState
  field
    colors : List ColorA
    doneRead : Bool
open ColorMapState public

initialColorMap : ColorMapState
initialColorMap = colorMapState builtin false

default-name : String
default-name = "sample.cmap"

chooseColorMapName : Maybe String → Maybe String
chooseColorMapName (just name) = just name
chooseColorMapName nothing with environment "CMAP_FILE"
... | just name = just name
... | nothing = findFile nothing default-name

readcmap : Maybe String → ColorMapState
readcmap requested with chooseColorMapName requested
... | nothing = colorMapState builtin true
... | just name with loadColorMap name
...   | nothing = colorMapState builtin true
...   | just loaded = colorMapState loaded true

GetCmapEntry : Nat → ColorMapState → Pair ColorMapState ColorA
GetCmapEntry n state =
  let current =
        if doneRead state
          then state
          else readcmap nothing
  in case lookup (colors current) n of λ where
       nothing →
         case headMaybe (colors current) of λ where
           nothing → current , rgba 0.8 0.1 0.1 0.75
           (just firstColor) → current , firstColor
       (just color) → current , color
