(in-package #:org.shirakumo.fraf.leaf)

(define-gl-struct point-light
  (position :vec3)
  (radius :float)
  (color :vec3)
  (intensity :float))

(define-gl-struct lights
  (point-lights (:struct point-light) :array-size 10))

(define-asset (leaf lights) uniform-buffer
    'lights)

(define-shader-entity lighted-entity ()
  ())

(define-class-shader (lighted-entity :fragment-shader)
  (gl-source (asset 'leaf 'lights))
  "
uniform float global_illumination = 0.5;

vec4 shade_point_light(vec4 color, vec2 position, struct PointLight light){
  if(light.radius <= distance(position, light.position)){
    color += light.color*light.intensity;
  }
  return color;
}

vec4 shade_lights(vec4 color, vec2 position){
  color *= global_illumination;
  for(int i=0; i<POINT_LIGHTS; ++i){
    color = shade_point_light(color, position, lights.point_lights[i]);
  }
  return color;
}")
