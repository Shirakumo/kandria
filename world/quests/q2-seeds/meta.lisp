(:identifier quest :version world-v0)
(:name q2-seeds :author "Tim White"
 :title "Retrieve the Seeds" :description "The settlement are low on food, and need me to retrieve the last of the seeds from the cache they discovered. It's buried beneath the Ruins to the east."
 :on-activate (find-seeds)
 :tasks (#p"find-seeds.lisp" #p"return-seeds.lisp"))