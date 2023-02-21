(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity moving-platform (game-entity resizable solid ephemeral)
  ((layer-index :initform (1+ +base-layer+))))

(defmethod is-collider-for ((platform moving-platform) thing) NIL)
(defmethod is-collider-for ((platform moving-platform) (block block)) T)
(defmethod is-collider-for ((platform moving-platform) (block death)) NIL)
(defmethod is-collider-for ((platform moving-platform) (solid solid)) T)

(defmethod trigger ((platform moving-platform) (thing game-entity) &key))

(define-shader-entity tiled-platform (layer moving-platform)
  ((name :initform (generate-name "PLATFORM"))))

(defmethod layer-index ((platform tiled-platform)) +base-layer+)

(defmethod entity-at-point (point (tiled-platform tiled-platform))
  (or (call-next-method)
      (when (contained-p point tiled-platform)
        tiled-platform)))

(define-shader-entity falling-platform (shadow-caster tiled-platform creatable)
  ((size :initform (vec 2 5))
   (fall-timer :initform 0.9 :accessor fall-timer)
   (initial-location :initform (vec 0 0) :initarg :initial-location :accessor initial-location)
   (max-speed :initarg :max-speed :initform (vec 10.0 10.0) :accessor max-speed :type vec2
              :documentation "The maximum falling speed of the platform")
   (fall-direction :initarg :fall-direction :initform (vec 0 -1) :accessor fall-direction :type vec2
                   :documentation "The direction in which the platform falls
Can also set fractions to control the acceleration")))

(defmethod initargs append ((platform falling-platform))
  '(:fall-direction :max-speed))

(defmethod initialize-instance :after ((platform falling-platform) &key)
  (compute-shadow-geometry platform T))

(defmethod compute-shadow-geometry ((platform falling-platform) (vbo vertex-buffer))
  (let* ((size (bsize platform))
         (data (buffer-data vbo)))
    (setf (fill-pointer data) 0)
    (add-shadow-line vbo (vec (- (vx size)) (- (vy size))) (vec (+ (vx size)) (- (vy size))))
    (add-shadow-line vbo (vec (+ (vx size)) (- (vy size))) (vec (+ (vx size)) (+ (vy size))))
    (add-shadow-line vbo (vec (+ (vx size)) (+ (vy size))) (vec (- (vx size)) (+ (vy size))))
    (add-shadow-line vbo (vec (- (vx size)) (+ (vy size))) (vec (- (vx size)) (- (vy size))))))

(defmethod save-p ((platform falling-platform)) NIL)

(defmethod stage :after ((platform falling-platform) (area staging-area))
  (stage (// 'sound 'falling-platform-impact) area)
  (stage (// 'sound 'falling-platform-rattle) area))

(defmethod (setf location) :after (location (platform falling-platform))
  (setf (state platform) :normal)
  (vsetf (velocity platform) 0 0)
  (setf (fall-timer platform) 0.9)
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
  (quest:reset platform))

(defmethod quest:reset progn ((platform falling-platform) &rest args)
  (declare (ignore args))
  (setf (location platform) (initial-location platform)))

(defmethod handle ((ev tick) (platform falling-platform))
  (ecase (state platform)
    (:blocked
     (vsetf (velocity platform) 0 0))
    (:normal)
    (:falling
     (when (< (decf (fall-timer platform) (dt ev)) 0.0)
       (nv+ (velocity platform) (v* (fall-direction platform) 10 (dt ev)))
       (nvclamp (v- (max-speed platform)) (velocity platform) (max-speed platform))
       (nv+ (frame-velocity platform) (velocity platform))
       (perform-collision-tick platform (dt ev))))))

(defmethod collide ((platform falling-platform) (other falling-platform) hit)
  (when (eq :falling (state platform))
    (call-next-method)
    (if (eq :blocked (state other))
        (setf (state platform) :blocked)
        (setf (state platform) (setf (state other) :falling)))))

(defmethod collide ((platform falling-platform) (solid solid) hit)
  (when (eq :falling (state platform))
    (let ((vel (frame-velocity platform)))
      (shake-camera :intensity 5)
      (unless (typep solid 'falling-platform)
        (setf (state platform) :blocked))
      (call-next-method)
      (vsetf vel 0 0))))

(defmethod collide ((platform falling-platform) (block block) hit)
  (when (eq :falling (state platform))
    (let ((vel (frame-velocity platform)))
      (shake-camera :intensity 5)
      (setf (state platform) :blocked)
      (call-next-method)
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
   (bypass-stopper :initform (cons NIL NIL) :accessor bypass-stopper)
   (fit-to-bsize :initform NIL)
   (texture :initform (// 'kandria 'elevator))
   (target :initform NIL :accessor target)))

(defmethod stage :after ((elevator elevator) (area staging-area))
  (dolist (sound '(elevator-start elevator-stop elevator-move elevator-broken elevator-recall))
    (stage (// 'sound sound) area)))

(defmethod action ((elevator elevator)) 'interact)

(defmethod description ((elevator elevator))
  (case (elevator-direction elevator)
    (:up (@ move-elevator-upwards))
    (:down (@ move-elevator-downwards))
    (T (@ elevator))))

(defmethod handle ((ev tick) (elevator elevator))
  (ecase (state elevator)
    (:normal
     (vsetf (velocity elevator) 0 0))
    (:moving
     (if (null (cdr (bypass-stopper elevator)))
         (setf (car (bypass-stopper elevator)) NIL)
         (setf (cdr (bypass-stopper elevator)) NIL))
     (incf (move-time elevator) (dt ev))
     (ignore-errors ;; KLUDGE: too lazy to figure out the proper check here.
      (setf (harmony:location (// 'sound 'elevator-move)) (location elevator)))
     (when (<= (move-time elevator) 1.0)
       (let* ((vel (velocity elevator))
              (dir (float-sign (vy vel))))
         (setf (vy vel) (* (clamp 0.0 (move-time elevator) 1.0)
                           (vy (max-speed elevator))
                           dir)))))
    (:should-stop
     (incf (move-time elevator) (dt ev))
     (when (<= (move-time elevator) 1.0)
       (let* ((vel (velocity elevator))
              (dir (float-sign (vy vel))))
         (setf (vy vel) (* (clamp 0.0 (move-time elevator) 1.0)
                           (vy (max-speed elevator))
                           dir))))
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
              (vsetf (velocity elevator) 0 0)
              (setf (vy (location elevator)) (- (vy (target elevator)) (vy (bsize elevator))))
              (setf (state elevator) :normal))
             (T
              (setf (vy (velocity elevator)) (* (vy (max-speed elevator)) (float-sign diff)))))))
    (:broken
     (vsetf (velocity elevator) 0 0)))
  (nv+ (frame-velocity elevator) (velocity elevator))
  (when (v/= 0 (frame-velocity elevator))
    (perform-collision-tick elevator (dt ev))))

(defmethod is-collider-for ((elevator elevator) (solid platform)) NIL)

(defmethod collides-p ((elevator elevator) (solid stopper) hit)
  (cond ((eql :recall (state elevator))
         NIL)
        ((<= 0.0 (vy (velocity elevator)))
         (setf (cdr (bypass-stopper elevator)) solid)
         (null (car (bypass-stopper elevator))))
        (T
         (setf (state elevator) :should-stop)
         NIL)))

(defmethod collide :before ((player player) (elevator elevator) hit)
  (unless (interactable player)
    (setf (interactable player) elevator)))

(defmethod collide ((elevator elevator) (player player) hit))

(defmethod collide :after ((elevator elevator) (solid solid) hit)
  (setf (state elevator) :normal))

(defmethod collide :after ((elevator elevator) (block block) hit)
  (setf (state elevator) :normal))

(defmethod (setf state) :before (state (elevator elevator))
  (case state
    ((:moving :recall)
     (unless (eq state (state elevator))
       (setf (cdr (bypass-stopper elevator)) T)
       (setf (car (bypass-stopper elevator)) T)
       (harmony:play (// 'sound 'elevator-start) :location (location elevator))
       (harmony:play (// 'sound 'elevator-move))))
    (:normal
     (when (find (state elevator) '(:moving :recall :should-stop))
       (harmony:play (// 'sound 'elevator-stop) :location (location elevator))
       (harmony:stop (// 'sound 'elevator-move))))
    (:broken
     (when (find (state elevator) '(:moving :recall :should-stop))
       (harmony:play (// 'sound 'elevator-broken) :location (location elevator))
       (harmony:stop (// 'sound 'elevator-move))))))

(defun elevator-direction (elevator)
  (let ((loc (location elevator))
        (bsize (bsize elevator)))
    (case (state elevator)
      (:normal
       (cond ((and (null (scan-collision-for elevator +world+ (vec (vx loc) (+ (vy loc) (vy bsize) 1))))
                   (not (retained 'down)))
              :up)
             ((and (null (scan-collision-for elevator +world+ (vec (vx loc) (- (vy loc) (vy bsize) 1))))
                   (not (retained 'up)))
              :down)))
      ((:moving :recall)
       (cond ((< 0 (vy (velocity elevator)))
              :down)
             ((< (vy (velocity elevator)) 0)
              :up))))))

(defmethod interact ((elevator elevator) thing)
  (setf (vy (max-speed elevator)) 2.0)
  (case (state elevator)
    ((:normal :recall)
     (case (elevator-direction elevator)
       (:up (setf (vy (velocity elevator)) +0.01))
       (:down (setf (vy (velocity elevator)) -0.01)))
     (when (/= 0 (vy (velocity elevator)))
       (harmony:play (// 'sound 'elevator-start))
       (setf (state elevator) :moving)
       (setf (move-time elevator) 0.0)))
    (:moving
     (setf (move-time elevator) 0.0)
     (setf (vy (velocity elevator)) (* -0.01 (float-sign (vy (velocity elevator))))))
    (:broken
     (harmony:play (// 'sound 'elevator-broken) :location (location elevator)))))

(define-shader-entity elevator-recall (lit-sprite interactable ephemeral creatable)
  ((target :initarg :target :initform NIL :accessor target :type symbol
           :documentation "The name of the elevator to recall")
   (texture :initform (// 'kandria 'elevator-recall))
   (counter :initform (cons 0 0) :accessor counter)
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
    (harmony:play (// 'sound 'elevator-recall) :reset T)
    (let ((counter (counter button))
          (target (unit (target button) +world+)))
      (when (< 10 (- (get-universal-time) (car counter)))
        (setf (car counter) (get-universal-time))
        (setf (cdr counter) 0))
      (case (incf (cdr counter))
        (1
         (interact target button)
         (setf (vy (max-speed target)) 2.0))
        (5
         (setf (vy (max-speed target)) 5.0))
        (15
         (setf (state target) :broken))))))

(defmethod interact ((elevator elevator) (button elevator-recall))
  (setf (target elevator) (vec (vx (location button))
                               (- (vy (location button))
                                  (vy (bsize button)))))
  (setf (state elevator) :recall))

(define-shader-entity service-elevator (elevator creatable)
  ((texture :initform (// 'kandria 'service-elevator))
   (bsize :initform (vec 16 8))
   (size :initform (vec 32 32))
   (max-speed :initarg :max-speed :initform (vec 0.0 10.0) :accessor max-speed)))

(defmethod interact :after ((elevator service-elevator) thing)
  (setf (vy (max-speed elevator)) 10.0))
