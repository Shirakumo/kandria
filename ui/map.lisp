(in-package #:org.shirakumo.fraf.kandria)

(defclass map-element (alloy:renderable alloy:focus-element alloy:layout-element)
  ((offset :initform (vec 0 0) :accessor offset)
   (state :initform NIL :accessor state)
   (bsize :initform (vec 0 0) :accessor bsize)
   (zoom :initform (/ 0.125 (alloy:resolution-scale (unit 'ui-pass T))) :accessor zoom)))

(animation:define-animation (flash-marker :loop T)
  0 ((setf simple:pattern) colors:gold)
  0.1 ((setf simple:pattern) colors:black)
  1.0 ((setf simple:pattern) colors:black)
  1.1 ((setf simple:pattern) colors:gold)
  2.0 ((setf simple:pattern) colors:gold))

(animation:define-animation (pulse-marker :loop T)
  0 ((setf simple:pattern) (colored:color 1 0 0 0.2) :easing animation:cubic-in-out)
  1 ((setf simple:pattern) (colored:color 1 0 0 0.5) :easing animation:cubic-in-out)
  2 ((setf simple:pattern) (colored:color 1 0 0 0.2) :easing animation:cubic-in-out))

(animation:define-animation (chunk-in :loop 0.5)
  0.0 ((setf simple:pattern) (colored:color 1 1 1 0.0) :easing animation:cubic-in-out)
  0.5 ((setf simple:pattern) (colored:color 1 1 1 0.75) :easing animation:cubic-in-out)
  2.0 ((setf simple:pattern) (colored:color 1 1 1 0.75) :easing animation:cubic-in-out)
  2.1 ((setf simple:pattern) (colored:color 1 1 1 0.6) :easing animation:cubic-in-out)
  2.3 ((setf simple:pattern) (colored:color 1 1 1 0.75) :easing animation:cubic-in-out))

(animation:define-animation (chunk-blink)
  0.0 ((setf simple:pattern) (colored:color 1 1 1 0.75) :easing animation:cubic-in-out)
  0.1 ((setf simple:pattern) (colored:color 1 1 1 0.0) :easing animation:cubic-in-out)
  0.15 ((setf simple:pattern) (colored:color 1 1 1 0.75) :easing animation:cubic-in-out)
  0.2 ((setf simple:pattern) (colored:color 1 1 1 0.75) :easing animation:cubic-in-out)
  2.0 ((setf simple:pattern) (colored:color 1 1 1 0.65) :easing animation:cubic-in-out)
  3.0 ((setf simple:pattern) (colored:color 1 1 1 0.75) :easing animation:cubic-in-out))

(defmethod presentations:realize-renderable ((renderer presentations:renderer) (map map-element))
  (presentations:clear-shapes map)
  (let ((array (make-array 0 :adjustable T :fill-pointer T))
        (player (unit 'player T))
        (gap 10)
        (fac (alloy:to-px (alloy:un 1))))
    (setf (offset map) (v* (location player) fac))
    (labels ((add-shape (shape)
               (setf (presentations:hidden-p shape) T)
               (vector-push-extend (cons (presentations:name shape) shape) array)
               shape)
             (unit-marker (unit color)
               (let* ((target (ensure-location (closest-visible-target unit)))
                      (bounds (alloy:extent (- (vx target) (* gap 5))
                                            (- (vy target) (* gap 5))
                                            (* gap 5 2)
                                            (* gap 5 2))))
                 (values
                  (add-shape (simple:rectangle renderer bounds :pattern color :name (name unit) :z-index -5))
                  target)))
             (target-marker (location size color)
               (let* ((location (v+ (ensure-location (closest-visible-target location))
                                    (vrandr 4.0 8.0)))
                      (bounds (alloy:extent (- (vx location) (/ size 2))
                                            (- (vy location) (/ size 2))
                                            size size))
                      (fill (colored:color (colored:r color) (colored:g color) (colored:b color) 0.5))
                      (shape (simple:ellipse renderer bounds :pattern fill :name :target :z-index -9)))
                 (add-shape shape)
                 (animation:apply-animation 'pulse-marker shape))))
      (for:for ((unit over (region +world+)))
        (typecase unit
          (chunk
           (when (and (unlocked-p unit) (visible-on-map-p unit))
             (let ((bounds (alloy:extent (+ gap (- (vx (location unit)) (vx (bsize unit))))
                                         (+ gap (- (vy (location unit)) (vy (bsize unit))))
                                         (- (* 2 (vx (bsize unit))) (* 2 gap))
                                         (- (* 2 (vy (bsize unit))) (* 2 gap)))))
               (let ((shape (simple:rectangle renderer bounds :pattern (colored:color 1 1 1 0.0)
                                                              :name 'chunk
                                                              :z-index -15)))
                 (add-shape shape))
               (when (language-string (name unit) NIL)
                 (add-shape (simple:text renderer bounds
                                         (language-string (name unit))
                                         :font (setting :display :font)
                                         :pattern colors:black
                                         :name (name unit)
                                         :size (alloy:un 80)
                                         :halign :middle
                                         :valign :middle
                                         :z-index -9
                                         :wrap T))))))))
      (for:for ((unit over (region +world+)))
        (typecase unit
          (npc
           (when (or (and (eql :lead (ai-state unit))
                          (visible-on-map-p (chunk unit)))
                     (visible-on-map-p unit))
             (let ((target (nth-value 1 (unit-marker unit (colored:color 0.5 1 0.5 1)))))
               (add-shape (simple:text renderer (alloy:extent (- (vx target) 500)
                                                              (+ (vy target) 50)
                                                              1000 100)
                                       (nametag unit)
                                       :font (setting :display :font)
                                       :pattern colors:white
                                       :name (name unit)
                                       :size (alloy:un 50)
                                       :halign :middle
                                       :valign :bottom
                                       :z-index -2)))))
          (save-point
           (let* ((location (location unit))
                  (chunk (find-chunk location)))
             (when (and chunk (unlocked-p chunk))
               (add-shape (simple:text renderer (alloy:extent (- (vx location) 100) (- (vy location) 100) 200 200)
                                       "💾"
                                       :font "PromptFont"
                                       :pattern colors:black
                                       :size (alloy:un 100)
                                       :halign :middle
                                       :valign :middle
                                       :z-index -2)))))))
      (dolist (quest (quest:known-quests (storyline +world+)))
        (when (eql :active (quest:status quest))
          (dolist (task (quest:active-tasks quest))
            (when (marker task)
              (destructuring-bind (location size &optional (color colors:red)) (enlist (marker task) (* 40 +tile-size+))
                (target-marker location size color))))))
      (dolist (quest (quest:known-quests (storyline +world+)))
        (when (eql :active (quest:status quest))
          (dolist (task (quest:active-tasks quest))
            (when (marker task)
              (destructuring-bind (location size &optional c) (enlist (marker task) (* 40 +tile-size+))
                (let ((location (ensure-location (closest-visible-target location))))
                  (let* ((shape (simple:line-strip renderer (list (alloy:point (vx location) (vy location))
                                                                  (alloy:point (vx location) (+ (vy location) (/ size 2) 100)))
                                                   :pattern colors:white
                                                   :line-width (alloy:un 2)
                                                   :z-index -2)))
                    (add-shape shape))
                  (let* ((bounds (alloy:extent (- (vx location) (/ 1000 2))
                                               (+ (vy location) (/ size 2) 150)
                                               1000 400))
                         (shape (simple:text renderer bounds (quest:title quest)
                                             :font (setting :display :font)
                                             :size (alloy:un 70)
                                             :halign :middle
                                             :valign :bottom
                                             :wrap T
                                             :pattern colors:white
                                             :z-index -2)))
                    (add-shape shape))
                  (let* ((bounds (alloy:extent (- (vx location) (/ 50 2))
                                               (- (vy location) (/ 50 2))
                                               50 50))
                         (shape (simple:ellipse renderer bounds
                                                :pattern colors:white
                                                :z-index -2)))
                    (add-shape shape))))))))
      (animation:apply-animation 'flash-marker (unit-marker player (colored:color 0.5 0.5 1 1)))
      (let ((trace (movement-trace player))
            (points (make-array 0 :adjustable T :fill-pointer T))
            (color (colored:color 0 0.8 1 0.5)))
        (flet ((flush ()
                 (when (< 0 (length points))
                   (let ((shape (simple:line-strip renderer points
                                                   :name 'trace
                                                   :pattern color
                                                   :line-width (alloy:un 4)
                                                   :join-style :bevel
                                                   :hidden-p T
                                                   :z-index -5)))
                     (add-shape shape)
                     (setf (org.shirakumo.alloy.renderers.opengl::size shape) 0)
                     (setf (fill-pointer points) 0)))))
          (loop for i from 0 below (length trace) by 2
                do (cond ((float-features:float-nan-p (aref trace i))
                          (flush)
                          (when (float-features:float-infinity-p (aref trace (1+ i)))
                            (let ((bounds (alloy:extent (- (aref trace (- i 2)) 32)
                                                        (- (aref trace (- i 1)) 32)
                                                        64 64)))
                              (add-shape (simple:text renderer bounds "✗"
                                                      :size (alloy:un 64)
                                                      :pattern colors:red
                                                      :valign :middle
                                                      :halign :middle
                                                      :name :death
                                                      :z-index -4
                                                      :font "PromptFont")))))
                         (T
                          (vector-push-extend (alloy:point (aref trace i) (aref trace (1+ i))) points)))
                finally (flush)))))
    (setf (presentations:shapes map) array)
    (update-markers map)))

(defmethod update-markers ((map map-element))
  (let ((shapes (presentations:shapes map))
        (renderer (unit 'ui-pass T)))
    (alloy:with-unit-parent map
      (loop for i from 0
            for shape across shapes
            do (when (eql (car shape) 'marker)
                 (setf (fill-pointer shapes) i)
                 (return)))
      (dolist (marker (map-markers (unit 'player T)))
        (let ((bounds (alloy:extent (- (vx (map-marker-location marker)) 128)
                                    (- (vy (map-marker-location marker)) 128)
                                    256 256)))
          (vector-push-extend (cons 'marker (simple:text renderer bounds (map-marker-label marker)
                                                         :size (alloy:un 128)
                                                         :pattern (map-marker-color marker)
                                                         :valign :middle
                                                         :halign :middle
                                                         :name 'marker
                                                         :z-index -3
                                                         :font "PromptFont"))
                              shapes))))))

(defmethod alloy:suggest-size (size (map map-element))
  size)

(defmethod alloy:render :around ((renderer alloy:renderer) (map map-element))
  (alloy:with-unit-parent map
    (when (alloy:render-needed-p map)
      (presentations:realize-renderable renderer map)
      (setf (slot-value map 'alloy:render-needed-p) NIL))
    (simple:with-pushed-transforms (renderer)
      (alloy:render renderer (simple:rectangle renderer (alloy:bounds map) :pattern (simple:image-pattern renderer (// 'kandria 'ui-background)
                                                                                                          :scaling (alloy:size (alloy:u/ (alloy:px 32) (alloy:vw 1))
                                                                                                                               (alloy:u/ (alloy:px 32) (alloy:vh 1))))))
      (simple:translate renderer (alloy:px-point (/ (width *context*) 2) (/ (height *context*) 2)))
      (simple:scale renderer (alloy:size (zoom map) (zoom map)))
      (simple:translate renderer (alloy:px-point (- (vx (offset map))) (- (vy (offset map)))))
      (loop for (name . shape) across (presentations:shapes map)
            do (unless (presentations:hidden-p shape)
                 (simple:with-pushed-transforms (renderer)
                   (setf (simple:z-index renderer) (presentations:z-index shape))
                   (alloy:render renderer shape)))))))

(defmethod alloy:handle ((ev alloy:pointer-event) (focus map-element))
  (restart-case
      (call-next-method)
    (alloy:decline ()
      T)))

(defmethod alloy:handle ((ev alloy:scroll) (panel map-element))
  (setf (zoom panel) (clamp 0.01 (+ (zoom panel) (* 0.01 (alloy:dy ev))) 0.5)))

(defmethod alloy:handle ((ev alloy:pointer-down) (panel map-element))
  (when (eql :left (alloy:kind ev))
    (setf (state panel) :drag)))

(defmethod alloy:handle ((ev alloy:pointer-up) (panel map-element))
  (setf (state panel) NIL))

(defmethod alloy:handle ((ev alloy:pointer-move) (panel map-element))
  (case (state panel)
    (:drag
     (let ((l (alloy:location ev))
           (o (alloy:old-location ev))
           (z (* (zoom panel) (alloy:with-unit-parent panel (alloy:to-px (alloy:un 1))))))
       (incf (vx (offset panel)) (/ (- (alloy:pxx o) (alloy:pxx l)) z))
       (incf (vy (offset panel)) (/ (- (alloy:pxy o) (alloy:pxy l)) z))))))

(defclass reticle (label)
  ((alloy:value :initform "[ ]")))

(presentations:define-update (ui reticle)
  (:label
   :size (alloy:un 30)
   :wrap NIL
   :halign :middle))

(defmethod hide ((reticle reticle))
  (alloy:leave reticle T))

(defclass map-legend-label (label)
  ())

(presentations:define-realization (ui map-legend-label)
  ((label simple:text)
   (alloy:margins)
   alloy:text
   :font (setting :display :font)
   :wrap T
   :size (alloy:un 20)
   :pattern colors:white
   :halign :middle
   :valign :middle))

(defclass map-legend (alloy:grid-layout alloy:renderable)
  ())

(defmethod initialize-instance :after ((legend map-legend) &key)
  (setf (alloy:row-sizes legend) '(30 30))
  (setf (alloy:col-sizes legend) '(T 150 150 150 150 150 T))
  (loop for prompt in '(toggle-marker toggle-trace zoom-in zoom-out close-map)
        for i from 0
        do (alloy:enter (make-instance 'map-legend-label :value (prompt-string prompt)
                                                         :style `((label :size ,(alloy:un 25))))
                        legend :col (1+ i) :row 0)
           (alloy:enter (make-instance 'map-legend-label :value (language-string prompt)
                                                         :style `((label :size ,(alloy:un 10))))
                        legend :col (1+ i) :row 1)))

(defmethod hide ((legend map-legend))
  (alloy:leave legend T))

(presentations:define-realization (ui map-legend)
  ((bg simple:rectangle)
   (alloy:margins)
   :pattern (simple:request-gradient alloy:renderer 'simple:linear-gradient (alloy:point 0 0) (alloy:point 0 60)
                                     #((0.2 #.(colored:color 0.1 0.1 0.1 0.9))
                                       (1.0 #.(colored:color 0.1 0.1 0.1 0.5))))))

(defclass map-panel (pausing-panel fullscreen-panel)
  ((show-trace :initform NIL :accessor show-trace)
   (clock :initform 0.2 :accessor clock)
   (corrupted-p :initform (do-fitting (entity (bvh (region +world+)) (unit 'player T))
                            (when (typep entity 'map-block-zone) (return T)))
                :accessor corrupted-p)))

(defmethod initialize-instance :after ((panel map-panel) &key)
  (clear-retained)
  (if (corrupted-p panel)
      (alloy:finish-structure panel (make-instance 'eating-constraint-layout :shapes (list (make-basic-background))) NIL)
      (let ((map (make-instance 'map-element)))
        (alloy:finish-structure panel map map))))

(defmethod show :after ((panel map-panel) &key)
  (alloy:with-unit-parent (unit 'ui-pass T)
    (alloy:enter (make-instance 'reticle :value (if (corrupted-p panel) (@ corrupted-map-reticle) "[ ]"))
                 (alloy:popups (alloy:layout-tree (unit 'ui-pass T)))
                 :x (alloy:u- (alloy:vw 0.5) (alloy:un 250))
                 :y (alloy:u- (alloy:vh 0.5) (alloy:un 25))
                 :w (alloy:un 500) :h (alloy:un 50))
    (unless (corrupted-p panel)
      (alloy:enter (make-instance 'map-legend)
                   (alloy:popups (alloy:layout-tree (unit 'ui-pass T)))
                   :x 0 :y 0 :w (alloy:vw 1) :h (alloy:un 60)))))

(defmethod hide :after ((panel map-panel))
  (harmony:stop (// 'sound 'ui-scroll))
  (let ((els ()))
    (alloy:do-elements (el (alloy:popups (alloy:layout-tree (unit 'ui-pass T))))
      (push el els))
    (mapc #'hide els)))

(defmethod (setf active-p) :after (value (panel map-panel))
  (if value
      (setf (active-p (action-set 'in-map)) T)
      (setf (active-p (action-set 'in-game)) T)))

(defun update-player-tick (panel x y)
  (let ((shape (presentations:find-shape 'player (alloy:focus-element panel))))
    (when shape
      (setf (alloy:unit-value (the alloy:un (alloy:x (simple:bounds shape)))) x)
      (setf (alloy:unit-value (the alloy:un (alloy:y (simple:bounds shape)))) y))))

(defmethod handle ((ev tick) (panel map-panel))
  (unless (corrupted-p panel)
    (let* ((map (alloy:layout-element panel))
           (ui-scalar (alloy:with-unit-parent map (alloy:to-px (alloy:un 1))))
           (speed (* 5 ui-scalar (/ (zoom map)))))
      (when (show-trace panel)
        (loop for (name . shape) across (presentations:shapes map)
              do (when (eql name 'trace)
                   (let ((data (org.shirakumo.alloy.renderers.opengl::line-data shape))
                         (idx (* (org.shirakumo.alloy.renderers.opengl::size shape) 5 6)))
                     (when (< idx (length data))
                       (incf (org.shirakumo.alloy.renderers.opengl::size shape) 2)
                       ;; KLUDGE: extract position from line
                       (alloy:with-unit-parent (alloy:layout-element panel)
                         (when (< (+ (* 4 6) 1 idx) (length data))
                           (let* ((x (aref data (+ (* 4 6) idx)))
                                  (y (aref data (+ (* 4 6) 1 idx))))
                             (unless (= 0.0 x y)
                               (update-player-tick panel (alloy:to-un x) (alloy:to-un y))))))
                       (return))))))
      (alloy:with-unit-parent (alloy:layout-element panel)
        (if (< (clock panel) 5.0)
            (loop for (name . shape) across (presentations:shapes map)
                  do (when (and (not (eql name 'trace))
                                (presentations:hidden-p shape))
                       (let ((distance (etypecase shape
                                         (simple:line-strip
                                          (vdistance (offset map) (vec (alloy:pxx (first (simple:points shape)))
                                                                       (alloy:pxy (first (simple:points shape))))))
                                         (T (vdistance (offset map) (vec (+ (alloy:pxx (simple:bounds shape))
                                                                            (/ (alloy:pxw (simple:bounds shape)) 2))
                                                                         (+ (alloy:pxy (simple:bounds shape))
                                                                            (/ (alloy:pxh (simple:bounds shape)) 2))))))))
                         (when (< distance (expt (* 120.0 (clock panel)) 2.1))
                           (setf (presentations:hidden-p shape) NIL)
                           (when (eql 'chunk name) (animation:apply-animation 'chunk-in shape))))))
            #++
            (when (<= 5.1 (clock panel))
              (setf (clock panel) 5.0)
              (loop with target = (random (length (presentations:shapes map)))
                    for (name . shape) across (presentations:shapes map)
                    do (decf target)
                       (when (and (<= target 0) (eql 'chunk name))
                         (animation:apply-animation 'chunk-blink shape)
                         (return))))))
      (incf (clock panel) (dt ev))
      (when (retained 'pan-left)
        (incf (vx (offset map)) (- speed)))
      (when (retained 'pan-right)
        (incf (vx (offset map)) (+ speed)))
      (when (retained 'pan-down)
        (incf (vy (offset map)) (- speed)))
      (when (retained 'pan-up)
        (incf (vy (offset map)) (+ speed)))
      (when (v= 0 (bsize map))
        (setf (bsize map) (v* (nth-value 1 (bsize (region +world+))) ui-scalar)))
      (nvclamp (vxy (bsize map)) (offset map) (vzw (bsize map)))
      (when (retained 'zoom-in)
        (setf (zoom map) (clamp 0.01 (+ (zoom map) 0.001) 0.5)))
      (when (retained 'zoom-out)
        (setf (zoom map) (clamp 0.01 (- (zoom map) 0.001) 0.5)))
      ;; FIXME: This doesn't work with the lowpass.
      (if (or (retained 'zoom-out) (retained 'zoom-in)
              (retained 'pan-up) (retained 'pan-down)
              (retained 'pan-left) (retained 'pan-right))
          (harmony:play (// 'sound 'ui-scroll))
          (harmony:stop (// 'sound 'ui-scroll))))))

(defmethod handle ((ev toggle-trace) (panel map-panel))
  (unless (corrupted-p panel)
    (let ((map (alloy:focus-element panel)))
      (setf (show-trace panel) (ecase (show-trace panel)
                                 ((NIL) :scroll)
                                 (:scroll :complete)
                                 (:complete NIL)))
      (when (find (show-trace panel) '(NIL :complete))
        (update-player-tick panel (vx (location (unit 'player T))) (vy (location (unit 'player T)))))
      (loop for (name . shape) across (presentations:shapes map)
            do (when (eql name 'trace)
                 (ecase (show-trace panel)
                   ((NIL) (setf (org.shirakumo.alloy.renderers.opengl::size shape) 0))
                   (:scroll (setf (org.shirakumo.alloy.renderers.opengl::size shape) 0))
                   (:complete (setf (org.shirakumo.alloy.renderers.opengl::size shape) 1000000000)))
                 (setf (presentations:hidden-p shape) (not (show-trace panel))))))))

(defmethod handle ((ev toggle-marker) (panel map-panel))
  (unless (corrupted-p panel)
    (let* ((map (alloy:focus-element panel))
           (unfac (alloy:with-unit-parent map (alloy:to-px (alloy:un 1))))
           (loc (v/ (offset map) unfac))
           (found NIL))
      (when (typep (source-event ev) 'mouse-event)
        (nv+ loc (v/ (v- (pos (source-event ev))
                         (v/ (vec (width *context*) (height *context*)) 2))
                     (* (zoom map) unfac unfac))))
      (loop for marker in (map-markers (unit 'player T))
            for mloc = (map-marker-location marker)
            do (when (and (< (vdistance mloc loc) 256)
                          (or (null found) (< (vdistance mloc loc) (vdistance (map-marker-location found) loc))))
                 (setf found marker)))
      (show (make-instance 'marker-menu :marker (or found (make-map-marker loc)))
            :height (alloy:un 250)))))

(defmethod handle ((ev close-map) (panel map-panel))
  (hide panel))

(defmethod update-markers ((panel map-panel))
  (update-markers (alloy:focus-element panel)))

(defclass marker-button (alloy:button* button)
  ())

(presentations:define-realization (ui marker-button)
  ((border simple:rectangle)
   (alloy:margins)
   :line-width (alloy:un 2))
  ((:label simple:text)
   (alloy:margins 0)
   alloy:text
   :font "PromptFont"
   :halign :middle
   :valign :middle))

(presentations:define-update (ui marker-button)
  (border
   :pattern (if alloy:focus (colored:color 0.9 0.9 0.9) colors:transparent))
  (:label
   :size (alloy:un 20)
   :pattern colors:black))

(presentations:define-animated-shapes button
  (:background (simple:pattern :duration 0.2))
  (border (simple:pattern :duration 0.3) (simple:line-width :duration 0.5)))

(defclass marker-menu (popup-panel)
  ((maker :initarg :marker :accessor marker)))

(defmethod initialize-instance :after ((panel marker-menu) &key marker)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(T T T T T) :row-sizes '(50)
                                                   :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern colors:white))))
         (focus (make-instance 'alloy:focus-grid :width 5)))
    (dolist (label '(" " "★" "☠" "♥" "⚑"
                     "🐟" "❓" "❗" "☹" "☺"
                     "⌖" "↔" "A" "B" "C"
                     "⓵" "⓶" "⓷" "⓸" "⓹"
                     "⓺" "⓻" "⓼" "⓽" "⓿"))
      (let ((label label))
        (make-instance 'marker-button :value label :on-activate (lambda ()
                                                           (setf (map-marker-label marker) label)
                                                           (hide panel))
                                      :focus-parent focus :layout-parent layout)))
    (alloy:on alloy:exit (focus)
      (hide panel))
    (alloy:finish-structure panel layout focus)))

(defparameter *marker-colors*
  (mapcar #'colored:decode '(#xFFD300 #xF9A602 #xFA8072 #xE0115F #xB43757
                             #x131E3A #x0B6623 #x4B3A26 #x787276 #xFFD300
                             #xFADA3E #xFF7417 #x7C0A02 #xFDE6FA #xC64B8C
                             #x95C8D8 #x708238 #x3A1F04 #xD9DDDC #x800000)))

(defmethod hide :after ((panel marker-menu))
  (clear-retained)
  (let ((markers (map-markers (unit 'player T)))
        (marker (marker panel)))
    (cond ((string= " " (map-marker-label marker))
           (setf (map-markers (unit 'player T)) (remove marker markers)))
          ((find marker markers))
          ((null markers)
           (setf (map-marker-color marker) (first *marker-colors*))
           (setf (map-markers (unit 'player T)) (list marker)))
          (T
           (loop for color in *marker-colors*
                 do (unless (loop for marker in markers
                                  thereis (colored:color= color (map-marker-color marker)))
                      (setf (map-marker-color marker) color)
                      (return))
                 finally (setf (map-marker-color marker) (first *marker-colors*)))
           (setf (cdr (last markers)) (list marker)))))
  (let ((panel (find-panel 'map-panel)))
    (when panel
      (update-markers panel))))

(defun show-sales-menu (direction character)
  (show-panel 'sales-menu :shop (unit character T) :target (unit 'player T)  :direction direction))
