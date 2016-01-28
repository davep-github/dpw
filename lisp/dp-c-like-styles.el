;;
;; Kernel style... mostly good except for a few really stupid bits.
;;

;; See actual defvar statements.

(defconst dp-kernel-c-style
  '(
    (dp-c-using-kernel-style-p                     . t)
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
                                      (statement-block-intro . +)
                                      (knr-argdecl-intro     . 0)
                                      (substatement-label    . 0)
                                      (label                 . 0)
                                      (statement-cont        . +)

                                      (case-label        . 0)))
    (c-hanging-semi&comma-criteria dp-c-semi&comma-nada)
    (c-echo-syntactic-information-p . nil)
    (c-indent-comments-syntactically-p . t)
    (c-hanging-braces-alist         . ((brace-list-open . ignore)
                                       (brace-list-close . ignore)
                                       (brace-entry-open . ignore)))

    (c-hanging-colons-alist         . ((member-init-intro . (before))))
    )
  "KERNEL C/C++ Programming Style")
(c-add-style "dp-kernel-c-style" dp-kernel-c-style)

(defun linux-c-mode ()
  "C mode with Linux kernel defaults"
  (interactive)
  (c-mode)
  (c-set-style "dp-kernel-c-style"))

(provide 'dp-c-like-styles)