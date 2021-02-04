(:identifier quest :version world-v0)
(:name settlement-emergency :author "Tim White"
 :title "Emergency?" :description "Something's wrong - the one that reactivated me, Catherine, doesn't look happy. I'd better talk to her."
 :on-activate (talk-to-catherine)
 :tasks (#p"task-talk-catherine.lisp"))
