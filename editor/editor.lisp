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
  ((alloy:tooltip :initform "Zoom"))
  (:default-initargs
   :range '(0.3 . 1.3)
   :step 0.05
   :grid 0.05
   :ideal-size (alloy:extent 0 0 100 20)))

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
  (alloy:constrain-visibility (alloy:size (alloy:w marker) (alloy:h marker)) pass)
  (render marker NIL))

(defmethod alloy:suggest-size (size (marker marker)) size)

(define-global +editor-history+ (make-instance 'linear-history))

(defclass editor (pausing-panel menuing-panel alloy:observable-object)
  ((name :initform :editor)
   (marker :initform (make-instance 'marker) :accessor marker)
   (zoom :initform NIL :accessor zoom)
   (entity :initform +world+ :accessor entity)
   (tool :initform NIL :accessor tool)
   (alt-tool :accessor alt-tool)
   (toolbar :accessor toolbar)
   (history :initform +editor-history+ :accessor history)
   (sidebar :initform NIL :accessor sidebar)
   (track-background-p :initform NIL :accessor track-background-p)
   (last-tick :initform 0 :accessor last-tick)
   (edited-entities :initform () :accessor edited-entities)))

(alloy:define-observable (setf entity) (entity alloy:observable))

(defmethod initialize-instance :after ((editor editor) &key)
  (let* ((focus (make-instance 'alloy:focus-list))
         (layout (make-instance 'alloy:border-layout))
         (toolbar (make-instance 'toolbar :editor editor :entity NIL))
         (entity (make-instance 'entity-widget :editor editor :side :west))
         (zoom (alloy:represent (zoom (camera +world+)) 'zoom-slider))
         (top (make-instance 'alloy:vertical-linear-layout :min-size (alloy:size 10 30) :cell-margins (alloy:margins)))
         (menu (alloy:with-menu
                 ("File"
                  ("New World" (edit 'new-world editor))
                  ("Load World..." (edit 'load-world editor))
                  :separator
                  ("Save World" (edit 'save-world editor))
                  ("Save World As..." (edit 'save-world-as editor))
                  :separator
                  ("Close Editor" (issue +world+ 'toggle-editor)))
                 ("State"
                  ("Save State" (edit 'save-game editor))
                  ("Save State As..." (edit 'save-game-as editor))
                  ("Load State" (edit 'load-game editor))
                  ("Load State..." (edit 'load-game-as editor))
                  :separator
                  ("Save Initial State" (edit 'save-initial-state editor)))
                 ("Edit"
                  ("Undo" (edit 'undo editor))
                  ("Redo" (edit 'redo editor))
                  :separator
                  ("Select" (edit 'select-entity editor))
                  ("Insert" (edit 'insert-entity editor))
                  ("Clone" (edit 'clone-entity editor))
                  ("Delete" (edit 'delete-entity editor))
                  ("History" (edit 'show-history editor)))
                 ("View"
                  ("Zoom In" (incf (alloy:value zoom) 0.1))
                  ("Zoom Out" (decf (alloy:value zoom) 0.1))
                  ("Center on Player" (v<- (location (camera +world+)) (location (unit 'player T))))
                  ("Fit Map Into View" (edit 'fit-into-view editor))
                  :separator
                  ("Toggle Background" (setf (track-background-p editor) (not (track-background-p editor))))
                  ("Toggle Lighting" (edit 'toggle-lighting editor)))
                 ("Tools"
                  ("Render Module Preview" (edit 'render-preview editor))
                  ("Reload Language" (refresh-language T)))
                 ("Help"
                  ("Documentation" (open-in-browser "https://kandria.com/editor")))
                 zoom)))
    (setf (alt-tool editor) 'browser)
    (setf (toolbar editor) toolbar)
    (setf (zoom editor) zoom)
    (setf (tool editor) 'browser)
    (alloy:observe 'entity editor (lambda (value object) (setf (entity entity) value)))
    (alloy:enter menu top)
    (alloy:enter menu focus)
    (alloy:enter toolbar top)
    (alloy:enter toolbar focus)
    (alloy:enter top layout :place :north :size (alloy:un 60))
    (alloy:enter entity layout :place :west :size (alloy:un 300))
    (alloy:enter entity focus)
    (alloy:enter (marker editor) layout :place :center)
    (alloy:finish-structure editor layout focus)
    (create-marker editor)))

(defmethod show :after ((editor editor) &key)
  (setf (entity editor) +world+)
  (setf (background (unit 'background T)) (background 'editor))
  (update-background (unit 'background T) T)
  (setf (zoom (camera +world+)) (expt 0.8 5))
  (reset (unit 'lighting-pass T)))

(defmethod hide :after ((editor editor))
  (dolist (entity (edited-entities editor))
    (recompute entity))
  (setf (edited-entities editor) NIL)
  (hide (tool editor))
  (for:for ((entity over (region +world+)))
    (when (and (typep entity 'chunk)
               (null (show-solids entity)))
      (setf (visibility entity) 0.0)))
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
  (setf (tool editor) (find-class tool)))

(defmethod (setf tool) ((tool class) (editor editor))
  (alloy:do-elements (element (alloy:layout-element (toolbar editor)))
    (when (eql (class-of (alloy:active-value element)) tool)
      (return (setf (tool editor) (alloy:active-value element))))))

(defmethod (setf alt-tool) ((tool symbol) (editor editor))
  (setf (alt-tool editor) (make-instance tool :editor editor)))

(defmethod default-tool ((editor editor))
  (or (default-tool (entity editor))
      'browser))

(defmethod (setf track-background-p) :after (value (editor editor))
  (unless value
    (setf (background (unit 'background T)) (background 'editor))
    (update-background (unit 'background T) T)))

(defmethod undo ((editor editor) region)
  (undo (history editor) region))

(defmethod redo ((editor editor) region)
  (redo (history editor) region))

(defmethod stage :after ((editor editor) (area staging-area))
  (stage (simple:request-font (unit 'ui-pass T) "Brands") area)
  (stage (background 'editor) area)
  (stage (marker editor) area))

(defmethod (setf sidebar) :before ((null null) (editor editor))
  (let ((previous (sidebar editor)))
    (when previous
      (alloy:leave (sidebar editor) (alloy:layout-element editor))
      (alloy:leave (sidebar editor) (alloy:focus-element editor)))))

(defmethod (setf sidebar) :after ((sidebar sidebar) (editor editor))
  (alloy:enter sidebar (alloy:layout-element editor) :place :east :size 200)
  (alloy:enter sidebar (alloy:focus-element editor)))

(defun create-marker (editor)
  (let* ((vao (vertex-array (marker editor)))
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
                   (not (eql 'layer (type-of entity)))
                   (not (eql 'bg-layer (type-of entity))))
          (let* ((p (location entity))
                 (s (bsize entity))
                 (ul (vec3 (- (vx p) (vx s)) (+ (vy p) (vy s)) 0))
                 (ur (vec3 (+ (vx p) (vx s)) (+ (vy p) (vy s)) 0))
                 (br (vec3 (+ (vx p) (vx s)) (- (vy p) (vy s)) 0))
                 (bl (vec3 (- (vx p) (vx s)) (- (vy p) (vy s)) 0)))
            (add (tvec 0.1 0.1 0.1 0.5) ul ur ur br br bl bl ul)))
        (when (and (typep entity 'door)
                   (primary entity))
          (emit (vxy_ (location entity)) (vxy_ (location (target entity))) (tvec 1 0 0 0.5))))
      (let ((z (tvec 0 0 0)))
        (add (tvec 1 1 1 0.5) z z z z z z z z)))
    (when (gl-name buffer)
      (resize-buffer buffer (* 4 (length array)) :data array :gl-type :float))
    (setf (size vao) (floor (length array) (+ 3 3 4)))))

(defun update-marker (editor)
  (let* ((entity (entity editor))
         (buffer (first (first (bindings (vertex-array (marker editor))))))
         (array (buffer-data buffer))
         (start (- (length array) 420))
         (i start))
    (labels ((evc (vec)
               (etypecase vec
                 (vec3
                  (setf (aref array (+ i 0)) (vx vec))
                  (setf (aref array (+ i 1)) (vy vec))
                  (setf (aref array (+ i 2)) (vz vec))
                  (incf i 3))))
             (emit (a b)
               (let ((a-b (v- a b))
                     (b-a (v- b a)))
                 (evc a) (evc a-b) (incf i 4)
                 (evc b) (evc a-b) (incf i 4)
                 (evc a) (evc b-a) (incf i 4)
                 (evc b) (evc a-b) (incf i 4)
                 (evc b) (evc b-a) (incf i 4)
                 (evc a) (evc b-a) (incf i 4)))
             (add (&rest vecs)
               (loop for (a b) on vecs
                     while b
                     do (emit a b))))
      (if (and (typep entity 'sized-entity)
               (not (eql 'layer (type-of entity)))
               (not (eql 'bg-layer (type-of entity))))
          (let* ((p (location entity))
                 (s (bsize entity))
                 (ul (vec3 (- (vx p) (vx s)) (+ (vy p) (vy s)) 0))
                 (ur (vec3 (+ (vx p) (vx s)) (+ (vy p) (vy s)) 0))
                 (br (vec3 (+ (vx p) (vx s)) (- (vy p) (vy s)) 0))
                 (bl (vec3 (- (vx p) (vx s)) (- (vy p) (vy s)) 0)))
            (add ul ur ur br br bl bl ul))
          (let ((z (tvec 0 0 0)))
            (add z z z z z z z z))))
    (when (gl-name buffer)
      (update-buffer-data buffer array))))

(defmethod (setf entity) :before (value (editor editor))
  (when (typep (entity editor) 'chunk)
    (setf (show-solids (entity editor)) NIL)
    (loop for layer across (layers (entity editor))
          do (setf (visibility layer) 1.0)))
  (setf (sidebar editor) NIL))

(defmethod (setf entity) :after (value (editor editor))
  (update-marker editor)
  (reinitialize-instance (toolbar editor) :editor editor :entity (entity editor))
  (setf (tool editor) (default-tool editor))
  (v:info :kandria.editor "Switched entity to ~a (~a)" value (type-of editor)))

(defmethod handle :around ((ev event) (editor editor))
  (when (typep ev 'tick)
    (handle ev (unit 'render T))
    (setf (last-tick editor) (fc ev))
    (when (track-background-p editor)
      (let ((entity (entity-at-point (location (camera +world+)) +world+)))
        (when (typep entity 'chunk)
          (setf (background (unit 'background T)) (background entity))
          (update-background (unit 'background T) T)))))
  (unless (call-next-method)
    (with-editor-error-handling
      (handle ev (cond ((retained :alt) (alt-tool editor))
                       (T (tool editor)))))))

(defmethod handle ((ev key-release) (editor editor))
  (let ((camera (camera +world+))
        (move-value (cond ((find :control (modifiers ev)) 0)
                          ((find :shift (modifiers ev)) 10)
                          (T 5)))
        (local (local-key-string *context* (key ev))))
    (case (if local (char-downcase (char local 0)) (key ev))
      (:tab (setf (entity editor) +world+) T)
      (:f5 (edit 'save-game T))
      (:f6 (edit 'save-region T))
      (:f7 (edit 'load-game T))
      (:f8 (edit 'load-initial-state T))
      (:delete (edit 'delete-entity T))
      (:insert (edit 'insert-entity T))
      (:up (incf (vy (location camera)) move-value))
      (:left (decf (vx (location camera)) move-value))
      (:down (decf (vy (location camera)) move-value))
      (:right (incf (vx (location camera)) move-value))
      (:period
       (loop with event = (make-instance 'tick :tt 0.0d0 :dt 0.01 :fc (last-tick editor))
             with queue = (trial::listener-queue +world+)
             for listener = (pop queue)
             while listener
             do (handle event listener))
       (update-marker editor))
      ((#\+ :plus) (incf (alloy:value (zoom editor)) 0.1))
      ((#\- :minus :dash) (decf (alloy:value (zoom editor)) 0.1))
      ((#\_ :underscore) (when (retained :control)
                           (edit 'undo editor)))
      (#\b (setf (tool editor) 'browser))
      (#\c (edit 'clone-entity T))
      (#\d (setf (tool editor) 'drag))
      (#\f (setf (tool editor) 'freeform))
      (#\h (edit 'move editor))
      (#\l (setf (tool editor) 'line))
      (#\o (when (retained :control)
             (edit 'load-world editor)))
      (#\p (setf (tool editor) 'paint))
      (#\r (setf (tool editor) 'rectangle))
      (#\s (when (retained :control)
             (if (retained :alt)
                 (edit 'save-region-as editor)
                 (edit 'save-region editor))))
      (#\t (edit 'toggle-lighting editor))
      (#\u (setf (entity editor) (unit 'player T)))
      (#\y (edit 'redo editor))
      (#\z (edit 'undo editor)))))

(defmethod handle ((event mouse-press) (editor editor))
  (setf (alloy:focus (alloy:focus-element editor)) :strong)
  (when (and (eq (entity editor) +world+)
             (eq :left (button event)))
    (let ((pos (mouse-world-pos (pos event))))
      (setf (entity editor) (or (entity-at-point pos +world+) +world+))))
  NIL)

(defmethod handle ((event mouse-double-click) (editor editor))
  (when (eq :left (button event))
    (let ((pos (mouse-world-pos (pos event))))
      (setf (entity editor) (or (entity-at-point pos +world+) +world+)))))

(defmethod edit :around (thing (editor editor))
  (with-editor-error-handling
    (call-next-method)))

(defmethod edit :after (action (editor editor))
  (update-marker editor))

(defmethod edit (action (editor (eql T)))
  (edit action (find-panel 'editor)))

(defmethod commit ((action action) (editor editor))
  (push (entity editor) (edited-entities editor))
  (redo action T)
  (commit action (history editor))
  (create-marker editor)
  (setf (changes-saved-p +main+) NIL))

(defmethod edit ((action (eql 'new-world)) (editor editor))
  (with-saved-changes-prompt
    (let ((old (region +world+))
          (region (make-instance 'region))
          (chunk (make-instance 'chunk)))
      (clear +editor-history+)
      (enter (make-instance 'background) region)
      (enter chunk region)
      (enter (make-instance 'player :chunk chunk) region)
      (leave old +world+)
      (enter region +world+)
      (setf (entity editor) +world+)
      (trial:commit +world+ +main+ :unload NIL)
      (setf (background (unit 'background region)) (background 'editor))
      (reset +world+)
      (reset (camera +world+))
      (setf (target (camera +world+)) (unit 'player region))
      (update-background (unit 'background region) T)
      (setf (changes-saved-p +main+) T)
      (show-cursor *context*))))

(defmethod edit ((action (eql 'load-world)) (editor editor))
  (with-saved-changes-prompt
    (let ((path (file-select:existing :title "Select World File")))
      (when path
        (load-into-world (minimal-load-world path) :edit T)))))

(defmethod edit ((action (eql 'save-world)) (editor editor))
  (depot:with-depot (depot (depot +world+) :commit T)
    (save-world +world+ depot))
  (setf (changes-saved-p +main+) T))

(defmethod edit ((action (eql 'save-world-as)) (editor editor))
  (let ((path (file-select:new :title "Select World File" :default (depot:to-pathname (depot +world+)) :filter '(("ZIP files" "zip")))))
    (when path
      (setf (depot +world+) (save-world +world+ path))
      (setf (changes-saved-p +main+) T))))

;; FIXME: This information does not belong here. where else to put it? world-v0?
(defmethod edit ((action (eql 'load-initial-state)) (editor editor))
  (let ((depot (depot:entry "region" (depot +world+))))
    (decode-payload (first (parse-sexps (depot:read-from (depot:entry "init.lisp" depot) 'character))) (region +world+) depot 'save-v0)))

(defmethod edit ((action (eql 'save-initial-state)) (editor editor))
  (setf (clock +world+) 0.0)
  (reset (u 'player))
  (let ((depot (depot:ensure-entry "region" (depot +world+) :type :directory)))
    (depot:with-open (tx (depot:ensure-entry "init.lisp" depot) :output 'character)
      (princ* (encode-payload (region +world+) NIL depot 'save-v0) (depot:to-stream tx)))))

(defmethod edit ((action (eql 'load-game)) (editor editor))
  (load-state (file (state +main+)) T))

(defmethod edit ((action (eql 'load-game-as)) (editor editor))
  (let ((path (file-select:existing :title "Select Save File" :default (file (state +main+)) :filter '(("ZIP files" "zip")))))
    (when path
      (load-state path T))))

(defmethod edit ((action (eql 'save-game)) (editor editor))
  (save-state +main+ T))

(defmethod edit ((action (eql 'save-game-as)) (editor editor))
  (let ((path (file-select:new :title "Select Save File" :default (file (state +main+)))))
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
           (with-commit (editor "Delete ~a" (descriptor entity))
             ((leave entity container)
              (setf (entity editor) +world+))
             ((enter-and-load entity container +main+)
              (setf (entity editor) entity)))))))

(defmethod edit ((action (eql 'select-entity)) (editor editor))
  (make-instance 'selector :ui (unit 'ui-pass T)))

(defmethod edit ((action (eql 'insert-entity)) (editor editor))
  (make-instance 'creator :ui (unit 'ui-pass T)))

(defmethod edit ((action (eql 'clone-entity)) (editor editor))
  (let ((entity (entity editor)))
    (cond ((typep entity '(or player world region camera))
           (v:warn :kandria.editor "Refusing to clone.")
           (alloy:message (format NIL "Cannot clone the ~a" (type-of entity)) :title "Error" :ui (unit 'ui-pass T)))
          (T
           (let ((loc (vcopy (closest-acceptable-location entity (location (camera +world+))))))
             (edit (make-instance 'insert-entity :entity (clone entity :location loc)) editor))))))

(defmethod edit ((action (eql 'show-history)) (editor editor))
  (make-instance 'history-dialog :ui (unit 'ui-pass T) :history (history editor)))

(defmethod edit ((action (eql 'undo)) (editor editor))
  (undo editor T)
  (create-marker editor))

(defmethod edit ((action (eql 'redo)) (editor editor))
  (redo editor T)
  (create-marker editor))

(defmethod edit ((action (eql 'move)) (editor editor))
  (let* ((entity (if (and (typep (entity editor) 'located-entity)
                          (not (retained :control)))
                     (entity editor)
                     (unit 'player T)))
         (oloc (vcopy (location entity))))
    (with-commit (editor "Move ~a" (descriptor entity))
      ((setf (location entity) (mouse-world-pos (cursor-position *context*)))
       (setf (state (unit 'player T)) :normal))
      ((setf (location entity) oloc)))))

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
    (enter-and-load entity (region +world+) +main+)
    (when (typep entity 'chunk)
      (setf (show-solids entity) T))
    (with-commit (editor "Insert ~a" (descriptor entity))
      ((setf (entity editor) entity)
       (create-marker editor))
      ((leave entity T)
       (setf (entity editor) +world+)
       (create-marker editor)))))

(defmethod edit ((action (eql 'change-lighting)) (editor editor))
  (make-instance 'lighting :ui (unit 'ui-pass T)))

(defmethod edit ((action (eql 'toggle-lighting)) (editor editor))
  (let ((pass (unit 'lighting-pass T)))
    (setf (lighting pass)
          (if (eql (gi 'none) (lighting pass))
              (gi (chunk (camera +world+)))
              (gi 'none)))
    (force-lighting pass)))

(defmethod edit ((action (eql 'fit-into-view)) (editor editor))
  (with-vec (x- y- x+ y+) (nth-value 1 (bsize (region +world+)))
    (let ((w (- x+ x-))
          (h (- y+ y-))
          (c (camera +world+))
          (m (marker editor)))
      (setf (zoom c) (/ (min (/ (alloy:pxw m) w) (/ (alloy:pxh m) h)) (view-scale c)))
      (vsetf (location c)
             (+ x- (/ w 2) (/ (- (/ (- (width *context*) (alloy:pxw m)) 2) (alloy:pxx m)) (zoom c) (view-scale c)))
             (+ y- (/ h 2) (/ (- (/ (- (height *context*) (alloy:pxh m)) 2) (alloy:pxy m)) (zoom c) (view-scale c)))))))

(defmethod edit ((action (eql 'render-preview)) (editor editor))
  (let ((module (module +world+)))
    (cond (module
           (for:for ((entity over (region +world+)))
             (when (and (typep entity 'chunk)
                        (null (show-solids entity)))
               (setf (visibility entity) 0.0)))
           (render +main+ +main+)
           (with-tempfile (file :type "png")
             (capture (u 'render) :file file :target-width 512 :target-height 288)
             ;; Finally, copy the file into the module
             (setf (preview module) file))
           (alloy:message "The module preview has been updated." :title "Success" :ui (unit 'ui-pass T)))
          (T
           (alloy:message "This world isn't tied to any module!" :title "Error" :ui (unit 'ui-pass T))))))
