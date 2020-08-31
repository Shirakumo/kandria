(defpackage #:org.shirakumo.fraf.leaf.dialogue.components
  (:use #:cl)
  (:shadow #:go #:speed #:setf #:eval #:map)
  (:local-nicknames
   (#:markless #:org.shirakumo.markless)
   (#:components #:org.shirakumo.markless.components))
  (:export
   #:jump
   #:placeholder
   #:form
   #:emote
   #:conditional-part
   #:choices
   #:conditional
   #:clauses
   #:source
   #:name
   #:clue
   #:go
   #:speed
   #:camera-instruction
   #:duration
   #:shake
   #:move
   #:location
   #:zoom
   #:roll
   #:angle
   #:show
   #:map
   #:location
   #:setf
   #:place
   #:eval))

(defpackage #:org.shirakumo.fraf.leaf.dialogue.syntax
  (:use #:cl)
  (:local-nicknames
   (#:components #:org.shirakumo.fraf.leaf.dialogue.components)
   (#:mcomponents #:org.shirakumo.markless.components)
   (#:markless #:org.shirakumo.markless))
  (:export
   #:parser
   #:jump
   #:conditional
   #:source
   #:placeholder
   #:emote
   #:part-separator
   #:conditional-part
   #:clue))

(defpackage #:org.shirakumo.fraf.leaf.dialogue
  (:use #:cl)
  (:shadow #:compile #:eval)
  (:local-nicknames
   (#:components #:org.shirakumo.fraf.leaf.dialogue.components)
   (#:mcomponents #:org.shirakumo.markless.components))
  ;; instructions.lisp
  (:export
   #:instruction
   #:index
   #:label
   #:noop
   #:source
   #:name
   #:jump
   #:target
   #:conditional
   #:clauses
   #:emote
   #:pause
   #:placeholder
   #:choose
   #:commit-choice
   #:confirm
   #:begin-mark
   #:end-mark
   #:text
   #:eval)
  ;; compiler.lisp
  (:export
   #:parse
   #:compile
   #:wrap-lexenv
   #:assembly
   #:instructions
   #:next-index
   #:emit
   #:walk
   #:define-simple-walker
   #:define-markup-walker
   #:resolved-target)
  ;; optimizers.lisp
  (:export
   #:pass
   #:run-pass
   #:compile*
   #:optimize-instructions
   #:jump-resolution-pass
   #:noop-elimination-pass)
  ;; vm.lisp
  (:export
   #:request
   #:input-request
   #:target-request
   #:target
   #:text-request
   #:text
   #:markup
   #:choice-request
   #:choices
   #:targets
   #:confirm-request
   #:emote-request
   #:emote
   #:pause-request
   #:duration
   #:source-request
   #:end-request
   #:vm
   #:instructions
   #:text-buffer
   #:choices
   #:markup
   #:execute
   #:text
   #:pop-text
   #:run
   #:reset
   #:resume
   #:suspend))
