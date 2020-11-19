(:name find-android
 :title "Find the Android"
 :description "Locate the android rumoured to live in the mountain caves"
 :invariant T
 :condition quest:all-complete
 :on-activate (fi-check pot-check tent-check sign-main-check sign-check fire-check corpse-check))
(quest:interaction :name fi-check :interactable fi :dialogue "
~ fi
| (:annoyed)Next time I'll bring my climbing gear.
~ player
| Suit yourself. But this was your idea.
~ fi
| Tracking the android was my idea. Talking to Harris was my idea. Clinging to your back while you scale a cliff face - (:shocked)definitely not my idea.
~ player
| Well, we're here now. Should I proceed?
~ fi
| Okay, but I'm staying right here. Let me know what you find. And be careful.")
(quest:interaction :name pot-check :interactable pot :dialogue "
~ player
| (The cooking pot infers human habitation.
| (And this is a great spot for a lookout...)
| ! eval (activate 'fi-tent)
| ! eval (complete 'fi-check)
")
; | ! eval (let (fi-tent-talk true)) - works to set
(quest:interaction :name tent-check :interactable tent :dialogue "
~ player
| (There's no one inside, but the bedroll suggests it was recently occupied.)
| (Does an android need a bedroll? I sleep standing up.)
| ! eval (activate 'fi-tent)
| ! eval (complete 'fi-check)
")
; these error
; | ? (not 'fi-tent-talk = true)
; | ? (not 'fi-tent-talk)
; | ['fi-tent-talk | ! eval (activate 'fi-tent)]
(quest:interaction :name fi-tent :interactable fi :dialogue "
~ player
| I think we've got company.
~ fi
| The camp? I agree.
| Harris said these caves were deserted.
| [has-more-dialogue Did you find anything else? | Keep your eyes open.]
")
(quest:interaction :name sign-main-check :interactable sign-main :dialogue "
~ player
| (It's the same symbol I have on my uniform.)
| (Maybe it's a warning...) 
| ! eval (activate 'fi-sign-main)
| ! eval (complete 'fi-check)")
(quest:interaction :name fi-sign-main :interactable fi :dialogue "
~ player
| That sign over there has the same symbol on it as my uniform. I think it's something to do with androids.
~ fi
| Then we're on the right track.
~ player
| Actually, now I think about it, what does it also look like to you?
~ fi
| I don't know.
~ player
| An arrow. Pointing up over the mountain.
~ fi
| You could boost yourself up there. But I'm definitely staying right here.
| [has-more-dialogue You got more? | You'd better get going.]")
(quest:interaction :name sign-check :interactable sign :dialogue "
~ player
| (The words were scratched into the wood with a knife. I can barely read it. Upscaling resolution and enabling zoom...)
| READ ME - NO LITTER U FUCKS - BOTS PATROL HERE
| (Short and sweet, just like Harris.)
| ! eval (activate 'fi-sign)
| ! eval (complete 'fi-check)
")
(quest:interaction :name fi-sign :interactable fi :dialogue "
~ player
| I found a sign - looked and sounded like Harris. It warned of robots on patrol.
~ fi
| Rogues. They're not uncommon in caves like these. Like you but not as strong - and thankfully not as smart.
~ player
| Was that a compliment?
~ fi
| A fact.
| [has-more-dialogue Anything else? | Now get going.]")
(quest:interaction :name fire-check :interactable fire :dialogue "
~ player
| (The fire is still warm. They left very recently.)
| ! eval (activate 'fi-fire)
| ! eval (complete 'fi-check)
")
(quest:interaction :name fi-fire :interactable fi :dialogue "
~ player
| I found the remnants of another human camp. Recently vacated.
~ fi
| I think it's fair to say that Harris hasn't been completely honest with us.
~ player
| You think it's a trap.
~ fi
| Only one way to find out.
~ player
| Spring it? Lucky me.
~ fi
| You can handle yourself.
| [has-more-dialogue Next? | Sayonara.]")
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
