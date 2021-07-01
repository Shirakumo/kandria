(in-package #:org.shirakumo.fraf.kandria)

(colored:define-color #:accent #x0088EE)

(defclass ui (org.shirakumo.fraf.trial.alloy:ui
              org.shirakumo.alloy:fixed-scaling-ui
              org.shirakumo.alloy.renderers.simple.presentations:default-look-and-feel)
  ((alloy:target-resolution :initform (alloy:px-size 1280 720))
   (alloy:scales :initform '((3840 T 2.0)
                             (2800 T 1.5)
                             (1920 T 1.25)
                             (1280 T 1.0)
                             (1000 T 0.8)
                             (T T 0.5)))))

(defmethod org.shirakumo.alloy.renderers.opengl.msdf:fontcache-directory ((ui ui))
  (pool-path 'kandria "font-cache/"))

(defclass button (alloy:button*)
  ())

(presentations:define-realization (ui button)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:label simple:text)
   (alloy:margins 5 10 10 5)
   alloy:text
   :font (setting :display :font)
   :halign :middle
   :valign :middle))

(presentations:define-update (ui button)
  (:background
   :pattern (case alloy:focus
              ((:weak :strong) (colored:color 1 1 1 0.5))
              (T colors:transparent)))
  (:label
   :size (alloy:un 20)
   :pattern colors:white))

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

(defmethod render :before ((pass ui-pass) target)
  (gl:enable :depth-test)
  (gl:clear-color 0 0 0 0))

(defmethod render :after ((pass ui-pass) target)
  (gl:disable :depth-test))

(defmethod handle :around ((ev event) (pass ui-pass))
  (unless (call-next-method)
    (dolist (panel (panels pass))
      (handle ev panel)
      (when (typep panel 'pausing-panel)
        (return)))))

(defmethod handle ((ev accept) (pass ui-pass))
  (alloy:handle (make-instance 'alloy:activate) pass))

(defmethod handle ((ev back) (pass ui-pass))
  (alloy:handle (make-instance 'alloy:exit) pass))

(defmethod handle ((ev next) (pass ui-pass))
  (alloy:handle (make-instance 'alloy:focus-next) pass))

(defmethod handle ((ev previous) (pass ui-pass))
  (alloy:handle (make-instance 'alloy:focus-prev) pass))

(defmethod handle ((ev text-entered) (pass ui-pass))
  (or (call-next-method)
      (process-cheats (text ev))))

(defmethod stage ((pass ui-pass) (area staging-area))
  (call-next-method)
  (dolist (panel (panels pass))
    (stage panel area))
  (stage (simple:request-font pass (setting :display :font)) area)
  (stage (framebuffer pass) area))

(defmethod compile-to-pass (object (pass ui-pass)))
(defmethod compile-into-pass (object container (pass ui-pass)))
(defmethod remove-from-pass (object (pass ui-pass)))

;; KLUDGE: No idea why this is necessary, fuck me.
(defmethod simple:request-font :around ((pass ui-pass) font &key)
  (let ((font (call-next-method)))
    (unless (and (alloy:allocated-p font)
                 (allocated-p (org.shirakumo.alloy.renderers.opengl.msdf:atlas font)))
      (trial:commit font (loader +main+) :unload NIL))
    font))

(defun find-panel (panel-type)
  (loop for panel in (panels (unit 'ui-pass T))
        do (when (typep panel panel-type)
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

(defun hide-panel (panel-type)
  (let ((panel (find-panel panel-type)))
    (when panel
      (hide panel))))

(defclass panel (alloy:structure)
  ((active-p :initform NIL :accessor active-p)))

(defmethod handle ((ev event) (panel panel)))

(defmethod show ((panel panel) &key ui)
  (when *context*
    ;; First stage and load
    (trial:commit panel (loader +main+) :unload NIL))
  ;; Then attach to the UI
  (let ((ui (or ui (unit 'ui-pass T))))
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
    (when (alloy:layout-tree (alloy:layout-element panel))
      (alloy:leave panel (alloy:root (alloy:layout-tree ui)))
      (alloy:leave panel (alloy:root (alloy:focus-tree ui)))
      (setf (panels ui) (remove panel (panels ui))))
    (setf (active-p panel) NIL)
    panel))

(defclass menuing-panel (panel)
  ())

(defmethod show :after ((panel menuing-panel) &key)
  ;; Hide prompts
  (alloy:do-elements (el (alloy:popups (alloy:layout-tree (unit 'ui-pass T))))
    (when (typep el 'prompt) (hide el)))
  ;; Clear pending events to avoid spurious inputs
  (discard-events +world+)
  (setf (active-p (action-set 'in-menu)) T))

(defmethod hide :after ((panel menuing-panel))
  ;; Clear pending events to avoid spurious inputs
  (discard-events +world+)
  (setf (active-p (action-set 'in-game)) T))

(defclass pausing-panel (menuing-panel)
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
