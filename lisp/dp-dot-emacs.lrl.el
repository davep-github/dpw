;; Never remove passwords from cache.
(setq password-cache-expiry nil)

;; For some reason, vc isn't being autoloaded here, but it is @ home.
;; Home must be the odd one, since this is the 3rd place (sigh) I've had to
;; do this.
(vc-load-vc-hooks)  ; This is being added to the Tools->Version Control menu.


(dp-add-list-to-list 
 'dp-auto-mode-alist-additions
 ;; (regexp . func-to-call-when-loaded)
 (list
  (cons "/etc/hosts"
        'dp-make-no-fill-stupidly-sh-mode)))


(defconst lrl-c-style
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
  "LRL C Programming Style")

(defun dp-lrl-c-style ()
  "Set up LRL C/C++ style."
  (interactive)
  (c-add-style "lrl-c-style" lrl-c-style t))

(unless (bound-and-true-p dp-default-c-style-name)
  (defvar dp-default-c-style-name "lrl-c-style"))

(defun lrl-style ()
  "Set up home (Lrl.net) C style."
  (interactive)
  (c-set-style "lrl-c-style"))

(defvar dp-default-c-style-name "lrl-c-style")

;;trying a new one (setq cscope-database-regexps
;;trying a new one       '(
;;trying a new one         ("^/home/davep/work/dpu/local/build/pcap-stuff/"
;;trying a new one          (t)
;;trying a new one          )
;;trying a new one         ("^/home/davep/work/dpu/snort/"
;;trying a new one          ("/home/davep/work/dpu/")
;;trying a new one          (t)
;;trying a new one          )
;;trying a new one         ("^/"
;;trying a new one          ( "/home/davep/work/dpu/hw/dpu/testdriver/" )
;;trying a new one          ( "/home/davep/work/dpu/")
;;trying a new one          (t)
;;trying a new one          ("/home/davep/work/dpu/external/kernel/linux-3.10.0-229.1.2.el7/")
;;trying a new one          )))

(setq cscope-database-regexps
      '(
        ( "^/home/davep/work/dpu"
          ("/home/davep/work/dpu/hw/dpu/testdriver")
          t
          ("/home/davep/work/dpu/snort")
          t
          ("/home/davep/work/dpu/local/build/pcap-stuff")
          t
;; Add back when/if kernel source becomes useful again.    
;;          ("/home/davep/work/dpu/external/kernel/linux-3.10.0-229.1.2.el7/")
          )))



(dp-add-force-read-only-regexp
 (dp-concat-regexps-grouped
  ;; Don't want to edit these stupid fvcking copies.
  '(
    ;; sometimes we do edit these legitimately, such as when integration is
    ;; happening.
    ;; "^/home/davep/work/dpu/snort/src/detection-plugins/dpu.[ch]$"
    "^/home/davep/work/dpu/external/build/snort-2.9.7.3"
    "^/home/davep/work/dpu/external/kernel/linux-3.10.0-229.1.2.el7"
    "^/home/davep/tmp/testdriver"
    ;; I've renamed this file and don't want to accidentally edit it.
    "^/home/davep/work/dpu/hw/dpu/testdriver/dpu-context.[ch]"
    ))
 t                                      ; Should the list be cleared first?
)

;; (dp-add-corresponding-file-pair "dpu-mmap.c" "altera_dma.h")

