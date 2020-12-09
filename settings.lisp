(in-package #:org.shirakumo.fraf.kandria)

(defvar *save-settings* T)
(define-global +settings+
    (copy-tree '(:audio (:latency 0.05
                         :volume (:master 0.5
                                  :effect 1.0
                                  :speech 1.0
                                  :music 1.0))
                 :display (:width 1280
                           :height 720
                           :fullscreen NIL
                           :vsync T
                           :ui-scale 1.0)
                 :camera (:screen-shake 1.0)
                 :language (:code :eng))))

(defun settings-path ()
  (make-pathname :name "settings" :type "lisp"
                 :defaults (config-directory)))

(defun keymap-path ()
  (make-pathname :name "keymap" :type "lisp"
                 :defaults (config-directory)))

(defun map-leaf-settings (function &optional (settings +settings+))
  (labels ((recurse (node rpath)
             (loop for (k v) on node by #'cddr
                   do (if (and (consp v) (keywordp (car v)))
                          (recurse v (list* k rpath))
                          (funcall function (reverse (list* k rpath)) v)))))
    (recurse settings ())))

(defun load-keymap (&optional path)
  (unless path
    (setf path (keymap-path))
    (ensure-directories-exist path)
    (unless (probe-file path)
      (uiop:copy-file (merge-pathnames "keymap.lisp" (root)) path)))
  (load-mapping path))

(defun load-settings (&optional (path (settings-path)))
  (ignore-errors
   (with-error-logging (:kandria.settings)
     (v:info :kandria.settings "Loading settings from ~a" path)
     (with-open-file (stream path :direction :input
                                  :element-type 'character
                                  :if-does-not-exist :error)
       (with-kandria-io-syntax
         (let ((*save-settings* NIL))
           (map-leaf-settings
            (lambda (path value)
              (apply #'(setf setting) value path))
            (loop for k = (read stream NIL '#1=#:eof)
                  until (eq k '#1#)
                  collect k)))))))
  +settings+)

(defun save-settings (&optional (path (settings-path)))
  (ignore-errors
   (with-error-logging (:kandria.settings)
     (v:info :kandria.settings "Saving settings to ~a" path)
     (with-open-file (stream path :direction :output
                                  :element-type 'character
                                  :if-exists :supersede)
       (with-kandria-io-syntax
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
           (plist 0 +settings+))))))
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
    (when *save-settings*
      (save-settings))
    value))
