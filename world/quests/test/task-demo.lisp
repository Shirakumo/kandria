(:name find-android
 :title "Find the Android"
 :description "Locate the android rumoured to live in the mountain caves"
 :invariant T
 :condition quest:all-complete
 :on-activate (fi-check pot-check tent-check sign-main-check sign-check landslide-check fire-check beacon-check corpse-check cave-in-check android-check))
(quest:interaction :name fi-check :interactable fi :dialogue "
~ fi
| (:annoyed)Next time I'll bring my own climbing gear.
~ player
| Suit yourself. But this was your idea.
~ fi
| Tracking the android was my idea. Talking to Harris was my idea. Clinging to your back while you scale a vertical cliff face - (:shocked)definitely not my idea.
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
| (Does an android require a bedroll? I recharge standing up.)
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
(quest:interaction :name landslide-check :interactable landslide :dialogue "
~ player
| (There was a landslide here... That's a memory I could do without.)
| (And this is human blood. There must be another way around.)
| ! eval (activate 'fi-landslide)
| ! eval (complete 'fi-check)
")
; | ! eval (let (landslide true))
(quest:interaction :name fi-landslide :interactable fi :dialogue "
~ player
| There's been a landslide in the cave. I think there might be bodies underneath.
~ fi
| That's not unusual in itself, but given everything else about this place...
~ player
| I hope the android isn't buried under there as well.
~ fi
| Androids are tougher than they look.
~ player
| I don't look tough?
~ fi
| <smiles> I didn't say that.
| [has-more-dialogue Anything more? | Well this is awkward...]")
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
(quest:interaction :name beacon-check :interactable beacon :dialogue "
~ player
| (How'd this get all the way up here?)
| (Whoa. That's one helluva view across the desert. Somebody's thinking place?)
| ! eval (complete 'fi-check)
")


(quest:interaction :name corpse-check :interactable corpse :dialogue "
~ player
| (Human remains. Dismembered, and picked clean...)
| (Might have been an animal attack, or those rogue robots...)")
; \/ query if already know of landslide var, and tweak text e.g. "This is the other side of the landslide"
(quest:interaction :name cave-in-check :interactable cave-in :dialogue "
~ player
| (The cave collapsed here. I can see more bodies underneath.)
| (Scratches in the rocks suggest combat occurred here - swords, gunfire, and finger nails...)")
(quest:interaction :name android-check :interactable android :dialogue "
~ player
| (It's the android... It's been destroyed. Not even Catherine could fix this kind of damage.)
| Hello, sister... What happened to you?
| (More human remains... It appears you didn't go down without a fight.)
| (The memory replay seems to be intact.)
| Excuse me, sister... I just need to retrieve this... --- Thank you.
| I'd better get this back to Fi.)
! eval (activate 'fi-outcome)")
(quest:interaction :name fi-outcome :interactable fi :dialogue "
~ fi
| Is everything okay?
~ player
| I found the android.
~ fi
| Oh. I'm sorry. What happened?
~ player
| They're offline and irreparable.
| By the lay of the carnage in there, I think Harris and company ambushed them.
| They fought, and the cave destabilised and collapsed. The humans were killed then and there - all but one.
| I think the android then killed Harris - not just killed, but dismembered the poor bastard.
| They spent her final seconds crawling back into their home, where they died.
~ fi
| -- I'm so sorry.
| -- Perhaps they hoped to trick us, and seize you too.
~ player
| Perhaps.
~ fi
| I see you have the memory replay.
~ player
| *Holds the small metal chip aloft*
~ fi
| Let's go home. We'll see what it can tell us about the past.
")	