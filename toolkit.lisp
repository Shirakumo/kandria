(in-package #:org.shirakumo.fraf.leaf)

(define-global +tile-size+ 16)
(define-global +layer-count+ 6)
(define-global +base-layer+ 3)
(define-global +solid-layer+ 0)
(define-global +tiles-in-view+ (vec2 40 26))
(define-global +world+ NIL)

(defun format-absolute-time (time)
  (multiple-value-bind (s m h dd mm yy) (decode-universal-time time 0)
    (format NIL "~4,'0d.~2,'0d.~2,'0d ~2,'0d:~2,'0d:~2,'0d" yy mm dd h m s)))

(defun maybe-finalize-inheritance (class)
  (let ((class (etypecase class
                 (class class)
                 (symbol (find-class class)))))
    (unless (c2mop:class-finalized-p class)
      (c2mop:finalize-inheritance class))
    class))

(defmacro with-leaf-io-syntax (&body body)
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
  (with-leaf-io-syntax
    (loop with eof = (make-symbol "EOF")
          with i = 0
          collect (multiple-value-bind (data next) (read-from-string string NIL EOF :start i)
                    (setf i next)
                    (if (eql data EOF)
                        (loop-finish)
                        data)))))

(defun princ* (expression &optional (stream *standard-output*))
  (with-leaf-io-syntax
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
    (symbol '#:symbol)
    (vector #(vector))
    (T (let ((class (find-class type)))
         (unless (c2mop:class-finalized-p class)
           (c2mop:finalize-inheritance class))
         (c2mop:class-prototype class)))))

(defun list-subclasses (class)
  (let ((sub (c2mop:class-direct-subclasses (ensure-class class))))
    (loop for class in sub
          nconc (list* class (list-subclasses class)))))

(defun list-leaf-classes (root)
  (let ((sub (c2mop:class-direct-subclasses (ensure-class root))))
    (if sub
        (remove-duplicates
         (loop for class in sub
               nconc (list-leaf-classes class)))
        (list (ensure-class root)))))

(defun similar-asset (asset suffix)
  (with-standard-io-syntax
    (asset (pool asset)
           (or (find-symbol (format NIL "~a~a" (name asset) suffix)
                            (symbol-package (name asset)))
               (find-symbol (format NIL "~a~a" (name asset) suffix)
                            (symbol-package (name (pool asset))))
               (error "No similar asset for ~s found with name ~s found in ~s"
                      asset (format NIL "~a~a" (name asset) suffix) (symbol-package (name asset)))))))

(defmethod unit (thing (target (eql T)))
  (when +world+
    (unit thing +world+)))

(defun vrand (min max)
  (vec (+ min (random (- max min)))
       (+ min (random (- max min)))))

(defun vrandr (min max)
  (let ((r (+ min (random (- max min))))
        (phi (random (* 2 PI))))
    (vec (* r (cos phi))
         (* r (sin phi)))))

(defun nvalign (vec grid)
  (vsetf vec
         (* grid (floor (+ (vx vec) (/ grid 2)) grid))
         (* grid (floor (+ (vy vec) (/ grid 2)) grid))))

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

(defun point-angle (point)
  (atan (vy point) (vx point)))

(defun update-instance-initforms (class)
  (flet ((update (instance)
           (loop for slot in (c2mop:class-direct-slots class)
                 for name = (c2mop:slot-definition-name slot)
                 for init = (c2mop:slot-definition-initform slot)
                 when init do (setf (slot-value instance name) (eval init)))))
    (when (window :main NIL)
      (for:for ((entity over (scene (window :main))))
        (when (typep entity class)
          (update entity))))))

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
(defclass resizable () ())

(defstruct (hit (:constructor make-hit (object location &optional (time 0f0) (normal (vec 0 0)))))
  (object NIL)
  (location NIL :type vec2)
  (time 0f0 :type single-float)
  (normal NIL :type vec2))

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

(defmethod collides-p (object target hit) NIL)
(defmethod collides-p (object (target solid) hit) T)

(defmethod scan-collision (target region)
  (scan target region (type-tester 'solid)))

;; Handle common collision operations. Uses SCAN-COLLISION to find the closest
;; valid HIT, then invokes COLLIDE using that hit, if any. Returns the closest
;; HIT, if any.
(defun handle-collisions (target object)
  (let ((hit (scan-collision target region)))
    (when hit
      (collide object (hit-object hit) hit)
      hit)))

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
                   (or (null result)
                       (< (vlength (bsize at-point))
                          (vlength (bsize result)))))
          (setf result at-point)))))

(defmethod contained-p (thing target)
  (scan target thing (constantly T)))

(defmethod clone (thing)
  thing)

(defmethod clone ((vec vec2)) (vcopy2 vec))
(defmethod clone ((vec vec3)) (vcopy3 vec))
(defmethod clone ((vec vec4)) (vcopy4 vec))
(defmethod clone ((mat mat2)) (mcopy2 mat))
(defmethod clone ((mat mat3)) (mcopy3 mat))
(defmethod clone ((mat mat4)) (mcopy4 mat))
(defmethod clone ((mat matn)) (mcopyn mat))

(defmethod clone ((cons cons))
  (cons (clone (car cons)) (clone (cdr cons))))

(defmethod clone ((array array))
  (make-array (array-dimensions array)
              :element-type (array-element-type array)
              :adjustable (adjustable-array-p array)
              :fill-pointer (fill-pointer array)
              :initial-contents array))

(defmethod clone ((entity entity))
  (let ((initvalues ()))
    (loop for initarg in (initargs entity)
          for slot = (initarg-slot (class-of entity) initarg)
          do (push initarg initvalues)
             (push (clone (slot-value entity (c2mop:slot-definition-name slot))) initvalues))
    (apply #'make-instance (class-of entity) (nreverse initvalues))))

(defun mouse-world-pos (pos)
  (let ((camera (unit :camera T)))
    (let ((pos (nv+ (v/ pos (view-scale camera)) (location camera))))
      (nv- pos (v/ (target-size camera) (zoom camera))))))

(defun generate-name (&optional indicator)
  (intern (format NIL "~a-~d" (or indicator "ENTITY") (incf *gensym-counter*)) #.*package*))

(defclass request-region (event)
  ((region :initarg :region :reader region)))

(defclass switch-region (event)
  ((region :initarg :region :reader region)))

(defclass switch-chunk (event)
  ((chunk :initarg :chunk :reader chunk)))

(defun switch-chunk (chunk)
  (issue +world+ 'switch-chunk :chunk chunk))

(defclass unpausable () ())

(defclass ephemeral (entity)
  ((flare:name :initform (generate-name))))

(define-shader-entity player () ())
