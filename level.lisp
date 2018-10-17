(in-package #:org.shirakumo.fraf.leaf)

(defclass level (pipelined-scene)
  ((file :initform NIL :initarg :file :accessor file)))

(defmethod initialize-instance :after ((level level) &key file)
  (when file (load-level level file)))

(defmethod save-level ((level level) (target (eql T)))
  (save-level level (file level)))

(defmethod load-level ((level level) (target (eql T)))
  (load-level level (file level)))

(defmethod save-level (object (file string))
  (save-level object (uiop:parse-native-namestring file)))

(defmethod load-level (object (file string))
  (load-level object (uiop:parse-native-namestring file)))

(defmethod save-level (object (file pathname))
  (with-open-file (out file :direction :output
                            :element-type '(unsigned-byte 8)
                            :if-exists :supersede)
    (save-level object out)))

(defmethod load-level (object (file pathname))
  (with-open-file (in file :direction :input
                           :element-type '(unsigned-byte 8))
    (load-level object in)))

(defmethod save-level (object (stream stream))
  (fast-io:with-fast-output (buffer stream)
    (v:info :leaf.map "Saving ~a from ~a" stream object)
    (loop for char across "LEAF MAP"
          do (fast-io:fast-write-byte (char-code char) buffer))
    (save-level object buffer)))

(defmethod load-level (object (stream stream))
  (fast-io:with-fast-input (buffer NIL stream)
    (v:info :leaf.map "Loading ~a into ~a" stream object)
    (loop for char across "LEAF MAP"
          do (when (char/= char (code-char (fast-io:fast-read-byte buffer)))
               (error "Invalid map header.")))
    (load-level object buffer)))

(defmethod save-level ((scene scene) (buffer fast-io:output-buffer))
  (for:for ((entity over scene))
    (save-level entity buffer)))

(defmethod load-level ((scene scene) (buffer fast-io:input-buffer))
  (handler-case
      (loop for id = (fast-io:readu16-le buffer)
            do (enter (load-level id buffer) scene))
    (end-of-file (e)
      scene)))

(defmethod save-level (thing (buffer fast-io:output-buffer)))

(defmethod save-level ((player player) (buffer fast-io:output-buffer))
  ;; FIXME: Change this to a spawner that can handle intro transitions
  (fast-io:writeu16-le 1 buffer)
  (fast-io:writeu32-le (ieee-floats:encode-float32 (vx (location player))) buffer)
  (fast-io:writeu32-le (ieee-floats:encode-float32 (vy (location player))) buffer))

(defmethod load-level ((id (eql 1)) (buffer fast-io:input-buffer))
  (make-instance 'player :location (vec (ieee-floats:decode-float32 (fast-io:readu32-le buffer))
                                        (ieee-floats:decode-float32 (fast-io:readu32-le buffer))
                                        0)))

(defmethod save-level ((layer layer) (buffer fast-io:output-buffer))
  (fast-io:writeu16-le 2 buffer)
  (fast-io:writeu16-le (first (size layer)) buffer)
  (fast-io:writeu16-le (second (size layer)) buffer)
  (fast-io:writeu16-le (level layer) buffer)
  (fast-io:writeu16-le (tile-size layer) buffer)
  (save-level (texture layer) buffer)
  (fast-io:writeu32-le (length (tiles layer)) buffer)
  (fast-io:fast-write-sequence (tiles layer) buffer))

(defmethod load-level ((id (eql 2)) (buffer fast-io:input-buffer))
  (make-instance
   'layer :size (list (fast-io:readu16-le buffer)
                      (fast-io:readu16-le buffer))
          :level (fast-io:readu16-le buffer)
          :tile-size (fast-io:readu16-le buffer)
          :texture (load-level 'asset buffer)
          :tiles (let* ((size (fast-io:readu32-le buffer))
                        (tiles (make-array size :element-type '(unsigned-byte 8))))
                   (loop for start = 0 then read
                         for read = (fast-io:fast-read-sequence tiles buffer start)
                         while (< read (length tiles)))
                   tiles)))

(defmethod save-level ((asset asset) (buffer fast-io:output-buffer))
  (fast-io:fast-write-sequence (babel:string-to-octets (package-name (symbol-package (name asset))) :encoding :utf-8) buffer)
  (fast-io:fast-write-byte 0 buffer)
  (fast-io:fast-write-sequence (babel:string-to-octets (symbol-name (name asset)) :encoding :utf-8) buffer)
  (fast-io:fast-write-byte 0 buffer))

(defmethod load-level ((asset (eql 'asset)) (buffer fast-io:input-buffer))
  (let ((vector (make-array 0 :element-type '(unsigned-byte 8) :adjustable T :fill-pointer 0)))
    (loop for b = (fast-io:fast-read-byte buffer)
          until (= 0 b)
          do (vector-push-extend b vector))
    (let ((package (babel:octets-to-string vector :encoding :utf-8)))
      (setf (fill-pointer vector) 0)
      (loop for b = (fast-io:fast-read-byte buffer)
            until (= 0 b)
            do (vector-push-extend b vector))
      (let ((name (babel:octets-to-string vector :encoding :utf-8)))
        (asset 'leaf (find-symbol name package))))))
