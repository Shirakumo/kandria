(in-package #:org.shirakumo.fraf.leaf)

(defvar *default-tile-size* 32)

(define-pool leaf
  :base :leaf)

(define-asset (leaf ground) image
    #p"ground.png")

(define-asset (leaf block) mesh
    (make-cube 32))

(defclass main (trial:main)
  ()
  (:default-initargs :clear-color (vec 0 0 0)))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))

(progn
  (defmethod setup-scene ((main main) scene)
    (enter (tiles->layer (list (make-tile (vec 0 0) (vec 0 0))
                               (make-tile (vec 0 0) (vec 0 0))
                               (make-tile (vec 32 0) (vec 0 2))
                               (make-tile (vec 32 32) (vec 1 0))
                               (make-tile (vec 32 64) (vec 0 1)))
                         (asset 'leaf 'ground))
           scene)
    (enter (make-instance 'player :vertex-array (asset 'leaf 'block)) scene)
    (enter (make-instance '2d-camera :location (vec -300 -300 0)) scene)
    (enter (make-instance 'render-pass) scene))
  (maybe-reload-scene))

(define-shader-subject player (vertex-entity located-entity)
  ())

;; Solids
(defclass surface (entity)
  ((tiles :initarg :tiles :accessor tiles)
   (blocks :initarg :blocks :accessor blocks))
  (:default-initargs
   :tiles (make-array 0 :element-type '(unsigned-byte 8))
   :blocks (vector (vec2 0 0)
                   (vec2 0 *default-tile-size*)
                   (vec2 *default-tile-size* 0))))

;; Decals
(define-shader-entity layer ()
  ((vertex-array :initarg :vertex-array :accessor vertex-array)
   (tilecount :initarg :tilecount :accessor tilecount)
   (texture :initarg :texture :accessor texture)
   (level :initarg :level :accessor level))
  (:default-initargs
   :vertex-array (error "VERTEX-ARRAY required")
   :texture (error "TEXTURE required")
   :tilecount (error "TILECOUNT required")
   :level 0))

(define-class-shader (layer :vertex-shader)
  "
layout (location = 0) in vec3 position;
layout (location = 1) in ivec2 tile_pos;
layout (location = 2) in ivec2 tile_tex;
uniform vec2 camera = vec2(0, 0);
uniform int level = 0;
uniform mat4 projection_matrix;
uniform mat4 view_matrix;
uniform mat4 model_matrix;
flat out ivec2 uv;

void main(){
  // We offset the tile tex by the quad pos since they align.
  uv = ivec2(position.x, position.y);
  // Same for the actual vertex positions.
  vec3 pos = position;
  pos.xy += tile_pos;
  pos.z = level;
  gl_Position = projection_matrix * view_matrix * model_matrix * vec4(pos, 1);
}")

(define-class-shader (layer :fragment-shader)
  "
uniform sampler2D tileset;
flat in ivec2 uv;
out vec4 color;

void main(){
  color = texelFetch(tileset, uv, 0);
  color.r = 1;
  color.a = 1;
}")

(defmethod paint ((layer layer) (pass shader-pass))
  (let ((program (shader-program-for-pass pass layer)))
    (setf (uniform program "level") (level layer))
    (setf (uniform program "model_matrix") (model-matrix))
    (setf (uniform program "view_matrix") (view-matrix))
    (setf (uniform program "projection_matrix") (projection-matrix))
    (gl:active-texture :texture0)
    (setf (uniform program "tileset") 0)
    (gl:bind-texture :texture-2d (gl-name (texture layer)))
    (gl:bind-vertex-array (gl-name (vertex-array layer)))
    (%gl:draw-elements-instanced :triangles (size (vertex-array layer)) :unsigned-int 0 1)))

(defstruct (tile (:constructor make-tile (pos tex)))
  (pos (vec2 0 0) :type vec2)
  (tex (vec2 0 0) :type vec2))

(defun pack-tileset (tiles &key (tile-size *default-tile-size*))
  (let* ((vao (change-class (make-rectangle tile-size tile-size :align :bottomleft) 'vertex-array))
         (arr (make-array (* 4 (length tiles)) :element-type '(signed-byte 32)))
         (vbo (make-instance 'vertex-buffer :buffer-data arr :element-type :int))
         (i -1))
    (dolist (tile tiles)
      ;; FIXME: we only really need a single short for the tex.
      (setf (aref arr (incf i)) (floor (vx (tile-pos tile))))
      (setf (aref arr (incf i)) (floor (vy (tile-pos tile))))
      (setf (aref arr (incf i)) (floor (vx (tile-tex tile))))
      (setf (aref arr (incf i)) (floor (vy (tile-tex tile)))))
    (push (list vbo :index 1 :offset 0 :size 2 :stride (* 4 4) :instancing 1) (bindings vao))
    (push (list vbo :index 2 :offset 8 :size 2 :stride (* 4 4) :instancing 1) (bindings vao))
    vao))

(defun tiles->layer (tiles tileset &key (level 0) (tile-size *default-tile-size*))
  (make-instance 'layer :level level
                        :texture tileset
                        :tilecount (length tiles)
                        :vertex-array  (pack-tileset tiles :tile-size tile-size)))
