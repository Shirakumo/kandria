;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-task (kandria q1-water ready-catherine)
  :title "Talk to Catherine"
  :condition NIL
  :on-activate (talk-catherine)
  :on-complete (follow-catherine-water)

  (:interaction talk-catherine
   :interactable catherine
   :repeatable T
   :dialogue "
~ catherine
| You ready to go?
~ player
- I'm ready.
  ~ catherine
  | Alright. Stay close behind me.
  ! eval (lead 'player 'main-leak-1 (unit 'catherine))
  ! eval (walk-n-talk 'catherine-walktalk1)
  ! eval (deactivate interaction)
  ! eval (complete task)
- Not yet.
  ~ catherine
  | [? Alright, you can have a minute. | Okay but we need to hurry - the water supply isn't gonna fix itself. | Okay, but whatever you need to do, please be quick about it.]
- Where are we going again?
  ~ catherine
  | (:concerned)Um, did your short-term memory corrupt? We need to fix the water leak - before we lose the crop and everyone starves!
  ~ player
  - I don't need to eat.
    ~ catherine
    | Well the rest of us aren't so lucky. Aren't so unlucky, actually.
  - Ah, I remember now.
    ~ catherine
    | Good. Well...
  - My systems are currently sub-optimal.
    ~ catherine
    | Well, I'm not surprised. Though I don't think there's much I can do about that. Sorry.
  ~ catherine
  | Let me know when you're ready to head out. But we can't afford to wait too long.
")

  (:interaction catherine-walktalk1
   :interactable catherine
   :dialogue "
! eval (complete 'catherine-walktalk1)
--
~ catherine
| (:shout)Catch me if you can!
"))
