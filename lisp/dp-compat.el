;;;
;;; $Id: dp-compat.el,v 1.5 2001/12/31 08:30:12 davep Exp $
;;;
;;; Load the correct set of my compatibility functions, based upon the
;;; current platform.
;;;

(message "dp-compat loading...")

;;
;; load up the proper set of compat cruft.
;;
(if (dp-xemacs-p)
    (load "dp-xemacs-fsf-compat.el")
  (load "dp-fsf-fsf-compat.el"))

;;
;; I could basically put the `then' in the xemacs compat file and the
;; else in the fsf, but I'm getting tired of so many little
;; differences.  Especially when dealing with gratuitous fsf changes.
;; This still beats putting similar code everwhar.
; fsf - (defun dp-completion-at-point ()
; fsf -   (interactive)
; fsf -   (if (dp-xemacs-p)
; fsf -       (lisp-complete-symbol)
; fsf -     (completion-at-point)))

;; I need to have one dp-.*-completion-.* for every case.
;; Easier to make everything global or handle in mode hooks.


(if (dp-xemacs-p)
    (progn
      (defalias 'dp-completion-at-point 'comint-dynamic-complete)
      (defalias 'dp-comint-dynamic-complete 'comint-dynamic-complete)
      (defalias 'dp-minibuffer-complete 'minibuffer-complete)
      (defalias 'dp-lisp-completion-at-point 'lisp-complete-symbol)
)

  (defalias 'dp-completion-at-point 'completion-at-point)
  (defalias 'dp-comint-dynamic-complete 'completion-at-point)
  (defalias 'dp-minibuffer-complete 'minibuffer-complete)
  (defalias 'dp-lisp-completion-at-point 'completion-at-point)
)

;;;
;;;
;;;
(provide 'dp-compat)
(message "dp-compat loading...done")
