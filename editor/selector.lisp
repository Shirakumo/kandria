(in-package #:org.shirakumo.fraf.kandria)

(defclass selector (alloy:dialog)
  ((entity :initform NIL :accessor entity))
  (:default-initargs
   :title "Select Entity"
   :extent (alloy:size 400 500)))

(defmethod alloy:reject ((selector selector)))

(defmethod alloy:accept ((selector selector))
  (setf (entity (find-panel 'editor)) (unit (entity selector) T))
  (snap-to-target (camera +world+) (unit (entity selector) T)))

(defclass entitylist (alloy:vertical-linear-layout alloy:focus-list)
  ())

(defclass entitybutton (alloy:direct-value-component alloy:button)
  ((selector :initarg :selector :accessor selector)))

(presentations:define-update (ui entitybutton)
  (:background
   :pattern (if (eq (entity (selector alloy:renderable)) alloy:value)
                colors:gray
                colors:transparent))
  (:label
   :size (alloy:un 12)
   :pattern colors:white
   :halign :start))

(defmethod alloy:activate :after ((button entitybutton))
  (setf (entity (selector button)) (alloy:value button)))

(defmethod initialize-instance :after ((selector selector) &key)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(T) :row-sizes '(30 T) :layout-parent selector))
         (focus (make-instance 'alloy:focus-list :focus-parent selector))
         (entities (sort (loop for entity being the hash-values of (name-map +world+)
                               when (typep entity 'located-entity)
                               collect (name entity))
                         #'string<))
         (filter "")
         (search (alloy:represent filter 'alloy:input-line))
         (entitylist (make-instance 'entitylist)))
    (alloy:enter search layout)
    (alloy:enter search focus)
    (make-instance 'alloy:scroll-view :scroll :y :focus entitylist :layout entitylist
                                      :layout-parent layout :focus-parent focus)
    (alloy:on alloy:value (value search)
      (alloy:clear entitylist)
      (loop for entity in entities
            do (when (search value (format NIL "~a:~a" (package-name (symbol-package entity)) (symbol-name entity)) :test #'char-equal)
                 (alloy:enter (make-instance 'entitybutton :selector selector :value entity) entitylist))))
    (setf (alloy:value search) "")))
