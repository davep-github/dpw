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

(dmessage "featurep gtags: %s" (featurep 'gtags))
;;(dmessage "B:gtags-global-command>%s<" gtags-global-command)
(setq gtags-global-command "ranking-global-gtags.py")
(dmessage "A:gtags-global-command>%s<" gtags-global-command)

(defun dp-nvidia-c-style ()
  "Set up C/C++ style."
  (interactive)
  (dp-define-nvidia-c-style)
  (c-add-style "nvidia-c-style" nvidia-c-style t))

(dp-nvidia-c-style)

(defun dp-nvgrep (command-args)
  "NVGrep current tree"
  (interactive
   (list (read-shell-command
	  "dp-nvgrep: "
	  (format "dp-nvgrep %c%s%c "
                  ?\'
                  (dp-get--as-string--region-or...)
                  ?\')
	  'dp-grep-history)))
  (save-some-buffers)
  (grep command-args))

(dp-safe-aliases 'nvg 'nvgrep 'dp-nvgrep)

;;(defun dp4-locale-client-setup ())
(fmakunbound 'dp4-locale-client-setup)

;;(setq dp-cscope-perverted-index-option nil)
;; I do it externally or use nvcscope's files.
(setq cscope-do-not-update-database t)

(defvar dp-default-hide-ifdef-lines nil
  "*Default value for `hide-ifdef-lines' (q.v.)")

(defun dp-nv-configure-hide-ifdef-GME ()
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
    '((USE_SW_NVTEST hide-ifdef-undef))
    "We never want these defined. And by never I mean usually.")

  (defun dp-setup-hide-ifdef-for-T3D.so (&optional extras)
    (interactive)
    (setq hide-ifdef-lines dp-default-hide-ifdef-lines
          hide-ifdef-env nil)
    (dp-hideif-assign-defs (append dp-T3D-hide-ifdef-default-.so-defs extras
                                   dp-T3D-hide-ifdef-common-undefs)
                           't3dso))

  (defun dp-setup-hide-ifdef-for-T3D.axf (&optional extras)
    (interactive)
    (setq hide-ifdef-lines dp-default-hide-ifdef-lines
          hide-ifdef-env nil)
    (dp-hideif-assign-defs (append dp-T3D-hide-ifdef-default-.axf-defs extras
                                   dp-T3D-hide-ifdef-common-undefs)
                           't3daxf))

  (defun dp-hide-ifdef-for-T3D.so ()
    (interactive)
    (dp-hide-ifdefs 't3dso))
  (dp-defaliases 'hif-t3dso 'hifso 'dp-hide-ifdef-for-T3D.so)
  
  (defun dp-hide-ifdef-for-T3D.axf ()
    (interactive)
    (dp-hide-ifdefs 't3daxf))
  (dp-defaliases 'hif-t3daxf 'hifaxf 'dp-hide-ifdef-for-T3D.axf)
)

;; Do I want the hide ifdef package activated?
;; At nVIDIA, the answer is HELL YES!
(setq dp-wants-hide-ifdef-p t)
(setq dp-hide-ifdef-configure-function 'dp-nv-configure-hide-ifdef-GME)

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

(defvar dp-generic-sandbox-dir-prefix 
  "/home/scratch.dpanariti[^/]*/"
  "All nvidia sandboxes will be rooted under dirs of this form.")

(dp-add-list-to-list 
 'dp-auto-mode-alist-additions
 (list ;; (regexp . func-to-call-when-loaded)
  (cons (format "%s.*/\\(regress_tegra_gpu_multiengine\\|gpu_multiengine_a[rs]2\\)$" dp-generic-sandbox-dir-prefix)
        'dp-make-no-fill-stupidly-text-mode)
   (cons (format "%s.*/tool_data.config$" dp-generic-sandbox-dir-prefix)
         'dp-make-no-fill-stupidly-text-mode)
   (cons (format "%s.*/tests/[^/]+/[0-9]\\{2\\}/[0-9]\\{2\\}/[0-9]\\{2\\}/[0-9]\\{6\\}/.*\\.\\(cfg\\|sh\\)" dp-generic-sandbox-dir-prefix)
         'dp-make-no-fill-stupidly-sh-mode)
   ;; We use spec as an extension for NESS [interface] specification files.
   ;; .spec is also used for rpm-spec-files.
   ;; Since the regexp for the rpm-spec-files *may* change, we'll just
   ;; override the mode with something innocuous, until an ness-spec mode is
   ;; written. Or at least a font locker.
   ;; For now, another existing mode may be more appropriate.
   (cons "\\.spec$" 'text-mode)))

(defvar dp-p4-default-depot-completion-prefix "//"
  "Depot root.")

(defun* dp-nvidia-make-cscope-database-regexps (&optional
                                                ignore-env-p
                                                db-locations
                                                (hierarchical-search-p t))
  "Compute value for `cscope-database-regexps'"
  (let* ((locstr (or db-locations
                     (and (not ignore-env-p)
                          (getenv "DP_NV_SRC_INDEX_DB_LOCS"))
                     (dp-string-join
                      '("ap //arch //sw/dev //sw/mods //sw/tools //hw/class"
;;;                      " //hw/kepler1_gklit3"
                        "//hw/tools"
                        ;; nvlink stuff
                        "fmod nvgpuinclude nvgpuclib"))))
         (locs (split-string locstr))
         (sb-name (dp-current-sandbox-name))
         (ticker "dp-nvidia-make-cscope-database-regexps: ")
         expansion
         result)
    (list
     (prog1
         (delete nil
                 (append
                  (list (dp-me-expand-dest "sb" sb-name))
                  (when hierarchical-search-p
                    '((t)))
                  (when sb-name
                    (let ((bubba (mapcar (function
                                          (lambda (loc)
                                            (dmessage "%s." ticker)
                                            (prog1
                                                (list (dp-me-expand-dest 
                                                       loc sb-name))
                                              (setq ticker
                                                    (dmessage "%s+" 
                                                              ticker)))))
                                         locs)))
                      (delete nil (delete '(nil) bubba))))
                  ))
       (dmessage "dp-nvidia-make-cscope-database-regexps: done.")))))

(setq dp-make-cscope-database-regexps-fun
      'dp-nvidia-make-cscope-database-regexps)

;; Define per-locale???
(defun* dp-set-cscope-database-regexps (&optional ignore-env-p 
                                        db-locations 
                                        (hierarchical-search-p t))
  (interactive "P")
  (setq cscope-database-regexps
        (funcall dp-make-cscope-database-regexps-fun 
                 ignore-env-p db-locations 
                 hierarchical-search-p)))
  
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

(defalias 'dp-tgen-add-debug
  (read-kbd-macro
   (concat "<C-prior> C-s sim.pl SPC RET - gdb SPC C-s - chip SPC "
           "t132 RET _debug C-s libt132_ RET debug_")))

(defalias 'dp-fcnvl-add-config-params
  (read-kbd-macro
   (concat
    "C-s hshub_config0 RET <right> M-a <C-right> M-o SPC - chipargs SPC "
    "-nvlink_configuration0= M-y C-s hshub_config1 RET <right> "
    "M-a <C-right> M-o SPC - chipargs SPC -nvlink_configuration1= M-y")))

(defvar dp-tgen-elf-load-option-olde
  "-chipargs '-elf_load /home/denver/release/sw/components/mts/1.0/cl28625566/debug_arm/denver/bin/mts.elf@0xe0000000:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/drv/mpcore/t132/ObjLinux_MPCoreXC/boot_page_table.axf:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/diag/testgen/dp-rtl-tests/top_peatrans_gpurtl-2013-11-21T08.33.48-0800/cpu_surface_write_read/override.elf@0xe0000000:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/diag/testgen/dp-rtl-tests/top_peatrans_gpurtl-2013-11-21T08.33.48-0800/cpu_surface_write_read/t132/ObjLinux_MPCoreXC/cpu_surface_write_read.Cortex-A8.axf:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/diag/testgen/dp-rtl-tests/top_peatrans_gpurtl-2013-11-21T08.33.48-0800/cpu_surface_write_read/t132/ObjLinux_ARM7TDMIXC/cpu_surface_write_read.ARM7TDMI.axf:' "
  "tip-top-denver.sh 'needed this to make it go.'")

(defvar dp-tgen-elf-load-option 
  "-chipargs '-elf_load /home/denver/release/sw/components/mts/1.0/cl28625566/debug_arm/denver/bin/mts.elf@0xe0000000:@SB@/hw/ap_t132/drv/mpcore/t132/ObjLinux_MPCoreXC/boot_page_table.axf:@PWD@override.elf@0xe0000000:@PWD@t132/ObjLinux_MPCoreXC/cpu_surface_write_read.Cortex-A8.axf:@PWD@t132/ObjLinux_ARM7TDMIXC/cpu_surface_write_read.ARM7TDMI.axf:' "
  "tip-top-denver.sh 'needs this to make it go.'")
;;
(defalias 'dp-tgen-add-elf-load
  (read-kbd-macro
   (concat "<C-prior> C-s idle_ 2*<C-w> RET 3*<right> "
           (replace-in-string dp-tgen-elf-load-option-olde
                              " " " SPC ")
)))

(defun dp-tgen-generate-elf-load-option (&optional s)
  (interactive)
  (setq-ifnil s dp-tgen-elf-load-option)
   (replace-in-string 
    (replace-in-string s
                       "@SB@"
                       (dp-current-sandbox-path))
    "@PWD@"
    default-directory))

(defun dp-tgen-insert-elf-load-option (&optional s)
  (interactive)
  (goto-char (point-min))
  (search-forward "-simtxt 'idle_timeout 150000'\" ")
  (insert (dp-tgen-generate-elf-load-option s)))

;; Nothing in my tgen run dirs need p4.
;; e.g.: /hw/ap_t132/diag/testgen
(defvar dp-p4-ignore-regexp
  (dp-concat-regexps-grouped
   '("/hw/.*/diag/testgen/"
     "/\\.\\(git\\|hg\\)"
     "generated-.*-defs\\.h"
     "\\.log\\.retry"
     "/diag/testgen/.*/[0-9]\\{2\\}/[0-9]\\{2\\}/[0-9]\\{6\\}/"
     "/plex/"))
  "Deactivate p4 for fileses what match this regexp.")

;;(setq dp-read-only-sandbox-regexp-private nil)
;;(setq dp-read-only-sandbox-regexp-private "\\(/sb2\\|/sb4\\)")
(setq dp-read-only-sandbox-regexp-private "\\(/sb4\\)")

;;

(dp-add-force-read-only-regexp
 (dp-concat-regexps-grouped
  ;; Don't want to edit these stupid fvcking copies.
  '("/plex/"
;;    "/fc_nvlink_translator/"            ; Whilst I'm working in fcnvl
    "/fcnvl"            ; Whilst I'm working in real dev dir
    "/g\\(plit*\\|gmlit*\\)"
    "fc_nvlink_translator/.*/"          ; Any subdir.
    "failed-attempt\\(ed\\)?-0")))

(defun dp-raison-d-etre (&optional
                         other-buffer-p
                         sb-name
                         file-name-abbrev)
  "Visit file describing the primary purpose of this sandbox?"
  (interactive "P")
  (setq-ifnil sb-name (dp-current-sandbox-name)
              file-name-abbrev "rde")
  (let ((rde (dp-me-expand-dest file-name-abbrev sb-name)))
    (when rde
      (funcall (if other-buffer-p
                   'find-file-other-window
                 'find-file)
               rde))))
(defalias 'rde 'dp-raison-d-etre)

(provide 'dp-dot-emacs.nvidia.el)
