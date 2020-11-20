(:name find-android
 :title "Find the Android"
 :description "Locate the android rumoured to live in the mountain caves"
 :invariant T
 :condition quest:all-complete
 :on-activate (fi-check pot-check tent-check sign-main-check sign-check landslide-check fire-check beacon-check corpse-check cave-in-check android-check home-check home-tent-check))
(quest:interaction :name fi-check :interactable fi :dialogue "
~ fi
| (:annoyed)Next time I'll bring my own climbing gear.
~ player
| Suit yourself. But this was your idea.
~ fi
| Tracking the android was my idea. Talking to Harris was my idea. Clinging to your back while you scale a vertical cliff face - (:shocked)definitely not my idea.
~ player
| Well, we're here now. Can I proceed?
~ fi
| You know you don't need to ask me that, of all people? But yes, you are permitted.
| Though I'm staying right here. Let me know what you find. And be careful.")
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
| Harris said these caves were deserted.
| [has-more-dialogue Did you find anything else? | Keep your eyes open.]
")
(quest:interaction :name sign-main-check :interactable sign-main :dialogue "
~ player
| (It's the same symbol that I have on my uniform.)
| (Perhaps it's a warning...) 
| ! eval (activate 'fi-sign-main)
| ! eval (complete 'fi-check)")
(quest:interaction :name fi-sign-main :interactable fi :dialogue "
~ player
| That sign over there has the same symbol on it as my uniform. I think it has something to do with androids.
~ fi
| Then we're on the right track.
~ player
| It also resembles an arrow, don't you think? Pointing up over the mountain?
~ fi
| I know you want to be a detective, but now I think you're seeing things.
| Remind me to check your pattern recognition software when we get back.
| [has-more-dialogue You got more? | You'd better get going.]")
(quest:interaction :name sign-check :interactable sign :dialogue "
~ player
| (The words were scratched into the wood with a knife. I can barely read it. Upscaling resolution and enabling zoom...)
| //READ ME - NO LITTER U FUCKS - BOTS PATROL HERE//
| (Short and not so sweet - that's Harris.)
| ! eval (activate 'fi-sign)
| ! eval (complete 'fi-check)
")
(quest:interaction :name fi-sign :interactable fi :dialogue "
~ player
| There's a sign in the cave - looked and sounded like only Harris can. It warned of robots on patrol.
~ fi
| Rogues... They're not uncommon in caves like these. They're like you but not as strong - and thankfully not as smart.
~ player
| Was that a compliment?
~ fi
| A fact.
| [has-more-dialogue Anything else? | Now get going.]")
(quest:interaction :name landslide-check :interactable landslide :dialogue "
~ player
| (A landslide... That's a memory I could do without.)
| (There's human blood on the rock. I can't follow them through there - I need to find another way around.)
| ! eval (activate 'fi-landslide)
| ! eval (complete 'fi-check)
")
; | ! eval (let (landslide true))
(quest:interaction :name fi-landslide :interactable fi :dialogue "
~ player
| There's been a landslide in the cave.
~ fi
| That's not unusual in these parts. But given that everything else seems wrong about this place...
~ player
| I hope the android isn't buried under there.
~ fi
| Androids are tougher than they look.
~ player
| I don't look tough?
~ fi
| *Smiles* I didn't say that.
| [has-more-dialogue Anything more? | Well this is awkward...]")
(quest:interaction :name fire-check :interactable fire :dialogue "
~ player
| (The fire is still warm. They left recently.)
| ! eval (activate 'fi-fire)
| ! eval (complete 'fi-check)
")
(quest:interaction :name fi-fire :interactable fi :dialogue "
~ player
| I found the remnants of another human camp. Recently vacated.
~ fi
| I think it's fair to say that Harris hasn't been completely honest with us.
~ player
| You think it's a trap?
~ fi
| There's one way to find out.
~ player
| Yes... Lucky me.
~ fi
| You can handle yourself.
| [has-more-dialogue Next? | Sayonara.]")
(quest:interaction :name beacon-check :interactable beacon :dialogue "
~ player
| (How did this get all the way up here?)
| (... Look at that view... Somebody's thinking place?)
| ! eval (complete 'fi-check)
")
(quest:interaction :name corpse-check :interactable corpse :dialogue "
~ player
| (Remains: human. Dismembered, and already picked clean.)
| (An animal attack? Or those rogue robots, perhaps.)
| ! eval (complete 'fi-check)
")
; \/ query if already know of landslide var, and tweak text e.g. "This is the other side of the landslide"
(quest:interaction :name cave-in-check :interactable cave-in :dialogue "
~ player
| (The cave collapsed here. This is where the humans came through - I can see more bodies underneath.)
| (The scratches in the rocks suggest combat occurred - swords, gunfire, and finger nails...)
| ! eval (complete 'fi-check)
")
(quest:interaction :name android-check :interactable android :dialogue "
~ player
| (It's the android... It's been destroyed. Not even Catherine could fix this kind of damage.)
| Hello, sestra... What happened to you?
| (More human remains. It appears you didn't go down without a fight.)
| (The memory replay seems to be intact.)
| Excuse me, sestra... I just need to retrieve this... --- Thank you.
| (I'd better get this back to Fi.)
| ! eval (complete 'fi-check)
| ! eval (activate 'fi-outcome)")
(quest:interaction :name home-check :interactable home :dialogue "
~ player
| (They made a home here. Who was Harris to take that away?)
| ! eval (complete 'fi-check)
")
(quest:interaction :name home-tent-check :interactable home-tent :dialogue "
~ player
| (Androids do use bedrolls. At least, this one did.)
| ! eval (complete 'fi-check)
")
(quest:interaction :name fi-outcome :interactable fi :dialogue "
~ fi
| Is everything okay?
~ player
| I found the android.
~ fi
| Oh... -- I'm so sorry...
| What happened?
~ player
| They're offline and irreparable.
| By the lay of the carnage in there, I'd say Harris and company ambushed them.
| They fought, and the cave destabilised and collapsed. The humans were killed in the cave in - all but one.
| The android then killed Harris - not just killed him, but dismembered him.
| They spent their final seconds crawling back into their home, where they offlined.
~ fi
| -- You think Harris tricked us into coming here? To seize you too?
~ player
| Perhaps.
~ fi
| I see you have the memory replay.
~ player
| *Holds the small metal chip aloft*
~ fi
| Let's go home. We'll see what it can tell us about the past.
")