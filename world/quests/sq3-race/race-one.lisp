(:name race-one
 :title "The can is... at a literal high point of EASTERN civilisation, now long gone."
 :description NIL
 :invariant T
 :condition (have 'can)
 :on-activate (spawn-can race-one-speech)
 :on-complete (race-one-return))
 
(quest:action :name spawn-can :on-activate (progn
                                             (setf (clock quest) 0)
                                             (show (make-instance 'timer :quest quest))
                                             (spawn 'race-1-site 'can)))

(quest:interaction :name race-one-speech :interactable race-1-site :repeatable T :dialogue "
~ player
| //This is the right place - the can must be close by.//
")
;; TODO: actually have a physical item? Harder to spot than a trigger prompt, and can't have collection dialogue otherwise (spawn happens approximate to site location)
;; trigger prompt also required to activate 'race-one-return without completing this task
