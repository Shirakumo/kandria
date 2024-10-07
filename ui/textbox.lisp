(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity profile-picture (trial:animated-sprite standalone-shader-entity alloy:layout-element)
  ((strength :initform 0.0 :accessor strength))
  (:default-initargs :sprite-data (asset 'kandria 'player-profile)))

(defmethod alloy:render ((pass ui-pass) (picture profile-picture))
  (let ((extent (alloy:bounds picture)))
    (with-pushed-matrix ((view-matrix :identity)
                         (model-matrix :identity))
      (translate-by (alloy:pxx extent) (alloy:pxy extent) -1000)
      (scale-by (/ (alloy:pxw extent) 1024) (/ (alloy:pxh extent) 1024) 1)
      (translate-by 256 0 0)
      (bind-textures picture)
      (render picture NIL))))

(defmethod render :before ((picture profile-picture) (program shader-program))
  (setf (uniform program "clock") (* 0.3 (truncate (* 30 (clock +world+)))))
  (setf (uniform program "fuzz") (strength picture)))

(define-class-shader (profile-picture :fragment-shader)
  "uniform float fuzz = 1.0;
uniform float clock = 0.0;
out vec4 color;

float rand(vec2 co){
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(co.xy ,vec2(a,b));
    float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

void main(){
  maybe_call_next_method();
  float rng = rand(uv * clock);
  float gray = rng * color.r + 0.71 * color.g + 0.07 * color.b;
  color.rgb = mix(color.rgb, vec3(gray), fuzz);

  float line = min(1.0, max(0.0, 100.0*(0.25+rng)+sin(uv.y*10+clock*0.1)*100.0));
  color.a = mix(color.a, color.a*line, fuzz);
}")

(defclass nametag (alloy:label) ())

(presentations:define-realization (ui nametag)
  ((:bord simple:rectangle)
   (alloy:extent 0 0 (alloy:pw 1) 2)
   :pattern colors:white)
  ((:label simple:text)
   (alloy:margins 10 -10 10 -10)
   alloy:text
   :valign :middle
   :font (setting :display :font)
   :size (alloy:un 20)
   :pattern colors:white
   :markup '((0 100 (:outline 1.0)))))

(defclass advance-prompt (alloy:label) ())

(presentations:define-realization (ui advance-prompt)
  ((bg simple:rectangle)
   (alloy:margins)
   :pattern colors:accent)
  ((:bord simple:rectangle)
   (alloy:extent 0 0 (alloy:pw 1) 1)
   :pattern colors:white)
  ((:label simple:text)
   (alloy:margins 1)
   (prompt-string :right :bank :keyboard)
   :valign :middle
   :halign :right
   :font "PromptFont"
   :size (alloy:ph 0.8)
   :pattern colors:white))

(presentations:define-update (ui advance-prompt)
  (bg
   :bounds (alloy:margins 0 0
                          (alloy:pw (case alloy:value
                                      ((T NIL) 1.0)
                                      (T (clamp 0.0
                                                (/ alloy:value (max 0.01 (setting :gameplay :auto-advance-after)))
                                                1.0))))
                          0))
  (:label
   :text (prompt-string :right :bank :keyboard)
   :hidden-p (null alloy:value)))

(defclass dialog-choice (alloy:button) ())

(presentations:define-realization (ui dialog-choice)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:indicator simple:rectangle)
   (alloy:extent 0 0 10 (alloy:ph))
   :pattern (colored:color 0 0 0 0))
  ((:label simple:text)
   (alloy:margins 5)
   alloy:text
   :valign :middle
   :halign :left
   :wrap T
   :font (setting :display :font)
   :size (alloy:un 20)
   :pattern colors:white))

(presentations:define-update (ui dialog-choice)
  (:label
   :wrap T
   :pattern colors:white
   :offset (alloy:point (if alloy:focus 10 0) 0))
  (:indicator
   :pattern (if alloy:focus
              colors:white
              colors:transparent))
  (:background
   :pattern (case alloy:focus
              (:strong (colored:color 0.3 0.3 0.3))
              (:weak (colored:color 0.1 0.1 0.1))
              (T colors:black))))

(presentations:define-animated-shapes dialog-choice
  (:label (presentations:offset :duration 0.2))
  (:indicator (simple:pattern :duration 0.2))
  (:background (simple:pattern :duration 0.2)))

(defclass dialog-choice-list (alloy:vertical-linear-layout alloy:vertical-focus-list)
  ((alloy:cell-margins :initform (alloy:margins 0))
   (alloy:min-size :initform (alloy:size 35 35))))

(presentations:define-realization (ui dialog-choice-list)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0 0 0.8)))

(defmethod alloy:exit ((list dialog-choice-list))
  (when (< 0 (alloy:element-count list))
    (let ((el (alloy:index-element (1- (alloy:element-count list)) list)))
      (setf (alloy:focus el) :weak))))

(defun clear-text-string ()
  (load-time-value (make-array 0 :element-type 'character)))

(defclass textbox (alloy:observable-object)
  ((vm :initform (make-instance 'dialogue:vm) :reader vm)
   (ip :initform 0 :accessor ip)
   (char-timer :initform 0.1 :accessor char-timer)
   (pause-timer :initform 0 :accessor pause-timer)
   (choices :initform (make-instance 'dialog-choice-list) :reader choices)
   (prompt :initform NIL :accessor prompt)
   (text :initform (clear-text-string) :accessor text)
   (source :initform 'player :accessor source)
   (pending :initform NIL :accessor pending)
   (profile :initform (make-instance 'profile-picture) :accessor profile)
   (scroll-index :initform 0 :accessor scroll-index)
   (textbox :accessor textbox)))

(defmethod hide :before ((textbox textbox))
  (harmony:stop (// 'sound 'ui-scroll-dialogue)))

(defmethod at-end-p ((textbox textbox))
  (<= (length (text textbox))
      (scroll-index textbox)))

(defun scroll-text (textbox &optional (to (1+ (scroll-index textbox))))
  (cond ((<= to (length (text textbox)))
         (harmony:play (// 'sound 'ui-scroll-dialogue))
         (setf (scroll-index textbox) to)
         (setf (org.shirakumo.alloy.renderers.opengl.msdf::vertex-count
                (presentations:find-shape :label (textbox textbox)))
               (* 6 to)))
        (T
         (harmony:stop (// 'sound 'ui-scroll-dialogue)))))

(defmethod advance ((textbox textbox))
  (restart-case
      (handler-bind (#+kandria-release (not-enough-in-inventory #'continue))
        (handle (dialogue:resume (vm textbox) (ip textbox)) textbox))
    (continue ()
      :report "Abort the interaction textbox."
      (hide textbox))))

(defmethod fast-forward ((textbox textbox))
  (loop for i from 0 to 1000 ; Safety to avoid infinite loops
        do (cond ((equal (pending textbox) '(:end))
                  (hide textbox)
                  (return))
                 ((/= 0 (alloy:element-count (choices textbox)))
                  ;; Pick last choice as it is usually the "nevermind" option.
                  (alloy:activate (alloy:index-element
                                   (1- (alloy:element-count (choices textbox)))
                                   (choices textbox))))
                 (T
                  (advance textbox)))
        finally (progn
                  (quest:complete (interaction textbox))
                  (hide textbox))))

(defmethod (setf choices) ((choices null) (textbox textbox))
  (alloy:clear (choices textbox)))

(defmethod (setf choices) ((choices cons) (textbox textbox))
  (alloy:clear (choices textbox))
  (loop for choice in (car choices)
        for target in (cdr choices)
        do (let* ((choice choice) (target target)
                  (button (alloy:represent choice 'dialog-choice)))
             (alloy:on alloy:activate (button)
               (setf (text textbox) (clear-text-string))
               (setf (prompt textbox) NIL)
               (setf (scroll-index textbox) 0)
               (setf (choices textbox) ())
               (harmony:play (// 'sound 'ui-advance-dialogue))
               (etypecase target
                 (integer
                  (setf (ip textbox) target))
                 (quest:interaction
                  (setf (interaction textbox) target)))
               (advance textbox))
             (alloy:enter button (choices textbox))))
  (setf (alloy:index (choices textbox)) 0)
  (when (active-p textbox)
    (setf (alloy:focus (choices textbox)) :strong))
  (let ((player (node 'player +world+)))
    (setf (source textbox) (nametag player))
    (setf (trial:sprite-data (profile textbox)) (profile-sprite-data player))
    (setf (animation (profile textbox)) 'normal))
  (setf (prompt textbox) T))

(defmethod handle ((ev tick) (textbox textbox))
  (handle ev (profile textbox))
  (cond ((and (at-end-p textbox)
              (not (prompt textbox)))
         (harmony:stop (// 'sound 'ui-scroll-dialogue))
         (cond ((< 0 (pause-timer textbox))
                (decf (pause-timer textbox) (dt ev)))
               ((pending textbox)
                (ecase (first (pending textbox))
                  (:emote
                   (handler-case
                       (setf (animation (profile textbox)) (second (pending textbox)))
                     (error ()
                       (v:warn :sound.dialog "Requested missing emote ~s" (second (pending textbox)))
                       (ignore-errors (setf (animation (profile textbox)) 'normal)))))
                  (:prompt
                   (if (eq (clear-text-string) (text textbox))
                       (setf (prompt textbox) NIL)
                       (setf (prompt textbox) (second (pending textbox)))))
                  (:end
                   (next-interaction textbox)))
                (setf (pending textbox) NIL))
               ((dialogue:instructions (vm textbox))
                (advance textbox))
               (T
                (next-interaction textbox))))
        ((at-end-p textbox)
         (when (numberp (prompt textbox))
           (decf (prompt textbox) (dt ev))
           (when (<= (prompt textbox) 0.0)
             (handle (make-instance 'advance) textbox)))
         (when (and (eq (clear-text-string) (text textbox))
                    (or (null (choices textbox))
                        (= 0 (alloy:element-count (choices textbox)))))
           (advance textbox)))
        ((< 0 (char-timer textbox))
         (decf (char-timer textbox) (dt ev)))
        ((< 0 (length (text textbox)))
         (unless (at-end-p textbox)
           (setf (char-timer textbox)
                 (* (setting :gameplay :text-speed)
                    (case (char (text textbox) (scroll-index textbox))
                      ((#\. #\! #\? #\: #\;) 7.5)
                      ((#\,) 2.5)
                      (T 1))))
           (when (<= (char-timer textbox) 0.0)
             (harmony:stop (// 'sound 'ui-scroll-dialogue))
             (scroll-text textbox (array-total-size (text textbox)))))
         (scroll-text textbox))))

(defmethod handle ((rq dialogue:request) (textbox textbox)))

(defmethod handle ((rq dialogue:end-request) (textbox textbox))
  (if (= 0 (ip textbox))
      (next-interaction textbox)
      (setf (pending textbox) (list :end))))

(defmethod handle ((rq dialogue:choice-request) (textbox textbox))
  (harmony:play (// 'sound 'ui-dialogue-choice))
  (setf (choices textbox) (cons (dialogue:choices rq)
                                (dialogue:targets rq))))

(defmethod handle ((rq dialogue:confirm-request) (textbox textbox))
  (setf (pending textbox) (list :prompt (if (setting :gameplay :auto-advance-dialog)
                                            (setting :gameplay :auto-advance-after)
                                            T))))

(defmethod handle ((rq dialogue:clear-request) (textbox textbox))
  (setf (text textbox) (clear-text-string))
  (setf (scroll-index textbox) 0))

(defmethod handle ((rq dialogue:source-request) (textbox textbox))
  (let ((unit (node (dialogue:name rq) T)))
    (cond (unit
           (setf (strength (profile textbox))
                 (clamp 0.0 (- (vdistance (location unit) (location (node 'player +world+))) (* 40 +tile-size+)) 1.0))
           (setf (mixed:speed-factor (harmony:segment 2 (// 'sound 'ui-scroll-dialogue))) (pitch unit))
           (setf (source textbox) (nametag unit))
           (setf (trial:sprite-data (profile textbox)) (profile-sprite-data unit))
           (setf (animation (profile textbox)) 'normal))
          (T
           (v:warn :kandria.dialogue "Couldn't find requested dialogue source: ~s" (dialogue:name rq))))))

(defmethod handle ((rq dialogue:emote-request) (textbox textbox))
  (setf (pending textbox) (list :emote (dialogue:emote rq))))

(defmethod handle ((rq dialogue:pause-request) (textbox textbox))
  (setf (pause-timer textbox) (dialogue:duration rq)))

(defun normalize-style (style)
  (case (car style)
    (:color
     (destructuring-bind (r g b &optional (a 1)) (second style)
       (list :color (colored:rgb (/ r 255) (/ g 255) (/ b 255) a))))
    (:underline
     (list :wave T))
    (:strikethrough
     (list :shake T))
    (:bold
     (list :rainbow T))
    (T style)))

(defun normalize-markup (markup &key (offset 0) (length most-positive-fixnum))
  (simple::sort-markup
   (loop for (start end . styles) in markup
         append (loop for style in styles
                      collect (list (+ start offset) (+ (or end length) offset)
                                    (normalize-style style))))))

(defun replace-swears (text)
  (let ((cycle 0)
        (rep (@ swear-replacement-characters)))
    (cl-ppcre:regex-replace-all (@ swears) text (lambda (string start end match-start match-end reg-starts reg-ends)
                                                  (declare (ignore string start end reg-starts reg-ends))
                                                  (map-into (make-string (- match-end match-start))
                                                            (lambda () (char rep (mod (incf cycle) (length rep)))))))))

(defmethod handle :after ((rq dialogue:text-request) (textbox textbox))
  (let* ((new-text (if (setting :gameplay :display-swears)
                       (dialogue:text rq)
                       (replace-swears (dialogue:text rq))))
         (s (make-array (+ (length (text textbox)) (length new-text))
                        :element-type 'character))
         (offset (- (length s) (length new-text))))
    (replace s (text textbox))
    (replace s new-text :start1 (length (text textbox)))
    (setf (text textbox) s)
    (scroll-text textbox (scroll-index textbox))
    (when (setting :gameplay :display-text-effects)
      (setf (markup (textbox textbox))
            (append (if (< 0 offset) (markup (textbox textbox)))
                    (normalize-markup (dialogue:markup rq) :offset offset :length (length new-text)))))))

(defmethod handle :after ((rq dialogue:target-request) (textbox textbox))
  (setf (ip textbox) (dialogue:target rq)))

(defmethod reset ((textbox textbox))
  (dialogue:reset (vm textbox))
  (alloy:clear (choices textbox))
  (setf (ip textbox) 0)
  (setf (text textbox) (clear-text-string))
  (setf (scroll-index textbox) 0)
  (setf (pending textbox) NIL)
  (setf (prompt textbox) NIL)
  textbox)
