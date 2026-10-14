#include "h3_ray.h"
#include <float.h>
#include <math.h>
#include <stddef.h>

static const long double constraint_tolerance = 5e-10L;

static long double pairing(kc_h3_vector first, kc_h3_vector second)
{
    return (long double)first.x*second.x + (long double)first.y*second.y +
           (long double)first.z*second.z - (long double)first.time*second.time;
}
static kc_h3_vector combination(double first_scale, kc_h3_vector first,
                                double second_scale, kc_h3_vector second)
{
    return (kc_h3_vector){first_scale*first.x+second_scale*second.x,
        first_scale*first.y+second_scale*second.y,
        first_scale*first.z+second_scale*second.z,
        first_scale*first.time+second_scale*second.time};
}
static kc_h3_status vector_range(kc_h3_vector vector)
{
    const double values[4] = {vector.x,vector.y,vector.z,vector.time};
    for (size_t index=0; index<4; ++index) {
        if (!isfinite(values[index])) return KC_H3_INVALID;
        if (fabs(values[index])>64.0) return KC_H3_NUMERICAL_RANGE;
    }
    return KC_H3_OK;
}
static kc_h3_status point_valid(kc_h3_vector point)
{
    kc_h3_status status=vector_range(point);
    if (status!=KC_H3_OK) return status;
    if (!(point.time>0.0) ||
        fabsl(pairing(point,point)+1.0L)>constraint_tolerance)
        return KC_H3_INVALID;
    return KC_H3_OK;
}
static kc_h3_status unit_tangent_valid(kc_h3_vector point,
                                      kc_h3_vector tangent)
{
    kc_h3_status status=vector_range(tangent);
    if (status!=KC_H3_OK) return status;
    if (fabsl(pairing(tangent,tangent)-1.0L)>constraint_tolerance ||
        fabsl(pairing(point,tangent))>constraint_tolerance)
        return KC_H3_INVALID;
    return KC_H3_OK;
}
kc_h3_status kc_h3_validate_ray(const kc_h3_ray *ray)
{
    if (!ray || !isfinite(ray->travelled) || ray->travelled<0.0)
        return KC_H3_INVALID;
    kc_h3_status status=point_valid(ray->position);
    if (status!=KC_H3_OK) return status;
    return unit_tangent_valid(ray->position,ray->direction);
}
static kc_h3_status frame_valid(kc_h3_vector point, const kc_h3_frame *frame)
{
    if (!frame) return KC_H3_INVALID;
    const kc_h3_vector vectors[3]={frame->right,frame->up,frame->forward};
    for (size_t index=0; index<3; ++index) {
        kc_h3_status status=unit_tangent_valid(point,vectors[index]);
        if (status!=KC_H3_OK) return status;
        for (size_t previous=0; previous<index; ++previous)
            if (fabsl(pairing(vectors[index],vectors[previous]))>
                constraint_tolerance) return KC_H3_INVALID;
    }
    return KC_H3_OK;
}
kc_h3_status kc_h3_distance(kc_h3_vector first, kc_h3_vector second,
                          double *distance)
{
    if (!distance) return KC_H3_INVALID;
    kc_h3_status status=point_valid(first);
    if (status!=KC_H3_OK) return status;
    status=point_valid(second);
    if (status!=KC_H3_OK) return status;
    kc_h3_vector difference=combination(1.0,second,-1.0,first);
    long double squared=pairing(difference,difference);
    if (squared<0.0L) return KC_H3_UNRESOLVED;
    double result=(double)(2.0L*asinhl(0.5L*sqrtl(squared)));
    if (!isfinite(result)) return KC_H3_NUMERICAL_RANGE;
    *distance=result;
    return KC_H3_OK;
}
kc_h3_status kc_h3_advance(const kc_h3_ray *ray, double distance,
                         kc_h3_ray *advanced)
{
    if (!advanced || !isfinite(distance) || distance<0.0)
        return KC_H3_INVALID;
    kc_h3_status status=kc_h3_validate_ray(ray);
    if (status!=KC_H3_OK) return status;
    if (distance>4.0) return KC_H3_NUMERICAL_RANGE;
    double cosine=cosh(distance), sine=sinh(distance);
    kc_h3_ray result={combination(cosine,ray->position,sine,ray->direction),
        combination(sine,ray->position,cosine,ray->direction),
        ray->travelled+distance};
    if (distance>0.0 && !(result.travelled>ray->travelled))
        return KC_H3_NUMERICAL_RANGE;
    status=kc_h3_validate_ray(&result);
    if (status!=KC_H3_OK)
        return status==KC_H3_INVALID ? KC_H3_UNRESOLVED : status;
    *advanced=result;
    return KC_H3_OK;
}
static kc_h3_vector transport_vector(const kc_h3_ray *ray,
                                    const kc_h3_ray *advanced,
                                    kc_h3_vector vector)
{
    double parallel=(double)pairing(vector,ray->direction);
    kc_h3_vector perpendicular=combination(1.0,vector,-parallel,ray->direction);
    return combination(1.0,perpendicular,parallel,advanced->direction);
}
kc_h3_status kc_h3_transport_frame(const kc_h3_ray *ray, double distance,
                                 const kc_h3_frame *frame,
                                 kc_h3_frame *transported)
{
    if (!transported) return KC_H3_INVALID;
    kc_h3_ray advanced;
    kc_h3_status status=kc_h3_advance(ray,distance,&advanced);
    if (status!=KC_H3_OK) return status;
    status=frame_valid(ray->position,frame);
    if (status!=KC_H3_OK) return status;
    kc_h3_frame result={transport_vector(ray,&advanced,frame->right),
        transport_vector(ray,&advanced,frame->up),
        transport_vector(ray,&advanced,frame->forward)};
    status=frame_valid(advanced.position,&result);
    if (status!=KC_H3_OK) return KC_H3_UNRESOLVED;
    *transported=result;
    return KC_H3_OK;
}
kc_h3_status kc_h3_change_chart(const kc_h3_ray *ray, kc_h3_chart chart,
                              kc_h3_chart_ray *converted)
{
    if (!converted) return KC_H3_INVALID;
    kc_h3_status status=kc_h3_validate_ray(ray);
    if (status!=KC_H3_OK) return status;
    double denominator, derivative;
    double position[3]={ray->position.x,ray->position.y,ray->position.z};
    double direction[3]={ray->direction.x,ray->direction.y,ray->direction.z};
    if (chart==KC_H3_UPPER_HALF_SPACE) {
        denominator=ray->position.time-ray->position.z;
        derivative=ray->direction.time-ray->direction.z;
        position[2]=1.0;
        direction[2]=0.0;
    } else if (chart==KC_H3_KLEIN) {
        denominator=ray->position.time;
        derivative=ray->direction.time;
    } else if (chart==KC_H3_POINCARE) {
        denominator=ray->position.time+1.0;
        derivative=ray->direction.time;
    } else return KC_H3_INVALID;
    if (!(denominator>0.0)) return KC_H3_UNRESOLVED;
    kc_h3_chart_ray result;
    for (size_t index=0; index<3; ++index) {
        result.position[index]=position[index]/denominator;
        result.velocity[index]=(direction[index]-
            result.position[index]*derivative)/denominator;
        if (!isfinite(result.position[index]) || !isfinite(result.velocity[index]))
            return KC_H3_NUMERICAL_RANGE;
    }
    *converted=result;
    return KC_H3_OK;
}
static double determinant3(const double matrix[3][3])
{
    return matrix[0][0]*(matrix[1][1]*matrix[2][2]-matrix[1][2]*matrix[2][1])-
           matrix[0][1]*(matrix[1][0]*matrix[2][2]-matrix[1][2]*matrix[2][0])+
           matrix[0][2]*(matrix[1][0]*matrix[2][1]-matrix[1][1]*matrix[2][0]);
}
kc_h3_status kc_h3_validate_isometry(const kc_h3_direct_isometry *isometry)
{
    if (!isometry) return KC_H3_INVALID;
    for (size_t row=0; row<4; ++row)
        for (size_t column=0; column<4; ++column) {
            double entry=isometry->rows[row][column];
            if (!isfinite(entry)) return KC_H3_INVALID;
            if (fabs(entry)>64.0) return KC_H3_NUMERICAL_RANGE;
        }
    for (size_t row=0; row<4; ++row)
        for (size_t other=0; other<4; ++other) {
            long double value=0.0L;
            for (size_t column=0; column<4; ++column)
                value+=(column==3 ? -1.0L : 1.0L)*
                    isometry->rows[row][column]*isometry->rows[other][column];
            long double expected=row==other ? (row==3 ? -1.0L : 1.0L) : 0.0L;
            if (fabsl(value-expected)>constraint_tolerance) return KC_H3_INVALID;
        }
    double determinant=0.0;
    for (size_t column=0; column<4; ++column) {
        double minor[3][3];
        for (size_t row=1; row<4; ++row) {
            size_t target=0;
            for (size_t source=0; source<4; ++source)
                if (source!=column) minor[row-1][target++]=isometry->rows[row][source];
        }
        determinant+=(column%2 ? -1.0 : 1.0)*
            isometry->rows[0][column]*determinant3(minor);
    }
    if (!(isometry->rows[3][3]>0.0) ||
        fabs(determinant-1.0)>5e-9) return KC_H3_INVALID;
    return KC_H3_OK;
}
static kc_h3_vector apply_vector(const kc_h3_direct_isometry *isometry,
                                kc_h3_vector vector)
{
    const double values[4]={vector.x,vector.y,vector.z,vector.time};
    double result[4]={0.0,0.0,0.0,0.0};
    for (size_t column=0; column<4; ++column)
        for (size_t row=0; row<4; ++row)
            result[column]+=values[row]*isometry->rows[row][column];
    return (kc_h3_vector){result[0],result[1],result[2],result[3]};
}
kc_h3_status kc_h3_apply_isometry(const kc_h3_direct_isometry *isometry,
                                const kc_h3_ray *ray, kc_h3_ray *mapped)
{
    if (!mapped) return KC_H3_INVALID;
    kc_h3_status status=kc_h3_validate_isometry(isometry);
    if (status!=KC_H3_OK) return status;
    status=kc_h3_validate_ray(ray);
    if (status!=KC_H3_OK) return status;
    kc_h3_ray result={apply_vector(isometry,ray->position),
        apply_vector(isometry,ray->direction),ray->travelled};
    status=kc_h3_validate_ray(&result);
    if (status!=KC_H3_OK) return KC_H3_UNRESOLVED;
    *mapped=result;
    return KC_H3_OK;
}
kc_h3_status kc_h3_map_frame(const kc_h3_direct_isometry *isometry,
                           const kc_h3_ray *ray, const kc_h3_frame *frame,
                           kc_h3_frame *mapped)
{
    if (!mapped) return KC_H3_INVALID;
    kc_h3_ray destination;
    kc_h3_status status=kc_h3_apply_isometry(isometry,ray,&destination);
    if (status!=KC_H3_OK) return status;
    status=frame_valid(ray->position,frame);
    if (status!=KC_H3_OK) return status;
    kc_h3_frame result={apply_vector(isometry,frame->right),
        apply_vector(isometry,frame->up),apply_vector(isometry,frame->forward)};
    status=frame_valid(destination.position,&result);
    if (status!=KC_H3_OK) return KC_H3_UNRESOLVED;
    *mapped=result;
    return KC_H3_OK;
}
static kc_h3_status finish_hit(const kc_h3_ray *ray, double distance,
                              double limit, kc_h3_hit *hit)
{
    if (distance>limit) return KC_H3_DISTANCE_LIMIT;
    kc_h3_hit result;
    result.distance=distance;
    kc_h3_status status=kc_h3_advance(ray,distance,&result.ray);
    if (status!=KC_H3_OK) return status;
    *hit=result;
    return KC_H3_OK;
}
kc_h3_status kc_h3_plane_hit(const kc_h3_ray *ray, kc_h3_vector normal,
                           double distance_limit, kc_h3_hit *hit)
{
    if (!hit || !isfinite(distance_limit) || distance_limit<0.0)
        return KC_H3_INVALID;
    kc_h3_status status=kc_h3_validate_ray(ray);
    if (status!=KC_H3_OK) return status;
    status=vector_range(normal);
    if (status!=KC_H3_OK) return status;
    long double normal_squared=pairing(normal,normal);
    if (!(normal_squared>0.0L)) return KC_H3_INVALID;
    long double scale=sqrtl(normal_squared);
    long double start=pairing(ray->position,normal)/scale;
    long double derivative=pairing(ray->direction,normal)/scale;
    if (start==0.0L) return KC_H3_ON_SURFACE;
    if (fabsl(start)<=constraint_tolerance) return KC_H3_UNRESOLVED;
    if (derivative==0.0L) return KC_H3_NO_HIT;
    long double parameter=-start/derivative;
    if (parameter<=0.0L) return KC_H3_NO_HIT;
    if (fabsl(parameter-1.0L)<=constraint_tolerance) return KC_H3_UNRESOLVED;
    if (parameter>1.0L) return KC_H3_NO_HIT;
    return finish_hit(ray,(double)atanhl(parameter),distance_limit,hit);
}
kc_h3_status kc_h3_sphere_hit(const kc_h3_ray *ray, kc_h3_vector center,
                            double radius, double distance_limit,
                            kc_h3_hit *hit)
{
    if (!hit || !isfinite(radius) || !(radius>0.0) ||
        !isfinite(distance_limit) || distance_limit<0.0) return KC_H3_INVALID;
    if (radius>4.0) return KC_H3_NUMERICAL_RANGE;
    kc_h3_status status=kc_h3_validate_ray(ray);
    if (status!=KC_H3_OK) return status;
    status=point_valid(center);
    if (status!=KC_H3_OK) return status;
    long double first=-pairing(ray->position,center);
    long double second=-pairing(ray->direction,center);
    long double boundary=coshl((long double)radius);
    if (fabsl(first-boundary)<=constraint_tolerance) return KC_H3_UNRESOLVED;
    long double discriminant=boundary*boundary-(first*first-second*second);
    long double uncertainty=constraint_tolerance*
        (1.0L+first*first+second*second+boundary*boundary);
    if (discriminant < -uncertainty) return KC_H3_NO_HIT;
    if (discriminant <= uncertainty) return KC_H3_UNRESOLVED;
    long double stable_root=boundary+sqrtl(discriminant);
    long double coefficient=first+second;
    if (!(coefficient>0.0L) || !(stable_root>0.0L)) return KC_H3_UNRESOLVED;
    long double roots[2]={stable_root/coefficient,(first-second)/stable_root};
    long double nearest=HUGE_VALL;
    for (size_t index=0; index<2; ++index) {
        if (!(roots[index]>0.0L) || !isfinite(roots[index]))
            return KC_H3_UNRESOLVED;
        long double distance=logl(roots[index]);
        if (distance>0.0L && distance<nearest) nearest=distance;
    }
    if (!isfinite(nearest)) return KC_H3_NO_HIT;
    return finish_hit(ray,(double)nearest,distance_limit,hit);
}
