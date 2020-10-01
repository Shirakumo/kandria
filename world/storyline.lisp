(quest-graph:quest :name example :title "Example quest" :description "An example quest for the demo."
                   :effects (task-1))
(quest-graph:task :name task-1 :title "Inspect the camp" :description "Check the abandoned camp for clues."
                  :invariant T :condition all-triggered :triggers (tent-check fire-check))
(quest-graph:interaction :name tent-check :interactable tent :dialogue "
~ player
| The camp looks long abandoned. I wonder who lived here.")
(quest-graph:interaction :name fire-check :interactable fire :dialogue "
~ player
| The wood is cold and wet. No chance of lighting a fire now.
| The equipment still looks to be in good shape though. I wonder why they left.")
