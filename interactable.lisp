(in-package #:org.shirakumo.fraf.leaf)

(defclass interaction (event)
  ((with :initarg :with :accessor with)))

(define-shader-subject interactable (sprite-entity)
  ((bsize :initform (vec +tile-size+ +tile-size+))
   (interactions :initform () :accessor interactions)))

(defmethod quest:activate ((trigger quest:interaction))
  (with-simple-restart (abort "Don't activate the interaction.")
    (let ((interactable (unit (quest:interactable trigger) +level+)))
      (with-new-value-restart (interactable) (new-value "Supply a new interactable to use.")
        (unless (typep interactable 'interactable)
          (error "Failed to find interactable for trigger: ~s"
                 (quest:interactable trigger))))
      (pushnew trigger (interactions interactable)))))

(define-shader-subject npc (animated-sprite-subject profile-entity interactable)
  ())

(define-shader-subject fi (npc)
  ()
  (:default-initargs
   :name 'fi
   :bsize (nv/ (vec 16 32) 2)
   :size (vec 32 40)
   :texture (asset 'leaf 'fi)
   :animations '((stand 0 8 :step 0.1))
   :profile-title "Fi"
   :profile-texture (asset 'leaf 'fi-profile)
   :profile-animations '((normal 0 1)
                         (normal-blink 0 3 :step 0.1 :next normal))))
