(in-package #:org.shirakumo.fraf.kandria)

;; FIXME: integrate into chunk

(define-gl-struct bg
  (parallax :vec2 :accessor parallax)
  (scaling :vec2 :accessor scaling)
  (offset :vec2 :accessor offset))

(define-gl-struct backgrounds
  (a (:struct bg) :reader a)
  (b (:struct bg) :reader b)
  (mix :float :accessor mix))

(define-asset (kandria backgrounds) uniform-block
    'backgrounds)

(defclass backgrounded ()
  ((background :initform (// 'kandria 'debug-bg) :initarg :background :accessor background
               :type texture)
   (background-parallax :initform (vec 2 1) :initarg :background-parallax :accessor background-parallax
                        :type vec2)
   (background-scaling :initform (vec 1.5 1.5) :initarg :background-scaling :accessor background-scaling
                       :type vec2)
   (background-offset :initform (vec 0 0) :initarg :background-offset :accessor background-offset
                      :type vec2)))

(defmethod stage :after ((backgrounded backgrounded) (area staging-area))
  (stage (background backgrounded) area))

(define-shader-entity background (lit-entity listener ephemeral)
  ((vertex-array :initform (// 'trial:trial 'trial::fullscreen-square) :accessor vertex-array)
   (texture-a :initform (// 'kandria 'debug-bg) :initarg :texture-a :accessor texture-a)
   (texture-b :initform (// 'kandria 'debug-bg) :initarg :texture-b :accessor texture-b))
  (:buffers (kandria backgrounds)))

(defmethod initargs append ((_ background))
  `(:texture))

(defmethod layer-index ((_ background)) 0)

(defmethod stage :after ((background background) (area staging-area))
  (stage (texture-a background) area)
  (stage (texture-b background) area))

(defmethod render ((background background) (program shader-program))
  (let ((vao (vertex-array background)))
    (setf (uniform program "view_size") (vec2 (max 1 (width *context*)) (max 1 (height *context*))))
    (setf (uniform program "view_matrix") (minv *view-matrix*))
    (setf (uniform program "texture_a") 0)
    (setf (uniform program "texture_b") 1)
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (texture-a background)))
    (gl:active-texture :texture1)
    (gl:bind-texture :texture-2d (gl-name (texture-b background)))
    (gl:bind-vertex-array (gl-name vao))
    (unwind-protect
         (%gl:draw-elements :triangles (size vao) :unsigned-int 0)
      (gl:bind-vertex-array 0))))

(defmethod handle ((ev switch-chunk) (background background))
  (with-buffer-tx (backgrounds (// 'kandria 'backgrounds))
    (setf (mix backgrounds) (float (- 1 (min 1 (mix backgrounds)))))
    (let ((a (a backgrounds))
          (b (b backgrounds)))
      ;; First move the target to be the source
      (setf (texture-a background) (texture-b background))
      (setf (parallax a) (parallax b))
      (setf (scaling a) (scaling b))
      (setf (offset a) (offset b))
      ;; Then set new source parameters
      (setf (texture-b background) (background (chunk ev)))
      (setf (parallax b) (background-parallax (chunk ev)))
      (setf (scaling b) (background-scaling (chunk ev)))
      (setf (offset b) (background-offset (chunk ev))))))

(defmethod handle ((ev tick) (background background))
  (when (< (mix (struct (// 'kandria 'backgrounds))) 1)
    (with-buffer-tx (backgrounds (// 'kandria 'backgrounds))
      (incf (mix backgrounds) (dt ev)))))

(define-class-shader (background :vertex-shader)
  (gl-source (asset 'kandria 'backgrounds))
  "layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 vertex_uv;
uniform sampler2D texture_a;
uniform sampler2D texture_b;
uniform mat4 view_matrix;
uniform vec2 view_size;
out vec2 map_coord_a;
out vec2 map_coord_b;

void main(){
  gl_Position = vec4(vertex, 1);
  // We start in view-space, so we have to inverse-map to world-space.
  vec2 size_a = textureSize(texture_a, 0).xy;
  map_coord_a = (view_matrix * vec4(vertex_uv*view_size*backgrounds.a.parallax, 0, 1)).xy;
  map_coord_a += size_a/2 + backgrounds.a.offset;
  map_coord_a /= backgrounds.a.parallax * backgrounds.a.scaling * size_a;

  vec2 size_b = textureSize(texture_b, 0).xy;
  map_coord_b = (view_matrix * vec4(vertex_uv*view_size*backgrounds.b.parallax, 0, 1)).xy;
  map_coord_b += size_b/2 + backgrounds.b.offset;
  map_coord_b /= backgrounds.b.parallax * backgrounds.b.scaling * size_b;
}")

(define-class-shader (background :fragment-shader)
  (gl-source (asset 'kandria 'backgrounds))
  "uniform sampler2D texture_a;
uniform sampler2D texture_b;
in vec2 map_coord_a;
in vec2 map_coord_b;
out vec4 color;

void main(){
  vec4 color_a = texture2D(texture_a, map_coord_a);
  vec4 color_b = texture2D(texture_b, map_coord_b);
  color = apply_lighting(mix(color_a, color_b, backgrounds.mix), vec2(0, 0), 0);
}")
