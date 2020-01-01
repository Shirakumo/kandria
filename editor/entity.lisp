(in-package #:org.shirakumo.fraf.leaf)

(alloy:define-widget entity-widget (sidebar)
  ((entity :initarg :entity :initform NIL :accessor entity
           :representation (alloy:label))))

(alloy:define-subcomponent (entity-widget region) ((name (unit 'region T)) alloy:label))
(alloy::define-subbutton (entity-widget insert) ()
  (issue +world+ (make-instance 'insert-entity)))
(alloy::define-subbutton (entity-widget clone) ()
  (issue +world+ (make-instance 'clone-entity)))
(alloy::define-subbutton (entity-widget delete) ()
  (leave (entity entity-widget) (unit 'region T)))
(alloy:define-subobject (entity-widget inspector) ('alloy::inspector :object (entity entity-widget))
  (alloy:on (setf entity) (entity entity-widget)
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
