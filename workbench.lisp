(in-package #:org.shirakumo.fraf.leaf)

(define-storyline test
  :title "Test")

(define-dialog (test a)
  :predicate T
  :character :player
  "Hello"
  :pause 1
  :append ", this is a robbery!"
  :stop
  :shake
  "Oh my goooooood!!!")

(setf (active-p (storyline 'test)) T)
