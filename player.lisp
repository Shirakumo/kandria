(in-package #:org.shirakumo.fraf.leaf)

(define-asset (leaf player-mesh) mesh
    (make-rectangle 32 40))

(define-global +vlim+ (vec  10      10))
;;                          GRD-ACC AIR-DCC AIR-ACC GRD-LIM
(define-global +vmove+ (vec 0.3     0.97    0.08    1.75))
;;                          CLIMB   DOWN    SLIDE
(define-global +vclim+ (vec 0.8     1.5     -1.2))
;;                          JUMP    LONGJMP WALL-VX WALL-VY
(define-global +vjump+ (vec 2.5     1.1     2.75     3.5))
;;                          ACC     DCC
(define-global +vdash+ (vec 20      0.7))

(define-shader-subject player (animated-sprite-subject moving facing-entity dialog-entity lighted-entity)
  ((spawn-location :initform (vec2 0 0) :accessor spawn-location)
   (prompt :initform (make-instance 'prompt :text :y :size 16 :color (vec 1 1 1 1)) :accessor prompt)
   (interactable :initform NIL :accessor interactable)
   (vertex-array :initform (asset 'leaf 'player-mesh))
   (jump-count :initform 0 :accessor jump-count)
   (dash-count :initform 0 :accessor dash-count)
   (surface :initform NIL :accessor surface))
  (:default-initargs
   :name :player
   :emotes '(:default concerned thinking cheeky)
   :profile (asset 'leaf 'profile)
   :texture (asset 'leaf 'player)
   :bsize (nv/ (vec 16 32) 2)
   :size (vec 32 40)
   :animation 0
   :animations '((stand 0 8 :step 0.1)
                 (run 8 24 :step 0.05)
                 (jump 24 27 :step 0.1 :next fall)
                 (fall 27 33 :step 0.1 :loop-to 29)
                 (slide 33 39 :step 0.075 :loop-to 38)
                 (climb 39 51 :step 0.1))))

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

(define-class-shader (player :fragment-shader)
  "in vec2 world_pos;
out vec4 color;

void main(){
  color.rgb = shade_lights(color.rgb, ivec3(world_pos+2, 0));
}")


(define-handler (player interact) (ev)
  (when (interactable player)
    (issue +level+ 'interaction :with (name (interactable player)))))

(define-handler (player dash) (ev)
  (let ((vel (velocity player)))
    (when (= 0 (dash-count player))
      (vsetf vel
             (cond ((retained 'movement :left)  -1)
                   ((retained 'movement :right) +1)
                   (T                            0))
             (cond ((retained 'movement :up)    +1)
                   ((retained 'movement :down)  -1)
                   (T                            0)))
      (setf (state player) :dashing)
      ;; (setf (animation player) 8)
      (when (v= 0 vel) (setf (vx vel) 1))
      (nvunit vel))))

(define-handler (player start-jump) (ev)
  (let* ((collisions (collisions player))
         (loc (location player))
         (vel (velocity player)))
    (cond ((svref collisions 2)
           ;; Ground jump
           (setf (vy vel) (vx +vjump+))
           (incf (jump-count player))
           (enter (make-instance 'dust-cloud :location (vcopy loc))
                  +level+))
          ((or (svref collisions 1)
               (svref collisions 3))
           ;; Wall jump
           (let ((dir (if (svref collisions 1) -1.0 1.0)))
             (setf (vx vel) (* dir (vz +vjump+)))
             (setf (vy vel) (vw +vjump+))
             (setf (direction player) dir)
             (enter (make-instance 'dust-cloud :location (vec2 (+ (vx loc) (* dir 0.5 +tile-size+))
                                                               (vy loc))
                                               :direction (vec2 dir 0))
                    +level+))))))

(defmethod collide :before ((player player) (block block) hit)
  (unless (typep block 'spike)
    (when (and (= +1 (vy (hit-normal hit)))
               (< (vy (velocity player)) -2))
      (enter (make-instance 'dust-cloud :location (nv+ (v* (velocity player) (hit-time hit)) (location player)))
             +level+))))

(defmethod collide ((player player) (trigger trigger) hit)
  (when (active-p trigger)
    (fire trigger)))

(defmethod collide ((player player) (interactable interactable) hit)
  (when (or (null (interactable player))
            (< (vsqrdist2 (location player) (location interactable))
               (vsqrdist2 (location player) (location (interactable player)))))
    (setf (interactable player) interactable)))

(defmethod tick :before ((player player) ev)
  (let ((collisions (collisions player))
        (loc (location player))
        (vel (velocity player))
        (size (bsize player)))
    (setf (interactable player) NIL)
    (ecase (state player)
      (:dashing
       (incf (dash-count player))
       (enter (make-instance 'particle :location (nv+ (vrand -7 +7) (location player)))
              +level+)
       (when (and (svref (collisions player) 2)
                  (= 0 (mod (dash-count player) 3)))
         (enter (make-instance 'dust-cloud :location (vcopy (location player)))
                +level+))
       (cond ((< 20 (dash-count player))
              (setf (state player) :normal))
             ((< 15 (dash-count player))
              (nv* vel (vy +vdash+)))
             ((= 8 (dash-count player))
              (nv* vel (vx +vdash+)))))
      (:dying
       (nv* vel 0.9))
      (:climbing
       ;; Animations
       (cond
         ((retained 'movement :up)
          (setf (playback-direction player) +1)
          (setf (playback-speed player) 1.0))
         ((retained 'movement :down)
          (setf (playback-direction player) -1)
          (setf (playback-speed player) 1.5))
         (T
          (setf (clock player) 0.0d0)))
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
                  (setf (vy vel) (vx +vclim+))
                  (setf (vx vel) (* (direction player) (vx +vclim+))))
                 ((retained 'movement :up)
                  (setf (vy vel) (vx +vclim+)))
                 ((retained 'movement :down)
                  (setf (vy vel) (* (vy +vclim+) -1)))
                 (T
                  (setf (vy vel) 0)))
           (when (typep attached 'moving-platform)
             (nv+ vel (velocity attached))))))
      (:normal
       ;; Animations
       (cond ((and (/= 0 (jump-count player))
                   (retained 'movement :jump))
              (setf (animation player) 'jump))
             ((and (or (svref collisions 1)
                       (svref collisions 3))
                   (not (svref collisions 2)))
              (setf (animation player) 'slide))
             ((svref collisions 2)
              (setf (animation player) (if (or (retained 'movement :left)
                                               (retained 'movement :right))
                                           'run 'stand)))
             (T
              (setf (animation player) 'fall)))
       
       ;; Test for climbing
       (when (and (retained 'movement :climb)
                  (not (retained 'movement :jump))
                  (or (svref collisions 1)
                      (svref collisions 3)))
         (setf (state player) :climbing)
         (setf (animation player) 'climb)
         (setf (direction player) (if (svref collisions 1) +1 -1)))

       ;; Movement
       (setf (vx vel) (* (vx vel) (vy +vmove+)))
       (cond ((svref collisions 2)
              (cond ((retained 'movement :left)
                     (setf (direction player) -1)
                     ;; Quick turns on the ground.
                     (when (< 0 (vx vel))
                       (setf (vx vel) 0))
                     (when (< (- (vw +vmove+)) (vx vel))
                       (decf (vx vel) (vx +vmove+))))
                    ((retained 'movement :right)
                     (setf (direction player) +1)
                     ;; Quick turns on the ground.
                     (when (< (vx vel) 0)
                       (setf (vx vel) 0))
                     (when (< (vx vel) (vw +vmove+))
                       (incf (vx vel) (vx +vmove+))))
                    (T
                     (setf (vx vel) 0))))
             ((retained 'movement :left)
              (setf (direction player) -1)
              (when (< (- (vw +vmove+)) (vx vel))
                (decf (vx vel) (vz +vmove+))))
             ((retained 'movement :right)
              (setf (direction player) +1)
              (when (< (vx vel) (vw +vmove+))
                (incf (vx vel) (vz +vmove+)))))
       ;; Jump progress
       (when (< 0 (jump-count player))
         (when (and (retained 'movement :jump)
                    (<= 5 (jump-count player) 15))
           (setf (vy vel) (* (vy +vjump+) (vy vel))))
         (incf (jump-count player)))
       ;; FIXME: Hard-coded gravity
       (decf (vy vel) 0.15)
       ;; Limit when sliding down wall
       (when (and (or (svref collisions 1)
                      (svref collisions 3))
                  (< (vy vel) (vz +vclim+)))
         (setf (vy vel) (vz +vclim+)))))
    (nvclamp (v- +vlim+) vel +vlim+))
  ;; OOB
  (unless (contained-p (location player) (surface player))
    (let ((other (for:for ((entity over (unit 'region +level+)))
                   (when (and (typep entity 'chunk)
                              (contained-p (location player) entity))
                     (return entity)))))
      (if other
          (issue +level+ 'switch-chunk :chunk other)
          (die player)))))

(defmethod tick :after ((player player) ev)
  (when (svref (collisions player) 2)
    (setf (jump-count player) 0)
    (unless (eql :dashing (state player))
      (setf (dash-count player) 0))))

(defmethod enter :after ((player player) (scene scene))
  (add-progression (progression-definition 'intro) scene)
  (add-progression (progression-definition 'revive) scene)
  (add-progression (progression-definition 'die) scene))

(define-handler (player switch-level) (ev level)
  (let ((other (for:for ((entity over (unit 'region level)))
                 (when (and (typep entity 'chunk)
                            (contained-p (location player) entity))
                   (return entity)))))
    (unless other
      (warn "Player is somehow outside all chunks, picking first chunk we can get.")
      (setf other (for:for ((entity flare-queue:in-queue (objects level)))
                    (when (typep entity 'chunk) (return entity)))))
    (issue level 'switch-chunk :chunk other)))

(define-handler (player switch-chunk) (ev chunk)
  (when (surface player)
    (deactivate (surface player)))
  (activate chunk)
  (setf (surface player) chunk)
  (setf (spawn-location player) (vcopy (location player))))

(defmethod compute-resources :after ((player player) resources ready cache)
  (vector-push-extend (asset 'leaf 'particle) resources))

(defmethod register-object-for-pass :after (pass (player player))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'dust-cloud)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'particle))))

(defmethod die ((player player))
  (vsetf (velocity player) 0 0)
  (vsetf (location player) 0 0)
  ;; (unless (eql (state player) :dying)
  ;;   (setf (state player) :dying)
  ;;   ;;(setf (animation player) 5)
  ;;   (nv* (velocity player) -1)
  ;;   (start (reset (progression 'die +level+))))
  )

(defmethod death ((player player))
  (start (reset (progression 'revive +level+)))
  ;;(setf (animation player) 6)
  (vsetf (location player)
         (vx (spawn-location player))
         (vy (spawn-location player))))

(defun player-screen-y ()
  (* (- (vy (location (unit :player T))) (vy (location (unit :camera T))))
     (view-scale (unit :camera T))))

(defmethod paint :before ((player player) target)
  (translate-by 0 4 0))

(defmethod paint :around ((player player) target)
  (call-next-method)
  (when (interactable player)
    (let ((prompt (prompt player))
          (interactable (interactable player)))
      (setf (vx (location prompt))
            (+ (vx (location interactable)) (- (/ (width prompt) 2))))
      (setf (vy (location prompt))
            (+ (vy (location interactable))
               (vy (size player))
               (height prompt)
               (/ (vy (size interactable)) -2)))
      (paint prompt target))))

(define-progression intro
  0.0 0.1 (:blink (calc middle :to (player-screen-y))
                  (set strength :from 1.0 :to 1.0))
  2.0 4.0 (:blink (set strength :from 1.0 :to 0.9 :ease cubic-in-out))
          (:bokeh (set strength :from 100.0 :to 80.0 :ease cubic-in-out))
  4.0 5.0 (:blink (set strength :to 1.0 :ease cubic-in-out))
  5.0 6.0 (:blink (set strength :to 0.7 :ease cubic-in-out))
  6.0 6.5 (:blink (set strength :to 1.0 :ease cubic-in))
  5.0 7.0 (:bokeh (set strength :to 0.0 :ease circ-in))
  6.5 6.7 (:blink (set strength :to 0.0 :ease cubic-in-out))
  6.7 6.8 (:blink (set strength :to 1.0 :ease cubic-in))
  6.8 6.9 (:blink (set strength :to 0.0 :ease cubic-in))
  6.9 7.0 (:blink (set strength :to 1.0 :ease cubic-in))
  7.0 7.1 (:blink (set strength :to 0.0 :ease cubic-in)))

(define-progression revive
  0.0 1.5 (:blink (calc middle :to (player-screen-y)))
  0.0 0.6 (:blink (set strength :from 1.0 :to 0.3 :ease cubic-in-out))
          (:bokeh (set strength :from 100.0 :to 10.0 :ease cubic-in-out))
  0.4 0.4 (:player (call (lambda (player tt dt) ;;(setf (animation player) 7)
                           )))
  0.6 0.8 (:blink (set strength :to 1.0 :ease cubic-in))
          (:bokeh (set strength :to 0.0 :ease cubic-out))
  0.9 1.0 (:blink (set strength :to 0.0 :ease cubic-out))
  1.5 1.5 (:player (call (lambda (player tt dt) (setf (state player) :normal)))))

(define-progression die
  0.0 0.8 (:blink (calc middle :to (player-screen-y)))
  0.0 0.8 (:blink (set strength :from 0.0 :to 1.0 :ease cubic-in))
          (:bokeh (set strength :from 0.0 :to 10.0))
  0.8 0.8 (:player (call (lambda (player tt dt) (death player)))))
