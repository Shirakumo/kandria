(in-package #:org.shirakumo.fraf.kandria)

(defgeneric item-order (item))
(defgeneric trade (source target item count)
  (:method-combination progn :most-specific-first))
(defgeneric price-for-buy (item inventory))
(defgeneric price-for-sell (item inventory))

(defclass inventory ()
  ((storage :initform (make-hash-table :test 'eq) :accessor storage)
   (unlock-table :initform (make-hash-table :test 'eq) :accessor unlock-table)))

(defmethod have ((item symbol) (inventory inventory))
  (< 0 (gethash item (storage inventory) 0)))

(defmethod item-count ((item symbol) (inventory inventory))
  (gethash item (storage inventory) 0))

(defmethod item-count ((item (eql T)) (inventory inventory))
  (hash-table-count (storage inventory)))

(defmethod price ((inventory inventory))
  (loop for item being the hash-keys of (storage inventory)
        for count being the hash-values of (storage inventory)
        sum (* count (price (type-prototype item)))))

(defmethod store ((item symbol) (inventory inventory) &optional (count 1))
  (when (subtypep item 'unlock-item)
    (setf (gethash item (unlock-table inventory)) T))
  (incf (gethash item (storage inventory) 0) count))

(defmethod item-unlocked-p ((item symbol) (inventory inventory))
  (or (< 0 (gethash item (storage inventory) 0))
      (gethash item (unlock-table inventory))))

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

(defmethod list-items ((inventory inventory) (type symbol))
  (sort (loop for item being the hash-keys of (storage inventory)
              for prototype = (make-instance item)
              when (typep prototype type)
              collect prototype)
        #'item<))

(define-shader-entity item (lit-sprite game-entity interactable)
  ((texture :initform (// 'kandria 'items))
   (size :initform (vec 8 8))
   (bsize :initform (vec 5 5))
   (layer-index :initform +base-layer+)
   (velocity :initform (vec 0 0))
   (light :initform NIL :accessor light)
   (medium :initform +default-medium+ :accessor medium)))

(defun item< (a b)
  (let ((a-order (item-order a))
        (b-order (item-order b)))
    (if (= a-order b-order)
        (string< (title a) (title b))
        (< a-order b-order))))

(defmethod trade progn (source target (item symbol) count)
  (trade source target (type-prototype item) count))

(defmethod trade progn ((source inventory) target (item item) count)
  (retrieve item source count))

(defmethod trade progn (source (target inventory) (item item) count)
  (store item target count))

(defmethod trade progn ((source inventory) (target player) (item item) count)
  (let ((price (* count (price-for-buy item source))))
    (retrieve 'item::parts target price)))

(defmethod trade progn ((source player) (target inventory) (item item) count)
  (let ((price (* count (price-for-sell item target))))
    (store 'item::parts source price)))

(defmethod trade progn (source (target player) (item item) count)
  (status (@formats 'new-item-in-inventory (language-string (type-of item)))))

(defmethod experience-reward ((item item))
  10)

(defmethod enter :after ((entity item) (magma magma))
  (kill entity))

(defmethod description ((item item))
  (language-string 'item))

(defmethod title ((item item))
  (language-string (type-of item)))

(defmethod price ((item item))
  0)

(defmethod price-for-buy ((item item) (inventory inventory))
  (price item))

(defmethod price-for-sell ((item item) (inventory inventory))
  (price item))

(defmethod item-description ((item item))
  (language-string (intern (format NIL "~a/DESCRIPTION" (string (type-of item)))
                           (symbol-package (class-name (class-of item))))))

(defmethod item-lore ((item item))
  (language-string (intern (format NIL "~a/LORE" (string (type-of item)))
                           (symbol-package (class-name (class-of item))))
                   NIL))

(defmethod item-unlocked-p ((item item) (inventory inventory))
  (item-unlocked-p (type-of item) inventory))

(defmethod kill ((item item))
  (leave* item T))

(defmethod spawn :before ((region region) (item item) &key)
  (vsetf (velocity item)
         (* (- (* 2 (random 2)) 1) (random* 2 1))
         (random* 4 2)))

(defmethod item-order ((_ item)) 1000)

(defmethod is-collider-for ((item item) thing) NIL)
(defmethod is-collider-for ((item item) (block block)) T)
(defmethod is-collider-for ((item item) (block stopper)) NIL)
(defmethod is-collider-for (thing (item item)) NIL)
(defmethod is-collider-for ((moving moving) (item item)) NIL)
(defmethod collide (thing (item item) hit) NIL)

(defmethod interactable-p ((item item))
  (let ((vel (velocity item)))
    (and (= 0 (vx vel)) (= 0 (vy vel)))))

(defmethod handle :before ((ev tick) (item item))
  (when (v/= 0 (velocity item))
    (nv+ (velocity item) (v* (gravity (medium item)) (dt ev)))
    (nv+ (frame-velocity item) (velocity item))
    (perform-collision-tick item (dt ev)))
  (when (light item)
    (vsetf (location (light item))
           (vx (location item))
           (+ 12 (vy (location item))))
    (when (= 0 (mod (fc ev) 10))
      (setf (multiplier (light item)) (random* 1.0 0.2)))))

(defmethod collide :after ((item item) (block block) hit)
  (let ((vel (frame-velocity item))
        (normal (hit-normal hit)))
    (when (= 1 (vy normal))
      (setf (vx (velocity item)) (* 0.95 (vx (velocity item)))))
    (when (<= (abs (vx (velocity item))) 0.1)
      (setf (vx (velocity item)) 0))
    (unless (light item)
      (let ((light (make-instance 'textured-light :location (nv+ (vec 0 16) (location item))
                                                  :multiplier 1.0
                                                  :bsize (vec 32 32)
                                                  :size (vec 64 64)
                                                  :offset (vec 0 144))))
        (setf (light item) light)
        (setf (container light) +world+)
        (compile-into-pass light NIL (unit 'lighting-pass +world+))))))

(defmethod interact ((item item) (inventory inventory))
  (trade NIL inventory item 1)
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
  (use (make-instance (find-class item)) on))

(defmethod use ((item item) on))

(defclass item-category ()
  ())

(defun list-item-categories ()
  (mapcar #'class-name (c2mop:class-direct-subclasses (find-class 'item-category))))

(defmethod list-items ((inventory inventory) (category item-category))
  (list-items inventory (item-category category)))

(defmethod list-items ((category item-category) type)
  (sort (loop for class in (c2mop:class-direct-subclasses (class-of category))
              for prototype = (make-instance (c2mop:ensure-finalized class))
              when (typep prototype type)
              collect prototype)
        #'item<))

(defmacro define-item-category (name &optional superclasses slots)
  `(progn
     (defclass ,name (,@superclasses item-category) ,slots)

     (defmethod item-category ((item ,name)) ',name)))

(define-item-category consumable-item)

(defmethod use :before ((item consumable-item) (inventory inventory))
  (retrieve item inventory))

(define-item-category quest-item)
(define-item-category value-item)
(define-item-category special-item)
(define-item-category unlock-item)
(define-item-category lore-item (unlock-item))

(defmacro define-item ((name &rest superclasses) x y w h &rest default-initargs &key price &allow-other-keys)
  (let ((name (intern (string name) '#:org.shirakumo.fraf.kandria.item)))
    (remf default-initargs :price)
    (export name (symbol-package name))
    `(progn
       (export ',name (symbol-package ',name))
       ,(emit-export '#:org.shirakumo.fraf.kandria.item name '/description)
       ,(emit-export '#:org.shirakumo.fraf.kandria.item name '/lore)
       (define-shader-entity ,name (,@superclasses item)
         ((size :initform ,(vec w h))
          (offset :initform ,(vec x y)))
         (:default-initargs
          ,@default-initargs))
       ,(when price
          `(defmethod price ((_ ,name)) ,price)))))

(define-shader-entity health-pack (item consumable-item value-item) ())
(define-shader-entity value-quest-item (item quest-item value-item) ())

(defmethod use ((item health-pack) (animatable animatable))
  (let ((buff (ceiling (* (health item) 0.01 (maximum-health animatable)))))
    (incf (health animatable) buff)
    (trigger (make-instance 'text-effect) animatable
             :text (format NIL "+~d" buff)
             :location (vec (+ (vx (location animatable)))
                            (+ (vy (location animatable)) 8 (vy (bsize animatable)))))))

(define-item (small-health-pack health-pack) 0 0 8 8
  :price 100)
(defmethod health ((_ item:small-health-pack)) 10)
(defmethod item-order ((_ item:small-health-pack)) 100)

(define-item (medium-health-pack health-pack) 0 0 8 8
  :price 250)
(defmethod health ((_ item:medium-health-pack)) 25)
(defmethod item-order ((_ item:medium-health-pack)) 101)

(define-item (large-health-pack health-pack) 0 0 8 8
  :price 500)
(defmethod health ((_ item:large-health-pack)) 50)
(defmethod item-order ((_ item:large-health-pack)) 102)

(define-item-category active-effect-item (consumable-item)
  ((clock :initform 30.0 :initarg :duration :accessor clock)))

(defmethod use ((item active-effect-item) (animatable animatable))
  (push item (active-effects animatable)))

(define-item (damage-shield active-effect-item value-item) 48 0 8 8
  :price 200)

(defmethod apply-effect ((effect item:damage-shield) (animatable animatable))
  (decf (damage-input-scale animatable) 0.2))

(define-item (combat-booster active-effect-item value-item) 40 0 8 8
  :price 200)

(defmethod apply-effect ((effect item:combat-booster) (animatable animatable))
  (incf (damage-output-scale animatable) 0.2))

(define-item (nanomachine-salve active-effect-item value-item) 32 0 8 8
  :price 200 :duration 10.0)

(defmethod apply-effect ((effect item:nanomachine-salve) (animatable animatable))
  ;; We want to buff 25% by the end of the 10s.
  (incf (health animatable) (* (maximum-health animatable) (/ 0.25 1000))))

;; VALUE ITEMS
(define-item (parts value-item) 8 16 8 8
  :price 1)

(defclass scrap () ())
(defmethod item-order ((_ scrap)) 200)
(define-item (heavy-spring scrap value-item) 8 16 8 8
  :price 20)
(define-item (satchel scrap value-item) 16 16 8 8
  :price 30)
(define-item (screw scrap value-item) 24 16 8 8
  :price 10)
(define-item (bolt scrap value-item) 32 16 8 8
  :price 10)
(define-item (nut scrap value-item) 40 16 8 8
  :price 10)
(define-item (gear scrap value-item) 48 16 8 8
  :price 20)
(define-item (bent-rod scrap value-item) 56 16 8 8
  :price 10)
(define-item (large-gear scrap value-item) 64 16 8 8
  :price 20)
(define-item (copper-ring scrap value-item) 72 16 8 8
  :price 20)
(define-item (metal-ring scrap value-item) 80 16 8 8
  :price 10)
(define-item (broken-ring scrap value-item) 88 16 8 8
  :price 10)
(define-item (heavy-rod scrap value-item) 96 16 8 8
  :price 20)
(define-item (light-rod scrap value-item) 104 16 8 8
  :price 20)
(define-item (simple-gadget scrap value-item) 112 16 8 8
  :price 10)
(define-item (dented-plate scrap value-item) 120 16 8 8
  :price 10)

(defclass electronics () ())
(defmethod item-order ((_ electronics)) 300)
(define-item (simple-circuit electronics value-item) 8 24 8 8
  :price 20)
(define-item (complex-circuit electronics value-item) 16 24 8 8
  :price 30)
(define-item (broken-circuit electronics value-item) 24 24 8 8
  :price 10)
(define-item (large-battery electronics value-item) 32 24 8 8
  :price 30)
(define-item (small-battery electronics value-item) 40 24 8 8
  :price 20)
(define-item (coin electronics value-item) 48 24 8 8
  :price 10)
(define-item (controller electronics value-item) 56 24 8 8
  :price 10)
(define-item (connector electronics value-item) 64 24 8 8
  :price 10)
(define-item (cable electronics value-item) 72 24 8 8
  :price 10)
(define-item (memory electronics value-item) 80 24 8 8
  :price 20)
(define-item (genera-core electronics value-item) 88 24 8 8
  :price 40)
(define-item (rusted-key electronics value-item) 96 24 8 8
  :price 10)

(defclass ores () ())
(defmethod item-order ((_ ores)) 400)
(define-item (clay-clump ores value-item) 0 32 8 8
  :price 20)
(define-item (gold-nugget ores value-item) 8 32 8 8
  :price 1000)
(define-item (silver-ore ores value-item) 16 32 8 8
  :price 600)
(define-item (bronze-clump ores value-item) 24 32 8 8
  :price 300)
(define-item (rich-soil ores value-item) 32 32 8 8
  :price 50)
(define-item (meteorite-fragment ores value-item) 40 32 8 8
  :price 40)
(define-item (hardened-alloy ores value-item) 48 32 8 8
  :price 60)
(define-item (quartz-crystal ores value-item) 56 32 8 8
  :price 50)
(define-item (rusted-clump ores value-item) 64 32 8 8
  :price 10)
(define-item (pearl ores value-item) 72 32 8 8
  :price 50)
(define-item (dirt-clump ores value-item) 80 32 8 8
  :price 10)

(defclass liquids () ())
(defmethod item-order ((_ liquids)) 500)
(define-item (coolant liquids value-item) 32 40 8 8
  :price 30)
(define-item (pure-water liquids value-item) 8 40 8 8
  :price 150)
(define-item (crude-oil liquids value-item) 16 40 8 8
  :price 100)
(define-item (refined-oil liquids value-item) 24 40 8 8
  :price 200)
(define-item (thermal-fluid liquids value-item) 0 40 8 8
  :price 30)
(define-item (mossy-water liquids value-item) 40 40 8 8
  :price 50)
(define-item (cloudy-water liquids value-item) 48 40 8 8
  :price 100)

(defclass skins () ())
(defmethod item-order ((_ skins)) 600)
(define-item (ruined-pelt skins value-item) 8 48 8 8
  :price 15)
(define-item (fine-pelt skins value-item) 0 48 8 8
  :price 100)
(define-item (pristine-pelt skins value-item) 16 48 8 8
  :price 200)

;; QUEST ITEMS
(define-item (seeds quest-item) 16 16 8 8)
(define-item (semi-factory-key quest-item) 8 0 8 8)
(define-item (can quest-item) 0 16 8 8)
(defmethod name ((can item:can)) 'item:can)
(define-item (wire quest-item) 8 0 8 8)
(define-item (blasting-cap quest-item) 8 0 8 8)
(define-item (charge-pack quest-item) 8 0 8 8)
(define-item (explosive quest-item) 8 0 8 8)
(define-item (receiver quest-item) 8 0 8 8)
(define-item (walkie-talkie-2 quest-item) 0 8 8 8)

;; VALUE-ITEMS (can be sold)
(define-item (mushroom-good-1 value-quest-item) 24 8 8 8
  :price 10)
(define-item (mushroom-good-2 value-quest-item) 32 8 8 8
  :price 10)
(define-item (mushroom-bad-1 value-quest-item) 16 8 8 8
  :price 20)
(define-item (walkie-talkie value-quest-item) 0 8 8 8
  :price 500)

;; SPECIAL ITEMS
(defclass palette-unlock (special-item)
  ())
(defmethod unlocked-palettes ((inventory inventory))
  (list-items inventory 'palette-unlock))
(macrolet ((define-palettes ()
             `(progn
                ,@(loop for palette in (getf (read-src (input* (asset 'kandria 'player))) :palettes)
                        for name = (intern (format NIL "~:@(PALETTE-~a~)" (substitute #\- #\Space palette)) '#:item)
                        for i from 0
                        append `((define-item (,name palette-unlock) 0 16 8 8)
                                 (defmethod palette-index ((,name ,name)) ,i))))))
  (define-palettes))

;;;; Used palettes marked with a x
;; x Model-1
;; x Model-2
;; x Model-3
;;   Model-4
;; x Model-5
;; x YoRHa
;;   Wayneright
;; x Mountain
;;   Vampire
;; x Trek
;;   Blingee
;; x Ninja
;;   Wahoo
;; x Shopping
;;   Invisible
;; x Camo
;;   Garlic
;; x Curly
;;   Quote
;; x Boy
;;   San-Diego
;;   Captain
;;   Ultimate-Lifeform
;;   Space
;;   Street
;;   K
;;   Planet
;;   Desu
;;   Dandy
;; x Ghost
;; x Bill
;;   The-Third
;;   ERROR

(define-item (manual lore-item) 56 0 8 8)

;; Draws
(define-random-draw mushrooms
  (item:mushroom-good-1 1)
  (item:mushroom-good-2 1)
  (item:mushroom-bad-1 1))
;; generally don't use this one, as it can be hard for the player to differentiate good from bad ones in the world, and they might not want to collect bad ones (for Catherine to burn, or Sahil to buy) - unless they can destroy them in their inventory (probably preferable to handling dropping in the world)

(define-random-draw mushrooms-good
  (item:mushroom-good-1 1)
  (item:mushroom-good-2 1))
;; placement: where background big mushrooms are
  
(define-random-draw mushrooms-good-1
  (item:mushroom-good-1 1)
  (item:mushroom-good-2 2))
;; placement: where background big mushrooms are
  
(define-random-draw mushrooms-good-2
  (item:mushroom-good-1 2)
  (item:mushroom-good-2 1))
;; placement: where background big mushrooms are
  
(define-random-draw mushrooms-bad-1
  (item:mushroom-bad-1 1))
;; placement: where mushrooms wouldn't be expected to grow i.e. in non-soil areas

;; REGION 1 UPPER + SURFACE
(define-random-draw region1-cave
  (item:cloudy-water 1)
  (item:mossy-water 2)
  (item:rich-soil 2)
  (item:quartz-crystal 2)
  (item:meteorite-fragment 3)
  (item:clay-clump 4)
  (item:rusted-clump 4)
  (item:dirt-clump 4)
  (item:ruined-pelt 4))
;; placement: region 1 soil areas

(define-random-draw region1-home
  (item:satchel 1)
  (item:small-battery 2)
  (item:cable 3)
  (item:controller 3)
  (item:broken-circuit 3)
  (item:simple-gadget 3))
;; placement: region 1 apartment areas

(define-random-draw region1-office
  (item:complex-circuit 1)
  (item:simple-circuit 2)
  (item:metal-ring 3)
  (item:broken-ring 3))
;; placement: region 1 office areas

(define-random-draw region1-factory
  (item:gear 1)
  (item:heavy-spring 1)
  (item:screw 2)
  (item:bolt 2)
  (item:nut 2)
  (item:bent-rod 2))
;; placement: region 1 factory areas

(define-random-draw region1-market
  (item:cloudy-water 1)
  (item:mossy-water 2)
  (item:rusted-key 3)
  (item:coin 3))
;; placement: region 1 market areas

;; REGION 1 LOWER - silver and bronze introduced here, but can also buy from Islay in this area, once unlocked
#| new items in this region:   
   silver-ore
   bronze-clump
   pure-water
   fine-pelt
   connector
   large-gear
   coolant
   large-battery
   copper ring
|#

(define-random-draw region1-lower-cave
  (item:silver-ore 1)
  (item:bronze-clump 2)
  (item:pure-water 3)
  (item:cloudy-water 4)
  (item:fine-pelt 4)
  (item:mossy-water 4)
  (item:rich-soil 4)
  (item:quartz-crystal 4)
  (item:clay-clump 6)
  (item:rusted-clump 6))
;; placement: region 1 lower soil areas

(define-random-draw region1-lower-home
  (item:pure-water 1)
  (item:fine-pelt 2)
  (item:satchel 3)
  (item:small-battery 4)
  (item:copper-ring 4)
  (item:controller 5)
  (item:cable 5))
;; placement: region 1 lower apartment areas

(define-random-draw region1-lower-office
  (item:complex-circuit 1)
  (item:large-battery 1)
  (item:metal-ring 3)
  (item:connector 3)
  (item:broken-ring 3))
;; placement: region 1 lower office areas

(define-random-draw region1-lower-factory
  (item:crude-oil 1)
  (item:coolant 3)
  (item:gear 4)
  (item:large-gear 4)
  (item:heavy-spring 4)
  (item:screw 5)
  (item:bolt 5)
  (item:nut 5))
;; placement: region 1 lower factory areas

(define-random-draw region1-lower-market
  (item:pure-water 1)
  (item:fine-pelt 2)
  (item:cloudy-water 2)
  (item:mossy-water 3)
  (item:rusted-key 4)
  (item:coin 4))
;; placement: region 1 lower market areas

;; REGION 2 - increase spawn frequency of bronze and silver (in caves by reducing number of other items; and in market areas too?)
;; - very different architecture and geology too, so whereas a lot of overlap between region 1 upper and lower, this will feel quite different

#| new items in this region:   
 thermal-fluid (also for trader quest)
 pearl (also for trader quest)
 pristine-pelt
 memory
 heavy-rod
 light-rod
 gold-nugget
 
 prev region items also required for trader quest nearby:
 pure-water
 coolant
 black-cap
|#

(define-random-draw region2-cave
  (item:gold-nugget 1)
  (item:silver-ore 2)
  (item:bronze-clump 3)
  (item:pure-water 4)
  (item:crude-oil 5)
  (item:cloudy-water 5)
  (item:fine-pelt 5)
  (item:rich-soil 5)
  (item:quartz-crystal 5)
  (item:pearl 5)
  (item:rusted-clump 7))
;; placement: region 2 empty cave areas (having more items here than otherwise would have due to most of the region being caves - using mushroom spawners too ofc)

(define-random-draw region2-market
 (item:pristine-pelt 1)
  (item:pure-water 2)
  (item:fine-pelt 3)
  (item:cloudy-water 3)
  (item:pearl 4)
  (item:rusted-key 5)
  (item:coin 5))
;; placement: market areas of region 2

(define-random-draw region2-home
  (item:pristine-pelt 1)
  (item:pure-water 2)
  (item:fine-pelt 3)
  (item:satchel 4)
  (item:small-battery 5)
  (item:copper-ring 5)
  (item:controller 6))
;; placement: region 2 housing areas

(define-random-draw region2-factory
  (item:crude-oil 1)
  (item:coolant 3)
  (item:thermal-fluid 3)
  (item:large-gear 4)
  (item:heavy-spring 4)
  (item:heavy-rod 4)
  (item:light-rod 4)
  (item:screw 5))
;; placement: region 2 lab/factory

(define-random-draw region2-office
  (item:complex-circuit 1)
  (item:large-battery 1)
  (item:memory 2)
  (item:metal-ring 3)
  (item:connector 3))
;; placement: region 2 office/council chambers


;; REGION 3
;; 


;; QUEST SPAWNERS
  
;; placement idea: 6 locations, some close to one another (2 per spawner)
(define-random-draw bomb-blasting-cap
  (item:blasting-cap 1))

;; placement idea: 5 locations, some close to one another - makes sense the explosives themselves would be stored in bulk and close together (5 per spawner)
(define-random-draw bomb-charge-pack
  (item:charge-pack 1))


#| ITEMS UNUSED IN SPAWNERS SO FAR
  
  Wraw region todo:
  
  (item:refined-oil 2) - Wraw region (needed for later sword upgrade) / Islay also sells
  (item:hardened-alloy 3) - Wraw region (needed for later sword upgrade) / Islay also sells
  (item:genera-core 1) - Wraw region only  
  (item:dented-plate 1)
  
|#
