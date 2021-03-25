(:name find-seeds
 :title "Find the seed cache beneath the ruins"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (seeds-arrive)
 :on-complete (return-seeds)
)

; enemies on this quest will be world NPCs, not spawned for the quest
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
; todo use a variable to track if you took none / destroyed, which could come back and bite you in the ass later (Alex finds out, and tries to frame you to cover his own tracks?) - log on the storyline
; todo use an exact technical unit/amount of pressure e.g. X pounds per inch (research)