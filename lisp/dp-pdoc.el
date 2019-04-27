;;
;; $Id: dp-pdoc.el,v 1.6 2002/11/06 08:30:09 davep Exp $
;; programming documentation functions
;;

;;
;; Issue: C++ functions pointing into the header's class
;;  1) We can't use "^name" due to inclass indentation.
;;  2) Extracted function name will have class::function format
;;     which func decl in class will not have.

(require 'func-menu)
(require 'regexp-opt)

(defvar pd-my-hfile nil
"The include file associated with this source file.
The include file will be the source file's name w/
c--> or cxx-->hxx translation")
(make-variable-buffer-local 'pd-my-hfile)

(defun pd-mark-func-def ()
  "Mark the current C function."
  (interactive)
  (c-mark-function))

(defun pd-in-topmost-intro ()
  "Return t if inside topmost-intro."
  (let ((syntax-el (car (car (c-guess-basic-syntax)))))
    (eq syntax-el 'topmost-intro)))

(defun pd-mark-func-def2 ()
  "Put mark and point around the function definition that point
is currently inside.
Use cc-mode syntax to find the limits."
  (interactive)
  ;;
  (dp-c-beginning-of-statement)
  (set-mark (point))
  ;; find the end of the def... the matching close paren after
  ;; the first open paren
  (dp-re-search-forward "(")		; it must be there
  (goto-char (match-beginning 0))
  (dp-find-matching-paren))


(defun pd-make-file-ext-pat (ext-list)
  (interactive)
  (concat "\\(.*\\)\\.\\("
	  (dp-string-join ext-list "\\|")
	  "\\)$"))

(defvar pd-src-to-hdr-ext-map
  (list (cons (pd-make-file-ext-pat '("c")) ".h")
	(cons (pd-make-file-ext-pat '("cc" "cxx" "c\\+\\+" "C")) ".h")))

(defvar pd-c-or-c++-pat
  (concat "\\(.*\\)\\.\\("
	  (dp-string-join '("c" "cc" "cxx" "c\\+\\+" "C") "\\|")
	  "\\)$")
  "RE to match a C-type file.")

;;
;; XXX - TODO - have the maps return an ordered list of extensions to try
;; and have the consumer of this routine loop until one makes a
;; a filename that exists.
(defun pd-map-src-to-hdr-ext (src-file)
  (interactive "Ffile: ")
  (catch 'got-hdr
    (mapcar (function
	     (lambda (pat-ext-cons)
	       (message "pat-ext-cons>%s<" pat-ext-cons)
	       (message "doing posix-str-match %s %s"
			(car pat-ext-cons) src-file)
	       (if (posix-string-match (car pat-ext-cons) src-file)
		   (progn
		     (message "throwing >%s<" (cdr pat-ext-cons))
		     (throw 'got-hdr (cdr pat-ext-cons)))
		 (message "no match"))))
	    pd-src-to-hdr-ext-map)
    nil))

(defvar pd-expand-file-name-func 'identity
  "Func to expand a file name")

(defun pd-get-inc-dir ()
  "Determine the include dir for the given file."
  (interactive)
  (let ((inc-dir
	(save-excursion
	  (goto-char (point-min))
	  (save-match-data
	    (if (dp-re-search-forward
		 "^\\s-*/?\\*\\s-*pdoc-inc-dir:\\s-*\\([^ 	]+\\)" nil t)
		(buffer-substring (match-beginning 1) (match-end 1))
	      nil)))))
    (unless inc-dir
      (setq inc-dir (dp-read-file-name "inc dir: " "." ".")))
    (save-match-data
      (if (posix-string-match "\\(.*\\)/$" inc-dir)
	  (match-string 1 inc-dir)
	inc-dir))))

(defun pd-find-hfile (&optional src-name)
  "Find the hfile associated with the current source file."
  (interactive)
  ;; (setq pd-my-hfile nil)		;for debugging, so we always recompute
  (if (null pd-my-hfile)
      (let (hext
	    incdir)
	(unless src-name
	  (setq src-name (buffer-file-name)))
	;; prepare the hfile's name
	(setq hext (pd-map-src-to-hdr-ext src-name))
	(if hext
	    (let ((fn-beg (match-beginning 1))
		  (fn-end (match-end 1)))
	      ;; ask the user where his includes are...
	      (setq incdir (pd-get-inc-dir))
	      (message "incdir>%s<" incdir)
	      (message "name>%s<" (substring src-name fn-beg fn-end))
	      (setq pd-my-hfile (funcall pd-expand-file-name-func
				 (concat
				  incdir "/"
				  (file-name-nondirectory
				   (substring
				    src-name
				    fn-beg
				    fn-end))
				  hext))))
	  (message "*** cannot determine hdr extension for >%s<" src-name))
	;;(message "pd-my-hfile>%s<" pd-my-hfile)
	))
  pd-my-hfile)

(defun pd-next-func-link (&optional func)
  "Return a `link' to the function's doc comment in the related header file.
Scan forward from point for the next function definition.  Construct a
link consisting of the corresponding header file as determined
by `pd-find-hfile' a separator (`#') and the function name."
  (interactive)
  (unless func
    (save-excursion
      ;; go forward to the next function
      (fume-scan-buffer)
      (let ((fume-function-name-regexp fume-function-name-regexp))
	(if (listp fume-function-name-regexp)
	    (setq fume-function-name-regexp
		  (car fume-function-name-regexp)))
      (fume-find-next-function-name (current-buffer))
      (setq func (buffer-substring (line-beginning-position) (point))))))
  (unless (pd-find-hfile)
    (error "No hfile defined for this file."))
  (concat pd-my-hfile "#" func))

(defun pd-goto-doc (&optional func)
  "Goto the documenting comment for the function at or after point."
  (interactive)
  (dp-goto-file+re (pd-next-func-link func)))

(defun pd-insert-doc-link (&optional func)
  (interactive)
  (insert (pd-next-func-link func)))
(defalias 'pdil 'pd-insert-doc-link)

(defun pdf()
  "Add a document to a function."
  (interactive)
  (pd-find-hfile)
)
