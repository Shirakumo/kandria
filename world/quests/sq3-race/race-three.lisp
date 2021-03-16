(:name race-three
 :title "Find the Y at mid-distance"
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

(quest:interaction :name race-three-speech :interactable race-3-site :dialogue "
~ player
| //It's the race 3 item. I'd better hurry back to Catherine and log my time.//
")