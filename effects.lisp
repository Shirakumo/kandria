(in-package #:org.shirakumo.fraf.kandria)

(define-shader-pass combine-pass (post-effect-pass)
  ((name :initform 'fade)
   (a-pass :port-type input)
   (b-pass :port-type input)
   (color :port-type output :reader color)
   (texture :initform (// 'kandria 'block-transition) :accessor texture)
   (on-complete :initform NIL :accessor on-complete)
   (strength :initform 0.0 :accessor strength)
   (direction :initform 0.0 :accessor direction)
   (screen-color :initform (vec 0 0 0) :accessor screen-color)))

(defmethod (setf kind) (kind (fade combine-pass))
  (ecase kind
    (:white
     (setf (texture fade) (// 'kandria 'plain-transition))
     (vsetf (screen-color fade) 5 5 5))
    (:black
     (setf (texture fade) (// 'kandria 'plain-transition))
     (vsetf (screen-color fade) 0 0 0))
    (:blue
     (setf (texture fade) (// 'kandria 'plain-transition))
     (vsetf (screen-color fade) 0.2 0.3 0.7))
    (:transition
      (setf (texture fade) (// 'kandria 'block-transition))
      (vsetf (screen-color fade) 0 0 0))))

(defmethod stage :after ((fade combine-pass) (area staging-area))
  (stage (// 'kandria 'block-transition) area)
  (stage (// 'kandria 'plain-transition) area)
  (stage (// 'sound 'ui-transition) area))

(defmethod handle ((ev transition-event) (fade combine-pass))
  (cond ((not (flare:running (progression 'transition +world+)))
         (when (eql :transition (kind ev))
           (harmony:play (// 'sound 'ui-transition)))
         (setf (kind fade) (kind ev))
         (push (on-complete ev) (on-complete fade))
         (setf (clock (progression 'transition +world+)) 0f0)
         (start (progression 'transition +world+)))
        ((< (flare:clock (progression 'transition +world+)) 0.7)
         (push (on-complete ev) (on-complete fade)))
        (T
         (funcall (on-complete ev)))))

(defmethod render :before ((fade combine-pass) (program shader-program))
  (gl:active-texture :texture0)
  (gl:bind-texture :texture-2d (gl-name (texture fade)))
  (setf (uniform program "direction") (direction fade))
  (setf (uniform program "transition_map") 0)
  (setf (uniform program "screen_color") (screen-color fade))
  (setf (uniform program "strength") (- 1 (strength fade))))

(define-class-shader (combine-pass :fragment-shader)
  "uniform float strength = 0.0;
uniform float smooth_size = 0.25;
uniform float direction = 1.0;
uniform vec3 screen_color = vec3(0,0,0);
uniform sampler2D transition_map;
uniform sampler2D a_pass;
uniform sampler2D b_pass;
in vec2 tex_coord;
out vec4 color;
void main(){
  vec4 a = texture(a_pass, tex_coord);
  vec4 b = texture(b_pass, tex_coord);
  color = mix(a, b, b.a);

  float mask = abs(direction-texture(transition_map, tex_coord).r);
  mask = smoothstep(strength, strength+smooth_size, mask*(1-smooth_size)+smooth_size);
  vec4 o = vec4(screen_color, mask);
  color = mix(color, o, o.a);
}")

(define-progression death
  0.0 1.5 (distortion (set strength :from 0.0 :to 1.0 :ease circ-out))
  1.5 1.5 (fade (call (lambda (fade clock step)
                        (setf (direction fade) 0.0)
                        (setf (strength fade) 0.0)
                        (setf (kind fade) :blue))))
  1.5 2.0 (fade (set strength :from 0.0 :to 1.0 :ease expo-in))
  2.0 2.0 (T (call (lambda (world clock step) (show-panel 'game-over))))
  2.0 2.5 (fade (set strength :to 0.0 :ease expo-out))
  2.0 4.0 (distortion (set strength :from 1.0 :to 0.0 :ease circ-in)))

(define-progression hurt
  0.0 0.2 (distortion (set strength :from 0.0 :to 0.5 :ease expo-out))
  0.2 0.3 (distortion (set strength :from 0.5 :to 0.0 :ease expo-out)))

(define-progression transition
  0.0 0.0 (fade (set direction :to 0.0))
  0.2 0.7 (fade (set strength :from 0.0 :to 1.0))
  0.7 1.0 (fade (call (lambda (fade clock step)
                        (loop for func = (pop (on-complete fade))
                              while func
                              do (funcall func))
                        (setf (direction fade) 1.0))))
  1.0 1.5 (fade (set strength :from 1.0 :to 0.0)))

(define-progression start-game
  0.0 1.0 (fade (call (lambda (fade clock step)
                        (setf (kind fade) :black)
                        (setf (direction fade) 0.0)
                        (setf (strength fade) (max (strength fade) 1.0)))))
  0.0 5.0 (fade (set strength :from 1.0 :to 0.0 :ease bounce-in)))

(define-progression game-end
  0.0 0.0 (:camera (set shake-timer :to 5.0))
  0.0 0.0 (:camera (set shake-intensity :from 0.0 :to 10.0))
  0.2 0.3 (:camera (set shake-intensity :from 10.0 :to 0.0))
  0.0 0.0 (sandstorm (set velocity :to 0.05))
  1.0 1.0 (T (call (lambda (f c s) (harmony:play (// 'sound 'ambience-earthquake)))))
  1.0 3.0 (:camera (set shake-intensity :from 0.0 :to 20.0 :ease cubic-in))
  1.0 3.0 (sandstorm (set strength :to 0.3))
  1.5 1.5 (T (call (lambda (f c s) (trigger 'rockslide NIL :location (v+ (location (camera +world+))
                                                                         (v_y (bsize (camera +world+)))
                                                                         (vec 0 300))))))
  1.9 1.9 (T (call (lambda (f c s) (trigger 'rockslide NIL :location (v+ (location (camera +world+))
                                                                         (v_y (bsize (camera +world+)))
                                                                         (vec 0 300))))))
  2.0 2.0 (T (call (lambda (f c s) (trigger 'rockslide NIL :location (v+ (location (camera +world+))
                                                                         (v_y (bsize (camera +world+)))
                                                                         (vec 0 300))))))
  3.6 3.6 (fade (set strength :to 1.0))
  4.0 5.0 (:camera (set shake-intensity :to 0.0)))

(define-progression low-health
  0.0 0.0 (fade (call (lambda (fade clock step) (setf (kind fade) :white))))
  0.0 0.2 (fade (set strength :from 0.0 :to 0.5))
  0.2 0.5 (fade (set strength :from 0.5 :to 0.0 :ease expo-out))
  0.5 0.6 (T (set time-scale :from 1.0 :to 0.2 :ease quint-in))
  1.0 1.5 (T (set time-scale :from 0.2 :to 1.0 :ease quint-out)))

(define-shader-pass distortion-pass (simple-post-effect-pass)
  ((name :initform 'distortion)
   (active-p :initform NIL)
   (texture :initform (// 'kandria 'pixelfont) :accessor texture)
   (strength :initform 0f0 :accessor strength)))

(defmethod (setf strength) :after (strength (pass distortion-pass))
  (unless (eq (active-p pass) (< 0 strength))
    (setf (active-p pass) (and (< 0 strength)
                               (not (setting :gameplay :visual-safe-mode))))))

(defmethod stage :after ((pass distortion-pass) (area staging-area))
  (stage (texture pass) area))

(defmethod prepare-pass-program :after ((pass distortion-pass) (program shader-program))
  (gl:active-texture :texture0)
  (gl:bind-texture :texture-2d (gl-name (texture pass)))
  (setf (uniform program "pixelfont") 0)
  (setf (uniform program "seed") (logand #xFFFF (sxhash (floor (* 2 (clock +world+))))))
  ;; Discretize the strength progression to reduce the flicker speed.
  (setf (uniform program "strength") (strength pass)))

(defmethod handle ((event event) (pass distortion-pass)))

(define-class-shader (distortion-pass :fragment-shader)
  "uniform sampler2D pixelfont;
uniform sampler2D previous_pass;
uniform int seed = 0;
uniform float strength = 0.0;
in vec2 tex_coord;
out vec4 color;

const vec2 num = vec2(40, 26)*1.5;
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

(define-shader-pass sandstorm-pass (simple-post-effect-pass)
  ((name :initform 'sandstorm)
   (active-p :initform NIL)
   (noise :port-type fixed-input :texture (// 'kandria 'noise))
   (noise-cloud :port-type fixed-input :texture (// 'kandria 'noise-cloud))
   (strength :initform 0f0 :accessor strength)
   (velocity :initform 1f0 :accessor velocity)))

(defmethod (setf strength) :after (strength (pass sandstorm-pass))
  (unless (eq (active-p pass) (< 0 strength))
    (setf (active-p pass) (and (< 0 strength)
                               (not (setting :gameplay :visual-safe-mode))))))

(defmethod stage :after ((pass sandstorm-pass) (area staging-area))
  (stage (texture (port pass 'noise)) area)
  (stage (texture (port pass 'noise-cloud)) area))

(defmethod render :before ((pass sandstorm-pass) (program shader-program))
  (setf (uniform program "strength") (strength pass))
  (setf (uniform program "speed") (velocity pass))
  (when (unit 'player +world+)
    (let* ((loc (location (unit 'player +world+)))
           (loc (m* (projection-matrix) (view-matrix) (tvec (vx loc) (vy loc) 0 1))))
      (setf (uniform program "focus_center") (tvec (* 0.5 (1+ (vx loc)))
                                                   (* 0.5 (1+ (vy loc)))))))
  (setf (uniform program "time") (clock +world+)))

(define-class-shader (sandstorm-pass :fragment-shader)
  "
uniform float time;
uniform sampler2D previous_pass;
uniform sampler2D noise;
uniform sampler2D noise_cloud;
uniform float strength = 1.0;
uniform float speed = 1.0;
uniform vec2 focus_center = vec2(0.5,0.5);
in vec2 tex_coord;
out vec4 color;

void main(){
  vec3 previous = texture(previous_pass, tex_coord).rgb;
  if(0 < strength){
    color.a = 1;
    float t = time*3;
    float r = (sin(t)+sin(t*0.3)+sin(t*0.1))*0.1;
    float off = sin(t*0.25)*0.0025*speed*0.1;
    vec3  n = texture(noise,       (tex_coord+r*vec2(speed, 0.20)+vec2(0, 0.0)+t*vec2(speed*0.4, off))*1.5).rgb;
    float a = texture(noise_cloud, (tex_coord+r*vec2(speed, 0.20)+vec2(0, 0.0)+t*vec2(speed*0.4, off))*0.3).r;
    float b = texture(noise_cloud, (tex_coord+r*vec2(speed, 0.20)+vec2(0, 0.5)+t*vec2(speed*0.4, off))*0.2).r;
    float c = texture(noise_cloud, (tex_coord+r*vec2(speed, 0.20)+vec2(0, 0.3)+t*vec2(speed*0.4, off))*0.1).r;
    float s = a*b*c*(length(n)*0.1+0.95)*strength;
    vec3 sand = vec3(0.9, 0.8, 0.7)*(s+0.5)+n/20;
    float mix_factor = clamp(1.3-s*5+strength, 0, 1);
    mix_factor = clamp((mix_factor-0.5)*0.5, -0.5, 0.5)+0.75;
    color.rgb = mix(sand, previous, mix_factor);
// Focus sphere
    float cdist = distance(tex_coord,focus_center);
    cdist = clamp((0.3-cdist)*2.0, 0.0, 1.0);
    color.rgb = mix(color.rgb, previous, cdist);
// Vignette
    vec2 d = abs(tex_coord-0.5)-vec2(0.1);
    float sdf = length(max(d, 0.0)) + min(max(d.x,d.y), 0.0) - 0.2;
    color = mix(color, vec4(0.9,0.8,0.7,1), clamp(sdf*3*strength, 0, 1));
  }else{
    color = vec4(previous, 1);
  }
}")

(define-setting-observer visual-safe-mode :gameplay :visual-safe-mode (value)
  (when value
    (setf (active-p (unit 'distortion T)) NIL)
    (setf (active-p (unit 'sandstorm T)) NIL)))
