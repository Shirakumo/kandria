(in-package #:org.shirakumo.fraf.kandria)

(defclass save-v0 (v0) ())

(define-encoder (world save-v0) (_b packet)
  (encode (storyline world))
  (encode (unit 'region world))
  (with-packet-entry (stream "global.lisp" packet
                             :element-type 'character)
    (princ* (list :region (name (region world))
                  :clock (clock world))
            stream)))

(define-encoder (quest:storyline save-v0) (_b packet)
  (with-packet-entry (stream "storyline.lisp" packet
                             :element-type 'character)
    (loop for quest being the hash-values of (quest:quests quest:storyline)
          do (princ* (encode quest) stream))))

(define-encoder (quest:quest save-v0) (buffer _p)
  (cons (quest:name quest:quest)
        (list :status (quest:status quest:quest)
              :tasks (loop for quest being the hash-values of (quest:tasks quest:quest)
                           collect (encode quest)))))

(define-encoder (quest:task save-v0) (_b _p)
  (cons (quest:name quest:task)
        (list :status (quest:status quest:task))))

(define-encoder (region save-v0) (_b packet)
  (with-packet-entry (stream (format NIL "regions/~(~a~).lisp" (name region)) packet
                             :element-type 'character)
    (let ((create-new (list NIL))
          (ephemeral (list NIL)))
      (macrolet ((add (target value)
                   `(handler-case
                        (setf (cdr ,target) (list* ,value (cdr ,target)))
                      (no-applicable-encoder (e)
                        (declare (ignore e))))))
        (labels ((recurse (parent)
                   (for:for ((entity over parent))
                     (cond ((typep entity 'ephemeral)
                            (add ephemeral (list* (name entity) (encode entity)))
                            (when (typep entity 'container)
                              (recurse entity)))
                           (T
                            (add create-new (list* (name parent) (type-of entity) (encode entity))))))))
          (recurse region)))
      (princ* (list :create-new (rest create-new)
                    :ephemeral (rest ephemeral))
              stream))))

(define-encoder (animatable save-v0) (_b _p)
  (let ((animation (animation animatable)))
    `(:location ,(encode (location animatable))
      :direction ,(direction animatable)
      :state ,(state animatable)
      :animation ,(when animation (name animation))
      :frame ,(when animation (frame-idx animatable))
      :health ,(health animatable)
      :stun-time ,(stun-time animatable))))

(define-encoder (player save-v0) (_b _p)
  (list* :inventory (alexandria:hash-table-alist (storage player))
         (call-next-method)))

(define-encoder (moving-platform save-v0) (_b _p)
  `(:location ,(encode (location moving-platform))
    :velocity ,(encode (velocity moving-platform))
    :state ,(state moving-platform)))

(define-encoder (rope save-v0) (_b _p)
  `(:extended ,(extended rope)))

(define-decoder (world save-v0) (_b packet)
  (destructuring-bind (&key region clock)
      (first (parse-sexps (packet-entry "global.lisp" packet :element-type 'character)))
    (setf (clock world) clock)
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
    (setf (quest:status quest:task) status)
    (when (eql :unresolved status)
      (dolist (trigger (quest:on-activate quest:task))
        (quest:activate (quest:find-named trigger quest:task))))))

(define-decoder (region save-v0) (initargs packet)
  (destructuring-bind (&key create-new ephemeral (delete-existing T) &allow-other-keys)
      (first (parse-sexps (packet-entry (format NIL "regions/~(~a~).lisp" (name region))
                                        packet :element-type 'character)))
    ;; Remove all entities that are not ephemeral
    (when delete-existing
      (labels ((recurse (parent)
                 (for:for ((entity over parent))
                   (typecase entity
                     ((not ephemeral)
                      (leave entity parent)
                      (remove-from-pass entity +world+))
                     (container (recurse entity))))))
        (recurse region)))
    ;; Add new entities that exist in the state
    (loop for (name type . state) in create-new
          for parent = (unit name (scene-graph region))
          for entity = (decode-payload state (make-instance type) packet save-v0)
          do (enter* entity parent))
    ;; Update state on ephemeral ones
    (loop for (name . state) in ephemeral
          for unit = (unit name (scene-graph region))
          do (if unit
                 (decode unit state)
                 (error "Unit named ~s referenced but not found." name)))))

(define-decoder (animatable save-v0) (initargs _p)
  (destructuring-bind (&key location direction state animation frame health stun-time &allow-other-keys) initargs
    (setf (location animatable) (decode 'vec2 location))
    (setf (direction animatable) direction)
    (setf (state animatable) state)
    (when animation
      (setf (animation animatable) animation)
      (setf (frame animatable) frame))
    (setf (health animatable) health)
    (setf (stun-time animatable) stun-time)
    animatable))

(define-decoder (player save-v0) (initargs _p)
  (call-next-method)
  (let ((inventory (getf initargs :inventory)))
    (setf (storage player) (alexandria:alist-hash-table inventory :test 'eq)))
  (snap-to-target (unit :camera T) player))

(define-decoder (moving-platform save-v0) (initargs _p)
  (destructuring-bind (&key location velocity state &allow-other-keys) initargs
    (setf (location moving-platform) (decode 'vec2 location))
    (setf (velocity moving-platform) (decode 'vec2 velocity))
    (setf (state moving-platform) state)
    moving-platform))

(define-decoder (rope save-v0) (initargs _p)
  (destructuring-bind (&key extended &allow-other-keys) initargs
    (setf (extended rope) extended)))
