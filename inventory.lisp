(in-package #:org.shirakumo.fraf.kandria)

(defgeneric item-order (item))

(defclass inventory ()
  ((storage :initform (make-hash-table :test 'eq) :accessor storage)))

(defmethod have ((item symbol) (inventory inventory))
  (< 0 (gethash item (storage inventory) 0)))

(defmethod item-count ((item symbol) (inventory inventory))
  (gethash item (storage inventory) 0))

(defmethod item-count ((item (eql T)) (inventory inventory))
  (hash-table-count (storage inventory)))

(defmethod store ((item symbol) (inventory inventory) &optional (count 1))
  (incf (gethash item (storage inventory) 0) count))

(defmethod retrieve ((item symbol) (inventory inventory) &optional (count 1))
  (let ((have (gethash item (storage inventory) 0)))
    (cond ((< count have)
           (setf (gethash item (storage inventory) 0) (- have count)))
          ((= count have)
           (remhash item (storage inventory)))
          (T
           (error "Can't remove ~s, don't have enough in inventory." item)))))

(defmethod clear ((inventory inventory))
  (clrhash (storage inventory)))

(defgeneric list-items (from kind))
(defmethod list-items ((inventory inventory) (type (eql T)))
  (alexandria:hash-table-keys (storage inventory)))

(defmethod list-items ((inventory inventory) (type symbol))
  (sort (loop for item being the hash-keys of (storage inventory)
              for prototype = (c2mop:class-prototype (find-class item))
              when (eql (item-category prototype) type)
              collect prototype)
        #'< :key #'item-order))

(define-shader-entity item (ephemeral lit-sprite moving interactable)
  ((texture :initform (// 'kandria 'items))
   (size :initform (vec 8 8))
   (layer-index :initform +base-layer+)
   (velocity :initform (vec (* (- (* 2 (random 2)) 1) (random* 2 1)) (random* 5 3)))))

(defmethod item-order ((_ item)) 0)

(defmethod interactable-p ((item item))
  (let ((vel (velocity item)))
    (and (= 0 (vx vel)) (= 0 (vy vel)))))

(defmethod handle :before ((ev tick) (item item))
  (nv+ (velocity item) (v* (gravity (medium item)) (* 100 (dt ev))))
  (nv+ (frame-velocity item) (velocity item)))

(defmethod collide :after ((item item) (block block) hit)
  (vsetf (velocity item) 0 0))

(defmethod interact ((item item) (inventory inventory))
  (store item inventory)
  (status "Received ~a" (language-string (type-of item)))
  (leave* item T))

(defmethod have ((item item) (inventory inventory))
  (have (type-of item) inventory))

(defmethod item-count ((item item) (inventory inventory))
  (item-count (type-of item) inventory))

(defmethod store ((item item) (inventory inventory) &optional (count 1))
  (store (type-of item) inventory count))

(defmethod retrieve ((item item) (inventory inventory) &optional (count 1))
  (retrieve (type-of item) inventory count)
  item)

(defmethod use ((item symbol) on)
  (use (c2mop:class-prototype (find-class item)) on))

(defclass item-category ()
  ())

(defun list-item-categories ()
  (mapcar #'class-name (c2mop:class-direct-subclasses (find-class 'item-category))))

(defmethod list-items ((inventory inventory) (category item-category))
  (list-items inventory (item-category category)))

(defmacro define-item-category (name)
  `(progn
     (defclass ,name (item-category) ())

     (defmethod item-category ((item ,name)) ',name)))

(define-item-category consumable-item)

(defmethod use :before ((item consumable-item) (inventory inventory))
  (retrieve item inventory))

(define-item-category quest-item)
(define-item-category value-item)
(define-item-category special-item)

(define-shader-entity health-pack (item consumable-item) ())

(defmethod use ((item health-pack) (animatable animatable))
  (incf (health animatable) (health item))
  (trigger (make-instance 'text-effect) animatable
           :text (format NIL "+~d" (health item))
           :location (vec (+ (vx (location animatable)))
                          (+ (vy (location animatable)) 8 (vy (bsize animatable))))))

(define-shader-entity small-health-pack (health-pack) ())
(defmethod health ((_ small-health-pack)) 10)
(defmethod item-order ((_ small-health-pack)) 0)

(define-shader-entity medium-health-pack (health-pack) ())
(defmethod health ((_ medium-health-pack)) 25)
(defmethod item-order ((_ medium-health-pack)) 1)

(define-shader-entity large-health-pack (health-pack) ())
(defmethod health ((_ large-health-pack)) 50)
(defmethod item-order ((_ large-health-pack)) 2)

(define-shader-entity can (item special-item) ())
