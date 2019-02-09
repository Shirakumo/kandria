(in-package #:org.shirakumo.fraf.leaf)

(define-shader-pass radial-bokeh-pass (simple-post-effect-pass)
  ())

(define-class-shader (radial-bokeh-pass :fragment-shader)
  '(leaf "radial-bokeh.frag"))

(define-shader-pass %hex-bokeh-pass (post-effect-pass)
  ((parent :initarg :parent :accessor parent)))

(defmethod paint-with :before ((pass %hex-bokeh-pass) target)
  (setf (uniform (shader-program pass) "strength") (coerce (strength (parent pass)) 'single-float)))

(define-shader-pass hex-bokeh-pass-1 (simple-post-effect-pass %hex-bokeh-pass)
  ())

(define-class-shader (hex-bokeh-pass-1 :fragment-shader)
  (pool-path 'leaf "bokeh-1.frag"))

(define-shader-pass hex-bokeh-pass-2 (simple-post-effect-pass %hex-bokeh-pass)
  ())

(define-class-shader (hex-bokeh-pass-2 :fragment-shader)
  (pool-path 'leaf "bokeh-2.frag"))

(define-shader-pass hex-bokeh-pass (post-effect-pass)
  ((bokeh-b :port-type input)
   (bokeh-c :port-type input)
   (bokeh-d :port-type input)
   (color :port-type output)
   (children :initform NIL :accessor children)
   (strength :initarg :strength :accessor strength))
  (:default-initargs :strength 0.0
                     :name :bokeh))

(defmethod initialize-instance :after ((pass hex-bokeh-pass) &key)
  (setf (children pass)
        (list (make-instance 'hex-bokeh-pass-1 :parent pass :uniforms `(("blurdir" ,(vec 0 1))))
              (make-instance 'hex-bokeh-pass-1 :parent pass :uniforms `(("blurdir" ,(vec 1.0 -0.577350269189626))))
              (make-instance 'hex-bokeh-pass-2 :parent pass :uniforms `(("blurdir" ,(vec -1.0 -0.577350269189626))))
              (make-instance 'hex-bokeh-pass-2 :parent pass :uniforms `(("blurdir" ,(vec 1.0 -0.577350269189626)))))))

(defmethod paint-with :before ((pass hex-bokeh-pass) target)
  (setf (uniform (shader-program pass) "strength") (coerce (strength pass) 'single-float)))

(defclass hex-bokeh-pass-node ()
  ((parent :initarg :parent :accessor parent)))

(defmethod connect (source (port hex-bokeh-pass-node) pipeline)
  (let ((pass (parent port)))
    (enter pass pipeline)
    (destructuring-bind (a b c d) (children pass)
      (connect source (flow:port a 'previous-pass) pipeline)
      (connect source (flow:port b 'previous-pass) pipeline)
      (connect (flow:port a 'color) (flow:port c 'previous-pass) pipeline)
      (connect (flow:port a 'color) (flow:port d 'previous-pass) pipeline)
      (connect (flow:port b 'color) (flow:port pass 'bokeh-b) pipeline)
      (connect (flow:port c 'color) (flow:port pass 'bokeh-c) pipeline)
      (connect (flow:port d 'color) (flow:port pass 'bokeh-d) pipeline))))

(defmethod flow:port ((pass hex-bokeh-pass) (name (eql 'previous-pass)))
  (make-instance 'hex-bokeh-pass-node :parent pass))

(define-class-shader (hex-bokeh-pass :fragment-shader)
  (pool-path 'leaf "bokeh-3.frag"))

(define-shader-pass blur-pass (simple-post-effect-pass)
  ())

(defun pascal-row (n)
  (cond ((= 0 n) (list 1))
        ((= 1 n) (list 1 1))
        (T (loop repeat n
                 for row = (list 1 1)
                 then (list* 1 (loop for (a b) on row
                                     if b collect (+ a b)
                                     else collect 1))
                 finally (return row)))))

(defun gauss-coefficients (n)
  (let* ((row (pascal-row (+ n 3)))
         (total (- (reduce #'+ row)
                   (* 2 (+ (first row) (second row)))))
         (coeff ()))
    (loop for i in (cddr row)
          repeat (- (/ (1+ (length row)) 2) 2)
          do (push (float (/ i total)) coeff))
    coeff))

(defun blur-values (n)
  (let* ((weights (list* 0 (gauss-coefficients n)))
         (offsets (list* 0 (loop for i from 0 below (length weights) collect i))))
    (values (loop for (x y) on weights by #'cddr
                  for (l r) on offsets by #'cddr
                  while y collect (/ (+ (* x l) (* y r))
                                     (+ x y)))
            (loop for (x y) on weights by #'cddr
                  while y collect (+ x y)))))

(defun make-blur-glsl (n)
  (multiple-value-bind (offset weight) (blur-values n)
    (format T "~&  float offset[~d] = float[](~{~f~^, ~});" (length offset) offset)
    (format T "~&  float weight[~d] = float[](~{~f~^, ~});" (length weight) weight)
    (format T "~&  color = texture2D(previous_pass, vec2(gl_FragCoord)/size) * weight[0];")
    (format T "~&  for(int i=1; i<~d; i++){" n)
    (format T "~&    color += texture2D(previous_pass, (vec2(gl_FragCoord)+direction*offset[i])/size) * weight[i];")
    (format T "~&    color += texture2D(previous_pass, (vec2(gl_FragCoord)-direction*offset[i])/size) * weight[i];")
    (format T "~&  }")))

(defmethod paint-with ((pass blur-pass) thing)
  (let ((program (shader-program pass)))
    (setf (uniform program "direction") +vy2+)
    (call-next-method)
    (setf (uniform program "direction") +vx2+)
    (call-next-method)))

(define-class-shader (blur-pass :fragment-shader)
  "uniform sampler2D previous_pass;
uniform vec2 direction = vec2(0, 1);
uniform float strength = 1.0;
out vec4 color;

void main(){
  vec2 size = vec2(textureSize(previous_pass, 0));
  float offset[3] = float[](0.0, 1.3846153, 3.2307692);
  float weight[3] = float[](0.22702703, 0.31621623, 0.07027027);
  color = texture2D(previous_pass, vec2(gl_FragCoord)/size) * weight[0];
  for(int i=1; i<9; i++){
    color += texture2D(previous_pass, (vec2(gl_FragCoord)+(direction*offset[i]))/size) * weight[i];
    color += texture2D(previous_pass, (vec2(gl_FragCoord)-(direction*offset[i]))/size) * weight[i];
  }
}")

(define-shader-pass blink-pass (simple-post-effect-pass)
  ((strength :initform 0.0 :accessor strength)
   (middle :initform 0 :accessor middle))
  (:default-initargs :name :blink))

(defmethod paint-with :before ((pass blink-pass) thing)
  (let ((program (shader-program pass)))
    (setf (uniform program "strength") (coerce (strength pass) 'single-float))
    (setf (uniform program "middle") (round (middle pass)))))

(define-class-shader (blink-pass :fragment-shader)
  "uniform sampler2D previous_pass;
uniform float strength = 0.8;
uniform int middle = 96;
out vec4 color;

void main(){
  float height = textureSize(previous_pass, 0).y;
  float percentage = abs(gl_FragCoord.y - middle)/height;
  if(percentage < (1-strength)){
    color = texelFetch(previous_pass, ivec2(gl_FragCoord.xy), 0);
    color.a = 1;
    color.rgb *= (1-strength*0.6);
  }else{
    color = vec4(0,0,0,1);
  }
}")

(define-asset (leaf particle) mesh
    (make-rectangle 1 1))

(define-shader-subject particle (vertex-entity located-entity)
  ((frame :initform 0 :accessor frame)
   (seed :initform (random 1.0) :accessor seed))
  (:default-initargs :vertex-array (asset 'leaf 'particle)))

(defmethod lifetime ((particle particle)) 20)

(define-handler (particle trial:tick) (ev)
  (incf (frame particle))
  (when (< (lifetime particle) (frame particle))
    (leave particle +level+)))

(defmethod paint :before ((particle particle) (pass shader-pass))
  (let ((program (shader-program-for-pass pass particle)))
    (setf (uniform program "seed") (seed particle))
    (setf (uniform program "frame") (frame particle))))

(define-class-shader (particle :vertex-shader)
  "layout (location = 1) in vec2 in_texcoord;
out vec2 texcoord;

void main(){
  texcoord = in_texcoord;
}")

(define-shader-subject dust-cloud (particle)
  ((direction :initarg :direction :accessor direction))
  (:default-initargs :vertex-array (asset 'leaf 'player-mesh)
                     :direction (vec2 0 1)))

(defmethod lifetime ((dust-cloud dust-cloud)) 50)

(defmethod paint :before ((particle dust-cloud) (pass shader-pass))
  (let ((program (shader-program-for-pass pass particle)))
    (setf (uniform program "direction") (direction particle))))

(define-class-shader (dust-cloud :fragment-shader)
  "
uniform int frame = 0;
uniform float seed = 1.0;
uniform vec2 direction = vec2(0,1);
in vec2 texcoord;
out vec4 color;

float hash12n(vec2 p){
  p  = fract(p * vec2(5.3987, 5.4421));
  p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
  return fract(p.x * p.y * 95.4307);
}

void main(){
  float ftime = (1-(frame/50.0))*2;
  vec2 pos = floor(texcoord*16)/16.0;
  vec2 off = vec2(ftime/3.0)*direction;
  vec2 skew = abs(direction.yx)+1;
  float cdist = 1-length(vec2(pos.x-0.5,pos.y-0.5)/skew+off)*4;

  float rng = hash12n(pos+seed);
  float prob = rng * ftime * cdist;
  if(prob < 0.3) color.a = 0;
  //color = vec4(cdist,0,0,1);
}"
  )
