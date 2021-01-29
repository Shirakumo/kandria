(:name talk-to-catherine
 :title "Talk to Catherine"
 :description "I should check in with Catherine."
 :invariant T
 :condition NIL
 :on-activate (talk))
(quest:interaction :name talk :interactable catherine :dialogue "
~ player
| Anything to do around here like fix the water supply?
~ fi
| (:unsure) Well, you could try a race!
~ player
| A... race? What do you mean?
~ fi
| (:normal) See how fast you can navigate these ruins.
~ player
- Alright, sounds fun!
  ~ fi
  | Well then, the clock starts... Now!  
- I'd rather not.
  ~ fi
  | Your choice. Come back if you change your mind.")
