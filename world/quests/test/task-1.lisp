(:name inspect-camp
 :title "Inspect the camp"
 :description "Check the abandoned camp for clues."
 :invariant T
 :condition quest:all-complete
 :on-activate (tent-check fire-check sign-check corpse-check fi-check))
(quest:interaction :name tent-check :interactable tent :dialogue "
~ player
| The tent looks very tattered and old. It seems like nobody's been here for quite a while.
| Inside the tent there's a messy bedroll and litter strewn about... (:skeptical)Did they live like this?")
(quest:interaction :name fire-check :interactable fire :dialogue "
~ player
| (:skeptical)The wood is cold and damp. No chance of lighting a fire now.
| The equipment still looks to be in good shape though. (:normal)Maybe they left for a hunt and never came back.
! eval (activate 'fi-fire)")
(quest:interaction :name sign-check :interactable sign :dialogue "
~ player
| The lettering is withered and worn down. It's hard to make the writing out. Let's see...
| \"Don't leave your trash around here! If I catch another one of you doing it I'll throw you off the cliff myself like the piece of garbage you are.\"
| Signed \"Harris\". (:giggle)Charming fellow!
! eval (activate 'fi-sign)")
(quest:interaction :name corpse-check :interactable corpse :dialogue "
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
| (:thinking)I wonder where the tunnel he came from used to lead.
! eval (activate 'fi-corpse)")
(quest:interaction :name fi-check :interactable fi :dialogue "
~ fi
| (:annoyed)Why did you have to bring me along for this?
~ player
| You know people here better than anyone. If we find someone it's probably best if you talk to them.
| Plus you know better than me if there's anything worthwhile around to take back to camp.
~ fi
| (:unsure)... (:normal)Fine. Let me know if you find anything.")
(quest:interaction :name fi-sign :interactable fi :dialogue "
~ player
| It looks like this camp was initially home to a group of people. I only found evidence of one guy by the name of \"Harris\" though. That ring a bell?
~ fi
| Can't say it does. [has-more-dialogue Found anything else?|]")
(quest:interaction :name fi-fire :interactable fi :dialogue "
~ player
| I haven't found anyone at all yet, and it seems like the camp has been abandoned for quite a while. A few weeks or months, even.
| (:thinking)Still, there's a lot of equipment around that's largely in good condition, so it's not like they just up and left, and it's unlikely they got raided.
~ fi
| Curious. (:unsure) And I suppose you haven't found any other traces of their identity?
~ player
| (:skeptical)Nothing substantial, no.
? has-more-dialogue
| ~ fi
| | Is that all?")
(quest:interaction :name fi-corpse :interactable fi :dialogue "
~ player
| I found what appears to be the corpse of Harris. He got cut off from the rest of his group when a cave-in happened and starved to death.
~ fi
| (:shocked)---(:annoyed) So there's nothing for us here, huh.
~ player
| Looks like this was a bust, yeah. Sorry I dragged you all the way out here.
~ fi
| (:unsure)That's...(:normal) It's alright. At least we know for sure there used to be someone here for quite a while.
~ player
| (:thinking)I wonder where everyone else in this group went...")
