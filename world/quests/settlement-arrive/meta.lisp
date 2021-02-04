(:identifier quest :version world-v0)
(:name settlement-emergency :author "Tim White"
 :title "Emergency?" :description "Something seems amiss in this settlement."
 :on-activate (talk-to-catherine)
 :tasks (#p"tasks-settlement-arrive.lisp"))
