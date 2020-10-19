(in-package #:org.shirakumo.fraf.kandria)

(alloy:define-widget editmenu (alloy:structure)
  ())

(alloy::define-subbutton (editmenu new) () (edit 'new-region T))
(alloy::define-subbutton (editmenu save) () (edit 'save-region T))
(alloy::define-subbutton (editmenu load) () (edit 'load-region T))
(alloy:define-subcomponent (editmenu zoom) ((zoom (unit :camera T)) alloy:ranged-slider
                                            :range '(0.1 . 3.0) :step 0.1 :grid 0.1
                                            :ideal-bounds (alloy:extent 0 0 100 20)))
(alloy::define-subbutton (editmenu undo) () (edit 'undo T))
(alloy::define-subbutton (editmenu redo) () (edit 'redo T))
(alloy:define-subcomponent (editmenu lighting) ((active-p (struct (// 'kandria 'gi))) alloy:switch
                                                :off 0 :on 1 :ideal-bounds (alloy:extent 0 0 50 20)))
(alloy:define-subcomponent (editmenu time) ((clock +world+) alloy:ranged-slider
                                            :range `(-140 . 340)
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
  (alloy:on (setf alloy:value) (value (slot-value menu 'lighting))
    (update-buffer-data (// 'kandria 'gi) T))
  (alloy:on (setf alloy:value) (value (slot-value menu 'time))
    (setf (alloy:value (slot-value menu 'lighting)) 1)
    (synchronize +world+ value)
    (update-lighting (unit 'lighting-pass T)))
  ;; KLUDGE: This appears necessary because the slots get reordered after
  ;;         creation again to put the superclass' structure slots before
  ;;         ours, causing the initialiser to run too early.
  (alloy:finish-structure menu (slot-value menu 'layout) (slot-value menu 'focus)))
