module GeometryCenter.DiscGrp.Draw where

open import GeometryCenter.Prelude
open import GeometryCenter.Types
open import GeometryCenter.Legacy
open import GeometryCenter.DiscGrp.Flags
open import GeometryCenter.DiscGrp.Util
open import GeometryCenter.DiscGrp.Dirdom

magic-scale : Float
magic-scale = 1.2

visd1 : Float
visd1 = 2.0

defaultFrustum : Float → List Point4
defaultFrustum half =
  makePoint4 (negf 1.0) 0.0 half 0.0 ∷
  makePoint4 1.0 0.0 half 0.0 ∷
  makePoint4 0.0 (negf 1.0) half 0.0 ∷
  makePoint4 0.0 1.0 half 0.0 ∷ []

DiscGrpStandardPreDraw : DiscGrp → DiscGrp
DiscGrpStandardPreDraw dg =
  let needsView =
        hasBit (groupFlag dg) DG-DRAWCAM ||
        hasBit (groupFlag dg) DG-ZCULL ||
        hasBit (groupFlag dg) DG-CENTERCAM
  in if not needsView
       then dg
       else
         let w2c = cameraWorldToCamera
             c2w =
               case transformInverse w2c of λ where
                 nothing → transformIdentity
                 (just value) → value
             m2w = currentModelToWorld
             w2m =
               case transformInverse m2w of λ where
                 nothing → transformIdentity
                 (just value) → value
             m2c = transformConcat m2w w2c
             c2m =
               case transformInverse m2c of λ where
                 nothing → transformIdentity
                 (just value) → value
             halfY0 = cameraHalfYField *f magic-scale
             halfX0 = cameraAspect *f halfY0
             half = maxf halfX0 halfY0
             info =
               dgViewInfo
                 (defaultFrustum half)
                 m2w w2m c2w w2c c2m m2c
         in record dg { groupViewInfo = info }

record DrawState : Set where
  constructor drawState
  field
    drawDirdomState : DirdomState
    drawGroup : DiscGrp
open DrawState public

ensureDrawableGeometry : DrawState → DrawState
ensureDrawableGeometry state =
  let dg = drawGroup state
      needsDomain =
        case fundamentalGeometry dg of λ where
          nothing → true
          (just geom) →
            hasBit (groupFlag dg) DG-NEWDIRDOM ||
            (hasBit (groupFlag dg) DG-DRAWDIRDOM &&
             case dirichletGeometry dg of λ where
               nothing → true
               (just dd) → false)
  in if not needsDomain
       then state
       else
         let result = DiscGrpDirDom (drawDirdomState state) dg
             withDomain = dirDomGroup result
             withFundamental =
               case fundamentalGeometry withDomain of λ where
                 nothing →
                   record withDomain {
                     fundamentalGeometry = dirichletGeometry withDomain
                   }
                 (just geom) → withDomain
             cleared =
               record withFundamental {
                 groupFlag =
                   bitAnd (groupFlag withFundamental)
                          (bitNot DG-NEWDIRDOM)
               }
         in drawState (dirDomState result) cleared

ensureElementList : DrawState → DrawState
ensureElementList state =
  let dg = drawGroup state
  in case groupElements dg of λ where
       (just existing) → state
       nothing →
         case groupNeighbors dg of λ where
           nothing → state
           (just neighbors) →
             record state {
               drawGroup =
                 record dg { groupElements = just neighbors }
             }

recenterCamera : DrawState → DrawState
recenterCamera state =
  let dg = drawGroup state
  in if not (hasBit (groupFlag dg) DG-CENTERCAM)
       then state
       else
         let info = groupViewInfo dg
             cameraPosition =
               transformPoint (cameraToModel info) origin4
             closest =
               DiscGrpClosestGroupEl
                 (drawDirdomState state)
                 dg
                 cameraPosition
             element = closestElement closest
         in case transformInverse (elementTransform element) of λ where
              nothing →
                drawState (closestState closest) (closestGroup closest)
              (just h) →
                let dg2 = closestGroup closest
                    info2 = groupViewInfo dg2
                    cinv = transformConcat h (modelToWorld info2)
                    hprime =
                      transformConcat (worldToModel info2) cinv
                    cameraPrime =
                      transformConcat (cameraToWorld info2) hprime
                    metric =
                      bitAnd (groupAttributes dg2) DG-METRIC-BITS
                    corrected =
                      if hasBit (groupAttributes dg2) DG-HYPERBOLIC &&
                         needstuneup cameraPrime
                        then tuneup cameraPrime metric
                        else cameraPrime
                    ignored = cameraSetCameraToWorld corrected
                in drawState (closestState closest) dg2

outsideFrustum : List Point4 → Point4 → Bool
outsideFrustum frustum image =
  any (λ plane → floatLess 0.0 (r40Dot image plane)) frustum

tileVisible : DiscGrp → Transform → Bool
tileVisible dg tile =
  if not (hasBit (groupFlag dg) DG-ZCULL)
    then true
    else
      let info = groupViewInfo dg
          tileToCamera =
            transformConcat tile (modelToCamera info)
          image =
            transformPoint tileToCamera (groupCenter dg)
          metric =
            bitAnd (groupAttributes dg) DG-METRIC-BITS
          distance =
            spaceDistance image (groupCenter dg) metric
          behind =
            not (natEq metric DG-SPHERICAL) &&
            floatLess
              0.0
              (pointEntry image 2 *f pointEntry image 3)
      in if floatLess (drawingDistance dg) distance
           then false
           else if floatLess visd1 distance
             then not (behind || outsideFrustum (frustum info) image)
             else true

drawTile : DiscGrp → Transform → Unit
drawTile dg tile =
  let pushed = pushTransform tt
      transformed = multiplyCurrentTransform tile
      drawDomain =
        if hasBit (groupFlag dg) DG-DRAWDIRDOM
          then
            case dirichletGeometry dg of λ where
              nothing → tt
              (just geom) → drawGeom geom
          else tt
      drawFundamental =
        if hasBit (groupFlag dg) DG-DRAWGEOM
          then
            case fundamentalGeometry dg of λ where
              nothing → tt
              (just geom) →
                case dirichletGeometry dg of λ where
                  nothing → drawGeom geom
                  (just dd) →
                    if sameGeom geom dd then tt else drawGeom geom
          else tt
      drawCamera =
        if hasBit (groupFlag dg) DG-DRAWCAM
          then
            case cameraGeometry dg of λ where
              nothing → tt
              (just geom) →
                let p = pushTransform tt
                    t = multiplyCurrentTransform
                          (cameraToModel (groupViewInfo dg))
                    d = drawGeom geom
                    q = popTransform tt
                in tt
          else tt
      popped = popTransform tt
  in tt

renderTiles : DiscGrp → Unit
renderTiles dg =
  let visible =
        filter (tileVisible dg) (geomIterateTransforms dg)
      ignored = map (drawTile dg) visible
  in tt

DiscGrpDraw : DrawState → DrawState
DiscGrpDraw state =
  let dg0 = drawGroup state
      dg1 =
        case predrawCallback dg0 of λ where
          nothing → DiscGrpStandardPreDraw dg0
          (just callback) → runPredraw callback dg0
      prepared0 = record state { drawGroup = dg1 }
      prepared1 = ensureDrawableGeometry prepared0
      prepared2 = ensureElementList prepared1
      recentered = recenterCamera prepared2
      ignored = renderTiles (drawGroup recentered)
  in recentered
