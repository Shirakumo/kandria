(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity chunk (located-entity bakable)
  ((vertex-array :initform (asset 'trial:geometry 'trial::fullscreen-square) :accessor vertex-array)
   (tileset :initarg :tileset :accessor tileset)
   (tilemap :accessor tilemap)
   (texture :accessor texture)
   (size :initarg :size :accessor size)
   (tile-size :initarg :tile-size :accessor tile-size))
  (:default-initargs
   :tileset (asset 'leaf 'ground)
   :tile-size *default-tile-size*))

(defmethod initialize-instance :after ((chunk chunk) &key size tilemap)
  (setf (tilemap chunk) (make-array (round (* (vx size) (vy size) 4)) :element-type '(unsigned-byte 8)))
  (etypecase tilemap
    (null
     (fill (tilemap chunk) 1))
    ((or string pathname)
     (with-open-file (stream tilemap :element-type '(unsigned-byte 8))
       (read-sequence (tilemap chunk) stream)))
    (vector
     (replace (tilemap chunk) tilemap)))
  (setf (texture chunk) (make-instance 'texture :width (round (vx size))
                                                :height (round (vy size))
                                                :pixel-data (tilemap chunk)
                                                :pixel-type :unsigned-byte
                                                :pixel-format :rgba-integer
                                                :internal-format :rgba8ui
                                                :min-filter :nearest
                                                :mag-filter :nearest)))

(defmethod paint ((chunk chunk) (pass shader-pass))
  (let ((program (shader-program-for-pass pass chunk))
        (vao (vertex-array chunk)))
    (setf (uniform program "tile_size") (tile-size chunk))
    (setf (uniform program "tileset") 0)
    (setf (uniform program "tilemap") 1)
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (tileset chunk)))
    (gl:active-texture :texture1)
    (gl:bind-texture :texture-2d (gl-name (texture chunk)))
    (gl:bind-vertex-array (gl-name vao))
    (%gl:draw-arrays-instanced :triangles 0 6 (length vao))))

(define-class-shader (chunk :vertex-shader)
  "
layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 vertex_uv;
out vec2 uv;

void main(){
  uv = vertex_uv;
  gl_Position = vec4(vertex, 1);
}")

(define-class-shader (chunk :fragment-shader)
  "
uniform sampler2D tileset;
uniform sampler2D tilemap;
uniform int tile_size = 8;
in vec2 uv;
out vec4 color;

void main(){
  color = texture(tilemap, uv);
}")
