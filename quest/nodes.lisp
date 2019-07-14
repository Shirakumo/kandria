(in-package #:org.shirakumo.fraf.leaf.quest.graph)

(defclass describable ()
  ((title :initarg :title :accessor title)
   (description :initarg :description :accessor description))
  (:default-initargs
   :title (error "TITLE required")
   :description ""))

(defmethod print-object ((describable describable) stream)
  (print-unreadable-object (describable stream :type T)
    (format stream "~s" (title describable))))

(defclass causes (flow:in-port flow:n-port)
  ())

(defmethod flow:check-connection-accepted progn (connection (port causes))
  (check-type connection flow:directed-connection)
  (check-type (flow:node (flow:left connection)) (or task start))
  (check-type (flow:node (flow:right connection)) (or task end)))

(defclass effects (flow:out-port flow:n-port)
  ())

(defmethod flow:check-connection-accepted progn (connection (port effects))
  (check-type connection flow:directed-connection)
  (check-type (flow:node (flow:left connection)) (or task start))
  (check-type (flow:node (flow:right connection)) (or task end)))

(defclass triggers (flow:n-port)
  ())

(defmethod flow:check-connection-accepted progn (connection (port triggers))
  (etypecase (flow:left connection)
    (task (check-type (flow:node (flow:right connection)) trigger))
    (trigger (check-type (flow:node (flow:right connection)) task))))

(defclass tasks (flow:n-port)
  ())

(defmethod flow:check-connection-accepted progn (connection (port tasks))
  (etypecase (flow:left connection)
    (task (check-type (flow:node (flow:right connection)) trigger))
    (trigger (check-type (flow:node (flow:right connection)) task))))

(flow:define-node task (describable)
  ((causes :port-type causes)
   (effects :port-type effects)
   (triggers :port-type triggers)
   (invariant :initarg :invariant :accessor invariant)
   (condition :initarg :condition :accessor condition)))

(defmethod causes ((task task))
  (loop for connection in (slot-value task 'causes)
        collect (flow:node (flow:left connection))))

(defmethod effects ((task task))
  (loop for connection in (slot-value task 'effects)
        collect (flow:node (flow:right connection))))

(defmethod triggers ((task task))
  (loop for connection in (slot-value task 'triggers)
        collect (flow:node (if (eql task (flow:node (flow:left connection)))
                               (flow:right connection)
                               (flow:left connection)))))

(flow:define-node trigger ()
  ((tasks :port-type tasks)))

(defmethod tasks ((trigger trigger))
  (loop for connection in (slot-value trigger 'tasks)
        collect (flow:node (if (eql trigger (flow:node (flow:left connection)))
                               (flow:right connection)
                               (flow:left connection)))))

(flow:define-node interaction (trigger)
  ((interactable :initarg :interactable :accessor interactable)
   (dialogue :initarg :dialogue :accessor dialogue)))

(flow:define-node start ()
  ((effects :port-type effects)))

(flow:define-node end ()
  ((causes :port-type causes)))

(defmethod connect ((cause start) (effect task))
  (flow:connect (flow:port cause 'effects) (flow:port effect 'causes)
                'flow:directed-connection))

(defmethod connect ((cause task) (effect end))
  (flow:connect (flow:port cause 'effects) (flow:port effect 'causes)
                'flow:directed-connection))

(defmethod connect ((cause task) (effect task))
  (flow:connect (flow:port cause 'effects) (flow:port effect 'causes)
                'flow:directed-connection))

(defmethod connect ((task task) (trigger trigger))
  (flow:connect (flow:port task 'triggers) (flow:port trigger 'tasks)))

(defmethod connect ((trigger trigger) (task task))
  (connect task trigger))
