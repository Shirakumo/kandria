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
