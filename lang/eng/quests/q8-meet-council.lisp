;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q8-meet-council)
  :author "Tim White"
  :title "Meet the Council"
  :description "Fi wants me to speak with the Cerebat Council, to see if they really have been taken over by the Wraw, as Innis claims."
  :on-activate (task-1)

  (task-1
   :title "Find the Cerebat council chamber, beneath Semi Sisters territory"
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
")))