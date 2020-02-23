(in-package #:org.shirakumo.fraf.leaf)

(define-subject editor-camera (trial:2d-camera)
  ((zoom :initarg :zoom :initform 1.0 :accessor zoom)))

(defmethod project-view ((camera editor-camera) ev)
  (reset-matrix *view-matrix*)
  (let ((z 4))
    (scale-by z z z)
    (translate-by (+ (vx (location camera)) (/ (width *context*) 2))
                  (+ (vy (location camera)) (/ (height *context*) 2))
                  100 *view-matrix*)))

;; FIXME: create observable animation class so we don't have to futz around with stuff not being
;;        observable or stored in multiple places.

(defclass animation-editor (trial:main)
  ((ui :initform (make-instance 'ui) :reader ui)
   (sprite :accessor sprite)
   (timeline :accessor timeline)
   (animation-edit :accessor animation-edit))
  (:default-initargs :clear-color (vec 0.25 0.25 0.25)
                     :width 1280
                     :height 720
                     :sprite 'player))

(defmethod initialize-instance ((editor animation-editor) &key sprite)
  (call-next-method)
  (load-world (pathname-utils:subdirectory (asdf:system-source-directory 'leaf) "world"))
  (setf (sprite editor) (etypecase sprite
                          (symbol
                           (change-class (make-instance sprite) 'animated-sprite))
                          (animated-sprite sprite)))
  (setf (playback-speed (sprite editor)) 0f0))

(defmethod setup-rendering :after ((editor animation-editor))
  (disable :cull-face :scissor-test :depth-test))

(defmethod setup-scene ((editor animation-editor) scene)
  (let* ((ui (ui editor))
         (focus (make-instance 'alloy:focus-list :focus-parent (alloy:focus-tree ui)))
         (layout (make-instance 'alloy:border-layout :layout-parent (alloy:layout-tree ui)))
         (pane (make-instance 'alloy:sidebar :side :west :focus-parent focus))
         (time (make-instance 'alloy:sidebar :side :south :focus-parent focus))
         (anim (make-instance 'animation-edit :sprite (sprite editor)))
         (line (make-instance 'timeline-edit :sprite (sprite editor))))
    (alloy:enter line time)
    (alloy:enter anim pane)
    (alloy:enter pane layout :place :west :size (alloy:un 200))
    (alloy:enter time layout :place :south :size (alloy:un 200))
    (setf (animation-edit editor) anim)
    (setf (timeline editor) line)
    (alloy:register ui ui)
    (enter ui scene))
  (enter (sprite editor) scene)
  (enter (make-instance 'editor-camera) scene)
  (enter (make-instance 'trial:render-pass) scene))

(defun launch-animation-editor (&rest initargs)
  (apply #'trial:launch 'animation-editor initargs))

(alloy:define-widget animation-edit (alloy:structure)
  ((sprite :initarg :sprite :accessor sprite)
   (animation :initform (make-attack-animation NIL 0 0 0f0 0 0 #()) :accessor animation
              :representation (alloy:combo-set :value-set '(NIL)))))

(defmethod initialize-instance :after ((edit animation-edit) &key)
  (let ((animations (coerce (animations (sprite edit)) 'list)))
    (setf (alloy:value-set (alloy:representation 'animation edit)) animations)
    (setf (animation edit) (first animations))
    (alloy:on (setf alloy:value) (value (alloy:representation 'animation edit))
      (dolist (slot '(start end step next loop))
        (alloy:refresh (slot-value edit slot)))
      (setf (animation (sprite edit)) value)
      (setf (playback-speed (sprite edit)) 0f0))
  (alloy:finish-structure edit (slot-value edit 'layout) (slot-value edit 'focus))))

(defclass attack-combo-item (alloy:combo-item) ())

(defmethod alloy:combo-item ((animation attack-animation) combo)
  (make-instance 'attack-combo-item :value animation))

(defmethod alloy:text ((item attack-combo-item))
  (string (trial::sprite-animation-name (alloy:value item))))

(alloy:define-subcomponent (animation-edit start) ((trial::sprite-animation-start (animation animation-edit)) alloy:wheel))
(alloy:define-subcomponent (animation-edit end) ((trial::sprite-animation-end (animation animation-edit)) alloy:wheel))
(alloy:define-subcomponent (animation-edit step) ((trial::sprite-animation-step (animation animation-edit)) alloy:wheel :step 0.01))
(alloy:define-subcomponent (animation-edit next) ((trial::sprite-animation-next (animation animation-edit)) alloy:wheel))
(alloy:define-subcomponent (animation-edit loop) ((trial::sprite-animation-loop (animation animation-edit)) alloy:wheel))

(alloy:define-subcontainer (animation-edit layout)
    (alloy:grid-layout :col-sizes '(75 T) :row-sizes '(30))
  "Anim" animation
  "Start" start
  "End" end
  "Step" step
  "Next" next
  "Loop to" loop)

(alloy:define-subcontainer (animation-edit focus)
    (alloy:focus-list)
  animation start end step next loop)

(defclass timeline-edit (alloy:structure)
  ((sprite :initarg :sprite :accessor sprite)))

(defmethod initialize-instance :after ((edit timeline-edit) &key sprite)
  (let* ((frames (make-instance 'alloy:horizontal-linear-layout
                                :cell-margins (alloy:margins)
                                :min-size (alloy:size 100 300)))
         (focus (make-instance 'alloy:focus-list))
         (layout (make-instance 'alloy:grid-layout :col-sizes '(100 T) :row-sizes '(T)))
         (scroll (make-instance 'alloy:scroll-view :scroll :x :focus focus :layout frames)))
    (alloy:build-ui
     (alloy:vertical-linear-layout :cell-margins (alloy:margins 1) :layout-parent layout
       "Frame" "Velocity" "Hurtbox" "Damage" "Interruptable" "Invincible" "Cancelable"))
    (alloy:enter scroll layout)
    (loop for animation across (animations sprite)
          do (loop for i from (trial::sprite-animation-start animation)
                   below (trial::sprite-animation-end animation)
                   for frame = (make-instance 'frame-edit :animation animation :frame i)
                   do (alloy:enter frame frames)
                      (alloy:enter frame focus)
                      (let ((animation animation))
                        (alloy:on alloy:activate ((alloy:representation 'frame-idx frame))
                          (setf (animation sprite) animation)
                          (setf (frame sprite) (alloy:value alloy:observable))
                          (setf (playback-speed sprite) 0f0)))))
    (alloy:finish-structure edit layout (alloy:focus-element scroll))))

(alloy:define-widget frame-edit (alloy:structure)
  ((frame-idx :initarg :frame :representation (alloy:button) :reader frame-idx)
   (animation :initarg :animation :reader animation)))

(defmethod initialize-instance :after ((edit frame-edit) &key)
  (alloy:finish-structure edit (slot-value edit 'layout) (slot-value edit 'focus)))

(defmethod frame-data ((widget frame-edit))
  (svref (attack-animation-frame-data (animation widget))
         (- (frame-idx widget) (trial::sprite-animation-start (animation widget)))))

(alloy:define-subcomponent (frame-edit velocity) ((frame-velocity (frame-data frame-edit)) trial-alloy::vec2))
(alloy:define-subcomponent (frame-edit hurtbox) ((frame-hurtbox (frame-data frame-edit)) trial-alloy::vec4))
(alloy:define-subcomponent (frame-edit damage) ((frame-damage (frame-data frame-edit)) alloy:wheel))
(alloy:define-subcomponent (frame-edit interruptable) ((interruptable-p (frame-data frame-edit)) alloy:checkbox))
(alloy:define-subcomponent (frame-edit invincible) ((invincible-p (frame-data frame-edit)) alloy:checkbox))
(alloy:define-subcomponent (frame-edit cancelable) ((cancelable-p (frame-data frame-edit)) alloy:checkbox))

(alloy:define-subcontainer (frame-edit layout)
    (alloy:vertical-linear-layout :cell-margins (alloy:margins 1))
  frame-idx velocity hurtbox damage interruptable invincible cancelable)

(alloy:define-subcontainer (frame-edit focus)
    (alloy:focus-list)
  frame-idx velocity hurtbox damage interruptable invincible cancelable)
