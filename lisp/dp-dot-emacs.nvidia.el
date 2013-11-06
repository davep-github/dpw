(dmessage "dp-dot-emcas.nvidia.el")

;; add to post-dpmacs hook.
(add-hook 'dp-post-dpmacs-hook (lambda ()
                                 (require 'dp-perforce)))


(setq visible-bell t)
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

(defun dp-nv-configure-hide-ifdef ()
  (defvar dp-T3D-hide-ifdef-default-.so-defs
    '((NV_T3D hide-ifdef-define)
      (NV_T3D_XC hide-ifdef-undef)
      (NV_XC hide-ifdef-undef))
    "T3D definitions for hide-ifdef-* to show code of interest in .so/x86
tests.")

  (defvar dp-T3D-hide-ifdef-default-.axf-defs
    '((NV_T3D hide-ifdef-define)
      (NV_T3D_XC hide-ifdef-define)
      (NV_XC hide-ifdef-define))
    "T3D definitions for hide-ifdef-* to show code of interest in ARM .axf
tests.")
  
  (defvar dp-T3D-hide-ifdef-common-undefs
    '((USE_SW_NVTEST 'hide-ifdef-undef))
    "We never want these defined. And by never I mean usually.")

  (defun dp-setup-hide-ifdef-for-T3D.so (&optional extras)
    (interactive)
    (setq hide-ifdef-lines t
          hide-ifdef-env nil)
    (dp-hideif-assign-defs (append dp-T3D-hide-ifdef-default-.so-defs extras
                                   dp-T3D-hide-ifdef-common-undefs)
                           "t3dso"))

  (defun dp-setup-hide-ifdef-for-T3D.axf (&optional extras)
    (interactive)
    (setq hide-ifdef-lines t
          hide-ifdef-env nil)
    (dp-hideif-assign-defs (append dp-T3D-hide-ifdef-default-.axf-defs extras
                                   dp-T3D-hide-ifdef-common-undefs)
                           "t3daxf"))

  (defun dp-hide-ifdef-for-T3D.so ()
    (interactive)
    (dp-hide-ifdefs "t3dso"))
  (dp-defaliases 'hif-t3dso 'hifso 'dp-hide-ifdef-for-T3D.so)
  
  (defun dp-hide-ifdef-for-T3D.axf ()
    (interactive)
    (dp-hide-ifdefs "t3daxf"))
  (dp-defaliases 'hif-t3daxf 'hifaxf 'dp-hide-ifdef-for-T3D.axf)
)

;; Do I want the hide ifdef package activated?
;; At nVIDIA, the answer is HELL YES!
(setq dp-wants-hide-ifdef-p t)
(setq dp-hide-ifdef-configure-function 'dp-nv-configure-hide-ifdef)

(setq dp-edting-server-valid-host-regexp "\\(o\\|sc\\)-xterm-.*")

;; For some reason, vc isn't being autoloaded here, but it is @ home.
(vc-load-vc-hooks)  ; This is being added to the Tools->Version Control menu.

(defun dp-nvidia-spec-macs-hook ()
  (dp-set-sandbox-regexp "/home/scratch\.")
  (setq dp-sandbox-make-command "mmake"))

(add-hook 'dp-post-dpmacs-hook 'dp-nvidia-spec-macs-hook)

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

(defun dp-nvidia-make-cscope-database-regexps (&optional ignore-env-p)
  "Compute value for `cscope-database-regexps'"
  (let* ((locstr (or (and (not ignore-env-p)
                          (getenv "DP_NV_ME_DB_LOCS"))
                     (concat
                      "ap //arch //sw/dev //sw/mods //sw/tools //hw/class"
                      ;; NB! Make sure every item is separated by spaces.
                      "  //hw/kepler1_gklit3 //hw/tools")))
         (locs (split-string locstr))
         (sb-name (dp-current-sandbox-name))
         expansion
         result)
    (list
     (append
      (list (dp-me-expand-dest "sb" sb-name))
      (delq nil (mapcar (function
                         (lambda (loc)
                           (list (dp-me-expand-dest loc sb-name))))
                        locs))))))

(setq dp-make-cscope-database-regexps-fun
      'dp-nvidia-make-cscope-database-regexps)

(defun dp-set-cscope-database-regexps (&optional ignore-env-p)
  (interactive)
  (setq cscope-database-regexps
        (dp-nvidia-make-cscope-database-regexps ignore-env-p)))
  
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

;; Nothing in my tgen run dirs need p4.
;; e.g.: /hw/ap_t132/diag/testgen
(defvar dp-p4-ignore-dirs-regexp
  "/hw/ap.*/diag/testgen/"
  "Deactivate p4 in these dirs.")

(defun dp-p4-active-here (&optional file-name)
  (setq-ifnil file-name (buffer-file-name))
  (and (not dp-p4-global-disable-detection-p)
       (dp-sandbox-file-p file-name)
       (not (string-match dp-p4-ignore-dirs-regexp file-name))))

(setq dp-proscribed-sandbox-private-p "/sb4")
;;
;; Don't want to edit these stupid fvcking copies.
(dp-add-force-read-only-regexp "/plex/")

(provide 'dp-dot-emacs.nvidia.el)
