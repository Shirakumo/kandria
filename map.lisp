(in-package #:org.shirakumo.fraf.leaf)

(defparameter *id-type-map* '(;; Scenery
                              (chunk            #x0011)
                              (falling-platform #x0012)
                              ;; Items / Characters
                              (player           #x0021)
                              (interactable     #x0022)))
(defvar *version* 'v0)

(defun type->id (type-ish)
  (second (find (etypecase type-ish
                  (standard-object (class-name (class-of type-ish)))
                  (symbol type-ish))
                *id-type-map* :key #'first)))

(defun id->type (id)
  (first (find id *id-type-map* :key #'second)))

(defclass version () ())
(defclass v0 (version) ())

(defgeneric save-map (source target version))
(defgeneric load-map (source target version))

(defmethod save-map (source target (version (eql T)))
  (save-map source target (make-instance *version*)))

(defmethod load-map (source target (version (eql T)))
  (load-map source target (make-instance *version*)))

(defmethod save-map ((level level) (target (eql T)) version)
  (save-map level (file level) version))

(defmethod load-map ((source (eql T)) (level level) version)
  (load-map (file level) level version))

(defmethod save-map (source (file string) version)
  (save-map source (uiop:parse-native-namestring file) version))

(defmethod load-map ((file string) target version)
  (load-map (uiop:parse-native-namestring file) target version))

(defmethod save-map (source (file pathname) version)
  (ensure-directories-exist file)
  (with-open-file (out file :direction :output
                            :element-type '(unsigned-byte 8)
                            :if-exists :supersede)
    (let ((*default-pathname-defaults* file))
      (save-map source out version))))

(defmethod load-map ((file pathname) target version)
  (with-open-file (in file :direction :input
                           :element-type '(unsigned-byte 8))
    (let ((*default-pathname-defaults* file))
      (load-map in target version))))

(defmethod save-map (source (stream stream) (version v0))
  (fast-io:with-fast-output (buffer stream)
    (v:info :leaf.map "Saving ~a from ~a" stream source)
    (loop for char across "LEAF MAP"
          do (fast-io:fast-write-byte (char-code char) buffer))
    (save-map version buffer version)
    (save-map source buffer version)))

(defmethod load-map ((stream stream) target (version v0))
  (fast-io:with-fast-input (buffer NIL stream)
    (v:info :leaf.map "Loading ~a into ~a" stream target)
    (loop for char across "LEAF MAP"
          do (when (char/= char (code-char (fast-io:fast-read-byte buffer)))
               (error "Invalid map header.")))
    (let ((version (load-map buffer version version)))
      (load-map buffer target version))))

(defmacro define-saver ((type version) &rest args)
  (let ((version-instance (gensym "VERSION"))
        (object (gensym "OBJECT"))
        (method-combination (loop for option = (car args)
                                  until (listp option)
                                  collect (pop args))))
    (destructuring-bind ((buffer) &rest body) args
      `(defmethod save-map ,@method-combination ((,type ,type) (,buffer fast-io:output-buffer) (,version-instance ,version))
         (flet ((save (,object)
                  (save-map ,object ,buffer ,version-instance)))
           (declare (ignorable #'save))
           ,@body)))))

(trivial-indent:define-indentation define-saver (4 4 &body))

(defmacro define-loader ((type version) &rest args)
  (let ((version-instance (gensym "VERSION"))
        (object (gensym "OBJECT"))
        (method-combination (loop for option = (car args)
                                  until (listp option)
                                  collect (pop args))))
    (destructuring-bind ((buffer) &rest body) args
      `(defmethod load-map ,@method-combination ((,buffer fast-io:input-buffer) (,type ,type) (,version-instance ,version))
         (flet ((load (,object)
                  (load-map ,buffer
                            (if (symbolp ,object)
                                (type-prototype ,object)
                                ,object)
                            ,version-instance)))
           (declare (ignorable #'load))
           ,@body)))))

(trivial-indent:define-indentation define-loader (4 4 &body))

(define-saver (version v0) (buffer)
  (save (symbol-name (class-name (class-of version)))))

(define-loader (version v0) (buffer)
  (let ((version-name (load 'string)))
    (flet ((bail () (error "No such version ~s." version-name)))
      (let* ((symbol (or (find-symbol version-name #.*package*) (bail)))
             (class (or (find-class symbol NIL) (bail))))
        (unless (subtypep class 'version) (bail))
        (make-instance class)))))

(define-saver (scene v0) (buffer)
  (save (name scene))
  (for:for ((entity over scene)
            (id = (type->id entity)))
    (when id
      (fast-io:writeu16-le id buffer)
      (save entity))))

(define-loader (scene v0) (buffer)
  (setf (name scene) (load 'symbol))
  (loop for type = (handler-case (id->type (fast-io:readu16-le buffer))
                     (end-of-file (e)
                       (declare (ignore e))
                       (return)))
        for class = (maybe-finalize-inheritance (find-class type))
        for entity = (load (c2mop:class-prototype class))
        do (enter entity scene)))

(define-saver (player v0) (buffer)
  (save (spawn-location player)))

(define-loader (player v0) (buffer)
  (make-instance 'player :location (load 'vec2)))

(define-saver (chunk v0) (buffer)
  (with-new-value-restart ((slot-value chunk 'name)) (set-value "Set the name.")
    (unless (name chunk) (error "Cannot save nameless chunks!")))
  (save (name chunk))
  (save (location chunk))
  (fast-io:writeu16-le (car (size chunk)) buffer)
  (fast-io:writeu16-le (cdr (size chunk)) buffer)
  (fast-io:writeu16-le (tile-size chunk) buffer)
  (save (background chunk))
  (save (tileset chunk))
  (let* ((*print-case* :downcase)
         (path (format NIL "~(~a.~a~).raw"
                       (symbol-name (or (name +level+) :chunk))
                       (symbol-name (name chunk)))))
    (with-open-file (stream path :direction :output
                                 :element-type '(unsigned-byte 8)
                                 :if-exists :supersede)
      (write-sequence (tilemap chunk) stream))
    (save path)))

(define-loader (chunk v0) (buffer)
  (make-instance 'chunk
                 :name (load 'symbol)
                 :location (load 'vec2)
                 :size (cons (fast-io:readu16-le buffer)
                             (fast-io:readu16-le buffer))
                 :tile-size (fast-io:readu16-le buffer)
                 :background (load 'asset)
                 :tileset (load 'asset)
                 :tilemap (merge-pathnames (load 'string))))

(define-saver (falling-platform v0) (buffer)
  (call-next-method)
  (save (direction falling-platform)))

(define-loader (falling-platform v0) (buffer)
  (change-class (call-next-method) 'falling-platform
                :velocity (vec 0 0)
                :directiov (load 'vec2)))

(define-saver (sprite-entity v0) (buffer)
  (save (name entity))
  (save (location entity))
  (save (bsize entity))
  (fast-io:write8-le (direction entity) buffer)
  (save (texture entity))
  (save (trial:tile entity)))

(define-loader (sprite-entity v0) (buffer)
  (make-instance 'sprite-entity
                 :name (load 'symbol)
                 :location (load 'vec2)
                 :bsize (load 'vec2)
                 :direction (fast-io:read8-le buffer)
                 :texture (load 'asset)
                 :tile (load 'vec2)))

(define-saver (vec2 v0) (buffer)
  (fast-io:writeu32-le (ieee-floats:encode-float32 (vx2 vec2)) buffer)
  (fast-io:writeu32-le (ieee-floats:encode-float32 (vy2 vec2)) buffer))

(define-loader (vec2 v0) (buffer)
  (vec2 (ieee-floats:decode-float32 (fast-io:readu32-le buffer))
        (ieee-floats:decode-float32 (fast-io:readu32-le buffer))))

(define-saver (asset v0) (buffer)
  (save (name (or (pool asset)
                  (error "Cannot save unpooled asset ~s" asset))))
  (save (or (name asset)
            (error "Cannot save unnamed asset ~s" asset))))

(define-loader (asset v0) (buffer)
  (asset (load 'symbol) (load 'symbol) T))

(define-saver (symbol v0) (buffer)
  (save (package-name (symbol-package symbol)))
  (save (symbol-name symbol)))

(define-loader (symbol v0) (buffer)
  (let ((package (load 'string))
        (name (load 'string)))
    (intern name package)))

(define-saver (string v0) (buffer)
  (fast-io:fast-write-sequence (babel:string-to-octets string :encoding :utf-8) buffer)
  (fast-io:fast-write-byte 0 buffer))

(define-loader (string v0) (buffer)
  (let ((vector (make-array 32 :element-type '(unsigned-byte 8) :adjustable T :fill-pointer 0)))
    (loop for b = (fast-io:fast-read-byte buffer)
          until (= 0 b)
          do (vector-push-extend b vector))
    (babel:octets-to-string vector :encoding :utf-8)))
