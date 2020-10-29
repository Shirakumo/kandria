(in-package #:org.shirakumo.fraf.kandria)

(define-asset (kandria rope-part) mesh
    (make-rectangle 2 8 :align :topcenter))

(define-shader-entity rope (lit-vertex-entity sized-entity interactable listener resizable ephemeral)
  ((vertex-array :initform (// 'kandria 'rope-part))
   (chain :initform #() :accessor chain))
  (:inhibit-shaders (shader-entity :fragment-shader)))

(defmethod initialize-instance :after ((rope rope) &key)
  (setf (chain rope) (make-array (floor (vy (bsize rope)) 4)))
  (loop for i from 0 below (length (chain rope))
        do (setf (aref (chain rope) i) (list (vec 0 (* i -8)) (vec 0 (* i -8))))))

(defmethod interactable-p ((rope rope)) NIL)

(defmethod layer-index ((rope rope)) +base-layer+)

(defmethod nudge ((rope rope) pos strength)
  (let ((i (floor (- (+ (vy (location rope)) (vy (bsize rope))) (vy pos)) 8))
        (chain (chain rope)))
    (when (<= 1 i (- (length chain) 2))
      (setf (vx (first (aref chain (1- i)))) 0)
      (setf (vx (first (aref chain i))) strength)
      (incf (vx (first (aref chain (1+ i)))) (* (signum strength) -0.5)))))

(defmethod handle ((ev tick) (rope rope))
  (declare (optimize speed))
  (when (in-view-p (location rope) (bsize rope))
    (let ((chain (chain rope))
          (drag 0.9)
          (g #.(vec 0 -9)))
      (declare (type (simple-array T (*)) chain))
      (loop for (pos prev) across chain
            do (let ((dx (* (- (vx pos) (vx prev)) drag))
                     (dy (* (- (vy pos) (vy prev)) drag)))
                 (vsetf prev (vx pos) (vy pos))
                 (incf (vx pos) (+ dx (* (vx g) (the single-float (dt ev)))))
                 (incf (vy pos) (+ dy (* (vy g) (the single-float (dt ev)))))
                 (let ((real (v+ pos (location rope))))
                   (incf (vy real) (vy (bsize rope)))
                   (when (scan-collision +world+ real)
                     (setf (vx pos) (- (vx prev) (* 0.25 dx)))))))
      (vsetf (first (aref chain 0)) 0 0)
      (dotimes (r 50)
        (loop for i from 1 below (length chain)
              for (p1) = (aref chain (1- i))
              for (p2) = (aref chain i)
              for d = (v- p2 p1)
              for dist = (vlength d)
              for frac = (/ (- 8 dist) (max 0.1 dist) 2)
              do (nv* d frac)
                 (nv- p1 d)
                 (nv+ p2 d))))))

(defmethod render ((rope rope) (program shader-program))
  (let ((chain (chain rope)))
    (translate-by 0 (vy (bsize rope)) 0)
    (loop for i from 0 below (1- (length chain))
          for (p1) = (aref chain i)
          for (p2) = (aref chain (1+ i))
          for d = (v- p2 p1)
          for angle = (atan (vy d) (vx d))
          do (with-pushed-matrix ()
               (translate-by (vx p1) (vy p1) 0)
               (rotate-by 0 0 1 (+ angle (/ PI 2)))
               (call-next-method)))))

(define-class-shader (rope :fragment-shader 1)
  "out vec4 color;

void main(){
  color = vec4(0.3,0.2,0.05,1);
}")

(defmethod resize ((rope rope) width height)
  (vsetf (bsize rope) (/ +tile-size+ 2) (/ height 2))
  (setf (chain rope) (make-array (floor height 8)))
  (loop for i from 0 below (length (chain rope))
        do (setf (aref (chain rope) i) (list (vec 0 (* i -8)) (vec 0 (* i -8))))))
