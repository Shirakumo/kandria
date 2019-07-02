(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity lighted-sprite-entity (sprite-entity lighted-entity)
  ())

(define-class-shader (lighted-sprite-entity :vertex-shader)
  "layout (location = 0) in vec3 vertex;
out vec2 world_pos;
uniform mat4 model_matrix;

void main(){
  world_pos = (model_matrix * vec4(vertex, 1)).xy;
}")

(define-class-shader (lighted-sprite-entity :fragment-shader)  
  "in vec2 world_pos;
out vec4 color;

void main(){
  color.rgb = shade_lights(color.rgb, ivec3(world_pos+2, 0));
}")
