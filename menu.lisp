(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject pause-menu ()
  ())

(defmethod compute-resources :after ((editor pause-menu) resources ready cache)
  (vector-push-extend (asset 'leaf 'square) resources)
  (vector-push-extend (asset 'trial 'trial::fullscreen-square) resources))

(defmethod register-object-for-pass :after (pass (editor pause-menu))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'active-pause-menu)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'text))))

(define-shader-subject inactive-pause-menu (pause-menu)
  ())

(define-handler (inactive-pause-menu pause) (ev)
  ;; FIXME: BROKEN
  ;(pause-game T inactive-pause-menu)
  ;(change-class inactive-pause-menu 'active-pause-menu)
  )

(define-shader-subject active-pause-menu (pause-menu)
  ((vertex-array :initform (asset 'trial 'trial::fullscreen-square) :accessor vertex-array)))

(define-handler (active-pause-menu back) (ev)
  (change-class active-pause-menu 'inactive-pause-menu)
  (unpause-game T active-pause-menu))

(defmethod paint ((active-pause-menu active-pause-menu) target)
  (let ((vao (vertex-array active-pause-menu)))
    (with-pushed-attribs
      (disable :depth-test)
      (gl:bind-vertex-array (gl-name vao))
      (%gl:draw-elements :triangles (size vao) :unsigned-int (cffi:null-pointer))
      (gl:bind-vertex-array 0))))

(define-class-shader (active-pause-menu :vertex-shader)
  "layout (location = 0) in vec3 position;

void main(){
  gl_Position = vec4(position, 1);
}")

(define-class-shader (active-pause-menu :fragment-shader)
  "out vec4 color;

void main(){
  color = vec4(0,0,0,0.75);
}")
