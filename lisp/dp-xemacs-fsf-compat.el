;;;
;;; $Id: dp-xemacs-fsf-compat.el,v 1.9 2003/10/09 07:30:10 davep Exp $
;;;
;;; Compatibility functions when in xemacs.
;;;

(defvar dp-all-compiler-warnings
  '(redefine callargs subr-callargs
    free-vars unresolved unused-vars obsolete or pedantic)
  "All? of the errors the byte compiler can generate.")

;;definition changed; (defmacro with-no-warnings (&rest body)
;;definition changed;   `(with-byte-compiler-warnings-suppressed dp-all-compiler-warnings
;;definition changed;     ,@body))
;; I'm surprised something like this lasted as long as it did.
;; New, now:
;;new def; `with-byte-compiler-warnings-suppressed-1' is an alias for `progn', a built-in special form
;;new def;   -- loaded from "bytecomp-runtime.el"

;;new def; Documentation:
;;new def; (progn BODY...): eval BODY forms sequentially and return value of last one.
;; butt:
;; (defmacro with-no-warnings (&rest body)
;;   `(with-byte-compiler-warnings-suppressed
;;     ,@body))
;; Actually, `with-no-warnings' is now defined, but where? 
;; Don't know where `with-no-warnings' is defined.
;;
;; I'm colliding with vc-xemacs:
;; From GNU Emacs' byte-run.el
;;from vc-xemacs; (unless (fboundp 'with-no-warnings)
;;from vc-xemacs;   (defun with-no-warnings (&rest body)
;;from vc-xemacs;     (car (last body))))
;; I'll do it too, so we're covered if vc-xemacs isn't around.
;; From GNU Emacs' byte-run.el
(unless (fboundp 'with-no-warnings)
  (defun with-no-warnings (&rest body)
    (car (last body))))

(defsubst transient-mark-mode (arg)
  "Emulate fsf emacs' transient mark mode w/zmacs-regions"
  (setq zmacs-regions (/= arg 0)))

(defun dp-dont-count-outside-minibuffer-p nil
  "*Don't consider the region to be active if it isn't inside the minibuf.")

(defsubst dp-mark-active-p (&optional dont-count-outside-minibuffer-p)
  "Emulate fsf emacs' transient mark activation w/zmacs-regions"
  (and zmacs-region-active-p
       (cons (region-beginning) (region-end))))
(defalias 'dp-region-active-p 'dp-mark-active-p)

(defsubst dp-deactivate-mark ()
  "Emulate fsf emacs' transient mark deactivation w/zmacs-regions"
  (zmacs-deactivate-region))

(defun dp-activate-mark ()
  "Emulate fsf emacs' transient mark activation w/zmacs-regions"
  (zmacs-activate-region))

(defalias 'define-mail-abbrev 'define-mail-alias)
(defalias 'mail-abbrevs-setup 'mail-aliases-setup)

(defalias 'line-beginning-position 'point-at-bol)
(defalias 'line-end-position 'point-at-eol)

(defun dp-set-mark (&optional pos)
  (interactive)
  (set-mark (or pos (point)))
  (progn
    (setq zmacs-region-stays t)
    (zmacs-activate-region)))

(defsubst dp-set-zmacs-region-stays (&optional arg)
  "Written before \(interactive \"_\"\) was discovered. However...
it keeps the region active in more cases. In particular when using one of my
d*beginning|end-of-defun functions. When using just \"_\", the region would
be deactivated when doing a beginning|end followed by an end|beginning."
  (setq zmacs-region-stays arg))


(defun dp-fill-keymap (map filling)
  "Fill keymap MAP with FILLING (caution, filling may be ~HOT~)."
  (let ((i 0))
    (while (< i 128)
      (define-key map (make-string 1 i) filling)
      (setq i (1+ i)))))


; (unless (fboundp 'read-event)
;   ;; Look at what pcomplete does :(cfl "../yokel/lib/xemacs/xemacs-packages/lisp/pcomplete/pcomplete.el" 34334 "^(if (fboundp 'read-event)"):

;   ;; If `read-event' is defined when pcomplete is loaded, then it assumes
;   ;; we're running fsf emacs and then things are hosed.  So, for now, bag
;   ;; this.  I think I hacked it in for some broken package that never worked
;   ;; anyway.  defined.
;   (defsubst read-event (&optional prompt)
;     "Provide fsf emacs' read-event functionality via xemacs' `next-command-event'."
;     (next-command-event nil prompt)))

(defalias 'find-tag-interactive 'find-tag-tag)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Nicked from Emacs.

(unless (boundp 'help-xref-following)
  (defvar help-xref-following nil
    "Non-nil when following a help cross-reference."))

(unless (fboundp 'help-buffer)
  (defun help-buffer ()
    (buffer-name                        ;for with-output-to-temp-buffer
     (if help-xref-following
         (current-buffer)
       (get-buffer-create "*Help*")))))

;;; End nickage.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ??? ;;    (generate-new-buffer-name "*Semantic-Help*")))


;; Want to set this font in elisp somehow
;; Font -*-courier-medium-r-*-*-*-140-*-*-*-*-iso8859-*
