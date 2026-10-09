/*
 * Functorial ICKY C translation.
 *
 * This intentionally uses the ICKY mathematical surface where it clarifies
 * the operation.  The ordinary C extraction remains ../c/recenter.c.
 *
 * The style target is named transformations calling named transformations:
 * input motion -> camera position -> nearest quotient copy -> recentered camera.
 */

#include <stddef.h>
#include <math.h>

typedef float scalar;

typedef struct {
    scalar x;
    scalar y;
    scalar z;
    scalar w;
} point_4;

typedef struct {
    scalar entry[4][4];
} transform;

typedef struct {
    point_4 center;
    transform const *neighbors;
    size_t number_of_neighbors;
} quotient_space;

typedef struct {
    transform group_transform;
    size_t crossing_count;
} nearest_copy;

typedef struct {
    transform camera_to_world;
    transform crossed_group_transform;
    size_t crossing_count;
} recentered_camera;

/* Linear algebra is an explicit lower layer, not mixed with quotient policy. */
transform identity_transform(void);
point_4 apply_transform(point_4 point, transform mapping);
transform compose_transform(transform first, transform second);
int inverse_transform(transform mapping, transform *inverse);
transform tune_hyperbolic_transform(transform mapping);

static scalar
minkowski_pairing(point_4 left, point_4 right)
{
    return
        left.x × right.x +
        left.y × right.y +
        left.z × right.z −
        left.w × right.w;
}

static scalar
hyperbolic_distance(point_4 left, point_4 right)
{
    scalar left_size_squared = minkowski_pairing(left, left);
    scalar right_size_squared = minkowski_pairing(right, right);
    scalar pairing = minkowski_pairing(left, right);

    scalar cosh_distance =
        fabsf(pairing) ÷
        √(left_size_squared × right_size_squared);

    /* Roundoff can put the mathematically exact lower bound below one. */
    cosh_distance = cosh_distance < 1 ? 1 : cosh_distance;

    return acoshf(cosh_distance);
}

static point_4
neighbor_center(
    quotient_space space,
    transform neighbor_transform)
{
    return apply_transform(space.center, neighbor_transform);
}

static scalar
distance_to_neighbor(
    quotient_space space,
    point_4 point,
    transform neighbor_transform)
{
    return hyperbolic_distance(
        point,
        neighbor_center(space, neighbor_transform));
}

static size_t
nearest_neighbor_index(
    quotient_space space,
    point_4 point)
{
    size_t nearest_index = 0;
    scalar nearest_distance =
        distance_to_neighbor(space, point, space.neighbors[0]);

    for (size_t neighbor_index = 1;
         neighbor_index < space.number_of_neighbors;
         ++neighbor_index) {
        scalar candidate_distance =
            distance_to_neighbor(
                space,
                point,
                space.neighbors[neighbor_index]);

        if (candidate_distance < nearest_distance) {
            nearest_index = neighbor_index;
            nearest_distance = candidate_distance;
        }
    }

    return nearest_index;
}

static int
move_point_into_accumulated_copy(
    point_4 original_point,
    transform accumulated_group_transform,
    point_4 *point_in_copy)
{
    transform inverse_group_transform;

    if (inverse_transform(
            accumulated_group_transform,
            &inverse_group_transform) ≟ 0)
        return 0;

    *point_in_copy =
        apply_transform(
            original_point,
            inverse_group_transform);

    return 1;
}

int
find_nearest_copy(
    quotient_space space,
    point_4 original_point,
    nearest_copy *result)
{
    if (space.number_of_neighbors ≟ 0)
        return 0;

    transform accumulated_group_transform = identity_transform();
    point_4 current_point = original_point;

    for (size_t crossing_count = 0;
         crossing_count < 1000;
         ++crossing_count) {
        size_t neighbor_index =
            nearest_neighbor_index(space, current_point);

        /* DiscGrpExtractNhbrs puts the identity first. */
        if (neighbor_index ≟ 0) {
            result->group_transform = accumulated_group_transform;
            result->crossing_count = crossing_count;
            return 1;
        }

        accumulated_group_transform =
            compose_transform(
                space.neighbors[neighbor_index],
                accumulated_group_transform);

        if (move_point_into_accumulated_copy(
                original_point,
                accumulated_group_transform,
                &current_point) ≟ 0)
            return 0;
    }

    return 0;
}

static int
camera_position_in_model(
    transform camera_to_world,
    transform model_to_world,
    point_4 *camera_position)
{
    transform world_to_camera;
    transform world_to_model;
    transform camera_to_model;

    if (inverse_transform(camera_to_world, &world_to_camera) ≟ 0)
        return 0;

    if (inverse_transform(model_to_world, &world_to_model) ≟ 0)
        return 0;

    transform model_to_camera =
        compose_transform(model_to_world, world_to_camera);

    if (inverse_transform(model_to_camera, &camera_to_model) ≟ 0)
        return 0;

    *camera_position =
        apply_transform(
            (point_4){0, 0, 0, 1},
            camera_to_model);

    return 1;
}

int
recenter_camera(
    quotient_space space,
    transform camera_to_world,
    transform model_to_world,
    recentered_camera *result)
{
    point_4 camera_position;

    if (camera_position_in_model(
            camera_to_world,
            model_to_world,
            &camera_position) ≟ 0)
        return 0;

    nearest_copy nearest;

    if (find_nearest_copy(
            space,
            camera_position,
            &nearest) ≟ 0)
        return 0;

    transform world_to_model;
    transform inverse_group_transform;

    if (inverse_transform(model_to_world, &world_to_model) ≟ 0)
        return 0;

    if (inverse_transform(
            nearest.group_transform,
            &inverse_group_transform) ≟ 0)
        return 0;

    transform group_transform_in_world =
        compose_transform(
            world_to_model,
            compose_transform(
                inverse_group_transform,
                model_to_world));

    transform moved_camera =
        compose_transform(
            camera_to_world,
            group_transform_in_world);

    result->camera_to_world =
        tune_hyperbolic_transform(moved_camera);
    result->crossed_group_transform = nearest.group_transform;
    result->crossing_count = nearest.crossing_count;

    return 1;
}
