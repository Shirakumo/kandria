(asdf:defsystem kandria-release
  :components ((:file "release"))
  :depends-on (:trial-release)
  :perform (asdf:build-op (op c) (uiop:symbol-call :org.shirakumo.fraf.trial.release :make)))
