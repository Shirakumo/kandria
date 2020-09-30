(in-package #:org.shirakumo.fraf.leaf)

(define-global +settings+
    (copy-tree '(:audio (:latency 0.05
                         :volume (:master 0.5
                                  :effect 1.0
                                  :speech 1.0
                                  :music 1.0))
                 :display (:width 1280
                           :height 720
                           :fullscreen NIL
                           :vsync T))))

(defun settings-path ()
  (make-pathname :name "settings" :type "lisp"
                 :defaults (config-directory)))

(defun load-settings (&optional (path (settings-path)))
  (with-error-logging (:kandria.settings)
    (v:info :kandria.settings "Loading settings from ~a" path)
    (ignore-errors
     (with-open-file (stream path :direction :input
                                  :element-type 'character
                                  :if-does-not-exist NIL)
       (when stream
         (with-leaf-io-syntax
           (setf +settings+ (loop for k = (read stream NIL '#1=#:eof)
                                  until (eq k '#1#)
                                  collect k)))))))
  +settings+)

(defun save-settings (&optional (path (settings-path)))
  (with-error-logging (:kandria.settings)
    (v:info :kandria.settings "Saving settings to ~a" path)
    (with-open-file (stream path :direction :output
                                 :element-type 'character
                                 :if-exists :supersede)
      (with-leaf-io-syntax
        (labels ((plist (indent part)
                   (loop for (k v) on part by #'cddr
                         do (format stream "~&~v{ ~}~s " (* indent 2) '(0) k)
                            (serialise indent v)))
                 (serialise (indent part)
                   (typecase part
                     (cons
                      (cond ((keywordp (car part))
                             (format stream "(")
                             (plist (1+ indent) part)
                             (format stream ")"))
                            (T
                             (prin1 part stream))))
                     (null
                      (format stream "NIL"))
                     (T
                      (prin1 part stream)))))
          (plist 0 +settings+)))))
  +settings+)

(defun setting (&rest path)
  (loop with node = (or +settings+ (load-settings))
        for key in path
        for next = (getf node key '#1=#:not-found)
        do (if (eq next '#1#)
               (return (values NIL NIL))
               (setf node next))
        finally (return (values node T))))

(defun (setf setting) (value &rest path)
  (labels ((update (node key path)
             (setf (getf node key)
                   (if path
                       (update (getf node key) (first path) (rest path))
                       value))
             node))
    (setf +settings+ (update +settings+ (first path) (rest path)))
    (save-settings)
    value))
