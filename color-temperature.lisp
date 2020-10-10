(in-package #:org.shirakumo.fraf.kandria)

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
