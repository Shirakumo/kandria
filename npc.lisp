(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity npc (ai-entity animatable ephemeral dialog-entity profile)
  ((bsize :initform (vec 8 16))))

(defmethod movement-speed ((npc npc))
  (case (state npc)
    (:crawling (p! crawl))
    (:climbing (p! climb-up))
    (T (p! walk-limit))))

(defmethod maximum-health ((npc npc))
  1000)

(defmethod handle :before ((ev tick) (npc npc))
  (nv+ (velocity npc) (v* (gravity (medium npc)) (* 100 (dt ev)))))

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
              (cond ((and (not (eql :keyboard +input-source+))
                          (< (abs (gamepad:axis :l-h +input-source+)) 0.5))
                     (setf (playback-speed npc) (/ (abs (vx vel)) (p! slowwalk-limit)))
                     (setf (animation npc) 'walk))
                    (T
                     (setf (playback-speed npc) (/ (abs (vx vel)) (p! walk-limit)))
                     (setf (animation npc) 'run))))
             (T
              (setf (animation npc) 'stand)))))
    (cond ((eql (name (animation npc)) 'slide)
           (harmony:play (// 'kandria 'slide)))
          (T
           (harmony:stop (// 'kandria 'slide))))))

(defmethod handle-ai-states ((npc npc) ev))

(define-shader-entity fi (npc)
  ((name :initform 'fi)
   (profile-sprite-data :initform (asset 'kandria 'fi-profile))
   (nametag :initform (@ fi-nametag)))
  (:default-initargs
   :sprite-data (asset 'kandria 'fi)))

(defmethod hurt ((fi fi) damage))

(define-shader-entity catherine (npc)
  ((name :initform 'catherine)
   (profile-sprite-data :initform (asset 'kandria 'fi-profile))
   (nametag :initform (@ catherine-nametag)))
  (:default-initargs
   :sprite-data (asset 'kandria 'catherine)))

(defmethod capable-p ((catherine catherine) (edge jump-node)) T)
(defmethod capable-p ((catherine catherine) (edge crawl-node)) T)
(defmethod capable-p ((catherine catherine) (edge climb-node)) T)

(defmethod hurt ((catherine catherine) damage))

(defmethod handle-ai-states ((catherine catherine) ev)
  (let ((player (unit 'player +world+)))
    (when (and (svref (collisions player) 2)
               (< (expt 64 2) (vsqrdist2 (location catherine) (location player))))
      (move-to (location player) catherine))))

(define-shader-entity pet (animatable ephemeral interactable)
  ())

(defmethod handle :before ((ev tick) (npc pet))
  (let ((vel (velocity npc))
        (dt (* 100 (dt ev))))
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
