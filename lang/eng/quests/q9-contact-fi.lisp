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
   :on-complete (q10-wraw q10-boss)

   (:interaction fi-ffcs-cerebat
    :interactable fi
    :dialogue "
~ player
| \"That should be far enough.\"(light-gray, italic)
| (:normal)Fi, are you there? Can you hear me?
~ fi
| Loud and clear. Where are you?
~ player
| Cerebat territory. The Council are gone. The Wraw have taken over.
~ fi
| ...
| What happened? Are you okay?
~ player
- I'm fine.
  ~ fi
  | (:happy)Good.
  | (:normal)So what's the situation?
- I helped the Wraw by mistake.
  ~ fi
  | What do you mean?
- I want to come home.
  ~ fi
  | First give me your report.
  ~ player
| I found a trader willing to talk - if I sourced him some supplies.
| I did, and that's when he told me. He also told me he's working for the Wraw.
~ fi
| (:annoyed)Ko nashi!
| Well, you couldn't have known.
| But now he's our enemy.
| ...
| (:unsure)What's Zelah up to?...
| (:normal)I'm sorry to send you \"deeper, but we really need to know what he's doing\"(orange).
| Can do you that? \"Go into Wraw territory\"(orange)?
~ player
- It's my job.
  ~ fi
  | (:happy)And you're very good at it.
- It'll be fun.
  ~ fi
  | (:unsure)I'm glad you enjoy your work. But this will be very dangerous. Please be careful.
- Do I have to?
  ~ fi
  | You always have a choice. But I need you to do this.
- I'll do it for you.
  ~ fi
  | (:happy)...
~ fi
| Your \"FFCS might not work down there\"(orange). But \"contact me as soon as you can\"(orange).
| Be safe.
! eval (deactivate (unit 'fi-ffcs-cerebat-1))
! eval (deactivate (unit 'fi-ffcs-cerebat-2))
")))
;; TODO enable trader as killable NPC - he'll move on soon anyway, so killing him will have negligible impact on gameplay, and is player's choice anyway
;; TODO move Zelah somewhere (offscreen?) to convey the Wraw are on the move
;; TODO also turn off "some" of Wraw base NPC spawners here, to show their numbers are thinning as most have departed for the surface (should player have come to Wraw territory before now); q11-recruit done further turns off spawners, leaving base completely empty
;; Ko nashi = bastard (Japanese)
;; Cannot give a reward here, as the player isn't in proximity to Fi. However, can sell stuff to the trader for parts.
