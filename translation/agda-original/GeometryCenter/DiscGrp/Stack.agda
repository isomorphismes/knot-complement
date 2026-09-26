module GeometryCenter.DiscGrp.Stack where

open import GeometryCenter.Prelude

CHUNKSIZE : Nat
CHUNKSIZE = 10000

record WordStackState : Set where
  constructor wordStackState
  field
    storage : List String
    oldIndex : Nat
    oldTop : Nat
    oldBase : Nat
    newIndex : Nat
    numberOfChunks : Nat
open WordStackState public

init-stack : WordStackState
init-stack =
  wordStackState [] 0 0 0 0 1

make-new-old : WordStackState → WordStackState
make-new-old state =
  let nextOldBase = suc (oldTop state)
      nextOldTop = natPred (newIndex state)
  in wordStackState
       (storage state)
       nextOldTop
       nextOldTop
       nextOldBase
       (newIndex state)
       (numberOfChunks state)

pop-old-stack : WordStackState → Pair WordStackState (Maybe String)
pop-old-stack state =
  if natGreaterOrEqual (oldIndex state) (oldBase state)
    then
      let found = lookup (storage state) (oldIndex state)
      in wordStackState
           (storage state)
           (natPred (oldIndex state))
           (oldTop state)
           (oldBase state)
           (newIndex state)
           (numberOfChunks state) , found
    else state , nothing

push-new-stack : WordStackState → String → WordStackState
push-new-stack state word =
  let required = suc (newIndex state)
      capacity = CHUNKSIZE * (numberOfChunks state)
      chunks =
        if natLess capacity required
          then numberOfChunks state * 2
          else numberOfChunks state
      nextStorage =
        if natEq (newIndex state) (length (storage state))
          then storage state ++ (word ∷ [])
          else replaceOrAppend (newIndex state) word (storage state)
  in wordStackState
       nextStorage
       (oldIndex state)
       (oldTop state)
       (oldBase state)
       required
       chunks
