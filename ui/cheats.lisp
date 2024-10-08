(in-package #:org.shirakumo.fraf.kandria)

(defclass cheat-label (label)
  ((markup :initform () :accessor markup)
   (alloy:value :initform "Type in a cheat code")))

(presentations:define-update (ui cheat-label)
  (:label
   :halign :middle
   :markup (markup alloy:renderable)))

(defclass cheat-panel (pausing-panel menuing-panel)
  ())

(defmethod initialize-instance :after ((panel cheat-panel) &key)
  (let ((layout (make-instance 'big-prompt-layout))
        (label (make-instance 'cheat-label)))
    (alloy:enter label layout :constraints `((:fill)))
    (alloy:on alloy:exit (label)
      (setf (alloy:focus label) :strong))
    (alloy:finish-structure panel layout label)))

(defmethod show :before ((panel cheat-panel) &key)
  (when (eql :fishing (state (u 'player)))
    (handle (make-instance 'stop-fishing) (u 'player)))
  #+trial-steam
  (ignore-errors (steam:show-floating-text-input (steam:interface 'steam:steamutils T))))

(defmethod hide :after ((panel cheat-panel))
  #+trial-steam
  (ignore-errors (steam:hide-floating-text-input (steam:interface 'steam:steamutils T))))

(defmethod handle ((ev key-release) (panel cheat-panel))
  (when (eql :escape (key ev))
    (hide panel)))

(defmethod handle ((ev text-entered) (panel cheat-panel))
  (let ((longest 0)
        (text ""))
    (loop for cheat in *cheat-codes*
          for i = (cheat-idx cheat)
          for code = (cheat-code cheat)
          do (cond ((< longest i)
                    (setf longest i)
                    (setf text code))
                   ((= 0 i))
                   ((= longest i)
                    (setf text (format NIL "~a~%~a" text code)))))
    (setf (alloy:value (alloy:focus-element panel)) text)
    (setf (markup (alloy:focus-element panel))
          `((0 ,longest (:color ,colors:white))
            (,longest ,(length text) (:color ,colors:gray))))))
