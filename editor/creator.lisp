(in-package #:org.shirakumo.fraf.kandria)

(defclass creator (alloy:dialog)
  ((entity :initform NIL :accessor entity))
  (:default-initargs
   :title "Create Entity"
   :extent (alloy:size 400 500)))

(defmethod alloy:reject ((creator creator)))

(defmethod alloy:accept ((creator creator))
  (let ((entity (entity creator)))
    (when entity
      (setf (location entity) (closest-acceptable-location entity (location entity)))
      (edit (make-instance 'insert-entity :entity entity) T))))

(defmethod initialize-instance :after ((creator creator) &key)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(T) :row-sizes '(30 T) :layout-parent creator))
         (focus (make-instance 'alloy:focus-list :focus-parent creator))
         (class NIL)
         (classes (sort (list-creatable-classes) #'string<))
         (combo (alloy:represent class 'alloy:combo-set :value-set classes :layout-parent layout :focus-parent focus))
         (inspector (make-instance 'alloy::inspector :object (entity creator)))
         (scroll (make-instance 'alloy:scroll-view :scroll :y :focus inspector :layout inspector
                                                   :layout-parent layout :focus-parent focus)))
    (alloy:on alloy:value (class combo)
      (when class
        (setf (entity creator) (make-instance class :location (vcopy (location (camera +world+)))))
        (reinitialize-instance inspector :object (entity creator))))))

