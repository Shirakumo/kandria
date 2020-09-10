(in-package #:leaf)

(defun generate-report-files ()
  (let ((save (make-instance 'save-state :filename "report")))
    (save-state +world+ save)
    `(("log" ,(trial:logfile))
      ("screenshot" ,(capture NIL :file (tempfile)))
      ("savestate" ,(file save)))))

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

(defclass report-input (alloy:dialog)
  ((description :initform "" :accessor description))
  (:default-initargs :accept NIL :reject NIL :title "Report a bug"))

(defmethod alloy:reject ((input report-input)))

(defmethod alloy:accept ((input report-input))
  (handler-case
      (progn (submit-report :description (description input))
             (alloy:enter (make-instance 'messagebox :message "Report submitted. Thank you!")
                          (unit 'ui-pass T)))
    (error (e)
      (v:error :leaf.report e)
      (alloy:enter (make-instance 'messagebox :message (format NIL "Failed to gather and submit report:~%~a" e))
                   (unit 'ui-pass T)))))

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
