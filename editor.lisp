(in-package #:org.shirakumo.fraf.leaf)

(define-action editor-command ())

(define-action toggle-editor (editor-command)
  (key-press (one-of key :section)))

(define-shader-subject editor (vertex-entity located-entity)
  ((active-p :initarg :active-p :accessor active-p)
   (layer :initform NIL :accessor layer)
   (tile :initform 1 :accessor tile-to-place))
  (:default-initargs
   :name :editor
   :active-p T
   :vertex-array (asset 'leaf 'square)))

(defmethod banned-slots append ((editor editor))
  '(layer))

(defmethod (setf layer) :after (value (editor editor))
  (v:info :leaf.editor "Switched layer to ~a" value))

(define-retention mouse (ev)
  (when (typep ev 'mouse-press)
    (setf (retained 'mouse (button ev)) T))
  (when (typep ev 'mouse-release)
    (setf (retained 'mouse (button ev)) NIL)))

(define-action next-layer ()
  (key-press (one-of key :page-down)))

(define-action prev-layer ()
  (key-press (one-of key :page-up)))

(defmethod enter :after ((editor editor) (scene scene))
  (setf (layer editor) (unit :surface scene)))

;; FIXME: don't handle events when inactive

(define-handler (editor mouse-move) (ev pos)
  (let ((loc (location editor))
        (camera (unit :camera (scene (handler *context*)))))
    (vsetf loc
           (+ (/ (vx pos) (zoom camera)) (vx (location camera)))
           (+ (/ (vy pos) (zoom camera)) (vy (location camera))))
    (when (layer editor)
      (let ((t-s (tile-size (layer editor))))
        (setf (vx loc) (* t-s (floor (vx loc) t-s)))
        (setf (vy loc) (* t-s (floor (vy loc) t-s))))
      (when (retained 'mouse :left)
        (setf (tile loc (layer editor)) (tile-to-place editor)))
      (when (retained 'mouse :right)
        (setf (tile loc (layer editor)) 0)))))

(define-handler (editor mouse-press) (ev button)
  (let ((layer (layer editor)))
    (when layer
      (case button
        (:left (setf (tile (location editor) layer) (tile-to-place editor)))
        (:right (setf (tile (location editor) layer) 0))))))

(define-handler (editor mouse-scroll) (ev delta)
  (cond ((< 0 delta)
         (incf (tile-to-place editor)))
        ((< delta 0)
         (decf (tile-to-place editor))))
  (setf (tile-to-place editor)
        (max 0 (min 255 (tile-to-place editor)))))

(define-handler (editor next-layer) (ev)
  (let ((layers (for:for ((entity over (scene (handler *context*)))
                          (list when (typep entity 'layer) collect entity)))))
    (setf (layer editor) (nth (mod (1+ (position (layer editor) layers))
                                   (length layers))
                              layers))))

(define-handler (editor prev-layer) (ev)
  (let ((layers (for:for ((entity over (scene (handler *context*)))
                          (list when (typep entity 'layer) collect entity)))))
    (setf (layer editor) (nth (mod (1- (position (layer editor) layers))
                                   (length layers))
                              layers))))

(define-handler (editor toggle-editor) (ev)
  (setf (active-p editor) (not (active-p editor))))

(define-handler (editor save-game) (ev)
  (format *query-io* "~&Map save location~@[ [~a]~]:~%> " (file (scene (handler *context*))))
  (let* ((line (read-line *query-io*))
         (file (if (string= "" line)
                   (file (scene (handler *context*)))
                   (pool-path 'leaf (uiop:parse-native-namestring line)))))
    (when file
      (setf (file (scene (handler *context*))) file)
      (save-level (scene (handler *context*)) T))))

(define-handler (editor load-game) (ev)
  (format *query-io* "~&Map load location~@[ [~a]~]:~%> " (file (scene (handler *context*))))
  (let* ((line (read-line *query-io*))
         (file (if (string= "" line)
                   (file (scene (handler *context*)))
                   (pool-path 'leaf (uiop:parse-native-namestring line)))))
    (when file
      (let ((scene (make-instance 'level :file file)))
        (change-scene (handler *context*) scene)))))

(defmethod paint :around ((editor editor) target)
  (when (active-p editor)
    (call-next-method)))

(defmethod paint :before ((editor editor) (pass shader-pass))
  (let ((program (shader-program-for-pass pass editor))
        (layer (layer editor)))
    (when layer
      (gl:bind-texture :texture-2d (gl-name (texture layer)))
      (multiple-value-bind (y x) (floor (* (tile-size layer) (tile-to-place editor)) (width (texture layer)))
        (setf (uniform program "tile") (vec2 x (* (tile-size layer) y)))))))

(define-class-shader (editor :vertex-shader)
  "
layout (location = 0) in vec3 vertex;
uniform vec2 tile;
out vec2 uv;

void main(){
  uv = vertex.xy + tile;
}")

(define-class-shader (editor :fragment-shader)
  "
uniform sampler2D tileset;
in vec2 uv;
out vec4 color;

void main(){
  color = texelFetch(tileset, ivec2(uv), 0);
  color *= 0.75;
}")
