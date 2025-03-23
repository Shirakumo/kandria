(in-package #:org.shirakumo.fraf.kandria)

(defclass news-display (label)
  ((alloy:value :initform "")
   (up-to-date :initform T :accessor up-to-date)
   (markup :initform () :accessor markup)))

(defmethod initialize-instance :after ((display news-display) &key)
  (fetch-news display))

(presentations:define-realization (ui news-display)
    ((version-warning simple:text)
     (alloy:margins) (@ update-game-notification)
     :size (alloy:un 15)
     :pattern colors:red
     :valign :top :halign :left
     :font (setting :display :font))
    ((label simple:text)
     (alloy:margins) alloy:text
     :size (alloy:un 15)
     :pattern colors:gray
     :valign :bottom :halign :left
     :font (setting :display :font)))

(presentations:define-update (ui news-display)
  (version-warning
   :hidden-p (up-to-date alloy:renderable))
  (label
   :text alloy:text
   :markup (markup alloy:renderable)))

(defun parse-news (source)
  (let ((version-line (read-line source))
        (req (dialogue:resume (dialogue:run (dialogue:compile source T) (make-instance 'dialogue:vm)) 1)))
    (values (dialogue:text req)
            (normalize-markup (dialogue:markup req))
            (subseq version-line 2))))

(defun fetch-news (target &optional (url "https://kandria.com/news.mess"))
  #-nx
  (with-eval-in-task-thread ()
    (v:info :kandria.news "Fetching news...")
    (handler-case
        (multiple-value-bind (text markup version) (parse-news (drakma:http-request url :want-stream T))
          (setf (alloy:value target) text)
          (setf (markup target) markup)
          (setf (up-to-date target) (version<= version (version :app))))
      (usocket:ns-try-again-condition ())
      (error (e)
        (v:severe :kandria.news "Failed to fetch news: ~a" e)))))

(defclass main-menu-button (button)
  ())

(defmethod alloy:activate :after ((button main-menu-button))
  (harmony:play (// 'sound 'ui-confirm)))

(presentations:define-realization (ui main-menu-button)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font (setting :display :font)
   :halign :middle :valign :middle
   :wrap T)
  ((:border simple:rectangle)
   (alloy:extent 0 0 (alloy:pw 1) 1)))

(presentations:define-update (ui main-menu-button)
  (:label
   :size (alloy:un 16)
   :pattern colors:white)
  (:border
   :pattern (if alloy:focus colors:white colors:transparent)))

(presentations:define-animated-shapes main-menu-button
  (:border (simple:pattern :duration 0.2)))

(defclass eating-constraint-layout (org.shirakumo.alloy.layouts.constraint:layout)
  ())

(defmethod alloy:handle ((ev alloy:pointer-event) (focus eating-constraint-layout))
  (restart-case
      (call-next-method)
    (alloy:decline ()
      (setf (alloy:cursor (alloy:ui focus)) :arrow)
      T))
  (when (typep ev 'alloy:drop-event)
    (alloy:decline)))

(defclass main-menu (menuing-panel)
  ())

(defmethod initialize-instance :after ((panel main-menu) &key)
  (let ((layout (make-instance 'eating-constraint-layout))
        (menu (make-instance 'alloy:vertical-linear-layout :cell-margins (alloy:margins 5) :min-size (alloy:size 120 30)))
        (focus (make-instance 'alloy:focus-list)))
    (alloy:enter menu layout :constraints `((:center :w) (:bottom 20) (:height 350) (:width 300)))
    (macrolet ((with-button ((name &rest initargs) &body body)
                 `(let ((button (alloy:represent (@ ,name) 'main-menu-button :focus-parent focus :layout-parent menu ,@initargs)))
                    (alloy:on alloy:activate (button)
                      ,@body)
                    button)))
      (when (and (list-saves)
                 (not (setting :debugging :kiosk-mode)))
        (with-button (resume-game)
          (handler-case
              (with-error-logging (:kandria.save)
                (resume-state (first (sort (list-saves) #'> :key #'save-time))))
            #+kandria-release
            (error () (messagebox (@ save-file-corrupted-notice)))))
        (with-button (load-game-menu)
          (show-panel 'save-menu :intent :load)))
      (if (setting :debugging :kiosk-mode)
          (with-button (new-game)
            (setf (state +main+) (make-instance 'save-state :filename "1"))
            (load-game NIL +main+))
          (with-button (new-game)
            (show-panel 'save-menu :intent :new)))
      (with-button (options-menu)
        (show-panel 'options-menu))
      (with-button (mod-menu)
        (show-panel 'module-menu))
      (with-button (credits-menu)
        (show-credits :on-hide (lambda () (show-panel 'main-menu))))
      #++
      (with-button (changelog-menu)
        )
      (let ((subbutton
              (with-button (subscribe-cta)
                (open-in-browser "https://courier.tymoon.eu/subscription/1"))))
        (alloy:on alloy:focus (value subbutton)
          (setf (presentations:update-overrides subbutton)
                (if value
                    `((:label :markup ((0 1000 (:rainbow T)))))
                    `((:label :markup ()))))))
      (let ((exit (with-button (exit-game)
                    (quit *context*))))
        (alloy:on alloy:exit (focus)
          (setf (alloy:focus exit) :weak)
          (setf (alloy:focus focus) :strong)))
      (let ((news (make-instance 'news-display)))
        (alloy:enter news layout :constraints `((:left 5) (:bottom 5) (:height 60) (:width 500))))
      (let ((version (make-instance 'label :value (format NIL "v~a" (version :app))
                                           :style `((:label :pattern ,colors:gray :halign :right :valign :bottom :size ,(alloy:un 10))))))
        (alloy:enter version layout :constraints `((:right 5) (:bottom 5) (:height 60) (:width 500)))))
    (alloy:finish-structure panel layout focus)))

(define-shader-entity fullscreen-background (lit-entity textured-entity trial:fullscreen-entity)
  ((texture :initform (// 'kandria 'main-menu))))

(define-class-shader (fullscreen-background :fragment-shader -10)
  "out vec4 color;

void main(){
  maybe_call_next_method();
  color = apply_lighting_flat(color, vec2(0, -5), 0, vec2(0));
}")

(define-shader-entity star (lit-sprite listener)
  ((multiplier :initform 1.0 :accessor multiplier)
   (texture :initform (// 'kandria 'star))
   (size :initform (vec 105 105))
   (clock :initform (random 1000.0) :accessor clock)))

(defmethod handle ((ev tick) (star star))
  (incf (clock star) (dt ev)))

(defmethod render :before ((star star) (program shader-program))
  (setf (uniform program "multiplier")
        (float (+ 1.0 (/ (+ (sin (* 2 (clock star)))
                            (sin (* PI (clock star))))
                         2.0))
               0f0)))

(define-class-shader (star :fragment-shader)
  "uniform float multiplier = 1.0;
out vec4 color;
void main(){
  maybe_call_next_method();
   color *= multiplier;
}")

(define-asset (kandria wave-grid) mesh
    (with-mesh-construction (v :finalizer finalize :attributes (location uv normal) :deduplicate NIL)
      (let* ((s (/ 512 64))
             (s2 (/ s -2)))
        (dotimes (x s (finalize-data))
          (dotimes (y s)
            (v (+ x s2 -0.0) 0 (+ y s2 -0.0) (/ (+ x 0) s) (/ (+ y 0) s) 0 1 0)
            (v (+ x s2 +1.0) 0 (+ y s2 -0.0) (/ (+ x 1) s) (/ (+ y 0) s) 0 1 0)
            (v (+ x s2 +1.0) 0 (+ y s2 +1.0) (/ (+ x 1) s) (/ (+ y 1) s) 0 1 0)
            (v (+ x s2 -0.0) 0 (+ y s2 +1.0) (/ (+ x 0) s) (/ (+ y 1) s) 0 1 0)))))
  :vertex-form :patches)

(define-shader-entity wave (listener renderable)
  ((wave-pass :initform (make-instance 'wave-propagate-pass :resolution 512) :initarg :wave-pass :accessor wave-pass)
   (vertex-array :initform (// 'kandria 'wave-grid) :accessor vertex-array)
   (matrix :initform (meye 4) :accessor matrix)
   (clock :initform 0.0 :accessor clock)))

(defmethod initialize-instance :after ((wave wave) &key)
  (handle (make-instance 'resize :width (width *context*) :height (height *context*)) wave))

(defmethod stage :after ((wave wave) (area staging-area))
  (stage (wave-pass wave) area)
  (stage (vertex-array wave) area))

(defmethod handle ((ev tick) (wave wave))
  (when (<= (decf (clock wave) (dt ev)) 0.0)
    (enter (vrand (vec2 0.5) 0.5) (wave-pass wave))
    (setf (clock wave) (+ 0.1 (random 0.5))))
  (update (wave-pass wave) (dt ev) (tt ev) (fc ev)))

(defmethod handle ((ev resize) (wave wave))
  (let ((mat (mperspective 50 (/ (max 1 (width ev)) (max 1 (height ev))) 1.0 100000.0)))
    (!m* mat mat (mlookat (vec 0 50 -200) (vec 0 30 0) +vy3+))
    (!m* mat mat (mscaling (vec 64 1 64)))
    (setf (matrix wave) mat)))

(defmethod render ((wave wave) (program shader-program))
  (handle (make-instance 'resize :width (width *context*) :height (height *context*)) wave)
  (gl:active-texture :texture0)
  (gl:bind-texture :texture-2d (gl-name (color (wave-pass wave))))
  (setf (uniform program "heightmap") 0)
  (setf (uniform program "transform_matrix") (matrix wave))
  (let* ((vao (vertex-array wave)))
    (gl:bind-vertex-array (gl-name vao))
    (gl:patch-parameter :patch-vertices 4)
    (%gl:draw-arrays :patches 0 (size vao))
    (gl:bind-vertex-array 0)))

(define-class-shader (wave :vertex-shader)
  "layout (location = TRIAL_V_LOCATION) in vec3 position;
layout (location = TRIAL_V_UV) in vec2 uv;

out vec3 vPosition;
out vec2 vUV;

void main(){
  maybe_call_next_method();
  vPosition = position;
  vUV = uv;
}")

(define-class-shader (wave :tess-control-shader)
  "#version 330
#extension GL_ARB_tessellation_shader : require
layout (vertices = 4) out;
in vec3 vPosition[];
in vec2 vUV[];
out vec3 tcPosition[];
out vec2 tcUV[];
const int subdivs = 64;

void main(){
  tcPosition[gl_InvocationID] = vPosition[gl_InvocationID];
  tcUV[gl_InvocationID] = vUV[gl_InvocationID];
  if(gl_InvocationID == 0){
    gl_TessLevelInner[0] = subdivs;
    gl_TessLevelInner[1] = subdivs;
    gl_TessLevelOuter[0] = subdivs;
    gl_TessLevelOuter[1] = subdivs;
    gl_TessLevelOuter[2] = subdivs;
    gl_TessLevelOuter[3] = subdivs;
  }
}")

(define-class-shader (wave :tess-evaluation-shader)
  "#version 330
#extension GL_ARB_tessellation_shader : require
layout (quads) in;
uniform sampler2D heightmap;
uniform mat4 transform_matrix;

in vec2 tcUV[];
in vec3 tcPosition[];
out vec3 tePosition;
out vec2 uv;
out float height;

void main(){
  vec3 a = mix(tcPosition[0], tcPosition[3], gl_TessCoord.x);
  vec3 b = mix(tcPosition[1], tcPosition[2], gl_TessCoord.x);
  vec2 u = mix(tcUV[0], tcUV[3], gl_TessCoord.x);
  vec2 v = mix(tcUV[1], tcUV[2], gl_TessCoord.x);
  tePosition = mix(a, b, gl_TessCoord.y);
  uv = mix(u, v, gl_TessCoord.y);
  height = texture(heightmap, uv).r;
  tePosition.y += height;
  gl_Position = transform_matrix * vec4(tePosition, 1);
}")

(define-class-shader (wave :fragment-shader)
  "
in float height;
out vec4 color;
void main(){
  maybe_call_next_method();
  color = vec4(vec3(min(1,1+height)), abs(height/5));
}")

(define-asset (kandria logo-rect) mesh
    (make-rectangle-mesh 400 100))

(define-shader-entity logo (listener textured-entity vertex-entity located-entity)
  ((vertex-array :initform (// 'kandria 'logo-rect))
   (texture :initform (// 'kandria 'logo))
   (clock :initform 0.0 :accessor clock)
   (previous-depth :initform 0.0 :accessor previous-depth))
  (:inhibit-shaders (textured-entity :fragment-shader)))

(defmethod handle ((ev tick) (logo logo))
  (incf (clock logo) (dt ev)))

(defmethod render :before ((logo logo) (program shader-program))
  (let* ((tt (clock logo))
         (depth (float (* (expt (- (rem tt 3.0) 1.0) 4.0)
                          (max 0.0 (/ (+ (sin (* PI tt)) (sin (* 13 tt))) 2.0)))
                       0f0)))
    (setf (uniform program "clock") (float (/ tt 10) 0f0))
    (setf (uniform program "max_attempts") (1+ (logand #x5 (sxhash (floor (* 3 tt))))))
    (cond ((< (previous-depth logo) depth)
           (setf (uniform program "depth") depth)
           (setf (previous-depth logo) depth))
          ((<= depth 0)
           (setf (uniform program "depth") depth)
           (setf (previous-depth logo) depth)))))

(define-class-shader (logo :fragment-shader)
  "
#define PI 3.1415926538
uniform sampler2D texture_image;
uniform int max_attempts = 3;
uniform float depth = 1.0;
uniform float clock = 0.0;
const vec2 tex_dx = vec2(1.0/128.0, 1.0/128.0);

in vec2 uv;
out vec4 color;

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main(){
  maybe_call_next_method();
  float x = floor((uv.x-1)*300);
  vec2 offset = uv;
  color = vec4(0);
  float r = rand(vec2(x,clock/10000.0));
  for(int i=0; i<max_attempts; ++i){
    offset.y -= tex_dx.y*r*depth;
    vec4 local = texture(texture_image, offset);
    if(0 < local.a){
      color = vec4(local.rgb*5, local.a);
      break;
    }
  }
}")

(defmethod stage :after ((menu main-menu) (area staging-area))
  (stage (// 'music 'menu) area)
  (stage (// 'music 'credits) area))

(defmethod show :after ((menu main-menu) &key)
  (let* ((camera (camera +world+))
         (tsize (target-size camera))
         (yspread (/ (vy tsize) 1.5)))
    (setf (lighting (node 'lighting-pass +world+)) (gi 'one))
    (setf (override (node 'environment +world+)) (// 'music 'menu))
    (trial:commit (make-instance 'star) (loader +main+) :unload NIL)
    (trial:commit (stage (make-instance 'star) (node 'render +world+)) (loader +main+) :unload NIL)
    (enter-and-load (make-instance 'fullscreen-background) +world+ +main+)
    (enter-and-load (make-instance 'logo :location (vec 0 80)) +world+ +main+)
    ;; Only enter the wave if we have tesselation available.
    (when-gl-extension :GL-ARB-TESSELLATION-SHADER
      (enter-and-load (make-instance 'wave) +world+ +main+))
    (dotimes (i 100)
      (let ((s (+ 8 (* 20 (/ (expt (random 10.0) 3) 1000.0)))))
        (enter (make-instance 'star
                              :bsize (vec s s)
                              :location (vec (random* 0 (* 2 (vx tsize)))
                                             (- (vy tsize) 10 (* yspread (/ (expt (random 10.0) 3) 1000.0)))))
               +world+))))
  ;; Show prompt to try and resume from report save file.
  (let ((report (find "report" (list-saves) :key (lambda (s) (pathname-name (file s))) :test #'string=)))
    (when report
      (show (make-instance 'prompt-panel
                           :text (@ recover-crashed-save)
                           :on-accept (lambda () (ignore-errors (rename-file (file report) (make-pathname :name "4" :defaults (file report)))))
                           :on-cancel (lambda () (ignore-errors (delete-file (file report)))))
            :width (alloy:un 500)
            :height (alloy:un 300)))))

(defmethod hide :after ((menu main-menu))
  (setf (override (node 'environment +world+)) NIL)
  (for:for ((entity over +world+)
            (garbage when (typep entity '(or star fullscreen-background logo wave)) collect entity))
    (returning (dolist (entity garbage) (leave entity T)))))

(defun return-to-main-menu ()
  (let ((state (state +main+))
        (player (node 'player +world+))
        (pauser (make-instance 'listener)))
    (clear +editor-history+)
    (pause-game +world+ pauser)
    (reset (node 'environment +world+))
    (promise:with-promise (succeed)
      (transition
        :kind :black
        #+kandria-release
        (when (and state player (setting :debugging :send-diagnostics))
          (submit-trace state player)
          (setf state NIL player NIL))
        (unpause-game +world+ pauser)
        (reset +main+)
        (funcall succeed)))))
