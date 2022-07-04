;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; (quest:update sq3-race :active)
;; (store 'item:can (unit 'player T))

(quest:define-quest (kandria sq3-race)
  :author "Tim White"
  :title "Catherine's Time Trials"
  :description "Catherine and her friends want to see what I'm capable of. They've planted cans for me to find and bring back. The faster I can do it, the more parts I'll get."
  :on-activate (race-hub)
  :variables (gold silver bronze pb start-task)
  (race-hub
   :title "Talk to Catherine in Engineering to start a race"
   :marker '(catherine 500)
   :invariant (not (complete-p 'q10-wraw))
   :on-activate T
   (:interaction start-race
    :title "About the race."
    :interactable catherine
    :repeatable T
    :source '("catherine-race" "hub"))))

(defmacro define-race (name &key site marker title title-start title-complete title-cancel bronze silver gold on-complete)
  (let ((name-start (trial::mksym #.*package* name '-start)))
    `(progn
       (quest:define-task (kandria sq3-race ,name-start)
         :title ,title
         :marker ',marker
         :invariant (not (complete-p 'q10-wraw))
         :condition (have 'item:can)
         :on-activate (start)
         :on-complete (,name)
         :variables ((gold ,gold)
                     (silver ,silver)
                     (bronze ,bronze)
                     pb start-task)
         (:interaction start
          :title ,title-start
          :interactable catherine
          :repeatable T
          :source '("catherine-race" "start"))
         
         (:action spawn-can
                  (reset* ',name)
                  (setf (clock quest) 0)
                  (activate 'cancel)
                  (show-timer quest)
                  (spawn ',site 'item:can)
                  (setf (quest:status (thing ',name)) :inactive))
                  
         (:interaction site
          :interactable ,site
          :repeatable T
          :source '("catherine-race" "site"))
                  
         (:interaction cancel
          :title ,title-cancel
          :interactable catherine
          :repeatable T
          :source '("catherine-race" "cancel")))

       (quest:define-task (kandria sq3-race ,name)
         :title "Return the can to Catherine in Engineering ASAP"
         :marker '(catherine 500)
         :invariant (not (complete-p 'q10-wraw))
         :on-activate T
         :condition all-complete
         :on-complete (race-hub ,name-start ,@on-complete)
         :variables ((gold ,gold)
                     (silver ,silver)
                     (bronze ,bronze)
                     (start-task ',name-start)
                     pb)
         (:action activate
                  (setf (quest:status (thing 'chat)) :inactive)
                  (activate 'cancel 'chat))
         
         (:interaction cancel
          :title ,title-cancel
          :interactable catherine
          :repeatable T
          :source '("catherine-race" "cancel"))
         
         (:interaction chat
          :title ,title-complete
          :interactable catherine
          :source '("catherine-race" "complete"))))))

;; TODO These vars stored in save game? Problematic if we tweak after launch/testing?
(define-race race-1
  :site race-1-site
  :marker (chunk-1841 1400)
  :title "The can is at... a literal high point of EASTERN civilisation, now long gone."
  :title-start "(Start Race Route 1)"
  :title-complete "(Complete Race Route 1)"
  :title-cancel "(Cancel Race Route 1)"
  :gold 60
  :silver 80
  :bronze 120
  :on-complete (race-2))

(define-race race-2
  :site race-2-site
  :marker (chunk-2480 3000)
  :title "The can is... where a shallow grave marks the end of the line at Zenith Crossing Station, East."
  :title-start "(Start Race Route 2)"
  :title-complete "(Complete Race Route 2)"
  :title-cancel "(Cancel Race Route 2)"
  :gold 60
  :silver 80
  :bronze 120
  :on-complete (race-3))

(define-race race-3
  :site race-3-site
  :marker (chunk-2482 1600)
  :title "The can is... beneath where we first ventured together, and got our feet wet."
  :title-start "(Start Race Route 3)"
  :title-complete "(Complete Race Route 3)"
  :title-cancel "(Cancel Race Route 3)"
  :gold 105
  :silver 120
  :bronze 150
  :on-complete (race-3))

(define-race race-4
  :site race-4-site
  :marker (chunk-5426 1600)
  :title "The can is... deep in the west, where we first met."
  :title-start "(Start Race Route 4)"
  :title-complete "(Complete Race Route 4)"
  :title-cancel "(Cancel Race Route 4)"
  :gold 90
  :silver 105
  :bronze 135
  :on-complete (race-4))

(define-race race-5
  :site race-5-site
  :marker (chunk-2019 1600)
  :title "The can is at... the furthest edge of the deepest cave in this region - there isn't 'much-room'."
  :title-start "(Start Race Route 5)"
  :title-complete "(Complete Race Route 5)"
  :title-cancel "(Cancel Race Route 5)"
  :gold 135
  :silver 150
  :bronze 180)
