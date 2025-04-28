(in-package #:org.shirakumo.fraf.kandria)

(defclass trigger (sized-entity resizable ephemeral collider)
  ((active-p :initarg :active-p :initform T :accessor active-p :accessor quest:active-p :type boolean
             :documentation "Whether the trigger is currently active or not")))

(defmethod is-collider-for ((moving moving) (trigger trigger)) NIL)

(defmethod initargs append ((trigger trigger)) '(:active-p))

(defmethod interact :around ((trigger trigger) source)
  (when (active-p trigger)
    (call-next-method)))

(defmethod quest:activate ((trigger trigger))
  (setf (active-p trigger) T))

(defmethod quest:deactivate ((trigger trigger))
  (setf (active-p trigger) NIL))

(defclass one-time-trigger (trigger)
  ())

(defmethod interact :after ((trigger one-time-trigger) source)
  (setf (active-p trigger) NIL))

(defclass checkpoint (trigger creatable)
  ())

(defmethod interact ((trigger checkpoint) entity)
  (case (state entity)
    ((:dying :respawning))
    (T (setf (spawn-location entity)
             (vec (vx (location trigger))
                  (+ (- (vy (location trigger))
                        (vy (bsize trigger)))
                     (vy (bsize entity))))))))

(defclass story-trigger (one-time-trigger creatable)
  ((story-item :initarg :story-item :initform NIL :accessor story-item :type symbol
               :documentation "The name of the story item to trigger")
   (target-status :initarg :target-status :initform :active :accessor target-status :type (member :active :inactive :complete)
                  :documentation "The status to change the story item to when triggered")))

(defmethod initargs append ((trigger story-trigger)) '(:story-item :target-status))

(defmethod interact ((trigger story-trigger) entity)
  (let ((name (story-item trigger)))
    (flet ((finish (thing)
             (ecase (target-status trigger)
               (:active (quest:activate thing))
               (:inactive (quest:deactivate thing))
               (:complete (quest:complete thing)))
             (return-from interact)))
      (loop for quest being the hash-values of (quest:quests (storyline +world+))
            do (loop for task being the hash-values of (quest:tasks quest)
                     do (loop for trigger being the hash-values of (quest:triggers task)
                              do (when (eql name (quest:name trigger))
                                   (finish trigger)))
                        (when (eql name (quest:name task))
                          (finish task)))
               (when (eql name (quest:name quest))
                 (finish quest)))
      (v:warn :kandria.quest "Could not find story-item named ~s when firing trigger ~s"
              name (name trigger)))))

(defclass interaction-trigger (one-time-trigger creatable)
  ((interaction :initarg :interaction :initform NIL :accessor interaction :type symbol
                :documentation "The interaction to trigger")))

(defmethod initargs append ((trigger interaction-trigger)) '(:interaction))

(defmethod interact ((trigger interaction-trigger) entity)
  (when (typep entity 'player)
    (handler-case
        (show (make-instance 'dialog :interactions (list (quest:find-trigger (interaction trigger) +world+))))
      #+kandria-release
      (error () (quest:deactivate trigger)))))

(defclass walkntalk-trigger (one-time-trigger creatable)
  ((interaction :initarg :interaction :initform NIL :accessor interaction :type symbol
                :documentation "The walk-n-talk interaction to trigger")
   (target :initarg :target :initform T :accessor target :type symbol
           :documentation "The name of the entity that can trigger this")))

(defmethod initargs append ((trigger walkntalk-trigger)) '(:interaction :target))

(defmethod interact ((trigger walkntalk-trigger) entity)
  (when (typep (name entity) (target trigger))
    (walk-n-talk (quest:find-trigger (interaction trigger) +world+))))

(defclass tween-trigger (trigger)
  ((left :initarg :left :accessor left :initform 0.0 :type single-float
         :documentation "The strength at the left edge")
   (right :initarg :right :accessor right :initform 1.0 :type single-float
          :documentation "The strength at the right edge")
   (horizontal :initarg :horizontal :accessor horizontal :initform T :type boolean
               :documentation "Whether the tween is horizontal (or vertical)")
   (ease-fun :initarg :easing :accessor ease-fun :initform 'linear :type (member linear cubic-out cubic-in)
             :documentation "The easing function to tween with")))

(defmethod initargs append ((trigger tween-trigger)) '(:left :right :horizontal :ease-fun))

(defmethod interact ((trigger tween-trigger) (entity located-entity))
  (flet ((ease (x fun from to)
           (let ((x (ecase fun
                      (linear x)
                      (cubic-out (easing-f:out-cubic x))
                      (cubic-in (easing-f:in-cubic x)))))
             (+ from (* (- to from) x)))))
    (let* ((x (if (horizontal trigger)
                  (+ (/ (- (vx (location entity)) (vx (location trigger)))
                        (* 2.0 (vx (bsize trigger))))
                     0.5)
                  (+ (/ (- (vy (location entity)) (vy (location trigger)))
                        (* 2.0 (vy (bsize trigger))))
                     0.5)))
           (v (ease (clamp 0.0 x 1.0) (ease-fun trigger) (left trigger) (right trigger))))
      (setf (value trigger) v))))

(defclass sandstorm-trigger (tween-trigger creatable)
  ((velocity :initform 1.0 :initarg :velocity :accessor velocity :type single-float
             :documentation "The velocity of the sandstorm")))

(defmethod stage :after ((trigger sandstorm-trigger) (area staging-area))
  (stage (// 'sound 'sandstorm) area))

(defmethod (setf value) (value (trigger sandstorm-trigger))
  (let ((value (max 0.0 (- value 0.01))))
    (cond ((< 0 value)
           (harmony:play (// 'sound 'sandstorm))
           (setf (mixed:volume (// 'sound 'sandstorm)) (/ value 4)))
          (T
           (harmony:stop (// 'sound 'sandstorm))))
    (let ((pass (node 'fade T)))
      (setf (sandstorm-strength pass) value)
      (setf (velocity pass) (velocity trigger)))))

(defclass dust-trigger (tween-trigger creatable)
  ())

(defmethod (setf value) (value (trigger dust-trigger))
  (let ((value (* 0.3 (max 0.0 (- value 0.01))))
        (pass (node 'fade T)))
    (setf (sandstorm-strength pass) value)
    (setf (velocity pass) 0.05)))

(defclass zoom-trigger (tween-trigger creatable)
  ((easing :initform 'quint-in)))

(defmethod (setf value) (value (trigger zoom-trigger))
  (setf (intended-zoom (camera +world+)) value))

(defclass pan-trigger (tween-trigger creatable)
  ())

(defmethod (setf value) (value (trigger pan-trigger))
  (duck-camera (vx value) (vy value)))

(defclass teleport-trigger (trigger creatable)
  ((target :initform NIL :initarg :target :accessor target)
   (primary :initform T :initarg :primary :accessor primary)))

(defmethod initargs append ((trigger teleport-trigger)) '(:target))

(defmethod default-tool ((trigger teleport-trigger)) 'freeform)

(defmethod enter :after ((trigger teleport-trigger) (region region))
  (when (primary trigger)
    (destructuring-bind (&optional (location (vec (+ (vx (location trigger)) (* 2 (vx (bsize trigger))))
                                                  (vy (location trigger))))
                                   (bsize (vcopy (bsize trigger)))) (target trigger)
      (let* ((other (clone trigger :location location :bsize bsize :target trigger :active-p NIL :primary NIL)))
        (setf (target trigger) other)
        (enter other region)))))

(defmethod interact ((trigger teleport-trigger) (entity located-entity))
  (setf (location entity) (target trigger))
  (vsetf (velocity entity) 0 0))

(defclass earthquake-trigger (trigger creatable)
  ((duration :initform 60.0 :initarg :duration :accessor duration)
   (clock :initform 0.0 :accessor clock)))

(defmethod stage :after ((trigger earthquake-trigger) (area staging-area))
  (stage (// 'sound 'ambience-earthquake) area))

(defmethod closest-acceptable-location ((trigger earthquake-trigger) location)
  location)

(defmethod interact ((trigger earthquake-trigger) (player player))
  (decf (clock trigger) 0.01)
  (let* ((max 7.0)
         (hmax (/ max 2.0)))
    (cond ((eql :fishing (state (node 'player +world+))))
          ((<= (clock trigger) (- max))
           (shake-camera :duration 0.0 :intensity 0)
           (setf (clock trigger) (+ (duration trigger) (random 10.0))))
          ((<= (clock trigger) -0.1)
           (let ((intensity (* 10 (- 1 (/ (expt 3 (abs (+ hmax (clock trigger))))
                                          (expt 3 hmax))))))
             (shake-camera :duration 7.0 :intensity intensity :rumble-intensity 0.1)))
          ((<= (clock trigger) 0.0)
           (harmony:play (// 'sound 'ambience-earthquake))))))
;; TODO: make dust fall down over screen.

(defclass music-trigger (trigger creatable)
  ((track :initarg :track :initform (asset 'music 'scare) :accessor track
          :type trial-harmony:sound :documentation "The music to play within this trigger volume")))

(defmethod stage :after ((trigger music-trigger) (area staging-area))
  (stage (resource (track trigger) T) area))

(defmethod (setf sound) :after ((sound trial-harmony:sound) (trigger music-trigger))
  (when +main+
    (trial:commit trigger (loader +main+) :unload NIL)))

(defmethod interact ((trigger music-trigger) (player player))
  (let ((sdf (max (- (abs (- (vx (location player)) (vx (location trigger)))) (vx (bsize trigger)))
                  (- (abs (- (vy (location player)) (vy (location trigger)))) (vy (bsize trigger))))))
    (if (<= sdf -3)
        (setf (override (node 'environment +world+)) (resource (track trigger) T))
        (setf (override (node 'environment +world+)) NIL))))

(defclass audio-trigger (trigger creatable)
  ((sound :initarg :sound :initform (asset 'sound 'ambience-pebbles-fall) :accessor sound
          :type trial-harmony:sound :documentation "The sound to play when entering this volume")
   (played-p :initform NIL :accessor played-p)))

(defmethod stage :after ((trigger audio-trigger) (area staging-area))
  (stage (resource (sound trigger) T) area))

(defmethod (setf sound) :after ((sound trial-harmony:sound) (trigger audio-trigger))
  (when +main+
    (trial:commit trigger (loader +main+) :unload NIL)))

(defmethod interact ((trigger audio-trigger) (player player))
  (if (within-p trigger player)
      (unless (played-p trigger)
        (harmony:play (resource (sound trigger) T))
        (setf (played-p trigger) T))
      (setf (played-p trigger) NIL)))

(defclass shutter-trigger (parent-entity listener trigger creatable)
  ())

(defmethod make-child-entity ((trigger shutter-trigger))
  (make-instance 'shutter :location (vcopy (location trigger))))

(defmethod interact ((trigger shutter-trigger) (player player))
  (when (within-p trigger player)
    (let ((state (do-fitting (entity (bvh (region +world+)) trigger :open)
                   (when (typep entity 'enemy) (return :closed)))))
      (dolist (shutter (children trigger))
        (setf (state shutter) state)))))

(defmethod handle ((ev switch-chunk) (trigger shutter-trigger))
  (dolist (shutter (children trigger))
    (setf (state shutter) :open)))

(defclass action-prompt (trigger listener creatable)
  ((action :initarg :action :initform NIL :accessor action
           :type alloy::any :documentation "The name or list of names of an action to show the prompt for")
   (interrupt :initarg :interrupt :initform NIL :accessor interrupt
              :type boolean :documentation "Whether it should interrupt gameplay to ensure players see the prompt")
   (prompt :initform (make-instance 'prompt) :reader prompt)
   (triggered :initform NIL :accessor triggered)))

(defmethod initargs append ((prompt action-prompt)) '(:action :interrupt))

(defmethod interactable-p ((prompt action-prompt))
  (active-p prompt))

(defmethod handle ((ev tick) (prompt action-prompt))
  (unless (triggered prompt)
    (when (slot-boundp (prompt prompt) 'alloy:layout-parent)
      (hide (prompt prompt))))
  (when (and (interrupt prompt)
             (eql :triggered (active-p prompt))
             (< (time-scale +world+) 1.0))
    ;; KLUDGE: if we're triggered but leave the volume, still show the prompt
    (let* ((player (node 'player T))
           (loc (vec (vx (location prompt))
                     (+ (vy (location player)) (vy (bsize player))))))
      (when (setting :gameplay :display-hud)
        (show (prompt prompt) :button (action prompt)
                              :description (language-string (unlist (action prompt)) NIL)
                              :location loc))
      (setf (triggered prompt) T))
    (if (<= 0.01 (time-scale +world+))
        (setf (time-scale +world+) (* (time-scale +world+) 0.95))
        (setf (time-scale +world+) 0.0)))
  (setf (triggered prompt) NIL))

(defmethod interact ((prompt action-prompt) (player player))
  (when (and (eql :normal (state player))
             (active-p prompt))
    (when (and (interrupt prompt)
               (<= 1.0 (time-scale +world+)))
      ;; KLUDGE: clear dash to ensure player can always recover.
      (when (eql (action prompt) 'dash)
        (setf (dash-exhausted player) NIL))
      (setf (active-p prompt) :triggered)
      (setf (time-scale +world+) 0.99))
    (let ((loc (vec (vx (location prompt))
                    (+ (vy (location player)) (vy (bsize player))))))
      (when (setting :gameplay :display-hud)
        (show (prompt prompt) :button (action prompt)
                              :description (language-string (unlist (action prompt)) NIL)
                              :location loc))
      (setf (triggered prompt) T))))

(defmethod handle ((ev trial:action) (prompt action-prompt))
  (when (and (interrupt prompt)
             (active-p prompt)
             (typep ev (unlist (action prompt)))
             (< (time-scale +world+) 1.0))
    (setf (time-scale +world+) 1.0)
    (setf (active-p prompt) NIL)))

(defmethod leave :before ((prompt action-prompt) from)
  (hide (prompt prompt)))

(defclass fullscreen-prompt-trigger (trigger creatable)
  ((action :initarg :action :initform NIL :accessor action
           :type alloy::any :documentation "The name or list of names of the action to display")
   (title :initarg :title :initform NIL :accessor title
          :type alloy::any :documentation "The title to display for the prompt")))

(defmethod interactable-p ((trigger fullscreen-prompt-trigger))
  (active-p trigger))

(defmethod interact ((trigger fullscreen-prompt-trigger) (player player))
  (fullscreen-prompt (action trigger) :title (or (title trigger) (action trigger)))
  (setf (active-p trigger) NIL))

(define-asset (kandria wind-mesh) static
    (let* ((arr (make-array (+ (* 4 4) (* 4 16)) :element-type 'single-float))
           (vbo (make-instance 'vertex-buffer :data-usage :stream-draw :buffer-data arr))
           (vao (make-instance 'vertex-array :bindings `((,vbo :size 2 :offset 0 :stride 16)
                                                         (,vbo :size 2 :offset 8 :stride 16)
                                                         (,vbo :size 2 :offset 64 :stride 16 :instancing 1)
                                                         (,vbo :size 2 :offset 72 :stride 16 :instancing 1))
                                             :size 4 :vertex-form :triangle-fan)))
      (macrolet ((seta (&rest els)
                   `(progn ,@(loop for i from 0 for el in els
                                   collect `(setf (aref arr ,i) ,(float el))))))
        (seta  -4 -4  0  0
               +4 -4  1  0
               +4 +4  1  1
               -4 +4  0  1))
      (loop for i from (* 4 4) below (length arr) by 4
            do (setf (aref arr (+ i 0)) most-negative-single-float)
               (setf (aref arr (+ i 1)) most-positive-single-float)
               (setf (aref arr (+ i 2)) 1.0)
               (setf (aref arr (+ i 3)) 1.0))
      vao))

(define-shader-entity wind (textured-entity lit-entity trigger listener creatable)
  ((vertex-array :initform NIL :accessor vertex-array)
   (vertex-buffer :initform NIL :accessor vertex-buffer)
   (texture :initform (// 'kandria 'wind))
   (clock :initform 0.0 :accessor clock)
   (strength :initform (vec 0 0) :accessor strength)
   (max-strength :initarg :strength :initform (vec 0 0) :accessor max-strength :type vec2
                 :documentation "The maximal strength of the wind")
   (kind :initarg :kind :initform :constant :accessor kind :type (member :constant :periodic :oscillating)
         :documentation "How the wind behaves over time")
   (period :initarg :period :initform 2.0 :accessor period :type single-float
           :documentation "How long one full period of the wind takes")
   (active-time :initform 0.0 :accessor active-time)))

(defmethod initialize-instance :after ((wind wind) &key)
  (let ((vao (resource (asset 'kandria 'wind-mesh) T)))
    (setf (vertex-array wind) vao)
    (setf (vertex-buffer wind) (caar (bindings vao)))))

(defmethod layer-index ((wind wind)) (+ 2 +base-layer+))

(defmethod interact ((wind wind) (player player))
  ;; FIXME: how do we get the actual dt here?
  (unless (or (eq :dashing (state player))
              (eq :climbing (state player))
              (eq 'climb-ledge (name (animation player)))
              (not (typep (medium player) 'air)))
    (let ((strength (v* (strength wind) 0.01)))
      (nv+ (velocity player) strength)
      (when (svref (collisions player) 2)
        (incf (vx (frame-velocity player)) (vx strength))
        (when (< 0 (vy strength))
          (incf (vy (frame-velocity player)) (vy strength))))))
  (incf (active-time wind) 0.02))

(defmethod stage :after ((wind wind) (area staging-area))
  (stage (vertex-array wind) area)
  (stage (// 'sound 'ambience-strong-wind) area))

(defmethod handle ((ev tick) (wind wind))
  (when (< 0.0 (active-time wind))
    (incf (clock wind) (dt ev))
    (setf (active-time wind) (clamp 0.0 (- (active-time wind) (dt ev)) 1.0))
    (ecase (kind wind)
      (:constant
       (v<- (strength wind) (max-strength wind)))
      (:periodic
       (let* ((x (- (mod (* (/ 20.0 (period wind)) (clock wind)) 40.0) 20.0))
              (y (max (/ (1+ (expt 3 (- 10 x))))
                      (- 1 (/ (1+ (expt 3 (- -10 x))))))))
         (v<- (strength wind) (v* (max-strength wind) y))))
      (:oscillating
       (let* ((x (* (/ 2.0 (period wind)) (clock wind)))
              (y (clamp -1.0 (* 5.0 (sin x)) +1.0)))
         (v<- (strength wind) (v* (max-strength wind) y)))))
    (let* ((vbo (vertex-buffer wind))
           (arr (buffer-data vbo))
           (camera (camera +world+))
           (view (bsize camera))
           (spd (strength wind))
           (dir (if (v= 0.0 spd) #.(vec 1 0) (vunit spd)))
           (r (sqrt (+ (expt (vx view) 2) (expt (vy view) 2))))
           (off (v* dir r))
           (d (* r 1.75)))
      (flet ((respawn (ai)
               (let ((off (nv- (nv* (vec (- (vy dir)) (vx dir)) (- (random d) (* 0.5 d))) off)))
                 (setf (aref arr (+ ai 0)) (+ (vx off) (vx (location camera)) (random* 0 128)))
                 (setf (aref arr (+ ai 1)) (+ (vy off) (vy (location camera)) (random* 0 128)))))
             (contained-p (x y)
               (and (< (* (vx view) -2.5) (- x (vx (location camera))) (* (vx view) 2.5))
                    (< (* (vy view) -2.5) (- y (vy (location camera))) (* (vy view) 2.5)))))
        (dotimes (i 16)
          (let ((ai (+ (* i 4) 16)))
            (unless (contained-p (aref arr (+ ai 0)) (aref arr (+ ai 1)))
              (respawn ai))
            (incf (aref arr (+ ai 0)) (* (vx spd) 200 (dt ev)))
            (incf (aref arr (+ ai 1)) (* (vy spd) 200 (dt ev)))
            (incf (aref arr (+ ai 0)) (* 90 (sin (* 8 (clock wind))) (dt ev)))
            (incf (aref arr (+ ai 1)) (* -90 (- 1 (min (abs (vx spd)) 1.0)) (+ 1.2 (sin (* i (clock wind)))) (dt ev)))
            (setf (aref arr (+ ai 2)) (max 1.0 (vlength spd)))
            (setf (aref arr (+ ai 3)) (atan (vy dir) (vx dir))))))
      (update-buffer-data vbo arr))
    (if (< 0 (active-time wind))
        (harmony:play (// 'sound 'ambience-strong-wind) :volume (* (max 0.1 (/ (vlength (strength wind)) (vlength (max-strength wind))))
                                                                   (active-time wind)))
        (harmony:stop (// 'sound 'ambience-strong-wind)))))

(defmethod handle ((ev switch-chunk) (wind wind))
  (setf (clock wind) 0.0))

(defmethod render ((wind wind) (program shader-program))
  (when (< 0.0 (active-time wind))
    (setf (uniform program "view_matrix") *view-matrix*)
    (setf (uniform program "projection_matrix") *projection-matrix*)
    (setf (uniform program "visibility") (clamp 0.0 (active-time wind) 1.0))
    (render-array (vertex-array wind) :instances 16)))

(define-class-shader (wind :vertex-shader)
  "layout (location = 0) in vec2 position;
layout (location = 2) in vec2 offset;
layout (location = 3) in vec2 stretch;

uniform mat4 view_matrix;
uniform mat4 projection_matrix;
out vec2 world_pos;

void main(){
  maybe_call_next_method();
  float phi = stretch.y;
  mat2 rot = mat2(cos(phi), sin(phi), -sin(phi), cos(phi));
  world_pos = offset + rot*(position*vec2(stretch.x, 1));
  gl_Position = projection_matrix * view_matrix * vec4(world_pos, 0, 1.0f);
}")

(define-class-shader (wind :fragment-shader)
  "uniform float visibility;
out vec4 color;
in vec2 world_pos;

void main(){
  maybe_call_next_method();
  color = apply_lighting_flat(color, vec2(0), 0, world_pos) * visibility;
}")
