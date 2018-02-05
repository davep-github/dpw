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

(defun dp-re-search-forward (regexp &optional limit noerror count buffer)
  (interactive)
  (dp-re-search-forward regexp limit noerror count buffer))

(defun dp-isearch-yank-char (&optional arg)
  (isearch-yank 'forward-char))

(autoload 'eldoc-doc "eldoc" "Display function doc in echo area." t)

(defun dp-elisp-eldoc-doc (&optional insert-template-p)
  (eldoc-doc insert-template-p))

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

(defsubst dp-local-variable-p (symbol buffer &optional after-set)
  (local-variable-p symbol buffer after-set))

;; fsf `yank' does this (now?)
;; I should keep track of the things I missed or that they've
;; rediscovered since I schisim'd from fsf to xemacs.
(defun dp-x-insert-selection (prompt-if-^Ms &optional no-insert-p)
  "Insert the current X Window selection at point, and put text into kill ring."
  (interactive "P")
  (let ((text (dp-with-all-output-to-string
	       (insert-selection))))
    (when (and (string-match "
" text)
	       (or (ding) t)
	       (or (not prompt-if-^Ms)
		   (y-or-n-p "^Ms in text; dedosify")))
      (setq text (replace-in-string text "
" "" 'literal))
      (message "dedos'd"))
    (push-mark (point))
    (unless no-insert-p
      (insert text))
    (setq this-command 'yank)
    (kill-new text)))

(defun dp-push-window-config ()
  (interactive)
  (call-interactively 'wconfig-ring-save))

(defun dp-pop-window-config (n)
  (interactive "p")
  ;; Real pop vs rotate. The yank pop acts, to me, counter-intuitively.
  (call-interactively 'wconfig-delete-pop))


(defalias 'bobp 'dp-bobp)
(defalias 'eobp 'dp-eobp)

(defun dp-isearch-yank-char (&optional arg)
  (interactive)
  (isearch-yank 'forward-char))

(defun dp-set-text-color (tag face &optional begin end detachable-p 
			      start-open-p end-open-p)
  "Set a region's background color to FACE.
Identify the extent w/TAG.
Use BEGIN and END as the limits of the extent."
  ;;(dmessage "b>%s<, e>%s<" begin end)
  (unless (dp-extent-with-property-exists tag begin end)
    (dp-make-extent (or begin (point-min)) (or end (point-max))
                    tag
                    'face face
                    'start-open start-open-p
                    'end-open end-open-p
                    'detachable detachable-p
                    'dp-end nil)))

(defun dp-low-level-server-start (&optional leave-dead inhibit-prompt)
  (gnuserv leave-dead inhibit-prompt)
;;
;; Try for more feature filled gnuserv and fall back
;; to the regular server if gnuserv is not available.
;; gnuserv is always available when I build my own XEmacs.
;;
(defun dp-start-server (&optional leave-or-make-dead-p)
  "Start up an editing server.  Try for gnuserv, then server.
This is a func so it can specified on the command line as something to run or
not."
  (condition-case appease-byte-compiler
      (progn
	(require 'server)
	(message "using server")
	(let ((frame (dp-current-frame)))
          (if (gnuserv-start leave-or-make-dead-p)
              t                         ; Deeniiiiiiied!
            (setq gnuserv-frame frame)
            nil)))
    (error (unless (in-windwoes)
	     (message "using regular server")
	     (server-start)))))
  
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
