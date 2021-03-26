(:name find-seeds
 :title "Find the seed cache beneath the ruins"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (seeds-arrive)
 :on-complete (return-seeds))

;; enemies on this quest will be world NPCs, not spawned for the quest
;; REMARK: Should have a lead-in to explain stuff lying around already:
;;         "Containers and sacks of seeds are strewn about. Someone's been through here before."
;;         "Most of the stuff lying around seems spoiled, but some of the closed containers should still have usable seeds."
;; REMARK: The last option seems strange to me. Do we have consistent options throughout to be adversarial?
;;         Does that properly reflect in how the story develops? Does the stranger have a reason to be adversarial?
;;         Rephrasing it as something like "Somehow it doesn't feel right to take this stuff." seems a bit better at least.
(quest:interaction :name seeds-arrive :interactable cache :dialogue "
~ player
| //It's an old-world bunker. This must be the storage cache.//
| //It smells as old as it looks.//
| //There are 54 sachets inside this container. The seeds are inside them, tiny and hard like dead insects.//
| //Will they still grow?//
- //Take all the sachets.//
  | //I stow 54 sachets in my compartment.//
  ! eval (store 'seeds 54)
- //Take some of the sachets.//
  | //I stow 17 sachets in my compartment.//
  ! eval (store 'seeds 17)
- //Destroy the seeds.//
  | //I hold the sachets in my hands, several at a time, and exert pressure sufficient to crush them into particulates.//
  | //My hands feel warm with the pressure and friction.//
")
;; TODO: use a variable to track if you took none / destroyed, which could come back and bite you in the ass later (Alex finds out, and tries to frame you to cover his own tracks?) - log on the storyline
;; TODO: use an exact technical unit/amount of pressure e.g. X pounds per inch (research)
