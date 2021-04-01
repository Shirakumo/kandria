(:identifier quest :version world-v0)
(:name sq3-race :author "Tim White"
 :title "Timed Travel" :description "Catherine wants to see what I'm capable of. She's had Alex plant cans around the region for me to find and bring back. The faster I can do it, the more reward I'll get. I can unlock more routes by getting bronze times or better."
 :on-activate (race-hub)
 :tasks (#p"race-hub.lisp" #p"race-one.lisp" #p"race-two.lisp" #p"race-three.lisp" #p"race-four.lisp" #p"race-five.lisp" #p"race-one-return.lisp" #p"race-two-return.lisp" #p"race-three-return.lisp" #p"race-four-return.lisp" #p"race-five-return.lisp")
 :variables (race-1-gold race-1-silver race-1-bronze race-1-pb race-2-gold race-2-silver race-2-bronze race-2-pb race-3-gold race-3-silver race-3-bronze race-3-pb race-4-gold race-4-silver race-4-bronze race-4-pb race-5-gold race-5-silver race-5-bronze race-5-pb)
)