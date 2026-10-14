#ifndef KC_M004_ATLAS_H
#define KC_M004_ATLAS_H

#include "h3_ray.h"

/* Fixed, labelled, complete two-regular-ideal-tetrahedron m004 atlas.
 * Faces are opposite their vertex number; vectors use the H3 time-last,
 * row-vector convention. An incoming_face is a checked seam witness,
 * not permission to skip an arbitrary face. -1 denotes interior state. */
typedef struct {
    unsigned tetrahedron;
    int incoming_face;
    kc_h3_ray ray;
    kc_h3_frame frame;
} kc_m004_state;
typedef struct {
    unsigned tetrahedron, face;
    unsigned vertex_image[4];
    kc_h3_direct_isometry map;
} kc_m004_pairing;
typedef struct {
    unsigned source_face;
    double distance;
    kc_m004_state before;
    kc_m004_state after;
} kc_m004_event;
typedef enum {
    KC_M004_OK = 0,
    KC_M004_INVALID = 1,
    KC_M004_NUMERICAL_RANGE = 2,
    KC_M004_NO_FACE = 3,
    KC_M004_DISTANCE_LIMIT = 4,
    KC_M004_UNRESOLVED = 5,
    KC_M004_CROSSING_LIMIT = 6
} kc_m004_status;
typedef struct { kc_m004_state state; unsigned crossings; } kc_m004_journey;

/* Values are forgeable; all consumers validate them. Failures leave outputs
 * unchanged. No cusp truncation or material boundary is introduced. */
kc_m004_status kc_m004_face_normal(unsigned face, kc_h3_vector *normal);
kc_m004_status kc_m004_face_pairing(unsigned tetrahedron, unsigned face,
                                   kc_m004_pairing *pairing);
kc_m004_status kc_m004_validate_state(const kc_m004_state *state);
/* Select a different unit viewing tangent at the same point. At a seam,
 * an outward tangent changes representative through the inverse pairing;
 * frame and travel follow it, with zero added length. Grazing is unresolved. */
kc_m004_status kc_m004_reorient(const kc_m004_state *state,
                               kc_h3_vector direction,kc_m004_state *oriented);
/* An event exactly at the distance budget is included. Ambiguous tied or
 * grazing events are UNRESOLVED; a numerical refusal is never an escape. */
kc_m004_status kc_m004_first_event(const kc_m004_state *state,
                                  double distance_limit, kc_m004_event *event);
/* Length <= 64; integration segments <= 1. Inputs and all three frame vectors
 * remain authoritative. crossing_limit is a budget, not a face boundary. */
kc_m004_status kc_m004_travel(const kc_m004_state *state, double distance,
                            unsigned crossing_limit, kc_m004_journey *journey);
#endif
