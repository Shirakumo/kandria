(:name get-can
 :title "Get the can"
 :description "There's a leftover food can in the camp."
 :invariant T
 :condition (have 'can)
 :on-activate (spawn-can)
 :on-complete (return-can))
(quest:action :name spawn-can :on-activate (progn
                                             (show (make-instance 'timer :quest quest))
                                             (spawn 'camp 'can)))
