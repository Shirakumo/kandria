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

(defmethod trigger ((effect effect) source &key))

(defmethod trigger ((effect symbol) source &rest args &key &allow-other-keys)
  (apply #'trigger (apply #'make-instance (effect effect)) source args))

(defclass closure-effect (effect)
  ((closure :initarg :closure :accessor closure)))

(defmethod trigger ((effect closure-effect) source &rest args)
  (apply (closure effect) source args))

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

(defmethod trigger :after ((effect sound-effect) source &key)
  (harmony:play (voice effect) :reset T :location (etypecase source
                                                    (located-entity (location source))
                                                    (vec2 source)
                                                    (T NIL))))

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
   (particles :initarg :particles :initform () :accessor particles)
   (direction :initform NIL))
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
  (setf (direction effect) (or direction (direction effect) (direction source)))
  (incf (vx (location effect)) (* (direction effect) (vx (offset effect))))
  (incf (vy (location effect)) (vy (offset effect)))
  (when (particles effect)
    (apply #'spawn-particles (location effect) (particles effect))))

(define-shader-entity text-effect (located-entity effect listener renderable)
  ((text :initarg :text :initform "" :accessor text)
   (font :initarg :font :initform (simple:request-font (unit 'ui-pass T) (setting :display :font)) :accessor font)
   (vertex-data :accessor vertex-data)
   (lifetime :initarg :lifetime :initform 1.0 :accessor lifetime)))

(defmethod layer-index ((effect text-effect)) (+ 2 +base-layer+))

(defmethod trigger ((effect text-effect) source &key (text (text effect)) location)
  (setf (location effect) (or location (vcopy (location source))))
  (let ((s (view-scale (camera +world+))))
    (multiple-value-bind (breaks array seq x- y- x+ y+)
        (org.shirakumo.alloy.renderers.opengl.msdf::compute-text
         (font effect) text (alloy:px-extent 0 0 500 30) (/ s 5) NIL NIL)
      (declare (ignore breaks seq))
      (decf (vx (location effect)) (/ (+ x- x+) 2 s))
      (decf (vy (location effect)) (/ (+ y- y+) 2 s))
      (setf (vertex-data effect) array)))
  (let ((region (region +world+)))
    (enter* effect region)))

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
      (org.shirakumo.alloy.renderers.opengl:draw-vertex-array vao :triangles 0 (truncate (length (vertex-data effect)) 10)))))

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

(define-shader-entity basic-effect (sprite-effect sound-effect)
  ((offset :initform (vec 0 -7))
   (layer-index :initform 1)))

(define-shader-entity step-effect (sprite-effect)
  ((offset :initform (vec 0 -7))
   (layer-index :initform 1)
   (voice :initarg :voice :accessor voice)))

(defun ground-bank (moving)
  (when (typep (svref (collisions moving) 2) 'block)
    (let* ((chunk (chunk moving))
           (layer (aref (layers chunk) +base-layer+))
           (banks (tile->bank (generator (albedo chunk)))))
      (%with-layer-xy (layer (tv- (location moving) #.(vec 0 16)))
        (let* ((pos (* 2 (+ x (* y (truncate (vx (size layer)))))))
               (int (+ (ash (aref (pixel-data layer) pos) 8)
                       (aref (pixel-data layer) (1+ pos)))))
          (gethash int banks))))))

(defmethod trigger :after ((effect step-effect) source &key)
  (let* ((bank (ground-bank source))
         (voices (voice effect))
         (voice (alexandria:random-elt (or (cdr (assoc bank voices))
                                           (cdr (first voices))))))
    (harmony:play voice :reset T)))

(define-shader-entity dash-effect (displacement-effect rotated-entity sprite-effect sound-effect)
  ((offset :initform (vec 0 8))
   (displacement-texture :initform (// 'kandria 'dashwave))
   (angle :initform NIL :initarg :angle :accessor angle)))

(defmethod trigger :after ((effect dash-effect) source &key angle)
  (setf (angle effect) (or angle (angle effect)
                           (when (v/= 0 (velocity source))
                             (point-angle (velocity source)))
                           (case (direction effect)
                             (-1. PI)
                             (+1. 0f0))
                           0f0))
  (let ((flash (make-instance 'flash :location (location effect)
                                     :multiplier 1.0
                                     :time-scale 1.0
                                     :bsize (vec 48 48)
                                     :size (vec 96 96)
                                     :offset (vec 0 48))))
    (enter flash +world+)
    (compile-into-pass flash NIL (unit 'lighting-pass +world+))))

(defmethod apply-transforms progn ((effect dash-effect))
  (translate-by 0 -16 0))

(define-effect slide sprite-effect
  :animation 'wall-slide)

(define-effect step step-effect
  :voice `((:dirt ,(// 'sound 'step-dirt-1)
                  ,(// 'sound 'step-dirt-2)
                  ,(// 'sound 'step-dirt-3)
                  ,(// 'sound 'step-dirt-4))
           (:sand ,(// 'sound 'step-sand-1)
                  ,(// 'sound 'step-sand-2)
                  ,(// 'sound 'step-sand-3)
                  ,(// 'sound 'step-sand-4))
           (:rocks ,(// 'sound 'step-rocks-1)
                   ,(// 'sound 'step-rocks-2)
                   ,(// 'sound 'step-rocks-3)
                   ,(// 'sound 'step-rocks-4))
           (:metal ,(// 'sound 'step-metal-1)
                   ,(// 'sound 'step-metal-2)
                   ,(// 'sound 'step-metal-3)
                   ,(// 'sound 'step-metal-4))
           (:concrete ,(// 'sound 'step-concrete-1)
                      ,(// 'sound 'step-concrete-2)
                      ,(// 'sound 'step-concrete-3)
                      ,(// 'sound 'step-concrete-4))
           (:grass ,(// 'sound 'step-tall-grass-1)
                   ,(// 'sound 'step-tall-grass-2)
                   ,(// 'sound 'step-tall-grass-3)
                   ,(// 'sound 'step-tall-grass-4)))
  :animation 'step)

(define-effect jump basic-effect
  :voice (// 'sound 'player-jump)
  :animation 'jump)

(define-effect dash dash-effect
  :voice (// 'sound 'player-dash)
  :animation 'dash
  :angle 0.0)

(define-effect air-dash dash-effect
  :voice (// 'sound 'player-dash)
  :animation 'air-dash
  :direction 1)

(define-effect enter-passage sound-effect
  :voice (// 'sound 'player-enter-passage))

(define-effect slash sound-effect
  :voice (list (// 'sound 'sword-small-slash-1)
               (// 'sound 'sword-small-slash-2)
               (// 'sound 'sword-small-slash-3)))

(define-effect big-slash sound-effect
  :voice (// 'sound 'sword-big-slash))

(define-effect jab sound-effect
  :voice (// 'sound 'sword-jab))

(define-effect swing sound-effect
  :voice (list (// 'sound 'sword-rotating-swing-1)
               (// 'sound 'sword-rotating-swing-2)))

(define-effect zombie-damage sound-effect
  :voice (// 'sound 'zombie-damage))

(define-effect wolf-damage sound-effect
  :voice (list (// 'sound 'wolf-damage-1)
               (// 'sound 'wolf-damage-2)))

(define-effect wolf-attack sound-effect
  :voice (// 'sound 'wolf-attack))

(define-effect wolf-die sound-effect
  :voice (// 'sound 'wolf-die))

(define-effect drone-attack sound-effect
  :voice (list (// 'sound 'drone-attack-001)
               (// 'sound 'drone-attack-002)))

(define-effect drone-notice sound-effect
  :voice (// 'sound 'drone-notice))

(define-effect drone-damage sound-effect
  :voice (// 'sound 'drone-damage))

(define-effect drone-die sound-effect
  :voice (// 'sound 'drone-die))

(define-effect pickup sound-effect
  :voice (// 'sound 'player-pick-up))

(define-effect ground-hit-soft sound-effect
  :voice (// 'sound 'sword-hit-ground-soft))

(define-effect player-damage sound-effect
  :voice (// 'sound 'player-damage))

(define-effect ground-hit basic-effect
  :voice (// 'sound 'sword-hit-ground-hard)
  :animation 'hit2
  :offset (vec 38 -8)
  :layer-index 2
  :multiplier 10.0)

(define-effect zombie-notice sound-effect
  :voice (// 'sound 'zombie-notice))

(define-shader-entity explosion-effect (displacement-effect basic-effect)
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
  (let* ((distance (expt (vsqrdistance (location effect) (location (unit 'player T))) 0.75))
         (strength (min 2.0 (/ 300.0 distance))))
    (when (< 0.1 strength)
      (shake-camera :intensity strength))))

(define-effect explosion explosion-effect
  :voice (// 'sound 'zombie-die)
  :animation 'explosion
  :particles (list (make-tile-uvs 8 18 128 128)
                   :amount 16
                   :scale 4 :scale-var 2
                   :dir 90 :dir-var 180
                   :speed 70 :speed-var 100
                   :life 1.0 :life-var 0.5)
  :multiplier 1.5)

(define-effect land sprite-effect
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
    (leave* sting T)))

(defmethod layer-index ((effect sting-effect)) 2)

(define-class-shader (sting-effect :fragment-shader)
  "out vec4 color;
void main(){
   color = vec4(100,100,100,1);
}")

(define-effect evade closure-effect
  :closure (lambda (source &rest args)
             (declare (ignore args))
             (harmony:play (// 'sound 'player-evade))
             (let ((spread (v* (bsize source) 2)))
               (spawn-lights (location source) (make-tile-uvs 8 6 128 128 48)
                             :amount 64 :multiplier 2.0
                             :scale 1.2 :scale-var 0
                             :dir 180 :dir-var 0
                             :life 0.2 :life-var 0.2
                             :speed 0 :speed-var 80
                             :spread spread
                             :gravity (vec 0 0)))))

(define-effect heavy-sting closure-effect
  :closure (lambda (source &rest args)
             (declare (ignore args))
             (let ((flash (make-instance 'flash :location (nv+ (vec (* (direction source) 2) 11)
                                                               (location source))
                                                :multiplier 2.0
                                                :time-scale 3.0
                                                :bsize (vec 24 24)
                                                :size (vec 48 48)
                                                :offset (vec 64 144))))
               (enter flash +world+)
               (compile-into-pass flash NIL (unit 'lighting-pass +world+)))))

(define-effect climb closure-effect
  :closure (lambda (source &rest args)
             (if (typep (interactable source) 'rope)
                 (harmony:play (alexandria:random-elt
                                (list (// 'sound 'rope-climb-1)
                                      (// 'sound 'rope-climb-2)
                                      (// 'sound 'rope-climb-3)))
                               :reset T))))
