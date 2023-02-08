(in-package #:org.shirakumo.fraf.kandria)

(define-global +tile-size+ 16)
(define-global +layer-count+ 6)
(define-global +base-layer+ 2)
(define-global +tiles-in-view+ (vec2 40 26))
(define-global +world+ NIL)
(define-global +app-system+ "kandria")
(define-global +settings+
    (copy-tree '(:audio (:latency 0.005
                         :backend :default
                         :device :default
                         :volume (:master 0.5
                                  :effect 1.0
                                  :music 1.0))
                 :display (:resolution (T T)
                           :fullscreen T
                           :vsync T
                           :target-framerate :none
                           :gamma 2.2
                           :ui-scale 1.0
                           :font "PromptFont"
                           :shadows T)
                 :gameplay (:rumble 1.0
                            :screen-shake 1.0
                            :god-mode NIL
                            :infinite-dash NIL
                            :infinite-climb NIL
                            :text-speed 0.02
                            :auto-advance-after 3.0
                            :auto-advance-dialog NIL
                            :display-text-effects T
                            :display-swears T
                            :pause-on-focus-loss T
                            :display-hud T
                            :visual-safe-mode NIL
                            :allow-resuming-death NIL
                            :game-speed 1.0
                            :damage-input 1.0
                            :damage-output 1.0
                            :level-multiplier 1.0
                            :exploding-wolves NIL
                            :show-splits NIL
                            :show-hit-stings T)
                 :language :system
                 :debugging (:show-debug-settings #+kandria-release NIL #-kandria-release T
                             :send-diagnostics T
                             :allow-editor #+kandria-release NIL #-kandria-release T
                             :show-mod-menu-entry T
                             :swank NIL
                             :swank-port 4005
                             :camera-control NIL
                             :fps-counter NIL
                             :dont-save-screenshot NIL
                             :dont-submit-reports NIL
                             :dont-load-mods NIL))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun mktab (&rest entries)
    (let ((table (make-hash-table :size (length entries))))
      (loop for (key val) in entries
            do (setf (gethash key table) val))
      table)))

(define-global +player-movement-data+
    (macrolet ((mktab* (&rest entries)
                 `(mktab ,@(loop for (k v) in entries
                                 collect `(list ',k ,v)))))
      (mktab* (coyote-time     0.08)
              (velocity-limit  (vec 10 20))
              (slowfall-limit  5.0)
              (walk-acc        0.1)
              (slowwalk-limit  0.6)
              (walk-limit      1.9)
              (run-acc         0.0125)
              (run-time        3.0)
              (run-limit       4.0)
              (air-acc         0.08)
              (air-dcc         0.97)
              (air-neutral-dcc 0.97)
              (climb-up        0.8)
              (climb-down      1.5)
              (climb-strength  5.0)
              (climb-jump-cost 1.7)
              (climb-hold-cost 0.1)
              (climb-up-cost   1.0)
              (slide-limit    -1.2)
              (slide-ramp-time 0.25)
              (crawl           0.5)
              (jump-acc        2.5)
              (jump-hold-acc  22.0)
              (walljump-acc    (vec 3.0 2.5))
              (inertia-coyote  0.3)
              (inertia-time    0.2)
              (dash-acc        1.2)
              (dash-dcc        0.875)
              (dash-air-dcc    0.98)
              (dash-acc-start  0.1)
              (dash-dcc-start  0.25)
              (dash-dcc-end    0.35)
              (dash-min-time   0.30)
              (dash-max-time   0.675)
              (dash-evade-grace-time 0.35)
              (hyperdash-bonus (vec 0.5 0.2))
              (slide-acc       0.02)
              (slide-dcc       0.1)
              (slide-acclimit  3.5)
              (slide-friction  0.98)
              (slide-slope-acc 0.03)
              (slide-slope-dcc 0.001)
              (buffer-expiration-time 0.3)
              (look-delay      0.5)
              (look-offset     192))))

(defmacro p! (name)
  #+kandria-release
  (gethash name +player-movement-data+)
  #-kandria-release
  `(gethash ',name +player-movement-data+))

(defun initial-timestamp ()
  (float (encode-universal-time 11 8 7 22 2 2396 0) 0d0))

(defun format-absolute-time (&optional (time (get-universal-time)) &key (date-separator #\.) (time-separator #\:) (date-time-separator #\ )
                                                                        (time-zone 0))
  (multiple-value-bind (s m h dd mm yy) (decode-universal-time time time-zone)
    (format NIL "~4,'0d~c~2,'0d~c~2,'0d~c~2,'0d~c~2,'0d~c~2,'0d"
            yy date-separator mm date-separator dd date-time-separator
            h time-separator m time-separator s)))

(defun format-relative-time (stamp)
  (let ((seconds   (mod (floor (/ stamp 1)) 60))
        (minutes   (mod (floor (/ stamp 60)) 60))
        (hours     (mod (floor (/ stamp 60 60)) 24))
        (days      (mod (floor (/ stamp 60 60 24)) 7))
        ;; We approximate by saying each month has four weeks
        (months    (mod (floor (/ stamp 60 60 24 7 4)) 12))
        ;; More accurate through stamp in a year
        (years     (mod (floor (/ stamp 31557600)) (expt 10 9)))
        (aeons          (floor (/ stamp 31557600 10 10 (expt 10 (- 9 2))))))
    (with-output-to-string (out)
      (cond ((< 0 aeons)
             (format out (language-string 'relative-time-aeons) aeons years months days hours minutes seconds))
            ((< 0 years)
             (format out (language-string 'relative-time-years) years months days hours minutes seconds))
            ((< 0 months)
             (format out (language-string 'relative-time-months) months days hours minutes seconds))
            ((< 0 days)
             (format out (language-string 'relative-time-days) days hours minutes seconds))
            ((< 0 hours)
             (format out (language-string 'relative-time-hours) hours minutes seconds))
            (T
             (format out (language-string 'relative-time-minutes) minutes seconds))))))

(defun parse-sexps (string)
  (with-trial-io-syntax (#.*package*)
    (loop with eof = (make-symbol "EOF")
          with i = 0
          collect (multiple-value-bind (data next) (read-from-string string NIL EOF :start i)
                    (setf i next)
                    (if (eql data EOF)
                        (loop-finish)
                        data)))))

(defun princ* (expression &optional (stream *standard-output*))
  (with-trial-io-syntax ()
    (write expression :stream stream :case :downcase)
    (fresh-line stream)))

(defun type-tester (type)
  (lambda (object) (typep object type)))

(define-compiler-macro type-tester (&whole whole type &environment env)
  (if (constantp type env)
      `(lambda (o) (typep o ,type))
      whole))

(defmethod unit (thing (target (eql T)))
  (when +world+
    (unit thing +world+)))

(declaim (inline within-dist-p closer
                 invclamp absinvclamp point-angle random* intersection-point ~=))

(defun ~= (a b &optional (delta 1))
  (< (abs (- a b)) delta))

(defun vrandr (min max &optional (deg (* 2 PI)) (rng #'random))
  (let ((r (+ min (funcall rng (- max min))))
        (phi (funcall rng deg)))
    (vec (* r (cos phi))
         (* r (sin phi)))))

(defun within-dist-p (a b x)
  (< (vsqrdistance a b) (expt x 2)))

(defun mindist (pos candidates)
  (loop for candidate in candidates
        minimize (vdistance pos candidate)))

(defun closer (a b dir)
  (< (abs (v. a dir)) (abs (v. b dir))))

(defun invclamp (low mid high)
  (cond ((< mid low) 0.0)
        ((< high mid) 1.0)
        (T (/ (- mid low) (- high low)))))

(defun absinvclamp (low mid high)
  (* (signum mid) (invclamp low (abs mid) high)))

(defmacro define-tvecop (name op)
  `(defmacro ,name (a b)
     (let ((ag (gensym "A")) (bg (gensym "B")))
       `(let ((,ag ,a) (,bg ,b))
          (vsetf (load-time-value (vec 0 0))
                 (,',op (vx2 ,ag) (vx2 ,bg)) (,',op (vy2 ,ag) (vy2 ,bg)))))))

(define-tvecop tv+ +)
(define-tvecop tv- -)
(define-tvecop tv* *)
(define-tvecop tv/ /)

(defmacro tvec (&rest args)
  `(vsetf (load-time-value (vec ,@(loop repeat (length args) collect 0)))
          ,@args))

(defmacro with-tvec ((v &rest args) &body body)
  `(let ((,v ,(ecase (length args)
                (2 `(3d-vectors::%vec2 ,(first args) ,(second args)))
                (3 `(3d-vectors::%vec3 ,(first args) ,(second args) ,(third args)))
                (4 `(3d-vectors::%vec4 ,(first args) ,(second args) ,(third args) ,(fourth args))))))
     (declare (dynamic-extent ,v))
     ,@body))

(defun point-angle (point)
  (atan (vy point) (vx point)))

(defun random* (x var)
  (if (= 0.0 var)
      x
      (+ x (- (random var) (/ var 2f0)))))

(defun damp* (factor quotient)
  (expt factor quotient))

(define-compiler-macro damp* (factor quotient)
  `(expt ,factor ,quotient))

(defun grander (a b)
  (cond ((= 0 a)
         b)
        ((< 0 a)
         (if (< b a) a b))
        (T
         (if (< a b) a b))))

(defun intersection-point (a as b bs)
  (let ((l (max (- (vx2 a) (vx2 as))
                (- (vx2 b) (vx2 bs))))
        (r (min (+ (vx2 a) (vx2 as))
                (+ (vx2 b) (vx2 bs))))
        (b (max (- (vy2 a) (vy2 as))
                (- (vy2 b) (vy2 bs))))
        (u (min (+ (vy2 a) (vy2 as))
                (+ (vy2 b) (vy2 bs)))))
    (vec2 (/ (+ l r) 2)
          (/ (+ b u) 2))))

(defclass solid () ())
(defclass half-solid (solid) ())
(defclass resizable () ())
(defclass creatable () ())

(defun list-creatable-classes ()
  (mapcar #'class-name (c2mop:class-direct-subclasses (find-class 'creatable))))

(defstruct (hit (:constructor %make-hit (&optional (object NIL) (location (vec 0 0)) (time 0f0) (normal (vec 0 0)))))
  (object NIL)
  (location NIL :type vec2)
  (time 0f0 :type single-float)
  (normal NIL :type vec2))

(defun make-hit (object location &optional (time 0f0) (normal (tvec 0 0)))
  (let ((hit (load-time-value (%make-hit NIL (vec 0 0)))))
    (setf (hit-object hit) object)
    (setf (hit-location hit) location)
    (setf (hit-time hit) time)
    (setf (hit-normal hit) normal)
    hit))

(defun transfer-hit (target source)
  (setf (hit-object target) (hit-object source))
  (setf (hit-location target) (hit-location source))
  (setf (hit-time target) (hit-time source))
  (setf (hit-normal target) (hit-normal source))
  target)

;; Scan through TARGET to find REGION. When a match is found, invoke ON-HIT
;; with a HIT instance. If ON-HIT returns true, the scan continues, otherwise
;; the HIT instance is returned.
(defgeneric scan (target region on-hit))
;; Should return T if the HIT should actually be counted as a valid collision.
(defgeneric is-collider-for (object collider))
(defgeneric collides-p (object tested hit))
;; Returns T if TARGET is contained in THING.
(defgeneric contained-p (target thing))

(defmethod contained-p ((point vec2) (rect vec4))
  (and (<= (- (vx4 rect) (vz4 rect)) (vx2 point) (+ (vx4 rect) (vz4 rect)))
       (<= (- (vy4 rect) (vw4 rect)) (vy2 point) (+ (vy4 rect) (vw4 rect)))))

(defmethod contained-p ((a vec4) (b vec4))
  (and (< (abs (- (vx a) (vx b))) (+ (vz a) (vz b)))
       (< (abs (- (vy a) (vy b))) (+ (vw a) (vw b)))))

(defmethod contained-p ((type symbol) (area symbol))
  (let ((area (unit area +world+)))
    (bvh:do-fitting (entity (bvh (region +world+)) area)
      (when (typep entity type)
        (return T)))))

(defmethod scan (target region on-hit))
(defmethod collides-p (object target hit)
  (is-collider-for object target))

(defmethod is-collider-for (object target) NIL)
(defmethod is-collider-for (object (target solid)) T)

(defun scan-collision-for (tester target region)
  (let ((result (scan target region (lambda (hit) (not (is-collider-for tester (hit-object hit)))))))
    (when result (hit-object result))))

;; Handle response to a collision of OBJECT with the TESTED entity on HIT.
;; HIT-OBJECT of the HIT instance must be EQ to TESTED.
(defgeneric collide (object tested hit))

(defmethod entity-at-point (point thing)
  NIL)

(defmethod entity-at-point (point (container container))
  (or (call-next-method)
      (for:for ((result as NIL)
                (entity over container)
                (at-point = (entity-at-point point entity)))
        (when (and at-point
                   ;; FIXME: this is terrible
                   (not (eql 'layer (type-of entity)))
                   (not (eql 'bg-layer (type-of entity)))
                   (or (null result)
                       (< (vlength (bsize at-point))
                          (vlength (bsize result)))))
          (setf result at-point)))))

(defmethod contained-p (thing target)
  (scan target thing (constantly NIL)))

(defun within-p (bigger smaller)
  (let ((b-size (bsize bigger))
        (s-size (bsize smaller))
        (b-loc (location bigger))
        (s-loc (location smaller)))
    (and (<= (- (vx b-loc) (vx b-size)) (- (vx s-loc) (vx s-size)))
         (<= (- (vy b-loc) (vy b-size)) (- (vy s-loc) (vy s-size)))
         (<= (+ (vx s-loc) (vx s-size)) (+ (vx b-loc) (vx b-size)))
         (<= (+ (vy s-loc) (vy s-size)) (+ (vy b-loc) (vy b-size))))))

(defun in-bounds-p (loc bounds)
  (declare (optimize speed))
  (declare (type vec2 loc))
  (declare (type vec4 bounds))
  (let* ((lx (vx2 loc))
         (ly (vy2 loc)))
    (and (< (vx4 bounds) lx)
         (< (vy4 bounds) ly)
         (< lx (vz4 bounds))
         (< ly (vw4 bounds)))))

(defun find-chunk (thing &optional (region (region +world+)))
  (when region
    (bvh:do-fitting (entity (bvh region) thing)
      (when (typep entity 'chunk)
        (return entity)))))

(defun 1-pole-lpf (current target)
  (let* ((a 0.99)
         (b (- 1.0 a)))
    (+ (* target b) (* current a))))

(defun sigdist-rect (loc bsize x)
  (declare (type vec2 x loc bsize))
  (declare (optimize speed))
  (let* ((dx (max (- (- (vx loc) (vx bsize)) (vx x))
                  (- (vx x) (+ (vx loc) (vx bsize)))))
         (dy (max (- (- (vy loc) (vy bsize)) (vy x))
                  (- (vy x) (+ (vy loc) (vy bsize))))))
    (+ (vlength (vec (max dx 0.0) (max dy 0.0)))
       (min 0.0 (max dx dy)))))

(defun closest-external-border (loc bsize x off)
  (let ((vx (max (- (vx loc) (vx bsize)) (min (+ (vx loc) (vx bsize)) (vx x))))
        (vy (max (- (vy loc) (vy bsize)) (min (+ (vy loc) (vy bsize)) (vy x)))))
    (cond ((and (/= (vx x) vx) (= (vy x) vy))
           (vec vx (vy x)))
          ((and (/= (vy x) vy) (= (vx x) vx))
           (vec (vx x) vy))
          (T
           (let* ((a (v- (v+ loc bsize) x))
                  (b (v- (v- loc bsize x)))
                  (min (vmin a b))
                  (d (min (vx min) (vy min))))
             (cond ((= (vx a) d)
                    (vec (+ (vx loc) (vx bsize) (vx off)) (vy x)))
                   ((= (vx b) d)
                    (vec (- (vx loc) (vx bsize) (vx off)) (vy x)))
                   ((= (vy a) d)
                    (vec (vx x) (+ (vy loc) (vy bsize) (vy off))))
                   (T
                    (vec (vx x) (- (vy loc) (vy bsize) (vy off))))))))))

(defun closest-border (loc bsize x)
  (let ((vx (max (- (vx loc) (vx bsize)) (min (+ (vx loc) (vx bsize)) (vx x))))
        (vy (max (- (vy loc) (vy bsize)) (min (+ (vy loc) (vy bsize)) (vy x)))))
    (cond ((or (/= (vx x) vx) (/= (vy x) vy))
           (vec vx vy))
          (T
           (let* ((a (v- (v+ loc bsize) x))
                  (b (v- (v- loc bsize x)))
                  (min (vmin a b))
                  (d (min (vx min) (vy min))))
             (cond ((= (vx a) d)
                    (vec (+ (vx loc) (vx bsize)) (vy x)))
                   ((= (vx b) d)
                    (vec (- (vx loc) (vx bsize)) (vy x)))
                   ((= (vy a) d)
                    (vec (vx x) (+ (vy loc) (vy bsize))))
                   (T
                    (vec (vx x) (- (vy loc) (vy bsize))))))))))

(defmethod closest-acceptable-location ((entity entity) location)
  (let ((closest NIL) (dist float-features:single-float-positive-infinity))
    (for:for ((other over (region +world+)))
      (when (typep other 'chunk)
        (let ((ndist (sigdist-rect (location other) (bsize other) location)))
          (when (< ndist dist)
            (setf dist ndist)
            (setf closest other)))))
    (cond ((null closest)
           location)
          ((contained-p location closest)
           location)
          (T
           (nv+ (closest-border (location closest) (bsize closest) location)
                (vec (* (vx (bsize entity)) (signum (- (vx (location closest)) (vx location))))
                     (* (vy (bsize entity)) (signum (- (vy (location closest)) (vy location))))))))))

(defun mouse-world-pos (pos)
  (let ((camera (camera +world+)))
    (let ((pos (nv+ (v/ pos (view-scale camera) (zoom camera)) (location camera))))
      (nv- pos (v/ (target-size camera) (zoom camera))))))

(defun world-screen-pos (pos)
  (let ((camera (camera +world+)))
    (let ((pos (v+ pos (v/ (target-size camera) (zoom camera)))))
      (v* (nv- pos (location camera)) (view-scale camera) (zoom camera)))))

(defun mouse-tile-pos (pos)
  (nvalign (mouse-world-pos (v- pos (/ +tile-size+ 2))) +tile-size+))

(defclass request-region (event)
  ((region :initarg :region :reader region)))

(defclass switch-region (event)
  ((region :initarg :region :reader region)))

(defclass switch-chunk (event)
  ((chunk :initarg :chunk :reader chunk)))

(defclass change-time (event)
  ((timestamp :initarg :timestamp :reader timestamp)))

(defun switch-chunk (chunk)
  (issue +world+ 'switch-chunk :chunk chunk))

(defclass force-lighting (event)
  ())

(defclass load-complete (event)
  ())

(defclass unpausable () ())

(defclass ephemeral (entity)
  ((name :initform (generate-name))))

(defmethod save-p ((entity ephemeral))
  (name entity))

(define-shader-entity player () ())
(define-shader-entity enemy () ())

(defmacro error-or (&rest cases)
  (let ((id (gensym "BLOCK")))
    `(cl:block ,id
       ,@(loop for case in cases
               collect `(ignore-errors
                         (return-from ,id ,case))))))

(defmacro case* (thing &body cases)
  (let ((thingg (gensym "THING")))
    `(let ((,thingg ,thing))
       ,@(loop for (test . body) in cases
               for tests = (enlist test)
               collect `(when (or ,@(loop for test in tests
                                          collect `(eql ,test ,thingg)))
                          ,@body)))))

(defun cycle-list (list)
  (let ((first (pop list)))
    (if list
        (setf (cdr (last list)) (list first))
        (setf list (list first)))
    (values list first)))

(defmacro define-unit-resolver-methods (func args)
  (let ((arglist (loop for arg in args
                       for i from 0
                       collect (make-symbol (princ-to-string i)))))
    `(progn
       ,@(loop for arg in args
               for i from 0
               when (eql arg 'unit)
               collect `(defmethod ,func ,(let ((list (copy-list arglist)))
                                            (setf (nth i list) `(,(nth i list) symbol))
                                            list)
                          (,@(if (listp func)
                                 `(funcall #',func)
                                 `(,func))
                           ,@(let ((list (copy-list arglist)))
                               (setf (nth i list) `(or (unit ,(nth i list) +world+)
                                                       (error "No unit named ~s found." ,(nth i list))))
                               list)))))))

(define-unit-resolver-methods start-animation (animation unit))

(defun ensure-unit (unit)
  (etypecase unit
    (entity unit)
    (symbol (unit unit +world+))))

(defun ensure-location (unit)
  (etypecase unit
    (entity (location unit))
    (vec unit)
    (symbol (location (unit unit +world+)))))

(defun set-tile (map width height x y tile)
  (destructuring-bind (&optional (tx 0) (ty 0) (w 1) (h 1)) tile
    (when (< w 0) (incf x w) (incf tx w) (setf w (1+ (- w))))
    (when (< h 0) (incf y h) (incf ty h) (setf h (1+ (- h))))
    (dotimes (xo w map)
      (dotimes (yo h)
        (let ((x (+ xo x))
              (y (+ yo y)))
          (when (and (<= 0 x (1- width))
                     (<= 0 y (1- height)))
            (let ((pos (* (+ x (* y width)) 2)))
              (setf (aref map (+ pos 0)) (+ xo tx))
              (setf (aref map (+ pos 1)) (+ yo ty)))))))))

(defun set-tile-stencil (map width height x y stencil)
  (destructuring-bind (h w _) (array-dimensions stencil)
    (declare (ignore _))
    (dotimes (yo h map)
      (let ((y (+ yo y)))
        (when (<= 0 y (1- height))
          (dotimes (xo w)
            (let ((x (+ xo x)))
              (when (<= 0 x (1- width))
                (let ((pos (* (+ x (* y width)) 2)))
                  (setf (aref map (+ pos 0)) (aref stencil yo xo 0))
                  (setf (aref map (+ pos 1)) (aref stencil yo xo 1)))))))))))

(defun stencil-from-tile (tile)
  (destructuring-bind (&optional (tx 0) (ty 0) (w 1) (h 1)) tile
    (when (< w 0) (incf tx w) (setf w (1+ (- w))))
    (when (< h 0) (incf ty h) (setf h (1+ (- h))))
    (let ((stencil (make-array (list h w 2) :element-type '(unsigned-byte 8))))
      (dotimes (yo h stencil)
        (dotimes (xo w)
          (setf (aref stencil yo xo 0) (+ xo tx))
          (setf (aref stencil yo xo 1) (+ yo ty)))))))

(defun stencil-from-fill (w h &optional tile)
  (destructuring-bind (&optional (tx 0) (ty 0) (tw 1) (th 1)) tile
    (let ((stencil (make-array (list h w 2) :element-type '(unsigned-byte 8))))
      (dotimes (yo h stencil)
        (dotimes (xo w)
          (setf (aref stencil yo xo 0) (+ tx (mod xo tw)))
          (setf (aref stencil yo xo 1) (+ ty (mod yo th))))))))

(defun stencil-from-map (map width height x y w h)
  (let ((stencil (make-array (list h w 2) :element-type '(unsigned-byte 8))))
    (dotimes (yo h stencil)
      (dotimes (xo w)
        (let ((x (+ xo x))
              (y (+ yo y)))
          (when (and (<= 0 x (1- width))
                     (<= 0 y (1- height)))
            (let ((pos (* (+ x (* y width)) 2)))
              (setf (aref stencil yo xo 0) (aref map (+ pos 0)))
              (setf (aref stencil yo xo 1) (aref map (+ pos 1))))))))))

(defmacro with-warning-report-for ((format &rest args) &body body)
  (let ((warning (gensym "WARNING")))
    `(handler-bind ((warning
                      (lambda (,warning)
                        (format T "
--------------------------------------------------------------------------------
  [~a] for ~?:
~a"
                                (type-of ,warning) ,format (list ,@args) ,warning)
                        (muffle-warning ,warning))))
       ,@body)))

(defun re-encode-json (file)
  (let* ((data (jsown:parse (alexandria:read-file-into-string file))))
    (let ((*print-pretty* nil))
      (with-open-file (output file :direction :output
                                   :if-exists :supersede)
        (jsown::write-object-to-stream data output)))))

(defun read-src (file)
  (with-trial-io-syntax ()
    (with-open-file (stream file :direction :input
                                 :element-type 'character)
      (read stream))))

(defun aseprite (&rest args)
  (uiop:run-program (list* #-windows "aseprite" #+windows "aseprite.exe"
                           "-b"
                           (loop for arg in args
                                 collect (typecase arg
                                           (pathname (uiop:native-namestring arg))
                                           (T (princ-to-string arg)))))
                    :output *standard-output*
                    :error-output *error-output*))

(defun img-convert (&rest args)
  (uiop:run-program (list* #-windows "convert" #+windows "convert.exe"
                           (loop for arg in args
                                 collect (typecase arg
                                           (pathname (uiop:native-namestring arg))
                                           (T (princ-to-string arg)))))
                    :output *standard-output*
                    :error-output *error-output*))

(defun img-montage (&rest args)
  (uiop:run-program (list* #-windows "montage" #+windows "montage.exe"
                           (loop for arg in args
                                 collect (typecase arg
                                           (pathname (uiop:native-namestring arg))
                                           (T (princ-to-string arg)))))
                    :output *standard-output*
                    :error-output *error-output*))

(defun optipng (file)
  (ignore-errors
   (uiop:run-program (list #-windows "pngcrush" #+windows "pngcrush.exe"
                           "-brute" "-reduce" "-speed"
                           (uiop:native-namestring file)
                           (uiop:native-namestring (make-pathname :type "tmp" :defaults file)))
                     :output *standard-output*
                     :error-output *error-output*)
   (rename-file (make-pathname :type "tmp" :defaults file) file)))

(defmacro match1 (thing &body clauses)
  (let ((thingg (gensym "THING")))
    `(let ((,thingg ,thing))
       (ecase (first ,thingg)
         ,@(loop for (id lambda . body) in clauses
                 collect `(,id
                           (destructuring-bind ,lambda (rest ,thingg)
                             ,@body)))))))

(trivial-indent:define-indentation match1 (4 &rest (&whole 2 4 &lambda &body)))

(defun symb (package &rest symb)
  (intern (format NIL "~{~a~}" symb)
          (if (eql T package) *package* package)))

(defun emit-export (package &rest symb)
  (let ((symb (apply #'symb package symb)))
    (export symb package)
    `(export ',symb ',package)))

(defmacro ! (&body body)
  `(when +world+
     (with-eval-in-render-loop (+world+)
       ,@body)))

(defun version<= (a b)
  (flet ((parse-version (v)
           (destructuring-bind (a b c &optional h) (cl-ppcre:split "[\\.\\-]" v)
             (list (parse-integer a)
                   (parse-integer b)
                   (parse-integer c)
                   h))))
    (destructuring-bind (a0 a1 a2 ah) (parse-version a)
      (destructuring-bind (b0 b1 b2 bh) (parse-version b)
        (or (< a0 b0)
            (when (= a0 b0)
              (or (< a1 b1)
                  (when (= a1 b1)
                    (or (< a2 b2)
                        (when (= a2 b2)
                          (or (null ah)
                              (not (null bh))
                              (string= ah bh))))))))))))
(defmacro or* (&rest stuff)
  (cond ((rest stuff)
         `(or ,@(loop for thing in stuff
                      collect `(or* ,thing))))
        (stuff
         (let ((value (gensym "VALUE")))
           `(let ((,value ,(first stuff)))
              (when (and ,value (string/= ,value ""))
                ,value))))
        (T NIL)))

(defun language-string* (thing &rest subset)
  (language-string (intern (format NIL "~a~{/~a~}" (string thing) subset)
                           (symbol-package thing))
                   NIL))

(defun u (name)
  (gethash name (name-map +world+)))

(defun load-source-file (file)
  (etypecase file
    (pathname
     (cl:load file))
    (depot:file
     (cl:load (depot:to-pathname file)))
    (depot:entry
     (trial:with-tempfile (tempfile :type "lisp")
       (depot:read-from file tempfile)
       ;; FIXME: *load-pathname* / *load-truename* make no sense here...
       (cl:load tempfile)))))

(defmacro with-lenient-reader ((&optional (category :kandria) (format "Ignoring reader error ~a")) &body body)
  `(handler-bind ((sb-int:simple-reader-package-error
                    (lambda (e)
                      (v:warn ,category ,format e)
                      (v:debug ,category e)
                      (if (find-restart 'unintern)
                          (invoke-restart 'unintern)
                          (invoke-restart 'continue)))))
     ,@body))
