(in-package #:org.shirakumo.fraf.kandria)

(defclass save-v0 (v0) ())
(defclass save-v1 (save-v0) ())
(defclass save-v1.1 (save-v1) ())
(defclass save-v1.2 (save-v1.1) ())
(defclass save-v1.3 (save-v1.2) ())

#-kandria-demo
(defmethod supported-p ((_ save-v1.2)) T)
(defmethod supported-p ((_ save-v1.3)) T)

(defun current-save-version ()
  (make-instance 'save-v1.3))

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
                    :zoom (if (find-panel 'editor)
                              1.0
                              (zoom (camera +world+))))
              stream)
      (princ* (encode (unit 'environment world))
              stream))))

(define-decoder (world save-v0) (_b packet)
  (destructuring-bind (world-data &optional env-data) (parse-sexps (packet-entry "global.lisp" packet :element-type 'character))
    (destructuring-bind (&key region (clock 0.0) (timestamp (initial-timestamp)) (zoom 1.0)) world-data
      (setf (clock world) clock)
      (setf (timestamp world) timestamp)
      (setf (zoom (camera +world+)) zoom)
      (setf (intended-zoom (camera +world+)) zoom)
      (let* ((region (cond ((and (region world) (eql region (name (region world))))
                            ;; Ensure we trigger necessary region reset events even if we're still in the same region.
                            (issue world 'switch-region :region (region world))
                            (region world))
                           (T
                            (load-region region world))))
             (initargs (ignore-errors (first (parse-sexps (packet-entry (format NIL "regions/~(~a~).lisp" (name region))
                                                                        packet :element-type 'character))))))
        (when initargs (decode region initargs))
        (setf (storyline world) (decode 'quest:storyline))))
    (when env-data
      (decode (unit 'environment world) env-data))))

(define-encoder (quest:storyline save-v0) (_b packet)
  (with-packet-entry (stream "storyline.lisp" packet
                             :element-type 'character)
    (princ* `(,(quest:name quest:storyline)
              :variables ,(encode-payload 'bindings (quest:bindings quest:storyline) packet save-v0)) stream)
    (loop for quest being the hash-values of (quest:quests quest:storyline)
          do (princ* (encode quest) stream))))

(define-decoder (quest:storyline save-v1) (_b packet)
  (destructuring-bind ((&key variables) . quests) (parse-sexps (packet-entry "storyline.lisp" packet
                                                                  :element-type 'character))
    (let ((storyline (quest:find-named 'kandria T)))
      (v:with-muffled-logging ()
        (quest:reset storyline))
      (quest:merge-bindings storyline (decode-payload variables 'bindings packet save-v1))
      (loop for (name . initargs) in quests
            for quest = (handler-case (quest:find-quest name storyline)
                          (error ()
                            (v:warn :kandria.save "Reference to unknown quest ~s, ignoring!" name)
                            NIL))
            do (when quest (decode quest initargs)))
      storyline)))

(define-decoder (quest:storyline save-v1.1) (_b packet)
  (destructuring-bind ((storyline &key variables) . quests) (parse-sexps (packet-entry "storyline.lisp" packet
                                                                  :element-type 'character))
    (let ((storyline (if (null storyline)
                         (make-instance 'quest:storyline)
                         (quest:find-named storyline T))))
      (v:with-muffled-logging ()
        (quest:reset storyline))
      (quest:merge-bindings storyline (decode-payload variables 'bindings packet save-v1.1))
      (loop for (name . initargs) in quests
            for quest = (handler-case (quest:find-quest name storyline)
                          (error ()
                            (v:warn :kandria.save "Reference to unknown quest ~s, ignoring!" name)
                            NIL))
            do (when quest (decode quest initargs)))
      storyline)))

(define-encoder (quest:quest save-v0) (buffer _p)
  (list (quest:name quest:quest)
        :status (quest:status quest:quest)
        :tasks (loop for quest being the hash-values of (quest:tasks quest:quest)
                     collect (encode quest))
        :clock (clock quest:quest)
        :bindings (encode-payload 'bindings (quest:bindings quest:quest) _p save-v0)))

(define-decoder (quest:quest save-v0) (initargs packet)
  (destructuring-bind (&key status (clock 0.0) tasks bindings) initargs
    (cond (tasks
           (setf (quest:status quest:quest) status)
           (loop for (name . initargs) in tasks
                 for task = (handler-case (quest:find-task name quest:quest)
                              (error ()
                                (v:warn :kandria.save "Reference to unknown task ~s, ignoring!" name)
                                NIL))
                 do (when task (decode task initargs))))
          (T
           ;; KLUDGE: we only do this if there's no task state saved as we then want to
           ;;         achieve the default changes from the quest definition. Typically
           ;;         from loading the initial state.
           (setf (quest:status quest:quest) :inactive)
           (ecase status
             (:inactive)
             (:active (quest:activate quest:quest))
             (:complete (quest:complete quest:quest))
             (:failed (quest:fail quest:quest)))))
    (setf (clock quest:quest) clock)
    (quest:merge-bindings quest:quest (decode-payload bindings 'bindings packet save-v0))))

(define-encoder (quest:task save-v0) (_b _p)
  (list (quest:name quest:task)
        :status (quest:status quest:task)
        :bindings (encode-payload 'bindings (quest:bindings quest:task) _p save-v0)
        :triggers (loop for trigger being the hash-values of (quest:triggers quest:task)
                        collect (encode trigger))))

(define-decoder (quest:task save-v0) (initargs packet)
  (destructuring-bind (&key status bindings triggers) initargs
    (setf (quest:status quest:task) status)
    (quest:merge-bindings quest:task (decode-payload bindings 'bindings packet save-v0))
    (loop for (name . initargs) in triggers
          for trigger = (handler-case (quest:find-trigger name quest:task)
                          (error ()
                            (v:warn :kandria.save "Reference to unknown trigger ~s, ignoring!" name)
                            NIL))
          do (when trigger (decode trigger initargs)))))

(define-encoder (quest:action save-v0) (_b _p)
  (list (quest:name quest:action)
        :status (quest:status quest:action)))

(define-decoder (quest:action save-v0) (initargs _p)
  (destructuring-bind (&key status) initargs
    ;; Note: we want to avoid causing the on-activate trigger to fire
    ;;       here as its changes should already be reflected by the rest of the save-state.
    (setf (quest:status quest:action) status)))

(define-encoder (quest:interaction save-v0) (_b _p)
  (list (quest:name quest:interaction)
        :status (quest:status quest:interaction)
        :bindings (encode-payload 'bindings (quest:bindings quest:interaction) _p save-v0)))

(define-decoder (quest:interaction save-v0) (initargs _p)
  (destructuring-bind (&key status bindings) initargs
    (quest:merge-bindings quest:interaction (decode-payload bindings 'bindings _p save-v0))
    (ecase status
      (:inactive
       (case (quest:status quest:interaction)
         (:active (quest:deactivate quest:interaction)))
       (setf (quest:status quest:interaction) status))
      (:active
       (case (quest:status quest:interaction)
         (:complete (setf (quest:status quest:interaction) :inactive)))
       (quest:activate quest:interaction))
      (:complete
       ;; Repeatable interactions need to be activated again first to ensure they appear on
       ;; the list of interactions.
       (when (and (repeatable-p quest:interaction)
                  (quest:active-p (quest:task quest:interaction)))
         (quest:activate quest:interaction))
       (quest:complete quest:interaction)))))

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
                          (when (save-p entity)
                            (add ephemeral (list* (name entity) (encode entity))))
                          (when (typep entity 'container)
                            (recurse entity)))
                         ((not (spawned-p entity))
                          (add create-new (list* (type-of entity) (encode entity))))))))
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
                      (leave entity parent))
                     (container (recurse entity))))))
        (recurse region)))
    ;; Update state on ephemeral ones
    (loop for (name . state) in ephemeral
          for unit = (unit name region)
          do (if unit
                 #-kandria-release
                 (with-simple-restart (continue "Ignore")
                   (decode unit state))
                 #+kandria-release
                 (decode unit state)
                 (warn "Unit named ~s referenced but not found." name)))
    ;; Add new entities that exist in the state
    (loop for (type . state) in create-new
          for entity = (with-simple-restart (continue "Ignore this entity.")
                         (decode-payload state (make-instance type) packet save-v0))
          do (when entity (enter entity region)))
    region))

(define-encoder (animatable save-v0) (_b _p)
  (let ((animation (animation animatable)))
    `(:location ,(encode (location animatable))
      :velocity ,(encode (velocity animatable))
      :direction ,(direction animatable)
      :state ,(state animatable)
      :animation ,(when animation (name animation))
      :frame ,(when animation (frame-idx animatable))
      :health ,(health animatable)
      :level ,(level animatable)
      :experience ,(experience animatable)
      :stun-time ,(stun-time animatable))))

(define-decoder (animatable save-v0) (initargs _p)
  (destructuring-bind (&key location (velocity '(0 0)) direction state animation frame health (level 1) (experience 0) stun-time &allow-other-keys) initargs
    (setf (slot-value animatable 'location) (decode 'vec2 location))
    (setf (velocity animatable) (decode 'vec2 velocity))
    (vsetf (frame-velocity animatable) 0 0)
    (setf (direction animatable) direction)
    (setf (state animatable)
          (if (and (eql :animated state) (eql animation 'stand))
              :normal
              state))
    (when (and animation (< 0 (length (animations animatable))))
      (setf (animation animatable) animation)
      (setf (frame animatable) frame))
    (setf (level animatable) level)
    (setf (experience animatable) experience)
    (setf (health animatable) health)
    (setf (stun-time animatable) stun-time)
    animatable))

(define-encoder (map-marker save-v0) (_b packet)
  (list (encode (map-marker-location map-marker))
        (map-marker-label map-marker)
        (encode (map-marker-color map-marker))))

(define-decoder (map-marker save-v0) (initargs _p)
  (destructuring-bind (location label color) initargs
    (make-map-marker (decode 'vec2 location)
                     label
                     (decode 'colored:rgb color))))

(define-encoder (player save-v0) (_b packet)
  (let ((trace (movement-trace player)))
    (with-packet-entry (stream "trace.dat" packet :element-type '(unsigned-byte 8))
      (nibbles:write-ub16/le (length trace) stream)
      (dotimes (i (length trace))
        (nibbles:write-ieee-single/le (aref trace i) stream))))
  ;; Set spawn point as current loc.
  (vsetf (spawn-location player) (vx (location player)) (vy (location player)))
  (list* :inventory (alexandria:hash-table-alist (storage player))
         :unlocked (alexandria:hash-table-keys (unlock-table player))
         :stats (stats player)
         :palette (palette-index player)
         :sword-level (sword-level player)
         :map-markers (mapcar #'encode (map-markers player))
         :nametag (nametag player)
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
  (destructuring-bind (&key inventory unlocked map-markers (stats (make-stats)) (palette 0) (sword-level 0) nametag &allow-other-keys) initargs
    (setf (storage player) (alexandria:alist-hash-table inventory :test 'eq))
    (let ((table (unlock-table player)))
      (clrhash table)
      (dolist (item unlocked)
        (setf (gethash item table) T)))
    (setf (map-markers player) (loop for marker in map-markers
                                     collect (decode 'map-marker marker)))
    (setf (stats player) stats)
    (setf (palette-index player) palette)
    (setf (sword-level player) sword-level)
    (when nametag
      (setf (nametag player) nametag))
    ;; Force state to normal to avoid being caught in save animation
    (setf (state player) :normal)
    (snap-to-target (camera +world+) player)))

(define-encoder (npc save-v0) (_b _p)
  (let ((last (car (last (path npc)))))
    (list* :path (when last (encode (second last)))
           :ai-state (ai-state npc)
           :walk (walk npc)
           :target (when (target npc) (encode (target npc)))
           :companion (when (companion npc) (name (companion npc)))
           :inventory (alexandria:hash-table-alist (storage npc))
           :nametag (nametag npc)
           (call-next-method))))

(define-decoder (npc save-v0) (initargs _p)
  (call-next-method)
  (destructuring-bind (&key (ai-state :normal) nametag walk target companion inventory &allow-other-keys) initargs
    ;; Force state to normal if animated to get them unstuck on a bad save.
    (when (eql :animated (state npc))
      (setf (state npc) :normal))
    (setf (ai-state npc) ai-state)
    (setf (walk npc) walk)
    (setf (target npc) (when target (decode 'vec2 target)))
    (setf (companion npc) (when companion (unit companion T)))
    (setf (storage npc) (alexandria:alist-hash-table inventory :test 'eq))
    (when nametag
      (setf (nametag npc) nametag))
    ;; KLUDGE: We ignore the path here and don't restore it, as restoring it
    ;;         requires a complete chunk graph, which we likely don't have yet
    ;;         at this stage, and thus can't compute a route. We instead rely
    ;;         on the NPC's state machine to reconstruct the missing path.
    (setf (path npc) ())))

(define-encoder (chunk save-v0) (_b _p)
  `(:unlocked-p ,(unlocked-p chunk)))

(define-decoder (chunk save-v0) (initargs _p)
  (setf (unlocked-p chunk) (getf initargs :unlocked-p)))

(define-encoder (moving-platform save-v0) (_b _p)
  `(:location ,(encode (location moving-platform))
    :velocity ,(encode (velocity moving-platform))
    :state ,(state moving-platform)))

(define-decoder (moving-platform save-v0) (initargs _p)
  (destructuring-bind (&key location velocity state &allow-other-keys) initargs
    (setf (location moving-platform) (decode 'vec2 location))
    (setf (velocity moving-platform) (decode 'vec2 velocity))
    (setf (slot-value moving-platform 'state) state)
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

(define-encoder (item save-v0) (_b _p)
  `(:location ,(encode (location item))))

(define-decoder (item save-v0) (initargs _p)
  (setf (location item) (decode 'vec2 (getf initargs :location)))
  item)

(define-encoder (spawner save-v0) (_b _p)
  ;; KLUDGE: Ensure the spawner deactivates now if
  ;;         we save in the same chunk as the spawner and
  ;;         it is auto-deactivate.
  (when (and (auto-deactivate spawner)
             (not (null (reflist spawner)))
             (done-p spawner))
    (setf (active-p spawner) NIL))
  `(:active-p ,(active-p spawner)))

(define-decoder (spawner save-v0) (initargs _p)
  (setf (reflist spawner) ())
  (setf (active-p spawner) (getf initargs :active-p)))

(define-encoder (locked-door save-v0) (_b _p)
  `(:unlocked-p ,(unlocked-p locked-door)))

(define-decoder (locked-door save-v0) (initargs _p)
  (setf (unlocked-p locked-door) (getf initargs :unlocked-p)))

(define-encoder (interactable-animated-sprite save-v0) (_b _p)
  `(:animation ,(name (animation interactable-animated-sprite))))

(define-decoder (interactable-animated-sprite save-v0) (initargs _p)
  (if (< 0 (length (animations interactable-animated-sprite)))
      (setf (animation interactable-animated-sprite) (getf initargs :animation))
      (setf (pending-animation interactable-animated-sprite) (getf initargs :animation))))

(define-encoder (environment-controller save-v0) (_b _p)
  `(:environment ,(when (environment environment-controller)
                    (name (environment environment-controller)))
    :area-states ,(area-states environment-controller)
    :override ,(if (symbolp (override environment-controller))
                   (override environment-controller)
                   (encode (override environment-controller)))))

(define-decoder (environment-controller save-v0) (initargs _p)
  (destructuring-bind (&key area-states environment override) initargs
    (setf (area-states environment-controller) area-states)
    (setf (override environment-controller) (if (symbolp override)
                                                override
                                                (decode 'resource override)))
    (switch-environment environment-controller (environment environment))))

(define-encoder (hider save-v0) (_b _p)
  `(:active-p ,(active-p hider)))

(define-decoder (hider save-v0) (initargs _p)
  (setf (active-p hider) (getf initargs :active-p)))

(define-encoder (blocker save-v0) (_b _p)
  `(:active-p ,(<= 1.0 (visibility blocker))))

(define-decoder (blocker save-v0) (initargs _p)
  (setf (visibility blocker) (if (getf initargs :active-p) 1.0 0.0)))

(define-encoder (gate save-v0) (_b _p)
  `(:state ,(state gate)))

(define-decoder (gate save-v0) (initargs _p)
  (setf (state gate) (getf initargs :state)))

(define-encoder (station save-v0) (_b _p)
  `(:unlocked-p ,(unlocked-p station)))

(define-decoder (station save-v0) (initargs _p)
  (setf (unlocked-p station) (getf initargs :unlocked-p)))

(define-encoder (chest save-v0) (_b _p)
  `(:state ,(state chest)))

(define-decoder (chest save-v0) (initargs _p)
  (setf (state chest) (getf initargs :state))
  (setf (pending-animation chest)
        (ecase (getf initargs :state)
          (:open 'open)
          (:closed 'closed))))
