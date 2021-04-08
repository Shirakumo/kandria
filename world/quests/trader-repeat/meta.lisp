(:identifier quest :version world-v0)
(:name trader-repeat :author "Tim White"
 :title "Trade" :description "If I want to trade items, I should find Sahil in the Midwest Market, beneath the Hub."
 :on-activate (trade-trader)
 :tasks (#p"trade-trader.lisp")
 :variables ((small-health-qty 10) (medium-health-qty 5) (large-health-qty 2))
)
