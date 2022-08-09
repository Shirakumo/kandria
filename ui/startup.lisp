(in-package #:org.shirakumo.fraf.kandria)

(defclass startup-screen-layout (alloy:swap-layout alloy:renderable)
  ())

(presentations:define-realization (ui startup-screen-layout)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern colors:black))

(defclass startup-screen (menuing-panel)
  ((timer :initform 1.0 :accessor timer)))

(defmethod initialize-instance :after ((panel startup-screen) &key)
  (let* ((layout (make-instance 'startup-screen-layout)))
    (let ((page (make-instance 'org.shirakumo.alloy.layouts.constraint:layout)))
      (alloy:enter page layout))
    (let ((page (make-instance 'org.shirakumo.alloy.layouts.constraint:layout)))
      (alloy:enter (make-instance 'label :value "A game by Shinmera, Tim, Blob, Mikel, and Cai."
                                         :style `((:label :halign :middle :size ,(alloy:un 30))))
                   page :constraints `((:fill)))
      (alloy:enter page layout))
    (let ((page (make-instance 'org.shirakumo.alloy.layouts.constraint:layout)))
      (alloy:enter (make-instance 'icon :value (// 'kandria 'shirakumo-logo))
                   page :constraints `((:fill :w) (:height 200) (= :y (- (- (+ :ry (/ :rh 2)) (/ :h 2)) -100))))
      (alloy:enter (make-instance 'icon :value (// 'kandria 'trial-logo))
                   page :constraints `((:fill :w) (:height 200) (= :y (- (- (+ :ry (/ :rh 2)) (/ :h 2)) +100))))
      (alloy:enter page layout))
    (alloy:finish-structure panel layout NIL)))

(defmethod alloy:index ((panel startup-screen))
  (alloy:index (alloy:layout-element panel)))

(defmethod (setf alloy:index) (index (panel startup-screen))
  (let ((layout (alloy:layout-element panel)))
    (transition
      :kind :black
      (cond ((< index (alloy:element-count layout))
             (alloy:with-unit-parent layout
               (setf (timer panel) 0f0)
               (setf (alloy:index layout) index)))
            (T
             (hide panel)
             (show-panel 'main-menu))))))

(defmethod stage :after ((screen startup-screen) (area staging-area))
  (stage (// 'kandria 'shirakumo-logo) area)
  (stage (// 'kandria 'trial-logo) area))

(defmethod handle ((ev tick) (screen startup-screen))
  (when (<= 2.0 (incf (timer screen) (dt ev)))
    (setf (timer screen) 0f0)
    (incf (alloy:index screen))))
