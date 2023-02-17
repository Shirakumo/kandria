(in-package #:org.shirakumo.fraf.kandria)

(define-pool kandria)
(define-pool sound :base "sound/")
(define-pool music :base "music/")

(defvar *install-root* NIL)

(defun set-pool-paths-from-install (install)
  (setf *install-root* install)
  (pushnew *install-root* cffi:*foreign-library-directories* :test #'equalp)
  (setf (base (find-pool 'kandria)) (pathname-utils:subdirectory install "pool" "kandria"))
  (setf (base (find-pool 'music)) (pathname-utils:subdirectory install "pool" "music"))
  (setf (base (find-pool 'sound)) (pathname-utils:subdirectory install "pool" "sound")))

(let ((root #.(make-pathname :name NIL :type NIL :defaults (or *compile-file-pathname* *load-pathname*))))
  (cond ((probe-file (merge-pathnames "install/" root))
         (set-pool-paths-from-install (merge-pathnames "install/" root)))
        ((probe-file (merge-pathnames ".install" root))
         (let ((path (string-trim '(#\Linefeed #\Return #\Space) (uiop:read-file-string (merge-pathnames ".install" *kandria-root*)))))
           (set-pool-paths-from-install (pathname-utils:parse-native-namestring path :as :directory))))))

(define-asset (kandria 1x) mesh
    (make-rectangle 1 1 :align :bottomleft))

(define-asset (kandria 16x) mesh
    (make-rectangle 16 16))

(define-asset (kandria placeholder) image
    #p"placeholder.png")

(defclass collider () ())

(defmethod (setf location) :after (loc (collider collider))
  (when (container collider)
    (bvh:bvh-update (bvh (container collider)) collider)))

(defmethod (setf bsize) :after (loc (collider collider))
  (when (container collider)
    (bvh:bvh-update (bvh (container collider)) collider)))

(defclass parent-entity (entity)
  ((children :initform () :initarg :children :accessor children)
   (child-count :initform 0 :initarg :child-count :accessor child-count :type integer)))

(defgeneric make-child-entity (parent))

(defmethod (setf children) :after (children (entity parent-entity))
  (when (/= (length children) (child-count entity))
    (setf (child-count entity) (length children))))

(defmethod (setf child-count) :after (count (entity parent-entity))
  (loop while (< count (length (children entity)))
        for child = (pop (children entity))
        do (leave child T))
  (loop while (< (length (children entity)) count)
        for child = (make-child-entity entity)
        do (push child (children entity))
           (when (container entity)
             (trial:commit child (loader +main+) :unload NIL)
             (enter child (container entity)))))

(defmethod stage :after ((entity parent-entity) (area staging-area))
  (when (children entity)
    (stage (first (children entity)) area)))

(defmethod enter :after ((entity parent-entity) (container container))
  (dolist (child (children entity))
    (unless (container child)
      (enter child container))))

(defmethod leave :after ((entity parent-entity) (container container))
  (dolist (child (children entity))
    (when (container child)
      (leave child T))))

(defclass base-entity (entity)
  ((name :initarg :name :initform NIL :type symbol :documentation "The name of the entity")))

(defmethod entity-at-point (point (entity base-entity))
  (or (call-next-method)
      (when (contained-p point entity)
        entity)))

(defmethod initargs append ((_ base-entity))
  ())

(defclass located-entity (base-entity transformed)
  ((location :initarg :location :initform (vec 0 0) :accessor location
             :type vec2 :documentation "The location in 2D space.")))

(defmethod initargs append ((_ located-entity))
  `(:location))

(defmethod print-object ((entity located-entity) stream)
  (print-unreadable-object (entity stream :type T :identity T)
    (format stream "~@[~a ~]~a" (name entity) (location entity))))

(defmethod apply-transforms progn ((obj located-entity))
  (translate-by (round (vx (location obj))) (round (vy (location obj))) 0))

(defclass facing-entity (base-entity transformed)
  ((direction :initarg :direction :initform 1 :accessor direction
              :type integer :documentation "The direction the entity is facing. -1 for left, +1 for right.")))

(defmethod initargs append ((_ facing-entity))
  '(:direction))

(defmethod apply-transforms progn ((obj facing-entity))
  (scale-by (direction obj) 1 1))

(define-unit-resolver-methods direction (unit))
(define-unit-resolver-methods (setf direction) (direction unit))
(define-unit-resolver-methods location (unit))
(define-unit-resolver-methods (setf location) (location unit))

(defclass rotated-entity (base-entity transformed)
  ((angle :initarg :angle :initform 0f0 :accessor angle
          :type single-float :documentation "The angle the entity is pointing in.")))

(defmethod initargs append ((_ rotated-entity))
  '(:angle))

(defmethod apply-transforms progn ((obj rotated-entity))
  (let ((angle (angle obj)))
    (when (/= 0.0 angle)
      (rotate #.(vec 0 0 1) angle))))

(defclass sized-entity (located-entity)
  ((bsize :initarg :bsize :initform (nv/ (vec +tile-size+ +tile-size+) 2) :accessor bsize
          :type vec2 :documentation "The bounding box half size.")))

(defmethod initargs append ((_ sized-entity))
  `(:bsize))

(defmethod size ((entity sized-entity))
  (v* (bsize entity) 2))

(defmethod resize ((entity sized-entity) width height)
  (vsetf (bsize entity) (/ width 2) (/ height 2)))

(defmethod scan ((entity sized-entity) (target vec2) on-hit)
  (let ((w (vx2 (bsize entity)))
        (h (vy2 (bsize entity)))
        (loc (location entity)))
    (when (and (<= (- (vx2 loc) w) (vx2 target) (+ (vx2 loc) w))
               (<= (- (vy2 loc) h) (vy2 target) (+ (vy2 loc) h)))
      (let ((hit (make-hit entity (location entity))))
        (unless (funcall on-hit hit) hit)))))

(defmethod scan ((entity sized-entity) (target vec4) on-hit)
  (let ((bsize (bsize entity))
        (loc (location entity)))
    (when (and (< (abs (- (vx2 loc) (vx4 target))) (+ (vx2 bsize) (vz4 target)))
               (< (abs (- (vy2 loc) (vy4 target))) (+ (vy2 bsize) (vw4 target))))
      (let ((hit (make-hit entity (location entity))))
        (unless (funcall on-hit hit) hit)))))

(defmethod scan ((entity sized-entity) (target sized-entity) on-hit)
  (let ((vec (load-time-value (vec4 0 0 0 0)))
        (loc (location target))
        (bsize (bsize target)))
    (vsetf vec (vx2 loc) (vy2 loc) (vx2 bsize) (vy2 bsize))
    (scan entity vec on-hit)))

(define-shader-entity sprite-entity (vertex-entity textured-entity rotated-entity sized-entity facing-entity)
  ((vertex-array :initform (// 'kandria '1x))
   (texture :initform (// 'kandria 'placeholder) :initarg :texture :accessor albedo
            :type resource :documentation "The tileset to display the sprite from.")
   (size :initform (vec 16 16) :initarg :size :accessor size
         :type vec2 :documentation "The size of the tile to display (in px).")
   (offset :initform (vec 0 0) :initarg :offset :accessor offset
           :type vec2 :documentation "The offset in the tile map (in px).")
   (layer-index :initform (1- +base-layer+) :initarg :layer :accessor layer-index
                :type integer :documentation "The layer the sprite should be on.")
   (fit-to-bsize :initform T :initarg :fit-to-bsize :accessor fit-to-bsize
                 :type boolean)
   (color-mask :initform (vec 1 1 1 1) :accessor color-mask))
  (:inhibit-shaders (textured-entity :fragment-shader)))

(defmethod initargs append ((_ sprite-entity))
  '(:texture :size :offset :layer))

(defmethod initialize-instance :after ((sprite sprite-entity) &key bsize)
  (unless (size sprite)
    (setf (size sprite) (v* (bsize sprite) 2)))
  (unless bsize
    (setf (bsize sprite) (v/ (size sprite) 2))))

(defmethod apply-transforms progn ((sprite sprite-entity))
  (let ((size (bsize sprite)))
    (translate-by (- (vx2 size)) (- (vy2 size)) 0)
    (if (fit-to-bsize sprite)
        (scale-by (* 2 (vx2 size)) (* 2 (vy2 size)) 1.0)
        (scale-by (vx2 (size sprite)) (vy2 (size sprite)) 1.0))))

(defmethod render :before ((entity sprite-entity) (program shader-program))
  (setf (uniform program "size") (size entity))
  (setf (uniform program "offset") (offset entity))
  (setf (uniform program "color_mask") (color-mask entity)))

(defmethod resize ((sprite sprite-entity) width height)
  (vsetf (size sprite) width height)
  (vsetf (bsize sprite) (/ width 2) (/ height 2)))

(define-class-shader (sprite-entity :fragment-shader)
  "in vec2 texcoord;
out vec4 color;
uniform sampler2D texture_image;
uniform vec2 size;
uniform vec2 offset;
uniform vec4 color_mask = vec4(1,1,1,1);

void main(){
  color = texelFetch(texture_image, ivec2(offset+(texcoord*size)), 0);
  color *= color_mask;
}")

(defclass game-entity (sized-entity listener collider)
  ((velocity :initarg :velocity :initform (vec2 0 0) :accessor velocity
             :type vec2 :documentation "The velocity of the entity.")
   (state :initform :normal :accessor state
          :type symbol :documentation "The current state of the entity.")
   (frame-velocity :initform (vec2 0 0) :accessor frame-velocity)
   (chunk :initform NIL :initarg :chunk :accessor chunk)))

(defmethod layer-index ((_ game-entity)) +base-layer+)

;; KLUDGE: ugly way of avoiding allocations
(defmethod scan ((entity sized-entity) (target game-entity) on-hit)
  (let ((hit (aabb (location target) (frame-velocity target)
                   (location entity) (tv+ (bsize entity) (bsize target)))))
    (when hit
      (setf (hit-object hit) entity)
      (unless (funcall on-hit hit) hit))))

(defmethod scan ((entity game-entity) (target game-entity) on-hit)
  (let* ((vel (tv- (frame-velocity target)
                   (if (v= 0 (frame-velocity entity))
                       (velocity entity)
                       (frame-velocity entity))))
         (hit (aabb (location target) vel (location entity) (tv+ (bsize entity) (bsize target)))))
    (when hit
      (setf (hit-object hit) entity)
      (unless (funcall on-hit hit) hit))))

(defmethod oob ((entity entity) (none null))
  (unless (or (null (region +world+)) (find-panel 'editor))
    (setf (state entity) :oob)
    (leave entity T)))

(defmethod (setf chunk) :after (chunk (entity game-entity))
  (when (and chunk (eql :oob (state entity)))
    (setf (state entity) :normal)))

(defmethod oob ((entity entity) new-chunk)
  (setf (chunk entity) new-chunk))

(defun handle-oob (entity)
  (let ((other (find-chunk (location entity)))
        (chunk (chunk entity)))
    (cond ((eq other chunk))
          (other
           (oob entity other))
          ((or (null chunk)
               (< (vy (location entity))
                  (- (vy (location chunk))
                     (vy (bsize chunk)))))
           (oob entity NIL))
          (T
           (setf (vx (location entity)) (clamp (- (vx (location chunk))
                                                  (vx (bsize chunk)))
                                               (vx (location entity))
                                               (+ (vx (location chunk))
                                                  (vx (bsize chunk)))))
           (cond ((< (vy (location entity)) (- (vy (location chunk)) (vy (bsize chunk))))
                  (setf (vy (location entity)) (max (- (vy (location chunk))
                                                       (vy (bsize chunk))
                                                       (vy (bsize entity)))
                                                    (vy (location entity)))))
                 ((< (+ (vy (location chunk)) (vy (bsize chunk))) (vy (location entity)))
                  (setf (vy (location entity)) (min (vy (location entity))
                                                    (+ (vy (location chunk))
                                                       (vy (bsize chunk))
                                                       (vy (bsize entity))
                                                       -3)))))))))

(defmethod (setf location) (location (entity game-entity))
  (vsetf (location entity) (vx location) (vy location))
  (handle-oob entity))

(defmethod handle :after ((ev tick) (entity game-entity))
  (let ((vel (frame-velocity entity))
        (loc (location entity)))
    (incf (vx loc) (* (vx vel) 100 (dt ev)))
    (incf (vy loc) (* (vy vel) 100 (dt ev)))
    (vsetf vel 0 0)
    (bvh:bvh-update (bvh (region +world+)) entity)
    ;; OOB
    (case (state entity)
      ((:oob :dying))
      (T
       (when (or (null (chunk entity))
                 (not (contained-p (location entity) (chunk entity))))
         (handle-oob entity))))))

(defclass transition-event (event)
  ((on-complete :initarg :on-complete :initform NIL :reader on-complete)
   (kind :initarg :kind :initform :transition :reader kind)))

(defmacro transition (&body on-blank)
  (form-fiddle:with-body-options (body options (kind :transition)) on-blank
      `(issue +world+ 'transition-event
              :kind ,kind
              ,@options
              :on-complete (lambda () ,@body))))

(defun transition-active-p ()
  (let ((pass (unit 'fade +world+)))
    (< 0.00001 (strength pass))))

(defun nearby-p (thing &rest things)
  (flet ((resolve (thing)
           (etypecase thing
             (symbol (unit thing +world+))
             (entity thing)
             (vec thing)))
         (ensure-sized (x y w2 h2)
           (vec x y (max w2 32) (max h2 32))))
    (let* ((thing (resolve thing))
           (test-fun (etypecase thing
                       (vec2
                        (lambda (other)
                          (< (vsqrdistance (location other) thing) (expt 64 2))))
                       (vec4
                        (let ((thing (ensure-sized (vx thing) (vy thing) (vz thing) (vw thing))))
                          (lambda (other)
                            (contained-p (location other) thing))))
                       (chunk
                        (lambda (other)
                          (contained-p other thing)))
                       (game-entity
                        (lambda (other)
                          (< (vsqrdistance (location other) (location thing)) (expt 64 2))))
                       (sized-entity
                        (let ((thing (ensure-sized (vx (location thing)) (vy (location thing))
                                                   (vx (bsize thing)) (vy (bsize thing)))))
                          (lambda (other)
                            (contained-p thing other))))
                       (located-entity
                        (lambda (other)
                          (< (vsqrdistance (location other) (location thing)) (expt 64 2))))
                       (null
                        (lambda (other)
                          (declare (ignore other))
                          NIL)))))
      (loop for thing in things
            always (funcall test-fun (resolve thing))))))
