(in-package #:org.shirakumo.fraf.kandria)

(defclass station-button (alloy:direct-value-component alloy:button)
  ((source :initarg :source :accessor source)
   (target :initarg :target :accessor target)))

(defmethod alloy:text ((button station-button))
  (language-string (name (alloy:value button))))

(defmethod (setf alloy:focus) :after (focus (button station-button))
  (when focus
    ;; FIXME: Show preview
    ))

(defmethod alloy:activate ((button station-button))
  (cond ((unlocked-p (alloy:value button))
         (unless (eq (alloy:value button) (source button))
           (trigger (alloy:value button) (source button))
           (harmony:play (// 'sound 'train-departing-and-arriving)))
         (harmony:play (// 'sound 'ui-confirm))
         (hide-panel 'fast-travel-menu))
        (T
         (harmony:play (// 'sound 'ui-error) :reset T))))

(presentations:define-realization (ui station-button)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:label simple:text)
   (alloy:margins 5)
   alloy:text
   :size (alloy:un 15)
   :font (setting :display :font)
   :valign :middle
   :halign :start)
  ((:current-bg simple:polygon)
   (list (alloy:point (alloy:pw 1.0) (alloy:ph 0.2))
         (alloy:point (alloy:pw 0.7) (alloy:ph 0.2))
         (alloy:point (alloy:pw 0.7) (alloy:ph 0.4))
         (alloy:point (alloy:pw 0.68) (alloy:ph 0.5))
         (alloy:point (alloy:pw 0.7) (alloy:ph 0.6))
         (alloy:point (alloy:pw 0.7) (alloy:ph 0.8))
         (alloy:point (alloy:pw 1.0) (alloy:ph 0.8)))
   :pattern colors:red
   :hidden-p (not (eq (source alloy:renderable) alloy:value)))
  ((:current-text simple:text)
   (alloy:extent (alloy:pw 0.72) (alloy:ph 0.3) (alloy:pw 0.3) (alloy:ph 0.4))
   (@ current-fast-travel-location)
   :size (alloy:un 12)
   :font (setting :display :font)
   :pattern colors:white
   :valign :middle
   :halign :start
   :hidden-p (not (eq (source alloy:renderable) alloy:value))))

(presentations:define-update (ui station-button)
  (:background
   :pattern (if (unlocked-p alloy:value)
                (if alloy:focus colors:white colors:black)
                (if alloy:focus colors:dim-gray colors:black)))
  (:label
   :pattern (if (unlocked-p alloy:value)
                (if alloy:focus colors:black colors:white)
                colors:gray)))

(defclass fast-travel-menu (pausing-panel menuing-panel)
  ())

(defmethod initialize-instance :after ((panel fast-travel-menu) &key current-station)
  (let* ((layout (make-instance 'eating-constraint-layout
                                :shapes (list (make-basic-background))))
         (clipper (make-instance 'alloy:clip-view :limit :x))
         (scroll (alloy:represent-with 'alloy:y-scrollbar clipper))
         (preview (make-instance 'icon :value (// 'kandria 'empty-save)))
         (focus (make-instance 'alloy:focus-stack :orientation :horizontal))
         (list (make-instance 'alloy:vertical-linear-layout
                              :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern (colored:color 0 0 0 0.5)))
                              :min-size (alloy:size 100 50))))
    (alloy:enter list clipper)
    (alloy:enter preview layout :constraints `((:left 100) (:right 630) (:bottom 100) (:top 100)))
    (alloy:enter clipper layout :constraints `((:width 500) (:right 70) (:bottom 100) (:top 100)))
    (alloy:enter scroll layout :constraints `((:width 20) (:right 50) (:bottom 100) (:top 100)))
    (alloy:enter (make-instance 'label :value (@ station-pick-destination)) layout :constraints `((:left 50) (:above ,clipper 10) (:size 500 50)))
    (dolist (station (list-stations))
      (let ((station (make-instance 'station-button :value station :source current-station :target panel :layout-parent list)))
        (alloy:enter station focus :layer 1)
        (alloy:on alloy:focus (focus station)
          (when focus
            (setf (alloy:value preview) (if (unlocked-p (alloy:value station))
                                            (// 'kandria (name (alloy:value station)))
                                            (// 'kandria 'empty-save)))))))
    (let ((back (alloy:represent (@ go-backwards-in-ui) 'button)))
      (alloy:enter back layout :constraints `((:left 50) (:below ,clipper 10) (:size 200 50)))
      (alloy:enter back focus :layer 0)
      (alloy:on alloy:activate (back)
        (hide panel))
      (alloy:on alloy:exit (focus)
        (setf (alloy:focus focus) :strong)
        (setf (alloy:focus back) :weak)))
    (alloy:finish-structure panel layout focus)))

(defmethod stage :after ((menu fast-travel-menu) (area staging-area))
  (stage (// 'kandria 'empty-save) area))

(defmethod show :after ((menu fast-travel-menu) &key)
  (harmony:play (// 'sound 'ui-fast-travel-map-open))
  (setf (alloy:index (alloy:focus-element menu)) (cons 1 0)))
