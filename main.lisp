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
