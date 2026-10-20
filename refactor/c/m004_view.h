#ifndef KC_M004_VIEW_H
#define KC_M004_VIEW_H

#include "m004_atlas.h"

/* A camera is a point and complete orthonormal frame in the m004 atlas.
 * Sensor coordinates are dimensionless; resolution is not camera state. */
typedef struct {
    kc_m004_state state;
    double tangent_half_vertical_fov;
    double aspect;
} kc_m004_camera;

/* One labelled geodesic sphere at each enabled tetrahedron centre. The
 * radius is strictly below the tetrahedron inradius, so the closed objects
 * lie inside their charts and do not require an object-clipping convention. */
typedef struct { unsigned marker_mask; double radius; } kc_m004_scene;
typedef struct { double distance; unsigned crossings; } kc_m004_view_budget;
typedef enum {
    KC_M004_VIEW_HIT = 0,
    KC_M004_VIEW_DISTANCE_LIMIT = 1,
    KC_M004_VIEW_CROSSING_LIMIT = 2,
    KC_M004_VIEW_UNRESOLVED = 3,
    KC_M004_VIEW_NUMERICAL_RANGE = 4,
    KC_M004_VIEW_INVALID = 5
} kc_m004_view_status;
typedef struct {
    kc_m004_view_status status;
    kc_m004_state endpoint;
    unsigned crossings;
    int marker;
    double headlight_cosine;
} kc_m004_pixel;

kc_m004_status kc_m004_camera_validate(const kc_m004_camera *camera);
kc_m004_status kc_m004_camera_ray(const kc_m004_camera *camera,
                                 double sensor_x, double sensor_y,
                                 kc_m004_state *ray);
/* Camera odometry accumulates; each viewing ray starts at optical distance 0.
 * Movement changes the authoritative camera before any pixels are sampled. */
kc_m004_status kc_m004_camera_move(const kc_m004_camera *camera, double distance,
                                  unsigned crossing_limit,
                                  kc_m004_camera *moved);
/* Positive yaw turns forward towards right; pitch turns forward towards up. */
kc_m004_status kc_m004_camera_turn(const kc_m004_camera *camera,
                                  double yaw, double pitch,
                                  kc_m004_camera *turned);
kc_m004_view_status kc_m004_trace(const kc_m004_scene *scene,
                                 const kc_m004_state *ray,
                                 kc_m004_view_budget budget,
                                 kc_m004_pixel *pixel);
/* Diagnostic colors: marker colors, distance dark blue, crossings yellow,
 * unresolved magenta, numerical range orange, invalid red. This is a CPU
 * reference image, not a claim of physical lighting or GPU acceptance. */
void kc_m004_pixel_rgb(const kc_m004_pixel *pixel, unsigned char rgb[3]);
#endif
