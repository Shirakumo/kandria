(in-package #:org.shirakumo.fraf.kandria)

(defun shortest-path-a* (grid start goal test cost-fun score-fun target-fun)
  (declare (optimize speed))
  (declare (type simple-vector grid))
  (declare (type (unsigned-byte 32) start goal))
  (declare (type function test cost-fun score-fun target-fun))
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
                 (return (values path T))))
             (setf open (delete min open))
             (dolist (node (svref grid min))
               (when (funcall test (cdr (gethash min source)) node)
                 (let* ((target (funcall target-fun node))
                        (tentative-score (+ (gethash min scores) (funcall score-fun node)))
                        (score (gethash target scores most-positive-single-float)))
                   (when (< tentative-score score)
                     (setf (gethash target source) (cons min node))
                     (setf (gethash target scores) tentative-score)
                     (setf (gethash target cost) (+ tentative-score (funcall cost-fun target goal)))
                     (pushnew target open))))))))

;;;; Graph within chunks
(defstruct (node-graph
            (:constructor %make-node-graph (width height &optional (grid (make-array (* width height) :initial-element NIL)))))
  (width 0 :type (unsigned-byte 32))
  (height 0 :type (unsigned-byte 32))
  (grid NIL :type simple-vector))

(macrolet ((defstruct* (name &body body)
             `(defstruct (,@name (:copier NIL) (:predicate NIL))
                ,@body)))
  (defstruct* (move-node (:constructor NIL))
      (to 0 :type (unsigned-byte 64)))
  (defstruct* (walk-node (:include move-node) (:constructor make-walk-node (to))))
  (defstruct* (crawl-node (:include move-node) (:constructor make-crawl-node (to))))
  (defstruct* (climb-node (:include move-node) (:constructor make-climb-node (to))))
  (defstruct* (fall-node (:include move-node) (:constructor make-fall-node (to))))
  (defstruct* (jump-node (:include move-node) (:constructor make-jump-node (to strength)))
      (strength NIL :type vec2))
  (defstruct* (rope-node (:include climb-node) (:constructor make-rope-node (to rope)))
      (rope NIL))
  (defstruct* (inter-door-node (:include move-node) (:constructor make-inter-door-node (to)))))

(declaim (inline node-idx))
(defun node-idx (graph x y)
  (+ x (* y (node-graph-width graph))))

(declaim (inline node))
(defun %node (graph x y)
  (the list (svref (node-graph-grid graph) (node-idx graph x y))))

(declaim (inline (setf node)))
(defun (setf %node) (value graph x y)
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
               (%node graph ax ay)))
        (T
         (push (funcall constructor (node-idx graph bx by))
               (%node graph ax ay))
         (push (funcall constructor (node-idx graph ax ay))
               (%node graph bx by)))))))

(defun connect-jump (graph ax ay bx by strength)
  (push (make-jump-node (node-idx graph bx by) strength)
        (%node graph ax ay)))

(defmacro do-nodes ((x y graph &optional (result NIL)) &body body)
  `(loop for ,y downfrom (1- (node-graph-height ,graph)) to 0
         do (loop for ,x from 0 below (node-graph-width ,graph)
                  do (progn ,@body))
         finally (return ,result)))

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
              nconc (loop for yfrac from 1 downto 0.5 by 0.1d0
                          collect (vec (* xfrac (vx vmax)) (* yfrac (vy vmax)))))
        (lambda (a b) (< (vlength a) (vlength b)))))

(defun create-jump-connections (solids graph ox oy dir)
  (declare (optimize speed))
  (declare (type (simple-array (unsigned-byte 8)) solids))
  (declare (type (unsigned-byte 32) ox oy))
  (declare (type (integer -1 +1) dir))
  (let* ((g (v/ (gravity (make-instance 'air)) 100 +tile-size+))
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
                                  for px = (the (signed-byte 32) (round (vx pos)))
                                  for py = (the (signed-byte 32) (floor (vy pos)))
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
                                            (connect-jump graph x y ox oy (vec (* (vx vel) (- dir))
                                                                               (+ (vy vel)
                                                                                  ;; Bias
                                                                                  (if (< 3 (tile x (1- y))) 1 0.5)
                                                                                  ;; If jump is short in X add extra strength
                                                                                  (if (<= (abs (- ox px)) 2) 0.5 0))))
                                            (return-from create-jump-connections))
                                           ((and (< 0 (vy vel))
                                                 (or (tile-type-p (tile px py) 'k)
                                                     (tile-type-p (tile px (+ 3 py)) 'k)))
                                            (loop-finish))
                                           ((and (< (vy vel) 0)
                                                 (tile-type-p (tile px py) 's))
                                            (loop-finish)))))))))))

(defun create-connections (solids graph)
  (declare (optimize speed))
  (let ((w (node-graph-width graph))
        (h (node-graph-height graph)))
    (declare (type (simple-array (unsigned-byte 8)) solids))
    (labels ((tile (x y)
               (if (and (<= 0 x (1- w)) (<= 0 y (1- h)))
                   (aref solids (* 2 (+ x (* w y))))
                   0))
             (fall (x y w h &optional (xoff 0) (yoff 0))
               (loop for yy downfrom (+ y yoff) to 0
                     do (when (or (= yy 0) (< 0 (tile (+ x xoff) (1- yy))))
                          (connect-nodes graph 'fall x y (+ x xoff) yy w h)
                          (loop-finish)))))
      (do-nodes (x y graph)
        (with-filters (solids w h x y)
          ((o o _
            o o _
            s s _)
           (connect-nodes graph 'walk (1- x) y x y w h))
          ((_ o _
            o o _
            o s _)
           (when (and (= 1 (tile x (1- y)))
                      (= 0 (tile (1- x) (- y 1))))
             (connect-nodes graph 'climb (1- x) (1- y) x y w h)
             (create-jump-connections solids graph x y -1)
             (fall x y w h -1)))
          ((_ o _
            _ o o
            _ s o)
           (when (and (= 1 (tile x (1- y)))
                      (= 0 (tile (1+ x) (- y 1))))
             (connect-nodes graph 'climb x y (1+ x) (1- y) w h)
             (create-jump-connections solids graph x y +1)
             (fall x y w h +1)))
          ((_ b _
            o o _
            _ b _)
           (connect-nodes graph 'crawl (1- x) y x y w h))
          ((_ b o
            _ o o
            _ b _)
           (connect-nodes graph 'crawl (1+ x) y x y w h))
          ((s o _
            c o _
            _ _ _)
           (connect-nodes graph 'climb x (1+ y) x y w h))
          ((_ o s
            _ o c
            _ _ _)
           (connect-nodes graph 'climb x (1+ y) x y w h))
          ((_ o _
            _ p c
            _ _ _)
           (connect-nodes graph 'climb x (1+ y) x y w h))
          ((_ o _
            c p _
            _ _ _)
           (connect-nodes graph 'climb x (1+ y) x y w h))
          ((_ p b
            _ o c
            _ _ _)
           (connect-nodes graph 'climb x (+ 2 y) x y w h))
          ((b p _
            c o _
            _ _ _)
           (connect-nodes graph 'climb x (+ 2 y) x y w h))
          ((s o _
            s o _
            o o _)
           (fall x y w h 0))
          ((_ o s
            _ o s
            _ o o)
           (fall x y w h 0))
          ((_ _ _
            _ _ _
            _ p _)
           (fall x y w h 0 -1))
          ((_ _ _
            _ o /
            _ _ _)
           (connect-nodes graph 'walk x y (1+ x) (1+ y) w h))
          ((_ _ _
            / o _
            _ _ _)
           (connect-nodes graph 'walk x y (1- x) (1+ y) w h))
          ((_ _ _
            o o b
            o o o)
           (create-jump-connections solids graph x y -1))
          ((_ _ _
            b o o
            o o o)
           (create-jump-connections solids graph x y +1)))))))

(defun create-entity-connections (chunk region graph)
  (let ((grid (node-graph-grid graph)))
    (do-fitting (entity (bvh region) chunk)
      (typecase entity
        (rope
         (let ((top (chunk-node-idx chunk (vec (+ (vx (location entity))
                                                  (* (direction entity) +tile-size+))
                                               (+ (vy (location entity))
                                                  (vy (bsize entity))))))
               (bot (chunk-node-idx chunk (vec (vx (location entity))
                                               (- (vy (location entity))
                                                  (vy (bsize entity)))))))
           ;; FIXME: Ropes across chunks
           (when (and (< 0 top (length grid))
                      (< 0 bot (length grid)))
             (push (make-rope-node top entity) (svref grid bot))
             (push (make-rope-node bot entity) (svref grid top)))))
        (door
         (flet ((closest-idx (entity)
                  (loop for x from (- (vx (location entity)) (vx (bsize entity)))
                        below (+ (vx (location entity)) (vx (bsize entity))) by +tile-size+
                        do (loop for y from (- (vy (location entity)) (vy (bsize entity)))
                                 below (+ (vy (location entity)) (vy (bsize entity))) by +tile-size+
                                 for vec = (vec x y)
                                 for idx = (chunk-node-idx chunk vec)
                                 do (when (and (< idx (length grid)) (svref grid idx))
                                      (return-from closest-idx idx))))))
           (when (and (primary entity) (eq chunk (find-chunk (location (target entity)) region)))
             (let ((a (closest-idx entity))
                   (b (closest-idx (target entity))))
               (when (and a b)
                 (push (make-inter-door-node b) (svref grid a))
                 (push (make-inter-door-node a) (svref grid b)))))))))))

(defun make-node-graph (chunk &optional (region (region +world+)))
  (trial::with-timing-report (:info :kandria.move-to "Computed node graph for ~a in ~fs run time, ~fs clock time." chunk)
    (let ((graph (%make-node-graph (floor (vx (size chunk))) (floor (vy (size chunk))))))
      (create-connections (pixel-data chunk) graph)
      (create-entity-connections chunk region graph)
      graph)))

(defun shortest-chunk-path (graph start goal offset test)
  (declare (optimize speed))
  (let ((w (node-graph-width graph))
        (h (node-graph-height graph))
        (grid (node-graph-grid graph)))
    (labels ((to-idx (vec)
               (etypecase vec
                 (integer vec)
                 (vec2
                  (the (unsigned-byte 32)
                       (+ (clamp 0 (the (unsigned-byte 32) (floor (- (vx vec) (vx offset)) +tile-size+)) (1- w))
                          (* w (clamp 0 (the (unsigned-byte 32) (floor (- (vy vec) (vy offset)) +tile-size+)) (1- h))))))))
             (from-idx (idx)
               (vec (+ (vx offset) (* (+ (mod idx w) 0.5) +tile-size+))
                    (+ (vy offset) (* (+ (floor idx w) 0.5) +tile-size+))))
             (find-start (idx)
               (declare (type (signed-byte 32) idx))
               (loop (when (< idx 0) (return))
                     (when (svref grid idx) (return idx))
                     (when (tile-type-p idx 's) (return))
                     (decf idx w)))
             (cost (a b)
               (vsqrdistance (from-idx a) (from-idx b)))
             (score (node)
               (+ (vsqrdistance (from-idx (move-node-to node)) (from-idx (to-idx goal)))
                  (etypecase node
                    (walk-node  0)
                    (inter-door-node 0)
                    (fall-node  100000)
                    (crawl-node 100000000)
                    (climb-node 1000000000)
                    (jump-node  10000000))))
             (test (prev next)
               (funcall test prev next (from-idx (move-node-to next)))))
      (let ((start (find-start (to-idx start)))
            (goal (find-start (to-idx goal))))
        (when (and start goal)
          (multiple-value-bind (path found) (shortest-path-a* grid start goal #'test #'cost #'score #'move-node-to)
            (when found
              (values
               (mapl (lambda (node)
                       (setf (car node) (list (car node) (from-idx (move-node-to (car node))))))
                     path)
               (from-idx start)))))))))

;;;; Graph across chunks
(defun chunk-node-idx (chunk loc)
  (let ((x (floor (- (vx loc) (- (vx (location chunk)) (vx (bsize chunk)))) +tile-size+))
        (y (floor (- (vy loc) (- (vy (location chunk)) (vy (bsize chunk)))) +tile-size+)))
    (+ x (* y (truncate (vx (size chunk)))))))

(defun chunk-node-vec (chunk idx)
  (multiple-value-bind (y x) (floor idx (vx (size chunk)))
    (vec (+ (- (vx (location chunk)) (vx (bsize chunk))) (+ (* x +tile-size+) (/ +tile-size+ 2)))
         (+ (- (vy (location chunk)) (vy (bsize chunk))) (+ (* y +tile-size+) (/ +tile-size+ 2))))))

(defstruct (chunk-node (:constructor %make-chunk-node (from from-node to to-node)))
  (from NIL :type T)
  (to NIL :type T)
  (from-node 0 :type (unsigned-byte 64))
  (to-node 0 :type (unsigned-byte 64)))

(defstruct (door-node (:include chunk-node) (:constructor %make-door-node (from from-node to to-node))))
(defstruct (teleport-node (:include chunk-node) (:constructor %make-teleport-node (from from-node to to-node))))

(defun make-chunk-node (nodes from-chunk from-loc to-chunk to-loc &optional (constructor '%make-chunk-node))
  (when (and (<= 0 (chunk-node-idx to-chunk to-loc) (length (node-graph-grid (node-graph to-chunk))))
             (svref (node-graph-grid (node-graph to-chunk)) (chunk-node-idx to-chunk to-loc)))
    (push (funcall constructor
                   from-chunk (chunk-node-idx from-chunk from-loc)
                   to-chunk (chunk-node-idx to-chunk to-loc))
          (svref nodes (chunk-graph-id from-chunk)))))

(defun connect-chunks (nodes from to)
  (let ((xcross (vec (max (- (vx (location to)) (vx (bsize to)))
                          (- (vx (location from)) (vx (bsize from))))
                     (min (+ (vx (location to)) (vx (bsize to)))
                          (+ (vx (location from)) (vx (bsize from))))))
        (ycross (vec (max (- (vy (location to)) (vy (bsize to)))
                          (- (vy (location from)) (vy (bsize from))))
                     (min (+ (vy (location to)) (vy (bsize to)))
                          (+ (vy (location from)) (vy (bsize from))))))
        (grid (node-graph-grid (node-graph from)))
        (bgrid (node-graph-grid (node-graph to)))
        (w (floor (vx (size from)))))
    (macrolet ((iterate (span loc to)
                 `(loop for s from (vx ,span) to (vy ,span) by +tile-size+
                        for loc = ,loc
                        for idx = (chunk-node-idx from loc)
                        while (< idx (length grid))
                        do (when (and (svref grid idx)
                                      (contained-p (v+ loc ,to) to))
                             (make-chunk-node nodes from loc to (v+ loc ,to))))))
      (cond ((< (vx xcross) (vy xcross))
             (cond ((= (- (vy (location from)) (vy (bsize from)))
                       (+ (vy (location to)) (vy (bsize to)))) ; B
                    (iterate xcross
                             (vec s (- (vy (location from)) (vy (bsize from)) (/ +tile-size+ -2)))
                             (vec 0 (* +tile-size+ -1)))
                    ;; Additional: fall nodes that exit to bottom
                    (dotimes (i (length grid))
                      (dolist (node (svref grid i))
                        (when (and (typep node 'fall-node) (< -1 (move-node-to node) w))
                          (let ((loc (chunk-node-vec from (move-node-to node))))
                            (loop for i = (chunk-node-idx to loc)
                                  while (< 0 i)
                                  do (decf (vy loc) +tile-size+)
                                     (when (and (< i (length bgrid))
                                                (svref bgrid i))
                                       (push (%make-chunk-node from (move-node-to node) to i)
                                             (svref nodes (chunk-graph-id from)))
                                       (return))))))))
                   ((= (+ (vy (location from)) (vy (bsize from)))
                       (- (vy (location to)) (vy (bsize to)))) ; U
                    (iterate xcross
                             (vec s (+ (vy (location from)) (vy (bsize from)) (* +tile-size+ -1.5)))
                             (vec 0 (* +tile-size+ 1.5))))))
            ((< (vx ycross) (vy ycross))
             (cond ((= (- (vx (location from)) (vx (bsize from)))
                       (+ (vx (location to)) (vx (bsize to)))) ; L
                    (iterate ycross
                             (vec (- (vx (location from)) (vx (bsize from)) (/ +tile-size+ -2)) s)
                             (vec (- +tile-size+) 0)))
                   ((= (+ (vx (location from)) (vx (bsize from)))
                       (- (vx (location to)) (vx (bsize to)))) ; R
                    (iterate ycross
                             (vec (+ (vx (location from)) (vx (bsize from)) (/ +tile-size+ -2)) s)
                             (vec (+ +tile-size+) 0)))))))))

(defun make-chunk-graph (region)
  (trial::with-timing-report (:info :kandria.move-to "Computed chunk graph for ~a in ~fs run time, ~fs clock time." region)
    (let ((chunks ()) (i 0))
      (labels ((locs-with-connections (chunk entity)
                 (let ((containing ()))
                   (loop with nodes = (node-graph-grid (node-graph chunk))
                         for x from (- (vx (location entity)) (vx (bsize entity)))
                         below (+ (vx (location entity)) (vx (bsize entity))) by +tile-size+
                         do (loop for y from (- (vy (location entity)) (vy (bsize entity)))
                                  below (+ (vy (location entity)) (vy (bsize entity))) by +tile-size+
                                  for vec = (vec x y)
                                  for idx = (chunk-node-idx chunk vec)
                                  do (when (and (< idx (length nodes))
                                                (svref nodes idx))
                                       (pushnew vec containing :test #'v=))))
                   containing))
               (connect-entities (nodes from to constructor)
                 (let* ((from-chunk (find-chunk (location from) region))
                        (to-chunk (find-chunk (location to) region))
                        (to-loc (first (sort (locs-with-connections to-chunk to) #'<
                                             :key (lambda (a) (vsqrdistance a (location to)))))))
                   (dolist (from-loc (locs-with-connections from-chunk from))
                     (unless (eq from-chunk to-chunk)
                       (make-chunk-node nodes
                                        from-chunk from-loc
                                        to-chunk to-loc
                                        constructor))))))
        ;; Compute chunk list and assign IDs
        (for:for ((entity over region))
          (when (typep entity 'chunk)
            (push entity chunks)
            (setf (chunk-graph-id entity) i)
            (incf i)))
        ;; Compute internal connections
        (let ((nodes (make-array (length chunks) :initial-element NIL)))
          (dolist (chunk chunks nodes)
            (dolist (other chunks)
              (unless (eql chunk other)
                (connect-chunks nodes chunk other)))
            (do-fitting (entity (bvh region) chunk)
              (typecase entity
                (door
                 (connect-entities nodes entity (target entity) #'%make-door-node))
                (teleport-trigger
                 (when (primary entity)
                   (connect-entities nodes entity (target entity) #'%make-teleport-node)))))))))))

(defun shortest-path (start goal test &optional (region (region +world+)))
  (let* ((graph (chunk-graph region))
         (start-chunk (find-chunk start region))
         (goal-chunk (find-chunk goal region)))
    (when (and start-chunk goal-chunk)
      (labels ((cost (a b)
                 (vsqrdistance (location (chunk-node-from (first (svref graph a))))
                            (location (chunk-node-from (first (svref graph b))))))
               (target (a)
                 (chunk-graph-id (chunk-node-to a)))
               (chunk-path (node goal)
                 (let ((chunk (chunk-node-to node)))
                   (shortest-chunk-path (node-graph chunk) (chunk-node-to-node node)
                                        goal (v- (location chunk) (bsize chunk))
                                        test)))
               ;; FIXME: we compute the full path here and then throw it away. This is very wasteful!
               ;;        should cache it instead and then reconstruct from chosen parts instead.
               ;;        or we could cache ahead of time which nodes inside a chunk are connectable.
               (test (prev node)
                 (if prev
                     (not (null (chunk-path prev (chunk-node-from-node node))))
                     (let ((chunk (chunk-node-from node)))
                       (nth-value 1 (shortest-chunk-path (node-graph chunk) start
                                                         (chunk-node-from-node node) (v- (location chunk) (bsize chunk))
                                                         test)))))
               (make-transition-node (node)
                 (list
                  (cond ((typep node '(or door-node teleport-node))
                         node)
                        ((< (vy (location (chunk-node-from node))) (vy (location (chunk-node-to node))))
                         (load-time-value (make-climb-node 0)))
                        ((> (vy (location (chunk-node-from node))) (vy (location (chunk-node-to node))))
                         (load-time-value (make-fall-node 0)))
                        (T
                         (load-time-value (make-walk-node 0))))
                  (if (typep node '(or door-node teleport-node))
                      (chunk-node-vec (chunk-node-from node) (chunk-node-from-node node))
                      (chunk-node-vec (chunk-node-to node) (chunk-node-to-node node))))))
        (if (eq start-chunk goal-chunk)
            (shortest-chunk-path (node-graph start-chunk) start goal (v- (location start-chunk) (bsize start-chunk)) test)
            (let ((chunk-path (shortest-path-a* graph (chunk-graph-id start-chunk) (chunk-graph-id goal-chunk)
                                                #'test #'cost (constantly 1) #'target)))
              (when chunk-path
                (multiple-value-bind (path start) (shortest-chunk-path (node-graph start-chunk) start (chunk-node-from-node (first chunk-path))
                                                                       (v- (location start-chunk) (bsize start-chunk)) test)
                  (values (append path
                                  (loop for (from to) on chunk-path
                                        for path = (if to
                                                       (chunk-path from (chunk-node-from-node to))
                                                       (chunk-path from goal))
                                        nconc (list* (make-transition-node from) path)
                                        do (unless path (return-from shortest-path (values NIL NIL)))))
                          start)))))))))

;;;; Path execution
(defclass movable (moving)
  ((current-node :initform NIL :accessor current-node)
   (path :initform NIL :accessor path)
   (pending-action :initform NIL :accessor pending-action)
   (node-time :initform 0f0 :accessor node-time)))

(defmethod (setf pending-direction) (value (movable movable))
  (setf (pending-action movable) (lambda (movable) (setf (direction movable) value))))

(defclass immovable (movable) ())

(defmethod capable-p ((immovable immovable) (edge move-node)) NIL)

(defgeneric movement-speed (movable))
(defgeneric capable-p (movable edge))
(defgeneric move-to (target movable))
(defmethod capable-p ((movable movable) (edge walk-node)) T)
(defmethod capable-p ((movable movable) (edge door-node)) T)
(defmethod capable-p ((movable movable) (edge inter-door-node)) T)
(defmethod capable-p ((movable movable) (edge fall-node)) T)
(defmethod capable-p ((movable movable) (edge jump-node)) NIL)
(defmethod capable-p ((movable movable) (edge crawl-node)) NIL)
(defmethod capable-p ((movable movable) (edge climb-node)) NIL)
(defmethod capable-p :around ((movable movable) (edge rope-node))
  (let ((rope (rope-node-rope edge)))
    (when (typep rope 'symbol)
      (setf rope (unit rope T)))
    (when (extended rope)
      (call-next-method))))

(defmethod path-available-p ((target vec2) (movable movable))
  (ignore-errors (shortest-path (find-chunk target) movable target)))

(defmethod path-available-p ((target located-entity) (movable movable))
  (path-available-p (location target) movable))

(defmethod move-to ((target vec2) (movable movable))
  (flet ((test (_prev node pos)
           (declare (ignore _prev pos))
           (and
            (capable-p movable node)
            ;; TODO: Re-activate and fix this once it's not prohibitively expensive.
            #++
            (not
             (for:for ((entity over (region +world+)))
               (when (and (typep entity 'solid)
                          (not (typep entity 'chunk))
                          (not (eq entity movable))
                          (contained-p pos entity))
                 (return entity)))))))
    (multiple-value-bind (path start) (shortest-path (location movable) target #'test)
      (setf (state movable) :normal)
      (when path
        (v:info :kandria.move-to "Moving ~s to ~s" movable target)
        (setf (current-node movable) start)
        (setf (path movable) path)))))

(defmethod move-to ((target located-entity) (movable movable))
  (move-to (location target) movable))

(define-unit-resolver-methods move-to (unit unit))

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

(defun execute-path (movable tick)
  (let* ((collisions (collisions movable))
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
             (cond ((< 0 (vx vel))
                    (setf (direction movable) +1))
                   ((< (vx vel) 0)
                    (setf (direction movable) -1)))
             (let ((dir (float-sign (- (vx target) (vx source))))
                   (diff (abs (- (vx target) (vx loc)))))
               (setf (vx vel) (* dir (movement-speed movable)))))
           (trigger-door (location)
             (do-fitting (entity (bvh (region +world+)) location)
               (when (typep entity 'door)
                 (setf (animation entity) 'open)))))
      ;; Handle current step
      (destructuring-bind (node target) (car (path movable))
        (etypecase node
          (symbol
           (setf (state movable) :normal)
           (setf (node-time movable) 0.0)
           (ecase node
             (null
              (setf (vx vel) 0.0))
             (walk
              (setf (vx vel) (* (ecase target
                                  ((NIL) (direction movable))
                                  (:left -1)
                                  (:right +1))
                                (movement-speed movable))))
             (jump
              (when ground
                (v<- vel (or target (vec (* (direction movable) 2.0) 3.4)))))
             (drop
              (typecase ground
                (null (setf (vx vel) 0))
                (platform (decf (vy (location movable)) 2))))))
          (walk-node
           ;; KLUDGE: When we detect a collision on the side, just try to jump
           ;;         and hope you get over it.
           (when (and ground (or (typep (svref collisions 1) 'ground)
                                 (typep (svref collisions 3) 'ground)))
             (incf (vy vel) 0.8))
           (unless (and (or (svref collisions 1)
                            (svref collisions 3))
                        (<= (vy vel) 0.0))
             (move-towards source target)))
          (fall-node
           (typecase ground
             (null (setf (vx vel) 0)
              (node-time movable))
             (platform (decf (vy (location movable)) 2))
             (T (move-towards source target)))
           (when (and (or (typep (svref collisions 1) 'ground)
                          (typep (svref collisions 3) 'ground))
                      (< (vy vel) (p! slide-limit)))
             (setf (vy vel) (p! slide-limit))))
          (jump-node
           (if ground
               (let ((node-dist (abs (- (vx loc) (vx source))))
                     (targ-dist (vsqrdistance loc target)))
                 (cond ((<= node-dist 8)
                        (vsetf vel (vx (jump-node-strength node)) (vy (jump-node-strength node))))
                       ((< node-dist targ-dist)
                        (move-towards (location movable) source))
                       (T
                        (move-towards source target))))
               (setf (vx vel) (vx (jump-node-strength node)))))
          (rope-node
           (let ((off (- (- (vx source) (* (direction (rope-node-rope node)) 8)) (vx loc))))
             (cond ((<= (abs (- (vy loc) (vy target))) 1)
                    (move-towards source target))
                   ((<= (abs off) 1)
                    (setf (state movable) :climbing)
                    (setf (node-time movable) 0.0)
                    (nudge (rope-node-rope node) loc (* (direction movable) -8))
                    (let ((dir (signum (- (vy target) (vy source))))
                          (diff (abs (- (vy target) (vy loc)))))
                      (setf (direction movable) (direction (rope-node-rope node)))
                      (setf (vx vel) 0.0)
                      (setf (vy vel) (* dir (max 0.5 (min diff (movement-speed movable)))))))
                   (T
                    (setf (vx vel) (float-sign off))))))
          (climb-node
           (cond ((or (svref collisions 1)
                      (svref collisions 3))
                  (setf (state movable) :climbing)
                  (if (svref collisions 1)
                      (setf (direction movable) +1)
                      (setf (direction movable) -1))
                  (let ((dir (signum (- (vy target) (vy source))))
                        (diff (abs (- (vy target) (vy loc)))))
                    (setf (vy vel) (* dir (max 0.5 (min diff (movement-speed movable)))))))
                 (T
                  (move-towards source target))))
          (crawl-node
           (move-towards source target)
           (setf (state movable) :crawling))
          (inter-door-node
           (flet ((teleport ()
                    (pop (path movable))
                    ;; FIXME: add a timer to let the animation complete
                    (trigger-door (location movable))
                    (vsetf (location movable) (vx target) (+ (- (vy target) (/ +tile-size+ 2)) (vy (bsize movable))))
                    (setf (current-node movable) target)))
             (vsetf vel 0 0)
             ;; FIXME: Need to properly distinguish whether we need to enter forward or backward
             (typecase movable
               (player
                (start-animation 'enter movable)
                (transition (teleport)))
               (T
                (start-animation 'enter movable)
                (when (= (frame-idx movable) (1- (end (animation movable))))
                  (setf (state movable) :normal)
                  (teleport))))))
          (teleport-node
           (do-fitting (entity (bvh (region +world+)) movable)
             (typecase entity
               (teleport-trigger
                ;; KLUDGE: This is potentially very bad. We skip a full node.
                (setf (current-node movable) (second (pop (path movable))))
                (pop (path movable))
                (interact entity movable))))
           (move-towards source target))
          (door-node
           (if (moved-beyond-target-p loc source target)
               (flet ((teleport ()
                        (let ((node-vec (chunk-node-vec (chunk-node-to node) (chunk-node-to-node node))))
                          (pop (path movable))
                          ;; FIXME: add a timer to let the animation complete
                          (trigger-door (location movable))
                          (vsetf (location movable) (vx node-vec) (+ (- (vy node-vec) (/ +tile-size+ 2)) (vy (bsize movable))))
                          (setf (current-node movable) node-vec))))
                 (vsetf vel 0 0)
                 ;; FIXME: Need to properly distinguish whether we need to enter forward or backward
                 (typecase movable
                   (player
                    (start-animation 'enter movable)
                    (transition (teleport)))
                   (T
                    (start-animation 'enter movable)
                    (when (and (= (frame-idx movable) (1- (end (animation movable))))
                               (<= (duration (aref (frames movable) (frame-idx movable)))
                                   (+ (dt tick) (clock movable))))
                      (setf (state movable) :normal)
                      (teleport)))))
               (move-towards source target))))
        ;; Check whether to move on to the next step
        (typecase node
          ((or door-node inter-door-node teleport-node symbol))
          (climb-node
           (when (<= (vy target) (vy loc))
             (pop (path movable))
             (setf (current-node movable) target)))
          (T
           (when (or (moved-beyond-target-p loc source target)
                     (and (typep (car (second (path movable))) 'climb-node)
                          (or (svref collisions 1) (svref collisions 3))))
             (pop (path movable))
             (setf (current-node movable) target))))))
    (when ground
      (incf (vy vel) (min 0 (vy (velocity ground)))))
    (nv+ vel (v* (gravity (medium movable)) (dt tick)))
    (when (< 2.0 (incf (node-time movable) (dt tick)))
      (v:warn :kandria.move-to "Cancelling path, made no progress executing ~a towards ~a in 2s"
              (caar (path movable)) (current-node movable))
      (setf (state movable) :normal)
      (setf (path movable) NIL)))
  (unless (path movable)
    (let ((action (shiftf (pending-action movable) NIL)))
      (when action
        (funcall action movable)))))

(defun close-to-path-p (loc path threshold)
  (let ((threshold (expt threshold 2)))
    (loop for (_ target) in path
          thereis (< (vsqrdistance loc target) threshold))))

(defmethod move (kind (movable movable) &key strength)
  (setf (path movable)
        (ecase kind
          ((NIL) ())
          (:freeze `((null NIL)))
          (:left `((walk :left)))
          (:right `((walk :right)))
          (:jump `((jump ,strength)))
          (:drop `((drop NIL))))))

(defmethod move (kind (name symbol) &rest args)
  (apply #'move kind (unit name +world+) args))

(defmethod stop ((movable movable))
  (setf (path movable) ()))

(define-unit-resolver-methods stop (unit))

(defun closest-visible-target (target)
  (let* ((tloc (ensure-location target))
         (region (region +world+))
         (chunk (find-chunk tloc region)))
    (when (and chunk (not (visible-on-map-p chunk)))
      (do-fitting (entity (bvh region) chunk)
        (when (typep entity 'door)
          (let ((other (find-chunk (target entity) region)))
            (when (and other (visible-on-map-p other))
              (setf target (target entity))
              (return)))))
      ;;;; The following is better but way too expensive if the player is far
      ;; (let* ((path (shortest-path (location (unit 'player +world+)) tloc (constantly T)))
      ;;        (door (loop for (node target) in path
      ;;                    when (typep node 'door-node)
      ;;                    do (return target))))
      ;;   (when door (setf target door)))
      )
    target))
