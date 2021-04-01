(:identifier quest :version world-v0)
(:name q4-find-allies :author "Tim White"
 :title "Find Allies" :description "The Noka need allies if they are to survive this world, and their old faction the Wraw."
 :on-activate (find-ally)
 :tasks (#p"find-ally.lisp"))