(in-package #:org.shirakumo.fraf.kandria)

(defclass rectangle (painter-tool)
  ((start-pos :initform NIL :accessor start-pos)
   (end-pos :initform NIL :accessor end-pos)
   (cache :initform (cons NIL NIL) :accessor cache)))

(defmethod label ((tool rectangle)) "")
(defmethod title ((tool rectangle)) "Rectangle")

(defmethod handle ((ev lose-focus) (tool rectangle))
  (handle (make-instance 'mouse-release :button :left :pos (or (end-pos tool) (vec 0 0))) tool))

(defmethod handle ((event mouse-release) (tool rectangle))
  (case (state tool)
    (:placing
     (let ((entity (entity tool))
           (start (shiftf (start-pos tool) NIL))
           (end (shiftf (end-pos tool) NIL))
           (whole (retained :shift)))
       (destructuring-bind (tile . cache) (cache tool)
         (with-commit (tool)
           ((repeat-tile-region entity start end tile whole))
           ((repeat-tile-region entity start end cache))))))))

(defun match-tile-layer (start x y)
  (let ((x (+ (vx start) (* x +tile-size+)))
        (y (+ (vy start) (* y +tile-size+))))
    (if (vec3-p start) (vec x y (vz start)) (vec x y))))

(defun repeat-tile-region (entity start end template &optional whole-chunks)
  (destructuring-bind (w h) (array-dimensions template)
    (when (and (< 0 w) (< 0 h))
      (let ((rw (abs (ceiling (- (vx end) (vx start)) +tile-size+)))
            (rh (abs (ceiling (- (vy end) (vy start)) +tile-size+)))
            (start (vmin start end)))
        (when whole-chunks
          (setf rw (* (floor rw (max 1 w)) w))
          (setf rh (* (floor rh (max 1 h)) h)))
        (loop for y from 0 below rh
              do (loop for x from 0 below rw
                       do (setf (tile (match-tile-layer start x y) entity)
                                (aref template (mod x w) (mod y h)))))))))

(defun cache-tile-region (entity start end)
  (let* ((w (abs (ceiling (- (vx end) (vx start)) +tile-size+)))
         (h (abs (ceiling (- (vy end) (vy start)) +tile-size+)))
         (template (make-array (list w h)))
         (start (vmin start end)))
    (loop for y from 0 below h
          do (loop for x from 0 below w
                   do (setf (aref template x y)
                            (tile (match-tile-layer start x y) entity))))
    template))

(defun create-tile-region (tile)
  (destructuring-bind (x y &optional (w 1) (h 1)) tile
    (let ((cache (make-array (list w h))))
      (loop for i from 0 below h
            do (loop for j from 0 below w
                     do (setf (aref cache j i) (list (+ x j) (+ y i) 1 1))))
      cache)))

(defmethod paint-tile ((tool rectangle) event)
  (let* ((entity (entity tool))
         (loc (mouse-tile-pos (pos event)))
         (loc (if (show-solids entity)
                  loc
                  (vec (vx loc) (vy loc) (layer (sidebar (editor tool)))))))
    (cond ((null (tile loc entity)))
          ((and (typep event 'mouse-press) (eql :middle (button event)))
           (setf (tile-to-place (sidebar (editor tool)))
                 (tile loc entity)))
          (T
           (setf (state tool) :placing)
           (unless (start-pos tool)
             (setf (start-pos tool) loc)
             (setf (end-pos tool) (vcopy loc))
             (setf (car (cache tool)) (create-tile-region (tile-to-place tool)))
             (setf (cdr (cache tool)) NIL))
           (when (v/= (end-pos tool) loc)
             (when (cdr (cache tool))
               (repeat-tile-region entity (start-pos tool) (end-pos tool) (cdr (cache tool))))
             (setf (end-pos tool) loc)
             (setf (cdr (cache tool)) (cache-tile-region entity (start-pos tool) (end-pos tool)))
             (when (car (cache tool))
               (repeat-tile-region entity (start-pos tool) (end-pos tool) (car (cache tool))
                                   (retained :shift))))))))
