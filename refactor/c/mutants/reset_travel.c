/* Deliberately wrong executable: reset cumulative travel at each segment. */
#define kc_h3_advance kc_h3_advance_unmutated
#include "../h3_ray.c"
#undef kc_h3_advance
kc_h3_status kc_h3_advance(const kc_h3_ray *ray, double distance,
                         kc_h3_ray *advanced)
{
    kc_h3_status status=kc_h3_advance_unmutated(ray,distance,advanced);
    if (status==KC_H3_OK) advanced->travelled=distance;
    return status;
}
