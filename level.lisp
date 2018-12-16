(in-package #:org.shirakumo.fraf.leaf)

(defparameter *id-type-map* '((player 1)
                              (parallax 2)
                              (chunk 3)
                              (falling-platform 4)
                              (interactable 5)))

(defclass level (pipelined-scene)
  ((name :accessor name)
   (pause-stack :initform () :accessor pause-stack)))

(defmethod pause-game ((_ (eql T)) pauser)
  (pause-game +level+ pauser))

(defmethod unpause-game ((_ (eql T)) pauser)
  (unpause-game +level+ pauser))

(defmethod pause-game ((level level) pauser)
  (push (handlers level) (pause-stack level))
  (setf (handlers level) ())
  (for:for ((entity flare-queue:in-queue (objects level)))
    (when (or (typep entity 'unpausable)
              (typep entity 'controller)
              (eq entity pauser))
      (add-handler (handlers entity) level))))

(defmethod unpause-game ((level level) pauser)
  (when (pause-stack level)
    (setf (handlers level) (pop (pause-stack level)))))

(defmethod paint :before ((level level) target)
  (let ((*paint-background-p* T))
    (for:for ((entity flare-queue:in-queue (objects level)))
      (when (typep entity 'background)
        (paint entity target)))))

(defmethod file ((level level))
  (pool-path 'leaf (make-pathname :name (format NIL "~(~a~)" (name level)) :type "map"
                                  :directory '(:relative "map"))))

(defun scan-for (type level target)
  (for:for ((result as NIL)
            (entity flare-queue:in-queue (objects level)))
    (when (and (not (eq entity target))
               (typep entity type))
      (let ((hit (with-simple-restart (decline "Decline handling the collision.")
                   (scan entity target))))
        (when hit (setf result hit))))))

(defmethod scan ((level level) target)
  (for:for ((result as NIL)
            (entity flare-queue:in-queue (objects level)))
    (when (not (eq entity target))
      (let ((hit (with-simple-restart (decline "Decline handling the collision.")
                   (scan entity target))))
        (when hit (setf result hit))))))

(defun type->id (type-ish)
  (second (find (etypecase type-ish
                  (standard-object (class-name (class-of type-ish)))
                  (symbol type-ish))
                *id-type-map* :key #'first)))

(defun id->type (id)
  (first (find id *id-type-map* :key #'second)))

(defmethod save-level ((level level) (target (eql T)))
  (save-level level (file level)))

(defmethod load-level ((level level) (target (eql T)))
  (load-level level (file level)))

(defmethod save-level (object (file string))
  (save-level object (uiop:parse-native-namestring file)))

(defmethod load-level (object (file string))
  (load-level object (uiop:parse-native-namestring file)))

(defmethod save-level (object (file pathname))
  (ensure-directories-exist file)
  (with-open-file (out file :direction :output
                            :element-type '(unsigned-byte 8)
                            :if-exists :supersede)
    (let ((*default-pathname-defaults* file))
      (save-level object out))))

(defmethod load-level (object (file pathname))
  (with-open-file (in file :direction :input
                           :element-type '(unsigned-byte 8))
    (let ((*default-pathname-defaults* file))
      (load-level object in))))

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
  (save-level (name scene) buffer)
  (for:for ((entity over scene)
            (id = (type->id entity)))
    (when id
      (fast-io:writeu16-le id buffer)
      (save-level entity buffer)))
  scene)

(defmethod load-level ((scene scene) (buffer fast-io:input-buffer))
  (setf (name scene) (load-level 'symbol buffer))
  (loop for type = (handler-case (id->type (fast-io:readu16-le buffer))
                     (end-of-file (e)
                       (declare (ignore e))
                       (return)))
        for class = (maybe-finalize-inheritance (find-class type))
        for entity = (load-level (c2mop:class-prototype class) buffer)
        do (enter entity scene))
  scene)

(defmethod save-level ((player player) (buffer fast-io:output-buffer))
  (save-level (spawn-location player) buffer))

(defmethod load-level ((player player) (buffer fast-io:input-buffer))
  (make-instance 'player :location (load-level 'vec2 buffer)))

(defmethod save-level ((parallax parallax) (buffer fast-io:output-buffer))
  (save-level (texture parallax) buffer))

(defmethod load-level ((parallax parallax) (buffer fast-io:input-buffer))
  (make-instance
   'parallax :texture (load-level 'asset buffer)))

(defmethod save-level ((platform falling-platform) (buffer fast-io:output-buffer))
  (call-next-method)
  (save-level (direction platform) buffer))

(defmethod load-level ((platform falling-platform) (buffer fast-io:input-buffer))
  (let ((layer (call-next-method)))
    (change-class layer 'falling-platform
                  :velocity (vec 0 0)
                  :direction (load-level 'vec2 buffer))))

(defmethod save-level ((chunk chunk) (buffer fast-io:output-buffer))
  (save-level (name chunk) buffer)
  (save-level (location chunk) buffer)
  (fast-io:writeu16-le (car (size chunk)) buffer)
  (fast-io:writeu16-le (cdr (size chunk)) buffer)
  (fast-io:writeu16-le (tile-size chunk) buffer)
  (save-level (tileset chunk) buffer)
  (let* ((*print-case* :downcase)
         (path (format NIL "~a.~a.raw"
                       (symbol-name (or (name +level+) :chunk))
                       (symbol-name (name chunk)))))
    (with-open-file (stream path :direction :output
                                 :element-type '(unsigned-byte 8)
                                 :if-exists :supersede)
      (write-sequence (tilemap chunk) stream))
    (save-level path buffer)))

(defmethod load-level ((chunk chunk) (buffer fast-io:input-buffer))
  (make-instance
   'chunk :name (load-level 'symbol buffer)
          :location (load-level 'vec2 buffer)
          :size (cons (fast-io:readu16-le buffer)
                      (fast-io:readu16-le buffer))
          :tile-size (fast-io:readu16-le buffer)
          :tileset (load-level 'asset buffer)
          :tilemap (merge-pathnames (load-level 'string buffer)
                                    *default-pathname-defaults*)))

(defmethod save-level ((entity sprite-entity) (buffer fast-io:output-buffer))
  (save-level (name entity) buffer)
  (save-level (location entity) buffer)
  (save-level (bsize entity) buffer)
  (fast-io:write8-le (direction entity) buffer)
  (save-level (texture entity) buffer)
  (save-level (trial:tile entity) buffer))

(defmethod load-level ((sprite sprite-entity) (buffer fast-io:input-buffer))
  (make-instance
   'sprite-entity :name (load-level 'symbol buffer)
                  :location (load-level 'vec2 buffer)
                  :bsize (load-level 'vec2 buffer)
                  :direction (fast-io:read8-le buffer)
                  :texture (load-level 'asset buffer)
                  :tile (load-level 'vec2 buffer)))

(defmethod save-level ((vec vec2) (buffer fast-io:output-buffer))
  (fast-io:writeu32-le (ieee-floats:encode-float32 (vx2 vec)) buffer)
  (fast-io:writeu32-le (ieee-floats:encode-float32 (vy2 vec)) buffer))

(defmethod load-level ((type (eql 'vec2)) (buffer fast-io:input-buffer))
  (vec2 (ieee-floats:decode-float32 (fast-io:readu32-le buffer))
        (ieee-floats:decode-float32 (fast-io:readu32-le buffer))))

(defmethod save-level ((asset asset) (buffer fast-io:output-buffer))
  (save-level (name asset) buffer))

(defmethod load-level ((type (eql 'asset)) (buffer fast-io:input-buffer))
  (asset 'leaf (load-level 'symbol buffer)))

(defmethod save-level ((symbol symbol) (buffer fast-io:output-buffer))
  (save-level (package-name (symbol-package symbol)) buffer)
  (save-level (symbol-name symbol) buffer))

(defmethod load-level ((type (eql 'symbol)) (buffer fast-io:input-buffer))
  (let ((package (load-level 'string buffer))
        (name (load-level 'string buffer)))
    (intern name package)))

(defmethod save-level ((string string) (buffer fast-io:output-buffer))
  (fast-io:fast-write-sequence (babel:string-to-octets string :encoding :utf-8) buffer)
  (fast-io:fast-write-byte 0 buffer))

(defmethod load-level ((type (eql 'string)) (buffer fast-io:input-buffer))
  (let ((vector (make-array 32 :element-type '(unsigned-byte 8) :adjustable T :fill-pointer 0)))
    (loop for b = (fast-io:fast-read-byte buffer)
          until (= 0 b)
          do (vector-push-extend b vector))
    (babel:octets-to-string vector :encoding :utf-8)))
