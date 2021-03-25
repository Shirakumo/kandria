(:name race-four
 :title "The can is... deep to the west, where people once dreamed."
 :description NIL
 :invariant T
 :condition (have 'can)
 :on-activate (spawn-can race-four-speech)
 :on-complete (race-four-return))
 
(quest:action :name spawn-can :on-activate (progn
                                             (setf (clock quest) 0)
											 (show (make-instance 'timer :quest quest))
                                             (spawn 'race-4-site 'can))
)

(quest:interaction :name race-four-speech :interactable race-4-site :repeatable T :dialogue "
~ player
| //This is the right place - the can must be close by.//
")