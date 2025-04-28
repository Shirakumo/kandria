(in-package #:org.shirakumo.fraf.kandria)

(define-shader-pass combine-pass (post-effect-pass)
  ((name :initform 'fade)
   (a-pass :port-type input)
   (b-pass :port-type input)
   (color :port-type output :reader color)
   (texture :initform (// 'kandria 'block-transition) :accessor texture)
   (on-complete :initform NIL :accessor on-complete)
   (strength :initform 0.0 :accessor strength)
   (direction :initform 0.0 :accessor direction)
   (screen-color :initform (vec 0 0 0) :accessor screen-color)
   (action-list :initform () :accessor action-list)
   (distortion-texture :initform (// 'kandria 'pixelfont) :accessor distortion-texture)
   (distortion-strength :initform 0f0 :accessor distortion-strength)
   (noise :port-type fixed-input :texture (// 'kandria 'noise))
   (noise-cloud :port-type fixed-input :texture (// 'kandria 'noise-cloud))
   (sandstorm-strength :initform 0f0 :accessor sandstorm-strength)
   (velocity :initform 1f0 :accessor velocity))
  (:shader-file (kandria "post.glsl")))

(defmethod (setf distortion-strength) :around (value (pass combine-pass))
  (unless (setting :gameplay :visual-safe-mode)
    (call-next-method)))

(defmethod (setf sandstorm-strength) :around (value (pass combine-pass))
  (unless (setting :gameplay :visual-safe-mode)
    (call-next-method)))

(defmethod (setf kind) (kind (fade combine-pass))
  (ecase kind
    (:white
     (setf (texture fade) (// 'kandria 'plain-transition))
     (vsetf (screen-color fade) 5 5 5))
    (:black
     (setf (texture fade) (// 'kandria 'plain-transition))
     (vsetf (screen-color fade) 0 0 0))
    (:blue
     (setf (texture fade) (// 'kandria 'plain-transition))
     (vsetf (screen-color fade) 0.2 0.3 0.7))
    (:transition
      (setf (texture fade) (// 'kandria 'block-transition))
      (vsetf (screen-color fade) 0 0 0))))

(defmethod stage :after ((pass combine-pass) (area staging-area))
  (stage (// 'kandria 'block-transition) area)
  (stage (// 'kandria 'plain-transition) area)
  (stage (// 'sound 'ui-transition) area)
  (stage (distortion-texture pass) area)
  (stage (texture (port pass 'noise)) area)
  (stage (texture (port pass 'noise-cloud)) area))

(defmethod handle ((ev transition-event) (fade combine-pass))
  (cond ((null (action-list fade))
         (when (eql :transition (kind ev))
           (harmony:play (// 'sound 'ui-transition)))
         (setf (kind fade) (kind ev))
         (push (on-complete ev) (on-complete fade))
         (setf (action-list fade) (make-instance (action-list:action-list 'transition))))
        ((< (action-list:elapsed-time (action-list fade)) 0.5)
         (push (on-complete ev) (on-complete fade)))
        (T
         (funcall (on-complete ev)))))

(defmethod handle ((ev tick) (fade combine-pass))
  (let ((action-list (action-list fade)))
    (when action-list
      (action-list:update action-list (dt ev))
      (when (action-list:finished-p action-list)
        (setf (action-list fade) NIL)))))

(defmethod render :before ((pass combine-pass) (program shader-program))
  (gl:active-texture :texture0)
  (gl:bind-texture :texture-2d (gl-name (texture pass)))
  (gl:active-texture :texture1)
  (gl:bind-texture :texture-2d (gl-name (distortion-texture pass)))
  (setf (uniform program "direction") (direction pass))
  (setf (uniform program "transition_map") 0)
  (setf (uniform program "screen_color") (screen-color pass))
  (setf (uniform program "transition_strength") (- 1 (strength pass)))
  (setf (uniform program "pixelfont") 1)
  (setf (uniform program "seed") (logand #xFFFF (sxhash (floor (* 2 (clock +world+))))))
  (setf (uniform program "distortion_strength") (distortion-strength pass))
  (setf (uniform program "sandstorm_strength") (sandstorm-strength pass))
  (setf (uniform program "speed") (velocity pass))
  (when (node 'player +world+)
    (let* ((loc (location (node 'player +world+)))
           (loc (m* (projection-matrix) (view-matrix) (tvec (vx loc) (vy loc) 0 1))))
      (setf (uniform program "focus_center") (tvec (* 0.5 (1+ (vx loc)))
                                                   (* 0.5 (1+ (vy loc)))))))
  (setf (uniform program "time") (clock +world+)))

(define-setting-observer visual-safe-mode :gameplay :visual-safe-mode (value)
  (when (and value (node 'fade T))
    (setf (sandstorm-strength (node 'fade T)) 0.0)
    (setf (distortion-strength (node 'fade T)) 0.0)))

(action-list:define-action-list death
  (ease 1.5 (distortion-strength (u 'fade)) :from 0.0 :to 1.0 :ease #'easing-f:out-circ)
  (setf (direction (u 'fade)) 0.0
        (strength (u 'fade)) 0.0
        (kind (u 'fade)) :blue)
  (ease 0.5 (strength (u 'fade)) :from 0.0 :to 1.0 :ease #'easing-f:in-exp)
  (eval (show-panel 'game-over-panel))
  (ease 0.5 (strength (u 'fade)) :from 1.0 :to 0.0 :ease #'easing-f:out-exp)
  (ease 2.0 (distortion-strength (u 'fade)) :from 1.0 :to 0.0 :ease #'easing-f:in-circ))

(action-list:define-action-list hurt
  (ease 0.2 (distortion-strength (u 'fade)) :from 0.0 :to 0.5 :ease #'easing-f:out-exp)
  (ease 0.1 (distortion-strength (u 'fade)) :from 0.5 :to 0.0 :ease #'easing-f:out-exp))

(action-list:define-action-list transition
  (setf (direction (u 'fade)) 0.0)
  (ease 0.5 (strength (u 'fade)) :from 0.0 :to 1.0)
  (delay 0.1)
  (eval (loop for func = (pop (on-complete (u 'fade)))
              while func
              do (funcall func))
        (setf (direction (u 'fade)) 1.0))
  (delay 0.1)
  (ease 0.5 (strength (u 'fade)) :from 1.0 :to 0.0))

(action-list:define-action-list start-game
  (setf (kind (u 'fade)) :black
        (direction (u 'fade)) 0.0)
  (eval (harmony:play (// 'sound 'player-awaken)))
  (ease 5.0 (strength (u 'fade)) :from 1.0 :to 0.0 :ease #'easing-f:in-bounce :blocking NIL)
  (ease 1.0 (strength (u 'fade)) :from 1.0 :to 1.0))

(action-list:define-action-list game-end
  (setf (shake-timer (camera +world+)) 5.0
        (shake-intensity (camera +world+)) 10.0
        (velocity (u 'fade)) 0.05
        (kind (u 'fade)) :black)
  (setf (override (u 'environment)) 'null)
  (eval (harmony:play (// 'sound 'bomb-explode)))
  (delay 0.2)
  (ease 0.1 (shake-intensity (camera +world+)) :from 10.0 :to 0.0)
  (delay 0.7)
  (eval (harmony:play (// 'sound 'ambience-earthquake) :volume (db -10)))
  (ease 2.0 (shake-intensity (camera +world+)) :from 0.0 :to 20.0 :ease #'easing-f:in-cubic :blocking NIL)
  (ease 2.0 (sandstorm-strength (u 'fade)) :from 0.0 :to 0.5 :blocking NIL)
  (delay 0.5)
  (eval (trigger 'rockslide NIL :location (v+ (location (camera +world+)) (v_y (bsize (camera +world+))) (vec 0 300))))
  (delay 0.4)
  (eval (trigger 'rockslide NIL :location (v+ (location (camera +world+)) (v_y (bsize (camera +world+))) (vec 0 300))))
  (delay 0.1)
  (eval (trigger 'rockslide NIL :location (v+ (location (camera +world+)) (v_y (bsize (camera +world+))) (vec 0 300))))
  (delay 1.6)
  (setf (strength (u 'fade)) 1.0)
  (delay 0.4)
  (ease 1.0 (sandstorm-strength (u 'fade)) :from 0.5 :to 0.0 :blocking NIL)
  (ease 1.0 (shake-intensity (camera +world+)) :from 20.0 :to 0.0))

(action-list:define-action-list low-health
  (eval (setf (kind (u 'fade)) :white)
        (setf (time-scale +world+) 1.0))
  (ease 0.1 (strength (u 'fade)) :from 0.0 :to 0.8                                :lanes #b010)
  (ease 0.8 (strength (u 'fade)) :from 0.8 :to 0.0 :ease #'easing-f:out-exp       :lanes #b010)
  (ease 0.2 (distortion-strength (u 'fade)) :from 0.0 :to 0.7 :ease #'easing-f:out-exp :lanes #b100)
  (ease 0.5 (time-scale +world+) :from 1.0 :to 0.2 :ease #'easing-f:in-quint      :lanes #b001)
  (delay 1.0)
  (ease 5.0 (distortion-strength (u 'fade)) :from 0.7 :to 0.0 :ease #'easing-f:out-exp :lanes #b100)
  (ease 1.0 (time-scale +world+) :from 0.2 :to 1.0 :ease #'easing-f:out-quint     :lanes #b001))
