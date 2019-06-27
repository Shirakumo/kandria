(in-package #:org.shirakumo.fraf.leaf)

(define-global +light-count+ 16)

(define-gl-struct point-light
  (position :vec2)
  (radius :float)
  (color :vec3)
  (intensity :float))

(define-gl-struct lights
  (point-lights (:struct point-light) :array-size +light-count+)
  (count :int))

(define-asset (leaf lights) uniform-buffer
    'lights)

(define-shader-entity lighted-entity ()
  ()
  (:buffers (leaf lights)))

(define-class-shader (lighted-entity :fragment-shader)
  (gl-source (asset 'leaf 'lights))
  "
uniform float global_illumination = 0.15;

vec3 add(vec3 a, vec3 b){
  return a+b;
}

vec3 screen(vec3 a, vec3 b){
  return 1 - (1-a) * (1-b);
}

vec3 overlay(vec3 a, vec3 b){
  return (length(a) < 0.5)? (2*a*b) : (1-2*(1-a)*(1-b));
}

vec3 soft_light(vec3 a, vec3 b){
  return (1-2*b)*a*a + 2*b*a;
}

vec3 shade_point_light(vec3 color, vec2 position, struct PointLight light){
  float falloff = distance(position, light.position) / light.radius;
  if(falloff <= 1){
    return add(color.rgb, light.color)*light.intensity*(1-falloff);
  }else{
    return vec3(0);
  }
}

vec3 shade_lights(vec3 albedo, vec2 position){
  vec3 color = vec3(0);
  for(int i=0; i<lights.count; ++i){
    color += shade_point_light(albedo, position, lights.point_lights[i]);
  }
  color += global_illumination * albedo;
  return color;
}")
