(in-package #:org.shirakumo.fraf.kandria)

(defclass inventory ()
  ((storage :initform (make-hash-table :test 'eq) :accessor storage)))

(defmethod have ((item symbol) (inventory inventory))
  (< 0 (gethash item (storage inventory) 0)))

(defmethod item-count ((item symbol) (inventory inventory))
  (gethash item (storage inventory) 0))

(defmethod item-count ((item (eql T)) (inventory inventory))
  (hash-table-count (storage inventory)))

(defmethod store ((item symbol) (inventory inventory))
  (incf (gethash item (storage inventory) 0)))

(defmethod retrieve ((item symbol) (inventory inventory))
  (let ((count (gethash item (storage inventory) 0)))
    (cond ((< 1 count)
           (setf (gethash item (storage inventory) 0) (1- count)))
          ((< 0 count)
           (remhash item (storage inventory)))
          (T
           (error "Can't remove ~s, don't have any in inventory." item)))))

(defmethod clear ((inventory inventory))
  (clrhash (storage inventory)))

(defgeneric list-items (from kind))
(defmethod list-items ((inventory inventory) (type (eql T)))
  (alexandria:hash-table-keys (storage inventory)))

(defmethod list-items ((inventory inventory) (type symbol))
  (loop for item being the hash-keys of (storage inventory)
        when (eql (item-category (c2mop:class-prototype item)) type)
        collect item))

(define-shader-entity item (ephemeral lit-sprite moving interactable)
  ((texture :initform (// 'kandria 'items))
   (size :initform (vec 8 8))
   (layer-index :initform +base-layer+)
   (velocity :initform (vec (* (- (* 2 (random 2)) 1) (random* 2 1)) (random* 5 3)))))

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
  (leave item T)
  (status "Received ~a" (language-string (type-of item)))
  (remove-from-pass item +world+))

(defmethod have ((item item) (inventory inventory))
  (have (type-of item) inventory))

(defmethod item-count ((item item) (inventory inventory))
  (item-count (type-of item) inventory))

(defmethod store ((item item) (inventory inventory))
  (store (type-of item) inventory))

(defmethod retrieve ((item item) (inventory inventory))
  (retrieve (type-of item) inventory)
  item)

(defmethod use ((item symbol) on)
  (use (c2mop:class-prototype (find-class item)) on))

(defclass item-category ()
  ())

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

(define-shader-entity health-pack (item consumable-item)
  ((health :initform (error "HEALTH required") :reader health)))

(defmethod use ((item health-pack) (animatable animatable))
  (incf (health animatable) (health item))
  (trigger (make-instance 'text-effect) animatable
           :text (format NIL "+~d" (health item))
           :location (vec (+ (vx (location animatable)))
                          (+ (vy (location animatable)) 8 (vy (bsize animatable))))))

(define-shader-entity small-health-pack (health-pack)
  ((health :initform 10)))
