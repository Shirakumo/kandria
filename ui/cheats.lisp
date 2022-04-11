(in-package #:org.shirakumo.fraf.kandria)

(defclass cheat-panel (pausing-panel menuing-panel)
  ())

(defmethod initialize-instance :after ((panel cheat-panel) &key)
  (let ((layout (make-instance 'big-prompt-layout))
        (label (make-instance 'label :value "" :style `((:label :halign :middle)))))
    (alloy:enter label layout :constraints `((:fill)))
    (alloy:on alloy:exit (label)
      (hide panel))
    (alloy:finish-structure panel layout label)))

(defmethod handle ((ev text-entered) (panel cheat-panel))
  (let ((longest 0) (text ""))
    (loop for cheat in *cheat-codes*
          for i = (cheat-idx cheat)
          for code = (cheat-code cheat)
          do (when (< longest i)
               (setf longest i)
               (setf text (subseq code 0 i))))
    (setf (alloy:value (alloy:focus-element panel)) text)))
