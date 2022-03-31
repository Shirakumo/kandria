(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity bench (lit-sprite interactable ephemeral creatable)
  ((texture :initform (// 'kandria 'region2 'albedo))))

(defmethod interactable-p ((bench bench))
  (eql :normal (state (unit 'player +world+))))

(defmethod layer-index ((bench bench))
  (1- +base-layer+))

(defmethod description ((bench bench))
  (@ bench))

(defmethod interact ((bench bench) (player player))
  (setf (vx (location player)) (+ (vx (location bench))
                                  (* (direction player) 12)))
  (vsetf (velocity player) 0 0)
  (setf (intended-zoom (camera +world+)) 1.5)
  (let ((segment (harmony:segment :lowpass T)))
    (setf (mixed:frequency segment) 700))
  (start-animation 'sit-down player)
  (setf (state player) :sitting))

(define-shader-entity mirror (lit-animated-sprite interactable ephemeral creatable)
  ()
  (:default-initargs
   :sprite-data (asset 'kandria 'mirror)))

(defmethod interactable-p ((mirror mirror)) T)

(defmethod layer-index ((mirror mirror))
  (1- +base-layer+))

(defmethod description ((mirror mirror))
  (@ mirror))

(defmethod interact ((mirror mirror) (player player))
  (show-panel 'wardrobe))

(define-shader-entity workbench (lit-animated-sprite interactable ephemeral creatable)
  ()
  (:default-initargs
   :sprite-data (asset 'kandria 'workbench)))

(defmethod interactable-p ((workbench workbench)) T)

(defmethod stage :after ((workbench workbench) (area staging-area))
  (stage (// 'kandria 'sword) area)
  (stage (// 'sound 'ambience-interactable-shing) area))

(defmethod (setf frame-idx) :after (index (workbench workbench))
  (when (and (= 0 index)
             (in-view-p (location workbench) (bsize workbench))
             (not (find-panel 'dialog)))
    (harmony:play (// 'sound 'ambience-interactable-shing))))

(defmethod layer-index ((workbench workbench))
  (1- +base-layer+))

(defmethod description ((workbench workbench))
  (@ workbench))

(defmethod interact ((workbench workbench) (player player))
  (show-panel 'upgrade-ui))

(define-shader-entity ball (axis-rotated-entity moving vertex-entity textured-entity creatable)
  ((vertex-array :initform (// 'kandria '1x))
   (texture :initform (// 'kandria 'ball))
   (bsize :initform (vec 6 6))
   (axis :initform (vec 0 0 1))))

(defmethod apply-transforms progn ((ball ball))
  (let ((size (v* 2 (bsize ball))))
    (translate-by (/ (vx size) -2) (/ (vy size) -2) 0)
    (scale (vxy_ size))))

(defmethod collides-p ((player player) (ball ball) hit)
  (eql :dashing (state player)))

(defmethod collide ((player player) (ball ball) hit)
  (nv+ (velocity ball) (v* (velocity player) 0.8))
  (incf (vy (velocity ball)) 2.0)
  (vsetf (frame-velocity player) 0 0)
  (nv* (velocity player) 0.8))

(defmethod handle :before ((ev tick) (ball ball))
  (let* ((vel (velocity ball))
         (vlen (vlength vel)))
    (when (< 0 vlen)
      (decf (angle ball) (* 0.1 (vx vel)))
      (nv* vel (* (min vlen 10) (/ 0.99 vlen))))
    (nv+ vel (v* (gravity (medium ball)) (dt ev)))
    (nv+ (frame-velocity ball) vel)))

(defmethod collide ((ball ball) (block block) hit)
  (nv+ (location ball) (v* (frame-velocity ball) (hit-time hit)))
  (vsetf (frame-velocity ball) 0 0)
  (let ((vel (velocity ball))
        (normal (hit-normal hit))
        (loc (location ball)))
    (let ((ref (nv+ (v* 2 normal (v. normal (v- vel))) vel)))
      (vsetf vel
             (if (< (abs (vx ref)) 0.2) 0 (vx ref))
             (if (< (abs (vy ref)) 0.2) 0 (* 0.8 (vy ref)))))
    (nv+ loc (v* 0.1 normal))))

(defmethod collide :after ((ball ball) (block slope) hit)
  (let* ((loc (location ball))
         (normal (hit-normal hit))
         (xrel (/ (- (vx loc) (vx (hit-location hit))) +tile-size+)))
    (when (< (vx normal) 0) (incf xrel))
    ;; KLUDGE: we add a bias of 0.1 here to ensure we stop colliding with the slope.
    (let ((yrel (lerp (vy (slope-l block)) (vy (slope-r block)) (clamp 0f0 xrel 1f0))))
      (setf (vy loc) (+ 0.05 yrel (vy (bsize ball)) (vy (hit-location hit)))))))

(define-shader-entity balloon (game-entity lit-animated-sprite ephemeral creatable)
  ()
  (:default-initargs
   :sprite-data (asset 'kandria 'balloon)))

(defmethod (setf animations) :after (animations (balloon balloon))
  (setf (next-animation (find 'die (animations balloon) :key #'name)) 'revive)
  (setf (next-animation (find 'revive (animations balloon) :key #'name)) 'stand))

(defmethod collides-p ((player player) (balloon balloon) hit)
  (eql 'stand (name (animation balloon))))

(defmethod collide ((player player) (balloon balloon) hit)
  (kill balloon)
  (setf (vy (velocity player)) 4.0)
  (case (state player)
    (:dashing
     (setf (vx (velocity player)) (* 1.1 (vx (velocity player)))))))

(defmethod kill ((balloon balloon))
  (setf (animation balloon) 'die))

(defmethod apply-transforms progn ((baloon balloon))
  (translate-by 0 -16 0))

(define-shader-entity lantern-light (textured-light)
  ((bsize :initform #.(vec 48 48))
   (size :initform #.(vec 96 96))
   (offset :initform #.(vec 0 48))
   (location :initform NIL)))

(defmethod spawned-p ((light lantern-light)) T)

(define-shader-entity lantern (lit-animated-sprite solid collider ephemeral creatable)
  ((size :initform (vec 32 32))
   (bsize :initform (vec 16 16))
   (state :initform :active :accessor state :type symbol)
   (respawn-time :initform 0.0 :accessor respawn-time)
   (light :initform (make-instance 'lantern-light) :accessor light))
  (:default-initargs
   :sprite-data (asset 'kandria 'lantern)))

(defmethod layer-index ((lantern lantern)) (1- +base-layer+))

(defmethod velocity ((lantern lantern)) #.(vec 0 0))

(defmethod is-collider-for ((lantern lantern) thing) NIL)
(defmethod is-collider-for :around (thing (lantern lantern)) NIL)

(defmethod stage :after ((lantern lantern) (area staging-area))
  (stage (// 'sound 'lantern-crash) area)
  (stage (// 'sound 'lantern-restore) area))

(defmethod collides-p ((player player) (lantern lantern) hit)
  (and (dash-exhausted player)
       (eq :active (state lantern))))

(defmethod collide ((player player) (lantern lantern) hit)
  (harmony:play (// 'sound 'lantern-crash) :reset T)
  (setf (climb-strength player) (p! climb-strength))
  (setf (direction lantern) (direction player))
  (setf (dash-exhausted player) NIL)
  (setf (state lantern) :inactive)
  (setf (respawn-time lantern) 4.0)
  (setf (animation lantern) 'crash)
  (when (eql 'dash (buffer player))
    (handle (make-instance 'dash) player)))

(defmethod enter :after ((lantern lantern) container)
  (setf (slot-value (light lantern) 'location) (location lantern))
  (enter (light lantern) container))

(defmethod leave :after ((lantern lantern) (container container))
  (leave (light lantern) container))

(defmethod enter* :after ((lantern lantern) container)
  (compile-into-pass (light lantern) NIL (unit 'lighting-pass +world+)))

(defmethod leave* :after ((lantern lantern) (container container))
  (remove-from-pass (light lantern) (unit 'lighting-pass +world+)))

(defmethod (setf location) :after (loc (lantern lantern))
  (setf (slot-value (light lantern) 'location) (location lantern)))

(defmethod handle ((ev switch-chunk) (lantern lantern))
  (setf (state lantern) :active)
  (setf (animation lantern) 'active))

(defmethod handle :before ((ev tick) (lantern lantern))
  (case (state lantern)
    (:active
     (setf (multiplier (light lantern)) 1.0))
    (:inactive
     (setf (multiplier (light lantern)) 0.0)
     (when (<= (decf (respawn-time lantern) (dt ev)) 0.0)
       (harmony:play (// 'sound 'lantern-restore) :reset T)
       (setf (state lantern) :active)
       (setf (animation lantern) 'respawn)))))

(define-shader-entity spring (lit-animated-sprite solid collider ephemeral creatable)
  ((size :initform (vec 16 16))
   (bsize :initform (vec 8 8))
   (iframes :initform 0.0 :accessor iframes)
   (strength :initform (vec 0 7) :initarg :strength :accessor strength :type vec2))
  (:default-initargs
   :sprite-data (asset 'kandria 'spring)))

(defmethod initargs append ((spring spring))
  '(:strength))

(defmethod layer-index ((platform spring)) +base-layer+)
(defmethod is-collider-for (thing (spring spring)) NIL)
(defmethod collides-p ((moving moving) (spring spring) hit)
  (< 0.5 (iframes spring)))

(defmethod stage :after ((spring spring) (area staging-area))
  (stage (// 'sound 'spring-fire) area))

(defmethod velocity ((spring spring)) #.(vec 0 0))

(defmethod collide ((moving moving) (spring spring) hit)
  (let ((strength (strength spring)))
    (when (/= 0 (vx strength))
      (setf (direction moving) (float-sign (vx strength)))
      (setf (vx (velocity moving)) (vx strength)))
    (when (/= 0 (vy strength))
      (setf (vy (velocity moving)) (vy strength)))
    (setf (iframes spring) 0.0)
    (harmony:play (// 'sound 'spring-fire) :reset T)
    (setf (animation spring) 'spring)))

(defmethod collide :after ((player player) (spring spring) hit)
  (setf (climb-strength player) (p! climb-strength))
  (setf (dash-exhausted player) NIL)
  (setf (state player) :normal))

(defmethod handle :after ((ev tick) (spring spring))
  (incf (iframes spring) (dt ev)))

(defmethod (setf location) :before (loc (spring spring))
  (cond ((< (vx (strength spring)) 0)
         (decf (vx loc) 4))
        ((< (vy (strength spring)) 0)
         (decf (vy loc) 4))))

(defmethod bsize ((spring spring))
  (let ((strength (strength spring)))
    (if (/= 0 (vx strength))
        #.(vec 4 8)
        #.(vec 8 4))))

(defmethod apply-transforms progn ((spring spring))
  (let ((strength (strength spring)))
    (cond ((< 0 (vx2 strength))
           (rotate-by 0 0 1 (/ PI -2))
           (translate-by -8 -4 0))
          ((> 0 (vx2 strength))
           (rotate-by 0 0 1 (/ PI +2))
           (translate-by +8 -4 0))
          ((< 0 (vy2 strength)))
          ((> 0 (vy2 strength))
           (rotate-by 0 0 1 PI)
           (translate-by 0 -8 0)))))

(define-shader-entity fountain (lit-animated-sprite solid collider ephemeral creatable)
  ((size :initform (vec 32 64))
   (bsize :initform (vec 16 32))
   (timer :initform 0.0 :accessor timer)
   (iframes :initform 0 :accessor iframes)
   (strength :initform (vec 0 7) :initarg :strength :accessor strength :type vec2))
  (:default-initargs :sprite-data (asset 'kandria 'fountain)))

(defmethod initargs append ((fountain fountain))
  '(:strength))

(defmethod active-p ((fountain fountain))
  (and (<= 0.05 (timer fountain) 0.4)
       (= 0 (iframes fountain))))

(defmethod is-collider-for (thing (fountain fountain)) NIL)
(defmethod is-collider-for ((moving moving) (fountain fountain))
  (active-p fountain))

(defmethod layer-index ((fountain fountain))
  +base-layer+)

(defmethod bsize ((fountain fountain))
  (let ((strength (strength fountain)))
    (if (/= 0 (vx strength))
        #.(vec 32 16)
        #.(vec 16 32))))

(defmethod velocity ((fountain fountain))
  #.(vec 0 0))

(defmethod stage :after ((fountain fountain) (area staging-area))
  (stage (// 'sound 'fountain-blip-001) area)
  (stage (// 'sound 'fountain-blip-002) area)
  (stage (// 'sound 'fountain-blip-003) area)
  (stage (// 'sound 'fountain-fire) area))

(defmethod collide ((moving moving) (fountain fountain) hit)
  (let ((strength (strength fountain)))
    (when (/= 0 (vx strength))
      (setf (direction moving) (float-sign (vx strength)))
      (setf (vx (velocity moving)) (vx strength)))
    (when (/= 0 (vy strength))
      (setf (vy (velocity moving)) (vy strength)))
    (incf (iframes fountain))
    (setf (svref (collisions moving) 2) NIL)))

(defmethod collide :after ((player player) (fountain fountain) hit)
  (setf (climb-strength player) (p! climb-strength))
  (setf (dash-exhausted player) NIL)
  (setf (state player) :normal))

(defmethod handle :after ((ev tick) (fountain fountain))
  (when (<= 4.0 (incf (timer fountain) (dt ev)))
    (setf (timer fountain) 0.0)
    (setf (iframes fountain) 0)
    ;; FIXME: only play when visible...
    ;;(harmony:play (// 'sound 'fountain-fire) :reset T)
    (setf (animation fountain) 'fire)))

(defmethod handle ((ev switch-chunk) (fountain fountain))
  (setf (timer fountain) 0.0)
  (setf (iframes fountain) 0)
  (setf (animation fountain) 'fire))

(defmethod apply-transforms progn ((fountain fountain))
  (let ((strength (strength fountain)))
    (cond ((< 0 (vx2 strength))
           (rotate-by 0 0 1 (/ PI -2))
           (translate-by -16 -32 0))
          ((> 0 (vx2 strength))
           (rotate-by 0 0 1 (/ PI +2))
           (translate-by +16 -32 0))
          ((< 0 (vy2 strength)))
          ((> 0 (vy2 strength))
           (rotate-by 0 0 1 PI)
           (translate-by 0 -64 0)))))

;; KLUDGE: the standard AABB-based test fucks up on zero velocity.
;;         if I make it not fuck up on that, other things break all over.
;;         I don't have time for this.
(defmethod scan ((entity fountain) (target game-entity) on-hit)
  (let ((vec (load-time-value (vec4 0 0 0 0)))
        (loc (location target))
        (bsize (bsize target)))
    (vsetf vec (vx2 loc) (vy2 loc) (vx2 bsize) (vy2 bsize))
    (scan entity vec on-hit)))

(define-shader-entity crumbling-platform (lit-animated-sprite collider ephemeral solid creatable)
  ((bsize :initform (vec 24 4))
   (size :initform (vec 48 32))
   (state :initform :active :accessor state)
   (respawn-time :initform 0.0 :accessor respawn-time))
  (:default-initargs
   :sprite-data (asset 'kandria 'crumbling-platform)))

(defmethod layer-index ((platform crumbling-platform)) +base-layer+)

(defmethod apply-transforms progn ((platform crumbling-platform))
  (translate-by 0 -24 0))

(defmethod handle :after ((ev tick) (platform crumbling-platform))
  (ecase (state platform)
    (:active)
    (:inactive
     (when (<= (decf (respawn-time platform) (dt ev)) 0.0)
       (unless (eql (name (animation platform)) 'restore)
         (harmony:play (// 'sound 'crumbling-platform-restore) :reset T)
         (setf (animation platform) 'restore))))))

(defmethod handle ((ev switch-chunk) (platform crumbling-platform))
  (setf (state platform) :active)
  (setf (animation platform) 'active))

(defmethod velocity ((platform crumbling-platform))
  #.(vec 0 0))

(defmethod stage :after ((platform crumbling-platform) (area staging-area))
  (stage (// 'sound 'crumbling-platform-crumble) area)
  (stage (// 'sound 'crumbling-platform-restore) area))

(defmethod switch-animation :after ((platform crumbling-platform) (animation symbol))
  (case animation
    (inactive
     (setf (state platform) :inactive)
     (setf (respawn-time platform) 4.0))
    (active
     (setf (state platform) :active))))

(defmethod is-collider-for ((moving moving) (platform crumbling-platform))
  (eql :active (state platform)))

(defmethod collides-p ((moving moving) (platform crumbling-platform) hit)
  (and (is-collider-for moving platform)
       (< 0 (vy (hit-normal hit)))
       (<= (vy (velocity moving)) 0)
       (<= (+ (vy (hit-location hit)) (vy (bsize platform)) -2)
           (- (vy (location moving)) (vy (bsize moving))))))

(defmethod collide ((moving moving) (platform crumbling-platform) hit)
  (let* ((loc (location moving))
         (pos (hit-location hit))
         (height (vy (bsize moving)))
         (t-s (vy (bsize platform))))
    (harmony:play (// 'sound 'crumbling-platform-crumble))
    (setf (animation platform) 'crumble)
    (setf (svref (collisions moving) 2) platform)
    ;; Force clamp velocity to zero to avoid "speeding up while on ground"
    (setf (vy (velocity moving)) (max 0 (vy (velocity moving))))
    ;; Zip
    (when (< (- (vy loc) height)
             (+ (vy pos) t-s))
      (setf (vy loc) (+ (vy pos) t-s height)))))

(define-shader-entity hider (layer trigger creatable)
  ((size :initform (vec 5 5))
   (visibility :type single-float)
   (name :initform (generate-name "HIDER"))))

(defmethod velocity ((hider hider))
  #.(vec 0 0))

(defmethod layer-index ((hider hider))
  (1+ +base-layer+))

(defmethod stage :after ((hider hider) (area staging-area))
  (stage (// 'sound 'hider-reveal) area))

(defmethod interact ((hider hider) source)
  (when (active-p hider)
    (let ((visibility (decf (visibility hider) 0.02)))
      (cond ((= 0.98 visibility)
             (harmony:play (// 'sound 'hider-reveal)))
            ((<= visibility 0.0)
             (setf (visibility hider) 0.0)
             (setf (active-p hider) NIL))))))

(defmethod (setf active-p) :after (value (hider hider))
  (setf (visibility hider) (if value 1.0 0.0)))

(define-shader-entity blocker (layer solid ephemeral collider creatable)
  ((size :initform (vec 5 5))
   (visibility :type single-float)
   (name :initform (generate-name "BLOCKER"))
   (weak-side :initarg :weak-side :initform :west :accessor weak-side
              :type (member :north :east :south :west :any))))

(defmethod velocity ((blocker blocker))
  #.(vec 0 0))

(defmethod layer-index ((blocker blocker))
  (1+ +base-layer+))

(defmethod quest:active-p ((blocker blocker))
  (<= 1.0 (visibility blocker)))

(defmethod stage :after ((blocker blocker) (area staging-area))
  (stage (// 'sound 'blocker-destroy) area))

(defmethod is-collider-for ((moving moving) (blocker blocker))
  (quest:active-p blocker))

(defmethod collide ((player player) (blocker blocker) hit)
  (cond ((and (or (eql :dashing (state player))
                  (and (< 3.0 (vlength (velocity player)))
                       (< 0.0 (dash-time player))))
              (ecase (weak-side blocker)
                (:north (< (vy (velocity player)) 0))
                (:east  (< (vx (velocity player)) 0))
                (:south (< 0 (vy (velocity player))))
                (:west  (< 0 (vx (velocity player))))
                (:any T)))
         (harmony:play (// 'sound 'blocker-destroy) :reset T)
         (setf (visibility blocker) 0.99)
         (nv* (nvunit (velocity player))  -5)
         (nv* (frame-velocity player) -1)
         (incf (vy (velocity player)) 4.0))
        (T
         (call-next-method))))

(defmethod entity-at-point (point (blocker blocker))
  (or (call-next-method)
      (when (contained-p point blocker)
        blocker)))

(defmethod render :before ((blocker blocker) (program shader-program))
  (when (< 0.0 (visibility blocker) 1.0)
    (setf (visibility blocker) (max 0.0 (- (visibility blocker) 0.01)))))

(define-shader-entity chest (interactable-animated-sprite ephemeral creatable)
  ((name :initform (generate-name "CHEST"))
   (bsize :initform (vec 8 8))
   (item :initform NIL :initarg :item :accessor item :type symbol)
   (state :initform :closed :initarg :state :accessor state :type (member :open :closed)))
  (:default-initargs
   :sprite-data (asset 'kandria 'chest)))

(defmethod layer-index ((chest chest))
  +base-layer+)

(defmethod description ((chest chest))
  (language-string 'chest))

(defmethod interactable-p ((chest chest))
  (eql :closed (state chest)))

(defmethod stage :after ((chest chest) (area staging-area))
  (stage (// 'sound 'chest-open) area))

(defmethod draw-item ((chest chest))
  (let ((drawer (random-drawer (item chest))))
    (if drawer
        (funcall drawer)
        (item chest))))

(defmethod (setf state) :after (state (chest chest))
  (when (< 0 (length (animations chest)))
    (ecase state
      (:open (setf (animation chest) 'activate))
      (:closed (setf (animation chest) 'closed)))))

(defmethod interact ((chest chest) (player player))
  (when (eql :closed (state chest))
    (harmony:play (// 'sound 'chest-open) :reset T)
    (spawn (location chest) (or (draw-item chest) 'item:parts))
    (setf (state chest) :open)
    (start-animation 'pickup player)))

(define-shader-entity shutter (lit-animated-sprite collider solid ephemeral)
  ((name :initform NIL)
   (bsize :initform (vec 24 40))
   (state :initform :open :initarg :state :accessor state :type (member :open :closed)))
  (:default-initargs
   :sprite-data (asset 'kandria 'shutter)))

(defmethod layer-index ((shutter shutter))
  (1+ +base-layer+))

(defmethod velocity ((shutter shutter)) #.(vec 0 0))

(defmethod stage :after ((shutter shutter) (area staging-area))
  (stage (// 'sound 'shutter-close) area)
  (stage (// 'sound 'shutter-open) area))

(defmethod (setf state) :before (state (shutter shutter))
  (unless (eq state (state shutter))
    (when (< 0 (length (animations shutter)))
      (ecase state
        (:open
         (harmony:play (// 'sound 'shutter-open))
         (setf (animation shutter) 'opening))
        (:closed
         (harmony:play (// 'sound 'shutter-close))
         (setf (animation shutter) 'closing))))))

(defmethod is-collider-for ((moving moving) (shutter shutter))
  (eql :closed (state shutter)))

(defmethod collides-p ((moving moving) (shutter shutter) hit)
  (and (eql :closed (state shutter))
       (call-next-method)))

(defmethod spawned-p ((shutter shutter)) T)

(define-shader-entity switch (lit-animated-sprite solid collider ephemeral creatable)
  ((name :initform NIL)
   (bsize :initform (vec 8 8))
   (state :initform :off :initarg :state :accessor state :type (member :off :on)))
  (:default-initargs
   :sprite-data (asset 'kandria 'switch)))

(defmethod layer-index ((switch switch))
  (1- +base-layer+))

(defmethod quest:active-p ((switch switch))
  (eql :on (state switch)))

(defmethod stage :after ((switch switch) (area staging-area))
  (stage (// 'sound 'key-activate) area))

(defmethod (setf state) :before (state (switch switch))
  (unless (eq state (state switch))
    (when (< 0 (length (animations switch)))
      (ecase state
        (:on
         (harmony:play (// 'sound 'key-activate) :reset T)
         (setf (animation switch) 'activate))
        (:off (setf (animation switch) 'off))))))

(defmethod handle :after ((ev tick) (switch switch))
  (when (and (eql 'off (name (animation switch)))
             (eql :on (state switch)))
    (setf (animation switch) 'on)))

(defmethod is-collider-for :around (thing (switch switch)) NIL)

(defmethod collides-p ((moving moving) (switch switch) hit)
  (setf (state switch) :on)
  NIL)

(defmethod spawned-p ((switch switch)) T)

(define-shader-entity gate (parent-entity tiled-platform creatable)
  ((name :initform (generate-name "GATE"))
   (size :initform (vec 1 5))
   (state :initform :closed :type (member :closed :open :opening :closing))
   (open-location :initform (vec 0 0) :initarg :open-location :accessor open-location :type vec2)
   (closed-location :initform (vec 0 0) :initarg :closed-location :accessor closed-location :type vec2)))

(defmethod initargs append ((gate gate))
  '(:size :child-count))

(defmethod initialize-instance :after ((gate gate) &key)
  (when (v= 0 (open-location gate))
    (v<- (open-location gate) (location gate)))
  (when (v= 0 (closed-location gate))
    (v<- (closed-location gate) (location gate))))

(defmethod make-child-entity ((gate gate))
  (make-instance 'switch :location (vcopy (location gate))))

(defmethod stage :after ((gate gate) (area staging-area))
  (stage (// 'sound 'gate-lift) area)
  (stage (// 'sound 'key-complete) area))

(defmethod quest:active-p ((gate gate))
  (eql :open (state gate)))

(defmethod quest:activate ((gate gate))
  (dolist (switch (children gate))
    (setf (state switch) :on)))

(defmethod (setf location) :after (location (gate gate))
  (case (state gate)
    (:open (v<- (open-location gate) location))
    (:closed (v<- (closed-location gate) location))))

(defmethod (setf state) :after (state (gate gate))
  (case state
    (:open
     (dolist (switch (children gate))
       (setf (state switch) :on))
     (v<- (location gate) (open-location gate)))
    (:closed
     (dolist (switch (children gate))
       (setf (state switch) :off))
     (v<- (location gate) (closed-location gate)))))

(defmethod handle ((ev tick) (gate gate))
  (flet ((reached (source target)
           (let ((dir (v- target source)))
             (<= 1.0
                 (/ (v. (v- (location gate) source) dir)
                    (max 0.001 (vsqrlength dir)))))))
    (ecase (state gate)
      (:closed
       (vsetf (velocity gate) 0 0)
       (when (loop for switch in (children gate)
                   always (eql :on (state switch)))
         (harmony:play (// 'sound 'gate-lift) :reset T)
         (harmony:play (// 'sound 'key-complete) :reset T)
         (setf (state gate) :opening)))
      (:open
       (vsetf (velocity gate) 0 0)
       (when (loop for switch in (children gate)
                   thereis (eql :off (state switch)))
         (setf (state gate) :closing)))
      (:opening
       (cond ((reached (closed-location gate) (open-location gate))
              (vsetf (velocity gate) 0 0)
              (setf (state gate) :open))
             ((< (vsqrlength (velocity gate)) 2.0)
              (let ((dir (nvunit (v- (open-location gate) (location gate)))))
                (nv+ (velocity gate) (v* dir (dt ev))))))
       (nv+ (frame-velocity gate) (velocity gate)))
      (:closing
       (cond ((reached (open-location gate) (closed-location gate))
              (vsetf (velocity gate) 0 0)
              (setf (state gate) :closed))
             ((< (vsqrlength (velocity gate)) 2.0)
              (let ((dir (nvunit (v- (closed-location gate) (location gate)))))
                (nv+ (velocity gate) (v* dir (dt ev))))))
       (nv+ (frame-velocity gate) (velocity gate))))))

(defmethod handle ((ev switch-chunk) (gate gate))
  (setf (state gate) (state gate)))

(define-shader-entity demo-blocker (lit-animated-sprite solid ephemeral collider creatable)
  ((bsize :initform (vec 40 64))
   (name :initform NIL)
   (cooldown :initform 0.0 :accessor cooldown))
  (:default-initargs :sprite-data (asset 'kandria 'demo-blocker)))

(defmethod velocity ((blocker demo-blocker))
  #.(vec 0 0))

(defmethod layer-index ((blocker demo-blocker))
  (1+ +base-layer+))

(defmethod is-collider-for ((player player) (blocker demo-blocker))
  #-kandria-demo NIL
  #+kandria-demo T)

(defmethod collide :after ((player player) (blocker demo-blocker) hit)
  (setf (slot-value blocker 'animation) (aref (animations blocker) 1))
  (setf (cooldown blocker) 1.0))

(defmethod handle :after ((ev tick) (blocker demo-blocker))
  (when (< 0.0 (cooldown blocker))
    (when (< (decf (cooldown blocker) (dt ev)) 0.0)
      (setf (slot-value blocker 'animation) (aref (animations blocker) 0)))))
