(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject parallax ()
  ((texture :initarg :texture :accessor texture)
   (vertex-array :initform (asset 'trial:trial 'trial::fullscreen-square) :accessor vertex-array))
  (:default-initargs :texture (asset 'leaf 'background)))

(defmethod paint ((parallax parallax) (pass shader-pass))
  (let ((vao (vertex-array parallax))
        (program (shader-program-for-pass pass parallax)))
    (with-pushed-attribs
      (setf (uniform program "aspect") (float (/ (width *context*)
                                                 (height *context*))))
      (setf (uniform program "offset") (nv- (vapply (location (unit :camera T)) floor)
                                            (target-size (unit :camera T))))
      (setf (uniform program "parallax") 0)
      (gl:active-texture :texture0)
      (gl:bind-texture :texture-2d (gl-name (texture parallax)))
      (gl:bind-vertex-array (gl-name vao))
      (%gl:draw-elements :triangles (size vao) :unsigned-int (cffi:null-pointer))
      (gl:bind-vertex-array 0))))

(define-class-shader (parallax :vertex-shader)
  "
layout (location = 0) in vec3 position;
layout (location = 1) in vec2 in_tex_coord;
uniform float aspect;
uniform vec2 offset;
out vec2 tex_coord;

void main(){
  gl_Position = vec4(position, 1.0f);
  tex_coord = vec2(in_tex_coord.x, in_tex_coord.y/aspect)+offset/1000;
}")

(define-class-shader (parallax :fragment-shader)
  "
uniform sampler2D parallax;
in vec2 tex_coord;
out vec4 color;

void main(){
  color = texture(parallax, tex_coord);
}")
