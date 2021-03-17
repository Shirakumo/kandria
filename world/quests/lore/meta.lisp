(:identifier quest :version world-v0)
(:name lore :author "Tim White"
 :title "The World" :description "This world is unfamiliar to me. I should explore and learn more about it."
 :on-activate (lore-explore-region1)
 :tasks (#p"tasks-lore-region1.lisp"))
