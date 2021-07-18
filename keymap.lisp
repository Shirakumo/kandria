(trigger toggle-editor
 (key :one-of (:section)))

(trigger toggle-diagnostics
 (key :one-of (:f10)))

(trigger toggle-fullscreen
 (key :one-of (:f11)))

(trigger report-bug
 (key :one-of (:f12)))

(trigger toggle-menu
 (key :one-of (:tab :esc :escape))
 (button :one-of (:select :home :start)))

(trigger screenshot
 (key :one-of (:print-screen)))

(trigger skip
 (key :one-of (:enter :space))
 (button :one-of (:b)))

(trigger advance
 (key :one-of (:enter :space))
 (mouse :one-of (:left))
 (button :one-of (:a :b)))

(trigger previous
 (key :one-of (:left :up :w :a))
 (button :one-of (:dpad-l :dpad-u))
 (axis :one-of (:l-h :dpad-h) :threshold -0.5)
 (axis :one-of (:l-v :dpad-v) :threshold +0.5))

(trigger next
 (key :one-of (:right :down :s :d))
 (button :one-of (:dpad-r :dpad-d))
 (axis :one-of (:l-h :dpad-h) :threshold +0.5)
 (axis :one-of (:l-v :dpad-v) :threshold -0.5))

(trigger accept
 (key :one-of (:e :enter))
 (button :one-of (:a)))

(trigger back
 (key :one-of (:esc :escape))
 (button :one-of (:b)))

(trigger quickmenu
 (key :one-of (:c :v))
 (button :one-of (:dpad-d))
 (axis :one-of (:dpad-v) :threshold -0.5))

(trigger interact
 (key :one-of (:e :enter))
 (button :one-of (:b)))

(retain jump
 (key :one-of (:space))
 (button :one-of (:a)))

(retain dash
 (key :one-of (:left-shift))
 (button :one-of (:r2))
 (axis :one-of (:r2) :threshold 0.25))

(retain climb
 (key :one-of (:left-control))
 (button :one-of (:l2))
 (axis :one-of (:l2) :threshold 0.25))

(trigger crawl
 (key :one-of (:q))
 (button :one-of (:l3)))

(trigger light-attack
 (key :one-of (:z))
 (mouse :one-of (:left))
 (button :one-of (:x)))

(trigger heavy-attack
 (key :one-of (:x))
 (mouse :one-of (:right))
 (button :one-of (:y)))

(retain left
 (key :one-of (:a :left))
 (axis :one-of (:l-h) :threshold -0.5))

(retain right
 (key :one-of (:d :right))
 (axis :one-of (:l-h) :threshold 0.5))

(retain up
 (key :one-of (:w :up))
 (axis :one-of (:l-v) :threshold 0.5))

(retain down
 (key :one-of (:s :down))
 (axis :one-of (:l-v) :threshold -0.5))

(trigger cast-line
 (key :one-of (:space :e))
 (button :one-of (:a)))

(trigger reel-in
 (key :one-of (:space :e))
 (button :one-of (:a)))

(trigger stop-fishing
 (key :one-of (:backspace :enter))
 (button :one-of (:b)))
