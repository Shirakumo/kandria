(quest-graph:quest :name example :title "Example quest" :description "An example quest for the demo."
                   :effects (task-1))
(quest-graph:task :name task-1 :title "Inspect the camp" :description "Check the abandoned camp for clues."
                  :invariant T :condition quest:all-complete :triggers (tent-check fire-check sign-check corpse-check))
(quest-graph:interaction :name tent-check :interactable tent :dialogue "
~ player
| The tent looks tattered and old. It seems like nobody's been here for quite a while.
| Inside the tent there's a messy bedroll and litter strewn about... (:skeptical)Did they live like this?")
(quest-graph:interaction :name fire-check :interactable fire :dialogue "
~ player
| (:skeptical)The wood is cold and damp. No chance of lighting a fire now.
| The equipment still looks to be in good shape though. (:normal)Maybe they left for a hunt and never came back.")
(quest-graph:interaction :name sign-check :interactable sign :dialogue "
~ player
| The lettering is withered and worn down. It's hard to make the writing out. Let's see...
| \"Don't leave your trash around here! If I catch another one of you doing it I'll throw you off the cliff myself like the piece of garbage you are.\"
| Signed \"Harris\". (:giggle)Charming fellow!")
(quest-graph:interaction :name corpse-check :interactable corpse :dialogue "
~ player
| The skeleton is clutching a notebook. (:skeptical)Excuse me, skeleton...
| (:normal)\"I fucked up. I managed to narrowly escape the cave-in, but the tunnel shut behind me and now I'm stuck in this tiny cave.
| \"No way in hell am I gonna be able to dig out of here. What the fuck am I gonna do?
| \"I guess for now I should be happy I had my backpack with me. Enough to make a bed and a fire. I'll have to call for help tomorrow.
| \"It's so damn cold in here. My supplies are now out and nobody's been answering my calls. I guess this is it.
| \"Heh. I always knew things were fucked up, but I didn't think I'd end up like this. So pathetic.
| \"For a while I was doing well for myself. Got yourself an entire crew together, eh, Harris?
| \"Not much left of all of that now, huh. Fuck. If only I had listened to Sara.
| \"Sara...\"-/-The ink trails off and runs out.
| (:thinking)I wonder where the tunnel he came from used to lead.")
