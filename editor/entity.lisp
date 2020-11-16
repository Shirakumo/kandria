(in-package #:org.shirakumo.fraf.kandria)

(alloy:define-widget entity-widget (sidebar)
  ((entity :initarg :entity :initform NIL :accessor entity
           :representation (alloy:label))))

(alloy:define-subcomponent (entity-widget region) ((name (unit 'region T)) alloy:label))
(alloy:define-subbutton (entity-widget insert) () (edit 'insert-entity T))
(alloy:define-subbutton (entity-widget clone) () (edit 'clone-entity T))
(alloy:define-subbutton (entity-widget delete) () (edit 'delete-entity T))
(alloy:define-subobject (entity-widget inspector) ('alloy::inspector :object (entity entity-widget))
  (alloy:on entity (entity entity-widget)
    (reinitialize-instance inspector :object entity)))

(alloy:define-subcontainer (entity-widget layout)
    (alloy:vertical-linear-layout)
  region entity
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(T T T) :row-sizes '(30) :cell-margins (alloy:margins 1 0 0 0)
    insert clone delete))
  inspector)

(alloy:define-subcontainer (entity-widget focus)
    (alloy:focus-list)
  insert clone delete inspector)

(defmethod default-tool ((_ sized-entity))
  'freeform)

(alloy:define-widget sprite-widget (sidebar)
  ())

(defmethod (setf tile-to-place) (tile (widget sprite-widget))
  (let ((offset (v* tile 16)))
    (cond ((retained :left-control)
           (let ((other (offset (entity widget))))
             (let ((bl (vmin offset other))
                   (tr (v+ 16 (vmax offset other))))
               (setf (offset (entity widget)) bl)
               (setf (size (entity widget)) (v- tr bl))
               (setf (bsize (entity widget)) (v/ (size (entity widget)) 2)))))
          (T
           (setf (offset (entity widget)) offset)))))

(alloy:define-subobject (sprite-widget tiles) ('tile-picker :widget sprite-widget))

(alloy:define-subcontainer (sprite-widget layout)
    (alloy:grid-layout :col-sizes '(T) :row-sizes '(T))
  tiles)

(alloy:define-subcontainer (sprite-widget focus)
    (alloy:focus-list)
  tiles)

(defmethod (setf entity) :after ((entity sprite-entity) (editor editor))
  (setf (sidebar editor) (make-instance 'sprite-widget :editor editor :side :east)))
