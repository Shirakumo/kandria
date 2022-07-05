;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q0-settlement-arrive)
  :author "Tim White"
  :title "Follow Catherine"
  :description "Catherine wants to show me something."
  (:go-to (farm-view-intro :lead catherine)
   :title "Follow Catherine")
  ;; TODO: force complete 'walk to ensure this whole task completes, even if walk-talk interrupted?
  ;; REMARK: It's confusing that you don't talk to catherine and instead have to find some hidden trigger volume.
  ;;         It would be better if this was activated on catherine as soon as the player walks into the farm
  ;;         by using a story-trigger, or even just directly activating it via an interaction-trigger.
  ;; TW: Don't colour code "android" here; yes it's the first time it's made explicit to the player; but they can figure it out themselves by now or soon after (boosting in earlier tutorial, reading steam blurb, and it's explained more soon after when talking to Jack)
  (:interact (catherine :now T)
   "~ catherine
| (:excited)What did I tell you? Incredible, right!
~ player
- Crops? In a desert?
  ~ catherine
  | (:excited)Isn't it amazing.
  | (:normal)...
  | (:disappointed)Well don't look too excited. Growing these \"post-Calamity\"(red) is a real feat, believe me.
- How did you manage this?
  ~ catherine
  | (:normal)Don't ask me - I'm just an engineer. I helped install the irrigation though.
  | Needless to say, growing crops \"post-Calamity\"(red) isn't easy.
  | (:excited)Heh, I knew you'd be impressed.
- I've seen these before. Lots of times.
  ~ catherine
  | (:normal)Oh, from before the \"Calamity\"(red)? I bet they had loads of plantations. We don't have many.
  | (:excited)That's so cool. I wish I could have seen that too.
~ catherine
| (:concerned)Erm, hang on a second. Where is everyone?
| This isn't the welcome I was expecting.
~ player
- Is something wrong?
  ~ catherine
  | (:concerned)I just reactivated an \"old-world\"(red) android. I guess I thought they'd all be here to see you.
- What were you expecting?
  ~ catherine
  | (:concerned)I don't know...
  | Though I just reactivated an \"old-world\"(red) android. I guess I thought everyone would be here to see you.
- Is it me?
  ~ catherine
  | (:concerned)You?... No of course not.
  | ... I mean, (:excited)I think you're amazing - a working android from the \"old world\"(red).
  | (:normal)But not everyone has fond tales to tell about androids, I guess. Their loss though.
  | But I'm sure it's not that.
~ catherine
| (:concerned)We'd better find \"Jack\"(yellow). He'll be in \"Engineering\"(red).
! eval (activate 'q0-find-jack)
 "))
;; learn Jack's name for the first time