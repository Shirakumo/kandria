(in-package #:org.shirakumo.fraf.kandria)

(define-global +tile-size+ 16)
(define-global +layer-count+ 6)
(define-global +base-layer+ 2)
(define-global +tiles-in-view+ (vec2 40 26))
(define-global +world+ NIL)
(define-global +main+ NIL)
(define-global +input-source+ :keyboard)

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
              (walk-acc        0.1)
              (slowwalk-limit  0.6)
              (walk-limit      1.9)
              (run-acc         0.0125)
              (run-time        3.0)
              (run-limit       4.0)
              (air-acc         0.08)
              (air-dcc         0.97)
              (climb-up        0.8)
              (climb-down      1.5)
              (climb-strength  7.0)
              (climb-jump-cost 1.7)
              (slide-limit    -1.2)
              (crawl           0.5)
              (jump-acc        2.5)
              (jump-mult       1.12)
              (walljump-acc    (vec 2.5 2.5))
              (dash-acc        1.2)
              (dash-dcc        0.875)
              (dash-air-dcc    0.98)
              (dash-acc-start  0.05)
              (dash-dcc-start  0.2)
              (dash-dcc-end    0.3)
              (dash-min-time   0.25)
              (dash-max-time   0.675)
              (dash-evade-grace-time 0.1)
              (buffer-expiration-time 0.3)
              (look-delay      0.5)
              (look-offset     16))))

(defmacro p! (name)
  #+kandria-release
  (gethash name +player-movement-data+)
  #-kandria-release
  `(gethash ',name +player-movement-data+))

(defmethod version ((_ (eql :kandria)))
  #.(flet ((file (p)
             (merge-pathnames p (pathname-utils:to-directory (or *compile-file-pathname* *load-pathname*))))
           (trim (s)
             (string-trim '(#\Return #\Linefeed #\Space) s)))
      (let* ((head (trim (alexandria:read-file-into-string (file ".git/HEAD"))))
             (path (subseq head (1+ (position #\  head))))
             (commit (trim (alexandria:read-file-into-string (file (merge-pathnames path ".git/"))))))
        (format NIL "~a-~a"
                (asdf:component-version (asdf:find-system "kandria"))
                (subseq commit 0 7)))))

(defun initial-timestamp ()
  (float (encode-universal-time 0 0 7 1 1 3196 0) 0d0))

(defun root ()
  (if (deploy:deployed-p)
      (deploy:runtime-directory)
      (pathname-utils:to-directory #.(or *compile-file-pathname* *load-pathname*))))

(defun config-directory ()
  (trial:config-directory "shirakumo" "kandria"))

(defun format-absolute-time (&optional (time (get-universal-time)) &key (date-separator #\.) (time-separator #\:) (date-time-separator #\ ))
  (multiple-value-bind (s m h dd mm yy) (decode-universal-time time 0)
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
             (format out "~d aeons ~d years ~d months ~d days ~d:~2,'0d:~2,'0d" aeons years months days hours minutes seconds))
            ((< 0 years)
             (format out "~d years ~d months ~d days ~d:~2,'0d:~2,'0d" years months days hours minutes seconds))
            ((< 0 months)
             (format out "~d months ~d days ~d:~2,'0d:~2,'0d" months days hours minutes seconds))
            ((< 0 days)
             (format out "~d days ~d:~2,'0d:~2,'0d" days hours minutes seconds))
            ((< 0 hours)
             (format out "~d:~2,'0d:~2,'0d" hours minutes seconds))
            (T
             (format out "~d:~2,'0d" minutes seconds))))))

(defun maybe-finalize-inheritance (class)
  (let ((class (etypecase class
                 (class class)
                 (symbol (find-class class)))))
    (unless (c2mop:class-finalized-p class)
      (c2mop:finalize-inheritance class))
    class))

(defmacro with-kandria-io-syntax (&body body)
  `(with-standard-io-syntax
     (let ((*package* #.*package*)
           (*print-case* :downcase)
           (*print-readably* NIL))
       ,@body)))

(defmacro with-memo (bindings &body body)
  (let ((funs (loop for binding in bindings
                    collect (cons (car binding) (gensym (string (car binding)))))))
    `(let ,(mapcar #'car bindings)
       (flet ,(loop for (var value) in bindings
                    for fun = (cdr (assoc var funs))
                    collect `(,fun ()
                                   (or ,var (setf ,var ,value))))
         (declare (ignorable ,@(loop for fun in funs collect (list 'function (cdr fun)))))
         (symbol-macrolet ,(loop for binding in bindings
                                 for fun = (cdr (assoc (car binding) funs))
                                 collect `(,(car binding) (,fun)))
           ,@body)))))

(defun find-new-directory (dir base)
  (loop for i from 0
        for sub = dir then (format NIL "~a-~d" dir i)
        for path = (pathname-utils:subdirectory base sub)
        do (unless (uiop:directory-exists-p path)
             (return path))))

(defun parse-sexps (string)
  (with-kandria-io-syntax
    (loop with eof = (make-symbol "EOF")
          with i = 0
          collect (multiple-value-bind (data next) (read-from-string string NIL EOF :start i)
                    (setf i next)
                    (if (eql data EOF)
                        (loop-finish)
                        data)))))

(defun princ* (expression &optional (stream *standard-output*))
  (with-kandria-io-syntax
    (write expression :stream stream :case :downcase)
    (fresh-line stream)))

(defun type-tester (type)
  (lambda (object) (typep object type)))

(define-compiler-macro type-tester (&whole whole type &environment env)
  (if (constantp type env)
      `(lambda (o) (typep o ,type))
      whole))

(defun type-prototype (type)
  (case type
    (character #\Nul)
    (complex #c(0 0))
    (cons '(NIL . NIL))
    (float 0.0)
    (function #'identity)
    (hash-table (load-time-value (make-hash-table)))
    (integer 0)
    (null NIL)
    (package #.*package*)
    (pathname #p"")
    (random-state (load-time-value (make-random-state)))
    (readtable (load-time-value (copy-readtable)))
    (stream (load-time-value (make-broadcast-stream)))
    (string "string")
    (symbol 'symbol)
    (vector #(vector))
    (T (let ((class (find-class type)))
         (unless (c2mop:class-finalized-p class)
           (c2mop:finalize-inheritance class))
         (c2mop:class-prototype class)))))

(defmethod unit (thing (target (eql T)))
  (when +world+
    (unit thing +world+)))

(declaim (inline v<- vrand vrandr nvalign vfloor vsqrlen2 vsqrdist2 within-dist-p closer
                 invclamp absinvclamp point-angle random* intersection-point))

(defun v<- (target source)
  (etypecase source
    (vec2 (vsetf target (vx2 source) (vy2 source)))
    (vec3 (vsetf target (vx3 source) (vy3 source) (vz3 source)))
    (vec4 (vsetf target (vx4 source) (vy4 source) (vz4 source) (vw4 source)))))

(defun vrand (min max)
  (vec (+ min (random (- max min)))
       (+ min (random (- max min)))))

(defun vrandr (min max &optional (deg (* 2 PI)))
  (let ((r (+ min (random (- max min))))
        (phi (random deg)))
    (vec (* r (cos phi))
         (* r (sin phi)))))

(defun nvalign (vec grid)
  (vsetf vec
         (* grid (floor (+ (vx vec) (/ grid 2)) grid))
         (* grid (floor (+ (vy vec) (/ grid 2)) grid))))

(defun nvunit* (vec)
  (if (v= vec 0)
      vec
      (nvunit vec)))

(defun vfloor (vec &optional (divisor 1))
  (vapply vec floor divisor divisor divisor divisor))

(defun vsqrlen2 (a)
  (declare (type vec2 a))
  (declare (optimize speed))
  (+ (expt (vx2 a) 2)
     (expt (vy2 a) 2)))

(defun vsqrdist2 (a b)
  (declare (type vec2 a b))
  (declare (optimize speed))
  (+ (expt (- (vx2 a) (vx2 b)) 2)
     (expt (- (vy2 a) (vy2 b)) 2)))

(defun within-dist-p (a b x)
  (< (vsqrdist2 a b) (expt x 2)))

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

(defun point-angle (point)
  (atan (vy point) (vx point)))

(defun random* (x var)
  (+ x (- (random var) (/ var 2f0))))

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

(defun initarg-slot (class initarg)
  (let ((class (etypecase class
                 (class class)
                 (symbol (find-class class)))))
    (find (list initarg) (c2mop:class-slots class)
          :key #'c2mop:slot-definition-initargs
          :test #'subsetp)))

(defmethod parse-string-for-type (string type)
  (read-from-string string))

(defmethod parse-string-for-type (string (type (eql 'vec2)))
  (with-input-from-string (stream string)
    (vec2 (read stream) (read stream))))

(defmethod parse-string-for-type (string (type (eql 'vec3)))
  (with-input-from-string (stream string)
    (vec3 (read stream) (read stream) (read stream))))

(defmethod parse-string-for-type (string (type (eql 'asset)))
  (with-input-from-string (stream string)
    (asset (read stream) (read stream) T)))

(defmethod parse-string-for-type :around (string type)
  (let ((value (call-next-method)))
    (with-new-value-restart (value) (new-value "Specify a new value")
      (unless (typep value type)
        (error 'type-error :expected-type type :datum value)))
    value))

(defclass solid () ())
(defclass half-solid (solid) ())
(defclass resizable () ())

(defstruct (hit (:constructor %make-hit (object location &optional (time 0f0) (normal (vec 0 0)))))
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
;; Similar to SCAN, but checks whether a HIT is valid through COLLIDES-P, and
;; returns the closest HIT instance, if any.
(defgeneric scan-collision (target region))
;; Should return T if the HIT should actually be counted as a valid collision.
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
(defmethod collides-p (object target hit) NIL)
(defmethod collides-p (object (target solid) hit) T)

(defmethod scan-collision (target region)
  (scan target region (lambda (hit) (unless (typep (hit-object hit) '(or block solid)) T))))

;; Handle common collision operations. Uses SCAN-COLLISION to find the closest
;; valid HIT, then invokes COLLIDE using that hit, if any. Returns the closest
;; HIT, if any.
(defun handle-collisions (target object)
  (let ((hit (scan-collision target object)))
    (when hit
      (collide object (hit-object hit) hit)
      T)))

;; Handle response to a collision of OBJECT with the TESTED entity on HIT.
;; HIT-OBJECT of the HIT instance must be EQ to TESTED.
(defgeneric collide (object tested hit))

(defmethod entity-at-point (point thing)
  NIL)

(defmethod entity-at-point (point (container flare:container))
  (or (call-next-method)
      (for:for ((result as NIL)
                (entity over container)
                (at-point = (entity-at-point point entity)))
        (when (and at-point
                   ;; FIXME: this is terrible
                   (typep entity '(or chunk (not layer)))
                   (or (null result)
                       (< (vlength (bsize at-point))
                          (vlength (bsize result)))))
          (setf result at-point)))))

(defmethod contained-p (thing target)
  (scan target thing (constantly NIL)))

(defun find-containing (thing container)
  (for:for ((entity over container))
    (when (and (typep entity 'chunk)
               (contained-p thing entity))
      (return entity))))

(defun overlapping-p (a a-size b b-size)
  (and (< (- a a-size) (+ b b-size))
       (< (- b b-size) (+ a a-size))))

(defgeneric clone (thing &key &allow-other-keys))

(defmethod clone (thing &key)
  thing)

(defmethod clone ((vec vec2) &key) (vcopy2 vec))
(defmethod clone ((vec vec3) &key) (vcopy3 vec))
(defmethod clone ((vec vec4) &key) (vcopy4 vec))
(defmethod clone ((mat mat2) &key) (mcopy2 mat))
(defmethod clone ((mat mat3) &key) (mcopy3 mat))
(defmethod clone ((mat mat4) &key) (mcopy4 mat))
(defmethod clone ((mat matn) &key) (mcopyn mat))

(defmethod clone ((cons cons) &key)
  (cons (clone (car cons)) (clone (cdr cons))))

(defmethod clone ((array array) &key)
  (if (array-has-fill-pointer-p array)
      (make-array (array-dimensions array)
                  :element-type (array-element-type array)
                  :adjustable (adjustable-array-p array)
                  :fill-pointer (fill-pointer array)
                  :initial-contents array)
      (make-array (array-dimensions array)
                  :element-type (array-element-type array)
                  :adjustable (adjustable-array-p array)
                  :initial-contents array)))

(defmethod clone ((entity entity) &rest initargs)
  (let ((initvalues ()))
    (loop for initarg in (initargs entity)
          for slot = (initarg-slot (class-of entity) initarg)
          do (push (clone (slot-value entity (c2mop:slot-definition-name slot))) initvalues)
             (push initarg initvalues))
    (apply #'make-instance (class-of entity) (append initargs initvalues))))

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
  (let ((camera (unit :camera T)))
    (let ((pos (nv+ (v/ pos (view-scale camera) (zoom camera)) (location camera))))
      (nv- pos (v/ (target-size camera) (zoom camera))))))

(defun world-screen-pos (pos)
  (let ((camera (unit :camera T)))
    (let ((pos (v+ pos (v/ (target-size camera) (zoom camera)))))
      (v* (nv- pos (location camera)) (view-scale camera) (zoom camera)))))

(defun mouse-tile-pos (pos)
  (nvalign (mouse-world-pos (v- pos (/ +tile-size+ 2))) +tile-size+))

(defun generate-name (&optional indicator)
  (loop for name = (format NIL "~a-~d" (or indicator "ENTITY") (incf *gensym-counter*))
        while (find-symbol name #.*package*)
        finally (return (intern name #.*package*))))

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

(defclass unpausable () ())

(defclass ephemeral (entity)
  ((flare:name :initform (generate-name))))

(define-shader-entity player () ())
(define-shader-entity enemy () ())

(defmacro call (func-ish &rest args)
  (let* ((slash (position #\/ (string func-ish)))
         (package (subseq (string func-ish) 0 slash))
         (symbol (subseq (string func-ish) (1+ slash)))
         (symbolg (gensym "SYMBOL")))
    `(let ((,symbolg (find-symbol ,symbol ,package)))
       (if ,symbolg
           (funcall ,symbolg ,@args)
           (error "No such symbol ~a:~a" ,package ,symbol)))))

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
                               (setf (nth i list) `(unit ,(nth i list) +world+))
                               list)))))))

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

(defmacro with-warning-report-for ((format &rest args) &body body)
  (let ((warning (gensym "WARNING")))
    `(handler-bind ((warning
                      (lambda (,warning)
                        (format T "
--------------------------------------------------------------------------------
  [~a] for ~?:
~a"
                                (type-of ,warning) ,format (list ,@args) ,warning)
                        (muffle-warning ,warning)))
                    )
       ,@body)))

(defun re-encode-json (file)
  (let* ((data (jsown:parse (alexandria:read-file-into-string file))))
    (let ((*print-pretty* nil))
      (with-open-file (output file :direction :output
                                   :if-exists :supersede)
        (jsown::write-object-to-stream data output)))))

(defun read-src (file)
  (with-kandria-io-syntax
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

(defun recompile-needed-p (targets sources)
  (let ((latest (loop for source in sources
                      maximize (file-write-date source))))
    (loop for target in targets
          thereis (or (null (probe-file target))
                      (< (file-write-date target) latest)))))
