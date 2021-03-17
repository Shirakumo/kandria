(:name race-two
 :title "Find the W at mid-distance"
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

(quest:interaction :name race-two-speech :interactable race-2-site :dialogue "
~ player
| //It's the race 2 item. I'd better hurry back to Catherine and log my time.//
")