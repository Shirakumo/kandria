(in-package #:org.shirakumo.fraf.leaf)

(defun config-directory ()
  #+(or windows win32 mswindows)
  (merge-pathnames (make-pathname :directory '(:relative "AppData" "Local" "shirakumo" "leaf"))
                   (user-homedir-pathname))
  #-(or windows win32 mswindows)
  (merge-pathnames (make-pathname :directory '(:relative ".config" "shirakumo" "leaf"))
                   (user-homedir-pathname)))

(defun save-state-path (name)
  (make-pathname :name (format NIL "~(~a~)" name) :type "save"
                 :defaults (config-directory)))

(defclass save ()
  ((name :initarg :name :accessor name)
   (username :initarg :username :accessor username)
   (timestamp :initarg :timestamp :accessor timestamp))
  (:default-initargs
   :name (error "NAME required.")
   :username NIL
   :timestamp (get-universal-time)))

(defmethod print-object ((save save) stream)
  (print-unreadable-object (save stream :type T)
    (format stream "~s ~a" (name save) (format-absolute-time (timestamp save)))))

(defmethod file ((save save))
  (save-state-path (name save)))

(defun list-saves ()
  (mapcar #'minimal-load-state
          (directory (make-pathname :name :wild :type "save" :defaults (config-directory)))))

(defmethod minimal-load-state (file)
  (with-open-file (in file
                      :direction :input
                      :element-type 'character)
    (let ((*default-pathname-defaults* file)
          (*read-eval* NIL)
          (*package* #.*package*))
      (load-state (make-instance 'save :name (pathname-name file)) in))))

(defmethod save-state ((main main) (save save))
  (v:info :leaf.state "Saving state ~a" save)
  (with-open-file (out (ensure-directories-exist (file save))
                       :direction :output
                       :element-type 'character
                       :if-exists :supersede)
    (let ((*default-pathname-defaults* (file save))
          (*print-case* :downcase)
          (*package* #.*package*))
      (format out ";; -*- Mode: common-lisp -*-~%")
      (save-state save out)
      (save-state main out))))

(defmethod load-state ((main main) (save save))
  (v:info :leaf.state "Loading state ~a" save)
  (with-open-file (in (file save)
                      :direction :input
                      :element-type 'character)
    (let ((*default-pathname-defaults* (file save))
          (*read-eval* NIL)
          (*package* #.*package*))
      (load-state save in)
      (load-state main in))))

(defmethod save-state (object (stream stream))
  (format stream "~&~s~%" (list* (type-of object) (state-data object))))

(defmethod load-state (object (stream stream))
  (destructuring-bind (type &rest data) (read stream)
    (load-state-into object type data)))

(defmethod load-state-into :around (object type data)
  (call-next-method)
  object)

(defmethod state-data ((save save))
  (list :username (username save)
        :timestamp (timestamp save)))

(defmethod load-state-into ((save save) (type (eql 'save)) (data cons))
  (destructuring-bind (&key username timestamp) data
    (setf (username save) username)
    (setf (timestamp save) timestamp)))

(defmethod save-state ((main main) (stream stream))
  (save-state (scene main) stream))

(defmethod load-state ((main main) (stream stream))
  (handler-case
      (loop (call-next-method))
    (end-of-file (e)
      (declare (ignore e)))))

(defmethod state-data ((world world))
  (let ((entries ()))
    (for:for ((entity over world))
      (when (find-method #'state-data () (list (class-of entity)) NIL)
        (push (list* (type-of entity) (state-data entity)) entries)))
    (list* (name world)
           (nreverse entries))))

(defmethod load-state-into ((main main) (type (eql 'world)) (data cons))
  (destructuring-bind (name &rest entries) data
    (let ((world (if (eq name (name (scene main)))
                     (scene main)
                     (load T (make-instance 'world :name name) T))))
      (loop for (type . data) in entries
            do (load-state-into world type data))
      (change-scene main world))))

(defmethod state-data ((player player))
  (list (name player) (vapply (spawn-location player) floor)))

(defmethod load-state-into ((world world) (type (eql 'player)) data)
  (destructuring-bind (name (_ x y)) data
    (declare (ignore _))
    (let ((player (unit name world)))
      (vsetf (location player) x y)
      (vsetf (spawn-location player) x y))))
