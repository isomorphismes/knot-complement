#include "recenter.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static kc_transform boost_x(float distance)
{
    float c = coshf(distance);
    float s = sinhf(distance);
    kc_transform out = kc_identity();
    out.m[0][0] = c;
    out.m[0][3] = s;
    out.m[3][0] = s;
    out.m[3][3] = c;
    return out;
}

static void require_close(float actual, float expected, float tolerance, const char *label)
{
    if (!isfinite(actual) || !isfinite(expected) || !isfinite(tolerance) ||
        tolerance < 0.0f || fabsf(actual - expected) > tolerance) {
        fprintf(stderr, "%s: got %.8f expected %.8f\n", label, actual, expected);
        exit(1);
    }
}

static void require_transform_close(kc_transform actual, kc_transform expected, const char *label)
{
    for (size_t i = 0; i < 4; ++i) {
        for (size_t j = 0; j < 4; ++j) {
            if (!isfinite(actual.m[i][j]) || !isfinite(expected.m[i][j]) ||
                fabsf(actual.m[i][j] - expected.m[i][j]) > 0.0002f) {
                fprintf(stderr, "%s[%zu][%zu]: got %.8f expected %.8f\n",
                    label, i, j, actual.m[i][j], expected.m[i][j]);
                exit(1);
            }
        }
    }
}

int main(int argc, char **argv)
{
    const kc_point4 origin = {0.0f, 0.0f, 0.0f, 1.0f};
    kc_transform identity = kc_identity();
    if (argc == 2 && strcmp(argv[1], "--reject-nan-assertion") == 0) {
        require_close(NAN, 0.0f, 0.0002f, "nonfinite scalar assertion");
        return 0;
    }
    if (argc == 2 && strcmp(argv[1], "--reject-nan-matrix") == 0) {
        kc_transform bad = identity;
        bad.m[0][0] = NAN;
        require_transform_close(bad, identity, "nonfinite matrix assertion");
        return 0;
    }
    if (argc != 1) return 2;
    kc_transform forward = boost_x(0.7f);
    kc_transform backward;
    if (kc_inverse(forward, &backward) != KC_OK) {
        return 1;
    }

    kc_transform neighbors[] = {identity, forward, backward};
    kc_space space = {origin, neighbors, 3};

    kc_point4 one_step = kc_apply(origin, forward);
    require_close(kc_hyperbolic_distance(origin, one_step), 0.7f, 0.0002f, "distance");

    kc_transform closest;
    size_t steps = 0;
    if (kc_find_nearest_copy(&space, one_step, &closest, &steps) != KC_OK) {
        return 1;
    }
    require_transform_close(closest, forward, "one-step closest");
    if (steps != 1) {
        fprintf(stderr, "one-step count: got %zu expected 1\n", steps);
        return 1;
    }

    kc_transform two_forward = kc_compose(forward, forward);
    kc_point4 two_steps = kc_apply(origin, two_forward);
    if (kc_find_nearest_copy(&space, two_steps, &closest, &steps) != KC_OK) {
        return 1;
    }
    require_transform_close(closest, two_forward, "two-step closest");
    if (steps != 2) {
        fprintf(stderr, "two-step count: got %zu expected 2\n", steps);
        return 1;
    }

    kc_transform fig8_a = {{
        {0.83333337f, 0.28867513f, -0.5f, -0.16666667f},
        {-0.86602545f, 0.5f, -0.86602545f, 0.86602545f},
        {0.5f, 0.86602545f, 1.0f, -1.0f},
        {-0.83333337f, -0.28867513f, -1.0f, 1.6666667f}
    }};
    kc_point4 fig8_image = kc_apply(origin, fig8_a);
    require_close(kc_hyperbolic_distance(origin, fig8_image), 1.0986123f, 0.0003f, "fig8 generator distance");
    if (kc_needs_hyperbolic_tuneup(fig8_a)) {
        fprintf(stderr, "fig8 generator unexpectedly needs tuneup\n");
        return 1;
    }

    kc_transform recentered;
    if (kc_recenter_camera(&space, two_forward, identity, &recentered, &closest, &steps) != KC_OK) {
        return 1;
    }
    require_transform_close(recentered, identity, "recentered camera");
    require_transform_close(closest, two_forward, "recentered closest");

    const kc_point4 invalid_points[] = {
        {1,0,0,0}, {0,0,0,-1}, {0,0,0,0}, {NAN,0,0,1}, {INFINITY,0,0,1}
    };
    for (size_t i = 0; i < sizeof(invalid_points)/sizeof(invalid_points[0]); ++i) {
        if (isfinite(kc_hyperbolic_distance(invalid_points[i],origin)) ||
            kc_find_nearest_copy(&space,invalid_points[i],&closest,&steps) != KC_BAD_INPUT) {
            fprintf(stderr,"invalid hyperbolic point accepted: %zu\n",i);
            return 1;
        }
    }
    kc_transform bad = identity;
    bad.m[0][0] = NAN;
    if (!kc_needs_hyperbolic_tuneup(bad) || kc_inverse(bad,&backward) != KC_BAD_INPUT ||
        kc_recenter_camera(&space,bad,identity,&recentered,&closest,&steps) != KC_BAD_INPUT)
        return 1;
    kc_transform wrong_order[] = {forward,identity};
    kc_space missing_first_identity = {origin,wrong_order,2};
    if (kc_find_nearest_copy(&missing_first_identity,origin,&closest,&steps) != KC_BAD_INPUT)
        return 1;
    kc_transform almost_identity = boost_x(1e-7f);
    kc_space small_nonidentity = {origin,&almost_identity,1};
    if (kc_find_nearest_copy(&small_nonidentity,origin,&closest,&steps) != KC_BAD_INPUT)
        return 1;
    kc_transform wrong_sheet = identity;
    wrong_sheet.m[3][3] = -1.0f;
    kc_transform wrong_neighbors[] = {identity,wrong_sheet};
    kc_space wrong_neighbor = {origin,wrong_neighbors,2};
    if (kc_find_nearest_copy(&wrong_neighbor,origin,&closest,&steps) != KC_BAD_INPUT)
        return 1;

    puts("recenter C: PASS");
    return 0;
}

