(:identifier quest :version world-v0)
(:name q3-new-home :author "Tim White"
 :title "Find new home" :description "I need to find a potential new home for the settlement amongst the Ruins. My FFCS indicates four candidate locations."
 :on-activate (find-home-first find-home-second find-home-third find-home-fourth)
 :tasks (#p"find-home-first.lisp" #p"find-home-second.lisp" #p"find-home-third.lisp" #p"find-home-fourth.lisp"#p"return-new-home.lisp"))
; todo task order, as shown on UI, does not follow activation order