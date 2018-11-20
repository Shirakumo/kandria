(in-package #:org.shirakumo.fraf.leaf)

(define-action editor-command ())

(define-action toggle-editor (editor-command)
  (key-press (one-of key :section)))

(define-action delete-entity (editor-command)
  (key-press (one-of key :delete)))

(define-action insert-entity (editor-command)
  (key-press (one-of key :insert)))

(define-action standard-entity (editor-command)
  (key-press (one-of key :home)))

(define-action select-entity (editor-command)
  (key-press (one-of key :tab)))

(define-action next-entity (editor-command)
  (key-press (one-of key :page-down)))

(define-action prev-entity (editor-command)
  (key-press (one-of key :page-up)))

(define-action resize-chunk (editor-command)
  (key-press (one-of key :f9)))

(define-action save-state (editor-command)
  (key-press (one-of key :f5)))

(define-action load-state (editor-command)
  (key-press (one-of key :f6)))

(define-action control-down (editor-command)
  (key-press (one-of key :left-control :right-control)))

(define-action control-up (editor-command)
  (key-release (one-of key :left-control :right-control)))

(define-action alt-down (editor-command)
  (key-press (one-of key :left-alt :right-alt)))

(define-action alt-up (editor-command)
  (key-release (one-of key :left-alt :right-alt)))

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
    (alt-up (setf (retained 'modifiers :alt) NIL))))

(define-action skip ()
  (key-press (one-of key :enter :space))
  (gamepad-press (one-of button :b)))

(define-action next ()
  (key-press (one-of key :enter :space))
  (gamepad-press (one-of button :a :b)))

(define-action movement ())

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
  (key-press (one-of key :d :e :right))
  (gamepad-move (one-of axis :l-h :dpad-h) (< old-pos 0.2 pos)))

(define-action start-up (movement)
  (key-press (one-of key :w :\, :up))
  (gamepad-move (one-of axis :l-v :dpad-v) (< pos -0.2 old-pos)))

(define-action start-down (movement)
  (key-press (one-of key :s :o :down))
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
  (key-release (one-of key :d :e :right))
  (gamepad-move (one-of axis :l-h :dpad-h) (< pos 0.2 old-pos)))

(define-action end-up (movement)
  (key-release (one-of key :w :\, :up))
  (gamepad-move (one-of axis :l-v :dpad-v) (< old-pos -0.2 pos)))

(define-action end-down (movement)
  (key-release (one-of key :s :o :down))
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
