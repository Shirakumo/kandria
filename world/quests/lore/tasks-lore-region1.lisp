;; Lore tooltips that can be accessed throughout the entire game - this quest can never be completed; some interactions may alter based on world state conditions.
;; Though maybe we add an achievement for finding and interacting with all of these.
;; Could structure across multiple tasks per region? So when a new region is accessed, it activates a new task full of lore triggers for that region.
(:name lore-explore-region1
 :title "Explore the world"
 :description "I should locate points of interest, to educate myself about this new world."
 :invariant T
 :condition NIL
 :on-activate (storage-shelves stone-gate-large housing-apartment housing-roof housing-stairs housing-kitchen housing-cafe ruins-view engineering-shelves engineering-bench farm-view sandstorm-view)
)

;; add lore triggers to on-activate - just sprinkle for now, until final level design (activate now, so player can explore freely initially, if they want - or encounter them later)
;; occasional branching within, based on world state

;; TODO: add more around entire region 1 as the level design and tilesets gets refined
;; Storage interior - shelves
(quest:interaction :name storage-shelves :interactable entity-5180 :repeatable T :dialogue "
~ player
| //It's their storage shed. Their supplies are low, and it smells like mating rats.//
")

;; Large stone gate
(quest:interaction :name stone-gate-large :interactable entity-5189 :repeatable T :dialogue "
~ player
| //Did this fall here? Or did they move it into place?//
")

;; Housing exterior - first floor left shattered room
(quest:interaction :name housing-apartment :interactable entity-5198 :repeatable T :dialogue "
~ player
| //Glass cracks under my feet like broken bones. There are human remains inside.//
")

;; Housing exterior - roof top-right
(quest:interaction :name housing-roof :interactable entity-5199 :repeatable T :dialogue "
~ player
| //The wind is howling like a dog on fire.//
")

;; Housing exterior - staircase
(quest:interaction :name housing-stairs :interactable entity-5200 :repeatable T :dialogue "
~ player
| //This was the stairwell. The building used to be much taller.//
")

;; Housing interior - kitchen
;; REMARK: I think they would have some power to cook. Maybe also instead make a remark about it
;;         smelling like one of the crops they're planting -- beets or potatoes perhaps?
;;         Would help make the camp feel more like home.
(quest:interaction :name housing-kitchen :interactable entity-5201 :repeatable T :dialogue "
~ player
| //There's no gas or electrical supply. It smells like a wrecked oil tanker.//
")

;; Housing interior - sign
(quest:interaction :name housing-cafe :interactable entity-5210 :repeatable T :dialogue "
~ player
| //Café Alpha... Did I used to come here? I recall the service being much better.//
")

;; Ruins - transition/view
(quest:interaction :name ruins-view :interactable entity-5211 :repeatable T :dialogue "
~ player
| //The city was pulverised. What happened?//
")

;; Engineering interior - shelves
;; branch if already spoken to Jack
(quest:interaction :name engineering-shelves :interactable entity-5212 :repeatable T :dialogue "
~ player
? (complete-p 'q0-settlement-emergency)
| | //Engineering. This is where Jack and Catherine work. The technology is crude - what do they build here, tin openers?//
|?
| | //Engineering. This is where Catherine works. The technology is crude - what do they build here, tin openers?//
")

;; Engineering interior - desk
;; REMARK: Maybe soften to: "[..] He's glaring at me quite intently."
(quest:interaction :name engineering-bench :interactable entity-5213 :repeatable T :dialogue "
~ player
? (complete-p 'q0-settlement-emergency)
| | //Jack's workbench. I can smell body odour - does he work here, or work out?//
|?
| | //It's a workbench. Perhaps it belongs to this man - who come to think of it looks like he wants to kill me.//
")

;; Farm - transition/view
;; REMARK: Change to "[..] - not well though by the looks of it."
(quest:interaction :name farm-view :interactable entity-5214 :repeatable T :dialogue "
~ player
| //This is farmland. They're growing potatoes - dying ones by the looks of it.//
")

;; Sandstorm transition/view
(quest:interaction :name sandstorm-view :interactable entity-5215 :repeatable T :dialogue "
~ player
| //Particulates ping off my body like bullets.//
| //The mountains lay beyond, though I can hardly see them in this storm.//
")
