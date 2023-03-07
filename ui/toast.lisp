(in-package #:org.shirakumo.fraf.kandria)

(defclass toast-label (alloy:label)
  ())

(presentations:define-realization (ui toast-label)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :pattern colors:black
   :halign :start
   :valign :middle
   :font (setting :display :font)
   :size (alloy:un 18)
   :wrap NIL))

(defclass toast (org.shirakumo.alloy.layouts.constraint:layout
                 alloy:component
                 alloy:popup
                 alloy:renderable)
  ((timer :initform 5.0 :accessor timer)))

(defmethod initialize-instance :after ((toast toast) &key (valign :top) (halign :right))
  (let ((label (alloy:represent-with 'toast-label (alloy:data toast)))
        (close (alloy:represent "" 'alloy:label :style `((:label :valign :middle)))))
    (alloy:enter close toast :constraints `((:left 10) (:center :h) (:size 20 20)))
    (alloy:enter label toast :constraints `((:margin 30 10 10 10)))
    (alloy:enter toast (u 'ui-pass) :x 10 :y 10 :w 200 :h 50)
    (presentations:realize-renderable (u 'ui-pass) label)
    (let* ((size (alloy:suggest-size (alloy:px-size 0 0) label))
           (w (+ 10 (alloy:pxx label) (alloy:pxw size)))
           (h (+ 10 (alloy:pxh size))))
      (alloy:update toast (alloy:layout-parent toast)
                    :x (alloy:px (ecase halign
                                   ((:left :west :start) 10)
                                   ((:right :east :end) (- (alloy:pxw (u 'ui-pass)) w 10))))
                    :y (alloy:px (ecase valign
                                   ((:bottom :south :down) 10)
                                   ((:top :north :up) (- (alloy:pxh (u 'ui-pass)) h 10))))
                    :w (alloy:px w) :h (alloy:px h)))))

(defmethod alloy:activate ((toast toast))
  (alloy:close toast))

(defmethod alloy:close ((toast toast))
  (alloy:leave toast T))

(defmethod animation:update :before ((toast toast) dt)
  (when (<= (decf (timer toast) dt) 0.0)
    (alloy:close toast)))

(defun toast (text &rest initargs)
  (apply #'alloy:represent-with 'toast (make-instance 'alloy:value-data :value text) initargs))

(presentations:define-realization (ui toast)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0.5 0)))
