(asdf:defsystem kandria-release
  :components ((:file "release"))
  :depends-on (:pathname-utils :zippy :deploy)
  :perform (asdf:build-op (op c) (uiop:symbol-call :release :release)))
