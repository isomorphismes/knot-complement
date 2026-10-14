#include "m004_atlas.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned assertions;
static void require(int condition,const char *label)
{
    ++assertions;
    if (!condition) { fprintf(stderr,"m004: %s\n",label); exit(1); }
}
static void close_number(double actual,double expected,const char *label)
{
    ++assertions;
    if (!isfinite(actual) || !isfinite(expected) || fabs(actual-expected)>2e-9) {
        fprintf(stderr,"m004 %s: %.17g, expected %.17g\n",label,actual,expected);
        exit(1);
    }
}
static void close_vector(kc_h3_vector actual,kc_h3_vector expected,const char *label)
{
    close_number(actual.x,expected.x,label); close_number(actual.y,expected.y,label);
    close_number(actual.z,expected.z,label); close_number(actual.time,expected.time,label);
}
static void close_frame(kc_h3_frame actual,kc_h3_frame expected,const char *label)
{
    close_vector(actual.right,expected.right,label);
    close_vector(actual.up,expected.up,label);
    close_vector(actual.forward,expected.forward,label);
}
static kc_h3_vector negative(kc_h3_vector vector)
{ return (kc_h3_vector){-vector.x,-vector.y,-vector.z,-vector.time}; }
static kc_h3_vector raw_map(kc_h3_vector vector,kc_h3_direct_isometry map)
{
    const double values[4]={vector.x,vector.y,vector.z,vector.time};
    double output[4]={0};
    for (unsigned row=0;row<4;++row)
        for (unsigned column=0;column<4;++column)
            output[column]+=values[row]*map.rows[row][column];
    return (kc_h3_vector){output[0],output[1],output[2],output[3]};
}
static kc_m004_state center_state(double x,double y,double z,unsigned tetrahedron)
{
    double magnitude=sqrt(x*x+y*y+z*z);
    x/=magnitude; y/=magnitude; z/=magnitude;
    double side=sqrt(x*x+y*y);
    kc_h3_vector direction={x,y,z,0};
    kc_h3_vector right={-y/side,x/side,0,0};
    kc_h3_vector up={-z*x/side,-z*y/side,side,0};
    return (kc_m004_state){tetrahedron,-1,{{0,0,0,1},direction,2.0},
        {right,up,direction}};
}
static void emit_vector(FILE *output,const char *prefix,kc_h3_vector vector)
{
    fprintf(output,"%s.x\t%.17g\n%s.y\t%.17g\n%s.z\t%.17g\n%s.time\t%.17g\n",
        prefix,vector.x,prefix,vector.y,prefix,vector.z,prefix,vector.time);
}
static void emit_state(FILE *output,const char *prefix,kc_m004_state state)
{
    char key[128];
    fprintf(output,"%s.tetrahedron\t%u\n%s.incoming_face\t%d\n%s.travelled\t%.17g\n",
        prefix,state.tetrahedron,prefix,state.incoming_face,prefix,state.ray.travelled);
    snprintf(key,sizeof(key),"%s.position",prefix); emit_vector(output,key,state.ray.position);
    snprintf(key,sizeof(key),"%s.direction",prefix); emit_vector(output,key,state.ray.direction);
    snprintf(key,sizeof(key),"%s.right",prefix); emit_vector(output,key,state.frame.right);
    snprintf(key,sizeof(key),"%s.up",prefix); emit_vector(output,key,state.frame.up);
    snprintf(key,sizeof(key),"%s.forward",prefix); emit_vector(output,key,state.frame.forward);
}
static void emit_event(FILE *output,const char *prefix,kc_m004_event event)
{
    char key[128];
    fprintf(output,"%s.source_face\t%u\n%s.distance\t%.17g\n",prefix,
        event.source_face,prefix,event.distance);
    snprintf(key,sizeof(key),"%s.before",prefix); emit_state(output,key,event.before);
    snprintf(key,sizeof(key),"%s.after",prefix); emit_state(output,key,event.after);
}
int main(int argc,char **argv)
{
    FILE *output=NULL;
    if (argc==3 && strcmp(argv[1],"--emit")==0) {
        output=fopen(argv[2],"w"); if (!output) return 2;
    } else if (argc!=1) return 2;
    static const unsigned expected_images[2][4][4]={
        {{0,1,3,2},{1,2,3,0},{2,3,1,0},{2,1,0,3}},
        {{0,1,3,2},{3,2,0,1},{3,0,1,2},{2,1,0,3}}};
    const double inverse_root3=1.0/sqrt(3.0),crossing_distance=0.5*log(2.0);
    /* Walk every oriented edge incidence by crossing one of its incident
     * faces and then taking the other. Six regular wedges close with the
     * identity developed map; this exercises nontrivial face composition. */
    for (unsigned initial_tetrahedron=0;initial_tetrahedron<2;++initial_tetrahedron)
        for (unsigned first_vertex=0;first_vertex<4;++first_vertex)
            for (unsigned second_vertex=first_vertex+1;second_vertex<4;++second_vertex)
                for (unsigned initial_face=0;initial_face<4;++initial_face) {
                    if (initial_face==first_vertex || initial_face==second_vertex) continue;
                    unsigned tetrahedron=initial_tetrahedron,face=initial_face;
                    unsigned edge_first=first_vertex,edge_second=second_vertex,wedges=0;
                    kc_h3_direct_isometry developed={{{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}}};
                    do {
                        kc_m004_pairing pairing;
                        require(kc_m004_face_pairing(tetrahedron,face,&pairing)==KC_M004_OK,
                            "edge cycle pairing");
                        kc_h3_direct_isometry composed={{{0}}};
                        for (unsigned row=0;row<4;++row)
                            for (unsigned column=0;column<4;++column)
                                for (unsigned inner=0;inner<4;++inner)
                                    composed.rows[row][column]+=
                                        developed.rows[row][inner]*pairing.map.rows[inner][column];
                        developed=composed;
                        edge_first=pairing.vertex_image[edge_first];
                        edge_second=pairing.vertex_image[edge_second];
                        unsigned next_face=0;
                        while (next_face==edge_first || next_face==edge_second || next_face==pairing.face)
                            ++next_face;
                        require(next_face<4,"next edge incidence exists");
                        tetrahedron=pairing.tetrahedron; face=next_face;
                        ++wedges;
                        require(wedges<=6,"edge closes within six wedges");
                    } while (tetrahedron!=initial_tetrahedron || face!=initial_face ||
                        !((edge_first==first_vertex && edge_second==second_vertex) ||
                          (edge_first==second_vertex && edge_second==first_vertex)));
                    require(wedges==6,"six pi/3 dihedral angles around edge");
                    for (unsigned row=0;row<4;++row)
                        for (unsigned column=0;column<4;++column)
                            close_number(developed.rows[row][column],row==column ? 1.0 : 0.0,
                                "edge cycle developed identity");
                }
    for (unsigned tetrahedron=0;tetrahedron<2;++tetrahedron)
        for (unsigned face=0;face<4;++face) {
            kc_m004_pairing pairing,reverse;
            require(kc_m004_face_pairing(tetrahedron,face,&pairing)==KC_M004_OK,
                "all eight pairings exist");
            require(pairing.tetrahedron==1-tetrahedron,"neighbor cell");
            require(pairing.face==expected_images[tetrahedron][face][face],"neighbor face");
            require(kc_h3_validate_isometry(&pairing.map)==KC_H3_OK,"direct future isometry");
            if (output) fprintf(output,"pair.%u.%u.tetrahedron\t%u\npair.%u.%u.face\t%u\n",
                tetrahedron,face,pairing.tetrahedron,tetrahedron,face,pairing.face);
            for (unsigned vertex=0;vertex<4;++vertex) {
                require(pairing.vertex_image[vertex]==expected_images[tetrahedron][face][vertex],
                    "ordered vertex permutation");
                if (output) fprintf(output,"pair.%u.%u.vertex.%u\t%u\n",
                    tetrahedron,face,vertex,pairing.vertex_image[vertex]);
                if (vertex!=face) {
                    kc_h3_vector source,target;
                    require(kc_m004_face_normal(vertex,&source)==KC_M004_OK,"source ideal direction");
                    require(kc_m004_face_normal(pairing.vertex_image[vertex],&target)==KC_M004_OK,
                        "target ideal direction");
                    source.time=1.0; target.time=1.0;
                    close_vector(raw_map(source,pairing.map),target,"face vertex image");
                }
            }
            require(kc_m004_face_pairing(pairing.tetrahedron,pairing.face,&reverse)==KC_M004_OK,
                "reverse pairing");
            require(reverse.tetrahedron==tetrahedron && reverse.face==face,"reverse combinatorics");
            for (unsigned row=0;row<4;++row)
                for (unsigned column=0;column<4;++column) {
                    double product=0;
                    for (unsigned inner=0;inner<4;++inner)
                        product+=pairing.map.rows[row][inner]*reverse.map.rows[inner][column];
                    close_number(product,row==column ? 1.0 : 0.0,"inverse pairing matrix");
                    if (output) fprintf(output,"pair.%u.%u.matrix.%u.%u\t%.17g\n",
                        tetrahedron,face,row,column,pairing.map.rows[row][column]);
                }
            kc_h3_vector normal;
            require(kc_m004_face_normal(face,&normal)==KC_M004_OK,"face normal");
            kc_m004_state state=center_state(-normal.x,-normal.y,-normal.z,tetrahedron);
            kc_m004_event event;
            require(kc_m004_first_event(&state,1.0,&event)==KC_M004_OK,"first face from center");
            require(event.source_face==face,"correct first face");
            close_number(event.distance,crossing_distance,"center to face distance");
            require(kc_m004_validate_state(&event.after)==KC_M004_OK,"incoming seam valid");
            kc_m004_event second;
            require(kc_m004_first_event(&event.after,0.1,&second)!=KC_M004_OK,
                "incoming seam is not repeated");
            close_vector(raw_map(event.after.ray.position,reverse.map),event.before.ray.position,
                "developed point continuity");
            close_vector(raw_map(event.after.ray.direction,reverse.map),event.before.ray.direction,
                "developed tangent continuity");
            close_vector(raw_map(event.after.frame.right,reverse.map),event.before.frame.right,
                "developed right continuity");
            close_vector(raw_map(event.after.frame.up,reverse.map),event.before.frame.up,
                "developed up continuity");
            close_vector(raw_map(event.after.frame.forward,reverse.map),event.before.frame.forward,
                "developed forward continuity");
        }
    kc_m004_state initial={0,-1,{{0,0,0,1},{-inverse_root3,-inverse_root3,-inverse_root3,0},2},
        {{1/sqrt(2.0),-1/sqrt(2.0),0,0},{-1/sqrt(6.0),-1/sqrt(6.0),2/sqrt(6.0),0},
        {-inverse_root3,-inverse_root3,-inverse_root3,0}}};
    kc_m004_event first;
    require(kc_m004_first_event(&initial,1,&first)==KC_M004_OK,"worked first event");
    double point_component=-1.0/(2.0*sqrt(6.0));
    close_vector(first.before.ray.position,(kc_h3_vector){point_component,point_component,
        point_component,3.0/(2.0*sqrt(2.0))},"exact boundary point");
    close_vector(first.before.ray.direction,(kc_h3_vector){3*point_component,3*point_component,
        3*point_component,1.0/(2.0*sqrt(2.0))},"exact outgoing tangent");
    close_vector(first.after.ray.position,first.before.ray.position,"symmetric pairing point");
    close_vector(first.after.ray.direction,negative(first.before.ray.direction),"mapped tangent");
    close_vector(first.after.frame.right,(kc_h3_vector){1/sqrt(2.0),0,-1/sqrt(2.0),0},"mapped right");
    close_vector(first.after.frame.up,(kc_h3_vector){-1/sqrt(6.0),2/sqrt(6.0),-1/sqrt(6.0),0},"mapped up");
    close_number(first.after.ray.travelled,2.0+crossing_distance,"face preserves travel");
    kc_m004_state reversed_seam;
    require(kc_m004_reorient(&first.after,negative(first.after.ray.direction),
        &reversed_seam)==KC_M004_OK,"outward viewing ray changes seam representative");
    require(reversed_seam.tetrahedron==initial.tetrahedron && reversed_seam.incoming_face==0,
        "reverse viewing ray returns to source chart");
    close_vector(reversed_seam.ray.position,first.before.ray.position,"reverse seam point");
    close_vector(reversed_seam.ray.direction,negative(first.before.ray.direction),"reverse seam tangent");
    close_frame(reversed_seam.frame,first.before.frame,"reverse seam frame");
    close_number(reversed_seam.ray.travelled,first.after.ray.travelled,"zero travel in seam reorientation");
    kc_m004_state seam_sentinel=reversed_seam;
    require(kc_m004_reorient(&first.after,first.after.frame.right,&seam_sentinel)==KC_M004_UNRESOLVED,
        "grazing seam direction unresolved");
    require(memcmp(&seam_sentinel,&reversed_seam,sizeof(seam_sentinel))==0,
        "grazing preserves output");
    kc_m004_journey center;
    require(kc_m004_travel(&initial,log(2.0),1,&center)==KC_M004_OK,"center-to-center journey");
    require(center.crossings==1 && center.state.tetrahedron==1,"one actual crossing");
    close_vector(center.state.ray.position,(kc_h3_vector){0,0,0,1},"second center");
    close_vector(center.state.ray.direction,(kc_h3_vector){inverse_root3,inverse_root3,inverse_root3,0},
        "second center direction");
    close_number(center.state.ray.travelled,2+log(2.0),"center total travel");
    if (output) {
        emit_state(output,"worked.initial",initial);
        emit_event(output,"worked.event",first);
        emit_state(output,"worked.center",center.state);
        fprintf(output,"worked.crossings\t%u\n",center.crossings);
    }
    kc_m004_event unchanged=first;
    require(kc_m004_first_event(&initial,0.1,&unchanged)==KC_M004_DISTANCE_LIMIT,"event budget");
    require(memcmp(&unchanged,&first,sizeof(first))==0,"limit preserves event output");
    kc_m004_journey unchanged_journey=center;
    require(kc_m004_travel(&initial,1.0,0,&unchanged_journey)==KC_M004_CROSSING_LIMIT,
        "crossing budget refusal");
    require(memcmp(&unchanged_journey,&center,sizeof(center))==0,"crossing limit preserves output");
    kc_m004_state edge=center_state(-1,0,0,0);
    require(kc_m004_first_event(&edge,1,&unchanged)==KC_M004_UNRESOLVED,"tied edge events refused");
    kc_m004_state bad=initial; bad.incoming_face=0;
    require(kc_m004_validate_state(&bad)==KC_M004_INVALID,"forged seam witness refused");
    bad=first.after; bad.ray.direction=negative(bad.ray.direction);
    require(kc_m004_validate_state(&bad)==KC_M004_INVALID,"outgoing incoming witness refused");
    require(kc_m004_validate_state(&first.before)==KC_M004_UNRESOLVED,"unowned outgoing seam refused");
    bad=initial; bad.ray.position.x=NAN;
    require(kc_m004_travel(&bad,1,10,&unchanged_journey)==KC_M004_INVALID,"nonfinite point refused");
    bad=initial; bad.frame.right=bad.frame.up;
    require(kc_m004_travel(&bad,1,10,&unchanged_journey)==KC_M004_INVALID,"broken full frame refused");
    bad=initial; bad.tetrahedron=2;
    require(kc_m004_validate_state(&bad)==KC_M004_INVALID,"missing tetrahedron refused");
    require(kc_m004_travel(&initial,NAN,10,&unchanged_journey)==KC_M004_INVALID,"NaN distance refused");
    require(kc_m004_travel(&initial,65,10,&unchanged_journey)==KC_M004_NUMERICAL_RANGE,"travel range explicit");
    require(kc_m004_first_event(&initial,5,&unchanged)==KC_M004_NUMERICAL_RANGE,"event range explicit");
    require(kc_m004_travel(NULL,0,0,&unchanged_journey)==KC_M004_INVALID,"null input refused");
    require(kc_m004_travel(&initial,0,0,NULL)==KC_M004_INVALID,"null output refused");
    require(memcmp(&unchanged_journey,&center,sizeof(center))==0,"invalid operations preserve output");
    kc_m004_state cusp=center_state(1,1,1,0);
    kc_m004_journey cusp_journey;
    require(kc_m004_travel(&cusp,2,0,&cusp_journey)==KC_M004_OK,"finite travel toward ideal cusp");
    require(cusp_journey.crossings==0,"ideal endpoint creates no finite boundary");
    close_number(cusp_journey.state.ray.travelled,4,"cusp travel preserved");
    for (unsigned sample=0;sample<32;++sample) {
        double x=sin((double)sample+0.31),y=cos(1.7*sample+0.2),z=sin(2.3*sample+0.43);
        kc_m004_state start=center_state(x,y,z,sample%2),inside=start;
        require(kc_h3_advance(&start.ray,0.07,&inside.ray)==KC_H3_OK,"interior sample point");
        require(kc_h3_transport_frame(&start.ray,0.07,&start.frame,&inside.frame)==KC_H3_OK,
            "interior sample frame");
        kc_m004_journey outward,returned;
        require(kc_m004_travel(&inside,1.3,64,&outward)==KC_M004_OK,"interior varied ray traversal");
        kc_m004_state return_start=outward.state;
        return_start.ray.direction=negative(return_start.ray.direction);
        require(kc_m004_travel(&return_start,1.3,64,&returned)==KC_M004_OK,"return traversal");
        require(returned.state.tetrahedron==inside.tetrahedron,"return cell");
        close_vector(returned.state.ray.position,inside.ray.position,"return position");
        close_vector(returned.state.ray.direction,negative(inside.ray.direction),"return direction");
        close_frame(returned.state.frame,inside.frame,"return frame");
        close_number(returned.state.ray.travelled,inside.ray.travelled+2.6,"return cumulative travel");
        require(outward.crossings==returned.crossings,"return crossing count");
    }
    kc_m004_state long_start=center_state(0.37,0.51,0.77,0);
    kc_m004_journey long_out,long_back;
    require(kc_m004_travel(&long_start,12,128,&long_out)==KC_M004_OK,"long forward path");
    kc_m004_state long_reverse=long_out.state;
    long_reverse.ray.direction=negative(long_reverse.ray.direction);
    require(kc_m004_travel(&long_reverse,12,128,&long_back)==KC_M004_OK,"long return path");
    require(long_out.crossings>5 && long_out.crossings==long_back.crossings,"long crossings retained");
    close_vector(long_back.state.ray.position,long_start.ray.position,"long return position");
    close_frame(long_back.state.frame,long_start.frame,"long return complete frame");
    close_number(long_back.state.ray.travelled,26,"long return travel");
    if (output) {
        emit_state(output,"path.initial",long_start);
        fprintf(output,"path.event_count\t4\n");
        kc_m004_state current=long_start;
        for (unsigned index=0;index<4;++index) {
            kc_m004_event event;
            require(kc_m004_first_event(&current,4,&event)==KC_M004_OK,"exported event");
            char prefix[64]; snprintf(prefix,sizeof(prefix),"path.event.%u",index);
            emit_event(output,prefix,event); current=event.after;
        }
        fprintf(output,"long.distance\t12\nlong.crossings\t%u\n",long_out.crossings);
        emit_state(output,"long.finish",long_out.state);
        if (fclose(output)!=0) return 2;
    }
    printf("m004 atlas: PASS (%u assertions)\n",assertions);
    return 0;
}
