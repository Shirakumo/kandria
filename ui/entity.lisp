(in-package #:org.shirakumo.fraf.leaf)

(alloy:define-widget entity-widget (sidebar)
  ((entity :initarg :entity :initform NIL :accessor entity
           :representation (alloy:label))))

(alloy:define-subcomponent (entity-widget region) ((name (unit 'region T)) alloy:label))
(alloy::define-subbutton (entity-widget move) ()
  )
(alloy::define-subbutton (entity-widget clone) ()
  )
(alloy::define-subbutton (entity-widget delete) ()
  (leave (entity entity-widget) (unit 'region T)))

(alloy:define-subcontainer (entity-widget layout)
    (alloy:vertical-linear-layout)
  region entity
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(T T T) :row-sizes '(30)
    move clone delete)))

(alloy:define-subcontainer (entity-widget focus)
    (alloy:focus-list)
  move clone delete)
