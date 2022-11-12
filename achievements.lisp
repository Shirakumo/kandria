(in-package #:org.shirakumo.fraf.kandria)

(define-achievement catherine-races quest-completed
  (loop with storyline = (storyline +world+)
        for quest in '(sq3-race-1 sq3-race-2 sq3-race-3 sq3-race-4 sq3-race-5)
        always (eql :complete (quest:status (quest:find-quest quest storyline)))))

(define-achievement barkeep-races quest-completed
  (loop with storyline = (storyline +world+)
        for quest in '(sq5-race-1 sq5-race-2 sq5-race-3 sq5-race-4 sq5-race-5 sq5-race-6)
        always (eql :complete (quest:status (quest:find-quest quest storyline)))))

(define-achievement spy-races quest-completed
  (loop with storyline = (storyline +world+)
        for quest in '(sq9-race-1 sq9-race-2 sq9-race-3 sq9-race-4 sq9-race-5)
        always (eql :complete (quest:status (quest:find-quest quest storyline)))))

(define-achievement sergeant-races quest-completed
  (loop with storyline = (storyline +world+)
        for quest in '(sq10-race-1 sq10-race-2 sq10-race-3 sq10-race-4 sq10-race-5)
        always (eql :complete (quest:status (quest:find-quest quest storyline)))))

(define-achievement sergeant-races quest-completed
  (loop with storyline = (storyline +world+)
        for quest in '(sq10-race-1 sq10-race-2 sq10-race-3 sq10-race-4 sq10-race-5)
        always (eql :complete (quest:status (quest:find-quest quest storyline)))))

(define-achievement full-map switch-chunk
  (multiple-value-bind (total found) (chunk-find-rate (unit 'player +world+))
    (<= total found)))

(define-achievement all-fish item-unlocked
  (loop with player = (unit 'player +world+)
        for fish in (c2mop:class-direct-subclasses (find-class 'fish))
        always (item-unlocked-p (class-name fish) player)))

(define-achievement game-complete game-over
  (eql (ending game-over) :normal))

(define-achievement early-ending game-over
  (eql (ending game-over) :zelah))

(defvar *last-death-count* (cons NIL 0))
(define-achievement persistence player-died
  (unless (eq (car *last-death-count*) (chunk (unit 'player T)))
    (setf (car *last-death-count*) (chunk (unit 'player T)))
    (setf (cdr *last-death-count*) 0))
  (<= 30 (incf (cdr *last-death-count*))))

(define-achievement accessibility)
(define-achievement modder)
