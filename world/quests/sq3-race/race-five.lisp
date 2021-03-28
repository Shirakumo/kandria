(:name race-five
 :title "The can is at... the furthest edge of the deepest cave in this region - there isn't much-room."
 :description NIL
 :invariant T
 :condition (have 'can)
 :on-activate (spawn-can race-five-speech)
 :on-complete (race-five-return))
 
(quest:action :name spawn-can :on-activate (progn
                                             (setf (clock quest) 0)
                                	     (show (make-instance 'timer :quest quest))
                                             (spawn 'race-5-site 'can)))

(quest:interaction :name race-five-speech :interactable race-5-site :repeatable T :dialogue "
~ player
| //This is the right place - the can must be close by.//
")
