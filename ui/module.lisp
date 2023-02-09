(in-package #:org.shirakumo.fraf.kandria)

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
   :size (alloy:un 12)
   :halign :start
   :valign :middle))

(defclass module-description (alloy:label) ())

(presentations:define-realization (ui module-description)
  ((:bg simple:rectangle)
   (alloy:margins 0)
   :pattern (colored:color 1 1 1 0.2))
  ((:label simple:text)
   (alloy:margins 15)
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
         (data (make-instance 'alloy:grid-layout :col-sizes '(100 T) :row-sizes '(40)))
         (active-p (alloy:represent-with 'alloy:labelled-switch preview :value-function 'active-p :focus-parent focus :text (@ module-active-switch))))
    (alloy:on alloy:activate (active-p)
      (setf (active-p (alloy:object preview)) (alloy:value active-p)))
    (macrolet ((label (lang function)
                 `(progn
                    (alloy:represent (@ ,lang) 'module-label :layout-parent data)
                    (alloy:represent-with 'module-label preview :value-function ',function :layout-parent data))))
      (label module-id id)
      (label module-author-list author)
      (label module-version version)
      (label module-upstream-url upstream))
    (alloy:enter icon layout :constraints `((:left 5) (:top 0) (:width 400) (:aspect-ratio 16/9)))
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

(defclass world-preview (alloy:structure alloy:delegate-data)
  ())

(defmethod initialize-instance :after ((preview world-preview) &key)
  (let* ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
         (title (alloy:represent-with 'module-title preview :value-function 'title))
         (description (alloy:represent-with 'module-description preview :value-function 'description))
         (data (make-instance 'alloy:grid-layout :col-sizes '(100 T 100 T) :row-sizes '(40)))
         (start (alloy:represent (@ module-load-world) 'button)))
    (alloy:on alloy:activate (start)
      (show-panel 'load-panel :loader (loader +main+))
      (render +main+ +main+)
      (let ((scene (scene +main+)))
        (setf (action-lists scene) ())
        (tagbody retry
           (loop for panel in (panels (unit 'ui-pass scene))
                 do (unless (typep panel '(or prerelease-notice load-panel hud))
                      (hide panel)
                      (go retry))))
        (load-world (depot:to-pathname (depot (alloy:object preview))) scene))
      (load-state NIL +main+))
    (macrolet ((label (lang function)
                 `(progn
                    (alloy:represent (@ ,lang) 'module-label :layout-parent data)
                    (alloy:represent-with 'module-label preview :value-function ',function :layout-parent data))))
      (label module-author-list author)
      (label module-version version)
      (label module-id id))
    (alloy:enter title layout :constraints `((:top 0) (:left 0) (:right 0) (:height 50)))
    (alloy:enter data layout :constraints `((:chain :below ,title 5) (:height 80)))
    (alloy:enter start layout :constraints `((:bottom 0) (:left 0) (:right 0) (:height 50)))
    (alloy:enter description layout :constraints `((:chain :below ,data 10) (:above ,start 10)))
    (alloy:finish-structure preview layout start)))

(defmethod alloy:observe ((none (eql NIL)) object (data world-preview) &optional (name data))
  )

(defmethod alloy:observe ((all (eql T)) object (data world-preview) &optional (name data))
  (alloy:refresh data))

(defmethod alloy:refresh ((preview world-preview))
  (let ((object (alloy:object preview)))
    (dolist (function (alloy:observed preview))
      (alloy:notify-observers function preview (slot-value object function) object))))

(defclass module-menu (tab-view menuing-panel)
  ())

(defmethod initialize-instance :after ((panel module-menu) &key)
  (let* ((layout (make-instance 'eating-constraint-layout))
         (clipper (make-instance 'alloy:clip-view :limit :x))
         (preview (make-instance 'module-preview :object (first (list-modules :available))))
         (focus (make-instance 'alloy:focus-stack :orientation :horizontal))
         (list (make-instance 'alloy:vertical-linear-layout
                              :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern colors:black))
                              :min-size (alloy:size 100 50)
                              :cell-margins (alloy:margins))))
    (alloy:enter preview focus :layer 2)
    (alloy:enter list clipper)
    (alloy:enter clipper layout :constraints `((:width 250) (:left 0) (:bottom 0) (:top 0)))
    (alloy:enter preview layout :constraints `((:right-of ,clipper 10) (:top 10) (:bottom 10) (:right 10)))
    (dolist (module (list-modules :available))
      (let ((button (make-instance 'tab-button :data (make-instance 'alloy:value-data :value (title module)) :layout-parent list)))
        (alloy:on alloy:focus (value button)
          (when value
            (setf (alloy:object preview) module)))
        (alloy:enter button focus :layer 1)))
    (add-tab panel (make-instance 'trial-alloy::language-data :name 'module-manage-tab) layout focus))
  (let* ((layout (make-instance 'eating-constraint-layout))
         (clipper (make-instance 'alloy:clip-view :limit :x))
         (preview (make-instance 'world-preview :object +world+))
         (focus (make-instance 'alloy:focus-stack :orientation :horizontal))
         (list (make-instance 'alloy:vertical-linear-layout
                              :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern colors:black))
                              :min-size (alloy:size 100 50)
                              :cell-margins (alloy:margins))))
    (alloy:enter preview focus :layer 2)
    (alloy:enter list clipper)
    (alloy:enter clipper layout :constraints `((:width 250) (:left 0) (:bottom 0) (:top 0)))
    (alloy:enter preview layout :constraints `((:right-of ,clipper 10) (:top 10) (:bottom 10) (:right 10)))
    ;; TODO: make this refresh when world / mod list changes.
    (dolist (world (list-worlds))
      (let ((button (make-instance 'tab-button :data (make-instance 'alloy:value-data :value (title world)) :layout-parent list)))
        (alloy:on alloy:focus (value button)
          (when value
            (setf (alloy:object preview) world)))
        (alloy:enter button focus :layer 1)))
    (add-tab panel (make-instance 'trial-alloy::language-data :name 'module-worlds-tab) layout focus))
  (alloy:on alloy:exit ((alloy:focus-element panel))
    (when (active-p panel)
      (hide panel))))

(defmethod stage :after ((menu module-menu) (area staging-area))
  (stage (// 'kandria 'empty-save) area))

(defmethod show :before ((panel module-menu) &key)
  (alloy:enter (alloy:represent (@ go-backwards-in-ui) 'back-button) panel)
  (let ((layout (make-instance 'menu-layout)))
    (alloy:enter (alloy:layout-element panel) layout :place :center)
    (setf (slot-value panel 'alloy:layout-element) layout)))

(! (toggle-panel 'module-menu))
