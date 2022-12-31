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
   (target :initarg :target :accessor target)
   (marked :initarg :marked :initform NIL :accessor marked)))

(defmethod item-count ((button shop-button) thing)
  (item-count (alloy:value button) (source button)))

(defmethod price ((button shop-button))
  (price (alloy:value button)))

(defmethod (setf alloy:focus) :after ((focus (eql :strong)) (button shop-button))
  (setf (alloy:focus (alloy:focus-parent button)) :strong))

(defmethod (setf marked) :after (value (button shop-button))
  (alloy:mark-for-render button))

(defmethod alloy:activate ((button shop-button))
  (when (active-p button)
    (show-panel 'transaction-panel :source button)))

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
   :pattern (if alloy:focus colors:white colors:black)
   :offset (if (marked alloy:renderable)
               (alloy:point 20 0)
               (alloy:point)))
  (name
   :pattern (if (active-p alloy:renderable)
                (if alloy:focus colors:black colors:white)
                colors:gray)
   :offset (if (marked alloy:renderable)
               (alloy:point 20 0)
               (alloy:point)))
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

(defmethod price ((button buy-button))
  (price-for-buy (alloy:value button) (source button)))

(defmethod retrieve (thing (button buy-button) &optional (count 1))
  (trade (source button) (target button) (alloy:value button) count)
  (alloy:value-changed button))

(defclass sell-button (shop-button)
  ())

(defmethod active-p ((button sell-button))
  (< 0 (item-count (alloy:value button) (source button))))

(defmethod price ((button sell-button))
  (price-for-sell (alloy:value button) (target button)))

(defmethod retrieve (thing (button sell-button) &optional (count 1))
  (trade (source button) (target button) (alloy:value button) count)
  (alloy:value-changed button))

(defmethod handle ((ev mark-for-bulk) (button sell-button))
  (when (active-p button)
    (setf (marked button) (not (marked button)))))

(defmethod alloy:activate ((button sell-button))
  (when (active-p button)
    (let ((marked (loop for child in (alloy:elements (alloy:focus-parent button))
                        when (and (typep child 'sell-button) (marked child))
                        collect child)))
      (if marked
          (dolist (button marked (harmony:play (// 'sound 'ui-buy)))
            (setf (marked button) NIL)
            (trade (source button) (target button) (alloy:value button) T))
          (show-panel 'transaction-panel :source button)))))

(defclass sales-menu (pausing-panel menuing-panel)
  ())

(defmethod initialize-instance :after ((panel sales-menu) &key shop direction target)
  (alloy:with-unit-parent (unit 'ui-pass T)
    (let* ((layout (make-instance 'eating-constraint-layout
                                  :shapes (list (make-basic-background))))
           (inner (make-instance 'alloy:border-layout))
           (clipper (make-instance 'alloy:clip-view :limit :x))
           (scroll (alloy:represent-with 'alloy:y-scrollbar clipper))
           (focus (make-instance 'alloy:focus-stack :orientation :horizontal))
           (list (make-instance 'alloy:vertical-linear-layout
                                :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern (colored:color 0 0 0 0.5)))
                                :min-size (alloy:size 100 50)))
           (money (alloy:represent (item-count 'item:parts target) 'money-counter))
           (info (make-instance 'alloy:border-layout :padding (alloy:margins 10)
                                                     :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern (colored:color 0 0 0 0.5)))))
           (icon (make-instance 'item-icon :value NIL))
           (description (make-instance 'label :value "" :style `((:label :bounds ,(alloy:margins 10 0) :size ,(alloy:un 14))))))

      (alloy:enter list clipper)
      (alloy:enter clipper inner)
      (alloy:enter description info)
      (alloy:enter icon info :place :west :size (alloy:un 80))
      (alloy:enter info inner :place :south :size (alloy:un 80))
      (alloy:enter scroll inner :place :east :size (alloy:un 20))
      
      (alloy:enter inner layout :constraints `((:left 50) (:right 50) (:bottom 100) (:top 100)))
      (alloy:enter money layout :constraints `((:right 50) (:above ,inner 10) (:size 500 50)))
      (alloy:enter (make-instance 'label :value (ecase direction (:buy (@ shop-buy-items)) (:sell (@ shop-sell-items))))
                   layout :constraints `((:left 50) (:above ,inner 10) (:size 200 50)))
      (ecase direction
        (:buy
         (dolist (item (list-items shop T))
           (let ((button (make-instance 'buy-button :value item :source shop :target target :layout-parent list :focus-parent focus)))
             (alloy:on alloy:focus (value button)
               (when value
                 (setf (alloy:value description) (item-description (alloy:value button)))
                 (setf (alloy:value icon) (make-instance (class-of (alloy:value button)))))))))
        (:sell
         (dolist (item (list-items target 'value-item))
           (unless (typep item 'item:parts)
             (let ((button (make-instance 'sell-button :value item :source target :target shop :layout-parent list :focus-parent focus)))
               (alloy:on alloy:focus (value button)
                 (when value
                   (setf (alloy:value description) (item-description (alloy:value button)))
                   (setf (alloy:value icon) (make-instance (class-of (alloy:value button)))))))))
         (let ((input (make-instance 'label :value (action-string 'mark-for-bulk :bank +input-source+) :style `((:label :halign :middle
                                                                                                                        :valign :middle))))
               (info (make-instance 'label :value (@ shop-mark-item-for-bulk-selling) :style `((:label :size ,(alloy:un 15)
                                                                                                       :halign :right)))))
           (alloy:enter input layout :constraints `((:right 50) (:below ,inner 10) (:size 50 50)))
           (alloy:enter info layout :constraints `((:right 120) (:below ,inner 10) (:size 500 50))))))
      (let ((back (alloy:represent (@ go-backwards-in-ui) 'button)))
        (alloy:enter back layout :constraints `((:left 50) (:below ,inner 10) (:size 200 50)))
        (alloy:enter back focus :layer 1)
        (alloy:on alloy:activate (back)
          (hide panel))
        (alloy:on alloy:exit (focus)
          (setf (alloy:focus focus) :strong)
          (setf (alloy:focus back) :weak)))
      (alloy:finish-structure panel layout focus))))

(defmethod stage :after ((panel sales-menu) (area staging-area))
  (stage (// 'kandria 'achievements) area))

(defmethod handle ((ev mark-for-bulk) (panel sales-menu))
  (when (typep (alloy:focused (alloy:focus-element panel)) 'sell-button)
    (handle ev (alloy:focused (alloy:focus-element panel)))))

(defmethod show :after ((panel sales-menu) &key)
  (setf (alloy:index (alloy:focus-element panel)) (cons 0 0)))

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

(defmethod alloy:handle :around ((ev alloy:focus-left) (wheel item-wheel))
  (if (= (alloy:value wheel) (decf (alloy:value wheel) (* (alloy:step wheel) 10)))
      (harmony:play (// 'sound 'ui-no-more-to-focus) :reset T)
      (harmony:play (// 'sound 'ui-focus-next) :reset T)))

(defmethod alloy:handle :around ((ev alloy:focus-right) (wheel item-wheel))
  (if (= (alloy:value wheel) (incf (alloy:value wheel) (* (alloy:step wheel) 10)))
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
         (ok (alloy:represent (@ accept-trade) 'popup-button :focus-parent focus))
         (cancel (alloy:represent (@ cancel-trade) 'popup-button :focus-parent focus)))
    (alloy:on alloy:activate (ok)
      (handler-case
          (progn
            (retrieve T source (alloy:value count))
            (harmony:play (// 'sound 'ui-buy))
            (hide panel))
        (error ()
          (alloy:with-unit-parent total
            (animation:apply-animation 'too-expensive (presentations:find-shape 'label total)))
          (harmony:play (// 'sound 'ui-error) :reset T))))
    (alloy:on alloy:activate (cancel)
      (hide panel))
    (setf (wheel panel) wheel)
    (alloy:enter (make-instance 'popup-label :value (@ trade-quantity)) layout)
    (alloy:enter wheel layout)
    (alloy:enter (make-instance 'popup-label :value (@ trade-total)) layout)
    (alloy:enter total layout)
    (alloy:enter ok layout :col 0 :row 3)
    (alloy:enter cancel layout :col 1 :row 3)
    (alloy:on alloy:exit (focus)
      (setf (alloy:focus focus) :strong)
      (setf (alloy:focus cancel) :weak))
    (alloy:finish-structure panel layout focus)))

(defmethod show :after ((panel transaction-panel) &key)
  (setf (alloy:focus (wheel panel)) :strong))

(defmethod restock-shop (shop))

(defmethod restock-shop ((npc npc))
  (unless (eql (name npc) 'achievo-shop)
    (dolist (item '(item:small-health-pack item:medium-health-pack item:large-health-pack
                    item:damage-shield item:combat-booster item:nanomachine-salve))
      (ensure-stored item npc 100))))

(defun show-sales-menu (direction character)
  (let ((shop (ensure-unit character)))
    (restock-shop shop)
    (show-panel 'sales-menu :shop shop :target (unit 'player T)  :direction direction)))
