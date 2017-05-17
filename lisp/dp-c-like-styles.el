;;
;; Kernel style... mostly good except for a few really stupid bits.
;;

;; See actual defvar statements.

;;
;; Transferred from dp-hooks.el
;; Styles have changed a lot over the years.
;; Check git history or svn (if repo can be found) or rcs home dir backup
;; archive.
;;
(defconst dp-kernel-c-style
  '(
    (dp-c-using-kernel-style-p                     . t)
    (dp-use-stupid-kernel-indentation-p            . nil)
    (dp-c-like-mode-default-indent-tabs-mode-p     . t)
    (dp-lang-use-c-new-file-template-p             . nil)
    (dp-trailing-whitespace-use-trailing-ws-font-p . t)
    (dp-use-space-before-tab-font-lock-p           . t)
    (dp-use-too-many-spaces-font-p                 . t)
    (dp-use-ugly-ass-pointer-style-p               . t)
    (c-insert-tab-function                         . dp-phys-tab)
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
    (c-hanging-braces-alist         . ((brace-list-open   . ignore)
                                       (brace-list-close  . ignore)
                                       (brace-list-intro  . ignore)
                                       (substatement-open . (after))
                                       (brace-entry-open  . ignore)))

    (c-hanging-colons-alist         . ((member-init-intro . (before))))
    )
  "KERNEL C/C++ Programming Style")
(c-add-style "dp-kernel-c-style" dp-kernel-c-style)

(defun linux-c-mode ()
  "C mode with Linux kernel defaults"
  (dmessage "in linux-c-mode.")
  (interactive)
  (c-mode)
  (c-set-style "dp-kernel-c-style" t)
  (setq c-tab-always-indent (not dp-use-stupid-kernel-indentation-p)))

(defconst dp-basic-c-style
  '(
    (dp-c-using-kernel-style-p                     . nil)
    (dp-use-stupid-kernel-indentation-p            . nil)
    (dp-c-like-mode-default-indent-tabs-mode-p     . nil)
    (dp-lang-use-c-new-file-template-p             . t)
    (dp-trailing-whitespace-use-trailing-ws-font-p . t)
    (dp-use-space-before-tab-font-lock-p           . nil)
    (dp-use-too-many-spaces-font-p                 . nil)
    (dp-use-ugly-ass-pointer-style-p               . nil)
    (c-tab-always-indent           . t)
    (c-basic-offset                . 4)
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
				      (case-label        . +)))
    (c-hanging-semi&comma-criteria dp-c-semi&comma-nada)
    (c-echo-syntactic-information-p . nil)
    (c-indent-comments-syntactically-p . t)
    (c-hanging-braces-alist         . ((brace-list-open   . ignore)
                                       (brace-list-close  . ignore)
                                       (brace-list-intro  . ignore)
                                       (substatement-open . (after))
                                       (brace-entry-open  . ignore)))
    (c-hanging-colons-alist         . ((member-init-intro . (before))))
    )
  "Basic C Programming Style")
(c-add-style "basic-c-style" dp-basic-c-style)
(c-add-style "ptb-c-style" dp-basic-c-style)

;; `defvar' only sets if void.
(defvar dp-default-c-style-name "basic-c-style")
(defvar dp-default-c-style dp-basic-c-style)

(defconst meduseld-c-style
  '((c-tab-always-indent           . t)
    (c-basic-offset                . 4)
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
				      (case-label        . +)))
    (c-hanging-semi&comma-criteria dp-c-semi&comma-nada)
    (c-echo-syntactic-information-p . nil)
    (c-indent-comments-syntactically-p . t)
    (c-hanging-colons-alist         . ((member-init-intro . (before))))
    )
  "MEDUSELD C Programming Style")
(c-add-style "meduseld-c-style" meduseld-c-style)

(defcustom dp-default-c-style 
  (symbol-value (intern-soft dp-default-c-style-name))
  "*Default C[++] style."
  :group 'dp-vars
  :type 'symbol)

(defun dp-c-add-default-style (&optional name style)
  (interactive)
  (dmessage "dp-c-add-default-style, name>%s< style>%s<" name style)
  (when name
    (setq dp-default-c-style-name name))
  (when style
    (setq dp-default-c-style style))
  (c-add-style dp-default-c-style-name dp-default-c-style t))

(defun meduseld-style ()
  "Set up home (Meduseld.net) C style."
  (interactive)
  (c-set-style "meduseld-c-style"))

(defun dp-cc-mode-activate-style (&optional style-name)
  "Set up a C/C++ style. Use the default by default."
  (interactive)
  (dmessage "in dp-cc-mode-activate-style, style-name>%s<" style-name)
  (c-set-style (or style-name dp-default-c-style-name)) t)

(setq c-default-style `((other . ,dp-default-c-style-name)
                        ;;(other . "meduseld-c-style")
                        (java-mode . "java") ))

(dp-deflocal current-project-c++-mode-style nil
  "*Variable set via File Variables to indicate the current c-mode style")

(dp-deflocal current-project-c++-mode-style-name nil
  "*Variable set via File Variables to indicate the current c-mode style name")

;;; A bit of history.
;; (defun ll-style ()
;;   "Set up ll C/C++ style."
;;   (interactive)
;;   (c-set-style "ll-c-style"))

;; (defun av2-style ()
;;   "Set up avalanche 2 C style."
;;   (interactive)
;;   (c-set-style "av2-c-style"))

;; (defun crl-style ()
;;   "Set up crl C style."
;;   (interactive)
;;   (c-set-style "crl-c-style"))

;; (defun vanu-style ()
;;   "Set up Vanu C style."
;;   (interactive)
;;   (c-set-style "vanu-c-style"))
;;

(provide 'dp-c-like-styles)
