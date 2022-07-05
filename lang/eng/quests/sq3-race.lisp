;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria sq3-race)
  :author "Tim White"
  :title "Catherine's Time Trials"
  :description "Catherine and her friends want to see what I'm capable of. They've planted cans for me to find and bring back. The faster I can do it, the more parts I'll get."
  :on-activate T
  :variables (gold silver bronze pb start-task active-race)
  (race-hub
   :title "Talk to Catherine in Engineering to start a race"
   :marker '(catherine 500)
   :invariant (not (complete-p 'q10-wraw))
   :condition all-complete
   :on-activate T
   :on-complete (sq3-race-1)
   (:interaction about-races
    :title "About the races."
    :interactable catherine
    :source '("catherine-race" "hub"))))

(defmacro define-race (name &key site source marker title return-title description bronze silver gold on-complete)
  (let ((title-start (format NIL "(Start ~a)" title))
        (title-cancel (format NIL "(Cancel ~a)" title))
        (title-complete (format NIL "(Complete ~a)" title)))
    `(quest:define-quest (kandria ,name)
       :author "Tim White"
       :title ,title
       :on-activate (start)
       :variables ((gold ,gold) (silver ,silver) (bronze ,bronze) pb)
       
       (start
        :title ,title-start
        :invariant (not (complete-p 'q10-wraw))
        :condition '()
        :on-activate T
        :on-complete (race)
        (:interaction init
         :title ,title-start
         :interactable catherine
         :repeatable T
         :source '(,source "start")))
       
       (race
        :title ,description
        :marker ',marker
        :invariant (not (complete-p 'q10-wraw))
        :condition (have 'item:can)
        :on-activate (init cancel)
        :on-complete (return)
        
        (:action init
                 (reset* 'return)
                 (deactivate 'start)
                 (setf (clock quest) 0)
                 (show-timer quest)
                 (spawn ',site 'item:can))

        (:action cancel-it
                 (when (have 'item:can)
                   (retrieve 'item:can T))
                 (hide-timer)
                 (reset* 'start 'race 'return)
                 (activate 'start)
                 (leave 'item:can)
                 (clear-pending-interactions))

        (:interaction cancel
         :title ,title-cancel
         :interactable catherine
         :repeatable T
         :source '(,source "cancel")))

       (return
         :title ,return-title
         :marker '(catherine 500)
         :invariant (not (complete-p 'q10-wraw))
         :on-activate (complete)
         :condition all-complete
         :on-complete (start ,@on-complete)
         
         (:interaction complete
          :title ,title-complete
          :interactable catherine
          :source '(,source "return"))

         (:action complete-it
                  (hide-timer)
                  (retrieve 'item:can T)
                  (reset* 'start 'race)
                  (clear-pending-interactions))))))

;; TODO These vars stored in save game? Problematic if we tweak after launch/testing?
(define-race sq3-race-1
  :site race-1-site
  :marker (chunk-1841 1400)
  :title "Race Route 1"
  :description "The can is at... a literal high point of EASTERN civilisation, now long gone."
  :return-title "Return the can to Catherine in Engineering ASAP"
  :source "catherine-race"
  :gold 60
  :silver 80
  :bronze 120
  :on-complete (sq3-race-2))

(define-race sq3-race-2
  :site race-2-site
  :marker (chunk-2480 3000)
  :title "Race Route 2"
  :description "The can is... where a shallow grave marks the end of the line at Zenith Crossing Station, East."
  :return-title "Return the can to Catherine in Engineering ASAP"
  :source "catherine-race"
  :gold 60
  :silver 80
  :bronze 120
  :on-complete (race-3))

(define-race sq3-race-3
  :site race-3-site
  :marker (chunk-2482 1600)
  :title "Race Route 3"
  :description "The can is... beneath where we first ventured together, and got our feet wet."
  :return-title "Return the can to Catherine in Engineering ASAP"
  :source "catherine-race"
  :gold 105
  :silver 120
  :bronze 150
  :on-complete (sq3-race-4))

(define-race sq3-race-4
  :site race-4-site
  :marker (chunk-5426 1600)
  :title "Race Route 4"
  :description "The can is... deep in the west, where we first met."
  :return-title "Return the can to Catherine in Engineering ASAP"
  :source "catherine-race"
  :gold 90
  :silver 105
  :bronze 135
  :on-complete (sq3-race-5))

(define-race sq3-race-5
  :site race-5-site
  :marker (chunk-2019 1600)
  :title "Race Route 5"
  :description "The can is at... the furthest edge of the deepest cave in this region - there isn't 'much-room'."
  :return-title "Return the can to Catherine in Engineering ASAP"
  :source "catherine-race"
  :gold 135
  :silver 150
  :bronze 180)
