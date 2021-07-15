;;; DO NOT MODIFY THIS FILE -*- coding: raw-text-unix -*-
;;;###coding system: raw-text-unix
(if (featurep 'auto-dp-autoloads) (error "Feature auto-dp-autoloads already loaded"))

;;;### (autoloads nil "../lisp/dp-buffer-bg" "../../../../../home/dpanarit/lisp/dp-buffer-bg.el"
;;;;;;  "a9fc3507647a1b8ddf6f93b4bf10b649")
;;; Generated autoloads from ../../../../../home/dpanarit/lisp/dp-buffer-bg.el

(autoload 'dp-buffer-bg-set-color "../lisp/dp-buffer-bg" "\
Add an overlay with background color COLOR to buffer BUFFER.
If COLOR is nil remove previously added overlay.

\(fn COLOR &optional BUFFER &key BEGIN END (widenp t) &allow-other-keys)" t nil)

;;;***

;;;### (autoloads nil "../lisp/dp-colorize-ifdefs" "../../../../../home/dpanarit/lisp/dp-colorize-ifdefs.el"
;;;;;;  "9feca494c3c7c1203d08fdf4b748482a")
;;; Generated autoloads from ../../../../../home/dpanarit/lisp/dp-colorize-ifdefs.el

(autoload 'dp-uncolorize-ifdefs "../lisp/dp-colorize-ifdefs" "\


\(fn &optional BEGIN END)" t nil)

(autoload 'dp-colorize-ifdefs "../lisp/dp-colorize-ifdefs" "\
Colorize parts of ifdef.

\(fn &optional COLORIZE-NESTED)" t nil)

;;;***

;;;### (autoloads nil "../lisp/dp-debug" "../../../../../home/dpanarit/lisp/dp-debug.el"
;;;;;;  "6c7998d695a940fd102bbe08b3f4bbc1")
;;; Generated autoloads from ../../../../../home/dpanarit/lisp/dp-debug.el

(autoload 'dp-hook-message "../lisp/dp-debug" "\


\(fn)" t nil)

(autoload 'dp-hook-insert "../lisp/dp-debug" "\


\(fn)" t nil)

(autoload 'dp-unhook-message "../lisp/dp-debug" "\


\(fn)" t nil)

(autoload 'dp-unhook-insert "../lisp/dp-debug" "\


\(fn)" t nil)

;;;***

;;;### (autoloads nil "../lisp/dp-faces" "../../../../../home/dpanarit/lisp/dp-faces.el"
;;;;;;  "06b13daced2567c95ba7776fcef8d510")
;;; Generated autoloads from ../../../../../home/dpanarit/lisp/dp-faces.el

(autoload 'dp-all-dp*-faces "../lisp/dp-faces" "\


\(fn)" nil nil)

(autoload 'dp-edit-faces "../lisp/dp-faces" "\
Alter face characteristics by editing a list of defined faces.
Pops up a buffer containing a list of defined faces.

WARNING: the changes you may perform with this function are no longer
saved. The prefered way to modify faces is now to use `customize-face'. If you
want to specify particular X font names for faces, please do so in your
.XDefaults file.

Editing commands:

\\{edit-faces-mode-map}

\(fn)" t nil)

;;;***

;;;### (autoloads nil "../lisp/dp-flyspell" "../../../../../home/dpanarit/lisp/dp-flyspell.el"
;;;;;;  "02de9034a584439d3ec663228ec73262")
;;; Generated autoloads from ../../../../../home/dpanarit/lisp/dp-flyspell.el

(autoload 'dp-flyspell-setup0 "../lisp/dp-flyspell" "\


\(fn HOOK-LIST DEFAULT-MODE-FUNC &optional FORCE)" t nil)

(autoload 'dp-flyspell-setup "../lisp/dp-flyspell" "\


\(fn &optional FORCE)" t nil)

(autoload 'dp-flyspell-prog-setup "../lisp/dp-flyspell" "\


\(fn)" t nil)

(autoload 'dp-flyspell-prog-mode "../lisp/dp-flyspell" "\
Put a buffer into `flyspell-prog-mode', with persistent-highlight OFF.
PERSISTENT-HIGHLIGHT-P says to turn on persistent-highlight.

\(fn &optional PERSISTENT-HIGHLIGHT-P)" t nil)

;;;***

;;;### (autoloads nil "../lisp/dp-id-utils" "../../../../../home/dpanarit/lisp/dp-id-utils.el"
;;;;;;  "f3dd03ad2b563844eb3e6772ea30b295")
;;; Generated autoloads from ../../../../../home/dpanarit/lisp/dp-id-utils.el

(autoload 'gid "../lisp/dp-id-utils" "\
Run gid, with user-specified ARGS, and collect output in a buffer.
While gid runs asynchronously, you can use the \\[next-error] command to
find the text that gid hits refer to. The command actually run is
defined by the gid-command variable.

\(fn ARGS)" t nil)

;;;***

;;;### (autoloads nil "../lisp/dp-journal" "../../../../../home/dpanarit/lisp/dp-journal.el"
;;;;;;  "d4ef8ad675d7960a7637a7b3b67fa275")
;;; Generated autoloads from ../../../../../home/dpanarit/lisp/dp-journal.el

(autoload 'dpj-stick-journal-file "../lisp/dp-journal" "\
Ass/2 way to make non-standard journal files a little less unusable.

\(fn &optional FILE-NAME UNSTICK-P DEFAULT-P)" nil nil)

(autoload 'dpj-stick-current-journal-file "../lisp/dp-journal" "\
Ass/2 way to make non-standard journal files a little less unusable.

\(fn &optional UNSTICK-P DEFAULT-P)" t nil)

(autoload 'dpj-grep-and-view-hits "../lisp/dp-journal" "\
Grep topics for regexp and view in view buf.
Search NUMBER-OF-MONTHS files back in time.
Search topics matching TOPIC-RE for GREP-RE.
View all records with matches in a view buf.
START-WITH-CURRENT-JOURNAL-P (interactively the prefix-arg) says to start
the search with the current journal file.

\(fn NUMBER-OF-MONTHS TOPIC-RE GREP-RE &optional (continue-from-last-p nil cflp-set-p))" t nil)

(defalias 'gv 'dpj-grep-and-view-hits)

(defalias 'dg 'dpj-grep-and-view-hits)

(defalias 'jg 'dpj-grep-and-view-hits)

(defalias 'dpj-grep 'dpj-grep-and-view-hits)

(autoload 'dpj-tidy-journals "../lisp/dp-journal" "\
Kill all but the most recent journal buffers.

\(fn &optional DONT-DELETE-P)" t nil)

(autoload 'dpj-tidy-journals-keep "../lisp/dp-journal" "\


\(fn)" t nil)

(autoload 'dpj-chase-link "../lisp/dp-journal" "\
Follow a link to another note.
 !<@todo XXX Make this put the BM in the most recent journal.

\(fn FILE-NAME OFFSET DATE-STRING)" nil nil)

(autoload 'dp-add-elisp-journal-entry "../lisp/dp-journal" "\


\(fn)" t nil)

(dp-safe-alias 'ee 'dp-add-elisp-journal-entry)

(autoload 'dpj-new-topic "../lisp/dp-journal" "\
Insert a new topic item.  Completion is allowed from the list of known topics.

\(fn &key TOPIC NO-SPACED-APPEND-P LINK-TOO-P IS-A-CLONE-P OTHER-WIN-P DIR-NAME)" t nil)

(autoload 'dpj-new-topic-other-window "../lisp/dp-journal" "\


\(fn &key TOPIC NO-SPACED-APPEND-P LINK-TOO-P IS-A-CLONE-P)" t nil)

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

(autoload 'dpj-goto-end-of-journal "../lisp/dp-journal" "\


\(fn)" t nil)

(defalias 'eoj 'dpj-goto-end-of-journal)

(autoload 'dpj-clone-topic "../lisp/dp-journal" "\
Clone the current topic with a new timestamp.
NB: previous topic means the previous SAME topic.
LINK-TOO-P, if non-nil says to link to the previous topic.
LINK-TOO-P, if nil will make a link to the previous topic if it is 
\"far enough away.\"
INSERT-THIS-TEXT is text to insert after the topic is inserted.
Allows for an indication of time flow within a continuing topic or 
continuation of a topic at a later time.

\(fn &optional LINK-TOO-P INSERT-THIS-TEXT LINK-FORWARD-ALSO-P)" t nil)

(defalias 'cxc 'dpj-clone-topic)

(autoload 'dpj-clone-topic-and-link "../lisp/dp-journal" "\
Clone topic and force link to previous topic regardless of distance.

\(fn)" t nil)

(autoload 'cxl "../lisp/dp-journal" "\


\(fn)" t nil)

(autoload 'dpj-mk-external-bookmark "../lisp/dp-journal" "\
Make link a topic @ (or POS (point)) in (or FILE-OR-BUF (current bufer)).

\(fn &optional (pos (point)) (file-or-buf (current-buffer)))" t nil)

(autoload 'dpj-edit-journal-file "../lisp/dp-journal" "\
Edit the journal file.

\(fn FNAME &optional MISSING-FILE-ACTION OTHER-WIN-P)" t nil)

(autoload 'dp-journal "../lisp/dp-journal" "\
Visit a journal file.
If `dpj-current-journal-file' is non-nil, visit that file, otherwise
visit the journal for the current date and set `dpj-current-journal-file'.
OTHER-WIN-P says visit in other window.
GOTO-EOF says go to end of file.
VISIT-LATEST says visit the current journal even if
`dpj-current-journal-file' is non-nil.
RETURN buffer that was visiting the journal, or nil.

\(fn &optional OTHER-WIN-P GOTO-EOF VISIT-LATEST TOPIC)" t nil)

(autoload 'dp-journal2 "../lisp/dp-journal" "\


\(fn)" t nil)

(defalias 'dj 'dp-journal2)

(defalias 'dj2 'dp-journal2)

(defalias 'dj1 'dp-journal)

(defalias 'dj0 'dp-journal)

(defalias 'dj\. 'dp-journal)

(defalias 'djd 'dp-journal)

(autoload 'dp-journal-one-window "../lisp/dp-journal" "\
Journal in a single window.

\(fn)" t nil)

(dp-defaliases 'dj1 'dj0 'djone 'djo 'dp-journal-one-window)

(autoload 'dpj-visit-other-journal-file "../lisp/dp-journal" "\
Visit FILE-NAME as journal and make it sticky to the current buffer.
This kind of allows us to use a journal file with a non-standard name.

\(fn FILE-NAME &optional OTHER-WINDOW-P)" t nil)

(when (dp-xemacs-p) (defvar dpj-menubutton-guts [dp-journal :active (fboundp 'dp-journal)] "Menu button to activate journal.") (defvar dpj-menubar-button (vconcat ["Dj"] dpj-menubutton-guts) "Journal menubar button.") (defvar dpj-menu-button-added nil "Non nil if we've already added the menu-button.") (unless dpj-menu-button-added (add-menu-button nil dpj-menubar-button nil default-menubar) (setq dpj-menu-button-added t)))

(autoload 'dp-journal-mode "../lisp/dp-journal" "\
Major mode for editing journals.

\(fn)" t nil)

(autoload 'dpj-setup-invisibility "../lisp/dp-journal" "\
Make a nice glyph for invisible text regions.

\(fn)" t nil)

;;;***

;;;### (autoloads nil "../lisp/dp-sel2" "../../../../../home/dpanarit/lisp/dp-sel2.el"
;;;;;;  "f0baf803530861a8adede7a722067477")
;;; Generated autoloads from ../../../../../home/dpanarit/lisp/dp-sel2.el

(autoload 'dp-sel2:paste "../lisp/dp-sel2" "\
Select the item to paste from a list.
Rotate kill list so that the selected kill-text is at the head of the
yank ring.

\(fn &optional GOTO-EMBEDDED-P)" t nil)

(autoload 'dp-sel2:bm "../lisp/dp-sel2" "\
Select a bookmark to which to jump.

\(fn &optional IGNORE-EMBEDDED-BOOKMARKS-P)" t nil)

;;;***

;;;### (autoloads nil "../lisp/dp-shells" "../../../../../home/dpanarit/lisp/dp-shells.el"
;;;;;;  "a787772a031990b8a4e0f9c3bb226198")
;;; Generated autoloads from ../../../../../home/dpanarit/lisp/dp-shells.el

(defvar shell-uninteresting-face 'shell-uninteresting-face "\
Face for shell output which is uninteresting.
Should be a color which nearly blends into background.")

(custom-autoload 'shell-uninteresting-face "../lisp/dp-shells" t)

(autoload 'dp-shells-mk-prompt-font-lock-regexp "../lisp/dp-shells" "\


\(fn &optional REGEXP-LIST)" nil nil)

(defvar dp-shells-prompt-font-lock-regexp "^\\([0-9]+\\)\\(/\\(?:[0-9]+\\|spayshul\\)\\)\\([#>]\\|\\(<[0-9]*>\\)?\\)" "\
*Regular expression to match my shell prompt.  Used for font locking.
For my multi-line prompt, this is second line.  For most prompts, this will
be the only line.  Some shells, like IPython's, already colorize their
prompt.  We don't want to stomp on them.")

(eval-after-load "shell" '(progn (setq shell-prompt-pattern-for-font-lock dp-shells-prompt-font-lock-regexp)))

(autoload 'dp-comint-mode-hook "../lisp/dp-shells" "\
Sets up personal comint mode options.
Called when shell, inferior-lisp-process, etc. are entered.

\(fn &optional (variant dp-default-variant))" t nil)

(autoload 'dp-shell-mode-hook "../lisp/dp-shells" "\
Sets up shell mode specific options.

\(fn &optional (variant dp-default-variant))" t nil)

(autoload 'dp-telnet-mode-hook "../lisp/dp-shells" "\
Sets up telnet mode specific options.

\(fn)" nil nil)

(autoload 'dp-compilation-mode-hook "../lisp/dp-shells" "\


\(fn)" nil nil)

(autoload 'dp-set-current-error-function "../lisp/dp-shells" "\


\(fn FUNC USE-NO-ARGS-P &rest ARGS)" t nil)

(autoload 'dp-reset-current-error-function "../lisp/dp-shells" "\


\(fn)" t nil)

(autoload 'dp-set-compile-like-mode-error-function "../lisp/dp-shells" "\


\(fn)" t nil)

(autoload 'dp-next-error "../lisp/dp-shells" "\
Find next error in shell buffer.
This key is globally bound.  It does special things only if it is
invoked inside a shell type buffer.  In this case, it ensures the
buffer is in compilation minor-mode and reparses errors if it detects
that a new command has been sent since the last parse.
KILL-BUFFER-FIRST-P says to kill the current buffer first. Useful when
examining a bunch of hits in a bunch of files to prevent ending up with tons
of open files.
NB! KILL-BUFFER-FIRST-P does not work. Don't use it. Seriously.

\(fn &optional KILL-BUFFER-FIRST-P)" t nil)

(autoload 'dp-cscope-next-thing "../lisp/dp-shells" "\


\(fn FUNC)" t nil)

(autoload 'dp-shell-goto-this-error "../lisp/dp-shells" "\
Goto the error at point in the shell buffer.  
This has the fortunate side effect of setting 
things up so that dp-next-error (\\[dp-next-error]) 
picks up right after the error we just visited.
We use this instead of just `compile-goto-error' so that
we can goto errors anywhere in the buffer, especially 
earlier in the buffer. `compile-goto-error' has a 
very (too) forward looking view of parsing error buffers.

\(fn &optional FORCE-REPARSE-P)" t nil)

(autoload 'dp-py-shell-hook "../lisp/dp-shells" "\
Set up my python shell mode fiddle-faddle.

\(fn)" t nil)

(autoload 'dp-gdb-mode-hook "../lisp/dp-shells" "\
Set up my gdb shell mode fiddle-faddle.

\(fn)" t nil)

(autoload 'dp-ssh-mode-hook "../lisp/dp-shells" "\
Set up my ssh shell mode fiddle-faddle.

\(fn)" t nil)

(autoload 'dp-python-shell "../lisp/dp-shells" "\
Start up python shell and then run my shell-mode-hook since they
set the key-map after the hook has run.

\(fn &optional ARGS)" t nil)

(defalias 'dpy 'dp-python-shell)

(defsubst dp-python-shell-this-window (&optional args) "\
Try to put the shell in the current window." (interactive "P") (dp-python-shell) (dp-slide-window-right 1))

(defalias 'dpyd 'dp-python-shell-this-window)

(defalias 'dpy\. 'dp-python-shell-this-window)

(defalias 'dpy0 'dp-python-shell-this-window)

(autoload 'dp-start-term "../lisp/dp-shells" "\
Start up a terminal session, but first set the coding system so eols are 
handled right.

\(fn PROMPT-FOR-SHELL-PROGRAM-P)" t nil)

(autoload 'dp-shell0 "../lisp/dp-shells" "\
Open/visit a shell buffer.
First shell is numbered 1 by default. 0 is too far away from the others. Save
it for something \"speshul\".
 ARG is numberp:
 ARG is >= 0: switch to that numbered shell.
 ARG is < 0: switch to shell buffer<(abs ARG)>
 ARG memq `dp-shells-primary-shell-names' shell<0> in other window.

\(fn &optional ARG &key OTHER-WINDOW-P NAME OTHER-FRAME-P)" t nil)

(autoload 'dp-shell "../lisp/dp-shells" "\


\(fn &optional ARG &key OTHER-WINDOW-P NAME OTHER-FRAME-P)" t nil)

(autoload 'dp-shell-other-window "../lisp/dp-shells" "\


\(fn &optional ARG)" t nil)

(defvar dp-gdb-file-history 'nil "\
Files on which we've run `dp-gdb'.")

(autoload 'dp-tack-on-gdb-mode "../lisp/dp-shells" "\
Major hack to change a shell buffer which is running gdb into a gdb-mode buffer.

\(fn &optional BUFFER-OR-NAME NEW-BUFFER-NAME)" t nil)

(autoload 'dp-gdb-naught "../lisp/dp-shells" "\
Run gdb on nothing. 
Useful for creating a gdb session from which you can attach to another
running process.

\(fn &optional NAME)" t nil)

(autoload 'dp-gdb "../lisp/dp-shells" "\
Extension to gdb that:
. Prefers the most recently used buffer if its process is still live,
. Else it asks for a buffer using a completion list of other gdb buffers,
. Else (or if nothing selected above) it starts a new gdb session.
ARG == nil  --> Use most recent session
ARG == '(4) --> Prompt for buffer
ARG == '-   --> Create new session
ARG == 0    --> New `dp-gdb-naught' session.

\(fn &optional INTERACTIVE-ONLY-ARG PATH COREFILE USE-MOST-RECENT-P NEW-P PROMPT-P OTHER-WINDOW-P FORCE-INTERACTIVE-P)" t nil)

(autoload 'dp-gdb-other-window "../lisp/dp-shells" "\


\(fn &rest R)" t nil)

(autoload 'dp-ssh "../lisp/dp-shells" "\
Find/create a shell buf, an existing ssh buf or create a ssh buf.

\(fn &optional SHELL-ID)" t nil)

(autoload 'dp-ssh-gdb "../lisp/dp-shells" "\


\(fn SSH-ARGS PATH &optional COREFILE)" t nil)

;;;***

;;;### (autoloads nil "../lisp/dp-sudo-edit3" "../../../../../home/dpanarit/lisp/dp-sudo-edit3.el"
;;;;;;  "35f98361101a5ce960caf21d2590f10a")
;;; Generated autoloads from ../../../../../home/dpanarit/lisp/dp-sudo-edit3.el

(defvar dp-sudo-edit-load-hook nil "\
List of functions to be called after the we're loaded.")

(custom-autoload 'dp-sudo-edit-load-hook "../lisp/dp-sudo-edit3" t)

(defface dp-sudo-edit-bg-face '((((class color) (background light)) (:background "pink"))) "\
Face for file being sudo edited." :group (quote faces) :group (quote dp-vars))

(autoload 'dp-sudo-edit "../lisp/dp-sudo-edit3" "\
Edit a file by using sudo to cat the file into a buffer and sudo to cp the edited file over the original.

\(fn ORIG-FILE-NAME)" t nil)

(autoload 'dp-sudo-edit-this-file "../lisp/dp-sudo-edit3" "\
Edit the current buffer w/sudo edit.

\(fn)" t nil)

(autoload 'dp-sudo-edit-devert "../lisp/dp-sudo-edit3" "\
Stop sudo-editing this file.  Edit it normally.

\(fn)" t nil)

(dp-defaliases 'ddse 'dedse 'dsed 'devert 'dp-sudo-edit-devert)

(autoload 'dp-dired-sudo-edit "../lisp/dp-sudo-edit3" "\
In dired, sudo the file named on this line.

\(fn)" t nil)

;;;***

;;;### (autoloads nil "../lisp/dp-templates" "../../../../../home/dpanarit/lisp/dp-templates.el"
;;;;;;  "0f0538726e5c3a777f66fdb91eb04bbe")
;;; Generated autoloads from ../../../../../home/dpanarit/lisp/dp-templates.el

(autoload 'dp-pb-new-entry "../lisp/dp-templates" "\


\(fn)" t nil)

;;;***

;;;### (autoloads nil "dp-buffer-bg" "../../../../../home/dpanarit/flisp/dp-buffer-bg.el"
;;;;;;  "a9fc3507647a1b8ddf6f93b4bf10b649")
;;; Generated autoloads from ../../../../../home/dpanarit/flisp/dp-buffer-bg.el

(autoload 'dp-buffer-bg-set-color "dp-buffer-bg" "\
Add an overlay with background color COLOR to buffer BUFFER.
If COLOR is nil remove previously added overlay.

\(fn COLOR &optional BUFFER &key BEGIN END (widenp t) &allow-other-keys)" t nil)

;;;***

;;;### (autoloads nil "dp-colorize-ifdefs" "../../../../../home/dpanarit/flisp/dp-colorize-ifdefs.el"
;;;;;;  "9feca494c3c7c1203d08fdf4b748482a")
;;; Generated autoloads from ../../../../../home/dpanarit/flisp/dp-colorize-ifdefs.el

(autoload 'dp-uncolorize-ifdefs "dp-colorize-ifdefs" "\


\(fn &optional BEGIN END)" t nil)

(autoload 'dp-colorize-ifdefs "dp-colorize-ifdefs" "\
Colorize parts of ifdef.

\(fn &optional COLORIZE-NESTED)" t nil)

;;;***

;;;### (autoloads nil "dp-debug" "../../../../../home/dpanarit/flisp/dp-debug.el"
;;;;;;  "6c7998d695a940fd102bbe08b3f4bbc1")
;;; Generated autoloads from ../../../../../home/dpanarit/flisp/dp-debug.el

(autoload 'dp-hook-message "dp-debug" "\


\(fn)" t nil)

(autoload 'dp-hook-insert "dp-debug" "\


\(fn)" t nil)

(autoload 'dp-unhook-message "dp-debug" "\


\(fn)" t nil)

(autoload 'dp-unhook-insert "dp-debug" "\


\(fn)" t nil)

;;;***

;;;### (autoloads nil "dp-faces" "../../../../../home/dpanarit/flisp/dp-faces.el"
;;;;;;  "06b13daced2567c95ba7776fcef8d510")
;;; Generated autoloads from ../../../../../home/dpanarit/flisp/dp-faces.el

(autoload 'dp-all-dp*-faces "dp-faces" "\


\(fn)" nil nil)

(autoload 'dp-edit-faces "dp-faces" "\
Alter face characteristics by editing a list of defined faces.
Pops up a buffer containing a list of defined faces.

WARNING: the changes you may perform with this function are no longer
saved. The prefered way to modify faces is now to use `customize-face'. If you
want to specify particular X font names for faces, please do so in your
.XDefaults file.

Editing commands:

\\{edit-faces-mode-map}

\(fn)" t nil)

;;;***

;;;### (autoloads nil "dp-flyspell" "../../../../../home/dpanarit/flisp/dp-flyspell.el"
;;;;;;  "02de9034a584439d3ec663228ec73262")
;;; Generated autoloads from ../../../../../home/dpanarit/flisp/dp-flyspell.el

(autoload 'dp-flyspell-setup0 "dp-flyspell" "\


\(fn HOOK-LIST DEFAULT-MODE-FUNC &optional FORCE)" t nil)

(autoload 'dp-flyspell-setup "dp-flyspell" "\


\(fn &optional FORCE)" t nil)

(autoload 'dp-flyspell-prog-setup "dp-flyspell" "\


\(fn)" t nil)

(autoload 'dp-flyspell-prog-mode "dp-flyspell" "\
Put a buffer into `flyspell-prog-mode', with persistent-highlight OFF.
PERSISTENT-HIGHLIGHT-P says to turn on persistent-highlight.

\(fn &optional PERSISTENT-HIGHLIGHT-P)" t nil)

;;;***

;;;### (autoloads nil "dp-id-utils" "../../../../../home/dpanarit/flisp/dp-id-utils.el"
;;;;;;  "f3dd03ad2b563844eb3e6772ea30b295")
;;; Generated autoloads from ../../../../../home/dpanarit/flisp/dp-id-utils.el

(autoload 'gid "dp-id-utils" "\
Run gid, with user-specified ARGS, and collect output in a buffer.
While gid runs asynchronously, you can use the \\[next-error] command to
find the text that gid hits refer to. The command actually run is
defined by the gid-command variable.

\(fn ARGS)" t nil)

;;;***

;;;### (autoloads nil "dp-journal" "../../../../../home/dpanarit/flisp/dp-journal.el"
;;;;;;  "d4ef8ad675d7960a7637a7b3b67fa275")
;;; Generated autoloads from ../../../../../home/dpanarit/flisp/dp-journal.el

(autoload 'dpj-stick-journal-file "dp-journal" "\
Ass/2 way to make non-standard journal files a little less unusable.

\(fn &optional FILE-NAME UNSTICK-P DEFAULT-P)" nil nil)

(autoload 'dpj-stick-current-journal-file "dp-journal" "\
Ass/2 way to make non-standard journal files a little less unusable.

\(fn &optional UNSTICK-P DEFAULT-P)" t nil)

(autoload 'dpj-grep-and-view-hits "dp-journal" "\
Grep topics for regexp and view in view buf.
Search NUMBER-OF-MONTHS files back in time.
Search topics matching TOPIC-RE for GREP-RE.
View all records with matches in a view buf.
START-WITH-CURRENT-JOURNAL-P (interactively the prefix-arg) says to start
the search with the current journal file.

\(fn NUMBER-OF-MONTHS TOPIC-RE GREP-RE &optional (continue-from-last-p nil cflp-set-p))" t nil)

(defalias 'gv 'dpj-grep-and-view-hits)

(defalias 'dg 'dpj-grep-and-view-hits)

(defalias 'jg 'dpj-grep-and-view-hits)

(defalias 'dpj-grep 'dpj-grep-and-view-hits)

(autoload 'dpj-tidy-journals "dp-journal" "\
Kill all but the most recent journal buffers.

\(fn &optional DONT-DELETE-P)" t nil)

(autoload 'dpj-tidy-journals-keep "dp-journal" "\


\(fn)" t nil)

(autoload 'dpj-chase-link "dp-journal" "\
Follow a link to another note.
 !<@todo XXX Make this put the BM in the most recent journal.

\(fn FILE-NAME OFFSET DATE-STRING)" nil nil)

(autoload 'dp-add-elisp-journal-entry "dp-journal" "\


\(fn)" t nil)

(dp-safe-alias 'ee 'dp-add-elisp-journal-entry)

(autoload 'dpj-new-topic "dp-journal" "\
Insert a new topic item.  Completion is allowed from the list of known topics.

\(fn &key TOPIC NO-SPACED-APPEND-P LINK-TOO-P IS-A-CLONE-P OTHER-WIN-P DIR-NAME)" t nil)

(autoload 'dpj-new-topic-other-window "dp-journal" "\


\(fn &key TOPIC NO-SPACED-APPEND-P LINK-TOO-P IS-A-CLONE-P)" t nil)

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


\(fn)" t nil)

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

\(fn &optional LINK-TOO-P INSERT-THIS-TEXT LINK-FORWARD-ALSO-P)" t nil)

(defalias 'cxc 'dpj-clone-topic)

(autoload 'dpj-clone-topic-and-link "dp-journal" "\
Clone topic and force link to previous topic regardless of distance.

\(fn)" t nil)

(autoload 'cxl "dp-journal" "\


\(fn)" t nil)

(autoload 'dpj-mk-external-bookmark "dp-journal" "\
Make link a topic @ (or POS (point)) in (or FILE-OR-BUF (current bufer)).

\(fn &optional (pos (point)) (file-or-buf (current-buffer)))" t nil)

(autoload 'dpj-edit-journal-file "dp-journal" "\
Edit the journal file.

\(fn FNAME &optional MISSING-FILE-ACTION OTHER-WIN-P)" t nil)

(autoload 'dp-journal "dp-journal" "\
Visit a journal file.
If `dpj-current-journal-file' is non-nil, visit that file, otherwise
visit the journal for the current date and set `dpj-current-journal-file'.
OTHER-WIN-P says visit in other window.
GOTO-EOF says go to end of file.
VISIT-LATEST says visit the current journal even if
`dpj-current-journal-file' is non-nil.
RETURN buffer that was visiting the journal, or nil.

\(fn &optional OTHER-WIN-P GOTO-EOF VISIT-LATEST TOPIC)" t nil)

(autoload 'dp-journal2 "dp-journal" "\


\(fn)" t nil)

(defalias 'dj 'dp-journal2)

(defalias 'dj2 'dp-journal2)

(defalias 'dj1 'dp-journal)

(defalias 'dj0 'dp-journal)

(defalias 'dj\. 'dp-journal)

(defalias 'djd 'dp-journal)

(autoload 'dp-journal-one-window "dp-journal" "\
Journal in a single window.

\(fn)" t nil)

(dp-defaliases 'dj1 'dj0 'djone 'djo 'dp-journal-one-window)

(autoload 'dpj-visit-other-journal-file "dp-journal" "\
Visit FILE-NAME as journal and make it sticky to the current buffer.
This kind of allows us to use a journal file with a non-standard name.

\(fn FILE-NAME &optional OTHER-WINDOW-P)" t nil)

(when (dp-xemacs-p) (defvar dpj-menubutton-guts [dp-journal :active (fboundp 'dp-journal)] "Menu button to activate journal.") (defvar dpj-menubar-button (vconcat ["Dj"] dpj-menubutton-guts) "Journal menubar button.") (defvar dpj-menu-button-added nil "Non nil if we've already added the menu-button.") (unless dpj-menu-button-added (add-menu-button nil dpj-menubar-button nil default-menubar) (setq dpj-menu-button-added t)))

(autoload 'dp-journal-mode "dp-journal" "\
Major mode for editing journals.

\(fn)" t nil)

(autoload 'dpj-setup-invisibility "dp-journal" "\
Make a nice glyph for invisible text regions.

\(fn)" t nil)

;;;***

;;;### (autoloads nil "dp-sel2" "../../../../../home/dpanarit/flisp/dp-sel2.el"
;;;;;;  "f0baf803530861a8adede7a722067477")
;;; Generated autoloads from ../../../../../home/dpanarit/flisp/dp-sel2.el

(autoload 'dp-sel2:paste "dp-sel2" "\
Select the item to paste from a list.
Rotate kill list so that the selected kill-text is at the head of the
yank ring.

\(fn &optional GOTO-EMBEDDED-P)" t nil)

(autoload 'dp-sel2:bm "dp-sel2" "\
Select a bookmark to which to jump.

\(fn &optional IGNORE-EMBEDDED-BOOKMARKS-P)" t nil)

;;;***

;;;### (autoloads nil "dp-shells" "../../../../../home/dpanarit/flisp/dp-shells.el"
;;;;;;  "a787772a031990b8a4e0f9c3bb226198")
;;; Generated autoloads from ../../../../../home/dpanarit/flisp/dp-shells.el

(defvar shell-uninteresting-face 'shell-uninteresting-face "\
Face for shell output which is uninteresting.
Should be a color which nearly blends into background.")

(custom-autoload 'shell-uninteresting-face "dp-shells" t)

(autoload 'dp-shells-mk-prompt-font-lock-regexp "dp-shells" "\


\(fn &optional REGEXP-LIST)" nil nil)

(defvar dp-shells-prompt-font-lock-regexp "^\\([0-9]+\\)\\(/\\(?:[0-9]+\\|spayshul\\)\\)\\([#>]\\|\\(<[0-9]*>\\)?\\)" "\
*Regular expression to match my shell prompt.  Used for font locking.
For my multi-line prompt, this is second line.  For most prompts, this will
be the only line.  Some shells, like IPython's, already colorize their
prompt.  We don't want to stomp on them.")

(eval-after-load "shell" '(progn (setq shell-prompt-pattern-for-font-lock dp-shells-prompt-font-lock-regexp)))

(autoload 'dp-comint-mode-hook "dp-shells" "\
Sets up personal comint mode options.
Called when shell, inferior-lisp-process, etc. are entered.

\(fn &optional (variant dp-default-variant))" t nil)

(autoload 'dp-shell-mode-hook "dp-shells" "\
Sets up shell mode specific options.

\(fn &optional (variant dp-default-variant))" t nil)

(autoload 'dp-telnet-mode-hook "dp-shells" "\
Sets up telnet mode specific options.

\(fn)" nil nil)

(autoload 'dp-compilation-mode-hook "dp-shells" "\


\(fn)" nil nil)

(autoload 'dp-set-current-error-function "dp-shells" "\


\(fn FUNC USE-NO-ARGS-P &rest ARGS)" t nil)

(autoload 'dp-reset-current-error-function "dp-shells" "\


\(fn)" t nil)

(autoload 'dp-set-compile-like-mode-error-function "dp-shells" "\


\(fn)" t nil)

(autoload 'dp-next-error "dp-shells" "\
Find next error in shell buffer.
This key is globally bound.  It does special things only if it is
invoked inside a shell type buffer.  In this case, it ensures the
buffer is in compilation minor-mode and reparses errors if it detects
that a new command has been sent since the last parse.
KILL-BUFFER-FIRST-P says to kill the current buffer first. Useful when
examining a bunch of hits in a bunch of files to prevent ending up with tons
of open files.
NB! KILL-BUFFER-FIRST-P does not work. Don't use it. Seriously.

\(fn &optional KILL-BUFFER-FIRST-P)" t nil)

(autoload 'dp-cscope-next-thing "dp-shells" "\


\(fn FUNC)" t nil)

(autoload 'dp-shell-goto-this-error "dp-shells" "\
Goto the error at point in the shell buffer.  
This has the fortunate side effect of setting 
things up so that dp-next-error (\\[dp-next-error]) 
picks up right after the error we just visited.
We use this instead of just `compile-goto-error' so that
we can goto errors anywhere in the buffer, especially 
earlier in the buffer. `compile-goto-error' has a 
very (too) forward looking view of parsing error buffers.

\(fn &optional FORCE-REPARSE-P)" t nil)

(autoload 'dp-py-shell-hook "dp-shells" "\
Set up my python shell mode fiddle-faddle.

\(fn)" t nil)

(autoload 'dp-gdb-mode-hook "dp-shells" "\
Set up my gdb shell mode fiddle-faddle.

\(fn)" t nil)

(autoload 'dp-ssh-mode-hook "dp-shells" "\
Set up my ssh shell mode fiddle-faddle.

\(fn)" t nil)

(autoload 'dp-python-shell "dp-shells" "\
Start up python shell and then run my shell-mode-hook since they
set the key-map after the hook has run.

\(fn &optional ARGS)" t nil)

(defalias 'dpy 'dp-python-shell)

(defsubst dp-python-shell-this-window (&optional args) "\
Try to put the shell in the current window." (interactive "P") (dp-python-shell) (dp-slide-window-right 1))

(defalias 'dpyd 'dp-python-shell-this-window)

(defalias 'dpy\. 'dp-python-shell-this-window)

(defalias 'dpy0 'dp-python-shell-this-window)

(autoload 'dp-start-term "dp-shells" "\
Start up a terminal session, but first set the coding system so eols are 
handled right.

\(fn PROMPT-FOR-SHELL-PROGRAM-P)" t nil)

(autoload 'dp-shell0 "dp-shells" "\
Open/visit a shell buffer.
First shell is numbered 1 by default. 0 is too far away from the others. Save
it for something \"speshul\".
 ARG is numberp:
 ARG is >= 0: switch to that numbered shell.
 ARG is < 0: switch to shell buffer<(abs ARG)>
 ARG memq `dp-shells-primary-shell-names' shell<0> in other window.

\(fn &optional ARG &key OTHER-WINDOW-P NAME OTHER-FRAME-P)" t nil)

(autoload 'dp-shell "dp-shells" "\


\(fn &optional ARG &key OTHER-WINDOW-P NAME OTHER-FRAME-P)" t nil)

(autoload 'dp-shell-other-window "dp-shells" "\


\(fn &optional ARG)" t nil)

(defvar dp-gdb-file-history 'nil "\
Files on which we've run `dp-gdb'.")

(autoload 'dp-tack-on-gdb-mode "dp-shells" "\
Major hack to change a shell buffer which is running gdb into a gdb-mode buffer.

\(fn &optional BUFFER-OR-NAME NEW-BUFFER-NAME)" t nil)

(autoload 'dp-gdb-naught "dp-shells" "\
Run gdb on nothing. 
Useful for creating a gdb session from which you can attach to another
running process.

\(fn &optional NAME)" t nil)

(autoload 'dp-gdb "dp-shells" "\
Extension to gdb that:
. Prefers the most recently used buffer if its process is still live,
. Else it asks for a buffer using a completion list of other gdb buffers,
. Else (or if nothing selected above) it starts a new gdb session.
ARG == nil  --> Use most recent session
ARG == '(4) --> Prompt for buffer
ARG == '-   --> Create new session
ARG == 0    --> New `dp-gdb-naught' session.

\(fn &optional INTERACTIVE-ONLY-ARG PATH COREFILE USE-MOST-RECENT-P NEW-P PROMPT-P OTHER-WINDOW-P FORCE-INTERACTIVE-P)" t nil)

(autoload 'dp-gdb-other-window "dp-shells" "\


\(fn &rest R)" t nil)

(autoload 'dp-ssh "dp-shells" "\
Find/create a shell buf, an existing ssh buf or create a ssh buf.

\(fn &optional SHELL-ID)" t nil)

(autoload 'dp-ssh-gdb "dp-shells" "\


\(fn SSH-ARGS PATH &optional COREFILE)" t nil)

;;;***

;;;### (autoloads nil "dp-sudo-edit3" "../../../../../home/dpanarit/flisp/dp-sudo-edit3.el"
;;;;;;  "35f98361101a5ce960caf21d2590f10a")
;;; Generated autoloads from ../../../../../home/dpanarit/flisp/dp-sudo-edit3.el

(defvar dp-sudo-edit-load-hook nil "\
List of functions to be called after the we're loaded.")

(custom-autoload 'dp-sudo-edit-load-hook "dp-sudo-edit3" t)

(defface dp-sudo-edit-bg-face '((((class color) (background light)) (:background "pink"))) "\
Face for file being sudo edited." :group (quote faces) :group (quote dp-vars))

(autoload 'dp-sudo-edit "dp-sudo-edit3" "\
Edit a file by using sudo to cat the file into a buffer and sudo to cp the edited file over the original.

\(fn ORIG-FILE-NAME)" t nil)

(autoload 'dp-sudo-edit-this-file "dp-sudo-edit3" "\
Edit the current buffer w/sudo edit.

\(fn)" t nil)

(autoload 'dp-sudo-edit-devert "dp-sudo-edit3" "\
Stop sudo-editing this file.  Edit it normally.

\(fn)" t nil)

(dp-defaliases 'ddse 'dedse 'dsed 'devert 'dp-sudo-edit-devert)

(autoload 'dp-dired-sudo-edit "dp-sudo-edit3" "\
In dired, sudo the file named on this line.

\(fn)" t nil)

;;;***

;;;### (autoloads nil "dp-templates" "../../../../../home/dpanarit/flisp/dp-templates.el"
;;;;;;  "0f0538726e5c3a777f66fdb91eb04bbe")
;;; Generated autoloads from ../../../../../home/dpanarit/flisp/dp-templates.el

(autoload 'dp-pb-new-entry "dp-templates" "\


\(fn)" t nil)

;;;***

;;;### (autoloads nil nil ("../../../../../home/dpanarit/flisp/auto-dp-autoloads.el"
;;;;;;  "../../../../../home/dpanarit/flisp/bubba-theme.el" "../../../../../home/dpanarit/flisp/buff-menu-junk.el"
;;;;;;  "../../../../../home/dpanarit/flisp/custom.amd.el" "../../../../../home/dpanarit/flisp/custom.el"
;;;;;;  "../../../../../home/dpanarit/flisp/custom.intel.el" "../../../../../home/dpanarit/flisp/custom.lrl.el"
;;;;;;  "../../../../../home/dpanarit/flisp/custom.other.el" "../../../../../home/dpanarit/flisp/custom.permabit.el"
;;;;;;  "../../../../../home/dpanarit/flisp/custom.skaion.el" "../../../../../home/dpanarit/flisp/custom.vanu.el"
;;;;;;  "../../../../../home/dpanarit/flisp/custom.vilya.el" "../../../../../home/dpanarit/flisp/davep1-theme.el"
;;;;;;  "../../../../../home/dpanarit/flisp/default-list-buffers-identification.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-abbrev-defs.el" "../../../../../home/dpanarit/flisp/dp-abbrev.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-adwaita0-theme.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-appt.el" "../../../../../home/dpanarit/flisp/dp-blm-keys.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-bookmarks.el" "../../../../../home/dpanarit/flisp/dp-buffer-bg.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-buffer-local-keys.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-buffer-menu.el" "../../../../../home/dpanarit/flisp/dp-c-like-styles.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-cal.el" "../../../../../home/dpanarit/flisp/dp-cedet-hacks.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-cf.el" "../../../../../home/dpanarit/flisp/dp-colorization-xemacs.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-colorization.el" "../../../../../home/dpanarit/flisp/dp-colorize-ifdefs.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-common-abbrevs-orig.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-common-abbrevs.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-compat.el" "../../../../../home/dpanarit/flisp/dp-debug.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-deps.el" "../../../../../home/dpanarit/flisp/dp-dict.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.HOME_BOX_0.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.amd.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.baloo.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.chele.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.el" "../../../../../home/dpanarit/flisp/dp-dot-emacs.grape01.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.hob.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.huan.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.intel.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.lrl.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.nvidia.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.permabit.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.sam.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.skaion.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.sybil.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.vanu.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-emacs.vilya.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-gnus.el" "../../../../../home/dpanarit/flisp/dp-dot-mew.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-dot-vm.el" "../../../../../home/dpanarit/flisp/dp-emms.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-ephemeral.el" "../../../../../home/dpanarit/flisp/dp-errors.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-faces.el" "../../../../../home/dpanarit/flisp/dp-flyspell.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-fsf-button-compat.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-fsf-early.el" "../../../../../home/dpanarit/flisp/dp-fsf-fsf-compat.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-fsf.el" "../../../../../home/dpanarit/flisp/dp-hooks.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-id-utils.el" "../../../../../home/dpanarit/flisp/dp-ilisp.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-init-early.el" "../../../../../home/dpanarit/flisp/dp-journal.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-keys.el" "../../../../../home/dpanarit/flisp/dp-lang-c-like.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-lang.el" "../../../../../home/dpanarit/flisp/dp-macros.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-mail.el" "../../../../../home/dpanarit/flisp/dp-makefile-mode.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-mew-config.el" "../../../../../home/dpanarit/flisp/dp-mew.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-mhe.el" "../../../../../home/dpanarit/flisp/dp-mmm.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-new-mew.el" "../../../../../home/dpanarit/flisp/dp-open-newline.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-org.el" "../../../../../home/dpanarit/flisp/dp-patches-for-testing.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-pdoc.el" "../../../../../home/dpanarit/flisp/dp-perforce.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-portage.el" "../../../../../home/dpanarit/flisp/dp-ptools.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-regexp.el" "../../../../../home/dpanarit/flisp/dp-sel2.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-server.el" "../../../../../home/dpanarit/flisp/dp-shells.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-sudo-edit3.el" "../../../../../home/dpanarit/flisp/dp-supercite.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-templates.el" "../../../../../home/dpanarit/flisp/dp-time.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-timeclock.el" "../../../../../home/dpanarit/flisp/dp-vars.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-vc.el" "../../../../../home/dpanarit/flisp/dp-xemacs-buffer-local-keys.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-xemacs-colorization.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-xemacs-early.el" "../../../../../home/dpanarit/flisp/dp-xemacs-extents.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-xemacs-fsf-compat.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp-xemacs-late.el" "../../../../../home/dpanarit/flisp/dp0-theme.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dp1-theme.el" "../../../../../home/dpanarit/flisp/dpmacs.el"
;;;;;;  "../../../../../home/dpanarit/flisp/dpmisc.el" "../../../../../home/dpanarit/flisp/fsf-custom-dp-colorize-broken-due-to-dark-themes-because-my-faces-declare-light-backgrounds.el"
;;;;;;  "../../../../../home/dpanarit/flisp/fsf-custom-dp-colorize-old-works-with-light-themes.el"
;;;;;;  "../../../../../home/dpanarit/flisp/fsf-custom-from-work+home-changes-that-effed-things-up.tmp.flisp.10.el"
;;;;;;  "../../../../../home/dpanarit/flisp/fsf-custom.el" "../../../../../home/dpanarit/flisp/fsf-init.el"
;;;;;;  "../../../../../home/dpanarit/flisp/hdr.el" "../../../../../home/dpanarit/flisp/init.el"
;;;;;;  "../../../../../home/dpanarit/flisp/public-dot-mew.el" "../../../../../home/dpanarit/flisp/srecode-map.el"
;;;;;;  "../../../../../home/dpanarit/lisp/bubba-theme.el" "../../../../../home/dpanarit/lisp/buff-menu-junk.el"
;;;;;;  "../../../../../home/dpanarit/lisp/custom.amd.el" "../../../../../home/dpanarit/lisp/custom.el"
;;;;;;  "../../../../../home/dpanarit/lisp/custom.intel.el" "../../../../../home/dpanarit/lisp/custom.lrl.el"
;;;;;;  "../../../../../home/dpanarit/lisp/custom.other.el" "../../../../../home/dpanarit/lisp/custom.permabit.el"
;;;;;;  "../../../../../home/dpanarit/lisp/custom.skaion.el" "../../../../../home/dpanarit/lisp/custom.vanu.el"
;;;;;;  "../../../../../home/dpanarit/lisp/custom.vilya.el" "../../../../../home/dpanarit/lisp/davep1-theme.el"
;;;;;;  "../../../../../home/dpanarit/lisp/default-list-buffers-identification.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-abbrev-defs.el" "../../../../../home/dpanarit/lisp/dp-abbrev.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-adwaita0-theme.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-appt.el" "../../../../../home/dpanarit/lisp/dp-blm-keys.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-bookmarks.el" "../../../../../home/dpanarit/lisp/dp-buffer-bg.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-buffer-bg.el" "../../../../../home/dpanarit/lisp/dp-buffer-bg.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-buffer-local-keys.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-buffer-menu.el" "../../../../../home/dpanarit/lisp/dp-c-like-styles.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-cal.el" "../../../../../home/dpanarit/lisp/dp-cedet-hacks.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-cf.el" "../../../../../home/dpanarit/lisp/dp-colorization-xemacs.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-colorization.el" "../../../../../home/dpanarit/lisp/dp-colorize-ifdefs.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-colorize-ifdefs.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-colorize-ifdefs.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-common-abbrevs-orig.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-common-abbrevs.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-compat.el" "../../../../../home/dpanarit/lisp/dp-debug.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-debug.el" "../../../../../home/dpanarit/lisp/dp-debug.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-deps.el" "../../../../../home/dpanarit/lisp/dp-dict.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.HOME_BOX_0.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.amd.el" "../../../../../home/dpanarit/lisp/dp-dot-emacs.baloo.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.chele.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.el" "../../../../../home/dpanarit/lisp/dp-dot-emacs.grape01.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.hob.el" "../../../../../home/dpanarit/lisp/dp-dot-emacs.huan.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.intel.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.lrl.el" "../../../../../home/dpanarit/lisp/dp-dot-emacs.nvidia.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.permabit.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.sam.el" "../../../../../home/dpanarit/lisp/dp-dot-emacs.skaion.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.sybil.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.vanu.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-emacs.vilya.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-gnus.el" "../../../../../home/dpanarit/lisp/dp-dot-mew.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-dot-vm.el" "../../../../../home/dpanarit/lisp/dp-emms.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-ephemeral.el" "../../../../../home/dpanarit/lisp/dp-errors.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-faces.el" "../../../../../home/dpanarit/lisp/dp-faces.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-faces.el" "../../../../../home/dpanarit/lisp/dp-flyspell.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-flyspell.el" "../../../../../home/dpanarit/lisp/dp-flyspell.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-fsf-button-compat.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-fsf-early.el" "../../../../../home/dpanarit/lisp/dp-fsf-fsf-compat.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-hooks.el" "../../../../../home/dpanarit/lisp/dp-id-utils.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-id-utils.el" "../../../../../home/dpanarit/lisp/dp-id-utils.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-ilisp.el" "../../../../../home/dpanarit/lisp/dp-init-early.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-journal.el" "../../../../../home/dpanarit/lisp/dp-journal.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-journal.el" "../../../../../home/dpanarit/lisp/dp-keys.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-lang-c-like.el" "../../../../../home/dpanarit/lisp/dp-lang.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-macros.el" "../../../../../home/dpanarit/lisp/dp-mail.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-makefile-mode.el" "../../../../../home/dpanarit/lisp/dp-mew-config.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-mew.el" "../../../../../home/dpanarit/lisp/dp-mhe.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-mmm.el" "../../../../../home/dpanarit/lisp/dp-new-mew.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-open-newline.el" "../../../../../home/dpanarit/lisp/dp-org.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-patches-for-testing.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-pdoc.el" "../../../../../home/dpanarit/lisp/dp-perforce.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-portage.el" "../../../../../home/dpanarit/lisp/dp-ptools.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-regexp.el" "../../../../../home/dpanarit/lisp/dp-sel2.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-sel2.el" "../../../../../home/dpanarit/lisp/dp-sel2.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-server.el" "../../../../../home/dpanarit/lisp/dp-shells.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-shells.el" "../../../../../home/dpanarit/lisp/dp-shells.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-sudo-edit3.el" "../../../../../home/dpanarit/lisp/dp-sudo-edit3.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-sudo-edit3.el" "../../../../../home/dpanarit/lisp/dp-supercite.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-templates.el" "../../../../../home/dpanarit/lisp/dp-templates.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-templates.el" "../../../../../home/dpanarit/lisp/dp-time.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-timeclock.el" "../../../../../home/dpanarit/lisp/dp-vars.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-vc.el" "../../../../../home/dpanarit/lisp/dp-xemacs-buffer-local-keys.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-xemacs-colorization.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-xemacs-early.el" "../../../../../home/dpanarit/lisp/dp-xemacs-extents.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-xemacs-fsf-compat.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp-xemacs-late.el" "../../../../../home/dpanarit/lisp/dp0-theme.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dp1-theme.el" "../../../../../home/dpanarit/lisp/dpmacs.el"
;;;;;;  "../../../../../home/dpanarit/lisp/dpmisc.el" "../../../../../home/dpanarit/lisp/fsf-custom-dp-colorize-broken-due-to-dark-themes-because-my-faces-declare-light-backgrounds.el"
;;;;;;  "../../../../../home/dpanarit/lisp/fsf-custom-dp-colorize-old-works-with-light-themes.el"
;;;;;;  "../../../../../home/dpanarit/lisp/fsf-custom-from-work+home-changes-that-effed-things-up.tmp.flisp.10.el"
;;;;;;  "../../../../../home/dpanarit/lisp/fsf-custom.el" "../../../../../home/dpanarit/lisp/fsf-init.el"
;;;;;;  "../../../../../home/dpanarit/lisp/hdr.el" "../../../../../home/dpanarit/lisp/init.el"
;;;;;;  "../../../../../home/dpanarit/lisp/public-dot-mew.el" "../../../../../home/dpanarit/lisp/srecode-map.el")
;;;;;;  (23217 36939 625472 889000))

;;;***

(provide 'auto-dp-autoloads)
