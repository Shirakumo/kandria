(in-package #:org.shirakumo.fraf.leaf)

(define-pool leaf
  :base :leaf)

(define-asset (leaf ground) image
    #p"ground.png")

(define-asset (leaf surface) image
    #p"surface.png")

(define-asset (leaf player) mesh
    (make-rectangle 8 16))

(define-asset (leaf square) mesh
    (make-rectangle 8 8 :align :topleft))

(define-subject camera (trial:2d-camera)
  ((zoom :initarg :zoom :initform 2 :accessor zoom)
   (target :initarg :target :initform NIL :accessor target))
  (:default-initargs :location (vec 0 0)))

(defmethod enter :after ((camera camera) (scene scene))
  (setf (target camera) (unit :player scene)))

(define-handler (camera trial:tick) (ev)
  (let ((loc (location camera)))
    (when (target camera)
      (let ((tar (location (target camera))))
        (vsetf loc (vx tar) (vy tar))
        (nv- loc (vec 100 100))))
    (nvclamp (vec 0 0) loc 64)))

(defmethod project-view ((camera camera) ev)
  (let ((z (zoom camera)))
    (reset-matrix *view-matrix*)
    (scale-by z z z *view-matrix*)
    (translate (v- (vxy_ (location camera))) *view-matrix*)))

(defclass main (trial:main)
  ((scene :initform NIL))
  (:default-initargs :clear-color (vec 0 0 0)
                     :title "Leaf - 0.0.0"))

(defmethod initialize-instance ((main main) &key map)
  (call-next-method)
  (setf (scene main)
        (if map
            (make-instance 'level :file (pool-path 'leaf map))
            (make-instance 'empty-level))))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))

(defmethod setup-scene ((main main) scene)
  (enter (make-instance 'editor) scene)
  (enter (make-instance 'camera :name :camera) scene)
  (enter (make-instance 'render-pass) scene))

(defclass empty-level (level)
  ())

(defmethod initialize-instance :after ((level empty-level) &key)
  (enter (make-instance 'layer :size '(512 512) :texture (asset 'leaf 'ground) :tile-size 8) level)
  (enter (make-instance 'player :size (vec 8 16)) level)
  (enter (make-instance 'surface :size '(512 512) :tile-size 8) level))
