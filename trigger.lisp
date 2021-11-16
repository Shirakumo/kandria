(in-package #:org.shirakumo.fraf.kandria)

(defclass trigger (sized-entity resizable ephemeral collider)
  ((active-p :initarg :active-p :initform T :accessor active-p :accessor quest:active-p :type boolean)))

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
  (setf (spawn-location entity)
        (vec (vx (location trigger))
             (+ (- (vy (location trigger))
                   (vy (bsize trigger)))
                (vy (bsize entity))))))

(defclass story-trigger (one-time-trigger creatable)
  ((story-item :initarg :story-item :initform NIL :accessor story-item :type symbol)
   (target-status :initarg :target-status :initform :active :accessor target-status :type symbol)))

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
  ((interaction :initarg :interaction :initform NIL :accessor interaction :type symbol)))

(defmethod initargs append ((trigger interaction-trigger)) '(:interaction))

(defmethod interact ((trigger interaction-trigger) entity)
  (when (typep entity 'player)
    (show (make-instance 'dialog :interactions (list (quest:find-trigger (interaction trigger) +world+))))))

(defclass walkntalk-trigger (one-time-trigger creatable)
  ((interaction :initarg :interaction :initform NIL :accessor interaction :type symbol)
   (target :initarg :target :initform T :accessor target :type symbol)))

(defmethod initargs append ((trigger walkntalk-trigger)) '(:interaction :target))

(defmethod interact ((trigger walkntalk-trigger) entity)
  (when (typep (name entity) (target trigger))
    (walk-n-talk (quest:find-trigger (interaction trigger) +world+))))

(defclass tween-trigger (trigger)
  ((left :initarg :left :accessor left :initform 0.0 :type single-float)
   (right :initarg :right :accessor right :initform 1.0 :type single-float)
   (horizontal :initarg :horizontal :accessor horizontal :initform T :type boolean)
   (ease-fun :initarg :easing :accessor ease-fun :initform 'linear :type symbol)))

(defmethod initargs append ((trigger tween-trigger)) '(:left :right :horizontal :ease-fun))

(defmethod interact ((trigger tween-trigger) (entity located-entity))
  (let* ((x (if (horizontal trigger)
                (+ (/ (- (vx (location entity)) (vx (location trigger)))
                      (* 2.0 (vx (bsize trigger))))
                   0.5)
                (+ (/ (- (vy (location entity)) (vy (location trigger)))
                      (* 2.0 (vy (bsize trigger))))
                   0.5)))
         (v (ease (clamp 0 x 1) (ease-fun trigger) (left trigger) (right trigger))))
    (setf (value trigger) v)))

(defclass sandstorm-trigger (tween-trigger creatable)
  ())

(defmethod stage :after ((trigger sandstorm-trigger) (area staging-area))
  (stage (// 'sound 'sandstorm) area))

(defmethod (setf value) (value (trigger sandstorm-trigger))
  (let ((value (max 0.0 (- value 0.01))))
    (cond ((< 0 value)
           (harmony:play (// 'sound 'sandstorm))
           (setf (mixed:volume (// 'sound 'sandstorm)) (/ value 4)))
          (T
           (harmony:stop (// 'sound 'sandstorm))))
    (setf (strength (unit 'sandstorm T)) value)))

(defclass zoom-trigger (tween-trigger creatable)
  ((easing :initform 'quint-in)))

(defmethod (setf value) (value (trigger zoom-trigger))
  (setf (intended-zoom (unit :camera T)) value))

(defclass pan-trigger (tween-trigger creatable)
  ())

(defmethod (setf value) (value (trigger pan-trigger))
  (duck-camera (vx value) (vy value)))

(defclass teleport-trigger (trigger creatable)
  ((target :initform NIL :initarg :target :accessor target)
   (primary :initform T :initarg :primary :accessor primary)))

(defmethod initargs append ((trigger teleport-trigger)) '(:target))

(defmethod default-tool ((trigger teleport-trigger)) (find-class 'freeform))

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
    (cond ((eql :fishing (state (unit 'player +world+))))
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

(defclass action-prompt (trigger listener creatable)
  ((action :initarg :action :initform NIL :accessor action
           :type alloy::any)
   (interrupt :initarg :interrupt :initform NIL :accessor interrupt
              :type boolean)
   (prompt :initform (make-instance 'prompt) :reader prompt)
   (triggered :initform NIL :accessor triggered)))

(defmethod initargs append ((prompt action-prompt)) '(:action :interrupt))

(defmethod interactable-p ((prompt action-prompt))
  (active-p prompt))

(defmethod handle ((ev tick) (prompt action-prompt))
  (unless (triggered prompt)
    (when (slot-boundp (prompt prompt) 'alloy:layout-parent)
      (hide (prompt prompt))))
  (setf (triggered prompt) NIL))

(defmethod interact ((prompt action-prompt) (player player))
  (when (eql :normal (state player))
    (when (interrupt prompt)
      ;; KLUDGE: clear dash to ensure player can always recover.
      (when (eql (action prompt) 'dash)
        (setf (dash-time player) 0.0))
      (if (<= 0.01 (time-scale +world+))
          (setf (time-scale +world+) (* (time-scale +world+) 0.95))
          (setf (time-scale +world+) 0.0)))
    (let ((loc (vec (vx (location prompt))
                    (+ (vy (location player)) (vy (bsize player))))))
      (show (prompt prompt) :button (action prompt)
                            :description (language-string (unlist (action prompt)) NIL)
                            :location loc)
      (setf (triggered prompt) T))))

(defmethod handle ((ev trial:action) (prompt action-prompt))
  (when (and (interrupt prompt)
             (typep ev (action prompt))
             (active-p prompt)
             (contained-p prompt (unit 'player +world+)))
    (setf (time-scale +world+) 1.0)
    (setf (active-p prompt) NIL)))

(defmethod leave* :before ((prompt action-prompt) from)
  (hide (prompt prompt)))

(define-shader-entity wind (lit-entity trigger listener creatable)
  ((strength :initarg :strength :initform (vec 0 0) :accessor strength :type vec2)
   (kind :initarg :kind :initform :constant :accessor kind :type symbol)
   (texture :initform (// 'kandria 'wind) :accessor texture)
   (vertex-array :initform (// 'trial 'trial::fullscreen-square) :accessor vertex-array)
   (clock :initform 0.0 :accessor clock)
   (accumulator :initform (vec 0 0) :accessor accumulator)
   (active-time :initform 0.0 :accessor active-time)))

(defmethod interact ((wind wind) (player player))
  ;; FIXME: how do we get the actual dt here?
  (unless (eq :dashing (state player))
    (nv+ (velocity player) (v* (strength wind) 0.01))
    (when (svref (collisions player) 2)
      (nv+ (frame-velocity player) (v* (strength wind) 0.01))))
  (incf (active-time wind) 0.02))

(defmethod stage :after ((wind wind) (area staging-area))
  (stage (texture wind) area)
  (stage (vertex-array wind) area))

(defmethod handle ((ev tick) (wind wind))
  (incf (clock wind) (dt ev))
  (nv+ (accumulator wind) (vmin (tvec 9 9) (strength wind)))
  (setf (active-time wind) (clamp 0.0 (- (active-time wind) (dt ev)) 1.0))
  (ecase (kind wind)
    (:constant
     (setf (vx (strength wind)) (* 5 (1+ (sin (clock wind))))))))

(defmethod render ((wind wind) (program shader-program))
  (when (in-view-p (location wind) (bsize wind))
    (setf (uniform program "view_size") (vec2 (max 1 (width *context*)) (max 1 (height *context*))))
    (setf (uniform program "view_matrix") (minv *view-matrix*))
    (setf (uniform program "clock") (clock wind))
    (setf (uniform program "strength") (vmin (tvec 9 9) (strength wind)))
    (setf (uniform program "accumulator") (accumulator wind))
    (setf (uniform program "visibility") (clamp 0.0 (active-time wind) 1.0))
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (texture wind)))
    (let ((vao (vertex-array wind)))
      (with-pushed-attribs
        (disable :depth-test)
        (gl:bind-vertex-array (gl-name vao))
        (%gl:draw-elements :triangles (size vao) :unsigned-int (cffi:null-pointer))
        (gl:bind-vertex-array 0)))))

(define-class-shader (wind :vertex-shader)
  "layout (location = 0) in vec2 vertex_pos;
layout (location = 1) in vec2 vertex_uv;
uniform mat4 view_matrix;
uniform vec2 view_size;
out vec2 world_xy;

void main(){
  world_xy = (view_matrix*vec4(vertex_uv*view_size,0,1)).xy;
  gl_Position = vec4(vertex_pos, 100, 1);
}")

(define-class-shader (wind :fragment-shader)
  "#define ITERATIONS 10
in vec2 world_xy;
out vec4 color;
uniform sampler2D tex_image;
uniform float clock = 0.0;
uniform vec2 strength = vec2(0);
uniform vec2 accumulator = vec2(0);
uniform float visibility = 0.0;

vec2 compute_offset(float dt, float scalar){
  float tt = clock - dt*2;
  float shift = 1.0-(sin(tt*1.524)+cos(world_xy.y*0.1)*0.3)*0.0001;
  return world_xy/scalar
         + tt*(vec2(0.0,sin(tt*1.132)*0.0002+0.1))
         - (accumulator-dt*100*strength)*0.01;
}

void main(){
  vec2 coord = compute_offset(0, 128);
  color = vec4(0);
  for(int i=0; i<ITERATIONS; ++i){
    color += texture(tex_image, coord)*(ITERATIONS-i)*(1.0/ITERATIONS);
    coord = compute_offset(i*0.01*(1.0/ITERATIONS), 128);
  }
  color += texture(tex_image, compute_offset(0, 100));
  color = apply_lighting_flat(color, vec2(0), 0, world_xy);
  color *= visibility;
}")
