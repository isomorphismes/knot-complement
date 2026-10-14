#include "m004_view.h"

#include <math.h>
#include <stddef.h>

static kc_h3_vector combine(kc_h3_vector first, double a,
                            kc_h3_vector second, double b) {
    kc_h3_vector result = {a*first.x+b*second.x, a*first.y+b*second.y,
                          a*first.z+b*second.z, a*first.time+b*second.time};
    return result;
}

static double product(kc_h3_vector first, kc_h3_vector second) {
    return first.x*second.x+first.y*second.y+first.z*second.z
           -first.time*second.time;
}

kc_m004_status kc_m004_camera_validate(const kc_m004_camera *camera) {
    if (!camera || !isfinite(camera->tangent_half_vertical_fov) ||
        camera->tangent_half_vertical_fov <= 0.0 ||
        camera->tangent_half_vertical_fov > 4.0 ||
        !isfinite(camera->aspect) || camera->aspect <= 0.0 || camera->aspect > 4.0)
        return KC_M004_INVALID;
    return kc_m004_validate_state(&camera->state);
}

kc_m004_status kc_m004_camera_ray(const kc_m004_camera *camera,
                                 double sensor_x, double sensor_y,
                                 kc_m004_state *ray) {
    kc_m004_status status;
    kc_m004_state candidate;
    double x, y, norm;
    if (!ray || !isfinite(sensor_x) || !isfinite(sensor_y) ||
        fabs(sensor_x)>1.0 || fabs(sensor_y)>1.0) return KC_M004_INVALID;
    status=kc_m004_camera_validate(camera);
    if (status!=KC_M004_OK) return status;
    x=sensor_x*camera->aspect*camera->tangent_half_vertical_fov;
    y=sensor_y*camera->tangent_half_vertical_fov;
    norm=sqrt(1.0+x*x+y*y);
    candidate=camera->state;
    kc_h3_vector direction=combine(candidate.frame.forward,1.0/norm,
                                    candidate.frame.right,x/norm);
    direction=combine(direction,1.0,candidate.frame.up,y/norm);
    /* A ray starting exactly on a seam may point into either chart. The
     * atlas maps all state for an outward direction without moving it. */
    status=kc_m004_reorient(&camera->state,direction,&candidate);
    if (status!=KC_M004_OK) return status;
    candidate.ray.travelled=0.0;
    *ray=candidate;
    return KC_M004_OK;
}

kc_m004_status kc_m004_camera_move(const kc_m004_camera *camera, double distance,
                                  unsigned crossing_limit,
                                  kc_m004_camera *moved) {
    kc_m004_camera candidate;
    kc_m004_journey journey;
    kc_m004_status status;
    if (!moved) return KC_M004_INVALID;
    status=kc_m004_camera_validate(camera);
    if (status!=KC_M004_OK) return status;
    candidate=*camera;
    status=kc_m004_reorient(&camera->state,camera->state.frame.forward,
                            &candidate.state);
    if (status!=KC_M004_OK) return status;
    status=kc_m004_travel(&candidate.state,distance,crossing_limit,&journey);
    if (status!=KC_M004_OK) return status;
    candidate.state=journey.state;
    *moved=candidate;
    return KC_M004_OK;
}

kc_m004_status kc_m004_camera_turn(const kc_m004_camera *camera,
                                  double yaw, double pitch,
                                  kc_m004_camera *turned) {
    kc_m004_camera candidate;
    kc_h3_vector forward, right, up;
    kc_m004_status status;
    if (!turned || !isfinite(yaw) || !isfinite(pitch) ||
        fabs(yaw)>3.14159265358979323846 || fabs(pitch)>3.14159265358979323846)
        return KC_M004_INVALID;
    status=kc_m004_camera_validate(camera);
    if (status!=KC_M004_OK) return status;
    candidate=*camera;
    forward=combine(candidate.state.frame.forward,cos(yaw),
                    candidate.state.frame.right,sin(yaw));
    right=combine(candidate.state.frame.right,cos(yaw),
                  candidate.state.frame.forward,-sin(yaw));
    up=combine(candidate.state.frame.up,cos(pitch),forward,-sin(pitch));
    forward=combine(forward,cos(pitch),candidate.state.frame.up,sin(pitch));
    candidate.state.frame=(kc_h3_frame){right,up,forward};
    kc_m004_state oriented;
    status=kc_m004_reorient(&candidate.state,forward,&oriented);
    if (status!=KC_M004_OK) return status;
    candidate.state=oriented;
    *turned=candidate;
    return KC_M004_OK;
}

static kc_m004_view_status view_status(kc_m004_status status) {
    if (status==KC_M004_NUMERICAL_RANGE) return KC_M004_VIEW_NUMERICAL_RANGE;
    if (status==KC_M004_UNRESOLVED) return KC_M004_VIEW_UNRESOLVED;
    return KC_M004_VIEW_INVALID;
}

static kc_m004_view_status finish(kc_m004_pixel *candidate,
                                  kc_m004_view_status status,
                                  kc_m004_pixel *pixel) {
    candidate->status=status;
    *pixel=*candidate;
    return status;
}

kc_m004_view_status kc_m004_trace(const kc_m004_scene *scene,
                                 const kc_m004_state *ray,
                                 kc_m004_view_budget budget,
                                 kc_m004_pixel *pixel) {
    kc_m004_pixel candidate;
    kc_m004_status status;
    double remaining;
    if (!scene || !ray || !pixel || scene->marker_mask>3 ||
        !isfinite(scene->radius) || scene->radius<=0.0 ||
        scene->radius>=0.5*log(2.0)-1e-8 || !isfinite(budget.distance) ||
        budget.distance<0.0 || budget.distance>64.0 || budget.crossings>4096)
        return KC_M004_VIEW_INVALID;
    status=kc_m004_validate_state(ray);
    if (status!=KC_M004_OK) return view_status(status);
    candidate=(kc_m004_pixel){KC_M004_VIEW_DISTANCE_LIMIT,*ray,0,-1,0.0};
    /* The optical budget is local to this trace; inherited odometry is not
     * consumed or reset. camera_ray supplies zero optical travel normally. */
    remaining=budget.distance;
    while (remaining>0.0) {
        kc_m004_event event;
        double segment=fmin(remaining,1.0);
        /* Each admitted sphere lies strictly inside this geodesically convex
         * tetrahedron. A segment reaching it from this tetrahedron cannot
         * cross a face first. Test it before even an ambiguous later edge. */
        if (scene->marker_mask & (1u<<candidate.endpoint.tetrahedron)) {
            kc_h3_hit hit;
            kc_h3_status hit_status=kc_h3_sphere_hit(&candidate.endpoint.ray,
                (kc_h3_vector){0,0,0,1},scene->radius,segment,&hit);
            if (hit_status==KC_H3_OK) {
                kc_h3_frame frame;
                kc_h3_vector normal;
                kc_h3_status frame_status=kc_h3_transport_frame(
                    &candidate.endpoint.ray,hit.distance,
                    &candidate.endpoint.frame,&frame);
                if (frame_status!=KC_H3_OK)
                    return finish(&candidate,KC_M004_VIEW_NUMERICAL_RANGE,pixel);
                candidate.marker=(int)candidate.endpoint.tetrahedron;
                candidate.endpoint.ray=hit.ray;
                candidate.endpoint.frame=frame;
                candidate.endpoint.incoming_face=-1;
                normal=combine(hit.ray.position,cosh(scene->radius)/sinh(scene->radius),
                               (kc_h3_vector){0,0,0,1},-1.0/sinh(scene->radius));
                candidate.headlight_cosine=fmax(0.0,fmin(1.0,
                                                   -product(normal,hit.ray.direction)));
                return finish(&candidate,KC_M004_VIEW_HIT,pixel);
            }
            if (hit_status==KC_H3_UNRESOLVED || hit_status==KC_H3_ON_SURFACE)
                return finish(&candidate,KC_M004_VIEW_UNRESOLVED,pixel);
            if (hit_status!=KC_H3_NO_HIT && hit_status!=KC_H3_DISTANCE_LIMIT)
                return finish(&candidate,KC_M004_VIEW_NUMERICAL_RANGE,pixel);
        }
        status=kc_m004_first_event(&candidate.endpoint,segment,&event);
        if (status==KC_M004_OK) segment=event.distance;
        else if (status!=KC_M004_NO_FACE && status!=KC_M004_DISTANCE_LIMIT)
            return finish(&candidate,view_status(status),pixel);
        if (status==KC_M004_OK) {
            if (candidate.crossings==budget.crossings)
                return finish(&candidate,KC_M004_VIEW_CROSSING_LIMIT,pixel);
            candidate.endpoint=event.after;
            candidate.crossings++;
        } else {
            kc_m004_journey journey;
            status=kc_m004_travel(&candidate.endpoint,segment,0,&journey);
            if (status!=KC_M004_OK)
                return finish(&candidate,view_status(status),pixel);
            candidate.endpoint=journey.state;
        }
        remaining=fmax(0.0,remaining-segment);
    }
    return finish(&candidate,KC_M004_VIEW_DISTANCE_LIMIT,pixel);
}

void kc_m004_pixel_rgb(const kc_m004_pixel *pixel, unsigned char rgb[3]) {
    static const unsigned char diagnostic[6][3]={
        {255,255,255},{8,16,28},{255,220,0},{255,0,255},{255,128,0},{255,0,0}};
    unsigned status;
    if (!rgb) return;
    status=pixel ? (unsigned)pixel->status : KC_M004_VIEW_INVALID;
    if (status>KC_M004_VIEW_INVALID) status=KC_M004_VIEW_INVALID;
    if (status==KC_M004_VIEW_HIT && (pixel->marker==0 || pixel->marker==1) &&
        isfinite(pixel->headlight_cosine) && pixel->headlight_cosine>=0.0 &&
        pixel->headlight_cosine<=1.0) {
        double brightness=0.2+0.8*pixel->headlight_cosine;
        unsigned char base[2][3]={{55,190,255},{255,112,55}};
        for (unsigned i=0;i<3;i++) rgb[i]=(unsigned char)(base[pixel->marker][i]*brightness);
    } else for (unsigned i=0;i<3;i++) rgb[i]=diagnostic[status][i];
}
