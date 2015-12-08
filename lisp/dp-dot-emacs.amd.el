(require 'vc)

;; See actual defvar statement.
(setq dp-c-fill-statement-minimal-indentation-p nil)
(setq dp-c-like-mode-default-indent-tabs-mode t)
(setq dp-lang-use-c-new-file-template-p nil)
(setq dp-trailing-whitespace-use-trailing-ws-font-p t)
(defun dp-define-amd-c-style ()
  (defconst amd-c-style
    '((c-tab-always-indent           . t)
      (c-basic-offset                . 8)
      (c-comment-only-line-offset    . 0)
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
    "AMD C/C++ Programming Style")
  (c-add-style "amd-c-style" amd-c-style)
  (defvar dp-default-c-style-name "amd-c-style")
  (defvar dp-default-c-style amd-c-style))

(defun dp-add-amd-c-style ()
  "Set up C/C++ style."
  (interactive)
  (dp-define-amd-c-style)
  (c-add-style "amd-c-style" amd-c-style t))

(defvar dp-default-c-style-name "amd-c-style")
(dp-add-amd-c-style)

;;Meh.
(add-hook 'c-mode-common-hook (lambda ()
                                (local-set-key [? ] 'dp-c*-electric-space)))