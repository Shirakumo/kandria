(:identifier quest :version world-v0)
(:name q2-seeds :author "Tim White"
 :title "Retrieve the seeds" :description "The settlement is low on food, and needs me to retrieve the last of the seeds from the cache they discovered."
 :on-activate (find-seeds)
 :tasks (#p"find-seeds.lisp" #p"return-seeds.lisp"))