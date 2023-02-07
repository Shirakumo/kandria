(in-package #:org.shirakumo.fraf.kandria)

(defclass module-button (button)
  ())

(defmethod alloy:text ((button module-button))
  (title (alloy:value button)))

(defclass icon* (alloy:icon alloy:value-component)
  ())

(presentations:define-update (ui icon*)
  (:icon
   :image alloy:value
   :sizing :contain))

(defclass module-preview (alloy:structure alloy:delegate-data)
  ())

(defmethod initialize-instance :after ((preview module-preview) &key)
  (let* ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
         (focus (make-instance 'alloy:focus-list))
         (icon (alloy:represent-with 'icon* preview :value-function 'preview))
         (title (alloy:represent-with 'alloy:label preview :value-function 'title))
         (description (alloy:represent-with 'alloy:label preview :value-function 'description))
         (upstream (alloy:represent-with 'alloy:button preview :value-function 'upstream :focus-parent focus))
         (active-p (alloy:represent-with 'alloy:labelled-switch preview :value-function 'active-p :focus-parent focus :text "Active")))
    (alloy:enter description layout :constraints `((:top 5) (:bottom 5) (:right 5) (:width 500)))
    (alloy:enter icon layout :constraints `((:left 5) (:top 5) (:medium (:left-of ,description 5)) (:aspect-ratio 16/9)))
    (alloy:enter title layout :constraints `((:weak (:chain :down ,icon 5)) (:height 50)))
    (alloy:enter upstream layout :constraints `((:weak (:chain :down ,title 5)) (:height 30)))
    (alloy:enter active-p layout :constraints `((:left 5) (:bottom 5) (:medium (:left-of ,description 5)) (:height 30)))
    (alloy:finish-structure preview layout focus)))

(defmethod alloy:access ((preview module-preview) (field (eql 'preview))) (or (preview (alloy:object preview)) (// 'kandria 'empty-save)))

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
    (alloy:enter list clipper)
    (alloy:enter preview layout :constraints `((:left 100) (:right 630) (:bottom 100) (:top 100)))
    (alloy:enter clipper layout :constraints `((:width 500) (:right 70) (:bottom 100) (:top 100)))
    (alloy:enter scroll layout :constraints `((:width 20) (:right 50) (:bottom 100) (:top 100)))
    (alloy:enter (make-instance 'label :value (@ station-pick-destination)) layout :constraints `((:left 50) (:above ,clipper 10) (:size 500 50)))
    (dolist (module (list-modules :available))
      (let ((module (make-instance 'module-button :value module :layout-parent list)))
        (alloy:enter module focus :layer 1)))
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
