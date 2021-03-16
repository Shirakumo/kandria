(:identifier quest :version world-v0)
(:name trader-repeat :author "Tim White"
 :title "Trade" :description "If I want to trade items, I should find Sahil."
 :on-activate (trade-trader)
 :tasks (#p"trade-trader.lisp"))
