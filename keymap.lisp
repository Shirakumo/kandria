(trigger toggle-editor
 (key :one-of (:section :f2)))

(trigger toggle-diagnostics
 (key :one-of (:f10)))

(trigger toggle-fullscreen
 (key :one-of (:f11)))

(trigger load-state)

(trigger report-bug
 (key :one-of (:f1)))

(trigger toggle-menu
 (key :one-of (:tab))
 (button :one-of (:start :home)))

(trigger screenshot
 (key :one-of (:print-screen)))

(trigger skip
 (key :one-of (:enter :space))
 (button :one-of (:b)))

(trigger advance
 (key :one-of (:enter :space))
 (mouse :one-of (:left))
 (button :one-of (:a :b)))

(trigger select-left
 (key :one-of (:left :a))
 (button :one-of (:dpad-l))
 (axis :one-of (:l-h :dpad-h) :threshold -0.5))

(trigger select-right
 (key :one-of (:right :d))
 (button :one-of (:dpad-r))
 (axis :one-of (:l-h :dpad-h) :threshold +0.5))

(trigger select-down
 (key :one-of (:down :s))
 (button :one-of (:dpad-d))
 (axis :one-of (:l-v :dpad-v) :threshold -0.5))

(trigger select-up
 (key :one-of (:up :w))
 (button :one-of (:dpad-u))
 (axis :one-of (:l-v :dpad-v) :threshold +0.5))

(trigger accept
 (key :one-of (:enter :e))
 (button :one-of (:a)))

(trigger back
 (key :one-of (:escape :c))
 (button :one-of (:b :select)))

(trigger mark-for-bulk
 (key :one-of (:m))
 (mouse :one-of (:middle))
 (button :one-of (:y)))

(trigger quickmenu
 (key :one-of (:c))
 (button :one-of (:select)))

(trigger open-map
 (key :one-of (:m))
 (button :one-of (:r1 :home)))

(trigger interact
 (key :one-of (:f :e :enter))
 (button :one-of (:b)))

(trigger jump
 (key :one-of (:space))
 (button :one-of (:a)))

(trigger dash
 (key :one-of (:left-shift))
 (button :one-of (:r2))
 (axis :one-of (:r2) :threshold 0.25))

(trigger climb
 (key :one-of (:left-control))
 (button :one-of (:l2))
 (axis :one-of (:l2) :threshold 0.25))

(trigger crawl
 (key :one-of (:v :q))
 (button :one-of (:l1 :l3)))

(trigger light-attack
 (key :one-of (:z))
 (mouse :one-of (:left))
 (button :one-of (:x)))

(trigger heavy-attack
 (key :one-of (:x))
 (mouse :one-of (:right))
 (button :one-of (:y)))

(trigger left
 (key :one-of (:left :a))
 (button :one-of (:dpad-l))
 (axis :one-of (:l-h :dpad-h) :threshold -0.5))

(trigger right
 (key :one-of (:right :d))
 (button :one-of (:dpad-r))
 (axis :one-of (:l-h :dpad-h) :threshold 0.5))

(trigger up
 (key :one-of (:up :w))
 (button :one-of (:dpad-u))
 (axis :one-of (:l-v :dpad-v) :threshold 0.5))

(trigger down
 (key :one-of (:down :s))
 (button :one-of (:dpad-d))
 (axis :one-of (:l-v :dpad-v) :threshold -0.5))

(trigger cast-line
 (key :one-of (:space :e))
 (button :one-of (:a)))

(trigger reel-in
 (key :one-of (:space :e))
 (button :one-of (:a)))

(trigger stop-fishing
 (key :one-of (:backspace :enter))
 (button :one-of (:b)))

(trigger zoom-in
 (key :one-of (:e))
 (button :one-of (:r2))
 (axis :one-of (:r2) :threshold 0.5))

(trigger zoom-out
 (key :one-of (:q :minus))
 (button :one-of (:l2))
 (axis :one-of (:l2) :threshold 0.5))

(trigger close-map
 (key :one-of (:escape :m))
 (button :one-of (:b :start :r1)))

(trigger toggle-trace
 (key :one-of (:c :tab))
 (button :one-of (:y)))

(trigger toggle-marker
 (key :one-of (:space))
 (mouse :one-of (:middle))
 (button :one-of (:a)))

(trigger pan-left
 (key :one-of (:a :left))
 (button :one-of (:dpad-l))
 (axis :one-of (:l-h :dpad-h) :threshold -0.5))

(trigger pan-right
 (key :one-of (:d :right))
 (button :one-of (:dpad-r))
 (axis :one-of (:l-h :dpad-h) :threshold 0.5))

(trigger pan-up
 (key :one-of (:w :up))
 (button :one-of (:dpad-u))
 (axis :one-of (:l-v :dpad-v) :threshold 0.5))

(trigger pan-down
 (key :one-of (:s :down))
 (button :one-of (:dpad-d))
 (axis :one-of (:l-v :dpad-v) :threshold -0.5))
