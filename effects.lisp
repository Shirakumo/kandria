(in-package #:org.shirakumo.fraf.leaf)

(define-shader-pass bokeh-pass (simple-post-effect-pass)
  ())

(define-class-shader (bokeh-pass :fragment-shader)
  "
#define GOLDEN_ANGLE 2.39996
#define ITERATIONS 150

uniform sampler2D previous_pass;
uniform float strength = 1.0;
out vec4 color;

mat2 rot = mat2(cos(GOLDEN_ANGLE), sin(GOLDEN_ANGLE), -sin(GOLDEN_ANGLE), cos(GOLDEN_ANGLE));

vec3 bokeh(sampler2D tex, vec2 uv, float radius){
    vec3 acc = vec3(0), div = acc;
    float r = 1.;
    vec2 vangle = vec2(0.0,radius*.01 / sqrt(float(ITERATIONS)));
    
    for (int j = 0; j < ITERATIONS; j++){
        r += 1. / r;
        vangle = rot * vangle;
        vec3 col = texture(tex, uv + (r-1.) * vangle).xyz;
        col = col * col *1.8;
        vec3 bokeh = pow(col, vec3(4));
        acc += col * bokeh;
        div += bokeh;
    }
    return acc / div;
}

void main(){
  vec2 uv = gl_FragCoord.xy / textureSize(previous_pass, 0).x;
  color = vec4(bokeh(previous_pass, uv, strength), 1);
}")

(define-shader-pass bokeh-pass (post-effect-pass)
  ((strength :initform 1.0 :accessor strength)))

(defmethod paint-with :before ((pass bokeh-pass) target)
  (setf (uniform (shader-program pass) "strength") (strength pass)))

(define-shader-pass bokeh-hex-pass-1 (simple-post-effect-pass bokeh-pass)
  ())

(define-class-shader (bokeh-hex-pass-1 :fragment-shader)
  '(leaf "bokeh-1.frag"))

(define-shader-pass bokeh-hex-pass-2 (simple-post-effect-pass bokeh-pass)
  ())

(define-class-shader (bokeh-hex-pass-2 :fragment-shader)
  '(leaf "bokeh-2.frag"))

(define-shader-pass bokeh-hex-pass (bokeh-pass)
  ((bokeh-b :port-type input)
   (bokeh-c :port-type input)
   (bokeh-d :port-type input)
   (color :port-type output)))

(define-class-shader (bokeh-hex-pass :fragment-shader)
  '(leaf "bokeh-3.frag"))

(defun apply-bokeh (scene source)
  (let* ((bokeh-a (make-instance 'bokeh-hex-pass-1 :uniforms `(("blurdir" ,(vec 0 1)))))
         (bokeh-b (make-instance 'bokeh-hex-pass-1 :uniforms `(("blurdir" ,(vec 1.0 -0.577350269189626)))))
         (bokeh-c (make-instance 'bokeh-hex-pass-2 :uniforms `(("blurdir" ,(vec -1.0 -0.577350269189626)))))
         (bokeh-d (make-instance 'bokeh-hex-pass-2 :uniforms `(("blurdir" ,(vec 1.0 -0.577350269189626)))))
         (bokeh (make-instance 'bokeh-hex-pass)))
    (connect source (flow:port bokeh-a 'previous-pass) scene)
    (connect source (flow:port bokeh-b 'previous-pass) scene)
    (connect (flow:port bokeh-a 'color) (flow:port bokeh-c 'previous-pass) scene)
    (connect (flow:port bokeh-a 'color) (flow:port bokeh-d 'previous-pass) scene)
    (connect (flow:port bokeh-b 'color) (flow:port bokeh 'bokeh-b) scene)
    (connect (flow:port bokeh-c 'color) (flow:port bokeh 'bokeh-c) scene)
    (connect (flow:port bokeh-d 'color) (flow:port bokeh 'bokeh-d) scene)
    (flow:port bokeh-d 'color)))

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
  ((strength :initform 0.5 :accessor strength)
   (middle :initform 96 :accessor middle)))

(defmethod paint-with :before ((pass blink-pass) thing)
  (let ((program (shader-program pass)))
    (setf (uniform program "strength") (strength pass))
    (setf (uniform program "middle") (middle pass))))

(define-handler (blink-pass trial:tick) (ev tt)
  ;; FIXME: move somewhere else
  (let ((tt (mod tt (* PI 4))))
    (setf (strength blink-pass)
          (coerce
           (cond ((< tt PI)
                  (+ 1 (/ (cos tt) 2)))
                 ((< tt (* PI 20/16))
                  (+ 1 (/ (cos (+ PI (* 16 tt))) 2)))
                 (T 0.0))
           'single-float))
    (loop for pass across (passes (scene (handler *context*)))
          do (when (typep pass 'bokeh-pass)
               (setf (strength pass) (* (strength blink-pass) 100))))))

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
  }else{
    color = vec4(0,0,0,1);
  }
}")
