(in-package #:org.shirakumo.fraf.kandria)

(defclass painter-tool (tool)
  ())

(defmethod handle ((event mouse-press) (tool painter-tool))
  (paint-tile tool event)
  (if (typep (entity tool) 'chunk)
      (loop for layer across (layers (entity tool))
            for i from 0
            do (if (= i (layer (sidebar (editor tool))))
                   (setf (visibility layer) 1.0)
                   (setf (visibility layer) 0.5)))
      (setf (visibility (entity tool)) 1.0)))

(defmethod handle :after ((event mouse-release) (tool painter-tool))
  (loop for layer across (layers (entity tool))
        do (setf (visibility layer) 1.0))
  (setf (state tool) NIL))

(defmethod handle ((ev lose-focus) (tool painter-tool))
  (handle (make-instance 'mouse-release :button :left :pos (or (end-pos tool) (vec 0 0))) tool))

(defmethod handle ((event mouse-move) (tool painter-tool))
  (setf (cursor *context*) :crosshair)
  (case (state tool)
    (:placing
     (paint-tile tool event))))

(defmethod handle ((event key-press) (tool painter-tool))
  (case (key event)
    (:1 (setf (layer (sidebar (editor tool))) 0))
    (:2 (setf (layer (sidebar (editor tool))) 1))
    (:3 (setf (layer (sidebar (editor tool))) 2))
    (:4 (setf (layer (sidebar (editor tool))) 3))
    (:5 (setf (layer (sidebar (editor tool))) 4))))

(defmethod tile-to-place ((tool painter-tool))
  (cond ((retained :left)
         (tile-to-place (sidebar (editor tool))))
        (T
         '(0 0 1 1))))

(defun cache-tile (chunk loc tile)
  (cache-tile-region
   (cond ((not (typep chunk 'chunk))
          chunk)
         ((vec3-p loc)
          (aref (layers chunk) (floor (vz loc))))
         (T
          chunk))
   (vxy loc) (vec (+ (vx loc) (* +tile-size+ (third tile)))
                  (+ (vy loc) (* +tile-size+ (fourth tile))))))

(defun stamp-tile (chunk loc template)
  (destructuring-bind (w h) (array-dimensions template)
    (repeat-tile-region
     (if (vec3-p loc)
         (aref (layers chunk) (floor (vz loc)))
         chunk)
     (vxy loc) (vec (+ (vx loc) (* +tile-size+ w))
                    (+ (vy loc) (* +tile-size+ h)))
     template)))

(defclass paint (painter-tool)
  ((stroke :initform NIL :accessor stroke)))

(defmethod label ((tool paint)) "")
(defmethod title ((tool paint)) "Paint (P)")

(defmethod end-pos ((tool paint))
  (caar (stroke tool)))

(defmethod handle ((event mouse-release) (tool paint))
  (case (state tool)
    (:placing
     (setf (state tool) NIL)
     (let ((entity (entity tool)))
       (destructuring-bind (tile . stroke) (nreverse (stroke tool))
         (with-commit (tool "Paint tile ~a" tile)
             ((loop for (loc . _) in stroke
                    do (setf (tile loc entity) tile)))
             ((loop for (loc . tile) in (reverse stroke)
                    do (stamp-tile entity loc tile)))))
       (setf (stroke tool) NIL)))))

(defmethod handle ((event mouse-scroll) (tool paint))
  (destructuring-bind (x y &optional w ha) (tile-to-place (sidebar (editor tool)))
    (setf (tile-to-place (sidebar (editor tool)))
          (if (retained :shift)
              (list x (+ y (floor (signum (delta event)))))
              (list (+ x (floor (signum (delta event)))) y)))))

(defmethod paint-tile ((tool paint) event)
  (let* ((entity (entity tool))
         (loc (mouse-world-pos (pos event)))
         (loc (if (show-solids entity)
                  loc
                  (vec (vx loc) (vy loc) (layer (sidebar (editor tool))))))
         (tile (tile-to-place tool)))
    (cond ((retained :control)
           (let* ((base-layer (aref (layers entity) +base-layer+))
                  (layer (copy-seq (pixel-data base-layer)))
                  (solids (copy-seq (pixel-data entity))))
             (with-cleanup-on-failure (progn (setf (pixel-data base-layer) layer)
                                             (setf (pixel-data entity) solids))
               (with-commit (tool "Auto tile")
                 ((auto-tile entity (vxy loc) (cdr (assoc (tile-set (sidebar (editor tool)))
                                                          (tile-types (tile-data entity))))))
                 ((setf (pixel-data base-layer) layer)
                  (setf (pixel-data entity) solids))))))
          ((retained :shift)
           (let* ((base-layer (aref (layers entity) (if (show-solids entity)
                                                        5
                                                        (floor (vz loc)))))
                  (original (copy-seq (pixel-data base-layer))))
             (with-commit (tool "Bucket fill")
               ((flood-fill entity loc tile))
               ((setf (pixel-data base-layer) original)))))
          ((and (typep event 'mouse-press) (eql :middle (button event)))
           (when (tile loc entity)
             (setf (tile-to-place (sidebar (editor tool)))
                   (tile loc entity))))
          ((tile loc entity)
           (setf (state tool) :placing)
           (unless (stroke tool)
             (push tile (stroke tool)))
           (when (or (null (cdr (stroke tool)))
                     (v/= loc (caar (stroke tool))))
             ;; FIXME: Make this work right with multiple tiles placement.
             (push (cons loc (cache-tile entity loc tile)) (stroke tool))
             (setf (tile loc entity) tile))))))
