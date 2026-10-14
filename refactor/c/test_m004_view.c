#include "m004_view.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned assertions;
static void check(int condition, const char *message) {
    ++assertions;
    if (!condition) { fprintf(stderr,"FAIL: %s\n",message); exit(1); }
}
static void close_to(double got, double expected, const char *message) {
    ++assertions;
    if (!isfinite(got) || !isfinite(expected) || fabs(got-expected)>2e-8) {
        fprintf(stderr,"FAIL: %s got %.17g expected %.17g\n",message,got,expected);
        exit(1);
    }
}
static void equal_vector(kc_h3_vector first, kc_h3_vector second, const char *name) {
    close_to(first.x,second.x,name); close_to(first.y,second.y,name);
    close_to(first.z,second.z,name); close_to(first.time,second.time,name);
}
static kc_m004_camera initial_camera(void) {
    const double a=1/sqrt(3.0),b=1/sqrt(2.0),c=1/sqrt(6.0);
    kc_h3_vector forward={-a,-a,-a,0};
    kc_h3_frame frame={{b,-b,0,0},{-c,-c,2*c,0},forward};
    return (kc_m004_camera){{0,-1,{{0,0,0,1},forward,0},frame},0.6,1.5};
}

int main(int argc, char **argv) {
    kc_m004_camera camera=initial_camera(),copy=camera,moved,turned;
    kc_m004_state ray,other;
    kc_m004_scene scene={2,log(2.0)/8.0};
    kc_m004_pixel pixel;
    kc_m004_view_budget budget={3.0,32};
    check(kc_m004_camera_validate(&camera)==KC_M004_OK,"camera admitted");
    check(kc_m004_camera_ray(&camera,0,0,&ray)==KC_M004_OK,"centre viewing ray");
    equal_vector(ray.ray.direction,camera.state.frame.forward,"centre direction");
    check(memcmp(&camera,&copy,sizeof camera)==0,"sampling leaves camera unchanged");
    check(kc_m004_trace(&scene,&ray,budget,&pixel)==KC_M004_VIEW_HIT,
          "marker behind one identified face");
    check(pixel.marker==1 && pixel.crossings==1,"correct marker and crossing count");
    close_to(pixel.endpoint.ray.travelled,7*log(2.0)/8.0,
             "independent axial entry log 2 minus radius");
    close_to(pixel.headlight_cosine,1.0,"axial headlight cosine");
    check(kc_m004_validate_state(&pixel.endpoint)==KC_M004_OK,"hit endpoint valid");
    check(memcmp(&camera,&copy,sizeof camera)==0,"trace leaves camera unchanged");

    /* A local object must be tested before the first chart transition. */
    scene.marker_mask=1;
    check(kc_m004_trace(&scene,&ray,budget,&pixel)==KC_M004_VIEW_HIT,
          "local sphere precedes face");
    check(pixel.marker==0 && pixel.crossings==0,"local object has zero crossings");
    close_to(pixel.endpoint.ray.travelled,scene.radius,"inside sphere exit length");
    other=ray;
    other.ray.direction=(kc_h3_vector){-1,0,0,0};
    check(kc_m004_trace(&scene,&other,budget,&pixel)==KC_M004_VIEW_HIT,
          "local object before ambiguous later edge");
    check(pixel.crossings==0,"ambiguous later edge not visited");
    scene.marker_mask=2;
    check(kc_m004_trace(&scene,&ray,(kc_m004_view_budget){0.2,32},&pixel)
          ==KC_M004_VIEW_DISTANCE_LIMIT,"visual distance is explicit");
    close_to(pixel.endpoint.ray.travelled,0.2,"distance endpoint");
    check(pixel.marker==-1,"distance is not object hit");
    check(kc_m004_trace(&scene,&ray,(kc_m004_view_budget){3,0},&pixel)
          ==KC_M004_VIEW_CROSSING_LIMIT,"crossing budget is explicit");
    check(pixel.crossings==0 && pixel.marker==-1,"crossing limit is not background");
    scene.marker_mask=0;
    check(kc_m004_trace(&scene,&ray,(kc_m004_view_budget){0,0},&pixel)
          ==KC_M004_VIEW_DISTANCE_LIMIT,"zero budget");
    close_to(pixel.endpoint.ray.travelled,0,"zero budget endpoint");

    /* Same sensor ray at the centre of 3x3 and 9x9 images. Only samples change. */
    check(kc_m004_camera_ray(&camera,2.0*(1.0+0.5)/3.0-1.0,
                            1.0-2.0*(1.0+0.5)/3.0,&ray)==KC_M004_OK,"3x3 centre");
    check(kc_m004_camera_ray(&camera,2.0*(4.0+0.5)/9.0-1.0,
                            1.0-2.0*(4.0+0.5)/9.0,&other)==KC_M004_OK,"9x9 centre");
    equal_vector(ray.ray.direction,other.ray.direction,"density-invariant ray");
    check(memcmp(&camera,&copy,sizeof camera)==0,"density leaves authoritative camera");
    check(kc_m004_camera_ray(&camera,1,-1,&other)==KC_M004_OK,"sensor corner");
    check(kc_h3_validate_ray(&other.ray)==KC_H3_OK,"corner normalized intrinsic ray");

    check(kc_m004_camera_move(&camera,0.5,8,&moved)==KC_M004_OK,"camera crosses face");
    check(moved.state.tetrahedron==1,"camera recharted");
    close_to(moved.state.ray.travelled,0.5,"camera odometry preserved");
    check(kc_m004_camera_ray(&moved,0,0,&ray)==KC_M004_OK,"ray after camera movement");
    close_to(ray.ray.travelled,0,"view optical distance starts at zero");
    scene.marker_mask=2;
    check(kc_m004_trace(&scene,&ray,budget,&pixel)==KC_M004_VIEW_HIT,"same object after movement");
    close_to(pixel.endpoint.ray.travelled,7*log(2.0)/8.0-0.5,
             "moving camera reduces object optical distance");
    check(pixel.crossings==0,"camera already in object chart");
    check(kc_m004_camera_turn(&camera,0.3,-0.2,&turned)==KC_M004_OK,"camera yaw pitch");
    equal_vector(turned.state.ray.position,camera.state.ray.position,"turn preserves point");
    close_to(turned.state.ray.travelled,0,"turn preserves odometry");
    check(kc_m004_camera_validate(&turned)==KC_M004_OK,"turned frame valid");
    check(kc_m004_camera_turn(&camera,0,0,&turned)==KC_M004_OK,"zero turn");
    equal_vector(turned.state.frame.forward,camera.state.frame.forward,"zero turn unchanged");

    kc_m004_camera seam;
    check(kc_m004_camera_move(&camera,0.5*log(2.0),8,&seam)==KC_M004_OK,
          "camera may stop exactly on identified face");
    check(seam.state.incoming_face>=0,"stopped camera retains seam witness");
    check(kc_m004_camera_turn(&seam,3.14159265358979323846,0,&turned)==KC_M004_OK,
          "turning outward at seam changes representative");
    check(turned.state.tetrahedron!=seam.state.tetrahedron,"outward seam chart changed");
    close_to(turned.state.ray.travelled,seam.state.ray.travelled,
             "turning at seam adds no travel");
    check(kc_m004_camera_ray(&turned,0,0,&ray)==KC_M004_OK,"view from reversed seam");
    check(kc_m004_validate_state(&ray)==KC_M004_OK,"reversed seam ray valid");

    /* A ray towards an ideal edge has two tied face events, not a wall hit. */
    ray=camera.state;
    ray.ray.direction=(kc_h3_vector){-1,0,0,0};
    check(kc_m004_trace(&scene,&ray,budget,&pixel)==KC_M004_VIEW_UNRESOLVED,
          "edge event is visibly unresolved");
    unsigned char rgb[3];
    kc_m004_pixel_rgb(&pixel,rgb);
    check(rgb[0]==255 && rgb[1]==0 && rgb[2]==255,"unresolved diagnostic magenta");

    kc_m004_pixel sentinel={KC_M004_VIEW_INVALID,camera.state,99,22,0.5};
    pixel=sentinel;
    scene.radius=0.5*log(2.0);
    check(kc_m004_trace(&scene,&camera.state,budget,&pixel)==KC_M004_VIEW_INVALID,
          "object touching chart boundary rejected");
    check(memcmp(&pixel,&sentinel,sizeof pixel)==0,"invalid scene leaves output unchanged");
    scene.radius=log(2.0)/8.0;
    scene.marker_mask=4;
    check(kc_m004_trace(&scene,&camera.state,budget,&pixel)==KC_M004_VIEW_INVALID,
          "invalid marker mask");
    scene.marker_mask=2;
    check(kc_m004_trace(&scene,&camera.state,(kc_m004_view_budget){NAN,3},&pixel)
          ==KC_M004_VIEW_INVALID,"NaN distance");
    copy=camera;
    check(kc_m004_camera_ray(&camera,NAN,0,&ray)==KC_M004_INVALID,"NaN sensor");
    check(kc_m004_camera_ray(&camera,1.1,0,&ray)==KC_M004_INVALID,"out of sensor");
    check(kc_m004_camera_turn(&camera,NAN,0,&copy)==KC_M004_INVALID,"NaN turn");
    check(memcmp(&camera,&copy,sizeof camera)==0,"rejected turn transactional");
    copy.aspect=INFINITY;
    check(kc_m004_camera_validate(&copy)==KC_M004_INVALID,"nonfinite aspect");
    check(kc_m004_trace(NULL,&camera.state,budget,&pixel)==KC_M004_VIEW_INVALID,"null scene");
    check(kc_m004_camera_move(NULL,0.1,3,&moved)==KC_M004_INVALID,"null camera");

    if (argc==3 && strcmp(argv[1],"--emit")==0) {
        FILE *file=fopen(argv[2],"w");
        check(file!=NULL,"open oracle table");
        scene=(kc_m004_scene){2,log(2.0)/8.0};
        check(kc_m004_camera_ray(&camera,0,0,&ray)==KC_M004_OK,"oracle camera ray");
        check(kc_m004_trace(&scene,&ray,budget,&pixel)==KC_M004_VIEW_HIT,"oracle trace");
        fprintf(file,"axial_marker_distance\t%.17g\n",pixel.endpoint.ray.travelled);
        fprintf(file,"axial_marker_crossings\t%u\n",pixel.crossings);
        fprintf(file,"axial_marker_id\t%d\n",pixel.marker);
        fprintf(file,"axial_headlight_cosine\t%.17g\n",pixel.headlight_cosine);
        check(fclose(file)==0,"close oracle table");
    } else check(argc==1,"arguments");
    printf("m004 CPU view: PASS (%u assertions)\n",assertions);
    return 0;
}
