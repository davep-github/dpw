
(when (bound-and-true-p dp-use-standard-emacs-python-mode)

  ;; Fancy vars...
  (defcustom dp-python-new-file-template-file
    (expand-file-name "~/bin/templates/python-template.py")
    "A file to stuff into each new Python file created with `pyit'
or a list: \(function args).
An `undo-boundary' is done before the template is used."
    :group 'dp-vars
    :type 'string)

  ;; Vars
  (defvar dp-orig-python-tab-binding nil
    "Original binding for the tab key in python mode")
  (defvar dp-latest-py-shell-buffer nil
    "Newest buffer created by `dp-python-shell'.")
  ;;(make-string 3 ?\')
  ;;(make-string 3 ?\")
  (defvar dp-python-mode-parenthesize-region-paren-list
    `(("(" . ")")
      ("\"" . "\"")
      ,(cons (make-string 3 ?\") (make-string 3 ?\"))
      ("'" . "'")
      ,(cons (make-string 3 ?') (make-string 3 ?'))
      ("`" . "`")
      ("{" . "}")
      ("[" . "]")
      ("<" . ">")
      ("<:" . ":>")
      ("*" . "*")
      ("`" . "'")
      ("" . ""))
    "Python mode's Parenthesizing pairs to try, in order.
See `dp-parenthesize-region-paren-list'")

;;;###autoload
  (defun* dp-python-shell (&optional args)
    "Start up python shell and then run my shell-mode-hook since they
set the key-map after the hook has run.
@todo XXX Can this go away with the new Emacs Python mode/support stuff."
    (interactive "P")
    ;; Hide history file... we'll manage it oursefs.
    ;; Hack around for python-mode bug:
    ;; It, `py-shell', sets mode name before switching to the Python buffer.
    (let ((py-buf (get-buffer "*Python*")))
      (when py-buf
	(dp-visit-or-switch-to-buffer py-buf)
      (return-from dp-python-shell)))

  (let ((dp-real-comint-read-input-ring (symbol-function
                                         'comint-read-input-ring))
        mode-name input-ring-name)
    ;; Fucking ipython's advice for py-shell reads in the history before
    ;; switching to the Python shell buffer.  So if, e.g., we're in a regular
    ;; shell buffer, its history is hosed.  So we'll spoof the read and
    ;; capture the file name they want to read and use that as our history
    ;; file and read that AT ZE *RIGHT* TIME!
    (cl-flet ((comint-read-input-ring
	       (&rest r)
	       (dmessage "in dummy comint-read-input-ring")
	       (setq input-ring-name comint-input-ring-file-name)))
      (py-shell args))
    (setq comint-input-ring-file-name input-ring-name))
  ;; This should be done in the Python buffer by `py-shell', but isn't.
  (setq mode-name "Python")
  (setq dp-ima-dpy-buffer-p t)
  (dp-maybe-read-input-ring)
  (unless (eq dp-latest-py-shell-buffer (current-buffer))
    (setq dp-latest-py-shell-buffer (current-buffer))
    (local-set-key "\C-c\C-b" 'dpy-reload)
    (dp-py-shell-hook))
  (add-local-hook 'kill-buffer-hook 'dp-ipython-buffer-killed))

;;;###autoload
  (defalias 'dpy 'dp-python-shell)

;;;###autoload
  (defsubst dp-python-shell-this-window (&optional args)
    "Try to put the shell in the current window."
    (interactive "P")
    (dp-python-shell)
    ;; This may or may not work, depending on the original window config.
    (dp-slide-window-right 1))

;;;###autoload
  (defalias 'dpyd 'dp-python-shell-this-window)
;;;###autoload
  (defalias 'dpy. 'dp-python-shell-this-window)
;;;###autoload
  (defalias 'dpy0 'dp-python-shell-this-window)

  (defun dpy-reload ()
    (interactive)
    ;; Kill current buffer if it's a dpy buffer, else the latest one created.
    (let* ((doomed-buf (if dp-ima-dpy-buffer-p
			   (current-buffer)
			 dp-latest-py-shell-buffer))
	   (cwd (buffer-local-value 'default-directory doomed-buf)))
      (kill-buffer doomed-buf)
      ;; Start new shell in same directory
      (cd cwd))
    (dp-python-shell))

  (defun dp-py-prepend-self. (&optional make-initializer-p)
    (interactive "P")
    (let (p m)
      (save-excursion
	(backward-word 1)
	(insert "self.")
	(setq m (dp-mk-marker))
	;; This makes sure we get the whole symbol since we may have issued
	;; the command inside it somewhere.
	(forward-word)
	(setq p (dp-mk-marker)))
      (when make-initializer-p
	(goto-char p)
	(insert " = " (buffer-substring m p)))))

  (dp-add-mode-paren-list 'python-mode
			  dp-python-mode-parenthesize-region-paren-list)

  (defun dp-python-mode-hook ()
    "Set up python *my* way."
    (interactive)
    ;; Python has a problem with my  `dp-fix-comments' function.
    (setq dp-il&md-dont-fix-comments-p t)
    (progn
      (filladapt-mode)
      (dmessage "Added filladapt-mode to python hook 2012-02-10T14:14:39"))
    (setq-ifnil dp-orig-python-tab-binding (key-binding (kbd "TAB")))
    (make-variable-buffer-local 'block-comment-start)
    (setq dp-insert-tempo-comment-func 'dp-py-insert-tempo-doxy-comment
	  block-comment-start (concat py-block-comment-prefix " ")
	  comment-start "# ")
    (define-key dp-Ccd-map [(control d)] 'dp-py-insert-tempo-doxy-comment)
    ;; They set this to "# " This makes doxygen comments ("##") not look like
    ;; Python comments.
    ;; ## forces comment to line up @ comment col.
    (setq comment-start "#")
    (local-set-key [tab] 'dp-python-indent-command)
    (local-set-key [(meta \;)] 'dp-py-indent-for-comment)
    (local-set-key [(meta ?`)] 'comint-previous-matching-input-from-input)
    (local-set-key "\C-p`" 'comint-previous-matching-input-from-input)
    (local-set-key [delete] 'dp-delete)
    (local-set-key "\C-z" 'dp-shell)
    (local-set-key [(control x) (control left)] 'py-beginning-of-def-or-class)
    (local-set-key [(meta left)] 'beginning-of-defun)
    (if (dp-xemacs-p)
	(local-set-key [(meta right)] 'py-end-of-def-or-class)
      (local-set-key [(meta right)] 'end-of-defun))
    (local-set-key [(meta return)] 'dp-py-open-newline)
    (local-set-key [(control meta ?p)] 'py-beginning-of-def-or-class)
    (local-set-key "\C-c!" 'dp-python-shell)
    (local-set-key [(meta s)] 'dp-py-insert-self?)
    (local-set-key [(meta q)] 'dp-fill-paragraph-or-region-with-no-prefix)
    (dp-add-line-too-long-font 'python-font-lock-keywords)
    (setq dp-cleanup-whitespace-p t)
    ;; @todo XXX conditionalize this properly
    ;; dp-trailing-whitespace-font-lock-element

    ;; !<@todo XXX Add this to a new file hook?
    (dp-auto-it?)

;;;;;;;;move to dp-flyspell (dp-flyspell-prog-mode)
    (message "python mode hook finished."))

  ;;CO; (defadvice py-end-of-def-or-class (before dp-py-eodoc activate)
  ;;CO;   "Make `py-end-of-def-or-class' leave the region active."
  ;;CO;   (dp-set-zmacs-region-stays t))

  (defadvice py-end-of-def-or-class (around dp-py-end-of-def-or-class activate)
    "If preceeding command was `dp-beginning-of-def-or-class' do a go-back.
Otherwise business as usual.
Also leave the region active."
    (dp-set-zmacs-region-stays t)
    (if (eq last-command 'dp-beginning-of-def-or-class)
	(dp-pop-go-back)
      ad-do-it))

  ;; Some Python only non `python-mode' keys.
  (define-key dp-Ccd-map [?p] 'dp-python-shell)
  (define-key dp-temp-buffer-mode-map [?p] 'dp-make-temp-python-mode-buffer)

  ;;
  (global-set-key [(control ?c) (control ?z)]
		(kb-lambda
		  (dp-kb-binding-moved arg 'dp-python-shell)))

;;;
;;; Make an? I?Python shell setup file or function?
;;; Not until I have only Python mode or Python type shell package.
;;; For now, assume we have both and leave them both here.
;;;
  (defun dp-python-get-process ()
    (or (get-buffer-process (current-buffer))
                                        ;XXX hack for .py buffers
	(get-process py-which-bufname)))

  ;; Make this a "style" thing (canna thing ova better word)?  Putting the
  ;; hook in the setup file if there is a setup type file.  Otherwise near
  ;; the setup code or function definition.
  (add-hook 'python-mode-hook 'dp-python-mode-hook)

  (defun dp-py-completion-setup-stolen ()
    (let ((python-process (dp-python-get-process)))
      (process-send-string
       python-process
       "from IPython.core.completerlib import module_completion\n")))

;;;###autoload
  (defun dp-py-shell-hook ()		;<:psh|pysh:>
    "Set up my python shell mode fiddle-faddle."
    (interactive)
    (dmessage "in dp-py-shell-hook")
    (make-variable-buffer-local 'dp-wants-ansi-color-p)
    (dp-maybe-add-ansi-color nil)
    (dp-specialized-shell-setup "~/.ipython/history"
				'bind-enter
				;; these are args to
				;; `dp-bind-shell-type-enter-key'
				:keymap py-shell-map
				:dp-ef-before-pmark-func nil
				;; ?????? 'dp-ignore-this-mode
				)
    (when (fboundp 'ipython-complete)
      (local-set-key [tab] 'ipython-complete))

    (dp-define-buffer-local-keys
     '([(meta return)] dp-end-of-line-and-enter
       "\C-d" dp-shell-delchar-or-quit
       [(control backspace)] dp-ipython-backward-delete-word)
     nil nil nil "dpsh"))

  (defun dp-python-indent-command (&optional indent-offset)
    "Indent region if mark is active, the current line otherwise."
    (interactive "*P")
    (if (dp-mark-active-p)
	(progn
	  (py-indent-region (region-beginning) (region-end) indent-offset)
	  ;;(message "indent region")
	  )
      ;;(message "indent line")
      (when dp-orig-python-tab-binding
	(setq this-command dp-orig-python-tab-binding)
	(call-interactively dp-orig-python-tab-binding))))

  (defun dp-py-fix-comment ()
    ;; `save-excursion' doesn't work here.
    ;; ??? marker vs number?
    (let ((pt (point)))
      (end-of-line)
      (when (and (eq (buffer-syntactic-context) 'comment)
		 ;; Don't hose comment only lines.
		 (not (dp-comment-only-line nil nil
					    'except-block-comments-p)))
	(dp-python-indent-command))
      (goto-char pt)))

  (defvar dp-py-cleanup-class-re
    (concat "^\\s-*\\(class\\)\\s-+\\(\\(\\w\\|\\s_\\)+\\)\\s-*"
	    ;; 4  5
	    "\\(\\((?\\)"
	    "\\s-*"
	    ;; 6  7
	    "\\(\\(\\w\\|\\s_\\)*\\)"
	    "\\s-*"
	    ;; 8
	    "\\()?\\)\\)\\(.*\\)$"))

  (defun dp-py-cleanup-class ()
    (interactive)
    ;; For some reason, I see `buffer-syntactic-context' getting hosed
    ;; such that it thinks it's in a string, when it's not.  It seems
    ;; like some kind of latch-up, since it will do that for a while
    ;; and then stop.  Going to `point-min' and calling
    ;; `buffer-syntactic-context' and returning seems to fix it, but...
    ;;  For now, I'll just make sure there's no colon where I want to
    ;;  put one.
    (save-excursion
      (beginning-of-line)
      (when (dp-re-search-forward dp-py-cleanup-class-re (line-end-position) t)
	(replace-match (format "\\1 \\2(%s)\\9"
			       (or (dp-non-empty-string (match-string 6))
				   "object"))))))

  (defun pyit ()
  "Set up a buffer as a Python language buffer.
Inserts `dp-python-new-file-template-file' by default."
  (interactive)
  (when (and buffer-file-name
             (not (string-match dp-ipython-temp-file-re buffer-file-name))
    (let ((comment-start "###"))
      (dp-script-it "python" t
                    :comment-start comment-start
                    :template 'dp-insert-new-file-template
                    :template-args (list dp-python-new-file-template-file))))))

  (dp-py-completion-setup-stolen)

  ;; End of 'dp-use-standard-emacs-python-mode
  )
