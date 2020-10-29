(in-package #:org.shirakumo.fraf.kandria)

(defclass quest (quest:quest)
  ())

(defmethod quest:make-assembly ((_ quest))
  (make-instance 'assembly))

(defclass task (quest:task)
  ())

(defmethod quest:make-assembly ((task task))
  (make-instance 'assembly))

(defclass assembly (dialogue:assembly)
  ())

(defmethod dialogue:wrap-lexenv ((assembly assembly) form)
  `(let* ((world +world+)
          (player (unit 'player world))
          (region (unit 'region world))
          (interaction (interaction (find-panel 'dialog)))
          (task (quest:task interaction))
          (quest (quest:quest task))
          (inventory (inventory player))
          (has-more-dialogue (rest (interactions (find-panel 'dialog)))))
     (declare (ignorable world player region interaction task quest inventory has-more-dialogue))
     (flet ((activate (thing)
              (quest:activate (if (symbolp thing) (quest:find-named thing task) thing)))
            (complete (thing)
              (quest:complete (if (symbolp thing) (quest:find-named thing task) thing)))
            (fail (thing)
              (quest:fail (if (symbolp thing) (quest:find-named thing task) thing)))
            (have (thing &optional (place inventory))
              (have thing place)))
       (declare (ignorable #'activate #'complete #'fail #'have))
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
