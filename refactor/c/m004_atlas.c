#include "m004_atlas.h"
#include <math.h>
#include <stddef.h>

static const double seam_tolerance=2e-10;
static const double event_tolerance=2e-10;
static const int vertex_signs[4][3]={{1,1,1},{1,-1,-1},{-1,1,-1},{-1,-1,1}};
static const unsigned vertex_images[2][4][4]={
    {{0,1,3,2},{1,2,3,0},{2,3,1,0},{2,1,0,3}},
    {{0,1,3,2},{3,2,0,1},{3,0,1,2},{2,1,0,3}}
};
static long double lorentz_pairing(kc_h3_vector first, kc_h3_vector second)
{
    return (long double)first.x*second.x+(long double)first.y*second.y+
        (long double)first.z*second.z-(long double)first.time*second.time;
}
static kc_m004_status translate_status(kc_h3_status status)
{
    if (status==KC_H3_OK) return KC_M004_OK;
    if (status==KC_H3_INVALID) return KC_M004_INVALID;
    if (status==KC_H3_NUMERICAL_RANGE) return KC_M004_NUMERICAL_RANGE;
    return KC_M004_UNRESOLVED;
}
kc_m004_status kc_m004_face_normal(unsigned face, kc_h3_vector *normal)
{
    if (!normal || face>=4) return KC_M004_INVALID;
    const double scale=1.0/sqrt(3.0);
    *normal=(kc_h3_vector){scale*vertex_signs[face][0],
        scale*vertex_signs[face][1],scale*vertex_signs[face][2],-1.0/3.0};
    return KC_M004_OK;
}
kc_m004_status kc_m004_face_pairing(unsigned tetrahedron, unsigned face,
                                   kc_m004_pairing *pairing)
{
    if (!pairing || tetrahedron>=2 || face>=4) return KC_M004_INVALID;
    kc_m004_pairing result={0};
    result.tetrahedron=1-tetrahedron;
    for (unsigned vertex=0;vertex<4;++vertex)
        result.vertex_image[vertex]=vertex_images[tetrahedron][face][vertex];
    result.face=result.vertex_image[face];
    kc_h3_vector normal;
    (void)kc_m004_face_normal(face,&normal);
    const double components[4]={normal.x,normal.y,normal.z,normal.time};
    double reflection[4][4],permutation[4][4]={{0}};
    for (unsigned row=0;row<4;++row)
        for (unsigned column=0;column<4;++column)
            reflection[row][column]=(row==column ? 1.0 : 0.0)-
                2.25*(row==3 ? -1.0 : 1.0)*components[row]*components[column];
    for (unsigned row=0;row<3;++row)
        for (unsigned column=0;column<3;++column)
            for (unsigned vertex=0;vertex<4;++vertex)
                permutation[row][column]+=0.25*vertex_signs[vertex][row]*
                    vertex_signs[result.vertex_image[vertex]][column];
    permutation[3][3]=1.0;
    for (unsigned row=0;row<4;++row)
        for (unsigned column=0;column<4;++column)
            for (unsigned inner=0;inner<4;++inner)
                result.map.rows[row][column]+=
                    reflection[row][inner]*permutation[inner][column];
    kc_m004_status status=translate_status(kc_h3_validate_isometry(&result.map));
    if (status!=KC_M004_OK) return status;
    *pairing=result;
    return KC_M004_OK;
}
static kc_m004_status validate_geometry(const kc_m004_state *state)
{
    if (!state || state->tetrahedron>=2 || state->incoming_face < -1 ||
        state->incoming_face>=4) return KC_M004_INVALID;
    kc_h3_frame checked;
    return translate_status(kc_h3_transport_frame(&state->ray,0.0,
        &state->frame,&checked));
}
kc_m004_status kc_m004_validate_state(const kc_m004_state *state)
{
    kc_m004_status status=validate_geometry(state);
    if (status!=KC_M004_OK) return status;
    for (unsigned face=0;face<4;++face) {
        kc_h3_vector normal;
        (void)kc_m004_face_normal(face,&normal);
        long double side=lorentz_pairing(state->ray.position,normal);
        long double derivative=lorentz_pairing(state->ray.direction,normal);
        if ((int)face==state->incoming_face) {
            if (fabsl(side)>seam_tolerance || derivative<=seam_tolerance)
                return KC_M004_INVALID;
        } else {
            if (side < -seam_tolerance) return KC_M004_INVALID;
            if (side<=seam_tolerance) return KC_M004_UNRESOLVED;
        }
    }
    return KC_M004_OK;
}
kc_m004_status kc_m004_reorient(const kc_m004_state *state,
                               kc_h3_vector direction,kc_m004_state *oriented)
{
    if (!oriented) return KC_M004_INVALID;
    kc_m004_status status=kc_m004_validate_state(state);
    if (status!=KC_M004_OK) return status;
    kc_m004_state result=*state;
    result.ray.direction=direction;
    status=validate_geometry(&result);
    if (status!=KC_M004_OK) return status;
    if (state->incoming_face>=0) {
        kc_h3_vector normal;
        (void)kc_m004_face_normal((unsigned)state->incoming_face,&normal);
        long double derivative=lorentz_pairing(direction,normal);
        if (fabsl(derivative)<=seam_tolerance) return KC_M004_UNRESOLVED;
        if (derivative<0.0L) {
            kc_m004_pairing pairing;
            status=kc_m004_face_pairing(state->tetrahedron,
                (unsigned)state->incoming_face,&pairing);
            if (status!=KC_M004_OK) return status;
            kc_m004_state mapped=result;
            status=translate_status(kc_h3_apply_isometry(&pairing.map,&result.ray,
                &mapped.ray));
            if (status!=KC_M004_OK) return status;
            status=translate_status(kc_h3_map_frame(&pairing.map,&result.ray,
                &result.frame,&mapped.frame));
            if (status!=KC_M004_OK) return status;
            mapped.tetrahedron=pairing.tetrahedron;
            mapped.incoming_face=(int)pairing.face;
            result=mapped;
        }
    }
    status=kc_m004_validate_state(&result);
    if (status!=KC_M004_OK) return status;
    *oriented=result;
    return KC_M004_OK;
}
static kc_m004_status advance_state(const kc_m004_state *state,double distance,
                                    kc_m004_state *advanced)
{
    kc_m004_state result=*state;
    kc_m004_status status=translate_status(kc_h3_advance(&state->ray,distance,
        &result.ray));
    if (status!=KC_M004_OK) return status;
    status=translate_status(kc_h3_transport_frame(&state->ray,distance,
        &state->frame,&result.frame));
    if (status!=KC_M004_OK) return status;
    if (result.incoming_face>=0) {
        kc_h3_vector normal;
        (void)kc_m004_face_normal((unsigned)result.incoming_face,&normal);
        if (lorentz_pairing(result.ray.position,normal)>seam_tolerance)
            result.incoming_face=-1;
    }
    *advanced=result;
    return KC_M004_OK;
}
kc_m004_status kc_m004_first_event(const kc_m004_state *state,
                                  double distance_limit,kc_m004_event *event)
{
    if (!event || !isfinite(distance_limit) || distance_limit<0.0)
        return KC_M004_INVALID;
    if (distance_limit>4.0) return KC_M004_NUMERICAL_RANGE;
    kc_m004_status status=kc_m004_validate_state(state);
    if (status!=KC_M004_OK) return status;
    double first_distance=INFINITY;
    unsigned first_face=4;
    int beyond_budget=0,tied=0;
    for (unsigned face=0;face<4;++face) {
        if ((int)face==state->incoming_face) continue;
        kc_h3_vector normal;
        (void)kc_m004_face_normal(face,&normal);
        long double side=lorentz_pairing(state->ray.position,normal);
        long double derivative=lorentz_pairing(state->ray.direction,normal);
        if (derivative>=0.0L) continue;
        long double parameter=-side/derivative;
        /* The ideal endpoint is infinitely far away. A finite budget is
         * safe when tanh(budget) is separated from an uncertain root. */
        long double budget_parameter=tanhl((long double)distance_limit);
        if (parameter>budget_parameter+event_tolerance) {
            if (parameter<1.0L+event_tolerance) beyond_budget=1;
            continue;
        }
        if (parameter>=1.0L-event_tolerance) return KC_M004_UNRESOLVED;
        if (!(parameter>0.0L)) return KC_M004_UNRESOLVED;
        double distance=(double)atanhl(parameter);
        if (distance>distance_limit) {
            beyond_budget=1;
            continue;
        }
        if (distance<=event_tolerance) return KC_M004_UNRESOLVED;
        if (distance<first_distance-event_tolerance) {
            first_distance=distance; first_face=face; tied=0;
        } else if (fabs(distance-first_distance)<=event_tolerance) tied=1;
    }
    if (first_face==4)
        return beyond_budget ? KC_M004_DISTANCE_LIMIT : KC_M004_NO_FACE;
    if (tied) return KC_M004_UNRESOLVED;
    kc_m004_event result={0};
    result.source_face=first_face;
    result.distance=first_distance;
    status=advance_state(state,first_distance,&result.before);
    if (status!=KC_M004_OK) return status;
    result.before.incoming_face=-1;
    /* The outgoing boundary state is recorded, but is not accepted as an
     * interior/incoming state by validate_state. */
    for (unsigned face=0;face<4;++face) {
        kc_h3_vector normal;
        (void)kc_m004_face_normal(face,&normal);
        long double side=lorentz_pairing(result.before.ray.position,normal);
        if (face==first_face) {
            if (fabsl(side)>seam_tolerance) return KC_M004_UNRESOLVED;
        } else if (side<=seam_tolerance) return KC_M004_UNRESOLVED;
    }
    kc_m004_pairing pairing;
    status=kc_m004_face_pairing(state->tetrahedron,first_face,&pairing);
    if (status!=KC_M004_OK) return status;
    result.after=result.before;
    result.after.tetrahedron=pairing.tetrahedron;
    result.after.incoming_face=(int)pairing.face;
    status=translate_status(kc_h3_apply_isometry(&pairing.map,&result.before.ray,
        &result.after.ray));
    if (status!=KC_M004_OK) return status;
    status=translate_status(kc_h3_map_frame(&pairing.map,&result.before.ray,
        &result.before.frame,&result.after.frame));
    if (status!=KC_M004_OK) return status;
    status=kc_m004_validate_state(&result.after);
    if (status!=KC_M004_OK) return status;
    *event=result;
    return KC_M004_OK;
}
kc_m004_status kc_m004_travel(const kc_m004_state *state,double distance,
                            unsigned crossing_limit,kc_m004_journey *journey)
{
    if (!journey || !isfinite(distance) || distance<0.0) return KC_M004_INVALID;
    if (distance>64.0 || crossing_limit>4096) return KC_M004_NUMERICAL_RANGE;
    kc_m004_status status=kc_m004_validate_state(state);
    if (status!=KC_M004_OK) return status;
    kc_m004_journey result={*state,0};
    double remaining=distance;
    unsigned iterations=0;
    while (remaining>0.0) {
        if (++iterations>4161) return KC_M004_NUMERICAL_RANGE;
        double segment=remaining<1.0 ? remaining : 1.0;
        kc_m004_event event;
        status=kc_m004_first_event(&result.state,segment,&event);
        double consumed;
        if (status==KC_M004_OK) {
            if (result.crossings==crossing_limit) return KC_M004_CROSSING_LIMIT;
            result.state=event.after;
            ++result.crossings;
            consumed=event.distance;
        } else if (status==KC_M004_DISTANCE_LIMIT || status==KC_M004_NO_FACE) {
            kc_m004_state advanced;
            status=advance_state(&result.state,segment,&advanced);
            if (status!=KC_M004_OK) return status;
            status=kc_m004_validate_state(&advanced);
            if (status!=KC_M004_OK) return status;
            result.state=advanced;
            consumed=segment;
        } else return status;
        double next_remaining=remaining-consumed;
        if (!(next_remaining<remaining) || next_remaining<0.0)
            return KC_M004_UNRESOLVED;
        remaining=next_remaining;
    }
    *journey=result;
    return KC_M004_OK;
}
