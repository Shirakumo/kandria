(asdf:defsystem #:kandria-docs
  :components ((:file "compile"))
  :depends-on (cl-markless-plump lass lquery cl-ppcre clip drakma)
  :perform (asdf:build-op (op c) (uiop:symbol-call :kandria-docs :generate-all)))
