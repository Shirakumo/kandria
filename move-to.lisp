(in-package #:org.shirakumo.fraf.kandria)

(defstruct (node-graph
            (:constructor %make-node-graph (width height &optional (grid (make-array (* width height) :initial-element NIL)))))
  (width 0 :type (unsigned-byte 16))
  (height 0 :type (unsigned-byte 16))
  (grid NIL :type simple-vector))

(defstruct (move-node (:constructor make-move-node (to)))
  (to 0 :type (unsigned-byte 16)))
(defstruct (crawl-node (:include move-node) (:constructor make-crawl-node (to))))
(defstruct (climb-node (:include move-node) (:constructor make-climb-node (to))))
(defstruct (fall-node (:include move-node) (:constructor make-fall-node (to))))
(defstruct (jump-node (:include move-node) (:constructor make-jump-node (to strength)))
  (strength NIL :type vec2))

(declaim (inline node-idx))
(defun node-idx (graph x y)
  (+ x (* y (node-graph-width graph))))

(declaim (inline node))
(defun node (graph x y)
  (the list (svref (node-graph-grid graph) (node-idx graph x y))))

(declaim (inline (setf node)))
(defun (setf node) (value graph x y)
  (setf (svref (node-graph-grid graph) (node-idx graph x y)) value))

(defun connect-nodes (graph type ax ay bx by w h)
  (let ((constructor (ecase type
                       (move 'make-move-node)
                       (crawl 'make-crawl-node)
                       (climb 'make-climb-node)
                       (fall 'make-fall-node))))
    (when (and (<= 0 ax (1- w)) (<= 0 ay (1- h)) (<= 0 bx (1- w)) (<= 0 by (1- h)))
      (case constructor
        ((make-fall-node)
         (push (funcall constructor (node-idx graph bx by))
               (node graph ax ay)))
        (T
         (push (funcall constructor (node-idx graph bx by))
               (node graph ax ay))
         (push (funcall constructor (node-idx graph ax ay))
               (node graph bx by)))))))

(defun connect-jump (graph ax ay bx by strength)
  (push (make-jump-node (node-idx graph bx by) strength)
        (node graph ax ay)))

(defmacro do-nodes ((x y graph) &body body)
  `(loop for ,y downfrom (1- (node-graph-height ,graph)) to 0
         do (loop for ,x from 0 below (node-graph-width ,graph)
                  do (progn ,@body))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun compile-filter (vars filter)
    `(and ,@(loop for i from 0 below (length filter)
                  for f in filter
                  for v in vars
                  unless (eql '_ f)
                  collect `(tile-type-p ,v ',f)))))

(defmacro with-filters ((solids w h x y) &body filters)
  (let ((solidsg (gensym "SOLIDS"))
        (vars (loop for i from 0 below 9 collect (make-symbol (format NIL "~d/~d"
                                                                      (- (mod i 3) 1)
                                                                      (- (floor i 3) 1))))))
    `(let* ((,solidsg ,solids)
            ,@(loop for i from 0 below (length vars)
                    for var in vars
                    for ox = (- (mod i 3) 1)
                    for oy = (- 1 (floor i 3))
                    collect `(,var (if (and ,(case ox
                                               (-1 `(<= 0 (+ ,x ,ox)))
                                               (+0 T)
                                               (+1 `(< (+ ,x ,ox) ,w)))
                                            ,(case oy
                                               (-1 `(<= 0 (+ ,y ,oy)))
                                               (+0 T)
                                               (+1 `(< (+ ,y ,oy) ,h))))
                                       (aref ,solidsg (* 2 (+ ,x ,ox (* (+ ,y ,oy) ,w))))
                                       0))))
       (declare (ignorable ,@vars))
       ,@(loop for (filter . body) in filters
               collect `(when ,(compile-filter vars filter)
                          ,@body)))))

(trivial-indent:define-indentation with-filters ((&whole 4 &rest 1) &rest (&whole 2 (&whole 1 &rest 1) &rest 1)))

(defun compute-jump-configurations (&key (vmax (vec 1.9 3.9)))
  (loop for xfrac from 0 to 1 by 0.1d0
        nconc (loop for yfrac from 0.1 to 1 by 0.1d0
                    collect (vec (* xfrac (vx vmax)) (* yfrac (vy vmax))))))

(defun create-jump-connections (solids graph ox oy dir)
  (let* ((g (v/ (gravity (make-instance 'air)) +tile-size+))
         (w (node-graph-width graph))
         (h (node-graph-height graph))
         (jumps (compute-jump-configurations)))
    (flet ((tile (x y)
             (if (and (<= 0 x (1- w)) (<= 0 y (1- h)))
                 (aref solids (* 2 (+ x (* w y))))
                 0)))
      ;; Scan in a range around the origin
      (loop for i from 1 below 12
            for x = (+ ox (* dir i))
            do (loop for y from (- oy 3) to (+ oy 9)
                     do (when (and (= 0 (tile x y))
                                   (< 0 (tile x (1- y))))
                          (print (list x y ox oy))
                          (dolist (vel jumps)
                            (loop for tt from 0 by 0.01
                                  for pos = (vec x y) then (v+ pos acc)
                                  for idx = (+ (round (vx pos)) (* w (floor (vy pos))))
                                  for acc = (vec (/ (vx vel) (- dir) +tile-size+)
                                                 (/ (vy vel) +tile-size+))
                                  then (v+ acc g)
                                  do (cond ((not (and (<= 0 (vx pos) (1- w))
                                                      (<= 0 (vy pos) (1- h))))
                                            (loop-finish))
                                           ((v= pos (vec ox oy))
                                            (connect-jump graph x y ox oy vel)
                                            (return-from create-jump-connections))
                                           ((< 0 (aref solids (* 2 idx)))
                                            (loop-finish)))))))))))

(defun create-connections (solids graph)
  (declare (optimize speed))
  (let ((w (node-graph-width graph))
        (h (node-graph-height graph)))
    (declare (type (simple-array (unsigned-byte 8)) solids))
    (flet ((tile (x y)
             (if (and (<= 0 x (1- w)) (<= 0 y (1- h)))
                 (aref solids (* 2 (+ x (* w y))))
                 0)))
      (do-nodes (x y graph)
        (with-filters (solids w h x y)
          ((o o _
            o o _
            s s _)
           (connect-nodes graph 'move (1- x) y x y w h))
          ((_ o _
            o o _
            o s _)
           (unless (and (< 3 (tile x (1- y)))
                        (< 0 (tile (1- x) (- y 2))))
             (connect-nodes graph 'climb (1- x) (1- y) x y w h)
             (create-jump-connections solids graph x y -1)
             (loop for yy downfrom y above 0
                   do (when (< 0 (tile (1- x) yy))
                        (connect-nodes graph 'fall x y (1- x) (1+ yy) w h)
                        (loop-finish)))))
          ((_ o _
            _ o o
            _ s o)
           (unless (and (< 3 (tile x (1- y)))
                        (< 0 (tile (1+ x) (- y 2))))
             (connect-nodes graph 'climb x y (1+ x) (1- y) w h)
             (create-jump-connections solids graph x y +1)
             (loop for yy downfrom y above 0
                   do (when (< 0 (tile (1+ x) yy))
                        (connect-nodes graph 'fall x y (1+ x) (1+ yy) w h)
                        (loop-finish)))))
          ((_ b _
            o o _
            _ b _)
           (connect-nodes graph 'crawl (1- x) y x y w h))
          ((s o _
            s o _
            _ _ _)
           (connect-nodes graph 'climb x (1+ y) x y w h))
          ((_ o s
            _ o s
            _ _ _)
           (connect-nodes graph 'climb x (1+ y) x y w h))
          ((_ o _
            _ p b
            _ _ _)
           (connect-nodes graph 'climb x (1+ y) x y w h))
          ((_ p b
            _ o b
            _ _ _)
           (connect-nodes graph 'climb x (1+ y) x y w h))
          ((_ _ _
            _ o /
            _ s _)
           (connect-nodes graph 'move x y (1+ x) (1+ y) w h))
          ((_ _ _
            / o _
            _ s _)
           (connect-nodes graph 'move x y (1- x) (1+ y) w h))
          ((_ _ _
            o o b
            o o o)
           (create-jump-connections solids graph x y -1))
          ((_ _ _
            b o o
            o o o)
           (create-jump-connections solids graph x y +1)))))))

(defun make-node-graph (solids w h)
  (let ((graph (%make-node-graph w h)))
    (create-connections solids graph)
    graph))

(defclass movable (moving)
  ((current-node :initform NIL :accessor current-node)
   (path :initform NIL :accessor path)))

(defgeneric capable-p (movable edge))
(defmethod capable-p ((movable movable) (edge move-node)) T)
(defmethod capable-p ((movable movable) (edge fall-node)) T)
(defmethod capable-p ((movable movable) (edge jump-node)) NIL)
(defmethod capable-p ((movable movable) (edge crawl-node)) NIL)
(defmethod capable-p ((movable movable) (edge climb-node)) NIL)
