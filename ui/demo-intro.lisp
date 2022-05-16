(in-package #:org.shirakumo.fraf.kandria)

(defclass demo-intro-panel (menuing-panel fullscreen-panel)
  ())

(defmethod initialize-instance :after ((panel demo-intro-panel) &key)
  (let ((layout (make-instance 'eating-constraint-layout
                               :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern colors:black))))
        (label (make-instance 'label :value "This demo showcases content from part way through the story.

The full game features a different intro, and many new environments, characters and quests."
                                     :style `((:label :halign :middle :pattern ,colors:black :size ,(alloy:un 15))))))
    (alloy:enter label layout :constraints '((:required (:max-width 1000) (:center :w :h))
                                       (:left 100) (:right 100) (:height 200)))
    (alloy:finish-structure panel layout label)))

(defmethod show :after ((panel demo-intro-panel) &key)
  (let ((label (alloy:focus-element panel)))
    (alloy:with-unit-parent label
      (presentations:realize-renderable (unit 'ui-pass T) label)
      (animation:apply-animation 'fade-in (presentations:find-shape :label label)))))

(animation:define-animation fade-in
  0.0 ((setf simple:pattern) colors:black)
  2.0 ((setf simple:pattern) colors:white))
