(in-package #:org.shirakumo.fraf.leaf)

(define-action movement ())

(define-action dash (movement)
  (key-press (one-of key :left-shift))
  (gamepad-press (one-of button :x)))

(define-action start-jump (movement)
  (key-press (one-of key :space))
  (gamepad-press (one-of button :a)))

(define-action start-climb (movement)
  (key-press (one-of key :left-control))
  (gamepad-press (one-of button :r2 :l2)))

(define-action start-left (movement)
  (key-press (one-of key :a :left))
  (gamepad-move (one-of axis :l-h :dpad-h) (< pos -0.2 old-pos)))

(define-action start-right (movement)
  (key-press (one-of key :d :e :right))
  (gamepad-move (one-of axis :l-h :dpad-h) (< old-pos 0.2 pos)))

(define-action start-up (movement)
  (key-press (one-of key :w :\, :up))
  (gamepad-move (one-of axis :l-v :dpad-v) (< pos -0.2 old-pos)))

(define-action start-down (movement)
  (key-press (one-of key :s :o :down))
  (gamepad-move (one-of axis :l-v :dpad-v) (< old-pos 0.2 pos)))

(define-action end-jump (movement)
  (key-release (one-of key :space))
  (gamepad-release (one-of button :a)))

(define-action end-climb (movement)
  (key-release (one-of key :left-control))
  (gamepad-release (one-of button :r2 :l2)))

(define-action end-left (movement)
  (key-release (one-of key :a :left))
  (gamepad-move (one-of axis :l-h :dpad-h) (< old-pos -0.2 pos)))

(define-action end-right (movement)
  (key-release (one-of key :d :e :right))
  (gamepad-move (one-of axis :l-h :dpad-h) (< pos 0.2 old-pos)))

(define-action end-up (movement)
  (key-release (one-of key :w :\, :up))
  (gamepad-move (one-of axis :l-v :dpad-v) (< old-pos -0.2 pos)))

(define-action end-down (movement)
  (key-release (one-of key :s :o :down))
  (gamepad-move (one-of axis :l-v :dpad-v) (< pos 0.2 old-pos)))

(define-retention movement (ev)
  (typecase ev
    (start-jump (setf (retained 'movement :jump) T))
    (start-climb (setf (retained 'movement :climb) T))
    (start-left (setf (retained 'movement :left) T))
    (start-right (setf (retained 'movement :right) T))
    (start-up (setf (retained 'movement :up) T))
    (start-down (setf (retained 'movement :down) T))
    (end-jump (setf (retained 'movement :jump) NIL))
    (end-climb (setf (retained 'movement :climb) NIL))
    (end-left (setf (retained 'movement :left) NIL))
    (end-right (setf (retained 'movement :right) NIL))
    (end-up (setf (retained 'movement :up) NIL))
    (end-down (setf (retained 'movement :down) NIL))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defclass located-entity (entity)
    ((location :initarg :location :initform (vec 0 0) :accessor location))))

(defmethod paint :around ((obj located-entity) target)
  (with-pushed-matrix ()
    (translate (vxy_ (location obj)))
    (call-next-method)))

(define-subject moving (located-entity)
  ((velocity :initarg :velocity :accessor velocity)
   (collisions :initform (make-array 4 :element-type 'bit :initial-element 0) :reader collisions)
   (size :initarg :size :accessor size))
  (:default-initargs :velocity (vec 0 0)
                     :size (vec *default-tile-size* *default-tile-size*)))

(define-generic-handler (moving tick trial:tick))

(defmethod scan (entity size start dir))

(defun closer (a b dir)
  (< (abs (v. a dir)) (abs (v. b dir))))

(defmethod tick ((moving moving) ev)
  (let ((scene (scene (handler *context*)))
        (loc (location moving))
        (vel (velocity moving))
        (size (size moving)))
    ;; Scan for hits until we run out of velocity or hits.
    (fill (collisions moving) 0)
    (catch 'end-collisions
      (loop while (or (/= 0 (vx vel)) (/= 0 (vy vel)))
            for hit = (scan scene size loc vel)
            while hit
            do (collide moving (hit-object hit) hit)))
    ;; Remaining velocity (if any) can be added safely.
    (nv+ loc vel)
    ;; Point test for adjacent walls
    (let* ((surface (unit :surface scene))
           (l (tile (vec (- (vx loc) (/ (vx size) 2) 1) (vy loc)) surface))
           (r (tile (vec (+ (vx loc) (/ (vx size) 2) 1) (vy loc)) surface)))
      (when (and l (= 1 l))
        (setf (bit (collisions moving) 3) 1))
      (when (and r (= 1 r))
        (setf (bit (collisions moving) 1) 1)))
    ;; FIXME: make drawing pixel aligned.
    ;;(vsetf loc (round (vx loc)) (round (vy loc)))
    ))

(defmethod collide ((moving moving) (block block) hit)
  (let* ((loc (location moving))
         (vel (velocity moving))
         (pos (hit-location hit))
         (normal (hit-normal hit))
         (height (/ (vy (size moving)) 2))
         (t-s (/ (block-s block) 2))
         (collisions (collisions moving))
         (l (block-l block))
         (r (block-r block)))
    (cond ((= -1 (vy normal))
           (setf (bit collisions 0) 1))
          ((= -1 (vx normal))
           (setf (bit collisions 1) 1))
          ((= +1 (vy normal))
           (setf (bit collisions 2) 1))
          ((= +1 (vx normal))
           (setf (bit collisions 3) 1)))
    (cond ((= 0 l r)
           (nv+ loc (v* vel (hit-time hit)))
           (nv- vel (v* normal (v. vel normal)))
           ;; Zip out of ground in case of clipping
           (when (and (/= 0 (vy normal))
                      (< (vy pos) (vy loc))
                      (< (- (vy loc) height)
                         (+ (vy pos) t-s)))
             (setf (vy loc) (+ (vy pos) t-s height))))
          (T
           (nv+ loc vel)
           (let* ((tt (max 0 (min 1 (/ (- (vx loc) (- (vx pos) t-s)) (* 2 t-s)))))
                  (sy (+ (- (vy pos) t-s) height l (* (- r l) tt))))
             (when (< (vy loc) sy)
               (setf (vy loc) sy)
               (setf (vy vel) 0)
               ;; FIXME: not perfect slowdown, dashes are fucked up
               (setf (vx vel) (* 0.25 (vx vel)))))
           ;; Early out
           (throw 'end-collisions NIL)))))

(define-shader-subject player (vertex-entity colored-entity moving)
  ((vlim  :initform (vec 10 10) :accessor vlim)
   (vmove :initform (vec2 0.5 0.1) :accessor vmove)
   (vclim :initform (vec2 0.75 1.5) :accessor vclim)
   (vjump :initform (vec4 2 3.5 3 2) :accessor vjump)
   (vdash :initform (vec2 5 0.95) :accessor vdash)
   (jump-count :initform 0 :accessor jump-count)
   (dash-count :initform 0 :accessor dash-count))
  (:default-initargs
   :vertex-array (asset 'leaf 'player)
   :location (vec 32 32)
   :size (vec 8 16)
   :name :player))

(defun update-instance-initforms (class)
  (flet ((update (instance)
           (loop for slot in (c2mop:class-direct-slots class)
                 for name = (c2mop:slot-definition-name slot)
                 for init = (c2mop:slot-definition-initform slot)
                 when init do (setf (slot-value instance name) (eval init)))))
    (when (window :main NIL)
      (for:for ((entity over (scene (window :main))))
        (when (typep entity class)
          (update entity))))))

(define-handler (player dash) (ev)
  (let ((vel (velocity player))
        (vdash (vdash player)))
    (when (= 0 (dash-count player))
      (vsetf vel
             (cond ((retained 'movement :left)  -1)
                   ((retained 'movement :right) +1)
                   (T                            0))
             (cond ((retained 'movement :up)    +1)
                   ((retained 'movement :down)  -1)
                   (T                            0)))
      (when (v= 0 vel) (setf (vx vel) 1))
      (nv* vel (/ (vx vdash) (vlength vel)))
      (incf (dash-count player) 0.001))))

(define-handler (player start-jump) (ev)
  (let ((collisions (collisions player))
        (vel (velocity player))
        (vjump (vjump player)))
    (cond ((bitp collisions 2)
           ;; Ground jump
           (setf (vy vel) (vx vjump))
           (incf (jump-count player)))
          ((or (bitp collisions 1)
               (bitp collisions 3))
           ;; Wall jump
           (setf (vx vel) (* (if (bitp collisions 1) -1.0 1.0)
                             (vz vjump)))
           (setf (vy vel) (vw vjump))))))

(declaim (inline bitp))
(defun bitp (bitarr bit)
  (= 1 (bit bitarr bit)))

(defmethod tick :after ((player player) ev)
  (when (bitp (collisions player) 2)
    (setf (jump-count player) 0)
    (when (< 20 (dash-count player))
      (setf (dash-count player) 0))))

(defmethod tick :before ((player player) ev)
  (let ((collisions (collisions player))
        (vel (velocity player))
        (vlim  (vlim  player))
        (vmove (vmove player))
        (vclim (vclim player))
        (vjump (vjump player))
        (vdash (vdash player)))
    
    (setf (vy (color player)) 0)
    (setf (vz (color player)) (if (= 0 (dash-count player)) 1 0))
    ;; Movement
    (cond ((< 0 (dash-count player) 20)
           ;; Dash in progress
           (incf (dash-count player))
           (nv* vel (vy vdash))
           (setf (vy (color player)) 1))
          ((and (or (bitp collisions 1)
                    (bitp collisions 3))
                (retained 'movement :climb)
                (not (retained 'movement :jump)))
           ;; Climbing
           (cond ((retained 'movement :up)
                  (setf (vy vel) (vx vclim)))
                 ((retained 'movement :down)
                  (setf (vy vel) (* (vy vclim) -1)))
                 (T
                  (setf (vy vel) 0))))
          (T
           ;; Movement (air, ground)
           (cond ((retained 'movement :left)
                  (when (< (- (vx vmove)) (vx vel))
                    (decf (vx vel) (vx vmove))))
                 ((retained 'movement :right)
                  (when (< (vx vel) (vx vmove))
                    (incf (vx vel) (vx vmove)))))
           (cond ((<= (vx vel) (- (vy vmove)))
                   (incf (vx vel) (vy vmove)))
                  ((<= (vy vmove) (vx vel))
                   (decf (vx vel) (vy vmove)))
                  (T
                   (setf (vx vel) 0)))
           ;; Jump progress
           (when (< 0 (jump-count player))
             (when (and (retained 'movement :jump)
                        (= 15 (jump-count player)))
               (setf (vy vel) (* (vy vjump) (vy vel))))
             (incf (jump-count player)))
           ;; FIXME: Hard-coded gravity
           (decf (vy vel) 0.1)
           (nvclamp (v- vlim) vel vlim))))
  ;; OOB
  (when (< (vy (location player)) 0)
    (setf (vy (location player)) 128)
    (setf (vy (velocity player)) 0)))
