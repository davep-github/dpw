(message "dp-fsf-early loading...")

(defun dp-ibuffer-do-and-update (op &rest op-args)
  "Do an ibuffer operation and then refresh the buffer."
  (apply op op-args)
  (ibuffer-update))

(defun dp-ibuffer-do-save ()
  "Save and then refresh the buffer."
  (interactive)
  (dp-ibuffer-do-and-update 'ibuffer-do-save))

(defcustom py-block-comment-prefix "##"
  "*String used by \\[comment-region] to comment out a block of code.
This should follow the convention for non-indenting comment lines so
that the indentation commands won't get confused (i.e., the string
should be of the form `#x...' where `x' is not a blank or a tab, and
`...' is arbitrary).  However, this string should not end in whitespace."
  :type 'string
  :group 'python)

(defun dp-stolen-sudo-edit (&optional arg)
  "Edit a file as root. With a prefix ARG edit the current file as root
Will also prompt for a file to visit if currentbuffer is not visiting a file."
  (interactive "P")
  (if (or (not arg) (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:"
			 (ido-read-file-name "Find file(as root): ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))
(defalias 'dse 'dp-stolen-sudo-edit)

(defun dset ()
  (interactive)
  (dp-stolen-sudo-edit t))

(require 'autoload)
;; "See Emacs' def of generated-autoload-file."
(make-variable-buffer-local 'generated-autoload-file)
(setq-default generated-autoload-file
	      (expand-file-name "auto-dp-autoloads.el"
				dp-lisp-dir))


;; stolen
(defun dp-update-autoloads ()
  "Call `update-autoloads-from-directories' on my local lisp directory."
  (interactive)
  (update-directory-autoloads (file-name-directory generated-autoload-file))
  (byte-compile-file generated-autoload-file))

(provide 'dp-fsf)
(message "dp-fsf-early loading...done.")
