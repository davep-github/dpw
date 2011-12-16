(require 'mmm-auto)
(require 'mmm-vars)

(defun dp-mmm-univ-back (stop)
  "Match back end of mode delimitter.  We need our own function here
since we want to regexp-quote the opening delimitter (?for c++?)."
  (let* ((back "{%/~1%}")
	 (pos (concat "^" (regexp-quote (mmm-format-matches back)))))
    ;;(dmessage "pos>%s<" pos)
    (mmm-match-and-verify pos nil stop nil)))

(defun dp-mmm-univ-get-mode (string)
  ;;(dmessage "string, 0>%s<" string)
  (string-match "{%\\([^/].*?\\)%}" string)
  (setq string (dp-regexp-dequote (match-string 1 string)))
  ;;(dmessage "string, 1>%s<" string)
  (let ((modestr (intern (if (string-match "mode\\'" string)
                             string
                           (concat string "-mode")))))
    (or (mmm-ensure-modename modestr)
	;;(and (dmessage "no such mode>%s<" modestr)
	;;     nil)
        (signal 'mmm-no-matching-submode nil))))

(defun dp-mmm-no-regexp-quote-form ()
  ;;(dmessage "ms>%s<, point>%s<" (match-string 0) (point))
  (match-string 0))

(mmm-add-classes
 `((dp-universal
    :front "^{%\\([^/].*?\\)%}"
;    :front-form dp-mmm-no-regexp-quote-form
    :back dp-mmm-univ-back
    :back "{%/~1%}"
    :insert ((?/ dp-universal "Submode: " @ "{%" str "%}" @ "\n" _ "\n"
                 @ "{%/" str "%}" @))
    :match-submode dp-mmm-univ-get-mode
    :save-matches 1
    )))

;; completion list.  wants value in car of list item.
(defvar dp-mmm-add-mm-mode-list '(("c++-mode") ("c-mode") ("text-mode") 
                                  ("python-mode") ("cperl-mode")
				  ("antlr-mode") ("fundamental-mode") ("shell-script-mode")
				  ("outline-mode") ("emacs-lisp-mode") ("diff-mode") 
				  ("haskell-mode") ("makefile-mode")
				  )
  "Completion list for modes.")

(defun dp-mmm-add-mm (&optional mode)
  "Add an MMM region.  Uses completion from modes in `dp-mmm-add-mm-mode-list'.
Also parses the region after adding the delimitters to get proper mode
behavior in the new region."
  (interactive)
  (unless mode
    (setq mode (completing-read "mode? " dp-mmm-add-mm-mode-list))
    (unless (intern-soft mode)
      (ding)
      (message "`%s' is not a currently defined symbol." mode)))
  (setq mode (intern-soft mode))
  (let (rcopy)
    (save-excursion
      (dp-mark-line-if-no-mark)
      (let ((region (car (io-region (mark) (point) 
                                    (format "{%%%s%%}" mode)
                                    (format "{%%/%s%%}" mode)
                                    'no-complaints))))
        (unless (Cu--p)
          (setq rcopy region)
          (when (memq mode '(c-mode c++-mode))
            (c-init-language-vars-for mode))
          (mmm-parse-region (car region) 
                            (cdr region))
          (setcar rcopy nil)
          (setcdr rcopy nil))))))

(defalias 'amm 'dp-mmm-add-mm)

;(unless (memq 'dp-universal mmm-global-classes)
;  (setq mmm-global-classes (cons 'dp-universal mmm-global-classes)))

(defun dp-mmm-in-any-subregion-p (&optional pos)
  (dolist (extent (extents-at (or pos (point))) nil)
    (if (get extent 'mmm)
        (return t))))
		      
(provide 'dp-mmm)


;;; Local Variables:
;;; mmm-global-classes: nil
;;; End:

;;; mmm-univ.el ends here
