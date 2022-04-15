;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q10-wraw)
  :author "Tim White"
  :title "The Wraw"
  :description "Fi wants me to go deep into Wraw territory itself, to try and determine what they're up to."
  :on-activate (wraw-objective wraw-warehouse wraw-mechs)

  (wraw-objective
   :title "Explore Wraw territory, beneath the Cerebat area"
   :invariant T
   :condition all-complete
   :on-activate (objective)
   :on-complete NIL
   
   (:interaction objective
    :interactable player
    :dialogue "
    "))

  (wraw-warehouse
   :title ""
   :invariant T
   :condition all-complete
   :on-activate (warehouse)
   :on-complete NIL
   :visible NIL

   ;; player will be collecting lots of these supplies themselves, so no need to over-explain them in the quest
   (:interaction warehouse
    :interactable q10-supplies
    :dialogue "
~ player
| \"This warehouse has plentiful supplies.\"(light-gray, italic)
| (:thinking)\"The coal and vats of oil indicate mass production, augmenting their already-considerable geothermal reserves.\"(light-gray, italic)
? (complete-p 'wraw-mechs)
| ~ player
| | (:embarassed)\"It's at a scale to manufacture enough mechs and weapons for an invasion of the entire valley...\"(light-gray, italic)
| | \"I need to \"contact Fi\"(orange).\"(light-gray, italic)
| | \"... FFCS can't punch through - whether it's the magnetic interference from the magma, or the Wraw themselves.\"(light-gray, italic)
| ? (complete-p 'q10-boss)
| | | \"I'd better get \"back to Cerebat territory\"(orange) and call this in.\"(light-gray, italic)
| | ! eval (complete 'wraw-objective)
| | ! eval (activate 'q10a-return-to-fi)
| | ! eval (activate (unit 'wraw-border-1))
| | ! eval (activate (unit 'wraw-border-2))
| |?
| | | \"I'd better \"deal with that active mech in the factory\"(orange) though, before it wakes up the whole army.\"(light-gray, italic)
| | | \"Then get \"back to Cerebat territory\"(orange) and call this in.\"(light-gray, italic)
"))

  (wraw-mechs
   :title ""
   :invariant T
   :condition all-complete
   :on-activate (mechs)
   :on-complete NIL
   :visible NIL

   ;; TODO fix markless formatting for Genera line, so escaped quotes can be part of the light-gray and italic wrapper
   (:interaction mechs
    :interactable q10-mechs
    :dialogue "
~ player
| \"This mech was built from drills and turbines. They all were, these power suits too.\"(light-gray, italic)
| \"This one has an interface port, which could forcibly extract data from an android.\"(light-gray, italic)
| \"Perhaps I can verify what the mech's purpose is...\"(light-gray, italic)
| (:giggle)\"Just gotta stick my finger in here... Pardon me.\"(light-gray, italic)
| (:normal)\"Yep, this has been designed to subdue an android alright.\"(light-gray, italic)
| (:skeptical)\"Make that androids, plural, judging from these weapon configurations.\"(light-gray, italic)
| (:giggle)\"All this just for little old me? I'm flattered.\"(light-gray, italic)
| (:normal)\"Hang on, what's this?...\"(light-gray, italic)
| \"\"... Neutralise additional android targets: \"Genera\"(red) in the \"western mountains\"(red). Targets unknown.\"(light-gray, italic)\"
| (:skeptical)\"... A faction of androids in the mountains? Am I not alone?\"(light-gray, italic)
? (complete-p 'wraw-warehouse)
| | (:embarassed)\"Given the raw materials I saw in the warehouse, their manufacturing ambitions are HUGE.\"(light-gray, italic)
| | \"As in,\"(light-gray) \"\"invading the entire valley\"(light-gray)\" \"huge.\"(light-gray, italic)
| | (:normal)\"I need to \"contact Fi\"(orange).\"(light-gray, italic)
| | \"... FFCS can't punch through - whether it's the magnetic interference from the magma, or the Wraw themselves.\"(light-gray, italic)
| | \"I'd better get \"back to Cerebat territory\"(orange) and call this in.\"(light-gray, italic)
  
~ player
| (:embarassed)Ouch!... Power surge from the mech.
| I think this one is powering up.
! eval (activate 'q10-boss)
")))
