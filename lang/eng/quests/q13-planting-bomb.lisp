;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q13-planting-bomb)
  :author "Tim White"
  :title "Planting the Bombs"
  :description "I need to plant each of the 3 bombs at key locations along the Noka-Semi border, then return to the Zenith Hub to radio in. Once detonated, they should stop the Wraw."
  :on-activate (task-reminder task-bomb-1 task-bomb-2 task-bomb-3)
  :variables (first-bomb-done)
  
  (task-reminder
   :title ""
   :visible NIL
   :invariant T
   :condition all-complete
   :on-activate (interact-islay interact-fi interact-catherine interact-innis interact-jack)

   (:interaction interact-islay
    :interactable islay
    :title "About the bombs."
    :repeatable T
    :dialogue "
~ islay
| (:normal)Remember where to \"plant them\"(orange):
| \"East of the Rootless hospital apartments, beneath the old Semi factory;\"(orange)
| \"The mushroom cave to the west;\"(orange)
| \"The sunken room beside the pump.\"(orange)
| Good luck.
")

   (:interaction interact-fi
    :interactable fi
    :title ""
    :repeatable T
    :dialogue "
~ fi
| Islay can remind you where to plant the bombs.
| I'm sorry, my mind is elsewhere.
| One was the sunken room beside the pump, I remember that much.
| (:happy)Be careful, {#@player-nametag}. Please.
")

   (:interaction interact-catherine
    :interactable catherine
    :title ""
    :repeatable T
    :dialogue "
~ catherine
| Hey, {#@player-nametag}! You still good to go? Talk to Islay if you need anything.
| (:excited)I can't wait to see us win, and you'll be the hero.
| (:normal)I'm glad I got to help build the bombs. Feels like sticking it to the Wraw myself.
| You be careful, okay?
")

   (:interaction interact-innis
    :interactable innis
    :title ""
    :repeatable T
    :dialogue "
~ islay
| Islay can remind you about your mission. I dinnae think I've anything to add, if she told you what she said she would.
| (:sly)I hope I was wrong about you, android.
| (:normal)We need you.
")

   (:interaction interact-jack
    :interactable jack
    :title ""
    :repeatable T
    :dialogue "
~ jack
| I can't help you, I'm outta the loop now. They didn't even need me to make the bomb.
| All I can do is keep an eye on everyone, make sure they don't freak out.
| (:annoyed)And the sooner you get goin', the less people will freak out.
"))

  (task-bomb-1
   :title "Plant a bomb on the low eastern border, east of the Rootless hospital apartments and below the old Semi factory"
   :invariant T
   :condition all-complete
   :on-activate (interact-bomb)

   (:interaction interact-bomb
    :interactable bomb-1
    :dialogue "
~ player
| \"This is the bomb site beneath the Semi factory.\"(light-gray, italic)
| \"I mould the explosive into a wall crevice, then push two RF detonators into the plastic.\"(light-gray, italic)
! eval (retrieve 'item:explosive 1)
! eval (retrieve 'item:receiver 2)
| \"It's ready.\"(light-gray, italic)
? (not (var 'first-bomb-done))
| | \"Checking FFCS... No signal. Wraw interference, as expected.\"(light-gray, italic)
| | \"Okay, 2 more bombs to go.\"(light-gray, italic)
| ! eval (setf (var 'first-bomb-done) T)
|? (complete-p 'task-bomb-2 'task-bomb-3)
| | \"Checking FFCS... More interference.\"(light-gray, italic)
| | \"That's the last bomb planted.\"(light-gray, italic)
| | \"I'd better \"get back to the Zenith Hub\"(orange) ASAP and request detonation.\"(light-gray, italic)
| ! eval (deactivate 'task-reminder)
| ! eval (activate 'task-return-bombs)
| ! eval (activate (unit 'ffcs-bomb-1))
| ! eval (activate (unit 'ffcs-bomb-2))
| ! eval (activate (unit 'ffcs-bomb-3))
| ! eval (activate (unit 'ffcs-bomb-4))
|?
| | \"Checking FFCS... There's still interference.\"(light-gray, italic)
| | \"Now I only have the last bomb to plant.\"(light-gray, italic)
"))

  (task-bomb-2
   :title "Plant a bomb in the flooded room beside the pump room"
   :invariant T
   :condition all-complete
   :on-activate (interact-bomb)

   (:interaction interact-bomb
    :interactable bomb-2
    :dialogue "
~ player
| \"This is the bomb site beneath the pump room.\"(light-gray, italic)
| \"I mould the explosive into a crack in the concrete floor, which sticks despite being wet.\"(light-gray, italic)
! eval (retrieve 'item:explosive 1)
| \"I push two RF detonators into the plastic. Thankfully they seem to be waterproof.\"(light-gray, italic)
! eval (retrieve 'item:receiver 2)
| \"It's ready.\"(light-gray, italic)
? (not (var 'first-bomb-done))
| | \"Checking FFCS... No signal. Wraw interference, as expected.\"(light-gray, italic)
| | \"Okay, 2 more bombs to go.\"(light-gray, italic)
| ! eval (setf (var 'first-bomb-done) T)
|? (complete-p 'task-bomb-1 'task-bomb-3)
| | \"Checking FFCS... More interference.\"(light-gray, italic)
| | \"That's the last bomb planted.\"(light-gray, italic)
| | \"I'd better \"get back to the Zenith Hub\"(orange) ASAP and request detonation.\"(light-gray, italic)
| ! eval (deactivate 'task-reminder)
| ! eval (activate 'task-return-bombs)
| ! eval (activate (unit 'ffcs-bomb-1))
| ! eval (activate (unit 'ffcs-bomb-2))
| ! eval (activate (unit 'ffcs-bomb-3))
| ! eval (activate (unit 'ffcs-bomb-4))
|?
| | \"Checking FFCS... There's still interference.\"(light-gray, italic)
| | \"Now I only have the last bomb to plant.\"(light-gray, italic)
"))

  (task-bomb-3
   :title "Plant a bomb in the mushroom cave to the west of the old Dreamscape apartments"
   :invariant T
   :condition all-complete
   :on-activate (call-bomb)

   (:interaction call-bomb
    :interactable bomb-3
    :dialogue "
~ player
| \"This is the bomb site in the mushroom cave.\"(light-gray, italic)
| \"I mould the explosive into the giant mushroom. Why not? Might as well cover them in fungus when they come through.\"(light-gray, italic)
! eval (retrieve 'item:explosive 1)
| \"I push two RF detonators into the plastic.\"(light-gray, italic)
! eval (retrieve 'item:receiver 2)
| \"It's ready.\"(light-gray, italic)
? (not (var 'first-bomb-done))
| | \"Checking FFCS... No signal. Wraw interference, as expected.\"(light-gray, italic)
| | \"Okay, 2 more bombs to go.\"(light-gray, italic)
| ! eval (setf (var 'first-bomb-done) T)
|? (complete-p 'task-bomb-1 'task-bomb-2)
| | \"Checking FFCS... More interference.\"(light-gray, italic)
| | \"That's the last bomb planted.\"(light-gray, italic)
| | \"I'd better \"get back to the Zenith Hub\"(orange) ASAP and request detonation.\"(light-gray, italic)
| ! eval (deactivate 'task-reminder)
| ! eval (activate 'task-return-bombs)
| ! eval (activate (unit 'ffcs-bomb-1))
| ! eval (activate (unit 'ffcs-bomb-2))
| ! eval (activate (unit 'ffcs-bomb-3))
| ! eval (activate (unit 'ffcs-bomb-4))
|?
| | \"Checking FFCS... There's still interference.\"(light-gray, italic)
| | \"Now I only have the last bomb to plant.\"(light-gray, italic)
"))

(task-return-bombs
   :title "Return to the Zenith Hub and contact Islay to detonate the bombs"
   :invariant T
   :condition all-complete
   :on-activate (return-bombs)
   :on-complete (q14-envoy)

   (:interaction call-bomb
    :interactable islay
    :title ""
    :dialogue "
~ player
| \"That should be far enough.\"(light-gray, italic)
| \"Checking FFCS... OK. I have a signal.\"(light-gray, italic)
| \"Islay, do you read me? The bombs are in position.\"(light-gray, italic)
| (:skeptical)\"... Hello, anyone?...\"(light-gray, italic)
| \"... The connection is open...\"(light-gray, italic)
~ islay
| (:nervous){#@player-nametag}, I read you. We have a problem - return to the surface now.
~ player
- What about the bombs?
- What problem?
- Can I talk to Fi?
~ player
| (:skeptical)\"... She closed the connection.\"(light-gray, italic)
| \"<-Shit.->\"(light-gray, italic)
| \"There's only one way to find out what's happening: \"go back to camp\"(orange).\"(light-gray, italic)
| ! eval (deactivate (unit 'ffcs-bomb-1))
| ! eval (deactivate (unit 'ffcs-bomb-2))
| ! eval (deactivate (unit 'ffcs-bomb-3))
| ! eval (deactivate (unit 'ffcs-bomb-4))
! eval (ensure-nearby 'outside-engineering 'innis 'catherine 'jack)
! setf (direction 'innis) 1
! setf (direction 'catherine) 1
! setf (direction 'jack) 1
! eval (setf (location 'fi) 'fi-wraw)
! setf (direction 'fi) 1
! eval (setf (location 'islay) 'islay-wraw)
! setf (direction 'islay) 1
! eval (setf (location 'trader) 'fi-farm)
! setf (direction 'trader) 1
! eval (setf (location 'alex) 'wraw-alex)
! setf (direction 'alex) -1
! eval (setf (location 'zelah) 'wraw-leader)
! setf (direction 'zelah) -1
")))
;; TODO hide zelah in the world before this point, and spawn him in here (currently placed in Wraw territory, but we want to keep him a secret till now)
;; TODO move other Wraw soldiers to the wraw-envoy zone (ensure-nearby)