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

(provide 'dp-fsf)
(message "dp-fsf-early loading...done.")
