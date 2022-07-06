;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(defmacro define-race (name &key npc site source marker title return-title description bronze silver gold on-complete)
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
         :interactable ,npc
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
                 (reset* 'return 'cancel-it)
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
         :interactable ,npc
         :repeatable T
         :source '(,source "cancel")))

       (return
         :title ,return-title
         :marker '(,npc 500)
         :invariant (not (complete-p 'q10-wraw))
         :on-activate (complete)
         :condition all-complete
         :on-complete (start ,@on-complete)
         
         (:interaction complete
          :title ,title-complete
          :interactable ,npc
          :source '(,source "return"))

         (:action complete-it
                  (hide-timer)
                  (retrieve 'item:can T)
                  (reset* 'start 'race)
                  (clear-pending-interactions))))))

(defmacro define-races (base-quest &body races)
  (form-fiddle:with-body-options (races other npc source return) races
    (declare (ignore other))
    (let* ((quest (quest:find-named base-quest (quest:storyline 'kandria)))
           (all-names (loop for i from 1 to (length races)
                            collect (trial::mksym *package* base-quest '- i)))
           (names all-names))
      `(progn
         ,@(loop for race in races
                 for i from 1
                 collect (destructuring-bind ((site gold silver bronze) &rest body) race
                           `(define-race ,(pop names)
                              ,@body
                              :site ,site
                              :npc ,npc
                              :gold ,gold
                              :silver ,silver
                              :bronze ,bronze
                              :title ,(format NIL "~a ~d" (quest:title quest) i)
                              :source ,source
                              :marker ',site
                              :on-complete ,(when names (list (first names)))
                              :return-title ,return)))))))

(quest:define-quest (kandria sq3-race)
  :author "Tim White"
  :title "Catherine's Time Trials"
  :description "Catherine and her friends want to see what I'm capable of. They've planted cans for me to find and bring back. I should talk to her if I want to start a race."
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

(define-races sq3-race
  :npc catherine
  :source "catherine-race"
  :return "Return the can to Catherine in Engineering ASAP"
  ((race-1-site 60 80 120)
   :marker (chunk-1841 1400)
   :description "The can is at... a literal high point of EASTERN civilisation, now long gone.")
  
  ((race-2-site 60 80 120)
   :marker (chunk-2480 3000)
   :description "The can is... where a shallow grave marks the end of the line at Zenith Crossing Station, East.")

  ((race-3-site 105 120 150)
   :marker (chunk-2482 1600)
   :description "The can is... beneath where we first ventured together, and got our feet wet.")

  ((race-4-site 90 105 135)
   :marker (chunk-5426 1600)
   :description "The can is... deep in the west, where we first met.")

  ((race-5-site 135 150 180)
   :marker (chunk-2019 2600)
   :description "The can is at... the furthest edge of the deepest cave in this region - there isn't 'much-room'."))
