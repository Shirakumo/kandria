(in-package #:org.shirakumo.fraf.leaf)

(defparameter *default-tile-size* 8)

(define-shader-entity layer (bakable)
  ((vertex-array :initform NIL :accessor vertex-array)
   (texture :initarg :texture :accessor texture)
   (tiles :initarg :tiles :accessor tiles)
   (size :initarg :size :accessor size)
   (tile-size :initarg :tile-size :accessor tile-size)
   (level :initarg :level :accessor level))
  (:default-initargs
   :texture (error "TEXTURE required")
   :tiles NIL
   :size (error "SIZE required")
   :tile-size *default-tile-size*
   :name :layer-0
   :level 0))

(defmethod initialize-instance :after ((layer layer) &key size)
  (unless (tiles layer)
    (setf (tiles layer) (make-array (apply #'* size) :element-type '(unsigned-byte 8)
                                                     :initial-element 0))))

(defmethod bake ((layer layer))
  (let* ((t-s (coerce (tile-size layer) 'single-float))
         (gbuf (make-instance 'vertex-buffer :buffer-data (vector 0.0 0.0 t-s 0.0 0.0 t-s 0.0 t-s t-s 0.0 t-s t-s)))
         (tbuf (make-instance 'vertex-buffer :buffer-data (tiles layer) :element-type :unsigned-byte))
         (vao (make-instance 'vertex-array :bindings () :size 6)))
    (push (list gbuf :index 0 :offset 0 :size 2 :stride (* 2 (gl-type-size :float))) (bindings vao))
    (push (list tbuf :index 1 :offset 0 :size 1 :stride (gl-type-size :unsigned-byte) :instancing 1) (bindings vao))
    (setf (vertex-array layer) vao)))

(defmethod resize ((layer layer) width height)
  (setf (size layer) (list width height)))

(defmethod (setf size) :before (size (layer layer))
  (destructuring-bind (width height) size
    (let ((buffer (caar (bindings (vertex-array layer))))
          (new (make-array (* width height) :element-type '(unsigned-byte 8)
                                            :initial-element 0)))
      (destructuring-bind (w h) (size layer)
        (dotimes (y (min height h))
          (dotimes (x (min width w))
            (setf (aref new (+ x (* y width)))
                  (aref (tiles layer) (+ x (* y w)))))))
      (setf (buffer-data buffer) new)
      (setf (tiles layer) new)
      (when (gl-name buffer)
        (setf (size buffer) (length new))
        (update-buffer-data buffer (tiles layer))))))

(defmethod paint ((layer layer) (pass shader-pass))
  (let ((program (shader-program-for-pass pass layer)))
    (setf (uniform program "view_matrix") (view-matrix))
    (setf (uniform program "projection_matrix") (projection-matrix))
    (setf (uniform program "level") (level layer))
    (setf (uniform program "layer_width") (first (size layer)))
    (setf (uniform program "tile_size") (tile-size layer))
    (setf (uniform program "tileset") 0)
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (texture layer)))
    (gl:bind-vertex-array (gl-name (vertex-array layer)))
    (%gl:draw-arrays-instanced :triangles 0 6 (length (tiles layer)))))

(define-class-shader (layer :vertex-shader)
  "
layout (location = 0) in vec2 vertex;
layout (location = 1) in int tile_id;
uniform sampler2D tileset;
uniform mat4 projection_matrix;
uniform mat4 view_matrix;
uniform int layer_width;
uniform int tile_size = 32;
uniform int level = 0;
out vec2 uv;

void main(){
  int tileset_width = textureSize(tileset, 0).x / tile_size;
  vec2 tile_tex = vec2(tile_id % tileset_width, tile_id / tileset_width) * tile_size;
  uv = vertex + tile_tex;

  vec2 tile_pos = vec2(gl_InstanceID % layer_width, gl_InstanceID / layer_width) * tile_size;
  gl_Position = projection_matrix * view_matrix * vec4(vertex+tile_pos, level, 1);
}")

(define-class-shader (layer :fragment-shader)
  "
uniform sampler2D tileset;
in vec2 uv;
out vec4 color;

void main(){
  color = texelFetch(tileset, ivec2(uv), 0);
}")

(defun tile (location layer)
  (let ((x (floor (vx location) (tile-size layer)))
        (y (floor (vy location) (tile-size layer))))
    (when (and (< -1 x (first (size layer)))
               (< -1 y (second (size layer))))
      (let ((pos (+ x (* y (first (size layer))))))
        (aref (tiles layer) pos)))))

(defun (setf tile) (value location layer)
  (let ((x (floor (vx location) (tile-size layer)))
        (y (floor (vy location) (tile-size layer))))
    (when (and (< -1 x (first (size layer)))
               (< -1 y (second (size layer))))
      (let ((pos (+ x (* y (first (size layer))))))
        (setf (aref (tiles layer) pos) value)
        (update-buffer-data (caar (bindings (vertex-array layer))) (tiles layer)
                            :buffer-start pos :buffer-end (1+ pos)
                            :data-start pos :data-end (1+ pos))
        value))))
