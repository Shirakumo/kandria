(in-package #:org.shirakumo.fraf.leaf)

(defclass interaction (event)
  ((with :initarg :with :accessor with)))

(define-shader-subject interactable (sprite-entity)
  ((bsize :initform (vec +tile-size+ +tile-size+))
   (interactions :initform () :accessor interactions)))

(defmethod quest:activate ((trigger quest:interaction))
  (with-simple-restart (abort "Don't activate the interaction.")
    (let ((interactable (unit (quest:interactable trigger) +world+)))
      (with-new-value-restart (interactable) (new-value "Supply a new interactable to use.")
        (unless (typep interactable 'interactable)
          (error "Failed to find interactable for trigger: ~s"
                 (quest:interactable trigger))))
      (pushnew trigger (interactions interactable)))))

;; (define-shader-subject npc (lit-animated-sprite profile-entity interactable)
;;   ())
