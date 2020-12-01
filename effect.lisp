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

(defmethod trigger ((effect symbol) source &rest args)
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

(define-shader-entity shader-effect (located-entity)
  ())

(defmethod trigger :after ((effect shader-effect) (source located-entity) &key location)
  (setf (location effect) (or location (vcopy (location source)))))

(defmethod trigger ((effect shader-effect) source &key)
  (let ((region (region +world+)))
    (enter effect region)
    (compile-into-pass effect region +world+)))

(define-shader-entity sprite-effect (lit-animated-sprite shader-effect)
  ((offset :initarg :offset :initform (vec 0 0) :accessor offset))
  (:default-initargs :sprite-data (asset 'kandria 'effects)))

(defmethod initialize-instance :after ((effect sprite-effect) &key animation)
  (when animation
    (setf (animation effect) (if (typep animation 'sequence)
                                 (alexandria:random-elt animation)
                                 animation))))

(defmethod (setf frame-idx) :after (idx (effect sprite-effect))
  (when (= idx (1- (end (animation effect))))
    (when (slot-boundp effect 'container)
      (leave effect T)
      (remove-from-pass effect +world+))))

(defmethod trigger :after ((effect sprite-effect) (source facing-entity) &key direction)
  (setf (direction effect) (or direction (direction source)))
  (nv+ (location effect) (offset effect)))

(define-shader-entity text-effect (shader-effect listener renderable)
  ((text :initarg :text :initform "" :accessor text)
   (font :initarg :font :initform (simple:request-font (unit 'ui-pass T) "PromptFont") :accessor font)
   (vertex-data :accessor vertex-data)
   (lifetime :initarg :lifetime :initform 1.0 :accessor lifetime)))

(defmethod trigger :after ((effect text-effect) source &key (text (text effect)))
  (let ((s (view-scale (unit :camera T))))
    (multiple-value-bind (breaks array x- y- x+ y+)
        (org.shirakumo.alloy.renderers.opengl.msdf::compute-text
         (font effect) text (alloy:px-extent 0 0 500 30) (/ s 5) NIL)
      (decf (vx (location effect)) (/ (+ x- x+) 2 s))
      (decf (vy (location effect)) (/ (+ y- y+) 2 s))
      (setf (vertex-data effect) array))))

(defmethod handle ((ev tick) (effect text-effect))
  (incf (vy (location effect)) (* 20 (dt ev)))
  (decf (lifetime effect) (dt ev))
  (when (and (< (lifetime effect) 0f0)
             (slot-boundp effect 'container))
    (leave effect T)
    (remove-from-pass effect +world+)))

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

(define-shader-entity step-effect (sprite-effect sound-effect)
  ((offset :initform (vec 0 -7))))

(defmethod layer-index ((effect step-effect)) 1)

(defmethod trigger :after ((effect step-effect) source &key)
  (harmony:play (voice effect) :reset T)
  (let ((pitcher (harmony:segment 'pitch (voice effect) NIL)))
    (when pitcher
      ;; FIXME: This causes really bad distortion of the step sound. Possibly the pitch segment
      ;;        is not configured to be high-quality enough?
      (setf (mixed:pitch pitcher) (+ 0.75 (random 0.5))))))

(define-effect step step-effect
  :voice (// 'kandria 'step)
  :animation 'step)

(define-effect jump step-effect
  :voice (// 'kandria 'jump)
  :animation 'jump)

(define-effect dash step-effect
  :voice (// 'kandria 'dash)
  :animation 'dash)

(define-effect slash sound-effect
  :voice (// 'kandria 'slash))

(define-effect stab sound-effect
  :voice (// 'kandria 'stab))

(define-effect ground-hit sound-effect
  :voice (// 'kandria 'ground-hit))

(define-effect zombie-notice sound-effect
  :voice (// 'kandria 'zombie-notice))

(define-effect explosion step-effect
  :voice (// 'kandria 'explosion)
  :animation 'explosion32)
