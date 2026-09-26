module GeometryCenter.DiscGrp.OutStack where

open import GeometryCenter.Prelude
open import GeometryCenter.Types

record OutStackState : Set where
  constructor outStackState
  field
    blockSize : Nat
    arraySize : Nat
    stack : List DiscGrpEl
    count : Nat
open OutStackState public

init-out-stack : OutStackState
init-out-stack = outStackState 1024 1 [] 0

enumpush : OutStackState → DiscGrpEl → OutStackState
enumpush state element =
  let nextCount = suc (count state)
      capacity = blockSize state * arraySize state
      nextArraySize =
        if natLess capacity nextCount
          then arraySize state * 2
          else arraySize state
  in outStackState
       (blockSize state)
       nextArraySize
       (stack state ++ (element ∷ []))
       nextCount

enumgetsize : OutStackState → Nat
enumgetsize = count

enumgetstack : OutStackState → List DiscGrpEl
enumgetstack = stack
