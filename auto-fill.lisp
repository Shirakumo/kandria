(in-package #:org.shirakumo.fraf.kandria)

(defun %flood-fill (layer width height x y fill)
  (let* ((tmp (vec2 0 0)))
    (labels ((pos (x y)
               (* (+ x (* y width)) 2))
             (tile (x y)
               (vsetf tmp
                      (aref layer (+ 0 (pos x y)))
                      (aref layer (+ 1 (pos x y)))))
             ((setf tile) (f x y)
               (setf (aref layer (+ 0 (pos x y))) (first f)
                     (aref layer (+ 1 (pos x y))) (second f))))
      (let ((q ()) (find (vec2 (aref layer (+ 0 (pos x y)))
                               (aref layer (+ 1 (pos x y))))))
        (unless (v= (vec (first fill) (second fill)) find)
          (push (cons x y) q)
          (loop while q for (n . y) = (pop q)
                for w = n for e = n
                do (loop until (or (= w 0) (v/= (tile (1- w) y) find))
                         do (decf w))
                   (loop until (or (= e (1- width)) (v/= (tile (1+ e) y) find))
                         do (incf e))
                   (loop for i from w to e
                         do (setf (tile i y) fill)
                            (when (and (< y (1- height)) (v= (tile i (1+ y)) find))
                              (pushnew (cons i (1+ y)) q))
                            (when (and (< 0 y) (v= (tile i (1- y)) find))
                              (pushnew (cons i (1- y)) q)))))))))

(defparameter *background-filters*
  '((:bg-tl>
     o o _
     o s s
     _ s s)
    (:bg-tr>
     _ o o
     s s o
     s s _)
    (:bg-bl>
     _ s s
     o s s
     o o _)
    (:bg-br>
     s s _
     s s o
     _ o o)
    (:bg-tl<
     o s _
     s s _
     _ _ s)
    (:bg-tr<
     _ _ s
     s s _
     o s _)
    (:bg-bl<
     _ s o
     _ s s
     s _ _)
    (:bg-br<
     s _ _
     _ s s
     _ s o)
    (:bg-i
     _ x _
     x s x
     _ x _)
    (:bg-t
     _ o _
     _ s _
     _ s _)
    (:bg-b
     _ s _
     _ s _
     _ o _)
    (:bg-l
     _ _ _
     o s s
     _ _ _)
    (:bg-r
     _ _ _
     s s o
     _ _ _)))

(defparameter *tile-filters*
  '((:platform-l
     _ _ _
     s* p _
     _ _ _)
    (:platform-r
     _ _ _
     _ p s*
     _ _ _)
    (:platform
     _ _ _
     _ p _
     _ _ _)
    (:tr>
     _ o o
     s s o
     x s _)
    (:tl>
     o o _
     o s s
     _ s x)
    (:br>
     x s _
     s s o
     _ o o)
    (:bl>
     _ s x
     o s s
     o o _)
    (:t
     _ o _
     s s s
     _ x _)
    (:b
     x x _
     s s s
     _ o _)
    (:l
     _ s x
     o s x
     _ s x)
    (:r
     x s _
     x s o
     x s _)
    (:tr<
     x x x
     s s x
     o s x)
    (:tl<
     x x x
     x s s
     x s o)
    (:br<
     o s x
     s s x
     x x x)
    (:bl<
     x s o
     x s s
     x x x)
    (:ct
     o s o
     s s s
     _ i _)
    (:cb
     _ i _
     s s s
     o s o)
    (:cl
     o s _
     s s i
     o s _)
    (:cr
     _ s o
     i s s
     _ s o)
    (:h
     _ o _
     s s s
     _ o _)
    (:v
     _ s _
     o s o
     _ s _)
    (:hl
     _ o _
     o s s
     _ o _)
    (:hr
     _ o _
     s s o
     _ o _)
    (:vt
     _ o _
     o s o
     _ s _)
    (:vb
     _ s _
     o s o
     _ o _)
    (:c
     _ o _
     o s o
     _ o _)
    (:spike-tr>
     _ _ _
     sp _ _
     s sp _)
    (:spike-tl>
     _ _ _
     _ _ sp
     _ sp s)
    (:spike-bl>
     _ sp s
     _ _ sp
     _ _ _)
    (:spike-br>
     s sp _
     sp _ _
     _ _ _)
    (:spike-bl<
     _ sp _
     _ _ sp
     x _ _)
    (:spike-br<
     _ sp _
     sp _ _
     _ _ x)
    (:spike-tr<
     _ _ x
     sp _ _
     _ sp _)
    (:spike-tl<
     x _ _
     _ _ sp
     _ sp _)
    (:spike-bl<
     sp _ _
     s _ sp
     x _ _)
    (:spike-br<
     _ _ sp
     sp _ s
     _ _ x)
    (:spike-tr<
     sp s x
     _ _ _
     _ sp _)
    (:spike-tl<
     x s sp
     _ _ _
     _ sp _)
    (:spike-t
     _ z _
     _ sp _
     _ _ _)
    (:spike-b
     _ _ _
     _ sp _
     _ z _)
    (:spike-l
     _ _ _
     z sp _
     _ _ _)
    (:spike-r
     _ _ _
     _ sp z
     _ _ _)
    (:spike
     _ _ _
     _ sp _
     _ _ _)))

(declaim (inline tile-type-p))
(defun tile-type-p (tile type)
  (ecase type
    ;; Tiles that are "outside"
    (o (or (= 0 tile) (= 2 tile) (= 3 tile) (<= 16 tile 20)))
    ;; Tiles that are edges
    (s (or (= 1 tile) (= 2 tile) (<= 4 tile 15) (= 21 tile)))
    ;; Tiles that are edges or inside
    (x (or (<= 1 tile 15) (= 21 tile) (= 255 tile) (= 22 tile)))
    ;; Tiles that are empty but inside
    (i (or (= 255 tile) (= 22 tile)))
    ;; Tiles that are platforms
    (p (= 2 tile))
    ;; Tiles that are solid but not platforms
    (s* (or (= 1 tile) (<= 4 tile 15) (= 21 tile)))
    ;; Tiles that are only blocks
    (b (or (= 1 tile) (= 21 tile)))
    ;; Tiles that are slopes
    (/ (<= 4 tile 15))
    ;; Tiles that you can bonk on
    (k (or (= 1 tile) (<= 17 tile 20) (= 21 tile)))
    ;; Tiles that can be climbed on
    (c (= 1 tile))
    ;; Spikes
    (sp (or (= 3 tile) (<= 17 tile 20)))
    ;; Zero
    (z (= 0 tile))
    (nz (< 0 tile))
    ;; Any tile at all (don't care)
    (_ T)))

(defun filter-edge (solids width height x y &optional (filters *tile-filters*))
  (labels ((pos (x y)
             (* (+ x (* y width)) 2))
           (tile (ox oy)
             (let* ((x (+ ox x))
                    (y (+ oy y))
                    (pos (pos x y)))
               (cond ((or (= -1 x) (= -1 y) (= width x) (= height y)) 1)
                     ((or (< x -1) (< y -1) (< width x) (< height y)) 0)
                     (T (aref solids pos))))))
    (loop for (type . filter) in filters
          do (when (loop for i from 0 below 9
                         for v in filter
                         for x = (- (mod i 3) 1)
                         for y = (- 1 (floor i 3))
                         for tile = (tile x y)
                         always (tile-type-p tile v))
               (return type)))))

(defun %auto-tile (solids tiles width height x y map)
  (flet ((tile (x y)
           (if (and (< -1 x width) (< -1 y height))
               (aref solids (* (+ x (* y width)) 2))
               0))
         ((setf tile) (kind x y &optional fallback)
           (let ((tilelist (cdr (or (assoc kind map :test 'equal)
                                    (assoc fallback map :test 'equal)))))
             (when tilelist
               (set-tile tiles width height x y (alexandria:random-elt tilelist))))))
    (when (= 0 (tile x y))
      (%flood-fill solids width height x y (list 22 0)))
    (dotimes (y height)
      (dotimes (x width)
        (let ((edge (filter-edge solids width height x y)))
          (when edge
            (setf (tile x y) edge)))))
    (dotimes (y height)
      (dotimes (x width)
        (case (tile x y)
          ( 4 (setf (tile x y) `(:slope 0)))
          ( 5 (setf (tile x y) `(:slope 1)))
          ( 6 (setf (tile x y) `(:slope 2)))
          ( 7 (setf (tile x y) `(:slope 3)))
          ( 8 (setf (tile x y) `(:slope 4)))
          ( 9 (setf (tile x y) `(:slope 5)))
          (10 (setf (tile x y) `(:slope 6)))
          (11 (setf (tile x y) `(:slope 7)))
          (12 (setf (tile x y) `(:slope 8)))
          (13 (setf (tile x y) `(:slope 9)))
          (14 (setf (tile x y) `(:slope 10)))
          (15 (setf (tile x y) `(:slope 11)))
          (22
           (let ((mindist 100))
             (loop for dy from -5 to +5
                   do (loop for dx from -5 to +5
                            do (when (< 0 (tile (+ x dx) (+ y dy)) 22)
                                 (setf mindist (min mindist (sqrt (+ (* dx dx) (* dy dy))))))))
             (setf (tile x y T) (round mindist)))))
        (when (<= 4 (tile x y) 15)
          (set-tile tiles width height x (1+ y) '(0 0 1 1)))))))

(defun %auto-tile-bg (tiles width height map)
  (labels ((tile (x y)
             (when (and (< -1 x width)
                        (< -1 y height))
               (+ (aref tiles (+ 0 (* (+ x (* y width)) 2)))
                  (aref tiles (+ 1 (* (+ x (* y width)) 2))))))
           ((setf tile) (kind x y &optional fallback)
             (let ((tilelist (cdr (or (assoc kind map :test 'equal)
                                      (assoc fallback map :test 'equal)))))
               (when tilelist
                 (set-tile tiles width height x y (alexandria:random-elt tilelist)))))
           (filter-edge (x y)
             (loop for (type . filter) in *background-filters*
                   do (when (loop for i from 0 below 9
                                  for v in filter
                                  for dx = (- (mod i 3) 1)
                                  for dy = (- 1 (floor i 3))
                                  for tile = (tile (+ x dx) (+ y dy))
                                  always (ecase v
                                           (s (and tile (< 0 tile)))
                                           (x (or (null tile) (< 0 tile)))
                                           (o (or (null tile) (= 0 tile)))
                                           (_ T)))
                        (return type)))))
    (dotimes (y height)
      (dotimes (x width)
        (let ((edge (filter-edge x y)))
          (when edge
            (setf (tile x y) edge)))))))
