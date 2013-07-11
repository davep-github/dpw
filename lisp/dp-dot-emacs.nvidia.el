(dmessage "dp-dot-emcas.nvidia.el")

;; add to post-dpmacs hook.
(add-hook 'dp-post-dpmacs-hook (lambda ()
                                 (require 'dp-perforce)
                                 (p4-use-xxdiff)))

(setq visible-bell nil)
(defun dp-define-nvidia-c-style ()
  (defconst nvidia-c-style
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
                                        (inclass           . +)
                                        (case-label        . +)))
      (c-hanging-semi&comma-criteria dp-c-semi&comma-nada)
      (c-echo-syntactic-information-p . nil)
      (c-indent-comments-syntactically-p . t)
      (c-hanging-colons-alist         . ((member-init-intro . (before))))
      )
    "Nvidia C/C++ Programming Style")
  (c-add-style "nvidia-c-style" nvidia-c-style)
  (defvar dp-default-c-style-name "nvidia-c-style")
  (defvar dp-default-c-style nvidia-c-style))

(defun dp-nvidia-c-style ()
  "Set up C/C++ style."
  (interactive)
  (dp-define-nvidia-c-style)
  (c-add-style "nvidia-c-style" nvidia-c-style t))

(dp-nvidia-c-style)

;;(defun dp4-locale-client-setup ())
(fmakunbound 'dp4-locale-client-setup)

;;(setq dp-cscope-perverted-index-option nil)
;; I do it externally or use nvcscope's files.
(setq cscope-do-not-update-database t)

(defvar dp-wants-hide-ifdef-p t
  "Do I want the hide ifdef package activated?
At nVIDIA, the answer is HELL YES!")

(setq dp-edting-server-valid-host-regexp "\\(o\\|sc\\)-xterm-.*")

;; For some reason, vc isn't being autoloaded here, but it is @ home.
(vc-load-vc-hooks)  ; This is being added to the Tools->Version Control menu.

(dp-set-sandbox-regexp "/home/scratch\.")
(setq dp-sandbox-make-command "mmake")

;; 
;; Since I cannot add variable hacks to files, I'll do it another way, using
;; the auto-mode-alist mechanism.
;; XXX @todo ? Should I trim that list? There are many bad matches already.
;;

(defun dp-make-no-wrap-stupidly ()
  (setq fill-column 9999))

(dp-add-list-to-list 'auto-mode-alist
		     `(("\\(^\\|/\\)regress_tegra_gpu_multiengine$" .
                        dp-make-no-wrap-stupidly)
                       ("/tests/[^/]+/[0-9]\\{2\\}/[0-9]\\{2\\}/[0-9]\\{2\\}/[0-9]\\{6\\}/.*\\.\\(cfg\\|sh\\)" .
                       dp-make-no-wrap-stupidly)))

(defvar dp-p4-default-depot-completion-prefix "//"
  "Depot root.")


(defun dp-nvidia-make-cscope-database-regexps ()
  "Compute value for `cscope-database-regexps'"
  (let ((ap (dp-me-expand-dest "ap" (dp-current-sandbox-name)))
        (sb (dp-current-sandbox-regexp)))
    `(
      (,sb                              ; If the filename matches this regexp
       (t)                              ; Search parents for db
       (,ap)                            ; Search ap (TOT) for db
       (,sb)                            ; Search sb root.
       )
      ("/home/scratch.traces02/mobile/traces/system/so"  ; Non ME type tests.
       (,sb)
       )
      )))

(setq dp-make-cscope-database-regexps-fun
      'dp-nvidia-make-cscope-database-regexps)

;; Factor into function that takes the expander (e.g. dp-me-expand-dest) as a
;; parameter.
(defun dp-nvidia-me-expand-preceding-word (&rest r)
  (let ((beg-end (dp-preceding-word-bounds))
        beg end
        word
        expansion)
    (when beg-end
      (setq beg (car beg-end)
            end (cdr beg-end)
            word (buffer-substring beg end))
      (when word
        (setq expansion (dp-me-expand-dest word))
        (when expansion
          (delete-region beg end)
          ;; These are most often directory names.
          (insert expansion "/")
          t)))))

(setq dp-fallback-expand-abbrev-fun 'dp-nvidia-me-expand-preceding-word)

(defun dp-p4-active-here ()
  (and (not dp-p4-global-disable-detection-p)
       (dp-sandbox-file-p (buffer-file-name))))


(provide 'dp-dot-emacs.nvidia.el)
