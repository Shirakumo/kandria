(in-package #:org.shirakumo.fraf.leaf)

(define-action movement ())

(define-action dash (movement)
  (key-press (one-of key :left-shift))
  (gamepad-press (one-of button :x)))

(define-action start-jump (movement)
  (key-press (one-of key :space))
  (gamepad-press (one-of button :a)))

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
    (start-left (setf (retained 'movement :left) T))
    (start-right (setf (retained 'movement :right) T))
    (start-up (setf (retained 'movement :up) T))
    (start-down (setf (retained 'movement :down) T))
    (end-jump (setf (retained 'movement :jump) NIL))
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
    (catch 'a
      (loop while (or (/= 0 (vx vel)) (/= 0 (vy vel)))
            for hit = (scan scene size loc vel)
            while hit
            do (collide moving (hit-object hit) hit)))
    ;; Remaining velocity (if any) can be added safely.
    (nv+ loc vel)
    (vsetf loc (round (vx loc)) (round (vy loc)))))

(defmethod collide ((moving moving) (block block) hit)
  (let* ((loc (location moving))
         (vel (velocity moving))
         (pos (hit-location hit))
         (normal (hit-normal hit))
         (l (block-l block))
         (r (block-r block)))
    (cond ((= 0 l r)
           (nv+ loc (v* vel (hit-time hit)))
           (nv- vel (v* normal (v. vel normal))))
          (T
           (nv+ loc vel)
           (let* ((y (vy loc))
                  (t-s (block-s block))
                  (tt (max 0 (min 1 (/ (- (vx loc) (- (vx pos) (/ t-s 2))) t-s))))
                  (sy (+ (- (vy pos) (/ t-s 2)) (/ (vy (size moving)) 2) l (* (- r l) tt))))
             (when (< y sy)
               (setf (vy loc) sy)
               (setf (vy vel) 0)))
           (throw 'a NIL)))))

(define-shader-subject player (vertex-entity moving)
  ((vlim :initform (vec 1 10) :accessor vlim)
   (vacc :initform (vec 10 10) :accessor vacc)
   (vdcc :initform (vec 1 1) :accessor vdcc)
   (jmp-count :initform 0.0 :accessor jmp-count)
   (dash-count :initform 0.0 :accessor dash-count))
  (:default-initargs
   :vertex-array (asset 'leaf 'player)
   :location (vec 32 32)
   :size (vec 8 16)
   :name :player))

(define-handler (player dash) (ev)
  (let ((vel (velocity player)))
    (vsetf vel
           (cond ((retained 'movement :left)  -8)
                 ((retained 'movement :right) +8)
                 (T                            0))
           (cond ((retained 'movement :up)    +8)
                 ((retained 'movement :down)  -8)
                 (T                            0)))
    (incf (dash-count player) 0.001)))

(defmethod collide :after ((player player) (block block) hit)
  (when (/= 0 (vy (hit-normal hit)))
    (setf (jmp-count player) 0.0)
    (setf (dash-count player) 0.0)))

(defmethod tick :before ((player player) ev)
  (let ((vel (velocity player))
        (dt (coerce (dt ev) 'single-float))
        (vlim (vec2 1 10))
        (vacc (vec2 10 7))
        (vdcc (vec2 5 10)))
    (cond ((< 0 (dash-count player) 0.5)
           (incf (dash-count player) dt))
          (T
           (cond ((retained 'movement :left)
                  (when (< (- (vx vlim)) (vx vel))
                    (decf (vx vel) (* dt (vx vacc)))))
                 ((retained 'movement :right)
                  (when (< (vx vel) (vx vlim))
                    (incf (vx vel) (* dt (vx vacc)))))
                 ((< (vx vdcc) (abs (vx vel)))
                  (decf (vx vel) (* dt (signum (vx vel)) (vx vdcc))))
                 (T
                  (setf (vx vel) 0)))
           (cond ((and (< (jmp-count player) 0.2)
                       (or (retained 'movement :jump)
                           (< 0 (jmp-count player) 0.15)))
                  (incf (vy vel) (* dt (vy vacc)))
                  (incf (jmp-count player) dt))
                 (T
                  (decf (vy vel) (* dt (vy vdcc)))))))
    (nvclamp (v- vlim) vel vlim))
  ;; OOB
  (when (< (vy (location player)) 0)
    (setf (vy (location player)) 128)
    (setf (vy (velocity player)) 0)))
