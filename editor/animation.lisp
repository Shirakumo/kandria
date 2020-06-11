(in-package #:org.shirakumo.fraf.leaf)

(define-subject editor-camera (trial:2d-camera)
  ((zoom :initarg :zoom :initform 4.0 :accessor zoom)))

(defmethod project-view ((camera editor-camera) ev)
  (reset-matrix *view-matrix*)
  (let ((z (zoom camera)))
    (translate-by (+ (vx (location camera)) (/ (width *context*) 2))
                  (+ (vy (location camera)) (/ (height *context*) 2))
                  100 *view-matrix*)
    (scale-by z z z *view-matrix*)))

(define-shader-entity rectangle (vertex-entity colored-entity sized-entity)
  ((vertex-array :initform (asset 'leaf '1x))
   (color :initform (vec 1 0 0 0.5))))

(defmethod paint :before ((rectangle rectangle) target)
  (let ((size (v* 2 (bsize rectangle))))
    (translate-by (/ (vx size) -2) (/ (vy size) -2) 0)
    (scale (vxy_ size))))

(define-shader-subject editor-sprite (alloy:observable-object animated-sprite)
  ((flare:name :initform 'sprite)
   (hurtbox :initform (make-instance 'rectangle) :reader hurtbox)
   (start-pos :initform NIL :accessor start-pos)
   (sprite-data :initarg :sprite-data :accessor sprite-data)))

(defmethod register-object-for-pass :after ((pass per-object-pass) (sprite editor-sprite))
  (register-object-for-pass pass (hurtbox sprite)))

(defun compute-frame-location (animation frame-idx)
  (let ((location (vec 0 0))
        (frame (svref (frames animation) frame-idx)))
    (loop for i from (start animation) below frame-idx
          for frame = (svref (frames animation) i)
          for vel = (velocity frame)
          for offset = (v* vel (duration frame) 100)
          do (nv+ location offset))
    (nv+ location (v* (velocity frame)
                      (duration frame)
                      100 0.5))
    location))

(defmethod paint :around ((sprite editor-sprite) pass)
  ;; FIXME: move player according to animation velocity
  ;; FIXME: show sprite extents
  (translate (vxy_ (compute-frame-location (animation sprite) (frame-idx sprite))))
  (with-pushed-matrix ()
    (translate-by 0 (vy (bsize sprite)) 0)
    (call-next-method))
  (let ((frame (hurtbox (frame sprite)))
        (hurtbox (hurtbox sprite)))
    (setf (bsize hurtbox) (vzw frame))
    (setf (location hurtbox) (vxy frame))
    (incf (vy (location hurtbox)) (vy (bsize sprite)))
    (paint hurtbox pass)))

(defun to-world-pos (pos)
  (let ((vec (vcopy pos))
        (sprite (unit 'sprite (scene (handler *context*))))
        (camera (unit :camera (scene (handler *context*)))))
    (decf (vx vec) (+ (vx (location camera)) (/ (width *context*) 2)))
    (decf (vy vec) (+ (vy (location camera)) (/ (height *context*) 2)))
    (vapplyf (nv/ vec (zoom camera)) floor)
    (decf (vy vec) (vy (bsize sprite)))
    vec))

(defun update-frame (sprite start end)
  (let* ((hurtbox (hurtbox (frame sprite)))
         (bsize (nvabs (nv/ (v- end start) 2)))
         (loc (nv- (v+ start bsize) (compute-frame-location (animation sprite) (frame-idx sprite)))))
    (setf (vx hurtbox) (vx loc))
    (setf (vy hurtbox) (vy loc))
    (setf (vz hurtbox) (vx bsize))
    (setf (vw hurtbox) (vy bsize))))

(define-handler (editor-sprite mouse-press) (ev pos button)
  (when (eql button :middle)
    (setf (start-pos editor-sprite) (to-world-pos pos))
    (update-frame editor-sprite (to-world-pos pos) (to-world-pos pos))))

(define-handler (editor-sprite mouse-release) (ev pos button)
  (when (eql button :middle)
    (update-frame editor-sprite (start-pos editor-sprite) (to-world-pos pos))
    (setf (start-pos editor-sprite) NIL)))

(define-handler (editor-sprite mouse-move) (ev pos button)
  (when (start-pos editor-sprite)
    (update-frame editor-sprite (start-pos editor-sprite) (to-world-pos pos))))

(defmethod switch-animation ((sprite editor-sprite) animation)
  (setf (frame-idx sprite) (start (animation sprite)))
  (setf (clock sprite) 0.0d0))

(defclass animation-editor-ui (ui)
  ((editor :initarg :editor :accessor editor)))

(defmethod alloy:handle ((event alloy:key-up) (ui animation-editor-ui))
  ;; FIXME: refresh frame representation in editor on change
  (let* ((editor (editor ui))
         (sprite (sprite editor))
         (frame (frame sprite)))
    (restart-case (call-next-method)
      (alloy:decline ()
        (case (alloy:key event)
          (:space
           (if (= (playback-speed sprite) 0f0)
               (setf (playback-speed sprite) 1f0)
               (setf (playback-speed sprite) 0f0)))
          (:delete
           (clear frame))
          ((:a :n :left)
           (decf (frame-idx sprite))
           (when (find :shift (alloy:modifiers event))
             (transfer-frame (frame sprite) frame)))
          ((:d :p :right)
           (incf (frame-idx sprite))
           (when (find :shift (alloy:modifiers event))
             (transfer-frame (frame sprite) frame)))
          (T (alloy:decline)))))))

(defclass animation-editor (trial:main)
  ((ui :accessor ui)
   (sprite :accessor sprite)
   (timeline :accessor timeline)
   (animation-edit :accessor animation-edit))
  (:default-initargs :clear-color (vec 0.25 0.25 0.25)
                     :width 1280
                     :height 720
                     :sprite-data (asset 'world 'player)))

(defmethod initialize-instance ((editor animation-editor) &key sprite-data)
  (call-next-method)
  (load-animations (input* sprite-data) sprite-data)
  (setf (ui editor) (make-instance 'animation-editor-ui :editor editor))
  (setf (sprite editor) (make-instance 'editor-sprite :sprite-data sprite-data))
  (setf (playback-speed (sprite editor)) 0f0))

(defmethod setup-rendering :after ((editor animation-editor))
  (disable :cull-face :scissor-test :depth-test))

(defmethod setup-scene ((editor animation-editor) scene)
  (enter (make-instance 'vertex-entity :vertex-array (asset 'trial 'trial::2d-axes)) scene)
  (enter (sprite editor) scene)
  (let* ((ui (ui editor))
         (focus (make-instance 'alloy:focus-list :focus-parent (alloy:focus-tree ui)))
         (layout (make-instance 'alloy:border-layout :layout-parent (alloy:layout-tree ui)))
         (pane (make-instance 'alloy:sidebar :side :west :focus-parent focus :layout-parent layout))
         (time (make-instance 'alloy:sidebar :side :south :focus-parent focus :layout-parent layout))
         (anim (make-instance 'animation-edit :sprite (sprite editor)))
         (line (make-instance 'timeline-edit :sprite (sprite editor))))
    (setf (alloy:bounds pane) (alloy:extent 0 0 200 0))
    (setf (alloy:bounds time) (alloy:extent 0 0 0 300))
    (alloy:enter line time)
    (alloy:enter anim pane)
    (setf (animation-edit editor) anim)
    (setf (timeline editor) line)
    (alloy:register ui ui)
    (enter ui scene))
  (enter (make-instance 'editor-camera :location (vec -200 70)) scene)
  (enter (make-instance 'trial:render-pass) scene))

(defun launch-animation-editor (&rest initargs)
  (setf +world+ (load-world (pathname-utils:subdirectory (asdf:system-source-directory 'leaf) "world")))
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

(defmethod alloy:combo-item ((animation sprite-animation) combo)
  (make-instance 'attack-combo-item :value animation))

(defmethod alloy:text ((item attack-combo-item))
  (string (name (alloy:value item))))

(defmethod animation ((edit animation-edit))
  (animation (sprite edit)))

(alloy:define-subcomponent (animation-edit animation) ((slot-value (sprite animation-edit) 'animation) alloy:combo-set :value-set (animations (sprite animation-edit))))
(alloy:define-subcomponent (animation-edit next) ((next-animation (animation animation-edit)) alloy:combo-set :value-set (list* NIL (map 'list #'name (animations (sprite animation-edit))))))
(alloy:define-subcomponent (animation-edit loop) ((loop-to (animation animation-edit)) alloy:wheel))
(alloy:define-subbutton (animation-edit save) ("Save")
  (with-open-file (stream (input* (sprite-data (sprite animation-edit)))
                          :direction :output
                          :if-exists :supersede)
    (write-animation (sprite animation-edit) stream)))

(alloy:define-subcontainer (animation-edit layout)
    (alloy:grid-layout :col-sizes '(75 T) :row-sizes '(30))
  "Anim" animation
  "Next" next
  "Loop to" loop
  "" save)

(alloy:define-subcontainer (animation-edit focus)
    (alloy:focus-list)
  animation next loop save)

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
       "Frame" "Hurtbox" "Velocity" "Knockback" "Damage" "Stun" "Interruptable" "Invincible" "Cancelable"))
    (alloy:enter scroll layout)
    (loop for i from 0 below (length (frames sprite))
          do (let* ((animation (loop for animation in (animations sprite)
                                     do (when (<= (start animation) i (end frame))
                                          (return animation))))
                    (frame (make-instance 'frame-edit :animation animation :frame i)))
               (alloy:enter frame frames)
               (alloy:enter frame focus)
               (alloy:on alloy:activate ((alloy:representation 'frame-idx frame))
                 (setf (animation sprite) animation)
                 (setf (frame sprite) (alloy:value alloy:observable))
                 (setf (playback-speed sprite) 0f0))))
    (alloy:finish-structure edit layout (alloy:focus-element scroll))))

(alloy:define-widget frame-edit (alloy:structure)
  ((frame-idx :initarg :frame :representation (alloy:button) :reader frame-idx)
   (animation :initarg :animation :reader animation)))

(defmethod initialize-instance :after ((edit frame-edit) &key)
  (alloy:finish-structure edit (slot-value edit 'layout) (slot-value edit 'focus)))

(defmethod frame ((widget frame-edit))
  (svref (frames (animation widget)) (frame-idx widget)))

(alloy:define-subcomponent (frame-edit hurtbox) ((hurtbox (frame frame-edit)) trial-alloy::vec4))
(alloy:define-subcomponent (frame-edit velocity) ((velocity (frame frame-edit)) trial-alloy::vec2))
(alloy:define-subcomponent (frame-edit knockback) ((knockback (frame frame-edit)) trial-alloy::vec2))
(alloy:define-subcomponent (frame-edit damage) ((damage (frame frame-edit)) alloy:wheel))
(alloy:define-subcomponent (frame-edit stun) ((stun-time (frame frame-edit)) alloy:wheel))
(alloy:define-subcomponent (frame-edit interruptable) ((interruptable-p (frame frame-edit)) alloy:checkbox))
(alloy:define-subcomponent (frame-edit invincible) ((invincible-p (frame frame-edit)) alloy:checkbox))
(alloy:define-subcomponent (frame-edit cancelable) ((cancelable-p (frame frame-edit)) alloy:checkbox))

(alloy:define-subcontainer (frame-edit layout)
    (alloy:vertical-linear-layout :cell-margins (alloy:margins 1))
  frame-idx hurtbox velocity knockback damage stun interruptable invincible cancelable)

(alloy:define-subcontainer (frame-edit focus)
    (alloy:focus-list)
  frame-idx hurtbox velocity knockback damage stun interruptable invincible cancelable)
