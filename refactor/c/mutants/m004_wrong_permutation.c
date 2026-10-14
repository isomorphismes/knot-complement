/* Compiling mutation: replace one odd vertex pairing by another odd pairing.
 * It is still an orientation-preserving Lorentz map, but the labelled
 * quotient is different. The topology oracle must reject it. */
#define kc_m004_face_pairing kc_m004_original_face_pairing
#include "../m004_atlas.c"
#undef kc_m004_face_pairing
kc_m004_status kc_m004_face_pairing(unsigned tetrahedron,unsigned face,
                                   kc_m004_pairing *pairing)
{
    if (tetrahedron==0 && face==1)
        return kc_m004_original_face_pairing(0,2,pairing);
    return kc_m004_original_face_pairing(tetrahedron,face,pairing);
}
