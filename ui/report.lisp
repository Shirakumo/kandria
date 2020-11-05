(in-package #:kandria)

(defun generate-report-files ()
  (let ((save (make-instance 'save-state :filename "report")))
    (save-state +world+ save)
    (remove-if-not (lambda (a) (probe-file (second a)))
                   `(("log" ,(trial:logfile))
                     ("screenshot" ,(capture NIL :file (tempfile)))
                     ("savestate" ,(file save))))))

(defun find-user-id ()
  (error-or
   (format NIL "~a@steam [~a]"
           (call steam/steam-id T)
           (call steam/display-name T))
   (pathname-utils:directory-name (user-homedir-pathname))
   "anonymous"))

(defun submit-report (&key (user (find-user-id)) (files (generate-report-files)) description)
  (handler-bind ((error (lambda (e)
                          (v:debug :kandria.report e)
                          (v:error :kandria.report "Failed to submit report: ~a" e))))
    (org.shirakumo.feedback.client:submit
     "kandria" user
     :version (version :kandria)
     :description description
     :attachments files
     :key "A61C1370-B410-4BE5-96DB-1A2744628063"
     :secret "0533AD22-7729-4D91-AD4B-3967F74AA078"
     :token "D794637E-314B-4CE3-9FCA-55A3CF95146D"
     :token-secret "B9743038-1661-49E2-B363-C174D0761289")))

(defclass report-panel (pausing-panel)
  ())

(defmethod initialize-instance :after ((panel report-panel) &key)
  (let* ((description "")
         (username (or (setting :username) (find-user-id)))
         (layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
         (focus (make-instance 'alloy:focus-list))
         (user (alloy:represent username 'alloy:input-line :placeholder "anonymous"))
         (desc (alloy:represent description 'alloy:input-box :placeholder "Describe your feedback here"))
         (submit (alloy:represent "Submit" 'alloy:button)))
    (alloy:enter desc layout :constraints `((:bottom 40) (:left 10) (:size 300 300)))
    (alloy:enter user layout :constraints `((:above ,desc 10) (:left 10) (:size 300 20)))
    (alloy:enter submit layout :constraints `((:below ,desc 10) (:left 10) (:size 300 20)))
    (alloy:enter-all focus user desc submit)
    (alloy:on alloy:activate (submit)
      (setf (setting :username) (find-user-id))
      (handler-bind ((error (lambda (e)
                              (v:error :kandria.report e)
                              (messagebox "Failed to gather and submit report:~%~a" e)
                              (continue e))))
        (with-simple-restart (continue "Ignore the failed report.")
          (let ((report (submit-report :user (if (string= "" username) "anonymous" username) :description description)))
            (status "Report submitted (#~d). Thank you!" (gethash "_id" report)))
          (hide panel))))
    (alloy:finish-structure panel layout focus)))

(defun standalone-error-handler (err)
  (when (deploy:deployed-p)
    (v:error :trial err)
    (v:fatal :trial "Encountered unhandled error in ~a, bailing." (bt:current-thread))
    (cond ((string/= "" (or (uiop:getenv "DEPLOY_DEBUG_BOOT") ""))
           (invoke-debugger err))
          ((ignore-errors (submit-report :description (format NIL "Hard crash due to error:~%~a" err)))
           (org.shirakumo.messagebox:show (format NIL "An unhandled error occurred. A log has been sent to the developers. Sorry for the inconvenience!")
                                          :title "Unhandled Error" :type :error :modal T))
          (T
           (org.shirakumo.messagebox:show (format NIL "An unhandled error occurred. Please send the application logfile to the developers. You can find it here:~%~%~a"
                                                  (uiop:native-namestring (logfile)))
                                          :title "Unhandled Error" :type :error :modal T)))
    (deploy:quit)))

(defclass report-button (panel)
  ())

(defmethod initialize-instance :after ((panel report-button) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (focus (make-instance 'alloy:focus-list))
        (button (alloy:represent "Submit Feedback" 'alloy:button
                                 :style `((:background :pattern ,colors:accent)
                                          (:label :pattern ,colors:white)))))
    (alloy:enter button layout :constraints `((:right 0) (:top 0) (:size 200 30)))
    (alloy:enter button focus)
    (alloy:on alloy:activate (button)
      (unless (find-panel 'report-panel)
        (show (make-instance 'report-panel))))
    (alloy:finish-structure panel layout focus)))
