
(defun aseprite (&rest args)
  (uiop:run-program (list* #-windows "aseprite" #+windows "aseprite.exe"
                           "-b"
                           (loop for arg in args
                                 collect (typecase arg
                                           (pathname (uiop:native-namestring arg))
                                           (T (princ-to-string arg)))))
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
      (aseprite "--sheet-pack"
                "--trim"
                "--shape-padding" "1"
                "--sheet" png
                "--format" "json-array"
                "--filename-format" "{tagframe} {tag}"
                "--list-tags"
                "--data" json
                file)
      ;; Make sure we have LF.
      (re-encode-json json)
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
      (aseprite file
                "--layer" "albedo"
                "--save-as" albedo)
      (aseprite file
                "--layer" "absorption"
                "--save-as" absorption)
      (aseprite file
                "--layer" "normal"
                "--save-as" normal))))

(asdf:defsystem kandria-data
  :serial NIL
  :depends-on (zpng pngload jsown)
  :components ((:file "palette-convert")
               (:module "sprites"
                :pathname ""
                :depends-on ("palette-convert")
                :components
                ((spritesheet "player")
                 (spritesheet "fi")
                 (spritesheet "catherine")
                 (spritesheet "jack")
                 (spritesheet "wolf")
                 (spritesheet "effects")
                 (spritesheet "dummy")
                 (spritesheet "balloon")
                 (spritesheet "debug-door")
                 (spritesheet "box")
                 (spritesheet "zombie")
                 (spritesheet "ruddydrone")
                 (spritesheet "player-profile")
                 (spritesheet "fi-profile")
                 (tilemap "debug")
                 (tilemap "tundra")
                 (tilemap "desert")))))
