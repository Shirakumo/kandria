(:identifier quest :version world-v0)
(:name sq1-leaks :author "Tim White"
 :title "Repair More Leaks" :description "There are always new leaks to fix. My FFCS indicates that these ones aren't far from the surface, so I should follow the pipeline down. Hopefully there'll be no surprises this time."
 :on-activate (leak-first leak-second leak-third)
 :tasks (#p"leak-first.lisp" #p"leak-second.lisp" #p"leak-third.lisp" #p"return-leaks.lisp")
 :variables (first-leak)
)
;; TODO task order, as shown on UI, does not follow activation order