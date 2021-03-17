; People tooltips that can be accessed throughout the entire game - this quest can never be completed; some interactions may alter based on world state conditions.
; Though maybe we add an achievement for finding and interacting with all of the people (across all the people quests/tasks)
(:name people-explore-region1-act1
 :title "Meet people"
 :description "I should find people to talk to - introduce myself, and find out about them."
 :invariant T
 :condition NIL
 :on-activate (catherine jack))

; have a different task file, or even whole quest, for each round of "hub" chat, as the story beats progress
(quest:interaction :name catherine :interactable catherine :repeatable T :dialogue "
~ catherine
| Hi I'm Catherine.
")

(quest:interaction :name jack :interactable jack :repeatable T :dialogue "
~ jack
| Hi I'm Jack.
")