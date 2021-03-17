(:identifier quest :version world-v0)
(:name sq3-race :author "Tim White"
 :title "Timed travel" :description "Catherine wants to see what I'm capable of. She's planted objects in the ruins, and the faster I can retrieve them in, the more reward I'll get."
 :on-activate (race-hub)
 :tasks (#p"race-hub.lisp" #p"race-one.lisp" #p"race-two.lisp" #p"race-three.lisp" #p"race-four.lisp" #p"race-one-return.lisp" #p"race-two-return.lisp" #p"race-three-return.lisp" #p"race-four-return.lisp")
 :variables (race-1-gold race-1-silver race-1-bronze race-1-pb race-2-gold race-2-silver race-2-bronze race-2-pb race-3-gold race-3-silver race-3-bronze race-3-pb race-4-gold race-4-silver race-4-bronze race-4-pb)
)