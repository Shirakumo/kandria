(in-package #:org.shirakumo.fraf.kandria)

(define-condition unsupported-save-file (error)
  ())

(defun save-state-path (name)
  (ensure-directories-exist
   (make-pathname :name (format NIL "~(~a~)" name) :type "zip"
                  :defaults (config-directory))))

(defclass save-state ()
  ((author :initarg :author :accessor author)
   (id :initarg :id :accessor id)
   (start-time :initarg :start-time :accessor start-time)
   (save-time :initarg :save-time :accessor save-time)
   (play-time :initarg :play-time :accessor play-time)
   (image :initarg :image :initform NIL :accessor image)
   (file :initarg :file :accessor file))
  (:default-initargs
   :id (make-uuid)
   :author (pathname-utils:directory-name (user-homedir-pathname))
   :start-time (get-universal-time)
   :save-time (get-universal-time)
   :play-time (total-play-time)))

(defmethod initialize-instance :after ((save-state save-state) &key (filename ""))
  (unless (slot-boundp save-state 'file)
    (setf (file save-state) (merge-pathnames filename (save-state-path (start-time save-state))))))

(defmethod print-object ((save-state save-state) stream)
  (print-unreadable-object (save-state stream :type T)
    (format stream "~s ~s" (author save-state) (file save-state))))

(defmethod exists-p ((save-state save-state))
  (probe-file (file save-state)))

(defun string<* (a b)
  (if (= (length a) (length b))
      (string< a b)
      (< (length a) (length b))))

(defmethod clone ((state save-state) &rest initargs)
  (apply #'make-instance 'save-state
         (append initargs
                 (list :author (author state)
                       :id (id state)
                       :start-time (start-time state)
                       :save-time (save-time state)
                       :play-time (play-time state)
                       :image (image state)
                       :filename (file-namestring (file state))))))

(defun list-saves ()
  (sort
   (loop for file in (directory (merge-pathnames "*.zip" (config-directory)))
         for state = (handler-case (minimal-load-state file)
                       (unsupported-save-file ()
                         (v:warn :kandria.save "Save state ~s is too old, ignoring." file)
                         NIL)
                       (error (e)
                         (v:warn :kandria.save "Save state ~s failed to load, ignoring." file)
                         (v:debug :kandria.save e)
                         NIL))
         when state collect state)
   #'string<* :key (lambda (f) (pathname-name (file f)))))

(defun delete-saves ()
  (dolist (save (list-saves))
    (delete-file (file save))))

(defun minimal-load-state (file)
  (depot:with-depot (depot file)
    (destructuring-bind (header initargs)
        (parse-sexps (depot:read-from (depot:entry "meta.lisp" depot) 'character))
      (assert (eq 'save-state (getf header :identifier)))
      (unless (supported-p (make-instance (getf header :version)))
        (cerror "Try it anyway." 'unsupported-save-file))
      (when (depot:entry-exists-p "image.png" depot)
        ;; KLUDGE: This fucking sucks, yo.
        (let ((temp (tempfile :type "png" :id (format NIL "kandria-~a" (pathname-name file)))))
          (depot:with-open (in (depot:entry "image.png" depot) :input '(unsigned-byte 8))
            (with-open-file (out temp :direction :output :if-exists :supersede :element-type '(unsigned-byte 8))
              (uiop:copy-stream-to-stream (depot:to-stream in) out :element-type '(unsigned-byte 8))))
          (push temp initargs)
          (push :image initargs)))
      (apply #'make-instance 'save-state :file file initargs))))

(defgeneric load-state (state world))
(defgeneric save-state (world state &key version &allow-other-keys))

(defmethod save-state ((world (eql T)) save &rest args)
  (apply #'call-next-method +world+ save args))

(defmethod save-state :around (world target &rest args &key (version T))
  (apply #'call-next-method world target :version (ensure-version version (current-save-version)) args))

(defmethod save-state ((world world) (save-state save-state) &key version show)
  (when (and show (unit 'ui-pass world))
    (toggle-panel 'save-done))
  (v:info :kandria.save "Saving state from ~a to ~a" world save-state)
  (setf (save-time save-state) (get-universal-time))
  (with-timing-report (:info :kandria.save "Saved state in ~fs run time, ~fs clock time.")
    (let ((tmp (make-pathname :type "zip" :name "temp" :defaults (file save-state))))
      (uiop:delete-file-if-exists tmp)
      (depot:with-depot (depot tmp :commit T)
        (depot:with-open (tx (depot:ensure-entry "meta.lisp" depot) :output 'character)
          (let ((stream (depot:to-stream tx)))
            (princ* (list :identifier 'save-state :version (type-of version)) stream)
            (princ* (list :id (id save-state)
                          :author (author save-state)
                          :start-time (start-time save-state)
                          :save-time (save-time save-state)
                          :play-time (play-time save-state))
                    stream)))
        (unless (setting :debugging :dont-save-screenshot)
          (depot:with-open (tx (depot:ensure-entry "image.png" depot) :output '(unsigned-byte 8))
            (render +world+ NIL)
            (let ((temp (tempfile :type "png" :id (format NIL "kandria-~a" (pathname-name (file save-state))))))
              (capture (unit 'render +world+) :target-width 192 :target-height 108 :file temp)
              (with-open-file (in temp :direction :input :element-type '(unsigned-byte 8))
                (uiop:copy-stream-to-stream in (depot:to-stream tx) :element-type '(unsigned-byte 8))))))
        (encode-payload world NIL depot version))
      (rename-file* tmp (file save-state))))
  save-state)

(defmethod load-state ((save-state save-state) world)
  (load-state (file save-state) world))

(defmethod load-state (state (world (eql T)))
  (load-state state +world+))

(defmethod load-state ((integer integer) world)
  (load-state (save-state-path integer) world))

(defmethod load-state ((pathname pathname) world)
  (depot:with-depot (depot pathname)
    (load-state depot world)))

(defmethod load-state ((depot depot:depot) (world world))
  (v:info :kandria.save "Loading state from ~a into ~a" depot world)
  (with-timing-report (:info :kandria.save "Restored save in ~fs run time, ~fs clock time.")
    (destructuring-bind (header initargs)
        (parse-sexps (depot:read-from (depot:entry "meta.lisp" depot) 'character))
      (assert (eq 'save-state (getf header :identifier)))
      (when (unit 'distortion T)
        (setf (strength (unit 'distortion T)) 0.0))
      (when (unit 'walkntalk world)
        (walk-n-talk NIL))
      (when (find-panel 'hud)
        (hide-timer))
      (let ((bg (unit 'background T)))
        (when bg
          (setf (background bg) (background 'black))
          (update-background bg T)))
      (setf (action-lists world) ())
      (setf (area-states (unit 'environment world)) NIL)
      (let ((version (coerce-version (getf header :version))))
        (decode-payload NIL world depot version)
        (apply #'make-instance 'save-state initargs)))))

(defun submit-trace (state &optional (player (unit 'player +world+)))
  (v:info :kandria.save "Submitting trace...")
  (let ((file (tempfile :type "dat"))
        (trace (movement-trace player)))
    (trial::with-unwind-protection (delete-file file)
      (with-open-file (stream file :direction :output :element-type '(unsigned-byte 8))
        (loop for float across trace
              do (unless (or (float-features:float-nan-p float)
                             (float-features:float-infinity-p float))
                   (nibbles:write-ieee-single/le float stream))))
      (ignore-errors
       (trial:with-error-logging (:kandria.save)
         (org.shirakumo.fraf.trial.feedback:submit-snapshot
          (id state) (play-time state) (session-time) :trace file))))))

(defun resume-state (resume &optional (main +main+))
  (unwind-protect (load-game resume main)
    (let ((state (find (id resume) (list-saves) :key #'id :test #'equalp)))
      (cond ((equalp (file state) (file resume)))
            (state
             (v:info :kandria.save "Resuming state ~a."
                     (id resume) (file resume))
             (setf (state main) state))
            (T
             (v:severe :kandria.save "Failed to find original save file with id ~a that this resume file is branched from! Replacing save 4."
                       (id resume))
             (setf (file resume) (rename-file (file resume) (make-pathname :name "4" :defaults (file resume)))))))))
