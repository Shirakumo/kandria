(in-package #:org.shirakumo.fraf.leaf)

(defun decline ()
  (invoke-restart 'decline))

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
  (l 0 :type (unsigned-byte 16))
  (r 0 :type (unsigned-byte 16)))

(defun make-surface-blocks (t-s slope-steps)
  (let ((blocks (make-array (+ 4 (* 2 (reduce #'+ slope-steps)))))
        (i -1))
    (flet ((make (c &rest args)
             (setf (aref blocks (incf i)) (apply (find-symbol (format NIL "MAKE-~a" c)) t-s args))))
      (make 'block)
      (make 'ground)
      (make 'platform)
      (make 'spike)
      (loop for steps in slope-steps
            do (loop for i from 0 below steps
                     for l = (* (/ i steps) *default-tile-size*)
                     for r = (* (/ (1+ i) steps) *default-tile-size*)
                     do (make 'slope (floor l) (floor r)))
            do (loop for i downfrom steps above 0
                     for l = (* (/ i steps) *default-tile-size*)
                     for r = (* (/ (1- i) steps) *default-tile-size*)
                     do (make 'slope (floor l) (floor r))))
      blocks)))

(defparameter *default-surface-blocks* (make-surface-blocks *default-tile-size* '(1 2 3)))

(define-shader-entity surface (layer)
  ((blocks :initarg :blocks :accessor blocks))
  (:default-initargs
   :texture (asset 'leaf 'surface)
   :name :surface
   :blocks *default-surface-blocks*))

(defmethod paint :around ((surface surface) target)
  (when (active-p (unit :editor T))
    (call-next-method)))

(define-class-shader (surface :fragment-shader -1)
  "out vec4 color;

void main(){
  if(color.a == 0){
    float r = (int(gl_FragCoord.x+0.5)%5==0)?1:0.5;
    r *= (int(gl_FragCoord.y+0.5)%5==0)?1:0.5;
    r *= 0.5;
    color = vec4(r,r,r,0.5);
  }else{
    color.a = 0.1;
  }
}")

(defstruct (hit (:constructor make-hit (object time location normal)))
  (object NIL)
  (time 0.0 :type single-float)
  (location NIL :type vec2)
  (normal NIL :type vec2))

(defun aabb (seg-pos seg-vel aabb-pos aabb-size)
  (declare (type vec2 seg-pos seg-vel aabb-pos aabb-size))
  (sb-int:with-float-traps-masked (:overflow :underflow :inexact)
    (let* ((scale (vec2 (if (= 0 (vx seg-vel)) most-positive-single-float (/ (vx seg-vel)))
                        (if (= 0 (vy seg-vel)) most-positive-single-float (/ (vy seg-vel)))))
           (sign (vec2 (float-sign (vx seg-vel)) (float-sign (vy seg-vel))))
           (near (v* (v- (v- aabb-pos (v* sign aabb-size)) seg-pos) scale))
           (far  (v* (v- (v+ aabb-pos (v* sign aabb-size)) seg-pos) scale)))
      (unless (or (< (vy far) (vx near))
                  (< (vx far) (vy near)))
        (let ((t-near (max (vx near) (vy near)))
              (t-far (min (vx far) (vy far))))
          (when (and (< t-near 1)
                     (< 0 t-far))
            (let* ((time (alexandria:clamp t-near 0.0 1.0))
                   (normal (if (< (vy near) (vx near))
                               (vec (- (vx sign)) 0)
                               (vec 0 (- (vy sign))))))
              (unless (= 0 (v. normal seg-vel))
                ;; KLUDGE: This test is necessary in order to ignore vertical edges
                ;;         that seem to stick out of the blocks. I have no idea why.
                (unless (and (/= 0 (vy normal))
                             (<= (vx aabb-size) (abs (- (vx aabb-pos) (vx seg-pos)))))
                  (make-hit NIL time aabb-pos normal))))))))))

(defun vsqrdist2 (a b)
  (declare (type vec2 a b))
  (declare (optimize speed))
  (+ (expt (- (vx2 a) (vx2 b)) 2)
     (expt (- (vy2 a) (vy2 b)) 2)))

(defmethod scan ((surface surface) (target vec2))
  (let ((tile (tile target surface)))
    (when (and tile (or (= tile 1) (= tile 2)))
      (aref (blocks surface) tile))))

(defmethod scan ((surface surface) (target game-entity))
  (let* ((t-s (tile-size surface))
         (x- 0) (y- 0) (x+ 0) (y+ 0)
         (size (v/ (v+ (bsize target) t-s) 2))
         (loc (location target))
         (vel (velocity target))
         (declined ()) (result))
    ;; Figure out bounding region
    (if (< 0 (vx vel))
        (setf x- (floor (- (vx loc) (vx size)) t-s)
              x+ (ceiling (+ (vx loc) (vx vel)) t-s))
        (setf x- (floor (- (+ (vx loc) (vx vel)) (vx size)) t-s)
              x+ (ceiling (vx loc) t-s)))
    (if (< 0 (vy vel))
        (setf y- (floor (- (vy loc) (vy size)) t-s)
              y+ (ceiling (+ (vy loc) (vy vel)) t-s))
        (setf y- (floor (- (+ (vy loc) (vy vel)) (vy size)) t-s)
              y+ (ceiling (vy loc) t-s)))
    ;; Sweep AABB through tiles
    (destructuring-bind (w h) (size surface)
      (loop
         (loop for x from (max 0 x-) to (min x+ (1- w))
               do (loop for y from (max 0 y-) to (min y+ (1- h))
                        for tile = (aref (tiles surface) (+ x (* y w)))
                        for hit = (when (/= 0 tile) (aabb loc vel (vec (+ (/ t-s 2) (* t-s x)) (+ (/ t-s 2) (* t-s y))) size))
                        do (when (and hit
                                      (not (find (hit-location hit) declined :test #'v=))
                                      (or (not result)
                                          (< (hit-time hit) (hit-time result))
                                          (and (= (hit-time hit) (hit-time result))
                                               (< (vsqrdist2 loc (hit-location hit))
                                                  (vsqrdist2 loc (hit-location result))))))
                             (setf (hit-object hit) (aref (blocks surface) tile))
                             (setf result hit))))
         (unless result (return))
         (restart-case
             (progn (collide target (hit-object result) result)
                    (return T))
           (decline ()
             :report "Decline handling the hit."
             (push (hit-location result) declined)
             (setf result NIL)))))))

(define-shader-subject moving-platform (vertex-entity game-entity)
  ()
  (:default-initargs :vertex-array (asset 'leaf 'player-mesh)))

(defmethod scan ((platform moving-platform) (target vec2))
  (let ((w (/ (vx (bsize platform)) 2))
        (h (/ (vy (bsize platform)) 2))
        (loc (location platform)))
    (when (and (< (- (vx loc) w) (vx target) (+ (vx loc) w))
               (< (- (vy loc) h) (vy target) (+ (vy loc) h)))
      platform)))

(defmethod scan ((platform moving-platform) (target game-entity))
  (let ((hit (aabb (location target) (v+ (velocity target) (velocity platform))
                   (location platform) (nv/ (v+ (size target) (bsize target)) 2))))
    (when hit
      (setf (hit-object hit) platform)
      (collide target platform hit))))

(defmethod tick ((platform moving-platform) ev)
  (let ((vel (velocity platform))
        (loc (location platform)))
    (nv+ loc vel)
    (setf (vx vel) (sin (tt ev)))))
