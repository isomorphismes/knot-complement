module GeometryCenter.Flythrough.Panel where

open import GeometryCenter.Prelude

data FormName : Set where
  MainForm HelpForm : FormName

data ObjectKind : Set where
  Box Text Button RoundButton Slider Browser : ObjectKind

record FormObjectSpec : Set where
  constructor objectSpec
  field
    objectName : String
    objectKind : ObjectKind
    x y width height : Nat
    label : String
    callback : Maybe String
    callbackArgument : Maybe String
    properties : List String
open FormObjectSpec public

mainObjects : List FormObjectSpec
mainObjects =
  objectSpec "background" Box 0 0 240 340 "" nothing nothing
    ("up-box" ∷ []) ∷
  objectSpec "DodecScale" Slider 10 313 226 22 "Scale Dodecahedron"
    (just "ScaleProc") (just "0")
    ("horizontal-slider" ∷ "align-top" ∷ "bold" ∷ []) ∷
  objectSpec "heading" Text 0 25 245 20 "Interactive Hyperbolic Flythrough"
    nothing nothing ("blue" ∷ "center" ∷ "bold" ∷ []) ∷
  objectSpec "layers-label" Text 0 215 80 30 "LAYERS"
    nothing nothing ("center" ∷ "bold" ∷ []) ∷
  objectSpec "path-label" Text 5 140 230 15 "PATH"
    nothing nothing ("center" ∷ "bold" ∷ []) ∷
  objectSpec "Quit" Button 190 50 40 30 "Quit"
    (just "QuitProc") (just "0") [] ∷
  objectSpec "separator-285" Box 0 285 245 5 ""
    nothing nothing ("shadow-box" ∷ "blue" ∷ []) ∷
  objectSpec "separator-210" Box 0 210 245 5 ""
    nothing nothing ("shadow-box" ∷ "blue" ∷ []) ∷
  objectSpec "Info" Button 10 50 170 30 "What's going on?"
    (just "InfoProc") (just "0") ("push" ∷ []) ∷
  objectSpec "separator-130" Box 0 130 245 5 ""
    nothing nothing ("shadow-box" ∷ "blue" ∷ []) ∷
  objectSpec "Direct" RoundButton 125 150 30 30 "Direct"
    (just "PathProc") (just "DIRECT")
    ("radio" ∷ "white-yellow" ∷ "label-color-223" ∷ "bold" ∷ []) ∷
  objectSpec "Equi" RoundButton 125 175 30 30 "Equidistant"
    (just "PathProc") (just "EQUI")
    ("radio" ∷ "white-yellow" ∷ "label-color-248" ∷ "bold" ∷ []) ∷
  objectSpec "Quarter" RoundButton 5 175 30 30 "Quarter Turn"
    (just "PathProc") (just "QUARTER")
    ("radio" ∷ "white-yellow" ∷ "label-color-135" ∷ "bold" ∷ []) ∷
  objectSpec "Loop" RoundButton 5 150 30 30 "Full Loop"
    (just "PathProc") (just "LOOP")
    ("radio" ∷ "white-yellow" ∷ "label-color-135" ∷ "bold" ∷ []) ∷
  objectSpec "steps-label" Text 0 255 60 30 "STEPS"
    nothing nothing ("center" ∷ "bold" ∷ []) ∷
  objectSpec "separator-248" Box 0 248 245 5 ""
    nothing nothing ("shadow-box" ∷ "blue" ∷ []) ∷
  objectSpec "Go" RoundButton 20 88 55 45 "GO"
    (just "GoProc") (just "1")
    ("radio" ∷ "white-green" ∷ "green-label" ∷ "large" ∷ "bold" ∷ []) ∷
  objectSpec "Stop" RoundButton 110 88 55 45 "STOP"
    (just "GoProc") (just "0")
    ("radio" ∷ "white-red" ∷ "red-label" ∷ "large" ∷ "bold" ∷ []) ∷
  objectSpec "Level3" RoundButton 195 215 30 30 "3"
    (just "TilingProc") (just "3") ("radio" ∷ "white-yellow" ∷ []) ∷
  objectSpec "Level2" RoundButton 155 215 30 30 "2"
    (just "TilingProc") (just "2") ("radio" ∷ "white-yellow" ∷ []) ∷
  objectSpec "Level1" RoundButton 115 215 30 30 "1"
    (just "TilingProc") (just "1") ("radio" ∷ "white-yellow" ∷ []) ∷
  objectSpec "Level0" RoundButton 75 215 30 30 "0"
    (just "TilingProc") (just "0") ("radio" ∷ "white-yellow" ∷ []) ∷
  objectSpec "Speed2" RoundButton 100 255 30 30 "20"
    (just "SpeedProc") (just "2") ("radio" ∷ "white-yellow" ∷ []) ∷
  objectSpec "Speed3" RoundButton 145 255 30 30 "40"
    (just "SpeedProc") (just "3") ("radio" ∷ "white-yellow" ∷ []) ∷
  objectSpec "Speed4" RoundButton 190 255 30 30 "80"
    (just "SpeedProc") (just "4") ("radio" ∷ "white-yellow" ∷ []) ∷
  objectSpec "Speed1" RoundButton 55 255 30 30 "10"
    (just "SpeedProc") (just "1") ("radio" ∷ "white-yellow" ∷ []) ∷
  objectSpec "title" Text 5 5 240 20 "Not Knot: The Software"
    nothing nothing ("blue" ∷ "center" ∷ "bold" ∷ []) ∷
  objectSpec "separator-84" Box 0 84 245 5 ""
    nothing nothing ("shadow-box" ∷ "blue" ∷ []) ∷ []

helpObjects : List FormObjectSpec
helpObjects =
  objectSpec "background" Box 0 0 530 340 "" nothing nothing
    ("up-box" ∷ []) ∷
  objectSpec "HelpBrowser" Browser 10 35 510 275 ""
    nothing nothing [] ∷
  objectSpec "title" Text 10 10 435 20
    "Not Knot: The Software   Interactive Hyperbolic Flythrough"
    nothing nothing ("blue" ∷ "left" ∷ "bold" ∷ []) ∷
  objectSpec "Done" Button 455 10 60 20 "Done"
    (just "DoneProc") (just "0") [] ∷
  objectSpec "EucDiag" Button 95 310 140 25 "Euclidean Diagram"
    (just "DiagProc") (just "EUC") ("radio" ∷ []) ∷
  objectSpec "HypDiag" Button 305 310 150 25 "Hyperbolic Diagram"
    (just "DiagProc") (just "HYP") ("radio" ∷ []) ∷ []

record FormSpec : Set where
  constructor formSpec
  field
    formName : FormName
    formWidth formHeight : Nat
    formObjects : List FormObjectSpec
open FormSpec public

create-form-MainForm : FormSpec
create-form-MainForm = formSpec MainForm 240 340 mainObjects

create-form-HelpForm : FormSpec
create-form-HelpForm = formSpec HelpForm 530 340 helpObjects

create-the-forms : List FormSpec
create-the-forms =
  create-form-MainForm ∷ create-form-HelpForm ∷ []
