(in-package #:org.shirakumo.fraf.leaf)

(defvar *default-tile-size* 32)

(define-pool leaf
  :base :leaf)

(define-asset (leaf ground) image
    #p"ground.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (leaf player) mesh
    (make-sphere 16 :segments 8))

(define-asset (leaf square) mesh
    (make-rectangle 32 32 :align :topleft))

(defclass main (trial:main)
  ()
  (:default-initargs :clear-color (vec 0 0 0)))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))

(progn
  (defmethod setup-scene ((main main) scene)
    (enter (make-instance 'player) scene)
    (enter (make-instance 'layer :size '(8 8) :texture (asset 'leaf 'ground)) scene)
    (enter (make-instance 'editor) scene)
    (enter (make-instance '2d-camera :location (vec -300 -300 0) :name :camera) scene)
    (enter (make-instance 'render-pass) scene))
  (maybe-reload-scene))

(define-shader-subject player (vertex-entity located-entity)
  ()
  (:default-initargs :vertex-array (asset 'leaf 'player)))

(define-shader-subject editor (vertex-entity located-entity)
  ((texture :initarg :texture :accessor texture)
   (layer :initform NIL :accessor layer))
  (:default-initargs :vertex-array (asset 'leaf 'square)))

(defmethod enter :after ((editor editor) (scene scene))
  (setf (layer editor) (unit :layer-0 scene)))

(define-handler (editor mouse-move) (ev pos)
  (setf (vxy (location editor)) (v+ pos (vxy (location (unit :camera (scene (handler *context*)))))))
  (when (layer editor)
    (let ((t-s (tile-size (layer editor))))
      (setf (vx (location editor)) (* t-s (floor (vx (location editor)) t-s)))
      (setf (vy (location editor)) (* t-s (floor (vy (location editor)) t-s))))))

(define-handler (editor mouse-press) (ev button)
  (let ((layer (layer editor)))
    (when layer
      (case button
        (:left (setf (tile (location editor) layer) 1))
        (:right (setf (tile (location editor) layer) 0))))))

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
   (texture :initarg :texture :accessor texture)
   (tiles :initarg :tiles :accessor tiles)
   (tile-size :initarg :tile-size :accessor tile-size)
   (level :initarg :level :accessor level))
  (:default-initargs
   :texture (error "TEXTURE required")
   :name :layer-0
   :tile-size *default-tile-size*
   :level 0))

(defmethod initialize-instance :after ((layer layer) &key tiles size)
  (cond (tiles
         (check-type tiles (array (unsigned-byte 8) (* *))))
        (size
         (setf (tiles layer) (make-array size :element-type '(unsigned-byte 8) :initial-element 0)))
        (T (error "TILES or SIZE required")))
  (pack-layer layer))

(define-class-shader (layer :vertex-shader)
  "
layout (location = 0) in vec2 vertex;
layout (location = 1) in vec2 tile_pos;
layout (location = 2) in vec2 tile_tex;
uniform mat4 projection_matrix;
uniform mat4 view_matrix;
uniform int level = 0;
out vec2 uv;

void main(){
  uv = vertex+tile_tex;
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

(defmethod paint ((layer layer) (pass shader-pass))
  (let ((program (shader-program-for-pass pass layer)))
    (setf (uniform program "view_matrix") (view-matrix))
    (setf (uniform program "projection_matrix") (projection-matrix))
    (setf (uniform program "level") (level layer))
    (setf (uniform program "tileset") 0)
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (texture layer)))
    (gl:bind-vertex-array (gl-name (vertex-array layer)))
    (%gl:draw-arrays-instanced :triangles 0 (size (vertex-array layer))
                               (array-total-size (tiles layer)))))

(defun pack-layer (layer)
  (let* ((tiles (tiles layer))
         (t-s (coerce (tile-size layer) 'single-float))
         (vao (make-instance 'vertex-array :bindings () :size 6))
         (arr (make-array (* 4 (array-total-size tiles)) :element-type 'single-float))
         (vbo (make-instance 'vertex-buffer :buffer-data arr))
         (gem (make-instance 'vertex-buffer :buffer-data (vector 0.0 0.0
                                                                 t-s 0.0
                                                                 0.0 t-s
                                                                 0.0 t-s
                                                                 t-s 0.0
                                                                 t-s t-s)))
         (j -1))
    (dotimes (y (array-dimension tiles 0))
      (dotimes (x (array-dimension tiles 1))
        (setf (aref arr (incf j)) (* t-s x))
        (setf (aref arr (incf j)) (* t-s y))
        (setf (aref arr (incf j)) (* 32 (coerce (mod (aref tiles x y) 4) 'single-float)))
        (setf (aref arr (incf j)) (* 32 (coerce (floor (aref tiles x y) 4) 'single-float)))))
    (push (list gem :index 0 :offset 0 :size 2 :stride (* 2 4)) (bindings vao))
    (push (list vbo :index 1 :offset 0 :size 2 :stride (* 4 4) :instancing 1) (bindings vao))
    (push (list vbo :index 2 :offset 8 :size 2 :stride (* 4 4) :instancing 1) (bindings vao))
    (setf (vertex-array layer) vao)))

(defun tile (location layer)
  (aref (tiles layer)
        (floor (vx location) (tile-size layer))
        (floor (vx location) (tile-size layer))))

;; FIXME: attempt a scheme where the data array only contains the texture index
;;        and calculate the position based on the instance ID.
(defun (setf tile) (value location layer)
  (let ((x (floor (vx location) (tile-size layer)))
        (y (floor (vy location) (tile-size layer)))
        (tiles (tiles layer)))
    (setf (aref tiles x y) value)
    (let ((buffer (car (second (bindings (vertex-array layer)))))
          (offset (+ (* 4 (+ x (* y (array-dimension (tiles layer) 0)))) 2)))
      (setf (aref (buffer-data buffer) offset) (* 32 (coerce (mod value 4) 'single-float)))
      (setf (aref (buffer-data buffer) (1+ offset)) (* 32 (coerce (floor value 4) 'single-float)))
      (update-buffer-data buffer (buffer-data buffer) :buffer-start offset :data-start offset))))
