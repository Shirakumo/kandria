(in-package #:org.shirakumo.fraf.kandria)

(defclass upgrade-checkbox (alloy:checkbox)
  ((materials :initarg :materials :accessor materials)))

(defmethod alloy:active-p ((checkbox upgrade-checkbox))
  (<= (alloy:on-value checkbox) (alloy:value checkbox)))

(defmethod alloy:activate ((checkbox upgrade-checkbox))
  (let ((player (unit 'player T)))
    (when (= (1+ (sword-level player)) (alloy:on-value checkbox))
      (cond ((loop for (count item) in (materials checkbox)
                   always (<= count (item-count item player)))
             (loop for (count item) in (materials checkbox)
                   do (retrieve item player count))
             (harmony:play (// 'sound 'ui-confirm))
             (harmony:play (// 'sound 'ui-upgrade-placeholder))
             (call-next-method))
            (T
             (alloy:with-unit-parent checkbox
               (animation:apply-animation 'upgrade-not-fulfilled
                                          (presentations:find-shape 'requirements checkbox)))
             (harmony:play (// 'sound 'ui-error) :reset T))))))

(defmethod selectable-p ((checkbox upgrade-checkbox))
  (<= (1- (alloy:on-value checkbox)) (alloy:value checkbox)))

(presentations:define-realization (ui upgrade-checkbox T)
  ((level simple:text)
   (alloy:extent (alloy:pw -1) (alloy:ph 1.11) (alloy:pw 3) 30)
   (@formats 'upgrade-ui-level (alloy:on-value alloy:renderable))
   :pattern (if (selectable-p alloy:renderable) colors:white colors:dark-gray)
   :font (setting :display :font)
   :size (alloy:un 20)
   :halign :middle
   :valign :middle)
  ((improvement simple:text)
   (alloy:extent (alloy:pw -1) -30 (alloy:pw 3) 30)
   (@formats 'upgrade-ui-improvement (* 50 (alloy:on-value alloy:renderable)))
   :pattern (if (selectable-p alloy:renderable) colors:white colors:dark-gray)
   :font (setting :display :font)
   :size (alloy:un 15)
   :halign :middle
   :valign :middle)
  ((backdrop simple:rectangle)
   (alloy:extent (alloy:pw 2.5) (alloy:ph 1.4) 250 (alloy:ph 3.7))
   :pattern (simple:request-gradient alloy:renderer 'simple:linear-gradient
                                     (alloy:point 0 (alloy:ph 3.7)) (alloy:point 0 (alloy:ph 1.4))
                                     #((0.2 #.(colored:color 0.1 0.1 0.1 0.9))
                                       (1.0 #.(colored:color 0.1 0.1 0.1 0.1)))))
  ((requirements simple:text)
   (alloy:extent (alloy:pw 2.8) (alloy:ph 1.3) 500 (alloy:ph 3.7))
   (@formats 'upgrade-ui-requirements
             (loop with player = (unit 'player +world+)
                   for (count item) in (materials alloy:renderable)
                   collect (list (item-count item player) count (language-string item))))
   :pattern colors:white
   :font (setting :display :font)
   :size (alloy:un 15)
   :valign :top
   :halign :left)
  ((indicator simple:line-strip)
   (vector (alloy:point (alloy:pw 0.5) (alloy:ph 1.8))
           (alloy:point (alloy:pw 2.5) (alloy:ph 4.5))
           (alloy:point (alloy:pw 2.5) (alloy:ph 5.0)))
   :pattern colors:white
   :line-width (alloy:un 2)))

(presentations:define-update (ui upgrade-checkbox)
  (level)
  (improvement
   :text (@formats 'upgrade-ui-improvement (* 50 (alloy:on-value alloy:renderable))))
  (backdrop
   :hidden-p (not alloy:focus))
  (requirements
   :pattern (if alloy:focus colors:white colors:transparent))
  (indicator
   :pattern (if alloy:focus colors:white colors:transparent)))

(presentations:define-animated-shapes upgrade-checkbox
  (requirements (simple:pattern :duration 0.2))
  (indicator (simple:pattern :duration 0.2)))

(animation:define-animation upgrade-not-fulfilled
  0.1 ((setf simple:pattern) colors:red)
  0.5 ((setf simple:pattern) colors:white))

(defclass upgrade-ui (pausing-panel menuing-panel)
  ())

(defmethod initialize-instance :after ((panel upgrade-ui) &key)
  ;; FIXME: spruce this up a little.
  (let* ((player (unit 'player T))
         (layout (make-instance 'eating-constraint-layout
                                :shapes (list (make-basic-background))))
         (data (make-instance 'alloy:accessor-data :object player :accessor 'sword-level))
         (focus (make-instance 'alloy:focus-stack :orientation :vertical)))
    (alloy:enter (make-instance 'icon :value (// 'kandria 'sword)) layout :constraints `(:center (:fill :w) (:height 200)))
    (loop for (level x y . materials) in
          '((1 100 150 (1 item:rusted-clump) (50 item:parts) (1 item:silver-ore))
            (2 300 150 (200 item:parts) (3 item:silver-ore))
            (3 500 150 (500 item:parts) (1 item:gold-nugget) (1 item:coolant) (2 item:thermal-fluid))
            (4 700 150 (1000 item:parts) (2 item:gold-nugget) (10 item:coolant) (2 item:thermal-fluid))
            (5 900 150 (2000 item:parts) (3 item:gold-nugget) (2 item:pearl) (3 item:hardened-alloy) (3 item:coolant) (2 item:refined-oil)))
          for box = (alloy:represent-with 'upgrade-checkbox data :on level :materials materials)
          do (alloy:enter box focus)
             (alloy:enter box layout :constraints `((:left ,x) (:bottom ,y) (:size 50 50))))
    (alloy:enter (make-instance 'label :value (@ upgrade-ui-title)) layout :constraints `((:left 50) (:top 40) (:size 500 50)))
    (let ((back (alloy:represent (@ go-backwards-in-ui) 'button)))
      (alloy:enter back layout :constraints `((:left 50) (:bottom 40) (:size 200 50)))
      (alloy:enter back focus :layer 1)
      (alloy:on alloy:activate (back)
        (hide panel))
      (alloy:on alloy:exit (focus)
        (setf (alloy:focus focus) :strong)
        (setf (alloy:focus back) :weak)))
    (alloy:finish-structure panel layout focus)))

(defmethod show :after ((menu upgrade-ui) &key)
  (harmony:play (// 'sound 'ui-fast-travel-map-open))
  (setf (alloy:index (alloy:focus-element menu)) (cons 0 0)))
