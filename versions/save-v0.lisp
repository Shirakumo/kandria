(in-package #:org.shirakumo.fraf.leaf)

(defclass save-v0 (v0) ())

(define-encoder (world save-v0) (_b packet)
  (encode (storyline world))
  (encode (unit 'region world))
  (with-packet-entry (stream "global.lisp" packet
                             :element-type 'character)
    (princ* (list :region (name (region world))) stream)))

(define-encoder (quest:storyline save-v0) (_b packet)
  (with-packet-entry (stream "storyline.lisp" packet
                             :element-type 'character)
    (loop for quest being the hash-values of (quest:quests quest:storyline)
          do (princ* (encode quest) stream))))

(define-encoder (quest:quest save-v0) (buffer _p)
  (cons (quest:name quest:quest)
        (list :status (quest:status quest:quest)
              :tasks (mapcar #'encode (quest:tasks quest:quest)))))

(define-encoder (quest:task save-v0) (_b _p)
  (cons (quest:name quest:task)
        (list :status (quest:status quest:task))))

(define-encoder (region save-v0) (_b packet)
  (with-packet-entry (stream (format NIL "regions/~(~a~).lisp" (name region)) packet
                             :element-type 'character)
    (let ((create-new (list NIL))
          (ephemeral (list NIL)))
      (labels ((payload (named entity target)
                 (handler-case
                     (setf (cdr target) (list* (cons (name named) (encode entity)) (cdr target)))
                   (no-applicable-encoder (e)
                     (declare (ignore e)))))
               (recurse (parent)
                 (for:for ((entity over parent))
                   (cond ((typep entity 'ephemeral)
                          (payload entity entity ephemeral)
                          (when (typep entity 'container)
                            (recurse entity)))
                         (T
                          (payload parent entity create-new))))))
        (recurse region))
      (princ* (list :create-new (rest create-new)
                    :ephemeral (rest ephemeral))
              stream))))

(define-encoder (player save-v0) (_b _p)
  (rest (call-next-method)))

(define-encoder (animatable save-v0) (_b _p)
  `(,(type-of animatable)
    :location ,(encode (location animatable))
    :direction ,(direction animatable)
    :state ,(state animatable)
    :animation ,(sprite-animation-name (animation animatable))
    :frame ,(frame animatable)
    :health ,(health animatable)
    :stun-time ,(stun-time animatable)))

(define-decoder (world save-v0) (_b packet)
  (destructuring-bind (&key region)
      (first (parse-sexps (packet-entry "global.lisp" packet :element-type 'character)))
    (let ((region (cond ((and (region world) (eql region (name (region world))))
                         ;; Ensure we trigger necessary region reset events even if we're still in the same region.
                         (issue world 'switch-region :region (region world))
                         (region world))
                        (T
                         (load-region region world)))))
      (decode (storyline world))
      (decode region))))

(define-decoder (quest:storyline save-v0) (_b packet)
  (loop for (name . initargs) in (parse-sexps (packet-entry "storyline.lisp" packet
                                                            :element-type 'character))
        for quest = (quest:find-quest name quest:storyline)
        do (decode quest initargs)))

(define-decoder (quest:quest save-v0) (initargs packet)
  (destructuring-bind (&key status tasks) initargs
    (setf (quest:status quest:quest) status)
    ;; FIXME: Quests not saved in the state won't be reset to initial state.
    (loop for (name . initargs) in tasks
          for task = (quest:find-task name quest:quest)
          do (decode task initargs))))

(define-decoder (quest:task save-v0) (initargs packet)
  (destructuring-bind (&key status) initargs
    (setf (quest:status quest:task) status)))

(define-decoder (region save-v0) (initargs packet)
  (destructuring-bind (&key create-new ephemeral)
      (first (parse-sexps (packet-entry (format NIL "regions/~(~a~).lisp" (name region))
                                        packet :element-type 'character)))
    ;; Remove all entities that are not ephemeral
    (labels ((recurse (parent)
               (for:for ((entity over parent))
                 (typecase entity
                   ((not ephemeral) (leave entity parent))
                   (container (recurse entity))))))
      (recurse region))
    ;; Add new entities that exist in the state
    (loop for (name . state) in create-new
          for parent = (unit name (scene-graph region))
          do (enter (decode-payload (cdr state) (make-instance (car state)) packet save-v0) parent))
    ;; Update state on ephemeral ones
    (loop for (name . state) in ephemeral
          for unit = (unit name (scene-graph region))
          do (if unit
                 (decode unit state)
                 (error "Unit named ~s referenced but not found." name)))))

(define-decoder (player save-v0) (_i _p)
  (call-next-method)
  (snap-to-target (unit :camera T) player))

(define-decoder (animatable save-v0) (initargs _p)
  (destructuring-bind (&key location direction state animation frame health stun-time) initargs
    (setf (location animatable) (decode 'vec2 location))
    (setf (direction animatable) direction)
    (setf (state animatable) state)
    (setf (animation animatable) animation)
    (setf (frame animatable) frame)
    (setf (health animatable) health)
    (setf (stun-time animatable) stun-time)
    animatable))
