;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q2-seeds)
  :author "Tim White"
  :title "Retrieve the Seeds"
  :description "The settlement are low on food, and need me to retrieve the last of the seeds from the cache they discovered."
  :on-activate (find-seeds)

  (find-seeds
   :title "Find the seed cache across the surface to the east and beneath the Ruins, then return to Fi on the Farm"
   :marker '(chunk-2062 1000)
   :description NIL
   :invariant T
   :condition (have 'item:seeds 20)
   :on-activate (q2-reminder seeds-arrive)
   :on-complete (return-seeds)

   (:interaction q2-reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
| Travel \"across the surface to the east\"(orange) and beneath the \"Ruins - retrieve whatever seeds remain\"(orange) in the cache.
| Good luck, Stranger.
")

   ;; enemies on this quest will be world NPCs, not spawned for the quest
   ;; REMARK: Should have a lead-in to explain stuff lying around already:
   ;;         "Containers and sacks of seeds are strewn about. Someone's been through here before."
   ;;         "Most of the stuff lying around seems spoiled, but some of the closed containers should still have usable seeds."
   ;; TIM REPLY: Added this. I left it out, as I thought this ransacking would be clear from the visuals, and didn't want to repeat the obvious. Though I haven't seen the visuals yet. Doesn't hurt I guess for some extra emphasis here.
   ;; REMARK: The last option seems strange to me. Do we have consistent options throughout to be adversarial?
   ;;         Does that properly reflect in how the story develops? Does the stranger have a reason to be adversarial?
   ;;         Rephrasing it as something like "Somehow it doesn't feel right to take this stuff." seems a bit better at least.
   ;; TIM REPLY: I added the "somehow", as this help regardless. There are occasional adversarial options, usually just for flavour. Here my plan is that Alex could learn of this if you took the bad choice, and try and use it to frame you later. Right now it's just a hook, and it could be taken out later if it ends up leading to nothing.
   ;; TIM REPLY 2: From discussion with testers too, removed the adversarial options for now
   ;; TODO encode these retrieval quantities as global vars at the quest level, for use when returning the quest too
   (:interaction seeds-arrive
    :interactable cache
    :dialogue "
~ player
| \"It's an old-world bunker. This must be the storage cache.\"(light-gray, italic)
| \"It smells as old as it looks. Containers and sacks of seeds are strewn about. Someone's been through here before.\"(light-gray, italic)
| \"Most of this is spoiled, but some of the drawers may still house usable seeds. Let's see...\"(light-gray, italic)
| \"This is all that's left: \"24 sachets\"(orange). Inside each one the seeds are tiny and hard like grit.\"(light-gray, italic)
| (:thinking)\"Will they still grow? I guess we'll find out.\"(light-gray, italic)
| (:normal)\"I should \"return to Fi\"(orange).\"(light-gray, italic)
! eval (store 'item:seeds 24)
! eval (deactivate 'q2-reminder)
"))
  ;; TODO: use an exact technical unit/amount of pressure e.g. X pounds per inch (research)

  (return-seeds
   :title "Return to Fi on the Farm and deliver the seeds"
   :marker '(fi 500)
   :condition all-complete
   :on-activate T

   ;; enemies on this quest will be world NPCs, not spawned for the quest
   ;; REMARK: It feels a bit too soon for Fi to fully trust the stranger already.
   ;;         I think it would be better if she remarked positively about it and hinted at
   ;;         welcoming her into the group, but only making her an actual member in Act 2.
   ;;         Also gives the player something to look forward to and we can build it up
   ;;         to be a more impactful and rewarding moment.
   ;; TIM REPLY & TODO: Good point. Will leave this comment here as a reminder
   ;; REMARK: Also as you already mentioned in the other part, would be best if the lie
   ;;         options were gated behind a variable that is set in the other task if you
   ;;         don't take anything.
   ;; TIM REPLY: I thought it could be cool if you can take the seeds from the cache AND lie about it, so keep them for yourself. Perhaps if you later trade them in with Sahil, word gets back to Fi - could be a nice consequence
   (:interaction seeds-return-fi
    :interactable fi
    :dialogue "
~ fi
| You're back - did you find the seeds?
~ player
| I've got the last of them right here.
~ fi
! eval (retrieve 'item:seeds T)
| Oh my. There must be... twenty sachets. All fully stocked.
| You've done well. Very well. I'll see these are sown right away.
| This buys us hope I never thought we'd have.
| Know that you are earning my trust, Stranger. Perhaps you will become a part of the \"Noka\"(red) yourself.
| But for now, please \"accept these parts\"(orange) as a token of my appreciation.
! eval (retrieve 'item:semi-factory-key 1)
! eval (store 'item:parts 200)
~ fi
? (complete-p 'q3-new-home)
| ? (not (find :kandria-demo *features*))
| | | You should \"check in with Catherine\"(orange) - I'm sure she'd like to see you again.
| | | I think I know what I'd like you to do next as well. \"Let me know\"(orange) when you're ready.
| | ! eval (activate 'sq-act1-intro)
| | ! eval (activate 'q4-intro)
|?
| ? (not (active-p 'q3-new-home))
| | | Oh, I've also \"given Jack a special job\"(orange) - something I think you'll be well-suited to help with.
| | | He'll be in Engineering.
|   
| | I also heard \"Sahil is here - our trader friend\"(orange). His caravan is down in the Midwest Market, beneath the \"Zenith Hub\"(red).
| | You would be wise to equip well for your work.
| ! eval (activate 'trader-arrive)
")))

;; TODO: act 2 prelude too
;; player learns "Noka" for the first time
;; TODO fi happy - | Oh my. There must be... fifty sachets here. All fully stocked.

;; Removing key card unspoken, as it can't sound anything but negative at a positive time, if Fi takes it back. Also, there's nothing left of value in the cache now, so it can remain open, and undiscussed here (implied, save words)
