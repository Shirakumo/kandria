(:name talk-to-catherine
 :title "Talk to Catherine"
 :description "The one that reactivated me, Catherine, doesn't look happy. I'd better talk to her."
 :invariant T
 :condition NIL
 :on-activate (talk))

(quest:interaction :name talk :interactable catherine :dialogue "
~ catherine
| This isn't the welcome I was expecting.
~ player
- Is something wrong?
  | ~ catherine
  | Well, for a start where is everyone? I just reactivated an android!
  | I thought everyone would be here to see you.
- What were you expecting?
  | ~ catherine
  | I don't know... Though I just reactivated an android...
  | I guess I thought everyone would be here to see you.
- Is it me?
  | ~ catherine
  | You?... I suppose it could be.
  | I mean, I think you're amazing - a working android from the old world!
  | But not everyone has fond tales to tell about androids.
~ catherine
| We'd better go inside and talk to Jack.
! eval (move-to 'jack (unit 'catherine))
")


; ! eval (activate 'q1-water)
; TODO mention stranger's name? Leave for jack to do?


;(:name find-jack
; :title "Find Jack"
; :description "Follow Catherine into the building and find Jack."
; :invariant T
; :condition NIL
; :on-activate (catherine-to-jack))
 
;(quest:action :name catherine-to-jack :on-activate (progn
;(lead 'player 'jack 'catherine)
;))

