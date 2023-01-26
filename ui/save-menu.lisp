(in-package #:org.shirakumo.fraf.kandria)

(defclass name-input (alloy:input-line)
  ())

(defmethod alloy:handle ((ev alloy:focus-right) (input name-input))
  ;; FIXME: avoid issues with events also being fired from letter keys
  (alloy:exit input)
  (alloy:focus-next (alloy:focus-parent input)))

(defmethod alloy:activate :after ((input name-input))
  (when (and (steam:steamworks-available-p)
             (not (eql :keyboard +input-source+)))
    (or (steam:show-text-input (steam:interface 'steam:steamutils T)
                               :default (alloy:text input)
                               :description (@ enter-name-prompt))
        (ignore-errors (steam:show-floating-text-input (steam:interface 'steam:steamutils T)))
        (v:warn :trial.steam "Failed to open gamepad text input panel..."))))

(presentations:define-realization (ui name-input)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:border simple:rectangle)
   (alloy:margins)
   :pattern colors:white
   :line-width (alloy:un 1))
  ((:label simple:text)
   (alloy:margins 1)
   alloy:text
   :font (setting :display :font)
   :wrap T
   :size (alloy:un 20)
   :halign :start
   :valign :middle)
  ((:cursor simple:cursor)
   (presentations:find-shape :label alloy:renderable)
   0
   :pattern colors:white))

(presentations:define-update (ui name-input)
  (:label
   :pattern colors:white))

(defclass name-input-panel (menuing-panel)
  ())

(defmethod initialize-instance :after ((panel name-input-panel) &key data on-complete)
  (let* ((layout (make-instance 'load-screen-layout))
         (focus (make-instance 'alloy:focus-list))
         (input (make-instance 'name-input :data data :focus-parent focus))
         (button (alloy:represent (@ accept-prompt-panel) 'button :focus-parent focus)))
    (alloy:on alloy:activate (button)
      (hide panel)
      (funcall on-complete (alloy:value data)))
    (alloy:on alloy:accept (input)
      (alloy:activate button))
    (alloy:on alloy:exit (focus)
      (hide panel))
    (alloy:enter input layout :constraints `((:size 300 50) (:center :w :h)))
    (alloy:enter button layout :constraints `((:size 100 50) (:center :h) (:right-of ,input 0)))
    (alloy:enter (make-instance 'label :value (@ enter-name-prompt) :style `((:label :halign :middle))) layout
                 :constraints `((:size 1000 50) (:center :w) (:above ,input 5)))
    (alloy:finish-structure panel layout focus)))

(defmethod show :after ((panel name-input-panel) &key)
  (alloy:activate (alloy:focus-element panel)))

(defclass save-button (alloy:direct-value-component)
  ((intent :initarg :intent :initform :new :accessor intent)
   (texture :initform NIL :accessor texture)
   (alloy:ideal-size :initform (alloy:size 500 108))))

(defmethod initialize-instance :after ((button save-button) &key)
  (setf (texture button)
        (let ((image (image (alloy:value button))))
          (etypecase image
            (pathname (handler-case
                          (with-error-logging (:kandria.save)
                            (generate-resources 'image-loader image :min-filter :linear :mag-filter :linear))
                        (error ()
                          (// 'kandria 'corrupted-save))))
            (vector (error "TODO"))
            (null (// 'kandria 'empty-save)))))
  (trial:commit (texture button) (loader +main+) :unload NIL))

(defmethod alloy:activate ((button save-button))
  (harmony:play (// 'sound 'ui-start-game))
  (ecase (intent button)
    (:new
     (labels ((launch-new-game (name)
                (setf (state +main+) (alloy:value button))
                (setf (author (state +main+)) name)
                (load-game NIL +main+))
              (prompt-name ()
                (let ((data (make-instance 'alloy:value-data :value (pathname-utils:directory-name (user-homedir-pathname)))))
                  (show-panel 'name-input-panel :data data :on-complete #'launch-new-game))))
       (if (equal (@ empty-save-file) (author (alloy:value button)))
           (prompt-name)
           (show (make-instance 'prompt-panel :text (@formats 'save-overwrite-reminder
                                                              (format-absolute-time (save-time (alloy:value button))))
                                              :on-accept #'prompt-name)
                 :width (alloy:un 500)
                 :height (alloy:un 300)))))
    (:load
     (when (exists-p (alloy:value button))
       (handler-case
           (with-error-logging (:kandria.save)
             (resume-state (alloy:value button) +main+))
         #+kandria-release
         (error () (messagebox (@ save-file-corrupted-notice))))))))

(presentations:define-realization (ui save-button)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern (if alloy:focus
                (colored:color 0.15 0.15 0.15 1)
                (colored:color 0.15 0.15 0.15 0.5)))
  ((:icon simple:icon)
   (alloy:extent 0 0 192 (alloy:ph 1))
   (texture alloy:renderable)
   :sizing :contain)
  ((:author simple:text)
   (alloy:margins 210 10 10 10)
   (author alloy:value)
   :size (alloy:un 30)
   :pattern colors:white
   :font (setting :display :font)
   :valign :top :halign :left)
  ((:save-time simple:text)
   (alloy:margins 210 10 10 10)
   (if (exists-p alloy:value)
       (format-absolute-time (save-time alloy:value) :time-zone NIL)
       "")
   :size (alloy:un 20)
   :pattern colors:white
   :font (setting :display :font)
   :valign :bottom :halign :left))

(presentations:define-update (ui save-button)
  (:background
   :pattern (if alloy:focus
                (colored:color 0.15 0.15 0.15 1)
                (colored:color 0.15 0.15 0.15 0.5)))
  (:icon)
  (:author
   :pattern (if alloy:focus colors:white colors:gray))
  (:save-time
   :pattern (if alloy:focus colors:white colors:gray)))

(presentations:define-animated-shapes save-button
  (:background (simple:pattern :duration 0.2))
  (:author (simple:pattern :duration 0.2))
  (:save-time (simple:pattern :duration 0.2)))

(defclass save-menu (menuing-panel)
  ())

(defmethod stage :after ((menu save-menu) (area staging-area))
  (stage (// 'kandria 'corrupted-save) area))

(defmethod initialize-instance :after ((panel save-menu) &key intent)
  (let ((layout (make-instance 'load-screen-layout))
        (list (make-instance 'alloy:vertical-linear-layout))
        (focus (make-instance 'alloy:focus-list))
        (saves (list-saves)))
    (alloy:enter list layout :constraints `((:left 50) (:right 50) (:bottom 100) (:top 100)))
    (dolist (name '("1" "2" "3" "4"))
      (let ((save (or (find-canonical-save name)
                      (make-instance 'save-state :author (@ empty-save-file) :filename (second names)))))
        (make-instance 'save-button :value save :layout-parent list :focus-parent focus :intent intent)))
    (alloy:enter (make-instance 'label :value (ecase intent
                                                (:new (@ new-game))
                                                (:load (@ load-game)))
                                       :style `((:label :size ,(alloy:un 40))))
                 layout :constraints `((:top 20) (:left 50) (:right 10) (:above ,list 10)))
    (let ((back (alloy:represent (@ go-backwards-in-ui) 'button)))
      (alloy:enter back layout :constraints `((:left 50) (:below ,list 10) (:size 200 50)))
      (alloy:enter back focus)
      (alloy:on alloy:activate (back)
        (harmony:play (// 'sound 'ui-focus-out))
        (hide panel))
      (alloy:on alloy:exit (focus)
        (setf (alloy:focus focus) :strong)
        (setf (alloy:focus back) :weak)))
    (alloy:finish-structure panel layout focus)))
