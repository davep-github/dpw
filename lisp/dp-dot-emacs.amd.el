(require 'vc)

(setq dp-mew-case "amd")

(defun dp-select-amd-c-style ()
  "Set up C/C++ style."
  (interactive)
  (cond
   ;; Main development boxen, so I needs the kernel mode.
   ((string-match "^\\(cz\\|xerxes$\\|yyz\\)" (dp-short-hostname))
    (setq dp-current-c-style dp-kernel-c-style
          dp-current-c-style-name "dp-kernel-c-style"))
   ((string-match "^atl" (dp-short-hostname))
    (setq dp-current-c-style ptb-c-style
          dp-current-c-style-name "ptb-c-style"))
   ((and buffer-file-truename
	 (string-match "brahma/ec/linux/" buffer-file-truename))
    (setq dp-current-c-style dp-kernel-c-style
          dp-current-c-style-name "dp-kernel-c-style"))
   (t (setq dp-current-c-style dp-default-c-style
            dp-current-c-style-name dp-default-c-style-name))))

;;;(dp-select-amd-c-style)

(defun dp-add-amd-c-style ()
  (interactive)
  (dmessage "dp-add-amd-c-style")
  (dp-select-amd-c-style)
  (dp-c-add-default-style))

(defun dp-amd-c-mode-common-hook ()
  (interactive)
  (dmessage "dp-amd-c-mode-common-hook")
  (dp-add-amd-c-style)
  (c-add-style dp-current-c-style-name dp-current-c-style t)

;;   ;; Some files use this and I can't find it.
;;   (defalias 'linux-c-mode 'c-mode)
  (dp-define-local-keys
   '(
     [tab] dp-c*-electric-tab
     [? ] dp-c*-electric-space)))

;; This was a recommended way to do this.  Is it really necessary? It was
;; hacked in quickly.
(add-hook 'c-mode-common-hook 'dp-amd-c-mode-common-hook)

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
;; The latter the utterly idiotic, ugly, lazy and just plain annoying
;; permabit style.
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

(defvar dp-edit-parallel-tramp-file-default-location "/[cz-fp4-bdc]")

(setq mail-host-address "amd.com"
      mu4e-get-mail-command "mbsync.amd"
      org-agenda-files (quote ("/home/dpanarit/org/amd.org"))
      smtpmail-sendto-domain "amd.com"
      smtpmail-smtp-server "smtp.office365.com"
      user-mail-address "david.panariti@amd.com")

;; Keep in sync w/ ~/bin.amd/amd-index-edc-linux
;; (setq cscope-database-regexps
;;       '(
;;         ("^/"
;;          ("/proj/ras_arch/ras/edc/brahma/ec/drm")
;;          ("/proj/ras_arch/ras/edc/brahma/ec/linux/drivers/gpu/drm/amd/amdgpu")
;;          ("/proj/ras_arch/ras/edc/brahma/ec/linux/drivers")
;;          t
;;          ("/proj/ras_arch/ras/edc/brahma/ec/linux")
;;          t
;;          ("/proj/ras_arch/ras/edc/brahma/ec")
;;          )
;;         ))

;;
;; NB!
;; `cscope-stop-at-first-match-dir' MUST be non-nil for `t' to be able to stop
;; searches after a match is made.
;; (setq cscope-database-regexps
;;       '(
;;         ;; Only search the big dbs if we're in their directories.
;;         (
;;          "^/proj/ras_arch/ras/edc/brahma/ec/linux$"
;;          ("/proj/ras_arch/ras/edc/brahma/ec/linux")
;;          t)

;;         (
;;          "^/proj/ras_arch/ras/edc/brahma/ec$"
;;          ("/proj/ras_arch/ras/edc/brahma/ec")
;;          t)

;;         (
;;          "^/proj/ras_arch/ras/edc/brahma/ec/"
;;          ("/proj/ras_arch/ras/edc/brahma/ec/linux/drivers/gpu/drm/amd/amdgpu")
;;          t
;;          ("/proj/ras_arch/ras/edc/brahma/ec/linux/drivers")
;;          t
;;          ("/proj/ras_arch/ras/edc/brahma/ec/drm")
;;          t
;;          ("/proj/ras_arch/ras/edc/brahma/ec/linux")
;;          t
;;          ("/proj/ras_arch/ras/edc/brahma/ec")
;;          )))

;; Auto updating (of gtags) works poorly with multiple databases.
;; Avoid having multiple databases in a single path.
;;use simple hier search (setq cscope-database-regexps
;;use simple hier search       '(
;;use simple hier search         ;; Only search the big dbs if we're in their directory.
;;use simple hier search         (
;;use simple hier search          "^/proj/ras_arch/ras/edc/brahma/ec/kgd/linux$"
;;use simple hier search          ("/proj/ras_arch/ras/edc/brahma/ec/kgd/linux")
;;use simple hier search          t)

;;use simple hier search         (
;;use simple hier search          "^/proj/ras_arch/ras/edc/brahma/ec$"
;;use simple hier search          ("/proj/ras_arch/ras/edc/brahma/ec")
;;use simple hier search          t)

;;use simple hier search         (
;;use simple hier search          "^/proj/ras_arch/ras/edc/brahma/ec/drm"
;;use simple hier search          ("/proj/ras_arch/ras/edc/brahma/ec/drm")
;;use simple hier search          (t)
;;use simple hier search          t)

;;use simple hier search         (
;;use simple hier search          "^/proj/ras_arch/ras/edc/brahma/ec/kgd/"
;;use simple hier search          ("/proj/ras_arch/ras/edc/brahma/ec/kgd/linux/drivers/gpu/drm/amd")
;;use simple hier search          t
;;use simple hier search          ;; These will get stale, but the stuff we'll be looking for will be
;;use simple hier search          ;; under more up-to-date dbs.
;;use simple hier search          ("/proj/ras_arch/ras/edc/brahma/ec/kgd/linux")
;;use simple hier search          t
;;use simple hier search          ("/proj/ras_arch/ras/edc/brahma/ec")
;;use simple hier search          )))

(setq auto-mode-alist (cons '("\\.cl$" . c-mode) auto-mode-alist))

(defvar bookmark-default-file
  (dp-nuke-newline
   (shell-command-to-string
    "mk-persistent-dropping-name.sh --use-project-as-prefix emacs.bmk")))

;;; Max height I can see changed for some reason.  I think it was due
;;; to amdgpu stopping working.  Mehbe not.  Value when amdgpu runs.
(defconst dp-sfh-height 63)
;;; No amdgpu driver.
(defconst dp-sfh-height 60)

;; For now, make my old dev area RO.
;; @todo XXX Skip this if using dset?
(dp-add-force-read-only-regexp
 '("\\(^\\|/\\)syslog.*"
   "/proj/ras_arch/ras/edc/brahma/"
   "/ras.local/edc/brahma/ec"
   "/ras.nfs/edc/brahma/ec"
   "/tmp-for-edc-code/"
   "/releases.amd-17\\.40/linux"
   "/tmp-for-edc-code/"
   ))

(custom-set-variables
 '(tramp-default-method "ssh")
 '(tramp-default-user "dpanarit")
 '(tramp-default-host "pablo"))

;; (setq dp-<type>*-regexp-list
;;       (dp-add-to-list
;;        'dp-<type>*-regexp-list
;;        (concat
;;         "struct\\s-+"
;;         "\\("
;;         "amdgpu_device"
;;         "\\|amdgpu_ring"
;;         "\\|amdgpu_ib"
;;         "\\|amdgpu_irq_src_funcs"
;;         "\\|amdgpu_ring_funcs"
;;         "\\|amd_ip_funcs"
;;         "\\|amdgpu_irq_src"
;;         "\\|amdgpu_iv_entry"
;;         "\\|drm_device"
;;         "\\|device"
;;         "\\|device_attribute"
;;         "\\|amdgpu_gds_reg_offset"
;;         "\\|fence"
;;         "\\|reg32_counter_name_map"
;;         "\\|pid"
;;         "\\|task_struct"
;;         "\\|edc_dump_count_info_t"
;;         "\\|amdgpu_cu_info"
;;         "\\|dentry"
;;         "\\|file_operations"
;;         "\\|debug_file_info"
;;         "\\)")))
