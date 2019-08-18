(in-package #:org.shirakumo.fraf.leaf)

;;; Idea:
;; 1. Bind an image for the storage of shadow values at the borders of the current view.
;; 2. Render chunk and other casting geometry, but instead of writing the colour value:
;; 3. Solve up to 2 linear system to cast a ray from the current fragment position to the
;;    border of the view, in the direction of the light.
;; 4. Wherever the solution provides an index in range of the border, store a value into
;;    the image.
;; 5. Bind the same image and render as usual.
;; 6. During the lighting phase, perform the same linear system solve, to look up the
;;    value in the shadow image and dim the light if we read something.

(define-shader-entity shadow-lookup-mixin ()
  ())

(define-class-shader (shadow-lookup-mixin :fragment-shader)
  "#extension GL_EXT_shader_image_load_store : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_ARB_shader_image_size : enable

ivec2 shadow_map_position(ivec2 pos, ivec2 size, vec2 dir){
  float ym = (dir.y < 0)? 0 : (size.y-1);
  float xm = (dir.x < 0)? 0 : (size.x-1);
  
  float t = (ym-pos.y)/dir.y;
  float x = pos.x+dir.x*t;
  if(0 <= x && x < size.x){
    return ivec2(x, ym);
  }else{
    t = (xm-pos.x)/dir.x;
    float y = pos.y+dir.y*t;
    return ivec2(xm, y);
  }
}")

(define-shader-pass shadow-map-pass (per-object-pass shadow-lookup-mixin)
  ((shadow :port-type trial::image-out :texspec (:internal-format :r8)))
  (:inhibit-shaders (shader-entity :fragment-shader)))

(defmethod paint-with :around ((target shadow-map-pass) (world world))
  (let ((texture (slot-value target 'shadow)))
    (%gl:clear-tex-image (gl-name texture) 0 (internal-format texture) :unsigned-byte (cffi:null-pointer))
    (call-next-method)
    (%gl:memory-barrier :shader-image-access-barrier)))

(defmethod paint ((container layered-container) (target shadow-map-pass))
  (let ((*current-layer* (floor +layer-count+ 2))
        (layers (objects container)))
    (loop for unit across (aref layers *current-layer*)
          do (paint unit target))
    (loop for unit across (aref layers (1- (length layers)))
          do (paint unit target))))

(define-class-shader (shadow-map-pass :fragment-shader -150)
  "layout(binding = 0, r8) uniform writeonly image2D shadow_map;
uniform vec2 light_direction = vec2(0, -1);

void main(){
  ivec2 size = imageSize(shadow_map);
  ivec2 pos = ivec2(gl_FragCoord.xy-vec2(0.5));

  if(0 < color.a)
    imageStore(shadow_map, shadow_map_position(pos, size, light_direction), vec4(1));
}")

(define-shader-pass shadow-render-pass (per-object-pass shadow-lookup-mixin)
  ((shadow :port-type trial::image-in :texspec (:internal-format :r8))))

(define-class-shader (shadow-render-pass :fragment-shader -150)
  "layout(binding = 0, r8) uniform readonly image2D shadow_map;
uniform vec2 light_direction = vec2(0, -1);
out vec4 color;

void main(){
  ivec2 size = imageSize(shadow_map);
  ivec2 pos = ivec2(gl_FragCoord.xy-vec2(0.5));

  float shadow = imageLoad(shadow_map, shadow_map_position(pos, size, light_direction)).r;
  if(0 < shadow) color *= 0.5;
}")
