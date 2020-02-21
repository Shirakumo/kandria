(in-package #:org.shirakumo.fraf.leaf)

(define-asset (leaf player-mesh) mesh
    (make-rectangle 64 50))

;;                          Gravity pulling down
(define-global +vgrav+ 0.15)
;;                          How many frames to stay "grounded"
(define-global +coyote+ 0.08)
;;                          Hard velocity caps
(define-global +vlim+  (vec 10      10))
;;                          GRD-ACC AIR-DCC AIR-ACC GRD-LIM
(define-global +vmove+ (vec 0.1     0.97    0.08    1.9))
;;                          CLIMB   DOWN    SLIDE
(define-global +vclim+ (vec 0.8     1.5     -1.2))
;;                          CRAWL
(define-global +vcraw+ (vec 0.5     0.0))
;;                          JUMP    LONGJMP WALL-VX WALL-VY
(define-global +vjump+ (vec 2.5     1.1     2.75     2.5))
;;                          ACC     DCC
(define-global +vdash+ (vec 10      0.7))

(define-shader-subject player (movable lit-animated-sprite)
  ((spawn-location :initform (vec2 0 0) :accessor spawn-location)
   (prompt :initform (make-instance 'prompt :text :y :size 16 :color (vec 1 1 1 1)) :accessor prompt)
   (interactable :initform NIL :accessor interactable)
   (vertex-array :initform (asset 'leaf 'player-mesh))
   (jump-time :initform 1.0d0 :accessor jump-time)
   (dash-time :initform 1.0d0 :accessor dash-time)
   (air-time :initform 1.0d0 :accessor air-time)
   (stun-time :initform 1.0d0 :accessor stun-time)
   (surface :initform NIL :accessor surface))
  (:default-initargs
   :name 'player
   :bsize (nv/ (vec 16 32) 2)
   :size (vec 64 50)
   :texture (asset 'world 'player)
   :animations "player-animations.lisp"))

(defmethod initialize-instance :after ((player player) &key)
  (setf (spawn-location player) (vcopy (location player))))

(defmethod resize ((player player) w h))

(define-class-shader (player :vertex-shader)
  "layout (location = 0) in vec3 vertex;
out vec2 world_pos;
uniform mat4 model_matrix;

void main(){
  world_pos = (model_matrix * vec4(vertex, 1)).xy;
}")

(define-handler (player interact) (ev)
  (when (interactable player)
    (issue +world+ 'interaction :with (interactable player))))

(define-handler (player dash) (ev)
  (let ((acc (acceleration player)))
    (when (and (= 0 (dash-time player))
               (eq :normal (state player)))
      (if (typep (trial::source-event ev) 'gamepad-event)
          (let ((dev (device (trial::source-event ev))))
            (vsetf acc
                   (absinvclamp 0.3 (gamepad:axis :l-h dev) 0.8)
                   (absinvclamp 0.3 (gamepad:axis :l-v dev) 0.8)))
          (vsetf acc
                 (cond ((retained 'movement :left)  -1)
                       ((retained 'movement :right) +1)
                       (T                            0))
                 (cond ((retained 'movement :up)    +1)
                       ((retained 'movement :down)  -1)
                       (T                            0))))
      (setf (state player) :dashing)
      (setf (animation player) 'dash)
      (when (v= 0 acc) (setf (vx acc) (direction player)))
      (nvunit acc))))

(define-handler (player start-jump) (ev)
  (unless (eql :crawling (state player))
    (setf (jump-time player) (- +coyote+))))

(define-handler (player light-attack) (ev)
  (when (aref (collisions player) 2)
    (setf (animation player) 'light-ground)
    (setf (state player) :attacking)))

(define-handler (player heavy-attack) (ev)
  (when (aref (collisions player) 2)
    (setf (animation player) 'heavy-ground)
    (setf (state player) :attacking)))

(flet ((handle-solid (player hit)
         (when (and (= +1 (vy (hit-normal hit)))
                    (< (vy (velocity player)) -5))
           (when (< 0.5 (air-time player))
             (shake-camera :duration 20 :intensity (* 3 (/ (abs (vy (velocity player))) (vy +vlim+)))))
           (enter (make-instance 'dust-cloud :location (nv+ (v* (velocity player) (hit-time hit)) (location player)))
                  +world+))
         (setf (air-time player) 0.0d0)
         (unless (eql :dashing (state player))
           (setf (dash-time player) 0.0))))
  (defmethod collide :before ((player player) (block block) hit)
    (unless (typep block 'spike)
      (handle-solid player hit)))

  (defmethod collide :before ((player player) (solid solid) hit)
    (handle-solid player hit)))

(defmethod collide ((player player) (trigger trigger) hit)
  (when (active-p trigger)
    (fire trigger)))

(defmethod collide :after ((player player) (enemy enemy) hit)
  (when (eql :dashing (state player))
    (nv+ (acceleration enemy) (nv* (vunit (acceleration player)) 2))
    (incf (vy (acceleration enemy)) 1.0)
    (nv* (nvunit (acceleration player)) -0.3)
    (incf (vy (acceleration player)) 0.1)
    (setf (stun-time player) 0.2d0)
    (setf (state player) :stunned)))

(defmethod (setf state) :before (state (player player))
  (unless (eq state (state player))
    (case state
      (:crawling
       (decf (vy (location player)) 8)
       (setf (vy (bsize player)) 8))
      (:climbing
       (setf (direction player) (if (svref (collisions player) 1) +1 -1))))
    (case (state player)
      (:crawling
       (incf (vy (location player)) 8)
       (setf (vy (bsize player)) 16)))))

(defmethod tick :before ((player player) ev)
  (when (path player)
    (return-from tick))
  (let ((collisions (collisions player))
        (dt (* 100 (dt ev)))
        (loc (location player))
        (acc (acceleration player))
        (size (bsize player)))
    (setf (interactable player) NIL)
    ;; Point test for interactables. Pretty stupid.
    (for:for ((entity over (surface player)))
      (when (and (not (eq entity player))
                 (typep entity 'interactable)
                 (contained-p (vec4 (vx loc) (vy loc) (* 1.5 (vx size)) (vy size)) entity))
        (setf (interactable player) entity)))
    ;; Handle jumps
    (when (< (jump-time player) 0.0d0)
      (cond ((or (svref collisions 1)
                 (svref collisions 3))
             ;; Wall jump
             (let ((dir (if (svref collisions 1) -1.0 1.0)))
               (setf (vx acc) (* dir (vz +vjump+)))
               (setf (vy acc) (vw +vjump+))
               (setf (direction player) dir)
               (setf (jump-time player) 0.0d0)
               (enter (make-instance 'dust-cloud :location (vec2 (+ (vx loc) (* dir 0.5 +tile-size+))
                                                                 (vy loc))
                                                 :direction (vec2 dir 0))
                      +world+)))
            ((< (air-time player) +coyote+)
             ;; Ground jump
             (setf (vy acc) (+ (vx +vjump+)
                               (if (svref collisions 2)
                                   (* 0.25 (max 0 (vy (velocity (svref collisions 2)))))
                                   0)))
             (setf (jump-time player) 0.0d0)
             (enter (make-instance 'dust-cloud :location (vcopy loc))
                    +world+))))
    (ecase (state player)
      (:stunned
       (decf (stun-time player) (dt ev))
       (when (<= (stun-time player) 0)
         (setf (state player) :normal)))
      (:dashing
       (incf (dash-time player) (dt ev))
       (enter (make-instance 'particle :location (nv+ (vrand -7 +7) (location player)))
              +world+)
       (cond ((not (eql 'dash (trial::sprite-animation-name (animation player))))
              (setf (state player) :normal))
             ((< 0.10 (dash-time player) 0.125)
              (nv* (nvunit acc) (vx +vdash+)))
             ((< 0.125 (dash-time player) 0.15)
              (nv* acc (damp* (vy +vdash+) dt)))))
      (:attacking
       (when (eql 'stand (trial::sprite-animation-name (animation player)))
         (setf (state player) :normal)))
      (:dying
       (nv* (velocity player) 0.9))
      (:climbing
       ;; Movement
       (let* ((top (if (= -1 (direction player))
                       (scan (surface player) (vec (- (vx loc) (vx size) 2) (- (vy loc) (vy size) 2)))
                       (scan (surface player) (vec (+ (vx loc) (vx size) 2) (- (vy loc) (vy size) 2)))))
              (attached (or (svref collisions (if (< 0 (direction player)) 1 3))
                            top)))
         (unless (and (retained 'movement :climb) attached)
           (setf (state player) :normal))
         (unless (retained 'movement :jump)
           (cond ((null (svref collisions (if (< 0 (direction player)) 1 3)))
                  (setf (vy acc) (vx +vclim+))
                  (setf (vx acc) (* (direction player) (vx +vclim+))))
                 ((retained 'movement :up)
                  (setf (vy acc) (vx +vclim+)))
                 ((retained 'movement :down)
                  (setf (vy acc) (* (vy +vclim+) -1)))
                 (T
                  (setf (vy acc) 0))))))
      (:crawling
       ;; Uncrawl on ground loss, or if we request it and aren't cramped.
       (unless (and (svref collisions 2)
                    (or (retained 'movement :down)
                        (svref collisions 0)))
         (setf (state player) :normal))
       
       (cond ((retained 'movement :left)
              (setf (vx acc) (- (vx +vcraw+))))
             ((retained 'movement :right)
              (setf (vx acc) (+ (vx +vcraw+))))
             (T
              (setf (vx acc) 0))))
      (:normal
       ;; Test for climbing
       (when (and (retained 'movement :climb)
                  (not (retained 'movement :jump))
                  (or (typep (svref collisions 1) '(and (not null) (not platform)))
                      (typep (svref collisions 3) '(and (not null) (not platform)))))
         (setf (state player) :climbing))

       ;; Test for crawling
       (when (and (retained 'movement :down)
                  (svref collisions 2))
         (setf (state player) :crawling))

       ;; Movement
       (setf (vx acc) (* (vx acc) (damp* (vy +vmove+) dt)))
       (cond ((svref collisions 2)
              (setf (vy acc) (max 0 (vy acc)))
              (incf (vy acc) (min 0 (vy (velocity (svref collisions 2)))))
              (cond ((retained 'movement :left)
                     (setf (direction player) -1)
                     ;; Quick turns on the ground.
                     (when (< 0 (vx acc))
                       (setf (vx acc) 0))
                     (when (< (- (vw +vmove+)) (vx acc))
                       (decf (vx acc) (vx +vmove+))))
                    ((retained 'movement :right)
                     (setf (direction player) +1)
                     ;; Quick turns on the ground.
                     (when (< (vx acc) 0)
                       (setf (vx acc) 0))
                     (when (< (vx acc) (vw +vmove+))
                       (incf (vx acc) (vx +vmove+))))
                    (T
                     (setf (vx acc) 0))))
             ((retained 'movement :left)
              (setf (direction player) -1)
              (when (< (- (vw +vmove+)) (vx acc))
                (decf (vx acc) (vz +vmove+))))
             ((retained 'movement :right)
              (setf (direction player) +1)
              (when (< (vx acc) (vw +vmove+))
                (incf (vx acc) (vz +vmove+)))))
       ;; Jump progress
       (when (< 0 (jump-time player))
         (when (and (retained 'movement :jump)
                    (<= 0.05 (jump-time player) 0.15))
           (setf (vy acc) (* (vy acc) (damp* (vy +vjump+) dt)))))
       (decf (vy acc) (* +vgrav+ dt))
       ;; Limit when sliding down wall
       (when (and (or (typep (svref collisions 1) 'ground)
                      (typep (svref collisions 3) 'ground))
                  (< (vy acc) (vz +vclim+)))
         (setf (vy acc) (vz +vclim+)))))
    (nvclamp (v- +vlim+) acc +vlim+)
    (nv+ (velocity player) acc)))

(defmethod tick :after ((player player) ev)
  (incf (jump-time player) (dt ev))
  (incf (air-time player) (dt ev))
  ;; OOB
  (unless (contained-p (location player) (surface player))
    (let ((other (for:for ((entity over (unit 'region +world+)))
                          (when (and (typep entity 'chunk)
                                     (contained-p (location player) entity))
                            (return entity)))))
      (cond (other
             (issue +world+ 'switch-chunk :chunk other))
            ((< (vy (location player)) (vy (location (surface player))))
             (die player))
            (T
             (setf (vx (location player)) (clamp (- (vx (location (surface player)))
                                                    (bsize (surface player)))
                                                 (vx (location player))
                                                 (+ (vx (location (surface player)))
                                                    (bsize (surface player)))))))))
  ;; Animations
  (let ((acc (acceleration player))
        (collisions (collisions player)))
    (cond ((< 0 (vx acc))
           (setf (direction player) +1))
          ((< (vx acc) 0)
           (setf (direction player) -1)))
    (case (state player)
      (:climbing
       (setf (animation player) 'climb)
       (cond
         ((< 0 (vy acc))
          (setf (playback-direction player) +1)
          (setf (playback-speed player) 1.0))
         ((< (vy acc) 0)
          (setf (playback-direction player) -1)
          (setf (playback-speed player) 1.5))
         (T
          (setf (clock player) 0.0d0))))
      (:crawling
       (setf (animation player) 'crawl)
       (when (= 0 (vx acc))
         (setf (clock player) 0.0d0)))
      (:normal
       (cond ((< 0 (vy acc))
              (setf (animation player) 'jump))
             ((null (svref collisions 2))
              (cond ((typep (svref collisions 1) 'ground)
                     (setf (animation player) 'slide)
                     (setf (direction player) +1))
                    ((typep (svref collisions 3) 'ground)
                     (setf (animation player) 'slide)
                     (setf (direction player) -1))
                    (T
                     (setf (animation player) 'fall))))
             ((< 0 (vx acc))
              (setf (animation player) 'run))
             ((< (vx acc) 0)
              (setf (animation player) 'run))
             (T
              (setf (animation player) 'stand)))))))

(define-handler (player switch-region) (ev region)
  (let ((other (for:for ((entity over region))
                 (list entity (contained-p (location player) entity))
                 (when (and (typep entity 'chunk)
                            (contained-p (location player) entity))
                   (return entity)))))
    (unless other
      (warn "Player is somehow outside all chunks, picking first chunk we can get.")
      (setf other (for:for ((entity over (unit 'region region)))
                    (when (typep entity 'chunk) (return entity))))
      (unless other
        (error "What the fuck? Could not find any chunks.")))
    (issue +world+ 'switch-chunk :chunk other)))

(define-handler (player switch-chunk) (ev chunk)
  (setf (surface player) chunk)
  (setf (spawn-location player) (vcopy (location player))))

(defmethod compute-resources :after ((player player) resources ready cache)
  (vector-push-extend (asset 'leaf 'particle) resources))

(defmethod register-object-for-pass :after (pass (player player))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'dust-cloud)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'particle))))

(defmethod die ((player player))
  (vsetf (acceleration player) 0 0)
  (vsetf (location player) 0 0))

(defmethod death ((player player))
  (vsetf (location player)
         (vx (spawn-location player))
         (vy (spawn-location player))))

(defun player-screen-y ()
  (* (- (vy (location (unit 'player T))) (vy (location (unit :camera T))))
     (view-scale (unit :camera T))))

(defmethod paint :before ((player player) target)
  (case (state player)
    (:crawling (translate-by 0 17 0))
    (T (translate-by 0 9 0))))

(defmethod paint :around ((player player) target)
  (call-next-method)
  (when (interactable player)
    (let ((prompt (prompt player))
          (interactable (interactable player)))
      (setf (vx (location prompt))
            (+ (vx (location interactable)) (- (/ (width prompt) 2))))
      (setf (vy (location prompt))
            (+ (vy (location interactable))
               (vy (bsize player))
               (height prompt)))
      (paint prompt target))))
