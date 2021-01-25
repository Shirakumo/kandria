(:name return-can
 :title "Return the can"
 :description "I should show the can to Fi so she can time me."
 :invariant T
 :condition all-complete
 :on-activate (show-can))
(quest:interaction :name show-can :interactable fi :dialogue "
! eval (hide-panel 'timer)
~ player
| Here you go.
~ fi
| Alright, let's see...
| It took you {(format-relative-time (clock quest))}!
? (< (clock quest) 10)
| | (:shocked)How did you do that so fast?
|? (< (clock quest) 30)
| | That's pretty quick!
|? (< (clock quest) 60)
| | (:unsure)Not bad.
|?
| | (:annoyed)I think you can do better than that.")
