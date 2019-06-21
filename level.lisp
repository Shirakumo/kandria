(in-package #:org.shirakumo.fraf.leaf)

(defclass level (pipelined-scene)
  ((name :accessor name)
   (pause-stack :initform () :accessor pause-stack)))

(defmethod initialize-instance :after ((level level) &key)
  (issue level 'switch-level :level level))

(defmethod pause-game ((_ (eql T)) pauser)
  (pause-game +level+ pauser))

(defmethod unpause-game ((_ (eql T)) pauser)
  (unpause-game +level+ pauser))

(defmethod pause-game ((level level) pauser)
  (push (handlers level) (pause-stack level))
  (setf (handlers level) ())
  (for:for ((entity flare-queue:in-queue (objects level)))
    (when (or (typep entity 'unpausable)
              (typep entity 'controller)
              (eq entity pauser))
      (add-handler (handlers entity) level))))

(defmethod unpause-game ((level level) pauser)
  (when (pause-stack level)
    (setf (handlers level) (pop (pause-stack level)))))

(defmethod file ((level level))
  (pool-path 'leaf (make-pathname :name (format NIL "~(~a~)" (name level)) :type "zip"
                                  :directory '(:relative "map"))))

(defun scan-for (type level target)
  (for:for ((result as NIL)
            (entity flare-queue:in-queue (objects level)))
    (when (and (not (eq entity target))
               (typep entity type))
      (let ((hit (with-simple-restart (decline "Decline handling the collision.")
                   (scan entity target))))
        (when hit (setf result hit))))))

(defmethod scan ((level level) target)
  (for:for ((result as NIL)
            (entity flare-queue:in-queue (objects level)))
    (when (not (eq entity target))
      (let ((hit (with-simple-restart (decline "Decline handling the collision.")
                   (scan entity target))))
        (when hit (setf result hit))))))
