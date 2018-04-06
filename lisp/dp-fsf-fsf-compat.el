;;;
;;; $Id: dp-fsf-fsf-compat.el,v 1.5 2001/12/27 08:30:14 davep Exp $
;;;
;;; Compatibility functions when running fsf emacs.
;;;

(message "dp-fsf-fsf-compat loading...")

(require 'dp-buffer-bg)

;; This wasn't in XEmacs, so I wrote it, then it was so I deleted it,
;; now it's not in Emacs.  Sigh.
;; ...or-region is a good idea in many cases.
(defun dp-fill-paragraph-or-region (arg)
  "Fill the current region, if it's active; otherwise, fill the paragraph.
See `fill-paragraph' and `fill-region' for more information."
  (interactive "*P")
  (if (dp-mark-active-p)
      (call-interactively 'fill-region)
    (call-interactively 'fill-paragraph)))

;nuke if aliases work. (defsubst dp-mark-active-p ()
;nuke if aliases work.   ;; mark-active
;nuke if aliases work.   ;; which is better?
;nuke if aliases work.   (use-region-p))

(dp-defaliases 'dp-mark-active-p 'dp-region-active-p 'use-region-p)

(defsubst dp-deactivate-mark ()
  (deactivate-mark))

(defsubst dp-set-mark (pos)
  (set-mark pos))

(defsubst dp-fill-keymap (map filler)
  "Fill a keymap MAP with a given item, FILLER."
  `(fillarray (car (cdr map)) filler))

(defmacro dp-set-zmacs-region-stays (arg)
  ())

(defun keymap-name (keymap)
"A tremendously bogus, dangerous and offensive hack.  Mildly better than nothing."
  (keymap-prompt keymap))

(defun set-keymap-name (map name)
  (message "No `set-keymap-name' functionality."))

(defalias 'ffap-host-to-path 'ffap-host-to-filename)

;;; Try to find common way to do this.  It's hacked from XEmacs' lisp code.
(defun paths-directories-which-exist (directories)
  "Return the directories among DIRECTORIES.
DIRECTORIES is a list of strings."
  (let ((reverse-directories '()))
    (while directories
      (if (paths-file-readable-directory-p (car directories))
	  (setq reverse-directories
		(cons (car directories)
		      reverse-directories)))
      (setq directories (cdr directories)))
    (reverse reverse-directories)))

(defun paths-file-readable-directory-p (filename)
  "Check if filename is a readable directory."
  (and (file-directory-p filename)
       (file-readable-p filename)))

(defun paths-construct-path (components &optional expand-directory)
  "Convert list of path components COMPONENTS into a path.
If EXPAND-DIRECTORY is non-NIL, use it as a directory to feed
to EXPAND-FILE-NAME."
  (let* ((reverse-components (reverse components))
	 (last-component (car reverse-components))
	 (first-components (reverse (cdr reverse-components)))
	 (path
	  (apply #'concat
		 (append (mapcar #'file-name-as-directory first-components)
			 (list last-component)))))
    (if expand-directory
	(expand-file-name path expand-directory)
      path)))

(defun dp-elisp-eldoc-doc (&optional insert-template)
  "Display simple help summary in echo area on demand.
If INSERT-TEMPLATE is non-nil (interactively with prefix arg) then insert a
function template at point.
@todo can we add possibility of specifying what to get help on?"
  (interactive "P")
  (let* ((eldoc-documentation-function 'elisp-eldoc-documentation-function)
	 (doc (funcall eldoc-documentation-function)))
    (if insert-template
	(eldoc-insert-elisp-func-template doc)
      (eldoc-message "%s"
		     (or doc
			 (format "No doc for `%s'" (elisp--current-symbol)))))))

(defsubst dp-mmm-in-any-subregion-p (&rest r)
  nil)

;;; This is what I get for committing myself meself to a "proprietary"
;;; subsystem, i.e. extents (which are so much better.)
(defsubst make-extent (&rest r)
  (message "change make-extent to something FSF-ish"))
(defsubst set-extent-properties (&rest r)
  (message "change set-extent-properties to something FSF-ish"))
(defun map-extents (&rest r)
  (message "change map-extents to something FSF-ish"))
(defun delete-extent (&rest r)
  (message "change delete-extent to something FSF-ish"))


;; EEEEEEEEVIL hack.  We need to create our own byte-compilation
;; method so that the proper variables are bound while compilation
;; takes place (which is when the warnings get noticed and batched
;; up).  What we really want to do is make `with-fboundp' a macro
;; that simply `progn's its BODY; but GOD DAMN IT, macros can't have
;; their own byte-compilation methods!  So we make `with-fboundp' a
;; macro calling `with-fboundp-1', which is cleverly aliased to
;; progn.  This way we can put a byte-compilation method on
;; `with-fboundp-1', and when interpreting, progn will duly skip
;; the first, quoted argument, i.e. the symbol name. (We could make
;; `with-fboundp-1' a regular function, but then we'd have to thunk
;; BODY and eval it at runtime.  We could probably just do this using
;; (apply 'progn BODY), but the existing method is more obviously
;; guaranteed to work.)
;;
;; In defense, cl-macs.el does a very similar thing with
;; `cl-block-wrapper'.

(put 'with-fboundp-1 'byte-compile 'byte-compile-with-fboundp)
(defalias 'with-fboundp-1 'progn)

(defmacro with-boundp (variables &rest body)
  "Evaluate BODY, but do not issue bytecomp warnings about VARIABLES undefined.
VARIABLES can be a symbol or a list of symbols and must be quoted.  When
compiling this file, the warnings `reference to free variable VARIABLE' and
`assignment to free variable VARIABLE' will not occur anywhere in BODY, for
any of the listed variables.  This is a clean way to avoid such warnings.

See also `if-boundp', `when-boundp', and `and-boundp' (ways to
conditionalize on a variable being bound and avoid warnings),
`declare-boundp' (issue a variable call without warnings), and
`globally-declare-boundp' (avoid warnings throughout a file about a
variable)."
  (setq variables (eval variables))
  (unless (consp variables)
      (setq variables (list variables)))
  `(progn
     (declare (special ,@variables))
     ,@body))
(put 'with-boundp 'lisp-indent-function 1)

(defmacro if-boundp (variable then &rest else)
  "Equivalent to (if (boundp VARIABLE) THEN ELSE) but handles bytecomp warnings.
VARIABLE should be a quoted symbol.  When compiling this file, the warnings
`reference to free variable VARIABLE' and `assignment to free variable
VARIABLE' will not occur anywhere in the if-statement.  This is a clean way
to avoid such warnings.  See also `with-boundp' and friends."
  `(with-boundp ,variable
     (if (boundp ,variable) ,then ,@else)))
(put 'if-boundp 'lisp-indent-function 2)

(defmacro when-boundp (variable &rest body)
  "Equivalent to (when (boundp VARIABLE) BODY) but handles bytecomp warnings.
VARIABLE should be a quoted symbol.  When compiling this file, the warnings
`reference to free variable VARIABLE' and `assignment to free variable
VARIABLE' will not occur anywhere in the when-statement.  This is a clean
way to avoid such warnings.  See also `with-boundp' and friends."
  `(with-boundp ,variable
     (when (boundp ,variable) ,@body)))
(put 'when-boundp 'lisp-indent-function 1)

(defmacro and-boundp (variable &rest args)
  "Equivalent to (and (boundp VARIABLE) ARGS) but handles bytecomp warnings.
VARIABLE should be a quoted symbol.  When compiling this file, the warnings
`reference to free variable VARIABLE' and `assignment to free variable
VARIABLE' will not occur anywhere in the and-statement.  This is a clean
way to avoid such warnings.  See also `with-boundp' and friends."
  `(with-boundp ,variable
     (and (boundp ,variable) ,@args)))
(put 'and-boundp 'lisp-indent-function 1)

(put 'with-fboundp 'lisp-indent-function 1)
(defmacro with-fboundp (functions &rest body)
  "Evaluate BODY, but do not issue bytecomp warnings about FUNCTIONS undefined.
FUNCTIONS can be a symbol or a list of symbols and must be quoted.  When
compiling this file, the warning `the function FUNCTION is not known to be
defined' will not occur anywhere in BODY, for any of the listed functions.
This is a clean way to avoid such warnings.

See also `if-fboundp', `when-fboundp', and `and-fboundp' (ways to
conditionalize on a function being bound and avoid warnings),
`declare-fboundp' (issue a function call without warnings), and
`globally-declare-fboundp' (avoid warnings throughout a file about a
function)."
  `(with-fboundp-1 ,functions ,@body))

(put 'if-fboundp 'lisp-indent-function 2)
(defmacro if-fboundp (function then &rest else)
  "Equivalent to (if (fboundp FUNCTION) THEN ELSE) but handles bytecomp warnings.
FUNCTION should be a quoted symbol.  When compiling this file, the warning
`the function FUNCTION is not known to be defined' will not occur anywhere
in the if-statement.  This is a clean way to avoid such warnings.  See also
`with-fboundp' and friends."
  `(with-fboundp ,function
     (if (fboundp ,function) ,then ,@else)))

(put 'when-fboundp 'lisp-indent-function 1)
(defmacro when-fboundp (function &rest body)
  "Equivalent to (when (fboundp FUNCTION) BODY) but handles bytecomp warnings.
FUNCTION should be a quoted symbol.  When compiling this file, the warning
`the function FUNCTION is not known to be defined' will not occur anywhere
in the when-statement.  This is a clean way to avoid such warnings.  See also
`with-fboundp' and friends."
  `(with-fboundp ,function
     (when (fboundp ,function) ,@body)))

(put 'and-fboundp 'lisp-indent-function 1)
(defmacro and-fboundp (function &rest args)
  "Equivalent to (and (fboundp FUNCTION) ARGS) but handles bytecomp warnings.
FUNCTION should be a quoted symbol.  When compiling this file, the warning
`the function FUNCTION is not known to be defined' will not occur anywhere
in the and-statement.  This is a clean way to avoid such warnings.  See also
`with-fboundp' and friends."
  `(with-fboundp ,function
     (and (fboundp ,function) ,@args)))

(defun valid-plist-p (&rest r)
  ;; FSF cares not.
  t)

(defun symbol-value-in-buffer (symbol buffer &optional unbound-value)
  (setq-ifnil buffer (current-buffer))
  (with-current-buffer buffer
    (if (not (boundp symbol))
        unbound-value)
    (symbol-value symbol)))

(defun redisplay-frame (&optional frame no-preempt)
  ;; FSF uses not the no-preempt parameter.
  (redraw-frame frame))

(defsubst dp-local-variable-p (symbol buffer &optional after-set)
  (local-variable-p symbol buffer))

(defun minibuffer-keyboard-quit ()
  (interactive)
  ;;(exit-minibuffer)
  ;;(keyboard-quit)
  (keyboard-escape-quit))

(defun symbol-near-point ()
  (interactive)
  (symbol-at-point))

(defmacro save-window-excursion/mapping (&rest body)
  `(save-window-excursion ,@body))

(defun map-plist (mp-function plist)
  "Map FUNCTION (a function of two args) over each key/value pair in PLIST.
Return a list of the results."
  (let (result)
    (while plist
      (push (funcall mp-function (car plist) (cadr plist)) result)
      (setq plist (cddr plist)))
    (nreverse result)))

(defun append-expand-filename (file-string string)
  "Append STRING to FILE-STRING differently depending on whether STRING
is a username (~string), an environment variable ($string),
or a filename (/string).  The resultant string is returned with the
environment variable or username expanded and resolved to indicate
whether it is a file(/result) or a directory (/result/)."
  (let ((file
	 (cond ((string-match "\\([~$]\\)\\([^~$/]*\\)$" file-string)
		(cond ((string= (substring file-string
					   (match-beginning 1)
					   (match-end 1)) "~")
		       (concat (substring file-string 0 (match-end 1))
			       string))
		      (t (substitute-in-file-name
			  (concat (substring file-string 0 (match-end 1))
				  string)))))
	       (t (concat (file-name-directory
			   (substitute-in-file-name file-string)) string))))
	result)

    (cond ((stringp (setq result (and (file-exists-p (expand-file-name file))
				      (dp-read-file-name-internal
				       (condition-case nil
					   (expand-file-name file)
					 (error file))
				       "" nil))))
	   result)
	  (t file))))

(defun line-number (&optional pos)
  (line-number-at-pos pos))

(defun abbrev-string-to-be-defined (arg)
  "Return the string for which an abbrev will be defined.
ARG is the argument to `add-global-abbrev' or `add-mode-abbrev'."
  (if (and (not arg) (region-active-p)) (setq arg 0)
    (setq arg (prefix-numeric-value arg)))
  (and (>= arg 0)
       (buffer-substring
	(point)
	(if (= arg 0) (mark)
	  (save-excursion (backward-word arg) (point))))))


(defun dp-x-insert-selection (prompt-if-^Ms &optional no-insert-p)
  "Insert the current X Window selection at point, and put text into kill ring."
  (interactive "P")
  (let ((text (dp-with-all-output-to-string
	       (yank))))
    (when (and (string-match "
" text)
	       (or (ding) t)
	       (or (not prompt-if-^Ms)
		   (y-or-n-p "^Ms in text; dedosify")))
      (setq text (replace-in-string text "
" "" 'literal))
      (message "dedos'd"))
    (push-mark (point))
    (unless no-insert-p
      (insert text))
    (setq this-command 'yank)
    (kill-new text)))

(defun dp-re-search-forward (regexp &optional limit noerror count buffer)
  "FSF's `re-search-forward' doesn't have a buffer parameter."
  (interactive)
  (with-current-buffer (or buffer (current-buffer))
    (re-search-forward regexp limit noerror count)))

(defun replace-in-string (which from-str to-str &optional literal)
  (replace-regexp-in-string from-str to-str which nil literal))

;; #### we need a coherent scheme for indicating compatibility info,
;; so that it can be programmatically retrieved.
(defun add-local-hook (hook function &optional append)
  "Add to the local value of HOOK the function FUNCTION.
You don't need this any more.  It's equivalent to specifying the LOCAL
argument to `add-hook'."
  (add-hook hook function append t))

(unless (fboundp 'gettext)
  (defalias 'gettext 'identity))

(defun dp-push-window-config ()
  (interactive)
  )

(defun dp-pop-window-config (n)
  (interactive "p")
  )

(defun device-frame-list (&optional device)
  "XEmacs predicates on device.
I need to look at filtered-frame-list to use device if non-nil."
  (frame-list))

(defun map-extents (&rest r)
  )

(defun window-displayed-height (&optional window)
  (window-buffer-height (or window (frame-selected-window))))

(defun dp-window-list (&optional frame minibuf window)
  "Fake window-list for fsf.
Dumb-fuxking-ass saveconf.el defined it's own window-list (FUCK!
function that had different parameters and was causing an error.
Hence the compat function which isn't needed.  Bailiff, whack his
pee-pee. "
  (window-list frame minibuf window))

(defun dp-bobp (&optional buffer)
  "FSF don't use a BUFFER parameter."
  (with-current-buffer (or buffer (current-buffer))
    (bobp)))

(defun dp-eobp (&optional buffer)
  "FSF don't use a BUFFER parameter."
  (with-current-buffer (or buffer (current-buffer))
    (eobp)))

;; Copped from `gnus-key-press-event-p'.
;;(defun key-press-event-p (x)
;;  (numberp x))
(defun key-press-event-p (x)
  (not (mouse-event-p x)))

;; X v FSF events, keys, etc, have diverged a lot.
(defun event-key (ev)
  ev)

(defalias 'dp-isearch-yank-char 'isearch-yank-char)

(defun gnuserv-start (&rest r)
  )

(defun dp-low-level-server-start (&optional leave-dead inhibit-prompt)
  (server-start leave-dead inhibit-prompt))

(defun dp-text-propertize-region (from to id-prop &rest props)
  "Kind of like XEmacs' extent stuff."
  (with-silent-modifications
    (set-text-properties from to
			 ;; Must be first and must be in every dp prop
			 ;; alist.
			 (append '(dp-extent-p t) ; Separated out for emphasis.
				 (list 'dp-id-prop id-prop
				       'dp-beginning (dp-mk-marker from nil t)
				       'dp-end (dp-mk-marker to nil t))
				 props))))

(defun dp-set-text-color (tag face &optional begin end detachable-p 
			      start-open-p end-open-p)
  "Set a region's background color to FACE.
Identify the extent w/TAG.
Use BEGIN and END as the limits of the extent."
  (let* ((be (if (not (or begin end))
		 (dp-region-or... :beg begin :end end
				  :bounder 'rest-or-all-of-line-p)
	       (cons begin end)))
	 (begin (car be))
	 (end (cdr be)))
    (apply `dp-text-propertize-region begin end 'dp-colorized-region
	   (list
	    'dp-colorized-p t
	    'dp-text-colorized t
	    'set-text-color-tag tag
	    'face-sym face
	    ;;'invisible 'dp-colorize-region
	    'dp-colorized-region-color-num -1
	    'dp-extent-search-key 'dp-colorized-region
	    'dp-extent-search-key2 (list 'dp-colorized-region-p t)))))

(defun dp-remove-file-state-colorization (&optional pos end)
  "We ignore begin and end in this version."
  (let ((overlays (overlays-at (or pos (point)))))
    (cl-loop for olay in overlays
	     do
	     ;; Only delete overlays with prop
	     ;; (cons 'dp-file-state-colorization t)
	     (delete-overlay olay))))

(defalias 'dp-set-background-color 'dp-buffer-bg-set-color)

(defadvice apropos (before dp-advice activate)
  "Invert sense of DO-ALL.  We likes the DO-ALL, precious."
  (ad-set-arg 1 (not (ad-get-arg 1))))

(defun dp-find-file (file-name codesys &optional wildcards)
  "FSF no take codesys arg."
  (find-file file-name wildcards))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Liberated from XEmacs.
(defun switch-to-other-buffer (arg)
  "Switch to the previous buffer.  With a numeric arg, n, switch to the nthmost recent buffer.  With an arg of 0, buries the current buffer at thebottom of the buffer stack."
  (interactive "p")
  (if (eq arg 0)
      (bury-buffer (current-buffer)))
  (switch-to-buffer
   (if (<= arg 1)
       (other-buffer (current-buffer))
     (nth (1+ arg) (buffer-list)))))

(defun add-one-shot-hook (hook function &optional append local)
  "Add to the value of HOOK the one-shot function FUNCTION.
FUNCTION will automatically be removed from the hook the first time
after it runs (whether to completion or to an error).
FUNCTION is not added if already present.
FUNCTION is added (if necessary) at the beginning of the hook list
unless the optional argument APPEND is non-nil, in which case
FUNCTION is added at the end.

HOOK should be a symbol, and FUNCTION may be any valid function.  If
HOOK is void, it is first set to nil.  If HOOK's value is a single
function, it is changed to a list of functions.

You can remove this hook yourself using `remove-hook'.

See also `add-hook'."
  (let ((sym (gensym)))
    (fset sym `(lambda (&rest args)
		 (unwind-protect
		     (apply ',function args)
		   (remove-hook ',hook ',sym ',local))))
    (put sym 'one-shot-hook-fun function)
    (add-hook hook sym append local)))

(defun add-local-one-shot-hook (hook function &optional append)
  "Add to the local value of HOOK the one-shot function FUNCTION.
You don't need this any more.  It's equivalent to specifying the LOCAL
argument to `add-one-shot-hook'."
  (add-one-shot-hook hook function append t))

(defun read-function (prompt &optional default-value)
  "Read the name of a function and return as a symbol.
Prompts with PROMPT. By default, return DEFAULT-VALUE."
  (intern (completing-read prompt obarray 'fboundp t nil
			   'function-history default-value)))

(defun dp-read-number (prompt &optional integers-only default-value)
  "Read a number from the minibuffer, prompting with PROMPT.
If optional second argument INTEGERS-ONLY is non-nil, accept
 only integer input.
If DEFAULT-VALUE is non-nil, return that if user enters an empty
 line."
  (let ((pred (if integers-only 'integerp 'numberp))
	num)
    (while (not (funcall pred num))
      (setq num (condition-case ()
		    (let ((minibuffer-completion-table nil))
		      (read-from-minibuffer
		       prompt (if num (prin1-to-string num)) nil t
		       nil nil default-value))
		  (input-error nil)
		  (invalid-read-syntax nil)
		  (end-of-file nil)))
      (or (funcall pred num) (beep)))
    num))

;;
;; set up a titlebar format.  Various window things will look for this in
;; order to jump to the main emacs window.
;; @todo XXX Fix this.  There is no equivalent in current FSF.  Need to change
;; how I make a title.
(defconst dp-frame-title-format (format
				 "%s@%s:%%f"
				 (upcase-initials invocation-name) system-name)
  "*Base frame title format.")

(defun dp-hl-highlight-one ()
  "Just highlight the current line.
Stolen from `global-hl-line-highlight' and removed the `global-hl-line-highlight'
predicate.  
XXX @todo It might be better to set that in a `let' and the call the original."
  (interactive)
  (unless global-hl-line-overlay
    (setq global-hl-line-overlay (hl-line-make-overlay))) ; To be moved.
  (unless (member global-hl-line-overlay global-hl-line-overlays)
    (push global-hl-line-overlay global-hl-line-overlays))
  (overlay-put global-hl-line-overlay 'window
	       (unless global-hl-line-sticky-flag
		 (selected-window)))
  (hl-line-move global-hl-line-overlay))

(defun dp-hl-unhighlight-one ()
  "Unhighlight a line.
XXX @todo Do we want to make it only act on the current line?
Currently it removes it regardless of the line we're on."
  (interactive)
  (when global-hl-line-overlay
    (delete-overlay global-hl-line-overlay)))

(require 'cus-edit)
(defsubst custom-face-get-spec (face)
  (custom-face-get-current-spec face))
;;(defalias 'custom-face-get-spec 'custom-face-get-current-spec)

(defun dp-read-file-name (prompt &optional dir default-file-name
       must-match initial predicate hist-var)
  "FSF does not have a HIST-VAR parameter."
  (read-file-name prompt dir default-file-name must-match initial predicate))

(defun dp-plists-equal (pl1 pl2)
  "Compare plists for EQUALity. List ordering is ignored.
e.g. \(dp-plist-equal '(p1 v1 p2 v2) '(p2 v2 p1 v1)) is t"
  (when (and
	 (and pl1 pl2)
	 (equal (length pl1) (length pl2)))
    (cl-loop for (prop val) on pl1 by #'cddr
	     always (equal (lax-plist-get pl2 prop)
			   val))))

(message "dp-fsf-fsf-compat loading...done")
