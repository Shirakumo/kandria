(in-package #:org.shirakumo.fraf.leaf)

(define-pool leaf
  :base :leaf)

(define-asset (leaf ground) image
    #p"ground.png")

(define-asset (leaf surface) image
    #p"surface.png")

(define-asset (leaf player) mesh
    (make-sphere 16 :segments 8))

(define-asset (leaf square) mesh
    (make-rectangle 32 32 :align :topleft))

(defclass main (trial:main)
  ((scene :initform (make-instance 'editor-level)))
  (:default-initargs :clear-color (vec 0 0 0)
                     :title "Leaf - 0.0.0"))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))

(defmethod setup-scene ((main main) scene)
  (enter (make-instance '2d-camera :name :camera) scene)
  (enter (make-instance 'render-pass) scene))

(defclass editor-level (level)
  ())

(defmethod initialize-instance :after ((level editor-level) &key)
  (enter (make-instance 'layer :size '(32 32) :texture (asset 'leaf 'ground)) level)
  (enter (make-instance 'player) level)
  (enter (make-instance 'surface :size '(32 32)) level)
  (enter (make-instance 'editor) level))
