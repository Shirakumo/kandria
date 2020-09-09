(in-package #:leaf)

(defun capture-screenshot (file &key (x 0) (y 0) (width (width *context*)) (height (height *context*)))
  (let ((data (gl:read-pixels x y width height :rgb :unsigned-byte)))
    (zpng:write-png (make-instance 'zpng:png :color-type :truecolor
                                             :width width
                                             :height height
                                             :image-data data)
                    file)))

(defun generate-report-files ()
  (let ((save (make-instance 'save-state :filename "report")))
    (save-state +world+ save)
    `(("log" ,(trial:logfile))
      ("screenshot" ,(capture-screenshot (tempfile)))
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
   :token ""
   :token-secret ""))
