(in-package #:org.shirakumo.fraf.kandria)

(defstruct (block (:constructor make-block (s)))
  (s 0 :type (unsigned-byte 16)))

(defmethod is-collider-for ((entity game-entity) (block block)) T)

(defstruct (ground (:include block)
                   (:constructor make-ground (s))))

(defstruct (platform (:include block)
                     (:constructor make-platform (s))))

(defstruct (death (:include block)
                  (:constructor make-death (s))))

(defstruct (spike (:include death)
                  (:constructor make-spike (s normal)))
  (normal NIL :type vec2))

(defstruct (slope (:include block)
                  (:constructor make-slope (s l r)))
  (l NIL :type vec2)
  (r NIL :type vec2))

(defstruct (stopper (:include block)
                    (:constructor make-stopper (s))))

(defstruct (slipblock (:include ground)
                      (:constructor make-slipblock (s))))

(defun make-surface-blocks (t-s slope-steps)
  (let ((blocks ()))
    (flet ((make (c &rest args)
             (push (apply (find-symbol (format NIL "MAKE-~a" c)) t-s args) blocks)))
      (make 'block)
      (make 'ground)
      (make 'platform)
      (make 'death)
      (loop for steps in slope-steps
            do (loop for i from 0 below steps
                     for l = (* (/ i steps) t-s)
                     for r = (* (/ (1+ i) steps) t-s)
                     do (make 'slope
                              (vec2 (/ t-s -2) (- (floor l) (/ t-s 2)))
                              (vec2 (/ t-s +2) (- (floor r) (/ t-s 2)))))
            do (loop for i downfrom steps above 0
                     for l = (* (/ i steps) t-s)
                     for r = (* (/ (1- i) steps) t-s)
                     do (make 'slope
                              (vec2 (/ t-s -2) (- (floor l) (/ t-s 2)))
                              (vec2 (/ t-s +2) (- (floor r) (/ t-s 2))))))
      (make 'stopper)
      (make 'spike (vec 0 +1))
      (make 'spike (vec +1 0))
      (make 'spike (vec 0 -1))
      (make 'spike (vec -1 0))
      (make 'slipblock)
      (make 'ground)
      (coerce (nreverse blocks) 'vector))))

(sb-ext:defglobal +surface-blocks+ NIL)
(setf +surface-blocks+ (make-surface-blocks +tile-size+ '(1 2 3)))

(defmethod velocity ((block block))
  #.(vec2 0 0))

(defmethod bsize ((block block))
  #.(vec2 (/ +tile-size+ 2) (/ +tile-size+ 2)))

