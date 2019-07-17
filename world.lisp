(in-package #:org.shirakumo.fraf.leaf)

(define-subject world ()
  ((flare:name :initform 'world)
   (storyline :initarg :storyline :accessor storyline)
   (maps :initarg :maps :accessor maps)))

(define-handler (world trial:tick) (ev fc)
  (when (= 0 (mod fc 10))
    (quest:try (storyline world))))

(define-handler (world interaction) (ev with)
  (when (typep with 'interactable)
    (setf (current-dialog (unit :textbox +level+))
          (quest:dialogue (first (interactions with))))))

(define-handler (world request-level) (ev level)
  (let ((map (or (gethash level (maps world))
                 (error "Cannot switch to unknown level ~s" level)))
        (level (make-instance 'level :name level)))
    (load-region (pool-path 'leaf map) level)
    (change-scene (handler *context*) level)))

(defclass quest (quest:quest)
  ())

(defmethod quest:make-assembly ((_ quest))
  (make-instance 'assembly))

(defclass assembly (dialogue:assembly)
  ())

(defmethod dialogue:wrap-lexenv ((_ assembly) form)
  `(with-memo ((world (unit 'world +level+))
               (player (unit 'player +level+))
               (region (unit 'region +level+))
               (chunk (surface (unit 'player +level+))))
     ,form))

(defmethod load-world ((pathname pathname) scene)
  (cond ((equal "" (pathname-type pathname))
         ())
        (T
         (error "Unknown packet type: ~a" (pathname-type pathname)))))


