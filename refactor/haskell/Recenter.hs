module Recenter
  ( Geometry(..)
  , Space(..)
  , NearestCopy(..)
  , RecenteredCamera(..)
  , RecenterError(..)
  , findNearestCopy
  , recenterCamera
  ) where

-- This translation makes the boundary discovered in the C code explicit:
-- quotient navigation needs linear-algebra operations, but does not need a
-- renderer, UI, Geomview object, or control scheme.

data Geometry point transform scalar = Geometry
  { identityTransform :: transform
  , applyTransform :: point -> transform -> point
  , composeTransform :: transform -> transform -> transform
  , inverseTransform :: transform -> Maybe transform
  , distanceBetween :: point -> point -> scalar
  , tuneTransform :: transform -> transform
  }

data Space point transform = Space
  { center :: point
  , neighbors :: [transform]
  }

data NearestCopy transform = NearestCopy
  { groupTransform :: transform
  , crossingCount :: Int
  } deriving (Eq, Show)

data RecenteredCamera transform = RecenteredCamera
  { cameraToWorld :: transform
  , crossedGroupTransform :: transform
  , recenteredCrossingCount :: Int
  } deriving (Eq, Show)

data RecenterError
  = SpaceHasNoNeighbors
  | SingularTransform
  | SearchDidNotConverge
  deriving (Eq, Show)

recenterSearchLimit :: Int
recenterSearchLimit = 1000

nearestNeighbor
  :: Ord scalar
  => Geometry point transform scalar
  -> Space point transform
  -> point
  -> Either RecenterError (Int, transform)
nearestNeighbor geometry space point =
  case neighbors space of
    [] -> Left SpaceHasNoNeighbors
    first : rest ->
      let (bestIndex, bestTransform, _) =
            foldl choose (0, first, distanceTo first) (zip [1..] rest)
      in Right (bestIndex, bestTransform)
  where
    distanceTo transform =
      distanceBetween geometry
        point
        (applyTransform geometry (center space) transform)

    choose (bestIndex, bestTransform, bestDistance) (index, candidate) =
      let candidateDistance = distanceTo candidate
      in if candidateDistance < bestDistance
           then (index, candidate, candidateDistance)
           else (bestIndex, bestTransform, bestDistance)

findNearestCopy
  :: Ord scalar
  => Geometry point transform scalar
  -> Space point transform
  -> point
  -> Either RecenterError (NearestCopy transform)
findNearestCopy geometry space originalPoint =
  go recenterSearchLimit originalPoint (identityTransform geometry) 0
  where
    go 0 _ _ _ = Left SearchDidNotConverge
    go fuel current accumulated crossings = do
      (neighborIndex, neighborTransform) <-
        nearestNeighbor geometry space current

      if neighborIndex == 0
        then Right $ NearestCopy accumulated crossings
        else do
          let next =
                composeTransform geometry neighborTransform accumulated

          nextInverse <-
            maybe (Left SingularTransform) Right
              (inverseTransform geometry next)

          go
            (fuel - 1)
            (applyTransform geometry originalPoint nextInverse)
            next
            (crossings + 1)

recenterCamera
  :: Ord scalar
  => Geometry point transform scalar
  -> Space point transform
  -> point
  -> transform
  -> transform
  -> Either RecenterError (RecenteredCamera transform)
recenterCamera geometry space origin cameraToWorld0 modelToWorld = do
  worldToCamera <-
    maybe (Left SingularTransform) Right
      (inverseTransform geometry cameraToWorld0)

  worldToModel <-
    maybe (Left SingularTransform) Right
      (inverseTransform geometry modelToWorld)

  let modelToCamera =
        composeTransform geometry modelToWorld worldToCamera

  cameraToModel <-
    maybe (Left SingularTransform) Right
      (inverseTransform geometry modelToCamera)

  let cameraPosition =
        applyTransform geometry origin cameraToModel

  nearest <- findNearestCopy geometry space cameraPosition

  inverseGroup <-
    maybe (Left SingularTransform) Right
      (inverseTransform geometry (groupTransform nearest))

  let groupInWorld =
        composeTransform geometry
          worldToModel
          (composeTransform geometry inverseGroup modelToWorld)

      movedCamera =
        composeTransform geometry cameraToWorld0 groupInWorld

  pure $ RecenteredCamera
    (tuneTransform geometry movedCamera)
    (groupTransform nearest)
    (crossingCount nearest)
