(in-package #:org.shirakumo.fraf.kandria)

(defstruct (node-graph
            (:constructor %make-node-graph (width height &optional (grid (make-array (* width height) :initial-element NIL)))))
  (width 0 :type (unsigned-byte 16))
  (height 0 :type (unsigned-byte 16))
  (grid NIL :type simple-vector))

(defstruct (move-node (:constructor make-move-node (to)))
  (to 0 :type (unsigned-byte 16)))
(defstruct (walk-node (:include move-node) (:constructor make-walk-node (to))))
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
                       (walk 'make-walk-node)
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

(defun compute-jump-configurations (&key (vmax (vec 2.0 3.4)))
  (sort (loop for xfrac from 0 to 1 by 0.1d0
              nconc (loop for yfrac from 0.1 to 1 by 0.1d0
                          collect (vec (* xfrac (vx vmax)) (* yfrac (vy vmax)))))
        (lambda (a b) (< (vlength a) (vlength b)))))

(defun create-jump-connections (solids graph ox oy dir)
  (declare (optimize speed))
  (declare (type (simple-array (unsigned-byte 8)) solids))
  (declare (type (unsigned-byte 16) ox oy))
  (declare (type (integer -1 +1) dir))
  (let* ((g (v/ (gravity (make-instance 'air)) +tile-size+))
         (w (node-graph-width graph))
         (h (node-graph-height graph))
         (jumps (compute-jump-configurations)))
    (flet ((tile (x y)
             (if (and (<= 0 x (1- w)) (<= 0 y (1- h)))
                 (aref solids (* 2 (+ x (* w y))))
                 0)))
      ;; Scan in a range around the origin
      (loop for i from 2 below 12
            for x = (+ ox (* dir i))
            do (loop for y from (- oy 9) to (+ oy 9)
                     do (when (and (= 0 (tile x y))
                                   (< 0 (tile x (1- y))))
                          (dolist (vel jumps)
                            (loop for tt from 0.0 by 0.01
                                  for pos = (vec x y) then (v+ pos acc)
                                  for px = (the (signed-byte 16) (round (vx pos)))
                                  for py = (the (signed-byte 16) (floor (vy pos)))
                                  for acc = (vec (/ (vx vel) (- dir) +tile-size+)
                                                 (/ (vy vel) +tile-size+))
                                  then (v+ acc g)
                                  do (cond ((not (and (<= 0 px (1- w))
                                                      (<= 0 py (1- h))))
                                            (loop-finish))
                                           ((or (and (= px ox) (= py oy))
                                                (and (= px ox) (= py (1- oy))
                                                     (or (< 0 (tile (1+ ox) oy))
                                                         (< 0 (tile (1- ox) oy)))))
                                            (connect-jump graph x y ox oy (vec (* (vx vel) (- dir)) (vy vel)))
                                            #++(return-from create-jump-connections))
                                           ((< 0 (aref solids (* 2 (+ px (* w py)))))
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
           (connect-nodes graph 'walk (1- x) y x y w h))
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
           (connect-nodes graph 'walk x y (1+ x) (1+ y) w h))
          ((_ _ _
            / o _
            _ s _)
           (connect-nodes graph 'walk x y (1- x) (1+ y) w h))
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
   (path :initform NIL :accessor path)
   (node-time :initform 0f0 :accessor node-time)))

(defgeneric movement-speed (movable))
(defgeneric capable-p (movable edge))
(defgeneric move-to (target movable))
(defmethod capable-p ((movable movable) (edge walk-node)) T)
(defmethod capable-p ((movable movable) (edge fall-node)) T)
(defmethod capable-p ((movable movable) (edge jump-node)) NIL)
(defmethod capable-p ((movable movable) (edge crawl-node)) NIL)
(defmethod capable-p ((movable movable) (edge climb-node)) NIL)

(defun shortest-path-a* (grid start goal test cost-fun score-fun)
  (declare (optimize speed))
  (declare (type simple-vector grid))
  (declare (type (unsigned-byte 16) start goal))
  (declare (type function test cost-fun score-fun))
  (let ((open (list start))
        (source (make-hash-table :test 'eql))
        (scores (make-hash-table :test 'eql))
        (cost (make-hash-table :test 'eql)))
    (declare (type list open))
    (setf (gethash start scores) 0)
    (setf (gethash start cost) 1)
    (loop while open
          for min = NIL
          for min-cost = NIL
          do (dolist (current open min)
               (let ((cost (gethash current cost)))
                 (when (or (null min) (< cost min-cost))
                   (setf min current min-cost cost))))
             (when (eql min goal)
               (let ((path (list)))
                 (loop for (from . node) = (gethash min source)
                       while from
                       do (setf min from)
                          (push node path))
                 (return path)))
             (setf open (delete min open))
             (dolist (node (svref grid min))
               (when (funcall test node)
                 (let* ((target (move-node-to node))
                        (tentative-score (+ (gethash min scores) (funcall score-fun node)))
                        (score (gethash target scores)))
                   (when (or (null score) (< tentative-score score))
                     (setf (gethash target source) (cons min node))
                     (setf (gethash target scores) tentative-score)
                     (setf (gethash target cost) (+ tentative-score (funcall cost-fun target goal)))
                     (pushnew target open))))))))

(defun shortest-path (graph start goal offset test)
  (declare (optimize speed))
  (let ((w (node-graph-width graph))
        (grid (node-graph-grid graph)))
    (labels ((to-idx (vec)
               (+ (the (unsigned-byte 16) (floor (- (vx vec) (vx offset))  +tile-size+))
                  (* w (the (unsigned-byte 16) (floor (- (vy vec) (vy offset)) +tile-size+)))))
             (from-idx (idx)
               (vec (+ (vx offset) (* (+ (mod idx w) 0.5) +tile-size+))
                    (+ (vy offset) (* (+ (floor idx w) 0.5) +tile-size+))))
             (find-start (idx)
               (declare (type (signed-byte 16) idx))
               (loop (when (< idx 0) (return))
                     (when (svref grid idx) (return idx))
                     (decf idx w)))
             (cost (a b)
               (vsqrdist2 (from-idx a) (from-idx b)))
             (score (node)
               (etypecase node
                 (walk-node 1)
                 (fall-node 2)
                 (crawl-node 4)
                 (climb-node 6)
                 (jump-node 10))))
      (let ((start (find-start (to-idx start)))
            (goal (find-start (to-idx goal))))
        (when (and start goal)
          (values
           (mapl (lambda (node)
                   (setf (car node) (list (car node) (from-idx (move-node-to (car node))))))
                 (shortest-path-a* grid start goal test #'cost #'score))
           (from-idx start)))))))

(defmethod path-available-p ((target vec2) (movable movable))
  (ignore-errors (shortest-path (find-containing target (region +world+)) movable target)))

(defmethod path-available-p ((target located-entity) (movable movable))
  (path-available-p (location target) movable))

(defmethod move-to ((target vec2) (movable movable))
  (let ((b-chunk (find-containing target (region +world+)))
        (a-chunk (find-containing (location movable) (region +world+))))
    (unless (eql b-chunk a-chunk)
      (error "FIXME: Don't know how to cross chunks!"))
    (multiple-value-bind (path start) (shortest-path (node-graph a-chunk) (location movable)
                                                     target (v- (location a-chunk) (bsize a-chunk))
                                                     (lambda (node)
                                                       (capable-p movable node)))
      (when path
        (v:info :trial.move-to "Moving ~a along~{~%  ~a~}" movable path)
        (setf (current-node movable) start)
        (setf (path movable) path)))))

(defmethod move-to ((target located-entity) (movable movable))
  (move-to (location target) movable))

(defmethod move-to ((target symbol) (movable movable))
  (move-to (unit target +world+) movable))

(defun moved-beyond-target-p (loc source target)
  ;; FIXME: do this in 2D with ray projection
  (and
   (or (/= (signum (- (vx target) (vx source)))
           (signum (- (vx target) (vx loc))))
       (= (vx target) (vx loc)))
   (or (/= (signum (- (vy target) (vy source)))
           (signum (- (vy target) (vy loc))))
       (<= (abs (- (vy target) (vy loc))) 17))))

(defmethod (setf current-node) :after (node (movable movable))
  (setf (node-time movable) 0f0))

(defmethod handle :before ((ev tick) (movable movable))
  (when (path movable)
    (let* ((collisions (collisions movable))
           (dt (* 100 (dt ev)))
           (loc (vec (vx (location movable))
                     (+ (- (vy (location movable))
                           (vy (bsize movable)))
                        (/ +tile-size+ 2))))
           (vel (velocity movable))
           (source (current-node movable))
           (ground (svref collisions 2)))
      (flet ((move-towards (source target)
               (when (and (eql :crawling (state movable))
                          (null (svref collisions 0)))
                 (setf (state movable) :normal))
               (when (eql :climbing (state movable))
                 (setf (state movable) :normal))
               (let ((dir (float-sign (- (vx target) (vx source))))
                     (diff (abs (- (vx target) (vx loc)))))
                 (setf (vx vel) (* dir (max 0.5 (min diff (movement-speed movable))))))))
        ;; Handle current step
        (destructuring-bind (node target) (car (path movable))
          (etypecase node
            (walk-node
             (move-towards source target)
             (nv+ vel (v* (gravity (medium movable)) dt)))
            (fall-node
             (if ground
                 (move-towards source target)
                 (setf (vx vel) 0))
             (when (and (or (typep (svref collisions 1) 'ground)
                            (typep (svref collisions 3) 'ground))
                        (< (vy vel) (p! slide-limit)))
               (setf (vy vel) (p! slide-limit)))
             (nv+ vel (v* (gravity (medium movable)) dt)))
            (jump-node
             (if ground
                 (let ((node-dist (abs (- (vx loc) (vx source))))
                       (targ-dist (vsqrdist2 loc target)))
                   (cond ((<= node-dist 8)
                          (vsetf vel (vx (jump-node-strength node)) (vy (jump-node-strength node))))
                         ((< node-dist targ-dist)
                          (move-towards (location movable) source))
                         (T
                          (move-towards source target))))
                 (setf (vx vel) (vx (jump-node-strength node))))
             (nv+ vel (v* (gravity (medium movable)) dt)))
            (climb-node
             (cond ((or (svref collisions 1)
                        (svref collisions 3))
                    (setf (state movable) :climbing)
                    (let ((dir (signum (- (vy target) (vy source))))
                          (diff (abs (- (vy target) (vy loc)))))
                      (setf (vy vel) (* dir (max 0.5 (min diff (movement-speed movable)))))))
                   (T
                    (move-towards source target)
                    (nv+ vel (v* (gravity (medium movable)) dt)))))
            (crawl-node
             (setf (state movable) :crawling)
             (move-towards source target)))
          ;; Check whether to move on to the next step
          (when (moved-beyond-target-p loc source target)
            (pop (path movable))
            (setf (current-node movable) target))))
      (when (< 2.0 (incf (node-time movable) (dt ev)))
        (v:warn :kandria.move-to "Cancelling path, made no progress towards node in 2s.")
        (setf (state movable) :normal)
        (setf (path movable) NIL))
      (nvclamp (v- (p! velocity-limit)) vel (p! velocity-limit))
      (nv+ (frame-velocity movable) vel))))
