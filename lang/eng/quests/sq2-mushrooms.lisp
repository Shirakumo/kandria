;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)
;; TODO store the target quantity in a variable, also used in the conditional? Then each time you talk to Catherine, she retrieves whatever you've got, and subtracts it from the variable for next time.
;; The android can then use inner monologue to reflect on exact quantities remaining. See q8a-secret-supplies as an example.
(quest:define-quest (kandria sq2-mushrooms)
  :author "Tim White"
  :title "Mushrooming"
  :description "Catherine wants me to gather mushrooms to help fill their food and textile reserves. Flower fungus and rusty puffball: yes. Black cap: no. She said at least 25 total should suffice."
  :on-activate (find-mushrooms)
  
  (find-mushrooms
   :title "Collect at least 25 flower fungus and/or rusty puffball mushrooms from underground, then return to Catherine in Engineering"
   :description NIL
   :invariant (not (complete-p 'q10-wraw))
   :condition (<= 25 (+ (item-count 'item:mushroom-good-1) (item-count 'item:mushroom-good-2)))
   :on-activate (sq2-reminder)
   :on-complete (return-mushrooms)

   (:interaction sq2-reminder
    :title "About the mushrooms."
    :interactable catherine
    :repeatable T
    :dialogue "
~ catherine
| How was your mushrooming? Oh, I don't think you've got enough yet.
| I need at least \"25 puffballs or flower fungus\"(orange). Keep \"searching underground\"(orange).
| (:excited)Good luck!
"))
  
  (return-mushrooms
   :title "Return to Catherine in Engineering and deliver the mushrooms"
   :marker '(catherine 500)
   :invariant (not (complete-p 'q10-wraw))
   :on-activate T
   (:interaction mushrooms-return
    :title "About the mushrooms."
    :interactable catherine
    :repeatable T
    :dialogue "
~ catherine
| How was your mushrooming? Let's see what you've got.
? (> 25 (+ (item-count 'item:mushroom-good-1) (item-count 'item:mushroom-good-2)) )
| | (:normal)Oh, I don't think you've got enough yet. I need \"25 puffballs or flower fungus\"(orange). Keep \"searching underground\"(orange).
| | (:excited)Good luck!
| < end
|? (= 25 (+ (item-count 'item:mushroom-good-1) (item-count 'item:mushroom-good-2)) )
| | (:excited)Wow, you got exactly what I asked for. I guess I shouldn't be surprised that you're so precise.
|? (< 25 (+ (item-count 'item:mushroom-good-1) (item-count 'item:mushroom-good-2)) )
| | (:cheer)Wow, you got even more than I asked for!
? (have 'item:mushroom-good-1)
| | (:excited)\"Flower fungus\"(red), nice! I'll get these to Fi and straight into the cooking pot.
| | (:normal)Apparently if you eat them raw they'll give you the skitters. One day I'll test that theory.
| ! eval (retrieve 'item:mushroom-good-1 T)
? (have 'item:mushroom-good-2)
| | (:cheer)\"Rusty puffball\"(red), great! These are my favourite - I made my neckerchief from them, believe it or not.
| | (:normal)I weaved them together with synthetic scraps; I needed a mask so their spores wouldn't give me lung disease.
| ! eval (retrieve 'item:mushroom-good-2 T)
? (have 'item:mushroom-bad-1)
| | (:disappointed)Oh, \"black cap\"(red)... Not a lot I can do with poisonous ones.
| | (:normal)Don't worry, I'll burn them later - don't want anyone eating them by accident.
| ! eval (retrieve 'item:mushroom-bad-1 T)
  
| (:normal)You know, it might not seem like much, but hauls like these could be the difference between us making it and not making it.
| We get birds, fish and bats when we can too, but they're harder to catch. Mushrooms don't run away.
| (:cheer)We owe you big time. Here, \"take these parts\"(orange), you've definitely earned them.
! eval (store 'item:parts 300)
| (:normal)If you \"find any more mushrooms\"(orange), make sure you grab them.
| If we don't need them, the least you could do is \"trade them with Sahil\"(orange).
| See you around, Stranger!
! eval (complete task)
! eval (setf (quest:status (thing 'return-mushrooms)) :inactive)
! eval (deactivate interaction)
# end
")))
