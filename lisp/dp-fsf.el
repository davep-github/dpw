(message "dp-fsf loading...")

;; FSF code.  Port to xemacs if needed.

(eval-when-compile (require 'subr-x))

(setq isearch-continues 'isearch-scroll
      custom-file (expand-file-name "fsf-custom.el"
				    (file-name-directory user-init-file))
      apropos-do-all t
      )
(load custom-file)

(defun dp-ibuffer-do-save ()
  "Save and then refresh the buffer."
  (interactive)
  (ibuffer-mark-forward nil nil 1)
  (ibuffer-do-save)
  (previous-line)
  (ibuffer-unmark-forward nil nil 1)
  (previous-line)
  (call-interactively 'ibuffer-update))

;; (defadvice manual-entry (after dp-advised-manual-entry act)

(defadvice ibuffer-forward-line (after dp-ibuffer-advisements act)
  (dp-ibuffer-current-filename-show))

(defadvice ibuffer-backward-line (after dp-ibuffer-advisements act)
  (dp-ibuffer-current-filename-show))

(defun dp-ibuffer-current-filename (&optional must-be-live-p)
  (interactive "P")
  (if-let ((buf (ibuffer-current-buffer must-be-live-p)))
      (buffer-file-name buf)
    buf))

(defun dp-ibuffer-current-filename-show (&optional must-be-live-p)
  (interactive "P")
  (message-nl "%s" (dp-ibuffer-current-filename must-be-live-p)))

(defun dp-ibuffer-current-buffer-name (&optional must-be-live-p)
  (interactive "P")
  (if-let ((buf (ibuffer-current-buffer must-be-live-p)))
      (buffer-name buf)
    buf))

(defun dp-ibuffer-current-buffer-name-show (&optional must-be-live-p)
  (interactive "P")
  (message-nl "%s" (dp-ibuffer-current-buffer-name must-be-live-p)))

(defcustom py-block-comment-prefix "##"
  "*String used by \\[comment-region] to comment out a block of code.
This should follow the convention for non-indenting comment lines so
that the indentation commands won't get confused (i.e., the string
should be of the form `#x...' where `x' is not a blank or a tab, and
`...' is arbitrary).  However, this string should not end in whitespace."
  :type 'string
  :group 'python)

(defvar dp-sudo-editing-file nil)

(defun dp-dse-this-buffer-once (name)
  (cond
   ((dp-dse-file-p name)
    (error "File is already being dp-sudo-edited"))
   ((dp-sudo-editing-file-p name)
    (error "File is already being edited by root with tramp"))))

(defun dp-stolen-sudo-edit (&optional dse-this-buffer-p)
  "Edit a file as root. With a prefix or DSE-THIS-BUFFER-P non-nil
edit the current file as root. Will prompt for a file to visit if
current buffer is not visiting a file."
  (interactive "P")
  (dp-dse-this-buffer-once (buffer-file-name))
  (if (and dse-this-buffer-p buffer-file-name)
      (find-alternate-file (concat dp-sudo-edit-tramp-local-prefix
				   buffer-file-name))
    (find-file (read-file-name "Find file(as root): "
			       dp-sudo-edit-tramp-local-prefix
			       nil
			       nil
			       default-directory)))
  (dp-set-buffer-background-color 'dp-sudo-edit-bg-face))

(defalias 'dse-tramp 'dp-stolen-sudo-edit)

(defun dse (&optional file-name)
  "Edit a file as root; `dp sudo edit'.
The stolen one above is slow when using completion."
  (interactive "GFind file (as root): ")

  ;; Can't do this because it changes the file name and then we can't tell
  ;; that we are already sudo editing the file.  Using buffer local vars had
  ;; wierd problems, but I'll try again.
  (find-file file-name)
  ;; this op is fast since we know the name and we're local.
  (dp-sudo-edit-this-file)
  )

(defun dp-sudo-edit-this-file ()
  "`dse this' sudo edit the file in the current buffer."
  (interactive)
  (when (dp-remote-file-p)
    (error "I can't dse a remote file... yet"))
  (dp-stolen-sudo-edit 'dse-this-buffer)
  (unless (string-match "<dse>\\(<[0-9]+>\\)?$" (buffer-name))
    (rename-buffer (concat (buffer-name) "<dse>"))
    (rename-uniquely)))

;;; XXX --> fix require order... (dp-defaliases 'dset 'dp-sudo-edit-this-file)
(defalias 'dset 'dp-sudo-edit-this-file)

(defun dsed (&optional sudead-buf)
  "Stop sudo editing this buffer."
  (interactive)
  (setq-ifnil sudead-buf (current-buffer))
  (let ((point (point))
	(file-to-load (symbol-value-in-buffer
		       'dp-sudo-editing-file sudead-buf)))
    (unless file-to-load
      (error "File is not being sudo edited"))
    (when (buffer-modified-p)
      (error "Buffer is modified. Save or revert first."))

    (find-file file-to-load)
    (set-symbol-value-in-buffer 'dp-sudo-editing-file nil)
    (kill-buffer sudead-buf)))

(require 'autoload)
;; "See Emacs' def of generated-autoload-file."
(make-variable-buffer-local 'generated-autoload-file)
(setq-default generated-autoload-file
	      (expand-file-name "auto-dp-autoloads.el"
				dp-lisp-dir))

(defun dp-describe-text-properties (num-chars-to-move
				    &optional output-buffer buffer)
  (interactive "P")
  (if (not num-chars-to-move)
      (call-interactively 'describe-text-properties)
    (save-excursion
      (goto-char (+ (point) (prefix-numeric-value num-chars-to-move)))
      (describe-text-properties (point) output-buffer buffer))
    (message "May not include dynamic properties, e.g. paren match color.")))

(provide 'dp-fsf)
(message "dp-fsf loading...done.")
