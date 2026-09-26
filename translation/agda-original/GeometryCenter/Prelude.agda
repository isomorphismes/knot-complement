module GeometryCenter.Prelude where

open import Agda.Builtin.Bool public
open import Agda.Builtin.Char public
open import Agda.Builtin.Float public
open import Agda.Builtin.Int public
open import Agda.Builtin.List public
open import Agda.Builtin.Maybe public
open import Agda.Builtin.Nat public
open import Agda.Builtin.Sigma public
open import Agda.Builtin.String public
open import Agda.Builtin.Unit public

data Either (A B : Set) : Set where
  left  : A → Either A B
  right : B → Either A B

case_of_ : {A B : Set} → A → (A → B) → B
case value of function = function value

record Pair (A B : Set) : Set where
  constructor _,_
  field
    first : A
    second : B

open Pair public

if_then_else_ : {A : Set} → Bool → A → A → A
if true then yes else no = yes
if false then yes else no = no

not : Bool → Bool
not true = false
not false = true

_&&_ : Bool → Bool → Bool
true && value = value
false && value = false

_||_ : Bool → Bool → Bool
true || value = true
false || value = value

length : {A : Set} → List A → Nat
length [] = 0
length (_ ∷ xs) = suc (length xs)

_++_ : {A : Set} → List A → List A → List A
[] ++ ys = ys
(x ∷ xs) ++ ys = x ∷ (xs ++ ys)

map : {A B : Set} → (A → B) → List A → List B
map f [] = []
map f (x ∷ xs) = f x ∷ map f xs

foldl : {A B : Set} → (B → A → B) → B → List A → B
foldl f state [] = state
foldl f state (x ∷ xs) = foldl f (f state x) xs

reverse : {A : Set} → List A → List A
reverse = foldl (λ xs x → x ∷ xs) []

zipWith : {A B C : Set} → (A → B → C) → List A → List B → List C
zipWith f [] ys = []
zipWith f xs [] = []
zipWith f (x ∷ xs) (y ∷ ys) = f x y ∷ zipWith f xs ys

replicate : {A : Set} → Nat → A → List A
replicate 0 value = []
replicate (suc n) value = value ∷ replicate n value

lookup : {A : Set} → List A → Nat → Maybe A
lookup [] n = nothing
lookup (x ∷ xs) 0 = just x
lookup (x ∷ xs) (suc n) = lookup xs n

replaceAt : {A : Set} → Nat → A → List A → List A
replaceAt n value [] = []
replaceAt 0 value (x ∷ xs) = value ∷ xs
replaceAt (suc n) value (x ∷ xs) = x ∷ replaceAt n value xs

removeAt : {A : Set} → Nat → List A → List A
removeAt n [] = []
removeAt 0 (x ∷ xs) = xs
removeAt (suc n) (x ∷ xs) = x ∷ removeAt n xs

enumerateFrom : {A : Set} → Nat → List A → List (Pair Nat A)
enumerateFrom n [] = []
enumerateFrom n (x ∷ xs) = (n , x) ∷ enumerateFrom (suc n) xs

enumerate : {A : Set} → List A → List (Pair Nat A)
enumerate = enumerateFrom 0

rangeFrom : Nat → Nat → List Nat
rangeFrom start 0 = []
rangeFrom start (suc count) = start ∷ rangeFrom (suc start) count

range : Nat → List Nat
range count = rangeFrom 0 count

headMaybe : {A : Set} → List A → Maybe A
headMaybe [] = nothing
headMaybe (x ∷ xs) = just x

lastMaybe : {A : Set} → List A → Maybe A
lastMaybe [] = nothing
lastMaybe (x ∷ []) = just x
lastMaybe (x ∷ y ∷ ys) = lastMaybe (y ∷ ys)

filter : {A : Set} → (A → Bool) → List A → List A
filter keep [] = []
filter keep (x ∷ xs) =
  if keep x then x ∷ filter keep xs else filter keep xs

all : {A : Set} → (A → Bool) → List A → Bool
all test [] = true
all test (x ∷ xs) = test x && all test xs

any : {A : Set} → (A → Bool) → List A → Bool
any test [] = false
any test (x ∷ xs) = test x || any test xs

sumFloats : List Float → Float
sumFloats [] = 0.0
sumFloats (x ∷ xs) = x +f sumFloats xs

natEq : Nat → Nat → Bool
natEq 0 0 = true
natEq 0 (suc n) = false
natEq (suc n) 0 = false
natEq (suc n) (suc m) = natEq n m

natLess : Nat → Nat → Bool
natLess 0 0 = false
natLess 0 (suc n) = true
natLess (suc n) 0 = false
natLess (suc n) (suc m) = natLess n m

natLessOrEqual : Nat → Nat → Bool
natLessOrEqual n m = natLess n m || natEq n m

natGreater : Nat → Nat → Bool
natGreater n m = natLess m n

natGreaterOrEqual : Nat → Nat → Bool
natGreaterOrEqual n m = natLessOrEqual m n

natPred : Nat → Nat
natPred 0 = 0
natPred (suc n) = n

replaceOrAppend : {A : Set} → Nat → A → List A → List A
replaceOrAppend 0 value [] = value ∷ []
replaceOrAppend (suc n) value [] = []
replaceOrAppend 0 value (x ∷ xs) = value ∷ xs
replaceOrAppend (suc n) value (x ∷ xs) =
  x ∷ replaceOrAppend n value xs

postulate
  _+f_ _-f_ _*f_ _/f_ : Float → Float → Float
  negf absf sqrtf acoshf acosf sinf cosf : Float → Float
  atan2f : Float → Float → Float
  floatEq floatLess floatLessOrEqual : Float → Float → Bool
  natToFloat : Nat → Float
  stringEq : String → String → Bool
  stringLength : String → Nat
  stringAppend : String → String → String
  charToString : Char → String
  stringToChars : String → List Char
  charsToString : List Char → String
  charEq : Char → Char → Bool
  upperLowerMate : Char → Char
  showNat : Nat → String
  showFloat : Float → String
  showTransform : List (List Float) → String
  intEq intLess intLessOrEqual : Int → Int → Bool
  natToInt : Nat → Int
  intToNat : Int → Maybe Nat
  natMod : Nat → Nat → Nat

infixl 6 _+f_ _-f_
infixl 7 _*f_ _/f_

maxf : Float → Float → Float
maxf a b = if floatLess a b then b else a

minf : Float → Float → Float
minf a b = if floatLess a b then a else b

clampAtLeastOne : Float → Float
clampAtLeastOne value =
  if floatLess value 1.0 then 1.0 else value

postulate
  bitOr bitAnd bitXor : Nat → Nat → Nat
  bitNot : Nat → Nat
  bitShiftLeft bitShiftRight : Nat → Nat → Nat
  hasBit : Nat → Nat → Bool
