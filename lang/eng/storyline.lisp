(in-package #:org.shirakumo.fraf.kandria)

(quest:define-storyline kandria
  :title "Kandria"
  :description "The main kandria storyline"
  :variables (weld-burn)
  :on-activate (q0-settlement-emergency lore))
