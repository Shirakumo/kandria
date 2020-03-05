(in-package #:org.shirakumo.fraf.leaf)

(defstruct (block (:constructor make-block (s)))
  (s 0 :type (unsigned-byte 16)))

(defstruct (ground (:include block)
                   (:constructor make-ground (s))))

(defstruct (platform (:include block)
                     (:constructor make-platform (s))))

(defstruct (spike (:include block)
                  (:constructor make-spike (s))))

(defstruct (slope (:include block)
                  (:constructor make-slope (s l r)))
  (l NIL :type vec2)
  (r NIL :type vec2))

(defstruct (stopper (:include block)
                    (:constructor make-stopper (s))))

(defun make-surface-blocks (t-s slope-steps)
  (let ((blocks (make-array (+ 5 (* 2 (reduce #'+ slope-steps)))))
        (i -1))
    (flet ((make (c &rest args)
             (setf (aref blocks (incf i)) (apply (find-symbol (format NIL "MAKE-~a" c)) t-s args))))
      (make 'block)
      (make 'ground)
      (make 'platform)
      (make 'spike)
      (loop for steps in slope-steps
            do (loop for i from 0 below steps
                     for l = (* (/ i steps) t-s)
                     for r = (* (/ (1+ i) steps) t-s)
                     do (make 'slope
                              (vec2 (/ t-s -2) (- (floor l) (/ t-s 2)))
                              (vec2 (/ t-s +2) (- (floor r) (/ t-s 2)))))
            do (loop for i downfrom steps above 0
                     for l = (* (/ i steps) t-s)
                     for r = (* (/ (1- i) steps) t-s)
                     do (make 'slope
                              (vec2 (/ t-s -2) (- (floor l) (/ t-s 2)))
                              (vec2 (/ t-s +2) (- (floor r) (/ t-s 2))))))
      (make 'stopper)
      blocks)))

(sb-ext:defglobal +surface-blocks+ NIL)
(setf +surface-blocks+ (make-surface-blocks +tile-size+ '(1 2 3)))

(defstruct (hit (:constructor make-hit (object time location normal)))
  (object NIL)
  (time 0.0 :type single-float)
  (location NIL :type vec2)
  (normal NIL :type vec2))

(defmethod velocity ((block block))
  #.(vec2 0 0))

(defmethod collides-p (object target hit)
  T)

(defun aabb (seg-pos seg-vel aabb-pos aabb-size)
  (declare (type vec2 seg-pos seg-vel aabb-pos aabb-size))
  (sb-int:with-float-traps-masked (:overflow :underflow :inexact :invalid)
    (let* ((scale (vec2 (if (= 0 (vx seg-vel)) float-features:single-float-positive-infinity (/ (vx seg-vel)))
                        (if (= 0 (vy seg-vel)) float-features:single-float-positive-infinity (/ (vy seg-vel)))))
           (sign (vec2 (if (<= 0. (vx seg-vel)) +1. -1.)
                       (if (<= 0. (vy seg-vel)) +1. -1.)))
           (near (v* (v- (v- aabb-pos (v* sign aabb-size)) seg-pos) scale))
           (far  (v* (v- (v+ aabb-pos (v* sign aabb-size)) seg-pos) scale)))
      (unless (or (< (vy far) (vx near))
                  (< (vx far) (vy near)))
        (let ((t-near (max (vx near) (vy near)))
              (t-far (min (vx far) (vy far))))
          (when (and (< t-near 1)
                     (< 0 t-far))
            (let ((normal (cond ((< t-near 0)
                                 (let ((dist (v- seg-pos aabb-pos)))
                                   (if (< (abs (vy dist)) (abs (vx dist)))
                                       (vec (signum (vx dist)) 0)
                                       (vec 0 (signum (vy dist))))))
                                ((< (vy near) (vx near))
                                 (vec (- (vx sign)) 0))
                                (T
                                 (vec 0 (- (vy sign)))))))
              (unless (= 0 (v. normal seg-vel))
                ;; KLUDGE: This test is necessary in order to ignore vertical edges
                ;;         that seem to stick out of the blocks. I have no idea why.
                (unless (and (/= 0 (vy normal))
                             (<= (vx aabb-size) (abs (- (vx aabb-pos) (vx seg-pos)))))
                  (make-hit NIL
                            t-near
                            aabb-pos
                            normal))))))))))

(defun rayline (ray dir a b)
  (declare (type vec2 ray dir a b))
  (let* ((lin (v- b a))
         (div (+ (* (- (vx2 lin)) (vy2 dir))
                 (* (+ (vx2 dir)) (vy2 lin)))))
    (when (/= 0.0 div)
      (let ((r (/ (+ (* (- (vy2 dir)) (- (vx2 ray) (vx2 a)))
                     (* (+ (vx2 dir)) (- (vy2 ray) (vy2 a))))
                  div))
            (l (/ (- (* (vx2 lin) (- (vy2 ray) (vy2 a)))
                     (* (vy2 lin) (- (vx2 ray) (vx2 a))))
                  div)))
        (when (and (<= 0 r 1) (<= 0 l 1))
          l)))))

(defun slope (pos vel size slope loc)
  (let* ((l (slope-l slope))
         (r (slope-r slope))
         (dir (signum (- (vy l) (vy r)))))
    (rayline pos vel
             (vec2 (+ (vx loc) (vx l) (* dir (vx size)))
                   (+ (vy loc) (vy l) (vy size)))
             (vec2 (+ (vx loc) (vx r) (* dir (vx size)))
                   (+ (vy loc) (vy r) (vy size))))))

#++ ;; Something's fucked with slopes and I don't know what.
(progn
  (assert (slope (vec 0 0) (vec  1 0) (vec 8 8) (aref +surface-blocks+ 4) (vec 16   0)))
  (assert (slope (vec 0 0) (vec  8 0) (vec 8 8) (aref +surface-blocks+ 4) (vec 16  -8)))
  (assert (slope (vec 0 0) (vec 16 0) (vec 8 8) (aref +surface-blocks+ 4) (vec 16 -16)))

  (assert (slope (vec 0 0) (vec 0  -1) (vec 8 8) (aref +surface-blocks+ 4) (vec  0 -16)))
  (assert (slope (vec 0 0) (vec 0  -8) (vec 8 8) (aref +surface-blocks+ 4) (vec  8 -16)))
  (assert (slope (vec 0 0) (vec 0 -16) (vec 8 8) (aref +surface-blocks+ 4) (vec 16 -16))))
