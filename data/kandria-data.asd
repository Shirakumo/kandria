
(defun aseprite (file &rest args)
  (uiop:run-program (list* #-windows "aseprite" #+windows "aseprite.exe"
                           "-b" (uiop:native-namestring file)
                           args)
                    :output *standard-output*
                    :error-output *error-output*))

(defclass static-compile-file (asdf:file-component)
  ())

(defmethod asdf:perform ((o asdf:load-op) (c static-compile-file)))

(defmethod asdf:needed-in-image-p ((o asdf:compile-op) (c static-compile-file))
  (destructuring-bind (file) (asdf:input-files o c)
    (loop for output in (asdf:output-files o c)
          thereis (or (null (probe-file output))
                      (< (file-write-date output)
                         (file-write-date file))))))

(defclass spritesheet (static-compile-file)
  ((asdf/component::type :initform "ase")))

;; Needs to be around to prevent ASDF from doing its shitty translation crap.
(defmethod asdf:output-files :around ((o asdf:compile-op) (c spritesheet))
  (destructuring-bind (file) (asdf:input-files o c)
    (list (make-pathname :type "json" :defaults file)
          (make-pathname :type "png" :defaults file))))

(defmethod asdf:perform ((o asdf:compile-op) (c spritesheet))
  (destructuring-bind (file) (asdf:input-files o c)
    (format *error-output* "~& Compiling ~a~%" file)
    (destructuring-bind (json png) (asdf:output-files o c)
      (aseprite (uiop:native-namestring file)
                "--format" "json-array"
                "--sheet-pack"
                "--trim"
                "--shape-padding" "1"
                "--filename-format" "{tagframe} {tag}"
                "--data" (uiop:native-namestring json)
                "--sheet" (uiop:native-namestring png)
                "--list-tags")
      ;; Convert palette colours
      (let ((lisp (make-pathname :type "lisp" :defaults json)))
        (when (probe-file lisp)
          (let ((palette (with-open-file (stream lisp)
                           (getf (read stream) :palette))))
            (when palette
              (format *error-output* "~& Converting palette~%")
              (convert-palette png (merge-pathnames palette lisp)))))))))

(defclass tilemap (static-compile-file)
  ((asdf/component::type :initform "ase")))

(defmethod asdf:output-files :around ((o asdf:compile-op) (c tilemap))
  (destructuring-bind (file) (asdf:input-files o c)
    (flet ((name (name)
             (format NIL "~a-~a" (pathname-name file) name)))
      (list (make-pathname :name (name "albedo") :type "png" :defaults file)
            (make-pathname :name (name "absorption") :type "png" :defaults file)
            (make-pathname :name (name "normal") :type "png" :defaults file)))))

(defmethod asdf:perform ((o asdf:compile-op) (c tilemap))
  (destructuring-bind (file) (asdf:input-files o c)
    (format T "~& Compiling ~a~%" file)
    (destructuring-bind (albedo absorption normal) (asdf:output-files o c)
      (aseprite (uiop:native-namestring file)
                "--layer" "albedo"
                "--save-as" (uiop:native-namestring albedo))
      (aseprite (uiop:native-namestring file)
                "--layer" "absorption"
                "--save-as" (uiop:native-namestring absorption))
      (aseprite (uiop:native-namestring file)
                "--layer" "normal"
                "--save-as" (uiop:native-namestring normal)))))

(asdf:defsystem kandria-data
  :serial T
  :depends-on (zpng pngload)
  :components ((:file "palette-convert")
               (spritesheet "player")
               (spritesheet "player-profile")
               (spritesheet "fi")
               (spritesheet "fi-profile")
               (spritesheet "wolf")
               (spritesheet "effects")
               (spritesheet "dummy")
               (spritesheet "balloon")
               (spritesheet "debug-door")
               (spritesheet "box")
               (spritesheet "zombie")
               (tilemap "debug")
               (tilemap "tundra")))
