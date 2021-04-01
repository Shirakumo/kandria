(in-package #:org.shirakumo.fraf.kandria)

(defclass region (layered-container ephemeral)
  ((name :initform 'test :initarg :name :accessor name :type symbol)
   (author :initform "Anonymous" :initarg :author :accessor author :type string)
   (version :initform "0.0.0" :initarg :version :accessor version :type string)
   (description :initform "" :initarg :description :accessor description :type string)
   (preview :initform NIL :initarg :preview :accessor preview)
   (chunk-graph :initform NIL :accessor chunk-graph)
   (bvh :initform (bvh:make-bvh) :reader bvh))
  (:default-initargs
   :layer-count +layer-count+))

(defgeneric load-region (packet region))
(defgeneric save-region (region packet &key version &allow-other-keys))

(defmethod save-region ((scene scene) target &rest args)
  (apply #'save-region (unit 'region scene) target args))

(defmethod save-region :around (region target &rest args &key (version T))
  (apply #'call-next-method region target :version (ensure-version version) args))

(defmethod save-region (region (pathname pathname) &key version (if-exists :supersede))
  (with-packet (packet pathname :direction :output :if-exists if-exists)
    (save-region region packet :version version)))

(defmethod save-region ((region region) (packet packet) &key version)
  (v:info :kandria.region "Saving ~a to ~a" region packet)
  (with-packet-entry (stream "meta.lisp" packet :element-type 'character)
    (princ* (list :identifier 'region :version (type-of version)) stream)
    (princ* (encode-payload region NIL packet version) stream)))

(defmethod load-region ((pathname pathname) scene)
  (with-packet (packet pathname :direction :input)
    (load-region packet scene)))

(defmethod load-region (thing (scene scene))
  (let ((new (load-region thing NIL)))
    (when (unit 'region scene)
      (leave (unit 'region scene) scene))
    (enter new scene)
    new))

(defmethod load-region ((packet packet) (null null))
  (v:info :kandria.region "Loading ~a" packet)
  (destructuring-bind (header info) (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character))
    (decode-payload
     info (type-prototype 'region) packet
     (destructuring-bind (&key identifier version) header
       (assert (eql 'region identifier))
       (coerce-version version)))))

(defmethod clear :after ((region region))
  (clear (bvh region)))

(defmethod enter :after ((unit collider) (region region))
  (bvh:bvh-insert (bvh region) unit))

(defmethod leave :after ((unit collider) (region region))
  (bvh:bvh-remove (bvh region) unit))

(defmethod scan ((region region) target on-hit)
  (bvh:do-fitting (object (bvh region) target)
    (let ((hit (scan object target on-hit)))
      (when hit (return hit)))))

(defmethod unit (name (region region))
  (for:for ((entity over region))
    (when (and (typep entity 'unit)
               (eql name (name entity)))
      (return entity))))
