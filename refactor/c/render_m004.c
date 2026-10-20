#include "m004_view.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

/* Deterministic host contact sheet: 3x3 successive camera positions. The
 * tiles are ordinary image layout; every optical ray traverses intrinsic H3
 * and the m004 face identifications. No quotient face is an opaque surface. */
int main(int argc, char **argv) {
    if (argc!=3) {
        fprintf(stderr,"usage: render_m004 OUTPUT.ppm RECEIPT.tsv\n");
        return 2;
    }
    enum { width=96,height=64,frames=9 };
    unsigned char pixels[frames][height][width][3];
    unsigned counts[frames][6]={{0}};
    double odometry[frames];
    unsigned tetrahedron[frames];
    const double a=1/sqrt(3.0),b=1/sqrt(2.0),c=1/sqrt(6.0);
    kc_h3_vector forward={-a,-a,-a,0};
    kc_h3_frame basis={{b,-b,0,0},{-c,-c,2*c,0},forward};
    kc_m004_camera camera={{0,-1,{{0,0,0,1},forward,0},basis},0.65,1.5};
    const kc_m004_scene scene={2,0.22};
    const kc_m004_view_budget budget={4.0,24};
    for (unsigned frame=0;frame<frames;frame++) {
        odometry[frame]=camera.state.ray.travelled;
        tetrahedron[frame]=camera.state.tetrahedron;
        for (unsigned y=0;y<height;y++) for (unsigned x=0;x<width;x++) {
            kc_m004_state ray;
            kc_m004_pixel pixel={KC_M004_VIEW_INVALID,camera.state,0,-1,0};
            kc_m004_status status=kc_m004_camera_ray(&camera,
                2.0*(x+0.5)/width-1.0,1.0-2.0*(y+0.5)/height,&ray);
            if (status==KC_M004_OK) {
                kc_m004_view_status traced=kc_m004_trace(&scene,&ray,budget,&pixel);
                if (traced==KC_M004_VIEW_INVALID) pixel.status=traced;
            } else if (status==KC_M004_UNRESOLVED)
                pixel.status=KC_M004_VIEW_UNRESOLVED;
            else if (status==KC_M004_NUMERICAL_RANGE)
                pixel.status=KC_M004_VIEW_NUMERICAL_RANGE;
            ++counts[frame][pixel.status];
            kc_m004_pixel_rgb(&pixel,pixels[frame][y][x]);
        }
        if (frame+1<frames) {
            kc_m004_camera moved;
            if (kc_m004_camera_move(&camera,0.09,24,&moved)!=KC_M004_OK) {
                fprintf(stderr,"camera move failed at frame %u\n",frame);
                return 1;
            }
            camera=moved;
        }
    }
    FILE *image=fopen(argv[1],"wb");
    if (!image) return 1;
    if (fprintf(image,"P6\n%d %d\n255\n",3*width,3*height)<0) return 1;
    for (unsigned row=0;row<3;row++) for (unsigned y=0;y<height;y++)
        for (unsigned column=0;column<3;column++)
            if (fwrite(pixels[row*3+column][y],3,width,image)!=width) return 1;
    if (fclose(image)!=0) return 1;
    FILE *receipt=fopen(argv[2],"w");
    if (!receipt) return 1;
    fprintf(receipt,"frame\tcamera_distance\ttetrahedron\thit\tdistance_limit\tcrossing_limit\tunresolved\tnumerical_range\tinvalid\n");
    for (unsigned frame=0;frame<frames;frame++) {
        fprintf(receipt,"%u\t%.17g\t%u",frame,odometry[frame],tetrahedron[frame]);
        for (unsigned status=0;status<6;status++) fprintf(receipt,"\t%u",counts[frame][status]);
        fputc('\n',receipt);
    }
    if (fclose(receipt)!=0) return 1;
    puts("m004 CPU diagnostic contact sheet: complete (nine frames, 55296 rays)");
    return 0;
}
