#include "tiny_planet.h"

#include <assert.h>
#include <math.h>
#include <stdio.h>

static const float pi = 3.14159265358979323846f;

static int
near(float a, float b, float epsilon)
{
    return fabsf(a - b) <= epsilon;
}

static int
vector_near(
    tp_vec3 a,
    tp_vec3 b,
    float epsilon)
{
    return
        near(a.x, b.x, epsilon) &&
        near(a.y, b.y, epsilon) &&
        near(a.z, b.z, epsilon);
}

int
main(void)
{
    tp_walker walker;

    assert(tp_walker_init(&walker, 20.0f));

    assert(near(
        tp_walker_latitude(&walker),
        0.0f,
        1.0e-6f));

    assert(near(
        tp_walker_longitude(&walker),
        0.0f,
        1.0e-6f));

    /* Quarter-circumference: +X -> -Z. */
    tp_walker_walk(
        &walker,
        20.0f * pi * 0.5f);

    assert(vector_near(
        walker.up,
        (tp_vec3){0.0f, 0.0f, -1.0f},
        2.0e-5f));

    assert(near(
        tp_vec3_length(walker.up),
        1.0f,
        1.0e-5f));

    assert(near(
        tp_vec3_dot(walker.up, walker.forward),
        0.0f,
        1.0e-5f));

    /* A thousand small steps should close one full great circle. */
    assert(tp_walker_init(&walker, 20.0f));

    for (int step = 0; step < 1000; ++step)
        tp_walker_walk(
            &walker,
            20.0f * 2.0f * pi / 1000.0f);

    assert(vector_near(
        walker.up,
        (tp_vec3){1.0f, 0.0f, 0.0f},
        3.0e-4f));

    assert(vector_near(
        walker.forward,
        (tp_vec3){0.0f, 0.0f, -1.0f},
        3.0e-4f));

    /*
     * Turn north, then walk a quarter-circumference from the equator
     * to the north pole.  No latitude-coordinate special case is involved.
     */
    assert(tp_walker_init(&walker, 20.0f));

    tp_walker_turn(&walker, pi * 0.5f);

    assert(vector_near(
        walker.forward,
        (tp_vec3){0.0f, 1.0f, 0.0f},
        2.0e-5f));

    tp_walker_walk(
        &walker,
        20.0f * pi * 0.5f);

    assert(vector_near(
        walker.up,
        (tp_vec3){0.0f, 1.0f, 0.0f},
        2.0e-5f));

    tp_vec3 eye =
        tp_walker_position(
            &walker,
            2.0f,
            1.0f);

    assert(near(
        tp_vec3_length(eye),
        23.0f,
        1.0e-4f));

    puts("PASS tiny-planet spherical walk");

    return 0;
}
