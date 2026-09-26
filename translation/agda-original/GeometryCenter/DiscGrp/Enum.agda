module GeometryCenter.DiscGrp.Enum where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags
open import GeometryCenter.DiscGrp.Create
open import GeometryCenter.DiscGrp.MatList
open import GeometryCenter.DiscGrp.Stack
open import GeometryCenter.DiscGrp.OutStack

ConstraintFn : Set
ConstraintFn = DiscGrpEl → Nat

record EnumState : Set where
  constructor enumState
  field
    currentGroup : DiscGrp
    constraintFunction : ConstraintFn
    checkNew : Bool
    haveMatrices : Bool
    enumMetric : Nat
    enumStringent : Bool
    longCount sameCount farCount printCount storeCount : Nat
    generatorCount : Nat
    symbols : List Char
    matrices : List Transform
    matrixState : MatListState
    wordState : WordStackState
    outputState : OutStackState
open EnumState public

setMatrixState : EnumState → MatListState → EnumState
setMatrixState state value = record state { matrixState = value }

setWordState : EnumState → WordStackState → EnumState
setWordState state value = record state { wordState = value }

setOutputState : EnumState → OutStackState → EnumState
setOutputState state value = record state { outputState = value }

matContext : EnumState → MatListContext
matContext state =
  matListContext 0 (enumStringent state) (enumMetric state)

incrementCounters : EnumState → Nat → EnumState
incrementCounters state bits =
  record state {
    longCount =
      if hasBit bits DG-CONSTRAINT-LONG
        then suc (longCount state) else longCount state ;
    printCount =
      if hasBit bits DG-CONSTRAINT-PRINT
        then suc (printCount state) else printCount state ;
    storeCount =
      if hasBit bits DG-CONSTRAINT-STORE
        then suc (storeCount state) else storeCount state ;
    farCount =
      if hasBit bits DG-CONSTRAINT-TOOFAR
        then suc (farCount state) else farCount state
  }

getindex : EnumState → Char → Maybe Nat
getindex state symbol =
  findIndex 0 (symbols state)
  where
    findIndex : Nat → List Char → Maybe Nat
    findIndex index [] = nothing
    findIndex index (candidate ∷ rest) =
      if charEq symbol candidate
        then just index
        else findIndex (suc index) rest

word-to-mat : EnumState → String → Transform
word-to-mat state word =
  foldl step transformIdentity (stringToChars word)
  where
    step : Transform → Char → Transform
    step current symbol with getindex state symbol
    ... | nothing = current
    ... | just index with lookup (matrices state) index
    ...   | nothing = current
    ...   | just generator = transformConcat current generator

is-big-and-new :
  EnumState →
  DiscGrpEl →
  Pair EnumState Nat
is-big-and-new state element =
  let newBits =
        if checkNew state
          then is-new (matContext state) (matrixState state)
                      (elementTransform element)
          else DG-CONSTRAINT-NEW
  in if hasBit newBits DG-CONSTRAINT-NEW
       then
         let constraintBits = constraintFunction state element
             counted = incrementCounters state constraintBits
         in counted , bitOr constraintBits newBits
       else
         record state { sameCount = suc (sameCount state) } , newBits

process :
  EnumState →
  DiscGrpEl →
  Bool →
  Pair EnumState Nat
process state element stacking =
  if not (haveMatrices state)
    then state , 0
    else
      let checked = is-big-and-new state element
          afterCheck = first checked
          bits = second checked
      in if not (hasBit bits DG-CONSTRAINT-NEW)
           then afterCheck , bits
           else if hasBit bits DG-CONSTRAINT-LONG
             then afterCheck , bits
             else if not
                    (hasBit bits DG-CONSTRAINT-STORE ||
                     hasBit bits DG-CONSTRAINT-PRINT)
               then afterCheck , bits
               else
                 let afterInsert =
                       if checkNew afterCheck
                         then
                           let inserted =
                                 insert-or-match-mat
                                   (matContext afterCheck)
                                   (matrixState afterCheck)
                                   (elementTransform element)
                                   INSERT
                               withMatrix =
                                 setMatrixState afterCheck (first inserted)
                           in if stacking
                                then setWordState withMatrix
                                       (push-new-stack
                                         (wordState withMatrix)
                                         (elementWord element))
                                else withMatrix
                         else afterCheck
                     afterPrint =
                       if hasBit bits DG-CONSTRAINT-PRINT
                         then setOutputState afterInsert
                                (enumpush (outputState afterInsert) element)
                         else afterInsert
                 in afterPrint , bits

waAction : WordAcceptor → Nat → Nat → Maybe Nat
waAction automaton state column with lookup (waActions automaton) state
... | nothing = nothing
... | just row = lookup row column

replaceCharAt : Nat → Char → String → String
replaceCharAt position value word =
  charsToString (replaceOrAppend position value (stringToChars word))

terminateAfter : Nat → String → String
terminateAfter position word =
  -- C writes NUL at depth+1.  Agda String is already length-delimited,
  -- so truncating to the prefix is the corresponding operation.
  charsToString (takePrefix (suc position) (stringToChars word))
  where
    takePrefix : Nat → List Char → List Char
    takePrefix 0 chars = []
    takePrefix (suc n) [] = []
    takePrefix (suc n) (c ∷ cs) = c ∷ takePrefix n cs

setWordChar : Nat → Char → DiscGrpEl → DiscGrpEl
setWordChar position symbol element =
  let changed = replaceCharAt position symbol (elementWord element)
  in record element {
       elementWord = terminateAfter position changed
     }

refreshElementMatrix : EnumState → DiscGrpEl → DiscGrpEl
refreshElementMatrix state element =
  record element {
    elementTransform = word-to-mat state (elementWord element)
  }

mutual
  enumerate-fsa :
    WordAcceptor →
    Nat →
    Nat →
    DiscGrpEl →
    EnumState →
    EnumState
  enumerate-fsa automaton automatonState depth element state =
    let processed = process state element false
        afterProcess = first processed
        bits = second processed
    in if not (hasBit bits DG-CONSTRAINT-STORE)
         then afterProcess
         else if hasBit bits DG-CONSTRAINT-MAXLEN
           then afterProcess
           else if natLess MAXDEPTH depth
             then afterProcess
             else
               enumerateGenerators
                 automaton
                 automatonState
                 depth
                 element
                 afterProcess
                 (enumerateFrom 1 (waGenerators automaton))

  enumerateGenerators :
    WordAcceptor →
    Nat →
    Nat →
    DiscGrpEl →
    EnumState →
    List (Pair Nat Char) →
    EnumState
  enumerateGenerators automaton automatonState depth element state [] = state
  enumerateGenerators automaton automatonState depth element state (entry ∷ rest)
    with waAction automaton automatonState (first entry)
  ... | nothing =
    enumerateGenerators automaton automatonState depth element state rest
  ... | just nextState =
    if natEq nextState (waFail automaton)
      then enumerateGenerators automaton automatonState depth element state rest
      else
        let withWord = setWordChar depth (second entry) element
            withMatrix = refreshElementMatrix state withWord
            afterChild =
              enumerate-fsa automaton nextState (suc depth) withMatrix state
        in enumerateGenerators
             automaton automatonState depth element afterChild rest

processGeneratorWords :
  Nat →
  String →
  EnumState →
  List (Pair Nat Char) →
  EnumState
processGeneratorWords depth baseWord state [] = state
processGeneratorWords depth baseWord state (entry ∷ rest) =
  let template =
        discGrpEl
          (groupAttributes (currentGroup state))
          baseWord
          transformIdentity
          (rgba 1.0 1.0 1.0 0.75)
          nothing
      withWord = setWordChar depth (second entry) template
      withMatrix = refreshElementMatrix state withWord
      processed = process state withMatrix true
  in processGeneratorWords depth baseWord (first processed) rest

drainOldWords : Nat → EnumState → EnumState
drainOldWords depth state =
  let popped = pop-old-stack (wordState state)
      afterPop = setWordState state (first popped)
  in case second popped of λ where
       nothing → afterPop
       (just word) →
         drainOldWords depth
           (processGeneratorWords
             depth
             word
             afterPop
             (enumerate (symbols afterPop)))

dumb-enumerate-depths : Nat → EnumState → EnumState
dumb-enumerate-depths 0 state = state
dumb-enumerate-depths (suc remaining) state =
  let depth = natSub MAXDEPTH remaining
      prepared = setWordState state (make-new-old (wordState state))
      drained = drainOldWords depth prepared
  in dumb-enumerate-depths remaining drained


dumb-enumerate : DiscGrpEl → EnumState → EnumState
dumb-enumerate element state =
  let reset = setWordState state init-stack
      firstProcess = process reset element true
  in dumb-enumerate-depths MAXDEPTH (first firstProcess)

get-matrices : DiscGrp → Pair (List Char) (List Transform)
get-matrices dg =
  case groupGenerators dg of λ where
    nothing → [] , []
    (just generators) →
      let es = elements generators
      in map firstCharacter es , map elementTransform es
  where
    firstCharacter : DiscGrpEl → Char
    firstCharacter element with stringToChars (elementWord element)
    ... | [] = ' '
    ... | c ∷ cs = c

initialEnumState : DiscGrp → ConstraintFn → EnumState
initialEnumState dg constraint =
  let extracted = get-matrices dg
      generatorTotal =
        case groupGenerators dg of λ where
          nothing → 0
          (just generators) → length (elements generators)
  in enumState
       dg
       constraint
       true
       true
       (bitAnd (groupAttributes dg) DG-METRIC-BITS)
       false
       0 0 0 0 0
       generatorTotal
       (first extracted)
       (second extracted)
       emptyState
       init-stack
       init-out-stack

DiscGrpEnum :
  DiscGrp →
  ConstraintFn →
  DiscGrpElList
DiscGrpEnum dg constraint =
  let initial = initialEnumState dg constraint
      identityElement =
        discGrpEl
          (groupAttributes dg)
          ""
          transformIdentity
          (rgba 1.0 1.0 1.0 0.75)
          nothing
      enumerated =
        case groupWordAcceptor dg of λ where
          nothing → dumb-enumerate identityElement initial
          (just automaton) →
            enumerate-fsa automaton (waStart automaton) 0 identityElement initial
      cleaned =
        record enumerated {
          matrixState = delete-list (matrixState enumerated)
        }
  in discGrpElList defaultMatrixGroup (enumgetstack (outputState cleaned))
