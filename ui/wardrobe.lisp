(in-package #:org.shirakumo.fraf.kandria)

(defclass palette-button (alloy:direct-value-component alloy:button)
  ((target :initarg :target :accessor target)))

(defmethod alloy:text ((button palette-button))
  (title (alloy:value button)))

(defmethod (setf alloy:focus) :after (focus (button palette-button))
  (when focus
    (setf (palette-index (target button)) (palette-index (alloy:value button)))))

(defmethod alloy:activate ((button palette-button))
  (harmony:play (// 'sound 'ui-confirm))
  (alloy:do-elements (button (alloy:focus-parent button))
    (alloy:refresh button))
  (setf (palette-index (node 'player T)) (palette-index (alloy:value button))))

(presentations:define-realization (ui palette-button)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:label simple:text)
   (alloy:margins 5)
   alloy:text
   :size (alloy:un 15)
   :font (setting :display :font)
   :pattern colors:white
   :valign :middle
   :halign :start)
  ((:current-bg simple:polygon)
   (list (alloy:point (alloy:pw 1.0) (alloy:ph 0.2))
         (alloy:point (alloy:pw 0.7) (alloy:ph 0.2))
         (alloy:point (alloy:pw 0.7) (alloy:ph 0.4))
         (alloy:point (alloy:pw 0.68) (alloy:ph 0.5))
         (alloy:point (alloy:pw 0.7) (alloy:ph 0.6))
         (alloy:point (alloy:pw 0.7) (alloy:ph 0.8))
         (alloy:point (alloy:pw 1.0) (alloy:ph 0.8)))
   :pattern colors:red
   :hidden-p (not (eql (palette-index (node 'player T)) (palette-index alloy:value))))
  ((:current-text simple:text)
   (alloy:extent (alloy:pw 0.72) (alloy:ph 0.3) (alloy:pw 0.3) (alloy:ph 0.4))
   (@ current-outfit-selection)
   :size (alloy:un 12)
   :font (setting :display :font)
   :pattern colors:white
   :valign :middle
   :halign :start
   :hidden-p (not (eql (palette-index (node 'player T)) (palette-index alloy:value)))))

(presentations:define-update (ui palette-button)
  (:background
   :pattern (if alloy:focus colors:white colors:black))
  (:label
   :pattern (if alloy:focus colors:black colors:white))
  (:current-bg
   :hidden-p (not (eql (palette-index (node 'player T)) (palette-index alloy:value))))
  (:current-text
   :hidden-p (not (eql (palette-index (node 'player T)) (palette-index alloy:value)))))

(define-shader-entity sprite-preview (alloy:renderable alloy:layout-element standalone-shader-entity)
  ((target :initarg :target :accessor target)))

(defmethod alloy:render-needed-p ((preview sprite-preview)) T)

(defmethod alloy:render ((ui ui) (preview sprite-preview))
  (call-next-method)
  (with-pushed-matrix ((view-matrix :identity)
                       (model-matrix :identity))
    (let* ((program (shader-program preview))
           (bounds (alloy:bounds preview))
           (scale (/ (alloy:pxh bounds) 2 (* 2 (vy (bsize (target preview)))))))
      (translate-by (+ (alloy:pxx bounds) (/ (alloy:pxw bounds) 2))
                    (- (+ (alloy:pxy bounds) (/ (alloy:pxh bounds) 2))
                       (* (vy (bsize (target preview))) scale))
                    0)
      (scale-by scale scale 1)
      (trial::activate program)
      (bind-textures (target preview))
      (render (target preview) program))))

(define-class-shader (sprite-preview :vertex-shader)
  "
layout(location = TRIAL_V_LOCATION) in vec3 position;
layout(location = TRIAL_V_UV) in vec2 in_uv;
out vec2 uv;

uniform mat4 model_matrix;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

void main(){
  uv = in_uv;
  gl_Position = (projection_matrix * (view_matrix * (model_matrix * vec4(position, 1.0))));
}")

(define-class-shader (sprite-preview :fragment-shader)
  "
uniform sampler2D texture_image;
uniform sampler2D palette;
uniform int palette_index = 0;
in vec2 uv;

void main(){
  color = texture(texture_image, uv);
  if(color.r*color.b == 1 && color.g < 0.1){
    color = texelFetch(palette, ivec2(color.g*255, palette_index), 0);
  }
  if(color.a == 0) discard;
}")

(defclass wardrobe (pausing-panel menuing-panel)
  ())

(defmethod initialize-instance :after ((panel wardrobe) &key)
  (let* ((layout (make-instance 'eating-constraint-layout
                                :shapes (list (make-basic-background))))
         (clipper (make-instance 'alloy:clip-view :limit :x))
         (scroll (alloy:represent-with 'alloy:y-scrollbar clipper))
         (preview (make-instance 'sprite-preview :target (clone (node 'player T))
                                 :shapes (list (simple:rectangle (node 'ui-pass T) (alloy:margins) :pattern colors:black))))
         (focus (make-instance 'alloy:focus-stack :orientation :horizontal))
         (list (make-instance 'alloy:vertical-linear-layout
                              :shapes (list (simple:rectangle (node 'ui-pass T) (alloy:margins) :pattern (colored:color 0 0 0 0.5)))
                              :min-size (alloy:size 100 50))))
    (alloy:enter list clipper)
    (alloy:enter preview layout :constraints `((:left 50) (:right 570) (:bottom 100) (:top 100)))
    (alloy:enter clipper layout :constraints `((:width 500) (:right 70) (:bottom 100) (:top 100)))
    (alloy:enter scroll layout :constraints `((:width 20) (:right 50) (:bottom 100) (:top 100)))
    (alloy:enter (make-instance 'label :value (@ wardrobe-title)) layout :constraints `((:left 50) (:above ,clipper 10) (:size 500 50)))
    (loop for palette in (unlocked-palettes (node 'player T))
          for button = (make-instance 'palette-button :value palette :target (target preview) :layout-parent list)
          do (alloy:enter button focus :layer 1)
             (when (eql (palette-index palette) (palette-index (node 'player T)))
               (setf (alloy:focus button) :weak)))
    (let ((back (alloy:represent (@ go-backwards-in-ui) 'button)))
      (alloy:enter back layout :constraints `((:left 50) (:below ,clipper 10) (:size 200 50)))
      (alloy:enter back focus :layer 0)
      (alloy:on alloy:activate (back)
        (hide panel))
      (alloy:on alloy:exit (focus)
        (setf (alloy:focus focus) :strong)
        (setf (alloy:focus back) :weak)))
    (alloy:finish-structure panel layout focus)))
