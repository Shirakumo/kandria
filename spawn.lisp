(in-package #:kandria)

(define-global +random-draw+ (make-hash-table :test 'eq))
(define-global +spawn-cache+ (make-hash-table :test 'eq))
(define-global +spawn-tracker+ (make-hash-table :test 'eq))

(defun weighted-random-elt (segments &optional (random-fun #'random))
  (let* ((total (loop for segment in segments
                      sum (second segment)))
         (index (funcall random-fun total)))
    ;; Could try to binsearch, but eh. Probably fine.
    (loop for prev = 0.0 then (+ prev weight)
          for (part weight) in segments
          do (when (< index (+ prev weight))
               (return part)))))

(defun random-drawer (name)
  (gethash name +random-draw+))

(defun (setf random-drawer) (value name)
  (setf (gethash name +random-draw+) value))

(defmethod draw-item ((item symbol))
  (funcall (gethash item +random-draw+)))

(defmacro define-random-draw (&environment env name &body items)
  (let ((total (float (loop for (item weight) in items
                            do (unless (find-class item NIL env)
                                 (alexandria:simple-style-warning "Unknown item type: ~s"  item))
                            sum weight))))
    `(setf (random-drawer ',name)
           (lambda (&optional (f #'random))
             (let ((r (funcall f ,total)))
               (cond ,@(nreverse (loop for prev = 0.0 then (+ prev weight)
                                       for (item weight) in items
                                       collect `((< ,prev r) ',item)))))))))

(defmethod spawned-p (entity)
  (gethash entity +spawn-tracker+))

(defun mark-as-spawned (entity)
  (setf (gethash entity +spawn-tracker+) T))

(defclass spawner (listener sized-entity ephemeral resizable creatable)
  ((flare:name :initform (generate-name 'spawner))
   (spawn-type :initarg :spawn-type :initform NIL :accessor spawn-type :type alloy::any)
   (spawn-count :initarg :spawn-count :initform 2 :accessor spawn-count :type integer)
   (spawn-args :initarg :spawn-args :initform NIL :accessor spawn-args :type alloy::any)
   (reflist :initform () :accessor reflist)
   (adjacent :initform () :accessor adjacent)
   (auto-deactivate :initarg :auto-deactivate :initform NIL :accessor auto-deactivate :type boolean)
   (active-p :initarg :active-p :initform T :accessor active-p :type boolean)
   (jitter-y-p :initarg :jitter-y-p :initform T :accessor jitter-y-p :type boolean)
   (rng :initarg :rng :initform (random-state:make-generator :squirrel T) :accessor rng)))

(defmethod initargs append ((spawner spawner))
  '(:spawn-type :spawn-count :spawn-args :auto-deactivate :active-p :jitter-y-p))

(defmethod (setf location) :after (location (spawner spawner))
  (let ((chunk (find-chunk spawner))
        (adjacent ()))
    (when chunk
      (bvh:do-fitting (entity (bvh (region +world+))
                              (vec (- (vx (location chunk)) (vx (bsize chunk)) 8)
                                   (- (vy (location chunk)) (vy (bsize chunk)) 8)
                                   (+ (vx (location chunk)) (vx (bsize chunk)) 8)
                                   (+ (vy (location chunk)) (vy (bsize chunk)) 8)))
        (when (typep entity 'chunk)
          (push entity adjacent))))
    (setf (adjacent spawner) adjacent)))

(defun handle-spawn (spawner chunk)
  (when (null (adjacent spawner))
    (setf (location spawner) (location spawner)))
  (cond ((null (reflist spawner))
         (when (find chunk (adjacent spawner))
           (setf (reflist spawner)
                 (apply #'spawn (location spawner) (spawn-type spawner)
                        :count (spawn-count spawner)
                        :collect T
                        :jitter (vec (* 2.0 (vx (bsize spawner)))
                                     (if (jitter-y-p spawner)
                                         (* 2.0 (vy (bsize spawner)))
                                         0))
                        :rng (rng spawner)
                        (spawn-args spawner)))
           (dolist (entity (reflist spawner))
             (mark-as-spawned entity))))
        ((not (find chunk (adjacent spawner)))
         (when (and (done-p spawner) (auto-deactivate spawner))
           (v:info :kandria.spawn "Deactivating ~a" spawner)
           (setf (active-p spawner) NIL))
         (dolist (entity (reflist spawner))
           (remhash entity +spawn-tracker+)
           (when (slot-boundp entity 'container)
             (leave* entity T)))
         (setf (reflist spawner) ()))))

(defmethod done-p ((spawner spawner))
  (loop for entity in (reflist spawner)
        never (slot-boundp entity 'container)))

(defmethod quest:status ((spawner spawner))
  (if (done-p spawner) :complete :unresolved))

(define-unit-resolver-methods done-p (unit))

(defmethod (setf active-p) :after (state (spawner spawner))
  (when (and state (unit 'player +world+))
    (handle-spawn spawner (chunk (unit 'player +world+)))))

(defmethod quest:activate ((spawner spawner))
  (setf (active-p spawner) T))

(defmethod quest:deactivate ((spawner spawner))
  (setf (active-p spawner) NIL)
  (dolist (entity (reflist spawner))
    (remhash entity +spawn-tracker+)
    (when (slot-boundp entity 'container)
      (leave* entity T))))

(defmethod handle ((ev switch-chunk) (spawner spawner))
  (when (active-p spawner)
    (handle-spawn spawner (chunk ev))))

(defmethod spawn ((location vec2) (types cons) &rest initargs)
  (loop for type in types
        nconc (apply #'spawn location type initargs)))

(defmethod spawn ((location vec2) type &rest initargs &key (count 1) (jitter +tile-size+) collect (rng *random-state*) &allow-other-keys)
  (let ((initargs (remf* initargs :count :collect :jitter :rng))
        (region (region +world+))
        (spawner (random-drawer type))
        (rng (lambda (max) (random-state:random max rng))))
    (labels ((draw ()
               (if spawner
                   (funcall spawner rng)
                   type))
             (create ()
               (apply #'make-instance (draw)
                      :location (v+ location
                                    (etypecase jitter
                                      (real (vrandr 0 jitter PI rng))
                                      (vec2 (vec (- (funcall rng (vx jitter)) (* 0.5 (vx jitter)))
                                                 (- (funcall rng (vy jitter)) (* 0.5 (vy jitter)))))))
                      initargs)))
      (if collect
          (loop repeat count
                collect (spawn region (create)))
          (loop repeat count
                do (spawn region (create)))))))

(defmethod spawn ((container container) (entity entity) &key)
  (unless (gethash (class-of entity) +spawn-cache+)
    (setf (gethash (class-of entity) +spawn-cache+) T)
    (trial:commit entity (loader +main+) :unload NIL))
  (enter* entity container)
  entity)

(defmethod spawn ((marker located-entity) type &rest initargs)
  (apply #'spawn (location marker) type initargs))

(defmethod spawn ((name symbol) type &rest initargs &key &allow-other-keys)
  (apply #'spawn (location (unit name +world+)) type initargs))

(defun clear-spawns ()
  (clrhash +spawn-cache+)
  (clrhash +spawn-tracker+))
