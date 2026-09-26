module GeometryCenter.DiscGrp.Misc where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy

DiscGrpHandleScan : DiscGrp → Callback → Unit
DiscGrpHandleScan dg callback =
  let a = scanHandle (fundamentalGeometryHandle dg) callback
      b = scanHandle (dirichletGeometryHandle dg) callback
      c = scanHandle (cameraGeometryHandle dg) callback
      d = case fundamentalGeometry dg of λ where
            nothing → tt
            (just geom) → geomHandleScan geom callback
      e = case dirichletGeometry dg of λ where
            nothing → tt
            (just geom) → geomHandleScan geom callback
      f = case cameraGeometry dg of λ where
            nothing → tt
            (just geom) → geomHandleScan geom callback
  in tt
