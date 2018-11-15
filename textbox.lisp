(in-package #:org.shirakumo.fraf.leaf)

(define-asset (leaf textbox) mesh
    (make-rectangle 200 25 :align :bottomleft :y 15 :x 0
                           :mesh (make-rectangle 750 100 :align :bottomleft)))

(define-asset (leaf profile-mesh) mesh
    (make-rectangle 128 128 :align :bottomleft))

(define-asset (leaf text) font
    #p"Kemco Pixel Bold.ttf"
  :size 42)

(define-shader-entity profile (sprite-entity)
  ((vertex-array :initform (asset 'leaf 'profile-mesh)))
  (:default-initargs :size (vec 512 512)
                     :texture (asset 'leaf 'profile)))

(define-shader-subject textbox (vertex-entity)
  ((flare:name :initform :textbox)
   (vertex-array :initform (asset 'leaf 'textbox))
   (profile :initform (make-instance 'profile) :reader profile)
   (paragraph :initform (make-instance 'text :font (asset 'leaf 'text)
                                             :size 18 :width 710 :wrap T
                                             :color (vec 1 1 1 1) :text "") :reader paragraph)
   (title :initform (make-instance 'text :font (asset 'leaf 'text)
                                         :size 22 :color (vec 0 0 0 1) :text "Test") :reader title)
   (target :initarg :target :accessor target) 
   (start-time :initform 0.0 :accessor start-time)
   (true-size :initform 0 :accessor true-size)
   (current-dialog :initform NIL :accessor current-dialog)
   (dialog-index :initform 0 :accessor dialog-index)))

(defmethod register-object-for-pass :after (pass (textbox textbox))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'profile)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'text))))

(defmethod text ((textbox textbox))
  (text (paragraph textbox)))

(defmethod (setf text) (string (textbox textbox))
  (setf (text (paragraph textbox)) string)
  (shiftf (true-size textbox) (size (vertex-array (paragraph textbox))) 0)
  (setf (start-time textbox) 0))

(defmethod trial:tile ((textbox textbox))
  (trial:tile (profile textbox)))

(defmethod (setf target) :after ((entity dialog-entity) (textbox textbox))
  (setf (text (title textbox)) (string-capitalize (name entity)))
  (setf (texture (profile textbox)) (profile entity))
  (setf (vx (trial:tile (profile textbox))) 0))

(defmethod (setf current-dialog) :after ((dialog dialog) (textbox textbox))
  (pause (handler *context*))
  (setf (dialog-index textbox) -1)
  (advance textbox))

(defmethod (setf current-dialog) :after ((null null) (textbox textbox))
  (unpause (handler *context*)))

(defmethod advance ((textbox textbox))
  (when (current-dialog textbox)
    (catch 'stop
      (loop for (fun . args) = (dialog (incf (dialog-index textbox)) (current-dialog textbox))
            while fun
            do (apply (dialog-function fun) textbox args)))))

(define-handler (textbox skip) (ev)
  (setf (size (vertex-array (paragraph textbox)))
        (true-size textbox)))

(define-handler (textbox next) (ev)
  (when (= (size (vertex-array (paragraph textbox)))
           (true-size textbox))
    (advance textbox)))

(define-handler (textbox trial:tick) (ev tt)
  (when (= 0 (start-time textbox)) (setf (start-time textbox) tt))
  (setf (size (vertex-array (paragraph textbox)))
        (min (* 6 (floor (* 30 (- tt (start-time textbox)))))
             (true-size textbox))))

(define-handler (textbox check-storyline event) (ev)
  
  (let ((diags (compute-applicable-dialogs ev T)))
    (cond ((cdr diags)
           (error "FIXME: Menu for multiple dialogs"))
          (diags
           (setf (current-dialog textbox) (first diags))))))

(defmethod paint :around ((textbox textbox) target)
  (when (current-dialog textbox)
    (with-pushed-matrix ((*model-matrix* :identity)
                         (*view-matrix* :identity))
      (let ((s (/ (width *context*) 800)))
        (scale-by s s 1)
        (translate-by 500 (+ 256 128) 5)
        (scale-by 2 2 1)
        (paint (profile textbox) target)
        (scale-by 1/2 1/2 1)
        (translate-by -475 -256 0)
        (call-next-method)
        (translate-by 10 -5 0)
        (paint (title textbox) target)
        (translate-by 10 -22 0)
        (with-pushed-attribs
          (enable :scissor-test)
          (gl:scissor (* s 40) (* s 40) (* s 720) (* s 80))
          (paint (paragraph textbox) target))))))

(define-class-shader (textbox :vertex-shader)
  "out vec4 vcolor;

void main(){
  vcolor = (gl_VertexID < 6)? vec4(0,0,0,1): vec4(1,0.9,0,1);
}")

(define-class-shader (textbox :fragment-shader)
  "out vec4 color;
in vec4 vcolor;

void main(){
  color = vcolor;
}")
