(in-package #:org.shirakumo.fraf.kandria)

(alloy:define-widget editmenu (alloy:structure)
  ((lighting :initform NIL :representation (alloy:switch :ideal-bounds (alloy:extent 0 0 50 20)))))

(defclass zoom-slider (alloy:ranged-slider)
  ())

(defmethod alloy:value ((slider zoom-slider))
  (let ((val (call-next-method)))
    (expt val 1/5)))

(defmethod (setf alloy:value) (value (slider zoom-slider))
  (call-next-method (expt value 5) slider))

(alloy::define-subbutton (editmenu new) () (edit 'new-region T))
(alloy::define-subbutton (editmenu save) () (edit 'save-region T))
(alloy::define-subbutton (editmenu load) () (edit 'load-region T))
(alloy:define-subcomponent (editmenu zoom) ((zoom (unit :camera T)) zoom-slider
                                            :range '(0.3 . 1.3) :step 0.05 :grid 0.05
                                            :ideal-bounds (alloy:extent 0 0 100 20)))
(alloy::define-subbutton (editmenu undo) () (edit 'undo T))
(alloy::define-subbutton (editmenu redo) () (edit 'redo T))
(alloy:define-subcomponent (editmenu time) ((hour +world+) alloy:ranged-slider
                                            :range `(0 . 24)
                                            :ideal-bounds (alloy:extent 0 0 100 20)))

(alloy:define-subcontainer (editmenu layout :if-exists :supersede)
    (alloy:horizontal-linear-layout :cell-margins (alloy:margins 3 3)
                                    :shapes (list (make-instance 'simple:filled-rectangle :bounds (alloy:margins)
                                                                                          :name :background))
                                    :style `((:background :pattern ,(colored:color 0.1 0.1 0.1))))
  new save load zoom undo redo lighting time)

(alloy:define-subcontainer (editmenu focus :if-exists :supersede)
    (alloy:focus-list)
  new save load zoom undo redo lighting time)

(defmethod initialize-instance :after ((menu editmenu) &key)
  (alloy:on alloy:value (value (alloy:representation 'lighting menu))
    (setf (lighting (unit 'lighting-pass T))
          (if value
              (gi (chunk (unit :camera T)))
              (gi 'none)))
    (force-lighting (unit 'lighting-pass T)))
  (alloy:on alloy:value (value (slot-value menu 'time))
    (setf (alloy:value (alloy:representation 'lighting menu)) T)
    (synchronize +world+ value)
    (update-lighting (unit 'lighting-pass T)))
  ;; KLUDGE: This appears necessary because the slots get reordered after
  ;;         creation again to put the superclass' structure slots before
  ;;         ours, causing the initialiser to run too early.
  (alloy:finish-structure menu (slot-value menu 'layout) (slot-value menu 'focus)))
