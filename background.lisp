(in-package #:org.shirakumo.fraf.kandria)

(defvar *background-info* (make-hash-table :test 'eq))

(defmethod background ((name symbol))
  (or (gethash name *background-info*)
      (error "No background named ~s found." name)))

(defmethod (setf background) (value (name symbol))
  (when *context*
    (update-background (unit 'background T)))
  (if value
      (setf (gethash name *background-info*) value)
      (remhash name *background-info*))
  value)

(defun list-backgrounds ()
  (loop for v being the hash-values of *background-info*
        collect v))

(defmacro define-background (name &body initargs)
  (let ((existing (gensym "EXISTING"))
        (initargs (if (listp (first initargs))
                      `(:backgrounds (vector ,@(loop for init in initargs
                                                     collect `(make-instance 'background-info ,@init))))
                      initargs))
        (class (if (listp (first initargs)) 'background-bundle 'background-single)))
    `(let ((,existing (ignore-errors (background ',name))))
       (setf (background ',name) (ensure-instance ,existing ',class :name ',name ,@initargs)))))

(define-gl-struct bg
  (parallax :vec2 :accessor parallax)
  (scaling :vec2 :accessor scaling)
  (offset :vec2 :accessor offset)
  (lighting-strength :float :accessor lighting-strength))

(define-gl-struct backgrounds
  (a (:struct bg) :reader a)
  (b (:struct bg) :reader b)
  (mix :float :accessor mix))

(define-asset (kandria backgrounds) uniform-block
    'backgrounds)

;; FIXME: the naming here is all over the place and I hate it.
(defclass background-info ()
  ((name :initform NIL :initarg :name :accessor name)))

(defmethod print-object ((info background-info) stream)
  (print-unreadable-object (info stream :type T)
    (format stream "~s" (name info))))

(defclass background-single (background-info)
  ((texture :initform (make-instance 'texture) :initarg :texture :accessor texture
            :type (or placeholder-resource texture))
   (parallax :initform (vec 2 1) :initarg :parallax :accessor parallax
             :type vec2)
   (scaling :initform (vec 1.5 1.5) :initarg :scaling :accessor scaling
            :type vec2)
   (offset :initform (vec 0 0) :initarg :offset :accessor offset
           :type vec2)
   (clock :initform '(0 24) :initarg :clock :accessor clock)
   (lighting-strength :initform 1.0 :initarg :lighting-strength :accessor lighting-strength)))

(defmethod stage :after ((single background-single) (area staging-area))
  (stage (texture single) area))

(defmethod shared-initialize :after ((single background-single) slots &key)
  (when *context*
    (issue +world+ 'load-request :thing (texture single))))

(defmethod active-p ((single background-single))
  (destructuring-bind (min max) (clock single)
    (<= min (hour +world+) max)))

(defclass background-bundle (background-info)
  ((backgrounds :initform #() :accessor backgrounds)))

(defmethod stage ((bundle background-bundle) (area staging-area))
  (loop for background across (backgrounds bundle)
        do (stage background area)))

;; TODO: could cache active background.
(defmethod background ((bundle background-bundle))
  (find-if #'active-p (backgrounds bundle)))

(defmethod texture ((bundle background-bundle))
  (texture (background bundle)))

(defmethod parallax ((bundle background-bundle))
  (parallax (background bundle)))

(defmethod scaling ((bundle background-bundle))
  (scaling (background bundle)))

(defmethod offset ((bundle background-bundle))
  (offset (background bundle)))

(defmethod lighting-strength ((bundle background-bundle))
  (lighting-strength (background bundle)))

(defmethod active-p ((bundle background-bundle))
  (background bundle))

(define-shader-entity background (lit-entity listener ephemeral)
  ((name :initform 'background)
   (vertex-array :initform (// 'trial:trial 'trial::fullscreen-square) :accessor vertex-array)
   (texture-a :initform NIL :initarg :texture-a :accessor texture-a)
   (texture-b :initform NIL :initarg :texture-b :accessor texture-b)
   (background :initform () :accessor background))
  (:buffers (kandria backgrounds)))

(defmethod layer-index ((_ background)) -1)

(defmethod render ((background background) (program shader-program))
  (when (texture-b background)
    (let ((vao (vertex-array background)))
      (setf (uniform program "view_size") (vec2 (max 1 (width *context*)) (max 1 (height *context*))))
      (setf (uniform program "view_matrix") (minv *view-matrix*))
      (setf (uniform program "texture_a") 0)
      (setf (uniform program "texture_b") 1)
      (gl:active-texture :texture0)
      (gl:bind-texture :texture-2d (gl-name (texture-a background)))
      (gl:active-texture :texture1)
      (gl:bind-texture :texture-2d (gl-name (texture-b background)))
      (gl:bind-vertex-array (gl-name vao))
      (unwind-protect
           (%gl:draw-elements :triangles (size vao) :unsigned-int 0)
        (gl:bind-vertex-array 0)))))

(defun update-background (background &optional force)
  (let ((info (background background)))
    ;; When there's a new target to set and it's not already our target, update
    (when (allocated-p (// 'kandria 'backgrounds))
      (with-buffer-tx (backgrounds (// 'kandria 'backgrounds))
        (let ((a (a backgrounds))
              (b (b backgrounds)))
          (cond ((and info (not (eq (texture info) (texture-b background))) (not force))
                 (setf (mix backgrounds) (- 1.0 (min 1.0 (mix backgrounds))))
                 ;; First move the target to be the source
                 (setf (texture-a background) (or (texture-b background) (texture info)))
                 (setf (parallax a) (parallax b))
                 (setf (scaling a) (scaling b))
                 (setf (offset a) (offset b))
                 (setf (lighting-strength a) (lighting-strength b)))
                (T
                 (setf (texture-a background) (or (texture-b background) (texture info)))
                 (setf (mix backgrounds) 1.0)))
          ;; Then set new source parameters
          (setf (texture-b background) (texture info))
          (setf (parallax b) (parallax info))
          (setf (scaling b) (scaling info))
          (setf (offset b) (offset info))
          (setf (lighting-strength b) (lighting-strength info)))))))

(defmethod stage :after ((background background) (area staging-area))
  (when (background background)
    (stage (background background) area))
  (stage (texture-a background) area)
  (stage (texture-b background) area))

(defmethod handle ((ev switch-chunk) (background background))
  (when (allocated-p (// 'kandria 'backgrounds))
    (setf (background background) (background (chunk ev)))
    (update-background background)))

(defmethod handle ((ev change-time) (background background))
  #++
  (update-background background))

(defmethod handle ((ev tick) (background background))
  (when (< (mix (struct (// 'kandria 'backgrounds))) 1)
    (with-buffer-tx (backgrounds (// 'kandria 'backgrounds))
      (incf (mix backgrounds) (dt ev)))))

(define-class-shader (background :vertex-shader)
  "layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 vertex_uv;
uniform sampler2D texture_a;
uniform sampler2D texture_b;
uniform mat4 view_matrix;
uniform vec2 view_size;
out vec2 map_coord_a;
out vec2 map_coord_b;
out vec2 world_xy;

void main(){
  maybe_call_next_method();
  gl_Position = vec4(vertex, 1);
  world_xy = (view_matrix*vec4(vertex_uv*view_size,0,1)).xy;
  // We start in view-space, so we have to inverse-map to world-space.
  vec2 size_a = textureSize(texture_a, 0).xy;
  map_coord_a = (view_matrix * vec4(vertex_uv*view_size*backgrounds.a.parallax, 0, 1)).xy;
  map_coord_a += size_a/2 + backgrounds.a.offset;
  map_coord_a /= backgrounds.a.parallax * backgrounds.a.scaling * size_a;

  vec2 size_b = textureSize(texture_b, 0).xy;
  map_coord_b = (view_matrix * vec4(vertex_uv*view_size*backgrounds.b.parallax, 0, 1)).xy;
  map_coord_b += size_b/2 + backgrounds.b.offset;
  map_coord_b /= backgrounds.b.parallax * backgrounds.b.scaling * size_b;
}")

(define-class-shader (background :fragment-shader)
  "uniform sampler2D texture_a;
uniform sampler2D texture_b;
in vec2 map_coord_a;
in vec2 map_coord_b;
in vec2 world_xy;
out vec4 color;

void main(){
  maybe_call_next_method();
  // FIXME: this does not transition right.
  float lighting_strength = backgrounds.b.lighting_strength;
  vec4 color_a = texture(texture_a, map_coord_a);
  vec4 color_b = texture(texture_b, map_coord_b);
  color = mix(color_a, color_b, backgrounds.mix);
  color = apply_lighting_flat(color, vec2(0), 1-lighting_strength, world_xy);
}")
