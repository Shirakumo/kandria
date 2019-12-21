(in-package #:org.shirakumo.fraf.leaf)

(define-subject editor (base-editor)
  ((sidebar :initform NIL :accessor sidebar)))

;;; Update sidebar on class change
(defmethod update-instance-for-different-class :around ((editor editor) current &key)
  (when (sidebar editor)
    (let ((layout (alloy:root (alloy:layout-tree (ui editor))))
          (focus (alloy:root (alloy:focus-tree (ui editor)))))
      (alloy:leave (sidebar editor) layout)
      (alloy:leave (sidebar editor) focus))
    (when (typep current 'editor)
      (setf (sidebar current) NIL)))
  (call-next-method))

(defmethod update-instance-for-different-class :around (previous (editor editor) &key)
  (call-next-method)
  (when (sidebar editor)
    (let ((layout (alloy:root (alloy:layout-tree (ui editor))))
          (focus (alloy:root (alloy:focus-tree (ui editor)))))
      (alloy:enter (sidebar editor) layout :place :east :size (alloy:un 300))
      (alloy:enter (sidebar editor) focus)
      (alloy:register (sidebar editor) (ui editor)))))

(defmethod active-p ((editor editor)) T)

(defmethod (setf entity) :after (value (editor editor))
  (change-class editor (editor-class value))
  (v:info :leaf.editor "Switched entity to ~a (~a)" value (type-of editor)))

(defmethod handle :before (event (editor editor))
  (handle event (controller (handler *context*)))
  (handle event (unit :camera +world+)))

(defmethod handle ((event event) (editor editor))
  (unless (handle event (ui editor))
    (call-next-method)
    (handle event (tool editor))))

(defmethod paint ((editor editor) (target rendering-pass))
  (paint (ui editor) target))

(define-handler (editor mouse-release) (ev pos)
  (unless (entity editor)
    (setf (entity editor) (entity-at-point (mouse-world-pos pos) +world+))))

(define-handler (editor select-entity) (ev)
  (setf (entity editor) NIL))

(define-handler (editor load-world) (ev)
  (if (retained 'modifiers :control)
      (let ((world (load-world +world+)))
        (change-scene (handler *context*) world))
      (let ((path (file-select:existing :title "Select World File" :default (storage (packet +world+)))))
        (when path (change-scene (handler *context*) (load-world path))))))

(define-handler (editor save-region) (ev)
  (if (retained 'modifiers :control)
      (let ((path (file-select:new :title "Select Region File" :default (storage (packet +world+)))))
        (save-region T path))
      (save-region T T)))

(define-handler (editor load-region) (ev)
  (let ((old (unit 'region +world+)))
    (cond ((retained 'modifiers :control)
           (transition old (load-region T T)))
          (T
           (let ((path (file-select:existing :title "Select Region File")))
             (when path (transition old (load-region path T))))))))

(define-handler (editor save-game) (ev)
  (save-state T T))

(define-handler (editor load-game) (ev)
  (let ((old (unit 'region +world+)))
    (flet ((load! (state)
             (load-state state T)
             (transition old (unit 'region +world+))))
      (cond ((retained 'modifiers :control) (load! T))
            (T (let ((path (file-select:existing :title "Select Save File" :default (file (state (handler *context*))))))
                 (load! path)))))))

(define-handler (editor undo) (ev)
  (undo editor (unit 'region T)))

(define-handler (editor redo) (ev)
  (redo editor (unit 'region T)))

(define-handler (editor insert-entity) (ev)
  )

(define-handler (editor delete-entity) (ev)
  (leave (entity editor) (unit 'region +world+))
  (setf (entity editor) NIL))

(define-handler (editor clone-entity) (ev)
  (setf (state editor) :dragging)
  (let ((clone (clone (entity editor))))
    (transition clone +world+)
    (enter clone +world+)
    (setf (entity editor) clone)))

(define-handler (editor inspect-entity) (ev)
  #+swank
  (let ((swank::*buffer-package* *package*)
        (swank::*buffer-readtable* *readtable*))
    (swank:inspect-in-emacs (entity editor) :wait NIL)))

(define-handler (editor trial:tick) (ev)
  (let ((loc (location (unit :camera +world+)))
        (spd (if (retained 'modifiers :shift) 10 1)))
    (cond ((retained 'movement :left) (decf (vx loc) spd))
          ((retained 'movement :right) (incf (vx loc) spd)))
    (cond ((retained 'movement :down) (decf (vy loc) spd))
          ((retained 'movement :up) (incf (vy loc) spd)))))
