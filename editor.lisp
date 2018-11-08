(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject entity-marker (vertex-entity)
  ((vertex-array :initform (asset 'leaf 'particle))
   (editor :initarg :editor :accessor editor)))

(defmethod paint ((marker entity-marker) (pass shader-pass))
  (let ((entity (entity (editor marker))))
    (when (typep entity '(or game-entity chunk))
      (let ((program (shader-program-for-pass pass marker))
            (camera (unit :camera T)))
        (setf (uniform program "scale") (view-scale camera))
        (setf (uniform program "offset") (location camera)))
      (gl:blend-func :one-minus-dst-color :src-alpha)
      (with-pushed-matrix ()
        (translate (vxy_ (location entity)))
        (scale-by (* 2 (vx (bsize entity))) (* 2 (vy (bsize entity))) 1.0)
        (call-next-method))
      (gl:blend-func :src-alpha :one-minus-src-alpha))))

(define-class-shader (entity-marker :fragment-shader)
  "out vec4 color;
uniform vec2 offset = vec2(0);
uniform float scale = 1.0;

void main(){
    ivec2 grid = ivec2(floor((gl_FragCoord.xy+0.5)/scale+offset));
    float r = (grid.x%8==0 || grid.y%8==0)?1.0:0.0;
    color = vec4(r,r,r,1-r);
}")

(define-shader-subject inactive-editor (located-entity)
  ((flare:name :initform :editor)
   (entity :initform NIL :accessor entity)
   (marker :accessor entity-marker)))

(defmethod initialize-instance :after ((editor inactive-editor) &key)
  (setf (entity-marker editor) (make-instance 'entity-marker :editor editor)))

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
  (register-object-for-pass pass (entity-marker editor))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'editor)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'moving-editor)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'chunk-editor))))

(define-shader-subject editor (inactive-editor)
  ())

(defmethod active-p ((editor editor)) T)

(defmethod banned-slots append ((editor editor))
  '(entity))

(defmethod (setf entity) :after (value (editor editor))
  (change-class editor (editor-class value))
  (v:info :leaf.editor "Switched entity to ~a (~a)" value (type-of editor)))

(defmethod paint :around ((editor editor) target)
  (call-next-method)
  (paint (entity-marker editor) target))

;; FIXME: Autosaves in lieu of undo

(define-handler (editor insert-entity) (ev)
  ;; FIXME
  )

(define-handler (editor delete-entity) (ev)
  (leave (entity editor) +level+)
  (setf (entity editor) NIL))

(define-handler (editor standard-entity) (ev)
  (setf (entity editor) (unit :surface scene)))

(define-handler (editor mouse-press) (ev)
  (setf (entity editor) (entity-at-point (location editor) +level+)))

(define-handler (editor mouse-move-pos mouse-move) (ev pos)
  (let ((loc (location editor))
        (camera (unit :camera T)))
    (vsetf loc (vx pos) (vy pos))
    (nv+ (nv/ loc (view-scale camera)) (location camera))
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

(define-shader-subject moving-editor (editor)
  ((dragging :initform NIL :accessor dragging)))

(defmethod editor-class ((moving moving)) 'moving-editor)

(define-handler (moving-editor mouse-press) (ev)
  (let ((hit (entity-at-point (location moving-editor) +level+)))
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

(define-shader-subject chunk-editor (editor vertex-entity)
  ((tile :initform 1 :accessor tile-to-place)
   (level :initform 0 :accessor level)
   (vertex-array :initform (asset 'leaf 'square))))

(defmethod editor-class ((chunk chunk)) 'chunk-editor)

(define-handler (chunk-editor resize-chunk) (ev)
  (with-query (size "New chunk size" :parse #'read-from-string)
    (setf (size (entity chunk-editor)) size)))

(define-handler (chunk-editor key-press) (ev key)
  (case key
    (:1 (setf (level chunk-editor) 0))
    (:2 (setf (level chunk-editor) 1))
    (:3 (setf (level chunk-editor) 2))
    (:4 (setf (level chunk-editor) 3))))

(define-handler (chunk-editor mouse-press) (ev button)
  (let ((chunk (entity chunk-editor))
        (tile (case button
                (:left (tile-to-place chunk-editor))
                (:right 0)))
        (loc (vec3 (vx (location chunk-editor)) (vy (location chunk-editor)) (level chunk-editor))))
    (when tile
      (if (retained 'modifiers :control)
          (flood-fill chunk loc tile)
          (setf (tile loc chunk) tile)))))

(define-handler (chunk-editor mouse-move) (ev)
  (let ((loc (vec3 (vx (location chunk-editor)) (vy (location chunk-editor)) (level chunk-editor))))
    (when (retained 'mouse :left)
      (setf (tile loc (entity chunk-editor)) (tile-to-place chunk-editor)))
    (when (retained 'mouse :right)
      (setf (tile loc (entity chunk-editor)) 0))))

(define-handler (chunk-editor change-tile mouse-scroll) (ev delta)
  (unless (retained 'modifiers :control)
    (cond ((< 0 delta)
           (incf (tile-to-place chunk-editor)))
          ((< delta 0)
           (decf (tile-to-place chunk-editor))))
    (setf (tile-to-place chunk-editor)
          (max 0 (min 255 (tile-to-place chunk-editor))))))

(defmethod paint :before ((editor chunk-editor) (pass shader-pass))
  (let ((program (shader-program-for-pass pass editor))
        (chunk (entity editor)))
    (gl:bind-texture :texture-2d (gl-name (texture chunk)))
    (setf (uniform program "tile") (vec2 (* (tile-size chunk) (tile-to-place editor))
                                         (ecase (level editor)
                                           (0     (* 2 (tile-size chunk)))
                                           ((1 3) (* 1 (tile-size chunk)))
                                           (2     (* 0 (tile-size chunk))))))))

(define-class-shader (chunk-editor :vertex-shader)
  "
layout (location = 0) in vec3 vertex;
uniform vec2 tile;
out vec2 uv;

void main(){
  uv = vertex.xy + tile;
}")

(define-class-shader (chunk-editor :fragment-shader)
  "
uniform sampler2D tileset;
in vec2 uv;
out vec4 color;

void main(){
  color = texelFetch(tileset, ivec2(uv), 0);
}")

