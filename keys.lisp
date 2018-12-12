(in-package #:org.shirakumo.fraf.leaf)

(define-action editor-command ())

;;; Left Block
(define-action select-entity (editor-command)
  (key-press (one-of key :tab)))

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

;;; F Group 1
(define-action save-level (editor-command)
  (key-press (one-of key :f1)))

(define-action load-level (editor-command)
  (key-press (one-of key :f2)))

(define-action save-state (editor-command)
  (key-press (one-of key :f3)))

(define-action load-state (editor-command)
  (key-press (one-of key :f4)))

;;; F Group 2
(define-action resize-entity (editor-command)
  (key-press (one-of key :f5)))

(define-action change-tile (editor-command)
  (key-press (one-of key :f6)))

;;; F Group 3
(define-action inspect-entity (editor-command)
  (key-press (one-of key :f12)))

;;; Action Block
(define-action delete-entity (editor-command)
  (key-press (one-of key :delete)))

(define-action insert-entity (editor-command)
  (key-press (one-of key :insert)))

(define-action next-entity (editor-command)
  (key-press (one-of key :page-down)))

(define-action prev-entity (editor-command)
  (key-press (one-of key :page-up)))

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

(define-action movement ())

(define-action interact (movement)
  (key-press (one-of key :enter :e))
  (gamepad-press (one-of button :y)))

(define-action dash (movement)
  (key-press (one-of key :left-shift))
  (gamepad-press (one-of button :x)))

(define-action start-jump (movement)
  (key-press (one-of key :space))
  (gamepad-press (one-of button :a)))

(define-action start-climb (movement)
  (key-press (one-of key :left-control))
  (gamepad-press (one-of button :r2 :l2)))

(define-action start-left (movement)
  (key-press (one-of key :a :left))
  (gamepad-move (one-of axis :l-h :dpad-h) (< pos -0.2 old-pos)))

(define-action start-right (movement)
  (key-press (one-of key :d :right))
  (gamepad-move (one-of axis :l-h :dpad-h) (< old-pos 0.2 pos)))

(define-action start-up (movement)
  (key-press (one-of key :w :up))
  (gamepad-move (one-of axis :l-v :dpad-v) (< pos -0.2 old-pos)))

(define-action start-down (movement)
  (key-press (one-of key :s :down))
  (gamepad-move (one-of axis :l-v :dpad-v) (< old-pos 0.2 pos)))

(define-action end-jump (movement)
  (key-release (one-of key :space))
  (gamepad-release (one-of button :a)))

(define-action end-climb (movement)
  (key-release (one-of key :left-control))
  (gamepad-release (one-of button :r2 :l2)))

(define-action end-left (movement)
  (key-release (one-of key :a :left))
  (gamepad-move (one-of axis :l-h :dpad-h) (< old-pos -0.2 pos)))

(define-action end-right (movement)
  (key-release (one-of key :d :right))
  (gamepad-move (one-of axis :l-h :dpad-h) (< pos 0.2 old-pos)))

(define-action end-up (movement)
  (key-release (one-of key :w :up))
  (gamepad-move (one-of axis :l-v :dpad-v) (< old-pos -0.2 pos)))

(define-action end-down (movement)
  (key-release (one-of key :s :down))
  (gamepad-move (one-of axis :l-v :dpad-v) (< pos 0.2 old-pos)))

(define-retention movement (ev)
  (typecase ev
    (start-jump (setf (retained 'movement :jump) T))
    (start-climb (setf (retained 'movement :climb) T))
    (start-left (setf (retained 'movement :left) T))
    (start-right (setf (retained 'movement :right) T))
    (start-up (setf (retained 'movement :up) T))
    (start-down (setf (retained 'movement :down) T))
    (end-jump (setf (retained 'movement :jump) NIL))
    (end-climb (setf (retained 'movement :climb) NIL))
    (end-left (setf (retained 'movement :left) NIL))
    (end-right (setf (retained 'movement :right) NIL))
    (end-up (setf (retained 'movement :up) NIL))
    (end-down (setf (retained 'movement :down) NIL))))
