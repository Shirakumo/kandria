(in-package #:org.shirakumo.fraf.kandria)

(defclass toolbar (alloy:structure)
  ())

(defmethod initialize-instance :after ((toolbar toolbar) &key editor entity)
  (let ((layout (make-instance 'alloy:horizontal-linear-layout
                               :cell-margins (alloy:margins 3 3)
                               :min-size (alloy:size 50 20)
                               :shapes (list (make-instance 'simple:filled-rectangle :bounds (alloy:margins)
                                                                                     :name :background))
                               :style `((:background :pattern ,(colored:color 0.1 0.1 0.1)))))
        (focus (make-instance 'alloy:focus-list)))
    (populate-toolbar layout focus editor entity)
    (alloy:finish-structure toolbar layout focus)))

(defmethod reinitialize-instance :after ((toolbar toolbar) &key editor entity)
  (let ((layout (alloy:layout-element toolbar))
        (focus (alloy:focus-element toolbar)))
    (alloy:clear layout)
    (alloy:clear focus)
    (populate-toolbar layout focus editor entity)
    (alloy:register layout (unit 'ui-pass T))))

(defclass tool-button (alloy:radio)
  ())

(defmethod alloy:preferred-size ((button tool-button))
  (alloy:size 50 20))

(presentations:define-realization (ui tool-button)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:icon simple:text)
   (alloy:margins)
   (label (alloy:active-value alloy:renderable))
   :halign :middle
   :valign :middle
   :pattern colors:white
   :size 10
   :font "Icons"))

(presentations:define-update (ui tool-button)
  (:background
   :pattern (cond (alloy:focus
                   (colored:color 0.3 0.3 0.3))
                  ((alloy:active-p alloy:renderable)
                   (colored:color 0.2 0.2 0.2))
                  (T
                   colors:black))))

(defun populate-toolbar (layout focus editor entity)
  (dolist (tool (applicable-tools entity))
    (let* ((tool (make-instance tool :editor editor))
           (button (alloy:represent (tool editor) 'tool-button
                                    :active-value tool
                                    :tooltip (title tool))))
      (alloy:enter button layout)
      (alloy:enter button focus))))
