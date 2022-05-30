;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q8-meet-council)
  :author "Tim White"
  :title "Meet the Council"
  :description "Fi wants me to speak with the Cerebat Council, to see if they really have been taken over by the Wraw, as Innis claims."
  :on-activate (task-find)

  (task-find
   :title "Find the Cerebat Council, beneath Semi Sisters territory"
   :marker '(chunk-5549 1000)
   :invariant (not (complete-p 'q8a-secret-supplies))
   :condition NIL
   :on-activate (interact-reminder)
   :on-complete NIL

   (:interaction interact-reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
| Go and \"see the Cerebat Council beneath Semi Sisters territory\"(orange) - see what you can \"learn about the supposed Wraw takeover\"(orange).
")

  (:interaction player-council-chamber
    :interactable player
    :dialogue "
~ player
| \"This would seem to be the Cerebat Council chamber, but there's \"no Council\"(orange).\"(light-gray, italic)
? (not (active-p 'q8a-secret-supplies))
| | \"I should \"ask around, find out where they are\"(orange) - \"local traders might know something\"(orange).\"(light-gray, italic)
| ! eval (activate 'task-search)
|?
| | \"Looks like I'll need to \"give that trader what he wants to find out where they are\"(orange).\"(light-gray, italic)
| ! eval (activate 'task-search-hold)
"))

  (task-search-hold
   :title "Find the Cerebat Council, beneath Semi Sisters territory"
   :invariant (not (complete-p 'q8a-secret-supplies))
   :on-activate (interact-reminder)
   :condition NIL
   
   (:interaction interact-reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
| If the Council aren't there, you'll need to investigate. \"See if any of the Cerebat traders know anything\"(orange).
"))

  (task-search
   :title "Ask around the Cerebat traders to see if anyone knows where the Council are"
   :marker '(chunk-5527 2200)
   :invariant (not (complete-p 'q8a-secret-supplies))
   :condition NIL
   :on-activate (interact-reminder)
   :on-complete NIL

   (:interaction interact-reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
| If the Council aren't there, you'll need to investigate. \"See if any of the Cerebat traders know anything\"(orange).
")))