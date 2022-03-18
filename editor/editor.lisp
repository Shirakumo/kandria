(in-package #:org.shirakumo.fraf.kandria)

(defmacro with-editor-error-handling (&body body)
  (let ((thunk (gensym "THUNK"))
        (handler (gensym "HANDLER")))
    `(flet ((,thunk ()
              ,@body)
            (,handler (error)
              (v:severe :trial.editor error)
              (alloy:message (princ-to-string error) :title "Error" :ui (unit 'ui-pass T))
              (invoke-restart ',handler)))
       (if (deploy:deployed-p)
           (with-simple-restart (,handler "Exit.")
             (handler-bind ((error #',handler))
               (,thunk)))
           (,thunk)))))

(defclass zoom-slider (alloy:ranged-slider)
  ()
  (:default-initargs
   :range '(0.3 . 1.3)
   :step 0.05
   :grid 0.05
   :ideal-bounds (alloy:extent 0 0 100 20)))

(defmethod alloy:value ((slider zoom-slider))
  (let ((val (call-next-method)))
    (expt val 1/5)))

(defmethod (setf alloy:value) (value (slider zoom-slider))
  (call-next-method (expt value 5) slider))

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
  ((vertex-array :initform (let ((buffer (make-instance 'vertex-buffer :data-usage :dynamic-draw
                                                                       :buffer-data (make-array 0 :element-type 'single-float :adjustable T :fill-pointer T))))
                             (make-instance 'vertex-array :bindings `((,buffer :stride 40 :offset  0 :size 3 :index 0)
                                                                      (,buffer :stride 40 :offset 12 :size 3 :index 1)
                                                                      (,buffer :stride 40 :offset 24 :size 4 :index 2))
                                                          :size 0)))))

(defmethod alloy:render ((pass ui-pass) (marker marker))
  (alloy:with-constrained-visibility ((alloy:bounds marker) pass)
    (render marker NIL)))

(defmethod alloy:suggest-bounds (bounds (marker marker)) bounds)

(defclass editor (pausing-panel menuing-panel alloy:observable-object)
  ((flare:name :initform :editor)
   (marker :initform (make-instance 'marker) :accessor marker)
   (zoom :initform NIL :accessor zoom)
   (entity :initform NIL :accessor entity)
   (tool :initform NIL :accessor tool)
   (alt-tool :accessor alt-tool)
   (toolbar :accessor toolbar)
   (history :initform (make-instance 'linear-history) :accessor history)
   (sidebar :initform NIL :accessor sidebar)
   (last-tick :initform 0 :accessor last-tick)))

(alloy:define-observable (setf entity) (entity alloy:observable))

(defmethod register-object-for-pass (pass (editor editor))
  (register-object-for-pass pass (maybe-finalize-inheritance 'trial::lines)))

(defmethod initialize-instance :after ((editor editor) &key)
  (let* ((focus (make-instance 'alloy:focus-list))
         (layout (make-instance 'alloy:border-layout))
         (toolbar (make-instance 'toolbar :editor editor :entity NIL))
         (entity (make-instance 'entity-widget :editor editor :side :west))
         (zoom (alloy:represent (zoom (camera +world+)) 'zoom-slider))
         (menu (alloy:with-menu
                 ("File"
                  ("New Region" (edit 'new-region editor))
                  ("Load Region..." (edit 'load-region editor))
                  :separator
                  ("Save Region" (edit 'save-region editor))
                  ("Save Region As..." (edit 'save-region-as editor))
                  :separator
                  ("Close Editor" (issue +world+ 'toggle-editor)))
                 ("State"
                  ("Save State" (edit 'save-game editor))
                  ("Save State As..." (edit 'save-game-as editor))
                  ("Load State..." (edit 'load-game editor))
                  :separator
                  ("Save Initial State" (edit 'save-initial-state editor)))
                 ("Edit"
                  ("Undo" (edit 'undo editor))
                  ("Redo" (edit 'redo editor))
                  :separator
                  ("Select" (edit 'select-entity editor))
                  ("Insert" (edit 'insert-enitty editor))
                  ("Clone" (edit 'clone-entity editor))
                  ("Delete" (edit 'delete-entity editor))
                  :separator
                  ("Set Lighting" (edit 'change-lighting editor)))
                 ("View"
                  ("Zoom In" (incf (alloy:value zoom) 0.1))
                  ("Zoom Out" (decf (alloy:value zoom) 0.1))
                  ("Center on Player" (setf (location (camera +world+)) (location (unit 'player T)))))
                 ("Help"
                  ("About"))
                 zoom)))
    (setf (alt-tool editor) 'browser)
    (setf (tool editor) 'browser)
    (setf (toolbar editor) toolbar)
    (setf (zoom editor) zoom)
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
  (setf (entity editor) (region +world+))
  (setf (background (unit 'background T)) (background 'editor))
  (update-background (unit 'background T) T)
  (setf (zoom (camera +world+)) (expt 0.8 5))
  (reset (unit 'lighting-pass T)))

(defmethod hide :after ((editor editor))
  (hide (tool editor))
  (when (chunk (unit 'player T))
    (switch-chunk (chunk (unit 'player T))))
  (snap-to-target (camera +world+) (unit 'player T))
  (issue +world+ 'force-lighting))

(defmethod (setf tool) :around ((tool tool) (editor editor))
  (let ((entity (entity editor)))
    (when (find (type-of tool) (applicable-tools entity))
      (trial:commit tool (loader +main+) :unload NIL)
      (when (and (tool editor) (not (eq tool (tool editor))))
        (hide (tool editor)))
      (call-next-method)
      (v:info :kandria.editor "Switched to ~a" (type-of tool)))
    tool))

(defmethod (setf tool) ((tool symbol) (editor editor))
  (setf (tool editor) (make-instance tool :editor editor)))

(defmethod (setf tool) ((tool class) (editor editor))
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
  (stage (background 'editor) area)
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
  (let* ((selected (entity editor))
         (vao (vertex-array (marker editor)))
         (buffer (first (first (bindings vao))))
         (array (buffer-data buffer)))
    (setf (fill-pointer array) 0)
    (labels ((evc (vec)
               (etypecase vec
                 (vec3
                  (vector-push-extend (vx vec) array)
                  (vector-push-extend (vy vec) array)
                  (vector-push-extend (vz vec) array))
                 (vec4
                  (vector-push-extend (vx vec) array)
                  (vector-push-extend (vy vec) array)
                  (vector-push-extend (vz vec) array)
                  (vector-push-extend (vw vec) array))))
             (emit (a b c)
               (let ((a-b (v- a b))
                     (b-a (v- b a)))
                 (evc a) (evc a-b) (evc c)
                 (evc b) (evc a-b) (evc c)
                 (evc a) (evc b-a) (evc c)
                 (evc b) (evc a-b) (evc c)
                 (evc b) (evc b-a) (evc c)
                 (evc a) (evc b-a) (evc c)))
             (add (color &rest vecs)
               (loop for (a b) on vecs
                     while b
                     do (emit a b color))))
      (for:for ((entity over (region +world+)))
        (when (and (typep entity 'sized-entity)
                   (not (eql 'layer (type-of entity))))
          (let* ((p (location entity))
                 (s (bsize entity))
                 (ul (vec3 (- (vx p) (vx s)) (+ (vy p) (vy s)) 0))
                 (ur (vec3 (+ (vx p) (vx s)) (+ (vy p) (vy s)) 0))
                 (br (vec3 (+ (vx p) (vx s)) (- (vy p) (vy s)) 0))
                 (bl (vec3 (- (vx p) (vx s)) (- (vy p) (vy s)) 0)))
            (add (if (eql entity selected)
                     (tvec 1 1 1 0.5)
                     (tvec 0.1 0.1 0.1 0.5))
                 ul ur ur br br bl bl ul)))
        (when (and (typep entity 'door)
                   (primary entity))
          (emit (vxy_ (location entity)) (vxy_ (location (target entity))) (tvec 1 0 0 0.5)))))
    (when (gl-name buffer)
      (resize-buffer buffer (* 4 (length array)) :data array :gl-type :float))
    (setf (size vao) (floor (length array) (+ 3 3 4)))))

(defmethod (setf entity) :before (value (editor editor))
  (setf (sidebar editor) NIL))

(defmethod (setf entity) :after (value (editor editor))
  (update-marker editor)
  (setf (tool editor) (default-tool editor))
  (reinitialize-instance (toolbar editor) :editor editor :entity (entity editor))
  (v:info :kandria.editor "Switched entity to ~a (~a)" value (type-of editor)))

(defmethod handle :around ((ev event) (editor editor))
  (when (typep ev 'tick)
    (handle ev (unit 'render T))
    (setf (last-tick editor) (fc ev)))
  (unless (call-next-method)
    (with-editor-error-handling
      (handle ev (cond ((retained :alt) (alt-tool editor))
                       (T (tool editor)))))))

(defmethod handle ((ev key-release) (editor editor))
  (let ((camera (camera +world+))
        (move-value (cond ((find :control (modifiers ev)) 0)
                          ((find :shift (modifiers ev)) 10)
                          (T 5))))
    (case (key ev)
      (:tab (setf (entity editor) (region +world+)) T)
      (:f5 (edit 'save-game T))
      (:f6 (edit 'save-region T))
      (:f7 (edit 'load-game T))
      (:f8 (edit 'load-initial-state T))
      (:delete (edit 'delete-entity T))
      (:insert (edit 'insert-entity T))
      (:w (incf (vy (location camera)) move-value))
      (:a (decf (vx (location camera)) move-value))
      (:s (decf (vy (location camera)) move-value))
      (:d (incf (vx (location camera)) move-value))
      (:period
       (loop with event = (make-instance 'tick :tt 0.0d0 :dt 0.01 :fc (last-tick editor))
             with queue = (trial::listener-queue +world+)
             for listener = (pop queue)
             while listener
             do (handle event listener))
       (update-marker editor)))))

(defmethod handle ((event text-entered) (editor editor))
  (case (char-downcase (char (text event) 0))
    (#\b (setf (tool editor) 'browser))
    (#\c (edit 'clone-entity T))
    (#\f (setf (tool editor) 'freeform))
    (#\h (setf (location (unit 'player T))
               (mouse-world-pos (cursor-position *context*)))
     (setf (state (unit 'player T)) :normal))
    (#\l (setf (tool editor) 'line))
    (#\o (when (retained :control)
           (edit 'load-region editor)))
    (#\p (setf (tool editor) 'paint))
    (#\r (setf (tool editor) 'rectangle))
    (#\s (when (retained :control)
           (if (retained :alt)
               (edit 'save-region-as editor)
               (edit 'save-region editor))))
    (#\t (edit 'toggle-lighting editor))
    (#\u (setf (entity editor) (unit 'player T)))
    (#\y (edit 'redo editor))
    (#\z (edit 'undo editor))
    (#\_ (when (retained :control)
           (edit 'undo editor)))
    (#\+ (incf (alloy:value (zoom editor)) 0.1))
    (#\- (decf (alloy:value (zoom editor)) 0.1))))

(defmethod handle ((event mouse-release) (editor editor))
  (when (and (eq (entity editor) (region +world+))
             (eq :left (button event)))
    (let ((pos (mouse-world-pos (pos event))))
      (setf (entity editor) (entity-at-point pos +world+)))))

(defmethod edit :around (thing (editor editor))
  (with-editor-error-handling
    (call-next-method)))

(defmethod edit :after (action (editor editor))
  (update-marker editor))

(defmethod edit (action (editor (eql T)))
  (edit action (find-panel 'editor)))

(defmethod commit ((action action) (editor editor))
  (redo action (unit 'region T))
  (commit action (history editor)))

(defmethod edit ((action (eql 'new-region)) (editor editor))
  (alloy:with-confirmation ("Are you sure you want to create a new region?" :ui (unit 'ui-pass T))
    (let ((old (region +world+))
          (region (make-instance 'region))
          (chunk (make-instance 'chunk)))
      (enter (make-instance 'background) region)
      (enter chunk region)
      (enter (make-instance 'player :chunk chunk) region)
      (enter region +world+)
      (setf (entity editor) region)
      (leave old +world+)
      (trial:commit +world+ +main+ :unload NIL)
      (setf (background (unit 'background T)) (background 'editor))
      (reset (camera +world+))
      (setf (target (camera +world+)) (unit 'player T))
      (update-background (unit 'background T) T))))

(defmethod edit ((action (eql 'load-region)) (editor editor))
  (flet ((load (path)
           (load-region path T)
           (setf (background (unit 'background T)) (background 'editor))
           (update-background (unit 'background T) T)
           (clear (history editor))
           (setf (entity editor) (region +world+))
           (trial:commit +world+ +main+)))
    (let ((path (file-select:existing :title "Select Region File")))
      (when path
        (load path)))))

(defmethod edit ((action (eql 'save-region)) (editor editor))
  (save-region T T))

(defmethod edit ((action (eql 'save-region-as)) (editor editor))
  (let ((path (file-select:new :title "Select Region File" :default (storage (packet +world+)) :filter '(("ZIP files" "zip")))))
    (when path
      (save-region (region +world+) path))))

;; FIXME: This information does not belong here. where else to put it? world-v0?
(defmethod edit ((action (eql 'load-initial-state)) (editor editor))
  (with-packet (packet (packet +world+) :offset (region-entry (region +world+) +world+)
                                        :direction :input)
    (decode-payload (first (parse-sexps (packet-entry "init.lisp" packet :element-type 'character))) (region +world+) packet 'save-v0)))

(defmethod edit ((action (eql 'save-initial-state)) (editor editor))
  (with-packet (packet (packet +world+) :offset (region-entry (region +world+) +world+)
                                        :direction :output)
    (with-packet-entry (stream "init.lisp" packet :element-type 'character)
      (princ* (encode-payload (region +world+) NIL packet 'save-v0) stream))))

(defmethod edit ((action (eql 'load-game)) (editor editor))
  (let ((path (file-select:existing :title "Select Save File" :default (file (state +main+)) :filter '(("ZIP files" "zip")))))
    (when path
      (load-state path T))))

(defmethod edit ((action (eql 'save-game)) (editor editor))
  (save-state +main+ T))

(defmethod edit ((action (eql 'save-game-as)) (editor editor))
  (let ((path (file-select:new :title "Select Save File" :default (print (file (state +main+))))))
    (when path
      (save-state (scene +main+)
                  (make-instance 'save-state :file path)))))

(defmethod edit ((action (eql 'delete-entity)) (editor editor))
  (let* ((entity (entity editor))
         (container (container entity)))
    (cond ((typep entity '(or player world region camera))
           (v:warn :kandria.editor "Refusing to delete ~a" entity)
           (alloy:message (format NIL "Cannot delete the ~a" (type-of entity)) :title "Error" :ui (unit 'ui-pass T)))
          (T
           ;; FIXME: Clean up stale data files from region packet
           ;;        Should probably do that as an explicit command to invoke at some point.
           ;;        Maybe at deploy time?
           (with-commit (editor)
             ((leave* entity container)
              (setf (entity editor) (region +world+)))
             ((enter-and-load entity container +main+)
              (setf (entity editor) entity)))))))

(defmethod edit ((action (eql 'select-entity)) (editor editor))
  (make-instance 'selector :ui (unit 'ui-pass T)))

(defmethod edit ((action (eql 'insert-entity)) (editor editor))
  (make-instance 'creator :ui (unit 'ui-pass T)))

(defmethod edit ((action (eql 'clone-entity)) (editor editor))
  (cond ((typep (entity editor) 'player)
         (v:warn :kandria.editor "Refusing to clone the player.")
         (alloy:message "Cannot clone the player." :title "Error" :ui (unit 'ui-pass T)))
        (T
         (let ((loc (vcopy (closest-acceptable-location (entity editor) (location (camera +world+))))))
           (edit (make-instance 'insert-entity :entity (clone (entity editor) :location loc)) editor)))))

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
    (trial:commit entity (loader +main+) :unload NIL)
    (when (typep entity 'chunk)
      (setf (show-solids entity) T))
    (with-commit (editor)
      ((enter* entity (unit 'region T))
       (setf (entity editor) entity))
      ((leave* entity (unit 'region T))
       (setf (entity editor) (region +world+))))))

(defmethod edit ((action (eql 'change-lighting)) (editor editor))
  (make-instance 'lighting :ui (unit 'ui-pass T)))

(defmethod edit ((action (eql 'toggle-lighting)) (editor editor))
  (let ((pass (unit 'lighting-pass T)))
    (setf (lighting pass)
          (if (eql (gi 'none) (lighting pass))
              (gi (chunk (camera +world+)))
              (gi 'none)))
    (force-lighting pass)))
