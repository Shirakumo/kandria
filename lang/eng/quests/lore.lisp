;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria lore)
  :author "Tim White"
  :title "The World"
  :description "This world is unfamiliar to me. I should explore and learn more about it."
  :visible NIL
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
| //It's their storage shed. Their supplies are low and it smells like mating rats.//
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
| //Glass cracks under my feet like broken bones. There are human remains in the bed.//
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

  ;; Housing apartment - bed
  (:interaction housing-bed
   :interactable lore-apt-bed
   :repeatable T
   "
~ player
| (:giggle)//This bed was recently made up - I doubt it was room service.//
| (:normal)//I don't sleep, but it looks incredibly inviting.//
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
? (complete-p 'q0-settlement-arrive)
| | //Engineering. This is where Jack and Catherine work.//
|?
| | //It's some sort of workshop. The technology is crude - what do they build here, tin openers?//
")

  ;; Engineering interior - desk
  ;; REMARK: Maybe soften to: "[..] He's glaring at me quite intently."
  ;; TIM REPLY: Added a variant of this, with one of the Stranger's striking metaphors
  (:interaction engineering-bench
   :interactable lore-eng-bench
   :repeatable T
   "
~ player
? (complete-p 'q0-settlement-arrive)
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
| | //The irrigation is working again. The crops might be too far gone to make it though.//
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
")

  (:interaction zenith-hub
   :interactable lore-hub
   :repeatable T
   "
~ player
| //Zenith... That was the name of the city, and this was the train station.//
| (:thinking)//Is it me, or was that insignia strangely prophetic?//
")

  (:interaction east-apartments
   :interactable lore-east-apartment
   :repeatable T
   "
~ player
| //These were Rootless hospital apartments.//
")

  (:interaction market
   :interactable lore-market
   :repeatable T
   "
~ player
| //The Midwest Market. You could almost imagine those mannequins behind the glass were real people.//
| (:embarassed)//Like this place wasn't creepy enough.//
")

  (:interaction west-apartments
   :interactable lore-west-apartment
   :repeatable T
   "
~ player
| //Dreamscape West Side - once the height of luxury, now hell in the earth.//
")

#|
  (:interaction pump-room
   :interactable lore-substation
   :repeatable T
   "
~ player
? (complete-p 'q1-water)
| | //The central substation, now repurposed as a pump room.//
|?
| | //The central substation, now seemingly repurposed as a pump room.//
  
| (:thinking)//How is the power generated? Hydroelectricity, perhaps.//
")
|#

  (:interaction water-cave
   :interactable lore-water-cave
   :repeatable T
   "
~ player
| (:skeptical)//They've had many leaks, if this sunken room is anything to go by.//
")

  (:interaction mush-cave-1
   :interactable lore-mush-cave-1
   :repeatable T
   "
~ player
| (:skeptical)//How on earth did these mushrooms grow so large?//
? (or (active-p 'sq2-mushrooms) (complete-p 'sq2-mushrooms))
| | (:normal)//Presumably these kind are inedible - otherwise their hunger problems would be over.//
")

  (:interaction mush-cave-1a
   :interactable lore-mush-cave-1a
   :repeatable T
   "
~ player
| //I suppose truffles would be too much to ask for.//
")

  (:interaction mush-cave-2
   :interactable lore-mush-cave-2
   :repeatable T
   "
~ player
| //It's like walking on jello.//
")

  ;; This should be Brother (surveillance) offices? hint at an authoritarian former world? makes the joke work better? Leads into Semi Sisters next faction?
  ;; North Star is a more original name for surveillance than Brother? And the link to Semi Sisters cool name is not required to keep it. Yes.
  ;; Did not literally manufacture satellites here - it's not a factory, but offices.
  (:interaction offices
   :interactable lore-office
   :repeatable T
   "
~ player
| (:thinking)//North Star offices. They manufactured guidance, satellite and surveillance systems.//
| (:normal)//Bet they never saw this coming.//
")

  (:interaction factory
   :interactable lore-factory
   :repeatable T
   "
~ player
| //Semi were the manufacturers of electronic components - not least for androids.//
| //It's sad to see the factory so silent.//
")
;; TODO android emote - sad

  (:interaction skyscraper
   :interactable lore-skyscraper
   :repeatable T
   "
~ player
| //That is quite the view.//
| //The desert is bordered by mountains on all sides.//
| //Judging by the cloud formations, I'd wager there's an ocean beyond the range to the east.//
")

  (:interaction grave
   :interactable lore-grave
   :repeatable T
   "
~ player
| //(:thinking)This is where it all began, and ended.//
| //(:normal)Not the most comfortable location to have spent a couple of decades. (:giggle)Little wonder I've a bad back.//
")

)

#|
;; TODO Old mushroom text interacts that could be repurposed as lore interacts:
could reuse locations shrooms1 to 5?

rusty puffball
(:giggle)They make clothes out of these? Call me a fashion victim but I wouldn't be seen dead in them.

Why do they look like alien parasites from an old B-movie?

black knight
(:thinking)They remind me of decaying frogspawn. Yet I've never seen decaying frogspawn...

They look like someone's insides if they were on the outside. That's probably what they'd do to you too.

|#
