(in-package #:org.shirakumo.fraf.kandria)

(defvar *async-task-thread* NIL)

(defclass task-thread ()
  ((runner :initform (make-instance 'simple-tasks:queued-runner) :accessor runner)
   (thread :initform NIL :accessor thread)))

(defmethod start ((thread task-thread))
  (unless (and (thread thread)
               (bt:thread-alive-p (thread thread)))
    (setf (thread thread)
          (with-thread ("task-thread")
            (simple-tasks:start-runner (runner thread))))
    (loop until (eql :running (simple-tasks:status (runner thread))))))

(defmethod stop ((thread task-thread))
  (handler-case (simple-tasks:stop-runner (runner thread))
    (simple-tasks:runner-not-stopped ()
      (wait-for-thread-exit (thread runner)))))

(defmethod simple-tasks:schedule-task :before (task (thread task-thread))
  (start thread))

(defmethod simple-tasks:schedule-task (task (thread task-thread))
  (simple-tasks:schedule-task task (runner thread)))

(defclass ui-task (simple-tasks:call-task)
  ())

(defmethod simple-tasks:run-task ((task ui-task))
  (with-unwind-protection (! (hide-panel 'spinner-panel))
    (handler-case
        (with-error-logging (:kandria.async)
          (! (show-panel 'spinner-panel))
          (call-next-method))
      (not-authenticated ()
        (message (@ error-not-authenticated)))
      (usocket:ns-error ()
        (message (@ error-no-internet)))
      (usocket:socket-error ()
        (message (@ error-connection-failed-try-again)))
      (error (e)
        (message (@formats 'error-generic e))))))

(defmacro with-ui-task (&body body)
  (let ((ok (gensym "OK")))
    `(promise:with-promise (,ok)
       (flet ((thunk ()
                (funcall ,ok (progn ,@body))))
         (simple-tasks:schedule-task
          (make-instance 'ui-task :func #'thunk)
          *async-task-thread*)))))

(setf *async-task-thread* (make-instance 'task-thread))
