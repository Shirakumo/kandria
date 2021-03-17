(:identifier quest :version world-v0)
(:name q1-water :author "Tim White"
 :title "Fix the water supply" :description "The settlement are on the brink of starvation, and will loose their crop (and themselves) if the water supply isn’t restored."
 :on-activate (ready-catherine)
 :tasks (#p"task-ready-catherine.lisp" #p"task-follow-catherine-water.lisp" #p"task-return-home.lisp"))
