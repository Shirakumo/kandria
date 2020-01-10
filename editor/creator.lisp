(in-package #:org.shirakumo.fraf.leaf)

(defclass creator (alloy:dialog)
  ((entity :initform NIL :accessor entity))
  (:default-initargs
   :title "Create Entity"
   :extent (alloy:size 400 500)))

(defmethod alloy:reject ((creator creator)))

(defmethod alloy:accept ((creator creator))
  (edit (make-instance 'insert-entity :entity (entity creator)) T))

(defmethod initialize-instance :after ((creator creator) &key)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(T) :row-sizes '(30 T) :layout-parent creator))
         (focus (make-instance 'alloy:focus-list :focus-parent creator))
         (classes (list-leaf-classes 'base-entity))
         (class (first classes))
         (combo (alloy:represent class 'alloy:combo-set :value-set classes :layout-parent layout :focus-parent focus))
         (inspector (make-instance 'alloy::inspector :object (entity creator)))
         (scroll (make-instance 'alloy:scroll-view :scroll :y :focus inspector :layout inspector
                                                   :layout-parent layout :focus-parent focus)))
    (alloy:on (setf alloy:value) (class combo)
      (setf (entity creator) (make-instance class))
      (reinitialize-instance inspector :object (entity creator)))))

