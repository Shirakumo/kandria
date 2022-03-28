(in-package #:org.shirakumo.fraf.kandria)

(defclass money-counter (alloy:label)
  ())

(defmethod alloy:text ((counter money-counter))
  (format NIL "~a ~d ¤" (@ shop-available-funds) (alloy:value counter)))

(defmethod alloy:render-needed-p ((counter money-counter))
  T)

(presentations:define-realization (ui money-counter)
  ((label simple:text)
   (alloy:margins 5 2)
   alloy:text
   :pattern colors:white
   :size (alloy:un 20)
   :font (setting :display :font)
   :halign :end
   :valign :middle))

(presentations:define-update (ui money-counter)
  (label
   :text alloy:text))

(defclass shop-button (alloy:direct-value-component)
  ((source :initarg :source :accessor source)
   (target :initarg :target :accessor target)))

(defmethod item-count ((button shop-button) thing)
  (item-count (alloy:value button) (source button)))

(defmethod price ((button shop-button))
  (price (alloy:value button)))

(defmethod alloy:activate ((button shop-button))
  (when (active-p button)
    (show-panel 'transaction-panel :source button)))

(defmethod (setf alloy:focus) :after ((focus (eql :strong)) (button shop-button))
  (setf (alloy:focus (alloy:focus-parent button)) :strong))

(presentations:define-realization (ui shop-button)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((name simple:text)
   (alloy:margins 5)
   (title alloy:value)
   :size (alloy:un 15)
   :font (setting :display :font)
   :pattern colors:white
   :valign :middle
   :halign :start)
  ((count simple:text)
   (alloy:margins 5 5 200 5)
   (princ-to-string (item-count alloy:renderable T))
   :size (alloy:un 15)
   :font (setting :display :font)
   :pattern colors:white
   :valign :middle
   :halign :end)
  ((price simple:text)
   (alloy:margins 5)
   (format NIL "~d ¤" (price alloy:renderable))
   :size (alloy:un 15)
   :font (setting :display :font)
   :pattern colors:white
   :valign :middle
   :halign :end))

(presentations:define-update (ui shop-button)
  (:background
   :pattern (if alloy:focus colors:white colors:black))
  (name
   :pattern (if (active-p alloy:renderable)
                (if alloy:focus colors:black colors:white)
                colors:gray))
  (count
   :text (princ-to-string (item-count alloy:renderable T))
   :pattern (if (active-p alloy:renderable)
                (if alloy:focus colors:black colors:white)
                colors:gray))
  (price
   :pattern (if (active-p alloy:renderable)
                (if alloy:focus colors:black colors:white)
                colors:gray)))

(presentations:define-animated-shapes shop-button
  (:background (simple:pattern :duration 0.2))
  (name (simple:pattern :duration 0.2))
  (count (simple:pattern :duration 0.2))
  (price (simple:pattern :duration 0.2)))

(defclass buy-button (shop-button)
  ())

(defmethod active-p ((button buy-button))
  (<= (price (alloy:value button)) (item-count 'item:parts (target button))))

(defmethod retrieve (thing (button buy-button) &optional (count 1))
  (let ((item (alloy:value button)))
    (retrieve 'item:parts (target button) (* count (price item)))
    (retrieve item (source button) count)
    (store item (target button) count)
    (alloy:value-changed button)))

(defclass sell-button (shop-button)
  ())

(defmethod active-p ((button sell-button))
  (< 0 (item-count (alloy:value button) (source button))))

(defmethod retrieve (thing (button sell-button) &optional (count 1))
  (let ((item (alloy:value button)))
    (retrieve item (source button) count)
    (store 'item:parts (source button) (* count (price item)))
    (alloy:value-changed button)))

(defclass sales-menu (menuing-panel pausing-panel)
  ())

(defmethod initialize-instance :after ((panel sales-menu) &key shop direction target)
  (alloy:with-unit-parent (unit 'ui-pass T)
    (let* ((layout (make-instance 'eating-constraint-layout
                                  :shapes (list (make-basic-background))))
           (clipper (make-instance 'alloy:clip-view :limit :x))
           (scroll (alloy:represent-with 'alloy:y-scrollbar clipper))
           (focus (make-instance 'alloy:focus-list))
           (list (make-instance 'alloy:vertical-linear-layout
                                :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern (colored:color 0 0 0 0.5)))
                                :min-size (alloy:size 100 50)))
           (money (alloy:represent (item-count 'item:parts target) 'money-counter)))
      (alloy:enter list clipper)
      (alloy:enter clipper layout :constraints `((:left 50) (:right 70) (:bottom 100) (:top 100)))
      (alloy:enter scroll layout :constraints `((:width 20) (:right 50) (:bottom 100) (:top 100)))
      (alloy:enter money layout :constraints `((:right 50) (:above ,clipper 10) (:size 500 50)))
      (ecase direction
        (:buy
         (alloy:enter (make-instance 'label :value (@ shop-buy-items)) layout :constraints `((:left 50) (:above ,clipper 10) (:size 200 50)))
         (dolist (item (list-items shop T))
           (make-instance 'buy-button :value item :source shop :target target :layout-parent list :focus-parent focus)))
        (:sell
         (alloy:enter (make-instance 'label :value (@ shop-sell-items)) layout :constraints `((:left 50) (:above ,clipper 10) (:size 200 50)))
         (dolist (item (list-items target 'value-item))
           (unless (typep item 'item:parts)
             (make-instance 'sell-button :value item :source target :target shop :layout-parent list :focus-parent focus)))))
      (let ((back (make-instance 'button :value (@ go-backwards-in-ui) :on-activate (lambda () (hide panel)))))
        (alloy:enter back layout :constraints `((:left 50) (:below ,clipper 10) (:size 200 50)))
        (alloy:enter back focus)
        (alloy:on alloy:exit (focus)
          (setf (alloy:focus back) :strong)))
      (alloy:finish-structure panel layout focus))))

(defclass item-wheel (alloy:ranged-wheel)
  ())

(defmethod alloy:handle :around ((ev alloy:focus-down) (wheel item-wheel))
  (if (= (alloy:value wheel) (decf (alloy:value wheel) (alloy:step wheel)))
      (harmony:play (// 'sound 'ui-no-more-to-focus) :reset T)
      (harmony:play (// 'sound 'ui-focus-next) :reset T)))

(defmethod alloy:handle :around ((ev alloy:focus-up) (wheel item-wheel))
  (if (= (alloy:value wheel) (incf (alloy:value wheel) (alloy:step wheel)))
      (harmony:play (// 'sound 'ui-no-more-to-focus) :reset T)
      (harmony:play (// 'sound 'ui-focus-next) :reset T)))

(defmethod alloy:accept :after ((wheel item-wheel))
  (alloy:focus-next (alloy:focus-parent wheel))
  (alloy:focus-next (alloy:focus-parent wheel)))

(defmethod alloy:exit :after ((wheel item-wheel))
  (alloy:focus-prev (alloy:focus-parent wheel)))

(presentations:define-realization (ui item-wheel)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.9 0.9 0.9))
  ((border simple:rectangle)
   (alloy:margins)
   :pattern colors:transparent
   :line-width (alloy:un 1))
  ((label simple:text)
   (alloy:margins 10 2)
   alloy:text
   :pattern colors:black
   :font (setting :display :font)
   :size (alloy:un 15)
   :valign :middle
   :halign :end))

(presentations:define-update (ui item-wheel)
  (border
   :pattern (case alloy:focus
              (:strong colors:black)
              (T colors:gray)))
  (background
   :pattern (case alloy:focus
              (:strong colors:transparent)
              (:weak (colored:color 0.9 0.9 0.9))
              (T (colored:color 0.8 0.8 0.8))))
  (label
   :text alloy:text))

(defclass total-counter (alloy:label)
  ((price :initarg :price :accessor price)))

(defmethod alloy:text ((counter total-counter))
  (format NIL "~d ¤" (* (alloy:value counter) (price counter))))

(presentations:define-realization (ui total-counter)
  ((label simple:text)
   (alloy:margins 5 2)
   alloy:text
   :pattern colors:black
   :size (alloy:un 20)
   :font (setting :display :font)
   :halign :end
   :valign :middle))

(presentations:define-update (ui total-counter)
  (label
   :text alloy:text))

(defclass transaction-panel (popup-panel)
  ((wheel :accessor wheel)))

(animation:define-animation too-expensive
  0.1 ((setf simple:pattern) colors:red)
  0.5 ((setf simple:pattern) colors:black))

(defmethod initialize-instance :after ((panel transaction-panel) &key source)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(150 150) :row-sizes '(40 40 T 40)
                                                   :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern colors:white))))
         (focus (make-instance 'alloy:focus-list))
         (count (make-instance 'alloy:value-data :value 1))
         (wheel (make-instance 'item-wheel :data count :range (cons 0 (item-count source T)) :focus-parent focus))
         (total (make-instance 'total-counter :data count :price (price source)))
         (ok (make-instance 'popup-button
                            :value (@ accept-trade)
                            :on-activate (lambda ()
                                           (handler-case
                                               (progn
                                                 (retrieve T source (alloy:value count))
                                                 (harmony:play (// 'sound 'ui-buy))
                                                 (hide panel))
                                             (error ()
                                               (alloy:with-unit-parent total
                                                 (animation:apply-animation 'too-expensive (presentations:find-shape 'label total)))
                                               (harmony:play (// 'sound 'ui-error) :reset T))))
                            :focus-parent focus))
         (cancel (make-instance 'popup-button
                                :value (@ cancel-trade)
                                :on-activate (lambda ()
                                               (hide panel))
                                :focus-parent focus)))
    (setf (wheel panel) wheel)
    (alloy:enter (make-instance 'popup-label :value (@ trade-quantity)) layout)
    (alloy:enter wheel layout)
    (alloy:enter (make-instance 'popup-label :value (@ trade-total)) layout)
    (alloy:enter total layout)
    (alloy:enter ok layout :col 0 :row 3)
    (alloy:enter cancel layout :col 1 :row 3)
    (alloy:on alloy:exit (focus)
      (setf (alloy:focus cancel) :strong))
    (alloy:finish-structure panel layout focus)))

(defmethod show :after ((panel transaction-panel) &key)
  (setf (alloy:focus (wheel panel)) :strong))

(defun show-sales-menu (direction character)
  (show-panel 'sales-menu :shop (unit character T) :target (unit 'player T)  :direction direction))
