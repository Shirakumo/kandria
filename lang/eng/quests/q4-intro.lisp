;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q4-intro)
  :author "Tim White"
  :title "Speak With Fi"
  :description "She has new work for me."
  :on-activate (talk-to-fi)

  (talk-to-fi
   :title "Speak with Fi on the Farm"
   :condition all-complete
   :on-activate (talk-fi)
   :on-complete (q4-find-alex)
   (:interaction talk-fi
    :interactable fi
    :dialogue "
~ fi
| Alright, it's like this: The Wraw are almost certainly coming to reclaim us.
| But we cannot defend ourselves without knowing their plans: where they'll attack, and more importantly //when//.
| Alex was hunting in \"Cerebats territory\"(red), a faction of traders deeper underground, and might have the answers we need.
| (:unsure)But they've been gone a long time now. Too long.
| (:normal)I want you to \"find Alex and bring them back\"(orange) for debriefing.
| To reach the Cerebats township you'll need to get past the tech-witch \"Semi Sisters\"(red).
| We have good relations so it //should// be fine. They built the infrastructure that keeps us going, like the water pump and telephones.
| You can reach their land \"through the floor in the pump room\"(orange).
| But they've never seen an android before - not since before the Calamity, at least. Hopefully they'll play nice.
| If not... you'll have to improvise.
~ player
- Improvise?
  ~ fi
  | Are you familiar with the concept?...
  | (:unsure)I apologise: that came out wrong. I meant, can androids...?
  | (:shocked)It doesn't matter. I think you've answered this question lots of times already.
  | (:normal)I'm sorry I can't be more specific, but I don't know what resistance you'll face.
  | Be prepared for everything: social, and physical.
- I'll be fine.
  ~ fi
  | I believe you will.
- I was designed to do just that.
  ~ fi
  | You're a remarkable piece of-
  |(:shocked)... person. You're a remarkable //person//.
~ fi
| Is everything clear? You know what you need to do?
~ player
- It's clear.
  ~ fi
  | Excellent. 
  < end
- I have some questions.
  ~ fi
  | Of course.
  < questions
# questions
- Tell me about Alex.
  ~ fi
  | Alex is a hunter, like you. They've been with us from the beginning.
  | I hope you'll meet them soon - it would be nice for you to get to know them yourself.
  | Two hunters is a luxury. I'm excited to see what you can do together.
  < questions
- Tell me about the Semi Sisters.
  ~ fi
  | They're tech-witches, old enough to remember before the Calamity. They worked for Semi and a bunch of other megacorps.
  | They keep the water and power on in this whole area, and don't seem to mind if we siphon a little off.  
  | (:normal)Two sisters, \"Innis\"(yellow) and \"Islay\"(yellow), run the show. It would be best to avoid them for now.
  < questions
- Tell me about the Cerebats.  
  ~ fi
  | I suppose they're the closest thing the Valley has to a council.
  | They manage trade and arbitrate disputes between factions.
  | But I think most people know who's really calling the shots.
  | Perhaps I should be surprised that politics survived the apocalypse. (:annoyed)But I'm not.
  < questions
- Do you trust me yet?
  ~ fi
  | This is not the kind of mission for someone you don't trust.
  | Of course, you'd be right if you said I don't have a choice. No one else can do this.
  < questions
- I'm done.
  < end
# end
~ fi
| See Sahil if you haven't already, and stock up - it will be a long journey.
| Catherine tells me your FFCS works with our radios. You'll be deep underground, and I'd like you to keep in contact.
| As Alex has shown, falling off the grid isn't helpful.
| So please stay in touch - you can call me day or night.
")))
;; TODO Fi happy: I believe you will.
