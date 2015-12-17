(require 'vc)

;; See actual defvar statement.
(setq dp-c-fill-statement-minimal-indentation-p nil)
(setq dp-c-like-mode-default-indent-tabs-mode t)
(setq dp-lang-use-c-new-file-template-p nil)
(setq dp-trailing-whitespace-use-trailing-ws-font-p t)
(setq dp-use-space-before-tab-font-lock-p t)
(defun dp-define-amd-c-style ()
  (defconst amd-c-style
    '(
      ;; see `c-indent-command'
      (c-tab-always-indent           . nil)
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
                                (dp-define-local-keys
                                 '(
                                   [tab] dp-c*-electric-tab
                                   [? ] dp-c*-electric-space))))

;; Make it so that we `align' properly:
;; struct moo
;; {
;; 	bool					enabled;
;; 	const struct amdgpu_vm_pte_funcs 	*vm_pte_funcs;
;; };
;; rather than:
;; struct moo
;; {
;; 	bool					enabled;
;; 	const struct amdgpu_vm_pte_funcs       *vm_pte_funcs;
;; };

;; The former matches the (ridiculous) kernel style.
;; Both are like jet engines: they suck and they blow.
(require 'align)
(setcdr
  (assoc 'regexp
         (assoc 
          'c-variable-declaration
          align-rules-list))
  (concat "[*&0-9A-Za-z_]>?[&*]*\\(\\s-+[!]*\\)"
			  "\\*?[A-Za-z_][0-9A-Za-z:_]*\\s-*\\(\\()\\|"
			  "=[^=\n].*\\|(.*)\\|\\(\\[.*\\]\\)*\\)?"
			  "\\s-*[;,]\\|)\\s-*$\\)"))