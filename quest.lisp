(in-package #:org.shirakumo.fraf.kandria)

(defclass place-marker (sized-entity resizable ephemeral)
  ())

(defmethod (setf location) ((marker place-marker) (entity located-entity))
  (setf (location entity) (location marker)))

(defmethod (setf location) ((name symbol) (entity located-entity))
  (setf (location entity) (location (unit name +world+))))

(defclass quest (quest:quest)
  ())

(defmethod quest:activate :after ((quest quest))
  (status :important "New quest: ~a" (quest:title quest)))

(defmethod quest:make-assembly ((_ quest))
  (make-instance 'assembly))

(defclass task (quest:task)
  ())

(defmethod quest:make-assembly ((task task))
  (make-instance 'assembly))

(defclass interaction (quest:interaction)
  ())

(defmethod quest:activate ((trigger interaction))
  (with-simple-restart (abort "Don't activate the interaction.")
    (let ((interactable (unit (quest:interactable trigger) +world+)))
      (when (typep interactable 'interactable)
        (pushnew trigger (interactions interactable))))))

(defmethod quest:deactivate ((trigger interaction))
  (let ((interactable (unit (quest:interactable trigger) +world+)))
    (when (typep interactable 'interactable)
      (setf (interactions interactable) (remove interactable (interactions interactable))))))

(defmethod quest:complete ((trigger interaction))
  (let ((interactable (unit (quest:interactable trigger) +world+)))
    (when (typep interactable 'interactable)
      (setf (interactions interactable) (remove interactable (interactions interactable))))))

(defclass assembly (dialogue:assembly)
  ())

(defmethod dialogue:wrap-lexenv ((assembly assembly) form)
  `(let* ((world +world+)
          (player (unit 'player world))
          (region (unit 'region world))
          (interaction (interaction (find-panel 'dialog)))
          (task (quest:task interaction))
          (quest (quest:quest task))
          (has-more-dialogue (rest (interactions (find-panel 'dialog)))))
     (declare (ignorable world player region interaction task quest has-more-dialogue))
     (labels ((thing (thing)
                (if (symbolp thing) (quest:find-named thing task) thing))
              (activate (&rest things)
                (loop for thing in things do (quest:activate (thing thing))))
              (deactivate (&rest things)
                (loop for thing in things do (quest:deactivate (thing thing))))
              (complete (&rest things)
                (loop for thing in things do (quest:complete (thing thing))))
              (fail (&rest things)
                (loop for thing in things do (quest:fail (thing thing))))
              (active-p (&rest things)
                (loop for thing in things always (quest:active-p (thing thing))))
              (complete-p (&rest things)
                (loop for thing in things always (eql :complete (quest:status (thing thing)))))
              (failed-p (&rest things)
                (loop for thing in things always (eql :failed (quest:status (thing thing)))))
              (have (thing &optional (inventory player))
                (have thing inventory))
              (store (item &optional (inventory player))
                (store item inventory))
              (retrieve (item &optional (inventory player))
                (retrieve item inventory)))
       (declare (ignorable #'activate #'deactivate #'complete #'fail #'active-p #'complete-p #'failed-p #'have #'store #'retrieve))
       ,form)))

(defmethod load-quest ((packet packet) (storyline quest:storyline))
  (with-kandria-io-syntax
    (destructuring-bind (header info) (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character))
      (let ((quest (decode-payload
                    (list* :storyline storyline info) (type-prototype 'quest) packet
                    (destructuring-bind (&key identifier version) header
                      (assert (eql 'quest identifier))
                      (coerce-version version)))))
        (setf (quest:find-quest (quest:name quest) storyline) quest)))))
