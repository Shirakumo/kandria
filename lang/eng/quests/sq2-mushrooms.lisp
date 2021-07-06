;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)
;; TODO FIX this quest completes after first task interaction, when it should remain open and be completed manually later
(quest:define-quest (kandria sq2-mushrooms)
  :author "Tim White"
  :title "Mushrooming"
  :description "Catherine asked me to forage for mushrooms beneath the camp. She needs at least: 25 flower fungi and/or rusty puffballs; I should avoid: black caps"
  :on-activate T
  (return-mushrooms
   :title "Find mushrooms and return to Catherine when I have enough"
   :on-activate T
   (:interaction mushrooms-return
    :title "About the mushrooms."
    :interactable catherine
    :repeatable T
    :dialogue "
~ catherine
| How was your mushrooming? Let's see what you've got.
? (> 25 (+ (item-count 'item:mushroom-good-1) (item-count 'item:mushroom-good-2)) )
| | (:normal)Oh, I don't think you've got enough yet. Keep searching underground though.
| | (:excited)Good luck!
| < end
|? (= 25 (+ (item-count 'item:mushroom-good-1) (item-count 'item:mushroom-good-2)) )
| | (:excited)Wow, you got exactly what I asked for. I guess I shouldn't be surprised that you're so precise.
|? (< 25 (+ (item-count 'item:mushroom-good-1) (item-count 'item:mushroom-good-2)) )
| | (:cheer)Wow, you got even more than I asked for!
? (have 'item:mushroom-good-1)
| | (:excited)Flower fungus, nice! I'll get these to Fi and straight into the cooking pot.
| | (:normal)Apparently if you eat them raw they'll give you the skitters. One day I'll test that theory.
| ! eval (retrieve 'item:mushroom-good-1 T)
? (have 'item:mushroom-good-2)
| | (:cheer)Rusty puffball, great! These are my favourite - I made my neckerchief from them, believe it or not.
| | (:normal)I weaved them together with synthetic scraps; I needed a mask so their spores wouldn't give me lung disease.
| ! eval (retrieve 'item:mushroom-good-2 T)
? (have 'item:mushroom-bad-1)
| | (:disappointed)Oh, you got some black caps huh? Not a lot I can do with poisonous ones.
| | (:normal)Don't worry, I'll burn them later - don't want anyone eating them by accident.
| ! eval (retrieve 'item:mushroom-bad-1 T)
  
| (:normal)You know, it might not seem like much, but hauls like these could be the difference between us making it and not making it.
| (:cheer)We owe you big time. Here, take these parts, you've definitely earned them.
! eval (store 'item:parts 30)
| (:normal)If you find any more mushrooms, make sure you grab them too!
| If we don't need them, then the least you could do is trade them with Sahil.
| See you around, Stranger!
! eval (complete task)
! eval (setf (quest:status (thing 'return-mushrooms)) :inactive)
! eval (deactivate interaction)
# end
")))
