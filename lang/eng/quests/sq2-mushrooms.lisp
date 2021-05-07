;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria sq2-mushrooms)
  :author "Tim White"
  :title "Mushrooming"
  :description "Catherine asked me to forage for mushrooms beneath the camp. She asked for: 25 flower fungi and/or rusty puffballs; I should avoid: black knights"
  :on-activate (mushroom-sites)

  (mushroom-sites
   :title "Find mushrooms"
   :on-activate T
   ;; //[? Here's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.] [? They look much more appetising on a plate. | People eat this stuff? | It looks and smells like mould. I suppose it's the same thing, more or less. | It looks like someone's insides if they were on the outside.]//
   (:interaction mushrooms1
    :interactable shrooms1
    :repeatable T
    :variables (batch1 batch2)
    :dialogue "
~ player
| //[? It's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.]//
- [(not (var 'batch1)) //Take 6 flower fungi//|]
  | I pick 6 flower fungi and stow them in my internal compartment.
  | They're quite pretty. It seems a shame to eat them.
  ! eval (store 'mushroom-good-1 6)
  ! eval (setf (var 'batch1) T)
  < ending
- [(not (var 'batch2)) //Take 1 rusty puffball//|]
  | I pick 1 rusty puffball.
  | (:giggle)They make clothes out of these? Call me a fashion victim but I wouldn't be seen dead in them.
  ! eval (store 'mushroom-good-2 1)
  ! eval (setf (var 'batch2) T)
  < ending
- //Take none//

# ending
? (and (var 'batch1) (var 'batch2))
| ! eval (deactivate 'mushrooms1)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
")
   ;; once player has collected some, activate return to Catherine dialogue if not already active
   ;; TODO: allow player to drop/destroy any they've collected that they don't want? Though that could break the quest if they accidentally drop good ones, and can't pick them up again - would equal auto failure. If always get same reward, doesn't matter either, just affects hand-in dialogue

   (:interaction mushrooms2
    :interactable shrooms2
    :repeatable T
    :variables (batch1 batch2 batch3)
    :dialogue "
~ player
| //[? It's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.]//
- [(not (var 'batch1)) //Take 3 flower fungi//|]
  | I pick 3 flower fungi.
  | People eat this stuff?
  ! eval (store 'mushroom-good-1 3)
  ! eval (setf (var 'batch1) T)
  < ending
- [(not (var 'batch2)) //Take 7 rusty puffballs//|]
  | I pick 7 rusty puffballs.
  | They look and smell like mould. I suppose it's the same thing, more or less.
  ! eval (store 'mushroom-good-2 7)
  ! eval (setf (var 'batch2) T)
  < ending
- [(not (var 'batch3)) //Take 2 black knights//|]
  | I pick 2 black knights and stow them in my compartment.
  | (:thinking)They remind me of decaying frogspawn. Yet I've never seen decaying frogspawn...
  ! eval (store 'mushroom-bad-1 2)
  ! eval (setf (var 'batch3) T)
  < ending
- Take none

# ending
? (and (var 'batch1) (var 'batch2) (var 'batch3))
| ! eval (deactivate 'mushrooms2)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
")

   (:interaction mushrooms3
    :interactable shrooms3
    :repeatable T
    :variables (batch1 batch2)
    :dialogue "
~ player
| //[? It's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.]//
- [(not (var 'batch1)) //Take 4 rusty puffballs//|]
  | I pick 4 rusty puffballs and stow them in my compartment.
  ! eval (store 'mushroom-good-2 4)
  ! eval (setf (var 'batch1) T)
  < ending
- [(not (var 'batch2)) //Take 5 flower fungi//|]
  | I pick 5 flower fungi.
  ! eval (store 'mushroom-good-1 5)
  ! eval (setf (var 'batch2) T)
  < ending
- Take none

# ending
? (and (var 'batch1) (var 'batch2))
| ! eval (deactivate 'mushrooms3)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
")

   ;; TODO move back to little nook to the bottom right of the Hub near shroom1, if crawl interacts supported?
   (:interaction mushrooms4
    :interactable shrooms4
    :repeatable T
    :variables (batch1 batch2 batch3)
    :dialogue "
~ player
| //[? It's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.]//
- [(not (var 'batch1)) //Take 4 flower fungi//|]
  | I pick 4 flower fungus.
  ! eval (store 'mushroom-good-1 4)
  ! eval (setf (var 'batch1) T)
  < ending
- [(not (var 'batch2)) //Take 10 black knights//|]
  | I pick 10 black knights.
  ! eval (store 'mushroom-bad-1 10)
  ! eval (setf (var 'batch2) T)
  < ending
- [(not (var 'batch3)) //Take 5 rusty puffballs//|]
  | I pick 5 rusty puffballs and stow them in my compartment.
  | (:skeptical)I suppose truffles would be too much to ask for.
  ! eval (store 'mushroom-good-2 5)
  ! eval (setf (var 'batch3) T)
  < ending
- Take none

# ending
? (and (var 'batch1) (var 'batch2) (var 'batch3))
| ! eval (deactivate 'mushrooms4)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
")

   (:interaction mushrooms5
    :interactable shrooms5
    :repeatable T
    :variables (batch1 batch2 batch3)
    :dialogue "
~ player
| //[? It's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.]//
- [(not (var 'batch1)) //Take 8 black knights//|]
  | I pick 8 black knights and stow them in my compartment.
  | They look like someone's insides if they were on the outside. That's probably what they'd do to you too.
  ! eval (store 'mushroom-bad-1 8)
  ! eval (setf (var 'batch1) T)
  < ending
- [(not (var 'batch2)) //Take 9 rusty puffballs//|]
  | I pick 9 rusty puffballs.
  | Why do they look like alien parasites from an old B-movie?
  ! eval (store 'mushroom-good-2 9)
  ! eval (setf (var 'batch2) T)
  < ending
- [(not (var 'batch3)) //Take 6 flower fungi//|]
  | I pick 6 flower fungi.
  ! eval (store 'mushroom-good-1 6)
  ! eval (setf (var 'batch3) T)
  < ending
- Take none

# ending
? (and (var 'batch1) (var 'batch2) (var 'batch3))
| ! eval (deactivate 'mushrooms5)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
"))

  (return-mushrooms
   :title "I've collected enough mushrooms for Catherine"
   :condition all-complete
   :on-activate T

   (:interaction mushrooms-return
    :title "Return the mushrooms"
    :interactable catherine
    :dialogue "
~ catherine
| How was your mushrooming? Let's see what you've got.
? (= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| | (:excited)Wow, you got exactly what I asked for. I guess I shouldn't be surprised that you're so precise.
|? (< 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| | (:cheer)Wow, you got even more than I asked for!
? (have 'mushroom-good-1)
| | (:excited)Flower fungus, nice! I'll get these to Fi and straight into the cooking pot.
| | (:normal)Apparently if you eat them raw they'll give you the skitters. One day I'll test that theory.
| ! eval (retrieve 'mushroom-good-1 (item-count 'mushroom-good-1))
? (have 'mushroom-good-2)
| | (:cheer)Rusty puffball, great! These are my favourite - I made my neckerchief from them, believe it or not.
| | (:normal)Though that was just so I had a mask, so their spores wouldn't give me lung disease.
| ! eval (retrieve 'mushroom-good-2 (item-count 'mushroom-good-2))
? (have 'mushroom-bad-1)
| | (:disappointed)Oh, you got some black knights huh? Not a lot I can do with them.
| | (:normal)Don't worry, I'll burn them later - don't want anyone eating them by accident.
| ! eval (retrieve 'mushroom-bad-1 (item-count 'mushroom-bad-1))
  
| (:normal)You know, it might not seem like much, but hauls like these could be the difference between us making it and not making it.
| (:cheer)We owe you big time. Here, take these parts, you've definitely earned them.
| (:normal)See you around, Stranger!
! eval (store 'parts 10)
! eval (deactivate 'mushrooms-return)
? (not (complete-p 'mushroom-sites))
| ! eval (complete 'mushroom-sites)
")))
