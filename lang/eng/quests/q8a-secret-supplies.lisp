;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q8a-secret-supplies)
  :author "Tim White"
  :title "Supply Run"
  :description "The Cerebat trader says he'll tell me where the Cerebat Council are, if I bring him the essential supplies he needs to get his merchant shop back on its feet."
  :variables ((black-cap-count 2) (pure-water-count 2) (pearl-count 2) (thermal-count 2) (coolant-count 2))
  :on-activate T
  (return-supplies
   :title "Find 2 each of these and deliver them to the Cerebat trader: black cap mushroom, purified water, pearl, thermal fluid, coolant liquid"
   :on-complete (trader-cerebat-chat trader-cerebat-shop q9-contact-fi)
   :on-activate T
   (:interaction supplies-return
    :title "I'm back."
    :interactable cerebat-trader-quest
    :repeatable T
    :dialogue "
~ cerebat-trader-quest
| Did you get my supplies?
? (= 0 (+ (item-count 'item:mushroom-bad-1) (item-count 'item:pure-water) (item-count 'item:pearl) (item-count 'item:thermal-fluid) (item-count 'item:coolant)))
| ~ cerebat-trader-quest
| | Oh, that's a no. Keep lookin' - \"the stuff's 'round 'ere\"(orange), I'm sure of it.
| ~ player
| | \"Remaining quantities to find are: [(< 0 (var 'black-cap-count)) \"black cap mushrooms: {(var 'black-cap-count)}\"(orange) |] [(< 0 (var 'pure-water-count)) ; \"purified water: {(var 'pure-water-count)}\"(orange) |] [(< 0 (var 'pearl-count)) ; \"pearls: {(var 'pearl-count)}\"(orange) |] [(< 0 (var 'thermal-count)) ; \"thermal fluid: {(var 'thermal-count)}\"(orange) |] [(< 0 (var 'coolant-count)) ; \"coolant liquid: {(var 'coolant-count)}\"(orange)].\"(light-gray, italic)
|?
| ~ cerebat-trader-quest
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
| | ~ cerebat-trader-quest
| | | I fink that's everything I asked for.
| | | I'll just put them to one side. Got a special customer lined up for these bad boys.
| | ~ player
| | - And now my information.
| |   ~ cerebat-trader-quest
| |   | I gotta say, I thought you mighta worked it out by now.
| | - Ahem.
| |   ~ cerebat-trader-quest
| |   | Don't worry, I 'aven't forgotten. Though I thought you mighta worked it out by now.
| | - What customer?
| |   ~ cerebat-trader-quest
| |   | I gotta say, I thought you mighta worked it out by now.
| | ~ cerebat-trader-quest
| | | The Wraw.
| | | I'm supplying the Wraw aren't I.
| | | It's the only good thing to come from them moving in, believe me. Though don't tell anyone I said that.
| | | So now you know.
| | | That's why you can't see the council. There isn't one any more.
| | | I told you they wouldn't see anyone!
| | | Toodle-oo.
| | ~ player
| | | (:embarassed)\"...\"(light-gray, italic)
| | | Shit.
| | | (:normal)\"I need to \"contact Fi\"(orange). Though first I should \"put some distance between myself and this slippery fella\"(orange).\"(light-gray, italic)
| | ! eval (complete task)
| | ! eval (reset* interaction)
| | ! eval (activate (unit 'fi-ffcs-cerebat-1))
| | ! eval (activate (unit 'fi-ffcs-cerebat-2))
| |?
| | ~ player
| | | \"Remaining quantities to find are: [(< 0 (var 'black-cap-count)) \"black cap mushrooms: {(var 'black-cap-count)}\"(orange) |] [(< 0 (var 'pure-water-count)) ; \"purified water: {(var 'pure-water-count)}\"(orange) |] [(< 0 (var 'pearl-count)) ; \"pearls: {(var 'pearl-count)}\"(orange) |] [(< 0 (var 'thermal-count)) ; \"thermal fluid: {(var 'thermal-count)}\"(orange) |] [(< 0 (var 'coolant-count)) ; \"coolant liquid: {(var 'coolant-count)}\"(orange)].\"(light-gray, italic)
")))
