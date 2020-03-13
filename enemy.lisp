(in-package #:org.shirakumo.fraf.leaf)

(define-asset (leaf placeholder-anim) image
      #p"placeholder-anim.png")

(define-shader-subject enemy (animatable solid)
  ((bsize :initform (nv/ (vec 16 16) 2))
   (size :initform (vec 16 16))
   (texture :initform (asset 'leaf 'placeholder-anim)))
  (:default-initargs
   :animations '((idle :start 0 :end 1 :step 0.1)
                 (hurt :start 1 :end 2 :step 0.1)
                 (die :start 2 :end 3 :step 0.1))))

(defmethod tick :before ((enemy enemy) ev)
  (let ((collisions (collisions enemy))
        (vel (velocity enemy))
        (acc (acceleration enemy)))
    (cond ((svref collisions 2)
           (nv* acc (damp* 0.9 100 (dt ev))))
          (T
           (when (<= 2 (vx acc))
             (setf (vx acc) (* (vx acc) (damp* 0.95 100 (dt ev)))))
           (decf (vy acc) (* +vgrav+ 20 (dt ev)))))
    (when (svref collisions 0) (setf (vy acc) (min 0 (vy acc))))
    (when (svref collisions 2) (setf (vy acc) (max 0 (vy acc))))
    (when (svref collisions 1) (setf (vx acc) (min 0 (vx acc))))
    (when (svref collisions 3) (setf (vx acc) (max 0 (vx acc))))
    (when (<= (vlength acc) 0.01)
      (vsetf acc 0 0))
    (ecase (state enemy)
      ((:dying :animated :stunned)
       (handle-animation-states enemy ev))
      (:normal
       (setf (animation enemy) 'idle)))
    (nvclamp (v- +vlim+) acc +vlim+)
    (nv+ vel acc)))

(defmethod tick :after ((enemy enemy) ev)
  (unless (contained-p (location enemy) (surface enemy))
    (vsetf (location enemy)
           (vx (location (surface enemy)))
           (vy (location (surface enemy))))))
