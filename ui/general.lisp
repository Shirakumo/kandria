(in-package #:org.shirakumo.fraf.leaf)

(defclass ui (org.shirakumo.fraf.trial.alloy:ui
              org.shirakumo.alloy:fixed-scaling-ui
              org.shirakumo.alloy.renderers.simple.presentations:default-look-and-feel)
  ((alloy:target-resolution :initform (alloy:px-size 1280 720))
   (alloy:scales :initform '((3840 T 2.5)
                             (2800 T 2.0)
                             (1920 T 1.5)
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

(defclass sidebar (single-widget)
  ((side :initarg :side :accessor side)
   (entity :initform NIL :accessor entity)
   (editor :initarg :editor :initform (alloy:arg! :editor) :accessor editor))
  (:metaclass alloy:widget-class))

(defmethod initialize-instance :before ((sidebar sidebar) &key editor)
  (setf (slot-value sidebar 'entity) (entity editor)))

(alloy:define-subobject (sidebar representation -100) ('alloy:sidebar :side (side sidebar))
  (alloy:enter (slot-value sidebar 'layout) representation)
  (alloy:enter (slot-value sidebar 'focus) representation))

(define-shader-pass ui-pass (ui)
  ((name :initform 'ui-pass)
   (panels :initform NIL :accessor panels)
   (color :port-type output :attachment :color-attachment0)
   (depth :port-type output :attachment :depth-stencil-attachment)))

(defmethod initialize-instance :after ((pass ui-pass) &key)
  (make-instance 'alloy:fullscreen-layout :layout-parent (alloy:layout-tree pass)))

(defmethod render :before ((pass ui-pass) target)
  (gl:clear-color 0 0 0 0))

(defmethod handle :after ((ev event) (pass ui-pass))
  (when (panels pass)
    (handle ev (first (panels pass)))))

(defmethod stage ((pass ui-pass) (area staging-area))
  (call-next-method)
  (stage (framebuffer pass) area))

(defmethod compile-to-pass (object (pass ui-pass)))
(defmethod compile-into-pass (object container (pass ui-pass)))

;; KLUDGE: No idea why this is necessary, fuck me.
(defmethod simple:request-font :around ((pass ui-pass) font &key)
  (let ((font (call-next-method)))
    (trial:commit font (loader (handler *context*)) :unload NIL)
    font))

(defclass panel (alloy:structure)
  ())

(defmethod handle ((ev event) (panel panel)))

(defmethod show ((panel panel) &key)
  ;; First stage and load
  (trial:commit panel (loader (handler *context*)) :unload NIL)
  ;; Then attach to the UI
  (let ((ui (unit 'ui-pass T)))
    (alloy:enter panel (alloy:root (alloy:layout-tree ui)))
    (setf (alloy:root (alloy:focus-tree ui)) panel)
    (alloy:register panel ui)
    (push panel (panels ui))
    panel))

(defmethod hide ((panel panel))
  (let ((ui (unit 'ui-pass T)))
    (alloy:leave panel (alloy:root (alloy:layout-tree ui)))
    (setf (panels ui) (remove panel (panels ui)))
    (setf (alloy:root (alloy:focus-tree ui)) (first (panels ui)))
    panel))

(defclass messagebox (alloy:popup alloy:focus-list org.shirakumo.alloy.layouts.constraint:layout alloy:observable)
  ((message :initarg :message :accessor message)))

(defmethod initialize-instance :after ((box messagebox) &key)
  (let ((message (alloy:represent (message box) 'alloy:label))
        (button (alloy:represent "Ok" 'alloy:button)))
    (alloy:enter message box :constraint `((:margin 10 10 10 40)))
    (alloy:enter button box :constraint `((:below ,message) (:height 30)))
    (alloy:on alloy:activate (button)
      (alloy:activate box))))

(defmethod alloy:activate ((box messagebox))
  (alloy:leave box T))

(presentations:define-realization (ui messagebox)
  ((:hider simple:rectangle)
   (alloy:extent 0 0 (alloy:vw 1) (alloy:vh 1))
   :pattern (colored:color 0 0 0 0.5))
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.2 0.2 0.2)))
