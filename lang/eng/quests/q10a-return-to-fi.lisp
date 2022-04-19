;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q10a-return-to-fi)
  :author "Tim White"
  :title "Contact Fi"
  :description "I need to warn Fi about the Wraw invasion of the valley."
  :on-activate (wraw-objective-return wraw-fi-ffcs)

  (wraw-objective-return
   :title "Leave Wraw territory and report to Fi by any means necessary"
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
   :visible NIL
   :condition (or (complete-p 'wraw-border) (complete-p 'station-trigger) (complete-p 'station-surface-trigger))
   :on-complete (wraw-fi-ffcs-functions)
   :on-activate T

   (:interaction wraw-border
    :interactable fi
    :dialogue "
~ player
| \"I've crossed the Cerebat border. I should be able to call Fi now.\"(light-gray, italic)
| Fi...
| Fi...?
| (:thinking)\"... Dammit. FFCS still can't punch through. I think the Wraw are on the move.\"(light-gray, italic)
| (:normal)\"I need to get \"back to the surface\"(orange). NOW.\"(light-gray, italic)")

   (:interaction station-trigger
    :interactable fi
    :dialogue "
~ player
| \"I'm out of Wraw territory. I should be able to call Fi now.\"(light-gray, italic)
| Fi...
| Fi...?
| (:thinking)\"... Dammit. FFCS still can't punch through. I think the Wraw are on the move.\"(light-gray, italic)
| (:normal)\"I need to get \"back to the surface\"(orange). NOW.\"(light-gray, italic)")

   (:interaction station-surface-trigger
    :interactable fi
    :dialogue "
~ player
| \"Home sweet home.\"(light-gray, italic)
| \"I should \"report to Fi about the impending Wraw invasion\"(orange) ASAP.\"(light-gray, italic)"))

  (wraw-fi-ffcs-functions
   :title ""
   :condition all-complete
   :on-activate NIL
   :on-complete (return-fi)
   :visible NIL
   (:action
      (deactivate 'wraw-objective-return)
      (setf (location 'fi) (location 'wraw-leader))
      (setf (direction 'fi) -1)
      (setf (location 'jack) (location 'fi-wraw))
      (setf (direction 'jack) 1)
      (setf (location 'catherine) (location 'islay-wraw))
      (setf (direction 'catherine) 1)
      (deactivate (unit 'wraw-border-1))
      (deactivate (unit 'wraw-border-2))
      (deactivate (unit 'wraw-border-3))
      (deactivate (unit 'station-east-lab-trigger))
      (deactivate (unit 'station-cerebat-trigger))
      (deactivate (unit 'station-semi-trigger))
      (deactivate (unit 'station-surface-trigger))
      (setf (location 'cerebat-trader-quest) (location 'cerebat-trader-wraw))
      (setf (direction 'cerebat-trader-quest) 1)))

  (return-fi
   :title "Return to the Noka camp ASAP to tell Fi about the Wraw invasion"
   :marker '(fi 500)
   :invariant T
   :condition all-complete
   :on-complete (q11-intro)
   :on-activate T

   (:interaction talk-fi
    :interactable fi
    :dialogue "
~ fi
| (:unsure){(nametag player)}, we've been waiting for you.
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
| (:unsure)...
| ... But why?
~ jack
| (:annoyed)To kill us all, or enslave us. Does it matter?!
~ fi
| (:unsure)I...
~ jack
| Fi?...
| (:annoyed)Fi, what do we do?
| (:shocked)... Fuck me. We need to get out of here.
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
| (:annoyed)Fuck me, the Wraw really have lost it if they wanna wipe out people who don't even exist.
~ catherine
| (:concerned)We don't know they don't exist. {(nametag player)}'s here, isn't she?
~ fi
| Androids in the mountains has been an age-old rumour.
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
  | Thank you, {(nametag player)}. You will be invaluable.
- I'll kill them all!
  ~ catherine
  | (:concerned)...
- I can't fight an army.
  ~ jack
  | (:annoyed)Then what are you good for?
  ~ catherine
  | (:disappointed)A helluva lot more than you!
  ~ jack
  | (:shocked)...
  | Cathy...
  ! eval (setf (var 'fight-army) T)
~ fi
| We must begin preparations immediately.
| Jack, get on the walkie and call everyone back to camp.
~ jack
| (:annoyed)So this is really happening... Well fuck.
~ fi
| Catherine, go to storage and assemble what weapons you can find.
~ catherine
| (:excited)On it!
~ fi
| I'll see what Sahil can do for us.
! eval (move-to 'check-supplies (unit 'catherine))
! eval (setf (walk 'jack) T)
! eval (move-to 'eng-jack (unit 'jack))
")))
;; no reward - it's battle stations. If player needs more currency here, they need to get it from sidequests and selling to traders.