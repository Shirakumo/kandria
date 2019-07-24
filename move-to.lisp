(in-package #:org.shirakumo.fraf.leaf)

(defclass walk-edge (flow:connection) ())
(defclass crawl-edge (flow:connection) ())
(defclass fall-edge (flow:directed-connection) ())
(defclass jump-edge (flow:directed-connection)
  ((strength :initarg :strength :accessor strength)))

(defmethod flow:connection= ((a jump-edge) (b jump-edge))
  (and (call-next-method)
       (v= (strength a) (strength b))))

(flow:define-node platform-node ()
  ((options :port-type flow:n-port)
   (location :initarg :location :accessor location)))

(defmethod print-object ((node platform-node) stream)
  (print-unreadable-object (node stream :type T)
    (format stream "~a" (location node))))

(flow:define-node right-edge-node (platform-node) ())
(flow:define-node left-edge-node (platform-node) ())
(flow:define-node both-edge-node (right-edge-node left-edge-node) ())

(defun connect-platforms (a b type &rest initargs)
  (apply #'flow:connect
         (flow:port a 'options)
         (flow:port b 'options)
         type initargs))

(defun create-platform-nodes (solids node-grid width height)
  (labels ((tile (x y)
             (aref solids (* (+ x (* y width)) 2)))
           ((setf node) (node x y)
             (setf (aref node-grid (+ x (* y width))) node)))
    (let ((prev-node NIL))
      (loop for y downfrom (1- height) above 0
            do (loop for x from 0 below width
                     do (cond ((and (< 0 (tile x (1- y)))
                                    (not (< 0 (tile x y))))
                               (let ((new (if (or prev-node (= 0 x) (< 1 (tile (1- x) y)))
                                              (make-instance 'platform-node :location (vec2 x y))
                                              (make-instance 'left-edge-node :location (vec2 x y)))))
                                 (when prev-node
                                   (connect-platforms prev-node new
                                                      (if (or (< 0 (tile x (1+ y)))
                                                              (< 0 (tile (1- x) (1+ y))))
                                                          'crawl-edge
                                                          'walk-edge)))
                                 (setf (node x y) new)
                                 (setf prev-node new)))
                              ((< 0 (tile x y))
                               (setf prev-node NIL))
                              ((typep prev-node 'left-edge-node)
                               (change-class prev-node 'both-edge-node)
                               (setf prev-node NIL))
                              ((typep prev-node 'platform-node)
                               (change-class prev-node 'right-edge-node)
                               (setf prev-node NIL))))
               (setf prev-node NIL)))))

(defun create-fall-connections (solids node-grid width height)
  (flet ((node (x y)
           (aref node-grid (+ x (* y width))))
         (tile (x y)
           (aref solids (* (+ x (* y width)) 2))))
    (loop for y downfrom (1- height) to 0
          do (loop for x from 0 below width
                   for node = (node x y)
                   do (when (and (typep node 'left-edge-node)
                                 (= 0 (tile (1- x) y)))
                        (loop for yy downfrom y to 0
                              for nnode = (node (1- x) yy)
                              do (when nnode
                                   (connect-platforms node nnode 'fall-edge)
                                   (return))))
                      (when (and (typep node 'right-edge-node)
                                 (= 0 (tile (1+ x) y)))
                        (loop for yy downfrom y to 0
                              for nnode = (node (1+ x) yy)
                              do (when nnode
                                   (connect-platforms node nnode 'fall-edge)
                                   (return))))))))

(defun reachable-p (nnode node)
  (let ((hash (make-hash-table :test 'eq)))
    (labels ((traverse (node)
               (when (eq node nnode)
                 (return-from reachable-p T))
               (unless (gethash node hash)
                 (setf (gethash node hash) T)
                 (loop for out in (slot-value node 'options)
                       for other = (flow:target-node node out)
                       do (when (and other (not (typep out 'jump-edge)))
                            (traverse other))))))
      (traverse node))))

(defun create-jump-connections-at (node ox oy solids node-grid width height)
  (let ((g (- +vgrav+))
        (j 5.0)
        (v 1.75))
    (loop for jf from 1 to 3
          for jv = (* j (/ jf 3))
          do (loop for vf from -3 to 3
                   for vv = (* v (/ vf 3))
                   do (let ((px 0) (py 0))
                        (loop for tt from 0 below 30
                              for x = (+ ox (round (* tt vv) +tile-size+))
                              for y = (+ oy (round (* tt (+ jv (* g tt))) +tile-size+))
                              for i = (+ x (* y width))
                              while (and (<= 0 x (1- width))
                                         (<= 0 y (1- height)))
                              do (when (or (/= px x) (/= py y))
                                   (setf px x py y)
                                   ;; FIXME: Not great.
                                   (when (or (= 1 (aref solids (* 2 i)))
                                             (< 2 (aref solids (* 2 i))))
                                     (return))
                                   (let ((nnode (aref node-grid i)))
                                     (when (and nnode (not (eq node nnode)) (not (reachable-p nnode node)))
                                       (connect-platforms node nnode 'jump-edge :strength (vec vv jv)))))))))))

(defun create-jump-connections (solids node-grid width height)
  (loop for y downfrom (1- height) to 0
        do (loop for x from 0 below width
                 for node = (aref node-grid (+ x (* y width)))
                 do (when (typep node 'platform-node)
                      (create-jump-connections-at node x y solids node-grid width height)))))

(defun compute-node-grid (solids width height)
  (let ((node-grid (make-array (/ (length solids) 2) :initial-element NIL)))
    (create-platform-nodes solids node-grid width height)
    (create-fall-connections solids node-grid width height)
    (create-jump-connections solids node-grid width height)
    node-grid))

(defun node-graph-mesh (node-grid width height &optional (scale +tile-size+))
  (with-vertex-filling ((make-instance 'vertex-mesh :vertex-type 'colored-vertex))
    (loop for y downfrom (1- height) to 0
          do (loop for x from 0 below width
                   for node = (aref node-grid (+ x (* y width)))
                   do (when node
                        (loop for out in (slot-value node 'options)
                              for target = (flow:target-node node out)
                              for color = (etypecase out
                                            (walk-edge (vec 0 1 0 1))
                                            (crawl-edge (vec 0.6 0.3 0 1))
                                            (jump-edge (vec 1 0 0 1))
                                            (fall-edge (vec 0 0 1 1)))
                              when target
                              do (vertex :position (nv* (vec x y 0) scale) :color color)
                                 (vertex :position (nv* (vxy_ (location target)) scale) :color (v* color 0.1))))))))

(defun format-node-graph (node-grid width height)
  (let ((*print-right-margin* most-positive-fixnum))
    (flet ((node (x y)
             (aref node-grid (+ x (* y width)))))
      (loop for y downfrom (1- height) to 0
            do (loop for x from 0 below width
                     do (format T (etypecase (node x y)
                                    (null " ")
                                    (both-edge-node "^")
                                    (left-edge-node "<")
                                    (right-edge-node ">")
                                    (platform-node "-"))))
               (format T "~&"))
      (format T "~% ===== ~%")
      (loop for y downfrom (1- height) to 0
            do (loop for x from 0 below width
                     for node = (node x y)
                     do (when node
                          (loop for con in (slot-value node 'options)
                                do (format T "~a~%" con))))
               (format T "~&")))))

(define-shader-entity node-graph (vertex-entity)
  ((node-grid :initarg :node-grid :accessor node-grid)
   (size :initarg :size :accessor size))
  (:default-initargs :vertex-form :lines))

(defmethod shared-initialize :after ((graph node-graph) slots &key solids)
  (declare (ignore slots))
  (let ((w (truncate (vx (size graph))))
        (h (truncate (vy (size graph)))))
    (when solids
      (setf (node-grid graph) (compute-node-grid solids w h))
      (setf (vertex-array graph)
            (change-class (node-graph-mesh (node-grid graph) w h) 'vertex-array)))))

(defmethod (setf node-grid) :after (node-grid (graph node-graph))
  (let ((w (truncate (vx (size graph))))
        (h (truncate (vy (size graph)))))
    (setf (vertex-array graph)
          (change-class (node-graph-mesh node-grid w h) 'vertex-array))))

(defmethod shortest-path ((graph node-graph) start goal)
  (let ((node-grid (node-grid graph))
        (width (floor (vx (size graph)))))
    (flet ((node (pos)
             (aref node-grid (+ (round (vx pos))
                                (* (round (vy pos)) width))))
           (cost (a b)
             (vsqrdist2 (location a) (location b))))
      (values (flow:a* (node start) (node goal) #'cost)
              (node start)))))

(define-class-shader (node-graph :vertex-shader)
  "layout (location = 1) in vec4 in_vertexcolor;
out vec4 vertexcolor;

void main(){
  vertexcolor = in_vertexcolor;
}")

(define-class-shader (node-graph :fragment-shader)
  "in vec4 vertexcolor;
out vec4 color;

void main(){
  color = vertexcolor;
}")

(define-subject movable (moving)
  ((current-node :initform NIL :accessor current-node)
   (path :initform NIL :accessor path)))

(defmethod move-to ((target vec2) (movable movable))
  (multiple-value-bind (path start) (shortest-path (surface movable)
                                                   (nv+ (v- (location movable)
                                                            (bsize movable))
                                                        (/ +tile-size+ 2))
                                                   target)
    (v:info :leaf.moving "Moving along~{~%  ~a~}" path)
    (setf (current-node movable) start)
    (setf (path movable) path)))

(defmethod tick :before ((movable movable) ev)
  (when (path movable)
    (let* ((surface (surface movable))
           (loc (location movable))
           (acc (acceleration movable))
           (con (car (path movable)))
           (node (current-node movable))
           (target (flow:target-node node con)))
      (cond ((< (vsqrdist2 
                 (v/ (nv+ (v- loc (location surface)) (bsize surface)) +tile-size+)
                 (location target))
                1.1)
             (pop (path movable))
             (setf (current-node movable) target)
             ;; Handle initial jump
             (let ((next (car (path movable))))
               (typecase next
                 (jump-edge
                  (vsetf acc
                         (vx (strength next))
                         (vy (strength next))))
                 (null
                  (vsetf acc 0 0)))))
            ((typep con 'walk-edge)
             (setf (vx acc) (if (< (vx (location target))
                                   (vx (location node)))
                                -1.75
                                +1.75)))
            ((typep con 'fall-edge)
             )
            ((typep con 'jump-edge)
             ))
      (decf (vy acc) +vgrav+)
      (nv+ (velocity movable) acc))))
