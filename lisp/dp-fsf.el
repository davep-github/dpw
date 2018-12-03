(message "dp-fsf loading...")

(setq isearch-continues 'isearch-scroll
      custom-file (dp-lisp-subdir
		   (format "fsf-custom.%s.el" (dp-short-hostname)))
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

(defcustom py-block-comment-prefix "##"
  "*String used by \\[comment-region] to comment out a block of code.
This should follow the convention for non-indenting comment lines so
that the indentation commands won't get confused (i.e., the string
should be of the form `#x...' where `x' is not a blank or a tab, and
`...' is arbitrary).  However, this string should not end in whitespace."
  :type 'string
  :group 'python)

(defcustom dp-sudo-edit-tramp-local-prefix "/sudo:root@localhost:"
  "Used to tell tramp(q.v) to use sudo to open and edit a file.")

(defun dp-stolen-sudo-edit (&optional dse-this-buffer-p)
  "Edit a file as root. With a prefix or DSE-THIS-BUFFER-P non-nil
edit the current file as root. Will prompt for a file to visit if
current buffer is not visiting a file."
  (interactive "P")
  (let (file-name)
    (if (and dse-this-buffer-p buffer-file-name)
	(find-alternate-file (concat dp-sudo-edit-tramp-local-prefix
				     buffer-file-name))
      (find-file (read-file-name "Find file(as root): "
				 dp-sudo-edit-tramp-local-prefix
				 nil
				 nil
				 default-directory)))))
(defalias 'dse-tramp 'dp-stolen-sudo-edit)

(defun dse (&optional file-name)
  "Edit a file as root; `dp sudo edit'.
The stolen one above is slow when using completion."
  (interactive "Gfile name: ")
  (find-file file-name)
  (dset)
  )    ; this op is fast since we know the name and we're local.

(defun dset ()
  "`dse this' sudo edit the file in the current buffer."
  (interactive)
  (dp-stolen-sudo-edit 'dse-this-buffer)
  (unless (string-match "<dse>\\(<[0-9]+>\\)?$" (buffer-name))
    (rename-buffer (concat (buffer-name) "<dse>"))
    (rename-uniquely)))

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
(message "dp-fsf loading...done.")
