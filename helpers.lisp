(in-package #:org.shirakumo.fraf.kandria)

(define-pool kandria)

(define-asset (kandria 1x) mesh
    (make-rectangle 1 1 :align :bottomleft))

(define-asset (kandria 16x) mesh
    (make-rectangle 16 16))

(define-asset (kandria placeholder) image
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

(defclass rotated-entity (base-entity transformed)
  ((angle :initarg :angle :initform 0 :accessor angle
          :type single-float :documentation "The angle the entity is pointing in.")))

(defmethod initargs append ((_ rotated-entity))
  '(:angle))

(defmethod apply-transforms progn ((obj rotated-entity))
  (rotate-by 0 0 1 (angle obj)))

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
  (scan entity (vec4 (vx2 (location target)) (vy2 (location target))
                     (vx2 (bsize target)) (vy2 (bsize target)))
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

(define-shader-entity sprite-entity (vertex-entity textured-entity sized-entity facing-entity)
  ((vertex-array :initform (// 'kandria '1x))
   (texture :initform (// 'kandria 'placeholder) :initarg :texture :accessor albedo
            :type resource :documentation "The tileset to display the sprite from.")
   (size :initform (vec 16 16) :initarg :size :accessor size
         :type vec2 :documentation "The size of the tile to display (in px).")
   (offset :initform (vec 0 0) :initarg :offset :accessor offset
           :type vec2 :documentation "The offset in the tile map (in px).")
   (layer-index :initform (1- +base-layer+) :initarg :layer :accessor layer-index
                :type integer :documentation "The layer the sprite should be on."))
  (:inhibit-shaders (textured-entity :fragment-shader)))

(defmethod initargs append ((_ sprite-entity))
  '(:texture :size :offset :layer))

(defmethod initialize-instance :after ((sprite sprite-entity) &key bsize)
  (unless (size sprite)
    (setf (size sprite) (v* (bsize sprite) 2)))
  (unless bsize
    (setf (bsize sprite) (v/ (size sprite) 2))))

(defmethod apply-transforms progn ((sprite sprite-entity))
  (let ((size (v* 2 (bsize sprite))))
    (translate-by (/ (vx size) -2) (/ (vy size) -2) 0)
    (scale (vxy_ size))))

(defmethod render :before ((entity sprite-entity) (program shader-program))
  (setf (uniform program "size") (size entity))
  (setf (uniform program "offset") (offset entity)))

(defmethod resize ((sprite sprite-entity) width height)
  (vsetf (size sprite) width height)
  (vsetf (bsize sprite) (/ width 2) (/ height 2)))

(define-class-shader (sprite-entity :fragment-shader)
  "in vec2 texcoord;
out vec4 color;
uniform sampler2D texture_image;
uniform vec2 size;
uniform vec2 offset;

void main(){
  color = texelFetch(texture_image, ivec2(offset+(texcoord*size)), 0);
}")

(defclass game-entity (sized-entity listener)
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

(defclass trigger (listener sized-entity)
  ((event-type :initarg :event-type :initform () :accessor event-type
               :type symbol :documentation "The type of the event that should be triggered.")
   (event-initargs :initarg :event-initargs :initform () :accessor event-initargs
                   :type list :documentation "The list of initargs for the triggered event.")
   (active-p :initarg :active-p :initform T :accessor active-p)))

(defmethod initargs append ((_ trigger))
  `(:event-type :event-initargs))

(defmethod handle ((ev tick) (trigger trigger))
  (when (contained-p (location (unit :player T)) trigger)
    (fire trigger)))

(defmethod fire ((trigger trigger))
  (v:info :kandria.trigger "Firing (~a~{ ~a~})" (event-type trigger) (event-initargs trigger))
  (apply #'issue +world+ (event-type trigger) (event-initargs trigger))
  (setf (active-p trigger) NIL))

(defclass transition-event (event)
  ((on-complete :initarg :on-complete :initform NIL :reader on-complete)))

(defmacro transition (&body on-blank)
  `(issue +world+ 'transition-event
          :on-complete (lambda () ,@on-blank)))

(define-shader-entity paletted-entity ()
  ((palette :initarg :palette :initform (// 'kandria 'placeholder) :accessor palette
            :type resource)
   (palette-index :initarg :palette-index :initform 0 :accessor palette-index
                  :type integer)))

(defmethod stage :after ((entity paletted-entity) (area staging-area))
  (stage (palette entity) area))

(defmethod render :before ((entity paletted-entity) (program shader-program))
  (gl:active-texture :texture4)
  (gl:bind-texture :texture-2D (gl-name (palette entity)))
  (setf (uniform program "palette") 4)
  (setf (uniform program "palette_index") (palette-index entity)))

(define-class-shader (paletted-entity :fragment-shader -1)
  "uniform sampler2D palette;
uniform int palette_index = 0;

void main(){
  if(color.r*color.b == 1 && color.g < 0.1){
    color = texelFetch(palette, ivec2(color.g*255, palette_index), 0);
  }
}")
