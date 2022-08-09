(in-package #:org.shirakumo.fraf.kandria)

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

(defmethod alloy:suggest-bounds ((bounds alloy:extent) (icon icon))
  (alloy:extent (alloy:x bounds)
                (alloy:y bounds)
                (alloy:w bounds)
                (alloy:un 200)))

(defclass credits-layout (alloy:fullscreen-layout alloy:focus-element alloy:renderable)
  ())

(defmethod alloy:handle ((ev alloy:pointer-event) (layout credits-layout))
  T)

(defmethod alloy:handle ((ev alloy:exit) (layout credits-layout)))

(presentations:define-realization (ui credits-layout)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern colors:black))

(defclass credits (menuing-panel)
  ((credits :accessor credits)
   (offset :initform -100 :accessor offset)
   (ideal :initform NIL :accessor ideal)))

(defmethod show :after ((credits credits) &key)
  #++
  (setf (override (unit 'environment +world+)) (// 'music 'credits)))

(defmethod hide :after ((credits credits))
  (setf (game-speed +main+) 1.0)
  (setf (override (unit 'environment +world+)) NIL)
  (labels ((traverse (node)
             (typecase node
               (alloy:layout
                (alloy:call-with-elements #'traverse node))
               (presentations::renderable
                (map NIL #'traverse (presentations:shapes node)))
               (simple:icon
                (deallocate (simple:image node))))))
    (traverse (credits credits))))

(defmethod handle ((ev tick) (panel credits))
  (let* ((extent (alloy:bounds (credits panel)))
         (ideal (or (ideal panel) (setf (ideal panel) (alloy:pxh (alloy:suggest-bounds extent (credits panel)))))))
    (setf (game-speed +main+) (if (retained 'skip) 10.0 1.0))
    (alloy:with-unit-parent (alloy:layout-element panel)
      (setf (alloy:bounds (credits panel)) 
            (alloy:px-extent (alloy:pxx extent)
                             (- (offset panel) ideal)
                             (alloy:vw 1)
                             ideal))
      (incf (offset panel) (* (alloy:to-px (alloy:un 50)) (dt ev)))
      (when (< (+ ideal (height *context*)) (offset panel))
        (hide panel)))))

(defmethod handle :after (ev (panel credits))
  (when (typep ev '(or back toggle-menu))
    (hide panel)))

(defmethod from-markless (path layout)
  (from-markless (cl-markless:parse path T) layout))

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

(defmethod initialize-instance :after ((panel credits) &key (file (merge-pathnames "CREDITS.mess" (language-dir (setting :language)))))
  (let* ((layout (make-instance 'credits-layout))
         (credits (make-instance 'alloy:vertical-linear-layout
                                 :layout-parent layout
                                 :min-size (alloy:size (alloy:vw 1) 100)
                                 :cell-margins (alloy:margins 10))))
    (setf (credits panel) credits)
    (from-markless (merge-pathnames file (root)) credits)
    (alloy:finish-structure panel layout layout)))

(defun show-credits (&key)
  (reset (unit 'environment +world+))
  (transition
    :kind :black
    ;; First, hide everything.
    #+kandria-release
    (when (and state player (setting :debugging :send-diagnostics))
      (submit-trace state player)
      (setf state NIL player NIL))
    (let ((els ()))
      (alloy:do-elements (el (alloy:popups (alloy:layout-tree (unit 'ui-pass +world+))))
        (when (typep el 'popup)
          (push el els)))
      (mapc #'hide els))
    ;; show the end screen and the credits panel, which will hide to reveal the end screen.
    (show-panel 'stats-screen :next #'return-to-main-menu)
    (show-panel 'credits)
    ;; Reset the camera and remove the region to reduce lag
    (reset (camera +world+))
    (leave (region +world+) +world+)
    (setf (storyline +world+) (make-instance 'quest:storyline))
    (compile-to-pass +world+ +world+)
    (invoke-restart 'discard-events)))
