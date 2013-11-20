;; $Id$
;;
;; Permabit p4.el configuration and extensions
;; Initial code kindly donated by Alex Lawson.
;; XXX @todo Needs cleanup. Way too much was done too quickly and on the sly.
;;

(require 'p4)
(defvar p4-make-backup-files t
  "Should emacs make backup files when editing files under p4 control")

;;(defvar dp-font-lock-depot-prefix-regexp "\\(?:hw\\|sw\\|arch\\|dev\\)")
;; Don't want to have to add every tree root; unless it turns out we have to.
(defvar dp-font-lock-depot-prefix-regexp "\\(?:[^/]+\\)")

;; Pattern used to highlite P4 ChangeSets
;; Some of these faces are defined in add-log.el.
(defvar p4-changeset-font-lock-keywords
  `(;; Comments
    ("^#.*"
     (0 'font-lock-comment-face))
    ;; Change Specication Details
    ("^\\([A-Za-z]+\\):[ \t]*\\(.*\\)"
     (1 'font-lock-keyword-face)
     (2 'font-lock-variable-name-face))
    ;; User File Descriptions
    ("\\(...//.*\\)"
     (1 'dp-journal-medium-question-face))
    ;; Files in ChangeSet
    ("\\(//eng.*\\)[ \t]*#"
     (1 'font-lock-string-face))
    ;; Pair Line
    ("\\(Pair\\):[ \t]*\\(.*\\)"
     (1 'font-lock-keyword-face)
     (2 'font-lock-variable-name-face))
    ,dp-font-lock-line-too-long-element
    ;; ,dp-trailing-whitespace-font-lock-element
    ) 
  "Regexp used to colorize p4-mode changesets.
This mode uses tabs, so the line too long regexp fails.")

; Pattern used to highlite P4 Clients
(defvar p4-client-font-lock-keywords
  `(;; Comments
    ("^#.*"
     (0 'font-lock-comment-face))
    ;; Client Specification Details
    ("^\\([A-Za-z]+\\):[ \t]*\\(.*\\)"
     (1 'font-lock-keyword-face)
     (2 'font-lock-variable-name-face))
    ;; Files in ChangeSet
    (
     ,(format "\\(-?\\)\\(//%s/.*\\)[ \t]+\\(//.*\\)" 
              dp-font-lock-depot-prefix-regexp)
     (1 'font-lock-reference-face)
     (2 'font-lock-preprocessor-face)
     (3 'font-lock-string-face))
    ) "Regexp used to colorize p4-mode clients")

; Configure p4 for xxdiff
(defun p4-use-xxdiff ()
  "Configure p4 to use xxdiff."
  (interactive)
  (setenv "P4DIFF" "xxdiff")
  (setq p4-default-diff-options ""))

; Utility method to find all pending changes
(defun p4-user-pending-changes ()
  "Find all pending changes by the current user"
  (interactive)
  (p4-file-change-log "changes" (list "-s" "pending" "-u"
				      (user-login-name))))
; p4-mode-hook to fix common frustrations
(add-hook 'p4-mode-hook
          (function 
           (lambda ()
             (setq
              ;; Configure backup files
              make-backup-files p4-make-backup-files
              
              ;; Our depot root
              p4-default-depot-completion-prefix 
              dp-p4-default-depot-completion-prefix 
              
              ;; Always follow symlinks to perforce files
              p4-follow-symlinks t
              )
             ;; Fix horrible default diff colors
             ;;(set-face-foreground 'p4-diff-del-face "red")
             ;;(set-face-foreground 'p4-diff-ins-face "green")
             ;; Get me out of here...
             (define-key p4-basic-map [(control ?c) (control ?c)]
               'dp4-restore-windows-and-frames)
             (define-key p4-opened-map [(control ?c) (control ?c)]
               'dp4-restore-windows-and-frames)
             ;; This shouldn't be universal.
             ;;;(dp-raise-and-focus-frame)
             )))

;; Setup indentation for p4 buffers
(defun p4-setup-indent ()
  "Setup indentation for a p4 buffer to DTRT"
  (interactive)
  ;; Filladapt's guesses are no where near their wonky style.
  ;; Adjust for next gig.
  (filladapt-mode 0)
  (make-variable-buffer-local 'tab-stop-list)
  (setq tab-stop-list '(8 10))
  (dp-define-buffer-local-keys'([tab] tab-to-tab-stop))
  (setq left-margin 8
	fill-column 74
	indent-tabs-mode t
	tab-width 8))

(defun dp4-form-hook-common (font-lock-keywords)
  (p4-setup-indent)
  (flyspell-mode-off)
  (set (make-local-variable 'font-lock-defaults)
       font-lock-keywords)
  (font-lock-fontify-buffer))

; If you have p4-async-command-hook installed, this will be
; called when you create a change or submit buffer.
(defun dp4-change-form-hook ()
  (interactive)
  (dp4-form-hook-common '(p4-changeset-font-lock-keywords
                          t nil nil backward-paragraph))
  (flyspell-mode-on))

(setq p4-change-hook 'dp4-change-form-hook)

; If you have p4-async-command-hook installed, this will be
; called when you create a client buffer.
(defun dp4-client-form-hook ()
  (interactive)
  (dp4-form-hook-common
   '(p4-client-font-lock-keywords
     t nil nil backward-paragraph))
  (font-lock-fontify-buffer))

(setq p4-client-hook 'dp4-client-form-hook)

(defvar dp4-frame-configurations-max 16
  "Only keep this absurd amount of configs around.")

(defvar dp4-frame-configurations nil
  "Save frame configs instead of just window configs.")

(defun dp4-restore-windows-and-frames (&optional save-p)
  (interactive "P")
  (kill-this-buffer)
  (let ((fc (car-safe dp4-frame-configurations)))
    (when fc
      (set-frame-configuration fc)
      (setq dp4-frame-configurations (cdr-safe dp4-frame-configurations)))))

(defalias 'p4p 'dp4-restore-windows-and-frames)

(defun dp4-bind-standard-keys (&optional just-map-control-C-p)
  ;; Map some common exit type single keys if we're read-only
  (with-current-buffer (or (dp-get-buffer p4-output-buffer-name)
                           (current-buffer))
    (dp-define-buffer-local-keys '([(control ?c) (control ?c)]
                                   dp4-restore-windows-and-frames))
    (when (and (not just-map-control-C-p)
               buffer-read-only)
      (dp-define-buffer-local-keys '([?q]
                                     dp4-restore-windows-and-frames
                                     [?x]
                                     dp4-restore-windows-and-frames
                                     [?-]
                                     dp4-restore-windows-and-frames)))))

(defun dp4-save-windows-and-frames ()
  "p4 only saves window config."
  (dp-push-onto-bounded-stack 'dp4-frame-configurations
                              (current-frame-configuration)
                              dp4-frame-configurations-max))

;;don't work; (defadvice p4-diff (after dp-p4-diff activate)
;;don't work;   (dmessage "p4-diff advice")
;;don't work;   (dp-set-frame-height))

;;don't work; (defadvice p4-diff2 (after dp-p4-diff2 activate)
;;don't work;   (dmessage "p4-diff2 advice")
;;don't work;   (dp-set-frame-height))

(defadvice p4-push-window-config (before dp-p4-push-window-config activate)
  (dp4-save-windows-and-frames))

(defadvice p4-edit (around dp-p4-edit activate)
  "Check for and handle symlinks my way. Also push window and frame config."
  (if (and (file-symlink-p (buffer-file-name))
           (not (y-or-n-p "File is a symlink, continue?")))
      (progn
        (when (and buffer-file-truename
                   (not (string= buffer-file-truename 
                                 (car kill-ring-yank-pointer)))
          (kill-new buffer-file-truename)))
        (message "Cancelling op on symlink. True name: %s"
                 buffer-file-truename))
    ;; The window config is also saved by p4 and can be restored like so:
    ;; p4-pop-window-config C-x p q
    (dp4-save-windows-and-frames)
    ad-do-it
    (dp4-bind-standard-keys)
    (dp-set-auto-mode)))

(defadvice p4-async-call-process (after dp-p4-async-call-process activate)
  ;;(dmessage "p4-async-call-process, bn>%s<" (buffer-name (current-buffer)))
  (dp4-bind-standard-keys))

(defadvice p4-blame (after dp-p4-blame activate)
  (dmessage "p4 buffer name>%s<" (get-buffer p4-output-buffer-name))
  (dmessage "buffer name>%s<" (buffer-name))
  (dp4-bind-standard-keys))

(defadvice p4-make-basic-buffer (after dp-p4-make-basic-buffer activate)
   (dmessage "dp-p4-make-basic-buffer, bn>%s<" (buffer-name))
  )

(defadvice p4-revert (after dp-p4-revert activate)
  ;; Make sure all mode specific stuff is set up.  In particular the
  ;; read-only background color.
  (dp-set-auto-mode))

;; Example form headers:
;; # A Perforce Client Specification.
;; # A Perforce Change Specification.
;; # Map a perforce form to a hook. This is used when we are used as an
;; editing server.
(defvar dp4-form-type-to-hook-map
  '(("Client" . dp4-client-form-load-hook)
    ("Change" . dp4-change-form-load-hook))
  "Map a perforce form type to a hook function.")

(defun dp4-deduce-form-type ()
  "Deduce the perforce form type based on the header it conveniently inserts."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward 
           "^# A Perforce \\(Client\\|Change\\) Specification." nil t)
      (match-string 1))))

(defun dp4-get-form-type-hook ()
  (cdr-safe (assoc (dp4-deduce-form-type) dp4-form-type-to-hook-map)))

(defun dp4-run-form-type-hooks ()
  "Run the appropriate hook(s) for the form type."
  (let ((hook (dp4-get-form-type-hook)))
    (when hook
      (funcall hook))))

(defun dp-p4-emacs-client ()
  "Set up p4 forms we're editing as a server. p4 client, p4 change, ... 
Things which are edited with ec-p4(dp) which uses this as the value for
`dp-found-file-post-hook'."
  ;; Set up things for the current form type.
  (dp4-run-form-type-hooks)
  (setq indent-tabs-mode t))

(defun dp4-nuke-Host-line ()
  "Nuke the ever painful, veritably unused Host: line."
  (interactive)
  (goto-char (point-min))
  (when (re-search-forward "^Host:.*$" nil t)
    (dp-kill-entire-line)
    (dp-kill-entire-line)))

(defun dp4-basic-form-setup ()
  "Nice standard client setup."
  (interactive)
  (dp4-nuke-Host-line))

(defun dp4-client-form-load-hook ()
  (interactive)
  (dp-warn-if-empty "perforce client form.")
  (if-and-fboundp 'dp4-locale-client-form-load-hook
      (dp4-locale-client-setup)
    (dp4-basic-form-setup)
    (dp4-client-form-hook)))

(defun dp4-change-form-load-hook ()
  (interactive)
  (dp-warn-if-empty "perforce change form.")
  (if-and-fboundp 'dp4-locale-change-form-load-hook
      (dp4-locale-client-setup)
    (dp4-basic-form-setup)
    (dp4-change-form-hook)))

;; Called when a p4.el command is executed.
(defun dp4-async-command-hook ()
;;   (dmessage "dp4-async-command-hook, buffer-name>%s<" (buffer-name)
  (if (or (string-match "*p4 \\(new\\|[0-9]+\\) change*" (buffer-name))
          (equal "*p4 submit*" (buffer-name)))
      (run-hooks 'p4-change-hook)
    ;; match either *p4 client* or *p4 client: client-name*
  (if (equal 0 (string-match "\\*p4 client.*"
                             (buffer-name)))
      (run-hooks 'p4-client-hook))
  ;; add hooks for: "
  ;;	*p4 [bb]ranch.*"
  ;;	*p4 label.*"
  ;;	*p4 user*"
  ;;	*p4 describe: .*"
  ))

(defun dp4-diff (&optional change-num)
  "Compare file in current buffer. With CHANGE-NUM if non-nil.
If CHANGE-NUM is C-- or C-0 or C-<less than zero> --> prompt for CHANGE-NUM."
  (interactive "P")
  ;; nil --> simple diff
  (let* ((change-num (or change-num
                         (prefix-numeric-value current-prefix-arg)))
        (current-file-name (p4-buffer-file-name-2))
        (current-prefix-arg (if (integerp current-prefix-arg)
                                nil
                            current-prefix-arg)))
    (cond
     ((or (null change-num)
          (and (integerp change-num) 
               (= change-num 1)))
      (call-interactively 'p4-diff))
     ((and (integerp change-num)
           (> change-num 1))
      (p4-diff2 (format "@%s" change-num) ""))
     (t
      (p4-diff2 (read-string "Revision (include @ or # prefix): ")
               "")))))

; p4-async-command-hook to allow specifying hooks for special
; perforce buffers
(add-hook 'p4-async-command-hook 'dp4-async-command-hook)

(provide 'dp-perforce)
