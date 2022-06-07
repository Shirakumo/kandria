;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria world)
  :author "Tim White"
  :title ""
  :visible NIL
  :on-activate (task-world-all task-world-engineers task-engineers-wall-listen))

;; Lore interacts that can be accessed throughout the entire game at ANY time if the player explores far enough.
;; Some are conditional to determine which line is shown; however, most are written in a way that works no matter what point in the story the player discovers them.
;; They are written as the thoughts or inner monologue of the player character.
(quest:define-task (kandria world task-world-all)
  :title ""
  :condition NIL
  :on-activate T

;; REGION 1 UPPER

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
| \"I wonder if people tried to use this station to escape under ground.\"(light-gray, italic)
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
| (:thinking)\"\"Café Alpha\"(red). Did I used to come here?\"(light-gray, italic)
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
? (or (complete-p 'q0-find-jack) (active-p 'demo-start) (complete-p 'demo-start))
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
? (or (complete-p 'q0-find-jack) (active-p 'demo-start) (complete-p 'demo-start))
| | \"Jack's workbench. I can smell body odour - does he work here, or work out?\"(light-gray, italic)
|?
| | \"It's a workbench. Perhaps it belongs to this man - who come to think of it looks like he wants to kill me.\"(light-gray, italic)
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
| \"\"Zenith\"(red) - that was the name of the city, and this was the central station.\"(light-gray, italic)
| (:thinking)\"Is it me, or was that insignia strangely prophetic?\"(light-gray, italic)
")

   ;; Rootless was the name of a hospital organisation in the old world
  (:interaction east-apartments
   :interactable lore-east-apartment
   :repeatable T
   "
~ player
| \"These were \"Rootless hospital apartments\"(red). Did people die in their sickbeds?\"(light-gray, italic)
")

  ;; a market area; behind dark glass windows stand the shadows of clothing mannequins from the old world
  (:interaction market
   :interactable lore-market
   :repeatable T
   "
~ player
| \"The \"Midwest Market\"(red). You could imagine those mannequins behind the glass were real people.\"(light-gray, italic)
| (:embarassed)\"Like this place wasn't creepy enough.\"(light-gray, italic)
")

  ;; ruined luxury apartments from the old world, now buried in the ground
  (:interaction west-apartments
   :interactable lore-west-apartment
   :repeatable T
   "
~ player
| \"\"Dreamscape West Side\"(red) - once the height of luxury, now hell in the earth.\"(light-gray, italic)
")

  ;; a flooded room near the water pump
  (:interaction water-cave
   :interactable lore-water-cave
   :repeatable T
   "
~ player
| (:thinking)\"This sunken room must be part of their reservoir, from which the pump draws water.\"(light-gray, italic)
")
;; was: They've had many leaks, if this sunken room is anything to go by.

  ;; large mushrooms which the player can climb up and stand on
  (:interaction mush-cave-1
   :interactable lore-mush-cave-1
   :repeatable T
   "
~ player
| (:thinking)\"How on earth did these mushrooms grow so large?\"(light-gray, italic)
? (or (active-p 'sq2-mushrooms) (complete-p 'sq2-mushrooms))
| | (:normal)\"Presumably they are inedible, otherwise their hunger problems would be over.\"(light-gray, italic)
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
| (:thinking)\"\"Brother\"(red) and \"North Star\"(red) offices. They manufactured guidance, satellite and surveillance systems.\"(light-gray, italic)
| (:normal)\"Bet they never saw this coming.\"(light-gray, italic)
")

  ;; Semi were a company in the old world, which made androids and parts for androids. It's where the Semi Sisters faction take their name from, as well as an ironic reference to the old-world surveillance company, Brother.
  (:interaction factory
   :interactable lore-factory
   :repeatable T
   "
~ player
| \"\"Semi\"(red) were the manufacturers of electronic components - not least for androids.\"(light-gray, italic)
| \"It's sad to see the factory so silent.\"(light-gray, italic)
")

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
? (complete-p 'q0-find-jack)
| | \"It's a pity: the gas holders could have been repurposed as grain silos.\"(light-gray, italic)
")

;; REGION 1 LOWER

;; the character reflects while navigating deep and complex tunnels through the ground
  (:interaction semi-cave-east-1
   :interactable lore-semi-cave-east
   :repeatable T
   "
~ player
| \"Were the inhabitants here people or rabbits? These warrens go on forever.\"(light-gray, italic)
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

;; a scenic picture on the wall from pre-Calamity times - now it seems as ancient as a cave painting once did
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
| \"Do they trade in contraband? I suppose nothing's illegal any more.\"(light-gray, italic)
")

;; a bar in the Semi Sisters hub area
  (:interaction semi-hub-2
   :interactable lore-semi-bar
   :repeatable T
   "
~ player
? (not (complete-p (find-task 'q11a-bomb-recipe 'task-move-semis)))
| | \"I guess people need a watering hole wherever they go.\"(light-gray, italic)
| | \"This one's as loud with chatter as anywhere I remember - but instead of clinking glass they're clinking tin cans.\"(light-gray, italic)
|?
| | \"Looks like I missed last orders.\"(light-gray, italic)
")

;; another scenic picture on the wall from pre-Calamity times
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
? (not (complete-p (find-task 'q11a-bomb-recipe 'task-move-semis)))
| | \"The din of the base fades away up here - save for the interruption of fuzzy video feeds and communications chatter.\"(light-gray, italic)
|?
| | \"Dark screens. It's either pitch black in the tunnels, or their CCTV cameras have gone offline.\"(light-gray, italic)
")

;; exploring a ruined underground "subscraper" - a skyscraper that goes down into the ground, rather than up into the sky (they built buildings like this before the Calamity)
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
| \"What food is left in here is spoiled. Including those Candy Androids, looking at me mournfully through the broken glass.\"(light-gray, italic)
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

;; a calendar still on the wall in an old office block; March 2368 is when the Calamity happened. There are faces on the calendar too.
  (:interaction semi-hub-10
   :interactable lore-semi-calendar
   :repeatable T
   "
~ player
| \"A calendar from 2368, still showing March. Some of those appointments never happened.\"(light-gray, italic)
| \"Is that a picture of the people who worked here?\"(light-gray, italic)
")

;; a fluorescent painted sign in the caves near the Semi Sisters base, directing people towards it.
;; The player may or may not have encountered the Semi Sisters when they find this.
  (:interaction semi-cave-west-1
   :interactable lore-semi-sign
   :repeatable T
   "
~ player
| \"Well that's fluorescent.\"(light-gray, italic) (:thinking)\"Wonder how they made the paint.\"(light-gray, italic)
")

;; spike traps and barbed wire litter areas around the Semi Sisters base - lethal to an android, as they reflect on police states from before the Calamity.
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

;; REGION 2

;; abandoned laboratory
  (:interaction cerebat-lab-1
   :interactable lore-cerebat-lab-1
   :repeatable T
   "
~ player
| (:thinking)\"I don't think this laboratory has been used since before the calamity.\"(light-gray, italic)
")

;; abandoned lab, looking at an unusual sample in a glass tube (like something from Aliens)
  (:interaction cerebat-lab-2
   :interactable lore-cerebat-lab-2
   :repeatable T
   "
~ player
| (:embarassed)\"What the hell is that? I think it's organic. And dead.\"(light-gray, italic)
| \"Well it's staying where it is, just in case.\"(light-gray, italic) (:giggle)\"I don't want anything jumping on my face.\"(light-gray, italic)
")

;; in a big lush water cave
;; (works even if they've seen the deeper volcanic Wraw area, since here they're comparing it to the drier less habitable areas above)
  (:interaction cerebat-water-cave
   :interactable lore-cerebat-water-cave
   :repeatable T
   "
~ player
| \"At this depth I was expecting magma not water.\"(light-gray, italic)
")

;; big mushrooms in a big lush water cave
  (:interaction cerebat-mush-cave
   :interactable lore-cerebat-mush-cave
   :repeatable T
   "
~ player
| \"These are different kinds of giant mushrooms. I don't know if they're edible.\"(light-gray, italic)
| (:giggle)\"Though maybe they're drinkable.\"(light-gray, italic)
")

;; bottomless pit which would cause insta-death
  (:interaction cerebat-pit
   :interactable lore-cerebat-pit
   :repeatable T
   "
~ player
| (:embarassed)\"I fall in there and no one's gonna find me.\"(light-gray, italic)
")

;; a painted Cerebats faction sign and direction arrow, though it only says "BATS"
;; play turns it into a joke, since chances are they've seen bats flying around in the caves before.
;; They may or may not have encountered / know about the Cerebats faction at this point
  (:interaction cerebat-bats-1
   :interactable lore-cerebat-bats-1
   :repeatable T
   "
~ player
| (:giggle)\"Yes, there are indeed bats in these parts.\"(light-gray, italic)
")

;; another painted Cerebats faction sign and direction arrow, though it only says "BATS" (and is written in red paint)
;; They may or may not have encountered / know about the Cerebats faction at this point
  (:interaction cerebat-bats-2
   :interactable lore-cerebat-bats-2
   :repeatable T
   "
~ player
| \"I hope that's not written in blood. Or thermal fluid.\"(light-gray, italic)
")

;; a mushroom cave, but also referring to the lush backdrop
  (:interaction cerebat-mush
   :interactable lore-cerebat-mush
   :repeatable T
   "
~ player
| \"It's so humid down here, no wonder it's lush.\"(light-gray, italic)
| (:giggle)\"Thank God I don't sweat, or I'd be watering the plants as well.\"(light-gray, italic)
")

;; the water is pumped from here to the Semis and Noka living areas far above
  (:interaction cerebat-lake
   :interactable lore-cerebat-lake
   :repeatable T
   "
~ player
| (:thinking)\"Water must get pumped up from these lakes to the levels above.\"(light-gray, italic)
")

;; because this is a light area, even though it's deep underground
  (:interaction cerebat-light
   :interactable lore-cerebat-light
   :repeatable T
   "
~ player
| (:thinking)\"Where's all the light coming from? Phosphorescent flora?\"(light-gray, italic)
")

;; wind in the tunnels - difference in temperature with the levels above, and with the air over water and land
  (:interaction cerebat-wind
   :interactable lore-cerebat-wind
   :repeatable T
   "
~ player
| (:thinking)\"The water must be cooling the air and causing the winds.\"(light-gray, italic)
")

;; wind power
;; may have encountered wind farming in the tunnels already in Semi/Cerebat territory (sidequest), or may not have - but can assume the character has observed this in the environment while exploring
;; not "the doldrums" - in wind and light/mood
  (:interaction cerebat-wind-power
   :interactable lore-cerebat-wind-power
   :repeatable T
   "
~ player
| \"This is hardly the doldrums I was expecting.\"(light-gray, italic)
| \"No wonder they use wind for power -\"(light-gray, italic) (:giggle)\"much as my thrusters do the reverse.\"(light-gray, italic)
")

;; bouncing springs like in Sonic
;; Helps (non-android) people/hunters (assuming you know of hunters at this point) to move around
;; Derived from old railway buffers
  (:interaction cerebat-bouncer
   :interactable lore-cerebat-bouncer
   :repeatable T
   "
~ player
| \"Rail buffers repurposed as springboards? An ingenious way to help people navigate these tunnels.\"(light-gray, italic)
")

;; oil slick in a cave
;; may not have had the harsh treatment from Jack (and others yet), but we can assume the character remembers that part of their old life
  (:interaction cerebat-oil
   :interactable lore-cerebat-oil
   :repeatable T
   "
~ player
| \"Oil and water. Like humans and androids.\"(light-gray, italic)
")
;; could have said something about fossils/androids, but you'll see there are fossils in there if you fish in the oil

;; hideouts

;; council chamber
;; living quarters
;; shady backstreets
;; busy market
;; factory



  ;; the caved-in tunnel that trapped the Semi Sisters engineers. A different line plays depending on whether or not the debris has been cleared yet, and whether or not the player knows about the trapped engineers quests yet
  (:interaction engineers-wall
   :interactable lore-engineers-wall
   :repeatable T
   "
~ player
? (active-p (unit 'blocker-engineers))
| ? (or (active-p 'demo-engineers) (active-p 'q5a-rescue-engineers))
| | | \"This might be the \"collapsed tunnel\"(orange) that trapped the Semis engineers.\"(light-gray, italic)
| | | (:thinking)\"I'll need to \"find another way around\"(orange).\"(light-gray, italic)
| |?
| | | \"A collapsed tunnel.\"(light-gray, italic) (:thinking)\"I'll need to \"find another way around\"(orange).\"(light-gray, italic)
|?
| ? (or (active-p 'demo-engineers) (active-p 'q5a-rescue-engineers) (complete-p 'demo-engineers) (complete-p 'q5a-rescue-engineers))
| | | \"The remnants of the collapsed rail tunnel.\"(light-gray, italic) \"It looks stable enough - for now.\"(light-gray, italic)
| |?
| | | \"The remnants of the collapsed tunnel.\"(light-gray, italic) \"It looks stable enough - for now.\"(light-gray, italic)
"))

;; conversation with a Semi Sisters rail engineer, if you encounter them independently of the quest to rescue them.
;; This is dialogue with the player, not inner monologue.
;; Conditionals determine what they say based on first of all whether you've cleared the tunnel yet that's blocking them in, and second whether you've spoken to them before.
;; Task resolves once all the Semis move to the surface during q11a-bomb-recipe
;; TODO Semi Engineers nametag completion doesn't update live on next chat line, though does in next convo selected. Worth fixing?
(quest:define-task (kandria world task-world-engineers)
  :title ""
  :condition NIL
  :on-complete ()
  :on-activate T

  (:interaction trapped-engineers
   :interactable semi-engineer-chief
   :repeatable T
   :title ""
  "
? (active-p (unit 'blocker-engineers))
| ? (not (var 'engineers-first-talk))
| | ~ semi-engineer-chief
| | | How in God's name did you get in here?
| | ~ player
| | | There's a tunnel above this shaft - though it's not something a human could navigate.
| | ~ semi-engineer-chief
| | | ... A //human//? So you're...
| | ~ player
| | - Not human, yes.
| |   ~ semi-engineer-chief
| |   | ... An android, as I live and breathe.
| | - An android.
| |   ~ semi-engineer-chief
| |   | ... As I live and breathe.
| | - What are you doing in here?
| | ~ semi-engineer-chief
| | | We're glad you showed up. We're rail engineers from the Semi Sisters.
| | ! eval (setf (nametag (unit 'semi-engineer-chief)) (@ semi-engineer-nametag))
| | ~ semi-engineer-chief
| | | The tunnel collapsed; we lost the chief and half the company.
| | | We \"can't break through\"(orange) - can you? Can androids do that?
| | | \"The collapse is just ahead.\"(orange)
| | ! eval (setf (var 'engineers-first-talk) T)
| | ! eval (activate 'world-engineers-wall)
| |?
| | ~ semi-engineer-chief
| | | How'd it go with the \"collapsed wall\"(orange)? We can't stay here forever.
|?
| ? (not (var 'engineers-first-talk))
| | ~ semi-engineer-chief
| | | Who are you? How did you break through the collapsed tunnel?
| | ~ player
| | - I'm... not human.
| |   ~ semi-engineer-chief
| |   | ... An android, as I live and breathe.
| | - I'm an android.
| |   ~ semi-engineer-chief
| |   | ... As I live and breathe.
| | - What are you doing in here?
| | ~ semi-engineer-chief
| | | We're glad you showed up. We're rail engineers from the Semi Sisters.
| | ! eval (setf (nametag (unit 'semi-engineer-chief)) (@ semi-engineer-nametag))
| | ~ semi-engineer-chief
| | | We lost the chief and half the company when the tunnel collapsed.
| | | But things are looking up now the route is open.
| | | Thank you.
| | ! eval (setf (var 'engineers-first-talk) T)
| |?
| | ~ semi-engineer-chief
| | | I can't believe you got through... Now food and medical supplies can get through too. Thank you.
| | | We can resume our excavations. It'll be slow-going, but we'll get it done.
"))

;; listen in case the player clears the wall before talking to the engineers in the world - and if so, complete the quest to get XP
(quest:define-task (kandria world task-engineers-wall-listen)
   :title NIL
   :visible NIL
   :condition (not (active-p (unit 'blocker-engineers)))
   :on-complete (task-engineers-wall-complete))

;; complete the world engineers quest and get XP, even if not spoken to them yet
(quest:define-task (kandria world task-engineers-wall-complete)
   :title NIL
   :visible NIL
   :condition all-complete
   :on-activate T
   (:action functions
     (complete 'world-engineers-wall)))

;; replacement interact when the engineer is now on the surface in the final act, preparing for the battle
(quest:define-task (kandria world task-engineers-surface)
  :title ""
  :condition NIL
  :on-activate T

  (:interaction engineer-surface
   :interactable semi-engineer-chief
   :repeatable T
   :title ""
  "
~ semi-engineer-chief
| It's strange being on the surface. You live here? It's hot.
| I hope our metro will fare better than this shoddy water pipe.
"))

;; TODO region 3 lore entries: about the geothermal generators and the old company that ran them; about the Wraw massing supplies and building mechs and power suits, hinting at invasion (quest covers this explicitly), further deets to support the Cerebat takeover perhaps (though inflected based on whether that has happened yet or not). In the early game, the Wraw area could be sparse in NPCs and lore interacts are vague. And ofc player will never be able to access compounds at any time to learn too much about them.

;; NPC FALLBACK DIALOGUE

;; TODO flesh these out. Currently only done for the KS demo quests, with only temporary (T) complete fallback dialogue
;; Written to have minor arcs, should the player talk to them at the start/during, and the end of the demo quests. Generally based on how they regard the android early in the main story.
;; 3-5 alts each

;; Innis (Semi Sisters leader, female) - generally doesn't like the player; Scottish dialect
(define-default-interactions innis
  (q14-envoy
   "| (:angry)I'm watching you.")
  (q13-planting-bomb
   "| (:angry)Where've you been?")
  (demo-end-prep
   "| [? You might be useful after all. | You should think about joining us - leave those lowlifes you call friends behind. | Maybe you are better off intact than in pieces. | I hope getting the water back was worth it. | There's a war coming, android. Make sure you're on the winning side.]")
  (demo-intro
   "| [? Dinnae you have Semis' business to attend to? | I ken everything about you, android. So dinnae try anything funny. | I'm still contemplating dismantling you. So I wouldnae wait around here too long. | I didnae turn the water off lightly, you understand. But business is business.]")
  (demo-semis
   "| (:angry)[? \"Talk to my sister up in the control room.\"(orange) | Are your audio receivers offline? I said \"talk to my sister - she's up in the control room\"(orange). | Do you want the water turned back on or not? If you do, then \"talk to my sister up in the control room\"(orange).]")
  (demo-start
   "| [? Dinnae you have Semis' business to attend to? | I ken everything about you, android. So dinnae try anything funny. | I'm still contemplating dismantling you. So I wouldnae wait around here too long. | I didnae turn the water off lightly, you understand. But business is business.]")
  (T
  "| What do you want?"))
;; dinnae = don't (Scottish)
;; wouldnae = wouldn't (Scottish)
;; didnae = didn't (Scottish)
;; ken = know (Scottish)
   
;; Islay (Semi Sisters second in command and chief engineer, Innis' sister) - is warmer to the player; Scottish accent, but less dialect
;; No longer used in the demo, since Islay has immediate dialogue after innis initial convo, and then trader options all the time
(define-default-interactions islay
  (demo-end-prep
   "| [? I knew you'd come through for us. | If only people were as reliable as androids. | I'd love to hear your story - where you've been all these years. | Tell your friends we're sorry about the water. | I'll make sure Innis doesn't turn the water off again.]")
  (demo-start
   "| [? Mind how you go, {(nametag player)}. | You're a rare specimen indeed. | I never thought I'd see another working android. | You scratch our back, we'll do the rest.]")
  (T
  "| I'm sorry, I'm busy."))
  
;; alex - ex-Noka hunter, doesn't like the player since they believe they stole their job with the Noka
;; TODO don't have the fallback of "hic" be possible once they've left the Semi bar at the start of act 3 (q7), as they're meant to have sobered up by then
(define-default-interactions alex
  (q14-envoy
   "| (:angry)You picked the wrong side.")
  (q13-planting-bomb
   "| (:angry)Hello again.")
  (T
  "| (:angry)<-Hic->. Go away."))

;; can only appear in the demo
(define-default-interactions trader
  (T
  "| Sorry, habibti. I'm closed for business while I fix my caravan."))

;; Jack (Noka faction chief engineer, male) - doesn't like the player, or androids in general; Southern USA accent and dialect
(define-default-interactions jack
  (q14-envoy
   "| Was I wrong about you?")
  (q13-planting-bomb
   "| Look what the cat dragged in.")
  (q11a-bomb-recipe
   "| (:annoyed)Innis is a real bitch, don't ya think?")
  (demo-end-prep
   "| [? The water's back on. Don't tell me that was you? | That was a close one. Don't think I ever been so thirsty. | Maybe you're alright after all. | I'm still keeping an eye on you, mind.]")
  (demo-start
   "| (:annoyed)[? I'm watching you, android. | Don't you have work to do? | Be seein' ya. | I'm thirsty, hurry it up! | What's the matter? You afraid?]")
  (T
  "| What?"))

;; Fi (Noka faction leader, female) - somewhat indifferent and distanced to the player; formal, but warming to them. Japanese English accent and dialect.
(define-default-interactions fi
  (q14-envoy
   "| You're one of us.")
  (q13-planting-bomb
   "| (:unsure){(nametag player)}...")
  (q11a-bomb-recipe
  "| Konnichiwa.")
  (q11-recruit-semis
  "| (:unsure)Whatever you're doing, please hurry.")
  (q6-return-to-fi
  "| Konnichiwa.")
  (q4-intro
  "| Any news on Alex? I still need them back.")
  (demo-end-prep
   "| (:happy)[? You did it! But how did you do it? | People rarely return from the Semi Sisters. Yet here you are. | I knew I could trust you. | I'm so glad you're still intact. | Now our crops might stand a chance.]")
  (demo-start
   "| [? Please hurry, {(nametag player)}. | Our survival depends on you. | You are earning my trust. Please, continue to do so. | You could be a hunter, and more besides.]")
  (T
  "| Konnichiwa."))
   
;; Catherine (Noka junior engineer, female) - thinks the player character as an android is amazing, though treats them a little too much like a machine to begin with, before becoming great friends with them. Midwest/generic USA accent and dialect.
(define-default-interactions catherine
  (epilogue-talk
   "| (:concerned)So we won? I hope everyone is okay.")
  (q14-envoy
   "| (:concerned)You don't belong to Zelah. You don't belong to anyone but yourself.")
  (q13-planting-bomb
   "| He doesn't look so tough. (:excited)I could take him.")
  (demo-end-prep
   "| (:excited)[? I never doubted you! | You're my hero, {(nametag player)}! | I'm gonna take a bath! Well, once everyone's had their fill. | I won't take water for granted __EVER__ again.]")
  (demo-start
   "| (:concerned)[? The water's never been off this long. | I believe in you, {(nametag player)}. | It's just another adventure, right? | Is this the end?]")
  (T
  "| You okay?"))
  
(define-default-interactions zelah
  (q14-envoy
  "| It's too late for you. It's too late for everyone.")
  (T
  "| Keep going."))

;; same for each engineer
;; TODO more efficient way to structure this?
(define-default-interactions semi-engineer-1
  (T
   "| [? Talk to the new chief. | I'm busy. | It's been a long shift. | The new chief's the one you want.  | Sorry, can't chat. | I've got a lot of work to do. | Not a good time, sorry.]"))

(define-default-interactions semi-engineer-2
  (T
   "| [? Talk to the new chief. | I'm busy. | It's been a long shift. | The new chief's the one you want.  | Sorry, can't chat. | I've got a lot of work to do. | Not a good time, sorry.]"))
   
(define-default-interactions semi-engineer-3
  (T
   "| [? Talk to the new chief. | I'm busy. | It's been a long shift. | The new chief's the one you want.  | Sorry, can't chat. | I've got a lot of work to do. | Not a good time, sorry.]"))

(define-default-interactions semi-engineer-4
  (T
   "| [? Talk to the new chief. | I'm busy. | It's been a long shift. | The new chief's the one you want.  | Sorry, can't chat. | I've got a lot of work to do. | Not a good time, sorry.]"))
   
(define-default-interactions semi-engineer-5
  (T
   "| [? Talk to the new chief. | I'm busy. | It's been a long shift. | The new chief's the one you want.  | Sorry, can't chat. | I've got a lot of work to do. | Not a good time, sorry.]"))

;; same for each soldier
;; TODO more efficient way to structure this?
(define-default-interactions soldier-1
  (q14-envoy
  "| [? I'm not afraid of an android. | You look like a detective, not a soldier. Or maybe a nurse. | Zelah owns you, android. | Go away. | We'll be seeing you soon. And your friends.]")
  (q13-planting-bomb
   "| Step away.")
  (T
   "| [? Huh? | Yeah? | What?]"))

(define-default-interactions soldier-2
  (q14-envoy
  "| [? I'm not afraid of an android. | You look like a detective, not a soldier. Or maybe a nurse. | Zelah owns you, android. | Go away. | We'll be seeing you soon. And your friends.]")
  (q13-planting-bomb
   "| Step away.")
  (T
   "| [? Huh? | Yeah? | What?]"))
   
(define-default-interactions soldier-3
  (q14-envoy
  "| [? I'm not afraid of an android. | You look like a detective, not a soldier. Or maybe a nurse. | Zelah owns you, android. | Go away. | We'll be seeing you soon. And your friends.]")
  (q13-planting-bomb
   "| Step away.")
  (T
   "| [? Huh? | Yeah? | What?]"))

(define-default-interactions npc
  (T
   "| [? Haven't seen you around before. | ... | Sorry, I'm busy. | Uh. Hi? | Leave me alone. | You look kinda strange. | Excuse me. | No time to chat.]"))
