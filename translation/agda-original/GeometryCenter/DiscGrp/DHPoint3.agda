module GeometryCenter.DiscGrp.DHPoint3 where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.DiscGrp.Flags

x y z w : Point4 → Float
x p = pointEntry p 0
y p = pointEntry p 1
z p = pointEntry p 2
w p = pointEntry p 3

dot3 : Point4 → Point4 → Float
dot3 a b =
  x a *f x b +f y a *f y b +f z a *f z b

dot4 : Point4 → Point4 → Float
dot4 a b = dot3 a b +f w a *f w b

dot31 : Point4 → Point4 → Float
dot31 a b = dot3 a b -f w a *f w b

subtract3 : Point4 → Point4 → Point4
subtract3 a b =
  makePoint4
    (x a -f x b)
    (y a -f y b)
    (z a -f z b)
    1.0

subtract4 : Point4 → Point4 → Point4
subtract4 a b =
  makePoint4
    (x a -f x b)
    (y a -f y b)
    (z a -f z b)
    (w a -f w b)

add3 : Point4 → Point4 → Point4
add3 a b =
  makePoint4
    (x a +f x b)
    (y a +f y b)
    (z a +f z b)
    1.0

scale3 : Point4 → Float → Point4
scale3 a scalar =
  makePoint4 (scalar *f x a) (scalar *f y a) (scalar *f z a) (w a)

scale4 : Point4 → Float → Point4
scale4 a scalar =
  makePoint4
    (scalar *f x a)
    (scalar *f y a)
    (scalar *f z a)
    (scalar *f w a)

magnitude3 : Point4 → Float
magnitude3 a = sqrtf (dot3 a a)

normalize31 : Point4 → Point4
normalize31 a =
  let value = dot31 a a in
  if floatEq value 0.0
    then a
    else scale4 a (1.0 /f sqrtf (absf value))

normalize4 : Point4 → Point4
normalize4 a =
  let value = dot4 a a in
  if floatEq value 0.0
    then a
    else scale4 a (1.0 /f sqrtf (absf value))

DHPt3Dot : Point4 → Point4 → Nat → Float
DHPt3Dot v0 v1 metric =
  if natEq metric DG-HYPERBOLIC
    then dot31 v0 v1
    else dot4 v0 v1

DHPt3Dot3 : Point4 → Point4 → Nat → Float
DHPt3Dot3 v0 v1 metric =
  if natEq metric DG-EUCLIDEAN
    then dot3 v0 v1
    else if natEq metric DG-HYPERBOLIC
      then dot31 v0 v1
      else dot4 v0 v1

DHPt3Distance : Point4 → Point4 → Nat → Float
DHPt3Distance p0 p1 metric =
  if natEq metric DG-EUCLIDEAN
    then magnitude3 (subtract3 p0 p1)
    else if natEq metric DG-HYPERBOLIC
      then
        let d0 = dot31 p0 p0
            d1 = dot31 p1 p1
        in if floatLessOrEqual 0.0 d0 || floatLessOrEqual 0.0 d1
             then 0.0
             else
               acoshf
                 (clampAtLeastOne
                   (absf (dot31 p0 p1 /f sqrtf (d0 *f d1))))
      else
        let d0 = dot31 p0 p0
            d1 = dot31 p1 p1
        in acosf
             (absf (dot4 p0 p1 /f sqrtf (d0 *f d1)))

DHPt3PerpBisect : Point4 → Point4 → Nat → Point4
DHPt3PerpBisect p0 p1 metric =
  if natEq metric DG-EUCLIDEAN
    then
      let result0 = subtract3 p1 p0
          midpoint = scale3 (add3 p0 p1) 0.5
      in makePoint4
           (x result0)
           (y result0)
           (z result0)
           (negf (dot3 midpoint result0))
    else if natEq metric DG-HYPERBOLIC
      then
        let q0 = normalize31 p0
            q1 = normalize31 p1
            difference = subtract4 q0 q1
        in if floatLess 0.0 (dot31 q0 difference)
             then scale4 difference (negf 1.0)
             else difference
      else
        let q0 = normalize4 p0
            q1 = normalize4 p1
            difference = subtract4 q0 q1
        in if floatLess 0.0 (dot4 q0 difference)
             then scale4 difference (negf 1.0)
             else difference
