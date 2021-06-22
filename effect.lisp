(in-package #:org.shirakumo.fraf.kandria)

(defvar *effects* (make-hash-table :test 'eq))

(defmethod effect ((name symbol))
  (or (gethash name *effects*)
      (error "No effect named ~s found." name)))

(defmethod (setf effect) (value (name symbol))
  (if value
      (setf (gethash name *effects*) value)
      (remhash name *effects*))
  value)

(defmacro define-effect (name type &body initargs)
  `(setf (effect ',name) (list ',type ,@initargs)))

(defun list-effects ()
  (loop for k being the hash-keys of *effects*
        collect k))

(defclass effect () ())

(defgeneric trigger (effect source &key))

(defmethod trigger ((effect symbol) source &rest args &key &allow-other-keys)
  (apply #'trigger (apply #'make-instance (effect effect)) source args))

(defclass sound-effect (effect)
  ((voice :accessor voice)))

(defmethod initialize-instance :after ((effect sound-effect) &key voice)
  (when voice
    (setf (voice effect) (if (typep voice 'sequence)
                             (alexandria:random-elt voice)
                             voice))))

(defmethod state ((effect sound-effect))
  (if (mixed:done-p (voice effect))
      :inactive
      :active))

(defmethod trigger ((effect sound-effect) source &key)
  (harmony:play (voice effect) :reset T))

(defclass camera-effect (effect)
  ((duration :initarg :duration :initform 20 :accessor duration)
   (intensity :initarg :intensity :initform 3 :accessor intensity)))

(defmethod trigger ((effect camera-effect) source &key)
  (shake-camera :duration (duration effect) :intensity (intensity effect)))

(define-shader-entity shader-effect (located-entity effect)
  ((multiplier :initarg :multiplier :initform 1f0 :accessor multiplier)))

(defmethod trigger :after ((effect shader-effect) (source located-entity) &key location)
  (setf (location effect) (or location (vcopy (location source)))))

(defmethod trigger ((effect shader-effect) source &key)
  (let ((region (region +world+)))
    (enter* effect region)))

(defmethod render :before ((effect shader-effect) (program shader-program))
  (setf (uniform program "multiplier") (multiplier effect)))

(define-class-shader (shader-effect :fragment-shader)
  "uniform float multiplier = 1.0;
out vec4 color;
void main(){
  color = vec4(color.rgb*multiplier, color.a);
}")

(define-shader-entity sprite-effect (lit-animated-sprite shader-effect)
  ((offset :initarg :offset :initform (vec 0 0) :accessor offset)
   (layer-index :initarg :layer-index :initform +base-layer+ :accessor layer-index)
   (particles :initarg :particles :initform () :accessor particles))
  (:default-initargs :sprite-data (asset 'kandria 'effects)))

(defmethod initialize-instance :after ((effect sprite-effect) &key animation)
  (when animation
    (setf (animation effect) (if (typep animation 'sequence)
                                 (alexandria:random-elt animation)
                                 animation))))

(defmethod (setf frame-idx) :after (idx (effect sprite-effect))
  (when (= idx (1- (end (animation effect))))
    (when (slot-boundp effect 'container)
      (leave* effect T))))

(defmethod trigger :after ((effect sprite-effect) source &key direction)
  (setf (direction effect) (or direction (direction source)))
  (incf (vx (location effect)) (* (direction effect) (vx (offset effect))))
  (incf (vy (location effect)) (vy (offset effect)))
  (when (particles effect)
    (apply #'spawn-particles (location effect) (particles effect))))

(define-shader-entity text-effect (shader-effect listener renderable)
  ((text :initarg :text :initform "" :accessor text)
   (font :initarg :font :initform (simple:request-font (unit 'ui-pass T) (setting :display :font)) :accessor font)
   (vertex-data :accessor vertex-data)
   (lifetime :initarg :lifetime :initform 1.0 :accessor lifetime)))

(defmethod layer-index ((effect text-effect)) (+ 2 +base-layer+))

(defmethod trigger :after ((effect text-effect) source &key (text (text effect)))
  (let ((s (view-scale (unit :camera T))))
    (multiple-value-bind (breaks array x- y- x+ y+)
        (org.shirakumo.alloy.renderers.opengl.msdf::compute-text
         (font effect) text (alloy:px-extent 0 0 500 30) (/ s 5) NIL NIL)
      (decf (vx (location effect)) (/ (+ x- x+) 2 s))
      (decf (vy (location effect)) (/ (+ y- y+) 2 s))
      (setf (vertex-data effect) array))))

(defmethod handle ((ev tick) (effect text-effect))
  (incf (vy (location effect)) (* 20 (dt ev)))
  (decf (lifetime effect) (dt ev))
  (when (and (< (lifetime effect) 0f0)
             (slot-boundp effect 'container))
    (leave* effect T)))

(defmethod render ((effect text-effect) (program shader-program))
  (gl:active-texture :texture0)
  (gl:bind-texture :texture-2D (gl-name (org.shirakumo.alloy.renderers.opengl.msdf:atlas (font effect))))
  ;; FIXME: this is horribly inefficient and stupid
  (let* ((renderer (unit 'ui-pass T))
         (shader (org.shirakumo.alloy.renderers.opengl:resource 'org.shirakumo.alloy.renderers.opengl.msdf::text-shader renderer))
         (vbo (org.shirakumo.alloy.renderers.opengl:resource 'org.shirakumo.alloy.renderers.opengl.msdf::text-vbo renderer))
         (vao (org.shirakumo.alloy.renderers.opengl:resource 'org.shirakumo.alloy.renderers.opengl.msdf::text-vao renderer)))
    (org.shirakumo.alloy.renderers.opengl:bind shader)
    (let ((pos (world-screen-pos (location effect)))
          (f1 (/ 2.0 (max 1.0 (width *context*))))
          (f2 (/ 2.0 (max 1.0 (height *context*)))))
      (setf (uniform shader "transform") (mat3 (list f1 0 (+ -1 (* f1 (vx pos)))
                                                     0 f2 (+ -1 (* f2 (vy pos)))
                                                     0 0 1)))
      (setf (uniform shader "color") (vec4 1 1 1 (min (lifetime effect) 1)))
      ;; FIXME: this seems expensive, but maybe it would be worse to statically allocate for each text.
      (org.shirakumo.alloy.renderers.opengl:update-vertex-buffer vbo (vertex-data effect))
      (org.shirakumo.alloy.renderers.opengl:draw-vertex-array vao :triangles (/ (length (vertex-data effect)) 4)))))

(defclass displacement-effect (effect)
  ((displacement-texture :initarg :displacement-texture :initform (// 'kandria 'shockwave) :accessor displacement-texture)))

(defmethod trigger :after ((effect displacement-effect) source &key (strength 0.1))
  (let* ((direction (if (typep source 'facing-entity) (direction source) 1.0))
         (displacer (make-instance 'shockwave :location (location effect)
                                              :texture (displacement-texture effect)
                                              :strength strength
                                              :direction direction)))
    (enter displacer +world+)
    (compile-into-pass displacer NIL (unit 'displacement-render-pass +world+))))

(define-shader-entity step-effect (sprite-effect sound-effect)
  ((offset :initform (vec 0 -7))
   (layer-index :initform 1)))

(defmethod trigger :after ((effect step-effect) source &key)
  (harmony:play (voice effect) :reset T)
  (let ((pitcher (harmony:segment 'pitch (voice effect) NIL)))
    (when pitcher
      ;; FIXME: This causes really bad distortion of the step sound. Possibly the pitch segment
      ;;        is not configured to be high-quality enough?
      (setf (mixed:pitch pitcher) (+ 0.75 (random 0.5))))))

(define-shader-entity dash-effect (displacement-effect rotated-entity sprite-effect sound-effect)
  ((offset :initform (vec 0 8))
   (displacement-texture :initform (// 'kandria 'dashwave))))

(defmethod trigger :after ((effect dash-effect) source &key angle)
  (harmony:play (voice effect) :reset T)
  (setf (angle effect) (or angle
                           (when (v/= 0 (velocity source))
                             (point-angle (velocity source)))
                           (case (direction effect)
                             (-1. PI)
                             (+1. 0f0))
                           0f0))
  (setf (direction effect) 1))

(defmethod apply-transforms progn ((effect dash-effect))
  (translate-by 0 -16 0))

(define-effect slide sprite-effect
  :animation 'wall-slide)

(define-effect step step-effect
  :voice (// 'sound 'step-dirt)
  :animation 'step)

(define-effect jump step-effect
  :voice (// 'sound 'jump)
  :animation 'jump)

(define-effect dash step-effect
  :voice (// 'sound 'dash)
  :animation 'dash)

(define-effect air-dash dash-effect
  :voice (// 'sound 'dash)
  :animation 'air-dash)

(define-effect slash sound-effect
  :voice (// 'sound 'slash))

(define-effect stab sound-effect
  :voice (// 'sound 'hit-zombie))

(define-effect ground-hit step-effect
  :voice (// 'sound 'hit-ground)
  :animation 'hit2
  :offset (vec 38 -8)
  :layer-index 2
  :multiplier 10.0)

(define-effect zombie-notice sound-effect
  :voice (// 'sound 'notice-zombie))

(define-shader-entity explosion-effect (displacement-effect step-effect)
  ((layer-index :initform 2)))

(defmethod trigger :after ((effect explosion-effect) source &key)
  (let ((flash (make-instance 'flash :location (location effect)
                                     :multiplier 1.5
                                     :time-scale 2.0
                                     :bsize (vec 96 96)
                                     :size (vec 96 96)
                                     :offset (vec 112 96))))
    (enter flash +world+)
    (compile-into-pass flash NIL (unit 'lighting-pass +world+)))
  (let* ((distance (expt (vsqrdist2 (location effect) (location (unit 'player T))) 0.75))
         (strength (min 2.0 (/ 300.0 distance))))
    (when (< 0.1 strength)
      (shake-camera :intensity strength))))

(define-effect explosion explosion-effect
  :voice (// 'sound 'die-zombie)
  :animation 'explosion
  :particles (list (make-tile-uvs 8 18 128 128)
                   :amount 16
                   :scale 4 :scale-var 2
                   :dir 90 :dir-var 180
                   :speed 70 :speed-var 100
                   :life 1.0 :life-var 0.5)
  :multiplier 1.5)

(define-effect land step-effect
  :voice (// 'sound 'land-normal)
  :animation 'land-smash
  :layer-index 2)

(define-effect spark sprite-effect
  :animation '(spark1 spark2 spark3)
  :particles (list (make-tile-uvs 8 4 128 128 32)
                   :amount 16
                   :speed 70 :speed-var 30
                   :life 0.3 :life-var 0.2)
  :multiplier 2.0)

(define-effect hit sprite-effect
  :animation '(hit1 hit3)
  :layer-index 2
  :multiplier 10.0)

(define-effect splash sprite-effect
  :animation '(water-splash)
  :layer-index +base-layer+)

(define-asset (kandria sting) mesh
    (make-rectangle 1000000 1))

(define-shader-entity sting-effect (vertex-entity rotated-entity shader-effect)
  ((vertex-array :initform (// 'kandria 'sting))
   (fc :initform 5 :accessor fc)))

(defmethod render :after ((sting sting-effect) program)
  (when (<= (decf (fc sting)) 0)
    (let ((*scene* +world+))
      (leave* sting T))))

(defmethod layer-index ((effect sting-effect)) 2)

(define-class-shader (sting-effect :fragment-shader)
  "out vec4 color;
void main(){
   color = vec4(100,100,100,1);
}")
