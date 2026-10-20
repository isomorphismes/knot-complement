#ifndef KC_H3_RAY_H
#define KC_H3_RAY_H

/* Unit-curvature H3; spatial coordinates first, positive time last.
 * Public representations are forgeable in C: every operation validates them.
 * No quotient, camera projection, material surface or renderer is implied. */
typedef struct { double x, y, z, time; } kc_h3_vector;
typedef struct {
    kc_h3_vector position;
    kc_h3_vector direction;
    double travelled;
} kc_h3_ray;
typedef struct { kc_h3_vector right, up, forward; } kc_h3_frame;
typedef struct { double rows[4][4]; } kc_h3_direct_isometry;
typedef struct { double position[3], velocity[3]; } kc_h3_chart_ray;
typedef struct { double distance; kc_h3_ray ray; } kc_h3_hit;

typedef enum {
    KC_H3_OK = 0,
    KC_H3_INVALID = 1,
    KC_H3_NUMERICAL_RANGE = 2,
    KC_H3_NO_HIT = 3,
    KC_H3_DISTANCE_LIMIT = 4,
    KC_H3_ON_SURFACE = 5,
    KC_H3_UNRESOLVED = 6
} kc_h3_status;
typedef enum {
    KC_H3_UPPER_HALF_SPACE,
    KC_H3_KLEIN,
    KC_H3_POINCARE
} kc_h3_chart;

/* This initial double reference refuses components outside [-64,64] and
 * single advances over length 4. Refusal does not mean a boundary of H3.
 * Error/limit results leave every supplied output unchanged. */
kc_h3_status kc_h3_validate_ray(const kc_h3_ray *ray);
kc_h3_status kc_h3_distance(kc_h3_vector first, kc_h3_vector second,
                          double *distance);
kc_h3_status kc_h3_advance(const kc_h3_ray *ray, double distance,
                         kc_h3_ray *advanced);
kc_h3_status kc_h3_transport_frame(const kc_h3_ray *ray, double distance,
                                 const kc_h3_frame *frame,
                                 kc_h3_frame *transported);
kc_h3_status kc_h3_change_chart(const kc_h3_ray *ray, kc_h3_chart chart,
                              kc_h3_chart_ray *converted);
kc_h3_status kc_h3_validate_isometry(const kc_h3_direct_isometry *isometry);
kc_h3_status kc_h3_apply_isometry(const kc_h3_direct_isometry *isometry,
                                const kc_h3_ray *ray, kc_h3_ray *mapped);
kc_h3_status kc_h3_map_frame(const kc_h3_direct_isometry *isometry,
                           const kc_h3_ray *ray, const kc_h3_frame *frame,
                           kc_h3_frame *mapped);
kc_h3_status kc_h3_plane_hit(const kc_h3_ray *ray, kc_h3_vector normal,
                           double distance_limit, kc_h3_hit *hit);
kc_h3_status kc_h3_sphere_hit(const kc_h3_ray *ray, kc_h3_vector center,
                            double radius, double distance_limit,
                            kc_h3_hit *hit);
#endif
