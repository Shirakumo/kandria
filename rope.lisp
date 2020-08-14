(in-package #:org.shirakumo.fraf.leaf)

(define-asset (leaf rope-part) mesh
    (make-rectangle 2 8 :align :topcenter))

(define-shader-entity rope (lit-entity vertex-entity sized-entity interactable listener resizable ephemeral)
  ((vertex-array :initform (// 'leaf 'rope-part))
   (chain :initform #() :accessor chain)))

(defmethod initialize-instance :after ((rope rope) &key)
  (setf (chain rope) (make-array (floor (vy (bsize rope)) 4)))
  (loop for i from 0 below (length (chain rope))
        do (setf (aref (chain rope) i) (list (vec 0 (* i -8)) (vec 0 (* i -8))))))

(defmethod layer-index ((rope rope)) +base-layer+)

(defmethod handle ((ev mouse-press) (rope rope))
  (vsetf (first (aref (chain rope) 1)) 5 0))

(defmethod nudge ((rope rope) pos strength)
  (let ((i (floor (- (+ (vy (location rope)) (vy (bsize rope))) (vy pos)) 8))
        (chain (chain rope)))
    (when (<= 1 i (- (length chain) 2))
      (setf (vx (first (aref chain (1- i)))) 0)
      (setf (vx (first (aref chain i))) strength)
      (incf (vx (first (aref chain (1+ i)))) (* (signum strength) -0.5)))))

(defmethod handle ((ev tick) (rope rope))
  (declare (optimize speed))
  (let ((chain (chain rope))
        (drag 0.9)
        (g (vec 0 -9)))
    (declare (type (simple-array T (*)) chain))
    (loop for (pos prev) across chain
          do (let ((d (v* (v- pos prev) drag)))
               (vsetf prev (vx pos) (vy pos))
               (nv+ pos d (v* g (dt ev)))))
    (vsetf (first (aref chain 0)) 0 0)
    (dotimes (r 50)
      (loop for i from 1 below (length chain)
            for (p1) = (aref chain (1- i))
            for (p2) = (aref chain i)
            for d = (v- p2 p1)
            for dist = (vlength d)
            for frac = (/ (- 8 dist) dist 2)
            do (nv* d frac)
               (nv- p1 d)
               (nv+ p2 d)))))

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

(define-class-shader (rope :fragment-shader)
  "out vec4 color;

void main(){
  color = apply_lighting(vec4(0,0,0,1), vec2(0), 0);
}")

(defmethod resize ((rope rope) width height)
  (vsetf (bsize rope) (/ +tile-size+ 2) (/ height 2))
  (setf (chain rope) (make-array (floor height 8)))
  (loop for i from 0 below (length (chain rope))
        do (setf (aref (chain rope) i) (list (vec 0 (* i -8)) (vec 0 (* i -8))))))
