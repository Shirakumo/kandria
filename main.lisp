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

(defclass empty-level (level)
  ()
  (:default-initargs :name :untitled))

(defvar *complete* NIL)
(defmethod initialize-instance :after ((level empty-level) &key)
  (let ((region (make-instance 'region))
        (chunk (make-instance 'chunk :tileset (asset 'leaf 'ice))))
    (enter region level)
    (enter chunk region)
    (enter (make-instance 'fi) chunk)
    (enter (make-instance 'player :location (vec 64 64)) region)
    (let ((start (make-instance 'quest-graph:start :title "Test"))
          (task (make-instance 'quest-graph:task :title "Talk"
                                                 :condition '*complete*))
          (dial (make-instance 'quest-graph:interaction
                               :interactable :fi
                               :dialogue "
~ :player
| A full month of work on the game! (:happy)
~ :fi
| It's freezing here, how do you stand this?
! setf *complete* T"))
          (end (make-instance 'quest-graph:end)))
      (quest-graph:connect start task)
      (quest-graph:connect task end)
      (quest-graph:connect task dial)
      (let* ((*package* #.*package*)
             (storyline (quest:make-storyline (list start))))
        (enter (make-instance 'world :storyline storyline) level)))))

(defclass main (trial:main)
  ((scene :initform NIL)
   (save :initform (make-instance 'save :name "test") :accessor save))
  (:default-initargs :clear-color (vec 2/17 2/17 2/17)
                     :title "Leaf - 0.0.0"
                     :width 1280
                     :height 720))

(defmethod initialize-instance ((main main) &key map)
  (call-next-method)
  (setf (scene main)
        (if map
            (make-instance 'level :file (pool-path 'leaf map))
            (make-instance 'empty-level))))

(defmethod setup-rendering :after ((main main))
  (disable :cull-face :scissor-test :depth-test))

(defmethod save-state ((main main) (_ (eql T)))
  (save-state main (save main)))

(defmethod load-state ((main main) (_ (eql T)))
  (load-state main (save main)))

(defmethod (setf scene) :after (scene (main main))
  (setf +level+ scene))

(defmethod finalize :after ((main main))
  (setf +level+ NIL))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))

(defmethod setup-scene ((main main) scene)
  (enter (make-instance 'textbox) scene)
  (enter (make-instance 'inactive-pause-menu) scene)
  (enter (make-instance 'inactive-editor) scene)
  (enter (make-instance 'camera) scene)
  (enter (make-instance 'render-pass) scene)
  ;; FIXME: fucked up
  (quest:activate (quest:find-quest "Test" (storyline (unit :world scene)))))
