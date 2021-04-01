(:identifier quest :version world-v0)
(:name q2-intro :author "Tim White"
 :title "Query Fi" :description "Catherine said Fi would like to talk to me."
 :on-activate (talk-to-fi)
 :tasks (#p"talk-to-fi.lisp")
)