(in-package #:org.shirakumo.fraf.kandria)

(defstruct (block (:constructor make-block (s)))
  (s 0 :type (unsigned-byte 16)))

(defmethod collides-p ((entity game-entity) (block block) hit) T)

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

(defmethod velocity ((block block))
  #.(vec2 0 0))

(defun aabb (seg-pos seg-vel aabb-pos aabb-size)
  (declare (type vec2 seg-pos seg-vel aabb-pos aabb-size))
  (declare (optimize speed))
  (sb-int:with-float-traps-masked (:overflow :underflow :inexact :invalid)
    (let* ((scale-x (if (= 0 (vx2 seg-vel)) float-features:single-float-positive-infinity (/ (vx2 seg-vel))))
           (scale-y (if (= 0 (vy2 seg-vel)) float-features:single-float-positive-infinity (/ (vy2 seg-vel))))
           (sign-x (if (<= 0. (vx2 seg-vel)) +1. -1.))
           (sign-y (if (<= 0. (vy2 seg-vel)) +1. -1.))
           (near-x (* (- (vx2 aabb-pos) (* sign-x (vx2 aabb-size)) (vx2 seg-pos)) scale-x))
           (near-y (* (- (vy2 aabb-pos) (* sign-y (vy2 aabb-size)) (vy2 seg-pos)) scale-y))
           (far-x (* (- (+ (vx2 aabb-pos) (* sign-x (vx2 aabb-size))) (vx2 seg-pos)) scale-x))
           (far-y (* (- (+ (vy2 aabb-pos) (* sign-y (vy2 aabb-size))) (vy2 seg-pos)) scale-y)))
      (unless (or (< far-y near-x)
                  (< far-x near-y))
        (let ((t-near (max near-x near-y))
              (t-far (min far-x far-y)))
          (when (and (< t-near 1)
                     (< 0 t-far))
            (let ((normal (cond ((< t-near 0)
                                 (let ((dist (v- seg-pos aabb-pos)))
                                   (if (< (abs (vy2 dist)) (abs (vx2 dist)))
                                       (vec (signum (vx2 dist)) 0)
                                       (vec 0 (signum (vy2 dist))))))
                                ((< near-y near-x)
                                 (vec (- sign-x) 0))
                                (T
                                 (vec 0 (- sign-y))))))
              (unless (= 0 (v. normal seg-vel))
                ;; KLUDGE: This test is necessary in order to ignore vertical edges
                ;;         that seem to stick out of the blocks. I have no idea why.
                (unless (and (/= 0 (vy2 normal))
                             (<= (vx2 aabb-size) (abs (- (vx2 aabb-pos) (vx2 seg-pos)))))
                  (make-hit NIL
                            aabb-pos
                            t-near
                            normal))))))))))

(defun slope (pos vel size slope loc)
  (declare (type vec2 pos vel size loc))
  (declare (optimize speed))
  ;; We simplify our collision test to a single corner of the AABB. This point is shifted
  ;; towards the slope by the bsize to ensure we always test the closer edge. To make this
  ;; work with the corners of the slope, we allow an extra bias of 0.5 on the slope time.
  ;; We also add in an extra precise computation of the y position in order to know when
  ;; the box is already "within" the triangle to let the check pass despite negative ray
  ;; time.
  (when (<= (vy vel) 0)
    (let* ((la (v+ loc (slope-l slope)))
           (lb (v+ loc (slope-r slope)))
           (pos (vec (+ (vx pos)
                        (* (vx size) (signum (- (vy lb) (vy la)))))
                     (- (vy pos) (vy size))))
           (v1 (v- pos la))
           (v2 (v- lb la))
           (v3 (vec (- (vy vel)) (vx vel)))
           (dot (v. v2 v3)))
      (when (< 0.0001 (abs dot))
        (let* ((t1 (/ (- (* (vx v2) (vy v1)) (* (vy v2) (vx v1))) dot))
               (t2 (/ (v. v1 v3) dot))
               (xrel (+ 0.5 (/ (- (vx pos) (vx loc)) #.(float +tile-size+ 0f0))))
               (yrel (lerp (vy (slope-l slope)) (vy (slope-r slope)) (clamp 0.0 xrel 1.0))))
          (when (and (<= -0.5 t2 1.5)
                     (or (<= -1.0 t1 1.0)
                         (< (vy pos) (+ yrel (vy loc)))))
            t1))))))
