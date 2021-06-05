(in-package #:org.shirakumo.fraf.kandria)

(defclass fishing-spot (sized-entity interactable ephemeral)
  ((direction :initarg :direction :initform +1 :accessor direction
              :type integer)))

(defmethod interactable-p ((spot fishing-spot)) T)

(defmethod interact ((spot fishing-spot) (player player))
  (setf (direction player) (direction spot))
  (setf (state player) :fishing)
  (vsetf (velocity player) 0 0)
  (setf (animation player) 'fishing-start))

(define-shader-entity fishing-buoy (lit-sprite moving)
  ((texture :initform (// 'kandria 'items))
   (size :initform (vec 8 8))
   (layer-index :initform +base-layer+)
   (offset :initform (vec 0 24))))

(defmethod collides-p ((buoy fishing-buoy) (moving moving) hit) NIL)

(defmethod handle :before ((ev tick) (buoy fishing-buoy))
  (let ((vel (velocity buoy)))
    (typecase (medium buoy)
      (water
       (let ((dist (- (+ (vy (location (medium buoy))) (vy (bsize (medium buoy))))
                      (vy (location buoy)))))
         (nv+ vel (v* (vec 0 (clamp 0.3 dist 4)) (dt ev)))))
      (T
       (nv+ vel (v* (gravity (medium buoy)) (dt ev)))))
    (setf (vx vel) (deadzone 0.001 (vx vel)))
    (setf (vy vel) (deadzone 0.001 (vy vel)))
    (nv+ (frame-velocity buoy) vel)))

(define-asset (kandria line-part) mesh
    (make-rectangle 0.5 4 :align :topcenter))

(define-shader-entity fishing-line (lit-vertex-entity listener)
  ((name :initform 'fishing-line)
   (vertex-array :initform (// 'kandria 'line-part))
   (chain :initform #() :accessor chain)
   (location :initform (vec 0 0) :initarg :location :accessor location)
   (buoy :initform (make-instance 'fishing-buoy) :accessor buoy))
  (:inhibit-shaders (shader-entity :fragment-shader)))

(defmethod initialize-instance :after ((fishing-line fishing-line) &key)
  (setf (chain fishing-line) (make-array 64)))

(defmethod layer-index ((fishing-line fishing-line)) +base-layer+)

(defmethod stage ((line fishing-line) (area staging-area))
  (stage (buoy line) area))

(defmethod enter* :after ((line fishing-line) target)
  (let ((chain (chain line))
        (buoy (buoy line)))
    (loop for i from 0 below (length chain)
          do (setf (aref chain i) (list (vcopy (location line)) (vcopy (location line)))))
    (v<- (location buoy) (location line))
    (vsetf (velocity buoy) 8 4)
    (enter* (buoy line) target)))

(defmethod leave* :after ((line fishing-line) from)
  (when (slot-boundp (buoy line) 'container)
    (leave* (buoy line) from)))

(defmethod handle ((ev tick) (fishing-line fishing-line))
  (declare (optimize speed))
  (let ((chain (chain fishing-line))
        (buoy (buoy fishing-line))
        (g #.(vec 0 -80))
        (dt2 (expt (the single-float (dt ev)) 2)))
    (declare (type (simple-array T (*)) chain))
    (flet ((verlet (a b)
             (let ((x (vx a)) (y (vy a)))
               (vsetf a
                      (+ x (* 0.92 (- x (vx b))) (* dt2 (vx g)))
                      (+ y (* 0.92 (- y (vy b))) (* dt2 (vy g))))
               (vsetf b x y)))
           (relax (a b i)
             (let* ((dist (v- b a))
                    (dir (if (v/= 0 dist) (nvunit dist) (vec 0 0)))
                    (delta (- (vdistance a b) i))
                    (off (v* delta dir 0.5)))
               (nv+ a off)
               (nv- b off))))
      (loop for (a b) across chain
            do (verlet a b))
      (v<- (first (aref chain 0)) (location fishing-line))
      (v<- (first (aref chain (1- (length chain)))) (location buoy))
      (dotimes (i 50)
        (loop for i from 1 below (length chain)
              do (relax (first (aref chain (+ -1 i)))
                        (first (aref chain (+  0 i)))
                        4)))
      (let ((last (first (aref chain (1- (length chain)))))
            (loc (location buoy)))
        (incf (vx (velocity buoy)) (* 0.01 (deadzone 0.75 (- (vx last) (vx loc)))))
        (incf (vy (velocity buoy)) (* 0.01 (deadzone 0.75 (- (vy last) (vy loc)))))))))

(defmethod render ((fishing-line fishing-line) (program shader-program))
  (let ((chain (chain fishing-line)))
    (loop for i from 0 below (1- (length chain))
          for (p1) = (aref chain i)
          for (p2) = (aref chain (1+ i))
          for d = (tv- p2 p1)
          for angle = (atan (vy d) (vx d))
          do (with-pushed-matrix ()
               (translate-by (vx p1) (vy p1) 0)
               (rotate-by 0 0 1 (+ angle (/ PI 2)))
               (call-next-method)))))

(define-class-shader (fishing-line :fragment-shader 1)
  "out vec4 color;

void main(){
  color = vec4(0,0,0,1);
}")
