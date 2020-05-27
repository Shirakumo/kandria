(in-package #:org.shirakumo.fraf.leaf)

(defmacro define-global (name value)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (if (boundp ',name)
         (setf ,name ,value)
         (sb-ext:defglobal ,name ,value))))

(define-global +tile-size+ 16)
(define-global +layer-count+ 5)
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

(defun kw (thing)
  (intern (string-upcase thing) "KEYWORD"))

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

(defun clamp (low mid high)
  (max low (min mid high)))

(defun invclamp (low mid high)
  (cond ((< mid low) 0.0)
        ((< high mid) 1.0)
        (T (/ (- mid low) (- high low)))))

(defun absinvclamp (low mid high)
  (* (signum mid) (invclamp low (abs mid) high)))

(defun damp* (damp &rest factors)
  (- 1 (apply #'* (- 1 damp) factors)))

(define-compiler-macro damp* (damp &rest factors)
  `(- 1 (* (- 1 ,damp) ,@factors)))

(defun lerp (from to n)
  (+ (* from (- 1 n)) (* to n)))

(defun ->rad (deg)
  (* PI (/ deg 180)))

(defun ->deg (rad)
  (/ (* rad 180) PI))

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

(defmethod contained-p ((target vec2) thing)
  NIL)

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

(define-pool leaf
  :base :leaf)

(define-asset (leaf 1x) mesh
    (make-rectangle 1 1 :align :bottomleft))

(define-asset (leaf 16x) mesh
    (make-rectangle 16 16))

(define-asset (leaf placeholder) image
    #p"placeholder.png")

(defgeneric initargs (object)
  (:method-combination append :most-specific-last))

(defclass base-entity (entity)
  ())

(defmethod entity-at-point (point (entity base-entity))
  (or (call-next-method)
      (when (contained-p point entity)
        entity)))

(defmethod initargs append ((_ base-entity))
  '(:name))

(defclass solid () ())
(defclass resizable () ())

(defclass located-entity (base-entity)
  ((location :initarg :location :initform (vec 0 0) :accessor location
             :type vec2 :documentation "The location in 2D space.")))

(defmethod initargs append ((_ located-entity))
  `(:location))

(defmethod print-object ((entity located-entity) stream)
  (print-unreadable-object (entity stream :type T :identity T)
    (format stream "~a" (location entity))))

(defmethod paint :around ((obj located-entity) target)
  (with-pushed-matrix ()
    (translate-by (round (vx (location obj))) (round (vy (location obj))) 0)
    (call-next-method)))

(defclass facing-entity (base-entity)
  ((direction :initarg :direction :initform 1 :accessor direction
              :type (integer -1 1) :documentation "The direction the entity is facing. -1 for left, +1 for right.")))

(defmethod initargs append ((_ facing-entity))
  '(:direction))

(defmethod paint :around ((obj facing-entity) target)
  (with-pushed-matrix ()
    (scale-by (direction obj) 1 1)
    (call-next-method)))

(defclass sized-entity (located-entity)
  ((bsize :initarg :bsize :initform (nv/ (vec +tile-size+ +tile-size+) 2) :accessor bsize
          :type vec2 :documentation "The bounding box half size.")))

(defmethod initargs append ((_ sized-entity))
  `(:bsize))

(defmethod scan ((entity sized-entity) (target vec2))
  (let ((w (vx (bsize entity)))
        (h (vy (bsize entity)))
        (loc (location entity)))
    (when (and (<= (- (vx loc) w) (vx target) (+ (vx loc) w))
               (<= (- (vy loc) h) (vy target) (+ (vy loc) h)))
      entity)))

(defmethod scan ((entity sized-entity) (target vec4))
  (let ((bsize (bsize entity))
        (loc (location entity)))
    (when (and (< (abs (- (vx loc) (vx target))) (+ (vx bsize) (vz target)))
               (< (abs (- (vy loc) (vy target))) (+ (vy bsize) (vw target))))
      entity)))

(defmethod contained-p ((target vec2) (entity sized-entity))
  (scan entity target))

(defmethod contained-p ((target vec4) (entity sized-entity))
  (scan entity target))

(define-shader-entity sprite-entity (trial:sprite-entity sized-entity facing-entity)
  ((vertex-array :initform (asset 'leaf '1x))
   (frame :initform 0
          :type integer :documentation "The tile to display from the sprite sheet.")
   (texture :initform (asset 'leaf 'placeholder)
            :type asset :documentation "The tileset to display the sprite from.")
   (size :initform NIL
         :type vec2 :documentation "The size of the tile to display.")))

(defmethod initargs append ((_ sprite-entity))
  '(:tile :texture))

(defmethod initialize-instance :after ((sprite sprite-entity) &key)
  (unless (size sprite)
    (setf (size sprite) (v* (bsize sprite) 2))))

(defmethod (setf bsize) :after (value (sprite sprite-entity))
  (setf (size sprite) (v* value 2)))

(defmethod paint :before ((sprite sprite-entity) target)
  (let ((size (v* 2 (bsize sprite))))
    (translate-by (/ (vx size) -2) (/ (vy size) -2) 0)
    (scale (vxy_ size))))

(defmethod resize ((sprite sprite-entity) width height)
  (vsetf (size sprite) width height)
  (vsetf (bsize sprite) (/ width 2) (/ height 2)))

(define-subject game-entity (sized-entity)
  ((velocity :initarg :velocity :initform (vec2 0 0) :accessor velocity
             :type vec2 :documentation "The velocity of the entity.")
   (state :initform :normal :accessor state
          :type symbol :documentation "The current state of the entity.")
   (surface :initform NIL :accessor surface)))

(define-generic-handler (game-entity tick trial:tick))

(defmethod enter :after ((entity game-entity) (container container))
  (setf (surface entity) container))

(defmethod leave :after ((entity game-entity) (container container))
  (setf (surface entity) NIL))

(defmethod scan ((entity sized-entity) (target game-entity))
  (let ((hit (aabb (location target) (velocity target)
                   (location entity) (v+ (bsize entity) (bsize target)))))
    (when hit
      (setf (hit-object hit) entity)
      hit)))

(defmethod scan ((entity game-entity) (target game-entity))
  (let ((hit (aabb (location target) (v- (velocity target) (velocity entity))
                   (location entity) (v+ (bsize entity) (bsize target)))))
    (when hit
      (setf (hit-object hit) entity)
      hit)))

(defclass trigger (sized-entity)
  ((event-type :initarg :event-type :initform () :accessor event-type
               :type class :documentation "The type of the event that should be triggered.")
   (event-initargs :initarg :event-initargs :initform () :accessor event-initargs
                   :type list :documentation "The list of initargs for the triggered event.")
   (active-p :initarg :active-p :initform T :accessor active-p)))

(defmethod initargs append ((_ trigger))
  `(:event-type :event-initargs))

(defmethod fire ((trigger trigger))
  (apply #'issue +world+ (event-type trigger) (event-initargs trigger))
  (setf (active-p trigger) NIL))

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

(define-shader-subject player () ())
