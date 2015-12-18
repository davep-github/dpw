;;
;; Kernel style... mostly good except for a few really stupid bits.
;;

;; See actual defvar statements.

(defconst kernel-c-style
  '(
    (dp-c-fill-statement-minimal-indentation-p     . nil)
    (dp-c-like-mode-default-indent-tabs-mode       . t)
    (dp-lang-use-c-new-file-template-p             . nil)
    (dp-trailing-whitespace-use-trailing-ws-font-p . t)
    (dp-use-space-before-tab-font-lock-p           . t)
    ;; see `c-indent-command'
    (c-tab-always-indent                           . nil)
    (c-basic-offset                                . 8)
    (c-comment-only-line-offset                    . 0)

    (c-cleanup-list                . (scope-operator
                                      empty-defun-braces
                                      defun-close-semi
                                      list-close-comma
                                      brace-else-brace
                                      brace-elseif-brace
                                      knr-open-brace)) ; my own addition
    (c-offsets-alist               . ((arglist-intro     . +)
                                      (substatement-open . 0)
                                      (inline-open       . 0)
                                      (cpp-macro-cont    . +)
                                      (access-label      . /)
                                      (inclass           . +)
                                      (case-label        . 0)))
    (c-hanging-semi&comma-criteria dp-c-semi&comma-nada)
    (c-echo-syntactic-information-p . nil)
    (c-indent-comments-syntactically-p . t)
    (c-hanging-colons-alist         . ((member-init-intro . (before))))
    )
  "KERNEL C/C++ Programming Style")

(provide 'dp-c-like-styles)