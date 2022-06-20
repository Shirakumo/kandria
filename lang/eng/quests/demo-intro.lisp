;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-intro)
  :author "Tim White"
  :title "Find the Control Room"
  :description "I think I found the Semi Sisters. The one that seemed in charge said I should talk to her sister in the control room, about what I can do in exchange for her turning the water back on."
  (:interact (islay)
   :title "Find the sister in the control room"
   (find-mess "demo-intro"))
  (:eval
   :condition (not (find-panel 'fullscreen-prompt))
   (fullscreen-prompt 'toggle-menu))
  (:eval
   :condition (not (find-panel 'fullscreen-prompt))
   (fullscreen-prompt 'interact :title 'save-demo))
  (:eval
   :on-complete (trader-shop-semi)
   (setf (music-state 'region1) :quiet)))
