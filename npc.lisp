(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity npc (ai-entity animatable ephemeral dialog-entity profile)
  ((bsize :initform (vec 8 16))
   (target :initform NIL :accessor target)
   (companion :initform NIL :accessor companion)
   (walk :initform NIL :accessor walk)
   (lead-interrupt :initform "| Where are you going? It's this way!" :accessor lead-interrupt)))

(defmethod movement-speed ((npc npc))
  (case (state npc)
    (:crawling (p! crawl))
    (:climbing (p! climb-up))
    (T (if (walk npc)
           (p! slowwalk-limit)
           (p! walk-limit)))))

(defmethod maximum-health ((npc npc))
  1000)

(defmethod hurt ((npc npc) (player player)))

(defmethod handle :after ((ev tick) (npc npc))
  (let ((vel (velocity npc))
        (collisions (collisions npc)))
    (setf (playback-direction npc) +1)
    (setf (playback-speed npc) 1.0)
    (case (state npc)
      (:climbing
       (setf (animation npc) 'climb)
       (cond
         ((< (vy vel) 0)
          (setf (playback-direction npc) -1)
          (setf (playback-speed npc) 1.5))
         ((= 0 (vy vel))
          (setf (clock npc) 0.0))))
      (:crawling
       (cond ((< 0 (vx vel))
              (setf (direction npc) +1))
             ((< (vx vel) 0)
              (setf (direction npc) -1)))
       (setf (animation npc) 'crawl)
       (when (= 0 (vx vel))
         (setf (clock npc) 0.0)))
      (:normal
       (cond ((< 0 (vx vel))
              (setf (direction npc) +1))
             ((< (vx vel) 0)
              (setf (direction npc) -1)))
       (cond ((< 0 (vy vel))
              (setf (animation npc) 'jump))
             ((null (svref collisions 2))
              (cond ((< (air-time npc) 0.1))
                    ((typep (svref collisions 1) 'ground)
                     (setf (animation npc) 'fall)
                     (setf (direction npc) +1)
                     (when (< (clock npc) 0.01)
                       (trigger 'slide npc :direction -1)))
                    ((typep (svref collisions 3) 'ground)
                     (setf (animation npc) 'fall)
                     (setf (direction npc) -1)
                     (when (< (clock npc) 0.01)
                       (trigger 'slide npc :direction +1)))
                    (T
                     (setf (animation npc) 'fall))))
             ((< 0 (abs (vx vel)))
              (setf (playback-speed npc) (/ (abs (vx vel)) (p! walk-limit)))
              (setf (animation npc) 'run))
             (T
              (setf (animation npc) 'stand)))))
    (cond ((eql (name (animation npc)) 'slide)
           (harmony:play (// 'kandria 'slide)))
          (T
           (harmony:stop (// 'kandria 'slide))))))

(defmethod handle-ai-states ((npc npc) ev)
  (let ((companion (companion npc)))
    (case (ai-state npc)
      (:normal)
      (:move-to
       (if (path npc)
           (execute-path npc ev)
           (setf (ai-state npc) :normal)))
      (:lead
       (let ((distance (vsqrdist2 (location npc) (location companion))))
         (cond ((< (expt (* 20 +tile-size+) 2) distance)
                (setf (ai-state npc) :lead-check))
               ((< (vsqrdist2 (location npc) (target npc)) (expt (* 2 +tile-size+) 2))
                (setf (companion npc) NIL)
                (setf (path npc) ())
                (setf (ai-state npc) :normal))
               ((null (path npc))
                (unless (move-to (target npc) npc)
                  (error "What the fuck? Don't know how to get to ~a" (target npc))))
               (T
                (execute-path npc ev)))))
      (:lead-check
       (let ((distance (vsqrdist2 (location npc) (location companion))))
         (cond ((< distance (expt (* 10 +tile-size+) 2))
                (interrupt-walk-n-talk NIL)
                (setf (ai-state npc) :lead))
               ((close-to-path-p (location companion) (path npc) (* 5 +tile-size+))
                (interrupt-walk-n-talk NIL)
                (setf (ai-state npc) :lead-teleport))
               (T
                (interrupt-walk-n-talk (lead-interrupt npc))))))
      (:lead-teleport
       (when (svref (collisions companion) 2)
         (vsetf (location npc)
                (vx (location companion))
                (+ (vy (location companion)) 4))
         (if (move-to (target npc) npc)
             (setf (ai-state npc) :lead)
             (setf (ai-state npc) :lead-check))))
      (:follow
       (let ((distance (vsqrdist2 (location npc) (location companion))))
         (cond ((path npc)
                (execute-path npc ev))
               ((< distance (expt (* 5 +tile-size+) 2))
                (setf (vx (velocity npc)) 0))
               (T
                (setf (ai-state npc) :follow-check)))))
      (:follow-check
       (let ((distance (vsqrdist2 (location npc) (location companion))))
         (cond ((< distance (expt (* 3 +tile-size+) 2))
                (setf (ai-state npc) :follow))
               ((< (expt (* 40 +tile-size+) 2) distance)
                ;; TODO: shout where are you, then timer it.
                (setf (ai-state npc) :follow-teleport))
               (T
                (when (move-to companion npc)
                  (setf (ai-state npc) :follow))))))
      (:follow-teleport
       ;; TODO: Smart-teleport: search for places just outside view of the companion from
       ;;       which the companion is reachable
       (when (svref (collisions companion) 2)
         (vsetf (location npc)
                (vx (location companion))
                (+ (vy (location companion)) 4))
         (setf (ai-state npc) :follow)))
      (:cowering
       (cond ((enemies-present-p (location npc))
              (unless (find (state npc) '(:animated :stunned :dying))
                (start-animation 'cower npc)))
             ((target npc)
              (setf (state npc) :normal)
              (lead (companion npc) (target npc) npc))
             ((companion npc)
              (setf (state npc) :normal)
              (follow (companion npc) npc)))))))

(defmethod hurt :after ((npc npc) (enemy enemy))
  (setf (state npc) :cowering))

(defmethod follow ((target located-entity) (npc npc))
  (setf (walk npc) NIL)
  (setf (path npc) NIL)
  (setf (current-node npc) NIL)
  (setf (companion npc) target)
  (setf (ai-state npc) :follow))

(defmethod stop-following ((npc npc))
  (setf (companion npc) NIL)
  (setf (target npc) NIL)
  (setf (ai-state npc) :normal))

(defmethod lead (target (goal located-entity) npc)
  (lead target (vcopy (location goal)) npc))

(defmethod lead ((target located-entity) (goal vec2) (npc npc))
  (setf (walk npc) NIL)
  (setf (path npc) NIL)
  (setf (current-node npc) NIL)
  (setf (target npc) goal)
  (setf (companion npc) target)
  (setf (ai-state npc) :lead))

(defmethod move-to :after (target (npc npc))
  (when (eql :normal (ai-state npc))
    (setf (ai-state npc) :move-to)))

(define-unit-resolver-methods (setf lead-interrupt) (thing unit))
(define-unit-resolver-methods (setf walk) (thing unit))
(define-unit-resolver-methods follow (unit unit))
(define-unit-resolver-methods stop-following (unit))
(define-unit-resolver-methods lead (unit unit unit))

(define-shader-entity fi (npc)
  ((name :initform 'fi)
   (profile-sprite-data :initform (asset 'kandria 'fi-profile))
   (nametag :initform (@ fi-nametag)))
  (:default-initargs
   :sprite-data (asset 'kandria 'fi)))

(define-shader-entity catherine (npc)
  ((name :initform 'catherine)
   (profile-sprite-data :initform (asset 'kandria 'catherine-profile))
   (nametag :initform (@ catherine-nametag))
   (lead-interrupt :initform "~ catherine
| (:shout) Come on! It's this way!"))
  (:default-initargs
   :sprite-data (asset 'kandria 'catherine)))

(defmethod capable-p ((catherine catherine) (edge jump-node)) T)
(defmethod capable-p ((catherine catherine) (edge crawl-node)) T)
(defmethod capable-p ((catherine catherine) (edge climb-node)) T)

(define-shader-entity jack (npc)
  ((name :initform 'jack)
   (profile-sprite-data :initform (asset 'kandria 'jack-profile))
   (nametag :initform (@ jack-nametag)))
  (:default-initargs
   :sprite-data (asset 'kandria 'jack)))

(defmethod (setf animation) ((_ (eql 'run)) (jack jack))
  (setf (animation jack) 'walk))
  
(define-shader-entity trader (npc)
  ((name :initform 'trader)
   (profile-sprite-data :initform (asset 'kandria 'fi-profile))
   (nametag :initform (@ trader-nametag)))
  (:default-initargs
   :sprite-data (asset 'kandria 'sahil)))

(define-shader-entity pet (animatable ephemeral interactable)
  ())

(defmethod handle :before ((ev tick) (npc pet))
  (let ((vel (velocity npc))
        (dt (dt ev)))
    (case (state npc)
      ((:dying :animated :stunned)
       (handle-animation-states npc ev))
      (T
       (nv+ vel (v* (gravity (medium npc)) dt))))
    (nv+ (frame-velocity npc) vel)))

(defmethod handle :after ((ev tick) (npc pet))
  (case (state npc)
    (:normal
     (let ((player (unit 'player T)))
       (case (name (animation npc))
         (sleep
          (when (< (vsqrdist2 (location player) (location npc))
                   (expt (* 3 +tile-size+) 2))
            (setf (animation npc) 'wake)))
         (pet)
         (wake
          (when (< (expt (* 4 +tile-size+) 2)
                   (vsqrdist2 (location player) (location npc)))
            (setf (animation npc) 'lay))))))))

(defmethod interactable-p ((npc pet))
  (eql 'wake (name (animation npc))))

(defmethod interact ((npc pet) (player player))
  (setf (animation npc) 'pet)
  (start-animation 'pet player))

(define-shader-entity tame-wolf (pet)
  ()
  (:default-initargs
   :sprite-data (asset 'kandria 'wolf)))

;; KLUDGE: add proper idle at some point.
(defmethod idleable-p ((npc tame-wolf)) NIL)
