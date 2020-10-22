(in-package #:org.shirakumo.fraf.kandria)

(defstruct (gradient
            (:constructor %%make-gradient (stops colors)))
  (stops NIL :type (simple-array single-float))
  (colors NIL :type (simple-array vec3)))

(defun %make-gradient (values)
  (let ((stops (make-array (/ (length values) 2) :element-type 'single-float))
        (colors (make-array (/ (length values) 2))))
    (loop for (stop rgb) on values by #'cddr
          for i from 0
          while rgb
          do (setf (aref stops i) (float stop))
             (setf (aref colors i) (vec (first rgb) (second rgb) (third rgb))))
    (%%make-gradient stops colors)))

(defun multiply-gradient (gradient value)
  (loop for color across (gradient-colors gradient)
        do (nv* color value))
  gradient)

(defun make-gradient (values)
  (%make-gradient values))

(define-compiler-macro make-gradient (values &environment env)
  (if (constantp values env)
      `(load-time-value (%make-gradient ,values))
      `(%make-gradient ,values)))

(defun find-gradient-position (v values)
  (declare (type single-float v))
  (declare (type (simple-array single-float) values))
  (declare (optimize speed))
  ;; First check bounds
  (cond ((<= v (aref values 0))
         0)
        ((<= (aref values (1- (length values))) v)
         (- (length values) 2))
        (T ;; Binary search
         (let* ((i (floor (length values) 2))
                (step (floor i 2)))
           (declare (type (unsigned-byte 32) i step))
           (loop for left = (aref values i)
                 do (cond ((< v left)
                           (decf i step)
                           (setf step (max 1 (floor step 2))))
                          ((< (aref values (1+ i)) v)
                           (incf i step)
                           (setf step (max 1 (floor step 2))))
                          (T
                           (return i))))))))

(defun gradient-value (x gradient)
  (let* ((stops (gradient-stops gradient))
         (colors (gradient-colors gradient))
         (i (find-gradient-position x stops))
         (l (aref stops i))
         (r (aref stops (1+ i)))
         (mix (clamp 0 (/ (- x l) (- r l)) 1)))
    (vlerp (aref colors i) (aref colors (1+ i)) mix)))

(defun gradient (x stops)
  (gradient-value x (make-gradient stops)))

(define-compiler-macro gradient (x stops)
  `(gradient-value ,x (make-gradient ,stops)))

(defun clock-color (clock)
  (gradient (mod (float clock) 24.0)
            '( 0 (0.0627451 0.0 0.23921569)
               1 (0.21568628 0.24705882 0.3882353)
               5 (1.0 0.47843137 0.47843137)
               7 (0.9882353 1.0 0.7764706)
               9 (0.8862745 1.0 0.9764706)
              14 (0.8862745 1.0 0.9764706)
              16 (0.9882353 1.0 0.7764706)
              18 (1.0 0.67058825 0.20784314)
              19 (0.8980392 0.35686275 0.35686275)
              20 (0.21568628 0.24705882 0.3882353)
              24 (0.0627451 0.0 0.23921569))))
