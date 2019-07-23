(in-package #:org.shirakumo.fraf.leaf)

(defclass walk-edge (flow:connection) ())
(defclass fall-edge (flow:directed-connection) ())
(defclass jump-edge (flow:directed-connection)
  ((strength :initarg :strength :accessor strength)))

(defclass in-port (flow:n-port flow:in-port) ())
(defclass out-port (flow:n-port flow:out-port) ())

(flow:define-node platform-node ()
  ((in :port-type in-port)
   (out :port-type out-port)
   (location :initarg :location :accessor location)))

(flow:define-node right-edge-node (platform-node) ())
(flow:define-node left-edge-node (platform-node) ())
(flow:define-node both-edge-node (right-edge-node left-edge-node) ())

(defun connect-platforms (a b type &rest initargs)
  (apply #'flow:connect
         (flow:port a 'out)
         (flow:port b 'in)
         type initargs))

(defun create-platform-nodes (solids node-grid width height)
  (labels ((pos (x y)
             (* (+ x (* y width)) 2))
           (tile (x y)
             (aref solids (pos x y)))
           ((setf node) (node x y)
             (setf (aref node-grid (pos x y)) node)))
    (let ((prev-node NIL))
      (loop for y downfrom (1- height) above 0
            do (loop for x from 0 below width
                     do (cond ((and (= 1 (tile x (1- y)))
                                    (not (= 1 (tile x y))))
                               (let ((new (if (or prev-node (= 0 x) (= 1 (tile (1- x) y)))
                                              (make-instance 'platform-node :location (vec2 x y))
                                              (make-instance 'left-edge-node :location (vec2 x y)))))
                                 (when prev-node
                                   (connect-platforms prev-node new 'walk-edge))
                                 (setf (node x y) new)
                                 (setf prev-node new)))
                              ((= 1 (tile x y))
                               (setf prev-node NIL))
                              ((typep prev-node 'left-edge-node)
                               (change-class prev-node 'both-edge-node)
                               (setf prev-node NIL))
                              ((typep prev-node 'platform-node)
                               (change-class prev-node 'right-edge-node)
                               (setf prev-node NIL))))
               (setf prev-node NIL)))))

(defun create-fall-connections (node-grid width height)
  (flet ((node (x y)
           (aref node-grid (* (+ x (* y width)) 2))))
    (loop for y downfrom (1- height) to 0
          do (loop for x from 0 below width
                   for node = (node x y)
                   do (when (typep node 'left-edge-node)
                        (loop for yy downfrom y to 0
                              for nnode = (node (1- x) yy)
                              do (when nnode
                                   (connect-platforms node nnode 'fall-edge)
                                   (return))))
                      (when (typep node 'right-edge-node)
                        (loop for yy downfrom y to 0
                              for nnode = (node (1+ x) yy)
                              do (when nnode
                                   (connect-platforms node nnode 'fall-edge)
                                   (return))))))))

(defun calculate-jump-trajectories (g j v)
  ;; KLUDGE: bounds guesstimated by current player properties
  (let ((jump-grid (make-array (* 10 10) :initial-element NIL)))
    (loop for jf from 1 to 3
          for jv = (* j (/ jf 3))
          do (loop for vf from 0 to 3
                   for vv = (* v (/ vf 3))
                   do (let ((px 0) (py 0) (path ()))
                        (loop for tt from 0 below 2 by (/ 30)
                              for x = (round (* tt vv))
                              for y = (round (* tt (+ jv (* g tt))))
                              for i = (+ x (* (+ y 5) 10))
                              while (< i (length jump-grid))
                              do (when (or (/= px x) (/= py y))
                                   (setf px x py y)
                                   (push (cons x y) path)
                                   (push (cons (vec2 jv vv) path) (aref jump-grid i)))))))
    jump-grid))

(defun create-jump-connections-at (node x y node-grid jump-grid width height)
  (loop for jy from -5 to 5
        do (loop for jx from 1 below 10
                 for i = (+ jx (* (+ jy 5) 10))
                 for (strength . path) = (aref jump-grid i)
                 do (when strength
                      (let* ((i (+ (+ x jx) (* (+ y jy) width)))
                             (target (aref node-grid i)))
                        (when target
                          (connect-platforms node target 'jump-edge
                                             :strength strength)))))))

(defun create-jump-connections (node-grid width height)
  ;; KLUDGE: using empirically measured values
  (let ((jump-grid (calculate-jump-trajectories +vgrav+ 2.8 1.75)))
    (flet ((node (x y)
             (aref node-grid (* (+ x (* y width)) 2))))
      (loop for y downfrom (1- height) to 0
            do (loop for x from 0 below width
                     for node = (node x y)
                     do (when (typep node 'platform-node)
                          (create-jump-connections-at node x y node-grid jump-grid width height)))))))

(defun compute-node-graph (solids width height)
  (let ((node-grid (make-array (length solids) :initial-element NIL)))
    (create-platform-nodes solids node-grid width height)
    (create-fall-connections node-grid width height)
    (create-jump-connections node-grid width height)
    node-grid))

(defun format-node-graph (node-grid width height)
  (flet ((node (x y)
           (aref node-grid (* (+ x (* y width)) 2))))
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
                        (loop for con in (slot-value node 'out)
                              do (format T "~a~%" con))))
             (format T "~&"))))
