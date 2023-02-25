(in-package #:org.shirakumo.fraf.kandria)

(defun race-achieved-p (race)
  (let ((quest (quest:find-quest race (storyline +world+))))
    (and (quest:var 'pb quest)
         (<= (quest:var 'pb quest) (quest:var 'gold quest)))))

(define-achievement catherine-races task-completed
  :icon (// 'kandria 'ach-racecat)
  (every #'race-achieved-p '(sq3-race-1 sq3-race-2 sq3-race-3 sq3-race-4 sq3-race-5)))

(define-achievement barkeep-races task-completed
  :icon (// 'kandria 'ach-racebar)
  (every #'race-achieved-p '(sq5-race-1 sq5-race-2 sq5-race-3 sq5-race-4 sq5-race-5 sq5-race-6)))

(define-achievement spy-races task-completed
  :icon (// 'kandria 'ach-racespy)
  (every #'race-achieved-p '(sq9-race-1 sq9-race-2 sq9-race-3 sq9-race-4 sq9-race-5)))

(define-achievement sergeant-races task-completed
  :icon (// 'kandria 'ach-racesarge)
  (every #'race-achieved-p '(sq10-race-1 sq10-race-2 sq10-race-3 sq10-race-4 sq10-race-5)))

(define-achievement full-map switch-chunk
  :icon (// 'kandria 'ach-map)
  (and (string= "00000000-0000-0000-0000-000000000000" (id +world+))
       (multiple-value-bind (total found) (chunk-find-rate (unit 'player +world+))
         (<= total found))))

(define-achievement all-fish item-unlocked
  :icon (// 'kandria 'ach-fish)
  (loop with player = (unit 'player +world+)
        for fish in (c2mop:class-direct-subclasses (find-class 'fish))
        always (item-unlocked-p (class-name fish) player)))

(define-achievement game-complete game-over
  :icon (// 'kandria 'ach-end)
  (eql (ending game-over) :normal))

(define-achievement early-ending game-over
  :icon (// 'kandria 'ach-zelah)
  (eql (ending game-over) :zelah))

(defvar *last-death-count* (cons NIL 0))
(define-achievement persistence player-died
  :icon (// 'kandria 'ach-deaths)
  (unless (eq (car *last-death-count*) (chunk (unit 'player T)))
    (setf (car *last-death-count*) (chunk (unit 'player T)))
    (setf (cdr *last-death-count*) 0))
  (<= 30 (incf (cdr *last-death-count*))))

(define-achievement accessibility NIL
    :icon (// 'kandria 'ach-access))
(define-achievement modder NIL
    :icon (// 'kandria 'ach-mod))

(define-setting-observer accessibility-achievement :gameplay (value)
  (when +world+
    (when (or (/= 1.0 (getf value :rumble))
              (/= 1.0 (getf value :screen-shake))
              (getf value :god-mode)
              (getf value :infinite-dash)
              (getf value :infinite-climb)
              (/= 0.02 (getf value :text-speed))
              (/= 3.0 (getf value :auto-advance-after))
              (getf value :auto-advance-dialog)
              (null (getf value :display-text-effects))
              (null (getf value :display-swears))
              (getf value :visual-safe-mode)
              (getf value :allow-resuming-death)
              (/= 1.0 (getf value :game-speed))
              (/= 1.0 (getf value :damage-input))
              (/= 1.0 (getf value :damage-output))
              (/= 1.0 (getf value :level-multiplier))
              (null (getf value :show-hit-stings)))
      (award 'accessibility))))
