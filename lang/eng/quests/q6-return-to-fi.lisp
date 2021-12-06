;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q6-return-to-fi)
  :author "Tim White"
  :title "Return to Fi"
  :description "I should contact Fi and tell her about Alex."
  :on-activate (leave-semis)
  
  (leave-semis
   :title "Head out of Semi Sisters territory and contact Fi"
   :invariant T
   :condition all-complete
   :on-activate NIL
   :on-complete NIL

   (:interaction fi-ffcs
    :interactable fi
    :dialogue "
~ player
| \"I might as well call Fi from here. There's nowhere the Semis don't have eyes and ears.\"(light-gray, italic)
| (:normal)Hello Fi, it's me.
| (:skeptical)... Fi?
| (:thinking)\"Something's masking my FFCS.\"(light-gray, italic)
| \"I probably have Innis to thank for that.\"(light-gray, italic)
| (:normal)\"Alright, if they don't want me calling home, \"I'll go on foot\"(orange).\"(light-gray, italic)
| (:giggle)\"Or maybe I'll take the train.\"(light-gray, italic)
! eval (activate 'return-fi)
"))

  (return-fi
   :title "Return to the Noka camp and speak to Fi"
   :invariant T
   :condition all-complete
   :on-complete NIL
   :on-activate T

   (:interaction talk-fi
    :interactable fi
    :dialogue "
~ fi
| I was starting to get worried.
")))