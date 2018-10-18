(in-package #:org.shirakumo.fraf.leaf)

(define-action movement ())

(define-action jump (movement)
  (key-press (one-of key :space))
  (gamepad-press (one-of button :x :a)))

(define-action start-left (movement)
  (key-press (one-of key :a :left))
  (gamepad-move (eql axis :left-h) (< pos -0.2 old-pos)))

(define-action start-right (movement)
  (key-press (one-of key :d :e :right))
  (gamepad-move (eql axis :left-h) (< old-pos 0.2 pos)))

(define-action start-up (movement)
  (key-press (one-of key :w :\, :up))
  (gamepad-move (eql axis :left-v) (< pos -0.2 old-pos)))

(define-action start-down (movement)
  (key-press (one-of key :s :o :down))
  (gamepad-move (eql axis :left-v) (< old-pos 0.2 pos)))

(define-action end-left (movement)
  (key-release (one-of key :a :left))
  (gamepad-move (eql axis :left-h) (< old-pos -0.2 pos)))

(define-action end-right (movement)
  (key-release (one-of key :d :e :right))
  (gamepad-move (eql axis :left-h) (< pos 0.2 old-pos)))

(define-action end-up (movement)
  (key-release (one-of key :w :\, :up))
  (gamepad-move (eql axis :left-v) (< old-pos -0.2 pos)))

(define-action end-down (movement)
  (key-release (one-of key :s :o :down))
  (gamepad-move (eql axis :left-v) (< pos 0.2 old-pos)))

(define-retention movement (ev)
  (typecase ev
    (start-left (setf (retained 'movement :left) T))
    (start-right (setf (retained 'movement :right) T))
    (start-up (setf (retained 'movement :up) T))
    (start-down (setf (retained 'movement :down) T))
    (end-left (setf (retained 'movement :left) NIL))
    (end-right (setf (retained 'movement :right) NIL))
    (end-up (setf (retained 'movement :up) NIL))
    (end-down (setf (retained 'movement :down) NIL))))

(define-subject moving (located-entity)
  ((velocity :initarg :velocity :accessor velocity)
   (size :initarg :size :accessor size))
  (:default-initargs :velocity (vec 0 0 0)
                     :size (vec *default-tile-size* *default-tile-size*)))

(define-generic-handler (moving tick trial:tick))

(defmethod scan (entity start dir))

(defun closer (a b dir)
  (< (abs (v. a dir)) (abs (v. b dir))))

(defmethod tick ((moving moving) ev)
  (let ((scene (handler *context*))
        (loc (location moving))
        (vel (velocity moving))
        (size (size moving)))
    ;; Step X
    (cond ((< 0 (vx vel))
           (let ((hit (scan scene (nv+ (nv/ (vx__ size) 2) loc) vel)))
             (when hit
               (setf (vx vel) 0)
               (setf (vx loc) (vx (- (vx (first hit)) (/ (vx size) 2)))))))
          ((< (vx vel) 0)
           (let ((hit (scan scene (nv+ (nv/ (vx__ size) -2) loc) vel)))
             (when hit
               (setf (vx vel) 0)
               (setf (vx loc) (vx (+ (vx (first hit)) (/ (vx size) 2))))))))
    (incf (vx loc) (vx vel))
    ;; Step Y
    (cond ((< 0 (vy vel)))
          ((< (vy vel) 0)))))

(define-shader-subject player (vertex-entity moving)
  ()
  (:default-initargs
   :vertex-array (asset 'leaf 'player)
   :location (vec 32 32 0)
   :name :player))

(defmethod tick :before ((player player) ev)
  (cond ((retained 'movement :left)
         (setf (vx (velocity player)) -2))
        ((retained 'movement :right)
         (setf (vx (velocity player)) +2))
        (T
         (setf (vx (velocity player))  0))))
