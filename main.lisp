(in-package #:org.shirakumo.fraf.leaf)

(defmethod unit (thing (target (eql T)))
  (when *context*
    (unit thing (scene (handler *context*)))))

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
   (target-size :initarg :target-size :accessor target-size)
   (target :initarg :target :initform NIL :accessor target)
   (surface :initform NIL :accessor surface))
  (:default-initargs
   :location (vec 0 0)
   :target-size (vec (* 8 60) 0)))

(defmethod enter :after ((camera camera) (scene scene))
  (setf (target camera) (unit :player scene))
  (setf (surface camera) (unit :surface scene)))

(define-handler (camera trial:tick) (ev)
  (let ((loc (location camera))
        (surface (surface camera))
        (size (target-size camera)))
    (when (target camera)
      (let ((tar (location (target camera))))
        (vsetf loc (vx tar) (vy tar))
        (nv- loc (v/ size 2))))
    (setf (vx loc) (max 0 (min (- (* (first (size surface)) (tile-size surface))
                                  (vx size))
                               (vx loc))))
    (setf (vy loc) (max 0 (min (- (* (second (size surface)) (tile-size surface))
                                  (vy size))
                               (vy loc))))))

(define-handler (camera resize) (ev)
  (setf (zoom camera) (float (/ (width ev) (vx (target-size camera)))))
  (setf (vy (target-size camera)) (/ (height ev) (zoom camera))))

(defmethod project-view ((camera camera) ev)
  (let ((z (zoom camera)))
    (reset-matrix *view-matrix*)
    (scale-by z z z *view-matrix*)
    (translate (nv- (vxy_ (location camera))) *view-matrix*)))

(defclass main (trial:main)
  ((scene :initform NIL))
  (:default-initargs :clear-color (vec 61/255 202/255 245/255)
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
  (let* ((render (make-instance 'render-pass))
         (blink-pass (make-instance 'blink-pass))
         (bokeh-pass (make-instance 'hex-bokeh-pass)))
    (connect (flow:port render 'color) (flow:port blink-pass 'previous-pass) scene)
    (connect (flow:port blink-pass 'color) (flow:port bokeh-pass 'previous-pass) scene)
    ))

(defclass empty-level (level)
  ())

(defmethod initialize-instance :after ((level empty-level) &key)
  (let ((size (list 512 64)))
    (enter (make-instance 'layer :size size :texture (asset 'leaf 'ground) :tile-size 8) level)
    (enter (make-instance 'player :size (vec 8 16)) level)
    (enter (make-instance 'surface :size size :tile-size 8) level)))
