(in-package #:org.shirakumo.fraf.leaf)

(define-subject base-editor (located-entity alloy:observable-object)
  ((flare:name :initform :editor)
   (alloy:target-resolution :initform (alloy:size 1280 720))
   (entity :initform NIL :accessor entity)
   (ui :initform (make-instance 'ui) :accessor ui)))

(defmethod compute-resources :after ((editor base-editor) resources readying traversal)
  (vector-push-extend (ui editor) resources))

(defmethod initialize-instance :after ((editor base-editor) &key)
  (let* ((ui (ui editor))
         (focus (make-instance 'alloy:focus-list :focus-parent (alloy:focus-tree ui)))
         (layout (make-instance 'alloy:border-layout :layout-parent (alloy:layout-tree ui)))
         (menu (make-instance 'editmenu))
         (entity (make-instance 'entity-widget :side :west)))
    (alloy:observe 'entity editor (lambda (value object) (setf (entity entity) value)))
    (alloy:enter menu layout :place :north)
    (alloy:enter menu focus)
    (alloy:enter entity layout :place :west :size (alloy:un 200))
    (alloy:enter entity focus)
    (alloy:register ui ui)))

(defmethod register-object-for-pass :after ((pass per-object-pass) (editor base-editor))
  (register-object-for-pass pass (maybe-finalize-inheritance 'editor))
  (register-object-for-pass pass (maybe-finalize-inheritance 'chunk-editor)))

(define-handler (base-editor toggle-editor) (ev)
  (setf (active-p base-editor) (not (active-p base-editor))))

(defmethod (setf active-p) (value (editor base-editor))
  (with-buffer-tx (light (asset 'leaf 'light-info))
    (setf (active-p light) (if value 0 1)))
  (cond (value
         (pause-game T editor)
         (handle (make-instance 'resize :width (width *context*) :height (height *context*))
                 (ui editor))
         (change-class editor (editor-class (entity editor))))
        (T
         (change-class editor 'inactive-editor)
         (unpause-game T editor))))

(defmethod editor-class (thing) 'editor)

(define-subject inactive-editor (base-editor)
  ())

(defmethod active-p ((editor inactive-editor)) NIL)

(define-subject editor (base-editor)
  ((state :initform NIL :accessor state)
   (start-pos :initform (vec 0 0) :accessor start-pos)
   (sidebar :initform NIL :accessor sidebar)))

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
    (call-next-method)))

(defmethod paint :after ((editor editor) (target rendering-pass))
  (paint (ui editor) target))

;; FIXME: Autosaves in lieu of undo

(defun update-editor-pos (editor pos)
  (let ((loc (location editor))
        (camera (unit :camera T)))
    (vsetf loc (vx pos) (vy pos))
    (nv+ (nv/ loc (view-scale camera)) (location camera))
    (nv- loc (v/ (target-size camera) (zoom camera)))))

(define-handler (editor mouse-press) (ev pos button)
  (update-editor-pos editor pos)
  (let ((loc (location editor)))
    (unless (entity editor)
      (setf (entity editor) (entity-at-point loc +world+)))))

(define-handler (editor mouse-release) (ev)
  (setf (state editor) NIL))

(define-handler (editor mouse-move) (ev pos)
  (let ((loc (location editor))
        (old (start-pos editor))
        (entity (entity editor)))
    (update-editor-pos editor pos)
    (case (state editor)
      (:dragging
       ;; FIXME: for chunks (and other containers) we should also move
       ;;        contained units by the same delta.
       (vsetf (location entity)
              (- (vx loc) (vx old))
              (- (vy loc) (vy old)))
       (nvalign (location entity) (/ +tile-size+ 2))
       (setf (location entity) (location entity)))
      (:resizing
       (let ((size (nvalign (v- loc (location entity)) (/ +tile-size+ 2))))
         (resize editor (vx size) (vy size)))))))

(defmethod resize ((editor editor) w h)
  (resize (entity editor) w h))

(define-handler (editor mouse-scroll) (ev delta)
  (when (retained 'modifiers :control)
    (setf (zoom (unit :camera T)) (* (zoom (unit :camera T))
                                     (if (< 0 delta) 2.0 (/ 2.0))))))

(define-handler (editor select-entity) (ev)
  (setf (entity editor) NIL))

(define-handler (editor next-entity) (ev)
  (let* ((set (objects +world+))
         (pos (or (flare-indexed-set:set-index-of (entity editor) set) -1)))
    (setf (entity editor) (flare-indexed-set:set-value-at
                           (mod (1+ pos) (flare-indexed-set:set-size set))
                           set))))

(define-handler (editor prev-entity) (ev)
  (let* ((set (objects +world+))
         (pos (or (flare-indexed-set:set-index-of (entity editor) set) +1)))
    (setf (entity editor) (flare-indexed-set:set-value-at
                           (mod (1- pos) (flare-indexed-set:set-size set))
                           set))))

(define-handler (editor load-world) (ev)
  (if (retained 'modifiers :control)
      (let ((world (load-world +world+)))
        (change-scene (handler *context*) world))
      (with-query (file "World load location"
                        :default (storage (packet +world+))
                        :parse #'uiop:parse-native-namestring)
        (let ((world (load-world (pool-path 'leaf file))))
          (change-scene (handler *context*) world)))))

(define-handler (editor save-region) (ev)
  (save-region T T))

(define-handler (editor load-region) (ev)
  (let ((old (unit 'region +world+)))
    (cond ((retained 'modifiers :control)
           (transition old (load-region T T)))
          (T
           (with-query (region "Region name")
             (transition old (load-region region T)))))))

(define-handler (editor save-game) (ev)
  (save-state T T))

(define-handler (editor load-game) (ev)
  (let ((old (unit 'region +world+)))
    (flet ((load! (state)
             (load-state state T)
             (transition old (unit 'region +world+))))
      (cond ((retained 'modifiers :control) (load! T))
            (T (with-query (region "State name")
                 (load! region)))))))

(define-handler (editor insert-entity) (ev)
  )

(define-handler (editor delete-entity) (ev)
  (leave (entity editor) (unit 'region +world+))
  (setf (entity editor) NIL))

(define-handler (editor move-entity) (ev)
  (setf (state editor) :dragging)
  (setf (start-pos editor) (v- (location editor)
                               (vxy (location (entity editor))))))

(define-handler (editor resize-entity) (ev)
  (setf (state editor) :resizing)
  (setf (start-pos editor) (location (entity editor))))

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

(define-asset (leaf square) mesh
    (make-rectangle +tile-size+ +tile-size+ :align :bottomleft))

(define-subject movable-editor (editor)
  ())

(defmethod editor-class ((_ movable)) 'movable-editor)

(define-handler (movable-editor move-to mouse-press -1) (ev button)
  (case button
    (:right
     (move-to (location movable-editor) (entity movable-editor)))))

(define-subject chunk-editor (editor)
  ((tile :initform (vec2 1 0) :accessor tile-to-place)
   (layer :initform +3 :accessor layer)))

(defmethod shared-initialize :after ((editor chunk-editor) slots &key)
  (setf (tile-to-place editor) (vec2 1 0)))

(defmethod update-instance-for-different-class :after (previous (editor chunk-editor) &key)
  (setf (sidebar editor) (make-instance 'chunk-widget :entity (entity editor) :side :east)))

(defmethod (setf entity) :before (new (editor chunk-editor))
  (setf (target-layer (entity editor)) NIL))

(defmethod editor-class ((_ chunk)) 'chunk-editor)

(defmethod (setf tile-to-place) (value (chunk-editor chunk-editor))
  (let ((width (floor (width (tileset (entity chunk-editor))) +tile-size+))
        (height (floor (height (tileset (entity chunk-editor))) +tile-size+)))
    (setf (vx value) (clamp 0 (vx value) (1- width)))
    (if (= +3 (layer chunk-editor))
        (setf (vy value) 0)
        (setf (vy value) (clamp 0 (vy value) (1- height))))
    (setf (slot-value chunk-editor 'tile) value)))

(defmethod resize ((editor chunk-editor) w h)
  (let* ((entity (entity editor))
         (old (v- (start-pos editor) (bsize entity)))
         (size (vmax (v- (location editor) old) (vec +tile-size+ +tile-size+))))
    (resize entity (vx size) (vy size))
    (let ((loc (v+ old (bsize entity))))
      (vsetf (location entity) (vx loc) (vy loc)))))

(define-handler (chunk-editor key-press) (ev key)
  (when (case key
          (:1 (setf (layer chunk-editor) -2))
          (:2 (setf (layer chunk-editor) -1))
          (:3 (setf (layer chunk-editor)  0))
          (:4 (setf (layer chunk-editor) +1))
          (:5 (setf (layer chunk-editor) +2))
          (:0 (setf (layer chunk-editor) +3)))
    (v:info :leaf.editor "Switched layer to ~d" (layer chunk-editor)))
  (setf (tile-to-place chunk-editor) (tile-to-place chunk-editor)))

(define-handler (chunk-editor chunk-press mouse-press) (ev pos button)
  (unless (eql button :middle)
    (let* ((chunk (entity chunk-editor))
           (tile (case button
                   (:left (tile-to-place (sidebar chunk-editor)))
                   (:right (vec2 0 0))))
           (loc (vec3 (vx (location chunk-editor)) (vy (location chunk-editor))
                      (layer (sidebar chunk-editor)))))
      (cond ((retained 'modifiers :control)
             (if (= (layer chunk-editor) 0)
                 (auto-tile chunk loc)
                 (flood-fill chunk loc tile)))
            ((retained 'modifiers :alt)
             (setf (tile-to-place (sidebar chunk-editor)) (tile loc chunk)))
            (T
             (setf (state chunk-editor) :placing)
             (setf (tile loc chunk) tile))))))

(define-handler (chunk-editor chunk-move mouse-move) (ev)
  (let ((loc (vec3 (vx (location chunk-editor)) (vy (location chunk-editor)) (layer chunk-editor))))
    (case (state chunk-editor)
      (:placing
       (cond ((retained 'mouse :left)
              (setf (tile loc (entity chunk-editor)) (tile-to-place chunk-editor)))
             ((retained 'mouse :right)
              (setf (tile loc (entity chunk-editor)) (vec2 0 0))))))))

(define-handler (chunk-editor change-tile mouse-scroll) (ev delta)
  (unless (retained 'modifiers :control)
    (let* ((width (floor (width (tileset (entity chunk-editor))) +tile-size+))
           (i (+ (vx (tile-to-place chunk-editor))
                 (* (vy (tile-to-place chunk-editor))
                    width))))
      (cond ((< 0 delta) (incf i))
            ((< delta 0) (decf i)))
      (setf (tile-to-place chunk-editor)
            (vec2 (mod i width) (floor i width))))))
