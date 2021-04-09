(:identifier quest :version world-v0)
(:name sq2-mushrooms :author "Tim White"
 :title "Mushrooming" :description "Catherine asked me to forage for mushrooms beneath the camp. She asked for: 25 flower fungi and/or rusty puffballs; I should avoid: black knights"
 :on-activate (mushroom-sites)
 :tasks (#p"mushroom-sites.lisp" #p"return-mushrooms.lisp")
)