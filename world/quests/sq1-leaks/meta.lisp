(:identifier quest :version world-v0)
(:name sq1-leaks :author "Tim White"
 :title "Repair the leaks" :description "Although the main water supply pipes have been repaired after the sabotage, there are always leaks to fix. Hopefully there'll be no surprises this time."
 :on-activate (leak-first leak-second leak-third)
 :tasks (#p"leak-first.lisp" #p"leak-second.lisp" #p"leak-third.lisp" #p"return-leaks.lisp"))
; todo task order, as shown on UI, does not follow activation order