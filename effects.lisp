(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity effect (trial:animated-sprite facing-entity sized-entity)
  ()
  (:default-initargs :sprite-data (asset 'leaf 'effects)))

(defmethod switch-animation ((effect effect) _)
  (let ((region (container effect)))
    (leave effect region)
    (loop for pass across (passes +world+)
          do (remove-from-pass effect pass))))

(defun make-effect (name)
  (let ((effect (make-instance 'effect))
        (region (region +world+)))
    (setf (animation effect) name)
    (enter effect region)
    (loop for pass across (passes +world+)
          do (compile-into-pass effect region pass))))

(define-asset (leaf sweeper) mesh
    (make-rectangle 2.0 0.25 :align :bottomleft))

(define-shader-entity sweep (transformed listener vertex-entity)
  ((name :initform :sweep)
   (vertex-array :initform (// 'leaf 'sweeper))
   (clock :initform 0f0 :accessor clock)
   (direction :initform :from-blank :accessor direction)
   (on-complete :initform NIL :accessor on-complete)))

(defmethod (setf direction) :after (dir (sweep sweep))
  (setf (clock sweep) 0.0))

(defmethod handle ((ev tick) (sweep sweep))
  (setf (clock sweep) (min (+ (clock sweep) (* 3 (dt ev))) 2.0))
  (when (and (on-complete sweep) (<= 2.0 (clock sweep)))
    (funcall (on-complete sweep))
    (setf (on-complete sweep) NIL)))

(defmethod handle ((ev transition-event) (sweep sweep))
  (setf (on-complete sweep) (on-complete ev))
  (setf (direction sweep) (direction ev)))

(defmethod apply-transforms progn ((sweep sweep))
  (setf *projection-matrix*
        (setf *view-matrix* (meye 4)))
  (setf *model-matrix* (meye 4)))

(defmethod render ((sweep sweep) (program shader-program))
  (let (y dy)
    (ecase (direction sweep)
      (:to-blank
       (translate-by -3 1 0)
       (setf y +1 dy -0.25))
      (:from-blank
       (translate-by -1 -1.25 0)
       (setf y -1 dy +0.25)))
    (loop repeat 8
          for tt from (- (clock sweep) 1.0) by 0.125
          for xprev = -1 then x
          for x = (ease (clamp 0 tt 1) 'quad-in -1 +1)
          do (translate-by (- x xprev) dy 0)
             (call-next-method))))

(define-class-shader (sweep :fragment-shader)
  "out vec4 color;
void main(){ color = vec4(0,0,0,1); }")

(define-shader-pass distortion-pass (simple-post-effect-pass)
  ((texture :initform (// 'leaf 'pixelfont) :accessor texture)
   (strength :initform 0f0 :accessor strength)))

(defmethod stage :after ((pass distortion-pass) (area staging-area))
  (stage (texture pass) area))

(defmethod prepare-pass-program :after ((pass distortion-pass) (program shader-program))
  (gl:active-texture :texture0)
  (gl:bind-texture :texture-2d (gl-name (texture pass)))
  (setf (uniform program "pixelfont") 0)
  (setf (uniform program "seed") (logand #xFFFF (sxhash (floor (* 10 (current-time))))))
  (setf (uniform program "strength") (strength pass)))

(defmethod handle ((event event) (pass distortion-pass)))

(define-class-shader (distortion-pass :fragment-shader)
  "uniform sampler2D pixelfont;
uniform sampler2D previous_pass;
uniform int seed = 0;
uniform float strength = 0.0;
in vec2 tex_coord;
out vec4 color;

const vec2 num = vec2(40, 26)*2;
const ivec2 glyphs = ivec2(10, 13);
const int glyph_count = 10*13;

float rand(vec2 co){
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(co.xy ,vec2(a,b));
    float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

void main(){
  float scalar = 1-clamp(strength,0,1);
  vec2 pos = floor(tex_coord*num);
  int r = int(rand(pos+seed)*glyph_count);
  float val = 1;
  if(scalar*glyph_count < r){
    vec2 idx = vec2(r%glyphs.x, r/glyphs.x);
    vec2 sub = mod(tex_coord*num, 1);
    val = texelFetch(pixelfont, ivec2((sub+idx)*7), 0).r;
  }
  float scale = clamp(r,scalar*30,glyph_count)*scalar*scalar;
  pos = floor(tex_coord*num*scale)/scale;
  if(val == 1){
    color = texture(previous_pass, pos/num);
  }else{
    color = texture(previous_pass, (pos+1)/num);
  }
}")
