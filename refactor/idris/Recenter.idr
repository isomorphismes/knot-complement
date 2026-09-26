module Recenter

%default total

public export
record Geometry point transform scalar where
  constructor GeometryOperations
  identityTransform : transform
  applyTransform : point -> transform -> point
  composeTransform : transform -> transform -> transform
  inverseTransform : transform -> Maybe transform
  distanceBetween : point -> point -> scalar
  tuneTransform : transform -> transform

public export
record Space point transform where
  constructor QuotientSpace
  center : point
  -- Identity copy first, matching DiscGrpExtractNhbrs.
  neighbors : List transform

public export
record NearestCopy transform where
  constructor FoundCopy
  groupTransform : transform
  crossingCount : Nat

public export
record RecenteredCamera transform where
  constructor CameraInBaseCopy
  cameraToWorld : transform
  crossedGroupTransform : transform
  recenteredCrossingCount : Nat

public export
data RecenterError
  = SpaceHasNoNeighbors
  | SingularTransform
  | SearchDidNotConverge

recenterSearchLimit : Nat
recenterSearchLimit = 1000

distanceTo :
  Ord scalar =>
  Geometry point transform scalar ->
  Space point transform ->
  point ->
  transform ->
  scalar
distanceTo geometry space point transform =
  distanceBetween geometry
    point
    (applyTransform geometry (center space) transform)

nearestNeighbor :
  Ord scalar =>
  Geometry point transform scalar ->
  Space point transform ->
  point ->
  Either RecenterError (Nat, transform)
nearestNeighbor geometry space point =
  case neighbors space of
    [] => Left SpaceHasNoNeighbors
    first :: rest =>
      Right (chooseRest 1 0 first (distanceTo geometry space point first) rest)
  where
    chooseRest :
      Nat -> Nat -> transform -> scalar -> List transform -> (Nat, transform)
    chooseRest nextIndex bestIndex bestTransform bestDistance [] =
      (bestIndex, bestTransform)
    chooseRest nextIndex bestIndex bestTransform bestDistance (candidate :: rest) =
      let candidateDistance = distanceTo geometry space point candidate in
        if candidateDistance < bestDistance
          then chooseRest (S nextIndex) nextIndex candidate candidateDistance rest
          else chooseRest (S nextIndex) bestIndex bestTransform bestDistance rest

public export
findNearestCopy :
  Ord scalar =>
  Geometry point transform scalar ->
  Space point transform ->
  point ->
  Either RecenterError (NearestCopy transform)
findNearestCopy geometry space originalPoint =
  search recenterSearchLimit originalPoint (identityTransform geometry) 0
  where
    search :
      Nat ->
      point ->
      transform ->
      Nat ->
      Either RecenterError (NearestCopy transform)
    search Z current accumulated crossings =
      Left SearchDidNotConverge
    search (S fuel) current accumulated crossings =
      case nearestNeighbor geometry space current of
        Left problem => Left problem
        Right (neighborIndex, neighborTransform) =>
          if neighborIndex == 0
            then Right (FoundCopy accumulated crossings)
            else
              let next =
                    composeTransform geometry neighborTransform accumulated
              in case inverseTransform geometry next of
                   Nothing => Left SingularTransform
                   Just nextInverse =>
                     search
                       fuel
                       (applyTransform geometry originalPoint nextInverse)
                       next
                       (S crossings)

public export
recenterCamera :
  Ord scalar =>
  Geometry point transform scalar ->
  Space point transform ->
  point ->
  transform ->
  transform ->
  Either RecenterError (RecenteredCamera transform)
recenterCamera geometry space origin cameraToWorld0 modelToWorld =
  case inverseTransform geometry cameraToWorld0 of
    Nothing => Left SingularTransform
    Just worldToCamera =>
      case inverseTransform geometry modelToWorld of
        Nothing => Left SingularTransform
        Just worldToModel =>
          let modelToCamera =
                composeTransform geometry modelToWorld worldToCamera
          in case inverseTransform geometry modelToCamera of
               Nothing => Left SingularTransform
               Just cameraToModel =>
                 let cameraPosition =
                       applyTransform geometry origin cameraToModel
                 in case findNearestCopy geometry space cameraPosition of
                      Left problem => Left problem
                      Right nearest =>
                        case inverseTransform geometry (groupTransform nearest) of
                          Nothing => Left SingularTransform
                          Just inverseGroup =>
                            let groupInWorld =
                                  composeTransform geometry
                                    worldToModel
                                    (composeTransform geometry
                                      inverseGroup
                                      modelToWorld)
                                movedCamera =
                                  composeTransform geometry
                                    cameraToWorld0
                                    groupInWorld
                            in Right
                                 (CameraInBaseCopy
                                   (tuneTransform geometry movedCamera)
                                   (groupTransform nearest)
                                   (crossingCount nearest))
