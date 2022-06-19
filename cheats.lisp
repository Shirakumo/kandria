(in-package #:org.shirakumo.fraf.kandria)

(defvar *cheat-codes* ())

(defstruct (cheat (:constructor make-cheat (name code effect)))
  (name NIL :type symbol)
  (idx 0 :type (unsigned-byte 8))
  (code "" :type simple-base-string)
  (effect NIL :type function))

(defun cheat (name)
  (find name *cheat-codes* :key #'cheat-name))

(defun (setf cheat) (cheat name)
  (let ((cheats (remove name *cheat-codes* :key #'cheat-name)))
    (setf *cheat-codes* (if cheat (list* cheat cheats) cheats))
    cheat))

(defmacro define-cheat (code &body action)
  (destructuring-bind (name code) (enlist code code)
    `(setf (cheat ',name) (make-cheat ',name
                                      ,(string-downcase code)
                                      (lambda () ,@action)))))

(defun process-cheats (key)
  (loop for cheat in *cheat-codes*
        for i = (cheat-idx cheat)
        for code = (cheat-code cheat)
        do (let ((new (if (string= key code :start2 i :end2 (+ i (length key))) (1+ i) 0)))
             (cond ((<= (length code) new)
                    (setf (cheat-idx cheat) 0)
                    (hide-panel 'cheat-panel)
                    (v:info :kandria.cheats "Activating cheat code ~s" (cheat-name cheat))
                    (let ((name (language-string (symb T 'cheat/ (cheat-name cheat)))))
                      (if (funcall (cheat-effect cheat))
                          (status (@formats 'game-cheat-activated name))
                          (status (@formats 'game-cheat-deactivated name)))))
                   (T
                    (setf (cheat-idx cheat) new))))))

(define-cheat hello
  T)

(define-cheat (cheat-console cheater)
  (show-panel 'cheat-panel)
  T)

(define-cheat tpose
  (clear-retained)
  (start-animation 't-pose (unit 'player T)))

(define-cheat god
  (setf (invincible-p (unit 'player T)) (not (invincible-p (unit 'player T)))))

(define-cheat armageddon
  (cond ((= 1 +health-multiplier+)
         (for:for ((entity over (region +world+)))
           (when (typep entity 'enemy)
             (setf (health entity) 1)))
         (setf +health-multiplier+ 0f0))
        (T
         (setf +health-multiplier+ 1f0)
         NIL)))

(define-cheat campfire
  (cond ((<= (clock-scale +world+) 60)
         (setf (clock-scale +world+) (* 60 30)))
        (T
         (setf (clock-scale +world+) 60)
         NIL)))

(define-cheat matrix
  (cond ((<= 0.9 (time-scale +world+))
         (setf (time-scale +world+) 0.1))
        (T
         (setf (time-scale +world+) 1.0)
         NIL)))

(define-cheat (i-cant-see |i can't see|)
  (setf (hour +world+) 12))

(define-cheat test
  (let ((room (unit 'debug T)))
    (when room
      (vsetf (location (unit 'player T))
             (vx (location room))
             (vy (location room)))
      (setf (intended-zoom (camera +world+)) 1.0)
      (snap-to-target (camera +world+) (unit 'player T)))))

(define-cheat self-destruct
  (cond ((<= (health (unit 'player T)) 1)
         (setf (health (unit 'player T)) 0)
         (kill (unit 'player T)))
        (T
         (trigger 'explosion (unit 'player T))
         (setf (health (unit 'player T)) 1))))

#-kandria-demo
(flet ((noclip ()
         (setf (state (unit 'player T))
               (case (state (unit 'player T))
                 (:noclip :normal)
                 (T :noclip)))
         (eql (state (unit 'player T)) :noclip)))
  (define-cheat noclip
    (noclip))

  (define-cheat SPISPOPD
    (noclip)))

(define-cheat nanomachines
  (setf (health (unit 'player T)) (maximum-health (unit 'player T))))

(define-cheat (you-must-die |you must die|)
  (kill (unit 'player T)))

(define-cheat (lp0-on-fire |lp0 on fire|)
  (error "Simulating an uncaught error."))

(define-cheat (lp1-on-fire |lp1 on fire|)
  (error 'gl:opengl-error :error-code :out-of-memory))

(define-cheat (lp2-on-fire |lp2 on fire|)
  (error 'gl:opengl-error :error-code :invalid-operation))

(define-cheat blingee
  (dolist (class (list-leaf-classes 'value-item))
    (store (class-name class) (unit 'player T))))

(define-cheat motherlode
  (store 'item:parts (unit 'player T) 10000))

(define-cheat (unlock-palettes |clothes make the woman|)
  (dolist (class (list-leaf-classes 'palette-unlock))
    (store (class-name class) (unit 'player T))))

#-kandria-release
(define-cheat snapshot
  (let ((state (or (state +main+) (first (list-saves)))))
    (when state
      (submit-trace state))))

#-kandria-demo
(define-cheat (developer |i am a developer|)
  (setf (setting :debugging :show-debug-settings) T))

(define-cheat (reveal-map |i can see forever|)
  (for:for ((unit over (region +world+)))
    (when (typep unit 'chunk)
      (setf (unlocked-p unit) T))))

#-kandria-demo
(define-cheat (unlock-fast-travel |lots and lots of trains|)
  (for:for ((unit over (region +world+)))
    (when (typep unit 'station)
      (setf (unlocked-p unit) T))))

(define-cheat (show-solids |show solid tiles|)
  (let (mode)
    (for:for ((unit over (region +world+)))
      (when (typep unit 'chunk)
        (unless mode
          (setf mode (if (show-solids unit) :off :on)))
        (case mode
          (:off (setf (show-solids unit) NIL))
          (:on (setf (show-solids unit) T)))))
    (case mode
      (:off NIL)
      (:on T))))

(define-cheat (level-up |i'm feeling stronger|)
  (incf (level (unit 'player T))))

(define-cheat (splits-panel |gotta go fast|)
  (toggle-panel 'splits))
