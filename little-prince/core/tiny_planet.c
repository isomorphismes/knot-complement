#include "tiny_planet.h"

#include <math.h>

static tp_vec3
add(tp_vec3 a, tp_vec3 b)
{
    return (tp_vec3){
        a.x + b.x,
        a.y + b.y,
        a.z + b.z
    };
}

static tp_vec3
scale(tp_vec3 v, float s)
{
    return (tp_vec3){
        v.x * s,
        v.y * s,
        v.z * s
    };
}

static tp_vec3
cross(tp_vec3 a, tp_vec3 b)
{
    return (tp_vec3){
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    };
}

float
tp_vec3_dot(tp_vec3 a, tp_vec3 b)
{
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

float
tp_vec3_length(tp_vec3 v)
{
    return sqrtf(tp_vec3_dot(v, v));
}

static tp_vec3
normalize(tp_vec3 v)
{
    float length = tp_vec3_length(v);

    if (length <= 1.0e-8f)
        return (tp_vec3){0.0f, 0.0f, 0.0f};

    return scale(v, 1.0f / length);
}

static tp_vec3
rotate(tp_vec3 v, tp_vec3 axis, float radians)
{
    axis = normalize(axis);

    float c = cosf(radians);
    float s = sinf(radians);

    return add(
        add(
            scale(v, c),
            scale(cross(axis, v), s)),
        scale(
            axis,
            tp_vec3_dot(axis, v) * (1.0f - c)));
}

static void
orthonormalize(tp_walker *walker)
{
    walker->up = normalize(walker->up);

    walker->forward =
        add(
            walker->forward,
            scale(
                walker->up,
                -tp_vec3_dot(walker->forward, walker->up)));

    walker->forward = normalize(walker->forward);
}

int
tp_walker_init(tp_walker *walker, float radius)
{
    if (walker == 0 || !(radius > 0.0f))
        return 0;

    walker->radius = radius;

    /*
     * Start on the equator, not at a coordinate pole.  The runtime algorithm
     * itself has no poles; latitude/longitude are only terrain lookup values.
     */
    walker->up = (tp_vec3){1.0f, 0.0f, 0.0f};
    walker->forward = (tp_vec3){0.0f, 0.0f, -1.0f};

    return 1;
}

int
tp_walker_set_frame(
    tp_walker *walker,
    tp_vec3 up,
    tp_vec3 forward)
{
    if (walker == 0 || tp_vec3_length(up) <= 1.0e-8f)
        return 0;

    walker->up = normalize(up);

    walker->forward =
        add(
            forward,
            scale(
                walker->up,
                -tp_vec3_dot(forward, walker->up)));

    if (tp_vec3_length(walker->forward) <= 1.0e-8f)
        return 0;

    walker->forward = normalize(walker->forward);

    return 1;
}

void
tp_walker_turn(tp_walker *walker, float radians)
{
    if (walker == 0)
        return;

    walker->forward =
        rotate(walker->forward, walker->up, radians);

    orthonormalize(walker);
}

void
tp_walker_walk(tp_walker *walker, float distance)
{
    if (walker == 0 || !(walker->radius > 0.0f))
        return;

    tp_vec3 tangent_axis =
        cross(walker->up, walker->forward);

    if (tp_vec3_length(tangent_axis) <= 1.0e-8f)
        return;

    float radians = distance / walker->radius;

    walker->up =
        rotate(walker->up, tangent_axis, radians);

    walker->forward =
        rotate(walker->forward, tangent_axis, radians);

    orthonormalize(walker);
}

tp_vec3
tp_walker_position(
    const tp_walker *walker,
    float terrain_height,
    float eye_height)
{
    if (walker == 0)
        return (tp_vec3){0.0f, 0.0f, 0.0f};

    return scale(
        walker->up,
        walker->radius + terrain_height + eye_height);
}

float
tp_walker_latitude(const tp_walker *walker)
{
    if (walker == 0)
        return 0.0f;

    float y = walker->up.y;

    if (y < -1.0f)
        y = -1.0f;

    if (y > 1.0f)
        y = 1.0f;

    return asinf(y);
}

float
tp_walker_longitude(const tp_walker *walker)
{
    if (walker == 0)
        return 0.0f;

    return atan2f(walker->up.z, walker->up.x);
}
