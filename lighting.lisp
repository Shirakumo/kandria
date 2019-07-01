(in-package #:org.shirakumo.fraf.leaf)

(define-global +light-count+ 16)

(define-gl-struct light
  (type :int)
  (position :vec2)
  (dimensions :vec4)
  (color :vec3)
  (intensity :float))

(define-gl-struct lights
  (lights (:struct light) :count +light-count+)
  (count :int))

(define-asset (leaf lights) uniform-buffer
    'lights)

(define-shader-entity lighted-entity ()
  ()
  (:buffers (leaf lights)))

(define-class-shader (lighted-entity :fragment-shader)
  (gl-source (asset 'leaf 'lights))
  "
uniform float global_illumination = 0.3;

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

float point_light_sdf(vec2 position, vec4 dimensions){
  return length(position) - dimensions.x;
}

float trapezoid_light_sdf(vec2 p, vec4 dimensions){
  vec2 c = vec2(sin(dimensions.x/2), cos(dimensions.x/2));
  float t = dimensions.y;
  float b = dimensions.z;
  float theta = dimensions.w;
  float h = p.y;

  mat2 rot;
  rot[0] = vec2(cos(theta), -sin(theta));
  rot[1] = vec2(sin(theta), cos(theta));
  p = rot*p;

  p.x = abs(p.x);
  p.y += t;
  
  float m = length(p-c*max(dot(p,c),0.0));
  return max(max(m*sign(c.y*p.x-c.x*p.y), -h), -(b+(-h)));
}

float cone_light_sdf(vec2 p, vec4 dimensions){
  vec2 c = vec2(sin(dimensions.x/2), cos(dimensions.x/2));
  float r = dimensions.y + dimensions.z;
  float t = dimensions.z;

  p.x = abs(p.x);
  p.y += t;
  float l = length(p) - r;
  float m = length(p-c*clamp(dot(p,c),0.0,r));
  return max(max(l,m*sign(c.y*p.x-c.x*p.y)), t-p.y);
}

float evaluate_light(vec2 position, Light light){
  switch(light.type){
  case 1: return point_light_sdf(position, light.dimensions);
  case 2: return trapezoid_light_sdf(position, light.dimensions);
  case 3: return cone_light_sdf(position, light.dimensions);
  default: return 1.0;
  }
}

vec3 shade_lights(vec3 albedo, vec2 position){
  vec3 color = vec3(0);
  for(int i=0; i<lights.count; ++i){
    Light light = lights.lights[i];
    vec2 relative_position = light.position - position;
    float sdf = evaluate_light(relative_position, light);
    if(sdf <= 0){
      color += add(albedo.rgb, light.color)*light.intensity*clamp(-sdf/2, 0, 1);
    }
  }
  color += global_illumination * albedo;
  return color;
}")
