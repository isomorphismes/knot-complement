#include "h3_ray.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned checks;
static void require_status(kc_h3_status actual, kc_h3_status expected,
                           const char *label)
{
    ++checks;
    if (actual!=expected) {
        fprintf(stderr,"%s: status %d, expected %d\n",label,actual,expected);
        exit(1);
    }
}
static void require_close(double actual, double expected, const char *label)
{
    ++checks;
    if (!isfinite(actual) || !isfinite(expected) || fabs(actual-expected)>2e-10) {
        fprintf(stderr,"%s: %.17g, expected %.17g\n",label,actual,expected);
        exit(1);
    }
}
static void require_vector(kc_h3_vector actual, kc_h3_vector expected,
                           const char *label)
{
    require_close(actual.x,expected.x,label);
    require_close(actual.y,expected.y,label);
    require_close(actual.z,expected.z,label);
    require_close(actual.time,expected.time,label);
}
static void emit_vector(FILE *output, const char *prefix, kc_h3_vector vector)
{
    fprintf(output,"%s.x\t%.17g\n%s.y\t%.17g\n%s.z\t%.17g\n%s.time\t%.17g\n",
        prefix,vector.x,prefix,vector.y,prefix,vector.z,prefix,vector.time);
}
int main(int argc, char **argv)
{
    FILE *output=NULL;
    if (argc==3 && strcmp(argv[1],"--emit")==0) {
        output=fopen(argv[2],"w");
        if (!output) return 2;
    } else if (argc!=1) return 2;
    const kc_h3_ray initial={{0,0,0,1},{1,0,0,0},2.0};
    const kc_h3_frame frame={{0,1,0,0},{0,0,1,0},{1,0,0,0}};
    const double step=log(2.0);
    const kc_h3_vector exact_point={3.0/4.0,0,0,5.0/4.0};
    const kc_h3_vector exact_direction={5.0/4.0,0,0,3.0/4.0};
    kc_h3_ray advanced;
    require_status(kc_h3_advance(&initial,step,&advanced),KC_H3_OK,"advance");
    require_vector(advanced.position,exact_point,"exact point");
    require_vector(advanced.direction,exact_direction,"exact direction");
    require_close(advanced.travelled,2.0+step,"accumulated distance");
    double measured;
    require_status(kc_h3_distance(initial.position,advanced.position,&measured),
        KC_H3_OK,"distance");
    require_close(measured,step,"intrinsic distance");
    if (output) {
        emit_vector(output,"point",advanced.position);
        emit_vector(output,"direction",advanced.direction);
        fprintf(output,"travelled\t%.17g\ndistance\t%.17g\n",advanced.travelled,measured);
    }
    kc_h3_chart_ray converted;
    const kc_h3_chart charts[3]={KC_H3_UPPER_HALF_SPACE,KC_H3_KLEIN,KC_H3_POINCARE};
    const double chart_positions[3][3]={{3.0/5.0,0,4.0/5.0},{3.0/5.0,0,0},{1.0/3.0,0,0}};
    const double chart_velocities[3][3]={{16.0/25.0,0,-12.0/25.0},{16.0/25.0,0,0},{4.0/9.0,0,0}};
    const char *chart_names[3]={"upper","klein","poincare"};
    for (size_t chart=0; chart<3; ++chart) {
        require_status(kc_h3_change_chart(&advanced,charts[chart],&converted),KC_H3_OK,"chart");
        for (size_t coordinate=0; coordinate<3; ++coordinate) {
            require_close(converted.position[coordinate],chart_positions[chart][coordinate],"chart point");
            require_close(converted.velocity[coordinate],chart_velocities[chart][coordinate],"chart tangent");
            if (output) fprintf(output,"%s.position.%zu\t%.17g\n%s.velocity.%zu\t%.17g\n",
                chart_names[chart],coordinate,converted.position[coordinate],
                chart_names[chart],coordinate,converted.velocity[coordinate]);
        }
        if (chart==0) {
            double height=converted.position[2];
            double speed_squared=(converted.velocity[0]*converted.velocity[0]+
                converted.velocity[1]*converted.velocity[1]+
                converted.velocity[2]*converted.velocity[2])/(height*height);
            require_close(speed_squared,1.0,"upper-half-space metric speed");
        }
    }
    kc_h3_frame transported;
    require_status(kc_h3_transport_frame(&initial,step,&frame,&transported),KC_H3_OK,"frame transport");
    require_vector(transported.right,frame.right,"right transport");
    require_vector(transported.up,frame.up,"up transport");
    require_vector(transported.forward,exact_direction,"forward transport");
    if (output) emit_vector(output,"frame.forward",transported.forward);
    const kc_h3_direct_isometry boost={{{1.25,0,0,0.75},{0,1,0,0},{0,0,1,0},{0.75,0,0,1.25}}};
    kc_h3_ray mapped;
    require_status(kc_h3_apply_isometry(&boost,&initial,&mapped),KC_H3_OK,"isometry");
    require_vector(mapped.position,exact_point,"mapped point");
    require_vector(mapped.direction,exact_direction,"mapped direction");
    require_close(mapped.travelled,initial.travelled,"representative change preserves travel");
    require_status(kc_h3_map_frame(&boost,&initial,&frame,&transported),KC_H3_OK,"map whole frame");
    require_vector(transported.forward,exact_direction,"mapped forward");
    /* The boost is symmetric as a stored matrix. A nonsymmetric rotation
       catches accidental column-vector application that it cannot expose. */
    const kc_h3_direct_isometry quarter_turn={{{0,1,0,0},{-1,0,0,0},{0,0,1,0},{0,0,0,1}}};
    kc_h3_ray rotated;
    require_status(kc_h3_apply_isometry(&quarter_turn,&initial,&rotated),KC_H3_OK,"quarter turn");
    require_vector(rotated.direction,(kc_h3_vector){0,1,0,0},"row-vector rotation direction");
    require_status(kc_h3_map_frame(&quarter_turn,&initial,&frame,&transported),KC_H3_OK,"rotated frame");
    require_vector(transported.right,(kc_h3_vector){-1,0,0,0},"rotated right");
    require_vector(transported.up,frame.up,"rotated up");
    require_vector(transported.forward,(kc_h3_vector){0,1,0,0},"rotated forward");
    kc_h3_ray rotated_advance, advanced_rotation;
    require_status(kc_h3_advance(&rotated,step,&rotated_advance),KC_H3_OK,"advance rotated ray");
    require_status(kc_h3_apply_isometry(&quarter_turn,&advanced,&advanced_rotation),KC_H3_OK,"rotate advanced ray");
    require_vector(rotated_advance.position,(kc_h3_vector){0,0.75,0,1.25},"rotated exact point");
    require_vector(rotated_advance.position,advanced_rotation.position,"isometry and advance commute");
    kc_h3_direct_isometry bad_isometry=boost;
    bad_isometry.rows[0][0]=NAN;
    require_status(kc_h3_validate_isometry(&bad_isometry),KC_H3_INVALID,"nonfinite isometry");
    const kc_h3_direct_isometry reflection={{{-1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}}};
    require_status(kc_h3_validate_isometry(&reflection),KC_H3_INVALID,"orientation reversal");
    bad_isometry=reflection;
    bad_isometry.rows[0][0]=1;
    bad_isometry.rows[3][3]=-1;
    require_status(kc_h3_validate_isometry(&bad_isometry),KC_H3_INVALID,"time reversal");
    kc_h3_ray first, second, combined;
    require_status(kc_h3_advance(&initial,0.2,&first),KC_H3_OK,"first segment");
    require_status(kc_h3_advance(&first,0.3,&second),KC_H3_OK,"second segment");
    require_status(kc_h3_advance(&initial,0.5,&combined),KC_H3_OK,"combined segment");
    require_vector(second.position,combined.position,"composition point");
    require_vector(second.direction,combined.direction,"composition direction");
    require_close(second.travelled,combined.travelled,"composition travel");
    first=initial;
    for (unsigned iteration=0; iteration<100; ++iteration) {
        require_status(kc_h3_advance(&first,0.02,&second),KC_H3_OK,"repeated segment");
        first=second;
    }
    require_status(kc_h3_advance(&initial,2.0,&combined),KC_H3_OK,"longer oracle segment");
    require_vector(first.position,combined.position,"repeated composition point");
    require_vector(first.direction,combined.direction,"repeated composition tangent");
    require_close(first.travelled,4.0,"repeated travel");
    kc_h3_ray returning=advanced;
    returning.direction=(kc_h3_vector){-exact_direction.x,0,0,-exact_direction.time};
    require_status(kc_h3_advance(&returning,step,&second),KC_H3_OK,"return path");
    require_vector(second.position,initial.position,"return point");
    require_close(second.travelled,2.0+2.0*step,"return travel");
    kc_h3_hit hit;
    require_status(kc_h3_plane_hit(&initial,(kc_h3_vector){1,0,0,0.6},4.0,&hit),KC_H3_OK,"plane event");
    require_close(hit.distance,step,"plane distance");
    require_vector(hit.ray.position,exact_point,"plane point");
    if (output) fprintf(output,"plane.distance\t%.17g\n",hit.distance);
    kc_h3_vector sphere_center={15.0/8.0,0,0,17.0/8.0};
    require_status(kc_h3_sphere_hit(&initial,sphere_center,step,4.0,&hit),KC_H3_OK,"sphere event");
    require_close(hit.distance,step,"sphere distance");
    require_vector(hit.ray.position,exact_point,"sphere point");
    if (output) fprintf(output,"sphere.distance\t%.17g\n",hit.distance);
    require_status(kc_h3_sphere_hit(&initial,initial.position,step,4.0,&hit),KC_H3_OK,"sphere exit from inside");
    require_close(hit.distance,step,"sphere exit distance");
    const kc_h3_hit retained=hit;
    require_status(kc_h3_plane_hit(&initial,(kc_h3_vector){1,0,0,0.6},0.1,&hit),KC_H3_DISTANCE_LIMIT,"plane limit");
    if (memcmp(&hit,&retained,sizeof hit)!=0) return 1;
    require_status(kc_h3_sphere_hit(&initial,sphere_center,step,0.1,&hit),KC_H3_DISTANCE_LIMIT,"sphere limit");
    if (memcmp(&hit,&retained,sizeof hit)!=0) return 1;
    require_status(kc_h3_plane_hit(&initial,(kc_h3_vector){1,0,0,-0.6},4.0,&hit),KC_H3_NO_HIT,"plane behind");
    require_status(kc_h3_plane_hit(&initial,(kc_h3_vector){0,1,0,0.6},4.0,&hit),KC_H3_NO_HIT,"parallel plane");
    require_status(kc_h3_plane_hit(&initial,(kc_h3_vector){1,0,0,0},4.0,&hit),KC_H3_ON_SURFACE,"starting on plane");
    require_status(kc_h3_plane_hit(&initial,(kc_h3_vector){1,0,0,1e-12},4.0,&hit),KC_H3_UNRESOLVED,"uncertain plane event");
    require_status(kc_h3_plane_hit(&initial,(kc_h3_vector){0,0,0,1},4.0,&hit),KC_H3_INVALID,"invalid plane normal");
    sphere_center.x=-sphere_center.x;
    require_status(kc_h3_sphere_hit(&initial,sphere_center,step,4.0,&hit),KC_H3_NO_HIT,"sphere behind");
    sphere_center=(kc_h3_vector){0,sinh(2.0),0,cosh(2.0)};
    require_status(kc_h3_sphere_hit(&initial,sphere_center,step,4.0,&hit),KC_H3_NO_HIT,"sphere off ray");
    sphere_center=(kc_h3_vector){0,0.75,0,1.25};
    require_status(kc_h3_sphere_hit(&initial,sphere_center,step,4.0,&hit),KC_H3_UNRESOLVED,"sphere tangency");
    const kc_h3_vector invalid_points[]={{1,0,0,0},{0,0,0,-1},{0,0,0,0},{NAN,0,0,1},{INFINITY,0,0,1}};
    for (size_t index=0; index<sizeof invalid_points/sizeof invalid_points[0]; ++index) {
        kc_h3_ray invalid=initial;
        invalid.position=invalid_points[index];
        require_status(kc_h3_advance(&invalid,step,&second),KC_H3_INVALID,"invalid point");
        require_status(kc_h3_distance(invalid.position,initial.position,&measured),KC_H3_INVALID,"invalid distance point");
    }
    const kc_h3_vector invalid_directions[]={{2,0,0,0},{1,0,0,1},{NAN,0,0,0},{0,0,0,0}};
    for (size_t index=0; index<sizeof invalid_directions/sizeof invalid_directions[0]; ++index) {
        kc_h3_ray invalid=initial;
        invalid.direction=invalid_directions[index];
        require_status(kc_h3_validate_ray(&invalid),KC_H3_INVALID,"invalid direction");
    }
    second=initial;
    require_status(kc_h3_advance(&initial,-1.0,&second),KC_H3_INVALID,"negative length");
    require_status(kc_h3_advance(&initial,NAN,&second),KC_H3_INVALID,"nonfinite length");
    require_status(kc_h3_advance(&initial,5.0,&second),KC_H3_NUMERICAL_RANGE,"bounded local advance");
    require_status(kc_h3_advance(&initial,1e-300,&second),KC_H3_NUMERICAL_RANGE,"unrepresentable travel increment");
    if (memcmp(&second,&initial,sizeof second)!=0) return 1;
    require_status(kc_h3_advance(NULL,step,&second),KC_H3_INVALID,"absent ray");
    require_status(kc_h3_advance(&initial,step,NULL),KC_H3_INVALID,"absent output");
    require_status(kc_h3_change_chart(&initial,(kc_h3_chart)99,&converted),KC_H3_INVALID,"unknown chart");
    kc_h3_frame invalid_frame=frame;
    invalid_frame.up=frame.right;
    require_status(kc_h3_transport_frame(&initial,step,&invalid_frame,&transported),KC_H3_INVALID,"nonorthogonal frame");
    require_status(kc_h3_sphere_hit(&initial,initial.position,0.0,4.0,&hit),KC_H3_INVALID,"zero sphere radius");
    require_status(kc_h3_sphere_hit(&initial,initial.position,NAN,4.0,&hit),KC_H3_INVALID,"nonfinite sphere radius");
    if (output && fclose(output)!=0) return 2;
    printf("H3 ray reference: PASS (%u assertions)\n",checks);
    return 0;
}
