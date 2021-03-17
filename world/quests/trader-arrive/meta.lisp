(:identifier quest :version world-v0)
(:name trader-arrive :author "Tim White"
 :title "Find the Trader" :description "Sahil the trader has arrived. I should speak with him."
 :on-activate (talk-trader)
 :tasks (#p"talk-trader.lisp"))
