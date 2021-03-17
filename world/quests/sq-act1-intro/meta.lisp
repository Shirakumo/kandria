(:identifier quest :version world-v0)
(:name sq-act1-intro :author "Tim White"
 :title "Talk to Catherine" :description "I should catch up with Catherine, see if she needs anything doing."
 :on-activate (sq-act1-catherine)
 :tasks (#p"sq-act1-catherine.lisp")
)