;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria sq1-leaks)
  :author "Tim White"
  :title "Repair New Leaks"
  :description "There are new leaks to fix; I should follow the red pipeline down. Hopefully there'll be no surprises this time. My FFCS detects three locations."
  :on-activate (leak-first leak-second leak-third task-sq1-reminder)
  :variables (first-leak)

 (task-sq1-reminder
   :title "Talk to Catherine if I need a reminder"
   :visible NIL
   :on-activate T
   (:interaction sq1-reminder
    :title "About the new leaks."
    :interactable catherine
    :repeatable T
    :dialogue "
~ catherine
| \"Follow the red pipeline\"(orange) down like we did before and you'll find the new leaks.
~ player
| \"My FFCS indicates \"three leaks\"(orange), all close to the surface.\"(light-gray, italic)
"))

  (leak-first
   :title "Find the first leak"
   :condition all-complete
   :on-activate T

   (:action start-leak
    (setf (animation (unit 'leak-1)) 'short-spray))

   (:interaction leak-1
    :interactable leak-1
    :dialogue "
~ player
| \"//There's a hole in the pipe - probably caused by duress where it bends around this corner.//\"(light-gray)
? (not (var 'first-leak))
| | \"//I ignite the torch from the index finger on my right hand.//\"(light-gray)
| | [(var 'q1-weld-burn) (:embarassed)\"//This time I enable the UV filters on my cameras.//\"(light-gray) | (:normal)\"//I enable the UV filters on my cameras.//\"(light-gray)]
| | (:normal)\"//Weld complete.//\"(light-gray)
| ! eval (setf (animation (unit 'leak-1)) 'normal)
| ? (have 'item:walkie-talkie)
| | | \"//I turn on the walkie-talkie. It's heavy for such a simple piece of technology.//\"(light-gray)
|  
| | Catherine, I've sealed one of the leaks. [(have 'item:walkie-talkie) Over.|]
| ~ catherine
| | Great work - the pressure is much better already.
| | \"Keep going\"(orange) - let me know if you hit any trouble. [(have 'item:walkie-talkie) Over and out.|]
| ! eval (setf (var 'first-leak) T)
|?
| | \"//Weld complete.//\"(light-gray)
| ! eval (setf (animation (unit 'leak-1)) 'normal)
? (complete-p 'leak-second 'leak-third)
| ~ player
| | Catherine, I think I got the last leak. [(have 'item:walkie-talkie) Over.|]
| ~ catherine
| | (:cheer)You did it - pressure is returning! That's a job well done. [(have 'item:walkie-talkie) Over.|]
| | (:normal)Any sign of sabotage? [(have 'item:walkie-talkie) Over.|]
| ~ player
| - No, all clear.
|   ~ catherine
|   | That's what I like to hear.
| - It was all subsidence, or wear and tear.
|   ~ catherine
|   | Oh man, you probably don't need reminding about landslides - sorry!
| ~ catherine
| | (:excited)\"Hurry back\"(orange), I've got a little something for you. [(have 'item:walkie-talkie) Over and out.|]
| ! eval (deactivate 'task-sq1-reminder)
| ! eval (activate 'return-leaks)
"))
  ;; TODO: how does FFCS communicate with Catherine? Catherine still needs to use walkie and "over"? Yes, but FFCS removes need for "over" as it can control things dynamically remotely
  ;; UNUSED: and a sprawl of soil and stones - subsidence caused this.

  (leak-second
   :title "Find the second leak"
   :condition all-complete
   :on-activate T

   (:action start-leak
     (setf (animation (unit 'leak-2)) 'long-spray))

   (:interaction leak-2
    :interactable leak-2
    :dialogue "
~ player
| \"//The pipe has split.//\"(light-gray)
| \"//There's no subsidence, but it's close to Catherine's previous repair - I wonder if she accidentally damaged the pipe.//\"(light-gray)
? (not (var 'first-leak))
| | \"//I ignite the torch from the index finger on my right hand.//\"(light-gray)
| | [(var 'q1-weld-burn) (:embarassed)\"//This time I enable the UV filters on my cameras.//\"(light-gray) | (:normal)\"//I enable the UV filters on my cameras.//\"(light-gray)]
| | (:normal)\"//Weld complete.//\"(light-gray)
| ! eval (setf (animation (unit 'leak-2)) 'normal)
| ? (have 'item:walkie-talkie)
| | | \"//I turn on the walkie-talkie. It's heavy for such a simple piece of technology.//\"(light-gray)
|  
| | Catherine, I've sealed one of the leaks. [(have 'item:walkie-talkie) Over.|]
| ~ catherine
| | Great work - the pressure is much better already.
| | \"Keep going\"(orange) - let me know if you hit any trouble. [(have 'item:walkie-talkie) Over and out.|]
| ! eval (setf (var 'first-leak) T)
|?
| | \"//Weld complete.//\"(light-gray)
| ! eval (setf (animation (unit 'leak-2)) 'normal)
? (complete-p 'leak-first 'leak-third)
| ~ player
| | Catherine, I think I got the last leak. [(have 'item:walkie-talkie) Over.|]
| ~ catherine
| | (:cheer)You did it - pressure is returning! That's a job well done. [(have 'item:walkie-talkie) Over.|]
| | (:normal)Any sign of sabotage? [(have 'item:walkie-talkie) Over.|]
| ~ player
| - No, all clear.
|   ~ catherine
|   | That's what I like to hear.
| - It was all subsidence, or wear and tear.
|   ~ catherine
|   | Oh man, you probably don't need reminding about landslides - sorry!
| ~ catherine
| | (:excited)\"Hurry back\"(orange), I've got a little something for you. [(have 'item:walkie-talkie) Over and out.|]
| ! eval (deactivate 'task-sq1-reminder)
| ! eval (activate 'return-leaks)
"))

  (leak-third
   :title "Find the third leak"
   :condition all-complete
   :on-activate T

   (:action start-leak
    (setf (animation (unit 'leak-3)) 'long-spray-rythmic))

   (:interaction leak-3
    :interactable leak-3
    :dialogue "
~ player
| \"//The pipe is ruptured, like an artery oozing blood.//\"(light-gray)
| \"//The ground feels uncannily unstable, like I've been in this situation before.//\"(light-gray)
? (not (var 'first-leak))
| | \"//I ignite the torch from the index finger on my right hand.//\"(light-gray)
| | [(var 'q1-weld-burn) (:embarassed)\"//This time I enable the UV filters on my cameras.//\"(light-gray) | (:normal)\"//I enable the UV filters on my cameras.//\"(light-gray)]
| | (:normal)\"//Weld complete.//\"(light-gray)
| ! eval (setf (animation (unit 'leak-3)) 'normal)
| ? (have 'item:walkie-talkie)
| | | \"//I turn on the walkie-talkie. It's heavy for such a simple piece of technology.//\"(light-gray)
|  
| | Catherine, I've sealed one of the leaks. [(have 'item:walkie-talkie) Over.|]
| ~ catherine
| | Great work - the pressure is much better already.
| | \"Keep going\"(orange) - let me know if you hit any trouble. [(have 'item:walkie-talkie) Over and out.|]
| ! eval (setf (var 'first-leak) T)
|?
| | \"//Weld complete.//\"(light-gray)
| ! eval (setf (animation (unit 'leak-3)) 'normal)
? (complete-p 'leak-first 'leak-second)
| ~ player
| | Catherine, I think I got the last leak. [(have 'item:walkie-talkie) Over.|]
| ~ catherine
| | (:cheer)You did it - pressure is returning! That's a job well done. [(have 'item:walkie-talkie) Over.|]
| | (:normal)Any sign of sabotage? [(have 'item:walkie-talkie) Over.|]
| ~ player
| - No, all clear.
|   ~ catherine
|   | That's what I like to hear.
| - It was all subsidence, or wear and tear.
|   ~ catherine
|   | Oh man, you probably don't need reminding about landslides - sorry!
| ~ catherine
| | (:excited)\"Hurry back\"(orange), I've got a little something for you. [(have 'item:walkie-talkie) Over and out.|]
| ! eval (deactivate 'task-sq1-reminder)
| ! eval (activate 'return-leaks)
"))

  (return-leaks
   :title "Return to Catherine in Engineering"
   :condition all-complete
   :on-activate T

   (:interaction leaks-return
    :title "About the leaks."
    :interactable catherine
    :dialogue "
~ catherine
| (:cheer)The water pressure is back! I knew you could do it.
| (:normal)Here, \"take these parts\"(orange) - you've earned them.
! eval (store 'item:parts 150)
? (have 'item:walkie-talkie)
| | I'll take the walkie back for now in case someone else needs it.
| ! eval (retrieve 'item:walkie-talkie 1)
| | Bet it was weird using such archaic technology.
| ~ player
| - I liked it.
| - Never again.
|   ~ catherine
|   | Oh, that bad huh?
| - It did the job.
|  
~ catherine
| Well, you can definitely scratch water leaks off your bucket list, right?
")))

;; TODO if don't have the walkie, but you took it (so you've sold it to Sahil), should she say something? Or just not comment or forget? Doing so would get you into hot water about lying, etc. which we might not want in act 1 (we removed similar things from the seed quest). If we did it, would need to set a var during any of the leaks tasks, based on whether you have the walkie or not; can't set on first receiving the walkie, as it's in another quest (act 1 hub), unless used a global var...
#|
TODO is it okay that Catherine breaks off convo here, and to access more sidequests you need to click on here again? What if on returning to her, you want to discuss another quest before handing this one in? Or you have multiple to hand in?
should be able to choose which ones you want to hand in and in what order? but the necessary var checks to accomodate those options would mean all these sidequests need housing under a single quest folder, and all their tasks list would overlap
- could use var checks? though they only check hierarchical, not between tasks?
Also means that sq return dialogues cannot be repeatable - having to fire once only, to then allow user to get back to sq hub
|#
