(:name talk-to-fi
 :title "Talk to Fi"
 :description "Check with Fi to see what's going on"
 :invariant T
 :condition NIL
 :on-activate (talk))
(quest:interaction :name talk :interactable fi :dialogue "
~ player
| Anything to do around here?
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
  ! eval (activate 'race)
- I'd rather not.
  ~ fi
  | Your choice. Come back if you change your mind.")
