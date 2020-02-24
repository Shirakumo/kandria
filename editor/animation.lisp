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

(define-shader-subject editor-sprite (alloy:observable-object animated-sprite)
  ())

(defclass animation-editor (trial:main)
  ((ui :initform (make-instance 'ui) :reader ui)
   (file :initarg :file :accessor file)
   (sprite :accessor sprite)
   (timeline :accessor timeline)
   (animation-edit :accessor animation-edit))
  (:default-initargs :clear-color (vec 0.25 0.25 0.25)
                     :width 1280
                     :height 720
                     :file "player-animations.lisp"))

(defmethod initialize-instance ((editor animation-editor) &key file)
  (call-next-method)
  (load-world (pathname-utils:subdirectory (asdf:system-source-directory 'leaf) "world"))
  (setf (sprite editor) (make-instance 'editor-sprite :animations file))
  (setf (playback-speed (sprite editor)) 0f0))

(defmethod setup-rendering :after ((editor animation-editor))
  (disable :cull-face :scissor-test :depth-test))

(defmethod setup-scene ((editor animation-editor) scene)
  (enter (sprite editor) scene)
  (let* ((ui (ui editor))
         (focus (make-instance 'alloy:focus-list :focus-parent (alloy:focus-tree ui)))
         (layout (make-instance 'alloy:border-layout :layout-parent (alloy:layout-tree ui)))
         (pane (make-instance 'alloy:sidebar :side :west :focus-parent focus :layout-parent layout))
         (time (make-instance 'alloy:sidebar :side :south :focus-parent focus :layout-parent layout))
         (anim (make-instance 'animation-edit :sprite (sprite editor)))
         (line (make-instance 'timeline-edit :sprite (sprite editor))))
    (alloy:enter line time)
    (alloy:enter anim pane)
    (setf (animation-edit editor) anim)
    (setf (timeline editor) line)
    (alloy:register ui ui)
    (enter ui scene))
  (enter (make-instance 'editor-camera :location (vec 0 100)) scene)
  (enter (make-instance 'trial:render-pass) scene))

(defun launch-animation-editor (&rest initargs)
  (apply #'trial:launch 'animation-editor initargs))

(alloy:define-widget animation-edit (alloy:structure)
  ((sprite :initarg :sprite :accessor sprite)))

(defmethod initialize-instance :after ((edit animation-edit) &key)
  (alloy:on (setf alloy:value) (value (slot-value edit 'animation))
    (dolist (slot '(start end step next loop))
      (alloy:refresh (slot-value edit slot)))
    (setf (playback-speed (sprite edit)) 0f0))
  (alloy:finish-structure edit (slot-value edit 'layout) (slot-value edit 'focus)))

(defclass attack-combo-item (alloy:combo-item) ())

(defmethod alloy:combo-item ((animation attack-animation) combo)
  (make-instance 'attack-combo-item :value animation))

(defmethod alloy:text ((item attack-combo-item))
  (string (trial::sprite-animation-name (alloy:value item))))

(defmethod animation ((edit animation-edit))
  (animation (sprite edit)))

(alloy:define-subcomponent (animation-edit animation) ((slot-value (sprite animation-edit) 'animation) alloy:combo-set :value-set (animations (sprite animation-edit))))
(alloy:define-subcomponent (animation-edit start) ((trial::sprite-animation-start (animation animation-edit)) alloy:wheel))
(alloy:define-subcomponent (animation-edit end) ((trial::sprite-animation-end (animation animation-edit)) alloy:wheel))
(alloy:define-subcomponent (animation-edit step) ((trial::sprite-animation-step (animation animation-edit)) alloy:wheel :step 0.01))
(alloy:define-subcomponent (animation-edit next) ((trial::sprite-animation-next (animation animation-edit)) alloy:wheel))
(alloy:define-subcomponent (animation-edit loop) ((trial::sprite-animation-loop (animation animation-edit)) alloy:wheel))
(alloy:define-subbutton (animation-edit save) ("Save")
  (with-open-file (stream (file animation-edit)
                          :direction :output
                          :if-exists :supersede)
    (write-animation (sprite animation-edit) stream)))

(alloy:define-subcontainer (animation-edit layout)
    (alloy:grid-layout :col-sizes '(75 100) :row-sizes '(30))
  "Anim" animation
  "Start" start
  "End" end
  "Step" step
  "Next" next
  "Loop to" loop
  "" save)

(alloy:define-subcontainer (animation-edit focus)
    (alloy:focus-list)
  animation start end step next loop save)

(defclass timeline-edit (alloy:structure)
  ((sprite :initarg :sprite :accessor sprite)))

(defmethod initialize-instance :after ((edit timeline-edit) &key sprite)
  (let* ((frames (make-instance 'alloy:horizontal-linear-layout
                                :cell-margins (alloy:margins)
                                :min-size (alloy:size 100 300)))
         (focus (make-instance 'alloy:focus-list))
         (layout (make-instance 'alloy:grid-layout :col-sizes '(100 T) :row-sizes '(300)))
         (scroll (make-instance 'alloy:scroll-view :scroll :x :focus focus :layout frames)))
    
    (alloy:build-ui
     (alloy:vertical-linear-layout :cell-margins (alloy:margins 1) :layout-parent layout
       "Frame" "Hurtbox" "Velocity" "Knockback" "Damage" "Stun" "Interruptable" "Invincible" "Cancelable"))
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

(alloy:define-subcomponent (frame-edit hurtbox) ((frame-hurtbox (frame-data frame-edit)) trial-alloy::vec4))
(alloy:define-subcomponent (frame-edit velocity) ((frame-velocity (frame-data frame-edit)) trial-alloy::vec2))
(alloy:define-subcomponent (frame-edit knockback) ((frame-knockback (frame-data frame-edit)) trial-alloy::vec2))
(alloy:define-subcomponent (frame-edit damage) ((frame-damage (frame-data frame-edit)) alloy:wheel))
(alloy:define-subcomponent (frame-edit stun) ((frame-stun (frame-data frame-edit)) alloy:wheel))
(alloy:define-subcomponent (frame-edit interruptable) ((interruptable-p (frame-data frame-edit)) alloy:checkbox))
(alloy:define-subcomponent (frame-edit invincible) ((invincible-p (frame-data frame-edit)) alloy:checkbox))
(alloy:define-subcomponent (frame-edit cancelable) ((cancelable-p (frame-data frame-edit)) alloy:checkbox))

(alloy:define-subcontainer (frame-edit layout)
    (alloy:vertical-linear-layout :cell-margins (alloy:margins 1))
  frame-idx hurtbox velocity knockback damage stun interruptable invincible cancelable)

(alloy:define-subcontainer (frame-edit focus)
    (alloy:focus-list)
  frame-idx hurtbox velocity knockback damage stun interruptable invincible cancelable)
