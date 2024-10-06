(in-package #:org.shirakumo.fraf.kandria)

(colored:define-color #:accent #x0088EE)
(colored:define-color #:dark-accent #x0055AA)
;; Disable blend extensions because we don't need em
(setf org.shirakumo.alloy.renderers.opengl::*gl-extensions* '(:none))

(defclass ui (org.shirakumo.fraf.trial.alloy:ui
              org.shirakumo.alloy:fixed-scaling-ui
              org.shirakumo.alloy.renderers.simple.presentations:default-look-and-feel)
  ((alloy:target-resolution :initform (alloy:px-size 1280 720))
   (alloy:scales :initform '((3840 T 2.0)
                             (2800 T 1.5)
                             (1920 T 1.25)
                             (1280 T 1.0)
                             (1000 T 0.8)
                             (T T 0.5)))
   (first-hold-time :initform (cons NIL 0.0) :accessor first-hold-time)))

(defmethod handle :after ((ev tick) (ui ui))
  (let ((hold (first-hold-time ui)))
    (loop for action in '(select-left select-right select-up select-down)
          do (when (retained action)
               (if (eql action (car hold))
                   (incf (cdr hold) (dt ev))
                   (setf (car hold) action
                         (cdr hold) 0.0))
               (return))
          finally (setf (car hold) NIL
                        (cdr hold) 0.0))
    ;; 0.5 is the initial repeat delay
    (when (< 0.5 (cdr hold))
      (issue +world+ (make-instance (car hold)))
      ;; 0.1 is the delay between repeats
      (setf (cdr hold) (- 0.5 0.1)))))

(defmethod org.shirakumo.alloy.renderers.opengl.msdf:fontcache-directory ((ui ui))
  (pool-path 'kandria "font-cache/"))

(presentations:define-realization (ui alloy:checkbox)
  ((:border simple:rectangle)
   (alloy:extent 0 0 (alloy:ph 1) (alloy:ph 1))
   :pattern colors:white
   :line-width (alloy:un 2))
  ((:check simple:rectangle)
   (alloy:extent (alloy:ph 0.15) (alloy:ph 0.15) (alloy:ph 0.7) (alloy:ph 0.7))
   :hidden-p (not (alloy:active-p alloy:renderable))
   :pattern colors:accent))

(presentations:define-update (ui alloy:checkbox)
  (:border
   :hidden-p NIL
   :pattern (if alloy:focus
                (colored:color 0.9 0.9 0.9)
                colors:gray))
  (:check
   :pattern (if alloy:focus (colored:color 0.9 0.9 0.9) colors:accent)
   :hidden-p (not (alloy:active-p alloy:renderable))))

(presentations:define-realization (ui alloy:switch)
  ((:border simple:rectangle)
   (alloy:margins)
   :pattern colors:white
   :line-width (alloy:un 2))
  ((:background simple:rectangle)
   (alloy:margins))
  ((:switch simple:rectangle)
   (alloy:extent 0 0 (alloy:pw 0.3) (alloy:ph))))

(presentations:define-update (ui alloy:switch)
  (:border
   :hidden-p NIL
   :pattern (if alloy:focus
                (colored:color 0.9 0.9 0.9)
                colors:gray))
  (:background
   :pattern (if (alloy:active-p alloy:renderable)
                colors:dark-accent
                (colored:color 0 0 0 0.5)))
  (:switch
   :pattern (if (alloy:active-p alloy:renderable)
                colors:accent
                colors:black)))

(presentations:define-animated-shapes alloy:switch
  (:background (simple:pattern :duration 0.2))
  (:switch (simple:pattern :duration 0.3) (simple:bounds :duration 0.5)))

(presentations:define-realization (ui alloy:labelled-switch T)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :font (setting :display :font)
   :halign :middle
   :valign :middle))

(presentations:define-update (ui alloy:labelled-switch)
  (:border
   :z-index 0)
  (:label
   :text alloy:text
   :pattern colors:white))

(presentations:define-realization (ui alloy:slider)
  ((:background simple:rectangle)
   (ecase (alloy:orientation alloy:renderable)
     (:horizontal (alloy:extent 0 (alloy:ph 0.4) (alloy:pw) (alloy:ph 0.2)))
     (:vertical (alloy:extent (alloy:pw 0.4) 0 (alloy:pw 0.2) (alloy:ph)))))
  ((:border simple:rectangle)
   (alloy:margins -3)
   :line-width (alloy:un 1))
  ((:handle simple:rectangle)
   (ecase (alloy:orientation alloy:renderable)
     (:horizontal (alloy:extent -5 0 10 (alloy:ph)))
     (:vertical (alloy:extent 0 -5 (alloy:pw) 10))))
  ((:display simple:text)
   (alloy:margins)
   (format NIL "~,2f" alloy:value)
   :pattern colors:white
   :font (setting :display :font)
   :halign :middle
   :valign :middle))

(presentations:define-update (ui alloy:slider)
  (:handle
   :pattern (case alloy:focus
              (:strong colors:white)
              (T colors:accent)))
  (:display
   :text (format NIL "~,2f" alloy:value)))

(presentations:define-realization (ui alloy:scrollbar)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:handle simple:rectangle)
   (ecase (alloy:orientation alloy:renderable)
     (:horizontal (alloy:extent -10 0 20 (alloy:ph)))
     (:vertical (alloy:extent 0 -10 (alloy:pw) 20)))))

(defclass icon (alloy:icon alloy:direct-value-component)
  ())

(defclass button (alloy:button)
  ())

(presentations:define-realization (ui button)
  ((:background simple:rectangle)
   (alloy:margins))
  ((border simple:rectangle)
   (alloy:margins)
   :line-width (alloy:un 2))
  ((:label simple:text)
   (alloy:margins 0)
   alloy:text
   :font (setting :display :font)
   :halign :middle
   :valign :middle))

(presentations:define-update (ui button)
  (:background
   :pattern (if alloy:focus (colored:color 1 1 1 0.5) (colored:color 1 1 1 0.1)))
  (border
   :pattern (if alloy:focus (colored:color 0.9 0.9 0.9) colors:gray)
   :line-width (if alloy:focus (alloy:un 3) (alloy:un 1)))
  (:label
   :size (alloy:un 20)
   :pattern colors:white))

(presentations:define-animated-shapes button
  (:background (simple:pattern :duration 0.2))
  (border (simple:pattern :duration 0.3) (simple:line-width :duration 0.5)))

(defclass label (alloy:label*)
  ())

(presentations:define-realization (ui label)
  ((:label simple:text)
   (alloy:margins 0)
   alloy:text
   :font (setting :display :font)
   :wrap T
   :size (alloy:un 20)
   :halign :start
   :valign :middle))

(presentations:define-update (ui label)
  (:label
   :pattern colors:white))

(defmethod alloy:suggest-size ((size alloy:size) (element label))
  (let ((shape (or (presentations:find-shape :label element)
                   (presentations:find-shape 'label element))))
    (if shape
        (alloy:widen (alloy:suggest-size (alloy:ensure-extent (simple:bounds shape) size) shape)
                     (if (typep (simple:bounds shape) 'alloy:margins) (simple:bounds shape) (alloy:margins 2)))
        size)))

#+trial-steam
(defmethod alloy:activate :after ((input alloy:text-input-component))
  (when (and (steam:steamworks-available-p)
             (not (eql :keyboard +input-source+)))
    (or (ignore-errors (steam:show-floating-text-input (steam:interface 'steam:steamutils T)))
        (steam:show-text-input (steam:interface 'steam:steamutils T)
                               :default (alloy:text input)
                               :description (@ enter-name-prompt))
        (v:warn :trial.steam "Failed to open gamepad text input panel..."))))

#+trial-steam
(defmethod alloy:exit :after ((input alloy:text-input-component))
  (when (and (steam:steamworks-available-p)
             (not (eql :keyboard +input-source+)))
    (ignore-errors (steam:show-floating-text-input (steam:interface 'steam:steamutils T)))))

(defclass deferrer (alloy:renderable alloy:layout-element)
  ())

(defmethod alloy:render :around ((renderer ui) (element deferrer))
  (render element NIL))

(defclass pane (alloy:renderable)
  ())

(presentations:define-realization (ui pane)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0 0 0.75)))

(defclass single-widget (alloy:widget)
  ()
  (:metaclass alloy:widget-class))

(defmethod alloy:layout-element ((widget single-widget))
  (slot-value widget 'representation))

(defmethod alloy:enter ((widget single-widget) target &rest initargs)
  (apply #'alloy:enter (slot-value widget 'representation) target initargs))

(defmethod alloy:update ((widget single-widget) target &rest initargs)
  (apply #'alloy:update (slot-value widget 'representation) target initargs))

(defmethod alloy:leave ((widget single-widget) target)
  (alloy:leave (slot-value widget 'representation) target))

(defmethod alloy:register ((widget single-widget) target)
  (alloy:register (slot-value widget 'representation) target))

(define-shader-pass ui-pass (ui)
  ((name :initform 'ui-pass)
   (panels :initform NIL :accessor panels)
   (color :port-type output :attachment :color-attachment0)
   (depth :port-type output :attachment :depth-stencil-attachment)))

(defmethod initialize-instance :after ((pass ui-pass) &key)
  (make-instance 'alloy:fullscreen-layout :layout-parent (alloy:layout-tree pass))
  (make-instance 'alloy:focus-list :focus-parent (alloy:focus-tree pass)))

(defmethod alloy:clear :after ((pass ui-pass))
  (setf (panels pass) ())
  (make-instance 'alloy:fullscreen-layout :layout-parent (alloy:layout-tree pass))
  (make-instance 'alloy:focus-list :focus-parent (alloy:focus-tree pass)))

(defmethod enter (thing (pass ui-pass)))

(defmethod trial:render :around ((pass ui-pass) target)
  (gl:clear-color 0 0 0 0)
  (trial:activate (trial:framebuffer pass))
  (trial:with-pushed-features
    (trial:enable-feature :depth-test :stencil-test)
    (call-next-method)))

(defmethod handle :around ((ev event) (pass ui-pass))
  (unless (call-next-method)
    (dolist (panel (panels pass))
      (handle ev panel)
      (when (typep panel 'pausing-panel)
        (return)))))

(defmethod handle ((ev file-drop-event) (pass ui-pass))
  (or (call-next-method)
      (dolist (path (paths ev))
        (cond ((ignore-errors (minimal-load-state path))
               (load-state (minimal-load-state path) +main+))
              ((ignore-errors (minimal-load-world path))
               (load-into-world (minimal-load-world path)))
              ((ignore-errors (minimal-load-module path))
               (install-module path (minimal-load-module path)))
              (T
               (v:info :kandria "Don't know what to do with ~s, ignoring" path))))))

(defmethod handle ((ev accept) (pass ui-pass))
  (alloy:handle (load-time-value (make-instance 'alloy:activate)) pass))

(defmethod handle ((ev back) (pass ui-pass))
  (alloy:handle (load-time-value (make-instance 'alloy:exit)) pass))

(defmethod handle ((ev select-left) (pass ui-pass))
  (alloy:handle (load-time-value (make-instance 'alloy:focus-left)) pass))

(defmethod handle ((ev select-right) (pass ui-pass))
  (alloy:handle (load-time-value (make-instance 'alloy:focus-right)) pass))

(defmethod handle ((ev select-up) (pass ui-pass))
  (alloy:handle (load-time-value (make-instance 'alloy:focus-up)) pass))

(defmethod handle ((ev select-down) (pass ui-pass))
  (alloy:handle (load-time-value (make-instance 'alloy:focus-down)) pass))

(defmethod handle ((ev text-entered) (pass ui-pass))
  (or (call-next-method)
      (process-cheats (text ev))))

(defmethod alloy:focus-next :around ((chain alloy:focus-chain))
  (let ((focused (alloy:focused chain)))
    (call-next-method)
    (if (eql focused (alloy:focused chain))
        (harmony:play (// 'sound 'ui-no-more-to-focus) :reset T)
        (harmony:play (// 'sound 'ui-focus-next) :reset T))))

(defmethod alloy:focus-prev :around ((chain alloy:focus-chain))
  (let ((focused (alloy:focused chain)))
    (call-next-method)
    (if (eql focused (alloy:focused chain))
        (harmony:play (// 'sound 'ui-no-more-to-focus) :reset T)
        (harmony:play (// 'sound 'ui-focus-next) :reset T))))

(defmethod alloy:notice-focus :before (thing (chain alloy:focus-chain))
  (when (and (eql :strong (alloy:focus chain))
             (not (eq thing (alloy:focused chain)))
             (not (typep thing 'tile-button)))
    (harmony:play (// 'sound 'ui-focus-next) :reset T)))

(defmethod stage ((pass ui-pass) (area staging-area))
  (call-next-method)
  (dolist (panel (panels pass))
    (stage panel area))
  (stage (// 'kandria 'ui-background) area)
  (dolist (sound '(ui-focus-in ui-focus-out ui-location-enter
                   ui-advance-dialogue ui-no-more-to-focus
                   ui-quest-start ui-close-menu ui-dialogue-choice
                   ui-focus-next ui-open-menu ui-quest-complete
                   ui-quest-fail ui-quest-update ui-scroll-dialogue
                   ui-scroll ui-start-game ui-start-dialogue ui-use-item
                   ui-error ui-warning ui-upgrade-placeholder
                   ui-tutorial-popup ui-fast-travel-map-open
                   ui-buy ui-confirm ui-level-up ui-sell
                   train-departing-and-arriving))
    (stage (// 'sound sound) area))
  (stage (simple:request-font pass (setting :display :font)) area)
  (stage (simple:request-font pass "PromptFont") area)
  (stage (simple:request-font pass "Brands") area)
  (stage (framebuffer pass) area))

(defmethod object-renderable-p ((renderable renderable) (pass ui-pass)) NIL)

;; KLUDGE: No idea why this is necessary, fuck me.
(defmethod simple:request-font :around ((pass ui-pass) font &key)
  (let ((font (call-next-method)))
    (unless (and (alloy:allocated-p font)
                 (allocated-p (org.shirakumo.alloy.renderers.opengl.msdf:atlas font)))
      (trial:commit font (loader +main+) :unload NIL))
    font))

(defun find-panel (panel-type &optional (scene +world+))
  (declare (optimize speed))
  (loop for panel in (panels (unit 'ui-pass scene))
        do (when (typep panel panel-type)
             (return panel))))

(define-compiler-macro find-panel (panel-type &optional (scene '+world+))
  `(loop for panel in (panels (unit 'ui-pass ,scene))
         do (when (typep panel ,panel-type)
              (return panel))))

(defun toggle-panel (panel-type &rest initargs)
  (let ((panel (find-panel panel-type)))
    (if panel
        (hide panel)
        (show (apply #'make-instance panel-type initargs)))))

(defun show-panel (panel-type &rest initargs)
  (let ((panel (find-panel panel-type)))
    (unless panel
      (show (apply #'make-instance panel-type initargs)))))

(defun hide-panel (panel-type &optional (scene +world+))
  (if (eq T panel-type)
      (loop for panel = (first (panels (unit 'ui-pass scene)))
            while panel do (hide panel))
      (let ((panel (find-panel panel-type scene)))
        (when panel
          (hide panel)))))

(defclass panel (alloy:structure popup)
  ((active-p :initform NIL :accessor active-p)))

(defmethod handle ((ev event) (panel panel)))

(defmethod shown-p ((panel panel))
  (alloy:layout-tree (alloy:layout-element panel)))

(defmethod show ((panel panel) &key ui)
  (when *context*
    ;; First stage and load
    (trial:commit panel (loader +main+) :unload NIL))
  ;; Then attach to the UI
  (let ((ui (or ui (unit 'ui-pass T))))
    (when (alloy:focus-element panel)
      (dolist (panel (panels ui))
        (when (active-p panel)
          (setf (active-p panel) NIL)
          (return))))
    (alloy:enter panel (alloy:root (alloy:layout-tree ui)))
    (alloy:register panel ui)
    (when (alloy:focus-element panel)
      (alloy:enter panel (alloy:root (alloy:focus-tree ui)))
      (setf (alloy:focus (alloy:focus-element panel)) :strong))
    (push panel (panels ui))
    (setf (active-p panel) T)
    panel))

(defmethod hide ((panel panel))
  (let ((ui (unit 'ui-pass T)))
    (when (slot-boundp (alloy:layout-element panel) 'alloy:layout-parent)
      (alloy:leave panel (alloy:root (alloy:layout-tree ui)))
      (alloy:leave panel (alloy:root (alloy:focus-tree ui)))
      (setf (panels ui) (remove panel (panels ui))))
    (when (active-p panel)
      (setf (active-p panel) NIL)
      (dolist (panel (panels ui))
        (when (alloy:focus-element panel)
          (setf (active-p panel) T)
          (setf (alloy:focus (alloy:focus-element panel)) :strong)
          (return))))
    panel))

(defclass popup ()
  ())

(defmethod alloy:render :around ((ui ui) (popup popup))
  (unless (find-panel 'fullscreen-panel)
    (call-next-method)))

(defclass fullscreen-panel (panel)
  ())

(defclass action-set-change-panel (panel)
  ((prior-action-set :initform 'in-game :accessor prior-action-set)))

(defmethod show :before ((panel action-set-change-panel) &key)
  (setf (prior-action-set panel) (or (trial:active-action-set) 'in-game)))

(defmethod hide :after ((panel action-set-change-panel))
  (unless (eql (action-set (prior-action-set panel))
               (active-action-set))
    (clear-retained))
  (setf (active-p (action-set (prior-action-set panel))) T))

(defclass menuing-panel (action-set-change-panel fullscreen-panel)
  ())

(defmethod (setf active-p) :after (value (panel menuing-panel))
  (when value
    (setf (active-p (action-set 'in-menu)) T)))

(defclass pausing-panel (fullscreen-panel)
  ())

(defmethod show :after ((panel pausing-panel) &key)
  (pause-game T (unit 'ui-pass T)))

(defmethod hide :after ((panel pausing-panel))
  (unpause-game T (unit 'ui-pass T)))

(defclass messagebox (alloy:dialog alloy:observable)
  ((message :initarg :message :accessor message))
  (:default-initargs :accept "Ok" :reject NIL :title "Message"))

(defmethod alloy:reject ((box messagebox)))
(defmethod alloy:accept ((box messagebox)))

(defmethod initialize-instance :after ((box messagebox) &key)
  (alloy:represent (message box) 'alloy:label
                   :style `((:label :wrap T :pattern ,colors:white :valign :top :halign :left))
                   :layout-parent box))

(defun messagebox (message &rest format-args)
  (alloy:with-unit-parent (unit 'ui-pass T)
    (let ((box (make-instance 'messagebox :ui (unit 'ui-pass T)
                                          :message (apply #'format NIL message format-args)
                                          :extent (alloy:extent (alloy:u- (alloy:vw 0.5) 300)
                                                                (alloy:u- (alloy:vh 0.5) 200)
                                                                300 200))))
      (alloy:ensure-visible (alloy:layout-element box) T))))

(defun make-basic-background ()
  (let ((pass (unit 'ui-pass T)))
    (alloy:with-unit-parent pass
      (simple:rectangle pass (alloy:margins) :pattern
                        (simple:image-pattern pass (// 'kandria 'ui-background)
                                              :scaling (alloy:size (alloy:u/ (alloy:px 32) (alloy:vw 1))
                                                                   (alloy:u/ (alloy:px 32) (alloy:vh 1))))))))

(define-setting-observer font :display :font ()
  (when (unit 'ui-pass T)
    (alloy:refresh (unit 'ui-pass T))))

(define-setting-observer ui-scale :display :ui-scale ()
  (when (unit 'ui-pass T)
    (alloy:refresh (unit 'ui-pass T))))

(define-language-change-hook ui ()
  (when (unit 'ui-pass T)
    (alloy:refresh (unit 'ui-pass T))))

(defclass ui-task (promise-task)
  ())

(defmethod simple-tasks:run-task ((task ui-task))
  (with-unwind-protection (! (hide-panel 'spinner-panel))
    (handler-case
        (with-error-logging (:kandria.async)
          (! (show-panel 'spinner-panel))
          (call-next-method))
      (not-authenticated ()
        (message (@ error-not-authenticated)))
      (usocket:ns-error ()
        (message (@ error-no-internet)))
      (usocket:socket-error ()
        (message (@ error-connection-failed-try-again)))
      (error (e)
        (message (@formats 'error-generic e))))))

(defmacro with-ui-task (&body body)
  `(with-eval-in-task-thread (:task-type 'ui-task)
     ,@body))
