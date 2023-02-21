(in-package #:org.shirakumo.fraf.kandria)

(defclass screen-gap (alloy:layout-element alloy:renderable)
  ())

(defmethod alloy:suggest-size ((size alloy:size) (screen-gap screen-gap))
  (alloy:size (alloy:w size) (alloy:vh 1)))

(defclass paragraph (label)
  ())

(presentations:define-update (ui paragraph)
  (:label
   :size (alloy:un 15)
   :wrap T
   :valign :top
   :halign :middle))

(defclass header (label)
  ((level :initarg :level :initform 1 :accessor level)))

(presentations:define-update (ui header)
  (:label
   :size (case (level alloy:renderable)
           (0 (alloy:un 50))
           (1 (alloy:un 35))
           (2 (alloy:un 25))
           (T (alloy:un 20)))
   :valign :middle
   :halign :middle))

(defclass icon (alloy:direct-value-component alloy:icon)
  ())

(presentations:define-update (ui icon)
  (:icon
   :image alloy:value
   :sizing :contain))

(defmethod alloy:suggest-size ((size alloy:size) (icon icon))
  (alloy:extent (alloy:w size)
                (alloy:un 200)))

(defclass credits-layout (org.shirakumo.alloy.layouts.constraint:layout alloy:focus-element alloy:renderable)
  ())

(defmethod alloy:handle ((ev alloy:pointer-event) (layout credits-layout))
  T)

(defmethod presentations:realize-renderable :after (ui (layout credits-layout))
  (let ((scroll (alloy:index-element 0 layout)))
    (setf (slot-value scroll 'alloy:offset) (alloy:px-point 0 most-negative-single-float))))

(defmethod alloy:handle ((ev alloy:exit) (layout credits-layout)))

(presentations:define-realization (ui credits-layout)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern colors:black))

(defclass credits (menuing-panel)
  ((scroll :accessor scroll)
   (ideal :initform NIL :accessor ideal)
   (on-hide :initarg :on-hide :initform (lambda ()) :accessor on-hide)))

(defmethod stage :after ((credits credits) (area staging-area))
  (stage (// 'music 'credits) area))

(defmethod show :after ((credits credits) &key)
  (harmony:seek (// 'music 'credits) 0)
  (setf (override (unit 'environment +world+)) (// 'music 'credits)))

(defmethod hide :after ((credits credits))
  (setf (game-speed +main+) 1.0)
  (when (eql (// 'music 'credits) (override (unit 'environment +world+)))
    (setf (override (unit 'environment +world+)) NIL))
  (labels ((traverse (node)
             (typecase node
               (alloy:layout
                (alloy:call-with-elements #'traverse node))
               (presentations::renderable
                (map NIL #'traverse (presentations:shapes node)))
               (simple:icon
                (deallocate (simple:image node))))))
    (traverse (scroll credits)))
  (setf (active-p (find-class 'in-menu)) T)
  (funcall (on-hide credits)))

(defmethod handle ((ev tick) (panel credits))
  (let* ((scroll (scroll panel))
         (offset (alloy:pxy (alloy:offset scroll))))
    (cond ((< offset 0)
           (setf (game-speed +main+) (if (retained 'skip) 30.0 1.0))
           (let* ((size (+ (alloy:pxh (alloy:inner (scroll panel)))
                           (* 2 (alloy:pxh (scroll panel)))))
                  (dur (mixed:duration (trial-harmony:voice (// 'music 'credits))))
                  ;; KLUDGE: I don't know why we have to do 2.0 here but it isn't right.
                  ;;         1.0 is far too slow, too, though, so.... ????
                  (spd (* 2.0 (/ size dur))))
             (incf offset (* spd (dt ev)))
             (setf (alloy:offset scroll) (alloy:px-point 0 offset))))
          ((not (harmony:active-p (trial-harmony:voice (// 'music 'credits))))
           (transition :kind :black (hide panel))))))

(defmethod handle :after (ev (panel credits))
  (when (or (typep ev '(or back toggle-menu))
            (and (typep ev 'key-press)
                 (eql :escape (key ev))))
    (transition :kind :black (hide panel))))

(defmethod from-markless ((path pathname) layout)
  (from-markless (cl-markless:parse path T) layout))

(defmethod from-markless ((element cl-markless-components:unit-component) layout))

(defmethod from-markless ((element cl-markless-components:header) layout)
  (alloy:enter (make-instance 'header :value (cl-markless-components:text element)
                                      :level (cl-markless-components:depth element))
               layout))

(defmethod from-markless ((element cl-markless-components:image) layout)
  (let* ((renderer (unit 'ui-pass T))
         (image (simple:request-image renderer (pool-path 'kandria (cl-markless-components:target element)))))
    (allocate image)
    (alloy:enter (make-instance 'icon :value image) layout)))

(defmethod from-markless ((element cl-markless-components:parent-component) layout)
  (loop for child across (cl-markless-components:children element)
        do (from-markless child layout)))

(defmethod from-markless ((element cl-markless-components:paragraph) layout)
  (alloy:enter (make-instance 'paragraph :value (cl-markless-components:text element)) layout))

(defmethod from-markless ((element string) layout)
  (alloy:enter (make-instance 'paragraph :value element) layout))

(defmethod initialize-instance :after ((panel credits) &key (file (merge-pathnames "CREDITS.mess" (language-dir))))
  (let* ((layout (make-instance 'credits-layout))
         (scroll (make-instance 'alloy:clip-view))
         (credits (make-instance 'alloy:vertical-linear-layout
                                 :min-size (alloy:size (alloy:vw 1) 100)
                                 :cell-margins (alloy:margins 0))))
    (alloy:enter scroll layout :constraints `(:fill))
    (alloy:enter credits scroll)
    (setf (scroll panel) scroll)
    (alloy:enter (make-instance 'screen-gap) credits)
    (from-markless (merge-pathnames file (data-root)) credits)
    (alloy:enter (make-instance 'screen-gap) credits)
    (let ((prompts (make-instance 'alloy:horizontal-linear-layout :align :end)))
      (alloy:enter (make-instance 'prompt-label :value (coerce-button-string 'toggle-menu)) prompts)
      (alloy:enter (make-instance 'prompt-description :value (language-string 'exit-credits NIL)) prompts)
      (alloy:enter (make-instance 'prompt-label :value (coerce-button-string 'skip)) prompts)
      (alloy:enter (make-instance 'prompt-description :value (language-string 'faster-credits NIL)) prompts)
      (alloy:enter prompts layout :constraints `((:right 30) (:bottom 30) (:size 500 50))))
    (alloy:finish-structure panel layout layout)))

(defun show-credits (&key (transition T) (state (state +main+)) on-hide)
  (reset (unit 'environment +world+))
  (flet ((thunk ()
           (let ((player (unit 'player +world+)))
             ;; First, hide everything.
             #+kandria-release
             (when (and state player (setting :debugging :send-diagnostics))
               (submit-trace state (unit 'player +world+)))
             (let ((els ()))
               (alloy:do-elements (el (alloy:popups (alloy:layout-tree (unit 'ui-pass +world+))))
                 (when (typep el 'popup)
                   (push el els)))
               (mapc #'hide els))
             (hide-panel 'main-menu)
             ;; show the end screen and the credits panel, which will hide to reveal the end screen.
             (if on-hide
                 (show-panel 'credits :on-hide on-hide)
                 (show-panel 'credits :on-hide (lambda ()
                                                 (show-panel 'stats-screen :next #'return-to-main-menu :player player))))
             ;; Reset the camera and remove the region to reduce lag
             (reset (camera +world+))
             (leave (region +world+) +world+)
             (setf (storyline +world+) (make-instance 'storyline)))))
    (if transition
        (transition
          :kind :black
          (thunk))
        (thunk))))
