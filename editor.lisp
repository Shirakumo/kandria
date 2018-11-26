(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity entity-marker (vertex-entity)
  ((vertex-array :initform (asset 'leaf 'particle))
   (editor :initarg :editor :accessor editor)))

(defmethod paint ((marker entity-marker) (pass shader-pass))
  (let ((entity (entity (editor marker))))
    (when (typep entity 'sized-entity)
      (let ((program (shader-program-for-pass pass marker))
            (camera (unit :camera T)))
        (setf (uniform program "scale") (view-scale camera))
        (setf (uniform program "offset") (v- (location camera)
                                             (v/ (target-size camera) (zoom camera)))))
      (gl:blend-func :one-minus-dst-color :src-alpha)
      (with-pushed-matrix ()
        (translate (vxy_ (location entity)))
        (scale-by (* 2 (vx2 (bsize entity))) (* 2 (vy2 (bsize entity))) 1.0)
        (call-next-method))
      (gl:blend-func :src-alpha :one-minus-src-alpha))))

(define-class-shader (entity-marker :fragment-shader)
  "out vec4 color;
uniform vec2 offset = vec2(0);
uniform float scale = 1.0;

void main(){
  ivec2 grid = ivec2(floor((gl_FragCoord.xy+0.5)+offset*scale));
  float r = (floor(mod(grid.x, 8*scale))==0.0 || floor(mod(grid.y, 8*scale))==0)?1.0:0.0;
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
         (pause (handler *context*)))
        (T
         (change-class editor 'inactive-editor)
         (unpause (handler *context*)))))

(define-handler (inactive-editor toggle-editor) (ev)
  (setf (active-p inactive-editor) (not (active-p inactive-editor))))

(defmethod compute-resources :after ((editor inactive-editor) resources ready cache)
  (vector-push-extend (asset 'leaf 'square) resources)
  (vector-push-extend (asset 'leaf 'tile-picker) resources))

(defmethod register-object-for-pass :after (pass (editor inactive-editor))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'entity-marker)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'tile-picker)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'editor)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'chunk-editor))))

(define-shader-subject editor (inactive-editor)
  ((status :initform NIL :accessor status)))

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

(define-handler (editor mouse-press) (ev pos)
  (let ((loc (location editor))
        (camera (unit :camera T)))
    (vsetf loc (vx pos) (vy pos))
    (nv+ (nv/ loc (view-scale camera)) (location camera))
    (nv- loc (target-size camera))
    (unless (entity editor)
      (setf (entity editor) (entity-at-point loc +level+)))
    (when (retained 'modifiers :alt)
      (setf (status editor) :dragging))))

(define-handler (editor mouse-release) (ev)
  (setf (status editor) NIL))

(define-handler (editor mouse-move) (ev pos)
  (let ((loc (location editor))
        (entity (entity editor))
        (camera (unit :camera T)))
    (vsetf loc (vx pos) (vy pos))
    (nv+ (nv/ loc (view-scale camera)) (location camera))
    (nv- loc (target-size camera))
    (nvalign loc *default-tile-size*)
    (case (status editor)
      (:dragging
       (vsetf (location entity)
              (- (vx loc) (mod (vx (bsize entity)) *default-tile-size*))
              (- (vy loc) (mod (vy (bsize entity)) *default-tile-size*)))))))

(define-handler (editor mouse-scroll) (ev delta)
  (when (retained 'modifiers :control)
    (setf (zoom (unit :camera T)) (* (zoom (unit :camera T))
                                     (if (< 0 delta) 2.0 (/ 2.0))))))

(define-handler (editor select-entity) (ev)
  (setf (entity editor) NIL))

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

(define-handler (editor save-state) (ev)
  (save-state (handler *context*) T))

(define-handler (editor load-state) (ev)
  (load-state (handler *context*) T))

(define-handler (editor save-game) (ev)
  (if (retained 'modifiers :control)
      (save-level +level+ T)
      (with-query (file "Map save location"
                   :default (file +level+)
                   :parse #'uiop:parse-native-namestring)
        (setf (name +level+) (kw (pathname-name file)))
        (save-level +level+ (pool-path 'leaf file)))))

(define-handler (editor load-game) (ev)
  (if (retained 'modifiers :control)
      (let ((level (make-instance 'level :file (file +level+))))
        (change-scene (handler *context*) level))
      (with-query (file "Map load location"
                   :default (file +level+)
                   :parse #'uiop:parse-native-namestring)
        (let ((level (make-instance 'level :name (kw (pathname-name file)))))
          (load-level level file)
          (change-scene (handler *context*) level)))))

(define-handler (editor insert-entity) (ev)
  (let ((*package* #.*package*))
    (with-query (class "Class name"
                       :parse #'read-from-string)
      (let ((entity (make-instance class :location (vcopy (location editor)))))
        (transition entity +level+)
        (enter entity +level+)
        (setf (entity editor) entity)))))

(define-handler (editor delete-entity) (ev)
  (leave (entity editor) +level+)
  (setf (entity editor) NIL))

(define-handler (editor trial:tick) (ev)
  (let ((loc (location (unit :camera +level+))))
    (cond ((retained 'movement :left) (decf (vx loc) 1))
          ((retained 'movement :right) (incf (vx loc) 1)))
    (cond ((retained 'movement :down) (decf (vy loc) 1))
          ((retained 'movement :up) (incf (vy loc) 1)))))

(define-asset (leaf square) mesh
    (make-rectangle 8 8 :align :topleft))

(define-shader-subject chunk-editor (editor vertex-entity)
  ((tile :initform 1 :accessor tile-to-place)
   (level :initform 0 :accessor level)
   (vertex-array :initform (asset 'leaf 'square))
   (tile-picker :initform NIL :accessor tile-picker)))

(defmethod shared-initialize :after ((editor chunk-editor) slots &key)
  (setf (tile-picker editor) (make-instance 'tile-picker :editor editor)))

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

(define-handler (chunk-editor chunk-press mouse-press) (ev pos button)
  (let ((chunk (entity chunk-editor))
        (tile (case button
                (:left (tile-to-place chunk-editor))
                (:right 0)))
        (loc (vec3 (vx (location chunk-editor)) (vy (location chunk-editor)) (level chunk-editor)))
        (s (/ (width *context*) (* 64 *default-tile-size*))))
    (when tile
      (cond ((<= (vy pos) (* 4 *default-tile-size* s))
             (let ((i (+ (floor (/ (vx pos) s 8))
                         (* 64 (- 3 (floor (/ (vy pos) s 8)))))))
               (setf (tile-to-place chunk-editor) i)))
            ((retained 'modifiers :control)
             (flood-fill chunk loc tile))
            ((not (retained 'modifiers :alt))
             (setf (status chunk-editor) :placing)
             (setf (tile loc chunk) tile))))))

(define-handler (chunk-editor chunk-move mouse-move) (ev)
  (let ((loc (vec3 (vx (location chunk-editor)) (vy (location chunk-editor)) (level chunk-editor))))
    (case (status chunk-editor)
      (:placing
       (cond ((retained 'mouse :left)
              (setf (tile loc (entity chunk-editor)) (tile-to-place chunk-editor)))
             ((retained 'mouse :right)
               (setf (tile loc (entity chunk-editor)) 0)))))))

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
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (tileset chunk)))
    (setf (uniform program "tileset") 0)
    (setf (uniform program "tile") (vec2 (* (tile-size chunk) (tile-to-place editor))
                                         (* (tile-size chunk) (max 0 (1- (level editor))))))))

(defmethod paint :around ((editor chunk-editor) (target shader-pass))
  (with-pushed-matrix ()
    (call-next-method))
  (paint (tile-picker editor) target))

(define-class-shader (chunk-editor :vertex-shader)
  "
layout (location = 0) in vec3 position;
uniform vec2 tile;
out vec2 uv;

void main(){
  uv = position.xy + tile;
}")

(define-class-shader (chunk-editor :fragment-shader)
  "
uniform sampler2D tileset;
in vec2 uv;
out vec4 color;

void main(){
  color = texelFetch(tileset, ivec2(uv), 0);
}")

(define-asset (leaf tile-picker) mesh
    (make-rectangle (* 64 *default-tile-size*) (* 4 *default-tile-size*) :align :bottomleft))

(define-shader-entity tile-picker (vertex-entity textured-entity)
  ((vertex-array :initform (asset 'leaf 'tile-picker))
   (texture :initform NIL)
   (editor :initarg :editor :accessor editor))
  (:inhibit-shaders (textured-entity :fragment-shader)))

(defmethod paint :around ((picker tile-picker) target)
  (with-pushed-matrix ((*model-matrix* :identity)
                       (*view-matrix* :identity))
    (let ((editor (editor picker)))
      (setf (texture picker)
            (if (= 0 (level editor))
                (surface (entity editor))
                (tileset (entity editor)))))
    (let ((s (/ (width *context*) (* 64 *default-tile-size*))))
      (translate-by 0 (* 4 *default-tile-size* s) 4)
      (scale-by s s 1))
    (call-next-method)))

(defmethod paint :before ((picker tile-picker) (pass shader-pass))
  (let ((program (shader-program-for-pass pass picker)))
    (setf (uniform program "level") (max 0 (1- (level (editor picker)))))))

(define-class-shader (tile-picker :fragment-shader)
  "in vec2 texcoord;
out vec4 color;
uniform sampler2D texture_image;
uniform int level = 0;

void main(){
  vec2 tile = texcoord * vec2(64, 4);
  vec2 tile_uv = mod(tile, 1);
  tile.y = 4-tile.y;
  tile = floor(tile);
  ivec2 uv = ivec2(floor(8.0*(tile_uv+vec2(tile.x+tile.y*64.0, level))));

  vec4 texel = texelFetch(texture_image, uv, 0);
  color.rgb = vec3((mod(floor((texcoord.x*64+texcoord.y*4)*2), 2.0) <= 0.0)? 0.1 : 0.2);
  color.a = 1.0;
  color = mix(color, texel, texel.a);
}")
