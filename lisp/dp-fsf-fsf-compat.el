;;;
;;; $Id: dp-fsf-fsf-compat.el,v 1.5 2001/12/27 08:30:14 davep Exp $
;;;
;;; Compatibility functions when running fsf emacs.
;;;

(message "dp-fsf-fsf-compat loading...")

(require 'dp-buffer-bg)

(global-set-key [(control ?h) ?a] 'apropos)
(global-set-key [(control ?h) (control ?c)] 'apropos-command)
(global-set-key [(control ?h) (control ?v)] 'apropos-variable)

;; This wasn't in XEmacs, so I wrote it, then it was so I deleted it,
;; now it's not in Emacs.  Sigh.
;; ...or-region is a good idea in many cases.
(defun dp-fill-paragraph-or-region (arg)
  "Fill the current region, if it's active; otherwise, fill the paragraph.
See `fill-paragraph' and `fill-region' for more information."
  (interactive "*P")
  (if (dp-mark-active-p)
      (call-interactively 'fill-region)
    (save-restriction
      (when (Cu-memq '(- 0))
	(setq current-prefix-arg nil)
	(narrow-to-region (line-beginning-position) (point-max)))
      (call-interactively 'fill-paragraph))))

(defun dp-mark-active-p (&optional dont-count-outside-minibuffer-p)
  "Emulate fsf emacs' transient mark activation w/zmacs-regions"
  (and (use-region-p)
       (cons (region-beginning) (region-end))))

(defalias 'dp-region-active-p 'dp-mark-active-p)

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

;; stolen from: mmmode, was: easy-mmode-set-keymap-parents
(defun dp-set-keymap-parents (m parents)
  (set-keymap-parent
   m (if (cdr parents) (make-composed-keymap parents) (car parents))))

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
      (eldoc-message (format "%s"
			     (or doc
				 (format "No doc for `%s'"
					 (elisp--current-symbol))))))))

(defun eldoc-insert-elisp-func-template (doc)
  "Insert function template extracted from an eldoc help message."
  (interactive "*")
  (message "%s" doc)
  (if (not doc)
      (error "could not find doc.")
    (if (string-match "[^(]*(\\(.*\\))[^)]*" doc)
	(save-excursion
	  (insert (substring doc (match-beginning 1) (match-end 1)) ")"))
      (message "Cannot find args, none?"))))

(defsubst dp-mmm-in-any-subregion-p (&rest r)
  nil)

(defun map-extents (map-fun
		    &optional object from to maparg flags property value)
  "Try to fake XEmacs' `map-extents'."
  (setq-ifnil object (current-buffer)
	      from (cond
		    ((overlayp object) (overlay-start))
		    ((stringp object) 0)
		    ((bufferp object)
		     (with-current-buffer object
		       (point-min)))
		    (t (error "Unsupported object type: %s" object)))
	      to (cond
		    ((overlayp object) (overlay-end))
		    ((stringp object) (1- (length object)))
		    ((bufferp object)
		     (with-current-buffer object
		       (point-max)))
		    (t (error "Unsupported object type: %s" object))))
  ;; @todo XXX Handle other kinds of objects.
  (with-current-buffer (or object (current-buffer))
    (mapc (lambda (extent)
	    (funcall map-fun extent maparg))
	  (auto-overlays-in from to
			    (when property
			      (list 'eq property value)
			      )))))

;; (extents-at POS &optional OBJECT PROPERTY BEFORE AT-FLAG)
;; We really don't use any of the args except.  I do a filtering process
;; elsewhere.
;; (auto-overlays-at-point &optional POINT PROP-TEST INACTIVE)
(defun extents-at (pos &optional object property before at-flag)
  (auto-overlays-at-point pos
			  (when property
			    (list 'eq property value))
			  nil))

(defalias 'delete-extent 'delete-overlay)

;;
;; Copied directly from XEmacs.
;;
(defun sorted-key-descriptions (keys &optional separator)
  "Sort and separate the key descriptions for KEYS.
The sorting is done by length (shortest bindings first), and the bindings
are separated with SEPARATOR (\", \" by default)."
  (mapconcat 'key-description
             (sort* keys #'< :key #'length)
             (or separator ", ")))

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

(defun symbol-value-in-buffer (symbol &optional buffer unbound-value)
  (setq-ifnil buffer (current-buffer))
  (with-current-buffer buffer
    (if (not (boundp symbol))
        unbound-value)
    (symbol-value symbol)))

;;
(defun set-symbol-value-in-buffer (symbol val &optional buffer)
  (setq-ifnil buffer (current-buffer))
  (with-current-buffer buffer
    (set symbol val)))

(defun redisplay-frame (&optional frame no-preempt)
  ;; FSF uses not the no-preempt parameter.
  (redraw-frame frame))

(defsubst dp-local-variable-p (symbol buffer &optional after-set)
  (local-variable-p symbol buffer))

(defun minibuffer-keyboard-quit ()
  (interactive)
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
	       (if (dp-xemacs-p)
		   (yank)
		 (insert-for-yank (gui-get-primary-selection))))))
    (when (and (string-match "" text)
	       (or (ding) t)
	       (or (not prompt-if-^Ms)
		   (y-or-n-p "^Ms in text; dedosify")))
      (setq text (replace-in-string text "" "" 'literal))
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

(defvar dp-window-config-stack nil
  "FSF has no way to push a window config so we do the work onto this stack.")

(defun dp-push-window-configuration ()
  (interactive)
  (push (current-window-configuration) dp-window-config-stack)
  )
(defalias 'dp-push-window-config 'dp-push-window-configuration)

(defun dp-pop-window-configuration (n)
  (interactive "p")
  (pop dp-window-config-stack)
  )

(defun device-frame-list (&optional device)
  "XEmacs predicates on device.
I need to look at filtered-frame-list to use device if non-nil."
  (frame-list))

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
	     (delete-overlay olay))))

(defalias 'dp-set-background-color 'dp-buffer-bg-set-color)

(defun dp-find-file (file-name codesys &optional wildcards)
  "FSF no take codesys arg."
  (find-file file-name wildcards))

;; From FSF Emacs' syntax.el. I am happy.
(defun buffer-syntactic-context (&optional buffer)
  "Syntactic context at point in BUFFER.
Either of `string', `comment' or nil.
This is an XEmacs compatibility function."
  (with-current-buffer (or buffer (current-buffer))
    (syntax-ppss-context (syntax-ppss))))

(defun buffer-syntactic-context-depth (&optional buffer)
  "Syntactic parenthesis depth at point in BUFFER.
This is an XEmacs compatibility function."
  (with-current-buffer (or buffer (current-buffer))
    (syntax-ppss-depth (syntax-ppss))))

(defalias 'describe-function-at-point 'describe-function)

;; Stolen.  And hacked.
;; There is a bug that is triggered when an existing autoloads file or buffer
;; exists.  Therefore, we make sure neither exists.
;; Lines like this cause "Invalid time specification" errors:
;; ;;;### (autoloads nil "dp-colorize-ifdefs" "../../../flisp/dp-colorize-ifdefs.el"
;; ;;;;;;  "9feca494c3c7c1203d08fdf4b748482a")
;; ;;;;;;  ----------------------------------
;; These are OK:
;; ;;;;;;  "../../../flisp/dp-colorization-xemacs.el" (0 0 0 0))
;; ;;;;;;                                             ---------
;; I don't know why they are generated differently. Doesn't seem to be:
;; 1) File date
;; 2) File owner/group.
;;
(defun* dp-update-autoloads ()
  "Call `update-autoloads-from-directories' on my local lisp directory."
  (interactive)
  (let ((autoloads-buf (dp-get-buffer (file-name-nondirectory
				       generated-autoload-file))))
    (when autoloads-buf
      (when (buffer-modified-p autoloads-buf)
	(message "Buffer for %s is modified and it's gotta go."
		 (buffer-file-name autoloads-buf))
	(return-from dp-update-autoloads nil))
      (kill-buffer autoloads-buf)))
  (when (file-exists-p generated-autoload-file)
    (if (y-or-n-p (format
		       "Autoload file (%s) exists, and that is bad.  Remove it?"
		       generated-autoload-file))
	(delete-file generated-autoload-file)
      (message "Fine. You deal with it.")
      (return-from dp-update-autoloads nil)))
  (update-directory-autoloads (file-name-directory generated-autoload-file))
  (byte-compile-file generated-autoload-file)
  generated-autoload-file)

(defalias 'string-to-int 'string-to-number)
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
		       prompt nil nil
		       t	      ; READ -- see read-from-minibuffer doc.
		       nil
		       default-value
		       nil))
		  (input-error nil)
		  (invalid-read-syntax nil)
		  (end-of-file default-value)))
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

(defun dp-edit-faces (&optional regexp)
  "Edit my faces, or faces specified by REGEXP."
  (interactive (list (and current-prefix-arg
                          (read-regexp "List faces matching regexp"))))
  (list-faces-display (or regexp dp-faces-regexp)))

(defun dp-appt-initialize (&rest r)
  "An interactive function for [re]initializing the appointment list.
Name is old and from the XEmacs days and is used for compatibility."
  (interactive)
  (apply 'appt-activate r))

(defun dp-appt-initialize-on ()
  "Activate the appointment timer system."
  (interactive)
  (dp-appt-initialize 1))

(defmacro with-string-as-buffer-contents (str &rest body)
  "With the contents of the current buffer being STR, run BODY.
Point starts positioned to end of buffer.
Returns the new contents of the buffer, as modified by BODY.
The original current buffer is restored afterwards."
  `(with-temp-buffer
     (insert ,str)
     ,@body
     (buffer-string)))

(defsubst py-point (position)
  "Returns the value of point at certain commonly referenced POSITIONs.
POSITION can be one of the following symbols:

  bol  -- beginning of line
  eol  -- end of line
  bod  -- beginning of def or class
  eod  -- end of def or class
  bob  -- beginning of buffer
  eob  -- end of buffer
  boi  -- back to indentation
  bos  -- beginning of statement

This function does not modify point or mark."
  (let ((here (point)))
    (cond
     ((eq position 'bol) (beginning-of-line))
     ((eq position 'eol) (end-of-line))
     ((eq position 'bod) (py-beginning-of-def-or-class 'either))
     ((eq position 'eod) (py-end-of-def-or-class 'either))
     ;; Kind of funny, I know, but useful for py-up-exception.
     ((eq position 'bob) (goto-char (point-min)))
     ((eq position 'eob) (goto-char (point-max)))
     ((eq position 'boi) (back-to-indentation))
     ((eq position 'bos) (py-goto-initial-line))
     (t (error "Unknown buffer position requested: %s" position))
     )
    (prog1
        (point)
      (goto-char here))))

(defun message-nl (fmt &rest args)
  (let ((message-log-max nil))
    (apply 'message fmt args)))

(message "dp-fsf-fsf-compat loading...done")
