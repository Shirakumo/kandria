(in-package #:org.shirakumo.fraf.leaf)

(define-asset (leaf fi) image
    #p"fi.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (leaf fi-profile) image
    #p "fi-profile.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (leaf player) image
    #p"player.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (leaf player-profile) image
    #p"player-profile.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (leaf ice) image
    #p"ice.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (leaf icey-mountains) image
    #p "icey-mountains.png"
  :min-filter :nearest
  :mag-filter :nearest)

(defclass empty-world (world)
  ()
  (:default-initargs :name :untitled))

(defvar *complete* NIL)
(defmethod initialize-instance :after ((world empty-world) &key)
  (let ((region (make-instance 'region))
        (chunk (make-instance 'chunk :tileset (asset 'leaf 'ice))))
    (enter region world)
    (enter chunk region)
    (enter (make-instance 'fi) chunk)
    (enter (make-instance 'player :location (vec 64 64)) region)
    (let ((quest (make-instance 'quest-graph:quest :name :quest :title "Test"))
          (task (make-instance 'quest-graph:task :title "Talk"
                                                 :condition '*complete*))
          (dial (make-instance 'quest-graph:interaction
                               :interactable 'fi
                               :dialogue "
~ player
| A full month of work on the game! (:happy)
~ fi
| It's freezing here, how do you stand this?
! setf (location player) (vec 100 100)"))
          (end (make-instance 'quest-graph:end)))
      (quest-graph:connect quest task)
      (quest-graph:connect task end)
      (quest-graph:connect task dial)
      (let* ((*package* #.*package*)
             (storyline (quest:make-storyline (list quest) :quest-type 'quest)))
        (enter (make-instance 'world :storyline storyline) world)))))

(defclass main (trial:main)
  ((scene :initform NIL)
   (save :initform (make-instance 'save :name "test") :accessor save))
  (:default-initargs :clear-color (vec 2/17 2/17 2/17)
                     :title "Leaf - 0.0.0"
                     :width 1280
                     :height 720))

(defmethod initialize-instance ((main main) &key world)
  (call-next-method)
  (setf (scene main)
        (if world
            (load-world (pool-path 'leaf world))
            (make-instance 'empty-world))))

(defmethod setup-rendering :after ((main main))
  (disable :cull-face :scissor-test :depth-test))

(defmethod save-state ((main main) (_ (eql T)))
  (save-state main (save main)))

(defmethod load-state ((main main) (_ (eql T)))
  (load-state main (save main)))

(defmethod (setf scene) :after (scene (main main))
  (setf +world+ scene))

(defmethod finalize :after ((main main))
  (setf +world+ NIL))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))

(defmethod setup-scene ((main main) scene)
  (enter (make-instance 'textbox) scene)
  (enter (make-instance 'inactive-pause-menu) scene)
  (enter (make-instance 'inactive-editor) scene)
  (enter (make-instance 'camera) scene)
  (enter (make-instance 'render-pass) scene)
  ;; FIXME: fucked up
  (quest:activate (quest:find-quest "Test" (storyline (unit 'world scene)))))

#+leaf-inspector
(progn
  (sb-ext:defglobal +inspector+ NIL)
  
  (defmethod initialize-instance :after ((main main) &key)
    (setf +inspector+ (nth-value 1 (clouseau:inspect main :new-process t))))

  (defmethod finalize :after ((main main))
    (setf +world+ NIL)
    (setf +inspector+ NIL))

  (defmethod update :after ((main main) tt dt fc)
    (when (= 0 (mod fc 10))
      (let* ((pane (clim:find-pane-named +inspector+ 'clouseau::inspector))
             (state (clouseau::state pane)))
        (setf (clouseau:root-object state :run-hook-p t)
              (clouseau:root-object state))))))
