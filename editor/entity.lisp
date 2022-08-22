(in-package #:org.shirakumo.fraf.kandria)

(alloy:define-widget entity-widget (sidebar)
  ((entity :initarg :entity :initform NIL :accessor entity
           :representation (alloy:label :ideal-size (alloy:size 0 0)))))

(alloy:define-subcomponent (entity-widget region) ((name (unit 'region T)) alloy:label))
(alloy:define-subbutton (entity-widget insert) () (edit 'insert-entity T))
(alloy:define-subbutton (entity-widget clone) () (edit 'clone-entity T))
(alloy:define-subbutton (entity-widget delete) () (edit 'delete-entity T))
(alloy:define-subobject (entity-widget inspector) ('alloy::inspector :object (entity entity-widget))
  (alloy:on entity (entity entity-widget)
    (reinitialize-instance inspector :object entity)))

(alloy:define-subcontainer (entity-widget layout)
    (alloy:vertical-linear-layout)
  region
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

(defmethod place-width ((widget sprite-widget)) (floor (vx (size (entity widget))) 16))
(defmethod place-height ((widget sprite-widget)) (floor (vy (size (entity widget))) 16))
(defmethod (setf place-width) (value (widget sprite-widget)))
(defmethod (setf place-height) (value (widget sprite-widget)))

(defmethod tile-to-place ((widget sprite-widget))
  (let ((offset (offset (entity widget)))
        (size (size (entity widget))))
    (list (floor (vx offset) 16) (floor (vy offset) 16)
          (floor (vx size) 16) (floor (vy size) 16))))

(defmethod (setf tile-to-place) (tile (widget sprite-widget))
  (destructuring-bind (x y w h) tile
    (let ((offset (vec (* 16 x) (* 16 y)))
          (size (vec (* 16 w) (* 16 h))))
      (setf (offset (entity widget)) offset)
      (setf (size (entity widget)) size)
      (setf (bsize (entity widget)) (v/ size 2)))))

(alloy:define-subobject (sprite-widget tiles) ('tile-picker :widget sprite-widget))

(alloy:define-subcontainer (sprite-widget layout)
    (alloy:grid-layout :col-sizes '(T) :row-sizes '(T))
  tiles)

(alloy:define-subcontainer (sprite-widget focus)
    (alloy:focus-list)
  tiles)

(defmethod (setf entity) :after ((entity sprite-entity) (editor editor))
  (setf (sidebar editor) (make-instance 'sprite-widget :editor editor :side :east)))
