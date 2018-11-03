(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject inactive-editor (located-entity)
  ((flare:name :initform :editor)
   (entity :initform NIL :accessor entity)))

(defmethod editor-class (thing) 'editor)

(defmethod active-p ((editor inactive-editor)) NIL)
(defmethod (setf active-p) (value (editor inactive-editor))
  (cond (value
         (change-class editor (editor-class (entity editor)))
         (remove-handler (handlers (unit :player T)) +level+))
        (T
         (change-class editor 'inactive-editor)
         (add-handler (handlers (unit :player T)) +level+))))

(define-handler (inactive-editor toggle-editor) (ev)
  (setf (active-p inactive-editor) (not (active-p inactive-editor))))

(defmethod compute-resources :after ((editor inactive-editor) resources ready cache)
  (vector-push-extend (asset 'leaf 'square) resources))

(defmethod register-object-for-pass :after (pass (editor inactive-editor))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'editor)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'moving-editor)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'layer-editor))))

(define-shader-subject editor (inactive-editor)
  ())

(defmethod active-p ((editor editor)) T)

(defmethod banned-slots append ((editor editor))
  '(entity))

(defmethod (setf entity) :after (value (editor editor))
  (change-class editor (editor-class value))
  (v:info :leaf.editor "Switched entity to ~a (~a)" value (type-of editor)))

(defmethod enter :after ((editor editor) (scene scene))
  (setf (entity editor) (unit :surface scene)))

;; FIXME: Autosaves in lieu of undo

(define-handler (editor insert-entity) (ev)
  ;; FIXME
  )

(define-handler (editor delete-entity) (ev)
  (leave (entity editor) +level+)
  (setf (entity editor) NIL))

(define-handler (editor standard-entity) (ev)
  (setf (entity editor) (unit :surface scene)))

(define-handler (editor mouse-move-pos mouse-move) (ev pos)
  (let ((loc (location editor))
        (camera (unit :camera T)))
    (vsetf loc
           (+ (/ (vx pos) (view-scale camera)) (vx (location camera)))
           (+ (/ (vy pos) (view-scale camera)) (vy (location camera))))
    (let ((t-s *default-tile-size*))
      (setf (vx loc) (* t-s (floor (vx loc) t-s)))
      (setf (vy loc) (* t-s (floor (vy loc) t-s))))))

(define-handler (editor mouse-scroll) (ev delta)
  (when (retained 'modifiers :control)
    (setf (zoom (unit :camera T)) (* (zoom (unit :camera T))
                                     (if (< 0 delta) 2.0 (/ 2.0))))))

(define-handler (editor next-entity) (ev)
  (let* ((set (objects +level+))
         (pos (or (flare-indexed-set:set-index-of (entity editor) set) -1)))
    (setf (entity editor) (flare-indexed-set:set-value-at
                           (mod (1+ pos) (flare-indexed-set:set-size set))
                           set))))

(define-handler (editor prev-entity) (ev)
  (let* ((set (objects +level+))
         (pos (or (flare-indexed-set:set-index-of (entity editor) set) +1)))
    (setf (entity editor) (flare-indexed-set:set-value-at
                           (mod (1- pos) (flare-indexed-set:set-size set))
                           set))))

(define-handler (editor save-game) (ev)
  (if (retained 'modifiers :control)
      (save-level +level+ T)
      (with-query (file "Map save location"
                   :default (file +level+)
                   :parse #'uiop:parse-native-namestring)
        (setf (file +level+) (pool-path 'leaf file))
        (save-level +level+ T))))

(define-handler (editor load-game) (ev)
  (if (retained 'modifiers :control)
      (let ((level (make-instance 'level :file (file +level+))))
        (change-scene (handler *context*) level))
      (with-query (file "Map load location"
                   :default (file +level+)
                   :parse #'uiop:parse-native-namestring)
        (let ((level (make-instance 'level :file (pool-path 'leaf file))))
          (change-scene (handler *context*) level)))))

(define-handler (editor trial:tick) (ev)
  (let ((loc (location (unit :camera +level+))))
    (cond ((retained 'movement :left) (decf (vx loc) 1))
          ((retained 'movement :right) (incf (vx loc) 1)))
    (cond ((retained 'movement :down) (decf (vy loc) 1))
          ((retained 'movement :up) (incf (vy loc) 1)))))

(defmethod paint :around ((editor editor) target)
  (when (active-p editor)
    (call-next-method)))

(define-shader-subject moving-editor (editor)
  ((dragging :initform NIL :accessor dragging)))

(defmethod editor-class ((moving moving)) 'moving-editor)

(define-handler (moving-editor mouse-press) (ev)
  (let ((hit (for:for ((result as NIL)
                       (entity over +level+))
               (when (and (typep entity 'located-entity)
                          (contained-p (location moving-editor) entity)
                          (or (null result)
                              (< (vlength (bsize entity))
                                 (vlength (bsize result)))))
                 (setf result entity)))))
    (cond ((not hit))
          ((eq hit (entity moving-editor))
           (setf (dragging moving-editor) T))
          (T
           (setf (entity moving-editor) hit)))))

(define-handler (moving-editor mouse-release) (ev)
  (setf (dragging moving-editor) NIL))

(define-handler (moving-editor mouse-move) (ev)
  (when (dragging moving-editor)
    (vsetf (location (entity moving-editor))
           (vx (location moving-editor))
           (vy (location moving-editor)))))

(define-shader-subject layer-editor (editor vertex-entity)
  ((tile :initform 1 :accessor tile-to-place)
   (vertex-array :initform (asset 'leaf 'square))))

(defmethod editor-class ((layer layer)) 'layer-editor)

(define-handler (layer-editor resize-layer) (ev)
  (with-query (size "New layer size" :parse #'read-from-string)
    (setf (size (entity editor)) size)))

(define-handler (layer-editor change-tile mouse-scroll) (ev delta)
  (unless (retained 'modifiers :control)
    (cond ((< 0 delta)
           (incf (tile-to-place layer-editor)))
          ((< delta 0)
           (decf (tile-to-place layer-editor))))
    (setf (tile-to-place layer-editor)
          (max 0 (min 255 (tile-to-place layer-editor))))))

(define-handler (layer-editor mouse-press) (ev button)
  (let ((layer (entity layer-editor))
        (tile (case button
                (:left (tile-to-place layer-editor))
                (:right 0))))
    (when tile
      (if (retained 'modifiers :control)
          (flood-fill layer (location layer-editor) tile)
          (setf (tile (location layer-editor) layer) tile)))))

(define-handler (layer-editor mouse-move) (ev)
  (let ((loc (location layer-editor)))
    (when (retained 'mouse :left)
      (setf (tile loc (entity layer-editor)) (tile-to-place layer-editor)))
    (when (retained 'mouse :right)
      (setf (tile loc (entity layer-editor)) 0))))

(defmethod paint :before ((editor layer-editor) (pass shader-pass))
  (let ((program (shader-program-for-pass pass editor))
        (layer (entity editor)))
    (gl:bind-texture :texture-2d (gl-name (texture layer)))
    (multiple-value-bind (y x) (floor (* (tile-size layer) (tile-to-place editor)) (width (texture layer)))
      (setf (uniform program "tile") (vec2 x (* (tile-size layer) y))))))

(define-class-shader (layer-editor :vertex-shader)
  "
layout (location = 0) in vec3 vertex;
uniform vec2 tile;
out vec2 uv;

void main(){
  uv = vertex.xy + tile;
}")

(define-class-shader (layer-editor :fragment-shader)
  "
uniform sampler2D tileset;
in vec2 uv;
out vec4 color;

void main(){
  color = texelFetch(tileset, ivec2(uv), 0);
}")
