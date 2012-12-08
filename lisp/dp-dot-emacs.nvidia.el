(dmessage "dp-dot-emcas.nvidia.el")

;; add to post-dpmacs hook.
(add-hook 'dp-post-dpmacs-hook (lambda ()
                                 (require 'dp-perforce)))

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

;; For some reason, vc isn't being autoloaded here, but it is @ home.
(vc-load-vc-hooks)  ; This is being added to the Tools->Version Control menu.

(provide 'dp-dot-emacs.nvidia.el)
