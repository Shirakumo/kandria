;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q10a-return-to-fi)
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

   (:interaction wraw-border
    :interactable fi
    :dialogue "
~ player
| \"I've crossed the Cerebat border. I should be able to call Fi now.\"(light-gray, italic)
| Fi...
| (:skeptical)Fi...?
| (:thinking)\"... Dammit. FFCS still can't punch through. I think the Wraw are on the move.\"(light-gray, italic)
| \"I need to get \"back to the surface\"(orange) now.\"(light-gray, italic)
! eval (deactivate 'wraw-objective-return)
! eval (activate 'return-fi)
! eval (ensure-nearby 'outside-engineering 'fi 'jack 'catherine)
! setf (direction 'fi) 1
! setf (direction 'jack) 1
! setf (direction 'catherine) 1
! eval (deactivate (unit 'wraw-border-1))
! eval (deactivate (unit 'wraw-border-2))
"))
;; TODO move cerebat trader somewhere "off-screen"; if can't, then deactivate his chat and trade options, to essentially remove him from the story, perhaps move him into Wraw territory too - he's now part of the Wraw war effort. Could have him interact as a trader in Wraw territory too? Give the player some trade options in the depths? He's playing you against the Wraw for profit? You don't have to tell him that you're working against the Wraw, but he can just not want to ask any questions. Or keep trade up in region 1 and the surface with Sahil and Islay? So trading is done between trips to the depths?

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
| (:shocked)...
| ... But why?
~ jack
| (:annoyed)To kill us all, or enslave us. Does it matter?!
~ fi
| (:shocked)I...
~ jack
| Fi?...
| (:shocked)Fi, what do we do?
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