(in-package #:org.shirakumo.fraf.leaf)

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
    (enter (make-instance 'layer :size '(8 8) :texture (asset 'leaf 'ground)) scene)
    (enter (make-instance 'player) scene)
    (enter (make-instance 'editor) scene)
    (enter (make-instance '2d-camera :location (vec -300 -300 0) :name :camera) scene)
    (enter (make-instance 'render-pass) scene))
  (maybe-reload-scene))

(define-shader-subject player (vertex-entity located-entity)
  ()
  (:default-initargs :vertex-array (asset 'leaf 'player)))

(define-shader-subject editor (vertex-entity located-entity)
  ((layer :initform NIL :accessor layer)
   (tile :initform 1 :accessor tile-to-place))
  (:default-initargs :vertex-array (asset 'leaf 'square)))

(define-retention mouse (ev)
  (when (typep ev 'mouse-press)
    (setf (retained 'mouse (button ev)) T))
  (when (typep ev 'mouse-release)
    (setf (retained 'mouse (button ev)) NIL)))

(defmethod enter :after ((editor editor) (scene scene))
  (setf (layer editor) (unit :layer-0 scene)))

(define-handler (editor mouse-move) (ev pos)
  (setf (vxy (location editor)) (v+ pos (vxy (location (unit :camera (scene (handler *context*)))))))
  (when (layer editor)
    (let ((t-s (tile-size (layer editor))))
      (setf (vx (location editor)) (* t-s (floor (vx (location editor)) t-s)))
      (setf (vy (location editor)) (* t-s (floor (vy (location editor)) t-s))))
    (when (retained 'mouse :left)
      (setf (tile (location editor) (layer editor)) (tile-to-place editor)))
    (when (retained 'mouse :right)
      (setf (tile (location editor) (layer editor)) 0))))

(define-handler (editor mouse-press) (ev button)
  (let ((layer (layer editor)))
    (when layer
      (case button
        (:left (setf (tile (location editor) layer) (tile-to-place editor)))
        (:right (setf (tile (location editor) layer) 0))))))

(define-handler (editor mouse-scroll) (ev delta)
  (cond ((< 0 delta)
         (incf (tile-to-place editor)))
        ((< delta 0)
         (decf (tile-to-place editor))))
  (setf (tile-to-place editor)
        (max 0 (tile-to-place editor))))

(defmethod paint :before ((editor editor) (pass shader-pass))
  (let ((program (shader-program-for-pass pass editor))
        (layer (layer editor)))
    (gl:bind-texture :texture-2d (gl-name (texture layer)))
    (multiple-value-bind (y x) (floor (* (tile-size layer) (tile-to-place editor)) (width (texture layer)))
      (setf (uniform program "tile") (vec2 x (* (tile-size layer) y))))))

(define-class-shader (editor :vertex-shader)
  "
layout (location = 0) in vec3 vertex;
uniform vec2 tile;
out vec2 uv;

void main(){
  uv = vertex.xy + tile;
}")

(define-class-shader (editor :fragment-shader)
  "
uniform sampler2D tileset;
in vec2 uv;
out vec4 color;

void main(){
  color = texelFetch(tileset, ivec2(uv), 0);
  color *= 0.5;
}")

;; Solids
(defclass surface (entity)
  ((tiles :initarg :tiles :accessor tiles)
   (blocks :initarg :blocks :accessor blocks))
  (:default-initargs
   :tiles (make-array 0 :element-type '(unsigned-byte 8))
   :blocks (vector (vec2 0 0)
                   (vec2 0 *default-tile-size*)
                   (vec2 *default-tile-size* 0))))
