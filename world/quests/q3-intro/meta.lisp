(:identifier quest :version world-v0)
(:name q3-intro :author "Tim White"
 :title "Talk to Jack" :description "Fi said I could help Jack with something."
 :on-activate (talk-to-jack)
 :tasks (#p"talk-to-jack.lisp")
)