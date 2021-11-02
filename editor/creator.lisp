(in-package #:org.shirakumo.fraf.kandria)

(defparameter *creator-class-list*
  (sort
   '(basic-light textured-light
     checkpoint story-trigger interaction-trigger walkntalk-trigger sandstorm-trigger
     zoom-trigger pan-trigger teleport-trigger earthquake-trigger spawner place-marker action-prompt
     interactable-sprite interactable-animated-sprite
     dummy box wolf zombie drone tame-wolf ball balloon sawblade
     npc-block-zone catherine fi jack trader innis
     door passage locked-door save-point fishing-spot
     falling-platform elevator elevator-recall
     chunk water sludge magma rope grass heatwave)
   #'string<))

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
         (combo (alloy:represent class 'alloy:combo-set :value-set *creator-class-list* :layout-parent layout :focus-parent focus))
         (inspector (make-instance 'alloy::inspector :object (entity creator)))
         (scroll (make-instance 'alloy:scroll-view :scroll :y :focus inspector :layout inspector
                                                   :layout-parent layout :focus-parent focus)))
    (alloy:on alloy:value (class combo)
      (setf (entity creator) (make-instance class :location (vcopy (location (unit :camera T)))))
      (reinitialize-instance inspector :object (entity creator)))))

