;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q8a-secret-supplies)
  :author "Tim White"
  :title "Supply Run"
  :description "The Cerebat trader says he'll tell me where the Council are, if I bring him the essential supplies he needs for his merchant shop. They can be found nearby."
  :variables ((black-cap-count 2) (black-cap-prev-count) (pure-water-count 2) (pure-water-prev-count) (pearl-count 2) (pearl-prev-count) (thermal-count 2) (thermal-prev-count) (coolant-count 2) (coolant-prev-count))
  :on-activate (return-supplies task-mushroom task-water task-pearl task-thermal task-coolant)
  
  (task-mushroom
   :title "Deliver 2 black cap mushrooms total"
   :condition (= 0 (var 'black-cap-count))
   :on-complete NIL)

  (task-water
   :title "Deliver 2 purified water total"
   :condition (= 0 (var 'pure-water-count))
   :on-complete NIL)
   
  (task-pearl
   :title "Deliver 2 pearls total"
   :condition (= 0 (var 'pearl-count))
   :on-complete NIL)

  (task-thermal
   :title "Deliver 2 thermal fluid total"
   :condition (= 0 (var 'thermal-count))
   :on-complete NIL)

  (task-coolant
   :title "Deliver 2 coolant liquid total"
   :condition (= 0 (var 'coolant-count))
   :on-complete NIL)
  
  (return-supplies
   :title ""
   :visible NIL
   :marker '(cerebat-trader-quest 500)
   :on-complete (trader-cerebat-chat trader-cerebat-shop q9-contact-fi)
   :on-activate T
   (:interaction supplies-return
    :title "I'm back."
    :interactable cerebat-trader-quest
    :repeatable T
    :dialogue "
~ cerebat-trader-quest
| Did you get my supplies?
? (= 0 (+ (min (var 'black-cap-count) (item-count 'item:mushroom-bad-1)) (min (var 'pure-water-count) (item-count 'item:pure-water)) (min (var 'pearl-count) (item-count 'item:pearl)) (min (var 'thermal-count) (item-count 'item:thermal-fluid)) (min (var 'coolant-count) (item-count 'item:coolant))))
| ~ cerebat-trader-quest
| | Oh, that's a no. Keep lookin' - \"the stuff's 'round 'ere\"(orange), I'm sure of it.
| ~ player
| | \"Remaining quantities to find nearby are: [(< 0 (var 'black-cap-count)) \"Black cap mushrooms: {(var 'black-cap-count)}\"(orange).|] [(< 0 (var 'pure-water-count)) \"Purified water: {(var 'pure-water-count)}\"(orange).|] [(< 0 (var 'pearl-count)) \"Pearls: {(var 'pearl-count)}\"(orange).|] [(< 0 (var 'thermal-count)) \"Thermal fluid: {(var 'thermal-count)}\"(orange).|] [(< 0 (var 'coolant-count)) \"Coolant liquid: {(var 'coolant-count)}\"(orange).]\"(light-gray, italic)
|?
| ~ cerebat-trader-quest
| | Nice, I'll take what you've got.
| ? (< 0 (var 'black-cap-count))
| | ! eval (setf (var 'black-cap-prev-count) (var 'black-cap-count))
| | ! eval (setf (var 'black-cap-count) (- (var 'black-cap-count) (min (var 'black-cap-count) (item-count 'item:mushroom-bad-1))))
| | ! eval (retrieve 'item:mushroom-bad-1 (min (var 'black-cap-prev-count) (item-count 'item:mushroom-bad-1)))
| ? (< 0 (var 'pure-water-count))
| | ! eval (setf (var 'pure-water-prev-count) (var 'pure-water-count))
| | ! eval (setf (var 'pure-water-count) (- (var 'pure-water-count) (min (var 'pure-water-count) (item-count 'item:pure-water))))
| | ! eval (retrieve 'item:pure-water (min (var 'pure-water-prev-count) (item-count 'item:pure-water)))
| ? (< 0 (var 'pearl-count))
| | ! eval (setf (var 'pearl-prev-count) (var 'pearl-count))
| | ! eval (setf (var 'pearl-count) (- (var 'pearl-count) (min (var 'pearl-count) (item-count 'item:pearl))))
| | ! eval (retrieve 'item:pearl (min (var 'pearl-prev-count) (item-count 'item:pearl)))
| ? (< 0 (var 'thermal-count))
| | ! eval (setf (var 'thermal-prev-count) (var 'thermal-count))
| | ! eval (setf (var 'thermal-count) (- (var 'thermal-count) (min (var 'thermal-count) (item-count 'item:thermal-fluid))))
| | ! eval (retrieve 'item:thermal-fluid (min (var 'thermal-prev-count) (item-count 'item:thermal-fluid)))
| ? (< 0 (var 'coolant-count))
| | ! eval (setf (var 'coolant-prev-count) (var 'coolant-count))
| | ! eval (setf (var 'coolant-count) (- (var 'coolant-count) (min (var 'coolant-count) (item-count 'item:coolant))))
| | ! eval (retrieve 'item:coolant (min (var 'coolant-prev-count) (item-count 'item:coolant)))
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
| | | The \"Wraw\"(orange).
| | | I'm supplying the Wraw aren't I.
| | | It's the only good thing to come from \"them moving in\"(orange), believe me. Though don't tell anyone I said that.
| | | So now you know.
| | | That's why you can't see the \"Council. There isn't one any more.\"(orange)
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
| | | \"Remaining quantities to find nearby are: [(< 0 (var 'black-cap-count)) \"Black cap mushrooms: {(var 'black-cap-count)}\"(orange).|] [(< 0 (var 'pure-water-count)) \"Purified water: {(var 'pure-water-count)}\"(orange).|] [(< 0 (var 'pearl-count)) \"Pearls: {(var 'pearl-count)}\"(orange).|] [(< 0 (var 'thermal-count)) \"Thermal fluid: {(var 'thermal-count)}\"(orange).|] [(< 0 (var 'coolant-count)) \"Coolant liquid: {(var 'coolant-count)}\"(orange).]\"(light-gray, italic)
")))
