(:name task-1
 :title "Test task"
 :description "Whatever"
 :invariant T
 :condition NIL
 :on-activate (start))
(quest:interaction :name start :interactable catherine :dialogue "
~ catherine
| (:cheer) And here we are!
~ player
| (:skeptical) This is the camp?
~ catherine
| (:excited) Yep! Come with me, I'll show you the best thing you'll ever see!
! eval (activate (unit 'field))
! eval (lead 'player 'field 'catherine)
! eval (walk-n-talk 'walk)")
(quest:interaction :name walk :interactable catherine :dialogue "
-----
~ catherine
| (:normal) We haven't been up here for long, but it's really exciting!
| (:normal) The surface is so different from the underground.")
(quest:interaction :name field :interactable catherine :dialogue "
~ catherine
| (:excited) Check it out! Real crops!
~ player
| (:normal) Hmm. --- (:skeptical) Is that all?
~ catherine
| (:disappointed) Oh come on, you could be at least a little excited. Nobody else has grown anything here for ages!
| (:normal) Fine, be like that.--(:concerned) Alright, I have to go show you to jack.
! eval (lead 'player 'jack 'catherine)")
