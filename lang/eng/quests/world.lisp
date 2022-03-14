;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria world)
  :author "Tim White"
  :title "The World"
  :description "This world is unfamiliar to me. I should explore and learn more about it."
  :visible NIL
  :on-activate (task-world-all))

;; Lore tooltips that can be accessed throughout the entire game - this quest can never be completed; some interactions may alter based on world state conditions.
;; Though maybe we add an achievement for finding and interacting with all of these.
;; Could structure across multiple tasks per region? So when a new region is accessed, it activates a new task full of lore triggers for that region.
(quest:define-task (kandria world task-world-all)
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
| \"//It's their storage shed. Supplies are low and it smells like mating rats.//\"(light-gray)
")

  ;; Large stone gate
  (:interaction stone-gate-large
   :interactable lore-gate-rock
   :repeatable T
   "
~ player
| (:thinking)\"//Did this fall here, or did they move it into place?//\"(light-gray)
")

  ;; Housing exterior - first floor left shattered room
  (:interaction housing-apartment
   :interactable lore-apartment-remains
   :repeatable T
   "
~ player
| \"//Glass cracks under my feet like broken bones. There are human remains in the bed.//\"(light-gray)
")
  
  (:interaction storm-east-view
   :interactable lore-storm-east
   :repeatable T
   "
~ player
| \"//The wind is howling like a dog on fire.//\"(light-gray)
")

  ;; Housing exterior - staircase
  (:interaction housing-stairs
   :interactable lore-apartment-stairs
   :repeatable T
   "
~ player
| \"//This was the stairwell. The building used to be much taller.//\"(light-gray)
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
| \"//There's no gas or electrical supply. It smells like a wrecked oil tanker.//\"(light-gray)
| (:thinking)\"//Though I am detecting starchy potato notes, and is that... beetroot?//\"(light-gray)
")

  ;; Housing interior - sign
  (:interaction housing-cafe
   :interactable lore-cafe
   :repeatable T
   "
~ player
| (:thinking)\"//Café Alpha... Did I used to come here?//\"(light-gray)
| (:giggle)\"//If so I'm sure the service was much better.//\"(light-gray)
")

  ;; Housing apartment - bed
  (:interaction housing-bed
   :interactable lore-apt-bed
   :repeatable T
   "
~ player
| (:giggle)\"//This bed was recently made up - I doubt it was room service.//\"(light-gray)
| (:normal)\"//I don't sleep, but it looks incredibly inviting.//\"(light-gray)
")

  ;; Ruins - transition/view
  (:interaction ruins-view
   :interactable lore-city-view
   :repeatable T
   "
~ player
| \"//The city was pulverised. What happened?//\"(light-gray)
")

  ;; Engineering interior - shelves
  ;; branch if already spoken to Jack
  ;; TODO remove demo checks when no longer needed
  (:interaction engineering-shelves
   :interactable lore-engineering
   :repeatable T
   "
~ player
? (or (complete-p 'q0-settlement-arrive) (active-p 'demo-start) (complete-p 'demo-start))
| | \"//Engineering. This is where Jack and Catherine work.//\"(light-gray)
|?
| | \"//It's some sort of workshop. The technology is crude - what do they build here, tin openers?//\"(light-gray)
")

  ;; Engineering interior - desk
  ;; REMARK: Maybe soften to: "[..] He's glaring at me quite intently."
  ;; TIM REPLY: Added a variant of this, with one of the Stranger's striking metaphors
  ;; TODO remove demo checks when no longer needed
  (:interaction engineering-bench
   :interactable lore-eng-bench
   :repeatable T
   "
~ player
? (or (complete-p 'q0-settlement-arrive) (active-p 'demo-start) (complete-p 'demo-start))
| | \"//Jack's workbench. I can smell body odour - does he work here, or work out?//\"(light-gray)
|?
| | \"//It's a workbench. Perhaps it belongs to this man - who come to think of it has a stare that could fry circuits.//\"(light-gray)
")

  ;; Sandstorm transition/view
  (:interaction sandstorm-view
   :interactable lore-storm
   :repeatable T
   "
~ player
| \"//Particulates ping off my body like bullets.//\"(light-gray)
| \"//The mountains lay beyond, though I can hardly see them in this storm.//\"(light-gray)
")

  (:interaction zenith-hub
   :interactable lore-hub
   :repeatable T
   "
~ player
| \"//Zenith... That was the name of the city, and this was the central station.//\"(light-gray)
| (:thinking)\"//Is it me, or was that insignia strangely prophetic?//\"(light-gray)
")

  (:interaction east-apartments
   :interactable lore-east-apartment
   :repeatable T
   "
~ player
| \"These were Rootless hospital apartments. Did people die in their sickbeds?\"(light-gray, italic)
")

  (:interaction market
   :interactable lore-market
   :repeatable T
   "
~ player
| \"//The Midwest Market. You could imagine those mannequins behind the glass were real people.//\"(light-gray)
| (:embarassed)\"//Like this place wasn't creepy enough.//\"(light-gray)
")

  (:interaction west-apartments
   :interactable lore-west-apartment
   :repeatable T
   "
~ player
| \"//Dreamscape West Side - once the height of luxury, now hell in the earth.//\"(light-gray)
")

  (:interaction water-cave
   :interactable lore-water-cave
   :repeatable T
   "
~ player
| (:skeptical)\"//This sunken room must be part of their reservoir, which the pump draws water from.//\"(light-gray)
")
;; was: They've had many leaks, if this sunken room is anything to go by.

  (:interaction mush-cave-1
   :interactable lore-mush-cave-1
   :repeatable T
   "
~ player
| (:skeptical)\"//How on earth did these mushrooms grow so large?//\"(light-gray)
? (or (active-p 'sq2-mushrooms) (complete-p 'sq2-mushrooms))
| | (:normal)\"//Presumably these are inedible - otherwise their hunger problems would be over.//\"(light-gray)
")

  (:interaction mush-cave-1a
   :interactable lore-mush-cave-1a
   :repeatable T
   "
~ player
| \"//I suppose truffles would be too much to ask for.//\"(light-gray)
")

  (:interaction mush-cave-2
   :interactable lore-mush-cave-2
   :repeatable T
   "
~ player
| \"//It's like walking on jello.//\"(light-gray)
")

  ;; This should be Brother (surveillance) offices? hint at an authoritarian former world? makes the joke work better? Leads into Semi Sisters next faction?
  ;; North Star is a more original name for surveillance than Brother? And the link to Semi Sisters cool name is not required to keep it. Yes. Well, can have both listed as companies here.
  ;; Did not literally manufacture satellites here - it's not a factory, but offices.
  (:interaction offices
   :interactable lore-office
   :repeatable T
   "
~ player
| (:thinking)\"//Brother and North Star offices. They manufactured guidance, satellite and surveillance systems.//\"(light-gray)
| (:normal)\"//Bet they never saw this coming.//\"(light-gray)
")

  (:interaction factory
   :interactable lore-factory
   :repeatable T
   "
~ player
| \"//Semi were the manufacturers of electronic components - not least for androids.//\"(light-gray)
| \"//It's sad to see the factory so silent.//\"(light-gray)
")
;; TODO android emote - sad

  (:interaction skyscraper
   :interactable lore-skyscraper
   :repeatable T
   "
~ player
| \"//That is quite the view.//\"(light-gray)
| \"//The desert is bordered by mountains on all sides.//\"(light-gray)
| \"//Judging by the cloud formations there's an ocean beyond the range to the east.//\"(light-gray)
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
| | \"//The irrigation is working again. The crops might be too far gone to make it though.//\"(light-gray)
|?
| | \"//These are potatoes - dying ones by the looks of it.//\"(light-gray)
")

  (:interaction grave
   :interactable lore-grave
   :repeatable T
   "
~ player
| (:thinking)\"//This is where it ended. And now begins.//\"(light-gray)
| (:giggle)\"//Not the most comfortable place to have spent a few decades. Little wonder I've a bad back.//\"(light-gray)
")

  (:interaction grave-cliff
   :interactable lore-grave-cliff
   :repeatable T
   "
~ player
| \"//The old gasworks exploded. Was I something to do with that?//\"(light-gray)
? (complete-p 'q0-settlement-arrive)
| | \"//It's a pity: the gas holders could have been repurposed as grain silos.//\"(light-gray)
")
;; perhaps the old gasworks was being converted into something more modern, when an accident happened, perhaps involving the android. Like this explosion in Sheffield when an old gasworks was being converted in the 1970s: https://www.bbc.co.uk/news/uk-england-south-yorkshire-45097740

;; TODO Semi Engineers nametag completion doesn't update live on next chat line, though does in next convo selected. Worth fixing?
  (:interaction trapped-engineers
   :interactable semi-engineer-chief
   :repeatable T
   :title "(Talk to engineers)"
  "
? (active-p (unit 'blocker-engineers))
| ? (not (var 'engineers-first-talk))
| | ~ semi-engineer-chief
| | | (:weary)How in God's name did you get in here?
| | ~ player
| | | There's a tunnel above this shaft - though it's not something a human could navigate.
| | ~ semi-engineer-chief
| | | ... A //human//? So you're...
| | ~ player
| | - Not human, yes.
| |   ~ semi-engineer-chief
| |   | (:shocked)... An android, as I live and breathe.
| | - An android.
| |   ~ semi-engineer-chief
| |   | (:shocked)... As I live and breathe.
| | - What are you doing in here?
| | ~ semi-engineer-chief
| | | (:weary)We're glad you showed up. We're engineers from the Semi Sisters.
| | ! eval (setf (nametag (unit 'semi-engineer-chief)) (@ semi-engineer-nametag))
| | | The tunnel collapsed; we lost the chief and half the company.
| | | We \"can't break through\"(orange) - can you? Can androids do that?
| | | \"The collapse is just ahead.\"(orange)
| | ! eval (setf (var 'engineers-first-talk) T)
| |?
| | ~ semi-engineer-chief
| | | (:weary)How'd it go with the \"collapsed wall\"(orange)? We can't stay here forever.
|?
| ? (not (var 'engineers-first-talk))
| | ~ semi-engineer-chief
| | | (:weary)Who are you? How did you break through the collapsed tunnel?
| | ~ player
| | - I'm... not human.
| |   ~ semi-engineer-chief
| |   | (:shocked)... An android, as I live and breathe.
| | - I'm an android.
| |   ~ semi-engineer-chief
| |   | (:shocked)... As I live and breathe.
| | - What are you doing in here?
| | ~ semi-engineer-chief
| | | (:weary)We're glad you showed up. We're engineers from the Semi Sisters.
| | ! eval (setf (nametag (unit 'semi-engineer-chief)) (@ semi-engineer-nametag))
| | | We lost the chief and half the company when the tunnel collapsed.
| | | (:weary)We'll send someone for help now the route is open. Our sisters will be here soon to tend to us.
| | | Thank you.
| | ! eval (setf (var 'engineers-first-talk) T)
| |?
| | ~ semi-engineer-chief
| | | I don't believe you got through... Now food and medical supplies can get through too. Thank you.
| | | We can resume our excavations. It'll be slow-going, but we'll get it done.
? (active-p (find-task 'q5a-rescue-engineers 'task-engineers))
| ! eval (complete (find-task 'q5a-rescue-engineers 'task-engineers))
|? (active-p (find-task 'q5a-rescue-engineers 'task-reminder))
| ! eval (complete (find-task 'q5a-rescue-engineers 'task-reminder))
? (active-p (find-task 'demo-engineers 'task-engineers))
| ! eval (complete (find-task 'demo-engineers 'task-engineers))
|? (active-p (find-task 'demo-engineers 'task-reminder))
| ! eval (complete (find-task 'demo-engineers 'task-reminder))
"))

;; TODO remove demo task checks at the end here, when no longer needed

;; TODO region 3 lore entries: about the geothermal generators and the old company that ran them; about the Wraw massing supplies and building mechs and power suits, hinting at invasion (quest covers this explicitly), further deets to support the Cerebat takeover perhaps (though inflected based on whether that has happened yet or not). In the early game, the Wraw area could be sparse in NPCs and lore interacts are vague. And ofc player will never be able to access compounds at any time to learn too much about them.

;; TODO flesh these out. Currently only done for the KS demo quests, with no (T) complete fallback
;; Written to have minor arcs, should the player see them at the start/during, and the end. Generally based on how they regard the android early in the main story.
;; 3-5 alts
(define-default-interactions innis
  (demo-end-prep
   "| [? You might be useful after all. | You should think about joining us - leave those lowlifes you call friends behind. | Maybe you are better off intact than in pieces. | I hope getting the water back was worth it. | There's a war coming, android. Make sure you're on the right side.]")
  (demo-intro
   "| (:sly)[? Dinnae you have Semis' business to attend to? | I ken everything about you, android. So dinnae try anything funny. | I'm still contemplating dismantling you, ya ken. So I wouldnae wait around here too long. | I didnae turn the water off lightly, you understand. But business is business.]")
  (demo-semis
   "| (:angry)[? \"Talk to my sister.\"(orange) | You deaf? I said \"talk to Islay\"(orange).]")
  (demo-start
   "| (:sly)[? Dinnae you have Semis' business to attend to? | I ken everything about you, android. So dinnae try anything funny. | I'm still contemplating dismantling you, ya ken. So I wouldnae wait around here too long. | I didnae turn the water off lightly, you understand. But business is business.]")
  (T
  "| What do you want?"))
;; dinnae = don't (Scottish)
;; wouldnae = wouldn't (Scottish)
;; didnae = didn't (Scottish)
;; ken = know (Scottish)
   
(define-default-interactions islay
  (demo-end-prep
   "| (:happy)[? I knew you'd come through for us. | If only people were as reliable as androids. | I'd love to hear your story - where you've been all these years. | Tell your friends we're sorry about the water. | I'll make sure Innis doesn't turn the water off again.]")
  (demo-start
   "| [? Mind how you go, {#@player-nametag}. | You're a rare specimen indeed. | I never thought I'd see another working android. | You scratch our back, we'll do the rest.]")
  (T
  "| (:nervous)I'm sorry, I'm busy."))

(define-default-interactions jack
  (demo-end-prep
   "| [? The water's back on. Don't tell me that was you? | That was a close one. Don't think I ever been so thirsty. | Maybe you're alright after all. | I'm still keeping an eye on you, mind.]")
  (demo-start
   "| (:annoyed)[? I'm watching you, android. | Don't you have work to do? | Be seein' ya. | I'm thirsty, hurry it up! | What's the matter? You afraid?]")
  (T
  "| What?"))
   
(define-default-interactions fi
  (demo-end-prep
   "| (:happy)[? You did it! But how did you do it? | People rarely return from the Semi Sisters. Yet here you are. | I knew I could trust you. | I'm so glad you're still in one piece. | Now our crops might stand a chance.]")
  (demo-start
   "| [? Please hurry, {#@player-nametag}. | Our survival depends on you. | You are earning my trust. Please, continue to do so. | You could be a hunter, and more besides.]")
  (T
  "| Konnichiwa."))
   
(define-default-interactions catherine
  (demo-end-prep
   "| (:excited)[? I never doubted you! | You're my hero, {#@player-nametag}! | I'm gonna take a bath! Well, once everyone's had their fill. | I won't take water for granted __EVER__ again.]")
  (demo-start
   "| (:concerned)[? The water's never been off this long. | I believe in you, {#@player-nametag}. | It's just another adventure, right? | Is this the end?]")
  (T
  "| You okay?"))