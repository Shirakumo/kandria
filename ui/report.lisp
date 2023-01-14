(in-package #:kandria)

(defparameter org.shirakumo.fraf.trial.feedback:*client-args*
  '(:key "A61C1370-B410-4BE5-96DB-1A2744628063"
    :secret "0533AD22-7729-4D91-AD4B-3967F74AA078"
    :token "D794637E-314B-4CE3-9FCA-55A3CF95146D"
    :token-secret "B9743038-1661-49E2-B363-C174D0761289"))

(org.shirakumo.fraf.trial.feedback:define-report-hook kandria ()
  (when +world+
    `(("savestate" ,(file (save-state +world+ (clone (state +main+) :filename "report")))))))

(defclass report-panel (pausing-panel menuing-panel)
  ())

(defclass report-dialog (alloy:dialog)
  ((username :initform "anonymous" :accessor username)
   (description :initform "" :accessor description))
  (:default-initargs
   :title "Submit Feedback"
   :extent (alloy:size 300 500)
   :accept "Submit" :reject NIL))

(defmethod alloy:close :after ((dialog report-dialog))
  (hide-panel 'report-panel))

(defmethod alloy:accept ((dialog report-dialog))
  (handler-bind ((error (lambda (e)
                          (v:error :kandria.report e)
                          (messagebox "Failed to gather and submit report:~%~a" e)
                          (continue e))))
    (with-simple-restart (continue "Ignore the failed report.")
      (let* ((username (username dialog))
             (description (description dialog))
             (report (org.shirakumo.fraf.trial.feedback:submit-report
                      :user (if (string= "" username) "anonymous" username)
                      :description description)))
        (status (@formats 'feedback-report-submitted (gethash "_id" report)))
        (let ((save (find "report" (list-saves) :key (lambda (s) (pathname-name (file s))) :test #'string=)))
          (when save (delete-file (file save)))))
      (hide-panel 'report-panel))))

(defmethod initialize-instance :after ((dialog report-dialog) &key)
  (unless (setting :username)
    (setf (setting :username) (org.shirakumo.fraf.trial.feedback::find-user-id)))
  (setf (username dialog) (setting :username))
  (let ((layout (make-instance 'alloy:grid-layout :col-sizes '(T) :row-sizes '(30 T) :layout-parent dialog))
        (focus (make-instance 'alloy:focus-list :focus-parent dialog)))
    (alloy:represent (username dialog) 'alloy:input-line
                     :placeholder "anonymous" :layout-parent layout :focus-parent focus)
    (alloy:represent (description dialog) 'alloy:input-box
                     :placeholder "Describe your feedback here" :layout-parent layout :focus-parent focus)))

(defmethod initialize-instance :after ((panel report-panel) &key)
  (alloy:finish-structure panel (make-instance 'alloy:fixed-layout) NIL))

(defmethod show :after ((panel report-panel) &key)
  (make-instance 'report-dialog :ui (unit 'ui-pass T)))

(defmethod hide :after ((panel report-panel))
  (alloy:do-elements (el (alloy:popups (alloy:layout-tree (unit 'ui-pass T))))
    (alloy:leave el T)))
