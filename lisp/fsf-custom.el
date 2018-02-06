(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#2d3743" "#ff4242" "#74af68" "#dbdb95" "#34cae2" "#008b8b" "#00ede1" "#e1e1e0"])
 '(beacon-blink-when-focused t)
 '(beacon-mode t)
 '(comint-input-ignoredups t)
 '(comint-move-point-for-output t)
 '(comint-password-prompt-regexp
   "\\(\\([Oo]ld \\|[Bb]ad \\|[Nn]ew \\|^\\)?[Pp]assword\\|pass[ _-]?phrase\\):?\\s-*\\'\\|\\(Enter passphrase for.*: \\)\\|\\(Password for .*\\)\\|\\(Bad passphrase, try again for.*:\\)\\|\\(Enter password.*:\\s-+\\)\\|\\(\\(\\[sudo\\] \\)?[Pp]assword for .*\\(davep\\||dpanariti?\\|dapanarx.*\\).*:? \\)")
 '(comint-scroll-show-maximum-output nil)
 '(custom-enabled-themes (quote (adwaita)))
 '(display-time-mode t)
 '(global-hl-line-mode nil)
 '(icomplete-mode t)
 '(icomplete-separator ",")
 '(ido-mode nil nil (ido))
 '(ido-use-filename-at-point (quote guess))
 '(isearch-allow-scroll t)
 '(isearch-lazy-highlight t)
 '(isearch-resume-in-command-history t)
 '(ispell-lazy-highlight nil)
 '(kill-do-not-save-duplicates t)
 '(kill-ring-max 128)
 '(lazy-highlight-initial-delay 0.1)
 '(lazy-highlight-interval 0)
 '(mouse-yank-at-point t)
 '(org-insert-mode-line-in-empty-file t)
 '(package-selected-packages
   (quote
    (hyperbole diffview dired-du auto-overlays adjust-parens which-key sed-mode notes-mode on-screen bug-hunter beacon python pinentry metar diff-hl gited flylisp ggtags json-mode context-coloring)))
 '(query-replace-lazy-highlight nil)
 '(safe-local-variable-values
   (quote
    ((c-font-lock-extra-types "FILE" "bool" "language" "linebuffer" "fdesc" "node" "regexp")
     (block-comment-end . "")
     (folding-internal-margins)
     (folded-file . t))))
 '(save-abbrevs nil)
 '(save-place-mode t)
 '(scroll-bar-mode (quote right))
 '(show-paren-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(beacon-fallback-background ((t (:background "DodgerBlue3"))))
 '(cursor ((t (:background "blue3"))))
 '(ido-only-match ((t (:foreground "ForestGreen" :weight bold))))
 '(isearch ((t (:background "blue" :foreground "white"))))
 '(lazy-highlight ((t (:background "LightSkyBlue1"))))
 '(mode-line ((t (:background "LightSkyBlue3" :foreground "black" :box (:line-width -1 :style released-button)))))
 '(mode-line-inactive ((t (:inherit mode-line :background "azure1" :foreground "grey20" :box (:line-width -1 :color "grey75") :weight light))))
 '(rectangle-preview ((t (:inherit region))))
 '(region ((t (:background "LightSkyBlue1")))))
