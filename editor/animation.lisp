(in-package #:org.shirakumo.fraf.leaf)

(defclass animation-editor (trial:main)
  ((ui :initform (make-instance 'ui) :reader ui)
   (sprite :accessor sprite)
   (timeline :accessor timeline)
   (animation-edit :accessor animation-edit))
  (:default-initargs :clear-color (vec 0.25 0.25 0.25)))

(defmethod initialize-instance ((editor animation-editor) &key sprite)
  (call-next-method)
  (setf (sprite editor) (etypecase sprite
                          (symbol (make-instance sprite))
                          (animated-sprite sprite))))

(defmethod setup-scene ((editor animation-editor) scene)
  (let* ((ui (ui editor))
         (focus (make-instance 'alloy:focus-list :focus-parent (alloy:focus-tree ui)))
         (layout (make-instance 'alloy:border-layout :layout-parent (alloy:layout-tree ui)))
         (pane (make-instance 'alloy:sidebar :side :west :layout-parent layout :focus-parent focus))
         (time (make-instance 'alloy:sidebar :side :south :layout-parent layout :focus-parent focus))
         (anim (make-instance 'animation-edit :sprite (sprite editor)))
         (line (make-instance 'timeline-edit :sprite (sprite editor))))
    (alloy:enter line time)
    (alloy:enter anim pane)
    (setf (animation-edit editor) anim)
    (setf (timeline editor) line)
    (alloy:register ui ui)
    (enter ui scene))
  (enter (make-instance '2d-camera) scene)
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
    (setf (animation edit) (first animations)))
  (alloy:finish-structure edit (slot-value edit 'layout) (slot-value edit 'focus)))

(alloy:define-subcomponent (animation-edit start) ((trial::sprite-animation-start (animation animation-edit)) alloy:wheel))
(alloy:define-subcomponent (animation-edit end) ((trial::sprite-animation-end (animation animation-edit)) alloy:wheel))
(alloy:define-subcomponent (animation-edit step) ((trial::sprite-animation-step (animation animation-edit)) alloy:wheel))
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
  (let* ((layout (make-instance 'alloy:horizontal-linear-layout
                                :cell-margins (alloy:margins)
                                :min-size (alloy:size 100 300)))
         (focus (make-instance 'alloy:focus-list))
         (scroll (make-instance 'alloy:scroll-view :scroll :x :focus focus :layout layout :focus focus)))
    (loop for animation across (animations sprite)
          do (loop for i from (trial::sprite-animation-start animation)
                   below (trial::sprite-animation-end animation)
                   for frame = (make-instance 'frame-edit :animation animation :frame i)
                   do (alloy:enter frame layout)
                      (alloy:enter frame focus)))
    (alloy:finish-structure edit (alloy:layout-element scroll) (alloy:focus-element scroll))))

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
