(in-package #:org.shirakumo.fraf.leaf)

(define-action editor-command ())

(define-action toggle-editor (editor-command)
  (key-press (one-of key :section)))

(define-action control-down (editor-command)
  (key-press (one-of key :left-control :right-control)))

(define-action control-up (editor-command)
  (key-release (one-of key :left-control :right-control)))

(define-action alt-down (editor-command)
  (key-press (one-of key :left-alt :right-alt)))

(define-action alt-up (editor-command)
  (key-release (one-of key :left-alt :right-alt)))

(define-action shift-down (editor-command)
  (key-press (one-of key :left-shift :right-shift)))

(define-action shift-up (editor-command)
  (key-release (one-of key :left-shift :right-shift)))

(define-action undo (editor-command)
  (key-press (and (one-of key :z)
                  (retained 'modifiers :control))))

(define-action redo (editor-command)
  (key-press (and (one-of key :y)
                  (retained 'modifiers :control))))

(define-retention mouse (ev)
  (when (typep ev 'mouse-press)
    (setf (retained 'mouse (button ev)) T))
  (when (typep ev 'mouse-release)
    (setf (retained 'mouse (button ev)) NIL)))

(define-retention modifiers (ev)
  (typecase ev
    (control-down (setf (retained 'modifiers :control) T))
    (control-up (setf (retained 'modifiers :control) NIL))
    (alt-down (setf (retained 'modifiers :alt) T))
    (alt-up (setf (retained 'modifiers :alt) NIL))
    (shift-down (setf (retained 'modifiers :shift) T))
    (shift-up (setf (retained 'modifiers :shift) NIL))))

(define-action menuing ())

(define-action skip (menuing)
  (key-press (one-of key :enter :space))
  (gamepad-press (one-of button :b)))

(define-action advance (menuing)
  (key-press (one-of key :enter :space))
  (gamepad-press (one-of button :a :b)))

(define-action previous (menuing)
  (key-press (one-of key :left :up :w :a))
  (gamepad-press (one-of button :dpad-l :dpad-u))
  (gamepad-move (one-of axis :l-v :dpad-v :l-h :dpad-h) (< pos -0.5 old-pos)))

(define-action next (menuing)
  (key-press (one-of key :right :down :s :d))
  (gamepad-press (one-of button :dpad-r :dpad-d))
  (gamepad-move (one-of axis :l-v :dpad-v :l-h :dpad-h) (< pos +0.5 old-pos)))

(define-action accept (menuing)
  (key-press (one-of key :enter))
  (gamepad-press (one-of button :a)))

(define-action back (menuing)
  (key-press (one-of key :esc :escape :backspace))
  (gamepad-press (one-of button :b)))

(define-action pause (menuing)
  (key-press (one-of key :esc :escape))
  (gamepad-press (one-of button :home)))

(define-action quicksave (menuing)
  (key-press (one-of key :f5)))

(define-action quickload (menuing)
  (key-press (one-of key :f9)))

(define-action movement ())

(define-action interact (movement)
  (key-press (one-of key :enter :e))
  (gamepad-press (one-of button :y)))

(define-action start-dash (movement)
  (key-press (one-of key :left-shift))
  (gamepad-press (one-of button :r2))
  (gamepad-move (one-of axis :r2) (< old-pos 0.4 pos)))

(define-action end-dash (movement)
  (key-release (one-of key :left-shift))
  (gamepad-release (one-of button :r2))
  (gamepad-move (one-of axis :r2) (< pos 0.4 old-pos)))

(define-action crawl (movement)
  (key-press (one-of key :q))
  (gamepad-press (one-of button :l3)))

(define-action light-attack (movement)
  (mouse-press (one-of button :left))
  (gamepad-press (one-of button :b)))

(define-action heavy-attack (movement)
  (mouse-press (one-of button :right))
  (gamepad-press (one-of button :y)))

(define-action start-jump (movement)
  (key-press (one-of key :space))
  (gamepad-press (one-of button :a)))

(define-action start-climb (movement)
  (key-press (one-of key :left-control))
  (gamepad-press (one-of button :l2))
  (gamepad-move (one-of axis :l2) (< old-pos 0.4 pos)))

(define-action start-left (movement)
  (key-press (one-of key :a :left))
  (gamepad-press (one-of button :dpad-l))
  (gamepad-move (one-of axis :l-h :dpad-h) (< pos -0.4 old-pos)))

(define-action start-right (movement)
  (key-press (one-of key :d :right))
  (gamepad-press (one-of button :dpad-r))
  (gamepad-move (one-of axis :l-h :dpad-h) (< old-pos 0.4 pos)))

(define-action start-up (movement)
  (key-press (one-of key :w :up))
  (gamepad-press (one-of button :dpad-u))
  (gamepad-move (one-of axis :l-v :dpad-v) (< old-pos 0.4 pos)))

(define-action start-down (movement)
  (key-press (one-of key :s :down))
  (gamepad-press (one-of button :dpad-d))
  (gamepad-move (one-of axis :l-v :dpad-v) (< pos -0.8 old-pos)))

(define-action end-jump (movement)
  (key-release (one-of key :space))
  (gamepad-release (one-of button :a)))

(define-action end-climb (movement)
  (key-release (one-of key :left-control))
  (gamepad-release (one-of button :l2))
  (gamepad-move (one-of axis :l2) (< pos 0.4 old-pos)))

(define-action end-left (movement)
  (key-release (one-of key :a :left))
  (gamepad-release (one-of button :dpad-l))
  (gamepad-move (one-of axis :l-h :dpad-h) (< old-pos -0.4 pos)))

(define-action end-right (movement)
  (key-release (one-of key :d :right))
  (gamepad-release (one-of button :dpad-r))
  (gamepad-move (one-of axis :l-h :dpad-h) (< pos 0.4 old-pos)))

(define-action end-up (movement)
  (key-release (one-of key :w :up))
  (gamepad-release (one-of button :dpad-u))
  (gamepad-move (one-of axis :l-v :dpad-v) (< pos 0.4 old-pos)))

(define-action end-down (movement)
  (key-release (one-of key :s :down))
  (gamepad-release (one-of button :dpad-d))
  (gamepad-move (one-of axis :l-v :dpad-v) (< old-pos -0.8 pos)))

(define-retention movement (ev)
  (typecase ev
    (start-jump (setf (retained 'movement :jump) T))
    (start-climb (setf (retained 'movement :climb) T))
    (start-left (setf (retained 'movement :left) T))
    (start-right (setf (retained 'movement :right) T))
    (start-up (setf (retained 'movement :up) T))
    (start-down (setf (retained 'movement :down) T))
    (start-dash (setf (retained 'movement :dash) T))
    (end-jump (setf (retained 'movement :jump) NIL))
    (end-climb (setf (retained 'movement :climb) NIL))
    (end-left (setf (retained 'movement :left) NIL))
    (end-right (setf (retained 'movement :right) NIL))
    (end-up (setf (retained 'movement :up) NIL))
    (end-down (setf (retained 'movement :down) NIL))
    (end-dash (setf (retained 'movement :dash) NIL))))
