(in-package #:org.shirakumo.fraf.kandria)

(defclass module-preview (alloy:structure)
  ())

(defmethod initialize-instance :after ((preview module-preview) &key value)
  (let ((preview (make-instance 'icon :value (// 'kandria 'empty-save)))
        (title (make-instance 'label :data ()))
        (description (make-instance 'label :value "")))))

(defclass module-menu (pausing-panel menuing-panel)
  ())

(defmethod initialize-instance :after ((panel module-menu) &key current-station)
  (let* ((layout (make-instance 'eating-constraint-layout
                                :shapes (list (make-basic-background))))
         (clipper (make-instance 'alloy:clip-view :limit :x))
         (scroll (alloy:represent-with 'alloy:y-scrollbar clipper))
         
         (focus (make-instance 'alloy:focus-stack :orientation :horizontal))
         (list (make-instance 'alloy:vertical-linear-layout
                              :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern (colored:color 0 0 0 0.5)))
                              :min-size (alloy:size 100 50))))
    (alloy:enter list clipper)
    (alloy:enter preview layout :constraints `((:left 100) (:right 630) (:bottom 100) (:top 100)))
    (alloy:enter clipper layout :constraints `((:width 500) (:right 70) (:bottom 100) (:top 100)))
    (alloy:enter scroll layout :constraints `((:width 20) (:right 50) (:bottom 100) (:top 100)))
    (alloy:enter (make-instance 'label :value (@ station-pick-destination)) layout :constraints `((:left 50) (:above ,clipper 10) (:size 500 50)))
    (dolist (module (list-modules :loaded-only NIL))
      (let ((module (alloy:represent (alloy:value preview) 'alloy:radio :active-value module :layout-parent list)))
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
