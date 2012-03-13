;;;
;;; $Id: dp-makefile-mode.el,v 1.3 2003/08/07 07:30:09 davep Exp $
;;;
;;; Makefile mode extensions.
;;;

;;
;; Snatched from ~weikart/.emacs
;; When editing a makefile, this sets the compile command to include
;; the name of the makefile, which is nice if you are using an oddly
;; named makefile.
(setq compile-make-command "make")
;; default compile command
(setq compile-command (concat compile-make-command " -k ")) 
(add-hook 'makefile-mode-hook ;; for *.mak, etc...
	  'dp-makefile-mode-hook)

(defvar dp-makefile-mode-parenthesize-region-paren-list
  '(("(" . ")")
    ("{" . "}")
    ("\"" . "\"")
    ("'" . "'")
    ("`" . "`")
    ("[" . "]")
    ("<" . ">")
    ("<:" . ":>")
    ("*" . "*")
    ("`" . "'")
    ("" . ""))
  "Makefile mode's Parenthesizing pairs to try, in order.
See `dp-parenthesize-region-paren-list'")

(dp-add-mode-paren-list 'makefile-mode
                        dp-makefile-mode-parenthesize-region-paren-list)

(defun dp-makefile-mode-hook ()
  "Set up makefile-mode *my* way."
  (if (local-variable-p 'compile-command (current-buffer))
      () ;; already there, do nothing
    (make-local-variable 'compile-command)
    (setq compile-command 
	  (concat compile-make-command 
		  " -k -f " 
                  (if (buffer-file-name)
                      (file-name-nondirectory (buffer-file-name))
                    "")
                  " "))
                  
    (message "compile command: %s" compile-command))
  (dp-save-orig-n-set-new 'makefile-font-lock-keywords 
                          'dp-append-to-list-symbol nil
                          (list dp-trailing-whitespace-font-lock-element))
  
  (local-set-key "\e[" 'dp-makefile-mode-find-matching-paren)
  (local-set-key [(meta ?p)] 'dp-parenthesize-region))


(defalias 'make 'dp-make)

(defvar dp-makefile-mode-ifx-re-alist 
  '((dp-if . "[.]?[ 	]*if")		; gets #if, #ifdef and #ifndef.
    (dp-else . "[.]?[ 	]*else")
    (dp-elif . "[.]?[ 	]*elif")	; ignored by the hideif stuff.
    (dp-endif . "[.]?[ 	]*endif"))
  "alist of regexps to find and identify CPP conditional directives")

(defun dp-makefile-mode-find-matching-paren ()
  "Find matching makefile conditional (e.g. ifdef/endif)."
  (interactive)
  (let* ((hif-ifndef-regexp "^[.]?ifndef")
	 (hif-ifx-regexp "^[.]?if\\(n?\\(def\\|eq\\)\\)?[ \t]*")
	 (hif-else-regexp "^[.]?else")
	 (hif-endif-regexp "^[.]?endif")
	 (hif-ifx-else-endif-regexp
	  (concat hif-ifx-regexp "\\|" 
		  hif-else-regexp "\\|" hif-endif-regexp)))
    (dp-find-matching-paren dp-makefile-mode-ifx-re-alist)))

(provide 'dp-makefile-mode)
