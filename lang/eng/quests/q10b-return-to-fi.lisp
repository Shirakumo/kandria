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
! eval (ensure-nearby 'outside-engineering 'fi 'jack 'catherine)
! setf (direction 'fi) 1
! setf (direction 'jack) 1
! setf (direction 'catherine) 1
! eval (setf (location 'islay) 'islay-main-loc)
! setf (direction 'islay) -1
! eval (deactivate (unit 'fi-ffcs-wraw-1))
! eval (deactivate (unit 'fi-ffcs-wraw-2))
"))
;; TODO move cerebat trader somewhere "off-screen"

  ;; TODO post-horizontal would also set chat dialogues here on Jack and Catherine, perhaps as a vehicle for sidequests, or just to catchup (or both)
  (return-fi
   :title "Return to the Noka camp ASAP to tell Fi about the Wraw invasion"
   :invariant T
   :condition all-complete
   :on-complete (q11-intro)
   :on-activate T

   (:interaction talk-fi
    :interactable fi
    :dialogue "
~ fi
| (:unsure){#@player-nametag}, we've been waiting for you.
| That you didn't contact me remotely fills me with dread. What did you find?
~ player
- The Wraw are coming.
  ~ jack
  | (:annoyed)We know that already.
- They've built an invasion army.
  ~ fi
  | ...
  ~ catherine
  | (:concerned)Oh my god.
- They're coming for the entire valley.
  ~ fi
  | What do you mean the entire valley?
~ player
| They've built enough mechs and power-suited soldiers to take this entire valley by force.
| And given I couldn't use my FFCS in Cerebat territory, I think they're on the march.
~ fi
| (:shocked)...
| I...
~ jack
| (:shocked)Fi?...
| Fi, what do we do?
| ... Fuck me. We need to get out of here.
~ catherine
| (:concerned)And go where exactly?
| We've got old people and kids to think about.
~ player
- There might be somewhere...
  ~ fi
  | Where?
- I interfaced with one of their mechs...
  ~ jack
  | (:annoyed)Spare us your sordid sex life android.
  ~ fi
  | (:annoyed)__JACK!__ Not now!
  | (:normal)Go on...
- Do androids live in the mountains?
  ~ jack
  | (:annoyed)Oh boy here we go.
  ~ fi
  | Why do you ask?
~ player
| I found mention of what sounded like a faction of androids, the \"Genera\", living in the mountains to the west.
| I think it was a directive for their mechs, to destroy them too.
~ jack
| (:annoyed)Fuck me, they really have lost it if they want to wipe out people who don't even exist.
~ catherine
| (:concerned)We don't know they don't exist. {#@player-nametag}'s here, isn't she?
~ fi
| There's been a long-held rumour about the mountains.
| But I don't think we can stake our future on it - the desert is impassable, never mind the mountains.
~ jack
| (:annoyed)Then we're fucked. Pure and simple.
~ catherine
| (:concerned)...
~ fi
| Not yet. Not while we can still fight.
~ jack
| (:shocked)... Fight?! What, against Wraw soldiers and mechs?
| It's suicide. They'll cut us to ribbons and eat what's left.
~ catherine
| It's not suicide - we have an android.
~ fi
| (:unsure)...
~ player
- I'm ready to fight.
  ~ fi
  | Thank you, {#@player-nametag}. You will be invaluable.
- I'll take them all on!
  ~ catherine
  | (:excited)You can! I know you can!
- I can't fight an army.
  ~ jack
  | (:annoyed)Then what are you good for?
  ~ catherine
  | (:disappointed)A helluva lot more than you!
  ~ jack
  | (:shocked)...
  | Cathy...
~ fi
| We must begin preparations immediately.
| Jack, get on the walkie and call everyone back to camp.
~ jack
| So this is really happening... Well fuck.
~ fi
| Catherine, go to storage and assemble what weapons you can find.
~ catherine
| (:excited)On it!
! eval (move-to 'check-supplies (unit 'catherine))
! eval (setf (walk 'jack) T)
! eval (move-to 'eng-jack (unit 'jack))
")))