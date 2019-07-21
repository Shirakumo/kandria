(in-package #:org.shirakumo.fraf.leaf)

(defclass save-v0 (version) ())

(define-decoder (world save-v0) (_b packet)
  (destructuring-bind (&key region)
      (first (parse-sexps (packet-entry "global.lisp" packet :element-type 'character)))
    ;; FIXME: Avoid reloading the entire region when loading state.
    ;;        Particularly, avoid changing assets for chunks.
    (let ((region (load-region region world)))
      (decode (storyline world))
      (decode region))))

(define-encoder (world save-v0) (_b packet)
  (encode (storyline world))
  (encode (unit 'region world))
  (with-packet-entry (stream "global.lisp" packet
                             :element-type 'character)
    (princ* (list :region (name (unit 'region world))) stream)))

(define-decoder (quest:storyline save-v0) (_b packet)
  (loop for (name . initargs) in (parse-sexps (packet-entry "storyline.lisp" packet
                                                            :element-type 'character))
        for quest = (quest:find-quest name quest:storyline)
        do (decode quest initargs)))

(define-encoder (quest:storyline save-v0) (_b packet)
  (with-packet-entry (stream "storyline.lisp" packet
                             :element-type 'character)
    (loop for quest being the hash-values of (quest:quests quest:storyline)
          do (princ* (encode quest) stream))))

(define-decoder (quest:quest save-v0) (initargs packet)
  (destructuring-bind (&key status tasks) initargs
    (setf (quest:status quest:quest) status)
    ;; FIXME: Quests not saved in the state won't be reset to initial state.
    (loop for (name . initargs) in tasks
          for task = (quest:find-task name quest:quest)
          do (decode task initargs))))

(define-encoder (quest:quest save-v0) (buffer _p)
  (cons (quest:name quest:quest)
        (list :status (quest:status quest:quest)
              :tasks (mapcar #'encode (quest:tasks quest:quest)))))

(define-decoder (quest:task save-v0) (initargs packet)
  (destructuring-bind (&key status) initargs
    (setf (quest:status quest:task) status)))

(define-encoder (quest:task save-v0) (_b _p)
  (cons (quest:name quest:quest)
        (list :status (quest:status quest:task))))

(define-decoder (region save-v0) (_b packet)
  (destructuring-bind (&key deletions additions state)
      (first (parse-sexps (packet-entry (format NIL "regions/~(~a~).lisp" (name region))
                                        packet :element-type 'character)))
    (let ((v0 (make-instance 'v0)))
      (dolist (name deletions)
        (leave (unit name region) region))
      (dolist (addition additions)
        (destructuring-bind (&key container init) addition
          (enter (decode-payload (cdr init) (car init) packet v0)
                 (unit container region))))
      (loop for (name . state) in state
            for unit = (unit name (scene-graph region))
            do (decode unit state)))))

(define-encoder (region save-v0) (_b packet)
  (with-packet-entry (stream (format NIL "regions/~(~a~).lisp" (name region)) packet
                             :element-type 'character)
    (multiple-value-bind (additions deletions) (compute-entity-delta region (scene-graph region))
      (let ((v0 (make-instance 'v0))
            (state ()))
        (flare:do-container-tree (entity region) 
          (handler-case (push (encode entity) state)
            (no-applicable-encoder (e)
              (declare (ignore e)))))
        (princ* (list :deletions (loop for entity in deletions
                                       collect (name (cdr entity)))
                      :additions (loop for (container . entity) in additions
                                       collect (list :container (name container)
                                                     :init (encode-payload entity NIL packet v0)))
                      :state state)
                stream)))))
(untrace encode-payload)
(define-decoder (player save-v0) (initargs _p)
  (destructuring-bind (&key location) initargs
    (setf (location player) (decode 'vec2 location))))

(define-encoder (player save-v0) (_b _p)
  `(player :location ,(encode (location player))))

(define-decoder (vec2 save-v0) (data _p)
  (destructuring-bind (x y) data
    (vec2 x y)))

(define-encoder (vec2 save-v0) (_b _p)
  (list (vx vec2)
        (vy vec2)))

(define-decoder (asset save-v0) (data _p)
  (destructuring-bind (pool name) data
    (asset pool name)))

(define-encoder (asset save-v0) (_b _p)
  (list (name (pool asset))
        (name asset)))
