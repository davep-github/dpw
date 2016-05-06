(require 'vc)

(defun dp-add-amd-c-style ()
  "Set up C/C++ style."
  (interactive)
  (setq dp-default-c-style-name "amd-c-style")
  (c-add-style "amd-c-style" dp-kernel-c-style t))

;;Meh.
(add-hook 'c-mode-common-hook (lambda ()
                                (dp-add-amd-c-style)
                                ;; Some files use this and I can't find it.
                                (defalias 'linux-c-mode 'c-mode)
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

;; Auto updating (of gtags) sucks with multiple databases.
;; Avoid having multiple databases in a single path.
(setq cscope-database-regexps
      '(
        ;; Only search the big dbs if we're in their directory.
        (
         "^/proj/ras_arch/ras/edc/brahma/ec/kgd/linux$"
         ("/proj/ras_arch/ras/edc/brahma/ec/kgd/linux")
         t)

        (
         "^/proj/ras_arch/ras/edc/brahma/ec$"
         ("/proj/ras_arch/ras/edc/brahma/ec")
         t)

        (
         "^/proj/ras_arch/ras/edc/brahma/ec/drm"
         ("/proj/ras_arch/ras/edc/brahma/ec/drm")
         (t)
         t)

        (
         "^/proj/ras_arch/ras/edc/brahma/ec/kgd/"
         ("/proj/ras_arch/ras/edc/brahma/ec/kgd/linux/drivers/gpu/drm")
         t
         ;; These will get stale, but the stuff we'll be looking for will be
         ;; under more up-to-date dbs.
         ("/proj/ras_arch/ras/edc/brahma/ec/kgd/linux")
         t
         ("/proj/ras_arch/ras/edc/brahma/ec")
         )))

(setq auto-mode-alist (cons '("\\.cl$" . c-mode) auto-mode-alist))

