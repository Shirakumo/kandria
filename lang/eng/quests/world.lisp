;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria world)
  :author "Tim White"
  :title ""
  :visible NIL
  :on-activate (task-world-all))

;; Lore interacts that can be accessed throughout the entire game at ANY time if the player explores far enough.
;; Some are conditional to determine which line is shown; however, most are written in a way that works no matter what point in the story the player discovers them.
;; They are written as the thoughts or inner monologue of the player character.
(quest:define-task (kandria world task-world-all)
  :title ""
  :condition NIL
  :on-activate T

    ;; Storage interior - shelves
  (:interaction storage-shelves
   :interactable lore-storage
   :repeatable T
   "
~ player
| \"Their storage shed. Supplies are low and it smells like mating rats.\"(light-gray, italic)
")

;; a half-ruined train from the old-world
(:interaction noka-train
   :interactable lore-noka-train
   :repeatable T
   "
~ player
| \"It's a train. Well, half a train.\"(light-gray, italic)
| \"I wonder if people tried to use these stations to escape under ground.\"(light-gray, italic)
")

  ;; Large stone rock/gate
  (:interaction stone-gate-large
   :interactable lore-gate-rock
   :repeatable T
   "
~ player
| (:thinking)\"Did this fall here, or did they move it into place?\"(light-gray, italic)
")

  ;; Trashed apartment from the old world, with a broken window
  (:interaction housing-apartment
   :interactable lore-apartment-remains
   :repeatable T
   "
~ player
| \"Glass cracks under my feet like broken bones. There are human remains in the bed.\"(light-gray, italic)
")
  
  ;; a sandstorm blocks the player from crossing further into the desert to the east
  (:interaction storm-east-view
   :interactable lore-storm-east
   :repeatable T
   "
~ player
| \"The wind is howling like a dog on fire.\"(light-gray, italic)
")

  ;; the remains of an apartment stairwell, with the rest of the skyscraper missing ("used to be much taller" - sarcastic joke)
  (:interaction housing-stairs
   :interactable lore-apartment-stairs
   :repeatable T
   "
~ player
| \"This was the stairwell. The building used to be much taller.\"(light-gray, italic)
")

  ;; a dirty kitchen the survivors use to cook
  (:interaction housing-kitchen
   :interactable lore-kitchen
   :repeatable T
   "
~ player
| \"There's no gas or electrical supply. It smells like a wrecked oil tanker.\"(light-gray, italic)
| (:thinking)\"Though I am detecting starchy potato notes, and is that... beetroot?\"(light-gray, italic)
")

  ;; a ruined cafe from the old world called Café Alpha according to its sign. Joke about there being no waiters or waitresses any more
  (:interaction housing-cafe
   :interactable lore-cafe
   :repeatable T
   "
~ player
| (:thinking)\"Café Alpha... Did I used to come here?\"(light-gray, italic)
| (:giggle)\"If so I'm sure the service was much better.\"(light-gray, italic)
")

  ;; one of the old apartment rooms looks like it's been slept in recently
  (:interaction housing-bed
   :interactable lore-apt-bed
   :repeatable T
   "
~ player
| (:giggle)\"This bed was recently made up - I doubt it was room service.\"(light-gray, italic)
| (:normal)\"I don't sleep, but it looks incredibly inviting.\"(light-gray, italic)
")

  ;; vista of the ruined city in the background, collapsed skyscrapers, etc.
  (:interaction ruins-view
   :interactable lore-city-view
   :repeatable T
   "
~ player
| \"The city was pulverised. What happened?\"(light-gray, italic)
")

  ;; Engineering workshop
  ;; TODO remove demo checks when no longer needed
  (:interaction engineering-shelves
   :interactable lore-engineering
   :repeatable T
   "
~ player
? (or (complete-p 'q0-settlement-arrive) (active-p 'demo-start) (complete-p 'demo-start))
| | \"Engineering. This is where Jack and Catherine work.\"(light-gray, italic)
|?
| | \"It's some sort of workshop. The technology is crude - what do they build here, tin openers?\"(light-gray, italic)
")

  ;; Jack's workbench in the engineering workshop; "work out" = exercise/gym
  ;; "who come to think of it has a stare that could fry circuits." - this is before the player has met Jack, so we can imagine he's glaring at them
  ;; TODO remove demo checks when no longer needed
  (:interaction engineering-bench
   :interactable lore-eng-bench
   :repeatable T
   "
~ player
? (or (complete-p 'q0-settlement-arrive) (active-p 'demo-start) (complete-p 'demo-start))
| | \"Jack's workbench. I can smell body odour - does he work here, or work out?\"(light-gray, italic)
|?
| | \"It's a workbench. Perhaps it belongs to this man - who come to think of it has a stare that could fry circuits.\"(light-gray, italic)
")

  ;; a sandstorm blocks the player from crossing further into the desert to the west
  (:interaction sandstorm-view
   :interactable lore-storm
   :repeatable T
   "
~ player
| \"Particulates ping off my body like bullets.\"(light-gray, italic)
| \"The mountains lay beyond, though I can hardly see them in this storm.\"(light-gray, italic)
")

  ;; Zenith was the name of the city in the old world. The city's logo is presented front and centre on the wall, a star glowing over a valley, which the player's character notices resembles an explosion levelling a city... Is that what happened?
  ;; central station = railway station
  (:interaction zenith-hub
   :interactable lore-hub
   :repeatable T
   "
~ player
| \"Zenith... That was the name of the city, and this was the central station.\"(light-gray, italic)
| (:thinking)\"Is it me, or was that insignia strangely prophetic?\"(light-gray, italic)
")

   ;; Rootless was the name of a hospital organisation in the old world
  (:interaction east-apartments
   :interactable lore-east-apartment
   :repeatable T
   "
~ player
| \"These were Rootless hospital apartments. Did people die in their sickbeds?\"(light-gray, italic)
")

  ;; a market area; behind dark glass windows stand the shadows of clothing mannequins from the old world
  (:interaction market
   :interactable lore-market
   :repeatable T
   "
~ player
| \"The Midwest Market. You could imagine those mannequins behind the glass were real people.\"(light-gray, italic)
| (:embarassed)\"Like this place wasn't creepy enough.\"(light-gray, italic)
")

  ;; ruined luxury apartments from the old world, now buried in the ground
  (:interaction west-apartments
   :interactable lore-west-apartment
   :repeatable T
   "
~ player
| \"Dreamscape West Side - once the height of luxury, now hell in the earth.\"(light-gray, italic)
")

  ;; a flooded room near the water pump
  (:interaction water-cave
   :interactable lore-water-cave
   :repeatable T
   "
~ player
| (:skeptical)\"This sunken room must be part of their reservoir, which the pump draws water from.\"(light-gray, italic)
")
;; was: They've had many leaks, if this sunken room is anything to go by.

  ;; large mushrooms which the player can climb up and stand on
  (:interaction mush-cave-1
   :interactable lore-mush-cave-1
   :repeatable T
   "
~ player
| (:skeptical)\"How on earth did these mushrooms grow so large?\"(light-gray, italic)
? (or (active-p 'sq2-mushrooms) (complete-p 'sq2-mushrooms))
| | (:normal)\"Presumably these are inedible - otherwise their hunger problems would be over.\"(light-gray, italic)
")

  ;; the sarcastic player character laments there are no truffles, only these huge giant mushrooms everywhere
  (:interaction mush-cave-1a
   :interactable lore-mush-cave-1a
   :repeatable T
   "
~ player
| \"I suppose truffles would be too much to ask for.\"(light-gray, italic)
")

  ;; when the player is stood on top of a giant mushroom
  (:interaction mush-cave-2
   :interactable lore-mush-cave-2
   :repeatable T
   "
~ player
| \"It's like walking on jello.\"(light-gray, italic)
")

  ;; ruined offices of two companies from the old world, Brother and North Star
  ;; a joke about their surveillance not helping them predict the end of the world
  (:interaction offices
   :interactable lore-office
   :repeatable T
   "
~ player
| (:thinking)\"Brother and North Star offices. They manufactured guidance, satellite and surveillance systems.\"(light-gray, italic)
| (:normal)\"Bet they never saw this coming.\"(light-gray, italic)
")

  ;; Semi were a company in the old world, which made androids and parts for androids. It's where the Semi Sisters faction take their name from, as well as an ironic reference to the old-world surveillance company, Brother.
  (:interaction factory
   :interactable lore-factory
   :repeatable T
   "
~ player
| \"Semi were the manufacturers of electronic components - not least for androids.\"(light-gray, italic)
| \"It's sad to see the factory so silent.\"(light-gray, italic)
")
;; TODO android emote - sad

  ;; view from the top of a ruined skyscraper if the player manages to climb up there (the player can't actually see these things due to the camera, but we describe them anyway)
  (:interaction skyscraper
   :interactable lore-skyscraper
   :repeatable T
   "
~ player
| \"That is quite the view.\"(light-gray, italic)
| \"The desert is bordered by mountains on all sides.\"(light-gray, italic)
| \"Judging by the cloud formations there's an ocean beyond the range to the east.\"(light-gray, italic)
")

  ;; the settlement's farmland on the surface; the first line shows if the player has done the quest to restore the water supply; otherwise the other one shows
  (:interaction farm-view
   :interactable lore-farm
   :repeatable T
   "
~ player
? (complete-p 'q1-water)
| | \"The irrigation is working again. The crops might be too far gone to make it though.\"(light-gray, italic)
|?
| | \"These are potatoes - dying ones by the looks of it.\"(light-gray, italic)
")

  ;; the area of rubble where the player character is first awakened; they're reflecting on what happened in their previous life that led to their stranding here (which they can't fully remember, and the player themselves is not privy too). A bit of humour about their bad back due to lying on rocks for thirty years.
  (:interaction grave
   :interactable lore-grave
   :repeatable T
   "
~ player
| (:thinking)\"This is where it ended. And now begins.\"(light-gray, italic)
| (:giggle)\"Not the most comfortable place to have spent a few decades. Little wonder I've a bad back.\"(light-gray, italic)
")

   ;; above the rubble area where the player character is first awakened, there's a huge, collapsed gasworks building visible
   ;; perhaps the old gasworks was being converted into something more modern, when an accident happened, perhaps involving the android. Like this explosion in Sheffield when an old gasworks was being converted in the 1970s: https://www.bbc.co.uk/news/uk-england-south-yorkshire-45097740
  (:interaction grave-cliff
   :interactable lore-grave-cliff
   :repeatable T
   "
~ player
| \"The old gasworks exploded. Was I something to do with that?\"(light-gray, italic)
? (complete-p 'q0-settlement-arrive)
| | \"It's a pity: the gas holders could have been repurposed as grain silos.\"(light-gray, italic)
")

;; the character reflects while navigating deep and complex tunnels through the ground
(:interaction semi-cave-east-1
   :interactable lore-semi-cave-east
   :repeatable T
   "
~ player
| \"Was the old world ruled by people or rabbits? These warrens go on forever.\"(light-gray, italic)
")

;; the player can use the lanterns to recharge their jump/boost
(:interaction semi-cave-east-2
   :interactable lore-semi-lights
   :repeatable T
   "
~ player
| \"It's lucky they lit these tunnels with lanterns - the charge is more than sufficient to recharge my boost.\"(light-gray, italic)
")

;; another old Semi factory space
(:interaction semi-cave-east-3
   :interactable lore-semi-product-line
   :repeatable T
   "
~ player
| \"I think they assembled androids on this production line.\"(light-gray, italic)
")

;; a scenic picture on the wall from pre-calamity times - now it seems as ancient as a cave painting once did
(:interaction semi-cave-east-4
   :interactable lore-semi-pic
   :repeatable T
   "
~ player
| \"I suppose this is the equivalent of a cave painting these days.\"(light-gray, italic)
")

;; the player character reflects on their artificial method of swimming
(:interaction semi-cave-east-5
   :interactable lore-semi-swim
   :repeatable T
   "
~ player
| \"It's a good job I can swim.\"(light-gray, italic)
| (:giggle)\"And by swim I mean activate my aquatic water jets.\"(light-gray, italic)
")

;; examining one of the old-world trains refitted by the Semi Sisters
(:interaction semi-train
   :interactable lore-semi-train
   :repeatable T
   "
~ player
| \"This is a maglev bullet train. With rail trucks welded onto its chassis.\"(light-gray, italic)
")

;; while examining the Semi Sisters' storage area
(:interaction semi-hub-1
   :interactable lore-semi-hub-supplies
   :repeatable T
   "
~ player
| \"Do they trade in contraband? Well, I suppose nothing's illegal any more.\"(light-gray, italic)
")

;; a bar in the Semi Sisters hub area
(:interaction semi-hub-2
   :interactable lore-semi-bar
   :repeatable T
   "
~ player
| \"I guess people need a watering hole wherever they go.\"(light-gray, italic)
| \"This one's as loud with chatter and clinking glass as anywhere I remember.\"(light-gray, italic)
")

;; another scenic picture on the wall from pre-calamity times
;; the player character doubts it either because things are too far gone, or because even if society recovers, they'll hopefully do things differently
(:interaction semi-hub-3
   :interactable lore-semi-pic-2
   :repeatable T
   "
~ player
| \"Maybe the world will look like this picture again one day. But I doubt it.\"(light-gray, italic)
")

;; the Semi Sisters' council chamber / control room, where Innis and Islay, the leaders, mostly hang out. It's quite deluxe and well-furnished compared to the makeshift areas of the rest of their base
(:interaction semi-hub-4
   :interactable lore-semi-control
   :repeatable T
   "
~ player
| \"The din of the base fades away up here.\"(light-gray, italic)
| \"It's as relaxing a place as I've found since I woke up.\"(light-gray, italic)
")

;; exploring a ruined underground "subscraper" - a skyscraper that goes down into the ground, rather than up into the sky (they built buildings like this before the calamity)
(:interaction semi-hub-5
   :interactable lore-semi-broken-building
   :repeatable T
   "
~ player
| \"How this subscraper hasn't completely collapsed is beyond me.\"(light-gray, italic)
")

;; makeshift areas of the Semi Sisters' base, where people have strung up modesty curtains on rails to give themselves privacy amongst the old factories and machinery where they now live
(:interaction semi-hub-6
   :interactable lore-semi-curtain
   :repeatable T
   "
~ player
| \"Machinery and modesty curtains - not what I expected. I suppose they have to make do with what they've got.\"(light-gray, italic)
")

;; a hydroponic "garden" in the Semi Sisters' base. Compared to the Noka faction on the surface, they're doing very well here at growing food and they have plenty of water
(:interaction semi-hub-7
   :interactable lore-semi-plants
   :repeatable T
   "
~ player
| \"It's a hydroponic paradise. I don't think these people are wanting in the food and water department.\"(light-gray, italic)
")

;; a mostly empty vending machine from the old world.
;; Candy Android = a candy bar from the old world. Suggests maybe it was a PR thing to make people more amenable to androids, by making chocolate bars that resemble them.
(:interaction semi-hub-8
   :interactable lore-semi-vending
   :repeatable T
   "
~ player
| \"Any food left in here will be spoiled. Including those Candy Androids, looking at me mournfully through the broken glass.\"(light-gray, italic)
")

;; an old office building is now a sleeping area in the Semi Sisters' base.
;; sly joke reference to crunch culture and sleeping under your desk.
(:interaction semi-hub-9
   :interactable lore-semi-bedroom
   :repeatable T
   "
~ player
| \"An office turned bedroom.\"(light-gray, italic) (:giggle)\"Brings new meaning to sleeping under your desk.\"(light-gray, italic)
")

;; a calendar still on the wall in an old office block; March 2368 is when the calamity happened. There are faces on the calendar too.
(:interaction semi-hub-10
   :interactable lore-semi-calendar
   :repeatable T
   "
~ player
| \"A calendar from 2368, still showing March. Some of those appointments never happened.\"(light-gray, italic)
| \"Is that a picture of the people who worked here?\"(light-gray, italic)
")

;; a fluorescent sign in the caves near the Semi Sisters base, directing people towards it. Like most lights, especially one in a musty cave, it's attracted flies to their doom.
;; The character reflects that they also feel like a dead fly in an endless warren of tubes/tunnels.
;; The player may or may not have encountered the Semi Sisters when they find this.
(:interaction semi-cave-west-1
   :interactable lore-semi-sign
   :repeatable T
   "
~ player
| \"Well that's fluorescent. The tubes are full of dead flies. I know the feeling.\"(light-gray, italic)
")

;; spike traps and barbed wire litter areas around the Semi Sisters base - lethal to an android, as they reflect on police states from before the calamity.
;; Maybe the Semi Sisters planted them for defence, even though it makes it harder for their own people to get around. Or maybe it's a legacy from when the militaristic Wraw faction inhabited this area?
(:interaction semi-cave-west-2
   :interactable lore-semi-spikes
   :repeatable T
   "
~ player
| \"Who put all these spikes here? It's like a police state.\"(light-gray, italic)
")

;; these are the rail engineers from the Semi Sisters, who are digging out more of the old metro tunnels and expanding the rail network, but who got cut off when the tunnel collapsed.
;; The player may encounter them before the quest from the Semis to actually rescue them.
(:interaction semi-cave-west-3
   :interactable lore-semi-eng-post
   :repeatable T
   "
~ player
| \"It's a temporary engineers' camp. They've got food enough to be self-sufficient, at least for a while.\"(light-gray, italic)
")


;; conversation with a Semi Sisters rail engineer, if you encounter them independently of the quest to rescue them.
;; This is dialogue with the player, not inner monologue.
;; Conditionals determine what they say based on first of all whether you've cleared the tunnel yet that's blocking them in, and second whether you've spoken to them before.
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
| | | (:weary)We're glad you showed up. We're rail engineers from the Semi Sisters.
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
| | | (:weary)We're glad you showed up. We're rail engineers from the Semi Sisters.
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

;; NPC FALLBACK DIALOGUE

;; TODO flesh these out. Currently only done for the KS demo quests, with only temporary (T) complete fallback dialogue
;; Written to have minor arcs, should the player talk to them at the start/during, and the end of the demo quests. Generally based on how they regard the android early in the main story.
;; 3-5 alts each

;; Innis (Semi Sisters leader, female) - generally doesn't like the player; Scottish dialect
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
   
;; Islay (Semi Sisters second in command and chief engineer, Innis' sister) - is warmer to the player; Scottish accent, but less dialect
(define-default-interactions islay
  (demo-end-prep
   "| (:happy)[? I knew you'd come through for us. | If only people were as reliable as androids. | I'd love to hear your story - where you've been all these years. | Tell your friends we're sorry about the water. | I'll make sure Innis doesn't turn the water off again.]")
  (demo-start
   "| [? Mind how you go, {#@player-nametag}. | You're a rare specimen indeed. | I never thought I'd see another working android. | You scratch our back, we'll do the rest.]")
  (T
  "| (:nervous)I'm sorry, I'm busy."))

;; Jack (Noka faction chief engineer, male) - doesn't like the player, or androids in general; Southern USA accent and dialect
(define-default-interactions jack
  (demo-end-prep
   "| [? The water's back on. Don't tell me that was you? | That was a close one. Don't think I ever been so thirsty. | Maybe you're alright after all. | I'm still keeping an eye on you, mind.]")
  (demo-start
   "| (:annoyed)[? I'm watching you, android. | Don't you have work to do? | Be seein' ya. | I'm thirsty, hurry it up! | What's the matter? You afraid?]")
  (T
  "| What?"))

;; Fi (Noka faction leader, female) - somewhat indifferent and distanced to the player; formal, but warming to them. Japanese English accent and dialect.
(define-default-interactions fi
  (demo-end-prep
   "| (:happy)[? You did it! But how did you do it? | People rarely return from the Semi Sisters. Yet here you are. | I knew I could trust you. | I'm so glad you're still in one piece. | Now our crops might stand a chance.]")
  (demo-start
   "| [? Please hurry, {#@player-nametag}. | Our survival depends on you. | You are earning my trust. Please, continue to do so. | You could be a hunter, and more besides.]")
  (T
  "| Konnichiwa."))
   
;; Catherine (Noka junior engineer, female) - thinks the player character as an android is amazing, though treats them a little too much like a machine to begin with, before becoming great friends with them. Midwest/generic USA accent and dialect.
(define-default-interactions catherine
  (demo-end-prep
   "| (:excited)[? I never doubted you! | You're my hero, {#@player-nametag}! | I'm gonna take a bath! Well, once everyone's had their fill. | I won't take water for granted __EVER__ again.]")
  (demo-start
   "| (:concerned)[? The water's never been off this long. | I believe in you, {#@player-nametag}. | It's just another adventure, right? | Is this the end?]")
  (T
  "| You okay?"))