;;;
;;; Setup the Emacs Lisp PYthon development environment.
;;;

(when (bound-and-true-p dp-use-elpy-mode-p)
  (elpy-enable)

  (defun dp-elpy-mode-hook ()
    (interactive)
    ;; I wanted to do this in the python-mode hook but I had to use
    ;; elpy-mode-map directly which I didn't like.
    (define-key elpy-mode-map [(meta up)] 'dp-other-window-up)
    (define-key elpy-mode-map [(meta down)] 'other-window)
    (define-key elpy-mode-map [(control up)] 'dp-scroll-down)
    (define-key elpy-mode-map [(control down)] 'dp-scroll-up)
    )
  (add-hook 'elpy-mode-hook 'dp-elpy-mode-hook)

  (message "Completed dp-elpy.el setup.")
  )

(provide 'dp-elpy)


