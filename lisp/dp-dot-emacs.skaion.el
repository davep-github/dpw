
;; Never remove passwords from cache.
(setq password-cache-expiry nil)


(dp-add-list-to-list 
 'dp-auto-mode-alist-additions
 ;; (regexp . func-to-call-when-loaded)
 (list
  (cons "/etc/hosts"
        'dp-make-no-fill-stupidly-sh-mode)))


(defconst skaion-c-style
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
  "SKAION C Programming Style")
(c-add-style "skaion-c-style" skaion-c-style t)

(unless (bound-and-true-p dp-default-c-style-name)
  (defvar dp-default-c-style-name "skaion-c-style"))

(defun skaion-style ()
  "Set up home (Skaion.net) C style."
  (interactive)
  (c-set-style "skaion-c-style"))

(defvar dp-default-c-style-name "skaion-c-style")

