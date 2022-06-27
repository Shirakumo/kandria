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
| \"I wonder if people tried to use this station to escape below ground.\"(light-gray, italic)
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
| \"Is that glass cracking beneath my feet, or broken bones? I don't think I want to look.\"(light-gray, italic)
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
  (:interaction engineering-shelves
   :interactable lore-engineering
   :repeatable T
   "
~ player
? (complete-p 'q0-find-jack)
| | \"Engineering. This is where Jack and Catherine work.\"(light-gray, italic)
|?
| | \"It's some sort of workshop. The technology is crude - what do they build here, tin openers?\"(light-gray, italic)
")

  ;; Jack's workbench in the engineering workshop; "work out" = exercise/gym
  ;; "who come to think of it has a stare that could fry circuits." - this is before the player has met Jack, so we can imagine he's glaring at them
  (:interaction engineering-bench
   :interactable lore-eng-bench
   :repeatable T
   "
~ player
? (complete-p 'q0-find-jack)
| | \"Jack's workbench. I can smell body odour - does he work here, or work out?\"(light-gray, italic)
|?
| | \"It's a workbench. Perhaps it belongs to this man - who come to think of it looks like he wants to kill me.\"(light-gray, italic)
")

  ;; a sandstorm blocks the player from crossing further into the desert to the west
  ;; does this say androids are bulletproof? Perhaps, though could just be a turn of phrase. Guns don't feature in the game, except when people are massing arms at the end;
  ;; which could suggest the android would be formidable on the battlefield, if bulletproof, and thus why Zelah wants them out of the way.
  (:interaction sandstorm-view
   :interactable lore-storm
   :repeatable T
   "
~ player
| \"The particulates are pinging off my body like bullets.\"(light-gray, italic)
| \"Mountains lay beyond, though I can hardly see them in this storm.\"(light-gray, italic)
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
| \"The \"Midwest Market\"(red). Those mannequins behind the glass could almost be real people.\"(light-gray, italic)
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
| | (:normal)\"Presumably they are inedible, otherwise their food problems would be over.\"(light-gray, italic)
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
| \"\"Semi\"(red) were the manufacturers of electronic components, not least for androids.\"(light-gray, italic)
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
  ;; needs to work whether they encounter this at the beginning of the game, or at any point later
  (:interaction grave
   :interactable lore-grave
   :repeatable T
   "
~ player
| (:thinking)\"So this is where it ended. And now begins.\"(light-gray, italic)
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
| \"It's fortunate they lit these tunnels with lanterns - the charge is more than sufficient to power my boost.\"(light-gray, italic)
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
;; conditional for when the base is empty later on
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
;; conditional for when the base is empty later on
  (:interaction semi-hub-4
   :interactable lore-semi-control
   :repeatable T
   "
~ player
? (not (complete-p (find-task 'q11a-bomb-recipe 'task-move-semis)))
| | \"The din of the base fades away up here - save for the interruption of fuzzy video feeds and comms chatter.\"(light-gray, italic)
|?
| | \"Dark screens. It's either pitch black in the tunnels, or the rest of their CCTV cameras have gone offline.\"(light-gray, italic)
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

;; the caved-in tunnel that trapped the Semi Sisters engineers. A different line plays depending on whether or not the debris has been cleared yet, and whether or not the player knows about the trapped engineers quests yet
;; the "UP and around" clue is important here, to tell the player they need to go up not down. We can imagine the player character has used FFCS to scan and know there's a way up but not down
  (:interaction engineers-wall
   :interactable lore-engineers-wall
   :repeatable T
   "
~ player
? (active-p (unit 'blocker-engineers))
| ? (or (active-p 'demo-engineers) (active-p 'q5a-rescue-engineers))
| | | \"This might be the \"collapsed tunnel\"(orange) that trapped the \"Semis engineers\"(orange).\"(light-gray, italic)
| | | \"I don't think I can clear it from this side.\"(light-gray, italic)
| | | (:thinking)\"I'll need to \"find another way up and around\"(orange).\"(light-gray, italic)
| |?
| | | \"A collapsed tunnel. I don't think I can clear it from this side.\"(light-gray, italic)
| | | (:thinking)\"I'll need to \"find another way up and around\"(orange).\"(light-gray, italic)
|?
| ? (or (active-p 'demo-engineers) (active-p 'q5a-rescue-engineers) (complete-p 'demo-engineers) (complete-p 'q5a-rescue-engineers))
| | | \"The remnants of the collapsed rail tunnel. It looks stable enough - for now.\"(light-gray, italic)
| |?
| | | \"The remnants of the collapsed tunnel. It looks stable enough - for now.\"(light-gray, italic)
")

;; REGION 2

;; abandoned laboratory
;; The player does know the term "Calamity" by this point
  (:interaction cerebat-lab-1
   :interactable lore-cerebat-lab-1
   :repeatable T
   "
~ player
| (:thinking)\"I don't think this lab has been used since before the Calamity.\"(light-gray, italic)
")

;; abandoned lab, looking at an unusual sample in a glass tube (like something from Aliens)
  (:interaction cerebat-lab-2
   :interactable lore-cerebat-lab-2
   :repeatable T
   "
~ player
| (:embarassed)\"What the hell is that? I think it's organic. And dead.\"(light-gray, italic)
| \"Well it's staying where it is. I don't want anything jumping on my face.\"(light-gray, italic)
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

;; big mushrooms in a big lush water cave, different to the ones higher up. And hence the drinkable joke
  (:interaction cerebat-mush-cave
   :interactable lore-cerebat-mush-cave
   :repeatable T
   "
~ player
| \"These are a different kind of giant mushroom. I don't know if they're edible.\"(light-gray, italic)
| (:giggle)\"Though given how wet this place is, they might be drinkable.\"(light-gray, italic)
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
;; character turns it into a joke, since chances are they've seen bats flying around in the caves before. Even if they haven't, they'll know the meaning.
;; They may or may not have encountered / know about the Cerebats faction at this point
  (:interaction cerebat-bats-1
   :interactable lore-cerebat-bats-1
   :repeatable T
   "
~ player
| (:giggle)\"Yes, there are indeed bats in these parts.\"(light-gray, italic)
")

;; another painted Cerebats faction sign and direction arrow, though it only says "BATS" (and is written in red paint, the same colour as blood AND thermal fluid in androids)
;; They may or may not have encountered / know about the Cerebats faction at this point
  (:interaction cerebat-bats-2
   :interactable lore-cerebat-bats-2
   :repeatable T
   "
~ player
| (:embarassed)\"I hope that's not written in blood. Or thermal fluid.\"(light-gray, italic)
")

;; a mushroom cave, but also referring to the lush backdrop
  (:interaction cerebat-mush
   :interactable lore-cerebat-mush
   :repeatable T
   "
~ player
| \"It's so humid down here, no wonder it's lush.\"(light-gray, italic)
| (:giggle)\"Thank God I don't sweat, or I'd be watering the plants from my armpits.\"(light-gray, italic)
")

;; a lake area; the water is pumped from here to the Semis and Noka living areas far above
;; may or may not know the names of the factions in the levels above at this point, hence ambiguity
  (:interaction cerebat-lake
   :interactable lore-cerebat-lake
   :repeatable T
   "
~ player
| (:thinking)\"Water must get pumped up from these lakes to the levels above.\"(light-gray, italic)
")

;; because this is a light area, even though it's deep underground
;; teasing the concept of big phosphorescent (radioactive?) fauna - though you never see anything
  (:interaction cerebat-light
   :interactable lore-cerebat-light
   :repeatable T
   "
~ player
| (:thinking)\"Where's all the light coming from? Phosphorescent flora?\"(light-gray, italic)
| (:embarassed)\"Phosphorescent fauna?...\"(light-gray, italic)
")

;; wind in the tunnels, caused by difference in temperature with the levels above, and with the air over water and land
  (:interaction cerebat-wind
   :interactable lore-cerebat-wind
   :repeatable T
   "
~ player
| (:thinking)\"The water must be cooling the hot air and causing the wind.\"(light-gray, italic)
")

;; wind power
;; may have encountered wind farming in the tunnels already in Semi/Cerebat territory (sidequest), or may not have - but can assume the character has observed this in the environment while exploring
;; not "the doldrums" - since the wind is light, and so is the mood here; not what she was expecting deep underground
;; her thrusters use power for wind!
  (:interaction cerebat-wind-power
   :interactable lore-cerebat-wind-power
   :repeatable T
   "
~ player
| \"It's not exactly the doldrums down here.\"(light-gray, italic)
| \"No wonder they use wind for power -\"(light-gray, italic) (:giggle)\"much as my thrusters do the reverse.\"(light-gray, italic)
")

;; bouncing springs like in Sonic
;; Helps people/hunters/androids (assuming you know of hunters at this point) to navigate these tunnels
;; Derived from old railway buffers (those round sprung buffers, use in pairs on the front and back of rail carriages/trucks/cars, to help avoid impacts when connecting them together)
  (:interaction cerebat-bouncer
   :interactable lore-cerebat-bouncer
   :repeatable T
   "
~ player
| \"Those springboards are repurposed rail buffers... Ingenious!\"(light-gray, italic)
")

;; oil slick in a cave
;; may not have had the harsh treatment from Jack (and others yet), but we can assume the character remembers that part of their old life, that humans and androids don't get along
;; TODO remove this if Nick removed them from the game
  (:interaction cerebat-oil
   :interactable lore-cerebat-oil
   :repeatable T
   "
~ player
| \"Oil and water. Like humans and androids.\"(light-gray, italic)
")
;; could have said something about fossils/androids, but you'll see there are fossils in there if you fish in the oil
;; the free availability of oil also shows why the Cerebats are a wealthy faction (or were, before the Wraw took them over)

;; a hideout of neutral rogue enemies, who ambush passers by (might not be obvious to player, so description clarifies). Well stocked due to all the item spawners.
;; player may or may not know about rogues by this point
  (:interaction cerebat-hideout
   :interactable lore-cerebat-hideout
   :repeatable T
   "
~ player
| \"A well-off hideout. Though if that stench is anything to go by,\"(light-gray, italic) (:giggle)\"it's seriously lacking in bathroom facilities.\"(light-gray, italic)
")

;; an abandoned hideout of neutral rogue enemies, who used to ambush passers by (might not be obvious to player, so description clarifies)
;; player may or may not know about rogues by this point, and the Semi Sisters (by name) on the level above; though to reach here, they will have seen that the level above is populated/watched
  (:interaction cerebat-old-hideout
   :interactable lore-cerebat-old-hideout
   :repeatable T
   "
~ player
| \"A long-abandoned hideout - most of the litter has blown away, but a few footprints remain.\"(light-gray, italic)
| (:thinking)\"Its position was probably too open and exposed, not to mention too close to the level above.\"(light-gray, italic)
")

;; an encampment of raiders on the edge of the Cerebat base
;; player may or may not have discovered the Cerebat base by this point - if they have, then this makes sense; if not, then it's a slight clue (but not a spoiler) that a base is nearby
;; player may or may not suspect/know that the Wraw have taken over the Cerebats by this point (depending where they are in the plot); if they do suspect, then this fuels the fire
  (:interaction cerebat-encampment
   :interactable lore-cerebat-encampment
   :repeatable T
   "
~ player
| \"This reminds me of a shady backstreet cache. I think they're running a black market out of here.\"(light-gray, italic)
")

;; cerebat council chamber - it's empty, no council
;; the room is modern and shiny, like the Calamity never happened (unlike most other places the player has seen)
;; player may or may not suspect/know that the Wraw have taken over the Cerebats by this point (depending where they are in the plot)
;; the player does know the term "Calamity" by this point
  (:interaction cerebat-council
   :interactable lore-cerebat-council
   :repeatable T
   "
~ player
| \"Instead of a shadow there's a reflection staring back at me from the shiny black floor.\"(light-gray, italic)
| \"You'd think the Calamity never happened here.\"(light-gray, italic)
")

;; living quarters - tents set up in rooms, deep underground
;; player may or may not suspect/know that the Wraw have taken over the Cerebats by this point (depending where they are in the plot)
  (:interaction cerebat-housing
   :interactable lore-cerebat-housing
   :repeatable T
   "
~ player
| \"This is a cosy little corner to set up camp. Not exactly under the stars though.\"(light-gray, italic)
")

;; shady backstreets
;; player may or may not suspect/know that the Wraw have taken over the Cerebats by this point (depending where they are in the plot)
  (:interaction cerebat-backstreet
   :interactable lore-cerebat-backstreet
   :repeatable T
   "
~ player
| \"You've seen one seedy backstreet, you've seen them all.\"(light-gray, italic)
")

;; busy market
;; player may or may not suspect/know that the Wraw have taken over the Cerebats by this point (depending where they are in the plot) - thus we raise suspicion here if they don't know, or confirm suspicion if they do (or it may just be interpreted as prejudice towards androids)
  (:interaction cerebat-market
   :interactable lore-cerebat-market
   :repeatable T
   "
~ player
| \"It's a busy market day, and I'm getting a disproportionate number of sideways glances.\"(light-gray, italic)
")

;; warehouse/factory
;; "Some of the boxes are covered in ash." - this is a clue that the Wraw have been suppling / have taken over the Cerebats. But it needs to be vague enough to make sense both before and after the player has discovered the Wraw takeover, at a time when they may or may not know as well that the Wraw come from a volcanic area. It also can't be too specific to serve as a plot clue, since this confirmation only comes from the cerebat trader during q8a.
  (:interaction cerebat-warehouse
   :interactable lore-cerebat-warehouse
   :repeatable T
   "
~ player
| \"I don't think I've seen a more stocked warehouse, and that includes before the Calamity.\"(light-gray, italic)
| \"Some of the boxes are covered in ash.\"(light-gray, italic)
")

;; REGION 3
;; fewer lore entries here, to preserve the mystery

;; geothermal tube
;; part of the old underground power station, which circulated water into the heat of the earth to produce steam, which in turn powered a turbine
;; parts of it are still active, used exclusively by the Wraw faction
  (:interaction wraw-tube
   :interactable lore-wraw-tube
   :repeatable T
   "
~ player
| \"This was one of Trickle's geothermal power stations. The pipes carried water here to be heated up.\"(light-gray, italic)
| (:thinking)\"The steam then powered turbines to produce electricity.\"(light-gray, italic)
")

;; lava fishing spot
;; the player can fish certain rare and exotic (and machine) types of fish/waste from the lava
  (:interaction wraw-fish
   :interactable lore-wraw-fish
   :repeatable T
   "
~ player
| \"It takes a special kind of life form to swim in lava.\"(light-gray, italic) (:embarassed)\"And I'm not it.\"(light-gray, italic)
")

;; lava and spikes area
;; "smell" because of the burning everywhere, accentuated by the blasts of hot air that the player can ride to platform around
;; android may or may not be religious - probably not. But keeps it open for the player. If not, then ofc this is just a turn of phrase
  (:interaction wraw-lava
   :interactable lore-wraw-lava
   :repeatable T
   "
~ player
| (:embarassed)\"This place is starting to look and smell more like Hell by the second.\"(light-gray, italic)
")

;; peoples' homes
;; the player may or may not know that these people are the enemy Wraw faction by this point; if they don't, then the negative tone here can be because this lava area seems a stupid place to live
  (:interaction wraw-people
   :interactable lore-wraw-people
   :repeatable T
   "
~ player
| \"It's a hardy bunch who choose to live in a lava tube, I'll give them that.\"(light-gray, italic)
")

;; cache of supplies (and weapons)
;; the player may or may not know that these people are the enemy Wraw faction by this point; so this is a more general comment about their living conditions
  (:interaction wraw-cache
   :interactable lore-wraw-cache
   :repeatable T
   "
~ player
| \"Life could be quite comfortable here - if you weren't living on a lava floodplain.\"(light-gray, italic)
"))

;; TODO region 3 lore entries: about the Wraw massing supplies and building mechs and power suits, hinting at invasion (quest covers this explicitly), further deets to support the Cerebat takeover perhaps (though inflected based on whether that has happened yet or not). In the early game, the Wraw area could be sparse in NPCs and lore interacts are vague. And ofc player will never be able to access compounds at any time to learn too much about them.


;; SEMI SISTERS ENGINEERS

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
| | ! eval (deactivate 'task-engineers-wall-listen)
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
     (complete 'world-engineers-wall)
     (activate 'world-move-engineers)))

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

;; NPC FALLBACK DIALOGUE

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
   
;; Islay, female (Semi Sisters second in command and chief engineer, Innis' sister) - is warmer to the player; Scottish accent, but less dialect
(define-default-interactions islay
  (T
  "| I'm sorry, I'm busy."))
  
;; alex, non binary - ex-Noka hunter, doesn't like the player since they believe they stole their job with the Noka; speaks London multicultural English
;; TODO don't have the fallback of "hic" be possible once they've left the Semi bar at the start of act 3 (q7), as they're meant to have sobered up by then
(define-default-interactions alex
  (q14-envoy
   "| (:angry)You picked the wrong side.")
  (q13-planting-bomb
   "| (:angry)Hello again.")
  (T
  "| (:angry)<-Hic->. Go away."))

;; Sahil, trader, male, Arabic code switching (used in demo and main game)
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
  (T
  "| You okay?"))
  
(define-default-interactions zelah
  (q14-envoy
  "| It's too late for you. It's too late for everyone.")
  (T
  "| Keep going."))

;; Semi Sisters engineers, a variety of genders represented here
;; TODO more efficient way to structure this?
;; top ones are when they're on the surface, before the battle
(define-default-interactions semi-engineer-1
  (q11a-bomb-recipe
   "| [? I hope there's something left to rebuild. | After all that work on the railway... Now this. | It's strange, just waiting. | I'm use to welding rails not cleaning guns. | Who are you again?]")
  (T
   "| [? Talk to the new chief. | I'm busy. | It's been a long shift. | The new chief's the one you want.  | Sorry, can't chat. | I've got a lot of work to do. | Not a good time, sorry.]"))

(define-default-interactions semi-engineer-2
  (q11a-bomb-recipe
   "| [? I hope there's something left to rebuild. | After all that work on the railway... Now this. | It's strange, just waiting. | I'm use to welding rails not cleaning guns. | Who are you again?]")
  (T
   "| [? Talk to the new chief. | I'm busy. | It's been a long shift. | The new chief's the one you want.  | Sorry, can't chat. | I've got a lot of work to do. | Not a good time, sorry.]"))
   
(define-default-interactions semi-engineer-3
  (q11a-bomb-recipe
   "| [? I hope there's something left to rebuild. | After all that work on the railway... Now this. | It's strange, just waiting. | I'm use to welding rails not cleaning guns. | Who are you again?]")
  (T
   "| [? Talk to the new chief. | I'm busy. | It's been a long shift. | The new chief's the one you want.  | Sorry, can't chat. | I've got a lot of work to do. | Not a good time, sorry.]"))

(define-default-interactions semi-engineer-4
  (q11a-bomb-recipe
   "| [? I hope there's something left to rebuild. | After all that work on the railway... Now this. | It's strange, just waiting. | I'm use to welding rails not cleaning guns. | Who are you again?]")
  (T
   "| [? Talk to the new chief. | I'm busy. | It's been a long shift. | The new chief's the one you want.  | Sorry, can't chat. | I've got a lot of work to do. | Not a good time, sorry.]"))
   
(define-default-interactions semi-engineer-5
  (q11a-bomb-recipe
   "| [? I hope there's something left to rebuild. | After all that work on the railway... Now this. | It's strange, just waiting. | I'm use to welding rails not cleaning guns. | Who are you again?]")
  (T
   "| [? Talk to the new chief. | I'm busy. | It's been a long shift. | The new chief's the one you want.  | Sorry, can't chat. | I've got a lot of work to do. | Not a good time, sorry.]"))

;; Wraw soldiers and personal bodyguards of Zelah - a variety of genders represented here
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

;; Semi Sisters roboticist, female
;; top one is when they're on the surface, before the battle
(define-default-interactions semi-robiticist
  (q11a-bomb-recipe
   "| We could really use some Servos on our side, right about now.")
  (sq4-analyse-robots
   "| I'm getting closer to understanding how Servos think. How //you//think too.")
  (T
  "| Can't talk now, sorry. Science waits for no one. Maybe later?"))

(define-default-interactions npc
  (T
   "| [? Haven't seen you around before. | ... | Sorry, I'm busy. | Uh. Hi? | Leave me alone. | You look kinda strange. | Excuse me. | No time to chat.]"))

;; TODO - faction generic NPC granularity
;; Cerebats/traders: Sorry, we're closed. etc.