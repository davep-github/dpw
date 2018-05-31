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
 '(beacon-color "medium sea green")
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
 '(custom-enabled-themes (quote (dp-challenger-deep)))
 '(custom-safe-themes
   (quote
    ("550002afa3c490fd9d5448b48eb624684af76c6ea8ab6c76a52156d5462f5a2e" "ac4fa5f372e49f8e7a203db00bf32ffb47db68e70b584bad404c2cba3ece2221" "90a8512e60f26d49c05eb500a943306baa2f540027b2b73460c57485f1a984d1" "75718cb7d721574434a4badf80ae1bcb8e5a235f13d7cde47d7044940cf95c66" "d1ca34eb9c9f8eaaa7f35c05a038b06beeadea35b4a1873ad5c7ea815f15a842" "2a908166a5e975844edd94663d365ebf9a45263904ed6e5b418aa8ecbaff4f4e" "6257b1ccc709abe4417745c440ccfdc201c90707bc39ab1f89bda3cd188aa70f" "b8c24d8aaa6104a020b372c08539a867301ec270b72582fdb97c88bafef809a6" "f58cef779390f90ee1bc51f9f1ca4e23d88acd84a327e3405d0d40ddcb03debc" "a8b5a36b9bfc1af3280af5fae073e672e329121d1e95efd6a087b314db1e2a83" "dcb9fd142d390bb289fee1d1bb49cb67ab7422cd46baddf11f5c9b7ff756f64c" "47744f6c8133824bdd104acc4280dbed4b34b85faa05ac2600f716b0226fb3f6" "64922fcf67155cb9138f9cd41730bc96dcace4076ea157a13764ea809712fade" "128ece6b395c75abec230985113714d7ec251419a56d3850d42e4e77ed57f919" "58ff81f7a8e74f1633c1ce4fb135112dc8736e5b240c9458d2fe43ce930bd76d" "9eb84b9c9c03c789e7d10c02a427d828de4a3a0075bdee039898fa425f43fcad" "28dcfcfad6f70f319aa7cf3a92afb78cc4ba3f614c063fee9cd095b2efb3e64e" "de11dfdc2b94c89baaca111b470bc2ef55b8c5f31627e2e7c682d0309ab611e0" "48d5e503e37a5587f3416e8f3de3015b2c0fb971c05e6f4fb3be7bb98ffa0f41" "c50f28265bdd44ce373f1a06367dfec66bc2adf6ee95d6513a7a07cbb3039c38" "935b1a2de5eb9c72ad904ecc7a607a4372d6808a9c1df73e39f578f76841aca9" "8a7ddbef5ae6addeb464e486c4e5c075caeb3c3bfd6d2eba4e59a556fcf11f14" "c76078b5340febca07edc1d54e54d01754b5e602f5d14332eb81244a7151bb5f" "2fb6c366aad4f6d78f75364a74be56735e8ddb2d0a60dc2c2220c89f17dd832e" "b04153b12fbb67935f6898f38eb985ec62511fd1df6e2262069efa8565874195" default)))
 '(custom-theme-directory "~/.emacs.d/dp-themes.d/")
 '(dired-auto-revert-buffer (quote dired-directory-changed-p))
 '(dired-backup-overwrite t)
 '(display-time-mode t)
 '(dp-trailing-whitespace-use-trailing-ws-font-p t)
 '(echo-keystrokes 0.1)
 '(global-eldoc-mode nil)
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
 '(magit-auto-revert-mode nil)
 '(magit-commit-arguments (quote ("--signoff")))
 '(magit-pull-arguments (quote ("--rebase")))
 '(magit-rebase-arguments (quote ("--interactive")))
 '(message-send-mail-function (quote message-send-mail-with-sendmail))
 '(minibuffer-prompt-properties
   (quote
    (read-only t cursor-intangible t face minibuffer-prompt)))
 '(mouse-yank-at-point t)
 '(mu4e-attachment-dir "/home/dpanarit/Downloads")
 '(next-error-highlight t)
 '(next-error-highlight-no-select t)
 '(next-error-recenter (quote (4)))
 '(org-insert-mode-line-in-empty-file t)
 '(package-selected-packages
   (quote
    (fuzzy full-ack ack-menu ag ibuffer-tramp challenger-deep-theme abyss-theme nova-theme magit ecb thingopt escreen mew nhexl-mode mu-cite mu4e-maildirs-extension mu4e-jump-to-list mu4e-alert flycheck-cstyle flycheck-checkbashisms flymake-cppcheck flycheck-rust flycheck-pos-tip flycheck-cython flymake-python-pyflakes flycheck hyperbole diffview dired-du auto-overlays adjust-parens which-key sed-mode notes-mode on-screen bug-hunter beacon python pinentry metar diff-hl gited flylisp ggtags json-mode context-coloring)))
 '(query-replace-lazy-highlight nil)
 '(safe-local-variable-values
   (quote
    ((c-font-lock-extra-types "FILE" "bool" "language" "linebuffer" "fdesc" "node" "regexp")
     (block-comment-end . "")
     (folding-internal-margins)
     (folded-file . t))))
 '(save-abbrevs nil)
 '(save-place-mode nil)
 '(scroll-bar-mode (quote right))
 '(search-whitespace-regexp nil)
 '(send-mail-function (quote smtpmail-send-it))
 '(sendmail-program "/home/dpanarit/bin/dp-msmtp")
 '(shell-cd-regexp "cd|chdir|g")
 '(shell-input-autoexpand t)
 '(shell-pushd-regexp "pushd|g")
 '(show-paren-mode t)
 '(show-trailing-whitespace t)
 '(smtpmail-debug-info t)
 '(smtpmail-debug-verb t)
 '(smtpmail-local-domain nil)
 '(smtpmail-queue-index-file "sendmail-q-index")
 '(smtpmail-smtp-service 25)
 '(smtpmail-smtp-user nil)
 '(smtpmail-stream-type nil)
 '(tags-revert-without-query t)
 '(timeclock-mode-line-display nil)
 '(tool-bar-mode nil)
 '(wdired-allow-to-change-permissions t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(beacon-fallback-background ((t (:background "DodgerBlue3"))))
 '(cursor ((t nil)))
 '(dp-trailing-whitespace-face ((t (:background "light coral" :foreground "black" :weight normal))))
 '(isearch ((t (:background "medium spring green" :foreground "#100e23" :weight bold))))
 '(lazy-highlight ((t (:background "#65b2ff" :foreground "black"))))
 '(rectangle-preview ((t (:inherit region))))
 '(region ((t (:background "royal blue"))))
 '(trailing-whitespace ((t nil))))
