(in-package #:org.shirakumo.fraf.leaf)

;;; Calculate an RGB triplet from a colour temperature,
;;; according to real sunlight scales. This is based on
;;; http://www.zombieprototypes.com/?p=210
;;; This should be usable in the region 1'000K to 40'000K.
;;; Daylight occurs in the region 5'000K - 6'500K.
(defun temperature-color (temp)
  (let ((temp (coerce temp 'double-float)))
    (declare (type (double-float 1d0) temp))
    (declare (optimize speed))
    (flet ((e (a b c d)
             (declare (type double-float a b c d))
             (let ((x (- (/ temp 100) d)))
               (coerce (max 0d0 (min 1d0 (/ (+ a (* b x) (* c (the double-float (log x)))) 255)))
                       'single-float))))
      (vec3 (e 351.97690566805693d0
               0.114206453784165d0
               -40.25366309332127d0
               55d0)
            (if (< temp 6600)
                (e -155.25485562709179d0
                   -0.44596950469579133d0
                   104.49216199393888d0
                   2d0)
                (e 325.4494125711974d0
                   0.07943456536662342d0
                   0.07943456536662342d0
                   50d0))
            (e
             -254.76935184120902d0
             -254.76935184120902d0
             115.67994401066147d0
             10d0)))))

(defun gradient-value (x gradient)
  (loop for (nstop ncolor) in (rest gradient)
        for (stop color) in gradient
        while nstop
        do (when (<= stop x nstop)
             (return (vlerp color ncolor
                            (/ (- x stop) (- nstop stop)))))))

(defun gradient (&rest values)
  (loop for (stop hex) on values by #'cddr
        while hex
        for r = (ldb (byte 8 16) hex)
        for g = (ldb (byte 8  8) hex)
        for b = (ldb (byte 8  0) hex)
        collect (list (/ stop 100.0)
                      (vec (/ r 255) (/ g 255) (/ b 255)))))

(defun clock-color (clock)
  (gradient-value (/ (mod clock 24.0) 24.0)
                  (load-time-value (gradient 0   #x10003D
                                             17  #x373F63
                                             25  #xFF7A7A
                                             30  #xFCFFC6
                                             40  #xE2FFF9
                                             60  #xE2FFF9
                                             70  #xFCFFC6
                                             77  #xFFAB35
                                             81  #xE55B5B
                                             86  #x373F63
                                             100 #x10003D))))
