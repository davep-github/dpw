;;
;; This file does, unfortunately, kind of double duty being the overall
;; Python config space as well as the python-mode stuff.  Since the Python
;; mode stuff is now in a file called python.el, naming becomes inconsistent.
;;

(dp-loading-require dp-python t

;; Fancy vars...
(defcustom dp-python-new-file-template-file
  (expand-file-name "~/bin/templates/python-template.py")
  "A file to stuff into each new Python file created with `pyit'
or a list: \(function args).
An `undo-boundary' is done before the template is used.
We just barf if the template file is missing."
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
(defalias 'dpy 'dp-python-shell)

;;;###autoload
(defun dp-python-shell-this-window (&optional args)
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

;; ^^^^^^^^^^^^^^^^^^^^^^^^^^ Common ^^^^^^^^^^^^^^^^^^^^^^^^^^
;; vvvvvvvvvvvvvvvvvvvvvvvvvv Emacs  vvvvvvvvvvvvvvvvvvvvvvvvvv
(if (bound-and-true-p dp-use-standard-emacs-python-mode-p)
    (progn
      (dp-defaliases 'dpy 'dp-python 'python-shell-switch-to-shell)

      )
  ;; else my olde/XEmacs hacked together Python/IPython dev environment.
  (require 'dp-olde-python)
)

;; @todo XXX common or olde?
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

;; @todo XXX Extract common.
(defun dp-python-mode-hook ()
  "Set up python *my* way."
  (interactive)
  ;; Python has a problem with my  `dp-fix-comments' function.
  (setq dp-il&md-dont-fix-comments-p t)
  (filladapt-mode)
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
  (local-set-key [(meta up)] 'dp-other-window-up)
  (local-set-key [(meta down)] 'other-window)
  (dp-add-line-too-long-font 'python-font-lock-keywords)
  (setq dp-cleanup-whitespace-p t)
  ;; @todo XXX conditionalize this properly
  ;; dp-trailing-whitespace-font-lock-element

  ;; !<@todo XXX Add this to a new file hook?
  (dp-auto-it?)

;;;;;;;;move to dp-flyspell >>>>> (dp-flyspell-prog-mode)

  (message "`dp-python-mode-hook' finished."))

;;CO; (defadvice py-end-of-def-or-class (before dp-py-eodoc activate)
;;CO;   "Make `py-end-of-def-or-class' leave the region active."
;;CO;   (dp-set-zmacs-region-stays t))

;;
(global-set-key [(control ?c) (control ?z)]
		(kb-lambda
		  (dp-kb-binding-moved arg 'dp-python-shell)))

;;;
;;; Make an? I?Python shell setup file or function?
;;; Not until I have only Python mode or Python type shell package.
;;; For now, assume we have both and leave them both here.
;;;
;;needed w/Elpy? (defun dp-python-get-process ()
;;needed w/Elpy?   (or (get-buffer-process (current-buffer))
;;needed w/Elpy?                                       ;XXX hack for .py buffers
;;needed w/Elpy? 	(get-process py-which-bufname)))

;; Make this a "style" thing (canna think ova better word)?  Putting the
;; hook in the setup file if there is a setup type file.  Otherwise near
;; the setup code or function definition.
(add-hook 'python-mode-hook 'dp-python-mode-hook)

;;needed w/Elpy? (defun dp-py-completion-setup-stolen ()
;;needed w/Elpy?   (let ((python-process (dp-python-get-process)))
;;needed w/Elpy?     (process-send-string
;;needed w/Elpy?      python-process
;;needed w/Elpy?      "from IPython.core.completerlib import module_completion\n")))

;; End of 'dp-use-standard-emacs-python-mode
)
