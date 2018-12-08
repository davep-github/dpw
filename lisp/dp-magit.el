;;
;; We need to hack a function, so let's isolate all the magit stuff.

(message "load dp-magit()...")

(require 'magit)
(add-hook 'magit-mode-hook 'magit-stgit-mode)

(defun dp-magit-mode-setup-hook ()
  )

(defun dp-magit-mode-bind-keys ()
  (interactive)
  (dp-local-set-keys
   '(
     [?=] magit-diff-dwim
     [(meta return)] magit-section-toggle
     [(meta left)] magit-section-backward
     [(meta right)] magit-section-forward
     )
   ))

(defun dp-magit-mode-hook ()
  (interactive)
  (dp-magit-mode-bind-keys))

;; Nice convention to put key bindings for modes alone in a function.
;; <clutch-pearls-on-soap-box>Wah! Name space pollution!</clutch-pearls-on-soap-box>
;; Make modification and application easier.
(defun dp-magit-rebase-bind-keys ()
  (interactive)
  (dp-define-local-keys
   '(
     [(meta down)] other-window
     [(meta up)] dp-other-window-up
     [(shift down)] git-rebase-move-line-down
     [(shift up)] git-rebase-move-line-up
     ;; git-rebase-kill-lines does one line.
     ;; we do one by default, else does prefix-arg lines.
     ;; Buffer is RO, so
     ;; `dp-delete-to-end-of-line' can't be used,
     ;; so remap it.  We are essentially killing
     ;; the line.
     [(meta ?k)] dp-magit-rebase-kill-lines
     [(meta return)] magit-section-toggle
     [(meta left)] magit-section-backward
     [(meta right)] magit-section-forward
     [(tab)] git-rebase-show-or-scroll-up
     [(meta ?d)] git-rebase-kill-line
     )
   ))

(add-hook 'magit-mode-hook 'dp-magit-mode-hook)

(defun dp-magit-rebase-mode-hook ()
  (dp-magit-rebase-bind-keys)		; YAY! More keymaps broken.
  )
(add-hook 'git-rebase-mode-hook 'dp-magit-rebase-mode-hook)

(defun dp-git-commit-setup-bind-keys ()
  (interactive)
  (dp-define-keys
   git-commit-mode-map
   '(
     [(meta ?p)] dp-parenthesize-region
     [(control ?x) (control ?p)] git-commit-prev-message
     [(control ?x) (control ?n)] git-commit-next-message
     )))

(defun dp-git-commit-setup-hook ()
  (interactive)
  (dp-git-commit-setup-bind-keys))

(add-hook 'git-commit-setup-hook 'dp-git-commit-setup-hook)
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
(dp-defaliases 'dmhu 'mhut 'hut 'dp-magit-hide-untracked)

(defun dp-magit-found-file-hook ()
  "Matched (cond)itions must return non-nil."
  (let ((bfn (expand-file-name buffer-file-name)))
    (cond
     ;; Yummy! Hard coding.
     ((string-match "\\(^\\|/\\)COMMIT_EDITMSG$" bfn)
      (goto-char (point-min))
      (message "dp-magit-found-file-hook: point: %s" (point)))
     (t nil))))

(global-set-key [(control ?x) (control ?g)]
		(kb-lambda ()
		    (setq current-prefix-arg (not current-prefix-arg))
		    (call-interactively 'magit-status)))

(provide 'dp-magit)

(message "load dp-magit()... done.")
