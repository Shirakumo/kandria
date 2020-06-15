(in-package #:org.shirakumo.fraf.leaf)

;; FIXME: integrate into chunk

(define-shader-entity background (lit-entity textured-entity ephemeral)
  ((vertex-array :initform (asset 'trial:trial 'trial::fullscreen-square) :accessor vertex-array)
   (parallax-speed :initform (vec 2 1) :initarg :parallax-speed :accessor parallax-speed)
   (parallax-direction :initform 1 :initarg :parallax-direction :accessor parallax-direction)
   (background-scale :initform (vec 1.5 1.5) :initarg :background-scale :accessor background-scale))
  (:inhibit-shaders (textured-entity :fragment-shader)))

(defmethod initargs append ((_ background))
  `(:texture))

(defmethod layer-index ((_ background)) 0)

(defmethod clone ((background background))
  (make-instance (class-of background)
                 :texture (texture background)))

(defmethod render ((background background) (program shader-program))
  (let ((vao (vertex-array background)))
    (setf (uniform program "view_size") (vec2 (width *context*) (height *context*)))
    (setf (uniform program "view_matrix") (minv *view-matrix*))
    (setf (uniform program "model_matrix") (minv *model-matrix*))
    (setf (uniform program "parallax_speed") (parallax-speed background))
    (setf (uniform program "parallax_direction") (parallax-direction background))
    (setf (uniform program "background_scale") (background-scale background))
    (setf (uniform program "background") 0)
    (gl:bind-vertex-array (gl-name vao))
    (unwind-protect
         (%gl:draw-elements :triangles (size vao) :unsigned-int 0)
      (gl:bind-vertex-array 0))))

(define-class-shader (background :vertex-shader)
  "layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 vertex_uv;
uniform vec2 parallax_speed = vec2(2, 1);
uniform vec2 background_scale = vec2(2, 2); 
uniform mat4 view_matrix;
uniform mat4 model_matrix;
uniform vec2 view_size;
out vec2 map_coord;

void main(){
  // We start in view-space, so we have to inverse-map to world-space.
  map_coord = (model_matrix * (view_matrix * vec4(vertex_uv*view_size*parallax_speed, 0, 1))).xy;
  map_coord /= parallax_speed * background_scale;
  gl_Position = vec4(vertex, 1);
}")

(define-class-shader (background :fragment-shader)
  "uniform sampler2D background;
uniform int parallax_direction = 1;
in vec2 map_coord;
out vec4 color;

void main(){
  ivec2 map_wh = textureSize(background, 0);
  ivec2 map_xy = ivec2(map_coord);

  switch(parallax_direction){
    case 0:
      map_xy = clamp(map_xy, ivec2(0), map_wh-1);
      break;
    case 1: 
      map_xy.x %= map_wh.x;
      map_xy.y = clamp(map_xy.y, 0, map_wh.y-1);
      break;
    case 2: 
      map_xy.x = clamp(map_xy.x, 0, map_wh.x-1);
      map_xy.y %= map_wh.y;
      break;
    case 3:
      map_xy %= map_wh;
      break;
  }
  
  color = texelFetch(background, map_xy, 0);
  color = mix(color, apply_lighting(color, vec2(0, 0), 0), 1);
}")
