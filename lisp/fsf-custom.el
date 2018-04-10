(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#2d3743" "#ff4242" "#74af68" "#dbdb95" "#34cae2" "#008b8b" "#00ede1" "#e1e1e0"])
 '(apropos-do-all t)
 '(auth-sources
   (quote
    ("secrets:Login" "~/.authinfo" "~/.authinfo.gpg" "~/.netrc")))
 '(beacon-blink-when-focused t)
 '(beacon-mode t)
 '(comint-buffer-maximum-size 8192)
 '(comint-input-autoexpand t)
 '(comint-input-ignoredups t)
 '(comint-input-ring-size 5120)
 '(comint-mode-hook (quote (dp-comint-mode-hook)))
 '(comint-move-point-for-output nil)
 '(comint-password-prompt-regexp
   "\\(\\([Oo]ld \\|[Bb]ad \\|[Nn]ew \\|^\\)?[Pp]assword\\|pass[ _-]?phrase\\):?\\s-*\\'\\|\\(Enter passphrase for.*: \\)\\|\\(Password for .*\\)\\|\\(Bad passphrase, try again for.*:\\)\\|\\(Enter password.*:\\s-+\\)\\|\\(\\(\\[sudo\\] \\)?[Pp]assword for .*\\(davep\\||d?panariti?\\|dapanarx.*\\).*:? \\)")
 '(comint-scroll-show-maximum-output nil)
 '(comint-use-prompt-regexp t)
 '(comment-style (quote extra-line))
 '(custom-enabled-themes (quote (bubba)))
 '(custom-safe-themes
   (quote
    ("64922fcf67155cb9138f9cd41730bc96dcace4076ea157a13764ea809712fade" "128ece6b395c75abec230985113714d7ec251419a56d3850d42e4e77ed57f919" "58ff81f7a8e74f1633c1ce4fb135112dc8736e5b240c9458d2fe43ce930bd76d" "9eb84b9c9c03c789e7d10c02a427d828de4a3a0075bdee039898fa425f43fcad" "28dcfcfad6f70f319aa7cf3a92afb78cc4ba3f614c063fee9cd095b2efb3e64e" "de11dfdc2b94c89baaca111b470bc2ef55b8c5f31627e2e7c682d0309ab611e0" "48d5e503e37a5587f3416e8f3de3015b2c0fb971c05e6f4fb3be7bb98ffa0f41" "c50f28265bdd44ce373f1a06367dfec66bc2adf6ee95d6513a7a07cbb3039c38" "935b1a2de5eb9c72ad904ecc7a607a4372d6808a9c1df73e39f578f76841aca9" "8a7ddbef5ae6addeb464e486c4e5c075caeb3c3bfd6d2eba4e59a556fcf11f14" "c76078b5340febca07edc1d54e54d01754b5e602f5d14332eb81244a7151bb5f" "2fb6c366aad4f6d78f75364a74be56735e8ddb2d0a60dc2c2220c89f17dd832e" "b04153b12fbb67935f6898f38eb985ec62511fd1df6e2262069efa8565874195" default)))
 '(display-time-mode t)
 '(dp-trailing-whitespace-use-trailing-ws-font-p t)
 '(echo-keystrokes 0.1)
 '(global-hl-line-mode nil)
 '(gmm-tool-bar-style (quote gnome))
 '(ibuffer-use-other-window nil)
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
 '(mail-host-address "amd.com")
 '(message-send-mail-function (quote message-send-mail-with-sendmail))
 '(minibuffer-prompt-properties
   (quote
    (read-only t cursor-intangible t face minibuffer-prompt)))
 '(mouse-yank-at-point t)
 '(mu4e-get-mail-command "mbsync.amd")
 '(org-agenda-files (quote ("/home/dpanarit/org/amd.org")))
 '(org-insert-mode-line-in-empty-file t)
 '(package-selected-packages
   (quote
    (ecb thingopt escreen mew nhexl-mode mu-cite mu4e-maildirs-extension mu4e-jump-to-list mu4e-alert flycheck-cstyle flycheck-checkbashisms flymake-cppcheck flycheck-rust flycheck-pos-tip flycheck-cython flymake-python-pyflakes flycheck hyperbole diffview dired-du auto-overlays adjust-parens which-key sed-mode notes-mode on-screen bug-hunter beacon python pinentry metar diff-hl gited flylisp ggtags json-mode context-coloring)))
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
 '(send-mail-function (quote smtpmail-send-it))
 '(sendmail-program "/home/dpanarit/bin/dp-msmtp")
 '(shell-cd-regexp "cd|chdir|g")
 '(shell-input-autoexpand t)
 '(shell-pushd-regexp "pushd|g")
 '(show-paren-mode t)
 '(show-trailing-whitespace nil)
 '(smtpmail-debug-info t)
 '(smtpmail-debug-verb t)
 '(smtpmail-local-domain nil)
 '(smtpmail-queue-index-file "sendmail-q-index")
 '(smtpmail-sendto-domain "amd.com")
 '(smtpmail-smtp-server "smtp.office365.com")
 '(smtpmail-smtp-service 25)
 '(smtpmail-smtp-user nil)
 '(smtpmail-stream-type nil)
 '(timeclock-mode-line-display nil)
 '(tool-bar-mode nil)
 '(user-mail-address "david.panariti@amd.com")
 '(wdired-allow-to-change-permissions t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(beacon-fallback-background ((t (:background "DodgerBlue3"))))
 '(cursor ((t (:background "blue3"))))
 '(dp-trailing-whitespace-face ((t (:background "light coral" :weight normal))))
 '(ido-only-match ((t (:foreground "ForestGreen" :weight bold))))
 '(isearch ((t (:background "blue" :foreground "white"))))
 '(lazy-highlight ((t (:background "LightSkyBlue1"))))
 '(minibuffer-prompt ((t (:foreground "midnight blue" :weight bold))))
 '(mode-line ((t (:background "LightSkyBlue3" :foreground "black" :box (:line-width -1 :style released-button)))))
 '(mode-line-inactive ((t (:inherit mode-line :background "azure1" :foreground "grey20" :box (:line-width -1 :color "grey75") :weight light))))
 '(rectangle-preview ((t (:inherit region))))
 '(region ((t (:background "LightSkyBlue1")))))
