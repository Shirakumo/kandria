(unless (fboundp 'poly-dialog-mode)
  (unless (assq 'polymode package-alist)
    (package-install 'polymode))
  (unless (assq 'markless package-alist)
    (package-install 'markless))
  
  (require 'polymode)
  (require 'markless)
  (require 'slime)

  (define-hostmode poly-lisp-hostmode
    :mode 'common-lisp-mode)

  (define-innermode poly-dialog-innermode
    :mode 'markless-mode
    :head-matcher "(\\(:interaction\\|define-interaction\\) .*?\n?\""
    :tail-matcher "[^\\]\""
    :head-mode 'host
    :tail-mode 'host)

  (define-polymode poly-dialog-mode
    :hostmode 'poly-lisp-hostmode
    :innermodes '(poly-dialog-innermode)))

;;;; Use the following mode header in relevant files:
;; -*- mode: poly-dialog; -*-
