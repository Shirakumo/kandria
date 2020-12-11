(in-package #:org.shirakumo.fraf.kandria)

(defclass tab-button (alloy:value-component)
  ((alloy:text :initarg :text :accessor alloy:text)
   (alloy:index :initarg :index :accessor alloy:index)))

(defmethod alloy:activate ((button tab-button))
  (setf (alloy:focus button) :strong)
  (setf (alloy:value button) (alloy:index button)))

(defmethod alloy:active-p ((button tab-button))
  (= (alloy:value button) (alloy:index button)))

(presentations:define-realization (ui tab-button)
  ((:border simple:rectangle)
   (alloy:margins 0 50 0 2)
   :pattern colors:white)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font "PromptFont"
   :size (alloy:un 20)
   :halign :middle
   :valign :middle))

(presentations:define-update (ui tab-button)
  (:border
   :hidden-p (not (alloy:active-p alloy:renderable)))
  (:label
   :pattern (if (alloy:active-p alloy:renderable)
                colors:white
                (colored:color 0.9 0.9 0.9))))

(defclass setting-label (alloy:label)
  ())

(presentations:define-update (ui setting-label)
  (:label :size (alloy:un 15)))

(presentations:define-update (ui alloy:renderable)
  (:background
   :pattern (colored:color 0.05 0.05 0.05)))

(defclass option-layout (org.shirakumo.alloy.layouts.constraint:layout pane)
  ())

(defclass options-menu (pausing-panel)
  ())

(defmethod initialize-instance :after ((menu options-menu) &key)
  (let ((layout (make-instance 'option-layout))
        (tabs (make-instance 'alloy:horizontal-linear-layout :min-size (alloy:size 200 50)))
        (center (make-instance 'alloy:swap-layout))
        (focus (make-instance 'alloy:focus-stack))
        (back (make-instance 'button :value (@ go-backwards-in-ui) :on-activate (lambda () (hide menu)))))
    (alloy:enter tabs layout :constraints `((:top 0) (:left 0) (:right 0) (:height 50)))
    (alloy:enter back layout :constraints `((:bottom 0) (:left 0) (:width 100) (:height 50)))
    (alloy:enter center layout :constraints `((:left 50) (:right 50) (:below ,tabs 20) (:above ,back 50)))
    (macrolet ((with-tab ((tab name) &body fill)
                 `(let* ((,tab (make-instance 'alloy:grid-layout :col-sizes '(200 300) :row-sizes '(50)))
                         (button (alloy:represent (alloy:index center) 'tab-button :index (alloy:element-count tabs) :text ,name)))
                    (alloy:enter button tabs)
                    (alloy:enter button focus :layer 0)
                    (alloy:enter ,tab center)
                    ,@fill))
               (control (layout label setting type &rest args)
                 `(let ((label (alloy:represent (@ ,label) 'setting-label))
                        (slider (alloy:represent (setting ,@setting) ,type ,@args)))
                    (alloy:enter label ,layout)
                    (alloy:enter slider ,layout)
                    (alloy:enter slider focus :layer 1))))
      (with-tab (audio (@ audio-settings))
        (control audio master-volume (:audio :volume :master) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
        (control audio effect-volume (:audio :volume :effect) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
        (control audio speech-volume (:audio :volume :speech) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
        (control audio music-volume (:audio :volume :music) 'alloy:ranged-slider :range '(0 . 1) :step 0.1))
      ;; FIXME: Video settings need to be confirmed first.
      (with-tab (video (@ video-settings))
        (let ((modes (loop for mode in (cl-glfw3:get-video-modes (cl-glfw3:get-primary-monitor))
                           collect (list (getf mode '%CL-GLFW3:WIDTH) (getf mode '%CL-GLFW3:HEIGHT))))
              (apply (make-instance 'button :value (@ apply-video-settings-now) :on-activate #'apply-video-settings)))
          (control video screen-resolution (:display :resolution) 'alloy:combo-set :value-set modes)
          (control video should-application-fullscreen (:display :fullscreen) 'alloy:switch)
          (control video activate-vsync (:display :vsync) 'alloy:switch)
          (control video user-interface-scale-factor (:display :ui-scale) 'alloy:ranged-slider :range '(0.25 . 2.0) :step 0.25)
          (alloy:enter apply video)
          (alloy:enter apply focus :layer 1)))
      (with-tab (gameplay (@ gameplay-settings))
        (control gameplay screen-shake-strength (:gameplay :screen-shake) 'alloy:ranged-slider :range '(0.0 . 16.0) :step 1.0))
      (with-tab (language (@ language-settings))
        (control language game-language (:language :code) 'alloy:combo-set :value-set +languages+)))
    (alloy:enter back focus :layer 2)
    (alloy:finish-structure menu layout focus)))
