(:name find-jack
 :title "Find Jack"
 :description "I should follow Catherine into that building and find Jack."
 :invariant T
 :condition all-complete
 :on-activate (talk-jack)
 :on-complete (q1-water))
 
 ; meet Jack for the first time - Stranger already presumes this is Jack
(quest:interaction :name talk-jack :interactable jack :dialogue "
~ jack
| ... Don't give me that bullshit. Where the hell have you been? And who's this?
~ catherine
| What do you mean? I've brought back the android... I got her working!
~ jack
| Jesus... this is all we need.
~ player
- Pleased to meet you.
- Jack, I presume.
- Is everything okay?
~ jack
| Well fuck me it speaks... Though what the hell is that accent?
~ Catherine
| Jack, what's wrong? Talk to me.
~ Jack
| The water has failed again, and this time it ain't the pumps. Must be a leak somewhere.
| If we don't get it back ASAP we're fucked. We'll lose the whole goddamn crop.
~ Catherine
| Shit!... I should have been here.
~ jack
| Yeah you should.
~ catherine
| Well I'm here now. What can I do?
~ jack
| You can stay put and man engineering. Fi and the others might need you.
| I'm goin' down there to check the supply pipes.
~ catherine
| You can't - not with your leg. And you know there's nothing I can't fix. Let me go.
~ jack
| No way. It's too dangerous.
~ catherine
| The android can come with me. You should see what she can do! She's got a freakin' sword!
~ jack
| A sword?... Have you lost your goddamn mind? An android ain't no toy!
| You'd be safer walking unarmed straight into Wraw territory than you would goin' anywhere with that thing.
~ player
- I can protect her.
  ~ jack
  | The hell you can.
- Why are you afraid of me?
  ~ jack
  | Androids don't exactly grow on trees. And some say you're the reason there aren't no trees anymore. Or buildings.
  | Or people.
- You're right to be afraid.
  ~ catherine
  | She's kidding... Aren't you?!
~ catherine
| Look, everyone knows the old stories. But they're just stories - this is real life.
| We need to fix the water right now or we're goners. And I'm you're best shot.
| Me AND my android buddy.
~ jack
| Fuck...
| Alright. You'd better not let me down.
~ catherine
| Yes!!
~ jack
| But I'm warning you android. You touch one hair on her head and I'll bury you for another fifty years!
~ catherine
| Thanks \"Dad\". Alright, let's go.
~ jack
| Hold on Cathy - take this walkie. Radio if you have any trouble.
~ catherine
| I will. And don't worry - we'll be back ASAP.
")

#| DIALOGUE REMOVED FOR TESTING SPEED - talk-jack



|#