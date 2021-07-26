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
  (let* ((have (gethash item (storage inventory) 0))
         (count (etypecase count
                  ((eql T) (setf count have))
                  (integer count))))
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

(define-shader-entity item (lit-sprite moving interactable)
  ((texture :initform (// 'kandria 'items))
   (size :initform (vec 8 8))
   (layer-index :initform +base-layer+)
   (velocity :initform (vec 0 0))
   (light :initform NIL :accessor light)))

(defmethod description ((item item))
  (language-string 'item))

(defmethod kill ((item item))
  (leave* item T))

(defmethod spawn :before ((region region) (item item) &key)
  (vsetf (velocity item)
         (* (- (* 2 (random 2)) 1) (random* 2 1))
         (random* 4 2)))

(defmethod item-order ((_ item)) 0)

(defmethod interactable-p ((item item))
  (let ((vel (velocity item)))
    (and (= 0 (vx vel)) (= 0 (vy vel)))))

(defmethod handle :before ((ev tick) (item item))
  (nv+ (velocity item) (v* (gravity (medium item)) (dt ev)))
  (nv+ (frame-velocity item) (velocity item))
  (when (light item)
    (vsetf (location (light item))
           (vx (location item))
           (+ 12 (vy (location item))))
    (when (= 0 (mod (fc ev) 5))
      (setf (multiplier (light item)) (random* 1.0 0.2)))))

(defmethod collide :after ((item item) (block block) hit)
  (vsetf (velocity item) 0 0)
  (unless (light item)
    (let ((light (make-instance 'textured-light :location (nv+ (vec 0 16) (location item))
                                                :multiplier 1.0
                                                :bsize (vec 32 32)
                                                :size (vec 64 64)
                                                :offset (vec 0 144))))
      (setf (light item) light)
      (setf (container light) +world+)
      (compile-into-pass light NIL (unit 'lighting-pass +world+)))))

(defmethod interact ((item item) (inventory inventory))
  (store item inventory)
  (status "Received ~a" (language-string (type-of item)))
  (leave* item T))

(defmethod leave* :after ((item item) thing)
  (when (light item)
    (remove-from-pass (light item) (unit 'lighting-pass +world+))
    (setf (light item) NIL)))

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

(defmethod use ((item item) on))

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

(defmacro define-item ((name &rest superclasses) x y w h &body body)
  (let ((name (intern (string name) '#:org.shirakumo.fraf.kandria.item)))
    (export name (symbol-package name))
    `(progn
       (export ',name (symbol-package ',name))
       (define-shader-entity ,name (,@superclasses item)
         ((size :initform ,(vec w h))
          (offset :initform ,(vec x y)))
         ,@body))))

(define-shader-entity health-pack (item consumable-item) ())

(defmethod use ((item health-pack) (animatable animatable))
  (incf (health animatable) (health item))
  (trigger (make-instance 'text-effect) animatable
           :text (format NIL "+~d" (health item))
           :location (vec (+ (vx (location animatable)))
                          (+ (vy (location animatable)) 8 (vy (bsize animatable))))))

(define-item (small-health-pack health-pack) 0 0 8 8)
(defmethod health ((_ item:small-health-pack)) 10)
(defmethod item-order ((_ item:small-health-pack)) 0)

(define-item (medium-health-pack health-pack) 0 0 8 8)
(defmethod health ((_ item:medium-health-pack)) 25)
(defmethod item-order ((_ item:medium-health-pack)) 1)

(define-item (large-health-pack health-pack) 0 0 8 8)
(defmethod health ((_ item:large-health-pack)) 50)
(defmethod item-order ((_ item:large-health-pack)) 2)

;; VALUE ITEMS
(define-item (parts value-item) 8 16 8 8)
(define-item (heavy-spring value-item) 8 16 8 8)
(define-item (satchel value-item) 16 16 8 8)
(define-item (screw value-item) 24 16 8 8)
(define-item (bolt value-item) 32 16 8 8)
(define-item (nut value-item) 40 16 8 8)
(define-item (gear value-item) 48 16 8 8)
(define-item (bent-rod value-item) 56 16 8 8)
(define-item (large-gear value-item) 64 16 8 8)
(define-item (copper-ring value-item) 72 16 8 8)
(define-item (metal-ring value-item) 80 16 8 8)
(define-item (broken-ring value-item) 88 16 8 8)
(define-item (heavy-rod value-item) 96 16 8 8)
(define-item (light-rod value-item) 104 16 8 8)
(define-item (simple-gadget value-item) 112 16 8 8)
(define-item (dented-plate value-item) 120 16 8 8)

(define-item (simple-circuit value-item) 8 24 8 8)
(define-item (complex-circuit value-item) 16 24 8 8)
(define-item (broken-circuit value-item) 24 24 8 8)
(define-item (large-battery value-item) 32 24 8 8)
(define-item (small-battery value-item) 40 24 8 8)
(define-item (coin value-item) 48 24 8 8)
(define-item (controller value-item) 56 24 8 8)
(define-item (connector value-item) 64 24 8 8)
(define-item (cable value-item) 72 24 8 8)
(define-item (memory value-item) 80 24 8 8)
(define-item (genera-core value-item) 88 24 8 8)
(define-item (rusted-key value-item) 96 24 8 8)

(define-item (clay-clump value-item) 0 32 8 8)
(define-item (gold-nugget value-item) 8 32 8 8)
(define-item (silver-ore value-item) 16 32 8 8)
(define-item (bronze-clump value-item) 24 32 8 8)
(define-item (rich-soil value-item) 32 32 8 8)
(define-item (meteorite-fragment value-item) 40 32 8 8)
(define-item (hardened-alloy value-item) 48 32 8 8)
(define-item (quartz-crystal value-item) 56 32 8 8)
(define-item (rusted-clump value-item) 64 32 8 8)
(define-item (pearl value-item) 72 32 8 8)
(define-item (dirt-clump value-item) 80 32 8 8)

(define-item (coolant value-item) 0 40 8 8)
(define-item (pure-water value-item) 8 40 8 8)
(define-item (crude-oil value-item) 16 40 8 8)
(define-item (refined-oil value-item) 24 40 8 8)
(define-item (thermal-fluid value-item) 32 40 8 8)
(define-item (mossy-water value-item) 40 40 8 8)
(define-item (cloudy-water value-item) 48 40 8 8)

(define-item (fine-pelt value-item) 0 48 8 8)
(define-item (ruined-pelt value-item) 8 48 8 8)
(define-item (pristine-pelt value-item) 16 48 8 8)

;; QUEST ITEMS
(define-item (seeds quest-item) 16 16 8 8)
(define-item (mushroom-good-1 quest-item) 24 8 8 8)
(define-item (mushroom-good-2 quest-item) 32 8 8 8)
(define-item (mushroom-bad-1 quest-item) 16 8 8 8)
(define-item (walkie-talkie quest-item) 0 0 8 8)
(define-item (semi-factory-key quest-item) 8 0 8 8)
(define-item (can quest-item) 0 16 8 8)

;; SPECIAL ITEMS

;; Draws
(define-random-draw mushrooms
  (item:mushroom-good-1 1)
  (item:mushroom-good-2 1)
  (item:mushroom-bad-1 1))
;; generally don't use this one, as it can be hard for the player to differentiate good from bad ones in the world, and they might not want to collect bad ones (for Catherine to burn, or Sahil to buy) - unless they can destroy them in their inventory (probably preferable to handling dropping in the world)

(define-random-draw mushrooms-good
  (item:mushroom-good-1 1)
  (item:mushroom-good-2 1))
  
(define-random-draw mushrooms-good-1
  (item:mushroom-good-1 2)
  (item:mushroom-good-2 1))
  
(define-random-draw mushrooms-good-2
  (item:mushroom-good-1 1)
  (item:mushroom-good-2 2))
  
(define-random-draw mushrooms-bad-1
  (item:mushroom-bad-1 1))
  
(define-random-draw region1-cave
  (item:clay-clump 3)
  (item:rich-soil 1)
  (item:meteorite-fragment 2)
  (item:quartz-crystal 1)
  (item:rusted-clump 3)
  (item:dirt-clump 3)
  (item:ruined-pelt 3))

(define-random-draw region1-home
  (item:satchel 2)
  (item:small-battery 2)
  (item:controller 1)
  (item:cable 3)
  (item:broken-circuit 3)
  (item:simple-gadget 3))

(define-random-draw region1-office
  (item:simple-circuit 2)
  (item:complex-circuit 1)
  (item:broken-ring 4)
  (item:metal-ring 3))

(define-random-draw region1-industrial
  (item:heavy-spring 3)
  (item:screw 3)
  (item:bolt 3)
  (item:nut 3)
  (item:gear 3)
  (item:bent-rod 3)
  (item:crude-oil 1))

(define-random-draw region1-market
  (item:mossy-water 1)
  (item:cloudy-water 1)
  (item:bronze-clump 1)
  (item:rusted-key 2)
  (item:coin 3))

#| ITEMS UNUSED IN SPAWNERS SO FAR
  
  (item:large-gear 1)
  (item:copper-ring 1)  
  (item:genera-core 1)
  (item:heavy-rod 1)
  (item:light-rod 1)  
  (item:dented-plate 1)    
  (item:large-battery 1)
  (item:connector 1)  
  (item:memory 1)  
  (item:hardened-alloy 3)
  (item:pearl 1)
  (item:gold-nugget 1)
  (item:silver-ore 2)  
  (item:coolant 3)
  (item:pure-water 1)  
  (item:refined-oil 2)
  (item:thermal-fluid 3)
  (item:fine-pelt 2)
  (item:pristine-pelt 1)
  
|#
