(in-package #:org.shirakumo.fraf.leaf)

(defun save-state-path (name)
  (ensure-directories-exist
   (make-pathname :name (format NIL "~(~a~)" name) :type "zip"
                  :defaults (config-directory))))

(defclass save-state ()
  ((author :initarg :author :accessor author)
   (start-time :initarg :start-time :accessor start-time)
   (save-time :initarg :save-time :accessor save-time)
   (file :initarg :file :accessor file))
  (:default-initargs
   :author (pathname-utils:directory-name (user-homedir-pathname))
   :start-time (get-universal-time)
   :save-time (get-universal-time)))

(defmethod initialize-instance :after ((save-state save-state) &key (filename ""))
  (unless (slot-boundp save-state 'file)
    (setf (file save-state) (merge-pathnames filename (save-state-path (start-time save-state))))))

(defmethod print-object ((save-state save-state) stream)
  (print-unreadable-object (save-state stream :type T)
    (format stream "~s ~a" (author save-state) (format-absolute-time (save-time save-state)))))

(defun list-saves ()
  (loop for file in (directory (make-pathname :name :wild :type "save" :defaults (config-directory)))
        collect (minimal-load-state file)))

(defun minimal-load-state (file)
  (with-packet (packet file)
    (destructuring-bind (header initargs)
        (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character))
      (assert (eq 'save-state (getf header :identifier)))
      (apply #'make-instance 'save-state :file file initargs))))

(defun current-save-version ()
  (make-instance 'save-v0))

(defgeneric load-state (state world))
(defgeneric save-state (world state &key version &allow-other-keys))

(defmethod save-state ((world (eql T)) save &rest args)
  (apply #'call-next-method +world+ save args))

(defmethod save-state :around (world target &rest args &key (version T))
  (apply #'call-next-method world target :version (ensure-version version (current-save-version)) args))

(defmethod save-state ((world world) (save-state save-state) &key version)
  (v:info :leaf.save "Saving state from ~a to ~a" world save-state)
  (with-packet (packet (file save-state) :direction :output :if-exists :supersede)
    (with-packet-entry (stream "meta.lisp" packet :element-type 'character)
      (princ* (list :identifier 'save-state :version (type-of version)) stream)
      (princ* (list :author (author save-state)
                    :start-time (start-time save-state)
                    :save-time (save-time save-state))
              stream))
    (encode-payload world NIL packet version)))

(defmethod load-state ((save-state save-state) world)
  (load-state (file save-state) world))

(defmethod load-state (state (world (eql T)))
  (load-state state +world+))

(defmethod load-state ((integer integer) world)
  (load-state (save-state-path integer) world))

(defmethod load-state ((pathname pathname) world)
  (with-packet (packet pathname)
    (load-state packet world)))

(defmethod load-state ((packet packet) (world world))
  (v:info :leaf.save "Loading state from ~a into ~a" packet world)
  (destructuring-bind (header initargs)
      (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character))
    (assert (eq 'save-state (getf header :identifier)))
    (let ((version (coerce-version (getf header :version))))
      (decode-payload NIL world packet version)
      (apply #'make-instance 'save-state initargs))))
