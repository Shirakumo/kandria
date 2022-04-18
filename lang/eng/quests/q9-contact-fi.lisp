;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q9-contact-fi)
  :author "Tim White"
  :title "Report to Fi"
  :description "I should get some distance from the Cerebat trader and contact Fi."
  :on-activate (contact-fi)
  
  (contact-fi
   :title "Leave the Cerebat trader then call Fi"
   :invariant T
   :condition all-complete
   :on-activate NIL
   :on-complete (q10-wraw)

   (:interaction fi-ffcs-cerebat
    :interactable fi
    :dialogue "
~ player
| \"That should be far enough.\"(light-gray, italic)
| (:normal)Fi, can you hear me?
~ fi
| Loud and clear. Where are you?
~ player
| Cerebat territory. The Council are dead. The Wraw have taken over.
~ fi
| ...
| What happened? Are you okay?
~ player
- I'm fine.
  ~ fi
  |(:happy)Good.
- I helped the Wraw by mistake.
  ~ fi
  | What do you mean?
- I want to come home.
  ~ fi
  | First give me your report.
~ player
| The council chamber is shuttered, but I found a trader willing to talk - if I sourced him some supplies.
| I did, and that's when he told me. He also told me he's working for the Wraw.
~ fi
| (:annoyed)Ko nashi!
| Well, you weren't to know.
| But now he's our enemy.
| ...
| (:unsure)What are the Wraw up to?...
| (:normal)I'm sorry to send you \"deeper, but I really need need to know what they're doing\"(orange).
| Can do you that?
~ player
- It's my job.
  ~ fi
  | (:happy)And you're very good at it.
- This will be fun.
  ~ fi
  | I'm glad you enjoy your work. But this will be very dangerous. Please be careful.
- Do I have to?
  ~ fi
  | You always have a choice. But I need you to do this.
- I'll do it for you.
  ~ fi
  | (:happy)...
~ fi
| Even your FFCS might not work down there.
| But \"contact me as soon as you can\"(orange) - even if that means returning to Cerebat territory to do so.
| Be safe.  
! eval (deactivate (unit 'fi-ffcs-cerebat-1))
! eval (deactivate (unit 'fi-ffcs-cerebat-2))
")))
;; TODO enable trader as killable NPC - he'll move on soon anyway, so killing him will have negligible impact on gameplay, and is player's choice anyway
;; TODO move Zelah somewhere (offscreen?) to convey the Wraw are on the move
;; Ko nashi = bastard (Japanese)
;; Cannot give a reward here, as the player isn't in proximity to Fi. However, can sell stuff to the trader for parts.
