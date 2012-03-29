(setq visible-bell nil)
;; For some reason, putty is getting/generating and passing on garbage
;; input. For XEmacs in a VNC session tunneled to by putty, the result is a
;; spurious f15. So, to make the bell STFU, I'll grab it and do nada.
(global-set-key [f15] (kb-lambda ()))
;; The keys can come at any time, say between the time I press Alt and ?w.
;; so...

(defun dp-putty-f15-bullshit ()
  (interactive)
  ;;(dmessage "?saved the day?")          ; Yes, quite often
  ;; Prevent it fucking up a selection.
  (dp-set-zmacs-region-stays t))
;; Prevent it fucking up an isearch
(put 'dp-putty-f15-bullshit 'isearch-command t)

(global-set-key [f15] 'dp-putty-f15-bullshit)
(global-set-key [(meta f15)] 'dp-putty-f15-bullshit)
(global-set-key [(control f15)] 'dp-putty-f15-bullshit)
(global-set-key [(control meta f15)] 'dp-putty-f15-bullshit)
(global-set-key [(shift f15)] 'dp-putty-f15-bullshit)
(global-set-key [(shift meta f15)] 'dp-putty-f15-bullshit)
(global-set-key [(shift control f15)] 'dp-putty-f15-bullshit)
(global-set-key [(shift control meta f15)] 'dp-putty-f15-bullshit)

(defconst intel-c-style
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
				      (access-label      . -)
                                      (inclass           . ++)
				      (case-label        . +)))
    (c-hanging-semi&comma-criteria dp-c-semi&comma-nada)
    (c-echo-syntactic-information-p . nil)
    (c-indent-comments-syntactically-p . t)
    (c-hanging-colons-alist         . ((member-init-intro . (before))))
    )
  "Intel C/C++ Programming Style")
(c-add-style "intel-c-style" intel-c-style)
(defvar dp-default-c-style-name "intel-c-style")
(defvar dp-default-c-style intel-c-style)

(defun dp-intel-c-style ()
  "Set up C/C++ style."
  (interactive)
  (c-add-style "intel-c-style" intel-c-style t))

;; For some reason, vc isn't being autoloaded here, but it is @ home.
(vc-load-vc-hooks)  ; This is being added to the Tools->Version Control menu.

;; May want this in a project specific .el
(defalias 'dp-poc-layout1
  (read-kbd-macro 
   (concat "M-x sbd RET C-o"          ; One window, no shell buffers showing.
           " M-x 2x1 RET C-2 C-z <C-next> <M-down> C-1 C-z" " <C-next>"
           " <M-down> C-0 C-z <C-next>")))

(defalias 'dp-poc-layout2
  (read-kbd-macro 
   (concat "M-x 2x2 RET C-2 C-z <C-next> <M-down> C-1 C-z" " <C-next>"
           " <M-down> C-3 C-z <C-next> <M-down> C-0 C-z <C-next>")))

(defalias 'dp-poc-layout
  (read-kbd-macro 
   (concat "C-0 C-z M-- C-1 C-z M-- C-2 C-z M-- M-x 2+1 RET C-2 C-z"
           " <M-down> C-1 C-z <M-down> C-0 C-z")))

(defvar dp-poc-layout-format-string
  (concat "C-0 C-z M-- C-1 C-z M-- C-2 C-z M-- M-x %s RET C-2 C-z"
          " <M-%s> C-1 C-z <M-%s> C-0 C-z")
"Common layout w/ %s for specific 3x window config.")

(defalias 'dp-poc-layout-2+1
  (read-kbd-macro 
   (format dp-poc-layout-format-string "2+1" "down" "down")))

;; *(&!^@))_!!-ing bs. The window order is different.
(defalias 'dp-poc-layout-2/1
  (read-kbd-macro 
   (format dp-poc-layout-format-string "2/1" "up" "up")))
  

;; I've been saving this window config in register ?k
;; Hence C-jk, hence jk.
;; 2 + 1:
;; shell 2(con) |
;; -------------+ shell 0 (SA)
;; shell 1 (CA) |
;;
(defalias 'jk+ 'dp-poc-layout-2+1)
(defalias 'jk| 'dp-poc-layout-2+1)

(defalias 'jk/ 'dp-poc-layout-2/1)
(defalias 'jk- 'dp-poc-layout-2/1)

(defalias 'jk 'dp-poc-layout-2/1)

;; For 2x SAs
;; 2 + 2:
;; shell 2 (con) | shell 3 (SA2)
;; --------------+--------------
;; shell 1 (CA)  | shell 0 (SA1)
;;
(defalias 'jk2 'dp-poc-layout2)

;; Make this environment/project aware.
(defun dp-index-code()
  (interactive)
  (shell-command 
   "cd /home/dapanarx/work/ftci/poc && index-code -I client pyagents&" nil))
(dp-safe-alias 'ic 'dp-index-code)

(provide 'dp-dot-emacs.intel.el)
