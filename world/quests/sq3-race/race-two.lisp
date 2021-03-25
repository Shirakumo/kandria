(:name race-two
 :title "The can is... where a shallow grave marks the end of the line for the West Crossing."
 :description NIL
 :invariant T
 :condition (have 'can)
 :on-activate (spawn-can race-two-speech)
 :on-complete (race-two-return))
 
(quest:action :name spawn-can :on-activate (progn
                                             (setf (clock quest) 0)
											 (show (make-instance 'timer :quest quest))
                                             (spawn 'race-2-site 'can))
)

(quest:interaction :name race-two-speech :interactable race-2-site :repeatable T :dialogue "
~ player
| //This is the right place - the can must be close by.//
")