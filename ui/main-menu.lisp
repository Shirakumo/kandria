(in-package #:org.shirakumo.fraf.kandria)

(defclass news-display (label)
  ((alloy:value :initform "")
   (markup :initform () :accessor markup)))

(defmethod initialize-instance :after ((display news-display) &key)
  (fetch-news display))

(presentations:define-update (ui news-display)
  (:label
   :size (alloy:un 15)
   :pattern colors:gray
   :valign :bottom :halign :left
   :markup (markup alloy:renderable)))

(defun parse-news (source)
  (let ((req (dialogue:resume (dialogue:run (dialogue:compile source T) (make-instance 'dialogue:vm)) 1)))
    (values (dialogue:text req)
            (normalize-markup (dialogue:markup req)))))

(defun fetch-news (target &optional (url "https://kandria.com/news.mess"))
  (with-thread ("news-fetcher")
    (v:info :kandria.news "Fetching news...")
    (handler-case
        (multiple-value-bind (text markup) (parse-news (drakma:http-request url :want-stream T))
          (setf (alloy:value target) text)
          (setf (markup target) markup))
      (error (e)
        (v:severe :kandria.news "Failed to fetch news: ~a" e)))))

(defclass main-menu-button (button)
  ())

(presentations:define-realization (ui main-menu-button)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font (setting :display :font)
   :halign :middle :valign :middle)
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

(defclass main-menu (menuing-panel)
  ())

(defmethod initialize-instance :after ((panel main-menu) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (menu (make-instance 'alloy:vertical-linear-layout :cell-margins (alloy:margins 5) :min-size (alloy:size 100 30)))
        (focus (make-instance 'alloy:focus-list)))
    (alloy:enter menu layout :constraints `((:center :w) (:bottom 20) (:height 300) (:width 200)))
    (macrolet ((with-button ((name &rest initargs) &body body)
                 `(make-instance 'main-menu-button :value (@ ,name) :on-activate (lambda ()
                                                                                   (discard-events +world+)
                                                                                   ,@body)
                                                   :focus-parent focus :layout-parent menu ,@initargs)))
      (when (list-saves)
        (with-button (load-game-menu)
          (show-panel 'save-menu :intent :load)))
      (with-button (new-game)
        (if (list-saves)
            (show-panel 'save-menu :intent :new)
            (load-game NIL +main+)))
      (with-button (options-menu)
        (show-panel 'options-menu))
      (with-button (credits-menu)
        (show-panel 'credits))
      #++
      (with-button (changelog-menu)
        )
      (let ((subbutton
              (if (steam:steamworks-available-p)
                  (with-button (subscribe-cta)
                    (open-in-browser "https://courier.tymoon.eu/subscription/1"))
                  (with-button (wishlist-cta)
                    (open-in-browser "https://store.steampowered.com/app/1261430/Kandria/?utm_source=in-game")))))
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
        (alloy:enter news layout :constraints `((:left 5) (:bottom 5) (:height 50) (:width 500)))))
    (alloy:finish-structure panel layout focus)))

(define-shader-entity star (sprite-entity)
  ((multiplier :initform 1.0 :accessor multiplier)
   (texture :initform (// 'kandria 'star))
   (size :initform (vec 105 105))
   (clock :initform (random 1000.0) :accessor clock)))

(defmethod render :before ((star star) (program shader-program))
  (incf (clock star) 0.01)
  (setf (uniform program "multiplier")
        (float (+ 1.0 (/ (+ (sin (* 2 (clock star)))
                            (sin (* PI (clock star))))
                         2.0))
               0f0)))

(define-class-shader (star :fragment-shader)
  "uniform float multiplier = 1.0;
out vec4 color;
void main(){
   color *= multiplier;
}")

(define-shader-entity heartbeat (located-entity lines)
  ((points :accessor points)
   (clock :initform 0.0 :accessor clock)))

(defmethod initialize-instance :after ((entity heartbeat) &key margin)
  (let ((points '(0 0 20 10 50 130 140 160 60 30 30 20 40 00 -10 00 30 50 50 140 150 100 20 30 10 0))
        (list ())
        (subdivs 20)
        (px (- margin))
        (py 0.0))
    (flet ((segment (x y)
             (let ((dx (/ (- x px) subdivs))
                   (dy (/ (- y py) subdivs)))
               (dotimes (i subdivs)
                 (push (vec px py 0) list)
                 (incf px dx) (incf py dy)))))
      (loop for x from (* 20 (/ (length points) -2)) by 20
            for y in points
            do (segment (float x) (/ (float y) 2)))
      (segment margin 0.0))
    (setf list (nreverse list))
    (setf (points entity) list)
    (replace-vertex-data entity list)))

(defmethod replace-vertex-data ((lines heartbeat) points &key (update T))
  (let ((mesh (make-instance 'vertex-mesh :vertex-type 'trial::line-vertex))
        (c #.(vec 1 1 1 1)))
    (with-vertex-filling (mesh)
      (loop for (a b) on points
            while b
            do (vertex :location a :normal (v- a b) :color c)
               (vertex :location b :normal (v- a b) :color c)
               (vertex :location a :normal (v- b a) :color c)
               (vertex :location b :normal (v- a b) :color c)
               (vertex :location b :normal (v- b a) :color c)
               (vertex :location a :normal (v- b a) :color c)))
    (replace-vertex-data (vertex-array lines) mesh :update update)))

(defmethod render :before ((heartbeat heartbeat) (program shader-program))
  (let* ((list (points heartbeat))
         (clock (decf (clock heartbeat) 0.02))
         (len (length list))
         (duration 3.0))
    (cond ((<= clock (- duration))
           (setf (clock heartbeat) (random* 2.0 1.0))
           (replace-vertex-data heartbeat list))
          ((<= clock 0.0)
           (let* ((dprog (/ (- clock) duration))
                  (strength (- 0.5 (abs (- dprog 0.5)))))
             (replace-vertex-data
              heartbeat (loop for i from 0
                              for v in list
                              for prog = (/ i len)
                              for off = (* (+ 0.2 (* 2 (- 0.5 (abs (- prog 0.5)))))
                                           3
                                           strength
                                           (logand #x3F (sxhash i))
                                           (/ (max 0.0 (- 1 (abs (- prog dprog)))) 20)
                                           (+ (sin (+ (* 5 clock) (/ i 2))) (sin (+ (* 5 clock) (/ i PI)))))
                              collect (vec (vx v) (+ (vy v) off) 0))))))))

(defmethod render ((heartbeat heartbeat) (program shader-program))
  (let ((count 10))
    (with-pushed-matrix ()
      (dotimes (i (1+ count))
        (setf (uniform program "multiplier") (- 0.5 (* 0.5 (float (/ i count) 0f0))))
        (call-next-method)
        (translate-by 5 -5 0)
        (scale-by 1 0.9 1)))
    (with-pushed-matrix ()
      (dotimes (i (1+ count))
        (setf (uniform program "multiplier") (- 0.5 (* 0.5 (float (/ i count) 0f0))))
        (call-next-method)
        (translate-by -5 5 0)
        (scale-by 1 0.9 1)))))

(define-class-shader (heartbeat :fragment-shader)
  "uniform float multiplier = 1.0;
out vec4 color;
void main(){
   color *= multiplier;
}")

(defmethod show :after ((menu main-menu) &key)
  (let* ((camera (make-instance 'camera))
         (tsize (target-size camera))
         (yspread (/ (vy tsize) 1.5)))
    (trial:commit (make-instance 'star) (loader +main+) :unload NIL)
    (enter-and-load (make-instance 'heartbeat :margin (vx tsize)) +world+ +main+)
    (dotimes (i 100)
      (let ((s (+ 8 (* 20 (/ (expt (random 10.0) 3) 1000.0)))))
        (enter* (make-instance 'star
                               :bsize (vec s s)
                               :location (vec (random* 0 (* 2 (vx tsize)))
                                              (- (vy tsize) 10 (* yspread (/ (expt (random 10.0) 3) 1000.0)))))
                +world+)))
    (enter (make-instance 'camera) +world+)))
