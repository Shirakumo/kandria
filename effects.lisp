(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity particle (vertex-entity located-entity)
  ((timer :initform 0.0f0 :accessor timer)
   (seed :initform (random 1.0) :accessor seed))
  (:default-initargs :vertex-array (asset 'leaf '1x)))

(defmethod lifetime ((particle particle)) 0.20)

(defmethod handle ((ev tick) (particle particle))
  (incf (timer particle) (float (slot-value ev 'dt) 0f0))
  (when (< (lifetime particle) (timer particle))
    (leave particle +world+)))

(defmethod render :before ((particle particle) (program shader-program))
  (setf (uniform program "seed") (seed particle))
  (setf (uniform program "timer") (timer particle)))

(define-class-shader (particle :vertex-shader)
  "layout (location = 1) in vec2 in_texcoord;
out vec2 texcoord;

void main(){
  texcoord = in_texcoord;
}")

(define-shader-entity dust-cloud (particle transformed)
  ((direction :initarg :direction :accessor direction))
  (:default-initargs :direction (vec2 0 1)))

(defmethod lifetime ((dust-cloud dust-cloud)) 0.40)

(defmethod apply-transforms progn ((particle particle))
  (scale-by 32 32 1)
  (translate-by -0.5 -0.5 0))

(defmethod render :before ((particle dust-cloud) (program shader-program))
  (setf (uniform program "direction") (direction particle)))

(define-class-shader (dust-cloud :fragment-shader)
  "
uniform float timer = 0;
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
  float ftime = (1-timer*2)*2;
  vec2 pos = floor(texcoord*32)/32.0;
  vec2 off = vec2(ftime/3.0)*direction;
  vec2 skew = abs(direction.yx)+1;
  float cdist = 1-length(vec2(pos.x-0.5,pos.y-0.5)/skew+off)*4;

  float rng = hash12n(pos+seed);
  float prob = rng * ftime * cdist;
  if(prob < 0.5) color.a = 0;
  //color = vec4(cdist,0,0,1);
}")
