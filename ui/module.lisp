(in-package #:org.shirakumo.fraf.kandria)

(defclass module-button (alloy:direct-value-component alloy:button)
  ())

(defmethod alloy:text ((button module-button))
  (title (alloy:value button)))

(presentations:define-realization (ui module-button)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:label simple:text)
   (alloy:margins 5)
   alloy:text
   :size (alloy:un 15)
   :font (setting :display :font)
   :valign :middle
   :halign :start))

(presentations:define-update (ui module-button)
  (:background
   :pattern (if (active-p alloy:value)
                (if alloy:focus colors:white colors:black)
                (if alloy:focus colors:dim-gray colors:black)))
  (:label
   :pattern (if (active-p alloy:value)
                (if alloy:focus colors:black colors:white)
                colors:gray)))

(defclass icon* (alloy:icon alloy:value-component)
  ())

(presentations:define-update (ui icon*)
  (:icon
   :image alloy:value
   :sizing :contain))

(defclass module-title (alloy:label) ())

(presentations:define-realization (ui module-title)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :font (setting :display :font)
   :wrap T
   :size (alloy:un 30)
   :halign :start
   :valign :middle))

(defclass module-label (alloy:label) ())

(presentations:define-realization (ui module-label)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :font (setting :display :font)
   :wrap T
   :size (alloy:un 14)
   :halign :start
   :valign :middle))

(defclass module-description (alloy:label) ())

(presentations:define-realization (ui module-description)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:label simple:text)
   (alloy:margins 5)
   alloy:text
   :font (setting :display :font)
   :wrap T
   :size (alloy:un 14)
   :halign :start
   :valign :top))

(presentations:define-update (ui module-description)
  (:label
   :pattern colors:white))

(defclass module-preview (alloy:structure alloy:delegate-data)
  ())

(defmethod initialize-instance :after ((preview module-preview) &key)
  (let* ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
         (focus (make-instance 'alloy:focus-list))
         (icon (alloy:represent-with 'icon* preview :value-function 'preview))
         (title (alloy:represent-with 'module-title preview :value-function 'title))
         (description (alloy:represent-with 'module-description preview :value-function 'description))
         (data (make-instance 'alloy:grid-layout :col-sizes '(100 T) :row-sizes '(30)))
         (active-p (alloy:represent-with 'alloy:labelled-switch preview :value-function 'active-p :focus-parent focus :text (@ module-active-switch))))
    (alloy:on alloy:activate (active-p)
      (setf (active-p (alloy:object preview)) (alloy:value active-p)))
    (macrolet ((label (lang function)
                 `(progn
                    (alloy:represent (@ ,lang) 'module-label :layout-parent data)
                    (alloy:represent-with 'module-label preview :value-function ',function :layout-parent data))))
      (label module-name name)
      (label module-author-list author)
      (label module-version version)
      (label module-upstream-url upstream))
    (alloy:enter icon layout :constraints `((:left 5) (:top 0) (:width 300) (:aspect-ratio 16/9)))
    (alloy:enter description layout :constraints `((:top 0) (:bottom 0) (:right 5) (:right-of ,icon 10)))
    (alloy:enter active-p layout :constraints `((:chain :down ,icon 5) (:height 30)))
    (alloy:enter title layout :constraints `((:chain :down ,active-p 5) (:height 50)))
    (alloy:enter data layout :constraints `((:chain :down ,title 5) (:height 500)))
    (alloy:finish-structure preview layout focus)))

(defmethod alloy:access ((preview module-preview) (field (eql 'preview)))
  (or (preview (alloy:object preview)) (// 'kandria 'empty-save)))

(defmethod alloy:refresh ((preview module-preview))
  (let ((object (alloy:object preview)))
    (dolist (function (alloy:observed preview))
      (alloy:notify-observers function preview (slot-value object function) object))))

(defclass module-menu (pausing-panel menuing-panel)
  ())

(defmethod initialize-instance :after ((panel module-menu) &key)
  (let* ((layout (make-instance 'eating-constraint-layout
                                :shapes (list (make-basic-background))))
         (clipper (make-instance 'alloy:clip-view :limit :x))
         (scroll (alloy:represent-with 'alloy:y-scrollbar clipper))
         (preview (make-instance 'module-preview :object (first (list-modules :available))))
         (focus (make-instance 'alloy:focus-stack :orientation :horizontal))
         (list (make-instance 'alloy:vertical-linear-layout
                              :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern (colored:color 0 0 0 0.5)))
                              :min-size (alloy:size 100 50))))
    (alloy:enter preview focus :layer 2)
    (alloy:enter list clipper)
    (alloy:enter preview layout :constraints `((:left 50) (:right 370) (:bottom 100) (:top 20)))
    (alloy:enter clipper layout :constraints `((:width 300) (:right 70) (:bottom 100) (:top 20)))
    (alloy:enter scroll layout :constraints `((:width 20) (:right 50) (:bottom 100) (:top 20)))
    (dolist (module (list-modules :available))
      (let ((button (make-instance 'module-button :value module :layout-parent list)))
        (alloy:on alloy:focus (value button)
          (when value
            (setf (alloy:object preview) module)))
        (alloy:enter button focus :layer 1)))
    (let ((back (alloy:represent (@ go-backwards-in-ui) 'button)))
      (alloy:enter back layout :constraints `((:left 50) (:below ,clipper 10) (:size 200 50)))
      (alloy:enter back focus :layer 0)
      (alloy:on alloy:activate (back)
        (hide panel))
      (alloy:on alloy:exit (focus)
        (setf (alloy:focus focus) :strong)
        (setf (alloy:focus back) :weak)))
    (alloy:finish-structure panel layout focus)))

(defmethod stage :after ((menu module-menu) (area staging-area))
  (stage (// 'kandria 'empty-save) area))

(! (toggle-panel 'module-menu))
