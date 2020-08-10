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

(define-shader-entity fade (transformed listener vertex-entity)
  ((name :initform 'fade)
   (vertex-array :initform (// 'trial 'fullscreen-square))
   (on-complete :initform NIL :accessor on-complete)
   (strength :initform 0.0 :accessor strength)))

(defmethod handle ((ev transition-event) (fade fade))
  (setf (on-complete fade) (on-complete ev))
  (setf (clock (progression 'transition +world+)) 0f0)
  (start (progression 'transition +world+)))

(defmethod apply-transforms progn ((fade fade))
  (setf *projection-matrix*
        (setf *view-matrix*
              (setf *model-matrix* (meye 4)))))

(defmethod render :before ((fade fade) (program shader-program))
  (setf (uniform program "strength") (strength fade)))

(define-class-shader (fade :fragment-shader)
  "uniform float strength = 0.0;
out vec4 color;
void main(){ color = vec4(0,0,0,strength); }")

(define-progression death
  0 1.0 (distortion (set strength :from 0.0 :to 1.0))
  1.0 1.0 (player (call (lambda (player clock step) (respawn player))))  
  1.5 2.5 (distortion (set strength :from 1.0 :to 0.0 :ease circ-in)))

(define-progression hurt
  0.0 0.2 (distortion (set strength :from 0.0 :to 0.7 :ease expo-out))
  0.2 0.3 (distortion (set strength :from 0.7 :to 0.0 :ease expo-out)))

(define-progression transition
  0.0 0.5 (fade (set strength :from 0.0 :to 1.0 :ease quint-in))
  0.5 0.5 (fade (call (lambda (fade clock step) (funcall (on-complete fade)))))
  0.5 1.0 (fade (set strength :from 1.0 :to 0.0 :ease quint-out)))

(define-shader-pass distortion-pass (simple-post-effect-pass)
  ((name :initform 'distortion)
   (active-p :initform NIL)
   (texture :initform (// 'leaf 'pixelfont) :accessor texture)
   (strength :initform 0f0 :accessor strength)))

(defmethod (setf strength) :after (strength (pass distortion-pass))
  (setf (active-p pass) (< 0 strength)))

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
    color = mix(color, vec4(0.2,0.3,0.7,1), clamp(strength*4-3,0,1));
  }else{
    color = texture(previous_pass, (pos+1)/num);
    color = mix(color, vec4(1), clamp(strength*4-3,0,1));
  }
}")
