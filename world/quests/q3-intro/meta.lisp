(:identifier quest :version world-v0)
(:name q3-intro :author "Tim White"
 :title "Talk to Jack" :description "It's been intimated that I could help Jack with something."
 :on-activate (talk-to-jack)
 :tasks (#p"talk-to-jack.lisp")
)