(in-package #:org.shirakumo.fraf.leaf)

(defclass ui (org.shirakumo.fraf.trial.alloy:ui
              org.shirakumo.alloy:fixed-scaling-ui)
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

(define-shader-pass ui-pass (render-pass)
  ((name :initform 'ui-pass)))

(defmethod render :before ((pass ui-pass) target)
  (gl:clear-color 0 0 0 0))

(defmethod object-renderable-p ((renderable renderable) (pass ui-pass)) NIL)
(defmethod object-renderable-p ((ui ui) (pass shader-pass)) NIL)
(defmethod object-renderable-p ((controller controller) (pass ui-pass)) T)
(defmethod object-renderable-p ((ui ui) (pass ui-pass)) T)
