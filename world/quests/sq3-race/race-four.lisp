(:name race-four
 :title "Find the Z at far distance"
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

(quest:interaction :name race-four-speech :interactable race-4-site :dialogue "
~ player
| //It's the race 4 item. I'd better hurry back to Catherine and log my time.//
")