(in-package #:org.shirakumo.fraf.kandria)

(defclass region (layered-container ephemeral)
  ((name :initform 'test :initarg :name :accessor name :type symbol)
   (author :initform "Anonymous" :initarg :author :accessor author :type string)
   (version :initform "0.0.0" :initarg :version :accessor version :type string)
   (description :initform "" :initarg :description :accessor description :type string)
   (preview :initform NIL :initarg :preview :accessor preview)
   (chunk-graph :initform NIL :accessor chunk-graph)
   (bvh :initform (bvh:make-bvh) :reader bvh)
   (depot :initarg :depot :accessor depot))
  (:default-initargs
   :layer-count +layer-count+))

(defgeneric load-region (depot region))
(defgeneric save-region (region depot &key version &allow-other-keys))

(defmethod save-region ((scene scene) target &rest args)
  (apply #'save-region (unit 'region scene) target args))

(defmethod save-region :around (region target &rest args &key (version T))
  (apply #'call-next-method region target :version (ensure-version version) args))

(defmethod save-region (region (pathname pathname) &key version (if-exists :supersede))
  (let ((depot (depot:realize-entry (depot:from-pathname pathname) T)))
    (save-region region depot :version version)
    (depot:commit depot)))

(defmethod save-region ((region region) (depot depot:depot) &key version)
  (v:info :kandria.region "Saving ~a to ~a" region depot)
  (depot:with-open (tx (depot:ensure-entry "meta.lisp" depot) :output 'character)
    (let ((stream (depot:to-stream tx)))
      (princ* (list :identifier 'region :version (type-of version)) stream)
      (princ* (encode-payload region NIL depot version) stream))))

(defmethod load-region ((pathname pathname) scene)
  (depot:with-depot (depot pathname)
    (load-region depot scene)))

(defmethod load-region (thing (scene scene))
  (let ((new (load-region thing NIL)))
    (when (unit 'region scene)
      (leave (unit 'region scene) scene))
    ;; KLUDGE: This is fucking shitty, but we have to ensure that
    ;;         the fader always comes after the region...
    (enter new scene)
    new))

(defmethod chunk-graph ((region region))
  (or (slot-value region 'chunk-graph)
      (setf (chunk-graph region) (make-chunk-graph region))))

(defmethod load-region ((depot depot:depot) (null null))
  (v:info :kandria.region "Loading ~a" depot)
  (destructuring-bind (header info) (parse-sexps (depot:read-from (depot:entry "meta.lisp" depot) 'character))
    (decode-payload
     info (type-prototype 'region) depot
     (destructuring-bind (&key identifier version) header
       (assert (eql 'region identifier))
       (coerce-version version)))))

(defmethod clear :after ((region region))
  (clear (bvh region)))

(defmethod enter :after ((unit sized-entity) (region region))
  (bvh:bvh-insert (bvh region) unit))

(defmethod leave :after ((unit sized-entity) (region region))
  (bvh:bvh-remove (bvh region) unit))

(defmethod scan ((region region) target on-hit)
  (bvh:do-fitting (object (bvh region) target)
    (unless (eq object target)
      (let ((hit (scan object target on-hit)))
        (when hit
          (return hit))))))

(defmethod scan ((region region) (target game-entity) on-hit)
  (let ((loc (location target))
        (bsize (bsize target)))
    (with-tvec (vec (- (vx2 loc) (vx2 bsize) 20)
                    (- (vy2 loc) (vy2 bsize) 20)
                    (+ (vx2 loc) (vx2 bsize) 20)
                    (+ (vy2 loc) (vy2 bsize) 20))
      (bvh:do-fitting (object (bvh region) vec)
        (unless (eq object target)
          (let ((hit (scan object target on-hit)))
            (when hit (return hit))))))))

(defmethod scan ((region region) (target vec4) on-hit)
  (with-tvec (vec (- (vx4 target) (vz4 target))
                  (- (vy4 target) (vw4 target))
                  (+ (vx4 target) (vz4 target))
                  (+ (vy4 target) (vw4 target)))
    (bvh:do-fitting (object (bvh region) vec)
      (let ((hit (scan object target on-hit)))
        (when hit (return hit))))))

(defmethod unit (name (region region))
  (for:for ((entity over region))
    (when (and (typep entity 'unit)
               (eql name (name entity)))
      (return entity))))

(defmethod bsize ((region region))
  (let ((x- most-positive-fixnum)
        (x+ most-negative-fixnum)
        (y- most-positive-fixnum)
        (y+ most-negative-fixnum))
    (flet ((expand (loc bs)
             (setf x- (min x- (- (vx loc) (vx bs))))
             (setf x+ (max x+ (+ (vx loc) (vx bs))))
             (setf y- (min y- (- (vy loc) (vy bs))))
             (setf y+ (max y+ (+ (vy loc) (vy bs))))))
      (for:for ((entity over region))
        (when (typep entity 'sized-entity)
          (expand (location entity) (bsize entity)))))
    (vec (/ (- x+ x-) 2)
         (/ (- y+ y-) 2))))
