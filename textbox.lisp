(in-package #:org.shirakumo.fraf.leaf)

(define-asset (leaf textbox) mesh
    (make-rectangle 200 25 :align :topleft
                           :mesh (make-rectangle 750 125 :align :topleft)))

(define-asset (leaf profile-mesh) mesh
    (make-rectangle 128 128 :align :topleft))

(define-asset (leaf text) font
    #p"Xolonium-Regular.ttf"
  :size 42)

(defclass profile-entity (entity)
  ((profile-title :initarg :profile-title :accessor profile-title)
   (profile-texture :initarg :profile-texture :accessor profile-texture)
   (profile-animations :initarg :profile-animations :accessor profile-animations)))

(define-shader-subject profile (animated-sprite-subject)
  ((profile :initform NIL :accessor profile)
   (emote :initform NIL :accessor emote)
   (vertex-array :initform (asset 'leaf 'profile-mesh))
   (next-blink :initform NIL :accessor next-blink))
  (:default-initargs :size (vec 128 128)
                     :animations '((none 0 1))
                     :texture (make-instance 'texture :width 0 :height 0
                                                      :pixel-format :rgba)))

(defmethod (setf profile) :after ((entity profile-entity) (profile profile))
  (setf (texture profile) (profile-texture entity))
  (setf (animations profile) (profile-animations entity))
  (setf (next-blink profile) NIL)
  entity)

(defmethod (setf emote) :after ((name symbol) (profile profile))
  (setf (animation profile) name))

(define-handler (profile tick trial:tick) (ev tt)
  (cond ((null (next-blink profile))
         (setf (next-blink profile) (+ tt 1.0 (random 5.0))))
        ((< (next-blink profile) tt)
         (setf (animation profile) (1+ (position (animation profile) (animations profile))))
         (setf (next-blink profile) (+ tt 1.0 (random 5.0))))))

(define-shader-subject textbox (vertex-entity)
  ((flare:name :initform :textbox)
   (vertex-array :initform (asset 'leaf 'textbox))
   (profile :initform (make-instance 'profile) :reader profile)
   (paragraph :initform (make-instance 'text :font (asset 'leaf 'text)
                                             :size 18 :width 710 :wrap T
                                             :color (vec 1 1 1 1) :text "") :reader paragraph)
   (title :initform (make-instance 'text :font (asset 'leaf 'text)
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

(when *context*
  (with-context (*context*)
    (setf (current-dialog (unit :textbox +level+))
          (dialogue:compile* "
~ :player
| Ayyyy---(:happy) man 
| (:skeptical)So what's all this here?
| Some kinda--.--.(:grin)--. clown show?"))))

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
          (write-string (dialogue:text request) stream)))
  (setf (cursor textbox) (cursor textbox)))

(defmethod handle-request ((request dialogue:source-request) (textbox textbox))
  ;; FIXME: handle proper profile, etc.
  (let ((unit (unit (dialogue:name request) +level+)))
    (unless unit
      (error "No unit named ~s found!" (dialogue:name request)))
    (setf (text (title textbox)) (profile-title unit))
    (setf (profile (profile textbox)) unit)))

(defmethod handle-request ((request dialogue:choice-request) (textbox textbox))
  (setf (choice textbox) 0)
  (setf (text textbox) (with-output-to-string (stream)
                         (loop for i from 0
                               for label in (dialogue:choices request)
                               do (format stream "~:[-~;>~] ~a~%" (= i (choice textbox)) label)))))

(defmethod handle-request ((request dialogue:end-request) (textbox textbox))
  (setf (current-dialog textbox) NIL))

(defmethod fulfilled-p ((request dialogue:input-request) (textbox textbox)) NIL)

(defmethod fulfilled-p ((request dialogue:text-request) (textbox textbox))
  (<= (length (text textbox)) (cursor textbox)))

(defmethod fulfilled-p ((request dialogue:pause-request) (textbox textbox))
  (and (call-next-method)
       (<= (dialogue:duration request) (clock textbox))))

(defmethod fulfilled-p ((request dialogue:source-request) (textbox textbox))
  T)

(defmethod fulfilled-p ((request dialogue:emote-request) (textbox textbox))
  (when (call-next-method)
    (setf (emote (profile textbox)) (dialogue:emote request))
    T))

(define-handler (textbox next) (ev)
  (when (typep (request textbox) 'dialogue:choice-request)
    (setf (choice textbox) (mod (1+ (choice textbox)) (length (dialogue:choices (request textbox)))))
    (setf (text (paragraph textbox))
          (with-output-to-string (stream)
            (loop for i from 0
                  for label in (dialogue:choices (request textbox))
                  do (format stream "~:[-~;>~] ~a~%" (= i (choice textbox)) label))))))

(define-handler (textbox previous) (ev)
  (when (typep (request textbox) 'dialogue:choice-request)
    (setf (choice textbox) (mod (1- (choice textbox)) (length (dialogue:choices (request textbox)))))
    (setf (text (paragraph textbox))
          (with-output-to-string (stream)
            (loop for i from 0
                  for label in (dialogue:choices (request textbox))
                  do (format stream "~:[-~;>~] ~a~%" (= i (choice textbox)) label))))))

(define-handler (textbox skip) (ev)
  )

(define-handler (textbox advance) (ev)
  (when (request textbox)
    (unless (typep (request textbox) 'dialogue:input-request)
      (loop until (typep (request textbox) 'dialogue:input-request)
            do (setf (cursor textbox) (length (text textbox)))
               (fulfilled-p (request textbox) textbox)
               (advance textbox)))
    (cond ((<= (length (text textbox)) (cursor textbox))
           (setf (text textbox) "")
           (if (typep (request textbox) 'dialogue:choice-request)
               (advance textbox (elt (dialogue:targets (request textbox)) (choice textbox)))
               (advance textbox)))
          (T
           (setf (cursor textbox) (length (text textbox)))))))

(define-handler (textbox trial:tick) (ev dt)
  (when (request textbox)
    (handle ev (profile textbox))
    (incf (clock textbox) dt)
    ;; FIXME: Configurable text speed
    (when (fulfilled-p (request textbox) textbox)
      (advance textbox))
    (when (and (< (cursor textbox) (length (text textbox)))
               (< .03 (clock textbox)))
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
        (with-pushed-matrix ((*model-matrix* :identity))
          (cond ((eql :player (name (profile (profile textbox))))
                 (translate-by 0 586 5)
                 (scale-by 3 3 1))
                (T
                 (translate-by 1000 618 5)
                 (scale-by -3 3 1)))
          (paint (profile textbox) target))
        (translate-by 25 146 0)
        (call-next-method)
        (translate-by 10 -18 0)
        (paint (title textbox) target)
        (translate-by 10 -24 0)
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
