(in-package #:org.shirakumo.fraf.kandria)

(defvar *quest-files*
  '("storyline"
    "achievo-shop"
    "epilogue-2"
    "epilogue"
    "epilogue-home"
    "explosion"
    "q0-find-jack"
    "q0-settlement-arrive"
    "q0-surface"
    "q10a-return-to-fi"
    "q10-boss"
    "q10-wraw"
    "q11a-bomb-recipe"
    "q11-intro"
    "q11-recruit-semis"
    "q12-help-alex"
    "q13-intro"
    "q13-planting-bomb"
    "q14-envoy"
    "q14a-zelah-gone"
    "q15-boss"
    "q15-catherine"
    "q15-intro"
    "q15-target-bomb"
    "q15-unexploded-bomb"
    "q1-ready"
    "q1-water"
    "q2-intro"
    "q2-seeds"
    "q3-intro"
    "q3-new-home"
    "q4-find-alex"
    "q4-intro"
    "q5a-engineers-return"
    "q5a-rescue-engineers"
    "q5b-boss"
    "q5b-investigate-cctv"
    "q5-intro"
    "q5-run-errands"
    "q6-return-to-fi"
    "q7-my-name"
    "q8-alex-cerebat"
    "q8a-bribe-trader"
    "q8-meet-council"
    "q9-contact-fi"
    "semi-station-marker"
    "sq1-leaks"
    "sq2-mushrooms"
    "sq3-race"
    "sq4-analyse-robots"
    "sq4-boss"
    "sq4-intro"
    "sq5-intro"
    "sq5-race"
    "sq6-deliver-letter"
    "sq6-intro"
    "sq7-intro"
    "sq7-wind-parts"
    "sq7a-catherine-semis"
    "sq8-intro"
    "sq8-find-council"
    "sq8-item"
    "sq9-intro"
    "sq9-race"
    "sq10-intro"
    "sq10-race"
    "sq11-intro"
    "sq11-sabotage-station"
    "sq14-intro"
    "sq14a-synthesis"
    "sq14b-boss"
    "sq14b-synthesis"
    "sq14c-synthesis"
    "sq-act1-intro"
    "trader-arrive"
    "trader-cerebat"
    "trader-islay"
    "tutorial"
    "vinny"
    "world-engineers-wall"
    "world"
    "world-move-engineers"))

(defun load-quest-file (file &optional (world (find-world)))
  (let* ((root (depot:entry "quests" world))
         (entry (if (depot:entry-exists-p (format NIL "~a.fasl" file) root)
                    (depot:entry (format NIL "~a.fasl" file) root)
                    (depot:entry (format NIL "~a.lisp" file) root))))
    (if (typep entry 'depot:file)
        (cl:load (depot:to-pathname entry))
        (trial:with-tempfile (tempfile :type (if (equal "lisp" (depot:attribute :type entry)) "lisp" "fasl"))
          (depot:read-from entry tempfile)
          (cl:load tempfile)))))

(defun load-all-quest-files (&key (world (find-world)))
  (v:info :kandria.quest "Loading quest files, this will take a while.")
  (dolist (file *quest-files*)
    (load-quest-file file world)))

(load-all-quest-files)
