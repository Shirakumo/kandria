(:name find-android
 :title "Find the Android"
 :description "Locate the android rumoured to live in the mountain caves"
 :invariant T
 :condition quest:all-complete
 :on-activate (fi-check pot-check tent-check sign-main-check sign-check landslide-check fire-check beacon-check corpse-check cave-in-check android-check home-check home-tent-check))
(quest:interaction :name fi-check :title "The mission" :interactable fi :dialogue "
? (complete-p 'android-check)
| ~ player
| | We found what we came for.
| ~ fi
| | And a lot more besides.
| | We can leave whenever you're ready. Though I'm not looking forward to the descent...
|?
| ~ fi
| | (:annoyed)Next time I'll bring my own climbing gear.
| ~ player
| | Suit yourself. But this was your idea.
| ~ fi
| | Tracking the android was my idea. Talking to Harris was my idea. Clinging to your back while you scale a vertical cliff face - (:shocked)definitely not my idea.
| ~ player
| | Well, we're here now. Can I proceed?
| ~ fi
| | You know you don't need to ask me that, of all people. But yes, you are permitted.
| | Though I'm staying right here. Let me know what you find. And be careful.
")
(quest:interaction :name pot-check :interactable pot :dialogue "
~ player
? (complete-p 'android-check)
| | I think Harris placed a lookout here. Perhaps watching for our approach.
|?
| | The cooking pot indicates human habitation.
| | And this is a great spot for a lookout.
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
(quest:interaction :name tent-check :interactable tent :dialogue "
~ player
? (complete-p 'android-check)
| | A person slept here.
|?
| | The android daily scrubbing routine takes minimal time. I don't think a bedroll is required.
| | (:thinking)Either this belongs to a person, or an android has adopted their behaviour... perhaps to blend in?
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
(quest:interaction :name sign-main-check :interactable sign-main :dialogue "
~ player
? (complete-p 'android-check)
| | I think the android made this, as a warning. In the end it was a mistake.
| ! eval (if (not (active-p 'fi-sign-main)) (activate 'fi-sign-main))
| ! eval (if (not (complete-p 'fi-sign-main)) (complete 'fi-sign-main))
|?
| | It's the mark for androids. This bodes well.
| ! eval (activate 'fi-sign-main)
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
;| ! eval (activate 'fi-sign-main) - can't reactivate a completed trigger
;| ! eval (complete 'fi-sign-main) - completing it a second time removes it from the extras menu? I think so
(quest:interaction :name fi-sign-main :title "The android sign" :interactable fi :dialogue "
? (complete-p 'android-check)
| ~ player
| | The sign over there with the android signifier on it - should we remove it?
| ~ fi
| | It won't hurt to leave it. If nothing else it's a fitting memorial.
| | And if it leads more like Harris into a death trap, then all the better.
| ~ player
| | Agreed.
|?
| ~ player
| | I've found a sign bearing the android signifier.
| ~ fi
| | Then we're going the right way.
| ~ player
| | Although... it's not painted in the correct color. Perhaps it has another meaning...
| | An arrow to indicate direction?
| ~ fi
| | (:unsure)I know you claim to be a detective, but now I think you're seeing things.
| | (:normal)I'll have Catherine give you a checkup when we get back.
| ~ player
| | (:skeptical)I'd rather she didn't.
| ~ fi
| | [has-more-dialogue You got more? | You'd better get going.]
")
(quest:interaction :name sign-check :interactable sign :dialogue "
~ player
? (complete-p 'android-check)
| | Harris scratched these words into the wood with a knife.
| | It says: //READ ME - NO LITTER U FUCKS - BOTS PATROL HERE//
| ! eval (if (not (active-p 'fi-sign)) (activate 'fi-sign))
| ! eval (if (not (complete-p 'fi-sign)) (complete 'fi-sign))
|?
| | The words were scratched into the wood with a knife. I can barely read it. Enhancing resolution...
| | //READ ME - NO LITTER U FUCKS - BOTS PATROL HERE//
| | Short and not so sweet - that's Harris.
| ! eval (activate 'fi-sign)
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
(quest:interaction :name fi-sign :title "Harris' message" :interactable fi :dialogue "
? (complete-p 'android-check)
| ~ player
| | It's a shame those rogues didn't get to Harris first.
| ~ fi
| | I know how you feel.
|?
| ~ player
| | There's a sign in the cave - looked and sounded like only Harris can. It warned of robots on patrol.
| ~ fi
| | Rogues... They're not uncommon in caves like these. I suppose they're androids, in a way, but have no mind of their own.
| | They're service drones, unlike you.
| ~ player
| | (:giggle)Was that a compliment?
| ~ fi
| | (:unsure)A fact.
| | [has-more-dialogue Anything else? | Now get going.]")
(quest:interaction :name landslide-check :interactable landslide :dialogue "
~ player
? (complete-p 'android-check)
| | The battle with the android probably caused this landslide too.
| | The mountain path is the alternative route.
| ! eval (if (not (active-p 'fi-landslide)) (activate 'fi-landslide))
| ! eval (if (not (complete-p 'fi-landslide)) (complete 'fi-landslide))
|?
| | A landslide... That's a memory I could do without.
| | (:thinking)There's human blood on the rock. I can't follow them through there - I need to find a way around.
| ! eval (activate 'fi-landslide)
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
(quest:interaction :name fi-landslide :title "The landslide" :interactable fi :dialogue "
? (complete-p 'android-check)
| ~ player
| | I think Harris' battle with the android caused the landslide.
| ~ fi
| | It wouldn't take much, with the instability of these caves.
| | Remember where we found you.
| ~ player
| | How could I forget.
|?
| ~ player
| | There's been a landslide in the cave.
| ~ fi
| | That's not unusual in these parts. But since everything else here feels wrong...
| ~ player
| | I hope the android isn't buried under there.
| ~ fi
| | Androids are tougher than they look.
| ~ player
| | (:giggle)I don't look tough?
| ~ fi
| | (:unsure)I didn't say that.
| | [has-more-dialogue Anything more? | Well this is awkward...]")
(quest:interaction :name fire-check :interactable fire :dialogue "
~ player
? (complete-p 'android-check)
| | This is where Harris made camp. The firewood is still warm.
| ! eval (if (not (active-p 'fi-fire)) (activate 'fi-fire))
| ! eval (if (not (complete-p 'fi-fire)) (complete 'fi-fire))
|?
| | A human camp. The fire is still warm.
| ! eval (activate 'fi-fire)
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
(quest:interaction :name fi-fire :title "The human camp" :interactable fi :dialogue "
? (complete-p 'android-check)
| ~ player
| | What should we do about Harris' camp?
| ~ fi
| | Leave it. Nature has a way of cleaning up after us.
|?
| ~ player
| | I found the remnants of another human camp, recently vacated.
| ~ fi
| | (:annoyed)I think it's fair to say Harris hasn't been completely honest with us.
| ~ player
| | (:skeptical)You think it's a trap?
| ~ fi
| | There's one way to find out.
| ~ player
| | Yes... Lucky me.
| ~ fi
| | You can handle yourself.
| | [has-more-dialogue Next? | Sayonara.]
")
(quest:interaction :name beacon-check :interactable beacon :dialogue "
~ player
? (complete-p 'android-check)
| | This was somebody's thinking place.
|?
| | How did this get all the way up here?
| | ... Look at that view...
| | (:thinking)Somebody's thinking place?
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
(quest:interaction :name corpse-check :interactable corpse :dialogue "
~ player
? (complete-p 'android-check)
| | The android did this.
|?
| | Remains: human. Dismembered, and already picked clean.
| | (:thinking)An animal attack? Or those rogue robots, perhaps.
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
(quest:interaction :name cave-in-check :interactable cave-in :dialogue "
~ player
? (complete-p 'android-check)
| | The cave collapsed during the battle, killing the people.
|?
| | The cave collapsed here. This is where the people came through - I can see more bodies underneath.
| | (:thinking)The scratches on the rocks suggest combat occurred: swords, gunfire, and finger nails...
| | Still no android.
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
(quest:interaction :name home-check :interactable home :dialogue "
~ player
? (complete-p 'android-check)
| | They made a home here. Who was Harris to take that away?
|?
| | (:thinking)Is this where the android lived?
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
(quest:interaction :name home-tent-check :interactable home-tent :dialogue "
~ player
? (complete-p 'android-check)
| | So some androids do sleep. I don't think this one did it to blend in, either.
| | (:thinking)Perhaps it brought them comfort.
|?
| | (:skeptical)If this was the android's home, then they appear to have used a bedroll.
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
(quest:interaction :name android-check :interactable android :dialogue "
~ player
? (or (active-p 'fi-outcome) (complete-p 'fi-outcome))
| | It's the android's remains.
|?
| | It's the android... or what's left of it.
| | I don't think even Catherine could put this back together...
| | Hello, sestra... What happened to you?
| | ... More human remains. It appears you didn't go down without a fight.
| | The Genera core seems to be intact.
| | Excuse me, sestra... I just need to retrieve this...
| | Thank you.
| | I'd better get this back to Fi.
| ! eval (activate 'fi-outcome)
| ! eval (if (active-p 'fi-sign-main) (complete 'fi-sign-main))
| ! eval (if (active-p 'fi-sign) (complete 'fi-sign))
| ! eval (if (active-p 'fi-landslide) (complete 'fi-landslide))
| ! eval (if (active-p 'fi-fire) (complete 'fi-fire))
! eval (if (not (complete-p 'fi-check)) (complete 'fi-check))
")
(quest:interaction :name fi-outcome :title "The android" :interactable fi :dialogue "
? (complete-p 'fi-outcome)
| ~ fi
| | I'm sorry about the android. At least we have their Genera core.
| | Catherine can examine the core once we get back.
|?
| ~ fi
| | Is everything okay?
| ~ player
| | I found the android.
| ~ fi
| | Oh... -- I'm so sorry...
| | What happened?
| ~ player
| | They're offline and irreparable.
| | By the lay of the carnage in there, I'd say Harris and company ambushed them.
| | They fought, and the cave destabilised and collapsed. The humans were killed in the cave in - all but one.
| | The android then killed Harris - not just killed him, but dismembered his body.
| | They spent their final seconds crawling back into their home, where they offlined.
| ~ fi
| | (:annoyed)-- You think Harris tricked us into coming here? To seize you too?
| ~ player
| | I don't know.
| ~ fi
| | Did you get the Genera core?
| ~ player
| | Right here.
| ~ fi
| | Alright, let's go home and see what we can learn about the past.
")