/* Compiling mutation: preserve source-chart tangent across a face. */
#define kc_m004_first_event kc_m004_original_first_event
#include "../m004_atlas.c"
#undef kc_m004_first_event
kc_m004_status kc_m004_first_event(const kc_m004_state *state,double distance,
                                  kc_m004_event *event)
{
    kc_m004_status status=kc_m004_original_first_event(state,distance,event);
    if (status==KC_M004_OK) event->after.ray.direction=event->before.ray.direction;
    return status;
}
