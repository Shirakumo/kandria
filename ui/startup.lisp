(in-package #:org.shirakumo.fraf.kandria)

(defclass swap-screen-layout (alloy:swap-layout alloy:renderable)
  ())

(presentations:define-realization (ui swap-screen-layout)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern colors:black))

(defclass swap-screen (pausing-panel menuing-panel)
  ((timer :initform 1.0 :accessor timer)
   (time-between-pages :initform 2.0 :accessor time-between-pages)))

(defmethod initialize-instance :after ((panel swap-screen) &key)
  (let* ((layout (make-instance 'swap-screen-layout)))
    (let ((page (make-instance 'org.shirakumo.alloy.layouts.constraint:layout)))
      (alloy:enter page layout))
    (setf (timer panel) (time-between-pages panel))
    (alloy:finish-structure panel layout NIL)))

(defmethod alloy:index ((panel swap-screen))
  (alloy:index (alloy:layout-element panel)))

(defmethod (setf alloy:index) (index (panel swap-screen))
  (let ((layout (alloy:layout-element panel)))
    (transition
      :kind :black
      (cond ((< index (alloy:element-count layout))
             (alloy:with-unit-parent layout
               (setf (timer panel) 0f0)
               (setf (alloy:index layout) index)))
            (T
             (hide panel))))
    index))

(defmethod handle ((ev tick) (screen swap-screen))
  (when (<= (time-between-pages screen) (incf (timer screen) (dt ev)))
    (setf (timer screen) 0f0)
    (incf (alloy:index screen))))

(defmethod handle ((ev skip) (screen swap-screen))
  (setf (timer screen) (time-between-pages screen)))

(defmethod handle ((ev advance) (screen swap-screen))
  (setf (timer screen) (time-between-pages screen)))

(defclass startup-screen (swap-screen)
  ())

(defmethod initialize-instance :after ((panel startup-screen) &key)
  (let* ((layout (alloy:layout-element panel)))
    (let ((page (make-instance 'org.shirakumo.alloy.layouts.constraint:layout)))
      (alloy:enter (make-instance 'label :value (@ startup-credits-line)
                                         :style `((:label :halign :middle :size ,(alloy:un 30))))
                   page :constraints `((:fill)))
      (alloy:enter page layout))
    (let ((page (make-instance 'org.shirakumo.alloy.layouts.constraint:layout)))
      (alloy:enter (make-instance 'icon :value (// 'kandria 'shirakumo-logo))
                   page :constraints `((:fill :w) (:height 200) (= :y (- (- (+ :ry (/ :rh 2)) (/ :h 2)) -100))))
      (alloy:enter (make-instance 'icon :value (// 'kandria 'trial-logo))
                   page :constraints `((:fill :w) (:height 200) (= :y (- (- (+ :ry (/ :rh 2)) (/ :h 2)) +100))))
      (alloy:enter page layout))))

(defmethod stage :after ((screen startup-screen) (area staging-area))
  (stage (// 'kandria 'shirakumo-logo) area)
  (stage (// 'kandria 'trial-logo) area))

(defmethod hide :after ((screen startup-screen))
  (setf (active-p (find-class 'in-menu)) T)
  (show-panel 'main-menu))
