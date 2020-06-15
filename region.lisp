(in-package #:org.shirakumo.fraf.leaf)

(defclass region (layered-container ephemeral)
  ((author :initform "Anonymous" :initarg :author :accessor author)
   (version :initform "0.0.0" :initarg :version :accessor version)
   (description :initform "" :initarg :description :accessor description)
   (preview :initform NIL :initarg :preview :accessor preview))
  (:default-initargs
   :layer-count +layer-count+
   :name (error "NAME required.")))

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
  (v:info :leaf.region "Saving ~a to ~a" region packet)
  (with-packet-entry (stream "meta.lisp" packet :element-type 'character)
    (princ* (list :identifier 'region :version (type-of version)) stream)
    (princ* (encode-payload region NIL packet version) stream)))

(defmethod load-region ((pathname pathname) scene)
  (with-packet (packet pathname :direction :input)
    (load-region packet scene)))

(defmethod load-region (thing (scene scene))
  (enter (load-region thing NIL) scene))

(defmethod load-region ((packet packet) (null null))
  (v:info :leaf.region "Loading ~a" packet)
  (destructuring-bind (header info) (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character))
    (decode-payload
     info (type-prototype 'region) packet
     (destructuring-bind (&key identifier version) header
       (assert (eql 'region identifier))
       (coerce-version version)))))

(defmethod scan ((region region) target on-hit)
  (for:for ((entity over region)
            (hit = (scan entity target on-hit)))
    (when hit (return hit))))
