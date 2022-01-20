(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity moving-platform (game-entity resizable solid ephemeral)
  ((layer-index :initform (1+ +base-layer+))
   (last-tick :initform 0 :accessor last-tick)))

(defmethod collides-p ((platform moving-platform) thing hit) NIL)
(defmethod collides-p ((platform moving-platform) (block block) hit) T)
(defmethod collides-p ((platform moving-platform) (block death) hit) NIL)
(defmethod collides-p ((platform moving-platform) (solid solid) hit) T)

(defmethod trigger ((platform moving-platform) (thing game-entity) &key))

(defmethod handle :around ((ev tick) (platform moving-platform))
  (when (< (last-tick platform) (fc ev))
    (setf (last-tick platform) (fc ev))
    (call-next-method)))

(define-shader-entity tiled-platform (layer moving-platform)
  ((name :initform (generate-name "PLATFORM"))))

(defmethod layer-index ((platform tiled-platform)) +base-layer+)

(defmethod entity-at-point (point (tiled-platform tiled-platform))
  (or (call-next-method)
      (when (contained-p point tiled-platform)
        tiled-platform)))

(define-shader-entity falling-platform (tiled-platform creatable)
  ((size :initform (vec 2 5))
   (fall-timer :initform 0.75 :accessor fall-timer)
   (initial-location :initform (vec 0 0) :initarg :initial-location :accessor initial-location)
   (max-speed :initarg :max-speed :initform (vec 10.0 10.0) :accessor max-speed :type vec2)
   (fall-direction :initarg :fall-direction :initform (vec 0 -1) :accessor fall-direction :type vec2)))

(defmethod initargs append ((platform falling-platform))
  '(:fall-direction :max-speed))

(defmethod save-p ((platform falling-platform)) NIL)

(defmethod stage :after ((platform falling-platform) (area staging-area))
  (stage (// 'sound 'falling-platform-impact) area)
  (stage (// 'sound 'falling-platform-rattle) area))

(defmethod (setf location) :after (location (platform falling-platform))
  (setf (state platform) :normal)
  (vsetf (velocity platform) 0 0)
  (setf (fall-timer platform) 0.75)
  (setf (initial-location platform) (vcopy location)))

(defmethod trigger ((platform falling-platform) (thing game-entity) &key)
  (case (state platform)
    (:normal
     (setf (state platform) :falling))))

(defmethod (setf state) :after (state (platform falling-platform))
  (case state
    (:falling (harmony:play (// 'sound 'falling-platform-rattle) :reset T))
    (:blocked (harmony:play (// 'sound 'falling-platform-impact) :reset T))))

(defmethod oob ((platform falling-platform) (none null))
  (vsetf (velocity platform) 0 0)
  (decf (vy (location platform)) 64))

(defmethod handle ((ev switch-chunk) (platform falling-platform))
  (setf (location platform) (initial-location platform)))

(defmethod handle ((ev tick) (platform falling-platform))
  (ecase (state platform)
    (:blocked
     (vsetf (velocity platform) 0 0))
    (:normal
     (loop repeat 10 while (handle-collisions +world+ platform)))
    (:falling
     (when (< (decf (fall-timer platform) (dt ev)) 0.0)
       (nv+ (velocity platform) (v* (fall-direction platform) 10 (dt ev)))
       (nvclamp (v- (max-speed platform)) (velocity platform) (max-speed platform))
       (nv+ (frame-velocity platform) (velocity platform))
       (loop repeat 10 while (handle-collisions +world+ platform))))))

(defmethod collide ((platform falling-platform) (other falling-platform) hit)
  (when (and (eq :falling (state platform))
             (< 0 (vy (hit-normal hit))))
    (let ((vel (frame-velocity platform)))
      (shake-camera)
      (nv+ (location platform) (v* vel (hit-time hit)))
      (vsetf vel (vx (velocity other)) (vy (velocity other)))
      (if (eq :blocked (state other))
          (setf (state platform) :blocked)
          (setf (state other) :falling)))))

(defmethod collide ((platform falling-platform) (solid solid) hit)
  (when (eq :falling (state platform))
    (let ((vel (frame-velocity platform)))
      (shake-camera :intensity 5)
      (setf (state platform) :blocked)
      (nv+ (location platform) (v* vel (hit-time hit)))
      (vsetf vel 0 0))))

(defmethod collide ((platform falling-platform) (block block) hit)
  (when (eq :falling (state platform))
    (let ((vel (frame-velocity platform)))
      (shake-camera :intensity 5)
      (setf (state platform) :blocked)
      (nv+ (location platform) (v* vel (hit-time hit)))
      (vsetf vel 0 0))))

(defmethod apply-transforms :around ((platform falling-platform))
  (when (and (eql :falling (state platform))
             (< 0.0 (fall-timer platform)))
    (translate-by (random* 0 2.0) (random* 0 2.0) 0))
  (call-next-method))

(define-shader-entity elevator (lit-sprite moving-platform creatable)
  ((name :initform (generate-name "ELEVATOR"))
   (bsize :initform (vec 40 8))
   (size :initform (vec 80 32))
   (max-speed :initarg :max-speed :initform (vec 0.0 2.0) :accessor max-speed)
   (move-time :initform 1.0 :accessor move-time)
   (fit-to-bsize :initform NIL)
   (texture :initform (// 'kandria 'elevator))
   (target :initform NIL :accessor target)))

(defmethod stage :after ((elevator elevator) (area staging-area))
  (dolist (sound '(elevator-start elevator-stop elevator-move))
    (stage (// 'sound sound) area)))

(defmethod action ((elevator elevator)) 'interact)

(defmethod description ((elevator elevator))
  (language-string 'elevator))

(defmethod handle ((ev tick) (elevator elevator))
  (ecase (state elevator)
    (:normal
     (vsetf (max-speed elevator) 0 2)
     (vsetf (velocity elevator) 0 0))
    (:moving
     (incf (move-time elevator) (dt ev))
     (setf (harmony:location (// 'sound 'elevator-move)) (location elevator))
     (when (<= (move-time elevator) 1.0)
       (let* ((vel (velocity elevator))
              (dir (float-sign (vy vel))))
         (setf (vy vel) (* (clamp 0.0 (move-time elevator) 1.0)
                           (vy (max-speed elevator))
                           dir)))))
    (:should-stop
     (let ((found NIL))
       (scan (chunk elevator)
             (tvec (vx (location elevator))
                   (vy (location elevator))
                   (vx (bsize elevator))
                   (vy (bsize elevator)))
             (lambda (hit)
               (not (when (typep (hit-object hit) 'stopper)
                      (setf found T)))))
       (unless found
         (vsetf (velocity elevator) 0 0)
         (vsetf (frame-velocity elevator) 0 0)
         (nvalign (location elevator) 8)
         (setf (state elevator) :normal))))
    (:recall
     (let ((diff (- (vy (target elevator)) (+ (vy (location elevator)) (vy (bsize elevator))))))
       (cond ((<= (abs diff) (vy (velocity elevator)))
              (setf (vy (location elevator)) (- (vy (target elevator)) (vy (bsize elevator))))
              (setf (state elevator) :normal))
             (T
              (setf (vy (velocity elevator)) (* (vy (max-speed elevator)) (float-sign diff)))))))
    (:broken
     (vsetf (velocity elevator) 0 0)))
  (nv+ (frame-velocity elevator) (velocity elevator))
  (loop repeat 10 while (handle-collisions +world+ elevator)))

(defmethod collides-p ((elevator elevator) (solid platform) hit) NIL)

(defmethod collides-p ((elevator elevator) (solid stopper) hit)
  (when (<= 0.2 (+ (abs (vx (velocity elevator)))
                   (abs (vy (velocity elevator)))))
    (cond ((eql :recall (state elevator))
           NIL)
          ((< 0.0 (vy (velocity elevator)))
           T)
          (T
           (setf (state elevator) :should-stop)
           NIL))))

(defmethod collide :before ((player player) (elevator elevator) hit)
  (setf (interactable player) elevator))

(defmethod collide ((elevator elevator) (block block) hit)
  (let ((vel (frame-velocity elevator)))
    (setf (state elevator) :normal)
    (nv+ (location elevator) (v* vel (hit-time hit)))
    (vsetf vel 0 0)))

(defmethod (setf state) :before (state (elevator elevator))
  (case state
    ((:moving :recall)
     (unless (eq state (state elevator))
       (harmony:play (// 'sound 'elevator-start))
       (harmony:play (// 'sound 'elevator-move))))
    ((:normal :broken)
     (when (find (state elevator) '(:moving :recall :should-stop))
       (harmony:play (// 'sound 'elevator-stop))
       (harmony:stop (// 'sound 'elevator-move))))))

(defmethod interact ((elevator elevator) thing)
  (case (state elevator)
    (:normal
     (harmony:play (// 'sound 'elevator-start))
     (setf (state elevator) :moving)
     (let ((loc (location elevator))
           (bsize (bsize elevator)))
       (cond ((and (null (scan-collision +world+ (vec (vx loc) (+ (vy loc) (vy bsize) 1))))
                   (not (retained 'down)))
              (setf (vy (velocity elevator)) +0.01))
             ((and (null (scan-collision +world+ (vec (vx loc) (- (vy loc) (vy bsize) 1))))
                   (not (retained 'up)))
              (setf (vy (velocity elevator)) -0.01))))
     (setf (move-time elevator) 0.0))
    (:moving
     (setf (move-time elevator) 0.0)
     (setf (vy (velocity elevator)) (* -0.01 (float-sign (vy (velocity elevator))))))
    (:broken
     #++(harmony:play (// 'sound 'elevator-broken)))))

(define-shader-entity elevator-recall (lit-sprite interactable ephemeral creatable)
  ((target :initarg :target :initform NIL :accessor target :type symbol)
   (texture :initform (// 'kandria 'elevator-recall))
   (bsize :initform (vec 8 16))
   (size :initform (vec 16 32))))

(defmethod initargs append ((button elevator-recall))
  '(:target))

(defmethod interactable-p ((button elevator-recall))
  T)

(defmethod description ((button elevator-recall))
  (language-string 'recall-button))

(defmethod interact ((button elevator-recall) thing)
  (when (target button)
    ;; FIXME: sound
    (interact (unit (target button) +world+) button)))

(defmethod interact ((elevator elevator) (button elevator-recall))
  (case (state elevator)
    (:broken
     #++(harmony:play (// 'sound 'elevator-broken)))
    (T
     (setf (target elevator) (vec (vx (location button))
                                  (- (vy (location button))
                                     (vy (bsize button)))))
     (setf (state elevator) :recall))))

(define-shader-entity cycler-platform (lit-sprite moving-platform creatable)
  ((velocity :initform (vec 0 0.5))))

(defmethod handle ((ev tick) (cycler cycler-platform))
  (nv+ (frame-velocity cycler) (velocity cycler))
  (dotimes (i 10)
    (unless (handle-collisions +world+ cycler)
      (return))))

(defmethod collide ((cycler cycler-platform) (block block) hit)
  (let ((vel (velocity cycler)))
    (cond ((< 0 (vy vel)) (vsetf vel (vy vel) 0))
          ((< 0 (vx vel)) (vsetf vel 0 (- (vx vel))))
          ((< (vy vel) 0) (vsetf vel (vy vel) 0))
          ((< (vx vel) 0) (vsetf vel 0 (- (vx vel)))))
    (vsetf (frame-velocity cycler) 0 0)))
