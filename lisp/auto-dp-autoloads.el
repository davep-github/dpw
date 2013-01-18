;;; DO NOT MODIFY THIS FILE
(if (featurep 'auto-dp-autoloads) (error "Already loaded"))

;;;### (autoloads (dp-colorize-ifdefs dp-uncolorize-ifdefs) "dp-colorize-ifdefs" "lisp/dp-colorize-ifdefs.el")

(autoload 'dp-uncolorize-ifdefs "dp-colorize-ifdefs" nil t nil)

(autoload 'dp-colorize-ifdefs "dp-colorize-ifdefs" "\
Colorize parts of ifdef." t nil)

;;;***

;;;### (autoloads (dp-unhook-insert dp-unhook-message dp-hook-insert dp-hook-message) "dp-debug" "lisp/dp-debug.el")

(autoload 'dp-hook-message "dp-debug" nil t nil)

(autoload 'dp-hook-insert "dp-debug" nil t nil)

(autoload 'dp-unhook-message "dp-debug" nil t nil)

(autoload 'dp-unhook-insert "dp-debug" nil t nil)

;;;***

;;;### (autoloads (dp-edit-faces dp-all-dp*-faces) "dp-faces" "lisp/dp-faces.el")

(autoload 'dp-all-dp*-faces "dp-faces" nil nil nil)

(autoload 'dp-edit-faces "dp-faces" "\
Alter face characteristics by editing a list of defined faces.
Pops up a buffer containing a list of defined faces.

WARNING: the changes you may perform with this function are no longer
saved. The prefered way to modify faces is now to use `customize-face'. If you 
want to specify particular X font names for faces, please do so in your
.XDefaults file.

Editing commands:

\\{edit-faces-mode-map}" t nil)

;;;***

;;;### (autoloads (dp-flyspell-prog-mode dp-flyspell-prog-setup dp-flyspell-setup dp-flyspell-setup0) "dp-flyspell" "lisp/dp-flyspell.el")

(autoload 'dp-flyspell-setup0 "dp-flyspell" nil t nil)

(autoload 'dp-flyspell-setup "dp-flyspell" nil t nil)

(autoload 'dp-flyspell-prog-setup "dp-flyspell" nil t nil)

(autoload 'dp-flyspell-prog-mode "dp-flyspell" "\
Put a buffer into `flyspell-prog-mode', with persistent-highlight OFF.
PERSISTENT-HIGHLIGHT-P says to turn on persistent-highlight." t nil)

;;;***

;;;### (autoloads (gid) "dp-id-utils" "lisp/dp-id-utils.el")

(autoload 'gid "dp-id-utils" "\
Run gid, with user-specified ARGS, and collect output in a buffer.
While gid runs asynchronously, you can use the \\[next-error] command to
find the text that gid hits refer to. The command actually run is
defined by the gid-command variable." t nil)

;;;***

;;;### (autoloads (dpj-setup-invisibility dp-journal-mode dpj-visit-other-journal-file dp-journal2 dp-journal dpj-edit-journal-file cxl dpj-clone-topic-and-link dpj-clone-topic dpj-goto-end-of-journal dp-add-elisp-journal-entry dpj-chase-link dpj-tidy-journals-keep dpj-tidy-journals dpj-stick-current-journal-file dpj-stick-journal-file) "dp-journal" "lisp/dp-journal.el")

(autoload 'dpj-stick-journal-file "dp-journal" "\
Ass/2 way to make non-standard journal files a little less unusable." nil nil)

(autoload 'dpj-stick-current-journal-file "dp-journal" "\
Ass/2 way to make non-standard journal files a little less unusable." t nil)

(defun* dpj-grep-and-view-hits (number-of-months topic-re grep-re &optional (continue-from-last-p nil cflp-set-p)) "Grep topics for regexp and view in view buf.\nSearch NUMBER-OF-MONTHS files back in time.\nSearch topics matching TOPIC-RE for GREP-RE.\nView all records with matches in a view buf.\nSTART-WITH-CURRENT-JOURNAL-P (interactively the prefix-arg) says to start\nthe search with the current journal file." (interactive (dpj-read-num-and-topic "Number of months" "grep expr: ")) (let ((x-args (list grep-re topic-re nil 'just-remember-records)) (rewind-p (if cflp-set-p continue-from-last-p (not current-prefix-arg)))) (when rewind-p (dpj-tidy-journals-keep)) (dpj-view-topics number-of-months 'dpj-grep-bodies x-args 'dont-visit) (set-buffer dpj-view-topic-buffer-name) (if (not (or (string= grep-re "") (string= grep-re ".") (string= grep-re ".*"))) (save-excursion (dp-beginning-of-buffer) (while (re-search-forward grep-re nil t) (dp-make-extent (match-beginning 0) (match-end 0) 'dpj-view-topic 'face 'dpj-view-grep-hit-face)))) (dpj-switch-to-view-buf)))

(defalias 'gv 'dpj-grep-and-view-hits)

(defalias 'dg 'dpj-grep-and-view-hits)

(defalias 'jg 'dpj-grep-and-view-hits)

(defalias 'dpj-grep 'dpj-grep-and-view-hits)

(autoload 'dpj-tidy-journals "dp-journal" "\
Kill all but the most recent journal buffers." t nil)

(autoload 'dpj-tidy-journals-keep "dp-journal" nil t nil)

(autoload 'dpj-chase-link "dp-journal" "\
Follow a link to another note.
 !<@todo XXX Make this put the BM in the most recent journal." nil nil)

(autoload 'dp-add-elisp-journal-entry "dp-journal" nil t nil)

(dp-safe-alias 'ee 'dp-add-elisp-journal-entry)

(defun* dpj-new-topic (&key topic no-spaced-append-p link-too-p is-a-clone-p other-win-p dir-name) "Insert a new topic item.  Completion is allowed from the list of known topics." (interactive) (dp-push-go-back "dpj-new-topic") (let (vbuf cur-topic (file-name (buffer-file-name)) offset context-info new-record-pos timestamp-info) (if (and (dpj-journal-mode-p) (> (point-max) 1)) (progn (setq timestamp-info (dpj-get-current-timestamp) cur-topic (dpj-current-topic nil 'no-quote) context-info (car timestamp-info))) (setq context-info "")) (setq offset (point)) (dp-journal other-win-p nil 'visit-latest topic) (unless topic (setq topic (car (dpj-get-topic-interactive nil cur-topic)))) (dpj-visit-appropriate-journal-file topic dir-name) (dpj-new-topic0 :topic topic :no-spaced-append-p no-spaced-append-p) (if (or link-too-p (and is-a-clone-p (or (not (string= file-name (buffer-file-name))) (dpj-auto-link-by-distance-p offset new-record-pos)))) (prog1 (dpj-insert-link file-name offset context-info)))))

(defun* dpj-new-topic-other-window (&key topic no-spaced-append-p link-too-p is-a-clone-p) (interactive) (dpj-new-topic :topic topic :no-spaced-append-p no-spaced-append-p :link-too-p link-too-p :is-a-clone-p is-a-clone-p :other-win-p 'other-win))

(defalias 'cx 'dpj-new-topic-other-window)

(defalias 'cx2 'dpj-new-topic-other-window)

(defalias 'cx1 'dpj-new-topic)

(defalias 'cx0 'dpj-new-topic)

(defalias 'cx\. 'dpj-new-topic)

(defalias 'nt 'dpj-new-topic-other-window)

(defalias 'ntc 'dpj-clone-topic)

(defalias 'nt2 'dpj-new-topic-other-window)

(defalias 'nt1 'dpj-new-topic)

(defalias 'nt0 'dpj-new-topic)

(autoload 'dpj-goto-end-of-journal "dp-journal" nil t nil)

(defalias 'eoj 'dpj-goto-end-of-journal)

(autoload 'dpj-clone-topic "dp-journal" "\
Clone the current topic with a new timestamp.
NB: previous topic means the previous SAME topic.
LINK-TOO-P, if non-nil says to link to the previous topic.
LINK-TOO-P, if nil will make a link to the previous topic if it is 
\"far enough away.\"
INSERT-THIS-TEXT is text to insert after the topic is inserted.
Allows for an indication of time flow within a continuing topic or 
continuation of a topic at a later time." t nil)

(defalias 'cxc 'dpj-clone-topic)

(autoload 'dpj-clone-topic-and-link "dp-journal" "\
Clone topic and force link to previous topic regardless of distance." t nil)

(autoload 'cxl "dp-journal" nil t nil)

(defun* dpj-mk-external-bookmark (&optional (pos (point)) (file-or-buf (current-buffer))) "Make link a topic @ (or POS (point)) in (or FILE-OR-BUF (current bufer))." (interactive) (let ((boundaries (dp-region-or-line-boundaries))) (dpj-clone-topic 'link-too-p (buffer-substring (car boundaries) (cdr boundaries)))))

(autoload 'dpj-edit-journal-file "dp-journal" "\
Edit the journal file." t nil)

(autoload 'dp-journal "dp-journal" "\
Visit a journal file.
If `dpj-current-journal-file' is non-nil, visit that file, otherwise
visit the journal for the current date and set `dpj-current-journal-file'.
OTHER-WIN-P says visit in other window.
GOTO-EOF says go to end of file.
VISIT-LATEST says visit the current journal even if
`dpj-current-journal-file' is non-nil.
RETURN buffer that was visiting the journal, or nil." t nil)

(autoload 'dp-journal2 "dp-journal" nil t nil)

(defalias 'dj 'dp-journal2)

(defalias 'dj2 'dp-journal2)

(defalias 'dj1 'dp-journal)

(defalias 'dj0 'dp-journal)

(defalias 'dj\. 'dp-journal)

(defalias 'djd 'dp-journal)

(autoload 'dpj-visit-other-journal-file "dp-journal" "\
Visit FILE-NAME as journal and make it sticky to the current buffer.
This kind of allows us to use a journal file with a non-standard name." t nil)

(when (dp-xemacs-p) (defvar dpj-menubutton-guts [dp-journal :active (fboundp 'dp-journal)] "Menu button to activate journal.") (defvar dpj-menubar-button (vconcat ["Dj"] dpj-menubutton-guts) "Journal menubar button.") (defvar dpj-menu-button-added nil "Non nil if we've already added the menu-button.") (unless dpj-menu-button-added (add-menu-button nil dpj-menubar-button nil default-menubar) (setq dpj-menu-button-added t)))

(autoload 'dp-journal-mode "dp-journal" "\
Major mode for editing journals." t nil)

(autoload 'dpj-setup-invisibility "dp-journal" "\
Make a nice glyph for invisible text regions." t nil)

;;;***

;;;### (autoloads (dp-sel2:bm dp-sel2:paste) "dp-sel2" "lisp/dp-sel2.el")

(autoload 'dp-sel2:paste "dp-sel2" "\
Select the item to paste from a list.
Rotate kill list so that the selected kill-text is at the head of the
yank ring." t nil)

(autoload 'dp-sel2:bm "dp-sel2" "\
Select a bookmark to which to jump." t nil)

;;;***

;;;### (autoloads (dp-ssh-gdb dp-ssh dp-gdb dp-gdb-naught dp-tack-on-gdb-mode dp-gdb-old dp-shell-other-window dp-lterm dp-cterm dp-start-term dp-python-shell dp-ssh-mode-hook dp-gdb-mode-hook dp-py-shell-hook dp-shell-goto-this-error dp-cscope-next-thing dp-next-error dp-set-compile-like-mode-error-function dp-reset-current-error-function dp-set-current-error-function dp-compilation-mode-hook dp-telnet-mode-hook dp-shell-mode-hook dp-comint-mode-hook dp-shells-mk-prompt-font-lock-regexp) "dp-shells" "lisp/dp-shells.el")

(defcustom shell-uninteresting-face 'shell-uninteresting-face "Face for shell output which is uninteresting.\nShould be a color which nearly blends into background." :type 'face :group 'shell-faces)

(defun* dp-shells-add-prompt-regexp (regexp &optional (mk-it-p t)) (add-to-list 'dp-shells-prompt-font-lock-regexp-list))

(autoload 'dp-shells-mk-prompt-font-lock-regexp "dp-shells" nil nil nil)

(defvar dp-shells-prompt-font-lock-regexp "^\\([0-9]+\\)\\(/[0-9]+\\)\\([#>]\\|\\(<[0-9]*>\\)?\\)" "\
*Regular expression to match my shell prompt.  Used for font locking.
For my multi-line prompt, this is second line.  For most prompts, this will
be the only line.  Some shells, like IPython's, already colorize their
prompt.  We don't want to stomp on them.")

(eval-after-load "shell" '(progn (setq shell-prompt-pattern-for-font-lock dp-shells-prompt-font-lock-regexp)))

(autoload 'dp-comint-mode-hook "dp-shells" "\
Sets up personal comint mode options.
Called when shell, inferior-lisp-process, etc. are entered." t nil)

(autoload 'dp-shell-mode-hook "dp-shells" "\
Sets up shell mode specific options." t nil)

(autoload 'dp-telnet-mode-hook "dp-shells" "\
Sets up telnet mode specific options." nil nil)

(autoload 'dp-compilation-mode-hook "dp-shells" nil nil nil)

(autoload 'dp-set-current-error-function "dp-shells" nil t nil)

(autoload 'dp-reset-current-error-function "dp-shells" nil t nil)

(autoload 'dp-set-compile-like-mode-error-function "dp-shells" nil nil nil)

(autoload 'dp-next-error "dp-shells" "\
Find next error in shell buffer.
This key is globally bound.  It does special things only if it is
invoked inside a shell type buffer.  In this case, it ensures the
buffer is in compilation minor-mode and reparses errors if it detects
that a new command has been sent since the last parse.
@todo Use/write i/f to `previous-error-p' to make us go backwards." t nil)

(autoload 'dp-cscope-next-thing "dp-shells" nil t nil)

(autoload 'dp-shell-goto-this-error "dp-shells" "\
Goto the error at point in the shell buffer.  
This has the fortunate side effect of setting 
things up so that dp-next-error (\\[dp-next-error]) 
picks up right after the error we just visited.
We use this instead of just `compile-goto-error' so that
we can goto errors anywhere in the buffer, especially 
earlier in the buffer. `compile-goto-error' has a 
very (too) forward looking view of parsing error buffers." t nil)

(autoload 'dp-py-shell-hook "dp-shells" "\
Set up my python shell mode fiddle-faddle." t nil)

(autoload 'dp-gdb-mode-hook "dp-shells" "\
Set up my gdb shell mode fiddle-faddle." t nil)

(autoload 'dp-ssh-mode-hook "dp-shells" "\
Set up my ssh shell mode fiddle-faddle." t nil)

(autoload 'dp-python-shell "dp-shells" "\
Start up python shell and then run my shell-mode-hook since they
set the key-map after the hook has run." t nil)

(defalias 'dpy 'dp-python-shell)

(defsubst dp-python-shell-this-window (&optional args) "Try to put the shell in the current window." (interactive "P") (dp-python-shell) (dp-slide-window-right 1))

(defalias 'dpyd 'dp-python-shell-this-window)

(defalias 'dpy\. 'dp-python-shell-this-window)

(defalias 'dpy0 'dp-python-shell-this-window)

(autoload 'dp-start-term "dp-shells" "\
Start up a terminal session, but first set the coding system so eols are 
handled right." t nil)

(autoload 'dp-cterm "dp-shells" nil t nil)

(autoload 'dp-lterm "dp-shells" nil t nil)

(defun* dp-shell0 (&optional arg &key other-window-p name other-frame-p) "Open/visit a shell buffer.\nFirst shell is numbered 0 by default.\nARG is numberp:\n ARG is >= 0: switch to that numbered shell.\n ARG is < 0: switch to shell buffer<(abs ARG)>\n ARG memq `dp-shells-shell<0>-names' shell<0> in other window." (interactive "P") (let* ((specific-buf-requested-p current-prefix-arg) (pnv (cond ((member arg dp-shells-shell<0>-names) 0) (t (prefix-numeric-value arg)))) (fav-buf0 (dp-shells-get-favored-buffer (current-buffer))) (fav-buf (dp-shells-favored-shell-buffer-buffer fav-buf0)) (fav-buf-name (dp-shells-favored-shell-buffer-name fav-buf)) (fan-buf-name (format "<%s>" (buffer-name))) (fav-flags (dp-shells-favored-shell-buffer-flags fav-buf0)) (other-window-p (or (eq arg '-) (and pnv (< pnv 0) (setq pnv (abs pnv))) other-window-p fav-flags (Cup))) (switch-window-func (cond ((functionp other-window-p) other-window-p) (other-window-p 'switch-to-buffer-other-window) (t nil))) (sh-name (or name (stringp arg) (and arg (or (dp-shells-get-shell-buffer-name pnv) (format "*shell*<%s>" pnv))) (and fav-buf0 fav-buf-name) (and pnv (or (dp-shells-get-shell-buffer-name pnv) (format "*shell*<%s>" pnv))) (and (dp-buffer-live-p (dp-shells-most-recent-shell-buffer))))) (existing-shell-p (dp-buffer-live-p sh-name)) (sh-buffer (and sh-name (get-buffer-create sh-name))) win fav-buf0 new-shell-buf) (if existing-shell-p (progn (dp-visit-or-switch-to-buffer sh-buffer switch-window-func) (when specific-buf-requested-p (dp-shells-set-most-recent-shell (current-buffer) 'shell)) (when (dp-fav-buf-p fav-buf0) (setq dp-shell-whence-buf fav-buf dp-use-whence-buffers-p t) (unless (string-match (regexp-quote fan-buf-name) fav-buf-name) (rename-buffer (format "%s%s" fav-buf-name fan-buf-name))) (message "Using fav buf: %s" fav-buf0)) (dmessage "point: %s, window-point: %s" (point) (window-point))) (setenv "PS1_prefix" nil 'UNSET) (setenv "PS1_host_suffix" (format "%s" (dp-shells-guess-suffix sh-name ""))) (setenv "PS1_bang_suff" (format dp-shells-shell-num-fmt pnv)) (save-window-excursion/mapping (shell sh-buffer)) (dp-visit-or-switch-to-buffer sh-buffer switch-window-func) (setq dp-shell-isa-shell-buf-p '(dp-shell shell) dp-prefer-independent-frames-p t other-window-p nil dp-shell-buffer-save-file-name (dp-transformed-save-buffer-file-name dp-default-save-buffer-contents-dir 'dp-shellify-shell-name)) (dp-shells-set-most-recently-created-shell sh-buffer 'shell) (dp-shells-set-most-recent-shell sh-buffer 'shell) (add-to-list 'dp-shells-shell-buffer-list sh-buffer) (add-local-hook 'kill-buffer-hook 'dp-shells-delq-buffer) (add-local-hook 'kill-buffer-hook (lambda nil (dp-save-shell-buffer-contents-hook nil t))) (setq dp-original-shell-filter-function (process-filter (dp-get-buffer-process-safe))) (set-process-filter (dp-get-buffer-process-safe) 'dp-shell-filter-proc) (dmessage "Loading shell input ring") (dp-maybe-read-input-ring))))

(defun* dp-shell (&optional arg &key other-window-p name other-frame-p) (interactive "P") (let ((whence-buf (unless (dp-shell-buffer-p) (current-buffer))) shell-buf) (if (equal current-prefix-arg '(4)) (dp-shell-cycle-buffers -1) (dp-shell0 arg :other-window-p other-window-p :name name :other-frame-p other-frame-p) (when whence-buf (setq dp-shell-whence-buf whence-buf)))))

(autoload 'dp-shell-other-window "dp-shells" nil t nil)

(autoload 'dp-gdb-old "dp-shells" nil t nil)

(autoload 'dp-tack-on-gdb-mode "dp-shells" nil t nil)

(autoload 'dp-gdb-naught "dp-shells" "\
Run gdb on program FILE in buffer *gdb-FILE*.
The directory containing FILE becomes the initial working directory
and source-file directory for GDB.  If you wish to change this, use
the GDB commands `cd DIR' and `directory'." t nil)

(autoload 'dp-gdb "dp-shells" "\
Extension to gdb that:
. Prefers the most recently used buffer if its process is still live,
. Else it asks for a buffer using a completion list of other gdb buffers,
. Else (or if nothing selected above) it starts a new gdb session." t nil)

(autoload 'dp-ssh "dp-shells" "\
Find/create a shell buf, an existing ssh buf or create a ssh buf." t nil)

(autoload 'dp-ssh-gdb "dp-shells" nil t nil)

;;;***

;;;### (autoloads (dp-dired-sudo-edit dp-sudo-edit-devert dp-sudo-edit-this-file dp-sudo-edit) "dp-sudo-edit3" "lisp/dp-sudo-edit3.el")

(defcustom dp-sudo-edit-load-hook nil "List of functions to be called after the we're loaded." :type 'hook :group 'dp-hooks)

(defface dp-sudo-edit-bg-face '((((class color) (background light)) (:background "thistle2"))) "Face for file being sudo edited." :group 'faces :group 'dp-vars)

(autoload 'dp-sudo-edit "dp-sudo-edit3" "\
Edit a file by using sudo to cat the file into a buffer and sudo to cp the edited file over the original." t nil)

(defalias 'dse 'dp-sudo-edit)

(autoload 'dp-sudo-edit-this-file "dp-sudo-edit3" "\
Edit the current buffer w/sudo edit." t nil)

(defalias 'dset 'dp-sudo-edit-this-file)

(defalias 'dse\. 'dp-sudo-edit-this-file)

(autoload 'dp-sudo-edit-devert "dp-sudo-edit3" "\
Stop sudo-editing this file.  Edit it normally." t nil)

(defalias 'dsed 'dp-sudo-edit-devert)

(autoload 'dp-dired-sudo-edit "dp-sudo-edit3" "\
In dired, sudo the file named on this line." t nil)

;;;***

;;;### (autoloads (dp-pb-new-entry) "dp-templates" "lisp/dp-templates.el")

(autoload 'dp-pb-new-entry "dp-templates" nil t nil)

;;;***

;;;### (autoloads nil "dpmacs" "lisp/dpmacs.el")

;;;***

(provide 'auto-dp-autoloads)
