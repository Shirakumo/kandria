(in-package #:org.shirakumo.fraf.leaf)

(define-storyline test
  :title "Test")

(define-dialog (test a)
  :predicate T
  :character player
  "Hello this is a robbery put up your hands"
  :shake
  "Oh my goooooood")

(print (compute-applicable-dialogs (make-instance 'trial:tick) T))
(print (dialog 'a (storyline 'test)))
