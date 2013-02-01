;;; DO NOT MODIFY THIS FILE -*- coding: raw-text-unix -*-
;;;###coding system: raw-text-unix
(if (featurep 'auto-dp-autoloads) (error "Feature auto-dp-autoloads already loaded"))

;;;### (autoloads (dp-colorize-ifdefs dp-uncolorize-ifdefs) "dp-colorize-ifdefs" "lisp/dp-colorize-ifdefs.el")

(autoload 'dp-uncolorize-ifdefs "dp-colorize-ifdefs" "\


arguments: (&optional BEGIN END)
" t nil)

(autoload 'dp-colorize-ifdefs "dp-colorize-ifdefs" "\
Colorize parts of ifdef.

arguments: (&optional COLORIZE-NESTED)
" t nil)

;;;***

;;;### (autoloads (dp-unhook-insert dp-unhook-message dp-hook-insert dp-hook-message) "dp-debug" "lisp/dp-debug.el")

(autoload 'dp-hook-message "dp-debug" "\


arguments: ()
" t nil)

(autoload 'dp-hook-insert "dp-debug" "\


arguments: ()
" t nil)

(autoload 'dp-unhook-message "dp-debug" "\


arguments: ()
" t nil)

(autoload 'dp-unhook-insert "dp-debug" "\


arguments: ()
" t nil)

;;;***

;;;### (autoloads (dp-edit-faces dp-all-dp*-faces) "dp-faces" "lisp/dp-faces.el")

(autoload 'dp-all-dp*-faces "dp-faces" "\


arguments: ()
" nil nil)

(autoload 'dp-edit-faces "dp-faces" "\
Alter face characteristics by editing a list of defined faces.
Pops up a buffer containing a list of defined faces.

WARNING: the changes you may perform with this function are no longer
saved. The prefered way to modify faces is now to use `customize-face'. If you 
want to specify particular X font names for faces, please do so in your
.XDefaults file.

Editing commands:

\\{edit-faces-mode-map}

arguments: ()
" t nil)

;;;***

;;;### (autoloads (dp-flyspell-prog-mode dp-flyspell-prog-setup dp-flyspell-setup dp-flyspell-setup0) "dp-flyspell" "lisp/dp-flyspell.el")

(autoload 'dp-flyspell-setup0 "dp-flyspell" "\


arguments: (HOOK-LIST DEFAULT-MODE-FUNC &optional FORCE)
" t nil)

(autoload 'dp-flyspell-setup "dp-flyspell" "\


arguments: (&optional FORCE)
" t nil)

(autoload 'dp-flyspell-prog-setup "dp-flyspell" "\


arguments: ()
" t nil)

(autoload 'dp-flyspell-prog-mode "dp-flyspell" "\
Put a buffer into `flyspell-prog-mode', with persistent-highlight OFF.
PERSISTENT-HIGHLIGHT-P says to turn on persistent-highlight.

arguments: (&optional PERSISTENT-HIGHLIGHT-P)
" t nil)

;;;***

;;;### (autoloads (gid) "dp-id-utils" "lisp/dp-id-utils.el")

(autoload 'gid "dp-id-utils" "\
Run gid, with user-specified ARGS, and collect output in a buffer.
While gid runs asynchronously, you can use the \\[next-error] command to
find the text that gid hits refer to. The command actually run is
defined by the gid-command variable.

arguments: (ARGS)
" t nil)

;;;***

;;;### (autoloads (dpj-setup-invisibility dp-journal-mode dpj-visit-other-journal-file dp-journal2 dp-journal dpj-edit-journal-file dpj-mk-external-bookmark cxl dpj-clone-topic-and-link dpj-clone-topic dpj-goto-end-of-journal dpj-new-topic-other-window dpj-new-topic dp-add-elisp-journal-entry dpj-chase-link dpj-tidy-journals-keep dpj-tidy-journals dpj-grep-and-view-hits dpj-stick-current-journal-file dpj-stick-journal-file) "dp-journal" "lisp/dp-journal.el")

(autoload 'dpj-stick-journal-file "dp-journal" "\
Ass/2 way to make non-standard journal files a little less unusable.

arguments: (&optional FILE-NAME UNSTICK-P DEFAULT-P)
" nil nil)

(autoload 'dpj-stick-current-journal-file "dp-journal" "\
Ass/2 way to make non-standard journal files a little less unusable.

arguments: (&optional UNSTICK-P DEFAULT-P)
" t nil)

(autoload 'dpj-grep-and-view-hits "dp-journal" "\
Grep topics for regexp and view in view buf.
Search NUMBER-OF-MONTHS files back in time.
Search topics matching TOPIC-RE for GREP-RE.
View all records with matches in a view buf.
START-WITH-CURRENT-JOURNAL-P (interactively the prefix-arg) says to start
the search with the current journal file.

arguments: (NUMBER-OF-MONTHS TOPIC-RE GREP-RE &optional (CONTINUE-FROM-LAST-P NIL CFLP-SET-P))
" t nil)

(defalias 'gv 'dpj-grep-and-view-hits)

(defalias 'dg 'dpj-grep-and-view-hits)

(defalias 'jg 'dpj-grep-and-view-hits)

(defalias 'dpj-grep 'dpj-grep-and-view-hits)

(autoload 'dpj-tidy-journals "dp-journal" "\
Kill all but the most recent journal buffers.

arguments: (&optional DONT-DELETE-P)
" t nil)

(autoload 'dpj-tidy-journals-keep "dp-journal" "\


arguments: ()
" t nil)

(autoload 'dpj-chase-link "dp-journal" "\
Follow a link to another note.
 !<@todo XXX Make this put the BM in the most recent journal.

arguments: (FILE-NAME OFFSET DATE-STRING)
" nil nil)

(autoload 'dp-add-elisp-journal-entry "dp-journal" "\


arguments: ()
" t nil)

(dp-safe-alias 'ee 'dp-add-elisp-journal-entry)

(autoload 'dpj-new-topic "dp-journal" "\
Insert a new topic item.  Completion is allowed from the list of known topics.

arguments: (&key TOPIC NO-SPACED-APPEND-P LINK-TOO-P IS-A-CLONE-P OTHER-WIN-P DIR-NAME)
" t nil)

(autoload 'dpj-new-topic-other-window "dp-journal" "\


arguments: (&key TOPIC NO-SPACED-APPEND-P LINK-TOO-P IS-A-CLONE-P)
" t nil)

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

(autoload 'dpj-goto-end-of-journal "dp-journal" "\


arguments: ()
" t nil)

(defalias 'eoj 'dpj-goto-end-of-journal)

(autoload 'dpj-clone-topic "dp-journal" "\
Clone the current topic with a new timestamp.
NB: previous topic means the previous SAME topic.
LINK-TOO-P, if non-nil says to link to the previous topic.
LINK-TOO-P, if nil will make a link to the previous topic if it is 
\"far enough away.\"
INSERT-THIS-TEXT is text to insert after the topic is inserted.
Allows for an indication of time flow within a continuing topic or 
continuation of a topic at a later time.

arguments: (&optional LINK-TOO-P INSERT-THIS-TEXT LINK-FORWARD-ALSO-P)
" t nil)

(defalias 'cxc 'dpj-clone-topic)

(autoload 'dpj-clone-topic-and-link "dp-journal" "\
Clone topic and force link to previous topic regardless of distance.

arguments: ()
" t nil)

(autoload 'cxl "dp-journal" "\


arguments: ()
" t nil)

(autoload 'dpj-mk-external-bookmark "dp-journal" "\
Make link a topic @ (or POS (point)) in (or FILE-OR-BUF (current bufer)).

arguments: (&optional (POS (POINT)) (FILE-OR-BUF (CURRENT-BUFFER)))
" t nil)

(autoload 'dpj-edit-journal-file "dp-journal" "\
Edit the journal file.

arguments: (FNAME &optional MISSING-FILE-ACTION OTHER-WIN-P)
" t nil)

(autoload 'dp-journal "dp-journal" "\
Visit a journal file.
If `dpj-current-journal-file' is non-nil, visit that file, otherwise
visit the journal for the current date and set `dpj-current-journal-file'.
OTHER-WIN-P says visit in other window.
GOTO-EOF says go to end of file.
VISIT-LATEST says visit the current journal even if
`dpj-current-journal-file' is non-nil.
RETURN buffer that was visiting the journal, or nil.

arguments: (&optional OTHER-WIN-P GOTO-EOF VISIT-LATEST TOPIC)
" t nil)

(autoload 'dp-journal2 "dp-journal" "\


arguments: ()
" t nil)

(defalias 'dj 'dp-journal2)

(defalias 'dj2 'dp-journal2)

(defalias 'dj1 'dp-journal)

(defalias 'dj0 'dp-journal)

(defalias 'dj\. 'dp-journal)

(defalias 'djd 'dp-journal)

(autoload 'dpj-visit-other-journal-file "dp-journal" "\
Visit FILE-NAME as journal and make it sticky to the current buffer.
This kind of allows us to use a journal file with a non-standard name.

arguments: (FILE-NAME &optional OTHER-WINDOW-P)
" t nil)

(when (dp-xemacs-p) (defvar dpj-menubutton-guts [dp-journal :active (fboundp 'dp-journal)] "Menu button to activate journal.") (defvar dpj-menubar-button (vconcat ["Dj"] dpj-menubutton-guts) "Journal menubar button.") (defvar dpj-menu-button-added nil "Non nil if we've already added the menu-button.") (unless dpj-menu-button-added (add-menu-button nil dpj-menubar-button nil default-menubar) (setq dpj-menu-button-added t)))

(autoload 'dp-journal-mode "dp-journal" "\
Major mode for editing journals.

arguments: ()
" t nil)

(autoload 'dpj-setup-invisibility "dp-journal" "\
Make a nice glyph for invisible text regions.

arguments: ()
" t nil)

;;;***

;;;### (autoloads (dp-sel2:bm dp-sel2:paste) "dp-sel2" "lisp/dp-sel2.el")

(autoload 'dp-sel2:paste "dp-sel2" "\
Select the item to paste from a list.
Rotate kill list so that the selected kill-text is at the head of the
yank ring.

arguments: ()
" t nil)

(autoload 'dp-sel2:bm "dp-sel2" "\
Select a bookmark to which to jump.

arguments: (&optional IGNORE-EMBEDDED-BOOKMARKS-P)
" t nil)

;;;***

;;;### (autoloads (dp-ssh-gdb dp-ssh dp-gdb dp-gdb-naught dp-tack-on-gdb-mode dp-gdb-old dp-shell-other-window dp-shell dp-shell0 dp-lterm dp-cterm dp-start-term dp-python-shell dp-ssh-mode-hook dp-gdb-mode-hook dp-py-shell-hook dp-shell-goto-this-error dp-cscope-next-thing dp-next-error dp-set-compile-like-mode-error-function dp-reset-current-error-function dp-set-current-error-function dp-compilation-mode-hook dp-telnet-mode-hook dp-shell-mode-hook dp-comint-mode-hook dp-shells-mk-prompt-font-lock-regexp dp-shells-add-prompt-regexp shell-uninteresting-face) "dp-shells" "lisp/dp-shells.el")

(defvar shell-uninteresting-face 'shell-uninteresting-face "\
Face for shell output which is uninteresting.
Should be a color which nearly blends into background.")

(autoload 'dp-shells-add-prompt-regexp "dp-shells" "\


arguments: (REGEXP &optional (MK-IT-P T))
" nil nil)

(autoload 'dp-shells-mk-prompt-font-lock-regexp "dp-shells" "\


arguments: (&optional REGEXP-LIST)
" nil nil)

(defvar dp-shells-prompt-font-lock-regexp "^\\([0-9]+\\)\\(/[0-9]+\\)\\([#>]\\|\\(<[0-9]*>\\)?\\)" "\
*Regular expression to match my shell prompt.  Used for font locking.
For my multi-line prompt, this is second line.  For most prompts, this will
be the only line.  Some shells, like IPython's, already colorize their
prompt.  We don't want to stomp on them.")

(eval-after-load "shell" '(progn (setq shell-prompt-pattern-for-font-lock dp-shells-prompt-font-lock-regexp)))

(autoload 'dp-comint-mode-hook "dp-shells" "\
Sets up personal comint mode options.
Called when shell, inferior-lisp-process, etc. are entered.

arguments: ()
" t nil)

(autoload 'dp-shell-mode-hook "dp-shells" "\
Sets up shell mode specific options.

arguments: ()
" t nil)

(autoload 'dp-telnet-mode-hook "dp-shells" "\
Sets up telnet mode specific options.

arguments: ()
" nil nil)

(autoload 'dp-compilation-mode-hook "dp-shells" "\


arguments: ()
" nil nil)

(autoload 'dp-set-current-error-function "dp-shells" "\


arguments: (FUNC USE-NO-ARGS-P &rest ARGS)
" t nil)

(autoload 'dp-reset-current-error-function "dp-shells" "\


arguments: ()
" t nil)

(autoload 'dp-set-compile-like-mode-error-function "dp-shells" "\


arguments: ()
" nil nil)

(autoload 'dp-next-error "dp-shells" "\
Find next error in shell buffer.
This key is globally bound.  It does special things only if it is
invoked inside a shell type buffer.  In this case, it ensures the
buffer is in compilation minor-mode and reparses errors if it detects
that a new command has been sent since the last parse.
@todo Use/write i/f to `previous-error-p' to make us go backwards.

arguments: (&optional PREVIOUS-ERROR-P)
" t nil)

(autoload 'dp-cscope-next-thing "dp-shells" "\


arguments: (FUNC)
" t nil)

(autoload 'dp-shell-goto-this-error "dp-shells" "\
Goto the error at point in the shell buffer.  
This has the fortunate side effect of setting 
things up so that dp-next-error (\\[dp-next-error]) 
picks up right after the error we just visited.
We use this instead of just `compile-goto-error' so that
we can goto errors anywhere in the buffer, especially 
earlier in the buffer. `compile-goto-error' has a 
very (too) forward looking view of parsing error buffers.

arguments: (&optional FORCE-REPARSE-P)
" t nil)

(autoload 'dp-py-shell-hook "dp-shells" "\
Set up my python shell mode fiddle-faddle.

arguments: ()
" t nil)

(autoload 'dp-gdb-mode-hook "dp-shells" "\
Set up my gdb shell mode fiddle-faddle.

arguments: ()
" t nil)

(autoload 'dp-ssh-mode-hook "dp-shells" "\
Set up my ssh shell mode fiddle-faddle.

arguments: ()
" t nil)

(autoload 'dp-python-shell "dp-shells" "\
Start up python shell and then run my shell-mode-hook since they
set the key-map after the hook has run.

arguments: (&optional ARGS)
" t nil)

(defalias 'dpy 'dp-python-shell)

(defsubst dp-python-shell-this-window (&optional args) "\
Try to put the shell in the current window." (interactive "P") (dp-python-shell) (dp-slide-window-right 1))

(defalias 'dpyd 'dp-python-shell-this-window)

(defalias 'dpy\. 'dp-python-shell-this-window)

(defalias 'dpy0 'dp-python-shell-this-window)

(autoload 'dp-start-term "dp-shells" "\
Start up a terminal session, but first set the coding system so eols are 
handled right.

arguments: (PROMPT-FOR-SHELL-PROGRAM-P)
" t nil)

(autoload 'dp-cterm "dp-shells" "\


arguments: ()
" t nil)

(autoload 'dp-lterm "dp-shells" "\


arguments: ()
" t nil)

(autoload 'dp-shell0 "dp-shells" "\
Open/visit a shell buffer.
First shell is numbered 0 by default.
ARG is numberp:
 ARG is >= 0: switch to that numbered shell.
 ARG is < 0: switch to shell buffer<(abs ARG)>
 ARG memq `dp-shells-shell<0>-names' shell<0> in other window.

arguments: (&optional ARG &key OTHER-WINDOW-P NAME OTHER-FRAME-P)
" t nil)

(autoload 'dp-shell "dp-shells" "\


arguments: (&optional ARG &key OTHER-WINDOW-P NAME OTHER-FRAME-P)
" t nil)

(autoload 'dp-shell-other-window "dp-shells" "\


arguments: (&optional ARG)
" t nil)

(autoload 'dp-gdb-old "dp-shells" "\


arguments: (&optional NEW-P PATH COREFILE)
" t nil)

(autoload 'dp-tack-on-gdb-mode "dp-shells" "\
Major hack to change a shell buffer which is running gdb into a gdb-mode buffer.

arguments: (&optional BUFFER-OR-NAME NEW-BUFFER-NAME)
" t nil)

(autoload 'dp-gdb-naught "dp-shells" "\
Run gdb on nothing. 
Useful for creating a gdb session from which you can attach to another
running process.

arguments: (&optional NAME)
" t nil)

(autoload 'dp-gdb "dp-shells" "\
Extension to gdb that:
. Prefers the most recently used buffer if its process is still live,
. Else it asks for a buffer using a completion list of other gdb buffers,
. Else (or if nothing selected above) it starts a new gdb session.

arguments: (&optional NEW-P PATH COREFILE)
" t nil)

(autoload 'dp-ssh "dp-shells" "\
Find/create a shell buf, an existing ssh buf or create a ssh buf.

arguments: (&optional SHELL-ID)
" t nil)

(autoload 'dp-ssh-gdb "dp-shells" "\


arguments: (SSH-ARGS PATH &optional COREFILE)
" t nil)

;;;***

;;;### (autoloads (dp-dired-sudo-edit dp-sudo-edit-devert dp-sudo-edit-this-file dp-sudo-edit dp-sudo-edit-load-hook) "dp-sudo-edit3" "lisp/dp-sudo-edit3.el")

(defvar dp-sudo-edit-load-hook nil "\
List of functions to be called after the we're loaded.")

(defface dp-sudo-edit-bg-face '((((class color) (background light)) (:background "thistle2"))) "Face for file being sudo edited." :group 'faces :group 'dp-vars)

(autoload 'dp-sudo-edit "dp-sudo-edit3" "\
Edit a file by using sudo to cat the file into a buffer and sudo to cp the edited file over the original.

arguments: (ORIG-FILE-NAME)
" t nil)

(defalias 'dse 'dp-sudo-edit)

(autoload 'dp-sudo-edit-this-file "dp-sudo-edit3" "\
Edit the current buffer w/sudo edit.

arguments: ()
" t nil)

(defalias 'dset 'dp-sudo-edit-this-file)

(defalias 'dse\. 'dp-sudo-edit-this-file)

(autoload 'dp-sudo-edit-devert "dp-sudo-edit3" "\
Stop sudo-editing this file.  Edit it normally.

arguments: ()
" t nil)

(defalias 'dsed 'dp-sudo-edit-devert)

(autoload 'dp-dired-sudo-edit "dp-sudo-edit3" "\
In dired, sudo the file named on this line.

arguments: ()
" t nil)

;;;***

;;;### (autoloads (dp-pb-new-entry) "dp-templates" "lisp/dp-templates.el")

(autoload 'dp-pb-new-entry "dp-templates" "\


arguments: ()
" t nil)

;;;***

(provide 'auto-dp-autoloads)
