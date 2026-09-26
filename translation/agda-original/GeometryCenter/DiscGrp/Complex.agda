module GeometryCenter.DiscGrp.Complex where

open import GeometryCenter.Prelude
open import GeometryCenter.Types

zeroComplex : Complex
zeroComplex = complex 0.0 0.0

oneComplex : Complex
oneComplex = complex 1.0 0.0

cplx-plus : Complex → Complex → Complex
cplx-plus z0 z1 =
  complex (real z0 +f real z1) (imag z0 +f imag z1)

cplx-minus : Complex → Complex → Complex
cplx-minus z0 z1 =
  complex (real z0 -f real z1) (imag z0 -f imag z1)

cplx-div : Complex → Complex → Complex
cplx-div z0 z1 =
  let modulus-squared =
        real z1 *f real z1 +f imag z1 *f imag z1
  in complex
       ((real z0 *f real z1 +f imag z0 *f imag z1) /f modulus-squared)
       ((imag z0 *f real z1 -f real z0 *f imag z1) /f modulus-squared)

cplx-mult : Complex → Complex → Complex
cplx-mult z0 z1 =
  complex
    (real z0 *f real z1 -f imag z0 *f imag z1)
    (real z0 *f imag z1 +f imag z0 *f real z1)

modulus : Complex → Float
modulus z =
  sqrtf (real z *f real z +f imag z *f imag z)

cplx-sqrt : Complex → Complex
cplx-sqrt z =
  let mod = sqrtf (modulus z) in
  if floatEq mod 0.0
    then zeroComplex
    else
      let arg = 0.5 *f atan2f (imag z) (real z)
      in complex (mod *f cosf arg) (mod *f sinf arg)

slEntry : SL2CMatrix → Nat → Nat → Complex
slEntry matrix row column with lookup matrix row
... | nothing = zeroComplex
... | just entries with lookup entries column
...   | nothing = zeroComplex
...   | just value = value

makeSL2C : Complex → Complex → Complex → Complex → SL2CMatrix
makeSL2C a b c d = (a ∷ b ∷ []) ∷ (c ∷ d ∷ []) ∷ []

sl2c-mult : SL2CMatrix → SL2CMatrix → SL2CMatrix
sl2c-mult a b =
  makeSL2C
    (cplx-plus (cplx-mult (slEntry a 0 0) (slEntry b 0 0))
               (cplx-mult (slEntry a 0 1) (slEntry b 1 0)))
    (cplx-plus (cplx-mult (slEntry a 0 0) (slEntry b 0 1))
               (cplx-mult (slEntry a 0 1) (slEntry b 1 1)))
    (cplx-plus (cplx-mult (slEntry a 1 0) (slEntry b 0 0))
               (cplx-mult (slEntry a 1 1) (slEntry b 1 0)))
    (cplx-plus (cplx-mult (slEntry a 1 0) (slEntry b 0 1))
               (cplx-mult (slEntry a 1 1) (slEntry b 1 1)))

sl2c-copy : SL2CMatrix → SL2CMatrix
sl2c-copy a = a

sl2c-normalize : SL2CMatrix → Maybe SL2CMatrix
sl2c-normalize a =
  let determinant =
        cplx-minus
          (cplx-mult (slEntry a 0 0) (slEntry a 1 1))
          (cplx-mult (slEntry a 0 1) (slEntry a 1 0))
  in
  if floatEq (real determinant) 0.0 && floatEq (imag determinant) 0.0
    then nothing
    else
      let argument = atan2f (imag determinant) (real determinant)
          mod = modulus determinant
          rootArgument = 0.5 *f argument
          rootModulus = sqrtf mod
          reciprocalArgument = negf rootArgument
          reciprocalModulus = 1.0 /f rootModulus
          factor =
            complex
              (reciprocalModulus *f cosf reciprocalArgument)
              (reciprocalModulus *f sinf reciprocalArgument)
      in just
           (makeSL2C
             (cplx-mult (slEntry a 0 0) factor)
             (cplx-mult (slEntry a 0 1) factor)
             (cplx-mult (slEntry a 1 0) factor)
             (cplx-mult (slEntry a 1 1) factor))

sl2c-invert : SL2CMatrix → SL2CMatrix
sl2c-invert a =
  makeSL2C
    (slEntry a 1 1)
    (complex (negf (real (slEntry a 0 1))) (negf (imag (slEntry a 0 1))))
    (complex (negf (real (slEntry a 1 0))) (negf (imag (slEntry a 1 0))))
    (slEntry a 0 0)

complexNormSquared : Complex → Float
complexNormSquared z =
  real z *f real z +f imag z *f imag z

sl2c-norm-squared : SL2CMatrix → Float
sl2c-norm-squared a =
  complexNormSquared (slEntry a 0 0) +f
  complexNormSquared (slEntry a 0 1) +f
  complexNormSquared (slEntry a 1 0) +f
  complexNormSquared (slEntry a 1 1)

conjugate : Complex → Complex
conjugate z = complex (real z) (negf (imag z))

sl2c-adjoint : SL2CMatrix → SL2CMatrix
sl2c-adjoint a =
  makeSL2C
    (conjugate (slEntry a 0 0))
    (conjugate (slEntry a 1 0))
    (conjugate (slEntry a 0 1))
    (conjugate (slEntry a 1 1))
