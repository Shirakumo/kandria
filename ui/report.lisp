(in-package #:leaf)

(defun generate-report-files ()
  (let ((save (make-instance 'save-state :filename "report")))
    (save-state +world+ save)
    (remove-if-not (lambda (a) (probe-file (second a)))
                   `(("log" ,(trial:logfile))
                     ("screenshot" ,(capture NIL :file (tempfile)))
                     ("savestate" ,(file save))))))

(defun find-user-id ()
  (macrolet ((c ((p s) &rest args)
               `(if (find-symbol ,(string s) ,(string p))
                    (funcall (find-symbol ,(string s) ,(string p)) ,@args)
                    (error "No such symbol ~a:~a" ,(string p) ,(string s)))))
    (handler-case (format NIL "~a@steam" (c (org.shirakumo.fraf.steamworks steam-id) T))
      (error () "anonymous"))))

(defun submit-report (&key (user (find-user-id)) (files (generate-report-files)) description)
  (org.shirakumo.feedback.client:submit
   "kandria" user
   :version #.(asdf:component-version (asdf:find-system "leaf"))
   :description description
   :attachments files
   :key "A61C1370-B410-4BE5-96DB-1A2744628063"
   :secret "0533AD22-7729-4D91-AD4B-3967F74AA078"
   :token "D794637E-314B-4CE3-9FCA-55A3CF95146D"
   :token-secret "B9743038-1661-49E2-B363-C174D0761289"))

(defclass report-input (alloy:window)
  ((description :initform "" :accessor description))
  (:default-initargs :title "Report a bug"
                     :extent (alloy:extent 0 0 500 300)
                     :minimizable NIL
                     :maximizable NIL))

(defmethod alloy:accept ((input report-input))
  (handler-bind ((error (lambda (e)
                          (v:error :leaf.report e)
                          (messagebox "Failed to gather and submit report:~%~a" e)
                          (continue e))))
    (with-simple-restart (continue "Ignore the failed report.")
      (submit-report :description (description input))
      (alloy:leave input T))))

(defmethod initialize-instance :after ((input report-input) &key)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(T) :row-sizes '(T 30) :layout-parent input))
         (focus (make-instance 'alloy:focus-list :focus-parent input))
         (description (alloy:represent (slot-value input 'description) 'alloy:input-box
                                       :placeholder "Describe your feedback here"
                                       :layout-parent layout :focus-parent focus))
         (submit (alloy:represent "Submit" 'alloy:button
                                  :layout-parent layout :focus-parent focus)))
    (alloy:on alloy:activate (submit)
      (alloy:accept input))))
