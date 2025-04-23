(in-package #:org.shirakumo.fraf.kandria)

(defstruct (block (:constructor make-block (s)))
  (s 0 :type (unsigned-byte 16)))

(defmethod is-collider-for ((entity game-entity) (block block)) T)

(defstruct (ground (:include block)
                   (:constructor make-ground (s))))

(defstruct (platform (:include block)
                     (:constructor make-platform (s))))

(defstruct (death (:include block)
                  (:constructor make-death (s))))

(defstruct (spike (:include death)
                  (:constructor make-spike (s normal)))
  (normal NIL :type vec2))

(defstruct (slope (:include block)
                  (:constructor make-slope (s l r)))
  (l NIL :type vec2)
  (r NIL :type vec2))

(defstruct (stopper (:include block)
                    (:constructor make-stopper (s))))

(defstruct (slipblock (:include ground)
                      (:constructor make-slipblock (s))))

(defun make-surface-blocks (t-s slope-steps)
  (let ((blocks ()))
    (flet ((make (c &rest args)
             (push (apply (find-symbol (format NIL "MAKE-~a" c)) t-s args) blocks)))
      (make 'block)
      (make 'ground)
      (make 'platform)
      (make 'death)
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
      (make 'spike (vec 0 +1))
      (make 'spike (vec +1 0))
      (make 'spike (vec 0 -1))
      (make 'spike (vec -1 0))
      (make 'slipblock)
      (make 'ground)
      (coerce (nreverse blocks) 'vector))))

(sb-ext:defglobal +surface-blocks+ NIL)
(declaim (type simple-vector +surface-blocks+))
(setf +surface-blocks+ (make-surface-blocks +tile-size+ '(1 2 3)))

(defmethod velocity ((block block))
  #.(vec2 0 0))

(defmethod bsize ((block block))
  #.(vec2 (/ +tile-size+ 2) (/ +tile-size+ 2)))

(defun aabb (seg-pos seg-vel aabb-pos aabb-size)
  (declare (type vec2 seg-pos seg-vel aabb-pos aabb-size))
  (declare (optimize speed))
  (let* ((scale-x (if (~= 0 (vx2 seg-vel) 0.00001) 1000000f0 (/ (vx2 seg-vel))))
         (scale-y (if (~= 0 (vy2 seg-vel) 0.00001) 1000000f0 (/ (vy2 seg-vel))))
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
                               (let ((dist (tv- seg-pos aabb-pos)))
                                 (if (< (abs (vy2 dist)) (abs (vx2 dist)))
                                     (tvec (signum (vx2 dist)) 0)
                                     (tvec 0 (signum (vy2 dist))))))
                              ((< near-y near-x)
                               (tvec (- sign-x) 0))
                              (T
                               (tvec 0 (- sign-y))))))
            (unless (= 0 (v. normal seg-vel))
              ;; KLUDGE: This test is necessary in order to ignore edges
              ;;         that seem to stick out of the blocks. I have no idea why.
              (unless (if (/= 0 (vy2 normal))
                          (<= (vx2 aabb-size) (abs (- (vx2 aabb-pos) (vx2 seg-pos))))
                          (<= (vy2 aabb-size) (abs (- (vy2 aabb-pos) (vy2 seg-pos)))))
                (make-hit NIL
                          aabb-pos
                          t-near
                          normal)))))))))
