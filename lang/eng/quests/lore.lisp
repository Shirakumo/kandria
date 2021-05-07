;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria lore)
  :author "Tim White"
  :title "The World"
  :description "This world is unfamiliar to me. I should explore and learn more about it."
  :on-activate (region1))

;; Lore tooltips that can be accessed throughout the entire game - this quest can never be completed; some interactions may alter based on world state conditions.
;; Though maybe we add an achievement for finding and interacting with all of these.
;; Could structure across multiple tasks per region? So when a new region is accessed, it activates a new task full of lore triggers for that region.
(quest:define-task (kandria lore region1)
  :title "Explore the world"
  :condition NIL
  :on-activate T
  ;; add lore triggers to on-activate - just sprinkle for now, until final level design (activate now, so player can explore freely initially, if they want - or encounter them later)
  ;; occasional branching within, based on world state

  ;; TODO: add more around entire region 1 as the level design and tilesets gets refined
  ;; Storage interior - shelves
  (:interaction storage-shelves
   :interactable lore-storage
   :repeatable T
   "
~ player
| //It's their storage shed. Their supplies are low, and it smells like mating rats.//
")

  ;; Large stone gate
  (:interaction stone-gate-large
   :interactable lore-gate-rock
   :repeatable T
   "
~ player
| (:thinking)//Did this fall here, or did they move it into place?//
")

  ;; Housing exterior - first floor left shattered room
  (:interaction housing-apartment
   :interactable lore-apartment-remains
   :repeatable T
   "
~ player
| //Glass cracks under my feet like broken bones. There are human remains inside.//
")

  ;; Housing exterior - roof top-right
  (:interaction housing-roof
   :interactable lore-apartment-roof
   :repeatable T
   "
~ player
| //The wind is howling like a dog on fire.//
")

  ;; Housing exterior - staircase
  (:interaction housing-stairs
   :interactable lore-apartment-stairs
   :repeatable T
   "
~ player
| //This was the stairwell. The building used to be much taller.//
")

  ;; Housing interior - kitchen
  ;; REMARK: I think they would have some power to cook. Maybe also instead make a remark about it
  ;;         smelling like one of the crops they're planting -- beets or potatoes perhaps?
  ;;         Would help make the camp feel more like home.
  ;; TIM REPLY: Agreed on power, I'm assuming they use oil for a lot of things. Oil-powered generators too for some electricity too, like the water pumps, walkie-talkies, and phones
  ;;            Will add about the smell good shout +1
  (:interaction housing-kitchen
   :interactable lore-kitchen
   :repeatable T
   "
~ player
| //There's no gas or electrical supply. It smells like a wrecked oil tanker.//
| (:thinking)//Though I am detecting starchy potato notes, and is that... beetroot?//
")

  ;; Housing interior - sign
  (:interaction housing-cafe
   :interactable lore-cafe
   :repeatable T
   "
~ player
| (:thinking)//Café Alpha... Did I used to come here?//
| (:giggle)//If so I'm sure the service was much better.//
")

  ;; Ruins - transition/view
  (:interaction ruins-view
   :interactable lore-city-view
   :repeatable T
   "
~ player
| //The city was pulverised. What happened?//
")

  ;; Engineering interior - shelves
  ;; branch if already spoken to Jack
  (:interaction engineering-shelves
   :interactable lore-engineering
   :repeatable T
   "
~ player
? (complete-p 'q0-settlement-emergency)
| | //Engineering. This is where Jack and Catherine work. The technology is crude - what do they build here, tin openers?//
|?
| | //Engineering. This is where Catherine works. The technology is crude - what do they build here, tin openers?//
")

  ;; Engineering interior - desk
  ;; REMARK: Maybe soften to: "[..] He's glaring at me quite intently."
  ;; TIM REPLY: Added a variant of this, with one of the Stranger's striking metaphors
  (:interaction engineering-bench
   :interactable lore-eng-bench
   :repeatable T
   "
~ player
? (complete-p 'q0-settlement-emergency)
| | //Jack's workbench. I can smell body odour - does he work here, or work out?//
|?
| | //It's a workbench. Perhaps it belongs to this man - who come to think of it has a stare that could fry circuit boards.//
")

  ;; Farm - transition/view
  ;; REMARK: Change to "[..] - not well though by the looks of it."
  ;; TIM REPLY: I think this alt is weaker - the dying expression seems to capture the Stranger's wry wit?
  (:interaction farm-view
   :interactable lore-farm
   :repeatable T
   "
~ player
? (complete-p 'q1-water)
| | //The irrigation is working again, but the crops might be too far gone to make it.//
|?
| | //This is farmland. They're growing potatoes - dying ones by the looks of it.//
")

  ;; Sandstorm transition/view
  (:interaction sandstorm-view
   :interactable lore-storm
   :repeatable T
   "
~ player
| //Particulates ping off my body like bullets.//
| //The mountains lay beyond, though I can hardly see them in this storm.//
"))
