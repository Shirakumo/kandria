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

(define-shader-pass pixelfont (textured-entity simple-post-effect-pass)
  ((texture :initform (// 'leaf 'pixelfont))))

(defmethod handle ((event event) (font pixelfont)))

(define-class-shader (pixelfont :fragment-shader)
  "uniform sampler2D pixelfont;
uniform sampler2D previous_pass;
in vec2 tex_coord;
out vec4 color;

void main(){
  ivec2 xy = ivec2(mod(gl_FragCoord.xy, 70));
  float r = texelFetch(pixelfont, xy, 0).r;
  color = vec4(r,r,r,1);
}")
