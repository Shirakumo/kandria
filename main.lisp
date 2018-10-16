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

(defclass main (trial:main)
  ()
  (:default-initargs :clear-color (vec 0 0 0)))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))

(progn
  (defmethod setup-scene ((main main) scene)
    (enter (make-instance 'player) scene)
    (enter (tiles->layer (tiles 0   0   0 3
                                32  0   0 1
                                32  32  1 3
                                32  64  0 2
                                64  64  0 3
                                96  64  1 2
                                96  32  1 1
                                128 32  0 3)
                         (asset 'leaf 'ground))
           scene)
    (enter (make-instance '2d-camera :location (vec -300 -300 0)) scene)
    (enter (make-instance 'render-pass) scene))
  (maybe-reload-scene))

(define-shader-subject player (vertex-entity located-entity)
  ()
  (:default-initargs :vertex-array (asset 'leaf 'player)))

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
layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 tile_pos;
layout (location = 2) in vec2 tile_tex;
uniform mat4 projection_matrix;
uniform mat4 view_matrix;
uniform int level = 0;
out vec2 uv;

void main(){
  uv = vertex.xy+tile_tex;
  gl_Position = projection_matrix * view_matrix * vec4(vertex.xy+tile_pos, level, 1);
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
    (%gl:draw-elements-instanced :triangles (size (vertex-array layer))
                                 :unsigned-int 0 (tilecount layer))))

(defstruct (tile (:constructor make-tile (pos tex)))
  (pos (vec2 0 0) :type vec2)
  (tex (vec2 0 0) :type vec2))

(defun tiles (&rest specs)
  (loop for (x y u v) on specs by #'cddddr
        collect (make-tile (vec x y) (vec u v))))

(defun pack-tileset (tiles &key (tile-size *default-tile-size*))
  (let* ((vao (change-class (make-rectangle tile-size tile-size :align :topleft) 'vertex-array))
         (arr (make-array (* 4 (length tiles)) :element-type 'single-float))
         (vbo (make-instance 'vertex-buffer :buffer-data arr))
         (i -1))
    (dolist (tile tiles)
      ;; FIXME: we only really need a single short for the tex.
      (setf (aref arr (incf i)) (vx (tile-pos tile)))
      (setf (aref arr (incf i)) (vy (tile-pos tile)))
      (setf (aref arr (incf i)) (* tile-size (vx (tile-tex tile))))
      (setf (aref arr (incf i)) (* tile-size (vy (tile-tex tile)))))
    (push-end (list vbo :index 1 :offset 0 :size 2 :stride (* 4 4) :instancing 1) (bindings vao))
    (push-end (list vbo :index 2 :offset 8 :size 2 :stride (* 4 4) :instancing 1) (bindings vao))
    vao))

(defun tiles->layer (tiles tileset &key (level 0) (tile-size *default-tile-size*))
  (make-instance 'layer :level level
                        :texture tileset
                        :tilecount (length tiles)
                        :vertex-array  (pack-tileset tiles :tile-size tile-size)))
