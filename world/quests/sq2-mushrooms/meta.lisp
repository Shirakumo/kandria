(:identifier quest :version world-v0)
(:name sq2-mushrooms :author "Tim White"
 :title "Mushrooming" :description "Catherine wants me to forage for mushrooms beneath the settlement: 25 flower fungi and/or rusty puffballs should do; avoid: black knights"
 :on-activate (mushroom-sites)
 :tasks (#p"mushroom-sites.lisp" #p"return-mushrooms.lisp")
)