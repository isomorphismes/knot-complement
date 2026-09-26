module recenter;

import std.math : abs, acosh, sqrt;
import std.typecons : Nullable, nullable;

alias Scalar = float;
alias Point4 = Scalar[4];
alias Transform = Scalar[4][4];

struct Space {
    Point4 center;
    Transform[] neighbors;
}

struct NearestCopy {
    Transform group_transform;
    size_t crossing_count;
}

struct RecenteredCamera {
    Transform camera_to_world;
    Transform crossed_group_transform;
    size_t crossing_count;
}

Transform identity_transform()
{
    Transform result;
    foreach (i; 0 .. 4)
        result[i][i] = 1;
    return result;
}

Transform compose_transform(Transform left, Transform right)
{
    Transform result = 0;
    foreach (i; 0 .. 4)
        foreach (j; 0 .. 4)
            foreach (k; 0 .. 4)
                result[i][j] += left[i][k] * right[k][j];
    return result;
}

Point4 apply_transform(Point4 point, Transform transform)
{
    Point4 result;
    foreach (j; 0 .. 4)
        foreach (k; 0 .. 4)
            result[j] += point[k] * transform[k][j];
    return result;
}

Nullable!Transform inverse_transform(Transform input)
{
    auto work = input;
    auto result = identity_transform();

    foreach (i; 0 .. 4) {
        size_t largest = i;
        Scalar largest_square = work[i][i] * work[i][i];

        foreach (j; i + 1 .. 4) {
            Scalar square = work[j][i] * work[j][i];
            if (square > largest_square) {
                largest = j;
                largest_square = square;
            }
        }

        if (largest_square == 0)
            return Nullable!Transform.init;

        if (largest != i) {
            auto work_row = work[i];
            work[i] = work[largest];
            work[largest] = work_row;

            auto result_row = result[i];
            result[i] = result[largest];
            result[largest] = result_row;
        }

        foreach (j; i + 1 .. 4) {
            Scalar factor = work[j][i] / work[i][i];
            foreach (k; 0 .. 4) {
                work[j][k] -= factor * work[i][k];
                result[j][k] -= factor * result[i][k];
            }
        }
    }

    foreach (i; 0 .. 4) {
        Scalar factor = work[i][i];
        if (factor == 0)
            return Nullable!Transform.init;
        foreach (k; 0 .. 4) {
            work[i][k] /= factor;
            result[i][k] /= factor;
        }
    }

    foreach_reverse (i; 0 .. 4)
        foreach_reverse (j; 0 .. i) {
            Scalar factor = work[j][i];
            foreach (k; 0 .. 4) {
                work[j][k] -= factor * work[i][k];
                result[j][k] -= factor * result[i][k];
            }
        }

    return nullable(result);
}

Scalar minkowski_pairing(Point4 left, Point4 right)
{
    return left[0] * right[0] +
           left[1] * right[1] +
           left[2] * right[2] -
           left[3] * right[3];
}

Scalar hyperbolic_distance(Point4 left, Point4 right)
{
    Scalar aa = minkowski_pairing(left, left);
    Scalar bb = minkowski_pairing(right, right);
    Scalar ab = minkowski_pairing(left, right);
    Scalar ratio = cast(Scalar) abs(ab / sqrt(aa * bb));
    if (ratio < 1)
        ratio = 1;
    return cast(Scalar) acosh(ratio);
}

Point4 scale_point(Scalar scale, Point4 point)
{
    Point4 result;
    foreach (i; 0 .. 4)
        result[i] = scale * point[i];
    return result;
}

Point4 subtract_point(Point4 left, Point4 right)
{
    Point4 result;
    foreach (i; 0 .. 4)
        result[i] = left[i] - right[i];
    return result;
}

Point4 normalize_hyperbolic(Point4 point)
{
    Scalar length =
        cast(Scalar) sqrt(abs(minkowski_pairing(point, point)));

    if (length == 0)
        return point;

    return scale_point(1 / length, point);
}

Point4 gram_schmidt(Point4 base, Point4 point)
{
    Scalar denominator = minkowski_pairing(base, base);

    if (denominator == 0)
        return point;

    return subtract_point(
        point,
        scale_point(
            minkowski_pairing(base, point) / denominator,
            base));
}

Transform tune_hyperbolic_transform(Transform transform)
{
    Point4 row0 = normalize_hyperbolic(transform[0]);

    Point4 row1 = gram_schmidt(row0, transform[1]);
    row1 = normalize_hyperbolic(row1);

    Point4 row2 = gram_schmidt(row0, transform[2]);
    row2 = gram_schmidt(row1, row2);
    row2 = normalize_hyperbolic(row2);

    Point4 row3 = gram_schmidt(row0, transform[3]);
    row3 = gram_schmidt(row1, row3);
    row3 = gram_schmidt(row2, row3);
    row3 = normalize_hyperbolic(row3);

    transform[0] = row0;
    transform[1] = row1;
    transform[2] = row2;
    transform[3] = row3;

    return transform;
}

size_t nearest_neighbor_index(Space space, Point4 point)
{
    size_t nearest = 0;
    Scalar nearest_distance =
        hyperbolic_distance(
            point,
            apply_transform(space.center, space.neighbors[0]));

    foreach (index, neighbor; space.neighbors[1 .. $]) {
        size_t actual_index = index + 1;
        Scalar candidate_distance =
            hyperbolic_distance(
                point,
                apply_transform(space.center, neighbor));

        if (candidate_distance < nearest_distance) {
            nearest = actual_index;
            nearest_distance = candidate_distance;
        }
    }

    return nearest;
}

Nullable!NearestCopy find_nearest_copy(Space space, Point4 original_point)
{
    if (space.neighbors.length == 0)
        return Nullable!NearestCopy.init;

    Transform accumulated = identity_transform();
    Point4 current = original_point;

    foreach (crossing_count; 0 .. 1000) {
        size_t nearest = nearest_neighbor_index(space, current);

        if (nearest == 0)
            return nullable(NearestCopy(accumulated, crossing_count));

        accumulated =
            compose_transform(space.neighbors[nearest], accumulated);

        auto inverse = inverse_transform(accumulated);
        if (inverse.isNull)
            return Nullable!NearestCopy.init;

        current = apply_transform(original_point, inverse.get);
    }

    return Nullable!NearestCopy.init;
}

Nullable!RecenteredCamera recenter_camera(
    Space space,
    Transform camera_to_world,
    Transform model_to_world)
{
    auto world_to_camera = inverse_transform(camera_to_world);
    auto world_to_model = inverse_transform(model_to_world);

    if (world_to_camera.isNull || world_to_model.isNull)
        return Nullable!RecenteredCamera.init;

    Transform model_to_camera =
        compose_transform(model_to_world, world_to_camera.get);

    auto camera_to_model = inverse_transform(model_to_camera);
    if (camera_to_model.isNull)
        return Nullable!RecenteredCamera.init;

    Point4 camera_position =
        apply_transform([0.0f, 0.0f, 0.0f, 1.0f], camera_to_model.get);

    auto nearest = find_nearest_copy(space, camera_position);
    if (nearest.isNull)
        return Nullable!RecenteredCamera.init;

    auto inverse_group = inverse_transform(nearest.get.group_transform);
    if (inverse_group.isNull)
        return Nullable!RecenteredCamera.init;

    Transform group_in_world =
        compose_transform(
            world_to_model.get,
            compose_transform(inverse_group.get, model_to_world));

    Transform moved_camera =
        compose_transform(camera_to_world, group_in_world);

    return nullable(RecenteredCamera(
        tune_hyperbolic_transform(moved_camera),
        nearest.get.group_transform,
        nearest.get.crossing_count));
}
