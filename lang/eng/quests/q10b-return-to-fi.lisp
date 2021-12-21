;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q10b-return-to-fi)
  :author "Tim White"
  :title "Contact Fi"
  :description "I need to warn Fi about the Wraw invasion of the entire valley."
  :on-activate (wraw-objective-return wraw-fi-ffcs)

  (wraw-objective-return
   :title "Return to Cerebat territory so I can reach Fi with my FFCS"
   :invariant T
   :condition all-complete
   :on-activate (objective)
   :on-complete NIL
   
   (:interaction objective
    :interactable player
    :dialogue "
    "))

  (wraw-fi-ffcs
   :title ""
   :invariant T
   :condition all-complete
   :on-activate NIL
   :on-complete NIL
   :visible NIL

   (:interaction fi-ffcs-wraw
    :interactable fi
    :dialogue "
~ player
| \"I've crossed the Cerebat border. I should be able to call Fi now.\"(light-gray, italic)
| Fi...
| (:skeptical)Fi...?
| (:thinking)\"FFCS still can't punch through. I think the Wraw are on the move.\"(light-gray, italic)
| \"I need to get \"back to the surface\"(orange) and quickly.\"(light-gray, italic)
! eval (deactivate 'wraw-objective-return)
! eval (activate 'return-fi)
! eval (deactivate (unit 'fi-ffcs-wraw-1))
! eval (deactivate (unit 'fi-ffcs-wraw-2))
"))

  (return-fi
   :title "Return to the Noka camp ASAP to tell Fi about the Wraw invasion"
   :invariant T
   :condition all-complete
   :on-complete ()
   :on-activate T

   (:interaction talk-fi
    :interactable fi
    :dialogue "
~ fi
Return dialogue
")))