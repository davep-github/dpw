;;;
;;; $Id: dp-debug.el,v 1.1 2003/06/02 07:30:08 davep Exp $
;;;
;;; elisp debugging code.
;;;

(eval-when-compile
  (require 'cl))

(defvar dp-message-grep-regexps '()
  "List of regexps to grep for in calls to `message'.")

(defvar dp-insert-grep-regexps '()
  "list of regexps to grep for in calls to `insert'.")

(defvar dp-original-message (symbol-function 'message)
  "Original value of `message' function.")

(defvar dp-original-insert  (symbol-function 'insert)
  "Original value of `insert' function.")

(defvar dp-break-action 'debug
  "Call this when a regexp matches.")

(defun dp-grep-list (regexps &rest args)
  (dolist (arg args)
    (when (stringp arg)
      (dolist (regexp regexps)
	(if (string-match regexp arg)
	    (funcall dp-break-action)
	  )))))

(defun dp-message-grep (fmt &rest args)
  (when fmt
    (let ((s (apply 'format fmt args)))
      (dp-grep-list dp-message-grep-regexps s)
      (funcall dp-original-message "%s\n" s))))

(defun dp-insert-grep (&rest args)
  (apply 'dp-grep-list dp-insert-grep-regexps args)
  (apply dp-original-insert args))

;;;###autoload
(defun dp-hook-message ()
  (interactive)
  (fset 'message 'dp-message-grep))

;;;###autoload
(defun dp-hook-insert ()
  (interactive)
  (fset 'insert 'dp-insert-grep))

;;;###autoload
(defun dp-unhook-message ()
  (interactive)
  (fset 'message dp-original-message))

;;;###autoload
(defun dp-unhook-insert ()
  (interactive)
  (fset 'insert dp-original-insert))

(defun dp-dump-match-data-at-point ()
  "I've used it to find the correct fields to use when dealing with hairy REs.
It's nice for running test cases to ensure the RE groups are matching what
you want them to. E.g
def d\():                                # PASS
def d
match data:

\[0]def d<
\[1]def d<
\[2]<
\[3]def<
\[4]<
\[5]<
\[6]<
\[7]nil<
\[8]nil<
\[9]nil<
\[10]nil<
\[11]nil<
\[12]nil<
\[13]nil<
"
  (save-excursion
    (princ 
     (concat "\n'''\n"
             (dmessage "%s\nmatch data:\n%s\n"
                       (buffer-substring (line-beginning-position)
                                         (line-end-position))
                       (dp-all-match-strings-string 
                        :sj-args '("\n" t t t)))
             "'''\npass # NOT the test result!")
     (current-buffer))))
