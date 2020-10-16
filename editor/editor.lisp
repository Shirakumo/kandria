(in-package #:org.shirakumo.fraf.kandria)

(defclass sidebar (single-widget)
  ((side :initarg :side :accessor side)
   (entity :initform NIL :accessor entity)
   (editor :initarg :editor :initform (alloy:arg! :editor) :accessor editor))
  (:metaclass alloy:widget-class))

(defmethod initialize-instance :before ((sidebar sidebar) &key editor)
  (setf (slot-value sidebar 'entity) (entity editor)))

(alloy:define-subobject (sidebar representation -100) ('alloy:sidebar :side (side sidebar))
  (alloy:enter (slot-value sidebar 'layout) representation)
  (alloy:enter (slot-value sidebar 'focus) representation))

(define-shader-entity marker (trial::lines standalone-shader-entity alloy:layout-element)
  ())

(defmethod alloy:render ((pass ui-pass) (marker marker))
  (alloy:with-constrained-visibility ((alloy:bounds marker) pass)
    (render marker NIL)))

(defmethod alloy:suggest-bounds (bounds (marker marker)) bounds)

(defclass editor (pausing-panel alloy:observable-object)
  ((flare:name :initform :editor)
   (marker :initform (make-instance 'marker) :accessor marker)
   (entity :initform NIL :accessor entity)
   (tool :accessor tool)
   (alt-tool :accessor alt-tool)
   (toolbar :accessor toolbar)
   (history :initform (make-instance 'linear-history) :accessor history)
   (sidebar :initform NIL :accessor sidebar)))

(alloy:define-observable (setf entity) (entity alloy:observable))

(defmethod register-object-for-pass (pass (editor editor))
  (register-object-for-pass pass (maybe-finalize-inheritance 'trial::lines)))

(defmethod initialize-instance :after ((editor editor) &key)
  (let* ((focus (make-instance 'alloy:focus-list))
         (layout (make-instance 'alloy:border-layout))
         (menu (make-instance 'editmenu))
         (toolbar (make-instance 'toolbar :editor editor :entity NIL))
         (entity (make-instance 'entity-widget :editor editor :side :west)))
    (setf (alt-tool editor) 'browser)
    (setf (tool editor) 'browser)
    (setf (toolbar editor) toolbar)
    (alloy:observe 'entity editor (lambda (value object) (setf (entity entity) value)))
    (alloy:enter menu layout :place :north :size (alloy:un 30))
    (alloy:enter menu focus)
    (alloy:enter toolbar layout :place :south :size (alloy:un 30))
    (alloy:enter toolbar focus)
    (alloy:enter entity layout :place :west :size (alloy:un 300))
    (alloy:enter entity focus)
    (alloy:enter (marker editor) layout :place :center)
    (alloy:finish-structure editor layout focus)
    (update-marker editor)))

(defmethod show :after ((editor editor) &key)
  (setf (lighting (unit 'lighting-pass T)) NIL))

(defmethod hide :after ((editor editor))
  (setf (lighting (unit 'lighting-pass T)) (lighting (region (unit :camera T)))))

(defmethod (setf tool) :before ((tool tool) (editor editor))
  (let ((entity (entity editor)))
    (unless (find (type-of tool) (applicable-tools entity))
      (error "Cannot use tool~%  ~a~%with~%  ~a" tool (entity editor)))
    (trial:commit tool (loader (handler *context*)) :unload NIL)))

(defmethod (setf tool) ((tool symbol) (editor editor))
  (setf (tool editor) (make-instance tool :editor editor)))

(defmethod (setf alt-tool) ((tool symbol) (editor editor))
  (setf (alt-tool editor) (make-instance tool :editor editor)))

(defmethod default-tool ((editor editor))
  (or (default-tool (entity editor))
      'browser))

(defmethod undo ((editor editor) region)
  (undo (history editor) region))

(defmethod redo ((editor editor) region)
  (redo (history editor) region))

(defmethod stage :after ((editor editor) (area staging-area))
  (stage (marker editor) area))

(defmethod (setf sidebar) :before ((null null) (editor editor))
  (let ((previous (sidebar editor)))
    (when previous
      (alloy:leave (sidebar editor) (alloy:layout-element editor))
      (alloy:leave (sidebar editor) (alloy:focus-element editor)))))

(defmethod (setf sidebar) :after ((sidebar sidebar) (editor editor))
  (alloy:enter sidebar (alloy:layout-element editor) :place :east :size (alloy:un 300))
  (alloy:enter sidebar (alloy:focus-element editor)))

(defun update-marker (editor)
  (let ((coords ())
        (selected (entity editor)))
    (flet ((add (color &rest vecs)
             (dolist (vec vecs)
               (push (list vec color) coords))))
      (for:for ((entity over (region +world+)))
        (when (typep entity '(and sized-entity (or chunk (not layer))))
          (let* ((p (location entity))
                 (s (bsize entity))
                 (ul (vec3 (- (vx p) (vx s)) (+ (vy p) (vy s)) 0))
                 (ur (vec3 (+ (vx p) (vx s)) (+ (vy p) (vy s)) 0))
                 (br (vec3 (+ (vx p) (vx s)) (- (vy p) (vy s)) 0))
                 (bl (vec3 (- (vx p) (vx s)) (- (vy p) (vy s)) 0)))
            (add (if (eql entity selected)
                     (vec 1 1 1 0.5)
                     (vec 0 0 0 0.5))
                 ul ur ur br br bl bl ul)))
        (when (and (typep entity 'door)
                   (primary entity))
          (add (vec 1 0 0 0.5) (vxy_ (location entity)) (vxy_ (location (target entity)))))))
    (replace-vertex-data (marker editor) coords)))

(defmethod (setf entity) :before (value (editor editor))
  (setf (sidebar editor) NIL))

(defmethod (setf entity) :after (value (editor editor))
  (update-marker editor)
  (setf (tool editor) (default-tool editor))
  (reinitialize-instance (toolbar editor) :editor editor :entity (entity editor))
  (v:info :kandria.editor "Switched entity to ~a (~a)" value (type-of editor)))

(defmethod handle :around ((ev event) (editor editor))
  (unless (call-next-method)
    (handle ev (cond ((retained :alt) (alt-tool editor))
                     (T (tool editor))))))

(defmethod handle ((ev key-release) (editor editor))
  (let ((camera (unit :camera T)))
    (case (key ev)
      (:tab (setf (entity editor) NIL) T)
      (:f1 (edit 'save-region T))
      (:f2 (edit 'load-region T))
      (:f3)
      (:f4)
      (:f5)
      (:f6)
      (:f7)
      (:f8)
      (:f9)
      (:f10)
      (:f11)
      (:delete (edit 'delete-entity T))
      (:insert (edit 'insert-entity T))
      (:c (edit 'clone-entity T))
      (:b (setf (tool editor) 'browser))
      (:f (setf (tool editor) 'freeform))
      (:p (setf (tool editor) 'paint))
      (:l (setf (tool editor) 'line))
      (:w (incf (vy (location camera)) 5))
      (:a (decf (vx (location camera)) 5))
      (:s (decf (vy (location camera)) 5))
      (:d (incf (vx (location camera)) 5)))))

(defmethod handle ((event mouse-release) (editor editor))
  (when (and (null (entity editor)) (eq :left (button event)))
    (let ((pos (mouse-world-pos (pos event))))
      (setf (entity editor) (entity-at-point pos +world+)))))

(defmethod edit :after (action (editor editor))
  (update-marker editor))

(defmethod edit (action (editor (eql T)))
  (edit action (find-panel 'editor)))

(defmethod edit ((action action) (editor editor))
  (redo action (unit 'region T))
  (commit action (history editor)))

(defmethod edit ((action (eql 'load-region)) (editor editor))
  (if (retained :control)
      (let ((path (file-select:existing :title "Select Region File")))
        (when path
          (load-region path T)))
      (load-region T T))
  (clear (history editor))
  (setf (entity editor) NIL)
  (trial:commit +world+ (handler *context*)))

(defmethod edit ((action (eql 'save-region)) (editor editor))
  (if (retained :control)
      (let ((path (file-select:new :title "Select Region File" :default (storage (packet +world+)))))
        (save-region T path))
      (save-region T T)))

(defmethod edit ((action (eql 'load-game)) (editor editor))
  (if (retained :control)
      (let ((path (file-select:existing :title "Select Save File" :default (file (state (handler *context*))))))
        (when path
          (load-state path T)))
      (load-state T T))
  (trial:commit +world+ (handler *context*)))

(defmethod edit ((action (eql 'save-game)) (editor editor))
  (if (retained :control)
      (let ((path (file-select:new :title "Select Save File" :default (file (state (handler *context*))))))
        (when path
          (save-state T path)))
      (save-state T T)))

(defmethod edit ((action (eql 'delete-entity)) (editor editor))
  ;; FIXME: Clean up stale data files from region packet.
  (leave (entity editor) (container (entity editor)))
  (setf (entity editor) NIL))

(defmethod edit ((action (eql 'insert-entity)) (editor editor))
  (make-instance 'creator :ui (unit 'ui-pass T)))

(defmethod edit ((action (eql 'clone-entity)) (editor editor))
  (edit (make-instance 'insert-entity :entity (clone (entity editor))) editor))

(defmethod edit ((action (eql 'undo)) (editor editor))
  (undo editor (unit 'region T)))

(defmethod edit ((action (eql 'redo)) (editor editor))
  (redo editor (unit 'region T)))

#+(OR)
(defmethod edit ((action (eql 'inspect)) (editor editor))
  #+swank
  (let ((swank::*buffer-package* *package*)
        (swank::*buffer-readtable* *readtable*))
    (swank:inspect-in-emacs (entity editor) :wait NIL)))

(defclass insert-entity () ((entity :initarg :entity :initform (alloy:arg! :entity) :accessor entity)))

(defmethod edit ((action insert-entity) (editor editor))
  (let ((entity (entity action))
        (*package* #.*package*))
    (when (typep entity 'located-entity)
      (setf (location entity) (vcopy (location (unit :camera T)))))
    (enter-and-load entity (unit 'region T) (handler *context*))
    (setf (entity editor) entity)))
