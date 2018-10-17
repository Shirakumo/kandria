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
  ((scene :initform (make-instance 'level :file (pool-path 'leaf "empty.map"))))
  (:default-initargs :clear-color (vec 0 0 0)
                     :title "Leaf - 0.0.0"))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))

(defmethod setup-scene ((main main) scene)
  (enter (make-instance 'editor) scene)
  (enter (make-instance '2d-camera :name :camera) scene)
  (enter (make-instance 'render-pass) scene))

;; Solids
(defclass surface (entity)
  ((tiles :initarg :tiles :accessor tiles)
   (blocks :initarg :blocks :accessor blocks))
  (:default-initargs
   :tiles (make-array 0 :element-type '(unsigned-byte 8))
   :blocks (vector (vec2 0 0)
                   (vec2 0 *default-tile-size*)
                   (vec2 *default-tile-size* 0))))
