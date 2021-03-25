(:name race-three
 :title "The can is... where we first ventured together, and got our feet wet."
 :description NIL
 :invariant T
 :condition (have 'can)
 :on-activate (spawn-can race-three-speech)
 :on-complete (race-three-return))
 
(quest:action :name spawn-can :on-activate (progn
                                             (setf (clock quest) 0)
											 (show (make-instance 'timer :quest quest))
                                             (spawn 'race-3-site 'can))
)

(quest:interaction :name race-three-speech :interactable race-3-site :repeatable T :dialogue "
~ player
| //This is the right place - the can must be close by.//
")