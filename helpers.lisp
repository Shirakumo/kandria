(in-package #:org.shirakumo.fraf.leaf)

(define-pool leaf)

(define-asset (leaf 1x) mesh
    (make-rectangle 1 1 :align :bottomleft))

(define-asset (leaf 16x) mesh
    (make-rectangle 16 16))

(define-asset (leaf placeholder) image
    #p"placeholder.png")

(defgeneric initargs (object)
  (:method-combination append :most-specific-last))

(defclass base-entity (renderable entity)
  ((name :initarg :name :initform NIL :type symbol :documentation "The name of the entity")))

(defmethod entity-at-point (point (entity base-entity))
  (or (call-next-method)
      (when (contained-p point entity)
        entity)))

(defmethod initargs append ((_ base-entity))
  '(:name))

(defclass located-entity (base-entity transformed)
  ((location :initarg :location :initform (vec 0 0) :accessor location
             :type vec2 :documentation "The location in 2D space.")))

(defmethod initargs append ((_ located-entity))
  `(:location))

(defmethod print-object ((entity located-entity) stream)
  (print-unreadable-object (entity stream :type T :identity T)
    (format stream "~a" (location entity))))

(defmethod apply-transforms progn ((obj located-entity))
  (translate-by (round (vx (location obj))) (round (vy (location obj))) 0))

(defclass facing-entity (base-entity transformed)
  ((direction :initarg :direction :initform 1 :accessor direction
              :type (integer -1 1) :documentation "The direction the entity is facing. -1 for left, +1 for right.")))

(defmethod initargs append ((_ facing-entity))
  '(:direction))

(defmethod apply-transforms progn ((obj facing-entity))
  (scale-by (direction obj) 1 1))

(defclass sized-entity (located-entity)
  ((bsize :initarg :bsize :initform (nv/ (vec +tile-size+ +tile-size+) 2) :accessor bsize
          :type vec2 :documentation "The bounding box half size.")))

(defmethod initargs append ((_ sized-entity))
  `(:bsize))

(defmethod scan ((entity sized-entity) (target vec2) on-hit)
  (let ((w (vx (bsize entity)))
        (h (vy (bsize entity)))
        (loc (location entity)))
    (when (and (<= (- (vx loc) w) (vx target) (+ (vx loc) w))
               (<= (- (vy loc) h) (vy target) (+ (vy loc) h)))
      (let ((hit (make-hit entity (location entity))))
        (unless (funcall on-hit hit) hit)))))

(defmethod scan ((entity sized-entity) (target vec4) on-hit)
  (let ((bsize (bsize entity))
        (loc (location entity)))
    (when (and (< (abs (- (vx loc) (vx target))) (+ (vx bsize) (vz target)))
               (< (abs (- (vy loc) (vy target))) (+ (vy bsize) (vw target))))
      (let ((hit (make-hit entity (location entity))))
        (unless (funcall on-hit hit) hit)))))

(defmethod scan ((entity sized-entity) (target sized-entity) on-hit)
  (scan entity (vec4 (vx (location target)) (vy (location target))
                     (vx (bsize target)) (vy (bsize target)))
        on-hit))

(defmethod scan-collision (target (entity sized-entity))
  (let ((best-hit NIL) (best-dist NIL))
    (flet ((on-find (hit)
             (when (and (not (eql entity (hit-object hit)))
                        (collides-p entity (hit-object hit) hit))
               (let ((dist (vsqrdist2 (hit-location hit) (location entity))))
                 (when (or (null best-hit)
                           (< (hit-time hit) (hit-time best-hit))
                           (and (= (hit-time hit) (hit-time best-hit))
                                (< dist best-dist)))
                   (setf best-hit hit best-dist dist))))
             T))
      (scan target entity #'on-find)
      best-hit)))

(define-shader-entity sprite-entity (trial:sprite-entity sized-entity facing-entity)
  ((vertex-array :initform (asset 'leaf '1x))
   (frame :initform 0
          :type integer :documentation "The tile to display from the sprite sheet.")
   (texture :initform (asset 'leaf 'placeholder)
            :type resource :documentation "The tileset to display the sprite from.")
   (size :initform NIL
         :type vec2 :documentation "The size of the tile to display.")))

(defmethod initargs append ((_ sprite-entity))
  '(:tile :texture))

(defmethod initialize-instance :after ((sprite sprite-entity) &key)
  (unless (size sprite)
    (setf (size sprite) (v* (bsize sprite) 2))))

(defmethod (setf bsize) :after (value (sprite sprite-entity))
  (setf (size sprite) (v* value 2)))

(defmethod apply-transforms progn ((sprite sprite-entity))
  (let ((size (v* 2 (bsize sprite))))
    (translate-by (/ (vx size) -2) (/ (vy size) -2) 0)
    (scale (vxy_ size))))

(defmethod resize ((sprite sprite-entity) width height)
  (vsetf (size sprite) width height)
  (vsetf (bsize sprite) (/ width 2) (/ height 2)))

(defclass game-entity (sized-entity)
  ((velocity :initarg :velocity :initform (vec2 0 0) :accessor velocity
             :type vec2 :documentation "The velocity of the entity.")
   (state :initform :normal :accessor state
          :type symbol :documentation "The current state of the entity.")
   (frame-velocity :initform (vec2 0 0) :accessor frame-velocity)))

(defmethod layer-index ((_ game-entity)) +base-layer+)

(defmethod scan ((entity sized-entity) (target game-entity) on-hit)
  (let ((hit (aabb (location target) (frame-velocity target)
                   (location entity) (v+ (bsize entity) (bsize target)))))
    (when hit
      (setf (hit-object hit) entity)
      (unless (funcall on-hit hit) hit))))

(defmethod scan ((entity game-entity) (target game-entity) on-hit)
  (let ((hit (aabb (location target) (v- (frame-velocity target) (frame-velocity entity))
                   (location entity) (v+ (bsize entity) (bsize target)))))
    (when hit
      (setf (hit-object hit) entity)
      (unless (funcall on-hit hit) hit))))

(defmethod handle :after ((ev tick) (entity game-entity))
  (let ((vel (frame-velocity entity)))
    (nv+ (location entity) (v* vel (* 100 (dt ev))))
    (vsetf vel 0 0)))

(defclass trigger (sized-entity)
  ((event-type :initarg :event-type :initform () :accessor event-type
               :type class :documentation "The type of the event that should be triggered.")
   (event-initargs :initarg :event-initargs :initform () :accessor event-initargs
                   :type list :documentation "The list of initargs for the triggered event.")
   (active-p :initarg :active-p :initform T :accessor active-p)))

(defmethod initargs append ((_ trigger))
  `(:event-type :event-initargs))

(defmethod fire ((trigger trigger))
  (apply #'issue +world+ (event-type trigger) (event-initargs trigger))
  (setf (active-p trigger) NIL))
