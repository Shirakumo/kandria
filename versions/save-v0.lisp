(in-package #:org.shirakumo.fraf.leaf)

(defclass save-v0 (version) ())

(define-decoder (world save-v0) (_b packet)
  (destructuring-bind (&key region)
      (first (parse-sexps (packet-entry "global.lisp" packet :element-type 'character)))
    (load-region region world)
    (decode (storyline world))
    (decode region)))

(define-encoder (world save-v0) (_b packet)
  (encode (storyline world))
  (encode (unit 'region world))
  (with-packet-entry (stream "global.lisp" packet
                             :direction :output
                             :element-type 'character)
    (princ* (list :region (name (unit 'region world))) stream)))

(define-decoder (quest:storyline save-v0) (_b packet)
  )

(define-encoder (quest:storyline save-v0) (_b packet)
  (with-packet-entry (stream "storyline.lisp" packet
                             :direction :output
                             :element-type 'character)
    (dolist (quest (quest:quests quest:storyline))
      (princ* (encode quest) stream))))

(define-decoder (quest:quest save-v0) (_b packet)
  )

(define-encoder (quest:quest save-v0) (buffer _p)
  (list :name (quest:name quest:quest)
        :status (quest:status quest:quest)
        :tasks (mapcar #'encode (quest:tasks quest:quest))))

(define-decoder (quest:task save-v0) (_b packet)
  )

(define-encoder (quest:task save-v0) (_b _p)
  (cons (quest:name quest:quest)
        (list :status (quest:status quest:task))))

(define-decoder (region save-v0) (_b packet)
  (destructuring-bind (&key deletions additions state)
      (first (parse-sexps (packet-entry (region-entry region (scene-graph region))
                                        packet :element-type 'character)))
    (dolist (name deletions)
      (leave (unit name region) region))))

(define-encoder (region save-v0) (_b packet)
  (with-packet-entry (stream (region-entry region (scene-graph region)) packet
                             :direction :output
                             :element-type 'character)
    (multiple-value-bind (additions deletions) (compute-entity-delta region (scene-graph region))
      (let ((v0 (make-instance 'v0))
            (state ()))
        (for:for ((entity over region))
          (unless (typep entity 'chunk)
            (push (encode entity) state)))
        (princ* (list :deletions (mapcar #'name deletions)
                      :additions (loop for entity in additions
                                       collect (encode-payload entity NIL packet v0))
                      :state state)
                stream)))))
