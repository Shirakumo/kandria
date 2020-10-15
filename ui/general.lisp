(in-package #:org.shirakumo.fraf.kandria)

(defclass ui (org.shirakumo.fraf.trial.alloy:ui
              org.shirakumo.alloy:fixed-scaling-ui
              org.shirakumo.alloy.renderers.simple.presentations:default-look-and-feel)
  ((alloy:target-resolution :initform (alloy:px-size 1280 720))
   (alloy:scales :initform '((3840 T 1.75)
                             (2800 T 1.5)
                             (1920 T 1.25)
                             (1280 T 1.0)
                             (1000 T 0.8)
                             (T T 0.5)))))

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
  (make-instance 'alloy:fullscreen-layout :layout-parent (alloy:layout-tree pass)))

(defmethod render :before ((pass ui-pass) target)
  (gl:enable :depth-test)
  (gl:clear-color 0 0 0 0))

(defmethod render :after ((pass ui-pass) target)
  (gl:disable :depth-test))

(defmethod handle :around ((ev event) (pass ui-pass))
  (unless (call-next-method)
    (when (panels pass)
      (handle ev (first (panels pass))))))

(defmethod stage ((pass ui-pass) (area staging-area))
  (call-next-method)
  (stage (simple:request-font pass "PromptFont") area)
  (stage (framebuffer pass) area))

(defmethod compile-to-pass (object (pass ui-pass)))
(defmethod compile-into-pass (object container (pass ui-pass)))

;; KLUDGE: No idea why this is necessary, fuck me.
(defmethod simple:request-font :around ((pass ui-pass) font &key)
  (let ((font (call-next-method)))
    (unless (and (alloy:allocated-p font)
                 (allocated-p (org.shirakumo.alloy.renderers.opengl.msdf:atlas font)))
      (trial:commit font (loader (handler *context*)) :unload NIL))
    font))

(defun find-panel (panel-type)
  (find panel-type (panels (unit 'ui-pass T)) :key #'type-of))

(defun toggle-panel (panel-type &rest initargs)
  (let ((panel (find-panel panel-type)))
    (if panel
        (hide panel)
        (show (apply #'make-instance panel-type initargs)))))

(defclass panel (alloy:structure)
  ())

(defmethod handle ((ev event) (panel panel)))

(defmethod show ((panel panel) &key ui)
  (when *context*
    ;; First stage and load
    (trial:commit panel (loader (handler *context*)) :unload NIL))
  ;; Then attach to the UI
  (let ((ui (or ui (unit 'ui-pass T))))
    (alloy:enter panel (alloy:root (alloy:layout-tree ui)))
    (setf (alloy:root (alloy:focus-tree ui)) (alloy:focus-element panel))
    (alloy:register panel ui)
    (push panel (panels ui))
    panel))

(defmethod hide ((panel panel))
  (let ((ui (unit 'ui-pass T)))
    ;; Make sure we hide things on top first.
    (loop until (eq panel (first (panels ui)))
          do (hide (first (panels ui))))
    (alloy:leave panel (alloy:root (alloy:layout-tree ui)))
    (setf (panels ui) (remove panel (panels ui)))
    (setf (alloy:root (alloy:focus-tree ui)) (when (panels ui) (alloy:focus-element (first (panels ui)))))
    panel))

(defclass pausing-panel (panel)
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
