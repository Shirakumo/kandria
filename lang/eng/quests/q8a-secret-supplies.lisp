;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO store the target quantity in a variable, also used in the conditional? Then each time you talk to Catherine, she retrieves whatever you've got, and subtracts it from the variable for next time.
(quest:define-quest (kandria q8a-secret-supplies)
  :author "Tim White"
  :title "Supply Run"
  :description "The Cerebat trader says he'll tell me about the Cerebat Council, if I bring him the essential supplies he needs to get his shop back on its feet."
  :variables ((black-cap-count 2) (pure-water-count 2) (pearl-count 2) (coolant-count 2) (thermal-count 2))
  :on-activate T
  (return-supplies
   :title "Find 2 each of these and deliver them to the Cerebat trader: black cap mushroom, purified water, pearl, thermal fluid, coolant liquid"
   :on-complete (trader-cerebat-chat trader-cerebat-shop q9-contact-fi)
   :on-activate T
   (:interaction supplies-return
    :title "I'm back."
    :interactable cerebat-trader
    :repeatable T
    :dialogue "
~ cerebat-trader
| Did you get my supplies?
? (= 0 (+ (item-count 'item:mushroom-bad-1) (item-count 'item:pure-water) (item-count 'item:pearl) (item-count 'item:thermal-fluid) (item-count 'item:coolant)))
| ~ cerebat-trader
| | Oh, that's a no.
| ~ player
| | \"Remaining quantities to find are: \"black cap mushrooms: {(var 'black-cap-count)}\"(orange); \"purified water: {(var 'pure-water-count)}\"(orange); \"pearls: {(var 'pearl-count)}\"(orange); \"thermal fluid: {(var 'thermal-count)}\"(orange); \"coolant liquid: {(var 'coolant-count)}\"(orange).\"(light-gray, italic)
|?
| ~ cerebat-trader
| | Nice, I'll take what you've got.
| ! eval (setf (var 'black-cap-count) (max (- (var 'black-cap-count) (item-count 'item:mushroom-bad-1)) 0))
| ! eval (retrieve 'item:mushroom-bad-1 T)
| ! eval (setf (var 'pure-water-count) (max (- (var 'pure-water-count) (item-count 'item:pure-water)) 0))
| ! eval (retrieve 'item:pure-water T)
| ! eval (setf (var 'pearl-count) (max (- (var 'pearl-count) (item-count 'item:pearl)) 0))
| ! eval (retrieve 'item:pearl T)
| ! eval (setf (var 'thermal-count) (max (- (var 'thermal-count) (item-count 'item:thermal-fluid)) 0))
| ! eval (retrieve 'item:thermal-fluid T)
| ! eval (setf (var 'coolant-count) (max (- (var 'coolant-count) (item-count 'item:coolant)) 0))
| ! eval (retrieve 'item:coolant T)
| ? (and (= 0 (var 'black-cap-count)) (= 0 (var 'pure-water-count)) (= 0 (var 'pearl-count)) (= 0 (var 'thermal-count)) (= 0 (var 'coolant-count)))
| | ~ cerebat-trader
| | | (:jolly)Well, I think that's everything I asked for.
| | | (:sly)I'll just put them to one side. Gotta special customer lined up for these bad boys.
| | ~ player
| | - And now my information.
| |   ~ cerebat-trader
| |   | I gotta say, I thought you mighta worked it out by now.
| | - Ahem.
| |   ~ cerebat-trader
| |   | Don't worry, I 'aven't forgotten. Though I thought you mighta worked it out by now.
| | - What customer?
| |   ~ cerebat-trader
| |   | I gotta say, I thought you mighta worked it out by now.
| | ~ cerebat-trader
| | | (:cautious)The Wraw.
| | | I'm supplying the Wraw aren't I.
| | | It's the only good thing to come from them moving in, believe me. (:jolly)Don't tell anyone I said that.
| | | (:normal)So now you know.
| | | That's why you can't see the council. There isn't one any more.
| | | (:jolly)I told you they wouldn't see anyone!
| | | Toodle-oo.
| | ~ player
| | | (:embarassed)\"...\"(light-gray, italic)
| | | \"Shit.\"(light-gray, italic)
| | | (:normal)\"I need to \"contact Fi\"(orange). Though first I should \"put some distance between myself and this slippery trader\"(orange).\"(light-gray, italic)
| | ! eval (complete task)
| | ! eval (setf (quest:status (thing 'return-supplies)) :inactive)
| | ! eval (deactivate interaction)
| | ! eval (activate (unit 'fi-ffcs-cerebat-1))
| | ! eval (activate (unit 'fi-ffcs-cerebat-2))
| |?
| | ~ player
| | | \"Remaining quantities to find are: \"black cap mushrooms: {(var 'black-cap-count)}\"(orange); \"purified water: {(var 'pure-water-count)}\"(orange); \"pearls: {(var 'pearl-count)}\"(orange); \"thermal fluid: {(var 'thermal-count)}\"(orange); \"coolant liquid: {(var 'coolant-count)}\"(orange).\"(light-gray, italic)
")))
