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
                                             (v/ (target-size camera) (zoom camera))))
        (setf (uniform program "tile_size") +tile-size+))
      (with-pushed-matrix ()
        (translate (vxy_ (location entity)))
        (scale-by (* 2 (vx2 (bsize entity))) (* 2 (vy2 (bsize entity))) 1.0)
        (call-next-method)))))

(define-class-shader (entity-marker :fragment-shader)
  "out vec4 color;
uniform vec2 offset = vec2(0);
uniform float scale = 1.0;
uniform int tile_size = 16;

void main(){
  ivec2 grid = ivec2(floor((gl_FragCoord.xy)+offset*scale));
  float r = (floor(mod(grid.x, tile_size*scale))==0.0 || floor(mod(grid.y, tile_size*scale))==0)?1.0:0.0;
  color = vec4(1,1,1,r*0.2);
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
         (pause-game T editor)
         (change-class editor (editor-class (entity editor))))
        (T
         (change-class editor 'inactive-editor)
         (unpause-game T editor))))

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
  ((state :initform NIL :accessor state)
   (start-pos :initform (vec 0 0) :accessor start-pos)))

(defmethod active-p ((editor editor)) T)

(defmethod banned-slots append ((editor editor))
  '(entity))

(defmethod (setf entity) :after (value (editor editor))
  (change-class editor (editor-class value))
  (v:info :leaf.editor "Switched entity to ~a (~a)" value (type-of editor)))

(defmethod paint :around ((editor editor) target)
  (call-next-method)
  (paint (entity-marker editor) target))

(defmethod handle :before (event (editor editor))
  (handle event (controller (handler *context*)))
  (handle event (unit :camera +world+)))

;; FIXME: Autosaves in lieu of undo

(defun update-editor-pos (editor pos)
  (let ((loc (location editor))
        (camera (unit :camera T)))
    (vsetf loc (vx pos) (vy pos))
    (nv+ (nv/ loc (view-scale camera)) (location camera))
    (nv- loc (v/ (target-size camera) (zoom camera)))
    (nvalign loc +tile-size+)))

(define-handler (editor mouse-press) (ev pos button)
  (let* ((camera (unit :camera T))
         ;; Calculate here to avoid nvalign of update-editor-pos
         (wpos (nv- (nv+ (v/ pos (view-scale camera)) (location camera))
                    (v/ (target-size camera) (zoom camera)))))
    (update-editor-pos editor pos)
    (unless (entity editor)
      (setf (entity editor) (entity-at-point wpos +world+)))
    (when (eql :middle button)
      (setf (start-pos editor) pos)
      (setf (state editor) :dragging))))

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
              (+ (vx loc) (floor (vx (size entity)) 2))
              (+ (vy loc) (floor (vy (size entity)) 2))))
      (:resizing
       (let ((size (vmax (v- loc old) (vec +tile-size+ +tile-size+))))
         (resize entity (vx size) (vy size))
         (let ((loc (v+ old (bsize entity))))
           (vsetf (location entity) (vx loc) (vy loc))))))))

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
  (let ((*package* #.*package*))
    (query-instance
     (lambda (entity)
       (transition entity +world+)
       (enter entity +world+)
       (setf (entity editor) entity)
       (setf (start-pos editor) (vcopy (location editor)))
       (setf (state editor) :dragging))
     (list :location (vcopy (location editor))))))

(define-handler (editor delete-entity) (ev)
  (leave (entity editor) +world+)
  (setf (entity editor) NIL))

(define-handler (editor resize-entity) (ev)
  (setf (state editor) :resizing)
  (setf (start-pos editor) (v- (location (entity editor))
                               (bsize (entity editor)))))

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

(define-shader-subject movable-editor (editor)
  ())

(defmethod editor-class ((_ movable)) 'movable-editor)

(define-handler (movable-editor move-to mouse-press -1) (ev button)
  (case button
    (:right
     (move-to (location movable-editor) (entity movable-editor)))))

(define-shader-subject sprite-editor (editor)
  ())

(defmethod editor-class ((_ sprite-entity)) 'sprite-editor)

(define-handler (sprite-editor change-tile mouse-scroll) (ev delta)
  (unless (retained 'modifiers :control)
    (let* ((entity (entity sprite-editor))
           (tile (trial:tile entity))
           (w (/ (width (texture entity)) (vx (size entity))))
           (h (/ (height (texture entity)) (vy (size entity))))
           (idx (+ (vx tile) (* w (vy tile)))))
      (setf idx (mod (cond ((< 0 delta) (1+ idx))
                           ((< delta 0) (1- idx))
                           (T idx))
                     (* w h)))
      (setf (vx tile) (mod idx w))
      (setf (vy tile) (floor idx w)))))

(define-shader-subject chunk-editor (editor vertex-entity)
  ((tile :initform (vec2 1 0) :accessor tile-to-place)
   (layer :initform +3 :accessor layer)
   (vertex-array :initform (asset 'leaf 'square))
   (tile-picker :initform NIL :accessor tile-picker)))

(defmethod shared-initialize :after ((editor chunk-editor) slots &key)
  (setf (tile-picker editor) (make-instance 'tile-picker :editor editor))
  (setf (tile-to-place editor) (vec2 1 0)))

(defmethod editor-class ((_ chunk)) 'chunk-editor)

(defmethod (setf tile-to-place) (value (chunk-editor chunk-editor))
  (let ((width (floor (width (tileset (entity chunk-editor))) +tile-size+))
        (height (floor (height (tileset (entity chunk-editor))) +tile-size+)))
    (setf (vx value) (clamp 0 (vx value) (1- width)))
    (if (= +3 (layer chunk-editor))
        (setf (vy value) 0)
        (setf (vy value) (clamp 0 (vy value) (1- height))))
    (setf (slot-value chunk-editor 'tile) value)))

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
                   (:left (tile-to-place chunk-editor))
                   (:right (vec2 0 0))))
           (loc (vec3 (vx (location chunk-editor)) (vy (location chunk-editor)) (layer chunk-editor))))
      (cond ((and (<= (vx pos) (width (tileset chunk)))
                  (<= (vy pos) (height (tileset chunk))))
             (setf (tile-to-place chunk-editor)
                   (vfloor pos +tile-size+)))
            ((retained 'modifiers :control)
             ;;(flood-fill chunk loc tile)
             (auto-tile chunk loc))
            ((retained 'modifiers :alt)
             (setf (tile-to-place chunk-editor) (tile loc chunk)))
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

(define-handler ((editor chunk-editor) insert-entity) (ev)
  (let ((*package* #.*package*))
    (query-instance
     (lambda (entity)
       (transition entity +world+)
       (enter entity (entity editor))
       (setf (entity editor) entity)
       (setf (start-pos editor) (vcopy (location editor)))
       (setf (state editor) :dragging))
     (list :location (vcopy (location editor))))))

(defmethod paint :before ((editor chunk-editor) (pass shader-pass))
  (let ((program (shader-program-for-pass pass editor))
        (chunk (entity editor)))
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (tileset chunk)))
    (setf (uniform program "tileset") 0)
    (setf (uniform program "tile_size") +tile-size+)
    (setf (uniform program "tile") (tile-to-place editor))))

(defmethod paint :around ((editor chunk-editor) (target shader-pass))
  (let ((*current-layer* +layer-count+))
    (paint-with target (entity editor))
    (with-pushed-matrix (model-matrix)
      (translate-by 8 8 0)
      (paint (node-graph (entity editor)) target)))
  (with-pushed-matrix ()
    (call-next-method))
  (paint (tile-picker editor) target))

(define-class-shader (chunk-editor :vertex-shader)
  "
layout (location = 1) in vec2 vertex_uv;
uniform int tile_size;
uniform vec2 tile;
out vec2 uv;

void main(){
  uv = (vertex_uv + tile)*tile_size;
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
    (make-rectangle 1 1 :align :bottomleft :z 10))

(define-shader-entity tile-picker (vertex-entity textured-entity)
  ((vertex-array :initform (asset 'leaf 'tile-picker))
   (texture :initform NIL)
   (editor :initarg :editor :accessor editor))
  (:inhibit-shaders (textured-entity :fragment-shader)))

(defmethod paint :around ((picker tile-picker) target)
  (with-pushed-matrix ((*model-matrix* :identity)
                       (*view-matrix* :identity))
    (let* ((tileset (tileset (entity (editor picker)))))
      (setf (texture picker) tileset)
      (translate-by 0 0 4)
      (scale-by (width tileset) (height tileset) 1))
    (call-next-method)))

(define-class-shader (tile-picker :fragment-shader)
  "in vec2 texcoord;
out vec4 color;
uniform sampler2D texture_image;

void main(){
  vec4 texel = texture(texture_image, texcoord);
  ivec2 real = ivec2(texcoord * vec2(32, 32));
  color.rgb = vec3((mod(real.x,2)+mod(real.y, 2) == 1)? 0.1 : 0.2);
  color = mix(color, texel, texel.a);
  color.a = 1.0;
}")

(define-shader-subject text-input ()
  ((vertex-array :initform (asset 'trial 'trial::fullscreen-square) :accessor vertex-array)
   (title :initform (make-instance 'text :color (vec 1 1 1 1) :font (asset 'trial 'trial::noto-mono) :size 20 :width 800 :wrap T) :accessor title)
   (label :initform (make-instance 'text :color (vec 1 1 1 1) :font (asset 'trial 'trial::noto-mono) :size 32) :accessor label)
   (callback :initarg :callback :accessor callback)))

(defmethod initialize-instance :after ((text-input text-input) &key title default)
  (setf (text (label text-input)) (or default ""))
  (setf (text (title text-input)) (or title "")))

(defmethod register-object-for-pass :after (pass (text-input text-input))
  (register-object-for-pass pass (label text-input)))

(defmethod enter :after ((input text-input) (world world))
  (pause-game world input))

(defmethod leave :before ((input text-input) (world world))
  (unpause-game world input))

(define-handler (text-input key-press) (ev key)
  (case key
    ((:enter :return)
     (leave text-input +world+)
     (funcall (callback text-input) (text (label text-input))))
    ((:esc :escape)
     (leave text-input +world+))
    ((:backspace)
     (let ((label (label text-input)))
       (when (< 0 (length (text label)))
         (setf (text label) (subseq (text label) 0 (1- (length (text label))))))))))

(define-handler (text-input text-entered) (ev text)
  (let ((label (label text-input)))
    (setf (text label) (concatenate 'string (text label) text))))

(defmethod paint ((text-input text-input) target)
  (let ((vao (vertex-array text-input)))
    (with-pushed-attribs
      (disable :depth-test)
      (gl:bind-vertex-array (gl-name vao))
      (%gl:draw-elements :triangles (size vao) :unsigned-int (cffi:null-pointer))
      (gl:bind-vertex-array 0)))
  (with-pushed-matrix ((view-matrix :identity)
                       (model-matrix :identity))
    (let ((label (label text-input))
          (title (title text-input)))
      (translate-by (/ (- (width *context*) 600) 2)
                    (+ (/ (height *context*) 2) (height label) (* 2 (height title)))
                    0)
      (paint title target)
      (translate-by 0 (- (* 2 (height title))) 0)
      (paint label target))))

(define-class-shader (text-input :vertex-shader)
  "layout (location = 0) in vec3 position;

void main(){
  gl_Position = vec4(position, 1);
}")

(define-class-shader (text-input :fragment-shader)
  "out vec4 color;

void main(){
  color = vec4(0,0,0,0.75);
}")
