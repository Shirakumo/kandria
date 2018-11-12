(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity profile (sprite-entity)
  ((vertex-array :initform (asset 'leaf 'profile-mesh)))
  (:default-initargs :size (vec 256 256)
                     :texture (asset 'leaf 'profile)))

(define-asset (leaf textbox) mesh
    (make-rectangle 750 100 :align :bottomleft))

(define-asset (leaf profile-mesh) mesh
    (make-rectangle 128 128 :align :bottomleft))

(define-asset (leaf text) font
    #p"Kemco Pixel Bold.ttf"
  :size 42)

(define-shader-subject textbox (vertex-entity)
  ((flare:name :initform :textbox)
   (vertex-array :initform (asset 'leaf 'textbox))
   (profile :initform (make-instance 'profile) :reader profile)
   (paragraph :initform (make-instance 'text :font (asset 'leaf 'text)
                                             :size 18 :width 710 :wrap T
                                             :color (vec 1 1 1 1) :text "") :reader paragraph)
   (start-time :initform 0.0 :accessor start-time)
   (true-size :initform 0 :accessor true-size)))

(defmethod register-object-for-pass :after (pass (textbox textbox))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'profile)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'text))))

(defmethod (setf text) (string (textbox textbox))
  (setf (text (paragraph textbox)) string)
  (shiftf (true-size textbox) (size (vertex-array (paragraph textbox))) 0)
  (setf (start-time textbox) 0))

(defmethod paint :around ((textbox textbox) target)
  (with-pushed-matrix ((*model-matrix* :identity)
                       (*view-matrix* :identity))
    (let ((s (/ (width *context*) 800)))
      (scale-by s s 1)
      (translate-by 25 (+ 256 128) 5)
      (scale-by 2 2 1)
      (paint (profile textbox) target)
      (scale-by 1/2 1/2 1)
      (translate-by 0 -256 0)
      (call-next-method)
      (translate-by 20 -32 0)
      (with-pushed-attribs
        (enable :scissor-test)
        (gl:scissor (* s 40) (* s 40) (* s 720) (* s 80))
        (paint (paragraph textbox) target)))))

(with-context (*context*)
  (setf (text (unit :textbox T)) "Oh boy, this sure is a dialogue box."))

(define-handler (textbox trial:tick) (ev tt)
  (when (= 0 (start-time textbox)) (setf (start-time textbox) tt))
  (setf (size (vertex-array (paragraph textbox)))
        (min (* 6 (floor (* 30 (- tt (start-time textbox)))))
             (true-size textbox))))

(define-class-shader (textbox :fragment-shader)
  "out vec4 color;

void main(){
  color.rgb *= 0;
}")
