(:name ready-catherine
 :title "Talk to Catherine"
 :description "I should talk to Catherine when I'm ready to head to the leaking water pipes."
 :invariant T
 :condition NIL
 :on-activate (talk-catherine)
 :on-complete (follow-catherine-water))

(quest:interaction :name talk-catherine :interactable catherine :repeatable T :dialogue "
~ catherine
| You ready to go?
- I'm ready.
  ~ catherine
  | Alright. Stay close behind me.
  ! eval (lead 'player 'main-leak-1 (unit 'catherine))
  ! eval (walk-n-talk 'catherine-walktalk1)
  ! eval (deactivate interaction)
  ! eval (complete task)
- Not yet.
  ~ catherine
  | Alright, you can have a minute. But we need to hurry - the water supply isn't gonna fix itself.  
- Where are we going again?
  ~ catherine
  | Um, are you suffering from memory loss? We need to fix the water leak - before we lose the crop and everyone starves.
  - I don't need to eat.
    ~ catherine
    | Well the rest of us aren't so lucky. Aren't so unlucky, actually.
  - Ah, I remember now.
    ~ catherine
    | Good. Well...
  - My systems are currently sub-optimal.
    ~ catherine
    | Well, I'm not surprised. Though I don't think there's much I can do about that. Sorry.
  ~ catherine
  | Let me know when you're ready to head out. But we can't afford to wait long.
")

(quest:interaction :name catherine-walktalk1 :interactable catherine :dialogue "
! eval (complete 'catherine-walktalk1)
--
~ catherine
| Catch me if you can!
")

#| TEMP DIALOGUE REMOVAL

|#
