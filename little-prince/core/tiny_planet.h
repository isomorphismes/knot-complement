#ifndef TINY_PLANET_H
#define TINY_PLANET_H

typedef struct {
    float x;
    float y;
    float z;
} tp_vec3;

typedef struct {
    /* Unit vector from planet center to the walker's feet. */
    tp_vec3 up;

    /* Unit tangent direction. */
    tp_vec3 forward;

    /* Base planet radius in game-space units. */
    float radius;
} tp_walker;

int tp_walker_init(tp_walker *walker, float radius);
int tp_walker_set_frame(tp_walker *walker, tp_vec3 up, tp_vec3 forward);

void tp_walker_turn(tp_walker *walker, float radians);
void tp_walker_walk(tp_walker *walker, float distance);

tp_vec3 tp_walker_position(
    const tp_walker *walker,
    float terrain_height,
    float eye_height);

float tp_walker_latitude(const tp_walker *walker);
float tp_walker_longitude(const tp_walker *walker);

float tp_vec3_dot(tp_vec3 a, tp_vec3 b);
float tp_vec3_length(tp_vec3 v);

#endif
