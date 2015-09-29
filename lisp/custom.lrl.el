(message "custom[.lrl].el...")
(custom-set-variables
 '(auto-raise-frame nil)
 '(browse-url-gnome-moz-arguments '("--raise")
)
 '(browse-url-kde-program "xkonq")
 '(browse-url-netscape-arguments '("-w")
)
 '(browse-url-netscape-program "xns")
 '(browse-url-xterm-program "xx")
 '(buffers-menu-sort-function 'sort-buffers-menu-alphabetically)
 '(cal-tex-diary t)
 '(cvs-allow-dir-commit t)
 '(dabbrev-ignored-buffer-regexps '("\\(TAGS\\|tags\\|ETAGS\\|etags\\|GTAGS\\|GRTAGS\\|GPATH\\)\\(<[0-9]+>\\)?")
)
 '(default-toolbar-position 'left)
 '(dired-find-subdir t)
 '(dired-no-confirm '(revert-subdirs)
)
 '(dired-omit-files nil)
 '(ediff-diff-options "")
 '(ediff-make-buffers-readonly-at-startup t)
 '(ediff-merge-split-window-function 'split-window-vertically)
 '(efs-auto-save 1 t)
 '(efs-auto-save-remotely nil t)
 '(efs-ftp-program-args '("-e" "-i" "-n" "-g" "-v" "-p")
)
 '(efs-pty-check-retry-time 60)
 '(efs-send-progress-off t)
 '(epg-debug t)
 '(ffap-machine-p-known 'reject)
 '(fill-column 77)
 '(filladapt-token-conversion-table '((citation-> . exact)
  (supercite-citation . exact)
  (lisp-comment . exact)
  (sh-comment . exact)
  (postscript-comment . exact)
  (c++-comment . exact)
  (texinfo-comment . exact)
  (bullet . spaces)
  (space . exact)
  (end-of-line . exact)
  (dpj-action-item . spaces)
  (dpj-action-item-resolution . spaces))
)
 '(flyspell-duplicate-distance 0)
 '(flyspell-issue-message-flag nil)
 '(flyspell-issue-welcome-flag nil)
 '(flyspell-use-meta-tab nil)
 '(gtags-auto-update t)
 '(gtags-ignore-case nil)
 '(gtags-select-buffer-single t)
 '(help-selects-help-window nil)
 '(highline-selected-window nil)
 '(igrep-case-fold-search t)
 '(indent-tabs-mode nil)
 '(interprogram-paste-function 'get-clipboard)
 '(kill-ring-max 128)
 '(mew-conf-path "~/MH" t)
 '(mew-mail-path "~/MH" t)
 '(mew-prog-pgp "gpg")
 '(modeline-scrolling-method t)
 '(mouse-yank-at-point t)
 '(outline-glyphs-on-left t)
 '(outline-mac-style t)
 '(p4-file-refresh-timer-time 0)
 '(paren-display-message 'never)
 '(paren-message-offscreen t)
 '(paren-message-show-linenumber 'absolute)
 '(parens-require-spaces nil)
 '(progress-feedback-use-echo-area t)
 '(ps-print-color-p nil t)
 '(py-align-multiline-strings-p nil)
 '(sc-citation-delimiter-regexp "[>|:]+")
 '(sc-citation-leader "   ")
 '(sc-mail-warn-if-non-rfc822-p t)
 '(sh-indent-for-continuation '/)
 '(shell-cd-regexp "cd\\|kd")
 '(shell-input-autoexpand 'input)
 '(speedbar-track-mouse-flag nil)
 '(speedbar-use-images nil)
 '(speedbar-use-tool-tips-flag t)
 '(tag-mark-stack-max 128)
 '(tags-always-exact t)
 '(tags-auto-read-changed-tag-files t)
 '(tags-build-completion-table 'ask)
 '(tags-exuberant-ctags-optimization-p t)
 '(toolbar-info-use-separate-frame nil)
 '(toolbar-mail-commands-alist (cons
 '(mew . mew)
 toolbar-mail-commands-alist)
)
 '(toolbar-mail-reader 'mew)
 '(toolbar-visible-p nil)
 '(tramp-debug-buffer t)
 '(tramp-default-method "scp")
 '(vc-dired-terse-display nil)
 '(vc-handle-cvs nil)
 '(vm-crash-box "~/email/vm.el/crash-boxes/INBOX.CRASH")
 '(vm-folder-directory "~/Email/vm.el/folders")
 '(vm-grep-program "egrep")
 '(vm-highlighted-header-face 'blue-foreground)
 '(vm-highlighted-header-regexp "From:\\\\|Subject:")
 '(vm-imap-expunge-after-retrieving nil)
 '(vm-imap-folder-cache-directory "~/eMail/vm.el/IMAP-cache")
 '(vm-imap-server-list '("imap-ssl:imap.vanu.com:993:inbox:login:davep:pwds-suck")
)
 '(vm-index-file-suffix ".vm-folder-index-file")
 '(vm-init-file "~/lisp/dp-dot-vm.el")
 '(vm-keep-crash-boxes "~/eMail/vm.el/crash-boxes")
 '(vm-preferences-file "~/lisp/dp-dot-vm.preferences")
 '(vm-primary-inbox "imap-ssl:imap.vanu.com:993:INBOX:login:davep:pwds-suck")
 '(w3m-use-toolbar nil)
 '(whitespace-check-spacetab-whitespace nil)
 '(whitespace-rescan-timer-time nil)
 '(whitespace-silent t))
(custom-set-faces
 '(bold ((t (:bold t))) t)
 '(buffers-tab ((t (:foreground "darkblue" :background "lightsteelblue" :bold t))) t)
 '(cperl-nonoverridable-face ((((class color) (background light)) (:foreground "darkgreen" :bold t))))
 '(cvs-handled-face ((((class color) (background light)) (:foreground "thistle4"))))
 '(cvs-marked-face ((((class color) (background light)) (:foreground "darkgreen" :bold t))))
 '(cvs-need-action-face ((((class color) (background light)) (:foreground "orangered3" :bold t))))
 '(cvs-unknown-face ((((class color) (background light)) (:foreground "darkorchid"))))
 '(dired-face-directory ((((type x pm mswindows tty) (class color)) (:foreground "blue" :bold t))))
 '(dired-face-executable ((((class color) (background light)) (:foreground "green4"))))
 '(dired-face-symlink ((((class color) (background light)) (:foreground "darkviolet"))))
 '(dp-default-endicator-face ((((class color) (background light)) (:foreground "lightblue" :background "lavender"))))
 '(dp-highlight-point-after-face ((((class color) (background light)) (:background "plum2"))))
 '(dp-highlight-point-before-face ((((class color) (background light)) (:background "plum2"))))
 '(dp-journal-medium-question-face ((((class color) (background light)) (:bold t))))
 '(dp-python-indent-face-2 ((((class color) (background light)) (:background "lavenderblush2"))))
 '(dp-python-indent-face-4 ((((class color) (background light)) (:background "azure2"))))
 '(dp-python-indent-face-5 ((((class color) (background light)) (:background "paleturquoise"))))
 '(dp-sel2:squish-newline-face ((((class color) (background light)) (:background "lightblue3"))))
 '(dp-sudo-edit-bg-face ((((class color) (background light)) (:background "thistle2"))))
 '(dp-trailing-whitespace-face ((((class color) (background light)) (:background "aquamarine" :bold nil))))
 '(dp-wp-face ((((class color) (background light)) (:background "lightsalmon2"))))
 '(flyspell-duplicate-face ((((class color)) (:foreground "red" :bold nil :underline t))))
 '(font-lock-doc-string-face ((((class color) (background light)) (:foreground "seagreen" :bold t))))
 '(font-lock-string-face ((((class color) (background light)) (:foreground "green4" :bold t))))
 '(font-lock-type-face ((((class color) (background light)) (:foreground "maroon4" :bold t))))
 '(highline-face ((t (:background "thistle3"))))
 '(holiday-face ((t (:background "orchid"))))
 '(info-node ((t (:foreground "blue" :bold t :italic t))))
 '(info-xref ((t (:foreground "blue" :bold t :underline t))))
 '(isearch ((t (:foreground "white" :background "blue" :bold t :underline t))) t)
 '(isearch-secondary ((t (:foreground "black" :background "lightskyblue1"))) t)
 '(mew-face-body-cite1 ((((class color) (type tty)) (:foreground "green")) (((class color) (background light)) (:foreground "ForestGreen")) (((class color) (background dark)) (:foreground "LimeGreen")) (t nil)) t)
 '(mew-face-body-cite2 ((((class color) (type tty)) (:foreground "cyan")) (((class color) (background light)) (:foreground "MediumBlue")) (((class color) (background dark)) (:foreground "SkyBlue")) (t nil)) t)
 '(mew-face-body-cite3 ((((class color) (type tty)) (:foreground "magenta")) (((class color) (background light)) (:foreground "DarkViolet")) (((class color) (background dark)) (:foreground "violet")) (t nil)) t)
 '(mew-face-body-cite4 ((((class color) (type tty)) (:foreground "yellow")) (((class color) (background light)) (:foreground "DarkOrange4")) (((class color) (background dark)) (:foreground "Gold")) (t nil)) t)
 '(mew-face-body-cite5 ((((class color) (type tty)) (:foreground "red")) (((class color) (background light)) (:foreground "Firebrick")) (((class color) (background dark)) (:foreground "OrangeRed")) (t nil)) t)
 '(mew-face-body-comment ((((class color) (type tty)) (:foreground "blue")) (((class color) (background light)) (:foreground "gray50")) (((class color) (background dark)) (:foreground "gray50")) (t nil)) t)
 '(mew-face-body-url ((((class color) (type tty)) (:foreground "red" :bold t)) (((class color) (background light)) (:foreground "Firebrick" :bold t)) (((class color) (background dark)) (:foreground "OrangeRed" :bold t)) (t (:bold t))) t)
 '(mew-face-eof-message ((((class color) (type tty)) (:foreground "green" :bold t)) (((class color) (background light)) (:foreground "ForestGreen" :bold t)) (((class color) (background dark)) (:foreground "LimeGreen" :bold t)) (t (:bold t))) t)
 '(mew-face-eof-part ((((class color) (type tty)) (:foreground "yellow" :bold t)) (((class color) (background light)) (:foreground "DarkOrange4" :bold t)) (((class color) (background dark)) (:foreground "Gold" :bold t)) (t (:bold t))) t)
 '(mew-face-header-date ((((class color) (type tty)) (:foreground "green" :bold t)) (((class color) (background light)) (:foreground "ForestGreen" :bold t)) (((class color) (background dark)) (:foreground "LimeGreen" :bold t)) (t (:bold t))) t)
 '(mew-face-header-from ((((class color) (type tty)) (:foreground "yellow" :bold t)) (((class color) (background light)) (:foreground "DarkOrange4" :bold t)) (((class color) (background dark)) (:foreground "Gold" :bold t)) (t (:bold t))) t)
 '(mew-face-header-important ((((class color) (type tty)) (:foreground "cyan" :bold t)) (((class color) (background light)) (:foreground "MediumBlue" :bold t)) (((class color) (background dark)) (:foreground "SkyBlue" :bold t)) (t (:bold t))) t)
 '(mew-face-header-key ((((class color) (type tty)) (:foreground "green" :bold t)) (((class color) (background light)) (:foreground "ForestGreen" :bold t)) (((class color) (background dark)) (:foreground "LimeGreen" :bold t)) (t (:bold t))) t)
 '(mew-face-header-marginal ((((class color) (type tty)) (:bold t)) (((class color) (background light)) (:foreground "gray50" :bold t)) (((class color) (background dark)) (:foreground "gray50" :bold t)) (t (:bold t))) t)
 '(mew-face-header-private ((((class color) (type tty)) (:bold t)) (((class color) (background light)) (:bold t)) (((class color) (background dark)) (:bold t)) (t (:bold t))) t)
 '(mew-face-header-subject ((((class color) (type tty)) (:foreground "red" :bold t)) (((class color) (background light)) (:foreground "Firebrick" :bold t)) (((class color) (background dark)) (:foreground "OrangeRed" :bold t)) (t (:bold t))) t)
 '(mew-face-header-to ((((class color) (type tty)) (:foreground "magenta" :bold t)) (((class color) (background light)) (:foreground "DarkViolet" :bold t)) (((class color) (background dark)) (:foreground "violet" :bold t)) (t (:bold t))) t)
 '(mew-face-header-xmew ((((class color) (type tty)) (:foreground "yellow" :bold t)) (((class color) (background light)) (:foreground "chocolate" :bold t)) (((class color) (background dark)) (:foreground "chocolate" :bold t)) (t (:bold t))) t)
 '(mew-face-header-xmew-bad ((((class color) (type tty)) (:foreground "red" :bold t)) (((class color) (background light)) (:foreground "red" :bold t)) (((class color) (background dark)) (:foreground "red" :bold t)) (t (:bold t))) t)
 '(mew-face-mark-delete ((((class color) (type tty)) (:foreground "red")) (((class color) (background light)) (:foreground "Firebrick")) (((class color) (background dark)) (:foreground "OrangeRed")) (t (:bold t))) t)
 '(mew-face-mark-multi ((((class color) (type tty)) (:foreground "magenta")) (((class color) (background light)) (:foreground "DarkViolet")) (((class color) (background dark)) (:foreground "violet")) (t (:bold t))) t)
 '(mew-face-mark-refile ((((class color) (type tty)) (:foreground "green")) (((class color) (background light)) (:foreground "ForestGreen")) (((class color) (background dark)) (:foreground "LimeGreen")) (t (:bold t))) t)
 '(mew-face-mark-review ((((class color) (type tty)) (:foreground "cyan")) (((class color) (background light)) (:foreground "MediumBlue")) (((class color) (background dark)) (:foreground "SkyBlue")) (t (:bold t))) t)
 '(mew-face-mark-unlink ((((class color) (type tty)) (:foreground "yellow")) (((class color) (background light)) (:foreground "DarkOrange4")) (((class color) (background dark)) (:foreground "Gold")) (t (:bold t))) t)
 '(semantic-highlight-func-current-tag-face ((((class color) (background light)) (:underline t :inverse-video t))))
 '(shell-output-2-face ((((class color) (background light)) (:foreground "blue3"))) t)
 '(shell-output-face ((((class color) (background light)) (:foreground "blue4"))) t)
 '(shell-prompt-face ((((class color) (background light)) (:foreground "black" :bold t))) t)
 '(shell-uninteresting-face ((((class color) (background light)) (:foreground "thistle4"))) t)
 '(w3m-form-face ((((class color) (background light)) (:foreground "cyan" :background "darkblue" :underline t))))
 '(whitespace-tab-face ((t (:background "plum4" :underline t))))
 '(whitespace-visual-blank-face ((t nil)))
 '(zmacs-region ((t (:background "lightsteelblue1" :bold t))) t))

(setq minibuffer-max-depth nil)
(put 'narrow-to-region 'disabled nil)

(message "custom.el...finished")
