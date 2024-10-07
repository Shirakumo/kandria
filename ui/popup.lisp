(in-package #:org.shirakumo.fraf.kandria)

(defclass popup-layout (alloy:fixed-layout)
  ())

(presentations:define-realization (ui popup-layout)
  ((:bg simple:rectangle)
   (alloy:extent (alloy:vw -1) (alloy:vh -1) (alloy:vw 2) (alloy:vh 2))
   :pattern (colored:color 0.05 0 0 0.2)))

(defmethod alloy:handle ((ev alloy:pointer-event) (focus popup-layout))
  (restart-case
      (call-next-method)
    (alloy:decline ()
      T)))

(defmethod alloy:refit ((layout popup-layout))
  (let ((extent (alloy:bounds layout)))
    (alloy:do-elements (element layout)
      (let ((size (alloy:suggest-size (alloy:size 500 200) element)))
        (when (or (= 0 (alloy:pxw size))
                  (= 0 (alloy:pxh size)))
          (setf size (alloy:bounds element)))
        (setf (alloy:bounds element)
              (alloy:px-extent (/ (- (alloy:pxw extent) (alloy:pxw size)) 2)
                               (/ (- (alloy:pxh extent) (alloy:pxh size)) 2)
                               (alloy:pxw size) (+ 20 (alloy:pxh size))))))))

(defclass popup-button (button)
  ())

(presentations:define-update (ui popup-button)
  (:label
   :pattern (if alloy:focus colors:white colors:black)
   :size (alloy:un 15))
  (:background
   :pattern (if alloy:focus colors:black (colored:color 0.9 0.9 0.9))
   :bounds (if alloy:focus (alloy:margins -5) (alloy:margins)))
  (border
   :hidden-p T))

(presentations:define-animated-shapes popup-button
  (:background (simple:pattern :duration 0.2)
               (simple:bounds :duration 0.2)))

(defclass popup-label (label)
  ())

(presentations:define-update (ui popup-label)
  (:label
   :pattern colors:black
   :size (alloy:un 15)))

(defclass popup-line (alloy:input-line)
  ())

(presentations:define-realization (ui popup-line)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.9 0.9 0.9))
  ((border simple:rectangle)
   (alloy:margins)
   :pattern colors:gray
   :line-width (alloy:un 1))
  ((:label simple:text)
   (alloy:margins 10 1 10 1)
   alloy:text
   :font (setting :display :font)
   :size (alloy:un 14)
   :halign :start
   :valign :middle
   :pattern colors:black)
  ((:cursor simple:cursor)
   (presentations:find-shape :label alloy:renderable)
   0
   :pattern colors:black)
  ((:selection simple:selection)
   (presentations:find-shape :label alloy:renderable)
   0 0))

(presentations:define-update (ui popup-line)
  (border
   :pattern (if alloy:focus colors:black colors:gray))
  (:label
   :pattern colors:black))

(defclass popup-panel (menuing-panel)
  ((source :initform NIL :initarg :source :accessor source)))

(defmethod initialize-instance :around ((panel popup-panel) &key)
  (call-next-method)
  (let ((popup (make-instance 'popup-layout)))
    (alloy:enter (alloy:layout-element panel) popup)
    (setf (slot-value panel 'alloy:layout-element) popup)))

(defmethod show :after ((panel popup-panel) &key (width (alloy:un 300)) (height (alloy:un 120)))
  (cond ((source panel)
         (alloy:with-unit-parent (source panel)
           (let ((bounds (alloy:px-extent (alloy:pxx (alloy:global-location (source panel)))
                                          (alloy:pxy (alloy:global-location (source panel)))
                                          (alloy:pxw (source panel))
                                          (alloy:pxh (source panel)))))
             (alloy:update (alloy:index-element 0 (alloy:layout-element panel))
                           (alloy:layout-element panel)
                           :x (+ (alloy:pxx bounds)
                                 (- (alloy:pxw bounds) (alloy:to-px width)))
                           :y (alloy:pxy bounds)
                           :w width
                           :h height))))
        (T
         (alloy:with-unit-parent (alloy:layout-element panel)
           (alloy:resize (alloy:layout-element panel) width height))
         (alloy:refit (alloy:layout-parent (alloy:layout-element panel))))))

(defmethod hide :after ((panel popup-panel))
  (when (source panel)
    (setf (alloy:focus (source panel)) :strong)))

(defclass info-label (label)
  ())

(presentations:define-update (ui info-label)
  (:label
   :bounds (alloy:margins 20)
   :pattern colors:black
   :size (alloy:un 14)
   :valign :top
   :halign :start
   :wrap T))

(defclass info-panel (popup-panel)
  ())

(defmethod initialize-instance :after ((panel info-panel) &key text on-accept)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(T) :row-sizes '(T 40)
                                                   :shapes (list (simple:rectangle (node 'ui-pass T) (alloy:margins) :pattern colors:white))))
         (label (make-instance 'info-label :value text :layout-parent layout))
         (button (alloy:represent (@ dismiss-info-panel) 'popup-button :layout-parent layout)))
    (alloy:on alloy:activate (button)
      (hide panel)
      (when on-accept (funcall on-accept)))
    ;; FIXME: scroll
    (alloy:finish-structure panel layout button)))

(defmethod message ((string string))
  (promise:with-promise (ok)
    (show (make-instance 'info-panel :text string :on-accept #'ok)
          :width (alloy:vw 0.5) :height (alloy:vh 0.5))))

(defclass prompt-panel (popup-panel)
  ())

(defmethod initialize-instance :after ((panel prompt-panel) &key text (accept (@ accept-prompt-panel)) (cancel (@ dismiss-prompt-panel)) on-accept on-cancel)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(T) :row-sizes '(T 50)
                                                   :shapes (list (simple:rectangle (node 'ui-pass T) (alloy:margins) :pattern colors:white))))
         (focus (make-instance 'alloy:focus-list))
         (label (make-instance 'info-label :value text :layout-parent layout))
         (buttons (make-instance 'alloy:grid-layout :col-sizes '(T T) :row-sizes '(T) :layout-parent layout))
         (cancel (alloy:represent cancel 'popup-button :layout-parent buttons :focus-parent focus))
         (accept (alloy:represent accept 'popup-button :layout-parent buttons :focus-parent focus)))
    (alloy:on alloy:activate (cancel)
      (hide panel)
      (when on-cancel (funcall on-cancel)))
    (alloy:on alloy:activate (accept)
      (hide panel)
      (funcall on-accept))
    (alloy:on alloy:exit (focus)
      (setf (alloy:focus focus) :strong)
      (setf (alloy:focus cancel) :weak))
    ;; FIXME: scroll
    (alloy:finish-structure panel layout focus)))

(defmethod show :after ((panel prompt-panel) &key)
  (harmony:play (// 'sound 'ui-warning)))

(defmethod prompt ((string string))
  (promise:with-promise (ok fail)
    (show (make-instance 'prompt-panel :text string :on-accept #'ok :on-cancel #'fail)
          :width (alloy:vw 0.5) :height (alloy:vh 0.5))))

(defun prompt* (string &key (accept (@ accept-prompt-panel)) (cancel (@ dismiss-prompt-panel)))
  (promise:with-promise (ok fail)
    (show (make-instance 'prompt-panel :text string :accept accept :cancel cancel :on-accept #'ok :on-cancel #'fail)
          :width (alloy:vw 0.5) :height (alloy:vh 0.5))))

(defclass query-panel (popup-panel)
  ())

(defmethod initialize-instance :after ((panel query-panel) &key text (value "") (accept (@ accept-prompt-panel)) (cancel (@ dismiss-prompt-panel)) on-accept on-cancel placeholder)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(T) :row-sizes '(T 50 50)
                                                   :shapes (list (simple:rectangle (node 'ui-pass T) (alloy:margins) :pattern colors:white))))
         (focus (make-instance 'alloy:focus-list))
         (label (make-instance 'info-label :value text :layout-parent layout))
         (input (make-instance 'popup-line :layout-parent layout :focus-parent focus :placeholder placeholder
                                           :data (make-instance 'alloy:value-data :value value)))
         (buttons (make-instance 'alloy:grid-layout :col-sizes '(T T) :row-sizes '(T) :layout-parent layout))
         (cancel (alloy:represent cancel 'popup-button :layout-parent buttons :focus-parent focus))
         (accept (alloy:represent accept 'popup-button :layout-parent buttons :focus-parent focus)))
    (alloy:on alloy:accept (input)
      (alloy:activate accept))
    (alloy:on alloy:activate (cancel)
      (hide panel)
      (when on-cancel (funcall on-cancel)))
    (alloy:on alloy:activate (accept)
      (hide panel)
      (funcall on-accept (alloy:value input)))
    (alloy:on alloy:exit (focus)
      (setf (alloy:focus focus) :strong)
      (setf (alloy:focus cancel) :weak))
    ;; FIXME: scroll
    (alloy:finish-structure panel layout focus)))

(defmethod show :after ((panel prompt-panel) &key)
  (harmony:play (// 'sound 'ui-warning)))

(defmethod query ((string string))
  (promise:with-promise (ok fail)
    (show (make-instance 'query-panel :text string :on-accept #'ok :on-cancel #'fail)
          :width (alloy:vw 0.5) :height (alloy:vh 0.5))))

(defun query* (string &key placeholder (value "") (accept (@ accept-prompt-panel)) (cancel (@ dismiss-prompt-panel)) (width (alloy:vw 0.5)) (height (alloy:vh 0.5)))
  (promise:with-promise (ok fail)
    (show (make-instance 'query-panel :text string :value value :accept accept :cancel cancel :on-accept #'ok :on-cancel #'fail :placeholder placeholder)
          :width width :height height)))

(defclass spinner-panel (menuing-panel)
  ())

(defmethod initialize-instance :after ((panel spinner-panel) &key)
  (let ((layout (make-instance 'eating-constraint-layout
                               :shapes (list (simple:rectangle (node 'ui-pass T) (alloy:margins)
                                                               :pattern (colored:color 0 0 0 0.5)))))
        (icon (make-instance 'save-icon)))
    (alloy:enter icon layout :constraints `(:center (:size 6 6)))
    (animation:apply-animation 'spin icon)
    (alloy:finish-structure panel layout NIL)))
