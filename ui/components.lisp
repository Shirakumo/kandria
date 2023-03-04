(in-package #:org.shirakumo.fraf.kandria)

;; KLUDGE: This shit is way too verbose. Ugh, alloy.

(defclass background-item (alloy:combo-item) ())

(defmethod alloy:text ((bg background-item))
  (string (name (alloy:value bg))))

(defmethod alloy:combo-item ((bg background-info) (combo alloy:combo))
  (make-instance 'background-item :value bg))

(defclass background-chooser (alloy:combo) ())

(defmethod alloy:text ((bg background-chooser))
  (string (name (alloy:value bg))))

(defmethod alloy:value-set ((bg background-chooser))
  (list-backgrounds))

(defmethod alloy:component-class-for-object ((bg background-info))
  (find-class 'background-chooser))

(defclass gi-item (alloy:combo-item) ())

(defmethod alloy:text ((gi gi-item))
  (string (name (alloy:value gi))))

(defmethod alloy:combo-item ((gi gi-info) (combo alloy:combo))
  (make-instance 'gi-item :value gi))

(defclass gi-chooser (alloy:combo) ())

(defmethod (setf alloy:value) ((null null) (chooser gi-chooser)))

(defmethod alloy:text ((gi gi-chooser))
  (string (name (alloy:value gi))))

(defmethod alloy:value-set ((gi gi-chooser))
  (list-gis))

(defmethod alloy:component-class-for-object ((gi gi-info))
  (find-class 'gi-chooser))
