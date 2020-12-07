(in-package #:org.shirakumo.fraf.kandria)

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

(define-progression stun
  0.0 0.1 (T (set time-scale :from 1.0 :to 0.0 :ease quint-in))
  0.2 0.3 (T (set time-scale :from 0.0 :to 1.0 :ease quint-out)))

(define-shader-pass distortion-pass (simple-post-effect-pass)
  ((name :initform 'distortion)
   (active-p :initform NIL)
   (texture :initform (// 'kandria 'pixelfont) :accessor texture)
   (strength :initform 0f0 :accessor strength)))

(defmethod (setf strength) :after (strength (pass distortion-pass))
  (unless (eq (active-p pass) (< 0 strength))
    (setf (active-p pass) (< 0 strength))))

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

(define-asset (kandria displacement) image
    #p"displacement.png")

(define-shader-pass displacement-pass (simple-post-effect-pass)
  ((name :initform 'displacement)
   (texture :initform (// 'kandria 'displacement) :reader texture)
   (location :initform (vec 0 0) :accessor location)
   (tt :initform 100.0 :accessor tt)))

(defmethod stage :after ((pass displacement-pass) (area staging-area))
  (stage (texture pass) area))

(defmethod handle ((ev tick) (pass displacement-pass))
  (incf (tt pass) (* 10 (dt ev))))

(defmethod (setf location) :after (location (pass displacement-pass))
  (setf (tt pass) 0.0))

(defmethod render :before ((pass displacement-pass) (program shader-program))
  (gl:active-texture :texture1)
  (gl:bind-texture :texture-2D (gl-name (texture pass)))
  (setf (uniform program "displacement_map") 1)
  (setf (uniform program "effect_size") (/ (tt pass) 2))
  (setf (uniform program "effect_strength") (* (tt pass) 10))
  (let ((loc (location pass)))
    (setf (uniform program "screen_pos") (vxy (m* (view-matrix) (vec4 (vx loc) (vy loc) 0 1))))))

(define-class-shader (displacement-pass :vertex-shader)
  "uniform sampler2D previous_pass;
uniform sampler2D displacement_map;
uniform vec2 screen_pos = vec2(0.5, 0.5);
uniform float effect_size = 1.0;
layout (location = 1) in vec2 in_tex_coord;
out vec2 dis_coord;

void main(){
  vec2 view_size = vec2(textureSize(previous_pass, 0).xy);
  vec2 dis_size = vec2(textureSize(displacement_map, 0).xy);
  dis_coord = ((in_tex_coord*view_size - screen_pos)/effect_size)/dis_size+0.5;
}")

(define-class-shader (displacement-pass :fragment-shader)
  "uniform sampler2D previous_pass;
uniform sampler2D displacement_map;
uniform float effect_strength = 1.0;
in vec2 tex_coord;
in vec2 dis_coord;
out vec4 color;

void main(){
  vec2 displacement = normalize(texture(displacement_map, dis_coord).rgb-0.5).xy;
  vec3 previous = texture(previous_pass, tex_coord+displacement/10*effect_strength).rgb;
  color = vec4(previous, 1);
}")
