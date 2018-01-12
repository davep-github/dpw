;;;
;;; $Id: dp-fsf-fsf-compat.el,v 1.5 2001/12/27 08:30:14 davep Exp $
;;;
;;; Compatibility functions when running fsf emacs.
;;;

(message "dp-fsf-fsf-compat loading...")

(defsubst dp-mark-active-p ()
  mark-active)

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

(defun dp-isearch-yank-char (&optional arg)
  (interactive)
  (isearch-yank-char arg))

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
  (let ((eldoc-documentation-function 'elisp-eldoc-documentation-function)
        (doc (funcall eldoc-documentation-function)))
    (if insert-template
	(eldoc-insert-elisp-func-template doc)
      (eldoc-message "%s"
		     (or doc 
			 (format "No doc for `%s'" (eldoc-current-symbol)))))))

(defsubst dp-mmm-in-any-subregion-p (&rest r)
  nil)

(defsubst make-extent (&rest r)
  (message "change make-extent to something FSF-ish"))
(defsubst set-extent-properties (&rest r)
  (message "change set-extent-properties to something FSF-ish"))

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

(defsubst redisplay-frame (&rest r)
  (message "Need `redisplay-frame' fnctionality"))

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
				      (read-file-name-internal
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

;;
;; set up a titlebar format.  Various window things will look for this in
;; order to jump to the main emacs window.
;; @todo XXX Fix this.  There is no equivalent in current FSF.  Need to change
;; how I make a title.
(defconst dp-frame-title-format (format "%%S@%s: %%f" (dp-short-hostname))
  "*Base frame title format.")

(require 'cus-edit)
(defsubst custom-face-get-spec (face)
  (custom-face-get-current-spec face))
;;(defalias 'custom-face-get-spec 'custom-face-get-current-spec)

(message "dp-fsf-fsf-compat loading...done")
