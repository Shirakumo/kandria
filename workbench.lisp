(in-package #:org.shirakumo.fraf.leaf)

(define-storyline test
  :title "Test")

(define-dialog (test a)
  :predicate (and (typep ev 'interaction)
                  (eql (with ev) :pc))
  :character :player
  "An old computer. Seems it's still running."
  :emote cheeky
  "Let's see what's on here ..."
  :shake
  :emote concerned
  "Huh! It says here that this entire world is..."
  :append " just a video game!" :stop)

(setf (active-p (storyline 'test)) T)
