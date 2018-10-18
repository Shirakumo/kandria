(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject editor (vertex-entity located-entity)
  ((layer :initform NIL :accessor layer)
   (tile :initform 1 :accessor tile-to-place))
  (:default-initargs
   :vertex-array (asset 'leaf 'square)))

(define-retention mouse (ev)
  (when (typep ev 'mouse-press)
    (setf (retained 'mouse (button ev)) T))
  (when (typep ev 'mouse-release)
    (setf (retained 'mouse (button ev)) NIL)))

(defmethod enter :after ((editor editor) (scene scene))
  (setf (layer editor) (unit :surface scene)))

(define-handler (editor mouse-move) (ev pos)
  (setf (vxy (location editor)) (v+ pos (vxy (location (unit :camera (scene (handler *context*)))))))
  (when (layer editor)
    (let ((t-s (tile-size (layer editor))))
      (setf (vx (location editor)) (* t-s (floor (vx (location editor)) t-s)))
      (setf (vy (location editor)) (* t-s (floor (vy (location editor)) t-s))))
    (when (retained 'mouse :left)
      (setf (tile (location editor) (layer editor)) (tile-to-place editor)))
    (when (retained 'mouse :right)
      (setf (tile (location editor) (layer editor)) 0))))

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

(define-handler (editor save-game) (ev)
  (format *query-io* "~&Map save location [~a]:~%> " (file (scene (handler *context*))))
  (let* ((line (read-line *query-io*))
         (file (uiop:parse-native-namestring (or (string= "" line) line))))
    (setf (file (scene (handler *context*))) file)
    (save-level (scene (handler *context*)) T)))

(define-handler (editor load-game) (ev)
  (format *query-io* "~&Map load location [~a]:~%> " (file (scene (handler *context*))))
  (let* ((line (read-line *query-io*))
         (scene (make-instance 'level :file (if (string= "" line)
                                                (file (scene (handler *context*)))
                                                (pool-path 'leaf line)))))
    (change-scene (handler *context*) scene)))

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
