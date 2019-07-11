(in-package #:org.shirakumo.fraf.leaf)

(define-asset (leaf textbox) mesh
    (make-rectangle 200 25 :align :topleft :y 15 :x 0
                           :mesh (make-rectangle 750 100 :align :topleft)))

(define-asset (leaf profile-mesh) mesh
    (make-rectangle 128 128 :align :topleft))

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
   (title :initform (make-instance 'text :font (asset 'trial 'prompt-font)
                                         :size 22 :color (vec 0 0 0 1) :text "") :reader title)
   (clock :initform 0.0 :accessor clock)
   (cursor :initform 0 :accessor cursor)
   (choice :initform 0 :accessor choice)
   (request :initform NIL :accessor request)
   (vm :initform NIL :accessor vm)))

(defmethod register-object-for-pass :after (pass (textbox textbox))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'profile)))
  (register-object-for-pass pass (maybe-finalize-inheritance (find-class 'text))))

(defmethod text ((textbox textbox))
  (text (paragraph textbox)))

(defmethod (setf text) (string (textbox textbox))
  (setf (text (paragraph textbox)) string)
  (setf (cursor textbox) 0))

(defmethod (setf cursor) :around (index (textbox textbox))
  (call-next-method (min index (length (text textbox))) textbox))

(defmethod (setf cursor) :after (index (textbox textbox))
  (setf (size (vertex-array (paragraph textbox))) (* 6 index)))

(defmethod trial:tile ((textbox textbox))
  (trial:tile (profile textbox)))

;; (defmethod (setf target) :after ((entity dialog-entity) (textbox textbox))
;;   (setf (text (title textbox)) (string-capitalize (name entity)))
;;   (setf (texture (profile textbox)) (profile entity))
;;   (setf (vx (trial:tile (profile textbox))) 0))

(defmethod (setf current-dialog) ((assembly dialogue:assembly) (textbox textbox))
  (pause-game T textbox)
  (setf (vm textbox) (dialogue:run assembly T))
  (setf (request textbox) NIL)
  (advance textbox 0))

(defmethod (setf current-dialog) ((null null) (textbox textbox))
  (setf (vm textbox) NIL)
  (setf (request textbox) NIL)
  (setf (text textbox) "")
  (unpause-game T textbox))

#+ ()
(with-context (*context*)
  (setf (current-dialog (unit :textbox +level+))
        (dialogue:compile* "! label start
- foo
  | woah!
- bar
  | weuh
- baz
  | eachu?
< start")))

(defmethod advance ((textbox textbox) &optional ip)
  (let* ((ip (or ip (dialogue:target (request textbox))))
         (request (dialogue:resume (vm textbox) ip)))
    (setf (request textbox) request)
    (handle-request request textbox)))

(defmethod handle-request ((request dialogue:text-request) (textbox textbox))
  ;; FIXME: handle markup
  (setf (text (paragraph textbox))
        (with-output-to-string (stream)
          (write-string (text (paragraph textbox)) stream)
          (write-string (dialogue:text request) stream))))

(defmethod handle-request ((request dialogue:source-request) (textbox textbox))
  ;; FIXME: handle proper profile, etc.
  (setf (text (title textbox)) (dialogue:text request)))

(defmethod handle-request ((request dialogue:choice-request) (textbox textbox))
  (setf (choice textbox) 0)
  (setf (text textbox) (format NIL "~{- ~a~^~%~}" (dialogue:choices request))))

(defmethod handle-request ((request dialogue:end-request) (textbox textbox))
  (setf (current-dialog textbox) NIL))

(defmethod fulfilled-p ((request dialogue:input-request) (textbox textbox)) NIL)

(defmethod fulfilled-p ((request dialogue:text-request) (textbox textbox))
  (<= (length (text textbox)) (cursor textbox)))

(defmethod fulfilled-p ((request dialogue:pause-request) (textbox textbox))
  (and (call-next-method)
       (<= (dialogue:duration request) (clock textbox))))

(defmethod fulfilled-p ((request dialogue:emote-request) (textbox textbox))
  (when (call-next-method)
    (setf (emote textbox) (dialogue:emote request))
    T))

(define-handler (textbox next) (ev)
  (incf (choice textbox)))

(define-handler (textbox previous) (ev)
  (setf (choice textbox) (max 0 (1- (choice textbox)))))

(define-handler (textbox skip) (ev)
  )

(define-handler (textbox advance) (ev)
  (let ((request (request textbox)))
    (when request
      (unless (typep request 'dialogue:input-request)
        (loop until (typep request 'dialogue:input-request)
              do (advance textbox)))
      (cond ((<= (length (text textbox)) (cursor textbox))
             (setf (text textbox) "")
             (if (typep request 'dialogue:choice-request)
                 (advance textbox (elt (dialogue:targets request) (choice textbox)))
                 (advance textbox)))
            (T
             (setf (cursor textbox) (length (text textbox))))))))

(define-handler (textbox trial:tick) (ev dt)
  (when (request textbox)
    (incf (clock textbox) dt)
    ;; FIXME: Configurable text speed
    (when (fulfilled-p (request textbox) textbox)
      (advance textbox))
    (when (and (< (cursor textbox) (length (text textbox)))
               (< .02 (clock textbox)))
      (setf (clock textbox) 0)
      (incf (cursor textbox)))))

(defmethod paint :around ((textbox textbox) target)
  (when (vm textbox)
    (with-pushed-matrix ((*model-matrix* :identity)
                         (*view-matrix* :identity))
      (let ((s (/ (width *context*) 800)))
        (scale-by s s 1)
        (when (< 0 (shake-counter (unit :camera T)))
          (translate (vxy_ (vrand -3 +3))))
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
