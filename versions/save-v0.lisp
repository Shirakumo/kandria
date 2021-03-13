(in-package #:org.shirakumo.fraf.kandria)

(defclass save-v0 (v0) ())

(define-encoder (world save-v0) (_b packet)
  (let ((region (region world)))
    (encode (storyline world))
    (with-packet-entry (stream (format NIL "regions/~(~a~).lisp" (name region)) packet
                               :element-type 'character)
      (princ* (encode region) stream))
    (with-packet-entry (stream "global.lisp" packet
                               :element-type 'character)
      (princ* (list :region (name region)
                    :clock (clock world)
                    :timestamp (timestamp world)
                    :zoom (zoom (unit :camera world)))
              stream))))

(define-decoder (world save-v0) (_b packet)
  (destructuring-bind (&key region (clock 0.0) (timestamp (initial-timestamp)) (zoom 1.0))
      (first (parse-sexps (packet-entry "global.lisp" packet :element-type 'character)))
    (setf (clock world) clock)
    (setf (timestamp world) timestamp)
    (setf (zoom (unit :camera world)) zoom)
    (setf (intended-zoom (unit :camera world)) zoom)
    (let* ((region (cond ((and (region world) (eql region (name (region world))))
                          ;; Ensure we trigger necessary region reset events even if we're still in the same region.
                          (issue world 'switch-region :region (region world))
                          (region world))
                         (T
                          (load-region region world))))
           (initargs (ignore-errors (first (parse-sexps (packet-entry (format NIL "regions/~(~a~).lisp" (name region))
                                                                      packet :element-type 'character))))))
      (decode region initargs)
      (decode (storyline world)))))

(define-encoder (quest:storyline save-v0) (_b packet)
  (with-packet-entry (stream "storyline.lisp" packet
                             :element-type 'character)
    (princ* (encode-payload 'bindings (quest:bindings quest:storyline) packet save-v0) stream)
    (loop for quest being the hash-values of (quest:quests quest:storyline)
          do (princ* (encode quest) stream))))

(define-decoder (quest:storyline save-v0) (_b packet)
  (destructuring-bind (bindings . quests) (parse-sexps (packet-entry "storyline.lisp" packet
                                                                     :element-type 'character))
    (setf (quest:bindings quest:storyline) (decode-payload bindings 'bindings packet save-v0))
    (loop for (name . initargs) in quests
          for quest = (quest:find-quest name quest:storyline)
          do (decode quest initargs))))

(define-encoder (quest:quest save-v0) (buffer _p)
  (list (quest:name quest:quest)
        :status (quest:status quest:quest)
        :tasks (loop for quest being the hash-values of (quest:tasks quest:quest)
                     collect (encode quest))
        :clock (clock quest:quest)
        :bindings (encode-payload 'bindings (quest:bindings quest:quest) _p save-v0)))

(define-decoder (quest:quest save-v0) (initargs packet)
  (destructuring-bind (&key status (clock 0.0) tasks bindings) initargs
    (setf (quest:status quest:quest) status)
    (setf (clock quest:quest) clock)
    (setf (quest:bindings quest:quest) (decode-payload bindings 'bindings packet save-v0))
    ;; FIXME: Quests not saved in the state won't be reset to initial state.
    (loop for (name . initargs) in tasks
          for task = (quest:find-task name quest:quest)
          do (decode task initargs))))

(define-encoder (quest:task save-v0) (_b _p)
  (list (quest:name quest:task)
        :status (quest:status quest:task)
        :bindings (encode-payload 'bindings (quest:bindings quest:task) _p save-v0)))

(define-decoder (quest:task save-v0) (initargs packet)
  (destructuring-bind (&key status bindings) initargs
    (setf (quest:status quest:task) status)
    (setf (quest:bindings quest:task) (decode-payload bindings 'bindings packet save-v0))
    (when (eql :unresolved status)
      (dolist (trigger (quest:on-activate quest:task))
        (quest:activate (quest:find-named trigger quest:task))))))

(define-encoder (region save-v0) (_b packet)
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
                          (when (name entity)
                            (add ephemeral (list* (name entity) (encode entity))))
                          (when (typep entity 'container)
                            (recurse entity)))
                         (T
                          (add create-new (encode entity)))))))
        (recurse region)))
    (list :create-new (rest create-new)
          :ephemeral (rest ephemeral))))

(define-decoder (region save-v0) (initargs packet)
  (destructuring-bind (&key create-new ephemeral (delete-existing T) &allow-other-keys) initargs
    ;; Remove all entities that are not ephemeral
    (when delete-existing
      (labels ((recurse (parent)
                 (for:for ((entity over parent))
                   (typecase entity
                     ((not ephemeral)
                      (leave* entity parent))
                     (container (recurse entity))))))
        (recurse region)))
    ;; Add new entities that exist in the state
    (loop for (type . state) in create-new
          for entity = (decode-payload state (make-instance type) packet save-v0)
          do (enter* entity region))
    ;; Update state on ephemeral ones
    (loop for (name . state) in ephemeral
          for unit = (unit name region)
          do (if unit
                 (decode unit state)
                 (error "Unit named ~s referenced but not found." name)))
    region))

(define-encoder (animatable save-v0) (_b _p)
  (let ((animation (animation animatable)))
    `(:location ,(encode (location animatable))
      :direction ,(direction animatable)
      :state ,(state animatable)
      :animation ,(when animation (name animation))
      :frame ,(when animation (frame-idx animatable))
      :health ,(health animatable)
      :stun-time ,(stun-time animatable))))

(define-decoder (animatable save-v0) (initargs _p)
  (destructuring-bind (&key location direction state animation frame health stun-time &allow-other-keys) initargs
    (setf (slot-value animatable 'location) (decode 'vec2 location))
    (setf (direction animatable) direction)
    (setf (state animatable) state)
    (when (and animation (< 0 (length (animations animatable))))
      (setf (animation animatable) animation)
      (setf (frame animatable) frame))
    (setf (health animatable) health)
    (setf (stun-time animatable) stun-time)
    animatable))

(define-encoder (player save-v0) (_b packet)
  (let ((trace (movement-trace player)))
    (with-packet-entry (stream "trace.dat" packet :element-type '(unsigned-byte 8))
      (nibbles:write-ub16/le (length trace) stream)
      (dotimes (i (length trace))
        (nibbles:write-ieee-single/le (aref trace i) stream))))
  (list* :inventory (alexandria:hash-table-alist (storage player))
         (call-next-method)))

(define-decoder (player save-v0) (initargs packet)
  (call-next-method)
  (let ((trace (movement-trace player)))
    (ignore-errors
     (with-packet-entry (stream "trace.dat" packet :element-type '(unsigned-byte 8))
       (let ((count (nibbles:read-ub16/le stream)))
         (when (< (array-total-size trace) count)
           (adjust-array trace count))
         (setf (fill-pointer trace) count)
         (dotimes (i count)
           (setf (aref trace i) (nibbles:read-ieee-single/le stream)))))))
  (let ((inventory (getf initargs :inventory)))
    (setf (storage player) (alexandria:alist-hash-table inventory :test 'eq)))
  (when (unit :camera T)
    (snap-to-target (unit :camera T) player)))

(define-encoder (moving-platform save-v0) (_b _p)
  `(:location ,(encode (location moving-platform))
    :velocity ,(encode (velocity moving-platform))
    :state ,(state moving-platform)))

(define-decoder (moving-platform save-v0) (initargs _p)
  (destructuring-bind (&key location velocity state &allow-other-keys) initargs
    (setf (location moving-platform) (decode 'vec2 location))
    (setf (velocity moving-platform) (decode 'vec2 velocity))
    (setf (state moving-platform) state)
    moving-platform))

(define-encoder (rope save-v0) (_b _p)
  `(:extended ,(extended rope)))

(define-decoder (rope save-v0) (initargs _p)
  (destructuring-bind (&key extended &allow-other-keys) initargs
    (setf (extended rope) extended)))

(define-encoder (trigger save-v0) (_b _p)
  `(:active-p ,(active-p trigger)))

(define-decoder (trigger save-v0) (initargs _)
  (setf (active-p trigger) (getf initargs :active-p)))

(define-slot-coders (item save-v0) ((location :type vec2)))
