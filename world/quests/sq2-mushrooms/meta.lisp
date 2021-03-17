(:identifier quest :version world-v0)
(:name sq2-mushrooms :author "Tim White"
 :title "Mushrooming" :description "Catherine wants me to forage for mushrooms beneath the settlement: 25 honey fungus and/or dusky puffball; Avoid: the grey knight"
 :on-activate (mushroom-sites)
 :tasks (#p"mushroom-sites.lisp" #p"return-mushrooms.lisp")
)