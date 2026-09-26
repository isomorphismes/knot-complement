module Recenter where

open import Agda.Builtin.Bool
open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat
open import Agda.Builtin.Sigma

data Either (A B : Set) : Set where
  left  : A → Either A B
  right : B → Either A B

data RecenterError : Set where
  space-has-no-neighbors : RecenterError
  singular-transform : RecenterError
  search-did-not-converge : RecenterError

record Geometry
  (Point Transform Scalar : Set) : Set where
  field
    identity-transform : Transform
    apply-transform : Point → Transform → Point
    compose-transform : Transform → Transform → Transform
    inverse-transform : Transform → Maybe Transform
    distance-between : Point → Point → Scalar
    less-than : Scalar → Scalar → Bool
    tune-transform : Transform → Transform

open Geometry

record Space (Point Transform : Set) : Set where
  constructor quotient-space
  field
    center : Point
    -- The identity copy is first, matching DiscGrpExtractNhbrs.
    neighbors : List Transform

open Space

record NearestCopy (Transform : Set) : Set where
  constructor found-copy
  field
    group-transform : Transform
    crossing-count : Nat

open NearestCopy

record RecenteredCamera (Transform : Set) : Set where
  constructor camera-in-base-copy
  field
    camera-to-world : Transform
    crossed-group-transform : Transform
    recentered-crossing-count : Nat

recenter-search-limit : Nat
recenter-search-limit = 1000

record Candidate (Transform Scalar : Set) : Set where
  constructor candidate
  field
    index : Nat
    transform : Transform
    distance : Scalar

open Candidate

nearest-neighbor :
  {Point Transform Scalar : Set} →
  Geometry Point Transform Scalar →
  Space Point Transform →
  Point →
  Either RecenterError (Candidate Transform Scalar)
nearest-neighbor geometry space point with neighbors space
... | [] = left space-has-no-neighbors
... | first ∷ rest =
  right (choose-rest 1 initial rest)
  where
    distance-to : Transform → Scalar
    distance-to mapping =
      distance-between geometry
        point
        (apply-transform geometry (center space) mapping)

    initial : Candidate Transform Scalar
    initial = candidate 0 first (distance-to first)

    choose-rest :
      Nat → Candidate Transform Scalar → List Transform → Candidate Transform Scalar
    choose-rest next best [] = best
    choose-rest next best (mapping ∷ more)
      with less-than geometry (distance-to mapping) (distance best)
    ... | true =
      choose-rest (suc next)
        (candidate next mapping (distance-to mapping))
        more
    ... | false =
      choose-rest (suc next) best more

find-nearest-copy :
  {Point Transform Scalar : Set} →
  Geometry Point Transform Scalar →
  Space Point Transform →
  Point →
  Either RecenterError (NearestCopy Transform)
find-nearest-copy geometry space original =
  search
    recenter-search-limit
    original
    (identity-transform geometry)
    0
  where
    search :
      Nat →
      Point →
      Transform →
      Nat →
      Either RecenterError (NearestCopy Transform)
    search zero current accumulated crossings =
      left search-did-not-converge
    search (suc fuel) current accumulated crossings
      with nearest-neighbor geometry space current
    ... | left problem = left problem
    ... | right nearest with index nearest
    ...   | zero = right (found-copy accumulated crossings)
    ...   | suc _ =
      let next =
            compose-transform geometry
              (transform nearest)
              accumulated
      in
      helper fuel next crossings
      where
        helper :
          Nat → Transform → Nat →
          Either RecenterError (NearestCopy Transform)
        helper fuel next crossings
          with inverse-transform geometry next
        ... | nothing = left singular-transform
        ... | just next-inverse =
          search
            fuel
            (apply-transform geometry original next-inverse)
            next
            (suc crossings)

recenter-camera :
  {Point Transform Scalar : Set} →
  Geometry Point Transform Scalar →
  Space Point Transform →
  Point →
  Transform →
  Transform →
  Either RecenterError (RecenteredCamera Transform)
recenter-camera geometry space origin camera-to-world₀ model-to-world
  with inverse-transform geometry camera-to-world₀
... | nothing = left singular-transform
... | just world-to-camera
  with inverse-transform geometry model-to-world
...   | nothing = left singular-transform
...   | just world-to-model =
  continue-camera world-to-model
    (compose-transform geometry model-to-world world-to-camera)
  where
    continue-camera :
      Transform →
      Transform →
      Either RecenterError (RecenteredCamera Transform)
    continue-camera world-to-model model-to-camera
      with inverse-transform geometry model-to-camera
    ... | nothing = left singular-transform
    ... | just camera-to-model
      with find-nearest-copy geometry space
             (apply-transform geometry origin camera-to-model)
    ...   | left problem = left problem
    ...   | right nearest
      with inverse-transform geometry (group-transform nearest)
    ...     | nothing = left singular-transform
    ...     | just inverse-group =
      let group-in-world =
            compose-transform geometry
              world-to-model
              (compose-transform geometry inverse-group model-to-world)

          moved-camera =
            compose-transform geometry
              camera-to-world₀
              group-in-world
      in
      right
        (camera-in-base-copy
          (tune-transform geometry moved-camera)
          (group-transform nearest)
          (crossing-count nearest))
