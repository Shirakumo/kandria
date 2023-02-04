(in-package #:org.shirakumo.fraf.kandria)

(alloy:define-widget entity-widget (sidebar)
  ((entity :initarg :entity :initform NIL :accessor entity
           :representation (alloy:label :ideal-size (alloy:size 0 0)))))

(alloy:define-subbutton (entity-widget insert) () (edit 'insert-entity T))
(alloy:define-subbutton (entity-widget clone) () (edit 'clone-entity T))
(alloy:define-subbutton (entity-widget delete) () (edit 'delete-entity T))
(alloy:define-subobject (entity-widget inspector) ('alloy::inspector :object (entity entity-widget))
  (alloy:on entity (entity entity-widget)
    (reinitialize-instance inspector :object entity)))

(alloy:define-subcontainer (entity-widget layout)
    (alloy:vertical-linear-layout)
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
  (tile-to-place (entity widget)))

(defmethod (setf tile-to-place) (tile (widget sprite-widget))
  (setf (tile-to-place (entity widget)) tile))

(alloy:define-subobject (sprite-widget tiles) ('tile-picker :widget sprite-widget :tile-size (picker-tile-size (entity sprite-widget))))

(alloy:define-subcontainer (sprite-widget layout)
    (alloy:grid-layout :col-sizes '(T) :row-sizes '(T))
  tiles)

(alloy:define-subcontainer (sprite-widget focus)
    (alloy:focus-list)
  tiles)

(defmethod (setf entity) :after ((entity sprite-entity) (editor editor))
  (setf (sidebar editor) (make-instance 'sprite-widget :editor editor :side :east)))

(defmethod picker-tile-size ((entity sprite-entity))
  (vec +tile-size+ +tile-size+))

(defmethod tile-to-place ((entity sprite-entity))
  (let ((offset (offset entity))
        (size (size entity)))
    (list (floor (vx offset) 16) (floor (vy offset) 16)
          (floor (vx size) 16) (floor (vy size) 16))))

(defmethod (setf tile-to-place) (tile (entity sprite-entity))
  (destructuring-bind (x y w h) tile
    (let ((offset (vec (* 16 x) (* 16 y)))
          (size (vec (* 16 w) (* 16 h))))
      (setf (offset entity) offset)
      (setf (size entity) size)
      (setf (bsize entity) (v/ size 2)))))

(defmethod (setf entity) :after ((entity grass-patch) (editor editor))
  (setf (sidebar editor) (make-instance 'sprite-widget :editor editor :side :east)))

(defmethod picker-tile-size ((entity grass-patch))
  (vec 4 4))

(defmethod tile-to-place ((entity grass-patch))
  (let ((offset (tile-start entity))
        (size (tile-size entity))
        (ps (picker-tile-size entity)))
    (list (floor (vx offset) (vx ps)) (floor (vy offset) (vy ps))
          (floor (vx size) (vx ps)) (floor (vy size) (vy ps)))))

(defmethod (setf tile-to-place) (tile (entity grass-patch))
  (destructuring-bind (x y w h) tile
    (let ((s (picker-tile-size entity)))
      (setf (tile-start entity) (vec (* (vx s) x) (* (vy s) y)))
      (setf (tile-size entity) (vec (* (vy s) w) (* (vy s) h)))
      (setf (tile-count entity) 1))))
