(in-package #:org.shirakumo.fraf.kandria.dialogue.components)

(docs:define-docs
  (type jump
    "")
  
  (type conditional
    "")

  (function clauses
    "")
  
  (type source
    "")

  (function name
    "")
  
  (type placeholder
    "")

  (function form
    "")
  
  (type emote
    "")

  (function emote
    "")
  
  (type conditional-part
    "")

  (function choices
    "")
  
  (type fake-instruction
    "")
  
  (type go
    "")
  
  (type speed
    "")

  (function speed
    "")
  
  (type camera
    "")

  (function action
    "")

  (function arguments
    "")
  
  (type move
    "")

  (function entity
    "")
  
  (type setf
    "")

  (function place
    "")
  
  (type eval
    ""))

(in-package #:org.shirakumo.fraf.kandria.dialogue.syntax)

(docs:define-docs
  (type parser
    "")

  (type jump
    "")

  (type label
    "")

  (type conditional
    "")

  (type source
    "")

  (type placeholder
    "")

  (type emote
    "")

  (type part-separator
    "")

  (type conditional-part
    ""))

(in-package #:org.shirakumo.fraf.kandria.dialogue)

;;; instructions.lisp
(docs:define-docs
  (type instruction
    "")
  
  (function index
    "")
  
  (function label
    "")
  
  (type noop
    "")
  
  (type source
    "")
  
  (function name
    "")
  
  (type jump
    "")
  
  (function target
    "")
  
  (type conditional
    "")
  
  (function clauses
    "")
  
  (type dispatch
    "")
  
  (function func
    "")
  
  (function targets
    "")
  
  (type emote
    "")
  
  (function emote
    "")
  
  (type pause
    "")
  
  (function duration
    "")
  
  (type placeholder
    "")
  
  (type choose
    "")
  
  (type commit-choice
    "")
  
  (type confirm
    "")
  
  (type begin-mark
    "")
  
  (function markup
    "")
  
  (type end-mark
    "")
  
  (type clear
    "")
  
  (type text
    "")
  
  (function text
    "")
  
  (type eval
  ""))


;;; compiler.lisp
(docs:define-docs
  (variable *root*
    "")
  
  (function parse
    "")
  
  (function compile
    "")
  
  (function disassemble
    "")
  
  (type assembly
    "")
  
  (function instructions
    "")
  
  (function next-index
    "")
  
  (function emit
    "")
  
  (function walk
    "")
  
  (function define-simple-walker
    "")
  
  (function define-markup-walker
    "")
  
  (function resolved-target
    ""))


;;; optimizers.lisp
(docs:define-docs
  (type pass
    "")
  
  (function prun-pass
    "")
  
  (function optimize-instructions
    "")
  
  (function compile*
    "")
  
  (type jump-resolution-pass
    "")
  
  (function label-map
    "")
  
  (type noop-elimination-pass
    ""))


;;; vm.lisp
(docs:define-docs
  (type request
    "")
  
  (type input-request
    "")
  
  (type target-request
    "")
  
  (type text-request
    "")
  
  (type choice-request
    "")
  
  (function choices
    "")
  
  (function targets
    "")
  
  (type confirm-request
    "")
  
  (type clear-request
    "")
  
  (type emote-request
    "")
  
  (type pause-request
    "")
  
  (type source-request
    "")
  
  (type end-request
    "")
  
  (type vm
    "")
  
  (function text-buffer
    "")
  
  (function execute
    "")
  
  (function pop-text
    "")
  
  (function run
    "")
  
  (function reset
    "")
  
  (function resume
    "")
  
  (function suspend
    ""))

