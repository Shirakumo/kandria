(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity fishing-buoy (lit-sprite moving)
  ((texture :initform (// 'kandria 'items))
   (fishing-line :accessor fishing-line)
   (size :initform (vec 8 8))
   (layer-index :initform +base-layer+)
   (offset :initform (vec 0 24))
   (tries :initform 0 :accessor tries)
   (catch-timer :initform 0.0 :accessor catch-timer)
   (item :initform NIL :accessor item)))

(defmethod is-collider-for ((buoy fishing-buoy) (moving moving)) NIL)
(defmethod is-collider-for ((buoy fishing-buoy) (platform platform)) NIL)

(defmethod catch-timer ((item item)) 1.0)

(defmethod (setf medium) :before ((water water) (buoy fishing-buoy))
  (unless (eq water (medium buoy))
    (harmony:play (// 'sound 'fishing-bob-lands-in-water))))

(defmethod handle :before ((ev tick) (buoy fishing-buoy))
  (let ((vel (velocity buoy))
        (dt (dt ev)))
    (case (state buoy)
      (:normal
       (cond ((< 0.0 (decf (catch-timer buoy) dt)))
             ((< (random 6.0) (tries buoy))
              (when (setf (item buoy) (draw-item (fishing-spot (fishing-line buoy))))
                (harmony:play (// 'sound 'fishing-fish-bite))
                (setf (catch-timer buoy) 0.0)
                (setf (tries buoy) 0)
                (setf (state buoy) :caught)
                (trigger 'splash buoy)
                (rumble :intensity 1.0)
                (incf (vy vel) -3)))
             (T
              (harmony:play (// 'sound 'fishing-fish-nibble))
              (rumble :intensity 0.2)
              (incf (vy vel) -0.5)
              (incf (tries buoy))
              (setf (catch-timer buoy) (random* 3.0 1.0)))))
      (:caught
       (cond ((null (item buoy))
              (setf (state buoy) :normal))
             ((< (catch-timer (item buoy)) (incf (catch-timer buoy) dt))
              (setf (catch-timer buoy) 5.0)
              (setf (item buoy) NIL)
              (harmony:play (// 'sound 'fishing-fish-escaped))
              (setf (state buoy) :escaped))))
      (:escaped
       (when (<= (decf (catch-timer buoy) dt) 0.0)
         (setf (state buoy) :normal)))
      (:reeling
       (let ((line (location (fishing-line buoy)))
             (item (item buoy)))
         (incf (vy vel) (* 0.1 (signum (- (vy line) (vy (location buoy))))))
         (incf (vx vel) (* 0.01 (signum (- (vx line) (vx (location buoy))))))
         (cond ((< (abs (- (vx (location (unit 'player +world+))) (vx (location buoy)))) 8)
                (cond (item
                       (harmony:play (// 'sound 'fishing-fish-caught))
                       (cond ((< (price item) 100)
                              (harmony:play (// 'sound 'fishing-bad-catch)))
                             ((< (price item) 500)
                              (harmony:play (// 'sound 'fishing-good-catch)))
                             (T
                              (harmony:play (// 'sound 'fishing-rare-catch))))
                       (setf (state buoy) :show)
                       (award-experience (unit 'player +world+) (experience-reward item))
                       (store item (unit 'player +world+))
                       (status (@formats 'fish-caught-successfully (language-string (type-of item)))))
                      (T
                       (setf (animation (unit 'player +world+)) 'stand)
                       (leave (fishing-line buoy) T))))
               (item
                (v<- (location item) (location buoy))
                (if (v= 0 vel)
                    (incf (angle item) (* (- (float (* 1.5 PI) 0f0) (angle item)) (* 10 dt)))
                    (setf (angle item) (float (mod (- (point-angle vel) PI) (* 2 PI)) 0f0)))))))
      (:show
       (let* ((player (unit 'player +world+))
              (hurtbox (hurtbox player))
              (item (item buoy)))
         (setf (animation player) 'show)
         (setf (intended-zoom (camera +world+)) 2.0)
         (vsetf vel 0 0)
         (v<- (location buoy) (vxy hurtbox))
         (when item
           (v<- (location item) (location buoy))
           (incf (angle item) (* (- (float (* 1.5 PI) 0f0) (angle item)) (* 10 dt)))))))
    (typecase (medium buoy)
      (water
       (let ((dist (- (+ (vy (location (medium buoy))) (vy (bsize (medium buoy))))
                      (vy (location buoy)))))
         (nv+ vel (v* (vec 0 (clamp 0.3 dist 4)) dt))))
      (T
       (nv+ vel (v* (gravity (medium buoy)) dt))))
    (setf (vx vel) (deadzone 0.001 (vx vel)))
    (setf (vy vel) (deadzone 0.001 (vy vel)))
    (nv+ (frame-velocity buoy) vel)))

(define-asset (kandria line-part) mesh
    (make-rectangle 0.5 4 :align :topcenter))

(define-shader-entity fishing-line (lit-vertex-entity listener)
  ((name :initform 'fishing-line)
   (vertex-array :initform (// 'kandria 'line-part))
   (chain :initform #() :accessor chain)
   (location :initform (vec 0 0) :initarg :location :accessor location)
   (fishing-spot :initform NIL :accessor fishing-spot)
   (buoy :initform (make-instance 'fishing-buoy) :accessor buoy))
  (:inhibit-shaders (shader-entity :fragment-shader)))

(defmethod initialize-instance :after ((fishing-line fishing-line) &key)
  (setf (chain fishing-line) (make-array 64))
  (setf (fishing-line (buoy fishing-line)) fishing-line))

(defmethod layer-index ((fishing-line fishing-line)) +base-layer+)

(defmethod stage ((line fishing-line) (area staging-area))
  (dolist (sound '(fishing-bob-lands-in-water fishing-fish-bite fishing-fish-nibble
                   fishing-fish-bite fishing-fish-caught fishing-fish-escaped
                   fishing-good-catch fishing-bad-catch fishing-rare-catch
                   fishing-big-splash fishing-begin-jingle))
    (stage (// 'sound sound) area))
  (stage (buoy line) area)
  (stage (// 'kandria 'fish) area))

(defmethod enter :after ((line fishing-line) target)
  (let ((chain (chain line))
        (buoy (buoy line)))
    (loop for i from 0 below (length chain)
          do (setf (aref chain i) (list (vcopy (location line)) (vcopy (location line)))))
    (v<- (location buoy) (location line))
    (setf (catch-timer buoy) 2.0)
    (setf (state buoy) :escaped)
    (setf (tries buoy) 0)
    (setf (item buoy) NIL)
    (setf (intended-zoom (camera +world+)) 1.0)
    (vsetf (velocity buoy) (* (- (vx (location (fishing-spot line))) (vx (location line))) 0.03) 4)
    (enter (buoy line) target)))

(defmethod leave :after ((line fishing-line) from)
  (when (container (buoy line))
    (leave (buoy line) from)))

(defmethod handle ((ev tick) (fishing-line fishing-line))
  (declare (optimize speed))
  (let ((chain (chain fishing-line))
        (buoy (buoy fishing-line))
        (g #.(vec 0 -80))
        (dt2 (expt (the single-float (dt ev)) 2)))
    (declare (type (simple-array T (*)) chain))
    (flet ((verlet (a b)
             (let ((x (vx a)) (y (vy a)))
               (vsetf a
                      (+ x (* 0.92 (- x (vx b))) (* dt2 (vx g)))
                      (+ y (* 0.92 (- y (vy b))) (* dt2 (vy g))))
               (vsetf b x y)))
           (relax (a b i)
             (let* ((dist (v- b a))
                    (dir (if (v/= 0 dist) (nvunit dist) (vec 0 0)))
                    (delta (- (vdistance a b) i))
                    (off (v* delta dir 0.5)))
               (nv+ a off)
               (nv- b off))))
      (loop for (a b) across chain
            do (verlet a b))
      (v<- (first (aref chain 0)) (location fishing-line))
      (v<- (first (aref chain (1- (length chain)))) (location buoy))
      (dotimes (i 50)
        (loop for i from 1 below (length chain)
              do (relax (first (aref chain (+ -1 i)))
                        (first (aref chain (+  0 i)))
                        4)))
      (let ((last (first (aref chain (1- (length chain)))))
            (loc (location buoy)))
        (incf (vx (velocity buoy)) (* 0.01 (deadzone 0.75 (- (vx last) (vx loc)))))
        (incf (vy (velocity buoy)) (* 0.01 (deadzone 0.75 (- (vy last) (vy loc)))))))))

(defmethod handle ((ev cast-line) (player player))
  (let* ((line (fishing-line player))
         (item (item (buoy line))))
    (when (and (not item)
               (not (container line)))
      (setf (animation player) 'fishing-start))))

(defmethod handle ((ev reel-in) (player player))
  (let* ((line (fishing-line player))
         (buoy (buoy line)))
    (when (container line)
      (case (state buoy)
        (:show
         (let ((item (item (buoy line))))
           (when (and item (container item))
             (leave item T)))
         (when (container line)
           (leave line T))
         (setf (item (buoy line)) NIL)
         (setf (animation player) 'stand))
        (T
         (harmony:play (// 'sound 'fishing-big-splash))
         (setf (animation player) 'fishing-reel)
         (when (and (item buoy) (not (container (item buoy))))
           (enter (item buoy) (region +world+)))
         (vsetf (velocity buoy)
                (* (- (vx (location line)) (vx (location buoy))) 0.05)
                (* (- (vy (location line)) (vy (location buoy))) 0.05))
         (setf (state buoy) :reeling))))))

(defmethod handle ((ev stop-fishing) (player player))
  (let ((line (fishing-line player)))
    (let ((item (item (buoy line))))
      (when item
        (when (container item)
          (leave item T))
        (setf (item (buoy line)) NIL)))
    (leave line T)
    (hide (prompt player))
    (hide (prompt-b player))
    (setf (intended-zoom (camera +world+)) 1.0)
    (setf (active-p (action-set 'in-game)) T)
    (setf (state player) :normal)))

(defmethod render ((fishing-line fishing-line) (program shader-program))
  (let ((chain (chain fishing-line)))
    (loop for i from 0 below (1- (length chain))
          for (p1) = (aref chain i)
          for (p2) = (aref chain (1+ i))
          for d = (tv- p2 p1)
          for angle = (atan (vy d) (vx d))
          do (with-pushed-matrix ()
               (translate-by (vx p1) (vy p1) 0)
               (rotate-by 0 0 1 (+ angle (/ PI 2)))
               (call-next-method)))))

(define-class-shader (fishing-line :fragment-shader 1)
  "out vec4 color;

void main(){
  color = vec4(0,0,0,1);
}")


(define-shader-entity fish (item unlock-item value-item item-category)
  ((texture :initform (// 'kandria 'fish))
   (size :initform (vec 8 8))
   (layer-index :initform +base-layer+)
   (catch-timer :initarg :catch-timer :initform 1.0 :accessor catch-timer)))

(defmethod item-category ((fish fish)) 'fish)

(defmethod item-order ((fish fish)) 1000)

(defmethod apply-transforms progn ((fish fish))
  (translate #.(vec 0.5 0 0)))

(defmethod experience-reward ((fish fish))
  (cond ((< (price fish) 100)
         50)
        ((< (price fish) 500)
         150)
        (T
         300)))

(defmacro define-fish (name x y w h &key price)
  (let ((name (intern (string name) '#:org.shirakumo.fraf.kandria.fish)))
    (export name (symbol-package name))
    `(progn
       (export ',name (symbol-package ',name))
       ,(emit-export '#:org.shirakumo.fraf.kandria.fish name '/description)
       ,(emit-export '#:org.shirakumo.fraf.kandria.fish name '/lore)
       (define-shader-entity ,name (fish)
         ((size :initform ,(vec w h))
          (offset :initform ,(vec x y))))
       ,(when price
          `(defmethod price ((_ ,name)) ,price)))))

(define-fish crab 0 0 16 16
  :price 150)
(define-fish machine-fish 0 16 16 8
  :price 125)
(define-fish salmon 0 24 16 8
  :price 150)
(define-fish shark 0 32 64 24
  :price 500)
(define-fish seabass 0 56 24 8
  :price 150)
(define-fish sneaky-seabass 0 64 24 8
  :price 200)
(define-fish can 16 0 8 8
  :price 50)
(define-fish boot 24 0 8 8
  :price 50)
(define-fish can-fish 16 8 16 8
  :price 200)
(define-fish tire 16 16 16 16
  :price 50)
(define-fish coelacanth 24 56 40 16
  :price 1000)
(define-fish boot-crate 32 0 16 16
  :price 100)
(define-fish megaroach 32 16 16 16
  :price 100)
(define-fish roach 48 0 8 8
  :price 50)
(define-fish seaweed 56 0 8 8
  :price 100)
(define-fish piranha 64 0 8 8
  :price 150)
(define-fish sandfish 48 8 24 8
  :price 150)
(define-fish ratfish 48 16 24 8
  :price 150)
(define-fish shroomfish 48 24 16 8
  :price 200)
(define-fish diving-helmet 64 24 8 8
  :price 100)
(define-fish three-eyed-fish 64 32 16 8
  :price 150)
(define-fish gyofish 64 40 16 16
  :price 300)
(define-fish ammonite 64 56 16 16
  :price 100)
(define-fish sand-dollar 72 0 8 8
  :price 150)
(define-fish clam 72 8 8 8
  :price 150)
(define-fish dopefish 72 16 16 16
  :price 2000)
(define-fish blowfish 80 0 16 16
  :price 150)
(define-fish blobfish 88 16 8 16
  :price 150)
(define-fish jellyfish 80 32 24 8
  :price 150)
(define-fish squid 80 40 16 8
  :price 150)
(define-fish fishing-rod 80 48 32 8
  :price 200)
(define-fish leaflet 80 56 8 8
  :price 50)
(define-fish shell 80 64 8 8
  :price 50)
(define-fish trout 88 56 24 8
  :price 150)
(define-fish electric-eel 88 64 40 8
  :price 150)
(define-fish anglerfish 96 0 32 16
  :price 150)
(define-fish action-figure 112 56 16 8
  :price 500)
(define-fish swordfish 0 72 64 24
  :price 300)
(define-fish swordfish2 64 80 48 16
  :price 100)
(define-fish nameplate 96 16 24 8
  :price 100)
(define-fish car-battery 96 24 8 8
  :price 50)
(define-fish seahorse 120 16 8 8
  :price 100)
(define-fish trilobite 104 24 16 16
  :price 100)
(define-fish rubber-duck 104 40 8 8
  :price 50)
(define-fish toy-submarine 112 40 8 8
  :price 50)
(define-fish alligator 64 72 48 8
  :price 300)
(define-fish distilled-water-bottle 120 24 8 8
  :price 100)

(define-random-draw desert-fishing
  (fish:fishing-rod     1.0)
  (fish:roach           1.0)
  (fish:three-eyed-fish 1.0)
  (fish:sand-dollar     1.0)
  (fish:shell           1.0)
  (fish:trilobite       1.0)
  (fish:piranha         0.5)
  (fish:sandfish        1.0)
  (fish:blobfish        0.5))

(define-random-draw structure-fishing
  (fish:can             1.0)
  (fish:boot            1.0)
  (fish:boot-crate      1.0)
  (fish:leaflet         1.0)
  (fish:car-battery     1.0)
  (fish:action-figure   0.5)
  (fish:seahorse        1.0)
  (fish:salmon          1.0)
  (fish:coelacanth      0.3)
  (fish:trout           1.0)
  (fish:electric-eel    1.0)
  (fish:distilled-water-bottle 1.0))

(define-random-draw cave-fishing
  (fish:tire            1.0)
  (fish:rubber-duck     1.0)
  (fish:ratfish         1.0)
  (fish:dopefish        0.5)
  (fish:crab            1.0)
  (fish:squid           1.0)
  (fish:alligator       1.0)
  (fish:seabass         1.0)
  (fish:sneaky-seabass  0.2)
  (fish:blowfish        1.0)
  (fish:swordfish       1.0))

(define-random-draw mushroom-fishing
  (fish:nameplate       1.0)
  (fish:toy-submarine   1.0)
  (fish:shroomfish      1.0)
  (fish:gyofish         1.0)
  (fish:seaweed         1.0)
  (fish:clam            1.0)
  (fish:jellyfish       1.0)
  (fish:shark           0.5)
  (fish:electric-eel    1.0))

(define-random-draw magma-fishing
  (fish:diving-helmet   1.0)
  (fish:megaroach       1.0)
  (fish:machine-fish    1.0)
  (fish:can-fish        1.0)
  (fish:swordfish2      0.5)
  (fish:ammonite        1.0)
  (fish:anglerfish      1.0))
