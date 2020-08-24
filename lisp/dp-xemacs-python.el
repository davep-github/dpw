(dp-loading-require 'dp-olde-python t
;; Olde, ergo, all or mostly XEmacs-ian.
;;;###autoload
  (defun* dp-python-shell (&optional args)
    "Start up python shell and then run my shell-mode-hook since they
set the key-map after the hook has run.
@todo XXX Can this go away with the new Emacs Python mode/support stuff."
    (interactive "P")
    ;; Hide history file... we'll manage it oursefs.
    ;; Hack around for python-mode bug:
    ;; It, `py-shell', sets mode name before switching to the Python buffer.
    (let ((py-buf (get-buffer "*Python*")))
      (when py-buf
	(dp-visit-or-switch-to-buffer py-buf)
      (return-from dp-python-shell)))

  (let ((dp-real-comint-read-input-ring (symbol-function
                                         'comint-read-input-ring))
        mode-name input-ring-name)
    ;; Fucking ipython's advice for py-shell reads in the history before
    ;; switching to the Python shell buffer.  So if, e.g., we're in a regular
    ;; shell buffer, its history is hosed.  So we'll spoof the read and
    ;; capture the file name they want to read and use that as our history
    ;; file and read that AT ZE *RIGHT* TIME!
    (cl-flet ((comint-read-input-ring
	       (&rest r)
	       (dmessage "in dummy comint-read-input-ring")
	       (setq input-ring-name comint-input-ring-file-name)))
      (py-shell args))
    (setq comint-input-ring-file-name input-ring-name))
  ;; This should be done in the Python buffer by `py-shell', but isn't.
  (setq mode-name "Python")
  (setq dp-ima-dpy-buffer-p t)
  (dp-maybe-read-input-ring)
  (unless (eq dp-latest-py-shell-buffer (current-buffer))
    (setq dp-latest-py-shell-buffer (current-buffer))
    (local-set-key "\C-c\C-b" 'dpy-reload)
    (dp-py-shell-hook))
  (add-local-hook 'kill-buffer-hook 'dp-ipython-buffer-killed))

(defadvice py-end-of-def-or-class (around dp-py-end-of-def-or-class activate)
  "If preceeding command was `dp-beginning-of-def-or-class' do a go-back.
Otherwise business as usual.
Also leave the region active."
  (dp-set-zmacs-region-stays t)
  (if (eq last-command 'dp-beginning-of-def-or-class)
      (dp-pop-go-back)
    ad-do-it))

;;;###autoload
(defun dp-py-shell-hook ()		;<:psh|pysh:>
  "Set up my python shell mode fiddle-faddle."
  (interactive)
  (dmessage "in dp-py-shell-hook")
  (make-variable-buffer-local 'dp-wants-ansi-color-p)
  (dp-maybe-add-ansi-color nil)
  (dp-specialized-shell-setup "~/.ipython/history"
			      'bind-enter
			      ;; these are args to
			      ;; `dp-bind-shell-type-enter-key'
			      :keymap py-shell-map
			      :dp-ef-before-pmark-func nil
			      ;; ?????? 'dp-ignore-this-mode
			      )
  (when (fboundp 'ipython-complete)
    (local-set-key [tab] 'ipython-complete))

  (dp-define-buffer-local-keys
   '([(meta return)] dp-end-of-line-and-enter
     "\C-d" dp-shell-delchar-or-quit
     [(control backspace)] dp-ipython-backward-delete-word)
   nil nil nil "dpsh"))

(defun dp-python-indent-command (&optional indent-offset)
  "Indent region if mark is active, the current line otherwise."
  (interactive "*P")
  (if (dp-mark-active-p)
      (progn
	(py-indent-region (region-beginning) (region-end) indent-offset)
	;;(message "indent region")
	)
    ;;(message "indent line")
    (when dp-orig-python-tab-binding
      (setq this-command dp-orig-python-tab-binding)
      (call-interactively dp-orig-python-tab-binding))))

(defun dp-py-cleanup-class ()
  (interactive)
  ;; For some reason, I see `buffer-syntactic-context' getting hosed
  ;; such that it thinks it's in a string, when it's not.  It seems
  ;; like some kind of latch-up, since it will do that for a while
  ;; and then stop.  Going to `point-min' and calling
  ;; `buffer-syntactic-context' and returning seems to fix it, but...
  ;;  For now, I'll just make sure there's no colon where I want to
  ;;  put one.
  (save-excursion
    (beginning-of-line)
    (when (dp-re-search-forward dp-py-cleanup-class-re (line-end-position) t)
      (replace-match (format "\\1 \\2(%s)\\9"
			     (or (dp-non-empty-string (match-string 6))
				 "object"))))))

  ;; needed w/Elpy? (dp-py-completion-setup-stolen)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
)
