(in-package #:org.shirakumo.fraf.kandria)

(defvar *cheat-codes* ())

(defstruct (cheat (:constructor make-cheat (name code effect)))
  (name NIL :type string)
  (idx 0 :type (unsigned-byte 8))
  (code "" :type simple-base-string)
  (effect NIL :type function))

(defun cheat (name)
  (find name *cheat-codes* :key #'cheat-name :test #'string-equal))

(defun (setf cheat) (cheat name)
  (let ((cheats (remove name *cheat-codes* :key #'cheat-name :test #'string-equal)))
    (setf *cheat-codes* (if cheat (list* cheat cheats) cheats))
    cheat))

(defmacro define-cheat (code name &body action)
  (check-type name string)
  `(setf (cheat ,name) (make-cheat ,name ,(string-downcase code) (lambda () ,@action))))

(defun process-cheats (key)
  (loop for cheat in *cheat-codes*
        for i = (cheat-idx cheat)
        for code = (cheat-code cheat)
        do (let ((new (if (string= key code :start2 i :end2 (+ i (length key))) (1+ i) 0)))
             (cond ((<= (length code) new)
                    (setf (cheat-idx cheat) 0)
                    (v:info :kandria.cheats "Activating cheat code ~s" (cheat-name cheat))
                    (if (funcall (cheat-effect cheat))
                        (status "Cheat ~s activated!" (cheat-name cheat))
                        (status "Cheat ~s deactivated" (cheat-name cheat))))
                   (T
                    (setf (cheat-idx cheat) new))))))

(define-cheat hello "Test cheat"
  (status "Hi there!"))

(define-cheat tpose "T-pose"
  (clear-retained)
  (start-animation 't-pose (unit 'player T)))

(define-cheat god "God mode"
  (setf (invincible-p (unit 'player T)) (not (invincible-p (unit 'player T)))))

(define-cheat armageddon "Armageddon"
  (cond ((= 1 +health-multiplier+)
         (for:for ((entity over (region +world+)))
           (when (typep entity 'enemy)
             (setf (health entity) 1)))
         (setf +health-multiplier+ 0f0))
        (T
         (setf +health-multiplier+ 1f0)
         NIL)))

(define-cheat campfire "Grill some marshmallows"
  (cond ((<= (hour-scale +world+) 60)
         (setf (hour-scale +world+) (* 60 60)))
        (T
         (setf (hour-scale +world+) 60)
         NIL)))

(define-cheat chaos\ control "You're the fake hedgehog"
  (cond ((<= 0.9 (time-scale +world+))
         (setf (time-scale +world+) 0.1))
        (T
         (setf (time-scale +world+) 1.0)
         NIL)))

(define-cheat test "Testing room"
  (let ((room (unit 'debug T)))
    (when room
      (vsetf (location (unit 'player T))
             (vx (location room))
             (vy (location room)))
      (snap-to-target (unit :camera T) (unit 'player T)))))
