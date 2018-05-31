;;
;; We need to hack a function, so let's isolate all the magit stuff.

(message "load dp-magit()...")

(require 'magit)

(defun dp-magit-mode-setup-hook ()
  )

(defun dp-magit-mode-hook ()
  (interactive)
  (dp-local-set-keys
   '([?=] magit-diff-dwim)))

;; Nice convention to put key bindings for modes alone in a function.
;; <clutch-pearls-on-soap-box>Wah! Name space pollution!</clutch-pearls-on-soap-box>
;; Make modification and application easier.
(defun dp-magit-rebase-bind-keys ()
  (dp-define-local-keys '(
			  [(meta down)] other-window
			  [(meta up)] dp-other-window-up
			  [(shift down)] git-rebase-move-line-down
			  [(shift up)] git-rebase-move-line-up
			  ;; git-rebase-kill-lines does one line.
			  ;; we do one by default, else does prefix-arg lines.
			  [?k] dp-magit-rebase-kill-lines
			  ;; Buffer is RO, so
			  ;; `dp-delete-to-end-of-line' can't be used,
			  ;; so remap it.  We are essentially killing
			  ;; the line.
			  [(meta ?k)] dp-magit-rebase-kill-lines
			  [(meta return)] magit-section-toggle
			  [(meta left)] magit-section-backward
			  [(meta right)] magit-section-forward
			  )
			))

(add-hook 'magit-mode-hook 'dp-magit-mode-hook)

(defun dp-magit-rebase-mode-hook ()
  (dp-magit-rebase-bind-keys)		; YAY! More keymaps broken.
  )
(add-hook 'git-rebase-mode-hook 'dp-magit-rebase-mode-hook)

;;
;; Sometimes the original version works.
;; Dunno why.
;; Repo state/contents?
;; version.
;;
(defun dp-magit-rebase-kill-lines (&optional num-lines)
  "Call `git-rebase-kill-lines' NUM-LINES times.
If NUM-LINES:
region active -- lines in region.
eq '- -- all lines till EOB.
= 9 -- all lines.
else: NUM-LINES lines.
"
  (interactive "p")
  (setq num-lines
	(cond
	 ((dp-region-active-p)
	  (goto-char (car (dp-region-boundaries-ordered)))
	  (dp-number-lines-region))
	 ((numberp num-lines)
	  (cond
	   ((< num-lines 0)
	    (count-lines (point) (point-max)))
	   ((equal num-lines 0)
	    (goto-char (point-min))
	    (count-lines (point-min) (point-max)))
	   (t num-lines)))
	 (t
	  (error "Can't determine NUM-LINES from arg>%s<" num-lines))
	 ))

  ;; Make sure rebase code doesn't move to the next line since it
  ;; won't move if the line is already killed.
  (let ((git-rebase-auto-advance nil))
    (dotimes (line-num num-lines)
      (git-rebase-kill-line)
      (forward-line))))

(defun dp-magit-hide-untracked ()
  (interactive)
  (save-excursion ; May not work depending on how the collapsing works.
    (magit-jump-to-untracked)
    (call-interactively 'magit-section-hide)))

;; This hack isn't needed at work.
;; And now tis not need at home.
;; (defun magit-log-format-margin (author date)
;;   (-when-let (option (magit-margin-option))
;;     (-let [(_ style width details details-width)
;;            (or magit-buffer-margin
;;                (symbol-value option))]
;;       (magit-make-margin-overlay
;;        (concat (and details
;;                     (concat (propertize (truncate-string-to-width
;;                                          (or author "")
;;                                          details-width
;;                                          nil ?\s (make-string 1 magit-ellipsis))
;;                                         'face 'magit-log-author)
;;                             " "))
;;                (propertize
;;                 (if (stringp style)
;;                     (format-time-string
;;                      style
;;                      (seconds-to-time (string-to-number date)))
;;                   (-let* ((abbr (eq style 'age-abbreviated))
;;                           ((cnt unit) (magit--age date abbr)))
;;                     (format (format (if abbr "%%2i%%-%ic" "%%2i %%-%is")
;;                                     (- (funcall width style details details-width)
;; 				       (if details (1+ details-width) 0)))
;;                             cnt unit)))
;;                 'face 'magit-log-date))))))

(provide 'dp-magit)

(message "load dp-magit()... done.")
