(:identifier quest :version world-v0)
(:name race :author "Nicolas Hafner"
 :title "Race for the clock!" :description "Try to find the item as quickly as possible!"
 :on-activate (get-can)
 :tasks (#p"get-can.lisp" #p"return-can.lisp"))
