(:name find-jack
 :title "Find Jack"
 :description "Follow Catherine into the building and find Jack."
 :invariant T
 :condition NIL
 :on-activate (catherine-to-jack))
 
(quest:action :name catherine-to-jack :on-activate (progn
(lead 'player 'jack 'catherine)
))