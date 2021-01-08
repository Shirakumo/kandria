(trigger toggle-editor
 (key :one-of (:section)))

(trigger toggle-diagnostics
 (key :one-of (:f11)))

(trigger report-bug
 (key :one-of (:f12)))

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
 (axis :one-of (:l-v :dpad-v :l-h :dpad-h) :threshold +0.5))

(trigger next
 (key :one-of (:right :down :s :d))
 (button :one-of (:dpad-r :dpad-d))
 (axis :one-of (:l-v :dpad-v :l-h :dpad-h) :threshold -0.5))

(trigger accept
 (key :one-of (:enter))
 (button :one-of (:a)))

(trigger back
 (key :one-of (:esc :escape :backspace))
 (button :one-of (:b)))

(trigger pause
 (key :one-of (:esc :escape))
 (button :one-of (:home :start)))

(trigger quicksave
 (key :one-of (:f5)))

(trigger quickload
 (key :one-of (:f9)))

(trigger interact
 (key :one-of (:enter :e))
 (button :one-of (:y)))

(trigger crawl
 (key :one-of (:q))
 (button :one-of (:l3)))

(trigger light-attack
 (mouse :one-of (:left))
 (button :one-of (:b)))

(trigger heavy-attack
 (mouse :one-of (:right))
 (button :one-of (:y)))

(retain dash
 (key :one-of (:left-shift))
 (button :one-of (:r2))
 (axis :one-of (:r2) :threshold 0.4))

(retain jump
 (key :one-of (:space))
 (button :one-of (:a)))

(retain climb
 (key :one-of (:left-control))
 (button :one-of (:l2))
 (axis :one-of (:l2) :threshold 0.4))

(retain left
 (key :one-of (:a :left))
 (axis :one-of (:l-h) :threshold -0.4))

(retain right
 (key :one-of (:d :right))
 (axis :one-of (:l-h) :threshold 0.4))

(retain up
 (key :one-of (:w :up))
 (axis :one-of (:l-v) :threshold 0.4))

(retain down
 (key :one-of (:s :down))
 (axis :one-of (:l-v) :threshold -0.8))
