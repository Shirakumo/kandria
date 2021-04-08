(:name find-seeds
 :title "Find the seed cache"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (seeds-arrive)
 :on-complete (return-seeds))

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
(quest:interaction :name seeds-arrive :interactable cache :dialogue "
~ player
| //It's an old-world bunker. This must be the storage cache.//
| //It smells as old as it looks. Containers and sacks of seeds are strewn about. Someone's been through here before.//
| //Most of this is spoiled, but some of the closed containers may still have usable seeds.//
| //Like this one: There are 54 sachets inside. The seeds are in wrappers, tiny and hard like dead insects.//
| //Will they still grow?//
| //I stow 54 sachets in my compartment.//
! eval (store 'seeds 54)
")
;; TODO: use a variable to track if you took none / destroyed, which could come back and bite you in the ass later (Alex finds out, and tries to frame you to cover his own tracks? - ties into the plot outline) - log as a var on the storyline
;; TODO: use an exact technical unit/amount of pressure e.g. X pounds per inch (research)

#| TODO removed option to destroy the seeds, logged here in case needed in the future beyond act 1, where a choice like this might be more suitable (e.g. doing a task for another faction, playing them off against one another, etc.)
- //Take all the sachets//
  | //I stow 54 sachets in my compartment.//
  ! eval (store 'seeds 54)
- //Take some of the sachets//
  | //I stow 17 sachets in my compartment.//
  ! eval (store 'seeds 17)
- //Destroy the seeds//
  | //Somehow it doesn't feel right to take them.//
  | //I hold the sachets in my hands, several at a time, and exert pressure sufficient to crush them into particulates.//
  | //My hands feel warm with the pressure and friction.//
|#