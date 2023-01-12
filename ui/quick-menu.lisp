(in-package #:org.shirakumo.fraf.kandria)

(defclass item-header (alloy:label*)
  ((alloy:value :initform (@ items-menu))))

(presentations:define-realization (ui item-header)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.15 0.15 0.15))
  ((:label simple:text)
   (alloy:margins 10)
   alloy:text
   :valign :middle
   :halign :middle
   :font (setting :display :font)
   :size (alloy:un 15)
   :pattern colors:white))

(defclass item-list (alloy:vertical-linear-layout alloy:focus-list alloy:renderable)
  ((alloy:min-size :initform (alloy:size 300 40))
   (alloy:cell-margins :initform (alloy:margins))))

(presentations:define-realization (ui item-list)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.1 0.1 0.1)))

(defmethod alloy:exit ((list item-list))
  (hide-panel 'quick-menu))

(defclass item-button (alloy:direct-value-component alloy:button)
  ((inventory :initarg :inventory :accessor inventory)))

(presentations:define-realization (ui item-button)
  ((:background simple:rectangle)
   (alloy:margins))
  ((count simple:text)
   (alloy:margins 10)
   (princ-to-string (item-count alloy:value (inventory alloy:renderable)))
   :valign :middle
   :halign :start
   :font (setting :display :font)
   :size (alloy:un 15)
   :pattern colors:white)
  ((:label simple:text)
   (alloy:margins 100 10 10 10)
   alloy:text
   :valign :middle
   :halign :start
   :font (setting :display :font)
   :size (alloy:un 15)
   :pattern colors:white))

(presentations:define-update (ui item-button)
  (:background
   :pattern (if alloy:focus colors:white colors:black))
  (count
   :text (princ-to-string (item-count alloy:value (inventory alloy:renderable)))
   :pattern (if alloy:focus colors:black colors:white))
  (:label
   :pattern (if alloy:focus colors:black colors:white)))

(defmethod alloy:text ((button item-button))
  (title (alloy:value button)))

(defmethod alloy:activate ((button item-button))
  (cond ((< 0 (item-count (alloy:value button) (inventory button)))
         (harmony:play (// 'sound 'ui-use-item) :reset T)
         (use (alloy:value button) (inventory button))
         (alloy:mark-for-render button)
         (when (= 0 (item-count (alloy:value button) (inventory button)))
           (setf (alloy:focus (alloy:focus-parent button)) :strong)
           (alloy:leave button T)))
        (T
         (harmony:play (// 'sound 'ui-error) :reset T))))

(defclass quick-menu (menuing-panel)
  ())

(defmethod show :after ((panel quick-menu) &key)
  (setf (time-scale +world+) 0.05)
  (when (< 0 (alloy:element-count (alloy:focus-element panel)))
    (setf (alloy:index (alloy:focus-element panel)) 0))
  (setf (timeout (health (find-panel 'hud))) 5.0))

(defmethod hide :after ((panel quick-menu))
  (setf (time-scale +world+) 1.0))

(defmethod initialize-instance :after ((panel quick-menu) &key (inventory (unit 'player T)))
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (scroll (make-instance 'alloy:clip-view :limit :x))
        (list (make-instance 'item-list))
        (label (make-instance 'item-header)))
    (dolist (item (list-items inventory 'consumable-item))
      (alloy:enter (make-instance 'item-button :value item :inventory inventory) list))
    (alloy:enter list scroll)
    (alloy:enter scroll layout :constraints `((:left 0) (:bottom 0) (:width 400) (:height 400)))
    (alloy:enter label layout :constraints `((:left 0) (:above ,scroll 0) (:width 400) (:height 40)))
    (alloy:finish-structure panel layout list)))
